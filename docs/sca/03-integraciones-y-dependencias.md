# 3. Integraciones y dependencias

## 3.1 Mapa de dependencias

```
                 ┌──────────────┐  455 refs (146 rule!, 309 cons!)  ┌──────────────┐
                 │     SCA      │ ────────────────────────────────▶ │  SCA CORE    │
                 │  (funcional) │ ◀──────────────────────────────── │   (SCAC)     │
                 └──────┬───────┘   2 refs inversas (ver §3.4)      └──────┬───────┘
    rule!/RT ANL_* (68) │  rule!/cons!CMP_* (160)   rule!/cons!PGM_* (112)  │ 25 connected systems
                        ▼              ▼                    ▼               ▼
                 ┌──────────┐   ┌────────────┐      ┌────────────┐   Core7 · Webservices · SOA7 · ESB
                 │   ANL    │   │    CMP     │      │    PGM     │   WM (wmapfre/wmbig1is/wmbig1s)
                 │Anulaciones│  │ Comunes   │      │  Gestor de │   SGO · SGC3 · Scgd · Core8
                 └──────────┘   │ (Clients  │      │  métodos   │   Portal interno (+Vida) · Retos
                                │  API…)    │      │  contacto  │   Documentación · Emisión · APP-SCAN
                                └────────────┘      └────────────┘   APP-PCA-SOLIC · Aurora PostgreSQL
                 refs residuales: TM_* (3), SCAT_* (1)
```

## 3.2 Sistemas conectados (SCAC, 25)

Todos son `system.http` (HTTP genérico) salvo `SCAC AWS DB` (Aurora PostgreSQL). Credenciales redactadas.

| Connected system | Backend Mapfre | Integraciones (aprox.) | Uso principal |
|---|---|---|---|
| `SCAC SCA Core7` | Core7 / PCA (`PCA_CORECFSA_HTTPRouter/*`, SOAP) | ~69 | Gestiones, autorizaciones, mecanización, cabecera, solicitud, simulación de anulación, observaciones |
| `SCAC SCA Webservice` | webservices (SOAP) | ~31 | Datos de póliza/cliente/productor, documentos, recibos |
| `SCAC SCA Soa7` | SOA7 (SOAP) | ~10 | Servicios corporativos |
| `SCAC SCA Esb` | ESB (SOAP) | ~10 | Enrutado a sistemas legacy |
| `SCAC SCA Wmapfre`, `SCAC SCA Wmbig1is`, `SCAC SCA Wmbig1s REST` | webMethods | varias | Finalizar gestión SGC, carga de gestiones |
| `SCAC SCA Core8`, `SCAC SCA Scgd` | Core8 / SCGD | pocas | Servicios adicionales de póliza |
| `SCAC WebApi SGO`, `SCAC WebApi Documentos SGO` | SGO | varias | Cierre de tareas, reserva de prima, documentos |
| `SCAC_SGC3` | SGC3 | pocas | Gestión comercial |
| `SCAC SCA Wportalinterno`, `SCAC WPORTALINTERNO VIDA` | Portal interno | pocas | Enlaces / redirecciones (GESVIDA, Consutron) |
| `SCAC WEBSERVICES VIDA`, `SCAC SCA WebServicesEmision` | Vida / emisión | pocas | Flujo Estratégicas |
| `SCAC SCA Webservices Documentacion`, `SCAC SCA WEBSERVICE SEARCH` | Documentum / búsqueda | pocas | Gestión documental |
| `SCAC API Clients`, `SCAC Login Token` | Clients API (REST + token) | ~8 | Datos de cliente, métodos de contacto, descuentos integralidad, checks |
| `SCAC Plataforma Retos Token` | Plataforma Retos | pocas | Ofertas de retención |
| `SCAC API Key Obtener Credenciales` | Web API SCAC | 1 | Credenciales para record types WEB_SERVICE |
| `SCAC SCA Webservice APP-SCAN`, `SCAC SCA Webservice APP-PCA-SOLIC` | webservices con usuarios de aplicación distintos | pocas | Variantes de autenticación |
| `SCAC AWS DB` | Aurora PostgreSQL | — | Fuente de los 16 record types de BBDD |

Reparto por protocolo: **116 integraciones SOAP/WSDL** vs **60 REST/otras**. Las SOAP se invocan con
`host`/`endpoint` parametrizados (`cons!SCAC_VAL_HOST_*` + literal de path en la regla SCA) y el mapeo se hace con
CDTs `type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}...` generados desde WSDL.

## 3.3 Objetos SCAC más utilizados desde SCA

Reglas de integración (`rule!SCAC_*Integracion`) referenciadas desde SCA — las más frecuentes:
`SCAC_consultarGestionIntegracion`, `SCAC_actualizarSolicitudIntegracion`, `SCAC_consultarCabeceraIntegracion`,
`SCAC_simularAnulacionPolizaIntegracion`, `SCAC_descargaDocumentoIntegracion`, `SCAC_aceptarAutorizacionIntegracion`,
`SCAC_APIClients_search`. Lista completa (146 referencias) en el
[anexo](anexos/inventario-generado.md#sca-objects-referencing-scac_-objects).

Constantes SCAC referenciadas (309 referencias): fundamentalmente `SCAC_VAL_HOST_CORE7`, `SCAC_VAL_HOST_WEBSERVICES`,
`SCAC_VAL_HOST_ESB`, `SCAC_VAL_HOST_WMAPFRE`, `SCAC_VAL_HOST_WMBIG1IS`, `SCAC_TXT_CORE7_ENDPOINT`,
`SCAC_VAL_USUARIO_*` / `SCAC_VAL_PWD_*` (credenciales usadas en cabeceras SOAP).

## 3.4 Dependencia inversa SCAC → SCA

Dos integraciones de SCAC referencian objetos de SCA, lo que rompe la dirección "core → funcional":

| Integración SCAC | Referencia a SCA |
|---|---|
| `SCAC_descargaDocumentoIntegracion` | `cons!SCA_WEBSERVICES_URL` |
| `SCAC_simularAnulacionPolizaIntegracion` | `rule!SCA_obtenerUserPassSimularPoliza` |

Además SCAC contiene constantes de otras apps: `ANL_DESBLOQUEARSGO` (puntero a PM de ANL) y `SCA_FORMAPAGOVIDA_URL`.

## 3.5 Dependencias con otras aplicaciones Appian

| App | Prefijo | Refs desde SCA | Objetos usados | Naturaleza |
|---|---|---|---|---|
| Anulaciones | `ANL` | 68 | Record types `ANL Anulacion` (41) y `ANL REF Tipo Integracion` (24); reglas `ANL_getTipoIntegracionById_qr`, `ANL_getXMLInsertarObervaciones`, `ANL_cerrarSolicitudSgoAppian`, `ANL_INT_SOAP_WS_IGenerarContraAnul`, `ANL_mapObservaciones_PostAnulacionNSE`; PM `ANL_DESBLOQUEARSGO` | **Fuerte**: SCA lee/escribe records de ANL y se sincroniza con sus procesos (evento `ANL_Desbloquear`). |
| Comunes | `CMP` | 160 | `CMP_obtenerNuuma`, `CMP_APIClients_*`, `CMP_APIUsuarios_ObtenerRoles`, `CMP_APIValidacion_validarEmail`, `CMP_requestChecks`, `CMP_existeObjeto`; constantes `CMP_VAL_HOST_CORE7/ESB/SOA7`, `CMP_CS_OBTENER_IP` | Librería común corporativa. Nota: SCA usa **a la vez** `CMP_VAL_HOST_*` y `SCAC_VAL_HOST_*` para los mismos hosts. |
| PGM | `PGM` | 112 | `PGM_ClientsAPI_ActualizarMetodoContacto`, `PGM_CODIGO_METODOCONTACTO_EMAIL` (el resto son referencias dentro de PMs) | Gestión de métodos de contacto del cliente. |
| TM (Transaction Manager) | `TM` | 3 | PM `SCA TM Add Transactions to Job Type` con `Write to Data Store Entity` | Uso residual del framework Transaction Manager (Data Store legacy). |
| SCAT | `SCAT` | 1 | — | Referencia residual, probablemente de un entorno de test. |

## 3.6 Sistemas externos por capacidad funcional

| Capacidad | Sistema(s) | Vía |
|---|---|---|
| Datos de póliza, cliente, productor, cabecera | Core7 (PCA), webservices, Clients API | SOAP + REST |
| Simulación / anulación / mecanización | Core7 `IMecanizarPCA`, `IGestionarAutorizacionesPCA`, `IGenerarContraAnul` | SOAP |
| Gestiones comerciales (alta, consulta, cierre) | SGC (webMethods `finalizarGestionSGC`), SGC3, SGO, STCAT | SOAP/REST |
| Reglas de decisión (siguiente acción, clasificación) | "Servicio de reglas" (vía Core7/ESB) | SOAP |
| Documental | Documentum (webservices Documentación), SGO Documentos, Appian docs (DOCX→PDF) | SOAP/REST |
| Retención | Plataforma Retos, SVA, Tréboles, descuentos Vida, Verti (inducción / contacto) | REST + SOAP |
| Notificaciones | Correo (DUE, buzones `cueanulacion{autos,hogar}@mapfre.com`), SGC | Send E-Mail |
| Redirecciones | Portal interno, GESVIDA, Consutron (`SCA_FORMAPAGOVIDA_URL`) | URL |
| Identidad / roles | `CMP_APIUsuarios_ObtenerRoles`, `CMP_obtenerNuuma` | REST |
