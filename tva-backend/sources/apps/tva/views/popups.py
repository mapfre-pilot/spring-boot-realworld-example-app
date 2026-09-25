"""Vistas de los pop-ups Appian Embedded (lanzar → taskId / completar → estado)."""

import logging

from drf_spectacular.utils import extend_schema
from rest_framework import serializers, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.operators.popups import completar_popup, lanzar_popup
from apps.tva.schemas.errors import ErrorCodes, error_response
from apps.tva.services.connectors.appian_embed import AppianEmbedError

from .sesiones import _get_sesion

logger = logging.getLogger(__name__)


class PopupLanzarSerializer(serializers.Serializer):
    idxTomador = serializers.IntegerField(min_value=0, default=0)


class PopupCompletarSerializer(serializers.Serializer):
    idxTomador = serializers.IntegerField(min_value=0, default=0)
    taskId = serializers.CharField(allow_blank=True, required=False, default="")
    resultado = serializers.ChoiceField(choices=["SUBMIT", "DISMISS", "ERROR"])


class PopupLanzarView(APIView):
    """POST /sesiones/{clave}/popups/{popup}/lanzar/ — obtiene taskId de Appian."""

    @extend_schema(request=PopupLanzarSerializer, responses={200: None, 400: None, 404: None, 502: None})
    def post(self, request, clave: str, popup: str):
        sesion = _get_sesion(clave, request.user)
        if sesion is None:
            return Response(error_response(ErrorCodes.SESION_NO_ENCONTRADA, "Sesión no encontrada"), status=status.HTTP_404_NOT_FOUND)
        serializer = PopupLanzarSerializer(data=request.data or {})
        serializer.is_valid(raise_exception=True)
        try:
            res = lanzar_popup(sesion, popup, serializer.validated_data["idxTomador"], request.user)
        except ValueError as e:
            return Response(error_response(ErrorCodes.PARAMETROS_ENTRADA, str(e)), status=status.HTTP_400_BAD_REQUEST)
        except AppianEmbedError as e:
            if e.status == 500:
                return Response(
                    error_response(e.codigo, e.mensaje, avisos=[{"mensaje": m.get("message", "")} for m in e.errores]),
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if e.status in (401, 403) or e.status == 0:
                return Response(
                    {**error_response(e.codigo, e.mensaje), "detalles": e.errores},
                    status=status.HTTP_502_BAD_GATEWAY,
                )
            return Response(error_response(e.codigo, e.mensaje), status=status.HTTP_400_BAD_REQUEST)
        return Response(res)


class PopupCompletarView(APIView):
    """POST /sesiones/{clave}/popups/{popup}/completar/ — SUBMIT/DISMISS/ERROR."""

    @extend_schema(request=PopupCompletarSerializer, responses={200: None, 400: None, 404: None})
    def post(self, request, clave: str, popup: str):
        sesion = _get_sesion(clave, request.user)
        if sesion is None:
            return Response(error_response(ErrorCodes.SESION_NO_ENCONTRADA, "Sesión no encontrada"), status=status.HTTP_404_NOT_FOUND)
        serializer = PopupCompletarSerializer(data=request.data or {})
        serializer.is_valid(raise_exception=True)
        d = serializer.validated_data
        try:
            res = completar_popup(
                sesion, popup, d["idxTomador"], d.get("taskId") or "", d["resultado"], getattr(request.user, "roles", []) or []
            )
        except ValueError as e:
            return Response(error_response(ErrorCodes.PARAMETROS_ENTRADA, str(e)), status=status.HTTP_400_BAD_REQUEST)
        return Response(res)
