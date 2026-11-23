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

## INBOX-38 — Diseño y pruebas de equivalencia pendientes

Se confirmó que terminaron los dos relanzamientos de Decidir. **No se aplicó ni se publicó ningún candidato:** falta un juego aislado que permita repetir las rutas con escrituras e integraciones desde un mismo estado. Los casos históricos de abajo sirven de referencia, no son datos reutilizables. La validación estática no demuestra la equivalencia en ejecución.

### Cortes propuestos

| Padre y base | Nodos extraídos y subproceso síncrono | Retornos al padre y nodos que se conservan | Nodos padre / hijos |
| --- | --- | --- | --- |
| SCA2 CMD Mecanizar v52.0 | **SCA2 SUB Mecanizar Registrar Gestión y Autorización**: 8–11, 340, 342–343. **SCA2 SUB Mecanizar Esperar ANL y Actualizar Gestión**: 302–306, 308–313, 315, 344. | Primer hijo: error → 12; éxito → 13. Segundo hijo: error → 12; revisar nivel → 325. El padre conserva alta ANL (301), recarga de solicitud, escritura de nivel, inducción Verti (334, con retorno a `induccionProcessId`) y despacho a CrearAccion (322 → Decidir). | 46 → 30 / 11 y 17 |
| SCA2 CMD MecanizarNSE v10.0 | **SCA2 SUB MecanizarNSE Crear y Registrar Autorización**: 13, 101. | Vuelve al 14, que revisa la respuesta. Finalización CORE, observaciones, cierre de ANL, escrituras de estado/error y despacho a CrearAccion (36 → Decidir) en el padre. | 31 → 30 / 4 |
| SCA2 CMD CompletarAccion v61.0 | **SCA2 SUB CompletarAccion Documentos y Cierre Externo**: 300–304, 310–312, 320–321, 350–353, 360–364, 370–373. | Continuación → 11; error → 199; transición OK → 330. Escrituras finales y despachos en el padre, incluido Decidir (12). | 46 → 25 / 28 |
| SCA2 CMD CrearAccion v34.0 | **SCA2 SUB CrearAccion Alta CORE y Registro de Acción**: 5, 7, 9, 16–19, 21, 204–209. | Fin → 2; error → 8; cambio de nivel → 10; cierre → 13; sin mecanizar → 22. Quedan carga, gestión Verti (30–40 donde existe), error común y despachos a Finalizar (14) y Decidir (15). | 40 → 28 / 21 |
| SCA2 CMD ProcesarLoteErrores v6.0 | Solo el 42 cambia a «Iniciar proceso» asíncrono, con la constante existente `SCA2_PM_CMD_PROCESAR_LOTE_ERRORES`. | Misma salida al 2. El 34 sigue síncrono, antes del histórico (37); puede llegar a Decidir mediante MarcarErrorRelanzado si el comando del error es Decidir. Se conservan la espera (39), el descarte (35) y el fin del lote (40). | 11 → 11 / — |

Todos los nodos no enumerados en el corte siguen en el padre. El SUB ocupa el ID del nodo de entrada original; con varios destinos, devuelve `destinoBloque` a un PV interno y una XOR retoma la ruta original. Se encadenan las entradas de Mecanizar–registro CORE, CompletarAccion y CrearAccion. En Mecanizar–registro CORE solo se encadena la salida de éxito. Los límites de los cortes de espera ANL y autorización NSE no se encadenan. Esto preserva las marcas de las rutas, pero queda por probar el encadenamiento efectivo en la sesión de oficina, incluido el retorno de Verti.

**Contratos de datos.** Los mapeos nominales de cada PV están en `inbox38-contratos.json`; sus tipos y multiplicidad, en los JSON de definición. Cada PV leído o escrito entra desde el PV homónimo del padre; solo los escritos vuelven al padre. Los usos explícitos de `pp!id`, `pp!initiator`, `pp!name` y `pp!starttime` reciben el valor del padre cuando corresponda, para preservar la correlación, el usuario, el comando y las claves de idempotencia. El contexto implícito de reglas y servicios no queda demostrado por el mapeo.

- **Mecanizar:** el bloque CORE recibe solicitud, gestión, reserva prima y observaciones; devuelve gestión, petición/respuesta, bloqueo, error y trazas. El bloque ANL recibe solicitud, póliza, estado de ANL y actualización; devuelve estados, contadores, respuestas, trazas y errores de actualización/escritura. Se conservan el temporizador y los bucles internos.
- **MecanizarNSE:** pasa `idSolicitud`, `consultaAutorizacion` y estado intermedio; devuelve `autSuccess`, `autErr`, `autBody` y los PV de llamada.
- **CompletarAccion:** pasa `idSolicitud`, `idTarea`, `resultado`, `sol` y resultados intermedios; devuelve resultado de documentos/CA/autorización/cierre/impresión, grabación del argumento, trazas y errores.
- **CrearAccion:** pasa `accionCalc`, `idSolicitud`, `sol`, `seleccionVerti` y estado intermedio; devuelve `wrErr`, `wrCodigo`, `wrNodo`, `wrErrMsg` y `obsRes`.
- **ProcesarLoteErrores:** pasa `ldrop(..., 1)` de `ids`, `solicitudes` y `comandos`; conserva `accion` y `idLote`. Suma uno a `procesados` si el estado actual es PENDIENTE y, en otro caso, a `omitidos`, partiendo de cero cuando el contador es nulo.

**Riesgos de equivalencia.** Se conserva `runAs` en cada nodo movido, pero los nodos ejecutados como `DESIGNER` (p. ej., Crear Autorización, Finalizar CA PCA y Alta gestión CORE) cambian de modelo: hay que comprobar propietario, permisos y usuario efectivo. Un fallo de plataforma puede pausar el hijo mientras espera el padre; probar recuperación, visibilidad y recepción de alertas, además del error de negocio. Comprobar retorno de PV nulos o múltiples y encadenamiento real. En el lote, comprobar iniciador, permisos, orden y comportamiento si falla el arranque. Que termine la primera instancia no significa que haya terminado el lote.

### Casos previstos en TEST

Preparar dos juegos equivalentes por el flujo ordinario de TEST o restaurar un mismo estado en un entorno aislado equivalente. No relanzar los IDs históricos ni reutilizar pólizas ya anuladas. No cambiar SCA, SCAC ni CORE ni usar DDL/DML directo.

| PM | Referencia histórica y precondición del nuevo caso | Ruta y evidencias que comparar |
| --- | --- | --- |
| Mecanizar | [R48-C](pruebas/r48-c-regresion-indices-paso1.md): 15788998 / 2002400321576 (Verti/vencimiento; quedaron instancias abiertas); 15788999 / 2002000004992 (AA; no se anuló). Replicar con tarea válida en `PDTE_MECANIZAR` y usuario/rol de oficina. | Verti, ANL ya creada y espera→desbloqueo→actualización; también error y timeout en casos aislados sin acortar tiempos. Comparar ANL, intervalos/contadores, `ANL_TIMEOUT`, `induccionProcessId`, nivel, llamadas, tareas, transiciones, errores y despacho. |
| MecanizarNSE | [R46-B](pruebas/r46-b-anl-nse-new.md): 15788855 / 2002500248962 (ya finalizada). Replicar autorización de Autos fuera de norma con tarea pendiente; más respuesta fallida aislada. | 13→101→14 en ambas; repetir éxito hasta finalización/despacho y fallo sin continuación indebida. Comparar `autSuccess/autErr/autBody`, llamadas, autorización, tareas, nivel, errores y estado final. |
| CompletarAccion | R48-C: 15789000 / 0730080000041 (CA positiva ya finalizada), 15788998 (negativa/Verti), 15788999 (AA). Crear tareas equivalentes con el resultado real de UI y documentos de prueba. | Documentación válida y fallida, cierre CA positivo, decisión y grabación del argumento. Comparar `resultado`, respuestas GD/CA/cierre/impresión, referencia documental, argumento, error, transición, tareas, llamadas y `FINALIZADA_POSITIVO` cuando proceda. |
| CrearAccion | R48-C: 15788998 / 2002400321576. Replicar el punto anterior al alta de acción, con y sin retorno Verti; más fallo controlado y repetición con la misma clave. | Alta CORE→observación→tarea y retorno Verti; cambio de nivel/cierre/Decidir según acción y error. Comparar `accionCalc`, `obsRes`, `wr*`, observaciones, tareas/asignaciones/transiciones y ausencia de altas duplicadas. |
| ProcesarLoteErrores | [R24-D](pruebas/r24-d-batch-sgd-errores.md): error 120 / 15788025 **no debe relanzarse**. Preparar por versión dos errores propios pendientes y uno ya resuelto en mitad, listas alineadas e `idLote` único. Probar DESCARTAR y RELANZAR con comandos autorizados. | 2 tratados / 1 omitido, dos transiciones en total de elementos tratados y una sola `-FIN`, ninguna escritura sobre el omitido, mismo iniciador, mismo orden. Comparar el 34 síncrono antes del histórico y los 10 s antes de cada arranque posterior a un elemento tratado. Seguir todas las instancias hasta fin del lote. |

Fijar antes de cada ensayo versiones de dependencias, perfil, estado inicial SCA2/CORE y entradas. Ejecutar la base y el candidato en un entorno aislado sin sustituir primero el modelo activo. Usar `testProcessModel` si es desatendido, seguir en Monitor las instancias que superen su plazo, y repetir el flujo de usuario si el caso pasa por atención o encadenamiento. Capturar ruta, PVs, llamadas, efectos externos observables y filas aplicables de Solicitud, Tarea, Transición, Llamada Servicio y Error. Normalizar solo IDs y timestamps generados que tengan correspondencia, no sus correlaciones ni intervalos. Comprobar fallos/alertas, legibilidad en Designer y borrado de instancias finalizadas al día. Tras publicar, releer el diseño y comprobar los avisos; consignar cualquier recomendación residual de un SUB síncrono legítimo.

### Copias, vuelta atrás y exclusiones

En `~/memory/appian_91b2ca/files/sca2-avisos-monitorizacion/` están las copias `inbox38-antes-*-v*.json` de los seis modelos publicados y los dos dependientes revisados. `inbox38_preparar.py` genera los contratos y los JSON `inbox38-crear-*` (metadatos de hijos: `AUTO_DELETE`, 1 día y **SCA2 Alertas**), `inbox38-definir-*` (grafos de hijos), `inbox38-actualizar-*` (padres) e `inbox38-revertir-*` (grafos anteriores). Sustituir las referencias de UUID de hijos y la guarda de versión con los valores reales. Se comprobó el esquema local de nodos y PVs, no la validación de publicación de Appian ni el mapeo efectivo de salidas del SUB.

Cotejar la versión publicada con la copia antes de aplicar; no sobrescribir cambios ajenos ni alterar seguridad o temporizadores. Guardar los JSON posteriores de padre e hijos. Ante una diferencia, detener nuevas pruebas, volver a publicar el diseño anterior del padre y verificar el grafo y las instancias activas antes de retirar un hijo sin dependientes. Restaurar el modelo no revierte llamadas ni filas ya escritas: acordar aislamiento y limpieza antes del ensayo.

**SCA2 CMD BarridoCaducidad se queda en v9.0** con el temporizador, el 7 síncrono hacia Caducar y el 9 de autorrelanzamiento intactos. Pendiente de aislar al menos 100 vencidas para alcanzar el 9; comprobar cursor, orden y ausencia de duplicados entre páginas sin tocar vencidas reales. Véase [el diseño de caducidad](72-caducidad-por-accion-sca2.md). No se modificaron Reserva Prima, el XOR del batch NSE ni Decidir.
