# PGM — Listado único: qué hace falta para probar la nueva aplicación con servicios reales

Consolida los apartados «qué hace falta» de las áreas A–F y el checklist técnico del área E ([`E-dependencias-servicios/requisitos-pruebas-servicios.md`](E-dependencias-servicios/requisitos-pruebas-servicios.md), que mantiene el detalle por integración con método, ruta, autenticación y URL por entorno). Prioridad: **B** bloqueante para probar el camino de PRO, **I** importante, **D** deseable.

## 1. API Gateway interno (ARCH-FIS-COM-001) — rutas que el BFF espera (`pgm.gateway.rutas`)

| Ruta lógica | Path por defecto | Backend real que debe publicar el Gateway | Prioridad |
|---|---|---|---|
| `api-canal-clientes` | `/api-canal/clientes` | api-product-clients (PROD-APICANAL-CLIENTES-001): `GET /client/search`, `/clients/individuals/{id}`, `/clients/companies/{id}`, `/clients/{id}/policies`, `/clients/{id}/contactMethods`, `/clients/{id}/totalClient`, `/clients/{id}/digitizedDocument` | B |
| `api-canal-polizas` | `/api-canal/polizas` | msapi-policy: `GET /companies/{c}/policies/{p}`, `/documents`, `/detail` | B |
| `api-canal-recibos` | `/api-canal/recibos` | msapi-receipts | I |
| `api-canal-siniestros` | `/api-canal/siniestros` | msapi-accident: `GET /accidents`, `/accidents/{id}` | I |
| `api-canal-ventas` | `/api-canal/ventas` | msapi-commercialization-health: `POST /1.0/health/quote|resume`, `/1.0/verify/{offer}`, `/1.0/issuance/{offer}`, `/1.0/health/sign` | I |
| `pgo` | `/legacy/pgo` | PGM_MapfreDigitalHealth `/apipgo/*` (oportunidades, resumen, detalle, alta, observaciones, documentos) | B |
| `sgc30` | `/legacy/sgc30` | SGC 3.0 `/sgc3-bk-business-tasks/api/1.0/external/business-tasks` (+ cierre, reapertura, observaciones, perfil) | B |
| `imediador` | `/legacy/imediador` | iMediador EDGE `/api/1.0/perfil`, `/contacto/actividadComercial`, `/contacto/insertarActividad`, catálogos | B |
| `bdec` | `/legacy/bdec` | BDEC API (ESTRUAGE) | I |
| `clients-edge` | `/legacy/clients-edge` | Clients EDGE / Client API: avisos, interacciones, reclamaciones, documentos CDD, prestaciones, proyectos/presupuestos, GESYC recibos, consentimientos, inducciones | B |
| `sgo` | `/legacy/sgo` | PGM_ServiciosSGO `ConsultarSolicitudes`, `ConsultarDocumentos` (SOAP → fachada REST) | I |
| `click2call` | `/legacy/click2call` | Broadsoft `POST /com.broadsoft.xsi-actions/v2.0/user/{nuuma}/calls/callmenow` | D |
| `aci` | `/legacy/aci` | PGM crearClienteACI (alta en Área de Cliente) | I |
| `firma` | `/legacy/firma` | Consentimientos / firma RGPD (`CMP_PM_FIRMA_RGPD_COMPLETO`: biométrica, email, SMS, impresión) | I |
| `dpve` | `/legacy/dpve` | PGM_DPVE_* (plan de pagos: susceptibilidad y simulación) | D |
| `wlcatalog` | `/legacy/wlcatalog` | PGM API WLCatalog (ESB SOAP `ARQ_CATALOG_SMEDWeb/sca/wICatalog`) → catálogo de acciones por cia+ramo | I |
| `gesyc` | `/legacy/gesyc` | GESYC `consultarRecibo`, `gesycore_servicios_bbe-web/services/imprimirRecibo` (SOAP → REST) | I |
| `mets` | `/legacy/mets` | METS expedientes de prestaciones | D |

Para cada ruta hace falta: URL por entorno (DEV/PRE/PRO; en TEST Appian apunta a **PRE**), esquema de autenticación que reproduce el Gateway (E §2.1: 5 esquemas — API key, OAuth client credentials, basic, cabeceras `USER-ID`/`NUUMA`, cookie Citrix), cabeceras obligatorias y **contrato de respuesta** (el BFF usa cuerpos sintéticos del simulador WireMock hasta recibirlo).

## 2. Contratos (PCC / dueños de plataforma)

| Pedir a | Qué | Prioridad |
|---|---|---|
| PCC (API Canal) | OpenAPI detallado de Clientes, Pólizas, Recibos, Siniestros, Ventas (las specs `PROD-APICANAL-*` del grafo están en `draft`/`confidence: low` y solo listan rutas) | B |
| PCC | Publicar como API Canal lo que hoy es legacy si se decide (PGO, SGC 3.0, iMediador, SGO, comunicaciones, ACI, Club) — decisión del owner: **de momento legacy vía Gateway** | I |
| Dueños PGO / Digital Health | Contrato por ramo de `opportunity/incomplete|complete` (17 subformularios de vencimiento) y de documentos | B |
| Dueños SGC 3.0 | Permiso VIEW por NUUMA en TEST; contrato de detalle, Agendar, Asignar | B |
| Dueños iMediador | `/api/1.0/perfil` (lista de perfiles/estructuras por usuario) para el selector de Inicio y del alta de vencimiento | B |
| Dueños GESYC / Consutron | `consultarRecibo`, `imprimirRecibo`, URL de ConsuWeb Recibos por entorno; credenciales APPUPGM | I |
| Dueños Motor API / Health API / Life API | Detalle de póliza por ramo (Autos, Salud, Vida/Ahorro) | I |
| OT Appian | Especificación del parámetro cifrado `inicioExterno` de SGO; URL de WLCatalog y de SCA por entorno | I |

## 3. Seguridad e identidad

| Qué | Detalle | Prioridad |
|---|---|---|
| Entra ID | App Registration `c4d0e5f0-4a24-4b89-a577-bd2c809f972a`, tenant `93ad25dd-8cdc-4066-9727-31a8a3024f80`, scope `api://c4d0e5f0-4a24-4b89-a577-bd2c809f972a/pgm.acceso` ya configurados. Falta: redirect URIs de la SPA (local `http://localhost:4200`, dev/pre/pro) en la plataforma *Single-page application*; consentimiento admin; grupos/roles en el token (`PGM_USUARIO`, `PGM_ASESOR_COMERCIAL`, `PGM_VISUALIZAR_CDM`, `PGM_ADMINISTRADOR`, `PGM_USUARIOSGRUPOTRABAJO`, `PGM_GR_DETALLEHOGAR`) | B |
| Perfil comercial | Fuente del NUUMA y de la estructura comercial por usuario (en TEST Appian lo fija `PGM_Alertas` → `JZAHONE`); el BFF lo lee de iMediador (`UsuariosComercialesPort`) | B |
| Perfil SGC 3.0 | Alta del usuario de pruebas en SGC 3.0 con permiso VIEW | B |
| Grupos Appian (si se prueba en paralelo con Appian) | `PGM_Alertas`, `PGM_AsesorComercial`, `PGM Visualizar CdM`, `PGM_USUARIOSGRUPOTRABAJO`, `PGM_GR_DETALLEHOGAR`, `RM Usuarios` | I |

## 4. Datos de prueba en TEST (hoy no existen o no se han localizado)

- Cliente con **oportunidades PGO** (vencimientos) para ver detalle/observaciones/documentos.
- Cliente con **presupuestos** (pestaña Presupuestos vacía para 15930307R).
- Cliente con **prestaciones** (expedientes METS) Autos/Hogar.
- Pólizas **Hogar, Salud, Decesos, Empresas**, y pólizas **anuladas/suspendidas** (estados anteriores); en TEST solo se han visto Autos y Vida/Ahorro.
- Recibos **Pendiente / Devuelto / agrupados / con plan de pagos** (solo hay «Cobrado»).
- Clientes de tipología **VIP, Rentas Altas, Empleado MAPFRE, Robinson, Autónomo, No perfilado, Gestor personal, Exclusivo corredor** (y las constantes `PGM_Mostrar_ExclusivoCorredor`, `PGM_mostrarDPVE` a `true`).
- Cliente **potencial** con teléfono y email para ACI / inducción; cliente **sin RGPD** para la firma.
- Usuario de pruebas con **NUUMA real**, estructura comercial y perfil SGC 3.0 (no el fijo `JZAHONE`).

## 5. Red, entornos y operación (SRE)

- Resolución DNS/VPN a `apps.pre.mapfre.net`, `wportalinterno.pre.mapfre.net`, `watenaus.pre.mapfre.net`, `esb.pre.mapfre.net`, `sgc20`, `sva`, GESALUD, NSE, GESVIDA, Citrix (desde la VM de pruebas todas fallan con `DNS_PROBE_FINISHED_NXDOMAIN`).
- Tabla de URLs por entorno de todas las lanzaderas (`PGM_URL_*`, `PGM_ENDPOINT_*`) → variables `PGM_URL_APPS`, `PGM_URL_NSE`, `PGM_URL_GESALUD`, `PGM_URL_GESVIDA`… del BFF.
- Onboarding Zeus/Backstage, pipeline, EKS, imágenes `acrmapfredevops`, Azure Artifacts, Config Server, observabilidad (ver `docs/pgm/06-operacion-produccion.md`).

## 6. Cómo probar hoy sin la red MAPFRE

- Perfil `local` (compose): datos sintéticos C-1001…C-1005; usuarios `usuario.local` (con NUUMA), `gestor.sin.nuuma`, `director.oficina` vía cabecera `X-Usuario-Local`; perfiles vía `X-PGM-Perfiles`.
- Perfil `simulador`: adaptadores reales del BFF contra un Gateway simulado (WireMock, `pgm-bff/sources/src/test/resources/gateway-sim/`), con las mismas rutas de §1 y cuerpos sintéticos; incluye casos 404/500/timeout.
