# Gate de despliegue a PRO — adm.zip

**Veredicto: NO APTO PARA PRO** — No apto para PRO: hay gates en incumplimiento sin justificar a OT.

| Gate | Control | Estado | Hallazgos |
|------|---------|--------|-----------|
| G01 | Recomendaciones de monitorización revisadas | 🔍 Revisión manual | 0 |
| G02 | Sin riesgos ALTOS de Health Check en los objetos del paquete | 🔍 Revisión manual | 0 |
| G03 | Procesos con grupo de alertas propio (no administradores) | 🔍 Revisión manual | 1 |
| G04 | Borrado de instancias de proceso <= 3 días | ❌ No cumple | 7 |
| G05 | Sin objetos sin dependencias | ✅ Cumple | 0 |
| G06 | Pruebas de rendimiento satisfactorias | 🔍 Revisión manual | 0 |
| G07 | Tareas de usuario con excepción de tiempo <= 1 día | ❌ No cumple | 6 |
| G08 | Records sincronizados sin full sync diario | ✅ Cumple | 0 |
| G09 | Sin constantes ni expresiones con contraseñas | ✅ Cumple | 0 |
| G10 | Procesos batch fuera de la ventana 06:30-22:00 | 🔍 Revisión manual | 2 |

**Health Check**: no aportado
**Cobertura**: 572 objetos del manifiesto, 573 ficheros analizados, 0 no parseables (100%)

## Hallazgos que bloquean

- **PM-008** `ADM Close Version` (processModel/0004eeea-2548-8000-29b1-7f0000014e7a.xml) — El modelo 'ADM Close Version' usa la configuración de limpieza por defecto del sistema en lugar de borrado propio (norma: borrado <= 3 días).
- **PM-008** `ADM Modificar Correos Informes Usuarios` (processModel/0002eaeb-71fa-8000-ccc0-7f0000014e7a.xml) — El modelo 'ADM Modificar Correos Informes Usuarios' archiva las instancias a los 3 días en lugar de borrarlas (norma: borrado <= 3 días).
- **PM-008** `ADM Proceso Devops` (processModel/0002eedb-dd91-8000-2590-7f0000014e7a.xml) — El modelo 'ADM Proceso Devops' usa la configuración de limpieza por defecto del sistema en lugar de borrado propio (norma: borrado <= 3 días).
- **PM-008** `ADM Recepcion Aprobacion RT` (processModel/000eee34-6ea5-8000-06e8-7f0000014e7a.xml) — El modelo 'ADM Recepcion Aprobacion RT' archiva las instancias a los 1 días en lugar de borrarlas (norma: borrado <= 3 días).
- **PM-008** `ADM Registrar Despliegue` (processModel/0002eedd-1341-8000-2608-7f0000014e7a.xml) — El modelo 'ADM Registrar Despliegue' usa la configuración de limpieza por defecto del sistema en lugar de borrado propio (norma: borrado <= 3 días).
- **PM-008** `ADM TEST reactivar user` (processModel/0002ef38-12ff-8000-36f0-7f0000014e7a.xml) — El modelo 'ADM TEST reactivar user' usa la configuración de limpieza por defecto del sistema en lugar de borrado propio (norma: borrado <= 3 días).
- **PM-008** `ADM_PM_UNARCH_FindArchivedProcess` (processModel/0004ee1b-458d-8000-fea1-7f0000014e7a.xml) — El modelo 'ADM_PM_UNARCH_FindArchivedProcess' usa la configuración de limpieza por defecto del sistema en lugar de borrado propio (norma: borrado <= 3 días).
- **PM-009** `ADM Desactivar Usuarios` (processModel/0002e8ea-6ff1-8000-426f-7f0000014e7a.xml) — La tarea de usuario 'User Input Task' del modelo 'ADM Desactivar Usuarios' no tiene excepción/escalado temporal (norma: <= 1 día(s)).
- **PM-009** `ADM Desactivar Usuarios` (processModel/0002e8ea-6ff1-8000-426f-7f0000014e7a.xml) — La tarea de usuario 'User Input Task' del modelo 'ADM Desactivar Usuarios' no tiene excepción/escalado temporal (norma: <= 1 día(s)).
- **PM-009** `ADM Gestionar Lista Distribucion` (processModel/0006e855-5d6a-8000-1ba4-7f0000014e7a.xml) — La tarea de usuario 'User Input Task' del modelo 'ADM Gestionar Lista Distribucion' no tiene excepción/escalado temporal (norma: <= 1 día(s)).
- **PM-009** `ADM Gestionar Lista Distribucion` (processModel/0006e855-5d6a-8000-1ba4-7f0000014e7a.xml) — La tarea de usuario 'User Input Task' del modelo 'ADM Gestionar Lista Distribucion' no tiene excepción/escalado temporal (norma: <= 1 día(s)).
- **PM-009** `ADM Resync Record` (processModel/0002f067-75b1-8000-6469-7f0000014e7a.xml) — La tarea de usuario 'User Input Task' del modelo 'ADM Resync Record' no tiene excepción/escalado temporal (norma: <= 1 día(s)).
- **PM-009** `ADM_PM_UNARCH_FindArchivedProcess` (processModel/0004ee1b-458d-8000-fea1-7f0000014e7a.xml) — La tarea de usuario 'User Input Task' del modelo 'ADM_PM_UNARCH_FindArchivedProcess' no tiene excepción/escalado temporal (norma: <= 1 día(s)).

## Pendientes de justificación a OT

- `G01`
- `G02`
- `G03`
- `G04`
- `PM-008:ADM Modificar Correos Informes Usuarios`
- `PM-008:ADM Proceso Devops`
- `PM-008:ADM Registrar Despliegue`
- `PM-008:ADM TEST reactivar user`
- `PM-008:ADM_PM_UNARCH_FindArchivedProcess`
- `PM-008:ADM Close Version`
- `PM-008:ADM Recepcion Aprobacion RT`
- `G06`
- `G07`
- `PM-009:ADM Desactivar Usuarios`
- `PM-009:ADM Resync Record`
- `PM-009:ADM_PM_UNARCH_FindArchivedProcess`
- `PM-009:ADM Gestionar Lista Distribucion`
- `G10`

## Buenas prácticas (no bloqueantes)

- [Alta] **PM-011** `ADM Batch Borrado Registro Despliegues` — Proceso batch programado en horario prohibido (gate G10)
- [Alta] **PM-011** `ADM Batch Upload FIle To S3` — Proceso batch programado en horario prohibido (gate G10)
- [Alta] **PRF-001** `ADM_Alerts_Main` — Consulta sin paginación acotada (batchSize -1)
- [Alta] **DEP-001** `ADM_DecisionIconVentanaDespliegue` — Uso de load() / with() (obsoletos)
- [Alta] **DEP-001** `ADM_NombreEstadoDespliegues` — Uso de load() / with() (obsoletos)
- [Alta] **DEP-001** `ADM_ObtenerIntegracionesLoggingEnabled` — Uso de load() / with() (obsoletos)
- [Alta] **PRF-001** `ADM_SuggestFunctionGruposUsuario` — Consulta sin paginación acotada (batchSize -1)
- [Alta] **DEP-001** `ADM_TransicionEstadosDespliegues` — Uso de load() / with() (obsoletos)
- [Alta] **PRF-001** `ADM_UNARCH_Formulario_desarchivado` — Consulta sin paginación acotada (batchSize -1)
- [Alta] **PRF-001** `ADM_getUsersFromExcelDesactivar` — Consulta sin paginación acotada (batchSize -1)
