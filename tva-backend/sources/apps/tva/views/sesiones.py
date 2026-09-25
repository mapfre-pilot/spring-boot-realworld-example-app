import logging

from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.models import Sesion
from apps.tva.operators.dispatcher import AccionInvalida, ejecutar_accion
from apps.tva.operators.maquina_pantallas import ACCIONES_VALIDAS
from apps.tva.schemas.errors import ErrorCodes, error_response
from apps.tva.serializers import AccionRequestSerializer, SesionEstadoSerializer, SesionSerializer

from ._auth import puede_ver_sesion

logger = logging.getLogger(__name__)


def _get_sesion(clave: str, user) -> Sesion:
    """404 si no existe, no está abierta para lectura ajena o no es del usuario."""
    try:
        sesion = Sesion.objects.get(clave=clave)
    except (Sesion.DoesNotExist, ValueError):
        return None
    if not puede_ver_sesion(user, sesion):
        return None
    return sesion


class SesionDetailView(APIView):
    """GET /sesiones/{clave}/ — estado completo de la sesión."""

    @extend_schema(responses={200: SesionSerializer, 404: None})
    def get(self, request, clave: str):
        sesion = _get_sesion(clave, request.user)
        if sesion is None:
            return Response(error_response(ErrorCodes.SESION_NO_ENCONTRADA, "Sesión no encontrada"), status=status.HTTP_404_NOT_FOUND)
        data = SesionSerializer(sesion).data
        from apps.tva.operators.botonera import botones_para

        data["botones"] = botones_para(sesion, getattr(request.user, "roles", []) or [])
        return Response(data)


class SesionEstadoView(APIView):
    """PUT /sesiones/{clave}/estado/ — sustituye el estado JSON."""

    @extend_schema(request=SesionEstadoSerializer, responses={200: SesionSerializer, 400: None, 404: None})
    def put(self, request, clave: str):
        sesion = _get_sesion(clave, request.user)
        if sesion is None:
            return Response(error_response(ErrorCodes.SESION_NO_ENCONTRADA, "Sesión no encontrada"), status=status.HTTP_404_NOT_FOUND)
        if not sesion.abierta:
            return Response(error_response(ErrorCodes.SESION_CERRADA, "Sesión cerrada"), status=status.HTTP_400_BAD_REQUEST)
        serializer = SesionEstadoSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        sesion.estado = serializer.validated_data["estado"]
        if "version_esquema" in serializer.validated_data:
            sesion.version_esquema = serializer.validated_data["version_esquema"]
        sesion.save(update_fields=["estado", "version_esquema", "actualizado"])
        return Response(SesionSerializer(sesion).data)


class SesionAccionView(APIView):
    """POST /sesiones/{clave}/acciones/{accion}/ — ejecuta un caso de uso."""

    @extend_schema(
        parameters=[OpenApiParameter("accion", str, enum=ACCIONES_VALIDAS)],
        request=AccionRequestSerializer,
        responses={200: None, 400: None, 404: None},
    )
    def post(self, request, clave: str, accion: str):
        sesion = _get_sesion(clave, request.user)
        if sesion is None:
            return Response(error_response(ErrorCodes.SESION_NO_ENCONTRADA, "Sesión no encontrada"), status=status.HTTP_404_NOT_FOUND)
        if not sesion.abierta:
            return Response(error_response(ErrorCodes.SESION_CERRADA, "Sesión cerrada"), status=status.HTTP_400_BAD_REQUEST)
        serializer = AccionRequestSerializer(data=request.data or {})
        serializer.is_valid(raise_exception=True)
        try:
            resultado = ejecutar_accion(
                sesion, accion, serializer.validated_data.get("datos", {}), getattr(request.user, "roles", []) or []
            )
        except AccionInvalida:
            return Response(
                error_response(ErrorCodes.ACCION_INVALIDA, f"Acción '{accion}' no reconocida"),
                status=status.HTTP_400_BAD_REQUEST,
            )
        return Response(resultado)
