# Estado de SCA2 tras la ronda 23 — dudas funcionales, resumen de cambios, lógica por flujo y previsión (20/10/2026)

> Documento de síntesis para el analista y el responsable del proyecto. Es funcional, no técnico. El detalle de cada punto está en los documentos que se citan (`docs/sca/`, rama `feature/sca`).

## 1. Dudas funcionales que siguen abiertas

Ordenadas por impacto. Ninguna se ha resuelto por mi cuenta: SCA2 hace hoy lo que se indica en la columna «SCA2 hoy» y espera decisión.

| # | Tema | SCA hoy | SCA2 hoy | Qué necesito que decidáis | Dónde está el detalle |
|---|---|---|---|---|---|
| 1 | **Pantalla previa Verti / Vencimiento** | No la muestra en ningún punto (ni antes del nivel 2 ni antes de mecanizar) | La muestra tras cada Contra Anulación negativa (lo pidió el análisis de la ronda 22) | ¿Debe salir sólo cuando el siguiente paso es mecanizar, o también cuando hay salto de nivel? | r23-c Q1 (D4) |
| 2 | **Resultado tras ANULAR PÓLIZA** (wAutemis no pendiente de aceptar) | Queda «Mecanización Enviada» | Pasa a nivel 3 y queda «Solicitud Finalizada sin anular» con la gestión INCOMPLETA | ¿Cuál es el estado final correcto? | r23-c Q4 (D6) |
| 3 | **Espera a ANL** | Espera a que ANL concluya el ciclo completo (Central + NEW + SGO) | Reanuda la mecanización en cuanto ANL marca autorizado/rechazado, aunque el resto del ciclo falle; además la espera caduca a las 24 h con error | ¿SCA2 debe esperar a la conclusión? ¿Qué hacer si pasan las 24 h? | 41-ronda23 §4 |
| 4 | **Usuario de la gestión de mecanización en CORE** | Perfil del usuario que pulsa ANULAR PÓLIZA | En nivel 2 lleva el perfil del gestor de oficina (p. ej. CE_MF_BK) en vez del usuario SI24 | Confirmar que debe ir el usuario real (lo arreglaría igual que en el alta de gestión) | r23-c Q5 (D7) |
| 5 | **NSE: estado CORE de la mecanización** | «ANULACIÓN REALIZADA» | «ANULACIÓN PENDIENTE DE AUTORIZAR» | ¿Cuál es el correcto? | r23-b |
| 6 | **NSE: catalogación final en CORE** | 1 | 2 (ambas calculan 1 en su propio registro) | ¿1 ó 2? | r23-b |
| 7 | **NSE: paso RGPD** | Existe | No existe | ¿Debe tenerlo SCA2? | r23-b |
| 8 | **Pólizas emitidas a futuro** | Crea la solicitud y llega a pedir a Emisión anular una póliza que aún no conoce | Bloquea el guardado: «La fecha de anulación no puede ser superior a la de vencimiento» | ¿Bloquear (como SCA2) o permitir (como SCA)? | r23-b D7 |
| 9 | **Retorno al formulario tras el alta** | — | Si el motor tarda, el usuario ve el formulario con aviso y puede volver a pulsar | Propuesta: saltar al Detalle en cuanto CORE devuelve el número y que el Detalle abra la CA/AA sola. Pendiente de tu OK | 34-ronda13 §1 |
| 10 | **RETOMAR en Acciones Administrativas y en nivel 2** | Sólo el propietario (y en nivel 2 oculto a Oficina) | Cualquier usuario del grupo con la gestión abierta | ¿Quién puede retomar? | 40-ronda22 §1, r23-c Q2 |
| 11 | **Impresión de la carta de nivel 2** | Una impresión por solicitud; la segunda la ignora | Igual desde la ronda 23 (antes se paraba) | ¿Basta una impresión por solicitud o debe imprimirse carta distinta en nivel 2? | r23-c Q3 (D2) |
| 12 | **Nuuma al retomar** | — | Se registra en SCA2 y llega a CORE al posponer/finalizar (no hay servicio CORE de «retomar») | Confirmar que vale | 38-ronda20 |
| 13 | **Casilla de vencimiento (SGC a un año)** en la inducción | Sí | Sin implementar | ¿Entra en el alcance? | 36 §14 |
| 14 | **Batch NSE** | Propio | Sin equivalente (hay propuesta) | ¿Se necesita en SCA2? | 36 §14 |
| 15 | **Origen FDC / Decisora** | Entrada por URL con `origen` | Un solo site, sin Decisora | ¿Hay que mantener la entrada desde FDC? | 36 §14 |
| 16 | **Documentos de prueba afectados por el fallo de Documentum** | — | 5 solicitudes (15788028/45/98/99/106) con documento no subido al SGD | ¿Los re-subo o se dejan? | 39-ronda21 |
| 17 | **Solicitud 15788025 desincronizada** | — | CORE anulada, SCA2 «Incompleta» | ¿Finalizarla a mano o dejarla como caso de prueba? | 34-ronda13 |

### Actualización tras la ronda 24 (21/10)

Estado de las 17 dudas tras las respuestas del analista (`43-ronda24-respuestas-analista.md`, `45-ronda24-derivacion-verti.md`) y los informes de las sesiones hijas:

| # | Estado | Qué se hizo / qué falta |
|---|---|---|
| 1 | **Cerrada y aplicada** | Pantalla Verti sólo con switch ON + contacto VERTI/VENCIMIENTO + acción MECANIZAR, tras la CA, cabecera común y un único CONTINUAR (`CMD CrearAccion`, `SCA2_VertiVencimientoPrincipal` v13, `SCA2_GenerarContactoVerti` v2); inducción por contacto en `CMD Mecanizar`. Probado con 15788198/15788208 (r23-c §9). **Nueva Q6**: se ha tomado como switch el FLAG global `vertiSuscripcionInteligente` (= S en TEST); `SCA2_flagVerti` por nuuma da false para los usuarios de prueba. ¿Es ese el switch?  **R23-A §7.2 (21/10)**: la inducción por contacto ya está verificada en positivo con solicitud nueva 15788218 (`CMD Mecanizar` v31, nodo 16 «Cargar» usa `ac!sol`): `contacto=[VERTI, VENCIMIENTO]` → `CMP Inducir Cliente Completo` 12248074 con `tipoInduccion="I"`, mecanización sin cambios. **Nueva Q7**: para esa misma póliza aparecen otras 3 instancias CMP con `tipoInduccion="A"` (iniciador APP-SCAN, producto AU01) creadas durante la CA/pantalla Verti; ningún objeto de SCA2 las lanza (el único arranque de CMP en SCA2 es el nodo 330 de `CMD Mecanizar`; el nodo 36 de `CrearAccion` es inerte), así que vienen de fuera de SCA2. ¿Es esperado que el cliente reciba inducción A + I? En SCA (15788167) no hay ninguna instancia CMP. |
| 2 | **Abierta** | Sin respuesta del analista (D6). Ligada a la etiqueta CORE tras ANULAR: SCA «Mecanización Enviada» vs SCA2 «ANULACIÓN PENDIENTE DE AUTORIZAR». |
| 3 | **Cerrada y aplicada** | `CMD Mecanizar` v30 (hoy v31) reanuda sólo con `CONCLUIDA` (ciclo completo) y corta 24 h después de la respuesta. **Hallazgo**: ANL en PRE nunca marca `CONCLUIDA` para solicitudes SCA2 (autorizar: «Anular Poliza NEW» no termina; rechazar: termina sin «Cierre SGO y STCAT»), por lo que 15788199/15788205 acabarán en `ANL_TIMEOUT` (r23-a §7). **Nuevas preguntas**: ¿aceptable en PRE? ¿El rechazo se da por concluido con ESTADO=2 + evento «No Autorizado»? ¿Quién marca `CONCLUIDA`? |
| 4 | Cerrada sin cambio | CE_MF_BK es perfil SI24. |
| 5 | Abierta (contexto entregado) | SCA marca «ANULACIÓN REALIZADA» nada más ANULAR; SCA2 sólo tras concluir ANL (coherente con #3). Pendiente decisión. |
| 6 | **Pendiente de OK** | Corrección localizada en `SCA2_ContraAnulacionOpciones` (usar la catalogación normalizada como SCA en la rama renovada). No aplicada; se haría sobre la v57 actual. |
| 7 | Abierta | RGPD: componente de firma externo a SCA; ¿debe integrarlo SCA2? |
| 8 | **Cerrada y aplicada** | `SCA2_pObtenerPolizaFecha` v2 reconsulta Emisión a +1 año; las pólizas a futuro se recuperan. El servicio de decisión devuelve ERROR en ambas apps (externo). |
| 9 | Entregable pendiente de OK | Propuesta en `44-propuesta-retorno-alta-navegacion.md`. |
| 10 | Cerrada sin cambio | RETOMAR por cualquier usuario del grupo. |
| 11 | **Cerrada y aplicada** | Una carta por solicitud; fecha/usuario/grupo de impresión en el Detalle (`SCA2_DetalleSolicitud` v61). |
| 12 | **Cerrada y aplicada** | RETOMAR lanza a CORE la misma llamada que POSPONER con el nuuma que retoma (gestiones 43706297/43706319). |
| 13 | Cerrada (fuera de alcance) | Casilla SGC fuera de alcance; falta documentación de Suscripción Inteligente. |
| 14 | **Cerrada y aplicada** | Batch NSE propio (`SCA2 Batch Mecanizacion NSE`, `SCA2 CMD MecanizarNSE`), desactivado con `SCA2_BOOL_BATCH_NSE = false`. Activar sólo con autorización. |
| 15 | Abierta | Faltan ejemplos de llamadas de la Decisora/FDC. |
| 16 | **Cerrada y aplicada** | `SCA2_subirDocumentosGD` v11 valida la referencia, error accionable y reintento (15788209). Los 5 documentos históricos no se han re-subido. **Nuevas preguntas**: duplicado en el SGD al reintentar; quién descarta la fila `DOC_GD_FAIL` tras un reintento correcto. |
| 17 | **Cerrada y aplicada** | 15788025 registrada en la bandeja como `DESINCRONIZACION_CORE` (fila 120) sin tocarla; se resuelve desde ahí. |

Además, R23-A confirmó con pólizas nuevas el **bloqueo NEW** (tras corregir la fecha «A EFECTO» del alta y la `reservaPrima` del bloqueo) y las tres acciones de la página de mantenimiento (AUTORIZAR, RECHAZAR, CANCELAR). Queda en curso la corrección del contacto Verti en `CMD Mecanizar` (`pv!contacto` se calculaba antes de cargar la solicitud; rama positiva de la inducción sin verificar). Informes: `pruebas/r23-a-autemis-anl.md`, `pruebas/r23-b-nse.md` §10, `pruebas/r23-c-nivel2-verti.md` §9, `pruebas/r24-d-batch-sgd-errores.md`.


### Actualización tras la ronda 27 (22/10)

Tercer «Análisis SCA2» (doc 48): TTQ Autos/Hogar, contra positiva, motivo/detalle/causa e impresión validados por el analista. Aplicados: pestaña «Datos póliza» por defecto, texto SI24 definitivo, RETOMAR/REASIGNAR recolocados, orden de argumentos en nivel 2 (anteriores alfabético → separador → nuevos), orden Mecanizar → ANL → CMP; orquestación Mecanizar → contacto → CMP (con firma RGPD) → decidir acción verificada con paridad. Nuevas preguntas abiertas (detalle en doc 48 §Resultados): quitar REASIGNAR; texto definitivo en Anulación fuera de norma y aviso SI24 en CA nivel 1; separador/numeración de argumentos; lentitud de la decisión (38 s backend + sondeo); **D4 resuelta en la ronda 28** (`pruebas/r28-cmp-sincrono-encadenado.md`: `a!startProcessLink` + Sub-Process encadenado, el componente se ejecuta entero y síncrono en la pantalla, sin panel ni tarjetas; abiertas D11 ≈17 s hasta la primera pantalla vs 4 s en SCA, vuelta al Detalle vs buscador, y borrado de los objetos sin uso de la ronda 26); tipoInduccion «I» vs «V/A» (#13); canal manuscrito OneTrust sin encadenar (equipo CMP). Siguen: #2 estado tras ANULAR, #6 catalogación renovada (pendiente de OK), Q6 switch Verti, Q7 inducciones APP-SCAN tipo A (ya filtradas en el panel), ANL CONCLUIDA en PRE, R25 sin pólizas wAutemis válidas, hoja de pólizas «que derivan» agotada.


### Actualización tras las rondas 28-29 (23/10)

Ronda 28: el componente Inducir Cliente se ejecuta entero, síncrono y encadenado desde ANULAR PÓLIZA (`a!startProcessLink` + Sub-Process encadenado), con firma RGPD; D4 cerrada. Ronda 29 (doc 49): contacto persistido y reutilizado, redirección automática a la siguiente tarea tras ACEPTAR, checks obligatorios en Verti/Vencimiento con `tipoInduccion` I/V/A, componente en paralelo a actualizar mecanización → ANL → decidir acción, dos tablas de argumentos en nivel 2, documentos del SGD visibles (ojo), tarjetas Verti y componente con contenido en el Detalle. Preguntas nuevas: **D-R29A-4** (¿esperar la confirmación de CORE antes de decidir nivel/FIN? — 15788314 finalizó con mecanización INCOMPLETA), ACEPTAR único vs aviso, apertura directa de tareas de nivel 2, URL del componente en la respuesta de contacto, flota/wAutemis (2002600060631), CA nivel 2 no creada en SCA TEST (15788312), ≈17 s hasta la primera pantalla del CMP, borrado de objetos sin uso de la ronda 26.

## 2. Qué se ha desarrollado y cambiado (muy resumido)

**Construcción (fase 0 → ronda 8).** SCA2 se levantó desde cero en TEST como una aplicación nueva sobre la misma BBDD/CORE: un solo site, buscador y Detalle con tarjetas por gestión, alta, motor de decisión, Contra Anulación, Acciones Administrativas, Autorización fuera de norma, Mecanización, Finalización, bandeja de errores con relanzamiento, etiquetas HU3980, documentos en Documentum, notificaciones. La diferencia de fondo con SCA: en vez de procesos de larga duración, SCA2 usa **comandos cortos** (Alta, Decidir, CrearAccion, CompletarAccion, Mecanizar, Finalizar…) y guarda el estado de la solicitud en base de datos; si algo externo falla, el comando queda en la bandeja de errores y se relanza sin perder la solicitud.

**Revisiones del analista (rondas 2–12, 20, 22).** Cinco documentos «Análisis SCA2» y ~60 puntos cruzados y aplicados: validaciones y vigencia del alta, traducción de motivos/detalles/causas NEW/NSE antes de ANL, estados finales y `numGestion`, `NO_MECANIZAR`, banner y permisos SI24 (sólo nivel 2, causas ocultas, cascada motivo→detalle→causa, sin pregunta «¿insiste el cliente?»), nivel 2 CE_RM/SI24 con tarea al grupo y nuuma «-» hasta retomar, RETOMAR sólo en la tarjeta abierta, autorización sólo para wAutemis «pendiente de aceptar», impresión idempotente, compañías contrarias en ventana, anulaTecnico+anulaExperto para SI24 con acuerdo, bloqueo de la póliza en Central (NEW) antes de ANL, pantalla Verti previa tras la CA negativa, RETOMAR/REASIGNAR en AA.

**Evolutivos y correcciones propias (rondas 13–23).** Visionado del documento al adjuntar (ojo + CONTINUAR); mecanización en dos pasos (confirmación → inducción Verti/vencimiento); limpieza técnica (0 avisos del analizador, procesos reordenados, sin cambio funcional); página de mantenimiento «Pendientes de autorizar (wAutemis)» con AUTORIZAR/RECHAZAR (lanzan ANL Desbloquear como lo haría SGO) y CANCELAR; corrección de la referencia de Documentum (desde el 14/10 no se subía el fichero); nivel «00000005» que se perdía al pasar por Verti; fecha de efecto en «A EFECTO» (se guardaba la de vencimiento); reserva de prima y códigos sin traducir en el bloqueo NEW; `text(null)` en pólizas a futuro; fault CORE 4115 «ya tiene impresión» que paraba la solicitud; pérdida de las marcas SI24 al relanzar.

**Pruebas.** Comparación SCA vs SCA2 con datos nuevos en todas las rondas, la mayoría con sesiones hijas en paralelo (S1–S5, H1–H6, R9, R10, R23): alta, CA positiva/negativa, AA, autorización, mecanización, Verti, nivel 2 y RETOMAR, telemáticas, corredor, campañas, plan de pagos, NSE, Autemis. Informes en `docs/sca/pruebas/`.

## 3. Lógica de cada flujo en SCA2

Todos los flujos comparten la misma idea: **la solicitud vive en CORE y en la tabla de SCA2; cada paso es un comando corto que deja la solicitud en un estado y crea (o cierra) una tarea**. El Detalle muestra una tarjeta por gestión y los botones que tocan según el estado y el perfil.

1. **Alta.** El gestor identifica la póliza (Emisión), SCA2 comprueba vigencia y solicitudes pendientes (M021), propone la catalogación (a efecto, vencimiento, servicio, trimestral…) y la fecha de anulación según la catalogación, y pide motivo → detalle → causa (con las causas SI24 ocultas y la cascada) y compañía contraria si procede. Al GUARDAR crea la solicitud en CORE, adjunta el documento si lo hay (Documentum) y lanza la decisión del motor.
2. **Decisión del motor.** Con los datos de póliza, cliente, canal, campañas, acuerdos y perfil decide la primera acción: Contra Anulación (nivel 1 u otro grupo), Acción Administrativa, Autorización fuera de norma, Mecanización directa o No mecanizar. Crea la gestión en CORE y la tarea en SCA2.
3. **Contra Anulación.** Tarea para el grupo que corresponda. Resultado positivo → la póliza se retiene y la solicitud se finaliza (ANULACIÓN DESESTIMADA). Resultado negativo → modales de cierre (contacto con el cliente, acuerdo especial…) y el motor decide el siguiente paso: salto a nivel 2 (SI24 Expertos, nuuma «-» hasta que alguien RETOMA), Acción Administrativa, o mecanización; antes de ese paso hoy se muestra la pantalla previa Verti/Vencimiento (duda 1). El nivel 2 puede posponer, finalizar o mecanizar; con SI24 y acuerdo se marca anulaExperto/anulaTecnico.
4. **Acciones Administrativas.** Tarea del grupo administrativo con documentos (adjuntar, visionar, imprimir plantilla). RETOMAR/REASIGNAR visibles con la gestión abierta. Al completar, el motor decide mecanizar o finalizar.
5. **Autorización fuera de norma.** Sólo para wAutemis que Emisión deja «pendiente de aceptar» (00000005/06). La solicitud espera a que ANL/SGO autorice o rechace; AUTORIZAR/RECHAZAR/CANCELAR también se pueden hacer desde la página de mantenimiento (uso de pruebas).
6. **Mecanización.** ANULAR PÓLIZA → confirmación → (si el motor lo indica) inducción Verti/vencimiento → bloqueo de la póliza en Central (NEW) → alta de la autorización en CORE → alta en ANL → si queda pendiente, espera a ANL (duda 3); si no, anulación efectiva y gestión en CORE. Las NSE siguen su propia catalogación (dudas 5–8).
7. **Finalización.** Cierra la solicitud con su estado final (anulada, desestimada, cancelada, finalizada sin anular, ilocalizable…), actualiza CORE, nivel y notificaciones (DUE con teléfono del tomador).
8. **Bandeja de errores (administradores).** Cualquier comando que falle en un sistema externo (CORE, NEW, ANL, Documentum, Emisión) queda registrado con el fault real y se puede relanzar desde donde falló, conservando los datos (incluidas las marcas SI24 y la referencia del documento).
9. **Buscador, Detalle, Tareas y Mantenimiento.** Buscador con los filtros y etiquetas HU3980; Detalle con tarjetas por gestión, documentos y acciones por perfil; mantenimiento con las opciones heredadas más la nueva de pendientes de autorizar.

## 4. Cuánto queda y cómo veo la aplicación

**Cómo la veo.** Los flujos principales (alta → motor → CA → nivel 2 → mecanización → finalización, AA, autorización, buscador/Detalle, documentos, bandeja de errores) funcionan con paridad respecto a SCA con datos nuevos y están probados de extremo a extremo; en las últimas rondas los fallos que aparecen ya no son de diseño sino defectos puntuales (una fecha, un flag perdido, un fault externo mal tratado) que se localizan y corrigen en la misma ronda. Lo que frena el cierre no es el desarrollo sino **(a) las 17 decisiones funcionales de la tabla** y **(b) la dependencia de sistemas externos de PRE** (NEW/Central, ANL/SGO, Emisión) para verificar los ciclos wAutemis completos. La aplicación está en condiciones de que los analistas la revisen de forma guiada en TEST.

**Qué queda (ordenado).**
1. ~~Cerrar el ciclo ANL con las solicitudes nuevas~~ Hecho en la ronda 24 (AUTORIZAR/RECHAZAR/CANCELAR funcionan; bloqueo NEW OK). Lo que queda es externo o de decisión: ANL en PRE no marca `CONCLUIDA` para SCA2 (ver §1, #3). **~1 sesión.**
2. Aplicar las decisiones de la tabla §1 cuando las tengamos. Las que implican cambio (1, 2, 3, 4, 8, 9, 10) son cada una de tamaño pequeño-medio y se prueban en la misma ronda. **~2 sesiones en total**, dependiendo de cuántas cambien el comportamiento actual.
3. Casuísticas aún no probadas con dato nuevo: Acción Administrativa con documentos que derive realmente del motor (ninguna póliza de las listas derivó a AA), Autemis con bloqueo NEW corregido en todas sus variantes, pólizas «a efecto» con todas las combinaciones. Necesito pólizas del analista para AA. **~1 sesión** (sesiones hijas en paralelo).
4. Evolutivos no decididos (casilla de vencimiento SGC, batch NSE, entrada desde FDC, salto al Detalle tras el alta). Si entran: **~1–2 sesiones**.
5. Documentación final para analistas y traspaso (actualizar `36-funcional-sca2.md` con las decisiones, manual de pruebas): **media sesión**.

Estimación total para dejar SCA2 lista para la validación formal de los analistas: **4–6 sesiones de trabajo**, de las que la mitad depende de recibir las decisiones y las pólizas. Los tiempos de espera externos (respuestas del analista, disponibilidad de PRE) son los que marcarán el calendario, no el desarrollo.

## Actualización ronda 30 (argumento económico → A2139022_MES)

- `SCA2_ContraAnulacionModalRecuperacionPoliza` v5 → **v9**: tras tréboles/TTQ/SVA y sólo con `return = false`, si `argumentoEconomico = "S"` llama a `SCA2_marcarAsignacionBonificacionIntegracion` (CORE `marcarAsignacionBonificacion`: ECONOMICO / «Arg. Econ.» / `left(desc,20)` / codArg / póliza / solicitud / `today()`). Detalle y pruebas en `docs/sca/50-ronda30-argumento-economico.md` y `docs/sca/pruebas/r30-argumento-economico.md` (commit 699ffa2).
- Probado con solicitudes nuevas (Autos): económico sin tréboles (15788328/15788344) y con tréboles OK (15788329/15788332) → fila ECONOMICO en CORE (`consultarBonoCliente`); tréboles KO (15788335), no económico (15788330) y negativo (15788331) → no inserta.
- No concluyente: Hogar argumento 1 (15788338) cierra sin fila ECONOMICO (hipótesis: el listado no marca `mcaEconomico`); error de CORE (15788337); SVA sin Club MAPFRE falla antes en `SCA2_ContraAnulacionModalSVA` (defecto previo); SCA no generó la tarea en TEST (15788333).
- Dudas analista: registrar o no el fallo de CORE (sólo posible en el proceso de cierre, no en el modal); `FEC_APLICACION` con fecha Appian; corregir SCA (inserta aunque fallen tréboles); la consulta devuelve `ECONOMICO` y `numTipBon` 0; ¿argumento 1 económico en Hogar? / respaldo `SCA2_obtenerMarcaEconomica`; incidencias SVA y estado «Incompleta».

## Actualización rondas 31-32 (grupos, Decisora, fachada SCA→SCA2, constantes y limpieza)

- Análisis (sólo lectura): grupos y permisos SCA→SCA2 (doc 51), Web API Decisora y migración (doc 52), SCA como fachada con SCA2 detrás (doc 53), constantes vs literales y objetos sin uso (doc 54).
- Ejecutado en TEST (ronda 32): 58 constantes nuevas de negocio (perfiles, estados, acciones, códigos externos, colores); 552 literales sustituidos por `cons!` en 83 objetos con cambio funcional cero (regresión `/test` + UI con solicitudes nuevas 15788366/68/69/70); 66 objetos sin uso borrados. Detalle en doc 54 §7.
- Pendiente de decisión: PMs `SCA2 CMD BarridoCaducidad` / `SCA2 CMD RegistrarDesincronizacion`; `DECISION_ERROR` del motor en TEST (preexistente); dudas de los docs 51-53 para analistas.

## Ronda 34 (27/10/2026) — 5.º Análisis SCA2
Argumento económico confirmado OK por el analista. Corregidos: recarga del argumentario con pantalla de tréboles (respuesta completa + desmarcar selección), enhorabuena al final tras tréboles/retos/SVA OK (servicio en el ACEPTAR de la pantalla; fallo → argumento Pendiente), y el mantenimiento (Campaña/URL, grabación de argumentos, 999 en listado, BAJAPRIM: el mantenimiento leía el catálogo Aurora desactualizado; ahora lee CORE). Detalle y dudas en `55-ronda34-analisis-sca2.md`. Pendiente del analista: CANCELAR tras entregar tréboles, entrega parcial, póliza NO CLUB para probar el fallo de tréboles, y la política de refresco del catálogo Aurora. R33 (objetos sin uso, `pruebas/r33-objetos-sin-uso-verificados.md`) sigue a la espera del analista: nada borrado.

## Ronda 35 (29/10/2026) — 6.º Análisis SCA2
Alta: espera de la decisión sin volver al formulario + aviso de «tardando más» + detección de solicitud en curso con consulta/RETOMAR (límite: refresco mínimo 30 s en Appian). Documentos: imágenes admitidas (lista del DNI) y visor sin sobredimensionar. Tréboles: observación «Se han aplicado Y tréboles al cliente» aplicada, pendiente de probar con póliza TTQ vigente. Timeout del argumentario igualado a SCA (300 s). Pólizas del analista: `pruebas/polizas/` con bloques por sesión y REGISTRO.md. Detalle y dudas en `56-ronda35-analisis-sca2.md`.

## Ronda 37 (29/10/2026) — respuestas del analista a la ronda 35
`.jpeg` admitido (documentos y DNI, probado). Observación de lo aplicado extendida a Retos y SVA, grabada sólo con éxito del servicio (pendiente de prueba en pantalla por falta de pólizas con Retos/SVA/TTQ en TEST). Visor ≈800 px aprobado. Detalle en `56-ronda35-analisis-sca2.md` y `pruebas/r37-a-jpeg-observaciones-retos-sva.md`.

## Ronda 38 (30/10/2026) — `SCA2 CMD RefrescarCacheCabecera` y errores de la caché de cabecera
MNI no aplicado: el bucle ya va por lotes de 50 filas (≈400 nodos) y el tiempo lo marcan los servicios en vivo; MNI no mejora y añade riesgo (alternativa por lotes documentada). Errores `REFRESCO_CACHE_RECORTE`/`varchar(255)` corregidos: el enlace GESVIDA (≈287 caracteres) se guarda sin prefijo fijo y se recompone al leer (`SCA2_construirFilaCacheCabecera` v2, `SCA2_renovarCacheCabecera` v3, `SCA2_obtenerDatosCabecera` v7). Hallazgos abiertos: caducidad grabada a 07:00 GMT frente al timer 07:05 Madrid; filas duplicadas por solicitud. Detalle en `pruebas/r38-a-refrescar-cache-cabecera-mni.md`.
