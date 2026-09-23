# TEST readiness — SCA2 (auditoría pre-pruebas)

Fecha: sesión actual. Entorno: https://mapfrespain-test.appiancloud.com. Credenciales `devin` / `APPIAN_DEV_DEVIN_PASSWORD`. Toda la verificación por GET/POST de test a lcp-api (sin tocar diseño; únicas escrituras: 2 intentos de PUT de reparación, sin efecto).

## 1. Record types SCA2 — 15/15 en TEST

Los 15 record types existen en TEST, con `dataSourceUuid` = `SCA2 DataBase AWS` (`_…_20050863`), `tableName` idéntico a DEV. Todas las tablas responden (0 filas — TEST sin datos, lo esperado). **Ninguna tabla faltante; no hay DDL pendiente.**

| # | Record type | dataSource | Sync | Filas |
|---|---|---|---|---|
| 1-15 | SCA2 Solicitud, Datos Solicitud, Error, Trazabilidad, … (los 15) | SCA2 DataBase AWS (_20050863) | OK (responde, header-only) | 0 |

## 2. PMs — 12 `SCA2 CMD *` publicados en TEST

Los 12 PMs existen en TEST por nombre (match con DEV). Las 12 constantes `SCA2_PM_*` apuntan al uuid correcto del PM en TEST (verificado constante↔uuid; los uuids son los mismos en DEV/TEST).

| PM | uuid (DEV=TEST) | constante | OK |
|---|---|---|---|
| SCA2 CMD Alta | 0000f06f-28fc-8000-6693-7f0000014e7a | SCA2_PM_CMD_ALTA | ✓ |
| + los otros 11 CMD | idénticos DEV/TEST | SCA2_PM_* | ✓ |

**No verificable vía API**: `alerts`/`alertRecipients`/`autoDelete` devuelven `null` en el JSON del PM exportado por lcp-api — el export no incluye esas propiedades. La comprobación "alertas→SCA2 Alertas" y "retención 1 día" requiere Designer (process model → propiedades). **Pendiente de verificación manual.**

## 3. Aptitud de pólizas — 15 primeras de `polizas_nse_vigor.txt`

Reglas ejecutadas en TEST (idénticas a las del popup Alta):
- `SCA2_validacionesPreviasPopupAlta(numPoliza)` — incluye la comprobación de solicitud SCA previa (devuelve `msg`/`bloquear`).
- `SCA2_polizaVigente(numPoliza)` — devuelve `null` (Text) para TODAS; en DEV da el mismo resultado para las mismas pólizas → comportamiento paritario, no es un fallo de TEST.
- `SCA2_obtenerDatosCabecera(numPoliza, "")` — **FALLA en TEST** para todas (ver bloqueante 1).

| Póliza | ¿devuelve datos? | ramo/producto | solicitud SCA previa | apta Alta |
|---|---|---|---|---|
| 2001900000004 | NO* | ? | No (bloquear:false) | pendiente* |
| 2001900000007 | NO* | ? | No | pendiente* |
| 2001900000011 | NO* | ? | No | pendiente* |
| 2001900000015 | NO* | ? | No | pendiente* |
| 2001900000044 | NO* | ? | No | pendiente* |
| 2001900000091 | NO* | ? | No | pendiente* |
| 2001900000111 | NO* | ? | No | pendiente* |
| 2001900000168 | NO* | ? | No | pendiente* |
| 2001900000193 | NO* | ? | No | pendiente* |
| 2001900000211 | NO* | ? | No | pendiente* |
| 2001900000216 | NO* | ? | No | pendiente* |
| 2001900000220 | NO* | ? | No | pendiente* |
| 2001900000224 | NO* | ? | No | pendiente* |
| 2001900000233 | NO* | ? | No | pendiente* |
| 2001900000239 | NO* | ? | No | pendiente* |

\* "NO" era por el bloqueante 1 (integración corrupta en la cadena), no por la póliza: la regla equivalente de SCA (`SCA_obtenerDatosCabecera`) respondía en TEST sin error → el backend PRE es accesible. Las 15 pólizas pasan el gate real del popup (`bloquear:false`, sin msg) → a efectos de validación previa **las 15 son aptas**. Tras la reparación y realineación de CS (ver §CS alineados), `SCA2_APIClients_search` con `policyNumber 2001900000007` devuelve HTTP 200, success=true, 376 ms, cliente con policyRoles TOMADOR / EN VIGOR → **API Clients en TEST conoce las pólizas NSE**; la columna "devuelve datos/ramo" se confirmará en el runtime del popup.

## 4. Site `sca2` en TEST

Site `SCA2 Anulaciones` (`bb62c468-…`, `webAddressIdentifier=sca2`): páginas **idénticas a DEV** (mismos uuids de página y target: buscador→`SCA2_Buscador` _20055660, errores→_20055578, gestiones-mantenimiento→_20060073). `branding`/`logo`/`favicon` = null en DEV y TEST por igual (branding por defecto de la plataforma — no hay logo documental que migrar). Sin divergencias.

## Bloqueantes

1. **`SCA2_APIClients_search` (`239686ab-cd2a-427f-813c-d99d609ed8d3`) y `SCA2_cargaGestionSGC3` (`5ed45630-74e2-4ada-b795-fc8af5f33eab`) están corruptas en TEST** *(RESUELTO — reimportadas por el usuario con el mismo UUID; GET 200, reglas dependientes validan sin errores)*: antes cualquier acceso devolvía `Expression evaluation error at function fn!toExpressionType_appian_internal parameter 1: Invalid symbol found (divide)` — literal mal escapado en el objeto importado (misma familia de bug que `text/xml` sin comillas en DEV). En DEV el objeto es válido (GET OK, adjunto en auditoría). **Reparación por API imposible** (el PUT vuelve a parsear el objeto corrupto). Acción: reimportar esas 2 integraciones o editarlas en Designer TEST. Esto bloquea la cadena `obtenerDatosCabecera` (y con ella el Alta NSE, que usa searchAPIClients vía tomador/contactMethod) — **bloqueante de pruebas de Alta**.
2. Alertas/retención de los 12 PMs no verificables por API → comprobar en Designer (alertas→SCA2 Alertas, eliminar 1 día tras completar).

## No bloqueantes / verificado OK

- **CS alineados (verificado live en Designer TEST + MCP read-only, 2026-09-23)** — `test_integraciones_cs.md` actualizado:
  - `SCA2_APIClients_Login` → **CMP Login token** (`_8636336`); test HTTP 200, ~320 ms, body con `cons!SCA2_TXT_APICLIENTS_*`.
  - `SCA2_APIClients_{search,contactMethod,Benefits}` → **CMP API Clients** (`_8634288`), Authorization `"Bearer " & index(rule!SCA2_APIClients_Login(),"result","body","access_token","")`. Son los CS que usa SCA para API Clients → 0 divergencias pendientes.
  - `SCA2_cargaGestionSGC3` se queda en **SCAC_SGC3** por diseño (ruta runtime de SCA: `SCAC_cargaGestionSGC3→SCAC_SGC3`; `CMP MapfreDigitalHealth SGC3` es de otro producto, no equivalente).
  - Cambios hechos vía Designer UI (MCP TEST read-only: escrituras → HTTP 405, testRule bloqueado → pruebas runtime en Designer "Solicitud de prueba" o el site).
- 15/15 record types, 12/12 PMs, site idéntico, 0 diffs de constantes.
- `polizaVigente` null en TEST = mismo resultado que en DEV (paridad).
- Pólizas aptas a nivel de validación previa: **15/15** (≥5 requeridas). Recomendadas para las primeras pruebas de Alta tras reparar la integración: 2001900000007, 2001900000168, 2001900000004, 2001900000091, 2001900000111.

## Pendiente

- Flujo punta a punta Alta → Decidir → Acción → Finalizar SCA vs SCA2 en TEST con las 20 primeras pólizas NSE de `polizas_nse_vigor.txt`.
- Clasificación de las 20 pólizas (ramo/producto/compañía/vigencia) con `SCA2_obtenerDatosCabecera` ya reparada.
- Verificar la bandeja SCA2 Error tras el fallo previo de `generarStudAnul` (error BBDD) para `2001900000007`: confirmar que la solicitud `PDTE-` y el error persistido relanzable se ven como en SCA.
