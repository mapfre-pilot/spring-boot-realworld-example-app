# Sistema Comercial de Anulaciones (SCA) — Documentación técnica

Auditoría de solo lectura de la aplicación Appian **Sistema Comercial de Anulaciones** (prefijo `SCA`) y de su
aplicación de soporte **SCA CORE** (prefijo `SCAC`) en el entorno `mapfrespain-dev` (Appian Cloud).

| Aplicación | UUID | Prefijo | Descripción en Appian |
|---|---|---|---|
| Sistema Comercial de Anulaciones | `512929e9-0fac-426c-b02d-4f546bd15305` | `SCA` | "Aplicación SCA Mapfre" |
| SCA CORE | `0a42a1fc-7392-4429-a377-5df76c2a9908` | `SCAC` | Capa de integraciones / sistemas conectados |

Fecha del análisis: septiembre 2026. Fuente: objetos de diseño leídos vía MCP Appian (`appian-dev-mcp-desarrollo-05c9`),
exclusivamente con operaciones `get*`/`list*`. **No se ha modificado ningún objeto.**

## Índice

1. [Visión funcional](01-vision-funcional.md) — qué hace la aplicación, roles, ciclo de vida de una solicitud.
2. [Arquitectura e inventario](02-arquitectura-e-inventario.md) — capas, objetos por tipo, sites, process models, Web APIs.
3. [Integraciones y dependencias](03-integraciones-y-dependencias.md) — SCA CORE, sistemas conectados, apps externas (ANL, CMP, PGM).
4. [Modelo de datos](04-modelo-de-datos.md) — record types, fuente de datos, estados.
5. [Seguridad y configuración](05-seguridad-y-configuracion.md) — grupos, visibilidad, constantes, gestión de entornos.
6. [Riesgos y mejoras propuestas](06-riesgos-y-mejoras.md) — deuda técnica y plan de mejora priorizado.
7. [Plan de rediseño: procesos atómicos orquestados desde la interfaz](07-plan-rediseno-procesos-atomicos.md) — diagnóstico de los PMs de alta, arquitectura objetivo, duplicación aislada de la app y fases.
8. [Alineación con los planes previos (NTT DATA / Appian Accelerate)](08-alineacion-planes-previos.md) — comparación con las acciones estratégicas, plan de estabilización y code reviews; diferencias incorporadas al plan.
9. [Fase 0: construcción de SCA2](09-fase0-construccion-sca2.md) — app SCA2, data source dedicado, migración de record types, batches A/B de reglas e interfaces e integraciones propias, PMs atómicos CMD_* (fase 1: Alta, Decidir, CrearAccion, CompletarAccion, Finalizar, Mecanizar, Caducar, BarridoCaducidad) y UI/site SCA2 con CMD Alta, pantallas completas de acción, página de Gestiones mantenimiento, redirección Vida y pruebas con pólizas reales.
10. [Anexo: inventario generado](anexos/inventario-generado.md) — volcado tabular (process models, integraciones, record types, referencias cruzadas).

## Alcance y limitaciones

- Se analizaron **1.000+ objetos**: 19 record types, 103 interfaces, 250 expression rules, 60 process models,
  5 Web APIs, 145 constantes, 5 grupos, 2 sites, 68 documentos y 17 carpetas de SCA; 176 integraciones,
  25 connected systems, 8 Web APIs y 12 constantes de SCAC.
- Cinco process models (`SCA Alta Solicitud Anulacion`, `SCA Crear Concepto`, `SCA Crear Concepto Funcional`,
  `SCA Eliminar Concepto Funcional`, `SCA Modificar Concepto Funcional`) no pudieron leerse completos por un error
  del servidor MCP (`'interfaceUuid' KeyError`); se documentan a partir de su lista de nodos y metadatos.
- El cuerpo SAIL de las Web APIs no es devuelto por el MCP; se documentan por metadatos (método, alias, visibilidad).
- No se ha analizado la base de datos (`SCAC AWS DB`) ni datos de negocio, solo el diseño.
- Los valores de credenciales (connected systems, constantes `*_PWD_*`, `*_USUARIO_*`) se han excluido deliberadamente.
- Los hallazgos de "riesgo" son señales de revisión basadas en el diseño; no son defectos confirmados en ejecución.
