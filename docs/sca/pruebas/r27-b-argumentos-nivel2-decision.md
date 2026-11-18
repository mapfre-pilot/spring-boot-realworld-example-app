# R27-B · Orden de los argumentos en la Contra Anulación de nivel 2 y lentitud de «Procesando la decisión» — SCA vs SCA2 (22/10/2026)

Sesión hija B de la ronda 27. Entorno TEST. Usuarios UI: `JJGONZ2` (Oficina, CE_RM) y `SISANS` (SI24 experto). Referencia funcional: SCA. Puntos del analista (documento «Análisis SCA2», 22/10): (1) en la CA de nivel 2 los argumentos ejecutados en nivel 1 aparecen mezclados con los nuevos; (2) «tarda mucho en decidir» tras la CA nivel 1 negativa.

## 1. Resumen

| Punto | Veredicto |
|---|---|
| 1. Orden de argumentos en nivel 2 | **Corregido en SCA2** (2 interfaces de mi columna). SCA y SCA2 (antes) pintaban igual: la tabla se ordenaba por el campo `orden` del servicio, con lo que los argumentos ya ejecutados en nivel 1 quedaban intercalados con los nuevos. Ahora SCA2 muestra primero los ejecutados en CA anteriores (alfabético), una fila separadora y después los nuevos en el orden del servicio. No es una divergencia SCA↔SCA2 sino una mejora pedida por el analista sólo para SCA2. |
| 2. Lentitud «Procesando la decisión…» | **No corregido (fuera de mi columna + decisión funcional)**. Medido con solicitud nueva: el backend tarda **38 s** desde FINALIZAR hasta que existe la tarea de nivel 2 (cadena CompletarAccion → Decidir → CrearAccion NIVEL → Decidir → CrearAccion, 5 procesos encadenados, 2 llamadas al motor de decisión y 3 a CORE) y la pantalla `SCA2_DetalleTareas` sondea cada **30 s** (`refreshInterval: 0.5`, mínimo que permite Appian), de modo que el usuario ve el mensaje entre ~40 y ~70 s. Propuesta en §5. |

## 2. Pólizas y solicitudes

De las 16 pólizas asignadas (hoja «Wautemis que derivan», desde el principio) **sólo `0005726681936` estaba libre**; las otras 15 ya tenían solicitud de rondas anteriores (`SCA2_consultarSolicitudes`): 0005726674052→15787862, 0005726674055→15787900, 0005726674004→15787861, 0005726678312→15787897, 0005726678405→15787873/15787867, 0005726680285→15787904/15787893, 0005726679137→15787921, 0005726677758→15787891, 0005726680401→15787895, 0005726679775→15787889, 0005726681055→15787898, 0005726685339→15787902/15787901, 0005726681805→15787923, 0005726681713→15788148, 0005726682097→15788149. Para la comparación en SCA tomé las siguientes pólizas libres de la misma hoja (filas 17+): `0005726681296` (al ir a usarla ya tenía la solicitud 15788291, creada por otra sesión entre mi comprobación y la prueba: no se tocó) y `0005726681370`.

| App | Póliza | Solicitud | Creada por | Uso |
|---|---|---|---|---|
| SCA2 | 0005726681936 | **15788293** | JJGONZ2 (UI) | CA nivel 1 negativa (3 argumentos) → CA nivel 2 retomada por SISANS (1 argumento negativo, **sin finalizar**) |
| SCA | 0005726681370 | **15788294** | JJGONZ2 (UI) | CA nivel 1 negativa → CA nivel 2 abierta por SISANS (**sin finalizar**) |

Solicitudes de referencia sólo leídas por LCP (sin modificar): ninguna además de las anteriores; la interfaz padre se probó con `POST /interfaces/{uuid}/test` sobre 15788160 (R23-C) únicamente para comprobar que evaluaba sin error.

## 3. Punto 1 — orden de los argumentos

### 3.1 Análisis (SAIL)
- SCA2: `SCA2_ContraAnulacionOpciones` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435`) carga `local!respArgumentario = rule!SCA2_consultarListadoArgumentos(body)` → `local!listaArgumentos`; estado/usuario/fecha son `index(local!listaArgumentos, "mcaEstado"|"usuario"|"fecEjecutado")` y la selección del grid devuelve el índice de la lista. El grid lo pinta `SCA2_ContraAnulacionArgumentarioEstrategicas` (`…_20060043`, copia de `SCA_ArgumentosContraAnulacionEstrategicas`) con `initialSorts/secondarySorts: a!sortInfo(field: "orden")` y «Orden» = `fv!identifier`.
- SCA: `SCA_ContraAnulacionOpcionesEstrategicas` (v10) + `SCA_ArgumentosContraAnulacionEstrategicas` (v6): mismo patrón, mismo `sortInfo("orden")`. **SCA ordena igual que SCA2 antes del cambio**: el servicio devuelve en nivel 2 los argumentos ejecutados en nivel 1 (con `nivelArgumento = 1`, `mcaEstado ≠ 0`, usuario y fecha) y los nuevos (`nivelArgumento = 2`, `mcaEstado = 0`) cada uno con su `orden`, y ambas apps los pintan por `orden` → intercalados (captura del analista: Orden 1,6,7,2,3,4,5,8,9,10).
- Criterio «argumento de una CA anterior»: `tointeger(nivelArgumento) < local!nivelIntervencion`, el mismo que ya usaba la propia interfaz para deshabilitar POSITIVO/NEGATIVO sobre esos argumentos (literal SCA).

### 3.2 Cambio aplicado (sólo SCA2, objetos de mi columna)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 57 → **58** | `local!listaArgumentos` se construye reordenada: índices con `nivelArgumento < nivelIntervencion` ordenados alfabéticamente por `descTipoArgumento` (`todatasubset` sobre `a!map(idx, desc)`), seguidos del resto en el orden del servicio (`difference(enumerate(n)+1, anteriores)`); nuevo `local!numArgAnteriores` que se pasa al hijo. Todos los índices derivados (estado/usuario/fecha/tréboles/selección/`obligEjecu`/`mayorOrdenObligNoEjecutados`) se calculan sobre esta lista, por lo que la lógica de negocio no cambia. **No** se ha tocado la corrección pendiente #6 (catalogación renovada) de R23-B §10. |
| `SCA2_ContraAnulacionArgumentarioEstrategicas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060043` | 2 → **4** (v3 intermedia: `insert()` no insertaba la fila, sustituido por concatenación) | Nuevo input `numArgAnteriores` (Integer). Las filas del grid son `a!map(idx, arg, separador)`; si `0 < numArgAnteriores < n` se intercala una fila `separador: true` («↑ Argumentos ejecutados en contra anulaciones anteriores | ↓ Argumentos disponibles para la nueva contra anulación») no seleccionable (`disableRowSelectionWhen: fv!row.separador`). Se eliminan `initialSorts/secondarySorts` (el grid respeta el orden de la lista). «Orden» = `fv!row.idx` (índice real, continuo 1..n; la fila separadora sin número). Selección → `ri!indiceArgumentoSeleccionado = fv!row.idx`, así el padre sigue indexando `local!listaArgumentos` igual que antes. Resto de columnas (Argumentario, Aplicación, Estado, Usuario, Fecha) idénticas usando `fv!row.arg` / `fv!row.idx`. |

Fragmento (padre, v58):
```
local!idxArgAnteriores: if(a!isNullOrEmpty(local!argumentario), {},
  where(a!forEach(items: local!argumentario,
    expression: a!defaultValue(tointeger(index(fv!item, "nivelArgumento", null)), local!nivelIntervencion) < local!nivelIntervencion))),
local!idxArgAnterioresAlfa: … todatasubset(a!forEach(items: local!idxArgAnteriores, expression: a!map(idx: fv!item, desc: upper(descTipoArgumento))), a!pagingInfo(1, -1, a!sortInfo("desc", true))) …,
local!idxArgNuevos: … difference(enumerate(count(local!argumentario)) + 1, local!idxArgAnteriores),
local!numArgAnteriores: count(local!idxArgAnteriores),
local!listaArgumentos: index(local!argumentario, append(local!idxArgAnterioresAlfa, local!idxArgNuevos), {}),
```
Fragmento (hijo, v4):
```
local!filasGrid: if(and(local!numAnt > 0, local!numAnt < length(local!filas)),
  { index(local!filas, enumerate(local!numAnt) + 1, {}), a!map(idx: 0, arg: null, separador: true),
    index(local!filas, enumerate(length(local!filas) - local!numAnt) + local!numAnt + 1, {}) },
  local!filas),
…  data: local!filasGrid, … disableRowSelectionWhen: fv!row.separador, …
```
Procedimiento: GET vivo (v57 / v2, idénticos a los volcados) → backup JSON local → PUT completo (con `inputs`) → re-GET (v58 / v4, expresión idéntica a la enviada) → `POST /interfaces/{uuid}/test` del hijo con 4 argumentos de prueba: `numArgAnteriores=2` → Orden `[1,2,null,3,4]` con la fila separadora; `0` y `4` → sin separador; `POST …/test` del padre con 15788160 → evalúa sin error.

### 3.3 Prueba UI (testing_agent, grabación)
Solicitud 15788293 (grabación `sca-comparativa-edited.mp4`). Servicio de argumentos para esta póliza: 7 argumentos (INCREMENTO PRIMA, GESTION COMPETENCIA, SUPLEMENTO EN GENERAL, CAMBIO DE FORMA DE PAGO, CLUB MAPFRE ORO, SERVICIOS MAPFRE, REDUCCION DE COBERTURAS).

| Paso | SCA2 (antes del cambio = SCA) | SCA2 (después, v58/v4) | Veredicto |
|---|---|---|---|
| CA nivel 1 (JJGONZ2): tabla inicial | 7 argumentos, Orden 1..7, Pendiente, sin separador | Igual: Orden 1..7 en el orden del servicio, **sin separador** | OK |
| Ejecutar 3 argumentos NEGATIVO (INCREMENTO PRIMA 21:19:40, CAMBIO DE FORMA DE PAGO 21:20:02, SUPLEMENTO EN GENERAL 21:20:27) | Estado Negativo / JJGONZ2 / fecha | Igual | OK |
| FINALIZAR CA negativa → plantilla de carta (obligatoria) → Sí → «CORRECTO / Procesando la decisión…» → ACEPTAR | — | Igual que en rondas anteriores; no aparecieron contacto/acuerdo ni Verti (póliza sin derivación Verti) | OK |
| Detalle: segunda tarjeta Contra Anulación (nivel 2, Incompleta) | — | Aparece tras ~55-70 s (ver §4) | OK (lento) |
| CA nivel 2 (SISANS, RETOMAR): orden | Mezclados por `orden` del servicio (Negativo intercalado con Pendiente) | **1 CAMBIO DE FORMA DE PAGO · 2 INCREMENTO PRIMA · 3 SUPLEMENTO EN GENERAL** (Negativo/JJGONZ2/fecha, alfabético) → **fila separadora** «↑ Argumentos ejecutados en contra anulaciones anteriores \| ↓ Argumentos disponibles para la nueva contra anulación» → **4 INCREMENTO PRIMA · 5 SERVICIOS MAPFRE · 6 SUPLEMENTO EN GENERAL · 7 GESTION COMPETENCIA · 8 CLUB MAPFRE ORO · 9 CAMBIO DE FORMA DE PAGO · 10 REDUCCION DE COBERTURAS** (Pendiente, orden del servicio, no alfabético) | **Corregido** |
| Fila separadora | — | Sin número, no seleccionable (checkbox deshabilitado) | OK |
| Seleccionar argumento anterior | Botones POSITIVO/NEGATIVO deshabilitados, tooltip «El argumento no puede volver a ejecutarse» | Igual | OK |
| Seleccionar argumento nuevo (obligatorio) | Botones habilitados; selección única | Igual | OK |
| Ejecutar NEGATIVO «INCREMENTO PRIMA» (nuevo) como SISANS | — | La fila se queda en Orden 4 del bloque inferior con Negativo / SISANS / 2026-10-22 21:25:28; el orden no cambia | OK |
| Paginación | 10 por página | «1 – 10 de 11»: la fila separadora cuenta como fila (página 1 = 9 argumentos + separador; página 2 = Orden 10) | OK (ver nota) |
| Salir sin finalizar (VOLVER AL DETALLE) | — | CA nivel 2 sigue Incompleta | OK |

Nota: con 10 argumentos + separador la página 1 muestra 9 argumentos y el 10º pasa a la página 2; el texto del separador se parte en dos líneas en anchos < 1600 px. Ambos son cosméticos; si el analista prefiere que el separador no cuente en la paginación habría que subir `pageSize` a 11 cuando hay separador (cambio trivial, no aplicado sin OK).

Comparación con SCA (póliza 0005726681370):
solicitud **15788294** (SCA, `sca-site`), misma secuencia (7 argumentos; NEGATIVO sobre INCREMENTO PRIMA 21:31:47, CAMBIO DE FORMA DE PAGO 21:32:01, SUPLEMENTO EN GENERAL 21:32:15; FINALIZAR → «Su gestión ha finalizado, la solicitud se ha enviado al Grupo de Expertos en Retención de SI24…»). SISANS retoma el nivel 2 desde el site `decidir-accion` y la tabla sale **mezclada y sin separador**, con la columna Orden 1, 4, 5, 2, 3, 6, 7, 8, 9, 10 (filas 1-3 Negativo/JJGONZ2 intercaladas con Pendiente): es exactamente lo que el analista señala en su captura y lo que hacía SCA2 antes del cambio. La CA de nivel 2 de SCA se pospuso (NO a contacto → ACEPTAR) y queda Incompleta. Capturas `sca-nivel2-argumentos.png` vs `sca2-nivel2-argumentos.png`.

Casos pedidos: nivel 1 sin CA anterior → **sin separador** (comprobado en 15788293 nivel 1). Tercera CA (nivel 3): no se pudo crear en esta ronda (requeriría finalizar la CA nivel 2 negativa y que el motor devolviera otro nivel); por diseño `nivelArgumento < nivelIntervencion` agrupa todos los anteriores (niveles 1 y 2) juntos y alfabéticos, y los ejecutados dentro del nivel actual (p. ej. tras posponer/retomar) permanecen en el bloque inferior con su Estado/Usuario/Fecha (comprobado con el argumento ejecutado por SISANS en nivel 2).

## 4. Punto 2 — lentitud de «Procesando la decisión de la solicitud…»

### 4.1 Dónde está el mensaje
`SCA2_DetalleTareas` (no es de mi columna): tras completar la tarea (`local!hecho`) muestra el mensaje mientras `local!accionEnCurso` y sondea con `a!refreshVariable(... refreshInterval: 0.5)` (= 30 s, el mínimo de Appian) `SCA2 Solicitud` (estado/procesoActivo), `SCA2 Tarea` (otra tarea PENDIENTE / MECANIZAR / estado de la tarea recién gestionada) y `SCA2 Transicion`; `local!esperaAgotada` corta a 1 min 30 s con el aviso «No se ha podido abrir la pantalla…». Los PM `SCA2 CMD CrearAccion` (40 nodos) y `SCA2 CMD CompletarAccion` (39 nodos) **no tienen timers ni esperas**; encadenan el siguiente comando con *Start Process*.

### 4.2 Tiempos medidos (SCA2 15788293, LCP `GET /processes/{id}` + `SCA2 Transicion`/`SCA2 Tarea`, hora UTC)

| Paso | Proceso | Inicio | Fin | Duración |
|---|---|---|---|---|
| Tarea CONTRAANULAR nivel 1 cerrada (FINALIZAR) | tarea 469 | — | 19:22:07 | — |
| `SCA2 CMD CompletarAccion` (Finalizar CA PCA en CORE, impresión carta, Write) | 10160808 | 19:22:06.4 | 19:22:18.4 | 12 s |
| `SCA2 CMD Decidir` (motor de decisión → NO_MECANIZAR) | 12253801 | 19:22:18.0 | 19:22:29.9 | 12 s |
| `SCA2 CMD CrearAccion` (cambio de nivel → NIVEL) | 16449812 | 19:22:25.3 | 19:22:28.9 | 4 s |
| `SCA2 CMD Decidir` (motor → CONTRA ANULAR NIVEL 2, grupo CE_MF_BK_EXPERTOSI24) | 269120805 | 19:22:28.8 | 19:22:47.8 | 19 s |
| `SCA2 CMD CrearAccion` (alta gestión CORE nivel 2 + tarea) | 537556981 | 19:22:42.3 | 19:22:47.0 | 5 s |
| Tarea CONTRA ANULAR NIVEL 2 creada | tarea 470 | 19:22:45 | — | **38 s desde FINALIZAR** |

CORE (`SCA2_consultaGestion(15788293)`, hora local): 43706574 Alta FINALIZADA · 43706576 CA nivel 1 FINALIZADA NEGATIVA 21:17:37→21:22:12 (`JJGONZ2 · RED MAPFRE / OFICINA`) · 43706577 Impresión FINALIZADA 21:22:14 · 43706578 CA nivel 2 INCOMPLETA 21:22:44 (`JJGONZ2 · GGE / GGE EXPERTOS SI24`). Es decir, CORE ve la CA nivel 2 32 s después de cerrar la CA 1: el tiempo se va en los **dos ciclos del motor de decisión** (12 s + 19 s, incluida la espera de que el subproceso anterior termine) y en las llamadas CORE, no en una espera artificial.

UI (cronómetro del testing_agent): capturas con hora UTC de la grabación: confirmación FINALIZAR/«Procesando» 19:22:13 → «CORRECTO / Los datos se han guardado correctamente / Procesando la decisión de la solicitud…» visible 19:22:26 y 19:22:36 → tarjeta nivel 2 capturada 19:23:21 (≈ **55-69 s**; la captura de la tarjeta no es el primer instante en que apareció, así que el valor real está entre 38 s (backend) y 69 s).

SCA (misma prueba, póliza 0005726681370): CORE (`consultaGestion(15788294)`, hora local): CA nivel 1 FINALIZADA NEGATIVA 21:33:28 (impresión 21:32:30) → CA nivel 2 INCOMPLETA **21:33:48 (20 s)**. UI: confirmación 19:33:20 → «procesando» 19:33:30 → mensaje «enviado a SI24» 19:33:40 → tarjeta nivel 2 capturada 19:34:04 (≈ **25-44 s**). SCA decide en un único proceso (un solo ciclo del motor); SCA2 tarda ~12-18 s más en backend por la cadena de 5 procesos atómicos (dos evaluaciones del motor) y además depende del sondeo de 30 s para refrescar el Detalle.

### 4.3 Conclusión y propuesta (no aplicada)
- El mensaje dura ≈ tiempo real del backend (38 s) + hasta 30 s del sondeo. No hay un sondeo «lento» corregible: 0,5 min es el mínimo de `refreshInterval`. Para reducir la percepción habría que (a) añadir en `SCA2_DetalleTareas` un botón «ACTUALIZAR» junto al mensaje que fuerce el refresco (`refreshOnVarChange` sobre un contador, como ya hace el panel Verti del propio objeto), y/o (b) bajar el tiempo del backend: la cadena hace **dos** evaluaciones del motor de decisión (NO_MECANIZAR → NIVEL → nueva decisión); unificar en una llamada toca la lógica de decisión (`SCA2 CMD Decidir`/`CrearAccion`), que no debo cambiar. Ambas opciones requieren decisión del analista/OT y (a) un objeto de otra columna.

## 5. Divergencias y preguntas al analista
1. Orden de argumentos: aplicado tal y como se pide (anteriores alfabético + separador + nuevos en orden del servicio). **Confirmar** el texto/estilo de la fila separadora y que la columna «Orden» siga numerando 1..n en el nuevo orden (antes mostraba el índice de la lista del servicio).
2. Lentitud: ¿se acepta la espera de 38 s + sondeo (igual lógica de decisión que SCA) o se quiere el botón «ACTUALIZAR» en `SCA2_DetalleTareas` (otra columna) y/o revisar la doble llamada al motor?
3. 15 de las 16 pólizas asignadas ya tenían solicitud; conviene renovar la hoja de pólizas para la próxima ronda.

## 6. Limitaciones
- No se ha probado una tercera CA (nivel 3). No se ha finalizado ninguna CA de nivel 2 (quedan Incompletas en 15788293 y 15788294).
- La póliza 0005726681296 ya tenía solicitud (15788291) de otra sesión al ir a usarla; el buscador de SCA abrió su detalle automáticamente al buscar por póliza y se cerró sin modificar nada.
- La prueba LCP del padre con 15788160 devolvió la tabla vacía (solicitud ya mecanizada, sin tarea de CA activa): sólo sirvió para validar que la expresión evalúa.

## 7. Grabaciones y capturas (no en el repo)
- Vídeo: `sca-comparativa-edited.mp4` (JJGONZ2 + SISANS, SCA2 15788293 y SCA 15788294).
- Capturas SCA2: `sca2-poliza1936-sin-solicitudes.png`, `sca2-alta-valores.png`, `sca2-id15788293.png`, `sca2-nivel1-argumentos.png`, `sca2-nivel1-tres-negativos.png`, `sca2-finalizar-confirmacion-procesando.png`, `sca2-guardado-procesando.png`, `sca2-tarjeta-nivel2.png`, `sca2-nivel2-argumentos.png`, `sca2-nivel2-historico-bloqueado.png`, `sca2-nivel2-nuevo-habilitado.png`, `sca2-nivel2-negativo-sisans.png`, `sca2-nivel2-pagina2.png`, `sca2-nivel2-incompleta-final.png`.
- Capturas SCA: `sca-poliza1296-ocupada.png`, `sca-error-volver-poliza-ocupada.png`, `sca-poliza1370-sin-solicitudes.png`, `sca-alta-valores.png`, `sca-nivel1-argumentos.png`, `sca-nivel1-tres-negativos.png`, `sca-finalizar-confirmacion.png`, `sca-finalizar-procesando.png`, `sca-finalizar-mensaje-si24.png`, `sca-tarjeta-nivel2.png`, `sca-nivel2-argumentos.png`, `sca-id15788294-pospuesta.png`, `sca-nivel2-incompleta-final.png`.
- Hallazgo colateral en **SCA** (no corregible por mí): al volver desde el detalle abierto automáticamente por el buscador de `sca-site` (póliza con solicitud existente) salta «Error de evaluación de expresión … in rule 'sca_datoscabecera' (called by 'sca_detallesolicitud' > 'sca_buscarsolicitudclientepoliza' > 'sca_buscadorsolicitudprincipal') at function a!submitLink [line 23]: The save target must be a local variable that does not refresh…». Es un fallo de SCA, documentado para la OT.
