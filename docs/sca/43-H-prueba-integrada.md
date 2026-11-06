# 43-H — Prueba integrada final de la fase 1 (sesión H)

Entorno: **Appian TEST** (`mapfrespain-test`), aplicación `SCA2 Sistema Comercial de Anulaciones SCA2` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`). Fecha: 2026-10-21 (horas en UTC salvo que se indique CEST). Sesión **solo de prueba y documentación**: no se ha modificado ningún objeto Appian ni ninguna constante. Lecturas por LCP REST (`/constants/{uuid}`, `/record-types/{uuid}/data`, `/expression-rules/{uuid}/test`, `/process-models/{uuid}/processes`, `/interfaces/{uuid}`); UI del site `sca2` con Playwright sobre el navegador de la sesión (usuario `devin`, perfil `CE_RM` / nuuma `JJGONZ2`). Capturas en `img/43-H-*.png`.

## 1. Objetivo y alcance

Verificar de extremo a extremo, **con las tres funcionalidades de la fase 1 activas a la vez**, dos solicitudes nuevas creadas desde la UI (una Autos NSE y una wAutemis): alta con catálogos Aurora (43-C/43-E), caducidad por nivel (43-A), propietario Appian y sombra (43-B), caché de cabecera (43-D), su refresco manual (43-F, botón) y su invalidación por comando (43-G); además, la página de mantenimiento «Catálogos CORE (Aurora)». Las reservas de datos están en [pruebas/coordinacion-fase1.md](pruebas/coordinacion-fase1.md).

## 2. Precondiciones comprobadas (GET /constants, 16:50 UTC)

| Constante | UUID | Versión | Valor |
|---|---|---|---|
| `SCA2_USAR_CATALOGOS_AURORA` | `_a-0000f093-2064-8000-9d36-011c48011c48_5603869` | 8 | `true` |
| `SCA2_USAR_CACHE_CABECERA` | `_a-0000f093-2064-8000-9d36-011c48011c48_5603399` | 20 | `true` |
| `SCA2_USAR_PROPIETARIO_APPIAN` | `_a-0000f093-2064-8000-9d36-011c48011c48_5603472` | 10 | `true` |

Líneas base de records antes de empezar (16:55 UTC): `SCA2 Solicitud` max id 269, `SCA2 Datos Cabecera` max id 244, `SCA2 Trazabilidad Cliente` max id 442, `SCA2 Transicion` max id 1601, `SCA2 Error` max id 121 (50 filas). Pólizas elegidas fuera de las ya usadas por A–G y de las tres bloqueadas.

## 3. Solicitudes creadas

| | Solicitud 1 (S1) | Solicitud 2 (S2) |
|---|---|---|
| Póliza | `2002600009080` (Autos NSE, LN 1, vence 20/01/2027) | `0001047017111` (wAutemis, LN 1, clave 0280999, vence 14/09/2027) |
| `idSolicitud` / `SCA2 Solicitud.id` | **15788224** / 270 | **15788225** / 271 |
| Alta (UI → `SCA2 CMD Alta`) | ACEPTAR 17:00:10 → alta 17:00:26 | ACEPTAR 17:24:46 → alta 17:25:07 |
| Motivo / Detalle / Causa | DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA | ídem |
| Canal / catalogación / fecha | PRESENCIAL / A VENCIMIENTO / 20/01/2027 | PRESENCIAL / A VENCIMIENTO / 14/09/2027 |
| Fila `SCA2 Datos Cabecera` | 245 | 248 |
| Estado final dejado | `EN_ACCION`, `interfazActiva = VERTI`, `procesoActivo = MECANIZAR` (mecanización **no** ejecutada) | ídem |

## 4. Resultados

Veredicto: **todo OK funcionalmente**; 4 observaciones (O1–O4) sin KO, detalladas en §5.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa |
|---|---|---|---|---|---|---|---|---|
| H-00 | Constantes de la fase 1 | las 3 en `true` | las 3 en `true` (v8 / v20 / v10) | OK | — | — | `GET /constants/{uuid}` | — |
| H-01 | Alta S1: desplegables Motivo/Detalle/Causa cargan desde Aurora | listas con datos | Motivo 3 (DECISION DE CLIENTE, DECISION DE LA ENTIDAD, DESAPARICION DEL RIESGO); Detalle 6; Causa M1/D9 → COMPROMISOS, ILOCALIZADO; M1/D1 → 3 valores. Cada lista 0,8–1,4 s (img 02–04) | OK | 15788224 | — | Buscador → ALTA SOLICITUD ANULACIÓN → póliza → ALTA → abrir cada desplegable | — |
| H-02 | Alta S1: `SCA2_consultarMotivo/Detalle/Causa` = `*Core` para esa combinación | mismo `result` | iguales en las 3 reglas (motivo: perfil CE_RM, LN 1; detalle: M1 LN1 → 7 filas; causa: M1/D9 y M1/D1 con perfil CE_RM). Solo difiere `durationMs` (Aurora 21–52 ms vs CORE 126–149 ms) | OK | 15788224 | — | `POST /expression-rules/{uuid}/test` sobre …20052556/…5603864, …20050900/…5603876, …20050906/…5603893 | la UI muestra 6 detalles y la API 7 porque `SCA2_AltaSolicitudPage` quita IMPAGO DEL SEGURO (`remove(local!detalleDDVisible, 2)`) para motivo 1: lógica legacy, no diferencia Aurora/CORE |
| H-03 | Alta S1: tiempo de apertura | medido | popup de alta 1,5 s; carga de la póliza 4,6 s; ALTA → pantalla de alta **11,27 s**; GUARDAR → modal de confirmación < 4 min (no medido con precisión, ver O1); ACEPTAR → alta registrada 16 s (17:00:10 → 17:00:26) | OK | 15788224 | Alta 537552182 | Playwright, `time.time()` entre clic y texto esperado (img 01, 05, 06) | — |
| H-04 | Tras alta S1: `SCA2 Solicitud` | `caducidadTarea` = hoy+7 (2026-10-28) ≤ vencimiento; `fecInicioNivel` informado; `nivelIntervencion` = 1 | `caducidadTarea` 2026-10-28 00:00:00; `fecInicioNivel` 2026-10-21 17:00:26; `nivelIntervencion` 1; `estadoSolicitud` EN_ACCION; `grupoAsignacion` CE_RM; `origenPoliza` NSE-Autos | OK | 15788224 | Alta 537552182 | `GET /record-types/c531595c…/data` | — |
| H-05 | Tras alta S1: `SCA2 Datos Cabecera` | fila `origenCache = CACHE`, `validaHasta` = 07:00 del día siguiente, `clienteCarterizado` y `clienteNuumapropietario` informados (no el texto `"null"`) | fila 245: CACHE; `fechaCache` 17:00:23; `validaHasta` 2026-10-22 07:00:00; `clienteCarterizado` `No`; `clienteNuumapropietario` **vacío** (null real, no el texto `"null"`); `tipoPoliza` NSE-Autos; `clienteCodint` 69610602007 | OK (O2) | 15788224 | Alta 537552182 | `GET /record-types/04f597de…/data` | ver O2 |
| H-06 | Detalle S1: apertura y segunda apertura desde caché | 2ª apertura no cambia `fechaCache` | 1ª apertura 1,13 s; 2ª apertura 1,10 s; `fechaCache` 17:00:23 en ambas; pestañas Datos póliza 2,45 s / Solicitud Anulación 1,55 s / Otras sol. Anulación 1,54 s (1 elemento: la propia 15788224) (img 08, 10) | OK | 15788224 | — | Buscador → enlace 15788224 → pestañas | — |
| H-07 | Detalle S1: «Actualizar datos» | `fechaCache` cambia; misma información | 2,03 s; `fechaCache` 17:00:23 → 17:06:41; `validaHasta` sigue 2026-10-22 07:00; texto de Datos cliente idéntico antes/después (img 09) | OK | 15788224 | — (no arranca PM: RefrescarCache 0 instancias) | botón «Actualizar datos» | — |
| H-08 | Posponer S1 desde Contra Anulación | `caducidadTarea` no cambia; `fechaDietario`/`contadorPosponer` sí | gestión CA 3,28 s; RETOMAR → pantalla 11,06 s; oficina MADRID CORREDORES NORTE II; POSPONER 3,23 s «CORRECTO»; `caducidadTarea` 2026-10-28 (igual); `fechaDietario` 2026-10-28; `contadorPosponer` 1; `version` 3→4; transición 1605 EN_ACCION→PENDIENTE OK; caché no invalidada (img 11, 12) | OK | 15788224 | Posponer 12248993 | Detalle → Contra Anulacion → RETOMAR → oficina → POSPONER → Sí | — |
| H-09 | Contra Anulación S1: RETOMAR → argumento → FINALIZAR | pantalla sin error, tipos de argumento visibles, tiempo | RETOMAR 7,12 s (2ª vez); 7 tipos de argumento (INCREMENTO PRIMA SINIESTROS obligatorio, GESTION COMPETENCIA, SUPLEMENTO EN GENERAL, CAMBIO DE FORMA DE PAGO, CLUB MAPFRE PLATA, SERVICIOS MAPFRE, REDUCCION DE COBERTURAS); NEGATIVO 2,04 s (Negativo / JJGONZ2 / 19:10:48 CEST); FINALIZAR bloqueado hasta imprimir la carta; plantilla «COMUNICACIÓN DE OPOSICIÓN A LA RENOVACIÓN» (2 págs); CONTINUAR 0,91 s; FINALIZAR → modal → SI 17:13:00; «CORRECTO» (img 13–16) | OK | 15788224 | CompletarAccion 269115861 | RETOMAR → marcar argumento 1 → NEGATIVO → icono carta → CONTINUAR → FINALIZAR → SI | — |
| H-10 | Sombra propietario S1 | fila nueva `SOMBRA_PROPIETARIO_CONTRAANULACION` con CLAVE/POLIZA/CARTERIZACION informados | fila **444** 17:11:34: `ESB=FALSE;APPIAN=FALSE;COINCIDE=S;CARTERIZACION=1;CLAVE=N;POLIZA=N`, cliente 15788224, póliza 2002600009080, perfil JJGONZ2 (se escribe al pulsar FINALIZAR, antes del SI) | OK (O3) | 15788224 | — | `GET /record-types/30d97aab…/data` | ver O3 |
| H-11 | Invalidación de caché S1 por CMD CompletarAccion | `validaHasta <= now()` | fila 245: `validaHasta` 2026-10-22 07:00 → **2026-10-21 17:13:05**; `fechaCache` sin cambio (17:06:41) | OK | 15788224 | CompletarAccion 269115861 | lectura tras FINALIZAR | — |
| H-12 | Decisión S1 tras CA | `CMD Decidir` crea transición | 1606 CompletarAccion EN_ACCION→DECIDIR OK 17:13:13; **1607 Decidir PDTE_FINALIZAR→MECANIZAR OK 17:13:25**; solicitud `interfazActiva` VERTI / `procesoActivo` MECANIZAR, `version` 7 | OK | 15788224 | Decidir 16445118; CrearAccion 11197775 | `GET /record-types/0b46024c…/data` | — |
| H-13 | Errores S1 | sin filas nuevas en `SCA2 Error` | ninguna fila con id > 121 | OK | 15788224 | — | `GET /record-types/d7111f93…/data` | — |
| H-14 | PM S1 sin pausa por excepción | todas COMPLETED, 0 tareas | Alta 537552182 (17:00:14–17:00:44), Decidir 13308393 y 16445118, CrearAccion 13308394 y 11197775, Posponer 12248993, CompletarAccion 269115861: todas `COMPLETED`, 0 tareas; Finalizar y RefrescarCache 0 instancias | OK | 15788224 | (las listadas) | `GET /process-models/{uuid}/processes?limit=500` filtrado desde 16:55 | — |
| H-15 | Alta S2 (wAutemis): desplegables | listas con datos | Motivo 3, Detalle 6, Causa M1/D9 → COMPROMISOS, ILOCALIZADO; M1/D1 → 3 valores; 0,8 s por lista (img 18–20). Misma combinación (perfil CE_RM, LN 1) que S1 → la comparación H-02 aplica | OK | 15788225 | — | ídem H-01 | — |
| H-16 | Alta S2: tiempos | medido | popup 1,49 s; póliza 4,63 s; ALTA → pantalla **8,62 s**; GUARDAR → modal de confirmación < 4 min (ver O1); ACEPTAR → formulario reiniciado **34,72 s**; alta 17:25:07 (img 17, 21, 22) | OK | 15788225 | Alta 15419298 | ídem H-03 | — |
| H-17 | Tras alta S2: `SCA2 Solicitud` | hoy+7, nivel 1, `fecInicioNivel` | `caducidadTarea` 2026-10-28 00:00:00 (< 14/09/2027); `fecInicioNivel` 17:25:07; `nivelIntervencion` 1; EN_ACCION / CONTRA_ANULAR; CE_RM; `origenPoliza` wAutemis | OK | 15788225 | Alta 15419298 | ídem H-04 | — |
| H-18 | Tras alta S2: `SCA2 Datos Cabecera` | CACHE, 07:00, campos informados | fila 248: CACHE; `fechaCache` 17:25:03; `validaHasta` 2026-10-22 07:00:00; `clienteCarterizado` `No`; `clienteNuumapropietario` vacío (null real); `polizaFechavencimiento` 14/09/2027; `tipoPoliza` wAutemis; `clienteCodint` 505103612026 | OK (O2) | 15788225 | Alta 15419298 | ídem H-05 | ver O2 |
| H-19 | Detalle S2: apertura, 2ª apertura, pestañas | `fechaCache` no cambia | 1ª apertura 1,08 s; 2ª apertura 0,97 s; `fechaCache` 17:26:26 sin cambio en la 2ª; Datos póliza 2,51 s / Solicitud Anulación 1,52 s / Otras sol. 1,54 s (1 elemento) (img 23, 25) | OK | 15788225 | — | ídem H-06 | — |
| H-20 | Detalle S2: «Actualizar datos» | `fechaCache` cambia; misma información | 2,04 s; `fechaCache` 17:25:03 → 17:26:26; `validaHasta` igual; Datos cliente idénticos (img 24) | OK | 15788225 | — | ídem H-07 | — |
| H-21 | Posponer S2 | caducidad igual; dietario/contador cambian | gestión CA 3,13 s; RETOMAR 11,9 s; 7 argumentos; POSPONER 3,22 s «CORRECTO»; `caducidadTarea` 2026-10-28 (igual); `fechaDietario` 2026-10-28; `contadorPosponer` 1; transición 1611 EN_ACCION→PENDIENTE OK; caché no invalidada (img 26, 27) | OK | 15788225 | Posponer 16445161 | ídem H-08 | — |
| H-22 | Contra Anulación S2 | sin error, argumentos, tiempo | RETOMAR 1,03 s (2ª vez); 7 argumentos; NEGATIVO 0,95 s; carta 2,21 s; CONTINUAR → FINALIZAR habilitado → modal → SI 17:30:05 → «CORRECTO» en **17,38 s** (img 28–30) | OK | 15788225 | CompletarAccion 10155263 | ídem H-09 | — |
| H-23 | Sombra propietario S2 | fila nueva con CLAVE/POLIZA/CARTERIZACION | fila **447** 17:30:01: `ESB=FALSE;APPIAN=FALSE;COINCIDE=S;CARTERIZACION=1;CLAVE=N;POLIZA=N`, cliente 15788225, póliza 0001047017111 | OK (O3) | 15788225 | — | ídem H-10 | ver O3 |
| H-24 | Invalidación de caché S2 | `validaHasta <= now()` | fila 248: `validaHasta` → **2026-10-21 17:30:08**; `fechaCache` igual | OK | 15788225 | CompletarAccion 10155263 | ídem H-11 | — |
| H-25 | Decisión S2 | transición de `CMD Decidir` | 1612 CompletarAccion EN_ACCION→DECIDIR OK 17:30:15; **1613 Decidir PDTE_FINALIZAR→MECANIZAR OK 17:30:24**; VERTI / MECANIZAR, `version` 7 | OK | 15788225 | Decidir 269115925; CrearAccion 537552274 | ídem H-12 | — |
| H-26 | Errores S2 | sin filas nuevas | ninguna (max id sigue 121) | OK | 15788225 | — | ídem H-13 | — |
| H-27 | PM S2 sin pausa por excepción | COMPLETED, 0 tareas | Alta 15419298 (17:24:51–17:25:21), Decidir 12249045 y 269115925, CrearAccion 13308460 y 537552274, Posponer 16445161, CompletarAccion 10155263: todas `COMPLETED`, 0 tareas; Finalizar y RefrescarCache 0 | OK | 15788225 | (las listadas) | ídem H-14 desde 17:24 | — |
| H-28 | Mantenimiento «Catálogos CORE (Aurora)»: lista los 6 catálogos con recuentos 14/22/146/343/17/100 | 6 catálogos y recuentos | Opción 7 del menú abre la página; aviso «Las pantallas están leyendo de Aurora (SCA2_USAR_CATALOGOS_AURORA = true)»; selector con los 6 catálogos (Motivos, Detalles, Causas, Tipos de argumento, Conceptos PCA, Valores de concepto), filas `Origen = CORE`, modificación 21/10/2026 12:30 CEST. **Recuento visible solo en Motivos (14 elementos)**; en los otros 5 la rejilla pagina de 15 en 15 y muestra «1 – 15 de muchos». Recuentos por API de los records `SCA2 Cat *`: **14 / 22 / 146 / 343 / 17 / 100** (img 31–38). Nada editado (NUEVO / RECARGAR DESDE CORE no pulsados) | OK (O4) | — | — | Gestiones mantenimiento → Catálogos CORE (Aurora) → cambiar catálogo; `GET /record-types/{uuid}/data?limit=5000` | ver O4 |

## 5. Observaciones (sin KO)

- **O1 — Medida del tiempo GUARDAR → modal de confirmación (H-03, H-16).** El script de UI esperaba a que desapareciera el texto accesible «Botón GUARDAR, Cargando»; ese texto (live region) permanece en el DOM tras terminar la carga, de modo que la espera agotaba su límite (≈240 s) aunque el modal ya estaba visible. El dato fiable es el medido por cambio de pantalla: ACEPTAR → formulario reiniciado 34,72 s en S2 (en S1, con el mismo defecto de medida, el alta quedó registrada 16 s después de ACEPTAR). No es una incidencia de la aplicación; se anota para no repetir el error en sesiones futuras.
- **O2 — `clienteNuumapropietario` vacío (H-05, H-18).** `SCA2_obtenerDatosCabecera` (43-D) persiste `null` cuando `datosCliente.nuumaPropietario` viene vacío de la fuente, y en TEST no hay gestor propietario de la clave/póliza para estos clientes (43-B §pendientes: 268 consultas a Estruage, todas `CLAVE=N, POLIZA=N`). El valor es un nulo real (la CSV del record devuelve cadena vacía), **no** el texto `"null"` que sí aparece en 7 filas CACHE anteriores a esta sesión (ids ≤ 244, de otras sesiones). Si se quiere un valor explícito («sin propietario») habría que decidirlo en 43-D; no se cambia nada.
- **O3 — Sombra con `CLAVE=N;POLIZA=N` (H-10, H-23).** Es el formato documentado en 43-B (`CLAVE=S|N|NA;POLIZA=S|N|NA`): `N` significa *informado y negativo* (JJGONZ2 no es propietario de clave ni de póliza), `NA` sería «no consultado». `CARTERIZACION=1` = «no carterizado» (código de retorno de la carterización, coherente con `clienteCarterizado = No`). `ESB=FALSE;APPIAN=FALSE;COINCIDE=S`: el cálculo legacy en Appian y el del ESB coinciden.
- **O4 — La página de catálogos no muestra el total salvo en Motivos (H-28).** Las seis rejillas de `SCA2_CatMantenimiento` (`_a-0000f093-2064-8000-9d36-011c48011c48_5604449`, v8) son `a!gridField(data: a!recordData(...), pageSize: 15)` sin `showTotalCount`, por lo que Appian muestra «1 – 15 de muchos»; el recuento solo se ve cuando cabe en una página (Motivos, 14). Los seis recuentos esperados se han confirmado por API sobre los records `SCA2 Cat Motivo/Detalle/Causa/Tipo Argumento/Concepto/Valor Concepto`. Si se quiere ver el total en pantalla bastaría activar el recuento total de la rejilla (decisión para la sesión C / mantenimiento; no se toca).

Otras notas: la transición de Posponer se registra con el nombre de la instancia (`SCA2 CMD Posponer - 21/10/2026 19:08 CEST`) en `comando`, igual que en 43-A; «Actualizar datos» no arranca `SCA2 CMD RefrescarCacheCabecera` (refresca en línea y reescribe la fila CACHE); la fila de sombra se escribe al pulsar FINALIZAR (antes de confirmar el modal), como en 43-B P11/P13.

## 6. Tiempos resumidos

| Paso | S1 (Autos NSE) | S2 (wAutemis) |
|---|---|---|
| Abrir popup de alta / cargar póliza / ALTA → pantalla de alta | 1,5 s / 4,6 s / 11,27 s | 1,49 s / 4,63 s / 8,62 s |
| Cada desplegable (Motivo, Detalle, Causa) | 0,8–1,4 s | 0,8 s |
| ACEPTAR → alta registrada / formulario reiniciado | 16 s (record) | 34,72 s (UI) |
| Detalle: 1ª / 2ª apertura | 1,13 s / 1,10 s | 1,08 s / 0,97 s |
| Pestañas Datos póliza / Solicitud Anulación / Otras sol. | 2,45 / 1,55 / 1,54 s | 2,51 / 1,52 / 1,54 s |
| «Actualizar datos» | 2,03 s | 2,04 s |
| Abrir gestión Contra Anulación / RETOMAR (1ª) / RETOMAR (2ª) | 3,28 / 11,06 / 7,12 s | 3,13 / 11,9 / 1,03 s |
| POSPONER / NEGATIVO / carta / CONTINUAR | 3,23 / 2,04 / — / 0,91 s | 3,22 / 0,95 / 2,21 / — |
| FINALIZAR (SI) → «CORRECTO» | backend 17:13:00 → 17:13:37 (UI no medible, O1) | 17,38 s |

## 7. Capturas

`img/43-H-01…07` alta S1 (pantalla, motivo, detalle, causa, formulario, confirmación, datos póliza); `08…10` detalle S1 (apertura, actualizado, otras solicitudes); `11…16` Contra Anulación S1 (pantalla, pospuesta, negativo, carta, modal finalizar, finalizada); `17…22` alta S2; `23…25` detalle S2; `26…30` Contra Anulación S2; `31` menú de mantenimiento; `32…37` los seis catálogos; `38` pie de la rejilla de causas («1 – 15 de muchos»).

## 8. Datos dejados en TEST

Solicitudes 15788224 y 15788225 en `EN_ACCION` con `interfazActiva = VERTI` / `procesoActivo = MECANIZAR` (no se ha ejecutado la mecanización); filas `SCA2 Datos Cabecera` 245 y 248 con `validaHasta` vencido (se regenerarán en la siguiente apertura del detalle o por el PM de refresco de las 07:05); filas de sombra 444 y 447; transiciones 1602–1613. Nada que borrar.
