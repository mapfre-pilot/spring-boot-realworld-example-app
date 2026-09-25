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
export AZURE_ARTIFACTS_NPM_PAT_B64=<PAT de Azure Artifacts en base64>
docker compose up --build -d
```

El build del frontend recibe el PAT como *build secret* de Docker (`id=npm_pat_b64`),
nunca como `ARG`/`ENV`: no queda en capas ni en la imagen final.

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

o ajusta `TVA_ENV` del contenedor frontend: al arrancar, `docker/entrypoint.sh` reduce `assets/environments.json` a la única clave `${TVA_ENV}` (patrón ngx-multienvironment: con una sola clave el paquete no muestra el selector; falla con `exit 1` si la clave no existe).

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
| `APPIAN_EMBED_MODE` | `mock` | `real` llama a las Web APIs Appian TEST (pop-ups RGPD/DNI/test) |
| `APPIAN_EMBED_API_KEY` | — | clave `Appian-API-Key` (solo `real`; va en `.env`, no versionada) |
| `APPIAN_EMBED_BASE_URL` | `https://mapfrespain-test.appiancloud.com/suite` | base `/suite` de la instancia Appian |
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

Frontend ya usa los paquetes corporativos reales: `@mapfre-tech/ngx-multienvironment` 4.0.0
y los executores `@mapfre-tech/nx-angular` (`application`, `dev-server`), `@mapfre-tech/nx-tools`,
`nx-angular-esp`, `nx-version-esp`. El `.npmrc` del repo apunta al feed de Azure Artifacts
(`pkgs.dev.azure.com/devopsmapfre/.../releases/npm/`); **la autenticación va en `~/.npmrc`
del usuario** (líneas `_auth`/`email`/`always-auth` con un PAT en base64 como en la
documentación corporativa — nunca en el repo). `pnpm install` resuelve los paquetes.
La elección de entorno sigue el patrón del paquete: en local, `environments.json` tiene
varias claves y `initMultiEnvironmentApp` muestra su selector una vez (la elección se
recuerda en `localStorage` bajo `OKCD_APPLICATION_ENVIRONMENT`); en el contenedor,
`docker/entrypoint.sh` filtra `assets/environments.json` a la única clave `TVA_ENV`
(defecto `pro`), por lo que el selector nunca aparece.

Solo el backend conserva stubs (el feed Python no está en alcance):

| Stub local | Paquete corporativo | Cómo restaurarlo |
|---|---|---|
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

## Integraciones: mock vs real

Cada conector externo se selecciona por `*_MODE` (`mock` por defecto; la app funciona
sin configuración). En `real`, los system checks (`apps/tva/checks.py`) fallan el
arranque si falta alguna variable obligatoria. Comprobar con
`python manage.py smoke_integraciones [--solo …] [--nif …] [--usuario …]` y con
`GET /api/tva/v1/salud/` (campo `integraciones`, solo modos — sin URLs ni credenciales).

| Conector | Variables | Objeto Appian equivalente | Endpoint(s) relativos | Verificar | Estado |
|---|---|---|---|---|---|
| API Life | `APILIFE_MODE`, `APILIFE_BASE_URL`, `APILIFE_USERNAME`, `APILIFE_PASSWORD` (+ `APILIFE_APPINVE_*`, `APILIFE_ACCEPT_LANGUAGE`, `APILIFE_APPLICATION_ID`, `APILIFE_TIMEOUT`) | Connected system "TVA API Life" (Basic, usuario APPSAVI) + "TVA API Life APPINVE" (APPINVE) | `/apisbc*…/api/life/1.0/…` (17 integraciones `TVA_API_Life_*`), `/sbccliente_be-web/api/1.0/vida/cliente/{nif}/individual/ahorro/importe/maximo`, `personavida_be-web/api/1.0/vida/gestionarPersonas` (PUT, `channelCode=01`) | `smoke_integraciones --solo apilife` (hace `generalTable`) | Implementado; verificado solo con tests (HTTP mockeado) |
| MISV perfilado | `MISV_MODE`, `MISV_BASE_URL`, `MISV_USERNAME`, `MISV_PASSWORD` (+ `MISV_APLICACION`, `MISV_TIPO_PERSONA`, `MISV_TIMEOUT`) | Connected system "TVA MISV" (Basic, usuario APPCMPA), integración `TVA_PerfiladoClientes` | `GET /NOVAServices/rest/RSPerfiladoClienteV2/obtenerPerfiladoCliente` (query USUARIO/APLICACION/NIF/TIPO_PERSONA) | `smoke_integraciones --solo misv --nif <nif>` | Implementado; verificado solo con tests |
| Perfil de usuario (SOA7) | `PERFIL_USUARIO_MODE`, `SOA_BASE_URL`, `SOA_USERNAME`, `SOA_PASSWORD` (+ `SOA_TIMEOUT`) | Integración `TVA_WSDL_IGestionarPerfilUsuario` (SOAP, WSSE UsernameToken, usuario APPRIMO) | `POST {SOA_BASE_URL}/MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL` | `smoke_integraciones --solo perfil-usuario --usuario <u>` | Implementado; verificado solo con tests (sobre XML de muestra) |
| RIC | `RIC_MODE`, `RIC_BASE_URL`, `RIC_PATH`, `RIC_USERNAME`, `RIC_PASSWORD` | Regla cross-app `MU_ObtenerClienteRIC` (Appian DEV usa mock bajo `TVA_FLAG_SIMULAR_BUSQUEDA_CLIENTE_RIC`) | `GET {RIC_BASE_URL}/{RIC_PATH}?documento=<nif>` | `smoke_integraciones --solo ric --nif <nif>` | Implementado; **contrato por confirmar con los dueños de MU** |
| Appian Embedded (pop-ups) | `APPIAN_EMBED_MODE`, `APPIAN_EMBED_BASE_URL`, `APPIAN_EMBED_API_KEY` | Web APIs `tva-lanzar-*` + `cmp-respuesta-componente` | `POST {base}/webapi/…` | `smoke_integraciones --solo appian` (solo config) | Real verificado contra TEST |

## Estado de la implementación

**Cubierto**: contrato real de `inicio` (indFunctionMode/companyId/distributionChannel/
username/investment, validaciones con los textos exactos de Appian y sobre de error
`{code:"02", errors:[…]}`); modelo de sesión TVA_Sesion (cajas/secciones, avisos
`{clase,tipo,texto,mostrarEn}`); navegación dirigida por datos
(`siguiente_pantalla`, reglas VA/VIA/R2C) y botonera calculada por pantalla/modo
(`botones` en cada respuesta, con confirmaciones); acciones cancelar / administración /
volver-administracion / doc-precontractual / contratar; `validar-seccion` con los
textos exactos de §12.4.4 (datos personales, domicilio, contacto, operación,
inversión, garantías, domiciliaciones, beneficiarios, notas, productores) y avisos
a nivel sección; catálogos estáticos `GET /catalogos/<nombre>/` (sexos, países,
provincias, tipos de vía, actividad/sector/profesión, periodicidades, duración,
beneficiarios, medios de contacto); catálogo mock de 21 productos DEV de API Life
con garantías, periodicidades, primas y opciones UL; flujo completo VA
(seguros ahorro → datos solicitud → tomador 1/2 → resumen → resultado firma → fin),
VIA (selección producto → modalidad campaña → datos → tomador 1 → resumen → firma),
R2C (captura → precios → resumen → firma); login local, admin (parámetros, batch
apertura/cierre + abrir/cerrar manual, cachés, trazas); pantallas SISTEMA_CERRADO /
SIN_PERFIL / SOLO_AVISOS; 135 tests backend (82% coverage), 28 tests frontend.

**Pendiente**: firma real (servicio de firma), descarga de documentos reales,
digitalización de DNI, cesión de derechos, RGPD, notas, propuestas persistidas en API
Life, i18n, tests E2E automatizados, OIDC end-to-end.
