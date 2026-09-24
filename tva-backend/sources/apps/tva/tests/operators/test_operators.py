import pytest

from apps.tva.models import Sesion
from apps.tva.operators import dispatcher, validaciones

pytestmark = pytest.mark.django_db


def _s(modalidad="VIA", pantalla="SELECCION_PRODUCTO_AHORRO"):
    return Sesion.objects.create(usuario="u", modalidad=modalidad, pantalla_actual=pantalla, estado={"avisos": []})


def test_validar_parametros():
    assert validaciones.validar_parametros_inicio("X", "GV") == []
    assert validaciones.validar_parametros_inicio("", "") != []


def test_validar_domiciliacion():
    assert validaciones.validar_domiciliacion({"iban": "ES0000000000000000000000"}) == []
    assert validaciones.validar_domiciliacion({"iban": "ES12"}) != []
    assert validaciones.validar_domiciliacion({}) != []


def test_validar_beneficiarios():
    assert validaciones.validar_beneficiarios({"beneficiarios": [{"porcentaje": 50}, {"porcentaje": 50}]}) == []
    assert validaciones.validar_beneficiarios({"beneficiarios": [{"porcentaje": 30}]}) != []


def test_dispatcher_accion_invalida():
    with pytest.raises(dispatcher.AccionInvalida):
        dispatcher.ejecutar_accion(_s(), "bogus", {})


def test_dispatcher_rentas_en_va_avisa():
    s = _s(modalidad="VA", pantalla="SEGUROS_AHORRO")
    res = dispatcher.ejecutar_accion(s, "recalcular-rentas", {})
    assert any(a["codigo"] == "TVA_ERROR_ACCION_INVALIDA" for a in res["avisos"])


def test_dispatcher_seleccionar_modalidad_sin_datos():
    s = _s()
    res = dispatcher.ejecutar_accion(s, "seleccionar-modalidad", {})
    assert any(a["codigo"] == "TVA_ERROR_VALIDACION" for a in res["avisos"])


def test_dispatcher_seleccionar_modalidad_ok():
    s = _s()
    res = dispatcher.ejecutar_accion(s, "seleccionar-modalidad", {"modalidad": "00595"})
    assert res["pantallaActual"] in ("MODALIDAD_CAMPANIA", "CAPTURA_DATOS_SOLICITUD")


def test_dispatcher_guardar_solicitud():
    res = dispatcher.ejecutar_accion(_s(), "guardar-solicitud", {})
    assert any(a["clase"] == 4 for a in res["avisos"])


def test_dispatcher_firmar():
    s = _s(modalidad="VA", pantalla="RESUMEN_CONTRATACION")
    res = dispatcher.ejecutar_accion(s, "firmar", {"tipoFirma": "electronica"})
    assert res["pantallaActual"] in ("RESULTADO_FIRMA", "FIN")


def test_dispatcher_verificar_productores():
    res = dispatcher.ejecutar_accion(_s(), "verificar-productores", {})
    assert res["pantallaActual"]


def test_dispatcher_importe_maximo():
    s = _s()
    dispatcher.ejecutar_accion(s, "importe-maximo", {})
    assert s.estado["importeMaximo"] == 240000.0


def test_dispatcher_validar_reinversion():
    res = dispatcher.ejecutar_accion(_s(), "validar-reinversion", {})
    assert res["pantallaActual"]


def test_dispatcher_siguiente_salta_campania():
    res = dispatcher.ejecutar_accion(_s(), "siguiente", {})
    assert res["pantallaActual"] == "CAPTURA_DATOS_SOLICITUD"


def test_dispatcher_siguiente_campania():
    s = _s()
    s.estado = {"modalidadCampania": True, "avisos": []}
    res = dispatcher.ejecutar_accion(s, "siguiente", {})
    assert res["pantallaActual"] == "MODALIDAD_CAMPANIA"
