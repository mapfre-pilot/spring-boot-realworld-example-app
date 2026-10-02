"""Tests de nivel API del contrato nuevo de inicio + iniciar_sesion (§12.3/12.4)."""

import pytest

from apps.tva.models import Parametro
from apps.tva.operators.iniciar_sesion import iniciar_sesion
from apps.tva.operators.maquina_pantallas import pantalla_inicio

pytestmark = pytest.mark.django_db

BASE = "/api/tva/v1"


def _params():
    Parametro.objects.get_or_create(clave="TVA_CODIGOS_EMPRESA_ADMITIDOS", defaults={"valor": '["0511"]', "tipo": "json"})
    Parametro.objects.get_or_create(clave="TVA_CODIGOS_DISTRIBUTION_CHANNEL_ADMITIDOS", defaults={"valor": '["200","500"]', "tipo": "json"})
    Parametro.objects.get_or_create(clave="TVA_APLICACION_CERRADA", defaults={"valor": "0", "tipo": "bool"})


BODY = {
    "indFunctionMode": "VIA",
    "companyId": "0511",
    "distributionChannel": "500",
    "username": "OTORRE@mapfre.net",
    "policyHolders": [{"documentId": "00000000T"}],
    "investment": [{"commercialProductCode": "00427", "operationTypeCode": "S", "uniqueContributionAmn": 6000}],
}


def test_inicio_api_errores_webapi(api_client, auth_header):
    _params()
    r = api_client.post(f"{BASE}/inicio/ahorro/", {**BODY, "companyId": "9999"}, format="json", **auth_header)
    assert r.status_code == 400
    j = r.json()
    assert j["code"] == "02" and j["application"] == "TVA"
    assert any("companyId" in e["message"] for e in j["errors"])


def test_inicio_api_ok_estructura_sesion(api_client, auth_header):
    _params()
    r = api_client.post(f"{BASE}/inicio/ahorro/", BODY, format="json", **auth_header)
    assert r.status_code == 201, r.content
    sesion_id = r.json()["claveSesion"]
    g = api_client.get(f"{BASE}/sesiones/{sesion_id}/", **auth_header)
    estado = g.json()["estado"]
    assert estado["modoFuncionamiento"] == "VIA"
    assert estado["perfilUsuario"]["nuuma"] == "OTORRE"
    assert estado["cajas"]
    assert estado["idPantallaActual"] in (
        "CAPTURA_DATOS_SOLICITUD",
        "CAPTURA_TOMADOR1",
        "MODALIDAD_CAMPANIA",
    )
    assert "botones" in g.json()


def test_pantalla_inicio_matrix():
    assert pantalla_inicio("VIA", {"investmentOption": None}) == pantalla_inicio("VIA", {})
    assert pantalla_inicio("VIA", {"investmentOption": {"insuranceOfferInd": True}}).value == "MODALIDAD_CAMPANIA"
    assert pantalla_inicio("VIA", {"investmentOption": {}, "perfilClientesOK": True}).value == "CAPTURA_DATOS_SOLICITUD"
    assert pantalla_inicio("VIA", {"investmentOption": {}, "perfilClientesOK": False}).value == "CAPTURA_TOMADOR1"
    assert pantalla_inicio("VA", {}).value == "SEGUROS_AHORRO"
    assert (
        pantalla_inicio(
            "VA",
            {
                "perfilClientesOK": True,
                "responseProposal": {"contractingProposal": {"insurancesApplication": [{}]}},
            },
        ).value
        == "CAPTURA_DATOS_SOLICITUD"
    )
    assert pantalla_inicio("R2C", {}).value == "R2C_CAPTURA"


def test_iniciar_sesion_contrato_nuevo():
    _params()
    sesion, errores = iniciar_sesion(usuario="tester", datos=dict(BODY))
    assert errores == []
    assert sesion.modalidad == "VIA"
    assert sesion.estado["claveSesion"] == str(sesion.clave)


def test_iniciar_sesion_via_sin_productos_aviso():
    _params()
    datos = dict(BODY, username="sinproductos@mapfre.net")
    datos["investment"] = []
    sesion, _ = iniciar_sesion(usuario="tester", datos=datos)
    assert any(a["texto"] == "El servicio no ha devuelvo ningún producto de ahorro" for a in sesion.estado["avisos"])


def _conv(fecha="2028-01-17"):
    return {
        "testData": {
            "convenience": {
                "profileCode": "ME",
                "profileDesc": "Medios",
                "signatureStatus": "FI",
                "expirationDate": fecha,
            }
        }
    }


def test_inicio_via_sin_perfilado_va_a_tomador1():
    """Bug reportado: Perfilado desmarcado debe ir a Tomador 1 (no Solicitud)."""
    datos = dict(BODY)
    datos["policyHolders"] = [{}]
    sesion, errores = iniciar_sesion(usuario="tester", datos=datos)
    assert errores == []
    assert sesion.estado["perfilClientesOK"] is False
    assert sesion.estado["idPantallaActual"] == "CAPTURA_TOMADOR1"


def test_inicio_via_perfilado_va_a_solicitud():
    datos = dict(BODY)
    datos["policyHolders"] = [_conv()]
    sesion, _ = iniciar_sesion(usuario="tester", datos=datos)
    assert sesion.estado["perfilClientesOK"] is True
    assert sesion.estado["idPantallaActual"] == "CAPTURA_DATOS_SOLICITUD"
    t = sesion.estado["tomadores"][0]
    assert t["perfilCliente"]["testConvenienciaEstadoFirma"] == "FI"
    assert t["datosGestionParticipante"]["testConvenienciaVigente"] is True
    assert "testData" not in t["datosPersonales"]


def test_inicio_via_perfilado_caducado():
    datos = dict(BODY)
    datos["policyHolders"] = [_conv("2020-01-01")]
    sesion, _ = iniciar_sesion(usuario="tester", datos=datos)
    assert sesion.estado["perfilClientesOK"] is False
    assert sesion.estado["idPantallaActual"] == "CAPTURA_TOMADOR1"
