---
id: WRK-SPEC-NEW-BFF-001
type: spec
layer: work-spec
scope: ephemeral
status: draft
version: 0.1.0
created: "2026-10-13"
updated: "2026-10-13"
owner: ggalv10
generated:
  by: devin/session-8b40e850c29e46d0a70e46a55c3dcab5
  at: "2026-10-13T09:45:00.512Z"
task_type: new-bff
manifest_used: MFST-NEW-BFF-001@1.2.0
parameters:
  archetype: sboot
  platform: PPV
  target_channel: spa
  consumes_pii: true
  paired_with_spa: MFST-NEW-SPA-001
activates:
  - ARCH-FIS-COM-001@1.0.0
  - ARQT-SBOOT-001@1.0.1
  - BP-API-001@1.0.0
suggested: []
activation_frozen: true
activation_resolved_at: "2026-10-13T09:45:00.512Z"
bootstrap_state: pending
tags:
  - work-spec
  - new-bff
---

# WRK-SPEC-NEW-BFF-001 — BFF Vencimientos Manuales (migración ES_VIDA_372)
## Intent
Sustituir la capa Struts/framework Vida de ES_VIDA_372VENCIMIENTOSMANUALES por un BFF Spring Boot que consume los servicios CICS B372VT* del producto mainframe
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
  "platform": "PPV",
  "target_channel": "spa",
  "consumes_pii": true,
  "paired_with_spa": "MFST-NEW-SPA-001"
}
```
## Problem Statement
`ES_VIDA_372VENCIMIENTOSMANUALES` (PPV, producto `PROD-PPV-VENCIMIENTOS-MANUALES-001`, proceso `PROC-PPV-008`) es un EAR del framework Vida: Struts 1.2 + JSP sobre WebSphere que actúa como BFF de 13 servicios CICS `B372VT01–12/19` (COBOL + DB2 propia). Struts 1, Log4j 1.2 y las librerías Vida están obsoletas. `PLAT-FUNC-PPV-001` fija que los frontales nuevos son SPA Angular y el backend contenedor Spring Boot, y que el mainframe se consume por su API de Producto (CTG) sin API Gateway. Inventario: `docs/inventario-vida372.md` del repo de aplicación.
## Proposed Change
Fase 1 (strangler): sustituir la capa Struts por `vencimientos-manuales-bff` (Spring Boot, `ARQT-SBOOT-001`) emparejado con la SPA de `WRK-SPEC-NEW-SPA-001`. COBOL, DB2 y JCL permanecen en el host.
- Arquitectura hexagonal: dominio (expediente, liquidación/impuestos, coaseguro, variables, persona, finiquito, informe, petición BDGI, carga de fichero, cartera), casos de uso, puerto de salida `HostVencimientosPort` (una operación por servicio `B372VT*`) y puerto `ImpresionPort` (FormsPath).
- Adaptador de salida CTG/CICS detrás del puerto; en esta fase, adaptador en memoria (perfil `local`) para desarrollo y tests.
- Contrato OpenAPI 3 primero (`BP-API-001`), REST `/api/v1/...`, modelo de errores común.
- Cálculos de importes que hoy viven en JavaScript (bruto/neto/retención/líquido, reparto de coaseguro) pasan al dominio con `BigDecimal` y tests de caracterización.
- Seguridad: OAuth2 resource server Entra ID (JWT), autorización por operación.
- Observabilidad: `/monitoring/health|metrics|prometheus`, log JSON sin PII.
## Constraints
- `ARQT-SBOOT-001`: Java 17/21, Maven, estructura `sources/`, `docker/Dockerfile`, `docker/docker-compose.yml`, `maven/settings.xml`, workflows `pull-request.yml`/`merge-commit.yml`; `mvn clean package` exit 0.
- `ARCH-FIS-COM-001` + `PLAT-FUNC-PPV-001`: BFF on-prem → mainframe sin API Gateway, vía API de Producto/CTG, con auditoría.
- Sin BBDD propia (`db_engine: ninguno`): los datos son del host.
- PII (NIF, datos fiscales y de pago): no se registran en logs.
## Acceptance Criteria
- [ ] Bootstrap ejecutado (`bootstrap_state: completed`) y outputs registrados.
- [ ] Implementación alineada con todas las specs Tier 1+2 activadas.
## Open Questions
- **Bootstrap manual**: `mapfre-cli`, Zeus OneTeam, Backstage y Azure Artifacts no están disponibles en la sesión. El esqueleto se crea a mano siguiendo `ARQT-*`; los pasos `configure-*`, `setup-sonar` y `register-in-catalog` quedan pendientes de SRE (`bootstrap_state` sigue en `pending`).
- **Librerías corporativas** (`arch-ram-lib-java-*`, `@mapfre-tech/nx-angular*`) no accesibles: se usan equivalentes públicos (Spring Boot actuator/micrometer/logstash-encoder; Nx/Angular públicos). Sustituir al pasar a `github.mapfre.com`.
- **Parámetros sin efecto en la activación**: `consumes_pii` no activa ninguna spec RGPD/cifrado (gap del grafo).
- **Producto** `PROD-PPV-VENCIMIENTOS-MANUALES-001` (`confidence: low`, importado de EA) no tiene `depends-on` (stack). Propuesta de consolidación: añadir el stack BFF+SPA+Mainframe.

- **Integración mainframe**: el grafo no tiene patrón CTG/CICS ni z/OS Connect (solo menciones en `PLAT-FUNC-PPV-001`). Propuesta de ADR: puerto `HostVencimientosPort` + adaptador CTG; la conexión real queda pendiente.
- **`PLAT-FUNC-PPV-001` no lo activa `MFST-NEW-BFF-001`** aunque `platform=PPV`, y la decisión de arquitectura se basa en esa spec. Propuesta: Tier 2 por plataforma en el manifest BFF (como en `MFST-NEW-API-001`).
- **`PAT-ENTRAID-001` y `PAT-OBSERVABILIDAD-JAVA-001` no se activan en BFF**: se aplican por coherencia con `new-api`.
- **Impresión FormsPath/SGDD**: sin spec; queda como `ImpresionPort`.
- **Perfiles/roles** por operación: la matriz de IDs funcionales del framework Vida no está en el snapshot.
- **Cartera VT03/VT05**: sin fuentes host ni Action en el snapshot; contrato provisional.
- **Batch JCL** (fase 2): candidato a `ARQT-SBATCH-001` si se saca del host.
## Traceability
| Relación | Target |
|---|---|
| governed-by-manifest | MFST-NEW-BFF-001@1.2.0 |
