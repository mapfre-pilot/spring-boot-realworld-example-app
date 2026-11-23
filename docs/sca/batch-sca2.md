# Batches SCA2 en Appian TEST

| Batch SCA con timer de inicio | Programación en SCA | Estado en SCA2 |
|---|---|---|
| [Mecanización NSE](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=15854) | Diario a las 02:30, zona configurada en el modelo | [Equivalente en SCA2](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=4198), sin timer y con interruptor desactivado. |
| [Reserva Prima SGO](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=14622) | Diario a las 00:10 UTC | [Batch](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=6075) y [trabajador](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=6121) sobre cola propia; ambos sin timer, con interruptor desactivado y sin productor. SCA mantiene la ejecución y el volcado. |

## Resumen operativo

[Gestiones mantenimiento → Batch](https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/gestiones-mantenimiento) muestra el estado de habilitación y las últimas 25 ejecuciones visibles de los dos modelos de SCA2, con su estado, inicio, fin e identificador. Es de solo lectura y respeta los permisos de Process Analytics. El estado es el del proceso, no el de cada solicitud; tampoco es un histórico tras la limpieza de instancias ni incluye las ejecuciones de SCA.

## Reserva Prima

- La cola `SCA2 Cola Reserva Prima` usa `sca2_anulaciones.sca2_cola_reserva_prima`. Conserva el filtro por fecha y estado pendiente, el lote de 30 y el lanzamiento paralelo de trabajadores. La consulta selecciona explícitamente los once campos que SCA pasa al trabajador, incluidos ambos datos de anulación; si no se indica la lista, Appian entrega solo el ID. Los marcados como ejecutados se escriben en esa misma cola.
- Se preservaron las llamadas compartidas de observaciones y alta en ANL, los correos y el reencolado en Transaction Manager tras 10 minutos. No se modificaron sus objetos originales ni se registró un nuevo productor.
- El correo diario reutiliza una sola consulta y recupera solo el campo que lista; conserva el límite de 5.000 filas de SCA, por el que Appian emite una advertencia. No se copió el valor de ejemplo que tenía el trabajador SCA: la entrada real viene del batch.
- Antes de autorizar el corte: probar con datos sintéticos en un circuito aislado el alta con evento de ANL, el correo, la transacción TM y la escritura en cola. Los nodos de escritura y arranque usan las versiones disponibles en TEST; sus efectos reales no se han ejecutado. Acordar el traspaso del volcado y la programación sin que convivan dos consumidores.
- Propuesta, no aplicada: evaluar transacciones TM por ítem con clave idempotente y reintento solo de fallos, para evitar reencolar el batch entero tras cada lote. Si se necesita histórico de operación más allá de Process Analytics, evaluar un registro específico de ejecuciones de SCA2.

## Validación aislada en TEST

- **Mecanización NSE:** la versión 4.0 del modelo filtra por `origenPoliza` en las expresiones de selección y recuento. Conserva `MECANIZADA`, `ANL` y el máximo de 500. Se evaluó la expresión publicada en modo lectura, sin errores ni candidatas en TEST; no se llamó al trabajador. La prueba funcional necesita una solicitud de TEST con póliza NSE que CORE y ANL puedan procesar y que el barrido de SCA excluya.
- **Reserva Prima:** la proyección se verificó con tres filas sintéticas. Solo se devolvió la vencida pendiente, con sus datos de anulación; se excluyeron la futura y la ya ejecutada. Se retiraron las tres filas y la cola quedó vacía. El buzón de CCR y los destinatarios del informe siguen siendo los de SCA; no se ha verificado un buzón de captura accesible. Transaction Manager tiene registrado el modelo SCA, no el de SCA2.
- **Estado operativo sin cambios:** ambos interruptores siguen apagados. No se cambiaron los temporizadores, el volcado ni el Transaction Manager. No se escribieron datos de negocio en CORE ni ANL ni se enviaron correos.
