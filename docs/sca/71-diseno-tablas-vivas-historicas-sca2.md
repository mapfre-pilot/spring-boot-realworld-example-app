# 71 · SCA2 — Tablas vivas sincronizadas e histórico de solo consulta

**Estado:** propuesta para revisión, 23/11/2026. Solo SCA2. Se consultó Appian TEST mediante el Dev MCP en modo de solo lectura. No se han creado tablas ni records, ejecutado migraciones, cambiado objetos ni alterado el comportamiento de la aplicación. No se requiere modificar SCA, SCAC ni CORE.

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

## 4. DDL de referencia — PostgreSQL, no desplegar tal cual

El sufijo físico es `_hist` en minúsculas como el resto de tablas (`_HIST` como concepto). Este borrador cubre las 15 tablas de expedientes; no cambia las vivas y no incluye el posible histórico independiente de Trazabilidad. `LIKE` sin opciones copia tipos y NOT NULL sin heredar secuencias ni índices operativos. Son tablas nuevas; ejecutar con el rol de migración tras comprobar que no existen. Cualquier ajuste posterior de una viva exige revisar su par histórica. El [DDL 73](sql/73-promocion-bd-sca2-estructura.sql) no aplica FKs físicas; por diseño la integridad del expediente archivado se comprueba en el lote. Si después se proponen FKs históricas, no vincular jamás con tablas vivas.

```sql
BEGIN;
SET LOCAL search_path TO sca2_anulaciones, pg_catalog;

DO $archivo$
DECLARE
  viva text;
  hist text;
BEGIN
  FOREACH viva IN ARRAY ARRAY[
    'sca2_solicitud', 'sca2_transicion', 'sca2_tarea', 'sca2_error',
    'sca2_llamada_servicio', 'sca2_datos_cabecera', 'sca2_datos_solicitud',
    'sca2_datos_basicos_solicitud', 'sca2_datos_perfiles_pca', 'sca2_datos_productor',
    'sca2_datos_poliza_autos', 'sca2_datos_poliza_hogar', 'sca2_datos_poliza_vida',
    'sca2_niveles_cobertura_autos', 'sca2_otras_solicitudes_cabecera'
  ]
  LOOP
    hist := viva || '_hist';
    EXECUTE format(
      'CREATE TABLE sca2_anulaciones.%I (LIKE sca2_anulaciones.%I,
        "FECHA_ARCHIVADO" timestamptz NOT NULL, PRIMARY KEY ("ID"))',
      hist, viva
    );
    IF viva IN ('sca2_solicitud', 'sca2_datos_cabecera') THEN
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ADD UNIQUE ("ID_SOLICITUD")', hist);
    ELSE
      EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("ID_SOLICITUD")', hist);
    END IF;
  END LOOP;
END;
$archivo$;

ALTER TABLE sca2_anulaciones.sca2_transicion_hist ADD UNIQUE ("CLAVE_IDEMPOTENCIA");
CREATE INDEX ON sca2_anulaciones.sca2_solicitud_hist ("CREATED_AT" DESC, "ID" DESC);
CREATE INDEX ON sca2_anulaciones.sca2_solicitud_hist ("NUM_POLIZA", "CREATED_AT" DESC, "ID" DESC);
CREATE INDEX ON sca2_anulaciones.sca2_transicion_hist ("ID_SOLICITUD", "FECHA" DESC, "ID" DESC);
COMMIT;
```

El índice único del histórico no impide reutilizar claves en la viva. Antes del movimiento, demostrar que ni `ID_SOLICITUD` ni las claves de idempotencia pueden reutilizarse o que reenvíos y altas con colisión conservan el resultado actual sin crear ni reintentar sobre un expediente archivado. Si no se demuestra, no mover Transicion ni su expediente; valorar un registro de claves persistente como prerrequisito separado.

Revisar con DBA el catálogo de restricciones y tipos en el entorno destino. Separar el rol de archivo (copia/borrado acotado) del origen de consulta del histórico (solo SELECT, sin propiedad de tablas ni permisos de escritura), sin rebajar los permisos de lectura existentes. No exponer payloads de error, datos de cliente, credenciales ni IP en nuevas vistas o informes.

## 5. Consultas y paridad funcional

- **Buscador:** filtros, exclusión de `PDTE-*`, orden, recuento, paginación y salto a detalle con un único resultado deben aplicarse al conjunto total, no primero a una página de vivas y luego anexar históricas. Para búsqueda exacta y detalle, usar la viva y hacer fallback por el mismo ID en el histórico ante ausencia, no ante acceso denegado o error. Para filtros amplios, unir con orden estable (`CREATED_AT DESC, ID DESC`) y resolver el estado de sincronización sin duplicados; evaluar una consulta paginada SQL (vista de lectura `UNION ALL`, con fuente y seguridad verificadas) si los dos records no permiten conservar paginación y total de forma eficiente. No limitar la búsqueda a fecha de archivo. Validar filtros por cliente/matrícula que primero resuelven pólizas.
- **Detalle:** conservar la ruta y referencia de solicitud; resolver origen una vez y consultar en él las hijas por `ID_SOLICITUD`, no reconstruir el estado con datos actuales ni invocar acciones de refresco. Mantener documentos, tarjetas, etiquetas y orden histórico; verificar qué acciones están disponibles hoy en terminales y no ocultar ninguna sin aprobación. No presuponer relaciones de record sincronizado ni seguridad de fila heredada para históricos sin Sync: probar consultas explícitas y controles por rol/expediente en ambos orígenes.
- **Cuadro de mando, trazas y bandeja:** saldrán de los KPIs filas aún dentro de la ventana de 90 días si solo se consulta la viva. Preservar ventanas por su fecha original, visibilidad, filtros, totales, ratios y promedios; para porcentajes y latencia combinar numeradores/denominadores o sumas/recuentos, no promediar agregados ya calculados. No trasladar alertas/worklists operativas al histórico; si hoy se puede consultar un error resuelto desde bandeja, mantenerlo disponible con los mismos filtros y sin cambiar reintentos.
- **Operación y APIs:** no hacer fallback automáticamente en reglas de escritura como si el histórico fuese editable. Comparar en TEST el resultado actual para idempotencia, Alta, enlaces antiguos, REST y procesos que referencian IDs; si existen efectos vigentes sobre cerradas, el archivado queda bloqueado para ellas hasta acordar una solución. No deducir que consulta solo lectura implica que cualquier consumidor existente es solo lectura.

## 6. Riesgos, fases y decisiones que requieren confirmación

1. **Antes de construir:** confirmar Data Sync, origen/rol, permisos de fila con perfiles reales, catálogo físico y correspondencia de cierres; inventariar las referencias SCA2 directas y transitivas (incluidas Web APIs, nodos de escritura diferida, redirecciones y enlaces directos). Medir recuentos y razones de exclusión en una extracción coherente sin modificar datos. No usar los 31 como objetivo de migración.
2. **Entrega aditiva en TEST, solo tras autorización:** DDL vacío, records de consulta no sincronizados, lectura conmutada bajo control y simulación sin borrado. Con datos de prueba, comparar mismos filtros/roles, detalle, documentos, cruces del cuadro de mando y bandeja con línea base. Ensayar corte exacto, cambios de mes, reintento del batch, fallo intermedio, carrera con reintento, reenvío con la misma clave y fallo de Sync tras commit.
3. **Piloto en TEST, solo tras aprobar paridad:** lote reducido supervisado, antes/después por ID, cardinalidad e igualdad de valores por tabla, duración de Sync y de consultas, sin repetidos ni nuevas filas huérfanas. Convivencia de consulta y archivo hasta comprobar paridad. Para revertir, parar el batch, aislar escrituras, reinsertar desde el manifiesto con PK originales tras comprobar colisiones y secuencias, restaurar las relaciones, reconciliar Sync, y solo entonces retirar el fallback. Ensayar esa restauración antes del primer borrado.
4. **Salida a producción:** aprobación separada, ventanas/capacidad y retención acordadas. Vigilar contención, reducción real de tamaño/tiempo de sincronización, latencia del buscador y calidad de métricas; no prometer mejora con los volúmenes observados en TEST.

**Requiere confirmación antes de ejecutar o cambiar comportamiento:**

| Decisión | Efecto que debe aprobarse o evitarse |
|---|---|
| Estados y evidencia de cierre, mes natural/zona y excepciones de tareas, errores, llamadas o reaperturas | Define qué deja de estar disponible como expediente vivo y cuándo. Confirmar también si algún cerrado debe seguir operativo o si existe reactivación. |
| Presentación de históricos en buscador/detalle | Mantener la experiencia actual. Una pestaña, filtro, etiqueta, URL diferente, ocultación de acciones o cambio en los resultados/paginación requieren visto bueno. |
| Visibilidad y acciones en bandeja, informes y cuadro de mando | No reducir ventanas ni recuentos ni quitar consultas/reintentos; confirmar cualquier diferencia o falta de paridad. |
| Permisos, retención/purga y tratamiento de trazabilidad no asociable | Acordar quién sigue viendo los datos archivados, por cuánto tiempo, y si Trazabilidad se separa. Este diseño no purga datos ni amplía su acceso. |
| Primera ejecución con borrado, ventana de batch y sincronización | Autorizar el traslado real y cualquier mantenimiento visible, pausa de escritura o cambio de contrato necesario para hacerlo sin incoherencias. |
