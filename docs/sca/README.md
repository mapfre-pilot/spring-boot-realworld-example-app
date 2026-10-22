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
15. [Cuarta revisión del analista: ronda 4](15-revision-analista-ronda4.md) — traducción NEW/NSE de motivo/detalle/causa antes de ANL y ACEPTAR tras la CA negativa que espera a la tarea de mecanización. Informe UI: [pruebas/09-ronda4-informe-testing-agent.md](pruebas/09-ronda4-informe-testing-agent.md).
16. [Quinta revisión del analista: ronda 5](16-revision-analista-ronda5.md) — `NO_MECANIZAR`, Decidir tras mecanizar, banner SI24, Acción Administrativa → mecanización, nivel 2 CE_RM/SI24 (SGC/DUE), Detalle (Autorización, RETOMAR, fechas CORE). Informe UI: [pruebas/10-ronda5-informe-testing-agent.md](pruebas/10-ronda5-informe-testing-agent.md).
17. [Bandeja de errores](17-bandeja-errores.md) — relanzar sin `local!dummy`, descartar, filtros, refresco y paginación. Informe UI: [pruebas/11-bandeja-errores-informe-testing-agent.md](pruebas/11-bandeja-errores-informe-testing-agent.md).
18. [Relanzar Alta con un único proceso y limpieza de datos](18-bandeja-errores-relanzar-alta-y-limpieza.md) — `SCA2_CMD_MarcarErrorRelanzado` como único punto de entrada e inventario/limpieza autorizada de errores y solicitudes sin CORE.
19. [Sexta revisión del analista: ronda 6](19-revision-analista-ronda6.md) — RETOMAR sólo en la tarjeta abierta, autorización sólo wAutemis «pendiente de aceptar», impresión idempotente (gestión 4 + documento) y cierre SGC real en `CMD Finalizar`, alta bloqueada con VER SOLICITUD si la póliza ya tiene solicitud abierta. Informe UI: [pruebas/12-ronda6-informe-testing-agent.md](pruebas/12-ronda6-informe-testing-agent.md).
20. [Pendientes y dudas funcionales](20-pendientes-y-dudas-funcionales.md) — inventario de pendientes técnicos y preguntas al analista/negocio para seguir desarrollando SCA2.
21. [Ronda 7: JJGONZ2 + SISANS, RCI con salto de nivel y dudas resueltas](21-revision-ronda7.md) — tarea de nivel 2 al grupo, solicitud abierta sólo con `codEstSolic` 1/2, Detalle directo con un resultado, POSPONER de Autorización con SGC, validaciones de fecha en GUARDAR (PRRA desactivado por 403, pendiente), `fecImpagoPCA` null como SCA (CORE 4005); pendientes del Excel (buscador «todas», Oficina al retomar, simulación, Vida). Informe UI: [pruebas/13-ronda7-informe-testing-agent.md](pruebas/13-ronda7-informe-testing-agent.md).
21. [Pruebas comparativas SCA vs SCA2 en TEST (S1–S5)](pruebas/00-consolidado-s1-s5.md) — consolidado de las cinco sesiones paralelas (POSITIVO, NEGATIVO+GD, Acción Administrativa, Autorización, Detalle/buscador/errores): veredicto por flujo, causas raíz corregidas, hallazgos comunes a SCA y pendientes; informes detallados `pruebas/s1…s5`.
22. [Anexo: inventario generado](anexos/inventario-generado.md) — volcado tabular (process models, integraciones, record types, referencias cruzadas).
23. [Análisis de los servicios legacy de SCA (repos Plastic) y plan de lógica en Appian](40-analisis-servicios-legacy-sca.md) — inventario de los 9 repos del ZIP «SCA2 Servicios SCA», 19 servicios RAS (Core7 EJB, mediaciones SOA7/ESB, webMethods, GAIA/NEW) con sus operaciones y lógica, relación con las integraciones de SCAC/SCA/SCA2 que los llaman, candidatos a implementar la lógica en Appian y plan por fases; diagramas `img/40-*.svg|png`. Anexo: [matriz servicios ↔ integraciones ↔ consumidores](anexos/40-matriz-servicios-appian.md).
24. [Diseño detallado fase 1: lógica legacy en Appian sin tocar MR01](41-diseno-logica-appian-fase1.md) — caducidad de tarea, propietario/carterización, catálogos cacheados en Aurora, caché de cabecera de una jornada y preparación de datos para decidir: objetos nuevos, puntos de conexión, pruebas y plan de 5 semanas reversible por constantes.
25. [Coordinación de la fase 1](42-coordinacion-fase1.md) — reparto de objetos Appian por sesión (A–E), reglas comunes, interruptores y [reservas de datos de prueba](pruebas/coordinacion-fase1.md).
26. Implementación fase 1 por sesión: [43-A caducidad por nivel](43-A-caducidad-por-nivel.md) · [43-B propietario y carterización](43-B-propietario-carterizacion.md) · [43-C catálogos en Aurora](43-C-catalogos-aurora.md) · [43-D caché de cabecera](43-D-cache-cabecera.md) · [43-E entrada al motor de reglas](43-E-entrada-reglas.md) · [43-F PM de refresco de caché](43-F-pm-refresco-cache.md) · [43-G invalidación de caché](43-G-invalidacion-cache.md) — objetos, versiones, pruebas y pendientes de cada pieza.
27. [Resumen de cierre de la fase 1](44-resumen-fase1.md) — estado de interruptores en TEST, objetos y versiones, pruebas, hallazgos y pendientes.

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

## Estado y previsión

- [Estado de SCA2 tras la ronda 23: dudas funcionales abiertas, resumen de cambios, lógica por flujo y previsión](42-estado-sca2-ronda23.md)
- [Ronda 24: respuestas del analista a las 17 dudas y plan de aplicación](43-ronda24-respuestas-analista.md)
- [Propuesta de navegación tras GUARDAR en el alta (duda #9)](44-propuesta-retorno-alta-navegacion.md)
- [Ronda 24: comportamiento de la derivación a VERTI (switch, contacto, mecanizar)](45-ronda24-derivacion-verti.md)
- Rondas 19–23 (mantenimiento wAutemis, análisis del analista, Documentum, ANL): [37](37-ronda19-mantenimiento-pendientes-autorizar.md) · [38](38-ronda20-analisis-sca2.md) · [39](39-ronda21-documentum-referencia.md) · [40](40-ronda22-analisis-sca2.md) · [41](41-ronda23-anl-mantenimiento.md)
- Informes de pruebas de las rondas 23–24 (sesiones hijas): [R23-A Autemis, bloqueo NEW y ANL](pruebas/r23-a-autemis-anl.md) · [R23-B NSE](pruebas/r23-b-nse.md) · [R23-C nivel 2, RETOMAR y Verti](pruebas/r23-c-nivel2-verti.md) · [R24-D batch NSE, SGD y bandeja](pruebas/r24-d-batch-sgd-errores.md)
- [46 — Ronda 25: autorización CORE tras ANL y reserva/devolución de prima en la simulación del alta](46-ronda25-reserva-prima-autorizacion.md)
- [47 — Ronda 26: componente Inducir Cliente (Verti) completable dentro del sitio SCA2](47-ronda26-induccion-verti-embebida.md)
