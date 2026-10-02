"""Flujo E2E R2C: captura → precios → selección → recalcular → contratar → firma."""

import pytest

from apps.tva.models import Parametro, Sesion

BASE = "/api/tva/v1"


@pytest.fixture(autouse=True)
def parametros(db):
    Parametro.objects.create(clave="TVA_APLICACION_CERRADA", valor="0", tipo="bool")


BODY_INICIO = {
    "indFunctionMode": "R2C",
    "companyId": "0511",
    "distributionChannel": "500",
    "username": "tester@mapfre.net",
    "policyHolders": [
        {"documentId": "12345678Z", "fechaNacimiento": "1960-01-15", "participationPerc": 60},
        {"documentId": "87654321X", "fechaNacimiento": "1965-05-20", "participationPerc": 40},
    ],
}


def _accion(api_client, clave, accion, datos=None, **auth):
    return api_client.post(
        f"{BASE}/sesiones/{clave}/acciones/{accion}/",
        {"datos": datos} if datos is not None else {},
        format="json",
        **auth,
    )


def test_flujo_r2c_completo(api_client, auth_header):
    r = api_client.post(f"{BASE}/inicio/rentas/", BODY_INICIO, format="json", **auth_header)
    assert r.status_code == 201, r.json()
    clave = r.json()["claveSesion"]
    assert r.json()["pantallaActual"] == "R2C_CAPTURA"

    # validar-seccion de la captura (rentas + 2 tomadores)
    r = _accion(
        api_client,
        clave,
        "validar-seccion",
        {
            "caja": "R2C_CAPTURA",
            "seccion": "captura",
            "datos": {
                "rentas": {"importeTotalPrima": 50000, "periodicidadRenta": "ANUAL"},
                "tomadores": [
                    {"documentId": "12345678Z", "fechaNacimiento": "1960-01-15", "participationPerc": 60},
                    {"documentId": "87654321X", "fechaNacimiento": "1965-05-20", "participationPerc": 40},
                ],
            },
        },
        **auth_header,
    )
    assert r.status_code == 200, r.json()

    # siguiente → simulación y precios
    r = _accion(api_client, clave, "siguiente", **auth_header)
    data = r.json()
    assert data["pantallaActual"] == "R2C_PRECIOS", data
    rentas = data["estado"]["rentas"]
    assert len(rentas["simulaciones"]) == 2
    assert rentas["idxSimulacionSeleccionada"] is None

    # seleccionar opción 50%
    r = _accion(api_client, clave, "actualizar-rentas", {"idxSimulacionSeleccionada": 0}, **auth_header)
    data = r.json()
    rentas = data["estado"]["rentas"]
    assert rentas["idxSimulacionSeleccionada"] == 0
    assert rentas["rentaObjetivo"] == pytest.approx(1415.89, abs=0.01)
    assert rentas["recalcular"] is False

    # renta objetivo manual → recalcular activo
    r = _accion(api_client, clave, "actualizar-rentas", {"rentaObjetivo": 1200}, **auth_header)
    data = r.json()
    assert data["estado"]["rentas"]["recalcular"] is True
    botones = {b["id"]: b for b in data["botones"]}
    assert botones["recalcular"]["disabled"] is False
    assert botones["contratar"]["disabled"] is True

    # recalcular → prima se actualiza, recalcular desactiva
    r = _accion(api_client, clave, "recalcular-rentas", **auth_header)
    data = r.json()
    rentas = data["estado"]["rentas"]
    assert rentas["recalcular"] is False
    assert rentas["importeTotalPrima"] == pytest.approx(1200 / 0.0283178, rel=0.01)
    botones = {b["id"]: b for b in data["botones"]}
    assert botones["contratar"]["disabled"] is False

    # contratar → resumen
    r = _accion(api_client, clave, "contratar", **auth_header)
    data = r.json()
    assert data["pantallaActual"] == "RESUMEN_CONTRATACION", data

    # firma → resultado firma → fin
    r = _accion(api_client, clave, "firmar", {"tipoFirma": "DIGITAL"}, **auth_header)
    assert r.json()["pantallaActual"] == "RESULTADO_FIRMA"
    r = _accion(api_client, clave, "siguiente", **auth_header)
    assert r.json()["pantallaActual"] == "FIN"


def test_actualizar_rentas_fuera_de_precios(api_client, auth_header, db):
    s = Sesion.objects.create(usuario="tester", modalidad="R2C", pantalla_actual="R2C_CAPTURA", estado={"avisos": []})
    r = _accion(api_client, s.clave, "actualizar-rentas", {"idxSimulacionSeleccionada": 0}, **auth_header)
    assert r.status_code == 200
    assert any(a["tipo"] == "ERROR" for a in r.json()["avisos"])


def test_contratar_sin_simulacion(api_client, auth_header, db):
    s = Sesion.objects.create(
        usuario="tester",
        modalidad="R2C",
        pantalla_actual="R2C_PRECIOS",
        estado={"avisos": [], "rentas": {"simulaciones": [], "idxSimulacionSeleccionada": None}},
    )
    r = _accion(api_client, s.clave, "contratar", **auth_header)
    assert "Seleccione una simulación" in [a["texto"] for a in r.json()["avisos"]]
    s.refresh_from_db()
    assert s.pantalla_actual == "R2C_PRECIOS"
