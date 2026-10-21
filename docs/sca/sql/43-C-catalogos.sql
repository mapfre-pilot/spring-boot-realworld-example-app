-- 43-C · Catálogos CORE en Aurora PostgreSQL (BD de SCA2, esquema sca2_anulaciones) — fase 1, sesión C.
-- ESTADO: las 6 tablas se crearon desde Appian TEST (record type → Crear tabla, data source 'SCA2 DataBase AWS') el 21-10-2026;
--         este script es la referencia as-built para otros entornos (PRE/PRO) y para el DBA (ACTIVO lo crea Appian como BIT/boolean).
-- Pendiente de DBA (Appian no los crea): los índices únicos ux_* del final (la unicidad la garantiza mientras tanto la carga y el mantenimiento).
-- Convención: tablas sca2_cat_*, columnas UPPER_SNAKE_CASE (igual que el resto de tablas Appian del esquema), PK ID serial.
SET search_path TO sca2_anulaciones;

-- SCA2 Cat Motivo: Catálogo CORE de motivos de anulación (IGenerarContraAnul.consultarMotivo) por línea de negocio, perfil y subperfil. Copia en Aurora; el maestro sigue siendo CORE.
CREATE TABLE IF NOT EXISTS sca2_cat_motivo (
  ID SERIAL PRIMARY KEY,
  COD_LINEA_NEGOCIO INTEGER,
  COD_PERFIL VARCHAR(30),
  COD_SUB_PERFIL VARCHAR(30),
  COD_MOTIVO VARCHAR(5),
  DESCRIPCION VARCHAR(100),
  ORDEN INTEGER,
  ACTIVO BOOLEAN DEFAULT TRUE,
  ORIGEN VARCHAR(10),
  FECHA_ALTA TIMESTAMP,
  FECHA_MODIFICACION TIMESTAMP,
  USUARIO_MODIFICACION VARCHAR(100)
);
COMMENT ON COLUMN sca2_cat_motivo.COD_LINEA_NEGOCIO IS 'Línea de negocio (codsector TRON / LINEA_NEGOCIO wAutemis): 1 Autos, 2 Diversos, 3 Vida';
COMMENT ON COLUMN sca2_cat_motivo.COD_PERFIL IS 'Perfil PCA del usuario (infoUsuarioDTO.codPerfil) para el que CORE devuelve el motivo';
COMMENT ON COLUMN sca2_cat_motivo.COD_SUB_PERFIL IS 'Subperfil PCA del usuario (infoUsuarioDTO.codSubPerfil)';
COMMENT ON COLUMN sca2_cat_motivo.COD_MOTIVO IS 'Código del motivo en CORE (tipoElementoBasicoDTO.codigo)';
COMMENT ON COLUMN sca2_cat_motivo.DESCRIPCION IS 'Descripción del motivo (tipoElementoBasicoDTO.descripcion)';
COMMENT ON COLUMN sca2_cat_motivo.ORDEN IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_motivo.ACTIVO IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_motivo.ORIGEN IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_motivo.FECHA_ALTA IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_motivo.FECHA_MODIFICACION IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_motivo.USUARIO_MODIFICACION IS 'Usuario Appian que hizo la última modificación';

-- SCA2 Cat Detalle: Catálogo CORE de detalles de anulación (IGenerarContraAnul.consultarDetalle) por línea de negocio y motivo. Copia en Aurora; el maestro sigue siendo CORE.
CREATE TABLE IF NOT EXISTS sca2_cat_detalle (
  ID SERIAL PRIMARY KEY,
  COD_LINEA_NEGOCIO INTEGER,
  COD_MOTIVO VARCHAR(5),
  COD_DETALLE VARCHAR(5),
  DESCRIPCION VARCHAR(100),
  ORDEN INTEGER,
  ACTIVO BOOLEAN DEFAULT TRUE,
  ORIGEN VARCHAR(10),
  FECHA_ALTA TIMESTAMP,
  FECHA_MODIFICACION TIMESTAMP,
  USUARIO_MODIFICACION VARCHAR(100)
);
COMMENT ON COLUMN sca2_cat_detalle.COD_LINEA_NEGOCIO IS 'Línea de negocio';
COMMENT ON COLUMN sca2_cat_detalle.COD_MOTIVO IS 'Código del motivo padre';
COMMENT ON COLUMN sca2_cat_detalle.COD_DETALLE IS 'Código del detalle en CORE';
COMMENT ON COLUMN sca2_cat_detalle.DESCRIPCION IS 'Descripción del detalle';
COMMENT ON COLUMN sca2_cat_detalle.ORDEN IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_detalle.ACTIVO IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_detalle.ORIGEN IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_detalle.FECHA_ALTA IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_detalle.FECHA_MODIFICACION IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_detalle.USUARIO_MODIFICACION IS 'Usuario Appian que hizo la última modificación';

-- SCA2 Cat Causa: Catálogo CORE de causas de anulación (IGenerarContraAnul.consultarCausa) por línea de negocio, motivo, detalle y perfil. Copia en Aurora; el maestro sigue siendo CORE.
CREATE TABLE IF NOT EXISTS sca2_cat_causa (
  ID SERIAL PRIMARY KEY,
  COD_LINEA_NEGOCIO INTEGER,
  COD_MOTIVO VARCHAR(5),
  COD_DETALLE VARCHAR(5),
  COD_PERFIL VARCHAR(30),
  COD_CAUSA VARCHAR(5),
  DESCRIPCION VARCHAR(100),
  ORDEN INTEGER,
  ACTIVO BOOLEAN DEFAULT TRUE,
  ORIGEN VARCHAR(10),
  FECHA_ALTA TIMESTAMP,
  FECHA_MODIFICACION TIMESTAMP,
  USUARIO_MODIFICACION VARCHAR(100)
);
COMMENT ON COLUMN sca2_cat_causa.COD_LINEA_NEGOCIO IS 'Línea de negocio';
COMMENT ON COLUMN sca2_cat_causa.COD_MOTIVO IS 'Código del motivo';
COMMENT ON COLUMN sca2_cat_causa.COD_DETALLE IS 'Código del detalle';
COMMENT ON COLUMN sca2_cat_causa.COD_PERFIL IS 'Perfil PCA (listadoCausaAnulDTO.codPerfil) para el que CORE devuelve la causa';
COMMENT ON COLUMN sca2_cat_causa.COD_CAUSA IS 'Código de la causa en CORE';
COMMENT ON COLUMN sca2_cat_causa.DESCRIPCION IS 'Descripción de la causa';
COMMENT ON COLUMN sca2_cat_causa.ORDEN IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_causa.ACTIVO IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_causa.ORIGEN IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_causa.FECHA_ALTA IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_causa.FECHA_MODIFICACION IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_causa.USUARIO_MODIFICACION IS 'Usuario Appian que hizo la última modificación';

-- SCA2 Cat Tipo Argumento: Catálogo CORE de tipos de argumento de contra anulación (IGestionarArgumentosPCA.consultarTipoArg, CDT detalleTpArgDTO). Copia en Aurora; el maestro sigue siendo CORE.
CREATE TABLE IF NOT EXISTS sca2_cat_tipo_argumento (
  ID SERIAL PRIMARY KEY,
  COD_TP_ARG VARCHAR(5),
  DESC_ARG VARCHAR(100),
  COD_ESTADO VARCHAR(1),
  ID_LINEA_NEGOCIO VARCHAR(2),
  ID_RAMO INTEGER,
  COD_COMPANIA INTEGER,
  COD_COMPANIA_ARG INTEGER,
  APLI_ARGUMENTO VARCHAR(30),
  INSTRUCCION VARCHAR(255),
  MCA_FINALIZADO VARCHAR(1),
  NOMBRE_DOC VARCHAR(100),
  NUM_DOC VARCHAR(30),
  OBSERVACIONES VARCHAR(255),
  FEC_VIGENCIA VARCHAR(19),
  FEC_MODIFICADO VARCHAR(19),
  COD_ID_CAMPANA VARCHAR(20),
  COD_TIP_BON VARCHAR(10),
  NUM_TIP_BON VARCHAR(5),
  REGATEABLE VARCHAR(1),
  MCA_TE_CUIDAMOS VARCHAR(1),
  NUM_DIAS_SGO INTEGER,
  COD_TAREA_SGO VARCHAR(20),
  TXT_URL_ARG VARCHAR(255),
  MCA_TREB_CALC VARCHAR(1),
  ORDEN INTEGER,
  ACTIVO BOOLEAN DEFAULT TRUE,
  ORIGEN VARCHAR(10),
  FECHA_ALTA TIMESTAMP,
  FECHA_MODIFICACION TIMESTAMP,
  USUARIO_MODIFICACION VARCHAR(100)
);
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_TP_ARG IS 'Código del tipo de argumento (clave CORE)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.DESC_ARG IS 'Descripción del argumento';
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_ESTADO IS 'Estado S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento.ID_LINEA_NEGOCIO IS 'Línea de negocio 1/2/3';
COMMENT ON COLUMN sca2_cat_tipo_argumento.ID_RAMO IS 'Ramo (200 Autos, 73 Diversos, 101 Vida)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_COMPANIA IS 'Compañía (vacío en CORE)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_COMPANIA_ARG IS 'Compañía del argumento (41, 1, 3)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.APLI_ARGUMENTO IS 'Aplicación (VISUALIZAR_PDF, WAUTEMIS, TE_CUIDAMOS, …)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.INSTRUCCION IS 'Instrucción';
COMMENT ON COLUMN sca2_cat_tipo_argumento.MCA_FINALIZADO IS 'Marca finalizado S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento.NOMBRE_DOC IS 'Nombre del documento';
COMMENT ON COLUMN sca2_cat_tipo_argumento.NUM_DOC IS 'Identificador Documentum';
COMMENT ON COLUMN sca2_cat_tipo_argumento.OBSERVACIONES IS 'Observaciones';
COMMENT ON COLUMN sca2_cat_tipo_argumento.FEC_VIGENCIA IS 'Fecha de vigencia tal como la devuelve CORE (dd/MM/yyyy HH:mm:ss)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.FEC_MODIFICADO IS 'Fecha de modificación tal como la devuelve CORE (dd/MM/yyyy HH:mm:ss)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_ID_CAMPANA IS 'Campaña (valor del concepto CAMP)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_TIP_BON IS 'Tipo de bonificación (TREBOLES, EUROS)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.NUM_TIP_BON IS 'Importe/número de la bonificación';
COMMENT ON COLUMN sca2_cat_tipo_argumento.REGATEABLE IS 'Regateable S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento.MCA_TE_CUIDAMOS IS 'Marca Te Cuidamos S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento.NUM_DIAS_SGO IS 'Días SGO';
COMMENT ON COLUMN sca2_cat_tipo_argumento.COD_TAREA_SGO IS 'Tarea SGO';
COMMENT ON COLUMN sca2_cat_tipo_argumento.TXT_URL_ARG IS 'URL del argumento';
COMMENT ON COLUMN sca2_cat_tipo_argumento.MCA_TREB_CALC IS 'Marca tréboles calculados S/N';
COMMENT ON COLUMN sca2_cat_tipo_argumento.ORDEN IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.ACTIVO IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_tipo_argumento.ORIGEN IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_tipo_argumento.FECHA_ALTA IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_tipo_argumento.FECHA_MODIFICACION IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_tipo_argumento.USUARIO_MODIFICACION IS 'Usuario Appian que hizo la última modificación';

-- SCA2 Cat Concepto: Catálogo CORE de conceptos PCA (IGestionarConceptosPCA.consultarConcepto, tipoBusqueda 0: cabecera conceptoDTO). Copia en Aurora; el maestro sigue siendo CORE.
CREATE TABLE IF NOT EXISTS sca2_cat_concepto (
  ID SERIAL PRIMARY KEY,
  IDN_CONCEPTO_PCA VARCHAR(10),
  DES_CONCEPTO_PCA VARCHAR(50),
  MCA_INH VARCHAR(1),
  FEC_ACTU DATE,
  ORDEN INTEGER,
  ACTIVO BOOLEAN DEFAULT TRUE,
  ORIGEN VARCHAR(10),
  FECHA_ALTA TIMESTAMP,
  FECHA_MODIFICACION TIMESTAMP,
  USUARIO_MODIFICACION VARCHAR(100)
);
COMMENT ON COLUMN sca2_cat_concepto.IDN_CONCEPTO_PCA IS 'Identificador del concepto en CORE';
COMMENT ON COLUMN sca2_cat_concepto.DES_CONCEPTO_PCA IS 'Descripción del concepto';
COMMENT ON COLUMN sca2_cat_concepto.MCA_INH IS 'Marca inhabilitado S/N';
COMMENT ON COLUMN sca2_cat_concepto.FEC_ACTU IS 'Fecha de actualización en CORE';
COMMENT ON COLUMN sca2_cat_concepto.ORDEN IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_concepto.ACTIVO IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_concepto.ORIGEN IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_concepto.FECHA_ALTA IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_concepto.FECHA_MODIFICACION IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_concepto.USUARIO_MODIFICACION IS 'Usuario Appian que hizo la última modificación';

-- SCA2 Cat Valor Concepto: Valores de cada concepto PCA (consultarConcepto tipoBusqueda 1: valorConceptoDTO). Copia en Aurora; el maestro sigue siendo CORE.
CREATE TABLE IF NOT EXISTS sca2_cat_valor_concepto (
  ID SERIAL PRIMARY KEY,
  IDN_CONCEPTO_PCA VARCHAR(10),
  IDN_PCA VARCHAR(5),
  VALOR_CONCEPTO VARCHAR(255),
  DES_CONCEPTO VARCHAR(100),
  MCA_INH VARCHAR(1),
  FEC_ACTU DATE,
  ORDEN INTEGER,
  ACTIVO BOOLEAN DEFAULT TRUE,
  ORIGEN VARCHAR(10),
  FECHA_ALTA TIMESTAMP,
  FECHA_MODIFICACION TIMESTAMP,
  USUARIO_MODIFICACION VARCHAR(100)
);
COMMENT ON COLUMN sca2_cat_valor_concepto.IDN_CONCEPTO_PCA IS 'Identificador del concepto padre';
COMMENT ON COLUMN sca2_cat_valor_concepto.IDN_PCA IS 'Identificador del valor dentro del concepto';
COMMENT ON COLUMN sca2_cat_valor_concepto.VALOR_CONCEPTO IS 'Valor';
COMMENT ON COLUMN sca2_cat_valor_concepto.DES_CONCEPTO IS 'Descripción del valor';
COMMENT ON COLUMN sca2_cat_valor_concepto.MCA_INH IS 'Marca inhabilitado S/N';
COMMENT ON COLUMN sca2_cat_valor_concepto.FEC_ACTU IS 'Fecha de actualización en CORE';
COMMENT ON COLUMN sca2_cat_valor_concepto.ORDEN IS 'Posición en la respuesta del CORE (orden de presentación)';
COMMENT ON COLUMN sca2_cat_valor_concepto.ACTIVO IS 'Baja lógica: false = no se devuelve a las pantallas';
COMMENT ON COLUMN sca2_cat_valor_concepto.ORIGEN IS 'CORE (carga inicial) o MANUAL (mantenimiento)';
COMMENT ON COLUMN sca2_cat_valor_concepto.FECHA_ALTA IS 'Fecha de alta de la fila';
COMMENT ON COLUMN sca2_cat_valor_concepto.FECHA_MODIFICACION IS 'Última modificación';
COMMENT ON COLUMN sca2_cat_valor_concepto.USUARIO_MODIFICACION IS 'Usuario Appian que hizo la última modificación';

-- Índices únicos (clave natural CORE). NO creados por Appian: ejecutar por el DBA.
CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_motivo ON sca2_cat_motivo (COD_LINEA_NEGOCIO, COD_PERFIL, COD_SUB_PERFIL, COD_MOTIVO);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_detalle ON sca2_cat_detalle (COD_LINEA_NEGOCIO, COD_MOTIVO, COD_DETALLE);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_causa ON sca2_cat_causa (COD_LINEA_NEGOCIO, COD_MOTIVO, COD_DETALLE, COD_PERFIL, COD_CAUSA);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_tipo_argumento ON sca2_cat_tipo_argumento (COD_TP_ARG);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_concepto ON sca2_cat_concepto (IDN_CONCEPTO_PCA);
CREATE UNIQUE INDEX IF NOT EXISTS ux_sca2_cat_valor_concepto ON sca2_cat_valor_concepto (IDN_CONCEPTO_PCA, IDN_PCA);
