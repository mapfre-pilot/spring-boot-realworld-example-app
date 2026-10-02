"""Ejecuta el batch de apertura/cierre sin Celery."""

from django.core.management.base import BaseCommand

from apps.tva.tasks.apertura_cierre import ejecutar_apertura_cierre


class Command(BaseCommand):
    help = "Ejecuta el batch apertura-cierre (equiv. PM TVA Batch Apertura-Cierre)"

    def handle(self, *args, **options):
        resultado = ejecutar_apertura_cierre()
        self.stdout.write(self.style.SUCCESS(str(resultado)))
