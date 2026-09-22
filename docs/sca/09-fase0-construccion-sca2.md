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

## 7. CMD Alta, UI y site SCA2

### `SCA2 CMD Alta`

- UUID **`0000f06f-28fc-8000-6693-7f0000014e7a`** (PM recreado tras el wedge del `startForm`; el uuid
  anterior quedó inválido y la constante `SCA2_PM_CMD_ALTA` apunta al nuevo).
- **13 nodos**: Start → **Construir Contexto** (`SCA2_construirContextoAlta`, solo si
  `pv!datosContexto` viene vacío) → PreGenerar (`SCA2_PreGenerarStudAnul`) → Call Integration
  `SCA2_generarStudAnul` (host `cons!SCAC_VAL_HOST_CORE7`, endpoint
  `PCA_CORECFSA_HTTPRouter/IGenerarContraAnul`) → XOR Resultado:
  - error → Write `SCA2 Error` (`idSolicitud="PDTE-"&pp!id`, código `ALTA_ERROR`) → End;
  - OK → Contexto (`SCA2_actualizacionVariablesPostGenerarStudAnul` + `obtenerDatosCabecera` +
    `determinarCatalogacionRenovada`) → Write Datos (8 filas: DatosBasicos, DatosSolicitud,
    PerfilesPca, Poliza Autos/Hogar/Vida por línea, Productor, Niveles Cobertura Autos,
    OtrasSolicitudesCabecera, TrazabilidadCliente) → Write Solicitud (estado `ALTA`, version=1) +
    Transición → XOR PRRA → Write Motivos reales → Start async `SCA2 CMD Decidir(idSolicitud)` → End.
- **15 params escalares** (numPoliza, lineaNegocio, origen, origenPoliza, canal, idioma, rol,
  usuario, gestionSGC, motivoReal/detalleReal/causaReal, telefonoExpertos, isPolizaPRRA,
  datosContexto). Sin CDTs; `datosContexto` como `Any Type`.

### Corrección de idempotencia (comando literal)

`pp!name` incluye timestamp (`"SCA2 CMD Alta - 22/09/2026 12:07 CEST"`), así que la clave de
idempotencia y `Error.comando`/`Transicion.comando` nunca casaban entre reejecuciones ni con
`pmPorComando`. En los 5 PMs se sustituyó `pp!name` por el **literal del comando**
(`"SCA2 CMD Alta"`, …); `pmPorComando` y el check de Alta volvieron a igualdad exacta.
Verificado: con una Transición OK `SCA2 CMD Decidir|TEST-3D-1|1` sembrada, dos ejecuciones de CMD
Decidir salen por la rama "Ya ejecutado" sin duplicar.

### Constantes de proceso y reglas de soporte

- `SCA2_PM_CMD_ALTA/DECIDIR/CREAR_ACCION/COMPLETAR_ACCION/FINALIZAR` (type PROCESS_MODEL):
  `_a-…_20055436/…442/…448/…454/…460`.
- `SCA2_pmPorComando(comando)` `_a-…_20055466` — a!match literal → constante, default null.
- `SCA2_relanzarError(error)` `_a-…_20055472` — a!writeRecords estado→RELANZADO + resueltoPor +
  fechaResolucion.
- `SCA2_construirContextoAlta` `_a-…_20056014` — reconstruye `iniciarProcesoPCA` como Map desde
  `SCA2_consultarPolizas` + `SCA2_obtenerInformacionUsuario` (fallback CE_RM/CE_RM_OFICINA) +
  `SCA2_calculoCanalEntrada`/`SCA2_calculoMedioComunicacion` (portadas verbatim con constantes
  SCA2_*) + lógica original de `codTpOrigen` (impago→"1", motivo 3/1/2→"3"/"2"/"4") y
  `fecAnulacion` por catalogación.

### Interfaces y site

| Objeto | UUID | Función |
|---|---|---|
| `SCA2_AltaSolicitud` | `_a-…_20055666` | sección con los 14 campos + validación de póliza duplicada (estado<>FINALIZADA) |
| `SCA2_AltaSolicitudPage` | `_a-…_20055716` | página sin inputs; locals + botón SOLID → `a!startProcess(cons!SCA2_PM_CMD_ALTA, {15 params})` |
| `SCA2_DetalleSolicitud` | `_a-…_20055572` | compuesta: Cabecera `_a-…_20055493`, Datos `_a-…_20055499` (lazy), Tareas `_a-…_20055554` (form inline → CMD CompletarAccion), Transiciones `_a-…_20055560`, Errores `_a-…_20055566` (Relanzar por fila) |
| `SCA2_BandejaErrores` | `_a-…_20055578` | grid PENDIENTE + Relanzar (`pmPorComando` + `a!startProcess` + `SCA2_relanzarError`) |
| `SCA2_Buscador` | `_a-…_20055660` | grid Solicitud (filtros póliza/estado, orden modifiedAt desc) → detalle inline |
| Site `SCA2 Anulaciones` | `bb62c468-0f71-4985-980a-6db65a9dc1f5` | páginas `/buscador`, `/alta` (INTERFACE→Page), `/errores` — `…/suite/sites/sca2` |

- Vista "Resumen" de `SCA2 Solicitud` → `SCA2_DetalleSolicitud(rv!record…idSolicitud)`.
- Decisión: **bandeja de errores en pantalla** (sin correos; los PMs originales usaban Send E-Mail).

### Quirks del MCP/UI nuevos

- **`updateProcessModel startForm` bug**: cualquier write parcial deja el PM permanentemente roto
  (`'interfaceUuid'` en get/update/node-update) — la única vía es página INTERFACE +
  `a!startProcess`; si ocurre, delete+recreate el PM y actualizar la constante.
- Grids: `a!gridField`/`a!gridTextColumn` no validan `fv!row` en createInterface → usar
  `a!gridField_25r2`/`a!gridColumn` con `pagingSaveInto:`; acciones por fila con
  `a!richTextIcon`+`a!dynamicLink`.
- `a!buttonLayout` (no buttonArrayLayout); estilos SOLID/OUTLINE/GHOST/LINK;
  `a!queryFilter` rechaza value ""/null (fallback `id>0` o `if(isNullOrEmpty(x),"\u0001",x)`);
  `placeholder:` (no placeholderLabel); `a!richTextDisplayItem` no existe; `a!localVariables`
  admite una sola expresión final; `createExpressionRule`/`createInterface` aceptan `testInputs`
  indocumentados; `testProcessModel` máx. 60 s; `addRecordTypeView` funciona.

### Prueba con póliza PRE 0007051068625 → 0999 (STOP)

- La póliza es **wAutemis/Automóviles** (NISSAN QASHQAI, ramo 200, "POLIZA LIDER", prima 439,82)
  según `SCA2_consultarPolizas`; `pObtenerPolizaFecha`/`pBuscarPoliza` dan axis2 Internal Error.
- Tras reconstruir el contexto completo (mismo shape y valores que la cadena original —
  nuuma JJGONZ2, CE_RM/CE_RM_OFICINA, codInt 502332532025, claveProduccion 5282852,
  estructComercial 016/15/1507, motivo 2/detalle 7/causa 16 válidos, codTpOrigen "4",
  canalEntrada 1 PRESENCIAL, fecAnulacion 2025-07-01), `generarStudAnul` sigue devolviendo
  `soapenv:Server` **0999** → STOP definitivo: la póliza probablemente no es anulable en PRE
  (o el servicio aplica otra validación no visible). Body final en `alta_body_final.xml`.
- El PM se comporta correctamente: rama error → fila `SCA2 Error` ALTA_ERROR PENDIENTE, 0 filas
  Solicitud/Transición, PM COMPLETED. La rama OK (8 records + Decidir) queda **sin ejercitar**.

### Gaps pendientes

- Pantallas de acción reales (Autorización / Acc Adm / Contra Anulación) — no portadas; el form
  inline de DetalleTareas es un sustituto mínimo.
- `SCA2 CMD Mecanizar`, `SCA2 CMD Notificar`, Redirección Vida → fase 2.
- Rama OK de CMD Alta sin verificar end-to-end (falta póliza anulable).
- `SCA2_altaDocumento`/`SCA2_AltaGestionArgumento` en STOP de batch B; credenciales literales en
  `SCA2_APIClients_Login`/`SCA2_ObtenerCredencialesConceptos` pendientes de connected system.

## 8. Pantallas de acción y paridad visual

### Estilo SCA extraído

- Sites SCA (`SCA_Site`, `SCA Decidir Accion`): `layout: HEADER_BAR` + `style: MERCURY`
  (preset, sin colores/logo custom — branding por defecto, `documents/` vacío). Páginas con
  icono `f016`; página "Gestiones mantenimiento" condicionada a `SCA_isUsuarioProceso()`.
- Colores: `SCA2_VAL_COLOR_ROJO` #DF0027 (botones primarios), `GRIS_MEDIO` #9F9F9F
  (cancelar/secundario), `VERDE` #00E663. Cards `shape: ROUNDED` + `showShadow`, richText
  STRONG en cabeceras, `rule!SCA2_PieDePagina()` al final de todas las pantallas.
- Site `sca2` quedó con displayName "Sistema Comercial de Anulaciones", HEADER_BAR/MERCURY e
  iconos f016. "Gestiones mantenimiento" omitida (sin objeto destino en SCA2).

### Interfaces nuevas/actualizadas

| Interfaz | Uuid (sufijo) | Líneas | Origen SCA |
|---|---|---|---|
| SCA2_DocumentosAccion | …_xxxx | 37 | SCA_AccionesAdministrativasDocumentacion (1205 l., condensada) |
| SCA2_AnulacionFueraNormaPrincipal | … | 195 | SCA_AnulacionFueraNormaPrincipal (774 l.) |
| SCA2_AccionesAdministrativasPrincipal | … | 206 | SCA_AccionesAdministrativasPrincipalEstrategicas (734 l.) |
| SCA2_ContraAnulacionOpciones | … | 209 | SCA_ContraAnulacionOpciones (2228 l., condensada) |
| SCA2_ContraAnulacionPrincipal | … | 29 | SCA_ContraAnulacionPrincipal (164 l.) |
| SCA2_BuscarSolicitudClientePoliza | … | 27 | SCA_BuscarSolicitudClientePoliza |
| SCA2_BuscadorTabla | … | 34 | SCA_BuscadorTabla |
| SCA2_DetalleTareas (actualizada) | … | 78 | abre Principal por tipo de tarea |
| SCA2_Buscador (actualizada) | … | — | estructura SCA_BuscadorSolicitudPrincipal |
| SCA2_AltaSolicitudPage (actualizada) | …_20055716 | 240 | SCA_AltaSolicitudAnulacionEstrategicas |
| SCA2_BandejaErrores / Detalle* (actualizadas) | … | — | fix `fields:` en queries (ver hallazgos) |

Reglas nuevas: `SCA2_D_TiposGestiones`, `SCA2_D_ColorEstadoGestion`, `SCA2_posponerTarea`
(update Tarea.fechaCaducidad vía `SCA2_obtenerCaducidadNivel(nivel:"2")` +
Solicitud.contadorPosponer+1/fechaDietario — mismo cálculo que el original, como writeRecords
en lugar de las integraciones STOP).

### Contrato de las Principales (SCA2)

- Inputs: `idSolicitud`, `idTarea` (y opcional `sol` Map). Carga con
  `rule!SCA2_obtenerDatosCabecera(numPoliza, idSolicitud)` en a!localVariables.
- Las escrituras de la UI original se mantienen en la UI (NTT: la pantalla persiste):
  `insertarObservaciones` + `aceptarAutorizacion` / `guardar*` / `finalizarContraAnulPca`.
- Al terminar: `a!startProcess(cons!SCA2_PM_CMD_COMPLETAR_ACCION, {idSolicitud, idTarea,
  resultado: a!map(mcaEstadoFinal, codEstado, estadoFinalizar, finalizadoCA, …)})` —
  Autorización devuelve "S"/"N" con codEstado "2"/"5"; AccAdm "FINALIZADA"/"CANCELADO";
  CA "9" + finalizadoCA (cancelar → "3").
- **Posponer** (STOP en la original): `SCA2_posponerTarea` por writeRecords.
- `SCA2_DetalleTareas` abre la Principal por `tipo` (AUTORIZACION→FueraNorma,
  ACC ADM→AccAdm, CONTRA ANULAR→CA) en la misma sección; mini-form eliminado.

### Hallazgos técnicos (UI)

- **`a!queryRecordType` sin `fields:` devuelve proxies**: `index(fv!row, ref)`,
  `fv!row[ref]`, `property()` → null; `tostring` → `[SCA2 Solicitud id=18]`. Fix: pasar
  `fields: {…}` con refs `'recordType!{uuid}RT.fields.{fuuid}name'` — aplicado a todos los
  queries que alimentan grids o filas indexadas. Esto era la causa real de las celdas vacías
  (no `gridField_25r2` vs `_25r3`).
- **`typename()` no existe en el eval de interfaces**: cualquier local que lo use lanza y el
  refresh entero revierte al render inicial (borra campos). Sustituto seguro:
  `search("<codigo>", tostring(fv!item)) > 0` para distinguir strings XML de Maps.
- `a!gridField_25r3` + `a!gridColumn(label, value: index(fv!row, ref, null), sortField)` es
  el patrón correcto (como en SCA); acciones por fila con `a!linkField(links:
  {a!dynamicLink})` / `a!tagField` — el volcado `[@attributes…` desaparece con `fields:`.
- Cascada de dropdowns: `a!forEach` sobre la respuesta del servicio + `saveInto` con resets
  (`a!save(local!detalle, null)`), `disabled` por dependencia.
- Playwright: navegar al site y click en ALTA (no URL directa); `fill()`+Tab para UNFOCUS;
  opciones de dropdown solo registran selección con `mouse.down()/up()` real en su bounding
  box (los clicks JS no disparan el save).

### Verificación en navegador (Playwright, CDP 29229)

- `/alta` con póliza real **0007051068625**: datos de póliza/cliente OK (POLIZA LIDER,
  wAutemis, ramo 200, prima 439,82€, ZAFIEF ZEXUPA CEJJADVEG / 34429061Q); dropdowns
  Motivo→Detalle→Causa en cascada (2 DESAPARICIÓN DEL RIESGO → 7 BAJA DE VEHÍCULO →
  {17 BAJA TEMPORAL, 16 BAJA VEHÍCULO, 18 SINIESTRO TOTAL}); GUARDAR habilita → click →
  mensaje "Solicitud enviada. Proceso: <ppid>"; Core7 devuelve 0999 → nueva fila
  `PDTE-268887523` ALTA_ERROR en la Bandeja de errores.
- `/buscador` → Ver → detalle inline con cabecera poblada; pestaña Tareas → Completar
  (tarea PENDIENTE AUTORIZACION) → pantalla de Autorización renderizada ("Revisión
  autorización de fecha de anulación", Oficina, Fecha anulación, Documentación,
  FINALIZAR/CANCELAR/POSPONER).
- Grids Buscador/Errores/detalle con valores reales y sin `[@attributes`.

| Captura | Muestra |
|---|---|
| ![alta_motivo_open](img/alta_motivo_open.png) | Desplegable Motivo con opciones |
| ![alta_ready](img/alta_ready.png) | Cascada motivo/detalle/causa seleccionada |
| ![errores_after](img/errores_after.png) | Bandeja con la nueva fila ALTA_ERROR del GUARDAR |
| ![autorizacion](img/autorizacion.png) | Pantalla de Autorización desde Completar |

### Condensaciones / STOPs

- `SCA2_ContraAnulacionOpciones` y `SCA2_DocumentosAccion` condensadas (originales de ~2-3k
  líneas): se conservan estructura de secciones, textos, colores y botones; omitidos los
  sub-flujos SGO (rehabilitar/descuentos), argumentario por URL y parte de los modales
  (disponibles como `SCA2_ContraAnulacionModal*` para enganchar).
- `a!startProcess`/`a!writeRecords` validados estructuralmente; el flujo Completar/Posponer
  end-to-end queda pendiente de una tarea real de cada tipo.
- Pendientes (actualizado en §9): Redirección Vida, `SCA2 CMD Notificar`
  y completar las pantallas condensadas; `SCA2 CMD Mecanizar`, Caducar y
  BarridoCaducidad ya implementados en §9.

## 9. CMD Mecanizar, Caducar y BarridoCaducidad

Análisis previo en `/home/ubuntu/sca-analysis/sca2_mecanizar_analysis.md` (subprocesos
`SCA Mecanizacion`, `SCA Alta Mecanización`, `SCA Finalizar Mecanización` y
`SCA Batch Caducidad`/`Previo`).

### PMs creados

| PM | UUID | Nodos | Parámetros |
|---|---|---|---|
| `SCA2 CMD Mecanizar` | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | 15 | idSolicitud, idTarea (opt), accion, mcaReservaPrima, importeRsvPrima, usuario |
| `SCA2 CMD Caducar` | `0000f06f-4f07-8000-670d-7f0000014e7a` | ~10 | idSolicitud |
| `SCA2 CMD BarridoCaducidad` | `0000f06f-4f69-8000-671e-7f0000014e7a` | 6 | (ninguno) |

Claves de idempotencia: `"SCA2 CMD Mecanizar|" & idSolicitud & "|" & nivelIntervencion`
(análoga para Caducar). Constantes `SCA2_PM_CMD_MECANIZAR`, `SCA2_PM_CMD_CADUCAR`,
`SCA2_PM_CMD_BARRIDO_CADUCIDAD`; `SCA2_pmPorComando` conoce ambos comandos; botón
"Mecanizar" (SOLID rojo) añadido a `SCA2_DetalleSolicitud`.

### Mapeo nodo-original → nodo-SCA2 (resumen)

| Original (SCA Mecanizacion) | SCA2 CMD Mecanizar |
|---|---|
| Flags polizaVigente/flagVerti/determinarContacto | nodo 16 Cargar (outputs flagVerti+contacto) |
| XOR caducada / VERTI / PRRA | XORs 4 (caducada→Write 5) y 6 (VERTI→Write 7: Tarea PENDIENTE + Transición PENDIENTE_HUMANO) |
| bloquearPoliza + consultarUltimaGestionREST | locales dentro de la consulta del nodo 8 |
| guardarMecanizacion (WS Core7) | calli 8 `SCA2_guardarMecanizacionIntegracion` → XOR 9 |
| crearAutorizacion | calli 10 → XOR 11 |
| insertarObservaciones ×4-6 | 1 sola llamada con texto compuesto (condensado) |
| Escrituras Tarea/Solicitud | Write Éxito 13 (MECANIZADA, mecanizacionRealizada, Tarea cerrada, Transición OK) |
| Reintentos ×3 internos | **no replicados** → Error PENDIENTE + relanzamiento por bandeja |
| receiveMessage ANL_Desbloquear (pausa) | **no implementado** |
| ANL Alta ×2 (subproceso otra app) | **STOP** — no llamar |
| SCA Finalizar Solicitud asíncrono | Start Process 14 → `cons!SCA2_PM_CMD_FINALIZAR` |
| SCA Batch Caducidad Previo (obtener+start por fila) | `SCA2 CMD BarridoCaducidad`: query estado∉{FINALIZADA,CADUCADA,ERROR} ∧ caducidadTarea<now() → Start Process Caducar por fila |
| SCA Batch Caducidad (finalizar una) | `SCA2 CMD Caducar`: XOR caducada→Write CADUCADA→calli finalizarSolicitud; no→SKIP |

### Verificación (filas TEST, póliza 0007051068625)

- Mecanizar: Core7 devuelve HTTP 500 (IMecanizarPCA) → rama de error correcta: Error row
  PENDIENTE (nodo "Guardar Mecanización"), Transición ERROR, Solicitud estado=ERROR +
  nodoRelanzar. Re-ejecución COMPLETED sin duplicar Transición.
- Caducar con caducidadTarea pasada → CADUCADA + Transición OK; con futura → SKIP;
  re-run → "Ya ejecutado" (COMPLETED).
- Barrido → COMPLETED, detectó la fila caducada (`lista: ["TEST-CAD-1"]`).
- Filas TEST borradas; Error/Transición conservados. Evidencia en
  `sca2_objects/pm/mecanizar_*.json`, `caducar_*.json`, `barrido_test*.json`.

### Bugs / lecciones MCP de esta tanda

1. `a!toJson(pv!err)` sobre IntegrationError lanza → usar `joinarray(tostring(pv!err)," | ")`.
2. Una regla con side-effect dentro de la lista `Records` produce un Number →
   "each item must be a record"; inyectarla como valor de campo con `a!localVariables`.
3. `ac!Result` es HttpResponse: `mapSalidaRespuesta*` necesita `ac!Result.body` y debe
   guardarse con `if(ac!Success,…)` para no parsear el cuerpo de error.
4. `ProcessParameters` del Start Process exige dict; para multi-instancia pasar
   `{idSolicitud: pv!lista}` (lista como valor del parámetro).
5. Reejecución con Transición ERROR/SKIP ya existente violaba la unicidad de
   `claveIdempotencia` → la Transición se escribe solo si no existe (guard), y el XOR
   "Ya ejecutado" de Caducar acepta `resultado in {"OK","SKIP"}`.
6. `updateProcessModelNode` con `data` parcial borra el resto del nodo: reenviar
   siempre inputs+outputs+customOutputs completos.

### STOPs y pendientes

- Reintentos ×3 y `receiveMessage` ANL_Desbloquear no portados (bandeja de relanzamiento).
- ANL Alta ×2 no llamadas (otra app).
- Rama de éxito de Guardar Mecanización/CrearAutorización sin ejercitar (Core7 PRE
  responde 500 a todas las integraciones, como el 0999 del Alta) — pendiente repetir
  con una póliza anulable.
- Rama VERTI no ejercitada (flagVerti=false con la póliza de prueba).
- Pendientes globales: Redirección Vida, `SCA2 CMD Notificar`, placeholders
  Variables/Batch del menú de gestiones, y credenciales literales en
  `SCA2_APIClients_Login`/`SCA2_ObtenerCredencialesConceptos` pendientes
  de connected system. Las pantallas condensadas se completaron en la sección 10.

## 10. Pantallas completas de acción y Gestiones mantenimiento (tanda 5)

Se completa la lógica que se condensó en tanda 4b, con paridad UX/UI SCA (textos,
orden de secciones, cards, colores `#DF0027`/`#9F9F9F`/`#00E663`, iconos, botones
SOLID rojo/gris, `SCA2_PieDePagina`), y la pantalla de acción pasa a ocupar la
página completa como en SCA.

### Objetos nuevos

| Interfaz SCA2 | uuid | Líneas | Origen SCA |
|---|---|---|---|
| `SCA2_ContraAnulacionArgumentarioEstrategicas` | `...20060043` | 144 | `SCA_ArgumentosContraAnulacionEstrategicas` (grid Orden/Argumento/Obligatorio/Argumentario SCAC/Aplicación URL/Estado tag/Usuario/Fecha, selección de fila) |
| `SCA2_ContraAnulacionSGO` | `...20060093` | 133 | `SCA_ModalTréboles` port verbatim a cardLayout (`a!dialogLayout_17r2` no existe) + ModalRetos/ModalSVA/ModalSVAEmail |
| `SCA2_ContraAnulacionRehabilitacion` | `...20060049` | 50 | `SCA_ModalRecuperacionPoliza` + link NSE + ModalInformativo |
| `SCA2_ContraAnulacionDescuentos` | `...20060055` | 20 | `SCA_ModalDescuentosVida` + ModalInformativo |
| `SCA2_ContraAnulacionCompaniaCatalogacion` | `...20060061` | 200 | `SCA_CompañaContrariaCatalogacion` (compañía + popup búsqueda + RECARGAR ARGUMENTO + tipo catalogación + fecha) |
| `SCA2_AccionesAdministrativasDocumentacion` | `...20060475` | 189 | `SCA_AccionesAdministrativasDocumentacion` (1205→189): grid docs + borrar + AÑADIR (tipo/nombre/upload a `SCA2_FLD_ACCION_ADMINISTRATIVA`) + GUARDAR + observaciones + "No se entrega documentación" |
| `SCA2_MecanizacionPrincipal` | `...20060481` | 164 | `SCA_DetalleAnulacionMecanizacionEstrategicas` (900→164): datos gestión + Reserva prima + observaciones + MECANIZAR (`a!startProcess` `cons!SCA2_PM_CMD_MECANIZAR` con accion/mcaReservaPrima/importeRsvPrima) / CANCELAR / POSPONER |
| `SCA2_GestionMantenimientoMenu` | `...20060073` | 127 | `SCA_GestionMantenimientoMenu`: nav lateral 5 opciones → GestionArgumentos/GestionConceptos/GestionAplicacion (reales) + placeholders Variables/Batch |

Actualizadas: `SCA2_ContraAnulacionOpciones` (451 l., flujo POSITIVO completo),
`SCA2_DetalleTareas`, `SCA2_AccionesAdministrativasPrincipal`,
`SCA2_DetalleSolicitud` (layout pantalla completa), site `sca2` (página nueva).

### Flujo POSITIVO/NEGATIVO de Contra Anulación

En `SCA2_ContraAnulacionOpciones`, al pulsar POSITIVO con 1 argumento seleccionado:
`insertarObservaciones` → `estadoArgumentos` → `modificarCatalogacion` →
`estadoContraAnul` "3" → dispatch de regateo según campaña/tipo (252/254/365 →
SVA, 286/287 → Retos, resto → Tréboles) → recuperación (`obtenerEstadoPoliza`
= "A" → `altaSGORehabilitar`) → descuentos (358/356 → `altaSGOVida`/`altaSGO`).
NEGATIVO → `guardarEjecuArg`. El cierre llama `SCA2 CMD CompletarAccion` con el
mismo Map de resultado (`mcaEstadoFinal`, `estadoFinalizar`, `finalizadoCA`…).

### Layout pantalla completa

`SCA2_DetalleSolicitud` gana `local!accionAbierta/tipoAccion/idTareaAccion`
(pasados como rule inputs a `SCA2_DetalleTareas`, cuyos `saveInto` escriben
ri! → parent local). Con `accionAbierta` se muestra SOLO la Principal + enlace
"VOLVER AL DETALLE" (GHOST rojo, icono arrow-left); cabecera/datos/tareas/
transiciones/errores ocultas y `PieDePagina` una sola vez. El link "Completar"
de la grid guarda los tres inputs; VOLVER los resetea y el detalle se
refresca. Tipos `MECANIZACION` y `VERTI` abren `SCA2_MecanizacionPrincipal`.

### Site

Página "Gestiones mantenimiento" añadida al site `sca2` (tipo INTERFACE →
`SCA2_GestionMantenimientoMenu`, `webAddressIdentifier gestiones-mantenimiento`,
icono `f016`, `visibilityExpr =rule!SCA2_isUsuarioProceso()` — misma regla que
SCA). Renderiza menú lateral con Gestión de argumentos/conceptos/aplicación
(interfaces reales ya portadas) y placeholders para Variables/Batch.

### Verificación

- `testInterface` 12/12 OK (`sca2_objects/ui/testInterface_t5.json`).
- Playwright (CDP 29229) con filas TEST (tareas CONTRA ANULAR / ACC ADM /
  MECANIZACION): cada tipo abre su Principal; Documentación expandida con
  grid + AÑADIR; argumentario con columnas y POSITIVO/NEGATIVO deshabilitados
  ("Debe seleccionarse 1 argumento"); Gestiones mantenimiento renderiza.
- Layout fix verificado: Completar → solo la Principal + VOLVER AL DETALLE;
  VOLVER → detalle completo refrescado. Screenshots en
  `sca2_objects/ui/screens/tanda5_*.png`; referencias:

  | Captura | Contenido |
  |---|---|
  | `img/tanda5_layout_fix.png` | ContraAnulación a pantalla completa con "VOLVER AL DETALLE" |
  | `img/tanda5_mecanizacion.png` | `SCA2_MecanizacionPrincipal` (MECANIZAR/CANCELAR/POSPONER) |
  | `img/tanda5_gestiones.png` | Página "Gestiones mantenimiento" del site |

- Filas TEST borradas tras la verificación. Bug encontrado y corregido en vivo:
  las llamadas a modales se evaluaban sin flag y renderizaban "fantasmas" →
  todas envueltas en `if(flag, rule!..., "")`.

### STOPs / gaps de esta tanda

1. `SCA2_GetUrlArgumento` y `SCA2_AltaGestionArgumento` siguen STOP; la URL del
   argumentario usa `SCA2_IF_ArgumentoAplicacionUrl`.
2. Subprocesos "ANL Alta" no invocados (otra app).
3. Escrituras SGO (`altaSGO`, `altaSGORehabilitar`, `altaSGOVida`,
   `guardarEjecuArg`, `modificarCatalogacion`) son las reglas SCA2 ya portadas;
   no ejercitadas end-to-end porque los servicios Core7/SGO devuelven 500 en PRE.
4. Variables/Batch en Gestiones mantenimiento son placeholders (sin equivalente).
5. `SCA2_ContraAnulacionArgumentario` renombrado a `...Estrategicas` por
   colisión de nombre con un objeto previo (patrón del original).
6. Condensación residual: validaciones por campo y algunos popups dedicados del
   original (2228 l.) quedan cubiertos por los modales genéricos.
