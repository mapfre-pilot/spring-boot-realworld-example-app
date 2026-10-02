"""Acción perfil-cliente — PM TVA Perfil cliente (test conveniencia / perfilado MISV)."""

import logging

from apps.tva.models import Sesion
from apps.tva.schemas.errors import AvisosClase, MENSAJES, aviso
from apps.tva.services.connectors.misv import get_misv_client

from ._comun import guardar_y_trazar, resultado
from .maquina_pantallas import siguiente

logger = logging.getLogger(__name__)


def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Lanza el perfilado del cliente; si no supera conveniencia avisa."""
    avisos = []
    try:
        perfil = get_misv_client().perfilar({"estado": sesion.estado, **datos})
        ok = bool(perfil.get("perfilClientesOK", True))
        sesion.estado = {**(sesion.estado or {}), "perfilCliente": perfil, "perfilClientesOK": ok}
        if not ok:
            avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_CLIENTE_SIN_CONVENIENCIA", MENSAJES["CLIENTE_SIN_CONVENIENCIA"]))
            sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
        else:
            sesion.pantalla_actual = siguiente(sesion).value
    except Exception as exc:
        avisos.append(aviso(AvisosClase.GENERAL, "TVA_ERROR_SERVICIO_EXTERNO", str(exc)))
        sesion.estado = {**(sesion.estado or {}), "avisos": avisos}
    guardar_y_trazar(sesion, "PERFIL_CLIENTE", avisos, datos)
    return resultado(sesion, avisos or None)
