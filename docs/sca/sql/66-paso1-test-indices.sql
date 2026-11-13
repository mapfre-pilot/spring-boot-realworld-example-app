-- =============================================================================
-- 66-paso1-test-indices.sql — Paso 1 tras el bloque A (TEST, 13/11/2026)
-- =============================================================================
-- Contenido: bloque B completo (índices) + C5 y C6 (ampliar dos longitudes).
-- Nada de esto cambia lo que hace la aplicación: los índices solo aceleran
-- lecturas y las ampliaciones de VARCHAR solo permiten guardar textos más largos.
-- NO incluye NOT NULL, UNIQUE ni FK (C1–C4, C7, C8): pueden hacer fallar una
-- escritura de Appian que hoy funciona y van en un paso posterior.
--
-- Resultado del bloque A en TEST (docs/sca/66-indices-bd-sca2.md §9):
--   solo existen las 22 PK y 2 UNIQUE; no hay ningún índice secundario, ni
--   siquiera los de ID_SOLICITUD del DDL 56; no hay vistas (A7 = 0).
--
-- DBeaver (conexión de TEST, nunca PRO):
--   * Barra de herramientas en «Auto-commit» (no «Manual commit»): CREATE INDEX
--     CONCURRENTLY falla dentro de una transacción.
--   * Ejecutar como script: Alt+X (Ejecutar script), no Ctrl+Enter.
--   * Si una sentencia da error, DBeaver pregunta: elegir «Saltar/Skip» y seguir.
--   * Después ejecutar 66-paso1-verificacion-resultado-unico.sql y mandar el JSON.
--   * Se puede repetir entero sin problema (IF NOT EXISTS).
-- Hay que ejecutarlo con el dueño de las tablas (la primera consulta lo muestra:
-- si «puede_crear_indices» sale false, parar y lanzarlo con ese usuario).
-- =============================================================================

SET search_path TO sca2_anulaciones;
SET lock_timeout = '5s';
SET statement_timeout = '15min';

-- P0. Comprobación: dueño de las tablas y si el usuario actual puede crear índices.
SELECT current_user,
       tableowner,
       count(*) AS tablas,
       bool_and(pg_has_role(current_user, tableowner, 'USAGE')) AS puede_crear_indices
  FROM pg_tables
 WHERE schemaname = 'sca2_anulaciones' AND tablename LIKE 'sca2\_%'
 GROUP BY tableowner;

-- B0. Índices por ID_SOLICITUD del DDL 56 (mismos nombres). Solo crean lo que falte
--     en TEST si A3 demuestra que no existen. Sirven a todas las consultas
--     "idSolicitud =" de detalle, procesos CMD y caché.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_cabecera_id_solicitud      ON sca2_anulaciones.sca2_datos_cabecera ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_solicitud_id_solicitud     ON sca2_anulaciones.sca2_datos_solicitud ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_basicos_solicitud_id_solicitud ON sca2_anulaciones.sca2_datos_basicos_solicitud ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_perfiles_pca_id_solicitud  ON sca2_anulaciones.sca2_datos_perfiles_pca ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_productor_id_solicitud     ON sca2_anulaciones.sca2_datos_productor ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_poliza_autos_id_solicitud  ON sca2_anulaciones.sca2_datos_poliza_autos ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_poliza_hogar_id_solicitud  ON sca2_anulaciones.sca2_datos_poliza_hogar ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_datos_poliza_vida_id_solicitud   ON sca2_anulaciones.sca2_datos_poliza_vida ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_niveles_cobertura_autos_id_solicitud ON sca2_anulaciones.sca2_niveles_cobertura_autos ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_otras_solicitudes_cabecera_id_solicitud ON sca2_anulaciones.sca2_otras_solicitudes_cabecera ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_tarea_id_solicitud               ON sca2_anulaciones.sca2_tarea ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_transicion_id_solicitud          ON sca2_anulaciones.sca2_transicion ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_error_id_solicitud               ON sca2_anulaciones.sca2_error ("ID_SOLICITUD");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_llamada_servicio_id_solicitud    ON sca2_anulaciones.sca2_llamada_servicio ("ID_SOLICITUD");
-- Rollback B0: no aplicar (son los índices del DDL 56 de producción).

-- B1. [ALTA] Solicitud por fecha de alta: buscador (orden createdAt DESC, 10 filas,
--     con "not starts with PDTE-") y cuadro de mando (createdAt BETWEEN últimos 90 días).
--     Evita leer y ordenar toda la tabla en cada apertura del buscador.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_solicitud_created_at
    ON sca2_anulaciones.sca2_solicitud ("CREATED_AT" DESC);
-- Rollback B1: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_created_at;

-- B2. [MEDIA] Solicitud por póliza + fecha: alta/contraanulación ("numPoliza =" con
--     orden createdAt DESC), buscador por póliza y batch NSE ("numPoliza in").
--     Cubre lo mismo que ix_sca2_solicitud_num_poliza (56); ese podrá borrarse
--     cuando D2 muestre que este se usa (no se borra en este script).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_solicitud_num_poliza_created_at
    ON sca2_anulaciones.sca2_solicitud ("NUM_POLIZA", "CREATED_AT" DESC);
-- Rollback B2: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_num_poliza_created_at;

-- B3. [BAJA] Barrido de caducidad (SCA2 CMD BarridoCaducidad: caducidadTarea < now()
--     y estado no final). Parcial: solo filas con caducidad informada.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_solicitud_caducidad_tarea
    ON sca2_anulaciones.sca2_solicitud ("CADUCIDAD_TAREA") WHERE "CADUCIDAD_TAREA" IS NOT NULL;
-- Rollback B3: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_solicitud_caducidad_tarea;

-- B4. [MEDIA] Aviso del cuadro de mando: TIPO = 'INDUCCION', ESTADO = 'PENDIENTE',
--     FECHA_CREACION < now() - 1 h, orden FECHA_CREACION ASC. Índice parcial pequeño
--     (solo pendientes): crece con las tareas vivas, no con el histórico.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_tarea_pendiente_tipo_fecha
    ON sca2_anulaciones.sca2_tarea ("TIPO", "FECHA_CREACION") WHERE "ESTADO" = 'PENDIENTE';
-- Rollback B4: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_tarea_pendiente_tipo_fecha;

-- B5. [MEDIA] Tareas por fecha de creación (cuadro de mando, BETWEEN 90 días).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_tarea_fecha_creacion
    ON sca2_anulaciones.sca2_tarea ("FECHA_CREACION");
-- Rollback B5: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_tarea_fecha_creacion;

-- B6. [MEDIA] Transiciones por fecha (cuadro de mando: BETWEEN 90 días, duracionMs).
--     Es la tabla que más crece (≈6,5 filas por solicitud en TEST).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_transicion_fecha
    ON sca2_anulaciones.sca2_transicion ("FECHA");
-- Rollback B6: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_transicion_fecha;

-- B7. [MEDIA] Bandeja de errores: ESTADO = x ORDER BY FECHA_CREACION DESC (paginada).
--     Hace redundante ix_sca2_error_estado (56); no se borra aquí.
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_error_estado_fecha_creacion
    ON sca2_anulaciones.sca2_error ("ESTADO", "FECHA_CREACION" DESC);
-- Rollback B7: DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_error_estado_fecha_creacion;

-- B8. [BAJA] Errores, llamadas y trazabilidad por fecha (cuadro de mando, 90 días).
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_error_fecha_creacion
    ON sca2_anulaciones.sca2_error ("FECHA_CREACION");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_llamada_servicio_fecha_inicio
    ON sca2_anulaciones.sca2_llamada_servicio ("FECHA_INICIO");
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_sca2_trazabilidad_cliente_fecha
    ON sca2_anulaciones.sca2_trazabilidad_cliente ("FECHA");
-- Rollback B8:
--   DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_error_fecha_creacion;
--   DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_llamada_servicio_fecha_inicio;
--   DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ix_sca2_trazabilidad_cliente_fecha;

-- B9. Estadísticas actualizadas para que el planificador use los índices nuevos
--     (ANALYZE no modifica datos). Rollback: no aplica.
ANALYZE sca2_anulaciones.sca2_solicitud;
ANALYZE sca2_anulaciones.sca2_tarea;
ANALYZE sca2_anulaciones.sca2_transicion;
ANALYZE sca2_anulaciones.sca2_error;
ANALYZE sca2_anulaciones.sca2_llamada_servicio;
ANALYZE sca2_anulaciones.sca2_trazabilidad_cliente;
ANALYZE sca2_anulaciones.sca2_datos_cabecera;



-- =============================================================================
-- C5–C6. Longitudes (solo amplían; sin reescritura de tabla)
-- =============================================================================

-- C5. [MEDIA] Longitud: POLIZA_FECHAULTIMOSINIESTRO a VARCHAR(1000) (R46-D, 63-r46d-*.sql
--     sigue pendiente: en TEST la columna es VARCHAR(255) y ya hay valores de 241).
--     Ampliar un VARCHAR en PostgreSQL no reescribe la tabla (bloqueo de milisegundos).
DO $$
BEGIN
  IF (SELECT character_maximum_length FROM information_schema.columns
       WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_datos_cabecera'
         AND column_name = 'POLIZA_FECHAULTIMOSINIESTRO') < 1000 THEN
    ALTER TABLE sca2_anulaciones.sca2_datos_cabecera
      ALTER COLUMN "POLIZA_FECHAULTIMOSINIESTRO" TYPE VARCHAR(1000);
    RAISE NOTICE 'C5: POLIZA_FECHAULTIMOSINIESTRO ampliada a 1000';
  END IF;
END $$;
-- Rollback C5 (solo si ningún valor supera 255):
--   ALTER TABLE sca2_anulaciones.sca2_datos_cabecera ALTER COLUMN "POLIZA_FECHAULTIMOSINIESTRO" TYPE VARCHAR(255);

-- C6. [BAJA] Longitud: CLAVE_IDEMPOTENCIA = COMANDO(60) | ID_SOLICITUD(50) | versión
--     puede superar 120 en teoría (hoy máx. 53). Se amplía a 200 (sin reescritura).
DO $$
BEGIN
  IF (SELECT character_maximum_length FROM information_schema.columns
       WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_transicion'
         AND column_name = 'CLAVE_IDEMPOTENCIA') < 200 THEN
    ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" TYPE VARCHAR(200);
    RAISE NOTICE 'C6: CLAVE_IDEMPOTENCIA ampliada a 200';
  END IF;
END $$;
-- Rollback C6: ALTER TABLE sca2_anulaciones.sca2_transicion ALTER COLUMN "CLAVE_IDEMPOTENCIA" TYPE VARCHAR(120);
