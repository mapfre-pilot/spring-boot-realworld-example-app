"""Preparación de la base de datos al arrancar el proceso WSGI.

Con ``TVA_AUTO_MIGRATE`` cada worker aplica las migraciones pendientes y
crea los parámetros TVA que falten (sin pisar los editados en Administración)
antes de atender peticiones. Un bloqueo serializa workers y réplicas.
"""

import logging
from contextlib import contextmanager

from django.conf import settings
from django.core.management import call_command
from django.db import connection

try:
    import fcntl
except ImportError:  # Windows: sin bloqueo de fichero
    fcntl = None

logger = logging.getLogger(__name__)

_LOCK_ID = 0x7456_4100


@contextmanager
def _bloqueo():
    if connection.vendor == "postgresql":
        with connection.cursor() as cursor:
            cursor.execute("SELECT pg_advisory_lock(%s)", [_LOCK_ID])
        try:
            yield
        finally:
            with connection.cursor() as cursor:
                cursor.execute("SELECT pg_advisory_unlock(%s)", [_LOCK_ID])
    elif connection.vendor == "sqlite" and fcntl and not connection.is_in_memory_db():
        with open(f"{connection.settings_dict['NAME']}.lock", "w") as fichero:
            fcntl.flock(fichero, fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(fichero, fcntl.LOCK_UN)
    else:
        yield


def preparar_base_datos() -> None:
    if connection.vendor == "sqlite" and not settings.LOCAL_ENVIRONMENT:
        logger.warning(
            "Sin DB_HOST: se usa SQLite dentro del contenedor (%s). Los datos se pierden al "
            "redesplegar y no se comparten entre réplicas: usar 1 réplica o configurar DB_*.",
            connection.settings_dict["NAME"],
        )
    with _bloqueo():
        # --fake-initial: tablas creadas antes por Liquibase (db/liquibase) se dan por migradas.
        call_command("migrate", interactive=False, fake_initial=True, verbosity=0)
        call_command("cargar_parametros", solo_nuevos=True, verbosity=0)
    connection.close()
    logger.info("Base de datos preparada (%s)", connection.vendor)


def preparar_si_procede() -> None:
    if settings.TVA_AUTO_MIGRATE:
        preparar_base_datos()
