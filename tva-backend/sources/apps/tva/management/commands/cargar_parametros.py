"""Carga los parámetros TVA desde ``apps/tva/fixtures/parametros.json``.

El JSON se deriva de las constantes ``cons!TVA_*`` del volcado Appian
(solo valores no sensibles: ids, textos, límites y códigos).
"""

import json
from pathlib import Path

from django.core.management.base import BaseCommand

from apps.tva.models import Parametro

FIXTURE = Path(__file__).resolve().parents[2] / "fixtures" / "parametros.json"


class Command(BaseCommand):
    help = "Carga los parámetros TVA (constantes Appian) en tva_parametro"

    def add_arguments(self, parser):
        parser.add_argument("--fichero", default=str(FIXTURE), help="JSON de parámetros")
        parser.add_argument(
            "--solo-nuevos",
            action="store_true",
            help="Solo crea los parámetros que no existen (conserva los valores editados en Administración)",
        )

    def handle(self, *args, **options):
        datos = json.loads(Path(options["fichero"]).read_text(encoding="utf8"))
        creados = actualizados = 0
        guardar = Parametro.objects.get_or_create if options["solo_nuevos"] else Parametro.objects.update_or_create
        for item in datos:
            _, created = guardar(
                clave=item["clave"],
                defaults={
                    "valor": item.get("valor", ""),
                    "tipo": item.get("tipo", "str"),
                    "descripcion": item.get("descripcion", ""),
                    "entorno": item.get("entorno"),
                },
            )
            creados += created
            actualizados += not created
        accion = "conservados" if options["solo_nuevos"] else "actualizados"
        self.stdout.write(self.style.SUCCESS(f"{creados} parámetros creados, {actualizados} {accion}"))
