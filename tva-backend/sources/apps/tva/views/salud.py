from drf_spectacular.utils import extend_schema
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView


class SaludView(APIView):
    """GET /api/tva/v1/salud/ — healthcheck público."""

    permission_classes = [AllowAny]
    authentication_classes = []

    @extend_schema(responses={200: {"type": "object", "properties": {"status": {"type": "string"}, "version": {"type": "string"}}}})
    def get(self, request):
        return Response({"status": "ok", "version": "1.0.0"})
