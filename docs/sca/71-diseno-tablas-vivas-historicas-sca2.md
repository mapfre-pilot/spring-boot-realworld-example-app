# 71 · SCA2 — Tablas vivas sincronizadas e histórico de solo consulta

**Estado (23/11/2026):** las 15 tablas históricas existen en TEST y estaban vacías en las pruebas del piloto. El sitio aislado «SCA2 Piloto Histórico» está disponible para los dos perfiles autorizados y su enlace directo al detalle funciona para ambos. El orden de argumentos de Contra Anulación también varía en el original. Se aprobó el traspaso en TEST, pero la nueva simulación no encontró candidatos: **0 solicitudes movidas**.

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

### Simulación manual y programada en TEST

`SCA2 CMD SimularArchivoHistorico` — UUID `0001f0c0-fab0-8000-dbb7-7f0000014e7a`. La versión **2.0** era de inicio manual y no tenía temporizador. La versión **3.0**, publicada en TEST, añade un disparador de inicio diario a las **04:30 Europe/Madrid**, después de la caducidad (01:00) y el reintento (03:00). Designer muestra la recurrencia diaria a las 04:30 con la zona del modelo, `Europe/Madrid`. Se conservan las cuatro tareas de script de solo consulta y cálculo, la bifurcación, las variables y los recuentos del resumen de la instancia. No hay escrituras en BD, subprocesos, integraciones ni referencias a Trazabilidad. No se tocó el reporte de Gestiones mantenimiento, el sitio operativo ni el PM de traspaso real.

La prueba manual de la versión 3.0 devolvió `COMPLETED processId=10302389 total=413 candidatos=0`. El PM de traspaso real registró 0 instancias. Queda por comprobar la primera ejecución nocturna; esta programación solo simula y no archiva expedientes. El respaldo de la versión 2.0 y la evidencia de publicación y configuración quedaron fuera de Git en `files/sca2-tablas-historicas/piloto/timer-simulacion/`. Para detener la programación, publicar el PM de simulación sin el disparador recurrente.

El PM fija un corte único de un mes natural en `Europe/Madrid` y pagina por PK. Usa las fechas de transición tipadas en Appian: las escrituras analizadas usan `now()` (véase [43-G](43-G-invalidacion-cache.md)) o UTC explícito (véase [SQL de reintento](sql/sca2-reintento-finalizacion.sql)). El resultado no contiene identificadores de solicitudes. Si no se acredita que no hay dependencias de servicios, procesos o reintentos, el expediente sigue en viva.

Prueba inicial de la versión 2.0 con `testProcessModel`: instancia `17625407`, estado `COMPLETED`, duración `15325 ms`, corte Appian `2026-10-23 10:41:26` UTC.

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

**Estado: consulta histórica conectada en el sitio operativo de TEST; lanzador nocturno conectado, sin traspaso en la primera ejecución.** Los records históricos y sus relaciones se validaron primero con copias aisladas. No se inició el PM de traspaso en la primera ejecución; la rutina revisada se comprobó por JDBC solo con una lista vacía.

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

- Los 15 pares vivo/histórico tienen la misma ACL de objeto. En el modelo devuelto por `getRecordType` ninguno presenta `securityRules` ni `securityExpression`. En `SCA2 Anulaciones` v8, Buscador no añade una condición de página; Errores y Gestiones mantenimiento exigen `SCA2_GRP_ADMINISTRADORES`. Las tres rutas operativas respondieron 200 como `devin`. BD aún debe acreditar los privilegios efectivos del origen de consulta, incluido que solo pueda hacer `SELECT`.
- La relectura con el corte original evaluó 408 solicitudes, una más que la primera simulación, con 251 en estado no elegible. Volvieron a salir 34 retenidas por dependencia no acreditada; al no guardar IDs en la simulación, no puede demostrarse identidad exacta entre ambos grupos solo a partir de sus totales. El cierre registrado de las 34 reencontradas se reparte entre `SCA2 CMD Finalizar` (18), `SCA2 CMD CompletarAccion` (15) y `SCA2 CMD Caducar` (1).
- Ninguna de esas 34 tenía `procesoActivo` o `nodoRelanzar` informado ni filas asociadas encontradas en `SCA2 Llamada Servicio`. El historial de los modelos inspeccionados no devolvió coincidencia para los 245 IDs de instancia vinculados; la consulta directa por los 34 IDs de cierre tampoco encontró estas instancias. Eso no distingue un proceso purgado de uno no visible, y no cubre servicios externos. **Clasificación: 0 seguras, 34 se quedan en viva**. Se necesita contrastar la correspondencia de IDs y la cobertura del historial con el responsable de operaciones, además de verificar los consumidores REST, reintentos y claves de idempotencia descritos en §2–3.

**Decisión sobre las 34 retenidas: B en ambas preguntas.** Se quedan en viva hasta disponer de cotejo. No se consulta ahora a Operaciones y la aprobación del lote las excluye expresamente.

1. ¿Puede Operaciones acreditar, para cada expediente del listado restringido, que no queda ninguna instancia, tarea, reapertura o reintento activo, y que la evidencia cubre el período e IDs consultados? **A. Sí**, indicar cuáles y adjuntar el cotejo; **B. No o solo parcialmente**, mantener en viva los expedientes sin evidencia. **Recomendada: B** hasta disponer del cotejo.
2. ¿Han confirmado todos los responsables de Web APIs, integraciones y reenvíos que no necesitan encontrar en viva esos expedientes ni sus claves de idempotencia? **A. Sí**, adjuntar validación por consumidor y expediente; **B. No o falta algún consumidor**, mantener en viva los casos afectados. **Recomendada: B** mientras falte una confirmación.

### Consultas y pruebas exigidas

Las sondas `validateExpression` sobre `SCA2 Solicitud Hist` no devolvieron errores ni avisos para una consulta paginada con total y un agrupamiento por estado. Esto valida las expresiones, no su ejecución con filas, los permisos de negocio ni la paridad visual. El histórico vacío no permite acreditar el camino que solo se ejecuta tras el archivo; no se hicieron copias de expedientes en TEST.

| Superficie (versión TEST de referencia, sin cambios) | Comportamiento que se debe conservar y prueba pendiente |
|---|---|
| `SCA2_Buscador` 40, `SCA2_BuscadorTabla` 20 | La copia `SCA2_Buscador_HistPiloto` aplica el filtro original a Hist. Sin coincidencias usa la consulta viva original; con coincidencias pide a cada fuente un prefijo de tamaño `startIndex + batchSize - 1`, adapta las filas Hist, ordena, corta la página y suma los dos totales. Conserva la rama CORE y para SCA2 invoca el detalle piloto. Quedan por probar los filtros interactivos, empates, páginas profundas, proyecciones con filas históricas y transición tras Sync. El total sumado presupone que los conjuntos no se solapan. |
| `SCA2_DetalleSolicitud` 77, `SCA2_cargarSolicitud` 10 | El detalle distingue ausencia SCA2 de una solicitud solo CORE y obtiene documentos con `SCA2_PM_OBTENER_DOCUMENTO_GD`. Resolver el origen antes de esa distinción, conservar el enlace e ID y cargar las hijas del mismo origen. Comparar cabecera, tarjetas, tareas, transiciones, errores y descarga; demostrar que ninguna acción que escriba sigue disponible para un expediente elegible. Si alguna sigue disponible, mantener el expediente en viva hasta acordar cómo conservarla. |
| `SCA2_BandejaErrores` 17 | Conservar filtro inicial, estados seleccionables, paginación y enlace al detalle bajo la misma restricción de administrador. Probar errores consultables del histórico y que las selecciones y acciones de relanzar/descartar sigan aplicándose solo a errores pendientes en viva. |
| `SCA2_CuadroMando` 38 | La copia agrega ambos orígenes con los filtros existentes y aplica los límites de presentación al resultado combinado. Queda por comprobar que cada expediente cuenta una sola vez durante la conciliación de Sync, y probar los filtros y gráficos de forma interactiva. Trazabilidad no se mueve. |

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
| [`SCA2_CuadroMando_HistPiloto`](sail/62-cuadro-mando/SCA2_CuadroMando_HistPiloto.sail) | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789527` | 2 |
| `SCA2_IndicadorFinalizacionesFallidas_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789521` | 1 |
| `SCA2_CombinarGrupos_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789489` | 1 |
| `SCA2_ConsultarGrupos_HistPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789509` | 1 |
| `SCA2_PruebaCuadroMando_HistPiloto` (solo datos sintéticos en memoria) | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789513` | 1 |

El detalle decide el origen por ID, da prioridad a viva y pasa el origen a las hijas. En la rama histórica, adapta campos al tipo que consumen las interfaces y bloquea las llamadas directas de escritura/proceso del piloto, salvo la obtención de documentos. No se probó la descarga, la visibilidad de todos los controles ni el camino con filas históricas. La bandeja combina los prefijos de Error vivo e Hist con el mismo filtro y total; las opciones de filtro y la lógica operativa del lote se siguen calculando en viva. Falta probar interacciones y paridad de opciones con datos históricos antes de conectar la bandeja.

Con Hist vacío, los renders del detalle y del buscador enlazado coincidieron en dos expedientes reales; la bandeja coincidió en la carga inicial. Se comparó el árbol de `testInterface` sin `_cId` ni tokens `saveInto`, sin pruebas visuales o clics.

#### Prueba de perfiles en Chrome

En Chrome con interfaz gráfica, el enlace «SSO Mapfre NO PRO» de TEST llevó a `login.microsoftonline.com`. Ambas cuentas mostraron `Sign in`, `Enter password` y `Stay signed in?`. No se observó MFA, aprobación en móvil ni un bucle. El reintento anterior sin responder a ese diálogo no había acreditado el retorno; en Chrome se obtuvo una sesión válida en el sitio SCA2 con ambas cuentas.

| Perfil | Retorno a Appian TEST | Expediente permitido en el original | Documentos en el original |
|---|---|---|---|
| JJGONZ2 | Al responder `No`, volvió a Designer, que mostró `Error 403 - Prohibido/a`. La misma sesión abrió el sitio SCA2 sin volver a pedir credenciales. | El buscador mostró el expediente de prueba; se abrió el detalle desde su fila y desde su URL en otra pestaña. | La lista de documentos mostró un justificante y el visor abrió su PDF de una página. No se descargó. |
| SISANS | Al responder `Yes`, volvió directamente al sitio SCA2. | El buscador mostró el expediente de prueba; se abrió el detalle desde su fila y desde su URL en otra pestaña. | La sección de documentos del expediente usado mostró `No hay documentos a mostrar`; no se validó apertura ni descarga para este perfil. |

En esa prueba inicial, Designer devolvió `Error 403 - Prohibido/a` a ambos al abrir el buscador piloto. Ese 403 no constituye una denegación por expediente. Las capturas de inicio de sesión quedan en la carpeta restringida `piloto/sso-chrome/`, fuera de Git; no se exportaron cookies.

#### Sitio aislado en TEST: SCA2 Piloto Histórico

- **Grupo:** `SCA2_GRP_PILOTO_HISTORICO`, UUID `_e-0000f0ba-6705-8000-9c9d-01075c01075c_11431`. El MCP no devolvió versión para el grupo. Sus dos únicos miembros son JJGONZ2 y SISANS, añadidos directamente por sus UPN de NO PRO.
- **Sitio:** [SCA2 Piloto Histórico](https://mapfrespain-test.appiancloud.com/suite/sites/sca2-piloto-historico), UUID `32e46c8b-31f6-4fc4-873b-f710d1d56742`, versión 3. ACL: sin acceso por defecto, sin grupos administradores o editores y solo el grupo piloto como visor. Las ACL de las copias y de los 15 records Hist no se ampliaron: no hizo falta para las pruebas con Hist vacío y no se ha acreditado que haga falta con filas archivadas. La configuración y la ACL del sitio operativo no cambiaron.

| Página | Interfaz | Condición de página |
|---|---|---|
| `buscador` | `SCA2_Buscador_HistPiloto` v3 · `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789276` | Visible para los miembros admitidos al sitio |
| `errores` | `SCA2_BandejaErrores_HistPiloto` v2 · `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789420` | Misma condición `SCA2_GRP_ADMINISTRADORES` que en el original |
| `cuadro-de-mando` | `SCA2_CuadroMando_HistPiloto` v2 · `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789527` | Misma condición `SCA2_GRP_ADMINISTRADORES` que en el original |

El detalle abre `SCA2_DetalleSolicitud_HistPiloto` v1 desde el buscador y la bandeja, sin página propia.

**Primera prueba (sitio v2, antes de corregir la URL):**

| Perfil | Buscador | Detalle permitido y enlace directo | Documentos | Bandeja y cuadro |
|---|---|---|---|---|
| JJGONZ2 | Mismas filas en las dos primeras páginas con Automóviles (`1–10 de 297` y `11–20 de 297`), y misma primera página al invertir el orden por fecha. | El mismo expediente abre desde la fila. En el original se puede reabrir el detalle desde su URL; copiar la URL del piloto abre el listado, no el expediente. | El visor abre el mismo justificante PDF de una página en ambos. No se descargó. | Denegados en ambos sitios. |
| SISANS | Mismas filas con Automóviles en las dos primeras páginas (`1–10 de 297` y `11–20 de 297`); mismo resultado al ordenar ascendentemente por número de póliza. | El mismo expediente abre desde la fila y el original reabre por URL. El piloto abre el listado al copiar su URL. En «Contra Anulación», los argumentos aparecen en distinto orden; se observó también en el segundo expediente. | Ambos muestran `No hay documentos a mostrar` en el primer expediente. En el segundo, ambos abren la carta firmada de dos páginas. No se descargó. | Denegados en ambos sitios. |

En ambas páginas restringidas y con ambos perfiles, la URL mostró `La página no existe o no tiene permiso para verla`. Esto acredita la misma denegación de página, no el contenido de las pantallas ni el acceso por expediente. No se identificó un expediente con denegación esperada. El piloto presenta también cabecera Appian y controles azules en lugar de la cabecera MAPFRE y el rojo del original. Las 15 tablas Hist devolvieron cabecera sin filas: estas pruebas no acreditan la lectura ni los permisos sobre expedientes archivados.

Evidencias fuera de Git: `/home/ubuntu/memory/appian_91b2ca/files/sca2-tablas-historicas/piloto/sitio-test/`. Los JSON `grupo-miembros.json`, `sitio-final.json` y `sitio-acl.json` recogen la configuración. Las capturas por cuenta y sitio se identifican por `filtro-autos`, `detalle`, `enlace-directo`, `visor`, `argumentos-sin-documentos` y `denegado`; para el detalle original de JJGONZ2, véanse también las capturas previas de `piloto/sso-chrome/`.

**Reprueba del detalle (sitio v3):**

- **Enlace directo:** la página de buscador del piloto tenía sin marcar «Actualizar URL cuando cambien los valores de entrada de regla» y mostraba sus cinco entradas como nuevas. El clic ya guardaba la solicitud en el rule input y abría el detalle, pero la página no persistía ese valor. En Designer se activó la opción y se guardaron los mapeos de `vista`, `numPoliza`, `idSolicitud`, `tipoAccion` e `idTarea`, manteniendo el cifrado. Ahora el piloto genera `?$sp=…` como el original. Es configuración de la página, no del record ni de la copia. Al cambiar la referencia en el sitio operativo, verificar que los cinco mapeos queden asociados a la nueva interfaz y que sigan activos el cifrado y la actualización de URL; el cambio de referencia no se ensayó allí.
- **Orden de argumentos:** el detalle original v77 y el piloto v1 ejecutan la misma llamada a `SCA2_consultaDetalleGestion` al desplegar Contra Anulación y pasan `MSSConsultaDetalleGestion.listadoContraAnul` directamente a la cuadrícula, sin ordenar ni fusionar con Hist. En el original, dos aperturas del mismo expediente como SISANS cambiaron incluso el primer argumento. No se inspeccionó la respuesta bruta de CORE; lo comprobado es que el original no garantiza un orden fijo y que la copia usa la misma ruta. No se añadió un orden solo en el piloto, porque no reproduciría el comportamiento del original.

| Perfil | Enlace directo en piloto | Contra Anulación en original y piloto |
|---|---|---|
| JJGONZ2 | Reabrió el mismo detalle en otra pestaña desde la URL con `$sp`. | La cuadrícula cargó en ambos; el orden observado varió desde la cuarta fila. |
| SISANS | Reabrió el mismo detalle en otra pestaña desde la URL con `$sp`. | La cuadrícula cargó en ambos; el original cambió de orden entre aperturas del mismo expediente. |

Capturas de la configuración y la reprueba, y metadatos del sitio v3: subcarpeta restringida `paridad-detalle/` de `piloto/sitio-test/`. Los destinos de las tres páginas, la visibilidad y la ACL del piloto no cambiaron, ni tampoco la configuración y ACL del sitio operativo.

La prueba de bandeja reutilizó la proyección, orden y paginación de la copia, sustituyendo las consultas por cuatro filas tipadas en memoria: total 4, página desde 2 con IDs 4 (histórico, `RESUELTO`) y 3 (vivo, `PENDIENTE`), sin errores. No cubre filtros interactivos ni acciones.

**Cuadro de mando.** Con Solicitud Hist vacío, la copia conserva las consultas y series originales; el render inicial contra el original v38 coincidió al excluir `_cId` y `saveInto`. Las otras cuatro pestañas del piloto renderizaron sin errores, truncamiento ni timeout. Una validación sin guardar forzó la rama combinada de las cinco pestañas, también sin errores. No se hicieron clics ni se inspeccionó visualmente el render.

Con Hist, las consultas de cada origen agregan con los mismos filtros, intervalos y claves y leen las agrupaciones por páginas, sin aplicar un top-N por origen. La copia suma conteos y sumas por clave, recalcula medias con el conteo de duraciones no nulas, conserva el máximo y genera las series y los top-N a partir de los resultados combinados. La prueba en memoria obtuvo **26 filas** en total y el grupo **X** en primer lugar con **8** (3 vivas y 5 históricas), cuando no era primero en ninguno de los dos orígenes; para X se obtuvo una media de **33,3333** (100/3), no un promedio de medias, y un máximo de **90**. La prueba no inserta filas ni acredita volúmenes altos o permisos con datos Hist.

El indicador piloto de finalizaciones fallidas conserva su lectura de solicitudes vivas en error: estos expedientes no son elegibles para archivar. La quinta pestaña, «Cuadro de Gestión», conserva las consultas de `SCA2 Ejecucion Argumento`, que no pertenece a las 15 tablas del piloto.

#### Conexión del sitio operativo y reversión (TEST)

Se conservaron el sitio `SCA2 Anulaciones` v8, sus páginas, parámetros cifrados, permisos y referencias, incluido el menú de mantenimiento. Se actualizaron las expresiones de `SCA2_DetalleSolicitud` (77 → 78), `SCA2_Buscador` (40 → 41), `SCA2_BandejaErrores` (17 → 18) y `SCA2_CuadroMando` (38 → 39), sin cambiar nombres, entradas ni ACL. La cuadrícula, la URL del buscador, «Ver solicitud» y «Volver al detalle» siguen usando las mismas rutas. El detalle conserva la cabecera original si el expediente sigue en viva y usa la variante histórica de solo lectura cuando solo queda en Hist. La única excepción aceptada es que un marcador nativo `/records` del record vivo puede dejar de abrir al archivarse el expediente; se podrá volver a localizar en el buscador del sitio.

Buscador, bandeja, otras solicitudes y métricas descartan de Hist las claves que el record vivo aún devuelve antes de contar, ordenar, paginar o agregar. Los selectores Comando, Nodo y Código combinan los orígenes sin duplicados. El ensayo de solapamiento en memoria devolvió una fila y total uno; los renders A/B de las cuatro interfaces operativas con Hist vacío coincidieron (`True`).

| Perfil | Verificación visual en Chrome de escritorio |
|---|---|
| `devin` | Buscador, detalle desde una fila y su URL, bandeja con sus selectores y cuadro de mando con gráficos. El resumen mostró 413 solicitudes. |
| `JJGONZ2` (SSO NO PRO) | Automóviles: páginas 1–10 y 11–20 de 297, mismo orden inicial e invertido. Detalle desde una fila y su URL. Se abrió el justificante de una página. Errores y Gestiones mantenimiento conservan la denegación. |
| `SISANS` (SSO NO PRO) | Automóviles: páginas 1–10 y 11–20 de 297, mismo orden inicial y al ordenar por póliza. Detalle desde una fila y su URL, un caso sin documentos y carta firmada en otro expediente. Errores y Gestiones mantenimiento conservan la denegación. El orden variable de los argumentos de CORE ya se observaba en el original. |

Los respaldos JSON (expresión, UUID, entradas, ACL e historial de versiones), del sitio y de las otras entradas, y las capturas (`devin-*`, `jjgonz2-*`, `sisans-*`) están en el directorio restringido `files/sca2-tablas-historicas/piloto/operativo/`. **Reversión:** por UUID de cada JSON `<clave>-antes`, restaurar solo `objeto.expression` mediante `updateInterface` con el `versionId` actual, en este orden: cuadro, bandeja, buscador, detalle. Releer y cotejar expresión, entradas y ACL. No alterar las referencias de sitio, menú, tareas o record. Esta reversión no restaura expedientes.

Los 15 records Hist estaban vacíos. No se verificaron descargas, un expediente explícitamente denegado, acciones que cambien datos ni latencia con volumen histórico.

#### Retirada del sitio piloto (TEST)

Se eliminaron el sitio `SCA2 Piloto Histórico` v3 y su grupo `SCA2_GRP_PILOTO_HISTORICO`, las pantallas `SCA2_Buscador_HistPiloto` y `SCA2_BandejaErrores_HistPiloto` y las reglas `SCA2_PruebaPaginacion_HistPiloto`, `SCA2_PruebaBandeja_HistPiloto` y `SCA2_PruebaCuadroMando_HistPiloto`. Se comprobó el índice de dependencias antes de cada baja; la pertenencia a la aplicación no es un consumidor. Los siete respaldos con definiciones, dependencias y ACL, el historial disponible y la membresía del grupo están en `piloto/retirada-piloto/`.

Se conservaron `SCA2_CuadroMando_HistPiloto`, `SCA2_DetalleSolicitud_HistPiloto` y sus dependencias, los auxiliares usados por el sitio normal (cabecera histórica, otras solicitudes, filtros y consultas), el simulador, el informe, los 15 records Hist y las copias de reversión de las pantallas anteriores hasta el primer expediente archivado. Tras la retirada, Chrome mostró a `devin` el buscador, la bandeja y el cuadro de mando del sitio normal; las tres capturas están en el mismo directorio. No se modificaron las referencias del sitio normal.

#### Fichero de instalación de la rutina (DBeaver, TEST)

**Fichero:** [`docs/sca/sql/sca2-hist-traspaso.sql`](sql/sca2-hist-traspaso.sql). Con autorización de BD, abrir este fichero en DBeaver contra PostgreSQL TEST y ejecutar el script completo (Alt+X) con parada ante error, con un usuario habilitado para asumir `user_sca2_anulaciones`. Requiere la estructura viva, las quince tablas Hist y la tabla de reintentos. Instala el procedimiento `sca2_anulaciones.sca2_pm_traspasar_historico` en una transacción y no ejecuta ningún lote. No ejecutar `CALL` ni iniciar el PM durante la instalación. El script de [prueba local](pruebas/sca2-hist-traspaso-local.sql) es solo para PostgreSQL desechable, no para TEST.

El usuario confirmó en DBeaver TEST que el catálogo devuelve `sca2_pm_traspasar_historico(text,text)` con `es_procedimiento = true`. Esta consulta no invoca la rutina ni acredita los privilegios del origen JDBC de Appian.

La revisión publicada en `e93193a` añade `idsArchivados` y `clavesSync` por tabla a los recuentos del lote. En PostgreSQL 14 local se instaló la versión anterior y se aplicó la revisión dos veces; los volcados de filas y secuencias se mantuvieron idénticos. La prueba local validó el manifiesto, los recuentos, la reversión por colisión y la reejecución sin movimientos. La copia para DBeaver está en `/home/ubuntu/sca2-hist-traspaso.sql`.

Tras la confirmación de instalación en TEST, un PM temporal usó el mismo servicio `Execute Stored Procedure` y origen JDBC que el PM real, con `[]` fijo en ambos parámetros. Terminó en `COMPLETED`, sin error JDBC, y devolvió `{"solicitados":0,"archivados":0,"repetidos":0,"excluidos":0,"conflictos":0,"filas":0,"idsArchivados":[],"clavesSync":{}}`. Se eliminó el PM temporal y se verificó que ya no figuraba en SCA2. Esto confirma el contrato nuevo en TEST sin mover datos; no prueba los permisos sobre las tablas con un lote no vacío ni la retirada de filas por Sync.

La rutina admite hasta diez IDs explícitos por lote (deduplicados) y solo admite archivar un expediente si también consta en la lista independiente de dependencias acreditadas; una lista de permisos vacía retorna un resumen a cero sin consultar ni bloquear las tablas. Revalida en BD estado, cierre, corte de un mes natural, pendientes y reaperturas. Copia las quince tablas preservando las PK antes de borrar de viva; una colisión incompatible revierte la unidad correspondiente y una reejecución no vuelve a mover un expediente ya archivado. PostgreSQL confirmó estos escenarios sobre datos sintéticos locales; los bloqueos `NOWAIT` a nivel de tabla requieren acordar una ventana y ensayar contención antes de usar la rutina con IDs.

#### Resultado del control previo al traspaso en TEST (23/11/2026)

Tras la aprobación, `SCA2 CMD SimularArchivoHistorico` devolvió `COMPLETED processId=823718 total=413 candidatos=0`. Excluyó 256 solicitudes por estado no elegible, 114 por cierre reciente, 37 por dependencias no acreditadas, 3 por tarea pendiente y 3 por `errorPendiente`. Esta última categoría lee el record de errores; no es un recuento de filas de la cola de reintentos. Los demás motivos devolvieron cero. Las 37 exclusiones por dependencias son un recuento de esta simulación, que no devuelve los IDs de las exclusiones; no sustituyen la lista de 34 IDs retenidos.

La lista permitida quedó vacía al aplicar la exclusión explícita de las 34 retenidas al conjunto vacío de candidatos. `SCA2 CMD TraspasarArchivoHistorico` registró 0 instancias; no se invocó la rutina ni se movió ninguna solicitud. No hay filas afectadas que respaldar, lote que conciliar, Data Sync posterior al traspaso ni expedientes archivados con los que verificar la paridad de pantallas. El resultado de simulación y el manifiesto quedan fuera de Git en `files/sca2-tablas-historicas/piloto/traspaso/`.

### Runbook para el primer lote (solo tras aprobación)

1. **Revisión 3 confirmada en TEST por JDBC.** Una sonda temporal con el mismo origen y servicio de Appian que el PM real pasó `[]` en ambos parámetros y terminó en `COMPLETED` sin error JDBC: `versionRutina: 3`, `archivados: 0`, `idsArchivados: []`, `clavesSync: {}`. Se eliminó la sonda. `SCA2 CMD TraspasarArchivoHistorico` (`0001f0c0-fddc-8000-dbc9-7f0000014e7a`) quedó publicado en v8.0, **sin temporizador ni instancias**. Valida el manifiesto, usa 15 nodos Sync Records por PK borrada y comprueba que las claves ya no estén visibles en los records vivos. Un error JDBC, manifiesto inválido, `QueryError` o una PK aún visible conduce a error. Una copia del grafo v8 con parámetros JDBC fijos a lista vacía devolvió `COMPLETED SIN_TRASLADO`; no se ha probado Sync con claves reales.
2. **Disparo real conectado al temporizador existente.** En TEST, `SCA2 CMD SimularArchivoHistorico` v4.0 conserva el resumen y llama después, como iniciador, al subproceso síncrono `SCA2 CMD ArchivoHistoricoNocturno` (`0001f0c1-8304-8000-dbf6-7f0000014e7a`, v2.0). El lanzador no tiene temporizador propio: se conserva el activador diario existente del simulador. Solo inicia el PM real con lista permitida no vacía; pasa `idsPermitidos` e `idsDependenciasAcreditadas` por separado (hasta diez solicitudes). Se cotejaron los 34 IDs únicos del manifiesto restringido y el PM real vuelve a vetarlos antes del JDBC.

   - La simulación aislada devolvió `COMPLETED`: 413 evaluadas, 0 candidatas, 0 permitidas y 34 retenidas. Los 34 IDs coinciden con el manifiesto restringido. Esta corrida usa la acreditación de entrada de la copia; no es una prueba de extremo a extremo del criterio nuevo.
   - **Reintentos sin consulta separada:** el simulador excluye errores no cerrados y la [rutina v3](sql/sca2-hist-traspaso.sql) comprueba la cola bajo bloqueo dentro de la transacción. Solo `RECUPERADO` y `OMITIDO` no bloquean. La [prueba local](pruebas/sca2-hist-traspaso-local.sql) conservó el resultado anterior y dejó en viva `MANUAL` con error `RESUELTO`, `PENDIENTE` y `AGOTADO`. Dos instalaciones locales encima del SQL previo de TEST dejaron datos y secuencias idénticos. La llamada vacía devolvió `versionRutina: 3`, `archivados: 0`, `idsArchivados: []`, `clavesSync: {}`.
   - El lanzador consulta el informe `SCA2 Procesos por Solicitud HistPiloto` (ID 590366) con una expresión interna, sin cambiar el contrato de la [regla piloto anterior](sail/piloto/SCA2_acreditarDependenciasArchivo.sail). Las instancias activas o pausadas, incluida pausa por excepción, bloquean la solicitud. Si falta la columna o el ID de una instancia abierta, aparece un estado desconocido o el resultado es incompleto (tope de 500 filas), no acredita el lote.
   - La sonda de solo lectura como `devin`, con corte de las 04:30 Europe/Madrid, devolvió 413 evaluadas, 0 candidatas y 34 retenidas fuera; informe válido con 48 filas y 1 abierta. Se comprobó que `devin` es administrador del sistema en TEST. La réplica del lanzador, sin nodo de traspaso y con el mismo corte, devolvió `COMPLETED` con 413/0/34, pero el nodo del informe corrió como `Administrator` en el ejecutor de pruebas. Eso no acredita la identidad del temporizador. El lanzador exige iniciador `devin` y privilegios de administrador en la ejecución y la lectura del informe; si no los tiene, no acredita solicitudes y queda en error. Se eliminaron las sondas temporales.

   En Process Modeler se volvió a abrir la v4.0 y se verificó que `Temporizador_1` seguía con recurrencia diaria a las **04:30 Europe/Madrid**, usando la zona del modelo (`pm!timezone`). El lote de prueba de solo lectura con subproceso de prueba devolvió `COMPLETED`, 413 evaluadas, 0 candidatas y un hijo iniciado por `devin`. Al publicar se verificaron 0 instancias tanto del lanzador como del PM real. Queda por observar la primera ejecución por temporizador y comprobar su identidad efectiva. No iniciar manualmente el simulador v4.0 ni el traspaso: la v4.0 ya conecta con la ruta real. Para volver a simulación sola, republicar desde Process Modeler la definición v3.0 y verificar su mismo activador y zona, sin crear un segundo temporizador. Los respaldos de definiciones, versiones y ACL y las evidencias están en `piloto/revision-entradas/reusar-timer-*` y `piloto/revision-entradas/corte-v3-*`.
3. **Primera noche real:** no habrá traspaso manual ni ensayo controlado previo. La primera ejecución nocturna con expedientes elegibles será la prueba: conciliar filas por tabla y PK, verificar que no quedan duplicados, que las claves desaparecen del record vivo y que se conservan métricas, enlaces, documentos y permisos. Mostrar solo recuentos y estado en el resumen de batch; mantener las claves y valores en el manifiesto restringido. Si falla una verificación, detener lotes sucesivos, preservar el manifiesto y decidir entre reintentar solo Sync o restaurar.
4. **Restauración:** detener nuevos lotes y coordinar con operaciones el aislamiento de escrituras del lote. Si no hubo commit, verificar que viva e Hist quedaron intactas. Si lo hubo, restaurar en una sola transacción con las PK y valores originales, raíz antes que hijas; si una fila viva ya existe con distinto contenido, detenerse sin sobrescribirla. Retirar de Hist solo las filas del lote ya comprobadas, ajustar secuencias si procede y conciliar los records vivos en Appian. Repetir la comparación funcional y conservar el manifiesto y el resultado. No usar la reversión del DDL para restaurar expedientes.
5. **Producción:** aprobación, retención y ventana de ejecución separadas. Medir tamaño y tiempo de Sync, latencia de consulta y paridad de métricas antes de afirmar una mejora de rendimiento.

#### Incidencia del primer disparo en TEST (24/11/2026)

- A las **04:30 Europe/Madrid**, el simulador v4.0 (instancia `9250497`, iniciador `devin`) evaluó 426 solicitudes y mostró 0 candidatas. El subproceso v2.0 (`9250501`, mismo iniciador) ejecutó el nodo de informe como `Administrator`. Su consulta 590366 devolvió 228 de 228 filas, con columnas `c0`–`c3` e ID de solicitud en `c3`. Las dos filas activas eran ejecuciones del propio simulador (modelo `6320`), que no recibe `idSolicitud`. El lanzador rechazó el lote por los IDs vacíos, no por paginación, columnas o timeout: no llegó al nodo de traspaso. El camino de error intentó evaluar `1 / pv!errorDisparo` con valor cero y dejó al lanzador detenido con el padre a la espera.
- El lanzador **v3.0**, publicado con el mismo UUID, excluye únicamente `6320` de las dos listas del contexto del informe (quedan 21 modelos). La sonda devolvió 222 de 222 filas, cero abiertas y un informe válido. Se conservan los estados bloqueantes, las comprobaciones de integridad y el rechazo ante cualquier otra instancia abierta sin ID. Se verificó que el grafo del simulador v4.0, su llamada síncrona y el nodo que inicia el PM real no cambiaron. El camino de error guarda el texto `ERROR`, alerta al grupo **SCA2 Alertas** y termina en vez de provocar una excepción aritmética. Con el informe original inválido, la sonda sin capacidad de iniciar el PM real terminó `COMPLETED` con el resultado funcional `ERROR`, 0 permitidas, 0 acreditadas y evento `TYPE_COMPLETE` de la alerta. El evento acredita la ejecución del nodo, no la recepción individual. Los errores no controlados del motor siguen sujetos a las alertas nativas de Appian.
- La sonda con informe válido terminó `COMPLETED` sin error: evaluó **426**, dejó fuera las **34** retenidas y acreditó **4**, no 0. El simulador cuenta como `dependenciaNoAcreditada` todas las solicitudes que superan sus demás filtros (38 en la ejecución real); el lanzador aplica la acreditación de procesos, el manifiesto y los campos de bloqueo (34 quedaron en esa categoría, 4 pasaron). El resto de categorías coincidió entre esa ejecución del simulador y la sonda. Los 413 corresponden a la referencia del día anterior; los recuentos conservados no identifican las 13 solicitudes de diferencia. Las 4 candidatas no son traspasos: el próximo lote vuelve a evaluar la situación y la rutina mantiene sus propios vetos. El PM real no se ejecutó manualmente ni se cambió el sitio.
- Se cancelaron desde Monitor los dos padres `9250497` y `14500108`, que arrastraron a sus hijos síncronos `9250501` y `14500479`. Tras la cancelación, los cuatro devolvieron `CANCELLED` sin error actual. No quedaron instancias abiertas del simulador, del lanzador o del PM real; este último registró 0 instancias en total. Los respaldos previos, el diagnóstico, las sondas y la comprobación posterior están fuera de Git, en `piloto/revision-entradas/incidente-*`.

#### Primer lote con expedientes archivados en TEST (25/11/2026)

La ejecución programada de las **04:30 Europe/Madrid** inició el simulador v4.0 (`15575642`) con `devin`: 432 evaluadas, 0 candidatas en el resumen sin acreditación. El lanzador v3.0 (`15575644`) validó el informe (449 filas, 0 abiertas), mantuvo fuera las 34 retenidas y acreditó 4 solicitudes.

El PM real v8.0 (`15575645`) completó el nodo **Traspasar lote en una transacción**. La rutina v3 devolvió `archivados: 4`, `filas: 97`, `conflictos: 0` y 97 claves de borrado en 11 tablas; los cuatro IDs constan en el manifiesto restringido. Después, la puerta **¿El manifiesto coincide con el resumen?** tomó la salida de error antes del primer Sync. El nodo de error quedó detenido al evaluar `estadoSync:1 / if(pv!cursorSync > 0, 0, 1)`: `Invalid division: Denominator may not be zero (0)`. Este error es el del nodo que señaliza el rechazo; no identifica qué condición rechazó el manifiesto.

En la revisión, las tres instancias estaban `ACTIVE`, sin hora de fin: el PM real en error y el lanzador y el simulador esperando. No se ejecutaron Sync ni su comprobación posterior. No se canceló, restauró ni reintentó nada tras la escritura que reportó la rutina. Quedan pendientes el cotejo físico vivo/Hist y la paridad de buscador, detalle, documentos, enlace del sitio, bandeja de errores y cuadro de mando. Mantener las copias de reversión hasta resolver Sync y comprobar esa paridad.

Antes del siguiente lote, coordinar la suspensión del disparo real y conciliar las claves ya archivadas. Si solo falta sincronizar, recuperar Sync con ese manifiesto sin volver a ejecutar el procedimiento de traspaso.

#### Recuperación en TEST: disparo real deshabilitado, cotejo y Sync completados

En TEST se respaldó el simulador v4.0 y se publicó `SCA2 CMD SimularArchivoHistorico` v5.0. La comparación del modelo publicado con el respaldo mostró el nodo de inicio intacto, sin nodos nuevos, y solo dos cambios en el grafo: se eliminó la llamada al lanzador y el nodo de resumen pasó a Fin. Así se conserva el temporizador existente sin disparar el lote real desde las **04:30 Europe/Madrid**. Se leyó la zona del modelo en Process Modeler; no se pudo volver a abrir la configuración de recurrencia para una captura nueva.

El manifiesto de `15575645` contiene 97 claves en 11 de las 15 tablas. El cotejo físico de solo lectura no devolvió datos: la primera sonda de exportación falló con `The following error was raised by the Export to Excel function: null`; la segunda falló con `Cannot invoke "java.sql.Connection.close()" because "conn" is null`. Se eliminaron ambos modelos y carpetas temporales; al consultar las instancias de sonda `14505961` y `10310076`, Appian todavía las reportó `ACTIVE` con error. Estos errores no prueban ni descartan un descuadre físico.

Se detuvo la recuperación antes de Sync. No se volvió a ejecutar la rutina, no se cancelaron las tres instancias del lote y no se cambió la validación. Sigue sin confirmarse qué condición rechazó el manifiesto. Tampoco se verificaron buscador, detalle, documentos, enlace del sitio, bandeja ni cuadro de mando. Siguiente paso: obtener un resultado de solo lectura de las 15 parejas vivo/Hist, por una conexión de TEST que funcione, y cotejar IDs y claves antes de autorizar Sync. Mantener el disparo real deshabilitado y las copias de reversión.

El cotejo posterior en TEST con `a!queryRecordType` sobre los **15 records Hist directos** devolvió **97/97 claves exactas para las cuatro solicitudes**, incluidas cuatro tablas que correctamente no devolvieron filas. Se eliminó la regla temporal de consulta. La parte viva sigue sin verificar: Appian no devolvió almacenes para la aplicación SCA2, ni un almacén publicado para su origen de datos, ni constantes de entidad SCA2 en el inventario consultado. Los records vivos sincronizados no sustituyen una lectura de la base de datos. No se ejecutaron Sync ni los pasos posteriores.

La alternativa en `~/sca2-respaldos/cotejo-2511.sql` es una sola consulta `SELECT` para DBeaver en TEST. Devuelve una fila por pareja de tablas, con recuentos vivo/Hist, claves faltantes o inesperadas, claves aún presentes en vivo y claves del manifiesto asociadas a otra solicitud. Se probó en PostgreSQL local en modo de solo lectura; falta ejecutarla contra TEST. Solo si devuelve 97 filas Hist con las claves esperadas y ninguna en vivo se puede continuar con la recuperación.

Se cancelaron únicamente las dos sondas fallidas desde el monitor global. La consulta de estado posterior confirmó `14505961 CANCELLED` y `10310076 CANCELLED`.

**Cotejo final y Sync.** El usuario confirmó el resultado DBeaver TEST de `cotejo-2511.sql`: 0 filas vivas en las 15 tablas, 97 filas Hist esperadas y ninguna clave faltante, inesperada o vinculada a otra solicitud. Se ejecutó un PM temporal de **solo Sync** sin nodo JDBC (instancia `13462066`, `COMPLETED`): 11 operaciones sobre las 97 PK del manifiesto, sin errores, y los 11 post-checks devolvieron 0 claves visibles en los records vivos. El post-check por solicitud devolvió también 0 en vivo y una fila Hist por cada ID (`15788266`, `15788314`, `15788315`, `15788321`). Se eliminó el PM temporal y se verificó su ausencia. Monitor confirmó `15575645 CANCELLED`, `15575644 CANCELLED` y `15575642 CANCELLED`. No se volvió a invocar la rutina.

**Causa y corrección.** Al reproducir la validación v8 con el resultado real de `15575645`, las conversiones escalares de las listas de claves y el recuento de IDs sin convertir la lista a su tipo daban un solo elemento por lista no vacía: 1 ID en vez de 4, y 1 clave por tabla poblada en vez de sus 97 claves en total. Eso activó el rechazo y el nodo aritmético de error provocó la división por cero. El PM real **v9.0**, publicado tras respaldo y pruebas sin JDBC ni Sync, usa listas tipadas en la validación y en los pasos que consumen las claves. El error controlado registra el motivo, ejecuta la alerta a **SCA2 Alertas** y termina. Las reproducciones devolvieron:

- Resultado real: `COMPLETED VERIFICADA`, sin alerta.
- Resultado vacío: `COMPLETED SIN_TRASLADO`, sin alerta.
- Resultado incompleto: `COMPLETED ERROR: retenidas, JDBC o manifiesto de sincronización inválido`, nodo de alerta completado. El evento no acredita la recepción individual.

El simulador **v5.0** sigue sin llamada al lanzador; v9.0 no reactiva el disparo real. El monitor de SCA2 mostraba «Hay 0 errores de proceso sin resolver de las últimas 24 horas» y la consulta del historial de los tres modelos no encontró instancias abiertas ni pausadas. Las tres ejecuciones canceladas siguen en el historial; no se reintentó ni borró ninguna de ellas. Se mantienen las copias de reversión.

**Cuadro de mando.** `SCA2_CuadroMando` v39, guardado por `devin` el 23/11/2026 a las 18:48:13 UTC, llamaba sin argumentos a `SCA2_CuadroMando_HistPiloto` v3, guardado por `devin` ese día a las 18:39:16 UTC. `tabInicial` es un entero que selecciona la pestaña inicial y su valor por defecto es 1. Tras respaldar objetos, versiones y ACL, en v40 solo se cambió la llamada a `rule!SCA2_CuadroMando_HistPiloto(tabInicial: 1)`. Con `devin`, la pestaña operativa se abrió sin error y, para el mismo intervalo (25/08/2026–23/11/2026), mostró los nueve recuentos de referencia: 432 solicitudes, 37 en curso, 162 cerradas, 67 contra anulaciones positivas, 89 mecanizadas, 2714 pasos, 224 tareas pendientes, 1039 llamadas y 233 solicitudes en error. Esta comparación se hizo antes de recuperar Sync.

**Sitio operativo tras Sync, con `devin`.** El buscador no expone un campo de número de solicitud: se filtró por la póliza de cada expediente y se comprobó una sola fila con su ID exacto. Los cuatro detalles se abrieron desde la fila y al volver a cargar su enlace directo del sitio. La bandeja, filtrada por cada ID, mostró 0 errores. La sección de documentos estaba vacía en `15788266` y `15788314`. En `15788315` y `15788321` mostró cuatro documentos en cada uno y se abrió el visor de uno por expediente, sin cotejar el contenido de los PDF. El cuadro para 25/08/2026–23/11/2026 mantuvo los nueve recuentos anteriores, ya sin las cuatro solicitudes en el record vivo. El SSO NO PRO de `JJGONZ2` y `SISANS` no regresó de Microsoft a Appian; no se verificó la visibilidad con esos perfiles.

Los respaldos, resultados y capturas están fuera de Git en `~/sca2-respaldos`: `2026-11-25-replay-manifiesto-v8*`, `2026-11-25-sync-only*`, `2026-11-25-post-sync-por-id.json`, `2026-11-25-cancelar-lote-estado.log`, `2026-11-25-monitor-sca2.png`, `2026-11-25-fix-*`, `cotejo-sitio-*.png`, `cuadro-sca2-test-v40-mismo-periodo.png` y `cuadro-sca2-test-despues-sync.png`.

#### Reactivación autorizada en TEST (25/11/2026)

Tras respaldar la definición y los permisos, se publicó `SCA2 CMD SimularArchivoHistorico` **v6.0**. El único cambio en el grafo restablece la llamada síncrona al terminar el resumen, con la asignación al iniciador que tenía v4.0. La cadena publicada es **simulador v6.0 → lanzador v3.0 → traspaso v9.0**; el inicio y el resumen del simulador no cambiaron. Las definiciones del lanzador y del traspaso se cotejaron con las versiones verificadas: siguen el criterio A, el veto de las 34 retenidas y la condición de arrancar el traspaso solo si hay IDs permitidos.

En Process Modeler, la v6.0 muestra el mismo `Temporizador_1`: recurrencia cada día a las **04:30**, con `pm!timezone` y zona del modelo **Europe/Madrid**. No se creó ni se cambió el temporizador. Capturas: `~/sca2-respaldos/reusar-timer-recurrencia-reactivacion-v6.png` y `~/sca2-respaldos/reusar-timer-zona-reactivacion-v6.png`.

No se inició ningún modelo manualmente. Al publicar se observó un arranque adicional del simulador a las 08:16 Europe/Madrid (`537700318`, iniciador `devin`): terminó con 428 evaluadas y 0 candidatas en el resumen. El lanzador (`537700319`) terminó por la salida controlada de error: el informe devolvió 252 filas, 1 abierta y `valido: false`; se completó el nodo de alerta a **SCA2 Alertas**. No se identificó la fila abierta a partir de las variables guardadas. No se inició ninguna instancia nueva del PM real ni se movieron datos. Respaldos y estados del arranque en `~/sca2-respaldos/2026-11-25-reactivacion-*`.

En la revisión posterior al lote del 26/11, comprobar las instancias del simulador y lanzador: estado, iniciador, validez del informe y número de candidatas. Si arrancó el PM real, verificar su versión, manifiesto, Sync y post-check. Confirmar que no queden instancias pausadas ni errores sin resolver. Si falla, conservar la evidencia sin reintentar manualmente.
