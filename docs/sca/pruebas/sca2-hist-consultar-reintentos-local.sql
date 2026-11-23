-- Ejecutar solo en una base PostgreSQL desechable con la estructura SCA2 instalada.
\ir ../sql/sca2-hist-consultar-reintentos.sql
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL search_path = sca2_anulaciones, pg_catalog;

INSERT INTO sca2_reintento_fin (id_error, id_solicitud, version_origen, estado_final,
                               proceso_original, estado, proximo_intento)
VALUES (-11, 'LOCAL-RETRY-PENDIENTE', 1, 'FINALIZADA', 1, 'PENDIENTE', now() + interval '1 hour'),
       (-11, 'LOCAL-RETRY-PENDIENTE', 2, 'FINALIZADA', 1, 'RECUPERADO', now()),
       (-12, 'LOCAL-RETRY-AGOTADO', 1, 'FINALIZADA', 1, 'AGOTADO', now()),
       (-13, 'LOCAL-RETRY-RECUPERADO', 1, 'FINALIZADA', 1, 'RECUPERADO', now()),
       (-14, 'LOCAL-RETRY-FUERA', 1, 'FINALIZADA', 1, 'PENDIENTE', now()),
       (-15, 'LOCAL-RETRY-MANUAL', 1, 'FINALIZADA', 1, 'MANUAL', now()),
       (-16, 'LOCAL-RETRY-OMITIDO', 1, 'FINALIZADA', 1, 'OMITIDO', now());

DO $prueba$
DECLARE
  r text;
  antes jsonb;
  despues jsonb;
BEGIN
  SELECT jsonb_agg(to_jsonb(q) ORDER BY id_error, version_origen) INTO antes FROM sca2_reintento_fin q;
  CALL sca2_pm_consultar_reintentos_hist('[]', r);
  IF r::jsonb IS DISTINCT FROM '{"evaluados":[],"bloqueados":[]}'::jsonb THEN
    RAISE EXCEPTION 'Resultado inesperado para una lista vacía: %', r;
  END IF;
  CALL sca2_pm_consultar_reintentos_hist(
    '["LOCAL-RETRY-PENDIENTE","LOCAL-RETRY-AGOTADO","LOCAL-RETRY-RECUPERADO","LOCAL-RETRY-AUSENTE","LOCAL-RETRY-PENDIENTE","LOCAL-RETRY-MANUAL","LOCAL-RETRY-OMITIDO"]', r);
  IF r::jsonb IS DISTINCT FROM '{
    "evaluados":["LOCAL-RETRY-AGOTADO","LOCAL-RETRY-AUSENTE","LOCAL-RETRY-MANUAL","LOCAL-RETRY-OMITIDO","LOCAL-RETRY-PENDIENTE","LOCAL-RETRY-RECUPERADO"],
    "bloqueados":["LOCAL-RETRY-AGOTADO","LOCAL-RETRY-MANUAL","LOCAL-RETRY-PENDIENTE"]
  }'::jsonb THEN
    RAISE EXCEPTION 'Resultado de cotejo inesperado: %', r;
  END IF;
  BEGIN
    CALL sca2_pm_consultar_reintentos_hist('[null]', r);
    RAISE EXCEPTION 'Se aceptó un ID nulo';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM <> 'IDs de solicitud no válidos' THEN
      RAISE;
    END IF;
  END;
  SELECT jsonb_agg(to_jsonb(q) ORDER BY id_error, version_origen) INTO despues FROM sca2_reintento_fin q;
  IF despues IS DISTINCT FROM antes THEN
    RAISE EXCEPTION 'La consulta modificó la cola';
  END IF;
  RAISE NOTICE 'Reintentos Hist: lista vacía, IDs válidos y deduplicados, bloqueos por expediente, cola intacta';
END
$prueba$;
ROLLBACK;
