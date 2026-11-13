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

## Ronda 42 (30/10/2026) — espera síncrona en lugar del sondeo de 30 s
Las pantallas lanzan el proceso de forma síncrona (`isSynchronous: true`) y los PMs Alta, Decidir, CrearAccion, CompletarAccion y Posponer van encadenados (activity chaining) con subprocesos síncronos, sin cambiar nodos, variables ni lógica. Si Appian corta a los 30 s (límite documentado), `onIncomplete` vuelve al sondeo de 30 s con aviso y botón COMPROBAR AHORA. Tiempos con solicitudes nuevas: alta ≈34 s → 15–20 s (lo que tarda el propio proceso); CA negativa 49,3 → 14,0 s; CA positiva 21,6 → 3,5 s; POSPONER 27,4 → 2,1 s; Vencimiento 28,7 → 1,7 s. Corregido un hueco en el que COMPROBAR AHORA habilitaba ACEPTAR antes de la gestión (`SCA2_DetalleTareas` v41). Sin probar en UI: acciones administrativas, anulación fuera de norma, botones de mecanización y `onIncomplete` natural. Detalle en `pruebas/r42-a-espera-sincrona-sin-sondeo.md`.

## Ronda 43 (03/11/2026) — póliza Vida (7.º Análisis SCA2)
Cabecera Vida corregida (`SCA2_getCodAgenteVida` v2: entrada con el CDT `SCAC_DS_producersData`; 0005912432 muestra «AG» y «105333 / 5324209», también desde caché). Motivo/detalle/causa de Vida con la línea de negocio 3 (`SCA2_INT_LINEA_NEGOCIO_VIDA`). Rama Vida del alta portada de SCA (`SCA2_AltaSolicitudPage` v49, `SCA2_construirContextoAlta` v14), pero el alta Vida no llega a crearse: CORE responde 4004 «Datos insuficientes» en `generarStudAnul` (3 pólizas nuevas). Regresión Hogar 15788719 y Autos 15788720 correcta. Detalle en `pruebas/r43-a-poliza-vida-cabecera-motivos.md`.

## Ronda 44 (03/11/2026) — estados tras acciones administrativas y mecanización (8.º Análisis SCA2)
Informe: `pruebas/r44-a-estados-acc-adm-mecanizacion.md` (commit 37a35b7). ACEPTAR del alta deshabilitado tras el primer clic (`SCA2_AltaSolicitudPage` v50). Sin inducción VERTI/Vencimiento cuando la solicitud viene de Acción Administrativa, como SCA (`SCA2 CMD Mecanizar` v45, regla `SCA2_vieneDeAccionAdministrativa`). La mecanización «Incompleta» se debía a que SCA2 cerraba la solicitud en CORE antes de que NSE escribiera el suplemento en ANL: `SCA2 CMD Finalizar` v14 espera a NSE (1 min, máx. 10) y actualiza la mecanización (`SCA2_actualizarMecanizacionAnulacionNse`). Probado OK con 15788751 (NSE Autos), 15788752 (NSE Hogar) y 15788753 (entrega de documentos): «ANULACION REALIZADA» y lista «Finalizada. Anulación realizada». Sin probar: pendiente de autorizar (sin pólizas con controles 05/06), wAutemis (error previo en «Tipo catalogación» del alta) y anulación directa 15788754 (NSE no respondió en 10 min; quedó «Incompleta» y la lista muestra «Pendiente de Autorización»).

## Ronda 45 (06/11/2026) — 9.º «Análisis SCA2»

**Contexto.** En TEST, el MCP y la LCP siguen caídos por el feature toggle `ae.dev-copilot-api.lcp-api-plugin = false` (las rutas `lcp-api/*` dan 404 y el MCP rechaza las herramientas); la incidencia queda pendiente de Appian Support. Se trabajó con Deployment API v2, generando `versionUuid` nuevos para los paquetes parciales, y con Appian Designer. Los cambios y pruebas fueron en SCA2.

Fuentes de detalle: `pruebas/coordinacion-ronda45.md`, `pruebas/r45-a-vida-clave-produccion.md`, `pruebas/r45-b-anl-pendiente-autorizar.md`, `pruebas/r45-c-si24.md`, `pruebas/r45-d-estados-lista.md` y `pruebas/polizas/REGISTRO.md`.

### Resultados por sesión

#### R45-A — Vida

| Casos | Resultado | Solicitudes usadas |
|---|---|---|
| A1, Vida sin estructura comercial | **OK** en SCA2: aviso y GUARDAR bloqueado. Comparación con SCA: **no comparable**, SCA rechaza la Vida en la validación previa. | `0006059023`; sin solicitud creada |
| A2, clave de producción y estructura comercial | **OK**: `0006000328`, `0006000397` y `0006059601` muestran `184720372 / 0035099`; el productor «1» seguido de otro válido se resolvió en Designer. | `0006000328`, `0006000397`, `0006059601`, `0006059703` (solo Designer; sin alta) |
| Alta Vida en CORE | **KO**: tres altas devuelven 4004 en `generarStudAnul`; probar `codCiaUsuario` 3 tampoco lo corrige. | `PDTE-269184418`, `PDTE-748230`, `PDTE-269184469`, `PDTE-13377305` (sin solicitud CORE) |
| A3, doble clic en ACEPTAR | **KO visual / OK sin duplicados** en Hogar y Autos; **no probado** en Vida. La comparación SCA tiene el mismo comportamiento. | `15788809`, `15788813`; `15788810` creada, doble clic no medido; SCA `15788814` |
| Origen de la Vida histórica y respuesta CORE | **No comparable / no concluyente**: lectura de `15788717` no identifica el camino de creación ni el campo que falta. | `15788717` (solo lectura) |

#### R45-B — ANL y mecanización

| Casos | Resultado | Solicitudes usadas |
|---|---|---|
| B2a, `fecAnulacion` / `fechaSuplemento` para NSE y wAutemis | **OK** para la fecha enviada en NSE (`15788805`) y wAutemis con vencimiento a menos de 18 meses (`15788828`). **KO externo NEW 916** al vencer a más de 18 meses (`15788817`). | `15788768` (solo lectura/regla), `15788805`, `15788817` (solo lectura), `15788828` |
| B2b, controles 05/06 y pendiente de autorizar | **KO / no conseguido**: no se obtuvieron casos reales 4/5 + 2 ni 4/5 + 7. En el cribado, 42 NSE respondieron fault 4021 sin controles; la wAutemis `15788828` quedó 4 + mecanización INCOMPLETA. | `15788828`; cribado de 45 pólizas, sin otras solicitudes nuevas |
| B1, Acción Administrativa sin documentación | **OK en CORE** (`15788805`, anulación realizada); discrepancia inicial de etiqueta/UI, revisada por R45-D. | `15788805` |
| B4, NO en Anulación/Suscripción | **KO** para solicitud 14. La mecanización quedó en código 4 en `15788815`; la fase 2 para forzar el 14 no funcionó y se revirtió. | `15788811`, `15788815`, `15788821`, `15788826` |
| D6, ANL sin `TIPO_FLUJO` | **KO externo**: `15788754` quedó sin suplemento, con la gestión de mecanización incompleta. | `15788754` (solo lectura) |
| D8, cierre wAutemis tras ANULAR NEW | **OK E2E** tras la espera: `15788830` finalizó con mecanización realizada; regresión NSE también **OK** con `15788831`. | `15788828` (diagnóstico), `15788830`, `15788831` |

#### R45-C — Si24

| Casos | Resultado | Solicitudes usadas |
|---|---|---|
| C1/C3, aviso Si24 | **OK**: no aparece al usuario Si24; se mantiene para Red Mapfre. | `15788800`, `15788801`, `15788804` |
| C4, FINALIZAR sin carta/DNI con argumento negativo | **OK** para SISANS; Red Mapfre sigue necesitando carta. | `15788800`, `15788801` |
| C2, Verti/Vencimiento e inducción | **OK** el enlace a la tarea; **KO externo** en la consulta del agente de CMP. El caso de vencimiento futuro también queda en error de integración ANL. | `15788801`, `15788817` |
| P1/P2, nivel 2, RETOMAR y modal Sí/No | **OK**, incluidos los flags de perfil corregidos; el vencimiento pasado de `15788808` explicó que no se lanzaran mecanización ni inducción. | `15788808`, `15788812` |
| F4, asignación y botones RETOMAR/REASIGNAR | **OK** en las pruebas de asignación, tarea propia y tarea sin asignar; **pendiente** decidir si la Verti de nivel 2 debe asignarse al usuario o al grupo Si24. | `15788816`, `15788824`, `15788825` |
| Comparación funcional en SCA | **No comparable**: el alta se quedó bloqueada en el popup. | `0002729325303`; sin solicitud |

#### R45-D — Estados

| Casos | Resultado | Solicitudes usadas |
|---|---|---|
| Tabla de estados y colores | **OK**, 29/29 combinaciones verificadas en la regla desplegada. | Regla de prueba en Designer; sin solicitud |
| F1, F3, F4 y F5: pendiente, anulación realizada, contra-anulación positiva y cancelada | **OK** en lista; coherencia lista/detalle/«Otras solicitudes» verificada en fase 2. | `15788799`, `15788803`, `15788806`, `15788807` |
| F2: mecanización enviada / pendiente de autorización | **KO para el caso objetivo / no reproducido**: la solicitud quedó en nivel 2 (NSE 6). | `15788802` |
| B1, revisión y prueba nueva | **OK / no se reprodujo** la etiqueta incorrecta; en la prueba nueva se observaron estados transitorios y convergencia a azul en t2/t5. | `15788805`, `15788822` |
| Comparación en SCA | **Parcial / no comparable**: casos 1–3 solo en lista inicial; después falló la navegación de SCA. | `15788799`; sin solicitud nueva para los casos restantes |

### Errores externos observados

| Sistema | Error / caso | Evidencia |
|---|---|---|
| CORE | 4004 «Datos insuficientes» en `generarStudAnul` para altas Vida | Tres altas con clave, estructura y prima; el intento con `codCiaUsuario` 3 dio el mismo resultado. |
| NEW / GAIA | Error 916: «La Fecha de Efecto no puede ser mayor o menor en 18 meses que la Fecha de Mecanización» | wAutemis con vencimiento a ~21 meses; `fechaSuplemento` enviada coincide con la fecha de anulación. |
| CMP | «No es posible realizar la inducción. Se ha producido un error al consultar los datos del agente» | `15788801` y `15788817`; CMP es externo a SCA2. |
| ANL | `REDIRIGIR_NEW = true` y `TIPO_FLUJO` vacío | `15788754`: ANL no lanzó NSE/NEW y no registró suplemento. |
| NSE | Fault 4021: «Se produjo un error no controlado al validar los datos de la anulación» | Las 42 pólizas NSE del cribado no devolvieron controles técnicos 05/06. |

### Objetos modificados

| Sesión | Objeto | Versión / resultado |
|---|---|---|
| R45-A | Integración `SCA2_consultaEstructuraComercialVida` | v2 → v3 |
| R45-A | ER `SCA2_obtenerDatosCabeceraLive` (parte Vida) | v1 → v2 |
| R45-A | IF `SCA2_AltaSolicitudPage` | v50 → v51 |
| R45-A | ER `SCA2_construirContextoAlta` | v4 → v6 |
| R45-A | ER `SCA2_construirContextoAlta` (prueba `codCiaUsuario` 3) | v6 → v7 → v8; cambio revertido, contenido final de v8 = v6 |
| R45-A | Constantes `SCA2_TXT_POLIZA_SIN_ESTRUCTURA_TITULO` y `SCA2_TXT_POLIZA_SIN_ESTRUCTURA_COMERCIAL` | Nuevas, v1 |
| R45-B | ER `SCA2_construirSolicitudAnulacionAnlTraducida` | vN → vN+1 (un guardado en Designer; versión numérica no indicada) |
| R45-B | ER `SCA2_actualizarMecanizacionAnulacionNse`; PM `SCA2 CMD Finalizar` | v3 → v4; v14 → v15 |
| R45-B | ER `SCA2_actualizarMecanizacionAnulacionNse` (fase 2) | v4 → v5 → v6 → v7; fase 2 revertida, contenido final = v4 |
| R45-B | PM `SCA2 CMD Finalizar` (fase 2) | v15 → v16 → v17; fase 2 revertida, contenido final = v15 |
| R45-B | Constantes `SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA` (9) y `SCA2_TXT_COD_ESTADO_SOL_CANCELADA` (14) | Nuevas, v1; quedan sin uso tras revertir fase 2 |
| R45-B | ER `SCA2_actualizarMecanizacionAnulacionNse` (espera wAutemis/ANL) | v5 → v6; probado E2E en fase 5, sin cambios adicionales |
| R45-C | IF `SCA2_ContraAnulacionOpciones` | v5 → v6 → v7 |
| R45-C | IF `SCA2_DetalleTareas` | v3 → v4 → v5 |
| R45-C | IF `SCA2_DetalleSolicitud` | v2 → v3 → v4 |
| R45-D | ER `SCA2_calcularEstadoSolicitud` | v3 → v4 → v5 |
| R45-D | ER `SCA2_colorEstadoSolicitud` | v3 → v4 |
| R45-D | IF `SCA2_BuscadorTabla` y `SCA2_Buscador` | v3 → v4 → v5 |
| R45-D | IF `SCA2_TablaOtrasSolAnulacion` | v2 → v3 |
| R45-D | IF `SCA2_SolicitudAnulacion` | v3 → v4 → v5 |
| R45-D | 15 constantes `SCA2_TXT_ETQ_ESTADO_*` / `SCA2_TXT_COD_EST_MECANIZACION_*` | Nuevas, v1 |
| R45-D | Constante `SCA2_TXT_COD_EST_MECANIZACION_SIN` | Nueva, v1 |

### Dudas para el analista

#### Vida: clave y alta

1. **R45-A D1 — clave de producción:** ¿la parte izquierda es `184720372` (concatenación literal, implementado) o `18420372` como pone el ejemplo? Si es lo segundo, ¿qué regla quita el `7`?
2. **R45-A D2 — CORE 4004:** con compañía 3, ramo 101, producto, clave `codAgente`, estructura DGT/DT/oficina, prima y `codInt`, CORE sigue con 4004. ¿Qué dato exige CORE para Vida? ¿`numApli` (qué valor para Vida)? ¿Se puede obtener la petición de un alta Vida correcta (p. ej. la 15788717 de R43) o el detalle del 4004 en el log de CORE?
3. **R45-A D3 — `fecValidez`:** ¿debe enviarse explícitamente (y con qué fecha: hoy, efecto o anulación)? Hoy el servicio responde sin él.
4. **R45-A D4 — estructura comercial y prima:** se envían ahora a CORE (antes vacías, también en SCA). Si CORE no las quiere para Vida, ¿se pueden quitar (cambio solo en `SCA2_construirContextoAlta`)?
5. **R45-A D5 — ACEPTAR visual:** en SCA2 (y en SCA) el botón no se ve deshabilitado tras el primer clic, aunque no se duplica nada. ¿Basta con que no haya duplicados o se quiere además un cambio visual inmediato? Lo segundo no se puede hacer en SAIL antes de la respuesta del servidor; habría que separar el clic (marcar) de la navegación, lo que añade un paso.

#### ANL, CORE, NEW y NSE

6. **R45-B D1 — cancelación desde mecanización:** ¿se acepta 5+4 («Rechazada anulación», como haría SCA) o debe usarse otro servicio para dejar la solicitud en 14?
7. **R45-B D1, fase 2 — servicio CORE:** `finalizarContraAnulPca` con 9 no cancela una solicitud sin gestión de contra-anulación. ¿Qué servicio de CORE debe cancelar (14) desde la mecanización?
8. **R45-B D5 — fecha de suplemento a más de 18 meses:** NEW rechaza la anulación a vencimiento con error 916. ¿Qué `fechaSuplemento` debe ir en ese caso, o SCA2 debe impedirlo?
9. **R45-B D6 — ANL sin `TIPO_FLUJO`:** en `15788754`, ANL acepta con `REDIRIGIR_NEW` y `TIPO_FLUJO` vacío y no lanza NSE/NEW. ¿Cómo debe tratarlo SCA2?
10. **R45-B D7 — fecha del nivel NEW:** NEW solo devuelve 00000005 (Norma 58) cuando la fecha de efecto está cerca de hoy. En una anulación A VENCIMIENTO no devuelve nivel y SCA2 sigue el camino normal. ¿Debe SCA2 consultar el nivel con otra fecha (¿la de hoy?) para ir a pendiente de autorizar, como SCA?
11. **R45-B D8 — estado final wAutemis:** en `15788828`, CORE dejó solicitud 4 «Pendiente de Autorización» + mecanización INCOMPLETA, aunque NEW respondió true y la póliza aparece anulada en NEW. ¿Qué estado final debía quedar y quién lo fijaba? **Resuelta en fase 5:** `15788830` terminó con la mecanización ANULACIÓN REALIZADA tras esperar a ANL.
12. **R45-B D9 — nivel 00000004 de wAutemis:** el cribado con `SCA2_consultarAnulacionPoliza` y la fecha de vencimiento devuelve `nvlCumplimiento` 00000004, pero la pantalla de `15788830` lo muestra vacío y no va a pendiente de autorizar. ¿Debe 00000004 ir a pendiente de autorizar en wAutemis?
13. **R45-B D2 — espera NSE máxima:** ¿cuál es el máximo de espera NSE aceptable (10 min actual)?
14. **R45-B D3 — «Tipo catalogación» de wAutemis:** ¿qué opción elegir entre las cuatro propuestas: inicializar «A FECHA» como valor válido, ampliar las opciones, limpiar el valor no permitido o decidir que wAutemis siempre debe usar «A FECHA»?
15. **R45-B D4 — etiqueta tras B1:** revisar la etiqueta «Finalizada sin anular» con CORE 5 + ANULACIÓN REALIZADA. **Contrastada en R45-D:** no se reprodujo como estado final; en `15788822` se observó un estado transitorio mientras concluía NSE/CORE.

#### Si24, Verti e inducción

16. **R45-C D1 — aviso Si24:** se resolvió que «la solicitud la trata Si24» significa usuario gestor Si24, perfil `CE_MF_BK` (GGE) o nivel de intervención > 1. ¿Se debe ocultar también a central y CCC, o solo a Si24/GGE?
17. **R45-C D2 — perfiles (resuelta):** se corrigieron en fase 2 los flags `codPerfilSi24Experto/Front/GGE`, que antes salían siempre `false` al leerse de un campo inexistente de `infoUsuarioDTO`; SCA los calcula de `codSubPerfil`/`codPerfil`.
18. **R45-C D3 — CMP «datos del agente»:** la inducción de la 0002729325300 (wAutemis, acuerdo VW PLURI) devuelve «error al consultar los datos del agente» en CMP. ¿Es esperable en TEST para pólizas de acuerdo/concesionario? SCA2 marca la gestión de inducción como Finalizada.
19. **R45-C D4 — perfiles y documentación:** C4 se aplica a cualquier perfil distinto de Red Mapfre (`codPerfil` ≠ perfil RM). ¿Hay otros perfiles que deban seguir exigiendo carta/DNI?
20. **R45-C D5 — Verti de nivel 2:** ¿la Verti del nivel 2 debe ir al usuario del alta o al usuario/grupo Si24?
21. **R45-C D5b — RETOMAR/REASIGNAR (resuelta):** ¿deben limitarse RETOMAR/REASIGNAR al usuario asignado, como en SCA? Se limitó RETOMAR a la tarea propia o sin asignar y se ajustó REASIGNAR en CA nivel 2 para `CE_MF_SI24` en `SCA2_DetalleSolicitud` v4. La asignación de la Verti de nivel 2 sigue siendo la pregunta abierta anterior.
22. **R45-C D6 — caducidad (explicada):** `15788808` estaba caducada por la fecha de vencimiento pasada. Con vencimiento futuro (`15788817`), el encadenado llegó a ANL e inducción; ANL quedó en error de integración y CMP falló al consultar el agente (externos).
23. **R45-C D7 — REASIGNAR en CA1 de otro grupo:** si el usuario no comparte grupo/nivel y no puede gestionar la tarea, SCA2 oculta toda la botonera. ¿Debe ver REASIGNAR, como en SCA?
24. **R45-C D8 — error de ANL en TEST:** ¿es esperado que ANL deje la anulación de la 0002729325306 (GO INSURANCE PLURIANUAL, wAutemis) en «Gestionar Error Integración Anulacion», bloqueando NSE y dejando la mecanización Incompleta?

#### Etiquetas y estado transitorio

25. **R45-D Q1 — estado 4/5 con mecanización incompleta:** para solicitud 4/5 + mecanización 3 (incompleta) o 5, hoy aparece «Pendiente de Autorización» o lo que resulte de la lógica anterior por gestiones. ¿Qué etiqueta debe mostrarse? (Ejemplo 15788455.)
26. **R45-D Q2 — filtro Estado:** el filtro usa el estado SCA2 persistido, no la etiqueta D1; con «Cancelada» aparecen filas con otras etiquetas. ¿Debe filtrar por la etiqueta D1?
27. **R45-D Q3 — combinaciones fuera de tabla:** ¿qué etiqueta corresponde a solicitud 2 + mecanización 1 sin gestión 5; 2 + mecanización 2/4/7; 14 + mecanización distinta de vacía/4; 3 + cualquier mecanización; y estados 7–10, 13, 15–19? Hoy se aplica la lógica anterior.
28. **R45-D fase 3 — mientras NSE termina:** ¿se quiere un estado explícito mientras NSE no ha terminado o un refresco automático en lugar del estado intermedio observado? No implementado.

### Pendientes

- No se consiguieron casos reales 4/5 + 2 ni 4/5 + 7. El cribado NSE devolvió fault 4021; las wAutemis no dieron la combinación buscada al usar la fecha de vencimiento.
- Acción Administrativa activa: no hubo prueba UI; las solicitudes nuevas solo mostraban las acciones como «Pendiente», sin tarea activa.
- R45-C deja abiertas estas solicitudes de prueba: `15788816` (Verti nivel 2 de JJGONZ2), `15788817` (mecanización Incompleta/error ANL), `15788824` (Verti SISANS abierta) y `15788825` (CA1 JJGONZ2 abierta).
- También quedan anotadas en R45-C `15788808` (mecanización Incompleta), `15788812` (Verti SISANS abierta) y las CA abiertas de `15788800` y `15788804`.
- R45-D no obtuvo prueba real para 4/5 + 2 o 4/5 + 7; la solicitud `15788802` terminó en nivel 2.

## Ronda 46 (10/11/2026): 10.º «Análisis SCA2»

**Contexto.** El MCP de Appian TEST (`appian-dev-mcp-c90b`, plugin 26.9.15) ha vuelto a funcionar. Todos los cambios se han hecho en SCA2 y se han probado en TEST.

El análisis tuvo dos entregas: R46-A con la primera y R46-B, R46-C y R46-D con la segunda.

Fuentes de detalle:
- `pruebas/coordinacion-ronda46.md`: objetos tocados y sus versiones.
- `pruebas/r46-a-analisis-detalle-estados.md`
- `pruebas/r46-b-anl-nse-new.md`
- `pruebas/r46-c-alta-si24-detalle.md`
- `pruebas/r46-d-argumentario-treboles.md`

### Resultados por sesión

| Sesión | Hecho y probado con solicitudes nuevas | Cambiado sin prueba E2E / bloqueado | Solicitudes abiertas |
|---|---|---|---|
| R46-A: detalle y etiquetas | «Nivel X» también en el nivel 1. Nivel real en la inducción. Se quita «Gestión Verti/Vencimiento» cuando la gestión ha terminado. Perfil, grupo y Nuuma CORE. 4/5 + mecanización 3/5 → «Solicitud Finalizada sin anular» (rojo). | Filtro «Estado» sin cambios (N1). Opción seleccionada en el componente: CMP no la registra (N2). | — |
| R46-B: ANL, NSE y NEW | wAutemis 916 bloquea el alta con el mensaje de Autemis. Espera NSE/ANL de 10 × 30 s (5 min). Catalogación Más Móvil «A VENCIMIENTO TRIMESTRAL» según el servicio. Catalogación final NSE en CORE = 1 (`15788858`). | Solo revisados por código, por falta de un caso real: rechazo NSE → mecanización 4 (`SCA2 CMD Mecanizar`, nodo 304); `ANL_EXCESO_TIEMPO` en la bandeja de errores (`SCA2 CMD Finalizar`). | `15788858` |
| R46-C: alta, Si24 y detalle | CONSULTAR SOLICITUD (`2002400441596`). Mensaje de fecha anterior a la de efecto (`2002400441598`). Enlace NSE con `n`/`o` (`15787950`). Verti de nivel 2 gestionable por el usuario del alta (N6). Solo GGE y Si24 experto/front finalizan sin carta, como en SCA. | Verti → inducción con Oficina: falta una póliza de acuerdo válida (`15788853` quedó con la mecanización incompleta). Perfiles Central, CCC, GGE y Si24 front sin probar: no hay usuarios de esos perfiles. | `15788857` |
| R46-D: argumentario y tréboles | RECARGAR conserva el argumento marcado (`15788852`). Corregido el desplegable «SVA a aplicar» (`15788856`). | Importados sin probar: tréboles al ACEPTAR la enhorabuena, entrega parcial TTQ con error relanzable, truncado a 999, recarga de Aurora, observaciones SVA y reserva de prima. DDL de `POLIZA_FECHAULTIMOSINIESTRO` pendiente de un DBA (`sql/63-r46d-ampliar-poliza-fechaultimosiniestro.sql`). | `15788852`, `15788854`, `15788856` |

### Incidencias de coordinación

R46-D guardó `SCA2_ContraAnulacionOpciones` sobre la reserva de R46-C. Se restauró en la v73; la versión final es la v78 y un diff confirma que conserva los cambios de R46-B, R46-C y R46-D.

### Necesario para cerrar

- Una póliza con TU TE QUEDAS vigente y un cliente socio Club.
- Una póliza de acuerdo con vencimiento a menos de 18 meses, para Verti → inducción con Oficina.
- Usuarios de TEST con perfil administrador SCA2 (bandeja `/errores` y mantenimiento), Central, CCC, GGE y Si24 front.
- Pólizas que lleguen a «Pendiente de Autorización» (4/5 + 2) o a «Mecanización Enviada» (4/5 + 7).
- Un DBA que ejecute el DDL de la caché de cabecera.
- Alta Vida: el 4004 de CORE sigue abierto (AM/CORE).

### Dudas nuevas

Están en la sección «Dudas nuevas» de cada informe. Entre ellas:
- La fecha de Más Móvil: ¿02/01 o 01/01/2027?
- El tipo de documento del enlace NSE, que hoy se deduce del formato del número.
- El significado de «reserva de prima».
- N3 y N4 de R46-A.
