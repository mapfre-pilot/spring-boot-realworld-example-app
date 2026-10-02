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
    # periodicContributionAmn = 0 en la propuesta → no se prellena (evita
    # «Debe seleccionar la periodicidad»)
    assert not data["estado"]["datosOperacion"].get("aportacionPeriodica")

    # 00447 no es unit linked → la caja no tiene sección opcionesInversion
    caja_seguro = next(c for c in data["estado"]["cajas"] if c["id"] == "DATOS_DEL_SEGURO")
    ids = [s["id"] for s in caja_seguro["secciones"]]
    assert "opcionesInversion" not in ids

    # Valida con operación + garantías + domiciliaciones (sin opciones)
    estado = data["estado"]
    _accion(
        api_client,
        clave,
        "validar-seccion",
        {"caja": "DATOS_PRODUCTORES", "seccion": "productores", "datos": {"oficina": "0001", "productor": "12345"}},
        **auth_header,
    )
    _accion(
        api_client,
        clave,
        "validar-seccion",
        {
            "caja": "DATOS_DEL_SEGURO",
            "seccion": "operacion",
            "datos": {"fechaEfecto": "2026-09-29", "tipoDuracion": "ANIOS", "duracion": 10, "primaUnica": 12000},
        },
        **auth_header,
    )
    _accion(
        api_client,
        clave,
        "validar-seccion",
        {"caja": "DATOS_DEL_SEGURO", "seccion": "garantias", "datos": estado["garantias"]},
        **auth_header,
    )
    r = _accion(
        api_client,
        clave,
        "validar-seccion",
        {"caja": "DATOS_DEL_SEGURO", "seccion": "domiciliaciones", "datos": {"ibanRecibos": "ES9121000418450200051332"}},
        **auth_header,
    )
    gyv = next(b for b in r.json()["botones"] if b["id"] == "guardar-y-volver")
    assert gyv["disabled"] is False

    # Guardar y volver: en VA es el botón de avance → CAPTURA_TOMADOR1
    r = _accion(api_client, clave, "guardar-solicitud", {}, **auth_header)
    data = r.json()
    assert data["pantallaActual"] == "CAPTURA_TOMADOR1", data
    assert any(a["codigo"] == "TVA_OK_SAVE_PROPOSAL" for a in data["avisos"])
