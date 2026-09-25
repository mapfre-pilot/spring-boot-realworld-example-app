"""Tests de los pop-ups Appian Embedded (connector, operador y vistas)."""

from unittest.mock import MagicMock, patch

import pytest
import requests

from apps.tva.models import Sesion
from apps.tva.operators.popups import completar_popup, construir_body
from apps.tva.services.connectors.appian_embed import AppianEmbedError, RealAppianEmbedClient
from apps.tva.tests.conftest import make_token

BASE = "/api/tva/v1"

DP = {"nombre": "Ana", "primerApellido": "Ruiz", "segundoApellido": "Sanz", "fechaNacimiento": "1980-01-01", "documentId": "12345678Z"}
MEDIOS = [{"tipo": "MOVIL", "prefijo": "+34", "numero": "600000000"}, {"tipo": "EMAIL", "contactMethodValue": "a@b.c"}]


def _estado(client_id="", doc="12345678Z"):
    dp = {**DP, "documentId": doc}
    return {
        "avisos": [],
        "perfilUsuario": {"nuuma": "GGALV10"},
        "tomadores": [
            {
                "datosPersonales": dp,
                "mediosContacto": MEDIOS,
                "datosGestionParticipante": {"datosRIC": {"clientId": client_id}},
                "perfilCliente": {},
            }
        ],
    }


class _User:
    sub = "GGALV10"
    roles: list = []


def _sesion(client_id="", doc="12345678Z"):
    return Sesion.objects.create(usuario="tester", modalidad="VIA", pantalla_actual="CAPTURA_TOMADOR1", estado=_estado(client_id, doc))


# --- connector real ---


def _cliente_real():
    c = RealAppianEmbedClient()
    c.session = MagicMock()
    return c


def test_real_ok():
    c = _cliente_real()
    c.session.post.return_value = MagicMock(ok=True, json=lambda: {"taskId": "t-1", "taskUrl": "u"})
    assert c.lanzar("rgpd", {}) == {"taskId": "t-1", "taskUrl": "u"}
    assert "Appian-API-Key" in c.session.post.call_args.kwargs["headers"]


def test_real_401_origen_invalido():
    c = _cliente_real()
    c.session.post.return_value = MagicMock(
        ok=False,
        status_code=401,
        json=lambda: {"code": "3", "message": "Origen no válido", "errors": [{"code": "1", "message": "El origen no es válido"}]},
    )
    with pytest.raises(AppianEmbedError) as e:
        c.lanzar("dni", {})
    assert e.value.status == 401
    assert e.value.codigo == "3"
    assert e.value.errores[0]["message"] == "El origen no es válido"


def test_real_500_parametros():
    c = _cliente_real()
    c.session.post.return_value = MagicMock(
        ok=False,
        status_code=500,
        json=lambda: {"code": "3", "message": "Parámetros no válidos", "errors": [{"code": "1", "message": "campo x"}]},
    )
    with pytest.raises(AppianEmbedError) as e:
        c.lanzar("test-conveniencia", {})
    assert e.value.status == 500
    assert e.value.mensaje == "Parámetros no válidos"


def test_real_sin_conexion():
    c = _cliente_real()
    c.session.post.side_effect = requests.ConnectionError("boom")
    with pytest.raises(AppianEmbedError) as e:
        c.lanzar("rgpd", {})
    assert e.value.status == 0
    assert e.value.codigo == "APPIAN_NO_DISPONIBLE"


# --- construir_body ---


def test_body_rgpd_pot(db):
    b = construir_body(_sesion(), "rgpd", 0, _User())
    assert b["proceso"] == "RGPD-POT"
    assert b["documentoIdentidad"] == "12345678Z"
    assert b["tipoDocumento"] == "NIF"
    assert b["usuarioAppian"].endswith("@mapfre.net")
    assert b["email"] == "a@b.c" and b["telefono"] == "600000000"


def test_body_rgpd_cli(db):
    b = construir_body(_sesion(client_id="99"), "rgpd", 0, _User())
    assert b["proceso"] == "RGPD-CLI" and b["clienteID"] == "99"


def test_body_dni_nie(db):
    b = construir_body(_sesion(client_id="99", doc="X1234567L"), "dni", 0, _User())
    assert b["numeroDNINIE"] == "X1234567L"
    assert b["esCliente"] == "true" and b["idRic"] == "99"
    assert b["tipoEnvio"] == "EMAIL"


def test_body_test(db):
    b = construir_body(_sesion(), "test-conveniencia", 0, _User())
    assert b["NIF"] == "12345678Z" and b["tipoTest"] == "TC" and b["aplicacion"] == "VIDA"
    assert b["telefono"] == "+34600000000"


def test_body_errores(db):
    with pytest.raises(ValueError, match="desconocido"):
        construir_body(_sesion(), "nope", 0, _User())
    with pytest.raises(ValueError, match="no existe"):
        construir_body(_sesion(), "rgpd", 5, _User())
    s = _sesion()
    s.estado["tomadores"][0]["datosPersonales"] = {"documentId": "1"}
    with pytest.raises(ValueError, match="Faltan datos"):
        construir_body(s, "rgpd", 0, _User())


# --- completar ---


@pytest.mark.parametrize(
    ("popup", "flag"),
    [("rgpd", "consentimientoProteccionDatos"), ("dni", "documentoIdDigitalizado"), ("test-conveniencia", "testConvenienciaVigente")],
)
def test_completar_submit_flags(db, popup, flag):
    s = _sesion()
    res = completar_popup(s, popup, 0, "t-1", "SUBMIT")
    s.refresh_from_db()
    assert s.estado["tomadores"][0]["datosGestionParticipante"][flag] is True
    assert res["estado"]["tomadores"][0]["datosGestionParticipante"][flag] is True


def test_completar_submit_test_firma(db):
    s = _sesion()
    completar_popup(s, "test-conveniencia", 0, "t-1", "SUBMIT")
    s.refresh_from_db()
    assert s.estado["tomadores"][0]["perfilCliente"]["testConveniencia"]["estado"] == "FIRMADO"


def test_completar_error_aviso(db):
    s = _sesion()
    completar_popup(s, "rgpd", 0, "t-1", "ERROR")
    s.refresh_from_db()
    assert any(a["codigo"] == "TVA_ERROR_POPUP_RGPD" for a in s.estado["avisos"])


# --- vistas ---


def test_lanzar_mock_200(db, api_client, auth_header):
    s = _sesion()
    r = api_client.post(f"{BASE}/sesiones/{s.clave}/popups/rgpd/lanzar/", {}, format="json", **auth_header)
    assert r.status_code == 200
    assert r.json()["taskId"].startswith("MOCK-rgpd-") and r.json()["modo"] == "mock"


def test_lanzar_popup_desconocido_400(db, api_client, auth_header):
    s = _sesion()
    r = api_client.post(f"{BASE}/sesiones/{s.clave}/popups/nope/lanzar/", {}, format="json", **auth_header)
    assert r.status_code == 400


def test_lanzar_502_sin_conexion(db, api_client, auth_header):
    s = _sesion()
    with patch("apps.tva.operators.popups.get_appian_embed_client") as m:
        m.return_value.lanzar.side_effect = AppianEmbedError(0, "APPIAN_NO_DISPONIBLE", "Appian no disponible")
        r = api_client.post(f"{BASE}/sesiones/{s.clave}/popups/rgpd/lanzar/", {}, format="json", **auth_header)
    assert r.status_code == 502


def test_completar_view_submit(db, api_client, auth_header):
    s = _sesion()
    r = api_client.post(
        f"{BASE}/sesiones/{s.clave}/popups/dni/completar/",
        {"idxTomador": 0, "taskId": "t", "resultado": "SUBMIT"},
        format="json",
        **auth_header,
    )
    assert r.status_code == 200
    assert r.json()["estado"]["tomadores"][0]["datosGestionParticipante"]["documentoIdDigitalizado"] is True


def test_popup_sesion_ajena_404(db, api_client):
    s = _sesion()
    r = api_client.post(
        f"{BASE}/sesiones/{s.clave}/popups/rgpd/lanzar/",
        {},
        format="json",
        HTTP_AUTHORIZATION=f"Bearer {make_token('otro')}",
    )
    assert r.status_code == 404
