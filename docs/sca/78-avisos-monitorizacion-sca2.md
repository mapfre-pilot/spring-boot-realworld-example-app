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

Se confirmó que terminaron los dos relanzamientos de Decidir. El diseño inicial quedó sin aplicar hasta autorizar el aislamiento: candidatos sin llamadores activos y altas nuevas mediante el flujo ordinario de TEST. Los modelos activos siguen intactos; véanse los resultados de esa ronda al final de esta sección.

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

### Primera ronda con candidatos aislados en TEST

**ProcesarLoteErrores: comparación del candidato.** Se configuró `SCA2 CMD ProcesarLoteErrores Candidato INBOX38` (v2.0, `0001f0c1-84b7-8000-dc08-7f0000014e7a`) y una constante que apunta solo al candidato, para que su nodo 42 no arranque el modelo activo. La paleta actual admite `appian.system.smart-services.start-process-6`, no `-5`. La copia usa la versión admitida, con `IsSynchronous = false` y `ChainIntoChild = false`.

Se probó la cadena de omisión completa con los mismos dos IDs sintéticos sin fila, `[-1,-2]`, y dos identificadores de lote separados. Las seis instancias terminaron `COMPLETED`. La base y el candidato conservaron el iniciador, el orden, las listas restantes y los contadores; cada uno escribió una sola transición `-FIN` con «0 tratados, 2 omitidos» (3534 y 3535). **Cambió la relación entre instancias:** la base v6.0 encadenó `9249567 → 9249568 → 9249569` con `parentId`; las continuaciones del candidato (`13455033` y `825056`, arrancadas desde `537693577`) no tienen `parentId`. El resultado de negocio en esa rama coincide, pero se pierde el árbol de procesos del lote en Monitor. No se publicó el cambio en el modelo activo ni se probaron después las ramas de descarte/relanzamiento de errores pendientes o el alertado de fallo. Se dejaron el candidato y su constante sin uso funcional para conservar la evidencia; aparte de pertenecer a la aplicación, el candidato solo está referenciado por su propia constante.

**Cuatro troceados: bloqueados por la escritura del grafo en el MCP.** Se creó el hijo de autorización de MecanizarNSE (v2.0, `0004f0c1-850d-8000-dc0a-7f0000014e7a`), pero al guardar el grafo del padre aislado la API devolvió `HTTP 400: Unsupported node type: 'appian.system.smart-services.start-process-5'`. Se confirmó que el padre candidato (`0001f0c1-850d-8000-dc0a-7f0000014e7a`) quedó en v1.0 solo con inicio y fin; no está conectado al hijo ni tiene llamadores. Los dos objetos quedan sin uso. La paleta excluye ese mismo tipo en nodos que se deben conservar en **MecanizarNSE** (23, 30, 36), **CrearAccion** (14, 15, 36), **CompletarAccion** (8, 10, 12) y **Mecanizar** (322). No se sustituyeron esos nodos por la versión nueva, porque están fuera del troceado que se quiere comparar. Los otros tres candidatos no se crearon y ninguno de los cuatro troceados se ejecutó. Para continuar se necesita una copia/edición que conserve los nodos existentes, p. ej. probar «Guardar como» y editar los cortes en Designer en vez de recrear los grafos por el MCP.

**Datos de prueba creados.** Se comprobaron vigencia y ausencia de solicitud SCA2 en curso antes de cada alta. Se construyó el contexto mediante `testRule` de `SCA2_construirContextoAlta` y se inició `SCA2 CMD Alta` con `testProcessModel`. No se hizo DDL/DML ni se tocaron solicitudes anteriores.

| Póliza de TEST | Solicitud / instancia Alta | Estado de entrada observado y evidencias |
| --- | --- | --- |
| 2002400378555 | **15789327** / 17627215 | Alta `COMPLETED`, `generar.success=true`, `wrErr=false`; llamada 513 OK; transiciones 3537, 3540, 3541; tarea 981 PENDIENTE. Quedó `EN_ACCION` en Acciones Administrativas, nivel 1. Se registró además el error de decisión 327 antes del estado final; no se considera equivalente en histórico a la otra alta. |
| 2002200057934 | **15789328** / 17627216 | Alta `COMPLETED`, `generar.success=true`, `wrErr=false`; llamada 514 OK; transiciones 3536, 3538, 3539; tarea 980 PENDIENTE. Mismo estado final; no se encontró fila de error para esta solicitud. |

No se avanzaron estas dos tareas tras el alta. Las evidencias de ejecución y los extractos de registros se guardaron junto a los payloads en `files/sca2-avisos-monitorizacion/`. Al terminar la primera ronda seguían publicados Mecanizar 52.0, MecanizarNSE 10.0, CompletarAccion 61.0, CrearAccion 34.0, ProcesarLoteErrores 6.0 y BarridoCaducidad 9.0.

### Publicación de ProcesarLoteErrores en TEST

Tras la aprobación del usuario de que las continuaciones queden como instancias independientes en Monitor, se publicó **v7.0** en el UUID existente `0001f0ba-bbae-8000-da82-7f0000014e7a`. Appian no permite cambiar el tipo en el mismo ID: el nodo 43 («Iniciar siguiente error del lote») sustituye al 42 y conserva las dos entradas de flujo (33 y 39) y la salida al fin. Usa la constante existente `SCA2_PM_CMD_PROCESAR_LOTE_ERRORES`, los mismos siete parámetros y las opciones asíncrona y sin encadenamiento. El nodo 34 sigue siendo síncrono. No cambiaron las PVs ni el total de 11 nodos.

La lectura de la versión publicada mostró `AUTO_DELETE` a **1 día**. Designer mostró **SCA2 Alertas** como destinatario de alertas de error. Se mantiene un día por petición del usuario, aunque Appian recomienda cero para este modelo sin tareas humanas. Designer aún recomienda convertir el subproceso restante; se conserva porque el nodo 34 debe terminar antes de registrar el histórico.

La prueba posterior `INBOX38-POST-V7-1795470006760` recorrió la misma cadena de omisión con IDs sintéticos. Las instancias `16585322 → 14500628 → 825078` quedaron `COMPLETED`, sin `parentId`, con contadores de omitidos 0 → 1 → 2 y cero tratados. Se encontró una única transición final (3542): «0 tratados, 2 omitidos por no estar PENDIENTE», igual que en la primera ronda. La prueba no ejecutó el descarte ni el relanzamiento de un error pendiente, ni provocó una alerta de fallo.

El candidato y su constante se dejaron sin uso, sin borrarlos. Las copias de v6.0 y v7.0, el resultado de la prueba, las tres instancias, la transición y la captura de alertas están en `files/sca2-avisos-monitorizacion/`.

### Copia de MecanizarNSE en Designer

«Guardar como» en la carpeta **SCA2 Process Models** creó `SCA2 CMD MecanizarNSE Designer Candidato` (`001ff0c1-883a-8000-dc1a-7f0000014e7a`). La copia inicial conservó los **31 nodos** y los tres `start-process-5` (23, 30 y 36). Es distinta del candidato vacío de la primera ronda.

La copia conserva las PVs, conexiones y asignaciones. Appian generó UUIDs nuevos para los nodos, ajustó las coordenadas y añadió traducciones inglesas vacías. En seis nodos de escritura, el literal de `PauseOnError` pasó de 0 a nulo mientras se mantuvo la expresión explícita `=false()`; la equivalencia del comportamiento ante un fallo de escritura queda por probar.

**Prueba de serialización de `PauseOnError`.** Los nodos afectados en la copia inicial eran 32, 33, 99, 100, 101 y 102. En v10.0 cada uno tiene `expression: "=false()"` y `value: 0`. En el nodo 99, guardar el literal `false` en Designer restauró `value: 0` pero eliminó la expresión; volver a guardar `=false()` recuperó la expresión y dejó el literal nulo. La prueba se deshizo antes de editar el grafo.

**Precedente de serialización en Designer.** Se revisaron 25 de los 26 PMs que devolvió el inventario SCA2 (se excluyó Decidir). La versión publicada **7.0 de SCA2 CMD RefrescarCacheCabecera**, guardada desde Designer, conserva `=false()` con literal nulo en los nodos 6 y 12. La [prueba de R38-A](./pruebas/r38-a-refrescar-cache-cabecera-mni.md#r38-a--sca2-cmd-refrescarcachecabecera-revisión-mni-y-errores-de-campos-de-la-caché-de-cabecera) documenta la instancia 537589544 de esa versión: `COMPLETED`, 43 filas procesadas y sin errores de escritura. Esto acredita una ejecución correcta por el nodo 6; no prueba qué ocurre ante un error de escritura ni la ejecución del nodo 12 en esa instancia. La v8.0 mantiene el mismo formato en el nodo 6, pero no se encontraron instancias retenidas. **ProcesarLoteErrores v7.0 no es un precedente**: en sus nodos 35, 37 y 40, `PauseOnError` tiene literal 1 y no tiene expresión. Con el precedente de RefrescarCacheCabecera se acepta conservar `=false()` sin literal en el borrador, sin prescindir de la comparación funcional antes de promover.

**Candidato de prueba v1.0; modelo activo sin promover.** La copia de Designer tiene **30 nodos** y conserva los tres `start-process-5`. En la salida por defecto del nodo 12, el subproceso síncrono «Crear y registrar autorización» sustituye los nodos 13 y 101 y conecta al 14 «¿Autorización OK?». Apunta al hijo v2.0 (`0004f0c1-850d-8000-dc0a-7f0000014e7a`), pasa las entradas mediante PVs y `idProcesoPadre = pp!id`, y devuelve las nueve PVs acordadas sin encadenamiento. Los cinco nodos de escritura que quedaron en el padre conservan `=false()` con literal nulo; el nodo 101 mantiene en el hijo `=false()` con literal 0. Padre e hijo registran `AUTO_DELETE` a un día y alertas por grupo habilitadas; falta cotejar el destinatario exacto y el comportamiento ante fallos antes de promover. Designer marcó el grafo sin errores. El arranque por MCP rechazó el borrador porque no tenía una versión publicada y el arranque de depuración de Designer también lo rechazó. Se publicó **solo la copia aislada**, para permitir las pruebas, no el UUID activo (`0000f095-7c8e-8000-d60a-7f0000014e7a`), que sigue publicado en v10.0.

**Comparación pendiente.** No se ejecutaron pares válidos. El nodo 4 solo deja llegar al tramo sustituido con una solicitud `MECANIZADA`, proceso activo `ANL` y origen NSE no wAutemis, sin una transición OK idempotente para esa versión. Las altas 15789327/15789328 quedaron en Acciones Administrativas y una arrastra un `DECISION_ERROR`; no sirven como par. R46-B tampoco proporciona una póliza reutilizable: el caso histórico 15788855 ya está finalizado y siguió el camino informativo de anulación directa. Falta reproducir la precondición del nodo 4 por el flujo ordinario en dos pares nuevos y alcanzar el subproceso tanto en éxito como en error, sin alterar datos históricos ni forzar el estado con DML. Hasta entonces no se promueve MecanizarNSE. Evidencias en `files/sca2-avisos-monitorizacion/`: `inbox38-nse-corte-designer.png`, `inbox38-nse-depuracion-borrador.png`, `inbox38-nse-candidato-v1.0.json` e `inbox38-nse-hijo-verificado-v2.0.json`.

### Pruebas por pares desde las tareas de TEST

- **CompletarAccion.** La pantalla de tareas envía «ACC ADM» a `SCA2_AccionesAdministrativasPrincipal`. Tanto FINALIZAR como CANCELAR llaman de forma síncrona a `cons!SCA2_PM_CMD_COMPLETAR_ACCION`, que en TEST resuelve al UUID activo (`0000f06f-1307-8000-65b1-7f0000014e7a`, v61.0). FINALIZAR ejecuta además catalogación y guardado de Acciones Administrativas en CORE desde el propio formulario. Pulsar el botón en dos solicitudes no cambia el destino; invocar después el candidato no reproduce esas escrituras iniciales ni el encadenamiento. En v61.0, la ruta de Acciones Administrativas que prueba el corte pasa por el nodo 310 si se finaliza con `listaNombreDocs` no vacía (nodo 6); no basta que ambas altas lleguen a la tarea.
- **CrearAccion.** En v34.0, el ramal «Humana» del nodo 5 incluye Acciones Administrativas y enlaza con Alta gestión CORE (17) y Write Tarea (7). Si el caso que se quiere comparar es la creación de esa tarea, el punto de comparación está antes de que aparezca en pantalla. Completar una tarea existente prueba otro despacho. Incluso la salida directa a CrearAccion del nodo 10 de CompletarAccion v61.0 resuelve `cons!SCA2_PM_CMD_CREAR_ACCION` al UUID activo (`0000f06f-0eaa-8000-6594-7f0000014e7a`), no a una copia. Para comparar por pares sin redirigir tráfico compartido, hace falta una entrada de pruebas aislada: una copia del formulario para CompletarAccion y un arranque controlado de CrearAccion antes de que se cree la tarea, manteniendo el perfil, los parámetros y el contexto del despacho original.
- **Mecanizar y MecanizarNSE.** Son dos puntos distintos del flujo: Mecanizar debe arrancar desde una tarea de mecanización válida, no desde el estado que el propio proceso escribe en el nodo 13. Para cubrir el corte de espera de Mecanizar, el nodo 324 solo entra en el 302 si el origen es wAutemis y la simulación devuelve `00000005` o `00000006`; hace falta que ANL deje un caso consultable y permita observar su respuesta o reproducir su fallo en TEST. Para el corte NSE hace falta una póliza de TEST NSE-Autos o NSE-Hogar no wAutemis, sin solicitud en curso, cuya anulación por el flujo ordinario permita observar `MECANIZADA/ANL` y que la llamada previa de actualización de mecanización llegue al nodo 12 por éxito. Se necesitan entradas nuevas equivalentes para base y candidato y un caso que reproduzca un fallo dentro del tramo modificado. No se probó un alta nueva en esta revisión; estas condiciones describen qué buscar, no demuestran que falten pólizas válidas en TEST.

La comprobación de despacho fue de solo lectura. No se crearon candidatos adicionales, no se modificaron constantes ni llamadores compartidos y no se crearon ni avanzaron solicitudes en esta revisión. Las lecturas TEST de las interfaces, las constantes y los modelos publicados quedaron en `files/sca2-avisos-monitorizacion/inbox38-despacho-*.json`.

### Entradas de prueba autorizadas y búsqueda de casos ANL

**Preparación de CompletarAccion y CrearAccion.** Se publicaron únicamente los dos hijos nuevos en TEST, sin conectarlos a ningún llamador: `SCA2 SUB CompletarAccion Documentos y Cierre Externo` v2.0 (28 nodos) y `SCA2 SUB CrearAccion Alta CORE y Registro de Acción` v2.0 (21 nodos). La primera carga devolvió HTTP 400 porque faltaba rotular las salidas de las compuertas. Se reutilizaron las etiquetas de las condiciones y se rotularon las salidas por defecto, sin modificar expresiones ni destinos. La lectura de ambas v2.0 confirmó `AUTO_DELETE` a un día, alertado por grupo habilitado y `PauseOnError =false()` con literal 0 en las escrituras correspondientes. La creación se configuró con **SCA2 Alertas**; falta comprobar el destinatario efectivo y la recepción de fallos. El MCP recomienda eliminar inmediatamente los procesos desatendidos; se conserva el día solicitado.

El buscador de Designer devolvió el objeto exacto `SCA2 CMD CompletarAccion`, pero ni abrir el enlace ni confirmar con Enter cargó el modelo en Appian Process Modeler; el modelador siguió en `MecanizarNSE Designer Candidato v1.0`. No se guardaron los padres candidatos, ni se creó la copia del formulario o el arranque aislado, porque aún no tenían un padre candidato al que llamar. Los dos hijos de esta ronda se dejan sin uso. No se lanzaron pares, ni se modificaron o promovieron los PM activos.

**Búsqueda de solo lectura en TEST.** En 415 filas de `SCA2 Solicitud` se encontraron cuatro con `MECANIZADA/ANL`, todas wAutemis. La consulta `ANL_getAnulacionByFilter_qr` devolvió una fila por caso, las cuatro con `00000005` y `CONCLUIDA=false`. Tres no tenían respuesta de ANL; la cuarta estaba aceptada (`ESTADO=1`, desbloqueo `S`) pero no concluida. Son solicitudes existentes: no se avanzaron ni se usaron como pares.

Se consultó por póliza el registro de CORE TEST en siete referencias históricas: dos wAutemis no devolvieron solicitudes, pero no se verificó una fecha de anulación admisible con nivel 05/06 para ambas (a vencimiento, la evidencia de R45-B/R48-A muestra el límite de 18 meses de NEW). Las cuatro referencias NSE consultadas tenían solicitudes previas: dos en estado 2 y dos ya cerradas; ninguna era un caso vivo `MECANIZADA/ANL`. No se identificó un par apto en lo revisado. Para continuar hacen falta:

- **Mecanizar:** dos pólizas wAutemis reservadas para TEST, sin solicitud en curso, con la misma ruta hasta una tarea de mecanización y fecha de anulación admitida por NEW que devuelva `00000005` o `00000006`. ANL debe crear una fila correlacionada por solicitud; hace falta poder observar el desbloqueo o el fallo reproducible, sin reutilizar los casos existentes.
- **MecanizarNSE:** dos pólizas de TEST NSE-Autos/NSE-Hogar no wAutemis, sin solicitud en curso, con simulación y fecha que dejen por el flujo normal la solicitud en `MECANIZADA`, con ANL activo, y permitan superar la actualización previa al nodo 12. Hace falta otro par equivalente que permita provocar un error de autorización o de su escritura dentro del tramo extraído.

No se escribieron solicitudes ni filas de CORE o ANL. Las lecturas y versiones de los hijos están en `files/sca2-avisos-monitorizacion/` (`inbox38-busqueda-sca2-vivos.json`, `inbox38-busqueda-anl-lecturas.json`, `inbox38-busqueda-cartera-consultas.json`, `inbox38-hijo-*-v2.0.json`).

### Candidatos de CompletarAccion y CrearAccion; bloqueo de las pruebas por pares

Las URLs directas del modelador con `idToOpen=1177` y `idToOpen=1178` no abrieron los modelos activos en una pestaña nueva. Tras liberar las pestañas del modelador, el buscador de objetos de Designer sí abrió **CompletarAccion v61.0** y **CrearAccion v34.0**. «Guardar como» conservó los 46 y 40 nodos respectivos; Designer limitó a 40 caracteres el nombre de la copia de CompletarAccion.

| PM activo (sin cambios) | Copia aislada publicada solo en TEST | Corte verificado |
| --- | --- | --- |
| CompletarAccion v61.0 | `SCA2 CMD CompletarAccion Designer Candid` v2.0 (`002ef0c1-8dfb-8000-dc22-7f0000014e7a`) | 25 nodos; el nodo 8002 llama a Documentos y Cierre Externo v2.0; se conservan los arranques heredados 8, 10 y 12. |
| CrearAccion v34.0 | `SCA2 CMD CrearAccion Designer Candidato` v3.0 (`0028f0c1-8e2f-8000-dc23-7f0000014e7a`) | 28 nodos; el nodo 8002 llama a Alta CORE y Registro de Acción v2.0; se conservan los arranques heredados 14, 15 y 36. |

La API no permite sustituir el tipo de un nodo reutilizando su ID. La actualización atómica de cada copia con un ID nuevo para el subproceso sí conservó el tipo, los datos y la asignación de los arranques `start-process-5` existentes. La operación previa de añadir el enrutador de CrearAccion por nodo publicó automáticamente la copia v1.0; era intermedia y sin llamadores. En la primera versión con el corte, la API había asignado literal 1 a `PauseOnError` en las escrituras que seguían en el padre. Las versiones de la tabla recuperan `=false()` y literal 0 en los padres; las escrituras de los hijos mantienen ese mismo valor. La lectura publicada confirma llamadas síncronas con encadenamiento, borrado a un día y ningún llamador para los padres candidatos. Designer confirma el grupo **SCA2 Alertas** en los dos padres y en los dos hijos. No se comprobó la recepción de alertas ni se verificó la desaparición de los avisos en los modelos activos.

**CompletarAccion.** Se verificó que las cuatro pólizas NSE-Autos de TEST estaban vigentes y sin solicitud en curso. Se lanzaron cuatro altas nuevas con `SCA2 CMD Alta` v50.0, en dos pares por producto. Las cuatro altas terminaron `COMPLETED`, con `generar.success=true` y `wrErr=false`. Las solicitudes llegaron a `EN_ACCION`, Acciones Administrativas, versión 3, con tarea pendiente asignada a `devin`. Pero las cuatro registraron `DECISION_ERROR` previo al llegar a ese estado (HTTP 500, código de servicio `1107`, en «Consultar reglas» de Decidir). No se usaron como pares limpios, no se avanzó ninguna tarea ni se creó la copia del formulario. Para probar el corte, un par nuevo debe llegar sin ese error y poder finalizar las tareas aportando documentación; una finalización sin `listaNombreDocs` no prueba el tramo extraído.

| Par | Solicitud | Instancia Alta | Tarea pendiente | Error previo |
| --- | --- | --- | --- | --- |
| AU01 | 15789329 | 15569424 | 982 | 328 |
| AU01 | 15789330 | 537693715 | 983 | 329 |
| AU02 | 15789331 | 12392677 | 984 | 330 |
| AU02 | 15789332 | 14500847 | 985 | 331 |

**CrearAccion.** El alta normal ya ejecuta el modelo activo antes de devolver el control: Alta v50.0 (nodo 12) espera a Decidir v32.0, cuyo nodo 12 espera a `cons!SCA2_PM_CMD_CREAR_ACCION`. Las cuatro altas lo confirman con una transición `DECIDIDA → EN_ACCION` de CrearAccion y una tarea ya creada. Ejecutar el candidato sobre esas solicitudes no prueba la creación de la primera tarea desde el mismo estado y podría repetir una gestión; tampoco se tomó el estado `DECIDIDA` transitorio como un punto de prueba aislado. Falta un modo autorizado de dejar dos altas nuevas en el mismo estado antes de que CrearAccion se dispare, sin redirigir el despacho compartido ni alterar Decidir. No se creó el arranque aislado.

Se dejan las copias sin llamadores ni ejecución. No se promovió ningún modelo activo; tampoco se alteraron o avanzaron solicitudes anteriores. Las únicas escrituras de datos procedieron del flujo normal de las cuatro altas de TEST, sin DDL/DML directo. **Mecanizar v52.0 y MecanizarNSE v10.0** quedan a la espera de los datos ANL indicados arriba. Las copias originales, los candidatos publicados, las capturas `inbox38-*-corte-designer.png` y `inbox38-*-alertas-designer.png`, y las lecturas de las altas y registros `inbox38-pruebas-*` están en `files/sca2-avisos-monitorizacion/`.

### CompletarAccion: comparación de CANCELAR y bloqueo de FINALIZAR

Para esta ronda se aceptó el mismo `DECISION_ERROR` 1107 previo como punto de partida de ambos pares. Se creó en TEST `SCA2_INBOX38_AccionesAdministrativasPrueba`, copia del formulario que cambia únicamente los destinos de CANCELAR y FINALIZAR por `SCA2_PM_INBOX38_COMPLETAR_PRUEBA` (candidato v2.0) y restringe la vista al usuario de prueba y a los pares solicitud/tarea `15789330/983` y `15789332/985`. La evaluación mostró los botones para ambos pares y denegó `15789330/985`. No se cambió ningún llamador del sitio ni la constante activa.

| Acción | Publicado | Candidato | Resultado |
| --- | --- | --- | --- |
| CANCELAR | 15789331/984, instancia 15569451 v61.0 | 15789332/985, instancia 15569452 v2.0, hijo 15569453 v2.0 | Se confirmó la acción desde el sitio y desde la vista aislada de Designer, respectivamente. Las tres instancias terminaron `COMPLETED`. |
| FINALIZAR | 15789329/982 | 15789330/983 | No ejecutado. Ambos formularios mostraron «No hay elementos disponibles» en Documentos y FINALIZAR deshabilitado con el aviso que exige informar de la entrega. |

**CANCELAR, sin adjuntos en ambos lados.** La ruta de negocio fue la misma: completar Tarea, escribir `PDTE_FINALIZAR`, pasar por la lógica documental sin adjuntos ni llamada de cierre en ese bloque, registrar la transición y lanzar Finalizar. El historial del candidato mueve `Subir documentos GD → ¿Docs GD ok? → Llamada cierre?` al hijo y añade la evaluación de su resultado en el padre. Las PV comunes solo difirieron en identificadores o datos de cada solicitud, póliza o cliente; `wrErr=false` y `mcaEstadoFinal=CANCELADO` en ambas. El candidato añadió la PV técnica `resultadoBloque1=TRANSICION_OK`.

- **Solicitud / Tarea:** ambas quedaron en `CANCELADA/FIN`, versión 5, con la tarea original `COMPLETADA`.
- **Transición / Llamada Servicio:** las transiciones 3555–3558 registraron los mismos pasos `EN_ACCION → PDTE_FINALIZAR → CANCELADA`; llamadas 519 y 520 a `SCA2_finalizarSolicitudIntegracion`, ambas `OK`, HTTP 200.
- **Error / alertas:** solo se encontraron los `DECISION_ERROR` previos (330 y 331); no hubo error nuevo para estas solicitudes. No se verificó el envío ni la recepción de alertas.

**FINALIZAR con adjuntos.** Las dos solicitudes son NSE-Autos con causa 14 y ninguna muestra filas en la cuadrícula. El botón de adjuntar existe por fila: la acción 1 solo genera filas para NSE-Hogar o las causas admitidas por `SCA2_AccionesAdministrativasDocumentacion`. Se prepararon dos PDF ficticios idénticos, pero la UI no ofreció dónde subirlos. Marcar «El cliente no entrega documentación» habilitaría otra ruta y no validaría la subida en el tramo extraído; no se marcó. Hace falta un par nuevo y equivalente cuya causa u origen muestre los tipos de documento requeridos (DNI y al menos otro tipo admitido), y acotarlo de nuevo en el formulario de prueba.

No se promovió **CompletarAccion v61.0** ni se hizo una comprobación de Monitorización posterior a la promoción. Se cerró la vista de Designer y se dejaron la interfaz, la constante y la copia candidata sin uso ni llamadores del sitio; el único dependiente de la interfaz es su aplicación contenedora. **CrearAccion v34.0** sigue sin promoción ni arranque aislado; **Mecanizar v52.0** y **MecanizarNSE v10.0** siguen pendientes de las pólizas y datos ANL. No se avanzó ninguna solicitud ajena a los pares. Las capturas `inbox38-cancelar-*-confirmacion.png`, `inbox38-finalizar-*-previo.png`, los historiales `inbox38-cancelar-eventos-*.json` y las lecturas `inbox38-cancelar-despues-*` están en `files/sca2-avisos-monitorizacion/`.

### FINALIZAR con adjuntos en NSE-Hogar

Se consultaron pólizas vigentes de TEST, sin solicitudes en CORE ni en el registro SCA2. Las cuatro altas nuevas de Hogar terminaron `COMPLETED`, con `generar.success=true` y `wrErr=false`. El primer par (causa 1) no servía: `15789333` terminó en `ERROR_DECISION` con HTTP 500/1107 y `15789334` abrió una tarea de Contra Anulación. No se avanzaron. El segundo par (causa 32, «VENTA SIN REEMPLAZO») llegó a Acciones Administrativas, nivel 1, `EN_ACCION`, versión 3, con tarea pendiente para el mismo usuario:

| Variante | Póliza TEST | Solicitud / tarea | Instancia Alta | Instancia CompletarAccion |
| --- | --- | --- | --- | --- |
| Sitio normal | 0732500124161 | 15789335 / 988 | 14500905 | 9249787, v61.0 |
| Formulario aislado | 0731700096594 | 15789336 / 987 | 14500906 | 10303971, v2.0; hijo 10303972, v2.0 |

Se limitó el formulario aislado a `15789336/987`; la evaluación confirmó la denegación de la solicitud de control. En ambas pantallas se adjuntaron los mismos PDF ficticios como DNI y Anulación firmada, se verificó que FINALIZAR quedó habilitado y se confirmó la acción. Los tres procesos de CompletarAccion terminaron `COMPLETED`; `docsResult` devolvió `success=true`, 2 documentos y 2 subidos en ambos. Las diferencias en `docsResult` son los IDs de documento y de referencia. Ambas PV de resultado indicaron `FINALIZADA`, `OK`, y `wrErr=false`; el candidato añadió `resultadoBloque1=DECIDIR`. La entrada `resultado.tipoPersona` ya difiere por cliente: solo el control tenía el indicador «Cliente Alquimia».

- **Ruta, Solicitud, Tarea y Transición:** se comprobó el mismo recorrido hasta escribir `DECIDIR` y ejecutar el arranque síncrono de Decidir (nodo 12). El sucesor acabó llevando los dos casos a `PDTE_MECANIZAR`, versión 5, con la tarea de Acciones Administrativas completada (987/988), una nueva tarea pendiente (989/990) y las mismas transiciones funcionales (3569–3574).
- **Llamada Servicio:** no se registraron filas nuevas para FINALIZAR en este par; las dos existentes correspondían al alta. El resultado de la subida se verificó en las PV de CompletarAccion y en el historial del hijo.
- **Error:** el control ya tenía el 334 (HTTP 500/1107, `RELANZADO`) antes de FINALIZAR y no añadió ningún error posterior. La solicitud del candidato añadió el 335, `DECISION_ERROR` HTTP 500/1108, intentos 2, `PENDIENTE` en la lectura. La instancia 15569483 de **Decidir v32.0**, con `regla=mecanizar`, contiene el 1108 y ejecutó `Write Error → Start Decidir (reintento)`. El siguiente Decidir del caso candidato y el Decidir del control devolvieron `MECANIZAR`. No se modificó ni se relanzó manualmente Decidir. No se verificó la entrega de alertas.

**Sin promoción:** el resultado documental coincide, pero el par no demuestra equivalencia completa: el estado inicial de las filas de Error y una entrada de cliente difieren, y el recorrido posterior del candidato añade un error y reintento. No se atribuye esa diferencia al troceado. Para cerrar la comparación hace falta otro par de NSE-Hogar (o una causa que admita ambos documentos) con la misma clasificación de cliente, historial de error comparable y una respuesta de reglas reproducible en `mecanizar`. Se cerró la vista aislada y quedó sin uso; no se tocaron llamadores compartidos. Tampoco se promovieron CrearAccion, Mecanizar ni MecanizarNSE. Sin nueva versión activa, no se ejecutó una verificación posterior a la promoción ni una comprobación nueva de Monitorización. Evidencias: `files/sca2-avisos-monitorizacion/inbox38-finalizar-hogar-*`.

### Última prueba de FINALIZAR con Cliente Alquimia (23/11/2026)

Se crearon tres altas NSE-Hogar con la causa 32 («VENTA SIN REEMPLAZO»). Las tres terminaron `COMPLETED` con `generar.success=true`, en `EN_ACCION` v3 y con una tarea de Acciones Administrativas asignada a `devin`. Se descartó `15789338/992`: solo esa alta tenía un error previo (fila 336, HTTP 500/1107 en Decidir, `RELANZADO`). No se avanzó su tarea. Las solicitudes `15789337` y `15789339` no tenían filas de Error antes de FINALIZAR y coincidían en la clasificación: Cliente Vigente, Cliente Alquimia, Cliente Mayor de Edad y Cliente Tomador de alguna póliza vigente.

| Solicitud / tarea | CompletarAccion | Resultado de FINALIZAR | Estado al terminar Decidir |
|---|---|---|---|
| `15789337/991` | Publicado v61.0, instancia `13455314` | `COMPLETED`, tarea `COMPLETADA`, transición 3584 `EN_ACCION → DECIDIR` | `PDTE_MECANIZAR` v5, tarea de mecanización 994 pendiente; sin filas de Error |
| `15789339/993` | Candidato v2.0, instancia `12392744`, hijo `12392745` | Padre e hijo `COMPLETED`, tarea `COMPLETADA`, transición 3585 `EN_ACCION → DECIDIR` | `ERROR_DECISION` v4, sin tarea de mecanización; filas de Error 337 y 338 |

Ambas pantallas admitieron los mismos PDF de prueba como DNI y Anulación firmada y habilitaron FINALIZAR. En ambos recorridos se completó la tarea, se guardó la trazabilidad, se subieron dos documentos (`docsResult.success=true`, `numSubidos=2`, `wrErr=false`) y se despachó a Decidir. La comparación de PV solo mostró diferencias en datos e identificadores propios de cada caso y `resultadoBloque1=DECIDIR`, salida técnica del hijo. En Llamada Servicio solo constaron las altas (filas 525 y 527, HTTP 200); no se registraron filas nuevas en este tramo. No se verificó la recepción de alertas.

Decidir v32.0 consultó `mecanizar` en ambos casos, con el mismo perfil, subperfil, línea, nivel y origen. En el control, la instancia `14500941` creó el destino de mecanización y se abrió la tarea 994 (transiciones 3586 y 3587). En el candidato, la instancia `9249802` siguió `Consultar reglas → Write Error → Start Decidir (reintento)`; el reintento `16587154` siguió `Consultar reglas → Write Error bloqueado`. Ambos registraron HTTP 500/1108. La primera instancia se ejecutó **dentro del despacho** de CompletarAccion (`22:47:03.960–22:47:06.300 UTC`, con el padre `COMPLETED` a las `22:47:06.360`); el reintento comenzó después (`22:47:12.150 UTC`). El hijo había terminado a las `22:47:03.650 UTC`, antes de las dos consultas.

**Sin promoción.** El historial sitúa los HTTP 500 en la consulta a reglas de Decidir, no en el tramo extraído, y no demuestra que el troceado los haya causado. Pero el primer fallo no fue posterior al fin del padre y el estado final no coincidió. No se relanzó Decidir manualmente. Se cerró el formulario aislado, que queda sin uso y acotado a `15789339/993`; no se tocaron llamadores compartidos. CompletarAccion sigue en v61.0; CrearAccion, Mecanizar y MecanizarNSE siguen sin promoción, estos dos últimos pendientes de datos de prueba ANL. Evidencias: `files/sca2-avisos-monitorizacion/inbox38-ultimo-*` (capturas de adjuntos y confirmación, PV, eventos y filas de los registros).

### Comprobación de disponibilidad en TEST (24/11/2026)

A las 06:52:48 UTC, una evaluación de solo lectura de `SCA2_consultarServiciosReglas` con el DTO del caso que había fallado (`15789339`, regla `mecanizar`) devolvió `accion=MECANIZAR` sin error. La última fila `DECISION_ERROR` observada era todavía la 338 del 23/11; se comprobó el servicio directamente porque ese histórico no acreditaba su estado actual. La evaluación exitosa acredita esa consulta, no la disponibilidad general del servicio. Evidencia: `files/sca2-avisos-monitorizacion/inbox38-reglas-disponibilidad-consulta.json`.

**FINALIZAR no se repitió:** la integración de lectura `SCA2_APIClients_search` devolvió HTTP 500 (`UNKNOWN_ERROR`) en dos pólizas de control previamente clasificadas. No se pudo verificar la misma clasificación, incluido Cliente Alquimia, en un par nuevo. Es un servicio distinto del de reglas y de `IGenerarContraAnul`, cuyo HTTP 500 en CORE TEST fue reportado por caducidad y no se volvió a probar. No se crearon altas, no se avanzaron solicitudes y no se publicaron modelos.

### Comprobación previa a Mecanizar y MecanizarNSE (24/11/2026, 14:19 UTC)

La consulta de solo lectura a `SCA2_APIClients_search` devolvió HTTP 500 (`UNKNOWN_ERROR`) en ambas pólizas de control: `0732400254564` a las 14:19:32.752 UTC y `0739980204232` a las 14:19:32.685 UTC. En la misma comprobación, el servicio de reglas devolvió `accion=MECANIZAR` sin error a las 14:19:37.461 UTC. Evidencia: `files/sca2-avisos-monitorizacion/inbox38-preflight-mecanizar-2026-11-24T14-19-32-752Z.json`.

**No se inició la comparación de extremo a extremo.** El fallo de clientes impidió seguir con las altas de prueba. No se consumieron pólizas de `Polizasgeneral.xlsx`, no se crearon ni avanzaron solicitudes y no se publicó ningún modelo. No se ejecutó `IGenerarContraAnul` en esta comprobación.

Se repitió la consulta de clientes, también en solo lectura, con tres pólizas de `Polizasgeneral.xlsx` distintas de las de control. En TEST constaban como vigentes, producto 73 (Hogar), canal NSE, sin filas en SCA2 Solicitud al comprobarlas. Las tres devolvieron HTTP 500 (`UNKNOWN_ERROR`) el 24/11/2026:

| Póliza consultada | Hora de respuesta (UTC) |
|---|---|
| `0732400001493` | 14:21:26.456 |
| `0732400001966` | 14:21:26.563 |
| `0732400007366` | 14:21:26.446 |

El fallo no se limitó a las pólizas de control. No se crearon solicitudes ni se consumieron pólizas; no se ejecutaron las pruebas por pares de MecanizarNSE o Mecanizar. Evidencia: `files/sca2-avisos-monitorizacion/inbox38-preflight-clientes-polizas-excel-2026-11-24T14-21-24-644Z.json`.

### Primer intento por el flujo normal de MecanizarNSE (24/11/2026)

El botón «Solicitud de prueba» de `SCA2_APIClients_search` en **Designer de TEST** devolvió **HTTP 200** y datos de cliente en vigor para `0732400001493` (14:38:57.829 UTC) y `0732400001966` (14:39:00.177 UTC), con el cuerpo de consulta del alta. Estas comprobaciones no usaron `testRule`. Al comprobar SCA2 Solicitud a las 14:43:24.558 UTC, no había filas para ninguna de las dos pólizas de `Polizasgeneral.xlsx`.

Se inició un solo caso por el sitio normal: `0732400001493` → solicitud **15789357**, NSE-Hogar, «Anulación fuera de norma», canal presencial, catalogación A FECHA (24/11/2026). La fila **838** de SCA2 Llamada Servicio registra `SCA2_generarStudAnul` con `OK / HTTP 200`. Las transiciones **3812–3814** dejan el caso en `EN_ACCION / AUTORIZACION`, con la tarea **1002** pendiente. Sin embargo, la fila **539** de SCA2 Error registra un `DECISION_ERROR` de **HTTP 500, código 1107**, en «Consultar reglas» de `SCA2 CMD Decidir`, para esta misma solicitud. El avance a Autorización no elimina el error del servicio.

**Se detuvo la prueba al detectar ese error.** No se completó la tarea, no se dio de alta `0732400001966`, no se consumieron más pólizas y no se llegó a la precondición `MECANIZADA / ANL` de MecanizarNSE. No hay una pareja de ejecuciones para comparar PVs, ruta ni registros. Se verificaron las versiones MecanizarNSE **v10.0** y su candidata aislada **v1.0**. Mecanizar **v52.0** no se ejecutó; la búsqueda en TEST no devolvió un padre candidato de Mecanizar. No hubo promoción ni verificación posterior en Monitorización. Evidencia: `files/sca2-avisos-monitorizacion/inbox38-pares-mecanizar-primer-intento.json`.

### Revalidación antes de retomar MecanizarNSE y Mecanizar (25/11/2026)

Se hicieron dos rondas de solo lectura en TEST con `SCA2_consultarServiciosReglas`. Para `accion` se reconstruyó la entrada de «Consultar reglas» de la solicitud de prueba `15789357` (instancia `537696665`) con `SCA2_mapearDatosDecidirAccion`, sin relanzar Decidir ni avanzar la tarea. Para `mecanizar` se reutilizó el DTO de prueba guardado de `15789339`.

| Consulta | Primera ronda (UTC) | Reintento (UTC) |
|---|---|---|
| `mecanizar` | 07:53:34.879 — `ERROR`, HTTP 500/1108 | 07:56:27.453 — `ERROR`, HTTP 500/1108 |
| `accion` | 07:53:56.318 — `AUTORIZACION`, sin error | 07:56:28.672 — `AUTORIZACION`, sin error |

En Designer, «Solicitud de prueba» de `SCA2_APIClients_search` devolvió **HTTP 200** y cliente en vigor para `0732400001966` a las 07:54:51.660 UTC. El bloqueo actual es el HTTP 500 de la consulta `mecanizar`; en estas rondas no se reprodujo el 1107 que se había observado en `accion`. **No se reanudaron las pruebas por pares**, no se consumieron pólizas, no se crearon ni avanzaron solicitudes y no se promovieron modelos. Evidencia: `files/sca2-avisos-monitorizacion/inbox38-20261125-preflight-reglas-y-clientes.json`.

### Nueva comprobación de reglas en TEST (25/11/2026, 08:35 UTC)

Las siguientes evaluaciones de `SCA2_consultarServiciosReglas` fueron de solo lectura y usaron datos de pruebas anteriores:

| Consulta | Hora UTC | Resultado |
|---|---:|---|
| `mecanizar`, DTO de `15789337` | 08:35:22.943 | Error de evaluación; sin respuesta HTTP verificable del servicio |
| `mecanizar`, DTO de `15789339` | 08:35:26.227 | `MECANIZAR`, sin error |
| `accion`, entrada de «Consultar reglas» de `15789357` | 08:35:26.967 | `ERROR`, HTTP 500/1107 |
| `mecanizar`, reintento con DTO de `15789339` | 08:35:46.173 | `MECANIZAR`, sin error |

El HTTP 500/1107 de `accion` impide reanudar los pares aunque `mecanizar` haya respondido en dos consultas. No se consumieron pólizas, no se crearon ni avanzaron solicitudes y no se promovieron modelos. Las tres pólizas reservadas para convivencia del piloto, excluidas de ambas pruebas, están en [REGISTRO.md](pruebas/polizas/REGISTRO.md). Evidencia: `files/sca2-avisos-monitorizacion/inbox38-20261125-reglas-0835-y-reserva-piloto.json`.

### Sondeos de dependencias en TEST (25/11/2026)

Se exige que las cuatro dependencias respondan bien en una misma ronda para iniciar los pares. La API de clientes se prueba con «Solicitud de prueba» de Designer, en la integración `SCA2_APIClients_search`. Para CORE se usa la lectura `SCA2_consultarDetalleSolicitud` → `consultaDetalleSolicitud`, del mismo connected system y endpoint SOAP `IGenerarContraAnul`; se verifica que devuelva el detalle de la referencia de prueba existente. Este sondeo comprueba la consulta, no la operación de generación `generarStudAnul`, que no se ejecuta.

| Hora UTC de la ronda | «Consultar reglas» (`accion`) | `mecanizar` | Clientes (Designer) | CORE (solo consulta) |
|---|---|---|---|---|
| 08:41:06 | `ERROR`, código `1107`, con estado HTTP no capturado | Error de evaluación en dos consultas; sin HTTP verificable | HTTP 200 | Detalle devuelto |
| 08:41:24 | `AUTORIZACION`, sin error | Primero `MECANIZAR`; después HTTP 500/`1108` | HTTP 200 | Detalle devuelto |
| 09:11:25 | `AUTORIZACION`, sin error | `MECANIZAR` a las 09:11:29.854; HTTP 500/`1108` a las 09:11:32.611 | HTTP 200 | Detalle devuelto |
| 09:41:24 | `AUTORIZACION`, sin error | HTTP 500/`1108` a las 09:41:29.220 y 09:41:31.684 | HTTP 200 | Detalle devuelto |
| 10:11:25 | HTTP 500/`1107` a las 10:11:29.411 | `MECANIZAR` en ambas consultas | HTTP 200 | Detalle devuelto |
| 10:41:24 | HTTP 500/`1107` a las 10:41:29.712 | HTTP 500/`1108` a las 10:41:28.296; después `MECANIZAR` | HTTP 200 | Detalle devuelto |
| 11:11:24 | `AUTORIZACION`, sin error | HTTP 500/`1108` a las 11:11:28.825 y 11:11:31.630 | HTTP 200 | Detalle devuelto |
| 11:41:25 | HTTP 500/`1107` a las 11:41:28.833 | `MECANIZAR` en ambas consultas | HTTP 200 | Detalle devuelto |
| 12:11:25 | HTTP 500/`1107` a las 12:11:29.810 | HTTP 500/`1108` a las 12:11:28.036 y 12:11:31.619 | HTTP 200 | Detalle devuelto |
| 12:41:25 | HTTP 500/`1107` a las 12:41:28.699 | HTTP 500/`1108` a las 12:41:27.939; después `MECANIZAR` | HTTP 200 | Detalle devuelto |
| 13:11:25 | HTTP 500/`1107` a las 13:11:32.029 | `MECANIZAR` en ambas consultas | HTTP 200 | Detalle devuelto |
| 13:41:24 | HTTP 500/`1107` a las 13:41:28.941 | HTTP 500/`1108` a las 13:41:26.833; después `MECANIZAR` | HTTP 200 | Detalle devuelto |

El sondeo se cerró a las 13:53 UTC por indicación de coordinación. Ninguna de las 12 rondas, incluidas las dos comprobaciones iniciales, tuvo éxito simultáneo en las cuatro dependencias: el servicio de reglas siguió devolviendo HTTP 500 de forma intermitente. No se iniciaron los pares de MecanizarNSE ni Mecanizar, no se crearon ni avanzaron solicitudes, no se consumió ninguna póliza y no se promovieron modelos. Las exclusiones del piloto de [REGISTRO.md](pruebas/polizas/REGISTRO.md) no cambiaron.

Evidencia depurada por ronda: `files/sca2-avisos-monitorizacion/inbox38-sondeo-servicios-20261125.jsonl`.

### Nueva comprobación en TEST (26/11/2026)

| Comprobación de solo lectura | Hora UTC | Resultado |
|---|---:|---|
| «Consultar reglas» (`accion`), control de `15789357` | 08:20:27.750 | Appian devolvió HTTP 404, `Process instance not found: 537696665`. No se llamó al servicio de reglas para `accion` con este control. |
| CORE, `consultaDetalleSolicitud` | 08:20:27.905 | Devolvió el detalle de la referencia esperada; no se ejecutó `generarStudAnul`. |
| `mecanizar`, DTO de `15789339` | 08:20:32.189 y 08:20:34.509 | `MECANIZAR`, sin error en ambas consultas. |
| API de clientes, «Solicitud de prueba» de Designer | 08:20:32.491 | HTTP 200, cliente en vigor. |
| `accion`, comprobación diagnóstica con la copia guardada de `15789339` | 08:21:16.489 | `ACCIONES ADMINISTRATIVAS`, sin error. |

El 404 corresponde a la lectura del historial de Appian, no al servicio de reglas. No se observó HTTP 500 en las consultas que llegaron al servicio. Como la ronda inicial no pudo completar `accion` con el control previsto y la lectura diagnóstica usó otro caso, no se inició ningún par de MecanizarNSE ni Mecanizar. No se consumieron pólizas, no se crearon ni avanzaron solicitudes y no se promovieron modelos. Evidencia: `files/sca2-avisos-monitorizacion/inbox38-sondeo-servicios-20261126.jsonl` e `inbox38-sondeo-accion-20261126.json`.

### Ronda rápida y primer caso de MecanizarNSE en TEST (26/11/2026)

El 404 anterior se debió al borrado de la instancia de control al cabo de un día. La ronda rápida de solo lectura pasó con el caso alternativo y las demás dependencias en la misma ronda:

| Comprobación | Hora UTC | Resultado |
|---|---:|---|
| CORE, `consultaDetalleSolicitud` | 08:22:31.840 | Detalle de la referencia esperada. |
| API de clientes, «Solicitud de prueba» de Designer | 08:22:34.804 | HTTP 200, cliente en vigor. |
| `accion`, copia guardada de `15789339` | 08:22:35.127 | `ACCIONES ADMINISTRATIVAS`, sin error. |
| `mecanizar`, dos consultas | 08:22:36.241 y 08:22:38.768 | `MECANIZAR`, sin error en ambas. |

Se comprobó que la póliza NSE-Hogar `0732400001966` de Polizasgeneral.xlsx no tenía una solicitud previa en SCA2. Se creó por el flujo normal la solicitud `15789388` (alta `13468189`), se tramitó la autorización con adjuntos y se llegó a `PDTE_MECANIZAR / MECANIZAR` con la tarea `1029`. La simulación devolvió nivel `INFORMATIVO` y permitió pulsar «ANULAR PÓLIZA».

| SCA2 Llamada Servicio | Servicio | Hora UTC | Resultado registrado |
|---|---|---:|---|
| 1179 | `SCA2_generarStudAnul` | 08:30:06 | OK / HTTP 200 |
| 1180 | `SCA2_aceptarAutorizacionIntegracion` | 08:32:24 | OK / HTTP 200 |
| 1181 | `SCA2_guardarMecanizacionIntegracion` | 08:34:15 | OK / HTTP 200 |

**No se obtuvo una entrada utilizable para MecanizarNSE.** La anulación ejecutó **Mecanizar v52.0** (instancia `9262022`) como paso previo: `success=true`, `err=null`, `wrErr=false`, `observaciones=null`, `llamadaHttp=200`. La transición `3915` registró `MECANIZADA` a las 08:34:16. El historial muestra que la instancia siguió del nodo 324 a «Recargar solicitud» y «Write Cambio nivel», no a la espera de ANL reservada a wAutemis con observaciones `00000005`/`00000006`. A las 08:34:19 la transición `3916` marcó `IR A NIVEL 2` y se finalizó la tarea `1029`; a las 08:34:27 la solicitud llegó a `FIN / FIN PROCESO`. La tarea de inducción `1030` seguía pendiente en la última lectura (08:34:46.439), que no devolvió filas en SCA2 Error.

El caso no quedó en `MECANIZADA / ANL`, condición que comprueba el nodo 4 de MecanizarNSE. No se ejecutó ese modelo, ni publicado ni candidato. Tampoco se probó por pares el tramo de espera de Mecanizar: la instancia v52.0 fue solo la preparación del caso NSE y no pasó por ese tramo. Se detuvo el intento sin consumir más pólizas. No hay comparación de PVs, ruta, Solicitud, Tarea, Transición, Llamada Servicio y Error entre versiones, ni promoción ni comprobaciones posteriores a una promoción. Para retomar, hace falta identificar antes de consumir otra póliza una ruta ordinaria que deje un caso NSE elegible para MecanizarNSE; para Mecanizar, hacen falta entradas wAutemis que alcancen la espera y un padre candidato aislado.

Única póliza consumida en esta ronda: `0732400001966`, anotada en [REGISTRO.md](pruebas/polizas/REGISTRO.md). Evidencia en `files/sca2-avisos-monitorizacion/`: `inbox38-sondeo-servicios-20261126.jsonl` e `inbox38-flujo-26nov-15789388-{antes-mecanizar,tras-anular,despues-mecanizacion,mecanizar-pv-ruta}.json`.

### Reutilización del control v52.0 y selección de pólizas en solo lectura (26/11/2026)

La ronda de 08:38:48.856–08:38:55.382 UTC volvió a pasar: `accion` devolvió `ACCIONES ADMINISTRATIVAS`, las dos consultas `mecanizar` devolvieron `MECANIZAR`, clientes devolvió HTTP 200 desde Designer y CORE devolvió el detalle esperado.

**Mecanizar: `15789388` queda como mitad publicada del par NSE-Hogar.** Se conserva la ruta de la instancia `9262022`, v52.0, con nivel de entrada 1, `observaciones=null`, `success=true`, `err=null`, `wrErr=false` y `llamadaHttp=200`. La rama principal pasó por `MECANIZADA → IR A NIVEL 2 → FIN`, cerró la tarea de mecanización `1029` y alcanzó el nodo End. La solicitud terminó en `FINALIZADA / COMPLETADA` a las 08:39:15 UTC, mediante la transición de `SCA2 CMD Finalizar`; `SCA2_finalizarSolicitudIntegracion` registró `OK / HTTP 200` a las 08:39:13 UTC. La lectura de las 08:39:45.245 UTC no devolvió filas de SCA2 Error. La tarea de inducción `1030` seguía pendiente y la instancia de Mecanizar aún figuraba `Active` a las 08:41:22.024 UTC. Este control sirve para la ruta NSE, no para validar la espera ANL de wAutemis.

`0732400007366` aparece en la columna NSE-Hogar del Excel, no tenía solicitudes en SCA2 a las 08:39:31.846 UTC y dio HTTP 200 con cliente en vigor desde Designer a las 08:41:38.986 UTC. Comparte el tipo del control; no se verificó equivalencia de la tarea ni de los parámetros de la simulación. En TEST, la búsqueda de modelos por `Mecanizar` devolvió solo el padre publicado para Mecanizar y cuatro objetos de MecanizarNSE; las búsquedas por los dos nombres de los subprocesos proyectados para Mecanizar no encontraron objetos. La acción «ANULAR PÓLIZA» de `SCA2_MecanizacionPrincipal` sigue apuntando a `cons!SCA2_PM_CMD_MECANIZAR`. No se usó la póliza sugerida: habría que preparar el padre reestructurado con sus subprocesos y un arranque aislado que conserve los parámetros y el contexto de oficina. Arrancar otra vez v52.0 con el botón normal no probaría la candidata.

**MecanizarNSE: no se identificaron pólizas nuevas aptas.** Se cruzaron las columnas de tipo de Polizasgeneral.xlsx con 445 solicitudes y 2.767 transiciones de SCA2. Las cuatro solicitudes que seguían en `MECANIZADA / ANL` eran wAutemis, de nivel de intervención 1; la evidencia previa de ANL muestra `observaciones=00000005` en las cuatro. Ninguna figuraba en el Excel y todas quedan fuera de MecanizarNSE por origen. De las 63 solicitudes NSE con transición a `MECANIZADA` (49 Autos y 14 Hogar; 11 pólizas presentes en el Excel), las 63 registraron después `IR A NIVEL 2`. El Excel identifica el tipo, no el nivel de cumplimiento ni la ruta. En v52.0, el nodo 324 solo conserva la espera para wAutemis con `00000005`/`00000006`; los demás casos siguen a recarga y cambio de nivel. Se confirmó además que `SCA2_BOOL_BATCH_NSE` sigue desactivado. No se identificó una vía ordinaria que deje una póliza NSE nueva en el estado requerido por el nodo 4 de MecanizarNSE.

**Pólizas adicionales consumidas: 0 de 6.** No se crearon solicitudes ni se usaron las excluidas. No se pudo ejecutar la mitad candidata de Mecanizar ni iniciar MecanizarNSE. No hubo comparación completa, promoción ni comprobaciones posteriores a una promoción. Evidencia en `files/sca2-avisos-monitorizacion/`: `inbox38-sondeo-servicios-20261126.jsonl`, `inbox38-26nov-control-y-candidatos.json`, `inbox38-26nov-elegibilidad-nse.json`, `inbox38-26nov-clientes-0732400007366.json` e `inbox38-flujo-26nov-15789388-control-publicado.json`.
