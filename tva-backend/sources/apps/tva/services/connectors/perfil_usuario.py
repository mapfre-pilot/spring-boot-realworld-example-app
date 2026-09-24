"""Connector perfil de usuario — TVA_WSDL_IGestionarPerfilUsuario / API Life perfilUsuario.

Devuelve las funcionalidades asignadas al usuario (oficina, codProductor,
funcionalidades TVA_FUNCIONALIDAD_*).
"""

import json
import logging
from pathlib import Path

from django.conf import settings

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)
FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"


class PerfilUsuarioClient:
    def obtener_perfil(self, usuario: str) -> dict:  # pragma: no cover - interface
        raise NotImplementedError


class MockPerfilUsuarioClient(PerfilUsuarioClient):
    def obtener_perfil(self, usuario: str) -> dict:
        path = FIXTURES_DIR / "perfil_usuario.json"
        if path.exists():
            data = json.loads(path.read_text(encoding="utf8"))
            return dict(data.get("response", data))
        return {"usuario": usuario, "conPerfil": True, "funcionalidades": ["4016", "4017", "4018"], "codProductor": "P0001"}


class RealPerfilUsuarioClient(PerfilUsuarioClient):
    def __init__(self) -> None:
        self.http = BaseHttpClient(base_url=settings.PERFIL_USUARIO_BASE_URL, timeout=30)

    def obtener_perfil(self, usuario: str) -> dict:
        return dict(self.http.get("perfilUsuario", params={"usuario": usuario}).json())


_client: PerfilUsuarioClient | None = None


def get_perfil_usuario_client() -> PerfilUsuarioClient:
    global _client
    if _client is None:
        _client = RealPerfilUsuarioClient() if settings.PERFIL_USUARIO_MODE == "real" else MockPerfilUsuarioClient()
    return _client
