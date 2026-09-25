"""Tarea de alertas — envía los errores recientes al grupo de alertas por email."""

import logging
from datetime import timedelta

from celery import shared_task
from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone

from apps.tva.models import Traza

logger = logging.getLogger(__name__)


def ejecutar_alertas(horas: int = 1, destinatario: str | None = None) -> dict:
    """Envía por email las trazas ERROR de las últimas `horas`."""
    destinatario = destinatario or settings.ALERTAS_EMAIL_TO
    limite = timezone.now() - timedelta(hours=horas)
    errores = Traza.objects.filter(clase="ERROR", creado__gte=limite).order_by("-creado")[:100]
    if not errores.exists():
        return {"enviadas": 0, "errores": 0}
    if not destinatario:
        logger.warning("ALERTAS_EMAIL_TO no configurado; %s errores sin notificar", errores.count())
        return {"enviadas": 0, "errores": errores.count(), "motivo": "sin destinatario"}
    cuerpo = "\n".join(f"[{e.creado}] {e.clave_sesion} {e.tipo_contenido} {e.mensaje}" for e in errores)
    send_mail(
        subject=f"[TVA] {errores.count()} errores en {horas}h",
        message=cuerpo,
        from_email=settings.ALERTAS_EMAIL_FROM,
        recipient_list=[destinatario],
        fail_silently=True,
    )
    return {"enviadas": 1, "errores": errores.count()}


@shared_task(name="tva.alertas")
def alertas() -> dict:
    return ejecutar_alertas()
