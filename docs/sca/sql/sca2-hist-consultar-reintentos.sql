-- Instalar en TEST desde DBeaver por el responsable de BD. No ejecuta el batch de reintento.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL search_path = pg_catalog;

CREATE OR REPLACE PROCEDURE sca2_anulaciones.sca2_pm_consultar_reintentos_hist(
  IN p_ids text,
  OUT p_resultado text
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $consulta$
DECLARE
  entrada jsonb := p_ids::jsonb;
  evaluados text[];
  bloqueados text[];
BEGIN
  IF jsonb_typeof(entrada) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Se esperaba un array JSON de IDs de solicitud';
  END IF;
  IF jsonb_array_length(entrada) > 1000 OR EXISTS (
    SELECT 1 FROM jsonb_array_elements(entrada) AS t(valor)
     WHERE jsonb_typeof(valor) <> 'string'
        OR length(valor #>> '{}') NOT BETWEEN 1 AND 50
        OR (valor #>> '{}') <> btrim(valor #>> '{}')
        OR (valor #>> '{}') = '0'
  ) THEN
    RAISE EXCEPTION 'IDs de solicitud no válidos';
  END IF;

  SELECT ARRAY(SELECT DISTINCT id FROM jsonb_array_elements_text(entrada) AS t(id) ORDER BY id)
    INTO evaluados;
  SELECT ARRAY(
    SELECT DISTINCT r.id_solicitud::text
      FROM sca2_anulaciones.sca2_reintento_fin AS r
     WHERE r.id_solicitud = ANY(evaluados)
       AND (r.estado IS NULL OR r.estado NOT IN ('RECUPERADO', 'OMITIDO'))
     ORDER BY 1
  ) INTO bloqueados;
  p_resultado := jsonb_build_object('evaluados', evaluados, 'bloqueados', bloqueados)::text;
END
$consulta$;

REVOKE ALL ON PROCEDURE sca2_anulaciones.sca2_pm_consultar_reintentos_hist(text) FROM PUBLIC;
COMMIT;
