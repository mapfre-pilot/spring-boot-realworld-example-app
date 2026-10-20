# R23-C · Salto a nivel 2 (SI24) + Verti previa + RETOMAR — SCA vs SCA2 (20/10/2026)

Sesión hija C de la ronda 23. Entorno TEST. Usuarios: `JJGONZ2` (Oficina, CE_RM) y `SISANS` (SI24 experto). Referencia funcional: SCA.
Sesión: https://mapfre.devinenterprise.com/sessions/49ba1937072d488dbbaaacd31c201ff7

## 1. Pólizas y solicitudes

Lista «Wautemis que derivan» (30 pólizas). Consulta previa por LCP `SCA2_consultarSolicitudes(numPoliza, "", 0)` a las 17:00 UTC:

| Resultado | Pólizas |
|---|---|
| Ya tenían solicitud en CORE (descartadas, no se tocan) | 0005726674052 (15787862), 0005726674055 (15787900), 0005726674004 (15787861), 0005726678312 (15787897), 0005726678405 (15787873/15787867), 0005726680285 (15787904/15787893), 0005726679137 (15787921), 0005726677758 (15787891), 0005726680401 (15787895), 0005726679775 (15787889), 0005726681055 (15787898), 0005726685339 (15787902/15787901), 0005726681805 (15787923), 0005726681713 (15788148, sesión padre), 0005726682097 (15788149, sesión padre), 0005726684215 (15787916), 0005726684349 (15787913) |
| Libres (`MSSConsultarSolicitudes: null`) | 0005726681936, 0005726681296, 0005726681221, 0005726682856, 0005726681370, 0005726681408, 0005726682038, 0005726685618, 0005726683648, 0005726685247, 0005726683419, 0005726689061, 0005726688765 |

Para no colisionar con las otras dos sesiones de la ronda se usaron las últimas de la lista:

| App | Póliza | Solicitud CORE | Alta (UTC) | Uso |
|---|---|---|---|---|
| SCA2 | 0005726688765 | **15788151** | 16:55:49 | Ciclo 1 (descubre D1–D3) |
| SCA | 0005726685247 | **15788157** | 17:17:21 | Referencia |
| SCA2 | 0005726689061 | **15788160** | 17:42:28 | Ciclo 2 limpio (valida D2/D3; descubre D6/D7) |

Solicitudes protegidas no tocadas. Ninguna de las pólizas probadas derivó a Acciones Administrativas ni a Anulación fuera de norma, por lo que «AA / fuera de norma no pasan por Verti ni lanzan contactos» queda **no probado** en esta sesión.

## 2. Tabla paso a paso SCA vs SCA2

Horas: Appian/CORE en CEST (UTC+2) tal como se muestran en pantalla; LCP en UTC. Capturas en `~/sca2work/r23c/` (índice `r23c-indice-capturas.tsv`, 87 ficheros; no se suben al repo).

| # | Paso / usuario | SCA (15788157) | SCA2 ciclo 2 (15788160) · ciclo 1 (15788151) | ¿Igual? |
|---|---|---|---|---|
| 1 | Alta / JJGONZ2 (causa «Me ha subido mucho la prima», a vencimiento) | Solicitud CORE creada (19:17:21), gestión 8 FINALIZADA; vuelve al buscador | Igual: CORE 19:42:28 (c1 18:55:41), gestión 8; `SCA2 Solicitud` ALTA→DECIDIDA→EN_ACCION; tarea CONTRAANULAR | Sí |
| 2 | Contra Anulación nivel 1 NEGATIVA + carta + FINALIZAR / Sí / ACEPTAR | Gestión 2 FINALIZADA NEGATIVA (19:21:45) + gestión 4 impresión (19:20:04). Mensaje «se envía al Grupo de Expertos en Retención SI24» | Gestión 2 FIN. NEG. (19:46:55; c1 18:59:50) + gestión 4 (19:46:57; c1 18:59:52). Mensaje CORRECTO; vuelve al buscador | Sí (CORE idéntico); etiqueta del mensaje distinta |
| 3 | Pantalla «Inducción Verti / Vencimiento» tras la CA1 | **No aparece**: pasa directamente a la CA de nivel 2 | **Aparece** (tarjeta «Gestión Verti/vencimiento» Incompleta → RETOMAR → 2 casillas → CONTINUAR). Tarea VERTI `VERTI-PRE` (331 / 346) completada al continuar | **No → D4** |
| 4 | Creación de la CA nivel 2 en CORE | Gestión 2 nivel 2 INCOMPLETA (19:22:27), infoUsuario `JJGONZ2 · GGE / GGE EXPERTOS SI24` | Igual: gestión 2 nivel 2 (19:49:51; c1 19:03:14), mismo infoUsuario/grupo; **sin error `CORE_ALTA_GESTION`** (`SCA2_altaGestionCore` v7). `SCA2 Solicitud.procesoActivo = CONTRA ANULAR NIVEL 2`, `grupoAsignacion = CE_MF_BK`, tarea 334/348 grupo CE_MF_BK | Sí |
| 5 | Tarjeta CA nivel 2 vista por Oficina (JJGONZ2) | Nivel 2, Nuuma **JJGONZ2**, **con** RETOMAR | Nivel 2, grupo «GGE EXPERTOS SI24», Nuuma **«-»**, **sin** RETOMAR | No (decisión R23 padre: «-» hasta retomar; ver Q2) |
| 6 | Tarjeta CA nivel 2 vista por SISANS | En el Detalle de `sca-site` **no hay RETOMAR** (showWhen oculta nivel 2 a CE_MF_SI24); SISANS la retoma desde el site **`/suite/sites/decidir-accion`**; `/suite/tasks` → 403 | RETOMAR en el Detalle; al pulsarlo Nuuma pasa a **SISANS** (`SCA2 Tarea.asignadoA = SISANS`, `fechaCaptura` 17:06:49Z en c1) | Distinta navegación, mismo resultado |
| 7 | CA nivel 2 NEGATIVA por SISANS + FINALIZAR | Modales: finalizar Sí → «¿contactado con el cliente?» Sí → «acuerdo especial / insiste canal» Sí → «Se va a redirigir a la anulación» → OK. Gestión 2 nivel 2 FIN. NEG. 19:32:03 `SISANS · SI24 / SI24 EXPERTOS` | Modales FINALIZAR/Sí/ACEPTAR; gestión 2 nivel 2 FIN. NEG. (19:54:44; c1 19:09:44), mismo infoUsuario. **c1: error 105 `IMPR_GUARDAR_FAIL` y solicitud parada** (D1/D2) hasta relanzar; **c2 (tras corrección): continúa sin intervención** | c2 Sí; c1 No (corregido) |
| 8 | Impresión de la CA nivel 2 | Una sola gestión 4 por solicitud (CORE rechaza la 2ª: fault 4115); SCA ignora el resultado | c1: error; c2: `imprRes.omitida = true` y continúa | c2 Sí |
| 9 | Verti tras la CA nivel 2 | **No aparece**: va directo a la confirmación de anulación | **Aparece 2ª pantalla Verti** (tarea 343 / 351, `VERTI-PRE`); la retoma SISANS (JJGONZ2 no ve RETOMAR); la tarjeta muestra Nuuma JJGONZ2 (propietario) | **No → D4 / D8** |
| 10 | Decisión del motor tras la CA2 negativa (SI24 + acuerdos) | MECANIZAR («Detalle consulta New», CANCELAR / ANULAR PÓLIZA) | c2: `SCA2 Datos Solicitud.mcaanulaexperto/mcaanulatecnico = true/true` → motor **MECANIZAR** → tarea MECANIZAR 353 → misma pantalla «Detalle consulta New». c1: relanzamiento sin marcas → false/false → NO_MECANIZAR → nivel 3 → FIN (D3) | c2 Sí |
| 11 | ANULAR PÓLIZA | «La anulación se ha lanzado…»; gestión 5 nivel 2 `SISANS · SI24 / SI24 EXPERTOS` 19:32:25 → **«Mecanización Enviada»** 19:35:20; `codEstSolic = 4` | «La anulación se ha lanzado al sistema de emisión»; `guardarMecanizacion` OK; gestión 5 nivel 2 **`JJGONZ2 · GGE / GGE EXPERTOS SI24`** 19:57:40, **INCOMPLETA**; CMD Mecanizar (14348367): observaciones null → no espera ANL → `Finalizar gestión SGC` (omitido) → «IR A NIVEL 3» → CrearAccion NIVEL → Decidir (nivel 3) `FIN PROCESO` → CMD Finalizar → CORE `finalizarSolicitud` 19:58:46 (`codEstSolic = 4`); gestión 5 queda INCOMPLETA con fecha fin | **No → D6 / D7** |
| 12 | Estado final en buscador / Detalle | Buscador **«Mecanización Enviada»**; Detalle «FINALIZADO NEGATIVO CON CONTRAANULACIÓN», tarjeta Mecanización «Mecanización Enviada», NIVEL 3 | Buscador **«Solicitud Finalizada sin anular»**; Detalle «FINALIZADO NEGATIVO CON CONTRAANULACIÓN», tarjeta Mecanización «Finalizada» resultado «-», NIVEL 2 en pantalla (`SCA2 Solicitud.nivelIntervencion = 3`) | **No → D6** |
| 13 | Bandeja de errores SCA2 (`/errores`) | n/a | JJGONZ2 y SISANS: «La página no existe o no tiene permiso» (sólo administradores). Por LCP: c2 **0 errores**; c1 sólo el 105 (RELANZADO) | n/a |

Estados LCP del ciclo 2 (15788160) tras cada acción: `SCA2 Transicion` 1389–1415 (ALTA → DECIDIDA → EN_ACCION → DECIDIR → NO_MECANIZAR → NIVEL → DECIDIDA → EN_ACCION → DECIDIR → **MECANIZAR** → PDTE_MECANIZAR → MECANIZADA → IR A NIVEL 3 → NIVEL → DECIDIDA → FIN → FINALIZADA); tareas 345 CONTRAANULAR, 346 VERTI, 348 CONTRA ANULAR NIVEL 2 (SISANS), 351 VERTI, 353 MECANIZAR, todas cerradas; `SCA2 Error`: ninguno; CORE gestiones 43706171 (8), 43706172 (2 n1), 43706174 (4), 43706178 (2 n2, SISANS), 43706186 (5 n2, INCOMPLETA).

## 3. Estados observados por LCP (SCA2 15788151)

Gestiones CORE (`SCA2_consultaGestion(15788151)`), hora CORE (CEST):

| numGestion | acción | estado | nivel | inicio | fin | infoUsuario |
|---|---|---|---|---|---|---|
| 43706135 | 8 (alta) | FINALIZADA | 1 | 18:55:41 | 18:55:41 | JJGONZ2 · RED MAPFRE / OFICINA |
| 43706136 | 2 (CA) | FINALIZADA NEGATIVA | 1 | 18:55:59 | 18:59:50 | JJGONZ2 · RED MAPFRE / OFICINA |
| 43706140 | 4 (impresión) | FINALIZADA | 1 | 18:59:52 | 18:59:52 | JJGONZ2 |
| 43706145 | 2 (CA) | FINALIZADA NEGATIVA | **2** | 19:03:14 | 19:09:44 | SISANS · SI24 / SI24 EXPERTOS |

`SCA2_consultarSolicitudes(0005726688765)`: `codEstSolic = 2`, `fecResolucion = 19:09:44`.

`SCA2 Tarea` (CSV del record):

| id | tarea | estado | propietario | asignadoA | grupo | creada | captura | cierre | token |
|---|---|---|---|---|---|---|---|---|---|
| 328 | CONTRAANULAR | COMPLETADA | JJGONZ2 | JJGONZ2 | CE_RM | 16:56:00 | 16:57:37 | 16:59:42 | TK-675246-… |
| 331 | Gestión VERTI/Vencimiento | COMPLETADA | JJGONZ2 | JJGONZ2 | SCA2 Users | 17:00:05 | 17:02:12 | 17:02:56 | `VERTI-PRE` |
| 334 | CONTRA ANULAR NIVEL 2 | COMPLETADA | JJGONZ2 | **SISANS** | CE_MF_BK | 17:03:14 | **17:06:49** (RETOMAR SISANS) | 17:17:08 | TK-269111228-… |
| 343 | Gestión VERTI/Vencimiento (2ª) | COMPLETADA (SISANS, 17:36Z) | JJGONZ2 | JJGONZ2 | SCA2 Users | 17:17:27 | | 17:36 | `VERTI-PRE` |

`SCA2 Transicion` (resumen): ALTA → DECIDIDA → EN_ACCION (CrearAccion 675246) → DECIDIR (CompletarAccion 675259, CA1) → NO_MECANIZAR?/NIVEL (Decidir 10150493 → CrearAccion 13303624 «NIVEL») → DECIDIDA (Decidir 15414401) → EN_ACCION (CrearAccion 269111228, CA nivel 2) → [error 105] → PDTE_FINALIZAR→DECIDIR (CompletarAccion relanzado 14348208, 17:17:12) → NO_MECANIZAR (Decidir 675332, 17:17:21).

`SCA2 Solicitud` tras la CA nivel 2 (antes del relanzamiento): `estadoSolicitud=PDTE_FINALIZAR`, `interfazActiva=CONTRA_ANULAR`, `procesoActivo=CONTRA ANULAR NIVEL 2`, `nivelIntervencion=2`, `grupoAsignacion=CE_MF_BK`. Tras el relanzamiento: `EN_ACCION / VERTI / NO_MECANIZAR`; tras la 2ª Verti (SISANS, 17:36Z): NIVEL → Decidir → FIN → **FINALIZADA** nivel 3 (17:36:21Z), buscador «Solicitud Finalizada sin anular», Detalle «FINALIZADO NEGATIVO CON CONTRAANULACIÓN»; CORE `codEstSolic = 4`.

`SCA2 Error`: **ningún `CORE_ALTA_GESTION`** (el alta de la CA nivel 2 con `SCA2_altaGestionCore` v7 funcionó a la primera). Un único error: id 105, `SCA2 CMD CompletarAccion` / nodo «Guardar impresion CA» / `IMPR_GUARDAR_FAIL`, PENDIENTE 17:09:47 → RELANZADO 17:17 (ver §4).

`SCA2 Datos Solicitud` (15788151): `mcaanulaexperto = false`, `mcaanulatecnico = false` tanto tras la CA1 como tras la CA2 relanzada (ver D3).

Instancias `SCA2 CMD CrearAccion` de la solicitud: 675246 (16:55:57, CA1), 14348152 (17:00:00, Verti previa), 537547564 (17:01:34, vuelta de Verti), 13303624 (17:02:55, NIVEL), 14348167/537547568/675272 (17:03, CA nivel 2 y notificación), 675280/13303654/13303656 (17:07–17:10, RETOMAR/finalizar), 537547611 (17:17:22, 2ª Verti previa). Todas COMPLETED.

## 4. Divergencias y errores

### D1 · Mensaje de error engañoso en «Guardar impresion CA» (corregida)
El error 105 decía «Failed to connect to https://core7.pre…/IGenerarContraAnul», pero `pv!imprRes.body` de la instancia 12244382 contiene un fault SOAP de CORE:
`<codigo>4115</codigo><msg>La solicitud ya tiene una impresion</msg>` (`SolicitudConImpresionException`, PCA_CORECEAR). El nodo 360 daba prioridad a `local!res.error` (texto genérico del conector) sobre el `faultstring`/`msg` del body. No era un fallo de red.

### D2 · SCA2 bloquea la solicitud cuando CORE rechaza la 2ª impresión; SCA la ignora (corregida)
- CORE sólo admite una impresión (gestión «4») por solicitud. En nivel 1 la impresión se guarda (43706140); al finalizar la CA de nivel 2 la petición vuelve con el fault 4115.
- **SCA** (`SCA Finalizar Contra Anulacion`, nodo 21 `guardarImpr` → 114 `Consulta Reglas`) guarda el resultado en `pv!resGuardarImpr` y **no lo evalúa**: sigue al motor. En la referencia 15788157 también hay una sola gestión 4 (43706162).
- **SCA2** (`SCA2 CMD CompletarAccion` nodo 360 → 361 «¿Impresion ok?» → 199 `Write Error`) lo trataba como error: la solicitud quedaba en `PDTE_FINALIZAR` con la tarea de nivel 2 PENDIENTE y en el Detalle «Finalizada negativa» / buscador «Solicitud pendiente», sin continuar hacia Verti/Mecanización/nivel 3 hasta un relanzamiento manual desde la bandeja (sólo administradores). La comprobación `yaGuardada` del nodo exigía además que `SCA2_consultarDocumentos` devolviera documentos, cosa que no ocurre en esta póliza, por lo que no evitaba la llamada.
- Divergencia exclusiva de SCA2 → corregida (§5). Ya había ocurrido en 15788148 (r23-pruebas §B) y se había relanzado a mano.

### D3 · El relanzamiento de CompletarAccion perdía las marcas SI24/acuerdos (corregida)
`SCA2_parametrosRelanzarCompletarAccion` reconstruía `pv!resultado` con una lista fija de claves y descartaba `anulaExpertos/anulaTecnicos` (el payload del error 105 los traía a `true/true`, calculados por `SCA2_ContraAnulacionOpciones` v54 / `ModalSiNo` v6 de la ronda 22). El nodo 11 «Write Decidir» grababa entonces `mcaanulaexperto/mcaanulatecnico = "false"` en `SCA2 Datos Solicitud` y `SCA2_mapearDatosDecidirAccion` los enviaba así al motor → `NO_MECANIZAR` → 2ª Verti previa → nivel 3 → FIN (misma vía que 15788148). Con D2 corregida este camino ya no se recorre en el caso normal, pero el relanzamiento debe conservar las marcas.

### D4 · Pantalla Verti previa antes del salto a nivel 2 (NO corregida — pregunta funcional)
- **SCA**: la inducción Verti vive en `SCA Mecanizacion` (46 `determinarContacto` → 44 pantalla Verti/Vencimiento): sólo aparece cuando el motor decide MECANIZAR. En 15788157, tras la CA1 negativa, SCA pasa directamente a «Grupo de Expertos en Retención SI24» (gestión 43706163 nivel 2, INCOMPLETA) **sin pantalla Verti**.
- **SCA2** (diseño R22 §5, según respuesta del analista 8.5 «la inducción a VERTI sólo desde contra anulación»): tras **cualquier** CA negativa crea la tarea `VERTI-PRE` y muestra «Inducción Verti / Vencimiento» antes de ejecutar la acción decidida, también cuando la acción es «IR A NIVEL 2» (y de nuevo antes de nivel 3).
- Es una diferencia de comportamiento visible (una pantalla extra para Oficina y para SI24) y la respuesta del analista admite las dos lecturas. **No se cambia; pregunta Q1 en §7.**

### D5 · Etiquetas del grupo de nivel 2 en CORE (igual en ambas)
SCA y SCA2 crean la CA nivel 2 con `infoUsuario = JJGONZ2 · GGE / GGE EXPERTOS SI24` (perfiles `CE_MF_BK`/`CE_MF_BK_EXPERTOSI24` que CORE traduce así) y, tras finalizarla SISANS, CORE muestra `SISANS · SI24 / SI24 EXPERTOS`. La tarjeta SCA2 muestra «GGE EXPERTOS SI24» mientras está abierta: es lo que devuelve CORE, no una divergencia.

### D6 · Estado final tras ANULAR PÓLIZA: «Mecanización Enviada» (SCA) vs «Finalizada sin anular» (SCA2) — NO corregida
- SCA: la gestión 5 pasa a **«Mecanización Enviada»** (19:35:20, 3 min después de ANULAR PÓLIZA) y la solicitud queda `codEstSolic = 4`; buscador y tarjeta «Mecanización Enviada».
- SCA2 (`SCA2 CMD Mecanizar` 14348367, 10 s): `guardarMecanizacion` OK → `observaciones = null` (no es wAutemis «pendiente de aceptar») → 300 ¿ANL ya creada? → 301 `ANL Alta` → 324 (no) → 325 → 326 `Finalizar gestión SGC` (omitido) → **320 «Write Cambio nivel» (`procesoActivo = IR A NIVEL 3`)** → CrearAccion NIVEL → Decidir (nivel 3) → `FIN PROCESO` → CMD Finalizar → CORE `finalizarSolicitud`. La gestión 5 nunca se actualiza y CORE la cierra como **INCOMPLETA** (fecha fin 19:58:46); `SCA2_consultarSolicitudes` devuelve `codEstSolic = 4` igual que SCA, pero el Detalle/buscador de SCA2 derivan «Finalizada sin anular» de la gestión 5 INCOMPLETA + CA negativa.
- En SCA, en la rama no pendiente, `SCA Mecanizacion`/`SCA Finalizar Mecanización` tampoco llaman a `actualizarMecanizacion` (nodos 5/31 sólo en ANL/cancelada; `SCA_PB_buclesActualizarMecanizacion` con `saltar = true` va al nodo 16 «mcaMecanizada & Pendiente & Autoriz»). Qué fija «Mecanización Enviada» en SCA (nodo 16, `SCA Finalizar Solicitud` o el propio CORE al recibir la aceptación de NEW) **no se ha identificado en esta sesión**. Pertenece al escenario Mecanizar/ANL de la otra sesión de la ronda; no se toca `SCA2 CMD Mecanizar`.
- Efecto visible: la misma anulación lanzada a emisión se muestra como «Mecanización Enviada» en SCA y como «Solicitud Finalizada sin anular» en SCA2. **Pregunta Q4.**

### D7 · `infoUsuario` de la gestión de mecanización — NO corregida
`SCA2 CMD Mecanizar` nodo 8 «Guardar Mecanización» envía `infoUsuario` desde `pv!sol.datosPerfilesPca` (JJGONZ2 / CE_MF_BK / CE_MF_BK_EXPERTOSI24, el gestor de la solicitud), por lo que CORE registra la gestión 5 como `JJGONZ2 · GGE / GGE EXPERTOS SI24` y la tarjeta SCA2 muestra «JJGONZ2 / CE_MF_BK» aunque la ejecutó SISANS. SCA registra `SISANS · SI24 / SI24 EXPERTOS` (perfil real del usuario que mecaniza, como ya se corrigió en `SCA2_altaGestionCore` v7 para la CA). Corrección probable: resolver el perfil real de `pp!initiator` en el nodo 8 (misma técnica que v7). No aplicada para no cruzarse con la sesión que trabaja sobre `SCA2 CMD Mecanizar`.

### D8 · Nuuma de la tarjeta Verti
La tarjeta «Gestión Verti/vencimiento» muestra el propietario de la tarea (JJGONZ2, usuario de la solicitud) aunque la retome SISANS; SCA no tiene equivalente en este flujo (no muestra Verti). Sólo relevante si se mantiene D4.

## 5. Objetos SCA2 modificados

Procedimiento: GET vivo → backup local (`~/sca2work/r23c/backup/`) → edición mínima → PUT completo → re-GET y comparación → test.

| Objeto | Tipo | UUID | Versión | Cambio |
|---|---|---|---|---|
| `SCA2_parametrosRelanzarCompletarAccion` | Regla | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5483721` | v3 → v4 | `local!resTipado` incluye `anulaExpertos`, `anulaTecnicos`, `mcaFisicoJuridico`, `catalogacion`, `ciaContraria`, `observaciones` (passthrough de `payload.resultado`). Test `idError=105`: `anulaExpertos=true, anulaTecnicos=true, mcaFisicoJuridico="J", catalogacion="2"`. |
| `SCA2 CMD CompletarAccion` | PM | `0000f06f-1307-8000-65b1-7f0000014e7a` | (LCP no expone versión de PM; re-GET: sólo el nodo 360 difiere, 39 nodos, variables y lanes idénticos) | Nodo 360 «Guardar impresion CA»: `local!yaImpresa` = body contiene `<codigo>4115</codigo>` o «ya tiene una impresion» → `success = true`, `omitida = true`; el `error` prioriza `<msg>`/`<faultstring>` del body sobre el texto del conector. |

Fragmento nodo 360 (después):
```
local!yaImpresa: or(search("<codigo>4115</codigo>", local!body)>0, search("ya tiene una impresion", local!body)>0),
local!ok: or(and(tostring(a!defaultValue(index(local!res,"success",null),false))="true", search("<faultstring>", local!body)=0, search("<respuesta>false</respuesta>", local!body)=0), local!yaImpresa),
local!msgCore: if(search("<msg>", local!body)>0, …<msg>…, if(search("<faultstring>", local!body)>0, …<faultstring>…, "")),
a!map(success: local!ok, omitida: local!yaImpresa, …, error: if(local!ok, null, if(a!isNotNullOrEmpty(local!msgCore), local!msgCore, if(a!isNotNullOrEmpty(index(local!res,"error",null)), …, "IGenerarContraAnul.guardarImpr no ha devuelto éxito"))))
```

Fragmento regla v4 (añadido en `local!resTipado`):
```
anulaExpertos: index(local!res, "anulaExpertos", null),
anulaTecnicos: index(local!res, "anulaTecnicos", null),
mcaFisicoJuridico: index(local!res, "mcaFisicoJuridico", null),
catalogacion: index(local!res, "catalogacion", null),
ciaContraria: index(local!res, "ciaContraria", null),
observaciones: index(local!res, "observaciones", null),
```

Acciones operativas sobre datos propios: relanzamiento del error 105 de 15788151 con `POST /process-models/0000f073-49f2-8000-d0e7-7f0000014e7a/test` (`SCA2 CMD MarcarErrorRelanzado`, proceso 269111266 COMPLETED, 17:17 UTC). Una sonda previa con body vacío dejó la instancia 537547609 de ese PM en ERROR («Marcar error RELANZADO: Records must not be null»): sin efecto sobre datos; puede borrarse.

## 6. Veredicto

- **Salto a nivel 2 + RETOMAR: paridad**. Alta → CA1 negativa → CA nivel 2 en CORE (grupo SI24 EXPERTOS, sin `CORE_ALTA_GESTION`) → nuuma «-» hasta que SISANS retoma (asignadoA/fechaCaptura grabados) → CA2 negativa → motor MECANIZAR con `mcaanulaexperto/mcaanulatecnico = true` → Mecanización → anulación lanzada a emisión. Validado en el ciclo 2 (15788160) sin intervención de backend.
- **Dos divergencias exclusivas de SCA2 corregidas** (D2 fault 4115 de la 2ª impresión bloqueaba la solicitud; D3 el relanzamiento perdía las marcas SI24/acuerdos) y una de mensaje (D1).
- **Divergencias abiertas** (no corregidas, requieren decisión o pertenecen a otro escenario): D4 pantalla Verti previa antes del salto de nivel y antes de mecanizar (SCA no la muestra en ninguno de los dos puntos), D6 estado final «Finalizada sin anular» vs «Mecanización Enviada», D7 `infoUsuario` de la mecanización.
- No probado: póliza que derive a Acciones Administrativas / Anulación fuera de norma (ninguna de las probadas lo hizo); resultado efectivo en emisión (sólo confirmación UI); bandeja de errores por UI (sin permiso) — se consultó por LCP.

## 7. Preguntas funcionales y pendientes

- **Q1 (D4)**: ¿la pantalla «Inducción Verti / Vencimiento» debe mostrarse tras una CA negativa cuyo resultado es un **salto de nivel** (como hace SCA2) o sólo cuando se va a mecanizar (como hace SCA)? Si es lo segundo, el nodo 30 de `SCA2 CMD CrearAccion` debería condicionar `pedirVerti` a que la acción decidida sea MECANIZAR.
- **Q2 (RETOMAR nivel 2)**: en SCA2 la tarjeta de la CA nivel 2 muestra RETOMAR a SISANS (cualquier miembro del grupo SI24) y no a Oficina; en SCA el Detalle de `sca-site` oculta el botón de nivel 2 al subperfil `CE_MF_SI24` (`SCA_DetalleAnulacionContraAnulacion`: `showWhen: not(or(local!disabled, and(nivelIntervencion="2", subPerfilLogueado="CE_MF_SI24")))`) y lo muestra a Oficina; el experto la retoma desde el site `decidir-accion`. ¿En SCA2 RETOMAR debe estar disponible para cualquier usuario del grupo SI24 o sólo para el que la capturó? ¿Debe verlo también Oficina como en SCA? No se ha cambiado.
- **Q3 (D2)**: ¿debe SCA2 intentar la impresión de la carta de nivel 2 por otra vía (plantilla distinta) o basta con una impresión por solicitud como en CORE/SCA?
- **Q4 (D6)**: tras ANULAR PÓLIZA en una wAutemis no pendiente de aceptar, ¿SCA2 debe dejar la solicitud en «Mecanización Enviada» (como SCA) en lugar de cambiar de nivel y finalizar? Hace falta localizar en SCA qué paso fija ese estado antes de tocar `SCA2 CMD Mecanizar`.
- **Q5 (D7)**: la gestión de mecanización en CORE debe llevar el perfil real del usuario que pulsa ANULAR PÓLIZA (como SCA): ¿se aplica la misma técnica que `SCA2_altaGestionCore` v7 en el nodo 8 de `SCA2 CMD Mecanizar`?
- Pendientes: borrar la instancia espuria 537547609 de `SCA2 CMD MarcarErrorRelanzado`; verificar en emisión (Consuweb/NEW) la anulación de 0005726689061 y 0005726685247; repetir el escenario con una póliza que derive a AA / fuera de norma; D6/D7 con la sesión responsable de Mecanizar/ANL.

## 8. Grabaciones y capturas

- Vídeo anotado del ciclo 2 (SCA2 15788160) y comparación: `r23c-ciclo-limpio-edited.mp4` (adjunto al mensaje final de la sesión; no se sube al repo).
- Capturas (87, prefijo `r23c-`): ciclo 1 SCA2 `r23c-sca2-01…20`, recuperación `r23c-rec-01…06`, SCA `r23c-sca-01…23`, ciclo 2 SCA2 `r23c-limpio-01…33`. Claves: `r23c-limpio-16-sisans-antes-retomar.png` / `17-sisans-capturada.png` (nuuma «-» → SISANS), `r23c-limpio-27-mecanizacion.png`, `28-anulacion-enviada.png`, `30-mecanizacion-finalizada.png`, `32-buscador-final.png`; SCA `r23c-sca-10-ca2-oficina.png`, `12-sisans-retomar-decidir.png`, `18-mecanizacion.png`, `20-buscador-final.png`, `23-mecanizacion-enviada.png`.
- Informe del agente de pruebas: `~/sca2work/r23c/r23c-informe-ui.md` (local).
