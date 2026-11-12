# 66 · Índices y restricciones de la base de datos SCA2 (R48-B)

> Ronda R48-B · 12/11/2026 · Appian **TEST** (`mapfrespain-test`, MCP `appian-dev-mcp-c90b`), solo lectura. **No se ha ejecutado DDL ni DML** ni se ha modificado ningún objeto Appian. PRO no se ha consultado.
> Script: [`sql/66-indices-sca2.sql`](sql/66-indices-sca2.sql) (para el DBA). Contexto: [04](04-modelo-de-datos.md), [56 DDL](sql/56-ddl-sca2-produccion.sql), [58 §6](58-plan-migracion-sca-sca2.md), [43-D](43-D-cache-cabecera.md), [62](62-cuadro-mando.md), [65](65-valoracion-produccion-rendimiento.md).

## 1. Resumen

- **Motor**: PostgreSQL (Aurora PostgreSQL). Lo confirma `listDataSources` del MCP de TEST (`databaseType: PostgreSQL` para `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050863`) y el DDL 56. No es MySQL/MariaDB ni Oracle: las consultas de catálogo del script usan `pg_indexes`, `pg_index`, `pg_constraint`, `pg_stat_user_*` e `information_schema`, no `SHOW INDEX`.
- **22 tablas `sca2_*`**, una por record type (todos de tipo `DATABASE`, esquema `sca2_anulaciones`). La aplicación no tiene CDT ni data stores: los record types apuntan directamente a las tablas (`_20050863` es el *data source*; `getDataStore` sobre ese id da HTTP 500 porque no es un data store). No hay vistas de BD: solo existe además `PRBRV_EXPEDIENTE_E21CA9B6`, que no es de SCA2 y queda fuera.
- **Volumen en TEST**: tablas pequeñas (la mayor, `sca2_transicion`, 3.085 filas). Hoy cualquier consulta es rápida con o sin índices; los índices propuestos son para **cuando crezca el volumen** (PRO) y, sobre todo, para que el script deje la BD **robusta** (UNIQUE / NOT NULL) frente a duplicados que ya existen.
- **Sincronización**: la API no expone si cada record type tiene *data sync* (**[Pendiente]**). Por las relaciones 1:N y a `User` que tienen, y por las agregaciones y filtros a través de relaciones del cuadro de mando, **se infiere que están sincronizados** (ver §2.2). Si es así, **las lecturas de Appian no llegan a PostgreSQL**: van contra la caché de Appian. Los índices de lectura solo se notarían en la sincronización, en las consultas directas del DBA/informes y si algún día se desactiva la sincronización. Lo que sí afecta siempre a la BD son las **escrituras** (`Write Records` de los PM, `a!writeRecords`, `a!deleteRecords`) y las **restricciones**.
- **Hallazgos de robustez con datos reales de TEST**:
  - `sca2_datos_cabecera`: 4 solicitudes con **2 filas de caché** (creadas con 4–8 s de diferencia: refrescos concurrentes). No hay UNIQUE que lo impida.
  - `sca2_tarea`: 5 pares solicitud+tipo con **2 tareas PENDIENTE** (una pareja creada con 3 s de diferencia).
  - `sca2_error`: 38 errores PENDIENTE repetidos (misma solicitud, comando y código).
  - `sca2_cat_tipo_argumento`: `COD_TP_ARG = 999` aparece dos veces (activo e inactivo) → el `ux_sca2_cat_tipo_argumento` del DDL 56 **no existe en TEST** (si existiera, la segunda fila no se habría podido insertar) y fallaría al crearlo.
  - `sca2_datos_cabecera.POLIZA_FECHAULTIMOSINIESTRO` sigue en **VARCHAR(255)** (R46-D pendiente) y ya hay valores de 241 caracteres.
  - `sca2_transicion.CLAVE_IDEMPOTENCIA` sí tiene UNIQUE físico (el MCP lo informa) y 0 duplicados.
- **Propuesta**: 10 índices nuevos (1 alta, 6 media, 3 baja) + los de `ID_SOLICITUD` del DDL 56 si faltan; UNIQUE en la caché de cabecera (alta, tras limpiar y ajustar el refresco), NOT NULL en claves, UNIQUE parcial de catálogo, ampliación de dos longitudes. UNIQUE de tareas pendientes y FKs quedan **comentados** hasta que haya decisión.

## 2. Inventario (TEST, 12/11/2026)

### 2.1 Tablas y record types

PK = `ID` (INTEGER, secuencia) en las 22 tablas. «UNIQUE físico» = lo que informa `listDatabaseTableColumns` (solo detecta UNIQUE de una columna). «Rel.» = relaciones del record type.

| Record type | Tabla | Filas | Col. | UNIQUE físico (además de PK) | Rel. | Sync |
|---|---|---:|---:|---|---|---|
| SCA2 Solicitud | `sca2_solicitud` | 496 | 36 | `ID_SOLICITUD` | createdBy/modifiedBy (User), 1:N transiciones, tareas, errores, datosSolicitud, nivelesCoberturaAutos, otrasSolicitudesCabecera, llamadasServicio | Inferido sí [Pendiente] |
| SCA2 Transicion | `sca2_transicion` | 3.085 | 12 | `CLAVE_IDEMPOTENCIA` | N:1 solicitud, usuario (User) | Inferido sí [Pendiente] |
| SCA2 Tarea | `sca2_tarea` | 858 | 17 | — | N:1 solicitud, propietario/asignadoA (User) | Inferido sí [Pendiente] |
| SCA2 Error | `sca2_error` | 143 | 13 | — | N:1 solicitud, resueltoPor (User) | Inferido sí [Pendiente] |
| SCA2 Llamada Servicio | `sca2_llamada_servicio` | 338 | 12 | — | N:1 solicitud | Inferido sí [Pendiente] |
| SCA2 Trazabilidad Cliente | `sca2_trazabilidad_cliente` | 935 | 11 | — | — | [Pendiente] |
| SCA2 Datos Cabecera | `sca2_datos_cabecera` | 490 | 53 | — | — | [Pendiente] |
| SCA2 Datos Solicitud | `sca2_datos_solicitud` | 478 | 33 | — | N:1 solicitud | Inferido sí [Pendiente] |
| SCA2 Datos Basicos Solicitud | `sca2_datos_basicos_solicitud` | 478 | 9 | — | — | [Pendiente] |
| SCA2 Datos Perfiles Pca | `sca2_datos_perfiles_pca` | 478 | 6 | — | — | [Pendiente] |
| SCA2 Datos Productor | `sca2_datos_productor` | 478 | 16 | — | — | [Pendiente] |
| SCA2 Datos Poliza Autos | `sca2_datos_poliza_autos` | 421 | 84 | — | — | [Pendiente] |
| SCA2 Datos Poliza Hogar | `sca2_datos_poliza_hogar` | 57 | 90 | — | — | [Pendiente] |
| SCA2 Datos Poliza Vida | `sca2_datos_poliza_vida` | 0 | 90 | — | — | [Pendiente] |
| SCA2 Niveles Cobertura Autos | `sca2_niveles_cobertura_autos` | 478 | 5 | — | N:1 solicitud | Inferido sí [Pendiente] |
| SCA2 Otras Solicitudes Cabecera | `sca2_otras_solicitudes_cabecera` | 478 | 10 | — | N:1 solicitud | Inferido sí [Pendiente] |
| SCA2 Cat Motivo | `sca2_cat_motivo` | 14 | 12 | — (UNIQUE compuesto: [Pendiente]) | — | Doc 41: sí |
| SCA2 Cat Detalle | `sca2_cat_detalle` | 22 | 11 | — (ídem) | — | Doc 41: sí |
| SCA2 Cat Causa | `sca2_cat_causa` | 146 | 13 | — (ídem) | — | Doc 41: sí |
| SCA2 Cat Tipo Argumento | `sca2_cat_tipo_argumento` | 346 | 31 | — (no existe, ver §1) | — | Doc 41: sí |
| SCA2 Cat Concepto | `sca2_cat_concepto` | 17 | 11 | — | — | Doc 41: sí |
| SCA2 Cat Valor Concepto | `sca2_cat_valor_concepto` | 101 | 13 | — | — | Doc 41: sí |

Ningún record type tiene record events (`hasRecordEvents = false`). Las filas son las de `listRecordData` del 12/11/2026 (las del doc 56 son anteriores).

### 2.2 Estado de sincronización

`getRecordType` no devuelve el estado de *data sync* y no hay herramienta MCP que lo lea. Indicios de que **están sincronizados**: (1) relaciones 1:N y relaciones con el record type de sistema `User`; (2) el cuadro de mando filtra y agrega a través de relaciones (`SCA2 Tarea.solicitud.lineaNegocio`, `SCA2 Datos Solicitud.solicitud.createdAt`…); (3) el doc 41 dice que los catálogos están sincronizados y el doc 09 describe la creación con «sincronizar». **[Pendiente]**: confirmarlo en Designer (record type → *Data Model* → *Data Sync*) y anotar la fecha de la última sincronización y su duración.

Consecuencias si están sincronizados:
- `a!queryRecordType`, `a!recordData` (grids) y los nodos de consulta leen de la caché de Appian, **no** de PostgreSQL.
- PostgreSQL recibe: la sincronización completa (lectura de toda la tabla por PK, por lotes), las escrituras (INSERT/UPDATE por PK y la relectura por PK de la fila escrita) y los borrados.
- Cualquier cambio de datos hecho **directamente en la BD** (limpieza de duplicados, ampliación de columnas…) no se ve en Appian hasta la siguiente sincronización: tras ejecutar C1 o limpiar datos, lanzar la sincronización completa del record type.
- Límite de filas de un record type sincronizado [Pendiente: confirmar el valor configurado]; `sca2_transicion` es la que más crece (≈6,5 filas por solicitud).

### 2.3 Tipos y longitudes (columnas de consulta)

| Tabla | Columna | Tipo físico | Nulos TEST | Observación |
|---|---|---|---:|---|
| sca2_solicitud | ID_SOLICITUD | VARCHAR(50) UNIQUE | 0 | 21 filas `PDTE-*` |
| sca2_solicitud | NUM_POLIZA | VARCHAR(30) | 0 | 460 pólizas distintas / 496 filas |
| sca2_solicitud | ESTADO_SOLICITUD | VARCHAR(40) | 0 | 12 valores; EN_ACCION 43 % |
| sca2_solicitud | CREATED_AT / MODIFIED_AT / CADUCIDAD_TAREA | TIMESTAMP | 0 / 0 / 22 | |
| sca2_solicitud | LINEA_NEGOCIO / ORIGEN_POLIZA | VARCHAR(20) | 0 | 3 y 4 valores (baja selectividad) |
| sca2_tarea | TIPO / ESTADO | VARCHAR(40) / VARCHAR(20) | 0 | 7 tipos; PENDIENTE 283 |
| sca2_tarea | GRUPO / ASIGNADO_A / PROPIETARIO | VARCHAR(100) / VARCHAR(255) | 37 (grupo) | |
| sca2_transicion | CLAVE_IDEMPOTENCIA | VARCHAR(120) UNIQUE | 0 | Máx. 53; teórico 60+50+versión > 120 |
| sca2_error | COMANDO / CODIGO / ESTADO | VARCHAR(60/40/20) | 0 | `ID_SOLICITUD` admite nulo (errores sin solicitud) |
| sca2_datos_cabecera | ID_SOLICITUD / VALIDA_HASTA / FECHA_CACHE / ORIGEN_CACHE | VARCHAR(50) / TIMESTAMP / TIMESTAMP / VARCHAR(50) | 0 / 213 / – / 213 | 277 filas `CACHE`, 213 de alta |
| sca2_datos_cabecera | POLIZA_FECHAULTIMOSINIESTRO | **VARCHAR(255)** | – | Máx. 241: ampliar a 1000 (R46-D) |
| sca2_datos_solicitud | FECIMPRESION | VARCHAR(255) | – | Un valor de 255 (texto de prueba R47C truncado) |

Los campos de texto del record type informan `VARCHAR(255)` en `sourceFieldType` aunque la columna física sea más corta (150 discrepancias de metadato, sin efecto funcional). Appian **no valida** la longitud física: un valor más largo falla al escribir en la BD (error del nodo Write Records), no en el formulario.

## 3. Índices que existen hoy

| Origen | Qué se sabe |
|---|---|
| Verificado por MCP | PK `ID` en las 22 tablas; UNIQUE `sca2_solicitud.ID_SOLICITUD`; UNIQUE `sca2_transicion.CLAVE_IDEMPOTENCIA`. |
| Deducido de los datos | `ux_sca2_cat_tipo_argumento (COD_TP_ARG)` **no existe** en TEST (hay un duplicado). |
| DDL 56 (repo) | 59 índices: `ID_SOLICITUD` en las 15 tablas hijas, `NUM_POLIZA`/`ESTADO_SOLICITUD`/`ESTADO_TAREA` en solicitud, `NUM_POLIZA`/`ESTADO` en tarea, `ESTADO` en error, `ESTADO_ORIGEN`/`ESTADO_DESTINO` en transición, `ESTADO`/`ESTADOPOLIZA` en pólizas, `COD_ESTADO` en tipo argumento y los 6 `ux_sca2_cat_*`. |
| **[Pendiente]** | Qué índices del DDL 56 existen físicamente en TEST: la API de Appian no expone índices (doc 58 §6). Lo resuelven las consultas **A3–A5** del script. |

Índices del DDL 56 de **baja selectividad** (pocos valores distintos) que el planificador casi nunca usará: `ESTADO`/`ESTADOPOLIZA` de pólizas, `ESTADO_TAREA`, `ESTADO_ORIGEN`/`ESTADO_DESTINO`, `COD_ESTADO`. No se borran; si **A4/D4** muestran `idx_scan = 0` tras unas semanas en PRO, son candidatos a eliminar (ahorran coste de escritura).

## 4. Patrones de consulta reales

Fuente: 214 reglas, 72 interfaces y 17 PM de la aplicación SCA2 en TEST (lectura con `getExpressionRule`/`getInterface`/`getProcessModel`). 126 llamadas `a!queryRecordType` en 52 objetos, 30 `a!recordData` (grids), **0 `a!queryEntity`**, `a!writeRecords`/`a!deleteRecords` en 12 interfaces/reglas y 67 nodos *Write Records* en 13 PM. Frecuencia: **muy alta** = en cada apertura de solicitud/tarea o en cada comando; **alta** = cada uso de una pantalla de bandeja/buscador; **media** = cuadro de mando y mantenimiento; **baja** = batch/administración.

| # | Patrón (objeto) | Record type | Filtros | Orden / lote | Frecuencia | Índice que lo sirve |
|---|---|---|---|---|---|---|
| P1 | Lectura por solicitud (detalle, `SCA2_cargarSolicitud`, CMD Alta…) | Solicitud | `idSolicitud =` | 1 fila | Muy alta (16 usos) | UNIQUE `ID_SOLICITUD` (existe) |
| P2 | Buscador `SCA2_Buscador` | Solicitud | `idSolicitud not starts with "PDTE-"` + opcionales `numPoliza =`, `idSolicitud =`, `estadoSolicitud in`, `lineaNegocio =`, `numPoliza in` (cliente/matrícula); los vacíos se sustituyen por `id > 0` | `createdAt DESC`, 10 | Alta | **B1** (sin filtros), **B2** (por póliza), UNIQUE (por id) |
| P3 | Solicitud en curso por póliza (alta, contraanulación) | Solicitud | `numPoliza =` (+ `estadoSolicitud not in` / `is null`, `createdAt >=`) | `createdAt DESC` | Alta | **B2** |
| P4 | Batch NSE / pendientes de autorizar | Solicitud | `estadoSolicitud =`, `numPoliza in`, `procesoActivo =` / `origenPoliza =` | `modifiedAt DESC` | Baja | B2 (por póliza) |
| P5 | Barrido de caducidad (`SCA2 CMD BarridoCaducidad`) | Solicitud | `caducidadTarea <`, `estadoSolicitud not in` | — | Baja (batch) | **B3** |
| P6 | Datos de la solicitud (`SCA2_Obtener*`, `DetalleSolicitud`, CMD) | Datos Solicitud/Básicos/Perfiles/Productor/Pólizas/Niveles/Otras | `idSolicitud =` (`in` en perfiles) | `id DESC`, 1 | Muy alta (≈25 usos) | `ix_*_id_solicitud` (B0/DDL 56) |
| P7 | Caché de cabecera vigente (`SCA2_obtenerDatosCabecera*`) | Datos Cabecera | `idSolicitud =`, `validaHasta not null`, `validaHasta > now()` (± `origenCache = "CACHE"`) | `fechaCache DESC` o `id DESC`, 1 | Muy alta | `ix_sca2_datos_cabecera_id_solicitud`; **C1** garantiza 1 fila |
| P8 | Refresco de caché caducada (`SCA2 CMD RefrescarCacheCabecera`) | Datos Cabecera + Solicitud | `idSolicitud in`, `origenCache =`, `validaHasta <=`; solicitudes `estadoSolicitud not in` | — | Baja (batch) | `ix_..._id_solicitud` |
| P9 | Limpieza de duplicados (`SCA2_obtenerFilasDuplicadasCacheCabecera`) | Datos Cabecera | `idSolicitud =` | `id DESC`, 100 | Media | ídem; innecesaria con C1 |
| P10 | Idempotencia de comandos (los 9 CMD) | Transicion | `claveIdempotencia =` (+ `resultado =`/`in`); clave = `comando|idSolicitud|versión` (`SCA2_claveIdempotencia`) | — | Muy alta (cada comando) | UNIQUE `CLAVE_IDEMPOTENCIA` (existe) |
| P11 | Historial de transiciones (`SCA2_DetalleTransiciones`) | Transicion | `idSolicitud =` | `fecha DESC` | Alta | `ix_sca2_transicion_id_solicitud` |
| P12 | Tarea pendiente de la solicitud (`DetalleTareas`, `puedeGestionarTarea`, CMD CrearAccion/CambiarNivel/Mecanizar) | Tarea | `idSolicitud =`, `estado =`, `tipo = / <> / starts with / in`, `id <>` | `id DESC`, 1 | Muy alta | `ix_sca2_tarea_id_solicitud` (≈2 filas por solicitud: basta) |
| P13 | Tarea por id (acciones, reasignar) | Tarea | `id =` | 1 | Alta (7 usos) | PK |
| P14 | **Aviso del cuadro de mando** | Tarea | `tipo = "INDUCCION"`, `estado = PENDIENTE`, `fechaCreacion < now() - 1 h` | `fechaCreacion ASC`, 100 | Media (cada carga) | **B4** |
| P15 | Bandeja de errores (`SCA2_BandejaErrores`) | Error | `id > 0`, `estado =`, `comando starts with` (opcionales) | `fechaCreacion DESC`, paginada | Alta | **B7** |
| P16 | Errores de la solicitud / reintentos (`DetalleErrores`, `ContraAnulacion…`, CMD) | Error | `idSolicitud =`, `comando =`/`starts with`, `estado =`, `codigo =`, `fechaCreacion >=` | `fechaCreacion DESC` | Alta | `ix_sca2_error_id_solicitud` |
| P17 | Cuadro de mando (`SCA2_CuadroMando`, 90 días, línea, origen) | Solicitud, Datos Solicitud, Transicion, Tarea, Llamada, Error, Trazabilidad, Cat Motivo/Detalle | `createdAt`/`fecha`/`fechaCreacion`/`fechaInicio between`; `solicitud.lineaNegocio =`, `solicitud.origenPoliza =` (a través de la relación); `mecanizacionRealizada`, `resultado <> "OK"`, `duracionMs not null`, `grupo not null`, `perfilUsuario not null`, `estado =` | agregaciones (`a!aggregationFields`) | Media | **B1, B5, B6, B8** (rango de fechas) |
| P18 | Mantenimiento de catálogos (`SCA2_CatMantenimiento`, `catConstruirCarga`, altas) | Cat * | `activo =`, `includes` (contiene) en varios campos; altas: clave `=` e `id <>` | `orden, id`; carga 5.000 | Baja | Ninguno útil (≤346 filas) |
| P19 | Filtros por usuario y grupo | Tarea, Solicitud, Transicion | `asignadoA`/`grupo`/`propietario`/`usuario` se **leen** (campos) y se comparan en memoria (`SCA2_puedeGestionarTarea`, `reasignarTarea`); en consulta solo `grupo not null` (cuadro) | — | Alta | No necesitan índice |
| E1 | Escrituras de proceso (13 PM, 67 nodos *Write Records*) e interfaces (`a!writeRecords` en 12) | Solicitud, Transicion, Tarea, Error, Llamada, Datos *, Cabecera | INSERT/UPDATE por `ID` | — | Muy alta | PK; cada índice añadido suma coste aquí |

## 5. Propuesta

### 5.1 Tabla «tabla → índice → consulta → prioridad → riesgo»

| Tabla | Índice / restricción (script) | Consulta que acelera o protege | Prioridad | Riesgo |
|---|---|---|---|---|
| sca2_* hijas | `ix_*_id_solicitud` (B0, nombres del DDL 56) | P6, P7, P11, P12, P16 | Alta si faltan (A3) | Nulo: `IF NOT EXISTS`; si existe con otro nombre se duplicaría → revisar A3 antes |
| sca2_solicitud | `ix_sca2_solicitud_created_at ("CREATED_AT" DESC)` (B1) | P2 sin filtros (10 últimas sin ordenar toda la tabla), P17 | **Alta** | Bajo: +1 índice en cada INSERT/UPDATE de `CREATED_AT` (solo en alta) |
| sca2_solicitud | `ix_sca2_solicitud_num_poliza_created_at ("NUM_POLIZA","CREATED_AT" DESC)` (B2) | P2/P3/P4 por póliza con orden por fecha | Media | Bajo; deja redundante `ix_sca2_solicitud_num_poliza` (borrar más adelante) |
| sca2_solicitud | `ix_sca2_solicitud_caducidad_tarea` parcial `IS NOT NULL` (B3) | P5 | Baja | Bajo; `CADUCIDAD_TAREA` cambia en cada nivel → coste de UPDATE |
| sca2_tarea | `ix_sca2_tarea_pendiente_tipo_fecha ("TIPO","FECHA_CREACION") WHERE ESTADO='PENDIENTE'` (B4) | P14 (aviso) | Media | Bajo: índice pequeño; si cambia el literal `PENDIENTE` (constante `SCA2_TXT_ESTADO_TAREA_PENDIENTE`) deja de usarse |
| sca2_tarea | `ix_sca2_tarea_fecha_creacion` (B5) | P17 tareas | Media | Bajo |
| sca2_transicion | `ix_sca2_transicion_fecha` (B6) | P17 gestiones/duración | Media | Bajo; es la tabla con más INSERT |
| sca2_error | `ix_sca2_error_estado_fecha_creacion ("ESTADO","FECHA_CREACION" DESC)` (B7) | P15 | Media | Bajo; redundante con `ix_sca2_error_estado` |
| sca2_error / llamada / trazabilidad | `ix_..._fecha_creacion`, `ix_..._fecha_inicio`, `ix_..._fecha` (B8) | P17 | Baja | Bajo |
| sca2_datos_cabecera | **UNIQUE** `ux_sca2_datos_cabecera_id_solicitud` (C1) | P7: garantiza una fila por solicitud (R38) | **Alta** | **Medio**: hoy fallaría (4 duplicados) → el bloque no lo crea hasta limpiar. Con él, un segundo INSERT concurrente del refresco dará `unique_violation` → antes ajustar el refresco (abajo) |
| sca2_transicion | `CLAVE_IDEMPOTENCIA SET NOT NULL` (C2; el UNIQUE ya existe) | P10: un UNIQUE admite varios NULL | Alta | Bajo: 0 nulos; un comando que no calcule la clave fallará al escribir (comportamiento deseado) |
| sca2_solicitud, transicion, tarea, llamada, cabecera | `SET NOT NULL` en `ID_SOLICITUD`, `NUM_POLIZA`, `CREATED_AT`, `ESTADO` (C3) | Robustez de P1–P16 | Media | Bajo: 0 nulos. Bloqueo breve (escanea la tabla) |
| sca2_cat_* | `ux_sca2_cat_*` del DDL 56 que falten; `ux_sca2_cat_tipo_argumento_activo (COD_TP_ARG) WHERE ACTIVO` (C4) | P18 altas (evita códigos repetidos activos) | Media | Bajo; el completo del DDL 56 fallaría por el 999 activo/inactivo |
| sca2_datos_cabecera | `POLIZA_FECHAULTIMOSINIESTRO → VARCHAR(1000)` (C5, = R46-D) | Escritura de caché con enlace GESVIDA | Media | Bajo: ampliar VARCHAR no reescribe la tabla; falla si hay vistas dependientes (A7: hoy ninguna) |
| sca2_transicion | `CLAVE_IDEMPOTENCIA → VARCHAR(200)` (C6) | P10 con comandos/ids largos | Baja | Bajo; ídem |
| sca2_tarea | UNIQUE parcial `(ID_SOLICITUD, TIPO) WHERE ESTADO='PENDIENTE'` (C7, **comentado**) | Evita tareas pendientes duplicadas | Alta en robustez, **pendiente de decisión** | Alto: hoy hay 5 duplicados; `SCA2 CMD CrearAccion` fallaría en la carrera en lugar de duplicar |
| tarea, transicion, llamada | FK a `sca2_solicitud(ID_SOLICITUD)` `NOT VALID` (C8, **comentado**) | Integridad (0 huérfanos) | Baja | Medio: rechazaría el paso de `PDTE-*` al id de CORE si ya hay hijos; coste de comprobación en cada INSERT. No aporta rendimiento |

**No se proponen**: índice compuesto `tarea (ID_SOLICITUD, ESTADO, TIPO)` ni `transicion (ID_SOLICITUD, FECHA)` (con ≈2 y ≈6,5 filas por solicitud el índice por `ID_SOLICITUD` basta); índices en catálogos (menos de 400 filas: el `Seq Scan` es más barato); UNIQUE en `datos_*` (el modelo los define 1:N y las lecturas toman la última fila; hay 1 duplicado de pruebas, 15787528) ni en `sca2_error` (38 duplicados pendientes: es un tema de la lógica de reintento, no de la BD); FK en `sca2_error`, `datos_*` y cabecera (huérfanos por diseño o de pruebas).

### 5.2 Filtros que no pueden usar un índice B-tree

| Filtro (Appian → SQL) | Dónde | Efecto | Recomendación |
|---|---|---|---|
| `not starts with "PDTE-"` → `NOT LIKE 'PDTE-%'` | Buscador | Negación: no usa índice; descarta 21 de 496 filas | Mantener; el orden `CREATED_AT DESC` + B1 recorre el índice y descarta al vuelo |
| `includes` → `LIKE '%x%'` | Mantenimiento de catálogos | Escaneo completo | Irrelevante (≤346 filas). En tablas grandes haría falta `pg_trgm` (no se propone) |
| `starts with` → `LIKE 'x%'` | Bandeja de errores (`comando`), tareas (`tipo`) | Solo usa índice con collation `C` o `varchar_pattern_ops` (A1) | Si el valor es completo, usar `=` (propuesta Appian) |
| `<>`, `not in`, `is null` | Solicitud en curso, tareas `tipo <> INDUCCION` | No selectivos | Se apoyan en el filtro selectivo (`numPoliza`, `idSolicitud`) |
| Filtros por relación (`solicitud.lineaNegocio`) | Cuadro de mando | Join en Appian (caché si sync) | Sin efecto en PG si están sincronizados |
| `id > 0` como filtro «vacío» | Buscador, bandeja | Inocuo, pero ensucia el plan | Sustituir por `applyWhen` (propuesta Appian) |

No se han detectado funciones aplicadas a columnas en los filtros (las funciones como `tostring()` se aplican al valor, no a la columna).

### 5.3 Cambios de Appian propuestos (no aplicados)

1. **Refresco de caché de cabecera sin duplicados** (requisito de C1): antes de escribir, releer la fila por `idSolicitud` y reutilizar su `id` (UPDATE en lugar de INSERT), y evitar el doble disparo (Web API `SCA2_refrescarCacheCabecera` y el PM llamados con segundos de diferencia). Con C1 creado, tratar el `unique_violation` como «ya refrescada».
2. **`SCA2 CMD CrearAccion`**: comprobar «ya existe tarea PENDIENTE de ese tipo» justo antes de escribir (requisito de C7).
3. **Reintentos de `SCA2 Error`**: actualizar el error PENDIENTE existente (intentos +1) en lugar de crear otro igual.
4. **Buscador y bandeja**: `applyWhen` en vez de `id > 0`; `comando =` en vez de `starts with` cuando se elige un comando concreto.
5. Si `sca2_transicion` se acerca al límite de filas de sincronización, valorar un filtro de origen de la sincronización (p. ej. últimos N meses) o un histórico aparte.

## 6. Qué ejecutar primero en TEST

1. **Bloque A** completo (solo lectura). Guardar la salida: A3–A5 resuelven los [Pendiente] de índices y restricciones; A8–A11 confirman duplicados, huérfanos, nulos y longitudes; A13 es la línea base.
2. **Bloque B** (índices, `CONCURRENTLY`, en autocommit) y `ANALYZE` (B9). D2 sin índices inválidos.
3. **C2, C3, C4, C5, C6** (no dependen de cambios en Appian).
4. **C1** (desactivado en el script; quitar los comentarios) solo después de (a) borrar las 4 filas sobrantes de A8.1 desde Appian (`SCA2_obtenerFilasDuplicadasCacheCabecera` + `a!deleteRecords`) y (b) aplicar y probar el cambio 5.3.1. Si se borran en la BD, lanzar la sincronización completa de `SCA2 Datos Cabecera`.
5. **Bloque D**: D1/D2 y repetir A13 (D3). Probar en la UI: alta, buscador, detalle, una acción completa, bandeja de errores y cuadro de mando.
6. C7 y C8 solo tras decisión del analista y prueba en TEST. Después, repetir en PRO en ventana de baja carga (nunca sin pasar por TEST).

## 7. Cómo medir antes y después

| Dónde | Qué medir | Cómo |
|---|---|---|
| PostgreSQL | Plan y coste de cada patrón | `EXPLAIN (ANALYZE, BUFFERS)` de A13 antes y D3 después: tipo de nodo (`Seq Scan` → `Index Scan`/`Bitmap`), `actual time`, `Buffers` |
| PostgreSQL | Uso real de los índices | `pg_stat_user_indexes.idx_scan` (A4/D4) tras días de uso; `pg_stat_user_tables.seq_scan` |
| PostgreSQL | Sentencias lentas | `pg_stat_statements` o `log_min_duration_statement` si el DBA los tiene activos [Pendiente] |
| Appian (sync) | Duración de la sincronización | Designer → record type → *Data Sync* / monitorización: duración antes/después |
| Appian | Tiempo de las pantallas | Vista *Performance* de la interfaz (`SCA2_Buscador`, `SCA2_CuadroMando`, `SCA2_DetalleSolicitud`) y *Test Rules* de las reglas de consulta; mismo caso, 3 ejecuciones, mediana |
| Appian | Tiempo de los comandos | Duración de las instancias de `SCA2 CMD *` (monitorización de procesos) y `DURACION_MS` de `sca2_transicion` / `sca2_llamada_servicio` |

**Diferencia clave**: si los record types están sincronizados, los tiempos de pantalla de Appian **no cambiarán** con los índices de lectura (leen de la caché de Appian); los índices se verán en EXPLAIN, en la sincronización y en las consultas directas. Las restricciones (C1–C6) sí cambian el comportamiento de las escrituras desde el primer momento. Con estos volúmenes, la diferencia en EXPLAIN también será pequeña (PostgreSQL puede preferir `Seq Scan` en tablas de cientos de filas, y es correcto); el beneficio esperado es a volumen de PRO.

## 8. Limitaciones y pendientes

- **[Pendiente]** Índices y restricciones físicas de TEST (salvo PK y los 2 UNIQUE vistos): bloque A.
- **[Pendiente]** Estado de *data sync* de cada record type y límite de filas configurado: Designer.
- **[Pendiente]** Collation de la BD (A1) y disponibilidad de `pg_stat_statements`.
- **[Pendiente]** Volúmenes de PRO: no consultado (regla «nunca PRO»).
- Los conteos y duplicados son de TEST del 12/11/2026 (`listRecordData`); pueden cambiar.
- El script se ha probado en un PostgreSQL 16 local vacío creado con el DDL 56 (dos ejecuciones seguidas sin error, idempotente; con duplicados simulados C1 emite el WARNING y no crea el índice). No se ha ejecutado contra TEST.
