# Generated for TVA. La DDL oficial vive en db/liquibase/changelog/001-tva-schema.sql;
# esta migración existe para que `manage.py migrate` funcione en local/tests (sqlite).
import uuid

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Sesion",
            fields=[
                ("clave", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("usuario", models.CharField(db_index=True, max_length=128)),
                ("modalidad", models.CharField(choices=[("VA", "Venta asesorada"), ("VIA", "Venta informada"), ("R2C", "Rentas (R2C)")], max_length=8)),
                ("canal", models.CharField(choices=[("GV", "GESVIDA"), ("PFM", "PFM"), ("OTRO", "Otro")], default="OTRO", max_length=8)),
                (
                    "pantalla_actual",
                    models.CharField(
                        choices=[
                            ("SISTEMA_CERRADO", "Sistema cerrado"),
                            ("SIN_PERFIL", "Sin perfil"),
                            ("SOLO_AVISOS", "Sólo avisos"),
                            ("SELECCION_PRODUCTO_AHORRO", "Selección producto ahorro"),
                            ("SEGUROS_AHORRO", "Seguros ahorro"),
                            ("MODALIDAD_CAMPANIA", "Modalidad campaña"),
                            ("CAPTURA_DATOS_SOLICITUD", "Captura datos solicitud"),
                            ("CAPTURA_TOMADOR1", "Captura tomador 1"),
                            ("CAPTURA_TOMADOR2", "Captura tomador 2"),
                            ("RESUMEN_CONTRATACION", "Resumen contratación"),
                            ("RESULTADO_FIRMA", "Resultado firma"),
                            ("R2C_CAPTURA", "R2C captura"),
                            ("R2C_PRECIOS", "R2C precios"),
                            ("ADMINISTRACION", "Administración"),
                            ("FIN", "Fin"),
                        ],
                        max_length=64,
                    ),
                ),
                ("version_esquema", models.PositiveIntegerField(default=1)),
                ("estado", models.JSONField(blank=True, default=dict)),
                ("abierta", models.BooleanField(default=True)),
                ("creado", models.DateTimeField(auto_now_add=True)),
                ("actualizado", models.DateTimeField(auto_now=True)),
            ],
            options={"db_table": "tva_sesion", "ordering": ["-creado"]},
        ),
        migrations.CreateModel(
            name="Parametro",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("clave", models.CharField(max_length=128, unique=True)),
                ("valor", models.TextField(blank=True, default="")),
                ("tipo", models.CharField(choices=[("str", "Texto"), ("int", "Entero"), ("bool", "Booleano"), ("json", "JSON")], default="str", max_length=8)),
                ("descripcion", models.TextField(blank=True)),
                ("entorno", models.CharField(blank=True, max_length=16, null=True)),
                ("actualizado", models.DateTimeField(auto_now=True)),
            ],
            options={"db_table": "tva_parametro"},
        ),
        migrations.CreateModel(
            name="Traza",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("clave_sesion", models.CharField(blank=True, db_index=True, max_length=64)),
                ("tipo_contenido", models.CharField(blank=True, max_length=64)),
                ("clase", models.CharField(choices=[("INFO", "Info"), ("ERROR", "Error"), ("AVISO", "Aviso")], default="INFO", max_length=8)),
                ("mensaje", models.TextField(blank=True)),
                ("datos", models.JSONField(blank=True, default=dict)),
                ("creado", models.DateTimeField(auto_now_add=True)),
                ("sesion", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="trazas", to="tva.sesion")),
            ],
            options={"db_table": "tva_traza", "ordering": ["-creado"]},
        ),
    ]
