# 10. Plan de migración TVA basado en los arquetipos de Arquitectura España

Revisión del plan del documento 09 adaptada a los dos arquetipos corporativos indicados
por el equipo: **Arquetipo Angular (Arquitectura de Referencia Angular, v1)** para el SPA y
**Arquetipo Contenedores Python Django (v1)** para el backend. Sustituye la propuesta
Spring Boot del documento 09; el mapeo funcional de TVA (pantallas, procesos,
integraciones, datos) del documento 09 se mantiene y aquí se indica cómo se aterriza en
cada arquetipo.

> **Estado: borrador pendiente de validación.** Las secciones marcadas con `[ZIP]`
> dependen del contenido real de los arquetipos (documentos Appian TEST
> `…_5463656` y `…_5463643`), que en el momento de redactar no se han podido descargar
> (HTTP 401). Lo que no lleva la marca procede de la documentación de Marketplace
> aportada por el equipo o del análisis de TVA (docs 01–08). No se ha iniciado ninguna
> construcción.

## 10.1 Resumen de los arquetipos (según la documentación aportada)

### Frontend — Arquitectura de Referencia Angular

| Aspecto | Valor documentado |
|---|---|
| Requisitos de desarrollo | Git, **Node 22+** (vía `nvm`), **pnpm 11+** (gestor del arquetipo v1), VS Code, GitHub CLI (`gh`) |
| Acceso | Organización GitHub `mapfre-tech`; PAT para Git por HTTPS (`gh auth login`) |
| Registro de paquetes | Paquetes de la Arquitectura de Referencia publicados en un **registro npm privado de Azure Artifacts**; pnpm se autentica con `~/.npmrc` |
| Secciones de la guía | Flujo de desarrollo, Fundamentos, Escenarios de desarrollo, Aplicación Angular, **Microfrontend**, Librería Angular, Herramientas de desarrollo, Testing y Calidad, Release, CI/CD, Guías de desarrollo |
| Sistema operativo indicado | macOS Tahoe (26) como referencia del equipo; no es requisito técnico del arquetipo |

`[ZIP]` Pendiente de confirmar en el arquetipo: versión de Angular, si el scaffolding es
Nx/workspace o `angular.json` simple, si incluye Angular Material o un design system
propio de la Arquitectura de Referencia (paquetes `@mapfre-*` en Azure Artifacts),
librerías de estado/i18n/HTTP que trae, linters, runner de tests, e2e y workflows
`.github/workflows`.

### Backend — Arquetipo Contenedores Python Django

| Aspecto | Valor documentado |
|---|---|
| Propósito | Microservicios **Python + Django** dentro de la arquitectura de contenedores |
| Versión | Arquetipo **v1**; anexo de migración a **Django 5.2** |
| Herramientas | Docker ≥ 28.2.1, Docker Compose ≥ 2.37, Git ≥ 2.49, VS Code ≥ 1.100, Postman ≥ 10, **Python 3.11**, **Poetry** |
| Arranque local | `.env` a partir de `.env.sample` (valores `CHANGEME` = secretos); `docker compose -f docker/docker-compose.yml up`; `python manage.py runserver 0:8888`; depuración con `ipdb` |
| Estilo | PEP 8, PEP 257 (docstrings), typing |
| Imagen base | Imagen corporativa que fija versión de Python, certificados, variables de entorno y librerías de sistema; actúa como *builder* de la imagen del componente |
| Observabilidad (**requerida** en el preset España) | `arch-ram-lib-django-observability` (logging JSON, trazas OpenTelemetry, métricas Prometheus). OpenSearch/ArgoCD para logs, Grafana para trazas y métricas |
| Seguridad | OAuth obligatorio con **EntraID** (u Okta). Extensión con validación JWT vía JWK Set URI, claims, scopes por endpoint y CORS. Requiere crear la aplicación de EntraID del producto |
| Cliente HTTP | Extensión con Basic, JWT, OAuth2, OBO; clase base de integración por *location*; credenciales en YAML; utilidades JSONPath/XML |
| Redis cache | Extensión integrada en el cache de Django, TTL global/por método, decoradores |
| Kafka | Extensión para Confluent Kafka (producers/consumers, Schema Registry/Avro, DLQ) |
| BBDD relacional | ORM Django contra Postgres/MySQL. **Las migraciones las gestiona el componente de BBDD relacional con Liquibase**, no Django |
| BBDD no relacional | Extensión MongoAtlas (mongoengine) |
| Storage | Extensión S3 / FTP / SFTP (boto3) |
| Tareas asíncronas | Extensión Celery + Celery Beat |
| Django Admin | Extensión con login EntraID y estáticos en S3; requiere habilitar migraciones Django vía issue a DevOps |
| Testing y calidad | `poetry run pytest` desde `sources/`; contratos OpenAPI v3 validados (API First); **SonarQube** en CI |
| Documentación | README con estructura estándar; `drf-spectacular` expone `/docs/swagger` |
| CI/CD | GitHub Actions con workflows reusables (GitFlow sobre `develop`/`main`): `pull-request.yml` (tests, imagen, Sonar) y `merge-commit.yml` (imagen → ACR, siguiente versión) |
| Limitación declarada | API First: no hay generación automática de código desde OpenAPI en Django |

Scaffolding documentado del backend:

```
.
├── .github/workflows/{pull-request.yml, merge-commit.yml}
├── docker/{docker-compose.yml, Dockerfile, .dockerignore}
├── sources/
│   ├── apps/<app>/
│   │   ├── management/commands/   procesos que necesitan contexto Django (consumidores, batch)
│   │   ├── operators/             lógica de negocio y transformación
│   │   ├── schemas/               respuestas y códigos de error OpenAPI
│   │   ├── serializers/           validación de entrada/salida
│   │   ├── services/connectors/   integración con servicios externos que consume la app
│   │   ├── services/providers/    servicios externos expuestos/consumidos
│   │   ├── tasks/                 tareas asíncronas (Celery)
│   │   ├── tests/
│   │   ├── views/                 vistas asociadas a urls
│   │   ├── utils/
│   │   ├── apps.py · urls.py
│   ├── config/{settings.py, urls.py, wsgi.py}
│   ├── .pre-commit-config.yaml · manage.py · poetry.lock · pyproject.toml
├── .gitignore · README.md · security-metadata.toml
```

`[ZIP]` Pendiente de confirmar: versiones exactas en `pyproject.toml` (Django, DRF,
drf-spectacular, extensiones `arch-ram-lib-*`), contenido de `settings.py`, `.env.sample`,
Dockerfile/imagen base, `security-metadata.toml`, y los inputs de los workflows reusables.

## 10.2 Qué cambia respecto al plan del documento 09

| Tema | Doc 09 | Plan con arquetipos |
|---|---|---|
| Backend | Spring Boot 3 / Java 21 | **Django 5.x / Python 3.11** con el arquetipo de contenedores y sus extensiones |
| Estructura backend | `api / application / core / infrastructure` | `views / serializers / schemas / operators / services(connectors, providers) / tasks / management.commands` del arquetipo |
| Persistencia | JPA/MyBatis + Flyway | ORM Django; **DDL con Liquibase** en el componente de BBDD (sin migraciones Django salvo Django Admin) |
| Cliente HTTP a API Life / MISV / RIC | WebClient + Resilience4j | Extensión de cliente HTTP del arquetipo (Basic/JWT/OAuth2/OBO, credenciales en YAML) |
| Seguridad | Spring Security OAuth2 Resource Server | Extensión OAuth del arquetipo contra **EntraID** (JWT, scopes por endpoint, CORS) |
| Caché de configuración de producto | Caffeine/Spring Cache | Extensión **Redis** del arquetipo |
| Batch (apertura/cierre, borrado trazas, alertas) | `@Scheduled` | **Celery Beat** (extensión) o `management/commands` lanzados por cron del cluster |
| Observabilidad | Micrometer/Actuator | `arch-ram-lib-django-observability` (obligatoria): OpenSearch, Grafana |
| OpenAPI | springdoc | Contrato OpenAPI v3 escrito a mano (API First) + `drf-spectacular` para publicar `/docs/swagger`; generación del cliente TypeScript desde el contrato |
| Frontend | Angular 19 + Material, npm | Arquetipo Angular v1 con **pnpm 11+**, paquetes de Azure Artifacts, `[ZIP]` UI kit y versión Angular según arquetipo |
| CI/CD | Propuesta genérica | Workflows reusables corporativos (`pull-request.yml`, `merge-commit.yml`), GitFlow `develop`/`main`, SonarQube, imagen a ACR |
| Repositorios | Monorepo en este repo | **Dos repositorios generados desde Marketplace** (wizard) en `mapfre-tech`: `tva-frontend` y `tva-backend` `[a validar]` |

Se mantiene íntegro del documento 09: la tabla "qué se migra y qué no" (9.1), el mapeo
de interfaces Appian → features Angular (9.3), la lista de casos de uso derivados de los
28 procesos (9.4), el modelo de datos `tva_sesion / tva_traza / tva_parametro` (9.4) y
los riesgos (9.6).

## 10.3 Arquitectura objetivo

```
Portal GV / PFM ──POST /api/tva/v1/inicio/*──▶ ┌──────────────────────────────────┐
                                                │ tva-backend (Django, contenedor) │
Navegador ──▶ tva-frontend (Angular) ──REST/JWT▶│ views · serializers · operators  │──▶ API Life / SBC / MISV / RIC
              arquetipo Angular v1              │ services.connectors (cliente HTTP│──▶ PostgreSQL (RDS)  ← DDL Liquibase
              pnpm · Azure Artifacts            │ arquetipo) · tasks (Celery)      │──▶ Redis (caché taller/productos)
                                                │ observabilidad · OAuth EntraID   │──▶ SMTP / notificaciones (alertas)
                                                └──────────────────────────────────┘
                      ▲                                        ▲
                      └──────────────── EntraID (OIDC) ────────┘
```

Principios (iguales a 9.2): el backend es la fuente de verdad de la sesión, orquesta los
casos de uso (uno por proceso Appian) y es el único que habla con API Life/MISV/RIC; el
front solo consume `tva-backend` con el JWT de EntraID.

## 10.4 Backend Django — aterrizaje de TVA en el arquetipo

Una única app Django `tva` (o varias si el equipo prefiere separar `rentas`) dentro de
`sources/apps/`:

```
sources/apps/tva/
├── views/         inicio.py (POST /inicio/ahorro, /inicio/rentas — portales)
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
├── services/connectors/  apilife.py (16 endpoints TVA_API_Life_*), sbc.py, misv.py, ric.py, perfil_usuario.py (SOAP)
├── models/        Sesion (JSONField + version_esquema + pantalla_actual + usuario), Traza, Parametro
├── tasks/         apertura_cierre.py, borrar_trazas.py, alertas.py  (Celery Beat)
├── management/commands/  cargar_parametros.py (extracción de las ~200 constantes Appian)
└── tests/         unit (operators, validaciones), integración con stubs de API Life
```

Decisiones de diseño derivadas del arquetipo:

- **Sesión** en `JSONField` de PostgreSQL con `version_esquema` (resuelve A2/A3/M10 de
  07-mejoras) y vinculada al `sub`/`oid` del JWT de EntraID: solo el propietario o un
  admin la recupera (resuelve el riesgo de acceso por `claveSesion`).
- **DDL** (`tva_sesion`, `tva_traza`, `tva_parametro`) como changelogs **Liquibase** en el
  componente de BBDD relacional, según exige el arquetipo; los modelos Django se declaran
  `managed = False` salvo que se habilite Django Admin.
- **Credenciales** de API Life/MISV/BD: YAML de la extensión de cliente HTTP + variables
  `.env`/secretos del cluster. Desaparece `TVA_Conectar_ContrasennaUsuarioVida` (A1).
- **Caché** del taller (`VIDA_ObtenerConfiguracionProductoComercial`, listas de productos)
  con la extensión Redis y TTL; sustituye la pantalla de cachés Appian por un endpoint admin.
- **Batch**: apertura/cierre programado y borrado de trazas como tareas Celery Beat
  (crontab); alertas por email como tarea. Alternativa: `management/commands` + CronJob
  de Kubernetes si el producto no despliega worker Celery `[a validar]`.
- **Portales GV/PFM**: endpoints `/inicio/*` protegidos con scope propio
  (`client_credentials` en EntraID por portal), sustituyendo al grupo `TVA WebApi Inicio`.
- **Observabilidad**: la extensión obligatoria reemplaza `MU_Traza*`/`TVA_LogAplicacion`;
  `claveSesion` viaja como atributo de traza/log para correlación.
- **API First**: `openapi.yaml` versionado en el repo, validado en CI; `drf-spectacular`
  solo para publicar. Del contrato se genera el cliente TypeScript del front
  (`openapi-generator`/`orval`, `[ZIP]` según lo que traiga el arquetipo Angular).

## 10.5 Frontend Angular — aterrizaje en el arquetipo

Se conserva el mapeo de features del documento 09 (shell, productos, solicitud, tomador,
rentas, resumen, diálogos, admin, shared/ui). Ajustes al arquetipo:

- Proyecto generado con el wizard del arquetipo Angular v1 (`pnpm`), no con `ng new`.
- `[ZIP]` **UI kit**: si el arquetipo provee un design system corporativo (paquetes en
  Azure Artifacts), los equivalentes de `MU_TextField`, `MU_Dropdown`, `MU_Aviso` se
  construyen sobre él; Angular Material solo si el arquetipo lo incluye o lo permite.
- `[ZIP]` **Estado / HTTP / i18n / auth**: usar las librerías que el arquetipo trae
  (interceptor de token EntraID, manejo de errores, configuración por entorno) antes que
  las propuestas genéricas de 9.3 (Signal Store, Transloco).
- **Microfrontend**: la guía tiene sección propia. Propuesta: TVA como **aplicación
  Angular standalone** en fase inicial; evaluar exponerlo como microfrontend si los
  portales GV/PFM son ya *shells* de la Arquitectura de Referencia `[a validar]`.
- Autenticación: OIDC contra EntraID (misma app registration que el backend o app
  cliente separada `[a validar]`), roles `TVA_USUARIO`, `TVA_ADMIN_PORTAL`, `TVA_DEBUG`
  como grupos/app roles de EntraID.
- Testing y calidad según la guía "Testing y Calidad" del arquetipo (`[ZIP]` runner y e2e
  concretos); SonarQube en CI.

## 10.6 Requisitos de entorno

| Herramienta | Front | Back | Estado en mi máquina |
|---|---|---|---|
| Git ≥ 2.49 | ✓ | ✓ | disponible |
| Node 22+ (nvm) | ✓ | — | Node 24 (compatible; instalar 22 LTS vía nvm si el arquetipo lo fija) |
| pnpm 11+ | ✓ | — | por instalar |
| GitHub CLI + PAT `mapfre-tech` | ✓ | ✓ | **necesito acceso a la organización `mapfre-tech`** |
| `~/.npmrc` Azure Artifacts | ✓ | — | **necesito credencial del feed** |
| Python 3.11 + Poetry | — | ✓ | por instalar (3.11 concreto) |
| Docker ≥ 28.2 / Compose ≥ 2.37 | — | ✓ | Docker 29.7 disponible |
| Acceso a imagen base corporativa (registry) | — | ✓ | **necesito acceso al registry** |
| Paquetes `arch-ram-lib-*` (Azure Artifacts PyPI) | — | ✓ | **necesito credencial del feed** |
| App registration EntraID (TVA) | ✓ | ✓ | a solicitar al equipo |
| SonarQube (alta de la app) | ✓ | ✓ | a solicitar |
| Postman ≥ 10, VS Code | opcional | opcional | — |

## 10.7 Fases

| Fase | Contenido | Depende de |
|---|---|---|
| 0. Contrato y datos | `openapi.yaml` de `tva-backend` desde los CDT `VIDA_API_Life_*`/`TVA_Sesion`; tabla de transiciones de pantallas; extracción de constantes → `tva_parametro`; changelogs Liquibase; fixtures de API Life desde `TVA_MOCK_*` | Volcado Appian (ya disponible) |
| 1. Esqueletos desde los arquetipos | Generar `tva-frontend` y `tva-backend` con los wizards; CI reusable en verde; observabilidad, OAuth EntraID y cliente HTTP configurados; shell Angular + `SesionStore`; `POST /inicio/*` y `GET /sesiones/{clave}` | ZIP/wizard, acceso `mapfre-tech`, Azure Artifacts, EntraID |
| 2. Flujo VIA | Selección producto → solicitud → tomador → resumen → firma contra stubs, luego API Life PRE | Fase 1 |
| 3. Flujo VA | Propuesta multiproducto, perfil, test idoneidad/conveniencia, notas | — |
| 4. Rentas R2C | Captura, precios, recálculo, contratación | — |
| 5. Transversales | Diálogos RGPD/cesión/DNI, documentación precontractual, firma manuscrita, póliza | — |
| 6. Admin y batch | Parámetros, apertura/cierre y borrado de trazas (Celery Beat), alertas, Redis | — |
| 7. Convivencia y corte | Feature flag en GV/PFM; retirada Appian | Portales |

Esfuerzo propio estimado: fase 0 ≈ 1 sesión; fase 1 ≈ 1 sesión una vez tenga accesos;
fases 2–6 ≈ 5–7 sesiones; la fase 7 depende de terceros. Sin acceso a Azure Artifacts,
imagen base y EntraID puedo prototipar con stubs locales, pero el resultado **no** sería
el arquetipo real.

## 10.8 Decisiones a validar por el equipo

1. Un repo por componente (`tva-frontend`, `tva-backend`) en `mapfre-tech` generados por
   Marketplace, frente a construir aquí en `feature/tva`.
2. UI kit: design system del arquetipo vs Angular Material (según `[ZIP]`).
3. Batch con Celery Beat (worker adicional) vs `management/commands` + CronJob.
4. Una app Django `tva` vs separar `rentas`.
5. Django Admin: no usarlo (evita migraciones Django y estáticos S3) y resolver la
   administración en el SPA `/admin` — propuesta por defecto.
6. Registro EntraID: una app para back + una SPA cliente, y `client_credentials` por portal.
7. Alcance de la migración de dependencias `MU_*`/`VIDA_*`/`CMP_*`: reimplementar en TVA
   o servicio común Vida.
8. Confirmar que los documentos Appian `…_5463656` / `…_5463643` son front y back
   respectivamente (o al revés) una vez descargados.
