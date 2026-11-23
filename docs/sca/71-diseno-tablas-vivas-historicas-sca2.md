# 71 · SCA2 — Tablas vivas sincronizadas e histórico de solo consulta

**Estado (23/11/2026):** negocio aprobó las 14 opciones recomendadas. Los scripts de la fase 1 están listos para que el usuario los ejecute en DBeaver contra TEST. No se han ejecutado en TEST ni se han creado o modificado objetos Appian. No se ha movido ningún dato. El piloto de traspaso requiere aprobación separada.

## 1. Resumen

Mantener los record types operativos sobre las tablas actuales y sincronizados. Los expedientes cerrados desde hace **más de un mes** se trasladarían, con sus filas asociadas, a tablas `sca2_*_hist` del mismo esquema. Cada tabla histórica tendría su propio record type SQL no sincronizado, de solo consulta, con la misma PK, columnas originales y fecha de archivado. Una solicitud con trabajo pendiente no se archiva, aunque su estado parezca final.

La unidad de movimiento es el expediente, no una fila antigua aislada. El detalle histórico debe conservar los datos, la autorización y los enlaces existentes; no se debe habilitar el borrado hasta demostrar esa paridad. La decisión no altera cuándo caduca, cómo finaliza ni cómo se reintenta una solicitud.

## 2. Evidencia de Appian TEST

Fuente: `listRecordTypes` acotado a la aplicación SCA2, `getRecordType`, `listDatabaseTableColumns`, `getObjectDependents` y páginas de `listRecordData` por cada record. `listDataSources` identificó **SCA2 DataBase AWS** como **PostgreSQL**; las tablas están en `sca2_anulaciones`. El MCP devolvió 22 tablas con 588 columnas físicas, todas con PK `ID` de tipo entero. El inventario completo de nombres y tipos se puede contrastar con el [DDL 73 de estructura](sql/73-promocion-bd-sca2-estructura.sql); no copiar índices de operativa ni defaults de secuencia al histórico.

**Sincronización actual:** `getRecordType` no devuelve el interruptor Data Sync. **I** = inferido por relaciones a otros records o a User y consultas relacionadas; **D** = documentado como sincronizado en la [implantación de catálogos](43-C-catalogos-aurora.md), no revalidado; **?** = sin evidencia suficiente. Confirmar el interruptor, el volumen y la última sincronización en Designer antes de implantar. La consulta por MCP no demuestra que un record esté sincronizado ni reproduce los permisos de un gestor.

**Medición:** en TEST, a las 09:26 UTC del 23/11, hubo **404 solicitudes**, **157** en los códigos terminales candidatos (58 FINALIZADA, 67 FINALIZADA_POSITIVO, 27 CANCELADA y 5 CADUCADA). Las 157 tenían último cambio de estado `OK` coherente con el estado actual. **36** tenían esa transición antes del corte del 23/10 a las 09:26 UTC. Al excluir provisoriamente expedientes con tareas, errores o llamadas sin cierre acreditado, quedan **31** para revisar, no 31 autorizados para mover. Son lecturas paginadas de TEST, no una instantánea transaccional de la BD ni una estimación de PRO.

| Record (prefijo SCA2) | Tabla actual | Columnas | Filas | Asociadas a las 36 | Relación y Data Sync | Archivo propuesto |
|---|---|---:|---:|---:|---|---|
| Solicitud | `sca2_solicitud` | 36 | 404 | 36 | 1:N a Transicion, Tarea, Error, Datos Solicitud, Niveles, Otras Solicitudes y Llamada; dos User; I | Raíz |
| Transicion | `sca2_transicion` | 12 | 2.416 | 280 | N:1 a Solicitud y User; I | Conservar toda la secuencia, incluida la clave de idempotencia |
| Tarea | `sca2_tarea` | 17 | 701 | 59 | N:1 a Solicitud y dos User; I | Con el expediente; dos filas bloquean por estado/fecha |
| Error | `sca2_error` | 13 | 208 | 5 | N:1 a Solicitud y User; I | Con el expediente; las cinco filas bloquean por estado/fecha |
| Llamada Servicio | `sca2_llamada_servicio` | 12 | 500 | 0 | N:1 a Solicitud; I | Con el expediente, solo si acabó la llamada |
| Datos Cabecera | `sca2_datos_cabecera` | 53 | 573 | 36 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente; conservar la fila que consulta el detalle, sin refrescarla desde el histórico |
| Datos Solicitud | `sca2_datos_solicitud` | 33 | 557 | 36 | N:1 a Solicitud; I | Con el expediente |
| Datos Basicos Solicitud | `sca2_datos_basicos_solicitud` | 9 | 557 | 36 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente |
| Datos Perfiles Pca | `sca2_datos_perfiles_pca` | 6 | 557 | 36 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente |
| Datos Productor | `sca2_datos_productor` | 16 | 557 | 36 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente |
| Datos Poliza Autos | `sca2_datos_poliza_autos` | 84 | 465 | 34 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente |
| Datos Poliza Hogar | `sca2_datos_poliza_hogar` | 90 | 89 | 2 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente |
| Datos Poliza Vida | `sca2_datos_poliza_vida` | 90 | 3 | 0 | Sin relación Appian; `ID_SOLICITUD`; ? | Con el expediente si hay filas |
| Niveles Cobertura Autos | `sca2_niveles_cobertura_autos` | 5 | 557 | 36 | N:1 a Solicitud; I | Con el expediente |
| Otras Solicitudes Cabecera | `sca2_otras_solicitudes_cabecera` | 10 | 557 | 36 | N:1 a la solicitud propietaria; I | Con el expediente, no arrastrar las otras solicitudes referenciadas |
| Trazabilidad Cliente | `sca2_trazabilidad_cliente` | 11 | 801 | No aplica | Sin `ID_SOLICITUD`; `FECHA`, `POLIZA`, `CLIENTE`, perfil/operación/resultado; ? | Fase aparte por fecha del evento y retención aprobada; 239 eventos anteriores al corte |
| Cat Motivo / Detalle / Causa | `sca2_cat_motivo` / `sca2_cat_detalle` / `sca2_cat_causa` | 12 / 11 / 13 | 14 / 22 / 146 | No aplica | Sin relación; D | No archivar: referencias de catálogo |
| Cat Tipo Argumento / Concepto / Valor Concepto | `sca2_cat_tipo_argumento` / `sca2_cat_concepto` / `sca2_cat_valor_concepto` | 31 / 11 / 13 | 347 / 17 / 101 | No aplica | Sin relación; D | No archivar: referencias de catálogo |

La columna «Asociadas» se cruza por `ID_SOLICITUD` contra las 36 antes de aplicar las exclusiones. Quedan fuera las filas sin clave o sin coincidencia en la extracción, p. ej. 183 de Datos Cabecera, 170 de Datos Solicitud, 5 de Llamada Servicio y un error sin clave. No se consideran huérfanos confirmados en BD ni se borran. No deducir pertenencia a partir de póliza, cliente o cercanía de fechas. Trazabilidad no es una hija segura; consultar sus eventos históricos por fecha solo tras fijar retención, acceso y métricas.

### Lectores y escritores que condicionan el cambio

`getObjectDependents` localiza referencias de diseño, no prueba la rama por la que pasa un usuario. La siguiente matriz recoge los consumidores SCA2 que hay que cubrir al implantar; se complementa con los [patrones de consulta 66](66-indices-bd-sca2.md#4-patrones-de-consulta-reales) y el [cuadro de mando 69](69-cuadro-mando-respuestas-dudas.md).

| Datos | Lecturas que hay que preservar | Escrituras o flujos que deben seguir sobre la viva |
|---|---|---|
| Solicitud | `SCA2_Buscador`, `SCA2_BuscadorTabla`, `SCA2_cargarSolicitud`, detalle, `SCA2_CuadroMando`; Alta consulta duplicados y BarridoCaducidad selecciona vigentes | PMs `SCA2 CMD Alta`, `Decidir`, `CrearAccion`, `CompletarAccion`, `Finalizar`, `Caducar`, `Mecanizar`/`MecanizarNSE` y `Posponer` |
| Transicion | `SCA2_DetalleTransiciones`, `SCA2_CuadroMando`, comprobación de `CLAVE_IDEMPOTENCIA` en los CMD y procesamiento de errores | Los CMD registran transiciones; comprobar reenvíos tardíos antes de retirar de viva la protección por clave |
| Tarea | `SCA2_DetalleTareas`, `SCA2_obtenerIdTareaPendiente`, permisos/reasignación y avisos de `SCA2_CuadroMando` | `SCA2 CMD CrearAccion`, `CompletarAccion`, `Mecanizar` y `Posponer`; el archivo no cierra tareas |
| Error | `SCA2_BandejaErrores`, `SCA2_DetalleErrores`, `SCA2_obtenerErrorPendiente`, `SCA2_contarErroresPendientes`, cuadro de mando y lote de errores | Los CMD producen errores; `SCA2 CMD MarcarErrorRelanzado` y `SCA2 CMD ProcesarLoteErrores` son consumidores operativos; no archivar un reintento o bloqueo |
| Llamada Servicio | `SCA2_CuadroMando` lee resultados/latencias; preservar filtro por línea y origen | PMs observados: `SCA2 CMD Alta`, `Caducar`, `CompletarAccion`, `Finalizar`, `Mecanizar` y `MecanizarNSE` |
| Datos Cabecera | `SCA2_DetalleCabecera`, `SCA2_cargarSolicitud`, `SCA2_obtenerDatosCabecera` y ligadas al propietario | `SCA2 CMD Alta`, `SCA2 CMD RefrescarCacheCabecera` y reglas de renovación/invalidez; comprobar que ni refresco ni escritura tardía recrean filas tras el movimiento |
| Datos Solicitud y resto de snapshots/datos asociados | `SCA2_DetalleDatos`, `SCA2_cargarSolicitud` y reglas `SCA2_Obtener*`; buscador/cuadro consultan Datos Solicitud. Revisar los tres consumidores Web API del record Datos Solicitud y mantener sus contratos | `SCA2 CMD Alta` carga los asociados; `SCA2 CMD CompletarAccion` y `Posponer` actualizan datos de la solicitud |
| Trazabilidad y catálogos | `SCA2_CuadroMando` consume trazabilidad (ver patrón P17); las reglas de catálogo y `SCA2_CatMantenimiento` consumen los catálogos | Alta, CompletarAccion y `SCA2_registrarSombraPropietario` referencian Trazabilidad. Mantener mantenimiento y recarga de catálogos sin cambios |

## 3. Elegibilidad y batch de archivado

1. Fijar un único corte por ejecución y compararlo con la fecha de cierre usando `<`, no `<=`. Se propone **un mes natural**, en la zona de negocio acordada, no 30 días. Validar qué zona representan los `TIMESTAMP` sin offset de origen y cómo se convierte el corte en cambios de mes y horario.
2. No existe `FECHA_FIN` en Solicitud. Propuesta inicial sin cambiar escrituras de los CMD: usar `sca2_transicion.FECHA` del último cambio real con `RESULTADO='OK'`, origen distinto de destino, ordenado por `FECHA DESC, ID DESC`. Su destino debe coincidir con el estado actual, validado como definitivo. No usar `MODIFIED_AT`, creación, fecha de caducidad ni la edad de la tarea como fecha de cierre. Excluir reaperturas, incoherencias, cambios posteriores sin conciliar y expedientes sin cierre verificable.
3. Validar con negocio la lista terminal contra las escrituras de los CMD: se midieron los terminales citados en §2 y se consideraron además `FINALIZADA_ANULADA`, `FINALIZADA_RECHAZADA_ANULACION`, `FINALIZADA_SIN_ANULAR`, `FINALIZADA_NEG_CONTRA`, `FINALIZADA_NO_REQ` y `CADUCADA_NEGATIVA`, sin filas observadas. No inferir por prefijo ni incluir `PDTE-*`, `PDTE_FINALIZAR`, `MECANIZADA`, errores ni estados en curso. Que el estado sea terminal no prueba que hayan acabado todas las integraciones.
4. Excluir expedientes con tarea que no esté en un estado de cierre validado (p. ej. COMPLETADA/FINALIZADA/CANCELADA) o sin `FECHA_CIERRE`; con error sin resolución definitiva acreditada por estado y `FECHA_RESOLUCION` (incluidos PENDIENTE, BLOQUEADO y RELANZADO sin cierre probado); con llamada sin `FECHA_FIN`; o con proceso, bloqueo, reintento o escritura pendiente. El conjunto de 31 solo aplica una aproximación con los datos tabulares, no estas comprobaciones de proceso/concurrencia.
5. Batch nocturno distinto del de caducidad. Empezar en modo recuento; seleccionar por fecha de cierre/PK, con lotes pequeños, máximo por noche, una sola ejecución activa, tiempo límite y sin solapar otros batches SCA2. Un componente autorizado en PostgreSQL debe abrir **una transacción por lote** con la familia de tablas en el mismo origen; no encadenar nodos Appian de copia y borrado suponiendo atomicidad. Los comandos y escritores de hijas han de usar el mismo protocolo de exclusión por solicitud, o estar en pausa y drenados en una ventana controlada verificada; un bloqueo de la raíz por sí solo no impide insertos en relacionadas sin FK.
6. Dentro de la transacción, bloquear la raíz, volver a evaluar elegibilidad, capturar PK y copiar raíz e hijas con columnas explícitas. Mantener PK y valores originales y asignar una única fecha de archivo del lote. Ante una PK ya presente, comparar **todos** los valores originales, no sobrescribir ni borrar viva si difieren, y tratar colisiones de claves de negocio como incidencias. Verificar equivalencia por PK y por contenido antes de borrar las hijas y, al final, la raíz. Fallo en cualquier tabla implica rollback completo; un reintento tras commit no vuelve a mover el expediente. Guardar manifiesto de lotes/PK en acceso restringido y publicar solo recuentos y causas agregadas en la operación del batch.
7. Un cambio directo en PostgreSQL no se refleja por sí solo en la caché de Appian. Tras el commit, conciliar los IDs eliminados de cada record vivo con el mecanismo soportado y ensayado en TEST. Si la sincronización incremental no retira los borrados, usar sincronización completa en ventana autorizada. Registrar por separado estado BD y estado Sync; ante fallo Sync, parar nuevos lotes, reintentar la reconciliación y no repetir el movimiento. Probar que ni las pantallas ni los CMD operan durante una incoherencia de caché; si no puede garantizarse, mantener el archivo desactivado.

## 4. Scripts de estructura para TEST — PostgreSQL

1. [Instalación `sca2-hist-ddl.sql`](sql/sca2-hist-ddl.sql): en DBeaver, confirmar conexión a TEST y capacidad para asumir el rol `user_sca2_anulaciones`. Ejecutar el script completo (Alt+X), con parada al primer error. Debe informar 15 tablas verificadas y 15 creadas la primera vez (0 creadas si ya se aplicó). Si falla, no continuar con Appian; enviar el error y confirmar que la transacción se revirtió.
2. [Reversión `sca2-hist-rollback.sql`](sql/sca2-hist-rollback.sql): solo para deshacer la instalación inicial. Si ya existen consumidores Appian, retirarlos primero con autorización. La reversión solo elimina tablas de este script que estén vacías y sin dependencias en BD. No revierte un traslado de datos.

Los scripts solo afectan a las 15 tablas nuevas `_hist` de `sca2_anulaciones`; no incluyen Trazabilidad ni conceden acceso de consulta. El DDL copia columnas y NOT NULL sin secuencias ni índices de operativa; añade PK, `FECHA_ARCHIVADO` e índices para el histórico. Cualquier ajuste posterior de una viva exige revisar su par histórica. El [DDL 73](sql/73-promocion-bd-sca2-estructura.sql) no aplica FKs físicas; si después se proponen FKs históricas, no vincular con tablas vivas.

Validado en PostgreSQL 14 **local**, sobre el DDL 73: instalación, segunda ejecución sin cambios, reversión y segunda reversión. Se comprobó también el rechazo de tablas con datos, dependencias y colisiones con tablas ajenas. En TEST, el usuario ejecutó la instalación en DBeaver: `SCA2 histórico: 15 tablas verificadas; 15 creadas`. No se ejecutó la reversión ni ningún otro script de BD contra TEST.

El índice único del histórico no impide reutilizar claves en la viva. Antes del movimiento, demostrar que ni `ID_SOLICITUD` ni las claves de idempotencia pueden reutilizarse o que reenvíos y altas con colisión conservan el resultado actual sin crear ni reintentar sobre un expediente archivado. Si no se demuestra, no mover Transicion ni su expediente; valorar un registro de claves persistente como prerrequisito separado.

Revisar con DBA el catálogo de restricciones y tipos en el entorno destino. Separar el rol de archivo (copia/borrado acotado) del origen de consulta del histórico (solo SELECT, sin propiedad de tablas ni permisos de escritura), sin rebajar los permisos de lectura existentes. No exponer payloads de error, datos de cliente, credenciales ni IP en nuevas vistas o informes.

## 5. Consultas y paridad funcional

- **Buscador:** filtros, exclusión de `PDTE-*`, orden, recuento, paginación y salto a detalle con un único resultado deben aplicarse al conjunto total, no primero a una página de vivas y luego anexar históricas. Para búsqueda exacta y detalle, usar la viva y hacer fallback por el mismo ID en el histórico ante ausencia, no ante acceso denegado o error. Para filtros amplios, unir con orden estable (`CREATED_AT DESC, ID DESC`) y resolver el estado de sincronización sin duplicados; evaluar una consulta paginada SQL (vista de lectura `UNION ALL`, con fuente y seguridad verificadas) si los dos records no permiten conservar paginación y total de forma eficiente. No limitar la búsqueda a fecha de archivo. Validar filtros por cliente/matrícula que primero resuelven pólizas.
- **Detalle:** conservar la ruta y referencia de solicitud; resolver origen una vez y consultar en él las hijas por `ID_SOLICITUD`, no reconstruir el estado con datos actuales ni invocar acciones de refresco. Mantener documentos, tarjetas, etiquetas y orden histórico; verificar qué acciones están disponibles hoy en terminales y no ocultar ninguna sin aprobación. No presuponer relaciones de record sincronizado ni seguridad de fila heredada para históricos sin Sync: probar consultas explícitas y controles por rol/expediente en ambos orígenes.
- **Cuadro de mando, trazas y bandeja:** saldrán de los KPIs filas aún dentro de la ventana de 90 días si solo se consulta la viva. Preservar ventanas por su fecha original, visibilidad, filtros, totales, ratios y promedios; para porcentajes y latencia combinar numeradores/denominadores o sumas/recuentos, no promediar agregados ya calculados. No trasladar alertas/worklists operativas al histórico; si hoy se puede consultar un error resuelto desde bandeja, mantenerlo disponible con los mismos filtros y sin cambiar reintentos.
- **Operación y APIs:** no hacer fallback automáticamente en reglas de escritura como si el histórico fuese editable. Comparar en TEST el resultado actual para idempotencia, Alta, enlaces antiguos, REST y procesos que referencian IDs; si existen efectos vigentes sobre cerradas, el archivado queda bloqueado para ellas hasta acordar una solución. No deducir que consulta solo lectura implica que cualquier consumidor existente es solo lectura.

## 6. Decisiones de negocio aprobadas

| Respuesta | Decisión |
|---|---|
| 1A | Incluir `FINALIZADA`, `FINALIZADA_POSITIVO`, `CANCELADA` y `CADUCADA`. No añadir otras variantes sin verificar que son definitivas. |
| 2A | Usar el último paso correcto al estado final actual. Si no es verificable, mantener en viva. |
| 3A | Más de un mes natural, en horario de España peninsular (`Europe/Madrid`); excluir el instante exacto del corte. |
| 4A | Mantener en viva los expedientes completos si hay trabajo pendiente, cierre no acreditado o reapertura permitida. |
| 5A | Mantener un único buscador con filtros, orden, páginas, resultados y acceso directo actuales. |
| 6A | Mantener detalle, enlaces, documentos y presentación. Si una acción vigente no se puede conservar, mantener el expediente en viva. |
| 7A | Mantener la consulta, filtros y acciones de la bandeja. Los errores con actuación o reintento pendiente siguen en viva. |
| 8A | Mantener los indicadores e informes con sus fechas, filtros y cálculos, contando expedientes archivados cuando corresponda. |
| 9A | Conservar el acceso por perfil y expediente, sin dar acceso adicional. |
| 10A | Sin borrado definitivo automático en fase 1. Aprobar la conservación y eliminación por separado antes de producción. |
| 11A | No archivar Trazabilidad Cliente en fase 1. |
| 12A | Primero simulación sin retirar datos. El piloto nocturno en TEST y producción se aprueban por separado. |
| 13A | No activar el traslado si necesita una pausa visible o no se puede garantizar una lectura coherente. |
| 14A | Mantener en viva todo expediente aún usado por servicios o procesos hasta demostrar paridad. |

## 7. Fase 1 — implantación en Appian TEST

El catálogo de Appian confirmó 15 tablas `_hist` en `sca2_anulaciones`, con PK `ID` y las columnas y tipos de cada tabla viva más `FECHA_ARCHIVADO`. Antes de crear los records se guardaron copias de metadatos, versiones y permisos de objeto de los vivos, junto con la estructura de cada par de tablas.

### Records históricos

El MCP creó los records sobre las tablas existentes con el acceso sincronizado por defecto. Según lo indicado por el usuario, se cambió cada uno en Designer a **Directo (No sincronizado)** y se comprobó el estado al volver a abrirlo. Una actualización de descripción por MCP en `SCA2 Solicitud Hist` (v3 → v4) conservó el acceso directo. Se comprobaron los tipos de campo y la coincidencia de grupos, roles y acceso por defecto con los records vivos. `listRecordData` devolvió solo la cabecera en los 15 históricos. No se añadieron acciones de escritura ni se enlazaron estos records desde pantallas existentes.

| Record | Tabla | UUID | Versión |
| --- | --- | --- | --- |
| SCA2 Solicitud Hist | `sca2_solicitud_hist` | `3af38605-67f3-4f9e-971c-7fd784e69d87` | 4 |
| SCA2 Transicion Hist | `sca2_transicion_hist` | `bebd74f4-f1b6-46a2-9a3a-54bab1ab9a28` | 4 |
| SCA2 Tarea Hist | `sca2_tarea_hist` | `236c22e1-f0fb-4186-b235-72c3397b5241` | 3 |
| SCA2 Error Hist | `sca2_error_hist` | `4d94fa0f-83f2-4b41-9c9b-f4cd11af5e18` | 3 |
| SCA2 Llamada Servicio Hist | `sca2_llamada_servicio_hist` | `a4ce4e99-11a8-421d-924f-e52b3c80bb61` | 3 |
| SCA2 Datos Cabecera Hist | `sca2_datos_cabecera_hist` | `57fc7a32-e00f-45b7-9d53-b17c9b9bed4e` | 3 |
| SCA2 Datos Solicitud Hist | `sca2_datos_solicitud_hist` | `cf8fc3ec-b497-4411-93d3-5ba5256bf678` | 3 |
| SCA2 Datos Basicos Solicitud Hist | `sca2_datos_basicos_solicitud_hist` | `6e6e4805-1fb4-4594-acd6-58188eba698c` | 3 |
| SCA2 Datos Perfiles Pca Hist | `sca2_datos_perfiles_pca_hist` | `dc6fc066-fe86-4fb8-8625-0c2c071035cf` | 3 |
| SCA2 Datos Productor Hist | `sca2_datos_productor_hist` | `0aae5a4f-8dd9-459f-89df-b0a145e22637` | 3 |
| SCA2 Datos Poliza Autos Hist | `sca2_datos_poliza_autos_hist` | `66d43738-f6f4-4fe0-aa9b-d501ceb865d5` | 3 |
| SCA2 Datos Poliza Hogar Hist | `sca2_datos_poliza_hogar_hist` | `d6b95633-c692-46b0-b37e-c31a2bad7ff2` | 3 |
| SCA2 Datos Poliza Vida Hist | `sca2_datos_poliza_vida_hist` | `cf30d767-50cb-4932-9af2-f42a87425159` | 3 |
| SCA2 Niveles Cobertura Autos Hist | `sca2_niveles_cobertura_autos_hist` | `8b8f9d72-188e-4da5-b50d-97bb53132be9` | 4 |
| SCA2 Otras Solicitudes Cabecera Hist | `sca2_otras_solicitudes_cabecera_hist` | `b9df1adc-40c1-49bb-9d25-6cac076b625c` | 4 |

La prueba no acredita autorización por expediente, visibilidad con perfiles de negocio ni que las credenciales del origen estén limitadas a SELECT. Deben comprobarse antes de exponer o poblar los históricos, incluidos los campos sensibles del record de errores.

### Simulación manual

`SCA2 CMD SimularArchivoHistorico` — UUID `0001f0c0-fab0-8000-dbb7-7f0000014e7a`, versión numerada **2.0**. Appian muestra también un borrador; los nodos y variables coinciden con la versión 2.0. Se auditó el modelo: inicio manual, sin timer, cuatro tareas de script de solo consulta y cálculo, una bifurcación y fin. No hay escrituras, subprocesos, integraciones ni referencias a Trazabilidad. No se tocó el reporte de Gestiones mantenimiento.

El PM fija un corte único de un mes natural en `Europe/Madrid` y pagina por PK. Usa las fechas de transición tipadas en Appian: las escrituras analizadas usan `now()` (véase [43-G](43-G-invalidacion-cache.md)) o UTC explícito (véase [SQL de reintento](sql/sca2-reintento-finalizacion.sql)). El resultado no contiene identificadores de solicitudes. Si no se acredita que no hay dependencias de servicios, procesos o reintentos, el expediente sigue en viva.

`testProcessModel`: instancia `17625407`, estado `COMPLETED`, duración `15325 ms`, corte Appian `2026-10-23 10:41:26` UTC.

| Resultado por expediente (un motivo principal) | Total |
| --- | ---: |
| Estado no elegible o provisional | 250 |
| Cierre no verificable | 0 |
| Cierre reciente | 118 |
| Tarea pendiente | 2 |
| Error o reintento pendiente | 3 |
| Llamada sin terminar | 0 |
| Reapertura detectada | 0 |
| Dependencia no acreditada | 34 |
| Candidatos | 0 |
| **Total evaluado** | **407** |

Los 34 que superaron los filtros anteriores **no son candidatos**: con las comprobaciones actuales no se acredita que sus servicios, procesos o reintentos hayan terminado. Los 31 de §2 corresponden al inventario de diseño, no a esta ejecución. No se movió ningún dato ni se activó el batch nocturno.

## 8. Paquete del piloto para aprobación

**Estado: preparación parcial, no apta para autorizar el primer traspaso.** Se añadieron relaciones a los records históricos y copias aisladas del buscador, detalle y bandeja. Los objetos operativos y sus referencias siguen intactos. No se ejecutó el PM de traspaso, no se lanzó ningún script contra TEST y no se movieron datos. Las copias de Appian y el cotejo de expedientes quedan en evidencia restringida, no en Git.

### Relaciones de los records históricos

Se reprodujeron las 20 relaciones de los ocho records vivos que las tenían, apuntando a Hist cuando la entidad se archiva, y al record de sistema User cuando corresponde. En estas relaciones no había destinos de catálogo SCA2 adicionales. Todas se configuraron `NON_CASCADING`: la consulta no debe propagar escrituras. Se comprobó el destino y los campos de cada relación por MCP, que las ACL no cambiaron y que los ocho records seguían como **Directo (No sincronizado)** en Designer.

| Record histórico | Versión inicial → final | Relaciones |
|---|---:|---:|
| Solicitud Hist | 4 → 13 | 9 |
| Transicion Hist | 4 → 6 | 2 |
| Tarea Hist | 3 → 7 | 3 |
| Error Hist | 3 → 5 | 2 |
| Llamada Servicio Hist | 3 → 4 | 1 |
| Datos Solicitud Hist | 3 → 4 | 1 |
| Niveles Cobertura Autos Hist | 4 → 5 | 1 |
| Otras Solicitudes Cabecera Hist | 4 → 5 | 1 |

### Permisos por expediente y dependencias

- Los 15 pares vivo/histórico tienen la misma ACL de objeto. En el modelo devuelto por `getRecordType` ninguno presenta `securityRules` ni `securityExpression`. En `SCA2 Anulaciones` v8, Buscador no añade una condición de página; Errores y Gestiones mantenimiento exigen `SCA2_GRP_ADMINISTRADORES`. En el navegador, las tres rutas operativas respondieron 200 como `devin`. Los intentos con JJGONZ2 y SISANS por SSO NO PRO no regresaron a Appian, también al probar el UPN de dominio NO PRO. No se acreditaron perfiles de negocio, denegaciones por expediente, enlace directo, acceso a hijas ni descarga en Hist. BD aún debe acreditar los privilegios efectivos del origen de consulta, incluido que solo pueda hacer `SELECT`.
- La relectura con el corte original evaluó 408 solicitudes, una más que la primera simulación, con 251 en estado no elegible. Volvieron a salir 34 retenidas por dependencia no acreditada; al no guardar IDs en la simulación, no puede demostrarse identidad exacta entre ambos grupos solo a partir de sus totales. El cierre registrado de las 34 reencontradas se reparte entre `SCA2 CMD Finalizar` (18), `SCA2 CMD CompletarAccion` (15) y `SCA2 CMD Caducar` (1).
- Ninguna de esas 34 tenía `procesoActivo` o `nodoRelanzar` informado ni filas asociadas encontradas en `SCA2 Llamada Servicio`. El historial de los modelos inspeccionados no devolvió coincidencia para los 245 IDs de instancia vinculados; la consulta directa por los 34 IDs de cierre tampoco encontró estas instancias. Eso no distingue un proceso purgado de uno no visible, y no cubre servicios externos. **Clasificación: 0 seguras, 34 se quedan en viva**. Se necesita contrastar la correspondencia de IDs y la cobertura del historial con el responsable de operaciones, además de verificar los consumidores REST, reintentos y claves de idempotencia descritos en §2–3.

**Preguntas cerradas antes de incluir expedientes en el lote**

1. ¿Puede Operaciones acreditar, para cada expediente del listado restringido, que no queda ninguna instancia, tarea, reapertura o reintento activo, y que la evidencia cubre el período e IDs consultados? **A. Sí**, indicar cuáles y adjuntar el cotejo; **B. No o solo parcialmente**, mantener en viva los expedientes sin evidencia. **Recomendada: B** hasta disponer del cotejo.
2. ¿Han confirmado todos los responsables de Web APIs, integraciones y reenvíos que no necesitan encontrar en viva esos expedientes ni sus claves de idempotencia? **A. Sí**, adjuntar validación por consumidor y expediente; **B. No o falta algún consumidor**, mantener en viva los casos afectados. **Recomendada: B** mientras falte una confirmación.

### Consultas y pruebas exigidas

Las sondas `validateExpression` sobre `SCA2 Solicitud Hist` no devolvieron errores ni avisos para una consulta paginada con total y un agrupamiento por estado. Esto valida las expresiones, no su ejecución con filas, los permisos de negocio ni la paridad visual. El histórico vacío no permite acreditar el camino que solo se ejecuta tras el archivo; no se hicieron copias de expedientes en TEST.

| Superficie (versión TEST de referencia, sin cambios) | Comportamiento que se debe conservar y prueba pendiente |
|---|---|
| `SCA2_Buscador` 40, `SCA2_BuscadorTabla` 20 | La copia `SCA2_Buscador_HistPiloto` aplica el filtro original a Hist. Sin coincidencias usa la consulta viva original; con coincidencias pide a cada fuente un prefijo de tamaño `startIndex + batchSize - 1`, adapta las filas Hist, ordena, corta la página y suma los dos totales. Conserva la rama CORE y para SCA2 invoca el detalle piloto. Quedan por probar los filtros interactivos, empates, páginas profundas, proyecciones con filas históricas y transición tras Sync. El total sumado presupone que los conjuntos no se solapan. |
| `SCA2_DetalleSolicitud` 77, `SCA2_cargarSolicitud` 10 | El detalle distingue ausencia SCA2 de una solicitud solo CORE y obtiene documentos con `SCA2_PM_OBTENER_DOCUMENTO_GD`. Resolver el origen antes de esa distinción, conservar el enlace e ID y cargar las hijas del mismo origen. Comparar cabecera, tarjetas, tareas, transiciones, errores y descarga; demostrar que ninguna acción que escriba sigue disponible para un expediente elegible. Si alguna sigue disponible, mantener el expediente en viva hasta acordar cómo conservarla. |
| `SCA2_BandejaErrores` 17 | Conservar filtro inicial, estados seleccionables, paginación y enlace al detalle bajo la misma restricción de administrador. Probar errores consultables del histórico y que las selecciones y acciones de relanzar/descartar sigan aplicándose solo a errores pendientes en viva. |
| `SCA2_CuadroMando` 36 | Comparar filtros por fecha, línea y origen, agrupaciones, ventanas y ratios. Unir conteos y sumas antes de calcular ratios/medias y aplicar los límites después de agrupar; comprobar que cada expediente cuenta una sola vez mientras se concilia Sync. Trazabilidad no se mueve. |

Con Hist vacío, `testInterface` comparó el árbol renderizado del buscador original y de la copia con cuatro entradas: inicial, un ID inexistente y dos solicitudes reales. No hubo diagnósticos de ejecución; se comparó estructura y valores renderizados, no los IDs internos ni los tokens opacos de `saveInto`. No se ejecutaron interacciones, descargas ni acciones desde el render.

La regla aislada `SCA2_PruebaPaginacion_HistPiloto` (`_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789298`, v3) devolvió total 4 y las dos filas sintéticas correctas en la página que comienza en 2. Esto no es una prueba de lectura de filas de BD.

#### Inventario de copias aisladas y evidencia

| Objeto de TEST | UUID | Versión |
|---|---|---:|
| `SCA2_Buscador_HistPiloto` (enlace al detalle piloto) | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789276` | 3 |
| `SCA2_cargarSolicitud_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789402` | 1 |
| `SCA2_DetalleCabecera_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789408` | 1 |
| `SCA2_DetalleDatos_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789414` | 1 |
| `SCA2_DetalleErrores_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789426` | 1 |
| `SCA2_DetalleTareas_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789432` | 1 |
| `SCA2_DetalleTransiciones_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789438` | 1 |
| `SCA2_DetalleSolicitud_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789444` | 1 |
| `SCA2_BandejaErrores_HistPiloto` (enlace al detalle piloto) | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789420` | 2 |
| `SCA2_PruebaBandeja_HistPiloto` (solo datos sintéticos en memoria) | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789458` | 1 |

El detalle decide el origen por ID, da prioridad a viva y pasa el origen a las hijas. En la rama histórica, adapta campos al tipo que consumen las interfaces y bloquea las llamadas directas de escritura/proceso del piloto, salvo la obtención de documentos. No se probó la descarga, la visibilidad de todos los controles ni el camino con filas históricas. La bandeja combina los prefijos de Error vivo e Hist con el mismo filtro y total; las opciones de filtro y la lógica operativa del lote se siguen calculando en viva. Falta probar interacciones y paridad de opciones con datos históricos antes de conectar la bandeja.

Con Hist vacío, los renders del detalle y del buscador enlazado coincidieron en dos expedientes reales; la bandeja coincidió en la carga inicial. Se comparó el árbol de `testInterface` sin `_cId` ni tokens `saveInto`, sin pruebas visuales o clics. El reintento de JJGONZ2 y SISANS seleccionó «SSO Mapfre NO PRO» y esperó `domcontentloaded` más una espera fija antes de comprobar el retorno: ambos permanecieron en `login.microsoftonline.com`. Sigue sin acreditarse la paridad por perfil.

La prueba de bandeja reutilizó la proyección, orden y paginación de la copia, sustituyendo las consultas por cuatro filas tipadas en memoria: total 4, página desde 2 con IDs 4 (histórico, `RESUELTO`) y 3 (vivo, `PENDIENTE`), sin errores. No cubre filtros interactivos ni acciones.

No se publicó una copia del cuadro de mando: sus series usan `a!recordData` con un solo origen, y sumar agrupaciones ya limitadas o promedios de ambos orígenes no garantiza las métricas. Falta combinar las agrupaciones de ambos orígenes antes de limitar y reconstruir las series manteniendo sus filtros, intervalos y formato. No hay prueba de métricas contando Hist.

#### Cómo conectar las copias (no ejecutado)

1. Validar acceso permitido y denegado por expediente, enlace directo y documentos con perfiles no administradores. Probar las acciones y opciones de la bandeja con casos archivados sintéticos antes de usar TEST con filas.
2. Terminar el cuadro de mando y repetir los renders y comprobaciones de métricas con los mismos filtros. Si Sync permite que viva e Hist devuelvan temporalmente la misma PK, no habilitar hasta ensayar cómo evitar duplicados sin cambiar el comportamiento.
3. Después de la aprobación, cambiar las referencias de las páginas SCA2 de Buscador y Errores a `SCA2_Buscador_HistPiloto` y `SCA2_BandejaErrores_HistPiloto`, y la referencia del cuadro de mando de Gestiones mantenimiento a su copia cuando esté validada; mantener las condiciones de página y permisos. Revisar los demás puntos de entrada SCA2 al detalle antes de reemplazarlos y conservar los originales para revertir cada referencia. No tocar SCA, SCAC ni CORE.

#### Rutina transaccional propuesta

El [SQL de traspaso](sql/sca2-hist-traspaso.sql) y su [prueba local](pruebas/sca2-hist-traspaso-local.sql) residen en Git, no en TEST. La rutina admite hasta diez IDs explícitos por lote (deduplicados) y solo admite archivar un expediente si también consta en la lista independiente de dependencias acreditadas; una lista de permisos vacía retorna un resumen a cero sin consultar ni bloquear las tablas. Revalida en BD estado, cierre, corte de un mes natural, pendientes y reaperturas. Copia las quince tablas preservando las PK antes de borrar de viva; una colisión incompatible revierte la unidad correspondiente y una reejecución no vuelve a mover un expediente ya archivado. PostgreSQL confirmó estos escenarios sobre datos sintéticos locales; los bloqueos `NOWAIT` a nivel de tabla requieren acordar una ventana y ensayar contención antes de usar la rutina con IDs.

### Runbook para el primer lote (solo tras aprobación)

1. **Antes de habilitar el PM de traspaso:** cerrar las pruebas de permisos, paridad y dependencias. `SCA2 CMD TraspasarArchivoHistorico` (`0001f0c0-fddc-8000-dbc9-7f0000014e7a`) pasa de v1.0 (solo inicio y fin) a v2.0 y borrador con un único nodo `Execute Stored Procedure`, conforme al [patrón de reintento](analisis/sca2-reintento-finalizacion.md). Expone `idsPermitidos`, `idsDependenciasAcreditadas` y devuelve `resumen`. La inspección de v2.0 y del borrador confirmó inicio manual, sin timer, ruta de lista vacía hacia el resumen sin pasar por BD y 0 instancias. No se inició el PM, ni siquiera con la lista vacía; falta validar el enlace JDBC y sus privilegios después de que BD instale explícitamente la rutina. Separar los roles de consulta y ejecución y acordar la sincronización. No ejecutar sin autorización.
2. **Ensayo aislado, sin datos reales:** verificar límite de lote, corte horario, revalidación bajo bloqueo, intento concurrente, conflicto de PK con contenido distinto, fallo entre copia y borrado, reejecución idempotente y recuperación si falla Sync. Verificar que el histórico mantiene los mismos IDs y valores, que la transacción revierte completa ante error y que se puede restaurar un lote confirmado. El resumen de batch solo mostrará recuentos y estado; los IDs y valores para conciliación irán en un manifiesto operativo restringido.
3. **Tras autorización explícita del traspaso:** iniciar un único lote pequeño manual, con manifiesto y operador de guardia; no usar timer. Conciliar por tabla y PK el contenido antes/después, filas de hijas, duplicados, métricas, enlaces, documentos y permisos; verificar desaparición del record vivo después de Sync. Si falla una verificación, detener lotes sucesivos, preservar el manifiesto y decidir entre reintentar Sync sin mover datos de nuevo o restaurar.
4. **Restauración:** detener nuevos lotes y coordinar con operaciones el aislamiento de escrituras del lote. Si no hubo commit, verificar que viva e Hist quedaron intactas. Si lo hubo, restaurar en una sola transacción con las PK y valores originales, raíz antes que hijas; si una fila viva ya existe con distinto contenido, detenerse sin sobrescribirla. Retirar de Hist solo las filas del lote ya comprobadas, ajustar secuencias si procede y conciliar los records vivos en Appian. Repetir la comparación funcional y conservar el manifiesto y el resultado. No usar la reversión del DDL para restaurar expedientes.
5. **Producción:** aprobación, retención y ventana de ejecución separadas. Medir tamaño y tiempo de Sync, latencia de consulta y paridad de métricas antes de afirmar una mejora de rendimiento.
