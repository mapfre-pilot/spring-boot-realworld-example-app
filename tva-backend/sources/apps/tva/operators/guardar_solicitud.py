"""Acción guardar-solicitud — PM TVA Guardar y volver (saveProposal / savingInsuranceApplication)."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase, aviso
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._comun import guardar_y_trazar, resultado

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Guarda la solicitud en API Life y avisa del resultado."""
    avisos = []
    try:
        response = get_apilife_client().save_proposal({"estado": sesion.estado, **datos})
        sesion.estado = {**(sesion.estado or {}), "saveProposalResponse": response}
        if response.get("hasErrors") or response.get("errors"):
            avisos.append(aviso(AvisosClase.SAVE_PROPOSAL, "TVA_ERROR_SERVICIO_EXTERNO", "Errores al guardar la propuesta"))
        else:
            avisos.append(aviso(AvisosClase.SAVE_PROPOSAL, "TVA_OK_SAVE_PROPOSAL", "Solicitud guardada"))
    except ApiLifeError as exc:
        avisos.append(aviso(AvisosClase.SAVE_PROPOSAL, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
    sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "GUARDAR_SOLICITUD", avisos, datos)
    return resultado(sesion, avisos)
