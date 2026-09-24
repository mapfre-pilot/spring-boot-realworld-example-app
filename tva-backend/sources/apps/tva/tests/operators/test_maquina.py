import pytest

from apps.tva.models import Sesion
from apps.tva.operators import maquina_pantallas as mp


def _s(modalidad, pantalla, estado=None):
    return Sesion(usuario="u", modalidad=modalidad, pantalla_actual=pantalla, estado=estado or {})


@pytest.mark.parametrize(
    "modalidad,esperada",
    [("VA", "SEGUROS_AHORRO"), ("VIA", "SELECCION_PRODUCTO_AHORRO"), ("R2C", "R2C_CAPTURA")],
)
def test_pantalla_inicio_basica(modalidad, esperada):
    assert mp.pantalla_inicio(modalidad, {}).value == esperada


def test_va_propuesta_perfil_ok():
    estado = {"responseProposal": {"contractingProposal": {"insurancesApplication": [{"statusDesc": None}]}}, "perfilClientesOK": True}
    assert mp.pantalla_inicio("VA", estado).value == "CAPTURA_DATOS_SOLICITUD"


def test_via_investment_offer_campania():
    assert mp.pantalla_inicio("VIA", {"investmentOption": {"insuranceOfferInd": True}}).value == "MODALIDAD_CAMPANIA"


def test_via_investment_perfil_ko():
    assert (
        mp.pantalla_inicio("VIA", {"investmentOption": {"insuranceOfferInd": False}, "perfilClientesOK": False}).value == "CAPTURA_TOMADOR1"
    )


def test_siguiente_via_salta_campania():
    s = _s("VIA", "SELECCION_PRODUCTO_AHORRO", {"modalidadCampania": False})
    assert mp.siguiente(s).value == "CAPTURA_DATOS_SOLICITUD"


def test_siguiente_y_anterior_va():
    s = _s("VA", "CAPTURA_DATOS_SOLICITUD")
    assert mp.siguiente(s).value == "CAPTURA_TOMADOR1"
    assert mp.siguiente(s, "anterior").value == "SEGUROS_AHORRO"


def test_siguiente_fin_no_avanza():
    s = _s("R2C", "FIN")
    assert mp.siguiente(s).value == "FIN"


def test_pantalla_fuera_de_secuencia():
    s = _s("VA", "SISTEMA_CERRADO")
    assert mp.siguiente(s).value == "SISTEMA_CERRADO"
