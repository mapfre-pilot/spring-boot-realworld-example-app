"""Connector API Life — 16 endpoints ``TVA_API_Life_*`` + SBC máximo.

Interfaz única ``ApiLifeClient`` con dos implementaciones:

- ``MockApiLifeClient``: carga los fixtures JSON de ``fixtures/apilife/``
  (derivados de las reglas ``TVA_MOCK_*`` del volcado Appian).
- ``RealApiLifeClient``: HTTP sobre ``apps.core.httpclient.BaseHttpClient``
  (stub de arch-ram-lib-django-httpclient) con credenciales por env.

Selección por ``APILIFE_MODE=mock|real``.

El cliente real es spec-driven: ``ENDPOINT_SPECS`` transcribe cada
integración ``TVA_API_Life_*`` del dump Appian (ver
``integrations_spec.txt`` — método, path, query params, cabeceras
``X-Request-*``, timeouts). Valores de path/query/headers se extraen
("pop") del payload; el resto forma el body JSON en POST/PUT con nulls
eliminados (equivalente a ``removeNullsFromJson``). GET nunca envía body.
"""

import json
import logging
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import requests
from django.conf import settings

from apps.core.httpclient import BaseHttpClient

logger = logging.getLogger(__name__)

# Constantes TVA (constants/*.json del dump Appian)
EMPRESA_POR_DEFECTO = "0511"  # cons!TVA_CODIGOS_EMPRESA_POR_DEFECTO
CANAL_POR_DEFECTO = "500"  # cons!TVA_CODIGOS_DISTRIBUTION_CHANNEL_POR_DEFECTO
ORIGIN_CODE_PFM = "PFM"  # cons!TVA_VAL_ORIGIN_CODE_PFM
ACRONIMO_APLICACION = "TVA"  # cons!TVA_ACRONIMO_APLICACION
CHANNEL_CODE_PERSONAS = "01"  # a!defaultValue(ri!channelCode, "01")


def _idioma() -> str:
    """cons!CMP_VAL_TRADUCCION_ES (cross-app): env-overridable."""
    return getattr(settings, "APILIFE_ACCEPT_LANGUAGE", "es") or "es"


def _aplicacion() -> str:
    return getattr(settings, "APILIFE_APPLICATION_ID", ACRONIMO_APLICACION) or ACRONIMO_APLICACION


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
    """Error funcional llamando a API Life. ``code`` = código de negocio si lo hay."""

    def __init__(self, message: str, code: str | None = None) -> None:
        super().__init__(message)
        self.code = code


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

    def general_table(self, table: str, nuuma: str | None = None, aplicacion: str | None = None) -> dict:
        return self.call("generalTable", {"codigoTableGeneral": table, "nuuma": nuuma, "aplicacion": aplicacion})

    def verify_producers(self, payload: dict) -> dict:
        return self.call("verifyProducers", payload)

    def client_search(self, documento: str) -> dict:
        return self.call("clientSearch", {"identityDocumentNumber": documento})

    def printing_types(self, payload: dict) -> dict:
        return self.call("printingTypes", payload)

    def policy_documents(self, payload: dict) -> dict:
        return self.call("policy_documents", payload)

    def perfil_usuario(self, nuuma: str, clave_sesion: str | None = None) -> dict:
        return self.call("perfilUsuario", {"nuuma": nuuma, "claveSesion": clave_sesion})

    def sbc_maximo(self, payload: dict) -> dict:
        return self.call("sbcMaximo", payload)

    def gestionar_personas(self, payload: dict) -> dict:
        return self.call("gestionarPersonas", payload)


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
        if endpoint == "gestionarPersonas":
            return {"ok": True}
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


# ---------------------------------------------------------------------------
# Specs de endpoints — transcripción de integrations/*.json
#
# Fuentes de valores en query/headers:
#   "p:<key>"            → payload.pop(key)
#   "p:<key>|<default>"  → payload.pop(key) o <default> si vacío
#   "p:<k1>,<k2>|<def>"  → primer key no vacío entre k1/k2, o default
#   "const:<valor>"      → literal
#   "lang"               → settings.APILIFE_ACCEPT_LANGUAGE (cons!CMP_VAL_TRADUCCION_ES)
#   "appid"              → payload 'aplicacion' o settings.APILIFE_APPLICATION_ID
# La cabecera Host no se envía (requests la calcula).
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class EndpointSpec:
    method: str
    path: str  # plantilla con {param} resueltos desde el payload
    timeout: int = 10
    body: bool = False  # True → el resto del payload es el body JSON
    query: tuple[tuple[str, str], ...] = ()
    headers: tuple[tuple[str, str], ...] = ()
    credential: str = "apilife"  # "appinve" reservado (conectado APPINVE)


_LANG = ("Accept-Language", "lang")
_CO = ("X-Request-companyId", f"p:companyId,companyID|{EMPRESA_POR_DEFECTO}")
_CO_ISSUE = ("X-Request-issueCompanyId", f"p:companyId,companyID|{EMPRESA_POR_DEFECTO}")
_CO_REQ = ("X-Request-companyId", "p:companyId")
_CO_REQ_ISSUE = ("X-Request-issueCompanyId", "p:companyId")
_CHANNEL = ("X-Request-distributionChannel", f"p:distributionChannel|{CANAL_POR_DEFECTO}")
_CHANNEL_REQ = ("X-Request-distributionChannel", "p:distributionChannel")
_USER = ("X-Request-internalUser", "p:nuuma")
_APP = ("X-Request-applicationId", "appid")
_APP_TVA = ("X-Request-applicationId", f"const:{ACRONIMO_APLICACION}")

_STD = (_LANG, _CO, _CO_ISSUE, _USER, _APP, _CHANNEL)

ENDPOINT_SPECS: dict[str, EndpointSpec] = {
    "ProductList": EndpointSpec(
        method="GET",
        path="/apisbctaller_int-web/api/life/1.0/settings/products",
        timeout=10,
        query=(("productTypeCode", "p:productTypeCode"), ("identityDocumentNumber", "p:identityDocumentNumber")),
        headers=(_LANG, _CO, _CO_ISSUE, _USER, _CHANNEL),
    ),
    "clientSearch": EndpointSpec(
        method="POST",
        path="/apisbctaller_int-web/api/life/1.0/client/search",
        timeout=10,
        body=True,
        headers=(_LANG, _CO_REQ, _CO_REQ_ISSUE, _CHANNEL_REQ),
    ),
    "generalTable": EndpointSpec(
        method="GET",
        path="/apisbctaller_int-web/api/life/1.0/catalog/general/generalTable/{codigoTableGeneral}",
        timeout=100,
        headers=(
            _LANG,
            ("X-Request-companyId", f"const:{EMPRESA_POR_DEFECTO}"),
            ("X-Request-issueCompanyId", f"const:{EMPRESA_POR_DEFECTO}"),
            _APP,
            ("X-Request-distributionChannel", f"const:{CANAL_POR_DEFECTO}"),
            _USER,
        ),
    ),
    "getProposal": EndpointSpec(
        method="GET",
        path="/apisbcsolicitudes_int-web/api/life/1.0/individual/saving/proposal/{proposalId}",
        timeout=10,
        query=(("originCode", f"const:{ORIGIN_CODE_PFM}"),),
        headers=(_LANG, _CO, _CO_ISSUE, _APP, _CHANNEL),
    ),
    "individualAnnuityInsuranceApplication": EndpointSpec(
        method="POST",
        path="/apisbcsolicitudes_int-web/api/life/1.0/individual/annuity/insuranceApplication",
        timeout=20,
        body=True,
        headers=_STD,
    ),
    "individualAnnuitySimulation": EndpointSpec(
        method="POST",
        path="/apisbcpolizas_int-web/api/life/1.0/individual/annuity/simulation",
        timeout=20,
        body=True,
        headers=_STD,
    ),
    "individualDocuments": EndpointSpec(
        method="POST",
        path="/apisbctaller_int-web/api/life/1.0/individual/documents",
        timeout=20,
        body=True,
        headers=(*_STD, ("X-Request-operationCode", "p:operationCode")),
    ),
    "individualDocumentsNOdocs": EndpointSpec(
        method="POST",
        path="/apisbctaller_int-web/api/life/1.0/individual/documents",
        timeout=20,
        body=True,
        headers=(*_STD, ("X-Request-operationCode", "p:operationCode")),
    ),
    "individualNotes": EndpointSpec(
        method="POST",
        path="/apisbcpolizas_int-web/api/life/1.0/individual/notes",
        timeout=10,
        body=True,
        headers=(
            _LANG,
            _CO,
            _CO_ISSUE,
            _USER,
            _APP,
            ("X-Request-processId", "p:claveSesion"),
            # "distributionChannnel" (triple n) es literal en la integración Appian
            ("X-Request-distributionChannnel", f"p:distributionChannel|{CANAL_POR_DEFECTO}"),
        ),
    ),
    "perfilUsuario": EndpointSpec(
        method="GET",
        path="/apisbctaller_int-web/api/life/1.0/individual/search/{nuuma}",
        timeout=10,
        headers=(
            _LANG,
            _CO,
            _CO_ISSUE,
            _CHANNEL,
            _USER,
            _APP_TVA,
            ("X-Request-processId", "p:claveSesion"),
            ("numma", "p:nuuma"),
        ),
    ),
    "policy_documents": EndpointSpec(
        method="POST",
        path="/apisbcpolizas_int-web/api/life/1.0/individual/policy/{policyId}/documents",
        timeout=120,
        body=True,
        headers=(
            _LANG,
            _CO_REQ,
            _CO_REQ_ISSUE,
            _APP_TVA,
            _CHANNEL_REQ,
            ("X-Forwarded-For", "p:ipCliente"),
            _USER,
        ),
    ),
    "printingTypes": EndpointSpec(
        method="GET",
        path="/apisbctaller_int-web/api/life/1.0/settings/printingTypes/{commercialProductCode}",
        timeout=10,
        headers=(_LANG, _CO_REQ, _CO_REQ_ISSUE, _CHANNEL_REQ, _USER),
    ),
    "saveProposal": EndpointSpec(
        method="POST",
        path="/apisbcsolicitudes_int-web/api/life/1.0/individual/saving/proposal",
        timeout=20,
        body=True,
        headers=_STD,
    ),
    "savingInsuranceApplication": EndpointSpec(
        method="POST",
        path="/apisbcpolizas_int-web/api/life/1.0/individual/saving/insuranceApplication",
        timeout=40,
        body=True,
        headers=_STD,
    ),
    "validateReinvestment": EndpointSpec(
        method="POST",
        path="/apisbcpolizas_int-web/api/life/1.0/individual/validate/reinvestment",
        timeout=10,
        body=True,
        headers=(
            _LANG,
            _CO,
            _CO_ISSUE,
            _USER,
            _APP,
            # claveSesion & "_" & CMP_generarCodigoAleatorio()
            ("X-Request-processId", "p:claveSesion|auto"),
            _CHANNEL,
        ),
    ),
    "verifyProducers": EndpointSpec(
        method="POST",
        path="/apisbctaller_int-web/api/life/1.0/settings/verifyProducers",
        timeout=20,
        body=True,
        headers=(
            ("Accept-Language", "const:es-ES"),
            _CO_REQ,
            _CO_REQ_ISSUE,
            _APP,
            _CHANNEL_REQ,
            _USER,
        ),
    ),
    "sbcMaximo": EndpointSpec(
        method="GET",
        path="/sbccliente_be-web/api/1.0/vida/cliente/{identityDocumentNumber}/individual/ahorro/importe/maximo",
        timeout=10,
        query=(
            ("codAgrupacion", "p:codAgrupacion"),
            ("flgTomadorAportante", "p:flgTomadorAportante|S"),
            ("flgMinusvalia", "p:flgMinusvalia|N"),
        ),
        headers=(
            ("X-Request-codEntidad", f"p:companyId|{EMPRESA_POR_DEFECTO}"),
            ("X-Request-codRemitente", f"p:companyId|{EMPRESA_POR_DEFECTO}"),
            ("X-Request-codMedio", f"p:distributionChannel|{CANAL_POR_DEFECTO}"),
            ("X-Request-idAplicacion", f"const:{ACRONIMO_APLICACION}"),
            ("X-Request-codIdioma", "lang"),
        ),
    ),
    "gestionarPersonas": EndpointSpec(
        method="PUT",
        path="/personavida_be-web/api/1.0/vida/gestionarPersonas",
        timeout=20,
        body=True,
        query=(("channelCode", f"p:channelCode|{CHANNEL_CODE_PERSONAS}"),),
        headers=(("internalUser", "p:nuuma"),),
    ),
}


def _resolver_fuente(src: str, payload: dict) -> str:
    """Resuelve una fuente de spec a un valor (o "" si vacío)."""
    if src == "lang":
        return _idioma()
    if src == "appid":
        return str(payload.pop("aplicacion", None) or _aplicacion())
    if src.startswith("const:"):
        return src[6:]
    if src.startswith("p:"):
        rest = src[2:]
        keys, _, default = rest.partition("|")
        for key in keys.split(","):
            value = payload.pop(key, None)
            if value not in (None, ""):
                return str(value)
        if default == "auto":
            return uuid.uuid4().hex[:8].upper()
        return default
    return src


def _quitar_nulls(value: Any) -> Any:
    """Elimina claves None recursivamente (removeNullsFromJson)."""
    if isinstance(value, dict):
        return {k: _quitar_nulls(v) for k, v in value.items() if v is not None}
    if isinstance(value, list):
        return [_quitar_nulls(v) for v in value]
    return value


class RealApiLifeClient(ApiLifeClient):
    """Cliente real spec-driven sobre BaseHttpClient.

    Credenciales: ``APILIFE_USERNAME``/``PASSWORD`` (connected system
    "TVA API Life", usuario APPSAVI). ``credential="appinve"`` usa
    ``APILIFE_APPINVE_*`` (fallback a las principales).
    """

    def __init__(self) -> None:
        self.http = BaseHttpClient(
            base_url=settings.APILIFE_BASE_URL,
            timeout=settings.APILIFE_TIMEOUT,
            username=settings.APILIFE_USERNAME,
            password=settings.APILIFE_PASSWORD,
        )
        self._http_appinve: BaseHttpClient | None = None

    def _http_para(self, spec: EndpointSpec) -> BaseHttpClient:
        if spec.credential != "appinve":
            return self.http
        if self._http_appinve is None:
            self._http_appinve = BaseHttpClient(
                base_url=settings.APILIFE_BASE_URL,
                timeout=settings.APILIFE_TIMEOUT,
                username=getattr(settings, "APILIFE_APPINVE_USERNAME", "") or settings.APILIFE_USERNAME,
                password=getattr(settings, "APILIFE_APPINVE_PASSWORD", "") or settings.APILIFE_PASSWORD,
            )
        return self._http_appinve

    def call(self, endpoint: str, payload: dict | None = None) -> dict:
        spec = ENDPOINT_SPECS.get(endpoint)
        if spec is None:
            raise ApiLifeError(f"Endpoint desconocido '{endpoint}'", code="ENDPOINT_DESCONOCIDO")
        data = dict(payload or {})
        path = spec.path
        for marcador in list(_marcadores(path)):
            valor = data.pop(marcador, None)
            path = path.replace("{" + marcador + "}", "" if valor is None else str(valor))
        query = {k: v for k, v in ((n, _resolver_fuente(s, data)) for n, s in spec.query) if v not in (None, "")}
        headers = {k: v for k, v in ((n, _resolver_fuente(s, data)) for n, s in spec.headers) if v not in (None, "")}
        body = _quitar_nulls(data) if spec.body else None
        http = self._http_para(spec)
        url = f"{http.base_url}/{path.lstrip('/')}"
        try:
            resp = http.session.request(
                spec.method,
                url,
                params=query or None,
                headers=headers,
                json=body,
                timeout=spec.timeout,
            )
        except requests.RequestException as exc:
            logger.error("API Life %s no disponible: %s", endpoint, type(exc).__name__)
            raise ApiLifeError(f"APILIFE_NO_DISPONIBLE {endpoint}: {exc}", code="APILIFE_NO_DISPONIBLE") from exc
        if not resp.ok:
            raise self._error_http(endpoint, resp)
        if not resp.content:
            return {}
        try:
            parsed = resp.json()
        except ValueError:
            return {"raw": resp.text}
        return dict(parsed) if isinstance(parsed, dict) else {"result": parsed}

    @staticmethod
    def _error_http(endpoint: str, resp: requests.Response) -> ApiLifeError:
        """Appian coge el último ``errors[]`` del body (errorMessage CUSTOM)."""
        try:
            errores = resp.json().get("errors") or []
        except ValueError:
            errores = []
        if errores:
            ultimo = errores[-1]
            msg = ultimo.get("message") or resp.reason
            code = ultimo.get("code")
            return ApiLifeError(f"{code}: {msg}" if code else str(msg), code=str(code) if code else None)
        return ApiLifeError(f"HTTP {resp.status_code} en {endpoint}", code=str(resp.status_code))


def _marcadores(path: str) -> list[str]:
    return [p.split("}")[0] for p in path.split("{")[1:]]


_client: ApiLifeClient | None = None


def get_apilife_client() -> ApiLifeClient:
    """Factory: devuelve el cliente según APILIFE_MODE."""
    global _client
    if _client is None:
        _client = RealApiLifeClient() if settings.APILIFE_MODE == "real" else MockApiLifeClient()
    return _client


def reset_apilife_client() -> None:
    """Resetea el singleton (tests)."""
    global _client
    _client = None
