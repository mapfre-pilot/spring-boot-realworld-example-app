"""Connector RIC — búsqueda de personas/cliente Vida (MU_ObtenerClienteRIC).

El lookup real vive en la regla cross-app ``MU_ObtenerClienteRIC`` (fuera
del dump TVA) y Appian DEV usa el mock bajo
``TVA_FLAG_SIMULAR_BUSQUEDA_CLIENTE_RIC``. ``RealRicClient`` es
configurable (``RIC_BASE_URL``/``RIC_PATH``/``RIC_USERNAME``/``RIC_PASSWORD``,
GET con ``documento``) pero el contrato debe confirmarse con los dueños de
la aplicación MU.
"""

import json
import logging
from pathlib import Path

import requests

from apps.tva.services import configuracion

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)
FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"


class RicError(Exception):
    """Error llamando a RIC."""


class RicClient:
    def buscar_cliente(self, documento: str) -> dict:  # pragma: no cover - interface
        raise NotImplementedError


class MockRicClient(RicClient):
    def buscar_cliente(self, documento: str) -> dict:
        path = FIXTURES_DIR / "cliente_vida.json"
        if path.exists():
            return dict(json.loads(path.read_text(encoding="utf8")))
        return {"documento": documento, "encontrado": True, "clienteVida": {}}


class RealRicClient(RicClient):
    """Contrato orientativo (pendiente de confirmar con MU):

    ``GET {RIC_BASE_URL}/{RIC_PATH}?documento=<nif>`` con Basic auth.
    """

    def __init__(self) -> None:
        self.http = BaseHttpClient(
            base_url=configuracion.obtener("RIC_BASE_URL"),
            timeout=configuracion.obtener("RIC_TIMEOUT"),
            username=configuracion.obtener("RIC_USERNAME") or "",
            password=configuracion.obtener("RIC_PASSWORD") or "",
        )
        self.path = configuracion.obtener("RIC_PATH") or "personas"

    def buscar_cliente(self, documento: str) -> dict:
        try:
            resp = self.http.session.get(
                f"{self.http.base_url}/{self.path.lstrip('/')}",
                params={"documento": documento},
                timeout=self.http.timeout,
            )
        except requests.RequestException as exc:
            logger.error("RIC no disponible: %s", type(exc).__name__)
            raise RicError(f"RIC_NO_DISPONIBLE: {exc}") from exc
        if not resp.ok:
            raise RicError(f"HTTP {resp.status_code} en RIC")
        return dict(resp.json())


_client: RicClient | None = None
_huella: tuple | None = None


def get_ric_client() -> RicClient:
    global _client, _huella
    huella = configuracion.huella("ric")
    if _client is None or huella != _huella:
        _client = RealRicClient() if configuracion.obtener("RIC_MODE") == "real" else MockRicClient()
        _huella = huella
    return _client


def reset_ric_client() -> None:
    global _client
    _client = None
