# 11. Guía de despliegue — TVA

Cómo levantar la migración completa (frontend Angular + backend Django + PostgreSQL +
Redis) desde un clon limpio de la rama `feature/tva`. El backend usa solo dependencias
públicas; el frontend además necesita acceso al feed corporativo de Azure Artifacts
(PAT, ver requisitos).

## Requisitos

| Herramienta | Versión |
|---|---|
| Node.js | ≥ 20 (probado 22/24) |
| pnpm | 11.21 (`packageManager` fijado; `corepack enable`) |
| Python | 3.11 (pyenv recomendado) |
| Poetry | ≥ 2.5 |
| Docker + Docker Compose | cualquier versión reciente (v2+) |
| PAT de Azure Artifacts | usuario `~/.npmrc` con `_auth`/`username`/`_password`/`email` hacia `pkgs.dev.azure.com` (ver §3 Frontend) |

## Instalación paso a paso en local (checklist)

1. `git clone --branch feature/tva <repo>` (rama `feature/tva`).
2. PAT en `~/.npmrc` (bloque de §3 — sin él `pnpm install` falla).
3. Backend: `cd tva-backend/sources && poetry install && cp ../.env.sample ../.env`
   (`.env` se carga vía `python-dotenv` desde `manage.py`/`wsgi.py`; los defaults
   sirven en local) `&& poetry run python manage.py migrate &&
   poetry run python manage.py cargar_parametros`.
4. `poetry run python manage.py runserver 0:8888` — `curl
   http://localhost:8888/api/tva/v1/salud/` → `integraciones` todo `mock`.
5. Token: `poetry run python manage.py crear_token_local --usuario operador1
   --roles TVA_USUARIO,TVA_ADMIN_PORTAL` → pegar en `/login` del SPA.
6. Frontend: `cd tva-frontend && pnpm install && pnpm exec nx serve tva` →
   `http://localhost:4200`; el selector de entorno aparece una vez (elegir `dev`
   → `apiBaseUrl` localhost:8888).
7. Datos de prueba mock: en Inicio `documentoCliente` cualquier NIF válido (p.ej.
   `12345678Z`), `canal` GV, `username` `operador1@mapfre.net`; el mock acepta
   cualquier productor.
8. Para integraciones reales: `*_MODE=real` + variables del § "Integraciones:
   mock vs real" y verificación con `smoke_integraciones`.
9. Comprobaciones opcionales: `poetry run python manage.py check` y
   `poetry run python manage.py smoke_integraciones` (todo OK en mock).

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

Antes de `pnpm install`, autentica el feed corporativo en `~/.npmrc` del usuario
(una vez; el `.npmrc` del repo solo apunta al registro):

```
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:username=mapfre
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:_password=<PAT_BASE64>
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:email=<tu-email>
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:always-auth=true
```

(equivalente corporativo: `:_auth=<PAT_BASE64>` en vez de `username`/`_password`;
nunca en el repo).

```bash
cd tva-frontend
pnpm install
pnpm exec nx serve tva        # http://localhost:4200
```

En la primera carga aparece una vez el selector de entorno del paquete
corporativo (claves `dev`/`pre`/`pro`); elige `dev` — su `apiBaseUrl` apunta a
`http://localhost:8888/api/tva/v1`. La elección se recuerda en `localStorage`
(`OKCD_APPLICATION_ENVIRONMENT`).

## Arranque con Docker Compose

```bash
docker compose up --build -d
```

La pila de contenedores solo levanta el backend y su infraestructura. El
frontend **no es un contenedor**: se publica como artefacto SPA con los targets
Nx del `project.json`:

```bash
cd tva-frontend
pnpm nx run tva:assemble-web --configuration=production   # genera dist/artifacts/tva/tva.zip
pnpm nx run tva:release-web                               # publica el artefacto
```

Servicios (raíz `docker-compose.yml`):

| Servicio | Puerto | Qué hace |
|---|---|---|
| `tva-backend` | 8888 | Dockerfile.public + `docker/entrypoint.sh` (migrate → cargar_parametros → gunicorn) |
| `postgres` | 5432 | PostgreSQL 16 (volumen `postgres-data`) |
| `redis` | 6379 | Redis 7 (cache/broker Celery) |

Verificación:

```bash
curl http://localhost:8888/api/tva/v1/salud/     # backend
docker compose down -v                          # parar y limpiar volúmenes
```

### Entorno del frontend

El entorno se decide en runtime leyendo `assets/environments.json` (patrón
`ngx-multienvironment`, véase `tva-frontend/README.md`): el selector solo
aparece cuando el fichero tiene varias claves; para fijar un entorno el
artefacto se empaqueta con la clave correspondiente.

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
| `APILIFE_MODE`/`MISV_MODE`/`RIC_MODE`/`PERFIL_USUARIO_MODE` | `mock` | `real` usa los conectores HTTP — variables por conector en § "Integraciones: mock vs real" (`APILIFE_*`, `MISV_*`, `RIC_*`, `SOA_*`) |
| `APPIAN_EMBED_MODE` | `mock` | `real` llama a las Web APIs Appian (pop-ups RGPD/DNI/test) |
| `APPIAN_EMBED_API_KEY` | — | clave `Appian-API-Key` (solo `real`; va en `.env`, no versionada) |
| `APPIAN_EMBED_BASE_URL` | URL Appian `/suite` | base de la instancia Appian |
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
recuerda en `localStorage` bajo `OKCD_APPLICATION_ENVIRONMENT`).

Solo el backend conserva stubs (el feed Python no está en alcance):

| Stub local | Paquete corporativo | Cómo restaurarlo |
|---|---|---|
| `apps/core/auth.py` | `arch-ram-lib-django-auth` | Descomentar bloque en `pyproject.toml`, adaptar settings |
| `apps/core/observability.py` | `arch-ram-lib-django-observability` | Ídem |
| `apps/core/httpclient.py` | `arch-ram-lib-django-httpclient` | Ídem |
| `apps/core/cache.py` | `arch-ram-lib-django-rediscache` | Ídem |
| `tva-backend/db/liquibase/` | Esquema DDL gestionado por Liquibase corporativo | Ya generado para Postgres; registrar el changelog en el repo de Liquibase |

## Integraciones reales pendientes

- **API Life / MISV / RIC / perfil de usuario**: clientes `real` implementados y
  configurables (ver § "Integraciones: mock vs real") — pendiente validación
  end-to-end con red/credenciales; el contrato RIC debe confirmarse con los
  dueños de MU. Constantes cross-app no presentes en el dump y por tanto
  con defaults env-overridables: `CMP_VAL_TRADUCCION_ES`→`APILIFE_ACCEPT_LANGUAGE=es`,
  `VIDA_ACRONIMO_APLICACION`→`MISV_APLICACION=VIDA`,
  `VIDA_CODIGOS_TIPO_PERSONA_FISICA`→`MISV_TIPO_PERSONA=F`.
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
| Appian Embedded (pop-ups) | `APPIAN_EMBED_MODE`, `APPIAN_EMBED_BASE_URL`, `APPIAN_EMBED_API_KEY` | Web APIs `cmp-firma-rgpd`, `cmp-captura-dni`, `testIdoneidad`, `cmp-respuesta-componente` | `POST {base}/webapi/…` | `smoke_integraciones --solo appian` (solo config) | Real verificado contra TEST |

## Login SSO con EntraID

El frontend soporta Authorization Code + PKCE contra EntraID con
`angular-auth-oidc-client` (sin MSAL). Se activa seleccionando un entorno con
`auth.mode: "oidc"` en `public/assets/environments.json`.

### Configuración de la app registration (Azure portal)

1. Una única app registration sirve para SPA y API.
   - `tenant`: `93ad25dd-8cdc-4066-9727-31a8a3024f80`
   - `client_id`: `86cc156f-a83e-4c72-bd33-bcaca9ef9545`
2. **Autenticación → Plataformas**: añadir plataforma **SPA** con redirect URI
   `http://localhost:4200` (en pre/pro, la URL HTTPS del portal). No marcar
   Implicit grant; usar "Authorization code with PKCE".
3. **Exponer una API**: scope `tva.access` bajo
   `api://86cc156f-a83e-4c72-bd33-bcaca9ef9545` y autorizar el propio
   `client_id` como aplicación cliente.
4. **Manifiesto**: `"accessTokenAcceptedVersion": 2` (el access token llega con
   `iss` = `https://login.microsoftonline.com/<tenant>/v2.0` y `aud` = client_id).
5. **Roles de aplicación (opcional)**: definir `TVA_USUARIO`, `TVA_ADMIN_PORTAL`
   y `TVA_DEBUG` en el manifiesto y asignarlos a usuarios/grupos. Si el token no
   trae `roles`, se aplican `OAUTH_DEFAULT_ROLES` (backend) y `auth.defaultRoles`
   (frontend), ambos por defecto `TVA_USUARIO,TVA_ADMIN_PORTAL` en `local-sso`.

### Backend

```bash
OAUTH_JWKS_URI=https://login.microsoftonline.com/93ad25dd-8cdc-4066-9727-31a8a3024f80/discovery/v2.0/keys
OAUTH_ISSUER=https://login.microsoftonline.com/93ad25dd-8cdc-4066-9727-31a8a3024f80/v2.0
OAUTH_AUDIENCE=86cc156f-a83e-4c72-bd33-bcaca9ef9545,api://86cc156f-a83e-4c72-bd33-bcaca9ef9545
OAUTH_DEFAULT_ROLES=TVA_USUARIO,TVA_ADMIN_PORTAL
# OAUTH_JWKS_CACHE_TTL=3600 (opcional)
```

`apps/core/auth.py` (clase `JWTAuthentication`) despacha por el `alg` del header
JWT: `HS256` → decode local (solo si `ENVIRONMENT=local`); `RS256` → validación
JWKS contra `OAUTH_JWKS_URI` con `issuer` y `audience` de las variables
(`OAUTH_AUDIENCE` acepta lista separada por comas). `TokenUser.sub` =
`preferred_username` ?? `upn` ?? `sub` ?? `oid`. `GET /salud/` informa
`auth: {local, oidc}` según la configuración. En local conviven ambos modos
(el `.env` puede tener los `OAUTH_*` activos sin afectar al login HS256).

### Frontend

El entorno `local-sso` de `environments.json` ya lleva authority/clientId/scope
reales y `defaultRoles`. En desarrollo:

```bash
pnpm exec nx serve tva
# abrir http://localhost:4200 → selector de entorno → elegir "local-sso"
```

Para cambiar entre `dev` y `local-sso`: en la consola del navegador
`localStorage.removeItem('OKCD_APPLICATION_ENVIRONMENT')` y recargar → vuelve a
aparecer el selector (o `localStorage.setItem('OKCD_APPLICATION_ENVIRONMENT',
'local-sso')` + recargar para fijarlo). Al entrar, cualquier ruta protegida
redirige a EntraID (authorize + PKCE); al volver, `AuthService.inicializarOidc()`
(App initializer) completa el `checkAuth()` y fija el access token en la señal
(no se guarda en localStorage; silent renew con refresh token activo). `/login`
redirige a `/` si ya hay sesión; `Salir` llama a `logoffAndRevokeTokens()`.

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
SIN_PERFIL / SOLO_AVISOS; pop-ups RGPD / Captura DNI / test de conveniencia como
tareas embebidas Appian TEST con verificación real de resultado
(`cmp-respuesta-componente`); resumen estructurado (no JSON); frontend en
Clean Architecture (`src/app/core` ports/usecases/repositorios) y tema visual
MAPFRE; conectores reales configurables (API Life spec-driven, MISV, SOAP SOA7,
RIC) con checks de configuración y `smoke_integraciones`; **193 tests backend
(84% coverage), 26 + 57 tests frontend**.

**Pendiente**: firma/contratación real (servicio de firma), documentos
precontractuales reales y descarga, cesión de derechos, notas, propuestas
persistidas en API Life, catálogo dinámico real, precio R2C real, EntraID OIDC
end-to-end, sustituir stubs `arch-ram-lib-*` por los paquetes corporativos,
integraciones reales verificadas solo con tests (HTTP mockeado — sin
red/credenciales aquí), `docker compose up` sin verificar en esta máquina
(`docker compose config` validado), i18n, tests E2E automatizados.
