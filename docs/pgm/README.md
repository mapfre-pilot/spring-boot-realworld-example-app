# Migración PGM (Appian) → arquitectura de referencia MAPFRE

Análisis brownfield de la aplicación Appian **PGM_MAPFRE** (TEST) y propuesta de migración a SPA Angular + BFF Spring Boot sobre API Canal, elaborado con el harness KDD (`kdd-mapfre`).

| Documento | Contenido |
|---|---|
| [01-analisis-funcional.md](01-analisis-funcional.md) | Qué hace PGM, perfiles, navegación, procesos funcionales, reglas de negocio |
| [02-analisis-tecnico.md](02-analisis-tecnico.md) | Arquitectura as-is, modelo de datos, integraciones, procesos, Web APIs, seguridad, deuda |
| [03-mapeo-api-canal.md](03-mapeo-api-canal.md) | Capacidad a capacidad: destino (API Canal / plataforma / BFF) y gaps a solicitar a PCC |
| [04-arquitectura-objetivo-y-plan.md](04-arquitectura-objetivo-y-plan.md) | Arquitectura objetivo (specs activadas), strangler por fases, riesgos y open questions |
| [inventario/](inventario/) | Inventario completo: objetos por tipo, integraciones (CSV), sistemas conectados, modelos de proceso, records, Web APIs/data stores, constantes relevantes, lanzaderas por página y por ramo, textos de pantallas (SAIL) |
| [capturas/](capturas/) | Pantallas de TEST (navegación solo lectura) |
| [diagramas/](diagramas/) | Arquitectura actual, objetivo y objetivo v2 (componentes a construir) — SVG + PNG |
| `../../.kdd/` | WRK-SPEC congelados: `WRK-SPEC-NEW-SPA-001` (ARQT-ANGULAR-001, BP-API-001) y `WRK-SPEC-NEW-BFF-001` (ARCH-FIS-COM-001, ARQT-SBOOT-001, BP-API-001), `platform: standalone` (plataforma Canales y Clientes sin specs aún) |

Método: inventario por LCP API en modo lectura (2.986 objetos; 1.922 definiciones descargadas), navegación del site `pgm-mapfre` sin ejecutar operativas que modifiquen datos, lectura de specs del grafo KDD (`ARCH-APICANAL-001`, `PROD-APICANAL-*`, `ARQT-ANGULAR-001`, `ARQT-SBOOT-001`, `BP-API-001`, `ARCH-FIS-COM-001`). En Appian no se creó ni modificó ningún objeto.
