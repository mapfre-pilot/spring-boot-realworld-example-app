# H4 — Planes «Pruebas de mecanización» y «Revisión Autorización» en SCA2 vs SCA (TEST, ronda 8)

- Fecha: 2026-10-13 (10:10–11:40 UTC). Entorno: `https://mapfrespain-test.appiancloud.com` (sites `sca2` y `sca-site`).
- Planes ejecutados: `planes/pruebas-de-mecanizacion.md` (10 casos) y `planes/revision-autorizacion.md` (14 casos). Total 24 casos.
- Usuarios UI: `JJGONZ2` (oficina, CE_RM) y `SISANS` (SI24 Experto). Lectura de CORE con `SCA2_consultaGestion`, `SCA2_consultarAutorizacion`, `SCA2_consultarSolicitudes`, `SCA2_cargarSolicitud` (record) y bandeja `SCA2 Error` vía LCP.
- Pólizas asignadas (todas sin solicitud previa, comprobado con `SCA2_consultarSolicitudes` antes del alta): 0001047017040, 0001047017054, 0001047017061, 0005726677758, 0005726680401.
- Coordinación ronda 8: `coordinacion-ronda8.md` (reservas de objetos, incidencia CORE `guardarAutorizacion`).

## Resumen

| Veredicto | Casos |
|---|---|
| OK igual | 7 |
| DIVERGENCIA corregida | 0 |
| DIVERGENCIA pendiente | 3 |
| NO PROBADO | 14 |

- **SCA no comparable en UI**: las dos altas de referencia en SCA (B 15787899 y D 15787891) se quedaron >25 min en «Aún procesando» / 403 sin crear la tarea siguiente (sólo gestión 8 en CORE). Para esos pasos SCA2 se valida contra la descripción del plan y contra el diseño de SCA (SAIL/PM leídos por LCP).
- Los casos NSE (mecanización 5–10), Mas Móvil (aut. 6) y plan de pagos (aut. 14) no tienen datos en TEST ni lógica en SCA: NO PROBADO.
- Dos divergencias funcionales de SCA2 detectadas; una (fecha autorizada no propagada a la mecanización) con corrección intentada y revertida (ver §4); otra (CANCELAR autorización) resulta ser un fallo del servicio CORE común a SCA.

## 1. Solicitudes creadas

| Clave | App | Póliza | CORE | Camino | Estado final (CORE / record SCA2 / buscador) |
|---|---|---|---|---|---|
| A | SCA2 | 0001047017040 | 15787878 | Alta (motivo 1/detalle 1/causa 1, A EFECTO 06/03/2026) → CA NEGATIVA → mecanización → ANULAR PÓLIZA 10:22 UTC | CORE: 8 FIN, 2 FIN NEGATIVA, 4 FIN, 5 «ANULACION PENDIENTE DE AUTORIZAR», 7 FINALIZADA (abierta); autorización codEstado 1 SI24. Record `MECANIZADA` / procesoActivo `ANL`. Buscador SCA2 «Mecanización Enviada»; buscador SCA «Pendiente» |
| B | SCA | 0001047017054 | 15787899 | Alta (misma combinación; SCA sólo ofrece A VENCIMIENTO 29/04/2027) 10:49 UTC | Sólo gestión 8 FINALIZADA; sin tarea CA tras 3 comprobaciones (10:56, 11:01, 11:04). SCA no comparable |
| C | SCA2 | 0001047017061 | 15787881 | Alta (motivo 4/detalle 9/causa 28 ANULACIÓN FUERA DE NORMA, A FECHA 13/10/2026) → autorización → POSPONER → RETOMAR → FINALIZAR 20/10/2026 10:33 UTC → mecanización (sin anular) | CORE: 7 FINALIZADA 12:26:27→12:33:27 (local), autorización codEstado 2 / mcaAutorizada S / fecAnulAutorizada 20/10/2026, `consultarSolicitudes.fecAnul` = 20/10/2026, gestión 5 INCOMPLETA. Record `PDTE_MECANIZAR` / `MECANIZAR`, `fecanulacion` 13/10/2026. Detalle: Autorización «Aceptada», Mecanización «Incompleta» + RETOMAR; documentos 0900ab4481a09c28 (DNI) y 0900ab4481a09c26 (Autorización) |
| D | SCA | 0005726677758 | 15787891 | Alta autorización (misma combinación, A FECHA) 10:37 UTC | Sólo gestión 8 FINALIZADA; sin tarea Autorización tras 3 comprobaciones; 403 «Acceso denegado» al volver a la pestaña. SCA no comparable |
| E | SCA2 | 0005726680401 | 15787895 | Alta autorización 10:43 UTC → CANCELAR 10:44 UTC (no surtió efecto, §4.2) → RETOMAR → FINALIZAR 20/10/2026 11:13 UTC (re-test v21, con error de pantalla pero proceso lanzado) | CORE: 7 FINALIZADA 13:13:08 (local), autorización codEstado 2 / fecAnulAutorizada 20/10/2026, gestión 5 INCOMPLETA. Record `PDTE_MECANIZAR` / `MECANIZAR`. `SCA2 Error`: 1 fila CompletarAccion `AUT_GUARDAR_FAIL` (del CANCELAR) |

No se pulsó ANULAR PÓLIZA en C ni E (quedan retomables en Mecanización). Ninguna solicitud histórica fue modificada.

## 2. Plan «Pruebas de mecanización» (10 casos)

| Id plan | Nombre | Resultado SCA | Resultado SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| manual_test_2-1 | Mecanización póliza. Alerta (prima/reserva distinta de cero) | No alcanzado en UI (B sin CA). Diseño: `SCA_ContraAnulacionDetalleAnulacionPoliza` muestra «El cálculo de esta solicitud de anulación es provisional, consulte la situacion definitiva en Consuweb.» si `mcaReservaPrima <> "N"` | A: aviso naranja con el mismo texto literal, importe anulación -758.21, Reserva prima «No», nivel cumplimiento 00000005 | OK igual (texto y condición idénticos en SAIL; UI SCA no comparable) | `h4-mec-sca2-02-alertas.png` |
| manual_test_2-2 | Mecanización póliza. Alertas (cambios en póliza tras confirmar fecha) | No alcanzado en UI. Diseño SCA: «Las condiciones de anulación de la póliza se han modificado tras confirmar la fecha de anulación» | A: mismo aviso literal mostrado junto al anterior; además SCA2 muestra aviso propio si la simulación cae | OK igual | `h4-mec-sca2-02-alertas.png` |
| manual_test_2-3 | Mecanización póliza wAutemis y Acepta | No alcanzado en UI. Diseño: botón ANULAR PÓLIZA → `SCA Mecanizacion` → gestión 5 | A: «¿Desea anular la póliza con la información que se indica?», Póliza/Causa/Fecha/Importe, botones ANULAR PÓLIZA y CANCELAR; ANULAR → «CORRECTO / Los datos se han guardado correctamente / La anulación se ha lanzado al sistema de emisión.»; buscador «Mecanización Enviada»; CORE gestión 5 creada | OK igual | `h4-mec-sca2-03-anulacion-enviada.png`, `-04-buscador.png`, `-05-detalle-mecanizacion.png` |
| manual_test_2-4 | Mecanización póliza wAutemis y Acepta con autorización (Emisión devuelve pendiente de autorizar) | No alcanzado en UI. Diseño `SCA Mecanizacion`: si wAutemis y observaciones 00000005/6 → «Crear Autorizacion» (CORE) + «Pausar hasta ANL_Desbloquear»; la pantalla muestra modal «El proceso de anulación de la póliza se ha puesto en marcha, a través de la gestión de la petición de autorización…» | A devolvió 00000005: `SCA2 CMD Mecanizar` creó la autorización en CORE (gestión 7, codEstado 1, SI24), record `MECANIZADA`/`ANL`, espera ANL. Detalle: Mecanización «Anulacion Pendiente De Autorizar» + tarjeta Autorización «Pendiente» sin acciones (igual para SISANS). Buscador SCA2 «Mecanización Enviada»; SCA «Pendiente» para el mismo CORE. SCA2 no muestra el modal de SCA (la respuesta de Emisión llega en el comando asíncrono) | DIVERGENCIA pendiente (menor): texto del modal y etiqueta del buscador distintos; el flujo CORE/ANL es el mismo. ANL en TEST nunca desbloquea (conocido) | `h4-mec-sca2-06-detalle-autorizacion.png`, `-07-detalle-2min.png`, `h4-ampl-sca-a-tarjetas.png`, `h4-ampl-sca-a-c-buscador-pendiente.png` |
| manual_test_2-5 | NSE Autos y cancela | — | — | NO PROBADO: no hay póliza NSE Autos asignada ni en TEST; no probar CANCELAR gastaría una póliza wAutemis | — |
| manual_test_2-6 | NSE Autos y Acepta | — | — | NO PROBADO: sin póliza NSE | — |
| manual_test_2-7 | NSE Autos y Acepta con autorización | — | — | NO PROBADO: sin póliza NSE | — |
| manual_test_2-8 | NSE Hogar y cancela | — | — | NO PROBADO: sin póliza NSE Hogar | — |
| manual_test_2-9 | NSE Hogar y Acepta | — | — | NO PROBADO: sin póliza NSE Hogar | — |
| manual_test_2-10 | NSE Hogar y Acepta con autorización | — | — | NO PROBADO: sin póliza NSE Hogar | — |

Observación (fuera de este plan, para H1/H2): para la combinación DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, SCA2 ofreció sólo «A EFECTO» (póliza 040) y SCA sólo «A VENCIMIENTO» (póliza 054). Son pólizas distintas y la catalogación la devuelve el REST `consultarCatalogacionRest` por póliza (reglas idénticas en SCA y SCA2), así que no se considera divergencia; convendría repetir con la misma póliza en ambas apps (`h4-mec-sca2-01-solo-a-efecto.png`, `h4-mec-sca-01-solo-a-vencimiento.png`).

## 3. Plan «Revisión Autorización» (14 casos)

| Id plan | Nombre | Resultado SCA | Resultado SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| manual_test_2-1 | Acceso mismo usuario | D no llegó a tarea. Diseño: `SCA Autorización` asigna la tarea al creador | C: al GUARDAR el alta JJGONZ2 entra directamente en «Revisión autorización de fecha de anulación» (pestañas, selector de oficina con 2 oficinas, fecha autorizada = fecha solicitud, Documentación, CANCELAR/POSPONER/FINALIZAR); tras POSPONER, el mismo usuario ve RETOMAR en el Detalle y RETOMAR reabre la pantalla conservando fecha, oficina, observación y documento | OK igual (contra descripción del plan y diseño) | `h4-aut-sca2-01-inicial.png`, `-14-detalle-pospuesto.png`, `-16-retomar-conserva.png` |
| manual_test_2-2 | Acceso distinto usuario | No comparable (D sin tarea) | SISANS (SI24) abre C desde el buscador y llega al Detalle en consulta (no a la pantalla de autorización); ve RETOMAR (SI24 puede retomar), no REASIGNAR. En A y E (autorización creada por mecanización) SISANS no ve acciones | OK igual (comportamiento descrito en S4 para SCA; sin UI SCA) | `h4-aut-sca2-15-sisans-detalle.png`, `h4-ampl-sca2-a-sisans-sin-acciones.png`, `h4-ampl-sca2-e-sisans-sin-acciones.png` |
| manual_test_2-3 | Cambio Fecha anulación autorizada | No comparable en UI. Diseño: `SCA_aceptarAutorizacion(fecAnulAutorizada)`; CORE actualiza `fecAnulacion` de la solicitud y `SCA Mecanizacion` lee la solicitud de CORE | C: fecha cambiada a 20/10/2026 + FINALIZAR → «CORRECTO / Se va a redirigir a la anulación»; CORE `fecAnulAutorizada` = 20/10/2026 y `consultarSolicitudes.fecAnul` = 20/10/2026, pero la pantalla de mecanización muestra «Fecha anulación póliza 13/10/2026» (lee `SCA2 Datos Solicitud.fecanulacion`, que no se actualiza). Reproducido también en E | **DIVERGENCIA pendiente** (corrección intentada y revertida, §4.1) | `h4-aut-sca2-17-fecha-nueva-finalizar.png`, `-19-fecha-no-propagada.png`, `h4-retest-03-e-fecha-20-documentos.png` |
| manual_test_2-4 | Validación fecha anulación mayor que vencimiento | Diseño SCA: validación «La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.» | C: 31/12/2030 → mismo literal al confirmar FINALIZAR | OK igual | `h4-aut-sca2-07-validacion-fecha-futura.png` |
| manual_test_2-5 | Comprobación fecha informada (plan: «Debe seleccionar si autoriza o deniega la revisión de la fecha de autorización») | Ese literal no existe en `SCA_AnulacionFueraNormaPrincipal`; el campo es obligatorio | C: fecha vacía → «Se requiere un valor» (campo requerido), igual que SCA | OK igual (el texto del plan no existe en SCA TEST) | `h4-aut-sca2-08-validacion-fecha-vacia.png` |
| manual_test_2-6 | Mas Móvil (catalogación trimestral) | — | — | NO PROBADO: no hay póliza Mas Móvil asignada; ni SCA ni SCA2 tienen lógica específica en la pantalla de autorización | — |
| manual_test_2-7 | Adjuntar documentos | No comparable en UI. Diseño: `SCA_AccionesAdministrativasDocumentacion` (misma lógica que la copia SCA2) | C: FINALIZAR deshabilitado hasta entregar documentación (tooltip «Es necesario entregar los documentos que se precisan para poder continuar»); «Añadir» exige oficina; tipos por fila fijos «Autorización» y «DNI»; PDF subido y visualizado tras finalizar; referencias GD 0900ab4481a09c26/…28 en Detalle | OK igual | `h4-aut-sca2-04-modal-documento.png`, `-06-doc1-listado.png`, `-20-aceptada-documentos.png`, `-21-visualizar-doc1.png` |
| manual_test_2-8 | Eliminar documento | No comparable en UI | C: eliminar DNI → confirmación «El documento seleccionado se eliminará / ¿Confirma la eliminación?» y desaparece del listado. Observación: tras eliminar, FINALIZAR quedó deshabilitado aunque seguía adjunto «Autorización» (misma lógica `documentosOk` que SCA; no se pudo contrastar en UI SCA) | OK igual (observación anotada) | `h4-aut-sca2-11-dni-eliminado.png` |
| manual_test_2-9 | Modificar documento | No comparable en UI | C: segundo documento de otro tipo añadido al listado y luego sustituido (DNI eliminado y vuelto a adjuntar) | OK igual | `h4-aut-sca2-10-dos-documentos.png` |
| manual_test_2-10 | DNI como documento | No comparable en UI | C: tipo «DNI» disponible y aceptado; figura como «Dni» en el Detalle | OK igual | `h4-aut-sca2-09-tipo-dni.png` |
| manual_test_2-11 | Posponer una oficina | No comparable en UI | C: POSPONER sin oficina → «Se requiere un valor»; con oficina + observación → «¿Desea continuar? / Se va a posponer la revisión de autorización» → CORRECTO; Detalle «Pendiente» con observación «Prueba H4 posponer» y RETOMAR | OK igual (POSPONER ya validado frente a SCA en S4) | `h4-aut-sca2-12-posponer-sin-oficina.png`, `-13-posponer-correcto.png`, `-14-detalle-pospuesto.png` |
| manual_test_2-12 | Posponer más de una oficina | No comparable en UI | El usuario tiene 2 oficinas y el selector obliga a elegir una; no hay selección múltiple (igual que SCA) | NO PROBADO: el caso exige un usuario con oficinas distintas de las de JJGONZ2 y en SCA no se alcanzó la pantalla | `h4-aut-sca2-01-inicial.png` |
| manual_test_2-13 | Cancelar | No comparable en UI. Diseño: CANCELAR → `SCA_guardarAutorizacion(mcaAutorizada "N", codEstado "5")` | E: confirmación «Va a proceder a cancelar la solicitud de anulación» → tras ~3 min «CORRECTO / Los datos se han guardado correctamente», pero la solicitud sigue «Pendiente» y retomable. Causa: CORE `guardarAutorizacion` (codEstado 5) responde SOAP fault 4007 «Ocurrio un error en el acceso a la base de datos»; **el mismo error se obtiene ejecutando la regla `SCA_guardarAutorizacion` de SCA** con el mismo payload. El CMD queda en `SCA2 Error` (`AUT_GUARDAR_FAIL`, relanzamiento automático) | **DIVERGENCIA pendiente** (fallo del servicio CORE común a SCA; SCA2 además muestra CORRECTO antes de saber el resultado) | `h4-aut-sca2-e-02-confirmar-cancelar.png`, `-e-03-correcto.png`, `-e-04-sigue-pendiente.png`, `h4-ampl-sca2-e-revision-retomada.png` |
| manual_test_2-14 | Finalizar con plan de pagos | — | — | NO PROBADO: no hay póliza con plan de pagos; ni SCA ni SCA2 tienen lógica de plan de pagos en la pantalla (duda abierta doc 22) | — |

## 4. Divergencias

### 4.1 Fecha autorizada no propagada a la mecanización (aut. 2-3) — pendiente, corrección revertida

- Hecho: CORE sí actualiza la fecha de anulación de la solicitud al aceptar la autorización (C: `fecAnul` 20/10/2026) y `SCA Mecanizacion` la lee de CORE (`pv!solicitudAnulacion.datosCompletosSolicitud.datosSolicitud.fecAnulacion`). SCA2 lee `SCA2 Datos Solicitud.fecanulacion` (snapshot del alta) en `SCA2_MecanizacionPrincipal` y en `SCA2 CMD Mecanizar`, por lo que mostraría y enviaría a CORE la fecha original.
- Intento: `SCA2_AnulacionFueraNormaPrincipal` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423`) v20 → v21 (11:27 UTC): `a!writeRecords` de `fecanulacion` en el saveInto de FINALIZAR. Re-test en E (11:13 UTC): error «Attempted to run a second smart service, but only one smart service can be run per expression evaluation» (convive con `a!startProcess`); el proceso sí se lanzó y E quedó aceptada. **Revertido en v22 (expresión idéntica a v20, readback comprobado).** Backups en local (`~/sca2work/backups/`).
- Propuesta (no publicada): en `SCA2 CMD CompletarAccion` (`0000f06f-1307-8000-65b1-7f0000014e7a`), rama «Autorizacion aceptada» (nodo «Write Decidir»), escribir también `SCA2 Datos Solicitud.fecanulacion = text(todate(resultado.fechaAutorizada), "dd/mm/yyyy")`. No se ha publicado porque no queda póliza para re-probar y el nodo es compartido con la CA negativa de otras sesiones. Reserva del PM liberada sin cambios en `coordinacion-ronda8.md`.
- Pregunta funcional: ¿la fecha que debe regir la mecanización tras una autorización es siempre la fecha autorizada (como hace CORE/SCA)? Si sí, aplicar la propuesta y re-probar con una póliza RCI de reserva.

### 4.2 CANCELAR en Revisión autorización (aut. 2-13) — pendiente, no exclusiva de SCA2

- `guardarAutorizacion` con `codEstado 5 / mcaAutorizada N` devuelve HTTP 500, fault 4007 (`GestionEAO`, `ErrorTecnicoAccesoDatosException`), tanto con la integración de SCA2 como con la regla `SCA_guardarAutorizacion` (probado por LCP sobre 15787895, con y sin `codGestion`/`tipoAutorizacion`/`infoUsuario`). SCA haría la misma llamada (`SCA Autorización`, nodo «Actualizar Autorización»).
- Diferencia de SCA2: la pantalla muestra «CORRECTO» antes del resultado del comando asíncrono y el error queda en la bandeja `SCA2 Error` (sólo administradores); en SCA el error se vería en el proceso. Sin decisión de negocio sobre cómo mostrar al usuario el fallo de un comando, no se corrige.
- Pregunta funcional: ¿debe el usuario ver un aviso en pantalla cuando el comando de cancelación falla en CORE (en lugar de «CORRECTO»)? ¿Hay que abrir incidencia a CORE por el 4007 al cancelar autorizaciones?

### 4.3 Autorización tras mecanización (mec. 2-4) — pendiente, menor

- SCA muestra el modal «El proceso de anulación de la póliza se ha puesto en marcha, a través de la gestión de la petición de autorización…» cuando Emisión devuelve 00000005; SCA2 muestra «La anulación se ha lanzado al sistema de emisión.» y el buscador «Mecanización Enviada» (SCA «Pendiente»). CORE y ANL quedan igual en ambas. Pregunta: ¿se quiere el texto específico de autorización pendiente en SCA2?

## 5. Estados CORE observados (`SCA2_consultaGestion`, hora local Appian = UTC+2)

- 15787878 (A): 8 FINALIZADA 12:17:29 · 2 FINALIZADA NEGATIVA 12:17:46→12:20:01 · 4 FINALIZADA 12:20:03 · 5 ANULACION PENDIENTE DE AUTORIZAR 12:20:14 · 7 FINALIZADA 12:22:20 (sin fin). Autorización codEstado 1, SI24.
- 15787881 (C): 8 FINALIZADA 12:26:11 · 7 FINALIZADA 12:26:27→12:33:27 · 5 INCOMPLETA 12:33:36. Autorización codEstado 2, mcaAutorizada S, fecAnulAutorizada 20/10/2026. `consultarSolicitudes`: fecAnul 20/10/2026, codEstSolic 2.
- 15787891 (D, SCA): 8 FINALIZADA 12:37:15. Nada más tras 30 min.
- 15787895 (E): 8 FINALIZADA 12:43:04 · 7 FINALIZADA 12:43:21→13:13:08 · 5 INCOMPLETA. Autorización codEstado 2, fecAnulAutorizada 20/10/2026. `SCA2 Error`: CompletarAccion / «Actualizar Autorizacion» / AUT_GUARDAR_FAIL 12:44.
- 15787899 (B, SCA): 8 FINALIZADA (alta 10:49 UTC). Nada más.
- Solicitudes históricas 15787858–15787872: sólo lectura; ninguna tenía gestión 7 (autorización) abierta.

## 6. Limitaciones

- SCA TEST: altas que no generan la tarea siguiente en >25 min, 403 «Acceso denegado» y error de evaluación en `sca_datoscabecera` (`a!submitLink`, «save target must be a local variable…») al volver con la flecha interna (`h4-ampl-sca-d-error-volver.png`). Son defectos/latencia de SCA, no se tocan.
- ANL no desbloquea anulaciones en TEST: la mecanización de A queda «Pendiente de autorizar» indefinidamente (conocido).
- Sin pólizas NSE, Mas Móvil ni con plan de pagos: casos NO PROBADOS.
- Las 5 pólizas se han consumido; para re-probar la corrección de §4.1 hace falta una póliza RCI de reserva (pedida en el mensaje final).
- Horas de clic aproximadas (±1 min) salvo las tomadas de CORE.

## 7. Grabaciones y capturas (fuera del repo)

- Vídeo principal: `h4-sca2-sca-comparativa-edited.mp4` (bloques 1 y 2, 10:14–10:54 UTC).
- Vídeo re-test: `h4-retest-v21-edited.mp4` (E, 11:10–11:14 UTC).
- Capturas (`~/sca2work/h4-evidence/`): `h4-mec-sca2-01…08`, `h4-mec-sca-01…04`, `h4-aut-sca2-01…23`, `h4-aut-sca2-e-01…06`, `h4-aut-sca-01…04`, `h4-ampl-*` (SISANS, lecturas cruzadas SCA/SCA2, rondas B/D), `h4-retest-01…05`.
