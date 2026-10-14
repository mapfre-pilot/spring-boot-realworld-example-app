# R10-C · Contra Anulación con pólizas de campaña (TTQ / PREMFIDE / RETOS / SVA) — SCA vs SCA2 (TEST)

Sesión R10-C de la ronda 10 (ver `docs/sca/27-plan-ronda10.md`). Alcance: alta + Contra Anulación con las pólizas de la sección R10-C de `polizas-ronda10.md`, casos del plan `planes/contra-anular-v2.md` que dependen de campaña (2-10 TTQ, 2-11 PREMFIDE, 2-12 RETOS, 2-13 SVA, 2-14 pérdida de descuento), que H3 dejó «no probados por falta de pólizas de campaña».

Referencia de comportamiento: SCA TEST. Sólo se corrigen objetos `SCA2_*`.

## 1. Resumen

**Casos del plan de campaña: 2 OK · 1 OK con divergencias corregidas · 2 pendientes de decisión · 0 no probados por falta de pólizas** (pero **sin referencia SCA en pantalla**: las 4 altas de SCA se crearon en CORE y SCA TEST nunca generó la tarea de Contra Anulación — mismo bloqueo que H3; la comparación se ha hecho contra el diseño SAIL de SCA, que es la referencia, y contra CORE/Club MAPFRE).

| Caso | Veredicto |
|---|---|
| 2-10 Fin positivo TTQ (tréboles) | **Divergencias corregidas** (4 propias de SCA2) y re-probado: asignación real de 1 trébol en Club MAPFRE (0,88 → 1,88) y CA finalizada positiva en CORE |
| 2-10 bis NEGATIVO con argumento TTQ | **OK** |
| 2-10 ter TTQ con cliente no activo en Club MAPFRE | **OK** (mensaje literal de SCA, argumento vuelve a Pendiente) |
| 2-13 Fin positivo SVA | **Pendiente de decisión**: ni SCA ni SCA2 abren el modal de regalos (defecto de diseño heredado de SCA, ver §6) |
| 2-14 Pérdida de descuento | **Pendiente de decisión**: el argumento «PÉRDIDA DE DESCUENTOS» (código 290) no genera SGO ni en SCA ni en SCA2; sólo lo hacen los códigos 358/356, que no aparecen en TEST |
| 2-11 PREMFIDE · 2-12 RETOS | **No probados**: ninguna de las 9 pólizas R10-C dadas de alta ofrece argumentos PREMFIDE/RETOS en TEST (todas las campañas son «Tu te quedas» de tréboles) |

Objetos SCA2 modificados: `SCA2_ContraAnulacionOpciones` 44 → 47, `SCA2_ContraAnulacionModalRecuperacionPoliza` 4 → 5, `SCA2_executeAsignarIntegracion` 1 → 2 (§3). Reservas liberadas en `coordinacion-ronda10.md`.

## 2. Análisis previo del diseño (SCA vs SCA2) — qué hace cada aplicación con una campaña

Flujo SCA (`SCA_ContraAnulacionOpcionesEstrategicas` v9 → modales → `SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas` v7):

1. El listado de argumentos (`consultarListadoArgumentos`) devuelve, además de `listadoArgumentos`, un bloque `treboles` (DEFCART) con, por campaña, `codTrebol`, `descTrebol`, `trebolesDisponibles` y `trebolesRecomendados`.
2. Al seleccionar un argumento, SCA busca su `codTipoArgumento` en DEFCART (`campanaDescart`). Si lo encuentra, el argumento es «Tu te quedas» (`tuTeQuedas`) salvo que la campaña sea `RETOS`. Además consulta `consultarTipoArg` y sólo abre un modal de regateo si el argumento es `regateable = "S"` o está en DEFCART.
3. POSITIVO con argumento de campaña: modal de tréboles («Indique el número de <campaña> a aplicar (máximo: N recomendados: R)»), modal de RETOS (tipos 286/287) o modal de SVA (tipos 252/254/365, lista de regalos y pantalla de correo).
4. Al ACEPTAR el modal de recuperación se ejecutan las acciones: tréboles → `executeAsignar` (Club MAPFRE) y, si es TTQ, `gestionarTTQ` (si no, `marcarAsignacionBonificacion`); RETOS → `asignarRetos` + `gestionarTTQ`; SVA → `asignarSVA` + `marcarAsignacionBonificacion`. Mensajes: «Se ha realizado la asignación de tréboles al usuario correctamente.» (con variante «…muy cerca del Vencimiento…» si vence en ≤ 5 días), «Ha comenzado el proceso de asignación de SVA al cliente de forma correcta.», «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos/Club Mapfre…».

Divergencias propias de SCA2 encontradas en el diseño (antes de probar en UI):

| # | Dónde | SCA | SCA2 (v44 / v4) | Efecto funcional |
|---|---|---|---|---|
| D1 | `SCA2_ContraAnulacionOpciones` → datos que recibe el modal de recuperación | Pasa `tuTeQuedas`, `numBonAplic` (tréboles elegidos), `svaElegido`, `email`, `fecVencimiento`, `mcaTeCuidamos`… | No los pasaba | SCA2 **nunca llamaba a `gestionarTTQ`**, asignaba tréboles con cantidad vacía y el SVA sin regalo elegido |
| D2 | Uso de DEFCART | Máximo y recomendados de la campaña, nombre de la bonificación (`descTrebol`), comprobación «regateable» | Máximo fijo 5, texto fijo «tréboles», sin recomendados, sin comprobar «regateable»; abría regateo según el código de campaña del argumento | Textos y límites del modal distintos; podía abrir regateo en argumentos que en SCA no lo abren |
| D3 | `SCA2_ContraAnulacionModalRecuperacionPoliza` | Tras error de TTQ/Club Mapfre desmarca el argumento; mensaje de éxito con aviso de vencimiento cercano | No desmarcaba; sin aviso | Estado del argumento inconsistente tras error |
| D4 | Correo / cliente para SVA | Correo de contacto de la cabecera e `idCliente` al modal de correo | Correo vacío y sin `idCliente` | La pantalla de correo del SVA salía vacía y no podía actualizar RIC |

Los modales `SCA2_ContraAnulacionModalRetos`, `…ModalSVA` y `…ModalSVAEmail` son idénticos a los de SCA (diff vacío salvo prefijo).

## 3. Objetos Appian modificados

| Objeto | UUID | Versión | Qué cambió | Cómo se probó |
|---|---|---|---|---|
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 44 → 45 | Conserva la respuesta completa del listado (`treboles` DEFCART); `arrayTrebolesDisponibles/Recomendados`, `campanaDescart`, `codCampana`, `tuTeQuedas`, `consultarTipoArg` → `esRegateable`; `maximo`/`tipoBonificacion` dinámicos; `fecVencimientoPoliza`; correo desde `SCA2_obtenerDatosCabecera`; puerta `esRegateable` en el despacho de modales; `data` del SGO con `codCampania`, `trebolesRecomendados`, `nuuma`, `idCliente`; `data` del modal de recuperación con `mcaTeCuidamos`, `tuTeQuedas`, `fecVencimiento`, `numBonAplic`, `svaElegido`, `email`, `mcaPropietarioPoliza`, `claveProduccion`, `argumentoEconomico`, `descTipoArgumento` | GET vivo + backup, PUT completo, relectura idéntica, `testInterface` con una solicitud existente sin errores; UI (§4) |
| `SCA2_ContraAnulacionOpciones` | idem | 45 → 46 | La ventana «¡Enhorabuena en la retención…!» ya no se muestra mientras está abierto el modal de tréboles/retos/SVA/correo (SCA: `showWhen` con todos los flags de modal a false) | UI: en 15788004 y 15788000 el modal y la confirmación aparecen por separado |
| `SCA2_ContraAnulacionOpciones` | idem | 46 → 47 | `local!nifTomadorCalc`: el NIF del tomador se toma de datos de póliza/cabecera (los datos básicos de la solicitud SCA2 no lo guardan y `estado.nifTomador` viene vacío). Se usa en `numDoc` (Club MAPFRE, SVA, clasificación TC, altas SGO) | Club MAPFRE devolvía «Es obligatorio especificar el identificador de cliente»; tras v47 asigna el trébol (15788000) |
| `SCA2_executeAsignarIntegracion` | `6eb7470e-5807-4050-801c-442bdab112c3` | 1 → 2 | `ignoreEmptyHeaders` a false para que se envíe la cabecera `SOAPAction: ""` que exige el servicio SocioAsignarTreboles (Axis respondía 500 «no SOAPAction header!»; `SCAC_executeAsignarIntegracion` sí la envía) | Test LCP con NIF inválido: antes 500, después 200 con `inderror=1` igual que SCAC; UI 15788000 |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951` | 4 → 5 | Mensaje de éxito TTQ con variante «muy cerca del Vencimiento»; desmarca el argumento (`estadoArgumentos = "0"`) en error de TTQ y de Club Mapfre | Idem; `testInterface` sin errores; UI (§4) |

## 4. Resultados por caso



### 4.1 Solicitudes creadas en esta sesión

| App | Póliza | Solicitud | Gestión CA | Argumentos de campaña vistos | Uso |
|---|---|---|---|---|---|
| SCA | 0731380063613 | 15787972 | — (sólo alta 43705612) | — | GUARDAR tardó ~5 min y acabó en «403 Acceso denegado»; la solicitud se creó pero SCA no generó la tarea de CA |
| SCA | 0731380341847 | 15787981 | — (sólo alta 43705629) | — | Idem |
| SCA | 0006661200369 | 15787988 | — | — | Idem |
| SCA | 0732000133236 | 15787993 | — | — | Idem |
| SCA2 | 0731600130561 | — | — | — | El alta no creó solicitud (póliza vencida 19/09/2026) |
| SCA2 | 2002300400992 | 15787983 | 43705638 FINALIZADA POSITIVA 16:10 | SERVICIO VALOR AÑADIDO (252) | Caso 2-13 SVA: POSITIVO sin modal de regalos (igual que SCA por diseño, ver §6) |
| SCA2 | 2002100432427 | 15787994 | 43705658 FINALIZADA POSITIVA 16:20 | TU TE QUEDAS BANKIA 76 TREBOLES DISPONIBLES (DEFCART TTQBANKIA), PÉRDIDA DE DESCUENTOS (290) | Caso 2-10 TTQ (validaciones, cancelar, error de integración → corregido) y 2-14 |
| SCA2 | 2002100425210 | 15788000 | 43705672 FINALIZADA POSITIVA 16:35 | TU TE QUEDAS CONCESIONARIOS 40 TREBOLES DISPONIBLES | Caso 2-10 TTQ POSITIVO completo (TTQAUTOCON, máximo 40, 1 trébol asignado: Club MAPFRE pasa de 0,88 a 1,88) |
| SCA2 | 2002300300497 | 15788003 | CA FINALIZADA NEGATIVA | TU TE QUEDAS NO CLUB MAPFRE 20 TREBOLES DISPONIBLES | Caso 2-10 NEGATIVO con argumento de campaña (sin modal; exige imprimir carta; redirige a Anular póliza, no anulada) |
| SCA2 | 2002300379272 | 15788004 | INCOMPLETA (pendiente) | TU TE QUEDAS NO CLUB MAPFRE 30 TREBOLES DISPONIBLES | Caso 2-10 con cliente no activo en Club MAPFRE: mensaje «No se han podido asignar tréboles… no está dado de alta en te cuidamos… El cliente no tiene ningún contrato en vigor…» y argumento vuelve a Pendiente |
| SCA2 | 2002100424271 | 15788006 | pendiente | TU TE QUEDAS 30 TREBOLES DISPONIBLES | Sólo captura del argumentario (10 argumentos); sin ejecutar |
| SCA2 | 2002100432557 | 15788008 | pendiente | TU TE QUEDAS BANKIA 56 TREBOLES DISPONIBLES | Sólo captura (9 argumentos); sin ejecutar |
| SCA2 | 0007051028157 (RCI) | 15788010 | pendiente | TU TE QUEDAS RCI 30 TREBOLES DISPONIBLES | Sólo captura; aviso «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24…»; sin ejecutar |
| SCA2 | 2002100432564 | 15788011 | pendiente | TU TE QUEDAS RCI 76 TREBOLES DISPONIBLES | Sólo captura; el alta volvió al formulario tras ACEPTAR aunque la solicitud se creó (se abrió por RETOMAR); sin ejecutar |


## 5. Hallazgos externos (CORE / NSE / Emisión / Documentum)

_(pendiente)_

## 6. Preguntas para el analista

_(pendiente)_

Pólizas R10-C no consumidas (disponibles): 2002200295382, 0007051028913, 0732200228788, 2002500478924, 2002100432565, 0002940500039, 2002100432564 (consumida), 0731380454474, 0731380454486, 0007051033953, 0731700187136, 2002500381088, 0732400120983, 2002100424268, 2002100432561, 2002300392341, 2002500484818, 0730380324165, 2002100424266. Ninguna solicitud de rondas anteriores se ha tocado; ninguna solicitud creada tiene registros en la bandeja de errores de SCA2.

### 4.2 Tabla por caso del plan

| Id | Caso | SCA (referencia) | SCA2 | Veredicto | Solicitudes / pólizas |
|---|---|---|---|---|---|
| 2-10 | Fin positivo argumento TTQ: modal con tréboles a asignar, validaciones en defecto/exceso, cancelar y volver, asignar y finalizar | Diseño: modal «Indique el número de <campaña> a aplicar (máximo: N recomendados: R)», «El valor ha de ser mayor que 0» / «El valor no puede ser mayor que el máximo indicado», CANCELAR desmarca el argumento; al ACEPTAR la retención llama a Club MAPFRE y a `gestionarTTQ` y finaliza. No se pudo ver en pantalla (SCA TEST sin tarea de CA) | Antes: máximo fijo 5 sin campaña, `gestionarTTQ` nunca llamado, Club MAPFRE con cliente vacío y cabecera SOAP ausente, confirmación de retención visible bajo el modal. Después (v47 / v2 / v5): modal «Indique el número de TTQAUTOCON a aplicar (máximo: 40)», validaciones 0 y 41 con los literales de SCA, ACEPTAR deshabilitado si el valor no es válido, CANCELAR vuelve a la CA, con 1 trébol: finaliza positiva (CORE 43705672) y el cliente pasa de 0,88 a 1,88 tréboles | **Divergencias corregidas** | 15787994 (2002100432427, TTQBANKIA máx. 76), 15788000 (2002100425210, TTQAUTOCON máx. 40) |
| 2-10 | NEGATIVO con argumento TTQ seleccionado | Diseño: NEGATIVO ejecuta `guardarEjecuArg` sin modal; FINALIZAR exige la carta impresa | Igual: sin modal; FINALIZAR exige «Se ha de imprimir la plantilla de la carta firmada», visor PDF → CONTINUAR → «Se va a finalizar la gestión de contra anulación»; CORE: CA FINALIZADA NEGATIVA, impresión FINALIZADA, mecanización INCOMPLETA; redirige a Anular póliza (no se anuló) | **OK** | 15788003 (2002300300497) |
| 2-10 | TTQ con cliente no activo en Club MAPFRE | Diseño: mensaje «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos… Mensaje obtenido de Te Cuidamos: …» y el argumento vuelve a Pendiente | Mensaje idéntico («…El cliente no tiene ningún contrato en vigor en la fecha indicada.»), argumento Pendiente, solicitud sigue pendiente | **OK** (el reset a Pendiente es la corrección v5) | 15788004 (2002300379272) |
| 2-11 | Fin positivo PREMFIDE | — | — | **No probado**: ninguna póliza R10-C ofrece argumento PREMFIDE en TEST (9 argumentarios revisados) | — |
| 2-12 | Fin positivo RETOS (286/287) | — | — | **No probado**: no aparece argumento RETOS en ninguna póliza R10-C (DEFCART sólo devuelve campañas «Tu te quedas») | — |
| 2-13 | Fin positivo SVA: modal de regalos y pantalla de correo | Diseño: la regla `SCA_obtenerSVADisponibles` devuelve directamente la lista de regalos, pero la pantalla comprueba `index(lista, "sva")` → siempre vacío → **el modal de regalos nunca se abre en SCA**; el flujo sigue como un positivo normal | Igual que SCA: POSITIVO con «SERVICIO VALOR AÑADIDO» no abre modal; aviso «La póliza está anulada, debe proceder a su operativa habitual…» y finaliza positiva (CORE 43705638). La lista de regalos del cliente sí existe (dos cheques carburante, igual en SCA y SCA2) | **Pendiente de decisión** (paridad con un defecto de SCA) | 15787983 (2002300400992) |
| 2-14 | Pérdida de descuento (SGO de vinculación/retención) | Diseño: sólo los argumentos 358/356 generan SGO; «PÉRDIDA DE DESCUENTOS» es el código 290/291 y no lo genera | Igual: POSITIVO con PÉRDIDA DE DESCUENTOS finaliza positiva sin SGO (CORE 43705658) | **Pendiente de decisión** | 15787994 |
| — | Avisos/tarjetas sólo con campaña | Argumento con DEFCART: descripción compuesta «TU TE QUEDAS … N TREBOLES DISPONIBLES»; aviso de acuerdo especial en pólizas RCI | Igual (9 argumentarios); aviso «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.» en 0007051028157 | **OK** | 15788006, 15788008, 15788010, 15788011 |
| — | Tras CANCELAR el modal el checkbox del argumento sigue marcado | Igual por diseño (la tabla guarda la selección en `local!selection` y sólo se resetea el estado) | Igual | **OK** (paridad; ver §6) | 15787994, 15788004 |
| — | Mensaje «Se ha realizado la asignación de tréboles al usuario correctamente.» | Diseño: el modal fija el mensaje pero en el mismo clic llama a `guardarEjecuArg` y finaliza (no llega a verse) | Igual: finaliza y vuelve al listado en ~35 s sin mostrar el mensaje | **OK** (paridad; ver §6) | 15788000 |

Evidencias (`docs/sca/pruebas/evidencias/r10c/`): `sca2_2002100432427_ca_antes.png` (argumentario con TTQ), `sca2_2002100432427_ttq_cero.png`, `sca2_2002100432427_ttq_exceso.png`, `sca2_2002100432427_ttq_error_integracion.png` (antes de la corrección), `sca2_15788000_v47_ttq_modal.png`, `sca2_15788000_v47_retencion.png`, `sca2_15788000_v47_listado_final.png`, `sca2_15788000_v47_detalle_ttq.png`, `sca2_15788003_ttq_negativo.png`, `sca2_15788003_ca_finalizada_negativa.png`, `sca2_15788004_ttq_modal.png`, `sca2_15788004_no_te_cuidamos.png`, `sca2_2002300400992_sva_positivo_sin_modal.png`, `sca2_15788010_aviso_si24.png`, `sca_0731380063613_alta_403.png`, `sca_0731380341847_sin_ca.png`.

## 5. Hallazgos externos (CORE / NSE / Emisión / Documentum / SCA TEST)

1. **SCA TEST no genera la tarea de Contra Anulación tras el alta**: las 4 altas (15787972, 15787981, 15787988, 15787993) tardaron ~5 min en GUARDAR, acabaron en «403 Acceso denegado» y CORE sólo tiene la gestión de alta (acción 8). Mismo comportamiento que en H3. Sin referencia SCA en pantalla; la comparación es contra el SAIL de SCA y CORE.
2. **Club MAPFRE (SocioAsignarTreboles)** exige la cabecera `SOAPAction` aunque esté vacía; valida NIF («El número mínimo de caracteres del NIF/NIE/CIF es de 3») y contrato en vigor («El cliente no tiene ningún contrato en vigor en la fecha indicada»).
3. **Detalle SCA2**: tras finalizar la CA (positiva en CORE) la tarjeta «Contra anulación» sigue «Incompleta» sin fecha fin y «Argumentos ejecutados» muestra otros argumentos (15787994, 15788000). Objeto `SCA2_DetalleSolicitud` (PADRE/otras sesiones); no tocado.
4. **Misma configuración defectuosa que `SCA2_executeAsignarIntegracion` (SOAPAction vacío + `ignoreEmptyHeaders`)** en `SCA2_consultarDPIntegracion` y `SCA2_inbsDeleteDocumentDTOIntegracion`: fuera de mi alcance (plan de pagos / documentos); conviene revisarlas.
5. **Alta SCA2**: con 2002100432564 (15788011) y 2002100425210 el formulario volvió al alta sin confirmación aunque la solicitud se creó (latencia); 0731600130561 (vencida 19/09/2026) no creó solicitud.
6. En TEST ninguna póliza R10-C tiene campañas RETOS ni PREMFIDE ni argumentos 358/356; DEFCART sólo devuelve «Tu te quedas» (TTQBANKIA, TTQAUTOCON, TTQAUTOS, NO CLUB MAPFRE, RCI).

## 6. Preguntas para el analista (lenguaje funcional)

1. **Regalos SVA**: en SCA TEST, al finalizar en positivo con el argumento «Servicio valor añadido», no se abre la ventana para elegir el regalo ni la de correo, aunque el cliente tiene regalos disponibles (p. ej. cheques carburante). SCA2 hace lo mismo. ¿Debe SCA2 abrir esa ventana (como describe el plan de pruebas) o mantenerse igual que SCA hoy?
2. **Pérdida de descuentos**: el argumento «PÉRDIDA DE DESCUENTOS» no genera la solicitud SGO de descuento ni en SCA ni en SCA2; sólo la generan los argumentos «descuento por vinculación/retención» (que no existen en TEST). ¿Es el comportamiento esperado?
3. **Mensaje de éxito de tréboles**: al confirmar la retención con tréboles, la asignación se hace y la solicitud se finaliza directamente sin que el usuario vea «Se ha realizado la asignación de tréboles al usuario correctamente.» (igual en SCA por diseño). ¿Debe mostrarse el mensaje antes de finalizar?
4. **Checkbox tras cancelar**: al cancelar la ventana de tréboles el argumento queda en Pendiente pero su casilla sigue marcada (igual en SCA). ¿Debe desmarcarse?
5. **Tarjeta de Contra anulación en el detalle**: tras una CA positiva (confirmada en CORE) el detalle de SCA2 muestra la contra anulación «Incompleta». ¿Qué debe mostrar la tarjeta en ese caso?
6. **Pólizas de acuerdo especial (RCI)** con argumento «Tu te quedas RCI»: aparece el aviso de que debe gestionarla SI24 y no se puede anular desde la pantalla. ¿Debe permitirse igualmente asignar tréboles desde Oficina?
