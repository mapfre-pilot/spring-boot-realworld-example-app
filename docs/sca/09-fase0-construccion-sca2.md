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

## 5. Batch B — sustitución de CDTs e integraciones propias

**Decisiones del usuario**

- SCA2 **no usa CDTs**: los datos se modelan con record types SCA2 o con `Map`.
- SCA2 tendrá **integraciones propias** (no llamadas `rule!SCAC_*Integracion`): reutilizan los connected
  systems de SCAC como dependencia (mismo `connectedSystemUuid`; no se copian credenciales) y aceptan `Map`.
- En las integraciones SOAP el body se conserva tal cual: `toxml(type!{ns}CDT(...))` permanece dentro del
  body como dependencia de tipos existentes (no se crean CDTs).
- Las reglas referenciadas desde integraciones se replican en SCA2 las de SCA/SCAC
  (`SCA2_APIClients_Login`, `SCA2_ObtenerCredencialesConceptos`, `SCA2_obtenerUserPassSimularPoliza`);
  `rule!CMP_*` / `rule!PGM_*` quedan como dependencia cross-app.

### Tabla CDT → record type / Map

| CDT origen | Destino SCA2 |
|---|---|
| `SCAC_DS_solicitudAnulacion` | record type `SCA2 Solicitud` (o `Map` si accede a campos ausentes) |
| `SCAC_DS_datosCabecera` | `SCA2 Datos Cabecera` / `Map` |
| `SCAC_DS_datosSolicitud` | `SCA2 Datos Solicitud` / `Map` |
| `SCAC_DS_datosBasicosSolicitud` | `SCA2 Datos Basicos Solicitud` |
| `SCAC_DS_datosPerfilesPca` | `SCA2 Datos Perfiles Pca` |
| `SCAC_DS_datosPolizaVida` | `SCA2 Datos Poliza Vida` |
| `SCAC_DS_datosPolizaAutos` | `SCA2 Datos Poliza Autos` |
| `SCAC_DS_datosPolizaHogar` | `SCA2 Datos Poliza Hogar` |
| `SCAC_DS_producersData` | `SCA2 Datos Productor` |
| Cualquier otro CDT (DTOs WSDL PCA/SGC, `CargaGestion*`, `*Response`, resto `SCAC_DS_*`, `SCA_DS_*`) | `Map` |

Regla de decisión: el input usa el `typeReference` del RT **solo si todos los campos accedidos en el SAIL
(`ri!x.campo`) existen en el RT**; si no, `Map` con `missing_fields` anotado. Casos con campos ausentes
(input → campos que faltan en el RT):

- `SCA2_setDatosGestionDatosPoliza`: `solicitudAnulacion` → `datosCompletosSolicitud`, `datosPerfilesPca`
- `SCA2_setDatosGestionSGC`: `solicitudAnulacion` → `datosPoliza`; `datosCabecera` → `datosCliente`
- `SCA2_posponerAccAdm`: `datosCabecera` → `datosCliente`, `datosPoliza`; `solicitudAnulacion` →
  `datosCompletosSolicitud`, `datosPolizaAutos`, `datosPolizaHogar`, `datosPolizaVida`
- `SCA2_posponerCA`: `datosCabecera` → `datosCliente`; `solicitudAnulacion` → `datosCompletosSolicitud`
- `SCA2_posponerAutorizacion`: `datosCabecera` → `datosCliente`, `datosPoliza`; `solicitudAnulacion` →
  `datosCompletosSolicitud`, `datosPolizaAutos`, `datosPolizaHogar`, `datosPolizaVida`
- `SCA2_CargaGcOnline`: `solicitudAnulacion` → `datosPolizaAutos`

### Reescrituras aplicadas

- `'type!{ns}X'(...)` → `a!map(...)`; `cast(typeof('type!X'), v)` → `v` (266 ocurrencias, 57 objetos; 0 no cubiertas).
- `rule!SCAC_X` → `rule!SCA2_X` solo cuando el equivalente SCA2 ya está creado; si no, se conserva la
  referencia SCAC (pendiente = vacío al final).
- En integraciones: header values literales deben enviarse con comillas (`"*/*"`, `"text/xml"`).
- `validateExpression` ejecutado antes de cada create (solo diagnóstico: no puede stubbear `ri!`).
- `testInputs` funciona también en `createExpressionRule`/`createInterface` (no documentado en el schema):
  permitió crear las reglas EVAL que fallaban evaluando con inputs nulos.

### Contadores

- **Integraciones: 104 creadas** de 111 del cierre (+2 replicadas incluidas en ese total: `SCA2_APIClients_Login`,
  `SCA2_ObtenerCredencialesConceptos`) — 42 `direct_json`, 62 SOAP con body verbatim, 1 plugin AWS S3.
  **3 STOP:**
  - `SCA2_obtenerTokenRetosRESTIntegracion`, `SCA2_asignarRetosRESTIntegracion` — sin `connectedSystemUuid`
    en origen → decidir connected system o URL directa.
  - `SCA2_altaDocumentoIntegracion` — multipart requiere un Document de prueba que aún no existe en SCA2 →
    crear un documento/constante y reintentar.
- **Reglas/interfaces batch B: 92 de 103 creadas** (total SCA2: **240 objetos**, 148 batch A + 92 batch B).
  **11 STOP** (con causa y siguiente paso):
  - `SCA2_altaDocumento`, `SCA2_AltaGestionArgumento` — input `Document` sin valor de prueba posible →
    subir un documento a SCA2 y reintentar.
  - `SCA2_monitorizarSolicitud` — HTTP 500 "Name is insufficiently unique" (colisión fuera de SCA2) →
    localizar el objeto conflictivo o renombrar.
  - `SCA2_DatosPolizaDinamico` (+ cascada `SCA2_ObtenerMapaPoliza`) — acceso `ri!x['recordType!{u}.fields.f']`
    requiere un record real → decidir: consultar el record type o pasar estructura compatible.
  - `SCA2_guardarGestionSGC` (+ cascadas `SCA2_posponerAccAdm`/`posponerCA`/`posponerAutorizacion`) —
    comparación Null vs Integer interna no resoluble con testInputs → revisar la rama nula en origen.
  - `SCA2_GetUrlArgumento` — `sca2_consultarconceptoreutilizable` espera estructura CDT (index) → ajustar
    el callee a Map o tipar el input.
  - `SCA2_CargaGcOnline` — estructura WSDL `MSECargaGestionPCA` anidada no reproducible con `a!map` →
    reescribir a mano el acceso al payload.

### Dependencias que quedan hacia SCAC / CMP / PGM

- Constantes referenciadas (no copiadas): `SCAC_VAL_HOST_CORE7`, `SCAC_VAL_HOST_WEBSERVICES`,
  `SCAC_VAL_HOST_WMAPFRE`, `SCAC_VAL_USUARIO_ACCESO_SERVICIOS`, `SCAC_VAL_PWD_ACCESO_SERVICIOS`,
  `CMP_VAL_HOST_WEBSERVICES`, `SCA_WEBSERVICES_URL` (host y credenciales quedan como dependencia cross-app).
- Reglas cross-app: `rule!CMP_APIGW_newToken_TEST`, `rule!CMP_fechaHoraISO8601`, `rule!CMP_docABase64`,
  `rule!PGM_GenerateNonce`.

### Nota de riesgo

`SCA2_APIClients_Login` y `SCA2_ObtenerCredencialesConceptos` copian el body **verbatim** e incluyen
**credenciales literales en el cuerpo** (igual que las originales SCAC). Recomendado mover esas
credenciales al connected system o a constantes cifradas antes de promocionar fuera de DEV.

## 6. PMs atómicos CMD_* (fase 1: bucle Decisión/Acción)

Reimplementación del PM particionado "SCA Alta Solicitud Anulacion Particionado" como comandos
atómicos encadenados por `Start Process` **asíncrono**. Especificación: `sca-analysis/sca2_cmd_spec.md`.
Carpeta: `SCA2 Process Models` (`_g-0000f069-4ee2-8000-64c6-7f0000014e7a_711`).

### Process models

| PM | UUID | Nodos | Params | Escribe | Lanza (async) |
|---|---|---|---|---|---|
| `SCA2 CMD Decidir` | `0000f06f-0eab-8000-6595-7f0000014e7a` | 15 | `idSolicitud`, `regla` | Solicitud (DECIDIDA/destino), Transición, Error | `SCA2 CMD CrearAccion`; reintento a sí mismo (máx. 3) |
| `SCA2 CMD CrearAccion` | `0000f06f-0eaa-8000-6594-7f0000014e7a` | 15 | `idSolicitud` | Tarea (PENDIENTE+token+caducidad), Solicitud (EN_ACCION), Transición, Error | — |
| `SCA2 CMD CompletarAccion` | `0000f06f-1307-8000-65b1-7f0000014e7a` | 12 | `idSolicitud`, `idTarea`, `resultado` (Map) | Tarea (cierre), Solicitud (PDTE_FINALIZAR), Transición, Error | `SCA2 CMD Finalizar` |
| `SCA2 CMD Finalizar` | `0000f06f-1309-8000-65b3-7f0000014e7a` | 11 | `idSolicitud` | Solicitud (FINALIZADA/ERROR+nodoRelanzar), Error | — (Call Integration nodes) |

Las tres ramas humanas (AUTORIZACION*, ACCIONES ADMINISTRATIVAS*, CONTRA ANULAR*) comparten un único
camino Caducidad → Write Tarea+Solicitud+Transición, parametrizado por pv (tipo, interfazActiva, grupo).

### Convenciones comunes

- `idSolicitud` + params mínimos por comando; la carga del contexto la hace `rule!SCA2_cargarSolicitud`
  (Map con la forma del antiguo `SCAC_DS_solicitudAnulacion`, proyectado campo a campo con `fields:` explícito).
- Clave de idempotencia: `pp!name|idSolicitud|version` (`|idTarea` en CompletarAccion) vía
  `rule!SCA2_claveIdempotencia`.
- Toda mutación relevante persiste fila en `SCA2 Transicion` y, en fallo, en `SCA2 Error`
  (estado PENDIENTE/BLOQUEADO tras 3 intentos, `proximoIntento` +30 min).
- Encadenamiento solo por `Start Process` asíncrono (`IsSynchronous=false`): **0 User Input Task** y
  **0 subprocesos síncronos** en los 4 PMs (verify por `typeName` de nodos).

### Reglas de soporte creadas

| Regla | UUID | Rol |
|---|---|---|
| `SCA2_cargarSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | QueryRecordType ×9 → Map anidado name-keyed |
| `SCA2_claveIdempotencia` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054960` | `comando|idSolicitud|version` |
| `SCA2_contarErroresPendientes` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054966` | cuenta errores PENDIENTE para el comando |

### Mapeo PM particionado → CMD (según spec)

| Nodo particionado | CMD destino |
|---|---|
| Decisión reglas PRE (nodos 10/27, l.126) | `SCA2 CMD Decidir` (XOR Resultado: DETALLE / POPUP_SGO / ERROR×3) |
| "Mecanizar?" (nodo 7, l.73) | Decidir rama mecanizar → `PDTE_MECANIZAR` (Write DestinoMecanizar, fase 2) |
| "Acción?" (nodo 9, l.78) | `SCA2 CMD CrearAccion` (XOR con 6 condiciones + default ERROR) |
| Resultado tarea / Cancel? (l.126/l.139-145) | `SCA2 CMD CompletarAccion` |
| FINPCA (`0002ec12-be50`, 44 nodos) / FINSGC (`0002ec01-93cd`, 15) | `SCA2 CMD Finalizar` como Call Integration directas (`SCA2_finalizarSolicitudIntegracion`, `SCA2_cargaGestionSGC3`) — no portables a reglas (timers+subprocesos) |

### Resultados de verificación (TEST-SCA2-000)

- `validateDesignObject`: `hasErrors=false` en los 4 PMs.
- **CrearAccion AUTORIZACION** → COMPLETED: fila Tarea PENDIENTE (token `TK-<pid>-<ts>`,
  caducidad +1d vía `SCA2_obtenerCaducidadNivel`), Solicitud DECIDIDA→EN_ACCION, Transición OK.
- **CompletarAccion** (resultado `mcaEstadoFinal="9"`) → COMPLETED: Solicitud → PDTE_FINALIZAR.
- **Finalizar** → COMPLETED: la integración PCA falla contra el host (id ficticio, esperado) →
  `pv!err` persistido, `SCA2 Error` FINALIZAR_ERROR, Solicitud → ERROR con `nodoRelanzar`.
- Cleanup: filas Solicitud/Tarea de test borradas; filas Error/Transición conservadas como evidencia.

### Quirks del MCP (relevantes para siguientes tandas)

- `createProcessModel` crea ya Start(id 1)/End(id 2); `assignment` es obligatorio en
  `createProcessModelNode` para Script/Write/StartProcess/XOR.
- Un XOR con >1 flujo sin reglas invalida el PM y bloquea creates posteriores → crear con 1 flujo,
  luego `updateProcessModelNode` con `connections`+`decision` juntos.
- Start Process referencia el PM destino por **id numérico interno** (`idToOpen`), params por
  `customInputs` con el nombre del pv destino.
- Records dentro de Maps: el query necesita `fields:` explícito y proyección a `a!map` name-keyed;
  las condiciones XOR no evalúan fiable `index(index(pv!sol,…))` anidado → pvs escalares
  (`accionCalc`…) computados en `customOutputs` (solo ligan `ac!x` si el input es type **Map**, no Any Type).
- `uuid()` no existe → token `"TK-"&pp!id&"-"&text(now(),…)`; `a!toJson` no serializa IntegrationError
  → `joinarray(tostring(pv!err)," | ")`.

### STOPs y gaps

- Subprocesos Notificar/DUE (`0002ecbb-30a0`) y NotificarError (`0002ec04`): contienen Send E-Mail /
  subprocessos → **no portables a reglas**; pendiente un futuro `SCA2 CMD Notificar`.
- `SCA2_monitorizarSolicitud` sigue en STOP de batch B (colisión de nombre).
- Mecanizar / Redirección Vida: sin comando aún → Decidir escribe `PDTE_MECANIZAR` sin lanzar nada (fase 2).
- Gaps menores: `pdteAutorizar` no existe en SCA2 Solicitud (condición null-safe); motivo/detalle
  "reales" del cambio de nivel no persisten (sin pv fuente); cambio de asignación usa `grupo=perfil`
  como fallback; "Borrar registros BBDD" del particionado no se porta (histórico conservado).
