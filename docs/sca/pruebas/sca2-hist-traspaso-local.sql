-- Solo para una base PostgreSQL local desechable con estructura y rutinas SCA2 instaladas.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL search_path = sca2_anulaciones, pg_catalog;

DO $prueba$
DECLARE
  r text;
  antigua timestamp := (statement_timestamp() AT TIME ZONE 'UTC') - interval '2 months';
  tabla name;
  expediente constant text := 'LOCAL-ARCHIVABLE';
BEGIN
  CALL sca2_pm_traspasar_historico('[]', '[]', r);
  IF (r::jsonb ->> 'solicitados')::integer <> 0 THEN
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
  IF r::jsonb <> '{"solicitados":5,"archivados":1,"repetidos":0,"excluidos":3,"conflictos":1,"filas":15}'::jsonb THEN
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
  END LOOP;
  IF (SELECT count(*) FROM sca2_solicitud WHERE "ID_SOLICITUD" LIKE 'LOCAL-%') <> 4
     OR EXISTS (SELECT 1 FROM sca2_solicitud_hist WHERE "ID_SOLICITUD" = 'LOCAL-COLISION') THEN
    RAISE EXCEPTION 'Se retiró un excluido o la colisión no revirtió la copia de la raíz';
  END IF;
  CALL sca2_pm_traspasar_historico('["LOCAL-ARCHIVABLE"]', '["LOCAL-ARCHIVABLE"]', r);
  IF r::jsonb <> '{"solicitados":1,"archivados":0,"repetidos":1,"excluidos":0,"conflictos":0,"filas":0}'::jsonb THEN
    RAISE EXCEPTION 'Reejecución no idempotente: %', r;
  END IF;
  RAISE NOTICE 'Histórico: lista vacía; 15 filas del expediente; 3 excluidos; colisión revertida; repetición sin cambios';
END
$prueba$;

ROLLBACK;
