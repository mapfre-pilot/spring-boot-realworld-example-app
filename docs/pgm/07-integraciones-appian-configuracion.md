# PGM en Appian → pestaña «Configuración» de la nueva aplicación

> Generado desde `inventario/integraciones.csv` y `inventario/sistemas-conectados.md` (objetos de PGM_MAPFRE en Appian TEST, 19/10/2026). Sirve para **sacar las credenciales de cada connected system en Appian Designer** (Objects → Connected Systems) y **rellenar la pestaña Configuración** (Servicios y credenciales) de la SPA. Appian TEST apunta a los servicios de **PRE**: en Configuración elige *Entorno de los servicios = PRE*.

## 1. Cómo probar la SPA contra los servicios legacy de PGM

1. Arranca con el perfil `pruebas`: `$env:PGM_PERFIL="pruebas"` antes de `podman compose … up` (o `PGM_PERFIL=pruebas` en Linux). En ese perfil el **Origen de datos** por defecto es `LEGACY` y la «llamada directa» está activada (sin API Gateway).
2. Entra en **Configuración → Servicios y credenciales** y, para cada servicio de la tabla 2, pega las credenciales del connected system de Appian (usuario/contraseña Basic, client id/secret OAuth o API key) y confirma la «URL PRE». Pulsa **Probar conexión**.
3. En **Configuración → Origen de datos** deja `LEGACY` global (o por capacidad) y el entorno `PRE`.
4. Para volver a API Canal basta con cambiar el origen a `API_CANAL`; no hace falta reiniciar.

> La «llamada directa» existe solo para pruebas desde un puesto sin Gateway. En DEV/PRE/PRO el BFF sale siempre por el API Gateway interno (ARCH-FIS-COM-001) y la casilla debe estar desactivada.

## 2. Connected systems de PGM ↔ servicio de la pestaña Configuración

| Connected system (Appian) | URL base en TEST (= PRE) | Auth en Appian | Servicio en Configuración | Qué rellenar | Nº integraciones |
|---|---|---|---|---|---|
| `PGM Clients EDGE` | `https://webservices.pre.mapfre.net:26004` | Basic | `clients-edge` | Basic → `usuario` / `password` (URL PRE `https://webservices.pre.mapfre.net:26004`) | 52 |
| `PGM_MapfreDigitalHealth` | `https://clientes.private.pre.mapfredigitalhealth.com:26030` | None | `pgo` | API key → `apiKey` (cabecera `x-api-key`, `USER-ID`={nuuma}) | 19 |
| `PGM_SGC3.0` | `https://sgc.es.pre.azure.mapfre.com` | OAuth Client Credentials Grant | `sgc30` | OAuth client credentials → `clientId` / `clientSecret`; cabecera `NUUMA` | 16 |
| `PGM iMediador EDGE` | `https://wportalinterno.pre.mapfre.net:26001/iMediador_be-web/sgc-imediador` | Basic | `imediador` | Basic en Appian → en la pestaña `apiKey` o cambiar tipo a Basic (`usuario`/`password`) | 11 |
| `PGM BFF` | `https://api-pgm.digital.private.pre.mapfredigitalhealth.com:26033` | OAuth Client Credentials Grant | `aci` | OAuth client credentials (PGM BFF TOKEN) → servicio `aci`/Cliente Total: `clientId` / `clientSecret` | 10 |
| `CMP API WLCatalog` | `https://esb.pre.mapfre.net:26005/ARQ_CATALOG_SMEDWeb/sca/wICatalog` | None | `wlcatalog` | Sin auth en Appian (ESB) → tipo NINGUNA o Basic si el Gateway lo exige | 9 |
| `PGM Integraciones` | `https://apisb.mapfre.net:25003/` | None | `home-api` | OAuth client credentials (PGM_APIGW_newToken) → `clientId` / `clientSecret` | 8 |
| `PGM Citrix API` | `https://virtualapps.pre.mapfre.net:26009/Citrix/APIWeb/` | None | `-` | Lanzadera Citrix (cookie de sesión del usuario): URL en «URLs de lanzaderas» (`PGM_ENDPOINT_VIRTUALAPPS`), sin credencial de servicio | 5 |
| `PGM Health API` | `https://apisb.mapfre.com/esp/srv/api/health/1.0` | None | `health-api` | OAuth client credentials (token apisb) → `clientId` / `clientSecret` | 5 |
| `PGM API WLCatalog` | `https://esb.pre.mapfre.net:26005/ARQ_CATALOG_SMEDWeb/sca/wICatalog` | None | `wlcatalog` | ídem | 3 |
| `PGM Clients EDGE Recibos` | `http://denodo-prep.es.mapfre.net:26014` | Basic | `clients-edge-recibos` | Basic → `usuario` / `password` (Denodo PRE) | 3 |
| `PGM Life Risk API` | `https://webservices.pre.mapfre.net:26004` | Basic | `life-api` | Basic → `usuario` / `password` | 3 |
| `PGM loopback appian` | `https://mapfrespain-test.appiancloud.com/suite/webapi/` | API Key | `appian` | API key de Web APIs de Appian → sección «Conexión con Appian» → `apiKey` | 3 |
| `PGM API Portal Interno` | `https://wportalinterno.pre.mapfre.net:26001/` | Basic | `bdec` | Basic → mismas credenciales que BDEC (wportalinterno) | 2 |
| `PGM Pre-registro ACI` | `https://apisb.mapfre.net:25003/esp/srv/api/aci/1.0/seguridad/login` | Basic | `aci` | Basic de pre-registro ACI → `usuario` / `password` (si se usa en lugar de OAuth) | 2 |
| `PGM_NeuronaVerti` | `https://neurona-pre.verti.es.mapfre.net:26017` | None | `firma` | Inducción Verti (WSSISNet): usuario/contraseña de servicio → pendiente de servicio propio | 2 |
| `CMP API ESB` | `https://esb.pre.mapfre.net:26005/` | None | `wlcatalog` | ESB consultarDatosAgente: misma conexión ESB | 1 |
| `CMP LoopBack` | `https://mapfrespain-test.appiancloud.com/suite/webapi/` | API Key | `appian` | ídem | 1 |
| `PGM BDEC API` | `https://wportalinterno.pre.mapfre.net:26001` | Basic | `bdec` | Basic → `usuario` / `password` | 1 |
| `PGM Client API` | `https://apisb.mapfre.net:25003/esp/srv/api/clients/1.0` | OAuth Client Credentials Grant | `client-api` | OAuth client credentials → `clientId` / `clientSecret`; cabeceras `tokenUrl`, `scope` | 1 |
| `PGM MotorAPI Login` | `https://apisb.mapfre.net:25003/auth/authorize/login` | Basic | `motor-api` | Basic del login del Motor API: usar `clientId` / `clientSecret` del servicio `motor-api` | 1 |
| `PGM PGM Life Risk API DUPLICADO` | `https://webservices.pre.mapfre.net:26004` | Basic | `gesyc` | Basic → `usuario` / `password` (imprimirRecibo) | 1 |
| `PGM WMAPFRE` | `https://wmapfre.pre.mapfre.net:26016` | Basic | `firma` | Basic → `usuario` / `password` (crosselling/creatividades) | 1 |
| `PGM_ConectaOrange` | `https://bwctc.conecta.orange.es` | None | `click2call` | Basic XSI → `usuario` / `password` | 1 |
| `PGM_KeyVault_SGC3.0` | `https://sgc3-pre-keyvault.vault.azure.net/` | OAuth Client Credentials Grant | `sgc30` | KeyVault de cifrado de SGC 3.0: mismas credenciales OAuth (pendiente de confirmar con SGC) | 1 |
| `PGM_iMediadorEDGE_AltaNGA` | `https://wportalinterno.pre.mapfre.net:26001/sgc_bbe-web/sgc/` | Basic | `imediador` | mismas credenciales que iMediador EDGE | 1 |
| `PGM BFF TOKEN` | `https://apioauth.platform.pre.mapfredigitalhealth.com` | None | `aci` | URL del token del BFF de Digital Health → cabecera `tokenUrl` del servicio | 0 |
| `PGM Health API 2.0` | `https://apisb.mapfre.com/esp/srv/api/health/2.0` | None | `health-api` | mismas credenciales que Health API 1.0 (cambia la URL base a /health/2.0) | 0 |
| `PGM Motor API` | `https://apisb.mapfre.net:25003/srv/api/1.0/motor/` | OAuth Client Credentials Grant | `motor-api` | OAuth client credentials → `clientId` / `clientSecret` | 0 |
| `PGM PostgreSQL AWS` | `—` | — | `-` | Caché PostgreSQL propia de Appian: no se migra (PGM no es dueño de datos) | 0 |
| `PGM_Comercialización_Seguros_NSE` | `http://webservices.pre.mapfre.net:26004/` | None | `-` | NSE emisión Verti: sin auth en Appian; pendiente de ruta Gateway | 0 |
| `PGM_SCDG` | `https://scgd.pre.mapfre.net:26012` | Basic | `firma` | Basic → `usuario` / `password` | 0 |
| `PGM_WebApi_SGC_Prueba` | `None` | OAuth Client Credentials Grant | `-` | Conexión de prueba, no usada | 0 |

## 3. Integraciones por connected system (método y ruta tal y como están en Appian)

Las rutas con `ri!` son parámetros de la integración. La columna «Capacidad en la nueva app» indica qué pantalla/servicio del BFF la usa cuando el origen es `LEGACY`.


### `PGM Clients EDGE` → servicio `clients-edge` (52)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_APISCA_ObtenerArgumentario` | POST | `"/sca_servicios/api/1.0/compania/"&ri!compania&"/poliza/"&ri!poliza&"/argumento"` | — |
| `PGM_ClientsAPI_EDGE_AvisosClientePorId` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId &"/alerts"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_BankingPosition` | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId & "/bankingPosition"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_CarterizacionClientePorId` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId &"/remoteManagerInfo"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_ChecksClientePorId` | POST | `"/mrcconsultaback_int-web/api/1.0/client/"&ri!clientId&"/checks"` | — |
| `PGM_ClientsAPI_EDGE_DatosClientePorId` | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_DescuentoVinculacion` | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId & "/integralityDiscountDetail"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_DireccionesClientePorId` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/addresses"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_MasDatosCliente` | PUT | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/contactMethod/" & ri!motivoContacto & "-" & ri!metodoContacto` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_MetodosContactoClientePorId` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/contactMethods"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_Obtener_ClienteTotal` | GET | `"/MRCConsultaBack_be-web/api/1.0/client/"&ri!clientId&"/representedCompanies?clientTypeCode="&ri!clientTypeCode&""` | Cliente Total |
| `PGM_ClientsAPI_EDGE_PerfilClientePorId` | GET | `"/MRCConsultaBack_be-web/api/1.0/client/" & ri!clientId & "/profile"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_PolizasClientePorIdCarrusel` | GET | `"/MRCBack_be-web/api/1.0/client/"& ri!clientId & "/policies"` | Posición › pólizas |
| `PGM_ClientsAPI_EDGE_exclusivoCorredor` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId &"/exclusiveAgentMessage"` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_EDGE_modificarDireccionCliente` | PUT | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/address/" & ri!address.addressId` | Ficha 360 (clientes) |
| `PGM_ClientsAPI_Interaction` | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` | Centro de comunicaciones |
| `PGM_ClientsAPI_Interaction_Santander_Alta` | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` | Centro de comunicaciones |
| `PGM_ClientsAPI_Interaction_Santander_Baja` | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` | Centro de comunicaciones |
| `PGM_ClientsAPI_Interaction_Verti` | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` | Centro de comunicaciones |
| `PGM_ClientsEDGE_ActualizarNacionalidad` | POST | `/mrcconsultaback_int-web/api/1.0/client/modification` | — |
| `PGM_ClientsEDGE_ActualizarPreferenciasContacto` | POST | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/preferenceContactChannel"` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_BorrarContactMethod` | DELETE | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/contactMethod/" & ri!motivoContacto & "-" & ri!metodoContacto` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_ContactoBDC` | POST | `/mrcconsultaback_int-web/api/1.0/client/interaction` | Centro de comunicaciones |
| `PGM_ClientsEDGE_Crosselling` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/crosselling"` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_EliminarDirecciones` | DELETE | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/address/" & ri!address` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_Informacion_externa` | POST | `/MRCConsultaBack_be-web/api/1.0/client/externalInformation` | — |
| `PGM_ClientsEDGE_InteracionesClientePorId` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/interactions?startDate=" & text(today() - 1096, "dd/mm/yyyy") & "&endDate=" & text(today(), "dd/mm/yyyy")` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_OrigenDatos` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/originData"` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_PreferenciasContacto` | GET | `"/mrcconsultaback_int-web/api/1.0/client/" & ri!clientId & "/preferenceContactChannels"` | Ficha 360 (clientes) |
| `PGM_ClientsEDGE_Search` | POST | `/mrcconsultaback_int-web/api/1.0/clients/search` | Buscador (clientes) |
| `PGM_ClientsMediation_BeneficiosClientePorId` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/benefits"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_DescuentoIntegralidadPorDocumento` | POST | `/api_negocioclientes_int-web/api/1.0/client/integralityDiscountPercent` | — |
| `PGM_ClientsMediation_EncuestasClientePorId` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/surveys"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_MetodosIdentificacionClientePorId` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/identificationMethods"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_PrestacionesClientePorId` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/claims"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_PresupuestosClientePorDocumentoYNPpto` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/projects"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_PresupuestosClientePorId` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/projects"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_ReclamacionesClientePorId` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/complaints"` | Ficha 360 (clientes) |
| `PGM_ClientsMediation_Superbonus` | GET | `"/api_negocioclientes_int-web/api/1.0/client/" & ri!clientId & "/bonus"` | Ficha 360 (clientes) |
| `PGM_ComercializacionSeguros_Polizas` | POST | `"/evt21_nse_serv_emi/api/1.0/poliza/"&ri!numeroPoliza&"/verti"` | — |
| `PGM_DPVE_IntegralidadPrimas` | GET | `/SR_TRC_be-web/api/nt21/integralidad/primas` | Plan de pagos (DPVE) |
| `PGM_DPVE_Integralidad_Simulacion` | POST | `/SR_TRC_be-web/api/nt21/clientes/integralidad/simulacion` | Plan de pagos (DPVE) |
| `PGM_GestionarSiniestroAutos` | GET | `/es_aupr_atn_mets_be-web/api/2.0/autos/siniestro/search_by_exp` | — |
| `PGM_GestionarSiniestroAutos_Prestacion` | GET | `/es_aupr_atn_mets_be-web/api/2.0/autos/siniestro/prestacion/search_by_exp` | — |
| `PGM_ServiciosRecibos_ConsultarDatosRecibo` | POST | `/gesycore_servicios_bbe-web/services/consultarRecibo` | — |
| `PGM_SignatureManagemen_Search` | POST | `/consentimientos_be-web/api/1.0/consent/request/search` | Firmar RGPD |
| `PGM_SignatureManagemen_Search_Baja` | POST | `/consentimientos_be-web/api/1.0/consent/request/search` | Firmar RGPD |
| `PGM_SignatureManagemen_cancellation` | DELETE | `"/consentimientos_be-web/api/1.0/consent/request/"&ri!requestId&"/cancellation"` | Firmar RGPD |
| `PGM_SignatureManagemen_request` | POST | `/consentimientos_be-web/api/1.0/consent/request` | Firmar RGPD |
| `PGM_TeCuidamosAPI_ObtenerIdSocio` | GET | `/es_mkfd_tc_movil_app_be-web/api/tecuidamos/socios/beneficios` | — |
| `PGM_TeCuidamosAPI_TrebolesCliente` | GET | `"/es_mkfd_tc_movil_app_be-web/api/tecuidamos/socios/consultaTreboles/" & ri!documento` | — |
| `PGM_informacionUsuario_grupos` | POST | `/SERVICIOSWEBPI/services/InformacionUsuario` | — |

### `?` → servicio `-` (48)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_APICatalogo_DPVE` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_AccesoSGO` | GET | `—` | Bandeja SGO |
| `PGM_BFF_Token` | — | `—` | — |
| `PGM_CitrixAPI_Configuration_AWS` | GET | `—` | Lanzadera Citrix |
| `PGM_CitrixAPI_ListResources_AWS` | GET | `—` | Lanzadera Citrix |
| `PGM_ClientsAPI_AvisosClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_BankingPosition` | GET | `—` | — |
| `PGM_ClientsAPI_BeneficiosClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_BusquedaClientes` | POST | `—` | — |
| `PGM_ClientsAPI_BusquedaClientes_Rendimiento` | POST | `—` | — |
| `PGM_ClientsAPI_CarterizacionClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_ChecksClientePorId` | POST | `—` | — |
| `PGM_ClientsAPI_DatosClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_DescuentoIntegralidadPorDocumento` | POST | `—` | — |
| `PGM_ClientsAPI_DireccionesClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_EncuestasClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_InteraccionesClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_Login` | POST | `—` | — |
| `PGM_ClientsAPI_MetodosContactoClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_MetodosIdentificacionClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_PerfilClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_PolizasClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_PolizasClientePorIdCarrusel` | GET | `—` | — |
| `PGM_ClientsAPI_PrestacionesClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_PresupuestosClientePorDocumentoYNPpto` | GET | `—` | — |
| `PGM_ClientsAPI_PresupuestosClientePorId` | GET | `—` | — |
| `PGM_ClientsAPI_ReclamacionesClientePorId` | GET | `—` | — |
| `PGM_ClientsEDGE_products` | GET | `—` | — |
| `PGM_ClientsEDGE_productsDetail` | GET | `—` | — |
| `PGM_ConsultarDatosAgente` | POST | `—` | — |
| `PGM_ConsultarDetalleSiniestro` | POST | `—` | — |
| `PGM_DPVE_Checks` | POST | `—` | — |
| `PGM_DPVE_GenerarDocumentacion` | — | `—` | — |
| `PGM_ExstreamDocumentation_comunication_V2` | — | `—` | — |
| `PGM_GestionarACI_crearCliente` | POST | `—` | — |
| `PGM_GestionarLeads_SAVIA_V2` | POST | `—` | — |
| `PGM_GestionarSolicitudesAnulacion` | POST | `—` | — |
| `PGM_InduccionVerti_No_NSE` | POST | `—` | — |
| `PGM_PGO` | GET | `—` | — |
| `PGM_PerfiladoCliente` | GET | `—` | — |
| `PGM_ServiciosHogar_ConsultarPoliza` | POST | `—` | — |
| `PGM_ServiciosRecibos_EnvioAlBanco` | POST | `—` | — |
| `PGM_ServiciosRecibos_IOperarAgrupaciones` | POST | `—` | — |
| `PGM_ServiciosSGC_ConsultarGestiones` | POST | `—` | — |
| `PGM_ServiciosSGO_ConsultarDocumentos` | POST | `—` | Bandeja SGO |
| `PGM_ServiciosSGO_ConsultarSolicitudes` | POST | `—` | Bandeja SGO |
| `PGM_ServiciosSGO_ConsultarSolicitudes_Interfaz` | POST | `—` | Bandeja SGO |
| `PGM_ServiciosVida_ConsultarProductor` | POST | `—` | — |

### `PGM_MapfreDigitalHealth` → servicio `pgo` (19)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_DigitalHealth_ActualizacionVencimientoCompleto` | PATCH | `"/apipgo/opportunity/complete/" & ri!opportunityId` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_ActualizarVencimientoIncompleto` | PATCH | `"/apipgo/opportunity/incomplete/" & ri!opportunityId` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_ActualizarVencimientoSalud` | POST | `/apipgo/opportunity/health` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_AltaVencimientoIncompleto` | POST | `/apipgo/opportunity/incomplete` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_AnadirObservacion` | POST | `"/apipgo/opportunity/" & ri!opportunityId & "/observation"` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_AñadirDocumento` | POST | `/apipgo/opportunity/attachment` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_DetalleVencimiento` | GET | `"/apipgo/opportunity/" & ri!opportunityId` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_EditarObservacion` | PUT | `"/apipgo/opportunity/" & ri!opportunityId & "/observation/" & ri!ObservacionId` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_EliminarDocumento` | DELETE | `"/apipgo/opportunity/" & ri!opportunityId &"/attachment/" & ri!attachment_id` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_EliminarObservacion` | DELETE | `"/apipgo/opportunity/" & ri!opportunityId & "/observation/" & ri!ObservacionId` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_EliminarVencimiento` | DELETE | `"/apipgo/opportunity/" & ri!opportunityId` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_EnrutamientoNUUMA` | GET | `"/apipgo/system/route/" & ri!nuuma` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_ObtenerDocumento` | POST | `"/apipgo/opportunity/" & ri!opportunityId &"/attachment/retrieve"` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_SumarioVencimientosCliente` | POST | `/apipgo/client/opportunities/summary` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_VencimientosNumeroDocumento` | POST | `/apipgo/client/opportunities` | Gestión comercial › vencimientos |
| `PGM_DigitalHealth_listadoCompanias` | GET | `/apipgo/competitor-company` | Gestión comercial › vencimientos |
| `PGM_getFinancialGroup` | GET | `"/apipgo/financials/products/"& ri!productCode &"/financial-groups"` | Gestión comercial › vencimientos |
| `PGM_getFunds` | GET | `"/apipgo/financials/"& ri!financialCode &"/products/"& ri!productCode &"/funds"` | Gestión comercial › vencimientos |
| `PGM_getPlans` | GET | `"/apipgo/financials/"& ri!financialCode &"/products/"& ri!productCode &"/funds/" &ri!fundCode& "/plans"` | Gestión comercial › vencimientos |

### `PGM_SGC3.0` → servicio `sgc30` (16)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_EliminarObservacion` | DELETE | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/observations` | Gestión comercial › gestiones |
| `PGM_SGC30_ActualizarAsignacion` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | Gestión comercial › gestiones |
| `PGM_SGC30_ActualizarNGA` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | Gestión comercial › gestiones |
| `PGM_SGC30_ActualizarObservacionPorIdTarea_ActualizaciónExitoPotencial` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | Gestión comercial › gestiones |
| `PGM_SGC30_ActualizarObservacionPorIdTarea_General` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/observations` | Gestión comercial › gestiones |
| `PGM_SGC30_CerrarTarea` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/close` | Gestión comercial › gestiones |
| `PGM_SGC30_Compartir` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | Gestión comercial › gestiones |
| `PGM_SGC30_CrearObservacionPorIdTarea` | POST | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/observations` | Gestión comercial › gestiones |
| `PGM_SGC30_DetalleGestion` | GET | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | Gestión comercial › gestiones |
| `PGM_SGC30_EstructuraDentroDeEstructura` | POST | `/sgc3-bk-business-tasks/api/1.0/external/structures/search` | Gestión comercial › gestiones |
| `PGM_SGC30_EstructuraFueraDeEstructura` | POST | `/sgc3-bk-business-tasks/api/1.0/external/structures/search/out` | Gestión comercial › gestiones |
| `PGM_SGC30_GestionesNumeroDocumento` | POST | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` | Gestión comercial › gestiones |
| `PGM_SGC30_Perfil` | GET | `/sgc3-bk-users/api/1.0/user/profile` | — |
| `PGM_SGC30_ReabrirTarea` | PUT | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/reopen` | Gestión comercial › gestiones |
| `PGM_SGC30_descargaDocumentos` | GET | `/sgc3-bk-business-tasks/api/1.0/external/business-tasks/documents/download` | Gestión comercial › gestiones |
| `PGM_SGC3_firmaMediador` | POST | `/sgc3-bk-users/api/1.0/external/user/terms/sign` | — |

### `PGM iMediador EDGE` → servicio `imediador` (11)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_iMediadorEDGE_ActividadComercial` | GET | `"/api/1.0/contacto/" & ri!idContacto & "/usuario/" & ri!nuuma & "/origen/"&ri!origen&"/obtenerActividades"` | — |
| `PGM_iMediadorEDGE_AltaActividad` | POST | `"/api/1.0/contacto/" & ri!idContacto & "/usuario/" & ri!nuuma & "/insertarActividad"` | — |
| `PGM_iMediadorEDGE_AltaContacto` | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.idPerfil & "/delegado/" & ri!estructuraComercial.delegado & "/altaContacto"` | — |
| `PGM_iMediadorEDGE_AltaGestion` | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.idPerfil & "/delegado/" & ri!estructuraComercial.delegado & "/altaGestion"` | — |
| `PGM_iMediadorEDGE_AltaVencimiento` | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina &  "/usuario/" & ri!estructuraComercial.nuuma &  "/perfil/" & ri!estructuraComercial.idPerfil &  "/delegado/" & ri!estructuraComercial.delegado &  "/contacto/" & ri!idContacto & "/altaVencimiento"` | — |
| `PGM_iMediadorEDGE_CatalogoAcciones` | GET | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.idPerfil & "/delegado/" & ri!estructuraComercial.delegado & "/catalogoAcciones"` | Acciones por póliza (WLCatalog) |
| `PGM_iMediadorEDGE_CatalogoNivelesGestion` | GET | `"/api/1.0/origen/"&ri!origen&"/obtenerNivelesGestion"` | Acciones por póliza (WLCatalog) |
| `PGM_iMediadorEDGE_ConsultaContactos` | POST | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.idPerfil & "/delegado/" & ri!estructuraComercial.delegado & "/consultaContactos"` | — |
| `PGM_iMediadorEDGE_ConsultaGestiones` | GET | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina & "/usuario/" & ri!estructuraComercial.nuuma & "/perfil/" & ri!estructuraComercial.idPerfil & "/delegado/" & ri!estructuraComercial.delegado & "/consultaGestiones"` | — |
| `PGM_iMediadorEDGE_Perfil` | GET | `"/api/1.0/usuario/" & ri!nuuma & "/perfil"` | — |
| `PGM_iMediadorEDGE_Vencimientos` | GET | `"/api/1.0/oficina/" & ri!estructuraComercial.idOficina &  "/usuario/" & ri!estructuraComercial.nuuma &  "/perfil/" & ri!estructuraComercial.idPerfil &  "/delegado/" & ri!estructuraComercial.delegado &  "/contacto/" & ri!idContacto & "/consultaVencimiento"` | — |

### `PGM BFF` → servicio `aci` (10)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_BFF_DPV` | POST | `/api-pgm/catalog/query` | — |
| `PGM_BFF_OperacionConsents` | GET | `"/api-pgm/oneTrust/client/" & ri!idCliente& "/consents"` | Firmar RGPD |
| `PGM_DELETE_ClienteTotal_Eliminar_Empresa` | DELETE | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/" & ri!idEmpresa` | Cliente Total |
| `PGM_GET_ClienteTotal` | GET | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies"` | Cliente Total |
| `PGM_GET_ClienteTotal_Cargos` | POST | `/api-pgm/catalog/query` | — |
| `PGM_GET_ClienteTotal_Documentos` | GET | `"/api-pgm/clients/"& ri!idDocumento &"/representedCompanies/document"` | Cliente Total |
| `PGM_GET_ClienteTotal_Search` | POST | `/api-pgm/clients/representedCompanies/search` | Cliente Total |
| `PGM_POST_ClienteTotal_Enviar_Firma` | POST | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/signature"` | Cliente Total |
| `PGM_POST_ClienteTotal_Insertar_Empresa` | POST | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/" & ri!idEmpresa` | Cliente Total |
| `PGM_PUT_ClienteTotal_Actualizar_Empresa` | PUT | `"/api-pgm/client/" & ri!idCliente & "/representedCompanies/" & ri!idEmpresa` | Cliente Total |

### `CMP API WLCatalog` → servicio `wlcatalog` (9)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_APICatalogo` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_Argumentario` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_DPVE_v2` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_ObtenerRoles` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_ParametrosIntegracion` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_PolizaValida` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_SCA` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_URLIntegracion` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_catalogo` | POST | `—` | Acciones por póliza (WLCatalog) |

### `PGM Integraciones` → servicio `home-api` (8)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_APIGW_newToken` | POST | `auth/oauth/v2/token` | — |
| `PGM_APIGW_refreshToken` | POST | `auth/oauth/v2/token` | — |
| `PGM_API_HOME_ConsumoProtegido` | GET | `"/esp/srv/api/home/2.0/policy/" & ri!numPoliza & "/detail"` | — |
| `PGM_API_HOME_HipotecaSegura` | GET | `"/esp/srv/api/home/2.0/policy/" & ri!numPoliza & "/detail"` | — |
| `PGM_ClientsAPI_ActualizarMetodoContacto` | PUT | `"esp/srv/api/clients/1.0/client/" & ri!clientId & "/contactMethod/" & cons!PGM_CODIGO_METODOCONTACTO_HABITUAL & "-" & ri!metodoContacto` | Ficha 360 (clientes) |
| `PGM_DPVE_IntegralityDiscountDetail` | GET | `"esp/srv/api/clients/1.0/client/"&ri!IDCliente&"/integralityDiscountDetail"` | — |
| `PGM_HomeApi_PolicyDetail` | GET | `"/esp/srv/api/home/2.0/policy/" & ri!numPoliza & "/detail"` | — |
| `PGM_MotorApi_Policy` | GET | `"srv/api/1.0/motor/policy/" & ri!referenceNumber & "/detail"` | — |

### `PGM Citrix API` → servicio `-` (5)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_CitrixAPI_Configuration` | POST | `/Home/Configuration` | Lanzadera Citrix |
| `PGM_CitrixAPI_DownloadFromPath` | GET | `—` | Lanzadera Citrix |
| `PGM_CitrixAPI_GetAuthMethods` | POST | `/Authentication/GetAuthMethods` | Lanzadera Citrix |
| `PGM_CitrixAPI_ListResources` | POST | `—` | Lanzadera Citrix |
| `PGM_CitrixAPI_LoginUsername` | POST | `/PostCredentialsAuth/Login` | Lanzadera Citrix |

### `PGM Health API` → servicio `health-api` (5)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_HealthAPI_CoberturasPorIdProducto` | GET | `"/settings/commercialProduct/" & ri!commercialProductId & "/coverages"` | — |
| `PGM_HealthAPI_DetallesPolizaSaludPorId` | GET | `"/individual/policy/" & ri!policyId` | — |
| `PGM_HealthAPI_ProductosComerciales` | GET | `/settings/commercialProducts` | — |
| `PGM_HealthAPI_ProfesionesPorIdProducto` | GET | `"/settings/commercialProduct/" & ri!commercialProductId & "/healthQuestionnaire/conditions/professions"` | — |
| `PGM_HealthAPI_Tarificacion` | POST | `/individual/simulation` | Tarificación Salud |

### `PGM API WLCatalog` → servicio `wlcatalog` (3)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_APICatalogo_IntegracionesPoliza` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_URLPresupuestos` | POST | `—` | Acciones por póliza (WLCatalog) |
| `PGM_APICatalogo_codURLPresupuestos` | POST | `—` | Acciones por póliza (WLCatalog) |

### `PGM Clients EDGE Recibos` → servicio `clients-edge-recibos` (3)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_ClientsAPI_EDGE_PolizasClientePorId` | GET | `/server/vfdc/client/views/productsDetail` | — |
| `PGM_ClientsAPI_EDGE_ProductosPorId` | GET | `/server/vfdc/client/views/products` | — |
| `PGM_ClientsAPI_EDGE_RecibosClientePorId` | GET | `/server/vfdc/client/views/receiptsDetail` | Recibos |

### `PGM Life Risk API` → servicio `life-api` (3)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_LifeAPI_DuplicadoPoliza` | POST | `"/apisbcpolizas_int-web/api/life/1.0/individual/policy/"&ri!idPoliza&"/documents"` | — |
| `PGM_LifeAPI_Poliza` | GET | `"/apisbcpolizas_int-web/api/life/1.0/individual/policy/"&ri!idPoliza` | — |
| `PGM_LifeAPI_UnitLink` | GET | `"/apisbcpolizas_int-web/api/life/1.0/policy/"&ri!idPoliza&"/unitLink"` | — |

### `PGM loopback appian` → servicio `appian` (3)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_POST_cliente_record` | POST | `infoCliente` | — |
| `PGM_POST_llamar_registro_operaciones` | POST | `registro` | — |
| `PGM_WebApi_numDocumento` | GET | `accesoFicha` | — |

### `PGM API Portal Interno` → servicio `bdec` (2)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_ObtenerGruposRest` | POST | `ARQ_SecurityServices_be-web/api/1.0/securityManagement/groups` | — |
| `PGM_registrarConsultaModificacionPOST` | POST | `cons!PGM_URL_REGISTRO_ACCIONES_NUUMA` | — |

### `PGM Pre-registro ACI` → servicio `aci` (2)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_ClientsAPI_Login_ACI` | POST | `—` | — |
| `PGM_ClientsAPI_UpdateToken_ACI` | POST | `—` | — |

### `PGM_NeuronaVerti` → servicio `firma` (2)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_NeuronaVerti_Inducir` | POST | `/callcenter/WSSISNet` | — |
| `PGM_NeuronaVerti_Login` | POST | `/callcenter/WSSISNet` | — |

### `CMP API ESB` → servicio `wlcatalog` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `CMP_PostConsulta_consultarDatosAgente` | POST | `ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0` | — |

### `CMP LoopBack` → servicio `appian` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_R_obtenerCliente` | POST | `infoCliente` | — |

### `PGM BDEC API` → servicio `bdec` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_BDEC_EstructuraComercialPorClave` | GET | `"/ES_AUAD_ESTRUAGE_SERVICIOS_REST_be-web/api/1.0/claveProduccion/"&ri!clave` | — |

### `PGM Client API` → servicio `client-api` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_ClientsAPI_RecibosClientePorId` | GET | `"/client/" & ri!clientId & "/receipts"` | Ficha 360 (clientes) |

### `PGM MotorAPI Login` → servicio `motor-api` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_MotorAPI_newToken` | POST | `—` | — |

### `PGM PGM Life Risk API DUPLICADO` → servicio `gesyc` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_LifeAPI_DuplicadoRecibos` | POST | `/gesycore_servicios_bbe-web/services/imprimirRecibo` | — |

### `PGM WMAPFRE` → servicio `firma` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_ServiciosCrosselling_Creatividades` | GET | `/servicios_crosselling_ws_be/api/1.0/aci/crosselling/creatividades` | — |

### `PGM_ConectaOrange` → servicio `click2call` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_Click2Call` | POST | `"/com.broadsoft.xsi-actions/v2.0/user/"&ri!nuuma&"/calls/callmenow"` | Click2Call |

### `PGM_KeyVault_SGC3.0` → servicio `sgc30` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_KeyVault_SGC3_Encriptar` | POST | `keys/appian-pgm/encrypt?api-version=7.4` | — |

### `PGM_iMediadorEDGE_AltaNGA` → servicio `imediador` (1)

| Integración | Método | Ruta | Capacidad en la nueva app |
|---|---|---|---|
| `PGM_iMediadorEDGE_AltaActividad_New` | POST | `/api/1.0/contacto/insertarActividad` | — |

## 4. Credenciales que no son de servicio

| Elemento | Dónde va en Configuración |
|---|---|
| App Registration Entra ID (tenant `93ad25dd-…`, clientId `c4d0e5f0-…`, scope `api://c4d0e5f0-…/pgm.acceso`) | Sección **Entra ID** (habilitar login, redirect URIs) |
| API key de las Web APIs de Appian (`PGM loopback appian`, `CMP LoopBack`) | Sección **Conexión con Appian** → `apiKey` |
| Constantes de URL (`PGM_URL_NSE`, `PGM_URL_GESALUD`, `PGM_ENDPOINT_VIRTUALAPPS`, `PGM_URL_SGC20`…) | Sección **URLs de lanzaderas** |
| Constantes booleanas (`PGM_visualizacionRecibos`, `PGM_CONS_VER_DETALLE_PRESTACIONES`, `PGM_Mostrar_ExclusivoCorredor`, `PGM_mostrarDPVE`) | Sección **Funcionalidades** |
| NUUMA / perfil SGC 3.0 del usuario de pruebas (en TEST `PGM_Alertas` → `JZAHONE`) | Sección **Usuarios de prueba** (perfil local/pruebas) |


## 5. Pendiente de confirmar (no inventado)

- Los **esquemas de respuesta** de Clients EDGE, Denodo, Client API y Health API no están publicados en el grafo KDD: el BFF los lee de forma tolerante (`JsonTolerante`) y se ajustarán con el contrato real o con la primera respuesta capturada en pruebas.
- `PGM_Comercialización_Seguros_NSE`, `PGM_NeuronaVerti` y Citrix no tienen aún servicio propio en Configuración (son lanzaderas o altas que PGM hace vía proceso).
- Las URL de **PRO** de los connected systems no constan en Appian TEST salvo Citrix (informe E).

