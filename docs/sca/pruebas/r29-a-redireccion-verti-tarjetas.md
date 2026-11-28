# R29-A — Redirección tras ACEPTAR, checks obligatorios en Verti/Vencimiento y tarjetas del Detalle (SCA2 vs SCA, TEST)

> Ronda 29 (23/10/2026), sesión hija R29-A. Entorno `mapfrespain-test`. Objetos leídos/modificados por LCP (GET vivo → backup → PUT completo → re-GET → `POST …/test`); prueba UI con JJGONZ2 (agente de pruebas, grabación anotada). Puntos 2, 3 y 8 del cuarto «Análisis SCA2» (doc 49). Horas en UTC salvo que se indique (CORE = hora de Madrid, UTC+2).

## 0. Resumen

| Punto del analista | Resultado |
|---|---|
| 1. Tras ACEPTAR del «CORRECTO / Procesando la decisión…» SCA2 iba al buscador | **Corregido** (`SCA2_DetalleTareas` v37): ACEPTAR sigue deshabilitado mientras el motor decide (sondeo existente de 30 s, ≈36 s medidos) y, cuando existe la siguiente tarea de la solicitud, la abre en la misma pantalla. Probado: CA negativa → **Gestión Verti/Vencimiento** sin pasar por el buscador. |
| 2. Sin marcar ningún check no debe poder iniciarse el componente | **Corregido** (`SCA2_VertiVencimientoPrincipal` v14): CONTINUAR deshabilitado + «Marque al menos una opción (Verti o Vencimiento) para continuar.». La opción marcada se guarda también en la tarea VERTI (`CMD CrearAccion` nodo 34). **SCA deja pulsar CONTINUAR ANULACIÓN sin ningún check** (divergencia pedida por el analista, a favor de SCA2). |
| 3. Detalle: «Gestión Verti/Vencimiento» con el check y la gestión del componente con su resultado | **Corregido** (`SCA2_DetalleSolicitud` v67/v68): vuelven las dos tarjetas con contenido (opción, estado, resultado, instancia, detalle del error). SCA no tiene estas tarjetas. |
| Hallazgo para R29-C | En SCA2 15788314 la solicitud se **finalizó** (CMD Mecanizar → IR A NIVEL 2 → Decidir → FIN → Finalizar, 10:58:31–10:58:52) con la gestión CORE de **Mecanización INCOMPLETA**, mientras el componente seguía abierto; en SCA 15788317 la mecanización quedó ANULACION REALIZADA y el motor creó la **CA nivel 2**. Ver §4 D-R29A-4. No es de mi columna (PM `CMD Mecanizar`, R29-C). |

## 1. Pólizas y solicitudes

Hoja «NSE emitidas después de septiembre» de `SCA2PolNSEPre.ods`, desde el PRINCIPIO (sin 2002600013207 ni 2002100296038). Comprobadas por `SCA2_consultarSolicitudes(numPoliza, null, 0)` el 23/10 ~10:20 UTC: 2002000157937 y 2002400468198 **ya tenían solicitud** (descartadas); libres 2002000200336, 2002500491505, 2002500495460 (reserva, no usada), 2002100505983, 2002100517805, 2002300346925.

| App | Póliza | Solicitud | Usuario | Resultado |
|---|---|---|---|---|
| SCA2 | 2002000200336 | **15788314** | JJGONZ2 | Alta → CA N1 negativa → ACEPTAR → **Verti/Vencimiento abierta sola** → sólo Verti → Mecanización → ANULAR PÓLIZA → CMP encadenado (RGPD manuscrita + certificación simulada TEST → consulta) → error del servicio Verti PRE → vuelta al Detalle; solicitud FINALIZADA en SCA2/CORE (ver D-R29A-4). |
| SCA | 2002500491505 | **15788317** | JJGONZ2 | Alta → CA N1 negativa → Verti previa (CONTINUAR habilitado sin check; se marcó Verti) → Mecanización → ANULAR → CMP (RGPD → consulta → derivación) → ENTENDIDO → vuelta al **buscador**; Mecanización ANULACION REALIZADA; CA nivel 2 INCOMPLETA. |

No se ha abierto ni modificado ninguna otra solicitud (las lecturas LCP de 15788296 —R28— fueron sólo `POST …/test` de interfaces, sin escribir).

## 2. Objetos SCA2 modificados

Backups y SAIL antes/después en `~/sca2work/r29a/bk/` (no se suben al repo).

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_DetalleTareas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | 36 → **37** | Siguiente tarea tras completar la acción (§2.1). |
| `SCA2_VertiVencimientoPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063389` | 13 → **14** | `local!sinSeleccion`; CONTINUAR `disabled`; texto de ayuda. |
| PM `SCA2 CMD CrearAccion` | `0000f06f-0eaa-8000-6594-7f0000014e7a` | LCP no da número (40 nodos antes/después; sólo cambia el nodo 34) | Nodo 34 «Write cierre tarea VERTI» escribe además `tokenTarea = left("VERTI:" & a!defaultValue(pv!seleccionVerti, "NINGUNO"), 64)`. |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 66 → **67** → **68** | Tarjetas VERTI/INDUCCION con contenido (§2.3); v68: sin aviso «La tarea solicitada no está disponible» al volver del componente con la tarea de la URL cerrada, y texto de resultado KO con el componente abierto. |
| Constante nueva `SCA2_GRP_CMP_GLOBAL_VERTI` | `_a-0000f097-8800-8000-9d3b-011c48011c48_5615142` | 1 | GROUP «CMP Global Verti» (visualizadores del registro `CMP Traza inducir cliente`): la tarjeta del componente sólo consulta la traza si el usuario es del grupo (JJGONZ2 lo es); si no, el resultado se deduce del estado de la tarea. |

`POST /interfaces/…/test` tras cada PUT: sin errores (15788296 sólo lectura y 15788314); la pantalla Verti devuelve CONTINUAR `disabled` y el texto de ayuda; el Detalle contiene «Gestión Verti» e «Inducción Verti».

**Campo de la opción Verti/Vencimiento (para R29-C)**: no se ha tocado el CDT `SCA2 Datos Solicitud` ni `SCA2_cargarSolicitud`. La opción queda en `SCA2 Tarea.tokenTarea` (campo `90ecf1b6-4da4-477f-923b-d4ad9431fa98`) con el formato `VERTI:VERTI` | `VERTI:VENCIMIENTO` | `VERTI:VERTI VENCIMIENTO`: en la tarea **VERTI** al cerrarse (nuevo, nodo 34) y en la tarea **MECANIZAR** (ya existía, nodo 9; la lee `SCA2_MecanizacionPrincipal` y llega a `CMD Mecanizar` como `inducirVerti`). Observado en 15788314: tarea 511 VERTI y 512 MECANIZAR con `VERTI:VERTI`. Mapeo propuesto a `tipoInduccion`: VERTI → «I», VENCIMIENTO → «V», ambos → «A».

### 2.1 `SCA2_DetalleTareas` v37

- `local!tareaPendiente` (sondeo existente, 30 s) excluye también la tarea abierta tras un salto (`local!idTareaTras`) y las INDUCCION, con `fields` explícitos; `local!tareaAccionEstado` vigila la tarea realmente gestionada (`a!defaultValue(local!idTareaTras, ri!idTareaAccion)`), y CA/AA/Autorización reciben esa misma tarea tras un salto.
- Nuevos `local!sigTipo/sigNombre/sigPantalla/sigEsMia`. Mensaje en el popup: «Se va a redirigir a la siguiente tarea: Gestión Verti/vencimiento.» (o «La siguiente tarea (…) se gestiona desde el Detalle de la solicitud.»).
- ACEPTAR (rama no MECANIZACION), con relectura en el clic:
```
if(a!isNotNullOrEmpty(local!tareaMec), {…MECANIZACION…},          /* como antes */
  if(and(a!isNotNullOrEmpty(local!sigT), local!sigTEsMia, local!sigTPantalla <> ""),
    {a!save(local!idTareaTras, <id sigT>), a!save(local!pantallaTras, local!sigTPantalla), a!save(local!hecho, false)},
    if(a!isNotNullOrEmpty(local!sigT),
      {a!save(ri!accionAbierta, false), a!save(ri!tipoAccion, null), a!save(ri!idTareaAccion, null), …},   /* Detalle */
      <comportamiento anterior: buscador si no hay siguiente tarea (FIN) >)))
```
  `sigTPantalla`: CONTRA* → CONTRA ANULAR, MECANIZAR* → MECANIZACION, VERTI, ACC* → ACC ADM, AUTORIZACION*; tipos con «NIVEL» (p. ej. CONTRA ANULAR NIVEL 2) → Detalle, para que se tomen con RETOMAR (que registra la captura en CORE, R24 #12). `sigTEsMia` = `asignadoA` = usuario conectado.
- Sin espera añadida: ACEPTAR se habilita cuando el sondeo ve la tarea (Appian no permite navegar sin un evento del usuario; el ACEPTAR único equivale al «Se va a redirigir…» de SCA).

### 2.2 `SCA2_VertiVencimientoPrincipal` v14
```
local!sinSeleccion: and(or(local!mostrarVerti, local!mostrarVencimiento),
  not(and(local!mostrarVerti, contains(toboolean(a!defaultValue(local!checkVerti, {})), true))),
  not(and(local!mostrarVencimiento, contains(toboolean(a!defaultValue(local!checkVencimiento, {})), true)))),
… a!buttonWidget(label: "CONTINUAR", disabled: local!sinSeleccion, …)
```
Si la pantalla no ofrece ninguna opción (sin contactos) CONTINUAR sigue habilitado, como antes.

### 2.3 `SCA2_DetalleSolicitud` v67/v68
- `local!tareasMaps` vuelve a incluir VERTI cerradas e INDUCCION (sólo se ocultan INDUCCION CANCELADA), con `token` y `proceso`; INDUCCION pendiente = estado «En curso» (sin RETOMAR/enlaces).
- Tarjeta **Gestión Verti/vencimiento**: fechas, nivel, perfil, grupo, nuuma + «Opción seleccionada» (Verti / Vencimiento / Verti y Vencimiento; si la tarea VERTI antigua no tiene token, se toma el de la MECANIZAR).
- Tarjeta **Inducción Verti/vencimiento (Componente)**: «Opción enviada al componente», «Estado del componente» (En curso / Terminado), «Resultado del componente» y «Instancia del componente» (`SCA2 Tarea.proceso`, la escribe `CMD Mecanizar` 333 al cerrar: «-» mientras está abierto) y, si hay error, «Detalle del resultado». Resultado: última fila de `CMP Traza inducir cliente` (registro del CMP, app CMP Verti) de la póliza: OK → «Completado sin incidencias»; KO → «Terminado con error» o, si la gestión sigue abierta, «Con error (el componente sigue abierto)»; sin traza → «Completado sin incidencias» si la tarea está cerrada, «En curso» si no. Limitación: el CMP no deja traza en todos los casos (sólo 29 filas en TEST; `CMP Auditoria Inducir` sólo guarda nombre de proceso) y no hay otra salida legible del Sub-Process (el CMP no devuelve PVs de resultado; PVs de la instancia 687301 = sólo entradas).
- v68: `showWhen` del aviso «La tarea solicitada no está disponible» añade `not(local!tareaUrlCerrada)`: al volver del componente a la URL de la mecanización (tarea cerrada) se muestra el Detalle sin aviso aunque la solicitud ya esté finalizada.

## 3. Prueba UI (agente de pruebas, JJGONZ2, 23/10)

Grabación `r29a-edited.mp4` (3 min 17 s). Capturas `r29a_sca2_NN_*` / `r29a_sca_NN_*` (90 PNG, 1600×1000) y registro `r29a_utc.log`.

| Paso | SCA (15788317) | SCA2 (15788314) | Veredicto |
|---|---|---|---|
| Póliza sin solicitud | Buscador vacío (`r29a_sca_01`) | Buscador vacío (`r29a_sca2_01`) | Igual |
| Alta | Gestión 8 FINALIZADA 13:05:26 (CORE) | Gestión 8 FINALIZADA 12:49:31; tras GUARDAR la decisión tarda (>80 s; caso #9 conocido) | Igual en resultado |
| CA N1 negativa | Gestión 2 FINALIZADA NEGATIVA 13:10:36 | Gestión 2 FINALIZADA NEGATIVA 12:54:18 | Igual |
| Popup tras la CA | Encadena a la pantalla Verti previa (`r29a_sca_19`) | CORRECTO «Procesando…» con ACEPTAR deshabilitado 10:54:30 (`r29a_sca2_20`) → 10:55:06 «Se va a redirigir a la siguiente tarea» y ACEPTAR habilitado (36 s, `r29a_sca2_21`) → ACEPTAR → **Gestión Verti/Vencimiento de la misma solicitud** (`r29a_sca2_22`) | **Igual** (antes SCA2 iba al buscador) |
| Verti/Vencimiento sin check | CONTINUAR ANULACIÓN **habilitado** sin check (`r29a_sca_20_verti_sin_seleccion`; no se envió así) | CONTINUAR **deshabilitado** + aviso (`r29a_sca2_23_verti_bloqueo`) | Distinto: SCA2 cumple lo pedido por el analista |
| Verti marcado → Mecanización | Mecanización | Sólo Verti → CONTINUAR → CORRECTO → «Se va a redirigir a la anulación» → Mecanización (`r29a_sca2_24…28`); tarea 511 `VERTI:VERTI` | Igual |
| ANULAR → componente | RGPD → consulta → derivación → ENTENDIDO → buscador (`r29a_sca_2x…33`) | RGPD manuscrita + certificación simulada → consulta → **error servicio Verti PRE** «Failed to connect to https://webservices.pre.mapfre.net:26004/…/poliza/2002000200336/verti» → «Completar la derivación» → vuelta al Detalle (`r29a_sca2_29…37`) | Encadenado igual; el error es del servicio externo (no se reintentó) |
| Detalle | Sin tarjetas Verti/componente (`r29a_sca_38_detalle_real`); Mecanización ANULACION REALIZADA (`r29a_sca_39`) | v67: aviso «La tarea solicitada no está disponible» (corregido en v68). v68: «Gestión Verti/vencimiento» Opción seleccionada = **Verti**, fechas/usuario (`r29a_sca2_45_v68_gestion`); «Inducción… (Componente)» Verti / **En curso** / **Con error (el componente sigue abierto)** / instancia «-» + detalle del error (`r29a_sca2_46_v68_componente`); misma vista desde el buscador y desde la URL de vuelta (`r29a_sca2_44`, `r29a_sca2_47`) | Lo pedido por el analista |
| Decisión posterior | CA **nivel 2** INCOMPLETA 13:21:47 | Solicitud **FINALIZADA** (FIN) 10:58:52 UTC con Mecanización CORE **INCOMPLETA** | **Distinto** → D-R29A-4 (R29-C) |
| Consulta cruzada | 15788314 visible en SCA (`r29a_sca_41`) | 15788317 «datos de CORE, sólo consulta», CA N2 incompleta (`r29a_sca2_50`) | Igual (CORE común) |

## 4. Divergencias

| Id | Divergencia | Exclusiva SCA2 | Acción |
|---|---|---|---|
| D-R29A-1 | ACEPTAR tras la CA negativa iba al buscador. | Sí | **Corregida** (v37). |
| D-R29A-2 | Verti/Vencimiento: SCA permite continuar sin check. | No (SCA lo permite) | SCA2 lo bloquea por petición expresa del analista. |
| D-R29A-3 | Tarjetas Verti/componente: SCA no las tiene. | — | Añadidas en SCA2 por petición del analista. |
| D-R29A-4 | 15788314: `CMD Mecanizar` (proceso 9110907, versión de R29-C con ramas en paralelo) registró MECANIZADA 10:58:31 e «IR A NIVEL 2» 10:58:34; `CMD CrearAccion` → `CMD Decidir` (10:58:45) → FIN → `CMD Finalizar` 10:58:52: solicitud FINALIZADA (nivel 2), CORE `codEstSolic 4`, gestión 5 Mecanización **INCOMPLETA** con fecha fin 12:58:52 (Madrid). En SCA (y en SCA2 en R28) la gestión 5 pasa a ANULACION REALIZADA (≈1 min) y el motor crea la CA nivel 2. Hipótesis: la rama paralela decide antes de que CORE confirme la anulación. | Sí | **No corregida** (PM `CMD Mecanizar` es de R29-C). Se comunica a R29-C/padre. |
| D-R29A-5 | Popup tras la CA: ACEPTAR se habilita al detectar la siguiente tarea (≈36 s; sondeo 30 s). SCA encadena la pantalla sin pulsar. | Sí | Documentada: en SAIL no se puede navegar sin evento del usuario; se mantiene un único ACEPTAR. |
| D-R29A-6 | Tras el componente SCA vuelve al buscador; SCA2 al Detalle (D10 de R28). | Sí (mejor en SCA2) | Sin cambio. |

## 5. Estados CORE / SCA2 observados

`SCA2_consultaGestion` (horas Madrid):

| Solicitud | numGestion | acción | estado | nivel | inicio | fin |
|---|---|---|---|---|---|---|
| 15788314 (SCA2) | 43706645 | 8 Alta | FINALIZADA | 1 | 12:49:31 | 12:49:31 |
| | 43706646 | 2 CA | FINALIZADA NEGATIVA | 1 | 12:49:53 | 12:54:18 |
| | 43706647 | 4 Impresión | FINALIZADA | 1 | 12:54:19 | 12:54:19 |
| | 43706648 | 5 Mecanización | **INCOMPLETA** | 1 | 12:56:44 | 12:58:52 |
| 15788317 (SCA) | 43706658 | 8 Alta | FINALIZADA | 1 | 13:05:26 | 13:05:26 |
| | 43706662 | 2 CA | FINALIZADA NEGATIVA | 1 | 13:08:28 | 13:10:36 |
| | 43706663 | 4 Impresión | FINALIZADA | 1 | 13:09:14 | 13:09:14 |
| | 43706668 | 5 Mecanización | ANULACION REALIZADA | 1 | 13:12:40 | 13:14:02 |
| | 43706678 | 2 CA | INCOMPLETA | 2 | 13:21:47 | — |

`SCA2_consultarSolicitudes`: 2002000200336 → 15788314 `codEstSolic 4`, `fecResolucion 23/10/2026 12:58:52`; 2002500491505 → 15788317 `codEstSolic 2`.

SCA2 15788314 (UTC): `SCA2 Solicitud` FINALIZADA / interfazActiva FIN / nivel 2 / mecanizacionRealizada true. `SCA2 Tarea`: 510 CONTRAANULAR COMPLETADA (10:49:55→10:54:11), 511 VERTI COMPLETADA (10:54:37→10:56:42, `VERTI:VERTI`), 512 MECANIZAR FINALIZADA (10:56:46→10:58:34, `VERTI:VERTI`), 514 INDUCCION **PENDIENTE** (10:58:32, sin proceso). `SCA2 Transicion` 1877–1891 (Alta, Decidir, CrearAccion, CompletarAccion, Decidir→MECANIZAR, CrearAccion→PDTE_MECANIZAR, Mecanizar→MECANIZADA y →IR A NIVEL 2, CrearAccion→NIVEL, Decidir, CrearAccion→FIN, Finalizar→FINALIZADA), todas OK. `SCA2 Error`: ninguno. `CMP Traza inducir cliente`: KO servicio VERTI (Failed to connect) para la póliza.

## 6. Limitaciones / pendiente

- No se pudo validar el final feliz del componente en SCA2 (ENTENDIDO, «Terminado», instancia informada) por el error de conectividad del servicio Verti PRE; tampoco las variantes «sólo Vencimiento», «Verti y Vencimiento» ni «siguiente tarea de otro usuario» (no estaban en el recorrido).
- La instancia del componente sólo se conoce al cerrar (nodo 333 de `CMD Mecanizar`); si R29-C la escribe al crear la tarea INDUCCION (nodo 332), la tarjeta la mostrará desde el inicio.
- Alta → siguiente tarea (duda #9, doc 44): no aplicado; `SCA2_AltaSolicitudPage` no está en mi columna y la propuesta del doc 44 sigue pendiente de aprobación.
- Objetos de SCA, SCAC, CORE, CMP, GAIA, PRE y Documentum no tocados.

## 7. Preguntas al analista

1. ¿Se acepta un único ACEPTAR (habilitado en cuanto existe la siguiente tarea, ≈30–40 s) o se quiere otro aviso mientras se decide?
2. Tareas de nivel > 1 (p. ej. CA nivel 2) tras el popup: ¿abrir directamente (sin la llamada de captura de RETOMAR a CORE) o, como ahora, ir al Detalle para RETOMAR?
3. D-R29A-4 (para R29-C): con la mecanización en paralelo al componente, ¿la decisión debe esperar a que CORE confirme la anulación (como SCA) antes de decidir nivel/FIN?

## 8. Grabaciones y capturas

- Grabación: `r29a-edited.mp4`.
- Capturas clave: `r29a_sca2_20_popup_procesando`, `r29a_sca2_21_popup_redireccion`, `r29a_sca2_22_verti_sin_seleccion`, `r29a_sca2_23_verti_bloqueo`, `r29a_sca2_45_v68_gestion`, `r29a_sca2_46_v68_componente`, `r29a_sca2_47_v68_url_retorno`, `r29a_sca_20_verti_sin_seleccion`, `r29a_sca_38_detalle_real`, `r29a_sca_39_mecanizacion_realizada`, cruzadas `r29a_sca_41_cruzada_identificador`, `r29a_sca2_50_cruzada_solicitud`. Paquete completo `r29a_capturas_y_utc.zip`. No se añaden vídeos ni imágenes al repositorio.
