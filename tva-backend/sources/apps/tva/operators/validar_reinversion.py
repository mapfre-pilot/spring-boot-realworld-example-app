"""Acción validar-reinversion — PM TVA ValidarReinversion."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import guardar_y_trazar, resultado

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    avisos = []
    try:
        response = get_apilife_client().validate_reinvestment({"estado": sesion.estado, **datos})
        sesion.estado = {**(sesion.estado or {}), "validateReinvestment": response, "avisos": []}
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "VALIDAR_REINVERSION", avisos, datos)
    return resultado(sesion, avisos or None)
