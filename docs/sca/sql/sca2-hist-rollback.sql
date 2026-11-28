-- SCA2 TEST · Reversión de la instalación inicial (solo tablas históricas vacías).
-- DBeaver: confirma la conexión a TEST y ejecuta el script completo (Alt+X)
-- con parada al primer error. Antes, retirar consumidores Appian si los hubiera.
-- Se niega a eliminar si alguna tabla tiene filas, no es del DDL o tiene
-- dependencias en BD. No usar para revertir un piloto que ya movió expedientes.
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
  tabla_hist regclass;
  lista text[] := ARRAY[]::text[];
  contiene_filas boolean;
BEGIN
  FOREACH viva IN ARRAY tablas LOOP
    hist := viva || '_hist';
    tabla_hist := to_regclass(format('sca2_anulaciones.%I', hist));
    IF tabla_hist IS NULL THEN
      CONTINUE;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM pg_class
       WHERE oid = tabla_hist AND relkind = 'r' AND relowner = current_user::regrole
         AND obj_description(oid, 'pg_class') = marca
    ) THEN
      RAISE EXCEPTION 'La tabla histórica % no pertenece a este script; no se elimina ninguna tabla', hist;
    END IF;
    EXECUTE format('LOCK TABLE sca2_anulaciones.%I IN ACCESS EXCLUSIVE MODE', hist);
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM sca2_anulaciones.%I)', hist) INTO contiene_filas;
    IF contiene_filas THEN
      RAISE EXCEPTION 'La tabla histórica % tiene datos; no se elimina ninguna tabla', hist;
    END IF;
    lista := array_append(lista, hist);
  END LOOP;

  FOREACH hist IN ARRAY lista LOOP
    EXECUTE format('DROP TABLE sca2_anulaciones.%I RESTRICT', hist);
  END LOOP;
  RAISE NOTICE 'SCA2 histórico: % tablas vacías eliminadas', cardinality(lista);
END;
$archivo$;

COMMIT;
