-- 76 · SCA2 · Ampliar OBSERVACIONES a VARCHAR(2000) en el catálogo de tipos de argumento.
-- Aurora PostgreSQL. Ejecutar primero en TEST y luego en la BD SCA2 de destino
-- con el propietario de la tabla o un rol habilitado para alterarla.
-- psql -v ON_ERROR_STOP=1 -f 76-ampliar-observaciones-tipo-argumento.sql
-- En DBeaver: ejecutar el script completo (Alt+X) en la conexión de SCA2.
-- No reduce una columna que ya admita 2000 caracteres o más.
-- No volver a VARCHAR(255) si ya hay textos más largos.

BEGIN;
SET LOCAL lock_timeout = '5s';

DO $$
DECLARE
  tipo text;
  longitud integer;
BEGIN
  SELECT data_type, character_maximum_length INTO tipo, longitud
    FROM information_schema.columns
   WHERE table_schema = 'sca2_anulaciones'
     AND table_name = 'sca2_cat_tipo_argumento'
     AND column_name = 'OBSERVACIONES';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No se encuentra sca2_anulaciones.sca2_cat_tipo_argumento."OBSERVACIONES"; revisar la conexión y los permisos';
  ELSIF tipo = 'text' OR (tipo = 'character varying' AND (longitud IS NULL OR longitud >= 2000)) THEN
    RAISE NOTICE 'OBSERVACIONES ya admite al menos 2000 caracteres; no se aplica ningún cambio';
  ELSIF tipo = 'character varying' AND longitud = 255 THEN
    ALTER TABLE sca2_anulaciones.sca2_cat_tipo_argumento
      ALTER COLUMN "OBSERVACIONES" TYPE VARCHAR(2000);
  ELSE
    RAISE EXCEPTION 'Tipo actual inesperado para OBSERVACIONES: %, longitud %', tipo, longitud;
  END IF;
END $$;

COMMIT;

-- Si se amplió: OBSERVACIONES | character varying | 2000.
SELECT column_name, data_type, character_maximum_length
  FROM information_schema.columns
 WHERE table_schema = 'sca2_anulaciones'
   AND table_name = 'sca2_cat_tipo_argumento'
   AND column_name = 'OBSERVACIONES';
