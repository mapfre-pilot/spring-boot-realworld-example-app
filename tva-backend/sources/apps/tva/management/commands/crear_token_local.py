"""Genera un JWT HS256 local para probar la API en ENVIRONMENT=local."""

from datetime import timedelta

import jwt
from django.conf import settings
from django.core.management.base import BaseCommand
from django.utils import timezone


class Command(BaseCommand):
    help = "Crea un token JWT local (HS256) con sub y roles"

    def add_arguments(self, parser):
        parser.add_argument("--usuario", required=True, help="sub del token")
        parser.add_argument("--roles", default="TVA_USUARIO", help="roles separados por coma")
        parser.add_argument("--horas", type=int, default=8, help="caducidad en horas")

    def handle(self, *args, **options):
        now = timezone.now()
        claims = {
            "sub": options["usuario"],
            "roles": [r.strip() for r in options["roles"].split(",") if r.strip()],
            "iat": int(now.timestamp()),
            "exp": int((now + timedelta(hours=options["horas"])).timestamp()),
            "iss": "tva-local",
        }
        token = jwt.encode(claims, settings.SECRET_KEY, algorithm="HS256")
        self.stdout.write(token)
