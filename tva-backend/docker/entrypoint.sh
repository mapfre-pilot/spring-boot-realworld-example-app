#!/bin/sh
# Entrypoint del backend TVA: migra, carga parámetros y arranca gunicorn.
set -e
python manage.py migrate
python manage.py cargar_parametros
exec gunicorn config.wsgi:application --bind 0.0.0.0:8888 --workers 2
