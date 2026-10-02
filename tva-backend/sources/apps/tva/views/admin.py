"""Vistas de administración — rol TVA_ADMIN_PORTAL (pantalla TVA_Pantalla_Administracion).

Stub point: la gestión fina de roles/admin de ``esp-archbacksp-lib-django-admin``
se sustituye por comprobación de claim ``roles`` en el JWT.
"""

import logging
from io import StringIO

from django.core.management import CommandError, call_command
from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.permissions import BasePermission
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.models import Parametro, Traza
from apps.tva.serializers import ParametroSerializer
from apps.tva.serializers.sesion import TrazaSerializer
from apps.tva.services import configuracion
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
        defaults = {k: request.data[k] for k in ("valor", "tipo", "descripcion", "entorno") if k in request.data}
        param, _ = Parametro.objects.update_or_create(clave=clave, defaults=defaults)
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
        qs = Traza.objects.all()
        clave = request.query_params.get("clave")
        if clave:
            qs = qs.filter(clave_sesion=clave)
        qs = qs.order_by("-creado")[:500]
        return Response(TrazaSerializer(qs, many=True).data)


class ConfiguracionView(APIView):
    """GET/PUT /admin/configuracion/ — conectores (modo, URLs, usuarios y secretos).

    Los secretos nunca se devuelven: solo ``configurado``. En el PUT un secreto
    vacío conserva el actual; ``restablecer`` borra el valor de BD y vuelve al
    de la variable de entorno.
    """

    permission_classes = [IsTvaAdmin]

    @extend_schema(responses={200: None})
    def get(self, request):
        return Response(configuracion.describir())

    @extend_schema(request=None, responses={200: None})
    def put(self, request):
        valores = request.data.get("valores") or {}
        restablecer = request.data.get("restablecer") or []
        if not isinstance(valores, dict) or not isinstance(restablecer, list):
            return _error_validacion("valores debe ser un objeto y restablecer una lista")
        try:
            configuracion.guardar(valores, restablecer, usuario=request.user.sub)
        except configuracion.ConfiguracionError as exc:
            return _error_validacion(str(exc))
        return Response(configuracion.describir())


class ProbarConfiguracionView(APIView):
    """POST /admin/configuracion/probar/ — smoke de solo lectura de un conector."""

    permission_classes = [IsTvaAdmin]

    @extend_schema(request=None, responses={200: None})
    def post(self, request):
        grupo = request.data.get("grupo")
        if grupo not in configuracion.GRUPOS:
            return _error_validacion(f"grupo esperado: {', '.join(configuracion.GRUPOS)}")
        salida = StringIO()
        opciones = {"solo": grupo, "nif": request.data.get("nif") or "", "usuario": request.user.sub}
        try:
            call_command("smoke_integraciones", stdout=salida, stderr=salida, **opciones)
            ok = True
        except CommandError as exc:
            salida.write(f"{exc}\n")
            ok = False
        return Response({"ok": ok, "salida": salida.getvalue()})


def _error_validacion(mensaje: str) -> Response:
    return Response({"error": {"codigo": "TVA_ERROR_VALIDACION", "mensaje": mensaje}}, status=status.HTTP_400_BAD_REQUEST)
