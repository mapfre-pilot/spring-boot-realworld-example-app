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

## 3. Arranque manual (desarrollo)

Requisitos: JDK 21, Maven 3.9+, Node.js 22+ (probado con 24), npm 10.

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
