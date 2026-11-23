-- 77 · SCA2 · Tabla de ejecuciones de argumento (Cuadro de Gestión, opción A).
-- Aurora PostgreSQL, esquema sca2_anulaciones. Ejecutar primero en TEST y luego en la BD SCA2 de destino
-- con el propietario del esquema o un rol que pueda crear tablas.
-- psql -v ON_ERROR_STOP=1 -f 77-ejecucion-argumento.sql
-- En DBeaver: ejecutar el script completo (Alt+X) en la conexión de SCA2.
-- Solo crea objetos nuevos (IF NOT EXISTS): no modifica ninguna tabla existente; se puede relanzar.
-- Una fila por argumento cerrado en positivo o negativo; la graba SCA2 CMD CompletarAccion.
-- Rollback: DROP TABLE sca2_anulaciones.sca2_ejecucion_argumento;

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL search_path TO sca2_anulaciones;

CREATE TABLE IF NOT EXISTS sca2_ejecucion_argumento (
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
COMMENT ON TABLE sca2_ejecucion_argumento IS 'SCA2: argumento ejecutado al cerrar la contra anulación (positivo/negativo). Fuente del Cuadro de Gestión';
COMMENT ON COLUMN sca2_ejecucion_argumento."ID_SOLICITUD" IS 'Solicitud SCA2 (sca2_solicitud.ID_SOLICITUD)';
COMMENT ON COLUMN sca2_ejecucion_argumento."ID_TAREA" IS 'Tarea SCA2 que se cerró';
COMMENT ON COLUMN sca2_ejecucion_argumento."NUM_POLIZA" IS 'Póliza';
COMMENT ON COLUMN sca2_ejecucion_argumento."LINEA_NEGOCIO" IS '1 Autos, 2 Hogar/Diversos, 3 Vida';
COMMENT ON COLUMN sca2_ejecucion_argumento."COD_TP_ARG" IS 'Tipo de argumento (sca2_cat_tipo_argumento.COD_TP_ARG)';
COMMENT ON COLUMN sca2_ejecucion_argumento."DESC_ARG" IS 'Descripción del argumento en el momento del cierre';
COMMENT ON COLUMN sca2_ejecucion_argumento."COD_ID_CAMPANA" IS 'Campaña del argumento (TTQAUTOS, PREMFIDE, RETOS...)';
COMMENT ON COLUMN sca2_ejecucion_argumento."RESULTADO" IS 'POSITIVO o NEGATIVO';
COMMENT ON COLUMN sca2_ejecucion_argumento."MCA_ESTADO_FINAL" IS 'mcaEstadoFinal enviado a CORE (3 positivo, 6 negativo...)';
COMMENT ON COLUMN sca2_ejecucion_argumento."MCA_ECONOMICO" IS 'S/N: argumento económico (mcaEconomico de consultarListadoArgumentos)';
COMMENT ON COLUMN sca2_ejecucion_argumento."MCA_REGATEABLE" IS 'S/N: regateable según sca2_cat_tipo_argumento.REGATEABLE al cerrar';
COMMENT ON COLUMN sca2_ejecucion_argumento."NUM_TREBOLES" IS 'Tréboles aplicados (numBonAplic); nulo si no aplica';
COMMENT ON COLUMN sca2_ejecucion_argumento."PERFIL_USUARIO" IS 'Perfil PCA del gestor';
COMMENT ON COLUMN sca2_ejecucion_argumento."USUARIO" IS 'Usuario Appian que cerró';
COMMENT ON COLUMN sca2_ejecucion_argumento."FECHA" IS 'Fecha y hora del cierre';

CREATE INDEX IF NOT EXISTS ix_sca2_ejec_arg_fecha ON sca2_ejecucion_argumento ("FECHA");
CREATE INDEX IF NOT EXISTS ix_sca2_ejec_arg_poliza ON sca2_ejecucion_argumento ("NUM_POLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_ejec_arg_solicitud ON sca2_ejecucion_argumento ("ID_SOLICITUD");

COMMIT;
