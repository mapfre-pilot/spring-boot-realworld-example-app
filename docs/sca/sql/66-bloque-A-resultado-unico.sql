-- =============================================================================
-- 66-bloque-A-resultado-unico.sql — Bloque A de 66-indices-sca2.sql en UNA consulta
-- =============================================================================
-- Solo lectura (SELECT y EXPLAIN ANALYZE de SELECT). No crea ni modifica nada.
-- Devuelve una sola fila y una sola columna («resultado») con un JSON que contiene
-- la salida de cada comprobación (A1 … A12), para poder guardarla de una vez.
-- A13 (EXPLAIN ANALYZE) no cabe en una consulta: PostgreSQL no permite EXPLAIN
-- dentro de otra consulta. Es opcional; se lanza aparte si se quiere la línea base.
--
-- DBeaver (conexión a la BD de TEST, nunca PRO):
--   1. Abrir este fichero en un editor SQL de la conexión de TEST.
--   2. Botón derecho dentro del editor > Ejecutar > Exportar desde consulta
--      (Execute > Export From Query) > formato TXT o JSON > carpeta y nombre >
--      Iniciar. Guarda el resultado completo en un fichero sin recortes.
--   Alternativa: Ctrl+Enter, clic en la celda «resultado» > botón derecho >
--      Copiar avanzado > Copiar valor (o Ver/Editar valor y guardar a fichero).
-- Mandar el fichero a Devin.
-- =============================================================================
SELECT json_build_object(
  'A1#1', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT version()
) t),
  'A1#2', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT current_database(), current_user, datcollate, datctype
  FROM pg_database WHERE datname = current_database()
) t),
  'A2', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
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
 ORDER BY c.relname
) t),
  'A3', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT tablename, indexname, indexdef
  FROM pg_indexes
 WHERE schemaname = 'sca2_anulaciones' AND tablename LIKE 'sca2\_%'
 ORDER BY tablename, indexname
) t),
  'A4', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT t.relname AS tabla, i.relname AS indice, ix.indisunique AS es_unico,
       ix.indisvalid AS es_valido, st.idx_scan, st.idx_tup_read,
       pg_size_pretty(pg_relation_size(i.oid)) AS tamano
  FROM pg_index ix
  JOIN pg_class i ON i.oid = ix.indexrelid
  JOIN pg_class t ON t.oid = ix.indrelid
  JOIN pg_namespace n ON n.oid = t.relnamespace
  LEFT JOIN pg_stat_user_indexes st ON st.indexrelid = ix.indexrelid
 WHERE n.nspname = 'sca2_anulaciones' AND t.relname LIKE 'sca2\_%'
 ORDER BY t.relname, i.relname
) t),
  'A5', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT conrelid::regclass AS tabla, conname, contype, convalidated,
       pg_get_constraintdef(oid) AS definicion
  FROM pg_constraint
 WHERE connamespace = 'sca2_anulaciones'::regnamespace
   AND conrelid::regclass::text LIKE 'sca2\_%'
 ORDER BY 1, 2
) t),
  'A6', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT table_name, column_name, data_type, character_maximum_length, is_nullable, column_default
  FROM information_schema.columns
 WHERE table_schema = 'sca2_anulaciones' AND table_name LIKE 'sca2\_%'
   AND column_name IN ('ID','ID_SOLICITUD','NUM_POLIZA','ESTADO','ESTADO_SOLICITUD','TIPO',
                       'CLAVE_IDEMPOTENCIA','COMANDO','CODIGO','FECHA','FECHA_CREACION',
                       'FECHA_INICIO','CREATED_AT','CADUCIDAD_TAREA','VALIDA_HASTA',
                       'FECHA_CACHE','ORIGEN_CACHE','POLIZA_FECHAULTIMOSINIESTRO','ACTIVO',
                       'COD_TP_ARG')
 ORDER BY table_name, column_name
) t),
  'A7', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT DISTINCT v.relname AS vista, t.relname AS tabla
  FROM pg_depend d
  JOIN pg_rewrite r ON r.oid = d.objid
  JOIN pg_class v ON v.oid = r.ev_class
  JOIN pg_class t ON t.oid = d.refobjid
  JOIN pg_namespace n ON n.oid = t.relnamespace
 WHERE n.nspname = 'sca2_anulaciones' AND t.relname LIKE 'sca2\_%' AND v.oid <> t.oid
) t),
  'A8#1', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "ID_SOLICITUD", count(*) AS filas, array_agg("ID" ORDER BY "ID") AS ids,
       array_agg("ORIGEN_CACHE" ORDER BY "ID") AS origenes
  FROM sca2_anulaciones.sca2_datos_cabecera
 GROUP BY "ID_SOLICITUD" HAVING count(*) > 1 ORDER BY 1
) t),
  'A8#2', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "ID", "ID_SOLICITUD", "ORIGEN_CACHE", "FECHA_CACHE", "VALIDA_HASTA"
  FROM (SELECT c.*, row_number() OVER (PARTITION BY "ID_SOLICITUD" ORDER BY "ID" DESC) AS rn
          FROM sca2_anulaciones.sca2_datos_cabecera c) x
 WHERE rn > 1 ORDER BY "ID_SOLICITUD", "ID"
) t),
  'A8#3', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "CLAVE_IDEMPOTENCIA", count(*) FROM sca2_anulaciones.sca2_transicion
 GROUP BY 1 HAVING count(*) > 1 OR "CLAVE_IDEMPOTENCIA" IS NULL
) t),
  'A8#4', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT max(length("CLAVE_IDEMPOTENCIA")) AS long_max_clave,
       max(length("COMANDO")) AS long_max_comando FROM sca2_anulaciones.sca2_transicion
) t),
  'A8#5', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_solicitud GROUP BY 1 HAVING count(*) > 1
) t),
  'A8#6', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT 'sca2_datos_solicitud' AS tabla, "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_solicitud GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_basicos_solicitud', "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_basicos_solicitud GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_perfiles_pca', "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_perfiles_pca GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_productor', "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_productor GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_poliza_autos', "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_poliza_autos GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_poliza_hogar', "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_poliza_hogar GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'sca2_datos_poliza_vida', "ID_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_datos_poliza_vida GROUP BY 2 HAVING count(*) > 1
) t),
  'A8#7', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "ID_SOLICITUD", "TIPO", count(*), array_agg("ID" ORDER BY "ID") AS ids,
       array_agg("FECHA_CREACION" ORDER BY "ID") AS creadas
  FROM sca2_anulaciones.sca2_tarea WHERE "ESTADO" = 'PENDIENTE'
 GROUP BY 1, 2 HAVING count(*) > 1 ORDER BY 1
) t),
  'A8#8', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT 'motivo' AS cat, concat_ws('|',"COD_LINEA_NEGOCIO","COD_PERFIL","COD_SUB_PERFIL","COD_MOTIVO") AS clave, count(*) FROM sca2_anulaciones.sca2_cat_motivo GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'detalle', concat_ws('|',"COD_LINEA_NEGOCIO","COD_MOTIVO","COD_DETALLE"), count(*) FROM sca2_anulaciones.sca2_cat_detalle GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'causa', concat_ws('|',"COD_LINEA_NEGOCIO","COD_MOTIVO","COD_DETALLE","COD_PERFIL","COD_CAUSA"), count(*) FROM sca2_anulaciones.sca2_cat_causa GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'tipo_argumento', "COD_TP_ARG", count(*) FROM sca2_anulaciones.sca2_cat_tipo_argumento GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'tipo_argumento_activo', "COD_TP_ARG", count(*) FROM sca2_anulaciones.sca2_cat_tipo_argumento WHERE "ACTIVO" GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'concepto', "IDN_CONCEPTO_PCA", count(*) FROM sca2_anulaciones.sca2_cat_concepto GROUP BY 2 HAVING count(*) > 1
UNION ALL SELECT 'valor_concepto', concat_ws('|',"IDN_CONCEPTO_PCA","IDN_PCA"), count(*) FROM sca2_anulaciones.sca2_cat_valor_concepto GROUP BY 2 HAVING count(*) > 1
) t),
  'A9', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT 'sca2_tarea' AS tabla, count(*) FROM sca2_anulaciones.sca2_tarea h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_transicion', count(*) FROM sca2_anulaciones.sca2_transicion h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_llamada_servicio', count(*) FROM sca2_anulaciones.sca2_llamada_servicio h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_error', count(*) FROM sca2_anulaciones.sca2_error h WHERE h."ID_SOLICITUD" IS NOT NULL AND NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_datos_solicitud', count(*) FROM sca2_anulaciones.sca2_datos_solicitud h WHERE NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_niveles_cobertura_autos', count(*) FROM sca2_anulaciones.sca2_niveles_cobertura_autos h WHERE NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_otras_solicitudes_cabecera', count(*) FROM sca2_anulaciones.sca2_otras_solicitudes_cabecera h WHERE NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
UNION ALL SELECT 'sca2_datos_cabecera', count(*) FROM sca2_anulaciones.sca2_datos_cabecera h WHERE NOT EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_solicitud s WHERE s."ID_SOLICITUD" = h."ID_SOLICITUD")
) t),
  'A10', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT 'sca2_solicitud.ID_SOLICITUD' AS columna, count(*) FROM sca2_anulaciones.sca2_solicitud WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_solicitud.NUM_POLIZA', count(*) FROM sca2_anulaciones.sca2_solicitud WHERE "NUM_POLIZA" IS NULL
UNION ALL SELECT 'sca2_solicitud.CREATED_AT', count(*) FROM sca2_anulaciones.sca2_solicitud WHERE "CREATED_AT" IS NULL
UNION ALL SELECT 'sca2_transicion.ID_SOLICITUD', count(*) FROM sca2_anulaciones.sca2_transicion WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_transicion.CLAVE_IDEMPOTENCIA', count(*) FROM sca2_anulaciones.sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" IS NULL
UNION ALL SELECT 'sca2_tarea.ID_SOLICITUD', count(*) FROM sca2_anulaciones.sca2_tarea WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_tarea.ESTADO', count(*) FROM sca2_anulaciones.sca2_tarea WHERE "ESTADO" IS NULL
UNION ALL SELECT 'sca2_llamada_servicio.ID_SOLICITUD', count(*) FROM sca2_anulaciones.sca2_llamada_servicio WHERE "ID_SOLICITUD" IS NULL
UNION ALL SELECT 'sca2_datos_cabecera.ID_SOLICITUD', count(*) FROM sca2_anulaciones.sca2_datos_cabecera WHERE "ID_SOLICITUD" IS NULL
) t),
  'A11', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT 'cabecera.POLIZA_FECHAULTIMOSINIESTRO' AS columna, max(length("POLIZA_FECHAULTIMOSINIESTRO")) FROM sca2_anulaciones.sca2_datos_cabecera
UNION ALL SELECT 'datos_solicitud.FECIMPRESION', max(length("FECIMPRESION")) FROM sca2_anulaciones.sca2_datos_solicitud
UNION ALL SELECT 'error.COMANDO', max(length("COMANDO")) FROM sca2_anulaciones.sca2_error
UNION ALL SELECT 'tarea.TIPO', max(length("TIPO")) FROM sca2_anulaciones.sca2_tarea
UNION ALL SELECT 'tarea.ESTADO', max(length("ESTADO")) FROM sca2_anulaciones.sca2_tarea
) t),
  'A12#1', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "ESTADO_SOLICITUD", count(*) FROM sca2_anulaciones.sca2_solicitud GROUP BY 1 ORDER BY 2 DESC
) t),
  'A12#2', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "TIPO", "ESTADO", count(*) FROM sca2_anulaciones.sca2_tarea GROUP BY 1, 2 ORDER BY 3 DESC
) t),
  'A12#3', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT "ESTADO", count(*) FROM sca2_anulaciones.sca2_error GROUP BY 1 ORDER BY 2 DESC
) t),
  'A12#4', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
SELECT count(*) FILTER (WHERE "ID_SOLICITUD" LIKE 'PDTE-%') AS pdte, count(*) AS total FROM sca2_anulaciones.sca2_solicitud
) t)
)::text AS resultado;
