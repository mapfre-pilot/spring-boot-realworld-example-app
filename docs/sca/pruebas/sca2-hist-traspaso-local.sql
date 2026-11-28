-- Solo para una base PostgreSQL local desechable con estructura y rutinas SCA2 instaladas.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL search_path = sca2_anulaciones, pg_catalog;

DO $prueba$
DECLARE
  r text;
  resumen jsonb;
  claves jsonb;
  antigua timestamp := (statement_timestamp() AT TIME ZONE 'UTC') - interval '2 months';
  tabla name;
  expediente constant text := 'LOCAL-ARCHIVABLE';
BEGIN
  CALL sca2_pm_traspasar_historico('[]', '[]', r);
  IF (r::jsonb ->> 'solicitados')::integer <> 0
     OR r::jsonb -> 'versionRutina' IS DISTINCT FROM '3'::jsonb
     OR r::jsonb -> 'idsArchivados' IS DISTINCT FROM '[]'::jsonb
     OR r::jsonb -> 'clavesSync' IS DISTINCT FROM '{}'::jsonb THEN
    RAISE EXCEPTION 'La lista vacía no debe procesar nada';
  END IF;

  INSERT INTO sca2_solicitud ("ID_SOLICITUD", "NUM_POLIZA", "ESTADO_SOLICITUD", "CREATED_AT")
    SELECT id, '1', 'FINALIZADA', antigua
      FROM unnest(ARRAY[expediente, 'LOCAL-PENDIENTE', 'LOCAL-REABIERTO', 'LOCAL-COLISION', 'LOCAL-NO-AUTORIZADO']) AS t(id);
  INSERT INTO sca2_transicion ("ID_SOLICITUD", "ESTADO_ORIGEN", "ESTADO_DESTINO", "RESULTADO", "FECHA", "CLAVE_IDEMPOTENCIA")
    SELECT id, 'EN_PROCESO', 'FINALIZADA', 'OK', antigua, id || '-CIERRE'
      FROM unnest(ARRAY[expediente, 'LOCAL-PENDIENTE', 'LOCAL-REABIERTO', 'LOCAL-COLISION', 'LOCAL-NO-AUTORIZADO']) AS t(id);
  INSERT INTO sca2_transicion ("ID_SOLICITUD", "ESTADO_ORIGEN", "ESTADO_DESTINO", "RESULTADO", "FECHA", "CLAVE_IDEMPOTENCIA")
    VALUES ('LOCAL-REABIERTO','FINALIZADA','EN_PROCESO','OK',antigua - interval '1 day','LOCAL-REAPERTURA');
  INSERT INTO sca2_tarea ("ID_SOLICITUD", "ESTADO", "FECHA_CIERRE")
    VALUES (expediente,'COMPLETADA',antigua), ('LOCAL-PENDIENTE','PENDIENTE',NULL);
  INSERT INTO sca2_datos_cabecera ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_solicitud ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_basicos_solicitud ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_perfiles_pca ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_productor ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_poliza_autos ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_poliza_hogar ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_datos_poliza_vida ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_niveles_cobertura_autos ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_otras_solicitudes_cabecera ("ID_SOLICITUD") VALUES (expediente);
  INSERT INTO sca2_error ("ID_SOLICITUD", "ESTADO", "FECHA_RESOLUCION") VALUES (expediente,'RESUELTO',antigua);
  INSERT INTO sca2_llamada_servicio ("ID_SOLICITUD", "FECHA_FIN") VALUES (expediente, antigua);
  INSERT INTO sca2_transicion_hist ("ID", "ID_SOLICITUD", "ESTADO_ORIGEN", "CLAVE_IDEMPOTENCIA", "FECHA_ARCHIVADO")
    SELECT "ID", "ID_SOLICITUD", 'DISTINTO', "CLAVE_IDEMPOTENCIA", now()
      FROM sca2_transicion WHERE "ID_SOLICITUD" = 'LOCAL-COLISION';

  CALL sca2_pm_traspasar_historico(
    '["LOCAL-ARCHIVABLE","LOCAL-PENDIENTE","LOCAL-REABIERTO","LOCAL-COLISION","LOCAL-ARCHIVABLE","LOCAL-NO-AUTORIZADO"]',
    '["LOCAL-ARCHIVABLE","LOCAL-PENDIENTE","LOCAL-REABIERTO","LOCAL-COLISION"]', r);
  resumen := r::jsonb;
  IF resumen - 'idsArchivados' - 'clavesSync' <> '{"versionRutina":3,"solicitados":5,"archivados":1,"repetidos":0,"excluidos":3,"conflictos":1,"filas":15}'::jsonb
     OR resumen -> 'idsArchivados' IS DISTINCT FROM jsonb_build_array(expediente) THEN
    RAISE EXCEPTION 'Resumen inesperado: %', r;
  END IF;
  FOR tabla IN
    SELECT relname FROM pg_class WHERE relnamespace = 'sca2_anulaciones'::regnamespace
      AND relkind = 'r' AND right(relname,5) = '_hist'
  LOOP
    EXECUTE format('SELECT CASE WHEN count(*) = 1 THEN ''ok'' ELSE ''error'' END FROM %I WHERE "ID_SOLICITUD" = $1', tabla)
      INTO r USING expediente;
    IF r <> 'ok' THEN RAISE EXCEPTION 'No se archivó todo el expediente en %', tabla; END IF;
    EXECUTE format('SELECT CASE WHEN count(*) = 0 THEN ''ok'' ELSE ''error'' END FROM %I WHERE "ID_SOLICITUD" = $1', left(tabla,-5))
      INTO r USING expediente;
    IF r <> 'ok' THEN RAISE EXCEPTION 'Quedaron filas vivas en %', tabla; END IF;
    EXECUTE format('SELECT jsonb_agg("ID" ORDER BY "ID") FROM %I WHERE "ID_SOLICITUD" = $1', tabla)
      INTO claves USING expediente;
    IF resumen -> 'clavesSync' -> left(tabla,-5) IS DISTINCT FROM claves THEN
      RAISE EXCEPTION 'Claves de sincronización incorrectas en %', tabla;
    END IF;
  END LOOP;
  IF (SELECT count(*) FROM sca2_solicitud WHERE "ID_SOLICITUD" LIKE 'LOCAL-%') <> 4
     OR EXISTS (SELECT 1 FROM sca2_solicitud_hist WHERE "ID_SOLICITUD" = 'LOCAL-COLISION') THEN
    RAISE EXCEPTION 'Se retiró un excluido o la colisión no revirtió la copia de la raíz';
  END IF;
  CALL sca2_pm_traspasar_historico('["LOCAL-ARCHIVABLE"]', '["LOCAL-ARCHIVABLE"]', r);
  IF r::jsonb <> '{"versionRutina":3,"solicitados":1,"archivados":0,"repetidos":1,"excluidos":0,"conflictos":0,"filas":0,"idsArchivados":[],"clavesSync":{}}'::jsonb THEN
    RAISE EXCEPTION 'Reejecución no idempotente: %', r;
  END IF;
  RAISE NOTICE 'Histórico: lista vacía; 15 filas del expediente; 3 excluidos; colisión revertida; repetición sin cambios';
END
$prueba$;

DO $reintentos$
DECLARE
  r text;
  antigua timestamp := (statement_timestamp() AT TIME ZONE 'UTC') - interval '2 months';
  ids constant text[] := ARRAY['LOCAL-GUARD-MANUAL', 'LOCAL-GUARD-PENDIENTE', 'LOCAL-GUARD-AGOTADO',
                                'LOCAL-GUARD-RECUPERADO', 'LOCAL-GUARD-OMITIDO'];
  estados constant text[] := ARRAY['MANUAL', 'PENDIENTE', 'AGOTADO', 'RECUPERADO', 'OMITIDO'];
BEGIN
  INSERT INTO sca2_solicitud ("ID_SOLICITUD", "NUM_POLIZA", "ESTADO_SOLICITUD", "CREATED_AT")
    SELECT id, '1', 'FINALIZADA', antigua FROM unnest(ids) AS t(id);
  INSERT INTO sca2_transicion ("ID_SOLICITUD", "ESTADO_ORIGEN", "ESTADO_DESTINO", "RESULTADO", "FECHA", "CLAVE_IDEMPOTENCIA")
    SELECT id, 'EN_PROCESO', 'FINALIZADA', 'OK', antigua, id || '-CIERRE' FROM unnest(ids) AS t(id);
  WITH errores AS (
    INSERT INTO sca2_error ("ID_SOLICITUD", "ESTADO", "FECHA_RESOLUCION")
      SELECT id, 'RESUELTO', antigua FROM unnest(ids) AS t(id)
      RETURNING "ID", "ID_SOLICITUD"
  )
  INSERT INTO sca2_reintento_fin (id_error, id_solicitud, version_origen, estado_final, proceso_original, estado, proximo_intento)
    SELECT e."ID", t.id, 1, 'FINALIZADA', 1, t.estado, now() + interval '1 day'
      FROM unnest(ids, estados) AS t(id, estado) JOIN errores e ON e."ID_SOLICITUD" = t.id;

  CALL sca2_pm_traspasar_historico(to_jsonb(ids)::text, to_jsonb(ids)::text, r);
  IF r::jsonb -> 'idsArchivados' IS DISTINCT FROM jsonb_build_array(ids[5], ids[4])
     OR (r::jsonb ->> 'excluidos')::integer IS DISTINCT FROM 3
     OR (SELECT count(*) FROM sca2_solicitud WHERE "ID_SOLICITUD" = ANY(ids[1:3])) <> 3
     OR EXISTS (SELECT 1 FROM sca2_solicitud_hist WHERE "ID_SOLICITUD" = ANY(ids[1:3])) THEN
    RAISE EXCEPTION 'Veto de reintentos inesperado: %', r;
  END IF;
  RAISE NOTICE 'Veto atómico: MANUAL con error RESUELTO, PENDIENTE y AGOTADO fuera; RECUPERADO y OMITIDO no bloquean';
END
$reintentos$;

ROLLBACK;
