# SCA2 — DDL de creación y actualización (resumen)

Extracción de Appian TEST (sólo lectura): 2026-11-03T10:37:37.924844+00:00. Fichero: `docs/sca/sql/56-ddl-sca2-produccion.sql`. Owner: `docs/sca/sql/56-owner-sca2.sql`.

## Qué hace

- **Base vacía:** crea el esquema `sca2_anulaciones`, 22 tablas, 588 columnas, 22 secuencias de `ID` y 59 índices.
- **Esquema existente:** crea las tablas que falten, añade columnas que falten, amplía tipos cuando es seguro (VARCHAR más largo, VARCHAR→TEXT, SMALLINT→INTEGER→BIGINT, número→texto), añade PK, autonumérico de `ID`, UNIQUE e índices que falten y refresca comentarios.
- **Nunca** borra tablas, columnas ni datos, ni reduce tipos. Lo que no puede cambiar con seguridad lo avisa con `WARNING`; las columnas que SCA2 ya no usa, con `NOTICE`.
- Se puede relanzar las veces que haga falta. Va en una transacción: si falla algo, no aplica nada.

## Cambios respecto a la versión anterior

- Nueva tabla `sca2_llamada_servicio` (record type `SCA2 Llamada Servicio`, 12 columnas): registro de llamadas a servicios.
- El resto de tablas y columnas no ha cambiado.

## Tablas

| Tabla | Record type | Columnas | Filas en TEST |
|---|---|---:|---:|
| sca2_cat_causa | SCA2 Cat Causa | 13 | 146 |
| sca2_cat_concepto | SCA2 Cat Concepto | 11 | 17 |
| sca2_cat_detalle | SCA2 Cat Detalle | 11 | 22 |
| sca2_cat_motivo | SCA2 Cat Motivo | 12 | 14 |
| sca2_cat_tipo_argumento | SCA2 Cat Tipo Argumento | 31 | 346 |
| sca2_cat_valor_concepto | SCA2 Cat Valor Concepto | 13 | 101 |
| sca2_datos_basicos_solicitud | SCA2 Datos Basicos Solicitud | 9 | 362 |
| sca2_datos_cabecera | SCA2 Datos Cabecera | 53 | 360 |
| sca2_datos_perfiles_pca | SCA2 Datos Perfiles Pca | 6 | 362 |
| sca2_datos_poliza_autos | SCA2 Datos Poliza Autos | 84 | 333 |
| sca2_datos_poliza_hogar | SCA2 Datos Poliza Hogar | 90 | 29 |
| sca2_datos_poliza_vida | SCA2 Datos Poliza Vida | 90 | 0 |
| sca2_datos_productor | SCA2 Datos Productor | 16 | 362 |
| sca2_datos_solicitud | SCA2 Datos Solicitud | 33 | 362 |
| sca2_error | SCA2 Error | 13 | 125 |
| sca2_llamada_servicio | SCA2 Llamada Servicio | 12 | 45 |
| sca2_niveles_cobertura_autos | SCA2 Niveles Cobertura Autos | 5 | 362 |
| sca2_otras_solicitudes_cabecera | SCA2 Otras Solicitudes Cabecera | 10 | 362 |
| sca2_solicitud | SCA2 Solicitud | 36 | 370 |
| sca2_tarea | SCA2 Tarea | 17 | 642 |
| sca2_transicion | SCA2 Transicion | 12 | 2281 |
| sca2_trazabilidad_cliente | SCA2 Trazabilidad Cliente | 11 | 685 |

Excluida: `PRBRV_EXPEDIENTE_E21CA9B6` (está en el esquema pero no es de SCA2).

## Cómo ejecutarlo en un entorno

1. `psql -v ON_ERROR_STOP=1 -f 56-ddl-sca2-produccion.sql`.
2. Revisar los `WARNING` de la salida, si los hay.
3. Si hace falta, `56-owner-sca2.sql` para dejar como owner a `user_sca2_anulaciones`.
4. Si Appian no conecta con el owner, descomentar los `GRANT` del final con su usuario.

## Límites

- La API de Appian no muestra defaults (salvo `ACTIVO` de catálogos), nulabilidad, checks ni triggers: no se crean.
- Las claves ajenas van comentadas.

## Verificación en PostgreSQL 16 local

```text
== A. Base vacía
 ejecución 1: avisos=[]
 ejecución 2: avisos=[]
 objetos i=59 r=22 S=22 | diferencias [] | ID sin autonumérico 0
== B. Esquema creado con el DDL anterior y con datos
 tablas antes 21
 avisos []
 filas sca2_solicitud 1:P1,2:P2,3:P3 | catálogo M1:true | llamada_servicio 1
 objetos i=59 r=22 S=22 | diferencias []
 2ª ejecución avisos []
== C. Esquema antiguo incompleto/distinto
   NOTICE:  Ampliado sca2_solicitud.ID_SOLICITUD: character varying(20) -> character varying(50)
   NOTICE:  Convertido sca2_solicitud.NUM_POLIZA: smallint -> character varying(30)
   WARNING:  No se reduce sca2_solicitud.ESTADO_SOLICITUD: actual character varying(4000), esperado character varying(40) (revisar DBA)
   NOTICE:  Ampliado sca2_transicion.CLAVE_IDEMPOTENCIA: character varying(50) -> character varying(120)
   NOTICE:  PK añadida en sca2_solicitud.ID
   NOTICE:  Autonumérico añadido en sca2_solicitud.ID (secuencia sca2_solicitud_ID_seq)
   NOTICE:  UNIQUE añadida en sca2_solicitud.ID_SOLICITUD
   WARNING:  No se pudo añadir UNIQUE en sca2_transicion.CLAVE_IDEMPOTENCIA: could not create unique index "sca2_transicion_clave_idempotencia_key" (revisar duplicados)
   NOTICE:  Columna sin uso en SCA2 (se conserva): sca2_solicitud.OBSOLETA
 filas 5:S5:x,7:S7:y,8:S8:-
 PK solicitud 1 | UNIQUE ID_SOLICITUD 1
 diferencias restantes ["('sca2_solicitud', 'ESTADO_SOLICITUD'): esperado=character varying(40) real=character varying(4000)", "('sca2_solicitud', 'OBSOLETA'): esperado=None real=text"]
```
