# Prerrequisitos TEST — auditoría READ-ONLY (Tanda 19)

Fecha: 2026-09-24. Método: `lcp-api` GET con usuario `devin` en DEV y TEST. Nada creado ni modificado.

## Hallazgo principal

**SCA2 ya existe parcialmente en TEST.** La app `SCA2 Sistema Comercial de Anulaciones` está presente con **el mismo uuid** que en DEV (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`), junto con las constantes `SCA2_*`, los 3 grupos `SCA2_*` y 10 de los 15 record types. Las reglas NO están (GET `SCA2_construirContextoAlta` → 404 en TEST) y el site `sca2` está libre. El despliegue previsto es por tanto una **actualización/completado**, no una creación de cero.

## 1. Aplicaciones y site

| Objeto | uuid DEV | uuid TEST | ¿Coincide? |
|---|---|---|---|
| SCA (Sistema Comercial de Anulaciones) | 512929e9-0fac-426c-b02d-4f546bd15305 | mismo | SÍ |
| SCAC (SCA CORE) | 0a42a1fc-7392-4429-a377-5df76c2a9908 | mismo | SÍ |
| App SCA2 | _a-0000f069-…_20050128 | mismo (ya existe) | SÍ |
| Site `sca2` | existe en DEV | **libre en TEST** (0 sites con query sca2) | urlStub disponible |

## 2. Connected systems (18 referenciados por las integraciones SCA2)

| Connected system | uuid | DEV | TEST |
|---|---|---|---|
| SCAC SCA Core7 | _11566224 | OK | OK |
| SCAC SCA Webservice | _11566210 | OK | OK |
| SCAC SCA Soa7 | _11566217 | OK | OK |
| SCAC SCA Esb | _11588319 | OK | OK |
| SCAC SCA Wmapfre | _11591762 | OK | OK |
| SCAC SCA Webservice APP-SCAN | _11985079 | OK | OK |
| SCAC SCA Webservices Documentacion | _12134680 | OK | OK |
| SCAC WEBSERVICES VIDA | _17943416 | OK | OK |
| SCAC WPORTALINTERNO VIDA | _17990330 | OK | OK |
| SCAC SCA WebServicesEmision | _18917830 | OK | OK |
| SCAC API Key Obtener Credenciales | _18525124 | OK | OK |
| CMP LoopBack | _364620 | OK | OK |
| CMP API Webservices | _8633590 | OK | OK |
| CMP API Clients | _8634288 | OK | OK |
| CMP Conexion AWS S3 | _13979606 | OK | OK |
| **SCAC API Clients** | _16855252 | OK | **NO EXISTE en TEST** |
| **SCAC Login Token** | _16855258 | OK | **NO EXISTE en TEST** |
| **SCAC_SGC3** | _19914595 | OK | **NO EXISTE en TEST** |

**BLOQUEANTE**: 3 connected systems faltan en TEST. Integraciones SCA2 afectadas:
- `SCAC API Clients` → `SCA2_APIClients_Benefits`, `SCA2_APIClients_contactMethod`, `SCA2_APIClients_search`, `SCA2_SCA_CMP_APIClients_Perfil`
- `SCAC Login Token` → `SCA2_APIClients_Login`
- `SCAC_SGC3` → `SCA2_cargaGestionSGC3`

Sin estos 3 CS el import marcará "missing precedents" y los flujos API Clients (cabecera/enriquecimientos/login) y SGC3 no funcionarán en TEST.

## 3. Constantes de host SCAC/CMP y de SCA

| Constante | uuid (igual DEV=TEST) | Valor DEV | Valor TEST |
|---|---|---|---|
| SCAC_VAL_HOST_CORE7 | _16790677 | core7.pre.mapfre.net | core7.pre.mapfre.net |
| SCAC_VAL_HOST_ESB | _16790209 | esb.pre.mapfre.net | esb.pre.mapfre.net |
| SCAC_VAL_HOST_WEBSERVICES | _16790255 | webservices.pre.mapfre.net | webservices.pre.mapfre.net |
| CMP_VAL_HOST_CORE7 | _3710964 | **core7.desa.mapfre.net** | **core7.pre.mapfre.net** |
| CMP_VAL_HOST_ESB | _1652747 | **esb.desa.mapfre.net** | **esb.pre.mapfre.net** |
| CMP_VAL_HOST_SOA7 | _2087784 | **soa7.desa.mapfre.net** | **soa7.pre.mapfre.net** |
| SCA_TXT_BONIFICACION_VALUES | _11926032 | [TREBOLES, EUROS] | idéntico |
| SCA_INT_CODIGO_COMPANIA | _11850966 | [1,41,3] | idéntico |
| SCA_TXT_RAMA_NEGOCIO_ITEMS | _11924225 | [200,210,73,0,101] items | idéntico |
| SCA_INT_RAMA_NEGOCIO_VALUES | _11924219 | [200,210,73,0,101] | idéntico |
| SCA_DSE_TM_TRANSACTION | _18520213 | dd5ec92b-…@7417 | dd5ec92b-…@60351 (misma entidad, id de instancia distinto — esperable) |

Nota: en TEST los backends SCAC apuntan a **PRE** (core7.pre, esb.pre). Las `CMP_VAL_HOST_*` cambian de `*.desa` (DEV) a `*.pre` (TEST) — mismo valor que SCAC. Las integraciones SCA2 que usan `CMP_VAL_HOST_*` en TEST hablarán con PRE, no con desa.

## 4. Constantes SCA equivalentes en TEST (para el .properties)

Todas existen en TEST con el **mismo uuid** y, salvo lo indicado, **mismo valor que SCA2_* en DEV** (SCA2_* también existe ya en TEST con los valores DEV):

| SCA2_* (DEV/TEST ya igual) | Equivalente SCA en TEST | Valor SCA TEST |
|---|---|---|
| SCA2_TXT_URL_HOST | SCA_TXT_URL_HOST | https://mapfrespain-test.appiancloud.com ← usar este en TEST |
| SCA2_WEBSERVICES_URL | SCA_WEBSERVICES_URL | webservices.pre.mapfre.net |
| SCA2_NUMPOLIZA_URL | SCA_NUMPOLIZA_URL | apps.pre.mapfre.net/consutron/…/resumen.do |
| SCA2_FECHAULTIMOSINIESTRO_URL | SCA_FECHAULTIMOSINIESTRO_URL | apps.pre.mapfre.net/…/listado.do?numPoliza= |
| SCA2_FORMAPAGO_URL | SCA_FORMAPAGO_URL | idem listado.do |
| SCA2_PLANPAGO_URL | SCA_PLANPAGO_URL | PCA_FRONTFWEB detalle_solicitudes |
| SCA2_FICHAAMPLIADA_URL | SCA_FICHAAMPLIADA_URL | FichaAmpliadaClientes_fe-web |
| SCA2_NUMPOLIZAVIDA_URL | SCA_NUMPOLIZAVIDA_URL | webvida.pre.mapfre.net/…/DetallePolizaCliente |
| SCA2_TXT_URL_NSE | SCA_TXT_URL_NSE | wportalinterno.pre.mapfre.net/EVT21_NSE_FWEB/ |
| SCA2_TXT_URL_LOCALIZADOROFICINAS | SCA_TXT_URL_LOCALIZADOROFICINAS | wportalinterno.pre.mapfre.net/…/EntradaOficinasAction.do |
| SCA2_TXT_URL_LANZARDECISION_ANTIGUO | SCA_TXT_URL_LANZARDECISION_ANTIGUO | wportalinterno.pre.mapfre.net/…/lanzar_decision |
| SCA2_TXT_URL_GESCOMWEB | SCA_TXT_URL_GESCOMWEB | http://wgescomad/wgescom/default.asp |
| SCA2_TXT_URL_GESTIONCOMPETENCIAS | SCA_TXT_URL_GESTIONCOMPETENCIAS | wportalinternowip.es.mapfre.net/competencia/… |
| SCA2_TXT_URL_DOCUMENTACIONSCA | SCA_TXT_URL_DOCUMENTACIONSCA | mapfre.tts-cloud.com/publisher/search/?q=SCA… |
| SCA2_URL_TECUIDAMOS | SCA_URL_TECUIDAMOS | clubmapfre.es/…tarjeta-credito-mapfre-tecuidamos/ |
| SCA2_TXT_RUTAS_ARGUMENTOS_VAL | SCA_TXT_RUTAS_ARGUMENTOS_VAL | (consultar en Designer; query no devuelta) |
| SCA2_USERS_DOMAIN | SCA_USERS_DOMAIN | @mapfrenopro.onmicrosoft.com (mismo tenant) |
| SCA2_TXT_EMAIL_ENVIO_ERRORES | SCA_TXT_EMAIL_ENVIO_ERRORES | pruebasca@mapfre.com |
| SCA2_TXT_EMAIL_DUE_PARA_ALTITUDE | SCA_TXT_EMAIL_DUE_PARA_ALTITUDE | JOSPENA@mapfre.com (SCA2=APP-ALTITUDEMAIL93; existe también SCA_TXT_EMAIL_DUE_PARA_ALTITUDE_TEST=APP-ALTITUDEMAILPRU4@mapfre.com) |
| SCA2_TXT_EMAIL_DUE_PARA_EXPERTOS | SCA_TXT_EMAIL_DUE_PARA_EXPERTOS | JOSPENA@mapfre.com |
| SCA2_TXT_APICLIENTS_{USER,PASS,CLIENT_ID,CLIENT_SECRET} | (no existen SCA_* equivalentes; son propias de SCA2) | **ya existen en TEST y están rellenas** (valores no documentados — secretos) |

## 5. Grupos y usuarios

Todos los grupos existen en TEST con **uuid idéntico** a DEV:
- `SCA Acceso Decisora` (_5401), `SCA Acceso Decisora Vida` (_5417), `SCA Alertas` (_5584), `SCA_PROCESO` (_4687).
- Los 14 pares `SCA_CE_*` / `SCA_CE_*old` / `SCA_CE_*_TEST`: idénticos (uuid `_e-0000ec31…` y `_e-0000ec13…`/`_e-0000ebb9…` en ambos).
- Grupos SCA2 (`Administrators` _8069, `Users` _8071, `Alertas` _8076): **ya existen en TEST**, mismo uuid. `SCA2 Administrators` fue creado en TEST por `GGALV10@mapfre.net` (existe como usuario). `devin` autentica OK en TEST (curl 200). Endpoint `/users` no implementado por el plugin → membresías no verificables por API.

## 6. Carpetas/documentos de SCA

| Objeto | uuid | DEV | TEST |
|---|---|---|---|
| SCA Cliente Tipo Valor (FLD) | _12352654 | OK | OK |
| SCA Documentación argumentario (FLD) | _12308402 | OK | OK |
| SCA Plantilla contrato compra venta (DOC) | _19745745 | OK | OK |
| SCA Mecanizaciones (DOC) | _15634446 | OK | OK |

## 7. Record types (query "SCA", 15 DEV vs 10 TEST)

En TEST ya existen: SCA2 Datos Basicos Solicitud, Datos Cabecera, Datos Perfiles Pca, Datos Poliza Autos/Hogar/Vida, Datos Productor, Error, Tarea, Trazabilidad Cliente — **mismo uuid** que en DEV (sin diffs).
**Faltan en TEST**: `SCA2 Solicitud`, `SCA2 Transicion`, `SCA2 Datos Solicitud`, `SCA2 Niveles Cobertura Autos`, `SCA2 Otras Solicitudes Cabecera`.
(Los record types de catálogo de SCA no aparecen en la query por nombre; solo se contaron los SCA*.)

## 8. Dependientes de `cons!SCA2_GRP_ALERTAS` en DEV (informe §2.2 del plan)

Usuarios de la constante (apunta a `SCA Alertas`, debería apuntar a `SCA2 Alertas`):
- `SCA2_isUsuarioProceso` (regla, línea 3)
- `SCA2_obtenerInformacionUsuario` (regla, línea 8)
- `SCA2_ContraAnulacionArgumentarioEstrategicas` (interfaz, línea 12)

→ Repuntar `SCA2_GRP_ALERTAS` → `SCA2 Alertas` en DEV antes de exportar (3 objetos solo).

## 9. Versión de Appian

El endpoint `/version` no está implementado por el plugin lcp-api en ningún entorno → no verificable por API.

## Resumen de bloqueantes / avisos

**BLOQUEANTES (missing precedents si se importa ya):**
1. `SCAC API Clients` (_16855252) — falta en TEST; afecta a 4 integraciones API Clients.
2. `SCAC Login Token` (_16855258) — falta en TEST; `SCA2_APIClients_Login`.
3. `SCAC_SGC3` (_19914595) — falta en TEST; `SCA2_cargaGestionSGC3`.
4. 5 record types SCA2 ausentes en TEST (se crean con el paquete — no es missing precedent, pero requiere las tablas `sca2_*` correspondientes en la BBDD de TEST).

**AVISOS:**
- TEST ya contiene la app SCA2 + constantes SCA2 + 3 grupos + 10 record types: el import será actualización; revisar por qué está a medio desplegar (¿export previo manual?).
- `CMP_VAL_HOST_*` en TEST apuntan a `.pre` (DEV: `.desa`) — alinear expectativas de backend.
- `SCA2_TXT_URL_HOST` tendrá que pasar a `mapfrespain-test` (valor SCA_TEST ya disponible).
- Endpoint `/users` y `/version` no expuestos → verificación manual en Admin Console para membresías de grupo y versión.
