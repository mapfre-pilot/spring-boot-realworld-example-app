"""Celery app for TVA.

Stub point: sustituye a ``arch-ram-lib-django-celery``. La librería
corporativa configura el broker, los serializers y el autodiscovery;
aquí se hace directamente sobre celery + redis.
"""

import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

app = Celery("tva")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
