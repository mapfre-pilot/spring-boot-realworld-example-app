"""Configuración de conectores editable desde Administración y arranque automático."""

import pytest
from django.core.management import call_command
from django.test import override_settings

from apps.tva.bootstrap import preparar_base_datos
from apps.tva.models import ConfiguracionIntegracion, Parametro
from apps.tva.services import configuracion
from apps.tva.services.connectors import ric

URL = "/api/tva/v1/admin/configuracion/"


@override_settings(RIC_BASE_URL="https://entorno")
def test_obtener_prioriza_bd_sobre_entorno(db):
    assert configuracion.obtener("RIC_BASE_URL") == "https://entorno"
    configuracion.guardar({"RIC_BASE_URL": "https://bd", "RIC_TIMEOUT": "5"}, [], usuario="admin")
    assert configuracion.obtener("RIC_BASE_URL") == "https://bd"
    assert configuracion.obtener("RIC_TIMEOUT") == 5
    configuracion.guardar({}, ["RIC_BASE_URL"], usuario="admin")
    assert configuracion.obtener("RIC_BASE_URL") == "https://entorno"


def test_secreto_cifrado_y_vacio_conserva(db):
    configuracion.guardar({"RIC_PASSWORD": "s3cr3t"}, [], usuario="admin")
    fila = ConfiguracionIntegracion.objects.get(nombre="RIC_PASSWORD")
    assert fila.secreto and "s3cr3t" not in fila.valor
    configuracion.guardar({"RIC_PASSWORD": ""}, [], usuario="admin")
    assert configuracion.obtener("RIC_PASSWORD") == "s3cr3t"


@pytest.mark.parametrize(
    "valores",
    [{"RIC_MODE": "otro"}, {"RIC_TIMEOUT": "x"}, {"NO_EXISTE": "1"}],
)
def test_guardar_valida(db, valores):
    with pytest.raises(configuracion.ConfiguracionError):
        configuracion.guardar(valores, [], usuario="admin")


def test_cliente_se_recrea_al_cambiar_modo(db):
    ric.reset_ric_client()
    assert isinstance(ric.get_ric_client(), ric.MockRicClient)
    configuracion.guardar({"RIC_MODE": "real", "RIC_BASE_URL": "https://ric"}, [], usuario="admin")
    assert isinstance(ric.get_ric_client(), ric.RealRicClient)
    configuracion.guardar({}, ["RIC_MODE", "RIC_BASE_URL"], usuario="admin")
    assert isinstance(ric.get_ric_client(), ric.MockRicClient)


def test_api_configuracion_no_expone_secretos(api_client, admin_header):
    r = api_client.put(URL, {"valores": {"APPIAN_EMBED_API_KEY": "clave", "APPIAN_EMBED_MODE": "real"}}, format="json", **admin_header)
    assert r.status_code == 200
    assert "clave" not in r.content.decode()
    campo = next(c for c in r.json() if c["nombre"] == "APPIAN_EMBED_API_KEY")
    assert campo == {**campo, "valor": None, "configurado": True, "origen": "bd", "tipo": "secreto"}
    assert api_client.get("/api/tva/v1/salud/").json()["integraciones"]["appianEmbed"] == "real"


def test_api_configuracion_requiere_admin_y_valida(api_client, auth_header, admin_header):
    assert api_client.get(URL, **auth_header).status_code == 403
    r = api_client.put(URL, {"valores": {"MISV_MODE": "x"}}, format="json", **admin_header)
    assert r.status_code == 400
    assert r.json()["error"]["codigo"] == "TVA_ERROR_VALIDACION"


def test_api_probar(api_client, admin_header):
    r = api_client.post(f"{URL}probar/", {"grupo": "apilife"}, format="json", **admin_header)
    assert r.json() == {"ok": True, "salida": "apilife  mode=mock\nOK  apilife\n"}
    configuracion.guardar({"PERFIL_USUARIO_MODE": "real"}, [], usuario="admin")
    with override_settings(SOA_BASE_URL="http://127.0.0.1:9", SOA_TIMEOUT=1):
        r = api_client.post(f"{URL}probar/", {"grupo": "perfil-usuario"}, format="json", **admin_header)
    assert r.json()["ok"] is False
    assert api_client.post(f"{URL}probar/", {"grupo": "x"}, format="json", **admin_header).status_code == 400


def test_cargar_parametros_solo_nuevos_conserva_valores(db):
    call_command("cargar_parametros")
    Parametro.objects.filter(clave="TVA_APLICACION_CERRADA").update(valor="1")
    call_command("cargar_parametros", "--solo-nuevos")
    assert Parametro.objects.get(clave="TVA_APLICACION_CERRADA").valor == "1"


@pytest.mark.django_db(transaction=True)
def test_preparar_base_datos_carga_parametros():
    Parametro.objects.all().delete()
    preparar_base_datos()
    assert Parametro.objects.filter(clave="TVA_APLICACION_CERRADA").exists()
