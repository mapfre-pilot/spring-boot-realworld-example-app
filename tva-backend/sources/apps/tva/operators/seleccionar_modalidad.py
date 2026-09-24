"""Acción seleccionar-modalidad — PM TVA modalidadProductosAhorro / propuestaProductosAhorro."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase
from apps.tva.services.connectors.apilife import get_apilife_client

from ._comun import add_aviso, guardar_y_trazar, resultado
from .maquina_pantallas import siguiente

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Selecciona producto/modalidad y avanza según siguientePantalla."""
    modalidad_prod = datos.get("modalidad") or datos.get("productCode")
    if not modalidad_prod:
        a = add_aviso(sesion, AvisosClase.TALLER, "TVA_ERROR_VALIDACION", "modalidad/producto obligatorio")
        guardar_y_trazar(sesion, "SELECCIONAR_MODALIDAD", [a])
        return resultado(sesion)

    # Recuperar el taller (catálogo) para validar la modalidad
    try:
        taller = get_apilife_client().general_table("productos")
    except Exception as exc:
        logger.warning("Taller no disponible: %s", exc)
        taller = {}

    estado = dict(sesion.estado or {})
    estado["modalidadProducto"] = modalidad_prod
    estado["taller"] = taller or estado.get("taller", {})
    sesion.estado = estado
    sesion.pantalla_actual = siguiente(sesion).value
    guardar_y_trazar(sesion, "SELECCIONAR_MODALIDAD", datos=datos)
    return resultado(sesion)
