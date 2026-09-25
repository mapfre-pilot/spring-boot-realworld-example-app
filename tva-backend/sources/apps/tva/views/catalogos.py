import json
import logging
from pathlib import Path

from drf_spectacular.utils import extend_schema
from rest_framework.response import Response
from rest_framework.views import APIView

logger = logging.getLogger(__name__)

CATALOGOS_DIR = Path(__file__).resolve().parent.parent / "fixtures" / "catalogos"


class CatalogosView(APIView):
    """GET /catalogos/<nombre>/ — catálogo estático desde fixtures/catalogos/."""

    @extend_schema(responses={200: None})
    def get(self, request, nombre: str):
        path = CATALOGOS_DIR / f"{nombre}.json"
        if not path.exists() or path.parent != CATALOGOS_DIR:
            return Response({"detail": f"Catálogo '{nombre}' no disponible"}, status=404)
        return Response(json.loads(path.read_text(encoding="utf8")))
