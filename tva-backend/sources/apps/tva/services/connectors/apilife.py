"""Connector API Life — 16 endpoints ``TVA_API_Life_*`` + SBC máximo.

Interfaz única ``ApiLifeClient`` con dos implementaciones:

- ``MockApiLifeClient``: carga los fixtures JSON de ``fixtures/apilife/``
  (derivados de las reglas ``TVA_MOCK_*`` del volcado Appian).
- ``RealApiLifeClient``: HTTP sobre ``apps.core.httpclient.BaseHttpClient``
  (stub de arch-ram-lib-django-httpclient) con credenciales por env.

Selección por ``APILIFE_MODE=mock|real``.
"""

import json
import logging
from pathlib import Path
from typing import Any

from django.conf import settings

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)

FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"

# Mapa endpoint → fixture (derivado de las reglas TVA_MOCK_* / TVA_API_Life_*)
ENDPOINT_FIXTURES = {
    "individualAnnuitySimulation": "annuity_simulation",
    "individualAnnuityInsuranceApplication": "annuity_insurance_application",
    "individualDocuments": "individual_documents",
    "validateReinvestment": "validate_reinvestment",
    "individualNotes": "individual_notes",
    "saveProposal": "save_proposal",
    "savingInsuranceApplication": "saving_insurance_application",
    "getProposal": "get_proposal",
    "ProductList": "product_list",
    "generalTable": "general_table",
    "verifyProducers": "verify_producers",
    "clientSearch": "client_search",
    "printingTypes": "printing_types",
    "individualDocumentsNOdocs": "individual_documents_nodocs",
    "policy_documents": "policy_documents",
    "perfilUsuario": "perfil_usuario",
    "sbcMaximo": "sbc_maximo",
}


class ApiLifeError(Exception):
    """Error funcional llamando a API Life."""


class ApiLifeClient:
    """Interfaz del conector API Life."""

    def call(self, endpoint: str, payload: dict | None = None) -> dict:  # pragma: no cover - interface
        raise NotImplementedError

    def annuity_simulation(self, payload: dict) -> dict:
        return self.call("individualAnnuitySimulation", payload)

    def annuity_insurance_application(self, payload: dict) -> dict:
        return self.call("individualAnnuityInsuranceApplication", payload)

    def individual_documents(self, payload: dict) -> dict:
        return self.call("individualDocuments", payload)

    def validate_reinvestment(self, payload: dict) -> dict:
        return self.call("validateReinvestment", payload)

    def individual_notes(self, payload: dict) -> dict:
        return self.call("individualNotes", payload)

    def save_proposal(self, payload: dict) -> dict:
        return self.call("saveProposal", payload)

    def saving_insurance_application(self, payload: dict) -> dict:
        return self.call("savingInsuranceApplication", payload)

    def get_proposal(self, payload: dict) -> dict:
        return self.call("getProposal", payload)

    def product_list(self, payload: dict | None = None) -> dict:
        return self.call("ProductList", payload or {})

    def general_table(self, table: str) -> dict:
        return self.call("generalTable", {"table": table})

    def verify_producers(self, payload: dict) -> dict:
        return self.call("verifyProducers", payload)

    def client_search(self, documento: str) -> dict:
        return self.call("clientSearch", {"document": documento})

    def printing_types(self, payload: dict) -> dict:
        return self.call("printingTypes", payload)

    def policy_documents(self, payload: dict) -> dict:
        return self.call("policy_documents", payload)

    def perfil_usuario(self, nuuma: str) -> dict:
        return self.call("perfilUsuario", {"nuuma": nuuma})

    def sbc_maximo(self, payload: dict) -> dict:
        return self.call("sbcMaximo", payload)


class MockApiLifeClient(ApiLifeClient):
    """Cliente mock: devuelve los fixtures JSON por endpoint."""

    def call(self, endpoint: str, payload: dict | None = None) -> dict:
        name = ENDPOINT_FIXTURES.get(endpoint, endpoint)
        path = FIXTURES_DIR / f"{name}.json"
        if not path.exists():
            logger.warning("Fixture no encontrado para %s (%s)", endpoint, path)
            raise ApiLifeError(f"Mock sin fixture para endpoint '{endpoint}'")
        data: dict[str, Any] = json.loads(path.read_text(encoding="utf8"))
        response: dict[str, Any] = data.get("response", data)
        return response


class RealApiLifeClient(ApiLifeClient):
    """Cliente real sobre BaseHttpClient (stub de arch-ram-lib-django-httpclient)."""

    def __init__(self) -> None:
        self.http = BaseHttpClient(
            base_url=settings.APILIFE_BASE_URL,
            timeout=settings.APILIFE_TIMEOUT,
            username=settings.APILIFE_USERNAME,
            password=settings.APILIFE_PASSWORD,
        )

    def call(self, endpoint: str, payload: dict | None = None) -> dict:
        try:
            if payload is None:
                return dict(self.http.get(endpoint).json())
            return dict(self.http.post(endpoint, json=payload).json())
        except Exception as exc:
            logger.error("API Life %s falló: %s", endpoint, exc)
            raise ApiLifeError(str(exc)) from exc


_client: ApiLifeClient | None = None


def get_apilife_client() -> ApiLifeClient:
    """Factory: devuelve el cliente según APILIFE_MODE."""
    global _client
    if _client is None:
        _client = RealApiLifeClient() if settings.APILIFE_MODE == "real" else MockApiLifeClient()
    return _client
