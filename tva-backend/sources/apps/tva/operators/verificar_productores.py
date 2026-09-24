"""Acción verificar-productores — PM TVA VerificarProductores."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import guardar_y_trazar, resultado

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    avisos = []
    try:
        response = get_apilife_client().verify_producers({"estado": sesion.estado, **datos})
        sesion.estado = {**(sesion.estado or {}), "verifyProducers": response, "avisos": []}
        if response.get("productoresNoVerificados"):
            avisos.append(aviso(AvisosClase.VERIFICAR_PRODUCTORES, "TVA_AVISO_PRODUCTORES", "Hay productores no verificados"))
            sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.VERIFICAR_PRODUCTORES, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "VERIFICAR_PRODUCTORES", avisos, datos)
    return resultado(sesion, avisos or None)
