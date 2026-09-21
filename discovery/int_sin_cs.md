# Integraciones sin Connected System (DEV)

- **Total:** 110
- **Con host resoluble:** 74
- **Sin host resoluble:** 36
- **Hosts distintos (incluyendo puerto):** 26

## Hosts distintos

| Host | Integraciones | Aplicaciones | Cobertura SMK |
|---|---:|---|---|
| `10.255.255.1` | 1 | CMD Demo Componentes | No |
| `192.0.2.1` | 4 | CMD Demo Componentes | No |
| `api-product-clients.clientes.private.pre.mapfredigitalhealth.com` | 1 | CMD Demo Componentes | No |
| `api.github.com` | 7 | CMD Demo Componentes | Sí |
| `api012.successfactors.eu` | 1 | Procesos RRHH | No |
| `apiattributions.pre.mapfredigitalhealth.com` | 2 | PGM_MAPFRE | No |
| `apisb.mapfre.com` | 6 | CdC_MAPFRE, PGM_MAPFRE, SPA_MAPFRE | Sí |
| `apisb.mapfre.net:25003` | 21 | CMP Componentes, CST_MAPFRE, PGM_MAPFRE, SCA CORE, SPA_MAPFRE | Sí |
| `cf-dev-back-3biubn3r.authentication.eu10.hana.ondemand.com` | 1 | Procesos RRHH | No |
| `config.zscaler.com` | 1 | CMP Componentes | No |
| `core7.desa.mapfre.net` | 1 | SCA CORE | No |
| `core7.pre.mapfre.net:26007` | 3 | PGM_MAPFRE | Sí |
| `denodo-prep.es.mapfre.net:26014` | 2 | PGM_MAPFRE | Sí |
| `esb.pre.mapfre.net:26005` | 6 | PGM_MAPFRE | Sí |
| `hermes-view.mapfre.net:25049` | 1 | CMP Componentes | No |
| `login.microsoftonline.com` | 1 | PGO Datos de Prueba | No |
| `mapfrespain-dev.appiancloud.com` | 1 | Test Idoneidad | Sí |
| `mapfretech--s-a-cf-dev-back-3biubn3r-mapfre-back-dev-bp32262abd.cfapps.eu10-004.hana.ondemand.com` | 2 | Procesos RRHH | No |
| `misv.pre.mapfre.net:26024` | 1 | PGM_MAPFRE | Sí |
| `mwtlw5vss3okvqpbjka5xdjzhu0ceoay.lambda-url.eu-west-1.on.aws` | 2 | PGM_MAPFRE | No |
| `performancemanager5.successfactors.eu` | 2 | Procesos RRHH | No |
| `rrpp.dgsfp.mineco.es` | 2 | CVM2 | No |
| `sgc.es.pre.azure.mapfre.com` | 1 | SCA CORE | Sí |
| `soa7.desa.mapfre.net:25006` | 1 | PGM_MAPFRE | Sí |
| `webservices.pre.mapfre.net:26004` | 2 | PGM_MAPFRE | Sí |
| `wportalinterno.desa.mapfre.net:25001` | 1 | PGM_MAPFRE | Sí |

## Hosts no cubiertos por las pruebas HTTP SMK

- **`10.255.255.1`** (1 integraciones; apps: CMD Demo Componentes)
- **`192.0.2.1`** (4 integraciones; apps: CMD Demo Componentes)
- **`api-product-clients.clientes.private.pre.mapfredigitalhealth.com`** (1 integraciones; apps: CMD Demo Componentes)
- **`api012.successfactors.eu`** (1 integraciones; apps: Procesos RRHH)
- **`apiattributions.pre.mapfredigitalhealth.com`** (2 integraciones; apps: PGM_MAPFRE)
- **`cf-dev-back-3biubn3r.authentication.eu10.hana.ondemand.com`** (1 integraciones; apps: Procesos RRHH)
- **`config.zscaler.com`** (1 integraciones; apps: CMP Componentes)
- **`core7.desa.mapfre.net`** (1 integraciones; apps: SCA CORE)
- **`hermes-view.mapfre.net:25049`** (1 integraciones; apps: CMP Componentes)
- **`login.microsoftonline.com`** (1 integraciones; apps: PGO Datos de Prueba)
- **`mapfretech--s-a-cf-dev-back-3biubn3r-mapfre-back-dev-bp32262abd.cfapps.eu10-004.hana.ondemand.com`** (2 integraciones; apps: Procesos RRHH)
- **`mwtlw5vss3okvqpbjka5xdjzhu0ceoay.lambda-url.eu-west-1.on.aws`** (2 integraciones; apps: PGM_MAPFRE)
- **`performancemanager5.successfactors.eu`** (2 integraciones; apps: Procesos RRHH)
- **`rrpp.dgsfp.mineco.es`** (2 integraciones; apps: CVM2)

## Distribución por aplicación

| Aplicación | Integraciones |
|---|---:|
| PGM_MAPFRE | 38 |
| CMD Demo Componentes | 16 |
| SPA_MAPFRE | 14 |
| RM Riesgo Modular | 11 |
| CST_MAPFRE | 6 |
| Procesos RRHH | 6 |
| SCA CORE | 5 |
| CMP Componentes | 3 |
| CdC_MAPFRE | 3 |
| CVM2 | 2 |
| PGO Datos de Prueba | 2 |
| CapturaWeb | 1 |
| Minsait Utilities | 1 |
| Tarificador Vida Ahorro | 1 |
| Test Idoneidad | 1 |

## URLs sin host resoluble

Estas filas conservan la expresión cruda o indican que `getIntegration` no devolvió URL; no se ha inferido ningún host.

- **CW_Conectar_oAuth_token** (`CapturaWeb`): `rule!MU_Conectar_URL_APIBusiness(forzarPreEnDev: ri!forzarPreEnDev) & "auth/oauth/v2/token"`
- **CMD_Test_8443** (`CMD Demo Componentes`): `(vacío/no disponible)`
- **CMD_IntegrationTest** (`CMD Demo Componentes`): `ri!url`
- **CMD_DescargarLogs** (`CMD Demo Componentes`): `(vacío/no disponible)`
- **MU_Conectar_oAuth_token** (`Minsait Utilities`): `rule!MU_Conectar_URL_APIBusiness(forzarPreEnDev: ri!forzarPreEnDev) & "auth/oauth/v2/token"`
- **PGM_ServiciosSGO_ConsultarSolicitudes** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarSolicitudes/com_mapfre_sgo_ws_ConsultarSolicitudes_Port"`
- **PGM_ServiciosSGO_ConsultarDocumentos** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarDocumentos/com_mapfre_sgo_ws_ConsultarDocumentos_Port"`
- **PGM_ServiciosSGO_ConsultarSolicitudes_Interfaz** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarSolicitudes/com_mapfre_sgo_ws_ConsultarSolicitudes_Port"`
- **PGM_ConsultarDatosAgente** (`PGM_MAPFRE`): `cons!PGM_HOST_CONSULTARAGENTE & "/ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0"`
- **PGM_ClientsAPI_PolizasClientePorIdCarrusel** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/policies"`
- **PGM_GestionarACI_crearCliente** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_API_ACI & "/olvido/usuario/crear_cliente"`
- **PGM_DPVE_Checks** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/checks"`
- **PGM_AccesoSGO** (`PGM_MAPFRE`): `cons!PGM_ENDPOINT_APPIAN & "/suite/webapi/abrir-detalle-solicitud"`
- **PDP_Prueba_Adaptador** (`PGO Datos de Prueba`): `(vacío/no disponible)`
- **RM_API_Clients_search** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_APIBusiness(forzarPreEnDev: true) & "esp/srv/api/clients/1.0/clients/search"`
- **RM_Conectar_oAuth_token** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_APIBusiness(forzarPreEnDev: ri!forzarPreEnDev) & "auth/oauth/v2/token"`
- **RM_WSDL_Gesycore_ConsultarRecibosPoliza** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "gesycore_servicios_bbe-web/services/consultarRecibosPoliza"`
- **RM_API_NT21_precontrato_aviso** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "SR_TRC_be-web/api/nt21/precontrato/aviso"`
- **RM_WSDL_DescargarDocPrecon** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "IDDPredoc_be-web/ws/consultarDocumentosPrecontractuales_v2"`
- **RM_WSDL_Gesycore_ObtenerIDPResolutiva** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "gesycore_servicios_bbe-web/services/obtenerIDPResolutiva"`
- **RM_WSDL_Gesycore_ObtenerSiguienteIdentificador** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "DT_be-web/ws/GestionarDomiciliacionTarjeta"`
- **RM_WSDL_Gesycore_RecuperarDatosAsociados** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: ri!forzarPreEnDev) & "DT_be-web/ws/GestionarDomiciliacionTarjeta"`
- **RM_WSDL_ConsultarEstadoFirmaRefExterna** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "FIRDOCE-web/ws/consultarEstadoSolicitudFirmasService"`
- **RM_WSDL_BSExecuteQuery** (`RM Riesgo Modular`): `rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "SERVICIOSBASICOS/services/BSExecuteQuery"`
- **RM_WSDL_IGestionarPerfilUsuario** (`RM Riesgo Modular`): `rule!MU_Conectar_URL_SOA7(forzarPreEnDev: true) & "MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL"`
- **SCAC_tokenSGC3** (`SCA CORE`): `(vacío/no disponible)`
- **SPA_Mapfre_Integracion_GestorConf** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Eliminar** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Modificar** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Autos** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Modificar_Autos** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Eliminar_Autos** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Salud** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Modificar_Salud** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **SPA_Mapfre_Integracion_GestorConf_Eliminar_Salud** (`SPA_MAPFRE`): `rule!SPA_Mapfre_Tarificador_Generar(...)`
- **TVA_WSDL_IGestionarPerfilUsuario** (`Tarificador Vida Ahorro`): `rule!MU_Conectar_URL_SOA7(forzarPreEnDev: true) & "MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL"`

## Integraciones demo/test

- **CMD_Test_8443** (`CMD Demo Componentes`): host `(sin host)`; URL `(no disponible)`
- **CMD_timeout** (`CMD Demo Componentes`): host `10.255.255.1`; URL `https://10.255.255.1`
- **CMD_HeadOidGithub** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/graphql`
- **CMD_CommitPushGithub** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/graphql`
- **CMD_HeadOidGithubPackage** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/graphql`
- **CMD_CommitPushGithubPackage** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/graphql`
- **CMD_PRGithub** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/graphql`
- **CMD_IdGithubRepo** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/graphql`
- **CMD_ObtenerPatches** (`CMD Demo Componentes`): host `api.github.com`; URL `https://api.github.com/repos/mapfre-tech/esp-appiantest-devops-github/contents/package/patches.xml?ref=release/package`
- **CMD_IntegrationTest** (`CMD Demo Componentes`): host `(sin host)`; URL `ri!url`
- **CMD_Timeout_3** (`CMD Demo Componentes`): host `192.0.2.1`; URL `http://192.0.2.1`
- **CMD_Timeout_6** (`CMD Demo Componentes`): host `192.0.2.1`; URL `http://192.0.2.1`
- **CMD_Timeout_9** (`CMD Demo Componentes`): host `192.0.2.1`; URL `http://192.0.2.1`
- **CMD_DescargarLogs** (`CMD Demo Componentes`): host `(sin host)`; URL `(no disponible)`
- **CMD_ErrorsHandlingDynatrace_TimeOut** (`CMD Demo Componentes`): host `192.0.2.1`; URL `http://192.0.2.1`
- **CMD_PruebaBFF_remoteManagerInfo** (`CMD Demo Componentes`): host `api-product-clients.clientes.private.pre.mapfredigitalhealth.com`; URL `https://api-product-clients.clientes.private.pre.mapfredigitalhealth.com/`
- **CMP_APIGW_newToken_TEST** (`CMP Componentes`): host `apisb.mapfre.net:25003`; URL `https://apisb.mapfre.net:25003/auth/oauth/v2/token`
- **PDP_Prueba_Adaptador** (`PGO Datos de Prueba`): host `(sin host)`; URL `(no disponible)`
- **SCAC_prueba2** (`SCA CORE`): host `sgc.es.pre.azure.mapfre.com`; URL `https://sgc.es.pre.azure.mapfre.com/external/api/1.0/tasks`

## Fallos o respuestas no disponibles

- `CMD_Test_8443`: `getIntegration` devolvió HTTP 500 por `Unmatched open bracket [`; URL/host no disponibles.
- `CMD_DescargarLogs`: la UUID vigente de inventario no pudo recuperar URL en la llamada previa (HTTP 404 observado con UUID antigua); se conserva URL/host no disponibles.
- `PDP_Prueba_Adaptador` y `SCAC_tokenSGC3`: `properties.url` es nulo.

## Resolución de expresiones y autenticación

- 57 URLs contienen `cons!`, `rule!` o `ri!`; se conserva la expresión exacta.
- Se resolvieron de forma segura constantes de endpoint para CST (`CST_C_TXT_ENDPOINT_APICLIENTES`), CMP (`CMP_HERMES_URL`), PGM (API Clients, APIS, CORE7, DENODO, API ACI, ESB y MISV) y RRHH M4 (token y endpoint). Los hosts resultantes se reflejan en JSON aunque `urlRaw` mantiene la expresión original.
- Permanecen sin resolver las expresiones basadas en reglas y constantes sin correspondencia segura, especialmente WebServices/SGO y algunas reglas de conexión; no se inventó ningún host.
- No se copiaron headers, cuerpos, tokens, passwords, client secrets ni API keys. El campo `auth` contiene únicamente metadatos seguros (`authType` y presencia de expresión).
- La comparación de cobertura es sensible al puerto: por ejemplo, `apisb.mapfre.net` y `apisb.mapfre.net:25003` se contabilizan como hosts distintos.
