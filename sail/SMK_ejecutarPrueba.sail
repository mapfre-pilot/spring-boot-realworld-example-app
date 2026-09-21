/* Dispatcher de pruebas de humo: dado el código de catálogo (SMK Test.codigo), ejecuta la prueba y devuelve
   el contrato común {resultado: OK|KO|WARN|SKIP, mensaje, detalle}.
   Para añadir una prueba: crear la integración/regla, añadir aquí su caso y dar de alta la fila en SMK Test. */
a!match(
  value: ri!codigo,
  equals: "DB_APPIAN_BUSINESS",
  then: a!localVariables(local!n: a!queryRecordType(recordType: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test', fields: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo', pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1), fetchTotalCount: true).totalCount, a!map(resultado: "OK", mensaje: "Consulta OK: " & local!n & " pruebas en catálogo", detalle: "")),
  equals: "S3_LIST_BUCKETS",
  then: rule!SMK_evaluarIntegracion(res: rule!SMK_INT_S3_ListBuckets(), mensajeOk: "List Buckets OK", detalleOk: ""),
  equals: "PLATAFORMA_PROCESO",
  then: a!map(resultado: "OK", mensaje: "Motor de procesos operativo; usuario " & loggedInUser(), detalle: ""),
  equals: "HTTP_API_GW_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_gw_core_pfgop_dev_es_plataforma_aws_mapfre_net()),
  equals: "HTTP_APISB_MAPFRE_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_apisb_mapfre_com()),
  equals: "HTTP_APISB_MAPFRE_NET_25003",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_apisb_mapfre_net_25003()),
  equals: "HTTP_APISBINT_MAPFRE_NET_26003",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_apisbint_mapfre_net_26003()),
  equals: "HTTP_WWW_APISB_MAPFRE_NET_25003",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_www_apisb_mapfre_net_25003()),
  equals: "HTTP_API_CLAIMS_DEV_REEF_HEALTH_ES_MAPFRE_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_claims_dev_reef_health_es_mapfre_com()),
  equals: "HTTP_API_PGM_DIGITAL_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM_26033",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_pgm_digital_private_pre_mapfredigitalhealth_com_26033()),
  equals: "HTTP_API_PRODUCT_SGC_DIGITAL_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM_443",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_product_sgc_digital_private_pre_mapfredigitalhealth_com_443()),
  equals: "HTTP_API_ATENEAES_MAPFREES_DEV_APPS_EMEA_AWS_MAPFRE_NET_25053",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_ateneaes_mapfrees_dev_apps_emea_aws_mapfre_net_25053()),
  equals: "HTTP_API_DIGITAL_DEV_MAPFREDIGITALHEALTH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_digital_dev_mapfredigitalhealth_com()),
  equals: "HTTP_API_GITHUB_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_github_com()),
  equals: "HTTP_API_TECUIDAMOS_PRE_MAPFREDIGITALHEALTH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_api_tecuidamos_pre_mapfredigitalhealth_com()),
  equals: "HTTP_APICONTEXT_TECUIDAMOS_PRE_MAPFREDIGITALHEALTH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_apicontext_tecuidamos_pre_mapfredigitalhealth_com()),
  equals: "HTTP_APIOAUTH_PLATFORM_PRE_MAPFREDIGITALHEALTH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_apioauth_platform_pre_mapfredigitalhealth_com()),
  equals: "HTTP_AYS_API_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25036",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_ays_api_core_pfgop_dev_es_plataforma_aws_mapfre_net_25036()),
  equals: "HTTP_BACKEND_PGO_MAPFRE_NET",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_backend_pgo_mapfre_net()),
  equals: "HTTP_BWCTC_CONECTA_ORANGE_ES",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_bwctc_conecta_orange_es()),
  equals: "HTTP_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM_26030",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_clientes_private_pre_mapfredigitalhealth_com_26030()),
  equals: "HTTP_CLOUD_UIPATH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_cloud_uipath_com()),
  equals: "HTTP_CLTV_ATENEA_ES_DATAPROD_DEV_EMEA_AWS_MAPFRE_NET_25052",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_cltv_atenea_es_dataprod_dev_emea_aws_mapfre_net_25052()),
  equals: "HTTP_CORE7_DESA_MAPFRE_NET_25007",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_core7_desa_mapfre_net_25007()),
  equals: "HTTP_CORE7_PRE_MAPFRE_NET_26007",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_core7_pre_mapfre_net_26007()),
  equals: "HTTP_CORE8_PRE_MAPFRE_NET_26025",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_core8_pre_mapfre_net_26025()),
  equals: "HTTP_CYC_API_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25037",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_cyc_api_core_pfgop_dev_es_plataforma_aws_mapfre_net_25037()),
  equals: "HTTP_DENODO_DESA_ES_MAPFRE_NET_25014",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_denodo_desa_es_mapfre_net_25014()),
  equals: "HTTP_DENODO_PREP_ES_MAPFRE_NET_26014",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_denodo_prep_es_mapfre_net_26014()),
  equals: "HTTP_ESB_DESA_MAPFRE_NET_25005",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esb_desa_mapfre_net_25005()),
  equals: "HTTP_ESB_PRE_MAPFRE_NET_26005",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esb_pre_mapfre_net_26005()),
  equals: "HTTP_ESP_CVM2_EMC_API_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25047",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_emc_api_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25047()),
  equals: "HTTP_ESP_CVM2_EMPLEADOSCOMERCIALES_BACKEND_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_250544",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_empleadoscomerciales_backend_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_250544()),
  equals: "HTTP_ESP_CVM2_ESC_API_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25048",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_esc_api_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25048()),
  equals: "HTTP_ESP_CVM2_ESTRUCTURACOMERCIAL_BACKEND_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25041",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_estructuracomercial_backend_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25041()),
  equals: "HTTP_ESP_CVM2_GES_API_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25045",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_ges_api_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25045()),
  equals: "HTTP_ESP_CVM2_GESTION_BFF_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25038",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_gestion_bff_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25038()),
  equals: "HTTP_ESP_CVM2_MED_API_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25046",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_med_api_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25046()),
  equals: "HTTP_ESP_CVM2_MEDIADORES_BACKEND_CORE_PFADMSOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25039",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_cvm2_mediadores_backend_core_pfadmsop_dev_es_plataforma_aws_mapfre_net_25039()),
  equals: "HTTP_ESP_PGOAPPP_GD_BACKEND_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25058",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_esp_pgoappp_gd_backend_core_pfgop_dev_es_plataforma_aws_mapfre_net_25058()),
  equals: "HTTP_EV_API_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25057",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_ev_api_core_pfgop_dev_es_plataforma_aws_mapfre_net_25057()),
  equals: "HTTP_GD_API_CORE_PFGOP_DEV_ES_PLATAFORMA_AWS_MAPFRE_NET_25043",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_gd_api_core_pfgop_dev_es_plataforma_aws_mapfre_net_25043()),
  equals: "HTTP_GRAPH_MICROSOFT_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_graph_microsoft_com()),
  equals: "HTTP_WEBSERVICES_DESA_MAPFRE_NET_25004_HTTP",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_webservices_desa_mapfre_net_25004_2()),
  equals: "HTTP_INT_DENODO_INF_ES_MAPFRE_NET_25051",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_int_denodo_inf_es_mapfre_net_25051()),
  equals: "HTTP_MISV_PRE_MAPFRE_NET_26024",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_misv_pre_mapfre_net_26024()),
  equals: "HTTP_NEURONA_PRE_VERTI_ES_MAPFRE_NET_26017",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_neurona_pre_verti_es_mapfre_net_26017()),
  equals: "HTTP_PRE_PLATAFORMARETOS_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_pre_plataformaretos_com()),
  equals: "HTTP_PREPROD_VERTI_ES",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_preprod_verti_es()),
  equals: "HTTP_SCGD_DESA_MAPFRE_NET_25012",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_scgd_desa_mapfre_net_25012()),
  equals: "HTTP_SCGD_PRE_MAPFRE_NET_26012",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_scgd_pre_mapfre_net_26012()),
  equals: "HTTP_SES000A103542_ES_MAPFRE_NET_25023",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_ses000a103542_es_mapfre_net_25023()),
  equals: "HTTP_SES000A107158_ES_MAPFRE_NET_25031",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_ses000a107158_es_mapfre_net_25031()),
  equals: "HTTP_SES000A204616_ES_MAPFRE_NET_26023",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_ses000a204616_es_mapfre_net_26023()),
  equals: "HTTP_SGC_ES_PRE_AZURE_MAPFRE_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_sgc_es_pre_azure_mapfre_com()),
  equals: "HTTP_SGC3_PRE_KEYVAULT_VAULT_AZURE_NET",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_sgc3_pre_keyvault_vault_azure_net()),
  equals: "HTTP_SOA7_DESA_MAPFRE_NET_25006",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_soa7_desa_mapfre_net_25006()),
  equals: "HTTP_SOA7_PRE_MAPFRE_NET_26006",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_soa7_pre_mapfre_net_26006()),
  equals: "HTTP_VBS70364_LIVE_DYNATRACE_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_vbs70364_live_dynatrace_com()),
  equals: "HTTP_VIRTUALAPPS_PRE_MAPFRE_NET_26009",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_virtualapps_pre_mapfre_net_26009()),
  equals: "HTTP_WEBSERVICES_DESA_MAPFRE_NET",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_webservices_desa_mapfre_net()),
  equals: "HTTP_WEBSERVICES_DESA_MAPFRE_NET_25004",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_webservices_desa_mapfre_net_25004()),
  equals: "HTTP_WEBSERVICES_PRE_MAPFRE_NET_26004",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_webservices_pre_mapfre_net_26004()),
  equals: "HTTP_WEBSERVICESEMISION_PRE_MAPFRE_NET_26040",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_webservicesemision_pre_mapfre_net_26040()),
  equals: "HTTP_WMAPFRE_PRE_MAPFRE_NET_26016",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_wmapfre_pre_mapfre_net_26016()),
  equals: "HTTP_WMBIG1IS_DESA_MAPFRE_NET_25018",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_wmbig1is_desa_mapfre_net_25018()),
  equals: "HTTP_WMBIG3IS_PRE_MAPFRE_NET_26019",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_wmbig3is_pre_mapfre_net_26019()),
  equals: "HTTP_WPORTALINTERNO_DESA_MAPFRE_NET_25001",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_wportalinterno_desa_mapfre_net_25001()),
  equals: "HTTP_WPORTALINTERNO_PRE_MAPFRE_NET_26001",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_wportalinterno_pre_mapfre_net_26001()),
  equals: "HTTP_WS_GDU_PRE_AZURE_MAPFRE_NET_25021",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_ws_gdu_pre_azure_mapfre_net_25021()),
  equals: "HTTP_MAPFRESPAIN_DEV_APPIANCLOUD_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_mapfrespain_dev_appiancloud_com()),
  equals: "HTTP_MAPFRESPAIN_NEWRELEASES_APPIANCLOUD_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_mapfrespain_newreleases_appiancloud_com()),
  equals: "HTTP_MAPFRESPAIN_TEST_APPIANCLOUD_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_mapfrespain_test_appiancloud_com()),
  equals: "DB_GCD_BBDD",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{56e061d7-c425-4e80-a8cc-f8d67cefdbf1}GCD Tipo Dato Erroneo',
      fields: {'recordType!{56e061d7-c425-4e80-a8cc-f8d67cefdbf1}GCD Tipo Dato Erroneo.fields.{057df37b-bd16-4626-be8e-2eda8f366c7e}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre GCD Tipo Dato Erroneo (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_ADM_ADM_ADMINISTRACION_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{2a7d4ca5-506a-404d-aeda-046f237f9cb9}ADM Log Servicios',
      fields: {'recordType!{2a7d4ca5-506a-404d-aeda-046f237f9cb9}ADM Log Servicios.fields.{a705a37f-94d9-4c47-8962-6b7574f82831}idlog'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre ADM Log Servicios (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_BDT_SC_ESQUEMA",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{3c7d04e1-f92b-408e-9ce4-175ac1ea80e9}BDT Asignacion',
      fields: {'recordType!{3c7d04e1-f92b-408e-9ce4-175ac1ea80e9}BDT Asignacion.fields.{26eec9ec-200b-4494-a703-1e8171800607}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre BDT Asignacion (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_BDE_BBDD",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{eaffca00-79ee-40f1-b22d-9ff109c3cde1}BDE Linea de Bitacora',
      fields: {'recordType!{eaffca00-79ee-40f1-b22d-9ff109c3cde1}BDE Linea de Bitacora.fields.{5db01b9d-3713-437d-bf40-70dcb37b60d9}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre BDE Linea de Bitacora (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CW_AURORA_POSTGRE",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{7e6a368d-4a2d-45be-a4b6-4e1b0b5b5282}CW Log Altas',
      fields: {'recordType!{7e6a368d-4a2d-45be-a4b6-4e1b0b5b5282}CW Log Altas.fields.{752ec676-b6e4-4993-bf15-46b5c484905f}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CW Log Altas (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CVA_CVA_CARTAVERDE_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{0f041f2d-8aa2-4852-b9d7-ef9070db4a4f}CVA Carta Verde',
      fields: {'recordType!{0f041f2d-8aa2-4852-b9d7-ef9070db4a4f}CVA Carta Verde.fields.{5356d123-0014-41a2-8da4-ccd8d34a482a}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CVA Carta Verde (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CD_CD_DELETEDOCUMENT_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{8e217851-f68a-4ae9-abd4-61489efdb752}CD Delete Document Event',
      fields: {'recordType!{8e217851-f68a-4ae9-abd4-61489efdb752}CD Delete Document Event.fields.{ac6895b0-e5fd-42a2-bb3b-691135f9d208}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CD Delete Document Event (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CMD_PRUEBA_DB",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{1d60aae3-4301-4f69-92fb-6adbe036a42d}CMD Record AWS',
      fields: {'recordType!{1d60aae3-4301-4f69-92fb-6adbe036a42d}CMD Record AWS.fields.{98e1546d-07c1-4d88-8b6e-f400a51a8480}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CMD Record AWS (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CMP_DB_ALTA_CLIENTE",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{5fa8a703-dfb5-487a-8875-45088da3b708}CMP Traza Alta Cliente',
      fields: {'recordType!{5fa8a703-dfb5-487a-8875-45088da3b708}CMP Traza Alta Cliente.fields.{8eb90b90-6136-41ec-b6ba-99be1832e67f}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CMP Traza Alta Cliente (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CMP_DB_MODIFICACION_CLIENTE",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{2e0f7c9f-4e19-4548-953f-09d937d5a02e}CMP Traza Modificacion Cliente',
      fields: {'recordType!{2e0f7c9f-4e19-4548-953f-09d937d5a02e}CMP Traza Modificacion Cliente.fields.{3f5a8b8c-7a21-4029-a2e9-0f5224ed35ba}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CMP Traza Modificacion Cliente (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CMP_CMP_COMPONENTES_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente',
      fields: {'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{ec503ab3-6965-4599-a2e0-6792a4d4e55b}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CMP Traza inducir cliente (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CMP_DB_FIRMA_RGPD",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{6b9a71e3-527f-4624-8eb5-223286506f5d}CMP Proposito',
      fields: {'recordType!{6b9a71e3-527f-4624-8eb5-223286506f5d}CMP Proposito.fields.{285274f2-9558-4e60-9939-3d8f0fe540cb}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CMP Proposito (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CMP_POSTGRES_VERTI",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{6372c298-2de2-455c-835a-1d63c863668f}CMP registroReintentosVerti',
      fields: {'recordType!{6372c298-2de2-455c-835a-1d63c863668f}CMP registroReintentosVerti.fields.{bd0203b3-b043-4ef1-becb-45135c28b17c}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CMP registroReintentosVerti (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_VIDA_AURORA",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{df4d29a6-23b9-4f6b-a08f-db5ae85f1cc7}VIDA Taller productos',
      fields: {'recordType!{df4d29a6-23b9-4f6b-a08f-db5ae85f1cc7}VIDA Taller productos.fields.{1f0eaceb-98df-45ca-9419-b39aab0eac6f}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre VIDA Taller productos (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_CDD_CDD_CONSULTADESCARGADOCS_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{f49edb0b-0c88-40ad-b15f-9a2c37889835}CDD Categoria',
      fields: {'recordType!{f49edb0b-0c88-40ad-b15f-9a2c37889835}CDD Categoria.fields.{d6665a26-3bfa-4d31-a05b-a00941b4f6a9}idCategoria'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre CDD Categoria (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PADS_DB_CVM2_PRC",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{3f60452e-da7a-4353-84b6-e5a20cd65374}PADS Task',
      fields: {'recordType!{3f60452e-da7a-4353-84b6-e5a20cd65374}PADS Task.fields.{399e6891-7897-49e4-8fcb-95cc0e5665fb}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PADS Task (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_EC_SISTEMA_CONECTADO_BD",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{9750acfd-d438-480b-a7ae-059a87bb4f04}EC PT Categoria',
      fields: {'recordType!{9750acfd-d438-480b-a7ae-059a87bb4f04}EC PT Categoria.fields.{2aa34706-9dff-4582-81f3-217893fc787e}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre EC PT Categoria (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_ECV_BASE_DE_DATOS_PRINCIPAL",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{de6dcd9e-dd8f-42ca-b66d-dc83350b1116}ECV Tipo Aportacion',
      fields: {'recordType!{de6dcd9e-dd8f-42ca-b66d-dc83350b1116}ECV Tipo Aportacion.fields.{4ca17bb3-9d47-4b91-a7c5-f114a3fdd9e6}idSeqTipAportacion'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre ECV Tipo Aportacion (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_EDA_SCHEMA_EDA",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{85626656-7839-4d9c-a33f-280512f14e3a}EDA Dgt',
      fields: {'recordType!{85626656-7839-4d9c-a33f-280512f14e3a}EDA Dgt.fields.{e5f272d8-755e-4004-a9d9-efc99c7ecfcb}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre EDA Dgt (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_EDPA_SCHEMA_EDPA",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{75782e8f-cea3-4cae-8cd2-7af92033428f}EDPA Apps',
      fields: {'recordType!{75782e8f-cea3-4cae-8cd2-7af92033428f}EDPA Apps.fields.{348f8579-9393-41ac-b69a-1fa60d6b5fff}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre EDPA Apps (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_GMP_SISTEMA_CONECTADO_BD",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{f9b711ae-fae6-45ff-b352-4f5cd6de0d19}GMP Notificaciones Email',
      fields: {'recordType!{f9b711ae-fae6-45ff-b352-4f5cd6de0d19}GMP Notificaciones Email.fields.{7b87e9f7-4f00-4a79-b557-9037a5253fbc}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre GMP Notificaciones Email (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_MBM_DB_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{d507a9e2-4776-4ca3-acd2-cacc46b24a6d}MBM CM Correos Leidos Hora',
      fields: {'recordType!{d507a9e2-4776-4ca3-acd2-cacc46b24a6d}MBM CM Correos Leidos Hora.fields.{1816807b-959a-4df1-b025-63998a4b6daf}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre MBM CM Correos Leidos Hora (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PAI_BASE_DE_DATOS_PRINCIPAL",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{ea15ed08-47b9-4117-9563-54cec525cd95}PAI Perfil',
      fields: {'recordType!{ea15ed08-47b9-4117-9563-54cec525cd95}PAI Perfil.fields.{0678382d-d6ad-4641-850f-27a5393b654a}id_sec_perfil'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PAI Perfil (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PGM_POSTGRESQL_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{5bd37a8d-a3db-4b8a-af31-56398f00c8d4}PGM_R_cliente_tmp',
      fields: {'recordType!{5bd37a8d-a3db-4b8a-af31-56398f00c8d4}PGM_R_cliente_tmp.fields.{de50edd6-4f02-463b-b455-165a68542fe7}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PGM_R_cliente_tmp (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PBT_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{39984687-1af1-44aa-b143-a9207894654b}PBT Tarea',
      fields: {'recordType!{39984687-1af1-44aa-b143-a9207894654b}PBT Tarea.fields.{f1a8eca8-d827-4851-ba3f-e7fd4d5e8258}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PBT Tarea (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PCP_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{ae565dbf-4fcf-4f54-946f-fce8d7716b70}PCP Catalogo',
      fields: {'recordType!{ae565dbf-4fcf-4f54-946f-fce8d7716b70}PCP Catalogo.fields.{14fa65a2-ce4f-4700-ae1d-67d525142c6a}cod'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PCP Catalogo (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PCC_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{187d6680-da7f-43b7-acda-6700106262a0}PMC KPI HistoricoCaso',
      fields: {'recordType!{187d6680-da7f-43b7-acda-6700106262a0}PMC KPI HistoricoCaso.fields.{d35e89c4-ed85-40d1-a4b6-6da6d0871836}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PMC KPI HistoricoCaso (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PEP_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{35a3699b-7a57-49e2-b329-ede8f4c66128}PEP Auditoria Grupo',
      fields: {'recordType!{35a3699b-7a57-49e2-b329-ede8f4c66128}PEP Auditoria Grupo.fields.{a796438b-e5a0-4dca-a06f-97b1d9268468}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PEP Auditoria Grupo (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PGT_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{64d6172b-d744-4579-b367-b086815f6879}PGT TipoTrabajo',
      fields: {'recordType!{64d6172b-d744-4579-b367-b086815f6879}PGT TipoTrabajo.fields.{fcb6458d-ce3a-4796-bda0-7750709d0d9e}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PGT TipoTrabajo (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PIC_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{6efc9a5b-36bb-4544-9cd0-33beaa5c945b}PIC Conf Asignacion',
      fields: {'recordType!{6efc9a5b-36bb-4544-9cd0-33beaa5c945b}PIC Conf Asignacion.fields.{6292d9cd-ea60-4477-98fb-17b32b042b73}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PIC Conf Asignacion (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_SCT_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{ac568da9-ef13-444d-8dbd-3032b3169934}SCT Caso',
      fields: {'recordType!{ac568da9-ef13-444d-8dbd-3032b3169934}SCT Caso.fields.{d7947b89-bb25-4e9e-ac73-cc156bb5528b}idCaso'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre SCT Caso (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_PRD_BASE_DE_DATOS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{8b557668-0623-4c84-9bcd-f45ef75aa9b3}PRD Tabla Decision',
      fields: {'recordType!{8b557668-0623-4c84-9bcd-f45ef75aa9b3}PRD Tabla Decision.fields.{f68c62df-1d60-42ce-9c2f-b122a14aafd5}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre PRD Tabla Decision (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_RH_RECURSOSH",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{73768a77-3756-4485-a4a8-96935c15b435}RH Sincronizacion M4',
      fields: {'recordType!{73768a77-3756-4485-a4a8-96935c15b435}RH Sincronizacion M4.fields.{68a048d4-c7a4-40c1-a96d-44cdc978b904}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre RH Sincronizacion M4 (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_RM_AURORA_POSTGRESQL",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{8d7df608-74d2-4007-a12e-e0d2f03bd01b}RM CacheCuestionarios',
      fields: {'recordType!{8d7df608-74d2-4007-a12e-e0d2f03bd01b}RM CacheCuestionarios.fields.{aa950c38-2d7e-4cae-b9cd-83df1221f004}codCuestionario'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre RM CacheCuestionarios (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_SCAC_AWS_DB",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{c8840e90-1653-450b-bf8c-225ee7acd0c4}SCA solicitudAnulacion',
      fields: {'recordType!{c8840e90-1653-450b-bf8c-225ee7acd0c4}SCA solicitudAnulacion.fields.{cf318bed-7373-40a3-ae76-69683cbba820}idsolicitud'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre SCA solicitudAnulacion (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_SGI_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{e9e986f2-5cbe-4407-9468-9297e999686c}SGI Catalogo NivelDos',
      fields: {'recordType!{e9e986f2-5cbe-4407-9468-9297e999686c}SGI Catalogo NivelDos.fields.{165e8b8a-4063-4492-b65f-3da86df8e6c2}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre SGI Catalogo NivelDos (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_SGO_SCHEMA_BBDD",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{a9ec0307-3cc8-4399-aa64-2795038bff38}SGO DocSoporte',
      fields: {'recordType!{a9ec0307-3cc8-4399-aa64-2795038bff38}SGO DocSoporte.fields.{7bf7421c-cdb0-4cc6-a80c-35af03c044f4}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre SGO DocSoporte (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_TM_DB_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{88378b30-8ce4-4918-b234-2a21b1e1713d}TM Job Type Transaction',
      fields: {'recordType!{88378b30-8ce4-4918-b234-2a21b1e1713d}TM Job Type Transaction.fields.{28be546d-2a44-4782-b505-4e74b534330f}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre TM Job Type Transaction (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "DB_VAC_AWS",
  then: a!localVariables(
    local!ds: a!queryRecordType(
      recordType: 'recordType!{a1039534-cc5b-4c5b-91ad-d2c3cdbc7e6b}VAC_PFW Action',
      fields: {'recordType!{a1039534-cc5b-4c5b-91ad-d2c3cdbc7e6b}VAC_PFW Action.fields.{5b145ba1-29f2-4be0-a842-93c88dd911e2}id'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true,
    ),
    a!map(
      resultado: "OK",
      mensaje: "Consulta OK sobre VAC_PFW Action (" & local!ds.totalCount & " filas)",
      detalle: ""
    )
  ),
  equals: "HTTP_LOGIN_MICROSOFTONLINE_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_LOGIN_MICROSOFTONLINE_COM)),
  equals: "HTTP_CONFIG_ZSCALER_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_CONFIG_ZSCALER_COM)),
  equals: "HTTP_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_PERFORMANCEMANAGER5_SUCCESSFACTORS_EU)),
  equals: "HTTP_API012_SUCCESSFACTORS_EU",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_API012_SUCCESSFACTORS_EU)),
  equals: "HTTP_RRPP_DGSFP_MINECO_ES",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_RRPP_DGSFP_MINECO_ES)),
  equals: "HTTP_HERMES_VIEW_MAPFRE_NET_25049",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_HERMES_VIEW_MAPFRE_NET_25049)),
  equals: "HTTP_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_APIATTRIBUTIONS_PRE_MAPFREDIGITALHEALTH_COM)),
  equals: "HTTP_API_PRODUCT_CLIENTS_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_API_PRODUCT_CLIENTS_CLIENTES_PRIVATE_PRE_MAPFREDIGITALHEALTH_COM)),
  equals: "HTTP_CORE7_DESA_MAPFRE_NET",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_CORE7_DESA_MAPFRE_NET)),
  equals: "HTTP_CF_DEV_BACK_3BIUBN3R_AUTHENTICATION_EU10_HANA_ONDEMAND_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_CF_DEV_BACK_3BIUBN3R_AUTHENTICATION_EU10_HANA_ONDEMAND_COM)),
  equals: "HTTP_MAPFRETECH_S_A_CF_DEV_BACK_3BIUBN3R_MAPFRE_BACK_DEV_BP32262ABD_CFAPPS_EU10_004_HANA_ONDEMAND_COM",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_MAPFRETECH_S_A_CF_DEV_BACK_3BIUBN3R_MAPFRE_BACK_DEV_BP32262ABD_CFAPPS_EU10_004_HANA_ONDEMAND_COM)),
  equals: "HTTP_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS",
  then: rule!SMK_evaluarHttp(rule!SMK_INT_HTTP_url(urlBase: cons!SMK_URL_MWTLW5VSS3OKVQPBJKA5XDJZHU0CEOAY_LAMBDA_URL_EU_WEST_1_ON_AWS)),
  default: a!map(resultado: "SKIP", mensaje: "Prueba no implementada en SMK_ejecutarPrueba: " & ri!codigo, detalle: "")
)