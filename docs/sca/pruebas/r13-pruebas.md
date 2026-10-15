# Ronda 13 — Pruebas (15/10/2026)

Cambios probados: `34-ronda13-visionado-verti-alta.md`. Usuario JJGONZ2 (Oficina). Grabaciones del testing agent: `sca2-r13-*`.

## 1. Evolutivo visionado (plan del analista CP01–CP04)
| Caso | Solicitud / póliza | Resultado |
|---|---|---|
| CP01 CA: adjuntar DNI → ojo habilitado → visor con CONTINUAR arriba → vuelve con la fila intacta | 15788053 / 0001047017117 | PASA |
| CP02 CA: adjuntar «Carta firmada» → ojo = adjunto; imprimir = plantilla | 15788053 | PASA |
| CP03 AA (Baja vehículo): adjuntar DNI → ojo → visor CONTINUAR | 15788054 / 0001047017120 | PASA |
| CP04 AA (Venta del vehículo): adjuntar «Documento compra/venta sin traspaso» → ojo = adjunto; imprimir = plantilla | 15788055 / 0001047017123 | PASA |
| Comparación SCA | — | No probado: sin tarea CA/AA interactiva accesible en SCA TEST |
Ninguna CA/AA finalizada ni pospuesta (quedan pendientes para seguir probando). Incidencia repetida: las altas CP03/CP04 volvieron al formulario sin número (ver doc 34 §1); las solicitudes se crearon una sola vez.

Hallazgo colateral corregido durante la prueba: pestaña «Solicitud Anulación» del Detalle fallaba con `wherecontains … (Text, Any Type)` cuando la lista de compañías contrarias venía vacía → `SCA2_SolicitudAnulacion` v10 (`touniformstring`). Verificado en 15788053.

## 2. Mecanización / inducción Verti (15788025, póliza 0000253500305)
| Paso | Resultado |
|---|---|
| Pantalla de mecanización muestra sólo la confirmación (sin bloque «Generación de contactos») | PASA (v16) |
| ANULAR PÓLIZA → CORRECTO; el proceso crea la gestión «Verti/vencimiento» (tarea VERTI 231, 18:19:40) | PASA: el motor devolvió contactos para esta póliza |
| Tras ACEPTAR, saltar a la pantalla de inducción | FALLABA (volvía al buscador) → corregido en `SCA2_DetalleTareas` v25 (pendiente de reprobar con otra solicitud en MECANIZAR) |
| Pantalla «Inducción Verti / Vencimiento» con casillas | FALLABA («No se han determinado contactos») → corregido v5 (parámetros del motor como en Mecanización + casillas por defecto si el motor no responde): PASA |
| CONTINUAR → mecanizar | FALLABA 1: la 2.ª ejecución de CMD Mecanizar se descartaba por idempotencia (la tarea VERTI escribía la transición OK) → corregido en el proceso. FALLABA 2: «only one smart service can be run per expression evaluation» (insertarObservaciones + startProcess) → v6/v7 encadenan inducción → mecanizar y pasan las observaciones al proceso. FALLABA 3 (v6/v7): encadenar startProcess en onSuccess cuenta también como 2.º smart service → v8: el botón sólo lanza CMD Mecanizar con `inducirVerti`, y el proceso tiene un nodo nuevo «Inducción Verti (CMP)» (Start Process del PM corporativo). FALLABA 4 (v8): el proceso ejecutó la mecanización en CORE (gestión 43705728) pero «Write Éxito» falló por clave de idempotencia duplicada (la tarea VERTI había escrito ya la clave `SCA2 CMD Mecanizar|15788025|1` a las 18:19) → clave con sufijo `|VERTI` en la vuelta desde la inducción y cierre de la tarea MECANIZAR pendiente. Resultado de la reprueba con solicitud nueva: §3 |
| Comparación SCA | No probado: sin solicitud SCA en mecanización; póliza 0000023400744 tiene ya la solicitud 15788045 |

## 3. Reprueba con solicitud nueva (15788053, póliza 0001047017117)
| Paso | Resultado |
|---|---|
| CA: INCREMENTO PRIMA → NEGATIVO → FINALIZAR → SI (oficina MADRID CORREDORES NORTE II, carta) | PASA: «Finalizada Negativa» |
| Mecanización: sólo confirmación; ANULAR PÓLIZA | PASA |
| ACEPTAR abre la inducción en la misma cadena | FALLA (vuelve al buscador: ACEPTAR se pulsó antes de que el proceso creara la tarea VERTI) → `SCA2_DetalleTareas` v26: ACEPTAR espera (máx. 90 s) a la tarea VERTI o al fin de la mecanización. Reprueba: §3b |
| RETOMAR Gestión Verti/vencimiento → casillas → Verti → CONTINUAR → ACEPTAR | PASA, sin error |
| Detalle a los 2 min | PASA: Mecanización «Anulación Realizada» (fin 21:04:25), Gestión Verti/vencimiento «Finalizada», sin MECANIZAR pendiente |
| Después aparece «Contra Anulación — Incompleta, nivel 2» (21:04:19) | Comportamiento del ciclo existente (mecanización → cambio de nivel → CrearAccion nivel 2, como SCA: SI24). Confirmar con el analista que tras Verti también aplica |
| Efecto real de la inducción en Verti/GAIA | NO PROBADO (sólo desde Verti/GAIA) |

### 3b. Reprueba de DetalleTareas v26 (ACEPTAR → inducción en la misma cadena)
- 15788057 / 0001047017127: la póliza tiene acuerdo especial → la CA negativa derivó a CA nivel 2 (GGE EXPERTOS SI24), no a Mecanización; no sirve para el escenario (queda la CA nivel 2 sin gestionar).
- 15788058 / 0001047017135 (v26): ANULAR PÓLIZA → ACEPTAR volvió al buscador. Causa real (hallada por el tester en el código): en MECANIZACION el popup CORRECTO mostraba otra card «ACEPTAR» con enlace directo al buscador y ocultaba el botón corregido → v27/v28: el botón corregido se muestra en MECANIZACION, relee la tarea VERTI en el clic y mantiene el popup («Comprobando si procede la inducción…») mientras el proceso no ha decidido. Por RETOMAR: Verti → CONTINUAR → Detalle a los 2 min: Mecanización «Anulación Realizada», Verti «Finalizada», nueva CA nivel 2 incompleta (no gestionada).
- Tercera solicitud (v28): resultado al final de esta sección.


**Estado de 15788025 (ATENCIÓN):** CORE tiene la anulación mecanizada (gestión 43705728, proceso 17390968 a las 18:45) pero SCA2 sigue en EN_ACCION/VERTI con las tareas 220 (MECANIZAR) y 231 (VERTI) pendientes porque la escritura falló. No relanzar CMD Mecanizar (volvería a llamar a CORE); hace falta sincronizar el registro a mano (MECANIZADA → ANL) o finalizar la solicitud. Decisión del usuario.

## 4. Pendientes de prueba
- ANULAR PÓLIZA → ACEPTAR → pantalla de inducción en la misma cadena (DetalleTareas v25) con una solicitud nueva en MECANIZAR.
- Efecto real de la inducción (PM CMP Inducir Cliente Completo) en GAIA/Verti: sólo comprobable desde Verti/GAIA.
- Vencimiento a un año (SGC): no implementado en SCA2 (doc 34 §3).
