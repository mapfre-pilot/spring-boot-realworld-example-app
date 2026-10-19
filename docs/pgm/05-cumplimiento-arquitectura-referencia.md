# 05 · Cumplimiento de la arquitectura de referencia (KDD review)

Revisión de la rama `feature/pgm` contra los WRK-SPEC congelados `.kdd/WRK-SPEC-NEW-BFF-001.md` (ARCH-FIS-COM-001@1.0.0 · ARQT-SBOOT-001@1.0.1 · BP-API-001@1.0.0) y `.kdd/WRK-SPEC-NEW-SPA-001.md` (ARQT-ANGULAR-001@1.1.0 · BP-API-001@1.0.0), siguiendo la skill `kdd-review`.

Leyenda: ✅ cumple · 🟡 cumple con equivalente abierto (fuera de la red MAPFRE no hay acceso al activo corporativo) · ⛔ pendiente / no verificable desde esta sesión.

## 1. Veredicto

**Approve con reservas**: no hay hallazgos bloqueantes sobre el código. Lo que no cumple al 100 % depende de activos que solo existen dentro de MAPFRE (mapfre-cli/Zeus, Azure Artifacts, imágenes `acrmapfredevops`, App Registration de Entra ID, Backstage, SRE, contratos reales de API Canal) y está anotado como gap en los WRK-SPEC. Al entrar en la organización, los 🟡 se sustituyen sin cambiar el diseño.

## 2. ARQT-SBOOT-001@1.0.1 — `pgm-bff/`

| Criterio | Estado | Evidencia |
|---|---|---|
| Estructura `sources/`, `docker/Dockerfile`, `docker/docker-compose.yml`, `maven/settings.xml`, `sources/pom.xml` | ✅ | `pgm-bff/` (creada a mano porque `mapfre-cli scaffold` no es accesible → 🟡 en el origen, ✅ en el resultado) |
| `mvn clean package` exit 0 desde `sources/` | ✅ | Java 21 / Spring Boot 3.5.6; 16 tests |
| Workflows `.github/workflows/pull-request.yml` y `merge-commit.yml` | 🟡 | Presentes; equivalentes abiertos de `ZeusOneteam-CI-ContainerJava` |
| Onboarding SRE (`ZeusOneteam-OnboardingAWSArqContJava`) | ⛔ | Requiere Zeus; pendiente |
| Liquibase si hay BBDD relacional | n/a | PGM no es dueño de datos: el BFF no tiene BBDD (decisión de `docs/pgm/04`) |
| Log de arranque con URL local, perfil activo y estado del Config Server | ✅ | `PgmBffApplication.trazaArranque` → `pgm-bff listo: url=… perfil=local … configServer=…` |
| `/monitoring/health`, `/monitoring/metrics`, `/monitoring/prometheus` en 200 | ✅ | `ObservabilityEndpointsTest` + arranque real |
| Imagen base corporativa `mapfre-java-base:21-jdk-alpine` | 🟡 | `eclipse-temurin:21-jre-alpine` parametrizable por `RUNTIME_IMAGE` |

## 3. ARQT-ANGULAR-001@1.1.0 — `pgm-spa/`

| Criterio | Estado | Evidencia |
|---|---|---|
| Workspace Nx válido: `nx.json`, `tsconfig.base.json`, `project.json` en raíz (standalone) | ✅ | `pgm-spa/` (Nx 20.8, Angular 19.2) |
| `npm install && npm run build` exit 0 | ✅ | `npx nx build pgm-spa` (production, 365 kB inicial); `.npmrc` con `legacy-peer-deps` en vez de Azure Artifacts (🟡) |
| `npx nx graph` sin ciclos | ✅ | 1 proyecto, 0 dependencias cíclicas |
| Workflow `ZeusOneteam-CI-FrontSPA` | 🟡 | `.github/workflows/pull-request.yml` / `merge-commit.yml` equivalentes (lint + test + build + imagen) |
| Jest + Spectator, `nx test` exit 0 | ✅ | 11 tests (`*.spec.ts` en application/infrastructure/ui) |
| ESLint reglas MAPFRE, `nx lint` exit 0 | 🟡/✅ | ESLint angular-eslint + prefijo `pgm`; las reglas corporativas (`@mapfre-tech/*`) no son accesibles |
| Prettier sin cambios | ✅ | `prettier --check src/**` limpio |
| Librería UI corporativa | 🟡 | Estilos propios en `src/styles.scss` |

## 4. BP-API-001@1.0.0 — ambos

| Criterio | Estado | Evidencia |
|---|---|---|
| Contrato OpenAPI versionado y presente | ✅ | `pgm-bff/sources/src/main/resources/openapi/pgm-bff.yaml` v1.0.0, servido en `/v3/api-docs.yaml`; la SPA consume `/api/v1` con modelos alineados (`domain/models/api.models.ts`) |
| CI: `pull-request.yml` + `merge-commit.yml` | 🟡 | Presentes en ambos componentes (equivalentes abiertos) |
| Auth Entra ID (`consumes_pii: true` → requiere auth) | 🟡 | BFF: resource server JWT (`security.entraid.*`, perfil ≠ local); SPA: OIDC code+PKCE (`angular-oauth2-oidc`). Falta el App Registration real (⛔ tenant/clientId/scope por configuración externa) |
| Observabilidad Java (PAT-OBSERVABILIDAD-JAVA-001) | ✅ | Actuator bajo `/monitoring`, Prometheus, logs JSON con enmascarado de PII (`PiiMasker`), OTLP configurable |
| Registro en Backstage (`catalog-info.yaml`) | 🟡 | `pgm-bff/catalog-info.yaml`, `pgm-spa/catalog-info.yaml` preparados; alta en el catálogo pendiente |
| SonarQube | 🟡 | `sonar-project.properties` en ambos; servidor corporativo pendiente |

## 5. ARCH-FIS-COM-001@1.0.0 — comunicaciones del BFF

| Regla | Estado | Evidencia |
|---|---|---|
| 1 · Síncrono inter-plataforma solo por API Gateway interno | ✅ | Todos los puertos `!local` salen por `pgm.gateway.base-url` (`/apicanal/*`, `/plataformas/*`); ningún host directo |
| 2 · Sin comunicación directa entre namespaces de otros dominios | ✅ | No hay clientes a servicios internos de otros dominios |
| 3 · Sin acceso a BBDD de otras plataformas | ✅ | El BFF no tiene datasource; ningún driver JDBC |
| 4 · Asíncrono inter-plataforma por Kafka | n/a | PGM no publica/consume eventos (sin requisitos asíncronos en el análisis) |
| 5 · EKS↔OpenShift intra-plataforma solo transitorio | n/a | Un solo componente de backend |
| Sin adaptadores legacy (ESB/SOAP/Denodo/API Clientes legacy) — exigencia del usuario | ✅ | `docs/pgm/03-mapeo-api-canal.md` §5; sin dependencias SOAP/JDBC en `pom.xml` |

## 6. Gates de aplicación (ejecutados en la sesión)

| Comando | Resultado |
|---|---|
| `pgm-bff/sources: mvn clean package` | exit 0 · 16 tests |
| `pgm-spa: npx nx lint pgm-spa` | exit 0 |
| `pgm-spa: npx nx test pgm-spa` | exit 0 · 11 tests |
| `pgm-spa: npx nx build pgm-spa` (production) | exit 0 |
| `pgm-spa: npx prettier --check` | exit 0 |
| `docker compose -f pgm/docker-compose.yml build && up` | imágenes `pgm-bff:local`, `pgm-spa:local`; SPA en :4200 proxied al BFF |
| e2e en navegador (Playwright sobre la SPA + BFF local) | 14 flujos OK (búsqueda, ficha 360, Vto./Ppto. + tarificación Salud + borrador, gestión comercial, CdM, lanzaderas, recibos, 404 RFC 9457) |
| `spec-graph validate` (grafo KDD) | 0 errores · 366 warnings (baseline de `develop`) |

## 7. Trust y trazabilidad

- WRK-SPEC con `activation_frozen: true`, pins `ID@version` existentes en el grafo, `generated.by: devin/session-…`, sin `verified` (lo firma una persona), `bootstrap_state: completed`.
- Copias `.kdd/` idénticas en frontmatter a las canónicas de `kdd-mapfre-docs/work/` (sin commit en el repo KDD: requiere confirmación).
- Pendiente del ciclo HARN-KDD-001: PR de `feature/pgm` y `spec-consolidate` (ADR de "BFF sin BBDD / PGM solo caché", propuesta de specs para la plataforma Canales y Clientes, feedback de capacidades API Canal que faltan). Ambos requieren confirmación del usuario.
