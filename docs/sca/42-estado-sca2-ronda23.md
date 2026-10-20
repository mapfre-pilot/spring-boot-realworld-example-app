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
1. Cerrar el ciclo ANL con las solicitudes nuevas ya pendientes (15788161/15788166/15788168): AUTORIZAR, RECHAZAR y CANCELAR y comprobar que ANL llega hasta el cierre con SGO. La sesión hija R23-A se paró por límite de uso justo antes; pendiente de tu OK para reanudarla o relanzarla. **~1 sesión.**
2. Aplicar las decisiones de la tabla §1 cuando las tengamos. Las que implican cambio (1, 2, 3, 4, 8, 9, 10) son cada una de tamaño pequeño-medio y se prueban en la misma ronda. **~2 sesiones en total**, dependiendo de cuántas cambien el comportamiento actual.
3. Casuísticas aún no probadas con dato nuevo: Acción Administrativa con documentos que derive realmente del motor (ninguna póliza de las listas derivó a AA), Autemis con bloqueo NEW corregido en todas sus variantes, pólizas «a efecto» con todas las combinaciones. Necesito pólizas del analista para AA. **~1 sesión** (sesiones hijas en paralelo).
4. Evolutivos no decididos (casilla de vencimiento SGC, batch NSE, entrada desde FDC, salto al Detalle tras el alta). Si entran: **~1–2 sesiones**.
5. Documentación final para analistas y traspaso (actualizar `36-funcional-sca2.md` con las decisiones, manual de pruebas): **media sesión**.

Estimación total para dejar SCA2 lista para la validación formal de los analistas: **4–6 sesiones de trabajo**, de las que la mitad depende de recibir las decisiones y las pólizas. Los tiempos de espera externos (respuestas del analista, disponibilidad de PRE) son los que marcarán el calendario, no el desarrollo.
