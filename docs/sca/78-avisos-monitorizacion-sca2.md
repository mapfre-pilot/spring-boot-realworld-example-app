# 78 · SCA2 — Avisos de monitorización

## Resultado en TEST

En **Monitorear → Panel de estado → Orientación de diseño de Appian** se verificó la desaparición del aviso «Variable de proceso no utilizada» de **SCA2 CMD MecanizarNSE**. En la versión 10.0 se retiró `estadoFinal`: era una variable interna sin valor inicial, sin referencias en el modelo y no formaba parte de los parámetros de entrada. Los informes de proceso de la aplicación revisados no tenían este modelo como contexto.

La comparación con la versión publicada anterior únicamente mostró la retirada de esa variable. Se conservaron los 31 nodos, sus conexiones y los parámetros `idSolicitud`, `relanzado` e `idTarea`. La validación estructural no indicó errores ni advertencias. El panel sigue mostrando «Demasiados nodos» para este modelo. No se lanzaron instancias de mecanización para la comprobación.

Los tres modelos revisados ya eliminaban las instancias completadas al cabo de un día y enviaban las alertas de error al grupo **SCA2 Alertas**. Se mantuvo un día tal como se solicitó, aunque el validador recomienda cero días para modelos sin tareas atendidas. No se modificaron rutas ni se aplicaron cambios en la base de datos.

## Pendientes de decisión

| Objeto | Aviso | Motivo y siguiente paso |
| --- | --- | --- |
| SCA2 CMD Mecanizar | Variable de proceso no utilizada | `inducirVerti` no se lee dentro del modelo, pero es un parámetro y la interfaz que inicia la mecanización aún lo envía. No se elimina sin aprobar y verificar la retirada del contrato en los llamadores. |
| SCA2 CMD Mecanizar | Demasiados nodos | 46 nodos; el panel de TEST recomienda un máximo de 30. Evaluar la extracción del tramo de espera y actualización de ANL, con sus reintentos y salidas de éxito/error, sin mover la inducción. La extracción exige comprobar el encadenamiento y quién ejecuta cada paso. |
| SCA2 CMD MecanizarNSE | Demasiados nodos | 31 nodos. Un posible corte es extraer la creación de la autorización y el registro de esa llamada a un único subproceso síncrono, conservando los datos de respuesta y la rama de error. No se aplicó: cambia el límite de instancia y puede afectar a identidad, transacciones o fallos. |
| SCA2 Batch Mecanizacion NSE | Puerta con múltiples flujos entrantes | La entrada inicial y el retorno del bucle confluyen en «¿Quedan solicitudes?». Appian recomienda un nodo de script que fusione ambas entradas antes de la puerta. Eso cambia la ejecución del bucle si se habilita el batch; no se aplicó ni se activó el batch. |
| SCA2 Tarea Hist, Solicitud Hist, Transicion Hist, Llamada Servicio Hist, Error Hist, Niveles Cobertura Autos Hist, Datos Solicitud Hist y Otras Solicitudes Cabecera Hist | Ciertas propiedades no se utilizan | El aviso indica que el acceso directo no utiliza todas las propiedades de la conexión. Ese acceso es intencionado (véase [el diseño de históricos](71-diseno-tablas-vivas-historicas-sca2.md)); no se cambió la sincronización ni la conexión. |

El sitio piloto, su grupo, las copias del piloto y el proceso Decidir quedaron fuera de esta intervención.

## Ampliación — Otros 16 objetos del panel

En **SCA2_TablaGestionArgumentos** se retiró únicamente la declaración sin valor inicial de `local!documentum` (v3 → v4). Se conservaron el input `ri!documentum` y el guardado de documentos que lo utiliza. La validación no indicó errores ni advertencias estructurales; la evaluación con una lista vacía produjo el mismo árbol de componentes, sin contar los identificadores de renderizado y el valor serializado de guardado por sesión. No había casos guardados. El aviso desapareció del panel: el total pasó de 27 a 26 objetos.

| Objeto | Aviso | Acción o propuesta |
| --- | --- | --- |
| SCA2_TablaGestionArgumentos | Variable local no utilizada | Corregido y verificado en TEST. |
| SCA2 Datos Poliza Vida Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo; la sincronización no se cambia para quitar el aviso. |
| SCA2 Datos Poliza Hogar Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo. |
| SCA2 Datos Poliza Autos Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo. |
| SCA2 Datos Productor Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo. |
| SCA2 Datos Perfiles Pca Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo. |
| SCA2 Datos Basicos Solicitud Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo. |
| SCA2 Datos Cabecera Hist | Ciertas propiedades no se utilizan | Mantener el acceso directo. |
| SCA2 CMD CompletarAccion | Demasiados nodos (46) | Evaluar extraer la subida documental y el cierre externo como un subproceso que devuelva éxito, error o continuación, manteniendo las escrituras de estado y el despacho posterior en el padre. Comprobar orden, errores y encadenamiento antes de publicar. |
| SCA2 CMD CrearAccion | Demasiados nodos (40) | Evaluar extraer la carga, idempotencia y preparación VERTI (12 nodos) dejando la decisión de acción en el padre. Validar los retornos de fin, error y continuación y conservar el encadenamiento de VERTI; no cambiar Decidir. |
| SCA2 CMD BarridoCaducidad | Convertir subprocesos en Iniciar proceso | Mantener «Caducar solicitud» síncrono y secuencial por elemento. Si se prioriza el aviso, evaluar solamente el autorrelanzamiento asíncrono «Procesar siguiente lote» y comprobar cursor, identidad y no duplicación. |
| SCA2 CMD Procesar Reserva Prima | Variables de proceso no utilizadas | No eliminar las 11 variables que enumera Designer: las 11 tienen referencias en v4.0, incluida la entrada `reservaPrima`. Verificar la recomendación en una copia de diseño y escalar a Appian si se reproduce. Separar ese diagnóstico de `codAnulacion`, que no se enumera y cuyo valor de actividad alimenta la escritura de la anulación. |
| SCA2 Batch Reserva Prima | Convertir subprocesos en Iniciar proceso | Mantener las operaciones de poner en cola y cerrar transacción en su orden síncrono; no convertirlas sin una prueba que demuestre que la cola, el cierre y la propagación de fallos conservan su comportamiento. |
| SCA2 CMD ProcesarLoteErrores | Convertir subprocesos en Iniciar proceso | Conservar «Relanzar error» síncrono antes del histórico. Si se prioriza el aviso, evaluar solo el siguiente elemento asíncrono, verificando el intervalo, los contadores y la ausencia de duplicados. |
| SCA2_ContraAnulacionCompaniaCatalogacion | Entradas de regla no utilizadas | Retiradas las dos entradas y sus argumentos en el único llamador; aviso eliminado en TEST. |
| SCA2_consultarListadoArgumentosREST | Entrada de regla no utilizada | Conservar `random`: el llamador lo envía intencionadamente para no reutilizar una respuesta con el mismo cuerpo. Solo plantear su retirada si se demuestra en TEST que la recarga sigue consultando el servicio en cada solicitud. |

No se modificaron modelos de proceso, integraciones ni tipos de registro en esta ampliación. Mecanizar, MecanizarNSE y Batch Mecanizacion NSE siguen pendientes de decisión.

### Corrección — Entradas de compañía contraria y catalogación

En TEST, se retiraron `argumentoSeleccionado` e `indiceArgumentoSeleccionado` de `SCA2_ContraAnulacionCompaniaCatalogacion` (v9 → v10). Su expresión quedó idéntica: no usa esas entradas en expresiones ejecutables, guardados ni validaciones; solo las nombraba en el comentario de cabecera. La consulta de dependientes devolvió la aplicación SCA2 y un único llamador, `SCA2_ContraAnulacionOpciones` (v83 → v84). En esa llamada solo se quitaron las dos lecturas directas de `local!argumentoSeleccionado` y `local!indiceArgSeleccionado`, que no contienen `a!save()` ni llamadas a integraciones. Se publicaron primero los argumentos omitidos en Opciones y después las declaraciones en Catalogación. Se conservaron las variables locales, todos los guardados y el par enviado a `SCA2_ContraAnulacionArgumentarioEstrategicas`, que sí participa en la selección.

Las cinco evaluaciones antes y después se completaron sin errores ni truncamiento: Catalogación con datos sintéticos y Opciones con las entradas del caso guardado `TEST-UI-4B` y de las tres solicitudes de [R46-D](pruebas/r46-d-argumentario-treboles.md) (`15788852`, `15788854`, `15788856`). Los árboles SAIL coinciden al excluir solo los IDs de renderizado y las expresiones de guardado serializadas por sesión. Para `15788852`, la primera evaluación posterior devolvió dos filas de argumentos donde la base tenía ocho; una segunda evaluación de la misma v84 volvió a mostrar las ocho filas y coincidió con el árbol base. No se excluyeron datos del argumentario de la comparación.

El caso predeterminado de Opciones conservó su configuración y pasó (`success: true`). Catalogación no presentó errores de validación. La validación genérica de Opciones sigue mostrando el mismo error de filtro vacío en `SCA2_cargarSolicitud` que en v83, sin reproducirse con las entradas de prueba indicadas. El aviso desapareció de Monitorización y de la ficha de Catalogación. Por indicación del usuario no se pulsó **RECARGAR ARGUMENTO** en la interfaz. No se tocaron PMs ni integraciones.
