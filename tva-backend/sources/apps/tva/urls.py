from django.urls import path

from apps.tva.views.admin import AperturaCierreView, CachesView, ParametrosView, TrazasView
from apps.tva.views.catalogos import CatalogosView
from apps.tva.views.clientes import ClientesView
from apps.tva.views.documentos import DocumentosView
from apps.tva.views.inicio import InicioAhorroView, InicioRentasView
from apps.tva.views.productos import ProductosView
from apps.tva.views.salud import SaludView
from apps.tva.views.sesiones import SesionAccionView, SesionDetailView, SesionEstadoView

urlpatterns = [
    path("salud/", SaludView.as_view(), name="tva-salud"),
    path("inicio/ahorro/", InicioAhorroView.as_view(), name="tva-inicio-ahorro"),
    path("inicio/rentas/", InicioRentasView.as_view(), name="tva-inicio-rentas"),
    path("sesiones/<str:clave>/", SesionDetailView.as_view(), name="tva-sesion"),
    path("sesiones/<str:clave>/estado/", SesionEstadoView.as_view(), name="tva-sesion-estado"),
    path("sesiones/<str:clave>/acciones/<str:accion>/", SesionAccionView.as_view(), name="tva-sesion-accion"),
    path("sesiones/<str:clave>/documentos/<str:tipo>/", DocumentosView.as_view(), name="tva-sesion-documentos"),
    path("clientes/", ClientesView.as_view(), name="tva-clientes"),
    path("productos/", ProductosView.as_view(), name="tva-productos"),
    path("catalogos/<str:nombre>/", CatalogosView.as_view(), name="tva-catalogos"),
    path("admin/parametros/", ParametrosView.as_view(), name="tva-admin-parametros"),
    path("admin/apertura-cierre/", AperturaCierreView.as_view(), name="tva-admin-apertura-cierre"),
    path("admin/caches/limpiar/", CachesView.as_view(), name="tva-admin-caches"),
    path("admin/trazas/", TrazasView.as_view(), name="tva-admin-trazas"),
]
