from datetime import timedelta

from django.core.management import call_command
from django.utils import timezone

from apps.tva.models import Parametro, Traza


def test_cargar_parametros(db):
    call_command("cargar_parametros")
    assert Parametro.objects.filter(clave="TVA_APLICACION_CERRADA").exists()


def test_crear_token_local():
    from io import StringIO

    out = StringIO()
    call_command("crear_token_local", "--usuario", "u1", "--roles", "TVA_USUARIO,TVA_ADMIN_PORTAL", stdout=out)
    token = out.getvalue().strip()
    import jwt
    from django.conf import settings

    claims = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"], options={"verify_aud": False})
    assert claims["sub"] == "u1"
    assert "TVA_ADMIN_PORTAL" in claims["roles"]


def test_apertura_cierre_command(db):
    Parametro.objects.create(clave="TVA_FECHA_APERTURA", valor="2000-01-01")
    Parametro.objects.create(clave="TVA_FECHA_CIERRE", valor="2999-01-01")
    call_command("apertura_cierre")
    assert Parametro.objects.get(clave="TVA_APLICACION_CERRADA").valor == "0"


def test_borrar_trazas_command(db):
    vieja = Traza.objects.create(clave_sesion="X", mensaje="vieja")
    Traza.objects.filter(pk=vieja.pk).update(creado=timezone.now() - timedelta(days=400))
    Traza.objects.create(clave_sesion="Y", mensaje="nueva")
    call_command("borrar_trazas", "--dias", "30")
    assert not Traza.objects.filter(pk=vieja.pk).exists()
    assert Traza.objects.filter(clave_sesion="Y").exists()


def test_alertas_command_sin_destino(db, settings):
    settings.ALERTAS_EMAIL_TO = ""
    Traza.objects.create(clase="ERROR", mensaje="boom")
    call_command("alertas", "--horas", "1")
