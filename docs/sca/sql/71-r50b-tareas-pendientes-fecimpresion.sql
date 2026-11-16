-- =====================================================================================
-- R50-B · SCA2 TEST · esquema sca2_anulaciones (PostgreSQL 14 / Aurora)
-- Ejecutar en DBeaver (conexión appianmapfredbpre), Auto-commit activado, Alt+X.
-- Orden: 0 (lectura inicial) → 1 (FECIMPRESION a 1000) → 2 (C7, solo si no hay duplicados) → 3 (lectura final).
-- Alt+X abre un resultado por SELECT: el JSON que vale es el ÚLTIMO (bloque 3).
-- Rollback al final (bloques R1 y R2). Doc: docs/sca/pruebas/r50-b-tareas-errores-sin-duplicados.md
-- =====================================================================================

-- 0. LECTURA (devuelve un único JSON; exportar con «Exportar desde consulta»)
SELECT json_build_object(
  'fecimpresion', (SELECT json_build_object('tipo', data_type, 'longitud', character_maximum_length)
                     FROM information_schema.columns
                    WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_solicitud'
                      AND column_name = 'FECIMPRESION'),
  'fecimpresion_max_usada', (SELECT max(length("FECIMPRESION")) FROM sca2_anulaciones.sca2_datos_solicitud),
  'indice_c7', (SELECT indexdef FROM pg_indexes
                 WHERE schemaname = 'sca2_anulaciones' AND indexname = 'ux_sca2_tarea_pendiente_solicitud_tipo'),
  'tareas_pendientes_duplicadas', (SELECT coalesce(json_agg(d ORDER BY d."ID_SOLICITUD", d."TIPO"), '[]'::json) FROM (
      SELECT "ID_SOLICITUD", "TIPO", count(*) AS filas, array_agg("ID" ORDER BY "ID") AS ids
        FROM sca2_anulaciones.sca2_tarea WHERE "ESTADO" = 'PENDIENTE'
       GROUP BY "ID_SOLICITUD", "TIPO" HAVING count(*) > 1) d),
  'errores_pendientes_duplicados', (SELECT count(*) FROM (
      SELECT 1 FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'
       GROUP BY "ID_SOLICITUD", "COMANDO", "NODO", "CODIGO" HAVING count(*) > 1) e)
) AS resultado;

-- 1. Ampliar sca2_datos_solicitud.FECIMPRESION de 255 a 1000 (solo amplía; no reescribe la tabla).
DO $$
DECLARE v_len integer;
BEGIN
  SELECT character_maximum_length INTO v_len FROM information_schema.columns
   WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_solicitud' AND column_name = 'FECIMPRESION';
  IF v_len IS NULL THEN
    RAISE NOTICE '[1] No existe sca2_datos_solicitud.FECIMPRESION o no es VARCHAR: no se hace nada';
  ELSIF v_len >= 1000 THEN
    RAISE NOTICE '[1] FECIMPRESION ya tiene % caracteres: no se hace nada', v_len;
  ELSE
    ALTER TABLE sca2_anulaciones.sca2_datos_solicitud ALTER COLUMN "FECIMPRESION" TYPE VARCHAR(1000);
    RAISE NOTICE '[1] FECIMPRESION ampliada de % a 1000', v_len;
  END IF;
END $$;

-- 2. C7: una sola tarea PENDIENTE por solicitud y tipo. No se crea si hay duplicados (se listan).
DO $$
DECLARE r record; v_dup integer;
BEGIN
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'sca2_anulaciones'
              AND indexname = 'ux_sca2_tarea_pendiente_solicitud_tipo') THEN
    RAISE NOTICE '[2] El índice ux_sca2_tarea_pendiente_solicitud_tipo ya existe: no se hace nada';
    RETURN;
  END IF;
  SELECT count(*) INTO v_dup FROM (SELECT 1 FROM sca2_anulaciones.sca2_tarea WHERE "ESTADO" = 'PENDIENTE'
     GROUP BY "ID_SOLICITUD", "TIPO" HAVING count(*) > 1) x;
  IF v_dup > 0 THEN
    FOR r IN SELECT "ID_SOLICITUD" AS s, "TIPO" AS t, string_agg("ID"::text, ', ' ORDER BY "ID") AS ids
               FROM sca2_anulaciones.sca2_tarea WHERE "ESTADO" = 'PENDIENTE'
              GROUP BY "ID_SOLICITUD", "TIPO" HAVING count(*) > 1 LOOP
      RAISE NOTICE '[2] Duplicado: solicitud % tipo % ids %', r.s, r.t, r.ids;
    END LOOP;
    RAISE NOTICE '[2] Hay % grupos duplicados: NO se crea el índice. Cerrar antes los duplicados (ver informe r50-b §4)', v_dup;
    RETURN;
  END IF;
  -- Tabla pequeña (< 1000 filas): creación normal, el bloqueo dura milisegundos.
  EXECUTE 'CREATE UNIQUE INDEX ux_sca2_tarea_pendiente_solicitud_tipo ON sca2_anulaciones.sca2_tarea ("ID_SOLICITUD", "TIPO") WHERE "ESTADO" = ''PENDIENTE''';
  RAISE NOTICE '[2] Creado ux_sca2_tarea_pendiente_solicitud_tipo';
END $$;

-- 3. LECTURA FINAL (el mismo JSON que el bloque 0, ya con los cambios; es el que hay que pasar. Devuelve un único JSON; exportar con «Exportar desde consulta»)
SELECT json_build_object(
  'fecimpresion', (SELECT json_build_object('tipo', data_type, 'longitud', character_maximum_length)
                     FROM information_schema.columns
                    WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_solicitud'
                      AND column_name = 'FECIMPRESION'),
  'fecimpresion_max_usada', (SELECT max(length("FECIMPRESION")) FROM sca2_anulaciones.sca2_datos_solicitud),
  'indice_c7', (SELECT indexdef FROM pg_indexes
                 WHERE schemaname = 'sca2_anulaciones' AND indexname = 'ux_sca2_tarea_pendiente_solicitud_tipo'),
  'tareas_pendientes_duplicadas', (SELECT coalesce(json_agg(d ORDER BY d."ID_SOLICITUD", d."TIPO"), '[]'::json) FROM (
      SELECT "ID_SOLICITUD", "TIPO", count(*) AS filas, array_agg("ID" ORDER BY "ID") AS ids
        FROM sca2_anulaciones.sca2_tarea WHERE "ESTADO" = 'PENDIENTE'
       GROUP BY "ID_SOLICITUD", "TIPO" HAVING count(*) > 1) d),
  'errores_pendientes_duplicados', (SELECT count(*) FROM (
      SELECT 1 FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'
       GROUP BY "ID_SOLICITUD", "COMANDO", "NODO", "CODIGO" HAVING count(*) > 1) e)
) AS resultado;

-- =====================================================================================
-- ROLLBACK (solo si hiciera falta deshacer)
-- R2. Quitar el índice C7
-- DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_tarea_pendiente_solicitud_tipo;
-- R1. Volver FECIMPRESION a 255 (solo si ningún valor supera 255; si no, avisa y no hace nada)
-- DO $$
-- BEGIN
--   IF (SELECT coalesce(max(length("FECIMPRESION")), 0) FROM sca2_anulaciones.sca2_datos_solicitud) > 255 THEN
--     RAISE NOTICE '[R1] Hay valores de más de 255 caracteres: no se reduce';
--   ELSE
--     ALTER TABLE sca2_anulaciones.sca2_datos_solicitud ALTER COLUMN "FECIMPRESION" TYPE VARCHAR(255);
--     RAISE NOTICE '[R1] FECIMPRESION vuelve a 255';
--   END IF;
-- END $$;
-- =====================================================================================
