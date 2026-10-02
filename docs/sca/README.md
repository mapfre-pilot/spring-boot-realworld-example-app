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
9. [Fase 0: construcción de SCA2](09-fase0-construccion-sca2.md) — app SCA2, data source dedicado, migración de record types, batches A/B de reglas e interfaces e integraciones propias, PMs atómicos CMD_* (fase 1: Alta, Decidir, CrearAccion, CompletarAccion, Finalizar, Mecanizar, Caducar, BarridoCaducidad) y UI/site SCA2 con CMD Alta, pantallas completas de acción, página de Gestiones mantenimiento, redirección Vida y pruebas con pólizas reales; paridad visual del site/buscador con SCA, CMD Posponer/CambiarNivel, fase A2 de pólizas y corrección de las consultas SOAP tipadas (causa raíz del 500 de Core7); paridad de lógica en pantallas de acción (tandas 9-11: REVISIÓN, API Clients, trazabilidad, Mecanización completa/VERTI, Documentación administrativa y PMs GenerarPdf/ObtenerDocumentoGD).
10. [Plan de despliegue de SCA2 a TEST](10-plan-despliegue-test.md) — decisiones previas, prerrequisitos (dependencias SCA/SCAC por UUID), matriz DEV→TEST de connected system/constantes/secretos, BBDD `sca2_anulaciones`, ejecución, validación y rollback.
11. [Alineación con SCA TEST, navegación F5 y rendimiento](11-alineacion-test-rendimiento-navegacion.md) — veredictos de los 13 objetos divergentes y 3 ausentes en TEST, mecanismo final de persistencia en URL (`?$sp` con rule inputs + parámetros de URL del site) y medición de rendimiento del Alta con mejoras propuestas.
12. [Correcciones tras la revisión del analista](12-correcciones-analista-contra-anulacion.md) — Alta (2ª póliza, Cancelar, salto directo a la acción decidida), Alta gestión CORE, argumentos GAIA (`listadoArgumentos`/`mcaEstado`), catalogación, visor de documento nulo y subida de documentos a GD replicada de forma atómica en `CMD CompletarAccion`.
13. [Segunda revisión del analista (`Analisis SCA2.docx`)](13-revision-analista-ronda2.md) — cruce de los 18 puntos con lo ya corregido en S1–S5 y nuevas correcciones: botones del buscador, GUARDAR con progreso/CANCELAR inactivo y navegación automática post-alta (PMs Alta/Decidir síncronos), CANCELAR de Contra Anulación con cierre CORE (`mcaEstadoFinal 9`) y estado `CANCELADA`, secciones abiertas en Acción Administrativa, búsqueda por cliente vía `consultarDP`, búsqueda por NIF (`SCA2_Buscador` v16), visor documental de Acción Administrativa (`CONVERT_BINARY`), POSPONER/RETOMAR de Contra Anulación con persistencia de compañía/catalogación/fecha (v36 + CMD Posponer); evidencias LCP en [`pruebas/06-ronda2-analista-lcp-ui.md`](pruebas/06-ronda2-analista-lcp-ui.md) e informe UI del testing agent en [`pruebas/07-ronda2-ui3-informe-testing-agent.md`](pruebas/07-ronda2-ui3-informe-testing-agent.md).
14. [Tercera revisión del analista funcional: ronda 3](14-revision-analista-ronda3.md) — correcciones del Alta y vigencia, orquestación SCA2→ANL, estados finales, `numGestion`, Detalle/Tareas v17, resultados UI D–G y pendientes. Informe UI: [pruebas/08-ronda3-informe-testing-agent.md](pruebas/08-ronda3-informe-testing-agent.md).
15. [Pruebas comparativas SCA vs SCA2 en TEST (S1–S5)](pruebas/00-consolidado-s1-s5.md) — consolidado de las cinco sesiones paralelas (POSITIVO, NEGATIVO+GD, Acción Administrativa, Autorización, Detalle/buscador/errores): veredicto por flujo, causas raíz corregidas, hallazgos comunes a SCA y pendientes; informes detallados `pruebas/s1…s5`.
16. [Anexo: inventario generado](anexos/inventario-generado.md) — volcado tabular (process models, integraciones, record types, referencias cruzadas).

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
