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

Las instancias v25.0 **10301760** y **269259101** quedaron paradas en «Consultar reglas» con `rank (Data Outputs)`; la instancia **823135**, también v25.0, esperaba en «Start CrearAccion». Tras la intervención del administrador, las tres devolvieron HTTP 404 en el MCP y ninguna apareció activa en el listado de Decidir. El borrado automático no actúa mientras una instancia siga activa.

En esa lectura, **15789310** estaba en `EN_DECISION` y **15789318** en `ALTA`, sin filas de `SCA2 Error` para relanzar. La recuperación posterior se describe abajo.

## Auditoría de seguimiento en TEST

- Se consultó sin filtro el runtime de los **22 modelos** de la aplicación SCA2: **48 instancias**, de las cuales **47 completadas y una activa**. Los procesos **269258736**, **537691815** y **14499183**, que esperaban desde CrearAccion, CompletarAccion y Alta, devolvieron HTTP 404. No hubo instancias con estado de pausa o excepción en el listado.
- En esa auditoría seguía activa **11252095**, de `SCA2 CMD CompletarAccion` v49.0: el último inicio de nodo era «Start decidir» (03/11/2026), sin finalización en el historial consultado. Ese nodo inicia Decidir de forma síncrona con `regla="mecanizar"`. No se pudo identificar su hija ni atribuirle el mismo fallo de tipos. Tras la intervención del administrador, el MCP devolvió HTTP 404 para esta instancia.
- Se revisaron las salidas tipadas de las versiones publicadas de los 22 modelos y las ramas de error de sus reglas relevantes. Decidir es el único modelo con llamada directa a `SCA2_consultarServiciosReglas`. No se identificó otra asignación confirmada de un `error` de texto a Map o a un tipo incompatible. Por ejemplo, Mecanizar guarda el **objeto** `a!map(success:false, error:tostring(ac!Error))`, no su campo `error`; `error` en el lote de reintentos de Finalizar es un ID numérico según el adaptador versionado, no el texto de un servicio.
- La v32 por sí sola no protegía el análisis JSON de la regla: una evaluación sintética con HTML dio «El parámetro jsonText no era JSON válido». No se observó esa respuesta en ejecución; el tratamiento de Decidir se describe abajo. En Mecanizar, `SCA2_determinarContacto` devuelve nulo si falla la integración en vivo, pero analiza JSON en éxito; no se confirmó una respuesta de texto que llegue al Map `contacto`, y no se cambió esa regla.
- Tampoco se cambiaron las esperas síncronas de Decidir ni su tratamiento de escrituras o avisos: convertir fallos técnicos en reintentos, o quitar una espera, cambia el flujo. Se verificó que Decidir sigue publicado en v32.0 con `AUTO_DELETE` a un día y alertas de grupo habilitadas. La auditoría no modificó ni publicó objetos Appian.

## Respuesta HTTP exitosa sin cuerpo JSON válido

Appian TEST: se guardó una copia privada del diseño de `SCA2_consultarServiciosReglas` v2 y se publicó la **v3**. El índice de dependencias identifica un solo consumidor de ejecución: el nodo «Consultar reglas» de `SCA2 CMD Decidir`.

La regla comprueba el cuerpo con `isvalidjson` antes de llamar a `a!fromJson` si la integración informó éxito. Ante sintaxis no válida o cuerpo ausente devuelve `accion`, `grupo` y `subgrupo` iguales a `ERROR` y un `error` de texto fijo, sin guardar el cuerpo. Decidir v32 ya convierte ese texto en Map y aplica el flujo existente de `DECISION_ERROR`: reintenta con menos de tres intentos y, al agotarlos, bloquea y deja la solicitud en `ERROR_DECISION` para la gestión habitual de errores. El diagnóstico HTTP de la rama de fallo anterior no cambia.

| Validación en TEST | Resultado |
|---|---|
| `validateExpression`, salida anterior frente a la nueva con JSON válido y ante fallo HTTP | Salida idéntica para `CONTRAANULAR`, `MECANIZAR`, el error de negocio en JSON y el literal JSON `null`; diagnóstico HTTP idéntico. |
| `validateExpression`, HTML, JSON truncado, cuerpo ausente y HTML de más de 4.000 caracteres con HTTP exitoso | Error de texto acotado, normalizado por la salida del nodo 5; se cumplen las condiciones publicadas de las ramas de error con uno y tres intentos, respectivamente. |
| `testRule` de la regla publicada con la consulta normal de referencia | `CONTRAANULAR`, con error, grupo y subgrupo nulos, igual que antes. |

En esa validación no se forzó un fallo de servicio ni se ejecutó el proceso completo. No se modificó el modelo de Decidir, que conserva la v32.0, el borrado automático a un día y el destinatario **SCA2 Alertas**.

## Relanzamiento directo en TEST

Antes de ejecutar, el listado sin filtro de los 22 modelos SCA2 devolvió 47 instancias completadas y ninguna activa o en pausa. No había ningún error pendiente de las dos solicitudes. Se guardaron copias privadas de Solicitud, Tarea y Error, limitadas a ambas.

Se lanzó `SCA2 CMD Decidir` v32.0 una vez por solicitud, en secuencia, con `idSolicitud` como único parámetro: el modelo usa `accion` cuando no se informa la regla y carga el nivel vigente de Solicitud. Se verificaron las instancias iniciales y sus reintentos.

| Solicitud y nivel | Instancia inicial | Resultado |
|---|---|---|
| 15789310 · 2 | 269260558 · `COMPLETED` | El servicio de reglas devolvió HTTP 500 en los tres intentos. Decidir los tramitó como `DECISION_ERROR`: la solicitud quedó en `ERROR_DECISION`, con un error `PENDIENTE` y otro `BLOQUEADO`. La tarea anterior siguió completada; no se creó otra. |
| 15789318 · 1 | 16585003 · `COMPLETED` | HTTP 500 al inicio y en el primer reintento. El último reintento obtuvo `CONTRAANULAR`: la solicitud pasó a `EN_ACCION` con una nueva tarea `PENDIENTE` y el error quedó `RELANZADO`. |

Todos los reintentos de Decidir y el proceso de creación de la nueva tarea finalizaron. No aparecieron nuevas filas de `SCA2 Llamada Servicio` para estas solicitudes; la respuesta de reglas se comprobó en las variables de ejecución. No se hizo otra ejecución manual ni se modificaron directamente los records. No se verificó la Bandeja visualmente.

## Comprobación de regresión

La comparación del diseño publicado de Decidir v25.0 y v32.0 identificó una sola diferencia en las expresiones (la conversión de `errorDecision` de texto a mapa), seis cambios de etiquetas y el identificador de versión. Se conservaron conexiones, variables y ajustes del modelo. El diseño de la regla v3 conserva las entradas y la llamada al servicio de la v2; solo evita el análisis de cuerpos ausentes o no válidos. Para JSON válido se conservan las salidas funcionales y para fallo HTTP se conserva el diagnóstico anterior.

En solo lectura se consultó el servicio y la regla publicada con `testRule`. Como el MCP no permite invocar una versión anterior con `testRule`, se evaluó con `validateExpression` el tratamiento de las versiones v2 y v3 sobre la misma respuesta real y se contrastó con la salida publicada. Coincidieron `accion`, `grupo`, `subgrupo` y `error` en Autos nivel 1 (`ACCIONES ADMINISTRATIVAS`), Hogar nivel 2 (`CONTRA ANULAR NIVEL 2`) y Vida nivel 1 (`CONTRAANULAR`). No se pudo completar el contraste con una respuesta correcta comparable para Autos nivel 2, Hogar nivel 1 ni Vida nivel 2.
