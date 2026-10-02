"""Tests de los clientes reales (HTTP mockeado) y checks de configuración."""

import requests
import pytest
from django.core.checks import run_checks

from apps.tva.services.connectors.apilife import (
    ApiLifeError,
    RealApiLifeClient,
)
from apps.tva.services.connectors.misv import (
    RealMisvClient,
    arreglo_nif_pfm,
)
from apps.tva.services.connectors.perfil_usuario import (
    RealPerfilUsuarioClient,
    parsear_perfil_soap,
)
from apps.tva.services.connectors.ric import RealRicClient


def _resp(status=200, payload=None, text=None):
    r = requests.Response()
    r.status_code = status
    r._content = (text if text is not None else __import__("json").dumps(payload or {})).encode()
    r.headers["Content-Type"] = "application/json"
    return r


@pytest.fixture
def apilife(settings, mocker):
    settings.APILIFE_BASE_URL = "https://test"
    settings.APILIFE_USERNAME = "u"
    settings.APILIFE_PASSWORD = "p"
    settings.APILIFE_APPLICATION_ID = "TVA"
    settings.APILIFE_ACCEPT_LANGUAGE = "es"
    c = RealApiLifeClient()
    req = mocker.patch.object(c.http.session, "request", return_value=_resp(payload={"ok": 1}))
    return c, req


def test_product_list_get(apilife):
    c, req = apilife
    c.product_list(company_id="0511", product_type_code="VIDA", nuuma="N123")
    kw = req.call_args.kwargs
    assert req.call_args.args[0] == "GET"
    assert kw["params"]["productTypeCode"] == "VIDA"
    assert kw["headers"]["X-Request-internalUser"] == "N123"
    assert kw["headers"]["Accept-Language"] == "es"
    assert kw["json"] is None


def test_get_proposal(apilife):
    c, req = apilife
    c.call("getProposal", {"proposalId": "P1", "distributionChannel": "700"})
    kw = req.call_args.kwargs
    assert kw["params"]["originCode"] == "PFM"
    assert "proposal/P1" in req.call_args.args[1]
    assert kw["headers"]["X-Request-distributionChannel"] == "700"
    assert kw["headers"]["X-Request-companyId"] == "0511"


def test_sbc_maximo(apilife):
    c, req = apilife
    c.sbc_maximo({"identityDocumentNumber": "00000000T"})
    kw = req.call_args.kwargs
    assert "/00000000T/individual/ahorro/importe/maximo" in req.call_args.args[1]
    assert kw["params"]["flgTomadorAportante"] == "S"
    assert kw["params"]["flgMinusvalia"] == "N"
    assert kw["headers"]["X-Request-codEntidad"] == "0511"
    assert kw["headers"]["X-Request-codIdioma"] == "es"
    assert kw["headers"]["X-Request-idAplicacion"] == "TVA"


def test_save_proposal_body_sin_nulls(apilife):
    c, req = apilife
    c.save_proposal({"request": {"a": 1, "b": None, "c": {"d": None, "e": "x"}}, "nuuma": "N1"})
    kw = req.call_args.kwargs
    assert req.call_args.args[0] == "POST"
    body = kw["json"]
    assert body["request"]["a"] == 1
    assert "b" not in body["request"]
    assert "d" not in body["request"]["c"]
    assert "nuuma" not in body  # consumido como header


def test_policy_documents_xff(apilife):
    c, req = apilife
    c.call("policy_documents", {"policyId": "P9", "ipCliente": "10.0.0.1", "companyId": "0511", "nuuma": "N1"})
    kw = req.call_args.kwargs
    assert kw["headers"]["X-Forwarded-For"] == "10.0.0.1"
    assert "/policy/P9/documents" in req.call_args.args[1]


def test_gestionar_personas_put(apilife):
    c, req = apilife
    c.gestionar_personas({"nuuma": "N1", "request": [{"a": 1}]})
    kw = req.call_args.kwargs
    assert req.call_args.args[0] == "PUT"
    assert "gestionarPersonas" in req.call_args.args[1]
    assert kw["params"]["channelCode"] == "01"
    assert kw["headers"]["internalUser"] == "N1"


def test_error_ultimo_errors(apilife, mocker):
    c, req = apilife
    req.return_value = _resp(
        status=400,
        payload={"errors": [{"code": "E1", "message": "primero"}, {"code": "E2", "message": "ultimo"}]},
    )
    with pytest.raises(ApiLifeError) as err:
        c.call("getProposal", {"proposalId": "P"})
    assert "ultimo" in str(err.value)
    assert err.value.code == "E2"


def test_error_red(apilife, mocker):
    c, req = apilife
    req.side_effect = requests.ConnectionError("boom")
    with pytest.raises(ApiLifeError) as err:
        c.call("ProductList", {})
    assert err.value.code == "APILIFE_NO_DISPONIBLE"


def test_arreglo_nif():
    assert arreglo_nif_pfm("012345678X") == "2345678X"  # right(NIF, 8)
    assert arreglo_nif_pfm("12345678Z") == "12345678Z"
    assert arreglo_nif_pfm("") == ""


def test_misv_params(settings, mocker):
    settings.MISV_BASE_URL = "https://misv"
    settings.MISV_USERNAME = "u"
    settings.MISV_PASSWORD = "p"
    c = RealMisvClient()
    get = mocker.patch.object(c.http.session, "get", return_value=_resp(payload={"perfilClientesOK": True}))
    c.perfilar({"nuuma": "N1", "nif": "012345678X"})
    params = get.call_args.kwargs["params"]
    assert params == {"USUARIO": "N1", "APLICACION": "VIDA", "NIF": "2345678X", "TIPO_PERSONA": "F"}
    assert "RSPerfiladoClienteV2" in get.call_args.args[0]


SOAP_XML = """<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body><mav:ConsultarPerfilUsuarioResponse xmlns:mav="http://x">
<MSSConsultarPerfilUsuario><cdOficina>9275</cdOficina><dirReg>99</dirReg>
<claveProductor>P1</claveProductor><dgt>99</dgt>
<funcionalidades><funcionalidades>4016</funcionalidades><funcionalidades>4017</funcionalidades></funcionalidades>
</MSSConsultarPerfilUsuario></mav:ConsultarPerfilUsuarioResponse></soapenv:Body></soapenv:Envelope>"""


def test_soap_parse():
    d = parsear_perfil_soap(SOAP_XML)
    assert d["codOficina"] == "9275" and d["funcionalidades"] == ["4016", "4017"]


def test_soap_envelope_wsse(settings, mocker):
    settings.SOA_BASE_URL = "https://soa"
    settings.SOA_USERNAME = "APPRIMO"
    settings.SOA_PASSWORD = "secreto"
    c = RealPerfilUsuarioClient()
    post = mocker.patch("apps.tva.services.connectors.perfil_usuario.requests.post", return_value=_resp(text=SOAP_XML))
    perfil = c.obtener_perfil("tester@mapfre.net")
    body = post.call_args.kwargs["data"].decode()
    assert "<wsse:Username>APPRIMO</wsse:Username>" in body
    assert "<wsse:Password>secreto</wsse:Password>" in body
    assert "<nuuma>TESTER</nuuma>" in body
    assert perfil["codOficina"] == "9275" and perfil["nuuma"] == "TESTER"


def test_checks_real_sin_vars(settings):
    settings.APILIFE_MODE = "real"
    settings.APILIFE_BASE_URL = ""
    settings.APILIFE_USERNAME = ""
    settings.APILIFE_PASSWORD = ""
    errs = run_checks(tags=["compatibility"])
    assert any(e.id == "tva.E001" for e in errs)


def test_checks_modo_invalido(settings):
    settings.RIC_MODE = "banana"
    errs = run_checks(tags=["compatibility"])
    assert any(e.id == "tva.E004" for e in errs)


def test_checks_mock_ok(settings):
    settings.APILIFE_MODE = "mock"
    settings.MISV_MODE = "mock"
    settings.RIC_MODE = "mock"
    settings.PERFIL_USUARIO_MODE = "mock"
    settings.APPIAN_EMBED_MODE = "mock"
    errores_tva = [e for e in run_checks(tags=["compatibility"]) if e.id.startswith("tva.")]
    assert errores_tva == []


def test_salud_integraciones(api_client):
    resp = api_client.get("/api/tva/v1/salud/")
    assert resp.status_code == 200
    integr = resp.json()["integraciones"]
    assert integr == {
        "apilife": "mock",
        "misv": "mock",
        "perfilUsuario": "mock",
        "ric": "mock",
        "appianEmbed": "mock",
    }


def test_smoke_mock():
    from django.core.management import call_command

    call_command("smoke_integraciones")  # debe no lanzar


def test_ric_real_params(settings, mocker):
    settings.RIC_BASE_URL = "https://ric"
    settings.RIC_PATH = "personas"
    c = RealRicClient()
    get = mocker.patch.object(c.http.session, "get", return_value=_resp(payload={"encontrado": True}))
    c.buscar_cliente("00000000T")
    assert get.call_args.kwargs["params"] == {"documento": "00000000T"}
