"""Batch borrado de trazas — PM ``TVA Batch Borrar traza``.

Borra las trazas con más de ``TVA_TRAZA_DIAS_PERMANENCIA`` días,
exceptuando las claves ``TVA_TRAZA_CLAVES_SESION_NO_BORRAR`` /
nuuma ``TVA_TRAZA_NUUMA_NO_BORRAR``.
"""

import logging
from datetime import timedelta

from celery import shared_task
from django.utils import timezone

from apps.tva.models import Parametro, Traza

logger = logging.getLogger(__name__)


def ejecutar_borrar_trazas(dias: int | None = None) -> dict:
    dias = dias if dias is not None else int(Parametro.get("TVA_TRAZA_DIAS_PERMANENCIA", 30) or 30)
    claves_no_borrar = Parametro.get("TVA_TRAZA_CLAVES_SESION_NO_BORRAR", []) or []
    if isinstance(claves_no_borrar, str):
        claves_no_borrar = [claves_no_borrar]
    limite = timezone.now() - timedelta(days=dias)
    qs = Traza.objects.filter(creado__lt=limite).exclude(clave_sesion__in=claves_no_borrar)
    borradas = qs.count()
    qs.delete()
    logger.info("Borradas %s trazas > %s días", borradas, dias)
    return {"borradas": borradas, "dias": dias}


@shared_task(name="tva.borrar_trazas")
def borrar_trazas() -> dict:
    return ejecutar_borrar_trazas()
