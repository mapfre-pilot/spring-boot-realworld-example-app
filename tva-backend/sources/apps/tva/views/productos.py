import logging

from django.conf import settings
from drf_spectacular.utils import extend_schema
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.core.cache import get_cache
from apps.tva.services.connectors.apilife import get_apilife_client

logger = logging.getLogger(__name__)


def _catalogo_taller(company_id=None, nuuma=None, canal=None) -> dict:
    """Catálogo del taller — API Life ProductList(companyId, productTypeCode, nuuma, distributionChannel)."""
    key = f"tva:productos:{company_id}:{nuuma}:{canal}"
    cache = get_cache()
    cached_value = cache.get(key)
    if cached_value is not None:
        return cached_value
    value = get_apilife_client().product_list(company_id=company_id, nuuma=nuuma, distribution_channel=canal)
    cache.set(key, value, settings.CACHE_DEFAULT_TIMEOUT)
    return value


class ProductosView(APIView):
    """GET /productos/ — catálogo del taller cacheado (params opcionales)."""

    @extend_schema(responses={200: None})
    def get(self, request):
        return Response(
            _catalogo_taller(
                company_id=request.query_params.get("companyId"),
                nuuma=request.query_params.get("nuuma"),
                canal=request.query_params.get("distributionChannel"),
            )
        )


def limpiar_cache_productos() -> None:
    get_cache().delete_pattern("tva:productos:*") if hasattr(get_cache(), "delete_pattern") else get_cache().clear()
