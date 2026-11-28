-- =====================================================================================
-- 78 · SCA2 · DESPLIEGUE EN PRODUCCIÓN DEL ESQUEMA COMPLETO sca2_anulaciones
-- Aurora PostgreSQL 14 · esquema sca2_anulaciones · owner user_sca2_anulaciones
-- Origen: Appian TEST (mapfrespain-test), data source «SCA2 DataBase AWS», comprobado con
-- el MCP el 26/11/2026: 43 tablas y 1136 columnas. Catálogos exportados de TEST ese día.
--
-- Un único fichero con todo lo que hay en TEST, en este orden:
--    1. Estructura base: 22 tablas, índices y owners (73-promocion-bd-sca2-estructura).
--    2. OBSERVACIONES de tipos de argumento a VARCHAR(2000) (76).
--    3. sca2_ejecucion_argumento, cuadro de gestión (77).
--    4. sca2_adjunto_compraventa, contrato de compraventa sin traspaso (sca2-adjunto-compraventa).
--    5. sca2_cola_reserva_prima, cola del batch Reserva Prima.
--    6. 15 tablas *_hist del archivo histórico, vacías (sca2-hist-ddl).
--    7. Reintento de finalización: 3 tablas, funciones y procedures; queda DESACTIVADO
--       (habilitado = false) (sca2-reintento-finalizacion).
--    8. Procedure de traspaso al histórico v3; instalarlo no mueve datos (sca2-hist-traspaso).
--    9. Catálogos sca2_cat_* con los ID de TEST (sustituye a 74), sin las filas que solo
--       existen en TEST por pruebas (tipos de argumento 342–346, valor de concepto 101).
--   10. Verificación final (solo lectura, un único JSON).
--
-- Cómo ejecutarlo:
--   * Como user_sca2_anulaciones o como un usuario miembro de ese rol (p. ej. el master de
--     Aurora con GRANT user_sca2_anulaciones TO <master>). El rol debe existir; si no, el
--     script se para al principio sin cambiar nada. Si el esquema no existe, el usuario
--     necesita CREATE sobre la base de datos (o crearlo antes con
--     CREATE SCHEMA sca2_anulaciones AUTHORIZATION user_sca2_anulaciones).
--   * psql:    psql -v ON_ERROR_STOP=1 -f 78-despliegue-produccion-sca2-completo.sql
--   * DBeaver: ejecutar el script completo (Alt+X) con parada en el primer error.
--   * Cada bloque es una transacción: si uno falla no deja nada a medias de ese bloque
--     y lo anterior queda bien hecho. Es idempotente: corregida la causa, se vuelve a
--     ejecutar el fichero entero desde el principio.
--   * Nunca borra tablas, columnas ni datos, ni reduce tipos. En los catálogos, las filas
--     cuyo ID ya existe no se tocan (ON CONFLICT DO NOTHING).
--   * Al final: en «verificacion_final», «ok» debe salir true.
--   * Después, en Appian: sincronizar los record types SCA2 con data sync.
-- No activa el reintento de finalización ni lanza el traspaso al histórico: eso sigue
-- necesitando su autorización aparte.
-- =====================================================================================

-- =====================================================================================
-- 1. Estructura base (22 tablas)
--    Origen: 73-promocion-bd-sca2-estructura.sql
-- =====================================================================================
-- =====================================================================================
-- 73 · SCA2 · Script de BD para la promoción de la aplicación (1 de 2: ESTRUCTURA)
-- Aurora PostgreSQL / PostgreSQL >= 11 · esquema sca2_anulaciones
-- Fecha: 17/11/2026 · Origen: Appian TEST (mapfrespain-test), aplicación SCA2
--   _a-0000f069-4f37-8000-9cc8-011c48011c48_20050128, data source «SCA2 DataBase AWS».
--
-- Deja el esquema del entorno destino IGUAL que el físico de TEST hoy (comprobado con
-- listDatabaseTableColumns del MCP el 17/11/2026: 22 tablas, 588 columnas):
--   1. DDL 56 (tablas, columnas, PK, secuencias, comentarios, índices por ID_SOLICITUD,
--      UNIQUE de catálogos) con las longitudes ya ampliadas en TEST:
--        sca2_datos_cabecera.POLIZA_FECHAULTIMOSINIESTRO VARCHAR(1000)  (scripts 63 / 66-C5)
--        sca2_datos_solicitud.FECIMPRESION               VARCHAR(1000)  (script 71)
--        sca2_transicion.CLAVE_IDEMPOTENCIA              VARCHAR(200)   (script 66-C6)
--      y el UNIQUE de tipo de argumento parcial sobre filas activas (66-paso2 C4).
--      Los 15 índices por ESTADO/NUM_POLIZA del DDL 56 que TEST no tiene van comentados
--      y, si existen de una ejecución anterior del 56, se borran (4b), igual que el
--      UNIQUE total ux_sca2_cat_tipo_argumento. Solo índices: nunca borra tablas,
--      columnas ni datos.
--   2. Índices de rendimiento B1–B8 (script 66-paso1).
--   3. NOT NULL de claves C2/C3 (script 66-paso2).
--   4. UNIQUE de integridad: C1 caché de cabecera (70), C7 tarea pendiente (71),
--      error pendiente (72).
-- Sustituye, para un entorno nuevo, a 56, 63, 66-paso1, 66-paso2, 70, 71 y 72.
--
-- Cómo ejecutarlo:
--   * OWNER: todo (esquema, tablas, secuencias, índices) queda con owner user_sca2_anulaciones.
--     Ejecutar como user_sca2_anulaciones o como un usuario miembro de ese rol (p. ej. el
--     master de Aurora con GRANT user_sca2_anulaciones TO <master>). El rol debe existir;
--     si no, el script se para al principio sin cambiar nada.
--   * psql:    psql -v ON_ERROR_STOP=1 -f 73-promocion-bd-sca2-estructura.sql
--     DBeaver: Alt+X (ejecutar script). Los NOTICE/WARNING salen en «Salida» (Ctrl+Shift+O).
--   * Todo va en UNA transacción: si algo falla, no se aplica nada.
--   * Idempotente: se puede relanzar; en un esquema ya existente sólo crea/añade/amplía
--     lo que falte, nunca borra tablas, columnas ni datos ni reduce tipos.
--   * Los índices se crean sin CONCURRENTLY (tablas vacías en el destino). Si el esquema
--     destino ya tuviera muchos datos, lanzarlo en ventana de baja carga.
--   * Después: 74-promocion-bd-sca2-catalogos.sql (datos de catálogos).
--   * La última consulta devuelve un único JSON de verificación (esperado al final).
--   5. Owner user_sca2_anulaciones de todo el esquema (56-owner-sca2.sql).
-- Fuera de este script (igual que en TEST): claves ajenas (C8) y GRANTs a otros usuarios
-- (bloque comentado al final).
-- =====================================================================================
BEGIN;

-- El owner de todo el esquema debe ser user_sca2_anulaciones: si el rol no existe o el
-- usuario que ejecuta no puede asignárselo, se para aquí sin cambiar nada.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'user_sca2_anulaciones') THEN
    RAISE EXCEPTION 'No existe el rol user_sca2_anulaciones: crearlo antes de ejecutar este script';
  END IF;
  IF NOT pg_has_role(current_user, 'user_sca2_anulaciones', 'USAGE')
     AND NOT (SELECT rolsuper FROM pg_roles WHERE rolname = current_user) THEN
    RAISE EXCEPTION 'El usuario % no puede asignar el owner user_sca2_anulaciones: ejecutar como user_sca2_anulaciones o como un miembro de ese rol', current_user;
  END IF;
END $$;

-- Solo se crea si no existe (CREATE SCHEMA IF NOT EXISTS pide CREATE sobre la base de datos
-- aunque el esquema ya exista).
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'sca2_anulaciones') THEN
    IF NOT has_database_privilege(current_database(), 'CREATE') THEN
      RAISE EXCEPTION 'No existe el esquema sca2_anulaciones y % no tiene CREATE sobre la base de datos %: crearlo antes (CREATE SCHEMA sca2_anulaciones AUTHORIZATION user_sca2_anulaciones) o dar ese permiso', current_user, current_database();
    END IF;
    CREATE SCHEMA sca2_anulaciones AUTHORIZATION user_sca2_anulaciones;
  END IF;
END $$;
SET search_path TO sca2_anulaciones;

-- ---------------------------------------------------------------
-- sca2_cat_causa (SCA2 Cat Causa): 13 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_cat_causa (
  "ID" SERIAL PRIMARY KEY,
  "COD_LINEA_NEGOCIO" INTEGER,
  "COD_MOTIVO" VARCHAR(5),
  "COD_DETALLE" VARCHAR(5),
  "COD_PERFIL" VARCHAR(30),
  "COD_CAUSA" VARCHAR(5),
  "DESCRIPCION" VARCHAR(100),
  "ORDEN" INTEGER,
  "ACTIVO" BOOLEAN DEFAULT TRUE,
  "ORIGEN" VARCHAR(10),
  "FECHA_ALTA" TIMESTAMP,
  "FECHA_MODIFICACION" TIMESTAMP,
  "USUARIO_MODIFICACION" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "COD_LINEA_NEGOCIO" INTEGER;
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "COD_MOTIVO" VARCHAR(5);
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "COD_DETALLE" VARCHAR(5);
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "COD_PERFIL" VARCHAR(30);
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "COD_CAUSA" VARCHAR(5);
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "DESCRIPCION" VARCHAR(100);
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "ORDEN" INTEGER;
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "ACTIVO" BOOLEAN DEFAULT TRUE;
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(10);
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "FECHA_ALTA" TIMESTAMP;
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "FECHA_MODIFICACION" TIMESTAMP;
ALTER TABLE sca2_cat_causa ADD COLUMN IF NOT EXISTS "USUARIO_MODIFICACION" VARCHAR(100);
ALTER TABLE sca2_cat_causa ALTER COLUMN "ACTIVO" SET DEFAULT TRUE;
COMMENT ON TABLE sca2_cat_causa IS 'SCA2 Cat Causa: Catálogo CORE de causas de anulación (IGenerarContraAnul.consultarCausa) por línea de negocio, motivo, detalle y perfil. Copia en Aurora; el maestro sigue siendo CORE.';
COMMENT ON COLUMN sca2_cat_causa."COD_LINEA_NEGOCIO" IS 'Línea de negocio';
COMMENT ON COLUMN sca2_cat_causa."COD_MOTIVO" IS 'Código del motivo';
COMMENT ON COLUMN sca2_cat_causa."COD_DETALLE" IS 'Código del detalle';
COMMENT ON COLUMN sca2_cat_causa."COD_PERFIL" IS 'Perfil PCA (listadoCausaAnulDTO.codPerfil) para el que CORE devuelve la causa';
COMMENT ON COLUMN sca2_cat_causa."COD_CAUSA" IS 'Código de la causa en CORE';
COMMENT ON COLUMN sca2_cat_causa."DESCRIPCION" IS 'Descripción de la causa';
COMMENT ON COLUMN sca2_cat_causa."ORDEN" IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_causa."ACTIVO" IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_causa."ORIGEN" IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_causa."FECHA_ALTA" IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_causa."FECHA_MODIFICACION" IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_causa."USUARIO_MODIFICACION" IS 'Usuario Appian que hizo la última modificación';

-- ---------------------------------------------------------------
-- sca2_cat_concepto (SCA2 Cat Concepto): 11 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_cat_concepto (
  "ID" SERIAL PRIMARY KEY,
  "IDN_CONCEPTO_PCA" VARCHAR(10),
  "DES_CONCEPTO_PCA" VARCHAR(50),
  "MCA_INH" VARCHAR(1),
  "FEC_ACTU" DATE,
  "ORDEN" INTEGER,
  "ACTIVO" BOOLEAN DEFAULT TRUE,
  "ORIGEN" VARCHAR(10),
  "FECHA_ALTA" TIMESTAMP,
  "FECHA_MODIFICACION" TIMESTAMP,
  "USUARIO_MODIFICACION" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "IDN_CONCEPTO_PCA" VARCHAR(10);
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "DES_CONCEPTO_PCA" VARCHAR(50);
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "MCA_INH" VARCHAR(1);
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "FEC_ACTU" DATE;
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "ORDEN" INTEGER;
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "ACTIVO" BOOLEAN DEFAULT TRUE;
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(10);
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "FECHA_ALTA" TIMESTAMP;
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "FECHA_MODIFICACION" TIMESTAMP;
ALTER TABLE sca2_cat_concepto ADD COLUMN IF NOT EXISTS "USUARIO_MODIFICACION" VARCHAR(100);
ALTER TABLE sca2_cat_concepto ALTER COLUMN "ACTIVO" SET DEFAULT TRUE;
COMMENT ON TABLE sca2_cat_concepto IS 'SCA2 Cat Concepto: Catálogo CORE de conceptos PCA (IGestionarConceptosPCA.consultarConcepto, tipoBusqueda 0: cabecera conceptoDTO). Copia en Aurora; el maestro sigue siendo CORE.';
COMMENT ON COLUMN sca2_cat_concepto."IDN_CONCEPTO_PCA" IS 'Identificador del concepto en CORE';
COMMENT ON COLUMN sca2_cat_concepto."DES_CONCEPTO_PCA" IS 'Descripción del concepto';
COMMENT ON COLUMN sca2_cat_concepto."MCA_INH" IS 'Marca inhabilitado S/N';
COMMENT ON COLUMN sca2_cat_concepto."FEC_ACTU" IS 'Fecha de actualización en CORE';
COMMENT ON COLUMN sca2_cat_concepto."ORDEN" IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_concepto."ACTIVO" IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_concepto."ORIGEN" IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_concepto."FECHA_ALTA" IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_concepto."FECHA_MODIFICACION" IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_concepto."USUARIO_MODIFICACION" IS 'Usuario Appian que hizo la última modificación';

-- ---------------------------------------------------------------
-- sca2_cat_detalle (SCA2 Cat Detalle): 11 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_cat_detalle (
  "ID" SERIAL PRIMARY KEY,
  "COD_LINEA_NEGOCIO" INTEGER,
  "COD_MOTIVO" VARCHAR(5),
  "COD_DETALLE" VARCHAR(5),
  "DESCRIPCION" VARCHAR(100),
  "ORDEN" INTEGER,
  "ACTIVO" BOOLEAN DEFAULT TRUE,
  "ORIGEN" VARCHAR(10),
  "FECHA_ALTA" TIMESTAMP,
  "FECHA_MODIFICACION" TIMESTAMP,
  "USUARIO_MODIFICACION" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "COD_LINEA_NEGOCIO" INTEGER;
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "COD_MOTIVO" VARCHAR(5);
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "COD_DETALLE" VARCHAR(5);
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "DESCRIPCION" VARCHAR(100);
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "ORDEN" INTEGER;
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "ACTIVO" BOOLEAN DEFAULT TRUE;
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(10);
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "FECHA_ALTA" TIMESTAMP;
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "FECHA_MODIFICACION" TIMESTAMP;
ALTER TABLE sca2_cat_detalle ADD COLUMN IF NOT EXISTS "USUARIO_MODIFICACION" VARCHAR(100);
ALTER TABLE sca2_cat_detalle ALTER COLUMN "ACTIVO" SET DEFAULT TRUE;
COMMENT ON TABLE sca2_cat_detalle IS 'SCA2 Cat Detalle: Catálogo CORE de detalles de anulación (IGenerarContraAnul.consultarDetalle) por línea de negocio y motivo. Copia en Aurora; el maestro sigue siendo CORE.';
COMMENT ON COLUMN sca2_cat_detalle."COD_LINEA_NEGOCIO" IS 'Línea de negocio';
COMMENT ON COLUMN sca2_cat_detalle."COD_MOTIVO" IS 'Código del motivo padre';
COMMENT ON COLUMN sca2_cat_detalle."COD_DETALLE" IS 'Código del detalle en CORE';
COMMENT ON COLUMN sca2_cat_detalle."DESCRIPCION" IS 'Descripción del detalle';
COMMENT ON COLUMN sca2_cat_detalle."ORDEN" IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_detalle."ACTIVO" IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_detalle."ORIGEN" IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_detalle."FECHA_ALTA" IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_detalle."FECHA_MODIFICACION" IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_detalle."USUARIO_MODIFICACION" IS 'Usuario Appian que hizo la última modificación';

-- ---------------------------------------------------------------
-- sca2_cat_motivo (SCA2 Cat Motivo): 12 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_cat_motivo (
  "ID" SERIAL PRIMARY KEY,
  "COD_LINEA_NEGOCIO" INTEGER,
  "COD_PERFIL" VARCHAR(30),
  "COD_SUB_PERFIL" VARCHAR(30),
  "COD_MOTIVO" VARCHAR(5),
  "DESCRIPCION" VARCHAR(100),
  "ORDEN" INTEGER,
  "ACTIVO" BOOLEAN DEFAULT TRUE,
  "ORIGEN" VARCHAR(10),
  "FECHA_ALTA" TIMESTAMP,
  "FECHA_MODIFICACION" TIMESTAMP,
  "USUARIO_MODIFICACION" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "COD_LINEA_NEGOCIO" INTEGER;
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "COD_PERFIL" VARCHAR(30);
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "COD_SUB_PERFIL" VARCHAR(30);
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "COD_MOTIVO" VARCHAR(5);
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "DESCRIPCION" VARCHAR(100);
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "ORDEN" INTEGER;
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "ACTIVO" BOOLEAN DEFAULT TRUE;
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(10);
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "FECHA_ALTA" TIMESTAMP;
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "FECHA_MODIFICACION" TIMESTAMP;
ALTER TABLE sca2_cat_motivo ADD COLUMN IF NOT EXISTS "USUARIO_MODIFICACION" VARCHAR(100);
ALTER TABLE sca2_cat_motivo ALTER COLUMN "ACTIVO" SET DEFAULT TRUE;
COMMENT ON TABLE sca2_cat_motivo IS 'SCA2 Cat Motivo: Catálogo CORE de motivos de anulación (IGenerarContraAnul.consultarMotivo) por línea de negocio, perfil y subperfil. Copia en Aurora; el maestro sigue siendo CORE.';
COMMENT ON COLUMN sca2_cat_motivo."COD_LINEA_NEGOCIO" IS 'Línea de negocio (codsector TRON / LINEA_NEGOCIO wAutemis): 1 Autos, 2 Diversos, 3 Vida';
COMMENT ON COLUMN sca2_cat_motivo."COD_PERFIL" IS 'Perfil PCA del usuario (infoUsuarioDTO.codPerfil) para el que CORE devuelve el motivo';
COMMENT ON COLUMN sca2_cat_motivo."COD_SUB_PERFIL" IS 'Subperfil PCA del usuario (infoUsuarioDTO.codSubPerfil)';
COMMENT ON COLUMN sca2_cat_motivo."COD_MOTIVO" IS 'Código del motivo en CORE (tipoElementoBasicoDTO.codigo)';
COMMENT ON COLUMN sca2_cat_motivo."DESCRIPCION" IS 'Descripción del motivo (tipoElementoBasicoDTO.descripcion)';
COMMENT ON COLUMN sca2_cat_motivo."ORDEN" IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_motivo."ACTIVO" IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_motivo."ORIGEN" IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_motivo."FECHA_ALTA" IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_motivo."FECHA_MODIFICACION" IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_motivo."USUARIO_MODIFICACION" IS 'Usuario Appian que hizo la última modificación';

-- ---------------------------------------------------------------
-- sca2_cat_tipo_argumento (SCA2 Cat Tipo Argumento): 31 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_cat_tipo_argumento (
  "ID" SERIAL PRIMARY KEY,
  "COD_TP_ARG" VARCHAR(5),
  "DESC_ARG" VARCHAR(100),
  "COD_ESTADO" VARCHAR(1),
  "ID_LINEA_NEGOCIO" VARCHAR(2),
  "ID_RAMO" INTEGER,
  "COD_COMPANIA" INTEGER,
  "COD_COMPANIA_ARG" INTEGER,
  "APLI_ARGUMENTO" VARCHAR(30),
  "INSTRUCCION" VARCHAR(255),
  "MCA_FINALIZADO" VARCHAR(1),
  "NOMBRE_DOC" VARCHAR(100),
  "NUM_DOC" VARCHAR(30),
  "OBSERVACIONES" VARCHAR(255),
  "FEC_VIGENCIA" VARCHAR(19),
  "FEC_MODIFICADO" VARCHAR(19),
  "COD_ID_CAMPANA" VARCHAR(20),
  "COD_TIP_BON" VARCHAR(10),
  "NUM_TIP_BON" VARCHAR(5),
  "REGATEABLE" VARCHAR(1),
  "MCA_TE_CUIDAMOS" VARCHAR(1),
  "NUM_DIAS_SGO" INTEGER,
  "COD_TAREA_SGO" VARCHAR(20),
  "TXT_URL_ARG" VARCHAR(255),
  "MCA_TREB_CALC" VARCHAR(1),
  "ORDEN" INTEGER,
  "ACTIVO" BOOLEAN DEFAULT TRUE,
  "ORIGEN" VARCHAR(10),
  "FECHA_ALTA" TIMESTAMP,
  "FECHA_MODIFICACION" TIMESTAMP,
  "USUARIO_MODIFICACION" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_TP_ARG" VARCHAR(5);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "DESC_ARG" VARCHAR(100);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_ESTADO" VARCHAR(1);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "ID_LINEA_NEGOCIO" VARCHAR(2);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "ID_RAMO" INTEGER;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_COMPANIA" INTEGER;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_COMPANIA_ARG" INTEGER;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "APLI_ARGUMENTO" VARCHAR(30);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "INSTRUCCION" VARCHAR(255);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "MCA_FINALIZADO" VARCHAR(1);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "NOMBRE_DOC" VARCHAR(100);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "NUM_DOC" VARCHAR(30);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "OBSERVACIONES" VARCHAR(255);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "FEC_VIGENCIA" VARCHAR(19);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "FEC_MODIFICADO" VARCHAR(19);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_ID_CAMPANA" VARCHAR(20);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_TIP_BON" VARCHAR(10);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "NUM_TIP_BON" VARCHAR(5);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "REGATEABLE" VARCHAR(1);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "MCA_TE_CUIDAMOS" VARCHAR(1);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "NUM_DIAS_SGO" INTEGER;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "COD_TAREA_SGO" VARCHAR(20);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "TXT_URL_ARG" VARCHAR(255);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "MCA_TREB_CALC" VARCHAR(1);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "ORDEN" INTEGER;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "ACTIVO" BOOLEAN DEFAULT TRUE;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(10);
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "FECHA_ALTA" TIMESTAMP;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "FECHA_MODIFICACION" TIMESTAMP;
ALTER TABLE sca2_cat_tipo_argumento ADD COLUMN IF NOT EXISTS "USUARIO_MODIFICACION" VARCHAR(100);
ALTER TABLE sca2_cat_tipo_argumento ALTER COLUMN "ACTIVO" SET DEFAULT TRUE;
COMMENT ON TABLE sca2_cat_tipo_argumento IS 'SCA2 Cat Tipo Argumento: Catálogo CORE de tipos de argumento de contra anulación (IGestionarArgumentosPCA.consultarTipoArg, CDT detalleTpArgDTO). Copia en Aurora; el maestro sigue siendo CORE.';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_TP_ARG" IS 'Código del tipo de argumento (clave CORE)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."DESC_ARG" IS 'Descripción del argumento';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_ESTADO" IS 'Estado S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento."ID_LINEA_NEGOCIO" IS 'Línea de negocio 1/2/3';
COMMENT ON COLUMN sca2_cat_tipo_argumento."ID_RAMO" IS 'Ramo (200 Autos, 73 Diversos, 101 Vida)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_COMPANIA" IS 'Compañía (vacío en CORE)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_COMPANIA_ARG" IS 'Compañía del argumento (41, 1, 3)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."APLI_ARGUMENTO" IS 'Aplicación (VISUALIZAR_PDF, WAUTEMIS, TE_CUIDAMOS, …)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."INSTRUCCION" IS 'Instrucción';
COMMENT ON COLUMN sca2_cat_tipo_argumento."MCA_FINALIZADO" IS 'Marca finalizado S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento."NOMBRE_DOC" IS 'Nombre del documento';
COMMENT ON COLUMN sca2_cat_tipo_argumento."NUM_DOC" IS 'Identificador Documentum';
COMMENT ON COLUMN sca2_cat_tipo_argumento."OBSERVACIONES" IS 'Observaciones';
COMMENT ON COLUMN sca2_cat_tipo_argumento."FEC_VIGENCIA" IS 'Fecha de vigencia tal como la devuelve CORE (dd/MM/yyyy HH:mm:ss)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."FEC_MODIFICADO" IS 'Fecha de modificación tal como la devuelve CORE (dd/MM/yyyy HH:mm:ss)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_ID_CAMPANA" IS 'Campaña (valor del concepto CAMP)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_TIP_BON" IS 'Tipo de bonificación (TREBOLES, EUROS)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."NUM_TIP_BON" IS 'Importe/número de la bonificación';
COMMENT ON COLUMN sca2_cat_tipo_argumento."REGATEABLE" IS 'Regateable S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento."MCA_TE_CUIDAMOS" IS 'Marca Te Cuidamos S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento."NUM_DIAS_SGO" IS 'Días SGO';
COMMENT ON COLUMN sca2_cat_tipo_argumento."COD_TAREA_SGO" IS 'Tarea SGO';
COMMENT ON COLUMN sca2_cat_tipo_argumento."TXT_URL_ARG" IS 'URL del argumento';
COMMENT ON COLUMN sca2_cat_tipo_argumento."MCA_TREB_CALC" IS 'Marca tréboles calculados S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento."ORDEN" IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."ACTIVO" IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_tipo_argumento."ORIGEN" IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_tipo_argumento."FECHA_ALTA" IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_tipo_argumento."FECHA_MODIFICACION" IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_tipo_argumento."USUARIO_MODIFICACION" IS 'Usuario Appian que hizo la última modificación';

-- ---------------------------------------------------------------
-- sca2_cat_valor_concepto (SCA2 Cat Valor Concepto): 13 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_cat_valor_concepto (
  "ID" SERIAL PRIMARY KEY,
  "IDN_CONCEPTO_PCA" VARCHAR(10),
  "IDN_PCA" VARCHAR(5),
  "VALOR_CONCEPTO" VARCHAR(255),
  "DES_CONCEPTO" VARCHAR(100),
  "MCA_INH" VARCHAR(1),
  "FEC_ACTU" DATE,
  "ORDEN" INTEGER,
  "ACTIVO" BOOLEAN DEFAULT TRUE,
  "ORIGEN" VARCHAR(10),
  "FECHA_ALTA" TIMESTAMP,
  "FECHA_MODIFICACION" TIMESTAMP,
  "USUARIO_MODIFICACION" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "IDN_CONCEPTO_PCA" VARCHAR(10);
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "IDN_PCA" VARCHAR(5);
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "VALOR_CONCEPTO" VARCHAR(255);
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "DES_CONCEPTO" VARCHAR(100);
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "MCA_INH" VARCHAR(1);
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "FEC_ACTU" DATE;
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "ORDEN" INTEGER;
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "ACTIVO" BOOLEAN DEFAULT TRUE;
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(10);
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "FECHA_ALTA" TIMESTAMP;
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "FECHA_MODIFICACION" TIMESTAMP;
ALTER TABLE sca2_cat_valor_concepto ADD COLUMN IF NOT EXISTS "USUARIO_MODIFICACION" VARCHAR(100);
ALTER TABLE sca2_cat_valor_concepto ALTER COLUMN "ACTIVO" SET DEFAULT TRUE;
COMMENT ON TABLE sca2_cat_valor_concepto IS 'SCA2 Cat Valor Concepto: Valores de cada concepto PCA (consultarConcepto tipoBusqueda 1: valorConceptoDTO). Copia en Aurora; el maestro sigue siendo CORE.';
COMMENT ON COLUMN sca2_cat_valor_concepto."IDN_CONCEPTO_PCA" IS 'Identificador del concepto padre';
COMMENT ON COLUMN sca2_cat_valor_concepto."IDN_PCA" IS 'Identificador del valor dentro del concepto';
COMMENT ON COLUMN sca2_cat_valor_concepto."VALOR_CONCEPTO" IS 'Valor';
COMMENT ON COLUMN sca2_cat_valor_concepto."DES_CONCEPTO" IS 'Descripción del valor';
COMMENT ON COLUMN sca2_cat_valor_concepto."MCA_INH" IS 'Marca inhabilitado S/N';
COMMENT ON COLUMN sca2_cat_valor_concepto."FEC_ACTU" IS 'Fecha de actualización en CORE';
COMMENT ON COLUMN sca2_cat_valor_concepto."ORDEN" IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_valor_concepto."ACTIVO" IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_valor_concepto."ORIGEN" IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_valor_concepto."FECHA_ALTA" IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_valor_concepto."FECHA_MODIFICACION" IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_valor_concepto."USUARIO_MODIFICACION" IS 'Usuario Appian que hizo la última modificación';

-- ---------------------------------------------------------------
-- sca2_datos_basicos_solicitud (SCA2 Datos Basicos Solicitud): 9 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_basicos_solicitud (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "NUMPOLIZA" VARCHAR(255),
  "CODPRODUCTO" VARCHAR(255),
  "DESCPRODUCTO" VARCHAR(255),
  "IDGESTIONSGC" VARCHAR(255),
  "CODRAMO" VARCHAR(255),
  "CODCIACONTRARIA" VARCHAR(255),
  "NUMFAX" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "NUMPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "CODPRODUCTO" VARCHAR(255);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "DESCPRODUCTO" VARCHAR(255);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "IDGESTIONSGC" VARCHAR(255);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "CODRAMO" VARCHAR(255);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "CODCIACONTRARIA" VARCHAR(255);
ALTER TABLE sca2_datos_basicos_solicitud ADD COLUMN IF NOT EXISTS "NUMFAX" VARCHAR(255);
COMMENT ON TABLE sca2_datos_basicos_solicitud IS 'SCA2 Datos Basicos Solicitud: Copia SCA2 de ''SCA datosBasicosSolicitud'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_datos_cabecera (SCA2 Datos Cabecera): 53 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_cabecera (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "CLIENTE_NOMBRE" VARCHAR(255),
  "CLIENTE_APELLIDOS" VARCHAR(255),
  "CLIENTE_NIF" VARCHAR(255),
  "CLIENTE_APODERADO" VARCHAR(255),
  "CLIENTE_CARTERIZADO" VARCHAR(255),
  "CLIENTE_NUUMAPROPIETARIO" VARCHAR(255),
  "CLIENTE_RSVPRIMA" VARCHAR(255),
  "CLIENTE_DTOINTEGRALIDADNUEVAPRODUCCION" VARCHAR(255),
  "CLIENTE_TREBOLES" VARCHAR(255),
  "CLIENTE_ACTIVOCLUBMAPFRE" VARCHAR(255),
  "CLIENTE_PERFILCLUBMAPFRE" VARCHAR(255),
  "CLIENTE_TIPOCLIENTEVALOR" VARCHAR(255),
  "CLIENTE_TIPOCLIENTEDESC" VARCHAR(255),
  "CLIENTE_IDCLIENTE" VARCHAR(255),
  "POLIZA_NUMEROPOLIZA" VARCHAR(255),
  "POLIZA_NOMBREPRODUCTO" VARCHAR(255),
  "POLIZA_VEHICULO" VARCHAR(255),
  "POLIZA_LINEANEGOCIO" VARCHAR(255),
  "POLIZA_FORMAPAGO" VARCHAR(255),
  "POLIZA_FECHAEFECTO" VARCHAR(255),
  "POLIZA_FECHAVENCIMIENTO" VARCHAR(255),
  "POLIZA_ANTIGUEDAD" VARCHAR(255),
  "POLIZA_PLANPAGO" VARCHAR(255),
  "POLIZA_PRIMAACTUALRENOVACION" VARCHAR(255),
  "POLIZA_ACUERDO" VARCHAR(255),
  "POLIZA_CLAVEPRODUCCION" VARCHAR(255),
  "POLIZA_TIPOPRODUCTOR" VARCHAR(255),
  "POLIZA_SINIESTROSANOACTUAL" VARCHAR(255),
  "POLIZA_FECHAULTIMOSINIESTRO" VARCHAR(1000),
  "POLIZA_DTOINTEGRALIDADPOLIZA" VARCHAR(255),
  "CONTACTO_VIA" VARCHAR(255),
  "CONTACTO_DOMICILIO" VARCHAR(255),
  "CONTACTO_NUMERO" VARCHAR(255),
  "CONTACTO_PROVINCIA" VARCHAR(255),
  "CONTACTO_LOCALIDAD" VARCHAR(255),
  "CONTACTO_CODPOSTAL" VARCHAR(255),
  "CONTACTO_TELMOVIL" VARCHAR(255),
  "CONTACTO_TELFIJO" VARCHAR(255),
  "CONTACTO_CORREO" VARCHAR(255),
  "CONTACTO_PISO" VARCHAR(255),
  "CONTACTO_PUERTA" VARCHAR(255),
  "CONTACTO_ESCALERA" VARCHAR(255),
  "FECHA_CACHE" TIMESTAMP,
  "VALIDA_HASTA" TIMESTAMP,
  "ORIGEN_CACHE" VARCHAR(50),
  "POLIZA_RAMO" VARCHAR(255),
  "POLIZA_CESIONDERECHOS" VARCHAR(255),
  "POLIZA_REVALORIZACION" VARCHAR(255),
  "CONTACTO_PAIS" VARCHAR(255),
  "TIPO_POLIZA" VARCHAR(100),
  "CLIENTE_CODINT" VARCHAR(100)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_NOMBRE" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_APELLIDOS" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_NIF" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_APODERADO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_CARTERIZADO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_NUUMAPROPIETARIO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_RSVPRIMA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_DTOINTEGRALIDADNUEVAPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_TREBOLES" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_ACTIVOCLUBMAPFRE" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_PERFILCLUBMAPFRE" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_TIPOCLIENTEVALOR" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_TIPOCLIENTEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_IDCLIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_NUMEROPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_NOMBREPRODUCTO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_VEHICULO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_LINEANEGOCIO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_FORMAPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_FECHAEFECTO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_FECHAVENCIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_ANTIGUEDAD" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_PLANPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_PRIMAACTUALRENOVACION" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_ACUERDO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_CLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_TIPOPRODUCTOR" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_SINIESTROSANOACTUAL" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_FECHAULTIMOSINIESTRO" VARCHAR(1000);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_DTOINTEGRALIDADPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_VIA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_DOMICILIO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_NUMERO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_PROVINCIA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_LOCALIDAD" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_CODPOSTAL" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_TELMOVIL" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_TELFIJO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_CORREO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_PISO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_PUERTA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_ESCALERA" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "FECHA_CACHE" TIMESTAMP;
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "VALIDA_HASTA" TIMESTAMP;
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "ORIGEN_CACHE" VARCHAR(50);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_RAMO" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_CESIONDERECHOS" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_REVALORIZACION" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CONTACTO_PAIS" VARCHAR(255);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "TIPO_POLIZA" VARCHAR(100);
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "CLIENTE_CODINT" VARCHAR(100);
COMMENT ON TABLE sca2_datos_cabecera IS 'SCA2 Datos Cabecera: Copia SCA2 de ''SCA datosCabecera'' (misma estructura; tabla propia).';
COMMENT ON COLUMN sca2_datos_cabecera."FECHA_CACHE" IS 'Fecha-hora de carga en la caché de la cabecera';
COMMENT ON COLUMN sca2_datos_cabecera."VALIDA_HASTA" IS 'Fecha-hora hasta la que la fila es caché válida (07:00 del día siguiente a la carga)';
COMMENT ON COLUMN sca2_datos_cabecera."ORIGEN_CACHE" IS 'Origen de la fila: CACHE (envoltorio SCA2_obtenerDatosCabecera)';
COMMENT ON COLUMN sca2_datos_cabecera."POLIZA_RAMO" IS 'Ramo (solo Vida)';
COMMENT ON COLUMN sca2_datos_cabecera."POLIZA_CESIONDERECHOS" IS 'Cesión de derechos (solo Vida)';
COMMENT ON COLUMN sca2_datos_cabecera."POLIZA_REVALORIZACION" IS 'Revalorización (solo Vida)';
COMMENT ON COLUMN sca2_datos_cabecera."CONTACTO_PAIS" IS 'País del domicilio de contacto (solo Vida)';
COMMENT ON COLUMN sca2_datos_cabecera."TIPO_POLIZA" IS 'Tipo de póliza (resultado de SCA2_obtenerTipoPoliza) para reproducir la búsqueda de otras solicitudes desde la caché';
COMMENT ON COLUMN sca2_datos_cabecera."CLIENTE_CODINT" IS 'Código interno del tomador (codInt) para la búsqueda de otras solicitudes desde la caché';

-- ---------------------------------------------------------------
-- sca2_datos_perfiles_pca (SCA2 Datos Perfiles Pca): 6 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_perfiles_pca (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "CODCOMPANIA" VARCHAR(255),
  "CODPERFIL" VARCHAR(255),
  "CODSUBPERFIL" VARCHAR(255),
  "NUUMA" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_perfiles_pca ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_perfiles_pca ADD COLUMN IF NOT EXISTS "CODCOMPANIA" VARCHAR(255);
ALTER TABLE sca2_datos_perfiles_pca ADD COLUMN IF NOT EXISTS "CODPERFIL" VARCHAR(255);
ALTER TABLE sca2_datos_perfiles_pca ADD COLUMN IF NOT EXISTS "CODSUBPERFIL" VARCHAR(255);
ALTER TABLE sca2_datos_perfiles_pca ADD COLUMN IF NOT EXISTS "NUUMA" VARCHAR(255);
COMMENT ON TABLE sca2_datos_perfiles_pca IS 'SCA2 Datos Perfiles Pca: Copia SCA2 de ''SCA datosPerfilesPca'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_datos_poliza_autos (SCA2 Datos Poliza Autos): 84 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_poliza_autos (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "LINEADENEGOCIO" VARCHAR(255),
  "IDPOLIZA" VARCHAR(255),
  "NIFTOMADOR" VARCHAR(255),
  "NOMBREAPELLIDOSTOMADOR" VARCHAR(255),
  "TIPOCLIENTE" VARCHAR(255),
  "IDENTIFICADORCLAVE" VARCHAR(255),
  "ESTADOPOLIZA" VARCHAR(255),
  "NUMAPLI" VARCHAR(255),
  "ACUERDO" VARCHAR(255),
  "TIPODEACUERDO" VARCHAR(255),
  "MARCASITUACIONPENDIENTE" VARCHAR(255),
  "FECHAEFECTOANUALIDADCURSO" VARCHAR(255),
  "FECHADEEFECTOANULACION" VARCHAR(255),
  "FECHADEEFECTOINICIAL" VARCHAR(255),
  "FECHADEVENCIMIENTO" VARCHAR(255),
  "DURACION" VARCHAR(255),
  "ESTADO" VARCHAR(255),
  "PRIMAANUAL" VARCHAR(255),
  "BANCO" VARCHAR(255),
  "PRODUCTO" VARCHAR(255),
  "CLAVEPRODUCCION" VARCHAR(255),
  "FORMADEPAGO" VARCHAR(255),
  "NOMFORMADEPAGO" VARCHAR(255),
  "SISTEMADEBONIFICACION" VARCHAR(255),
  "NIVELBONUSRC" VARCHAR(255),
  "NIVELMALUSRC" VARCHAR(255),
  "CODCIAPOLIZA" VARCHAR(255),
  "CODRAMO" VARCHAR(255),
  "NUMERO" VARCHAR(255),
  "APLICASAT" VARCHAR(255),
  "APLICACHEQUESEGURO" VARCHAR(255),
  "SINIESTROSPORANYO" VARCHAR(255),
  "CODGAMA" VARCHAR(255),
  "DESCGAMA" VARCHAR(255),
  "FECPREMIO" VARCHAR(255),
  "CODPROMOCION" VARCHAR(255),
  "VEHICULO_ANTIGUEDAD" VARCHAR(255),
  "VEHICULO_CATEGORIA" VARCHAR(255),
  "VEHICULO_TIPO" VARCHAR(255),
  "VEHICULO_VALOR" VARCHAR(255),
  "VEHICULO_MARCA" VARCHAR(255),
  "VEHICULO_NIVELDEREPARABILIDAD" VARCHAR(255),
  "VEHICULO_CODTIPCNTRLOCALIZADOR" VARCHAR(255),
  "VEHICULO_CODTIPLOCALIZADOR" VARCHAR(255),
  "VEHICULO_MATRICULA" VARCHAR(255),
  "TOMADOR_CODINT" VARCHAR(255),
  "TOMADOR_TIPO" VARCHAR(255),
  "TOMADOR_TIPODECLIENTE" VARCHAR(255),
  "TOMADOR_MARCAROBINSON" VARCHAR(255),
  "TOMADOR_TOMADORESCONDUCTOR" VARCHAR(255),
  "TOMADOR_FECHADENACIMIENTO" VARCHAR(255),
  "TOMADOR_SEXO" VARCHAR(255),
  "TOMADOR_CODIGOPOSTAL" VARCHAR(255),
  "TOMADOR_ESTADOCIVIL" VARCHAR(255),
  "TOMADOR_TIPODOCUMENTO" VARCHAR(255),
  "TOMADOR_NUMDOCUMENTO" VARCHAR(255),
  "TOMADOR_NOMBRE" VARCHAR(255),
  "TOMADOR_APELLIDO1" VARCHAR(255),
  "TOMADOR_APELLIDO2" VARCHAR(255),
  "TOMADOR_EMAIL" VARCHAR(255),
  "TOMADOR_TELEFONO1" VARCHAR(255),
  "TOMADOR_TELEFONO2" VARCHAR(255),
  "TOMADOR_CODCALIFICACION" VARCHAR(255),
  "CONDUCTOR_FECHACARNE" VARCHAR(255),
  "CONDUCTOR_FECHADENACIMIENTO" VARCHAR(255),
  "CONDUCTOR_SEXO" VARCHAR(255),
  "CONDUCTOR_CODIGOPOSTAL" VARCHAR(255),
  "CONDUCTOR_ESTADOCIVIL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CLAVEPRODUCCION" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREAGENTE" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODCLASEAGENTE" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_DGT" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODSUBCENTRAL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODOFICINADIRECTA" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREDGT" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL" VARCHAR(255),
  "ESTADORECIBOS_MCAIMPAGO" VARCHAR(255),
  "ESTADORECIBOS_FECEFECTORECIBOIMP" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "LINEADENEGOCIO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "IDPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NIFTOMADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NOMBREAPELLIDOSTOMADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TIPOCLIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "IDENTIFICADORCLAVE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTADOPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NUMAPLI" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ACUERDO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TIPODEACUERDO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "MARCASITUACIONPENDIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "FECHAEFECTOANUALIDADCURSO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "FECHADEEFECTOANULACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "FECHADEEFECTOINICIAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "FECHADEVENCIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "DURACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTADO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "PRIMAANUAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "BANCO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "PRODUCTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "FORMADEPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NOMFORMADEPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "SISTEMADEBONIFICACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NIVELBONUSRC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NIVELMALUSRC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CODCIAPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CODRAMO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "NUMERO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "APLICASAT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "APLICACHEQUESEGURO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "SINIESTROSPORANYO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CODGAMA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "DESCGAMA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "FECPREMIO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CODPROMOCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_ANTIGUEDAD" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_CATEGORIA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_TIPO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_VALOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_MARCA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_NIVELDEREPARABILIDAD" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_CODTIPCNTRLOCALIZADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_CODTIPLOCALIZADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "VEHICULO_MATRICULA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_CODINT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_TIPO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_TIPODECLIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_MARCAROBINSON" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_TOMADORESCONDUCTOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_FECHADENACIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_SEXO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_CODIGOPOSTAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_ESTADOCIVIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_TIPODOCUMENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_NUMDOCUMENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_NOMBRE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_APELLIDO1" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_APELLIDO2" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_EMAIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_TELEFONO1" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_TELEFONO2" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "TOMADOR_CODCALIFICACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CONDUCTOR_FECHACARNE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CONDUCTOR_FECHADENACIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CONDUCTOR_SEXO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CONDUCTOR_CODIGOPOSTAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "CONDUCTOR_ESTADOCIVIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREAGENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODCLASEAGENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_DGT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODSUBCENTRAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODOFICINADIRECTA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREDGT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTADORECIBOS_MCAIMPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_autos ADD COLUMN IF NOT EXISTS "ESTADORECIBOS_FECEFECTORECIBOIMP" VARCHAR(255);
COMMENT ON TABLE sca2_datos_poliza_autos IS 'SCA2 Datos Poliza Autos: Copia SCA2 de ''SCA datosPolizaAutos'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_datos_poliza_hogar (SCA2 Datos Poliza Hogar): 90 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_poliza_hogar (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "IDPOLIZA" VARCHAR(255),
  "NIFTOMADOR" VARCHAR(255),
  "NOMBREAPELLIDOSTOMADOR" VARCHAR(255),
  "TIPOCLIENTE" VARCHAR(255),
  "IDENTIFICADORCLAVE" VARCHAR(255),
  "ESTADOPOLIZA" VARCHAR(255),
  "NUMAPLI" VARCHAR(255),
  "CLIENTEACTIVOTECUIDAMOS" VARCHAR(255),
  "CLIENTECARTERIZADO" VARCHAR(255),
  "DTOINTEGRABILIDADNUEVAPRODUCCION" VARCHAR(255),
  "TREBOLES" VARCHAR(255),
  "DESCRIPCIONTIPOVIA" VARCHAR(255),
  "NOMBREVIA" VARCHAR(255),
  "NUMERODOMICILIO" VARCHAR(255),
  "DESCRIPCIONLOCALIDAD" VARCHAR(255),
  "DESCRIPCIONPROVINCIA" VARCHAR(255),
  "DESCRIPCIONPAIS" VARCHAR(255),
  "CODIGOPOSTAL" VARCHAR(255),
  "TELEFONOFIJO" VARCHAR(255),
  "TELEFONOMOVIL" VARCHAR(255),
  "EMAIL" VARCHAR(255),
  "CODCIAPOLIZA" VARCHAR(255),
  "CODRAMO" VARCHAR(255),
  "NUMPOLIZA" VARCHAR(255),
  "LINEADENEGOCIO" VARCHAR(255),
  "PRODUCTO" VARCHAR(255),
  "SITUACIONRIESGO" VARCHAR(255),
  "CESIONDERECHOS" VARCHAR(255),
  "ACUERDO" VARCHAR(255),
  "TIPODEACUERDO" VARCHAR(255),
  "DESCRIPCIONRIESGO" VARCHAR(255),
  "SUMASASEGURADAS" VARCHAR(255),
  "FORMADEPAGO" VARCHAR(255),
  "FORMADECOBRO" VARCHAR(255),
  "PRIMAANUAL" VARCHAR(255),
  "PRIMARENOVACION" VARCHAR(255),
  "DESCUENTOS" VARCHAR(255),
  "USOVIVIENDA" VARCHAR(255),
  "REGIMENVIVIENDA" VARCHAR(255),
  "PLANPAGO" VARCHAR(255),
  "FECEFECTO" VARCHAR(255),
  "FECHADEEFECTOANULACION" VARCHAR(255),
  "FECULTIMOSINIESTRO" VARCHAR(255),
  "FECHADEVENCIMIENTO" VARCHAR(255),
  "PLANSANEAMIENTO" VARCHAR(255),
  "CLAVEPRODUCCION" VARCHAR(255),
  "TIPOPRODUCCION" VARCHAR(255),
  "ESTADO" VARCHAR(255),
  "BANCO" VARCHAR(255),
  "OBJASEGURADO" VARCHAR(255),
  "CODCOTIZACION" VARCHAR(255),
  "TIPOVIVIENDA" VARCHAR(255),
  "MCONSTRUIDOS" VARCHAR(255),
  "ANIOCONSTRUCCION" VARCHAR(255),
  "CALIDAD" VARCHAR(255),
  "TIPOCONSTRUCCION" VARCHAR(255),
  "TOMADOR_CODINT" VARCHAR(255),
  "TOMADOR_TIPO" VARCHAR(255),
  "TOMADOR_TIPODECLIENTE" VARCHAR(255),
  "TOMADOR_MARCAROBINSON" VARCHAR(255),
  "TOMADOR_TOMADORESCONDUCTOR" VARCHAR(255),
  "TOMADOR_FECHADENACIMIENTO" VARCHAR(255),
  "TOMADOR_SEXO" VARCHAR(255),
  "TOMADOR_CODIGOPOSTAL" VARCHAR(255),
  "TOMADOR_ESTADOCIVIL" VARCHAR(255),
  "TOMADOR_TIPODOCUMENTO" VARCHAR(255),
  "TOMADOR_NUMDOCUMENTO" VARCHAR(255),
  "TOMADOR_NOMBRE" VARCHAR(255),
  "TOMADOR_APELLIDO1" VARCHAR(255),
  "TOMADOR_APELLIDO2" VARCHAR(255),
  "TOMADOR_EMAIL" VARCHAR(255),
  "TOMADOR_TELEFONO1" VARCHAR(255),
  "TOMADOR_TELEFONO2" VARCHAR(255),
  "TOMADOR_CODCALIFICACION" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CLAVEPRODUCCION" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREAGENTE" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODCLASEAGENTE" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_DGT" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODSUBCENTRAL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODOFICINADIRECTA" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREDGT" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL" VARCHAR(255),
  "ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL" VARCHAR(255),
  "ESTADORECIBOS_MCAIMPAGO" VARCHAR(255),
  "ESTADORECIBOS_FECEFECTORECIBOIMP" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "IDPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "NIFTOMADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "NOMBREAPELLIDOSTOMADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TIPOCLIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "IDENTIFICADORCLAVE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTADOPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "NUMAPLI" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CLIENTEACTIVOTECUIDAMOS" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CLIENTECARTERIZADO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DTOINTEGRABILIDADNUEVAPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TREBOLES" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DESCRIPCIONTIPOVIA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "NOMBREVIA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "NUMERODOMICILIO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DESCRIPCIONLOCALIDAD" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DESCRIPCIONPROVINCIA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DESCRIPCIONPAIS" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CODIGOPOSTAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TELEFONOFIJO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TELEFONOMOVIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "EMAIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CODCIAPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CODRAMO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "NUMPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "LINEADENEGOCIO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "PRODUCTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "SITUACIONRIESGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CESIONDERECHOS" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ACUERDO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TIPODEACUERDO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DESCRIPCIONRIESGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "SUMASASEGURADAS" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "FORMADEPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "FORMADECOBRO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "PRIMAANUAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "PRIMARENOVACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "DESCUENTOS" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "USOVIVIENDA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "REGIMENVIVIENDA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "PLANPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "FECEFECTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "FECHADEEFECTOANULACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "FECULTIMOSINIESTRO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "FECHADEVENCIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "PLANSANEAMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TIPOPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTADO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "BANCO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "OBJASEGURADO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CODCOTIZACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TIPOVIVIENDA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "MCONSTRUIDOS" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ANIOCONSTRUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "CALIDAD" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TIPOCONSTRUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_CODINT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_TIPO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_TIPODECLIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_MARCAROBINSON" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_TOMADORESCONDUCTOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_FECHADENACIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_SEXO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_CODIGOPOSTAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_ESTADOCIVIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_TIPODOCUMENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_NUMDOCUMENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_NOMBRE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_APELLIDO1" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_APELLIDO2" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_EMAIL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_TELEFONO1" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_TELEFONO2" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "TOMADOR_CODCALIFICACION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREAGENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODCLASEAGENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_DGT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODSUBCENTRAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODOFICINADIRECTA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREDGT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTADORECIBOS_MCAIMPAGO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_hogar ADD COLUMN IF NOT EXISTS "ESTADORECIBOS_FECEFECTORECIBOIMP" VARCHAR(255);
COMMENT ON TABLE sca2_datos_poliza_hogar IS 'SCA2 Datos Poliza Hogar: Copia SCA2 de ''SCA datosPolizaHogar'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_datos_poliza_vida (SCA2 Datos Poliza Vida): 90 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_poliza_vida (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "CLAVEPRODUCCION" VARCHAR(255),
  "LINEADENEGOCIO" VARCHAR(255),
  "IDPOLIZA" VARCHAR(255),
  "NIFTOMADOR" VARCHAR(255),
  "NOMBREAPELLIDOSTOMADOR" VARCHAR(255),
  "FECHADEVENCIMIENTO" VARCHAR(255),
  "TIPOCLIENTE" VARCHAR(255),
  "IDENTIFICADORCLAVE" VARCHAR(255),
  "ESTADOPOLIZA" VARCHAR(255),
  "NUMAPLI" VARCHAR(255),
  "POLICYID" VARCHAR(255),
  "COMPANYID" VARCHAR(255),
  "COMPANYDESC" VARCHAR(255),
  "ACCOUNTINGFIELDCODE" VARCHAR(255),
  "ACCOUNTINGFIELDDESC" VARCHAR(255),
  "EFFECTIVEDATE" VARCHAR(255),
  "DUEDATE" VARCHAR(255),
  "CAPTUREDATE" VARCHAR(255),
  "LANGUAGECODE" VARCHAR(255),
  "LANGUAGEDESC" VARCHAR(255),
  "CURRENCYISOCODE" VARCHAR(255),
  "CURRENCYISODESC" VARCHAR(255),
  "POLICYSTATUSCODE" VARCHAR(255),
  "POLICYSTATUSDESC" VARCHAR(255),
  "POLICYSTATUSREASONCODE" VARCHAR(255),
  "POLICYSTATUSREASONDESC" VARCHAR(255),
  "CONTRACTDURATIONYEARSNUM" VARCHAR(255),
  "CONTRACTDURATIONMONTHSNUM" VARCHAR(255),
  "CONTRACTDURATIONDAYSNUM" VARCHAR(255),
  "DUEDATEAGE" VARCHAR(255),
  "DESTINATIONTYPECODE" VARCHAR(255),
  "DESTINATIONTYPEDESC" VARCHAR(255),
  "FIRSTRECEIPTPAPERIND" VARCHAR(255),
  "COMMERCIALPRODUCTCODE" VARCHAR(255),
  "COMMERCIALPRODUCTNAME" VARCHAR(255),
  "REINVESTMENTPOLICYID" VARCHAR(255),
  "REINVESTMENTREASONCODE" VARCHAR(255),
  "REINVESTMENTREASONDESC" VARCHAR(255),
  "PURPOSECONTRACTCODE" VARCHAR(255),
  "PURPOSECONTRACTDESC" VARCHAR(255),
  "PREMIUMAMN" VARCHAR(255),
  "CONTRIBUTIONFREQUENCYCODE" VARCHAR(255),
  "CONTRIBUTIONFREQUENCYDESC" VARCHAR(255),
  "PAYMONTHDAYNUM" VARCHAR(255),
  "REVALUATIONTYPECODE" VARCHAR(255),
  "REVALUATIONTYPEDESC" VARCHAR(255),
  "REVALUATIONPERC" VARCHAR(255),
  "RIGHTSASSIGNMENT" VARCHAR(255),
  "TOMADORCLIENTID" VARCHAR(255),
  "TOMADORPERSONTYPECODE" VARCHAR(255),
  "TOMADORPERSONTYPEDESC" VARCHAR(255),
  "TOMADORNAME" VARCHAR(255),
  "TOMADORFIRSTSURNAME" VARCHAR(255),
  "TOMADORSECONDSURNAME" VARCHAR(255),
  "TOMADORBIRTHDATE" VARCHAR(255),
  "TOMADORCONTACTMETHODID" VARCHAR(255),
  "TOMADORCONTACTMETHODTYPECODE" VARCHAR(255),
  "TOMADORCONTACTMETHODTYPEDESC" VARCHAR(255),
  "TOMADORCONTACTMETHODVALUE" VARCHAR(255),
  "TOMADORIDENTITYDOCUMENTTYPECODE" VARCHAR(255),
  "TOMADORIDENTITYDOCUMENTTYPEDESC" VARCHAR(255),
  "TOMADORIDENTITYDOCUMENTNUMBER" VARCHAR(255),
  "ASEGURADOCLIENTID" VARCHAR(255),
  "ASEGURADOPERSONTYPECODE" VARCHAR(255),
  "ASEGURADOPERSONTYPEDESC" VARCHAR(255),
  "ASEGURADONAME" VARCHAR(255),
  "ASEGURADOFIRSTSURNAME" VARCHAR(255),
  "ASEGURADOSECONDSURNAME" VARCHAR(255),
  "ASEGURADOBIRTHDATE" VARCHAR(255),
  "ASEGURADOCONTACTMETHODID" VARCHAR(255),
  "ASEGURADOCONTACTMETHODTYPECODE" VARCHAR(255),
  "ASEGURADOCONTACTMETHODTYPEDESC" VARCHAR(255),
  "ASEGURADOCONTACTMETHODVALUE" VARCHAR(255),
  "ASEGURADOIDENTITYDOCUMENTTYPECODE" VARCHAR(255),
  "ASEGURADOIDENTITYDOCUMENTTYPEDESC" VARCHAR(255),
  "ASEGURADOIDENTITYDOCUMENTNUMBER" VARCHAR(255),
  "ESTRUCTURACOMERCIALCLAVEPRODUCCION" VARCHAR(255),
  "ESTRUCTURACOMERCIALNOMBREAGENTE" VARCHAR(255),
  "ESTRUCTURACOMERCIALCODCLASEAGENTE" VARCHAR(255),
  "ESTRUCTURACOMERCIALDGT" VARCHAR(255),
  "ESTRUCTURACOMERCIALCODSUBCENTRAL" VARCHAR(255),
  "ESTRUCTURACOMERCIALCODOFICINADIRECTA" VARCHAR(255),
  "ESTRUCTURACOMERCIALNOMBREDGT" VARCHAR(255),
  "ESTRUCTURACOMERCIALNOMBRESUBCENTRAL" VARCHAR(255),
  "ESTRUCTURACOMERCIALNOMBREOFICINADIRECTA" VARCHAR(255),
  "ESTRUCTURACOMERCIALDESCCLASEMEDIADOR" VARCHAR(255),
  "ESTRUCTURACOMERCIALCODOFICINACOMERCIAL" VARCHAR(255),
  "ESTRUCTURACOMERCIALNOMBREOFICINACOMERCIAL" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "LINEADENEGOCIO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "IDPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "NIFTOMADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "NOMBREAPELLIDOSTOMADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "FECHADEVENCIMIENTO" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TIPOCLIENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "IDENTIFICADORCLAVE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTADOPOLIZA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "NUMAPLI" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "POLICYID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "COMPANYID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "COMPANYDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ACCOUNTINGFIELDCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ACCOUNTINGFIELDDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "EFFECTIVEDATE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "DUEDATE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CAPTUREDATE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "LANGUAGECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "LANGUAGEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CURRENCYISOCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CURRENCYISODESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "POLICYSTATUSCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "POLICYSTATUSDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "POLICYSTATUSREASONCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "POLICYSTATUSREASONDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CONTRACTDURATIONYEARSNUM" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CONTRACTDURATIONMONTHSNUM" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CONTRACTDURATIONDAYSNUM" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "DUEDATEAGE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "DESTINATIONTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "DESTINATIONTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "FIRSTRECEIPTPAPERIND" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "COMMERCIALPRODUCTCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "COMMERCIALPRODUCTNAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "REINVESTMENTPOLICYID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "REINVESTMENTREASONCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "REINVESTMENTREASONDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "PURPOSECONTRACTCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "PURPOSECONTRACTDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "PREMIUMAMN" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CONTRIBUTIONFREQUENCYCODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "CONTRIBUTIONFREQUENCYDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "PAYMONTHDAYNUM" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "REVALUATIONTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "REVALUATIONTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "REVALUATIONPERC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "RIGHTSASSIGNMENT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORCLIENTID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORPERSONTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORPERSONTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORNAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORFIRSTSURNAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORSECONDSURNAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORBIRTHDATE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORCONTACTMETHODID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORCONTACTMETHODTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORCONTACTMETHODTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORCONTACTMETHODVALUE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORIDENTITYDOCUMENTTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORIDENTITYDOCUMENTTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "TOMADORIDENTITYDOCUMENTNUMBER" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOCLIENTID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOPERSONTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOPERSONTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADONAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOFIRSTSURNAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOSECONDSURNAME" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOBIRTHDATE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOCONTACTMETHODID" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOCONTACTMETHODTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOCONTACTMETHODTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOCONTACTMETHODVALUE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOIDENTITYDOCUMENTTYPECODE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOIDENTITYDOCUMENTTYPEDESC" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ASEGURADOIDENTITYDOCUMENTNUMBER" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALCLAVEPRODUCCION" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALNOMBREAGENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALCODCLASEAGENTE" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALDGT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALCODSUBCENTRAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALCODOFICINADIRECTA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALNOMBREDGT" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALNOMBRESUBCENTRAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALNOMBREOFICINADIRECTA" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALDESCCLASEMEDIADOR" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALCODOFICINACOMERCIAL" VARCHAR(255);
ALTER TABLE sca2_datos_poliza_vida ADD COLUMN IF NOT EXISTS "ESTRUCTURACOMERCIALNOMBREOFICINACOMERCIAL" VARCHAR(255);
COMMENT ON TABLE sca2_datos_poliza_vida IS 'SCA2 Datos Poliza Vida: Copia SCA2 de ''SCA Datos Poliza Vida'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_datos_productor (SCA2 Datos Productor): 16 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_productor (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "ACCESOSGC" VARCHAR(255),
  "DESCCANAL" VARCHAR(255),
  "DESCCLASEPROD" VARCHAR(255),
  "DESCSUBCANAL" VARCHAR(255),
  "ESREDTEL" VARCHAR(255),
  "ESSI24" VARCHAR(255),
  "ESTELE" VARCHAR(255),
  "IDCANAL" VARCHAR(255),
  "IDCLASEPROD" VARCHAR(255),
  "IDSUBCANAL" VARCHAR(255),
  "TIPOACCESOSGC" VARCHAR(255),
  "TIPOMEDIACION" VARCHAR(255),
  "ANULAEXPERTOS" BOOLEAN,
  "ANULATECNICOS" BOOLEAN
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ACCESOSGC" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "DESCCANAL" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "DESCCLASEPROD" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "DESCSUBCANAL" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ESREDTEL" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ESSI24" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ESTELE" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "IDCANAL" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "IDCLASEPROD" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "IDSUBCANAL" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "TIPOACCESOSGC" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "TIPOMEDIACION" VARCHAR(255);
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ANULAEXPERTOS" BOOLEAN;
ALTER TABLE sca2_datos_productor ADD COLUMN IF NOT EXISTS "ANULATECNICOS" BOOLEAN;
COMMENT ON TABLE sca2_datos_productor IS 'SCA2 Datos Productor: Copia SCA2 de ''SCA datosProductor'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_datos_solicitud (SCA2 Datos Solicitud): 33 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_datos_solicitud (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "CANALDEEJECUCION" VARCHAR(255),
  "PERFILREDMAPFRE" VARCHAR(255),
  "FECSOLICITUDANUL" VARCHAR(255),
  "FECEFECIMPAGADO" VARCHAR(255),
  "CODCAUSA" VARCHAR(255),
  "CODDETALLE" VARCHAR(255),
  "FECANULACION" VARCHAR(255),
  "FECIMPRESION" VARCHAR(1000),
  "CATALOGACION" VARCHAR(255),
  "FECESTADO" VARCHAR(255),
  "ORIGEN" VARCHAR(255),
  "CONTACTO" VARCHAR(255),
  "ESTADOSOLICITUD" VARCHAR(255),
  "USUARIO" VARCHAR(255),
  "MCAMECANIZADA" VARCHAR(255),
  "CODMOTIVO" VARCHAR(255),
  "DESCCAUSA" VARCHAR(255),
  "CANALENTRADA" VARCHAR(255),
  "SOCIOTECUIDAMOS" VARCHAR(255),
  "PERFILTECUIDAMOS" VARCHAR(255),
  "MCAANULAEXPERTO" VARCHAR(255),
  "MCAANULATECNICO" VARCHAR(255),
  "CODPCA" VARCHAR(255),
  "DESCPCA" VARCHAR(255),
  "CODMEDIOCOMUNICACION" VARCHAR(255),
  "TLFEXPERTO" VARCHAR(255),
  "RSVPRIMA" DOUBLE PRECISION,
  "IDCOMPANIA" INTEGER,
  "MCARSVPRIMA" VARCHAR(5),
  "RESP_CONTACTO" VARCHAR(255),
  "FECHA_RESP_CONTACTO" TIMESTAMP
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CANALDEEJECUCION" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "PERFILREDMAPFRE" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECSOLICITUDANUL" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECEFECIMPAGADO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CODCAUSA" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CODDETALLE" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECANULACION" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECIMPRESION" VARCHAR(1000);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CATALOGACION" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECESTADO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "ORIGEN" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CONTACTO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "ESTADOSOLICITUD" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "USUARIO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "MCAMECANIZADA" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CODMOTIVO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "DESCCAUSA" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CANALENTRADA" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "SOCIOTECUIDAMOS" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "PERFILTECUIDAMOS" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "MCAANULAEXPERTO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "MCAANULATECNICO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CODPCA" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "DESCPCA" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "CODMEDIOCOMUNICACION" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "TLFEXPERTO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "RSVPRIMA" DOUBLE PRECISION;
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "IDCOMPANIA" INTEGER;
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "MCARSVPRIMA" VARCHAR(5);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "RESP_CONTACTO" VARCHAR(255);
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECHA_RESP_CONTACTO" TIMESTAMP;
COMMENT ON TABLE sca2_datos_solicitud IS 'SCA2 Datos Solicitud: Copia SCA2 de ''SCA datosSolicitud'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_error (SCA2 Error): 13 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_error (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "COMANDO" VARCHAR(60),
  "NODO" VARCHAR(100),
  "CODIGO" VARCHAR(40),
  "MENSAJE" VARCHAR(4000),
  "PAYLOAD" TEXT,
  "INTENTOS" INTEGER,
  "PROXIMO_INTENTO" TIMESTAMP,
  "ESTADO" VARCHAR(20),
  "FECHA_CREACION" TIMESTAMP,
  "RESUELTO_POR" VARCHAR(255),
  "FECHA_RESOLUCION" TIMESTAMP
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "COMANDO" VARCHAR(60);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "NODO" VARCHAR(100);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "CODIGO" VARCHAR(40);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "MENSAJE" VARCHAR(4000);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "PAYLOAD" TEXT;
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "INTENTOS" INTEGER;
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "PROXIMO_INTENTO" TIMESTAMP;
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "ESTADO" VARCHAR(20);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "FECHA_CREACION" TIMESTAMP;
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "RESUELTO_POR" VARCHAR(255);
ALTER TABLE sca2_error ADD COLUMN IF NOT EXISTS "FECHA_RESOLUCION" TIMESTAMP;
COMMENT ON TABLE sca2_error IS 'SCA2 Error: Bandeja de errores y reintentos de comandos/integraciones.';

-- ---------------------------------------------------------------
-- sca2_llamada_servicio (SCA2 Llamada Servicio): 12 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_llamada_servicio (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "COMANDO" VARCHAR(100),
  "NODO" VARCHAR(100),
  "SERVICIO" VARCHAR(100),
  "RESULTADO" VARCHAR(20),
  "CODIGO_HTTP" INTEGER,
  "MENSAJE_ERROR" VARCHAR(1000),
  "PROCESS_ID" INTEGER,
  "FECHA_INICIO" TIMESTAMP,
  "FECHA_FIN" TIMESTAMP,
  "DURACION_MS" INTEGER
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "COMANDO" VARCHAR(100);
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "NODO" VARCHAR(100);
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "SERVICIO" VARCHAR(100);
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "RESULTADO" VARCHAR(20);
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "CODIGO_HTTP" INTEGER;
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "MENSAJE_ERROR" VARCHAR(1000);
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "PROCESS_ID" INTEGER;
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "FECHA_INICIO" TIMESTAMP;
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "FECHA_FIN" TIMESTAMP;
ALTER TABLE sca2_llamada_servicio ADD COLUMN IF NOT EXISTS "DURACION_MS" INTEGER;
COMMENT ON TABLE sca2_llamada_servicio IS 'SCA2 Llamada Servicio: [SCA2] Registro de llamadas a servicios externos (observabilidad Process HQ): servicio, duración y resultado por solicitud. Se rellena solo con SCA2_USAR_OBSERVABILIDAD = true.';

-- ---------------------------------------------------------------
-- sca2_niveles_cobertura_autos (SCA2 Niveles Cobertura Autos): 5 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_niveles_cobertura_autos (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "GRUPODECOBERTURA" VARCHAR(255),
  "NIVELDEPRIMA" VARCHAR(255),
  "MCASINIESTRO" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_niveles_cobertura_autos ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_niveles_cobertura_autos ADD COLUMN IF NOT EXISTS "GRUPODECOBERTURA" VARCHAR(255);
ALTER TABLE sca2_niveles_cobertura_autos ADD COLUMN IF NOT EXISTS "NIVELDEPRIMA" VARCHAR(255);
ALTER TABLE sca2_niveles_cobertura_autos ADD COLUMN IF NOT EXISTS "MCASINIESTRO" VARCHAR(255);
COMMENT ON TABLE sca2_niveles_cobertura_autos IS 'SCA2 Niveles Cobertura Autos: Copia SCA2 de ''SCA nivelesCoberturaAutos'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_otras_solicitudes_cabecera (SCA2 Otras Solicitudes Cabecera): 10 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_otras_solicitudes_cabecera (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "FECSOLICITUD" VARCHAR(255),
  "NUMPOLIZA" VARCHAR(255),
  "IDLINEANEGOCIO" VARCHAR(255),
  "FECANUL" VARCHAR(255),
  "CAUSAANUL" VARCHAR(255),
  "FECRESOLUCION" VARCHAR(255),
  "CODESTSOLIC" VARCHAR(255),
  "IDSOLICITUDOTRA" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "FECSOLICITUD" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "NUMPOLIZA" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "IDLINEANEGOCIO" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "FECANUL" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "CAUSAANUL" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "FECRESOLUCION" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "CODESTSOLIC" VARCHAR(255);
ALTER TABLE sca2_otras_solicitudes_cabecera ADD COLUMN IF NOT EXISTS "IDSOLICITUDOTRA" VARCHAR(255);
COMMENT ON TABLE sca2_otras_solicitudes_cabecera IS 'SCA2 Otras Solicitudes Cabecera: Copia SCA2 de ''SCA otrasSolicitudesCabecera'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- sca2_solicitud (SCA2 Solicitud): 36 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_solicitud (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50) UNIQUE,
  "NUM_POLIZA" VARCHAR(30),
  "ESTADO_SOLICITUD" VARCHAR(40),
  "INTERFAZ_ACTIVA" VARCHAR(60),
  "PROCESO_ACTIVO" VARCHAR(60),
  "ESTADO_TAREA" VARCHAR(40),
  "NODO_RELANZAR" VARCHAR(100),
  "ERROR" VARCHAR(4000),
  "PRIORIDAD_TAREA" INTEGER,
  "CADUCIDAD_TAREA" TIMESTAMP,
  "NIVEL_INTERVENCION" INTEGER,
  "FEC_INICIO_NIVEL" TIMESTAMP,
  "FECHA_DIETARIO" DATE,
  "CONTADOR_POSPONER" INTEGER,
  "MECANIZACION_REALIZADA" BOOLEAN,
  "TAREA_CAPTURADA" BOOLEAN,
  "ARGUMENTO_POSITIVO" BOOLEAN,
  "IS_POLIZA_PRRA" BOOLEAN,
  "DUE_ENVIADO" BOOLEAN,
  "TRANSACTION_ID" INTEGER,
  "GRUPO_ASIGNACION" VARCHAR(100),
  "CANAL" VARCHAR(20),
  "IDIOMA" VARCHAR(10),
  "ID_NEGOCIO" VARCHAR(20),
  "ROL" VARCHAR(40),
  "USUARIO" VARCHAR(100),
  "ORIGEN_POLIZA" VARCHAR(20),
  "LINEA_NEGOCIO" VARCHAR(20),
  "VERSION" INTEGER,
  "BLOQUEADO_POR" VARCHAR(100),
  "BLOQUEADO_HASTA" TIMESTAMP,
  "CREATED_BY" VARCHAR(255),
  "CREATED_AT" TIMESTAMP,
  "MODIFIED_BY" VARCHAR(255),
  "MODIFIED_AT" TIMESTAMP
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "NUM_POLIZA" VARCHAR(30);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ESTADO_SOLICITUD" VARCHAR(40);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "INTERFAZ_ACTIVA" VARCHAR(60);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "PROCESO_ACTIVO" VARCHAR(60);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ESTADO_TAREA" VARCHAR(40);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "NODO_RELANZAR" VARCHAR(100);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ERROR" VARCHAR(4000);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "PRIORIDAD_TAREA" INTEGER;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "CADUCIDAD_TAREA" TIMESTAMP;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "NIVEL_INTERVENCION" INTEGER;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "FEC_INICIO_NIVEL" TIMESTAMP;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "FECHA_DIETARIO" DATE;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "CONTADOR_POSPONER" INTEGER;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "MECANIZACION_REALIZADA" BOOLEAN;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "TAREA_CAPTURADA" BOOLEAN;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ARGUMENTO_POSITIVO" BOOLEAN;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "IS_POLIZA_PRRA" BOOLEAN;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "DUE_ENVIADO" BOOLEAN;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "TRANSACTION_ID" INTEGER;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "GRUPO_ASIGNACION" VARCHAR(100);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "CANAL" VARCHAR(20);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "IDIOMA" VARCHAR(10);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ID_NEGOCIO" VARCHAR(20);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ROL" VARCHAR(40);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "USUARIO" VARCHAR(100);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "ORIGEN_POLIZA" VARCHAR(20);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "LINEA_NEGOCIO" VARCHAR(20);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "VERSION" INTEGER;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "BLOQUEADO_POR" VARCHAR(100);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "BLOQUEADO_HASTA" TIMESTAMP;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "CREATED_BY" VARCHAR(255);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "CREATED_AT" TIMESTAMP;
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "MODIFIED_BY" VARCHAR(255);
ALTER TABLE sca2_solicitud ADD COLUMN IF NOT EXISTS "MODIFIED_AT" TIMESTAMP;
COMMENT ON TABLE sca2_solicitud IS 'SCA2 Solicitud: Estado persistido de la solicitud de anulacion. Fuente de verdad del orquestador (sustituye a PVs del PM largo).';

-- ---------------------------------------------------------------
-- sca2_tarea (SCA2 Tarea): 17 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_tarea (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "NUM_POLIZA" VARCHAR(30),
  "NOMBRE_TAREA" VARCHAR(100),
  "TIPO" VARCHAR(40),
  "ESTADO" VARCHAR(20),
  "PROCESO" VARCHAR(60),
  "PROPIETARIO" VARCHAR(255),
  "ASIGNADO_A" VARCHAR(255),
  "GRUPO" VARCHAR(100),
  "PRIORIDAD" INTEGER,
  "FECHA_CREACION" TIMESTAMP,
  "FECHA_CADUCIDAD" TIMESTAMP,
  "FECHA_CAPTURA" TIMESTAMP,
  "FECHA_CIERRE" TIMESTAMP,
  "DUE_ENVIADO" BOOLEAN,
  "TOKEN_TAREA" VARCHAR(64)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "NUM_POLIZA" VARCHAR(30);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "NOMBRE_TAREA" VARCHAR(100);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "TIPO" VARCHAR(40);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "ESTADO" VARCHAR(20);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "PROCESO" VARCHAR(60);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "PROPIETARIO" VARCHAR(255);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "ASIGNADO_A" VARCHAR(255);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "GRUPO" VARCHAR(100);
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "PRIORIDAD" INTEGER;
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "FECHA_CREACION" TIMESTAMP;
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "FECHA_CADUCIDAD" TIMESTAMP;
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "FECHA_CAPTURA" TIMESTAMP;
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "FECHA_CIERRE" TIMESTAMP;
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "DUE_ENVIADO" BOOLEAN;
ALTER TABLE sca2_tarea ADD COLUMN IF NOT EXISTS "TOKEN_TAREA" VARCHAR(64);
COMMENT ON TABLE sca2_tarea IS 'SCA2 Tarea: Tarea pendiente representada como fila (sustituye a User Input Task vivas y a TareasPorPolizaAWS).';

-- ---------------------------------------------------------------
-- sca2_transicion (SCA2 Transicion): 12 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_transicion (
  "ID" SERIAL PRIMARY KEY,
  "ID_SOLICITUD" VARCHAR(50),
  "COMANDO" VARCHAR(60),
  "ESTADO_ORIGEN" VARCHAR(40),
  "ESTADO_DESTINO" VARCHAR(40),
  "CLAVE_IDEMPOTENCIA" VARCHAR(200) UNIQUE,
  "RESULTADO" VARCHAR(20),
  "DETALLE" VARCHAR(4000),
  "PROCESS_ID" INTEGER,
  "USUARIO" VARCHAR(255),
  "FECHA" TIMESTAMP,
  "DURACION_MS" INTEGER
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "ID_SOLICITUD" VARCHAR(50);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "COMANDO" VARCHAR(60);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "ESTADO_ORIGEN" VARCHAR(40);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "ESTADO_DESTINO" VARCHAR(40);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "CLAVE_IDEMPOTENCIA" VARCHAR(200);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "RESULTADO" VARCHAR(20);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "DETALLE" VARCHAR(4000);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "PROCESS_ID" INTEGER;
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "USUARIO" VARCHAR(255);
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "FECHA" TIMESTAMP;
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "DURACION_MS" INTEGER;
COMMENT ON TABLE sca2_transicion IS 'SCA2 Transicion: Historico de transiciones de estado / comandos ejecutados (trazabilidad e idempotencia).';

-- ---------------------------------------------------------------
-- sca2_trazabilidad_cliente (SCA2 Trazabilidad Cliente): 11 columnas
-- ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sca2_trazabilidad_cliente (
  "ID" SERIAL PRIMARY KEY,
  "FECHA" TIMESTAMP,
  "SISTEMA" VARCHAR(255),
  "PLATAFORMA" VARCHAR(255),
  "IP" VARCHAR(255),
  "PERFIL_USUARIO" VARCHAR(255),
  "OPERACION" VARCHAR(255),
  "RESULTADO_OPERACION" VARCHAR(255),
  "CLIENTE" VARCHAR(255),
  "POLIZA" VARCHAR(255),
  "TIPO_PERSONA" VARCHAR(255)
);
-- Columnas que falten en un esquema anterior
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "FECHA" TIMESTAMP;
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "SISTEMA" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "PLATAFORMA" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "IP" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "PERFIL_USUARIO" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "OPERACION" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "RESULTADO_OPERACION" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "CLIENTE" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "POLIZA" VARCHAR(255);
ALTER TABLE sca2_trazabilidad_cliente ADD COLUMN IF NOT EXISTS "TIPO_PERSONA" VARCHAR(255);
COMMENT ON TABLE sca2_trazabilidad_cliente IS 'SCA2 Trazabilidad Cliente: Copia SCA2 de ''SCA Trazabilidad Cliente'' (misma estructura; tabla propia).';

-- ---------------------------------------------------------------
-- Ampliación de tipos en esquemas anteriores (nunca reduce ni convierte con pérdida)
-- ---------------------------------------------------------------
DO $$
DECLARE
  r record; actual text; la int; le int;
BEGIN
  FOR r IN SELECT * FROM (VALUES
    ('sca2_cat_causa', 'ID', 'integer'),
    ('sca2_cat_causa', 'COD_LINEA_NEGOCIO', 'integer'),
    ('sca2_cat_causa', 'COD_MOTIVO', 'character varying(5)'),
    ('sca2_cat_causa', 'COD_DETALLE', 'character varying(5)'),
    ('sca2_cat_causa', 'COD_PERFIL', 'character varying(30)'),
    ('sca2_cat_causa', 'COD_CAUSA', 'character varying(5)'),
    ('sca2_cat_causa', 'DESCRIPCION', 'character varying(100)'),
    ('sca2_cat_causa', 'ORDEN', 'integer'),
    ('sca2_cat_causa', 'ACTIVO', 'boolean'),
    ('sca2_cat_causa', 'ORIGEN', 'character varying(10)'),
    ('sca2_cat_causa', 'FECHA_ALTA', 'timestamp without time zone'),
    ('sca2_cat_causa', 'FECHA_MODIFICACION', 'timestamp without time zone'),
    ('sca2_cat_causa', 'USUARIO_MODIFICACION', 'character varying(100)'),
    ('sca2_cat_concepto', 'ID', 'integer'),
    ('sca2_cat_concepto', 'IDN_CONCEPTO_PCA', 'character varying(10)'),
    ('sca2_cat_concepto', 'DES_CONCEPTO_PCA', 'character varying(50)'),
    ('sca2_cat_concepto', 'MCA_INH', 'character varying(1)'),
    ('sca2_cat_concepto', 'FEC_ACTU', 'date'),
    ('sca2_cat_concepto', 'ORDEN', 'integer'),
    ('sca2_cat_concepto', 'ACTIVO', 'boolean'),
    ('sca2_cat_concepto', 'ORIGEN', 'character varying(10)'),
    ('sca2_cat_concepto', 'FECHA_ALTA', 'timestamp without time zone'),
    ('sca2_cat_concepto', 'FECHA_MODIFICACION', 'timestamp without time zone'),
    ('sca2_cat_concepto', 'USUARIO_MODIFICACION', 'character varying(100)'),
    ('sca2_cat_detalle', 'ID', 'integer'),
    ('sca2_cat_detalle', 'COD_LINEA_NEGOCIO', 'integer'),
    ('sca2_cat_detalle', 'COD_MOTIVO', 'character varying(5)'),
    ('sca2_cat_detalle', 'COD_DETALLE', 'character varying(5)'),
    ('sca2_cat_detalle', 'DESCRIPCION', 'character varying(100)'),
    ('sca2_cat_detalle', 'ORDEN', 'integer'),
    ('sca2_cat_detalle', 'ACTIVO', 'boolean'),
    ('sca2_cat_detalle', 'ORIGEN', 'character varying(10)'),
    ('sca2_cat_detalle', 'FECHA_ALTA', 'timestamp without time zone'),
    ('sca2_cat_detalle', 'FECHA_MODIFICACION', 'timestamp without time zone'),
    ('sca2_cat_detalle', 'USUARIO_MODIFICACION', 'character varying(100)'),
    ('sca2_cat_motivo', 'ID', 'integer'),
    ('sca2_cat_motivo', 'COD_LINEA_NEGOCIO', 'integer'),
    ('sca2_cat_motivo', 'COD_PERFIL', 'character varying(30)'),
    ('sca2_cat_motivo', 'COD_SUB_PERFIL', 'character varying(30)'),
    ('sca2_cat_motivo', 'COD_MOTIVO', 'character varying(5)'),
    ('sca2_cat_motivo', 'DESCRIPCION', 'character varying(100)'),
    ('sca2_cat_motivo', 'ORDEN', 'integer'),
    ('sca2_cat_motivo', 'ACTIVO', 'boolean'),
    ('sca2_cat_motivo', 'ORIGEN', 'character varying(10)'),
    ('sca2_cat_motivo', 'FECHA_ALTA', 'timestamp without time zone'),
    ('sca2_cat_motivo', 'FECHA_MODIFICACION', 'timestamp without time zone'),
    ('sca2_cat_motivo', 'USUARIO_MODIFICACION', 'character varying(100)'),
    ('sca2_cat_tipo_argumento', 'ID', 'integer'),
    ('sca2_cat_tipo_argumento', 'COD_TP_ARG', 'character varying(5)'),
    ('sca2_cat_tipo_argumento', 'DESC_ARG', 'character varying(100)'),
    ('sca2_cat_tipo_argumento', 'COD_ESTADO', 'character varying(1)'),
    ('sca2_cat_tipo_argumento', 'ID_LINEA_NEGOCIO', 'character varying(2)'),
    ('sca2_cat_tipo_argumento', 'ID_RAMO', 'integer'),
    ('sca2_cat_tipo_argumento', 'COD_COMPANIA', 'integer'),
    ('sca2_cat_tipo_argumento', 'COD_COMPANIA_ARG', 'integer'),
    ('sca2_cat_tipo_argumento', 'APLI_ARGUMENTO', 'character varying(30)'),
    ('sca2_cat_tipo_argumento', 'INSTRUCCION', 'character varying(255)'),
    ('sca2_cat_tipo_argumento', 'MCA_FINALIZADO', 'character varying(1)'),
    ('sca2_cat_tipo_argumento', 'NOMBRE_DOC', 'character varying(100)'),
    ('sca2_cat_tipo_argumento', 'NUM_DOC', 'character varying(30)'),
    ('sca2_cat_tipo_argumento', 'OBSERVACIONES', 'character varying(255)'),
    ('sca2_cat_tipo_argumento', 'FEC_VIGENCIA', 'character varying(19)'),
    ('sca2_cat_tipo_argumento', 'FEC_MODIFICADO', 'character varying(19)'),
    ('sca2_cat_tipo_argumento', 'COD_ID_CAMPANA', 'character varying(20)'),
    ('sca2_cat_tipo_argumento', 'COD_TIP_BON', 'character varying(10)'),
    ('sca2_cat_tipo_argumento', 'NUM_TIP_BON', 'character varying(5)'),
    ('sca2_cat_tipo_argumento', 'REGATEABLE', 'character varying(1)'),
    ('sca2_cat_tipo_argumento', 'MCA_TE_CUIDAMOS', 'character varying(1)'),
    ('sca2_cat_tipo_argumento', 'NUM_DIAS_SGO', 'integer'),
    ('sca2_cat_tipo_argumento', 'COD_TAREA_SGO', 'character varying(20)'),
    ('sca2_cat_tipo_argumento', 'TXT_URL_ARG', 'character varying(255)'),
    ('sca2_cat_tipo_argumento', 'MCA_TREB_CALC', 'character varying(1)'),
    ('sca2_cat_tipo_argumento', 'ORDEN', 'integer'),
    ('sca2_cat_tipo_argumento', 'ACTIVO', 'boolean'),
    ('sca2_cat_tipo_argumento', 'ORIGEN', 'character varying(10)'),
    ('sca2_cat_tipo_argumento', 'FECHA_ALTA', 'timestamp without time zone'),
    ('sca2_cat_tipo_argumento', 'FECHA_MODIFICACION', 'timestamp without time zone'),
    ('sca2_cat_tipo_argumento', 'USUARIO_MODIFICACION', 'character varying(100)'),
    ('sca2_cat_valor_concepto', 'ID', 'integer'),
    ('sca2_cat_valor_concepto', 'IDN_CONCEPTO_PCA', 'character varying(10)'),
    ('sca2_cat_valor_concepto', 'IDN_PCA', 'character varying(5)'),
    ('sca2_cat_valor_concepto', 'VALOR_CONCEPTO', 'character varying(255)'),
    ('sca2_cat_valor_concepto', 'DES_CONCEPTO', 'character varying(100)'),
    ('sca2_cat_valor_concepto', 'MCA_INH', 'character varying(1)'),
    ('sca2_cat_valor_concepto', 'FEC_ACTU', 'date'),
    ('sca2_cat_valor_concepto', 'ORDEN', 'integer'),
    ('sca2_cat_valor_concepto', 'ACTIVO', 'boolean'),
    ('sca2_cat_valor_concepto', 'ORIGEN', 'character varying(10)'),
    ('sca2_cat_valor_concepto', 'FECHA_ALTA', 'timestamp without time zone'),
    ('sca2_cat_valor_concepto', 'FECHA_MODIFICACION', 'timestamp without time zone'),
    ('sca2_cat_valor_concepto', 'USUARIO_MODIFICACION', 'character varying(100)'),
    ('sca2_datos_basicos_solicitud', 'ID', 'integer'),
    ('sca2_datos_basicos_solicitud', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_basicos_solicitud', 'NUMPOLIZA', 'character varying(255)'),
    ('sca2_datos_basicos_solicitud', 'CODPRODUCTO', 'character varying(255)'),
    ('sca2_datos_basicos_solicitud', 'DESCPRODUCTO', 'character varying(255)'),
    ('sca2_datos_basicos_solicitud', 'IDGESTIONSGC', 'character varying(255)'),
    ('sca2_datos_basicos_solicitud', 'CODRAMO', 'character varying(255)'),
    ('sca2_datos_basicos_solicitud', 'CODCIACONTRARIA', 'character varying(255)'),
    ('sca2_datos_basicos_solicitud', 'NUMFAX', 'character varying(255)'),
    ('sca2_datos_cabecera', 'ID', 'integer'),
    ('sca2_datos_cabecera', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_cabecera', 'CLIENTE_NOMBRE', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_APELLIDOS', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_NIF', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_APODERADO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_CARTERIZADO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_NUUMAPROPIETARIO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_RSVPRIMA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_DTOINTEGRALIDADNUEVAPRODUCCION', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_TREBOLES', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_ACTIVOCLUBMAPFRE', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_PERFILCLUBMAPFRE', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_TIPOCLIENTEVALOR', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_TIPOCLIENTEDESC', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CLIENTE_IDCLIENTE', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_NUMEROPOLIZA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_NOMBREPRODUCTO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_VEHICULO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_LINEANEGOCIO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_FORMAPAGO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_FECHAEFECTO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_FECHAVENCIMIENTO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_ANTIGUEDAD', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_PLANPAGO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_PRIMAACTUALRENOVACION', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_ACUERDO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_CLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_TIPOPRODUCTOR', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_SINIESTROSANOACTUAL', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_FECHAULTIMOSINIESTRO', 'character varying(1000)'),
    ('sca2_datos_cabecera', 'POLIZA_DTOINTEGRALIDADPOLIZA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_VIA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_DOMICILIO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_NUMERO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_PROVINCIA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_LOCALIDAD', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_CODPOSTAL', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_TELMOVIL', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_TELFIJO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_CORREO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_PISO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_PUERTA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_ESCALERA', 'character varying(255)'),
    ('sca2_datos_cabecera', 'FECHA_CACHE', 'timestamp without time zone'),
    ('sca2_datos_cabecera', 'VALIDA_HASTA', 'timestamp without time zone'),
    ('sca2_datos_cabecera', 'ORIGEN_CACHE', 'character varying(50)'),
    ('sca2_datos_cabecera', 'POLIZA_RAMO', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_CESIONDERECHOS', 'character varying(255)'),
    ('sca2_datos_cabecera', 'POLIZA_REVALORIZACION', 'character varying(255)'),
    ('sca2_datos_cabecera', 'CONTACTO_PAIS', 'character varying(255)'),
    ('sca2_datos_cabecera', 'TIPO_POLIZA', 'character varying(100)'),
    ('sca2_datos_cabecera', 'CLIENTE_CODINT', 'character varying(100)'),
    ('sca2_datos_perfiles_pca', 'ID', 'integer'),
    ('sca2_datos_perfiles_pca', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_perfiles_pca', 'CODCOMPANIA', 'character varying(255)'),
    ('sca2_datos_perfiles_pca', 'CODPERFIL', 'character varying(255)'),
    ('sca2_datos_perfiles_pca', 'CODSUBPERFIL', 'character varying(255)'),
    ('sca2_datos_perfiles_pca', 'NUUMA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ID', 'integer'),
    ('sca2_datos_poliza_autos', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_poliza_autos', 'LINEADENEGOCIO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'IDPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NIFTOMADOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NOMBREAPELLIDOSTOMADOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TIPOCLIENTE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'IDENTIFICADORCLAVE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTADOPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NUMAPLI', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ACUERDO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TIPODEACUERDO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'MARCASITUACIONPENDIENTE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'FECHAEFECTOANUALIDADCURSO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'FECHADEEFECTOANULACION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'FECHADEEFECTOINICIAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'FECHADEVENCIMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'DURACION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTADO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'PRIMAANUAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'BANCO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'PRODUCTO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'FORMADEPAGO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NOMFORMADEPAGO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'SISTEMADEBONIFICACION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NIVELBONUSRC', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NIVELMALUSRC', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CODCIAPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CODRAMO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'NUMERO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'APLICASAT', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'APLICACHEQUESEGURO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'SINIESTROSPORANYO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CODGAMA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'DESCGAMA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'FECPREMIO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CODPROMOCION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_ANTIGUEDAD', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_CATEGORIA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_TIPO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_VALOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_MARCA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_NIVELDEREPARABILIDAD', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_CODTIPCNTRLOCALIZADOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_CODTIPLOCALIZADOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'VEHICULO_MATRICULA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_CODINT', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_TIPO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_TIPODECLIENTE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_MARCAROBINSON', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_TOMADORESCONDUCTOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_FECHADENACIMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_SEXO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_CODIGOPOSTAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_ESTADOCIVIL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_TIPODOCUMENTO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_NUMDOCUMENTO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_NOMBRE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_APELLIDO1', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_APELLIDO2', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_EMAIL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_TELEFONO1', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_TELEFONO2', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'TOMADOR_CODCALIFICACION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CONDUCTOR_FECHACARNE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CONDUCTOR_FECHADENACIMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CONDUCTOR_SEXO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CONDUCTOR_CODIGOPOSTAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'CONDUCTOR_ESTADOCIVIL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREAGENTE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODCLASEAGENTE', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_DGT', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODSUBCENTRAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODOFICINADIRECTA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREDGT', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTADORECIBOS_MCAIMPAGO', 'character varying(255)'),
    ('sca2_datos_poliza_autos', 'ESTADORECIBOS_FECEFECTORECIBOIMP', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ID', 'integer'),
    ('sca2_datos_poliza_hogar', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_poliza_hogar', 'IDPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'NIFTOMADOR', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'NOMBREAPELLIDOSTOMADOR', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TIPOCLIENTE', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'IDENTIFICADORCLAVE', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTADOPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'NUMAPLI', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CLIENTEACTIVOTECUIDAMOS', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CLIENTECARTERIZADO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DTOINTEGRABILIDADNUEVAPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TREBOLES', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DESCRIPCIONTIPOVIA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'NOMBREVIA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'NUMERODOMICILIO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DESCRIPCIONLOCALIDAD', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DESCRIPCIONPROVINCIA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DESCRIPCIONPAIS', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CODIGOPOSTAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TELEFONOFIJO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TELEFONOMOVIL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'EMAIL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CODCIAPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CODRAMO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'NUMPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'LINEADENEGOCIO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'PRODUCTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'SITUACIONRIESGO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CESIONDERECHOS', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ACUERDO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TIPODEACUERDO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DESCRIPCIONRIESGO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'SUMASASEGURADAS', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'FORMADEPAGO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'FORMADECOBRO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'PRIMAANUAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'PRIMARENOVACION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'DESCUENTOS', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'USOVIVIENDA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'REGIMENVIVIENDA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'PLANPAGO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'FECEFECTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'FECHADEEFECTOANULACION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'FECULTIMOSINIESTRO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'FECHADEVENCIMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'PLANSANEAMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TIPOPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTADO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'BANCO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'OBJASEGURADO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CODCOTIZACION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TIPOVIVIENDA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'MCONSTRUIDOS', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ANIOCONSTRUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'CALIDAD', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TIPOCONSTRUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_CODINT', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_TIPO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_TIPODECLIENTE', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_MARCAROBINSON', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_TOMADORESCONDUCTOR', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_FECHADENACIMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_SEXO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_CODIGOPOSTAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_ESTADOCIVIL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_TIPODOCUMENTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_NUMDOCUMENTO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_NOMBRE', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_APELLIDO1', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_APELLIDO2', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_EMAIL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_TELEFONO1', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_TELEFONO2', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'TOMADOR_CODCALIFICACION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREAGENTE', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODCLASEAGENTE', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_DGT', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODSUBCENTRAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODOFICINADIRECTA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREDGT', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTADORECIBOS_MCAIMPAGO', 'character varying(255)'),
    ('sca2_datos_poliza_hogar', 'ESTADORECIBOS_FECEFECTORECIBOIMP', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ID', 'integer'),
    ('sca2_datos_poliza_vida', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_poliza_vida', 'CLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'LINEADENEGOCIO', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'IDPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'NIFTOMADOR', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'NOMBREAPELLIDOSTOMADOR', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'FECHADEVENCIMIENTO', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TIPOCLIENTE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'IDENTIFICADORCLAVE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTADOPOLIZA', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'NUMAPLI', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'POLICYID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'COMPANYID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'COMPANYDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ACCOUNTINGFIELDCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ACCOUNTINGFIELDDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'EFFECTIVEDATE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'DUEDATE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CAPTUREDATE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'LANGUAGECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'LANGUAGEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CURRENCYISOCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CURRENCYISODESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'POLICYSTATUSCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'POLICYSTATUSDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'POLICYSTATUSREASONCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'POLICYSTATUSREASONDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CONTRACTDURATIONYEARSNUM', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CONTRACTDURATIONMONTHSNUM', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CONTRACTDURATIONDAYSNUM', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'DUEDATEAGE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'DESTINATIONTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'DESTINATIONTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'FIRSTRECEIPTPAPERIND', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'COMMERCIALPRODUCTCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'COMMERCIALPRODUCTNAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'REINVESTMENTPOLICYID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'REINVESTMENTREASONCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'REINVESTMENTREASONDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'PURPOSECONTRACTCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'PURPOSECONTRACTDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'PREMIUMAMN', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CONTRIBUTIONFREQUENCYCODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'CONTRIBUTIONFREQUENCYDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'PAYMONTHDAYNUM', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'REVALUATIONTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'REVALUATIONTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'REVALUATIONPERC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'RIGHTSASSIGNMENT', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORCLIENTID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORPERSONTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORPERSONTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORNAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORFIRSTSURNAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORSECONDSURNAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORBIRTHDATE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODVALUE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORIDENTITYDOCUMENTTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORIDENTITYDOCUMENTTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'TOMADORIDENTITYDOCUMENTNUMBER', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOCLIENTID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOPERSONTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOPERSONTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADONAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOFIRSTSURNAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOSECONDSURNAME', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOBIRTHDATE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODID', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODVALUE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOIDENTITYDOCUMENTTYPECODE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOIDENTITYDOCUMENTTYPEDESC', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ASEGURADOIDENTITYDOCUMENTNUMBER', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCLAVEPRODUCCION', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREAGENTE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODCLASEAGENTE', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALDGT', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODSUBCENTRAL', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODOFICINADIRECTA', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREDGT', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBRESUBCENTRAL', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREOFICINADIRECTA', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALDESCCLASEMEDIADOR', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODOFICINACOMERCIAL', 'character varying(255)'),
    ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREOFICINACOMERCIAL', 'character varying(255)'),
    ('sca2_datos_productor', 'ID', 'integer'),
    ('sca2_datos_productor', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_productor', 'ACCESOSGC', 'character varying(255)'),
    ('sca2_datos_productor', 'DESCCANAL', 'character varying(255)'),
    ('sca2_datos_productor', 'DESCCLASEPROD', 'character varying(255)'),
    ('sca2_datos_productor', 'DESCSUBCANAL', 'character varying(255)'),
    ('sca2_datos_productor', 'ESREDTEL', 'character varying(255)'),
    ('sca2_datos_productor', 'ESSI24', 'character varying(255)'),
    ('sca2_datos_productor', 'ESTELE', 'character varying(255)'),
    ('sca2_datos_productor', 'IDCANAL', 'character varying(255)'),
    ('sca2_datos_productor', 'IDCLASEPROD', 'character varying(255)'),
    ('sca2_datos_productor', 'IDSUBCANAL', 'character varying(255)'),
    ('sca2_datos_productor', 'TIPOACCESOSGC', 'character varying(255)'),
    ('sca2_datos_productor', 'TIPOMEDIACION', 'character varying(255)'),
    ('sca2_datos_productor', 'ANULAEXPERTOS', 'boolean'),
    ('sca2_datos_productor', 'ANULATECNICOS', 'boolean'),
    ('sca2_datos_solicitud', 'ID', 'integer'),
    ('sca2_datos_solicitud', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_datos_solicitud', 'CANALDEEJECUCION', 'character varying(255)'),
    ('sca2_datos_solicitud', 'PERFILREDMAPFRE', 'character varying(255)'),
    ('sca2_datos_solicitud', 'FECSOLICITUDANUL', 'character varying(255)'),
    ('sca2_datos_solicitud', 'FECEFECIMPAGADO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CODCAUSA', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CODDETALLE', 'character varying(255)'),
    ('sca2_datos_solicitud', 'FECANULACION', 'character varying(255)'),
    ('sca2_datos_solicitud', 'FECIMPRESION', 'character varying(1000)'),
    ('sca2_datos_solicitud', 'CATALOGACION', 'character varying(255)'),
    ('sca2_datos_solicitud', 'FECESTADO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'ORIGEN', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CONTACTO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'ESTADOSOLICITUD', 'character varying(255)'),
    ('sca2_datos_solicitud', 'USUARIO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'MCAMECANIZADA', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CODMOTIVO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'DESCCAUSA', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CANALENTRADA', 'character varying(255)'),
    ('sca2_datos_solicitud', 'SOCIOTECUIDAMOS', 'character varying(255)'),
    ('sca2_datos_solicitud', 'PERFILTECUIDAMOS', 'character varying(255)'),
    ('sca2_datos_solicitud', 'MCAANULAEXPERTO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'MCAANULATECNICO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CODPCA', 'character varying(255)'),
    ('sca2_datos_solicitud', 'DESCPCA', 'character varying(255)'),
    ('sca2_datos_solicitud', 'CODMEDIOCOMUNICACION', 'character varying(255)'),
    ('sca2_datos_solicitud', 'TLFEXPERTO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'RSVPRIMA', 'double precision'),
    ('sca2_datos_solicitud', 'IDCOMPANIA', 'integer'),
    ('sca2_datos_solicitud', 'MCARSVPRIMA', 'character varying(5)'),
    ('sca2_datos_solicitud', 'RESP_CONTACTO', 'character varying(255)'),
    ('sca2_datos_solicitud', 'FECHA_RESP_CONTACTO', 'timestamp without time zone'),
    ('sca2_error', 'ID', 'integer'),
    ('sca2_error', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_error', 'COMANDO', 'character varying(60)'),
    ('sca2_error', 'NODO', 'character varying(100)'),
    ('sca2_error', 'CODIGO', 'character varying(40)'),
    ('sca2_error', 'MENSAJE', 'character varying(4000)'),
    ('sca2_error', 'PAYLOAD', 'text'),
    ('sca2_error', 'INTENTOS', 'integer'),
    ('sca2_error', 'PROXIMO_INTENTO', 'timestamp without time zone'),
    ('sca2_error', 'ESTADO', 'character varying(20)'),
    ('sca2_error', 'FECHA_CREACION', 'timestamp without time zone'),
    ('sca2_error', 'RESUELTO_POR', 'character varying(255)'),
    ('sca2_error', 'FECHA_RESOLUCION', 'timestamp without time zone'),
    ('sca2_llamada_servicio', 'ID', 'integer'),
    ('sca2_llamada_servicio', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_llamada_servicio', 'COMANDO', 'character varying(100)'),
    ('sca2_llamada_servicio', 'NODO', 'character varying(100)'),
    ('sca2_llamada_servicio', 'SERVICIO', 'character varying(100)'),
    ('sca2_llamada_servicio', 'RESULTADO', 'character varying(20)'),
    ('sca2_llamada_servicio', 'CODIGO_HTTP', 'integer'),
    ('sca2_llamada_servicio', 'MENSAJE_ERROR', 'character varying(1000)'),
    ('sca2_llamada_servicio', 'PROCESS_ID', 'integer'),
    ('sca2_llamada_servicio', 'FECHA_INICIO', 'timestamp without time zone'),
    ('sca2_llamada_servicio', 'FECHA_FIN', 'timestamp without time zone'),
    ('sca2_llamada_servicio', 'DURACION_MS', 'integer'),
    ('sca2_niveles_cobertura_autos', 'ID', 'integer'),
    ('sca2_niveles_cobertura_autos', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_niveles_cobertura_autos', 'GRUPODECOBERTURA', 'character varying(255)'),
    ('sca2_niveles_cobertura_autos', 'NIVELDEPRIMA', 'character varying(255)'),
    ('sca2_niveles_cobertura_autos', 'MCASINIESTRO', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'ID', 'integer'),
    ('sca2_otras_solicitudes_cabecera', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_otras_solicitudes_cabecera', 'FECSOLICITUD', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'NUMPOLIZA', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'IDLINEANEGOCIO', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'FECANUL', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'CAUSAANUL', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'FECRESOLUCION', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'CODESTSOLIC', 'character varying(255)'),
    ('sca2_otras_solicitudes_cabecera', 'IDSOLICITUDOTRA', 'character varying(255)'),
    ('sca2_solicitud', 'ID', 'integer'),
    ('sca2_solicitud', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_solicitud', 'NUM_POLIZA', 'character varying(30)'),
    ('sca2_solicitud', 'ESTADO_SOLICITUD', 'character varying(40)'),
    ('sca2_solicitud', 'INTERFAZ_ACTIVA', 'character varying(60)'),
    ('sca2_solicitud', 'PROCESO_ACTIVO', 'character varying(60)'),
    ('sca2_solicitud', 'ESTADO_TAREA', 'character varying(40)'),
    ('sca2_solicitud', 'NODO_RELANZAR', 'character varying(100)'),
    ('sca2_solicitud', 'ERROR', 'character varying(4000)'),
    ('sca2_solicitud', 'PRIORIDAD_TAREA', 'integer'),
    ('sca2_solicitud', 'CADUCIDAD_TAREA', 'timestamp without time zone'),
    ('sca2_solicitud', 'NIVEL_INTERVENCION', 'integer'),
    ('sca2_solicitud', 'FEC_INICIO_NIVEL', 'timestamp without time zone'),
    ('sca2_solicitud', 'FECHA_DIETARIO', 'date'),
    ('sca2_solicitud', 'CONTADOR_POSPONER', 'integer'),
    ('sca2_solicitud', 'MECANIZACION_REALIZADA', 'boolean'),
    ('sca2_solicitud', 'TAREA_CAPTURADA', 'boolean'),
    ('sca2_solicitud', 'ARGUMENTO_POSITIVO', 'boolean'),
    ('sca2_solicitud', 'IS_POLIZA_PRRA', 'boolean'),
    ('sca2_solicitud', 'DUE_ENVIADO', 'boolean'),
    ('sca2_solicitud', 'TRANSACTION_ID', 'integer'),
    ('sca2_solicitud', 'GRUPO_ASIGNACION', 'character varying(100)'),
    ('sca2_solicitud', 'CANAL', 'character varying(20)'),
    ('sca2_solicitud', 'IDIOMA', 'character varying(10)'),
    ('sca2_solicitud', 'ID_NEGOCIO', 'character varying(20)'),
    ('sca2_solicitud', 'ROL', 'character varying(40)'),
    ('sca2_solicitud', 'USUARIO', 'character varying(100)'),
    ('sca2_solicitud', 'ORIGEN_POLIZA', 'character varying(20)'),
    ('sca2_solicitud', 'LINEA_NEGOCIO', 'character varying(20)'),
    ('sca2_solicitud', 'VERSION', 'integer'),
    ('sca2_solicitud', 'BLOQUEADO_POR', 'character varying(100)'),
    ('sca2_solicitud', 'BLOQUEADO_HASTA', 'timestamp without time zone'),
    ('sca2_solicitud', 'CREATED_BY', 'character varying(255)'),
    ('sca2_solicitud', 'CREATED_AT', 'timestamp without time zone'),
    ('sca2_solicitud', 'MODIFIED_BY', 'character varying(255)'),
    ('sca2_solicitud', 'MODIFIED_AT', 'timestamp without time zone'),
    ('sca2_tarea', 'ID', 'integer'),
    ('sca2_tarea', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_tarea', 'NUM_POLIZA', 'character varying(30)'),
    ('sca2_tarea', 'NOMBRE_TAREA', 'character varying(100)'),
    ('sca2_tarea', 'TIPO', 'character varying(40)'),
    ('sca2_tarea', 'ESTADO', 'character varying(20)'),
    ('sca2_tarea', 'PROCESO', 'character varying(60)'),
    ('sca2_tarea', 'PROPIETARIO', 'character varying(255)'),
    ('sca2_tarea', 'ASIGNADO_A', 'character varying(255)'),
    ('sca2_tarea', 'GRUPO', 'character varying(100)'),
    ('sca2_tarea', 'PRIORIDAD', 'integer'),
    ('sca2_tarea', 'FECHA_CREACION', 'timestamp without time zone'),
    ('sca2_tarea', 'FECHA_CADUCIDAD', 'timestamp without time zone'),
    ('sca2_tarea', 'FECHA_CAPTURA', 'timestamp without time zone'),
    ('sca2_tarea', 'FECHA_CIERRE', 'timestamp without time zone'),
    ('sca2_tarea', 'DUE_ENVIADO', 'boolean'),
    ('sca2_tarea', 'TOKEN_TAREA', 'character varying(64)'),
    ('sca2_transicion', 'ID', 'integer'),
    ('sca2_transicion', 'ID_SOLICITUD', 'character varying(50)'),
    ('sca2_transicion', 'COMANDO', 'character varying(60)'),
    ('sca2_transicion', 'ESTADO_ORIGEN', 'character varying(40)'),
    ('sca2_transicion', 'ESTADO_DESTINO', 'character varying(40)'),
    ('sca2_transicion', 'CLAVE_IDEMPOTENCIA', 'character varying(200)'),
    ('sca2_transicion', 'RESULTADO', 'character varying(20)'),
    ('sca2_transicion', 'DETALLE', 'character varying(4000)'),
    ('sca2_transicion', 'PROCESS_ID', 'integer'),
    ('sca2_transicion', 'USUARIO', 'character varying(255)'),
    ('sca2_transicion', 'FECHA', 'timestamp without time zone'),
    ('sca2_transicion', 'DURACION_MS', 'integer'),
    ('sca2_trazabilidad_cliente', 'ID', 'integer'),
    ('sca2_trazabilidad_cliente', 'FECHA', 'timestamp without time zone'),
    ('sca2_trazabilidad_cliente', 'SISTEMA', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'PLATAFORMA', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'IP', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'PERFIL_USUARIO', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'OPERACION', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'RESULTADO_OPERACION', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'CLIENTE', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'POLIZA', 'character varying(255)'),
    ('sca2_trazabilidad_cliente', 'TIPO_PERSONA', 'character varying(255)')
  ) AS e(tabla, columna, tipo)
  LOOP
    SELECT format_type(a.atttypid, a.atttypmod) INTO actual
      FROM pg_attribute a JOIN pg_class c ON c.oid = a.attrelid JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'sca2_anulaciones' AND c.relname = r.tabla AND a.attname = r.columna AND a.attnum > 0 AND NOT a.attisdropped;
    IF actual IS NULL OR actual = r.tipo THEN CONTINUE; END IF;
    IF actual LIKE 'character varying(%' AND r.tipo LIKE 'character varying(%' THEN
      la := substring(actual from '\((\d+)\)')::int; le := substring(r.tipo from '\((\d+)\)')::int;
      IF le > la THEN
        EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I TYPE %s', r.tabla, r.columna, r.tipo);
        RAISE NOTICE 'Ampliado %.%: % -> %', r.tabla, r.columna, actual, r.tipo;
      ELSE
        RAISE WARNING 'No se reduce %.%: actual %, esperado % (revisar DBA)', r.tabla, r.columna, actual, r.tipo;
      END IF;
    ELSIF (actual LIKE 'character varying%' OR actual = 'character(1)') AND r.tipo = 'text'
       OR actual = 'smallint' AND r.tipo IN ('integer', 'bigint')
       OR actual = 'integer' AND r.tipo = 'bigint' THEN
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I TYPE %s', r.tabla, r.columna, r.tipo);
      RAISE NOTICE 'Ampliado %.%: % -> %', r.tabla, r.columna, actual, r.tipo;
    ELSIF actual IN ('smallint', 'integer', 'bigint') AND (r.tipo = 'text' OR (r.tipo LIKE 'character varying(%'
          AND substring(r.tipo from '\((\d+)\)')::int >= 20)) THEN
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I TYPE %s USING %I::text', r.tabla, r.columna, r.tipo, r.columna);
      RAISE NOTICE 'Convertido %.%: % -> %', r.tabla, r.columna, actual, r.tipo;
    ELSE
      RAISE WARNING 'Tipo distinto en %.%: actual %, esperado % (no se cambia; revisar DBA)', r.tabla, r.columna, actual, r.tipo;
    END IF;
  END LOOP;
END $$;

-- ---------------------------------------------------------------
-- Claves primarias, autonumérico de ID y claves únicas que falten
-- ---------------------------------------------------------------
DO $$
DECLARE
  r record; seq text; rel regclass;
BEGIN
  FOR r IN SELECT * FROM (VALUES
    ('sca2_cat_causa', 'ID', true),
    ('sca2_cat_concepto', 'ID', true),
    ('sca2_cat_detalle', 'ID', true),
    ('sca2_cat_motivo', 'ID', true),
    ('sca2_cat_tipo_argumento', 'ID', true),
    ('sca2_cat_valor_concepto', 'ID', true),
    ('sca2_datos_basicos_solicitud', 'ID', true),
    ('sca2_datos_cabecera', 'ID', true),
    ('sca2_datos_perfiles_pca', 'ID', true),
    ('sca2_datos_poliza_autos', 'ID', true),
    ('sca2_datos_poliza_hogar', 'ID', true),
    ('sca2_datos_poliza_vida', 'ID', true),
    ('sca2_datos_productor', 'ID', true),
    ('sca2_datos_solicitud', 'ID', true),
    ('sca2_error', 'ID', true),
    ('sca2_llamada_servicio', 'ID', true),
    ('sca2_niveles_cobertura_autos', 'ID', true),
    ('sca2_otras_solicitudes_cabecera', 'ID', true),
    ('sca2_solicitud', 'ID', true),
    ('sca2_tarea', 'ID', true),
    ('sca2_transicion', 'ID', true),
    ('sca2_trazabilidad_cliente', 'ID', true)
  ) AS e(tabla, columna, autonumerico)
  LOOP
    rel := format('sca2_anulaciones.%I', r.tabla)::regclass;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = rel AND contype = 'p') THEN
      BEGIN
        EXECUTE format('ALTER TABLE sca2_anulaciones.%I ADD PRIMARY KEY (%I)', r.tabla, r.columna);
        RAISE NOTICE 'PK añadida en %.%', r.tabla, r.columna;
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'No se pudo añadir la PK en %.%: % (revisar duplicados/nulos)', r.tabla, r.columna, SQLERRM;
      END;
    END IF;
    IF r.autonumerico AND NOT EXISTS (
         SELECT 1 FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
          WHERE a.attrelid = rel AND a.attname = r.columna AND (a.attidentity <> '' OR d.adbin IS NOT NULL)) THEN
      seq := r.tabla || '_' || r.columna || '_seq';
      EXECUTE format('CREATE SEQUENCE IF NOT EXISTS sca2_anulaciones.%I OWNED BY sca2_anulaciones.%I.%I', seq, r.tabla, r.columna);
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I SET DEFAULT nextval(%L)', r.tabla, r.columna, 'sca2_anulaciones.' || quote_ident(seq));
      EXECUTE format('SELECT setval(%L, COALESCE((SELECT max(%I) FROM sca2_anulaciones.%I), 0) + 1, false)', 'sca2_anulaciones.' || quote_ident(seq), r.columna, r.tabla);
      RAISE NOTICE 'Autonumérico añadido en %.% (secuencia %)', r.tabla, r.columna, seq;
    END IF;
  END LOOP;
  FOR r IN SELECT * FROM (VALUES
    ('sca2_solicitud', 'ID_SOLICITUD'),
    ('sca2_transicion', 'CLAVE_IDEMPOTENCIA')
  ) AS e(tabla, columna)
  LOOP
    rel := format('sca2_anulaciones.%I', r.tabla)::regclass;
    IF NOT EXISTS (
         SELECT 1 FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = i.indkey[0]
          WHERE i.indrelid = rel AND i.indisunique AND i.indnatts = 1 AND a.attname = r.columna) THEN
      BEGIN
        EXECUTE format('ALTER TABLE sca2_anulaciones.%I ADD CONSTRAINT %I UNIQUE (%I)', r.tabla, left(r.tabla || '_' || lower(r.columna) || '_key', 63), r.columna);
        RAISE NOTICE 'UNIQUE añadida en %.%', r.tabla, r.columna;
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'No se pudo añadir UNIQUE en %.%: % (revisar duplicados)', r.tabla, r.columna, SQLERRM;
      END;
    END IF;
  END LOOP;
END $$;

-- ---------------------------------------------------------------
-- Índices de consulta (póliza, solicitud y estado)
-- ---------------------------------------------------------------
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_cat_tipo_argumento_cod_estado ON sca2_cat_tipo_argumento ("COD_ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_basicos_solicitud_id_solicitud ON sca2_datos_basicos_solicitud ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_cabecera_id_solicitud ON sca2_datos_cabecera ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_perfiles_pca_id_solicitud ON sca2_datos_perfiles_pca ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_autos_id_solicitud ON sca2_datos_poliza_autos ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_autos_estadopoliza ON sca2_datos_poliza_autos ("ESTADOPOLIZA");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_autos_estado ON sca2_datos_poliza_autos ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_hogar_id_solicitud ON sca2_datos_poliza_hogar ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_hogar_estadopoliza ON sca2_datos_poliza_hogar ("ESTADOPOLIZA");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_hogar_estado ON sca2_datos_poliza_hogar ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_vida_id_solicitud ON sca2_datos_poliza_vida ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_vida_estadopoliza ON sca2_datos_poliza_vida ("ESTADOPOLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_productor_id_solicitud ON sca2_datos_productor ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_solicitud_id_solicitud ON sca2_datos_solicitud ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_datos_solicitud_estadosolicitud ON sca2_datos_solicitud ("ESTADOSOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_error_id_solicitud ON sca2_error ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_error_estado ON sca2_error ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_llamada_servicio_id_solicitud ON sca2_llamada_servicio ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_niveles_cobertura_autos_id_solicitud ON sca2_niveles_cobertura_autos ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_otras_solicitudes_cabecera_id_solicitud ON sca2_otras_solicitudes_cabecera ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_num_poliza ON sca2_solicitud ("NUM_POLIZA");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_estado_solicitud ON sca2_solicitud ("ESTADO_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_estado_tarea ON sca2_solicitud ("ESTADO_TAREA");
CREATE INDEX IF NOT EXISTS ix_sca2_tarea_id_solicitud ON sca2_tarea ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_tarea_num_poliza ON sca2_tarea ("NUM_POLIZA");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_tarea_estado ON sca2_tarea ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_transicion_id_solicitud ON sca2_transicion ("ID_SOLICITUD");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_transicion_estado_origen ON sca2_transicion ("ESTADO_ORIGEN");
-- No existe en TEST (doc 66 §2): CREATE INDEX IF NOT EXISTS ix_sca2_transicion_estado_destino ON sca2_transicion ("ESTADO_DESTINO");
-- Claves naturales de catálogos (43-C). Si hay duplicados, avisa y no la crea.
DO $$
BEGIN
  BEGIN
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_motivo ON sca2_anulaciones.sca2_cat_motivo ("COD_LINEA_NEGOCIO", "COD_PERFIL", "COD_SUB_PERFIL", "COD_MOTIVO")';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_motivo: % (revisar duplicados)', SQLERRM;
  END;
  BEGIN
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_detalle ON sca2_anulaciones.sca2_cat_detalle ("COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE")';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_detalle: % (revisar duplicados)', SQLERRM;
  END;
  BEGIN
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_causa ON sca2_anulaciones.sca2_cat_causa ("COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE", "COD_PERFIL", "COD_CAUSA")';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_causa: % (revisar duplicados)', SQLERRM;
  END;
  BEGIN
    -- Como en TEST: único solo entre filas activas (COD_TP_ARG 999 existe activo e inactivo).
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_tipo_argumento_activo ON sca2_anulaciones.sca2_cat_tipo_argumento ("COD_TP_ARG") WHERE "ACTIVO"';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_tipo_argumento_activo: % (revisar duplicados activos)', SQLERRM;
  END;
  BEGIN
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_concepto ON sca2_anulaciones.sca2_cat_concepto ("IDN_CONCEPTO_PCA")';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_concepto: % (revisar duplicados)', SQLERRM;
  END;
  BEGIN
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_valor_concepto ON sca2_anulaciones.sca2_cat_valor_concepto ("IDN_CONCEPTO_PCA", "IDN_PCA")';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_valor_concepto: % (revisar duplicados)', SQLERRM;
  END;
END $$;

-- ---------------------------------------------------------------
-- Aviso de columnas que existen en BD y SCA2 ya no usa (no se borran)
-- ---------------------------------------------------------------
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT c.relname AS tabla, a.attname AS columna
             FROM pg_attribute a JOIN pg_class c ON c.oid = a.attrelid JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'sca2_anulaciones' AND c.relkind = 'r' AND a.attnum > 0 AND NOT a.attisdropped
              AND c.relname IN ('sca2_cat_causa', 'sca2_cat_concepto', 'sca2_cat_detalle', 'sca2_cat_motivo', 'sca2_cat_tipo_argumento', 'sca2_cat_valor_concepto', 'sca2_datos_basicos_solicitud', 'sca2_datos_cabecera', 'sca2_datos_perfiles_pca', 'sca2_datos_poliza_autos', 'sca2_datos_poliza_hogar', 'sca2_datos_poliza_vida', 'sca2_datos_productor', 'sca2_datos_solicitud', 'sca2_error', 'sca2_llamada_servicio', 'sca2_niveles_cobertura_autos', 'sca2_otras_solicitudes_cabecera', 'sca2_solicitud', 'sca2_tarea', 'sca2_transicion', 'sca2_trazabilidad_cliente')
              AND (c.relname, a.attname) NOT IN (SELECT * FROM (VALUES
                ('sca2_cat_causa', 'ID'),
                ('sca2_cat_causa', 'COD_LINEA_NEGOCIO'),
                ('sca2_cat_causa', 'COD_MOTIVO'),
                ('sca2_cat_causa', 'COD_DETALLE'),
                ('sca2_cat_causa', 'COD_PERFIL'),
                ('sca2_cat_causa', 'COD_CAUSA'),
                ('sca2_cat_causa', 'DESCRIPCION'),
                ('sca2_cat_causa', 'ORDEN'),
                ('sca2_cat_causa', 'ACTIVO'),
                ('sca2_cat_causa', 'ORIGEN'),
                ('sca2_cat_causa', 'FECHA_ALTA'),
                ('sca2_cat_causa', 'FECHA_MODIFICACION'),
                ('sca2_cat_causa', 'USUARIO_MODIFICACION'),
                ('sca2_cat_concepto', 'ID'),
                ('sca2_cat_concepto', 'IDN_CONCEPTO_PCA'),
                ('sca2_cat_concepto', 'DES_CONCEPTO_PCA'),
                ('sca2_cat_concepto', 'MCA_INH'),
                ('sca2_cat_concepto', 'FEC_ACTU'),
                ('sca2_cat_concepto', 'ORDEN'),
                ('sca2_cat_concepto', 'ACTIVO'),
                ('sca2_cat_concepto', 'ORIGEN'),
                ('sca2_cat_concepto', 'FECHA_ALTA'),
                ('sca2_cat_concepto', 'FECHA_MODIFICACION'),
                ('sca2_cat_concepto', 'USUARIO_MODIFICACION'),
                ('sca2_cat_detalle', 'ID'),
                ('sca2_cat_detalle', 'COD_LINEA_NEGOCIO'),
                ('sca2_cat_detalle', 'COD_MOTIVO'),
                ('sca2_cat_detalle', 'COD_DETALLE'),
                ('sca2_cat_detalle', 'DESCRIPCION'),
                ('sca2_cat_detalle', 'ORDEN'),
                ('sca2_cat_detalle', 'ACTIVO'),
                ('sca2_cat_detalle', 'ORIGEN'),
                ('sca2_cat_detalle', 'FECHA_ALTA'),
                ('sca2_cat_detalle', 'FECHA_MODIFICACION'),
                ('sca2_cat_detalle', 'USUARIO_MODIFICACION'),
                ('sca2_cat_motivo', 'ID'),
                ('sca2_cat_motivo', 'COD_LINEA_NEGOCIO'),
                ('sca2_cat_motivo', 'COD_PERFIL'),
                ('sca2_cat_motivo', 'COD_SUB_PERFIL'),
                ('sca2_cat_motivo', 'COD_MOTIVO'),
                ('sca2_cat_motivo', 'DESCRIPCION'),
                ('sca2_cat_motivo', 'ORDEN'),
                ('sca2_cat_motivo', 'ACTIVO'),
                ('sca2_cat_motivo', 'ORIGEN'),
                ('sca2_cat_motivo', 'FECHA_ALTA'),
                ('sca2_cat_motivo', 'FECHA_MODIFICACION'),
                ('sca2_cat_motivo', 'USUARIO_MODIFICACION'),
                ('sca2_cat_tipo_argumento', 'ID'),
                ('sca2_cat_tipo_argumento', 'COD_TP_ARG'),
                ('sca2_cat_tipo_argumento', 'DESC_ARG'),
                ('sca2_cat_tipo_argumento', 'COD_ESTADO'),
                ('sca2_cat_tipo_argumento', 'ID_LINEA_NEGOCIO'),
                ('sca2_cat_tipo_argumento', 'ID_RAMO'),
                ('sca2_cat_tipo_argumento', 'COD_COMPANIA'),
                ('sca2_cat_tipo_argumento', 'COD_COMPANIA_ARG'),
                ('sca2_cat_tipo_argumento', 'APLI_ARGUMENTO'),
                ('sca2_cat_tipo_argumento', 'INSTRUCCION'),
                ('sca2_cat_tipo_argumento', 'MCA_FINALIZADO'),
                ('sca2_cat_tipo_argumento', 'NOMBRE_DOC'),
                ('sca2_cat_tipo_argumento', 'NUM_DOC'),
                ('sca2_cat_tipo_argumento', 'OBSERVACIONES'),
                ('sca2_cat_tipo_argumento', 'FEC_VIGENCIA'),
                ('sca2_cat_tipo_argumento', 'FEC_MODIFICADO'),
                ('sca2_cat_tipo_argumento', 'COD_ID_CAMPANA'),
                ('sca2_cat_tipo_argumento', 'COD_TIP_BON'),
                ('sca2_cat_tipo_argumento', 'NUM_TIP_BON'),
                ('sca2_cat_tipo_argumento', 'REGATEABLE'),
                ('sca2_cat_tipo_argumento', 'MCA_TE_CUIDAMOS'),
                ('sca2_cat_tipo_argumento', 'NUM_DIAS_SGO'),
                ('sca2_cat_tipo_argumento', 'COD_TAREA_SGO'),
                ('sca2_cat_tipo_argumento', 'TXT_URL_ARG'),
                ('sca2_cat_tipo_argumento', 'MCA_TREB_CALC'),
                ('sca2_cat_tipo_argumento', 'ORDEN'),
                ('sca2_cat_tipo_argumento', 'ACTIVO'),
                ('sca2_cat_tipo_argumento', 'ORIGEN'),
                ('sca2_cat_tipo_argumento', 'FECHA_ALTA'),
                ('sca2_cat_tipo_argumento', 'FECHA_MODIFICACION'),
                ('sca2_cat_tipo_argumento', 'USUARIO_MODIFICACION'),
                ('sca2_cat_valor_concepto', 'ID'),
                ('sca2_cat_valor_concepto', 'IDN_CONCEPTO_PCA'),
                ('sca2_cat_valor_concepto', 'IDN_PCA'),
                ('sca2_cat_valor_concepto', 'VALOR_CONCEPTO'),
                ('sca2_cat_valor_concepto', 'DES_CONCEPTO'),
                ('sca2_cat_valor_concepto', 'MCA_INH'),
                ('sca2_cat_valor_concepto', 'FEC_ACTU'),
                ('sca2_cat_valor_concepto', 'ORDEN'),
                ('sca2_cat_valor_concepto', 'ACTIVO'),
                ('sca2_cat_valor_concepto', 'ORIGEN'),
                ('sca2_cat_valor_concepto', 'FECHA_ALTA'),
                ('sca2_cat_valor_concepto', 'FECHA_MODIFICACION'),
                ('sca2_cat_valor_concepto', 'USUARIO_MODIFICACION'),
                ('sca2_datos_basicos_solicitud', 'ID'),
                ('sca2_datos_basicos_solicitud', 'ID_SOLICITUD'),
                ('sca2_datos_basicos_solicitud', 'NUMPOLIZA'),
                ('sca2_datos_basicos_solicitud', 'CODPRODUCTO'),
                ('sca2_datos_basicos_solicitud', 'DESCPRODUCTO'),
                ('sca2_datos_basicos_solicitud', 'IDGESTIONSGC'),
                ('sca2_datos_basicos_solicitud', 'CODRAMO'),
                ('sca2_datos_basicos_solicitud', 'CODCIACONTRARIA'),
                ('sca2_datos_basicos_solicitud', 'NUMFAX'),
                ('sca2_datos_cabecera', 'ID'),
                ('sca2_datos_cabecera', 'ID_SOLICITUD'),
                ('sca2_datos_cabecera', 'CLIENTE_NOMBRE'),
                ('sca2_datos_cabecera', 'CLIENTE_APELLIDOS'),
                ('sca2_datos_cabecera', 'CLIENTE_NIF'),
                ('sca2_datos_cabecera', 'CLIENTE_APODERADO'),
                ('sca2_datos_cabecera', 'CLIENTE_CARTERIZADO'),
                ('sca2_datos_cabecera', 'CLIENTE_NUUMAPROPIETARIO'),
                ('sca2_datos_cabecera', 'CLIENTE_RSVPRIMA'),
                ('sca2_datos_cabecera', 'CLIENTE_DTOINTEGRALIDADNUEVAPRODUCCION'),
                ('sca2_datos_cabecera', 'CLIENTE_TREBOLES'),
                ('sca2_datos_cabecera', 'CLIENTE_ACTIVOCLUBMAPFRE'),
                ('sca2_datos_cabecera', 'CLIENTE_PERFILCLUBMAPFRE'),
                ('sca2_datos_cabecera', 'CLIENTE_TIPOCLIENTEVALOR'),
                ('sca2_datos_cabecera', 'CLIENTE_TIPOCLIENTEDESC'),
                ('sca2_datos_cabecera', 'CLIENTE_IDCLIENTE'),
                ('sca2_datos_cabecera', 'POLIZA_NUMEROPOLIZA'),
                ('sca2_datos_cabecera', 'POLIZA_NOMBREPRODUCTO'),
                ('sca2_datos_cabecera', 'POLIZA_VEHICULO'),
                ('sca2_datos_cabecera', 'POLIZA_LINEANEGOCIO'),
                ('sca2_datos_cabecera', 'POLIZA_FORMAPAGO'),
                ('sca2_datos_cabecera', 'POLIZA_FECHAEFECTO'),
                ('sca2_datos_cabecera', 'POLIZA_FECHAVENCIMIENTO'),
                ('sca2_datos_cabecera', 'POLIZA_ANTIGUEDAD'),
                ('sca2_datos_cabecera', 'POLIZA_PLANPAGO'),
                ('sca2_datos_cabecera', 'POLIZA_PRIMAACTUALRENOVACION'),
                ('sca2_datos_cabecera', 'POLIZA_ACUERDO'),
                ('sca2_datos_cabecera', 'POLIZA_CLAVEPRODUCCION'),
                ('sca2_datos_cabecera', 'POLIZA_TIPOPRODUCTOR'),
                ('sca2_datos_cabecera', 'POLIZA_SINIESTROSANOACTUAL'),
                ('sca2_datos_cabecera', 'POLIZA_FECHAULTIMOSINIESTRO'),
                ('sca2_datos_cabecera', 'POLIZA_DTOINTEGRALIDADPOLIZA'),
                ('sca2_datos_cabecera', 'CONTACTO_VIA'),
                ('sca2_datos_cabecera', 'CONTACTO_DOMICILIO'),
                ('sca2_datos_cabecera', 'CONTACTO_NUMERO'),
                ('sca2_datos_cabecera', 'CONTACTO_PROVINCIA'),
                ('sca2_datos_cabecera', 'CONTACTO_LOCALIDAD'),
                ('sca2_datos_cabecera', 'CONTACTO_CODPOSTAL'),
                ('sca2_datos_cabecera', 'CONTACTO_TELMOVIL'),
                ('sca2_datos_cabecera', 'CONTACTO_TELFIJO'),
                ('sca2_datos_cabecera', 'CONTACTO_CORREO'),
                ('sca2_datos_cabecera', 'CONTACTO_PISO'),
                ('sca2_datos_cabecera', 'CONTACTO_PUERTA'),
                ('sca2_datos_cabecera', 'CONTACTO_ESCALERA'),
                ('sca2_datos_cabecera', 'FECHA_CACHE'),
                ('sca2_datos_cabecera', 'VALIDA_HASTA'),
                ('sca2_datos_cabecera', 'ORIGEN_CACHE'),
                ('sca2_datos_cabecera', 'POLIZA_RAMO'),
                ('sca2_datos_cabecera', 'POLIZA_CESIONDERECHOS'),
                ('sca2_datos_cabecera', 'POLIZA_REVALORIZACION'),
                ('sca2_datos_cabecera', 'CONTACTO_PAIS'),
                ('sca2_datos_cabecera', 'TIPO_POLIZA'),
                ('sca2_datos_cabecera', 'CLIENTE_CODINT'),
                ('sca2_datos_perfiles_pca', 'ID'),
                ('sca2_datos_perfiles_pca', 'ID_SOLICITUD'),
                ('sca2_datos_perfiles_pca', 'CODCOMPANIA'),
                ('sca2_datos_perfiles_pca', 'CODPERFIL'),
                ('sca2_datos_perfiles_pca', 'CODSUBPERFIL'),
                ('sca2_datos_perfiles_pca', 'NUUMA'),
                ('sca2_datos_poliza_autos', 'ID'),
                ('sca2_datos_poliza_autos', 'ID_SOLICITUD'),
                ('sca2_datos_poliza_autos', 'LINEADENEGOCIO'),
                ('sca2_datos_poliza_autos', 'IDPOLIZA'),
                ('sca2_datos_poliza_autos', 'NIFTOMADOR'),
                ('sca2_datos_poliza_autos', 'NOMBREAPELLIDOSTOMADOR'),
                ('sca2_datos_poliza_autos', 'TIPOCLIENTE'),
                ('sca2_datos_poliza_autos', 'IDENTIFICADORCLAVE'),
                ('sca2_datos_poliza_autos', 'ESTADOPOLIZA'),
                ('sca2_datos_poliza_autos', 'NUMAPLI'),
                ('sca2_datos_poliza_autos', 'ACUERDO'),
                ('sca2_datos_poliza_autos', 'TIPODEACUERDO'),
                ('sca2_datos_poliza_autos', 'MARCASITUACIONPENDIENTE'),
                ('sca2_datos_poliza_autos', 'FECHAEFECTOANUALIDADCURSO'),
                ('sca2_datos_poliza_autos', 'FECHADEEFECTOANULACION'),
                ('sca2_datos_poliza_autos', 'FECHADEEFECTOINICIAL'),
                ('sca2_datos_poliza_autos', 'FECHADEVENCIMIENTO'),
                ('sca2_datos_poliza_autos', 'DURACION'),
                ('sca2_datos_poliza_autos', 'ESTADO'),
                ('sca2_datos_poliza_autos', 'PRIMAANUAL'),
                ('sca2_datos_poliza_autos', 'BANCO'),
                ('sca2_datos_poliza_autos', 'PRODUCTO'),
                ('sca2_datos_poliza_autos', 'CLAVEPRODUCCION'),
                ('sca2_datos_poliza_autos', 'FORMADEPAGO'),
                ('sca2_datos_poliza_autos', 'NOMFORMADEPAGO'),
                ('sca2_datos_poliza_autos', 'SISTEMADEBONIFICACION'),
                ('sca2_datos_poliza_autos', 'NIVELBONUSRC'),
                ('sca2_datos_poliza_autos', 'NIVELMALUSRC'),
                ('sca2_datos_poliza_autos', 'CODCIAPOLIZA'),
                ('sca2_datos_poliza_autos', 'CODRAMO'),
                ('sca2_datos_poliza_autos', 'NUMERO'),
                ('sca2_datos_poliza_autos', 'APLICASAT'),
                ('sca2_datos_poliza_autos', 'APLICACHEQUESEGURO'),
                ('sca2_datos_poliza_autos', 'SINIESTROSPORANYO'),
                ('sca2_datos_poliza_autos', 'CODGAMA'),
                ('sca2_datos_poliza_autos', 'DESCGAMA'),
                ('sca2_datos_poliza_autos', 'FECPREMIO'),
                ('sca2_datos_poliza_autos', 'CODPROMOCION'),
                ('sca2_datos_poliza_autos', 'VEHICULO_ANTIGUEDAD'),
                ('sca2_datos_poliza_autos', 'VEHICULO_CATEGORIA'),
                ('sca2_datos_poliza_autos', 'VEHICULO_TIPO'),
                ('sca2_datos_poliza_autos', 'VEHICULO_VALOR'),
                ('sca2_datos_poliza_autos', 'VEHICULO_MARCA'),
                ('sca2_datos_poliza_autos', 'VEHICULO_NIVELDEREPARABILIDAD'),
                ('sca2_datos_poliza_autos', 'VEHICULO_CODTIPCNTRLOCALIZADOR'),
                ('sca2_datos_poliza_autos', 'VEHICULO_CODTIPLOCALIZADOR'),
                ('sca2_datos_poliza_autos', 'VEHICULO_MATRICULA'),
                ('sca2_datos_poliza_autos', 'TOMADOR_CODINT'),
                ('sca2_datos_poliza_autos', 'TOMADOR_TIPO'),
                ('sca2_datos_poliza_autos', 'TOMADOR_TIPODECLIENTE'),
                ('sca2_datos_poliza_autos', 'TOMADOR_MARCAROBINSON'),
                ('sca2_datos_poliza_autos', 'TOMADOR_TOMADORESCONDUCTOR'),
                ('sca2_datos_poliza_autos', 'TOMADOR_FECHADENACIMIENTO'),
                ('sca2_datos_poliza_autos', 'TOMADOR_SEXO'),
                ('sca2_datos_poliza_autos', 'TOMADOR_CODIGOPOSTAL'),
                ('sca2_datos_poliza_autos', 'TOMADOR_ESTADOCIVIL'),
                ('sca2_datos_poliza_autos', 'TOMADOR_TIPODOCUMENTO'),
                ('sca2_datos_poliza_autos', 'TOMADOR_NUMDOCUMENTO'),
                ('sca2_datos_poliza_autos', 'TOMADOR_NOMBRE'),
                ('sca2_datos_poliza_autos', 'TOMADOR_APELLIDO1'),
                ('sca2_datos_poliza_autos', 'TOMADOR_APELLIDO2'),
                ('sca2_datos_poliza_autos', 'TOMADOR_EMAIL'),
                ('sca2_datos_poliza_autos', 'TOMADOR_TELEFONO1'),
                ('sca2_datos_poliza_autos', 'TOMADOR_TELEFONO2'),
                ('sca2_datos_poliza_autos', 'TOMADOR_CODCALIFICACION'),
                ('sca2_datos_poliza_autos', 'CONDUCTOR_FECHACARNE'),
                ('sca2_datos_poliza_autos', 'CONDUCTOR_FECHADENACIMIENTO'),
                ('sca2_datos_poliza_autos', 'CONDUCTOR_SEXO'),
                ('sca2_datos_poliza_autos', 'CONDUCTOR_CODIGOPOSTAL'),
                ('sca2_datos_poliza_autos', 'CONDUCTOR_ESTADOCIVIL'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CLAVEPRODUCCION'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREAGENTE'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODCLASEAGENTE'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_DGT'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODSUBCENTRAL'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODOFICINADIRECTA'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREDGT'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL'),
                ('sca2_datos_poliza_autos', 'ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL'),
                ('sca2_datos_poliza_autos', 'ESTADORECIBOS_MCAIMPAGO'),
                ('sca2_datos_poliza_autos', 'ESTADORECIBOS_FECEFECTORECIBOIMP'),
                ('sca2_datos_poliza_hogar', 'ID'),
                ('sca2_datos_poliza_hogar', 'ID_SOLICITUD'),
                ('sca2_datos_poliza_hogar', 'IDPOLIZA'),
                ('sca2_datos_poliza_hogar', 'NIFTOMADOR'),
                ('sca2_datos_poliza_hogar', 'NOMBREAPELLIDOSTOMADOR'),
                ('sca2_datos_poliza_hogar', 'TIPOCLIENTE'),
                ('sca2_datos_poliza_hogar', 'IDENTIFICADORCLAVE'),
                ('sca2_datos_poliza_hogar', 'ESTADOPOLIZA'),
                ('sca2_datos_poliza_hogar', 'NUMAPLI'),
                ('sca2_datos_poliza_hogar', 'CLIENTEACTIVOTECUIDAMOS'),
                ('sca2_datos_poliza_hogar', 'CLIENTECARTERIZADO'),
                ('sca2_datos_poliza_hogar', 'DTOINTEGRABILIDADNUEVAPRODUCCION'),
                ('sca2_datos_poliza_hogar', 'TREBOLES'),
                ('sca2_datos_poliza_hogar', 'DESCRIPCIONTIPOVIA'),
                ('sca2_datos_poliza_hogar', 'NOMBREVIA'),
                ('sca2_datos_poliza_hogar', 'NUMERODOMICILIO'),
                ('sca2_datos_poliza_hogar', 'DESCRIPCIONLOCALIDAD'),
                ('sca2_datos_poliza_hogar', 'DESCRIPCIONPROVINCIA'),
                ('sca2_datos_poliza_hogar', 'DESCRIPCIONPAIS'),
                ('sca2_datos_poliza_hogar', 'CODIGOPOSTAL'),
                ('sca2_datos_poliza_hogar', 'TELEFONOFIJO'),
                ('sca2_datos_poliza_hogar', 'TELEFONOMOVIL'),
                ('sca2_datos_poliza_hogar', 'EMAIL'),
                ('sca2_datos_poliza_hogar', 'CODCIAPOLIZA'),
                ('sca2_datos_poliza_hogar', 'CODRAMO'),
                ('sca2_datos_poliza_hogar', 'NUMPOLIZA'),
                ('sca2_datos_poliza_hogar', 'LINEADENEGOCIO'),
                ('sca2_datos_poliza_hogar', 'PRODUCTO'),
                ('sca2_datos_poliza_hogar', 'SITUACIONRIESGO'),
                ('sca2_datos_poliza_hogar', 'CESIONDERECHOS'),
                ('sca2_datos_poliza_hogar', 'ACUERDO'),
                ('sca2_datos_poliza_hogar', 'TIPODEACUERDO'),
                ('sca2_datos_poliza_hogar', 'DESCRIPCIONRIESGO'),
                ('sca2_datos_poliza_hogar', 'SUMASASEGURADAS'),
                ('sca2_datos_poliza_hogar', 'FORMADEPAGO'),
                ('sca2_datos_poliza_hogar', 'FORMADECOBRO'),
                ('sca2_datos_poliza_hogar', 'PRIMAANUAL'),
                ('sca2_datos_poliza_hogar', 'PRIMARENOVACION'),
                ('sca2_datos_poliza_hogar', 'DESCUENTOS'),
                ('sca2_datos_poliza_hogar', 'USOVIVIENDA'),
                ('sca2_datos_poliza_hogar', 'REGIMENVIVIENDA'),
                ('sca2_datos_poliza_hogar', 'PLANPAGO'),
                ('sca2_datos_poliza_hogar', 'FECEFECTO'),
                ('sca2_datos_poliza_hogar', 'FECHADEEFECTOANULACION'),
                ('sca2_datos_poliza_hogar', 'FECULTIMOSINIESTRO'),
                ('sca2_datos_poliza_hogar', 'FECHADEVENCIMIENTO'),
                ('sca2_datos_poliza_hogar', 'PLANSANEAMIENTO'),
                ('sca2_datos_poliza_hogar', 'CLAVEPRODUCCION'),
                ('sca2_datos_poliza_hogar', 'TIPOPRODUCCION'),
                ('sca2_datos_poliza_hogar', 'ESTADO'),
                ('sca2_datos_poliza_hogar', 'BANCO'),
                ('sca2_datos_poliza_hogar', 'OBJASEGURADO'),
                ('sca2_datos_poliza_hogar', 'CODCOTIZACION'),
                ('sca2_datos_poliza_hogar', 'TIPOVIVIENDA'),
                ('sca2_datos_poliza_hogar', 'MCONSTRUIDOS'),
                ('sca2_datos_poliza_hogar', 'ANIOCONSTRUCCION'),
                ('sca2_datos_poliza_hogar', 'CALIDAD'),
                ('sca2_datos_poliza_hogar', 'TIPOCONSTRUCCION'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_CODINT'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_TIPO'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_TIPODECLIENTE'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_MARCAROBINSON'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_TOMADORESCONDUCTOR'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_FECHADENACIMIENTO'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_SEXO'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_CODIGOPOSTAL'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_ESTADOCIVIL'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_TIPODOCUMENTO'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_NUMDOCUMENTO'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_NOMBRE'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_APELLIDO1'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_APELLIDO2'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_EMAIL'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_TELEFONO1'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_TELEFONO2'),
                ('sca2_datos_poliza_hogar', 'TOMADOR_CODCALIFICACION'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CLAVEPRODUCCION'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREAGENTE'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODCLASEAGENTE'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_DGT'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODSUBCENTRAL'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODOFICINADIRECTA'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREDGT'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBRESUBCENTRAL'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREOFICINADIRECTA'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_DESCCLASEMEDIADOR'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_CODOFICINACOMERCIAL'),
                ('sca2_datos_poliza_hogar', 'ESTRUCTURACOMERCIAL_NOMBREOFICINACOMERCIAL'),
                ('sca2_datos_poliza_hogar', 'ESTADORECIBOS_MCAIMPAGO'),
                ('sca2_datos_poliza_hogar', 'ESTADORECIBOS_FECEFECTORECIBOIMP'),
                ('sca2_datos_poliza_vida', 'ID'),
                ('sca2_datos_poliza_vida', 'ID_SOLICITUD'),
                ('sca2_datos_poliza_vida', 'CLAVEPRODUCCION'),
                ('sca2_datos_poliza_vida', 'LINEADENEGOCIO'),
                ('sca2_datos_poliza_vida', 'IDPOLIZA'),
                ('sca2_datos_poliza_vida', 'NIFTOMADOR'),
                ('sca2_datos_poliza_vida', 'NOMBREAPELLIDOSTOMADOR'),
                ('sca2_datos_poliza_vida', 'FECHADEVENCIMIENTO'),
                ('sca2_datos_poliza_vida', 'TIPOCLIENTE'),
                ('sca2_datos_poliza_vida', 'IDENTIFICADORCLAVE'),
                ('sca2_datos_poliza_vida', 'ESTADOPOLIZA'),
                ('sca2_datos_poliza_vida', 'NUMAPLI'),
                ('sca2_datos_poliza_vida', 'POLICYID'),
                ('sca2_datos_poliza_vida', 'COMPANYID'),
                ('sca2_datos_poliza_vida', 'COMPANYDESC'),
                ('sca2_datos_poliza_vida', 'ACCOUNTINGFIELDCODE'),
                ('sca2_datos_poliza_vida', 'ACCOUNTINGFIELDDESC'),
                ('sca2_datos_poliza_vida', 'EFFECTIVEDATE'),
                ('sca2_datos_poliza_vida', 'DUEDATE'),
                ('sca2_datos_poliza_vida', 'CAPTUREDATE'),
                ('sca2_datos_poliza_vida', 'LANGUAGECODE'),
                ('sca2_datos_poliza_vida', 'LANGUAGEDESC'),
                ('sca2_datos_poliza_vida', 'CURRENCYISOCODE'),
                ('sca2_datos_poliza_vida', 'CURRENCYISODESC'),
                ('sca2_datos_poliza_vida', 'POLICYSTATUSCODE'),
                ('sca2_datos_poliza_vida', 'POLICYSTATUSDESC'),
                ('sca2_datos_poliza_vida', 'POLICYSTATUSREASONCODE'),
                ('sca2_datos_poliza_vida', 'POLICYSTATUSREASONDESC'),
                ('sca2_datos_poliza_vida', 'CONTRACTDURATIONYEARSNUM'),
                ('sca2_datos_poliza_vida', 'CONTRACTDURATIONMONTHSNUM'),
                ('sca2_datos_poliza_vida', 'CONTRACTDURATIONDAYSNUM'),
                ('sca2_datos_poliza_vida', 'DUEDATEAGE'),
                ('sca2_datos_poliza_vida', 'DESTINATIONTYPECODE'),
                ('sca2_datos_poliza_vida', 'DESTINATIONTYPEDESC'),
                ('sca2_datos_poliza_vida', 'FIRSTRECEIPTPAPERIND'),
                ('sca2_datos_poliza_vida', 'COMMERCIALPRODUCTCODE'),
                ('sca2_datos_poliza_vida', 'COMMERCIALPRODUCTNAME'),
                ('sca2_datos_poliza_vida', 'REINVESTMENTPOLICYID'),
                ('sca2_datos_poliza_vida', 'REINVESTMENTREASONCODE'),
                ('sca2_datos_poliza_vida', 'REINVESTMENTREASONDESC'),
                ('sca2_datos_poliza_vida', 'PURPOSECONTRACTCODE'),
                ('sca2_datos_poliza_vida', 'PURPOSECONTRACTDESC'),
                ('sca2_datos_poliza_vida', 'PREMIUMAMN'),
                ('sca2_datos_poliza_vida', 'CONTRIBUTIONFREQUENCYCODE'),
                ('sca2_datos_poliza_vida', 'CONTRIBUTIONFREQUENCYDESC'),
                ('sca2_datos_poliza_vida', 'PAYMONTHDAYNUM'),
                ('sca2_datos_poliza_vida', 'REVALUATIONTYPECODE'),
                ('sca2_datos_poliza_vida', 'REVALUATIONTYPEDESC'),
                ('sca2_datos_poliza_vida', 'REVALUATIONPERC'),
                ('sca2_datos_poliza_vida', 'RIGHTSASSIGNMENT'),
                ('sca2_datos_poliza_vida', 'TOMADORCLIENTID'),
                ('sca2_datos_poliza_vida', 'TOMADORPERSONTYPECODE'),
                ('sca2_datos_poliza_vida', 'TOMADORPERSONTYPEDESC'),
                ('sca2_datos_poliza_vida', 'TOMADORNAME'),
                ('sca2_datos_poliza_vida', 'TOMADORFIRSTSURNAME'),
                ('sca2_datos_poliza_vida', 'TOMADORSECONDSURNAME'),
                ('sca2_datos_poliza_vida', 'TOMADORBIRTHDATE'),
                ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODID'),
                ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODTYPECODE'),
                ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODTYPEDESC'),
                ('sca2_datos_poliza_vida', 'TOMADORCONTACTMETHODVALUE'),
                ('sca2_datos_poliza_vida', 'TOMADORIDENTITYDOCUMENTTYPECODE'),
                ('sca2_datos_poliza_vida', 'TOMADORIDENTITYDOCUMENTTYPEDESC'),
                ('sca2_datos_poliza_vida', 'TOMADORIDENTITYDOCUMENTNUMBER'),
                ('sca2_datos_poliza_vida', 'ASEGURADOCLIENTID'),
                ('sca2_datos_poliza_vida', 'ASEGURADOPERSONTYPECODE'),
                ('sca2_datos_poliza_vida', 'ASEGURADOPERSONTYPEDESC'),
                ('sca2_datos_poliza_vida', 'ASEGURADONAME'),
                ('sca2_datos_poliza_vida', 'ASEGURADOFIRSTSURNAME'),
                ('sca2_datos_poliza_vida', 'ASEGURADOSECONDSURNAME'),
                ('sca2_datos_poliza_vida', 'ASEGURADOBIRTHDATE'),
                ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODID'),
                ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODTYPECODE'),
                ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODTYPEDESC'),
                ('sca2_datos_poliza_vida', 'ASEGURADOCONTACTMETHODVALUE'),
                ('sca2_datos_poliza_vida', 'ASEGURADOIDENTITYDOCUMENTTYPECODE'),
                ('sca2_datos_poliza_vida', 'ASEGURADOIDENTITYDOCUMENTTYPEDESC'),
                ('sca2_datos_poliza_vida', 'ASEGURADOIDENTITYDOCUMENTNUMBER'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCLAVEPRODUCCION'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREAGENTE'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODCLASEAGENTE'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALDGT'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODSUBCENTRAL'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODOFICINADIRECTA'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREDGT'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBRESUBCENTRAL'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREOFICINADIRECTA'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALDESCCLASEMEDIADOR'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALCODOFICINACOMERCIAL'),
                ('sca2_datos_poliza_vida', 'ESTRUCTURACOMERCIALNOMBREOFICINACOMERCIAL'),
                ('sca2_datos_productor', 'ID'),
                ('sca2_datos_productor', 'ID_SOLICITUD'),
                ('sca2_datos_productor', 'ACCESOSGC'),
                ('sca2_datos_productor', 'DESCCANAL'),
                ('sca2_datos_productor', 'DESCCLASEPROD'),
                ('sca2_datos_productor', 'DESCSUBCANAL'),
                ('sca2_datos_productor', 'ESREDTEL'),
                ('sca2_datos_productor', 'ESSI24'),
                ('sca2_datos_productor', 'ESTELE'),
                ('sca2_datos_productor', 'IDCANAL'),
                ('sca2_datos_productor', 'IDCLASEPROD'),
                ('sca2_datos_productor', 'IDSUBCANAL'),
                ('sca2_datos_productor', 'TIPOACCESOSGC'),
                ('sca2_datos_productor', 'TIPOMEDIACION'),
                ('sca2_datos_productor', 'ANULAEXPERTOS'),
                ('sca2_datos_productor', 'ANULATECNICOS'),
                ('sca2_datos_solicitud', 'ID'),
                ('sca2_datos_solicitud', 'ID_SOLICITUD'),
                ('sca2_datos_solicitud', 'CANALDEEJECUCION'),
                ('sca2_datos_solicitud', 'PERFILREDMAPFRE'),
                ('sca2_datos_solicitud', 'FECSOLICITUDANUL'),
                ('sca2_datos_solicitud', 'FECEFECIMPAGADO'),
                ('sca2_datos_solicitud', 'CODCAUSA'),
                ('sca2_datos_solicitud', 'CODDETALLE'),
                ('sca2_datos_solicitud', 'FECANULACION'),
                ('sca2_datos_solicitud', 'FECIMPRESION'),
                ('sca2_datos_solicitud', 'CATALOGACION'),
                ('sca2_datos_solicitud', 'FECESTADO'),
                ('sca2_datos_solicitud', 'ORIGEN'),
                ('sca2_datos_solicitud', 'CONTACTO'),
                ('sca2_datos_solicitud', 'ESTADOSOLICITUD'),
                ('sca2_datos_solicitud', 'USUARIO'),
                ('sca2_datos_solicitud', 'MCAMECANIZADA'),
                ('sca2_datos_solicitud', 'CODMOTIVO'),
                ('sca2_datos_solicitud', 'DESCCAUSA'),
                ('sca2_datos_solicitud', 'CANALENTRADA'),
                ('sca2_datos_solicitud', 'SOCIOTECUIDAMOS'),
                ('sca2_datos_solicitud', 'PERFILTECUIDAMOS'),
                ('sca2_datos_solicitud', 'MCAANULAEXPERTO'),
                ('sca2_datos_solicitud', 'MCAANULATECNICO'),
                ('sca2_datos_solicitud', 'CODPCA'),
                ('sca2_datos_solicitud', 'DESCPCA'),
                ('sca2_datos_solicitud', 'CODMEDIOCOMUNICACION'),
                ('sca2_datos_solicitud', 'TLFEXPERTO'),
                ('sca2_datos_solicitud', 'RSVPRIMA'),
                ('sca2_datos_solicitud', 'IDCOMPANIA'),
                ('sca2_datos_solicitud', 'MCARSVPRIMA'),
                ('sca2_datos_solicitud', 'RESP_CONTACTO'),
                ('sca2_datos_solicitud', 'FECHA_RESP_CONTACTO'),
                ('sca2_error', 'ID'),
                ('sca2_error', 'ID_SOLICITUD'),
                ('sca2_error', 'COMANDO'),
                ('sca2_error', 'NODO'),
                ('sca2_error', 'CODIGO'),
                ('sca2_error', 'MENSAJE'),
                ('sca2_error', 'PAYLOAD'),
                ('sca2_error', 'INTENTOS'),
                ('sca2_error', 'PROXIMO_INTENTO'),
                ('sca2_error', 'ESTADO'),
                ('sca2_error', 'FECHA_CREACION'),
                ('sca2_error', 'RESUELTO_POR'),
                ('sca2_error', 'FECHA_RESOLUCION'),
                ('sca2_llamada_servicio', 'ID'),
                ('sca2_llamada_servicio', 'ID_SOLICITUD'),
                ('sca2_llamada_servicio', 'COMANDO'),
                ('sca2_llamada_servicio', 'NODO'),
                ('sca2_llamada_servicio', 'SERVICIO'),
                ('sca2_llamada_servicio', 'RESULTADO'),
                ('sca2_llamada_servicio', 'CODIGO_HTTP'),
                ('sca2_llamada_servicio', 'MENSAJE_ERROR'),
                ('sca2_llamada_servicio', 'PROCESS_ID'),
                ('sca2_llamada_servicio', 'FECHA_INICIO'),
                ('sca2_llamada_servicio', 'FECHA_FIN'),
                ('sca2_llamada_servicio', 'DURACION_MS'),
                ('sca2_niveles_cobertura_autos', 'ID'),
                ('sca2_niveles_cobertura_autos', 'ID_SOLICITUD'),
                ('sca2_niveles_cobertura_autos', 'GRUPODECOBERTURA'),
                ('sca2_niveles_cobertura_autos', 'NIVELDEPRIMA'),
                ('sca2_niveles_cobertura_autos', 'MCASINIESTRO'),
                ('sca2_otras_solicitudes_cabecera', 'ID'),
                ('sca2_otras_solicitudes_cabecera', 'ID_SOLICITUD'),
                ('sca2_otras_solicitudes_cabecera', 'FECSOLICITUD'),
                ('sca2_otras_solicitudes_cabecera', 'NUMPOLIZA'),
                ('sca2_otras_solicitudes_cabecera', 'IDLINEANEGOCIO'),
                ('sca2_otras_solicitudes_cabecera', 'FECANUL'),
                ('sca2_otras_solicitudes_cabecera', 'CAUSAANUL'),
                ('sca2_otras_solicitudes_cabecera', 'FECRESOLUCION'),
                ('sca2_otras_solicitudes_cabecera', 'CODESTSOLIC'),
                ('sca2_otras_solicitudes_cabecera', 'IDSOLICITUDOTRA'),
                ('sca2_solicitud', 'ID'),
                ('sca2_solicitud', 'ID_SOLICITUD'),
                ('sca2_solicitud', 'NUM_POLIZA'),
                ('sca2_solicitud', 'ESTADO_SOLICITUD'),
                ('sca2_solicitud', 'INTERFAZ_ACTIVA'),
                ('sca2_solicitud', 'PROCESO_ACTIVO'),
                ('sca2_solicitud', 'ESTADO_TAREA'),
                ('sca2_solicitud', 'NODO_RELANZAR'),
                ('sca2_solicitud', 'ERROR'),
                ('sca2_solicitud', 'PRIORIDAD_TAREA'),
                ('sca2_solicitud', 'CADUCIDAD_TAREA'),
                ('sca2_solicitud', 'NIVEL_INTERVENCION'),
                ('sca2_solicitud', 'FEC_INICIO_NIVEL'),
                ('sca2_solicitud', 'FECHA_DIETARIO'),
                ('sca2_solicitud', 'CONTADOR_POSPONER'),
                ('sca2_solicitud', 'MECANIZACION_REALIZADA'),
                ('sca2_solicitud', 'TAREA_CAPTURADA'),
                ('sca2_solicitud', 'ARGUMENTO_POSITIVO'),
                ('sca2_solicitud', 'IS_POLIZA_PRRA'),
                ('sca2_solicitud', 'DUE_ENVIADO'),
                ('sca2_solicitud', 'TRANSACTION_ID'),
                ('sca2_solicitud', 'GRUPO_ASIGNACION'),
                ('sca2_solicitud', 'CANAL'),
                ('sca2_solicitud', 'IDIOMA'),
                ('sca2_solicitud', 'ID_NEGOCIO'),
                ('sca2_solicitud', 'ROL'),
                ('sca2_solicitud', 'USUARIO'),
                ('sca2_solicitud', 'ORIGEN_POLIZA'),
                ('sca2_solicitud', 'LINEA_NEGOCIO'),
                ('sca2_solicitud', 'VERSION'),
                ('sca2_solicitud', 'BLOQUEADO_POR'),
                ('sca2_solicitud', 'BLOQUEADO_HASTA'),
                ('sca2_solicitud', 'CREATED_BY'),
                ('sca2_solicitud', 'CREATED_AT'),
                ('sca2_solicitud', 'MODIFIED_BY'),
                ('sca2_solicitud', 'MODIFIED_AT'),
                ('sca2_tarea', 'ID'),
                ('sca2_tarea', 'ID_SOLICITUD'),
                ('sca2_tarea', 'NUM_POLIZA'),
                ('sca2_tarea', 'NOMBRE_TAREA'),
                ('sca2_tarea', 'TIPO'),
                ('sca2_tarea', 'ESTADO'),
                ('sca2_tarea', 'PROCESO'),
                ('sca2_tarea', 'PROPIETARIO'),
                ('sca2_tarea', 'ASIGNADO_A'),
                ('sca2_tarea', 'GRUPO'),
                ('sca2_tarea', 'PRIORIDAD'),
                ('sca2_tarea', 'FECHA_CREACION'),
                ('sca2_tarea', 'FECHA_CADUCIDAD'),
                ('sca2_tarea', 'FECHA_CAPTURA'),
                ('sca2_tarea', 'FECHA_CIERRE'),
                ('sca2_tarea', 'DUE_ENVIADO'),
                ('sca2_tarea', 'TOKEN_TAREA'),
                ('sca2_transicion', 'ID'),
                ('sca2_transicion', 'ID_SOLICITUD'),
                ('sca2_transicion', 'COMANDO'),
                ('sca2_transicion', 'ESTADO_ORIGEN'),
                ('sca2_transicion', 'ESTADO_DESTINO'),
                ('sca2_transicion', 'CLAVE_IDEMPOTENCIA'),
                ('sca2_transicion', 'RESULTADO'),
                ('sca2_transicion', 'DETALLE'),
                ('sca2_transicion', 'PROCESS_ID'),
                ('sca2_transicion', 'USUARIO'),
                ('sca2_transicion', 'FECHA'),
                ('sca2_transicion', 'DURACION_MS'),
                ('sca2_trazabilidad_cliente', 'ID'),
                ('sca2_trazabilidad_cliente', 'FECHA'),
                ('sca2_trazabilidad_cliente', 'SISTEMA'),
                ('sca2_trazabilidad_cliente', 'PLATAFORMA'),
                ('sca2_trazabilidad_cliente', 'IP'),
                ('sca2_trazabilidad_cliente', 'PERFIL_USUARIO'),
                ('sca2_trazabilidad_cliente', 'OPERACION'),
                ('sca2_trazabilidad_cliente', 'RESULTADO_OPERACION'),
                ('sca2_trazabilidad_cliente', 'CLIENTE'),
                ('sca2_trazabilidad_cliente', 'POLIZA'),
                ('sca2_trazabilidad_cliente', 'TIPO_PERSONA')
              ) AS e(t, c))
  LOOP
    RAISE NOTICE 'Columna sin uso en SCA2 (se conserva): %.%', r.tabla, r.columna;
  END LOOP;
END $$;


-- =====================================================================================
-- 2. Índices de rendimiento (66-paso1 B1–B8; en TEST desde el 13/11/2026)
-- =====================================================================================
CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_created_at
    ON sca2_anulaciones.sca2_solicitud ("CREATED_AT" DESC);
CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_num_poliza_created_at
    ON sca2_anulaciones.sca2_solicitud ("NUM_POLIZA", "CREATED_AT" DESC);
CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_caducidad_tarea
    ON sca2_anulaciones.sca2_solicitud ("CADUCIDAD_TAREA") WHERE "CADUCIDAD_TAREA" IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_sca2_tarea_pendiente_tipo_fecha
    ON sca2_anulaciones.sca2_tarea ("TIPO", "FECHA_CREACION") WHERE "ESTADO" = 'PENDIENTE';
CREATE INDEX IF NOT EXISTS ix_sca2_tarea_fecha_creacion
    ON sca2_anulaciones.sca2_tarea ("FECHA_CREACION");
CREATE INDEX IF NOT EXISTS ix_sca2_transicion_fecha
    ON sca2_anulaciones.sca2_transicion ("FECHA");
CREATE INDEX IF NOT EXISTS ix_sca2_error_estado_fecha_creacion
    ON sca2_anulaciones.sca2_error ("ESTADO", "FECHA_CREACION" DESC);
CREATE INDEX IF NOT EXISTS ix_sca2_error_fecha_creacion
    ON sca2_anulaciones.sca2_error ("FECHA_CREACION");
CREATE INDEX IF NOT EXISTS ix_sca2_llamada_servicio_fecha_inicio
    ON sca2_anulaciones.sca2_llamada_servicio ("FECHA_INICIO");
CREATE INDEX IF NOT EXISTS ix_sca2_trazabilidad_cliente_fecha
    ON sca2_anulaciones.sca2_trazabilidad_cliente ("FECHA");

-- =====================================================================================
-- 3. NOT NULL de claves (66-paso2 C2/C3). Si hay nulos avisa y no lo aplica.
--    No se aplica a sca2_error.ID_SOLICITUD ni a ESTADO_SOLICITUD (nulos por diseño).
-- =====================================================================================
DO $$
DECLARE r record; hay_nulos boolean;
BEGIN
  FOR r IN SELECT * FROM (VALUES ('sca2_transicion','CLAVE_IDEMPOTENCIA'),
                                 ('sca2_solicitud','ID_SOLICITUD'), ('sca2_solicitud','NUM_POLIZA'),
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
      RAISE WARNING 'NOT NULL: %.% tiene nulos; no se aplica', r.tabla, r.columna;
    ELSE
      EXECUTE format('ALTER TABLE sca2_anulaciones.%I ALTER COLUMN %I SET NOT NULL', r.tabla, r.columna);
      RAISE NOTICE 'NOT NULL en %.%', r.tabla, r.columna;
    END IF;
  END LOOP;
END $$;

-- =====================================================================================
-- 4. UNIQUE de integridad (sin duplicados en SCA2). Si ya hay duplicados avisa y
--    no crea ese índice (el resto del script sigue).
--    C1  (70): una fila de caché de cabecera por solicitud.
--    C7  (71): una tarea PENDIENTE por solicitud y tipo.
--    R52 (72): un error PENDIENTE por solicitud, comando, nodo y código (NULL = '').
-- =====================================================================================
DO $$
DECLARE r record; v_dup integer;
BEGIN
  FOR r IN SELECT * FROM (VALUES
      ('ux_sca2_datos_cabecera_id_solicitud', 'sca2_datos_cabecera',
       '"ID_SOLICITUD"', ''),
      ('ux_sca2_tarea_pendiente_solicitud_tipo', 'sca2_tarea',
       '"ID_SOLICITUD", "TIPO"', ' WHERE "ESTADO" = ''PENDIENTE'''),
      ('ux_sca2_error_pendiente_clave', 'sca2_error',
       '"ID_SOLICITUD", "COMANDO", (coalesce("NODO", '''')), (coalesce("CODIGO", ''''))', ' WHERE "ESTADO" = ''PENDIENTE''')
    ) v(indice, tabla, columnas, filtro)
  LOOP
    IF to_regclass('sca2_anulaciones.' || r.indice) IS NOT NULL THEN
      RAISE NOTICE '% ya existe', r.indice;
      CONTINUE;
    END IF;
    EXECUTE format('SELECT count(*) FROM (SELECT 1 FROM sca2_anulaciones.%I%s GROUP BY %s HAVING count(*) > 1) d',
                   r.tabla, r.filtro, r.columnas) INTO v_dup;
    IF v_dup > 0 THEN
      RAISE WARNING '% grupos duplicados en %: NO se crea %. Eliminar los duplicados desde Appian y relanzar.',
                    v_dup, r.tabla, r.indice;
    ELSE
      EXECUTE format('CREATE UNIQUE INDEX %I ON sca2_anulaciones.%I (%s)%s', r.indice, r.tabla, r.columnas, r.filtro);
      RAISE NOTICE 'Creado %', r.indice;
    END IF;
  END LOOP;
END $$;

-- =====================================================================================
-- 4b. Índices de versiones anteriores del DDL 56 que TEST no tiene: se borran para que
--     quede igual que TEST (solo índices; no se toca ningún dato).
--     ux_sca2_cat_tipo_argumento (único total) impediría cargar COD_TP_ARG 999 activo e
--     inactivo: lo sustituye ux_sca2_cat_tipo_argumento_activo.
-- =====================================================================================
DROP INDEX IF EXISTS sca2_anulaciones.ux_sca2_cat_tipo_argumento;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_cat_tipo_argumento_cod_estado;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_datos_poliza_autos_estado;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_datos_poliza_autos_estadopoliza;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_datos_poliza_hogar_estado;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_datos_poliza_hogar_estadopoliza;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_datos_poliza_vida_estadopoliza;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_datos_solicitud_estadosolicitud;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_error_estado;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_solicitud_estado_solicitud;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_solicitud_estado_tarea;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_solicitud_num_poliza;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_tarea_estado;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_tarea_num_poliza;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_transicion_estado_destino;
DROP INDEX IF EXISTS sca2_anulaciones.ix_sca2_transicion_estado_origen;

-- =====================================================================================
-- Owner: user_sca2_anulaciones en el esquema, tablas, vistas y secuencias (56-owner-sca2.sql).
-- Los índices y las secuencias SERIAL siguen al owner de su tabla.
-- =====================================================================================
DO $$
DECLARE r record;
BEGIN
  -- Cambiar el owner del esquema pide CREATE sobre la base de datos: solo si hace falta.
  IF (SELECT pg_get_userbyid(nspowner) FROM pg_namespace WHERE nspname = 'sca2_anulaciones') <> 'user_sca2_anulaciones' THEN
    EXECUTE 'ALTER SCHEMA sca2_anulaciones OWNER TO user_sca2_anulaciones';
  END IF;
  FOR r IN SELECT c.relname, c.relkind FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'sca2_anulaciones' AND c.relkind IN ('r','v','m','p')
              AND pg_get_userbyid(c.relowner) <> 'user_sca2_anulaciones'
  LOOP
    EXECUTE format('ALTER %s sca2_anulaciones.%I OWNER TO user_sca2_anulaciones',
                   CASE r.relkind WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW' ELSE 'TABLE' END, r.relname);
  END LOOP;
  FOR r IN SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'sca2_anulaciones' AND c.relkind = 'S'
              AND pg_get_userbyid(c.relowner) <> 'user_sca2_anulaciones'
  LOOP
    EXECUTE format('ALTER SEQUENCE sca2_anulaciones.%I OWNER TO user_sca2_anulaciones', r.relname);
  END LOOP;
END $$;

ANALYZE sca2_anulaciones.sca2_solicitud;
ANALYZE sca2_anulaciones.sca2_tarea;
ANALYZE sca2_anulaciones.sca2_transicion;
ANALYZE sca2_anulaciones.sca2_error;
ANALYZE sca2_anulaciones.sca2_llamada_servicio;
ANALYZE sca2_anulaciones.sca2_trazabilidad_cliente;
ANALYZE sca2_anulaciones.sca2_datos_cabecera;

COMMIT;

-- =====================================================================================
-- 2. OBSERVACIONES de sca2_cat_tipo_argumento a VARCHAR(2000)
--    Origen: 76-ampliar-observaciones-tipo-argumento.sql
-- =====================================================================================
-- 76 · SCA2 · Ampliar OBSERVACIONES a VARCHAR(2000) en el catálogo de tipos de argumento.
-- Aurora PostgreSQL. Ejecutar primero en TEST y luego en la BD SCA2 de destino
-- con el propietario de la tabla o un rol habilitado para alterarla.
-- psql -v ON_ERROR_STOP=1 -f 76-ampliar-observaciones-tipo-argumento.sql
-- En DBeaver: ejecutar el script completo (Alt+X) en la conexión de SCA2.
-- No reduce una columna que ya admita 2000 caracteres o más.
-- No volver a VARCHAR(255) si ya hay textos más largos.

BEGIN;
SET LOCAL lock_timeout = '5s';

DO $$
DECLARE
  tipo text;
  longitud integer;
BEGIN
  SELECT data_type, character_maximum_length INTO tipo, longitud
    FROM information_schema.columns
   WHERE table_schema = 'sca2_anulaciones'
     AND table_name = 'sca2_cat_tipo_argumento'
     AND column_name = 'OBSERVACIONES';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No se encuentra sca2_anulaciones.sca2_cat_tipo_argumento."OBSERVACIONES"; revisar la conexión y los permisos';
  ELSIF tipo = 'text' OR (tipo = 'character varying' AND (longitud IS NULL OR longitud >= 2000)) THEN
    RAISE NOTICE 'OBSERVACIONES ya admite al menos 2000 caracteres; no se aplica ningún cambio';
  ELSIF tipo = 'character varying' AND longitud = 255 THEN
    ALTER TABLE sca2_anulaciones.sca2_cat_tipo_argumento
      ALTER COLUMN "OBSERVACIONES" TYPE VARCHAR(2000);
  ELSE
    RAISE EXCEPTION 'Tipo actual inesperado para OBSERVACIONES: %, longitud %', tipo, longitud;
  END IF;
END $$;

COMMIT;

-- =====================================================================================
-- 3. sca2_ejecucion_argumento
--    Origen: 77-ejecucion-argumento.sql
-- =====================================================================================
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

-- =====================================================================================
-- 4. sca2_adjunto_compraventa
--    Origen: sca2-adjunto-compraventa.sql (PR #75)
-- =====================================================================================
-- SCA2 · Aurora PostgreSQL 14 · referencias Appian del contrato de compraventa sin traspaso.
-- BD: comprobar la conexión a TEST y ejecutar el script completo, con parada al primer error.
-- No modifica tablas existentes ni carga datos.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog;

SELECT pg_advisory_xact_lock(619431, 83);

DO $script$
DECLARE
  marca constant text := 'SCA2-83: adjuntos de compraventa sin traspaso v1';
  tabla regclass;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class
     WHERE oid = to_regclass('sca2_anulaciones.sca2_solicitud') AND relkind = 'r'
  ) THEN
    RAISE EXCEPTION 'Falta la tabla viva sca2_anulaciones.sca2_solicitud';
  END IF;

  tabla := to_regclass('sca2_anulaciones.sca2_adjunto_compraventa');
  IF tabla IS NULL THEN
    CREATE TABLE sca2_anulaciones.sca2_adjunto_compraventa (
      "ID" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
      "ID_SOLICITUD" varchar(50) NOT NULL,
      "TIPO_GESTION" varchar(6) NOT NULL CHECK ("TIPO_GESTION" IN ('ACCADM', 'AUT')),
      "NUM_GESTION" varchar(50) NOT NULL,
      "ID_DOCUMENTO_APPIAN" integer NOT NULL CHECK ("ID_DOCUMENTO_APPIAN" > 0),
      "FECHA_ENTREGA" date NOT NULL,
      UNIQUE ("ID_SOLICITUD", "TIPO_GESTION", "NUM_GESTION")
    );
    EXECUTE format('COMMENT ON TABLE sca2_anulaciones.sca2_adjunto_compraventa IS %L', marca);
    REVOKE ALL ON TABLE sca2_anulaciones.sca2_adjunto_compraventa FROM PUBLIC;
    RAISE NOTICE 'SCA2-83: tabla sca2_adjunto_compraventa creada';
  ELSIF NOT EXISTS (
    SELECT 1 FROM pg_class
     WHERE oid = tabla AND relkind = 'r' AND relowner = current_user::regrole
       AND obj_description(oid, 'pg_class') = marca
  ) THEN
    RAISE EXCEPTION 'sca2_adjunto_compraventa ya existe y no pertenece a este script; no se modifica';
  ELSE
    RAISE NOTICE 'SCA2-83: tabla sca2_adjunto_compraventa ya existente; sin cambios';
  END IF;
END;
$script$;

COMMIT;

-- =====================================================================================
-- 5. sca2_cola_reserva_prima
--    Origen: estructura física de TEST (listDatabaseTableColumns)
-- =====================================================================================
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog;

DO $script$
DECLARE
  marca constant text := 'SCA2: cola del batch Reserva Prima v1';
  tabla regclass;
BEGIN
  tabla := to_regclass('sca2_anulaciones.sca2_cola_reserva_prima');
  IF tabla IS NULL THEN
    CREATE TABLE sca2_anulaciones.sca2_cola_reserva_prima (
      "ID" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
      "SOLICITUD_ANULACION" text,
      "COD_GESTION" varchar(128),
      "TIPO_GESTION" varchar(128),
      "TIPO_ACCION" varchar(128),
      "COD_ANULACION" varchar(128),
      "NIF" varchar(32),
      "NIVEL_INTERVENCION" varchar(32),
      "DATOS_CONTRAANULACION" text,
      "FECHA_EJECUCION" timestamp,
      "EJECUTADO" varchar(10)
    );
    EXECUTE format('COMMENT ON TABLE sca2_anulaciones.sca2_cola_reserva_prima IS %L', marca);
    REVOKE ALL ON TABLE sca2_anulaciones.sca2_cola_reserva_prima FROM PUBLIC;
    RAISE NOTICE 'SCA2: tabla sca2_cola_reserva_prima creada';
  ELSIF NOT EXISTS (
    SELECT 1 FROM pg_class WHERE oid = tabla AND relkind = 'r' AND relowner = current_user::regrole
  ) THEN
    RAISE EXCEPTION 'sca2_cola_reserva_prima ya existe con otro owner; revisar con el DBA';
  ELSIF (SELECT count(*) FROM information_schema.columns
          WHERE table_schema = 'sca2_anulaciones' AND table_name = 'sca2_cola_reserva_prima'
            AND column_name IN ('ID','SOLICITUD_ANULACION','COD_GESTION','TIPO_GESTION','TIPO_ACCION','COD_ANULACION',
                                'NIF','NIVEL_INTERVENCION','DATOS_CONTRAANULACION','FECHA_EJECUCION','EJECUTADO')) <> 11 THEN
    RAISE EXCEPTION 'sca2_cola_reserva_prima ya existe con otra estructura; no se modifica';
  ELSE
    RAISE NOTICE 'SCA2: sca2_cola_reserva_prima ya existente; sin cambios';
  END IF;
END
$script$;

COMMIT;

-- =====================================================================================
-- 6. Tablas *_hist del archivo histórico
--    Origen: sca2-hist-ddl.sql
-- =====================================================================================
-- SCA2 TEST · Aurora PostgreSQL 14 · fase 1 (estructura vacía).
-- Confirma la conexión a TEST y los permisos para SET ROLE user_sca2_anulaciones.
-- DBeaver: ejecutar el script completo (Alt+X), con parada al primer error.
-- No mueve datos, no altera tablas vivas y no registra ningún batch.
BEGIN;
SET LOCAL ROLE user_sca2_anulaciones;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = pg_catalog;

SELECT pg_advisory_xact_lock(619431, 71);

DO $archivo$
DECLARE
  tablas constant text[] := ARRAY[
    'sca2_solicitud', 'sca2_transicion', 'sca2_tarea', 'sca2_error',
    'sca2_llamada_servicio', 'sca2_datos_cabecera', 'sca2_datos_solicitud',
    'sca2_datos_basicos_solicitud', 'sca2_datos_perfiles_pca', 'sca2_datos_productor',
    'sca2_datos_poliza_autos', 'sca2_datos_poliza_hogar', 'sca2_datos_poliza_vida',
    'sca2_niveles_cobertura_autos', 'sca2_otras_solicitudes_cabecera'
  ];
  marca constant text := 'SCA2-HIST-71: estructura historica v1';
  viva text;
  hist text;
  tabla_viva regclass;
  tabla_hist regclass;
  clave_unica text;
  columnas_vivas jsonb;
  columnas_hist jsonb;
  nuevas integer := 0;
BEGIN
  FOREACH viva IN ARRAY tablas LOOP
    hist := viva || '_hist';
    tabla_viva := to_regclass(format('sca2_anulaciones.%I', viva));
    tabla_hist := to_regclass(format('sca2_anulaciones.%I', hist));
    clave_unica := CASE
      WHEN viva IN ('sca2_solicitud', 'sca2_datos_cabecera') THEN 'ID_SOLICITUD'
      WHEN viva = 'sca2_transicion' THEN 'CLAVE_IDEMPOTENCIA'
    END;

    IF NOT EXISTS (
      SELECT 1 FROM pg_class WHERE oid = tabla_viva AND relkind = 'r'
    ) OR NOT EXISTS (
      SELECT 1 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid
       WHERE c.conrelid = tabla_viva AND c.contype = 'p'
         AND a.attname = 'ID' AND a.atttypid = 'integer'::regtype
         AND c.conkey = ARRAY[a.attnum]
    ) THEN
      RAISE EXCEPTION 'Falta la tabla viva % o su clave primaria esperada (ID integer)', viva;
    END IF;

    IF tabla_hist IS NULL THEN
      EXECUTE format(
        'CREATE TABLE sca2_anulaciones.%I (LIKE sca2_anulaciones.%I,
          "FECHA_ARCHIVADO" timestamptz NOT NULL, PRIMARY KEY ("ID"))', hist, viva
      );
      EXECUTE format('COMMENT ON TABLE sca2_anulaciones.%I IS %L', hist, marca);
      EXECUTE format('REVOKE ALL ON TABLE sca2_anulaciones.%I FROM PUBLIC', hist);

      IF clave_unica IS NOT NULL THEN
        EXECUTE format('ALTER TABLE sca2_anulaciones.%I ADD UNIQUE (%I)', hist, clave_unica);
      END IF;
      IF viva NOT IN ('sca2_solicitud', 'sca2_datos_cabecera', 'sca2_transicion') THEN
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("ID_SOLICITUD")', hist);
      END IF;
      IF viva = 'sca2_solicitud' THEN
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("CREATED_AT" DESC, "ID" DESC)', hist);
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("NUM_POLIZA", "CREATED_AT" DESC, "ID" DESC)', hist);
      ELSIF viva = 'sca2_transicion' THEN
        EXECUTE format('CREATE INDEX ON sca2_anulaciones.%I ("ID_SOLICITUD", "FECHA" DESC, "ID" DESC)', hist);
      END IF;
      nuevas := nuevas + 1;
      tabla_hist := to_regclass(format('sca2_anulaciones.%I', hist));
    ELSIF NOT EXISTS (
      SELECT 1 FROM pg_class
       WHERE oid = tabla_hist AND relkind = 'r' AND relowner = current_user::regrole
         AND obj_description(oid, 'pg_class') = marca
    ) THEN
      RAISE EXCEPTION 'La tabla histórica % ya existe y no pertenece a este script; no se modifica', hist;
    END IF;

    SELECT jsonb_agg(jsonb_build_array(attname, atttypid, atttypmod, attnotnull, attcollation) ORDER BY attname)
      INTO columnas_vivas FROM pg_attribute
     WHERE attrelid = tabla_viva AND attnum > 0 AND NOT attisdropped;
    SELECT jsonb_agg(jsonb_build_array(attname, atttypid, atttypmod, attnotnull, attcollation) ORDER BY attname)
      INTO columnas_hist FROM pg_attribute
     WHERE attrelid = tabla_hist AND attnum > 0 AND NOT attisdropped AND attname <> 'FECHA_ARCHIVADO';

    IF columnas_hist IS DISTINCT FROM columnas_vivas OR NOT EXISTS (
      SELECT 1 FROM pg_attribute WHERE attrelid = tabla_hist AND NOT attisdropped
        AND attname = 'FECHA_ARCHIVADO' AND atttypid = 'timestamptz'::regtype AND attnotnull
    ) OR EXISTS (
      SELECT 1 FROM pg_attribute WHERE attrelid = tabla_hist AND attnum > 0
        AND NOT attisdropped AND (atthasdef OR attidentity <> '' OR attgenerated <> '')
    ) OR NOT EXISTS (
      SELECT 1 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid
       WHERE c.conrelid = tabla_hist AND c.contype = 'p'
         AND a.attname = 'ID' AND c.conkey = ARRAY[a.attnum]
    ) OR (clave_unica IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid
       WHERE c.conrelid = tabla_hist AND c.contype = 'u'
         AND a.attname = clave_unica AND c.conkey = ARRAY[a.attnum]
    )) THEN
      RAISE EXCEPTION 'La estructura de % no coincide con la tabla viva o el contrato de archivo; revisar con el DBA', hist;
    END IF;
  END LOOP;

  RAISE NOTICE 'SCA2 histórico: % tablas verificadas; % creadas', array_length(tablas, 1), nuevas;
END;
$archivo$;

COMMIT;

-- =====================================================================================
-- 7. Reintento de finalización (queda desactivado)
--    Origen: sca2-reintento-finalizacion.sql
-- =====================================================================================
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

-- =====================================================================================
-- 8. Procedure de traspaso al histórico v3 (no mueve datos)
--    Origen: sca2-hist-traspaso.sql
-- =====================================================================================
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
  version_rutina constant integer := 3;
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
    p_resumen := (jsonb_build_object('versionRutina', version_rutina) ||
      '{"solicitados":0,"archivados":0,"repetidos":0,"excluidos":0,"conflictos":0,"filas":0,"idsArchivados":[],"clavesSync":{}}'::jsonb)::text;
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
          AND (r.estado IS NULL OR r.estado NOT IN ('RECUPERADO', 'OMITIDO'))
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
    'versionRutina', version_rutina,
    'solicitados', cardinality(ids), 'archivados', archivados, 'repetidos', repetidos,
    'excluidos', excluidos, 'conflictos', conflictos, 'filas', filas_total,
    'idsArchivados', ids_archivados, 'clavesSync', claves_sync
  )::text;
END
$archivo$;

REVOKE ALL ON PROCEDURE sca2_anulaciones.sca2_pm_traspasar_historico(text, text) FROM PUBLIC;

COMMIT;

-- =====================================================================================
-- 9. Catálogos sca2_cat_* (ID de TEST)
--    Origen: Appian TEST, listRecordData del 26/11/2026
-- =====================================================================================
BEGIN;
SET LOCAL lock_timeout = '5s';

-- sca2_cat_motivo: 14 filas (ID conservado de TEST)
INSERT INTO sca2_anulaciones.sca2_cat_motivo ("ID", "COD_LINEA_NEGOCIO", "COD_PERFIL", "COD_SUB_PERFIL", "COD_MOTIVO", "DESCRIPCION", "ORDEN", "ACTIVO", "ORIGEN", "FECHA_ALTA", "FECHA_MODIFICACION", "USUARIO_MODIFICACION") VALUES
  (1, 1, 'CE_RM', 'CE_RM_OFICINA', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (2, 1, 'CE_RM', 'CE_RM_OFICINA', '4', 'DECISION DE LA ENTIDAD', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (3, 1, 'CE_RM', 'CE_RM_OFICINA', '2', 'DESAPARICION DEL RIESGO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (4, 2, 'CE_RM', 'CE_RM_OFICINA', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (5, 2, 'CE_RM', 'CE_RM_OFICINA', '4', 'DECISION DE LA ENTIDAD', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (6, 3, 'CE_RM', 'CE_RM_OFICINA', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (7, 1, 'CE_MF_SI24', 'CE_MF_SI24_EXPERTO', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (8, 1, 'CE_MF_SI24', 'CE_MF_SI24_EXPERTO', '2', 'DESAPARICION DEL RIESGO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (9, 2, 'CE_MF_SI24', 'CE_MF_SI24_EXPERTO', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (10, 3, 'CE_MF_SI24', 'CE_MF_SI24_EXPERTO', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (11, 1, 'CE_MF_BK', 'CE_MF_BK_EXPERTOSI24', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (12, 1, 'CE_MF_BK', 'CE_MF_BK_EXPERTOSI24', '2', 'DESAPARICION DEL RIESGO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (13, 2, 'CE_MF_BK', 'CE_MF_BK_EXPERTOSI24', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net'),
  (14, 3, 'CE_MF_BK', 'CE_MF_BK_EXPERTOSI24', '1', 'DECISION DE CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:38', TIMESTAMP '2026-11-18 07:47:56', 'MASCARP@mapfre.net')
ON CONFLICT ("ID") DO NOTHING;
DO $$ BEGIN PERFORM setval(pg_get_serial_sequence('sca2_anulaciones.sca2_cat_motivo', 'ID'), GREATEST((SELECT max("ID") FROM sca2_anulaciones.sca2_cat_motivo), 1)); END $$;

-- sca2_cat_detalle: 22 filas (ID conservado de TEST)
INSERT INTO sca2_anulaciones.sca2_cat_detalle ("ID", "COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE", "DESCRIPCION", "ORDEN", "ACTIVO", "ORIGEN", "FECHA_ALTA", "FECHA_MODIFICACION", "USUARIO_MODIFICACION") VALUES
  (1, 1, '1', '9', 'ASEGURADO NO DESEA SEGURO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (2, 1, '1', '6', 'IMPAGO DEL SEGURO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (3, 1, '1', '4', 'MALA GESTION', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (4, 1, '1', '1', 'PRECIO', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (5, 1, '1', '2', 'PRODUCTO', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (6, 1, '1', '3', 'SINIESTRO', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (7, 1, '1', '5', 'VENTA DEL VEHICULO', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (8, 1, '4', '9', 'DECISION DE LA ENTIDAD', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (9, 1, '2', '7', 'BAJA DE VEHICULO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (10, 2, '1', '9', 'ASEGURADO NO DESEA SEGURO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (11, 2, '1', '6', 'IMPAGO DEL SEGURO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (12, 2, '1', '4', 'MALA GESTION', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (13, 2, '1', '1', 'PRECIO', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (14, 2, '1', '2', 'PRODUCTO', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (15, 2, '1', '3', 'SINIESTRO', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (16, 2, '1', '10', 'VENTA/DESAPARICION DEL RIESGO', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (17, 2, '4', '9', 'DECISION DE LA ENTIDAD', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (18, 3, '1', '9', 'ASEGURADO NO DESEA SEGURO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (19, 3, '1', '4', 'MALA GESTION', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (20, 3, '1', '1', 'PRECIO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (21, 3, '1', '2', 'PRODUCTO', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin'),
  (22, 3, '1', '10', 'VENTA/DESAPARICION DEL RIESGO', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:40', TIMESTAMP '2026-10-21 10:30:40', 'devin')
ON CONFLICT ("ID") DO NOTHING;
DO $$ BEGIN PERFORM setval(pg_get_serial_sequence('sca2_anulaciones.sca2_cat_detalle', 'ID'), GREATEST((SELECT max("ID") FROM sca2_anulaciones.sca2_cat_detalle), 1)); END $$;

-- sca2_cat_causa: 146 filas (ID conservado de TEST)
INSERT INTO sca2_anulaciones.sca2_cat_causa ("ID", "COD_LINEA_NEGOCIO", "COD_MOTIVO", "COD_DETALLE", "COD_PERFIL", "COD_CAUSA", "DESCRIPCION", "ORDEN", "ACTIVO", "ORIGEN", "FECHA_ALTA", "FECHA_MODIFICACION", "USUARIO_MODIFICACION") VALUES
  (1, 1, '1', '9', 'CE_RM', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (2, 1, '1', '9', 'CE_RM', '29', 'ILOCALIZADO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (3, 1, '1', '9', 'CE_MF_SI24', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (4, 1, '1', '9', 'CE_MF_SI24', '29', 'ILOCALIZADO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (5, 1, '1', '9', 'CE_MF_BK', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (6, 1, '1', '9', 'CE_MF_BK', '29', 'ILOCALIZADO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (7, 1, '1', '6', 'CE_RM', '15', 'ASEGURADO NO LOCALIZADO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (8, 1, '1', '6', 'CE_MF_SI24', '15', 'ASEGURADO NO LOCALIZADO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (9, 1, '1', '6', 'CE_MF_BK', '15', 'ASEGURADO NO LOCALIZADO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (10, 1, '1', '4', 'CE_RM', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (11, 1, '1', '4', 'CE_RM', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (12, 1, '1', '4', 'CE_RM', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (13, 1, '1', '4', 'CE_MF_SI24', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (14, 1, '1', '4', 'CE_MF_SI24', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (15, 1, '1', '4', 'CE_MF_SI24', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (16, 1, '1', '4', 'CE_MF_BK', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (17, 1, '1', '4', 'CE_MF_BK', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (18, 1, '1', '4', 'CE_MF_BK', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (19, 1, '1', '1', 'CE_RM', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (20, 1, '1', '1', 'CE_RM', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (21, 1, '1', '1', 'CE_RM', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (22, 1, '1', '1', 'CE_MF_SI24', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (23, 1, '1', '1', 'CE_MF_SI24', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (24, 1, '1', '1', 'CE_MF_SI24', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (25, 1, '1', '1', 'CE_MF_BK', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (26, 1, '1', '1', 'CE_MF_BK', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (27, 1, '1', '1', 'CE_MF_BK', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (28, 1, '1', '2', 'CE_RM', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (29, 1, '1', '2', 'CE_RM', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (30, 1, '1', '2', 'CE_RM', '5', 'QUIERO UNA FRANQUICIA MAS BAJA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (31, 1, '1', '2', 'CE_MF_SI24', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (32, 1, '1', '2', 'CE_MF_SI24', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (33, 1, '1', '2', 'CE_MF_SI24', '5', 'QUIERO UNA FRANQUICIA MAS BAJA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (34, 1, '1', '2', 'CE_MF_BK', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (35, 1, '1', '2', 'CE_MF_BK', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (36, 1, '1', '2', 'CE_MF_BK', '5', 'QUIERO UNA FRANQUICIA MAS BAJA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (37, 1, '1', '3', 'CE_RM', '9', 'INSATISFECHO CON LA REPARACION', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (38, 1, '1', '3', 'CE_RM', '7', 'NO ME CUBRIERON UN SINIESTRO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (39, 1, '1', '3', 'CE_RM', '8', 'TARDARON MUCHO EN RESOLVERLO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (40, 1, '1', '3', 'CE_MF_SI24', '9', 'INSATISFECHO CON LA REPARACION', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (41, 1, '1', '3', 'CE_MF_SI24', '7', 'NO ME CUBRIERON UN SINIESTRO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (42, 1, '1', '3', 'CE_MF_SI24', '8', 'TARDARON MUCHO EN RESOLVERLO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (43, 1, '1', '3', 'CE_MF_BK', '9', 'INSATISFECHO CON LA REPARACION', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (44, 1, '1', '3', 'CE_MF_BK', '7', 'NO ME CUBRIERON UN SINIESTRO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (45, 1, '1', '3', 'CE_MF_BK', '8', 'TARDARON MUCHO EN RESOLVERLO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (46, 1, '1', '5', 'CE_RM', '14', 'NO VOY A COMPRARME OTRO COCHE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (47, 1, '1', '5', 'CE_RM', '13', 'SEGURO REGALADO POR LA COMPRA DE COCHE', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (48, 1, '1', '5', 'CE_MF_BK', '14', 'NO VOY A COMPRARME OTRO COCHE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (49, 1, '1', '5', 'CE_MF_BK', '13', 'SEGURO REGALADO POR LA COMPRA DE COCHE', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (50, 1, '4', '9', 'CE_RM', '28', 'ANULACIÓN FUERA DE NORMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (51, 1, '4', '9', 'CE_RM', '26', 'REEMPLAZO POR ERROR EN FECHA DE EMISION', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (52, 1, '4', '9', 'CE_RM', '27', 'REEMPLAZO POR UNIFICACIÓN DE VENCIMIENTOS', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (53, 1, '2', '7', 'CE_RM', '17', 'BAJA TEMPORAL', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (54, 1, '2', '7', 'CE_RM', '16', 'BAJA VEHICULO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (55, 1, '2', '7', 'CE_RM', '18', 'SINIESTRO TOTAL', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (56, 1, '2', '7', 'CE_MF_BK', '17', 'BAJA TEMPORAL', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (57, 1, '2', '7', 'CE_MF_BK', '16', 'BAJA VEHICULO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (58, 1, '2', '7', 'CE_MF_BK', '18', 'SINIESTRO TOTAL', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (59, 2, '1', '9', 'CE_RM', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (60, 2, '1', '9', 'CE_RM', '29', 'ILOCALIZADO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (61, 2, '1', '9', 'CE_MF_SI24', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (62, 2, '1', '9', 'CE_MF_SI24', '29', 'ILOCALIZADO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (63, 2, '1', '9', 'CE_MF_BK', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (64, 2, '1', '9', 'CE_MF_BK', '29', 'ILOCALIZADO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (65, 2, '1', '6', 'CE_RM', '15', 'ASEGURADO NO LOCALIZADO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (66, 2, '1', '6', 'CE_MF_SI24', '15', 'ASEGURADO NO LOCALIZADO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (67, 2, '1', '6', 'CE_MF_BK', '15', 'ASEGURADO NO LOCALIZADO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (68, 2, '1', '4', 'CE_RM', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (69, 2, '1', '4', 'CE_RM', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (70, 2, '1', '4', 'CE_RM', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (71, 2, '1', '4', 'CE_MF_SI24', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (72, 2, '1', '4', 'CE_MF_SI24', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (73, 2, '1', '4', 'CE_MF_SI24', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (74, 2, '1', '4', 'CE_MF_BK', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (75, 2, '1', '4', 'CE_MF_BK', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (76, 2, '1', '4', 'CE_MF_BK', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (77, 2, '1', '1', 'CE_RM', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (78, 2, '1', '1', 'CE_RM', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (79, 2, '1', '1', 'CE_RM', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (80, 2, '1', '1', 'CE_MF_SI24', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (81, 2, '1', '1', 'CE_MF_SI24', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (82, 2, '1', '1', 'CE_MF_SI24', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (83, 2, '1', '1', 'CE_MF_BK', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (84, 2, '1', '1', 'CE_MF_BK', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (85, 2, '1', '1', 'CE_MF_BK', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (86, 2, '1', '2', 'CE_RM', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (87, 2, '1', '2', 'CE_RM', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (88, 2, '1', '2', 'CE_RM', '5', 'QUIERO UNA FRANQUICIA MAS BAJA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (89, 2, '1', '2', 'CE_MF_SI24', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (90, 2, '1', '2', 'CE_MF_SI24', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (91, 2, '1', '2', 'CE_MF_SI24', '5', 'QUIERO UNA FRANQUICIA MAS BAJA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (92, 2, '1', '2', 'CE_MF_BK', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (93, 2, '1', '2', 'CE_MF_BK', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (94, 2, '1', '2', 'CE_MF_BK', '5', 'QUIERO UNA FRANQUICIA MAS BAJA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (95, 2, '1', '3', 'CE_RM', '9', 'INSATISFECHO CON LA REPARACION', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (96, 2, '1', '3', 'CE_RM', '7', 'NO ME CUBRIERON UN SINIESTRO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (97, 2, '1', '3', 'CE_RM', '8', 'TARDARON MUCHO EN RESOLVERLO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (98, 2, '1', '3', 'CE_MF_SI24', '9', 'INSATISFECHO CON LA REPARACION', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (99, 2, '1', '3', 'CE_MF_SI24', '7', 'NO ME CUBRIERON UN SINIESTRO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (100, 2, '1', '3', 'CE_MF_SI24', '8', 'TARDARON MUCHO EN RESOLVERLO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (101, 2, '1', '3', 'CE_MF_BK', '9', 'INSATISFECHO CON LA REPARACION', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (102, 2, '1', '3', 'CE_MF_BK', '7', 'NO ME CUBRIERON UN SINIESTRO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (103, 2, '1', '3', 'CE_MF_BK', '8', 'TARDARON MUCHO EN RESOLVERLO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (104, 2, '1', '10', 'CE_RM', '31', 'VENTA CON REEMPLAZO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (105, 2, '1', '10', 'CE_RM', '32', 'VENTA SIN REEMPLAZO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (106, 2, '1', '10', 'CE_MF_BK', '31', 'VENTA CON REEMPLAZO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (107, 2, '1', '10', 'CE_MF_BK', '32', 'VENTA SIN REEMPLAZO', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (108, 2, '4', '9', 'CE_RM', '28', 'ANULACIÓN FUERA DE NORMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (109, 2, '4', '9', 'CE_RM', '26', 'REEMPLAZO POR ERROR EN FECHA DE EMISION', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (110, 2, '4', '9', 'CE_RM', '27', 'REEMPLAZO POR UNIFICACIÓN DE VENCIMIENTOS', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (111, 3, '1', '9', 'CE_RM', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (112, 3, '1', '9', 'CE_MF_SI24', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (113, 3, '1', '9', 'CE_MF_BK', '30', 'COMPROMISOS', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (114, 3, '1', '4', 'CE_RM', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (115, 3, '1', '4', 'CE_RM', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (116, 3, '1', '4', 'CE_RM', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (117, 3, '1', '4', 'CE_MF_SI24', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (118, 3, '1', '4', 'CE_MF_SI24', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (119, 3, '1', '4', 'CE_MF_SI24', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (120, 3, '1', '4', 'CE_MF_BK', '12', 'ERRORES ADMINISTRATIVOS DE LA COMPAÑIA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (121, 3, '1', '4', 'CE_MF_BK', '10', 'ME TRATARON MAL', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (122, 3, '1', '4', 'CE_MF_BK', '11', 'NUNCA ME RESUELVEN LO QUE NECESITO', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (123, 3, '1', '1', 'CE_RM', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (124, 3, '1', '1', 'CE_RM', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (125, 3, '1', '1', 'CE_RM', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (126, 3, '1', '1', 'CE_MF_SI24', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (127, 3, '1', '1', 'CE_MF_SI24', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (128, 3, '1', '1', 'CE_MF_SI24', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (129, 3, '1', '1', 'CE_MF_BK', '1', 'ME HA SUBIDO MUCHO LA PRIMA', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (130, 3, '1', '1', 'CE_MF_BK', '3', 'MEJOR PRECIO DE LA COMPETENCIA', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (131, 3, '1', '1', 'CE_MF_BK', '2', 'NO PUEDO PAGAR ESA CANTIDAD', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (132, 3, '1', '2', 'CE_RM', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (133, 3, '1', '2', 'CE_RM', '34', 'ME GUSTARIA BAJAR CAPITALES', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (134, 3, '1', '2', 'CE_RM', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (135, 3, '1', '2', 'CE_RM', '33', 'NO QUIERO TANTAS GARANTIAS', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (136, 3, '1', '2', 'CE_MF_SI24', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (137, 3, '1', '2', 'CE_MF_SI24', '34', 'ME GUSTARIA BAJAR CAPITALES', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (138, 3, '1', '2', 'CE_MF_SI24', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (139, 3, '1', '2', 'CE_MF_SI24', '33', 'NO QUIERO TANTAS GARANTIAS', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (140, 3, '1', '2', 'CE_MF_BK', '6', 'EL PRODUCTO NO SATISFACE AL CLIENTE', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (141, 3, '1', '2', 'CE_MF_BK', '34', 'ME GUSTARIA BAJAR CAPITALES', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (142, 3, '1', '2', 'CE_MF_BK', '4', 'MEJORES COBERTURAS EN OTRA COMPAÑIA', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (143, 3, '1', '2', 'CE_MF_BK', '33', 'NO QUIERO TANTAS GARANTIAS', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (144, 3, '1', '10', 'CE_RM', '35', 'PRESTAMO DESAPARECIDO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (145, 3, '1', '10', 'CE_MF_SI24', '35', 'PRESTAMO DESAPARECIDO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin'),
  (146, 3, '1', '10', 'CE_MF_BK', '35', 'PRESTAMO DESAPARECIDO', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:43', TIMESTAMP '2026-10-21 10:30:43', 'devin')
ON CONFLICT ("ID") DO NOTHING;
DO $$ BEGIN PERFORM setval(pg_get_serial_sequence('sca2_anulaciones.sca2_cat_causa', 'ID'), GREATEST((SELECT max("ID") FROM sca2_anulaciones.sca2_cat_causa), 1)); END $$;

-- sca2_cat_tipo_argumento: 342 filas (ID conservado de TEST); sin las filas de prueba de TEST con ID 342, 343, 344, 345, 346
INSERT INTO sca2_anulaciones.sca2_cat_tipo_argumento ("ID", "COD_TP_ARG", "DESC_ARG", "COD_ESTADO", "ID_LINEA_NEGOCIO", "ID_RAMO", "COD_COMPANIA", "COD_COMPANIA_ARG", "APLI_ARGUMENTO", "INSTRUCCION", "MCA_FINALIZADO", "NOMBRE_DOC", "NUM_DOC", "OBSERVACIONES", "FEC_VIGENCIA", "FEC_MODIFICADO", "COD_ID_CAMPANA", "COD_TIP_BON", "NUM_TIP_BON", "REGATEABLE", "MCA_TE_CUIDAMOS", "NUM_DIAS_SGO", "COD_TAREA_SGO", "TXT_URL_ARG", "MCA_TREB_CALC", "ORDEN", "ACTIVO", "ORIGEN", "FECHA_ALTA", "FECHA_MODIFICACION", "USUARIO_MODIFICACION") VALUES
  (1, '1', 'SERVICIOS MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SERVICIOS MAPFRE.pdf', '090003e8802a0ff8', 'Prueba 7', '01/04/2015 00:00:00', '25/10/2026 11:07:21', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (2, '2', 'GESTION COMPETENCIA', 'N', '1', 200, NULL, NULL, 'GESTION_COMPETENCIA', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '24/04/2013', '26/04/2013 14:00:45', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (3, '3', 'Club Mapfre', 'N', '1', 200, NULL, 1, 'TE_CUIDAMOS', 'instrucciones', 'S', 'documento_pca1653383274901.pdf', '090003e8801c58f3', 'OBSERVACIONES', '24/05/2022 00:00:00', '27/10/2026 16:35:37', 'TTQAUTOS', NULL, NULL, 'S', 'S', 0, NULL, 'https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS018Gesvida/VJ0180007_DetallePolizaCliente.do', 'S', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (4, '4', 'INSATISFACCION CON EL SERVICIO', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'INSATISFACCION CON EL SERVICIO.pdf', '090003e8801c58f8', NULL, '01/04/2015 00:00:00', '03/11/2025 14:03:11', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (5, '5', 'CONSULTA DE SINIESTROS', 'N', '1', 200, NULL, NULL, 'CONSUWEB', NULL, 'N', NULL, NULL, NULL, '24/04/2013', '26/04/2013 14:00:45', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (6, '6', 'PRODUCTO ALTERNATIVO', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'S', 'PRODUCTO ALTERNATIVO.pdf', '090003e8802a1840', NULL, '01/04/2015 00:00:00', '26/10/2026 16:22:20', NULL, NULL, NULL, 'S', 'S', 0, NULL, NULL, 'S', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (7, '7', 'BONUS MALUS GENERAL', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles positivos.pdf', '090003e8801c61d5', NULL, '01/04/2015 00:00:00', '05/11/2025 14:57:47', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (8, '8', 'SUPLEMENTO EN GENERAL', 'N', '1', 200, NULL, NULL, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '24/04/2013', '26/04/2013 14:00:45', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 8, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (9, '9', 'REDUCCION DE COBERTURAS', 'N', '1', 200, NULL, 41, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '24/04/2013', '07/04/2026 08:55:30', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 9, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (10, '10', 'CAMBIO DE FORMA DE PAGO', 'N', '1', 200, NULL, NULL, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '24/04/2013', '26/04/2013 14:00:45', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 10, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (11, '11', 'SAT', 'S', '1', 200, NULL, 1, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '01/01/2024 00:00:00', '02/01/2024 09:48:30', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 11, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (12, '12', 'APLICAR INTEGRALIDAD', 'S', '1', 200, NULL, NULL, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '12/01/2022 00:00:00', '12/01/2022 15:51:24', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 12, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (13, '13', 'CHEQUE SEGURO', 'S', '1', 200, NULL, 1, 'CHEQUE_SEGURO', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/05/2025 00:00:00', '06/05/2025 14:59:24', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 13, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (14, '14', 'Club Mapfre NO Socios Tipo A', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Te Cuidamos A HOR.pdf', '090003e8801c59c9', 'OBSERVACIONES', '12/01/2022 00:00:00', '03/11/2025 17:56:30', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 14, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (15, '15', 'Club Mapfre NO Socios Tipo B', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Te Cuidamos B HOR.pdf', '090003e8801c5b2a', 'OBSERVACIONES', '12/01/2022 00:00:00', '04/11/2025 14:00:23', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 15, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (16, '16', 'Club Mapfre NO Socios Tipo C', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Te Cuidamos C HOR.pdf', '090003e8801c5b44', 'OBSERVACIONES', '12/01/2022 00:00:00', '04/11/2025 14:39:25', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 16, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (17, '17', 'Club Mapfre Socios Modalidad A', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Te Cuidamos A HOR.pdf', '090003e8801c5baf', 'OBSERVACIONES', '13/01/2022 00:00:00', '04/11/2025 17:56:13', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 17, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (18, '18', 'Club Mapfre Socios Modalidad B', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Te Cuidamos B HOR.pdf', '090003e8801c6209', 'OBSERVACIONES', '12/01/2022 00:00:00', '05/11/2025 17:13:25', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 18, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (19, '19', 'Club Mapfre Socios Modalidad C', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Te Cuidamos C HOR.pdf', '090003e8801c621d', 'OBSERVACIONES', '12/01/2022 00:00:00', '05/11/2025 17:26:39', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 19, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (20, '20', 'BM - Un parte de daños propios', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles negativos -4 a -6.pdf', '62dfe1542dca20fa', NULL, '01/04/2015 00:00:00', '23/05/2023 12:34:46', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 20, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (21, '21', 'BM - Un parte de lunas', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles negativos -4 a -6.pdf', '090003e8801c623c', NULL, '01/04/2015 00:00:00', '05/11/2025 17:51:11', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 21, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (22, '22', 'BM - 2 partes de daños propios', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles negativos -7 a -9.pdf', '62e2e1542dcb3e19', NULL, '01/04/2015 00:00:00', '23/05/2023 12:35:12', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 22, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (23, '23', 'BM - 2 partes de lunas', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles negativos -7 a -9.pdf', '62e3c1542dcb96a2', NULL, '01/04/2015 00:00:00', '23/05/2023 12:35:26', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 23, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (24, '24', 'BM - 3 partes de daños propios', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles negativos -10.pdf', '62e4c1542dcbf503', NULL, '01/04/2015 00:00:00', '23/05/2023 12:35:35', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 24, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (25, '25', 'BM - 3 partes de lunas', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Niveles negativos -10.pdf', '62e601542dcc4a91', NULL, '01/04/2015 00:00:00', '23/05/2023 12:35:47', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 25, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (26, '26', 'ME HA SUBIDO MUCHO LA PRIMA', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'ME HA SUBIDO LA PRIMA.pdf', '090003e886fcf89d', 'OBSERVACIONES', '01/04/2015 00:00:00', '20/11/2023 08:56:12', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 26, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (27, '27', 'MEJOR PRECIO DE LA COMPETENCIA', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'MEJOR PRECIO DE LA COMPETENCIA.pdf', '090003e886fcf8a1', 'OBSERVACIONES', '01/04/2015 00:00:00', '20/11/2023 08:57:41', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 27, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (28, '28', 'NO PUEDO PAGAR ESA CANTIDAD', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'ME PARECE CARO.pdf', '090003e886fcf8a0', 'OBSERVACIONES', '01/04/2015 00:00:00', '20/11/2023 08:57:06', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 28, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (29, '34', 'CLUB MAPFRE', 'S', '1', 200, NULL, 41, 'TE_CUIDAMOS', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '01/09/2015 00:00:00', '24/11/2025 00:45:54', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 29, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (30, '35', 'CLUB MAPFRE PLATA ', 'N', '1', 200, NULL, 41, 'TE_CUIDAMOS', 'OBSERVACIONES', 'N', 'Club MAPFRE Plata.pdf', '090003e8801e576a', 'OBSERVACIONES', '01/09/2015 00:00:00', '13/01/2026 14:01:27', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 30, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (31, '36', 'CAMBIO DE PÓLIZA A "BASICar"', 'N', '1', 200, NULL, 41, 'WAUTEMIS', 'OBSERVACIONES', 'N', 'CAMBIO DE POLIZA A BASICAR.pdf', '090003e886fcf89c', 'OBSERVACIONES', '01/01/2015 00:00:00', '20/11/2023 09:32:04', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 31, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (32, '37', 'BONUS MALUS "BASICar"', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU ELIGES_argumentarios.pdf', 'd7c9214912768b8a', 'OBSERVACIONES', '20/11/2023 00:00:00', '20/11/2023 09:30:05', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 32, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (33, '38', 'SUPER BONUS Tú eliges', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Superbonus.pdf', '58b4c15428e5e60d', 'OBSERVACIONES', '01/04/2016 00:00:00', '07/08/2017 09:21:34', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 33, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (34, '39', 'SERVICIOS MAPFRE "BASICar"', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SERVICIOS MAPFRE BASICAR.pdf', '090003e886fcfb5e', 'OBSERVACIONES', '25/11/2016 00:00:00', '20/11/2023 09:30:48', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 34, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (35, '40', 'SAT AUTORIZADO', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SAT Autorizado.pdf', '10061149bd84b31e', 'OBSERVACIONES', '25/06/2014', '17/11/2014 00:00:00', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 35, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (36, '41', 'COMPAÑÍA MUTUA MADRILEÑA', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/09/2020 00:00:00', '06/06/2023 13:48:48', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 36, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (37, '42', 'SERVICIOS MAPFRE ACUERDOS', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Servicios Mapfre Acuerdos.pdf', '62fac1542dd48043', NULL, '01/04/2015 00:00:00', '19/04/2016 11:23:02', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 37, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (38, '43', 'Servicios CON Puerta a Puerta', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Servicios_STC.pdf', '7ba8c18312a39465', 'OBSERVACIONES', '01/09/2018 00:00:00', '27/09/2022 09:10:26', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 38, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (39, '44', 'Servicios SIN Puerta a Puerta', 'N', '1', 200, NULL, 41, 'WAUTEMIS', 'OBSERVACIONES', 'N', 'SERVICIOS SIN PUERTA A PUERTA.pdf', '090003e886643579', 'OBSERVACIONES', '01/09/2018 00:00:00', '07/08/2023 08:56:28', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 39, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (40, '45', 'Servicios SIN Puerta a Puerta', 'N', '1', 200, NULL, 41, 'WAUTEMIS', 'OBSERVACIONES', 'N', 'SERVICIOS SIN PUERTA A PUERTA.pdf', '090003e8866437fe', 'OBSERVACIONES', '01/09/2018 00:00:00', '07/08/2023 08:57:21', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 40, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (41, '46', 'Servicios CON Puerta a Puerta', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Servicios_STC.pdf', '7ba5018312a22555', 'OBSERVACIONES', '01/09/2018 00:00:00', '27/09/2022 09:15:01', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 41, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (42, '47', 'COMPAÑÍA ALLIANZ', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/09/2020 00:00:00', '12/01/2022 17:05:06', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 42, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (43, '48', 'CLUB MAPFRE', 'S', '1', 200, NULL, NULL, 'TE_CUIDAMOS', 'OBSERVACIONES', 'N', 'te Cuidamos.pdf', '630071542dd6ab97', 'OBSERVACIONES', '19/07/2015 00:00:00', '17/11/2022 15:33:03', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 43, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (44, '49', 'CLUB MAPFRE MAS', 'S', '1', 200, NULL, NULL, 'TE_CUIDAMOS', 'OBSERVACIONES', 'N', 'te Cuidamos.pdf', '630171542dd6f75c', 'OBSERVACIONES', '19/07/2015 00:00:00', '17/11/2022 15:33:20', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 44, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (45, '50', 'ALARMAS', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'S', 'SCA_ALARMAS.pdf', '866471545c4ea851', 'OBSERVACIONES', '10/01/2016 00:00:00', '17/05/2022 12:16:23', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 45, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (46, '51', 'TRÉBOLES CANJEABLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Tréboles - JEP - Provisional.pdf', '62d4b1542dc64c5c', NULL, '01/04/2016 00:00:00', '19/04/2016 11:07:31', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 46, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (47, '52', 'SUBIDA PRIMA IMPUESTO IPS 8%', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Subida Primas Impuestos.pdf', '803d31774d032995', 'OBSERVACIONES', '01/04/2015 00:00:00', '23/03/2022 12:43:34', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 47, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (48, '53', 'SUPER BONUS TERCEROS', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_SUPERBONUS_TER.pdf', '82479155020890b1', NULL, '01/05/2016 00:00:00', '07/08/2017 09:26:08', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 48, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (49, '54', 'SUPER BONUS FRANQUICIA', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_SUPERBONUS_TRF.pdf', '7a7a615502094d53', NULL, '01/05/2016 00:00:00', '07/08/2017 09:26:26', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 49, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (50, '55', 'SUPER BONUS TODO RIESGO', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_SUPERBONUS_TR.pdf', '824a41550209fd14', NULL, '01/05/2016 00:00:00', '07/08/2017 09:26:36', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 50, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (51, '56', 'SVA PARA RETENCIÓN', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '01/05/2016 00:00:00', '16/09/2024 12:50:21', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 51, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (52, '57', 'PÓLIZA ECOLÓGICA', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_ECOLOGICA.pdf', '5633b154e6c81f6f', NULL, '01/05/2016 00:00:00', '12/01/2022 17:06:00', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 52, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (53, '58', 'PÓLIZA YCAR', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_YCAR.PDF', '5dec3154e6c8c1b7', NULL, '01/05/2016 00:00:00', '12/01/2022 17:07:41', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 53, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (54, '59', 'CAMBIO MODALIDAD YCAR/ECOL', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'CAMBIO MODALIDAD YCAR ECOL..pdf', '090003e8866423c3', NULL, '01/07/2016 00:00:00', '07/08/2023 08:03:10', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 54, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (55, '60', 'SUBIDA PRECIO MOTOS', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCAINCPRMMTOS.pdf', '51ea115da294c69c', 'OBSERVACIONES', '24/09/2016 00:00:00', '20/12/2022 09:04:51', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 55, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (56, '61', 'DOMICILIACION TARJETA', 'S', '1', 200, NULL, NULL, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '22/01/2017 00:00:00', '09/06/2020 07:27:47', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 56, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (57, '62', 'MOTO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/09/2016 00:00:00', '26/03/2026 10:22:43', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 57, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (58, '63', 'ALLIANZ TERCEROS', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/12/2016 00:00:00', '06/06/2023 13:49:18', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 58, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (59, '64', 'ALLIANZ TODO RIESGO', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/12/2016 00:00:00', '06/06/2023 13:49:41', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 59, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (60, '65', 'ALLIANZ TODO RIESGO FRANQUICIA', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/12/2016 00:00:00', '06/06/2023 13:50:07', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 60, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (61, '66', 'MUTUA MAD TERCEROS', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/12/2016 00:00:00', '06/06/2023 13:50:44', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 61, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (62, '67', 'MUTUA MAD TODO RIESGO', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/12/2016 00:00:00', '06/06/2023 13:51:02', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 62, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (63, '68', 'MUTUA MAD MOTOS', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/12/2016 00:00:00', '06/06/2023 13:51:28', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 63, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (64, '69', 'COMPAÑÍA CONTRARIA GENÉRICO', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '15/01/2017 00:00:00', '09/01/2017 12:44:32', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 64, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (65, '70', 'PUERTA A PUERTA', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '15/01/2017 00:00:00', '09/01/2017 12:45:16', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 65, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (66, '71', 'COMPROMISOS', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_COMPROMISOS.pdf', 'b9278159bc0ca6fd', NULL, '22/01/2017 00:00:00', '20/01/2017 14:24:51', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 66, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (67, '72', 'Revisión Técnica', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'S', NULL, NULL, NULL, '27/06/2017 00:00:00', '26/02/2023 15:40:03', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 67, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (68, '73', 'PAGO TARJETA BONIF 20 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/08/2017 00:00:00', '02/07/2018 08:32:23', 'PAGOTARJ', 'TREBOLES', '20', 'N', 'N', NULL, NULL, NULL, 'N', 68, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (69, '74', 'PAGO TARJETA BONIF 30 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/08/2017 00:00:00', '02/07/2018 08:32:15', 'PAGOTARJ', 'TREBOLES', '30', 'N', 'N', NULL, NULL, NULL, 'N', 69, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (70, '75', 'PAGO TARJETA BONIF 50 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/08/2017 00:00:00', '02/07/2018 08:32:07', 'PAGOTARJ', 'TREBOLES', '50', 'N', 'N', NULL, NULL, NULL, 'N', 70, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (71, '76', 'PAGO TARJETA GENÉRICO', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '01/08/2017 00:00:00', '03/11/2021 08:40:11', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 71, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (72, '77', 'TU TE QUEDAS 10 TREBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886644e57', NULL, '28/01/2018 00:00:00', '25/11/2024 09:21:53', 'TTQAUTOS', 'TREBOLES', '10', 'S', 'N', 0, NULL, NULL, 'N', 72, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (73, '78', 'TU TE QUEDAS 15 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886644e5b', NULL, '28/01/2018 00:00:00', '07/08/2023 09:33:17', 'TTQAUTOS', 'TREBOLES', '15', 'S', 'N', 0, NULL, NULL, 'N', 73, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (74, '79', 'TU TE QUEDAS 20 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886645287', NULL, '28/01/2018 00:00:00', '02/12/2024 07:52:50', 'TTQAUTOS', 'TREBOLES', '20', 'S', 'N', 0, NULL, NULL, 'N', 74, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (75, '80', 'TU TE QUEDAS 25 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886645289', NULL, '28/01/2018 00:00:00', '07/08/2023 09:35:08', 'TTQAUTOS', 'TREBOLES', '25', 'S', 'N', 0, NULL, NULL, 'N', 75, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (76, '81', 'TU TE QUEDAS 30 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e88664528c', NULL, '28/01/2018 00:00:00', '02/12/2024 10:25:59', 'TTQAUTOS', 'TREBOLES', '30', 'S', 'N', 0, NULL, NULL, 'N', 76, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (77, '82', 'TU TE QUEDAS 35 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e88664528f', NULL, '28/01/2018 00:00:00', '07/08/2023 09:37:21', 'TTQAUTOS', 'TREBOLES', '35', 'S', 'N', 0, NULL, NULL, 'N', 77, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (78, '83', 'TU TE QUEDAS 40 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866454e1', NULL, '28/01/2018 00:00:00', '28/11/2024 07:27:58', 'TTQAUTOS', 'TREBOLES', '40', 'S', 'N', 0, NULL, NULL, 'N', 78, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (79, '84', 'TU TE QUEDAS 45 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866454e2', NULL, '28/01/2018 00:00:00', '07/08/2023 09:38:52', 'TTQAUTOS', 'TREBOLES', '45', 'S', 'N', 0, NULL, NULL, 'N', 79, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (80, '85', 'TU TE QUEDAS 50 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866454e6', NULL, '28/01/2018 00:00:00', '25/11/2024 09:22:48', 'TTQAUTOS', 'TREBOLES', '50', 'S', 'N', 0, NULL, NULL, 'N', 80, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (81, '86', 'TU TE QUEDAS 55 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866454e9', NULL, '28/01/2018 00:00:00', '07/08/2023 09:40:19', 'TTQAUTOS', 'TREBOLES', '55', 'S', 'N', 0, NULL, NULL, 'N', 81, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (82, '87', 'TU TE QUEDAS 60 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e88664575b', NULL, '28/01/2018 00:00:00', '25/11/2024 09:23:00', 'TTQAUTOS', 'TREBOLES', '60', 'S', 'N', 0, NULL, NULL, 'N', 82, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (83, '88', 'TU TE QUEDAS 10 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '28/01/2018 00:00:00', '30/01/2026 15:12:32', 'TTQAUTOS', 'TREBOLES', '10', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 83, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (84, '89', 'TU TE QUEDAS 15 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:12:40', 'TTQAUTOS', 'TREBOLES', '15', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 84, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (85, '90', 'TU TE QUEDAS 20 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:12:46', 'TTQAUTOS', 'TREBOLES', '20', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 85, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (86, '91', 'TU TE QUEDAS 25 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:13:13', 'TTQAUTOS', 'TREBOLES', '25', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 86, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (87, '92', 'TU TE QUEDAS 30 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:13:02', 'TTQAUTOS', 'TREBOLES', '30', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 87, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (88, '93', 'TU TE QUEDAS 35 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:13:29', 'TTQAUTOS', 'TREBOLES', '35', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 88, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (89, '94', 'TU TE QUEDAS 40 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:13:18', 'TTQAUTOS', 'TREBOLES', '40', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 89, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (90, '95', 'TU TE QUEDAS 45 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:13:45', 'TTQAUTOS', 'TREBOLES', '45', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 90, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (91, '96', 'TU TE QUEDAS 50 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:13:32', 'TTQAUTOS', 'TREBOLES', '50', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 91, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (92, '97', 'TU TE QUEDAS 55 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:14:40', 'TTQAUTOS', 'TREBOLES', '55', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 92, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (93, '98', 'TU TE QUEDAS 60 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/01/2018 00:00:00', '30/01/2026 15:14:50', 'TTQAUTOS', 'TREBOLES', '60', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 93, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (94, '99', 'SUPERBONUS GENERICO', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Superbonus_genérico.pdf', '083cf17a86610455', NULL, '21/12/2017 00:00:00', '06/09/2024 12:54:55', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 94, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (95, '100', 'SUPERBONUS 1a ANUALIDAD', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Superbonus_1er_año.pdf', '090003e8801c58f9', NULL, '21/12/2017 00:00:00', '03/11/2025 14:33:43', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 95, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (96, '101', 'SUPERBONUS 2a ANUALIDAD', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Superbonus_2o_año.pdf', '090003e8801c58fb', NULL, '21/12/2017 00:00:00', '03/11/2025 14:51:59', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 96, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (97, '102', 'SUPERBONUS 3a ANUALIDAD', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Superbonus_3er_año.pdf', '090003e8801c591b', NULL, '21/12/2017 00:00:00', '03/11/2025 14:57:41', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 97, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (98, '103', 'SUPERBONUS PIERDE CANDIDATURA', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '21/12/2017 00:00:00', '19/02/2018 07:46:37', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 98, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (99, '104', 'BASICar GRANDES CIUDADES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'BASICAR GRANDES CIUDADES.pdf', '090003e8801c591c', 'OBSERVACIONES', '21/12/2017 00:00:00', '03/11/2025 14:59:15', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 99, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (100, '105', 'TIPOLOGÍA CLIENTE PLATA', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Argumento Cliente Plata.pdf', '090003e8801c591d', NULL, '21/04/2018 00:00:00', '03/11/2025 15:03:52', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 100, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (101, '106', 'TIPOLOGÍA CLIENTE ORO', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Argumento Cliente Oro.pdf', '090003e8801c5946', NULL, '21/04/2018 00:00:00', '03/11/2025 16:27:16', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 101, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (102, '107', 'TIPOLOGÍA CLIENTE PLATINO', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Argumento Cliente Platino.pdf', NULL, NULL, '21/04/2018 00:00:00', '23/04/2018 10:28:21', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 102, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (103, '108', 'PAGO TARJETA BONIF 25 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_PAGOTARJETABONIFI.pdf', 'a24ea17ce10e8709', NULL, '27/10/2019 00:00:00', '12/01/2022 17:09:12', 'PAGOTARJ', 'TREBOLES', '25', 'N', 'N', NULL, NULL, NULL, 'N', 103, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (104, '109', '*TU TE QUEDAS 30 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/05/2022 12:18:55', 'ESPTTQ18', 'TREBOLES', '30', 'N', 'N', NULL, NULL, NULL, 'N', 104, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (105, '110', '*TU TE QUEDAS 35 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/05/2022 12:19:45', 'ESPTTQ18', 'TREBOLES', '35', 'N', 'N', NULL, NULL, NULL, 'N', 105, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (106, '111', '*TU TE QUEDAS 40 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/05/2022 12:20:27', 'ESPTTQ18', 'TREBOLES', '40', 'N', 'N', NULL, NULL, NULL, 'N', 106, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (107, '112', '*TU TE QUEDAS 45 TRÉBOLES ', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/05/2022 12:21:02', 'ESPTTQ18', 'TREBOLES', '45', 'N', 'N', NULL, NULL, NULL, 'N', 107, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (108, '113', '*TU TE QUEDAS 50 TRÉBOLES', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/05/2022 12:21:43', 'ESPTTQ18', 'TREBOLES', '50', 'N', 'N', NULL, NULL, NULL, 'N', 108, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (109, '114', 'TU TE QUEDAS 30 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '30/01/2026 15:14:40', 'ESPTTQ18', 'TREBOLES', '30', 'N', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 109, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (110, '115', 'TU TE QUEDAS 35 TRB CLUN M.', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/11/2022 15:39:33', 'ESPTTQ18', 'TREBOLES', '35', 'N', 'S', NULL, NULL, NULL, 'N', 110, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (111, '116', 'TU TE QUEDAS 40 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '30/01/2026 15:15:07', 'ESPTTQ18', 'TREBOLES', '40', 'N', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 111, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (112, '117', 'TU TE QUEDAS 45 TRB NO CLUB M.', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '17/11/2022 15:40:25', 'ESPTTQ18', 'TREBOLES', '45', 'N', 'S', NULL, NULL, NULL, 'N', 112, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (113, '118', 'TU TE QUEDAS 50 TRB NO CLUB M.', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '24/07/2018 00:00:00', '30/01/2026 15:15:00', 'ESPTTQ18', 'TREBOLES', '50', 'N', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 113, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (114, '119', 'REGALO DISP MOTO CONECTADA', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'MU-2018-069950 - Regalo dispositivo moto.pdf', '090003e8801c594a', NULL, '01/01/2019 00:00:00', '03/11/2025 16:40:48', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 114, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (115, '120', 'TREBOLES CAMBIO BANKIA ON', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '13/08/2019 00:00:00', '20/03/2026 08:01:17', NULL, NULL, NULL, 'N', 'N', 1, NULL, NULL, 'N', 115, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (116, '121', 'TU TE QUEDAS 10 TREBOLES RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c594b', NULL, '27/10/2019 00:00:00', '03/11/2025 16:42:43', 'TTQAUTORCI', 'TREBOLES', '10', 'S', 'N', 0, NULL, NULL, 'N', 116, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (117, '122', 'TU TE QUEDAS 15 TREBOLES RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c594c', NULL, '27/10/2019 00:00:00', '03/11/2025 16:45:12', 'TTQAUTORCI', 'TREBOLES', '15', 'S', 'N', 0, NULL, NULL, 'N', 117, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (118, '123', 'TU TE QUEDAS 20 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c594d', NULL, '27/10/2019 00:00:00', '03/11/2025 16:46:36', 'TTQAUTORCI', 'TREBOLES', '20', 'S', 'N', 0, NULL, NULL, 'N', 118, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (119, '124', 'TU TE QUEDAS 25 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c596b', NULL, '27/10/2019 00:00:00', '03/11/2025 16:50:10', 'TTQAUTORCI', 'TREBOLES', '25', 'S', 'N', 0, NULL, NULL, 'N', 119, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (120, '125', 'TU TE QUEDAS 30 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c596e', NULL, '27/10/2019 00:00:00', '03/11/2025 16:57:34', 'TTQAUTORCI', 'TREBOLES', '30', 'S', 'N', 0, NULL, NULL, 'N', 120, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (121, '126', 'TU TE QUEDAS 35 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5972', NULL, '27/10/2019 00:00:00', '03/11/2025 17:06:12', 'TTQAUTORCI', 'TREBOLES', '35', 'S', 'N', 0, NULL, NULL, 'N', 121, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (122, '127', 'TU TE QUEDAS 40 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5984', NULL, '27/10/2019 00:00:00', '03/11/2025 17:08:21', 'TTQAUTORCI', 'TREBOLES', '40', 'S', 'N', 0, NULL, NULL, 'N', 122, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (123, '128', 'TU TE QUEDAS 45 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5988', NULL, '27/10/2019 00:00:00', '03/11/2025 17:17:29', 'TTQAUTORCI', 'TREBOLES', '45', 'S', 'N', 0, NULL, NULL, 'N', 123, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (124, '129', 'TU TE QUEDAS 50 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c598b', NULL, '27/10/2019 00:00:00', '03/11/2025 17:21:05', 'TTQAUTORCI', 'TREBOLES', '50', 'S', 'N', 0, NULL, NULL, 'N', 124, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (125, '130', 'TU TE QUEDAS 55 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c59b1', NULL, '27/10/2019 00:00:00', '03/11/2025 17:44:57', 'TTQAUTORCI', 'TREBOLES', '55', 'S', 'N', 0, NULL, NULL, 'N', 125, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (126, '131', 'TU TE QUEDAS 60 TRÉBOLES RCI ', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c59b2', NULL, '27/10/2019 00:00:00', '03/11/2025 17:46:06', 'TTQAUTORCI', 'TREBOLES', '60', 'S', 'N', 0, NULL, NULL, 'N', 126, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (127, '132', 'ALTA CLUB MAPFRE TTQ 10 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c0', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:46:55', 'TTQAUTORCI', 'TREBOLES', '10', 'S', 'S', 0, NULL, NULL, 'N', 127, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (128, '133', 'ALTA CLUB MAPFRE TTQ 15 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c1', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:48:19', 'TTQAUTORCI', 'TREBOLES', '15', 'S', 'S', 0, NULL, NULL, 'N', 128, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (129, '134', 'ALTA CLUB MAPFRE TTQ 20 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c2', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:49:42', 'TTQAUTORCI', 'TREBOLES', '20', 'S', 'S', 0, NULL, NULL, 'N', 129, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (130, '135', 'ALTA CLUB MAPFRE TTQ 25 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c3', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:51:28', 'TTQAUTORCI', 'TREBOLES', '25', 'S', 'S', 0, NULL, NULL, 'N', 130, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (131, '136', 'ALTA CLUB MAPFRE TTQ 30 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c5', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:52:19', 'TTQAUTORCI', 'TREBOLES', '30', 'S', 'S', 0, NULL, NULL, 'N', 131, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (132, '137', 'ALTA CLUB MAPFRE TTQ 35 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c6', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:53:14', 'TTQAUTORCI', 'TREBOLES', '35', 'S', 'S', 0, NULL, NULL, 'N', 132, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (133, '138', 'ALTA CLUB MAPFRE TTQ 40 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c7', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:54:31', 'TTQAUTORCI', 'TREBOLES', '40', 'S', 'S', 0, NULL, NULL, 'N', 133, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (134, '139', 'ALTA CLUB MAPFRE TTQ 45 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59c8', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:55:14', 'TTQAUTORCI', 'TREBOLES', '45', 'S', 'S', 0, NULL, NULL, 'N', 134, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (135, '140', 'ALTA CLUB MAPFRE TTQ 50 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59d4', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:57:22', 'TTQAUTORCI', 'TREBOLES', '50', 'S', 'S', 0, NULL, NULL, 'N', 135, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (136, '141', 'ALTA CLUB MAPFRE TTQ 55 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59d5', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:58:22', 'TTQAUTORCI', 'TREBOLES', '55', 'S', 'S', 0, NULL, NULL, 'N', 136, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (137, '142', 'ALTA CLUB MAPFRE TTQ 60 TR RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c59d6', 'OBSERVACIONES', '27/10/2019 00:00:00', '03/11/2025 17:59:33', 'TTQAUTORCI', 'TREBOLES', '60', 'S', 'S', 0, NULL, NULL, 'N', 137, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (138, '143', 'CLUB MAPFRE ORO', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Oro.pdf', '090003e8801c5af3', 'OBSERVACIONES', '24/02/2020 00:00:00', '04/11/2025 12:46:29', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 138, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (139, '144', 'CLUB MAPFRE PLATA', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Plata.pdf', '090003e8801c5b0d', 'OBSERVACIONES', '17/02/2020 00:00:00', '04/11/2025 13:56:20', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 139, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (140, '145', 'CLUB MAPFRE PLATINO', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Platino.pdf', '090003e8801c5b0e', 'OBSERVACIONES', '17/02/2020 00:00:00', '04/11/2025 13:56:44', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 140, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (141, '147', 'COVID-19 Campaña Autónomos', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'CAMPAÑA AUTONOMO.pdf', '090003e8801c5b0f', 'OBSERVACIONES', '08/04/2020 00:00:00', '04/11/2025 13:57:51', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 141, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (142, '148', 'COVID-19 campaña Pymes ', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'CAMPAÑA PYME.PDF', '090003e8801c5b29', 'OBSERVACIONES', '08/04/2020 00:00:00', '04/11/2025 13:58:44', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 142, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (143, '149', 'COVID-19 Contingencia Mapfre', 'S', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '08/04/2020 00:00:00', '12/01/2022 17:09:55', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 143, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (144, '150', 'POTENCIAL PLAN DE PAGOS', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Plan_de_Pagos_SCA_julio_2021.pdf', '090003e8801c5b30', 'OBSERVACIONES', '18/05/2020 00:00:00', '04/11/2025 14:20:41', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 144, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (145, '151', 'PAGO TARJETA BONIFICADO 3%', 'N', '1', 200, NULL, 41, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '25/05/2020 00:00:00', '25/05/2026 11:53:53', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 145, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (146, '152', 'TU TE QUEDAS BANKIA 10 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b31', NULL, '20/07/2020 00:00:00', '04/11/2025 14:21:34', 'TTQBANKIA', 'TREBOLES', '10', 'S', 'N', 0, NULL, NULL, 'N', 146, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (147, '153', 'TU TE QUEDAS BANKIA 15 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b32', NULL, '20/07/2020 00:00:00', '04/11/2025 14:24:51', 'TTQBANKIA', 'TREBOLES', '15', 'S', 'N', 0, NULL, NULL, 'N', 147, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (148, '154', 'TU TE QUEDAS BANKIA 20 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b3e', NULL, '20/07/2020 00:00:00', '04/11/2025 14:25:41', 'TTQBANKIA', 'TREBOLES', '20', 'S', 'N', 0, NULL, NULL, 'N', 148, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (149, '155', 'TU TE QUEDAS BANKIA 25 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b3f', NULL, '20/07/2020 00:00:00', '04/11/2025 14:27:04', 'TTQBANKIA', 'TREBOLES', '25', 'S', 'N', 0, NULL, NULL, 'N', 149, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (150, '156', 'TU TE QUEDAS BANKIA 30 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b40', NULL, '20/07/2020 00:00:00', '04/11/2025 14:28:18', 'TTQBANKIA', 'TREBOLES', '30', 'S', 'N', 0, NULL, NULL, 'N', 150, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (151, '157', 'TU TE QUEDAS BANKIA 35 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b41', NULL, '20/07/2020 00:00:00', '04/11/2025 14:32:10', 'TTQBANKIA', 'TREBOLES', '35', 'S', 'N', 0, NULL, NULL, 'N', 151, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (152, '158', 'TU TE QUEDAS BANKIA 40 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b42', NULL, '20/07/2020 00:00:00', '04/11/2025 14:33:27', 'TTQBANKIA', 'TREBOLES', '40', 'S', 'N', 0, NULL, NULL, 'N', 152, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (153, '159', 'TU TE QUEDAS BANKIA 45 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b43', NULL, '20/07/2020 00:00:00', '04/11/2025 14:37:43', 'TTQBANKIA', 'TREBOLES', '45', 'S', 'N', 0, NULL, NULL, 'N', 153, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (154, '160', 'TU TE QUEDAS BANKIA 50 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b45', NULL, '20/07/2020 00:00:00', '04/11/2025 14:40:52', 'TTQBANKIA', 'TREBOLES', '50', 'S', 'N', 0, NULL, NULL, 'N', 154, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (155, '161', 'TU TE QUEDAS BANKIA 55 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b46', NULL, '20/07/2020 00:00:00', '04/11/2025 14:43:46', 'TTQBANKIA', 'TREBOLES', '55', 'S', 'N', 0, NULL, NULL, 'N', 155, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (156, '162', 'TU TE QUEDAS BANKIA 60 TRB', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c5b47', NULL, '20/07/2020 00:00:00', '04/11/2025 14:44:58', 'TTQBANKIA', 'TREBOLES', '60', 'S', 'N', 0, NULL, NULL, 'N', 156, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (157, '163', 'TT QUEDAS BANKIA 10 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b53', NULL, '20/07/2020 00:00:00', '04/11/2025 14:49:30', 'TTQBANKIA', 'TREBOLES', '10', 'S', 'S', 0, NULL, NULL, 'N', 157, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (158, '164', 'TT QUEDAS BANKIA 15 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b54', NULL, '20/07/2020 00:00:00', '04/11/2025 14:59:46', 'TTQBANKIA', 'TREBOLES', '15', 'S', 'S', 0, NULL, NULL, 'N', 158, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (159, '165', 'TT QUEDAS BANKIA 20 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b55', NULL, '20/07/2020 00:00:00', '04/11/2025 15:01:04', 'TTQBANKIA', 'TREBOLES', '20', 'S', 'S', 0, NULL, NULL, 'N', 159, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (160, '166', 'TT QUEDAS BANKIA 25 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b8b', NULL, '20/07/2020 00:00:00', '04/11/2025 17:47:14', 'TTQBANKIA', 'TREBOLES', '25', 'S', 'S', 0, NULL, NULL, 'N', 160, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (161, '167', 'TT QUEDAS BANKIA 30 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b8d', NULL, '20/07/2020 00:00:00', '04/11/2025 17:52:07', 'TTQBANKIA', 'TREBOLES', '30', 'S', 'S', 0, NULL, NULL, 'N', 161, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (162, '168', 'TT QUEDAS BANKIA 35 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b8e', NULL, '20/07/2020 00:00:00', '04/11/2025 17:53:27', 'TTQBANKIA', 'TREBOLES', '35', 'S', 'S', 0, NULL, NULL, 'N', 162, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (163, '169', 'TT QUEDAS BANKIA 40 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5b8f', NULL, '20/07/2020 00:00:00', '04/11/2025 17:54:53', 'TTQBANKIA', 'TREBOLES', '40', 'S', 'S', 0, NULL, NULL, 'N', 163, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (164, '170', 'TT QUEDAS BANKIA 45 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c5bf7', NULL, '20/07/2020 00:00:00', '05/11/2025 09:46:11', 'TTQBANKIA', 'TREBOLES', '45', 'S', 'S', 0, NULL, NULL, 'N', 164, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (165, '171', 'TT QUEDAS BANKIA 50 TRB NO TC', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '6a73c180ffe275a2', NULL, '20/07/2020 00:00:00', '21/11/2022 15:43:31', 'TTQBANKIA', 'TREBOLES', '50', 'S', 'S', NULL, NULL, NULL, 'N', 165, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (166, '172', 'TT QUEDAS BANKIA 55 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c6203', NULL, '20/07/2020 00:00:00', '05/11/2025 16:48:10', 'TTQBANKIA', 'TREBOLES', '55', 'S', 'S', 0, NULL, NULL, 'N', 166, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (167, '173', 'TT QUEDAS BANKIA 60 TRB NO TC', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TU TE QUEDAS_052022.pdf', '090003e8801c6204', NULL, '20/07/2020 00:00:00', '05/11/2025 16:48:49', 'TTQBANKIA', 'TREBOLES', '60', 'S', 'S', 0, NULL, NULL, 'N', 167, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (168, '174', 'RESERVA DE PRIMA', 'N', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_RESERVA PRIMA.pdf', '090003e8801d61f3', 'OBSERVACIONES', '10/12/2020 00:00:00', '25/05/2026 12:00:58', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 168, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (169, '175', 'CAMBIO DE FORMA DE PAGO', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '07/02/2022 00:00:00', '07/02/2022 13:06:03', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 169, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (170, '176', 'GESTIÓN COMPETENCIA', 'N', '2', 73, NULL, NULL, 'GESTION_COMPETENCIA', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '07/02/2022 00:00:00', '07/02/2022 13:07:15', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 170, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (171, '177', 'PAGO TARJETA BONIFICADO 3%', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_PAGO TARJETA.pdf', '090003e8801c6207', NULL, '07/02/2022 00:00:00', '25/05/2026 11:53:37', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 171, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (172, '178', 'AJUSTE COMERCIAL DE CARTERA 2', 'S', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'Observaciones', '07/02/2022 00:00:00', '26/10/2026 16:33:48', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 172, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (173, '179', 'POTENCIAL PLAN DE PAGOS', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Plan_de_Pagos_SCA_julio_2021.pdf', '090003e8801c6208', 'OBSERVACIONES', '07/02/2022 00:00:00', '05/11/2026 12:06:05', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 173, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (174, '180', 'CESIÓN DERE./REDUCCIÓN GARAN.', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '07/02/2022 00:00:00', '17/03/2022 18:17:49', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 174, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (175, '181', 'SUPLEMENTO GENERAL', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '07/02/2022 00:00:00', '07/02/2022 13:17:34', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 175, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (176, '182', 'CLUB MAPFRE PLATA', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Plata.pdf', '090003e8801c620a', 'OBSERVACIONES', '07/02/2022 00:00:00', '05/11/2025 17:14:51', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 176, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (177, '183', 'COMPROMISOS', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '07/02/2022 00:00:00', '07/02/2022 13:19:34', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 177, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (178, '184', 'INSATISFACCIÓN CON EL SERVICIO', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'INSATISFACCIÓN CON EL SERVICIO HOGAR.pdf', '60da517ed4213e35', NULL, '07/02/2022 00:00:00', '07/02/2022 13:20:55', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 178, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (179, '185', 'ME HA SUBIDO MUCHO LA PRIMA ', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'INCREMENTO PRIMA.pdf', '090003e8801c620b', 'OBSERVACIONES', '07/02/2022 00:00:00', '05/11/2025 17:18:53', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 179, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (180, '186', 'MEJOR PRECIO DE LA COMPETENCIA', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'MEJOR PRECIO LA COMPETENCIA HOGAR.pdf', '090003e8801c620c', 'OBSERVACIONES', '07/02/2022 00:00:00', '05/11/2025 17:19:53', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 180, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (181, '187', 'NO PUEDO PAGAR ESA CANTIDAD', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'NO PUEDO PAGAR ESA CANTIDAD HOGAR.pdf', '090003e8801c621a', NULL, '07/02/2022 00:00:00', '05/11/2025 17:20:22', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 181, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (182, '188', 'SERVICIOS MAPFRE', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'servicios mapfre.pdf', '090003e8801c621c', NULL, '07/02/2022 00:00:00', '05/11/2025 17:20:46', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 182, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (183, '190', 'SUBIDA DE IMPUESTOS IPS', 'S', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '07/02/2022 00:00:00', '23/03/2022 12:43:43', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 183, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (184, '192', 'VENTAJAS DEL PRODUCTO', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'ventajas del producto.pdf', '090003e8801c6220', 'OBSERVACIONES', '07/02/2022 00:00:00', '05/11/2025 17:38:35', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 184, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (185, '193', 'DESCUENTO SAT B', 'S', '1', 200, NULL, NULL, 'WAUTEMIS', 'OBSERVACIONES', 'S', NULL, NULL, NULL, '28/09/2021 00:00:00', '22/03/2022 16:39:25', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 185, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (186, '200', 'TU TE QUEDAS H 10 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6221', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:42:06', 'TTQHOGAR', 'TREBOLES', '10', 'S', 'N', 0, NULL, NULL, 'N', 186, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (187, '201', 'TU TE QUEDAS H 15 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6222', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:42:28', 'TTQHOGAR', 'TREBOLES', '15', 'S', 'N', 0, NULL, NULL, 'N', 187, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (188, '202', 'TU TE QUEDAS H 20 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6223', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:43:09', 'TTQHOGAR', 'TREBOLES', '20', 'S', 'N', 0, NULL, NULL, 'N', 188, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (189, '203', 'TU TE QUEDAS H 25 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6235', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:44:22', 'TTQHOGAR', 'TREBOLES', '25', 'S', 'N', 0, NULL, NULL, 'N', 189, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (190, '204', 'TU TE QUEDAS H 30 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6236', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:44:43', 'TTQHOGAR', 'TREBOLES', '30', 'S', 'N', 0, NULL, NULL, 'N', 190, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (191, '205', 'TU TE QUEDAS H 35 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6237', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:45:31', 'TTQHOGAR', 'TREBOLES', '35', 'S', 'N', 0, NULL, NULL, 'N', 191, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (192, '206', 'TU TE QUEDAS H 40 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6238', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:48:09', 'TTQHOGAR', 'TREBOLES', '40', 'S', 'N', 0, NULL, NULL, 'N', 192, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (193, '207', 'TU TE QUEDAS H 45 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6239', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:48:54', 'TTQHOGAR', 'TREBOLES', '45', 'S', 'N', 0, NULL, NULL, 'N', 193, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (194, '208', 'TU TE QUEDAS H 50 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c623a', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:49:30', 'TTQHOGAR', 'TREBOLES', '50', 'S', 'N', 0, NULL, NULL, 'N', 194, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (195, '209', 'TU TE QUEDAS H 55 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c623b', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:49:57', 'TTQHOGAR', 'TREBOLES', '55', 'S', 'N', 0, NULL, NULL, 'N', 195, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (196, '210', 'TU TE QUEDAS H 60 TREBOLES', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c623d', 'OBSERVACIONES', '11/05/2022 00:00:00', '05/11/2025 17:51:56', 'TTQHOGAR', 'TREBOLES', '60', 'S', 'N', 0, NULL, NULL, 'N', 196, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (197, '211', 'TU TE QUEDAS H 10 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c623e', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:10:32', 'TTQHOGAR', 'TREBOLES', '10', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 197, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (198, '212', 'TU TE QUEDAS H 15 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6249', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:10:21', 'TTQHOGAR', 'TREBOLES', '15', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 198, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (199, '213', 'TU TE QUEDAS H 20 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c624a', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:10:29', 'TTQHOGAR', 'TREBOLES', '20', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 199, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (200, '214', 'TU TE QUEDAS H 25 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c624b', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:10:36', 'TTQHOGAR', 'TREBOLES', '25', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 200, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (201, '215', 'TU TE QUEDAS H 30 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c624c', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:11:03', 'TTQHOGAR', 'TREBOLES', '30', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 201, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (202, '216', 'TU TE QUEDAS H 35 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c624d', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:10:53', 'TTQHOGAR', 'TREBOLES', '35', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 202, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (203, '217', 'TU TE QUEDAS H 40 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c624e', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:11:02', 'TTQHOGAR', 'TREBOLES', '40', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 203, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (204, '218', 'TU TE QUEDAS H 45 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c624f', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:11:10', 'TTQHOGAR', 'TREBOLES', '45', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 204, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (205, '219', 'TU TE QUEDAS H 50 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6250', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:11:19', 'TTQHOGAR', 'TREBOLES', '50', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 205, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (206, '220', 'TU TE QUEDAS H 55 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6251', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:11:27', 'TTQHOGAR', 'TREBOLES', '55', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 206, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (207, '221', 'TU TE QUEDAS H 60 TRB NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6252', 'OBSERVACIONES', '11/05/2022 00:00:00', '30/01/2026 15:11:37', 'TTQHOGAR', 'TREBOLES', '60', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 207, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (208, '222', 'TU TE QUEDAS H BANKIA 10 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6496', 'OBSERVACIONES', '11/05/2022 00:00:00', '06/11/2025 17:22:42', 'TTQHOGBNK', 'TREBOLES', '10', 'S', 'N', 0, NULL, NULL, 'N', 208, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (209, '223', 'TU TE QUEDAS H BANKIA 15 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8801c6497', 'OBSERVACIONES', '11/05/2022 00:00:00', '06/11/2025 17:23:01', 'TTQHOGBNK', 'TREBOLES', '15', 'S', 'N', 0, NULL, NULL, 'N', 209, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (210, '224', 'TU TE QUEDAS H BANKIA 20 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866484dd', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:35:04', 'TTQHOGBNK', 'TREBOLES', '20', 'S', 'N', 0, NULL, NULL, 'N', 210, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (211, '225', 'TU TE QUEDAS H BANKIA 25 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866484de', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:35:31', 'TTQHOGBNK', 'TREBOLES', '25', 'S', 'N', 0, NULL, NULL, 'N', 211, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (212, '226', 'TU TE QUEDAS H BANKIA 30 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866484e0', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:36:00', 'TTQHOGBNK', 'TREBOLES', '30', 'S', 'N', 0, NULL, NULL, 'N', 212, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (213, '227', 'TU TE QUEDAS H BANKIA 35 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866484e1', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:36:27', 'TTQHOGBNK', 'TREBOLES', '35', 'S', 'N', 0, NULL, NULL, 'N', 213, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (214, '228', 'TU TE QUEDAS H BANKIA 40 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e8866484e5', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:36:51', 'TTQHOGBNK', 'TREBOLES', '40', 'S', 'N', 0, NULL, NULL, 'N', 214, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (215, '229', 'TU TE QUEDAS H BANKIA 45 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886648755', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:37:21', 'TTQHOGBNK', 'TREBOLES', '45', 'S', 'N', 0, NULL, NULL, 'N', 215, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (216, '230', 'TU TE QUEDAS H BANKIA 50 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886648757', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:37:52', 'TTQHOGBNK', 'TREBOLES', '50', 'S', 'N', 0, NULL, NULL, 'N', 216, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (217, '231', 'TU TE QUEDAS H BANKIA 55 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886648759', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:38:22', 'TTQHOGBNK', 'TREBOLES', '55', 'S', 'N', 0, NULL, NULL, 'N', 217, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (218, '232', 'TU TE QUEDAS H BANKIA 60 TRB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e88664875e', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/08/2023 10:38:50', 'TTQHOGBNK', 'TREBOLES', '60', 'S', 'N', 0, NULL, NULL, 'N', 218, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (219, '233', 'TT QUEDAS BANKIA 10 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26c63181200371f1', NULL, '11/05/2022 00:00:00', '01/06/2022 18:05:05', 'TTQHOGBNK', 'TREBOLES', '10', 'S', 'S', NULL, NULL, NULL, 'N', 219, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (220, '234', 'TT QUEDAS BANKIA 15 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', 'e7da81812003d089', NULL, '11/05/2022 00:00:00', '01/06/2022 18:05:30', 'TTQHOGBNK', 'TREBOLES', '15', 'S', 'S', NULL, NULL, NULL, 'N', 220, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (221, '235', 'TT QUEDAS BANKIA 20 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26c781812004387f', NULL, '11/05/2022 00:00:00', '01/06/2022 18:05:56', 'TTQHOGBNK', 'TREBOLES', '20', 'S', 'S', NULL, NULL, NULL, 'N', 221, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (222, '236', 'TT QUEDAS BANKIA 25 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', 'e7dc11812004b6a3', NULL, '11/05/2022 00:00:00', '01/06/2022 18:06:28', 'TTQHOGBNK', 'TREBOLES', '25', 'S', 'S', NULL, NULL, NULL, 'N', 222, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (223, '237', 'TT QUEDAS BANKIA 30 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', 'e7dc518120050d19', NULL, '11/05/2022 00:00:00', '01/06/2022 18:06:51', 'TTQHOGBNK', 'TREBOLES', '30', 'S', 'S', NULL, NULL, NULL, 'N', 223, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (224, '238', 'TT QUEDAS BANKIA 35 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26c8e18120055f1d', NULL, '11/05/2022 00:00:00', '01/06/2022 18:07:12', 'TTQHOGBNK', 'TREBOLES', '35', 'S', 'S', NULL, NULL, NULL, 'N', 224, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (225, '239', 'TT QUEDAS BANKIA 40 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26c941812005bab3', NULL, '11/05/2022 00:00:00', '01/06/2022 18:07:35', 'TTQHOGBNK', 'TREBOLES', '40', 'S', 'S', NULL, NULL, NULL, 'N', 225, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (226, '240', 'TT QUEDAS BANKIA 45 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26c9a18120061819', NULL, '11/05/2022 00:00:00', '01/06/2022 18:07:59', 'TTQHOGBNK', 'TREBOLES', '45', 'S', 'S', NULL, NULL, NULL, 'N', 226, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (227, '241', 'TT QUEDAS BANKIA 50 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26cab1812006cbd6', NULL, '11/05/2022 00:00:00', '01/06/2022 18:08:45', 'TTQHOGBNK', 'TREBOLES', '50', 'S', 'S', NULL, NULL, NULL, 'N', 227, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (228, '242', 'TT QUEDAS BANKIA 55 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26cb518120071f3d', NULL, '11/05/2022 00:00:00', '01/06/2022 18:09:06', 'TTQHOGBNK', 'TREBOLES', '55', 'S', 'S', NULL, NULL, NULL, 'N', 228, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (229, '243', 'TT QUEDAS BANKIA 60 TRB NO TC', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '26cba18120077077', NULL, '11/05/2022 00:00:00', '01/06/2022 18:09:27', 'TTQHOGBNK', 'TREBOLES', '60', 'S', 'S', NULL, NULL, NULL, 'N', 229, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (230, '245', 'CLUB MAPFRE ORO', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Oro.pdf', '090003e88919ad11', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/01/2025 11:29:45', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 230, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (231, '246', 'CLUB MAPFRE PLATA', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Plata.pdf', '090003e88919ad27', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/01/2025 11:30:06', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 231, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (232, '247', 'CLUB MAPFRE PLATINO', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Club MAPFRE Platino.pdf', '090003e88919ad15', 'OBSERVACIONES', '11/05/2022 00:00:00', '07/01/2025 11:30:26', NULL, NULL, NULL, 'N', 'S', 0, NULL, NULL, 'N', 232, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (233, '250', 'RESERVA DE PRIMA', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '04/08/2022 00:00:00', '25/05/2026 12:00:42', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 233, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (234, '251', 'REGALO DE PERMANENCIA', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '25/11/2022 00:00:00', '28/11/2022 16:05:33', 'PREMAN', 'TREBOLES', '0', 'S', 'S', NULL, NULL, NULL, 'N', 234, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (235, '252', 'SERVICIO VALOR AÑADIDO', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '25/11/2022 00:00:00', '25/05/2026 12:01:20', NULL, NULL, NULL, 'S', 'S', 0, NULL, NULL, 'N', 235, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (236, '253', 'REGALO DE PERMANENCIA', 'N', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '25/11/2022 00:00:00', '28/11/2022 16:06:24', 'PREMAN', 'TREBOLES', '0', 'S', 'S', NULL, NULL, NULL, 'N', 236, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (237, '254', 'SERVICIO VALOR AÑADIDO', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '25/11/2022 00:00:00', '25/05/2026 12:01:30', NULL, NULL, NULL, 'S', 'S', 0, NULL, NULL, 'N', 237, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (238, '255', 'PREMIO DE FIDELIZACIÓN AUTOS', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '25/11/2022 00:00:00', '25/05/2026 11:59:54', 'PREMFIDE', 'TREBOLES', '0', 'S', 'S', 0, NULL, NULL, 'N', 238, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (239, '256', 'PREMIO DE FIDELIZACIÓN HOGAR', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '25/11/2022 00:00:00', '25/05/2026 12:00:06', 'PREMFIDE', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 239, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (240, '257', 'GRACIAS MADRID', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'Campaña_GRACIAS_Madrid.pdf', 'e073018506b624c9', 'OBSERVACIONES', '12/12/2022 00:00:00', '12/12/2022 15:21:19', 'GRACIASMAS', 'TREBOLES', '0', 'N', 'N', NULL, NULL, NULL, 'N', 240, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (241, '258', 'GRACIAS MADRID', 'S', '2', 73, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '12/12/2022 00:00:00', '16/12/2022 11:21:33', 'GRACIASMAS', 'TREBOLES', '0', 'N', 'N', NULL, NULL, NULL, 'N', 241, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (242, '259', 'INCREMENTO PRIMA PLATINO', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_INCREMENTO PRIMA PLATINO.pdf', '1fccd1851a640bcf', NULL, '16/12/2022 00:00:00', '20/12/2022 09:00:27', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 242, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (243, '261', 'INCREMENTO PRIMA CON SINIESTRO', 'N', '1', 200, NULL, NULL, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_INCREMENTO PRIMA CON STROS.pdf', '1fcf81851a652415', NULL, '16/12/2022 00:00:00', '20/12/2022 09:00:39', NULL, NULL, NULL, 'N', 'N', NULL, NULL, NULL, 'N', 243, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (244, '263', 'INCREMENTO PRIMA SIN SINIESTRO', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '16/12/2022 00:00:00', '10/10/2024 11:46:26', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 244, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (245, '265', 'INCREMENTO PRIMA', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_INCREMENTO PRIMA (general).pdf', '090003e8801d6286', NULL, '16/12/2022 00:00:00', '11/12/2025 14:21:19', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 245, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (246, '267', 'INCREMENTO PRIMA SINIESTROS', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'INCREMENTO PRIMA SINIESTROS.pdf', '090003e8801c40f5', NULL, '16/12/2022 00:00:00', '22/10/2025 16:28:11', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 246, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (247, '270', 'TU TE QUEDAS 70 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886646975', NULL, '13/01/2023 00:00:00', '25/11/2024 09:28:08', 'TTQAUTOS', 'TREBOLES', '70', 'S', 'N', 0, NULL, NULL, 'N', 247, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (248, '271', 'TU TE QUEDAS 80 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886646b80', NULL, '13/01/2023 00:00:00', '07/08/2023 10:04:10', 'TTQAUTOS', 'TREBOLES', '80', 'S', 'N', 0, NULL, NULL, 'N', 248, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (249, '272', 'TU TE QUEDAS 90 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886646b82', NULL, '13/01/2023 00:00:00', '07/08/2023 10:04:34', 'TTQAUTOS', 'TREBOLES', '90', 'S', 'N', 0, NULL, NULL, 'N', 249, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (250, '273', 'TU TE QUEDAS 100 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TU TE QUEDAS.pdf', '090003e886646b85', NULL, '13/01/2023 00:00:00', '07/08/2023 10:05:00', 'TTQAUTOS', 'TREBOLES', '100', 'S', 'N', 0, NULL, NULL, 'N', 250, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (251, '274', 'TTQ 70 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:15:30', 'TTQAUTOS', 'TREBOLES', '70', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 251, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (252, '275', 'TTQ 80 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:15:38', 'TTQAUTOS', 'TREBOLES', '80', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 252, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (253, '276', 'TTQ 90 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:16:01', 'TTQAUTOS', 'TREBOLES', '90', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 253, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (254, '277', 'TTQ 100 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:18:25', 'TTQAUTOS', 'TREBOLES', '100', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 254, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (255, '278', 'TTQ RCI 70 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '41bb5185aa7121e9', NULL, '13/01/2023 00:00:00', '29/05/2023 12:18:21', 'TTQAUTORCI', 'TREBOLES', '70', 'S', 'N', 0, NULL, NULL, 'N', 255, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (256, '279', 'TTQ RCI 80 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '374d0185aa7c7556', NULL, '13/01/2023 00:00:00', '29/05/2023 12:17:41', 'TTQAUTORCI', 'TREBOLES', '80', 'S', 'N', 0, NULL, NULL, 'N', 256, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (257, '280', 'TTQ RCI 90 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '376ab185aa8a774c', NULL, '13/01/2023 00:00:00', '29/05/2023 12:17:17', 'TTQAUTORCI', 'TREBOLES', '90', 'S', 'N', 0, NULL, NULL, 'N', 257, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (258, '281', 'TTQ RCI 100 TRÉBOLES', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_TUTEQUEDAS.pdf', '376f5185aa8c2900', NULL, '13/01/2023 00:00:00', '29/05/2023 12:16:56', 'TTQAUTORCI', 'TREBOLES', '100', 'S', 'N', 0, NULL, NULL, 'N', 258, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (259, '282', 'TTQ RCI 70 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:18:16', 'TTQAUTORCI', 'TREBOLES', '70', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 259, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (260, '283', 'TTQ RCI 80 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:18:43', 'TTQAUTORCI', 'TREBOLES', '80', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 260, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (261, '284', 'TTQ RCI 90 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:18:35', 'TTQAUTORCI', 'TREBOLES', '90', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 261, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (262, '285', 'TTQ RCI 100 NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '13/01/2023 00:00:00', '30/01/2026 15:19:05', 'TTQAUTORCI', 'TREBOLES', '100', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 262, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (263, '286', 'TRÉBOLES DE RETOS', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '13/03/2023 00:00:00', '25/05/2026 12:23:54', 'RETOS', 'TREBOLES', '0', 'S', 'S', 0, NULL, NULL, 'N', 263, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (264, '287', 'TREBOLES DE RETOS', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '13/03/2023 00:00:00', '25/05/2026 12:23:33', 'RETOS', 'TREBOLES', '0', 'S', 'S', 0, NULL, NULL, 'N', 264, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (265, '290', 'PÉRDIDA DE DESCUENTOS', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_PERDIDA DE DESCUENTOS.pdf', '090003e8875ba259', NULL, '18/04/2023 00:00:00', '15/01/2024 09:43:12', NULL, NULL, NULL, 'N', 'N', 0, NULL, 'www.mapfre.es', 'N', 265, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (266, '291', 'PÉRDIDA DE DESCUENTOS', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'SCA_PERDIDA DE DESCUENTOS.pdf', '090003e8875d2a87', NULL, '18/04/2023 00:00:00', '15/01/2024 15:12:00', NULL, NULL, NULL, 'N', 'N', 0, NULL, 'www.mapfre.es', 'N', 266, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (267, '292', 'SUPLEMENTO DESMARCAR ANULACION', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '18/04/2023 00:00:00', '21/06/2023 16:05:32', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 267, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (268, '293', 'SUPLEMENTO DESMARCAR ANULACIÓN', 'S', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '18/04/2023 00:00:00', '18/04/2023 13:04:34', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 268, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (269, '294', 'DESCUENTO COMUNIDAD', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '18/04/2023 00:00:00', '25/05/2026 11:53:05', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 269, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (270, '295', 'OPORTUNIDAD DE DESCUENTOS', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '18/04/2023 00:00:00', '26/02/2024 15:50:55', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 270, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (271, '296', 'OPORTUNIDAD DE DESCUENTOS', 'S', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'Insttrucui', 'N', 'DNI', '090003e8802a2263', 'Otra', '18/04/2023 00:00:00', '27/10/2026 16:40:22', NULL, 'TREBOLES', '20', 'N', 'N', 0, NULL, NULL, 'N', 271, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (272, '297', 'SUPLEMENTO DESMARCAR ANULACION', 'S', '1', 200, NULL, 1, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '21/06/2023 00:00:00', '21/06/2023 16:43:08', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 272, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (273, '300', 'TU TE QUEDAS', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '22/10/2026 15:54:49', 'TTQAUTOS', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 273, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (274, '301', 'TU TE QUEDAS NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '09/09/2026 12:43:59', 'TTQAUTOS', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 274, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (275, '302', 'TU TE QUEDAS RCI', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:47:07', 'TTQAUTORCI', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 275, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (276, '303', 'TU TE QUEDAS RCI NO CLB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:47:26', 'TTQAUTORCI', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 276, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (277, '304', 'TU TE QUEDAS BANKIA', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:47:41', 'TTQBANKIA', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 277, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (278, '305', 'TU TE QUEDAS BANKIA NO CLB MAP', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:48:28', 'TTQBANKIA', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 278, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (279, '306', 'TU TE QUEDAS HOGAR', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:49:55', 'TTQHOGAR', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 279, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (280, '307', 'TU TE QUEDAS HOGAR NO CLUB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:50:07', 'TTQHOGAR', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 280, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (281, '308', 'TU TE QUEDAS H BANKIA', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:50:19', 'TTQHOGBNK', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 281, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (282, '309', 'TU TE QUEDAS H BANKIA NO CLB', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '06/09/2023 00:00:00', '25/05/2026 12:50:28', 'TTQHOGBNK', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 282, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (283, '310', 'DEFENSA DE CARTERA', 'N', '1', 200, NULL, 41, 'WAUTEMIS', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '13/02/2024 00:00:00', '25/05/2026 11:44:13', 'DEFCART', 'EUROS', '0', 'N', 'N', 0, NULL, NULL, 'N', 283, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (284, '311', 'DEFENSA DE CARTERA', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '13/02/2024 00:00:00', '25/05/2026 11:52:49', 'DEFCART', 'EUROS', '0', 'N', 'N', 0, NULL, NULL, 'N', 284, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (285, '312', 'TU TE QUEDAS 10 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '10', 'S', 'N', 0, NULL, NULL, 'N', 285, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (286, '313', 'TU TE QUEDAS 15 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '15', 'S', 'N', 0, NULL, NULL, 'N', 286, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (287, '314', 'TU TE QUEDAS 20 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '20', 'S', 'N', 0, NULL, NULL, 'N', 287, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (288, '315', 'TU TE QUEDAS 25 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '25', 'S', 'N', 0, NULL, NULL, 'N', 288, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (289, '316', 'TU TE QUEDAS 30 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '30', 'S', 'N', 0, NULL, NULL, 'N', 289, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (290, '317', 'TU TE QUEDAS 35 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '35', 'S', 'N', 0, NULL, NULL, 'N', 290, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (291, '318', 'TU TE QUEDAS 40 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '40', 'S', 'N', 0, NULL, NULL, 'N', 291, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (292, '319', 'TU TE QUEDAS 45 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '45', 'S', 'N', 0, NULL, NULL, 'N', 292, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (293, '320', 'TU TE QUEDAS 50 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '50', 'S', 'N', 0, NULL, NULL, 'N', 293, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (294, '321', 'TU TE QUEDAS 55 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '55', 'S', 'N', 0, NULL, NULL, 'N', 294, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (295, '322', 'TU TE QUEDAS 60 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '60', 'S', 'N', 0, NULL, NULL, 'N', 295, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (296, '323', 'TTQ CON 10 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:19:17', 'TTQAUTOCON', 'TREBOLES', '10', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 296, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (297, '324', 'TTQ CON 15 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:19:48', 'TTQAUTOCON', 'TREBOLES', '15', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 297, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (298, '325', 'TTQ CON 20 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:20:10', 'TTQAUTOCON', 'TREBOLES', '20', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 298, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (299, '326', 'TTQ CON 25 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:20:01', 'TTQAUTOCON', 'TREBOLES', '25', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 299, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (300, '327', 'TTQ CON 30 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:20:30', 'TTQAUTOCON', 'TREBOLES', '30', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 300, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (301, '328', 'TTQ CON 35 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:20:38', 'TTQAUTOCON', 'TREBOLES', '35', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 301, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (302, '329', 'TTQ CON 40 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:20:55', 'TTQAUTOCON', 'TREBOLES', '40', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 302, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (303, '330', 'TTQ CON 45 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:20:45', 'TTQAUTOCON', 'TREBOLES', '45', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 303, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (304, '331', 'TTQ CON 50 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:21:15', 'TTQAUTOCON', 'TREBOLES', '50', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 304, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (305, '332', 'TTQ CON 55 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:21:03', 'TTQAUTOCON', 'TREBOLES', '55', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 305, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (306, '333', 'TTQ CON 60 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:21:11', 'TTQAUTOCON', 'TREBOLES', '60', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 306, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (307, '334', 'TU TE QUEDAS 70 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '70', 'S', 'N', 0, NULL, NULL, 'N', 307, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (308, '335', 'TU TE QUEDAS 80 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '80', 'S', 'N', 0, NULL, NULL, 'N', 308, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (309, '336', 'TU TE QUEDAS 90 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '90', 'S', 'N', 0, NULL, NULL, 'N', 309, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (310, '337', 'TU TE QUEDAS 100 TRÉBOLES CON', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '28/08/2024 00:00:00', 'TTQAUTOCON', 'TREBOLES', '100', 'S', 'N', 0, NULL, NULL, 'N', 310, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (311, '338', 'TTQ CON 70 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:21:19', 'TTQAUTOCON', 'TREBOLES', '70', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 311, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (312, '339', 'TTQ CON 80 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:21:46', 'TTQAUTOCON', 'TREBOLES', '80', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 312, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (313, '340', 'TTQ CON 90 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:21:37', 'TTQAUTOCON', 'TREBOLES', '90', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 313, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (314, '341', 'TTQ CON 100 TRB NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '30/01/2026 15:22:05', 'TTQAUTOCON', 'TREBOLES', '100', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 314, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (315, '342', 'TU TE QUEDAS CONCESIONARIOS', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '25/05/2026 12:45:11', 'TTQAUTOCON', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 315, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (316, '343', 'TTQ CONCES NO CLUB MAPFRE', 'N', '1', 200, NULL, 41, NULL, 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '28/08/2024 00:00:00', '25/05/2026 12:45:19', 'TTQAUTOCON', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 316, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (317, '344', 'TU TE QUEDAS VW', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '03/10/2024 00:00:00', '25/05/2026 12:49:16', 'TTQAUTOSVW', 'TREBOLES', '0', 'S', 'N', 0, NULL, NULL, 'N', 317, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (318, '345', 'TU TE QUEDAS VW NO CLB MAPFRE', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, 'OBSERVACIONES', '03/10/2024 00:00:00', '25/05/2026 12:49:29', 'TTQAUTOSVW', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'N', 318, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (319, '346', 'TARJETA BANKINTER', 'N', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TarjetaCreditoClubMAPFRE-Bankinter-Infografia_USOEXTERNO_MAR24.pdf', '090003e8801d635c', NULL, '21/11/2024 00:00:00', '11/12/2025 18:15:18', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 319, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (320, '347', 'TARJETA BANKINTER', 'N', '2', 73, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'TarjetaCreditoClubMAPFRE-Bankinter-Infografia_USOEXTERNO_MAR24.pdf', '090003e8895ff06b', NULL, '21/11/2024 00:00:00', '16/07/2025 15:06:25', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 320, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (321, '348', 'BALIZA INTELIGENTE', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '24/02/2025 00:00:00', '27/02/2025 10:32:42', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 321, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (322, '350', 'CAMBIO DE FORMA DE PAGO', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '05/11/2025 15:46:38', NULL, NULL, NULL, 'N', 'N', 0, NULL, 'https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS018Gesvida/VJ0180007_DetallePolizaCliente.do', 'N', 322, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (323, '351', 'CESIÓN DERE./REDUCCIÓN GARAN', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:26:03', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 323, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (324, '352', 'CLUB MAPFRE PLATA', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', 'CLUB MAPFRE PLATA', '090003e8801c3fa6', NULL, '10/06/2025 00:00:00', '28/10/2025 16:02:59', NULL, NULL, NULL, 'N', 'S', 0, NULL, 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'N', 324, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (325, '353', 'CLUB MAPFRE ORO', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '28/10/2025 16:03:09', NULL, NULL, NULL, 'N', 'S', 0, NULL, 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'N', 325, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (326, '354', 'CLUB MAPFRE PLATINO', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '28/10/2025 16:03:40', NULL, NULL, NULL, 'N', 'S', 0, NULL, 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'N', 326, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (327, '355', 'DERIVAR BUNKER RETENCIÓN', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:26:54', NULL, NULL, NULL, 'N', 'N', 0, NULL, 'https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS018Gesvida/VJ0180007_DetallePolizaCliente.do', 'N', 327, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (328, '356', 'DESCUENTO POR RETENCIÓN', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'Realice un suplemento a la póliza con descuento por retención', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '03/06/2026 10:22:06', 'DESRET', NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 328, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (329, '357', 'SIN DESCUENTO POR VINCULACIÓN', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '03/06/2026 10:26:39', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 329, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (330, '358', 'CON DESCUENTO POR VINCULACIÓN', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '03/06/2026 10:30:55', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 330, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (331, '359', 'INCREMENTO DE PRIMA', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '03/11/2025 12:23:29', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 331, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (332, '360', 'INCREMENTO DE PRIMA PLATINO', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '08/10/2025 16:44:35', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 332, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (333, '361', 'PAGO TARJETA BONIFICADO 3%', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '05/11/2026 11:57:57', NULL, NULL, NULL, 'N', 'N', 0, NULL, 'https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS018Gesvida/VJ0180007_DetallePolizaCliente.do', 'N', 333, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (334, '362', 'POTENCIAL PLAN DE PAGOS', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '08/10/2025 16:45:16', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 334, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (335, '363', 'PREMIO FIDELIDAD', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:32:43', 'PREMFIDE', 'TREBOLES', '0', 'S', 'S', 0, NULL, NULL, 'N', 335, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (336, '364', 'REDUCCION DE COBERTURAS', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:29:03', NULL, NULL, NULL, 'N', 'N', 0, NULL, 'https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS018Gesvida/VJ0180007_DetallePolizaCliente.do', 'N', 336, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (337, '365', 'SERVICIO VALOR AÑADIDO', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:32:31', NULL, NULL, '0', 'S', 'S', 0, NULL, 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'N', 337, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (338, '366', 'SERVICIOS MAPFRE', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '08/10/2025 16:45:43', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 338, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (339, '367', 'TTQ VIDA CLUB MAPFRE', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:20:59', 'TTQVIDA', 'TREBOLES', '0', 'S', 'N', 0, NULL, 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'N', 339, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (340, '368', 'TTQ VIDA NO CLUB MAPFRE', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '29/05/2026 12:20:44', 'TTQVIDA', 'TREBOLES', '0', 'S', 'S', 0, NULL, 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'N', 340, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (341, '369', 'VENTAJAS DEL PRODUCTO', 'N', '3', 101, NULL, 3, 'VISUALIZAR_PDF', 'OBSERVACIONES', 'N', NULL, NULL, NULL, '10/06/2025 00:00:00', '08/10/2025 16:46:33', NULL, NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 341, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:51', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net'),
  (347, '370', 'Bajada de Prima', 'S', '1', 200, NULL, 41, 'VISUALIZAR_PDF', 'Argumento para la bajada de prima en renovación.', 'N', 'PDF Bajada de Prima', '090003e8802ab99c', 'Dado de alta por primera vez, inactivo, el 04/11', '04/11/2026', '04/11/2026 12:32:15', 'BAJAPRIM', NULL, NULL, 'N', 'N', 0, NULL, NULL, 'N', 342, 'true', 'CORE', TIMESTAMP '2026-11-17 22:42:43', TIMESTAMP '2026-11-18 07:58:12', 'JOSPENA@mapfre.net')
ON CONFLICT ("ID") DO NOTHING;
DO $$ BEGIN PERFORM setval(pg_get_serial_sequence('sca2_anulaciones.sca2_cat_tipo_argumento', 'ID'), GREATEST((SELECT max("ID") FROM sca2_anulaciones.sca2_cat_tipo_argumento), 1)); END $$;

-- sca2_cat_concepto: 17 filas (ID conservado de TEST)
INSERT INTO sca2_anulaciones.sca2_cat_concepto ("ID", "IDN_CONCEPTO_PCA", "DES_CONCEPTO_PCA", "MCA_INH", "FEC_ACTU", "ORDEN", "ACTIVO", "ORIGEN", "FECHA_ALTA", "FECHA_MODIFICACION", "USUARIO_MODIFICACION") VALUES
  (1, '0', 'PRODUCTOR', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (2, '1', 'Corredores', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (3, '2', 'Banca-seguros', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (4, '3', 'RCI', 'N', DATE '2015-10-11', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (5, '4', 'Volkswagen', 'N', DATE '2015-10-11', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (6, '5', 'Mercedes', 'N', DATE '2015-10-11', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (7, '6', 'FGA', 'N', DATE '2015-10-11', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (8, '7', 'Keeway', 'N', DATE '2015-10-11', 8, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (9, '8', 'Go insurance', 'N', DATE '2015-10-11', 9, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (10, '9', 'BPSA', 'N', DATE '2015-10-11', 10, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (11, '10', 'BBVA', 'N', DATE '2015-10-11', 11, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (12, '11', 'Acuerdos tratables SI24', 'N', DATE '2015-10-11', 12, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (13, '12', 'MAC', 'N', DATE '2015-10-11', 13, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (14, '13', 'Tipo Contrato Localizador', 'N', DATE '2015-10-11', 14, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (15, '14', 'Flotas', 'N', DATE '2015-10-11', 15, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (16, 'CAMP', 'CAMPAÑAS ARGUMENTARIOS', 'N', DATE '2018-03-18', 16, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin'),
  (17, 'URL', 'CAT URLS DINAMICAS ARGUM', 'N', DATE '2023-04-16', 17, 'true', 'CORE', TIMESTAMP '2026-10-21 10:28:54', TIMESTAMP '2026-10-21 10:52:47', 'devin')
ON CONFLICT ("ID") DO NOTHING;
DO $$ BEGIN PERFORM setval(pg_get_serial_sequence('sca2_anulaciones.sca2_cat_concepto', 'ID'), GREATEST((SELECT max("ID") FROM sca2_anulaciones.sca2_cat_concepto), 1)); END $$;

-- sca2_cat_valor_concepto: 100 filas (ID conservado de TEST); sin las filas de prueba de TEST con ID 101
INSERT INTO sca2_anulaciones.sca2_cat_valor_concepto ("ID", "IDN_CONCEPTO_PCA", "IDN_PCA", "VALOR_CONCEPTO", "DES_CONCEPTO", "MCA_INH", "FEC_ACTU", "ORDEN", "ACTIVO", "ORIGEN", "FECHA_ALTA", "FECHA_MODIFICACION", "USUARIO_MODIFICACION") VALUES
  (1, '3', '0', '10014717', '10014717', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-11-13 10:06:19', 'devin'),
  (2, '3', '1', '10014895', '10014895', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (3, '3', '2', '10014952', '10014952', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (4, '3', '3', '10016325', '10016325', 'N', DATE '2015-10-11', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (5, '3', '4', '10016396', '10016396', 'N', DATE '2015-10-11', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (6, '3', '5', '10020278', '10020278', 'N', DATE '2015-10-11', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (7, '3', '6', '10023995', '10023995', 'N', DATE '2015-10-11', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (8, '3', '7', '10025733', '10025733', 'N', DATE '2015-10-11', 8, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (9, '3', '8', '10026420', '10026420', 'N', DATE '2015-10-11', 9, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (10, '3', '9', '10029500', '10029500', 'N', DATE '2015-10-11', 10, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (11, '3', '10', '10030235', '10030235', 'N', DATE '2015-10-11', 11, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (12, '3', '11', '10030236', '10030236', 'N', DATE '2015-10-11', 12, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (13, '3', '12', '10030739', '10030739', 'N', DATE '2015-10-11', 13, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (14, '3', '13', '10018717', '10018717', 'N', DATE '2015-10-11', 14, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (15, '3', '14', '10025665', '10025665', 'N', DATE '2015-10-11', 15, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (16, '3', '15', '10029822', '10029822', 'N', DATE '2015-10-11', 16, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (17, '4', '16', '10025081', '10025081', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (18, '4', '17', '10026434', '10026434', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (19, '4', '18', '10031034', '10031034', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (20, '4', '19', '10024079', '10024079', 'N', DATE '2015-10-11', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (21, '4', '20', '35713', '35713', 'N', DATE '2015-10-11', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (22, '5', '21', '10034516', '10034516', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (23, '5', '22', '10034514', '10034514', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (24, '5', '23', '10035188', '10035188', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (25, '5', '24', '10035189', '10035189', 'N', DATE '2015-10-11', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (26, '6', '25', '10036158', '10036158', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (27, '6', '26', '10036269', '10036269', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (28, '6', '27', '10036157', '10036157', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (29, '6', '28', '10036268', '10036268', 'N', DATE '2015-10-11', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (30, '6', '29', '10037272', '10037272', 'N', DATE '2015-10-11', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (31, '7', '30', '10037271', '10037271', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (32, '8', '31', '10037259', '10037259', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (33, '9', '32', '10037120', '10037120', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (34, '10', '33', '10009787', 'BBVA GENERAL', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (35, '11', '34', '10011745', 'RGA', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (36, '11', '35', '10011761', 'RGA MAGA', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (37, '11', '36', '10013401', 'RGA AGROPECUARIA', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (38, '11', '37', '10013403', 'RGA EMPL.-CAJAS RURALES', 'N', DATE '2015-10-11', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (39, '11', '38', '1000172', 'UNICAJA CLIENTES', 'N', DATE '2015-10-11', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (40, '11', '39', '10015526', 'UNICAJA EMPLEADOS', 'N', DATE '2015-10-11', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (41, '11', '40', '10000165', 'CAJA CIRCULO', 'N', DATE '2015-10-11', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (42, '11', '41', '10000198', 'CAJA CIRCULO', 'N', DATE '2015-10-11', 8, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (43, '11', '42', '10014373', 'CAJA ESPAÃ‘A DUERO OBSV', 'N', DATE '2015-10-11', 9, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (44, '11', '43', '10009787', 'BBVA GENERAL', 'N', DATE '2015-10-11', 10, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (45, '11', '44', '10025081', 'VAG FINANCIACION 1 AÃ‘O', 'N', DATE '2015-10-11', 11, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (46, '11', '45', '10026434', 'VAG CARTERA', 'N', DATE '2015-10-11', 12, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (47, '11', '46', '10031034', '10031034', 'N', DATE '2015-10-11', 13, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (48, '11', '47', '10024079', 'VAG PLURIANUAL', 'N', DATE '2015-10-11', 14, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (49, '11', '48', '10035713', '10035713', 'N', DATE '2015-10-11', 15, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (50, '11', '49', '10014717', 'RCI RENAULT FINANCIADO', 'N', DATE '2015-10-11', 16, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (51, '11', '50', '10014895', 'RCI RENAULT REGALADO', 'N', DATE '2015-10-11', 17, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (52, '11', '51', '10014952', 'RCI DACIA REGALADO', 'N', DATE '2015-10-11', 18, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (53, '11', '52', '10016325', 'RCI NISSAN REGALADO', 'N', DATE '2015-10-11', 19, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (54, '11', '53', '10016396', 'RCI CARTERA', 'N', DATE '2015-10-11', 20, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (55, '11', '54', '10020278', 'RCI DACIA FINANCIADO', 'N', DATE '2015-10-11', 21, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (56, '11', '55', '10023995', 'RCI NISSAN FINANCIADO', 'N', DATE '2015-10-11', 22, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (57, '11', '56', '10025733', 'RCI BOX EMPRESA RENAULT', 'N', DATE '2015-10-11', 23, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (58, '11', '57', '10026420', 'RCI BOX EMPRESA NISSAN', 'N', DATE '2015-10-11', 24, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (59, '11', '58', '10029500', '10029500', 'N', DATE '2015-10-11', 25, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (60, '11', '59', '10030235', '10030235', 'N', DATE '2015-10-11', 26, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (61, '11', '60', '10030236', '10030236', 'N', DATE '2015-10-11', 27, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (62, '11', '61', '10030739', '10030739', 'N', DATE '2015-10-11', 28, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (63, '11', '62', '10018717', 'RCI PLURIANUAL FINANCIADO', 'N', DATE '2015-10-11', 29, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (64, '11', '63', '10025665', 'RCI PLURIANUAL REGALADO', 'N', DATE '2015-10-11', 30, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (65, '11', '64', '10029822', '10029822', 'N', DATE '2015-10-11', 31, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (66, '11', '65', '10026380', 'IBERICAR EMPLEADOS', 'N', DATE '2015-10-11', 32, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (67, '11', '66', '10000035', 'CORREDURIA CORTE INGLES', 'N', DATE '2015-10-11', 33, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (68, '11', '67', '10007608', 'EMPLEADOS CORTE INGLES', 'N', DATE '2015-10-11', 34, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (69, '11', '68', '10007609', 'EMPL. CORTE INGLES C/BONO', 'N', DATE '2015-10-11', 35, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (70, '11', '69', '10007611', 'CORTE INGLES CAMP. COMERC.', 'N', DATE '2015-10-11', 36, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (71, '11', '70', '10008673', 'CORTE INGLES CAMP. COMERC.', 'N', DATE '2015-10-11', 37, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (72, '11', '71', '10008674', 'EMPL. CORTE INGLES C/BONO', 'N', DATE '2015-10-11', 38, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (73, '11', '72', '10008675', 'EMPLEADOS CORTE INGLES', 'N', DATE '2015-10-11', 39, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (74, '11', '73', '10013693', 'EL CORTE INGLES', 'N', DATE '2015-10-11', 40, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (75, '11', '74', '10013694', 'EL CORTE INGLES', 'N', DATE '2015-10-11', 41, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (76, '12', '75', '0000001', 'Gama producto', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (77, '13', '0', '001', 'Detector', 'N', DATE '2026-10-13', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (78, '13', '1', '007', 'PÃ³liza ecolÃ³gica', 'N', DATE '2026-10-13', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (79, '14', '78', '20', 'Tipo acuerdo', 'N', DATE '2015-10-11', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (80, '14', '79', '33', 'Tipo acuerdo', 'N', DATE '2015-10-11', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (81, '14', '80', '35', 'Tipo acuerdo', 'N', DATE '2015-10-11', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (82, 'CAMP', '0', 'TTQAUTOS', 'Tú Te Quedas Autos', 'N', DATE '2026-10-27', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (83, 'CAMP', '1', 'TTQHOGAR', 'Tú Te Quedas Hogar', 'N', DATE '2026-10-27', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (84, 'CAMP', '2', 'PAGOTARJ', 'Pago Tarjeta Bonificado', 'N', DATE '2026-10-27', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (85, 'CAMP', '3', 'TTQAUTORCI', 'Tú Te Quedas Autos RCI', 'N', DATE '2026-10-27', 4, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (86, 'CAMP', '4', 'TTQBANKIA', 'Tú Te Quedas Bankia', 'N', DATE '2026-10-27', 5, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (87, 'CAMP', '5', 'TTQHOGBNK', 'TTQ Hogar Bankia', 'N', DATE '2026-10-27', 6, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (88, 'CAMP', '6', 'PREMAN', 'Regalo de Permanencia', 'N', DATE '2026-10-27', 7, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (89, 'CAMP', '7', 'PREMFIDE', 'Premio fidelidad', 'N', DATE '2026-10-27', 8, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (90, 'CAMP', '8', 'GRACIASMAS', 'Gracias madrid', 'N', DATE '2026-10-27', 9, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (91, 'CAMP', '9', 'RETOS', 'Tréboles del servicio RETOS', 'N', DATE '2026-10-27', 10, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (92, 'CAMP', '10', 'DEFCART', 'Defensa de Cartera', 'N', DATE '2026-10-27', 11, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (93, 'CAMP', '11', 'TTQAUTOCON', 'Tú Te Quedas Concesionarios', 'N', DATE '2026-10-27', 12, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (94, 'CAMP', '12', 'TTQAUTOSVW', 'TTQ de Volkswagen', 'N', DATE '2026-10-27', 13, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (95, 'CAMP', '13', 'TTQVIDA', 'Tú te Quedas Vida', 'N', DATE '2026-10-27', 14, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (96, 'CAMP', '14', 'DESRET', 'Descuento retención de vida', 'N', DATE '2026-10-27', 15, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (97, 'CAMP', '15', 'BAJAPRIM', 'Bajada de Prima', 'N', DATE '2026-11-04', 16, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-11-25 11:33:49', 'devin'),
  (98, 'URL', '0', 'https://webvida.pre.mapfre.net/WSS000AEjec/accesodirecto/WSS018Gesvida/VJ0180007_DetallePolizaCliente.do', 'Gesvida', 'N', DATE '2026-01-30', 1, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (99, 'URL', '1', 'https://www.clubmapfre.es/particulares/ahorro-y-treboles/tarjeta-credito-mapfre-tecuidamos/', 'Club Mapfre', 'N', DATE '2026-01-30', 2, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin'),
  (100, 'URL', '2', 'https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=', 'Aplicación Club Mapfre', 'N', DATE '2026-01-30', 3, 'true', 'CORE', TIMESTAMP '2026-10-21 10:30:54', TIMESTAMP '2026-10-27 10:46:42', 'devin')
ON CONFLICT ("ID") DO NOTHING;
DO $$ BEGIN PERFORM setval(pg_get_serial_sequence('sca2_anulaciones.sca2_cat_valor_concepto', 'ID'), GREATEST((SELECT max("ID") FROM sca2_anulaciones.sca2_cat_valor_concepto), 1)); END $$;

COMMIT;

-- =====================================================================================
-- 10. Verificación final (solo lectura)
--    Origen: recuentos de Appian TEST del 26/11/2026
-- =====================================================================================
-- Esperado: ok true · tablas_distintas [] · catalogos_distintos [] · rutinas_faltan [] ·
-- owner_distinto [] · invalidos [] · reintento_habilitado false.
WITH esperado(tabla, columnas) AS (VALUES
    ('sca2_adjunto_compraventa', 6),
    ('sca2_cat_causa', 13),
    ('sca2_cat_concepto', 11),
    ('sca2_cat_detalle', 11),
    ('sca2_cat_motivo', 12),
    ('sca2_cat_tipo_argumento', 31),
    ('sca2_cat_valor_concepto', 13),
    ('sca2_cola_reserva_prima', 11),
    ('sca2_datos_basicos_solicitud', 9),
    ('sca2_datos_basicos_solicitud_hist', 10),
    ('sca2_datos_cabecera', 53),
    ('sca2_datos_cabecera_hist', 54),
    ('sca2_datos_perfiles_pca', 6),
    ('sca2_datos_perfiles_pca_hist', 7),
    ('sca2_datos_poliza_autos', 84),
    ('sca2_datos_poliza_autos_hist', 85),
    ('sca2_datos_poliza_hogar', 90),
    ('sca2_datos_poliza_hogar_hist', 91),
    ('sca2_datos_poliza_vida', 90),
    ('sca2_datos_poliza_vida_hist', 91),
    ('sca2_datos_productor', 16),
    ('sca2_datos_productor_hist', 17),
    ('sca2_datos_solicitud', 33),
    ('sca2_datos_solicitud_hist', 34),
    ('sca2_ejecucion_argumento', 16),
    ('sca2_error', 13),
    ('sca2_error_hist', 14),
    ('sca2_llamada_servicio', 12),
    ('sca2_llamada_servicio_hist', 13),
    ('sca2_niveles_cobertura_autos', 5),
    ('sca2_niveles_cobertura_autos_hist', 6),
    ('sca2_otras_solicitudes_cabecera', 10),
    ('sca2_otras_solicitudes_cabecera_hist', 11),
    ('sca2_reintento_fin', 11),
    ('sca2_reintento_fin_config', 2),
    ('sca2_reintento_fin_veto_manual', 1),
    ('sca2_solicitud', 36),
    ('sca2_solicitud_hist', 37),
    ('sca2_tarea', 17),
    ('sca2_tarea_hist', 18),
    ('sca2_transicion', 12),
    ('sca2_transicion_hist', 13),
    ('sca2_trazabilidad_cliente', 11)
), real AS (
  SELECT table_name AS tabla, count(*)::int AS columnas FROM information_schema.columns
   WHERE table_schema = 'sca2_anulaciones' GROUP BY table_name
), catalogo(tabla, filas) AS (VALUES
    ('sca2_cat_motivo', 14),
    ('sca2_cat_detalle', 22),
    ('sca2_cat_causa', 146),
    ('sca2_cat_tipo_argumento', 342),
    ('sca2_cat_concepto', 17),
    ('sca2_cat_valor_concepto', 100)
), comprobacion AS (
  SELECT
    (SELECT coalesce(json_agg(json_build_object('tabla', coalesce(e.tabla, r.tabla), 'esperado', e.columnas, 'real', r.columnas)), '[]'::json)
       FROM esperado e FULL JOIN real r ON r.tabla = e.tabla
      WHERE e.columnas IS DISTINCT FROM r.columnas) AS tablas_distintas,
    (SELECT coalesce(json_agg(json_build_object('tabla', c.tabla, 'esperado', c.filas, 'real', n.filas)), '[]'::json)
       FROM catalogo c CROSS JOIN LATERAL (SELECT (xpath('/row/c/text()', query_to_xml(
              format('SELECT count(*) AS c FROM sca2_anulaciones.%I', c.tabla), false, true, '')))[1]::text::int AS filas) n
      WHERE n.filas < c.filas) AS catalogos_distintos,
    (SELECT coalesce(json_agg(x), '[]'::json) FROM unnest(ARRAY[
       'sca2_capturar_reintento_fin','sca2_ejecutar_reintento_fin','sca2_reservar_manual_fin',
       'sca2_pm_capturar_reintento_fin','sca2_pm_ejecutar_reintento_fin','sca2_pm_reservar_manual_fin',
       'sca2_pm_traspasar_historico']) x
      WHERE NOT EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
                         WHERE n.nspname = 'sca2_anulaciones' AND p.proname = x)) AS rutinas_faltan,
    (SELECT coalesce(json_agg(c.relname), '[]'::json) FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'sca2_anulaciones' AND c.relkind IN ('r','v','m','p','S')
        AND pg_get_userbyid(c.relowner) <> 'user_sca2_anulaciones') AS owner_distinto,
    (SELECT coalesce(json_agg(c.relname), '[]'::json) FROM pg_index i
       JOIN pg_class c ON c.oid = i.indexrelid JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'sca2_anulaciones' AND NOT i.indisvalid) AS invalidos,
    (SELECT habilitado FROM sca2_anulaciones.sca2_reintento_fin_config WHERE singleton) AS reintento_habilitado
)
SELECT json_build_object(
  'fecha', now(),
  'usuario', current_user,
  'owner_esquema', (SELECT pg_get_userbyid(nspowner) FROM pg_namespace WHERE nspname = 'sca2_anulaciones'),
  'tablas', (SELECT count(*) FROM pg_tables WHERE schemaname = 'sca2_anulaciones'),
  'columnas', (SELECT count(*) FROM information_schema.columns WHERE table_schema = 'sca2_anulaciones'),
  'indices', (SELECT count(*) FROM pg_indexes WHERE schemaname = 'sca2_anulaciones'),
  'tablas_distintas', tablas_distintas,
  'catalogos_distintos', catalogos_distintos,
  'rutinas_faltan', rutinas_faltan,
  'owner_distinto', owner_distinto,
  'invalidos', invalidos,
  'reintento_habilitado', reintento_habilitado,
  'ok', tablas_distintas::text = '[]' AND catalogos_distintos::text = '[]' AND rutinas_faltan::text = '[]'
        AND owner_distinto::text = '[]' AND invalidos::text = '[]' AND reintento_habilitado IS FALSE
) AS verificacion_final
FROM comprobacion;

-- =====================================================================================
-- Permisos para OTROS usuarios (solo si Appian conecta con un usuario distinto del owner
-- user_sca2_anulaciones; descomentar con el usuario del entorno).
-- GRANT USAGE ON SCHEMA sca2_anulaciones TO "<usuario_appian>";
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sca2_anulaciones TO "<usuario_appian>";
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sca2_anulaciones TO "<usuario_appian>";
-- =====================================================================================
