# T21 — Auditoría de paridad: acciones SCA vs SCA2 (TEST)

Auditoría a nivel SAIL de las pantallas de acción. Columnas: divergencia | comportamiento SCA | SCA2 antes | corrección / justificación.

## Popup Reasignar

| Punto | SCA | SCA2 | Estado |
|---|---|---|---|
| Botón REASIGNAR | Botón único en la cabecera de `SCA_DetalleAnulacionContraAnulacion`, `a!startProcess(SCA_PM_REASIGNAR_TAREA, {taskId, idSolicitud})` + recarga + `SCA_PopUpReasignarTarea` ("La tarea se ha reasignado correctamente"). `disabled: isNullOrEmpty(taskId)`, tooltip "Solicitud pendiente en Antiguo SCA". | Botón por fila en el acordeón de tareas de `SCA2_DetalleSolicitud` (`showWhen: asignadoA vacío y SCA2_puedeGestionarTarea`), `SCA2_reasignarTarea(idTarea)` + `SCA2_PopUpReasignarTarea` (mismo mensaje INFO). | Justificado: la cabecera SCA2 usa el acordeón de `DetalleTareas`; el efecto (reasignar + popup de confirmación) es equivalente. Popup idéntico. |

## Autorización (`FueraNorma` / `DetalleAnulacionAutorizacion`)

| Punto | SCA | SCA2 | Estado |
|---|---|---|---|
| FINALIZAR | `confirmMessage: "Se va a finalizar la revisión de autorización"`, SOLID rojo, `disabled: not(documentosEntregados)`, validationGroup `FechaDeAnulacion`, startProcess Finalizar + trazabilidad. | Mismo texto/estilo/group/confirm; `disabled: not(isNotNullOrEmpty(local!noEntregaDoc))` (mismo semáforo de documentos entregados); `a!startProcess(CMD CompletarAccion, resultado{operacion:"Autorizacion"})` + `SCA2_aceptarAutorizacion` previo (integración aceptar autorización, igual que SCA). | Paridad. |
| CANCELAR | `"Va a proceder a cancelar la solicitud de anulación"`, LINK rojo, mcaEstadoFinal "N"/codEstado "5". | Idéntico (texto, estilo, `mcaEstadoFinal:"N", codEstado:"5"`). | Paridad. |
| POSPONER | `"Se va a posponer la revisión de autorización"`, `startProcess_24r3(SCA_PM_POSPONER…)`. | Mismo texto; `a!startProcess(CMD Posponer)` + trazabilidad en `onSuccess`. | Paridad (fix §8.z6 por restricción de un solo smart service). |
| `SCA_PopUpMensajeAutorizacion` | Popup mensaje autorización | No portado como interfaz separada; el flujo de FueraNorma no lo referencia en el path usado. | Justificado: en SCA sólo se usa en flujos de autorización nivel 2/3 no ejercitados; pendiente si aparece en uso real. |

## Mecanización (`MecanizacionEstrategicas` → `SCA2_MecanizacionPrincipal`)

| Punto | SCA | SCA2 antes | Corrección |
|---|---|---|---|
| Trazabilidad botón principal | `resultadoOperacion: if(controlRechazo,"OK","CANCELAR")` | Hardcoded `"CANCELAR"` | **Corregido**: `if(local!controlRechazo,"OK","CANCELAR")` — desplegado (re-GET ok). |
| CANCELAR | LINK rojo, `startProcess(PM_FINALIZAR_MECANIZACION, cancel:true)` + trazabilidad + `a!save(ri!numPoliza,"")` (vuelta al listado), **sin confirmación**. | `a!startProcess(CMD CompletarAccion, {mcaEstadoFinal:"CANCELADO"})` + trazabilidad en onSuccess + `a!save(ri!onCompletar,true)`; tenía `confirmHeader/confirmMessage "Va a proceder a cancelar la mecanización"`. | **Corregido**: eliminado el confirm (SCA no lo tiene). La vuelta vía `onCompletar→local!hecho` es el equivalente al `numPoliza=""` de SCA. |
| Botón principal | label `if(controlRechazo,"FINALIZAR SOLICITUD","ANULAR PÓLIZA")`, disabled si `sAnulacion.error.code="4023"` con tooltip. | Idéntico. | Paridad. |
| Padding motivos | `text(codMotivoTraducido,"00000000")` en consultas de anulación | Igual (usa `text(...,"00000000")`). | Paridad. |
| OCULTAR/TRAZAR ANULACIÓN | Toggles de la simulación en `DetalleAnulacionMecanizacion` | Presentes en la pantalla principal mecanización (modal informativo + tarjeta VERTI). | Paridad estructural. |

## VERTI (`SCA_GenerarContactoVerti` → `SCA2_VertiVencimientoPrincipal` + `SCA2_GenerarContactoVerti`)

| Punto | SCA | SCA2 | Estado |
|---|---|---|---|
| Popup Vencimiento/VERTI | `SCA_GenerarContactoVerti`: checkbox VERTI/vencimiento + botón `CONTINUAR ANULACIÓN` (SOLID rojo, submit). | `SCA2_GenerarContactoVerti` usado desde `SCA2_MecanizacionPrincipal` con `mostrarVerti/mostrarVencimiento/checkVerti/checkVencimiento`; la pantalla `SCA2_VertiVencimientoPrincipal` tiene CONTINUAR (`CMD Mecanizar`, trazabilidad en onSuccess) + CANCELAR. | Paridad de flujo. |

## DetalleTareas / dropdowns / etiquetas

| Punto | SCA | SCA2 antes | Corrección |
|---|---|---|---|
| Etiqueta tipo tarea | `SCA_D_TiposGestiones`: `CONTRA ANULAR`→`"CONTRA ANULACIÓN"`… y SCA2 recibe `CONTRAANULAR` del CrearAccion | `SCA2_D_TiposGestiones` sin caso `CONTRAANULAR` → `proper()` = "Contraanular" | **Corregido**: añadido `equals:"CONTRAANULAR", then:"CONTRA ANULACIÓN"`. `testRule` → "CONTRA ANULACIÓN". El `a!match` de pantalla ya cubría `CONTRAANULAR`. |
| Fuentes dropdown | Las mismas integraciones de catálogo (catálogos, oficinas `masDeUnaOficina/detalleOficina`). | Sin dropdownField en `DetalleTareas` (las acciones se eligen por fila del acordeón; selección de oficina en `ContraAnulacionOpciones`, ya portado). | Paridad. |

## ContraAnulación (resumen de fixes previos §8.z6)

- `SCA2_ContraAnulacionOpciones`: `mostrarBotonesCancelarPosponer` (regla homóloga a `SCA_mostrarBotonCancelarPosponer`) gobierna `showWhen` de CANCELAR/POSPONER; POSPONER `disabled` hasta seleccionar oficina con tooltip SCA.
- Botones FINALIZAR/CANCELAR/POSPONER: un solo `a!startProcess` (CMD CompletarAccion / CMD Posponer) + trazabilidad en `onSuccess` — restricción de un smart service por evaluación (SCA usaba `startProcess_26r3` legacy que lo permitía).

## Servicios PRE caídos (paridad documentada)

- `consultarListadoArgumentos` (argumentos CA): ORA-00936 con body idéntico para SCA y SCA2 → grid vacío es paridad.
- `generarStudAnul`/`generarContraAnul` PRE: errores 4005/4007 esporádicos; payload ya alineado (diff campo a campo §8.z).
EOF

## Milestone Alta/Detalle (`SCA_MilestoneMasDatosAltaSolicitud[Estrategicas]`)

| Punto | SCA | SCA2 antes | Corrección |
|---|---|---|---|
| `choose(local!seleccionado, …4 opciones)` con seleccionado=5 (popup sin solicitud; 2002000012636, 2002000066004) | **Bug SCA**: error "choose index 5 with 4 choices" — el milestone no renderiza. | Copia literal → mismo error. | **Corregido** (divergencia justificada — SCA falla): `choose(min(local!seleccionado,4),…)`: 5→Datos contacto (opción 4, correcta), 6→último fallback. Deploy + re-GET en ambas variantes. |
| Referencias a reglas `SCA_*` dentro de interfaces SCA2 | `'rule!SCA_TablaOtrasSolAnulación[_Estrategicas]'`, `'rule!SCA_SolicitudAnulación'` | Idénticas (copia literal) — interfaz rota si la regla SCA no resuelve. | **Corregido**: `SCA2_TablaOtrasSolAnulacion(numPoliza, idSolicitudSel)` y `SCA2_SolicitudAnulacion(idSolicitud, sol: SCA2_cargarSolicitud)` — firmas adaptadas a los contratos SCA2. |

## Candidatas de prueba (verify 25/09/2026, consultarSolicitudes + obtenerDatosCabecera)

Sin solicitud en Core7 ni fila en SCA2 Solicitud, cabecera sin errores:

- **Para SCA**: `2002000063789`, `2002000092160`
- **Para SCA2**: `2002000014944`, `2002000061459`
- Spare: `2002000085139`. Descartada `2002000065087` (ya tiene solicitud Core7 `15787538`).

## Posponer — estado de tarea tras posponer (25/09 PM)

| Punto | SCA | SCA2 antes | Corrección |
|---|---|---|---|
| Escritura tras posponer | `SCA Posponer Accion/ContraAnulacion` solo toca **caducidad** (dietario) — la gestión/tarea sigue "Incompleta" (PENDIENTE) con la nueva fecha dietario. | CMD Posponer escribía `estadoTarea="POSPUESTA"` + `Tarea.estado="POSPUESTA"` → ocultaba el botón RETOMAR (`showWhen: estado="PENDIENTE"`). | **Corregido**: nodo 5 del PM escribe `PENDIENTE` + `fechaCaducidad`/`fechaDietario`/`contadorPosponer+1` (re-GET: 0×POSPUESTA). Backfill Tarea 4,7 + Solicitud 14,17 → PENDIENTE conservando dietario 2026-10-02. |
| Feedback UI | `a!save(ri!numPoliza,null)`/vuelta al detalle | `a!save(ri!onCompletar,true)` en `onSuccess` (presente en CA Opciones, AccAdm, FueraNorma, VERTI — verificado). | Paridad. La falta de efecto en UI fue click pre-deploy; verificado por PM real (15787528, 15787538 → COMPLETED + writes correctos). |

## Acc. Adm. — grid de documentos vacía

| Punto | SCA | SCA2 | Estado |
|---|---|---|---|
| Filas del grid | `listaDocumentosNuevo` construido desde `documento1..9` ← `ri!listaDocumentos` ← `SCA_consultarDocumentos(codSolicitud)` | Misma cadena con `SCA2_consultarDocumentos`; `testRule(15787538)` → `MSSConsultarDocumentos:null` | Paridad: el servicio PRE devuelve null para solicitudes sin documentos → grid vacía en ambas. `SCA2_insertarObservaciones` también devuelve `success:false` PRE (no lanza excepción → no bloquea saveInto). |

## Alta post-OK + posponer — paridad post-observación SCA 15787542 (25/09 tarde)

| Punto | SCA | SCA2 antes | Corrección |
|---|---|---|---|
| Tras GUARDAR + OK | `SCA_AltaSolicitudEstrategicas` guarda `ri!idSolicitud = pv.codSolicitud` → la página renderiza directamente la acción pendiente ("Revisión autorización…"). | OK → `vista=DETALLE` (acordeón, había que RETOMAR). | **Corregido**: `SCA2_AltaSolicitudPage` +inputs `tipoAccion`/`idTarea`, `local!tareaNueva` (refreshVariable 0.5 sobre Tarea PENDIENTE de la solicitud) → OK abre la acción directamente; fallback a Detalle si aún no hay tarea. |
| Tarea tras posponer | SCA solo mueve caducidad; el owner vuelve al **grupo** → `RETOMAR` solo si `taskOwner=loggedInUser` → tras posponer aparece solo REASIGNAR. | Tarea quedaba asignada al usuario; RETOMAR seguía visible. | **Corregido**: PM CMD Posponer nodo 5 escribe `asignadoA=null`; DetalleSolicitud RETOMAR `showWhen: touser(asignadoA)=loggedInUser()` + puedeGestionar; REASIGNAR `showWhen: no-owner`. |
| Feedback posponer | Popup `SCA_PopUpMensajeAutorizacion` "CORRECTO / Los datos se han guardado correctamente" → vuelta al Buscador. | Texto verde "Acción registrada. Vuelva al detalle…" dentro de la acción. | **Corregido**: `SCA2_DetalleTareas` muestra card CORRECTO (check-circle, texto, ACEPTAR rojo) → `ri!idSolicitud=null` → vuelve al Buscador. |
| Alta fallida (Core7 KO) | Popup "ERROR / Los datos no se han podido guardar correctamente". | Card azul de éxito incluso con `idSolicitud=PDTE-*`. | **Corregido**: éxito solo si idSolGenerada no es `PDTE-*`; si `PDTE-*` → mensaje ERROR "Los datos no se han podido guardar correctamente (pestaña Errores)". |

## Alta 14944 — diagnóstico

El alta UI de 2002000014944 **sí se completó**: 15787543 EN_ACCION, Tarea ACCIONES ADMINISTRATIVAS PENDIENTE (JJGONZ2, CE_RM), transiciones OK. El "silencio" fue el tiempo del proceso síncrono; el usuario no llegó a ver/clickar el mensaje azul. El PM idempotente rechaza duplicados con ALTA_ERROR "Solicitud de anulacion ya existente" (verificado vía 2 relanzamientos de prueba → PDTE-8920113/PDTE-12066623, filas eliminadas).

## Autorización/FueraNorma + datos (25/09 noche)

| Punto | SCA | SCA2 antes | Corrección |
|---|---|---|---|
| Fecha anulación autorizada | `required`, poblada desde `solicitudAnulacion.datosCompletosSolicitud.datosSolicitud.fecAnulacion` | path `sol.datos.fecAnulacion` roto → vacío | Path correcto + parse dd/MM/yyyy (deployed, testInterface sin error) |
| Header Catalogación | "A FECHA" desde gestión | "-" (catal nunca escrito — key inexistente `datosSolicitud.catalogacion` en el contexto) | PM nodo7 lee `datosCod.codTpCatalogacion`; backfill rows 11/12 = "4" |
| `sol.datos` | `datosSolicitud` equivalente | clave ausente → todos los `sol.datos.*` null | alias `datos` + keys lowercase uniformes |

## Posponer/fechaAlta — fixes UI (25/09 noche v2)

| Punto | Causa | Fix |
|---|---|---|
| POSPONER UI no arranca PM | `obtenerCaducidadNivel` devuelve Datetime; PV `fechaDietario` es Date → fallo silencioso de a!startProcess (solo UI; testProcessModel con Date sí funcionaba) | `todate()` en los 4 saveInto POSPONER |
| OK alta → Detalle en vez de acción | `local!tareaNueva` lazy, solo usada en saveInto → null | `refreshAlways: true` |

## §t21.b — Posponer UI (verificado en navegador, 25/09)

| Divergencia | SCA | SCA2 antes | Fix |
|---|---|---|---|
| POSPONER no hacía nada | popup CORRECTO + tarea al grupo | sin efecto | Constante `SCA2_PM_CMD_POSPONER` era TEXT→PROCESS_MODEL; `insertarObservaciones`/`guardarTrazabilidad` en saveInto/onSuccess violaban el límite de 1 smart service por evaluación (incluye onSuccess) → eliminadas (PM ya escribe obs; CompletarAccion tiene nodo traza); onSuccess = `a!save(ri!onCompletar,true)`. Card de error/debug en AccAdm. |
| Traza técnica en posponer | se escribe | se escribía desde UI | pérdida documentada: no hay traza en Posponer/Mecanizar UI (añadir nodo PM si se requiere) |
| POSITIVO/NEGATIVO CA Opciones | encadena integraciones OK (legacy `_26r3`) | "second smart service" | pendiente: refactor mayor (PM o pasos divididos) |

## §t21.c — Cierre del patrón doble smart service (25/09)

| Divergencia | SCA | SCA2 antes | Fix / justificado |
|---|---|---|---|
| FINALIZAR CA Opciones no llamaba al cierre Core7 | PM cierra con IContraAnularPCA | saveInto sin integración | nodo 300 XOR + 301 Call Integration en CompletarAccion; UI pasa `finalizarCAPca` |
| FINALIZAR Autorización no llamaba aceptarAutorizacion | PM llama IGestionarAutorizacionesPCA | idem | nodo 302; UI pasa `operacion:"Autorizacion"` + `mSEAceptarAutorizacion` |
| Mecanización onSuccess con guardarTrazabilidad | traza técnica | "second smart service" latente | eliminado del onSuccess (traza la escribe el PM) — pérdida documentada |
| BandejaErrores Relanzar onSuccess writeRecords | marca RELANZADO | mismo error latente | marcado local `local!idsRelanzadas` oculta el enlace; record sigue PENDIENTE (documentado) |
| POSITIVO/NEGATIVO | integraciones condicionales en saveInto | idéntico | **justificado, no bug**: las reglas llamadas son integraciones HTTP puras, no smart services → el límite no aplica |
| Asterisco fecha autorizada | "*" visible | sin "*" | la plataforma no renderiza `*` de required en site page → literal " *" en label (verificado en vivo) |
