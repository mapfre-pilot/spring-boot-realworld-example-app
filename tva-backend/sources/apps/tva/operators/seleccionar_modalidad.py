"""Acción seleccionar-modalidad — PM TVA modalidadProductosAhorro / propuestaProductosAhorro."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase
from apps.tva.services.connectors.apilife import get_apilife_client

from ._comun import add_aviso, guardar_y_trazar, resultado
from .maquina_pantallas import siguiente_pantalla

logger = logging.getLogger(__name__)


def aplicar_producto(estado: dict, codigo_producto: str, investment_option: dict | None = None) -> dict:
    """Copia al estado los datos del producto seleccionado (garantías con
    las obligatorias preseleccionadas y opciones de inversión), como hace
    Appian al fijar la modalidad. Devuelve el nuevo estado.

    ``investment_option`` (opcional, desde la propuesta VA) precarga
    ``datosOperacion`` con primaUnica/aportacionPeriodica si están vacíos.
    """
    nuevo = dict(estado or {})
    try:
        taller = get_apilife_client().general_table("productos")
    except Exception as exc:
        logger.warning("Taller no disponible: %s", exc)
        taller = {}
    nuevo["modalidadProducto"] = codigo_producto
    nuevo["codigoProducto"] = codigo_producto
    nuevo["taller"] = taller or nuevo.get("taller", {})
    producto = next(
        (p for p in nuevo.get("productos") or [] if str(p.get("commercialProductCode") or p.get("code")) == str(codigo_producto)),
        {},
    )
    if producto:
        nuevo["productoSeleccionado"] = producto
        nuevo["garantias"] = [{**g, "seleccionada": bool(g.get("obligatoria"))} for g in producto.get("garantias") or []]
        via = dict(nuevo.get("ventaInformada") or {})
        via["opcionesInversion"] = [dict(o) for o in producto.get("opcionesInversion") or []]
        nuevo["ventaInformada"] = via
    if investment_option:
        op = dict(nuevo.get("datosOperacion") or {})
        if not op.get("primaUnica"):
            op["primaUnica"] = investment_option.get("uniqueContributionAmn")
        if not op.get("aportacionPeriodica"):
            op["aportacionPeriodica"] = investment_option.get("periodicContributionAmn")
        nuevo["datosOperacion"] = op
    return nuevo


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Selecciona producto/modalidad y avanza según siguientePantalla."""
    modalidad_prod = datos.get("modalidad") or datos.get("productCode")
    if not modalidad_prod:
        a = add_aviso(sesion, AvisosClase.TALLER, "TVA_ERROR_VALIDACION", "modalidad/producto obligatorio")
        guardar_y_trazar(sesion, "SELECCIONAR_MODALIDAD", [a])
        return resultado(sesion)

    applications = (
        (((sesion.estado or {}).get("responseProposal") or {}).get("contractingProposal") or {}).get("insurancesApplication")
    ) or []
    app = next(
        (a for a in applications if str(a.get("commercialProductCode")) == str(modalidad_prod)),
        {},
    )
    inv = (app.get("investmentOptions") or [None])[0]
    sesion.estado = aplicar_producto(sesion.estado or {}, modalidad_prod, inv)
    sesion.pantalla_actual = siguiente_pantalla(sesion).value
    guardar_y_trazar(sesion, "SELECCIONAR_MODALIDAD", datos=datos)
    return resultado(sesion)
