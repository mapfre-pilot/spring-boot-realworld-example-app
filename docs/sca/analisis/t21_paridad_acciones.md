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
