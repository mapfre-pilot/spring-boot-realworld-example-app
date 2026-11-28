-- SCA2 TEST · Aurora PostgreSQL 14 · fase 1 (estructura vacía).
-- Confirma la conexión a TEST y los permisos para SET ROLE user_sca2_anulaciones.
-- DBeaver: ejecutar el script completo (Alt+X), con parada al primer error.
-- No mueve datos, no altera tablas vivas y no registra ningún batch.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog;

SELECT pg_advisory_xact_lock(619431, 71);

DO $archivo$
DECLARE
  tablas constant text[] := ARRAY[
    'sca2_solicitud', 'sca2_transicion', 'sca2_tarea', 'sca2_error',
    'sca2_llamada_servicio', 'sca2_datos_cabecera', 'sca2_datos_solicitud',
    'sca2_datos_basicos_solicitud', 'sca2_datos_perfiles_pca', 'sca2_datos_productor',
    'sca2_datos_poliza_autos', 'sca2_datos_poliza_hogar', 'sca2_datos_poliza_vida',
    'sca2_niveles_cobertura_autos', 'sca2_otras_solicitudes_cabecera'
  ];
  marca constant text := 'SCA2-HIST-71: estructura historica v1';
  viva text;
  hist text;
  tabla_viva regclass;
  tabla_hist regclass;
  clave_unica text;
  columnas_vivas jsonb;
  columnas_hist jsonb;
  nuevas integer := 0;
BEGIN
  FOREACH viva IN ARRAY tablas LOOP
    hist := viva || '_hist';
    tabla_viva := to_regclass(format('sca2_anulaciones.%I', viva));
    tabla_hist := to_regclass(format('sca2_anulaciones.%I', hist));
    clave_unica := CASE
      WHEN viva IN ('sca2_solicitud', 'sca2_datos_cabecera') THEN 'ID_SOLICITUD'
      WHEN viva = 'sca2_transicion' THEN 'CLAVE_IDEMPOTENCIA'
    END;

    IF NOT EXISTS (
      SELECT 1 FROM pg_class WHERE oid = tabla_viva AND relkind = 'r'
    ) OR NOT EXISTS (
      SELECT 1 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid
       WHERE c.conrelid = tabla_viva AND c.contype = 'p'
         AND a.attname = 'ID' AND a.atttypid = 'integer'::regtype
         AND c.conkey = ARRAY[a.attnum]
    ) THEN
      RAISE EXCEPTION 'Falta la tabla viva % o su clave primaria esperada (ID integer)', viva;
    END IF;

    IF tabla_hist IS NULL THEN
      EXECUTE format(
        'CREATE TABLE sca2_anulaciones.%I (LIKE sca2_anulaciones.%I,
          "FECHA_ARCHIVADO" timestamptz NOT NULL, PRIMARY KEY ("ID"))', hist, viva
      );
      EXECUTE format('COMMENT ON TABLE sca2_anulaciones.%I IS %L', hist, marca);
      EXECUTE format('REVOKE ALL ON TABLE sca2_anulaciones.%I FROM PUBLIC', hist);

      IF clave_unica IS NOT NULL THEN
        EXECUTE format('ALTER TABLE sca2_anulaciones.%I ADD UNIQUE (%I)', hist, clave_unica);
      END IF;
      IF viva NOT IN ('sca2_solicitud', 'sca2_datos_cabecera', 'sca2_transicion') THEN
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("ID_SOLICITUD")', hist);
      END IF;
      IF viva = 'sca2_solicitud' THEN
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("CREATED_AT" DESC, "ID" DESC)', hist);
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("NUM_POLIZA", "CREATED_AT" DESC, "ID" DESC)', hist);
      ELSIF viva = 'sca2_transicion' THEN
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("ID_SOLICITUD", "FECHA" DESC, "ID" DESC)', hist);
      END IF;
      nuevas := nuevas + 1;
      tabla_hist := to_regclass(format('sca2_anulaciones.%I', hist));
    ELSIF NOT EXISTS (
      SELECT 1 FROM pg_class
       WHERE oid = tabla_hist AND relkind = 'r' AND relowner = current_user::regrole
         AND obj_description(oid, 'pg_class') = marca
    ) THEN
      RAISE EXCEPTION 'La tabla histórica % ya existe y no pertenece a este script; no se modifica', hist;
    END IF;

    SELECT jsonb_agg(jsonb_build_array(attname, atttypid, atttypmod, attnotnull, attcollation) ORDER BY attname)
      INTO columnas_vivas FROM pg_attribute
     WHERE attrelid = tabla_viva AND attnum > 0 AND NOT attisdropped;
    SELECT jsonb_agg(jsonb_build_array(attname, atttypid, atttypmod, attnotnull, attcollation) ORDER BY attname)
      INTO columnas_hist FROM pg_attribute
     WHERE attrelid = tabla_hist AND attnum > 0 AND NOT attisdropped AND attname <> 'FECHA_ARCHIVADO';

    IF columnas_hist IS DISTINCT FROM columnas_vivas OR NOT EXISTS (
      SELECT 1 FROM pg_attribute WHERE attrelid = tabla_hist AND NOT attisdropped
        AND attname = 'FECHA_ARCHIVADO' AND atttypid = 'timestamptz'::regtype AND attnotnull
    ) OR EXISTS (
      SELECT 1 FROM pg_attribute WHERE attrelid = tabla_hist AND attnum > 0
        AND NOT attisdropped AND (atthasdef OR attidentity <> '' OR attgenerated <> '')
    ) OR NOT EXISTS (
      SELECT 1 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid
       WHERE c.conrelid = tabla_hist AND c.contype = 'p'
         AND a.attname = 'ID' AND c.conkey = ARRAY[a.attnum]
    ) OR (clave_unica IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid
       WHERE c.conrelid = tabla_hist AND c.contype = 'u'
         AND a.attname = clave_unica AND c.conkey = ARRAY[a.attnum]
    )) THEN
      RAISE EXCEPTION 'La estructura de % no coincide con la tabla viva o el contrato de archivo; revisar con el DBA', hist;
    END IF;
  END LOOP;

  RAISE NOTICE 'SCA2 histórico: % tablas verificadas; % creadas', array_length(tablas, 1), nuevas;
END;
$archivo$;

COMMIT;
