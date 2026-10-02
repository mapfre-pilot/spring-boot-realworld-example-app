from django.apps import AppConfig


class TvaConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.tva"
    verbose_name = "Tarificador Vida Ahorro"

    def ready(self) -> None:
        from . import checks  # noqa: F401 — registra los system checks
