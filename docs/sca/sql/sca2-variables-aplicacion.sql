-- SCA2 TEST · PostgreSQL 14 · ejecutar en DBeaver con parada al primer error.
-- Crea el catálogo y su auditoría. No activa consumidores ni modifica filas SCA/CORE.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog;

SELECT pg_advisory_xact_lock(619431, 79);

DO $guardia$
DECLARE
  nombre text;
  objeto regclass;
  rutina regprocedure := to_regprocedure(
    'sca2_anulaciones.sca2_guardar_variable_aplicacion(text,text,integer,text)'
  );
  marca CONSTANT text := 'SCA2-VARIABLES-79: v1';
  existentes integer := 0;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class
    WHERE oid = to_regclass('sca2_anulaciones.sca2_solicitud') AND relkind = 'r'
  ) THEN
    RAISE EXCEPTION 'Falta sca2_anulaciones.sca2_solicitud: compruebe la conexión';
  END IF;

  FOREACH nombre IN ARRAY ARRAY['sca2_variable_aplicacion', 'sca2_variable_aplicacion_hist'] LOOP
    objeto := to_regclass(format('sca2_anulaciones.%I', nombre));
    IF objeto IS NOT NULL THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_class
        WHERE oid = objeto AND relkind = 'r' AND relowner = current_user::regrole
          AND obj_description(oid, 'pg_class') = marca
      ) THEN
        RAISE EXCEPTION 'Tabla % no reconocida o con dueño distinto', nombre;
      END IF;
      existentes := existentes + 1;
    END IF;
  END LOOP;

  IF rutina IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_proc
      WHERE oid = rutina AND prokind = 'f' AND proowner = current_user::regrole
        AND obj_description(oid, 'pg_proc') = marca
    ) THEN
      RAISE EXCEPTION 'Rutina % no reconocida o con dueño distinto', rutina;
    END IF;
    existentes := existentes + 1;
  END IF;

  IF existentes NOT IN (0, 3) THEN
    RAISE EXCEPTION 'Migración de variables incompleta: se esperaban cero o tres objetos';
  END IF;
END
$guardia$;

CREATE TABLE IF NOT EXISTS sca2_anulaciones.sca2_variable_aplicacion (
  codigo text PRIMARY KEY CHECK (codigo ~ '^[A-Z][A-Z0-9_]*$'),
  valor text NOT NULL,
  tipo text NOT NULL CHECK (tipo IN ('BOOLEANO', 'ENTERO', 'FECHA', 'TEXTO')),
  descripcion text NOT NULL,
  grupo text NOT NULL,
  revision integer NOT NULL DEFAULT 0 CHECK (revision >= 0),
  fecha_modificacion timestamptz NOT NULL DEFAULT clock_timestamp(),
  usuario_modificacion text NOT NULL DEFAULT 'MIGRACION' CHECK (btrim(usuario_modificacion) <> ''),
  CHECK (CASE tipo
    WHEN 'BOOLEANO' THEN valor IN ('true', 'false')
    WHEN 'ENTERO' THEN valor ~ '^(0|[1-9][0-9]{0,9})$' AND valor::numeric <= 2147483647
    WHEN 'FECHA' THEN valor ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' AND valor::date IS NOT NULL
    WHEN 'TEXTO' THEN btrim(valor) <> ''
  END)
);

CREATE TABLE IF NOT EXISTS sca2_anulaciones.sca2_variable_aplicacion_hist (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo text NOT NULL REFERENCES sca2_anulaciones.sca2_variable_aplicacion(codigo),
  revision integer NOT NULL CHECK (revision > 0),
  valor_anterior text NOT NULL,
  valor_nuevo text NOT NULL CHECK (valor_nuevo <> valor_anterior),
  fecha_modificacion timestamptz NOT NULL,
  usuario_modificacion text NOT NULL CHECK (btrim(usuario_modificacion) <> ''),
  UNIQUE (codigo, revision)
);

COMMENT ON TABLE sca2_anulaciones.sca2_variable_aplicacion IS 'SCA2-VARIABLES-79: v1';
COMMENT ON TABLE sca2_anulaciones.sca2_variable_aplicacion_hist IS 'SCA2-VARIABLES-79: v1';
REVOKE ALL ON sca2_anulaciones.sca2_variable_aplicacion, sca2_anulaciones.sca2_variable_aplicacion_hist FROM PUBLIC;

CREATE OR REPLACE FUNCTION sca2_anulaciones.sca2_guardar_variable_aplicacion(
  p_codigo text, p_valor text, p_revision integer, p_usuario text
) RETURNS integer
LANGUAGE plpgsql
SET search_path = pg_catalog
AS $guardar$
DECLARE
  anterior sca2_anulaciones.sca2_variable_aplicacion%ROWTYPE;
  instante timestamptz;
BEGIN
  IF p_codigo IS NULL OR p_valor IS NULL OR p_revision IS NULL OR
     p_usuario IS NULL OR btrim(p_usuario) = '' THEN
    RAISE EXCEPTION 'Faltan datos de la edición';
  END IF;

  SELECT * INTO STRICT anterior
  FROM sca2_anulaciones.sca2_variable_aplicacion
  WHERE codigo = p_codigo
  FOR UPDATE;

  IF anterior.revision <> p_revision THEN
    RAISE EXCEPTION 'La variable cambió; vuelva a cargarla' USING ERRCODE = '40001';
  END IF;
  IF anterior.valor = p_valor THEN
    RETURN anterior.revision;
  END IF;

  instante := clock_timestamp();
  UPDATE sca2_anulaciones.sca2_variable_aplicacion
  SET valor = p_valor, revision = anterior.revision + 1,
      fecha_modificacion = instante, usuario_modificacion = p_usuario
  WHERE codigo = p_codigo;

  INSERT INTO sca2_anulaciones.sca2_variable_aplicacion_hist
    (codigo, revision, valor_anterior, valor_nuevo, fecha_modificacion, usuario_modificacion)
  VALUES (p_codigo, anterior.revision + 1, anterior.valor, p_valor, instante, p_usuario);

  RETURN anterior.revision + 1;
END
$guardar$;

COMMENT ON FUNCTION sca2_anulaciones.sca2_guardar_variable_aplicacion(text,text,integer,text)
  IS 'SCA2-VARIABLES-79: v1';
REVOKE ALL ON FUNCTION sca2_anulaciones.sca2_guardar_variable_aplicacion(text,text,integer,text) FROM PUBLIC;

-- Valores observados en Appian TEST. Volver a cotejarlos antes de la primera carga.
-- No cargar credenciales, destinos internos, valores CORE compartidos ni temporizadores.
INSERT INTO sca2_anulaciones.sca2_variable_aplicacion (codigo, valor, tipo, descripcion, grupo)
VALUES
  ('USAR_CACHE_CABECERA','true','BOOLEANO','Usar caché de cabecera','Caché'),
  ('USAR_WEBAPI_CACHE_CABECERA','true','BOOLEANO','Usar Web API en la lectura de cabecera','Caché'),
  ('HORA_CADUCIDAD_CACHE_CABECERA','5','ENTERO','Hora local de caducidad de caché','Caché'),
  ('ZONA_HORARIA_CACHE_CABECERA','Europe/Madrid','TEXTO','Zona horaria de la caché de cabecera','Caché'),
  ('CACHE_REFRESCO_BATCH','50','ENTERO','Filas por lote de refresco de caché','Caché'),
  ('RECORTAR_FILA_CACHE_CABECERA','true','BOOLEANO','Ajustar la fila a los límites de la caché','Caché'),
  ('USAR_TOKEN_CACHE_APICLIENTS','true','BOOLEANO','Reutilizar token de API Clients','Caché'),
  ('USAR_PROPIETARIO_APPIAN','true','BOOLEANO','Resolver propietario en Appian','Decisión'),
  ('USAR_CATALOGOS_AURORA','true','BOOLEANO','Leer catálogos de Aurora cuando corresponda','Decisión'),
  ('USAR_POLIZA_RENOVADA_UNICA','true','BOOLEANO','Usar cálculo de póliza renovada única','Decisión'),
  ('USAR_GESTION_PRECARGADA_BUSCADOR','true','BOOLEANO','Reutilizar gestión precargada en buscador','Decisión'),
  ('ESPERA_DECISION_INICIAL_SEGUNDOS','30','ENTERO','Espera inicial de decisión','Decisión'),
  ('ESPERA_DECISION_SONDEO_SEGUNDOS','30','ENTERO','Intervalo de actualización de decisión','Decisión'),
  ('ESPERA_AGOTADA_SEGUNDOS','90','ENTERO','Tiempo para mostrar espera de decisión agotada','Decisión'),
  ('DIAS_CADUCIDAD_PROPIETARIO','14','ENTERO','Plazo del cálculo por nivel para propietario','Caducidad'),
  ('DIAS_CADUCIDAD_NO_PROPIETARIO','7','ENTERO','Plazo del cálculo por nivel para no propietario','Caducidad'),
  ('DIAS_CADUCIDAD_POSPUESTA','7','ENTERO','Días naturales por cada posposición','Caducidad'),
  ('LIMITE_DOCUMENTO_BYTES','52428800','ENTERO','Límite por archivo en bytes','Documentos'),
  ('BATCH_NSE','false','BOOLEANO','Interruptor del batch de mecanización NSE','Batch'),
  ('BATCH_RESERVA_PRIMA','false','BOOLEANO','Interruptor del batch de reserva de prima','Batch'),
  ('REINTENTO_FIN_ACTIVO','true','BOOLEANO','Interruptor Appian de reintento de finalización','Batch'),
  ('ESPERA_NSE_FINALIZAR_MAX_INTENTOS','10','ENTERO','Intentos de espera NSE al finalizar','Batch'),
  ('USAR_OBSERVABILIDAD','true','BOOLEANO','Registro operativo de llamadas y procesos','Observabilidad'),
  ('FECHA_INICIO_DATOS','2026-09-24','FECHA','Fecha inicial de datos del cuadro de mando','Observabilidad')
ON CONFLICT (codigo) DO NOTHING;

COMMIT;
