-- 77 · SCA2 · Tabla de ejecuciones de argumento (Cuadro de Gestión, opción A) · Aurora PostgreSQL 14.
-- Confirma la conexión a la BD SCA2 y los permisos para SET ROLE user_sca2_anulaciones:
-- la tabla queda a nombre del usuario con el que accede Appian.
-- DBeaver: ejecutar el script completo (Alt+X), con parada al primer error. Primero en TEST.
-- Solo crea objetos nuevos: no altera tablas existentes ni mueve datos. Se puede relanzar.
-- Una fila por argumento cerrado en positivo o negativo; la graba SCA2 CMD CompletarAccion.
-- Rollback: DROP TABLE sca2_anulaciones.sca2_ejecucion_argumento; (con el mismo rol)
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog;

SELECT pg_advisory_xact_lock(619431, 77);

DO $script$
DECLARE
  marca constant text := 'SCA2-77: ejecuciones de argumento (Cuadro de Gestión) v1';
  tabla regclass;
BEGIN
  IF to_regclass('sca2_anulaciones.sca2_solicitud') IS NULL THEN
    RAISE EXCEPTION 'No existe sca2_anulaciones.sca2_solicitud: la conexión no es la BD de SCA2';
  END IF;

  tabla := to_regclass('sca2_anulaciones.sca2_ejecucion_argumento');
  IF tabla IS NULL THEN
    CREATE TABLE sca2_anulaciones.sca2_ejecucion_argumento (
      "ID" SERIAL PRIMARY KEY,
      "ID_SOLICITUD" VARCHAR(50) NOT NULL,
      "ID_TAREA" INTEGER,
      "NUM_POLIZA" VARCHAR(30),
      "LINEA_NEGOCIO" INTEGER,
      "COD_TP_ARG" VARCHAR(5),
      "DESC_ARG" VARCHAR(100),
      "COD_ID_CAMPANA" VARCHAR(30),
      "RESULTADO" VARCHAR(10) NOT NULL,
      "MCA_ESTADO_FINAL" VARCHAR(5),
      "MCA_ECONOMICO" VARCHAR(1),
      "MCA_REGATEABLE" VARCHAR(1),
      "NUM_TREBOLES" INTEGER,
      "PERFIL_USUARIO" VARCHAR(30),
      "USUARIO" VARCHAR(100),
      "FECHA" TIMESTAMP NOT NULL
    );
    EXECUTE format('COMMENT ON TABLE sca2_anulaciones.sca2_ejecucion_argumento IS %L', marca);
    REVOKE ALL ON TABLE sca2_anulaciones.sca2_ejecucion_argumento FROM PUBLIC;
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."ID_SOLICITUD" IS 'Solicitud SCA2 (sca2_solicitud.ID_SOLICITUD)';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."ID_TAREA" IS 'Tarea SCA2 que se cerró';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."NUM_POLIZA" IS 'Póliza';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."LINEA_NEGOCIO" IS '1 Autos, 2 Hogar/Diversos, 3 Vida';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."COD_TP_ARG" IS 'Tipo de argumento (sca2_cat_tipo_argumento.COD_TP_ARG)';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."DESC_ARG" IS 'Descripción del argumento en el momento del cierre';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."COD_ID_CAMPANA" IS 'Campaña del argumento (TTQAUTOS, PREMFIDE, RETOS...)';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."RESULTADO" IS 'POSITIVO o NEGATIVO';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."MCA_ESTADO_FINAL" IS 'mcaEstadoFinal enviado a CORE (3 positivo, 6 negativo...)';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."MCA_ECONOMICO" IS 'S/N: argumento económico (mcaEconomico de consultarListadoArgumentos)';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."MCA_REGATEABLE" IS 'S/N: regateable según sca2_cat_tipo_argumento.REGATEABLE al cerrar';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."NUM_TREBOLES" IS 'Tréboles aplicados (numBonAplic); nulo si no aplica';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."PERFIL_USUARIO" IS 'Perfil PCA del gestor';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."USUARIO" IS 'Usuario Appian que cerró';
    COMMENT ON COLUMN sca2_anulaciones.sca2_ejecucion_argumento."FECHA" IS 'Fecha y hora del cierre';
    CREATE INDEX ix_sca2_ejec_arg_fecha ON sca2_anulaciones.sca2_ejecucion_argumento ("FECHA");
    CREATE INDEX ix_sca2_ejec_arg_poliza ON sca2_anulaciones.sca2_ejecucion_argumento ("NUM_POLIZA");
    CREATE INDEX ix_sca2_ejec_arg_solicitud ON sca2_anulaciones.sca2_ejecucion_argumento ("ID_SOLICITUD");
    RAISE NOTICE 'SCA2-77: tabla sca2_ejecucion_argumento creada a nombre de %', current_user;
  ELSIF NOT EXISTS (
    SELECT 1 FROM pg_class
     WHERE oid = tabla AND relkind = 'r' AND relowner = current_user::regrole
       AND obj_description(oid, 'pg_class') = marca
  ) THEN
    RAISE EXCEPTION 'sca2_ejecucion_argumento ya existe y no pertenece a este script o a %; no se modifica', current_user;
  ELSE
    RAISE NOTICE 'SCA2-77: sca2_ejecucion_argumento ya existía (a nombre de %); sin cambios', current_user;
  END IF;
END
$script$;

COMMIT;
