"""Batch apertura/cierre — PM ``TVA Batch Apertura-Cierre``.

Abre/cierra la aplicación según los parámetros TVA_FECHA_APERTURA /
TVA_FECHA_CIERRE y deja traza + aviso a la clase correspondiente.
"""

import logging
from datetime import date, datetime

from celery import shared_task

from apps.tva.models import Parametro, Traza

logger = logging.getLogger(__name__)


def _parse_fecha(valor) -> date | None:
    if not valor:
        return None
    if isinstance(valor, date):
        return valor
    try:
        return datetime.strptime(str(valor)[:10], "%Y-%m-%d").date()
    except (ValueError, TypeError):
        return None


def ejecutar_apertura_cierre(hoy: date | None = None) -> dict:
    """Decide si la app está abierta hoy y fija el parámetro TVA_APLICACION_CERRADA."""
    hoy = hoy or date.today()
    apertura = _parse_fecha(Parametro.get("TVA_FECHA_APERTURA"))
    cierre = _parse_fecha(Parametro.get("TVA_FECHA_CIERRE"))
    cerrada = bool((apertura and hoy < apertura) or (cierre and hoy > cierre))
    param, _ = Parametro.objects.update_or_create(
        clave="TVA_APLICACION_CERRADA",
        defaults={"valor": "1" if cerrada else "0", "tipo": "bool", "descripcion": "Cierre de aplicación (batch apertura-cierre)"},
    )
    Traza.objects.create(
        tipo_contenido="BATCH_APERTURA_CIERRE",
        clase="INFO",
        mensaje=f"Batch apertura-cierre ejecutado: cerrada={cerrada}",
        datos={"hoy": str(hoy), "apertura": str(apertura), "cierre": str(cierre)},
    )
    logger.info("Batch apertura-cierre: cerrada=%s", cerrada)
    return {"cerrada": cerrada, "fecha": str(hoy), "apertura": str(apertura), "cierre": str(cierre)}


@shared_task(name="tva.apertura_cierre")
def apertura_cierre() -> dict:
    return ejecutar_apertura_cierre()
