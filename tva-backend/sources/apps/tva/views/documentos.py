import logging

from drf_spectacular.utils import extend_schema
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.models import Sesion
from apps.tva.schemas.errors import ErrorCodes, error_response
from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client

from ._auth import puede_ver_sesion

logger = logging.getLogger(__name__)

TIPOS_DOCUMENTO = {"precontractual": "individualDocuments", "poliza": "policy_documents", "general": "individualDocumentsNOdocs"}


class DocumentosView(APIView):
    """GET /sesiones/{clave}/documentos/{tipo}/ — metadatos/base64 del documento."""

    @extend_schema(responses={200: None, 404: None})
    def get(self, request, clave: str, tipo: str):
        try:
            sesion = Sesion.objects.get(clave=clave)
        except (Sesion.DoesNotExist, ValueError):
            sesion = None
        if sesion is None or not puede_ver_sesion(request.user, sesion):
            return Response(error_response(ErrorCodes.SESION_NO_ENCONTRADA, "Sesión no encontrada"), status=404)
        endpoint = TIPOS_DOCUMENTO.get(tipo)
        if not endpoint:
            return Response(error_response(ErrorCodes.VALIDACION, f"Tipo de documento '{tipo}' no válido"), status=400)
        try:
            documento = get_apilife_client().call(endpoint, {"claveSesion": str(sesion.clave)})
        except ApiLifeError as exc:
            return Response(error_response(ErrorCodes.SERVICIO_EXTERNO, str(exc)), status=502)
        return Response({"tipo": tipo, "documento": documento})
