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
| CONTINUAR → mecanizar | FALLABA 1: la 2.ª ejecución de CMD Mecanizar se descartaba por idempotencia (la tarea VERTI escribía la transición OK) → corregido en el proceso. FALLABA 2: «only one smart service can be run per expression evaluation» (insertarObservaciones + startProcess) → v6/v7 encadenan inducción → mecanizar y pasan las observaciones al proceso. Resultado de la reprueba final: ver §3 |
| Comparación SCA | No probado: sin solicitud SCA en mecanización; póliza 0000023400744 tiene ya la solicitud 15788045 |

## 3. Pendientes de prueba
- Reprueba final de CONTINUAR en 15788025 con v7 (se anota al cerrar la ronda).
- ANULAR PÓLIZA → ACEPTAR → pantalla de inducción en la misma cadena (DetalleTareas v25) con una solicitud nueva en MECANIZAR.
- Efecto real de la inducción (PM CMP Inducir Cliente Completo) en GAIA/Verti: sólo comprobable desde Verti/GAIA.
- Vencimiento a un año (SGC): no implementado en SCA2 (doc 34 §3).
