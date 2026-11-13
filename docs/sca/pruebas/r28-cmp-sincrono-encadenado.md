# R28 — Componente Inducir Cliente (Verti) entero, síncrono y encadenado desde ANULAR PÓLIZA (SCA2 vs SCA, TEST)

> Ronda 28 (23/10/2026), sesión única. Entorno `mapfrespain-test`. Objetos leídos y modificados por LCP (`/process-models`, `/interfaces`, `/constants`, `POST …/test`); prueba UI con JJGONZ2 (agente de pruebas, grabación anotada). Continúa `r27-c-orquestacion-mecanizar-cmp.md` (D4) y el doc 47 (rondas 26/26-b).
>
> Instrucción del usuario (22/10 21:30): «No hace falta que salga los siguientes avisos y cards por el componente de inducir verti. […] se tiene que ejecutar el componente entero de inducir verti, de forma síncrona en la pantalla. […] Alta de Solicitud → decidir acción → Contra anular (finalizada negativa) → decidir mecanizar (mecanizar) → mecanizar → decidir contacto (verti y/o vencimiento) → CMP inducir cliente → decidir acción (salto de nivel / tarea de nivel / finalizar)».

## 0. Resumen ejecutivo

- **Hecho**: en SCA2, al pulsar **ANULAR PÓLIZA** la primera pantalla del componente corporativo `CMP Inducir Cliente Completo` se abre **sola, en la misma pestaña del site** (`/suite/sites/sca2/…`), y todas las siguientes (cotización, consentimiento, **firma RGPD**, consulta Verti, resumen…) vienen encadenadas hasta que el CMP termina; después el usuario vuelve al Detalle de la solicitud y SCA2 sigue en segundo plano (espera ANL si procede → fin gestión SGC → «IR A NIVEL n+1» → `CMD CrearAccion` → `CMD Decidir`, motor). Es el mismo comportamiento que SCA (`SCA_Mecanizacion` nodo 28 Sub-Process encadenado tras un formulario de tarea).
- **Cómo**: dos cortes de cadena identificados en R27-C, ambos resueltos en SCA2 (el CMP y SCA no se tocan): (1) el botón ANULAR PÓLIZA arrancaba `SCA2 CMD Mecanizar` con `a!startProcess`, que no muestra las tareas encadenadas → ahora es un **`a!startProcessLink`** (tarjeta-botón) con los mismos `processParameters`; (2) el nodo 330 «Inducción Verti (CMP)» era un *Start Process* síncrono, que no propaga la cadena → sustituido por el nodo **334 Sub-Process síncrono y encadenado** (`chainsInto = 1`) con el mismo mapeo de parámetros, y **todo el camino** inicio → … → 334 → … → fin encadenado.
- **Avisos y tarjetas retirados** (petición del usuario): panel amarillo «Inducción Verti (componente Inducir Cliente)» (`rule!SCA2_InduccionVertiPanel`) fuera de `SCA2_DetalleTareas` y `SCA2_DetalleSolicitud`; en «Gestiones realizadas» ya no se pintan las tareas internas de tipo **INDUCCION** («Inducción Verti/Vencimiento (componente)») ni las de tipo **VERTI** («Gestión Verti/vencimiento») una vez cerradas (la tarjeta VERTI pendiente se conserva porque es la vía RETOMAR a la pantalla previa). Los registros `SCA2 Tarea` INDUCCION se siguen escribiendo/cerrando (nodos 332/333) pero ocultos; la **pantalla previa Verti/Vencimiento** (doc 45) se mantiene intacta.
- **Prueba**: ver §5 (SCA2 y SCA con solicitudes nuevas, grabación `r28-…`). Divergencias restantes y preguntas en §4 y §9.

## 1. Pólizas y solicitudes

Pólizas NSE Autos «recién emitidas» tomadas del final de `SCA2PolNSEPre.ods` (hoja «NSE emitidas después de septiembre»), evitando 2002600013207, 2002100296038, 2002600060549 y 2002600060543. Comprobadas sin solicitud por `SCA2_consultarSolicitudes(numPoliza, null, 0)` → `null` el 23/10 06:1x UTC: 2002600060547, 2002600060546, 2002600060544, 2002600060542, 2002600060536, 2002600060533, 2002600060362, 2002600060532, 2002600060531, 2002600060521, 2002600060519, 2002600060528, 2002600060520.

| App | Póliza | Solicitud | Usuario | Resultado |
|---|---|---|---|---|
| SCA2 | 2002600060547 | **15788296** | JJGONZ2 | Alta → CA N1 negativa → Verti previa (RETOMAR) → Mecanización → ANULAR PÓLIZA → **primera pantalla del CMP abierta sola** (RGPD) → firma manuscrita/impresión (certificación simulada TEST) → consulta Verti → NO ASEGURABLE → ENTENDIDO → **vuelta al Detalle** → CA **nivel 2** Incompleta (gestión 43706594). |
| SCA | 2002600060546 | **15788297** | JJGONZ2 | Mismo recorrido → primera pantalla del CMP abierta sola (vencimientos; sin RGPD para este cliente) → ASEGURABLE → derivación → ENTENDIDO → vuelta al **buscador** de `decidir-accion` → CA **nivel 2** Incompleta (gestión 43706599, 5 min 14 s después). |

Ninguna solicitud protegida ni ajena ha sido abierta ni modificada (lectura por LCP de 15788292 sólo para `POST /interfaces/…/test`, sin escribir).

## 2. Flujo final (pantalla → PM → CMP → vuelta)

Leyenda: `·` conector encadenado (`activityChained = true`), `ø` no encadenado.

```mermaid
flowchart TD
  CA[Contra Anulación N1 negativa → CMD CompletarAccion → CMD Decidir: MECANIZAR] --> PREV[Pantalla previa «Verti / Vencimiento» CONTINUAR<br/>(switch ON ∧ contacto VERTI/VENC., doc 45) — sin cambios]
  PREV --> MEC[SCA2_DetalleTareas → SCA2_MecanizacionPrincipal v19<br/>tarjeta-botón ANULAR PÓLIZA = a!startProcessLink(SCA2 CMD Mecanizar, mismos processParameters)]
  MEC -- "clic (sigue la cadena)" --> N16[CMD Mecanizar 1 Start · 16 Cargar: cargarSolicitud + flagVerti + determinarContacto ·]
  N16 --> N3{3 ¿Ya ejecutado? ·} --> N4{4 ¿Caducada? ·} --> N6{6 Inducción VERTI? ·} --> N8[8 Guardar Mecanización CORE ·]
  N8 --> N9{9 Success? ·}
  N9 -->|wAutemis pdte.| N340[340 Bloqueo NEW · → 10 Crear Autorización · → 11 ·]
  N340 --> N13
  N9 -->|ok| N13[13 Write Éxito: MECANIZADA / procesoActivo ANL ·]
  N13 --> N200{200 ·} --> N300{300 ¿ANL ya creada? ·}
  N300 -->|no| N301[301 SUB ANL Alta asíncrono ·] --> N331
  N300 -->|sí| N331{331 ¿Inducir Verti? contacto ∋ VERTI ∨ VENCIMIENTO ·}
  N331 -->|sí| N332[332 Write Tarea INDUCCION pendiente (oculta) ·] --> N334[[334 SUB-PROCESS síncrono encadenado<br/>CMP Inducir Cliente Completo (chainsInto=1, runAs INITIATOR)<br/>aplicacion SCA · tipoInduccion I · usuarioAppian = pp!initiator]]
  N334 -. "primera pantalla se abre sola en /suite/sites/sca2/…" .-> CMP[CMP Fase 2: Mensaje consentimiento → Firma RGPD (Completo→Main/OneTrust) → Solicitud cotización → Consulta Verti → Resumen → Verti/Cancelar/Derivación<br/>todo encadenado dentro del CMP (R27-C §6)]
  CMP --> N333[333 Write cierre Tarea INDUCCION ·]
  N331 -->|no| N324
  N333 --> N324{324 ¿wAutemis pdte. aceptar? ·}
  N324 -->|sí| N302[302 Esperar ANL 5 min ø — corte de cadena: el usuario vuelve al Detalle] --> N303[303 Consultar ANL → 304 → 308/309/305 → 306 → 325]
  N324 -->|no NSE| N325[325 Recargar · → 326 Finalizar gestión SGC · → 320 Write IR A NIVEL n+1 / FIN PROCESO · → 321 · → 322 Start Process CMD CrearAccion · → End]
  N325 --> BACK[Vuelta al site: misma URL buscador?idSolicitud&tipoAccion&idTarea → SCA2_DetalleSolicitud v65: tarea cerrada / anulación lanzada ⇒ Detalle (no el formulario)]
  N302 --> BACK
  BACK --> DEC[CMD CrearAccion 10-12 → CMD Decidir (motor): CA nivel 2 / AA / FIN PROCESO]
```

Notas de diseño:
- **Chained ≠ bloqueante**: la cadena sólo decide qué ve el usuario (pantallas encadenadas y un indicador de carga entre nodos no atendidos). Si el CMP no presenta pantallas para el cliente (caso 15788275 en R26-b), toda la cadena es no atendida: Appian la corta al llegar a ~50 nodos o al terminar, y devuelve al usuario a la página. Los nodos no atendidos antes del CMP son 13 (16, 3, 4, 6, 8, 9, [340, 10, 11], 13, 200, 300, 301, 331, 332) + ~7 del CMP hasta su primera tarea; muy por debajo del límite.
- **ANL Alta (301)** sigue siendo un subproceso **asíncrono** (como estaba; en SCA va en paralelo con la inducción mediante un AND): no bloquea ni corta la cadena porque el nodo termina en cuanto lanza el subproceso. Se mantiene el orden corregido en R27-C (guardarMecanizacion → alta ANL → CMP → espera ANL) y la espera ANL/`guardarAutorizacion` (rondas 24/25) detrás del CMP. El timer 302 corta la cadena a propósito (wAutemis): el usuario vuelve al Detalle mientras SCA2 espera a ANL.
- **Después del CMP** la cadena sigue (333 → 324 → 325 → 326 → 320 → 321 → 322 → End): el usuario ve unos segundos de carga mientras SCA2 finaliza la gestión SGC y arranca `CMD CrearAccion`, y al volver al Detalle la decisión posterior ya está en marcha (en SCA el 28 → 23 también está encadenado).
- **Identificación de la instancia del CMP**: el Sub-Process expone `ac!subProcessID` → `pv!induccionProcessId` (antes `ac!ProcessInfo.pp.id` del Start Process): mismo dato, misma PV.
- **Usuario**: con `a!startProcessLink` el iniciador de `CMD Mecanizar` es el usuario conectado (JJGONZ2), por lo que `usuarioAppian = user(pp!initiator, "username")` y el `runAs INITIATOR` del Sub-Process hacen que el CMP (y sus subprocesos de firma/Verti) asignen las tareas al mismo usuario que pulsó ANULAR PÓLIZA; antes el Start Process se ejecutaba como diseñador (`devin` aparecía como iniciador del CMP, R27-C §10).

## 3. Objetos SCA2 modificados

Procedimiento por objeto: GET del objeto vivo justo antes de editar → backup local (`~/sca2work/r28/<objeto>_<ts>_before.json`) → edición → PUT del objeto completo (inputs/nodes/PV incluidos) → re-GET y comparación (idéntico) → `POST …/test` (interfaces; los PM no tienen test en LCP) → prueba UI con solicitud nueva (§5). Backups y SAIL antes/después en `~/sca2work/r28/` (no se suben al repo).

| Objeto | UUID | Versión antes → después | Cambio |
|---|---|---|---|
| PM `SCA2 CMD Mecanizar` | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | LCP no devuelve número (`versionId` vacío); publicada 23/10 ~06:40 UTC (42 nodos antes y después) | Nodo **330** «Inducción Verti (CMP)» (Start Process, IsSynchronous=1) **eliminado** y sustituido por el nodo **334** «Inducción Verti (CMP) [SUB encadenado]» (`internal.38` SUB_PROC, `pmUUID 0002ea05-adcc-8000-8c7a-7f0000014e7a`, `isAsynchronous 0`, `isTransparent 1`, `inheritSecurity 0`, **`chainsInto 1`**, `runAs INITIATOR`, salida `ac!subProcessID → induccionProcessId`); conexiones 332→334· y 334→333·. LCP rechaza cambiar el tipo de un nodo existente («node type cannot be changed on update»), por eso el id nuevo. **Encadenadas** (ø→·) las conexiones 1→16, 16→3, 3→4, 4→6, 6→8, 8→9, 9→340, 9→13, 340→10, 10→11, 11→13, 13→200, 200→300, 300→331, 300→301, 301→331, 331→332, 331→324, 333→324, 324→325, 325→326, 326→320, 320→321, 321→322, 322→2 (ya lo estaba 302→303). Sin cambios en PV, expresiones ni en el resto de nodos. |
| `SCA2_MecanizacionPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | 18 → **19** | ANULAR PÓLIZA pasa de `a!buttonWidget` + `a!startProcess` a tarjeta-botón `a!cardLayout(link: a!startProcessLink(processModel: cons!SCA2_PM_CMD_MECANIZAR, processParameters: {…mismos…}))` (roja `cons!SCA2_VAL_COLOR_ROJO`, texto blanco; gris sin enlace y con el mismo tooltip cuando antes estaba `disabled`: error 4023 de simulación o simulación caída). El `a!buttonLayout` se sustituye por `a!columnsLayout` (CANCELAR a la izquierda, ANULAR a la derecha). En los casos con aviso previo (`mcaRecibos`, control de rechazo, observaciones `00000005`) se mantiene el botón clásico que abre el aviso, y el **ACEPTAR** del aviso que antes lanzaba `a!startProcess(CMD Mecanizar)` es ahora la misma tarjeta `a!startProcessLink`; el ACEPTAR de «FINALIZAR SOLICITUD» (control de rechazo → `CMD CompletarAccion` CANCELADO) sigue siendo botón. `ri!onAnular`/`ri!onCompletar` ya no se guardan al anular (el usuario sale de la página por la cadena). |
| `SCA2_DetalleTareas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | 35 → **36** | Retirada la llamada `rule!SCA2_InduccionVertiPanel(idSolicitud, mostrar: …)` de la tarjeta CORRECTO (sustituida por comentario R28). Resto intacto (popup CORRECTO, redirección CA → Mecanización, rama INDUCCION del `a!match`, que queda sin entrada desde el Detalle). |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 64 → **65** → **66** | (a) Retirada `rule!SCA2_InduccionVertiPanel(numPoliza, idSolicitud)` encima del acordeón. (b) `local!tareasMaps`: se excluyen las tareas de tipo **INDUCCION** y las de tipo **VERTI ya cerradas** (no se pintan como tarjetas en «Gestiones realizadas»). En v65 se ocultaba toda tarea VERTI, también la PENDIENTE: el agente de pruebas detectó en 15788296 que así desaparecía la única vía (RETOMAR) para abrir la pantalla previa Verti/Vencimiento; **corregido en v66** (la tarjeta se ve mientras la tarea esté PENDIENTE y desaparece al cerrarse). (c) Guarda de retorno: `local!tareaUrlEstado` (estado de la tarea `ri!idTarea` de la URL) y `local!procesoActivoCarga` (instantáneas al cargar, `refreshOnReferencedVarChange: false`) → `local!tareaUrlCerrada` = tarea COMPLETADA/FINALIZADA/CANCELADA ∨ (`tipoAccion` MECANIZA* ∧ `procesoActivo` ≠ `MECANIZAR*`) → `local!accionAbierta: and(isNotNullOrEmpty(ri!tipoAccion), not(solicitudCerrada), not(tareaUrlCerrada))`. Motivo: al terminar la cadena el site vuelve a la misma URL (`buscador?idSolicitud&tipoAccion&idTarea`) y sin la guarda volvería a pintar el formulario de Mecanización/Verti de una tarea ya tramitada. |

Objetos que quedan **sin uso** y no se borran (decisión del encargo): interfaz `SCA2_InduccionVertiPanel` (v6), reglas `SCA2_tareasInduccionVerti` (v4) y `SCA2_obtenerTareaInduccion` (v3; la rama INDUCCION de `SCA2_DetalleTareas` todavía la referencia, pero esa rama ya no es alcanzable desde el Detalle), constantes `SCA2_PM_CMP_INDUCIR_FASE1/FASE2`, `SCA2_PM_CMP_FIRMA_*`, `SCA2_PM_CMP_SERVICIOS_FIRMA_ONETRUST`, `SCA2_PM_CMP_FLUJO_INDUCCION_VERTI`, `SCA2_PM_CMP_CONSULTA_VERTI`, `SCA2_PM_CMP_GESTIONAR_INDUCCION_VERTI`, `SCA2_PM_CMP_RESUMEN_CONSULTA`, `SCA2_PM_CMP_OPCION_1_2` y `SCA2_REP_TAREAS_CMP_INDUCCION`. `SCA2_PM_CMP_INDUCIR_CLIENTE` sigue en uso (por su valor, en el `pmUUID` del nodo 334).

### 3.1 Fragmentos

Nodo 334 (`SCA2 CMD Mecanizar`, tras el cambio):
```json
{"id": 334, "type": "internal.38", "typeName": "SUB_PROC", "name": {"es": "Inducción Verti (CMP) [SUB encadenado]"},
 "connections": [{"targetNodeId": 333, "activityChained": true}],
 "data": {"inputs": [
   {"name": "aplicacion", "expression": "\"SCA\""},
   {"name": "cliente", "expression": "a!map(idCliente: index(index(rule!SCA_obtenerDatosCabecera(numPoliza: …numpoliza…, idSolicitud: pv!idSolicitud),\"datosCliente\",null),\"idCliente\",null))"},
   {"name": "codCia", "expression": "a!defaultValue(index(index(pv!sol,\"datosPerfilesPca\",null),\"codcompania\",null), \"41\")"},
   {"name": "entidad", "expression": "\"00\""}, {"name": "inducirA", "expression": "1"},
   {"name": "nPoliza", "expression": "…datosBasicosSolicitud.numpoliza"}, {"name": "nuuma", "expression": "…datosPerfilesPca.nuuma"},
   {"name": "producto", "expression": "…datosBasicosSolicitud.codproducto"},
   {"name": "usuarioAppian", "expression": "user(pp!initiator, \"username\")"},
   {"name": "tipoInduccion", "expression": "/* Paridad SCA_Mecanizacion nodo 28 … */ \"I\""},
   {"name": "perfilSi24", "expression": "or(codperfil = \"CE_MF_SI24\", codperfil = \"CE_MF_BK\")"},
   {"name": "numPresupuesto"}, {"name": "poliza41"}, {"name": "registroReintento"},
   {"name": "pmUUID", "value": "0002ea05-adcc-8000-8c7a-7f0000014e7a"},
   {"name": "isAsynchronous", "value": 0}, {"name": "isTransparent", "value": 1}, {"name": "inheritSecurity", "value": 0}, {"name": "chainsInto", "value": 1}],
  "customOutputs": [{"expression": "ac!subProcessID", "saveInto": "induccionProcessId"}]},
 "assignment": {"attended": false, "runAs": "INITIATOR"}}
```

`SCA2_MecanizacionPrincipal` v19 (tarjeta ANULAR PÓLIZA):
```
a!cardLayout(
  contents: a!richTextDisplayField(labelPosition: "COLLAPSED",
    value: a!richTextItem(text: "ANULAR PÓLIZA", color: "#FFFFFF", style: "STRONG"), align: "CENTER", …),
  link: a!startProcessLink(
    processModel: cons!SCA2_PM_CMD_MECANIZAR,
    processParameters: {
      idSolicitud: ri!idSolicitud, idTarea: ri!idTarea,
      verti: false, inducirVerti: local!inducirVertiSel, rolNse: local!rolNse,
      mcaReservaPrima: if(local!polizaWAutemis, local!mcaReservaPrimaWAutemis, local!mcaReservaPrima),
      importeRsvPrima: if(local!polizaWAutemis, local!primaWAutemis, local!importeRsvPrima),
      observaciones: local!observaciones }),
  style: cons!SCA2_VAL_COLOR_ROJO, shape: "SEMI_ROUNDED", showBorder: false, padding: "STANDARD", accessibilityText: "Anular póliza")
```
Opción elegida (b del encargo): **sin paso de confirmación adicional** — la pantalla de Mecanización ya es la confirmación («¿Desea anular la póliza con la información que se indica?» + datos de la anulación), de modo que el propio ANULAR PÓLIZA es el enlace encadenado y no hay doble clic. No ha hecho falta mover a `CMD Mecanizar` nada del `saveInto` anterior: la única escritura del botón era el propio `a!startProcess` (la gestión MECANIZAR en CORE la escribe el PM, nodo 8). Un `a!buttonWidget` no admite enlaces y `a!sideBySideLayout` no admite `a!cardLayout` (error de validación en el PUT), por eso la tarjeta va en un `a!columnsLayout`.

`SCA2_DetalleSolicitud` v65 (guarda de retorno y filtro de tarjetas):
```
local!tareaUrlEstado: a!refreshVariable(value: if(a!isNullOrEmpty(ri!idTarea), null, <estado de SCA2 Tarea id = tointeger(ri!idTarea)>),
  refreshOnVarChange: {ri!tipoAccion, ri!idTarea}, refreshOnReferencedVarChange: false),
local!procesoActivoCarga: a!refreshVariable(value: tostring(index(local!est, "procesoActivo", null)),
  refreshOnVarChange: {ri!tipoAccion, ri!idTarea}, refreshOnReferencedVarChange: false),
local!tareaUrlCerrada: or(
  contains({"COMPLETADA", "FINALIZADA", "CANCELADA"}, upper(a!defaultValue(local!tareaUrlEstado, ""))),
  and(search("MECANIZA", upper(a!defaultValue(tostring(ri!tipoAccion), ""))) > 0,
      a!isNotNullOrEmpty(local!procesoActivoCarga), left(upper(local!procesoActivoCarga), 9) <> "MECANIZAR")),
local!accionAbierta: and(a!isNotNullOrEmpty(ri!tipoAccion), not(local!solicitudCerrada), not(local!tareaUrlCerrada)),
…
local!tareasMaps: if(local!soloCore, local!tareasCore, reject(fn!isnull, a!forEach(items: local!tareas,
  expression: if(or(tipo = "INDUCCION", and(tipo = "VERTI", estado <> "PENDIENTE")), null, a!map(…))))),   /* v66 */
```

`POST /interfaces/{uuid}/test` tras los PUT (solicitud 15788292, sólo lectura): las tres interfaces evalúan sin error; `SCA2_MecanizacionPrincipal` pinta la tarjeta ANULAR PÓLIZA con enlace de inicio de proceso; `SCA2_DetalleSolicitud` ya no contiene «Gestión Verti» ni «Inducción Verti» (antes: 1 y 2 apariciones).

## 4. Divergencias respecto a SCA (tras R28)

| Id | Divergencia | Exclusiva SCA2 | Acción |
|---|---|---|---|
| D4 (R27-C) | Primera pantalla del CMP no encadenada tras ANULAR PÓLIZA. | Sí | **Corregida** (§2-3). |
| D8 | Tras ANULAR PÓLIZA SCA2 ya no muestra la tarjeta «CORRECTO / La anulación se ha lanzado al sistema de emisión»: se pasa directamente al componente (como SCA, que tampoco la muestra en este punto) y, al terminar, al Detalle. Si el contacto no es VERTI/VENCIMIENTO (sin CMP) la cadena termina sin pantallas y el usuario vuelve directamente al Detalle. | — | Comportamiento pedido; documentado. |
| D2 (R27-C) | `tipoInduccion` fijo «I» (SCA envía «V»/«A» con vencimiento SGC). | Sí | No corregida (decisión funcional, duda #13). |
| D3 (R27-C) | Inducción ‖ ANL Alta en paralelo (SCA) vs secuencial (SCA2); ANL Alta asíncrono. | Sí | No corregida (sin efecto funcional). |
| D5 (R27-C) | «Te lo Juro» (OneTrust manuscrito) no encadenado dentro del CMP. | No (CMP ajeno) | No modificable. |
| D9 | SCA no tiene tarjetas VERTI/INDUCCION en su Detalle (R27-C). | — | **Alineado**: SCA2 ya no las muestra (la VERTI pendiente se conserva como vía RETOMAR a la pantalla previa). |
| D10 | Al terminar el CMP, SCA vuelve al **buscador** del site `decidir-accion` y SCA2 vuelve al **Detalle** de la solicitud (guarda de `SCA2_DetalleSolicitud` v65/66). | Sí (mejor en SCA2) | No se iguala a SCA: el encargo pide volver a la página de la solicitud. Documentada. |
| D11 | ANULAR PÓLIZA → primera pantalla del CMP: SCA2 ≈17 s frente a ≈4 s en SCA (R27-C: 4,9–10 s). Entre el clic y la pantalla la cadena ejecuta `SCA2_cargarSolicitud` + `SCA2_flagVerti` + `SCA2_determinarContacto` (16), `guardarMecanizacion` en CORE (8), escritura de estado (13), `SCA_obtenerDatosCabecera` para el `idCliente` del CMP (334) y los nodos previos del CMP (consulta AGC+ASNEF); SCA ya tiene el contacto y la cabecera cargados en PV antes del formulario. | Sí | No corregida: es el coste de los servicios en línea del comando atómico; se puede reducir pasando `idCliente` desde la pantalla (ya cargado en la cabecera) en vez de volver a llamar a `SCA_obtenerDatosCabecera` en el nodo 334 y cacheando `determinarContacto`. Pregunta §9. |

## 5. Prueba UI (agente de pruebas, JJGONZ2, 23/10/2026, horas UTC; la UI de Appian muestra hora local +2)

Grabación `r28-v66-comparacion-edited.mp4` (recorrido SCA2 15788296 con `SCA2_DetalleSolicitud` v66 y recorrido SCA 15788297). Un incidente durante la prueba: con v65 la tarjeta de la tarea VERTI pendiente quedaba oculta y no había forma de abrir la pantalla previa (el ACEPTAR del popup CORRECTO sólo redirige a tareas MECANIZAR); corregido en caliente en v66 y re-ejecutado desde el Detalle (§3).

| Paso | SCA (15788297, póliza 2002600060546) | SCA2 (15788296, póliza 2002600060547) | Veredicto |
|---|---|---|---|
| Comprobación póliza sin solicitud | Buscador sin resultados (`r28_sca_01_busqueda.png`) | Buscador sin resultados (`r28_sca2_01_busqueda.png`) | Igual |
| Alta | Gestión 8 FINALIZADA 06:41:22; el alta redirige al site `decidir-accion` (`r28_sca_06_alta_generada.png`) | Gestión 8 FINALIZADA 06:23:22; tras ACEPTAR vuelve al formulario sin id (caso #9 conocido) y la solicitud se abre por el buscador (`r28_sca2_07_post_alta.png`) | Igual en resultado; navegación distinta ya conocida |
| CA nivel 1 negativa | Argumento + NEGATIVO + impresión + preguntas → gestión 2 FINALIZADA NEGATIVA 06:44:51 (`r28_sca_08…14`) | Igual → gestión 2 FINALIZADA NEGATIVA 06:26:25 (`r28_sca2_08…15`) | Igual |
| Pantalla previa Verti/Vencimiento | Encadenada tras la CA (`r28_sca_15_verti_previa.png`) | Detalle → tarjeta «Gestión Verti/vencimiento» (pendiente, visible con v66) → RETOMAR → pantalla previa → CONTINUAR (`r28_sca2_20…25`) | Igual en pantalla; acceso distinto (SCA2 por RETOMAR, como en R27-C) |
| Mecanización | Formulario de tarea, botón ANULAR PÓLIZA (`r28_sca_16_mecanizacion.png`) | `SCA2_MecanizacionPrincipal` v19 con la tarjeta roja ANULAR PÓLIZA (`r28_sca2_26_mecanizacion.png`); URL `/suite/sites/sca2/page/buscador?$sp=…` | Igual en contenido |
| ANULAR PÓLIZA → primera pantalla del CMP | 06:46:42.8 → pantalla «consulta/vencimientos» del CMP visible ≈06:46:47 (**≈4 s**), URL `/suite/sites/decidir-accion/page/decidiraccion/start-process/…` (`r28_sca_17_cmp_consulta_vencimientos.png`) | 06:33:55.9 → `SCA2 CMD Mecanizar` 687299 arranca 06:33:56.3 → pantalla **RGPD del CMP abierta sola** ≈06:34:13 (**≈17 s**, medido sobre el vídeo), URL `/suite/sites/sca2/page/buscador/start-process/HkrBGUGaEK…?parameters=…` (`r28_sca2_27_cmp_rgpd.png`) | **Igual** (automático, misma pestaña, sin Tempo, sin tarjeta CORRECTO ni panel). SCA2 tarda más (D11) |
| Pantallas del componente | Vencimientos → consulta Verti → «Para procesar… CONTINUAR» (≈53 s de carga) → **ASEGURABLE** → derivación → «Proceso de inducción completado» → ENTENDIDO 06:48:57.6; todas encadenadas en `/suite/sites/decidir-accion/…` (`r28_sca_17…21`) | RGPD → firma manuscrita/impresión → certificación TEST → consulta Verti → procesar → **NO ASEGURABLE** → ENTENDIDO 06:36:36.7; todas encadenadas en `/suite/sites/sca2/page/buscador/start-process/…` (`r28_sca2_27…32`) | Igual (encadenado); la variante del CMP depende del cliente (RGPD sólo en SCA2 esta vez) |
| Vuelta al terminar el CMP | Vuelve al **buscador** de `decidir-accion` 06:49:02 (`r28_sca_22_retorno_buscador.png`); el Detalle se abre a mano (`r28_sca_23_detalle.png`) | Vuelve **al Detalle** de la solicitud 06:36:43 (6 s tras ENTENDIDO; la cadena recorrió 333→…→322): Mecanización «Anulación Realizada», sin panel amarillo, sin tarjetas VERTI/INDUCCION (`r28_sca2_33_retorno.png`, `r28_sca2_34_mecanizacion_realizada.png`) | Distinto a favor de SCA2 (D10) |
| Mecanización en CORE antes de terminar el CMP | Gestión 5 ANULACION REALIZADA 06:47:12 (CMP terminó 06:48:57) | Gestión 5 ANULACION REALIZADA 06:34:37 (CMP terminó 06:36:37) | Igual (orden R27-C) |
| Decisión posterior («decidir acción» nivel 2) | CA nivel 2 INCOMPLETA 43706599 a **06:54:11** (5 min 14 s tras ENTENDIDO; a 06:52:33 la UI aún mostraba NIVEL 1, `r28_sca_28_estado_final_sin_nivel2.png`; confirmado por LCP) | CA nivel 2 INCOMPLETA 43706594 a **06:36:58** (21 s tras ENTENDIDO), visible tras F5 (`r28_sca2_35_nivel2.png`) | Igual en resultado; SCA2 más rápido (como en R27-C) |
| Consulta cruzada | 15788296 abierta desde SCA: NIVEL 2 (`r28_sca_27_cruzada_nivel2.png`) | 15788297 abierta desde SCA2: «Solicitud gestionada en SCA o histórica: datos de CORE, sólo consulta» (`r28_sca2_37_cruzada_detalle.png`) | Igual (CORE común) |
| Bandeja de errores SCA2 | — | `SCA2_consultarErroresSolicitud(15788296)` → `[]` | OK |

Tiempos: SCA2 ANULAR → primera pantalla ≈17 s (R27-C: SCA 4,9–10 s; aquí SCA ≈4 s); CMP → decisión nivel 2: SCA2 21 s, SCA 5 min 14 s. La firma RGPD se completó en la variante manuscrita/impresión marcando la certificación simulada de TEST (dato de prueba, no es una firma real).

## 6. Estados CORE / SCA2 observados (LCP, 23/10 06:4x UTC; horas CORE = hora de Madrid, UTC+2)

Solicitud SCA2 **15788296** (póliza 2002600060547), `SCA2_consultaGestion`:

| numGestion | acción | estado | nivel | inicio | fin |
|---|---|---|---|---|---|
| 43706590 | 8 Alta | FINALIZADA | 1 | 08:23:22 | 08:23:22 |
| 43706591 | 2 Contra Anulación | FINALIZADA NEGATIVA | 1 | 08:23:44 | 08:26:25 |
| 43706592 | 4 Impresión | FINALIZADA | 1 | 08:26:27 | 08:26:27 |
| 43706593 | 5 Mecanización | **ANULACION REALIZADA** | 1 | 08:33:18 | **08:34:37** (antes de terminar el CMP, 08:36:37: orden R27-C conservado) |
| 43706594 | 2 Contra Anulación | INCOMPLETA | **2** | **08:36:58** (21 s después de ENTENDIDO) | — |

`SCA2_consultarSolicitudes(2002600060547)` → `codEstSolic 2`, `idSolicitud 15788296`, `fecResolucion null`. `SCA2_consultarErroresSolicitud(15788296)` → `[]` (sin errores). Tareas `SCA2 Tarea` de la solicitud: 474 CONTRAANULAR COMPLETADA (06:23:45→06:26:18 UTC), 475 «Gestión VERTI/Vencimiento» tipo VERTI COMPLETADA (06:26:47→06:33:16), 476 MECANIZAR FINALIZADA (06:33:20→06:36:39, token `VERTI:VERTI`), 477 «Inducción Verti/Vencimiento (componente)» tipo INDUCCION COMPLETADA (06:34:04→06:36:37, `proceso 687301`; **oculta** en el Detalle), 478 CONTRA ANULAR NIVEL 2 PENDIENTE (06:36:59).

Procesos (`GET /processes/{id}`), verificación del punto 1.c del encargo:

| Proceso | id | PM (versión) | Iniciador | Inicio → fin (UTC) | parentId |
|---|---|---|---|---|---|
| `SCA2 CMD Mecanizar - 23/10/2026 8:33 CEST` | **687299** | SCA2 CMD Mecanizar **36.0** | **JJGONZ2@mapfrenopro.onmicrosoft.com** (antes `devin`, R27-C §10) | 06:33:56 → 06:36:41 | — (arrancado por `a!startProcessLink`) |
| `CMP Inducir Cliente - 38917013` | **687301** | CMP Inducir Cliente Completo 52.0 | JJGONZ2@mapfrenopro.onmicrosoft.com | 06:34:07 → 06:36:37 | **687299** (creado por el Sub-Process 334) |

PV de 687299: `idSolicitud 15788296`, `idTarea 476`, `numGestion 43706593`, `success true`, `inducirVerti true`, `contacto.listaContactos ∋ VERTI`, **`induccionProcessId 687301`** (el `ac!subProcessID` del Sub-Process llega a la misma PV). PV del CMP 687301: `aplicacion SCA`, `tipoInduccion I`, `inducirA 1`, `nPoliza 2002600060547`, `nuuma JJGONZ2`, `perfilSi24 false`, **`usuarioAppian JJGONZ2@mapfrenopro.onmicrosoft.com`** (asignatario de sus tareas = usuario conectado). ANULAR PÓLIZA se pulsó a las 06:33:55.9 UTC y el proceso arrancó a las 06:33:56.3: el enlace de inicio de proceso lanza el PM al instante y la cadena llega a la primera pantalla del CMP en pocos segundos (§5).

## 7. Lo que no se puede encadenar por diseño del CMP

- `CMP Servicios Firma RGPD OneTrust` 4 «¿Induccion?» → 5 «Te lo Juro» (canal manuscrito con inducción): conector sin encadenar dentro del CMP (D5, R27-C). Afecta igual a SCA.
- Firma RGPD «no inmediata»: el CMP queda esperando la firma del cliente (tarea del subproceso de firma caduca a los 60 min, R26-b): la cadena se corta en esa espera y el usuario vuelve al Detalle; SCA2 sigue esperando al CMP (nodo 334 síncrono) igual que SCA.
- Si el CMP crea su primera tarea para otra identidad (p. ej. `JJGONZ2@mapfre.net` frente a `JJGONZ2@mapfrenopro.onmicrosoft.com`, Q7/APP-SCAN), la cadena no la mostraría: con `runAs INITIATOR` y `usuarioAppian = pp!initiator` el asignatario es el usuario conectado.

## 8. Limitaciones

- LCP no devuelve el número de versión de los PM (`versionId` vacío) ni permite cambiar el tipo de un nodo (de ahí el nodo 334 nuevo y el 330 eliminado); no hay `POST /process-models/{uuid}/test`: la validación del PM es la prueba UI.
- LCP sí expone `GET /processes/{id}` (processId, name, status, initiator, startTime, parentId, variables), usado en §6 para verificar que la instancia del CMP la crea el Sub-Process; no expone listados (`/processes?…` → 501) ni arranque de procesos.
- No se han tocado objetos del CMP, SCA, SCAC, CORE, GAIA, PRE ni Documentum.

## 9. Preguntas al analista / decisiones pendientes

1. ¿Se quiere algún aviso breve al volver del componente (p. ej. toast «Anulación enviada; la solicitud continúa») o basta con el Detalle actualizado? Hoy no se muestra nada (SCA vuelve al buscador sin aviso).
4. D11: ¿se acepta el ≈17 s entre ANULAR PÓLIZA y la primera pantalla del componente (indicador de carga de Appian) o se optimiza (pasar `idCliente` desde la pantalla y evitar la segunda llamada a cabecera en el nodo 334)?
2. D2: `tipoInduccion` «V»/«A» con vencimiento SGC (duda #13) sigue abierta.
3. Objetos sin uso (`SCA2_InduccionVertiPanel`, reglas y constantes `SCA2_PM_CMP_*` de los subprocesos): ¿se borran en la limpieza técnica siguiente?

## 10. Grabaciones y capturas

- Grabación: `r28-v66-comparacion-edited.mp4` (SCA2 15788296 con v66 + SCA 15788297, consultas cruzadas).
- Capturas SCA2: `r28_sca2_01_busqueda` … `r28_sca2_15_ca_correcto` (alta y CA), `r28_sca2_20_v66_verti_pendiente`, `r28_sca2_21…25_verti_*`, `r28_sca2_26_mecanizacion`, `r28_sca2_27_cmp_rgpd`, `r28_sca2_28_cmp_firma_manuscrita`, `r28_sca2_29_cmp_certificacion_test`, `r28_sca2_30_cmp_consulta_verti`, `r28_sca2_31_cmp_procesar`, `r28_sca2_32_cmp_no_asegurable`, `r28_sca2_33_retorno`, `r28_sca2_34_mecanizacion_realizada`, `r28_sca2_35_nivel2`, `r28_sca2_36…38_cruzada_*`.
- Capturas SCA: `r28_sca_01_busqueda` … `r28_sca_14_post_ca`, `r28_sca_15_verti_previa`, `r28_sca_16_mecanizacion`, `r28_sca_17_cmp_consulta_vencimientos`, `r28_sca_18_cmp_consulta_rellena`, `r28_sca_19_cmp_procesar`, `r28_sca_20_cmp_asegurable`, `r28_sca_21_cmp_completado`, `r28_sca_22_retorno_buscador`, `r28_sca_23_detalle`, `r28_sca_24_detalle_refresco`, `r28_sca_25_estado_nivel1`, `r28_sca_26_cruzada_detalle`, `r28_sca_27_cruzada_nivel2`, `r28_sca_28_estado_final_sin_nivel2`.
- Registro cronológico por pantalla: `events.jsonl` (paquete `r28_capturas.zip`). No se añaden vídeos ni imágenes al repositorio.
