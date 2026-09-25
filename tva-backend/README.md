# tva-backend — Tarificador Vida Ahorro (Django)

Backend Django/DRF de la migración de la aplicación Appian **TVA — Tarificador Vida Ahorro**, construido sobre el arquetipo corporativo (`arquetipos/backend-django`) pero con **solo dependencias públicas de PyPI**: las librerías corporativas `arch-ram-lib-django-*` / `esp-archbacksp-*` (feed privado de Azure Artifacts) se han sustituido por stubs locales en `apps/core/` con la misma responsabilidad.

## Requisitos

- Python 3.11 (recomendado `pyenv install 3.11.15`)
- Poetry 2.x (`pip install --user poetry`)
- Opcional: PostgreSQL 16 y Redis 7 (sin ellos se usa sqlite + caché en memoria)
- Opcional: Docker + Docker Compose

## Arranque local (clean clone, sin acceso corporativo)

```bash
cd tva-backend/sources
cp ../.env.sample ../.env          # valores por defecto válidos en local
pyenv local 3.11.15                # o cualquier Python 3.11.x
poetry install
poetry run python manage.py migrate
poetry run python manage.py cargar_parametros   # seed de cons!TVA_* (203 params)
poetry run python manage.py runserver 0.0.0.0:8888
```

Healthcheck: `curl http://localhost:8888/api/tva/v1/salud/` → `{"status":"ok","version":"1.0.0"}`.

### Token JWT local (solo `ENVIRONMENT=local`)

```bash
poetry run python manage.py crear_token_local --usuario tester --roles TVA_USUARIO,TVA_ADMIN_PORTAL
# usar como:  -H "Authorization: Bearer <token>"
```

En local los tokens son HS256 firmados con `SECRET_KEY`. En cualquier otro
entorno la autenticación es **RS256 contra el JWKS OIDC** del IdP
(`OAUTH_JWKS_URI`, `OAUTH_AUDIENCE`, `OAUTH_ISSUER`). Los roles se leen del
claim `roles` del JWT.

## Docker

```bash
cd tva-backend
cp .env.sample .env
docker compose -f docker/docker-compose.yml up --build
```

Levanta `esp-appianesad-tva` (puerto 8888) + `postgres:16` + `redis:7` usando
`docker/Dockerfile.public` (`python:3.11-slim`, sin acceso a ACR/Azure).
`docker/Dockerfile` es el del arquetipo corporativo (requiere ACR y el PAT de
Azure Artifacts); usar `Dockerfile.public` si no se dispone de ellos.

## Variables de entorno

Ver `.env.sample`. Todo lo sensible es `CHANGEME`/localhost. Destacadas:

| Variable | Uso |
|---|---|
| `ENVIRONMENT` | `local` → JWT HS256 + sqlite; otro valor → OIDC RS256 + PostgreSQL/Redis |
| `DB_*` | PostgreSQL. Sin `DB_HOST` se usa sqlite (`sources/db.sqlite3`) |
| `REDIS_*` | Redis para caché y broker Celery; sin `REDIS_HOST` se usa LocMem |
| `APILIFE_MODE` | `mock` (fixtures locales) o `real` (HTTP a `APILIFE_BASE_URL`) |
| `MISV_MODE` / `RIC_MODE` / `PERFIL_USUARIO_MODE` | igual que APILIFE |
| `OAUTH_JWKS_URI` / `OAUTH_AUDIENCE` / `OAUTH_ISSUER` | validación OIDC en no-local |
| `APPIAN_EMBED_MODE` | `mock` (taskId local) o `real` (Web APIs Appian TEST para RGPD/DNI/test conveniencia) |
| `APPIAN_EMBED_API_KEY` | clave `Appian-API-Key` de las Web APIs (solo en `real`; no versionar) |
| `APPIAN_EMBED_BASE_URL` / `APPIAN_EMBED_TIMEOUT` / `APPIAN_EMBED_EMAIL_AVISOS` | base `/suite`, timeout y email de avisos del alta cliente |

## API

Base: `/api/tva/v1/`. Documentación: `/docs/schema/` (OpenAPI) y `/docs/swagger/`
(Swagger UI). Contrato exportado en `tva-backend/openapi.yaml`
(regenerar: `poetry run python manage.py spectacular --file ../openapi.yaml`).

| Endpoint | Descripción |
|---|---|
| `GET salud/` | healthcheck público |
| `POST inicio/ahorro/`, `POST inicio/rentas/` | crea sesión (modalidad VA/VIA/R2C) |
| `GET sesiones/{clave}/` | estado de la sesión (dueño o `TVA_ADMIN_PORTAL`) |
| `PUT sesiones/{clave}/estado/` | sustituye el JSON de estado |
| `POST sesiones/{clave}/acciones/{accion}/` | `seleccionar-modalidad`, `guardar-solicitud`, `continuar-tomador`, `recalcular-rentas`, `contratar-rentas`, `firmar`, `validar-reinversion`, `verificar-productores`, `importe-maximo`, `siguiente`, `anterior` |
| `GET clientes/?documento=` | búsqueda cliente RIC + API Life |
| `GET productos/` | catálogo del taller (cacheado) |
| `GET sesiones/{clave}/documentos/{tipo}/` | `precontractual` / `poliza` / `general` |
| `GET/PUT admin/parametros/` | edición de `tva_parametro` (rol admin) |
| `POST admin/apertura-cierre/` | batch manual apertura/cierre |
| `POST admin/caches/limpiar/` | invalida cachés |
| `GET admin/trazas/?clave=` | log de aplicación |

## Swap de stubs → librerías corporativas

Cuando se disponga del PAT de Azure Artifacts:

1. Descomentar el bloque `[[tool.poetry.source]]` de `sources/pyproject.toml` y
   las dependencias corporativas marcadas `# Dependencias corporativas`.
2. Sustituir los stubs:

| Stub local | Librería corporativa |
|---|---|
| `apps/core/auth.py` | `arch-ram-lib-django-auth` |
| `apps/core/observability.py` | `arch-ram-lib-django-observability` |
| `apps/core/httpclient.py` | `arch-ram-lib-django-httpclient` |
| `apps/core/cache.py` | `arch-ram-lib-django-rediscache` |
| `config/celery.py` | `arch-ram-lib-django-celery` |
| `apps/tva/views/admin.py` | `esp-archbacksp-lib-django-admin` |

## Batch (Celery) y comandos

Las tareas Celery (`apps/tva/tasks/`) son también ejecutables como management
commands sin broker:

```bash
poetry run python manage.py apertura_cierre
poetry run python manage.py borrar_trazas --dias 30
poetry run python manage.py alertas --horas 1
poetry run python manage.py cargar_parametros   # seed de parámetros
```

Con Celery real: `celery -A config worker` / `celery -A config beat`
(`config/celery.py`, broker `CELERY_BROKER_URL`).

## DDL — Liquibase

`db/liquibase/changelog/changelog.xml` → `001-tva-schema.sql` crea
`tva_sesion`, `tva_traza`, `tva_parametro` (PostgreSQL: uuid/jsonb/timestamptz).
La migración Django `apps/tva/migrations/0001_initial.py` existe solo para
desarrollo/tests locales (sqlite); la DDL oficial en entornos es la de Liquibase.

## Calidad

```bash
cd sources
poetry run ruff check . && poetry run ruff format --check .
poetry run pyright
poetry run pytest          # cobertura >= 80% (fail_under del arquetipo)
```

## Notas de migración

- La máquina de pantallas (`operators/maquina_pantallas.py`) reproduce las
  transiciones de las reglas `TVA_*_siguientePantalla` (tabla en docstring).
- Los fixtures `apps/tva/fixtures/apilife/*.json` derivan de las reglas
  `TVA_MOCK_*` del volcado Appian, con DNI/IBAN/teléfonos/emails anonimizados.
- Los parámetros `apps/tva/fixtures/parametros.json` derivan de las constantes
  `cons!TVA_*` (solo valores no sensibles).
