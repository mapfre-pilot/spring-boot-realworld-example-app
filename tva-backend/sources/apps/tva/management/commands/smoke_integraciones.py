"""``manage.py smoke_integraciones`` — humo de conectores externos.

Por cada conector imprime su modo (mock|real); en real hace una llamada
de solo lectura e imprime OK/KO con la clase de error (sin credenciales).
Exit code 1 si algún conector queda KO.
"""

from django.conf import settings
from django.core.management.base import BaseCommand, CommandError

from apps.tva.services.connectors import apilife, misv, perfil_usuario, ric


class Command(BaseCommand):
    help = "Humo de integraciones TVA (mock|real, llamada de solo lectura en real)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--solo",
            choices=["apilife", "misv", "perfil-usuario", "ric", "appian"],
            help="Ejecutar un único conector.",
        )
        parser.add_argument("--nif", default="", help="Documento para misv/ric (obligatorio en modo real).")
        parser.add_argument("--usuario", default="", help="Usuario para perfil-usuario en modo real.")

    def handle(self, *args, **options):
        solo = options["solo"]
        ko = False
        pasos = {
            "apilife": lambda: self._apilife(),
            "misv": lambda: self._misv(options["nif"]),
            "perfil-usuario": lambda: self._perfil(options["usuario"]),
            "ric": lambda: self._ric(options["nif"]),
            "appian": lambda: self._appian(),
        }
        for nombre, paso in pasos.items():
            if solo and nombre != solo:
                continue
            if not self._paso(nombre, paso):
                ko = True
        if ko:
            raise CommandError("smoke_integraciones: conectores KO")

    def _paso(self, nombre: str, paso) -> bool:
        try:
            paso()
            self.stdout.write(f"OK  {nombre}")
            return True
        except Exception as exc:  # noqa: BLE001 — se reporta clase+mensaje
            self.stdout.write(self.style.ERROR(f"KO  {nombre}: {type(exc).__name__}: {exc}"))
            return False

    def _apilife(self):
        self.stdout.write(f"apilife  mode={settings.APILIFE_MODE}")
        if settings.APILIFE_MODE == "real":
            apilife.reset_apilife_client()
            apilife.get_apilife_client().general_table("productos")

    def _misv(self, nif: str):
        self.stdout.write(f"misv     mode={settings.MISV_MODE}")
        if settings.MISV_MODE == "real":
            if not nif:
                self.stdout.write("misv     skip (sin --nif)")
                return
            misv.reset_misv_client()
            misv.get_misv_client().perfilar({"nif": nif})

    def _perfil(self, usuario: str):
        self.stdout.write(f"perfil   mode={settings.PERFIL_USUARIO_MODE}")
        if settings.PERFIL_USUARIO_MODE == "real":
            if not usuario:
                raise CommandError("perfil-usuario real requiere --usuario")
            perfil_usuario.reset_perfil_usuario_client()
            perfil_usuario.get_perfil_usuario_client().obtener_perfil(usuario)

    def _ric(self, nif: str):
        self.stdout.write(f"ric      mode={settings.RIC_MODE}")
        if settings.RIC_MODE == "real":
            if not nif:
                raise CommandError("ric real requiere --nif")
            ric.reset_ric_client()
            ric.get_ric_client().buscar_cliente(nif)

    def _appian(self):
        modo = settings.APPIAN_EMBED_MODE
        self.stdout.write(f"appian   mode={modo} (solo config, no se llama nada mutante)")
        if modo == "real" and (not settings.APPIAN_EMBED_BASE_URL or not settings.APPIAN_EMBED_API_KEY):
            raise CommandError("appian-embed real sin APPIAN_EMBED_BASE_URL/API_KEY")
