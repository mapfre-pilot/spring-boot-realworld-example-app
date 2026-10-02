"""Acción importe-maximo — PM TVA ImporteMaximo (SBC máximo por agrupación fiscal)."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import guardar_y_trazar, resultado

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    avisos = []
    try:
        response = get_apilife_client().sbc_maximo({"estado": sesion.estado, **datos})
        sesion.estado = {**(sesion.estado or {}), "importeMaximo": response.get("importeMaximo", response), "avisos": []}
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "IMPORTE_MAXIMO", avisos, datos)
    return resultado(sesion, avisos or None)
