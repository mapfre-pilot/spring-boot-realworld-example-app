"""Connector RIC — búsqueda de personas/cliente Vida (TVA_GestionarPersonas, MU_ObtenerClienteRIC)."""

import json
import logging
from pathlib import Path

from django.conf import settings

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)
FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"


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
    def __init__(self) -> None:
        self.http = BaseHttpClient(base_url=settings.RIC_BASE_URL, timeout=30)

    def buscar_cliente(self, documento: str) -> dict:
        return dict(self.http.get("personas", params={"documento": documento}).json())


_client: RicClient | None = None


def get_ric_client() -> RicClient:
    global _client
    if _client is None:
        _client = RealRicClient() if settings.RIC_MODE == "real" else MockRicClient()
    return _client
