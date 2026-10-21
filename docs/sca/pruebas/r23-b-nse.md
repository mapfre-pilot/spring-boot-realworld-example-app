# R23-B — Pólizas NSE: recién emitidas, a futuro y renovadas (SCA vs SCA2, TEST)

Ronda 23, escenario H-B. Sesión Devin `477506ddf3fa486aa784bfc7a5376775` (20/10/2026). Entorno **TEST** (`mapfrespain-test`). Usuario UI: JJGONZ2 (Oficina, CE_RM / CE_RM_OFICINA). Lectura de estado por LCP (`SCA2_consultaGestion`, `SCA2_consultarCabeceraSolicitud`, `SCA2_consultarDetalleSolicitud`, `SCA2_cargarSolicitud`, `ANL_getAnulacionByFilter_qr`, instancias de PM, bandeja `SCA2 Error`).

> Regla de la ronda: SCA TEST es la referencia funcional; sólo se corrige SCA2 cuando la divergencia es exclusiva de SCA2 y la corrección es clara. Nunca se han tocado objetos de SCA/SCAC/CORE.

## 1. Pólizas del ODS: selección y descartes

Comprobación previa por LCP (`SCA2_consultarSolicitudes(numPoliza, "", "0")`, cabecera `SCA2_obtenerDatosCabecera` = `SCA_obtenerDatosCabecera`, idénticas en las dos apps para las 9 pólizas consultadas).

| Columna ODS | Póliza | Cabecera (Emisión) | Solicitud previa | Uso |
|---|---|---|---|---|
| A. NSE emitidas después de septiembre | 2002000157937 | TODO RIESGO, efecto 02/09/2026 – venc. 02/09/2027, RED AGEN / Expertos | ninguna | **SCA2** → 15788155 |
| A | 2002400468198 | IMPULSO TODO RIESGO, 20/08/2026 – 20/08/2027, RED AGEN / Expertos | ninguna | **SCA** → 15788154 |
| A | 2002000200336 | BASICar TR, 28/09/2026, CORREDORES / No Expertos | ninguna | reserva (no usada: productor distinto) |
| A | 2002600013207 | IMPULSO TR, 08/02/2026, AUTOMOCION / No Expertos | ninguna | reserva (no usada) |
| A | 2002100296038 / 2002400468198 / 2002500491505 / 2002500495460 / 2002100505983 | TERCEROS 09/08/2026, IMPULSO TR 20/08/2026, BASICar TR 04/12/2025, TERCEROS 22/12/2025, TR 24/09/2026 | ninguna | consultadas; sólo 2002400468198 usada |
| B. Emitidas a futuro | 2002600059907 | Emisión **no devuelve la póliza** (producto/efecto/vencimiento vacíos, prima NO DISPONIBLE; CORE sí devuelve tomador) | ninguna | **SCA2** (alta fallida, ver §3) |
| B | 0732600004759 | ídem | ninguna | **SCA** → 15788158 |
| B | 2002600060945 | ídem | ninguna | **SCA2** reintento tras corrección (ver §3) |
| B | 0732600005004 | ídem | ninguna | reserva |
| C. Renovadas | 0730080000252 | — | **15786171** (codEstSolic 14) | descartada: ya tenía solicitud |
| C | 0730080003931 | — | **15786172** (codEstSolic 6) | descartada: ya tenía solicitud |
| C | 0730780285731 | HOGAR FAMILIAR, 06/06/2026 – 06/06/2027, RED AGEN / Expertos | ninguna | **SCA2** → 15788163 |
| C | 0730980605812 | HOGAR FAMILIAR, 03/12/2025 – 03/12/2026, RED AGEN DIR / Expertos | ninguna | **SCA** → 15788162 |
| C | 0731480115289 | HOGAR FAMILIAR, 04/03/2026, INTERNET-TELEFO / Telemática | ninguna | reserva (no usada) |

Observaciones sobre el listado del analista:
- Las pólizas «a futuro» no existen para Emisión ni hoy ni con `pfechaconsulta` 21/10/2026, 15/11/2026, 15/01/2027 o 01/06/2027 (`pObtenerPolizaFecha` devuelve `coderror 20001 CODIGO INEXISTENTE [f_fila_a_fecha]…` sin fecha y `null` con fecha). CORE (`consultarPolizas`) tampoco las tiene (`COD_SAL 1 Error al obtener los datos de la poliza`, normal para NSE). Sólo el tomador llega (API Clients).
- `SCA2_polizaRenovada` devuelve `true` también para 2002000157937 y 2002600013207 (columna A), `false` para 2002000200336: la columna «emitidas después de septiembre» contiene pólizas que Emisión considera renovadas (tienen anualidad futura).

## 2. Solicitudes creadas (todas nuevas, 20/10/2026)

| Id | App | Póliza | Columna | Recorrido UI |
|---|---|---|---|---|
| 15788155 | SCA2 | 2002000157937 | A | Alta → Contra Anulación negativa → Impresión → Verti previa → Mecanización → ANULAR PÓLIZA |
| 15788154 | SCA | 2002400468198 | A | Alta → CA negativa → Impresión → Verti → Mecanización → ANULAR PÓLIZA → **RGPD** |
| 15788158 | SCA | 0732600004759 | B | Alta (GUARDAR OK) |
| — | SCA2 | 2002600059907 | B | Alta: **error al GUARDAR** (antes de la corrección) |
| (ver §3) | SCA2 | 2002600060945 | B | Alta tras la corrección |
| 15788163 | SCA2 | 0730780285731 | C | Alta → CA negativa → Impresión → Verti previa → (Mecanización no creada: error CORE) |
| 15788162 | SCA | 0730980605812 | C | Alta → CA negativa → Impresión → **error servicio de decisión** → FINALIZADO NEGATIVO CON CONTRAANULACIÓN |

Protegidas no tocadas. Otras solicitudes del mismo día de otras sesiones (15788152, 15788153, 15788156…) no se han abierto.

## 3. Comparación paso a paso

### 3.1 Columna A — NSE Autos emitidas después de septiembre (SCA2 15788155 / SCA 15788154)

| Paso | SCA (15788154, pól. 2002400468198) | SCA2 (15788155, pól. 2002000157937) | ¿Igual? |
|---|---|---|---|
| Popup alta | Sin mensaje, botón habilitado | Sin mensaje, botón habilitado | Sí |
| Cabecera del alta | Producto, efecto/vencimiento, forma de pago, productor y prima iguales a los de la cabecera por LCP | Ídem | Sí (misma regla de cabecera; respuestas idénticas por LCP) |
| Catalogación propuesta (REST catalogación) | `codCatalogacionDefecto 2` «A VENCIMIENTO», fecha propuesta = vencimiento (20/08/2027) | `2` «A VENCIMIENTO», fecha = 02/09/2027 | Sí (`SCA_consultarCatalogacionRest` y `SCA2_consultarCatalogacionRest` devuelven lo mismo con la misma consulta) |
| Mensaje al GUARDAR | Solicitud creada, redirección a la acción | Solicitud creada, redirección a la acción | Sí |
| Decisión del motor (nivel 1) | CONTRAANULAR | CONTRAANULAR (`CMD Decidir`: accion CONTRAANULAR, nivelCalc 1, origen NSE-Autos) | Sí |
| Contra Anulación negativa + FINALIZAR | Gestión CORE `2` FINALIZADA NEGATIVA; impresión `4` FINALIZADA | Ídem (43706149 / 43706154) | Sí |
| Decisión tras CA | Verti previa → Mecanización | `CMD Decidir` MECANIZAR; `CMD CrearAccion` crea tarea VERTI-PRE y luego MECANIZAR | Sí |
| ANULAR PÓLIZA | Pantalla **RGPD** («Este cliente no ha firmado…»: email/SMS o impresión/firma; al cerrar exige certificar «RGPD FIRMADA»). CORE: gestión `5` **ANULACION REALIZADA** (43706159) antes de resolver el RGPD | Mensaje de petición de autorización enviada a SGO/NSE; Verti y Mecanización «Finalizada» en Detalle. CORE: gestión `5` **ANULACION PENDIENTE DE AUTORIZAR** (43706156) | **No** (ver D1 y D2) |
| Tras mecanizar | PM `SCA Alta Solicitud Anulacion` decide **CONTRA ANULAR NIVEL 2** (`accion = "CONTRA ANULAR NIVEL 2"`, grupo CE_RM) → gestión CORE `2` **INCOMPLETA** (43706164); `nivelIntervencion` 2 | `CMD Decidir` vuelve a preguntar al motor → **CONTRA ANULAR NIVEL 2** (grupo CE_RM, nivelCalc 2, gestión SGC 233844292) → gestión CORE `2` **INCOMPLETA** (43706157); `nivelIntervencion` 2 | **Sí** (D3: paridad; cierra el pendiente de R23-1) |
| Catalogación final en CORE (`consultarCabeceraSolicitud`) | `catalogacion 1` (A EFECTO), `fecAnulacion 20/08/2027`, `descPca …CATALOGACION: A EFECTO…` | `catalogacion 2` (A VENCIMIENTO), `fecAnulacion 02/09/2027`, `descPca …A VENCIMIENTO…`; record `SCA2 Datos Solicitud.catalogacion = 1` | **No** (D4) |
| Detalle | PENDIENTE, A EFECTO 20/08/2027, gestión Mecanización «Anulación realizada» | PENDIENTE, A VENCIMIENTO 02/09/2027, Verti/Mecanización finalizadas | Parcial |
| ANL Anulacion (fila) | id 2158, TIPO_FLUJO 4, CATALOGACION 1, COD_CAUSA 00000005, OBSERVACIONES vacío, NUM_GESTION vacío, CONCLUIDA false, MODIFICADOR deployment.user | id 2157, TIPO_FLUJO 2, CATALOGACION 1, COD_CAUSA 00000005, OBSERVACIONES «00000005» (nivel Emisión), NUM_GESTION 43706156, CONCLUIDA false, MODIFICADOR Administrator | Parcial (misma alta ANL; distinto flujo) |
| Bandeja de errores SCA2 | — | Sin filas para 15788155 | — |

Nota: la rama «wAutemis pendiente de aceptar» del PM `SCA2 CMD Mecanizar` (nodos 9/324: `origenPoliza = wAutemis` y `observaciones ∈ {00000005, 00000006}`) **no** se activa para NSE: `pv!observaciones = "00000005"` es aquí el *nivel Emisión* (token de la tarea Verti `MEC:<nivel Emisión>|…`), no el código de autorización pendiente.

### 3.2 Columna C — NSE Hogar renovadas (SCA2 15788163 / SCA 15788162)

| Paso | SCA (15788162, pól. 0730980605812) | SCA2 (15788163, pól. 0730780285731) | ¿Igual? |
|---|---|---|---|
| Popup / cabecera / catalogación propuesta | Sin bloqueo; HOGAR FAMILIAR; `2` A VENCIMIENTO, fecha 03/12/2026 | Sin bloqueo; HOGAR FAMILIAR; `2` A VENCIMIENTO, fecha 06/06/2027 | Sí |
| GUARDAR / decisión | Solicitud creada; CONTRAANULAR | Solicitud creada; CONTRAANULAR (`CMD Decidir` nivel 1, origen NSE-Hogar) | Sí |
| CA negativa + FINALIZAR | Gestiones `8` FIN, `2` FIN NEGATIVA, `4` FIN (43706182/85/90) | Gestiones `8` FIN, `2` FIN NEGATIVA, `4` FIN (43706183/84/89) | Sí |
| Siguiente paso | «Se ha producido el siguiente error en el servicio de decisión:» (sin detalle) → la solicitud queda **FINALIZADO NEGATIVO CON CONTRAANULACIÓN**, sin tarea Verti/Mecanización. PM `SCA Alta Solicitud Anulacion` 10150764: `accion = "ERROR"` (18:06:41) | `CMD Decidir` MECANIZAR → Verti previa (Continuar, CORRECTO) → `CMD CrearAccion` 269111397 falla en nodo **«Alta gestion CORE»**: `CORE_ALTA_GESTION` «Ocurrio un error en el acceso a la base de datos. Compruebe que los valores introducidos son correctos.» (18:06:07) → `SCA2 Error` #111 PENDIENTE (reintento 18:36); record `estadoSolicitud = ERROR`, `procesoActivo = MECANIZAR`. Detalle: PENDIENTE, sin Mecanización | **Mismo fallo de CORE a la misma hora en las dos apps** (D5: no exclusivo de SCA2) |
| Catalogación final CORE | `1` A EFECTO, `fecAnulacion 03/12/2026` | `2` A VENCIMIENTO, `fecAnulacion 06/06/2027`; record SCA2 `catalogacion 1` | **No** (D4) |
| Cruce | 15788162 en el buscador SCA2: «Solicitud Finalizada sin anular» | 15788163 en el buscador SCA: estado PENDIENTE | — |

### 3.3 Columna B — pólizas «a futuro» (SCA 15788158 / SCA2)

| Paso | SCA (pól. 0732600004759) | SCA2 (pól. 2002600059907, antes de la corrección) | ¿Igual? |
|---|---|---|---|
| Popup alta | Sin mensaje al salir del campo; botón habilitado | Sin mensaje; botón habilitado | Sí |
| Formulario | Datos de cliente sí; póliza incompleta: producto/efecto/vencimiento/pago «-», prima NO DISPONIBLE, productor RED AGEN / Expertos / No Telemática | Ídem | Sí |
| GUARDAR | «Su solicitud se ha generado correctamente. Se le va a redirigir a la acción correspondiente» → **15788158** (sin aviso de póliza a futuro) | **Error Appian** en `SCA2_AltaSolicitudPage` (a!buttonWidget línea 767; `text` línea 808: «A null parameter has been passed as parameter 1»); no se crea solicitud | **No** → **D6, corregida** |
| Siguiente paso | Contra Anulación **NIVEL 1** → CA negativa → Verti → Mecanización → ANULAR PÓLIZA → RGPD (TEST) → «Su petición de anulación ha sido enviada. Se traslada aviso a la clave propietaria». CORE: `8` FIN, `2` FIN NEG, `4` FIN, `5` **ANULACION REALIZADA** (43706173), `2` INCOMPLETA (CA nivel 2); `catalogacion 1`, `fecAnulacion 17/12/2027` (fecha propuesta por el REST para una póliza que Emisión no conoce) | — | — |
| **Reintento SCA2 tras la corrección (v37)**, pól. 2002600060945 | — | Popup sin mensaje → formulario sin datos de póliza → propuesta `A VENCIMIENTO 01/12/2027` → GUARDAR: ya **no hay excepción**; devuelve la validación funcional «Se han detectado los siguientes errores: La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.» y no crea solicitud | **No** (D7, no corregida: decisión funcional) |

Decisión del analista a verificar («aviso solo al guardar»): **ninguna de las dos apps avisa en el popup**; SCA no avisa tampoco al guardar (crea la solicitud y llega a anular con fecha 17/12/2027); SCA2 (v37) bloquea al guardar con el mensaje de vencimiento. `SCA_erroresGuardarSolicitud` y `SCA2_erroresGuardarSolicitud` devuelven **el mismo error** con `fechaVencimiento` nulo (probado por LCP con los mismos datos): la diferencia está en que la pantalla de alta de SCA no bloquea el guardado con ese resultado en este camino, y la de SCA2 sí.

## 4. Divergencias

| # | Divergencia | ¿Exclusiva SCA2? | Acción |
|---|---|---|---|
| D1 | Tras ANULAR PÓLIZA, SCA muestra la pantalla **RGPD** (consentimiento: email/SMS/impresión y certificación «RGPD FIRMADA»); SCA2 no tiene paso RGPD | Sí | **No corregida**: es una funcionalidad completa (plantillas, envío, certificación) → decisión funcional. Documentada. |
| D2 | Resultado CORE de la mecanización: SCA `ANULACION REALIZADA`; SCA2 `ANULACION PENDIENTE DE AUTORIZAR` (ambas NSE Autos, RED AGEN/Expertos; ambas crean fila ANL con el mismo nivel Emisión 00000005). En SCA2 el usuario ve «petición de autorización enviada por SGO/NSE»; en SCA «Anulación realizada» | Sí (misma póliza-tipo, mismo CORE) | **No corregida**: SCA2 CMD Mecanizar fija el estado de la gestión a partir de la respuesta de Emisión/ANL; falta determinar qué dato de CORE usa SCA (`actualizarMecanizacion codEstMecanizacion "7"`/`"3"`) → pregunta al analista. |
| D3 | Tras mecanizar, nueva Contra Anulación **nivel 2** (`INCOMPLETA`, `nivelIntervencion 2`) | **No**: SCA también lo hace (15788154 y 15788158: gestión `2 INCOMPLETA` tras `ANULACION REALIZADA`; PM SCA `accion = CONTRA ANULAR NIVEL 2`) | Paridad confirmada; **cierra el pendiente de R23-1** (doc 41): no es divergencia. |
| D4 | Catalogación en CORE: SCA guarda **1 (A EFECTO)** y SCA2 **2 (A VENCIMIENTO)** para NSE renovadas con propuesta 2. Ambas apps calculan `determinarCatalogacionRenovada → 1` y lo guardan en su record (`SCA datosSolicitud` / `SCA2 Datos Solicitud` = 1); SCA actualiza CORE a 1 durante la CA (`SCA_modificarCatalogacionCodCiaCntrAnul` con la catalogación del record); SCA2 llama a la misma integración con el valor del record (`SCA2_cargarSolicitud` = 1) pero CORE sigue en 2 | Sí | **No corregida**: no he podido determinar por LCP por qué la actualización no llega a CORE (la respuesta de `modificarCatalogacion` no se persiste); el Detalle SCA2 muestra A EFECTO o A VENCIMIENTO según cargue del record o de CORE. Pendiente de depurar en una sesión con acceso a logs. |
| D5 | Columna C: CA negativa → siguiente acción falla (`CORE_ALTA_GESTION` «error en el acceso a la base de datos») | **No**: SCA falló a la misma hora («error en el servicio de decisión», PM `accion = ERROR`) | Fallo de CORE; en SCA2 queda en bandeja de errores con reintento automático; en SCA la solicitud se cierra como FINALIZADO NEGATIVO CON CONTRAANULACIÓN. Comportamiento ante el error distinto (SCA2 recuperable), documentado. |
| D6 | GUARDAR con póliza sin efecto/vencimiento (a futuro): SCA2 lanzaba excepción `text(null)` | Sí | **Corregida** (§5). |
| D7 | Tras D6, SCA2 bloquea el guardado con «La fecha de anulación no puede ser superior a la fecha de vencimiento»; SCA crea la solicitud y permite anular una póliza que Emisión no conoce | Sí (en el bloqueo), pero el comportamiento de SCA parece el incorrecto | **No corregida**: decisión funcional (¿debe permitirse el alta de una póliza a futuro? ¿con qué aviso?). |
| D8 | Etiquetas de estado del buscador (HU3980): SCA2 «Pendiente de Autorización» / «Solicitud Finalizada sin anular» vs SCA «Pendiente» / «Finalizado negativo con contraanulación» | Sí (ya conocida) | Documentada (HU3980, doc r10). |
| D9 | Popup de alta: SCA2 añade ramo 101 (Vida), bloqueo con `polizaVigente = false` (sin efecto: la regla devuelve texto) y estados abiertos {1,2} vs {1,2,7,8,9,10,16,17} en SCA | Sí (ya documentadas en rondas anteriores) | Sin cambios. |

## 5. Objetos SCA2 modificados

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_AltaSolicitudPage` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | 36 → **37** | Bloque de recatalogación en GUARDAR (añadido en v36 por otra sesión de la ronda) hecho **null-safe**. Antes: `text(local!fechaAnulacionCambio,"dd/MM/yyyy") = text(local!fechaEfectoAnualidadCurso,"dd/MM/yyyy")` (y el equivalente con `fechaVencimiento`) rompía con fechas nulas. Después: `if(a!isNullOrEmpty(local!fechaAnulacionCambio), null, if(if(a!isNullOrEmpty(local!fechaEfectoAnualidadCurso), false, text(…)=text(…)), a!save(local!tipoCatalogacion,"1"), if(if(a!isNullOrEmpty(local!fechaVencimiento), false, text(…)=text(…)), a!save(local!tipoCatalogacion,"2"), null)))`. Procedimiento: GET vivo → backup local (`before/after .sail`) → PUT completo → re-GET (v37, 1135 líneas) → prueba UI (B v37). |

No se ha modificado ningún otro objeto. No se han tocado objetos SCA/SCAC/CORE/ANL.

## 6. Estados CORE observados (`SCA2_consultaGestion` / `consultarCabeceraSolicitud`, 20/10/2026 ~20:30)

| Solicitud | Gestiones (accionRealizada → codEstGestion) | catalogacion / fecAnulacion / nivel |
|---|---|---|
| 15788155 (SCA2, A) | 8 FINALIZADA · 2 FINALIZADA NEGATIVA · 4 FINALIZADA · 5 ANULACION PENDIENTE DE AUTORIZAR · 2 INCOMPLETA | 2 / 02/09/2027 / 2 |
| 15788154 (SCA, A) | 8 FINALIZADA · 2 FINALIZADA NEGATIVA · 4 FINALIZADA · 5 ANULACION REALIZADA · 2 INCOMPLETA | 1 / 20/08/2027 / 2 |
| 15788158 (SCA, B) | 8 FINALIZADA · 2 FINALIZADA NEGATIVA · 4 FINALIZADA · 5 ANULACION REALIZADA · 2 INCOMPLETA | 1 / 17/12/2027 / 2 |
| 15788163 (SCA2, C) | 8 FINALIZADA · 2 FINALIZADA NEGATIVA · 4 FINALIZADA (Mecanización pendiente de reintento, Error #111) | 2 / 06/06/2027 / 1 |
| 15788162 (SCA, C) | 8 FINALIZADA · 2 FINALIZADA NEGATIVA · 4 FINALIZADA (cerrada por error de decisión) | 1 / 03/12/2026 / 1 |

Record SCA2 (`SCA2_cargarSolicitud`): 15788155 `EN_ACCION / CONTRA_ANULAR / CONTRA ANULAR NIVEL 2 / nivel 2 / catalogacion 1`; 15788163 `ERROR / VERTI / MECANIZAR / PENDIENTE / catalogacion 1`. Bandeja `SCA2 Error`: sólo #111 (15788163).

## 7. Veredicto

- **Columna A (NSE Autos recién emitidas / renovadas)**: alta, catalogación propuesta, decisión del motor (CONTRAANULAR → Verti → MECANIZAR) y recorrido hasta ANULAR PÓLIZA **equivalentes**. Difieren el **paso RGPD** (sólo SCA), el **estado CORE de la mecanización** (REALIZADA vs PENDIENTE DE AUTORIZAR) y la **catalogación final en CORE** (1 vs 2). La CA de nivel 2 posterior ocurre en ambas (no es divergencia).
- **Columna B (a futuro)**: ambas apps dejan entrar al formulario sin aviso. SCA2 fallaba al guardar (**corregido**); tras la corrección SCA2 bloquea con la validación de vencimiento y SCA crea la solicitud y anula. Requiere decisión funcional.
- **Columna C (Hogar renovadas)**: equivalentes hasta la CA negativa; ambas sufrieron el mismo fallo de CORE al crear la siguiente gestión (SCA2 reintentable, SCA cierra la solicitud).

## 8. Limitaciones y pendientes

- No se completó la mecanización de la columna C (fallo CORE `CORE_ALTA_GESTION` compartido); reintento automático SCA2 pendiente.
- D2 y D4 requieren ver la respuesta de CORE/Emisión en tiempo real (logs) o la decisión del analista; no se han corregido para no «esconder» una diferencia sin entender la causa.
- RGPD en SCA se certificó **sólo en TEST** para completar el flujo.
- La página «Errores» de SCA2 no es visible para JJGONZ2 (grupo de administración); la bandeja se leyó por LCP.
- No hubo campo Teléfono editable en las altas (Medio deshabilitado) en ninguna de las dos apps.

## 9. Grabaciones y capturas (no en el repo)

- `r23-nse-edited.mp4` — comparación completa A/B/C (SCA y SCA2).
- `r23-b-sca2-v37-edited.mp4` — reintento de B en SCA2 tras la corrección (v37).
- Capturas: `A-SCA2-catalogacion.png`, `A-SCA-catalogacion.png`, `A-SCA2-detalle-final.png`, `A-SCA-RGPD-despues.png`, `B-SCA2-guardar-error.png`, `B-v37-SCA2-guardar-validacion.png`, `B-SCA-id-contra.png`, `B-v37-SCA2-popup.png`, `B-SCA-popup-recomprobado.png`, `C-SCA2-detalle-final.png`, `C-SCA-detalle-final.png`, `C-SCA-error-decision.png`, `C-SCA2-buscador-final.png`, `C-SCA-buscador-final-ambas.png`.

---

## 10. Contexto para el analista (ronda 24)

Reanudación de R23-B con las respuestas del analista a las dudas #5, #6, #7 y #8. Solo se ha modificado **un objeto de SCA2** (bloque A). No se ha tocado SCA, SCAC, CORE, ANL, GAIA, PRE ni Documentum. Solicitudes nuevas de esta ronda: **SCA2 15788200** (pól. 2002600060946) y **SCA 15788203** (pól. 2002600073743).

### 10.A Pólizas emitidas a futuro (#8, decidido: reconsulta +1 año)

**Cómo lo hace SCA.** La detección de «emitida a futuro» está en la propia interfaz de alta (`SCA_AltaSolicitudAnulacion`, y también en `SCA_AltaSolicitudAnulacionPopUp`, `…Estrategicas`, `SCA_CalcularListaParCargaSGCOnline` y `SCA_DecisoraMain`): si la respuesta de `SCA_pObtenerPolizaFecha` no trae `poconpolizat`, repite la consulta con `pfechaconsulta: todate(a!addDateTime(today(), 1))` (**+1 día**, no +1 año). Por eso SCA, con pólizas cuyo efecto está a semanas vista, sigue sin obtener producto/efecto/vencimiento (formulario vacío en 15788158 y 15788203) y propone fecha sobre `hoy + 1 año`.

**Qué se ha implementado en SCA2.** En lugar de duplicar la lógica en cada punto de llamada, la reconsulta se ha centralizado en la regla de consulta, de modo que `SCA2_AltaSolicitudPage` v37 (que ya llama a la regla en el popup, la cabecera y el reintento +1 día) recibe los datos completos sin cambios: **se ha releído el objeto vivo y sigue en v37 con los fixes R23-B (null-safe en GUARDAR); no se ha editado**.

| Objeto | uuid | Versión | Cambio |
|---|---|---|---|
| `SCA2_pObtenerPolizaFecha` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052562` | 1 → **2** | Tras la primera llamada a Emisión (`IConsultarPoliza_1_3_0`), si la respuesta trae `pognrmensajeerrort` y no trae `poconpolizat`, y la fecha de consulta original es nula o ≤ hoy+1, repite **una sola vez** la misma consulta con `pfechaconsulta = todate(edate(today(), 12))` (+1 año). Si la segunda devuelve póliza, se devuelve esa respuesta; si no, se conserva la respuesta/error original. |

Procedimiento: GET vivo → backup (`SCA2_pObtenerPolizaFecha.before-<ts>.json/.sail`) → edición mínima → PUT del objeto completo → re-GET (`versionId: 2`) → `POST /expression-rules/{uuid}/test` → prueba UI. Fragmento añadido (resumen):

```appian
local!sinPolizaConError: and(
  a!isNotNullOrEmpty(local!respuesta),
  a!isNullOrEmpty(index(index(local!respuesta, "MSSPObtenerPolizaFecha", null), "poconpolizat", null)),
  a!isNotNullOrEmpty(index(index(local!respuesta, "MSSPObtenerPolizaFecha", null), "pognrmensajeerrort", null))
),
local!reintentarFuturo: and(
  local!sinPolizaConError,
  or(a!isNullOrEmpty(local!fechaConsultaOriginal), todate(local!fechaConsultaOriginal) <= today() + 1)
),
if(
  local!reintentarFuturo,
  /* segunda llamada con pfechaconsulta = todate(edate(today(), 12)); si trae poconpolizat se devuelve, si no local!respuesta */
  ...,
  local!respuesta
)
```

**Pruebas de la regla (LCP, `POST …/test`)** con pólizas de la columna B del ODS:

| Póliza | 1.ª consulta (hoy) | 2.ª consulta (hoy+1 año) → producto / efecto / vencimiento |
|---|---|---|
| 2002600060946 | sin póliza, `CODIGO INEXISTENTE [f_fila_a_fecha]` | TERCEROS AMPLIADO / 15/11/2026 / 15/11/2027 |
| 0732600004516 | sin póliza | HOGAR PLATINO / 12/11/2026 / 12/11/2027 |
| 2002600073743 | sin póliza | EQUILIBRIO TERCEROS / 10/11/2026 / 10/11/2027 |
| 0732600005004 | sin póliza | HOGAR FAMILIAR / 17/11/2026 / 17/11/2027 |
| 2002600060945 | sin póliza | BASICar TERCEROS AMPLIADO / 30/11/2026 / 30/11/2027 |
| 2002600059907 | sin póliza | EQUILIBRIO AMPLIADO / 30/12/2026 / 30/12/2027 |
| 9999999999999 (control) | sin póliza | sin póliza → se conserva el error original |

Todas las pólizas a futuro del ODS probadas se recuperan con +1 año; **no ha quedado ningún caso en que Emisión siga sin devolverla**.

**Prueba UI (grabación `r24-b-futuro-edited.mp4`)**, usuario JJGONZ2, motivo DECISION DE CLIENTE / ASEGURADO NO DESEA SEGURO / COMPROMISOS / PRESENCIAL:

| Paso | SCA2 — pól. 2002600060946 → **15788200** | SCA — pól. 2002600073743 → **15788203** | ¿Igual? |
|---|---|---|---|
| Popup | Entra al formulario sin aviso | Entra al formulario sin aviso | Sí |
| Cabecera | **TERCEROS AMPLIADO, efecto 15/11/2026, vencimiento 15/11/2027** (datos de la 2.ª consulta) | Producto/efecto/vencimiento **vacíos** | No (SCA2 ahora mejor; decisión #8) |
| Catalogación propuesta | A VENCIMIENTO, fecha 15/11/2027 (la fija el servicio de catalogación) | A VENCIMIENTO, fecha 11/11/2027 | Equivalente |
| GUARDAR | «Solicitud guardada correctamente», sin la validación «fecha superior al vencimiento» | «Se ha producido el siguiente error en el servicio de decisión:» (sin detalle); la solicitud se crea igualmente | Ver abajo |
| Detalle | PENDIENTE, nivel 1, catalogación A VENCIMIENTO; «Alta Solicitud: Finalizada»; **sin acción siguiente** tras 5 min | PENDIENTE, nivel 1, catalogación **A EFECTO** (SCA la cambia al guardar); sin acción siguiente | Parcial |
| CORE (`SCA2_consultaGestion`) | 43706289 acción 8 FINALIZADA | 43706296 acción 8 FINALIZADA | Sí |
| Buscador | Visible en SCA2 y en SCA | Visible en ambas | Sí |

**Por qué ninguna de las dos pasa de la alta — caso exacto para el analista.** Bandeja `SCA2 Error`: **#116, #117, #118** (solicitud 15788200, PM `SCA2 CMD Decidir`, nodo «Consultar reglas», tipo `DECISION_ERROR`, respuesta del servicio `{accion:"ERROR", grupo:"ERROR", subgrupo:"ERROR", error:""}`, 3 intentos entre 12:14:02 y 12:14:13 → BLOQUEADO). En SCA el mismo servicio de decisión devuelve el error que se muestra al guardar («…error en el servicio de decisión:» con texto vacío). Es decir, **el servicio de decisión/reglas falla con pólizas NSE emitidas a futuro en las dos aplicaciones** (también ocurrió en SCA con 0732600004759 → 15788158 en R23-B, aunque allí SCA continuó por Contra Anulación). No es una divergencia de SCA2; para reproducirlo: `SCA2_consultarDecision`/nodo «Consultar reglas» con `numPoliza=2002600060946`, origen NSE-Autos, catalogación 2, nivel 1, fecha propuesta 15/11/2027. Queda documentado en lugar de corregido (el servicio es externo). La continuidad Contra Anulación → Verti → Mecanización → ANULAR PÓLIZA con póliza a futuro **no se ha podido comparar** por este motivo.

Diferencia menor observada: SCA cambia la catalogación mostrada en Detalle de A VENCIMIENTO a A EFECTO al guardar; SCA2 conserva A VENCIMIENTO. Dado que el analista ha decidido que la catalogación la determine el servicio, SCA2 se deja como está.

### 10.5 (#5) Qué llamada de CORE fija «ANULACIÓN REALIZADA» (SCA 15788154) vs «ANULACIÓN PENDIENTE DE AUTORIZAR» (SCA2 15788155)

- **SCA**: el estado lo fija la llamada CORE **`actualizarMecanizacion`** (`mSEActualizarMecanizacionDTO`) en el PM `SCA_Finalizar_Mecanización`, nodos 5/31, con `codEstMecanizacion = if(pv!cancel, "4", local!polizaVigente = "A", "1", "4")` y `codEstPoliza = if(local!polizaVigente = "A", "A", "V")`, más `numSituacion` (suplemento) y `centroEmisor`. Con `codEstMecanizacion = "1"` / `codEstPoliza = "A"` CORE muestra «ANULACIÓN REALIZADA» (gestión 43706159). SCA llama a esta actualización **inmediatamente** después de ANULAR PÓLIZA, sin esperar a que ANL/Emisión confirmen.
- **SCA2**: el estado «PENDIENTE DE AUTORIZAR» lo deja la llamada CORE **`crearAutorizacion`** del PM `SCA2 CMD Mecanizar` (nodo 10), seguida de `guardarMecanizacion` (nodo 8). La llamada equivalente a `actualizarMecanizacion` existe más adelante en el mismo PM (nodo 308 prepara `sol/polizaVigente/numSituacion/centroEmisor` → nodo 309 `rule!SCA2_construirConsultaActualizarMecanizacion` → nodo 305 integración «Actualizar Mecanización» sobre `cons!SCAC_TXT_CORE7_ENDPOINT` → nodo 310 ¿OK?), pero **solo se ejecuta tras el sondeo ANL** (nodos 302/303/304, cada 5 min, hasta que `ANL Anulacion` esté desbloqueada/concluida o sea wAutemis aceptada, nodo 324). La instancia de 15788155 («SCA2 CMD Mecanizar - 20/10/2026 19:54») seguía **ACTIVE** en la espera ANL, por lo que CORE conserva el estado de `crearAutorizacion`. Es una diferencia de diseño (SCA2 espera confirmación de ANL antes de marcar la mecanización), no un parámetro distinto.
- Pendiente de confirmar: la regla `SCA2_construirConsultaActualizarMecanizacion` referenciada por el nodo 309 **no aparece** en el listado de reglas de las aplicaciones SCA2, SCA, SCA CORE, Anulaciones ni EDA por LCP. Si realmente no existe, el nodo 305 fallará cuando ANL concluya y SCA2 nunca pasará a «ANULACIÓN REALIZADA». No se ha creado (decisión funcional / posible objeto fuera de aplicación); conviene revisarlo con el analista.

### 10.6 (#6) Por qué SCA2 escribe catalogación 2 en CORE cuando calcula 1

Flujo en ambas apps: el servicio REST de catalogación (`SCA_/SCA2_consultarCatalogacionRest`) devuelve `codCatalogacionDefecto` (2 en los casos A) y la lista de opciones; el usuario elige; al guardar se envía `codCatalogacion: local!tipoCatalogacion` a CORE. En el alta, **las dos aplicaciones envían 2** (lo elegido/propuesto). La «validación posterior» para NSE renovadas es `SCA_/SCA2_determinarCatalogacionRenovada` (si `polizaRenovada` y catalogación 2/3 y origen NSE-Hogar/NSE-Autos → 1), idéntica en ambas, y es la que hace que el record interno calcule 1.

La diferencia está en **Contra Anulación** (donde se vuelve a escribir la catalogación en CORE con `modificarCatalogacionCodCiaCntrAnul`):

- SCA: `SCA_Alta_Solicitud_Anulacion` nodo 8 guarda `antiguaCatalogacion := pv!solicitudAnulacion.datosCompletosSolicitud.datosSolicitud.catalogacion` (valor ya normalizado por la validación de renovada), lo pasa al nodo 13 CONTRA ANULAR → `SCA_ContraAnulacionPrincipal(ri!antiguaCatalogacion)` → `SCA_ContraAnulacionOpciones`: `tipoCatalogacion: if(rule!SCA_polizaRenovada(poliza: ri!numPoliza) = true, ri!antiguaCatalogacion, local!tipoCatalogacion)` → CORE recibe **1**.
- SCA2: `SCA2_ContraAnulacionOpciones` reproduce la rama, pero sin el parámetro: `tipoCatalogacion: if(rule!SCA2_polizaRenovada(poliza: local!numPoliza) = true, index(local!datos, "catalogacion", local!catalogacion), local!catalogacion)`, donde `local!catalogacion: index(local!datos, "catalogacion", null)` y `local!datos` es la solicitud **leída de CORE** (catalogación 2). Las dos ramas del `if` devuelven el mismo valor, así que la validación de renovada **no tiene efecto** y CORE se queda con 2 aunque el record `SCA2 Solicitud` calcule 1.

Es, por tanto, una validación posterior mal aplicada en SCA2 (paso: Contra Anulación → `SCA2_ContraAnulacionOpciones`, parámetro `tipoCatalogacion` de la llamada a `modificarCatalogacionCodCiaCntrAnul`). Corrección prevista (no aplicada, a la espera de confirmación): usar en la rama renovada la catalogación calculada (`rule!SCA2_determinarCatalogacionRenovada(numPoliza, catalogacion, origenPoliza)` o el valor del record SCA2) en lugar de `index(local!datos, "catalogacion", …)`.

### 10.7 (#7) Paso RGPD en SCA

Aparece **después de FINALIZAR la Contra Anulación negativa y antes de la consulta Verti previa**, como modal del flujo de SCA (captura `A-SCA-RGPD-despues.png`, también `A-SCA-RGPD-impresion.png`, `A-SCA-RGPD-certificacion-pendiente.png`, `B-SCA-RGPD.png`, `B-SCA-RGPD-certificacion.png`):

- Título: **«Protección de datos RGPD»**. Texto: «Este cliente no ha firmado la cláusula de protección de datos RGPD. Por favor, selecciona un método de firma para continuar». Opciones: **Firma biométrica / Aceptación por email / Aceptación por SMS**; enlace «Aunque preferimos una Oficina sin papel, puedes solicitar Impresión y firma RGPD AQUÍ»; botón CONTINUAR.
- Con «Impresión y firma» pasa a una segunda pantalla: **«¿Certificas que el gestor ha firmado la cláusula RGPD?»** con botones CANCELAR / **RGPD FIRMADA**. Lo que certifica el usuario de oficina es que el cliente ha firmado la cláusula de protección de datos; tras RGPD FIRMADA el flujo sigue a «Solicitud de consulta Verti (Asegurable/No Asegurable)» (Observaciones Verti → CONTINUAR).
- Los textos «RGPD», «cláusula», «certificas» **no están en ninguno de los 738 objetos de la aplicación SCA** volcados por LCP (solo `SCA_GenerarContactoVerti` tiene el texto de la oferta Verti): el modal procede de un componente/aplicación de firma compartida que SCA invoca cuando el cliente no tiene la cláusula firmada (depende del dato del cliente, por eso apareció con 2002400468198 y 0732600004759). SCA2 no muestra ningún paso RGPD en el mismo punto (pasa de la CA negativa directamente a `VERTI-PRE`).

### 10.8 Pendientes tras la ronda 24

1. Servicio de decisión con pólizas NSE a futuro: devuelve ERROR en SCA y SCA2 (errores SCA2 #116-#118, solicitud 15788200; SCA 15788203). Requiere revisión del servicio; hasta entonces no se puede comparar CA/Verti/Mecanización con pólizas a futuro.
2. #6: confirmar que en Contra Anulación de póliza renovada SCA2 debe enviar a CORE la catalogación normalizada (1); corrección pequeña en `SCA2_ContraAnulacionOpciones`.
3. #5: confirmar existencia de `SCA2_construirConsultaActualizarMecanizacion`; si no existe, decidir cómo debe construir SCA2 la llamada `actualizarMecanizacion`.
4. #7: decidir si SCA2 debe integrar el paso RGPD (componente externo) antes de Verti previa.

### 10.9 Grabaciones y capturas de la ronda 24 (no en el repo)

- `r24-b-futuro-edited.mp4` — alta SCA2 (2002600060946 → 15788200) y SCA (2002600073743 → 15788203).
- Capturas: `B2-SCA2-popup.png`, `B2-SCA-popup.png`, `B2-SCA2-cabecera.png`, `B2-SCA-cabecera.png`, `B2-SCA2-catalogacion.png`, `B2-SCA-catalogacion.png`, `B2-SCA2-guardar-exito.png`, `B2-SCA-guardar-error-decision.png`, `B2-SCA2-detalle-final.png`, `B2-SCA-detalle-final.png`, `B2-SCA-buscador-ambas.png`, `B2-SCA2-buscador-final.png`.
