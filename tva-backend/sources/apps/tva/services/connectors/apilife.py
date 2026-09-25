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

    def product_list(
        self,
        company_id: str | None = None,
        product_type_code: str | None = None,
        nuuma: str | None = None,
        distribution_channel: str | None = None,
    ) -> dict:
        return self.call(
            "ProductList",
            {
                "companyId": company_id,
                "productTypeCode": product_type_code,
                "nuuma": nuuma,
                "distributionChannel": distribution_channel,
            },
        )

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


# Catálogo DEV de productos de ahorro — 21 productos, ordenado por desc.
# ``commercialProductCode`` a 5 dígitos; ``unitLinkedInd`` = UL.
_PRODUCTOS_DEV: list[tuple[int, str, bool]] = [
    (369, "SIALP Finance Europe", False),
    (427, "PIAS ELECCION", True),
    (444, "MULTIFONDOS ESTRATEGIA", True),
    (447, "Dividendo Vida II", False),
    (451, "PIAS AHORRO INVERSION", True),
    (457, "PPA MAPFRE JUBILACION", False),
    (459, "MULTIFONDOS OPEN", True),
    (479, "CLON PIAS ELECCION", True),
    (505, "DIVIDENDO EUROPA", False),
    (515, "RENTA DIVIDENDO EUROPA", False),
    (521, "PROGRAMA HORIZONTE INVERSIÓN", True),
    (526, "MULTIFONDOS COMPROMISO ESG", True),
    (527, "ACTIVO MULTIFONDOS II", True),
    (528, "PIAS HORIZONTE INVERSION", True),
    (534, "MILLÓN VIDA", False),
    (560, "DIVIDENDO AMERICA", False),
    (573, "MILLÓN VIDA PREMIUM", False),
    (584, "PIAS VALOR 6M", False),
    (587, "PENTAPLAN SIALP", False),
    (869, "PLAN PERIODICO 6M", False),
    (893, "GARANTÍA MEMORIA", False),
]


_GARANTIA_FC = {"codigo": "FC", "descripcion": "Fallecimiento por cualquier causa", "obligatoria": True, "seleccionada": True}
_GARANTIA_FA = {"codigo": "FA", "descripcion": "Fallecimiento por accidente", "obligatoria": False, "seleccionada": False}
_OPCIONES_427 = [
    {"investmentPreferenceCode": "ES0112835006", "descripcion": "MAPFRE Fondtesoro", "seleccionada": False},
    {"investmentPreferenceCode": "ES0112835007", "descripcion": "MAPFRE Renta Fija", "seleccionada": False},
    {"investmentPreferenceCode": "CESTA LIBRE", "descripcion": "Cesta libre", "seleccionada": False},
]
_OPCIONES_UL = [
    {"investmentPreferenceCode": "ES0112835006", "descripcion": "MAPFRE Fondtesoro", "seleccionada": False},
    {"investmentPreferenceCode": "ES0112835007", "descripcion": "MAPFRE Renta Fija", "seleccionada": False},
]


def _catalogo_dev() -> list[dict]:
    """Catálogo DEV: producto + garantías, periodicidades, primas y opciones UL."""
    productos = []
    for code, desc, ul in sorted(_PRODUCTOS_DEV, key=lambda p: p[1]):
        productos.append(
            {
                "code": f"{code:05d}",
                "commercialProductCode": f"{code:05d}",
                "commercialProductDesc": desc,
                "unitLinkedInd": ul,
                "garantias": [dict(_GARANTIA_FC), dict(_GARANTIA_FA)],
                "periodicidades": ["M", "T", "S", "A"] if ul else ["A"],
                "primaMinima": 600,
                "primaMaxima": 1_000_000,
                "opcionesInversion": [dict(o) for o in (_OPCIONES_427 if code == 427 else _OPCIONES_UL)] if ul else [],
                "requiereAsegurado": False,
            }
        )
    return productos


class MockApiLifeClient(ApiLifeClient):
    """Cliente mock: devuelve los fixtures JSON por endpoint."""

    def call(self, endpoint: str, payload: dict | None = None) -> dict:
        if endpoint == "ProductList":
            # nuuma == "SINPRODUCTOS" permite probar el caso vacío.
            nuuma = (payload or {}).get("nuuma") or ""
            return {"products": [] if nuuma == "SINPRODUCTOS" else _catalogo_dev()}
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
