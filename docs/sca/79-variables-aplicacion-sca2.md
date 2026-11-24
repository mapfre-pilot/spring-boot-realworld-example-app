# Variables de la aplicación — inventario y diseño SCA2

Estado: propuesta; no se ha aplicado el SQL ni cambiado ningún objeto de Appian TEST. La pantalla es una **configuración operativa nueva de SCA2**, no una reproducción de una pantalla SCA: los dos sites SCA TEST apuntan al mismo menú (v1–v6), que no contiene la opción. El menú de [SCA2 TEST](https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/gestiones-mantenimiento) ya contiene la opción pendiente.

## Inventario y carga inicial

Se revisaron las 266 constantes de la aplicación SCA2 en TEST, sus dependencias para los candidatos, los PM operativos indicados y los documentos de mantenimiento. «Usos» cuenta objetos directos distintos que devuelve el índice MCP, sin contar la aplicación; puede incluir pilotos/pruebas y no equivale a ejecuciones ni a consumidores indirectos. «Literal» se cuenta por objeto cuando no existe una constante independiente. Los nombres abreviados de la primera columna llevan el prefijo `SCA2_`, salvo donde se indica un objeto con su nombre completo. Valores a volver a cotejar inmediatamente antes de la primera carga.

| Origen en TEST | Valor y tipo | Usos | Efecto |
|---|---|---:|---|
| `USAR_CACHE_CABECERA` | true · booleano | 7 | Leer/invalidar caché de cabecera en Detalle, Alta y reintentos. |
| `USAR_WEBAPI_CACHE_CABECERA` | true · booleano | 1 | Selecciona la vía Web API de lectura de cabecera. |
| `HORA_CADUCIDAD_CACHE_CABECERA` | 5 · entero (hora local) | 4 | Determina cuándo vence la cabecera cacheada. |
| `TXT_ZONA_HORARIA_CACHE_CABECERA` | Europe/Madrid · texto/IANA | 1 | Zona de cálculo de caducidad de la cabecera; no cambia el timer de ningún PM. |
| `CACHE_REFRESCO_BATCH` | 50 · entero (filas) | 1 | Páginas del PM de refresco de cabecera. |
| `RECORTAR_FILA_CACHE_CABECERA` | true · booleano | 1 | Ajusta los datos de cabecera a los tamaños persistibles; no cambia esos tamaños. |
| `USAR_TOKEN_CACHE_APICLIENTS` | true · booleano | 3 | Reutiliza el token en búsqueda, contacto y beneficios sin exponer credenciales. |
| `USAR_PROPIETARIO_APPIAN` | true · booleano | 2 | Selecciona el cálculo local de propietario. |
| `USAR_CATALOGOS_AURORA` | true · booleano | 6 | Selecciona lectura Aurora en los consumidores cableados y estado de su mantenimiento. |
| `USAR_POLIZA_RENOVADA_UNICA` | true · booleano | 1 | Selecciona cálculo de póliza renovada única en contraanulación. |
| `USAR_GESTION_PRECARGADA_BUSCADOR` | true · booleano | 1 | Reutiliza la gestión precargada en el buscador. |
| `VAL_ESPERA_DECISION_INICIAL_SEGUNDOS` | 30 · entero (s) | 1 | Espera inicial de la decisión desde Alta. |
| `VAL_ESPERA_DECISION_SONDEO_SEGUNDOS` | 30 · entero (s) | 3 | Intervalo de sondeo de la decisión en Alta/Detalle. |
| `VAL_ESPERA_AGOTADA_SEGUNDOS` | 90 · entero (s) | 3 | Cuándo mostrar «espera agotada»; no cancela la instancia. |
| `DIAS_CADUCIDAD_PROPIETARIO` | 14 · entero (días) | 1 | Regla por nivel para propietario donde aún se usa; no sustituye el plazo por acción. |
| `DIAS_CADUCIDAD_NO_PROPIETARIO` | 7 · entero (días) | 1 | Regla por nivel para no propietario. |
| Literal `7` en `SCA2_calcularCaducidadAccion` | 7 · entero (días naturales) | 1 directo, 5 consumidores de la regla incl. un objeto de prueba | Plazo al posponer; mantiene fin de día local y tope de vencimiento de póliza. Sin recálculo retroactivo. |
| Literal de límite de documentos | 52.428.800 · entero (bytes) | 1 directo; 4 interfaces propagan el bloqueo resultante según la ronda 76 | Máximo por archivo (50 MiB). Migrar juntos comparación, mensaje y flujos de continuación; caso exacto permitido. |
| `BOOL_BATCH_NSE` | false · booleano | 2 | Interruptor del batch NSE y lectura en ResumenBatch. No programa el batch. |
| `BOOL_BATCH_RESERVA_PRIMA` | false · booleano | 2 | Interruptor del batch Reserva Prima y lectura en ResumenBatch. No programa el batch. |
| `REINTENTO_FIN_ACTIVO` | true · booleano | 3 | Interruptor Appian de captura/reserva y del modelo de reintentos. No sustituye el segundo interruptor SQL. |
| `VAL_ESPERA_NSE_FINALIZAR_MAX_INTENTOS` | 10 · entero (intentos) | 1 | Máximo de esperas NSE en Finalizar; no cambia la duración del timer. |
| `USAR_OBSERVABILIDAD` | true · booleano | 12 | Activa instrumentación operativa en comandos; **no** desactiva la auditoría de variables. |
| `FECHA_INICIO_DATOS` | 2026-09-24 · fecha | 2 | Límite inferior para métricas de Cuadro de mando y su piloto. |

### Parámetros que no se cargan en el primer lote

No se descartan del análisis. Algunos necesitan migrar el mecanismo de programación, ajustar la validez cruzada o acordar antes un cambio de riesgo. No se publican valores internos de entorno, cuentas, correos o credenciales: GitHub confirma que el repositorio es público. Los destinos y correos vigentes se leen en Designer TEST bajo sus constantes, no en una semilla pública.

| Origen | Valor en TEST o evidencia | Usos | Decisión |
|---|---|---:|---|
| `BOOL_PILOTO_ACTIVO`, `USERS_DOMAIN` | false (booleano); dominio de identidad (texto) | 1 / 2 | Cambian el alcance de acceso del piloto; no ofrecer como ajuste operativo. |
| `GRP_ALERTAS`, `GRP_ADMINISTRADORES` | SCA2 Alertas / SCA2 Administrators · grupos | 3 indexados para Alertas, más referencias de seguridad que no recoge ese recuento | No editar destinatarios de fallos ni permisos del modelo desde el site. |
| CORE `1 APLICACION` y `2 TEXTO` | CDT SOAP con valor e inhibición de texto; consultadas ambas filas. El mensaje de TEST no se publica. | 1 / 3 objetos SCA2 que referencian directamente el lector | Excluidas de la tabla, la pantalla y el guardado. La 1 condiciona el alta y la 2 aporta su mensaje; escribir afectaría a SCA. |
| `HOST_SOA7`, `HOST_ESB`, `HOST_CORE7`, `HOST_APICLIENTS`, `WEBSERVICES_URL` | Texto; valores de entorno reservados | 3 / 1 / 1 / 1 / 17 | Destinos de integración, no puentear Connected Systems. CORE no se modifica; muchas reglas llaman a las constantes SCAC compartidas en lugar de las SCA2. Un futuro ajuste de enrutamiento debe limitarse a destinos aprobados del mismo entorno; nada de URL libre. |
| `FECHAULTIMOSINIESTRO_URL`, `FICHAAMPLIADA_URL`, `FORMAPAGO_URL`, `NUMPOLIZAVIDA_URL`, `NUMPOLIZA_URL`, `PLANPAGO_URL`, `TXT_URL_DOCUMENTACIONSCA`, `TXT_URL_GESCOMWEB`, `TXT_URL_GESTIONCOMPETENCIAS`, `TXT_URL_LOCALIZADOROFICINAS`, `TXT_URL_NSE`, `URL_TECUIDAMOS`, `TXT_ENLACE_CLUB_MAPFRE` | Texto; enlaces vigentes reservados | 1 cada uno | Enlaces de navegación, no parámetros de ejecución de negocio. |
| `TXT_LINK_GESVIDA`, `TXT_LINK_GESVIDA_CABECERA`, `TXT_URL_NSE_GUIADO` | Texto; enlaces vigentes reservados | 3 / 5 / 2 | Separar navegación de persistencia en cabecera antes de parametrizar. |
| `TXT_EMAIL_DUE_PARA_ALTITUDE`, `TXT_EMAIL_DUE_PARA_EXPERTOS`, `TXT_IP_TRAZABILIDAD` | Correo / correo / texto; valores reservados | 1 / 1 / 3 | Notificaciones y trazabilidad. Definir destinatarios permitidos y separar pruebas; el dato de trazabilidad no debe seguir siendo una IP editable. |
| `INT_COD_CIA_VIDA` | 3 · entero | 2 | Código contractual compartido por Alta y construcción de contexto. No es un umbral operativo; cambiarlo puede enrutar a otra compañía. También se usan códigos de compañía en DTOs (p.ej. 41), perfiles y catálogos: no editarlos desde el site. |
| `TXT_EXTENSIONES_DOCUMENTO` | PDF, PNG, TIFF, JPG, JPEG · lista | 1 | Lista de formatos permitidos. No ampliar tipos ni descoordinar upload/servidor por un ajuste de recuperación. |
| Barrido caducidad: hora del Start, tamaño de página | Programación documentada 01:00 Europe/Madrid; página 100 en PM TEST | 1 y 1 | Timer de diseño + cursor. Parametrizar la hora requiere un despachador que preserve calendarios y evite duplicados; lote pendiente de validar junto con el indicador «lote completo». |
| Caducidad por acción ordinaria | Día de entrada a las 23:59:59 Europe/Madrid · hora/zona | 1 regla | Regla de negocio explícita, no parte del interruptor técnico. No cambiar sin revisar semántica y solape con el barrido. |
| Mecanización NSE | Límite 500 · entero; SCA 02:30; SCA2 sin timer según documentación de Batch | 1 por valor | Reserva de capacidad; no encender ni copiar la hora mientras exista otro productor/consumidor. |
| Reserva Prima | Lote 30, reencolado TM +10 min · enteros; SCA 00:10 UTC, SCA2 sin timer según documentación de Batch | 1 por valor | Consistencia con TM y carga paralela; no mover programación ni productor. |
| Finalizar y lote de errores | Espera NSE 30 s, nuevo intento de recuperación +30 min, timer de lote 10 s · enteros; batch de reintento sin timer activo | 1 por valor | Separar timers de modelo de los cálculos en expresiones y verificar configuración de Designer al cablear. Los timeouts de nodos/conectores no se consideran constantes editables. |
| Reintento SQL `sca2_reintento_fin_config.habilitado` | Booleano; carga documentada false. **Actual TEST no verificado:** record con sync invalidada | Procedimientos de captura/ejecución; no es constante Appian | No sembrar ni duplicar la autoridad del control sin confirmar el valor real por la vía autorizada. No inferir el estado efectivo del batch de `REINTENTO_FIN_ACTIVO`. |
| Archivo histórico nocturno | 04:30 Europe/Madrid documentado para el simulador; un mes natural de retención; lanzador real con `maximo=0` observado como valor inicial del PM | 1 por concepto; no implica misma programación en el lanzador real | Guardas de corte, exclusiones, cupos/timeout y no solape: no editables sin validar el circuito de recuperación. |
| UUIDs, estados y códigos del contrato, máscaras de datos, literales de UI y credenciales | No aplicable | — | Son referencias, contratos o datos sensibles; nunca copiarlos a este catálogo. |

Para ampliar el lote, revisar los literales de los nodos, expresiones, integraciones y timers implicados, no solo sus nombres. El índice de dependencias no sustituye esa revisión, en particular para mínimos, máximos, timeouts del runtime o endpoints que están embebidos en un Connected System.

## Diseño de lectura, edición y auditoría

- `sca2_anulaciones.sca2_variable_aplicacion`: PK código estable; valor serializado, tipo, descripción, grupo, revisión, usuario y fecha de modificación. El [script](sql/sca2-variables-aplicacion.sql) inicializa únicamente las 24 filas de la primera tabla, mediante `ON CONFLICT DO NOTHING`. Antes de cablear, comprobar contra las constantes y literales publicados y revisar que el plan de edición no modifique SCA, SCAC o CORE. `sca2_variable_aplicacion_hist` conserva código, revisión, anterior/nuevo, usuario y marca temporal fuera del ciclo de vida del PM.
- Crear records SCA2 para catálogo e histórico sobre las tablas **ya creadas** por el responsable en DBeaver (`createTable:false`). El catálogo debe ser legible por los consumidores autorizados, incluidos perfiles funcionales/PMs que no pueden entrar al mantenimiento. Historial, metadatos y edición solo para administradores mediante sus vistas/roles; no publicar otro punto de escritura ni un record action genérico. Si se activa Data Sync, sincronizar ambos IDs tras el commit; si no se puede garantizar una lectura inmediatamente vigente, preferir lectura sin sync y verificar en Designer. Un fallo de sync postcommit no equivale a fallo de guardado; mostrarlo por separado y conciliar.
- `SCA2_obtenerVariable(codigo)`: despacha por catálogo permitido y convierte al tipo esperado. Si la fila no existe, usa la constante publicada o el literal legado exacto (no trata `false` o `0` como ausentes). Una fila inválida o un fallo de lectura no es una fila ausente: hacerlos observables; no reactivar una función que se haya deshabilitado silenciosamente. No cablear una clave que no tenga validación y prueba de equivalencia. En particular, mantener una separación entre cálculo puro y la lectura (reglas de fechas y efectos en procesos).
- `SCA2_GestionVariablesAplicacion` en la rama actual de `SCA2_GestionMantenimientoMenu`: listar por grupo, seleccionar una variable y mostrar valor vigente, tipo, descripción, fecha, autor y su historial. Solo `SCA2_GRP_ADMINISTRADORES`; preservar el gate del site y repetir la validación en servidor contra el iniciador autenticado. Sin alta ni baja desde la pantalla. Validar tipo y límites por clave en SAIL y de nuevo en el comando, p. ej. hora 0–23, zona IANA admitida, tamaño por archivo no superior al tope de plataforma, relación inicial/sondeo/agotada y pruebas de combinación de interruptores. Confirmar los valores de alto impacto antes de guardar.
- `SCA2 CMD Guardar Variable de Aplicación`: recibe código, nuevo valor y revisión esperada; la identidad debe salir de `pp!initiator`, no de un input editable. Puerto de persistencia SCA2 invoca una **única** rutina para actualizar y auditar; bloquea la fila, rechaza revisiones obsoletas y omite cambios idénticos. La función PostgreSQL del script es el contrato transaccional; antes de conectar, probar la invocación con el smart service en TEST. Si el conector solo admite `CALL`, usar un procedimiento SCA2 fino sobre la misma función, sin duplicar las escrituras. Dar acceso de arranque solo al grupo admin y configurar nombres legibles, borrado de instancias al pasar un día y alertas a **SCA2 Alertas**. El historial de cambios no depende de retener instancias.
- La rutina no crea filas nuevas y valida el tipo primitivo; los rangos/relaciones de negocio pertenecen al comando. No ofrecer la ejecución de la rutina a usuarios finales directamente por BD ni sincronizar variables con SCA. El usuario responsable ejecuta el SQL en DBeaver TEST; aquí no se ejecuta DDL/DML contra TEST.

### Coste de lectura en ejecución

Hoy una constante no implica acceso al record. No sustituirla por una consulta por variable, por fila o por iteración. Una lectura conjunta por grupo/clave al inicio de la evaluación (SAIL: local reutilizable) o del comando, y pasar un snapshot de tipos en PVs/inputs. Batches: un snapshot por ejecución raíz, también al invocar trabajadores o páginas recursivas; el cambio surte efecto en la **siguiente** ejecución y el lote no mezcla revisiones. PM por solicitud: agrupar claves en una lectura por frontera de negocio que las use y no propagar datos ajenos; la espera NSE reutiliza el valor durante sus iteraciones. Si falta una fila, completar el snapshot con los mismos fallbacks. No añadir caché global ni TTL opaco en v1. Medir la latencia y las consultas antes/después en Alta, Detalle, Finalizar y en un lote representativo; no hay benchmark todavía.

### Verificación exigida al cablear

Paridad con la semilla intacta; fila ausente con fallback; false/0 válidos; acceso por admin y rechazo de no admin por site y por servidor; guardar/releer, auditoría con anterior/nuevo, fallo que revierta ambos cambios, ediciones concurrentes y cambio idéntico; comprobar que CORE 1 y 2 no aparecen ni reciben llamadas. Probar sin disparar batches ni cambiar datos compartidos; la prueba local del SQL no prueba el render ni el conector Appian.
