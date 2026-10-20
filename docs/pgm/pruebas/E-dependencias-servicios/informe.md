# Área E — Dependencias técnicas y requisitos para probar la nueva aplicación con servicios reales

Sesión: https://mapfre.devinenterprise.com/sessions/c75f07f5969244418a7d5ad6e85e05cf · Rama: `devin/pgm-pruebas-E-dependencias-servicios` · Fecha de análisis: 2026-10-20 · Entorno analizado: Appian **TEST** (`mapfrespain-test`), aplicación `PGM_MAPFRE` (`_a-0000e700-629a-8000-9bc5-011c48011c48_1927060`).

> **Esta área no recorre pantallas.** Todo lo que sigue procede de la lectura de los objetos de diseño por la API LCP (`/objects`, `/connected-systems/{uuid}`, `/integrations/{uuid}`, `/constants`, `/expression-rules`, `/process-models`, `/web-apis`, `/groups` + `/groups/{uuid}/members`, `/record-types`, `/data-stores`, `/interfaces`) y del inventario previo (`docs/pgm/inventario/*`, `docs/pgm/02-analisis-tecnico.md`, `docs/pgm/03-mapeo-api-canal.md`). No hay capturas: la configuración de los connected systems se ha leído en JSON, no en Designer. La «matriz pantalla/acción» pedida en el contexto común se sustituye aquí por la matriz **capacidad funcional → servicio origen → API Canal → Gateway → BFF** (§4), que es el equivalente para esta área.
>
> **Secretos:** no se copia ningún valor de usuario, contraseña, client secret, API key ni token. Se indica únicamente el nombre de la credencial/constante/vault y quién debe aportarla.

## 0. Resumen ejecutivo

- Appian PGM habla con **30 connected systems** (LCP devuelve 30, no los 33 del inventario previo; ver §1.1) y **211 integraciones** (208 leídas; 3 no serializables por LCP, §1.3). Todas las integraciones son `system.http`; 16 son SOAP/XML sobre ESB, el resto REST/JSON.
- Las credenciales reales **no están en la mayoría de connected systems**: 56 integraciones no tienen CS y 19 (PGO) usan un `Bearer` tomado de constantes. Hay **cinco esquemas de autenticación** distintos que el BFF debe reproducir vía API Gateway (§2).
- El NUUMA del usuario es la clave de todo lo comercial (iMediador, SGC 3.0, PGO, estructura, Click2Call). En TEST se obtiene de `CMP_obtenerNuuma(loggedInUser())`, salvo para miembros de `PGM_Alertas` o la lista `PGM_CONS_USUARIOS_NEGOCIO`, que reciben el NUUMA fijo de pruebas **`JZAHONE`** (§7.2). Esto explica los bloqueos de *Gestiones*/*Actividad comercial* del usuario `devin` y cómo reproducirlos en el BFF.
- API Canal cubre (con `confidence: low`, specs en borrador) clientes, pólizas, recibos, siniestros y ventas Salud. **No cubre** PGO, SGC 3.0, iMediador, BDEC, SGO, Click2Call, Citrix, catálogos WL/ESB, teCuidamos, consentimientos (CDC), ACI, DPVE/Exstream, Verti/Neurona ni Cliente Total: todo eso debe salir del BFF por rutas `/legacy/...` del Gateway (§4-§5).
- Datos de prueba: tres documentos verificados en TEST contra los servicios reales (`15930307R`, `01076564A`, `98064151V`, §6). No se ha podido construir la lista de 10-20 documentos por capacidad sin invocar servicios de negocio; se deja el método y lo que falta.
- **Incidencia a declarar (§6.4):** una evaluación LCP de la regla `PGM_respuesta_search_webApi` (que se creía de solo lectura) escribió 3 filas en la caché técnica `PGM_R_cliente_record_postgres` de TEST. No afecta a datos de negocio; la caché se purga automáticamente.
- La checklist accionable por responsable está en `requisitos-pruebas-servicios.md`.

## 1. Inventario técnico (verificado por LCP)

### 1.1 Objetos de la aplicación

| Tipo | LCP | Comentario |
|---|---|---|
| CONNECTED_SYSTEM | 30 | El inventario previo decía 33. Diferencia **no conciliada**: hipótesis más probable, los 3 restantes son CS de otra aplicación (`CMP_*`, `TM_*`) referenciados por PGM pero no incluidos en el paquete; LCP `/objects?appUuid=` solo lista objetos del paquete. Pendiente de confirmar en Designer. |
| INTEGRATION | 211 | 208 definiciones leídas; 3 fallan (§1.3). |
| WEB_API | 9 | Solo metadatos (alias, método); LCP no devuelve la expresión SAIL de una Web API. |
| PROCESS_MODEL | 127 | Definición descargada; análisis de consumo de integraciones por `rule!` (§5). |
| EXPRESSION_RULE | 332 | Descargadas y analizadas para mapeos y consumidores. |
| INTERFACE | 566 | Descargadas solo para localizar consumidores de integraciones. |
| CONSTANT | 545 | Endpoints, scopes, grupos, flags (§2.4, §7). |
| RECORD_TYPE / DATA_STORE | 17 / 4 | Caché de cliente, borradores, cuadro de mando, registros (§6.2). |
| GROUP | 21 | Con miembros (§7.1). |

Paginación real de LCP: `limit` máximo efectivo **50** aunque se pida 200.

### 1.2 Connected systems

Tabla completa en el **Anexo A** (nombre, base URL actual, tipo de autenticación, nombre de la credencial sin valor, nº de integraciones). Puntos relevantes:

- **Todas las base URL de los CS apuntan a PRE** (`*.pre.mapfre.net`, `apisb.mapfre.net:25003`, `*.pre.mapfredigitalhealth.com`, `sgc3-pre-keyvault`): el Appian TEST consume el entorno **PRE** de los legacy. No existe en el paquete una configuración separada TEST/PRE; los valores PRO solo aparecen en constantes concretas (`PGM_ENDPOINT_CITRIX_PRO` = `virtualappspro.mapfre.net:27010`) y en descripciones. **URLs PRO no verificadas** para el resto.
- Autenticación por CS: Basic (10: Portal Interno, BDEC, Clients EDGE, Clients EDGE Recibos/Denodo, Life Risk API ×2, MotorAPI Login, Pre-registro ACI, WMAPFRE, iMediador EDGE, iMediador AltaNGA, SCDG); OAuth 2.0 client credentials (5: `PGM BFF`, `PGM Client API`, `PGM Motor API`, `PGM_KeyVault_SGC3.0`, `PGM_SGC3.0`, `PGM_WebApi_SGC_Prueba`); API key (1: `PGM loopback appian`); JDBC (1: `PGM PostgreSQL AWS`); **None** (los demás: WLCatalog/ESB, Citrix, Health API 1.0/2.0, Integraciones, Comercialización NSE, ConectaOrange, MapfreDigitalHealth, NeuronaVerti, BFF TOKEN). «None» en el CS no significa sin autenticación: la credencial viaja en cabeceras construidas por expresión (§2).
- El usuario Basic de los legacy MAPFRE (EDGE, Portal Interno, BDEC, Denodo, WMAPFRE, SCDG, iMediador) es el **mismo usuario de aplicación** (`APPUPGM`, nombre visible en el CS; contraseña no copiada). Dueño: equipo PGM/OT Appian.
- CS de pruebas/duplicados a no migrar: `PGM PGM Life Risk API DUPLICADO`, `PGM_WebApi_SGC_Prueba` (sin base URL).

### 1.3 Integraciones

Tabla completa (211) en el **Anexo B**, agrupada por capacidad, con método, URL/ruta, query, body, inputs, uso y consumidores. Hallazgos:

- `bodyType`: vacío 97, `application/json` 74, `application/xml` 17, `auto-detect` 10, form-urlencoded 6, `text/xml` 2, `text/plain` 1, `application/soap+xml` 1. **16 integraciones SOAP** (ESB `wICatalog`, `ESTRUAGE`, SGO `wmbig2is`, siniestralidad, GESYC recibos, core7 gestiones, `informacionUsuario_grupos`, Neurona Verti, LifeAPI duplicados, InduccionVerti).
- **3 integraciones no verificadas** (LCP HTTP 500 «Failed to convert body expression to display form: Unmatched open bracket [»): `PGM_BFF_Token`, `PGM_DPVE_GenerarDocumentacion`, `PGM_ExstreamDocumentation_comunication_V2`. Su método/ruta sólo consta en el inventario previo (`integraciones.csv`); hay que leerlas en Designer.
- **Consumidores**: 139 integraciones se invocan por `rule!` desde reglas, procesos o interfaces; **69 no tienen invocación directa** (lista en Anexo B con «0»). Son candidatas a obsoletas o de pruebas (p. ej. toda la familia `PGM_ClientsAPI_*` directa a `apisb`, sustituida por `PGM_ClientsEDGE_*`; `PGM_SignatureManagemen_*`; `PGM_TeCuidamosAPI_*`; `PGM_ServiciosRecibos_*`; `PGM_Click2Call`; `PGM_API_HOME_*`). Antes de darlas por muertas hay que comprobar si algún proceso las referencia por nodo «Call Integration» (LCP no serializa esa referencia de forma uniforme): **no verificado**.
- `(sin CS)`: 56 integraciones llevan la URL completa en la propia integración, construida con `cons!PGM_ENDPOINT_*`/`cons!PGM_HOST_*` (ESB, Denodo, SGO, wmbig2is, core7, webvida, lambdas AWS de Citrix).

## 2. Autenticación, cabeceras y URLs por entorno

### 2.1 Cinco esquemas de autenticación que el BFF/Gateway debe reproducir

| # | Esquema | Dónde se usa en Appian | Cómo lo hace Appian | Credencial (nombre) / propietario |
|---|---|---|---|---|
| A | **OAuth2 password+client en API Gateway MAPFRE** (`apisb.mapfre.net:25003/auth/oauth/v2/token`) | Clients API, Health API 1.0/2.0, Motor API, Home API, ACI, Integraciones (`esp/srv/api/...`) — todas las integraciones «(sin CS)» con `Authorization: Bearer rule!PGM_getTokenApiGW(...)` | `PGM_getTokenApiGW(username, password, clientId, clientSecret, scope, tipo)` → `PGM_APIGW_newToken` (grant password + cliente) con caché y `PGM_APIGW_refreshToken`. Motor: `PGM_getTokenMotorAPI` → `PGM_MotorAPI_newToken` (Basic contra `/auth/authorize/login`, devuelve `token`/`refreshToken`). | `PGM_USR_APP_FMA_PGMAPPIAN` / `PGM_PSS_APP_FMA_PGMAPPIAN` (usuario de aplicación), `PGM_CLIENTID_CLIENTS_HEALTH` / `PGM_CLIENTSECRET_CLIENTS_HEALTH`, scopes `PGM_SCOPES_CLIENTS`, `PGM_SCOPES_CLIENTS_ACI`, `PGM_SCOPES_HEALTH`, `PGM_SCOPES_MOTOR`, `PGM_SCOPE_HOMEAPI`, `PGM_SCOPE_MOTORAPI`. Propietario: Arquitectura API Gateway (apisb) + equipo PGM. |
| B | **OAuth2 client credentials en plataforma Digital Health** (`apioauth.platform.pre.mapfredigitalhealth.com/o/token/`, scope `api-pgm openid`) | PGO/`PGM BFF` (`api-pgm.digital.private.pre.mapfredigitalhealth.com:26033`) y las 19 integraciones `PGM_MapfreDigitalHealth` (`clientes.private.pre...:26030`) con `Authorization: "Bearer " & cons!...` | CS `PGM BFF` (OAuth CC) + integración `PGM_BFF_Token` (no verificada) que guarda el token en constante. | `PGM_CONS_AUTH_TOKENBFF_CLIENTID` / `PGM_CONS_AUTH_TOKENBFF_CLIENT_SECRET`. Propietario: equipo PGO / Digital Health. |
| C | **Entra ID client credentials + NUUMA cifrado** (SGC 3.0) | 16 integraciones `PGM_SGC30_*` (`sgc.es.pre.azure.mapfre.com`) | CS `PGM_SGC3.0` OAuth CC contra tenant Entra `93ad25dd-…` con scope `api://app-sgc3-appian-pgm/.default`; el NUUMA viaja cifrado: `PGM_encriptarNuuma_SGC30` → CS `PGM_KeyVault_SGC3.0` (tenant `5cc6c66d-…`, `keys/appian-pgm/encrypt`) → base64url → query `preferredUsername`. | App registration `app-sgc3-appian-pgm` (client id/secret en el CS), Key Vault `sgc3-pre-keyvault`. Propietario: equipo SGC 3.0 + Entra ID. |
| D | **Basic con usuario de aplicación** | Clients EDGE (`webservices.pre.mapfre.net:26004`), Portal Interno/BDEC/iMediador/AltaNGA (`wportalinterno.pre:26001`), Denodo (`denodo-prep:26014`), WMAPFRE, SCDG, Life Risk | Credencial del CS, `isPreemptive: true`. | Usuario `APPUPGM` (contraseña en el CS). Propietario: cada dueño de legacy debe autorizar al nuevo consumidor (BFF/Gateway). |
| E | **Sin autenticación de aplicación / sesión del propio usuario** | ESB SOAP (`wICatalog`, `ESTRUAGE`, SGO, GESYC, core7) con `Host` explícito; Citrix (login con usuario/contraseña del propio usuario + cookies `CsrfToken`, `ASP.NET_SessionId`, `CtxsAuthId`, `CtxsDeviceId`); Neurona Verti (usuario SGC `PGM_USR_NEURONA`/`PGM_PSS_NEURONA`); Click2Call Broadsoft (`bwctc.conecta.orange.es`, sin auth en CS; cabeceras no verificadas por falta de consumidor). | Confianza por red (ESB) o credenciales del usuario final. | SRE/red: alta del origen (Gateway) en ESB/firewall. Citrix: no reproducible desde BFF sin el password del usuario → candidato a lanzadera pura. |

Además: `PGM loopback appian` usa API key Appian (`PGM_APIKEY_*`) para llamar a las Web APIs de la propia PGM (§5.1).

### 2.2 Cabeceras

Cabeceras observadas (recuento en Anexo B). Las que el Gateway/BFF deben propagar o fijar:

- `Accept-Language: es-ES` / `es_ES`, `Accept: application/json`, `Content-Type: application/json` (REST); `Content-Type: text/xml; charset=UTF-8`, `SOAPAction: ""`, `Host: split(cons!PGM_ENDPOINT_x,"//")[2]` (SOAP ESB).
- Cabeceras de contexto MAPFRE en APIs `apisb`: `X-Request-applicationId: PGM`, `X-Request-applicationName: PGM`, `X-Request-companyId: PGM` o `0511`, `X-Request-issueCompanyId: 0511`, `X-Request-distributionChannelCode: PGM`, `X-Request-distributionChannel: 100`, `X-Request-processId: 123456`, `X-Request-source: PruebasAppian`, `X-Request-internalUser: rule!PGM_ObtenerNuuma()`. **Nota:** varios valores son literales de prueba (`123456`, `PruebasAppian`) incrustados en TEST; hay que preguntar a cada API qué valores exige en PRE/PRO.
- `Authorization: Bearer …` construido por expresión (esquemas A y B). Se ha visto **un JWT literal** incrustado en una integración de TEST: no se traslada aquí y debe rotarse.
- Citrix: `Csrf-Token`, `Cookie`, `ASP.NET_SessionId`, `CtxsAuthId`, `CtxsDeviceId`.

### 2.3 URLs por entorno

| Sistema | TEST (lo que usa Appian TEST = PRE legacy) | PRO | Fuente |
|---|---|---|---|
| API Gateway MAPFRE (apisb) | `https://apisb.mapfre.net:25003` (`PGM_ENDPOINT_APIS`, `PGM_ENDPOINT_API_CLIENTS`, `PGM_ENDPOINT_API_ACI`) y `https://apisb.mapfre.com` (Health) | no verificado | CS + constantes |
| Clients EDGE / MRC | `https://webservices.pre.mapfre.net:26004` (`PGM_ENDPOINT_WEBSEVICES`, `PGM_HOST_EDGE`) | no verificado | CS |
| Denodo (recibos EDGE) | `http://denodo-prep.es.mapfre.net:26014` (`PGM_ENDPOINT_DENODO`, `PGM_HOST_DENODO`) | no verificado | CS |
| Portal Interno / BDEC / iMediador | `https://wportalinterno.pre.mapfre.net:26001` (`PGM_ENDPOINT_WPORTALINTERNO`, `PGM_ENDPOINT_PORTAL_INTERNO`) | no verificado | CS |
| ESB SOAP | `https://esb.pre.mapfre.net:26005` (`PGM_ENDPOINT_ESB`, `PGM_HOST_ESB`, `PGM_HOST_APICatalogo`, `CMP_VAL_HOST_ESB`) | no verificado | CS + constantes |
| SGO | `PGM_ENDPOINT_SGO`, `PGM_ENDPOINT_WMBIG2IS` (wmbig2is PRE) | no verificado | constantes |
| Core7 / webvida / MISV | `PGM_ENDPOINT_CORE7`, `PGM_HOST_CORE7`, `PGM_ENDPOINT_webvida`, `PGM_HOSTYPUERTO_MISV` | no verificado | constantes |
| PGO / Digital Health | `https://api-pgm.digital.private.pre.mapfredigitalhealth.com:26033`, `https://clientes.private.pre.mapfredigitalhealth.com:26030`, token `https://apioauth.platform.pre.mapfredigitalhealth.com` | no verificado | CS |
| SGC 3.0 | `https://sgc.es.pre.azure.mapfre.com` (`PGM_ENDPOINT_SGC30`), KeyVault `https://sgc3-pre-keyvault.vault.azure.net/` | no verificado | CS |
| Citrix | `https://virtualapps.pre.mapfre.net:26009/Citrix/APIWeb/` (`PGM_ENDPOINT_CITRIX_PRE`) | `virtualappspro.mapfre.net:27010` (`PGM_ENDPOINT_CITRIX_PRO`) | constantes |
| Neurona Verti | `https://neurona-pre.verti.es.mapfre.net:26017` (`PGM_Host_Neurona`) | no verificado | CS |
| Click2Call | `https://bwctc.conecta.orange.es` | mismo host (no verificado) | CS |
| WMAPFRE (crosselling) | `https://wmapfre.pre.mapfre.net:26016` (`PGM_ENDPOINT_WMAPFRE`) | no verificado | CS |
| SCDG | `https://scgd.pre.mapfre.net:26012` | no verificado | CS |
| Appian loopback | `https://mapfrespain-test.appiancloud.com/suite/webapi/` (`PGM_ENDPOINT_APPIAN`) | PRO Appian (no aplica tras migración) | CS |
| BBDD Appian | JDBC `aws-rds-test.mapfre.es:5432/appianmapfredb` esquema `pgm_portalgestion` | no verificado | CS |
| Lanzaderas (URL, no API) | `PGM_URL_PGM`, `PGM_URL_FAS`, `PGM_URL_GESALUD`, `PGM_URL_LANZADERAS_GESALUD`, `PGM_URL_REGISTRO_ACCIONES_NUUMA`, `PGM_BASE_URL_WHATSAPP`, `PGM_LanzaderaSCA`, `PGM_CONS_LANZADERA_PILOTO_NSEi` (`apps.pre.mapfre.net/evt21_nsei_fe-web/...`) | no verificado | constantes |

### 2.4 Mapeo de respuestas (reglas `PGM_*` aguas abajo)

| Capacidad | Integración → regla de mapeo → tipo destino | Campos usados |
|---|---|---|
| Búsqueda | `PGM_ClientsEDGE_Search` → `PGM_FormatearBusquedaClienteEDGE` → `PGM_Cliente_ResultadoBusqueda` | `body.results[]`: `clientId, name, firstSurname, secondSurname, clientTypeCode, identityDocumentNumber, identityDocumentTypeCode, address{…}, birthdate, clientStateCode, segment…`; códigos `body.code` 4005 (varios), 5001 |
| Búsqueda por póliza | `PGM_R_ClientePorNumPoliza_Record` → `PGM_ClientsEDGE_Search(camposBusquedaAvanzada: {numeroPoliza})` → `results[1].clientId` → `PGM_R_getClientePorIdRecord` | — |
| Ficha (caché) | `PGM_R_getClientePorIdRecord(id)` = `a!queryRecordByIdentifier(PGM_R_cliente_record_postgres + clienteTemp + gdprbrand)`; `PGM_R_MapeoRecordCDT` → `PGM_Cliente` | 86 campos (ver §6.2) |
| Pólizas/recibos/prestaciones/presupuestos | `PGM_R_PolizasPorIdCliente_Record`, `PGM_R_RecibosPorIdCliente_Record`, `PGM_R_PrestacionesPorIdCliente_Record`, `PGM_R_PresupuestosPorIdCliente_Record` → `PGM_AgruparPolizas_Record`, `PGM_AgruparRecibos_Record`, `PGM_AgruparYFiltrarPrestaciones_Record`, `PGM_AgruparPresupuestos_Record` | listados EDGE `detailedPolicies`, `receipts`, `claims`, `projects` |
| Perfil SGC 3.0 | `PGM_ObtenerPerfilSGC3(nuumaEncriptado)` → `PGM_SGC30_Perfil` → `PGM_PerfilSGC3` | `body.profiles[]` (`profile, od, defaultProfile…`), `body.canReplicate` |
| Estructura comercial | `PGM_EstructuraComercialPorNUUMA(nuuma)` → `PGM_iMediadorEDGE_Perfil` → `PGM_EstructuraComercial` | `body.perfiles[]` (`idPerfil, delegado, oficina, idSubperfil, compañía`), `body.claves` |
| Enrutamiento PGO/iMediador | `PGM_enrutamientoNUUMA` → `PGM_DigitalHealth_EnrutamientoNUUMA` | `body.routing_system` |
| Roles | `PGM_MapearRolesUsuario` → `PGM_ObtenerGruposRest` (Portal Interno) → `body.groupsList.nombre`; `PGM_obtenerGruposIntegraciones` → SOAP `PGM_informacionUsuario_grupos` → `<grupos>` | — |
| Tokens | `PGM_getTokenApiGW` → `body.access_token`, `refresh_token`; `PGM_getTokenMotorAPI` → `body.token`, `body.refreshToken` | — |

## 3. Web APIs, process models y backend Appian (§3 del encargo)

### 3.1 Web APIs (9, todas `isPublic: false`)

| Web API | Método y alias | Propósito (inventario previo; expresión **no verificada**, LCP no la devuelve) | Quién la llama | Sustituto en la nueva arquitectura |
|---|---|---|---|---|
| `PGM_POST_write_record` | `POST /infoCliente` | Escribe en la caché `PGM_R_cliente_record_postgres` la ficha compuesta de un cliente | `PGM loopback appian` (`PGM_registrarConsultaModificacionPOST`, procesos) | Desaparece: el BFF compone la ficha en memoria/caché propia (`obtenerFichaCliente`). |
| `PGM_GET_consultar_cliente_record` | `GET /infoCliente` | Lee la caché de cliente | loopback | `obtenerFichaCliente`. |
| `PGM_POST_agendar_registro_operaciones` | `POST /registro` | Registro de operaciones/auditoría de acciones | loopback / procesos | `registrarAuditoria` (`POST /auditoria`). |
| `PGM_Get_FichaCliente` | `GET /fichaCliente` | Entrada externa (SGC/CRM) a la ficha por id | cuentas `PGM.SGC`, `PGM.CRM` (grupo `PGM Acceso APP No Appian SGC`) | Deep link SPA `/clientes/:id` protegido por Entra ID. |
| `PGM_IdCliente_NumeroDocumento` | `GET /accesoFicha` | Resolución documento → idCliente (`PGM_WebApi_numDocumento`, `PGM_respuesta_search_webApi`) | SGC/CRM | `buscarClientes` + redirección SPA. |
| `PGM_WebApiFichaPoliza` / `_V2` | `POST /5bESUw`, `POST /abrir-poliza` | Apertura de ficha de póliza desde sistema externo | SGC/CRM | Deep link SPA `/polizas/:numero`. |
| `PGM_WebApi_SGC` | `POST /abrir-ficha-SGC` | Apertura de ficha desde SGC 3.0 | `PGM.SGC` | Deep link SPA + claim de origen. |
| `PGM Test WSDL` | `GET /testWsdl` | Prueba | — | No migrar. |

### 3.2 Process models (127)

Clasificación del inventario previo (`inventario/modelos-de-proceso.md`), confirmada por nombres y por el análisis de consumidores: orquestadores de ficha (p. ej. `PGM_PM_OBTERNER_ACTIVIDAD_COMERCIAL`), procesos SOAP (SGO, ESB, GESYC), diálogos de usuario (alta de gestión/contacto/vencimiento, consentimientos, DNI, Cliente Total, ACI), mantenimiento de caché (`PGM_TM_ColaBorradoRecord` + `TM_QueueTransaction`, fuera de `PGM_CONS_INICIO/FIN_HORARIO_PROD`), navegación y pruebas/POC. Sustitución: la orquestación pasa a casos de uso del BFF (`FichaClienteUseCase`, `ContextoUsuarioUseCase`, `LanzaderasUseCase`, `AuditoriaUseCase`); los diálogos que **modifican** (alta gestión/actividad/vencimiento, consentimientos, firma, inducción, DNI/RGPD, ACI, Cliente Total, anulaciones, agrupaciones de recibos) **no tienen operación en el BFF actual** y quedan como lanzadera o gap (§4). **No verificado**: nodos internos de cada PM (LCP devuelve la definición pero no se ha analizado nodo a nodo).

## 4. Matriz capacidad funcional → servicio origen → API Canal → Gateway → BFF

Leyenda API Canal: specs `PROD-APICANAL-{CLIENTES,POLIZAS,RECIBOS,SINIESTROS,VENTAS}-001` leídas directamente del grafo KDD (`~/kdd/kdd-mapfre-docs/specs/products/`), todas `status: draft`, `version 0.2.0`, `confidence: low`, propietario «Equipo API Canal — <dominio> (PCC)». El CLI `spec-graph` no pudo ejecutarse (permiso denegado en el entorno). Estado BFF según `pgm-bff/sources/src/main/resources/openapi/pgm-bff.yaml` y `application.yml` (`pgm.gateway.rutas`).

| Capacidad | Servicio origen en Appian (CS + ruta) | API Canal equivalente | Ruta Gateway propuesta | Operación BFF | Estado | Para probar con servicios reales hace falta |
|---|---|---|---|---|---|---|
| Búsqueda de cliente | `PGM Clients EDGE` `POST /mrcconsultaback_int-web/api/1.0/clients/search` (Basic); legado `PGM Client API` `POST …/clients/1.0/clients/search` (OAuth A) | `GET /client/search` (CLIENTES, host `api-product-clients-lb.clientes.{dev,pre,pro}`) — parcial: Appian busca por nombre/apellidos/documento/email/póliza/teléfono con `limit`; la spec documenta búsqueda básica y «subs autorizados por endpoint» | `/api-canal/clientes` (fallback `/legacy/clients-edge`) | `buscarClientes` | cubierto (simulado) | Alta de suscripción del BFF en API Canal Clientes; confirmar criterios de búsqueda soportados (póliza, teléfono, tipo persona F/J); acceso Gateway→EDGE con usuario Basic como fallback |
| Ficha 360 (datos, direcciones, contacto, GDPR, familia, posición bancaria, integralidad, documentación digitalizada, crosselling) | EDGE `GET /MRCBack_be-web/api/1.0/client/{id}` y `/addresses`, `/contactMethods`, `/profile`, `/alerts`, `/interactions`, `/bankingPosition`, `/digitizedDocument`; WMAPFRE crosselling; CDC consentimientos (`PGM_ClientsEDGE_*Consentimientos*`); caché Postgres | CLIENTES: `/clients/individuals/:id` (+`/totalClient`, `/personalData`, `/mapfreDetail`, `/mapfreData`, `/integralityDiscount`, `/digitizedDocument`, `/checks`), `/clients/companies/:id`, `/clients/:id/{originsInfo,crosselling,bankingPosition,bankInfo}`, `contactMethods/*`, `/families/:id`, `/healthCards/:n/policyRoles`, `/catalogs/:name` | `/api-canal/clientes` | `obtenerFichaCliente` | parcial (consentimientos CDC y crosselling WMAPFRE sin API Canal) | Suscripción API Canal; definir campos de la ficha que el BFF compone (86 campos de la caché Appian, §6.2) frente a los que devuelve API Canal; dueño de CDC para consentimientos; WMAPFRE vía `/legacy/wmapfre` |
| Pólizas por ramo / detalle | EDGE `GET /client/{id}/detailedPolicies` (query `startDate`, `endDate`, `policyNumber`), `/client/{id}/policies` (carrusel), `/products`, `/productsDetail`; Home API `/esp/srv/api/home/2.0/policy/{p}/detail`; Motor API `/srv/api/1.0/motor/policy/{ref}/detail`; Vida `apisbcpolizas_int-web/api/life/1.0/individual/policy/{id}` (+`/unitLink`); Salud Health API `/individual/policy/{id}`; Hogar SOAP | POLIZAS `GET /companies/{c}/policies/{p}` (+`/type`, documentos), `/healthCards/by/number` (hosts `msapi-policy-lb.digital.{dev,pre}`); hecho Autos/Hogar/PDA/Salud, en curso Vida/mascotas/caza, pendiente decesos/accidentes/comunidades/comercios/RC. **Listado de pólizas por cliente**: no documentado en POLIZAS (la spec CLIENTES tampoco lo expone) → gap | `/api-canal/polizas` + `/legacy/clients-edge` para el listado | `listarProductosCliente`, `obtenerPoliza` | parcial | Confirmar con PCC el endpoint de listado por cliente; cobertura por ramo en PRE; `companyId` (`0511`) y canal; acceso a Motor/Home/Life API por Gateway si API Canal no cubre el ramo |
| Recibos (listado, detalle, impagados, PdP, duplicado, envío al banco, agrupaciones) | EDGE `GET /client/{id}/receipts` (`limit`, `policyNumber`, `startDate`); Denodo `GET /server/vfdc/client/views/receiptsDetail` (`user=admin`, `clientId`, `startDate`, `limit`); GESYC SOAP `consultarRecibo`; `PGM_ServiciosRecibos_EnvioAlBanco`, `_IOperarAgrupaciones` (MODIFY, sin consumidor directo) | RECIBOS (`msapi-receipts-lb.digital.*`): listado por póliza, detalle (Gesycore), PDF duplicado, PdP; **pagos por hacer**; búsqueda por NIF parcial; consumidor METS | `/api-canal/recibos`; `/legacy/clients-edge` para listado por cliente; `/legacy/gesycore` para operaciones | `listarRecibosCliente`, `listarRecibosPoliza`, `obtenerRecibo` | parcial (operaciones MODIFY sin BFF) | Listado por cliente en API Canal o EDGE; Denodo requiere `user` fijo y Basic; operaciones de cobro/agrupación fuera de alcance BFF v1 |
| Prestaciones / siniestros | EDGE `GET /client/{id}/claims` (`startDate`); `PGM_ConsultarDetalleSiniestro` SOAP (siniestralidad) | SINIESTROS: Hogar `GET …/accidents`, `/accidents/{id}`, `/proceedings`; Motor en curso (`/claims`) (`msapi-accident-{motor,home,catalog}-lb`) — listado por cliente multi-ramo no documentado | `/api-canal/siniestros` + `/legacy/clients-edge` | `listarPrestacionesCliente` | parcial | Endpoint de listado por cliente; cobertura Salud/Vida/Decesos; lanzaderas por ramo (`PGM_RAMOSLANZADERAPRESTACIONESHOGAR`) |
| Presupuestos | EDGE `GET /client/{id}/projects` (`internalUser=nuuma`) | No hay producto API Canal de presupuestos/proyectos → gap | `/legacy/clients-edge` | `listarPresupuestosCliente` | parcial | Acceso EDGE por Gateway; confirmar `internalUser` = NUUMA |
| Tarificación Salud | Health API 1.0/2.0 (`apisb.mapfre.com/esp/srv/api/health/{1.0,2.0}`): `/settings/commercialProducts`, `/settings/commercialProduct/{id}/coverages`, `/individual/simulation`, `/individual/policy/{id}`; borradores en `PGM BBDD Borradores` (`PGM_Query_TarificacionesUsuario`) | VENTAS (`msapi-commercialization-{health,motor,catalog}-lb`): `POST /1.0/health/quote`, `/resume`, `/verify/{offer}`, `/issuance/{offer}`, `/health/sign`, documentos | `/api-canal/ventas` | `tarificarSalud`, `guardarBorradorTarificacion`, `obtenerBorradorTarificacion` | cubierto (simulado); borradores en BBDD propia del BFF | Suscripción VENTAS Salud en PRE; catálogo de productos/coberturas; mapeo Appian↔quote; datos de prueba de asegurados |
| Oportunidades PGO / Digital Health | `PGM BFF` `GET /apipgo/client/opportunities`, `/opportunities/summary`, `/opportunity/{id}`, `POST …/observation`, `/attachment`; `PGM_MapfreDigitalHealth` (19): vencimientos salud, documentos, observaciones, enrutamiento NUUMA | Ninguno → gap | `/legacy/pgo` | `listarOportunidadesCliente` (lectura) | parcial (observaciones/adjuntos sin BFF) | Client credentials B para el BFF (nuevo client en `apioauth.platform`), NUUMA del usuario en cabecera/query, datos de oportunidades para los clientes de prueba |
| Gestiones SGC 3.0 | `PGM_SGC3.0` (16): `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` (listado, alta, cierre, reapertura, observaciones, documentos), `/sgc3-bk-users/api/1.0/user/profile` (`preferredUsername` cifrado) | Ninguno → gap | `/legacy/sgc30` (+ `/legacy/keyvault-sgc30` o cifrado en BFF) | `listarGestionesCliente` | parcial (altas/cierres sin BFF) | App registration Entra para el BFF con scope `api://app-sgc3-appian-pgm/.default` (o propio), acceso a Key Vault `sgc3-pre-keyvault` para cifrar NUUMA, **usuario de pruebas con perfil SGC 3.0** |
| Actividad comercial iMediador (SGC 2.0) | `PGM iMediador EDGE` (11): `/api/1.0/usuario/{nuuma}/perfil`, `/consultaContactos`, `/consultaGestiones`, `/consultaVencimiento`, `/catalogoAcciones`, altas de contacto/gestión/actividad/vencimiento; `PGM_iMediadorEDGE_AltaNGA` | Ninguno → gap | `/legacy/imediador` | `obtenerContexto` (estructura), `listarGestionesCliente` | parcial | Basic `APPUPGM` o nuevo usuario para el Gateway; NUUMA con perfil iMediador (en TEST `JZAHONE`) |
| Estructura comercial / BDEC / agente | `PGM BDEC API` (Portal Interno) claves y estructuras; SOAP `ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0` (`CMP_PostConsulta_consultarDatosAgente`); `PGM_ObtenerGruposRest` (Portal Interno `ARQ_SecurityServices`); SOAP `informacionUsuario_grupos` | Ninguno (CLIENTES tiene `remoteManagerInfo`, no estructura del usuario) → gap | `/legacy/bdec`, `/legacy/esb-estruage` | `obtenerContexto` | parcial | Acceso Gateway→Portal Interno (Basic) y →ESB (red); NUUMA de pruebas con estructura |
| SGO (solicitudes) | SOAP `wmbig2is` `ConsultarSolicitudes`, `ConsultarDocumentos`; lanzadera `PGM_AccesoSGO`; grupo `SGO Acceso Aplicación` | Ninguno → gap | `/legacy/sgo` | `listarSolicitudesSgoCliente` | parcial | Alta de red Gateway→SGO; WSDL/XSD del servicio (no incluido en Appian: body construido a mano) |
| Click2Call / WhatsApp | `PGM_ConectaOrange` `POST /com.broadsoft.xsi-actions/v2.0/user/{nuuma}/calls/callmenow`; WhatsApp = URL `PGM_BASE_URL_WHATSAPP` (lanzadera) | Ninguno | `/legacy/click2call` | `iniciarLlamada` | cubierto (simulado) | Autenticación Broadsoft (**no verificada**: CS sin auth, cabeceras no visibles por falta de consumidor directo); usuario Broadsoft = NUUMA |
| Consentimientos (CDC) | integraciones `PGM_ClientsEDGE_*Consentimientos*`/`PGM_ClientsEDGE_ActualizarPreferenciasContacto` (MODIFY), flag `PGM_MOSTRAR_WA`, grupo `PGM_UsuariosEvolutivoConsentimientos` | CLIENTES `contactMethods/preference` (parcial, lectura) | `/api-canal/clientes` + `/legacy/clients-edge` | — (sin operación BFF) | falta | Decidir si la nueva app modifica consentimientos; contrato CDC |
| Club MAPFRE / teCuidamos | `PGM_TeCuidamosAPI_ObtenerIdSocio`, `_TrebolesCliente` (sin consumidor directo; campos `trebolesDisponibles` en caché) | Ninguno | `/legacy/tecuidamos` | — | falta | Confirmar si sigue en uso |
| Catálogos WL / ESB | `PGM API WLCatalog` SOAP `wICatalog` (`PGM_APICatalogo_*`: argumentario, DPVE, roles, parámetros, póliza válida, SCA, URLs) | Ninguno (CLIENTES `/catalogs/:name` solo catálogos de cliente) | `/legacy/esb-catalog` | `listarLanzaderas` (parámetros/URLs) | parcial | Red Gateway→ESB; los catálogos de URLs de lanzaderas deberían pasar a configuración del BFF |
| Auditoría / registro de acciones | Web APIs `/registro`, `/infoCliente`; `PGM_URL_REGISTRO_ACCIONES_NUUMA`; data store `PGM Registros procesos` | Ninguno | interno BFF | `registrarAuditoria` | cubierto | BBDD propia del BFF; decidir si se replica a registro corporativo |
| ACI (área cliente) | `PGM Pre-registro ACI` `POST /esp/srv/api/aci/1.0/seguridad/login`, `/olvido/usuario/crear_cliente`; `PGM_ClientsAPI_Login_ACI`, `_UpdateToken_ACI` | Ninguno | `/legacy/aci` | — | falta | Scope `PGM_SCOPES_CLIENTS_ACI`; operación MODIFY (alta cliente ACI) |
| Cliente Total / DNI / RGPD / firma | `PGM_GET_ClienteTotal_Cargos`, `_Documentos`; `PGM_SignatureManagemen_*` (request/search/cancellation); DPVE/Exstream (no verificadas) | CLIENTES `/totalClient`, `/digitizedDocument` (lectura) | `/api-canal/clientes` + `/legacy/signature` | — | falta | Contratos de firma y documentación (no leídos por LCP) |
| Citrix / lanzaderas | `PGM Citrix API` `/Home/Configuration`, `/Authentication/GetAuthMethods`, `/PostCredentialsAuth/Login`, `/Resources/List`; lambdas AWS `PGM_CitrixAPI_*_AWS`; URLs `PGM_URL_*`, `PGM_LanzaderaSCA`, `PGM_CONS_LANZADERA_PILOTO_NSEi` | Ninguno | ninguna (lanzadera desde SPA) | `listarLanzaderas` | cubierto (config local `ConfigLanzaderasAdapter`) | Lista de URLs por entorno; Citrix exige credenciales del usuario final → no reproducible desde BFF |
| Inducciones (Verti/NSE/leads) | `PGM_NeuronaVerti_Login`/`_Inducir` (SOAP, usuario `PGM_USR_NEURONA`), `PGM_InduccionVerti_No_NSE`, `PGM_GestionarLeads_SAVIA_V2`, `PGM_ClientsAPI_Interaction_*` | VENTAS Motor (en curso) | `/legacy/neurona` | — | falta (MODIFY) | Fuera de alcance v1 |
| Cuadro de mando | data store `PGM Cuadro de Mando`, record `PGM Cuadro de mando`; grupo `PGM Visualizar CdM` | Ninguno | interno | `listarKpis` | cubierto (simulado) | Fuente de datos real de KPIs (BBDD Appian → BBDD BFF) |

## 5. Lo que debe publicar el API Gateway

Rutas ya previstas en `application.yml` (`pgm.gateway.rutas`): `/api-canal/{clientes,polizas,recibos,siniestros,ventas}` y `/legacy/{pgo,sgc30,imediador,bdec,clients-edge,sgo,click2call}`. A la vista del inventario faltan: `/legacy/denodo-recibos`, `/legacy/gesycore`, `/legacy/esb-catalog`, `/legacy/esb-estruage`, `/legacy/portal-interno` (roles), `/legacy/wmapfre`, `/legacy/tecuidamos`, `/legacy/aci`, `/legacy/keyvault-sgc30` (o cifrado delegado), `/legacy/health-api`, `/legacy/motor-api`, `/legacy/home-api`, `/legacy/life-api`. Para cada ruta el Gateway debe: terminar la autenticación del BFF (Entra ID client credentials), inyectar la credencial del legacy (esquemas A-D) y fijar las cabeceras `X-Request-*` acordadas con cada API. Hosts origen y puertos: §2.3.

## 6. Datos de prueba

### 6.1 Documentos verificados en TEST (servicios reales, 2026-10-20)

| Documento | idCliente | Qué tiene (observado) | Cubre |
|---|---|---|---|
| `15930307R` | 38859674 | Persona física, NIF, nacido 1985, casado, profesión ABOGADOS, CP 28019 (Madrid). Según contexto común: cliente con pólizas. | Búsqueda, ficha, pólizas |
| `01076564A` | 38903733 | Persona física, NIF; resto de datos personales vacíos en EDGE. Potencial. | Búsqueda, ficha de potencial (sin pólizas) |
| `98064151V` | 9198551 | Titular de la póliza `0007001170587` (valor de `cons!PGM_LanzaderaSCA`). Tipología **Platino**, `segmentoIntegralidad A`, `descuentoIntegralidad 8`, `clubMapfre true`, `rgpdFirmado true`, `aci ACTIVO` (último acceso 2026-03-18), `esVIP false`, Robinson 9/12 false, `clienteTotal false`, `codigoDocumentoDigitalizado 1` (sin documentación digitalizada), consentimientos Comercial/Vencimientos/Inducción con canales «no disponible», posición bancaria con tarjeta financiera, familia informada, `mapfreLinkDesc EMPLEADO`. | Búsqueda por póliza, ficha completa, integralidad, consentimientos, familia, posición bancaria |

No se ha verificado ningún documento con recibos impagados, prestaciones, presupuestos, oportunidades PGO, empresa (`clientTypeCode J`), VIP o Robinson: obtenerlos exige invocar servicios de negocio (EDGE `receipts`/`claims`/`projects`, PGO) para muchos clientes, lo que esta área no ha hecho. Método propuesto para completar la lista de 10-20 documentos: (1) ejecutar en TEST, con el usuario de pruebas y NUUMA `JZAHONE`, la búsqueda por apellido (`PGM_ClientsEDGE_Search`, `limit` 50) para «GARCIA», «LOPEZ», «MARTINEZ»; (2) por cada `clientId` llamar a `detailedPolicies`, `receipts`, `claims`, `projects` y `/apipgo/client/opportunities/summary`; (3) quedarse con los que cubran cada casuística. Alternativa sin red: pedir a PCC/EDGE la lista de clientes de pruebas de PRE.

### 6.2 Caché Appian como contrato de referencia de la ficha

`PGM_R_cliente_record_postgres` (86 campos) es la mejor descripción de lo que la ficha 360 necesita: `idCliente, documento, tipoDocumento, tipoPersona, estado, situacion, codTipoCliente, esVIP, listaRobinson_9/12, segmentoIntegralidad, descTipologia, categoria, aci, ultimoAccesoACI, clubMapfre, trebolesDisponibles/Gastados, rgpd, rgpdFirmado, rgpdInducir, listaGDPR, clienteTotal, descuentoIntegralidad, exclusivoCorredor, autonomoPotencial, grandesCuentas, empleadoMapfre, mapfreLinkDesc, antiguedad, susceptibleFamilia, familia, posicionBancaria, crosseling, codigo/descDocumentoDigitalizado, nuumaCarterizacion, gestorCarterizacion, nuumaReplicar, alertasconsentimientos*, canalConsentimientos{SMS,Telefono,Whatsapp,EnvioPostal,Email}, consentimientos{Comercial,Vencimientos,Induccion}, polizasSuperbonus, estadoSuperbonus, importeSuperbonus, encuesta (fecha, NPS, motivo, caducidad), datos de empresa (CNAE, facturacion, nempleados, fechaConstitucion…), dirección descompuesta`. `PGM_R_cliente_tmp` (37 campos) es la versión temporal. El simulador del BFF (`pgm-bff/sources/src/main/resources/local-data/*.json`, clientes `C-1001..C-1005`) debería incorporar, para los mismos casos, al menos: un Platino con integralidad y familia (`98064151V`), un potencial sin pólizas (`01076564A`), un cliente con pólizas multi-ramo (`15930307R`), y además (sin referencia real aún) un VIP, un Robinson, una empresa (J) con CNAE, un cliente con recibo impagado, uno con prestación abierta, uno con presupuesto y uno con oportunidad PGO.

### 6.3 Reglas útiles para localizar datos (solo lectura verificada)

`PGM_R_ClientePorNumPoliza_Record(numPoliza)` (búsqueda EDGE + lectura de caché, sin escritura), `PGM_R_getClientePorIdRecord(id)` (lectura de caché), `PGM_Query_CacheIdCliente(user)` (caché de ids por usuario: vacía para todos los usuarios consultados), `PGM_Query_TarificacionesUsuario(usuario, ramo, producto)` (borradores de tarificación).

### 6.4 Incidencia

La regla `PGM_respuesta_search_webApi(camposBusquedaSearch, camposBusquedaPosicionada, nuuma)` se evaluó por LCP para 3 documentos creyendo que solo buscaba. Su rama de «resultado único» hace `a!writeRecords` en `PGM_R_cliente_record_postgres`: se escribieron/actualizaron las filas 38859674, 38903733 y 9198551 (caché técnica, TEST). No hay dato de negocio alterado; la caché la purga `PGM_TM_ColaBorradoRecord`. Se deja constancia para el coordinador.

## 7. Seguridad y permisos

### 7.1 Grupos Appian (21) y efecto

| Grupo | Miembros en TEST | Constante | Efecto observado en reglas/constantes |
|---|---|---|---|
| `PGM_UsuariosTerritorio` | 184 (34 usuarios + grupos anidados `PGM_Admin`, `PGM_Alertas`, `PGM_APS`, `PGM_AdministracionClientes`, `PGM Usuarios Locust`…) | `PGM_GRUPO_ALLUSERS` | Acceso general al site. **`devin` no está** en él (accede por `PGM_AsesorComercial`): revisar visibilidades que dependan de ALLUSERS. |
| `PGM_AllUsers` | 186 | — | Grupo histórico equivalente. |
| `PGM_AsesorComercial` | 1 (`devin`) | `PGM_GRUPO_ASESORCOMERCIAL` | Perfil comercial básico. |
| `PGM_AsesorClientes`, `PGM_Delegado`, `PGM_GestorDelegado`, `PGM_DirectorComercial`, `PGM_APS`, `PGM_UsuarioCentral` (id 183), `PGM_TTT` (190) | 0 | `PGM_GRUPO_*` | Perfiles de visibilidad por rol; vacíos en TEST (los roles reales vienen de NUUMA/estructura). |
| `PGM Visualizar CdM` | 2 (`devin`, `MROYAM1`) | `PGM_GRP_VISUALIZAR_CDM` | Pestaña Cuadro de Mando. |
| `PGM_Alertas` | 7 usuarios (`GGALV10`, `ACOUTOA`, `ASERAF3`, `CBLASC2`…) + `PwC DEV Team` | `PGM_GRUPO_ALERTAS` | En no-PROD fuerza NUUMA `JZAHONE` (§7.2). |
| `PGM Piloto Captura WEB` | 185 | `PGM_PilotoCapturaWEB_Group` | Piloto captura web (≈ todos). |
| `PGM_Grupo_PilotoFrontal_NSEi` | 3 (`EGUERR`, `GDMARCO`, `JZAHONE@mapfrenopro`) | `PGM_CONS_PUNTERO_GRUPO_PILOTO_NSEi` | Lanzadera piloto NSEi. |
| `PGM_UsuariosEvolutivoConsentimientos` | 12 | `PGM_CONS_USER_EVOLUTIVOCONSENTIMIENTOS` | Evolutivo consentimientos. |
| `PGM Acceso APP No Appian SGC` | `MROYAM1`, `PGM.CRM`, `PGM.SGC` | — | Cuentas de servicio que invocan las Web APIs. |
| `PGM_Admin` | `ot.pruebas`, `PGM.SGC` | — | Administración. |
| `PGM Audit` | 189 | — | Auditoría. |
| `PGM Usuarios Locust`, `PGM2 usuarios`, `PGM2 administradores` | 0 / anidados | — | Pruebas de carga / histórico. |
| Externos referenciados | — | `PGM_SGO_AccesoAplicacion` (`SGO Acceso Aplicación`), `PGM_FAS_ALL_USERS`, `PGM_GR_RM_USUSARIOS` | Acceso SGO, FAS, RM. |

### 7.2 NUUMA, perfil SGC 3.0 y estructura comercial

- `PGM_ObtenerNuuma()`: si el entorno no es PROD y `loggedInUser()` ∈ `cons!PGM_GRUPO_ALERTAS` o ∈ `cons!PGM_CONS_USUARIOS_NEGOCIO` (lista de usuarios de negocio de pruebas: `MABELT`, `JOSEFVA`, `fruesca`, `gpetra`…) devuelve **`JZAHONE`**; en otro caso `CMP_obtenerNuuma(usuario)` (correspondencia usuario Appian → NUUMA corporativo). `devin` no cumple ninguna condición y no tiene NUUMA corporativo → sin estructura, sin perfil SGC 3.0, sin iMediador/PGO.
- Perfil SGC 3.0: `PGM_encriptarNuuma_SGC30` (Key Vault) → `PGM_SGC30_Perfil` → perfil por defecto + `canReplicate`. Estructura: `PGM_iMediadorEDGE_Perfil(nuuma)` → perfiles (idPerfil, delegado, oficina, subperfil, compañía) + claves. Enrutamiento PGO vs iMediador: `PGM_DigitalHealth_EnrutamientoNUUMA` → `routing_system`.
- Flags por entorno (constantes): `PGM_mostrarPGO=true`, `PGM_mostrarDPVE=false`, `PGM_CONS_VAL_MOSTRAR_SGC=true`, `PGM_Mostrar_ExclusivoCorredor=false`, `PGM_MOSTRAR_CAMBIOS_CARRUSEL=true`, `PGM_MOSTRAR_WA=true`, `PGM_CONS_MOSTRARPDP=true`, `PGM_CONS_MOSTRAR_SOLUCION_GLOBAL=2026-06-15 07:00` (fecha de activación de nueva producción), `PGM_USUARIOSCOLAPSADO` (lista de usuarios con menú colapsado).

### 7.3 Qué hace falta en Entra ID para reproducirlo en el BFF

El BFF valida JWT de Entra ID (tenant `93ad25dd-8cdc-4066-9727-31a8a3024f80`, audience `c4d0e5f0-4a24-4b89-a577-bd2c809f972a`, scope `pgm.acceso`, claim `groups`) y resuelve perfil (`Perfiles`, `Visibilidades`, `FeatureFlags`, `AutorizacionService`). Para equivaler a Appian hacen falta:

1. Grupos Entra (o app roles) equivalentes a `PGM_UsuariosTerritorio`, `PGM_AsesorComercial`, `PGM_AsesorClientes`, `PGM_Delegado`, `PGM_GestorDelegado`, `PGM_DirectorComercial`, `PGM_UsuarioCentral`, `PGM_APS`, `PGM Visualizar CdM`, `PGM_UsuariosEvolutivoConsentimientos`, `PGM_Grupo_PilotoFrontal_NSEi`, `PGM Piloto Captura WEB`, `SGO Acceso Aplicación`, emitidos en el claim `groups` (o `roles`).
2. Un claim con el **NUUMA** del usuario (atributo de directorio o extensión; Appian lo obtiene por `CMP_obtenerNuuma`), o un servicio de correspondencia UPN→NUUMA accesible por el BFF (`obtenerContexto`).
3. Un usuario de pruebas en el tenant con NUUMA real con perfil iMediador/SGC 3.0 y estructura comercial (en TEST, `JZAHONE` o los de `PGM_CONS_USUARIOS_NEGOCIO`), más un usuario sin NUUMA para reproducir los bloqueos.
4. App registration del BFF con client credentials para SGC 3.0 (scope `api://app-sgc3-appian-pgm/.default` o uno propio) y acceso al Key Vault; otra para el API Gateway si así lo exige SRE.
5. Feature flags del BFF equivalentes a las constantes de §7.2.

## 8. Lo verificado y lo no verificado

| Verificado por LCP | No verificado (causa) |
|---|---|
| 30 CS con URL/auth; 208 integraciones con método, URL, query, headers, body, inputs, uso; 332 reglas; 127 PM (definición); 21 grupos con miembros; 17 RT; 4 DS; 545 constantes; 9 Web APIs (metadatos) | 3 integraciones (LCP 500); expresiones de las Web APIs (LCP no las devuelve); nodos internos de los PM; los 3 CS que faltan hasta 33; URLs PRO salvo Citrix; autenticación de Click2Call; cabeceras exigidas por cada API en PRO; si las 69 integraciones sin consumidor directo se usan desde nodos de proceso |
| Specs API Canal leídas (5 productos + `ARCH-APICANAL-001`) | Contratos API Canal reales (specs `confidence: low`, borrador); endpoint de listado de pólizas/recibos/siniestros por cliente |
| 3 documentos de prueba contra EDGE real | Documentos con impagados, prestaciones, presupuestos, oportunidades, empresa, VIP, Robinson |
| Reglas de NUUMA/SGC3/estructura/token | `CMP_obtenerNuuma` (fuera del paquete PGM) |

## 9. Ficheros de esta área

- `docs/pgm/pruebas/E-dependencias-servicios/informe.md` (este documento, con Anexos A y B)
- `docs/pgm/pruebas/E-dependencias-servicios/requisitos-pruebas-servicios.md` (checklist por responsable y prioridad)
- `docs/pgm/pruebas/E-dependencias-servicios/casos.csv` (casos de verificación por LCP; sin recorrido de UI)

---
## Anexo A — Connected systems (30 objetos devueltos por LCP)

| Connected system | Base URL (TEST, valor actual del CS) | Autenticación | Credencial (nombre, sin valor) | Nº integraciones | Descripción |
|---|---|---|---|---|---|
| PGM API Portal Interno | `https://wportalinterno.pre.mapfre.net:26001/` | Basic | username=APPUPGM, isPreemptive=True | 2 |  |
| PGM API WLCatalog | `https://esb.pre.mapfre.net:26005/ARQ_CATALOG_SMEDWeb/sca/wICatalog` | None | — | 3 | Sistema conectado para el acceso al catálogo ARQ_CATALOG_SMEDWeb/sca/wICatalog |
| PGM BDEC API | `https://wportalinterno.pre.mapfre.net:26001` | Basic | username=APPUPGM, isPreemptive=True | 1 | Conexión con la API de BDEC que permite la consulta de claves y estructuras comerciales de un agente |
| PGM BFF | `https://api-pgm.digital.private.pre.mapfredigitalhealth.com:26033` | OAuth Client Credentials Grant | clientId=<redactado>, clientSecret=<redactado>, tokenUrl=<redactado>, scope=api-pgm openid | 10 | Sistema conectado que apunta al BFF |
| PGM BFF TOKEN | `https://apioauth.platform.pre.mapfredigitalhealth.com` | None | — | 0 | Sistema conectado para la obtención del token necesario para los servicios del BFF |
| PGM Citrix API | `https://virtualapps.pre.mapfre.net:26009/Citrix/APIWeb/` | None | — | 5 | Conexión con la lanzadera de aplicaciones del Portal de Mediadores  Endpoint PRE: https://virtualapps.pre.mapfre.net:26009/Citrix/APIWeb/ En |
| PGM Client API | `https://apisb.mapfre.net:25003/esp/srv/api/clients/1.0` | OAuth Client Credentials Grant | clientId=<redactado>, clientSecret=<redactado>, tokenUrl=<redactado>, scope=esp:clients/basicInfo:read esp:clients/contactMethod esp:cl | 1 | Contiene información relativa a clientes (consulta, ficha cliente)  Scope: esp:clients/basicInfo:read esp:clients/extendedInfo esp:clients/a |
| PGM Clients EDGE | `https://webservices.pre.mapfre.net:26004` | Basic | username=APPUPGM, isPreemptive=True | 52 | Sistema que conecta con el API EDGE de Clientes |
| PGM Clients EDGE Recibos | `http://denodo-prep.es.mapfre.net:26014` | Basic | username=APPUPGM, isPreemptive=True | 3 | Sistema que conecta la máquina del API EDGE de Clientes que contiene la información de los recibos |
| PGM Health API | `https://apisb.mapfre.com/esp/srv/api/health/1.0` | None | — | 5 | Contiene información relativa a pólizas de salud (consulta, tarificación)  Scope: esp:health/commercialization:simulation esp:health/commerc |
| PGM Health API 2.0 | `https://apisb.mapfre.com/esp/srv/api/health/2.0` | None | — | 0 | "esp:health/commercialization:insuranceApplication","esp:health/commercialization:policy", "esp:health/commercialization:simulation","esp:he |
| PGM Integraciones | `https://apisb.mapfre.net:25003/` | None | — | 8 |  |
| PGM Life Risk API | `https://webservices.pre.mapfre.net:26004` | Basic | username=APPUPGM, isPreemptive=True | 3 | Connected sistem del API de Life Risk scopes: esp:life/commercialization ,  esp:life/commercialization:delete , esp:life/commercialization:s |
| PGM Motor API | `https://apisb.mapfre.net:25003/srv/api/1.0/motor/` | OAuth Client Credentials Grant | — | 0 | Sistema conectado para las llamadas del api motor |
| PGM MotorAPI Login | `https://apisb.mapfre.net:25003/auth/authorize/login` | Basic | username=APP-FMA-PGMAPPIAN, isPreemptive=True | 1 |  |
| PGM PGM Life Risk API DUPLICADO | `https://webservices.pre.mapfre.net:26004` | Basic | username=APP-FMA-PGMAppian, isPreemptive=True | 1 |  |
| PGM PostgreSQL AWS | `no informada` |  | connectionUrl=jdbc:postgresql://aws-rds-test.mapfre.es:5432/appianmapfredb?currentSchema=pgm_portalgestion, username=user_pgm_portalgestion, maxConnections=50,  | 0 | CS de acceso a la BBDD de AWS |
| PGM Pre-registro ACI | `https://apisb.mapfre.net:25003/esp/srv/api/aci/1.0/seguridad/login` | Basic | username=APP-FMA-PGMAPPIAN, isPreemptive=True | 2 |  |
| PGM WMAPFRE | `https://wmapfre.pre.mapfre.net:26016` | Basic | username=APPUPGM, isPreemptive=True | 1 |  |
| PGM iMediador EDGE | `https://wportalinterno.pre.mapfre.net:26001/iMediador_be-web/sgc-imediador` | Basic | username=APPUPGM, isPreemptive=True | 11 | Sistema conectado con la API Edge que proporciona los servicios de iMediador |
| PGM loopback appian | `https://mapfrespain-test.appiancloud.com/suite/webapi/` | API Key | apiKeySendAs=<redactado>, apiKeyName=<redactado>, apiKeyValue=<redactado> | 3 | Sistema conectado que apunta al loopback de pgm |
| PGM_Comercialización_Seguros_NSE | `http://webservices.pre.mapfre.net:26004/` | None | — | 0 | Gestionar Comercialización Seguros NSE (REST) [1.0] |
| PGM_ConectaOrange | `https://bwctc.conecta.orange.es` | None | — | 1 |  |
| PGM_KeyVault_SGC3.0 | `https://sgc3-pre-keyvault.vault.azure.net/` | OAuth Client Credentials Grant | clientId=<redactado>, clientSecret=<redactado>, tokenUrl=<redactado>, scope=https://vault.azure.net/.default | 1 | Sistema para conexión con el KeyVault de SGC3.0 |
| PGM_MapfreDigitalHealth | `https://clientes.private.pre.mapfredigitalhealth.com:26030` | None | — | 19 | http://api-pgo-lb.clientes.dev.mapfredigitalhealth.com/swagger-ui/index.html |
| PGM_NeuronaVerti | `https://neurona-pre.verti.es.mapfre.net:26017` | None | — | 2 |  |
| PGM_SCDG | `https://scgd.pre.mapfre.net:26012` | Basic | username=APPUPGM, isPreemptive=True | 0 | scgd.pre.mapfre.net |
| PGM_SGC3.0 | `https://sgc.es.pre.azure.mapfre.com` | OAuth Client Credentials Grant | clientId=<redactado>, clientSecret=<redactado>, tokenUrl=<redactado>, scope=api://app-sgc3-appian-pgm/.default | 16 |  |
| PGM_WebApi_SGC_Prueba | `None` | OAuth Client Credentials Grant | clientId=<redactado>, clientSecret=<redactado>, tokenUrl=<redactado>, scope= | 0 | Prueba para SGC |
| PGM_iMediadorEDGE_AltaNGA | `https://wportalinterno.pre.mapfre.net:26001/sgc_bbe-web/sgc/` | Basic | username=APPUPGM, isPreemptive=True | 1 | Sistema conectado que se usa para dar el alta de un nga |

Integraciones sin connected system (URL completa en la integración, normalmente `cons!PGM_ENDPOINT_*`): **56**.

## Anexo B — Integraciones (211) por capacidad funcional

Columnas: método y URL/ruta tal y como están en la definición (`relativePath`/expresión); *query* y *body* resumidos; *inputs* = rule inputs; *uso* = QUERY/MODIFY declarado en Appian; *consumidores* = reglas (R:), modelos de proceso (PM:) e interfaces (I:) que la invocan por `rule!` (0 = no se encontró invocación directa: candidata a obsoleta o invocada por proceso/documento).


### Autenticación / tokens (11)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_APIGW_newToken` | PGM Integraciones | POST | `auth/oauth/v2/token` |  | application/x-www-form-urlencoded · "grant_type=password" & "&username=" & ri!username & "&password=" & ri | username:Text,password:Text,clientId:Text,clientSecret:Text,scope:Text | QUERY | 1: R:PGM_getTokenApiGW |
| `PGM_APIGW_refreshToken` | PGM Integraciones | POST | `auth/oauth/v2/token` |  | application/x-www-form-urlencoded · "grant_type=refresh_token" & "&client_id=" & ri!clientId & "&client_se | clientId:Text,clientSecret:Text,refreshToken:Text | QUERY | 2: R:PGM_getTokenApiGW, R:PGM_getTokenMotorAPI |
| `PGM_BFF_Token` | (no verificado: LCP 500) | ? | `no verificado` |  |  |  | ? | 0 |
| `PGM_CitrixAPI_GetAuthMethods` | PGM Citrix API | POST | `/Authentication/GetAuthMethods` |  | application/json |  | QUERY | 1: R:PGM_TestRespuestaXML |
| `PGM_CitrixAPI_LoginUsername` | PGM Citrix API | POST | `/PostCredentialsAuth/Login` | username=ri!username;password=ri!password | application/json | username:Text,password:Text,csrfToken:Text,sessionId:Text | QUERY | 1: R:PGM_ObtenerCredenciales |
| `PGM_ClientsAPI_Login` | (sin CS) | POST | `cons!PGM_ENDPOINT_APIS & "/auth/oauth/v2/token"` |  | x-www-form-urlencoded · "grant_type=password&" & "username=" & cons!PGM_USR_APP_FMA_PGMAPPIAN |  | QUERY | 0 |
| `PGM_ClientsAPI_Login_ACI` | PGM Pre-registro ACI | POST | `` |  | x-www-form-urlencoded |  | QUERY | 0 |
| `PGM_ClientsAPI_UpdateToken_ACI` | PGM Pre-registro ACI | POST | `` |  | x-www-form-urlencoded · "grant_type=refresh_token" & "&refresh_token=" & ri!refreshToken | refreshToken:Text | QUERY | 0 |
| `PGM_KeyVault_SGC3_Encriptar` | PGM_KeyVault_SGC3.0 | POST | `keys/appian-pgm/encrypt?api-version=7.4` |  | application/json · { "alg": "RSA-OAEP-256", "value":rule!CMP_toBase64(ri!nuuma) } | nuuma:Text | QUERY | 4: R:PGM_EncriptarNuuma, R:PGM_Prueba_Respuesta404, R:PGM_encriptarNuuma_SGC30 … |
| `PGM_MotorAPI_newToken` | PGM MotorAPI Login | POST | `` |  | application/x-www-form-urlencoded · "grant_type=password&" & "username=" & cons!PGM_USR_APP_FMA_PGMAPPIAN |  | QUERY | 1: R:PGM_getTokenMotorAPI |
| `PGM_NeuronaVerti_Login` | PGM_NeuronaVerti | POST | `/callcenter/WSSISNet` |  | text/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env |  | QUERY | 1: R:PGM_ObtenerLoginNeurona |

### Búsqueda de cliente (14)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_ClientsAPI_BusquedaClientes` | (sin CS) | POST | `cons!PGM_ENDPOINT_API_CLIENTS& "/clients/search"` |  | application/json · { "clientTypeCode": if( and( a!isNotNullOrEmpty(ri!cliente.nombre), a! | cliente:PGM_Cliente,camposBusquedaAvanzada:Any Type | MODIFY | 2: I:PGM_FormularioTarificacion_DatosTomador_v2, R:PGM_PrestacionesPorPoliza |
| `PGM_ClientsAPI_BusquedaClientes_Rendimiento` | (sin CS) | POST | `cons!PGM_ENDPOINT_API_CLIENTS&"/clients/search"` |  | application/json · { "clientTypeCode": if( and( a!isNotNullOrEmpty(ri!cliente.nombre), a! | cliente:PGM_Cliente,camposBusquedaAvanzada:Any Type | QUERY | 1: R:PGM_DPVE_ObtenerClientIdPorCIF |
| `PGM_ClientsAPI_PresupuestosClientePorDocumentoYNPpto` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/projects"` | budgetCode=ri!nPresupuesto;internalUser=ri!nuuma |  | nPresupuesto:Text,clientId:Text,nuuma:Text | QUERY | 1: R:PGM_ConsultarVencimientosPresupuestos |
| `PGM_ClientsEDGE_Search` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/clients/search` |  | application/json · { "clientTypeCode": if( and( a!isNotNullOrEmpty(ri!cliente.nombre), a! | cliente:PGM_Cliente,camposBusquedaAvanzada:Any Type,limit:Number (Integer) | QUERY | 7: I:PGM_Inicio, R:PGM_CompletarInfoCliente, R:PGM_Prueba_Respuesta404 … |
| `PGM_ClientsMediation_PresupuestosClientePorDocumentoYNPpto` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/projects"` | internalUser=ri!nuuma;budgetCode=ri!nPresupuesto |  | clientId:Text,nuuma:Text,nPresupuesto:Text | QUERY | 4: I:PGM_FichaCliente_v2, I:PGM_R_recordViewFichaCliente, R:PGM_Prueba_Respuesta404 … |
| `PGM_GET_ClienteTotal_Search` | PGM BFF | POST | `/api-pgm/clients/representedCompanies/search` |  | application/json · { "identityDocumentNumber": ri!documento, "name": ri!nombre } | documento:Text,nombre:Text | QUERY | 1: R:PGM_Mapeo_ResultadoBusqueda_EmpresaVinculadas |
| `PGM_GestionarSiniestroAutos` | PGM Clients EDGE | GET | `/es_aupr_atn_mets_be-web/api/2.0/autos/siniestro/search_by_exp` | idUsuario=rule!PGM_ObtenerNuuma();numExpediente=ri!numExpediente |  | numExpediente:Text | QUERY | 1: R:PGM_DetalleSiniestroPorExpediente |
| `PGM_GestionarSiniestroAutos_Prestacion` | PGM Clients EDGE | GET | `/es_aupr_atn_mets_be-web/api/2.0/autos/siniestro/prestacion/search_by_exp` | idUsuario=rule!PGM_ObtenerNuuma();numExpediente=ri!numExpediente |  | numExpediente:Text | QUERY | 1: R:PGM_DetalleSiniestroPorExpediente |
| `PGM_R_obtenerCliente` | (sin CS) | POST | `infoCliente` |  | application/json · { "idCliente": ri!idCliente, "camposBusquedaPosicionada": ri!camposBus | idCliente:Text,nuuma:Text,camposBusquedaPosicionada:Map,camposBusquedaSearch:Map,recargarF | QUERY | 0 |
| `PGM_SGC30_EstructuraDentroDeEstructura` | PGM_SGC3.0 | POST | `/sgc3-bk-business-tasks/api/1.0/external/structures/search` | preferredUsername=ri!nuumaEncriptado | application/json · { "idTask": ri!idTarea, /*"search": "fix"*/ } | nuumaEncriptado:Text,idTarea:Text | QUERY | 1: I:PGM_DetalleGestion30 |
| `PGM_SGC30_EstructuraFueraDeEstructura` | PGM_SGC3.0 | POST | `/sgc3-bk-business-tasks/api/1.0/external/structures/search/out` | preferredUsername=ri!nuumaEncriptado | application/json · { "idTask": ri!idTarea, "search": ri!search } | nuumaEncriptado:Text,idTarea:Text,search:Text | QUERY | 1: R:PGM_BuscadorEstructuraExternaSGC30 |
| `PGM_SignatureManagemen_Search` | PGM Clients EDGE | POST | `/consentimientos_be-web/api/1.0/consent/request/search` |  | application/json · { "process": "PRSAN-ALTA", "identityDocumentNumber": ri!identityDocume | identityDocumentNumber:Text | MODIFY | 0 |
| `PGM_SignatureManagemen_Search_Baja` | PGM Clients EDGE | POST | `/consentimientos_be-web/api/1.0/consent/request/search` |  | application/json · { "process": "PRSAN-BAJA", "identityDocumentNumber": ri!identityDocume | identityDocumentNumber:Text | MODIFY | 0 |
| `PGM_WebApi_numDocumento` | PGM loopback appian | GET | `accesoFicha` | numeroDocumento=ri!numDocumento |  | numDocumento:Text | QUERY | 0 |

### Ficha de cliente (datos, contacto, GDPR, familia) (77)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_APICatalogo_IntegracionesPoliza` | PGM API WLCatalog | POST | `` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | cia:Text,ramo:Text | QUERY | 7: I:PGM_FichaPoliza, I:PGM_FichaPoliza_DetalleAutos, I:PGM_FichaPoliza_DetalleGenerica … |
| `PGM_APICatalogo_ParametrosIntegracion` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/ARQ_CATALOG_SMEDWeb/sca/wICatalog"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | idAplicacion:Text | QUERY | 1: R:PGM_ConstruirLanzadera |
| `PGM_APICatalogo_URLIntegracion` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/ARQ_CATALOG_SMEDWeb/sca/wICatalog"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | codURL:Text | QUERY | 1: R:PGM_ConstruirLanzadera |
| `PGM_BFF_OperacionConsents` | PGM BFF | GET | `"/api-pgm/oneTrust/client/" & ri!idCliente& "/consents"` |  |  | idCliente:Text | QUERY | 1: R:PGM_R_getInfoCliente |
| `PGM_ClientsAPI_AvisosClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/alerts"` | applicationName=PGM |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_BankingPosition` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/bankingPosition"` | includeHistoryInd=ri!historico |  | clientId:Text,historico:Boolean | QUERY | 0 |
| `PGM_ClientsAPI_BeneficiosClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/benefits"` |  |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_CarterizacionClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/remoteManagerInfo"` | applicationName=PGM |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_DatosClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS& "/client/" & ri!clientId` |  |  | clientId:Text | QUERY | 1: R:PGM_DPVE_ObtenerRazonSocialporID |
| `PGM_ClientsAPI_DescuentoIntegralidadPorDocumento` | (sin CS) | POST | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/integralityDiscountPercent"` |  | application/json · { identityDocumentTypeCode: ri!documentTypeCode, identityDocumentNumbe | documentTypeCode:Text,documentNumber:Text | QUERY | 0 |
| `PGM_ClientsAPI_DireccionesClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS& "/client/" & ri!clientId & "/addresses"` |  |  | clientId:Text | QUERY | 3: I:PGM_Masdatos, R:PGM_ClientePorID_Completo, R:PGM_CompletarInfoCliente |
| `PGM_ClientsAPI_EDGE_AvisosClientePorId` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId &"/alerts"` | applicationName=PGM |  | clientId:Text | QUERY | 4: R:PGM_MapearAlertas, R:PGM_Prueba_Respuesta404, R:PGM_R_GetAlertasPorIdCliente_Report … |
| `PGM_ClientsAPI_EDGE_BankingPosition` | PGM Clients EDGE | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId & "/bankingPosition"` | includeHistoryInd=ri!historico |  | clientId:Text,historico:Boolean | QUERY | 4: R:PGM_Extraer_Resultado_BankingPosition, R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente … |
| `PGM_ClientsAPI_EDGE_CarterizacionClientePorId` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId &"/remoteManagerInfo"` | applicationName=PGM |  | clientId:Text | QUERY | 3: R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente, R:PGM_getInfoCliente_test |
| `PGM_ClientsAPI_EDGE_DatosClientePorId` | PGM Clients EDGE | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId` |  |  | clientId:Text | QUERY | 6: R:PGM_ClientePorID_Completo, R:PGM_ClientePorId, R:PGM_CompletarInfoCliente … |
| `PGM_ClientsAPI_EDGE_DescuentoVinculacion` | PGM Clients EDGE | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId & "/integralityDiscountDetail"` | applicationCode=PGM |  | clientId:Text | QUERY | 1: I:PGM_Detalle_DescuentoVinculacion |
| `PGM_ClientsAPI_EDGE_DireccionesClientePorId` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/addresses"` |  |  | clientId:Text | QUERY | 5: I:PGM_DatosDeContacto, R:PGM_ClientePGM_a_ClienteRM, R:PGM_Prueba_Respuesta404 … |
| `PGM_ClientsAPI_EDGE_MasDatosCliente` | PGM Clients EDGE | PUT | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/contactMethod/" & ri!motivoContacto & "-" & ri!metodoContacto` |  | application/json · { "contactMethod": { "contactMethodId": ri!motivoContacto & "-" & ri!m | clientId:Text,metodoContacto:Text,prefix:Number (Integer),nuevoValor:Text,motivoContacto:T | MODIFY | 2: I:PGM_DatosDeContacto_Email, I:PGM_DatosDeContacto_Tel |
| `PGM_ClientsAPI_EDGE_MetodosContactoClientePorId` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/contactMethods"` |  |  | clientId:Text | QUERY | 9: I:PGM_DetalleGestion30, I:PGM_FichaCliente_Header_ParteSuperior_Nuevo_v2, PM:{'en_US': '', 'es': 'PGM Abrir Mas Datos |
| `PGM_ClientsAPI_EDGE_Obtener_ClienteTotal` | PGM Clients EDGE | GET | `"/MRCConsultaBack_be-web/api/1.0/client/"&ri!clientId&"/representedCompanies?clientTypeCode="&ri!clientTypeCode&""` |  |  | clientId:Text,clientTypeCode:Text | QUERY | 1: R:PGM_Obtener_ClienteTotal |
| `PGM_ClientsAPI_EDGE_PerfilClientePorId` | PGM Clients EDGE | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId & "/profile"` | includeHistoryInd=ri!historico |  | clientId:Text,historico:Boolean | QUERY | 7: I:PGM_TipologiaCliente, R:PGM_ClientePGM_a_ClienteRM, R:PGM_ClientePorID_Completo … |
| `PGM_ClientsAPI_EncuestasClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS& "/client/" & ri!clientId & "/surveys"` |  |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_InteraccionesClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/interactions?startDate=" & text(today() - 1096, "dd/mm/yyyy") & "&endDate=" & tex` | applicationName=PGM |  | clientId:Text | QUERY | 1: R:PGM_MapearInteracciones |
| `PGM_ClientsAPI_Interaction` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` |  | application/json · { "user": rule!PGM_ObtenerNuuma(), "interaction": { "effectiveDate": r | Interaction:PGM_ClientsAPI_Interaction | QUERY | 0 |
| `PGM_ClientsAPI_Interaction_Santander_Alta` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` |  | application/json · { "user": rule!PGM_ObtenerNuuma(), "interaction": { "effectiveDate": r | Interaction:PGM_ClientsAPI_Interaction | QUERY | 0 |
| `PGM_ClientsAPI_Interaction_Santander_Baja` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` |  | application/json · { "user": rule!PGM_ObtenerNuuma(), "interaction": { "effectiveDate": r | Interaction:PGM_ClientsAPI_Interaction | QUERY | 0 |
| `PGM_ClientsAPI_Interaction_Verti` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` |  | application/json · { "user": rule!PGM_ObtenerNuuma(), "interaction": { "effectiveDate": r | Interaction:PGM_ClientsAPI_Interaction | QUERY | 0 |
| `PGM_ClientsAPI_MetodosContactoClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/contactMethods"` |  |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_MetodosIdentificacionClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/identificationMethods"` |  |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_PerfilClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/profile"` | includeHistoryInd=ri!historico |  | clientId:Text,historico:Boolean | QUERY | 1: R:PGM_DPVE_ObtenerTipologiaCliente |
| `PGM_ClientsAPI_PrestacionesClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/claims"` | startDate=a!defaultValue(ri!startDate, edate(today(), -12)) |  | clientId:Text,startDate:Date | QUERY | 2: PM:{'pt': '', 'en_US': 'PGM_RecuperarRecibosYPrestaciones', 'it': '', 'fr_FR': '', 'es': 'PGM_RecuperarRecibosYPresta |
| `PGM_ClientsAPI_ReclamacionesClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS &"/client/" & ri!clientId & "/complaints"` | applicationName=PGM |  | clientId:Text | QUERY | 0 |
| `PGM_ClientsEDGE_ActualizarNacionalidad` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/client/modification` |  | application/json · { "originInfo": { "originClientId": ri!client.idCliente, /*Los dos sig | client:PGM_Cliente,nuevaNacionalidad:Text | MODIFY | 0 |
| `PGM_ClientsEDGE_ActualizarPreferenciasContacto` | PGM Clients EDGE | POST | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/preferenceContactChannel"` |  | application/json · { "contactChannelReasonCode":ri!medioContacto.razonMedioContacto, "con | clientId:Text,medioContacto:PGM_medioDeContacto | MODIFY | 0 |
| `PGM_ClientsEDGE_ContactoBDC` | PGM Clients EDGE | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` |  | application/json · { "user": ri!nuuma, "interaction": { "effectiveDate": rule!PGM_Formate | clientId:Text,documento:Text,tipoDocumento:Text,idMotivo:Text,canal:Text,nuuma:Text | MODIFY | 0 |
| `PGM_ClientsEDGE_Crosselling` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/crosselling"` | searchUser=rule!PGM_ObtenerNuuma() |  | clientId:Text | QUERY | 5: I:PGM_AccionesRecomendaciones, R:PGM_CompletarInfoCliente, R:PGM_Prueba_Respuesta404 … |
| `PGM_ClientsEDGE_EliminarDirecciones` | PGM Clients EDGE | DELETE | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/address/" & ri!address` | searchUser=rule!PGM_ObtenerNuuma() |  | clientId:Text,address:Text | MODIFY | 2: I:PGM_CajaAviso_BorrarDireccion, I:PGM_DatosDeContacto |
| `PGM_ClientsEDGE_Informacion_externa` | PGM Clients EDGE | POST | `/MRCConsultaBack_be-web/api/1.0/client/externalInformation` |  | application/json · { identityDocumentNumber: ri!documentNumber } | documentNumber:Text | QUERY | 4: R:PGM_CompletarInfoCliente, R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente … |
| `PGM_ClientsEDGE_InteracionesClientePorId` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/interactions?startDate=" & text(today() - 1096, "dd/mm/yyyy") & "&endDate=" & t` | applicationName=PGM |  | clientId:Text | QUERY | 4: R:PGM_MapearInteracciones, R:PGM_Prueba_Respuesta404, R:PGM_R_GetAlertasPorIdCliente_Report … |
| `PGM_ClientsEDGE_PreferenciasContacto` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/preferenceContactChannels"` |  |  | clientId:Text | QUERY | 3: I:PGM_DatosDeContacto, I:PGM_FormularioMasDatosCliente, I:PGM_Masdatos |
| `PGM_ClientsMediation_BeneficiosClientePorId` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/benefits"` |  |  | clientId:Text | QUERY | 5: R:PGM_ClientePorID_Completo, R:PGM_CompletarInfoCliente, R:PGM_Prueba_Respuesta404 … |
| `PGM_ClientsMediation_DescuentoIntegralidadPorDocumento` | PGM Clients EDGE | POST | `/api_negocioclientes_int-web/api/1.0/client/integralityDiscountPercent` |  | application/json · { identityDocumentTypeCode: ri!documentTypeCode, identityDocumentNumbe | documentTypeCode:Text,documentNumber:Text | QUERY | 4: R:PGM_CompletarInfoCliente, R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente … |
| `PGM_ClientsMediation_EncuestasClientePorId` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/surveys"` |  |  | clientId:Text | QUERY | 5: R:PGM_ClientePorID_Completo, R:PGM_CompletarInfoCliente, R:PGM_Prueba_Respuesta404 … |
| `PGM_ClientsMediation_MetodosIdentificacionClientePorId` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/identificationMethods"` |  |  | clientId:Text | QUERY | 3: R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente, R:PGM_getInfoCliente_test |
| `PGM_ClientsMediation_PrestacionesClientePorId` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/claims"` | startDate=a!defaultValue(ri!startDate, edate(today(), -12)) |  | clientId:Text,startDate:Date | QUERY | 4: I:PGM_ResumenPrestaciones_v2, R:PGM_MapeoPrestaciones, R:PGM_MapeoRecibosYPrestaciones … |
| `PGM_ClientsMediation_ReclamacionesClientePorId` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/complaints"` |  |  | clientId:Text | QUERY | 2: R:PGM_MapearReclamaciones, R:PGM_Prueba_Respuesta404 |
| `PGM_ComercializacionSeguros_Polizas` | PGM Clients EDGE | POST | `"/evt21_nse_serv_emi/api/1.0/poliza/"&ri!numeroPoliza&"/verti"` |  | application/json · { "contacto": { "apellido": ri!cliente.apellido1, "apellido2": ri!clie | numeroPoliza:Text,cliente:PGM_Cliente,datos:PGM_ComercializacionSeguros_Polizas | QUERY | 0 |
| `PGM_DELETE_ClienteTotal_Eliminar_Empresa` | PGM BFF | DELETE | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/" & ri!idEmpresa` | user=ri!nuuma |  | idCliente:Text,idEmpresa:Text,nuuma:Text | MODIFY | 1: I:PGM_ClienteTotal_Fisico |
| `PGM_DPVE_GenerarDocumentacion` | (no verificado: LCP 500) | ? | `no verificado` |  |  |  | ? | 0 |
| `PGM_DPVE_Integralidad_Simulacion` | PGM Clients EDGE | POST | `/SR_TRC_be-web/api/nt21/clientes/integralidad/simulacion` |  | application/json · { "codDocum": ri!NIF, "codIdioma": "es_ES", "idnAplicacion": "DPVE", " | tipoDocumento:Text,NIF:Text,codCia:Number (Integer)[],codRamo:Number (Integer)[] | QUERY | 1: R:PGM_DPVE_ObtenerDescuento |
| `PGM_DigitalHealth_ActualizacionVencimientoCompleto` | PGM_MapfreDigitalHealth | PATCH | `"/apipgo/opportunity/complete/" & ri!opportunityId` |  | application/json · { "expiration_date": ri!fechaVencimiento, /* no obligatorio si se envi | opportunityId:Text,nuuma:Text,entidadCompetencia:Text,fechaVencimiento:Text | MODIFY | 1: I:PGM_DetalleVencimiento |
| `PGM_DigitalHealth_AnadirObservacion` | PGM_MapfreDigitalHealth | POST | `"/apipgo/opportunity/" & ri!opportunityId & "/observation"` |  | application/json · { "observation":ri!observacion, "type":"USER", "user": ri!nuuma, } | opportunityId:Text,nuuma:Text,observacion:Text | MODIFY | 1: I:PGM_editarObservacion_PGO |
| `PGM_DigitalHealth_EditarObservacion` | PGM_MapfreDigitalHealth | PUT | `"/apipgo/opportunity/" & ri!opportunityId & "/observation/" & ri!ObservacionId` |  | application/json · { "observation":ri!observacion, "type":"USER", "user": ri!nuuma, } | opportunityId:Text,nuuma:Text,observacion:Text,ObservacionId:Text | MODIFY | 1: I:PGM_editarObservacion_PGO |
| `PGM_DigitalHealth_EliminarObservacion` | PGM_MapfreDigitalHealth | DELETE | `"/apipgo/opportunity/" & ri!opportunityId & "/observation/" & ri!ObservacionId` |  |  | opportunityId:Text,nuuma:Text,ObservacionId:Text | MODIFY | 0 |
| `PGM_EliminarObservacion` | PGM_SGC3.0 | DELETE | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/observations` | idTask=ri!idTarea;observationId=ri!idObservacion;preferredUsername=ri!nuumaEncriptado |  | idTarea:Text,idObservacion:Text,nuumaEncriptado:Text | MODIFY | 1: I:PGM_DetalleGestion30 |
| `PGM_GET_ClienteTotal` | PGM BFF | GET | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies"` | clientTypeCode=ri!tipoPersona;callType=ri!callType |  | idCliente:Text,tipoPersona:Text,callType:Text | QUERY | 2: I:PGM_ClienteTotal_Fisico, I:PGM_ClienteTotal_Juridico |
| `PGM_GET_ClienteTotal_Cargos` | PGM BFF | POST | `/api-pgm/catalog/query` |  | application/json · { "catalogFilterParams": { "catalogId": "LV_API_PGM_CARGOS", "installa |  | QUERY | 0 |
| `PGM_GET_ClienteTotal_Documentos` | PGM BFF | GET | `"/api-pgm/clients/"& ri!idDocumento &"/representedCompanies/document"` | template=facturas |  | idDocumento:Text | MODIFY | 0 |
| `PGM_GestionarACI_crearCliente` | (sin CS) | POST | `cons!PGM_ENDPOINT_API_ACI & "/olvido/usuario/crear_cliente"` |  | application/json · { "pnombre": ri!cliente.nombre, "papellido1": ri!cliente.apellido1, "p | cliente:PGM_Request_CrearClienteACI | MODIFY | 0 |
| `PGM_GestionarSolicitudesAnulacion` | (sin CS) | POST | `https://core7.pre.mapfre.net:26007/PCA_CORECFSA_HTTPRouter/IGenerarContraAnul/generarStudAnul` |  | auto-detect · ri!documento | documento:Document | MODIFY | 0 |
| `PGM_HealthAPI_Tarificacion` | PGM Health API | POST | `/individual/simulation` |  | application/json · { /*¿Opcional?*/ "clientData": { "identificationMethod": { "identityDo | datosTarificacion:PGM_TarificacionSalud | QUERY | 1: R:PGM_SimulacionTarificacion |
| `PGM_InduccionVerti_No_NSE` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/FDC_SMEDWeb/sca/wIConsultarIntegraciones"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env |  | MODIFY | 0 |
| `PGM_POST_ClienteTotal_Enviar_Firma` | PGM BFF | POST | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/signature"` |  | application/json · { "channel": ri!canal, "user": ri!nuuma, "signProcess": "PGM_APCTE" } | idCliente:Text,canal:Text,nuuma:Text | MODIFY | 1: I:PGM_ClienteTotal_Fisico |
| `PGM_POST_ClienteTotal_Insertar_Empresa` | PGM BFF | POST | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/" & ri!idEmpresa` |  | application/json · { "positionCode": ri!positionCode, "user": ri!nuuma } | idCliente:Text,idEmpresa:Text,positionCode:Text,nuuma:Text | MODIFY | 1: I:PGM_Incluir_Empresa_Vinculada |
| `PGM_POST_llamar_registro_operaciones` | PGM loopback appian | POST | `registro` |  | application/json · { cod_accion: ri!cod_accion, data: ri!data, fechaAudit: ri!fechaAudit, | cod_accion:Number (Integer),data:Map,fechaAudit:Text,nuuma:Text,usuarioAppian:Text | QUERY | 1: R:PGM_redirigirFichaCliente |
| `PGM_PUT_ClienteTotal_Actualizar_Empresa` | PGM BFF | PUT | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/" & ri!idEmpresa` |  | application/json · { "positionCode": ri!positionCode, "user": ri!nuuma } | idCliente:Text,idEmpresa:Text,positionCode:Text,nuuma:Text | MODIFY | 1: I:PGM_ClienteTotal_Fisico |
| `PGM_SGC30_ActualizarAsignacion` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | idTask=ri!idTask;preferredUsername=ri!nuumaEncriptado | application/json · { "operation": if( ri!operation = 2, "UPDATE_TRANSFER", "UPDATE_ASSIGN | nuumaEncriptado:Text,idTask:Text,codeStructureAssignation:Text,nuumaAssignation:Text,comme | MODIFY | 1: I:PGM_DetalleGestion30 |
| `PGM_SGC30_ActualizarObservacionPorIdTarea_ActualizaciónExitoPotencial` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | idTask=ri!idTarea;preferredUsername=ri!nuumaEncriptado | application/json · { "operation": "UPDATE_SUCCESS_POTENTIALITY", "successPotentiality": r | nuumaEncriptado:Text,idTarea:Text,potencialidadExito:Text | MODIFY | 1: I:PGM_DetalleGestion30 |
| `PGM_SGC30_ActualizarObservacionPorIdTarea_General` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/observations` | idTask=ri!idTarea;preferredUsername=ri!nuumaEncriptado | application/json · { "observationId": ri!idObservacion, "observation": ri!observacion } | nuumaEncriptado:Text,idTarea:Text,idObservacion:Text,observacion:Text | MODIFY | 1: I:PGM_NuevaActividadComercial |
| `PGM_SGC30_CrearObservacionPorIdTarea` | PGM_SGC3.0 | POST | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/observations` | preferredUsername=ri!nuumaEncriptado;idTask=ri!idTarea | application/json · { "observation": ri!observacion } | nuumaEncriptado:Text,idTarea:Text,observacion:Text | MODIFY | 1: I:PGM_NuevaActividadComercial |
| `PGM_ServiciosCrosselling_Creatividades` | PGM WMAPFRE | GET | `/servicios_crosselling_ws_be/api/1.0/aci/crosselling/creatividades` | numeroDocumento=ri!documento;origen=FAC |  | documento:Text | QUERY | 1: R:PGM_ObtenerCreatividades |
| `PGM_ServiciosRecibos_IOperarAgrupaciones` | (sin CS) | POST | `https://esb.pre.mapfre.net:26005/GESYC_AgrupRecib_SMEDWeb/sca/Exportar_IOperarAgrupaciones1` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |
| `PGM_SignatureManagemen_cancellation` | PGM Clients EDGE | DELETE | `"/consentimientos_be-web/api/1.0/consent/request/"&ri!requestId&"/cancellation"` |  |  | requestId:Text | QUERY | 0 |
| `PGM_SignatureManagemen_request` | PGM Clients EDGE | POST | `/consentimientos_be-web/api/1.0/consent/request` |  | application/json · { "data": { "process": if( ri!esAlta, "PRSAN-ALTA", "PRSAN-BAJA" ), "c | cliente:PGM_Cliente,request:PGM_SignatureManagemen_request,documento:Document,esAlta:Boole | QUERY | 0 |
| `PGM_TeCuidamosAPI_ObtenerIdSocio` | PGM Clients EDGE | GET | `/es_mkfd_tc_movil_app_be-web/api/tecuidamos/socios/beneficios` | numDocumento=ri!NIF |  | NIF:Text | QUERY | 0 |
| `PGM_informacionUsuario_grupos` | PGM Clients EDGE | POST | `/SERVICIOSWEBPI/services/InformacionUsuario` |  | application/json · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | nuuma:Text | QUERY | 1: R:PGM_obtenerGruposIntegraciones |
| `PGM_registrarConsultaModificacionPOST` | PGM API Portal Interno | POST | `cons!PGM_URL_REGISTRO_ACCIONES_NUUMA` |  | application/xml · ri!request | request:Text | MODIFY | 0 |

### Pólizas / productos / detalle por ramo (36)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_APICatalogo` | (sin CS) | POST | `` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |
| `PGM_APICatalogo_Argumentario` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/ARQ_CATALOG_SMEDWeb/sca/wICatalog"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | codigoArgumentario:Text | QUERY | 1: R:PGM_obtenerParametroArgumentario |
| `PGM_APICatalogo_DPVE` | (sin CS) | POST | `https://webservices.pre.mapfre.net:26004/ARQ_Catalogo_be-web/api/1.0/catalogos/catalog/flitered` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env |  | QUERY | 0 |
| `PGM_APICatalogo_DPVE_v2` | (sin CS) | POST | `` |  | application/xml · ri!request.request | request:CMP_ReqWlCatalog | QUERY | 1: R:PGM_DPVE_Codigos_Grupos |
| `PGM_APICatalogo_ObtenerRoles` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/ARQ_Usuarios_SMEDWeb/sca/wUsuarios"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | nuuma:Text | QUERY | 0 |
| `PGM_APICatalogo_PolizaValida` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/ARQ_CATALOG_SMEDWeb/sca/wICatalog"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env |  | QUERY | 1: I:PGM_modalMotivoSCA |
| `PGM_APICatalogo_SCA` | (sin CS) | POST | `cons!PGM_HOST_ESB&"/ARQ_CATALOG_SMEDWeb/sca/wICatalog"` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env |  | QUERY | 0 |
| `PGM_APICatalogo_URLPresupuestos` | PGM API WLCatalog | POST | `` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | catalogo:Text,valorCatalogo:Text,catalogoId:Text | QUERY | 1: R:PGM_mapeoURLsPresupuestos |
| `PGM_APICatalogo_catalogo` | (sin CS) | POST | `` |  | application/xml · ri!request.request | request:CMP_ReqWlCatalog | QUERY | 1: R:PGM_APICatalogo_catalogo_recordDataSource |
| `PGM_APICatalogo_codURLPresupuestos` | PGM API WLCatalog | POST | `` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | cia:Text,ramo:Text | QUERY | 1: R:PGM_mapeoURLsPresupuestos |
| `PGM_APISCA_ObtenerArgumentario` | PGM Clients EDGE | POST | `"/sca_servicios/api/1.0/compania/"&ri!compania&"/poliza/"&ri!poliza&"/argumento"` |  | application/json · { "numeroAplicacion": "0", "canalEntrada": 1, "perfilEjecucion": "CE_R | compania:Text,poliza:Text,nuuma:Text,ramo:Text,claveAgente:Text,causaSCA:Number (Integer) | QUERY | 0 |
| `PGM_API_HOME_ConsumoProtegido` | PGM Integraciones | GET | `"/esp/srv/api/home/2.0/policy/" & ri!numPoliza & "/detail"` | companyId=23;platformCode=52;distributionChannelCode=39 |  | numPoliza:Text | QUERY | 0 |
| `PGM_API_HOME_HipotecaSegura` | PGM Integraciones | GET | `"/esp/srv/api/home/2.0/policy/" & ri!numPoliza & "/detail"` | companyId=81;platformCode=52;distributionChannelCode=39 |  | numPoliza:Text | QUERY | 0 |
| `PGM_CitrixAPI_Configuration` | PGM Citrix API | POST | `/Home/Configuration` |  | application/json |  | QUERY | 1: R:PGM_ObtenerCredenciales |
| `PGM_ClientsAPI_EDGE_PolizasClientePorId` | PGM Clients EDGE Recibos | GET | `/server/vfdc/client/views/productsDetail` | policyNumber=ri!numeroPoliza;clientId=<redactado>, e |  | clientId:Text,numeroPoliza:Text,startDate:Date | QUERY | 16: I:PGM_FichaCliente_Carrusel, I:PGM_FichaCliente_v2, I:PGM_FiltrosMenos10Productos … |
| `PGM_ClientsAPI_EDGE_PolizasClientePorIdCarrusel` | PGM Clients EDGE | GET | `"/MRCBack_be-web/api/1.0/client/"& ri!clientId & "/policies"` |  |  | clientId:Text | QUERY | 5: I:PGM_R_recordViewFichaCliente, R:PGM_Prueba_Respuesta404, R:PGM_R_getPolizasPorIdCliente … |
| `PGM_ClientsAPI_EDGE_ProductosPorId` | PGM Clients EDGE Recibos | GET | `/server/vfdc/client/views/products` | clientId=<redactado>|  | clientId:Text | QUERY | 0 |
| `PGM_ClientsAPI_PolizasClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/detailedPolicies"` | endDate=31/12/9999;policyNumber=ri!numeroPoliza;startDate=a!defaultValue(ri!startDate, eda |  | clientId:Text,numeroPoliza:Text,startDate:Date | QUERY | 3: R:PGM_AccionesPolizaCompleto, R:PGM_Polizas_Verti, R:PGM_Prueba_Respuesta404 |
| `PGM_ClientsAPI_PolizasClientePorIdCarrusel` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/policies"` |  |  | clientId:Text | QUERY | 1: R:PGM_Prueba_Respuesta404 |
| `PGM_ClientsEDGE_products` | (sin CS) | GET | `"http://denodo-prep.es.mapfre.net:26014" & "/server/vfdc/client/views/productsDetail"` | clientId=<redactado>|  | clientId:Text | QUERY | 0 |
| `PGM_ClientsEDGE_productsDetail` | (sin CS) | GET | `cons!PGM_ENDPOINT_DENODO & "/server/vfdc/client/views/productsDetail"` | clientId=<redactado>|  | clientId:Text,numeroPoliza:Text | QUERY | 0 |
| `PGM_HealthAPI_DetallesPolizaSaludPorId` | PGM Health API | GET | `"/individual/policy/" & ri!policyId` |  |  | policyId:Text | QUERY | 1: R:PGM_DetallePolizaSaludPorId |
| `PGM_HealthAPI_ProductosComerciales` | PGM Health API | GET | `/settings/commercialProducts` |  |  |  | QUERY | 1: R:PGM_ActualizarNombresProductos |
| `PGM_HomeApi_PolicyDetail` | PGM Integraciones | GET | `"/esp/srv/api/home/2.0/policy/" & ri!numPoliza & "/detail"` | companyId=41;platformCode=52;distributionChannelCode=39 |  | numPoliza:Text | QUERY | 2: R:PGM_DetallePolizaHogarPorId, R:PGM_DetallePoliza_ConsumoProtegido |
| `PGM_LifeAPI_DuplicadoPoliza` | PGM Life Risk API | POST | `"/apisbcpolizas_int-web/api/life/1.0/individual/policy/"&ri!idPoliza&"/documents"` |  | application/json · { "endorsementId" : "00000", "modificationCode" : "00000", "issueDocum | idPoliza:Text | MODIFY | 1: I:PGM_DetalleVida_Doumentos |
| `PGM_LifeAPI_DuplicadoRecibos` | PGM PGM Life Risk API DUPLICADO | POST | `/gesycore_servicios_bbe-web/services/imprimirRecibo` |  | application/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | numRecibo:Text,nuuma:Text | QUERY | 0 |
| `PGM_LifeAPI_Poliza` | PGM Life Risk API | GET | `"/apisbcpolizas_int-web/api/life/1.0/individual/policy/"&ri!idPoliza` |  |  | idPoliza:Text | QUERY | 1: R:PGM_DetallePolizaVidaRiesgoPorId |
| `PGM_LifeAPI_UnitLink` | PGM Life Risk API | GET | `"/apisbcpolizas_int-web/api/life/1.0/policy/"&ri!idPoliza&"/unitLink"` |  |  | idPoliza:Text | QUERY | 1: R:PGM_DetallePolizaVidaRiesgoPorId |
| `PGM_MotorApi_Policy` | PGM Integraciones | GET | `"srv/api/1.0/motor/policy/" & ri!referenceNumber & "/detail"` | companyId=ri!companyId |  | referenceNumber:Text,companyId:Text | QUERY | 1: R:PGM_DetallePolizaAutosPorId |
| `PGM_ServiciosHogar_ConsultarPoliza` | (sin CS) | POST | `https://api.mapfre.net:27003/srv/IGestionarConsultaPolCanal` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |
| `PGM_ServiciosVida_ConsultarProductor` | (sin CS) | POST | `https://soa7.desa.mapfre.net:25006/REDTE_CProductor_SMEDWeb/sca/IConsultarProductorVidaExport1` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |
| `PGM_getFinancialGroup` | PGM_MapfreDigitalHealth | GET | `"/apipgo/financials/products/"& ri!productCode &"/financial-groups"` |  |  | productCode:Text | QUERY | 2: I:PGM_AltaVencimientos_PlanesPensiones, I:PGM_DetalleVencimientos_PlanesPensiones |
| `PGM_getFunds` | PGM_MapfreDigitalHealth | GET | `"/apipgo/financials/"& ri!financialCode &"/products/"& ri!productCode &"/funds"` |  |  | productCode:Text,financialCode:Text | QUERY | 2: I:PGM_AltaVencimientos_PlanesPensiones, I:PGM_DetalleVencimientos_PlanesPensiones |
| `PGM_getPlans` | PGM_MapfreDigitalHealth | GET | `"/apipgo/financials/"& ri!financialCode &"/products/"& ri!productCode &"/funds/" &ri!fundCode& "/plans"` |  |  | productCode:Text,financialCode:Text,fundCode:Text | QUERY | 2: I:PGM_AltaVencimientos_PlanesPensiones, I:PGM_DetalleVencimientos_PlanesPensiones |
| `PGM_iMediadorEDGE_CatalogoAcciones` | PGM iMediador EDGE | GET | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` |  |  | estructuraComercial:PGM_EstructuraComercial | QUERY | 0 |
| `PGM_iMediadorEDGE_CatalogoNivelesGestion` | PGM iMediador EDGE | GET | `"/api/1.0/origen/"&ri!origen&"/obtenerNivelesGestion"` |  |  | origen:Text | QUERY | 1: I:PGM_NuevaActividadComercial |

### Recibos (4)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_ClientsAPI_EDGE_RecibosClientePorId` | PGM Clients EDGE Recibos | GET | `/server/vfdc/client/views/receiptsDetail` | limit=if( a!isNullOrEmpty(ri!nRecibos), 30, ri!nRecibos );user=admin;clientId=<redactado>|  | clientId:Number (Integer),nRecibos:Number (Integer),startDate:Date | QUERY | 4: I:PGM_ResumenRecibos_v2, R:PGM_AumentarNumeroRecibos, R:PGM_MapeoRecibos … |
| `PGM_ClientsAPI_RecibosClientePorId` | PGM Client API | GET | `"/client/" & ri!clientId & "/receipts"` | limit=if( a!isNullOrEmpty(ri!nRecibos), 30, ri!nRecibos );policyNumber=ri!numPoliza;startD |  | clientId:Number (Integer),nRecibos:Number (Integer),numPoliza:Text,startDate:Date | QUERY | 4: I:PGM_ResumenRecibos_v3, PM:{'pt': '', 'en_US': 'PGM_RecuperarRecibosYPrestaciones', 'it': '', 'fr_FR': '', 'es': 'PG |
| `PGM_ServiciosRecibos_ConsultarDatosRecibo` | PGM Clients EDGE | POST | `/gesycore_servicios_bbe-web/services/consultarRecibo` |  | application/xml · ri!request | request:Text | QUERY | 1: R:PGM_ConsultarDatosRecibo |
| `PGM_ServiciosRecibos_EnvioAlBanco` | (sin CS) | POST | `https://esb.pre.mapfre.net:26005/GESYC_Aplicagest_SMEDWeb/sca/Exportar_IAplicarGestion1` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |

### Prestaciones / siniestros (1)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_ConsultarDetalleSiniestro` | (sin CS) | POST | `https://esb.pre.mapfre.net:26005/ATN_SINIESTRALIDAD_SMEDWeb/sca/wIConsultarSiniestralidad_3_0_0` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |

### Presupuestos / tarificación (Salud) (18)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_ClientsAPI_PresupuestosClientePorId` | (sin CS) | GET | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/projects"` | internalUser=ri!nuuma |  | clientId:Text,nuuma:Text | QUERY | 3: I:PGM_FichaCliente_v2_Record, R:PGM_ConsultarVencimientosPresupuestos, R:PGM_R_PresupuestosPorIdCliente_Record |
| `PGM_ClientsMediation_PresupuestosClientePorId` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/projects"` | internalUser=ri!nuuma |  | clientId:Text,nuuma:Text | QUERY | 4: I:PGM_FichaCliente_v2, I:PGM_R_recordViewFichaCliente, R:PGM_Prueba_Respuesta404 … |
| `PGM_DigitalHealth_ActualizarVencimientoIncompleto` | PGM_MapfreDigitalHealth | PATCH | `"/apipgo/opportunity/incomplete/" & ri!opportunityId` |  | application/json · a!toJson_17r1( rule!PGM_ActualizarVencimientoIncompleto( vencimiento: | vencimiento:PGM_Vencimiento_PGO,cliente:PGM_Cliente,perfilComercial:PGM_PerfilSGC3,opportu | MODIFY | 1: I:PGM_DetalleVencimiento |
| `PGM_DigitalHealth_ActualizarVencimientoSalud` | PGM_MapfreDigitalHealth | POST | `/apipgo/opportunity/health` |  | application/json · a!toJson_17r1( rule!PGM_ActualizarVencimientoIncompleto( vencimiento: | vencimiento:PGM_Vencimiento,cliente:PGM_Cliente,perfilComercial:PGM_PerfilSGC3 | MODIFY | 0 |
| `PGM_DigitalHealth_AltaVencimientoIncompleto` | PGM_MapfreDigitalHealth | POST | `/apipgo/opportunity/incomplete` |  | application/json · a!toJson_17r1( rule!PGM_ActualizarVencimientoIncompleto( vencimiento: | vencimiento:PGM_Vencimiento_PGO,cliente:PGM_Cliente,perfilComercial:PGM_PerfilSGC3 | MODIFY | 1: I:PGM_AltaVencimientos_v2 |
| `PGM_DigitalHealth_AñadirDocumento` | PGM_MapfreDigitalHealth | POST | `/apipgo/opportunity/attachment` |  | application/json · { "opportunity_id": ri!opportunityId, "attachment": "data:"&rule!PGM_t | opportunityId:Text,attachment:Text,nuuma:Text,nombreDoc:Text | MODIFY | 0 |
| `PGM_DigitalHealth_DetalleVencimiento` | PGM_MapfreDigitalHealth | GET | `"/apipgo/opportunity/" & ri!opportunityId` |  |  | opportunityId:Text | QUERY | 1: R:PGM_MapeoVencimientos_Detalle |
| `PGM_DigitalHealth_EliminarDocumento` | PGM_MapfreDigitalHealth | DELETE | `"/apipgo/opportunity/" & ri!opportunityId &"/attachment/" & ri!attachment_id` |  |  | opportunityId:Text,attachment_id:Text,nuuma:Text | MODIFY | 1: I:PGM_eliminarDocumento_PGO |
| `PGM_DigitalHealth_EliminarVencimiento` | PGM_MapfreDigitalHealth | DELETE | `"/apipgo/opportunity/" & ri!opportunityId` |  |  | opportunityId:Text | MODIFY | 1: I:PGM_DetalleVencimiento |
| `PGM_DigitalHealth_EnrutamientoNUUMA` | PGM_MapfreDigitalHealth | GET | `"/apipgo/system/route/" & ri!nuuma` | origin=PGM |  | nuuma:Text | QUERY | 1: R:PGM_enrutamientoNUUMA |
| `PGM_DigitalHealth_ObtenerDocumento` | PGM_MapfreDigitalHealth | POST | `"/apipgo/opportunity/" & ri!opportunityId &"/attachment/retrieve"` |  | application/json · { "attachment_id": ri!attachment_id, "user_nuuma": ri!nuuma } | opportunityId:Text,attachment_id:Text,nuuma:Text | QUERY | 0 |
| `PGM_DigitalHealth_SumarioVencimientosCliente` | PGM_MapfreDigitalHealth | POST | `/apipgo/client/opportunities/summary` |  | application/json · { "nuuma": ri!nuuma, "client_document": ri!documentoCliente } | nuuma:Text,documentoCliente:Text | QUERY | 1: R:PGM_SumarioVencimientosCliente |
| `PGM_DigitalHealth_VencimientosNumeroDocumento` | PGM_MapfreDigitalHealth | POST | `/apipgo/client/opportunities` |  | application/json · { "nuuma": ri!nuuma, "client_document": ri!documentoCliente } | documentoCliente:Text,nuuma:Text | QUERY | 1: R:PGM_MapeoVencimientos_Listado |
| `PGM_DigitalHealth_listadoCompanias` | PGM_MapfreDigitalHealth | GET | `/apipgo/competitor-company` | type=ri!type |  | type:Text | QUERY | 2: R:PGM_ListadoEntidadesVIDA_PGO, R:PGM_ListadoEntidades_PGO |
| `PGM_GestionarLeads_SAVIA_V2` | (sin CS) | POST | `https://apiattributions.pre.mapfredigitalhealth.com/lead` |  | application/json · { "client_ship_id": "CLIENTSHP_ID", "client_email": ri!gestionarLead.c | gestionarLead:PGM_GestionarLeads_SAVIA | MODIFY | 0 |
| `PGM_HealthAPI_CoberturasPorIdProducto` | PGM Health API | GET | `"/settings/commercialProduct/" & ri!commercialProductId & "/coverages"` | mandatoryCoveragesInd=true |  | commercialProductId:Text | QUERY | 2: R:PGM_CoberturasPorIdProducto, R:PGM_DetallePolizaSaludPorId |
| `PGM_HealthAPI_ProfesionesPorIdProducto` | PGM Health API | GET | `"/settings/commercialProduct/" & ri!commercialProductId & "/healthQuestionnaire/conditions/professions"` | pageNumber=0;pageSize=1000 |  | commercialProductId:Text | QUERY | 1: R:PGM_ActualizarListaProfesiones |
| `PGM_PGO` | (sin CS) | GET | `https://clientes.private.pre.mapfredigitalhealth.com:26030` |  |  |  | QUERY | 0 |

### Oportunidades PGO / Digital Health (2)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_iMediadorEDGE_AltaVencimiento` | PGM iMediador EDGE | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` |  | application/json · { "tipo": tointeger(ri!nuevoVencimiento.tipo), "linea": if(a!isNotNull | estructuraComercial:PGM_EstructuraComercial,idContacto:Text,nuevoVencimiento:PGM_Vencimien | MODIFY | 1: I:PGM_AltaVencimientos |
| `PGM_iMediadorEDGE_Vencimientos` | PGM iMediador EDGE | GET | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` |  |  | estructuraComercial:PGM_EstructuraComercial,idContacto:Text | QUERY | 4: R:PGM_ConsultarVencimientosPresupuestos, R:PGM_Prueba_Respuesta404, R:PGM_VencimientosPorIdContacto … |

### Gestiones SGC 3.0 (10)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_SGC30_ActualizarNGA` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | idTask=ri!idTask;preferredUsername=ri!nuumaEncriptado | application/json · { "operation": "UPDATE_NGA", "nuumaAssignation": ri!nuumaAssignation } | nuumaEncriptado:Text,idTask:Text,nuumaAssignation:Text | MODIFY | 1: I:PGM_NuevaActividadComercial |
| `PGM_SGC30_CerrarTarea` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/close` | idTask=ri!idTask;preferredUsername=ri!nuumaEncriptado | application/json | nuumaEncriptado:Text,idTask:Text | MODIFY | 1: I:PGM_DetalleGestion30 |
| `PGM_SGC30_Compartir` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | idTask=ri!idTask;preferredUsername=ri!nuumaEncriptado | application/json · { "operation": "UPDATE_SHARING", "codeStructureShared": ri!codeStructu | nuumaEncriptado:Text,idTask:Text,codeStructureAssignation:Text,comment:Text | MODIFY | 1: I:PGM_DetalleGestion30 |
| `PGM_SGC30_DetalleGestion` | PGM_SGC3.0 | GET | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | idTask=ri!idTask;preferredUsername=ri!nuumaEncriptado |  | idTask:Text,nuumaEncriptado:Text | QUERY | 1: R:PGM_MapearDetalleGestion |
| `PGM_SGC30_GestionesNumeroDocumento` | PGM_SGC3.0 | POST | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | preferredUsername=ri!nuumaEncriptado;page=ri!pagina;size=ri!pageSize | application/json · { "clientDocument": ri!numeroDocumento, "statusGroup": ri!estado, } | numeroDocumento:Text,nuumaEncriptado:Text,estado:Text,pagina:Number (Integer),pageSize:Num | QUERY | 2: I:PGM_ResumenGestiones, I:PGM_iMediador_Gestiones |
| `PGM_SGC30_Perfil` | PGM_SGC3.0 | GET | `/sgc3-bk-users/api/1.0/user/profile` | preferredUsername=ri!nuumaEncriptado |  | nuumaEncriptado:Text | QUERY | 4: R:PGM_ObtenerListadoPerfilesSGC3, R:PGM_ObtenerPerfilSGC3, R:PGM_Prueba_Respuesta404 … |
| `PGM_SGC30_ReabrirTarea` | PGM_SGC3.0 | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/reopen` | idTask=ri!idTask;preferredUsername=ri!nuumaEncriptado | application/json | nuumaEncriptado:Text,idTask:Text | MODIFY | 1: I:PGM_NuevaActividadComercial |
| `PGM_SGC30_descargaDocumentos` | PGM_SGC3.0 | GET | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/documents/download` | idTask=ri!idGestion;encryptedPath=ri!encryptedPath;preferredUsername=ri!nuumaEncriptado |  | idGestion:Text,encryptedPath:Text,nuumaEncriptado:Text | MODIFY | 0 |
| `PGM_SGC3_firmaMediador` | PGM_SGC3.0 | POST | `/sgc3-bk-users/api/1.0/external/user/terms/sign` | preferredUsername=ri!nuumaEncriptado | application/json | nuumaEncriptado:Text | MODIFY | 1: I:PGM_ClausulaInformativaMediadores |
| `PGM_ServiciosSGC_ConsultarGestiones` | (sin CS) | POST | `https://core7.pre.mapfre.net:26007/<literal-redactado>/IConsultarGestiones` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |

### Actividad comercial iMediador (SGC 2.0) (10)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_ClientsAPI_ActualizarMetodoContacto` | PGM Integraciones | PUT | `"esp/srv/api/clients/1.0/client/" & ri!clientId & "/contactMethod/" & cons!PGM_CODIGO_METODOCONTACTO_HABITUAL & "-" & ri!metodoContacto` |  | application/json · { "contactMethod": { "contactMethodId": cons!PGM_CODIGO_METODOCONTACTO | clientId:Text,metodoContacto:Text,nuevoValor:Text | MODIFY | 2: I:PGM_FichaCliente_Header_ParteSuperior_Mobile, I:PGM_FichaCliente_Header_Record |
| `PGM_ClientsEDGE_BorrarContactMethod` | PGM Clients EDGE | DELETE | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/contactMethod/" & ri!motivoContacto & "-" & ri!metodoContacto` | searchUser=rule!PGM_ObtenerNuuma() |  | clientId:Text,motivoContacto:Text,metodoContacto:Text | MODIFY | 2: I:PGM_DatosDeContacto_Email, I:PGM_DatosDeContacto_Tel |
| `PGM_iMediadorEDGE_ActividadComercial` | PGM iMediador EDGE | GET | `"/api/1.0/contacto/" & ri!idContacto & "/usuario/" & ri!nuuma & "/origen/"&ri!origen&"/obtenerActividades"` | indPaginacion=N |  | nuuma:Text,idContacto:Text,origen:Text | QUERY | 1: R:PGM_ActividadComercialPorIdContacto |
| `PGM_iMediadorEDGE_AltaActividad` | PGM iMediador EDGE | POST | `"/api/1.0/contacto/" & ri!idContacto & "/usuario/" & ri!nuuma & "/insertarActividad"` |  | application/json · { "idContacto": ri!idContacto, "origen": ri!origen, "nuuma": ri!nuuma, | nuuma:Text,idContacto:Text,actividad:Any Type,origen:Text | MODIFY | 0 |
| `PGM_iMediadorEDGE_AltaActividad_New` | PGM_iMediadorEDGE_AltaNGA | POST | `/api/1.0/contacto/insertarActividad` |  | application/json · { "idContacto": ri!idContacto, "origen": ri!origen, "nuuma": ri!nuuma, | idContacto:Text,nuuma:Text,actividad:Any Type,origen:Text,fechaCaducidad:Text,cliente:Map, | MODIFY | 1: I:PGM_NuevaActividadComercial |
| `PGM_iMediadorEDGE_AltaContacto` | PGM iMediador EDGE | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` |  | application/json · { "tipoContacto": rule!PGM_comprobarTipoContacto(categoria: ri!cliente | estructuraComercial:PGM_EstructuraComercial,cliente:PGM_Cliente | MODIFY | 5: I:PGM_FichaCliente_ItemCarrusel, I:PGM_FichaCliente_ItemCarrusel_Mobile, I:PGM_FichaCliente_ItemCarrusel_Mobile_v2 … |
| `PGM_iMediadorEDGE_AltaGestion` | PGM iMediador EDGE | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` |  | application/json · { "documento": ri!gestion.documento, "tipoDocumento": ri!gestion.tipoD | estructuraComercial:PGM_EstructuraComercial,gestion:PGM_GestionAlta | MODIFY | 0 |
| `PGM_iMediadorEDGE_ConsultaContactos` | PGM iMediador EDGE | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` |  | application/json · { "delegado": ri!estructuraComercial.delegado, "nuuma": ri!estructuraC | estructuraComercial:PGM_EstructuraComercial,documento:Text | QUERY | 8: I:PGM_FichaCliente_ItemCarrusel, I:PGM_FichaCliente_ItemCarrusel_Mobile, I:PGM_FichaCliente_ItemCarrusel_Mobile_v2 … |
| `PGM_iMediadorEDGE_ConsultaGestiones` | PGM iMediador EDGE | GET | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.id` | pagina=1 |  | estructuraComercial:PGM_EstructuraComercial | QUERY | 1: R:PGM_ObtenerGestiones_iMediador |
| `PGM_iMediadorEDGE_Perfil` | PGM iMediador EDGE | GET | `"/api/1.0/usuario/" & ri!nuuma & "/perfil"` |  |  | nuuma:Text | QUERY | 1: R:PGM_EstructuraComercialPorNUUMA |

### Estructura comercial BDEC / agente / NUUMA (5)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `CMP_PostConsulta_consultarDatosAgente` | (sin CS) | POST | `ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0` |  | text/plain · ri!request | request:Text | QUERY | 5: I:PGM_PosicionBancaria, R:PGM_ConstruirLanzadera, R:PGM_Prueba_Respuesta404 … |
| `PGM_BDEC_EstructuraComercialPorClave` | PGM BDEC API | GET | `"/ES_AUAD_ESTRUAGE_SERVICIOS_REST_be-web/api/1.0/claveProduccion/"&ri!clave` | codCompania=1;fechaValidez=None;codIdioma=None |  | clave:Text | QUERY | 1: R:PGM_DatosAgentePorClave |
| `PGM_Click2Call` | PGM_ConectaOrange | POST | `"/com.broadsoft.xsi-actions/v2.0/user/"&ri!nuuma&"/calls/callmenow"` | address=ri!telefono;transactionId=0 | application/json | nuuma:Text,telefono:Text | QUERY | 0 |
| `PGM_ConsultarDatosAgente` | (sin CS) | POST | `cons!PGM_HOST_CONSULTARAGENTE & "/ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0"` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |
| `PGM_ObtenerGruposRest` | PGM API Portal Interno | POST | `ARQ_SecurityServices_be-web/api/1.0/securityManagement/groups` |  | application/json · { "nuuma":ri!nuuma } | nuuma:Text | QUERY | 1: R:PGM_MapearRolesUsuario |

### SGO (solicitudes) (4)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_AccesoSGO` | (sin CS) | GET | `cons!PGM_ENDPOINT_APPIAN & "/suite/webapi/abrir-detalle-solicitud"` | codTramite=ri!codTramite |  | codTramite:Text | QUERY | 0 |
| `PGM_ServiciosSGO_ConsultarDocumentos` | (sin CS) | POST | `cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarDocumentos/<literal-redactado>"` |  | application/soap+xml · "<soap:Envelope xmlns:com=""http://les0009001202/com.mapfre.sgo.ws:Con | idSGO:Text,idGestion:Text,idDocumento:Text,nombreDocumento:Text | MODIFY | 1: I:PGM_TablaHistorialSGO |
| `PGM_ServiciosSGO_ConsultarSolicitudes` | (sin CS) | POST | `cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarSolicitudes/<literal-redactado>"` |  | auto-detect · ri!documento | documento:Document | QUERY | 0 |
| `PGM_ServiciosSGO_ConsultarSolicitudes_Interfaz` | (sin CS) | POST | `cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarSolicitudes/<literal-redactado>"` |  | application/xml · rule!PGM_Body_ConsultarSolicitudesActivasSGO() |  | QUERY | 0 |

### Club MAPFRE / teCuidamos (1)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_TeCuidamosAPI_TrebolesCliente` | PGM Clients EDGE | GET | `"/es_mkfd_tc_movil_app_be-web/api/tecuidamos/socios/consultaTreboles/" & ri!documento` | numDocumento=ri!documento |  | documento:Text | QUERY | 0 |

### Citrix / lanzaderas (4)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_CitrixAPI_Configuration_AWS` | (sin CS) | GET | `https://mwtlw5vss3okvqpbjka5xdjzhu0ceoay.lambda-url.eu-west-1.on.aws/` |  |  |  | QUERY | 0 |
| `PGM_CitrixAPI_DownloadFromPath` | PGM Citrix API | GET | `if( ri!dominio="DES000_PRE", cons!PGM_ENDPOINT_CITRIX_PRE, cons!PGM_ENDPOINT_CITRIX_PRO ) & ri!path` |  |  | path:Text,csrfToken:Text,sessionId:Text,ctxsAuthId:Text,ctxsDeviceId:Text,dominio:Text | MODIFY | 1: I:PGM_ListaRecursos_Citrix |
| `PGM_CitrixAPI_ListResources` | PGM Citrix API | POST | `if( ri!dominio="DES000_PRE", cons!PGM_ENDPOINT_CITRIX_PRE, cons!PGM_ENDPOINT_CITRIX_PRO ) & "Resources/List"` | resourcesDetails=full | application/json | csrfToken:Text,sessionId:Text,ctxsAuthId:Text,deviceId:Text,dominio:Text | QUERY | 1: R:PGM_ObtenerListaRecursos |
| `PGM_CitrixAPI_ListResources_AWS` | (sin CS) | GET | `https://mwtlw5vss3okvqpbjka5xdjzhu0ceoay.lambda-url.eu-west-1.on.aws/` |  |  | username:Text,password:Text,dominio:Text | QUERY | 1: R:PGM_ObtenerCredenciales |

### Inducciones (Verti / NSE / Leads) (1)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_NeuronaVerti_Inducir` | PGM_NeuronaVerti | POST | `/callcenter/WSSISNet` |  | text/xml · "<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/env | idSesion:Text,cliente:PGM_Cliente,producto:Text,numeroPoliza:Text,comentarios:Text,agente: | MODIFY | 0 |

### Documentación (DPVE / Exstream / Argumentario) (4)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_DPVE_Checks` | (sin CS) | POST | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/checks"` |  | application/json · { "questions": { { /*¿Cliente con grandes cuentas?*/ "questionId": 30 | clientId:Number (Integer) | QUERY | 1: PM:{'en_US': '', 'es': 'PGM_DPVE_Inicio'} |
| `PGM_DPVE_IntegralidadPrimas` | PGM Clients EDGE | GET | `/SR_TRC_be-web/api/nt21/integralidad/primas` | codCia=ri!codCia;codRamo=ri!codRamo;codIdioma=es_ES;idnAplicacion=PGM;mcaFisico=N |  | codRamo:Number (Integer),codCia:Number (Integer) | QUERY | 2: I:PGM_DPVE_FormularioPrincipal, R:PGM_DPVE_ObtenerPrimaMaximaMinima |
| `PGM_DPVE_IntegralityDiscountDetail` | PGM Integraciones | GET | `"esp/srv/api/clients/1.0/client/"&ri!IDCliente&"/integralityDiscountDetail"` | applicationCode=PGM |  | IDCliente:Text | QUERY | 2: R:PGM_DPVE_ClienteDuplicado, R:PGM_DPVE_ObtenerProductosContratados |
| `PGM_ExstreamDocumentation_comunication_V2` | (no verificado: LCP 500) | ? | `no verificado` |  |  |  | ? | 0 |

### Sin clasificar (9)

| Integración | CS | Método | URL / ruta | Query | Body (tipo) | Inputs | Uso | Consumidores |
|---|---|---|---|---|---|---|---|---|
| `PGM_BFF_DPV` | PGM BFF | POST | `/api-pgm/catalog/query` |  | application/json · { "catalogFilterParams": { "catalogId": ri!catalogId, "installationCod | token:Text,catalogId:Text,filters:Map[] | QUERY | 0 |
| `PGM_ClientsAPI_ChecksClientePorId` | (sin CS) | POST | `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/checks"` |  | application/json · { "questions": { { /*¿Cliente Empleado Mapfre?*/ "questionId":2 }, { / | clientId:Text | QUERY | 1: I:PGM_SeleccionIdContacto |
| `PGM_ClientsAPI_EDGE_ChecksClientePorId` | PGM Clients EDGE | POST | `"/mrcconsultaback_int-web/api/1.0/client/"&ri!clientId&"/checks"` |  | application/json · { "questions": { { /*¿Cliente Empleado Mapfre?*/ "questionId":2 }, { / | clientId:Text | QUERY | 6: I:PGM_NuevaActividadComercial, R:PGM_ClientePorID_Completo, R:PGM_CompletarInfoCliente … |
| `PGM_ClientsAPI_EDGE_exclusivoCorredor` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId &"/exclusiveAgentMessage"` |  |  | clientId:Text | QUERY | 4: R:PGM_Prueba_Respuesta404, R:PGM_R_GetAlertasPorIdCliente_Report, R:PGM_R_getInfoCliente … |
| `PGM_ClientsAPI_EDGE_modificarDireccionCliente` | PGM Clients EDGE | PUT | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/address/" & ri!address.addressId` |  | application/json · { "address": { "addressId": ri!address.addressId, "addressName": ri!ad | clientId:Text,clientNIF:Text,address:PGM_Cliente_AddressRM,nuuma:Text | MODIFY | 1: I:PGM_DatosDireccion |
| `PGM_ClientsEDGE_OrigenDatos` | PGM Clients EDGE | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/originData"` |  |  | clientId:Text | QUERY | 1: I:PGM_OrigenDeLosDatos |
| `PGM_ClientsMediation_Superbonus` | PGM Clients EDGE | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/bonus"` | policyId=ri!numPoliza |  | clientId:Text,numPoliza:Text | QUERY | 4: R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente, R:PGM_getInfoCliente_test … |
| `PGM_POST_cliente_record` | PGM loopback appian | POST | `infoCliente` |  | application/json · { "idCliente": ri!idCliente, "camposBusquedaAvanzada": ri!camposBusque | idCliente:Text,camposBusquedaAvanzada:Map,recargarFicha:Boolean,recargarRecord:Boolean,nuu | QUERY | 3: R:PGM_Comprobar_Flujo_idCliente, R:PGM_R_ClientePorID_Record, R:PGM_WebApi_SGC_LanzarProceso |
| `PGM_PerfiladoCliente` | (sin CS) | GET | `"https://"&cons!PGM_HOSTYPUERTO_MISV&"/NOVAServices/rest/RSPerfiladoCliente/obtenerPerfiladoCliente"` | USUARIO=ri!nuuma;APLICACION=PGM;NIF=rule!PGM_ArregloNIF_PFM(ri!documento);TIPO_PERSONA=F |  | documento:Text,nuuma:Text | QUERY | 3: R:PGM_Prueba_Respuesta404, R:PGM_R_getInfoCliente, R:PGM_getInfoCliente_test |

### Cabeceras observadas por integración (resumen)

| Cabecera | Nº integraciones |
|---|---|
| `Host` | 132 |
| `Accept-Language` | 86 |
| `Content-Type` | 66 |
| `Authorization` | 56 |
| `Accept` | 39 |
| `Connection` | 31 |
| `Accept-Encoding` | 29 |
| `SOAPAction` | 14 |
| `X-Request-applicationId` | 13 |
| `charset` | 12 |
| `X-Request-companyId` | 8 |
| `X-Citrix-IsUsingHTTPS` | 6 |
| `X-Request-processId` | 6 |
| `accept` | 5 |
| `X-Request-source` | 5 |
| `X-Request-distributionChannelCode` | 5 |
| `Cookie` | 4 |
| `Csrf-Token` | 4 |
| `ASP.NET_SessionId` | 4 |
| `" & "ASP.NET_SessionId` | 3 |
| `X-Request-applicationName` | 3 |
| `X-Request-internalUser` | 3 |
| `X-Request-issueCompanyId` | 3 |
| `X-Request-distributionChannel` | 3 |
| `" & "CtxsAuthId` | 2 |
| `endDate` | 2 |
| `X-Request-currencyIsoCode` | 2 |
| `USER-ID` | 2 |
| `username` | 1 |
| `password` | 1 |
| `environment` | 1 |
| `CtxsAuthId` | 1 |
| `" /*& "CtxsDeviceId` | 1 |
| `User-Agent` | 1 |
| `X-Request-countryCode` | 1 |
| `X-Request-entityCode` | 1 |
| `X-Request-insuranceBrokerCIF` | 1 |
| `User` | 1 |