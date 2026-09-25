"""Connector perfil de usuario — TVA_WSDL_IGestionarPerfilUsuario (SOAP SOA7).

Real: POST SOAP a ``SOA_BASE_URL + MAVISA_910Usuario_SOAMEDWeb/sca/
MAVISA_910Usuario_WSDL`` con WSSE UsernameToken (usuario APPRIMO, password
por env, Nonce aleatorio base64 y Created ISO-8601 UTC) — equivalente a las
reglas CMP_crearNonce / CMP_fechaHoraISO8601 del dump Appian. La respuesta
XML se parsea al mismo dict que devuelve el mock (codOficina, dirReg,
funcionalidades, claveProductor, dgt), igual que hacen
``TVA_ObtenerPerfilUsuario`` / ``TVA_ObtenerFuncionalidades``.
"""

import base64
import json
import logging
import os
import xml.etree.ElementTree as ET
from datetime import UTC, datetime
from pathlib import Path

import requests
from django.conf import settings

logger = logging.getLogger(__name__)
FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "fixtures" / "apilife"

SOAP_PATH = "MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL"

_SOAP_TEMPLATE = """<soapenv:Envelope xmlns:mav="http://MAVISA_910Usuario_SOAMED/com/mapfre/soa/vida/usuar/smed/MAVISA_910Usuario_SOAMED" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Header>
<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
<wsse:UsernameToken wsu:Id="UsernameToken-{token_id}">
<wsse:Username>{username}</wsse:Username>
<wsse:Password>{password}</wsse:Password>
<wsse:Nonce>{nonce}</wsse:Nonce>
<wsu:Created>{created}</wsu:Created>
</wsse:UsernameToken>
</wsse:Security>
</soapenv:Header>
   <soapenv:Body>
      <mav:ConsultarPerfilUsuario>
         <MSEConsultarPerfilUsuario>
            <nuuma>{nuuma}</nuuma>
         </MSEConsultarPerfilUsuario>
      </mav:ConsultarPerfilUsuario>
   </soapenv:Body>
</soapenv:Envelope>"""


class PerfilUsuarioError(Exception):
    """Error llamando al servicio de perfil de usuario."""


def _localname(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def parsear_perfil_soap(xml_text: str) -> dict:
    """Parsea la respuesta SOAP al dict del mock (sin namespaces).

    Replica ``TVA_ObtenerPerfilUsuario`` (extract de cdOficina/dirReg/
    claveProductor/dgt) y ``TVA_ObtenerFuncionalidades``
    (Envelope.Body.ConsultarPerfilUsuarioResponse.MSSConsultarPerfilUsuario
    .funcionalidades.funcionalidades).
    """
    try:
        raiz = ET.fromstring(xml_text)
    except ET.ParseError as exc:
        raise PerfilUsuarioError(f"Respuesta SOAP inválida: {exc}") from exc

    def texto(nombre: str) -> str:
        for el in raiz.iter():
            if _localname(el.tag) == nombre and el.text:
                return el.text.strip()
        return ""

    funcionalidades = [el.text.strip() for el in raiz.iter() if _localname(el.tag) == "funcionalidades" and el.text and el.text.strip()]
    return {
        "codOficina": texto("cdOficina"),
        "dirReg": texto("dirReg"),
        "funcionalidades": funcionalidades,
        "claveProductor": texto("claveProductor"),
        "dgt": texto("dgt"),
        "conPerfil": True,
    }


def _envelope(nuuma: str) -> str:
    return _SOAP_TEMPLATE.format(
        token_id=os.urandom(16).hex().upper(),
        username=settings.SOA_USERNAME,
        password=settings.SOA_PASSWORD,
        nonce=base64.b64encode(os.urandom(16)).decode("ascii"),
        created=datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
        nuuma=nuuma,
    )


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
        self.timeout = getattr(settings, "SOA_TIMEOUT", 10)
        self.url = f"{settings.SOA_BASE_URL.rstrip('/')}/{SOAP_PATH}"

    def obtener_perfil(self, usuario: str) -> dict:
        nuuma = usuario.split("@")[0].upper() if "@" in usuario else usuario
        envelope = _envelope(nuuma)
        try:
            resp = requests.post(  # noqa: S113 — timeout fijado por settings
                self.url,
                data=envelope.encode("utf8"),
                headers={"Content-Type": "text/xml"},
                timeout=self.timeout,
            )
        except requests.RequestException as exc:
            logger.error("Perfil usuario SOA no disponible: %s", type(exc).__name__)
            raise PerfilUsuarioError(f"SOA_NO_DISPONIBLE: {exc}") from exc
        if not resp.ok:
            raise PerfilUsuarioError(f"HTTP {resp.status_code} en perfil de usuario")
        perfil = parsear_perfil_soap(resp.text)
        perfil.update({"usuario": usuario, "nuuma": nuuma})
        return perfil


_client: PerfilUsuarioClient | None = None


def get_perfil_usuario_client() -> PerfilUsuarioClient:
    global _client
    if _client is None:
        _client = RealPerfilUsuarioClient() if settings.PERFIL_USUARIO_MODE == "real" else MockPerfilUsuarioClient()
    return _client


def reset_perfil_usuario_client() -> None:
    global _client
    _client = None
