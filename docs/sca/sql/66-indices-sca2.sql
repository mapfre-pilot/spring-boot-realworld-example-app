-- =============================================================================
-- 66-indices-sca2.sql — Índices y restricciones de rendimiento/robustez SCA2
-- =============================================================================
-- Motor: Aurora PostgreSQL (data source SCA2 _a-0000f069-4f37-8000-9cc8-011c48011c48_20050863,
--        databaseType = PostgreSQL según listDataSources del MCP de TEST).
-- Esquema: sca2_anulaciones. Solo tablas sca2_* (no toca SCA, SCAC ni PRBRV_*).
-- Informe: docs/sca/66-indices-bd-sca2.md (justificación, prioridades y medición).
--
-- Ejecución (DBA, primero en TEST, nunca directamente en PRO):
--   psql "host=... dbname=... user=user_sca2_anulaciones" -v ON_ERROR_STOP=0 -f 66-indices-sca2.sql
--   * Ejecutar con el owner de las tablas (user_sca2_anulaciones, ver 56-owner-sca2.sql).
--   * CREATE INDEX CONCURRENTLY no puede ir dentro de una transacción: lanzar en
--     autocommit (sin BEGIN/COMMIT y sin "psql -1"). No bloquea escrituras.
--   * Bloque A: solo SELECT. Revisar su salida antes de seguir con B, C y D.
--   * Bloque C: cada restricción se crea dentro de un DO que comprueba antes los
--     datos; si hay duplicados/nulos emite WARNING y NO la crea.
--   * Todo es idempotente (IF NOT EXISTS / comprobación en catálogo).
--   * Los record types SCA2 están (inferido) sincronizados: si se modifica o borra
--     un dato directamente en la BD, lanzar después la sincronización completa
--     del record type en Appian (Designer > record type > Data Sync).
--   * Rollback: al final de cada bloque y rollback global en el bloque R.
-- =============================================================================

SET search_path TO sca2_anulaciones;
SET lock_timeout = '5s';          -- no esperar indefinidamente a un bloqueo
SET statement_timeout = '15min';

-- =============================================================================
-- A. COMPROBACIONES PREVIAS (solo lectura)
-- =============================================================================

-- A1. Versión del motor, base de datos y collation (la collation decide si
--     "starts with" (LIKE 'x%') puede usar un índice B-tree normal: solo con "C").
SELECT version();
SELECT current_database(), current_user, datcollate, datctype
  FROM pg_database WHERE datname = current_database();

-- A2. Tablas, filas reales y tamaño (tablas SCA2 del esquema).
SELECT c.relname                                   AS tabla,
       c.reltuples::bigint                         AS filas_estimadas,
       s.n_live_tup                                AS filas_vivas,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano_total,
       s.seq_scan, s.idx_scan, s.n_tup_ins, s.n_tup_upd, s.n_tup_del,
       s.last_analyze, s.last_autoanalyze
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  LEFT JOIN pg_stat_user_tables s ON s.relid = c.oid
 WHERE n.nspname = 'sca2_anulaciones' AND c.relkind = 'r' AND c.relname LIKE 'sca2\_%'
 ORDER BY c.relname;

-- A3. Índices existentes HOY (el MCP de Appian no los expone: [Pendiente] en el informe).
SELECT tablename, indexname, indexdef
  FROM pg_indexes
 WHERE schemaname = 'sca2_anulaciones' AND tablename LIKE 'sca2\_%'
 ORDER BY tablename, indexname;

-- A4. Uso, tamaño y validez de cada índice (idx_scan = 0 tras semanas → candidato a revisar).
SELECT t.relname AS tabla, i.relname AS indice, ix.indisunique AS es_unico,
       ix.indisvalid AS es_valido, st.idx_scan, st.idx_tup_read,
       pg_size_pretty(pg_relation_size(i.oid)) AS tamano
  FROM pg_index ix
  JOIN pg_class i ON i.oid = ix.indexrelid
  JOIN pg_class t ON t.oid = ix.indrelid
  JOIN pg_namespace n ON n.oid = t.relnamespace
  LEFT JOIN pg_stat_user_indexes st ON st.indexrelid = ix.indexrelid
 WHERE n.nspname = 'sca2_anulaciones' AND t.relname LIKE 'sca2\_%'
 ORDER BY t.relname, i.relname;

-- A5. Restricciones existentes (PK, UNIQUE, FK, CHECK).
SELECT conrelid::regclass AS tabla, conname, contype, convalidated,
       pg_get_constraintdef(oid) AS definicion
  FROM pg_constraint
 WHERE connamespace = 'sca2_anulaciones'::regnamespace
   AND conrelid::regclass::text LIKE 'sca2\_%'
 ORDER BY 1, 2;

-- A6. Columnas clave: tipo, longitud y nulabilidad.
SELECT table_name, column_name, data_type, character_maximum_length, is_nullable, column_default
  FROM information_schema.columns
 WHERE table_schema = 'sca2_anulaciones' AND table_name LIKE 'sca2\_%'
   AND column_name IN ('ID','ID_SOLICITUD','NUM_POLIZA','ESTADO','ESTADO_SOLICITUD','TIPO',
                       'CLAVE_IDEMPOTENCIA','COMANDO','CODIGO','FECHA','FECHA_CREACION',
                       'FECHA_INICIO','CREATED_AT','CADUCIDAD_TAREA','VALIDA_HASTA',
                       'FECHA_CACHE','ORIGEN_CACHE','POLIZA_FECHAULTIMOSINIESTRO','ACTIVO',
                       'COD_TP_ARG')
 ORDER BY table_name, column_name;

-- A7. Vistas que dependan de tablas SCA2 (un ALTER COLUMN TYPE falla si hay vistas).
SELECT DISTINCT v.relname AS vista, t.relname AS tabla
  FROM pg_depend d
  JOIN pg_rewrite r ON r.oid = d.objid
  JOIN pg_class v ON v.oid = r.ev_class
  JOIN pg_class t ON t.oid = d.refobjid
  JOIN pg_namespace n ON n.oid = t.relnamespace
 WHERE n.nspname = 'sca2_anulaciones' AND t.relname LIKE 'sca2\_%' AND v.oid <> t.oid;

-- A8. Duplicados que impedirían cada UNIQUE propuesto (debe devolver 0 filas).
-- A8.1 Caché de cabecera: una fila por solicitud (decisión funcional R38).
--      En TEST (12/11/2026) había 4 solicitudes con 2 filas CACHE (15788810, 15788865,
--      15788867, 15788876), creadas con 4–8 s de diferencia.
SELECT "ID_SOLICITUD", count(*) AS filas, array_agg("ID" ORDER BY "ID") AS ids,
       array_agg("ORIGEN_CACHE" ORDER BY "ID") AS origenes
  FROM sca2_datos_cabecera
 GROUP BY "ID_SOLICITUD" HAVING count(*) > 1 ORDER BY 1;
-- Filas sobrantes (todas salvo la de mayor ID, el mismo criterio que
-- SCA2_obtenerFilasDuplicadasCacheCabecera). Borrarlas desde Appian (a!deleteRecords)
-- para que la caché sincronizada de Appian quede coherente.
SELECT "ID", "ID_SOLICITUD", "ORIGEN_CACHE", "FECHA_CACHE", "VALIDA_HASTA"
  FROM (SELECT c.*, row_number() OVER (PARTITION BY "ID_SOLICITUD" ORDER BY "ID" DESC) AS rn
          FROM sca2_datos_cabecera c) x
 WHERE rn > 1 ORDER BY "ID_SOLICITUD", "ID";

-- A8.2 Transición: clave de idempotencia (comando|idSolicitud|versión) única y no nula.
SELECT "CLAVE_IDEMPOTENCIA", count(*) FROM sca2_transicion
 GROUP BY 1 HAVING count(*) > 1 OR "CLAVE_IDEMPOTENCIA" IS NULL;
SELECT max(length("CLAVE_IDEMPOTENCIA")) AS long_max_clave,
       max(length("COMANDO")) AS long_max_comando FROM sca2_transicion;

-- A8.3 Solicitud: idSolicitud única.
SELECT "ID_SOLICITUD", count(*) FROM sca2_solicitud GROUP BY 1 HAVING count(*) > 1;

-- A8.4 Tablas de datos 1:1 por solicitud (en TEST: 15787528 duplicada en todas).
SELECT 'sca2_datos_solicitud' AS tabla, "ID_SOLICITUD", count(*) FROM sca2_datos_solicitud GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_basicos_solicitud', "ID_SOLICITUD", count(*) FROM sca2_datos_basicos_solicitud GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_perfiles_pca', "ID_SOLICITUD", count(*) FROM sca2_datos_perfiles_pca GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_productor', "ID_SOLICITUD", count(*) FROM sca2_datos_productor GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_poliza_autos', "ID_SOLICITUD", count(*) FROM sca2_datos_poliza_autos GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_poliza_hogar', "ID_SOLICITUD", count(*) FROM sca2_datos_poliza_hogar GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_poliza_vida', "ID_SOLICITUD", count(*) FROM sca2_datos_poliza_vida GROUP BY 2 HAVING count(*) > 1;

-- A8.5 Tarea: una sola tarea PENDIENTE por solicitud y tipo (en TEST: 5 casos).
SELECT "ID_SOLICITUD", "TIPO", count(*), array_agg("ID" ORDER BY "ID") AS ids,
       array_agg("FECHA_CREACION" ORDER BY "ID") AS creadas
  FROM sca2_tarea WHERE "ESTADO" = 'PENDIENTE'
 GROUP BY 1, 2 HAVING count(*) > 1 ORDER BY 1;

-- A8.6 Catálogos (claves de 56-ddl). En TEST COD_TP_ARG = '999' aparece 2 veces
--      (una activa y otra inactiva): ux_sca2_cat_tipo_argumento no puede existir hoy.
SELECT 'motivo' AS cat, concat_ws('|',"COD_LINEA_NEGOCIO","COD_PERFIL","COD_SUB_PERFIL","COD_MOTIVO") AS clave, count(*) FROM sca2_cat_motivo GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'detalle', concat_ws('|',"COD_LINEA_NEGOCIO","COD_MOTIVO","COD_DETALLE"), count(*) FROM sca2_cat_detalle GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'causa', concat_ws('|',"COD_LINEA_NEGOCIO","COD_MOTIVO","COD_DETALLE","COD_PERFIL","COD_CAUSA"), count(*) FROM sca2_cat_causa GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'tipo_argumento', "COD_TP_ARG", count(*) FROM sca2_cat_tipo_argumento GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'tipo_argumento_activo', "COD_TP_ARG", count(*) FROM sca2_cat_tipo_argumento WHERE "ACTIVO" GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'concepto', "IDN_CONCEPTO_PCA", count(*) FROM sca2_cat_concepto GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'valor_concepto', concat_ws('|',"IDN_CONCEPTO_PCA","IDN_PCA"), count(*) FROM sca2_cat_valor_concepto GROUP BY 2 HAVING count(*) > 1;

-- A9. Huérfanos (ID_SOLICITUD sin fila en sca2_solicitud) antes de cualquier FK.
--     En TEST: 0 en tarea/transición/llamada; 2 en datos_*; 13 en cabecera; 2 en error (diseño: PDTE-/sin solicitud).
SELECT 'sca2_tarea' AS tabla, count(*) FROM sca2_tarea h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_transicion', count(*) FROM sca2_transicion h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_llamada_servicio', count(*) FROM sca2_llamada_servicio h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_error', count(*) FROM sca2_error h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_datos_solicitud', count(*) FROM sca2_datos_solicitud h WHERE NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_niveles_cobertura_autos', count(*) FROM sca2_niveles_cobertura_autos h WHERE NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_otras_solicitudes_cabecera', count(*) FROM sca2_otras_solicitudes_cabecera h WHERE NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_datos_cabecera', count(*) FROM sca2_datos_cabecera h WHERE NOT EXISTS (SELECT 1 FROM sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD");

-- A10. Nulos en columnas candidatas a NOT NULL (debe ser 0 en todas).
SELECT 'sca2_solicitud.ID_SOLICITUD' AS columna, count(*) FROM sca2_solicitud WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_solicitud.NUM_POLIZA', count(*) FROM sca2_solicitud WHERE "NUM_POLIZA" IS NULL
UNION ALL SELECT 'sca2_solicitud.CREATED_AT', count(*) FROM sca2_solicitud WHERE "CREATED_AT" IS NULL
UNION ALL SELECT 'sca2_transicion.ID_SOLICITUD', count(*) FROM sca2_transicion WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_transicion.CLAVE_IDEMPOTENCIA', count(*) FROM sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" IS NULL
UNION ALL SELECT 'sca2_tarea.ID_SOLICITUD', count(*) FROM sca2_tarea WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_tarea.ESTADO', count(*) FROM sca2_tarea WHERE "ESTADO" IS NULL
UNION ALL SELECT 'sca2_llamada_servicio.ID_SOLICITUD', count(*) FROM sca2_llamada_servicio WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_datos_cabecera.ID_SOLICITUD', count(*) FROM sca2_datos_cabecera WHERE "ID_SOLICITUD" IS NULL;

-- A11. Longitudes: valores cerca del máximo físico (riesgo de error al escribir).
SELECT 'cabecera.POLIZA_FECHAULTIMOSINIESTRO' AS columna, max(length("POLIZA_FECHAULTIMOSINIESTRO")) FROM sca2_datos_cabecera
UNION ALL SELECT 'datos_solicitud.FECIMPRESION', max(length("FECIMPRESION")) FROM sca2_datos_solicitud
UNION ALL SELECT 'error.COMANDO', max(length("COMANDO")) FROM sca2_error
UNION ALL SELECT 'tarea.TIPO', max(length("TIPO")) FROM sca2_tarea
UNION ALL SELECT 'tarea.ESTADO', max(length("ESTADO")) FROM sca2_tarea;

-- A12. Selectividad de las columnas de filtro (para decidir índices).
SELECT "ESTADO_SOLICITUD", count(*) FROM sca2_solicitud GROUP BY 1 ORDER BY 2 DESC;
SELECT "TIPO", "ESTADO", count(*) FROM sca2_tarea GROUP BY 1, 2 ORDER BY 3 DESC;
SELECT "ESTADO", count(*) FROM sca2_error GROUP BY 1 ORDER BY 2 DESC;
SELECT count(*) FILTER (WHERE "ID_SOLICITUD" LIKE 'PDTE-%') AS pdte, count(*) AS total FROM sca2_solicitud;

-- A13. Línea base de planes (antes de B). Repetir en D3 y comparar.
--      EXPLAIN ANALYZE ejecuta el SELECT (solo lectura); sustituir los literales por casos reales.
EXPLAIN (ANALYZE, BUFFERS) SELECT "ID" FROM sca2_solicitud
 WHERE "ID_SOLICITUD" NOT LIKE 'PDTE-%' ORDER BY "CREATED_AT" DESC LIMIT 10;                 -- buscador sin filtros
EXPLAIN (ANALYZE, BUFFERS) SELECT "ID" FROM sca2_solicitud
 WHERE "NUM_POLIZA" = '2002000024445' ORDER BY "CREATED_AT" DESC LIMIT 10;                  -- solicitud en curso por póliza
EXPLAIN (ANALYZE, BUFFERS) SELECT "ID","ID_SOLICITUD","NUM_POLIZA","FECHA_CREACION" FROM sca2_tarea
 WHERE "TIPO" = 'INDUCCION' AND "ESTADO" = 'PENDIENTE' AND "FECHA_CREACION" < now() - interval '1 hour'
 ORDER BY "FECHA_CREACION" LIMIT 100;                                                       -- aviso cuadro de mando
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM sca2_transicion
 WHERE "FECHA" BETWEEN now() - interval '90 days' AND now();                                -- cuadro de mando
EXPLAIN (ANALYZE, BUFFERS) SELECT "ID" FROM sca2_error
 WHERE "ESTADO" = 'PENDIENTE' ORDER BY "FECHA_CREACION" DESC LIMIT 50;                      -- bandeja de errores
EXPLAIN (ANALYZE, BUFFERS) SELECT "ID" FROM sca2_datos_cabecera
 WHERE "ID_SOLICITUD" = '15788876' AND "VALIDA_HASTA" IS NOT NULL AND "VALIDA_HASTA" > now()
 ORDER BY "FECHA_CACHE" DESC LIMIT 1;                                                       -- caché de cabecera


-- =============================================================================
-- B. ÍNDICES (CREATE INDEX CONCURRENTLY: sin bloquear escrituras; fuera de transacción)
--    Si un CONCURRENTLY falla deja el índice INVALID: comprobar con A4/D2 y
--    borrarlo con su rollback antes de reintentar.
-- =============================================================================

-- B0. Índices por ID_SOLICITUD del DDL 56 (mismos nombres). Solo crean lo que falte
--     en TEST si A3 demuestra que no existen. Sirven a todas las consultas
--     "idSolicitud =" de detalle, procesos CMD y caché.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_cabecera_id_solicitud      ON sca2_anulaciones.sca2_datos_cabecera ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_solicitud_id_solicitud     ON sca2_anulaciones.sca2_datos_solicitud ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_basicos_solicitud_id_solicitud ON sca2_anulaciones.sca2_datos_basicos_solicitud ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_perfiles_pca_id_solicitud  ON sca2_anulaciones.sca2_datos_perfiles_pca ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_productor_id_solicitud     ON sca2_anulaciones.sca2_datos_productor ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_poliza_autos_id_solicitud  ON sca2_anulaciones.sca2_datos_poliza_autos ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_poliza_hogar_id_solicitud  ON sca2_anulaciones.sca2_datos_poliza_hogar ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_poliza_vida_id_solicitud   ON sca2_anulaciones.sca2_datos_poliza_vida ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_niveles_cobertura_autos_id_solicitud ON sca2_anulaciones.sca2_niveles_cobertura_autos ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_otras_solicitudes_cabecera_id_solicitud ON sca2_anulaciones.sca2_otras_solicitudes_cabecera ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_tarea_id_solicitud               ON sca2_anulaciones.sca2_tarea ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_transicion_id_solicitud          ON sca2_anulaciones.sca2_transicion ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_error_id_solicitud               ON sca2_anulaciones.sca2_error ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_llamada_servicio_id_solicitud    ON sca2_anulaciones.sca2_llamada_servicio ("ID_SOLICITUD");
-- Rollback B0: no aplicar (son los índices del DDL 56 de producción).

-- B1. [ALTA] Solicitud por fecha de alta: buscador (orden createdAt DESC, 10 filas,
--     con "not starts with PDTE-") y cuadro de mando (createdAt BETWEEN últimos 90 días).
--     Evita leer y ordenar toda la tabla en cada apertura del buscador.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_solicitud_created_at
    ON sca2_anulaciones.sca2_solicitud ("CREATED_AT" DESC);
-- Rollback B1: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_created_at;

-- B2. [MEDIA] Solicitud por póliza + fecha: alta/contraanulación ("numPoliza =" con
--     orden createdAt DESC), buscador por póliza y batch NSE ("numPoliza in").
--     Cubre lo mismo que ix_sca2_solicitud_num_poliza (56); ese podrá borrarse
--     cuando D2 muestre que este se usa (no se borra en este script).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_solicitud_num_poliza_created_at
    ON sca2_anulaciones.sca2_solicitud ("NUM_POLIZA", "CREATED_AT" DESC);
-- Rollback B2: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_num_poliza_created_at;

-- B3. [BAJA] Barrido de caducidad (SCA2 CMD BarridoCaducidad: caducidadTarea < now()
--     y estado no final). Parcial: solo filas con caducidad informada.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_solicitud_caducidad_tarea
    ON sca2_anulaciones.sca2_solicitud ("CADUCIDAD_TAREA") WHERE "CADUCIDAD_TAREA" IS NOT NULL;
-- Rollback B3: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_caducidad_tarea;

-- B4. [MEDIA] Aviso del cuadro de mando: TIPO = 'INDUCCION', ESTADO = 'PENDIENTE',
--     FECHA_CREACION < now() - 1 h, orden FECHA_CREACION ASC. Índice parcial pequeño
--     (solo pendientes): crece con las tareas vivas, no con el histórico.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_tarea_pendiente_tipo_fecha
    ON sca2_anulaciones.sca2_tarea ("TIPO", "FECHA_CREACION") WHERE "ESTADO" = 'PENDIENTE';
-- Rollback B4: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_tarea_pendiente_tipo_fecha;

-- B5. [MEDIA] Tareas por fecha de creación (cuadro de mando, BETWEEN 90 días).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_tarea_fecha_creacion
    ON sca2_anulaciones.sca2_tarea ("FECHA_CREACION");
-- Rollback B5: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_tarea_fecha_creacion;

-- B6. [MEDIA] Transiciones por fecha (cuadro de mando: BETWEEN 90 días, duracionMs).
--     Es la tabla que más crece (≈6,5 filas por solicitud en TEST).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_transicion_fecha
    ON sca2_anulaciones.sca2_transicion ("FECHA");
-- Rollback B6: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_transicion_fecha;

-- B7. [MEDIA] Bandeja de errores: ESTADO = x ORDER BY FECHA_CREACION DESC (paginada).
--     Hace redundante ix_sca2_error_estado (56); no se borra aquí.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_error_estado_fecha_creacion
    ON sca2_anulaciones.sca2_error ("ESTADO", "FECHA_CREACION" DESC);
-- Rollback B7: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_error_estado_fecha_creacion;

-- B8. [BAJA] Errores, llamadas y trazabilidad por fecha (cuadro de mando, 90 días).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_error_fecha_creacion
    ON sca2_anulaciones.sca2_error ("FECHA_CREACION");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_llamada_servicio_fecha_inicio
    ON sca2_anulaciones.sca2_llamada_servicio ("FECHA_INICIO");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_trazabilidad_cliente_fecha
    ON sca2_anulaciones.sca2_trazabilidad_cliente ("FECHA");
-- Rollback B8:
--   DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_error_fecha_creacion;
--   DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_llamada_servicio_fecha_inicio;
--   DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_trazabilidad_cliente_fecha;

-- B9. Estadísticas actualizadas para que el planificador use los índices nuevos
--     (ANALYZE no modifica datos). Rollback: no aplica.
ANALYZE sca2_anulaciones.sca2_solicitud;
ANALYZE sca2_anulaciones.sca2_tarea;
ANALYZE sca2_anulaciones.sca2_transicion;
ANALYZE sca2_anulaciones.sca2_error;
ANALYZE sca2_anulaciones.sca2_llamada_servicio;
ANALYZE sca2_anulaciones.sca2_trazabilidad_cliente;
ANALYZE sca2_anulaciones.sca2_datos_cabecera;


-- =============================================================================
-- C. RESTRICCIONES (cada una comprueba antes los datos; si fallaría, WARNING y no se crea)
--    Toman un bloqueo breve de la tabla (ACCESS EXCLUSIVE para SET NOT NULL,
--    SHARE para CREATE UNIQUE INDEX no concurrente). Tablas de cientos/miles de
--    filas en TEST: milisegundos. Lanzar fuera de horas de carga en PRO.
-- =============================================================================

-- C1. [ALTA] Caché de cabecera: una fila por ID_SOLICITUD (R38 detectó duplicados;
--     siguen 4 en TEST). Requisitos previos: (1) borrar sobrantes de A8.1 desde Appian,
--     (2) que el refresco reutilice el ID de la fila existente (ver informe §5.1),
--     porque con el índice un segundo INSERT concurrente fallará con unique_violation.
-- DESACTIVADO: no ejecutar hasta que el refresco de la caché de cabecera en Appian
-- reutilice la fila existente (informe §5.3.1). Si se crea antes, un refresco concurrente
-- fallará con unique_violation. Para activarlo, quitar los «-- » del bloque.
-- DO $$
-- BEGIN
--   IF to_regclass('sca2_anulaciones.ux_sca2_datos_cabecera_id_solicitud') IS NOT NULL THEN
--     RAISE NOTICE 'C1: ux_sca2_datos_cabecera_id_solicitud ya existe';
--   ELSIF EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_datos_cabecera
--                  GROUP BY "ID_SOLICITUD" HAVING count(*) > 1) THEN
--     RAISE WARNING 'C1: hay ID_SOLICITUD duplicados en sca2_datos_cabecera (ver A8.1); no se crea el UNIQUE';
--   ELSE
--     CREATE UNIQUE INDEX ux_sca2_datos_cabecera_id_solicitud
--         ON sca2_anulaciones.sca2_datos_cabecera ("ID_SOLICITUD");
--     RAISE NOTICE 'C1: creado ux_sca2_datos_cabecera_id_solicitud';
--   END IF;
-- END $$;
-- Rollback C1: DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_datos_cabecera_id_solicitud;

-- C2. [ALTA] Transición: CLAVE_IDEMPOTENCIA (comando|idSolicitud|versión) única y
--     NOT NULL. El UNIQUE ya existe en TEST (el MCP lo informa); un UNIQUE admite
--     varios NULL, por eso se añade NOT NULL. 0 nulos en TEST.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_index ix JOIN pg_attribute a ON a.attrelid = ix.indrelid AND a.attnum = ix.indkey[0]
                  WHERE ix.indrelid = 'sca2_anulaciones.sca2_transicion'::regclass
                    AND ix.indisunique AND ix.indnatts = 1 AND a.attname = 'CLAVE_IDEMPOTENCIA') THEN
    IF EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" IS NOT NULL
                GROUP BY "CLAVE_IDEMPOTENCIA" HAVING count(*) > 1) THEN
      RAISE WARNING 'C2: CLAVE_IDEMPOTENCIA duplicada (ver A8.2); no se crea el UNIQUE';
    ELSE
      ALTER TABLE sca2_anulaciones.sca2_transicion
        ADD CONSTRAINT sca2_transicion_clave_idempotencia_key UNIQUE ("CLAVE_IDEMPOTENCIA");
      RAISE NOTICE 'C2: UNIQUE CLAVE_IDEMPOTENCIA creado';
    END IF;
  END IF;
  IF EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" IS NULL) THEN
    RAISE WARNING 'C2: hay CLAVE_IDEMPOTENCIA nulas; no se aplica NOT NULL';
  ELSE
    ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" SET NOT NULL;
  END IF;
END $$;
-- Rollback C2: ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" DROP NOT NULL;
--              (el UNIQUE es del DDL 56: no quitarlo)

-- C3. [MEDIA] NOT NULL en las claves de negocio que todos los procesos informan
--     (ID_SOLICITUD lleva "PDTE-<proceso>" mientras no hay id de CORE).
--     NO se aplica a sca2_error.ID_SOLICITUD (hay errores sin solicitud por diseño)
--     ni a ESTADO_SOLICITUD (el alta consulta "estadoSolicitud is null").
DO $$
DECLARE r record; hay_nulos boolean;
BEGIN
  FOR r IN SELECT * FROM (VALUES ('sca2_solicitud','ID_SOLICITUD'), ('sca2_solicitud','NUM_POLIZA'),
                                 ('sca2_solicitud','CREATED_AT'), ('sca2_transicion','ID_SOLICITUD'),
                                 ('sca2_tarea','ID_SOLICITUD'), ('sca2_tarea','ESTADO'),
                                 ('sca2_llamada_servicio','ID_SOLICITUD'),
                                 ('sca2_datos_cabecera','ID_SOLICITUD')) v(tabla, columna)
  LOOP
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'sca2_anulaciones' AND table_name = r.tabla
                  AND column_name = r.columna AND is_nullable = 'NO') THEN
      CONTINUE;
    END IF;
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM sca2_anulaciones.%I WHERE %I IS NULL)', r.tabla, r.columna)
       INTO hay_nulos;
    IF hay_nulos THEN
      RAISE WARNING 'C3: %.% tiene nulos (ver A10); no se aplica NOT NULL', r.tabla, r.columna;
    ELSE
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I SET NOT NULL', r.tabla, r.columna);
      RAISE NOTICE 'C3: NOT NULL en %.%', r.tabla, r.columna;
    END IF;
  END LOOP;
END $$;
-- Rollback C3 (por columna):
--   ALTER TABLE sca2_anulaciones.sca2_solicitud        ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_solicitud        ALTER COLUMN "NUM_POLIZA"   DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_solicitud        ALTER COLUMN "CREATED_AT"   DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_transicion       ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_tarea            ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_tarea            ALTER COLUMN "ESTADO"       DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_llamada_servicio ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_datos_cabecera   ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;

-- C4. [MEDIA] Catálogos: UNIQUE de 56-ddl que falten. ux_sca2_cat_tipo_argumento
--     (COD_TP_ARG) no es viable: hay un código repetido activo/inactivo (999). Se
--     sustituye por un UNIQUE parcial solo sobre filas activas (baja lógica).
DO $$
DECLARE r record; hay_dup boolean;
BEGIN
  FOR r IN SELECT * FROM (VALUES
      ('ux_sca2_cat_motivo',  'sca2_cat_motivo',  '"COD_LINEA_NEGOCIO", "COD_PERFIL", "COD_SUB_PERFIL", "COD_MOTIVO"', ''),
      ('ux_sca2_cat_detalle', 'sca2_cat_detalle', '"COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE"', ''),
      ('ux_sca2_cat_causa',   'sca2_cat_causa',   '"COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE", "COD_PERFIL", "COD_CAUSA"', ''),
      ('ux_sca2_cat_tipo_argumento_activo', 'sca2_cat_tipo_argumento', '"COD_TP_ARG"', ' WHERE "ACTIVO"'),
      ('ux_sca2_cat_concepto', 'sca2_cat_concepto', '"IDN_CONCEPTO_PCA"', ''),
      ('ux_sca2_cat_valor_concepto', 'sca2_cat_valor_concepto', '"IDN_CONCEPTO_PCA", "IDN_PCA"', '')
    ) v(indice, tabla, columnas, filtro)
  LOOP
    IF to_regclass('sca2_anulaciones.' || r.indice) IS NOT NULL THEN
      RAISE NOTICE 'C4: % ya existe', r.indice;
      CONTINUE;
    END IF;
    IF r.indice = 'ux_sca2_cat_tipo_argumento_activo'
       AND to_regclass('sca2_anulaciones.ux_sca2_cat_tipo_argumento') IS NOT NULL THEN
      RAISE NOTICE 'C4: ux_sca2_cat_tipo_argumento (completo) ya existe; no hace falta el parcial';
      CONTINUE;
    END IF;
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM sca2_anulaciones.%I%s GROUP BY %s HAVING count(*) > 1)',
                   r.tabla, r.filtro, r.columnas) INTO hay_dup;
    IF hay_dup THEN
      RAISE WARNING 'C4: duplicados en % (ver A8.6); no se crea %', r.tabla, r.indice;
    ELSE
      EXECUTE format('CREATE UNIQUE INDEX %I ON sca2_anulaciones.%I (%s)%s', r.indice, r.tabla, r.columnas, r.filtro);
      RAISE NOTICE 'C4: creado %', r.indice;
    END IF;
  END LOOP;
END $$;
-- Rollback C4 (solo los creados por este script; ver NOTICE):
--   DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_cat_tipo_argumento_activo;
--   (ux_sca2_cat_motivo/detalle/causa/concepto/valor_concepto son del DDL 56: no quitarlos)

-- C5. [MEDIA] Longitud: POLIZA_FECHAULTIMOSINIESTRO a VARCHAR(1000) (R46-D, 63-r46d-*.sql
--     sigue pendiente: en TEST la columna es VARCHAR(255) y ya hay valores de 241).
--     Ampliar un VARCHAR en PostgreSQL no reescribe la tabla (bloqueo de milisegundos).
DO $$
BEGIN
  IF (SELECT character_maximum_length FROM information_schema.columns
       WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_cabecera'
         AND column_name = 'POLIZA_FECHAULTIMOSINIESTRO') < 1000 THEN
    ALTER TABLE sca2_anulaciones.sca2_datos_cabecera
      ALTER COLUMN "POLIZA_FECHAULTIMOSINIESTRO" TYPE VARCHAR(1000);
    RAISE NOTICE 'C5: POLIZA_FECHAULTIMOSINIESTRO ampliada a 1000';
  END IF;
END $$;
-- Rollback C5 (solo si ningún valor supera 255):
--   ALTER TABLE sca2_anulaciones.sca2_datos_cabecera ALTER COLUMN "POLIZA_FECHAULTIMOSINIESTRO" TYPE VARCHAR(255);

-- C6. [BAJA] Longitud: CLAVE_IDEMPOTENCIA = COMANDO(60) | ID_SOLICITUD(50) | versión
--     puede superar 120 en teoría (hoy máx. 53). Se amplía a 200 (sin reescritura).
DO $$
BEGIN
  IF (SELECT character_maximum_length FROM information_schema.columns
       WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_transicion'
         AND column_name = 'CLAVE_IDEMPOTENCIA') < 200 THEN
    ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" TYPE VARCHAR(200);
    RAISE NOTICE 'C6: CLAVE_IDEMPOTENCIA ampliada a 200';
  END IF;
END $$;
-- Rollback C6: ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" TYPE VARCHAR(120);

-- C7. [PENDIENTE DE DECISIÓN — NO SE EJECUTA] Una sola tarea PENDIENTE por solicitud
--     y tipo. Hoy hay 5 casos (A8.5), uno creado 3 s después del anterior (carrera
--     real). Activar solo cuando: (1) el analista decida qué hacer con los duplicados,
--     (2) SCA2 CMD CrearAccion trate el error de unicidad como "ya existe".
--   CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS ux_sca2_tarea_pendiente_solicitud_tipo
--       ON sca2_anulaciones.sca2_tarea ("ID_SOLICITUD", "TIPO") WHERE "ESTADO" = 'PENDIENTE';
-- Rollback C7: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ux_sca2_tarea_pendiente_solicitud_tipo;

-- C8. [BAJA / OPCIONAL — NO SE EJECUTA] Claves ajenas a sca2_solicitud("ID_SOLICITUD")
--     para tarea, transición y llamada (0 huérfanos en TEST). NOT VALID: no revisa
--     las filas existentes ni bloquea la tabla; VALIDATE después. Antes de activarlas
--     comprobar en TEST que ningún proceso cambia ID_SOLICITUD de "PDTE-*" al id de
--     CORE con hijos ya escritos (la FK lo rechazaría). No se proponen para sca2_error
--     (sin solicitud por diseño), datos_* ni cabecera (huérfanos de pruebas).
--   ALTER TABLE sca2_anulaciones.sca2_tarea ADD CONSTRAINT fk_sca2_tarea_sca2_solicitud
--     FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_anulaciones.sca2_solicitud ("ID_SOLICITUD") NOT VALID;
--   ALTER TABLE sca2_anulaciones.sca2_transicion ADD CONSTRAINT fk_sca2_transicion_sca2_solicitud
--     FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_anulaciones.sca2_solicitud ("ID_SOLICITUD") NOT VALID;
--   ALTER TABLE sca2_anulaciones.sca2_llamada_servicio ADD CONSTRAINT fk_sca2_llamada_servicio_sca2_solicitud
--     FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_anulaciones.sca2_solicitud ("ID_SOLICITUD") NOT VALID;
--   ALTER TABLE sca2_anulaciones.sca2_tarea            VALIDATE CONSTRAINT fk_sca2_tarea_sca2_solicitud;
--   ALTER TABLE sca2_anulaciones.sca2_transicion       VALIDATE CONSTRAINT fk_sca2_transicion_sca2_solicitud;
--   ALTER TABLE sca2_anulaciones.sca2_llamada_servicio VALIDATE CONSTRAINT fk_sca2_llamada_servicio_sca2_solicitud;
-- Rollback C8:
--   ALTER TABLE sca2_anulaciones.sca2_tarea            DROP CONSTRAINT IF EXISTS fk_sca2_tarea_sca2_solicitud;
--   ALTER TABLE sca2_anulaciones.sca2_transicion       DROP CONSTRAINT IF EXISTS fk_sca2_transicion_sca2_solicitud;
--   ALTER TABLE sca2_anulaciones.sca2_llamada_servicio DROP CONSTRAINT IF EXISTS fk_sca2_llamada_servicio_sca2_solicitud;


-- =============================================================================
-- D. VERIFICACIÓN (solo lectura)
-- =============================================================================

-- D1. Índices y restricciones resultantes (comparar con A3/A5).
SELECT tablename, indexname, indexdef FROM pg_indexes
 WHERE schemaname = 'sca2_anulaciones' AND tablename LIKE 'sca2\_%' ORDER BY 1, 2;
SELECT conrelid::regclass AS tabla, conname, contype, convalidated, pg_get_constraintdef(oid)
  FROM pg_constraint WHERE connamespace = 'sca2_anulaciones'::regnamespace
   AND conrelid::regclass::text LIKE 'sca2\_%' ORDER BY 1, 2;

-- D2. Ningún índice INVALID (CONCURRENTLY fallido). Debe devolver 0 filas.
SELECT i.relname AS indice_invalido FROM pg_index ix JOIN pg_class i ON i.oid = ix.indexrelid
  JOIN pg_namespace n ON n.oid = i.relnamespace
 WHERE n.nspname = 'sca2_anulaciones' AND NOT ix.indisvalid;

-- D3. Repetir los EXPLAIN (ANALYZE, BUFFERS) de A13 y comparar: se espera
--     "Index Scan"/"Index Only Scan"/"Bitmap Index Scan" con los índices nuevos y
--     menos "Buffers: shared hit/read". Con pocas filas PostgreSQL puede seguir
--     eligiendo "Seq Scan" (es lo correcto en tablas pequeñas).

-- D4. Uso real de los índices nuevos tras unos días de actividad (idx_scan > 0).
SELECT relname AS tabla, indexrelname AS indice, idx_scan, idx_tup_read
  FROM pg_stat_user_indexes
 WHERE schemaname = 'sca2_anulaciones' AND indexrelname IN (
       'ix_sca2_solicitud_created_at','ix_sca2_solicitud_num_poliza_created_at',
       'ix_sca2_solicitud_caducidad_tarea','ix_sca2_tarea_pendiente_tipo_fecha',
       'ix_sca2_tarea_fecha_creacion','ix_sca2_transicion_fecha',
       'ix_sca2_error_estado_fecha_creacion','ix_sca2_error_fecha_creacion',
       'ix_sca2_llamada_servicio_fecha_inicio','ix_sca2_trazabilidad_cliente_fecha',
       'ux_sca2_datos_cabecera_id_solicitud','ux_sca2_cat_tipo_argumento_activo')
 ORDER BY 1, 2;


-- =============================================================================
-- R. ROLLBACK GLOBAL de lo que crea este script (no toca nada del DDL 56).
--    Ejecutar en autocommit. Comentado para que no se lance por error.
-- =============================================================================
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_created_at;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_num_poliza_created_at;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_caducidad_tarea;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_tarea_pendiente_tipo_fecha;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_tarea_fecha_creacion;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_transicion_fecha;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_error_estado_fecha_creacion;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_error_fecha_creacion;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_llamada_servicio_fecha_inicio;
-- DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_trazabilidad_cliente_fecha;
-- DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_datos_cabecera_id_solicitud;
-- DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_cat_tipo_argumento_activo;
-- ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" DROP NOT NULL;
-- (NOT NULL de C3 y longitudes de C5/C6: ver el rollback de cada bloque)
