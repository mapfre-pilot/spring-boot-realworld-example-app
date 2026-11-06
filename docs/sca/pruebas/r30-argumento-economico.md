# R30 — Argumento económico en SCA2: implementación y pruebas (TEST)

Fecha: 2026-10-26 · Entorno: Appian TEST (`mapfrespain-test`) · Usuario de pantalla: `JJGONZ2` (perfil CE_RM).
Especificación: [`../50-ronda30-argumento-economico.md`](../50-ronda30-argumento-economico.md).

## 1. Objetos modificados

| Objeto | UUID | Versión antes → después | Cambio |
|---|---|---|---|
| Interfaz `SCA2_ContraAnulacionModalRecuperacionPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951` | **5 → 9** (final) | Bloque «argumento económico» entre el paso 7 (SVA) y el 8 (RED MAPFRE) |

Historial de versiones creadas en la ronda (todas sobre el mismo objeto):

| Versión | Contenido | Estado |
|---|---|---|
| 5 | Original (backup local antes de tocar nada) | — |
| 6 | Bloque económico + registro del error en `SCA2 Error` con `a!writeRecords` | Sustituida: el registro del error rompe el cierre positivo (caso 7) |
| 7 | v6 con el endpoint económico inválido (temporal, para forzar el error) | Temporal |
| 8 | v9 con el endpoint económico inválido (temporal, para probar el error sin registro) | Temporal |
| **9** | **Final**: bloque económico, el error no bloquea y no se registra | **Vigente** (relectura idéntica a lo enviado; sin rastro del endpoint de prueba) |

No se han modificado objetos de SCA, SCAC, CMP, CORE ni de ninguna otra aplicación. El llamador
(`SCA2_ContraAnulacionOpciones` → `SCA2_ContraAnulacionRehabilitacion`) ya pasaba en `data` los campos
`argumentoEconomico` (= `mcaEconomico` del servicio `consultarListadoArgumentos`), `descTipoArgumento`,
`codTipoArgumento`, `numPoliza` y `codSolicitud`: no hizo falta cambiarlo ni usar `SCA2_obtenerMarcaEconomica`.
Las reglas temporales de lectura (`SCA2_tmpR30Consulta`, `SCA2_tmpR30Lectura`, `SCA2_tmpR30Listado`) se crearon sólo para leer datos y se borraron (GET posterior 404).

### Diff del SAIL (v5 → v9)

```diff
@@ a!localVariables @@
+  local!errorEconomico,
@@ después del paso 7 (SVA) y antes del paso 8 @@
+                  /* R30: argumento económico → inserción en A2139022_MES vía marcarAsignacionBonificacion, sólo con positivo definitivo (tréboles/TTQ/SVA OK) */
+                  if(
+                    and(index(ri!data, "argumentoEconomico", "N") = "S", ri!return = false),
+                    rule!SCA2_marcarAsignacionBonificacionIntegracion(
+                      host: cons!SCAC_VAL_HOST_CORE7,
+                      endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
+                      consulta: a!localVariables(
+                        local!asignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}asignacionBonificacionDTO'(
+                          numPoliza: index(ri!data, "numPoliza", ""),
+                          codIdCampana: "ECONOMICO",
+                          codTipBon: "Arg. Econ.",
+                          numTipBon: index(ri!data, "codTipoArgumento", null),
+                          numSolicitud: index(ri!data, "codSolicitud", ""),
+                          mcaAplicada: "S",
+                          codDocum: left(index(ri!data, "descTipoArgumento", null), 20),
+                          fecAplicacion: today()
+                        ),
+                        local!mseMarcarAsignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseMarcarAsignacionBonificacionDTO'(
+                          asignacionBonificacion: local!asignacionBonificacionDTO
+                        ),
+                        local!marcarAsignacionBonificacion: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}marcarAsignacionBonificacion'(
+                          MSEMarcarAsignacion: local!mseMarcarAsignacionBonificacionDTO
+                        ),
+                        local!marcarAsignacionBonificacion
+                      ),
+                      onSuccess: a!save(local!errorEconomico, null),
+                      /* Un error del servicio no bloquea el positivo (no se puede registrar en SCA2 Error: sólo un smart service por evaluación) */
+                      onError: a!save(local!errorEconomico, fv!error)
+                    ),
+                    null
+                  ),
```

### Comportamiento decidido

- **Cuándo se inserta**: sólo si el argumento es económico (`argumentoEconomico = "S"`) **y** los pasos 5-7
  (tréboles, TTQ, SVA) han ido bien (`ri!return = false`). Diferencia deliberada con SCA, que inserta aunque fallen los tréboles.
- **Una sola vez**: la llamada está en el `saveInto` de ACEPTAR del modal de recuperación; el ACEPTAR del aviso
  informativo sólo cierra la ventana y llama a `ri!onFinalizarPositivo` (no repite integraciones).
- **Si CORE devuelve error**: el positivo **no se bloquea** y el error **no se registra**. Se intentó registrarlo en la
  bandeja `SCA2 Error` (v6) pero, en el mismo clic, el cierre positivo lanza un proceso y Appian sólo permite un smart
  service por evaluación: el clic fallaba y la solicitud quedaba a medias (caso 7). Un mensaje informativo tampoco es
  viable porque el cierre positivo sale de la pantalla. Queda como duda para el analista (§5).

## 2. Cómo se verifica la inserción

Appian no lee la tabla `TRON_LD.A2139022_MES`; quien escribe es CORE. Evidencia usada, por orden:

1. **Lectura CORE** con `SCAC_consultarBonoClienteIntegracion` (póliza + solicitud, `mcaAplicada = S`): devuelve las
   filas de bonificación de la póliza; la fila del argumento sale con `codTipBon = ECONOMICO`, la solicitud y `mcaAplicada = S`.
   `SCAC_consultarAsignacionBonificacionIntegracion` no sirve: responde fault 4004 («Datos insuficientes») o 4001
   («La consulta no devuelve resultados») en todas las variantes probadas, incluso para pólizas con la fila ya creada.
2. **Estado SCA2** (record `SCA2 Solicitud` / tareas) y bandeja `SCA2 Error`.
3. **Pantalla** (vídeos y capturas del testing).

Limitación: la consulta de bonos no devuelve `codDocum`, `codTipBon = "Arg. Econ."` ni `numTipBon` reales (devuelve
`numTipBon = 0`), y el log de request/response de la integración está desactivado; no se activó para no tocar la
integración. Los valores enviados se verifican por el código (diff) y por la fila resultante, no por un log de request.

## 3. Pruebas

Todas las solicitudes son nuevas, creadas hoy en SCA2 por `JJGONZ2`. Los NIF no se reproducen aquí.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| 1 | Económico sin tréboles, POSITIVO | Fila ECONOMICO en CORE; positivo cerrado | Fila `ECONOMICO`, `idSolicitud 15788328`, `mcaAplicada S`, `fecVigencia 2026-10-26`; solicitud `FINALIZADA_POSITIVO/FIN`, tarea COMPLETADA | OK | 15788328 (póliza 2002200295382) | tarea 536 | Alta → contra anulación → arg. 9 «REDUCCION DE COBERTURAS» → POSITIVO → ACEPTAR (08:41 Madrid) | — |
| 2 | Económico con tréboles OK | Fila de campaña + fila ECONOMICO | `TTQAUTOCON` (`numBonAplic 1`, `mcaAplicada S`) + `ECONOMICO` para 15788329; `FINALIZADA_POSITIVO/FIN` | OK | 15788329 (póliza 2002100432565) | tarea 537 | Arg. «TU TE QUEDAS CONCESIONARIOS 20 TREBOLES DISPONIBLES» → 1 trébol → ACEPTAR (08:49 Madrid) | — |
| 3a | Económico con tréboles KO (cliente sin Te Cuidamos) | No inserta; positivo no se cierra | Aviso «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos…»; argumento sigue Pendiente; sin fila ECONOMICO en CORE (sólo `TTQAUTOCON` previa con `mcaAplicada N`); sin error SCA2 | OK | 15788335 (póliza 0007051033953) | tarea 542 (EN_ACCION/PENDIENTE) | Arg. «TTQ CONCES NO CLUB MAPFRE 30 TREBOLES» → 1 trébol → ACEPTAR (09:18 Madrid). El ACEPTAR del aviso vuelve a la rejilla, no al modal: no hay CANCELAR que pulsar; no se canceló la solicitud | — |
| 3b | Económico SVA con cliente sin Club MAPFRE | No inserta | **Bloqueado** antes de llegar al modal modificado: error en `SCA2_ContraAnulacionModalSVA` («choiceLabels tenía longitud 0 y choiceValues tenía longitud 2») | No probado | 15788334 (póliza 0002940500039) | tarea 541 (EN_ACCION/PENDIENTE) | Arg. 252 «SERVICIO VALOR AÑADIDO» → al abrir la selección de SVA falla | Defecto preexistente, objeto no tocado en R30: el desplegable usa `desAccion` para etiquetas y la respuesta no lo trae. Ver §4 |
| 4 | NO económico, POSITIVO | No inserta ECONOMICO | Sin fila ECONOMICO; `FINALIZADA_POSITIVO/FIN`; sin error SCA2 | OK | 15788330 (póliza 2002100432561) | tarea 538 | Arg. 267 «INCREMENTO PRIMA SINIESTROS» → POSITIVO → ACEPTAR | — |
| 5 | Económico, NEGATIVO | No inserta | Sin fila ECONOMICO; solicitud sigue EN_ACCION; sin error SCA2 | OK | 15788331 (póliza 2002100424268) | tarea 539 (PENDIENTE) | Arg. 9 → NEGATIVO (08:57 Madrid) | — |
| 6 | Caso 1 en SCA (comparación) | Ver qué envía SCA | **No reproducible en TEST**: tras el alta, «Acción completada» sin redirección; no se generó tarea de contra anulación en Tempo (esperado > 5 min) | No probado | 15788333 (SCA, póliza 2002500484818) | sin tarea | Alta SCA (09:04 Madrid) → espera de tarea | Comparación hecha sobre el código de SCA (§4) |
| 7 | Error del servicio CORE (v7, con registro en `SCA2 Error`) | Positivo cerrado + fila `ARG_ECONOMICO_ERROR` | **Fallo**: «Attempted to run a second smart service, but only one smart service can be run per expression evaluation». Quedó la fila 146 `ARG_ECONOMICO_ERROR` y el argumento Positivo guardado, pero la solicitud sigue EN_ACCION/PENDIENTE | KO (corregido en v9) | 15788336 (póliza 0007051028913) | tarea 543 (PENDIENTE) | Endpoint económico inválido temporal → arg. 9 → POSITIVO → ACEPTAR (09:23 Madrid) | `a!writeRecords` + el proceso del cierre positivo en el mismo clic. Se quitó el registro |
| 7b | Error del servicio CORE (v8, sin registro) | Positivo cerrado sin error | Sin error de pantalla; `FINALIZADA_POSITIVO/FIN`, tarea COMPLETADA 08:30:15 UTC; sin filas nuevas en `SCA2 Error` | OK parcial (no concluyente) | 15788337 (póliza Hogar 0732200228788) | tarea 544 | Endpoint económico inválido temporal → arg. 1 «SERVICIOS MAPFRE» → POSITIVO → ACEPTAR (09:30 Madrid) | El cierre sin bloqueo está probado, pero no hay prueba de que se llamara al servicio: en Hogar el arg. 1 tampoco generó fila con el endpoint bueno (caso 8) |
| 8 | Regresión v9 (final), póliza Hogar, arg. 1 | Fila ECONOMICO; positivo cerrado | Positivo cerrado (`FINALIZADA_POSITIVO/FIN`, tarea COMPLETADA 08:37:40 UTC), sin errores, pero **sin fila ECONOMICO** en CORE (sólo `TTQHOGAR` antigua) | KO / no concluyente | 15788338 (póliza Hogar 0732200364740) | tarea 545 | Arg. 1 «SERVICIOS MAPFRE» → POSITIVO → ACEPTAR (09:37 Madrid) | Hipótesis no verificada: en Hogar el listado de argumentos no trae `mcaEconomico = "S"` para el arg. 1 y no se llama al servicio (el mismo SAIL inserta en Autos, caso 9). Tras el cierre el listado sale vacío y no se pudo comprobar. Duda 6 |
| 9 | Regresión v9 (final), póliza Autos, arg. 9 | Fila ECONOMICO; positivo cerrado | Fila `ECONOMICO`, `idSolicitud 15788344`, `mcaAplicada S`; `FINALIZADA_POSITIVO/FIN`, tarea COMPLETADA 08:56:05 UTC; sin errores SCA2 | OK | 15788344 (póliza 2002500381088) | tarea 546 | Arg. 267 obligatorio → NEGATIVO; arg. 9 «REDUCCION DE COBERTURAS» → POSITIVO → ACEPTAR (09:56 Madrid) | — |
| 2bis | Repetición del caso 2 (tréboles OK) | Fila campaña + ECONOMICO | `TTQAUTOS` (`mcaAplicada S`) + `ECONOMICO` para 15788332; `FINALIZADA_POSITIVO/FIN` | OK | 15788332 (póliza 2002100424266) | tarea 540 | Argumento con tréboles → ACEPTAR (09:00 Madrid) | — |

Evidencias: vídeos grabados en la sesión (no se suben al repositorio): `R30_UI` (caso 1), `R30_UI_casos2-6`, `R30_UI_caso3a`, `R30_UI_caso7_error`, `R30_UI_caso7b_error`, `R30_UI_regresion_v9`, `R30_UI_regresion_v9b`. Los casos 1-5 se hicieron con v6 (mismo bloque económico que v9; v9 sólo quita el registro del error).

## 4. Hallazgos

1. **Registro del error imposible desde el modal** (caso 7): escribir en `SCA2 Error` en el mismo clic que el cierre
   positivo rompe la evaluación (un solo smart service). Además deja la solicitud a medias. Corregido en v9.
2. **SCA inserta aunque fallen los tréboles**: su bloque económico no comprueba `ri!return`. SCA2 sí lo comprueba (no se ha tocado SCA).
3. **`SCA2_ContraAnulacionModalSVA` falla** con algunas respuestas de SVA (etiquetas vacías, valores con 2 elementos): bloquea
   cualquier argumento SVA en esas pólizas. Preexistente, fuera de R30 (UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051188`).
4. **Detalle de la solicitud desactualizado**: tras un positivo correcto (económico o no), el detalle puede mostrar
   «Contra Anulación Incompleta» y fecha fin «-» aunque la solicitud esté `FINALIZADA_POSITIVO/FIN`. Pasa también con el
   argumento no económico (caso 4): no lo causa R30.
5. **`consultarAsignacionBonificacion` no devuelve datos** en TEST (fault 4004/4001); para leer la fila hay que usar `consultarBonoCliente`.
6. **SCA no genera tarea en TEST** tras el alta (caso 6), lo que impidió comparar en pantalla.
7. El detalle y el buscador muestran «Solicitud Pendiente»/«Incompleta» tras cierres correctos (preexistente).
8. Residuos de prueba (no se han tocado): fila 146 de `SCA2 Error` y solicitudes 15788331, 15788334, 15788335, 15788336 en EN_ACCION.

## 5. Dudas para el analista

1. Si CORE falla al registrar el argumento económico, ¿basta con no bloquear el positivo (comportamiento actual) o hay que
   registrarlo? Para registrarlo habría que hacerlo dentro del proceso de cierre positivo (fuera del modal), lo que es un cambio mayor.
2. `FEC_APLICACION` la fija Appian con `today()` (igual que SCA). ¿Correcto o debe ser la fecha del servidor CORE?
3. ¿Se corrige también SCA para que no inserte cuando fallan los tréboles?
4. `codTipBon` se envía «Arg. Econ.» pero CORE guarda `ECONOMICO` (el `codIdCampana`) y `numTipBon = 0` según la consulta de bonos: ¿es lo esperado?
5. ¿Se abre incidencia para el desplegable de `SCA2_ContraAnulacionModalSVA` y para el detalle desactualizado?
6. En pólizas Hogar el argumento 1 «SERVICIOS MAPFRE» no generó fila ECONOMICO (caso 8). ¿Es económico en Hogar? Si el listado no trae `mcaEconomico`, ¿se usa como respaldo la marca del mantenimiento (`SCA2_obtenerMarcaEconomica`)? SCA lee el mismo campo, así que se comportaría igual.
