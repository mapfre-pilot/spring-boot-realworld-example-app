-- SCA2 TEST · Aurora PostgreSQL 14 · ejecutar como propietario de sca2_anulaciones.
-- DBeaver: ejecutar el script completo (Alt+X) con parada ante error.
-- La primera instalación deja el worker desactivado; reinstalar conserva el ajuste.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;

CREATE TABLE IF NOT EXISTS sca2_anulaciones.sca2_reintento_fin_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
  habilitado boolean NOT NULL DEFAULT false
);
INSERT INTO sca2_anulaciones.sca2_reintento_fin_config (singleton)
VALUES (true) ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS sca2_anulaciones.sca2_reintento_fin (
  id_error integer NOT NULL,
  id_solicitud varchar(50) NOT NULL,
  version_origen integer NOT NULL CHECK (version_origen >= 0),
  estado_origen varchar(40),
  estado_final varchar(40) NOT NULL CHECK (estado_final <> ''),
  proceso_original integer NOT NULL,
  estado varchar(16) NOT NULL DEFAULT 'PENDIENTE'
    CHECK (estado IN ('PENDIENTE', 'RECUPERADO', 'MANUAL', 'OMITIDO', 'AGOTADO')),
  intentos smallint NOT NULL DEFAULT 0 CHECK (intentos BETWEEN 0 AND 3),
  proximo_intento timestamp NOT NULL,
  ultimo_intento timestamp,
  ultimo_error varchar(5),
  PRIMARY KEY (id_error, version_origen),
  UNIQUE (id_solicitud, version_origen)
);
CREATE INDEX IF NOT EXISTS ix_sca2_reintento_fin_pendiente
  ON sca2_anulaciones.sca2_reintento_fin (proximo_intento, id_error)
  WHERE estado = 'PENDIENTE';

CREATE TABLE IF NOT EXISTS sca2_anulaciones.sca2_reintento_fin_veto_manual (
  id_error integer PRIMARY KEY
);

-- Invocar solo tras Write Error correcto y con éxito externo confirmado por
-- la instancia original. No reconstruir esta evidencia a partir de logs.
CREATE OR REPLACE FUNCTION sca2_anulaciones.sca2_capturar_reintento_fin(
  p_id_error integer, p_id_solicitud text, p_version_origen integer, p_estado_origen text,
  p_estado_final text, p_proceso_original integer, p_inicio timestamp,
  p_pca_confirmado boolean, p_sgc_confirmado_o_no_aplica boolean
) RETURNS boolean
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $$
BEGIN
  IF p_pca_confirmado IS DISTINCT FROM true
     OR p_sgc_confirmado_o_no_aplica IS DISTINCT FROM true
     OR NULLIF(btrim(p_estado_final), '') IS NULL
     OR p_inicio IS NULL OR p_id_error IS NULL THEN
    RETURN false;
  END IF;

  PERFORM pg_advisory_xact_lock(619430, p_id_error);
  IF EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_reintento_fin_veto_manual WHERE id_error = p_id_error)
    THEN RETURN false;
  END IF;

  INSERT INTO sca2_anulaciones.sca2_reintento_fin
    (id_error, id_solicitud, version_origen, estado_origen, estado_final, proceso_original, proximo_intento)
  SELECT e."ID", s."ID_SOLICITUD", p_version_origen, p_estado_origen, p_estado_final,
         p_proceso_original,
         GREATEST(e."PROXIMO_INTENTO", statement_timestamp() AT TIME ZONE 'UTC' + interval '30 minutes')
  FROM sca2_anulaciones.sca2_solicitud s
  JOIN sca2_anulaciones.sca2_error e USING ("ID_SOLICITUD")
  WHERE e."ID" = p_id_error AND s."ID_SOLICITUD" = p_id_solicitud
    AND s."VERSION" = p_version_origen + 1
    AND s."ESTADO_SOLICITUD" = 'ERROR' AND s."NODO_RELANZAR" = 'Finalizar PCA'
    AND e."COMANDO" = 'SCA2 CMD Finalizar' AND e."NODO" = 'Write FINALIZADA'
    AND e."CODIGO" = 'WRITE_FAIL' AND e."ESTADO" = 'PENDIENTE'
    AND e."FECHA_CREACION" >= p_inicio
  ON CONFLICT DO NOTHING;
  RETURN FOUND;
END;
$$;

-- Salidas: NORMAL = flujo actual, LANZAR = marca equivalente ya persistida,
-- OMITIR = el automático ya cerró o el mismo error ya está reservado.
CREATE OR REPLACE FUNCTION sca2_anulaciones.sca2_reservar_manual_fin(
  p_id_error integer, p_id_solicitud text, p_usuario text
) RETURNS text
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $$
DECLARE
  v sca2_anulaciones.sca2_reintento_fin%ROWTYPE;
BEGIN
  IF p_id_error IS NULL THEN RETURN 'NORMAL'; END IF;
  PERFORM pg_advisory_xact_lock(619430, p_id_error);
  SELECT * INTO v
  FROM sca2_anulaciones.sca2_reintento_fin
  WHERE id_error = p_id_error AND id_solicitud = p_id_solicitud
  ORDER BY version_origen DESC LIMIT 1
  FOR UPDATE;
  IF v.estado IN ('RECUPERADO', 'MANUAL') THEN RETURN 'OMITIR'; END IF;
  IF v.id_error IS NULL
     OR NOT COALESCE((SELECT habilitado FROM sca2_anulaciones.sca2_reintento_fin_config WHERE singleton), false)
     OR v.estado IN ('OMITIDO', 'AGOTADO') THEN
    -- Si el manual llega antes de la captura, su decisión prevalece aunque la
    -- escritura normal de Appian aún no haya marcado el error RELANZADO.
    INSERT INTO sca2_anulaciones.sca2_reintento_fin_veto_manual (id_error)
    SELECT "ID" FROM sca2_anulaciones.sca2_error
    WHERE "ID" = p_id_error AND "ID_SOLICITUD" = p_id_solicitud
      AND "COMANDO" = 'SCA2 CMD Finalizar' AND "NODO" = 'Write FINALIZADA'
      AND "CODIGO" = 'WRITE_FAIL' AND "ESTADO" = 'PENDIENTE'
    ON CONFLICT DO NOTHING;
    RETURN 'NORMAL';
  END IF;
  UPDATE sca2_anulaciones.sca2_error
  SET "ESTADO" = 'RELANZADO', "RESUELTO_POR" = p_usuario,
      "FECHA_RESOLUCION" = statement_timestamp() AT TIME ZONE 'UTC'
  WHERE "ID" = v.id_error AND "ID_SOLICITUD" = v.id_solicitud
    AND "COMANDO" = 'SCA2 CMD Finalizar' AND "CODIGO" = 'WRITE_FAIL'
    AND "ESTADO" = 'PENDIENTE';
  IF NOT FOUND THEN RETURN 'NORMAL'; END IF;

  UPDATE sca2_anulaciones.sca2_reintento_fin SET estado = 'MANUAL'
  WHERE id_error = v.id_error AND version_origen = v.version_origen;
  RETURN 'LANZAR';
END;
$$;

CREATE OR REPLACE FUNCTION sca2_anulaciones.sca2_ejecutar_reintento_fin(
  p_usuario text, p_proceso integer, p_invalidar_cache boolean
) RETURNS jsonb
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $$
DECLARE
  v sca2_anulaciones.sca2_reintento_fin%ROWTYPE;
  s sca2_anulaciones.sca2_solicitud%ROWTYPE;
  e sca2_anulaciones.sca2_error%ROWTYPE;
  v_ahora timestamp := statement_timestamp() AT TIME ZONE 'UTC';
  v_clave text;
  v_transicion integer;
  v_cache integer[];
  v_resultados jsonb := '[]'::jsonb;
BEGIN
  IF NOT COALESCE((SELECT habilitado FROM sca2_anulaciones.sca2_reintento_fin_config WHERE singleton), false)
    THEN RETURN v_resultados;
  END IF;

  FOR v IN
    SELECT * FROM sca2_anulaciones.sca2_reintento_fin
    WHERE estado = 'PENDIENTE' AND proximo_intento <= v_ahora
    ORDER BY proximo_intento, id_error
    LIMIT 25 FOR UPDATE SKIP LOCKED
  LOOP
    -- No esperar un lock asesor mientras se tiene el lock de la fila.
    IF NOT pg_try_advisory_xact_lock(619430, v.id_error) THEN CONTINUE; END IF;
    SELECT * INTO e FROM sca2_anulaciones.sca2_error WHERE "ID" = v.id_error FOR UPDATE;
    SELECT * INTO s FROM sca2_anulaciones.sca2_solicitud WHERE "ID_SOLICITUD" = v.id_solicitud FOR UPDATE;
    v_clave := 'SCA2 CMD Finalizar|' || v.id_solicitud || '|' || v.version_origen;
    IF s."VERSION" IS DISTINCT FROM v.version_origen + 1
       OR s."ESTADO_SOLICITUD" IS DISTINCT FROM 'ERROR'
       OR s."NODO_RELANZAR" IS DISTINCT FROM 'Finalizar PCA'
       OR e."ID_SOLICITUD" IS DISTINCT FROM v.id_solicitud
       OR e."COMANDO" IS DISTINCT FROM 'SCA2 CMD Finalizar'
       OR e."NODO" IS DISTINCT FROM 'Write FINALIZADA'
       OR e."CODIGO" IS DISTINCT FROM 'WRITE_FAIL'
       OR e."ESTADO" IS DISTINCT FROM 'PENDIENTE'
       OR EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_transicion WHERE "CLAVE_IDEMPOTENCIA" = v_clave)
       OR EXISTS (SELECT 1 FROM sca2_anulaciones.sca2_reintento_fin_veto_manual WHERE id_error = v.id_error)
    THEN
      UPDATE sca2_anulaciones.sca2_reintento_fin SET estado = 'OMITIDO'
      WHERE id_error = v.id_error AND version_origen = v.version_origen;
      CONTINUE;
    END IF;
    IF e."PROXIMO_INTENTO" > v_ahora THEN
      UPDATE sca2_anulaciones.sca2_reintento_fin SET proximo_intento = e."PROXIMO_INTENTO"
      WHERE id_error = v.id_error AND version_origen = v.version_origen;
      CONTINUE;
    END IF;

    UPDATE sca2_anulaciones.sca2_reintento_fin
    SET intentos = intentos + 1, ultimo_intento = v_ahora, ultimo_error = NULL
    WHERE id_error = v.id_error AND version_origen = v.version_origen;

    -- Si falla alguna escritura, se revierte este bloque entero, no el contador.
    BEGIN
      UPDATE sca2_anulaciones.sca2_solicitud
      SET "ESTADO_SOLICITUD" = v.estado_final, "VERSION" = s."VERSION" + 1,
          "MODIFIED_AT" = v_ahora, "MODIFIED_BY" = p_usuario,
          "INTERFAZ_ACTIVA" = 'FIN', "ESTADO_TAREA" = 'COMPLETADA',
          "PROCESO_ACTIVO" = NULL, "NODO_RELANZAR" = NULL, "ERROR" = NULL
      WHERE "ID" = s."ID";

      INSERT INTO sca2_anulaciones.sca2_transicion
        ("ID_SOLICITUD", "COMANDO", "ESTADO_ORIGEN", "ESTADO_DESTINO", "CLAVE_IDEMPOTENCIA",
         "RESULTADO", "DETALLE", "PROCESS_ID", "USUARIO", "FECHA")
      VALUES (v.id_solicitud, 'SCA2 CMD Finalizar', v.estado_origen, v.estado_final, v_clave,
              'OK', 'Recuperación automática local', p_proceso, p_usuario, v_ahora)
      RETURNING "ID" INTO v_transicion;

      v_cache := '{}';
      IF p_invalidar_cache IS TRUE AND v.id_solicitud NOT IN ('', '0') THEN
        WITH caducadas AS (
          UPDATE sca2_anulaciones.sca2_datos_cabecera SET "VALIDA_HASTA" = v_ahora
          WHERE "ID_SOLICITUD" = v.id_solicitud AND "ORIGEN_CACHE" = 'CACHE' AND "VALIDA_HASTA" > v_ahora
          RETURNING "ID"
        ) SELECT COALESCE(array_agg("ID"), '{}') INTO v_cache FROM caducadas;
      END IF;

      UPDATE sca2_anulaciones.sca2_error
      SET "ESTADO" = 'RELANZADO', "RESUELTO_POR" = p_usuario, "FECHA_RESOLUCION" = v_ahora
      WHERE "ID" = v.id_error;

      UPDATE sca2_anulaciones.sca2_reintento_fin SET estado = 'RECUPERADO'
      WHERE id_error = v.id_error AND version_origen = v.version_origen;
      v_resultados := v_resultados || jsonb_build_array(jsonb_build_object(
        'solicitud', s."ID", 'error', v.id_error, 'transicion', v_transicion, 'cache', v_cache
      ));
    EXCEPTION WHEN OTHERS THEN
      UPDATE sca2_anulaciones.sca2_reintento_fin
      SET estado = CASE WHEN intentos >= 3 THEN 'AGOTADO' ELSE 'PENDIENTE' END,
          proximo_intento = v_ahora + interval '30 minutes', ultimo_error = SQLSTATE
      WHERE id_error = v.id_error AND version_origen = v.version_origen;
    END;
  END LOOP;
  RETURN v_resultados;
END;
$$;

REVOKE ALL ON FUNCTION sca2_anulaciones.sca2_capturar_reintento_fin(integer, text, integer, text, text, integer, timestamp, boolean, boolean) FROM PUBLIC;
REVOKE ALL ON FUNCTION sca2_anulaciones.sca2_reservar_manual_fin(integer, text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION sca2_anulaciones.sca2_ejecutar_reintento_fin(text, integer, boolean) FROM PUBLIC;

-- Adaptadores JDBC para Execute Stored Procedure de Appian (los números con
-- validación desactivada se enlazan como BIGINT). Las salidas son texto simple.
CREATE OR REPLACE PROCEDURE sca2_anulaciones.sca2_pm_capturar_reintento_fin(
  IN id_error bigint, IN id_solicitud text, IN version_origen bigint, IN estado_origen text,
  IN estado_final text, IN proceso_original bigint, IN inicio_utc text,
  IN pca_confirmado boolean, IN sgc_confirmado_o_no_aplica boolean,
  OUT salida text
)
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $$
BEGIN
  salida := sca2_anulaciones.sca2_capturar_reintento_fin(
    id_error::integer, id_solicitud, version_origen::integer, estado_origen, estado_final,
    proceso_original::integer, inicio_utc::timestamp,
    pca_confirmado, sgc_confirmado_o_no_aplica
  )::text;
END;
$$;

CREATE OR REPLACE PROCEDURE sca2_anulaciones.sca2_pm_reservar_manual_fin(
  IN id_error bigint, IN id_solicitud text, IN usuario text, OUT salida text
)
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $$
BEGIN
  salida := sca2_anulaciones.sca2_reservar_manual_fin(id_error::integer, id_solicitud, usuario);
END;
$$;

CREATE OR REPLACE PROCEDURE sca2_anulaciones.sca2_pm_ejecutar_reintento_fin(
  IN usuario text, IN proceso bigint, IN invalidar_cache boolean, OUT salida text
)
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $$
BEGIN
  salida := sca2_anulaciones.sca2_ejecutar_reintento_fin(usuario, proceso::integer, invalidar_cache)::text;
END;
$$;

REVOKE ALL ON PROCEDURE sca2_anulaciones.sca2_pm_capturar_reintento_fin(bigint, text, bigint, text, text, bigint, text, boolean, boolean) FROM PUBLIC;
REVOKE ALL ON PROCEDURE sca2_anulaciones.sca2_pm_reservar_manual_fin(bigint, text, text) FROM PUBLIC;
REVOKE ALL ON PROCEDURE sca2_anulaciones.sca2_pm_ejecutar_reintento_fin(text, bigint, boolean) FROM PUBLIC;

COMMIT;

SELECT habilitado FROM sca2_anulaciones.sca2_reintento_fin_config WHERE singleton;
