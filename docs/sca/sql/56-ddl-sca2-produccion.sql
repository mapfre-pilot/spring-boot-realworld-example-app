-- =====================================================================
-- SCA2: DDL de creación y actualización del esquema sca2_anulaciones
-- Aurora PostgreSQL / PostgreSQL >= 11. Sólo estructura; no incluye datos.
-- Extracción UTC: 2026-11-03T10:37:37.924844+00:00
-- Origen: Appian TEST https://mapfrespain-test.appiancloud.com
-- Aplicación SCA2: _a-0000f069-4f37-8000-9cc8-011c48011c48_20050128
-- Data source: _a-0000f069-4f37-8000-9cc8-011c48011c48_20050863 (SCA2 DataBase AWS)
-- Alcance: 22 tablas de los record types SCA2, 588 columnas.
--
-- Se puede ejecutar en cualquier entorno y relanzar las veces que haga falta:
--   * Base vacía: crea el esquema, las tablas, secuencias, índices y comentarios.
--   * Esquema ya existente (versión anterior): crea las tablas que falten,
--     añade las columnas que falten, amplía tipos cuando es seguro (más longitud
--     en VARCHAR, VARCHAR -> TEXT, SMALLINT -> INTEGER -> BIGINT), añade
--     PK/UNIQUE/secuencias/defaults/índices que falten y refresca comentarios.
--   * Nunca borra tablas, columnas ni datos y nunca reduce un tipo. Si encuentra
--     un tipo que no puede cambiar con seguridad o columnas que SCA2 ya no usa,
--     lo avisa con NOTICE/WARNING para que lo revise el DBA.
--
-- Todo va en una transacción: si algo falla, no se aplica nada.
-- Columnas entrecomilladas en MAYÚSCULAS: es el nombre físico que usa Appian.
-- Se excluye PRBRV_EXPEDIENTE_E21CA9B6 (tabla del esquema sin record type SCA2).
-- Owner y GRANTs: ver bloque final (comentado).
-- =====================================================================
BEGIN;
CREATE SCHEMA IF NOT EXISTS sca2_anulaciones;
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
  "POLIZA_FECHAULTIMOSINIESTRO" VARCHAR(255),
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
ALTER TABLE sca2_datos_cabecera ADD COLUMN IF NOT EXISTS "POLIZA_FECHAULTIMOSINIESTRO" VARCHAR(255);
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
  "FECIMPRESION" VARCHAR(255),
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
ALTER TABLE sca2_datos_solicitud ADD COLUMN IF NOT EXISTS "FECIMPRESION" VARCHAR(255);
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
  "CLAVE_IDEMPOTENCIA" VARCHAR(120) UNIQUE,
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
ALTER TABLE sca2_transicion ADD COLUMN IF NOT EXISTS "CLAVE_IDEMPOTENCIA" VARCHAR(120);
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
    ('sca2_datos_cabecera', 'POLIZA_FECHAULTIMOSINIESTRO', 'character varying(255)'),
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
    ('sca2_datos_solicitud', 'FECIMPRESION', 'character varying(255)'),
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
    ('sca2_transicion', 'CLAVE_IDEMPOTENCIA', 'character varying(120)'),
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
CREATE INDEX IF NOT EXISTS ix_sca2_cat_tipo_argumento_cod_estado ON sca2_cat_tipo_argumento ("COD_ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_basicos_solicitud_id_solicitud ON sca2_datos_basicos_solicitud ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_cabecera_id_solicitud ON sca2_datos_cabecera ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_perfiles_pca_id_solicitud ON sca2_datos_perfiles_pca ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_autos_id_solicitud ON sca2_datos_poliza_autos ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_autos_estadopoliza ON sca2_datos_poliza_autos ("ESTADOPOLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_autos_estado ON sca2_datos_poliza_autos ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_hogar_id_solicitud ON sca2_datos_poliza_hogar ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_hogar_estadopoliza ON sca2_datos_poliza_hogar ("ESTADOPOLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_hogar_estado ON sca2_datos_poliza_hogar ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_vida_id_solicitud ON sca2_datos_poliza_vida ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_poliza_vida_estadopoliza ON sca2_datos_poliza_vida ("ESTADOPOLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_productor_id_solicitud ON sca2_datos_productor ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_solicitud_id_solicitud ON sca2_datos_solicitud ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_datos_solicitud_estadosolicitud ON sca2_datos_solicitud ("ESTADOSOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_error_id_solicitud ON sca2_error ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_error_estado ON sca2_error ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_llamada_servicio_id_solicitud ON sca2_llamada_servicio ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_niveles_cobertura_autos_id_solicitud ON sca2_niveles_cobertura_autos ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_otras_solicitudes_cabecera_id_solicitud ON sca2_otras_solicitudes_cabecera ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_num_poliza ON sca2_solicitud ("NUM_POLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_estado_solicitud ON sca2_solicitud ("ESTADO_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_solicitud_estado_tarea ON sca2_solicitud ("ESTADO_TAREA");
CREATE INDEX IF NOT EXISTS ix_sca2_tarea_id_solicitud ON sca2_tarea ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_tarea_num_poliza ON sca2_tarea ("NUM_POLIZA");
CREATE INDEX IF NOT EXISTS ix_sca2_tarea_estado ON sca2_tarea ("ESTADO");
CREATE INDEX IF NOT EXISTS ix_sca2_transicion_id_solicitud ON sca2_transicion ("ID_SOLICITUD");
CREATE INDEX IF NOT EXISTS ix_sca2_transicion_estado_origen ON sca2_transicion ("ESTADO_ORIGEN");
CREATE INDEX IF NOT EXISTS ix_sca2_transicion_estado_destino ON sca2_transicion ("ESTADO_DESTINO");
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
    EXECUTE 'CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_tipo_argumento ON sca2_anulaciones.sca2_cat_tipo_argumento ("COD_TP_ARG")';
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'No se pudo crear ux_sca2_cat_tipo_argumento: % (revisar duplicados)', SQLERRM;
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

-- Claves ajenas opcionales (MANY_TO_ONE internas). Revisar huérfanos antes de activar.
-- ALTER TABLE sca2_llamada_servicio ADD CONSTRAINT fk_sca2_llamada_servicio_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");
-- ALTER TABLE sca2_datos_solicitud ADD CONSTRAINT fk_sca2_datos_solicitud_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");
-- ALTER TABLE sca2_otras_solicitudes_cabecera ADD CONSTRAINT fk_sca2_otras_solicitudes_cabecera_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");
-- ALTER TABLE sca2_niveles_cobertura_autos ADD CONSTRAINT fk_sca2_niveles_cobertura_autos_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");
-- ALTER TABLE sca2_transicion ADD CONSTRAINT fk_sca2_transicion_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");
-- ALTER TABLE sca2_error ADD CONSTRAINT fk_sca2_error_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");
-- ALTER TABLE sca2_tarea ADD CONSTRAINT fk_sca2_tarea_sca2_solicitud FOREIGN KEY ("ID_SOLICITUD") REFERENCES sca2_solicitud ("ID_SOLICITUD");

-- Owner y permisos (opcional; descomentar en el entorno que corresponda).
-- El bloque completo de cambio de owner está en 56-owner-sca2.sql.
-- GRANT USAGE ON SCHEMA sca2_anulaciones TO "<usuario_appian>";
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sca2_anulaciones TO "<usuario_appian>";
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sca2_anulaciones TO "<usuario_appian>";
COMMIT;
