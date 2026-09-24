# 11. Guía de despliegue — TVA

Cómo levantar la migración completa (frontend Angular + backend Django + PostgreSQL +
Redis) desde un clon limpio de la rama `feature/tva`, usando solo dependencias públicas.

## Requisitos

| Herramienta | Versión |
|---|---|
| Node.js | ≥ 20 (probado 22/24) |
| pnpm | 11.21 (`packageManager` fijado; `corepack enable`) |
| Python | 3.11 (pyenv recomendado) |
| Poetry | ≥ 2.5 |
| Docker + Docker Compose | cualquier versión reciente (v2+) |

## Arranque local (sin Docker)

### 1. Backend

```bash
cd tva-backend/sources
poetry install
cp ../.env.sample ../.env            # ajusta si quieres Postgres en vez de sqlite
poetry run python manage.py migrate
poetry run python manage.py cargar_parametros
ENVIRONMENT=local poetry run python manage.py runserver 0:8888
```

- `salud/`: `curl http://localhost:8888/api/tva/v1/salud/`
- Swagger: `http://localhost:8888/docs/swagger/`
- Sin `DB_HOST` usa sqlite local; con `DB_*` usa PostgreSQL.
- Los fixtures siembran `TVA_FECHA_APERTURA`/`TVA_FECHA_CIERRE` **vacíos** (sin
  restricción) y `TVA_APLICACION_CERRADA=0`; los valores Appian originales se conservan
  en la `descripcion` del parámetro.

### 2. Token local

```bash
poetry run python manage.py crear_token_local --usuario operador1 \
  --roles TVA_USUARIO,TVA_ADMIN_PORTAL
```

Pega el token en la página `/login` del frontend (se guarda en `localStorage[tva_token]`).

### 3. Frontend

```bash
cd tva-frontend
pnpm install
pnpm exec nx serve tva        # http://localhost:4200
```

## Arranque con Docker Compose

```bash
docker compose up --build -d
```

Servicios (raíz `docker-compose.yml`):

| Servicio | Puerto | Qué hace |
|---|---|---|
| `tva-backend` | 8888 | Dockerfile.public + `docker/entrypoint.sh` (migrate → cargar_parametros → gunicorn) |
| `tva-frontend` | 8080 | build Nx `--configuration=pro` → nginx SPA + proxy `/api/` → backend |
| `postgres` | 5432 | PostgreSQL 16 (volumen `postgres-data`) |
| `redis` | 6379 | Redis 7 (cache/broker Celery) |

Verificación:

```bash
curl http://localhost:8080/                      # index del SPA
curl http://localhost:8080/api/tva/v1/salud/     # backend vía proxy nginx
docker compose down -v                          # parar y limpiar volúmenes
```

### Entorno del frontend en el contenedor

El entorno se decide en runtime leyendo `assets/environments.json` (véase
`tva-frontend/README.md`): sobreescribe el fichero montando un volumen:

```yaml
tva-frontend:
  volumes:
    - ./mi-environments.json:/usr/share/nginx/html/assets/environments.json:ro
```

o inyecta `window.__TVA_ENV__ = 'pre'` en el `index.html` servido.

## Variables de entorno

### Backend (`tva-backend/.env.sample`)

| Variable | Default | Uso |
|---|---|---|
| `ENVIRONMENT` | `local` | `local` = JWT HS256 propio; otro valor = OIDC RS256 |
| `DEBUG` | `False` | Debug Django |
| `SECRET_KEY` | CHANGEME | Clave Django / firma JWT local |
| `DB_HOST`/`DB_NAME`/`DB_USER`/`DB_PASSWORD`/`DB_PORT` | — | Postgres; vacío → sqlite |
| `REDIS_HOST` | localhost | Cache (django-redis) |
| `CELERY_BROKER_URL`/`CELERY_RESULT_BACKEND` | redis://localhost:6379/1 | Celery |
| `OAUTH_JWKS_URI`/`OAUTH_AUDIENCE`/`OAUTH_ISSUER` | CHANGEME | OIDC RS256 (no-local) |
| `CORS_ALLOWED_ORIGINS` | http://localhost:4200 | Orígenes del SPA (coma-separados) |
| `SQL_DEBUG` | — | `True` para loguear SQL (por defecto WARNING) |
| `APILIFE_MODE`/`MISV_MODE`/`RIC_MODE`/`PERFIL_MODE` | `mock` | `real` usa los conectores HTTP |
| `APILIFE_*`/`MISV_*`/`RIC_*` (URL/usuario/clave) | CHANGEME | Credenciales conector real |
| `CACHE_DEFAULT_TIMEOUT` | 300 | TTL caché (productos) |
| `TVA_TRAZA_DIAS_PERMANENCIA` | 365 | Purga de trazas |

### Frontend (`public/assets/environments.json`)

| Clave | dev | pre/pro |
|---|---|---|
| `apiBaseUrl` | `http://localhost:8888/api/tva/v1` | CHANGEME |
| `auth.mode` | `local` | `oidc` |
| `auth.tokenStorageKey` | `tva_token` | `tva_token` |
| `auth.authority`/`clientId`/`scope`/`redirectUrl` | — | CHANGEME (EntraID) |

## Matriz stub → paquete corporativo

| Stub local | Paquete corporativo | Cómo restaurarlo |
|---|---|---|
| `tva-frontend/libs/stubs/ngx-multienvironment` | `@mapfre-tech/ngx-multienvironment` | Quitar `libs/**` de `pnpm-workspace.yaml`, fijar versión real en `package.json`, restaurar `.npmrc.corporate` → `.npmrc`, quitar `paths` del stub en `tsconfig.json` |
| Ejecutores `@angular/build` + `project.corporate.json` | `@mapfre-tech/nx-angular`, `nx-tools` | `cp project.corporate.json project.json` + `.npmrc` corporativo |
| `.npmrc` público | `.npmrc.corporate` (feed Azure Artifacts) | Renombrar |
| `apps/core/auth.py` | `arch-ram-lib-django-auth` | Descomentar bloque en `pyproject.toml`, adaptar settings |
| `apps/core/observability.py` | `arch-ram-lib-django-observability` | Ídem |
| `apps/core/httpclient.py` | `arch-ram-lib-django-httpclient` | Ídem |
| `apps/core/cache.py` | `arch-ram-lib-django-rediscache` | Ídem |
| `tva-backend/db/liquibase/` | Esquema DDL gestionado por Liquibase corporativo | Ya generado para Postgres; registrar el changelog en el repo de Liquibase |

## Integraciones reales pendientes

- **API Life / MISV / RIC / perfil de usuario**: modo `real` listo — falta `*_MODE=real` +
  URLs/credenciales por env y validar contratos con los fixtures.
- **EntraID OIDC**: alta de app registrations (SPA + API) por el equipo; luego rellenar
  `authority`/`clientId`/`scope`/`redirectUrl` del frontend y `OAUTH_*` del backend.
- **PostgreSQL/Redis productivos**: el compose es para local; en infra real apuntar `DB_*`
  y `CELERY_*` a los servicios corporativos.
- **Celery beat**: tasks definidos (`apertura_cierre`, `borrar_trazas`, `alertas`); falta
  schedule + worker en despliegue.
- **CI corporativo**: workflows del arquetipo copiados sin cambios — esperan los secretos
  habituales del pipeline (Azure Artifacts, Sonar, etc.).

## Estado de la implementación

**Cubierto**: flujo completo VA (seguros ahorro → datos solicitud → tomador 1/2 →
resumen → resultado firma → fin), VIA (selección producto → modalidad campaña → datos →
tomador 1 → resumen → firma), R2C (captura → precios → resumen → firma); login local,
admin (parámetros, batch apertura/cierre + abrir/cerrar manual, cachés, trazas);
pantallas SISTEMA_CERRADO / SIN_PERFIL / SOLO_AVISOS; 62 tests backend (80% coverage),
18 tests frontend.

**Pendiente**: firma real (servicio de firma), descarga de documentos reales,
digitalización de DNI, cesión de derechos, RGPD, notas, propuestas persistidas en API
Life, i18n, tests E2E automatizados, OIDC end-to-end.
