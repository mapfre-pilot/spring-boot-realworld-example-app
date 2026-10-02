from django.conf import settings
from django.conf.urls.static import static
from django.urls import include, path
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
)

urlpatterns = [
    path("api/", include("apps.product.urls"), name="api"),
    path('docs/schema/', SpectacularAPIView.as_view(), name="schema"),
    path('docs/swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name="swagger"),
]

if settings.LOCAL_ENVIRONMENT:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
