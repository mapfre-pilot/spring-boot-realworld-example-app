"""Tests de la botonera data-driven (§12.4.3) y contratar."""

import pytest

from apps.tva.models import Sesion
from apps.tva.operators import dispatcher
from apps.tva.operators.botonera import botones_para
from apps.tva.operators.sesion_modelo import nueva_sesion_estado, set_seccion_valida

pytestmark = pytest.mark.django_db


def _s(pantalla="CAPTURA_DATOS_SOLICITUD", modalidad="VIA", estado=None):
    e = nueva_sesion_estado("k", modalidad)
    if estado:
        e.update(estado)
    return Sesion.objects.create(usuario="u", modalidad=modalidad, pantalla_actual=pantalla, estado=e)


def _botones(res):
    return {b["id"]: b for b in res}


def test_cancelar_visible_con_confirm():
    b = _botones(botones_para(_s()))["cancelar"]
    assert b["visible"] and not b["disabled"] and "cancelar" in b["confirm"]["header"].lower() or b["confirm"]


def test_administracion_solo_con_rol():
    s = _s()
    assert not _botones(botones_para(s, []))["administracion"]["visible"]
    assert _botones(botones_para(s, ["TVA_ADMIN_PORTAL"]))["administracion"]["visible"]


def test_atras_y_recalcular_solo_r2c_precios():
    s = _s(pantalla="R2C_PRECIOS", modalidad="R2C")
    b = _botones(botones_para(s))
    assert b["atras"]["visible"] and b["recalcular"]["visible"] and b["recalcular"]["disabled"]
    s2 = _s()
    assert not _botones(botones_para(s2))["atras"]["visible"]


def test_guardar_y_volver_solo_va():
    s = _s(modalidad="VA")
    assert _botones(botones_para(s))["guardar-y-volver"]["visible"]
    assert not _botones(botones_para(_s()))["guardar-y-volver"]["visible"]


def test_doc_precontractual_via_habilitado_con_secciones_validas():
    e = nueva_sesion_estado("k", "VIA")
    e = set_seccion_valida(e, "DATOS_PRODUCTORES", "productores", True)
    for sec in ("operacion", "opcionesInversion", "garantias", "domiciliaciones"):
        e = set_seccion_valida(e, "DATOS_DEL_SEGURO", sec, True)
    s = _s(estado=e)
    b = _botones(botones_para(s))["doc-precontractual"]
    assert b["visible"] and not b["disabled"]


def test_continuar_tomador_deshabilitado_sin_caja_valida():
    s = _s(pantalla="CAPTURA_TOMADOR1")
    assert _botones(botones_para(s))["continuar"]["disabled"]


def test_contratar_via_requiere_docs():
    e = nueva_sesion_estado("k", "VIA")
    e = set_seccion_valida(e, "DATOS_PRODUCTORES", "productores", True)
    for sec in ("operacion", "opcionesInversion", "garantias", "domiciliaciones"):
        e = set_seccion_valida(e, "DATOS_DEL_SEGURO", sec, True)
    s = _s(estado=e)
    assert _botones(botones_para(s))["contratar"]["disabled"]
    s2 = _s(estado={**e, "documentosPrecontractuales": [{"tipo": "PRECONTRACTUAL", "enviado": True}]})
    assert not _botones(botones_para(s2))["contratar"]["disabled"]


def test_contratar_accion_motivos():
    s = _s()
    res = dispatcher.ejecutar_accion(s, "contratar", {}, roles=[])
    assert res["pantallaActual"] == "CAPTURA_DATOS_SOLICITUD"
    assert any(a["tipo"] == "ERROR" for a in res["avisos"])


def test_contratar_accion_ok():
    e = nueva_sesion_estado("k", "VIA")
    e = set_seccion_valida(e, "DATOS_PRODUCTORES", "productores", True)
    for sec in ("operacion", "opcionesInversion", "garantias", "domiciliaciones"):
        e = set_seccion_valida(e, "DATOS_DEL_SEGURO", sec, True)
    e["documentosPrecontractuales"] = [{"tipo": "PRECONTRACTUAL", "enviado": True}]
    s = _s(estado=e)
    res = dispatcher.ejecutar_accion(s, "contratar", {}, roles=[])
    assert res["pantallaActual"] == "RESUMEN_CONTRATACION"
