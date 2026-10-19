# PGM_MAPFRE — Análisis técnico (as-is en Appian)

> Fuente: definiciones de objetos descargadas de Appian TEST por LCP API (solo lectura) el 19/10/2026. Detalle en `inventario/`.

## 1. Dimensión de la aplicación

| Tipo | Nº | Comentario |
|---|---|---|
| DOCUMENT | 850 | Iconos, imágenes, plantillas, documentos de trabajo |
| INTERFACE | 566 | 188 interfaces "raíz" (no referenciadas por otras) ≈ pantallas/pestañas; el resto componentes |
| CONSTANT | 545 | 228 documentos, 193 textos (URLs/endpoints/códigos), 41 modelos de proceso, 29 enteros, 17 grupos… |
| EXPRESSION_RULE | 332 | Formateo, validaciones, mapeo de respuestas, cálculo de visibilidades |
| INTEGRATION | 211 | 24 sistemas conectados + 59 integraciones con URL por constante |
| DATA_TYPE | 156 | CDTs `urn:mapfre:pgm` (cliente, póliza, recibo, prestación, búsqueda…) |
| PROCESS_MODEL | 127 | Mayoría orquestaciones cortas: llamar integración → mapear → mostrar |
| DECISION | 58 | Tablas de decisión (ramos, estados, iconos, visibilidades) |
| FOLDER | 58 | |
| CONNECTED_SYSTEM | 30 | + 3 compartidos (`CMP API WLCatalog`, `CMP API ESB`, `CMP LoopBack`) |
| GROUP | 21 | |
| RECORD_TYPE | 17 | 5 sobre PostgreSQL/Appian DB, 2 sobre web service, 10 "dummy" (sin fuente) usados como contenedor de la ficha |
| WEB_API | 9 | Entradas externas a la ficha |
| DATA_STORE | 4 | |
| SITE | 2 | `PGM` (producción) y `PGM Site Cambios` (POC navegación) |

Dependencias con componentes comunes del entorno: reglas `CMP_*` (28, librería común: indexado anidado, catálogo WL, consulta agente), `FAS_*` (5), `CSC`, `NSE`, `TM`.

## 2. Arquitectura actual

```
Usuario oficina ──SSO──> Appian Cloud (site pgm-mapfre)
                          │  Interfaces SAIL (566) + reglas (332) + decisiones (58)
                          │  Process models (127) como orquestadores de integraciones
                          │  Records (17) → la ficha es un record "PGM_Cliente_Record" sin fuente propia
                          │  Caché: PostgreSQL AWS (pgm_portalgestion) + Appian DB (jdbc/Appian)
                          ▼
   ┌──────────────────────────────────────────────────────────────────────────────────┐
   │ 211 integraciones HTTP (REST/JSON y SOAP legacy) hacia ≥ 25 sistemas distintos   │
   └──────────────────────────────────────────────────────────────────────────────────┘
```

Patrón dominante: **la pantalla llama directamente a la integración** (vía regla) o arranca un proceso que encadena `Call Integration` + nodos script; la agregación de la visión 360 se hace en Appian (`PGM_CompletarInfoCliente`: 8 integraciones en paralelo con AND/XOR; `PGM CargaInfoClienteRendimiento`, `PGM CompletarInfoCliente Paralelo`). Esto es exactamente la lógica que `ARCH-APICANAL-001` sitúa en API Canal (dominio) y en el BFF (journey).

## 3. Modelo de datos

### 3.1 Persistencia propia

| Almacén | Fuente | Entidades | Uso |
|---|---|---|---|
| `PGM PostgreSQL AWS` (schema `pgm_portalgestion`) | PostgreSQL | `pgm_cliente_record_postgres` (86 campos: identidad, contacto, segmentación, RGPD, ACI, Club, tréboles, perfilado…), `pgm_r_cliente_tmp` (37 campos, caché 10 min), `pgm_gdprbrand`, `PGM_INTERACCIONES_MOTIVOS_YCANALES` | **Caché de la ficha** y cuadro de mando |
| `PGM Memoria Caché` (Appian DB) | MariaDB Appian | `clientes`, `iconosCitrix` | Simula caché en memoria |
| `PGM BBDD Borradores` | Appian DB | `registros`, `tarificacionesSalud`, `intervinientesSalud` | Borradores de tarificación Salud |
| `PGM Registros procesos` | Appian DB | `tarificaciones` | Avisos sobre procesos realizados |
| `PGM Cuadro de Mando` | Appian DB | `PGM_cuadroDeMando`, `PGM_EVT_CONTEXT_KEY` | Métricas de uso |

Conclusión: **PGM no es dueño de ningún dato maestro**. Toda la persistencia es derivada (caché/trabajo) y desaparece en la arquitectura objetivo (la caché pasa a API Canal/ODL; borradores y métricas al BFF).

### 3.2 Records

`PGM_Cliente_Record` (v1/v2/v3), `PGM_Poliza_Record`, `PGM_Record_Recibo`, `PGM_Record_Vencimientos_PGO`, `PGM_Cliente_Acciones` y las `*_ListaExportable` son **records contenedores**: no tienen fuente de datos; sus vistas (`/record/<id>/view/summary`) montan la ficha a partir de la caché y de llamadas en línea. Records con fuente real: `PGM_R_cliente_record_postgres`, `PGM_R_cliente_tmp`, `PGM_R_GDPRBrand`, `PGM interaccionesMotivosYCanales`, `PGM Catalogo Nacionalidad` (web service).

### 3.3 CDTs

156 tipos `urn:mapfre:pgm` (p. ej. `PGM_Cliente`, `PGM_CamposBusquedaPosicionada`): son el **modelo canónico implícito** de PGM. En la migración se sustituyen por los DTO del contrato OpenAPI del BFF y por los modelos de `PROD-APICANAL-*`.

## 4. Integraciones y sistemas externos

Resumen por sistema conectado / endpoint (detalle completo: `inventario/integraciones.csv`, `inventario/sistemas-conectados.md`).

| Grupo | Nº integ. | Qué aporta a PGM | Tecnología |
|---|---|---|---|
| **API Clientes** (`PGM Clients EDGE` → `mrcconsultaback_int-web`, `api_negocioclientes_int-web`; y 20 integraciones vía `cons!PGM_ENDPOINT_API_CLIENTS` = `apisb.mapfre.net/esp/srv/api/clients/1.0`) | ~70 | Búsqueda, datos cliente, perfil, direcciones, métodos de contacto e identificación, pólizas (resumen y detalladas), prestaciones, presupuestos, reclamaciones, encuestas, avisos, interacciones, beneficios, carterización, posición bancaria, checks, crosselling, origen de datos, preferencias de contacto, exclusivo corredor, descuento integralidad, modificación de datos | REST/JSON, OAuth2 token API GW |
| **Consentimientos** (`consentimientos_be-web`) | 3 | Solicitar / buscar firma de consentimientos RGPD | REST |
| **PGM BFF** (`/api-pgm`, token propio) | 10 | Cliente Total (empresas representadas, firma), consentimientos OneTrust, catálogo (`/catalog/query`), DPV | REST (BFF ya existente, "v0") |
| **MapfreDigitalHealth / PGO** (`/apipgo`) | 19 | Oportunidades/vencimientos: alta, detalle, actualización, observaciones, adjuntos, sumario, enrutamiento NUUMA, compañías competidoras, productos financieros (fondos/planes/grupos) | REST |
| **SGC 3.0** (`sgc3-bk-business-tasks`, `sgc3-bk-users`) + KeyVault | 17 | Gestiones comerciales: listar/detalle, observaciones, asignación, compartir, cerrar/reabrir, descarga documentos, perfil usuario, firma mediador, estructuras | REST, cifrado de parámetros (Azure KeyVault) |
| **iMediador EDGE** (+ AltaNGA) | 12 | Actividades comerciales, vencimientos de agenda, perfil por NUUMA, catálogos | REST |
| **Health API** (`apisb…/health/1.0`) | 5 | Detalle póliza Salud, productos comerciales, coberturas, cuestionario, **tarificación** | REST API GW |
| **Life Risk API** (`apisbcpolizas…/life/1.0`) | 3 (+1) | Póliza Vida, Unit Link, duplicado de póliza; duplicado recibo (gesycore) | REST |
| **PGM Integraciones** (API GW `apisb.mapfre.com`) | 8 | Home API 2.0 (detalle póliza Hogar, Consumo Protegido, Hipoteca Segura), Motor API (póliza Autos), clients 1.0 (integralidad, método de contacto), OAuth token/refresh | REST API GW |
| **Recibos** (`gesycore_servicios`, `GESYC_*` ESB) | 4 | Consultar datos recibo, envío al banco, agrupaciones, impresión duplicado | REST + SOAP ESB |
| **Siniestros** (`es_aupr_atn_mets_be-web`, `ATN_SINIESTRALIDAD` ESB) | 3 | Siniestro y prestación Autos (METS), detalle de siniestro | REST + SOAP |
| **SGO** (`wmbig2is` webMethods) | 4 | Solicitudes activas, documentos, detalle de solicitud, acceso | SOAP |
| **Catálogo WL / ARQ_Catalogo** (`CMP API WLCatalog`, ESB) | 13 | Catálogos, argumentarios, roles, parámetros y URLs de integración (lanzaderas por ramo), validez de póliza, SCA | SOAP ESB / REST |
| **Estructura comercial** (BDEC, ESTRUAGE ESB, Portal Interno) | 5 | Estructura comercial por clave/NUUMA, grupos de seguridad, registro de acciones (auditoría) | REST/SOAP |
| **Inducción / terceros** (NeuronaVerti, NSE evt21, Santander vía Clients, SAVIA leads, ACI) | 8 | Inducir cliente a Verti/Santander/SAVIA, alta usuario ACI, login/token ACI | SOAP/REST |
| **Citrix (lambda AWS)** | 2 | Lanzadera a aplicaciones de ramo publicadas en Citrix | REST |
| **Otros** | — | ConectaOrange click-to-call, WMAPFRE creatividades crosselling, Te Cuidamos (tréboles), Denodo `productsDetail`, MISV perfilado cliente, CORE7 contra-anulación / gestiones, SOA7 productor Vida, Exstream documentación, loopback a Web APIs propias | mixto |

Hallazgos:

- **Acoplamiento directo canal → legacy** en ≥ 12 dominios técnicos (ESB SOAP, core7, soa7, webMethods, Denodo, lambdas) — lo que `ARCH-APICANAL-001` prohíbe para nuevos consumos.
- **Dos vías para lo mismo**: API Clientes se consume tanto por `Clients EDGE` (mrcconsultaback) como por API GW (`apisb…/clients/1.0`); `PGM_ClientsEDGE_products` tiene la URL de Denodo *hardcoded* y hay sistemas conectados duplicados/no usados (`PGM Health API 2.0`, `PGM Motor API`, `PGM_SCDG`, `PGM_Comercialización_Seguros_NSE`, `PGM BFF TOKEN`, `PGM_WebApi_SGC_Prueba`): 73 integraciones no referenciadas desde reglas/interfaces PGM (candidatas a baja).
- Autenticación heterogénea: OAuth2 client-credentials en API GW, token propio del BFF, API key loopback, SOAP sin auth, cifrado KeyVault para SGC.
- Ya existe un **BFF `/api-pgm`** incipiente (Cliente Total, OneTrust, catálogo): es el embrión natural del BFF objetivo.

## 5. Procesos (process models)

127 modelos; patrones (detalle en `inventario/modelos-de-proceso.md`):

1. **Orquestadores de integración** (`PGM_CompletarInfoCliente`, `PGM_RecuperarRecibosYPrestaciones`, `PGM_LanzaderaCitrix_v2`, `PGM_Llamada_Gestionar_*`): `Call Integration` + script + XOR/AND. → lógica de agregación → BFF / API Canal.
2. **Procesos SOAP** con `Generate Text` + `Call Integration` + `DeleteDocument` (plantillas XML): recibos, SGO, siniestralidad, agente, productor Vida. → adaptadores en API Canal (Recibos, Siniestros) o API Plataforma.
3. **Diálogos de usuario** (`User Input Task`: Cliente Total, crear cliente ACI, PGO documentos, inducciones, mensajes). → flujos Angular + endpoints BFF.
4. **Mantenimiento de caché/records** (`PGM_R_borradoRecord`, `PGM_R_agendarBorrado` cada 10 min, `PGM Actualizar Cliente`, `PGM Borrado Record`). → desaparecen (ODL de API Canal + caché HTTP).
5. **Enlaces / navegación** (`PGM Abrir enlace externo`, `PGM Abrir Mas Datos Clientes`, `PGM_Nav_Inicio`): procesos vacíos que solo redirigen. → routing Angular.
6. Pruebas/POC (`PGM_PUEBA`, `PGM_Prueba_VERTI`, `PGM testHTMLtoPDF`): no migrar.

## 6. Entradas externas (Web APIs)

| Web API | Alias | Uso |
|---|---|---|
| `PGM_IdCliente_NumeroDocumento` | `GET /accesoFicha?numeroDocumento=` | Abrir ficha por documento (SGC y otros frontales) |
| `PGM_Get_FichaCliente` | `GET /fichaCliente` | Abrir ficha por id |
| `PGM_WebApi_SGC` | `POST /abrir-ficha-SGC` | Lanzar ficha desde SGC (grupo `PGM Acceso APP No Appian SGC`) |
| `PGM WebApiFichaPoliza` / `_V2` | `POST /5bESUw`, `POST /abrir-poliza` | Abrir ficha de póliza |
| `PGM_GET_consultar_cliente_record` / `PGM_POST_write_record` | `/infoCliente` | Escribir/leer el record cliente (caché) |
| `PGM_POST_agendar_registro_operaciones` | `POST /registro` | Registro de operaciones |
| `PGM Test WSDL` | `/testWsdl` | Prueba |

En la arquitectura objetivo son **deep links** de la SPA (`/clientes/{documento}`, `/polizas/{id}`) protegidos por Entra ID; las que escriben caché desaparecen.

## 7. Seguridad

- SSO corporativo (SAML "SSO Mapfre PRO/NO PRO") + acceso básico en TEST.
- Autorización por grupos Appian (sección 2 del análisis funcional) combinada con estructura comercial (iMediador/BDEC) y perfil SGC 3.0 → en objetivo: **roles/grupos de Entra ID** + claims de estructura comercial resueltos en el BFF.
- Datos personales (PII) en caché PostgreSQL y en logs de integración (`enableRequestResponseLogging` activo en algunas integraciones): a eliminar en objetivo.
- Secretos: credenciales en sistemas conectados y constantes; en objetivo pasan a Key Vault / configuración de plataforma.

## 8. Deuda y riesgos detectados

- Versionado por duplicación (`Cliente_Record` v1/v2/v3, `Resumen*_v2/_v3`, `Health API`/`2.0`, `Life Risk API DUPLICADO`).
- URLs *hardcoded* de PRE/DESA en integraciones y constantes (`denodo-prep`, `soa7.desa`, `core7.pre`, lambdas AWS).
- Contratos SOAP legacy construidos con plantillas de texto (frágiles).
- Caché de PII propia con borrado programado (riesgo RGPD y de consistencia).
- 73 integraciones y 7 sistemas conectados sin uso detectable.
