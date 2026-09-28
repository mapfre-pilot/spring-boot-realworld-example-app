# Hallazgos SMK — dev — 2026-09-28T00:48Z

Connected Systems: 231 · Record types: 736 · Pruebas en catálogo base: 124 · Integraciones sin CS: 114

## Nuevos desde el último snapshot (2)
- SCA2 DataBase AWS (system.[DataSource].[AuroraPostgreSqlConnectedSystem]) — apps: SCA2 Sistema Comercial de Anulaciones
- SMK Database AWS (system.[DataSource].[AuroraPostgreSqlConnectedSystem]) — apps: SMK Pruebas de Humo

## Desaparecidos (2)
- PAI_SistTest (system.http)
- PPP Proxy API GW (system.http)

## URL cambiada (3)
- GCD Denodo: http://denodo-desa.es.mapfre.net:25014/ → https://denodo-desa.es.mapfre.net:25056/
- RH GD Corporativo: https://alb.appian.es.int.emea.aws.mapfre.net:443/ → https://alb.appian.es.int.emea.aws.mapfre.net/
- SGI UiPath: https://cloud.uipath.com/MAPFRE_AC/M_Spain/orchestrator_/t/65495ac6-f8bd-4ee4-b4c0-2ea8e7666e7a/Test_ArgumentosAppian → https://cloud.uipath.com/MAPFRE_AC/M_Spain/orchestrator_/t/65495ac6-f8bd-4ee4-b4c0-2ea8e7666e7a/

## Sin prueba de humo en el catálogo (12)
- [DB] LCK DB AWS — apps: (LCK) Object Locking — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [PLUGIN] BDE Conexión Sharepoint — apps: Bitácora de Empresas — Revisar manualmente: operación de lectura del plugin
- [PLUGIN] CMD TEST Conexión AWS S3 2 — apps: CMD Demo Componentes — Revisar manualmente: operación de lectura del plugin
- [DB] CMD Prueba orafi053 — apps: CMD Demo Componentes — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [PLUGIN] CMP Obtener IP — apps: CMP Componentes — Revisar manualmente: operación de lectura del plugin
- [DB] CMP DB Plan Familia — apps: CMP Plan Familia — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] CMP DB Respuesta Componente — apps: CMP Respuesta Componente — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] FAS Schema FAS — apps: FAS Ficha Ampliada de Socio — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] SCA2 DataBase AWS — apps: SCA2 Sistema Comercial de Anulaciones — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] SMK Database AWS — apps: SMK Pruebas de Humo — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] TVA BD Aurora PostgreSQL — apps: Tarificador Vida Ahorro — Sin record types dependientes: no hay consulta read-only posible sin crear objetos
- [DB] TI Aurora PostgreSQL — apps: Test Idoneidad — Sin record types dependientes: no hay consulta read-only posible sin crear objetos

## Integraciones sin Connected System con URL literal (50)
- CdC_ClientAPI_BusquedaClientes (CdC_MAPFRE) — apisb.mapfre.com — HTTP_APISB_MAPFRE_COM — cubierto — Constante SMK_URL_APISB_MAPFRE_COM + integración SMK_INT_HTTP_apisb_mapfre_com sin CS → código HTTP_APISB_MAPFRE_COM
- CMD_timeout (CMD Demo Componentes) — 10.255.255.1 — HTTP_10_255_255_1 — sin cobertura — Constante SMK_URL_10_255_255_1 + integración SMK_INT_HTTP_10_255_255_1 sin CS → código HTTP_10_255_255_1
- CMD_CommitPushGithub (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CdC_APIClientes_Login (CdC_MAPFRE) — apisb.mapfre.com — HTTP_APISB_MAPFRE_COM — cubierto — Constante SMK_URL_APISB_MAPFRE_COM + integración SMK_INT_HTTP_apisb_mapfre_com sin CS → código HTTP_APISB_MAPFRE_COM
- CMD_HeadOidGithub (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CMD_HeadOidGithubPackage (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CMD_PRGithub (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CMD_CommitPushGithubPackage (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CMD_ObtenerPatches (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CMD_IdGithubRepo (CMD Demo Componentes) — api.github.com — HTTP_API_GITHUB_COM — cubierto — Constante SMK_URL_API_GITHUB_COM + integración SMK_INT_HTTP_api_github_com sin CS → código HTTP_API_GITHUB_COM
- CMD_Timeout_6 (CMD Demo Componentes) — 192.0.2.1 — HTTP_192_0_2_1 — sin cobertura — Constante SMK_URL_192_0_2_1 + integración SMK_INT_HTTP_192_0_2_1 sin CS → código HTTP_192_0_2_1
- CMD_Timeout_3 (CMD Demo Componentes) — 192.0.2.1 — HTTP_192_0_2_1 — sin cobertura — Constante SMK_URL_192_0_2_1 + integración SMK_INT_HTTP_192_0_2_1 sin CS → código HTTP_192_0_2_1
- CMD_Timeout_9 (CMD Demo Componentes) — 192.0.2.1 — HTTP_192_0_2_1 — sin cobertura — Constante SMK_URL_192_0_2_1 + integración SMK_INT_HTTP_192_0_2_1 sin CS → código HTTP_192_0_2_1
- CMD_PruebaBFF_remoteManagerInfo (CMD Demo Componentes) — api-product-clients.clientes.private.pre.mapfredigitalhealth.com — HTTP_API_PRODUCT_CLIENTS_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM — cubierto — Constante SMK_URL_API_PRODUCT_CLIENTS_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM + integración SMK_INT_HTTP_api_product_clients_clientes_private_pre_mapfredigitalhealth_com sin CS → código HTTP_API_PRODUCT_CLIENTS_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM
- CMD_ErrorsHandlingDynatrace_TimeOut (CMD Demo Componentes) — 192.0.2.1 — HTTP_192_0_2_1 — sin cobertura — Constante SMK_URL_192_0_2_1 + integración SMK_INT_HTTP_192_0_2_1 sin CS → código HTTP_192_0_2_1
- CMP_APIGW_newToken_TEST (CMP Componentes) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- CMP_GetZscalerIps (CMP Componentes) — config.zscaler.com — HTTP_CONFIG_ZSCALER_COM — cubierto — Constante SMK_URL_CONFIG_ZSCALER_COM + integración SMK_INT_HTTP_config_zscaler_com sin CS → código HTTP_CONFIG_ZSCALER_COM
- PADS_POST_DGSFP_GetMediadores (CVM2) — rrpp.dgsfp.mineco.es — HTTP_RRPP_DGSFP_MINECO_ES — cubierto — Constante SMK_URL_RRPP_DGSFP_MINECO_ES + integración SMK_INT_HTTP_rrpp_dgsfp_mineco_es sin CS → código HTTP_RRPP_DGSFP_MINECO_ES
- PADS_POST_DGSFP_GetAltosCargos (CVM2) — rrpp.dgsfp.mineco.es — HTTP_RRPP_DGSFP_MINECO_ES — cubierto — Constante SMK_URL_RRPP_DGSFP_MINECO_ES + integración SMK_INT_HTTP_rrpp_dgsfp_mineco_es sin CS → código HTTP_RRPP_DGSFP_MINECO_ES
- PGM_CitrixAPI_ListResources_AWS (PGM_MAPFRE) — mwtlw5vss3okvqpbjka5xdjzhu0ceoay.lambda-url.eu-west-1.on.aws — HTTP_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS — cubierto — Constante SMK_URL_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS + integración SMK_INT_HTTP_mwtlw5vss3okvqpbjka5xdjzhu0ceoay_lambda_url_eu_west_1_on_aws sin CS → código HTTP_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS
- PGM_CitrixAPI_Configuration_AWS (PGM_MAPFRE) — mwtlw5vss3okvqpbjka5xdjzhu0ceoay.lambda-url.eu-west-1.on.aws — HTTP_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS — cubierto — Constante SMK_URL_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS + integración SMK_INT_HTTP_mwtlw5vss3okvqpbjka5xdjzhu0ceoay_lambda_url_eu_west_1_on_aws sin CS → código HTTP_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS
- PGM_ServiciosHogar_ConsultarPoliza (PGM_MAPFRE) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- PGM_ServiciosVida_ConsultarProductor (PGM_MAPFRE) — soa7.desa.mapfre.net — HTTP_SOA7_DESA_MAPFRE_NET_25006 — cubierto — Constante SMK_URL_SOA7_DESA_MAPFRE_NET_25006 + integración SMK_INT_HTTP_soa7_desa_mapfre_net_25006 sin CS → código HTTP_SOA7_DESA_MAPFRE_NET_25006
- PGM_ServiciosSGC_ConsultarGestiones (PGM_MAPFRE) — core7.pre.mapfre.net — HTTP_CORE7_PRE_MAPFRE_NET_26007 — cubierto — Constante SMK_URL_CORE7_PRE_MAPFRE_NET_26007 + integración SMK_INT_HTTP_core7_pre_mapfre_net_26007 sin CS → código HTTP_CORE7_PRE_MAPFRE_NET_26007
- PGM_BDEC_ObtenerDatosMediadorSalud (PGM_MAPFRE) — wportalinterno.desa.mapfre.net — HTTP_WPORTALINTERNO_DESA_MAPFRE_NET_25001 — cubierto — Constante SMK_URL_WPORTALINTERNO_DESA_MAPFRE_NET_25001 + integración SMK_INT_HTTP_wportalinterno_desa_mapfre_net_25001 sin CS → código HTTP_WPORTALINTERNO_DESA_MAPFRE_NET_25001
- PGM_ServiciosRecibos_IOperarAgrupaciones (PGM_MAPFRE) — esb.pre.mapfre.net — HTTP_ESB_PRE_MAPFRE_NET_26005 — cubierto — Constante SMK_URL_ESB_PRE_MAPFRE_NET_26005 + integración SMK_INT_HTTP_esb_pre_mapfre_net_26005 sin CS → código HTTP_ESB_PRE_MAPFRE_NET_26005
- PGM_GestionarLeads_SAVIA (PGM_MAPFRE) — apiattributions.pre.mapfredigitalhealth.com — HTTP_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM — cubierto — Constante SMK_URL_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM + integración SMK_INT_HTTP_apiattributions_pre_mapfredigitalhealth_com sin CS → código HTTP_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM
- PGM_ServiciosRecibos_EnvioAlBanco (PGM_MAPFRE) — esb.pre.mapfre.net — HTTP_ESB_PRE_MAPFRE_NET_26005 — cubierto — Constante SMK_URL_ESB_PRE_MAPFRE_NET_26005 + integración SMK_INT_HTTP_esb_pre_mapfre_net_26005 sin CS → código HTTP_ESB_PRE_MAPFRE_NET_26005
- PGM_ConsultarDetalleSiniestro (PGM_MAPFRE) — esb.pre.mapfre.net — HTTP_ESB_PRE_MAPFRE_NET_26005 — cubierto — Constante SMK_URL_ESB_PRE_MAPFRE_NET_26005 + integración SMK_INT_HTTP_esb_pre_mapfre_net_26005 sin CS → código HTTP_ESB_PRE_MAPFRE_NET_26005
- PGM_ServiciosRecibos_ImprimirDuplicado (PGM_MAPFRE) — esb.pre.mapfre.net — HTTP_ESB_PRE_MAPFRE_NET_26005 — cubierto — Constante SMK_URL_ESB_PRE_MAPFRE_NET_26005 + integración SMK_INT_HTTP_esb_pre_mapfre_net_26005 sin CS → código HTTP_ESB_PRE_MAPFRE_NET_26005
- PGM_GestionarSolicitudesAnulacion (PGM_MAPFRE) — core7.pre.mapfre.net — HTTP_CORE7_PRE_MAPFRE_NET_26007 — cubierto — Constante SMK_URL_CORE7_PRE_MAPFRE_NET_26007 + integración SMK_INT_HTTP_core7_pre_mapfre_net_26007 sin CS → código HTTP_CORE7_PRE_MAPFRE_NET_26007
- PGM_GestionarLeads_SAVIA_V2 (PGM_MAPFRE) — apiattributions.pre.mapfredigitalhealth.com — HTTP_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM — cubierto — Constante SMK_URL_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM + integración SMK_INT_HTTP_apiattributions_pre_mapfredigitalhealth_com sin CS → código HTTP_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM
- PGM_APICatalogo_DPVE (PGM_MAPFRE) — webservices.pre.mapfre.net — HTTP_WEBSERVICES_PRE_MAPFRE_NET_26004 — cubierto — Constante SMK_URL_WEBSERVICES_PRE_MAPFRE_NET_26004 + integración SMK_INT_HTTP_webservices_pre_mapfre_net_26004 sin CS → código HTTP_WEBSERVICES_PRE_MAPFRE_NET_26004
- PGM_DPVE_CatalogoProductos (PGM_MAPFRE) — webservices.pre.mapfre.net — HTTP_WEBSERVICES_PRE_MAPFRE_NET_26004 — cubierto — Constante SMK_URL_WEBSERVICES_PRE_MAPFRE_NET_26004 + integración SMK_INT_HTTP_webservices_pre_mapfre_net_26004 sin CS → código HTTP_WEBSERVICES_PRE_MAPFRE_NET_26004
- PGM_PGO (PGM_MAPFRE) — clientes.private.pre.mapfredigitalhealth.com — HTTP_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM_26030 — cubierto — Constante SMK_URL_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM_26030 + integración SMK_INT_HTTP_clientes_private_pre_mapfredigitalhealth_com_26030 sin CS → código HTTP_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM_26030
- PCC_GetTokenEntraId (PGO Datos de Prueba) — login.microsoftonline.com — HTTP_LOGIN_MICROSOFTONLINE_COM — cubierto — Constante SMK_URL_LOGIN_MICROSOFTONLINE_COM + integración SMK_INT_HTTP_login_microsoftonline_com sin CS → código HTTP_LOGIN_MICROSOFTONLINE_COM
- RH_SSFF_GetToken (Procesos RRHH) — performancemanager5.successfactors.eu — HTTP_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU — cubierto — Constante SMK_URL_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU + integración SMK_INT_HTTP_performancemanager5_successfactors_eu sin CS → código HTTP_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU
- RH_SSFF_GetAssertion (Procesos RRHH) — performancemanager5.successfactors.eu — HTTP_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU — cubierto — Constante SMK_URL_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU + integración SMK_INT_HTTP_performancemanager5_successfactors_eu sin CS → código HTTP_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU
- RH_SSFF_JobRequisition (Procesos RRHH) — api012.successfactors.eu — HTTP_API012_SUCCESSFACTORS_EU — cubierto — Constante SMK_URL_API012_SUCCESSFACTORS_EU + integración SMK_INT_HTTP_api012_successfactors_eu sin CS → código HTTP_API012_SUCCESSFACTORS_EU
- SCAC_prueba2 (SCA CORE) — sgc.es.pre.azure.mapfre.com — HTTP_SGC_ES_PRE_AZURE_MAPFRE_COM — cubierto — Constante SMK_URL_SGC_ES_PRE_AZURE_MAPFRE_COM + integración SMK_INT_HTTP_sgc_es_pre_azure_mapfre_com sin CS → código HTTP_SGC_ES_PRE_AZURE_MAPFRE_COM
- SCAC_obtenerTokenRetosRESTIntegracion (SCA CORE) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- SCAC_IGenerarContraAnul (SCA CORE) — core7.desa.mapfre.net — HTTP_CORE7_DESA_MAPFRE_NET — cubierto — Constante SMK_URL_CORE7_DESA_MAPFRE_NET + integración SMK_INT_HTTP_core7_desa_mapfre_net sin CS → código HTTP_CORE7_DESA_MAPFRE_NET
- SCAC_asignarRetosRESTIntegracion (SCA CORE) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- SGO_DocumentoABase64 (Sistema Gestión Operativa) — localhost — HTTP_LOCALHOST_8080 — sin cobertura — Constante SMK_URL_LOCALHOST_8080 + integración SMK_INT_HTTP_localhost_8080 sin CS → código HTTP_LOCALHOST_8080
- SPA_Mapfre_Integracion_APIMotor_Marcas (SPA_MAPFRE) — apisb.mapfre.com — HTTP_APISB_MAPFRE_COM — cubierto — Constante SMK_URL_APISB_MAPFRE_COM + integración SMK_INT_HTTP_apisb_mapfre_com sin CS → código HTTP_APISB_MAPFRE_COM
- SPA_Mapfre_Integracion_APIMotor_MarcasVehiculos (SPA_MAPFRE) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- SPA_MotorAPI_Login_V3 (SPA_MAPFRE) — apisb.mapfre.com — HTTP_APISB_MAPFRE_COM — cubierto — Constante SMK_URL_APISB_MAPFRE_COM + integración SMK_INT_HTTP_apisb_mapfre_com sin CS → código HTTP_APISB_MAPFRE_COM
- SPA_MotorAPI_Login (SPA_MAPFRE) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- SPA_Mapfre_MotorAPI_Login (SPA_MAPFRE) — apisb.mapfre.net — HTTP_APISB_MAPFRE_NET_25003 — cubierto — Constante SMK_URL_APISB_MAPFRE_NET_25003 + integración SMK_INT_HTTP_apisb_mapfre_net_25003 sin CS → código HTTP_APISB_MAPFRE_NET_25003
- TI_InicioTIdesdeWebAPI (Test Idoneidad) — mapfrespain-dev.appiancloud.com — HTTP_MAPFRESPAIN_DEV_APPIANCLOUD_COM — cubierto — Constante SMK_URL_MAPFRESPAIN_DEV_APPIANCLOUD_COM + integración SMK_INT_HTTP_mapfrespain_dev_appiancloud_com sin CS → código HTTP_MAPFRESPAIN_DEV_APPIANCLOUD_COM

## URL no resoluble en integraciones sin Connected System (64)
- CMD_Test_8443 (CMD Demo Componentes) — None — API error (HTTP 500): Error getting integration: Failed to convert body expression to display form: Expression evaluation error : Unmatched open bracket [


Con
- CW_Conectar_oAuth_token (CapturaWeb) — rule!MU_Conectar_URL_APIBusiness(forzarPreEnDev: ri!forzarPreEnDev) & "auth/oauth/v2/token" — URL nula, relativa o expresión cons!/rule!/ri!
- CdC_ClientAPI_DatosClientePorID (CdC_MAPFRE) — "https://apisb.mapfre.com/esp/srv/api/clients/1.0/client/"&ri!clientId — URL nula, relativa o expresión cons!/rule!/ri!
- CMD_IntegrationTest (CMD Demo Componentes) — ri!url — URL nula, relativa o expresión cons!/rule!/ri!
- CMD_DescargarLogs (CMD Demo Componentes) — None — URL nula, relativa o expresión cons!/rule!/ri!
- MAPFRE_CST_I_ClientAPI_BusquedaClientes (CST_MAPFRE) — cons!CST_C_TXT_ENDPOINT_APICLIENTES & "esp/srv/api/clients/1.0/clients/search" — URL nula, relativa o expresión cons!/rule!/ri!
- CMP_GetHermesIps (CMP Componentes) — cons!CMP_HERMES_URL — URL nula, relativa o expresión cons!/rule!/ri!
- MAPFRE_CST_I_ClientAPI_DatosClientePorID (CST_MAPFRE) — cons!CST_C_TXT_ENDPOINT_APICLIENTES & "esp/srv/api/clients/1.0/client/" & ri!clientId — URL nula, relativa o expresión cons!/rule!/ri!
- MAPFRE_CST_APIClientes_Login (CST_MAPFRE) — cons!CST_C_TXT_ENDPOINT_APICLIENTES & "auth/oauth/v2/token" — URL nula, relativa o expresión cons!/rule!/ri!
- MAPFRE_CST_I_ClientAPI_numPoliza (CST_MAPFRE) — cons!CST_C_TXT_ENDPOINT_APICLIENTES & "esp/srv/api/clients/1.0/client/" & ri!clientId & "/detailedPolicies" — URL nula, relativa o expresión cons!/rule!/ri!
- MAPFRE_CST_I_ClientAPI_TelefonoEmail (CST_MAPFRE) — cons!CST_C_TXT_ENDPOINT_APICLIENTES &"esp/srv/api/clients/1.0/client/"&ri!clientId&"/contactMethods" — URL nula, relativa o expresión cons!/rule!/ri!
- MAPFRE_CST_I_ClientsApi_PerfilCliente (CST_MAPFRE) — cons!CST_C_TXT_ENDPOINT_APICLIENTES & "esp/srv/api/clients/1.0/client/" & ri!clientId & "/profile" — URL nula, relativa o expresión cons!/rule!/ri!
- MU_Conectar_oAuth_token (Minsait Utilities) — rule!MU_Conectar_URL_APIBusiness(forzarPreEnDev: ri!forzarPreEnDev) & "auth/oauth/v2/token" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_PerfilClientePorId (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/profile" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_PrestacionesClientePorId (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/claims" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_PresupuestosClientePorId (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/projects" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_PolizasClientePorId (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/detailedPolicies" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_Login (PGM_MAPFRE) — cons!PGM_ENDPOINT_APIS & "/auth/oauth/v2/token" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_MetodosIdentificacionClientePorId (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/identificationMethods" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_Validar_Mail (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/email" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_crearClienteACI (PGM_MAPFRE) — cons!PGM_ENDPOINT_CORE7&"/ClienteOIM_CCFSARegistro_HTTPRouter/IRegistrarClientesOIM" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ServiciosSGO_ConsultarSolicitudes (PGM_MAPFRE) — cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarSolicitudes/com_mapfre_sgo_ws_ConsultarSolicitudes_Port" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ServiciosSGO_ConsultarDocumentos (PGM_MAPFRE) — cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarDocumentos/com_mapfre_sgo_ws_ConsultarDocumentos_Port" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ServiciosSGO_ConsultarSolicitudes_Interfaz (PGM_MAPFRE) — cons!PGM_ENDPOINT_WMBIG2IS&"/ws/com.mapfre.sgo.ws.ConsultarSolicitudes/com_mapfre_sgo_ws_ConsultarSolicitudes_Port" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ConsultarDatosAgente (PGM_MAPFRE) — cons!PGM_HOST_CONSULTARAGENTE & "/ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_InduccionVerti_No_NSE (PGM_MAPFRE) — cons!PGM_HOST_ESB&"/FDC_SMEDWeb/sca/wIConsultarIntegraciones" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_PresupuestosClientePorDocumentoYNPpto (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/projects" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_ReclamacionesClientePorId (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS &"/client/" & ri!clientId & "/complaints" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ObtenerEstructurasComercialesNuuma (PGM_MAPFRE) — cons!PGM_HOST_ESB&"/ESTRUAGE_ConsDatEstructura_SMEDWeb/sca/WSESTREstructura" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_PerfiladoCliente (PGM_MAPFRE) — "https://"&cons!PGM_HOSTYPUERTO_MISV&"/NOVAServices/rest/RSPerfiladoCliente/obtenerPerfiladoCliente" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsAPI_PolizasClientePorIdCarrusel (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/policies" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsEDGE_productsDetail (PGM_MAPFRE) — cons!PGM_ENDPOINT_DENODO & "/server/vfdc/client/views/productsDetail" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_ClientsEDGE_products (PGM_MAPFRE) — "http://denodo-prep.es.mapfre.net:26014" & "/server/vfdc/client/views/productsDetail" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_GestionarACI_crearCliente (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_ACI & "/olvido/usuario/crear_cliente" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_DPVE_Checks (PGM_MAPFRE) — cons!PGM_ENDPOINT_API_CLIENTS&"/client/" & ri!clientId & "/checks" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_AccesoSGO (PGM_MAPFRE) — cons!PGM_ENDPOINT_APPIAN & "/suite/webapi/abrir-detalle-solicitud" — URL nula, relativa o expresión cons!/rule!/ri!
- PGM_getDesignCSV (PGM_MAPFRE) — cons!PGM_CONS_ENTORNO & "logs/design_errors.csv" — URL nula, relativa o expresión cons!/rule!/ri!
- PDP_Prueba_Adaptador (PGO Datos de Prueba) — None — URL nula, relativa o expresión cons!/rule!/ri!
- RH_M4_Sincro_GetTabla (Procesos RRHH) — rule!RH_M4_Sincro_URLConParametros(
  nombreTabla: ri!nombreTabla,
  select: ri!select,
  filter: ri!filter,
  top: ri!top,
  skip: ri!skip
) — URL nula, relativa o expresión cons!/rule!/ri!
- RH_M4_Sincro_GetToken (Procesos RRHH) — cons!RH_M4_SINCRO_TOKEN_ENDPOINT — URL nula, relativa o expresión cons!/rule!/ri!
- RH_M4_Sincro_GetTablaCount (Procesos RRHH) — cons!RH_M4_SINCRO_ENDPOINT & upper(ri!nombreTabla) & "/$count" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_API_Clients_search (RM Riesgo Modular) — rule!RM_Conectar_URL_APIBusiness(forzarPreEnDev: true) & "esp/srv/api/clients/1.0/clients/search" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_Conectar_oAuth_token (RM Riesgo Modular) — rule!RM_Conectar_URL_APIBusiness(forzarPreEnDev: ri!forzarPreEnDev) & "auth/oauth/v2/token" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_Gesycore_ConsultarRecibosPoliza (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "gesycore_servicios_bbe-web/services/consultarRecibosPoliza" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_API_NT21_precontrato_aviso (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "SR_TRC_be-web/api/nt21/precontrato/aviso" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_Gesycore_ObtenerSiguienteIdentificador (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "DT_be-web/ws/GestionarDomiciliacionTarjeta" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_DescargarDocPrecon (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "IDDPredoc_be-web/ws/consultarDocumentosPrecontractuales_v2" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_Gesycore_ObtenerIDPResolutiva (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "gesycore_servicios_bbe-web/services/obtenerIDPResolutiva" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_Gesycore_RecuperarDatosAsociados (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: ri!forzarPreEnDev) & "DT_be-web/ws/GestionarDomiciliacionTarjeta" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_ConsultarEstadoFirmaRefExterna (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "FIRDOCE-web/ws/consultarEstadoSolicitudFirmasService" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_BSExecuteQuery (RM Riesgo Modular) — rule!RM_Conectar_URL_WebServices(forzarPreEnDev: true) & "SERVICIOSBASICOS/services/BSExecuteQuery" — URL nula, relativa o expresión cons!/rule!/ri!
- RM_WSDL_IGestionarPerfilUsuario (RM Riesgo Modular) — rule!MU_Conectar_URL_SOA7(forzarPreEnDev: true) & "MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL" — URL nula, relativa o expresión cons!/rule!/ri!
- SCAC_tokenSGC3 (SCA CORE) — None — URL nula, relativa o expresión cons!/rule!/ri!
- SMK_INT_HTTP_url (SMK Pruebas de Humo) — ri!urlBase & "/smk-smoke-probe" — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Eliminar (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Modificar (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion:ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Autos (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Modificar_Autos (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Eliminar_Autos (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Salud (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Modificar_Salud (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- SPA_Mapfre_Integracion_GestorConf_Eliminar_Salud (SPA_MAPFRE) — rule!SPA_Mapfre_Tarificador_Generar(
  previsualizacion: ri!gestor_configuraciones.previsualizacion
) — URL nula, relativa o expresión cons!/rule!/ri!
- TVA_WSDL_IGestionarPerfilUsuario (Tarificador Vida Ahorro) — rule!MU_Conectar_URL_SOA7(forzarPreEnDev: true) & "MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL" — URL nula, relativa o expresión cons!/rule!/ri!
## Runner (ejecución 6, 2026-09-28 00:52Z, motivo "Descubrimiento semanal Devin", origen AUTOMATICO)
109 OK · 4 KO · 1 WARN de 114 (ejecución anterior 5, 2026-09-22: 111 OK · 2 KO · 1 WARN).
- Regresiones OK → KO: HTTP_PRE_PLATAFORMARETOS_COM (al repetir la prueba con testRule responde OK/404: fallo transitorio) y HTTP_RRPP_DGSFP_MINECO_ES (sigue KO al repetir: sin respuesta HTTP del host rrpp.dgsfp.mineco.es).
- KO ya existentes: HTTP_API_PRODUCT_CLIENTS_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM, HTTP_CORE7_DESA_MAPFRE_NET. WARN ya existente: PLATAFORMA_PROCESO (latencia 2251 ms > 2000 ms).

## Acciones realizadas
- Nuevos CS de BD con record types dependientes (el script no los detecta porque listRecordTypes no devuelve dataSourceUuid; comprobado con getRecordType): creadas las pruebas DB_SCA2_DATABASE_AWS (record type SCA2 Solicitud, 21 filas) y DB_SMK_DATABASE_AWS (record type SMK Test, 124 filas) en SMK_ejecutarPrueba y SMK_catalogoBase, validadas con testRule (OK), e insertadas en SMK_TEST (DEV) con activo=false, origenAlta DESCUBRIMIENTO (ids 125 y 126). La activación es manual desde Catálogo.
- URL cambiada: GCD Denodo (fila HTTP_DENODO_DESA_ES_MAPFRE_NET_25014 → sistema/nombre denodo-desa.es.mapfre.net:25056), RH GD Corporativo (HTTP_WS_GDU_PRE_AZURE_MAPFRE_NET_25021 → sin puerto :443) actualizadas en SMK_catalogoBase y en SMK_TEST (DEV). SGI UiPath: solo cambia el path base (host cloud.uipath.com igual); anotado en la descripción. Las tres pruebas responden OK tras el cambio.
- Desaparecidos: PPP Proxy API GW (fila HTTP_API_GW_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET, ya inactiva; anotado en SMK_catalogoBase; la integración SMK_INT_HTTP_api_gw_core_pfgop_dev_es_plataforma_aws_mapfre_net queda sin CS y debe revisarse/eliminarse a mano) y PAI_SistTest (host ficticio, sin prueba en catálogo; nada que hacer).
- Sin cobertura viable (solo informe): 7 CS de BD sin record types (LCK DB AWS, CMD Prueba orafi053, CMP DB Plan Familia, CMP DB Respuesta Componente, FAS Schema FAS, TVA BD Aurora PostgreSQL, TI Aurora PostgreSQL) y 3 plugins (BDE Conexión Sharepoint, CMD TEST Conexión AWS S3 2, CMP Obtener IP).
