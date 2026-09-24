"""Vistas de administración — rol TVA_ADMIN_PORTAL (pantalla TVA_Pantalla_Administracion).

Stub point: la gestión fina de roles/admin de ``esp-archbacksp-lib-django-admin``
se sustituye por comprobación de claim ``roles`` en el JWT.
"""

import logging

from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.permissions import BasePermission
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.models import Parametro, Traza
from apps.tva.serializers import ParametroSerializer
from apps.tva.serializers.sesion import TrazaSerializer
from apps.tva.tasks.apertura_cierre import ejecutar_apertura_cierre
from apps.tva.views._auth import ROLE_ADMIN_PORTAL
from apps.tva.views.productos import limpiar_cache_productos

logger = logging.getLogger(__name__)


class IsTvaAdmin(BasePermission):
    def has_permission(self, request, view) -> bool:
        return bool(request.user and ROLE_ADMIN_PORTAL in getattr(request.user, "roles", []))


class ParametrosView(APIView):
    """GET/PUT /admin/parametros/ — edición de parámetros (constantes Appian)."""

    permission_classes = [IsTvaAdmin]

    @extend_schema(responses={200: ParametroSerializer(many=True)})
    def get(self, request):
        return Response(ParametroSerializer(Parametro.objects.all().order_by("clave"), many=True).data)

    @extend_schema(request=ParametroSerializer, responses={200: ParametroSerializer})
    def put(self, request):
        clave = request.data.get("clave")
        if not clave:
            return Response(
                {"error": {"codigo": "TVA_ERROR_VALIDACION", "mensaje": "clave obligatoria"}}, status=status.HTTP_400_BAD_REQUEST
            )
        param, _ = Parametro.objects.update_or_create(
            clave=clave, defaults={k: request.data.get(k, "") for k in ("valor", "tipo", "descripcion", "entorno")}
        )
        return Response(ParametroSerializer(param).data)


class AperturaCierreView(APIView):
    """POST /admin/apertura-cierre/ — batch manual de apertura/cierre programado."""

    permission_classes = [IsTvaAdmin]

    @extend_schema(responses={200: None})
    def post(self, request):
        resultado = ejecutar_apertura_cierre()
        return Response(resultado)


class CachesView(APIView):
    """POST /admin/caches/limpiar/ — invalida las cachés de la app."""

    permission_classes = [IsTvaAdmin]

    @extend_schema(responses={200: None})
    def post(self, request):
        limpiar_cache_productos()
        return Response({"limpiado": True})


class TrazasView(APIView):
    """GET /admin/trazas/?clave= — log de aplicación (equiv. TVA_Utilidades_Log)."""

    permission_classes = [IsTvaAdmin]

    @extend_schema(responses={200: TrazaSerializer(many=True)})
    def get(self, request):
        qs = Traza.objects.all().order_by("-creado")[:500]
        clave = request.query_params.get("clave")
        if clave:
            qs = qs.filter(clave_sesion=clave)
        return Response(TrazaSerializer(qs, many=True).data)
