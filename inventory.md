# Inventario Appian DEV (vía MCP)

## Resumen (10 líneas)
1. Se procesaron las 81 aplicaciones del fichero `content.txt` usando `listConnectedSystems` y `listIntegrations`, con `limit=200`.
2. Se deduplicaron connected systems por UUID; el fichero JSON incluye los sistemas con detalle `getConnectedSystem` recuperado en esta pasada.
3. Los tipos observados incluyen HTTP/REST, PostgreSQL/Aurora PostgreSQL, Oracle, S3/Amazon, SharePoint y plugins/local endpoint.
4. Los sistemas HTTP detallados abarcan Appian DEV, webservices DEV, Denodo, Core7, Dynatrace, Claim, Plexus/Verti y APIs CVM2.
5. La autenticación observada incluye None, Basic, API Key, OAuth Client Credentials Grant, OAuth/Entra y JDBC credentials.
6. Candidatas ligeras GET/consulta: `GCD_Denodo_GetInfoCliente`, catálogos VIDA `roadTypes`, `MBM_ListMessages`, `PADS_GET_Mediadores` e `ISS_wsRESTGET`.
7. Para `CMP API Webservices`, `CMP_APIClientEdge_contactMethods_GET` y `...preferenceContactChannels_GET` son consultas GET con timeout de 10 s.
8. No se ejecutó ninguna integración ni se creó/modificó ningún objeto de Appian; solo se usaron operaciones de lectura MCP.
9. Se observaron referencias a secretos en descripciones de diseño; no se copiaron valores secretos al inventario.
10. Hay fallos API documentados abajo y algunos connected systems/integraciones requieren una segunda pasada para completar detalles no disponibles.

## Agrupación por host/tipo

### HTTP / REST
- `https://mapfrespain-dev.appiancloud.com` — ADM API Appian — API Key. Prueba candidata: una integración GET de inspección/consulta de ADM (no ejecutar).
- `https://mapfrespain-dev.appiancloud.com/suite/webapi/` — CMP LoopBack / BDT_ConnectedSystem — API Key. Prueba candidata: una Web API GET idempotente; no ejecutar.
- `https://webservices.desa.mapfre.net:25004/` — CMP API Webservices — Basic. Pruebas candidatas: `CMP_APIClientEdge_contactMethods_GET`, `CMP_APIClientEdge_preferenceContactChannels_GET` (GET, QUERY, 10 s).
- `http://denodo-desa.es.mapfre.net:25014/` — GCD Denodo — Basic. Prueba candidata: `GCD_Denodo_GetInfoCliente` (GET, QUERY, path `server/vdb_cu_taskforce/i_client_info/views/i_client_info`).
- `https://apisbint.mapfre.net:26003/` — CW API Claim — None. Prueba candidata: `CW_API_Catalogs_roadTypes` (GET según nombre/listado; detalle no recuperado).
- `https://core7.pre.mapfre.net:26007/PCA_CORECFSA_HTTPRouter/` — ANL PCA CORE — None. Prueba candidata: una consulta `consultarTareaSgo` (no ejecutar).
- `https://esp-cvm2-mediadores-backend...:25039` — PADS Mediadores — None. Prueba: `PADS_GET_Mediadores` (GET, QUERY, timeout 10 s).
- `https://esp-cvm2-gestion-bff...:25038` — PADS Gestión BFF — OAuth Client Credentials Grant. Prueba: `PADS_GET_Gestión_BFF`, preferiblemente `/master/countries` o `/master/provinces`.
- `https://vbs70364.live.dynatrace.com/` — ADM Ingesta Dynatrace — API Key. Solo usar como prueba una consulta GET de estado si existe en la integración; no ejecutar.
- `https://preprod.verti.es/plexus/rs/oauth2/1.0` — CMP PlexusHost Token — Basic. No es candidata ligera GET: es endpoint de token y puede producir side effects/rotación.
- `https://mapfrecorp.sharepoint.com/sites/GO365ECCOMPUSGIBEES-GESTIONDOCUMEN` — BDE SharePoint — OAuth/Entra. Preferir una lectura de metadatos/listado mínima, no escritura.
- `https://webservices.desa.mapfre.net` — CMD_GD_API — OpenAPI, auth None. Candidata: operación GET de catálogo si está disponible.
- `https://webservices.pre.mapfre.net:26004/` — VIDA API Life — Basic. Prueba: `VIDA_API_Life_roadTypes` (GET, QUERY, path de catálogo).
- `https://mapfrespain-dev.appiancloud.com/suite/webapi/` — ISS Services SGO — detalle de CS pendiente. Prueba: `ISS_wsRESTGET` (`GET rest/{servicio}`, aunque figura `usage=MODIFY`).
- Graph API MBM — `MBM_ListMessages` (GET, QUERY) es consulta ligera, pero requiere mailbox/folder válidos.

### DB / PostgreSQL / Aurora
- `aws-rds-dev.mapfre.es:5432/appianmapfredb` — GCD BBDD, ADM adm_administracion AWS, BDE BBDD. Auth: credenciales JDBC (enmascaradas).
- También se detectaron múltiples connected systems de producto con schemas PostgreSQL/Aurora (CMP, PADS, PGO, RH, RM, SGO, TVA, TI, TM, etc.). Para DB la prueba ligera recomendada es una integración de lectura existente, nunca una conexión/escritura directa.

### S3 / Amazon
- `CMP Conexion AWS S3` — región `eu-west-1`, PrivateLink habilitado; auth AWS Signature V4. Prueba: listar/consultar un objeto conocido (solo lectura).

### SharePoint
- `BDE Conexión Sharepoint` — instance URL de SharePoint, OAuth/Entra application. Prueba: recuperar metadatos de una carpeta conocida (solo lectura).

### Otros tipos detectados
- Oracle (`CMD Prueba orafi053`), SMTP y otros plugins/local endpoint aparecen en los listados de aplicaciones; sus detalles no se ejecutaron.

## Fallos de API
- `CMP Plan Familia` (`_a-0000eec9-c65f-8000-9cab-011c48011c48_18342763`): `HTTP 500`, Application not found, tanto en `listConnectedSystems` como en `listIntegrations`.
- `CMD Prueba orafi053` (`_a-0000ec55-424b-8000-9c7a-011c48011c48_14307681`): `getConnectedSystem` no se incluyó en la pasada detallada; listado sí devolvió el objeto.
- Algunos UUID referenciados por integraciones devolvieron `HTTP 404 Connected system not found` al pedir detalle, pese a aparecer en listados (posible objeto eliminado/referencia huérfana).
- La API devolvió listas grandes truncadas por la interfaz; se conservaron rutas de contenido completas cuando fueron proporcionadas por el runtime.

## Archivos
- JSON: `/home/ubuntu/smoke/inventory.json`
- Este resumen: `/home/ubuntu/smoke/inventory.md`
