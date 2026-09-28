"""Fix 1: validación por sección — datosPersonales no arrastra mediosContacto."""

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
