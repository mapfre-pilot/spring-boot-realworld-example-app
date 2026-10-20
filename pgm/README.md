# PGM — Posición Global MAPFRE en la arquitectura de referencia

Migración de la aplicación Appian `PGM_MAPFRE` a **SPA Angular + BFF Spring Boot sobre API Canal / API Gateway**, construida con el harness KDD (`.kdd/WRK-SPEC-NEW-SPA-001.md`, `.kdd/WRK-SPEC-NEW-BFF-001.md`). El análisis funcional/técnico y el mapeo a API Canal están en `docs/pgm/`.

| Componente | Ruta | Stack | Specs |
|---|---|---|---|
| BFF | `pgm-bff/` | Spring Boot 3.5 · Java 21 · hexagonal · OpenAPI-first (`/api/v1`) | ARQT-SBOOT-001@1.0.1 · BP-API-001@1.0.0 · ARCH-FIS-COM-001@1.0.0 |
| SPA | `pgm-spa/` | Angular 19 · Nx 20 · standalone · signals · Jest + Spectator | ARQT-ANGULAR-001@1.1.0 · BP-API-001@1.0.0 |

## 1. Descarga

```bash
git clone -b feature/pgm https://github.com/mapfre-pilot/spring-boot-realworld-example-app.git
cd spring-boot-realworld-example-app
```
(o *Code → Download ZIP* de la rama `feature/pgm` y descomprimir).

## 2. Arranque rápido con Docker (Windows / macOS / Linux)

Requisito: Docker Desktop.

```bash
docker compose -f pgm/docker-compose.yml up --build
```

- SPA: <http://localhost:4200>
- BFF: <http://localhost:8080> · salud <http://localhost:8080/monitoring/health> · OpenAPI <http://localhost:8080/v3/api-docs.yaml>

El perfil `local` no necesita credenciales ni red MAPFRE: el BFF sirve **datos sintéticos** (ningún dato real de cliente) y la SPA no pide login (usuario mock `usuario.local`).

### 2.b Arranque con Podman (Windows)

Requisitos: [Podman Desktop](https://podman-desktop.io/) o Podman CLI ≥ 4.x con la extensión *Compose* (proveedor `docker-compose` o `podman-compose`).

```powershell
podman machine init                       # solo la primera vez
podman machine start
cd spring-boot-realworld-example-app
podman compose -f pgm/docker-compose.yml up --build
```

- Si `podman compose` dice que no encuentra proveedor: `pip install podman-compose` y repite, o `winget install Docker.DockerCompose` (solo el binario de compose, sin Docker Desktop).
- Alternativa sin compose:
  ```powershell
  podman network create pgm
  podman build -t pgm-bff:local -f pgm-bff/docker/Dockerfile pgm-bff
  podman build -t pgm-spa:local -f pgm-spa/docker/Dockerfile pgm-spa
  podman run -d --name bff --network pgm -p 8080:8080 pgm-bff:local
  podman run -d --name spa --network pgm -p 4200:8080 -e BFF_URL=http://bff:8080 pgm-spa:local
  ```
- Error `unable to retrieve auth token: invalid username/password` al bajar imágenes de Docker Hub: Podman está usando un login caducado (habitual con Rancher Desktop). `podman logout --all` y reintentar; si persiste, borrar las entradas `docker.io` / `index.docker.io` del Administrador de credenciales de Windows y las `auths` de `%USERPROFILE%\.docker\config.json`. Alternativa: apuntar las imágenes base al mirror público de AWS (`$env:BUILD_IMAGE`, `$env:RUNTIME_IMAGE`, `$env:NODE_IMAGE`, `$env:NGINX_IMAGE`, ver más abajo).
- Las imágenes no requieren root (usuarios `app`/`nginx` no privilegiados, puertos internos 8080): funcionan en modo rootless. Para parar: `podman compose -f pgm/docker-compose.yml down` (o `podman rm -f spa bff`).
- Primer build: ~5–8 min (descarga Maven/npm). Si la red corporativa corta registries públicos, configura el proxy en `podman machine ssh` o usa el arranque manual del §3.
- Imágenes base y mirror Maven configurables por variables de entorno (sirven para Docker y Podman): `NODE_IMAGE`, `NGINX_IMAGE`, `MAVEN_MIRROR` y para el BFF `BUILD_IMAGE`, `RUNTIME_IMAGE`. Ejemplo con el mirror público de AWS (si Docker Hub falla por credenciales o 429):
  ```powershell
  $env:BUILD_IMAGE="public.ecr.aws/docker/library/maven:3.9.11-eclipse-temurin-21-alpine"
  $env:RUNTIME_IMAGE="public.ecr.aws/docker/library/eclipse-temurin:21-jre-alpine"
  $env:NODE_IMAGE="public.ecr.aws/docker/library/node:22-alpine"
  $env:NGINX_IMAGE="public.ecr.aws/nginx/nginx-unprivileged:1.27-alpine"
  podman compose -f pgm/docker-compose.yml up --build
  ```
  Dentro de MAPFRE, las mismas variables sirven para las imágenes de `acrmapfredevops` y `MAVEN_MIRROR` para Azure Artifacts.

### 2.c Actualizar (rebuild) en Podman tras descargar una versión nueva

```powershell
cd pgm-feature-pgm                                  # carpeta donde has descomprimido el ZIP nuevo (sobrescribe la anterior)
podman compose -f pgm/docker-compose.yml down       # para y elimina los contenedores anteriores
podman compose -f pgm/docker-compose.yml build --no-cache bff spa
podman compose -f pgm/docker-compose.yml up
```
Si usaste las variables `BUILD_IMAGE`/`RUNTIME_IMAGE`/`NODE_IMAGE`/`NGINX_IMAGE` (mirror de AWS), vuelve a exportarlas en la misma consola antes del `build`. Para limpiar imágenes huérfanas: `podman image prune -f`. Comprobación: http://localhost:8080/monitoring/health devuelve `{"status":"UP"}` y http://localhost:4200 muestra el buscador.

### Perfil simulador (adaptadores reales contra un Gateway simulado)

El perfil `simulador` mantiene los adaptadores reales del BFF y dirige sus llamadas a WireMock con respuestas sintéticas:

```bash
docker compose -f pgm/docker-compose.yml --profile simulador up --build
```

## 3. Arranque manual (desarrollo)

Requisitos: JDK 21, Maven 3.9+, Node.js 22+ (probado con 24), npm 10. `pgm-spa/.npmrc` fija `legacy-peer-deps=true` (necesario para Spectator 18 con Angular 19).

```powershell
# BFF
cd pgm-bff\sources
mvn clean package
java -jar target\pgm-bff-0.1.0-SNAPSHOT.jar          # perfil local por defecto → http://localhost:8080

# SPA (otra consola)
cd pgm-spa
npm ci
npx nx serve pgm-spa                                 # http://localhost:4200, proxy /api → :8080 (proxy.conf.json)
```

Checks: `mvn test` (BFF, 16 tests), `npx nx test pgm-spa`, `npx nx lint pgm-spa`, `npx nx build pgm-spa`.

## 4. Qué probar (datos sintéticos del perfil local)

| Cliente | Caso | Qué ver |
|---|---|---|
| `C-1001` · Laura Martín Serrano · 00000001R | Particular en vigor, 4 pólizas (Autos, Hogar, Salud, Vida), alertas, familia, En Familia | Ficha 360, tarjetas por ramo, recibos, prestaciones, Vto./Ppto. con tarificación Salud |
| `C-1002` · Pablo Martín Serrano · 00000002W (autónomo VIP) | Descuento de vinculación, plan de pagos | Chips VIP / Dto. vinculación |
| `C-1003` · Construcciones Ejemplo S.L. · B00000003 | Tipología empresa | Chip *Exclusivo corredor* |
| `C-1004` · José María García García · 00000004A (potencial Robinson) | Sin pólizas, sin RGPD | Ficha potencial, palancas en rojo |
| `C-1005` · Carmen López Ruiz · X0000005T | Pólizas anuladas | Filtro *Productos anulados* |

Búsqueda: por nombre (`Martín` devuelve 2; `García` abre directamente la ficha al ser único), documento, teléfono, e-mail, póliza, tarjeta sanitaria o localidad (`Madrid`). Sin criterios → error 400 RFC 9457.

Usuarios del perfil local (cabecera `X-Usuario-Local` o `pgm.local.usuario-por-defecto` en `application-local.yml`):

| Usuario | Perfiles | SGC 3.0 / NUUMA | Efecto en la SPA |
|---|---|---|---|
| `usuario.local` (defecto) | USUARIO, ASESOR_COMERCIAL, VISUALIZAR_CDM | ASESOR / NU000001 | Todo visible, incl. Gestiones y Actividad comercial |
| `gestor.sin.nuuma` | USUARIO, ASESOR_COMERCIAL | — | Gestión comercial degradada (como en Appian sin NUUMA) |
| `director.oficina` | USUARIO, ASESOR_COMERCIAL, VISUALIZAR_CDM | DIRECTOR / NU000002 | Cuadro de mando |

## 5. Entornos corporativos

- **Seguridad**: perfil ≠ `local` → la SPA hace OIDC (code + PKCE) contra Entra ID (`pgm-spa/src/environments/environment.ts`) y el BFF valida el JWT (`security.entraid.*` en `application.yml`); scope `SCOPE_<security.entraid.scope>`.
- **Destinos del BFF**: solo API Canal (Clientes, Pólizas, Recibos, Siniestros, Ventas) y APIs de plataforma (PGO, SGC 3.0, iMediador, SGO, Comunicaciones) **a través del API Gateway** (`pgm.gateway.*`). No hay adaptadores a ESB/SOAP/Denodo/API Clientes legacy.
- **Observabilidad**: logs JSON sin PII (enmascarado de NIF/IBAN/e-mail/teléfono), OTLP (`OTEL_EXPORTER_OTLP_ENDPOINT`), Prometheus en `/monitoring/prometheus`.

## 6. Gaps respecto al arquetipo corporativo (documentados en los WRK-SPEC)

- `mapfre-cli` / Zeus / Backstage no accesibles desde esta sesión → esqueletos creados a mano con la estructura de ARQT-SBOOT-001 / ARQT-ANGULAR-001; workflows en `.github/workflows/` son equivalentes abiertos de `ZeusOneteam-CI-*`.
- Imágenes base `acrmapfredevops` sustituidas por Temurin / nginx-unprivileged; librería UI corporativa no accesible → estilos propios.
- Contratos reales de API Canal/plataformas tras el Gateway pendientes de publicación (PCC): los paths de `application.yml` son los propuestos en `docs/pgm/03-mapeo-api-canal.md`.
- Plataforma funcional *Canales y Clientes* sin specs en el grafo KDD (WRK-SPEC con `platform: standalone`).
