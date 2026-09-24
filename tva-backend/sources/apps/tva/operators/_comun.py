"""Helpers compartidos por los operadores."""

import logging

from apps.tva.models import Sesion, Traza
from apps.tva.schemas.errors import aviso
from apps.core.observability import set_clave_sesion

logger = logging.getLogger(__name__)


def resultado(sesion: Sesion, avisos: list | None = None) -> dict:
    """Respuesta estándar de POST acciones."""
    return {
        "claveSesion": str(sesion.clave),
        "pantallaActual": sesion.pantalla_actual,
        "avisos": avisos if avisos is not None else (sesion.estado or {}).get("avisos", []),
        "estado": sesion.estado,
    }


def guardar_y_trazar(sesion: Sesion, ubicacion: str, avisos: list | None = None, datos: dict | None = None) -> Sesion:
    """Persiste la sesión y deja traza (equiv. grabar traza en PM)."""
    sesion.save(update_fields=["pantalla_actual", "estado", "abierta", "actualizado"])
    Traza.objects.create(
        sesion=sesion,
        clave_sesion=str(sesion.clave),
        tipo_contenido=ubicacion,
        clase="ERROR" if any(a.get("codigo", "").endswith("ERROR") for a in (avisos or [])) else "INFO",
        mensaje=f"Acción {ubicacion} en {sesion.pantalla_actual}",
        datos=datos or {},
    )
    set_clave_sesion(str(sesion.clave))
    return sesion


def add_aviso(sesion: Sesion, clase, codigo: str, mensaje: str) -> dict:
    a = aviso(clase, codigo, mensaje)
    sesion.estado = {**(sesion.estado or {}), "avisos": [*(sesion.estado or {}).get("avisos", []), a]}
    return a
