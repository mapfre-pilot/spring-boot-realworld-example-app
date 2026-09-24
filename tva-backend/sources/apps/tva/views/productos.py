import logging

from django.conf import settings
from drf_spectacular.utils import extend_schema
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.core.cache import cached, get_cache
from apps.tva.services.connectors.apilife import get_apilife_client

logger = logging.getLogger(__name__)


@cached("tva:productos", timeout=settings.CACHE_DEFAULT_TIMEOUT)
def _catalogo_taller() -> dict:
    """Catálogo del taller — equiv. VIDA_ObtenerConfiguracionProductoComercial + TVA_GetListaProductos*."""
    return get_apilife_client().product_list()


class ProductosView(APIView):
    """GET /productos/ — catálogo del taller cacheado."""

    @extend_schema(responses={200: None})
    def get(self, request):
        return Response(_catalogo_taller())


def limpiar_cache_productos() -> None:
    get_cache().delete_pattern("tva:productos:*") if hasattr(get_cache(), "delete_pattern") else get_cache().clear()
