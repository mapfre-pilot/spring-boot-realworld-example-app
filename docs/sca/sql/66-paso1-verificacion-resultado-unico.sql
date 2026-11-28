-- =============================================================================
-- 66-paso1-verificacion-resultado-unico.sql — Verificación del paso 1 (solo lectura)
-- =============================================================================
-- Devuelve una sola celda «resultado» con un JSON. En DBeaver: botón derecho >
-- Ejecutar > Exportar desde consulta > JSON o TXT > Iniciar, y mandar el fichero.
-- =============================================================================
SELECT json_build_object(
  'D0_owner', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
      SELECT current_user, tableowner, count(*) AS tablas,
             bool_and(pg_has_role(current_user, tableowner, 'USAGE')) AS puede_crear_indices
        FROM pg_tables WHERE schemaname = 'sca2_anulaciones' AND tablename LIKE 'sca2\_%'
       GROUP BY tableowner) t),
  'D1_indices', (SELECT coalesce(json_agg(t ORDER BY t.tablename, t.indexname), '[]'::json) FROM (
      SELECT tablename, indexname, indexdef FROM pg_indexes
       WHERE schemaname = 'sca2_anulaciones' AND tablename LIKE 'sca2\_%') t),
  'D1_restricciones', (SELECT coalesce(json_agg(t ORDER BY t.tabla, t.conname), '[]'::json) FROM (
      SELECT conrelid::regclass::text AS tabla, conname, contype, convalidated,
             pg_get_constraintdef(oid) AS definicion
        FROM pg_constraint WHERE connamespace = 'sca2_anulaciones'::regnamespace
         AND conrelid::regclass::text LIKE 'sca2\_%') t),
  'D2_indices_invalidos', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
      SELECT i.relname AS indice_invalido FROM pg_index ix
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_namespace n ON n.oid = i.relnamespace
       WHERE n.nspname = 'sca2_anulaciones' AND NOT ix.indisvalid) t),
  'D_longitudes', (SELECT coalesce(json_agg(t), '[]'::json) FROM (
      SELECT table_name, column_name, character_maximum_length
        FROM information_schema.columns
       WHERE table_schema = 'sca2_anulaciones'
         AND (table_name, column_name) IN (('sca2_datos_cabecera','POLIZA_FECHAULTIMOSINIESTRO'),
                                          ('sca2_transicion','CLAVE_IDEMPOTENCIA'))) t),
  'D_analyze', (SELECT coalesce(json_agg(t ORDER BY t.relname), '[]'::json) FROM (
      SELECT relname, n_live_tup, last_analyze, last_autoanalyze FROM pg_stat_user_tables
       WHERE schemaname = 'sca2_anulaciones' AND relname LIKE 'sca2\_%') t)
)::text AS resultado;
