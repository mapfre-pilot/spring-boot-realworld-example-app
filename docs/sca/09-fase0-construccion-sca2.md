# Fase 0 — Construcción de la aplicación SCA2

Estado de la fase 0 del plan de rediseño (cap. 07): creación de la aplicación aislada `SCA2`, migración de la
fuente de datos de sus record types y copia del batch A de reglas e interfaces. Entorno: `mapfrespain-dev`.

## 1. Aplicación SCA2

- **Nombre:** `SCA2 Sistema Comercial de Anulaciones` · prefijo `SCA2` · urlIdentifier `ii9ZQA`
- **UUID:** `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`
- **Grupos:** `SCA2 Administrators` (`_e-0000f069-4e92-8000-9c18-01075c01075c_8069`, miembros: devin,
  GGALV10@mapfre.net) y `SCA2 Users` (`_e-0000f069-4e92-8000-9c18-01075c01075c_8071`).
- **Seguridad:** los objetos creados vía MCP heredan la seguridad por defecto de la aplicación
  (Administrators = admin, Users = viewer) al pasar `appUuid` en las llamadas `create*`.
- **Carpetas:** rulesAndConstants, knowledgeCenter, artifacts, documentation y processModels creadas por Appian
  (UUIDs registrados en `sca2_uuids.json`).

## 2. Data source "SCA2 DataBase AWS"

- **UUID connected system:** `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050863`
- **Schema PostgreSQL:** `sca2_anulaciones`
- **Data source anterior (origen):** `SCAC AWS DB` (`_a-0000eb9b-717e-8000-9c54-011c48011c48_12081503`), schema compartido de SCA.

### Limitación del MCP y procedimiento

`updateRecordType` del MCP `appian-dev-mcp-desarrollo-05c9` **no admite `dataSourceUuid`** (limitación verificada).
La migración se hizo manualmente en **Designer**: record type → *Change source / Cambiar tabla de base de datos* →
seleccionar el data source y la tabla `sca2_*` ya creada → mapear columnas por nombre → sincronizar.
Los **UUIDs de los record types se conservan** (verificado releyendo los 15 objetos tras el cambio — ningún uuid
cambió, nº de campos intacto).

### Estado por record type

| Record type | UUID | Tabla | Data source | Estado |
|---|---|---|---|---|
| SCA2 Solicitud | `c531595c-…` | `sca2_solicitud` | SCA2 DataBase AWS | ✅ migrado (36 campos, 15 rel.) |
| SCA2 Transicion | `0b46024c-…` | `sca2_transicion` | SCA2 DataBase AWS | ✅ migrado (12 campos, 2 rel.) |
| SCA2 Tarea | `696285d3-…` | `sca2_tarea` | SCA2 DataBase AWS | ✅ migrado (17 campos, 3 rel.) |
| SCA2 Error | `d7111f93-…` | `sca2_error` | SCA2 DataBase AWS | ✅ migrado (13 campos, 2 rel.) |
| SCA2 Datos Cabecera | `04f597de-…` | `sca2_datos_cabecera` | SCA2 DataBase AWS | ✅ migrado (44 campos) |
| SCA2 Datos Solicitud | `9a9209c7-…` | `sca2_datos_solicitud` | SCA2 DataBase AWS | ✅ migrado (28 campos) |
| SCA2 Datos Basicos Solicitud | `c21f92cb-…` | `sca2_datos_basicos_solicitud` | SCA2 DataBase AWS | ✅ migrado (9 campos) |
| SCA2 Datos Perfiles Pca | `284ca30d-…` | `sca2_datos_perfiles_pca` | SCA2 DataBase AWS | ✅ migrado (6 campos) |
| SCA2 Datos Productor | `cba8e12b-…` | `sca2_datos_productor` | SCA2 DataBase AWS | ✅ migrado (16 campos) |
| SCA2 Datos Poliza Autos | `eda2fe07-…` | `sca2_datos_poliza_autos` | SCA2 DataBase AWS | ✅ migrado (84 campos) |
| SCA2 Datos Poliza Hogar | `55afc46c-…` | `sca2_datos_poliza_hogar` | SCA2 DataBase AWS | ✅ migrado (90 campos) |
| SCA2 Datos Poliza Vida | `c4141a3a-…` | `sca2_datos_poliza_vida` | SCA2 DataBase AWS | ✅ migrado (90 campos) |
| SCA2 Niveles Cobertura Autos | `18a467f3-…` | `sca2_niveles_cobertura_autos` | SCA2 DataBase AWS | ✅ migrado (5 campos) |
| SCA2 Otras Solicitudes Cabecera | `e8f0c030-…` | `sca2_otras_solicitudes_cabecera` | SCA2 DataBase AWS | ✅ migrado (10 campos, 1 rel.) |
| SCA2 Trazabilidad Cliente | `30d97aab-…` | `sca2_trazabilidad_cliente` | SCA2 DataBase AWS | ✅ migrado (11 campos, 0 rel.) |

**15/15 record types en `SCA2 DataBase AWS`.** Las dos últimas tablas (`sca2_otras_solicitudes_cabecera` y
`sca2_trazabilidad_cliente`) las creó el usuario en el schema `sca2_anulaciones` y después se repuntaron desde
Designer por la misma ruta (Modelo de datos → *Cambiar tabla de base de datos*), conservando UUIDs. La
verificación vía MCP confirma uuid, tabla y nº de campos inalterados, y 1 relación en Otras Solicitudes Cabecera
(`solicitud` → SCA2 Solicitud) y 0 en Trazabilidad Cliente.

## 3. Constantes SCA2

98 constantes creadas (mapa `SCA_*` → `SCA2_*`) más 3 folder-constants. Excepciones:

- **17 constantes de tipo `PROCESS_MODEL`** (`SCA_PM_*`, `SCA_GENERAR_SOLICITUD`, `SCA_GUARDAR_TRAZABILIDAD`,
  `SCA_OBETENER_DOCUMENTO_ARGUMENTO`) omitidas deliberadamente: sus PMs de destino aún no existen en SCA2 (batch B).
- **`SCA2_DSE_TM_TRANSACTION`** falló al crear (`DATA_STORE_ENTITY not found` — apunta a una entidad de data store
  externa que no se puede referenciar desde la app).

## 4. Batch A — copia de reglas e interfaces (SCA → SCA2)

Alcance = cierre transitivo de: PM *Alta Solicitud Anulacion Particionado* + páginas del site + Web APIs +
PM *Generar Solicitud* + objetos `*Estrategicas` (closure2). Universo: 303 objetos (210 reglas, 93 interfaces).

- **HAND (16):** se rediseñan a mano; su SAIL referencia `recordType!{…}SCA solicitudAnulacion` o
  `SCA TareasPorPolizaAWS` (records que en SCA2 se sustituyen por el modelo Solicitud/Transicion/Tarea/Error).
- **DEFER (36):** referencian constantes `PROCESS_MODEL` o dependen transitivamente de objetos HAND/DEFER;
  esperan al batch B (PMs).
- **STOP (0):** ningún objeto usa `.relationships.`/`.actions.` sobre records copiados.
- **BATCH A (251)** copiados en orden topológico con reescritura SAIL: `rule!SCA_*` → `rule!SCA2_*` (solo si el
  objetivo está en el batch), `cons!SCA_*` → `cons!SCA2_*` (si la constante existe), `recordType!{uuid}` +
  `.fields.{fuuid}` remapeados a los UUIDs de los 11 record types migrados (uuid y nombre de campo).
- **Resultado: 148 creados, 103 con error.**
  - 72 — inputs con tipo CDT/WSDL (`SCAC_DS_*`, `*DTO`, …): la API de creación solo admite tipos built-in o
    `recordtype:datatype`; los tipos CDT son rechazados en todos los formatos probados → requieren ajuste manual
    o creación vía Designer/import.
  - 17 — cascada (`Invalid function rule!SCA2_*`): su dependencia falló por la causa anterior.
  - 14 — validación al evaluar con entradas nulas o errores internos de reglas `SCAC_*` referenciadas
    (a!toJson null, xpathsnippet null, documento inexistente…).
- **Referencias no mapeadas** (dejadas `SCA_*` a propósito y registradas en `sca2_batchA_plan.json.unmappedRefs`):
  `cons!SCA_DSE_TM_TRANSACTION`, `cons!SCA_INT_*` / `SCA_TXT_*` sin equivalente SCA2, y reglas `rule!SCA_*`
  externas al cierre (p.ej. `SCA_CMP_APIClients_Perfil`, `SCA_TipoFormaDeCobro`, `SCA_formaCobroPlanPago`).

Índice de objetos creados: `sca2_rules_ifaces.json`; respuestas individuales en `sca2_objects/`.

> Sin credenciales en este documento. Valores sensibles (hosts, usuarios, tokens) se redactaron en origen.
