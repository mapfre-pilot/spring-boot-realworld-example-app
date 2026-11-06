# H6 — Planes del analista: Gestión de solicitudes (buscador), Detalle de solicitud, Gestión aplicación y Gestión de conceptos (SCA vs SCA2, TEST)

Ronda 8, sesión H6. Fecha: 13/10/2026. Entorno Appian TEST (`mapfrespain-test`). Planes ejecutados: `planes/gestion-de-solicitudes.md` (13), `planes/gestion-solicitud-detalle-solucitud.md` (17), `planes/gestion-aplicacion.md` (10) y `planes/gestion-de-conceptos-y-clases.md` (4): **44 casos**.
Método: análisis estático por LCP (interfaces/reglas SCA vs SCA2) + pruebas UI con el agente de pruebas (JJGONZ2 oficina, SISANS SI24 Experto, `devin` administrador con login nativo para «Gestiones mantenimiento»). Capturas `h6_<fase>_<caso>_sca|sca2.png` y grabación `h6-mantenimiento` fuera del repo (adjuntas al mensaje final de la sesión).

## 1. Resumen

| Veredicto | Casos |
|---|---|
| OK igual | 22 |
| DIVERGENCIA corregida (SCA2) | 4 |
| DIVERGENCIA pendiente | 5 |
| NO PROBADO | 13 |

Correcciones publicadas en SCA2 TEST (ver §5): menú de mantenimiento (Gestión de conceptos operativa), paginación del buscador, validación de póliza inexistente al buscar y datos de la fila del buscador desde CORE (misma fuente que SCA).

## 2. Solicitudes creadas (pólizas asignadas a H6)

| Id | Solicitud CORE | Póliza | App de alta | Estado al cierre |
|---|---|---|---|---|
| S1 | 15787886 | 0001047017068 | SCA2 (JJGONZ2) | Alta finalizada; CORE decidió **Acciones Administrativas** (origen IMPAGO), AA incompleta asignada a JJGONZ2. No completada |
| S2 | 15787888 | 0001047017069 | SCA (JJGONZ2) | Alta registrada en CORE (Pendiente). Aparece en SCA2 en la tabla «Otras solicitudes…» y abre el Detalle de sólo consulta |
| S3 | 15787901 | 0005726685339 (RCI) | SCA2 (JJGONZ2) | Alta finalizada; CORE decidió **Acciones Administrativas** (no Contra Anulación), AA incompleta. No completada |

Datos de prueba de mantenimiento: valores `PRUEBA_DEVIN_H6_V1` (SCA2) y `_V2` (SCA) en el concepto «Tipo Contrato Localizador» y conceptos funcionales `PRUEBA_DEVIN_H6_CF` (SCA2) / `_CF2` (SCA): creados, modificados y **eliminados**; `PRUEBA_DEVIN_H6_CF_CANCEL` cancelado sin crear. No se dio de alta ningún concepto (irreversible). Comprobada la limpieza final en ambas apps.

## 3. Resultados por caso

### 3.1 Gestión de solicitudes (`gestion-de-solicitudes.md`, hoja Sheet1)

| Id | Caso | SCA | SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| 1 | Campos | Pestaña Cliente: 5 campos en una fila (nombre, apellido 1, apellido 2, tipo y nº documento); Póliza: nº póliza / matrícula / bastidor | Cliente: 3 + 2 filas y selector «Tipo Póliza» adicional; Póliza igual | **DIVERGENCIA pendiente** (sólo maquetación; mismos campos) | h6_A_1_sca/sca2 |
| 2 | Últimas solicitudes | Lista de CORE (`consultarUltimaGestion` por NUUMA): 542 filas de JJGONZ2 | Lista del record SCA2 Solicitud: 109 filas (sólo las gestionadas en SCA2) | **DIVERGENCIA pendiente** (decisión Excel 13 «Todas»: falta aplicarla también a la lista inicial, no sólo a las búsquedas) | h6_A_2_sca/sca2 |
| 3 | Listado con cero | `devin` tiene solicitudes en ambas (no hay usuario sin solicitudes). Variante: póliza inexistente `0000000000001` → aviso «La póliza no es una póliza válida…» y conserva la tabla | Antes: «No hay resultados para dicha búsqueda». Tras `SCA2_Buscador` v27: mismo aviso y conserva la tabla | **DIVERGENCIA corregida** | h6_A_3_sca, h6_A_3_sca2_v27 |
| 4 | Paginación | 1-10 de 519, siguiente/anterior | Antes: sólo «10 elementos», sin siguiente. Tras `SCA2_BuscadorTabla` v10 + `SCA2_Buscador` v26: «1-10 de 104», siguiente 11-20, anterior | **DIVERGENCIA corregida** (tamaño de página no configurable en ninguna) | h6_A_4_sca, h6_A_4_sca2_v26, h6_A_4siguiente/anterior_sca2_v26 |
| 5 | Búsqueda por cliente | NIF 00246810C → 15787878, 15787868 | Mismas solicitudes; las que no son de SCA2 van a la segunda tabla «Otras solicitudes de la póliza / cliente» (diseño ronda 7d) | OK igual (presentación en dos tablas por diseño) | h6_A_5_sca/sca2 |
| 6 | Búsqueda por póliza | 0005726678405 → 15787867 «Finalizado negativo con contraanulación» (CORE codEstSolic 4) | 15787867 «Pendiente» (tarea CA nivel 2 pendiente en SCA2); 15787873 en la tabla CORE | **DIVERGENCIA pendiente** (ya observada en ronda 7f; duda B5 del doc 22: qué estado manda cuando CORE y SCA2 no coinciden tras un salto de nivel) | h6_A_6_sca/sca2 |
| 7 | Resultado único | 0001047017036 → abre el Detalle directamente | Igual (regresión v27 OK) | OK igual | h6_A_7_sca, h6_A_7_sca2_v27 |
| 8 | Varios resultados · campos | Columnas Número solicitud, Estado, Fecha solicitud, Nº póliza, Línea negocio, Causa, Fecha resolución, Observaciones (CORE) | Mismas columnas; causa/fechas salían del record (S1: causa «-», fecha del record). Tras `SCA2_BuscadorTabla` v11 la fila de S1 coincide: «No Coche Nuevo», 2026-10-13 12:32:18, resolución «-» | **DIVERGENCIA corregida** | h6_A_8_sca/sca2, h6_A_12S1fila_sca_referencia_v11, h6_A_12S1fila_sca2_v11 |
| 9 | Botones | ALTA SOLICITUD ANULACIÓN y BUSCAR visibles para JJGONZ2 y SISANS | Igual | OK igual | h6_A_9_* |
| 10 | Alta desde la gestión | 0001047017069 → navega al alta → S2 15787888 (latencia alta, 403 propio de SCA durante el recorrido) | 0001047017068 → alta → S1 15787886 | OK igual | h6_A_10_* |
| 11 | Robinson con anulación a futuro | Sin póliza Robinson en TEST | — | NO PROBADO (sin datos) | — |
| 12 | Robinson sin pólizas vigentes | Sin póliza Robinson en TEST | — | NO PROBADO (sin datos) | — |
| 13 | Detalle desde el listado | Detalle de S2 con cabecera y gestiones | Detalle de S1 igual; S2 (creada en SCA) abre el Detalle de sólo consulta con datos de CORE (ronda 7g) | OK igual | h6_A_12_* |

Filtros (añadido): Estado = Pendiente + Línea = Automóviles sobre la póliza de S1: ambas localizan S1 (SCA termina en el Detalle por ser resultado único; SCA2 muestra la fila filtrada). OK en localización.

### 3.2 Detalle de solicitud (`gestion-solicitud-detalle-solucitud.md`, hoja manual_test)

| Id | Caso | SCA | SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| 1 | Entrada desde «Otras solicitudes» | Pestaña alimentada desde CORE (todas las solicitudes del cliente): S1 con causa «NO VOY A COMPRARME OTRO COCHE», fecha 13/10/2026 12:32:18, resolución «-» | Pestaña «Otras sol. Anulación» alimentada desde el record SCA2 por póliza: causa «-», fecha 12:32:26 (alta del record), resolución 12:32:37 aunque Pendiente | **DIVERGENCIA pendiente** (límite documentado en doc 21 §7g; propuesta en §6) | h6_D_1_sca/sca2 |
| 2 | Cabecera | S1: póliza/cliente, Pendiente, origen IMPAGO, canal PRESENCIAL, nivel 1, A FECHA | Mismos datos | OK igual | h6_D_2_* |
| 3 | Notificaciones | Sin pestaña propia en el Detalle (sólo dentro del detalle de Mecanización); 15787772 sin notificaciones comparables | Pestaña «Notificaciones» visible; contenido no contrastado | NO PROBADO (sin solicitud con notificaciones en TEST) | — |
| 4 | Detalle gestión Alta | S1: Alta finalizada, JJGONZ2 / OFICINA, observación «Prueba plan H6 buscador» | Igual | OK igual | h6_D_4_* |
| 5 | Detalle gestión Contra anulación | 15787867 (sólo lectura): CA nivel 1 finalizada negativa, argumento INCREMENTO PRIMA, Negativo | Igual. «Detalle suplemento» no muestra nada en ninguna app (ya conocido) | OK igual | h6_D_5_* |
| 6 | Detalle gestión Acciones Administrativas | 15787868 incompleta; 15787771 finalizada sin documentos | Igual | OK igual | h6_D_6_* |
| 7 | Detalle gestión Autorización | 15787772: Autorización **Pendiente** (no hay gestión 7 finalizada en TEST) | Igual (Pendiente) | NO PROBADO (precondición «Autorización finalizada» no existe en TEST) | h6_D_7_* |
| 8 | Detalle gestión Mecanización (realizada) | 15787772: ANULACIÓN REALIZADA | Igual | OK igual | h6_D_8_* |
| 9 | Detalle gestión Mecanización (incompleta) | 15787771: MECANIZACIÓN INCOMPLETA, NSE-Autos, mismas fechas y usuario; hito «Anulación» con icono gris | Mismos datos; hito «Anulación» con reloj rojo | **DIVERGENCIA pendiente** (sólo icono/color del hito) | h6_D_9_sca/sca2 |
| 10 | Póliza pendiente RdP | Sin solicitud pendiente de reserva de prima en TEST | — | NO PROBADO (sin datos) | — |
| 11 | Pendiente RdP · Cancelación | Idem | — | NO PROBADO (sin datos) | — |
| 12 | Recuperar (salto de nivel) | — | Alta RCI 0005726685339 → S3 15787901: CORE decidió **Acciones Administrativas**, no Contra Anulación → sin salto a nivel 2; se paró sin completar | NO PROBADO (CORE no abre CA para la póliza; la regla SI24 ↔ CA2 ya se probó en ronda 7f) | h6_D_12AA_sca2, h6_D_12S3_sca2 |
| 13 | No recuperar | SISANS sobre S1 (gestión nivel 1 asignada a JJGONZ2, sin salto): sin RETOMAR/REASIGNAR | Igual | OK igual (variante con Acción Administrativa en vez de CA) | h6_D_13_sca/sca2 |
| 14 | Imprimir | SCA Appian no tiene botón Imprimir en el Detalle: la carta se genera en la CA negativa | Igual (sin botón); S3 no llegó a CA negativa | NO PROBADO (sin equivalente en el Detalle; flujo de impresión cubierto por H3) | — |
| 15 | Reintentar | Sin botón en el Detalle (SCA usa alertas) | Sin botón; el relanzamiento está en la bandeja `/errores` (sólo administradores; inspeccionada con `devin`, sin pulsar Relanzar) | NO PROBADO (sin equivalente; no se relanzó) | h6_D_17errores_sca2 |
| 16 | No reintentar | Sin Reintentar en S1 | Igual | OK igual | h6_D_15_* |
| 17 | Cancelar en error al vuelo | Sin botón Cancelar en el Detalle | Igual; descartar errores sólo en `/errores` | NO PROBADO (sin equivalente; no se descartó nada) | — |

### 3.3 Gestión aplicación (`gestion-aplicacion.md`, hoja manual_test) — usuario `devin`

| Id | Caso | SCA | SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| 1 | Desactivar y Cancelar | No ejecutado | No ejecutado | NO PROBADO — **bloqueo del protocolo**: H3 y H4 seguían EN CURSO al cierre de H6; además SCA y SCA2 escriben la **misma** variable CORE (`idnVariablePca 2`), así que desactivar desde SCA2 cambia también lo que muestra la pantalla «Aplicación» de SCA (no bloquea altas: el alta mira la variable 1) | — |
| 2 | Desactivar y Aceptar | No ejecutado | No ejecutado | NO PROBADO (idem) | — |
| 3 | Activar | No ejecutado | No ejecutado | NO PROBADO (idem) | — |
| 4 | Listado conceptos funcionales | Lista (DNI_Obligatorio, oleadaNuumaEstrategicas, …); «La aplicación está activa» | Igual | OK igual | h6_C_2_4_* |
| 5 | Alta concepto funcional · validación | «Se requiere un valor» al dejar obligatorios vacíos | Igual | OK igual | h6_C_2_5_* |
| 6 | Alta concepto funcional | `PRUEBA_DEVIN_H6_CF2` creado y listado | `PRUEBA_DEVIN_H6_CF` creado y listado | OK igual | h6_C_2_6_* |
| 7 | Alta y Cancelar | Vuelve sin crear | Igual | OK igual | h6_C_2_7_* |
| 8 | Modificar | Valor → «H6mod» persistido | Igual | OK igual | h6_C_2_8_* |
| 9 | Eliminar y Cancelar | El concepto sigue | Igual | OK igual | h6_C_2_9_* |
| 10 | Eliminar y Confirmar | Desaparece | Igual | OK igual | h6_C_2_10_*, h6_C_2limpieza* |

Nota: en ambas apps el apartado «Aplicación» usa el record type `SCA Concepto Funcional` y sus acciones (procesos de SCA) → mismos formularios y mismo backend REST (`gestionAplicacionGET/POST/PUT/DEL`).

### 3.4 Gestión de conceptos y clases (`gestion-de-conceptos-y-clases.md`) — usuario `devin`

| Id | Caso | SCA | SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| 1 | Búsqueda de conceptos | «Tipo Contrato Localizador» → 001 Detector, 007 «PÃ³liza ecolÃ³gica» (codificación defectuosa en CORE, común); concepto sin valores → «No hay elementos disponibles» | Antes de la ronda: el menú pasaba literales a `SCA2_GestionConceptosYClases` (los `a!save(ri!…)` del buscador de conceptos no podían persistir). Tras `SCA2_GestionMantenimientoMenu` v2: misma búsqueda, mismos valores y mensaje | **DIVERGENCIA corregida** | h6_C_1_1_* |
| 2 | Modificación de valor | `PRUEBA_DEVIN_H6_V2`: descripción modificada y persistida | `PRUEBA_DEVIN_H6_V1`: igual | OK igual | h6_C_1_2_* |
| 3 | Eliminación de valor | V2 eliminado | V1 eliminado | OK igual | h6_C_1_3_*, h6_C_1limpieza* |
| 4 | Alta concepto | Formulario «Alta de concepto»: AÑADIR deshabilitado con campos vacíos; CANCELAR con confirmación «Los datos introducidos no se guardarán» | Igual (misma acción del record `SCA Concepto`) | OK igual (sólo validación y cancelación: un concepto no se puede borrar después, no se creó) | h6_C_1_4_* |

Menú lateral: SCA 4 opciones (Argumentos, Gestión de conceptos, Aplicación, Batch); SCA2 5 (añade «Variables de la aplicación» y «Batch» como marcadores «no disponible»): NO PROBADO sin equivalente, como indicaba el encargo.

## 4. Estados CORE observados

- S1 15787886 y S3 15787901: gestión 8 (Alta) FINALIZADA + gestión 3 (Acciones Administrativas) INCOMPLETA, nivel 1, JJGONZ2. CORE decide AA para las tres pólizas asignadas (recibo impagado → origen IMPAGO), por lo que no se pudo provocar la Contra Anulación ni el salto de nivel de la RCI.
- S2 15787888: alta en CORE (codEstSolic 2, Pendiente), creada desde SCA.
- 15787772: 8 FIN, 2 FIN NEG, 4 FIN, 5 ANULACION REALIZADA, 7 (Autorización) FINALIZADA en CORE pero la pantalla muestra «Pendiente» en ambas apps. 15787771: 8, 3 FIN, 5 INCOMPLETA. 15787867: 8, 2 FIN NEG (n1), 4, 2 INCOMPLETA (n2, PCARAGE/CE_MF_BK).

## 5. Divergencias corregidas en SCA2 TEST (skill `appian`: GET vivo → backup → PUT completo → relectura → `testInterface` → UI)

| # | Objeto · uuid | Versión | Cambio | Prueba |
|---|---|---|---|---|
| 1 | `SCA2_GestionMantenimientoMenu` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060073` | v1 → v2 | Declara en el menú las variables `idConcepto`, `descConceptoPca`, `modificar`, `modificarConcepto`, `altaValor`, `eliminar`, `identificador` y las pasa a `SCA2_GestionConceptosYClases` (antes literales `null/false`), como `SCA_GestionMantenimientoMenu` | `testInterface` OK; UI: buscar/añadir/modificar/eliminar valores sin error de evaluación (grabación h6-mantenimiento) |
| 2 | `SCA2_BuscadorTabla` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | v8 → v10 | Input nuevo `totalCount` (Number); si viene informado construye un `DataSubset` (startIndex/batchSize/sort del pagingInfo + totalCount + data) para que el grid pagine en servidor; `initialSorts` sólo en el modo lista | UI A4: 1-10 de 104, siguiente/anterior |
| 2b | `SCA2_Buscador` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | v23 → v26 | Pasa `totalCount` del DataSubset a la tabla. (v24 —DataSubset por el input `data` Any Type— dejó la tabla con una fila de guiones y se revirtió en v25 = contenido v23) | idem |
| 3 | `SCA2_Buscador` | v26 → v27 | Validación del campo «Número póliza» como `SCA_BuscarSolicitudClientePoliza`: `SCA2_pObtenerPolizaFecha` + `SCA2_obtenerTipoPoliza`/ramo → «El formato de la póliza no es el esperado» / «La póliza no es una póliza válida o no se encuentra disponible…»; con error no se filtra y se conserva la tabla | UI A3 v27 y regresión A7 |
| 4 | `SCA2_BuscadorTabla` | v10 → v11 | Columnas Fecha solicitud, Causa anulación y Fecha resolución toman la fila de CORE (`consultarUltimaGestion`, ya cargada para Observaciones: `fecSolicitud`, `codCausaPca` → `cons!SCA2_TXT_CAUSA_ANULACION`, `fechaResolucion`); el record SCA2 queda de respaldo | UI fila S1 igual que SCA (v11) |

Backups y relecturas en `~/sca2work/h6/` (fuera del repo). Reservas y liberaciones anotadas en `coordinacion-ronda8.md` (las tres primeras se publicaron antes de recibir el protocolo y se registraron a posteriori).

## 6. Divergencias pendientes (pregunta funcional)

1. **Lista inicial «Últimas solicitudes gestionadas»** (caso 2): SCA muestra todas las solicitudes del gestor que hay en CORE (542); SCA2 sólo las gestionadas en SCA2 (109). ¿Debe SCA2 mostrar también en la lista inicial las solicitudes de SCA/históricas (como ya hace en las búsquedas con la tabla «Otras solicitudes…»)? Propuesta técnica: segunda tabla con `SCA2_consultarUltimaGestionREST(nuuma)` menos las que ya son de SCA2.
2. **Pestaña «Otras sol. Anulación» del Detalle** (detalle caso 1): SCA lista las solicitudes del cliente desde CORE (con causa y fechas de CORE); SCA2 lista los records SCA2 de la póliza, con causa vacía y fecha de resolución aunque esté Pendiente. ¿Debe alimentarse desde CORE como SCA (ya está disponible en `estructuraCabecera.otrasSolicitudesCabecera`)? Si la respuesta es sí, el cambio es `SCA2_TablaOtrasSolAnulacion` + la llamada en `SCA2_DetalleSolicitud`.
3. **Estado en el buscador tras un salto de nivel** (caso 6, 15787867): SCA «Finalizado negativo con contraanulación» (estado CORE) vs SCA2 «Pendiente» (la CA de nivel 2 sigue abierta). ¿Qué debe ver el gestor mientras la CA de nivel 2 está pendiente? (duda B5 del doc 22). Relacionado: 15787878 «Pendiente» (SCA) vs «Mecanización Enviada» (SCA2) (dudas C4/C5).
4. **Maquetación de la pestaña Cliente** (caso 1): 5 campos en una fila (SCA) vs 3+2 y selector «Tipo Póliza» (SCA2). ¿Se exige la misma disposición? (sin impacto funcional).
5. **Icono del hito «Anulación»** en Mecanización incompleta (detalle caso 9): gris (SCA) vs reloj rojo (SCA2). ¿Se exige el mismo icono?

Observaciones no corregidas (comunes a ambas apps): «PÃ³liza ecolÃ³gica» (codificación del dato en CORE); 15787772 con gestión 7 FINALIZADA en CORE pero «Pendiente» en pantalla en las dos; «Detalle suplemento» sin contenido; latencia y «403 Acceso denegado» de SCA durante el alta.

## 7. Limitaciones y bloqueos

- **Desactivar/Activar aplicación** (gestión aplicación 1–3): no ejecutado. Al cerrar H6, H3 y H4 seguían EN CURSO (protocolo: nadie desactiva hasta que las otras 5 estén TERMINADA). Además la variable CORE es común a SCA y SCA2: hace falta confirmación expresa antes de ejecutarlo.
- Las tres pólizas asignadas (incluida la RCI) van a Acciones Administrativas por decisión de CORE: no se pudo probar RETOMAR con salto de nivel (caso 12) ni la impresión del flujo negativo.
- Sin datos en TEST para Robinson, reserva de prima, notificaciones ni Autorización finalizada.
- Visibilidad de «Gestiones mantenimiento»: SCA `rule!SCA_isUsuarioProceso()` (rol PROCESO de CORE), SCA2 sólo `SCA2 Administrators` (decisión del doc 11). JJGONZ2 no ve la página en SCA2; las pruebas de mantenimiento se hicieron con `devin` en las dos apps.
- SCA2 reutiliza los record types y acciones de SCA (`SCA Concepto`, `SCA Concepto Funcional`) en mantenimiento: no se modificaron.

## 8. Evidencias

- Grabación anotada: `h6-mantenimiento/h6-mantenimiento-edited.mp4` (Gestión de conceptos y Gestión aplicación en SCA y SCA2, usuario `devin`).
- Capturas (86, `h6-capturas-vigentes.zip`): `h6_A_*` buscador, `h6_D_*` detalle/permisos, `h6_C_*` mantenimiento; las vigentes para A3 son `_v27`, para A4 `_v26` y para la fila de S1 `_v11`.
