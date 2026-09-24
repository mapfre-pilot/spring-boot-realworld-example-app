"""Serializers de entrada/salida de la API TVA."""

from rest_framework import serializers

from apps.tva.models import Canal, Modalidad, Pantalla, Parametro, Sesion, Traza


class InicioRequestSerializer(serializers.Serializer):
    """Body de POST /inicio/ahorro y /inicio/rentas."""

    documentoCliente = serializers.CharField(max_length=20)
    canal = serializers.ChoiceField(choices=Canal.choices, default=Canal.OTRO)
    codigoProductor = serializers.CharField(max_length=20, required=False, allow_blank=True, default="")
    propuesta = serializers.JSONField(required=False)


class SesionSerializer(serializers.ModelSerializer):
    """Vista completa de la sesión (GET /sesiones/{clave})."""

    class Meta:
        model = Sesion
        fields = [
            "clave",
            "usuario",
            "modalidad",
            "canal",
            "pantalla_actual",
            "version_esquema",
            "estado",
            "abierta",
            "creado",
            "actualizado",
        ]
        read_only_fields = fields


class SesionEstadoSerializer(serializers.Serializer):
    """PUT /sesiones/{clave}/estado — sustituye el estado JSON completo."""

    estado = serializers.JSONField()
    version_esquema = serializers.IntegerField(required=False, min_value=1)

    def validate_estado(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("estado debe ser un objeto JSON")
        return value


class AccionRequestSerializer(serializers.Serializer):
    """Body opcional de POST /sesiones/{clave}/acciones/{accion}."""

    datos = serializers.JSONField(required=False, default=dict)


class ParametroSerializer(serializers.ModelSerializer):
    class Meta:
        model = Parametro
        fields = ["clave", "valor", "tipo", "descripcion", "entorno", "actualizado"]


class TrazaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Traza
        fields = ["id", "clave_sesion", "tipo_contenido", "clase", "mensaje", "datos", "creado"]


PANTALLAS_VALIDAS = [p.value for p in Pantalla]
MODALIDADES_VALIDAS = [m.value for m in Modalidad]
