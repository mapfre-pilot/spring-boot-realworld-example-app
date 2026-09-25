"""Modelos de persistencia de TVA.

DDL gestionada por Liquibase (`db/liquibase/changelog/`), no por
migraciones Django — la política del arquetipo es DDL vía Liquibase.
Se incluye una migración inicial solo para que `manage.py migrate`
funcione en desarrollo/tests locales (sqlite); en los entornos el DDL
oficial es el de Liquibase.
"""

import uuid

from django.db import models


class Modalidad(models.TextChoices):
    VENTA_ASESORADA = "VA", "Venta asesorada"
    VENTA_INFORMADA = "VIA", "Venta informada"
    RENTAS = "R2C", "Rentas (R2C)"


class Canal(models.TextChoices):
    GV = "GV", "GESVIDA"
    PFM = "PFM", "PFM"
    OTRO = "OTRO", "Otro"


class Pantalla(models.TextChoices):
    """Catálogo derivado de las constantes cons!TVA_ID_PANTALLA_*."""

    SISTEMA_CERRADO = "SISTEMA_CERRADO", "Sistema cerrado"
    SIN_PERFIL = "SIN_PERFIL", "Sin perfil"
    SOLO_AVISOS = "SOLO_AVISOS", "Sólo avisos"
    SELECCION_PRODUCTO_AHORRO = "SELECCION_PRODUCTO_AHORRO", "Selección producto ahorro"
    SEGUROS_AHORRO = "SEGUROS_AHORRO", "Seguros ahorro"
    MODALIDAD_CAMPANIA = "MODALIDAD_CAMPANIA", "Modalidad campaña"
    CAPTURA_DATOS_SOLICITUD = "CAPTURA_DATOS_SOLICITUD", "Captura datos solicitud"
    CAPTURA_TOMADOR1 = "CAPTURA_TOMADOR1", "Captura tomador 1"
    CAPTURA_TOMADOR2 = "CAPTURA_TOMADOR2", "Captura tomador 2"
    RESUMEN_CONTRATACION = "RESUMEN_CONTRATACION", "Resumen contratación"
    RESULTADO_FIRMA = "RESULTADO_FIRMA", "Resultado firma"
    R2C_CAPTURA = "R2C_CAPTURA", "R2C captura"
    R2C_PRECIOS = "R2C_PRECIOS", "R2C precios"
    ADMINISTRACION = "ADMINISTRACION", "Administración"
    FIN = "FIN", "Fin"


class Sesion(models.Model):
    """Sesión de tarificación — equivalente a la variable de proceso TVA_Sesion."""

    clave = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    usuario = models.CharField(max_length=128, db_index=True)
    modalidad = models.CharField(max_length=8, choices=Modalidad.choices)
    canal = models.CharField(max_length=8, choices=Canal.choices, default=Canal.OTRO)
    pantalla_actual = models.CharField(max_length=64, choices=Pantalla.choices)
    version_esquema = models.PositiveIntegerField(default=1)
    estado = models.JSONField(default=dict, blank=True)
    abierta = models.BooleanField(default=True)
    creado = models.DateTimeField(auto_now_add=True)
    actualizado = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "tva_sesion"
        ordering = ["-creado"]

    def __str__(self) -> str:
        return f"{self.clave} [{self.modalidad}] {self.pantalla_actual}"


class Traza(models.Model):
    """Registro de traza — equivalente a TVA_ENT_TRAZA (log de aplicación)."""

    class Clase(models.TextChoices):
        INFO = "INFO", "Info"
        ERROR = "ERROR", "Error"
        AVISO = "AVISO", "Aviso"

    sesion = models.ForeignKey(Sesion, null=True, blank=True, on_delete=models.SET_NULL, related_name="trazas")
    clave_sesion = models.CharField(max_length=64, blank=True, db_index=True)
    tipo_contenido = models.CharField(max_length=64, blank=True)
    clase = models.CharField(max_length=8, choices=Clase.choices, default=Clase.INFO)
    mensaje = models.TextField(blank=True)
    datos = models.JSONField(default=dict, blank=True)
    creado = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "tva_traza"
        ordering = ["-creado"]


class Parametro(models.Model):
    """Parámetro de configuración — sustituye las constantes cons!TVA_* editables."""

    class Tipo(models.TextChoices):
        STR = "str", "Texto"
        INT = "int", "Entero"
        BOOL = "bool", "Booleano"
        JSON = "json", "JSON"

    clave = models.CharField(max_length=128, unique=True)
    valor = models.TextField(blank=True, default="")
    tipo = models.CharField(max_length=8, choices=Tipo.choices, default=Tipo.STR)
    descripcion = models.TextField(blank=True)
    entorno = models.CharField(max_length=16, null=True, blank=True)
    actualizado = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "tva_parametro"

    def __str__(self) -> str:
        return self.clave

    def get_valor(self):
        """Devuelve el valor tipado (int/bool/json/str)."""
        if self.tipo == self.Tipo.INT:
            return int(self.valor)
        if self.tipo == self.Tipo.BOOL:
            return self.valor.strip().lower() in {"1", "true", "yes", "on"}
        if self.tipo == self.Tipo.JSON:
            import json

            try:
                return json.loads(self.valor)
            except (ValueError, TypeError):
                return None
        return self.valor

    @classmethod
    def get(cls, clave: str, default=None):
        """Shortcut: valor de un parámetro con fallback."""
        try:
            return cls.objects.get(clave=clave).get_valor()
        except cls.DoesNotExist:
            return default
