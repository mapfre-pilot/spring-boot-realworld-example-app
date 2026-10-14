# Traspaso de continuidad — paridad SCA → SCA2 (Appian TEST)

Documento para que otro agente de IA continúe exactamente donde se dejó el 07/10/2026 tras la **ronda 11**. Léelo entero antes de tocar nada.
Comunicación y documentación en **español**; hacer sólo lo que pide el usuario (ggalv10), probar todo lo que se cambie, crear datos nuevos
para las pruebas (no reutilizar solicitudes antiguas) y listar las rutas de los ficheros tocados al terminar.

## 1. Objetivo y estado
Objetivo: que **SCA2** (reconstrucción atómica de la aplicación de anulaciones SCA) tenga la **misma lógica funcional que SCA**, aplicando las
respuestas del analista (HU3978 estados, HU3980 etiquetas, dudas resueltas). Las diferencias de sistemas externos (CORE, PRE, Emisión, ANL, GAIA,
Documentum) se documentan, no se "arreglan" en SCA2. **No se modifica SCA ni SCAC** (sólo se leen como referencia).

Historial completo en `docs/sca/README.md` y los documentos 01–29. Lo imprescindible para continuar:
- `22-dudas-funcionales-para-el-analista.md` → dudas; `24`/`26`/`28`/`29` → respuestas y lo aplicado por ronda.
- `28-consolidado-ronda10.md` §tabla de objetos Appian y 21 preguntas al analista.
- `29-respuestas-analista-ronda11.md` → **última ronda**: 23 respuestas clasificadas, 4 implementadas, diseño del batch NSE, texto propuesto (#13), preguntas nuevas.
- `pruebas/` → un informe por sesión/ronda (h1–h6, r9a–r9e, r10a–r10d, r11-pruebas) y protocolos `coordinacion-ronda*.md`.

## 2. Pendientes exactos (en orden)
1. **Esperar respuestas del analista** a las 4 preguntas de `29` §5 y a las 21 de `28`: cascada motivo 3/detalle 8 (sin causas en CORE para nadie), convivencia del batch NSE, plazo/aviso ANL (24 h `ANL_TIMEOUT`), texto del error al cancelar autorización, quién ve la bandeja de errores.
2. **Probar lo no probado de la ronda 11** (`pruebas/r11-pruebas.md` §3): decisión del motor con SI24 + póliza de acuerdos (`anulaExperto = true`) — hace falta una póliza de acuerdos (clase de agente 33/56/97/49/80/69 o acuerdos de la lista `isAcuerdoSi24` en `SCA2_ContraAnulacionOpciones`) sin solicitudes, alta y CA positiva con SISANS, y comprobar en `SCA2 Datos Solicitud.mcaanulaexperto = "true"` y la derivación del motor; y relanzamiento de un error `DOC_GD_FAIL` comprobando que la regla v7 reutiliza la referencia (`reutilizado: true`) sin duplicar en el SGD.
3. **Batch NSE propio de SCA2**: cuando el analista decida (doc 29 §3), crear en el diseñador el proceso `SCA2 Batch Mecanizacion NSE` (la API LCP no crea procesos) y las reglas/constante desde LCP.
4. **No finalizar** 15787909, 15787759, 15787911 ni 15787917 sin confirmación expresa del usuario (lleva pendiente desde la ronda 9).
5. Pendientes funcionales abiertos (ver `28` y `29`): Verti (PRE token 1101), M201/M206 y FDC sin pólizas, documentos tipo 9, plan de pagos, filtros históricos, Desactivar/Activar aplicación (variable común con SCA: no probado).

## 3. Entorno, usuarios y datos
- Appian TEST: https://mapfrespain-test.appiancloud.com — sitios `sca-site` / `sca` (SCA) y `sca2` (SCA2); bandeja de errores `/suite/sites/sca2/page/errores` (sólo administradores; JJGONZ2 no la ve).
- Usuarios de prueba: **JJGONZ2** (Oficina, perfil CE_RM) y **SISANS** (SI24 Experto). Las credenciales están en los secretos de la organización Devin (no en el repo). Diseñador/LCP: credenciales `APPIAN_USERNAME`/`APPIAN_PASSWORD` (secretos).
- Pólizas: Excel `PolizasPruebaPRE.xlsx` del usuario (copias en el paquete). Sin solicitudes a fecha de hoy: 0000253500305 (usada sólo para identificar en el alta, sin guardar) y 0000253500338. Las usadas por ronda están en cada informe de `pruebas/`.
- Solicitudes de referencia: 15788005 (alta Hogar NSE), 15788009 (corredor), 15788000/03/04 (TTQ), 15788001/15788014 (FINALIZAR CA), 15788011 (CA nivel 1 abierta, con argumento NEGATIVO y carta adjunta, sin finalizar).

## 4. Cómo se modifican los objetos Appian (procedimiento obligatorio)
Herramientas: skill `appian` + MCP `appian-dev-mcp-c90b` (mapfrespain-test) y, sobre todo, la **API LCP** (`/suite/plugins/servlet/stateless/lcp-api`, Basic auth)
con los scripts del workspace (`sca2work/`, incluido en el paquete):
- `lcp.py` (get/put/post), `q.py` (evalúa una expresión SAIL arbitraria usando una regla temporal `r6/tmp_rule.json` y `/expression-rules/{uuid}/test`),
  `testrule.py <regla> '<json inputs>'`, `pmgraph.py` (grafo de un proceso), `r11_pols.py norm|rci` (pólizas libres), `r14/apply_hu3980.py`, `r13/apply_r13.py` (ejemplos de PUT de interfaces y de un proceso).
- Variables de entorno: `APPIAN_USERNAME`, `APPIAN_PASSWORD` (y opcional `LCP_BASE`). `PYTHONPATH=sca2work`. Límites LCP: `timeoutSeconds ≤ 60`, `maxResponseSizeBytes` 1000000; en `/process-models?search=` el filtro no funciona: paginar (`limit=50&offset=`) y filtrar por nombre (lista de PMs SCA en `r15/sca_pms.json`).
Pasos por objeto: GET vivo → comprobar `versionId` esperado → backup JSON → editar la expresión completa en local → `PUT {"expression": ...}` (interfaces/reglas) o
`PUT {"nodes", "processVariables"}` (procesos) → GET y comparar byte a byte → probar (LCP y/o UI) → anotar versión en el informe. El PUT valida el SAIL
(400 con detalle: p. ej. variables locales sin usar). Si otra sesión trabaja a la vez: reservar el objeto en `pruebas/coordinacion-ronda*.md` antes.

## 5. Objetos SCA2 más tocados (UUID · versión viva al cierre)
| Objeto | Tipo | UUID | Versión |
|---|---|---|---|
| SCA2_AltaSolicitudPage | Interfaz | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055716 | v30 |
| SCA2_ContraAnulacionOpciones | Interfaz | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056435 | v49 |
| SCA2_ContraAnulacionModalSiNo | Interfaz | _a-0000f069-4f37-8000-9cc8-011c48011c48_20052807 | v4 |
| SCA2_consultarCausa | Regla | _a-0000f069-4f37-8000-9cc8-011c48011c48_20050906 | v2 |
| SCA2_subirDocumentosGD | Regla | _a-0001f076-8f0a-8000-9d26-011c48011c48_5481351 | v7 |
| SCA2_altaDocumento | Regla | _a-0001f076-8f0a-8000-9d26-011c48011c48_5481374 | v1 |
| SCA2 CMD CompletarAccion | Proceso | 0000f06f-1307-8000-65b1-7f0000014e7a | nodos 11 (Write Decidir) y 312 modificados en R11 |
| SCA2 CMD Mecanizar | Proceso | 0000f06f-4cfc-8000-66d3-7f0000014e7a | ver R9/R10 |
| SCA Batch Mecanizacion NSE (referencia, no tocar) | Proceso | 0002ecf2-fb2e-8000-6f80-7f0000014e7a | — |
Records: `SCA2 Solicitud` c531595c-c3b5-454c-a355-8145e7e27e9a · `SCA2 Datos Solicitud` 9a9209c7-aab4-4078-9bef-280de47fdd6e (id 2d7b6a31…, idSolicitud 428e8c4c…, mcaanulaexperto b41590af…, mcaanulatecnico cb56d173…) · `SCA2 Error` d7111f93-55f3-4b43-b921-aedadd2af7c3 · `SCA2 Transicion` 0b46024c-58b4-48be-a2a4-20d54bc40815.
Tabla completa de cambios por ronda: `28-consolidado-ronda10.md` y `29-respuestas-analista-ronda11.md` §7.

## 6. Funcionamiento de SCA2 en dos líneas
Comandos atómicos (`SCA2 CMD Alta / CrearAccion / CompletarAccion / Decidir / Mecanizar / Finalizar…`) con transiciones idempotentes (`SCA2 Transicion`) y
errores relanzables en `SCA2 Error` (bandeja). El motor de decisión (`SCA2 CMD Decidir` → `SCA2_mapearDatosDecidirAccion[Estrategicas]` → `SCA2_consultarServiciosReglas`)
decide la acción/grupo siguiente con los datos de `SCA2 Datos Solicitud` y del productor. CORE (servicios PCA_CORECFSA) es la fuente de verdad de estados
y gestiones; SCA2 mantiene su record como caché/estado de proceso.

## 7. Repositorio y paquete
- Repo documental: `mapfre-pilot/spring-boot-realworld-example-app`, rama **`feature/sca`** (PR #1 abierta), carpeta `docs/sca/`. Commits pequeños, sin `git add .`, push a la misma rama.
- Workspace `sca2work/` (en el paquete, sin credenciales): `obj/` = exportación local de SCA/SCA2/SCAC (reglas, interfaces, procesos en .sail/.json; puede estar desfasada respecto a TEST: **siempre GET vivo antes de modificar**), `r5…r15/` = backups, payloads y relecturas por ronda, `r15/NOTAS-ronda11.md` = notas de la última ronda.
- Memoria del usuario y de la forma de trabajar: ver `docs/sca/README.md` y este documento.
