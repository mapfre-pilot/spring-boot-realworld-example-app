-- R50-A (16/11/2026) — Paso 3 de BD: C1, índice UNIQUE de la caché de cabecera SCA2
-- Tabla: sca2_anulaciones.sca2_datos_cabecera ("ID_SOLICITUD"). Índice: ux_sca2_datos_cabecera_id_solicitud
--
-- Requisitos previos (hechos en Appian por R50-A, ver pruebas/r50-a-cache-cabecera-unique.md):
--   * SCA2 CMD Alta 44.0: la fila de cabecera del alta reutiliza el id existente (UPDATE).
--   * Web API SCA2_refrescarCacheCabecera: si su INSERT choca con el UNIQUE devuelve 200 con la cabecera.
--   * Borradas desde Appian las filas sobrantes: 0 duplicados.
--
-- Cómo ejecutarlo (DBeaver, TEST, Auto-commit ACTIVADO, Alt+X = ejecutar script):
--   1) Bloque 1 (comprobación previa, solo lectura).
--   2) Bloque 2 (CREATE INDEX CONCURRENTLY). No puede ir dentro de un DO ni de una transacción:
--      por eso va suelto y con Auto-commit. Si hay duplicados, el bloque 1 lanza un ERROR y DBeaver
--      (Alt+X) / psql -v ON_ERROR_STOP=1 detienen el script antes del bloque 2. Si aun así se ejecutara
--      el 2, falla sin crear nada útil y el bloque 3 borra el índice INVALID.
--   3) Bloque 3 (comprueba que el índice es válido; si quedó INVALID lo borra para reintentar).
--   4) Verificación (un único JSON) al final.
-- Idempotente: con el índice ya creado y válido, el bloque 2 no hace nada (IF NOT EXISTS).
-- Rollback: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ux_sca2_datos_cabecera_id_solicitud;

-- ===== Bloque 1: comprobación previa =====
DO $$
DECLARE
  v_dup int;
  v_idx text;
BEGIN
  SELECT count(*) INTO v_dup FROM (
    SELECT 1 FROM sca2_anulaciones.sca2_datos_cabecera
     GROUP BY "ID_SOLICITUD" HAVING count(*) > 1) d;
  SELECT CASE WHEN i.indisvalid THEN 'VALIDO' ELSE 'INVALIDO' END INTO v_idx
    FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
   WHERE n.nspname = 'sca2_anulaciones' AND c.relname = 'ux_sca2_datos_cabecera_id_solicitud';
  IF v_dup > 0 THEN
    RAISE EXCEPTION 'C1: hay % ID_SOLICITUD duplicados en sca2_datos_cabecera: script detenido, el índice NO se crea (avisar a SCA2 para borrarlos desde Appian)', v_dup;
  ELSIF v_idx = 'VALIDO' THEN
    RAISE NOTICE 'C1: ux_sca2_datos_cabecera_id_solicitud ya existe y es válido: el bloque 2 no hará nada';
  ELSIF v_idx = 'INVALIDO' THEN
    RAISE WARNING 'C1: el índice existe pero es INVALIDO (creación interrumpida): ejecutar el bloque 3 y después el 2';
  ELSE
    RAISE NOTICE 'C1: 0 duplicados y sin índice: se puede ejecutar el bloque 2';
  END IF;
END $$;

-- ===== Bloque 2: creación (sin bloquear escrituras) =====
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS ux_sca2_datos_cabecera_id_solicitud
    ON sca2_anulaciones.sca2_datos_cabecera ("ID_SOLICITUD");

-- ===== Bloque 3: comprobación posterior =====
DO $$
DECLARE
  v_valido boolean;
BEGIN
  SELECT i.indisvalid INTO v_valido
    FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
   WHERE n.nspname = 'sca2_anulaciones' AND c.relname = 'ux_sca2_datos_cabecera_id_solicitud';
  IF v_valido IS NULL THEN
    RAISE WARNING 'C1: el índice no existe (¿había duplicados?)';
  ELSIF v_valido THEN
    RAISE NOTICE 'C1: ux_sca2_datos_cabecera_id_solicitud creado y VALIDO';
  ELSE
    -- Un CREATE INDEX CONCURRENTLY fallido (p. ej. por un duplicado entrado durante la creación) deja el índice INVALID.
    EXECUTE 'DROP INDEX sca2_anulaciones.ux_sca2_datos_cabecera_id_solicitud';
    RAISE WARNING 'C1: el índice había quedado INVALIDO y se ha borrado; revisar duplicados y repetir el bloque 2';
  END IF;
END $$;

-- ===== Verificación (solo lectura, un único JSON para exportar) =====
SELECT json_build_object(
  'fecha', now(),
  'filas', (SELECT count(*) FROM sca2_anulaciones.sca2_datos_cabecera),
  'solicitudes', (SELECT count(DISTINCT "ID_SOLICITUD") FROM sca2_anulaciones.sca2_datos_cabecera),
  'duplicados', (SELECT coalesce(json_agg(json_build_object('id_solicitud', "ID_SOLICITUD", 'filas', n)), '[]'::json)
                   FROM (SELECT "ID_SOLICITUD", count(*) n FROM sca2_anulaciones.sca2_datos_cabecera
                          GROUP BY "ID_SOLICITUD" HAVING count(*) > 1) d),
  'indice_c1', (SELECT json_build_object('nombre', c.relname, 'valido', i.indisvalid, 'unico', i.indisunique,
                                         'definicion', pg_get_indexdef(i.indexrelid))
                  FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid
                  JOIN pg_namespace n ON n.oid = c.relnamespace
                 WHERE n.nspname = 'sca2_anulaciones' AND c.relname = 'ux_sca2_datos_cabecera_id_solicitud'),
  'longitud_poliza_fechaultimosiniestro', (SELECT character_maximum_length FROM information_schema.columns
                 WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_cabecera'
                   AND column_name = 'POLIZA_FECHAULTIMOSINIESTRO'),
  'max_longitud_usada', (SELECT max(length("POLIZA_FECHAULTIMOSINIESTRO")) FROM sca2_anulaciones.sca2_datos_cabecera),
  'indices_tabla', (SELECT json_agg(indexname ORDER BY indexname) FROM pg_indexes
                     WHERE schemaname = 'sca2_anulaciones' AND tablename = 'sca2_datos_cabecera')
) AS verificacion_c1;
