"""Observability stub replacing ``arch-ram-lib-django-observability``.

Responsabilidad: logging JSON con request-id y propagación de la
``claveSesion`` de TVA como atributo de traza/log.

Swap: sustituir ``JsonFormatter`` y ``ObservabilityMiddleware`` por los
middlewares/formatters de la librería corporativa y actualizar
``LOGGING`` y ``MIDDLEWARE`` en settings.
"""

import contextvars
import json
import logging
import uuid
from datetime import datetime, timezone

_request_id: contextvars.ContextVar[str] = contextvars.ContextVar("request_id", default="")
_clave_sesion: contextvars.ContextVar[str] = contextvars.ContextVar("clave_sesion", default="")


def set_clave_sesion(clave: str) -> None:
    """Propaga la claveSesion de TVA al contexto de log."""
    _clave_sesion.set(clave or "")


def get_request_id() -> str:
    return _request_id.get()


class JsonFormatter(logging.Formatter):
    """Formatter JSON de una línea con requestId y claveSesion."""

    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "requestId": _request_id.get(),
            "claveSesion": _clave_sesion.get(),
        }
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        return json.dumps(payload, ensure_ascii=False)


class ObservabilityMiddleware:
    """Genera/propaga un request-id por petición (cabecera X-Request-Id)."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request_id = request.headers.get("X-Request-Id") or uuid.uuid4().hex
        token = _request_id.set(request_id)
        try:
            response = self.get_response(request)
            response["X-Request-Id"] = request_id
            return response
        finally:
            _request_id.reset(token)
            _clave_sesion.set("")
