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

En la última lectura de recuperación, **15789310** estaba en `EN_DECISION` y **15789318** en `ALTA`, sin filas de `SCA2 Error` para relanzar. La decisión sobre cómo recuperarlas queda pendiente (INBOX-37); no se relanzó ni se modificó ninguna.

## Auditoría de seguimiento en TEST

- Se consultó sin filtro el runtime de los **22 modelos** de la aplicación SCA2: **48 instancias**, de las cuales **47 completadas y una activa**. Los procesos **269258736**, **537691815** y **14499183**, que esperaban desde CrearAccion, CompletarAccion y Alta, devolvieron HTTP 404. No hubo instancias con estado de pausa o excepción en el listado.
- Queda activa **11252095**, de `SCA2 CMD CompletarAccion` v49.0: el último inicio de nodo es «Start decidir» (03/11/2026), sin finalización en el historial consultado. Ese nodo inicia Decidir de forma síncrona con `regla="mecanizar"`. No se pudo identificar su hija ni atribuirle el mismo fallo de tipos; requiere revisión en Appian Monitoring.
- Se revisaron las salidas tipadas de las versiones publicadas de los 22 modelos y las ramas de error de sus reglas relevantes. Decidir es el único modelo con llamada directa a `SCA2_consultarServiciosReglas`. No se identificó otra asignación confirmada de un `error` de texto a Map o a un tipo incompatible. Por ejemplo, Mecanizar guarda el **objeto** `a!map(success:false, error:tostring(ac!Error))`, no su campo `error`; `error` en el lote de reintentos de Finalizar es un ID numérico según el adaptador versionado, no el texto de un servicio.
- La corrección no captura excepciones de evaluación: la rama de HTTP exitoso de `SCA2_consultarServiciosReglas` analiza el cuerpo con `a!fromJson` antes de devolver una decisión; una evaluación sintética con HTML dio «El parámetro jsonText no era JSON válido». No se observó esa respuesta en TEST. En Mecanizar, `SCA2_determinarContacto` devuelve nulo si falla la integración en vivo, pero parsea JSON en éxito; no se confirmó una respuesta de texto válida que llegue al Map `contacto`. Cambiar el manejo de esos casos podría alterar qué se registra o si se ejecuta la inducción Verti, por lo que no se aplicó una conversión por analogía.
- Tampoco se cambiaron las esperas síncronas de Decidir ni su tratamiento de escrituras o avisos: convertir fallos técnicos en reintentos, o quitar una espera, cambia el flujo. Se verificó que Decidir sigue publicado en v32.0 con `AUTO_DELETE` a un día y alertas de grupo habilitadas. La auditoría no modificó ni publicó objetos Appian.
