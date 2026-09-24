"""Acción firmar — PM TVA PopUp Firmar / TVA Firmar / Firma-EnvioFirmaManuscrita."""

import logging

from apps.tva.models import Pantalla, Sesion
from apps.tva.schemas.errors import AvisosClase, MENSAJES, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import guardar_y_trazar, resultado
from .maquina_pantallas import siguiente

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Envía la solicitud a firma (electrónica o manuscrita) y avanza."""
    avisos = []
    tipo_firma = datos.get("tipoFirma", "electronica")
    try:
        response = get_apilife_client().policy_documents({"estado": sesion.estado, "tipoFirma": tipo_firma, **datos})
        sesion.estado = {**(sesion.estado or {}), "firma": {"tipo": tipo_firma, "response": response}, "avisos": []}
        sesion.pantalla_actual = siguiente(sesion).value
        if sesion.pantalla_actual != Pantalla.FIN.value and sesion.pantalla_actual != Pantalla.RESULTADO_FIRMA.value:
            sesion.pantalla_actual = Pantalla.RESULTADO_FIRMA.value
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.FIRMA, "TVA_ERROR_PROCESO_FIRMA", MENSAJES["PROCESO_FIRMA"]))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
        logger.error("Envío a firma falló: %s", exc)
    guardar_y_trazar(sesion, "FIRMAR", avisos, datos)
    return resultado(sesion, avisos or None)
