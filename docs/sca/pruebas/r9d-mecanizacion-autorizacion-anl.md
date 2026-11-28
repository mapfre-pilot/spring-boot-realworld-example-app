# R9-D — Mecanización y autorización (C1, C2, C3, C4, D2, G1/G2, Decisión 4)

Sesión hija R9-D de la ronda 9 (respuestas del analista, `24-respuestas-analista-ronda9.md`; plan `25-plan-ronda9.md`). Entorno Appian TEST, SCA (referencia) frente a SCA2. Sólo se han modificado objetos de SCA2 (reservas y liberaciones en `coordinacion-ronda9.md`). Backups SAIL antes/después en local (`~/sca2work/edits/`), no en el repo.

## 1. Resumen

| Ref (doc 25) | Qué dijo el analista | Qué hacía SCA2 | Qué hace ahora | Cómo se probó | Veredicto |
|---|---|---|---|---|---|
| C1 patrón NSE | «00000005/00000006 son wAutemis. Para NSE existen otros procedimientos en código de SCA, haz lo mismo» | Calculaba el código NSE (control técnico 3 → `00000005`) y pintaba los hitos NSE en la tarjeta, pero al pulsar ANULAR PÓLIZA lanzaba la anulación sin el aviso que SCA muestra para NSE pendiente de autorizar | Igual que SCA: con `00000005` el botón no envía, muestra el aviso «El proceso de anulación de la póliza se ha puesto en marcha, a través de la gestión de la petición de autorización. Hemos trasladado por SGO/NSE su petición…» (2 variantes según reserva de primas) y la anulación se lanza al ACEPTAR. Proceso y batch: ver §2.1 (SCA2 ya coincidía con el proceso online de SCA; el batch NSE de SCA no tiene equivalente en SCA2 → pregunta) | Paridad SAIL (LCP) + `testInterface` con 15787759 (NSE-Autos) sin errores. No hay pólizas NSE en TEST que devuelvan control técnico 3 → no probado en UI | Corregido (UI); pendiente de decisión el batch NSE |
| C2 botones Autorización | «Es un servicio externo el que cambia el estado. No es necesario botones» | Tarjeta Autorización: RETOMAR + REASIGNAR (como SCA); pantalla «Revisión autorización»: FINALIZAR, CANCELAR, POSPONER (como SCA) | Sin cambios: SCA2 no tiene ningún botón que SCA no tenga (no existen ACEPTAR/RECHAZAR) | Comparación SAIL `SCA_DetalleAnulacionAutorizacion`/`SCA_AnulacionFueraNormaPrincipal` vs `SCA2_DetalleSolicitud`/`SCA2_AnulacionFueraNormaPrincipal` + capturas UI (§4) | OK (paridad) |
| Decisión 4 cancelar autorización | «Lo tenemos que probar» | CANCELAR lanzaba el comando asíncrono y mostraba «CORRECTO» aunque CORE fallase (el 4007 acababa en la bandeja de errores). Además SCA2 no grababa la cancelación en CORE (`guardarAutorizacion` codEstado 5) antes de finalizar | CANCELAR graba `guardarAutorizacion` codEstado 5 de forma síncrona (como el nodo «Actualizar Autorización» de `SCA Autorización`); si CORE falla se muestra popup **ERROR** con el texto de CORE y la tarea no se completa; si va bien, se completa la acción | `testInterface`; UI con póliza RCI nueva en SCA y SCA2 (§4) | Corregido en SCA2; CORE 4007 → fallo de CORE (ver §2.3) |
| C4 bloqueo por Emisión | «No se puede hacer nada mientras está bloqueada» | Con `procesoActivo = ANL` (Mecanización enviada) la tarjeta oculta RETOMAR/REASIGNAR y la pestaña de tareas oculta «Completar» | Sin cambios | UI sobre 15787759 en SCA2 y SCA (§4) | OK |
| C3 / G1 / G2 caducidad y ANL | «Lo resolvemos haciendo más pruebas» / «ANL: necesitamos contexto» / «¿qué se hace en SCA?» | Espera 24 h (288 × 5 min) la respuesta de ANL y registra `ANL_TIMEOUT` (error relanzable) | Sin cambios (la diferencia depende de ANL). Descripción funcional del flujo SCA y párrafo para el analista en §3 | Lectura de `SCA Mecanizacion` + subprocesos y de `SCA2 CMD Mecanizar`; estado de 15787759 en §3.3 | Documentado |
| D2 documento en Documentum sin gestión CORE | «Puede pasar que esté en Documentum pero no en CORE. Hay que probarlo para poder decidir» | — | Sin cambios | Escenario provocado por `testRule` sobre 15787906 (§2.4): SCA2 no detecta el huérfano y al relanzar sube un segundo documento a Documentum; CORE queda con uno | Documentado + pregunta |

## 2. Detalle por punto

### 2.1 C1 — Patrón NSE

**Qué hace SCA (código leído por LCP):**
- Pantalla `SCA_ContraAnulacionDetalleAnulacionPoliza` (mecanización): para NSE el código de observaciones sale de los controles técnicos de la simulación: control técnico `3` → `00000005` (pendiente de suscripción/autorización); `1`/`4` → `00000001`. Para wAutemis sale de `nvlCumplimiento`. Si `00000005`, el botón ANULAR PÓLIZA no envía y muestra el modal informativo «El proceso de anulación de la póliza se ha puesto en marcha, a través de la gestión de la petición de autorización. Hemos trasladado por SGO/NSE su petición. Consulte su respuesta en el operacional» (si hay reserva de primas añade «: La cuantía final de la reserva de primas se calculará tras la revisión de los recibos cobrados»); la anulación se lanza al aceptar.
- Proceso `SCA Mecanizacion` → subproceso `SCA_PB_buclesActualizarMecanizacion` (nodo «mcaMecanizada & Pendiente & Autoriz»): la **autorización online (gestión 7) sólo se crea para wAutemis** con `00000005/00000006`; para NSE sólo se marca `pendiente = true` (variable que no se usa después). Es decir, en el proceso online SCA2 (`SCA2 CMD Mecanizar`, nodos «Success Mecanización?» y «¿wAutemis pdte. aceptar?») ya coincidía con SCA.
- Tarjeta `SCA_DetalleAnulacionMecanizacion`: hitos wAutemis `Mecaniza/SGO/STCAT/Anulación` si las observaciones de la gestión 5 contienen `observaciones: 00000005/6`; hitos NSE `Mecaniza/Suscripción/Anulación` si contienen `txtObservaciones: 00000005/6`; el hito Suscripción se da por hecho con la observación «RESPUESTA SUSCRIPCION NSE:». `SCA2_DetalleSolicitud` ya tenía esta misma lógica (rondas anteriores).
- **Batch `SCA Batch Mecanizacion NSE`** (sin equivalente en SCA2): recorre en CORE las solicitudes en estado 4 y 5 con mecanización en estado 2 que no son wAutemis; si la póliza sigue vigente actualiza la mecanización (estado 4) y crea/guarda una autorización **rechazada** (codEstado 3); si la póliza ya está anulada actualiza la mecanización (estado 1), crea/guarda una autorización **aceptada** (codEstado 2, fecha de hoy), finaliza la instancia ANL, finaliza la solicitud en CORE e inserta las observaciones de post-anulación NSE. En TEST, al compartir CORE, este batch de SCA actúa también sobre las solicitudes NSE de SCA2 (explica la gestión 7 de 15787759, §3.3).

**Cambio en SCA2:** `SCA2_MecanizacionPrincipal` v14 → v15 (uuid `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481`): nuevo `local!mensajeControlTecnico`; `submit: false` también con `observaciones = "00000005"`; en el `saveInto` se informa el mensaje (dos textos literales de SCA según `mcaReservaPrima`) y se abre el modal; el modal muestra `mensajeControlTecnico` si existe (si no, el de recibos) y su ACEPTAR lanza `SCA2 CMD Mecanizar` como ya hacía para la reserva de primas. Relectura idéntica al payload; `testInterface` con 15787759 sin errores (botones ANULAR PÓLIZA / CANCELAR).

**Pregunta para el analista (negocio):** cuando una póliza NSE queda pendiente de suscripción (control técnico 3), en SCA es un proceso nocturno (`SCA Batch Mecanizacion NSE`) el que, consultando CORE, cierra la mecanización y crea la autorización aceptada o rechazada según la póliza quede anulada o vigente. ¿SCA2 debe tener su propio batch equivalente (necesario si SCA se apaga) o se mantiene el de SCA mientras convivan? No se ha implementado en SCA2 porque es una pieza nueva (proceso programado sobre CORE) y conviven en el mismo CORE.

### 2.2 C2 — Botones de la Autorización

| Pantalla | SCA | SCA2 |
|---|---|---|
| Tarjeta «Autorización» del Detalle | RETOMAR (si la tarea es del usuario) o REASIGNAR; sólo en la fase activa | Igual (`SCA2_DetalleSolicitud`, bloque común de botones, oculto si CORE la da por finalizada) |
| «Revisión autorización» | FINALIZAR, CANCELAR, POSPONER (un botón «Adjuntar Documentacion» está comentado en el código) | FINALIZAR, CANCELAR, POSPONER |

No hay botones ACEPTAR/RECHAZAR en ninguna de las dos aplicaciones; el estado de la autorización lo cambian el servicio externo / el batch (§2.1). No se elimina nada.

### 2.3 Decisión 4 — Cancelar una autorización

- **SCA:** CANCELAR envía el formulario; el proceso `SCA Autorización` llama a `guardarAutorizacion` con `codEstado 5` (hasta 3 intentos) y después muestra siempre el popup «CORRECTO — Los datos se han guardado correctamente» (nodo «Copy of PopUpMensajeAutorizacion», texto fijo), incluso si los 3 intentos fallan. Es decir, SCA tampoco enseña el error de CORE al usuario; sólo POSPONER muestra CORRECTO/ERROR según el resultado.
- **SCA2 antes:** CANCELAR lanzaba `SCA2 CMD CompletarAccion` y mostraba CORRECTO; el comando no grababa la cancelación en CORE (sólo finalizaba la solicitud).
- **SCA2 ahora:** `SCA2_AnulacionFueraNormaPrincipal` v22 → v23 (uuid `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423`). CANCELAR llama a `rule!SCA2_guardarAutorizacion` (codEstado 5, mcaAutorizada N, fecha de anulación de la pantalla, codGestion/tipoAutorizacion de CORE) de forma síncrona. Si la respuesta es correcta (sin `faultcode`/`faultstring`), lanza `SCA2 CMD CompletarAccion` (con `autorizacionGuardada: true`) y sigue el flujo normal; si no, muestra el popup `SCA2_PopUpMensajeAutorizacion` con título **ERROR** y el texto «No se ha podido cancelar la autorización en CORE (guardarAutorizacion): <msg de CORE> (texto provisional, pendiente del analista)», y la tarea queda abierta para reintentar. Relectura idéntica; `testInterface` sin errores.
- **Resultado en TEST** (§4, escenario A): con la póliza RCI 0005726689605 (solicitud **15787909**, alta directa causa 28 «Anulación fuera de norma») CORE **aceptó** la cancelación (`guardarAutorizacion` codEstado 5 → autorización codEstado 5, gestión 7 «FINALIZADA CANCELADA» 18:53:42): el popup mostró «CORRECTO» y la tarjeta quedó «Autorización: Cancelada» — es el resultado real, no un CORRECTO ciego. No se ha podido reproducir el 4007 de la ronda 8 (CORE ya no falla con esta póliza), así que la rama ERROR queda validada sólo por código. Hallazgo adicional: tras cancelar, `SCA2 CMD CompletarAccion` volvía a llamar a `guardarAutorizacion` (nodo «Actualizar Autorizacion») sobre una autorización ya cancelada y la solicitud 15787909 se quedó en `PDTE_FINALIZAR` (buscador «Pendiente», CORE codEstSolic 2, sin error en la bandeja); se ha corregido el nodo para que no repita la llamada cuando la pantalla ya la grabó (`autorizacionGuardada`) — aplica a solicitudes nuevas; 15787909 sigue pendiente de finalizar (ver §7). En SCA el alta con RCI 0005726694905 (15787914) tardó >5 min y la tarjeta Autorización no llegó a aparecer durante la prueba (sólo gestión 8 en CORE): «SCA no comparable por latencia».

### 2.4 D2 — Documento en Documentum sin gestión/registro en CORE

Escenario provocado con `testRule` sobre la solicitud propia **15787906** (RCI 0005726697510, creada en SCA2 por el agente de pruebas):
1. `SCA2_altaDocumento(file 556799, tipo 7 DNI, acción 2)` → sube a Documentum `r_object_id 89bb01a1362ab5d4` (`D_IDPE_0001_15787906_13102026`) **sin** registrar en CORE; `SCA2_consultarDocumentos(15787906)` sigue vacío (simula el fallo tras Documentum).
2. Relanzamiento equivalente: `SCA2_subirDocumentosGD(15787906, {"556799_7"}, CA)` → vuelve a subir a Documentum (`c25d11a1362aca9b`) y registra en CORE (`MSSInsertarDocumentoDni = true`).
3. `SCA2_consultarDocumentos(15787906)` → 1 documento (`0900ab4481a0a180`, tipo 7).

Conclusión: como SCA2 sólo mira CORE (D1, decisión del analista), **no detecta el documento huérfano de Documentum y al relanzar lo duplica en Documentum**; CORE queda coherente con un único documento. Para la impresión (gestión 4) pasa lo mismo a nivel de CORE: `SCA2 CMD CompletarAccion` → «Guardar impresion CA» repite `guardarImpr` si falta la gestión 4 **o** falta el documento en CORE; CORE genera la carta y la gestión de nuevo.

**Pregunta para el analista:** ¿es aceptable que quede un documento duplicado en Documentum (invisible para SCA/SCA2 y CORE) o SCA2 debe guardar en su base de datos la referencia devuelta por Documentum en el momento de subirlo para reutilizarla al relanzar (sin consultar Documentum)? Si se prefiere lo segundo, se implementaría en `SCA2_subirDocumentosGD` + bandeja de errores.

## 3. C3 / G1 / G2 — Caducidad y espera a ANL (párrafo para el analista)

### 3.1 Qué hace SCA (proceso `SCA Mecanizacion` y subprocesos)
1. El gestor pulsa ANULAR PÓLIZA. SCA graba la mecanización en CORE (`guardarMecanizacion`, gestión 5) y, para **wAutemis** con respuesta `00000005/00000006` (pendiente de aceptar en Emisión), crea la **autorización** en CORE (gestión 7, hasta 3 intentos) e inserta en ANL las observaciones «Bloqueo NEW Entrada/Realizado».
2. Da de alta la anulación en **ANL** (subproceso «ANL Alta», aplicación ANL del mismo Appian) para que ANL/Emisión la ejecute.
3. **Empieza la espera**: el proceso se queda parado en el evento «Pausar hasta ANL_Desbloquear». **No hay temporizador**: espera indefinidamente a que ANL, cuando Emisión desbloquea la póliza, arranque el proceso `SCA Desbloquear Proceso Principal` (localiza la instancia por `SCA_obtenerIdMecanizacionDesbloqueo`) que le envía el mensaje.
4. Cuando llega el mensaje, `SCA_PB_buclesActualizarMecanizacion` actualiza la mecanización en CORE: si `now() >= caducidadNivel` (la caducidad del nivel calculada al entrar en la tarea) la marca **caducada** («Mecanizacion Caducada», tipo 1); si el gestor canceló, tipo 3; si no, tipo 2 (normal) y la solicitud sigue (decisión / siguiente nivel / finalización).
5. Si ANL **no responde nunca**: la instancia de SCA se queda esperando (no caduca sola, no avisa a nadie, no hay correo ni tarea); en CORE la gestión 5 queda INCOMPLETA y la solicitud «Mecanización enviada»/pendiente; el gestor no puede retomar (C4). La caducidad sólo se aplica si ANL contesta después de la fecha de caducidad del nivel, o si el `SCA Batch Caducidad` (que trabaja sobre las tareas/solicitudes caducadas de Contra Anulación, Acciones Administrativas y Autorización) la alcanza por otra vía. Para NSE no hay espera: el cierre lo hace el `SCA Batch Mecanizacion NSE` (§2.1).

### 3.2 Qué hace SCA2 (`SCA2 CMD Mecanizar`)
Mismos pasos 1-2 (gestión 5, autorización sólo wAutemis pendiente, alta en ANL). La espera (sólo wAutemis pendiente) es activa: consulta el registro ANL cada **5 minutos hasta 288 veces (24 h)**; si ANL desbloquea, actualiza la mecanización (3 intentos), finaliza la gestión SGC y pasa al siguiente nivel/decisión; si en 24 h no hay respuesta registra el error **`ANL_TIMEOUT`** («ANL no ha desbloqueado la solicitud en 24 h») en la bandeja de errores (sólo administradores), relanzable, y la solicitud se queda en «Mecanización enviada» (procesoActivo ANL) sin que el gestor pueda actuar. Para NSE SCA2 no espera y continúa (como el proceso online de SCA).

### 3.3 Estado actual de 15787759 (SCA2)
`SCA2 Solicitud`: estado `MECANIZADA`, `procesoActivo = ANL`, `estadoTarea = PENDIENTE`, origen **NSE-Autos** (póliza 2002000094372), creada 01/10/2026 18:17, última modificación 01/10/2026 18:27, caducidad de tarea 02/10/2026. CORE (`SCA2_consultaGestion`): gestiones 8 (alta) FINALIZADA, 2 (contra anulación) FINALIZADA NEGATIVA, 4 (impresión) FINALIZADA, **5 (mecanización) INCOMPLETA** (43704994, 20:25:49) y **7 (autorización) FINALIZADA** (43704995, 20:27:45, creada 2 minutos después por el batch NSE de SCA o por la versión del comando de aquella ronda). No existe registro `ANL Anulacion` para ella (`SCA2_obtenerAnulacion` = null), así que ANL nunca la va a desbloquear. Sigue bloqueada (C4) y sólo puede salir por la bandeja de errores o cerrándola en CORE.

### 3.4 Párrafo para el analista (G1/G2)
En SCA la espera a ANL empieza justo después de lanzar la anulación de una póliza wAutemis que Emisión deja «pendiente de aceptar» (códigos 00000005/00000006): SCA crea la autorización en CORE y se queda esperando, sin límite de tiempo y sin avisar a nadie, a que ANL le comunique el desbloqueo; cuando llega, da la mecanización por hecha o por caducada según haya pasado o no la fecha de caducidad del nivel. En SCA2 esa misma espera dura 24 horas (consulta cada 5 minutos) y, si ANL no contesta, deja un error relanzable en la bandeja de administradores. Preguntas: (1) ¿se mantiene la espera sin límite de SCA o se fija un plazo (24 h u otro) tras el cual la solicitud se da por caducada o se avisa (correo/tarea) a oficina o backoffice? (2) Si se fija plazo, ¿quién puede cerrar la solicitud y con qué estado en CORE (caducada / cancelada)? (3) ¿Debe el gestor poder cancelar la mecanización mientras está bloqueada por Emisión o se mantiene «no se puede hacer nada»?

## 4. Pruebas UI (agente de pruebas, SCA vs SCA2)

Agente de pruebas con JJGONZ2; grabación `sca-r9-comparacion-edited.mp4`; capturas `ss_*.png` adjuntas al mensaje final.

| Esc. | SCA2 | SCA | Resultado |
|---|---|---|---|
| A/C Revisión autorización (botones) | 15787909: tarjeta Autorización con RETOMAR; pantalla con CANCELAR, POSPONER, FINALIZAR (ss_1e970524) | 15787914: la tarjeta Autorización no apareció en el tiempo de la prueba (ss_543a06ed) | OK en SCA2 (mismos botones que el código de SCA); SCA no comparable |
| A CANCELAR | Popup CORRECTO «Los datos se han guardado correctamente» (ss_24eebb03); tarjeta «Autorización: Cancelada» (ss_90b325f2); buscador «Pendiente» (ss_9314a49e) por el nodo del comando corregido después | No alcanzado | OK (CORE aceptó la cancelación); rama ERROR no reproducible |
| B Bloqueo por Emisión (15787759) | Buscador «Mecanización Enviada» (ss_d9506217); tarjeta «Mecanización Incompleta / MECANIZACIÓN INCOMPLETA» sin RETOMAR ni REASIGNAR (ss_379d2bc4) | Misma tarjeta sin RETOMAR/REASIGNAR (ss_af4a191f) | OK, igual en ambas |
| Mecanización wAutemis (opcional) | 0001047017093 → 15787919: Contra Anulación POSITIVO → «¡Enhorabuena en la retención…!» → Finalizada positivamente (ss_62bbbf9f, ss_f82ee743); no abre mecanización (la mecanización sale del resultado NEGATIVO con decisión «mecanizar») | No ejecutado | No probado (ruta equivocada del agente; la mecanización se validó en la ronda 8) |
| C1 aviso NSE | No hay pólizas NSE con control técnico 3 en TEST | — | No probado en UI (paridad SAIL + testInterface) |

## 5. Objetos modificados (SCA2)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_AnulacionFueraNormaPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | 22 → 23 | CANCELAR graba `guardarAutorizacion` codEstado 5 síncrono; popup ERROR/CORRECTO con el resultado real; sin comando si CORE falla |
| `SCA2_MecanizacionPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | 14 → 15 | Aviso NSE pendiente de autorizar (`00000005`) como SCA; la anulación se lanza al ACEPTAR del aviso |
| `SCA2 CMD CompletarAccion` (nodo «Actualizar Autorizacion», id 303) | `0000f06f-1307-8000-65b1-7f0000014e7a` | — (PM) | El customOutput `autRes` no repite `guardarAutorizacion` cuando `resultado.autorizacionGuardada = true` (la pantalla ya grabó la cancelación); resto del modelo idéntico (comparado tras la relectura) |

Reservados y liberados sin cambios: `SCA2 CMD Mecanizar`. Todas las reservas están liberadas en `coordinacion-ronda9.md`. No se han tocado `SCA2_DetalleSolicitud` ni `SCA2_DetalleTareas` (reservadas por R9-B/R9-E; C2 y C4 no requerían cambios).

## 6. Solicitudes creadas en esta sesión

| Póliza | Solicitud CORE | App | Estado al cierre |
|---|---|---|---|
| 0005726697510 (RCI) | 15787906 | SCA2 | Pendiente (contra anulación nivel 1 abierta; la ruta por CA se abandonó porque la pantalla mostraba el nuevo aviso de «acuerdos SI24» que estaba desplegando R9-C). Usada para la prueba D2 (documentos). |
| 0005726689605 (RCI) | 15787909 | SCA2 | Autorización cancelada en CORE; SCA2 `PDTE_FINALIZAR` (buscador «Pendiente») |
| 0005726694905 (RCI) | 15787914 | SCA | Pendiente (sólo gestión 8; autorización no creada durante la prueba) |
| 0001047017093 (wAutemis) | 15787919 | SCA2 | Finalizada positivamente (CA POSITIVO) |

Consultadas sin modificar: 15787759.

## 7. Pendientes / preguntas para el analista (lenguaje de negocio)

1. **Batch NSE** (C1): ¿SCA2 necesita su propio proceso nocturno que cierre las mecanizaciones NSE pendientes y cree la autorización aceptada/rechazada, o se mantiene el de SCA mientras convivan? (§2.1)
2. **Documento duplicado en Documentum** (D2): ¿se acepta el duplicado invisible o SCA2 debe guardar la referencia de Documentum para reutilizarla al relanzar? (§2.4)
3. **Espera a ANL** (C3/G1/G2): plazo, aviso y quién cierra (§3.4).
4. **Texto del error al cancelar la autorización** (Decisión 4): texto provisional «No se ha podido cancelar la autorización en CORE…»; falta el definitivo. Nota: SCA muestra «CORRECTO» aunque CORE falle; SCA2 ahora muestra el error real como se pidió.
5. **CORE 4007 al cancelar autorizaciones en TEST**: en esta ronda CORE **no** ha devuelto el 4007 al cancelar (15787909 cancelada correctamente). Si vuelve a aparecer, SCA2 lo mostrará ahora como ERROR al usuario; SCA seguiría mostrando CORRECTO. ¿Se quiere que SCA también lo muestre (cambio en SCA, fuera de alcance)?
6. **Solicitud 15787909** (SCA2): autorización cancelada en CORE pero la solicitud se quedó en `PDTE_FINALIZAR` por la doble llamada a `guardarAutorizacion` (corregida para nuevas). ¿Se finaliza a mano en CORE/SCA2 (como las del punto G4) o se deja como evidencia?

## 8. Limitaciones
- No existen en TEST pólizas NSE que devuelvan control técnico 3: el aviso NSE se valida por paridad de código y `testInterface`.
- ANL nunca desbloquea en TEST; no se puede provocar el fin de la espera ni la caducidad.
- El MCP `appian-dev-mcp-c90b` no arrancó en esta sesión (falta `USERNAME/PASSWORD` en su entorno); todo el trabajo se ha hecho por la API LCP (lectura, PUT, `test`).
- - SCA TEST: el alta RCI tardó >5 min y la autorización no se generó en el tiempo de la prueba; la comparación UI de CANCELAR en SCA no se pudo hacer (se compara con el código del proceso `SCA Autorización`).
- CORE no devolvió 4007 en esta ronda: la rama ERROR del nuevo CANCELAR se valida por código (`testInterface` sin errores), no en UI.
- Las pestañas de tareas/errores de SCA2 son sólo de administradores; el enlace «Completar» no se verificó con JJGONZ2 (el código lo oculta con `procesoActivo = ANL`).
