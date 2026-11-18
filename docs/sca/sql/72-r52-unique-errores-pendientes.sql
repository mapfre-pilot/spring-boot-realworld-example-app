-- =====================================================================================
-- R52 · SCA2 TEST · esquema sca2_anulaciones (PostgreSQL 14 / Aurora)
-- Ejecutar en DBeaver (conexión appianmapfredbpre), Auto-commit activado, Alt+X.
-- Orden: 0 (lectura inicial) → 1 (índice único de errores PENDIENTE, solo si no hay duplicados) → 2 (lectura final).
-- Alt+X abre un resultado por SELECT: el JSON que vale es el ÚLTIMO (bloque 2).
-- Rollback al final (bloque R1). Doc: docs/sca/pruebas/r52-tareas-repetidas-usuario-real.md
-- Clave: (ID_SOLICITUD, COMANDO, NODO, CODIGO) con ESTADO = 'PENDIENTE', igual que SCA2_obtenerErrorPendiente.
-- NODO y CODIGO van con coalesce(…, '') porque en PostgreSQL 14 dos NULL no chocan en un UNIQUE
-- y la regla de Appian sí los trata como iguales («is null»).
-- =====================================================================================

-- 0. LECTURA INICIAL (devuelve un único JSON; exportar con «Exportar desde consulta»)
SELECT json_build_object(
  'indice_errores', (SELECT indexdef FROM pg_indexes
                      WHERE schemaname = 'sca2_anulaciones' AND indexname = 'ux_sca2_error_pendiente_clave'),
  'errores_pendientes', (SELECT count(*) FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'),
  'errores_pendientes_duplicados', (SELECT coalesce(json_agg(d ORDER BY d."ID_SOLICITUD", d."COMANDO"), '[]'::json) FROM (
      SELECT "ID_SOLICITUD", "COMANDO", "NODO", "CODIGO", count(*) AS filas, array_agg("ID" ORDER BY "ID") AS ids
        FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'
       GROUP BY "ID_SOLICITUD", "COMANDO", "NODO", "CODIGO" HAVING count(*) > 1) d)
) AS resultado;

-- 1. Un solo error PENDIENTE por (solicitud, comando, nodo, código). No se crea si hay duplicados (se listan).
DO $$
DECLARE r record; v_dup integer;
BEGIN
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'sca2_anulaciones'
              AND indexname = 'ux_sca2_error_pendiente_clave') THEN
    RAISE NOTICE '[1] El índice ux_sca2_error_pendiente_clave ya existe: no se hace nada';
    RETURN;
  END IF;
  SELECT count(*) INTO v_dup FROM (SELECT 1 FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'
     GROUP BY "ID_SOLICITUD", "COMANDO", coalesce("NODO", ''), coalesce("CODIGO", '') HAVING count(*) > 1) x;
  IF v_dup > 0 THEN
    FOR r IN SELECT "ID_SOLICITUD" AS s, "COMANDO" AS c, coalesce("NODO", '') AS n, coalesce("CODIGO", '') AS k,
                    string_agg("ID"::text, ', ' ORDER BY "ID") AS ids
               FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'
              GROUP BY "ID_SOLICITUD", "COMANDO", coalesce("NODO", ''), coalesce("CODIGO", '') HAVING count(*) > 1 LOOP
      RAISE NOTICE '[1] Duplicado: solicitud % comando % nodo % código % ids %', r.s, r.c, r.n, r.k, r.ids;
    END LOOP;
    RAISE NOTICE '[1] Hay % grupos duplicados: NO se crea el índice. Cerrar antes los duplicados (ver informe r52)', v_dup;
    RETURN;
  END IF;
  -- Tabla pequeña (< 1000 filas): creación normal, el bloqueo dura milisegundos.
  EXECUTE 'CREATE UNIQUE INDEX ux_sca2_error_pendiente_clave ON sca2_anulaciones.sca2_error '
       || '("ID_SOLICITUD", "COMANDO", (coalesce("NODO", '''')), (coalesce("CODIGO", ''''))) WHERE "ESTADO" = ''PENDIENTE''';
  RAISE NOTICE '[1] Creado ux_sca2_error_pendiente_clave';
END $$;

-- 2. LECTURA FINAL (el mismo JSON que el bloque 0, ya con los cambios; es el que hay que pasar)
SELECT json_build_object(
  'indice_errores', (SELECT indexdef FROM pg_indexes
                      WHERE schemaname = 'sca2_anulaciones' AND indexname = 'ux_sca2_error_pendiente_clave'),
  'errores_pendientes', (SELECT count(*) FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'),
  'errores_pendientes_duplicados', (SELECT coalesce(json_agg(d ORDER BY d."ID_SOLICITUD", d."COMANDO"), '[]'::json) FROM (
      SELECT "ID_SOLICITUD", "COMANDO", "NODO", "CODIGO", count(*) AS filas, array_agg("ID" ORDER BY "ID") AS ids
        FROM sca2_anulaciones.sca2_error WHERE "ESTADO" = 'PENDIENTE'
       GROUP BY "ID_SOLICITUD", "COMANDO", "NODO", "CODIGO" HAVING count(*) > 1) d)
) AS resultado;

-- =====================================================================================
-- ROLLBACK (solo si hiciera falta deshacer)
-- R1. Quitar el índice de errores PENDIENTE
-- DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_error_pendiente_clave;
-- =====================================================================================
