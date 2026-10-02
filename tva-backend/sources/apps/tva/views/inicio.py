import logging

from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.models import Modalidad
from apps.tva.operators.iniciar_sesion import InicioError, iniciar_sesion
from apps.tva.schemas.errors import error_response, webapi_error_response
from apps.tva.serializers import InicioRequestSerializer

logger = logging.getLogger(__name__)


class _InicioBase(APIView):
    modalidad = ""

    @extend_schema(
        request=InicioRequestSerializer,
        responses={201: None, 400: None, 403: None},
    )
    def post(self, request):
        serializer = InicioRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        datos = dict(serializer.validated_data)
        if "modalidad" not in datos and self.modalidad:
            datos["modalidad"] = self.modalidad
        try:
            sesion, errores = iniciar_sesion(usuario=request.user.sub, datos=datos)
        except InicioError as exc:
            return Response(error_response(exc.codigo, exc.mensaje, exc.avisos), status=status.HTTP_400_BAD_REQUEST)
        if errores:
            return Response(webapi_error_response(errores), status=status.HTTP_400_BAD_REQUEST)
        return Response({"claveSesion": str(sesion.clave), "pantallaActual": sesion.pantalla_actual}, status=status.HTTP_201_CREATED)


class InicioAhorroView(_InicioBase):
    """POST /inicio/ahorro — venta asesorada/informada (productos ahorro)."""

    modalidad = Modalidad.VENTA_ASESORADA


class InicioRentasView(_InicioBase):
    """POST /inicio/rentas — simulador de rentas (R2C)."""

    modalidad = Modalidad.RENTAS
