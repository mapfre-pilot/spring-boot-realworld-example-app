import pytest

from apps.tva.models import Parametro, Sesion
from apps.tva.tests.conftest import make_token

BASE = "/api/tva/v1"


@pytest.fixture(autouse=True)
def parametros(db):
    Parametro.objects.create(clave="TVA_APLICACION_CERRADA", valor="0", tipo="bool")
    Parametro.objects.create(clave="TVA_FECHA_APERTURA", valor="2000-01-01")
    Parametro.objects.create(clave="TVA_FECHA_CIERRE", valor="2999-01-01")


def _sesion(usuario="tester", modalidad="VIA", pantalla="SELECCION_PRODUCTO_AHORRO", estado=None):
    return Sesion.objects.create(usuario=usuario, modalidad=modalidad, pantalla_actual=pantalla, estado=estado or {"avisos": []})


# --- salud ---
def test_salud_sin_auth(api_client):
    r = api_client.get(f"{BASE}/salud/")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_auth_requerida(api_client):
    r = api_client.get(f"{BASE}/productos/")
    assert r.status_code in (401, 403)


# --- inicio ---
def test_inicio_ahorro(api_client, auth_header):
    r = api_client.post(f"{BASE}/inicio/ahorro/", {"documentoCliente": "00000000X", "canal": "GV"}, format="json", **auth_header)
    assert r.status_code == 201
    assert r.json()["pantallaActual"] == "SEGUROS_AHORRO"


def test_inicio_rentas(api_client, auth_header):
    r = api_client.post(f"{BASE}/inicio/rentas/", {"documentoCliente": "00000000X", "canal": "PFM"}, format="json", **auth_header)
    assert r.status_code == 201
    assert r.json()["pantallaActual"] == "R2C_CAPTURA"


def test_inicio_parametros_invalidos(api_client, auth_header):
    r = api_client.post(f"{BASE}/inicio/ahorro/", {"documentoCliente": "", "canal": "GV"}, format="json", **auth_header)
    assert r.status_code == 400


def test_inicio_app_cerrada(api_client, auth_header):
    Parametro.objects.filter(clave="TVA_APLICACION_CERRADA").update(valor="1")
    r = api_client.post(f"{BASE}/inicio/ahorro/", {"documentoCliente": "00000000X", "canal": "GV"}, format="json", **auth_header)
    assert r.status_code == 400
    assert r.json()["error"]["codigo"] == "TVA_ERROR_APLICACION_CERRADA"


# --- sesiones ---
def test_get_sesion_owner(api_client, auth_header):
    s = _sesion()
    r = api_client.get(f"{BASE}/sesiones/{s.clave}/", **auth_header)
    assert r.status_code == 200
    assert r.json()["clave"] == str(s.clave)


def test_get_sesion_otro_usuario_404(api_client):
    s = _sesion(usuario="otro")
    r = api_client.get(f"{BASE}/sesiones/{s.clave}/", HTTP_AUTHORIZATION=f"Bearer {make_token('distinto')}")
    assert r.status_code == 404


def test_get_sesion_admin(api_client, admin_header):
    s = _sesion(usuario="otro")
    r = api_client.get(f"{BASE}/sesiones/{s.clave}/", **admin_header)
    assert r.status_code == 200


def test_put_estado(api_client, auth_header):
    s = _sesion()
    r = api_client.put(f"{BASE}/sesiones/{s.clave}/estado/", {"estado": {"nuevo": 1}}, format="json", **auth_header)
    assert r.status_code == 200
    s.refresh_from_db()
    assert s.estado == {"nuevo": 1}


def test_accion_siguiente(api_client, auth_header):
    s = _sesion(estado={"avisos": [], "investmentOption": {}, "perfilClientesOK": True})
    r = api_client.post(f"{BASE}/sesiones/{s.clave}/acciones/siguiente/", {}, format="json", **auth_header)
    assert r.status_code == 200
    assert r.json()["pantallaActual"] == "CAPTURA_DATOS_SOLICITUD"


def test_accion_invalida(api_client, auth_header):
    s = _sesion()
    r = api_client.post(f"{BASE}/sesiones/{s.clave}/acciones/no-existe/", {}, format="json", **auth_header)
    assert r.status_code == 400


def test_accion_continuar_tomador(api_client, auth_header):
    s = _sesion(modalidad="VA", pantalla="CAPTURA_TOMADOR1", estado={"avisos": [], "tomadores": [{}]})
    r = api_client.post(
        f"{BASE}/sesiones/{s.clave}/acciones/continuar-tomador/",
        {"datos": {"datosPersonales": {"documento": "X", "birthDate": "1980-01-01"}}},
        format="json",
        **auth_header,
    )
    assert r.status_code == 200
    assert r.json()["pantallaActual"] == "CAPTURA_TOMADOR2"


def test_accion_guardar_solicitud(api_client, auth_header):
    s = _sesion()
    r = api_client.post(f"{BASE}/sesiones/{s.clave}/acciones/guardar-solicitud/", {"datos": {}}, format="json", **auth_header)
    assert r.status_code == 200
    assert any(a["clase"] == 4 for a in r.json()["avisos"])


# --- clientes/productos/documentos ---
def test_clientes(api_client, auth_header):
    r = api_client.get(f"{BASE}/clientes/?documento=00000000X", **auth_header)
    assert r.status_code == 200
    assert r.json()["documento"] == "00000000X"


def test_productos(api_client, auth_header):
    r = api_client.get(f"{BASE}/productos/", **auth_header)
    assert r.status_code == 200
    assert "products" in r.json()


def test_documentos(api_client, auth_header):
    s = _sesion()
    r = api_client.get(f"{BASE}/sesiones/{s.clave}/documentos/precontractual/", **auth_header)
    assert r.status_code == 200
    assert r.json()["tipo"] == "precontractual"


def test_documentos_tipo_invalido(api_client, auth_header):
    s = _sesion()
    r = api_client.get(f"{BASE}/sesiones/{s.clave}/documentos/inventado/", **auth_header)
    assert r.status_code == 400


# --- admin ---
def test_admin_parametros_no_admin(api_client, auth_header):
    r = api_client.get(f"{BASE}/admin/parametros/", **auth_header)
    assert r.status_code == 403


def test_admin_parametros(api_client, admin_header):
    r = api_client.get(f"{BASE}/admin/parametros/", **admin_header)
    assert r.status_code == 200
    assert any(p["clave"] == "TVA_APLICACION_CERRADA" for p in r.json())


def test_admin_put_parametro(api_client, admin_header):
    r = api_client.put(f"{BASE}/admin/parametros/", {"clave": "NUEVA", "valor": "v", "tipo": "str"}, format="json", **admin_header)
    assert r.status_code == 200
    assert Parametro.objects.filter(clave="NUEVA").exists()


def test_admin_apertura_cierre(api_client, admin_header):
    r = api_client.post(f"{BASE}/admin/apertura-cierre/", **admin_header)
    assert r.status_code == 200
    assert r.json()["cerrada"] is False


def test_admin_caches(api_client, admin_header):
    r = api_client.post(f"{BASE}/admin/caches/limpiar/", **admin_header)
    assert r.status_code == 200


def test_admin_trazas(api_client, admin_header):
    r = api_client.get(f"{BASE}/admin/trazas/", **admin_header)
    assert r.status_code == 200
