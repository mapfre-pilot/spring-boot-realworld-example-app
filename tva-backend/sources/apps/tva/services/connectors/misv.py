"""Connector MISV — perfilado de clientes (TVA_MISV / TVA_PerfiladoClientes).

Real: ``GET /NOVAServices/rest/RSPerfiladoClienteV2/obtenerPerfiladoCliente``
con query ``USUARIO`` (nuuma), ``APLICACION`` (cons!VIDA_ACRONIMO_APLICACION),
``NIF`` normalizado con ``arreglo_nif_pfm`` (rule!TVA_ArregloNIF_PFM) y
``TIPO_PERSONA`` (cons!VIDA_CODIGOS_TIPO_PERSONA_FISICA). Basic auth
(connected system "TVA MISV", usuario APPCMPA).
"""

import json
import logging
from pathlib import Path

import requests

from apps.tva.services import configuracion

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)
FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"

PERFILADO_PATH = "/NOVAServices/rest/RSPerfiladoClienteV2/obtenerPerfiladoCliente"


class MisvError(Exception):
    """Error llamando a MISV."""


def arreglo_nif_pfm(nif: str) -> str:
    """Puerto de ``TVA_ArregloNIF_PFM``: quita un cero a la izquierda del NIF
    (si empieza por 0 devuelve los 8 últimos caracteres)."""
    if nif and nif[0] == "0":
        return nif[-8:]
    return nif


def _misv_params(payload: dict) -> dict:
    estado = payload.get("estado") or {}
    nuuma = payload.get("nuuma") or estado.get("nuuma") or ""
    nif = (
        payload.get("nif")
        or payload.get("NIF")
        or payload.get("documento")
        or payload.get("documentId")
        or ((estado.get("tomadores") or [{}])[0].get("datosPersonales") or {}).get("documentId")
        or ""
    )
    return {
        "USUARIO": nuuma,
        "APLICACION": configuracion.obtener("MISV_APLICACION") or "VIDA",
        "NIF": arreglo_nif_pfm(nif),
        "TIPO_PERSONA": configuracion.obtener("MISV_TIPO_PERSONA") or "F",
    }


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
        self.http = BaseHttpClient(
            base_url=configuracion.obtener("MISV_BASE_URL"),
            timeout=configuracion.obtener("MISV_TIMEOUT"),
            username=configuracion.obtener("MISV_USERNAME"),
            password=configuracion.obtener("MISV_PASSWORD"),
        )

    def perfilar(self, payload: dict) -> dict:
        params = _misv_params(payload)
        try:
            resp = self.http.session.get(
                f"{self.http.base_url}{PERFILADO_PATH}",
                params=params,
                timeout=configuracion.obtener("MISV_TIMEOUT"),
            )
        except requests.RequestException as exc:
            logger.error("MISV perfilado no disponible: %s", type(exc).__name__)
            raise MisvError(f"MISV_NO_DISPONIBLE: {exc}") from exc
        if not resp.ok:
            raise MisvError(f"HTTP {resp.status_code} en perfilado MISV")
        return dict(resp.json())


_client: MisvClient | None = None
_huella: tuple | None = None


def get_misv_client() -> MisvClient:
    global _client, _huella
    huella = configuracion.huella("misv")
    if _client is None or huella != _huella:
        _client = RealMisvClient() if configuracion.obtener("MISV_MODE") == "real" else MockMisvClient()
        _huella = huella
    return _client


def reset_misv_client() -> None:
    global _client
    _client = None
