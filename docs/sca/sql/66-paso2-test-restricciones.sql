-- =============================================================================
-- 66-paso2-test-restricciones.sql — Paso 2 (TEST): NOT NULL y UNIQUE de catálogos
-- =============================================================================
-- Lanzar SOLO después de que la regresión del paso 1 (R48-C) haya salido bien.
-- Contenido: C2 (NOT NULL en CLAVE_IDEMPOTENCIA), C3 (NOT NULL en claves de negocio)
-- y C4 (UNIQUE de catálogos; el de tipo de argumento solo sobre filas activas).
-- Cada bloque comprueba antes los datos: si hay nulos o duplicados emite WARNING
-- y no aplica esa restricción.
-- RIESGO FUNCIONAL: si Appian intenta escribir un nulo en esas columnas o dar de
-- alta un código de catálogo activo repetido, la escritura pasará a fallar. Tras
-- aplicarlo hay que probar en TEST alta, contra anulación, acciones y
-- mantenimiento de argumentos con solicitudes nuevas.
-- Bloqueo: ACCESS EXCLUSIVE breve por tabla (milisegundos con el volumen de TEST).
--
-- DBeaver (conexión de TEST): Auto-commit y Alt+X (Ejecutar script). Mirar la
-- pestaña «Salida»/«Output» (Ctrl+Shift+O) para ver los NOTICE/WARNING.
-- Después, ejecutar 66-paso1-verificacion-resultado-unico.sql y mandar el JSON.
-- =============================================================================

SET search_path TO sca2_anulaciones;
SET lock_timeout = '5s';
SET statement_timeout = '15min';

-- C2. [ALTA] Transición: CLAVE_IDEMPOTENCIA (comando|idSolicitud|versión) única y
--     NOT NULL. El UNIQUE ya existe en TEST (el MCP lo informa); un UNIQUE admite
--     varios NULL, por eso se añade NOT NULL. 0 nulos en TEST.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_index ix JOIN pg_attribute a ON a.attrelid = ix.indrelid AND a.attnum = ix.indkey[0]
                  WHERE ix.indrelid = 'sca2_anulaciones.sca2_transicion'::regclass
                    AND ix.indisunique AND ix.indnatts = 1 AND a.attname = 'CLAVE_IDEMPOTENCIA') THEN
    IF EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" IS NOT NULL
                GROUP BY "CLAVE_IDEMPOTENCIA" HAVING count(*) > 1) THEN
      RAISE WARNING 'C2: CLAVE_IDEMPOTENCIA duplicada (ver A8.2); no se crea el UNIQUE';
    ELSE
      ALTER TABLE sca2_anulaciones.sca2_transicion
        ADD CONSTRAINT sca2_transicion_clave_idempotencia_key UNIQUE ("CLAVE_IDEMPOTENCIA");
      RAISE NOTICE 'C2: UNIQUE CLAVE_IDEMPOTENCIA creado';
    END IF;
  END IF;
  IF EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" IS NULL) THEN
    RAISE WARNING 'C2: hay CLAVE_IDEMPOTENCIA nulas; no se aplica NOT NULL';
  ELSE
    ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" SET NOT NULL;
  END IF;
END $$;
-- Rollback C2: ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" DROP NOT NULL;
--              (el UNIQUE es del DDL 56: no quitarlo)

-- C3. [MEDIA] NOT NULL en las claves de negocio que todos los procesos informan
--     (ID_SOLICITUD lleva "PDTE-<proceso>" mientras no hay id de CORE).
--     NO se aplica a sca2_error.ID_SOLICITUD (hay errores sin solicitud por diseño)
--     ni a ESTADO_SOLICITUD (el alta consulta "estadoSolicitud is null").
DO $$
DECLARE r record; hay_nulos boolean;
BEGIN
  FOR r IN SELECT * FROM (VALUES ('sca2_solicitud','ID_SOLICITUD'), ('sca2_solicitud','NUM_POLIZA'),
                                 ('sca2_solicitud','CREATED_AT'), ('sca2_transicion','ID_SOLICITUD'),
                                 ('sca2_tarea','ID_SOLICITUD'), ('sca2_tarea','ESTADO'),
                                 ('sca2_llamada_servicio','ID_SOLICITUD'),
                                 ('sca2_datos_cabecera','ID_SOLICITUD')) v(tabla, columna)
  LOOP
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema = 'sca2_anulaciones' AND table_name = r.tabla
                  AND column_name = r.columna AND is_nullable = 'NO') THEN
      CONTINUE;
    END IF;
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM sca2_anulaciones.%I WHERE %I IS NULL)', r.tabla, r.columna)
       INTO hay_nulos;
    IF hay_nulos THEN
      RAISE WARNING 'C3: %.% tiene nulos (ver A10); no se aplica NOT NULL', r.tabla, r.columna;
    ELSE
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I SET NOT NULL', r.tabla, r.columna);
      RAISE NOTICE 'C3: NOT NULL en %.%', r.tabla, r.columna;
    END IF;
  END LOOP;
END $$;
-- Rollback C3 (por columna):
--   ALTER TABLE sca2_anulaciones.sca2_solicitud        ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_solicitud        ALTER COLUMN "NUM_POLIZA"   DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_solicitud        ALTER COLUMN "CREATED_AT"   DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_transicion       ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_tarea            ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_tarea            ALTER COLUMN "ESTADO"       DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_llamada_servicio ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;
--   ALTER TABLE sca2_anulaciones.sca2_datos_cabecera   ALTER COLUMN "ID_SOLICITUD" DROP NOT NULL;

-- C4. [MEDIA] Catálogos: UNIQUE de 56-ddl que falten. ux_sca2_cat_tipo_argumento
--     (COD_TP_ARG) no es viable: hay un código repetido activo/inactivo (999). Se
--     sustituye por un UNIQUE parcial solo sobre filas activas (baja lógica).
DO $$
DECLARE r record; hay_dup boolean;
BEGIN
  FOR r IN SELECT * FROM (VALUES
      ('ux_sca2_cat_motivo',  'sca2_cat_motivo',  '"COD_LINEA_NEGOCIO", "COD_PERFIL", "COD_SUB_PERFIL", "COD_MOTIVO"', ''),
      ('ux_sca2_cat_detalle', 'sca2_cat_detalle', '"COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE"', ''),
      ('ux_sca2_cat_causa',   'sca2_cat_causa',   '"COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE", "COD_PERFIL", "COD_CAUSA"', ''),
      ('ux_sca2_cat_tipo_argumento_activo', 'sca2_cat_tipo_argumento', '"COD_TP_ARG"', ' WHERE "ACTIVO"'),
      ('ux_sca2_cat_concepto', 'sca2_cat_concepto', '"IDN_CONCEPTO_PCA"', ''),
      ('ux_sca2_cat_valor_concepto', 'sca2_cat_valor_concepto', '"IDN_CONCEPTO_PCA", "IDN_PCA"', '')
    ) v(indice, tabla, columnas, filtro)
  LOOP
    IF to_regclass('sca2_anulaciones.' || r.indice) IS NOT NULL THEN
      RAISE NOTICE 'C4: % ya existe', r.indice;
      CONTINUE;
    END IF;
    IF r.indice = 'ux_sca2_cat_tipo_argumento_activo'
       AND to_regclass('sca2_anulaciones.ux_sca2_cat_tipo_argumento') IS NOT NULL THEN
      RAISE NOTICE 'C4: ux_sca2_cat_tipo_argumento (completo) ya existe; no hace falta el parcial';
      CONTINUE;
    END IF;
    EXECUTE format('SELECT EXISTS (SELECT 1 FROM sca2_anulaciones.%I%s GROUP BY %s HAVING count(*) > 1)',
                   r.tabla, r.filtro, r.columnas) INTO hay_dup;
    IF hay_dup THEN
      RAISE WARNING 'C4: duplicados en % (ver A8.6); no se crea %', r.tabla, r.indice;
    ELSE
      EXECUTE format('CREATE UNIQUE INDEX %I ON sca2_anulaciones.%I (%s)%s', r.indice, r.tabla, r.columnas, r.filtro);
      RAISE NOTICE 'C4: creado %', r.indice;
    END IF;
  END LOOP;
END $$;
-- Rollback C4 (solo los creados por este script; ver NOTICE):
--   DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_cat_tipo_argumento_activo;
--   (ux_sca2_cat_motivo/detalle/causa/concepto/valor_concepto son del DDL 56: no quitarlos)
