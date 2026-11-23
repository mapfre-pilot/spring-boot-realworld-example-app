# 72 — Caducidad por acción y barrido nocturno de SCA2

**Estado (23/11/2026): cambios publicados en Appian TEST, sin temporizador.** Se modificaron únicamente objetos de diseño SCA2. SCA se revisó en solo lectura; no se modificaron SCA, SCAC ni CORE. No se ejecutó el barrido ni se actualizaron solicitudes existentes.

## 1. Qué hace SCA

| Evidencia en TEST | Comportamiento comprobado en la definición |
|---|---|
| `SCA Batch Caducidad Previo` v8.0, nodos 2 y 8 | Selecciona filas de `SCA solicitudAnulacion` con `caducidadtarea` no vacía y `todatetime(caducidadtarea) < now()`. No filtra por estado. Despacha el PM trabajador por fila mediante múltiples instancias. |
| `SCA Batch Caducidad` v7.0, nodo 11 | Decide por `procesoactivo` y los doce primeros valores de `SCA_TXT_ACCIONES`: autorización (nodo 32; `mcaAutorizada = "N"`, `codEstado = "5"`), mecanización (2), contraanulación (16) y acciones administrativas (23), en los niveles 1 a 3. La rama por defecto (5) solo marca la transacción TM como completa; no finaliza la solicitud. |
| `SCA Batch Caducidad` v7.0, nodos 21–22 y 40–41 | En error escribe el mensaje y `caducidadtarea = tostring(today()+1)`. En la ruta de éxito llama a finalizar y a `SCA Eliminar Tablas BBDD` v6.0, que borra la fila operativa en el nodo 6. |
| `SCA Alta Mecanización` v4.0, nodo 17; `SCA Alta Contra Anulacion` v8.0, nodos 10/13 | Informan la fecha en el record operativo. Al posponer, `SCA Autorización` v113.0 (20) y `SCA Acciones Administrativas` v137.0 (19) invocan `SCA_obtenerCaducidadNivel` con `mecanizar: false` y `nivel: "2"`. Esa regla v7 devuelve 7 o 15 días según perfil; no era una regla general de siete días. |

**Datos de solo lectura:** 497 filas únicas de `SCA solicitudAnulacion`; 133 con plazo, 131 vencidas al corte (23/11/2026, 10:39 CET). De las vencidas, 121 coincidían con una rama de caducidad: 80 `CONTRAANULAR`, 30 `CONTRA ANULAR NIVEL 2` y 11 `MECANIZAR`. Las otras 10 quedaban en la rama por defecto: 6 `FIN PROCESO`, 2 `ERROR` y 2 sin acción. `estadosolicitud` estaba vacío tanto en esas 497 filas como en las 542 de `SCA datosSolicitud`. Son coincidencias con la definición, no caducidades observadas en ejecución.

En SCA2 había una `DECIDIDA` y una `PDTE_FINALIZAR` vencidas cuyas acciones sí coincidían. No había filas vencidas que confirmaran por estado `PENDIENTE`, `ALTA` o `PENDIENTE_AUTORIZACION`, aunque autorización sí tiene rama en SCA. Un filtro solo por estado habría seleccionado 201 filas, incluidas 16 con estados de error y acción que SCA no tramita. Por eso se usa la acción efectiva y no una lista de estados abiertos.

## 2. `SCA2 CMD BarridoCaducidad` v8.0

El nodo 6 conserva `caducidadTarea < now()` e incluye solo estos valores de `procesoActivo`:

| Familia | Valores |
|---|---|
| Autorización | `AUTORIZACION`, `AUTORIZACION NIVEL 2`, `AUTORIZACION NIVEL 3` |
| Mecanización | `MECANIZAR`, `MECANIZAR NIVEL 2`, `MECANIZAR NIVEL 3` |
| Contraanulación | `CONTRAANULAR`, `CONTRA ANULAR NIVEL 2`, `CONTRA ANULAR NIVEL 3` |
| Acciones administrativas | `ACCIONES ADMINISTRATIVAS`, `ACCIONES ADMINISTRATIVAS NIVEL 2`, `ACCIONES ADMINISTRATIVAS NIVEL 3` |

Los valores se copiaron en SCA2 sin crear una dependencia de SCA. Se excluyen `FINALIZADA*`, `CANCELADA`, `CADUCADA`, `CADUCADA_NEGATIVA` y `MECANIZADA`. Un estado vacío no excluye la fila si cumple fecha y acción. `MECANIZADA` se escribe junto con `procesoActivo = "ANL"` en `CMD Mecanizar` v52.0, nodo 13; ANL no es una rama de caducidad en SCA.

La v8 conserva el procesamiento por lotes de la v7: hasta 100 filas por consulta, ordenadas por `caducidadTarea ASC, id ASC`. Para continuar se usa el cursor `fecha > fechaCursor OR (fecha = fechaCursor AND id > idCursor)`. El nodo 7 invoca `CMD Caducar` de forma secuencial, una vez por ID. Si el lote está lleno, los nodos 8–9 lanzan el siguiente lote de forma asíncrona. La lectura explícita de v8.0 y `listProcessModelNodes` coincidieron en los siete nodos y sus conexiones; respecto a v7 solo cambió la expresión `rows` del nodo 6.

### Recuento del selector en solo lectura

En 404 filas únicas de `SCA2 Solicitud` (23/11/2026, 10:44 CET), el filtro original devolvía **284** candidatas antes del límite; la v7, **179**; y la v8, **185** en lotes de **100 + 85**, sin saltos ni duplicados al comprobar el cursor sobre los datos leídos.

| Estado | Candidatas v8 |
|---|---:|
| `EN_ACCION` | 165 |
| `PDTE_MECANIZAR` | 14 |
| `ERROR` | 3 |
| `ERROR_DECISION` | 1 |
| `DECIDIDA` | 1 |
| `PDTE_FINALIZAR` | 1 |
| **Total** | **185** |

Frente al filtro original salen 66 `FINALIZADA_POSITIVO`, 26 `CANCELADA`, 6 `ERROR_DECISION` sin acción admitida y 4 `MECANIZADA`; entran 3 `ERROR` con acción admitida. Esta comprobación no ejecutó el PM ni llamó a `CMD Caducar`.

## 3. Caducidad por acción en SCA2

La decisión funcional confirmada sustituye el cálculo previo [por nivel](43-A-caducidad-por-nivel.md) al entrar en una acción: **23:59:59 de Europe/Madrid** del día de entrada. En cada nuevo posponer válido se recalcula para **las 23:59:59 del séptimo día natural posterior**, no como una suma fija de 168 horas. Si se dispone de un vencimiento de póliza anterior, se conserva ese tope como `todatetime(fechaVencimiento)`.

| Objeto publicado en TEST | Cambio |
|---|---|
| `SCA2_calcularCaducidadAccion` v1 | Regla pura. Devuelve un `Date and Time`; acepta instante base opcional (por defecto `now()`), indicador de posponer y fecha de póliza opcional. |
| `SCA2 CMD Alta` v50.0 | Nodo 9: sustituye el cálculo por nivel al escribir `Solicitud.caducidadTarea`. |
| `SCA2 CMD CrearAccion` v34.0 | Nodos 7 y 9: guarda la nueva fecha de solicitud al abrir la acción humana o pasar a `PDTE_MECANIZAR`. |
| `SCA2 CMD Posponer` v21.0 | Nodo 5: recalcula `Solicitud.caducidadTarea`. No cambia fecha de dietario, contador, idempotencia ni fecha propia de la tarea. |

Se mantiene el cálculo transitorio del nodo 11 de `CrearAccion` al pasar a decisión o fin, porque en ese nodo todavía no se abre una tarea. Los nodos 7 y 9 escriben el nuevo plazo cuando se abre la acción. Tampoco se cambiaron `SCA2_obtenerCaducidadNivel`, las fechas de tarea y de dietario, ni los flujos de mecanización y VERTI que usan esas fechas. `SCA2_DetalleTareas` lee la fecha propia de la tarea; `SCA2_CuadroMando` no referencia directamente esos campos en la versión revisada.

### Pruebas de la regla

`testRule`: **7/7** resultados esperados, todos de tipo `Date and Time`, sin errores. Resultados en UTC:

| Caso | Resultado |
|---|---|
| Entrada el 23/11, sin tope | `2026-11-23 22:59:59` |
| Entrada a las 23:30 UTC del 23/11 (ya día 24 en Madrid) | `2026-11-24 22:59:59` |
| Posponer el 28/03, cruzando el cambio de primavera | `2026-04-04 21:59:59` |
| Volver a posponer el 01/04 | `2026-04-08 21:59:59` |
| Posponer el 28/03 con póliza hasta el 01/04 | `2026-04-01 00:00:00` |
| Posponer el 24/10, cruzando el cambio de otoño | `2026-10-31 22:59:59` |
| Entrada el 29/03, día del cambio de primavera | `2026-03-29 21:59:59` |

`getProcessModel` con versión explícita y `listProcessModelNodes` coincidieron en las conexiones de los 23, 40 y 12 nodos de Alta, CrearAccion y Posponer. Respecto a las versiones anteriores solo cambiaron las expresiones de escritura indicadas. No se ejecutaron los PMs para validar el cambio.

## 4. Pendientes antes de activar

1. **Revisar la v8.0 publicada en Designer**, en particular Start, las ramas del nodo 3 y los nodos 7–9. En v7 la vista sin versión del MCP devolvió una conexión residual que no aparecía en la versión publicada; la comprobación del grafo v8 hasta ahora se hizo por MCP, no visualmente.
2. **Decidir qué hacer con las 185 solicitudes ya vencidas** del corte de TEST. No se han procesado ni modificado. El número es una foto del corte, no un recuento permanente.
3. **Acordar la programación nocturna y activar el temporizador solo después** de la revisión y de la decisión sobre el acumulado. No hay temporizador configurado para este barrido en TEST.
