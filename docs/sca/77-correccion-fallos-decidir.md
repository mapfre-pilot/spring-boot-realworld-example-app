# SCA2 — Corrección de instancias paradas en Decidir

Appian TEST, 23/11/2026. Se publicó `SCA2 CMD Decidir` **v32.0**. Solo se modificó ese modelo; antes se guardó una copia privada del diseño publicado v25.0 y de sus nodos, sin datos de solicitudes.

## Causa y corrección

Desde su v2, `SCA2_consultarServiciosReglas` devuelve texto en `error` si falla la consulta HTTP. El nodo 5, «Consultar reglas», intentaba asignar ese texto a `pv!errorDecision` (Map). Appian detenía la ejecución con `rank (Data Outputs)` antes de que el flujo pudiera registrar `DECISION_ERROR`.

La salida `errorDecision` ahora envuelve el texto en `a!map(mensaje: local!error)` y conserva los mapas y nulos. Se tradujeron y distinguieron las seis etiquetas de verificación y captura de errores de escritura de Detalle, SGO y Mecanización. No cambiaron las conexiones, las variables, el literal «Consultar reglas» ni la lógica de decisión y reintento.

Tras publicar se comprobó que se conservan el borrado automático **1 día después de terminar** y el grupo **SCA2 Alertas** como destinatario. La publicación no cambia las instancias ya iniciadas.

## Validación

| Prueba en TEST | Resultado |
|---|---|
| `validateExpression`, salida v25 con error de texto sintético | Reproduce `CastInvalid` de Text a Map. |
| `validateExpression`, salida publicada con texto, mapa y nulo | Sin errores; conserva el mensaje, el mapa existente y el nulo, respectivamente. |
| `testRule`, consulta normal con las mismas entradas antes y después, y evaluación de las salidas publicadas | Mismo resultado: `CONTRAANULAR`, sin error, grupo ni subgrupo. |

No se ejecutó un proceso completo ni se forzó un fallo en servicios externos: se usaron la consulta de reglas en modo lectura y la validación de expresiones, sin modificar solicitudes ni generar acciones.

## Pendiente operativo en TEST

Las instancias v25.0 **10301760** y **269259101** siguen activas y paradas en «Consultar reglas» con `rank (Data Outputs)`. La instancia padre **823135**, también v25.0, sigue esperando en «Start CrearAccion». Un administrador de TEST debe cancelar esas instancias; el borrado automático no actúa mientras sigan activas.

La solicitud **15789310** sigue en `EN_DECISION` y la **15789318** en `ALTA`. Ninguna tiene una fila de `SCA2 Error` para relanzar. No se cancelaron instancias ni se modificaron esas solicitudes.
