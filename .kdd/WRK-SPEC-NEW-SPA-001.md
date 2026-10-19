---
id: WRK-SPEC-NEW-SPA-001
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
  at: "2026-10-19T18:21:47.989Z"
task_type: new-spa
manifest_used: MFST-NEW-SPA-001@1.3.0
parameters:
  archetype: angular
  platform: standalone
  spa_type: spa
  with_bff: true
  paired_with_bff: MFST-NEW-BFF-001
activates:
  - ARQT-ANGULAR-001@1.1.0
  - BP-API-001@1.0.0
suggested:
  - MFST-NEW-BFF-001@1.0.0
activation_frozen: true
activation_resolved_at: "2026-10-19T18:21:47.989Z"
bootstrap_state: pending
tags:
  - work-spec
  - new-spa
---

# WRK-SPEC-NEW-SPA-001 — SPA PGM (migración del frontal Appian PGM_MAPFRE a Angular)
## Intent
Reimplementar el site Appian pgm-mapfre (buscador, ficha 360, recibos, prestaciones, gestión comercial, nueva producción, cartera, utilidades) como SPA Angular sobre el BFF PGM
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
  "platform": "standalone",
  "spa_type": "spa",
  "with_bff": true,
  "paired_with_bff": "MFST-NEW-BFF-001"
}
```
## Problem Statement
El site Appian `pgm-mapfre` (566 interfaces SAIL, 8 páginas, navegación por pestañas dentro de la ficha, 9 Web APIs de entrada desde SGC y otros frontales) concentra la UI de la visión 360 de oficinas. Está acoplado a Appian (records contenedores, procesos para redirigir, `a!dynamicLink`), con versionado por duplicación (`_v2/_v3`) y visibilidades por grupos Appian + estructura comercial + pilotos. Análisis funcional en `docs/pgm/01-analisis-funcional.md`.

## Proposed Change
`pgm-spa` (Angular 17–19 + Nx, `ARQT-ANGULAR-001`) sobre `pgm-bff` (`WRK-SPEC-NEW-BFF-001`):
- Rutas: `/inicio` (buscador multicriterio + resultados + enlaces), `/clientes/:id` (cabecera, indicadores con acción, resumen por ramo, pestañas posición/gestión comercial/presupuestos), `/polizas/:id`, `/recibos/:id`, `/nueva-produccion`, `/gestion-cartera`, `/prestaciones`, `/recibos`, `/gestion-comercial`, `/utilidades`.
- Deep links que sustituyen a las Web APIs Appian: `/clientes/por-documento/:doc`, `/polizas/:id`, `/clientes/:id?origen=sgc`.
- Autenticación OIDC Entra ID; visibilidades por rol/estructura/feature flag entregadas por el BFF (la SPA no decide permisos).
- Componentes reutilizables: tarjetas por ramo (lanzaderas), tablas exportables (Excel), carrusel de ramos, indicadores, diálogos multipaso (Cliente Total, alta ACI, documentos PGO, cobro/agrupación de recibos cuando API Canal lo publique).
- Diseño MAPFRE (tipografía/colores del site actual), accesibilidad, Jest + Spectator, ESLint/Prettier corporativos, CI `ZeusOneteam-CI-FrontSPA`.

## Constraints
- `ARQT-ANGULAR-001`: workspace Nx, esbuild, Jest/Spectator, ESLint/Prettier/commitlint/Husky, registro npm Azure Artifacts, creación desde Zeus OneTeam (Application SPA, extensión España).
- `BP-API-001`: consumo del BFF por contrato OpenAPI (cliente generado), sin llamadas directas a API Canal ni a plataformas desde el navegador.
- Convivencia por fases con el site Appian (strangler): enlaces cruzados hasta el apagado.

## Acceptance Criteria
- [ ] Ninguna llamada del componente a ESB/SOAP/Denodo/core legacy: solo `PROD-APICANAL-*` y APIs de plataforma por API Gateway (`ARCH-APICANAL-001` AC1).
- [ ] Bootstrap ejecutado (`bootstrap_state: completed`) y outputs registrados.
- [ ] Implementación alineada con todas las specs Tier 1+2 activadas.
## Open Questions
- Plataforma Canales y Clientes sin specs en el grafo → `platform: standalone` (ver WRK-SPEC-NEW-BFF-001).
- Gestión de estado (signals vs NgRx) y estrategia de microfrontend si Nébula/SGC necesitan embeber la ficha.
- Lanzaderas Citrix/NSE: qué aplicaciones de ramo seguirán sin API y cómo se abren desde la SPA.
- Cuadro de mando: métricas de negocio en Grafana vs pantalla propia.

## Traceability
| Relación | Target |
|---|---|
| governed-by-manifest | MFST-NEW-SPA-001@1.3.0 |
