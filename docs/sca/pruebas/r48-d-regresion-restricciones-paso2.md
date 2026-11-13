# R48-D — Regresión de SCA2 en Appian TEST tras el paso 2 de BD (NOT NULL y UNIQUE)

Entorno: Appian TEST (`mapfrespain-test`), site `/suite/sites/sca2`, usuario funcional `JJGONZ2` (SSO Mapfre NO PRO). Las lecturas técnicas se han hecho con el MCP de TEST (`appian-dev-mcp-c90b`), con `listRecordData`, `listProcessInstances`, `getProcessInstance` y `testRule`, y con los modelos de proceso e interfaces descargados en modo solo lectura. Fecha de la prueba: 13/11/2026, de 08:34 a 08:57 UTC (09:34–09:57 CET). Las horas van en UTC salvo que se indique CET.

Cambio validado: `docs/sca/sql/66-paso2-test-restricciones.sql`, que el usuario ejecutó en TEST hacia las 09:25 CET (08:25 UTC). Detalle en [66 §11](../66-indices-bd-sca2.md).
- **C2:** `NOT NULL` en `sca2_transicion.CLAVE_IDEMPOTENCIA`.
- **C3:** `NOT NULL` en `sca2_solicitud` (`ID_SOLICITUD`, `NUM_POLIZA`, `CREATED_AT`), `sca2_transicion.ID_SOLICITUD`, `sca2_tarea` (`ID_SOLICITUD`, `ESTADO`), `sca2_llamada_servicio.ID_SOLICITUD` y `sca2_datos_cabecera.ID_SOLICITUD`.
- **C4:** `UNIQUE` `ux_sca2_cat_motivo`, `ux_sca2_cat_detalle`, `ux_sca2_cat_causa`, `ux_sca2_cat_concepto`, `ux_sca2_cat_valor_concepto` y el parcial `ux_sca2_cat_tipo_argumento_activo` (`COD_TP_ARG WHERE ACTIVO`).

**Qué no se ha hecho:** no se ha cambiado ningún objeto Appian, no se ha ejecutado DDL, DML ni rollback, no se ha lanzado ninguna sincronización de record types, no se ha tocado SCA, SCAC, CORE, CMP, PRE, NSE ni ANL, y no se han modificado solicitudes antiguas.

## 1. Resumen

| Punto | Resultado |
|---|---|
| Regresión funcional con solicitudes nuevas | **OK. No hay regresión atribuible al paso 2.** Se han creado 3 solicitudes nuevas: **15789003** (Autos: POSPONER, RETOMAR, contra anulación NEGATIVA y finalización hasta Verti/vencimiento), **15789007** (Hogar: contra anulación POSITIVA hasta `FINALIZADA_POSITIVO`) y **15789009** (Autos: Acción Administrativa y finalización hasta `PDTE_MECANIZAR`). |
| Escrituras afectadas por C2/C3 | **OK.** Son 16 transiciones nuevas (3151–3166), 5 tareas (867–871), 6 llamadas a servicio (346–351), 3 solicitudes (524–526), 3 filas de caché de cabecera (749, 751, 753) y 3 de datos de solicitud (482–484). Todas tienen informadas las columnas `NOT NULL`, y las transiciones llevan `resultado=OK`. |
| Procesos SCA2 desde las 09:25 CET | 18 instancias nuevas en los 17 modelos `SCA2 CMD*` / `SCA2 Batch*`, **todas COMPLETED**. Ninguna ha quedado en error ni en `PAUSED_BY_EXCEPTION`. |
| SCA2 Error | **Ninguna fila nueva.** El máximo `id` sigue siendo 220 y no hay ningún `not-null violation`, `unique violation`, `duplicate key` ni `WRITE_FAIL` nuevo. |
| Mantenimiento de argumentos y catálogos | `JJGONZ2` no tiene acceso (`/page/gestiones-mantenimiento` es de `SCA2 Administradores`), así que solo se ha podido revisar el código y simular la recarga. **Hay un riesgo latente, no observado, con la UNIQUE parcial de tipo de argumento** por el código 999, que está repetido (§5). |
| Revisión del código | No se ha encontrado ninguna escritura normal que deje nulo `ID_SOLICITUD`, `ESTADO` de tarea, `CLAVE_IDEMPOTENCIA`, `NUM_POLIZA` o `CREATED_AT`. Hay un caso teórico en llamada a servicio (§6). |
| Tiempos | En línea con R48-C, R48-A y 65 (§4). |

## 2. Solicitudes nuevas

| Solicitud | Póliza | Línea / origen | Flujo | Estado final en SCA2 |
|---|---|---|---|---|
| **15789003** | 2002500377929 | Automóviles / NSE-Autos | Alta → contra anulación → RECARGAR ×2 → POSPONER → buscador por póliza → detalle → RETOMAR → NEGATIVO → carta firmada → FINALIZAR → «siguiente tarea: Gestión Verti/vencimiento» | `EN_ACCION`, proceso `MECANIZAR`, tarea 868 «Gestión VERTI/Vencimiento» `PENDIENTE`. **No se continuó la tarea Verti/vencimiento**, para no lanzar la inducción CMP ni anular la póliza en NSE. |
| **15789007** | 0731280519047 | Hogar / NSE-Hogar | Alta → contra anulación → RECARGAR → POSITIVO → finalización | `FINALIZADA_POSITIVO`, interfaz `FIN`, tarea `COMPLETADA`, versión 5. |
| **15789009** | 2002400121550 | Automóviles / NSE-Autos | Alta → Acción Administrativa (sin documentación, anulación a vencimiento) → FINALIZAR → «Se va a redirigir a la anulación» | `PDTE_MECANIZAR`, proceso `MECANIZAR`, tarea 871 `MECANIZAR` `PENDIENTE`. **No se pulsó ANULAR PÓLIZA**, como en R48-C. |

Las tres se han creado hoy en el site SCA2 con `JJGONZ2` sobre pólizas que no tenían ninguna solicitud en SCA2. Los números que faltan en la secuencia (15789001/02, 04–06 y 08) no están en SCA2 Solicitud. Es numeración de CORE y no corresponde a escrituras fallidas de SCA2: no hay ninguna fila en SCA2 Error ni ningún proceso en error.

## 3. Resultado por paso

Los tiempos «UI» se han medido con reloj de pared (Playwright), desde el clic hasta que aparece el texto esperado. Los de «proceso» son el inicio y fin de la instancia (`getProcessInstance`) o el `duracionMs` de la transición.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa / solución |
|---|---|---|---|---|---|---|---|---|
| A1 | Alta Autos con cabecera | Solicitud creada; fila en `sca2_solicitud` con `ID_SOLICITUD`, `NUM_POLIZA`, `CREATED_AT` | Pantalla de alta en 0,84 s; cabecera en 6,38 s; validaciones en 14,06 s; ACEPTAR → gestión de contra anulación en 24,34 s. Solicitud `id=524` con los tres campos informados | OK | 15789003 | `SCA2 CMD Alta` 9203426 (12,16 s); transición 3151 `SCA2 CMD Alta\|15789003\|1` | ALTA SOLICITUD ANULACIÓN → póliza → DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA → GUARDAR → ACEPTAR | — |
| A2 | Caché de cabecera (Autos) | Fila nueva con `ID_SOLICITUD` | `id=749`, `idSolicitud=15789003`, `origenCache=CACHE`, `validaHasta` 14/11 04:00 | OK | 15789003 | — | `listRecordData` | — |
| A3 | Decidir y CrearAccion tras el alta | Transiciones con clave y tarea `PENDIENTE` | 3152 `Decidir\|15789003\|1` (3,2 s); 3153 `CrearAccion\|15789003\|2` (0,56 s); tarea 867 `CONTRAANULAR` `PENDIENTE`; llamada 346 `SCA2_generarStudAnul` OK 200 | OK | 15789003 | Decidir 16542859; CrearAccion 779304 | — | — |
| A4 | RECARGAR ARGUMENTO (Autos) | Recarga sin error | 3,289 s y 3,404 s; botón deshabilitado a los ~0,29 s; 7 argumentos | OK | 15789003 | — | RECARGAR ARGUMENTO ×2 | — |
| A5 | POSPONER | Transición `Posponer`, tarea actualizada y nada a nulo | Diálogo → ACEPTAR → «CORRECTO» en 2,70 s → buscador. Transición 3154 `EN_ACCION→PENDIENTE`, clave `SCA2 CMD Posponer - 13/11/2026 9:39 CET\|15789003\|3` (1,75 s). Tarea 867: `estado=PENDIENTE`, `fechaCaducidad` 20/11, token `OFICINA:8652\|VILLALBA`. Solicitud v4, `contadorPosponer=1`. `FECIMPRESION` = «R48-D posponer Autos» | OK | 15789003 | `SCA2 CMD Posponer` 14454045 | Oficina VILLALBA → observación → POSPONER → ACEPTAR | — |
| A6 | Buscador por póliza y detalle tras posponer | La solicitud se ve con su estado | Por póliza: «Solicitud Pendiente», observación «R48-D posponer Autos». Detalle: «Alta Solicitud Finalizada», «Contra Anulacion Incompleta», con RETOMAR/REASIGNAR | OK | 15789003 | — | Filtro Número póliza → BUSCAR → abrir solicitud | En «Últimas solicitudes gestionadas» no salía arriba justo después de posponer (la primera era 15789000). Por póliza sí sale. Es orden de la lista, no una escritura. |
| A7 | RETOMAR | Vuelve a la gestión con los datos | Formulario de contra anulación al momento, con la oficina VILLALBA conservada | OK | 15789003 | — | Detalle → RETOMAR | — |
| A8 | Contra anulación NEGATIVA, carta y finalización | Guarda la gestión, cierra la tarea y crea la siguiente | NEGATIVO («INCREMENTO PRIMA SINIESTROS») en ~4 s → carta firmada (`SCA2 CMD GenerarPdf` 779336) → CONTINUAR → FINALIZAR → SÍ → «CORRECTO — Los datos se han guardado correctamente. Se va a redirigir a la siguiente tarea: Gestión Verti/vencimiento.» Transiciones 3155 `CompletarAccion EN_ACCION→DECIDIR`, clave `…\|15789003\|867`, y 3156 `Decidir PDTE_FINALIZAR→MECANIZAR`. Tarea 867 `COMPLETADA` (cerrada 08:45:01); tarea 868 VERTI `PENDIENTE`; llamada 347 `SCA2_finalizarContraAnulPcaIntegracion` OK 200 (555 ms) | OK | 15789003 | CompletarAccion 14454062 (10,93 s); Decidir 779343; CrearAccion 10257242 (tarea VERTI) | Argumento → NEGATIVO → imprimir carta → CONTINUAR → FINALIZAR → SÍ | Tiempo de pantalla entre FINALIZAR y el mensaje: entre 8 y 33 s, medición poco fiable por las esperas del script. Del proceso: 10,9 s, en el rango de R48-C (13,35 s). |
| B1 | Alta Hogar con cabecera | Solicitud y caché creadas | Pantalla 0,84 s; cabecera 5,04 s (HOGAR, SEMESTRAL); validaciones 15,95 s; ACEPTAR → gestión 21,48 s. Solicitud `id=525`, caché `id=751` | OK | 15789007 | `SCA2 CMD Alta` 9203452 (10,75 s); transición 3157 | DECISION DE CLIENTE / PRECIO / MEJOR PRECIO DE LA COMPETENCIA → GUARDAR → ACEPTAR | — |
| B2 | RECARGAR ARGUMENTO (Hogar) | Recarga sin error | 3,98 s (deshabilitado a 0,31 s); 7 argumentos | OK | 15789007 | — | RECARGAR ARGUMENTO | — |
| B3 | Contra anulación POSITIVA y finalización | Cierre `FINALIZADA_POSITIVO`, tarea `COMPLETADA`, llamadas a servicio OK | «¡Enhorabuena en la retención de la póliza!…» → ACEPTAR → buscador. Transición 3160 `EN_ACCION→FINALIZADA_POSITIVO` (1,89 s); tarea 869 `COMPLETADA`; llamadas 349 `SCA2_finalizarContraAnulPcaIntegracion` (479 ms) y 350 `SCA2_finalizarSolicitudIntegracion` (215 ms), OK 200. La caché 751 se invalida (`validaHasta` 08:50:33): la actualización parcial no toca `ID_SOLICITUD` | OK | 15789007 | Decidir 14454071; CrearAccion 537648184; CompletarAccion 17581444 (2,20 s) | Oficina VILLALBA → primer argumento → POSITIVO → ACEPTAR | Como en R48-C, no sale una instancia aparte de `SCA2 CMD Finalizar`: la finalización la hace CompletarAccion. |
| C1 | Alta Autos para Acción Administrativa | Solicitud y gestión AA | Pantalla 0,87 s; cabecera 6,48 s; validaciones con aviso documental de venta del vehículo 18,47 s; gestión «Acciones administrativas» abierta (~18–20 s después de ACEPTAR). Solicitud `id=526`, caché `id=753`; tarea 870 `ACCIONES ADMINISTRATIVAS` `PENDIENTE`; llamada 351 OK 200 | OK | 15789009 | `SCA2 CMD Alta` 269214952 (15,30 s); Decidir 15522349; CrearAccion 9203466 | DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE → GUARDAR → ACEPTAR | — |
| C2 | Acción Administrativa: decisión y finalización | Confirmación y redirección a la anulación; tarea MECANIZAR creada | Con la oficina y «El cliente no entrega documentación…» marcadas, FINALIZAR se habilita. Diálogo «¿Desea continuar? Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» → ACEPTAR → «CORRECTO. Los datos se han guardado correctamente. Se va a redirigir a la anulación.» Transiciones 3164 `CompletarAccion EN_ACCION→DECIDIR` (clave `…\|15789009\|870`), 3165 `Decidir EN_ACCION→MECANIZAR` (5,26 s) y 3166 `CrearAccion EN_ACCION→PDTE_MECANIZAR` (0,77 s). Tarea 870 `COMPLETADA`; tarea 871 `MECANIZAR` `PENDIENTE` | OK | 15789009 | CompletarAccion 12346965 (7,50 s); Decidir 15522356 (6,62 s); CrearAccion 15522357 | Oficina VILLALBA → «El cliente no entrega documentación» → FINALIZAR → ACEPTAR | No se pulsó ANULAR PÓLIZA para no anular la póliza en NSE (igual que 15788999 en R48-C). |
| D1 | Procesos SCA2 desde las 08:25 UTC | Ninguno en error | 18 instancias, todas COMPLETED (§3.1) | OK | Las 3 | §3.1 | `listProcessInstances` de los 17 modelos | — |
| D2 | SCA2 Error | Sin filas nuevas | Máximo `id` = 220 antes y después; ninguna fila con fecha 13/11/2026 | OK | — | — | `listRecordData` al empezar, a las 08:40, a las 08:51 y a las 08:57 | — |

No ha salido ningún error en pantalla durante la prueba.

### 3.1 Instancias nuevas desde las 08:25 UTC (09:25 CET)

| Modelo | Instancias (todas COMPLETED) |
|---|---|
| `SCA2 CMD Alta` | 9203426 (15789003), 9203452 (15789007), 269214952 (15789009) |
| `SCA2 CMD Decidir` | 16542859, 779343 (15789003); 14454071 (15789007); 15522349, 15522356 (15789009) |
| `SCA2 CMD CrearAccion` | 779304, 10257242 (15789003); 537648184 (15789007); 9203466, 15522357 (15789009) |
| `SCA2 CMD CompletarAccion` | 14454062 (15789003); 17581444 (15789007); 12346965 (15789009) |
| `SCA2 CMD Posponer` | 14454045 (15789003) |
| `SCA2 CMD GenerarPdf` | 779336 (carta firmada de 15789003) |
| Finalizar, Mecanizar, MecanizarNSE, Batch Mecanizacion NSE, Caducar, BarridoCaducidad, CambiarNivel, ObtenerDocumentoGD, MarcarErrorRelanzado, RegistrarDesincronizacion, RefrescarCacheCabecera | Ninguna en la ventana. No se han probado en ejecución; solo se ha revisado su código (§6). |

### 3.2 Columnas `NOT NULL` en las filas nuevas

| Tabla (record type) | Filas nuevas | Columnas C2/C3 | Valores observados |
|---|---|---|---|
| `sca2_solicitud` | 524, 525, 526 | `ID_SOLICITUD`, `NUM_POLIZA`, `CREATED_AT` | 15789003/2002500377929/08:36:19; 15789007/0731280519047/08:48:34; 15789009/2002400121550/08:54:36 |
| `sca2_transicion` | 3151–3166 (16) | `ID_SOLICITUD`, `CLAVE_IDEMPOTENCIA` | Siempre informadas. Las claves siguen el formato `comando\|idSolicitud\|versión` (en CompletarAccion es `…\|idTarea`). La más larga es la de Posponer, con 50 caracteres (el límite es 200). Todas tienen `resultado=OK`. |
| `sca2_tarea` | 867–871 (5) | `ID_SOLICITUD`, `ESTADO` | Al crear la tarea, `PENDIENTE`; al cerrarla, `COMPLETADA`. Las actualizaciones (Posponer y cierre) mantienen `ID_SOLICITUD`. |
| `sca2_llamada_servicio` | 346–351 (6) | `ID_SOLICITUD` | Siempre informado; todas `OK`, HTTP 200. |
| `sca2_datos_cabecera` | 749, 751, 753 | `ID_SOLICITUD` | 15789003, 15789007, 15789009 (`CACHE`). La invalidación de 751 es una actualización parcial y funciona. |

## 4. Tiempos comparados con mediciones anteriores

Referencias: [R48-C](r48-c-regresion-indices-paso1.md) (después del paso 1), [R48-A](r48-a-espera-alta-y-avisos.md) y [65](../65-valoracion-produccion-rendimiento.md).

| Medición | Antes | Ahora (tras el paso 2) | Valoración |
|---|---|---|---|
| `SCA2 CMD Alta` (proceso) | 65: mediana 11,3 s, p90 14,1 s, máx 15 s. R48-C: 11,37 / 11,14 / 15,00 s | 12,16 s (Autos CA); 10,75 s (Hogar); 15,30 s (Autos AA) | Igual. La de AA está en el máximo anterior (+0,3 s), dentro de la variación normal. |
| `SCA2 CMD Decidir` | 65: mediana 5,6 s, p90 10,4 s. R48-C: 3,91–4,12 s | Transiciones de 2,4 a 7,4 s; AA 6,62 s | Igual. |
| `SCA2 CMD CompletarAccion` | 65: mediana 9,7 s, p90 12,8 s. R48-C: 13,35 (CA neg.) / 4,97 (AA) / 2,77 s (CA pos.) | 10,93 / 7,50 / 2,20 s | Igual. |
| `SCA2 CMD CrearAccion` | 65: mediana 0,9 s | 0,52–0,77 s | Igual. |
| `SCA2 CMD Posponer` | Sin referencia | 1,75 s | Correcto. |
| UI: ACEPTAR → gestión abierta | R48-A: 23,2–32,4 s. R48-C: 23,8 / 33,1 s | 24,34 s (Autos); 21,48 s (Hogar); ~18–20 s (AA) | Igual o algo mejor. |
| UI: carga de cabecera | R48-C: ~7,8–8,6 s (medido desde el buscador) | 5,04–6,48 s (medido desde el botón ALTA del formulario) | No es comparable del todo: los puntos de medida son distintos. Sin empeoramiento. |
| RECARGAR ARGUMENTO | R48-C: 0,38–3,61 s | 3,29 / 3,40 / 3,98 s | Igual. |

Conclusión: el paso 2 no cambia los tiempos. Las restricciones `NOT NULL` y los índices `UNIQUE` añaden una comprobación por fila que no se nota con este volumen.

## 5. Mantenimiento de argumentos y catálogos

**No probado en pantalla:** `JJGONZ2` no tiene permiso en `/page/gestiones-mantenimiento` («La página no existe o no tiene permiso para verla»; es de `SCA2 Administradores`). No hay otro usuario funcional con acceso, así que no se ha hecho ni alta, ni edición, ni baja, ni reactivación. Lo que sigue sale de revisar el código y de una simulación de solo lectura.

**Quién escribe en los catálogos** (dependencias de los record types en `getObjectDependents`): solo `SCA2_CatMantenimiento` (pantalla de mantenimiento), la regla `SCA2_catConstruirCarga` (recarga desde CORE) y `SCA2_AltaGestionArgumento`, que vuelve a cargar tipo de argumento después de dar de alta o modificar un argumento en CORE. `SCA2_catMotivosAurora` y `SCA2_catConceptosAurora` solo leen.

| Escritura | Qué hace | ¿Puede chocar con C4? |
|---|---|---|
| `SCA2_CatMantenimiento` → GUARDAR (alta o edición) | Antes del `a!writeRecords` comprueba los duplicados por la clave del catálogo («Ya existe una fila con esa misma clave…») | No. En tipo de argumento la comprobación busca `COD_TP_ARG` sin filtrar por `ACTIVO`, así que es más estricta que la UNIQUE parcial. |
| `SCA2_CatMantenimiento` → Dar de baja / Reactivar | Escribe `id`, `activo=not(activo)`, fecha y usuario **sin comprobar si ya hay otra fila activa con el mismo código** | Motivo, detalle, causa, concepto y valor concepto: no, porque la UNIQUE va sobre la clave completa y la baja o reactivación no la cambia. **Tipo de argumento: sí.** Reactivar la fila `id=345` (`COD_TP_ARG=999`, inactiva) mientras la `id=344` (999, activa) siga activa daría `unique violation` en `ux_sca2_cat_tipo_argumento_activo`. El `onError` del botón muestra «No se ha podido actualizar: …» y no se guarda nada. |
| `SCA2_catConstruirCarga` (botón «Recargar desde CORE» y `SCA2_AltaGestionArgumento`) | Hace un upsert por clave natural: para cada fila que viene de CORE coge la **primera** existente con esa clave (`index(local!pos, 1, 1)`) y la deja `activo=true` | Hoy no. La simulación con `testRule` (no escribe) da `filasCore=346`, `existentesAntes=346`, `bajas=0`, 346 registros, ningún `COD_TP_ARG` repetido, y para el 999 elige la fila activa 344. **Pero es frágil:** la consulta de existentes no lleva `sortInfo`. Si el orden cambia y sale primero la 345, la carga intentaría activarla con la 344 activa y fallaría **toda la escritura del lote**. En `SCA2_AltaGestionArgumento` ese `a!writeRecords` **no tiene `onError`**, así que el fallo se vería como un error genérico después de un alta de argumento que en CORE sí se habría hecho. |

Datos actuales de SCA2 Cat Tipo Argumento: 346 filas, 345 activas, 0 de origen MANUAL. El único código repetido es el 999 «Prueba» (filas 344 activa y 345 inactiva, de origen CORE, creadas el 27/10 en pruebas anteriores).

**No es una regresión observada:** no ha fallado ninguna escritura. Es un riesgo que crea la UNIQUE parcial, y se propone corregirlo en Appian (§7) antes de que alguien reactive la fila 345.

## 6. Revisión del código (escrituras con posibles nulos)

Revisados los nodos «Write Records» y los `a!writeRecords` de los 17 modelos `SCA2 CMD*` / `SCA2 Batch*` y de las interfaces de gestión.

| Tabla | Altas (inserciones) | Modificaciones | Conclusión |
|---|---|---|---|
| `sca2_solicitud` | `SCA2 CMD Alta` («Write Solicitud» y «Write Solicitud Error»): `idSolicitud=pv!idSolicitud` (`PDTE-<proceso>` mientras CORE no da número), `numPoliza=pv!numPoliza`, `createdAt=a!defaultValue(existente, now())` | Parciales (`id` y los campos que cambian): no tocan `ID_SOLICITUD`, `NUM_POLIZA` ni `CREATED_AT` | Sin riesgo. |
| `sca2_transicion` | Todos los comandos (Alta, Decidir, CrearAccion, CompletarAccion, Posponer, Finalizar, Mecanizar, MecanizarNSE, Caducar, CambiarNivel): `idSolicitud=pv!idSolicitud` y `claveIdempotencia=rule!SCA2_claveIdempotencia(comando, id, versión)`, que concatena textos y nunca devuelve nulo (en el peor caso `"cmd\|\|"`); en CompletarAccion es `local!clave` | No se modifican | Sin riesgo de nulo. Si faltasen id y versión, la clave se repetiría y daría `unique violation` (UNIQUE del DDL 56, ya existía antes del paso 2). |
| `sca2_tarea` | CrearAccion, Mecanizar (VERTI, INDUCCION), Finalizar, MecanizarNSE, Caducar, CambiarNivel, RegistrarDesincronizacion: `idSolicitud=pv!idSolicitud` y `estado` como literal (`"PENDIENTE"` o `cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE`) | Parciales: estado literal (`COMPLETADA`, `PENDIENTE`, `FINALIZADA`), grupo, asignación o caducidad. No tocan `ID_SOLICITUD` | Sin riesgo. No hay ninguna escritura de tarea sin `ESTADO`. |
| `sca2_llamada_servicio` | Alta, CompletarAccion, Finalizar, Mecanizar, MecanizarNSE, Caducar: `idSolicitud=left(tostring(pv!idSolicitud), 50)` | No se modifican | **Riesgo teórico.** Si una llamada se registrase con `pv!idSolicitud` vacío, el texto vacío iría como nulo y la fila de log fallaría por C3. En los flujos revisados el id siempre llega (en el alta, `PDTE-<proceso>`) y las 6 llamadas nuevas lo llevan. No se ha visto ningún caso. |
| `sca2_datos_cabecera` | «Write Datos» del alta: `idSolicitud=pv!idSolicitud`; `SCA2_construirFilaCacheCabecera` copia el `idSolicitud` de la fila actual | `SCA2_renovarCacheCabecera` sale si el id está vacío, es `"0"` o tiene más de 20 caracteres; la invalidación es parcial (`id`, `validaHasta`) | Sin riesgo. |
| `sca2_error` | — | — | Fuera de C3 por diseño (hay errores sin solicitud). `MarcarErrorRelanzado` solo cambia `estado`. |

El único error de escritura en SCA2 Error de estos días es anterior al paso 2 y no tiene que ver con él: `id=215` (11/11/2026 15:00:02), `SCA2 CMD CompletarAccion`, nodo «Write Tarea». El literal es:

```text
No se puede escribir en ni eliminar del origen debido a una violación de integridad de datos. Detalles del error: ERROR: value too long for type character varying(255)
```

Es un problema de longitud de un texto de la tarea. Lo dejamos anotado como pendiente aparte, igual que `FECIMPRESION` en [R48-C §5.2](r48-c-regresion-indices-paso1.md).

## 7. Propuestas (sin aplicar)

No hay ninguna regresión, así que **no se propone rollback**. Si alguna vez falla una escritura por estas restricciones, el rollback de cada bloque está comentado en `sql/66-paso2-test-restricciones.sql`: `DROP NOT NULL` por columna en C3 y `DROP INDEX ux_sca2_cat_tipo_argumento_activo` en C4.

Propuestas preventivas en Appian, para decidir y sin aplicar:
1. **Tipo de argumento (§5):**
   - En `SCA2_catConstruirCarga`, buscar la fila existente dando prioridad a la activa (ordenar por `activo` descendente e `id`, o filtrar `activo=true` primero).
   - En «Reactivar» de `SCA2_CatMantenimiento`, comprobar si hay otra fila activa con el mismo `COD_TP_ARG` y avisar en lugar de escribir.
   - Añadir `onError` al `a!writeRecords` de `SCA2_AltaGestionArgumento`.
   - Otra opción, que es DML y necesita autorización: renombrar o borrar la fila de prueba `id=345` (999 «Prueba», inactiva).
2. **Llamada a servicio (§6):** si se quiere blindar, usar `a!defaultValue(pv!idSolicitud, "PDTE-" & pp!id)` en el `idSolicitud` del log de llamadas, como en el alta. No es urgente: no se ha visto ningún caso.

## 8. Lo que no se ha podido probar y dudas

**No probado:**
1. Mantenimiento de argumentos y catálogos (alta, edición, baja y reactivación): `JJGONZ2` no tiene acceso. Solo se ha revisado el código y simulado la recarga (§5).
2. `/errores` y cuadro de mando: sin acceso, igual que en R48-C. SCA2 Error se ha revisado por MCP.
3. Mecanización y anulación en NSE (`SCA2 CMD Mecanizar` y `MecanizarNSE`), inducción Verti/vencimiento (CMP) y `SCA2 CMD Finalizar`, Caducar, CambiarNivel y RegistrarDesincronizacion: no se han ejecutado para no anular pólizas ni lanzar CMP. 15789003 queda con la tarea Verti 868 `PENDIENTE` y 15789009 con la tarea MECANIZAR 871 `PENDIENTE`. Su código escribe `ID_SOLICITUD` y `ESTADO` igual que los comandos probados (§6).
4. Contra anulación negativa y Acción Administrativa de Hogar: el Hogar probado es la contra anulación positiva. Los procesos y tablas son los mismos que en Autos.
5. No se ha repetido en SCA porque no ha salido ninguna diferencia.

**Dudas:**
1. ¿Se corrige ya en Appian el riesgo de tipo de argumento (§7.1), o se limpia la fila de prueba 345? Mientras tanto, conviene que nadie reactive el 999 «Prueba».
2. El usuario de las transiciones encadenadas (Decidir y CrearAccion que lanza el propio proceso) es la cuenta técnica de Appian que ejecuta los modelos y no `JJGONZ2`. Ya era así antes (1.696 transiciones históricas) y no es del paso 2. ¿Se quiere que se registre el usuario de la gestión?
3. El error `varchar(255)` de «Write Tarea» del 11/11 (`id=215`): ¿se analiza en una tarea aparte junto con `FECIMPRESION`?

## 9. Evidencias

- Solicitudes: 15789003, 15789007, 15789009 (`sca2_solicitud` 524–526).
- Instancias: Alta 9203426, 9203452, 269214952; Decidir 16542859, 779343, 14454071, 15522349, 15522356; CrearAccion 779304, 10257242, 537648184, 9203466, 15522357; CompletarAccion 14454062, 17581444, 12346965; Posponer 14454045; GenerarPdf 779336.
- Filas nuevas: transiciones 3151–3166; tareas 867–871; llamadas a servicio 346–351; datos de cabecera 749, 751, 753; datos de solicitud 482–484.
- Las capturas y exportaciones CSV/JSON de la prueba se han guardado en la máquina de la sesión y no se suben al repositorio.
