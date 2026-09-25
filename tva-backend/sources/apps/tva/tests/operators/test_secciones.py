"""Tests §12.4.4 — validaciones de secciones con textos exactos y validar-seccion."""

import pytest

from apps.tva.models import Sesion
from apps.tva.operators import dispatcher
from apps.tva.operators.validaciones import errores_rentas_captura
from apps.tva.operators.sesion_modelo import (
    CAJA_DATOS_DEL_SEGURO,
    CAJA_DATOS_PRODUCTORES,
    CAJA_TOMADOR1,
    buscar_caja,
    nueva_sesion_estado,
    tomador_vacio,
)
from apps.tva.operators.validaciones import (
    errores_beneficiarios,
    errores_datos_operacion,
    errores_datos_personales,
    errores_direccion_correspondencia,
    errores_domiciliaciones,
    errores_domicilio_habitual,
    errores_medios_contacto,
    errores_notas,
    errores_opciones_inversion,
    errores_participante,
    errores_productores,
    iban_valido,
)

pytestmark = pytest.mark.django_db


def _sesion(pantalla="CAPTURA_DATOS_SOLICITUD", modalidad="VIA", estado=None):
    e = nueva_sesion_estado("k", modalidad)
    e["productos"] = [{"commercialProductCode": "00427", "unitLinkedInd": True, "primaMinima": 600, "primaMaxima": 1000000}]
    e["codigoProducto"] = "00427"
    if estado:
        e.update(estado)
    return Sesion.objects.create(usuario="u", modalidad=modalidad, pantalla_actual=pantalla, estado=e)


# --- mensajes exactos §12.4.4 ------------------------------------------------


@pytest.mark.parametrize(
    "faltante,msg",
    [
        ("documentId", "El documento identificativo no puede ser nulo"),
        ("nombre", "El nombre es obligatorio"),
        ("primerApellido", "El primer apellido es obligatorio"),
        ("fechaNacimiento", "La fecha de nacimiento es obligatoria"),
        ("sexo", "El sexo es obligatorio"),
        ("nacionalidad", "La nacionalidad es obligatoria"),
        ("paisNacimiento", "El país de nacimiento es obligatorio"),
        ("actividad", "Los campos Actividad, Sector y Profesión son obligatorios"),
    ],
)
def test_datos_personales_mensajes(faltante, msg):
    dp = {
        "documentId": "1",
        "nombre": "n",
        "primerApellido": "a",
        "fechaNacimiento": "1990-01-01",
        "sexo": "M",
        "nacionalidad": "ES",
        "paisNacimiento": "ES",
        "actividad": "AS",
        "sector": "SE",
        "profesion": "EM",
    }
    dp[faltante] = None
    assert msg in errores_datos_personales(dp)


def test_datos_personales_completos_sin_errores():
    dp = {
        "documentId": "1",
        "nombre": "n",
        "primerApellido": "a",
        "fechaNacimiento": "1990-01-01",
        "sexo": "M",
        "nacionalidad": "ES",
        "paisNacimiento": "ES",
        "actividad": "AS",
        "sector": "SE",
        "profesion": "EM",
    }
    assert errores_datos_personales(dp) == []


def test_medios_contacto_mensajes():
    assert "El móvil es obligatorio" in errores_medios_contacto([])
    assert "El correo electrónico es obligatorio" in errores_medios_contacto([])
    medios = [{"tipo": "MOVIL", "prefijo": "+34", "numero": "600"}, {"tipo": "EMAIL", "contactMethodValue": "a@b.es"}]
    assert errores_medios_contacto(medios) == []
    assert "El campo tipo de medio de contacto es obligatorio" in errores_medios_contacto([{"tipo": None, "numero": "1"}])
    assert "El campo Prefijo es obligatorio" in errores_medios_contacto([{"tipo": "MOVIL", "prefijo": None, "numero": "1"}])
    assert "El campo contactMethodValue es obligatorio" in errores_medios_contacto([{"tipo": "MOVIL", "prefijo": "+34"}])


def test_domicilio_habitual_mensajes():
    msgs = errores_domicilio_habitual({})
    for m in (
        "El tipo de vía es obligatorio",
        "El nombre de la vía es obligatorio",
        "El número es obligatorio",
        "El código postal es obligatorio",
        "La localidad es obligatoria",
        "La provincia es obligatoria",
        "El país es obligatorio",
    ):
        assert m in msgs
    dom = {
        "tipoVia": "CL",
        "nombreVia": "x",
        "numero": "1",
        "codigoPostal": "28001",
        "localidad": "Madrid",
        "provincia": "28",
        "pais": "ES",
    }
    assert errores_domicilio_habitual(dom) == []


def test_direccion_correspondencia_mensajes():
    msgs = errores_direccion_correspondencia({})
    assert "El Tipo de Vía es obligatorio" in msgs
    assert "El campo tipo de dirección es obligatorio" in msgs


@pytest.mark.parametrize(
    "op,msg",
    [
        ({}, "La fecha de efecto no puede ser nula"),
        ({"fechaEfecto": "2025-01-01"}, "Debe rellenar la prima única o la prima periódica"),
        ({"fechaEfecto": "2025-01-01", "aportacionPeriodica": 100}, "Debe seleccionar la periodicidad"),
        (
            {"fechaEfecto": "2025-01-01", "aportacionPeriodica": 100, "periodicidad": "M", "diaCobro": 45},
            "El valor debe estar en el rango 1 a 31",
        ),
        ({"fechaEfecto": "2025-01-01", "primaUnica": 10}, "El importe de la prima debe estar entre 600 y 1000000"),
        ({"fechaEfecto": "2025-01-01", "primaUnica": 1000, "revalorizacion": True}, "El tipo de revalorización no puede ser nulo"),
        (
            {"fechaEfecto": "2025-01-01", "primaUnica": 1000, "reinversion": {"activa": True}},
            "La operación de reinversión no puede ser nula",
        ),
        (
            {"fechaEfecto": "2025-01-01", "primaUnica": 1000, "reinversion": {"activa": True, "operacion": "R", "poliza": "1"}},
            "El tipo de de reinversion no puede ser nulo",
        ),
        ({"fechaEfecto": "2025-01-01", "primaUnica": 1000, "tipoDuracion": "ANIOS"}, "La duración no puede ser nula"),
        ({"fechaEfecto": "2025-01-01", "primaUnica": 1000, "tipoDuracion": "TABLA"}, "La tabla no puede ser nula"),
        ({"fechaEfecto": "2025-01-01", "primaUnica": 1000, "tipoDuracion": "EDAD_VENCIMIENTO"}, "La edad de vencimiento no puede ser nula"),
        (
            {"fechaEfecto": "2025-01-01", "primaUnica": 1000, "tipoDuracion": "FECHA_VENCIMIENTO"},
            "La fecha de vencimiento no puede ser nula",
        ),
        (
            {
                "fechaEfecto": "2025-01-01",
                "primaUnica": 1000,
                "tipoDuracion": "ANIOS",
                "duracion": 10,
                "gradoMinusvalia": "33",
                "fechaAltaMinusvalia": "2999-01-01",
            },
            "La fecha de alta de la minusvalía no puede ser un valor futuro",
        ),
    ],
)
def test_datos_operacion_mensajes(op, msg):
    assert msg in errores_datos_operacion(op, {"primaMinima": 600, "primaMaxima": 1000000})


def test_opciones_inversion_mensajes():
    assert "Debe seleccionar la opción de inversión" in errores_opciones_inversion([], {})
    opciones = [{"seleccionada": True, "primaUnica": 500, "plazoObjetivo": 5}]
    op = {"primaUnica": 1000}
    assert "La suma de los importes de la prima única debe coincidir con el total de la operación" in errores_opciones_inversion(
        opciones, op, {}
    )
    opciones = [{"seleccionada": True, "primaPeriodica": 50, "plazoObjetivo": 5}]
    assert "La suma de los importes de la prima periódica debe coincidir con el total de la operación" in errores_opciones_inversion(
        opciones, {"aportacionPeriodica": 100}, {}
    )
    opciones = [{"seleccionada": True, "primaUnica": 1000}]
    assert "El plazo objetivo no puede ser nulo" in errores_opciones_inversion(opciones, {"primaUnica": 1000}, {"unitLinkedInd": True})
    assert errores_opciones_inversion(opciones, {"primaUnica": 1000}, {"unitLinkedInd": False}) == []


def test_domiciliaciones_mensajes():
    assert "El IBAN de pago de recibos no puede ser nulo" in errores_domiciliaciones({})
    assert "El IBAN de pago de prestaciones no puede ser nulo" in errores_domiciliaciones({"requierePrestaciones": True})
    assert "IBAN inválido" in errores_domiciliaciones({"ibanRecibos": "ES00"})
    assert errores_domiciliaciones({"ibanRecibos": "ES91 2100 0418 4502 0005 1332"}) == []


def test_iban_valido():
    assert iban_valido("ES9121000418450200051332")
    assert not iban_valido("ES91")
    assert not iban_valido("XX9121000418450200051332")


def test_participante_y_beneficiarios_y_notas():
    msgs = errores_participante({})
    assert "El nombre es obligatorio" in msgs
    assert "El parentesco es obligatorio" in msgs
    assert "Debe incluir en el texto libre el beneficiario" in errores_beneficiarios({"tipo": "TEXTO_LIBRE"})
    assert "Hay notas seleccionadas que deben llevar texto obligatoriamente" in errores_notas([{"seleccionada": True, "texto": ""}])
    assert errores_notas([{"seleccionada": True, "texto": "ok"}]) == []


def test_productores_mensajes():
    assert "La oficina es obligatoria" in errores_productores({})
    assert "El productor es obligatorio" in errores_productores({})
    assert "El porcentaje de comisión no puede superar el máximo" in errores_productores(
        {"oficina": "1", "productor": "2", "comisionMaxima": 5, "comisionDeseada": 10}
    )
    assert errores_productores({"oficina": "1", "productor": "2", "comisionMaxima": 5, "comisionDeseada": 3}) == []


# --- validar-seccion / revalidar_caja ----------------------------------------


def test_validar_seccion_escribe_y_valida():
    s = _sesion()
    res = dispatcher.ejecutar_accion(
        s, "validar-seccion", {"caja": CAJA_DATOS_PRODUCTORES, "seccion": "productores", "datos": {"oficina": "1", "productor": "2"}}
    )
    s.refresh_from_db()
    assert s.estado["datosProductores"] == {"oficina": "1", "productor": "2"}
    caja = buscar_caja(s.estado, CAJA_DATOS_PRODUCTORES)
    assert caja["secciones"][0]["datosValidos"] is True
    assert "botones" in res


def test_validar_seccion_invalida_avisos():
    s = _sesion()
    dispatcher.ejecutar_accion(s, "validar-seccion", {"caja": CAJA_DATOS_PRODUCTORES, "seccion": "productores", "datos": {"oficina": "1"}})
    s.refresh_from_db()
    caja = buscar_caja(s.estado, CAJA_DATOS_PRODUCTORES)
    assert caja["secciones"][0]["datosValidos"] is False
    seccion_avisos = [a for a in s.estado["avisos"] if a.get("seccion") == f"{CAJA_DATOS_PRODUCTORES}/productores"]
    assert any(a["texto"] == "El productor es obligatorio" for a in seccion_avisos)


def test_validar_seccion_tomador_escribe_en_indice():
    s = _sesion()
    dispatcher.ejecutar_accion(
        s,
        "validar-seccion",
        {"caja": CAJA_TOMADOR1, "seccion": "datosPersonales", "datos": {"documentId": "1", "nombre": "n"}},
    )
    s.refresh_from_db()
    assert s.estado["tomadores"][0]["datosPersonales"]["nombre"] == "n"


def test_continuar_habilitado_solo_si_tomador_valido():
    s = _sesion(pantalla="CAPTURA_TOMADOR1")
    t = tomador_vacio()
    t["datosPersonales"] = {
        "documentId": "1",
        "nombre": "n",
        "primerApellido": "a",
        "fechaNacimiento": "1990-01-01",
        "sexo": "M",
        "nacionalidad": "ES",
        "paisNacimiento": "ES",
        "actividad": "AS",
        "sector": "SE",
        "profesion": "EM",
    }
    t["domicilioHabitual"] = {
        "tipoVia": "CL",
        "nombreVia": "x",
        "numero": "1",
        "codigoPostal": "28001",
        "localidad": "M",
        "provincia": "28",
        "pais": "ES",
    }
    t["mediosContacto"] = [{"tipo": "MOVIL", "prefijo": "+34", "numero": "600"}, {"tipo": "EMAIL", "contactMethodValue": "a@b.es"}]
    s.estado["tomadores"] = [t]
    s.save(update_fields=["estado"])
    res = dispatcher.ejecutar_accion(s, "continuar-tomador", {})
    s.refresh_from_db()
    assert s.pantalla_actual == "CAPTURA_DATOS_SOLICITUD"
    assert buscar_caja(s.estado, CAJA_TOMADOR1)["secciones"][0]["datosValidos"] is True
    assert any(a.get("texto", "").startswith("El importe máximo anual") for a in res["avisos"])


def test_continuar_no_avanza_con_errores():
    s = _sesion(pantalla="CAPTURA_TOMADOR1")
    dispatcher.ejecutar_accion(s, "continuar-tomador", {})
    s.refresh_from_db()
    assert s.pantalla_actual == "CAPTURA_TOMADOR1"


def test_doc_precontractual_habilitado_cuando_base_valida():
    s = _sesion()
    for seccion_id, datos in (
        ("operacion", {"fechaEfecto": "2025-01-01", "primaUnica": 1000, "tipoDuracion": "ANIOS", "duracion": 5}),
        ("opcionesInversion", [{"seleccionada": True, "primaUnica": 1000, "plazoObjetivo": 5}]),
        ("garantias", [{"codigo": "FC", "obligatoria": True, "seleccionada": True}]),
        ("domiciliaciones", {"ibanRecibos": "ES9121000418450200051332"}),
    ):
        dispatcher.ejecutar_accion(s, "validar-seccion", {"caja": CAJA_DATOS_DEL_SEGURO, "seccion": seccion_id, "datos": datos})
    dispatcher.ejecutar_accion(
        s, "validar-seccion", {"caja": CAJA_DATOS_PRODUCTORES, "seccion": "productores", "datos": {"oficina": "1", "productor": "2"}}
    )
    s.refresh_from_db()
    from apps.tva.operators.botonera import botones_para

    assert not {b["id"]: b for b in botones_para(s)}["doc-precontractual"]["disabled"]
    res = dispatcher.ejecutar_accion(s, "doc-precontractual", {})
    s.refresh_from_db()
    assert s.estado["documentosPrecontractuales"][0]["enviado"] is True
    # tras el envío, el botón queda deshabilitado
    assert {b["id"]: b for b in res["botones"]}["doc-precontractual"]["disabled"]


def test_producto_mock_campos_bloque2():
    from apps.tva.services.connectors.apilife import MockApiLifeClient

    prods = MockApiLifeClient().product_list(company_id="0511", nuuma="GGALV10", distribution_channel="500")["products"]
    p427 = next(p for p in prods if p["commercialProductCode"] == "00427")
    assert p427["unitLinkedInd"] and p427["opcionesInversion"]
    assert p427["garantias"][0]["obligatoria"] is True
    assert p427["periodicidades"] == ["M", "T", "S", "A"]
    p369 = next(p for p in prods if p["commercialProductCode"] == "00369")
    assert p369["periodicidades"] == ["A"]
    assert p369["primaMinima"] == 600 and p369["primaMaxima"] == 1_000_000


def test_catalogos_view(api_client, auth_header):
    res = api_client.get("/api/tva/v1/catalogos/provincias/", **auth_header)
    assert res.status_code == 200
    assert len(res.json()["valores"]) >= 50
    assert api_client.get("/api/tva/v1/catalogos/inexistente/", **auth_header).status_code == 404


def test_errores_rentas_captura_vacio():
    msgs = errores_rentas_captura({}, [])
    assert "El importe total de la prima es obligatorio" in msgs
    assert "La periodicidad de la renta es obligatoria" in msgs
    assert "Son obligatorios dos tomadores" in msgs


def test_errores_rentas_captura_por_tomador():
    rentas = {"importeTotalPrima": 6000, "periodicidadRenta": "MENSUAL"}
    msgs = errores_rentas_captura(rentas, [{}, {}])
    assert "Tomador 1: el número de DNI es obligatorio" in msgs
    assert "Tomador 1: la fecha de nacimiento es obligatoria" in msgs
    assert "Tomador 1: el porcentaje de participación es obligatorio" in msgs
    assert "Tomador 2: el número de DNI es obligatorio" in msgs


def test_errores_rentas_captura_ok():
    rentas = {"importeTotalPrima": 6000, "periodicidadRenta": "MENSUAL"}
    t = {"datosPersonales": {"documentId": "1", "fechaNacimiento": "1980-01-01", "participationPerc": 50}}
    assert errores_rentas_captura(rentas, [t, dict(t)]) == []


def test_r2c_siguiente_habilitado_tras_validar():
    s = _sesion(pantalla="R2C_CAPTURA", modalidad="R2C")
    from apps.tva.operators.botonera import botones_para

    assert {b["id"]: b for b in botones_para(s)}["siguiente"]["disabled"]
    t = {"documentId": "1", "fechaNacimiento": "1980-01-01", "participationPerc": 50}
    dispatcher.ejecutar_accion(
        s,
        "validar-seccion",
        {
            "caja": "R2C_CAPTURA",
            "seccion": "captura",
            "datos": {"rentas": {"importeTotalPrima": 6000, "periodicidadRenta": "MENSUAL"}, "tomadores": [t, dict(t)]},
        },
    )
    s.refresh_from_db()
    assert s.estado["rentas"]["importeTotalPrima"] == 6000
    assert s.estado["tomadores"][0]["datosPersonales"]["documentId"] == "1"
    assert not {b["id"]: b for b in botones_para(s)}["siguiente"]["disabled"]


def test_volver_visible_en_administracion():
    s = _sesion(pantalla="ADMINISTRACION")
    from apps.tva.operators.botonera import botones_para

    assert {b["id"]: b for b in botones_para(s, ["TVA_ADMIN_PORTAL"])}["volver"]["visible"]
