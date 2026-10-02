"""Envía las alertas acumuladas sin Celery."""

from django.core.management.base import BaseCommand

from apps.tva.tasks.alertas import ejecutar_alertas


class Command(BaseCommand):
    help = "Envía el email de alertas con los errores recientes"

    def add_arguments(self, parser):
        parser.add_argument("--horas", type=int, default=1)

    def handle(self, *args, **options):
        resultado = ejecutar_alertas(horas=options["horas"])
        self.stdout.write(self.style.SUCCESS(str(resultado)))
