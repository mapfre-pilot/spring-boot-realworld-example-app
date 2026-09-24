# 10. Plan de migración TVA basado en los arquetipos de Arquitectura España

Revisión del plan del documento 09 adaptada a los dos arquetipos corporativos facilitados
por el equipo y ya analizados: **arquetipo Angular** (documento Appian TEST "SCA2 spa") para
el SPA y **arquetipo Contenedores Python Django** ("SCA2 tvaBackend") para el backend.
Sustituye la propuesta Spring Boot del documento 09; el mapeo funcional de TVA (pantallas,
procesos, integraciones, datos) del documento 09 se mantiene y aquí se indica cómo se
aterriza en cada arquetipo.

> **Estado: propuesta pendiente de validación.** Todo lo que sigue procede de los ZIP
> reales (copiados en [`arquetipos/`](../../arquetipos/README.md)), de la documentación de
> Marketplace aportada y del análisis de TVA (docs 01–08). No se ha iniciado ninguna
> construcción. Los puntos que requieren decisión del equipo están en 10.8.

## 10.1 Lo que contienen realmente los arquetipos

### Frontend — "SCA2 spa" (`arquetipos/frontend-angular/`)

| Aspecto | Confirmado en el ZIP |
|---|---|
| Organización | Workspace **Nx 23.0.1** con una sola aplicación `app` (`project.json` en raíz, `nx.json`, `defaultProject: app`), `flavour: esp` (`.mtech-workspace-config.json`). No hay `angular.json`. |
| Angular | **21.2** (`@angular/*` `~21.2.0`), TypeScript 5.9, `strict` + `strictTemplates`. Standalone components, `bootstrapApplication`, rutas `loadComponent`. **Zoneless** (sin `zone.js` en polyfills; tests con `setupZonelessTestEnv`). |
| Gestor de paquetes | **pnpm 11.10.0** (`packageManager`), registro **Azure Artifacts** (`.npmrc`), `pnpm-workspace.yaml` con `minimumReleaseAgeExclude: @mapfre-tech/*`. |
| Paquetes corporativos | `@mapfre-tech/ngx-multienvironment` 4.0.0 (config por entorno en runtime leyendo `public/assets/environments.json` con claves `dev/pre/pro`), `@mapfre-tech/nx-angular` 1.3.0 (executors `application`, `dev-server`, `build-with-env`, `assemble-web`), `@mapfre-tech/nx-angular-esp`, `@mapfre-tech/nx-tools` (`zip`, `release-spa`, `release-debug-files-web`), `@mapfre-tech/nx-version-esp` (release con changelog *conventional commits*). |
| UI | **No incluye Angular Material ni ningún design system**: solo `@angular/forms`, `@angular/router`, SCSS. `styles.scss` vacío. |
| Estado / HTTP / i18n / auth | **No trae nada**: ni store, ni interceptores, ni librería OIDC, ni i18n (`enableI18nLegacyMessageIdFormat: false` únicamente). |
| Testing | **Jest 30** + `jest-preset-angular` 16 + **`@ngneat/spectator`** 22 (`createRoutingFactory`), `@faker-js/faker`, `factory.ts`. Sin e2e (`e2eTestRunner: none`). Cobertura `lcov` en CI. |
| Calidad | ESLint 9 flat (`@nx/eslint-plugin`, `angular-eslint`), Prettier 3.6, `.editorconfig`; **commitlint** conventional + **husky** (`commit-msg`). Regla: sufijos de clase permitidos `Component | Container | Page`; prefijo de selectores `app`. |
| Build | Presupuestos: initial 600 kB/900 kB, vendor 500/800, estilos de componente 15/20 kB. `build-with-env` por `dev/pre/pro`; `assemble-web` genera `dist/artifacts/app/app.zip`; `bundle-analyzer`; `optimize-assets`. |
| CI/CD | Workflows que reutilizan `mapfre-tech/esp-aeme-reusable-workflows-front@4`: `pull-request.yml` (lint/test/Sonar), `push-on-branch.yml`, `create-release.yml` (al mergear en `main`/`develop`/`support/*`), `tag.yml` (release web/Android/iOS/Storybook). `deploy.yml` despliega por **ArgoCD** vía `esp-pfdevops-reusable-workflows/argocd-deploy@v1` (inputs `environment`, `version`, `COMPONENT`, `TENANT`, `MANIFEST_REPOSITORY`). |
| Secretos que exige el CI | `AZURE_ARTIFACTS_PW`, `GH_TOKEN_ENCRYPTION_PASSPHRASE`, `SONAR_TOKEN`/`SONAR_ROOT_CERT`, `SLACK_TOKEN` (+ móviles/Chromatic si aplican). |

Punto de entrada real (`src/main.ts` → `app.config.ts`):

```ts
const { env, envConfig } = await initMultiEnvironmentApp();          // lee assets/environments.json
bootstrapApplication(AppComponent, getAppConfig({ env, envConfig }));  // provideRouter + provideEnvironment
```

### Backend — "SCA2 tvaBackend" (`arquetipos/backend-django/`)

| Aspecto | Confirmado en el ZIP |
|---|---|
| Identidad | `pyproject.toml`: `name = "esp-appianesad-tva"`, `description = "tarificador vida ahorro"`, `archetypeVersion = "1.12.1"`. Imagen/`docker-compose` ya nombrados `esp-appianesad-tva`. `security-metadata.toml`: `project_name = "Appian ADM"`, entidad MAPFRE ESPAÑA. **El arquetipo ya está generado para TVA.** |
| Runtime | **Python 3.11** (`>=3.11,<3.12`), **Django 5.2**, **DRF 3.17.1**, `djangorestframework-simplejwt` 5.5.1, `drf-spectacular` 0.29 + sidecar, `django-extensions` (solo `DEBUG`), `gunicorn` 22 (`--workers 3 --threads 100`, puerto **8888**), `requests`. |
| Extensiones corporativas (todas declaradas) | `arch-ram-lib-django-observability`, `-auth`, `-httpclient`, `-rediscache`, `-kafkaevent`, `-mongoatlas`, `-storages`, `-celery` y `esp-archbacksp-lib-django-admin`. Fuente Poetry suplementaria: Azure Artifacts PyPI. |
| Estructura | `sources/apps/product/{management/commands, operators, schemas, serializers, services/{connectors,providers}, tasks, tests/{commands,serializers,tasks,views}, views, urls.py, apps.py}` — todos los paquetes vacíos; `urls.py` con `urlpatterns = []`. `config/{settings.py, urls.py, wsgi.py}`; `manage.py`. Sin `poetry.lock`. |
| `settings.py` | `REST_FRAMEWORK`: `IsAuthenticated` por defecto, `JWTAuthentication` (simplejwt), JSON only, `AutoSchema` spectacular. `DATABASES`: **SQLite en memoria** (placeholder). `CACHES`: file-based (placeholder). `ALLOWED_HOSTS = ["*"]`. Logging a consola con `%(data)s`. `LOCAL_APPS = ["apps.product"]`. Rutas: `api/` → app, `docs/schema/`, `docs/swagger/`. Ninguna extensión `arch-ram-*` está aún añadida a `INSTALLED_APPS`/`MIDDLEWARE`: hay que activarlas. |
| `.env.sample` | `ENVIRONMENT, APPLICATION_NAME, SERVICE_NAME, DJANGO_PROJECT, SECRET_KEY, DEBUG, LOGGER_LEVEL, CACHE_DEFAULT_TIMEOUT, CACHE_OAUTH_TTL`. |
| Docker | `Dockerfile` multi-stage desde la imagen base corporativa `mapfre-django-base:3.11-slim` (ACR), `poetry install` con secreto `AZURE_ARTIFACTS_PW`, usuario no root; `docker-compose.yml` monta `sources/` y usa la red externa `arch-ram-network`; `common.docker-compose.yml` levanta OTel Collector, Jaeger, Prometheus, Kafka + Schema Registry, Redis TLS, GUIs y `nginx-proxy` (`*.localhost`). |
| Calidad | `pre-commit`: hooks básicos, **ruff** (check+format, `line-length 140`), **pyupgrade** `--py311-plus`, **pyright**, **pytest** obligatorio. `pytest` con `--cov=apps --cov-branch`, **`fail_under = 80`**. Estilo de test AAA (`# Arrange // Given` …). |
| CI/CD | `pull-request.yml` → `esp-pfdevops-reusable-workflows/container.django.pull-request.yml@v1` (build, test, Sonar; Poetry 2.1.1); `merge-commit.yml` → `container.django.merge-commit.yml@v1` (imagen a ACR, `deploy-on-develop: true`, borrado de ramas de versión); `deploy.yml` → ArgoCD igual que el front. GitFlow `develop`/`main`. |
| Asistentes IA | `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `README.agents.md`: exigen instalar `@mapfre-tech/clai` (npm Azure) y la skill **`django-engineer`** antes de generar código. |

Observaciones del arquetipo backend a tener en cuenta:

- `settings.py` contiene un error de sintaxis en `LOGGING.handlers.console.formatter`
  (`"verbose"",`): el proyecto no arranca tal cual; corregir en la fase 1.
- Falta `poetry.lock`; la primera instalación lo generará contra Azure Artifacts.
- `security-metadata.toml` viene con `project_name = "Appian ADM"`; revisar si TVA debe
  tener ficha propia.

## 10.2 Qué cambia respecto al plan del documento 09

| Tema | Doc 09 | Plan con arquetipos (confirmado) |
|---|---|---|
| Backend | Spring Boot 3 / Java 21 | **Django 5.2 / Python 3.11 / DRF**, proyecto `esp-appianesad-tva` ya generado |
| Estructura backend | `api / application / core / infrastructure` | `views / serializers / schemas / operators / services(connectors, providers) / tasks / management.commands` |
| Persistencia | JPA + Flyway | ORM Django con `managed = False`; **DDL con Liquibase** en el componente de BBDD (política del arquetipo) |
| Cliente HTTP a API Life / SBC / MISV / RIC | WebClient + Resilience4j | `arch-ram-lib-django-httpclient` (Basic/JWT/OAuth2/OBO, credenciales YAML) |
| Seguridad API | Spring Security Resource Server | `arch-ram-lib-django-auth` (JWT EntraID vía JWKS, scopes por endpoint, CORS). El `simplejwt` del scaffolding queda solo para local |
| Caché de taller/productos | Caffeine | `arch-ram-lib-django-rediscache` |
| Batch | `@Scheduled` | `arch-ram-lib-django-celery` (worker + beat) o `management/commands` + CronJob |
| Observabilidad | Micrometer | `arch-ram-lib-django-observability` (obligatoria) |
| OpenAPI | springdoc | API First: `openapi.yaml` en repo + `drf-spectacular` para publicar `/docs/swagger`; cliente TS generado para el front |
| Frontend | Angular 19 + Material, npm, `ng new` | **Nx 23 + Angular 21.2 zoneless, pnpm 11.10**, executors `@mapfre-tech/nx-angular`, config runtime `ngx-multienvironment` |
| UI kit | Angular Material | El arquetipo **no impone ninguno** → propuesta: **Angular Material 21 + CDK** (petición original), tema SCSS corporativo; ver 10.8-2 |
| Estado | Signals / Signal Store | Signals nativos + `SesionStore` propio (servicio `@Injectable` con `signal`/`computed`); sin dependencia extra salvo que el equipo prefiera `@ngrx/signals` |
| Tests front | Jasmine/Karma o Jest | **Jest + Spectator** (viene en el arquetipo); e2e no incluido → Playwright opcional |
| CI/CD | Genérico | Workflows reusables front (`esp-aeme-reusable-workflows-front@4`) y back (`esp-pfdevops-reusable-workflows@v1`), Sonar, ACR, ArgoCD |
| Repositorios | Monorepo aquí | Desarrollo en `feature/tva` de este repo (decisión del equipo); estructura de cada componente idéntica a la de su arquetipo para poder moverlos a repos `mapfre-tech` sin cambios |

Se mantiene íntegro del documento 09: la tabla "qué se migra y qué no" (9.1), el mapeo de
interfaces Appian → features Angular (9.3), la lista de casos de uso derivados de los 28
procesos (9.4), el modelo de datos `tva_sesion / tva_traza / tva_parametro` (9.4) y los
riesgos (9.6).

## 10.3 Arquitectura objetivo

```
Portal GV / PFM ──POST /api/tva/v1/inicio/*──▶ ┌────────────────────────────────────────┐
                                                │ esp-appianesad-tva (Django, contenedor)│
Navegador ──▶ tva-frontend (Nx/Angular 21) ─JWT▶│ views · serializers · operators        │──▶ API Life / SBC / MISV / RIC
              Material · Signals · pnpm         │ services.connectors (httpclient)       │──▶ PostgreSQL  ← DDL Liquibase
              ngx-multienvironment (dev/pre/pro)│ tasks (celery) · rediscache            │──▶ Redis (caché taller/productos)
                                                │ observability · auth (EntraID JWKS)    │──▶ SMTP (alertas)
                                                └────────────────────────────────────────┘
                      ▲                                             ▲
                      └──────────────── EntraID (OIDC / JWT) ───────┘
```

Principios (iguales a 9.2): el backend es la fuente de verdad de la sesión, orquesta los
casos de uso (uno por proceso Appian) y es el único que habla con API Life/MISV/RIC; el
front solo consume el backend con el JWT de EntraID.

## 10.4 Backend Django — aterrizaje de TVA en el arquetipo

Se renombra la app `product` a **`tva`** (`LOCAL_APPS = ["apps.tva"]`) y se rellenan las
carpetas ya previstas por el arquetipo:

```
sources/apps/tva/
├── views/         inicio.py (POST /inicio/ahorro, /inicio/rentas — portales, scope propio)
│                  sesiones.py (GET /sesiones/{clave}, POST /sesiones/{clave}/acciones/{accion})
│                  clientes.py (GET /clientes?documento=)
│                  documentos.py (GET /sesiones/{clave}/documentos/{tipo})
│                  admin.py (parámetros, apertura/cierre, cachés, log)
├── serializers/   SesionSerializer (versionado), TomadorSerializer, …  ← CDT TVA_* y VIDA_API_Life_*
├── schemas/       respuestas y errores OpenAPI (códigos hoy en cons!TVA_*_ERROR)
├── operators/     casos de uso = procesos Appian: iniciar_sesion_ahorro, seleccionar_modalidad,
│                  guardar_solicitud, continuar_tomador, recalcular_rentas, contratar_rentas,
│                  firmar, validar_reinversion, verificar_productores, importe_maximo, perfil_cliente
│                  + maquina_pantallas (reglas TVA_*_siguientePantalla) + validaciones (TVA_*_Validacion)
├── services/connectors/  apilife.py (16 endpoints TVA_API_Life_*), sbc.py, misv.py, ric.py,
│                         perfil_usuario.py (SOAP)  — sobre arch-ram-lib-django-httpclient
├── models.py      Sesion (JSONField + version_esquema + pantalla_actual + usuario), Traza, Parametro  (managed=False)
├── tasks/         apertura_cierre.py, borrar_trazas.py, alertas.py  (celery beat)
├── management/commands/  cargar_parametros.py (extracción de las ~200 constantes Appian)
└── tests/         views/ serializers/ tasks/ commands/ + operators/ (AAA, cobertura ≥ 80 %)
```

Decisiones de diseño derivadas del arquetipo:

- **`settings.py`**: `DATABASES` → PostgreSQL por variables de entorno; `CACHES` → Redis
  (extensión); `INSTALLED_APPS`/`MIDDLEWARE` con observability, auth y httpclient; retirar
  `ALLOWED_HOSTS=["*"]` y `simplejwt` fuera de local. Nuevas variables en `.env.sample`
  (`DB_*`, `REDIS_*`, `OAUTH_JWKS_URI`, `OAUTH_AUDIENCE`, `APILIFE_*`, `MISV_*`, `SMTP_*`),
  todas con valores `CHANGEME`.
- **Sesión** en `JSONField` con `version_esquema` (resuelve A2/A3/M10 de 07-mejoras) y
  vinculada al `oid` del JWT: solo el propietario o un admin la recupera.
- **DDL** (`tva_sesion`, `tva_traza`, `tva_parametro`) como changelogs **Liquibase**; sin
  migraciones Django (no se usa `esp-archbacksp-lib-django-admin`; se elimina de
  `pyproject` junto con `mongoatlas`, `kafkaevent` y `storages`, que TVA no necesita).
- **Credenciales** de API Life/MISV/BD: YAML del httpclient + secretos del cluster.
  Desaparece `TVA_Conectar_ContrasennaUsuarioVida` (A1).
- **Caché** del taller (`VIDA_ObtenerConfiguracionProductoComercial`, listas de productos)
  con `rediscache` y TTL; endpoint admin para invalidar.
- **Batch**: apertura/cierre programado y borrado de trazas como tareas Celery Beat;
  alertas por email como tarea. El `docker-compose` ya contempla contenedores separados
  para worker/beat con el mismo `command` pattern.
- **Portales GV/PFM**: endpoints `/inicio/*` con scope `tva.inicio` (`client_credentials`
  por portal en EntraID), sustituyendo al grupo `TVA WebApi Inicio`.
- **Observabilidad**: la extensión obligatoria reemplaza `MU_Traza*`/`TVA_LogAplicacion`;
  `claveSesion` viaja como atributo de traza/log.
- **API First**: `openapi.yaml` versionado y validado en CI (`drf-spectacular` solo
  publica). Del contrato se genera el cliente TypeScript del front con `openapi-generator`
  (`typescript-angular`), ya que el arquetipo Angular no trae generador propio.
- **Convenciones del arquetipo** que se respetan: ruff/pyright/pyupgrade en pre-commit,
  tests AAA con `api_client`, docstrings PEP 257, `fail_under = 80`.

## 10.5 Frontend Angular — aterrizaje en el arquetipo

Se conserva el mapeo de features del documento 09 (shell, productos, solicitud, tomador,
rentas, resumen, diálogos, admin, shared/ui). Ajustes al arquetipo real:

- **Base**: copia del workspace `arquetipos/frontend-angular/` (Nx 23, Angular 21.2
  zoneless, pnpm 11.10). App única `app` → renombrada `tva`; features como carpetas
  `src/app/pages/<feature>/` (sufijo `Page`), componentes reutilizables en
  `src/app/shared/` (sufijo `Component`), contenedores con lógica (sufijo `Container`),
  según la regla ESLint del arquetipo.
- **Zoneless**: toda la reactividad con **Signals** (`signal`, `computed`, `effect`,
  `input()`/`output()`), `ChangeDetectionStrategy.OnPush` y `toSignal` para HTTP.
  `SesionStore` = servicio `providedIn: 'root'` con `signal<Sesion>` + `computed` de
  pantalla actual; nada de `zone.run`.
- **UI kit**: se añade **Angular Material 21 + CDK** (el arquetipo no trae ninguno y no lo
  prohíbe) con tema SCSS propio; los equivalentes de `MU_TextField`, `MU_Dropdown`,
  `MU_Aviso` son wrappers en `shared/ui`. Se vigilan los presupuestos del arquetipo
  (initial 600/900 kB): Material se importa por componente y con `loadComponent`.
- **Configuración por entorno**: URLs del backend y de EntraID en
  `public/assets/environments.json` (`dev/pre/pro`) leídas con `provideEnvironment`; el
  build `build-with-env` selecciona la clave. Sin `environment.ts`.
- **Autenticación**: el arquetipo no trae OIDC → añadir `angular-auth-oidc-client`
  (EntraID, PKCE) + `HttpInterceptorFn` que adjunta el `Bearer`; guards funcionales por
  rol (`TVA_USUARIO`, `TVA_ADMIN_PORTAL`, `TVA_DEBUG` como app roles de EntraID).
- **HTTP**: `provideHttpClient(withInterceptors([...]))` + cliente generado desde
  `openapi.yaml` en `src/app/api/` (no editable a mano).
- **i18n**: textos en castellano hardcodeados en Appian → `@angular/localize` solo si el
  equipo lo pide; por defecto constantes en `shared/i18n/es.ts`.
- **Testing**: Jest + Spectator (`createComponentFactory`/`createRoutingFactory`),
  `faker`/`factory.ts` para fixtures de sesión; cobertura `lcov` en el target `ci-test`.
  e2e opcional con Playwright fuera del arquetipo.
- **Calidad**: commitlint conventional (husky), Prettier, ESLint flat del arquetipo,
  Sonar en el PR workflow.
- **Microfrontend**: el arquetipo tiene targets `assemble-mf`/`release-mf` (workspace) pero
  la app generada es SPA clásica → TVA arranca como SPA; convertir a MF solo si GV/PFM son
  *shells* de la Arquitectura de Referencia.

## 10.6 Requisitos de entorno

| Herramienta | Front | Back | Estado en mi máquina |
|---|---|---|---|
| Git | ✓ | ✓ | disponible |
| Node 22+ | ✓ | — | Node 24 disponible |
| pnpm 11.10 | ✓ | — | por instalar (`corepack enable`) |
| `~/.npmrc` Azure Artifacts (PAT *Packaging Read*) | ✓ | ✓ (`clai`) | **necesito `AZURE_ARTIFACTS_PW`**: sin él no se instalan `@mapfre-tech/*` ni `arch-ram-lib-*` |
| Python 3.11 + Poetry 2.1 | — | ✓ | por instalar (pyenv) |
| Docker / Compose | — | ✓ | Docker 29.7 disponible |
| Login ACR (`az acr login`) para `mapfre-django-base` | — | ✓ | **necesito acceso**; alternativa local: `python:3.11-slim` solo para desarrollo |
| App registration EntraID (API + SPA + portales) | ✓ | ✓ | a solicitar al equipo |
| Sonar, secretos de los workflows reusables (`GH_TOKEN_ENCRYPTION_PASSPHRASE`, `ACR_TOKEN_*`, `SONAR_*`) | ✓ | ✓ | solo aplican en repos `mapfre-tech` |
| `clai` + skill `django-engineer` | — | ✓ | requiere el mismo PAT de Azure |

**Sin credencial de Azure Artifacts** puedo construir front y back con las dependencias
públicas (Angular 21, Nx, Django, DRF) respetando estructura y convenciones, dejando
*stubs* con la misma interfaz para `ngx-multienvironment`, `nx-angular` executors y las
extensiones `arch-ram-lib-*`; al conseguir el PAT se sustituyen sin cambiar código de
negocio. Lo recomendable es disponer del PAT desde la fase 1.

## 10.7 Fases

| Fase | Contenido | Depende de |
|---|---|---|
| 0. Contrato y datos | `openapi.yaml` desde los CDT `VIDA_API_Life_*`/`TVA_Sesion`; tabla de transiciones de pantallas; extracción de constantes → `tva_parametro`; changelogs Liquibase; fixtures de API Life desde `TVA_MOCK_*` | Volcado Appian (disponible) |
| 1. Esqueletos | Copiar arquetipos a `tva-frontend/` y `tva-backend/` en `feature/tva`; renombrar `app`→`tva`, `product`→`tva`; corregir `settings.py`; Material + OIDC + interceptor; `POST /inicio/*` y `GET /sesiones/{clave}`; lint/test en verde | Validación de este plan; PAT Azure (deseable) |
| 2. Flujo VIA | Selección producto → solicitud → tomador → resumen → firma contra stubs, luego API Life PRE | Fase 1 |
| 3. Flujo VA | Propuesta multiproducto, perfil, test idoneidad/conveniencia, notas | — |
| 4. Rentas R2C | Captura, precios, recálculo, contratación | — |
| 5. Transversales | Diálogos RGPD/cesión/DNI, documentación precontractual, firma manuscrita, póliza | — |
| 6. Admin y batch | Parámetros, apertura/cierre y borrado de trazas (Celery Beat), alertas, Redis | — |
| 7. Convivencia y corte | Feature flag en GV/PFM; retirada Appian | Portales |

Esfuerzo propio estimado: fase 0 ≈ 1 sesión; fase 1 ≈ 1 sesión; fases 2–6 ≈ 5–7 sesiones;
la fase 7 depende de terceros.

## 10.8 Decisiones a validar por el equipo

> **Estado: implementado** con stubs (sin acceso a Azure Artifacts). Las decisiones se aplicaron tal como se propusieron; la guía de despliegue (`11-guia-despliegue.md`) documenta la matriz stub → paquete corporativo para restaurarlas en infraestructura MAPFRE.

1. **Ubicación**: desarrollo en `feature/tva` de este repo como `tva-frontend/` y
   `tva-backend/` (cada uno con la estructura exacta de su arquetipo para poder moverlos a
   repos `mapfre-tech` después). *Propuesta: sí.*
2. **UI kit**: Angular Material 21 (el arquetipo no trae ninguno). *Propuesta: sí.*
3. **Batch**: Celery worker + beat (extensión del arquetipo) vs `management/commands` +
   CronJob. *Propuesta: Celery.*
4. **Extensiones del `pyproject`**: mantener solo observability, auth, httpclient,
   rediscache, celery; eliminar kafkaevent, mongoatlas, storages y django-admin.
   *Propuesta: eliminar.*
5. **Apps Django**: una app `tva` vs separar `rentas`. *Propuesta: una.*
6. **EntraID**: una app registration API (`esp-appianesad-tva`) + una SPA + un cliente
   `client_credentials` por portal. *Requiere alta por el equipo.*
7. **Dependencias `MU_*`/`VIDA_*`/`CMP_*`**: reimplementar dentro de TVA (propuesta) o
   servicio común Vida.
8. **Credencial Azure Artifacts** para instalar paquetes corporativos desde mi máquina,
   o construir con stubs y sustituir después.
