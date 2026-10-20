# Para poder hacer pruebas con los servicios reales hace falta… (checklist área E)

Fuente: `informe.md` de esta misma carpeta (lectura LCP de PGM_MAPFRE en TEST, 2026-10-20). Prioridad: **B** = bloqueante (sin esto no se puede probar la capacidad), **I** = importante (se puede probar parcialmente), **D** = deseable. Estado inicial de todos los puntos: pendiente. Las credenciales se nombran, nunca se copian.

## 1. PCC / API Canal

| # | Prio | Requisito | Capacidad |
|---|---|---|---|
| PCC-1 | B | Alta del BFF `pgm-bff` como suscriptor («subs autorizados por endpoint») en **API Canal Clientes** PRE (`api-product-clients-lb.clientes.pre.mapfredigitalhealth.com`) para `GET /client/search`, `/clients/individuals/:id` (+ `totalClient`, `personalData`, `mapfreDetail`, `mapfreData`, `integralityDiscount`, `digitizedDocument`, `checks`), `/clients/companies/:id`, `/clients/:id/{originsInfo,crosselling,bankingPosition,bankInfo}`, `contactMethods/*`, `/families/:id`, `/catalogs/:name`. | Búsqueda, ficha |
| PCC-2 | B | Confirmar en Clientes los criterios de búsqueda que Appian usa hoy contra EDGE: nombre/apellidos, documento, email, teléfono, **número de póliza**, `clientTypeCode` F/J y `limit`; si alguno falta, mantener fallback EDGE. | Búsqueda |
| PCC-3 | B | Contrato final (OpenAPI) y entorno PRE de **API Canal Pólizas** (`msapi-policy-lb.digital.pre`) para `GET /companies/{c}/policies/{p}` (+`/type`, documentos) con `companyId` de PGM (Appian usa `0511`/`PGM`) y cobertura por ramo (hecho: Autos, Hogar, PDA, Salud; en curso: Vida, mascotas, caza; pendiente: decesos, accidentes, comunidades, comercios, RC). | Pólizas |
| PCC-4 | B | **Endpoint de listado de pólizas por cliente** (equivalente a EDGE `GET /client/{id}/detailedPolicies` y `/policies`): no está en las specs Clientes ni Pólizas. Decidir si lo publica API Canal o si se expone EDGE por `/legacy/clients-edge`. | Pólizas, carrusel |
| PCC-5 | B | **API Canal Recibos** PRE (`msapi-receipts-lb.digital.pre`): listado por póliza, detalle Gesycore, PDF duplicado, PdP; y endpoint de **listado de recibos por cliente** (EDGE `/client/{id}/receipts`, Denodo `receiptsDetail`) o fallback. | Recibos |
| PCC-6 | I | **API Canal Siniestros**: estado real de Motor (`/claims`) y de los ramos Salud/Vida/Decesos; listado multi-ramo por cliente (EDGE `/client/{id}/claims`) o fallback. | Prestaciones |
| PCC-7 | I | **API Canal Ventas Salud** PRE (`msapi-commercialization-health-lb.digital.pre`): `POST /1.0/health/quote`, `/resume`, `/verify`, `/issuance`, catálogo de productos/coberturas (Appian usa Health API `/settings/commercialProducts` y `/commercialProduct/{id}/coverages`). | Tarificación |
| PCC-8 | I | Subir las specs `PROD-APICANAL-*` de `confidence: low`/borrador a contratos verificados (OpenAPI + ejemplos) antes de dar por buenos los adaptadores del BFF. | Todas |
| PCC-9 | D | Producto API Canal para presupuestos/proyectos (EDGE `/client/{id}/projects`) y para consentimientos (CDC) — hoy inexistentes. | Presupuestos, consentimientos |

## 2. Dueños de cada legacy

| # | Prio | Requisito | Sistema / propietario |
|---|---|---|---|
| LEG-1 | B | Autorizar al API Gateway (origen del BFF) a consumir **Clients EDGE / MRC** (`webservices.pre.mapfre.net:26004`, rutas `mrcconsultaback_int-web/api/1.0/clients/search`, `MRCBack_be-web/api/1.0/client/{id}/…`, `api_negocioclientes_int-web/api/1.0/client/{id}/{claims,projects}`) con Basic (usuario de aplicación `APPUPGM` o uno nuevo para el BFF). | EDGE — equipo Clientes/MRC |
| LEG-2 | B | **PGO / Digital Health**: nuevo client credentials en `apioauth.platform.pre.mapfredigitalhealth.com/o/token/` (scope `api-pgm openid`) para el BFF; acceso a `api-pgm.digital.private.pre…:26033` (`/apipgo/client/opportunities`, `/summary`, `/opportunity/{id}`, `/observation`, `/attachment`) y `clientes.private.pre…:26030` (vencimientos, documentos, enrutamiento NUUMA). Hoy la credencial está en constantes `PGM_CONS_AUTH_TOKENBFF_*`. | PGO — equipo Digital Health |
| LEG-3 | B | **SGC 3.0**: autorizar un app registration del BFF para `sgc.es.pre.azure.mapfre.com` (`/sgc3-bk-business-tasks/api/1.0/external/business-tasks`, `/sgc3-bk-users/api/1.0/user/profile`) y acceso `encrypt` a la clave `appian-pgm` del Key Vault `sgc3-pre-keyvault` (o un endpoint de cifrado); documentar el formato `preferredUsername` (base64url del NUUMA cifrado). | SGC 3.0 |
| LEG-4 | B | **iMediador EDGE (SGC 2.0)** y **AltaNGA** en `wportalinterno.pre.mapfre.net:26001` (`/iMediador_be-web/sgc-imediador/api/1.0/usuario/{nuuma}/perfil`, `consultaContactos`, `consultaGestiones`, `consultaVencimiento`, `catalogoAcciones`, altas): autorización Basic al Gateway. | iMediador |
| LEG-5 | B | **BDEC / Portal Interno** (`wportalinterno.pre:26001`, claves y estructuras comerciales; `ARQ_SecurityServices` roles) y **ESB ESTRUAGE** (`ESTRUAGE_Servicios_SMEDWeb/sca/WEstrServicios_4_0_0`): acceso y WSDL/XSD. | BDEC / Arquitectura ESB |
| LEG-6 | I | **Denodo** (`denodo-prep.es.mapfre.net:26014/server/vfdc/client/views/receiptsDetail`): Basic y aclarar el parámetro `user=admin` fijo que usa Appian. | Denodo / Recibos |
| LEG-7 | I | **GESYC / Gesycore** (`consultarRecibo`, envío al banco, agrupaciones) y **core7** gestiones: WSDL y autorización; las operaciones MODIFY quedan fuera del BFF v1. | Recibos / core7 |
| LEG-8 | I | **SGO** (`wmbig2is` SOAP `ConsultarSolicitudes`, `ConsultarDocumentos`): WSDL/XSD (Appian construye el XML a mano) y acceso de red. | SGO |
| LEG-9 | I | **ESB wICatalog** (`esb.pre.mapfre.net:26005/ARQ_CATALOG_SMEDWeb/sca/wICatalog`): acceso para `PGM_APICatalogo_*` (argumentario, DPVE, roles, parámetros de integración, póliza válida, SCA, URLs de presupuestos) o migración de esos catálogos a configuración del BFF. | Arquitectura ESB |
| LEG-10 | I | **API Gateway MAPFRE apisb** (`apisb.mapfre.net:25003`, `apisb.mapfre.com`): client y usuario de aplicación para el BFF equivalentes a `PGM_USR_APP_FMA_PGMAPPIAN` / `PGM_CLIENTID_CLIENTS_HEALTH` con los scopes `PGM_SCOPES_CLIENTS`, `_CLIENTS_ACI`, `_HEALTH`, `_MOTOR`, `PGM_SCOPE_HOMEAPI`, `PGM_SCOPE_MOTORAPI`; valores válidos de `X-Request-processId`, `X-Request-source`, `X-Request-companyId` (`0511`), `X-Request-distributionChannel` (`100`) en PRE/PRO (en TEST hay literales de prueba). | Arquitectura apisb |
| LEG-11 | I | **Click2Call Broadsoft** (`bwctc.conecta.orange.es/com.broadsoft.xsi-actions/v2.0/user/{nuuma}/calls/callmenow`): mecanismo de autenticación (no visible en Appian) y usuario Broadsoft = NUUMA. | Telefonía |
| LEG-12 | D | WMAPFRE crosselling (`wmapfre.pre:26016`), teCuidamos (`ObtenerIdSocio`, `TrebolesCliente`), SCDG (`scgd.pre:26012`), Neurona Verti, ACI (`/esp/srv/api/aci/1.0`), firma (`SignatureManagemen_*`), DPVE/Exstream: confirmar vigencia (muchas sin consumidor directo en Appian) antes de exponerlas. | Varios |
| LEG-13 | D | Lanzaderas: lista oficial de URLs por entorno (NSE, NSEi, GESALUD, GESVIDA, Portal Interno, SGC 2.0/3.0, Asesor 360, SGO, FAS, SCA, WhatsApp, Citrix PRE/PRO). | Cada aplicación |

## 3. API Gateway (equipo plataforma)

| # | Prio | Requisito |
|---|---|---|
| GW-1 | B | Publicar las rutas ya previstas en el BFF: `/api-canal/{clientes,polizas,recibos,siniestros,ventas}` → hosts API Canal PRE; `/legacy/{pgo,sgc30,imediador,bdec,clients-edge,sgo,click2call}` → hosts de §2.3 del informe. |
| GW-2 | B | Inyección de credenciales por ruta: Basic `APPUPGM` (EDGE, Portal Interno, BDEC, iMediador, Denodo, WMAPFRE, SCDG); OAuth CC Digital Health (PGO); OAuth CC Entra (SGC 3.0); OAuth apisb (Clients/Health/Motor/Home/ACI). El BFF no debe custodiar estos secretos. |
| GW-3 | B | Autenticación del BFF hacia el Gateway (Entra ID client credentials) y valor de `PGM_GATEWAY_BASE_URL`, `PGM_GATEWAY_TENANT`, `PGM_GATEWAY_COMPANY_ID` para PRE. |
| GW-4 | I | Rutas adicionales detectadas en el inventario: `/legacy/denodo-recibos`, `/legacy/gesycore`, `/legacy/esb-catalog`, `/legacy/esb-estruage`, `/legacy/portal-interno`, `/legacy/wmapfre`, `/legacy/tecuidamos`, `/legacy/aci`, `/legacy/keyvault-sgc30`, `/legacy/health-api`, `/legacy/motor-api`, `/legacy/home-api`, `/legacy/life-api`. |
| GW-5 | I | Soporte SOAP passthrough (`Content-Type: text/xml`, `SOAPAction`, cabecera `Host`) para ESB, SGO, GESYC, ESTRUAGE. |
| GW-6 | I | Propagación de cabeceras de contexto `X-Request-*` y `Accept-Language: es-ES`; propagación del NUUMA del usuario final (cabecera acordada) hacia iMediador/PGO/SGC. |
| GW-7 | D | Timeouts acordes a los legacy (Appian no define; BFF usa 2 s conexión / 5 s lectura: insuficiente para SOAP ESB y Denodo según experiencia Appian — ajustar tras medir). |

## 4. Entra ID

| # | Prio | Requisito |
|---|---|---|
| EID-1 | B | App registration de la SPA/BFF en el tenant `93ad25dd-8cdc-4066-9727-31a8a3024f80` con audience `c4d0e5f0-4a24-4b89-a577-bd2c809f972a`, scope `pgm.acceso` y emisión del claim `groups` (o `roles`). |
| EID-2 | B | Grupos (o app roles) equivalentes a `PGM_UsuariosTerritorio`, `PGM_AsesorComercial`, `PGM_AsesorClientes`, `PGM_Delegado`, `PGM_GestorDelegado`, `PGM_DirectorComercial`, `PGM_UsuarioCentral`, `PGM_APS`, `PGM Visualizar CdM`, `PGM_UsuariosEvolutivoConsentimientos`, `PGM_Grupo_PilotoFrontal_NSEi`, `PGM Piloto Captura WEB`, `SGO Acceso Aplicación`, y su mapeo en `Perfiles`/`Visibilidades` del BFF. |
| EID-3 | B | **Claim o servicio de NUUMA**: Appian lo resuelve con `CMP_obtenerNuuma(usuario)`. Hace falta un atributo de directorio (extensión) o un servicio UPN→NUUMA consumible por el BFF; sin él no hay estructura comercial, iMediador, SGC 3.0, PGO ni Click2Call. |
| EID-4 | B | Usuario de pruebas con NUUMA real y perfil iMediador + SGC 3.0 + estructura comercial (en TEST Appian: `JZAHONE`, o los NUUMA de `PGM_CONS_USUARIOS_NEGOCIO`), y un segundo usuario sin NUUMA para reproducir los bloqueos (*Gestiones*, *Actividad comercial*, *Añadir vencimiento*). |
| EID-5 | I | App registration del BFF con client credentials para SGC 3.0 (`api://app-sgc3-appian-pgm/.default` o scope propio) y acceso al Key Vault `sgc3-pre-keyvault` (tenant `5cc6c66d-…`). |
| EID-6 | D | Equivalente del grupo `PGM Acceso APP No Appian SGC` (cuentas `PGM.SGC`, `PGM.CRM`) para los deep links desde SGC/CRM a la SPA (`/clientes/:id`, `/polizas/:numero`). |

## 5. Datos de prueba

| # | Prio | Requisito |
|---|---|---|
| DAT-1 | B | Confirmar que en PRE legacy (lo que usa Appian TEST) siguen válidos `15930307R` (cliente con pólizas, id 38859674), `01076564A` (potencial, id 38903733) y `98064151V` (Platino, póliza `0007001170587`, id 9198551). |
| DAT-2 | B | Lista de 10-20 documentos de PRE con: pólizas multi-ramo (Autos+Hogar+Salud+Vida), recibo **impagado**, prestación/siniestro abierto, presupuesto/proyecto, oportunidad PGO, vencimiento, gestión SGC 3.0, empresa (`clientTypeCode J`, CNAE), VIP, Robinson, exclusivo corredor, cliente total, sin documentación digitalizada, con firma pendiente. Método: búsqueda EDGE por apellido + consultas de listados con el usuario de pruebas (ver informe §6.1). |
| DAT-3 | I | Datos sintéticos del simulador del BFF (`pgm-bff/sources/src/main/resources/local-data/`) alineados con los casos anteriores y con los 86 campos de la caché Appian (`PGM_R_cliente_record_postgres`, informe §6.2). |
| DAT-4 | I | Datos de oportunidades/vencimientos PGO y gestiones SGC 3.0/iMediador asociados al NUUMA de pruebas (`JZAHONE`). |
| DAT-5 | D | KPIs reales para `listarKpis` (hoy en BBDD Appian `PGM Cuadro de Mando`). |

## 6. SRE / red

| # | Prio | Requisito |
|---|---|---|
| SRE-1 | B | Conectividad desde el API Gateway hacia: `webservices.pre.mapfre.net:26004`, `wportalinterno.pre.mapfre.net:26001`, `denodo-prep.es.mapfre.net:26014`, `esb.pre.mapfre.net:26005`, `apisb.mapfre.net:25003`, `apisb.mapfre.com`, `api-pgm.digital.private.pre.mapfredigitalhealth.com:26033`, `clientes.private.pre.mapfredigitalhealth.com:26030`, `apioauth.platform.pre.mapfredigitalhealth.com`, `sgc.es.pre.azure.mapfre.com`, `sgc3-pre-keyvault.vault.azure.net`, hosts API Canal `*.pre.mapfredigitalhealth.com`. |
| SRE-2 | I | Conectividad hacia `wmapfre.pre.mapfre.net:26016`, `scgd.pre.mapfre.net:26012`, `neurona-pre.verti.es.mapfre.net:26017`, `bwctc.conecta.orange.es`, hosts SGO/wmbig2is/core7/webvida (valores en constantes `PGM_ENDPOINT_*`). |
| SRE-3 | I | Certificados/CA de los hosts internos (`*.pre.mapfre.net`) en el trust store del Gateway/BFF. |
| SRE-4 | I | Inventario de hosts **PRO** equivalentes (solo verificado Citrix `virtualappspro.mapfre.net:27010`); el resto no consta en Appian. |
| SRE-5 | D | Rotar el JWT literal encontrado incrustado en una integración de TEST y las credenciales que figuran en constantes (`PGM_PSS_*`, `PGM_CLIENTSECRET_*`, `PGM_CONS_AUTH_TOKENBFF_*`, `PGM_APIKEY_*`) al pasarlas a un vault. |

## 7. Pendientes de la propia OT Appian (para cerrar el inventario)

| # | Prio | Requisito |
|---|---|---|
| OT-1 | I | Leer en Designer las 3 integraciones que LCP no serializa: `PGM_BFF_Token`, `PGM_DPVE_GenerarDocumentacion`, `PGM_ExstreamDocumentation_comunication_V2`. |
| OT-2 | I | Conciliar 33 vs 30 connected systems y confirmar las 69 integraciones sin invocación directa (obsoletas o llamadas desde nodos de proceso). |
| OT-3 | D | Exportar las expresiones de las 9 Web APIs (LCP no las devuelve) para cerrar su contrato de entrada/salida. |
