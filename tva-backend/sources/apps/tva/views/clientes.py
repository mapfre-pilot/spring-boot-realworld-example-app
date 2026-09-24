import logging

from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.tva.services.connectors.apilife import ApiLifeError, get_apilife_client
from apps.tva.services.connectors.ric import get_ric_client

logger = logging.getLogger(__name__)


class ClientesView(APIView):
    """GET /clientes/?documento= ��� búsqueda RIC + API Life."""

    @extend_schema(parameters=[OpenApiParameter("documento", str, required=True)], responses={200: None, 400: None})
    def get(self, request):
        documento = request.query_params.get("documento", "").strip()
        if not documento:
            return Response({"error": {"codigo": "TVA_ERROR_PARAMETROS_ENTRADA", "mensaje": "documento obligatorio"}}, status=400)
        cliente_ric = get_ric_client().buscar_cliente(documento)
        try:
            cliente_apilife = get_apilife_client().client_search(documento)
        except ApiLifeError:
            cliente_apilife = {}
        return Response({"documento": documento, "ric": cliente_ric, "clienteVida": cliente_apilife})
