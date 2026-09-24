"""Caso de uso: inicio de sesión de tarificación.

Equivale a los PM ``TVA Inicio Ahorro`` / ``TVA Inicio SimuladorRentas`` y
a la Web API ``TVA InicioTarificadorVidaAhorro``:
  1. comprobar apertura (param TVA_APLICACION_CERRADA)
  2. perfil del usuario (conector perfil_usuario → funcionalidades)
  3. cliente en RIC/API Life (conector ric)
  4. crear Sesion con pantalla inicial según modalidad
"""

import logging

from apps.tva.models import Pantalla, Parametro, Sesion, Traza
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.perfil_usuario import get_perfil_usuario_client
from apps.tva.services.connectors.ric import get_ric_client

from .maquina_pantallas import pantalla_inicio
from .validaciones import validar_parametros_inicio

logger = logging.getLogger(__name__)


class InicioError(Exception):
    """Error funcional en el inicio de sesión (lleva avisos asociados)."""

    def __init__(self, codigo: str, mensaje: str, avisos: list | None = None) -> None:
        super().__init__(mensaje)
        self.codigo = codigo
        self.mensaje = mensaje
        self.avisos = avisos or []


def _aplicacion_cerrada() -> bool:
    return bool(Parametro.get("TVA_APLICACION_CERRADA", 0))


def iniciar_sesion(usuario: str, documento_cliente: str, canal: str, modalidad: str, propuesta: dict | None = None) -> Sesion:
    """Crea una sesión de tarificación o lanza InicioError."""
    avisos = validar_parametros_inicio(documento_cliente, canal)
    if avisos:
        raise InicioError("TVA_ERROR_PARAMETROS_ENTRADA", "Parámetros de entrada inválidos", avisos)

    if _aplicacion_cerrada():
        raise InicioError(
            "TVA_ERROR_APLICACION_CERRADA",
            str(Parametro.get("TVA_MENSAJE_MOTIVO_CIERRE", "Aplicación cerrada por mantenimiento"))
            or "Aplicación cerrada por mantenimiento",
            [aviso(AvisosClase.GENERAL, "TVA_ERROR_APLICACION_CERRADA", "Aplicación cerrada")],
        )

    perfil = get_perfil_usuario_client().obtener_perfil(usuario)
    if not perfil.get("conPerfil", True) and not perfil.get("funcionalidades"):
        return _sesion_sin_perfil(usuario, modalidad, canal)

    cliente = get_ric_client().buscar_cliente(documento_cliente)
    estado = {
        "documentoCliente": documento_cliente,
        "codigoProductor": perfil.get("codProductor", ""),
        "funcionalidades": perfil.get("funcionalidades", []),
        "clienteVida": cliente.get("clienteVida", cliente),
        "perfilClientesOK": bool(cliente.get("perfilClientesOK", True)),
        "investmentOption": (propuesta or {}).get("investmentOption"),
        "responseProposal": propuesta or {},
        "avisos": [],
    }

    sesion = Sesion.objects.create(
        usuario=usuario,
        modalidad=modalidad,
        canal=canal if canal in ("GV", "PFM") else "OTRO",
        pantalla_actual=pantalla_inicio(modalidad, estado).value,
        estado=estado,
    )
    Traza.objects.create(
        sesion=sesion,
        clave_sesion=str(sesion.clave),
        tipo_contenido="INICIO",
        mensaje=f"Inicio sesión {modalidad} canal {canal}",
        datos={"documentoCliente": "***"},
    )
    logger.info("Sesión %s creada para %s (%s)", sesion.clave, usuario, modalidad)
    return sesion


def _sesion_sin_perfil(usuario: str, modalidad: str, canal: str) -> Sesion:
    return Sesion.objects.create(
        usuario=usuario,
        modalidad=modalidad,
        canal=canal if canal in ("GV", "PFM") else "OTRO",
        pantalla_actual=Pantalla.SIN_PERFIL.value,
        abierta=False,
        estado={"avisos": [aviso(AvisosClase.GENERAL, "TVA_ERROR_SIN_PERFIL", "Usuario sin perfil")]},
    )
