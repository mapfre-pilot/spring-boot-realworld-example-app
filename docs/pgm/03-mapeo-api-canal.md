# PGM — Mapeo de capacidades a API Canal y a la arquitectura de referencia

> Specs consultadas en el grafo KDD (`mapfre-pilot/esp-iaharness-kdd`, rama `develop`, 19/10/2026): `ARCH-APICANAL-001@0.2.0` (draft, confidence low), `PROD-APICANAL-CLIENTES-001`, `PROD-APICANAL-POLIZAS-001`, `PROD-APICANAL-RECIBOS-001`, `PROD-APICANAL-SINIESTROS-001`, `PROD-APICANAL-VENTAS-001` (todas draft/low). Al ser specs **no verificadas**, lo que sigue es contexto de diseño, no verdad: cada fila indica si la capacidad está documentada (✔), parcialmente (◐) o no (✘) en API Canal.

## 1. Principios aplicables (ARCH-APICANAL-001)

1. PGM es un **activo con frontal controlado por MAPFRE** → le corresponde **un BFF propio** ("Uno por activo (METS, AFIN, PGM, Nébula)").
2. Todo consumo de **Clientes, Pólizas, Siniestros/Prestaciones, Recibos y Ventas** se resuelve contra el `PROD-APICANAL-*` del dominio; si falta la capacidad **se pide a API Canal**, no se integra el canal con el core.
3. La lógica específica de PGM (visibilidades por perfil, orquestación de la ficha, lanzaderas, mediación) vive en el BFF; **el BFF no cachea lo que ya cachea API Canal**.
4. API Canal asume resiliencia (timeouts, circuit breakers, caché temporal) y trazabilidad; expone contrato estable y versionado.
5. El "nivel 1" de PGM (datos del cliente + pólizas + roles) ya está modelado en el **ODL MongoDB `apichannel`** de API Clientes, "para sustituir las llamadas múltiples actuales por una consulta rápida".
6. Deuda reconocida: "comparar los contratos ya construidos (PGM los tenía contra API Business) con los que publiquen las plataformas y normalizar los JWT".

## 2. Mapeo por capacidad

| # | Capacidad PGM (as-is) | Integración(es) Appian actuales | Destino en objetivo | Cobertura API Canal |
|---|---|---|---|---|
| C1 | Búsqueda de clientes multicriterio | `PGM_ClientsEDGE_Search`, `PGM_ClientsAPI_BusquedaClientes*` | `PROD-APICANAL-CLIENTES-001` `GET /client/search` (documento, nombre, póliza, tarjeta sanitaria) | ◐ faltan criterios: matrícula, nº recibo, nº presupuesto, nº expediente, CP/email/teléfono → **solicitar a API Canal** |
| C2 | Datos del cliente / visión 360 nivel 1 | `DatosClientePorId`, `PerfilClientePorId`, `Direcciones`, `MetodosContacto`, `MetodosIdentificacion`, `OrigenDatos`, `PolizasClientePorId*` | `GET /clients/individuals/:id`, `GET /clients/companies/:id`, `GET /clients/:id/originsInfo`, contactMethods, ODL (clientes+pólizas+roles) | ✔ |
| C3 | Posición bancaria, crosselling, descuento vinculación | `BankingPosition`, `ClientsEDGE_Crosselling`, `DescuentoIntegralidad*`, `DPVE_Integralidad*` | `GET /clients/:id/bankingPosition`, `/bankInfo`, `/crosselling`; integralidad/DPVE | ◐ integralidad y simulación DPVE no documentadas |
| C4 | Alertas, interacciones, encuestas, reclamaciones, beneficios, carterización, preferencias de contacto | `Avisos`, `Interacciones`, `Encuestas`, `Reclamaciones`, `Beneficios`, `Carterizacion`, `PreferenciasContacto`, `exclusivoCorredor` | Dominio Clientes (información comercial y analítica, calidad del dato) | ◐ catálogo de endpoints no detallado en la spec |
| C5 | Modificación de datos de contacto, nacionalidad, preferencias, registro de interacción | `PUT …/address`, `PUT …/contactMethod`, `ActualizarNacionalidad`, `ClientsAPI_Interaction*`, `ContactoBDC` | Gestión de clientes / datos de contacto (`/clients/:id/contactMethods/...`, validaciones `/validations/...`) | ◐ (escrituras parcialmente documentadas) |
| C6 | Familias | "En Familia" (datos cliente) | `GET /families/:familyId` | ✔ |
| C7 | Tarjeta sanitaria | búsqueda por tarjeta | `GET /healthCards/:n/policyRoles`, Pólizas `GET /healthCards/by/number` | ✔ |
| C8 | Catálogos (nacionalidades, ramos, roles, argumentarios) | `PGM_APICatalogo_*` (WLCatalog ESB), `Catalogo Nacionalidad` | `GET /catalogs/:catalogName` (Clientes) | ◐ argumentarios SCA y parámetros de lanzadera no son catálogo de cliente → BFF |
| C9 | Pólizas: detalle, tipo, documentos (duplicados, condiciones) | `HealthAPI_DetallesPolizaSaludPorId`, `LifeAPI_Poliza/UnitLink/DuplicadoPoliza`, `HomeApi_PolicyDetail`, `MotorApi_Policy`, `ServiciosHogar_ConsultarPoliza` | `PROD-APICANAL-POLIZAS-001` `GET /companies/{c}/policies/{p}`, `/type`, `/documents/*` | ◐ detalle por ramo (coberturas Salud, Unit Link Vida, situaciones Hogar) no verificado |
| C10 | Recibos: consulta, duplicado, agrupación, envío al banco, cobro | `ServiciosRecibos_*` (gesycore/GESYC ESB), `LifeAPI_DuplicadoRecibos`, cobro Bizum | `PROD-APICANAL-RECIBOS-001` (visión METS; "PGM reutilizará la visión de recibos de METS") | ◐ consulta ✔ / operativas de agrupación, envío al banco y cobro ✘ → solicitar |
| C11 | Prestaciones y siniestros | `GestionarSiniestroAutos*` (METS), `ConsultarDetalleSiniestro` (ESB), `PrestacionesClientePorId` | `PROD-APICANAL-SINIESTROS-001` `GET …/claims`, `/accidents/{id}`, `/proceedings`, comunicaciones | ✔ consulta; ◐ listados por cliente multi-ramo |
| C12 | Presupuestos | `PresupuestosClientePorId*`, `APICatalogo_URLPresupuestos` | Ventas (`PROD-APICANAL-VENTAS-001`: ofertas, quotes) | ◐ listado de presupuestos por cliente no documentado |
| C13 | Tarificación rápida Salud / nueva producción | `HealthAPI_Tarificacion`, `ProductosComerciales`, `Coberturas`, borradores | Ventas `POST /1.0/health/quote`, `/resume`, `/sign`, documentos | ✔ tarificación Salud; borradores → BFF |
| C14 | Oportunidades / vencimientos (PGO) | `PGM_DigitalHealth_*` (`/apipgo`) | Fuera de los 5 dominios API Canal → **API de Plataforma PGO** (vía API Gateway interno) o nuevo PROD API Canal "Oportunidades" | ✘ gap de grafo |
| C15 | Gestiones comerciales SGC 3.0 | `PGM_SGC30_*` + KeyVault | Plataforma SGC (API propia) vía API Gateway | ✘ gap |
| C16 | Actividad comercial iMediador / estructura comercial / NUUMA | `iMediadorEDGE_*`, `BDEC`, `ESTRUAGE`, `ObtenerGruposRest`, `registrarConsulta…` | Plataforma Comercial (iMediador/GESCOM) + Entra ID; auditoría en BFF | ✘ gap |
| C17 | Consentimientos RGPD / OneTrust / firma | `SignatureManagemen_*`, `BFF_OperacionConsents` | Dominio Clientes (calidad del dato / consentimientos) o plataforma de consentimientos | ◐ |
| C18 | Cliente Total (empresas representadas, firma) | BFF `/api-pgm/client/*/representedCompanies*` | BFF PGM (ya existe) → mover reglas de dominio a Clientes | ◐ |
| C19 | ACI (alta/login), Club MAPFRE, tréboles | `GestionarACI_crearCliente`, `ClientsAPI_Login_ACI`, `TeCuidamosAPI_*` | Plataformas de cliente digital (ACI, Club) vía API Gateway | ✘ gap |
| C20 | Inducción a Verti / Santander / SAVIA | `NeuronaVerti_*`, `InduccionVerti_No_NSE`, `Interaction_Santander_*`, `GestionarLeads_SAVIA_V2` | BFP/BFF según partner; registro de interacción en Clientes | ✘ gap (acuerdos con terceros → BFP) |
| C21 | SGO (solicitudes/documentos) | `ServiciosSGO_*` (webMethods SOAP) | Plataforma SGO (Appian/otro) por API Gateway | ✘ gap |
| C22 | Lanzaderas (Citrix, NSE, Portal Interno, URLs de integración) | `CitrixAPI_*`, `APICatalogo_URLIntegracion`, enlaces | BFF PGM: servicio de "lanzaderas" con catálogo de URLs por ramo/perfil | n/a (journey PGM) |
| C23 | Click-to-call, WhatsApp Oficinas, crosselling creatividades | `Click2Call`, `ServiciosCrosselling_Creatividades` | BFF PGM → plataformas de comunicación | n/a |
| C24 | Cuadro de mando de uso | records PostgreSQL | Observabilidad estándar (métricas de negocio Grafana) + eventos | n/a |
| C25 | Caché de ficha (PostgreSQL, 10 min) | `PGM_R_cliente_tmp`, `Memoria Caché` | **Eliminar**: ODL de API Clientes + caché temporal de API Canal | ✔ (ODL) |

Leyenda de destino: *API Canal* = `PROD-APICANAL-*`; *Plataforma* = API de Plataforma/producto consumida por API Gateway interno (`ARCH-FIS-COM-001`), nunca directamente desde la SPA; *BFF* = `pgm-bff` (Spring Boot); *BFP* = Backend for Partner.

## 3. Capacidades a solicitar al equipo API Canal (PCC)

1. **Clientes**: criterios de búsqueda adicionales (matrícula, recibo, presupuesto, expediente, CP/email/teléfono) o endpoints de "localización" por dominio (Pólizas: matrícula; Recibos: nº recibo; Ventas: nº presupuesto; Siniestros: nº expediente) que el BFF federe.
2. **Clientes**: endpoints explícitos para alertas, interacciones (lectura + alta), encuestas, reclamaciones, beneficios, carterización, preferencias de contacto, integralidad/descuento por vinculación y consentimientos.
3. **Pólizas**: detalle por ramo con coberturas (Salud, Vida/Unit Link, Hogar, Autos, financieros) y acciones (duplicados, solicitud de anulación).
4. **Recibos**: operativas (agrupar/desagrupar, envío al banco, cobro individual/múltiple incl. Bizum, duplicado/aviso de cobro) hoy en GESYC/gesycore.
5. **Siniestros**: listado de prestaciones por cliente multi-ramo.
6. **Ventas**: listado de presupuestos por cliente y recuperación de borradores.
7. Nuevos dominios/productos fuera de API Canal (decisión de arquitectura): **Oportunidades (PGO)**, **Gestión comercial (SGC 3.0 / iMediador)**, **SGO**, **ACI/Club**, **inducción a partners** (BFP).

## 4. Qué queda en el BFF de PGM

- Composición de la ficha 360 por pestañas (una llamada agregada por pestaña), *fan-out* controlado a API Canal y plataformas, *mapping* a DTO de pantalla.
- Autorización fina: grupo Entra ID × estructura comercial (oficina/delegado/perfil) × pilotos (feature flags).
- Catálogo de **lanzaderas** por ramo/perfil (hoy constantes + WLCatalog + Citrix), deep links de entrada (`/clientes/{documento}`, `/polizas/{id}`) y auditoría de accesos (registro de operaciones por NUUMA).
- Borradores de tarificación y estado de diálogos multi-paso (Cliente Total, alta ACI, PGO documentos).
- Nada de caché de datos de cliente ni lógica de dominio reutilizable (eso va a API Canal).

## 5. Lo que API Canal no cubre: servicios legacy de PGM a través del API Gateway

**Decisión del owner (ggalv10, 2026-10-20):** las capacidades que API Canal no publica se consumen de los **mismos servicios que ya usa PGM en Appian**, pero nunca en directo: el BFF solo habla con el API Gateway interno (ARCH-FIS-COM-001, regla 1), que publica tanto los productos API Canal como las fachadas de los servicios legacy. Sustituye la regla anterior «nada legacy» (sección 5 de la versión previa de este documento).

Los contratos se han tomado de dos fuentes: para API Canal, las specs `PROD-APICANAL-*` del grafo KDD; para legacy, los objetos de integración y *connected systems* exportados de `PGM_MAPFRE` (211 integraciones, ver `inventario/integraciones.csv`).

| Ruta Gateway (`pgm.gateway.rutas`) | Origen del contrato | Endpoints usados por el BFF | Integración Appian equivalente |
|---|---|---|---|
| `api-canal-clientes` → host `api-product-clients` | PROD-APICANAL-CLIENTES-001 | `GET /client/search` (document, name, phone, email, policyNumber, healthCardNumber, city, limit) · `GET /clients/individuals/{clientId}` · `GET /clients/{clientId}/policies` | `PGM_ClientsEDGE_Search`, `DatosClientePorId`, `PolizasClientePorId*` |
| `api-canal-polizas` → host `msapi-policy` | PROD-APICANAL-POLIZAS-001 | `GET /companies/{companyId}/policies/{policyId}` (`companyId` = `pgm.gateway.company-id`) | `HealthAPI_DetallesPolizaSaludPorId`, `HomeApi_PolicyDetail`, `MotorApi_Policy` |
| `api-canal-recibos` → host `msapi-receipts` | PROD-APICANAL-RECIBOS-001 | `GET /receipts/{receiptId}` (detalle) | `LifeAPI_DuplicadoRecibos` |
| `api-canal-ventas` → host `msapi-commercialization-health` | PROD-APICANAL-VENTAS-001 | `POST /1.0/health/quote` | `HealthAPI_Tarificacion` |
| `clients-edge` (legacy) → `webservices.*.mapfre.net` | Connected system *PGM Clients EDGE* | `GET /api_negocioclientes_int-web/api/1.0/client/{id}/claims` (prestaciones) · `GET …/client/{id}/projects?internalUser` (presupuestos) · `POST /gesycore_servicios_bbe-web/services/consultarRecibo` (recibos por cliente, GESYC) | `PGM_ClientsMediation_PrestacionesCliente*`, `PGM_ClientsMediation_PresupuestosCliente*`, `PGM_ServiciosRecibos_ConsultarDatosRecibo` |
| `pgo` (legacy) → `clientes.private.*.mapfredigitalhealth.com` | Connected system *PGM_MapfreDigitalHealth* | `POST /apipgo/client/opportunities` · (`GET /apipgo/opportunity/{id}`, `POST /apipgo/opportunity/health`, `PATCH /apipgo/opportunity/complete/{id}` en siguientes iteraciones) | `PGM_DigitalHealth_*` |
| `sgc30` (legacy) → `sgc.es.*.azure.mapfre.com` | Connected system *PGM_SGC3.0* | `POST /sgc3-bk-business-tasks/api/1.0/external/business-tasks` (gestiones) · `GET /sgc3-bk-users/api/1.0/user/profile?preferredUsername` (perfil SGC 3.0) | `PGM_SGC30_GestionesNumeroDocumento`, `PGM_SGC30_Perfil` |
| `imediador` (legacy) → `wportalinterno.*/iMediador_be-web/sgc-imediador` | Connected system *PGM iMediador EDGE* | `GET /api/1.0/usuario/{nuuma}/perfil` (estructura comercial) · actividad comercial `GET /api/1.0/contacto/{id}/usuario/{nuuma}/…` (siguiente iteración) | `PGM_iMediadorEDGE_Perfil`, `PGM_iMediadorEDGE_ActividadComercial` |
| `bdec` (legacy) → `wportalinterno.*` | Connected system *PGM BDEC API* | `GET /ES_AUAD_ESTRUAGE_SERVICIOS_REST_be-web/api/1.0/claveProduccion/{clave}` (reservado) | `PGM_BDEC_EstructuraComercialPorClave` |
| `sgo` (legacy) → fachada REST del Gateway sobre webMethods | `PGM_ServiciosSGO_*` (SOAP `ConsultarSolicitudes`, `ConsultarDocumentos`) | `POST /ConsultarSolicitudes` | `PGM_ServiciosSGO_ConsultarSolicitudes` |
| `click2call` (legacy) → `bwctc.conecta.orange.es` | Connected system *PGM_ConectaOrange* | `POST /com.broadsoft.xsi-actions/v2.0/user/{nuuma}/calls/callmenow?address={telefono}` | `PGM_Click2Call` |

Notas:
- Las bases por entorno (`dev/pre/pro`) viven en el Gateway, no en el BFF: el BFF solo conoce `PGM_GATEWAY_BASE_URL` y las rutas relativas anteriores. Las URLs de PRE de los *connected systems* de Appian se dejan como referencia para quien configure el Gateway (ver `inventario/sistemas-conectados.md`).
- ESB (`esb.*.mapfre.net`), Denodo y SOAP directos siguen **prohibidos** desde el BFF; cuando la fuente legacy es SOAP (SGO, GESYC agrupaciones, ESB siniestralidad) el Gateway debe exponer una fachada REST.
- Los esquemas de respuesta de estos servicios no están publicados en el grafo KDD; el perfil `simulador` (WireMock) usa los mismos paths y métodos con cuerpos sintéticos equivalentes a los que hoy consume PGM. Ajustar los mapeadores cuando PCC/los dueños de cada servicio faciliten el contrato detallado.
