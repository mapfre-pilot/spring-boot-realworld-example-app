"""Tests del contrato real de la Web API de inicio (§12.4.1) y del modelo
de sesión ``TVA_Sesion`` (§12.3) + product_list mock."""

import pytest

from apps.tva.models import Parametro
from apps.tva.operators import validaciones
from apps.tva.operators.sesion_modelo import caja_valida, nueva_sesion_estado, set_seccion_valida
from apps.tva.services.connectors.apilife import MockApiLifeClient

pytestmark = pytest.mark.django_db

BODY_OK = {
    "indFunctionMode": "VIA",
    "companyId": "0511",
    "distributionChannel": "500",
    "username": "OTORRE@mapfre.net",
    "policyHolders": [{"documentId": "00000000T"}],
    "investment": [
        {
            "commercialProductCode": "00427",
            "operationTypeCode": "S",
            "uniqueContributionAmn": 6000,
        }
    ],
}


def _parametros():
    Parametro.objects.create(clave="TVA_CODIGOS_EMPRESA_ADMITIDOS", valor='["0511"]', tipo="json")
    Parametro.objects.create(clave="TVA_CODIGOS_DISTRIBUTION_CHANNEL_ADMITIDOS", valor='["200","500"]', tipo="json")


def test_body_nulo():
    assert validaciones.validar_parametros_inicio_body(None) == ["Request inválida"]


def test_company_id():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "companyId": None})
    assert "El campo companyId no puede ser nulo" in e
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "companyId": "9999"})
    assert "Valor de companyId no permitido" in e


def test_distribution_channel():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "distributionChannel": None})
    assert "El campo distributionChannel no puede ser nulo" in e
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "distributionChannel": "999"})
    assert "Valor de distributionChannel no permitido" in e


def test_username():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "username": None})
    assert "El campo username no puede ser nulo" in e
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "username": "x@otro.com"})
    assert "El nombre de usuario debe acabar en @mapfre.net" in e


def test_ind_function_mode():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "indFunctionMode": None})
    assert "El campo indFunctionMode no puede ser nulo" in e
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "indFunctionMode": "XX"})
    assert "Valor de indFunctionMode no permitido" in e


def test_proposal_id_va():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "indFunctionMode": "VA"})
    assert "El campo proposalId no puede ser nulo si indFunctionMode es VA" in e


def test_dos_tomadores_max():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "policyHolders": [{}, {}, {}]})
    assert "No se admiten más de dos tomadores" in e


def test_va_investment_obligatorio():
    _parametros()
    e = validaciones.validar_parametros_inicio_body({**BODY_OK, "indFunctionMode": "VA", "proposalId": "1", "investment": []})
    assert "En Venta Asesorada es obligatorio informar al menos un seguro de ahorro" in e


def test_investment_option_errores():
    opt = {"commercialProductCode": "XXXXX", "operationTypeCode": "Z", "uniqueContributionAmn": None, "periodicContributionAmn": None}
    e = validaciones.validar_investment_option(opt, "investment[1]- ", "500", ["00427"])
    assert "investment[1]- commercialProductCode: El valor informado no es válido" in e
    assert "investment[1]- operationTypeCode: El valor informado no es válido" in e
    assert "investment[1]- Los dos importes no pueden ser nulos a la vez" in e

    opt2 = {
        "commercialProductCode": "00427",
        "operationTypeCode": "S",
        "uniqueContributionAmn": -1,
        "periodicContributionAmn": -5,
        "contributionFrequencyCode": "X",
    }
    e = validaciones.validar_investment_option(opt2, "investment[2]- ", "500", ["00427"])
    assert "investment[2]- uniqueContributionAmn: El valor no puede ser negativo" in e
    assert "investment[2]- periodicContributionAmn: El valor no puede ser negativo" in e
    assert "investment[2]- contributionFrequencyCode: El valor informado no es válido" in e


def test_investment_ok():
    _parametros()
    e = validaciones.validar_parametros_inicio_body(BODY_OK, ["00427"])
    assert e == []


def test_nuuma():
    assert validaciones.nuuma_desde_username("otorre@mapfre.net") == "OTORRE"


def test_sesion_modelo_cajas():
    estado = nueva_sesion_estado("k", "VIA", tomadores=[{"datosPersonales": {}}])
    assert estado["modoFuncionamiento"] == "VIA"
    assert {c["id"] for c in estado["cajas"]} == {
        "DATOS_PRODUCTORES",
        "DATOS_DEL_SEGURO",
        "CAPTURA_DATOS_TOMADOR1",
        "CAPTURA_DATOS_TOMADOR2",
    }
    assert not caja_valida(estado, "DATOS_PRODUCTORES")
    estado = set_seccion_valida(estado, "DATOS_PRODUCTORES", "productores", True)
    assert caja_valida(estado, "DATOS_PRODUCTORES")


def test_product_list_21_y_sinproductos():
    client = MockApiLifeClient()
    prods = client.product_list("0511", None, "OTORRE", "500")["products"]
    assert len(prods) == 21
    assert any(p["commercialProductCode"] == "00427" and p["unitLinkedInd"] for p in prods)
    assert client.product_list("0511", None, "SINPRODUCTOS", "500")["products"] == []
