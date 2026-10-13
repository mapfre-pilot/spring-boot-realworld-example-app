---
id: WRK-SPEC-NEW-SPA-001
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
  at: "2026-10-13T09:45:00.707Z"
task_type: new-spa
manifest_used: MFST-NEW-SPA-001@1.3.0
parameters:
  archetype: angular
  platform: PPV
  spa_type: spa
  with_bff: true
  paired_with_bff: MFST-NEW-BFF-001
activates:
  - ARQT-ANGULAR-001@1.1.0
  - BP-API-001@1.0.0
suggested:
  - MFST-NEW-BFF-001@1.0.0
activation_frozen: true
activation_resolved_at: "2026-10-13T09:45:00.707Z"
bootstrap_state: pending
tags:
  - work-spec
  - new-spa
---

# WRK-SPEC-NEW-SPA-001 — SPA Vencimientos Manuales (migración ES_VIDA_372)
## Intent
Sustituir las JSP de ES_VIDA_372VENCIMIENTOSMANUALES por una SPA Angular que consume el BFF de Vencimientos Manuales
## Knowledge Context
Specs activadas (congeladas desde `MFST-NEW-SPA-001@1.3.0`):
- ARQT-ANGULAR-001@1.1.0
- BP-API-001@1.0.0
### Sugeridas (Tier 3)

- MFST-NEW-BFF-001@1.0.0

## Parameters
Resueltos por el router; congelados con `activation_frozen: true`.
```json
{
  "archetype": "angular",
  "platform": "PPV",
  "spa_type": "spa",
  "with_bff": true,
  "paired_with_bff": "MFST-NEW-BFF-001"
}
```
## Problem Statement
Las 15 JSP + JavaScript del EAR Vida `ES_VIDA_372VENCIMIENTOSMANUALES` deben sustituirse por un frontal moderno (`PLAT-FUNC-PPV-001`: SPA Angular para nuevos frontales).
## Proposed Change
`vencimientos-manuales-web`: SPA Angular standalone en Nx (`ARQT-ANGULAR-001`), Clean Architecture (dominio, casos de uso, repositorios HTTP, páginas), con las 10 pantallas del inventario. Consume exclusivamente `vencimientos-manuales-bff` (`WRK-SPEC-NEW-BFF-001`). Login OIDC con Entra ID. Sin cálculos de negocio en cliente (los hace el BFF).
## Constraints
- `ARQT-ANGULAR-001`: Angular 17–19, Nx, esbuild, Jest + Spectator, ESLint, Prettier; `npm run build` exit 0.
- `BP-API-001`: el cliente sigue el contrato OpenAPI del BFF.
## Acceptance Criteria
- [ ] Bootstrap ejecutado (`bootstrap_state: completed`) y outputs registrados.
- [ ] Implementación alineada con todas las specs Tier 1+2 activadas.
## Open Questions
- **Bootstrap manual**: `mapfre-cli`, Zeus OneTeam, Backstage y Azure Artifacts no están disponibles en la sesión. El esqueleto se crea a mano siguiendo `ARQT-*`; los pasos `configure-*`, `setup-sonar` y `register-in-catalog` quedan pendientes de SRE (`bootstrap_state` sigue en `pending`).
- **Librerías corporativas** (`arch-ram-lib-java-*`, `@mapfre-tech/nx-angular*`) no accesibles: se usan equivalentes públicos (Spring Boot actuator/micrometer/logstash-encoder; Nx/Angular públicos). Sustituir al pasar a `github.mapfre.com`.
- **Parámetros sin efecto en la activación**: `consumes_pii` no activa ninguna spec RGPD/cifrado (gap del grafo).
- **Producto** `PROD-PPV-VENCIMIENTOS-MANUALES-001` (`confidence: low`, importado de EA) no tiene `depends-on` (stack). Propuesta de consolidación: añadir el stack BFF+SPA+Mainframe.

- Generadores `@mapfre-tech/nx-angular(-esp)` (`TOOL-NX-*-001`) no accesibles: estructura Clean Architecture creada a mano.
- `DOC-NEWCOMPONENT-ANGULAR-001` pendiente en el grafo.
## Traceability
| Relación | Target |
|---|---|
| governed-by-manifest | MFST-NEW-SPA-001@1.3.0 |
