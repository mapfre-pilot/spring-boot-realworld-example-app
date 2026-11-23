-- Preparación del piloto. No aplicar en TEST hasta autorización del responsable de BD.
-- La instalación no mueve datos. Nunca invocar en TEST con IDs antes de la aprobación del lote.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL search_path = pg_catalog;

CREATE OR REPLACE PROCEDURE sca2_anulaciones.sca2_pm_traspasar_historico(
  IN p_ids_permitidos text,
  IN p_ids_dependencias_acreditadas text,
  OUT p_resumen text
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $archivo$
DECLARE
  tablas constant text[] := ARRAY[
    'sca2_solicitud', 'sca2_transicion', 'sca2_tarea', 'sca2_error', 'sca2_llamada_servicio',
    'sca2_datos_cabecera', 'sca2_datos_solicitud', 'sca2_datos_basicos_solicitud',
    'sca2_datos_perfiles_pca', 'sca2_datos_productor', 'sca2_datos_poliza_autos',
    'sca2_datos_poliza_hogar', 'sca2_datos_poliza_vida', 'sca2_niveles_cobertura_autos',
    'sca2_otras_solicitudes_cabecera'
  ];
  terminales constant text[] := ARRAY['FINALIZADA', 'FINALIZADA_POSITIVO', 'CANCELADA', 'CADUCADA'];
  entrada jsonb := COALESCE(NULLIF(btrim(p_ids_permitidos), ''), '[]')::jsonb;
  acreditados jsonb := COALESCE(NULLIF(btrim(p_ids_dependencias_acreditadas), ''), '[]')::jsonb;
  ids text[];
  clave text;
  instante timestamptz := statement_timestamp();
  corte timestamp := (((instante AT TIME ZONE 'Europe/Madrid') - interval '1 month')
      AT TIME ZONE 'Europe/Madrid') AT TIME ZONE 'UTC';
  solicitud sca2_anulaciones.sca2_solicitud%ROWTYPE;
  cierre sca2_anulaciones.sca2_transicion%ROWTYPE;
  estado text;
  indice integer;
  tabla text;
  hist text;
  columnas text;
  columnas_origen text;
  conflicto boolean;
  ya_archivado boolean;
  filas integer;
  claves_borradas jsonb;
  claves_expediente jsonb;
  claves_sync jsonb := '{}'::jsonb;
  ids_archivados text[] := ARRAY[]::text[];
  filas_expediente integer;
  filas_total integer := 0;
  archivados integer := 0;
  repetidos integer := 0;
  excluidos integer := 0;
  conflictos integer := 0;
BEGIN
  IF jsonb_typeof(entrada) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'El lote requiere un array JSON de IDs de solicitud';
  END IF;

  IF jsonb_array_length(entrada) = 0 THEN
    p_resumen := '{"solicitados":0,"archivados":0,"repetidos":0,"excluidos":0,"conflictos":0,"filas":0,"idsArchivados":[],"clavesSync":{}}';
    RETURN;
  END IF;

  IF jsonb_array_length(entrada) > 10 OR EXISTS (
    SELECT 1 FROM jsonb_array_elements(entrada) AS t(valor)
     WHERE jsonb_typeof(valor) <> 'string'
        OR length(valor #>> '{}') NOT BETWEEN 1 AND 50
        OR (valor #>> '{}') IN ('', '0')
        OR (valor #>> '{}') LIKE 'PDTE-%'
        OR btrim(valor #>> '{}') IS DISTINCT FROM (valor #>> '{}')
  ) THEN
    RAISE EXCEPTION 'Lote inválido: se admiten de 1 a 10 IDs de solicitud definitivos';
  END IF;

  IF jsonb_typeof(acreditados) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'La acreditación requiere un array JSON de IDs de solicitud';
  END IF;

  SELECT array_agg(DISTINCT valor ORDER BY valor) INTO ids
    FROM jsonb_array_elements_text(entrada) AS t(valor);

  -- El piloto no conoce aún un bloqueo cooperativo de todos los escritores.
  -- NOWAIT abandona el lote si ya hay otro escritor y cubre inserciones de hijas sin FK.
  IF NOT pg_try_advisory_xact_lock(619431, 71) THEN
    RAISE EXCEPTION 'Ya hay otra operación de archivo SCA2 en curso' USING ERRCODE = '55P03';
  END IF;
  FOREACH tabla IN ARRAY tablas LOOP
    EXECUTE format('LOCK TABLE sca2_anulaciones.%I, sca2_anulaciones.%I IN SHARE ROW EXCLUSIVE MODE NOWAIT',
                   tabla, tabla || '_hist');
  END LOOP;
  LOCK TABLE sca2_anulaciones.sca2_reintento_fin IN SHARE MODE NOWAIT;

  FOREACH clave IN ARRAY ids LOOP
    SELECT * INTO solicitud FROM sca2_anulaciones.sca2_solicitud WHERE "ID_SOLICITUD" = clave;
    IF NOT FOUND THEN
      SELECT EXISTS (
        SELECT 1 FROM sca2_anulaciones.sca2_solicitud_hist WHERE "ID_SOLICITUD" = clave
      ) INTO ya_archivado;
      IF ya_archivado THEN
        FOREACH tabla IN ARRAY tablas LOOP
          EXECUTE format('SELECT EXISTS (SELECT 1 FROM sca2_anulaciones.%I WHERE "ID_SOLICITUD" = $1)', tabla)
            INTO conflicto USING clave;
          IF conflicto THEN EXIT; END IF;
        END LOOP;
        IF conflicto THEN conflictos := conflictos + 1;
        ELSE repetidos := repetidos + 1;
        END IF;
      ELSE
        excluidos := excluidos + 1;
      END IF;
      CONTINUE;
    END IF;

    estado := upper(COALESCE(solicitud."ESTADO_SOLICITUD", ''));
    SELECT * INTO cierre FROM sca2_anulaciones.sca2_transicion
     WHERE "ID_SOLICITUD" = clave AND "RESULTADO" = 'OK'
       AND NULLIF("ESTADO_ORIGEN", '') IS NOT NULL AND NULLIF("ESTADO_DESTINO", '') IS NOT NULL
       AND "ESTADO_ORIGEN" <> "ESTADO_DESTINO"
     ORDER BY "FECHA" DESC NULLS FIRST, "ID" DESC LIMIT 1;

    IF NOT (acreditados ? clave) OR NOT (estado = ANY(terminales)) OR cierre."FECHA" IS NULL
       OR cierre."ESTADO_DESTINO" IS DISTINCT FROM estado OR cierre."FECHA" >= corte
       OR NULLIF(btrim(solicitud."PROCESO_ACTIVO"), '') IS NOT NULL
       OR NULLIF(btrim(solicitud."NODO_RELANZAR"), '') IS NOT NULL
       OR EXISTS (
         SELECT 1 FROM sca2_anulaciones.sca2_tarea WHERE "ID_SOLICITUD" = clave
          AND ("FECHA_CIERRE" IS NULL OR upper(COALESCE("ESTADO", ''))
                NOT IN ('COMPLETADA', 'FINALIZADA', 'CANCELADA'))
       ) OR EXISTS (
         SELECT 1 FROM sca2_anulaciones.sca2_error WHERE "ID_SOLICITUD" = clave
          AND ("FECHA_RESOLUCION" IS NULL OR upper(COALESCE("ESTADO", '')) NOT IN ('RESUELTO', 'DESCARTADO'))
       ) OR EXISTS (
         SELECT 1 FROM sca2_anulaciones.sca2_llamada_servicio WHERE "ID_SOLICITUD" = clave AND "FECHA_FIN" IS NULL
       ) OR EXISTS (
         SELECT 1 FROM sca2_anulaciones.sca2_transicion WHERE "ID_SOLICITUD" = clave AND "RESULTADO" = 'OK'
          AND upper("ESTADO_ORIGEN") = ANY(terminales) AND NULLIF("ESTADO_DESTINO", '') IS NOT NULL
          AND NOT (upper("ESTADO_DESTINO") = ANY(terminales))
       ) OR EXISTS (
         SELECT 1 FROM sca2_anulaciones.sca2_reintento_fin r WHERE r.id_solicitud = clave
          AND r.estado IN ('PENDIENTE', 'AGOTADO')
       ) THEN
      excluidos := excluidos + 1;
      CONTINUE;
    END IF;

    -- Subtransacción: una colisión revierte la unidad completa, nunca borra media solicitud.
    filas_expediente := 0;
    claves_expediente := '{}'::jsonb;
    BEGIN
      FOREACH tabla IN ARRAY tablas LOOP
        hist := tabla || '_hist';
        SELECT string_agg(format('%I', attname), ', ' ORDER BY attnum),
               string_agg(format('v.%I', attname), ', ' ORDER BY attnum)
          INTO columnas, columnas_origen FROM pg_attribute
         WHERE attrelid = format('sca2_anulaciones.%I', tabla)::regclass
           AND attnum > 0 AND NOT attisdropped;
        EXECUTE format(
          'SELECT EXISTS (
             SELECT 1 FROM sca2_anulaciones.%I v JOIN sca2_anulaciones.%I h USING ("ID")
              WHERE v."ID_SOLICITUD" = $1
                AND (to_jsonb(h) - ''FECHA_ARCHIVADO'') IS DISTINCT FROM to_jsonb(v)
             UNION ALL
             SELECT 1 FROM sca2_anulaciones.%I h WHERE h."ID_SOLICITUD" = $1 AND NOT EXISTS
              (SELECT 1 FROM sca2_anulaciones.%I v WHERE v."ID" = h."ID" AND v."ID_SOLICITUD" = $1)
           )', tabla, hist, hist, tabla) INTO conflicto USING clave;
        IF conflicto THEN
          RAISE unique_violation USING MESSAGE = 'Histórico en conflicto con el expediente vivo';
        END IF;
        EXECUTE format(
          'INSERT INTO sca2_anulaciones.%I (%s, "FECHA_ARCHIVADO")
           SELECT %s, $2 FROM sca2_anulaciones.%I v WHERE v."ID_SOLICITUD" = $1
           ON CONFLICT ("ID") DO NOTHING', hist, columnas, columnas_origen, tabla)
           USING clave, instante;
      END LOOP;

      FOR indice IN REVERSE cardinality(tablas)..1 LOOP
        tabla := tablas[indice];
        EXECUTE format(
          'WITH borradas AS (DELETE FROM sca2_anulaciones.%I WHERE "ID_SOLICITUD" = $1 RETURNING "ID")
           SELECT count(*), COALESCE(jsonb_agg("ID" ORDER BY "ID"), ''[]''::jsonb) FROM borradas',
          tabla
        ) INTO filas, claves_borradas USING clave;
        IF filas > 0 THEN
          claves_expediente := claves_expediente || jsonb_build_object(tabla, claves_borradas);
        END IF;
        filas_expediente := filas_expediente + filas;
      END LOOP;
      FOR tabla, claves_borradas IN SELECT key, value FROM jsonb_each(claves_expediente) LOOP
        claves_sync := jsonb_set(claves_sync, ARRAY[tabla],
          COALESCE(claves_sync -> tabla, '[]'::jsonb) || claves_borradas);
      END LOOP;
      ids_archivados := array_append(ids_archivados, clave);
      archivados := archivados + 1;
      filas_total := filas_total + filas_expediente;
    EXCEPTION WHEN unique_violation THEN
      conflictos := conflictos + 1;
    END;
  END LOOP;

  p_resumen := jsonb_build_object(
    'solicitados', cardinality(ids), 'archivados', archivados, 'repetidos', repetidos,
    'excluidos', excluidos, 'conflictos', conflictos, 'filas', filas_total,
    'idsArchivados', ids_archivados, 'clavesSync', claves_sync
  )::text;
END
$archivo$;

REVOKE ALL ON PROCEDURE sca2_anulaciones.sca2_pm_traspasar_historico(text, text) FROM PUBLIC;

COMMIT;
