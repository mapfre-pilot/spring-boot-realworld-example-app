from django.conf import settings

from apps.tva.services import configuracion
from drf_spectacular.utils import extend_schema
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


class SaludView(APIView):
    """GET /api/tva/v1/salud/ — healthcheck público.

    ``integraciones`` publica el modo (mock|real) de cada conector,
    sin URLs ni credenciales.
    """

    permission_classes = [AllowAny]
    authentication_classes = []

    @extend_schema(
        responses={
            200: {
                "type": "object",
                "properties": {
                    "status": {"type": "string"},
                    "version": {"type": "string"},
                    "auth": {
                        "type": "object",
                        "properties": {
                            "local": {"type": "boolean"},
                            "oidc": {"type": "boolean"},
                        },
                    },
                    "integraciones": {
                        "type": "object",
                        "properties": {
                            "apilife": {"type": "string", "enum": ["mock", "real"]},
                            "misv": {"type": "string", "enum": ["mock", "real"]},
                            "perfilUsuario": {"type": "string", "enum": ["mock", "real"]},
                            "ric": {"type": "string", "enum": ["mock", "real"]},
                            "appianEmbed": {"type": "string", "enum": ["mock", "real"]},
                        },
                    },
                },
            }
        }
    )
    def get(self, request):
        return Response(
            {
                "status": "ok",
                "version": "1.0.0",
                "auth": {
                    "local": settings.LOCAL_ENVIRONMENT,
                    "oidc": bool(settings.OAUTH_JWKS_URI),
                },
                "integraciones": {
                    "apilife": configuracion.obtener("APILIFE_MODE"),
                    "misv": configuracion.obtener("MISV_MODE"),
                    "perfilUsuario": configuracion.obtener("PERFIL_USUARIO_MODE"),
                    "ric": configuracion.obtener("RIC_MODE"),
                    "appianEmbed": configuracion.obtener("APPIAN_EMBED_MODE"),
                },
            }
        )
