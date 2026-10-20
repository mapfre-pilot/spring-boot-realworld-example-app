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
