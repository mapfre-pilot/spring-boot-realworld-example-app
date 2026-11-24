# Variables de la aplicación — SCA2

Implementado en **SCA2 TEST**, en Gestiones mantenimiento → Variables de la aplicación. Es una pantalla nueva de SCA2; no cambia SCA, SCAC ni CORE. Se descartó el script de catálogo e histórico: el almacenamiento y la auditoría son las constantes y sus versiones en Appian. No hay que ejecutar SQL.

## Catálogo inicial

Se revisaron las 266 constantes de la aplicación SCA2 en TEST, sus dependencias para los candidatos, los PM operativos indicados y los documentos de mantenimiento. «Usos» cuenta objetos directos distintos que devuelve el índice MCP, sin contar la aplicación; puede incluir pilotos/pruebas y no equivale a ejecuciones ni a consumidores indirectos. «Literal» se cuenta por objeto cuando no existe una constante independiente. Los nombres abreviados de la primera columna llevan el prefijo `SCA2_`, salvo donde se indica un objeto con su nombre completo. Las 22 constantes existentes conservaron el valor vigente. Las dos constantes nuevas se inicializaron con los literales que reemplazan.

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
| `DIAS_CADUCIDAD_POSPUESTA` (nuevo) | 7 · entero (días naturales) | 1 directo, 5 consumidores de la regla incl. un objeto de prueba | Plazo al posponer; mantiene fin de día local y tope de vencimiento de póliza. Sin recálculo retroactivo. |
| `LIMITE_DOCUMENTO_BYTES` (nuevo) | 52.428.800 · entero (bytes) | 2 interfaces directas; el bloqueo se propaga por las interfaces de la ronda 76 | Máximo por archivo (50 MiB). Las comparaciones y los mensajes usan el mismo límite; el tamaño exacto está permitido. |
| `BOOL_BATCH_NSE` | false · booleano | 2 | Interruptor del batch NSE y lectura en ResumenBatch. No programa el batch. |
| `BOOL_BATCH_RESERVA_PRIMA` | false · booleano | 2 | Interruptor del batch Reserva Prima y lectura en ResumenBatch. No programa el batch. |
| `REINTENTO_FIN_ACTIVO` | true · booleano | 3 | Interruptor Appian de captura/reserva y del modelo de reintentos. No sustituye el segundo interruptor SQL. |
| `VAL_ESPERA_NSE_FINALIZAR_MAX_INTENTOS` | 10 · entero (intentos) | 1 | Máximo de esperas NSE en Finalizar; no cambia la duración del timer. |
| `USAR_OBSERVABILIDAD` | true · booleano | 12 | Activa instrumentación operativa en comandos; **no** desactiva la auditoría de variables. |
| `FECHA_INICIO_DATOS` | 2026-09-24 · fecha | 2 | Límite inferior para métricas de Cuadro de mando y su piloto. |

### Parámetros excluidos del catálogo inicial

No se descartan del análisis. Algunos necesitan migrar el mecanismo de programación, ajustar la validez cruzada o acordar antes un cambio de riesgo. No se publican valores internos de entorno, cuentas, correos o credenciales: GitHub confirma que el repositorio es público. Los destinos y correos vigentes se leen en Designer TEST bajo sus constantes, no en este catálogo.

| Origen | Valor en TEST o evidencia | Usos | Decisión |
|---|---|---:|---|
| `BOOL_PILOTO_ACTIVO`, `USERS_DOMAIN` | false (booleano); dominio de identidad (texto) | 1 / 2 | Cambian el alcance de acceso del piloto; no ofrecer como ajuste operativo. |
| `GRP_ALERTAS`, `GRP_ADMINISTRADORES` | SCA2 Alertas / SCA2 Administrators · grupos | 3 indexados para Alertas, más referencias de seguridad que no recoge ese recuento | No editar destinatarios de fallos ni permisos del modelo desde el site. |
| CORE `1 APLICACION` y `2 TEXTO` | CDT SOAP con valor e inhibición de texto; consultadas ambas filas. El mensaje de TEST no se publica. | 1 / 3 objetos SCA2 que referencian directamente el lector | Excluidas del catálogo, la pantalla y el guardado. La 1 condiciona el alta y la 2 aporta su mensaje; escribir afectaría a SCA. |
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
| Reintento SQL `sca2_reintento_fin_config.habilitado` | Booleano; carga documentada false. **Actual TEST no verificado:** record con sync invalidada | Procedimientos de captura/ejecución; no es constante Appian | No duplicar la autoridad del control sin confirmar el valor real por la vía autorizada. No inferir el estado efectivo del batch de `REINTENTO_FIN_ACTIVO`. |
| Archivo histórico nocturno | 04:30 Europe/Madrid documentado para el simulador; un mes natural de retención; lanzador real con `maximo=0` observado como valor inicial del PM | 1 por concepto; no implica misma programación en el lanzador real | Guardas de corte, exclusiones, cupos/timeout y no solape: no editables sin validar el circuito de recuperación. |
| UUIDs, estados y códigos del contrato, máscaras de datos, literales de UI y credenciales | No aplicable | — | Son referencias, contratos o datos sensibles; nunca copiarlos a este catálogo. |

Para ampliar el lote, revisar los literales de los nodos, expresiones, integraciones y timers implicados, no solo sus nombres. El índice de dependencias no sustituye esa revisión, en particular para mínimos, máximos, timeouts del runtime o endpoints que están embebidos en un Connected System.

## Lectura, edición y auditoría

- `SCA2_obtenerVariablesAplicacion(codigos)` lee el catálogo cerrado como un snapshot SAIL, directamente con `cons!`. No hay consultas de BD, fallback ni caché añadida. Los consumidores de las 22 constantes existentes permanecen intactos; las pantallas se actualizan tras recargar.
- `SCA2_GestionVariablesAplicacion`, conectada en la rama Variables de `SCA2_GestionMantenimientoMenu`, muestra grupo, descripción, tipo y valor, y ofrece un editor booleano, entero, fecha o texto. Solo se puede acceder como administrador SCA2. No hay alta, baja ni edición de metadatos. Tras guardar, la pantalla pide recargar antes de volver a editar: la propagación del valor no es inmediata.
- `SCA2 CMD Guardar Variable de Aplicación` valida a `pp!initiator` contra `SCA2_GRP_ADMINISTRADORES` y selecciona una rama con un UUID fijo por código. `SCA2_validarCambioVariableAplicacion` convierte el texto canónico al tipo declarado; rechaza códigos desconocidos, fechas no válidas, texto vacío y enteros negativos o fuera de rango (hora de caché: 0–23). Un valor idéntico termina sin escribir. No hay compare-and-set transaccional entre dos ediciones simultáneas; se conserva la secuencia de versiones.
- Cada nodo usa `Update Constant` nativo con `Run as initiator` y `Create New Version` activado. El proceso solo anuncia éxito después del nodo de escritura. El modelo borra instancias al día y usa alertas por grupo, configuradas con **SCA2 Alertas**. El historial se consulta en **Appian Designer → constante → Versions**: cada versión conserva el nuevo valor, el autor y la fecha; el valor anterior está en la versión precedente. No se encontró una función SAIL disponible en TEST para leer versiones de constantes desde el site.
- **Antes de desplegar:** marcar las 24 constantes del catálogo como **Environment Specific** en Designer: abrir cada constante, activar la casilla y guardar sin cambiar su valor. El MCP de TEST no expone esa propiedad. Comprobar la opción y el archivo de personalización en el destino: Appian preserva el valor de una constante específica de entorno al importar salvo que el archivo indique otro. En una primera instalación, comprobar que el valor de arranque coincida con el vigente en el entorno de destino.

## Objetos de TEST y verificación

- Constantes nuevas: `SCA2_DIAS_CADUCIDAD_POSPUESTA` = 7 y `SCA2_LIMITE_DOCUMENTO_BYTES` = 52.428.800. Consumidores ajustados: `SCA2_calcularCaducidadAccion`, `SCA2_AccionesAdministrativasDocumentacion` y `SCA2_AltaGestionArgumento`.
- Regla de lectura y validador, pantalla, menú y PM según los nombres anteriores; `SCA2_PM_CMD_GUARDAR_VARIABLE_APLICACION` referencia el PM. Se guardaron copias previas de los objetos editados.
- Prueba aislada con iniciador y diseñador distintos: el nodo **INITIATOR** guardó la versión 2 a nombre del administrador que arrancó el proceso y **DESIGNER** guardó la versión 3 a nombre del diseñador. Los dos valores incluían el marcador del iniciador. Los objetos de la prueba se retiraron.
- Prueba desde el site con el límite de documentos: `52428800 → 52428799 → 52428800`. Tras recargar se volvió a leer el valor restaurado, y Appian conservó las versiones. Se comprobó el editor a 1920×1080 y 1024×768.
- Las comprobaciones de Appian cubrieron catálogo de 24 entradas, ausencia de CORE, booleano falso, entero cero, fecha inválida y cambio idéntico sin escritura. No se realizó ningún cambio en CORE ni SQL en TEST.
