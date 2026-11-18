# R50-B · Tareas y errores sin duplicados (C7), observaciones `FECIMPRESION` y FKs (C8)

Entorno: Appian TEST (`appian-dev-mcp-c90b`), site SCA2 `/suite/sites/sca2`; referencia SCA `/suite/sites/sca-site`. Fecha: 16/11/2026.
Solicitudes del analista solo consultadas (no se han tocado): 15788025, 15788607, 15788673, 15788677, 15788894.

## 1. Resumen

| Tema | Decisión | Cambio | ¿Cambia lo que ve el usuario? |
|---|---|---|---|
| Tareas PENDIENTE duplicadas | Antes de escribir una tarea PENDIENTE se busca la que ya haya del mismo tipo y solicitud y se reutiliza (UPDATE con su `id`) | 5 nodos en CrearAccion y Mecanizar + ER nueva `SCA2_obtenerIdTareaPendiente` | No |
| Errores repetidos en `SCA2 Error` | Si ya hay un error PENDIENTE igual (solicitud, comando, nodo, código) se actualiza esa fila con `intentos + 1` | 13 nodos «Write Error» en 9 PMs + ER nueva `SCA2_obtenerErrorPendiente` | No (la bandeja `/errores` muestra una fila con más intentos en vez de varias iguales) |
| C7 · índice UNIQUE parcial | SQL preparado; **no se crea mientras haya duplicados** | `docs/sca/sql/71-r50b-tareas-pendientes-fecimpresion.sql` bloque 2 | No |
| `FECIMPRESION` (observaciones) | Recorte defensivo a 255 en Alta y Posponer (como ya hacía CompletarAccion) + SQL para ampliar a 1000 | 2 nodos + SQL bloque 1 | No (la pantalla ya limita a 240/250) |
| Error 215 | Era `FECIMPRESION` (> 255) en CompletarAccion v49; ya corregido en v50 | Ninguno adicional | — |
| C8 · FKs a `sca2_solicitud` | **No se aplican**: romperían el paso `PDTE-*` → id de CORE | Ninguno | — |

## 2. Tareas PENDIENTE sin duplicados

### Origen de los 4 duplicados de TEST (solo consulta)

| Solicitud | Tipo | Ids PENDIENTE | Qué pasó |
|---|---|---|---|
| 15788025 | MECANIZAR | 220, 375 | 220 del 15/10; 375 del 21/10, creada de nuevo por `SCA2 CMD CrearAccion` en una vuelta de VERTI |
| 15788607 | CONTRAANULAR | 617, 711 | El 05/11 `deployment.user` relanzó `SCA2 CMD Decidir` con la solicitud ya `EN_ACCION`; CrearAccion volvió a insertar la tarea |
| 15788673 | CONTRA ANULAR NIVEL 2 | 622, 712 | Igual que la anterior |
| 15788677 | CONTRA ANULAR NIVEL 2 | 632, 713, 714 | Dos relanzamientos de Decidir con segundos de diferencia → 3 tareas |

Causa común: los nodos que crean la tarea hacían siempre INSERT, sin mirar si ya había una PENDIENTE del mismo tipo.

### Cambio
- ER nueva `SCA2_obtenerIdTareaPendiente(idSolicitud, tipo)` (`_a-0000f0b4-5b71-8000-9d56-011c48011c48_5746459`): devuelve el `id` de la tarea PENDIENTE más antigua de esa solicitud y tipo, o null.
- En los Write que crean tareas PENDIENTE se añade `id: rule!SCA2_obtenerIdTareaPendiente(...)`. Si hay una, `a!writeRecords` la actualiza (mismos datos que antes); si no, inserta como siempre.

| PM | Nodo | Tipo de tarea |
|---|---|---|
| `SCA2 CMD CrearAccion` | 7 «Write Tarea» | `procesoActivo` |
| `SCA2 CMD CrearAccion` | 9 «Write PDTE_MECANIZAR + Tarea» | `procesoActivo` |
| `SCA2 CMD CrearAccion` | 31 «Write Tarea VERTI (previa)» | VERTI |
| `SCA2 CMD Mecanizar` | 7 «Write Tarea VERTI» | VERTI |
| `SCA2 CMD Mecanizar` | 332 «Write Tarea INDUCCION» | INDUCCION |

No se tocan los Write que ya actualizan por `id` (CrearAccion 16 y 34, CompletarAccion 5, Posponer 5, Mecanizar 5/13/306/320/333, MecanizarNSE 32) ni `SCA2 CMD CambiarNivel` (lo borra R50-C por no tener uso).

### Duplicados existentes: qué hacer
- No se han tocado. Con el cambio, a partir de ahora cualquier nueva escritura reutiliza la tarea **más antigua** (220, 617, 622, 632).
- Las 4 solicitudes son del analista (no son pruebas propias de SCA2), así que no las cierro yo. **Propuesta** (duda D1): cerrarlas desde Appian marcando como `CANCELADA` las tareas más nuevas (375, 711, 712, 713, 714), o dejarlas hasta que el analista termine esas solicitudes. Mientras existan, el bloque 2 del SQL avisa y **no** crea el índice.

## 3. Errores sin duplicados en `SCA2 Error`

- Antes: cada reintento que fallaba insertaba otra fila igual con `intentos = 1` (p. ej. 15788098 · ObtenerDocumentoGD · consultaDocumento · GD_ERROR: ids 88, 89, 90, 91).
- ER nueva `SCA2_obtenerErrorPendiente(idSolicitud, comando, nodo, codigo)` (`_a-0000f0b4-5b71-8000-9d56-011c48011c48_5746465`): devuelve `a!map(id, intentos)` del error PENDIENTE equivalente (id null e intentos 0 si no hay).
- Cada «Write Error» que escribe un error PENDIENTE pasa a escribir `id` = ese id e `intentos` = intentos + 1. Si no hay, inserta como antes con `intentos = 1`.
- La bandeja `/errores` no cambia: lee las mismas columnas; solo verá una fila (con más intentos) en vez de varias iguales.

| PM | Nodos |
|---|---|
| `SCA2 CMD CrearAccion` | 8 |
| `SCA2 CMD Mecanizar` | 12 |
| `SCA2 CMD Posponer` | 199 |
| `SCA2 CMD Decidir` | 7 |
| `SCA2 CMD ObtenerDocumentoGD` | 200 |
| `SCA2 CMD CompletarAccion` | 199 (los dos errores del nodo) |
| `SCA2 CMD Alta` | 6 |
| `SCA2 CMD Caducar` | 9 |
| `SCA2 CMD Finalizar` | 9, 17 |
| `SCA2 CMD MecanizarNSE` | 99 |

No se tocan: Decidir 8 (escribe `BLOQUEADO`, no PENDIENTE), `SCA2 CMD RefrescarCacheCabecera` (R50-A), `SCA2 CMD MarcarErrorRelanzado` (marca RELANZADO), `SCA2 CMD RegistrarDesincronizacion` y `SCA2 CMD CambiarNivel` (los borra R50-C).

## 4. SQL para el usuario · `docs/sca/sql/71-r50b-tareas-pendientes-fecimpresion.sql`

DBeaver, conexión `appianmapfredbpre`, Auto-commit, Alt+X. Orden:
1. **Bloque 0 (lectura)**: devuelve un único JSON (`fecimpresion`, máximo usado, índice C7, duplicados de tareas y de errores). Exportarlo y guardarlo.
2. **Bloque 1**: amplía `sca2_datos_solicitud.FECIMPRESION` de 255 a 1000 (solo si es menor; en PostgreSQL ampliar un VARCHAR no reescribe la tabla). Aviso `[1]`.
3. **Bloque 2 (C7)**: si hay tareas PENDIENTE duplicadas, las lista con `RAISE NOTICE` y **no** crea el índice. Si no hay, crea `ux_sca2_tarea_pendiente_solicitud_tipo` (`ID_SOLICITUD`, `TIPO`) `WHERE ESTADO = 'PENDIENTE'` (tabla pequeña: creación normal, el bloqueo dura milisegundos). Hoy, con los 4 grupos de §2, avisará y no hará nada; repetir cuando se cierren.
4. Repetir el bloque 0 y comparar.

Rollback (comentado al final): R2 `DROP INDEX`; R1 vuelve a 255 solo si ningún valor supera 255.

Probado en PostgreSQL 14 local (Docker) con el DDL `56-ddl-sca2-produccion.sql`: con duplicados avisa y no crea; tras cerrar el duplicado crea el índice; segunda ejecución no hace nada; el índice rechaza una segunda tarea PENDIENTE igual y admite FINALIZADA; R1 no reduce si hay textos de más de 255.

Tras ampliar a 1000 no hace falta tocar Appian (el record type lee la columna; el recorte a 255 se queda como margen, sin cambiar lo que se ve). Subir el recorte por encima de 255 es una decisión aparte (duda D2).

## 5. `FECIMPRESION` y error 215

- `SCA2 CMD CompletarAccion` nodo 5 ya escribía `left(observaciones, 255)` desde la v50.
- Cambio: `SCA2 CMD Alta` nodo 8 «Write Datos» y `SCA2 CMD Posponer` nodo 5 «Write Posponer» envuelven el valor de `FECIMPRESION` en `left(..., 255)`. La pantalla ya limita a 240 (alta) y 250 (posponer), así que el usuario no nota nada; solo evita un `WRITE_FAIL` si llegara un texto más largo por otra vía.
- Error 215 (11/11, solicitud 15788894, `SCA2 CMD CompletarAccion` · «Write Tarea» · `WRITE_FAIL` «value too long for type character varying(255)»): el resultado traía unas 1 400 letras de observaciones («Prueba de observaciones TTQ.» repetido) y el nodo 5 las escribía sin recortar en `FECIMPRESION` (VARCHAR 255). Las otras columnas de texto que escribe ese nodo en `sca2_tarea` (estado, fechas, propietario) son cortas. Ocurrió con CompletarAccion v49; la v50 ya recorta. No hace falta más cambio; con la ampliación a 1000 queda margen adicional.

## 6. FKs (C8): no se aplican

- `SCA2 CMD Alta`: si `generarStudAnul` (CORE) falla, la solicitud se graba con `idSolicitud = "PDTE-<id de proceso>"`. Al reintentar el alta (`idSolicitudExistente` empieza por `PDTE-`) se pide el número a CORE y la fila pasa a tener el id de CORE.
- En TEST hay 21 solicitudes `PDTE-*` y 21 errores con `ID_SOLICITUD = 'PDTE-*'`; también se registran llamadas de servicio con ese id.
- Una FK de `sca2_tarea`, `sca2_transicion` o `sca2_llamada_servicio` hacia `sca2_solicitud(ID_SOLICITUD)` sin `ON UPDATE CASCADE` impediría cambiar el id de la solicitud mientras haya hijas con `PDTE-*` (el alta reintentada fallaría). Con `ON UPDATE CASCADE` los hijos cambiarían de id, pero la caché, los errores y las trazas quedarían con ids distintos, y las llamadas que se registran antes de que exista la fila de la solicitud podrían fallar.
- Decisión: **no aplicar C8**. Las tablas ya tienen índices por `ID_SOLICITUD` (paso 1), que es lo que aporta rendimiento.

## 7. Objetos cambiados (versión antes → después)

| Objeto | Antes → después | Nodos |
|---|---|---|
| PM `SCA2 CMD CrearAccion` | 27.0 → 31.0 | 7, 8, 9, 31 |
| PM `SCA2 CMD Mecanizar` | 46.0 → 49.0 | 7, 12, 332 |
| PM `SCA2 CMD Posponer` | 17.0 → 19.0 | 5, 199 |
| PM `SCA2 CMD Decidir` | 17.0 → 18.0 | 7 |
| PM `SCA2 CMD ObtenerDocumentoGD` | 5.0 → 6.0 | 200 |
| PM `SCA2 CMD CompletarAccion` | 50.0 → 51.0 | 199 |
| PM `SCA2 CMD Alta` | 44.0 → 46.0 | 6, 8 (sobre la 44.0 de R50-A) |
| PM `SCA2 CMD Caducar` | 8.0 → 9.0 | 9 |
| PM `SCA2 CMD Finalizar` | 21.0 → 23.0 | 9, 17 |
| PM `SCA2 CMD MecanizarNSE` | 7.0 → 8.0 | 99 |
| ER `SCA2_obtenerIdTareaPendiente` | nueva → v1 | — |
| ER `SCA2_obtenerErrorPendiente` | nueva → v1 | — |

Cada guardado de nodo publica una versión (por eso algunos PMs suben varias). Antes de guardar se comprobó que cada nodo vivo era idéntico a la copia (`backups-r50/r50b-pm-*-antes.json`); después se reexportó (`r50b-pm-*-despues.json`) y solo cambiaron los nodos de la tabla, con la expresión prevista.

## 8. Pruebas con solicitudes nuevas
Usuarios funcionales SISANS (SI24 Experto) y JJGONZ2, UI real de SCA2 en TEST. Pólizas del bloque reservado R50-B. Después de cada paso se leyeron `SCA2 Tarea` y `SCA2 Error` (solo lectura). Detalle completo, vídeos y capturas en `capturas-r50/r50b/` (`informe-testing.md`).

| Escenario | Solicitud | Póliza | Pasos | Resultado | Tareas PENDIENTE | Errores nuevos |
|---|---|---|---|---|---|---|
| Alta | 15789172 | 0732300314838 | Alta Hogar, «ME HA SUBIDO MUCHO LA PRIMA», observaciones 240/240 | OK | CONTRAANULAR: 1 (910) | 0 |
| POSPONER con observación larga | 15789172 | 0732300314838 | Observaciones 250/250 → POSPONER | OK, «CORRECTO»; texto completo guardado (antes de R48 daba `WRITE_FAIL` si pasaba de 255) | CONTRAANULAR: 1 (misma 910) | 0 |
| RETOMAR | 15789172 | 0732300314838 | Bandeja → RETOMAR | OK, conserva las observaciones | CONTRAANULAR: 1 (misma 910, reutilizada) | 0 |
| Contra anulación positiva | 15789172 | 0732300314838 | POSITIVO → ACEPTAR | OK: `FINALIZADA_POSITIVO`, CORE `finalizarContraAnulPca` y `finalizarSolicitud` = true. El detalle mostró «Incompleta» el primer minuto y luego «Finalizada Positiva», igual que en SCA (ver observación O1) | 0 (910 COMPLETADA) | 0 |
| Contra anulación negativa | 15789179 | 0731800083179 | NEGATIVO → guardar | OK, pasa a Nivel 2 | CONTRA ANULAR NIVEL 2: 1 (917); 916 COMPLETADA | 0 |
| Acción Administrativa | 15789182 | 2002400004454 | JJGONZ2: VENTA DEL VEHICULO → presencial → cliente no entrega documentación → FINALIZAR | OK, AA Finalizada (no se pulsó ANULAR PÓLIZA) | MECANIZAR: 1 (921); 920 COMPLETADA | 0 |
| Bandeja `/errores` | — | — | La página solo la ven los miembros de `SCA2_GRP_ADMINISTRADORES` (igual que antes); SISANS y JJGONZ2 no lo son. Se ejecutó la interfaz con `testInterface`: carga y filtra por «Pendiente» | OK (sin cambios en la interfaz) | — | — |

Resultado: en las 3 solicitudes nuevas nunca hubo dos tareas PENDIENTE del mismo tipo y `SCA2 Error` no tuvo ninguna fila nueva (149 filas al empezar y al terminar).

**O1 · Estado «Incompleta» justo después de cerrar**: lo da la consulta del detalle a CORE/caché de cabecera (zona de R50-A), no los nodos cambiados aquí (el Write Error de CompletarAccion no se ejecutó). Ya se había visto en R49-D (T4b). Al reabrir sale bien.

**O2**: con SISANS el catálogo de Autos no ofrecía «VENTA DEL VEHICULO»; la AA se hizo con JJGONZ2 (como en R48). No es de R50-B.


## 9. No probado
- La rama «ya existe una tarea PENDIENTE» solo se ha visto en POSPONER/RETOMAR; no se ha relanzado a mano `SCA2 CMD Decidir`/`CrearAccion` (el caso real de los duplicados) ni se ha probado concurrencia. La consulta de la regla sí se probó con 15788677 (devuelve 632, la más antigua).
- La rama «error PENDIENTE repetido → intentos + 1» no se ha visto en una ejecución real porque no falló ningún servicio durante las pruebas. La regla se probó con 15788098 / ObtenerDocumentoGD (devuelve id 88, intentos 1) y Appian validó todas las expresiones al publicar.
- El recorte `left(..., 255)` con textos de más de 255 caracteres: la pantalla no deja escribir tanto.
- La bandeja `/errores` con un usuario administrador en el navegador (se comprobó con `testInterface`).
- El SQL solo se ha probado en PostgreSQL local; en TEST lo ejecuta el usuario.


## 10. Dudas
- **D1 · Duplicados actuales** (15788025, 15788607, 15788673, 15788677): ¿se cancelan desde Appian las tareas más nuevas (375, 711, 712, 713, 714) para poder crear el índice C7, o se espera a que el analista termine esas solicitudes? Propuesta: cancelarlas (no tienen efecto: SCA2 ya usa la más antigua).
- **D2 · Límite de observaciones**: tras ampliar la columna a 1000, ¿se quiere permitir más de 240/250 caracteres en pantalla? Hoy no se cambia (lo pidió así la ronda).
