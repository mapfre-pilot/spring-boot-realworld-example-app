"""Caso de uso: inicio de sesión de tarificación.

Equivale a los PM ``TVA Inicio Ahorro`` / ``TVA Inicio SimuladorRentas`` y
a la Web API ``TVA InicioTarificadorVidaAhorro``:
  1. validar el contrato de entrada (``TVA_WebApi_Inicio_ObtenerMensajeError``)
  2. comprobar apertura (param TVA_APLICACION_CERRADA)
  3. perfil del usuario (conector perfil_usuario → funcionalidades)
  4. cliente en RIC/API Life (conector ric)
  5. crear Sesion con el estado ``TVA_Sesion`` (§12.3) y la pantalla
     inicial según ``TVA_propuestaProductosAhorro_siguientePantalla``.

Contrato nuevo (primario): ``{indFunctionMode, proposalId, companyId,
distributionChannel, username, policyHolders[], investment[]}``.
Se aceptan además los campos legacy ``documentoCliente/canal/propuesta``
por compatibilidad con tests anteriores.
"""

import logging

from apps.tva.models import Pantalla, Parametro, Sesion, Traza
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import get_apilife_client
from apps.tva.services.connectors.perfil_usuario import get_perfil_usuario_client
from apps.tva.services.connectors.ric import get_ric_client

from .maquina_pantallas import pantalla_inicio
from .sesion_modelo import nueva_sesion_estado
from .validaciones import nuuma_desde_username, validar_parametros_inicio, validar_parametros_inicio_body

logger = logging.getLogger(__name__)

# Texto Appian cuando el catálogo viene vacío (conserva la falta original).
MSG_SIN_PRODUCTOS = "El servicio no ha devuelvo ningún producto de ahorro"


class InicioError(Exception):
    """Error funcional en el inicio de sesión (lleva avisos asociados)."""

    def __init__(self, codigo: str, mensaje: str, avisos: list | None = None) -> None:
        super().__init__(mensaje)
        self.codigo = codigo
        self.mensaje = mensaje
        self.avisos = avisos or []


def _aplicacion_cerrada() -> bool:
    return bool(Parametro.get("TVA_APLICACION_CERRADA", 0))


def _es_contrato_nuevo(datos: dict) -> bool:
    return any(k in datos for k in ("indFunctionMode", "companyId", "distributionChannel", "username", "investment", "policyHolders"))


def _tomadores_desde_policy_holders(policy_holders: list) -> list:
    from .sesion_modelo import _tomador_vacio

    tomadores = []
    for ph in policy_holders or []:
        t = _tomador_vacio()
        t["datosPersonales"] = dict(ph)
        tomadores.append(t)
    if not tomadores:
        tomadores = [_tomador_vacio()]
    return tomadores


def iniciar_sesion(usuario: str, datos: dict) -> tuple[Sesion | None, list[str]]:
    """Crea una sesión de tarificación.

    Devuelve ``(sesion, errores)``: si ``errores`` no está vacío la sesión es
    ``None`` y la vista responde el sobre de error de la Web API (§12.4.1).
    """
    datos = datos or {}
    errores = []
    if _es_contrato_nuevo(datos):
        nuuma = nuuma_desde_username(str(datos.get("username") or ""))
        codigos = None
        if datos.get("investment"):
            try:
                prods = (
                    get_apilife_client()
                    .product_list(
                        company_id=datos.get("companyId"),
                        nuuma=nuuma,
                        distribution_channel=datos.get("distributionChannel"),
                    )
                    .get("products", [])
                )
                codigos = [str(p.get("commercialProductCode") or p.get("code") or "") for p in prods]
            except Exception as exc:
                logger.warning("ProductList no disponible para validar investment: %s", exc)
        errores = validar_parametros_inicio_body(datos, codigos)
        if errores:
            return None, errores
        modalidad = str(datos.get("indFunctionMode"))
        if modalidad == "VIR":
            modalidad = "R2C"
        documento_cliente = ((datos.get("policyHolders") or [{}])[0].get("documentId")) or ""
        canal = str(datos.get("distributionChannel") or "OTRO")
        propuesta = {}
        investment_option = (datos.get("investment") or [None])[0]
        company_id = str(datos.get("companyId") or "")
        distribution_channel = str(datos.get("distributionChannel") or "")
    else:
        # Contrato legacy
        avisos = validar_parametros_inicio(datos.get("documentoCliente", ""), datos.get("canal", ""))
        if avisos:
            raise InicioError("TVA_ERROR_PARAMETROS_ENTRADA", "Parámetros de entrada inválidos", avisos)
        propuesta = datos.get("propuesta") or {}
        modalidad = propuesta.get("modoFuncionamiento") or datos.get("modalidad") or "VA"
        if modalidad == "VIR":
            modalidad = "R2C"
        documento_cliente = datos.get("documentoCliente", "")
        canal = datos.get("canal", "OTRO")
        nuuma = usuario.upper()
        company_id = propuesta.get("companyId")
        distribution_channel = canal
        investment_option = propuesta.get("investmentOption")

    if _aplicacion_cerrada():
        raise InicioError(
            "TVA_ERROR_APLICACION_CERRADA",
            str(Parametro.get("TVA_MENSAJE_MOTIVO_CIERRE", "Aplicación cerrada por mantenimiento"))
            or "Aplicación cerrada por mantenimiento",
            [aviso(AvisosClase.GENERAL, "TVA_ERROR_APLICACION_CERRADA", "Aplicación cerrada", tipo="ERROR")],
        )

    perfil = get_perfil_usuario_client().obtener_perfil(usuario)
    if not perfil.get("conPerfil", True) and not perfil.get("funcionalidades"):
        sesion = Sesion.objects.create(
            usuario=usuario,
            modalidad=modalidad,
            canal=canal if canal in ("GV", "PFM") else "OTRO",
            pantalla_actual=Pantalla.SIN_PERFIL.value,
            abierta=False,
            estado=nueva_sesion_estado(
                "",
                modalidad,
                nuuma=nuuma,
                perfil_usuario=perfil,
            ),
        )
        sesion.estado["avisos"] = [aviso(AvisosClase.GENERAL, "TVA_ERROR_SIN_PERFIL", "Usuario sin perfil", tipo="ERROR")]
        sesion.estado["idPantallaActual"] = Pantalla.SIN_PERFIL.value
        sesion.save(update_fields=["estado"])
        return sesion, []

    cliente = get_ric_client().buscar_cliente(documento_cliente)

    try:
        productos = (
            get_apilife_client()
            .product_list(company_id=company_id, nuuma=nuuma, distribution_channel=distribution_channel)
            .get("products", [])
        )
    except Exception as exc:
        logger.warning("ProductList falló en inicio: %s", exc)
        productos = []

    tomadores = _tomadores_desde_policy_holders(datos.get("policyHolders") or [])
    estado = nueva_sesion_estado(
        "",
        modalidad,
        codigo_producto=(investment_option or {}).get("commercialProductCode"),
        company_id=company_id,
        distribution_channel=distribution_channel,
        nuuma=nuuma,
        perfil_usuario={**perfil, "nuuma": nuuma},
        tomadores=tomadores,
        propuesta=propuesta,
        investment_option=investment_option,
        perfil_clientes_ok=bool(cliente.get("perfilClientesOK", True)),
    )
    estado["documentoCliente"] = documento_cliente
    estado["clienteVida"] = cliente.get("clienteVida", cliente)
    estado["productos"] = productos
    if not productos and modalidad == "VIA":
        estado["avisos"] = [aviso(AvisosClase.TALLER, "TVA_ERROR_SIN_PRODUCTOS", MSG_SIN_PRODUCTOS, tipo="ERROR")]

    pantalla = pantalla_inicio(modalidad, estado)
    estado["idPantallaActual"] = pantalla.value

    sesion = Sesion.objects.create(
        usuario=usuario,
        modalidad=modalidad,
        canal=canal if canal in ("GV", "PFM") else "OTRO",
        pantalla_actual=pantalla.value,
        estado=estado,
    )
    estado["claveSesion"] = str(sesion.clave)
    sesion.save(update_fields=["estado"])
    Traza.objects.create(
        sesion=sesion,
        clave_sesion=str(sesion.clave),
        tipo_contenido="INICIO",
        mensaje=f"Inicio sesión {modalidad} canal {canal}",
        datos={"documentoCliente": "***", "nuuma": nuuma},
    )
    logger.info("Sesión %s creada para %s (%s)", sesion.clave, usuario, modalidad)
    return sesion, []
