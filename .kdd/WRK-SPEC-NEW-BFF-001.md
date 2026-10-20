---
id: WRK-SPEC-NEW-BFF-001
type: spec
layer: work-spec
scope: ephemeral
status: draft
version: 0.1.0
created: "2026-10-19"
updated: "2026-10-19"
owner: ggalv10
generated:
  by: devin/session-bd30d5222e1d49f685a1fc534d35b644
  at: "2026-10-20T07:43:44Z"
task_type: new-bff
manifest_used: MFST-NEW-BFF-001@1.2.0
parameters:
  archetype: sboot
  platform: standalone
  target_channel: spa
  consumes_pii: true
  paired_with_spa: MFST-NEW-SPA-001
activates:
  - ARCH-FIS-COM-001@1.0.0
  - ARQT-SBOOT-001@1.0.1
  - BP-API-001@1.0.0
suggested: []
activation_frozen: true
activation_resolved_at: "2026-10-19T18:21:47.810Z"
bootstrap_state: completed
tags:
  - work-spec
  - new-bff
---

# WRK-SPEC-NEW-BFF-001 — BFF PGM (migración PGM_MAPFRE Appian → arquitectura de referencia)
## Intent
Sustituir la orquestación Appian de la visión 360 de PGM por un BFF Spring Boot que consume API Canal y APIs de plataforma por API Gateway, sin servicios legacy
## Knowledge Context
Specs activadas (congeladas desde `MFST-NEW-BFF-001@1.2.0`):
- ARCH-FIS-COM-001@1.0.0
- ARQT-SBOOT-001@1.0.1
- BP-API-001@1.0.0
## Parameters
Resueltos por el router; congelados con `activation_frozen: true`.
```json
{
  "archetype": "sboot",
  "platform": "standalone",
  "target_channel": "spa",
  "consumes_pii": true,
  "paired_with_spa": "MFST-NEW-SPA-001"
}
```
## Problem Statement
`PGM_MAPFRE` (Appian TEST, 2.986 objetos) es el frontal de oficinas con la visión 360 del cliente. Hoy la propia pantalla SAIL o un modelo de proceso llama directamente a 211 integraciones (API Clientes legacy `mrcconsultaback`/`apisb…/clients/1.0`, Health/Life/Home/Motor API, gesycore/GESYC y ATN por ESB SOAP, SGO por webMethods, PGO `/apipgo`, SGC 3.0, iMediador, Denodo, Citrix…), agrega la visión 360 en Appian (`PGM_CompletarInfoCliente`) y cachea PII en PostgreSQL (`pgm_r_cliente_tmp`, borrado cada 10 min). `ARCH-APICANAL-001` prohíbe que un canal consuma legacy o APIs de plataforma sin pasar por `PROD-APICANAL-*` y asigna a PGM un BFF propio. Análisis completo en `docs/pgm/` (02-analisis-tecnico, 03-mapeo-api-canal).

## Proposed Change
`pgm-bff` (Spring Boot 3 / Java 21, `ARQT-SBOOT-001`, `BP-API-001`) emparejado con `WRK-SPEC-NEW-SPA-001`:
- Contrato OpenAPI 3 primero, `/api/v1`: `GET /clientes/search` (búsqueda federada), `GET /clientes/{id}/ficha|productos|recibos|prestaciones|gestiones|oportunidades|presupuestos`, `GET /polizas/{id}`, `GET /recibos/{id}`, `GET /lanzaderas`, `POST /tarificacion/salud` (+ borradores), `POST /auditoria`.
- Hexagonal: casos de uso por pestaña de la ficha; puertos de salida `ClientesPort`, `PolizasPort`, `RecibosPort`, `SiniestrosPort`, `VentasPort` (adaptadores a `PROD-APICANAL-*`), `OportunidadesPort` (PGO), `GestionComercialPort` (SGC 3.0 / iMediador), `SgoPort`, `ComunicacionesPort` — todos por API Gateway interno con s2s por tenant (`ARCH-FIS-COM-001`). Ningún adaptador a ESB/SOAP/Denodo/core: lo que API Canal no cubre se solicita a PCC (docs/pgm/03 §3) y hasta entonces lo sigue sirviendo Appian (strangler).
- Autorización fina en el BFF: grupo Entra ID (perfil) × estructura comercial (oficina/delegado/NUUMA) × feature flags (pilotos); auditoría de accesos por NUUMA.
- Sin caché de datos de cliente (lo cachea API Canal/ODL); almacén ligero opcional (Redis/Mongo Atlas) solo para borradores de tarificación y estado de diálogos.
- Resiliencia de cliente HTTP (timeouts, retries idempotentes, circuit breaker), logs JSON sin PII, OTLP, Prometheus; métricas de negocio sustituyen al cuadro de mando Appian.

## Constraints
- `ARQT-SBOOT-001`: estructura `sources/`, `docker/`, `maven/settings.xml`, workflows `pull-request.yml`/`merge-commit.yml`, starters logging/telemetry/monitoring España, `mvn clean package` exit 0, OAuth2 Entra ID.
- `BP-API-001`: OpenAPI-first, `catalog-info.yaml`, SonarQube quality gate, observabilidad estándar.
- `ARCH-FIS-COM-001`: inter-plataforma solo vía API Gateway interno del destino; sin acceso a BBDD ajenas.
- `ARCH-APICANAL-001` (contexto, draft/low): el BFF no cachea lo que cachea API Canal; lógica de activo en BFF; terceros (Verti, Santander, SAVIA) vía BFP.
- PII (NIF, contacto, salud, posición bancaria): sin persistencia propia ni en logs.
- No modificar Appian durante el análisis; convivencia con el site Appian por fases.

## Acceptance Criteria
- [ ] Ninguna llamada del componente a ESB/SOAP/Denodo/core legacy: solo `PROD-APICANAL-*` y APIs de plataforma por API Gateway (`ARCH-APICANAL-001` AC1).
- [ ] Bootstrap ejecutado (`bootstrap_state: completed`) y outputs registrados.
- [ ] Implementación alineada con todas las specs Tier 1+2 activadas.
## Open Questions
- Plataforma: PGM pertenece a la plataforma **Canales y Clientes**, que aún no tiene `PLAT-FUNC-*`/`PROD-*` en el grafo; se usa `platform: standalone` (misma activación que `PGO`). Gap: crear `PLAT-FUNC-CYC-001` y `PROD-CYC-PGM-*`.
- `consumes_pii: true` no cambia la activación (gap del manifest).
- Dominios sin `PROD-APICANAL-*`: PGO (oportunidades), SGC 3.0, iMediador/estructura comercial, SGO, ACI/Club MAPFRE, consentimientos, comunicaciones: ¿nuevos productos API Canal o API de plataforma por Gateway? Decisión con PCC/Arquitectura.
- Capacidades a solicitar a API Canal: búsqueda por matrícula/recibo/presupuesto/expediente; alertas, interacciones, encuestas, reclamaciones, integralidad; operativas de recibos (cobro, agrupación, envío al banco, duplicados) y de pólizas (anulación, duplicados); listado de presupuestos por cliente.
- Modelo de autorización: grupos Entra ID vs claims de estructura comercial; servicio de perfiles.
- Las specs activadas son `confidence: medium` sin `verified`; `ARCH-APICANAL-001` y `PROD-APICANAL-*` son `draft/low`.
- [gap] `mapfre-cli scaffold` / Zeus / Backstage no accesibles desde la sesión: esqueleto creado a mano siguiendo la estructura del arquetipo; workflows `.github/workflows/*` son equivalentes abiertos de ZeusOneteam-CI (pendiente sustituir al entrar en la organización).
- [gap] Imágenes base `acrmapfredevops` y librerías corporativas (UI, `@mapfre-tech/*`) no accesibles: sustituidas por Temurin/nginx-unprivileged y estilos propios.
- [gap] Contratos reales de API Canal y APIs de plataforma tras el API Gateway no publicados: adaptadores `@Profile("!local")` escritos contra los paths propuestos en `docs/pgm/03-mapeo-api-canal.md`; perfil `local` con datos sintéticos.
- [gap] Onboarding SRE/observabilidad corporativa pendiente (OTLP configurable por `OTEL_EXPORTER_OTLP_ENDPOINT`).

- Decisión del owner (2026-10-20, ggalv10): lo que API Canal no cubre se consume de los servicios legacy que ya usa PGM en Appian (PGO /apipgo, SGC 3.0, iMediador EDGE, BDEC/ESTRUAGE, Clients EDGE, GESYC, SGO, Click2Call), siempre a través del API Gateway interno (ARCH-FIS-COM-001 regla 1); sustituye la restricción anterior «sin legacy». Entra ID: App Registration clientId c4d0e5f0-4a24-4b89-a577-bd2c809f972a (identificador público), tenant 93ad25dd-8cdc-4066-9727-31a8a3024f80, scope api://c4d0e5f0-4a24-4b89-a577-bd2c809f972a/pgm.acceso (a crear en el portal de Entra ID).
- (2026-10-20, tras pruebas A–F en Appian TEST) Gaps de contrato pendientes de PCC/dueños: detalle por ramo de PGO `opportunity/incomplete` (17 subformularios), iMediador `/api/1.0/perfil`, SGC 3.0 detalle/Agendar/Asignar, GESYC `consultarRecibo`/`imprimirRecibo`, WLCatalog, Motor/Health/Life API por ramo, `inicioExterno` de SGO. Los adaptadores `!local` usan los paths observados en los objetos de integración de PGM con cuerpos sintéticos (simulador). Lista única en `docs/pgm/pruebas/requisitos-pruebas-servicios.md`.
- Constantes Appian mapeadas a flags `pgm.features.*`: `PGM_visualizacionRecibos`, `PGM_CONS_VER_DETALLE_PRESTACIONES`; grupos `PGM_USUARIOSGRUPOTRABAJO` / `PGM_GR_DETALLEHOGAR` → visibilidad `fichaPolizaAutosHogar`.

## Traceability
| Relación | Target |
|---|---|
| governed-by-manifest | MFST-NEW-BFF-001@1.2.0 |
- Implementación (2026-10-19): `pgm-bff/` en rama `feature/pgm` de mapfre-pilot/spring-boot-realworld-example-app. Evidencia: `mvn clean package` + `mvn test` (16 tests OK, Java 21, Spring Boot 3.5.6); JAR arrancado en perfil `local`: `/monitoring/health|metrics|prometheus` 200, OpenAPI en `/v3/api-docs.yaml` (20 operaciones), 20 endpoints `/api/v1` verificados; commit `232e24b`.
