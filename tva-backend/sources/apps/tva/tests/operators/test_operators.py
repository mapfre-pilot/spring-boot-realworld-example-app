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
    s.estado = {"avisos": [], "perfilClientesOK": True}
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


def test_dispatcher_siguiente_sin_oferta_salta_campania():
    s = _s()
    s.estado = {"avisos": [], "investmentOption": {}, "perfilClientesOK": True}
    res = dispatcher.ejecutar_accion(s, "siguiente", {})
    assert res["pantallaActual"] == "CAPTURA_DATOS_SOLICITUD"


def test_dispatcher_siguiente_perfil_no_ok_va_a_tomador1():
    s = _s()
    s.estado = {"avisos": [], "investmentOption": {}, "perfilClientesOK": False}
    res = dispatcher.ejecutar_accion(s, "siguiente", {})
    assert res["pantallaActual"] == "CAPTURA_TOMADOR1"


def test_dispatcher_siguiente_campania():
    s = _s()
    s.estado = {"avisos": [], "investmentOption": {"insuranceOfferInd": True}}
    res = dispatcher.ejecutar_accion(s, "siguiente", {})
    assert res["pantallaActual"] == "MODALIDAD_CAMPANIA"


def test_dispatcher_siguiente_mergea_datos_en_estado():
    s = _s(modalidad="VA", pantalla="SEGUROS_AHORRO")
    dispatcher.ejecutar_accion(s, "siguiente", {"solicitud": {"importe": 1000}})
    s.refresh_from_db()
    assert s.estado["solicitud"]["importe"] == 1000
    assert s.pantalla_actual == "CAPTURA_DATOS_SOLICITUD"


def test_tomador1_dos_tomadores_va_a_tomador2():
    s = _s(modalidad="VA", pantalla="CAPTURA_TOMADOR1")
    s.estado = {"avisos": [], "tomadores": [{}, {}]}
    res = dispatcher.ejecutar_accion(s, "siguiente", {})
    assert res["pantallaActual"] == "CAPTURA_TOMADOR2"


def test_tomador1_un_tomador_va_a_solicitud():
    s = _s(modalidad="VA", pantalla="CAPTURA_TOMADOR1")
    s.estado = {"avisos": [], "tomadores": [{}]}
    res = dispatcher.ejecutar_accion(s, "siguiente", {})
    assert res["pantallaActual"] == "CAPTURA_DATOS_SOLICITUD"


def test_cancelar_fin_y_sin_avisos():
    s = _s(modalidad="VA", pantalla="CAPTURA_DATOS_SOLICITUD")
    s.estado = {"avisos": [{"clase": 8, "tipo": "INFO", "texto": "x"}]}
    res = dispatcher.ejecutar_accion(s, "cancelar", {})
    assert res["pantallaActual"] == "FIN"
    assert res["avisos"] == []


def test_administracion_sin_rol_avisa():
    s = _s()
    res = dispatcher.ejecutar_accion(s, "administracion", {}, roles=["TVA_USUARIO"])
    assert res["pantallaActual"] == "SELECCION_PRODUCTO_AHORRO"
    assert any(a["tipo"] == "ERROR" for a in res["avisos"])


def test_administracion_con_rol_y_vuelta():
    s = _s()
    res = dispatcher.ejecutar_accion(s, "administracion", {}, roles=["TVA_ADMIN_PORTAL"])
    assert res["pantallaActual"] == "ADMINISTRACION"
    res2 = dispatcher.ejecutar_accion(s, "volver-administracion", {}, roles=["TVA_ADMIN_PORTAL"])
    assert res2["pantallaActual"] == "SELECCION_PRODUCTO_AHORRO"


def test_doc_precontractual_via():
    s = _s()
    s.estado = {"avisos": [], "tomadores": [{"datosGestionParticipante": {}}]}
    res = dispatcher.ejecutar_accion(s, "doc-precontractual", {}, roles=[])
    assert s.estado["documentosPrecontractuales"] == [{"tipo": "PRECONTRACTUAL", "enviado": True}]
    assert s.estado["tomadores"][0]["datosGestionParticipante"]["enviadosDocumentosPrecontractuales"] is True
    assert res["avisos"] == [] or all(a["tipo"] != "ERROR" for a in res["avisos"])
