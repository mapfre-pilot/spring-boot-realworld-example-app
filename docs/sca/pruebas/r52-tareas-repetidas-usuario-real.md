# R52 — Tareas y errores repetidos, y usuario real en el histórico (SCA2, Appian TEST)

Fecha: 16/11/2026. Entorno: Appian TEST (`mapfrespain-test`), site `/suite/sites/sca2`. PRO no se ha tocado; DEV no se ha usado. Desde Devin no se ha ejecutado SQL.
Coordinación y copias: [`coordinacion-ronda52.md`](coordinacion-ronda52.md), [`backups-r52/`](backups-r52/).

## 1. Resumen

| Tema | Qué se ha hecho | Resultado |
|---|---|---|
| Tareas PENDIENTE repetidas | 375, 711, 712, 713 y 714 → `CANCELADA` (con `fechaCierre`). Se conservan las más antiguas: 220, 617, 622 y 632 | 0 grupos repetidos (solicitud + tipo + PENDIENTE) |
| Errores PENDIENTE repetidos (24 grupos) | La fila más antigua de cada grupo sigue `PENDIENTE` con `intentos` = suma del grupo; las otras 40 filas → `DESCARTADO` (el estado que ya usa la bandeja `/errores` para descartar). No se ha relanzado nada | 0 grupos repetidos (solicitud + comando + nodo + código + PENDIENTE) |
| Caminos que crean errores sin reutilizar | `SCA2 CMD RefrescarCacheCabecera` nodo 12 y la escritura `TTQ_KO` de `SCA2_ContraAnulacionSGO` creaban siempre una fila nueva. Ahora reutilizan el error PENDIENTE con `SCA2_obtenerErrorPendiente` y suman 1 a `intentos` | Todos los «Write Error» de SCA2 reutilizan (ver §4) |
| Caminos que crean tareas | Todos usan `SCA2_obtenerIdTareaPendiente` (R50-B). No hace falta cambiar nada | Ver §3 |
| Usuario real en el histórico | Los «Start Process» que encadenan comandos pasan de «ejecutar como diseñador» a «ejecutar como iniciador». Sin cambios en el resto del flujo | Los procesos hijos heredan como iniciador al usuario del site; ya no depende de quién publique |
| Scripts SQL | 71 sigue siendo válido tal cual. Nuevo `72-r52-unique-errores-pendientes.sql` (probado solo en PostgreSQL 14 y 16 locales) | Ver §6 |

## 2. Datos corregidos (16/11/2026 21:05, desde Appian con `updateRecordData`)

Copia previa: `backups-r52/R52_SCA2_Tarea_duplicadas_antes.csv` y `backups-r52/R52_SCA2_Error_duplicados_antes.csv`.

### 2.1 Tareas

| Solicitud | Tipo | Se conserva (PENDIENTE) | Pasa a CANCELADA |
|---|---|---|---|
| 15788025 | MECANIZAR | 220 | 375 |
| 15788607 | CONTRAANULAR | 617 | 711 |
| 15788673 | CONTRA ANULAR NIVEL 2 | 622 | 712 |
| 15788677 | CONTRA ANULAR NIVEL 2 | 632 | 713, 714 |

Lectura posterior: PENDIENTE 306, COMPLETADA 510, FINALIZADA 113, CANCELADA 5; ningún grupo PENDIENTE repetido.

### 2.2 Errores

`resueltoPor` de las filas descartadas: `GGALV10@mapfre.net` (quien ordenó el descarte), para no dejar `devin`; `fechaResolucion` 16/11/2026 21:05.

| Solicitud | Comando | Nodo | Código | Queda PENDIENTE | intentos | DESCARTADO |
|---|---|---|---|---|---|---|
| 15787668 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 137 | 3 | 145, 159 |
| 15788053 | Decidir | Consultar reglas | DECISION_ERROR | 83 | 2 | 84 |
| 15788098 | ObtenerDocumentoGD | consultaDocumento | GD_ERROR | 88 | 4 | 89, 90, 91 |
| 15788099 | ObtenerDocumentoGD | consultaDocumento | GD_ERROR | 92 | 2 | 93 |
| 15788161 | Decidir | Consultar reglas | DECISION_ERROR | 106 | 2 | 107 |
| 15788164 | Decidir | Consultar reglas | DECISION_ERROR | 108 | 2 | 109 |
| 15788200 | Decidir | Consultar reglas | DECISION_ERROR | 116 | 2 | 117 |
| 15788205 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 132 | 3 | 153, 173 |
| 15788208 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 133 | 4 | 140, 154, 174 |
| 15788209 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 134 | 4 | 141, 155, 175 |
| 15788210 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 135 | 4 | 142, 156, 176 |
| 15788218 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 136 | 4 | 143, 157, 177 |
| 15788225 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 128 | 4 | 144, 158, 178 |
| 15788255 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 160 | 2 | 161 |
| 15788256 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 162 | 2 | 163 |
| 15788260 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 164 | 2 | 165 |
| 15788271 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 166 | 2 | 167 |
| 15788369 | Decidir | Consultar reglas | DECISION_ERROR | 147 | 2 | 148 |
| 15788372 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_ERROR | 150 | 4 | 151, 152, 172 |
| 15788391 | Decidir | Consultar reglas | DECISION_ERROR | 168 | 2 | 169 |
| 15788436 | RefrescarCacheCabecera | Actualizar fila caché | REFRESCO_CACHE_RECORTE | 184 | 2 | 185 |
| 15788918 | Decidir | Consultar reglas | DECISION_ERROR | 216 | 2 | 217 |
| 15789139 | Decidir | Consultar reglas | DECISION_ERROR | 221 | 2 | 222 |
| 15789144 | Decidir | Consultar reglas | DECISION_ERROR | 224 | 2 | 225 |

Lectura posterior: PENDIENTE 73, DESCARTADO 47, RELANZADO 19, BLOQUEADO 10; ningún grupo PENDIENTE repetido.
13 de los 24 grupos son de `RefrescarCacheCabecera`, el camino que R50-B no cubría (§4); los 10 de `Decidir` y los 2 de `ObtenerDocumentoGD` son anteriores a R50-B.

## 3. Caminos que crean tareas (revisión)

| Proceso / nodo | Cómo escribe la tarea | Cubierto |
|---|---|---|
| CrearAccion 7 «Write Tarea» | `id: rule!SCA2_obtenerIdTareaPendiente(idSolicitud, tipo = procesoActivo)` | Sí |
| CrearAccion 9 «Write PDTE_MECANIZAR + Tarea» | Igual, tipo MECANIZAR | Sí |
| CrearAccion 31 «Write Tarea VERTI (previa)» | Igual, tipo VERTI | Sí |
| CrearAccion 16 «Write Asignacion» | Actualiza la tarea PENDIENTE existente (no crea) | Sí |
| CompletarAccion 5 «Write Tarea» | Actualiza `pv!idTarea` a COMPLETADA (no crea) | Sí |
| Decidir → CrearAccion (relanzado con la solicitud ya EN_ACCION, origen de la 711) | Pasa por CrearAccion 7, que reutiliza la tarea PENDIENTE del mismo tipo | Sí |
| Mecanizar 322 / MecanizarNSE 36 / MarcarErrorRelanzado 10–17 → CrearAccion | Igual que el anterior | Sí |

La 711 (y 712–714) son de antes de R50-B: con la regla actual, relanzar Decidir sobre una solicitud EN_ACCION reutiliza la tarea 617 en lugar de crear otra.

## 4. «Write Error» (revisión completa)

| Proceso / objeto | Nodo | Antes de R52 | Después |
|---|---|---|---|
| CMD Alta | 6 | Reutiliza (R50-B) | Sin cambios |
| CMD Caducar | 9 | Reutiliza | Sin cambios |
| CMD CompletarAccion | 199 | Reutiliza | Sin cambios |
| CMD CrearAccion | 8 | Reutiliza | Sin cambios |
| CMD Decidir | 7 | Reutiliza | Sin cambios |
| CMD Decidir | 8 | Escribe `BLOQUEADO` (no PENDIENTE) | Sin cambios (no afecta al índice) |
| CMD Finalizar | 9, 17 | Reutiliza | Sin cambios |
| CMD Mecanizar | 12 | Reutiliza | Sin cambios |
| CMD MecanizarNSE | 99 | Reutiliza | Sin cambios |
| CMD ObtenerDocumentoGD | 200 | Reutiliza | Sin cambios |
| CMD Posponer | 199 | Reutiliza | Sin cambios |
| CMD MarcarErrorRelanzado | 3 | Pasa a RELANZADO (no crea) | Sin cambios |
| **CMD RefrescarCacheCabecera** | **12** | **Creaba siempre fila nueva (`intentos: 1`)** | **`id` e `intentos + 1` con `SCA2_obtenerErrorPendiente`** (v7→v8) |
| **Interfaz SCA2_ContraAnulacionSGO** | `a!writeRecords` TTQ_KO | **Creaba siempre fila nueva (`intentos: 0`)** | **`id` con `SCA2_obtenerErrorPendiente`; `intentos` = existente + 1 (0 si es nuevo)** (v6→v7) |

## 5. Usuario real en el histórico

Causa: `SCA2 Transicion.usuario` y `SCA2 Solicitud.modifiedBy` se graban con `pp!initiator`. Los «Start Process» estaban en «ejecutar como diseñador»: el proceso hijo arrancaba con iniciador = último usuario que publicó el proceso padre (en TEST, `devin`). Ningún nodo graba `loggedInUser()`.

Cambio: solo `runAs` DESIGNER → INITIATOR en los «Start Process» que encadenan comandos lanzados desde el site. Los procesos padre ya hacen sus escrituras como iniciador, así que los hijos no deberían necesitar permisos de diseñador; queda por confirmar en la prueba funcional (§7). Si algún hijo fallara por permisos, se revierte solo ese nodo a «diseñador» (copias en `backups-r52/`).

| Proceso | Nodos | Versión antes→después |
|---|---|---|
| SCA2 CMD Alta | 12 Start Decidir | v46→v47 |
| SCA2 CMD Decidir | 11 Start Decidir, 12 Start CrearAccion, 15 Start Finalizar | v18→v21 |
| SCA2 CMD CrearAccion | 14 Start Finalizar, 15 Start Decidir | v31→v33 |
| SCA2 CMD CompletarAccion | 8 Start Finalizar, 10 Start CrearAccion, 12 Start Decidir | v51→v54 |
| SCA2 CMD Mecanizar | 322 Start CrearAccion | v49→v50 |
| SCA2 CMD MecanizarNSE | 36 Start CrearAccion | v8→v9 |
| SCA2 CMD MarcarErrorRelanzado | 10–17 (relanzar desde `/errores`) | v27→v35 |
| SCA2 CMD RefrescarCacheCabecera | 12 (§4) | v7→v8 |
| SCA2_ContraAnulacionSGO (interfaz) | TTQ_KO (§4) | v6→v7 |

Se guarda una versión por nodo (`updateProcessModelNode` publica en cada guardado). La comparación exportada (`backups-r52/*_vN_vM.diff`) solo muestra `runAs` y, en RefrescarCacheCabecera y SGO, los campos `id`/`intentos`; variables de proceso sin cambios.

No se cambia: `SCA2 Batch Mecanizacion NSE` nodo 6 (proceso programado: su iniciador es el del arranque del batch, no hay usuario del site) ni los procesos sin «Start Process» (Posponer, Finalizar, Caducar, BarridoCaducidad, ObtenerDocumentoGD, GenerarPdf), que ya graban su propio iniciador.

## 6. Scripts SQL para el usuario

1. `docs/sca/sql/71-r50b-tareas-pendientes-fecimpresion.sql` (con el bloque 3 de `6db037b`): **válido sin cambios**. Con las tareas ya canceladas, el bloque 2 crea C7 `ux_sca2_tarea_pendiente_solicitud_tipo`. En la lectura final debe salir `tareas_pendientes_duplicadas: []` y `errores_pendientes_duplicados: 0`.
2. `docs/sca/sql/72-r52-unique-errores-pendientes.sql` (nuevo): bloque 0 lectura, bloque 1 crea `ux_sca2_error_pendiente_clave` (`ID_SOLICITUD`, `COMANDO`, `coalesce(NODO,'')`, `coalesce(CODIGO,'')`) `WHERE ESTADO = 'PENDIENTE'` solo si no hay duplicados (si los hay, los lista y no hace nada), bloque 2 lectura final en JSON, rollback comentado. `coalesce` porque en PostgreSQL 14 dos NULL no chocan en un UNIQUE y la regla de Appian sí los considera iguales.
   Prueba local (PostgreSQL 14.25 y 16.16, Docker, nunca TEST): con duplicados → lista los 2 grupos y no crea; sin duplicados → crea; segunda ejecución → «ya existe»; insertar un PENDIENTE repetido (con NODO nulo) → `duplicate key`; insertar el mismo como DESCARTADO → OK; `DROP INDEX` → OK.

Orden recomendado en TEST: 71 y después 72, ambos en DBeaver con Auto-commit; pasar el JSON del último SELECT de cada uno.

## 7. Pruebas en el site

**No se han podido hacer las pruebas funcionales con solicitudes nuevas.** Ninguna solicitud creada.

| Prueba | Usuario | Resultado |
|---|---|---|
| Entrar al site SCA2 | JJGONZ2 (SSO NOPRO) | **Bloqueado**: error al cargar el buscador en `SCA2_obtenerInformacionUsuario` línea 31 ← `SCA2_obtenerRolPerfilSubperfil` línea 17 (`xpathsnippet`: «contextNode is null»). Evaluation ID `5541d:bd0f5`, `c4aa9:9adc7`, `d8752:d5742` |
| Entrar al site SCA2 | SISANS (SSO NOPRO) | **Bloqueado**: mismo error, evaluation ID `cb035:6247c` |
| Alta, POSPONER, RETOMAR, CA positiva y negativa, Acción Administrativa | — | **No probado** (no se puede llegar al alta) |
| Bandeja `/errores` | JJGONZ2 | «La página no existe o no tiene permiso»: es solo para administradores (ver `docs/sca/30-traspaso-continuidad.md`). No se ha entrado con `devin` |
| Tareas sin repetir (lectura del record) | — | **OK**: 934 tareas, 306 PENDIENTE, 0 grupos repetidos; 220/617/622/632 siguen PENDIENTE sin fecha de cierre; 375/711–714 CANCELADA |
| Errores sin repetir (lectura del record) | — | **OK**: 149 errores, 73 PENDIENTE, 0 grupos repetidos; error 88 (15788098 · ObtenerDocumentoGD) PENDIENTE con 4 intentos |

Causa del bloqueo: la integración de CORE `CMP_APIUsuarios_ObtenerRoles` (ESB `ARQ_Usuarios_SMEDWeb/sca/wUsuarios`) no devuelve cuerpo; `testRule` de `SCA2_obtenerRolPerfilSubperfil` con `JJGONZ2` y con `SISANS` da el mismo error desde el MCP. La regla es v1 de 23/09 y no la ha tocado R52: es una caída del servicio de roles de CORE, no un efecto de esta ronda.

Bandeja `/errores`: por defecto filtra `estado = PENDIENTE` y lista una fila por registro de `SCA2 Error`; con 0 grupos PENDIENTE repetidos, cada grupo aparece una sola vez. Las 40 filas `DESCARTADO` solo salen con el filtro «Descartado», igual que los descartes hechos desde la propia bandeja. Comprobación visual pendiente (requiere administrador).

### 7.1 Reintentos del servicio de roles (16–17/11/2026)

Instrucción: reintentar cada 15–20 minutos durante 3 horas como máximo, sin cambiar Appian. Se ha usado `testRule` de `SCA2_obtenerRolPerfilSubperfil` (NUUMA JJGONZ2; uno con SISANS).

| Hora (CET) | Resultado |
|---|---|
| 21:17:50 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 21:34:51 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 21:51:53 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 22:08:54 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 22:25:58 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 22:43:01 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 23:00:03 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 23:17:05 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 23:34:07 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 23:51:09 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 00:08:12 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 00:08:26 CET (SISANS) | Caído: `xpathsnippet` línea 17, «contextNode is null» |
| 00:15:15 CET | Caído: `xpathsnippet` línea 17, «contextNode is null» |

**Último intento: 17/11/2026 00:15:15 CET, sigue caído.** Las 3 horas terminan a las 00:17 sin que el servicio haya respondido. No se ha creado ninguna solicitud, no se ha leído el Detalle de 15788025, 15788607, 15788673 y 15788677 en el site y no ha hecho falta volver ningún nodo a «diseñador».

**Pendiente de repetir cuando vuelva el servicio de roles:** alta, POSPONER, RETOMAR, CA positiva y negativa y Acción Administrativa con JJGONZ2/SISANS, comprobando en el histórico, `SCA2 Transicion.usuario` y `SCA2 Solicitud.modifiedBy` el usuario del site y nunca `devin`.

## 8. Dudas y limitaciones

- `resueltoPor` de los 40 errores descartados es `GGALV10@mapfre.net` (quien autorizó el descarte). Si se prefiere vacío, se puede cambiar.
- Con el índice 72 creado, si un proceso intentara crear un segundo error PENDIENTE igual (ya no debería), la escritura fallaría; en SGO el fallo solo añade un aviso al mensaje de tréboles (`onError`).
- **Las pruebas funcionales con solicitudes nuevas están pendientes** (§7): el cambio de usuario real no está demostrado todavía.
- El batch `SCA2 Batch Mecanizacion NSE` sigue como diseñador: lo que graba es el usuario de arranque del batch, no un usuario del site.
