"""Borra trazas antiguas sin Celery."""

from django.core.management.base import BaseCommand

from apps.tva.tasks.borrar_trazas import ejecutar_borrar_trazas


class Command(BaseCommand):
    help = "Borra las trazas más antiguas que TVA_TRAZA_DIAS_PERMANENCIA"

    def add_arguments(self, parser):
        parser.add_argument("--dias", type=int, default=None)

    def handle(self, *args, **options):
        resultado = ejecutar_borrar_trazas(dias=options["dias"])
        self.stdout.write(self.style.SUCCESS(str(resultado)))
