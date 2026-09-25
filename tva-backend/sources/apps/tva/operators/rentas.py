"""Acciones de rentas R2C — PM TVA R2C Precios-Recalcular / Precios-Contratar / CapturaDatosRentas-Contratar."""

import logging

from apps.tva.models import Pantalla, Sesion
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import guardar_y_trazar, resultado
from .maquina_pantallas import siguiente_pantalla

logger = logging.getLogger(__name__)


def recalcular(sesion: Sesion, datos: dict) -> dict:
    """Llama a individualAnnuitySimulation para recalcular precios."""
    avisos = []
    try:
        response = get_apilife_client().annuity_simulation({"estado": sesion.estado, **datos})
        sesion.estado = {**(sesion.estado or {}), "annuitySimulation": response, "avisos": []}
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.ANNUITY_SIMULATION, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "R2C_RECALCULAR", avisos, datos)
    return resultado(sesion, avisos or None)


def contratar(sesion: Sesion, datos: dict) -> dict:
    """Llama a individualAnnuityInsuranceApplication y avanza a resumen/firma."""
    avisos = []
    try:
        response = get_apilife_client().annuity_insurance_application({"estado": sesion.estado, **datos})
        sesion.estado = {**(sesion.estado or {}), "insuranceApplication": response, "avisos": []}
        sesion.pantalla_actual = siguiente_pantalla(sesion).value
        if sesion.pantalla_actual == Pantalla.R2C_CAPTURA.value:  # estaba en captura
            sesion.pantalla_actual = Pantalla.R2C_PRECIOS.value
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.INSURANCE_APPLICATION, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "R2C_CONTRATAR", avisos, datos)
    return resultado(sesion, avisos or None)
