# 81 — Caducidad nocturna de SCA2 con Transaction Manager

**Estado a 25/11/2026: preparación en Appian TEST, sin cambio de despachador.** El Job Type `SCA2 Caducidad nocturna` (ID 209) se registró desactivado. No se encolaron solicitudes ni se ejecutó caducidad por TM. Siguen activos, sin cambios, el temporizador de las 01:00 de `SCA2 CMD BarridoCaducidad` v10.0 y su llamada MNI a `SCA2 CMD Caducar` v10.0. Véase [caducidad por acción](72-caducidad-por-accion-sca2.md).

## Objetos y comportamiento de negocio

| Objeto nuevo en TEST | Versión / valor | Función |
| --- | --- | --- |
| `SCA2_caducidadTMCandidatas` | 1 | Copia el selector del nodo 6 del barrido v10.0. Páginas de 100, orden y cursor por `caducidadTarea, id`; filtro adicional opcional por identificador para revalidar y acotar el piloto. |
| `SCA2_caducidadTMVentana` | 1 | Calcula la apertura y la siguiente 01:00 en `Europe/Madrid`, con los cambios de horario de esa zona. |
| `SCA2_INT_CADUCIDAD_TM_HORA_FIN` | 1 / 7 | Hora local de cierre, excluida de la ventana. |
| `SCA2_INT_CADUCIDAD_TM_CONCURRENCIA` | 1 / 2 | Valor inicial de referencia de `maxRunning`; TM almacena un número, no una referencia a la constante. |
| `SCA2 CMD Caducar TM` | 2.0 publicada | Recibe `idSolicitud` y `transaction`; revalida elegibilidad y ventana antes de llamar a `SCA2 CMD Caducar` en un subproceso síncrono. Autoborrado al día y alertas configuradas para `SCA2 Alertas`. |

El selector exige plazo vencido, acción activa admitida y estado no excluido, exactamente como el barrido. Un cambio de plazo por posposición puede dejar la solicitud fuera al revalidar. No se toca `SCA2_calcularCaducidadAccion` ni el PM de negocio: primero CORE; si responde OK, se escribe `CADUCADA`, se cierra la tarea y se vacía el proceso activo; si falla, queda `ERROR`, con tarea y proceso activo, y se conservan auditoría y trazas. Una candidata que ya no cumple se omite y su transacción se completa. El cierre técnico de TM **no** significa que CORE haya dado OK. No se configura ningún reintento TM ni se reencola tras un fallo CORE; el selector de una noche posterior podría volver a elegirla con el mismo criterio vigente.

## Despacho, deduplicación y corte pendientes de validar

1. Un único productor de SCA2 recorrerá el selector con el cursor del barrido y enviará a `TM Add Transactions to Job Type` una lista por página, sin crear un encolador hijo por solicitud. El cursor avanza con la última fila **seleccionada**, incluso si toda la página se descarta por deduplicación. Cada entrada lleva `modelUuid` del trabajador y `context.idSolicitud`. El Job Type tiene paso de contexto habilitado y no usa microbatch.
2. Antes de encolar, el productor debe excluir los identificadores que ya estén en estado `QUEUED` (1) o `RUNNING` (2) **de ese Job Type**, incluso si su fecha programada es mañana. TM almacena el contexto en `contextJson`; comparar el `idSolicitud` decodificado, no subcadenas del JSON. `TM_getTransactionsByStatusAndId` requiere una lectura por estado y paginación; no basta la primera página. Preferir una lectura paginada por ejecución con un conjunto de identificadores, actualizarlo tras cada página encolada y mantener un solo productor autorizado. Lectura y alta son operaciones separadas: esto no da una garantía atómica contra dos productores ni contra un traspaso no coordinado entre transacciones.
3. Habilitar el Job Type solo entre **01:00 y 07:00 (Europe/Madrid)**; al cierre, desactivarlo por el mecanismo de TM, sin cancelar pendientes ni terminar procesos activos. Al reabrir, los pendientes de la noche anterior tienen que seguir disponibles. TM selecciona el lote en un nodo y lo arranca en otro: desactivar el tipo no demuestra por sí solo que no arranque un proceso que ya estaba reservado. Hay que comprobar el comportamiento al corte con el tipo bajo carga antes de cualquier activación productiva.
4. La v2.0 comprueba la hora inmediatamente antes de invocar el negocio. Si una candidata ya fue entregada al trabajador fuera de ventana, la v2.0 intenta programar otra entrada para la siguiente 01:00 y luego completar la original, sin invocar CORE. Es un aplazamiento **previo** al primer intento, no un reintento de CORE; las dos operaciones no son atómicas y su convivencia con la deduplicación no se ha probado. **No se debe activar el tipo basándose solo en esta rama**: queda pendiente demostrar el corte de despacho y decidir cómo preservar una entrega tardía sin ventana de duplicación. Las solicitudes que ya iniciaron el CMD antes del corte deben poder terminar normalmente.

**Incidencia CORE:** un administrador deshabilita únicamente `SCA2 Caducidad nocturna` en el sitio de Transaction Manager (no para TM global ni cancela las instancias ya iniciadas). Revisar traza CORE, cola y activos; mantener el tipo deshabilitado hasta que se recupere CORE y reanudar en una ventana nocturna autorizada. Después de implantar el ciclo horario, la pausa por incidencia debe prevalecer sobre la apertura automática. No reencolar fallos CORE.

## Capacidad y piloto

El 25/11 el batch intentó 203 solicitudes en 14 min 08 s (100 + 100 + 3, **14,36 intentos/min**, media de trabajador **4,16 s**, p95 **5,32 s**). Hubo 203 llamadas CORE con HTTP 500 y ningún cierre. Los datos son del batch en TEST, no de TM ni de CORE sano.

| Concurrencia | Intentos/min teóricos a 4,16 s | Intentos teóricos, 01:00–07:00 (6 h ordinarias) |
| ---: | ---: | ---: |
| 1 | 14,4 | 5 190 |
| 2 | 28,8 | 10 380 |
| 3 | 43,3 | 15 580 |
| 5 | 72,1 | 25 960 |

Son techos aproximados (`concurrencia × segundos de ventana / 4,16`), no cierres ni compromisos de capacidad. No incluyen sondeo de TM, esperas de cola, competencia con otros Job Types, latencia al cerrar correctamente o noches de cambio horario. `TM_BATCH_SIZE_MAX` vale 100 y `TM_BATCH_SLEEP_SEC` vale 5 en TEST; no se cambiaron. Arrancar con 2 en TEST y, solo si se valida CORE sano, recomendar también 2 como punto de partida en PRO. Subir de uno en uno si la cola no se vacía a tiempo y la latencia p95, los errores CORE y los tiempos de espera de Appian permanecen estables. Al ajustar, actualizar `maxRunning` del Job Type y mantener la constante SCA2 alineada; la constante sola no altera la concurrencia efectiva.

**Comprobado en TEST:** seis pruebas de la regla de ventana pasaron; la consulta al selector con un ID inexistente devolvió cero filas sin error; el trabajador v2.0 terminó con un contexto sin ID de transacción (sin entrar en el camino de negocio); el PM de alta de TM terminó y la búsqueda por PM confirmó el Job Type 209. No se midió concurrencia efectiva ni rendimiento de TM. Pendientes: productor y deduplicación, pausa/apertura operativas y ensayo del límite, corrida nocturna controlada con candidatas aisladas del batch, CORE OK y ERROR, cierre de transacciones y ausencia de reintento. La comprobación genérica `listRecordData` de TM falló con HTTP 500 (`Headers cannot be null or empty`); el alta se verificó con la regla de búsqueda por modelo de TM.

**Cambio de despachador, con aprobación aparte:** primero reservar un pequeño conjunto que el barrido v10.0 no pueda seleccionar en la misma noche (sin cambiar su lógica ni ejecutar dos caminos para las mismas solicitudes); probar por la noche con el tipo habilitado solo para el intervalo autorizado; registrar pendientes, máximos activos, llamadas y transiciones por ID. Solo tras validar eso, el corte y la deduplicación, sustituir el MNI de las 01:00 por el único productor TM. Para volver al batch, primero detener el productor y deshabilitar el Job Type, esperar a los trabajadores activos y conciliar los pendientes antes de volver a activar el despacho antiguo.
