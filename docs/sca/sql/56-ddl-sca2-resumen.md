# SCA2 — inventario DDL

Extracción UTC: 2026-10-27T09:08:18.527112+00:00. Sólo GET en Appian TEST.

| Tabla | Record type | Nº columnas | PK | Unique | Filas en TEST |
|---|---|---:|---|---|---:|
| PRBRV_EXPEDIENTE_E21CA9B6 | SIN RT SCA2 — excluida | 3 | ID | ID | N/D (sin RT SCA2) |
| sca2_cat_causa | SCA2 Cat Causa | 13 | ID | ID | 146 |
| sca2_cat_concepto | SCA2 Cat Concepto | 11 | ID | ID | 17 |
| sca2_cat_detalle | SCA2 Cat Detalle | 11 | ID | ID | 22 |
| sca2_cat_motivo | SCA2 Cat Motivo | 12 | ID | ID | 14 |
| sca2_cat_tipo_argumento | SCA2 Cat Tipo Argumento | 31 | ID | ID | 343 |
| sca2_cat_valor_concepto | SCA2 Cat Valor Concepto | 13 | ID | ID | 100 |
| sca2_datos_basicos_solicitud | SCA2 Datos Basicos Solicitud | 9 | ID | ID | 305 |
| sca2_datos_cabecera | SCA2 Datos Cabecera | 53 | ID | ID | 368 |
| sca2_datos_perfiles_pca | SCA2 Datos Perfiles Pca | 6 | ID | ID | 305 |
| sca2_datos_poliza_autos | SCA2 Datos Poliza Autos | 84 | ID | ID | 297 |
| sca2_datos_poliza_hogar | SCA2 Datos Poliza Hogar | 90 | ID | ID | 8 |
| sca2_datos_poliza_vida | SCA2 Datos Poliza Vida | 90 | ID | ID | 0 |
| sca2_datos_productor | SCA2 Datos Productor | 16 | ID | ID | 305 |
| sca2_datos_solicitud | SCA2 Datos Solicitud | 33 | ID | ID | 305 |
| sca2_error | SCA2 Error | 13 | ID | ID | 74 |
| sca2_niveles_cobertura_autos | SCA2 Niveles Cobertura Autos | 5 | ID | ID | 305 |
| sca2_otras_solicitudes_cabecera | SCA2 Otras Solicitudes Cabecera | 10 | ID | ID | 305 |
| sca2_solicitud | SCA2 Solicitud | 36 | ID | ID, ID_SOLICITUD | 311 |
| sca2_tarea | SCA2 Tarea | 17 | ID | ID | 559 |
| sca2_transicion | SCA2 Transicion | 12 | ID | ID, CLAVE_IDEMPOTENCIA | 2006 |
| sca2_trazabilidad_cliente | SCA2 Trazabilidad Cliente | 11 | ID | ID | 590 |

## Discrepancias BD vs RT (literales LCP)

142 diferencias de metadatos. BIT/BOOLEAN y TIMESTAMP/DATETIME son alias JDBC/Appian, no necesariamente desajustes físicos. DOUBLE/DECIMAL y longitudes distintas se mantienen según BD.

- sca2_cat_causa.COD_MOTIVO: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_causa.COD_DETALLE: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_causa.COD_PERFIL: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_cat_causa.COD_CAUSA: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_causa.DESCRIPCION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_causa.ACTIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_cat_causa.ORIGEN: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_causa.FECHA_ALTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_causa.FECHA_MODIFICACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_causa.USUARIO_MODIFICACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_concepto.IDN_CONCEPTO_PCA: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_concepto.DES_CONCEPTO_PCA: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_cat_concepto.MCA_INH: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_concepto.ACTIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_cat_concepto.ORIGEN: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_concepto.FECHA_ALTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_concepto.FECHA_MODIFICACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_concepto.USUARIO_MODIFICACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_detalle.COD_MOTIVO: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_detalle.COD_DETALLE: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_detalle.DESCRIPCION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_detalle.ACTIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_cat_detalle.ORIGEN: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_detalle.FECHA_ALTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_detalle.FECHA_MODIFICACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_detalle.USUARIO_MODIFICACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_motivo.COD_PERFIL: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_cat_motivo.COD_SUB_PERFIL: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_cat_motivo.COD_MOTIVO: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_motivo.DESCRIPCION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_motivo.ACTIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_cat_motivo.ORIGEN: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_motivo.FECHA_ALTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_motivo.FECHA_MODIFICACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_motivo.USUARIO_MODIFICACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.COD_TP_ARG: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.DESC_ARG: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.COD_ESTADO: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.ID_LINEA_NEGOCIO: sourceFieldType: BD=VARCHAR(2), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.APLI_ARGUMENTO: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.MCA_FINALIZADO: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.NOMBRE_DOC: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.NUM_DOC: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.FEC_VIGENCIA: sourceFieldType: BD=VARCHAR(19), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.FEC_MODIFICADO: sourceFieldType: BD=VARCHAR(19), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.COD_ID_CAMPANA: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.COD_TIP_BON: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.NUM_TIP_BON: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.REGATEABLE: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.MCA_TE_CUIDAMOS: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.COD_TAREA_SGO: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.MCA_TREB_CALC: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.ACTIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_cat_tipo_argumento.ORIGEN: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_tipo_argumento.FECHA_ALTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_tipo_argumento.FECHA_MODIFICACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_tipo_argumento.USUARIO_MODIFICACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_valor_concepto.IDN_CONCEPTO_PCA: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_valor_concepto.IDN_PCA: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_cat_valor_concepto.DES_CONCEPTO: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_cat_valor_concepto.MCA_INH: sourceFieldType: BD=VARCHAR(1), RT=VARCHAR(255)
- sca2_cat_valor_concepto.ACTIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_cat_valor_concepto.ORIGEN: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_cat_valor_concepto.FECHA_ALTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_valor_concepto.FECHA_MODIFICACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_cat_valor_concepto.USUARIO_MODIFICACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_datos_basicos_solicitud.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_cabecera.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_cabecera.FECHA_CACHE: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_datos_cabecera.VALIDA_HASTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_datos_cabecera.ORIGEN_CACHE: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_cabecera.TIPO_POLIZA: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_datos_cabecera.CLIENTE_CODINT: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_datos_perfiles_pca.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_poliza_autos.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_poliza_hogar.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_poliza_vida.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_productor.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_productor.ANULAEXPERTOS: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_datos_productor.ANULATECNICOS: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_datos_solicitud.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_datos_solicitud.RSVPRIMA: sourceFieldType: BD=DOUBLE, RT=DECIMAL
- sca2_datos_solicitud.MCARSVPRIMA: sourceFieldType: BD=VARCHAR(5), RT=VARCHAR(255)
- sca2_datos_solicitud.FECHA_RESP_CONTACTO: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_error.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_error.COMANDO: sourceFieldType: BD=VARCHAR(60), RT=VARCHAR(255)
- sca2_error.NODO: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_error.CODIGO: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_error.PAYLOAD: sourceFieldType: BD=VARCHAR(2147483647), RT=LONGVARCHAR(65535)
- sca2_error.PROXIMO_INTENTO: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_error.ESTADO: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_error.FECHA_CREACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_error.FECHA_RESOLUCION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_niveles_cobertura_autos.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_otras_solicitudes_cabecera.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_solicitud.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_solicitud.NUM_POLIZA: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_solicitud.ESTADO_SOLICITUD: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_solicitud.INTERFAZ_ACTIVA: sourceFieldType: BD=VARCHAR(60), RT=VARCHAR(255)
- sca2_solicitud.PROCESO_ACTIVO: sourceFieldType: BD=VARCHAR(60), RT=VARCHAR(255)
- sca2_solicitud.ESTADO_TAREA: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_solicitud.NODO_RELANZAR: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_solicitud.CADUCIDAD_TAREA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_solicitud.FEC_INICIO_NIVEL: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_solicitud.MECANIZACION_REALIZADA: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_solicitud.TAREA_CAPTURADA: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_solicitud.ARGUMENTO_POSITIVO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_solicitud.IS_POLIZA_PRRA: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_solicitud.DUE_ENVIADO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_solicitud.GRUPO_ASIGNACION: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_solicitud.CANAL: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_solicitud.IDIOMA: sourceFieldType: BD=VARCHAR(10), RT=VARCHAR(255)
- sca2_solicitud.ID_NEGOCIO: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_solicitud.ROL: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_solicitud.USUARIO: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_solicitud.ORIGEN_POLIZA: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_solicitud.LINEA_NEGOCIO: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_solicitud.BLOQUEADO_POR: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_solicitud.BLOQUEADO_HASTA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_solicitud.CREATED_AT: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_solicitud.MODIFIED_AT: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_tarea.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_tarea.NUM_POLIZA: sourceFieldType: BD=VARCHAR(30), RT=VARCHAR(255)
- sca2_tarea.NOMBRE_TAREA: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_tarea.TIPO: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_tarea.ESTADO: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_tarea.PROCESO: sourceFieldType: BD=VARCHAR(60), RT=VARCHAR(255)
- sca2_tarea.GRUPO: sourceFieldType: BD=VARCHAR(100), RT=VARCHAR(255)
- sca2_tarea.FECHA_CREACION: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_tarea.FECHA_CADUCIDAD: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_tarea.FECHA_CAPTURA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_tarea.FECHA_CIERRE: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_tarea.DUE_ENVIADO: sourceFieldType: BD=BIT, RT=BOOLEAN
- sca2_tarea.TOKEN_TAREA: sourceFieldType: BD=VARCHAR(64), RT=VARCHAR(255)
- sca2_transicion.ID_SOLICITUD: sourceFieldType: BD=VARCHAR(50), RT=VARCHAR(255)
- sca2_transicion.COMANDO: sourceFieldType: BD=VARCHAR(60), RT=VARCHAR(255)
- sca2_transicion.ESTADO_ORIGEN: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_transicion.ESTADO_DESTINO: sourceFieldType: BD=VARCHAR(40), RT=VARCHAR(255)
- sca2_transicion.CLAVE_IDEMPOTENCIA: sourceFieldType: BD=VARCHAR(120), RT=VARCHAR(255)
- sca2_transicion.RESULTADO: sourceFieldType: BD=VARCHAR(20), RT=VARCHAR(255)
- sca2_transicion.FECHA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME
- sca2_trazabilidad_cliente.FECHA: sourceFieldType: BD=TIMESTAMP, RT=DATETIME

## Alcance y limitaciones

- Tablas sin RT SCA2: PRBRV_EXPEDIENTE_E21CA9B6
- RT sin tabla: ninguno
- PRBRV_EXPEDIENTE_E21CA9B6 no está vinculada a los 21 RT SCA2: excluida del DDL; pertenencia funcional no verificada.
- Filas: X-Total-Count de GET /record-types/{uuid}/data?limit=1, Accept: text/csv; no se guardan filas ni datos personales. No es COUNT directo de BD y puede depender de seguridad/sincronización.
- Defaults/identidad/nulabilidad/checks/índices físicos no expuestos. SERIAL es decisión de destino; catálogos reutilizan documentación as-built 43-C. VARCHAR(2147483647) se normaliza a TEXT; BIT a BOOLEAN y DOUBLE a DOUBLE PRECISION.
- Las 6 claves naturales ux_* y los índices ix_* son recomendaciones de destino, no unicidad observada por LCP. Las FKs y GRANTs quedan comentados.

## Verificación PostgreSQL 16 local

```text
Ejecución 1: exit=0; tablas=21; tablas nuevas=21; objetos existentes omitidos=0; errores=0; COMMIT=True
Ejecución 2: exit=0; tablas=21; tablas nuevas=0; objetos existentes omitidos=56; errores=0; COMMIT=True
sca2_cat_causa: 13 columnas; diferencias=0
sca2_cat_concepto: 11 columnas; diferencias=0
sca2_cat_detalle: 11 columnas; diferencias=0
sca2_cat_motivo: 12 columnas; diferencias=0
sca2_cat_tipo_argumento: 31 columnas; diferencias=0
sca2_cat_valor_concepto: 13 columnas; diferencias=0
sca2_datos_basicos_solicitud: 9 columnas; diferencias=0
sca2_datos_cabecera: 53 columnas; diferencias=0
sca2_datos_perfiles_pca: 6 columnas; diferencias=0
sca2_datos_poliza_autos: 84 columnas; diferencias=0
sca2_datos_poliza_hogar: 90 columnas; diferencias=0
sca2_datos_poliza_vida: 90 columnas; diferencias=0
sca2_datos_productor: 16 columnas; diferencias=0
sca2_datos_solicitud: 33 columnas; diferencias=0
sca2_error: 13 columnas; diferencias=0
sca2_niveles_cobertura_autos: 5 columnas; diferencias=0
sca2_otras_solicitudes_cabecera: 10 columnas; diferencias=0
sca2_solicitud: 36 columnas; diferencias=0
sca2_tarea: 17 columnas; diferencias=0
sca2_transicion: 12 columnas; diferencias=0
sca2_trazabilidad_cliente: 11 columnas; diferencias=0
Comparación nombres exactos y tipos normalizados JDBC/PostgreSQL: 576 columnas; 0 diferencias; 21/21 tablas SCA2.
Excluida del despliegue y de la comparación SCA2: PRBRV_EXPEDIENTE_E21CA9B6 (3 columnas inventariadas).
```

Logs completos: ~/mig/ddl_run_1.log y ~/mig/ddl_run_2.log. FKs opcionales y GRANTs no ejecutados (comentados).
