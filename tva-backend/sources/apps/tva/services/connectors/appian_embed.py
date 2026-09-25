"""Connector de los pop-ups Appian Embedded Interfaces (firma RGPD, captura DNI, test de conveniencia).

El backend obtiene un ``taskId`` de las Web API privadas de Appian TEST; el
frontend monta la tarea con ``embeddedBootstrap.nocache.js``. La API key solo
vive en el backend (no se envía al navegador).
"""

import logging
import uuid
from typing import Protocol

import requests
from django.conf import settings

logger = logging.getLogger(__name__)

# popup (id de la URL) → ruta de la Web API privada en Appian TEST
POPUPS = {
    "rgpd": "webapi/cmp-firma-rgpd",
    "dni": "webapi/cmp-captura-dni",
    "test-conveniencia": "webapi/testIdoneidad",
}


class AppianEmbedError(Exception):
    """Error funcional de la Web API de Appian (HTTP != 2xx o sin conexión)."""

    def __init__(self, status: int, codigo: str, mensaje: str, errores: list | None = None):
        super().__init__(mensaje)
        self.status = status
        self.codigo = codigo
        self.mensaje = mensaje
        self.errores = errores or []


class AppianEmbedClient(Protocol):
    def lanzar(self, popup: str, body: dict) -> dict:  # pragma: no cover - interfaz
        """Devuelve ``{"taskId": str, "taskUrl": str}``."""
        ...


class MockAppianEmbedClient:
    """Stub: genera un taskId local sin llamar a Appian."""

    def lanzar(self, popup: str, body: dict) -> dict:
        return {"taskId": f"MOCK-{popup}-{uuid.uuid4().hex[:8]}", "taskUrl": ""}


class RealAppianEmbedClient:
    """POST directo con ``Appian-API-Key``; sin reintentos (inicia procesos)."""

    def __init__(self) -> None:
        self.base_url = settings.APPIAN_EMBED_BASE_URL.rstrip("/")
        self.timeout = settings.APPIAN_EMBED_TIMEOUT
        self.session = requests.Session()

    def lanzar(self, popup: str, body: dict) -> dict:
        url = f"{self.base_url}/{POPUPS[popup]}"
        try:
            r = self.session.post(
                url,
                json=body,
                headers={"Appian-API-Key": settings.APPIAN_EMBED_API_KEY},
                timeout=self.timeout,
            )
        except requests.RequestException as e:
            logger.warning("Appian embed %s sin conexión", popup)
            raise AppianEmbedError(0, "APPIAN_NO_DISPONIBLE", f"Appian no disponible: {e.__class__.__name__}") from e
        logger.info("Appian embed %s → HTTP %s", popup, r.status_code)
        if not r.ok:
            try:
                err = r.json()
            except ValueError:
                err = {}
            raise AppianEmbedError(
                r.status_code,
                str(err.get("code") or "APPIAN_ERROR"),
                str(err.get("message") or "Error en la Web API de Appian"),
                err.get("errors") or [],
            )
        data = r.json()
        return {"taskId": str(data.get("taskId") or ""), "taskUrl": str(data.get("taskUrl") or "")}


_client: AppianEmbedClient | None = None


def get_appian_embed_client() -> AppianEmbedClient:
    global _client
    if _client is None:
        _client = RealAppianEmbedClient() if settings.APPIAN_EMBED_MODE == "real" else MockAppianEmbedClient()
    return _client
