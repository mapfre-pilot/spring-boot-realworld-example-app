# R27-A — Cabecera (pestaña por defecto), mensaje SI24 definitivo y botón REASIGNAR en nivel 2

**Ronda 27 · sesión R27-A · 2026-10-22 · entorno TEST (`mapfrespain-test`)**
Puntos del analista (doc 48, «Análisis SCA2» 22/10): #2 pestaña por defecto «Datos póliza», #7 texto SI24 aceptado, #8 botón REASIGNAR en la Contra Anulación de nivel 2.
Referencia funcional: SCA TEST. Sólo se ha modificado SCA2 (objetos de la columna R27-A de `coordinacion-ronda27.md`). No se ha tocado SCA, SCAC, CORE, GAIA ni PRE.

## 1. Resumen / veredicto

**APROBADO con 1 decisión pendiente del analista.** Los tres puntos de la columna R27-A están aplicados en SCA2 TEST y verificados en UI con una solicitud nueva (15788291, póliza 0005726681296) como JJGONZ2 (Oficina) y SISANS (SI24), comparando con SCA en la misma solicitud:

- Pestaña por defecto **«Datos póliza»** en alta, Contra Anulación nivel 1 y 2 y Detalle de SCA2 (4 interfaces, §3). SCA sigue abriendo en «Datos cliente» (comportamiento histórico, no se toca).
- Aviso definitivo **«Esta solicitud la está gestionando SI24»** en el Detalle para Oficina cuando la solicitud está en nivel 2 (§4). SCA no tiene aviso equivalente.
- **RETOMAR y REASIGNAR** en la misma fila, alineados a la derecha, con estilo de botón (§5.4); RETOMAR sigue funcionando (abre la CA nivel 2 y registra SISANS/SI24 EXPERTOS en CORE). **REASIGNAR no se ha quitado**: explicación y recomendación en §5.3, decisión pendiente (§10).
- Anomalías observadas fuera del alcance R27-A (no corregidas, §8/§9): tras ACEPTAR el alta SCA2 vuelve al formulario sin mostrar el id; toast «El argumento no puede volver a ejecutarse» al rehacer el argumento negativo en la CA nivel 1 (`SCA2_ContraAnulacionOpciones`, columna R27-B).

## 2. Pólizas y solicitudes de prueba

Pólizas asignadas (hoja «Wautemis que derivan», recorridas desde el final). Comprobación previa con `SCA2_consultarSolicitudes(numPoliza, codInt: null, tpBusqueda: 0)`:

| Póliza | Resultado comprobación | Uso |
|---|---|---|
| 0005726681296 | sin solicitud | **usada** → solicitud 15788291 |
| 0005726681221 | sin solicitud | no usada (reserva) |
| 0005726682856 | sin solicitud | reserva |
| 0005726681370 | sin solicitud | reserva |
| 0005726681408 | sin solicitud | reserva |
| 0005726682038 | ya tenía solicitud 15788254 (estado 4) | descartada |
| 0005726684215 | ya tenía solicitud 15787916 (estado 2) | descartada |
| 0005726684349 | ya tenía solicitud 15787913 (estado 2) | descartada |

Solicitudes creadas en esta sesión: **15788291** (póliza 0005726681296, alta 22/10/2026 21:10 por JJGONZ2 en SCA2; CA nivel 1 Finalizada Negativa; CA nivel 2 Incompleta tomada por SISANS). Queda abierta en nivel 2 (no se finalizó a propósito).

## 3. Punto 1 — pestaña por defecto de la cabecera

### 3.1 Análisis (volcado SAIL por LCP de las 83 interfaces SCA2 y 101 de SCA)

- `SCA2_DatosCabecera` (uuid `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053077`, v2) **no tiene pestañas propias**: pinta el título/estado y delega el bloque ampliable en `rule!SCA2_MilestoneMasDatosAltaSolicitud(...)`. Igual su variante `SCA2_DatosCabecera_Estrategicas`.
- Las pestañas (Datos cliente / Datos póliza / Solicitud Anulación / Otras sol. Anulación / Datos contacto) viven en `SCA2_MilestoneMasDatosAltaSolicitud` y `SCA2_MilestoneMasDatosAltaSolicitud_Estrategicas`, con `local!seleccionado: 1` (= Datos cliente) y `choose(local!seleccionado, rule!SCA2_DatosCliente(...), rule!SCA2_DatosPoliza(...), ...)`.
- Llamadores de la cabecera común (`rg "rule!SCA2_DatosCabecera"`): `SCA2_ContraAnulacionPrincipal`, `SCA2_AccionesAdministrativasPrincipal`, `SCA2_AnulacionFueraNormaPrincipal` (Autorización), `SCA2_VertiVencimientoPrincipal`. **Ninguno fuerza otra pestaña** (la cabecera no recibe ningún parámetro de pestaña).
- Dos pantallas tienen una copia propia de las pestañas: `SCA2_DetalleSolicitud` (`local!tab: 1`, 6 pestañas incl. Notificaciones; también cubre la Impresión del detalle, `local!esImpr`) y `SCA2_AltaSolicitudPage` (`local!tab: 1`, 4 pestañas). `SCA2_MecanizacionPrincipal` no usa la cabecera con pestañas.
- **SCA**: `SCA_MilestoneMasDatosAltaSolicitud` / `_Estrategicas` también inicializan `local!seleccionado: 1` → **SCA abre en «Datos cliente»** en todas sus pantallas. La petición del analista es por tanto una mejora deliberada de SCA2 sobre SCA (no una divergencia). No se cambia SCA.

### 3.2 Cambio aplicado (GET vivo → backup → PUT completo → re-GET)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_MilestoneMasDatosAltaSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053322` | 4 → 5 | `local!seleccionado: 1` → `2` |
| `SCA2_MilestoneMasDatosAltaSolicitud_Estrategicas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053071` | 4 → 5 | `local!seleccionado: 1` → `2` |
| `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | 38 → 39 | `local!tab: 1` → `2` |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 63 → 64 | `local!tab: 1` → `2` (+ cambios de §4 y §5) |

`SCA2_AltaSolicitudPage` no estaba en ninguna columna del reparto; se ha tocado sólo la línea `local!tab` (avisado en `coordinacion-ronda27.md`). Test LCP (`POST /interfaces/…_20053322/test`, póliza 0005726681296): renderiza `ContentLayout` sin error (8,5 s).

## 4. Punto 2 — mensaje SI24 definitivo

Búsqueda del literal en las 83 interfaces, 251 reglas y 147 constantes de SCA2 (`rg "gestionando SI24|texto provisional"`):

| Objeto | Línea | Texto | Acción |
|---|---|---|---|
| `SCA2_DetalleSolicitud` | aviso de la tarjeta de gestión (showWhen: tarea de grupo SI24 / subperfil SI24, usuario no SI24 y no admin) | «Esta solicitud la está gestionando SI24 (texto provisional, pendiente del analista)» | **Cambiado** a «Esta solicitud la está gestionando SI24» (v63→64). También el comentario SAIL. |
| `SCA2_ContraAnulacionOpciones` | comentario `/* R9-C B7-acuerdos … (texto provisional, pendiente del analista) */` | aviso **distinto** (póliza de acuerdo en nivel 1, no es el mensaje SI24) | No tocado: es un comentario (no se muestra) y el objeto es de la columna R27-B. |
| `SCA2_AnulacionFueraNormaPrincipal` | mensaje de error al cancelar una autorización en CORE: `… & " (texto provisional, pendiente del analista)"` | mensaje **distinto** (error técnico de CORE, no SI24) | No tocado: texto pendiente de otro punto del analista (ver preguntas). |

No existe ninguna constante ni regla con el literal; el mensaje sólo aparece en `SCA2_DetalleSolicitud`. `SCA2_DetalleTareas` no contiene el aviso ni botones RETOMAR/REASIGNAR (sólo la tabla de tareas y el panel de inducción Verti, fuera de alcance).

## 5. Punto 3 — botón REASIGNAR en la Contra Anulación de nivel 2

### 5.1 De dónde viene y qué hace en SCA2

- Lo pinta `SCA2_DetalleSolicitud`, en la zona «BOTONES DE REASIGNAR Y RETOMAR» de cada tarjeta de gestión (la misma zona para Contra Anulación, Acciones Administrativas, Mecanización y Autorización). Hasta hoy: un `a!columnsLayout` de 9 columnas con, en la última, una tarjeta roja «RETOMAR» (`a!cardLayout` + `a!dynamicLink`) y **debajo** un `a!buttonLayout` con «REASIGNAR» → los dos apilados en una columna estrecha (el «descolocado» que ve el analista).
- Visibilidad (R22 #1, doc 40 §8.1): ambos botones para cualquier usuario que pueda gestionar la tarea por grupo/nivel (`SCA2_puedeGestionarTarea`), aunque la tarea esté asignada a otro. En nivel 2 sólo lo cumplen los usuarios SI24/GGE.
- **REASIGNAR** llama a `rule!SCA2_reasignarTarea(idTarea)` (uuid `_a-0000f06b-141a-8000-9d23-011c48011c48_5454999`, v1): `a!writeRecords` sobre `SCA2 Tarea` con `asignadoA = propietario = loggedInUser()` y `fechaCaptura = now()`, y muestra el pop-up `SCA2_PopUpReasignarTarea` («La tarea se ha reasignado correctamente»). **No llama a CORE** (CORE no tiene concepto de asignatario; sólo registra la gestión y su `infoUsuario` al finalizar). Es decir: REASIGNAR = «asignarme a mí esta tarea» sin abrir la pantalla; RETOMAR = asignármela **y** abrir la pantalla de gestión (y en CA, marcar la gestión CORE como retomada vía `finalizarContraAnulPca` mcaEstadoFinal 2).
- Es una copia del patrón de SCA (`SCA_PopUpReasignarTarea`, `SCA_PM_REASIGNAR_TAREA`), adaptada a procesos atómicos.

### 5.2 Qué hace SCA en la misma situación

`SCA_DetalleAnulacionContraAnulacion` (y `…AccionesAdministrativas`, `…Mecanizacion`, `…Autorizacion`, `…AltaSolicitud`, con sus variantes `*Estrategicas`), última columna de la fila de botones:

```
if(touser(local!taskOwner) = loggedInUser(),
   cardLayout «RETOMAR» (a!processTaskLink a la tarea Appian),
   buttonLayout «REASIGNAR» (a!startProcess cons!SCA_PM_REASIGNAR_TAREA))
```

- **Son excluyentes**: el propietario de la tarea ve RETOMAR; cualquier otro usuario con acceso ve REASIGNAR (= «quítasela al propietario y dámela a mí»). La columna entera se oculta si `nivelIntervencion = "2"` y el subperfil logado es `CE_MF_SI24` (SI24 retoma desde su bandeja `decidir-accion`, no desde el Detalle), y si la gestión está cerrada.
- PM `SCA Reasignar Tarea` (`0002ec14-0a43-8000-6b64-7f0000014e7a`): Get Task → `Reassign Task` (newAssignees = `pv!nuevoUser`, PRIVILEGE_REASSIGN_TO_ANY) → borra y reescribe `SCA TareasPorPolizaAWS` con `propietario/asignadoA = pv!nuevoUser`. Las interfaces **no estratégicas** arrancan el PM **sin `nuevoUser`** (sólo `taskId`, `idSolicitud`), así que la tarea queda reasignada a «nadie»; las `*Estrategicas` pasan `nuevoUser: loggedInUser()`. Esto explica la frase del analista «en el SCA actual no se conservan esos botones»: en SCA, para un usuario SI24 en nivel 2 la columna está oculta, y en el resto de casos sólo se ve uno de los dos.

### 5.3 Explicación funcional para el analista y recomendación

- **Motivo del botón**: en SCA una gestión abierta pertenece a un usuario (tarea Appian asignada). Si otro compañero del mismo grupo tiene que continuarla, primero debe «reasignársela» (REASIGNAR) y después «retomarla» (RETOMAR). En SCA2 las tareas también se asignan (`SCA2 Tarea.asignadoA`) pero, al no haber tareas Appian, **RETOMAR ya asigna la tarea a quien la retoma** (decisión del analista en ronda 24, doc 43: «cualquier usuario del grupo puede retomar»). Por tanto REASIGNAR en SCA2 sólo sirve para «hacerse cargo» de una tarea sin abrirla (p. ej. para que aparezca en «Mis tareas» de un compañero) y hoy no aporta nada que RETOMAR no haga.
- **Recomendación**: **quitar REASIGNAR del Detalle en nivel 2** (y, por coherencia, en todas las tarjetas), ya que (a) SCA no lo muestra a SI24 en nivel 2, (b) RETOMAR ya reasigna y (c) sólo reasigna a uno mismo (no permite elegir destinatario, que sería el único caso útil para un administrador). Alternativa si se quiere conservar la función «asignar a otro»: dejarlo sólo para administradores con selector de usuario. **No se ha quitado**: pendiente de decisión del analista.

### 5.4 Cambio aplicado (colocación)

`SCA2_DetalleSolicitud` v63→64: el bloque de 9 columnas se sustituye por un `a!buttonArrayLayout(align: "END")` con dos `a!buttonWidget` en la misma fila, alineados a la derecha, con el mismo estilo que el resto de botones de las tarjetas del Detalle (`ACEPTAR` sólido rojo / `VOLVER` contorno de la tarjeta de Mecanización):

```
a!buttonArrayLayout(
  showWhen: <mismo showWhen que antes>,
  buttons: {
    a!buttonWidget(label: "RETOMAR", style: "SOLID", color: cons!SCA2_VAL_COLOR_ROJO, saveInto: {<mismo saveInto: writeRecords SCA2 Tarea asignadoA/fechaCaptura, finalizarContraAnulPca si CA, apertura de la gestión>}),
    a!buttonWidget(label: "REASIGNAR", style: "OUTLINE", color: "SECONDARY", saveInto: {rule!SCA2_reasignarTarea(...), a!save(local!showPopupReasignar, true)})},
  align: "END")
```

`showWhen` y `saveInto` se conservan íntegros (sin cambio funcional). Nota técnica: `a!buttonLayout(align:)` no existe en esta versión de Appian (LCP devolvió `400 Unrecognized Keyword align`), por eso se usa `a!buttonArrayLayout`. Backups antes/después en local (`~/sca2work/r27a/live/`), no en el repo.

## 6. Pruebas UI (testing_agent) — SCA vs SCA2 paso a paso

Grabación: `sca2-sca-r27a-edited.mp4`. Usuarios en contextos de navegador separados. Comparación SCA hecha **después** del RETOMAR de SISANS en SCA2 (misma solicitud).

| # | Paso | SCA2 (tras los cambios) | SCA (referencia) | Veredicto |
|---|---|---|---|---|
| 1 | Alta: buscar póliza 0005726681296 como JJGONZ2 | Cabecera abre en **Datos póliza**. Alta con causa «ME HA SUBIDO MUCHO LA PRIMA», presencial, a vencimiento 30/01/2028 | Buscador de SCA abre directamente el Detalle en **Datos cliente** | OK (mejora deliberada SCA2) |
| 2 | ACEPTAR alta | Tras ~35 s vuelve al formulario de alta **sin id ni mensaje**; la solicitud 15788291 sí se creó (buscador / CORE) | n/a (alta no repetida en SCA para no duplicar) | Anomalía UI fuera de R27-A → documentada §9 |
| 3 | Contra Anulación nivel 1 (JJGONZ2) | Abre en **Datos póliza**. Argumento INCREMENTO PRIMA PLATINO negativo, observación, carta generada/previsualizada → **Finalizada Negativa**. Toast «El argumento no puede volver a ejecutarse» al reinteractuar con el argumento | n/a | OK pestaña; toast documentado §9 |
| 4 | Derivación | Se crea CA **nivel 2 Incompleta** (grupo GGE EXPERTOS SI24, sin usuario). No apareció pantalla Verti/Vencimiento | Mismo estado visible en SCA (mismo CORE) | OK |
| 5 | Detalle SCA2 como JJGONZ2 | **Datos póliza**; tarjeta CA nivel 2 con el aviso exacto **«Esta solicitud la está gestionando SI24»** y sin botones de gestión | **Datos cliente**; CA nivel 2 sin aviso y sin RETOMAR/REASIGNAR | OK (aviso es mejora SCA2 aceptada por el analista) |
| 6 | Detalle SCA2 como SISANS | **Datos póliza**; tarjeta CA nivel 2 con **RETOMAR** (rojo sólido) y **REASIGNAR** (contorno gris) en la **misma fila, a la derecha** | **Datos cliente**; CA nivel 2 **sin RETOMAR ni REASIGNAR** (SI24 retoma desde su bandeja) | Colocación OK; presencia de REASIGNAR → decisión §10 |
| 7 | RETOMAR (SISANS) | Abre CA nivel 2 en **Datos póliza**; VOLVER AL DETALLE sin guardar → CA sigue **Incompleta**, ahora grupo SI24 EXPERTOS / perfil SI24 / nuuma SISANS (CORE registra el retomar, como en SCA) | n/a | OK |
| 8 | REASIGNAR / finalizar nivel 2 | No pulsados (por instrucción) | — | — |

## 7. Estados CORE / SCA2 observados

`SCA2_consultaGestion(codSolicitud: 15788291)` (LCP), tras el flujo completo; `SCA2_consultarSolicitudes(0005726681296)` → `codEstSolic = 2` en todo momento.

| numGestion | accionRealizada | codEstGestion | nivel | inicio → fin | infoUsuario | Tras qué acción |
|---|---|---|---|---|---|---|
| 43706568 | 8 (alta) | FINALIZADA | 1 | 21:10:32 → 21:10:32 | JJGONZ2 / RED MAPFRE / OFICINA | Alta SCA2 (obs. «Prueba UI R27-A…») |
| 43706569 | 2 (CA) | INCOMPLETA → **FINALIZADA NEGATIVA** | 1 | 21:10:55 → 21:16:53 | JJGONZ2 / OFICINA | CA nivel 1 negativa |
| 43706573 | 4 (carta) | FINALIZADA | 1 | 21:16:55 → 21:16:55 | JJGONZ2 / OFICINA | Carta de la CA nivel 1 |
| 43706575 | 2 (CA) | INCOMPLETA | **2** | 21:17:29 → — | **SISANS / SI24 EXPERTOS** (antes del RETOMAR: sin usuario, grupo GGE EXPERTOS SI24) | Derivación a nivel 2 + RETOMAR de SISANS |

Sin registros nuevos en la bandeja de errores SCA2 atribuibles a esta solicitud (no se revisaron errores ajenos).

## 8. Divergencias

| # | Divergencia | Exclusiva SCA2 | Estado |
|---|---|---|---|
| 1 | Pestaña por defecto «Datos cliente» (igual en SCA) | No (petición de mejora del analista) | Corregida en SCA2 (→ «Datos póliza») en las 4 interfaces |
| 2 | Texto provisional del aviso SI24 | Sí | Corregida (texto definitivo) |
| 3 | RETOMAR y REASIGNAR apilados/descolocados | Sí | Corregida (misma fila, derecha, estilo botón) |
| 4 | SCA2 muestra REASIGNAR a SI24 en nivel 2; SCA no muestra ni RETOMAR ni REASIGNAR a SI24 en el Detalle de nivel 2 | Sí | **No corregida**: decisión funcional del analista (§5.3). RETOMAR se mantiene por decisión previa (doc 43). |
| 5 | Alta SCA2: tras ACEPTAR vuelve al formulario sin id/mensaje (la solicitud sí se crea) | Sí (SCA muestra el detalle) | **No corregida**: fuera de R27-A (`SCA2_AltaSolicitudPage`/PM de alta, R27-C orquestación); sólo se tocó `local!tab`. Propuesta: tras el alta navegar al Detalle o mostrar el id. |
| 6 | Toast «El argumento no puede volver a ejecutarse» al rehacer el argumento negativo en CA nivel 1 | Pendiente de comprobar en SCA | **No corregida**: `SCA2_ContraAnulacionOpciones` es de R27-B; se traslada a esa sesión/analista. |

## 9. Limitaciones y pendientes

- No apareció la pantalla Verti/Vencimiento con esta póliza (la derivación fue directa a nivel 2), así que la pestaña por defecto de `SCA2_VertiVencimientoPrincipal` sólo está verificada por código (usa la cabecera común corregida), no en UI. Lo mismo para Acciones Administrativas, Autorización y las variantes `_Estrategicas`.
- La comparación con SCA se hizo sobre la misma solicitud **después** del RETOMAR de SISANS; en SCA el Detalle no muestra RETOMAR/REASIGNAR a SI24 en nivel 2 en ningún caso (código §5.2), por lo que el orden no altera la conclusión.
- `SCA2_AltaSolicitudPage` no estaba en el reparto de la ronda: se ha modificado sólo `local!tab` (línea de aviso en `coordinacion-ronda27.md`).
- La solicitud 15788291 queda abierta en nivel 2 (Incompleta, tomada por SISANS) para no finalizar la CA de nivel 2. No usar en otras pruebas.
- No se repitió el alta en SCA (duplicaría solicitud sobre la misma póliza); la pestaña inicial de SCA se verificó en su Detalle.
- Pendientes: decisión REASIGNAR (§10), anomalías 5 y 6 (§8), texto definitivo del error de `SCA2_AnulacionFueraNormaPrincipal`.

## 10. Preguntas para el analista

1. ¿Se quita REASIGNAR del Detalle (recomendación §5.3) o se mantiene sólo para administradores con selector de usuario?
2. `SCA2_AnulacionFueraNormaPrincipal` aún lleva el sufijo «(texto provisional, pendiente del analista)» en el mensaje de error al cancelar una autorización CORE (texto distinto al de SI24). ¿Texto definitivo?
3. El aviso «Esta solicitud la está gestionando SI24» se muestra a Oficina (Red Mapfre) en el Detalle; ¿debe mostrarse también en la pantalla de Contra Anulación de nivel 1 si la abre Oficina con la solicitud ya en nivel 2? (hoy no existe en SCA).

## 11. Grabaciones y capturas

Grabación anotada (no en el repo): `sca2-sca-r27a-edited.mp4` (contexto JJGONZ2 + contexto SISANS, SCA2 y SCA).
Capturas (no en el repo): `comparativa_01_cabeceras_oficina.png`, `comparativa_02_aviso_oficina.png`, `comparativa_03_botones_si24.png` (izquierda SCA, derecha SCA2) y `01_sca2_oficina_alta_datos_poliza.png` … `13_sca_oficina_nivel2_sin_aviso_ni_botones.png`.
