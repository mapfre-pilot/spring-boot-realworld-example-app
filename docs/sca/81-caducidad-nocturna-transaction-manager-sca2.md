# 81 — Caducidad nocturna de SCA2 con Transaction Manager

**Estado a 26/11/2026: caducidad TM activa en Appian TEST.** `SCA2 CMD BarridoCaducidad` v11.0 sustituye el recorrido MNI por una única llamada síncrona a `SCA2 CMD Encolar Caducidad TM` (v5.0 publicada), sin filtro de IDs. Designer muestra en la v11.0 el mismo temporizador diario de las **01:00 Europe/Madrid**. El productor no tiene temporizador propio. Véase [caducidad por acción](72-caducidad-por-accion-sca2.md).

**Publicación y arranque inmediato:** al publicar `BarridoCaducidad` v11.0, Appian disparó un barrido a las **12:41 CET** (instancia `13463306`), sin lanzamiento manual. El productor `13463307` encoló **100** transacciones, que quedaron pendientes con el tipo 209 desactivado. No se observó ningún arranque de `Caducar TM` ni de `Caducar` tras la publicación. Tener en cuenta que publicar puede disparar el barrido de inmediato, sin esperar a las 01:00.

**Activación fuera de ventana, 12:54 CET:** `TM Toggle Job Type` activó el tipo 209 (instancia `269268429`). Las 100 transacciones quedaron completadas, con **0 pendientes y 0 en curso**. La comparación antes/después no encontró nuevas llamadas a CORE, nuevas instancias de `SCA2 CMD Caducar` ni cambios en las 100 solicitudes o en sus registros de llamadas, transiciones y errores. El productor podrá volver a encolarlas a las 01:00 si siguen siendo candidatas.

## Objetos y comportamiento de negocio

| Objeto nuevo en TEST | Versión / valor | Función |
| --- | --- | --- |
| `SCA2_caducidadTMCandidatas` | 1 | Copia el selector del nodo 6 del barrido v10.0. Páginas de 100, orden y cursor por `caducidadTarea, id`; filtro adicional opcional por identificador para revalidar y acotar el piloto. |
| `SCA2_caducidadTMVentana` | 1 | Calcula la apertura y la siguiente 01:00 en `Europe/Madrid`, con los cambios de horario de esa zona. |
| `SCA2_INT_CADUCIDAD_TM_HORA_FIN` | 3 / 7 | Hora local de cierre, excluida de la ventana. |
| `SCA2_INT_CADUCIDAD_TM_CONCURRENCIA` | 2 / 10 | Valor de referencia de `maxRunning`; TM almacena un número, no una referencia a la constante. |
| `SCA2 CMD Caducar TM` | 3.0 publicada | Recibe `idSolicitud` y `transaction`; revalida elegibilidad y ventana antes de llamar a `SCA2 CMD Caducar` en un subproceso síncrono. |
| `SCA2 CMD Encolar Caducidad TM` | 5.0 publicada | Resuelve el tipo por UUID del trabajador (209 en TEST), lee transacciones activas, recorre las candidatas y encola una lista por página. Parámetro opcional `idSolicitudes` para el piloto; sin temporizador. |

El barrido, el productor y el trabajador tienen autoborrado al día y alertas a `SCA2 Alertas`.

El selector exige plazo vencido, acción activa admitida y estado no excluido, exactamente como el barrido. Un cambio de plazo por posposición puede dejar la solicitud fuera al revalidar. No se toca `SCA2_calcularCaducidadAccion` ni el PM de negocio: primero CORE; si responde OK, se escribe `CADUCADA`, se cierra la tarea y se vacía el proceso activo; si falla, queda `ERROR`, con tarea y proceso activo, y se conservan auditoría y trazas. Una candidata que ya no cumple se omite y su transacción se completa. El cierre técnico de TM **no** significa que CORE haya dado OK. No se configura ningún reintento TM ni se reencola tras un fallo CORE; el selector de una noche posterior podría volver a elegirla con el mismo criterio vigente.

## Despacho, deduplicación y corte

1. El productor recorre el selector con el cursor del barrido y llama a `TM Add Transactions to Job Type` una vez por página con nuevas candidatas. El cursor avanza con la última fila **seleccionada**, incluso si toda la página se descarta por deduplicación. Cada entrada lleva `modelUuid` del trabajador y `context.idSolicitud`. El Job Type pasa el contexto y no usa microbatch.
2. Antes de encolar, el productor lee en Appian las transacciones `QUEUED` (1) y `RUNNING` (2) **de ese Job Type**, con una única consulta por página de 500, cursor por ID de transacción y sin filtro de fecha programada. Deduplica por `idSolicitud` decodificado de `contextJson` y añade los IDs que él mismo encola durante la ejecución. Lectura y alta no son atómicas: debe haber **un solo productor sin ejecuciones solapadas**; no se debe encolar por otro camino.
3. La ventana de negocio es **[01:00, 07:00) Europe/Madrid**. El trabajador comprueba la hora inmediatamente antes de invocar el CMD. Fuera de ventana completa su transacción TM, **sin CORE, sin escrituras de negocio y sin reprogramar**. Si la solicitud sigue cumpliendo el selector, el productor de la siguiente noche puede encolarla. Las instancias que ya entraron al CMD pueden terminar. Las transacciones todavía pendientes al desactivar el tipo no se cancelan; al reabrir se despachan y la deduplicación impide volver a encolarlas mientras sigan activas.
4. El Job Type 209 queda **habilitado de forma permanente** (`isActive=true`, `maxRunning=10`, paso de contexto habilitado); no hay apertura ni pausa automática. La ventana la aplica el trabajador, no el Job Type. Usar el PM público `TM Toggle Job Type` si se necesita cambiar su estado. No lanzar manualmente el productor mientras corre el barrido. TM selecciona y arranca en nodos distintos, por lo que un trabajo reservado al desactivar el tipo podría llegar igualmente al trabajador; fuera de ventana, el control de hora evita que ejecute el CMD.

**Incidencia CORE:** un administrador deshabilita únicamente `SCA2 Caducidad nocturna` en el sitio de Transaction Manager (no para TM global ni cancela las instancias ya iniciadas). Revisar traza CORE, cola y activos; mantener el tipo deshabilitado hasta que se recupere CORE y reanudar en una ventana nocturna autorizada. No reencolar fallos CORE.

## Capacidad y piloto

El 25/11 el batch intentó 203 solicitudes en 14 min 08 s (100 + 100 + 3, **14,36 intentos/min**, media de trabajador **4,16 s**, p95 **5,32 s**). Hubo 203 llamadas CORE con HTTP 500 y ningún cierre. Los datos son del batch en TEST, no de TM ni de CORE sano.

| Concurrencia | Intentos/min teóricos a 4,16 s | Intentos teóricos, 01:00–07:00 (6 h ordinarias) |
| ---: | ---: | ---: |
| 1 | 14,4 | 5 190 |
| 2 | 28,8 | 10 380 |
| 3 | 43,3 | 15 580 |
| 5 | 72,1 | 25 960 |
| 10 | 144,2 | 51 920 |

Son techos aproximados (`concurrencia × segundos de ventana / 4,16`), no cierres ni compromisos de capacidad. No incluyen sondeo de TM, esperas de cola, competencia con otros Job Types, latencia al cerrar correctamente o noches de cambio horario. `TM_BATCH_SIZE_MAX` vale 100 y `TM_BATCH_SLEEP_SEC` vale 5 en TEST; no se cambiaron. Para unas 200 candidatas en TEST, incluso extrapolando los **11,86 intentos/min** del piloto, serían unos **17 minutos** de intentos con concurrencia 2, frente a seis horas de ventana. Recomendar también 2 como punto de partida en PRO, solo tras medir con CORE sano. Subir de uno en uno si la cola no se vacía a tiempo y la latencia p95, los errores CORE y los tiempos de espera de Appian permanecen estables. Al ajustar, actualizar `maxRunning` del Job Type y mantener la constante SCA2 alineada; la constante sola no altera la concurrencia efectiva.

**Piloto TEST, 25/11/2026:** cuatro solicitudes de prueba ya en `ERROR` desde el barrido anterior: `15788800`, `15788804`, `15788812` y `15788816`. Se acotó el productor a esos IDs, de día, sin instancias activas del barrido ni cambios en su temporizador. La primera ejecución encoló 4 y la segunda 0 mientras las cuatro seguían pendientes y el tipo desactivado.

Fuera de ventana (constante en 7), las cuatro entradas `4857794–4857797` quedaron completadas. No arrancó el CMD de caducidad: los extractos de solicitudes, auditoría de llamadas y transiciones fueron idénticos antes y después. No se creó ninguna entrada de reemplazo. El límite de observación inicial fue de 36 s; se completaron dos trabajos, se desactivó el tipo y se habilitó de nuevo para drenar los otros dos sin volver a encolar.

Para probar la rama de negocio de día, se amplió **solo en TEST** la hora de fin de 7 a 14 (v2) y se comprobó que la regla devolvía ventana abierta. Un nuevo despacho manual de los mismos IDs creó 4 transacciones (`4857837–4857840`), todas completadas en TM. Hubo exactamente 4 llamadas a `SCA2 CMD Caducar` v10.0 y 4 llamadas a CORE con HTTP 500: las 4 solicitudes quedaron en `ERROR`, con un nuevo registro `SCA2 Error` por solicitud, acción activa y tarea pendiente, sin reintento. El máximo observado fue **2** concurrentes; se completaron **4 en 20,24 s** desde la activación del tipo (**11,86 intentos/min**), o **4 en 16,38 s** del inicio del primer trabajador al fin del último (**14,65 intentos/min**). Son cifras de una muestra de cuatro con CORE en error, no una prueba de carga.

Al terminar se desactivó el tipo, se restauró el corte a **07:00** (v3) y se comprobó que la ventana volvía a estar cerrada. Balance TM: **8 completadas, 0 pendientes, 0 en curso, 0 fallidas y 0 canceladas**. No se probó CORE OK, el solapamiento de dos productores ni la pausa programada bajo carga a las 07:00 reales.

## Primer barrido programado y correcciones del 26/11

- A las **01:00:01 CET**, el barrido v11.0 (`537704556`) lanzó al productor v4.0 (`537704557`), que encoló **100** y no volvió al nodo de selección. TM completó las 100 entre **01:00:12 y 01:01:11**; las 100 llamadas a CORE devolvieron HTTP 500 y las solicitudes quedaron en `ERROR`.
- Se reconstruyeron **211 candidatas a las 01:00** aplicando el mismo criterio de elegibilidad en datos de solo lectura y sustituyendo `now()` por el corte de esa noche. Faltaron **111** por encolar. La consulta posterior al selector con el cursor `caducidadTarea,id` devolvió **100 + 100 + 15 + 0**; cuatro vencían justo a las 01:00 y quedaban fuera del corte estricto.
- La v4.0 contaba directamente la salida de tipo genérico del nodo y dejó `leerMasCandidatas=false` aunque había encolado 100. La v5.0 cuenta una marca por fila con `a!forEach`, como el barrido v10.0, tanto para las candidatas como para las transacciones activas. Conserva los cursores y la deduplicación. Se verificaron las expresiones publicadas y el recorrido del selector en lectura; no se lanzó el productor corregido ni se republicó el barrido. Falta observar el primer barrido nocturno con v5.0.
- El pico de **20** trabajadores correspondió a la ejecución `9257598` de **TM Create or Update Job Type** del 25/11 a las **13:08 CET**, iniciada por `GGALV10@mapfre.net`. Fue posterior e independiente del script de activación, que había usado **TM Toggle Job Type** (`269268429`) con **2**. El proceso público **TM Create or Update Job Type** `15581164` restauró `maxRunning=2`, con el tipo 209 activo y el paso de contexto intacto, alineado con la constante SCA2.
- Las instancias antiguas `17635149` (v3.0) y `269268287` (v2.0) eran pruebas con un ID ficticio y **0** transacciones encoladas. Se cancelaron en Designer TEST (no se eliminaron); se verificó `CANCELLED` en ambas.
- Por decisión de ggalv10, el **26/11** se subió la concurrencia en TEST a **10** con `TM Create or Update Job Type` (`15581670`, completado) y se verificó el mismo valor en la constante SCA2 v2. Se conservaron la activación y el paso de contexto del tipo 209. Queda por revisar en el barrido del **27/11** la concurrencia observada, el tiempo de vaciado y el volumen, los errores y la latencia de CORE; la capacidad a 10 de la tabla es teórica, no una medición.

## Vuelta al barrido anterior en TEST

1. Deshabilitar el Job Type 209 con `TM Toggle Job Type` (`isActive=false`). No ejecutar el productor manualmente. Confirmar que no queda ninguna instancia activa de `BarridoCaducidad`, del productor ni del trabajador TM; si las hay, esperar antes de volver a publicar.
2. Conciliar en TM las transacciones de ese tipo que sigan pendientes: identificarlas por solicitud y cancelarlas con el mecanismo de TM antes de volver a habilitar este tipo en el futuro. No reenviar transacciones finalizadas y no reintentar errores CORE.
3. En Appian Designer TEST, abrir `SCA2 CMD BarridoCaducidad` → **Archivo → Versiones…**, seleccionar **v10.0** y pulsar **Cargar**. Usar **Archivo → Guardar y publicar** para publicar su contenido como una nueva versión del **mismo modelo**; no crear una copia con otro temporizador. La referencia de recuperación es `~/memory/appian_91b2ca/files/sca2-caducidad-tm/antes-barrido-caducidad-v10.0.json` (SHA-256 `b972469e30d1ce622ad5be0730fa0df1bc090bbb4cdf5747ad1e97ab75ab8551`). El JSON de MCP no contiene la configuración del temporizador: usar la versión de Designer para recuperarla. Como el temporizador se disparó fuera de hora al publicar v11.0, republicar v10.0 **solo en la ventana nocturna**.
4. Abrir la versión publicada y comprobar que el Start tiene un único disparo diario a las **01:00 Europe/Madrid**, que reaparecen la consulta, el MNI de `SCA2 CMD Caducar` y el encadenado por cursor, y que no hay llamada al productor. Mantener desactivado el Job Type 209.
