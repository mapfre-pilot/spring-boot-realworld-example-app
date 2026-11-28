# SCA2: multiselección de argumentos en contraanulación

Implementado en Appian TEST. La selección múltiple ahorra pulsaciones; no cambia el contrato de CORE. Cada negativo se graba con una llamada individual a `IGestionarArgumentosPCA.guardarEjecuArg`, con las observaciones y el precio de su fila.

## Objetos

| Objeto | Antes → TEST | Cambio |
| --- | --- | --- |
| `SCA2_ContraAnulacionOpciones` | 84 → 85 → 86 | Habilitación, ejecución síncrona, reintento y argumento de cierre; v86 aplica al grid abierto las confirmaciones del proceso. |
| `SCA2_ContraAnulacionArgumentarioEstrategicas` | 7 → 8 → 9 | Selección múltiple de pendientes del nivel actual; v9 sincroniza la selección y el índice único usado por POSITIVO. |
| `SCA2_habilitacionArgumentosContraAnulacion` | Nuevo, v2 | Calcula filas ejecutables, habilitación y aviso de obligatorios. |
| `SCA2_ejecutarArgumentoNegativo` | Nuevo, v3 | Llama a la regla SOAP existente y considera confirmado el resultado de negocio `codigo = "2"` para un negativo. |
| `SCA2 CMD GuardarEjecucionArgumentos` | Nuevo, v2.0 | Múltiples instancias secuenciales; devuelve un resultado por argumento. Borrado de instancias al día y alertas a SCA2 Alertas. |
| `SCA2_PM_CMD_GUARDAR_EJECUCION_ARGUMENTOS` | Nueva, v1 | Referencia al proceso desde la interfaz. |
| `SCA2_obtenerArgumentoCierreContraAnulacion` | Nueva, v2 | Único punto de decisión del argumento que se envía al Cuadro de Gestión. |
| `SCA2_aplicarResultadosNegativosContraAnulacion` | Nueva, v1 | Calcula los tres vectores del grid, la selección pendiente y el último confirmado a partir de los resultados del PM. |

`SCA2_IF_ArgumentoAplicacionUrl` (v1), el SOAP existente y `SCA2 CMD CompletarAccion` no se modificaron. Opciones libera los enlaces Argumentario y Aplicación al invocar el grid; se mantienen los requisitos de documento y URL y el flujo de positivo, tréboles, finalizar y posponer, salvo el argumento enviado al Cuadro en el cierre.

## Reglas de selección y ejecución

| Selección de pendientes del nivel actual | POSITIVO | NEGATIVO |
| --- | --- | --- |
| Un obligatorio | Sí, si no hay otro positivo | Sí |
| Varios obligatorios sin opcionales | No | Sí |
| Obligatorios y opcionales, con todos los obligatorios pendientes seleccionados | No | Sí |
| Obligatorios y opcionales, sin seleccionar todos los obligatorios pendientes | No | No |
| Solo opcionales, con algún obligatorio pendiente | No | No |
| Solo opcionales, sin obligatorios pendientes (incluido un obligatorio positivo y el resto negativos) | Solo con una fila y sin positivo previo | Sí |

Si faltan obligatorios, ambos botones muestran un aviso. El estado pendiente `99` se admite; no habilita la reejecución de estados positivo o negativo. El proceso ejecuta primero los obligatorios y conserva los negativos confirmados aunque fallen otros. Si falla un obligatorio, los opcionales que dependen de él se omiten. Los fallidos y omitidos permanecen seleccionados para reintentar. Si vence la espera síncrona, la interfaz no presume el resultado y pide comprobar el proceso y reabrir la tarea antes de ejecutar de nuevo.

## Cuadro de Gestión

Se conserva una fila de cierre. En ambos caminos de FINALIZAR, el argumento proviene de `SCA2_obtenerArgumentoCierreContraAnulacion`, no de la selección. Para cambiar este criterio se edita esa regla y sus pruebas, sin cambiar el proceso de cierre. Con la pantalla abierta, se usa el último resultado negativo confirmado por el proceso en el nivel actual. Al reabrir, se recupera por `fecEjecutado` del mismo nivel.

**Límite al reabrir:** CORE devuelve la fecha con precisión de segundos, y devolvió en distinto orden dos negativos grabados en el mismo segundo. En ese caso la regla desempata por índice, no por orden real de confirmación. Para garantizar el último negativo también en ese empate, hace falta una secuencia persistente o una marca temporal de mayor precisión de CORE.

## Pruebas en TEST

- Reglas de Appian: `runAllExpressionRuleTestCases` de habilitación **20/20** y de cierre **5/5**; incluyen varios obligatorios, obligatorio positivo, positivo previo, `99` y exclusión de niveles anteriores.
- Proceso, instancia `16595705`: dos obligatorios sin DTO válido devolvieron `guardado=false`; el opcional devolvió `omitido=true`. No se llamó a CORE en este caso.
- Solicitud existente `15787842`, tarea `105`: se comprobó que respondían la gestión y el listado antes de ejecutar. Una llamada individual para el argumento `8` devolvió `codigo="2"` y el listado confirmó el negativo. En la instancia `9257605`, las llamadas para `9` y `346` devolvieron ambos `guardado=true`, y una lectura posterior confirmó los dos estados `2`. No se generó ninguna póliza ni se finalizó la gestión.
- `testInterface` de Opciones v85, solicitud `15787842`: diagnóstico sin error; grid de tipo `CHECKBOX`, sin límite de selección y con las filas ya ejecutadas deshabilitadas. `testInterface` del grid v8 sin errores con una fila anterior, una resuelta y dos pendientes. Estas comprobaciones no ejecutan el clic NEGATIVO ni reproducen un fallo de transporte SOAP.
- En la comprobación inicial en navegador se vieron los negativos persistidos en el detalle. La cuenta usada no ofreció **RETOMAR** para esa tarea, por lo que esa comprobación se limitó al detalle.

### Corrección de la actualización en pantalla (v86)

En la prueba de SISANS con la solicitud `15789155`, nivel 2, el PM `15577684` confirmó dos negativos, pero en Opciones v85 las filas seguían pendientes hasta reabrir. En v86, `onSuccess` lee `fv!processInfo.pv.resultados` (lista de Map) y guarda los vectores completos de estado, fecha y usuario, en vez de guardar celdas indexadas dentro de un bucle. Guarda también el último índice confirmado en el orden devuelto por el PM. Los fallidos u omitidos mantienen el estado y la selección y se muestra el aviso; el callback no sale del formulario.

En TEST, la regla de actualización pasó **5/5** casos guardados (incluidos éxito doble, fallo parcial y respuesta vacía). Al reproducir por `testRule` los resultados de la instancia `15577684`, las dos filas cambiaron a `"2"` con fecha y usuario, y la regla de cierre devolvió el último argumento confirmado, código `1`. `testInterface` de Opciones v86 para la tarea de nivel 2 (`15789155 / 907`) devolvió `ContentLayout` sin error y el grid mostró las dos filas resueltas como no seleccionables. Estas comprobaciones no disparan el callback desde el navegador.

Según comunicó ggalv10 el 2026-11-25, el equipo de TEST probó en la pantalla de contraanulación de Appian TEST los tres casos que quedaban pendientes: **varios obligatorios**, **positivo previo** y **fallo parcial de CORE**. Los tres funcionaron correctamente.

### Corrección de POSITIVO tras un salto de nivel (grid v9)

En la solicitud `15789371`, las instancias `12401337` y `833873` del PM confirmaron cuatro negativos del nivel anterior y tres del nivel actual, respectivamente. Quedó un argumento pendiente en la posición 8 de la lista completa. Opciones v86 habilitaba POSITIVO con la selección filtrada a las filas ejecutables, pero el grid v8 calculaba el índice único a partir de la selección sin filtrar, en guardados encadenados. Así, el botón podía estar habilitado y a la vez intentar guardar con un índice nulo (`Invalid index (-2147483647) for list: valid range is 1..8`).

Desde el grid v9, `selectionSaveInto` calcula la selección ejecutable, el índice único y el argumento a partir del mismo evento de selección, aplicando primero el desplazamiento por filas de niveles anteriores. Se conserva el `saveInto` de POSITIVO en Opciones v86 y no cambian NEGATIVO, POSPONER ni FINALIZAR.

En TEST se reprodujo el error de índice con una expresión de ocho filas que incluía una fila ya resuelta en la selección junto con la pendiente. Una selección sin esa fila no fallaba; con el filtro de v9 se obtuvo el índice 8 en ambos casos y al limpiar la selección no quedó ningún índice ni argumento. `testInterface` del grid v9 con ocho filas devolvió `ContentLayout` sin error. La regla de cierre devolvió el argumento de la posición 7 al recibirlo como último negativo confirmado. No se pulsó POSITIVO en una tarea real; no se capturó el evento original del navegador.
