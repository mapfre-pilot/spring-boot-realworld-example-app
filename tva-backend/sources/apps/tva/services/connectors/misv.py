"""Connector MISV — perfilado de clientes (TVA_MISV / TVA_PerfiladoClientes)."""

import json
import logging
from pathlib import Path

from django.conf import settings

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)
FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"


class MisvClient:
    def perfilar(self, payload: dict) -> dict:  # pragma: no cover - interface
        raise NotImplementedError


class MockMisvClient(MisvClient):
    def perfilar(self, payload: dict) -> dict:
        path = FIXTURES_DIR / "perfilado_clientes.json"
        if path.exists():
            return dict(json.loads(path.read_text(encoding="utf8")))
        return {"profileCode": "ME", "perfilClientesOK": True}


class RealMisvClient(MisvClient):
    def __init__(self) -> None:
        self.http = BaseHttpClient(base_url=settings.MISV_BASE_URL, timeout=30)

    def perfilar(self, payload: dict) -> dict:
        return dict(self.http.post("perfilado", json=payload).json())


_client: MisvClient | None = None


def get_misv_client() -> MisvClient:
    global _client
    if _client is None:
        _client = RealMisvClient() if settings.MISV_MODE == "real" else MockMisvClient()
    return _client
