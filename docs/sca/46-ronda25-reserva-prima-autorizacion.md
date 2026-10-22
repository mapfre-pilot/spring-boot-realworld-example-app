# Ronda 25 — Revisión de pruebas del analista: autorización CORE tras ANL y reserva/devolución de prima en la simulación del alta

> Origen: revisión del analista de las solicitudes 15788161 (cancelada, correcta), 15788166 (rechazada: la gestión de Autorización de CORE debía quedar **Rechazada**) y 15788168 (autorizada: debía anularse; la simulación del alta debe repetirse con reserva/devolución de prima = N cuando NEW/NSE la rechazan y esa marca debe llegar a la mecanización).
> Método: lectura de SCA (`SCA Finalizar Mecanización`, `SCA_ContraAnulacionDetalleAnulacionPoliza`) y SCA2 por LCP; cambios sólo en SCA2 (GET vivo → backup `sca2work/r25/` → PUT → readback). Sin PR; rama `feature/sca`.

## 1. Diagnóstico

| Caso | Qué pasó en SCA2 | Qué hace SCA | Causa en SCA2 |
|---|---|---|---|
| 15788166 RECHAZAR | ANL `ESTADO=2`, SCA2 reanudó, `actualizarMecanizacion` (estado 4) y «CERRADA SIN MECANIZAR»; la **autorización de CORE siguió pendiente** | `SCA Finalizar Mecanización` nodo «Guardar autorización»: tras la respuesta de ANL llama a `guardarAutorizacion` con `mcaAutorizada = S/N` y `codEstado = 2/3` según la póliza esté anulada (`polizaVigente = "A"`) o vigente | `SCA2 CMD Mecanizar` no llamaba nunca a `SCA2_guardarAutorizacion` (la regla existía sin uso) |
| 15788168 AUTORIZAR | Bloqueo NEW con `reservaPrima=N` pero **ANL `MCA_RESERVA_PRIMA = S`** (fila 2166; igual en 2164); «Anular Poliza NEW» no termina | La pantalla ANULAR PÓLIZA consulta NEW con reserva S y, si falla, con N, y guarda la marca que aceptó NEW (`confirReserva`) | (a) la pantalla `SCA2_MecanizacionPrincipal` pasaba a Mecanizar la marca calculada para NSE (`tointeger(null) <> 0` → "S") en vez de la de wAutemis; (b) el alta no controla la excepción de reserva/devolución de prima: `SCA2_consultarNewAlta` llamaba una sola vez con `S` si catalogación = 4 |

Petición del analista aplicada: cuando la simulación del alta devuelve la excepción «no se permite reserva de prima / devolución de prima», repetir la simulación con ese indicador a **N** y dejarlo **registrado** para la mecanización.

## 2. Cambios (TEST, app SCA2)

| # | Objeto | Versión | Cambio |
|---|---|---|---|
| 1 | Record `SCA2 Datos Solicitud` | v1 → v4 (v2/v3 sin efecto: `PUT` ignora campos nuevos; el campo se creó con `POST /record-types/{uuid}/fields`) | Campo nuevo `mcarsvprima` (TEXT, columna `MCARSVPRIMA`, uuid `a858c3df-b176-49f2-9f18-7336c9ddf748`): marca S/N con la que la simulación del alta fue aceptada |
| 2 | `SCA2_consultarNewAlta` (wAutemis) | v1 → v2 | Si la consulta a NEW con `mcaReservaPrima = S` (catalogación 4) falla y el mensaje contiene «reserva de prima», se repite con `N`. `result.mcaReservaPrima` (final) y `result.reservaPrimaForzada` |
| 3 | `SCA2_simularAnulacionAltaNse` (NSE) | v1 → v2 | Ídem con `indicadorReservaPrimas` («reserva de prima») e `indicadorDevolucionPrima` («devolución»): se repite con el indicador rechazado a `N`. `result.mcaReservaPrima`, `result.mcaDevolucionPrima`, `*Forzada` |
| 4 | `SCA2_simularAnulacion` | v16 → v17 | Devuelve siempre `{errorSimularAlta, mcaRsvPrima, mcaDevolucionPrima, reservaPrimaForzada, devolucionPrimaForzada}` (antes `null` cuando no había error bloqueante) |
| 5 | `SCA2_AltaSolicitudPage` | v37 → v38 | Pasa `mcaRsvPrima` (de `erroresSimular`) al `SCA2 CMD Alta` |
| 6 | PM `SCA2 CMD Alta` | PV nueva `mcaRsvPrima` (Text, parámetro) | Los dos Write de `SCA2 Datos Solicitud` graban `mcarsvprima` |
| 7 | `SCA2_cargarSolicitud` | v8 → v9 | Lee `mcarsvprima` → `datosSolicitud.mcaRsvPrima` |
| 8 | `SCA2_MecanizacionPrincipal` | v17 → v18 | Si `mcaRsvPrima = "N"` no se intenta la consulta/simulación con `S` (va directa a `N`). Paridad SCA: a Mecanizar viajan `mcaReservaPrima`/`importeRsvPrima` de **wAutemis** (`confirReserva`/`importeOperacion`) cuando la póliza es wAutemis |
| 9 | PM `SCA2 CMD Mecanizar` | v32 → v33 según Appian | Nodo 308 «Preparar actualización»: salida nueva `guardarAutorizacion` = `SCA2_guardarAutorizacion` (wAutemis y nivel 00000005/6; `mcaAutorizada`/`codEstado` = S/2 si la póliza está anulada, N/3 si sigue vigente; paridad SCA). Nodo 340: `reservaPrima = "S"` si la marca es "S" o "Sí" (antes sólo "Sí" → siempre N). PV nueva `guardarAutorizacion` |

No se ha tocado SCA, SCAC, CORE ni ANL. 15788166 y 15788168 no se han relanzado ni modificado.

## 3. Verificación por LCP (`/test`)

- `SCA2_consultarNewAlta` con 0001047017109, efecto 11/09/2026, catalogación 4: la 1.ª llamada (S) falla en NEW por la reserva de prima; la 2.ª (N) → `success=true`, `mcaReservaPrima=N`, `reservaPrimaForzada=true`.
- `SCA2_simularAnulacion` con el mismo contexto: `{errorSimularAlta:false, mcaRsvPrima:"N", reservaPrimaForzada:true}`.
- `SCA2_cargarSolicitud` v9 (15788168): `datos.mcaRsvPrima = null` (solicitud anterior al campo), resto igual.

## 4. Pruebas con solicitud nueva (UI)

Prueba UI (21/10 20:04–20:12 CEST, JJGONZ2; vídeo `sca2-r25-e2e-edited.mp4`): **bloqueada por datos**. Las 15 pólizas «a efecto» del ODS que quedaban libres (0001047017097/099/102/105/108/115/116/121/122/124/125/126/128/131/153) las rechaza el alta antes del formulario: «La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.» No se creó ninguna solicitud ni se tocó ninguna anterior. Regresión NSE-Autos con 2002000200336: el GUARDAR termina con excepción de NSE («Could not roll back JDBC transaction … StaleConnectionException: No hay más datos para leer del socket»), externa.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa/solución |
|---|---|---|---|---|---|---|---|---|
| C1 | Alta A EFECTO → `mcaRsvPrima = N` | simulación aceptada con N y marca grabada | sin póliza wAutemis válida | NO PROBADO | — | — | 15 candidatas → ALTA | pedir pólizas wAutemis válidas en PRE y libres |
| C2 | Mecanización con marca N (ANL `MCA_RESERVA_PRIMA = N`, bloqueo 200) | — | depende de C1 | NO PROBADO | — | — | — | ídem |
| C3 | RECHAZAR → ANL ESTADO 2 → (CONCLUIDA) → `guardarAutorizacion` codEstado 3 → Autorización **Rechazada** | — | depende de C1 | NO PROBADO | — | — | acceso a mantenimiento opción 6 con `devin` OK | ídem |
| C4 | AUTORIZAR → ANL concluye con reserva N | — | depende de C1 | NO PROBADO | — | — | — | ídem |
| R | Regresión alta NSE-Autos | popup de simulación | excepción JDBC de NSE al GUARDAR | KO externo | — | — | alta 2002000200336 | repetir cuando NSE responda |

Verificado por LCP (§3): el reintento con N de `SCA2_consultarNewAlta`/`SCA2_simularAnulacion` funciona con el contexto real de 15788168 (misma póliza, motivo y fecha).

## 5. Límite conocido

La salida «Guardar autorización» del nodo 308 sólo se ejecuta cuando ANL marca `CONCLUIDA` (criterio de espera decidido por el analista, duda #3). En PRE ANL no concluye el ciclo para solicitudes SCA2 (r23-a §7), así que en TEST sólo se puede comprobar simulando la conclusión en la fila ANL de la solicitud de prueba.

## 6. Componente de inducción Verti (CMP Inducir Cliente Completo) visible para el usuario

Petición del usuario (21/10): «cuando se llama al proceso de Verti se tiene que mostrar en la pantalla para que el usuario pueda completar el componente … y después de completar continúe en SCA2».

**Diagnóstico.** `SCA2 CMD Mecanizar` nodo 330 arrancaba el CMP **asíncrono** y seguía; los formularios del CMP (User Input Tasks de `CMP Inducir Cliente Completo Fase 1/2`, asignadas a `usuarioAppian` = quien pulsa ANULAR PÓLIZA) quedaban como tareas Appian que el site SCA2 no muestra. En SCA, `SCA Finalizar Mecanización` nodo 17 «Inducción Verti» es un **subproceso síncrono encadenado**: el usuario ve el formulario del componente justo después de ANULAR PÓLIZA y la mecanización continúa al terminarlo.

**Cambio (TEST).**
| Objeto | Versión | Cambio |
|---|---|---|
| PM `SCA2 CMD Mecanizar` | v33 → v34 según Appian (42 nodos; aviso «Too many nodes») | 331 → **332 «Write Tarea INDUCCION»** (`SCA2 Tarea` tipo `INDUCCION`, «Inducción Verti/Vencimiento (componente)», PENDIENTE, asignada al usuario de la solicitud) → **330 síncrono** (espera a que el usuario complete el componente; guarda `pp.id` en la PV nueva `induccionProcessId`) → **333 «Write cierre Tarea INDUCCION»** (COMPLETADA, `fechaCierre`, `proceso` = id del CMP) → 8 Guardar Mecanización. Orden idéntico a SCA: primero la inducción, después bloqueo NEW / ANL / CORE |
| `SCA2_DetalleTareas` | v30 → v31 | Tipo `INDUCCION` en la normalización y rama propia en el `a!match`: tarjeta con el estado (pendiente por *usuario* / completado el *fecha*), enlace «Abrir mis tareas de Appian para completar el componente» (`/suite/tempo/tasks`) y VOLVER |

**Límites.** El PM padre del CMP sólo tiene PVs de entrada, no devuelve resultado (los datos de AGC/RGPD/vencimientos viven en Fase 1/2 y no suben), así que SCA2 sólo puede registrar que el componente terminó y cuándo. LCP no expone process reports, por lo que no se puede abrir la tarea concreta con `a!processTaskLink`; se enlaza a la lista de tareas de Appian del usuario. Prueba con solicitud nueva pendiente (misma falta de pólizas válidas que §4).

### 6.1 Prueba R25-5 (22/10, solicitud nueva 15788255 / 0001047017138, JJGONZ2)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia |
|---|---|---|---|---|---|---|
| 1 | Alta → CA negativa → Verti (CONTINUAR sin casillas) → ANULAR PÓLIZA | contacto Verti y Mecanizar arrancado | contacto `[VERTI, VENCIMIENTO]`; Mecanizar 16448044 (modelo v34) iniciado 11:43:42 | OK | 15788255 | 16448044 |
| 2 | Tarea «Inducción Verti/Vencimiento (componente)» en el Detalle | tarjeta con estado y enlace a tareas Appian | 1.ª apertura KO: `style: "NORMAL"` inválido en VOLVER → **`SCA2_DetalleTareas` v32** (OUTLINE); después tarjeta «pendiente por JJGONZ2» + enlace `/suite/tempo/tasks` | OK (tras v32) | 15788255 | — |
| 3 | Formularios del CMP asignados al usuario | completar como usuario | tarea «Solicitud Cotización» (cliente 38918268) → consulta Verti → espera → «Riesgo NO ASEGURABLE en Verti» → ENTENDIDO | OK (rama no asegurable; sin RGPD/Robinson) | 15788255 | CMP 16448045 |
| 4 | Mecanizar espera al CMP y continúa | `induccionProcessId` informado, tarea COMPLETADA, mecanización sigue | antes null → después 16448045; tarjeta «Componente completado el 22/10/2026 11:48. La mecanización de SCA2 ha continuado»; Mecanizar COMPLETED 11:48:43, `guardarMecanizacion.success=true`, Detalle «Anulación Realizada» | OK | 15788255 | 16448044 |
| 5 | Bloqueo NEW + ANL tras la inducción | nivel 00000005 → nodo 340 | **no ocurrió**: `pv!observaciones` (nvlCumplimiento de la anulación wAutemis que envía la pantalla) llegó null, así que el nodo 9 fue por «Sí» (Guardar Mecanización/CORE) y no por «wAutemis pdte. aceptar → Autorización»; `bloqueoCentral`, `estadoAnl`, `mcaReservaPrima` nulas | **A INVESTIGAR** | 15788255 | 16448044 |

Vídeo: `sca2-r255-v32-cmp-edited.mp4`. Pendiente: averiguar por qué la respuesta de anulación wAutemis de 15788255 no trae `nvlCumplimiento` (¿póliza anulada directa / respuesta de error de NEW?) — la lógica de `SCA2_MecanizacionPrincipal` v18 para `local!anulacion` es la misma que en v17 salvo que omite la llamada con reserva «S» cuando el alta registró «N». Observación del probador: la tarjeta mostraba NIVEL 1 antes y NIVEL 2 después del cierre (sin interpretar).

### 6.2 Componente embebido en la página de SCA2 (petición del 22/10: «no en Tempo»)

**Por qué no basta con el enlace a Tempo ni con el encadenamiento de SCA.** SCA muestra los formularios del CMP «en línea» porque los lanza desde un nodo *Sub-Process* (`SCA Mecanizacion` nodo 28 «Inducción VERTI») encadenado (*activity chaining*) a su propia tarea de usuario. En SCA2 `CMD Mecanizar` no tiene tareas de usuario: la pantalla lo arranca con `a!startProcess` desde el site, y Appian no encadena formularios desde `a!startProcess`. Los formularios del CMP son tareas Appian de los subprocesos `CMP Inducir Cliente Completo Fase 1` (`0021ef3e-d62c-8000-3877-7f0000014e7a`) y `Fase 2` (`0022ef3e-d443-8000-386f-7f0000014e7a`), asignadas a `pv!usuarioAppian`.

**Solución aplicada (sólo SCA2, sin tocar el CMP):** localizar la tarea Appian activa del componente y abrirla con `a!processTaskLink` desde la tarjeta «Inducción Verti/Vencimiento» del Detalle. Un `a!processTaskLink` pulsado dentro de un site abre el formulario en la misma página del site SCA2 (no en Tempo); el resto de pantallas del CMP se encadenan y, al terminar, Appian devuelve al usuario a la página de SCA2.

| Objeto | Tipo | Cambio |
|---|---|---|
| `SCA2 Tareas CMP Induccion` | Informe de procesos (nuevo, carpeta SCA2 Artifacts; doc `_a-0000f093-2064-8000-9d36-011c48011c48_5609459`) | Tareas por modelo de proceso (Fase 1 / Fase 2). Columnas: c0 Name, c1 Status, c2 Process, c3 Start Time (GMT), c4 TaskId (`tp!id`), c5 ProcessId (`pp!id`), c6 Assignees (`tp!assignees`). Creado en Designer (LCP no expone informes). |
| `SCA2_REP_TAREAS_CMP_INDUCCION`, `SCA2_PM_CMP_INDUCIR_FASE1`, `SCA2_PM_CMP_INDUCIR_FASE2` | Constantes (nuevas) | Referencias al informe y a los dos subprocesos del CMP. |
| `SCA2_obtenerTareaInduccion(usuario, fechaDesde, idCliente)` | Regla (nueva, v2) | `a!queryProcessAnalytics` sobre el informe con `contextProcessModels` Fase 1/2; filtros estado ∈ {0 asignada, 1 aceptada}, asignado = usuario, inicio ≥ fechaDesde, y opcionalmente «id: &lt;idCliente&gt;» en el nombre del proceso. Devuelve `{taskId, nombre, estado, processId, inicio}` o null. Probada por LCP: con `JJGONZ2` devuelve su tarea activa, con otro usuario/inexistente null; estados vistos en el informe: 0/1 activas, 2 completada, 14 omitida. |
| `SCA2_DetalleTareas` | Interfaz v33 | Tarjeta INDUCCION: si la tarea SCA2 no está completada, consulta cada 30 s (y con el botón ACTUALIZAR) la tarea activa del CMP del usuario conectado (`fechaDesde` = creación de la tarea SCA2 − 3 h por el desfase GMT) y muestra `a!processTaskLink` «Completar el componente ahora: &lt;nombre de la pantalla&gt;». Si no hay tarea para el usuario (generándose o asignada a otro) lo indica. Eliminado el enlace a Tempo. |

Comprobado por LCP (`POST /interfaces/{uuid}/test`) que la rama «completada» renderiza sin error con la tarea 425 de 15788255; la rama «pendiente» se prueba en UI con una solicitud nueva (R25-6, abajo).
