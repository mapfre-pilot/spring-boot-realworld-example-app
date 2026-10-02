"""Fix 1: validación por sección — datosPersonales no arrastra mediosContacto."""

import pytest

from apps.tva.models import Sesion
from apps.tva.operators import secciones
from apps.tva.operators.secciones import errores_seccion


def _estado():
    return {
        "tomadores": [
            {
                "datosPersonales": {
                    "documentId": "12345678Z",
                    "nombre": "PRUEBA",
                    "primerApellido": "TVA",
                    "segundoApellido": "UNO",
                    "fechaNacimiento": "1980-05-10",
                    "sexo": "M",
                    "nacionalidad": "ES",
                    "paisNacimiento": "ES",
                    "actividad": "A",
                    "sector": "S",
                    "profesion": "P",
                },
                "domicilioHabitual": {},
                "mediosContacto": [],
            }
        ]
    }


def test_datos_personales_ok_sin_medios():
    assert errores_seccion(_estado(), "CAPTURA_DATOS_TOMADOR1", "datosPersonales") == []


def test_medios_contacto_vacios_dan_errores():
    errs = errores_seccion(_estado(), "CAPTURA_DATOS_TOMADOR1", "mediosContacto")
    assert "El móvil es obligatorio" in errs
    assert "El correo electrónico es obligatorio" in errs


@pytest.mark.django_db
def test_validar_seccion_medios_lista_vacia_se_guarda_como_lista():
    """Bug: datos=[] se convertía en {} y el frontend rompía con .filter."""
    s = Sesion.objects.create(
        usuario="u",
        modalidad="VA",
        pantalla_actual="CAPTURA_TOMADOR1",
        estado={"avisos": [], "tomadores": [{}], "cajas": []},
    )
    r = secciones.ejecutar(s, {"caja": "CAPTURA_DATOS_TOMADOR1", "seccion": "mediosContacto", "datos": []})
    s.refresh_from_db()
    assert s.estado["tomadores"][0]["mediosContacto"] == []
    textos = [a["texto"] for a in r["avisos"] if a.get("tipo") == "ERROR"]
    assert "El móvil es obligatorio" in textos
    assert "El correo electrónico es obligatorio" in textos

    medios = [
        {"tipo": "MOVIL", "prefijo": "+34", "numero": "600123456", "contactMethodValue": "600123456"},
        {"tipo": "EMAIL", "contactMethodValue": "a@b.es"},
    ]
    r = secciones.ejecutar(s, {"caja": "CAPTURA_DATOS_TOMADOR1", "seccion": "mediosContacto", "datos": medios})
    s.refresh_from_db()
    assert s.estado["tomadores"][0]["mediosContacto"] == medios
    assert not [a for a in r["avisos"] if a.get("tipo") == "ERROR"]
