"""Flujo VA: inicio con propuesta → seguros de ahorro → solicitud → guardar y volver."""

import pytest

from apps.tva.models import Parametro

BASE = "/api/tva/v1"


@pytest.fixture(autouse=True)
def parametros(db):
    Parametro.objects.create(clave="TVA_APLICACION_CERRADA", valor="0", tipo="bool")


BODY_INICIO_VA = {
    "indFunctionMode": "VA",
    "proposalId": "PROP-0001",
    "companyId": "0511",
    "distributionChannel": "500",
    "username": "tester@mapfre.net",
    "numTomadores": 2,
    "investment": [
        {
            "commercialProductCode": "00447",
            "operationTypeCode": "S",
            "uniqueContributionAmn": 12000,
            "periodicContributionAmn": 0,
            "contributionFrequencyCode": "A",
        }
    ],
    "policyHolders": [{"policyHolderId": 1}, {"policyHolderId": 2}],
}


def _accion(api_client, clave, accion, datos=None, **auth):
    return api_client.post(
        f"{BASE}/sesiones/{clave}/acciones/{accion}/",
        {"datos": datos} if datos is not None else {},
        format="json",
        **auth,
    )


def test_va_guardar_y_volver_avanza(api_client, auth_header):
    r = api_client.post(f"{BASE}/inicio/ahorro/", BODY_INICIO_VA, format="json", **auth_header)
    assert r.status_code == 201, r.json()
    clave = r.json()["claveSesion"]
    assert r.json()["pantallaActual"] == "SEGUROS_AHORRO"

    # Seleccionar el producto de la propuesta → solicitud con prima precargada
    r = _accion(api_client, clave, "seleccionar-modalidad", {"productCode": "00447"}, **auth_header)
    data = r.json()
    assert data["pantallaActual"] == "CAPTURA_DATOS_SOLICITUD", data
    assert data["estado"]["datosOperacion"]["primaUnica"] == 12000

    # Guardar y volver: en VA es el botón de avance → CAPTURA_TOMADOR1
    r = _accion(api_client, clave, "guardar-solicitud", {}, **auth_header)
    data = r.json()
    assert data["pantallaActual"] == "CAPTURA_TOMADOR1", data
    assert any(a["codigo"] == "TVA_OK_SAVE_PROPOSAL" for a in data["avisos"])
