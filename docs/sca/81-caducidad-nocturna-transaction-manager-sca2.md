# 81 — Caducidad nocturna de SCA2 con Transaction Manager

**Estado a 25/11/2026: piloto en Appian TEST, sin cambio de despachador.** El Job Type `SCA2 Caducidad nocturna` (ID 209) está desactivado y el productor nuevo no tiene temporizador. El único despacho programado sigue siendo `SCA2 CMD BarridoCaducidad` v10.0 a las 01:00, con su llamada MNI intacta a `SCA2 CMD Caducar` v10.0. Véase [caducidad por acción](72-caducidad-por-accion-sca2.md).

## Objetos y comportamiento de negocio

| Objeto nuevo en TEST | Versión / valor | Función |
| --- | --- | --- |
| `SCA2_caducidadTMCandidatas` | 1 | Copia el selector del nodo 6 del barrido v10.0. Páginas de 100, orden y cursor por `caducidadTarea, id`; filtro adicional opcional por identificador para revalidar y acotar el piloto. |
| `SCA2_caducidadTMVentana` | 1 | Calcula la apertura y la siguiente 01:00 en `Europe/Madrid`, con los cambios de horario de esa zona. |
| `SCA2_INT_CADUCIDAD_TM_HORA_FIN` | 3 / 7 | Hora local de cierre, excluida de la ventana. |
| `SCA2_INT_CADUCIDAD_TM_CONCURRENCIA` | 1 / 2 | Valor inicial de referencia de `maxRunning`; TM almacena un número, no una referencia a la constante. |
| `SCA2 CMD Caducar TM` | 3.0 publicada | Recibe `idSolicitud` y `transaction`; revalida elegibilidad y ventana antes de llamar a `SCA2 CMD Caducar` en un subproceso síncrono. |
| `SCA2 CMD Encolar Caducidad TM` | 4.0 publicada | Resuelve el tipo por UUID del trabajador (209 en TEST), lee transacciones activas, recorre las candidatas y encola una lista por página. Parámetro opcional `idSolicitudes` para el piloto; sin temporizador. |

Los dos PM de SCA2 tienen autoborrado al día y alertas a `SCA2 Alertas`.

El selector exige plazo vencido, acción activa admitida y estado no excluido, exactamente como el barrido. Un cambio de plazo por posposición puede dejar la solicitud fuera al revalidar. No se toca `SCA2_calcularCaducidadAccion` ni el PM de negocio: primero CORE; si responde OK, se escribe `CADUCADA`, se cierra la tarea y se vacía el proceso activo; si falla, queda `ERROR`, con tarea y proceso activo, y se conservan auditoría y trazas. Una candidata que ya no cumple se omite y su transacción se completa. El cierre técnico de TM **no** significa que CORE haya dado OK. No se configura ningún reintento TM ni se reencola tras un fallo CORE; el selector de una noche posterior podría volver a elegirla con el mismo criterio vigente.

## Despacho, deduplicación y corte

1. El productor recorre el selector con el cursor del barrido y llama a `TM Add Transactions to Job Type` una vez por página con nuevas candidatas. El cursor avanza con la última fila **seleccionada**, incluso si toda la página se descarta por deduplicación. Cada entrada lleva `modelUuid` del trabajador y `context.idSolicitud`. El Job Type pasa el contexto y no usa microbatch.
2. Antes de encolar, el productor lee en Appian las transacciones `QUEUED` (1) y `RUNNING` (2) **de ese Job Type**, con una única consulta por página de 500, cursor por ID de transacción y sin filtro de fecha programada. Deduplica por `idSolicitud` decodificado de `contextJson` y añade los IDs que él mismo encola durante la ejecución. Lectura y alta no son atómicas: debe haber **un solo productor sin ejecuciones solapadas**; no se debe encolar por otro camino.
3. La ventana de negocio es **[01:00, 07:00) Europe/Madrid**. El trabajador comprueba la hora inmediatamente antes de invocar el CMD. Fuera de ventana completa su transacción TM, **sin CORE, sin escrituras de negocio y sin reprogramar**. Si la solicitud sigue cumpliendo el selector, el productor de la siguiente noche puede encolarla. Las instancias que ya entraron al CMD pueden terminar. Las transacciones todavía pendientes al desactivar el tipo no se cancelan; al reabrir se despachan y la deduplicación impide volver a encolarlas mientras sigan activas.
4. El PM público `TM Toggle Job Type` permite habilitar o deshabilitar el tipo por separado y se usó durante el piloto. El MCP de TEST admite publicar PMs, pero no expone la configuración de temporizadores de inicio de PM; no quedó habilitado un programador de apertura/cierre. Para el cambio aprobado, configurar el disparo diario del productor a las 01:00 en Appian Designer, zona Europe/Madrid y `idSolicitudes` vacío. Configurar la apertura del tipo antes del productor y su pausa a la hora local de la constante (07:00 por defecto) usando el mecanismo de TM; sincronizar programación y constante si se cambia el corte. No habilitar esos disparos mientras el barrido v10 siga programado. TM selecciona y arranca en nodos distintos, por lo que un trabajo reservado al desactivar el tipo podría llegar igualmente al trabajador; el control de hora evita entonces ejecutar el CMD.

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

**Piloto TEST, 25/11/2026:** cuatro solicitudes de prueba ya en `ERROR` desde el barrido anterior: `15788800`, `15788804`, `15788812` y `15788816`. Se acotó el productor a esos IDs, de día, sin instancias activas del barrido ni cambios en su temporizador. La primera ejecución encoló 4 y la segunda 0 mientras las cuatro seguían pendientes y el tipo desactivado.

Fuera de ventana (constante en 7), las cuatro entradas `4857794–4857797` quedaron completadas. No arrancó el CMD de caducidad: los extractos de solicitudes, auditoría de llamadas y transiciones fueron idénticos antes y después. No se creó ninguna entrada de reemplazo. El límite de observación inicial fue de 36 s; se completaron dos trabajos, se desactivó el tipo y se habilitó de nuevo para drenar los otros dos sin volver a encolar.

Para probar la rama de negocio de día, se amplió **solo en TEST** la hora de fin de 7 a 14 (v2) y se comprobó que la regla devolvía ventana abierta. Un nuevo despacho manual de los mismos IDs creó 4 transacciones (`4857837–4857840`), todas completadas en TM. Hubo exactamente 4 llamadas a `SCA2 CMD Caducar` v10.0 y 4 llamadas a CORE con HTTP 500: las 4 solicitudes quedaron en `ERROR`, con un nuevo registro `SCA2 Error` por solicitud, acción activa y tarea pendiente, sin reintento. El máximo observado fue **2** concurrentes; se completaron **4 en 20,24 s** desde la activación del tipo (**11,86 intentos/min**), o **4 en 16,38 s** del inicio del primer trabajador al fin del último (**14,65 intentos/min**). Son cifras de una muestra de cuatro con CORE en error, no una prueba de carga.

Al terminar se desactivó el tipo, se restauró el corte a **07:00** (v3) y se comprobó que la ventana volvía a estar cerrada. Balance TM: **8 completadas, 0 pendientes, 0 en curso, 0 fallidas y 0 canceladas**. No se probó CORE OK, el solapamiento de dos productores ni la pausa programada bajo carga a las 07:00 reales.

**Cambio de despachador, con aprobación aparte:** cerrar las comprobaciones pendientes y probar los disparos y el corte con el reloj real. Sustituir el MNI programado de las 01:00 por el único productor TM, sin solapar despachadores. Para volver al batch, primero detener el productor y deshabilitar el Job Type, esperar a los trabajadores activos y conciliar los pendientes antes de volver a activar el despacho antiguo.
