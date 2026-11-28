-- Solo PostgreSQL local de prueba, con el esquema SCA2 y la migración ya creados.
-- psql -v ON_ERROR_STOP=1 -f sca2-reintento-finalizacion-local.sql
BEGIN;
SET LOCAL search_path TO sca2_anulaciones, pg_catalog;

INSERT INTO sca2_solicitud ("ID_SOLICITUD", "NUM_POLIZA", "CREATED_AT", "ESTADO_SOLICITUD", "NODO_RELANZAR", "ERROR", "VERSION")
SELECT id, id, now() AT TIME ZONE 'UTC', 'ERROR', 'Finalizar PCA', 'fallo de prueba', 5
FROM unnest(ARRAY['FIN-OK', 'FIN-MANUAL', 'FIN-ANTIGUO', 'FIN-EXTERNO', 'FIN-STALE', 'FIN-AGOTAR', 'FIN-YA-OK']) AS t(id);

INSERT INTO sca2_error ("ID_SOLICITUD", "COMANDO", "NODO", "CODIGO", "ESTADO", "FECHA_CREACION", "PROXIMO_INTENTO")
SELECT "ID_SOLICITUD", 'SCA2 CMD Finalizar', 'Write FINALIZADA',
       CASE WHEN "ID_SOLICITUD" = 'FIN-EXTERNO' THEN 'FINALIZAR_ERROR' ELSE 'WRITE_FAIL' END,
       'PENDIENTE', now() AT TIME ZONE 'UTC', now() AT TIME ZONE 'UTC' - interval '1 hour'
FROM sca2_solicitud WHERE "ID_SOLICITUD" LIKE 'FIN-%';

INSERT INTO sca2_datos_cabecera ("ID_SOLICITUD", "ORIGEN_CACHE", "VALIDA_HASTA")
VALUES ('FIN-OK', 'CACHE', now() AT TIME ZONE 'UTC' + interval '1 hour');

DO $$
DECLARE
  v_manual integer := (SELECT "ID" FROM sca2_error WHERE "ID_SOLICITUD" = 'FIN-MANUAL');
  v_ok integer := (SELECT "ID" FROM sca2_error WHERE "ID_SOLICITUD" = 'FIN-OK');
  v_antiguo integer := (SELECT "ID" FROM sca2_error WHERE "ID_SOLICITUD" = 'FIN-ANTIGUO');
  v_externo integer := (SELECT "ID" FROM sca2_error WHERE "ID_SOLICITUD" = 'FIN-EXTERNO');
  v_inicio timestamp := now() AT TIME ZONE 'UTC' - interval '1 minute';
  v_error record;
BEGIN
  ASSERT sca2_capturar_reintento_fin(v_ok, 'FIN-OK', 4, 'PDTE_FINALIZAR', 'CANCELADA', 1, v_inicio, true, true);
  ASSERT NOT sca2_capturar_reintento_fin(v_ok, 'FIN-OK', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 2, v_inicio, true, true);
  FOR v_error IN SELECT "ID", "ID_SOLICITUD" FROM sca2_error
    WHERE "ID_SOLICITUD" IN ('FIN-MANUAL', 'FIN-STALE', 'FIN-AGOTAR', 'FIN-YA-OK')
  LOOP
    ASSERT sca2_capturar_reintento_fin(v_error."ID", v_error."ID_SOLICITUD", 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio, true, true);
  END LOOP;
  ASSERT NOT sca2_capturar_reintento_fin(v_externo, 'FIN-EXTERNO', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio, true, true);
  ASSERT NOT sca2_capturar_reintento_fin(v_ok, 'FIN-ANTIGUO', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio, true, true);
  ASSERT NOT sca2_capturar_reintento_fin(v_antiguo, 'FIN-ANTIGUO', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio, true, false);
  ASSERT NOT sca2_capturar_reintento_fin(v_antiguo, 'FIN-ANTIGUO', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio, false, true);
  ASSERT NOT sca2_capturar_reintento_fin(v_antiguo, 'FIN-ANTIGUO', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio + interval '1 hour', true, true);

  ASSERT sca2_reservar_manual_fin(v_antiguo, 'FIN-ANTIGUO', 'appian-pruebas') = 'NORMAL';
  ASSERT NOT sca2_capturar_reintento_fin(v_antiguo, 'FIN-ANTIGUO', 4, 'PDTE_FINALIZAR', 'FINALIZADA', 1, v_inicio, true, true);
  ASSERT sca2_ejecutar_reintento_fin('appian-pruebas', 2, true) = '[]'::jsonb;
  UPDATE sca2_reintento_fin_config SET habilitado = true;
  ASSERT sca2_ejecutar_reintento_fin('appian-pruebas', 2, true) = '[]'::jsonb;
  ASSERT sca2_reservar_manual_fin(v_manual, 'FIN-MANUAL', 'appian-pruebas') = 'LANZAR';
  ASSERT sca2_reservar_manual_fin(v_manual, 'FIN-MANUAL', 'appian-pruebas') = 'OMITIR';
  ASSERT (SELECT "ESTADO" = 'RELANZADO' FROM sca2_error WHERE "ID" = v_manual);
  ASSERT (SELECT "ESTADO_SOLICITUD" = 'ERROR' FROM sca2_solicitud WHERE "ID_SOLICITUD" = 'FIN-MANUAL');
END $$;

UPDATE sca2_reintento_fin SET proximo_intento = now() AT TIME ZONE 'UTC' - interval '1 minute';
UPDATE sca2_solicitud SET "VERSION" = 6 WHERE "ID_SOLICITUD" = 'FIN-STALE';
INSERT INTO sca2_transicion ("ID_SOLICITUD", "CLAVE_IDEMPOTENCIA", "RESULTADO")
VALUES ('FIN-YA-OK', 'SCA2 CMD Finalizar|FIN-YA-OK|4', 'OK');
ALTER TABLE sca2_transicion ADD CONSTRAINT prueba_fallo_transicion CHECK ("ID_SOLICITUD" <> 'FIN-AGOTAR');

DO $$
DECLARE
  v jsonb := sca2_ejecutar_reintento_fin('appian-pruebas', 2, true);
  v_ok integer := (SELECT "ID" FROM sca2_error WHERE "ID_SOLICITUD" = 'FIN-OK');
BEGIN
  ASSERT jsonb_array_length(v) = 1;
  ASSERT (v->0->>'error')::integer = v_ok AND jsonb_array_length(v->0->'cache') = 1;
  ASSERT (SELECT "ESTADO_SOLICITUD" = 'CANCELADA' AND "VERSION" = 6 AND "ERROR" IS NULL
          FROM sca2_solicitud WHERE "ID_SOLICITUD" = 'FIN-OK');
  ASSERT (SELECT "ESTADO" = 'RELANZADO' FROM sca2_error WHERE "ID" = v_ok);
  ASSERT sca2_reservar_manual_fin(v_ok, 'FIN-OK', 'appian-pruebas') = 'OMITIR';
  ASSERT (SELECT count(*) = 1 FROM sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" = 'SCA2 CMD Finalizar|FIN-OK|4' AND "RESULTADO" = 'OK');
  ASSERT (SELECT count(*) = 2 FROM sca2_reintento_fin WHERE estado = 'OMITIDO');
  ASSERT (SELECT estado = 'PENDIENTE' AND intentos = 1 AND ultimo_error = '23514' FROM sca2_reintento_fin WHERE id_solicitud = 'FIN-AGOTAR');

  FOR i IN 2..3 LOOP
    UPDATE sca2_reintento_fin SET proximo_intento = now() AT TIME ZONE 'UTC' - interval '1 minute'
    WHERE id_solicitud = 'FIN-AGOTAR';
    ASSERT sca2_ejecutar_reintento_fin('appian-pruebas', 2, true) = '[]'::jsonb;
  END LOOP;
  ASSERT sca2_ejecutar_reintento_fin('appian-pruebas', 2, true) = '[]'::jsonb;
  ASSERT (SELECT estado = 'AGOTADO' AND intentos = 3 FROM sca2_reintento_fin WHERE id_solicitud = 'FIN-AGOTAR');
  ASSERT (SELECT "ESTADO_SOLICITUD" = 'ERROR' AND "VERSION" = 5 FROM sca2_solicitud WHERE "ID_SOLICITUD" = 'FIN-AGOTAR');
  ASSERT (SELECT "ESTADO" = 'PENDIENTE' FROM sca2_error WHERE "ID_SOLICITUD" = 'FIN-AGOTAR');
END $$;

CALL sca2_pm_ejecutar_reintento_fin('appian-pruebas', 2::bigint, true, NULL);
ROLLBACK;
