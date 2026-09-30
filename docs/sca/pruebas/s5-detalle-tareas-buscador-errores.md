# S5 — Detalle, estados, asignación de tareas, buscador, bandeja de errores y mecanización/caducidad (SCA vs SCA2, TEST)

Fecha: 30/09/2026 · Entorno: `mapfrespain-test` · Usuario funcional UI: `JJGONZ2@mapfrenopro.onmicrosoft.com` (RED MAPFRE / CE_RM / OFICINA, nivel 1).
Referencia funcional: **SCA TEST**. Solo se han modificado objetos de la aplicación **SCA2** (procedimiento GET vivo → backup → PUT completo → re-GET → `/test` → repetir UI). No se ha tocado SCA, SCAC, CORE, GAIA, PRE ni Documentum.

## 1. Pólizas y solicitudes creadas

| App | Póliza | idSolicitud | Alta (gestión CORE acción 8) | Ruta | Estado final CORE de la gestión Contra Anulación |
|---|---|---|---|---|---|
| SCA | `2002000000999` | **15787696** | 43704806 · FINALIZADA · 30/09/2026 11:34:04 · obs. `Prueba S5 Devin` | Contra Anular → NEGATIVO → carta → FINALIZAR | 43704815 · acción 2 · **FINALIZADA NEGATIVA** · fin 30/09/2026 12:11:30 · obs. `Prueba S5 negativo,Prueba S5 negativo` · documento tipo 6 `0900ab4481a04a8d`; gestión adicional 43704832 (acción 4, FINALIZADA 12:06:50) |
| SCA2 | `2002000061523` | **15787699** | 43704810 · FINALIZADA · 30/09/2026 11:34:55 · obs. `Prueba S5 Devin` | Contra Anular → NEGATIVO → carta → FINALIZAR (fallo, ver §4.1) → cierre CORE directo | 43704812 · acción 2 · **FINALIZADA CANCELADA** · fin 30/09/2026 12:24:29 · sin observación ni documento |

Póliza de reserva `2002000059216`: **no usada**. Datos del alta en ambas: motivo `DECISION DE CLIENTE` · detalle `PRECIO` · causa `ME HA SUBIDO MUCHO LA PRIMA` · canal `PRESENCIAL` · catalogación `A VENCIMIENTO`.

`SCA_consultarSolicitudes` / `SCA2_consultarSolicitudes` (tpBusqueda 0): ambas devuelven `codEstSolic: "2"`; `fecResolucion` 30/09/2026 12:11:30 (SCA) y 30/09/2026 12:24:29 (SCA2, tras el cierre CORE directo).

## 2. Tabla paso a paso SCA vs SCA2

Leyenda veredicto: **=** igual · **≠→OK** divergencia exclusiva SCA2 corregida en esta sesión · **≠ pend.** divergencia SCA2 pendiente · **≠ común** también ocurre en SCA / servicio externo (no se corrige) · **n/p** no probado.

| # | Paso | SCA (15787696) | SCA2 (15787699) | Veredicto |
|---|---|---|---|---|
| 1 | Alta (motivo → Contra Anular) | Gestión 43704806 FINALIZADA, obs. `Prueba S5 Devin`; solicitud `codEstSolic 2` | Gestión 43704810 FINALIZADA, misma obs.; record `SCA2 Solicitud` EN_ACCION / interfazActiva CONTRA_ANULAR | = |
| 2 | Buscador · pestaña Póliza | Fila con estado `Solicitud Pendiente` (naranja), resolución `-`, botones por fila | Igual; la fila de 15787699 aparece como `Solicitud Pendiente` | ≠→OK (antes SCA2 mostraba `Contra anulación en curso`; `SCA2_textoEstadoSolicitud` v4→v6) |
| 3 | Buscador · pestaña Cliente / Nº documento (`34615123P`) | Devuelve la solicitud | Devuelve la solicitud | = |
| 4 | Buscador · filtro Estado = Pendiente | Incluye la solicitud | Incluye 15787699 | ≠→OK (`SCA2_Buscador` v11→v12: agrupa estados internos equivalentes con `operator: "in"`) |
| 5 | Buscador · filtro Estado = Finalizada negativa | Incluye 15787696 tras FINALIZAR | Excluye 15787699 (record sigue `PDTE_FINALIZAR`, ver §4.2) | ≠ pend. (coherente con el record; el defecto es el estado del record, no el filtro) |
| 6 | Buscador · columnas, orden, paginación, colores | Columnas y orden equivalentes; colores por estado | Equivalentes; `Solicitud Pendiente` naranja como SCA | = |
| 7 | Buscador · solicitudes PDTE-* | n/a (SCA no las genera) | Ocultas del buscador; van a `/errores` (interfaz `SCA2_BandejaErrores`, probado por LCP) | = (diseño SCA2 documentado en doc 11) |
| 8 | Buscador · solicitud creada en la otra app | 15787699 (creada en SCA2) visible en SCA con `Solicitud Pendiente`, obs. `Prueba S5 Devin` en "últimas solicitudes gestionadas" | 15787696 (creada en SCA) **no** existe como record SCA2 → no abre detalle en SCA2 | ≠ común / limitación por diseño (SCA2 solo tiene record de sus propias solicitudes; documentado, no corregido) |
| 9 | Detalle · cabecera / Datos cliente / Datos póliza / Solicitud | Nombre `GAXVEF CAPIA`, apellidos `GOSIJTUEV JYABOG`, NIF `34615123P`, RSV 0,00 €, Dto 12 %, Club Oro | Idénticos | = |
| 10 | Detalle · acordeón Alta Solicitud | `Finalizada` verde, fechas y observación CORE de la gestión acción 8 | Igual (fechas/obs. desde CORE) | ≠→OK (`SCA2_DetalleSolicitud` v15→v16: usa la gestión CORE acción 8 en lugar de timestamps del record) |
| 11 | Detalle · tarjeta Contra Anulación (abierta) | Fecha inicio CORE, nivel 1, perfil RED MAPFRE, grupo OFICINA, nuuma JJGONZ2, argumentos ejecutados, documentos, observaciones | Igual (ya alineado en doc 12 §12.4) | = |
| 12 | Detalle · argumentos: NEGATIVO sobre `INCREMENTO PRIMA SINIESTROS` | Tag `Negativo` rojo | Tag `Negativo` rojo | = |
| 13 | Detalle · orden de argumentos en la tabla | TARJETA BANKINTER, OPORTUNIDAD DE DESCUENTOS, CAMBIO DE FORMA DE PAGO… | REDUCCION DE COBERTURAS, SERVICIOS MAPFRE, GESTION COMPETENCIA… (mismos argumentos, distinto orden) | ≠ común (el orden lo devuelve el servicio CORE/GAIA; SCA pagina 10 por página) |
| 14 | Acción Contra Anular · POSITIVO | Ventana de confirmación única, plantilla de carta con nombre/apellidos y fecha del día | Igual tras correcciones; prueba cancelada en la confirmación (no aceptada) | ≠→OK (`SCA2_ContraAnulacionOpciones` v15→v18: `tostring()` en `codTipoArgumento`, modal duplicado, nombre/apellidos y `today()` en la carta; `SCA2_ContraAnulacionRehabilitacion` v1→v2) |
| 15 | Acción Contra Anular · NEGATIVO + observación `Prueba S5 negativo` | Obs. persistida en CORE | Obs. no persistida (ver §4.1) | ≠→OK parcial (payload corregido v20, pendiente re-ejecución UI) |
| 16 | Acción · botón FINALIZAR bloqueado sin carta | Mensaje de documentación obligatoria | Igual tras corrección | ≠→OK (`SCA2_ContraAnulacionOpciones` v12→v13) |
| 17 | Acción · subir carta (GD) | Documento tipo 6 persistido, visible en Detalle | Subida OK en UI; F5 en la acción pierde la carta no confirmada | ≠ común (en SCA la carta tampoco sobrevive a F5 antes de FINALIZAR) |
| 18 | Acción · FINALIZAR | `CORRECTO`; gestión FINALIZADA NEGATIVA, fecha fin, doc. y obs. en CORE | `CORRECTO` en pantalla pero gestión INCOMPLETA, sin fecha fin, sin doc./obs. | ≠→OK parcial (§4.1: payload `finalizarCAPca` corregido en v20; CORE cerrado con la regla corregida) |
| 19 | Detalle tras cierre · tarjeta CA | `Finalizada Negativa` rojo, fin 12:11:30, carta y observaciones | `Finalizada Cancelada`, fin 12:24:29, sin documentos ni observaciones; color **naranja** (SCA: azul) | ≠→OK color (`SCA2_DetalleSolicitud` v19→v20) · docs/obs ≠ pend. (§4.3) |
| 20 | Detalle · botones RETOMAR / REASIGNAR con gestión cerrada | No se muestran | No se muestran | = |
| 21 | Tareas · RETOMAR (gestión abierta) | Retomar disponible solo para el propietario de la tarea (`SCA_queryProcessReport`) | RETOMAR ejecutado en SCA2: reabre la acción, tarea reasignada a JJGONZ2 | = (SCA no re-probado con RETOMAR: la gestión ya estaba cerrada) |
| 22 | Tareas · REASIGNAR | Solo visible si la tarea es de otro usuario (`local!reasignar`) | Igual: no visible siendo JJGONZ2 el asignado; pool solo con JJGONZ2 | = (no ejecutable con un único usuario del pool; `SCA2_DetalleSolicitud` v18→v19 corrige el `saveInto` de REASIGNAR) |
| 23 | Navegación · F5 en Detalle | Mantiene detalle | Mantiene detalle | = |
| 24 | Navegación · URL directa al detalle | Abre el detalle | Abre el detalle (`$sp` cifrado del site) | = |
| 25 | Navegación · atrás desde la acción | Vuelve al buscador con resultados perdidos (pantalla vacía) | Vuelve al detalle | ≠ común (defecto exclusivo de SCA; SCA2 se comporta mejor, no se toca) |
| 26 | Mecanización (`PDTE_MECANIZAR`) | No alcanzado | No alcanzado | n/p |
| 27 | Caducidad | Timer/receiveMessage en el PM de SCA (revisado en doc 11) | `SCA2 CMD BarridoCaducidad` / `CMD Caducar` (revisado); **no lanzado** para no afectar a solicitudes ajenas (el barrido no filtra por solicitud) | n/p |
| 19b | Detalle · color tarjeta CA tras v20 | `Finalizada Cancelada` azul | `Finalizada Cancelada` azul (ronda 4, también tras F5) | ≠→OK |
| 19c | Detalle · acordeón `Impresion` | SCA muestra un tercer acordeón `Impresion — Finalizada` (verde) en 15787696 (gestión adicional 43704832, acción 4) | SCA2 no tiene acordeón `Impresion` en su detalle (15787699 no tiene impresión, no comparable directamente) | n/p — confirmar con analista si SCA2 debe mostrarlo |
| 19d | Detalle · F5 con acordeón CA expandido | Mantiene el detalle | Mantiene el detalle pero el acordeón vuelve contraído; recarga ~30 s con pantalla vacía; `$sp` cambia | ≠ pend. (menor; no corregido) |
| 28 | Bandeja de errores `/errores` | n/a (SCA usa alertas/PM pausado) | Ruta `/suite/sites/sca2/page/errores` devuelve "La página no existe o no tiene permiso para verla" con JJGONZ2: la página tiene `visibilityExpr: a!isUserMemberOfGroup(loggedInUser(), cons!SCA2_GRP_ADMINISTRADORES)` (site v8, JJGONZ2 fue retirado de administradores en doc 11). Por LCP, `SCA2_DetalleErrores(idSolicitud 15787699)` → sin filas; `SCA2_BandejaErrores` → renderiza errores de otras solicitudes con Relanzar | n/p en UI (por diseño: solo admins) · no hay `SCA2 Error` de 15787699 |

## 3. Estados CORE observados tras cada acción

| Momento | SCA 15787696 | SCA2 15787699 |
|---|---|---|
| Tras Alta | 43704806 acción 8 FINALIZADA 11:34:04 | 43704810 acción 8 FINALIZADA 11:34:55 |
| Tras Contra Anular (gestión abierta) | 43704815 acción 2 INCOMPLETA, inicio 11:35 | 43704812 acción 2 INCOMPLETA, inicio 11:35:12 |
| Tras NEGATIVO + carta + FINALIZAR (UI) | 43704815 FINALIZADA NEGATIVA 12:11:30, obs. `Prueba S5 negativo,Prueba S5 negativo`, doc tipo 6; 43704832 acción 4 FINALIZADA 12:06:50 | 43704812 **sigue INCOMPLETA**; record `PDTE_FINALIZAR` (v4, 10:15:53 UTC), `estadoTarea PENDIENTE`; `SCA2_consultaDetalleGestion`: observaciones null, listadoDocumentos null; `SCA2_consultarDocumentos`: null |
| Tras corrección v20 + test directo `SCA2_finalizarContraAnulPca` (`mcaEstadoFinal "9"`) | — | 43704812 **FINALIZADA CANCELADA** 12:24:29; `consultarSolicitudes.fecResolucion` 12:24:29; record `SCA2 Solicitud` **sigue `PDTE_FINALIZAR`** |

## 4. Divergencias encontradas

### 4.1 Corregida (parcial): FINALIZAR de Contra Anulación no cerraba la gestión CORE — `SCA2_ContraAnulacionOpciones` v19→v20

`SCA2_CMD_CompletarAccion` (uuid `0000f06f-1307-8000-65b1-7f0000014e7a`) nodo `Finalizar CA PCA` pasa `pv!resultado.finalizarCAPca` a `rule!SCA2_finalizarContraAnulPca` → `SCA2_finalizarContraAnulPcaIntegracion` (`PCA_CORECFSA_HTTPRouter/IContraAnularPCA`). La interfaz enviaba un mapa plano (`codSolicitud, ciaContraria, catalogacion, resultado, observaciones, nuuma`) que no corresponde al CDT `finalizarContraAnulPca` (`MSEFinalizarContraAnulPca{mcaEstadoFinal, nivelIntervencion, codSolicitud, infoUsuario{…}}`), por lo que la llamada no cerraba la gestión aunque la UI mostrara `CORRECTO`.

```text
/* antes (v19) */
finalizarCAPca: { codSolicitud: ri!idSolicitud, ciaContraria: local!ciaContraria, catalogacion: local!catalogacion,
                  resultado: local!estadoContraAnul, observaciones: local!observaciones, nuuma: local!nuuma },
/* después (v20) — FINALIZAR ("9") y cierre POSITIVO ("3") */
finalizarCAPca: a!map(
  MSEFinalizarContraAnulPca: a!map(
    mcaEstadoFinal: "9", nivelIntervencion: local!nivelIntervencion, codSolicitud: ri!idSolicitud,
    infoUsuario: a!map(codCiaUsuario: local!codCiaUsuario, nuuma: local!nuuma, codPerfil: local!codPerfil,
                       codSubPerfil: index(local!data, "codSubPerfil", ""))),
  ciaContraria: local!ciaContraria, catalogacion: local!catalogacion)
```

Primer PUT rechazado (`Unused Local Variables at line: 59 — local!ciaContraria`); se conservaron `ciaContraria`/`catalogacion` fuera del mapa de integración y el segundo PUT devolvió 200 (v20). Re-GET idéntico; `/test` de la interfaz 200 sin error. Test directo de `SCA2_finalizarContraAnulPca` con el payload anidado para 15787699: `success: true`, `MSSFinalizarContraAnulPca.respuesta: true` → gestión 43704812 cerrada en CORE como **FINALIZADA CANCELADA** (`mcaEstadoFinal 9` = cancelación; el cierre NEGATIVO con observación/carta corresponde al flujo NEGATIVO previo, que ya había perdido su payload).

**Pendiente**: repetir FINALIZAR desde la UI de SCA2 con v20 sobre una solicitud nueva (con 15787699 la gestión ya está cerrada y una segunda llamada a CORE sería sobre una gestión finalizada). No se ha vuelto a ejecutar para no salir del alcance autorizado.

### 4.2 Pendiente: record `SCA2 Solicitud` 15787699 sigue en `PDTE_FINALIZAR`

`SCA2_CMD_CompletarAccion` escribe `PDTE_FINALIZAR` antes de llamar a CORE y solo escribe `FINALIZADA` (`interfazActiva FIN`, `procesoActivo null`) si `pv!resultado.finalizadoCA = true`, `mcaEstadoFinal ∈ {9,3,CANCELADO}` o `codEstado = 5`. Con el payload v19 la integración no devolvió éxito, el proceso no llegó a `Write FINALIZADA` y tampoco registró `SCA2 Error` (no hay filas en `SCA2_DetalleErrores`). El cierre directo por regla no pasa por el proceso, así que el record permanece `PDTE_FINALIZAR` (v4) y el buscador SCA2 sigue mostrando `Solicitud Pendiente` / resolución `-` mientras CORE ya muestra la gestión cerrada. Causa exacta del silencio del proceso (sin `Write Error`) **no verificada**. Propuesta: (a) reintentar el flujo completo con v20 en una solicitud nueva; (b) si se confirma que `Finalizar CA PCA` puede fallar sin `Write Error`, añadir rama de error/`SCA2 Error` en el PM (no se ha modificado el PM en esta sesión). No se ha corregido el record a mano.

### 4.3 Pendiente: documentos y observaciones de la Contra Anulación no persistidos en SCA2

En SCA la gestión cerrada muestra la carta (tipo 6) y las observaciones; en SCA2 `SCA2_consultaDetalleGestion` devuelve `observaciones null`, `listadoDocumentos null`. Es consecuencia de 4.1 (el NEGATIVO/carta/FINALIZAR original no llegó a CORE; el cierre posterior fue una cancelación sin payload), no un defecto del Detalle (§12.4 ya lee documentos/observaciones de CORE). Se resolverá al repetir el flujo con v20.

### 4.4 Corregida: color de la etiqueta de estado de la tarjeta Contra Anulación — `SCA2_DetalleSolicitud` v19→v20

SCA usa la decisión `SCA_D_ColorEstadoGestion(gestion, estado)` (objeto Decision, no accesible por LCP; colores muestreados en pantalla: FINALIZADA `#008C47`, FINALIZADA NEGATIVA `#DF0027`, FINALIZADA CANCELADA `#0D82BD`). SCA2 usaba un `a!match` inline con `default: "#E46B15"` (naranja) para cualquier estado no listado.

```text
equals: "FINALIZADA", then: "#008C47",
equals: "FINALIZADA POSITIVA", then: "#008C47",
+ equals: "FINALIZADA NEGATIVA", then: cons!SCA2_VAL_COLOR_ROJO,
+ equals: "FINALIZADA CANCELADA", then: "#0D82BD",
equals: "CANCELADA", then: "#9F9F9F",
default: "#E46B15"
```

PUT 200 (v20), re-GET idéntico, `/test` con `idSolicitud 15787699` → 200 sin error, 4,6 s. Validación UI ronda 4: `Finalizada Cancelada` azul en SCA2 igual que en SCA (muestreo de píxel equivalente), `Finalizada` verde en ambas; se mantiene tras F5. El rojo de `FINALIZADA NEGATIVA` en SCA2 **no está validado en runtime** (no hay solicitud SCA2 finalizada negativa; 15787696 no existe como record SCA2).

### 4.5 Corregidas antes en esta sesión (resumen)

| Objeto | uuid | Versión | Cambio |
|---|---|---|---|
| `SCA2_textoEstadoSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063670` | 4 → 6 | Estados internos `EN_ACCION`, `PENDIENTE`, `EN_PROCESO`, `PDTE`, `ALTA`, `DECIDIDA`, `PDTE_FINALIZAR` → `Solicitud Pendiente` (SCA no muestra `Contra anulación en curso`) |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 15 → 16 | Acordeón Alta: estado/fechas/observación desde la gestión CORE acción 8 |
| `SCA2_DetalleSolicitud` | ídem | 18 → 19 | REASIGNAR: `saveInto` llama directamente a `rule!SCA2_reasignarTarea(idTarea)` (eliminado `local!reasignado` sin uso) |
| `SCA2_DetalleSolicitud` | ídem | 19 → 20 | Colores FINALIZADA NEGATIVA / FINALIZADA CANCELADA (§4.4) |
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 12 → 13 | FINALIZAR bloqueado sin carta/argumento como SCA |
| `SCA2_ContraAnulacionOpciones` | ídem | 15 → 16 | `contains({"286","287"}, tostring(index(local!argumentoSeleccionado,"codTipoArgumento","")))` y `{"358","356"}` (error `Invalid types` en POSITIVO) |
| `SCA2_ContraAnulacionOpciones` | ídem | 17 → 18 | Formulario principal oculto mientras hay modal (`showWhen: and(not(local!showPopup), not(local!mcaVentana…))`) — confirmación POSITIVO duplicada |
| `SCA2_ContraAnulacionOpciones` | ídem | 18 → 19 | Plantilla de carta: `clienteNombre`/`clienteApellidos` desde `datosCabecera` raíz de `SCA2_cargarSolicitud`; `anho: tostring(year(today()))`, `dia: tostring(day(today()))` |
| `SCA2_ContraAnulacionOpciones` | ídem | 19 → 20 | Payload `finalizarCAPca` anidado `MSEFinalizarContraAnulPca` (§4.1) |
| `SCA2_ContraAnulacionRehabilitacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060049` | 1 → 2 | `a!cardLayout(contents: rule!SCA2_ContraAnulacionModalInformativo(...), showWhen: a!defaultValue(ri!mcaVentanaInfo, false), showBorder: false)` |
| `SCA2_Buscador` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | 11 → 12 | Filtro Estado con `operator: "in"` agrupando estados internos equivalentes (PENDIENTE, PENDIENTE_AUTORIZACION, FINALIZADA_NEG_CONTRA, CADUCADA) |

Backups SAIL/JSON antes/después en `~/sca2work/backup/` (fuera del repo). Objetos SCA2 consultados sin modificar: `SCA2_CMD_CompletarAccion`, `SCA2_CMD_Finalizar`, `SCA2_finalizarContraAnulPca`, `SCA2_finalizarContraAnulPcaIntegracion`, `SCA2_DetalleErrores`, `SCA2_BandejaErrores`, `SCA2_contarErroresPendientes`, `SCA2_relanzarError`, `SCA2_D_ColorEstadoGestion`, site `SCA2 Anulaciones` (v8).

### 4.6 Divergencias comunes / no corregibles en SCA2

- Orden de argumentos ejecutados (lo devuelve el servicio CORE/GAIA).
- F5 en la pantalla de acción pierde la carta subida y no confirmada (igual en SCA).
- Navegador atrás desde la acción deja el buscador SCA vacío (defecto de SCA; SCA2 correcto).
- Solicitud creada en SCA no abre en SCA2 (SCA2 solo tiene record de sus propias solicitudes; la inversa sí funciona porque SCA consulta CORE).
- `/errores` solo visible para `SCA2_GRP_ADMINISTRADORES` (decisión de diseño, doc 11); JJGONZ2 no es admin.

## 5. Limitaciones y pendientes

1. **FINALIZAR SCA2 con v20 no re-ejecutado desde UI** (gestión de 15787699 ya cerrada en CORE). Requiere una solicitud nueva autorizada.
2. **Record 15787699 en `PDTE_FINALIZAR`** con gestión CORE cerrada (§4.2): inconsistencia record/CORE en SCA2. Decidir si se corrige el dato o se deja como evidencia.
3. **Sin `SCA2 Error`** para el fallo silencioso de `Finalizar CA PCA`: revisar rama de error del PM `SCA2_CMD_CompletarAccion` (no modificado).
4. **REASIGNAR** no ejecutable en ninguna app: el pool solo contiene a JJGONZ2. **RETOMAR** en SCA no ejecutado (gestión ya cerrada cuando se probó en SCA2).
5. **Mecanización** no probada: ninguna solicitud llegó a `PDTE_MECANIZAR`.
6. **Caducidad** no probada: el barrido SCA2 no admite filtro por solicitud y afectaría a solicitudes ajenas; SCA caduca por timer del PM.
7. **Bandeja de errores** validada solo por LCP (`SCA2_BandejaErrores`/`SCA2_DetalleErrores` renderizan; no hay error de 15787699); la UI `/errores` requiere usuario administrador. Relanzar no probado sobre error propio (no se produjo ninguno).
8. POSITIVO en SCA2 probado hasta la confirmación y cancelado (no autorizado a aceptarse en este escenario).
9. Color rojo `FINALIZADA NEGATIVA` en SCA2 v20 validado solo por `/test` (sin solicitud SCA2 finalizada negativa).
10. Acordeón `Impresion` (gestión acción 4) existe en el detalle SCA y no en SCA2: no comparable con 15787699; pendiente de confirmar alcance.
11. `SCA_D_ColorEstadoGestion` es un objeto Decision no legible por LCP; los colores SCA se han obtenido muestreando la pantalla.

## 6. Preguntas para el analista

- ¿Se corrige a mano el record `SCA2 Solicitud` 15787699 (`PDTE_FINALIZAR` → `FINALIZADA`) o se deja como evidencia de la incidencia?
- ¿Debe `SCA2_CMD_CompletarAccion` registrar `SCA2 Error` cuando `Finalizar CA PCA` no devuelve éxito (hoy termina sin traza)?
- ¿Debe el detalle SCA2 mostrar el acordeón `Impresion` (gestiones acción 4) como SCA?
- ¿Se autoriza una póliza nueva para repetir el flujo NEGATIVO + carta + FINALIZAR con v20 en SCA2?

## 7. Evidencias (fuera del repo, en la máquina de la sesión)

Grabaciones (`~/screencasts/`):
- `sca-sca2-fase2-v18/sca-sca2-fase2-v18-edited.mp4` — Contra Anular, NEGATIVO, POSITIVO (cancelado), carta, FINALIZAR, F5, URL directa, buscador y filtros en SCA y SCA2.
- `sca-sca2-fase3/sca-sca2-fase3-edited.mp4` — detalle tras cierre CORE, buscador, `/errores`.
- `sca-sca2-fase4/sca-sca2-fase4-edited.mp4` — validación del color de estado (v20 `SCA2_DetalleSolicitud`), solo lectura.

Capturas (`~/sca2work/shots/`): `f2_05_negativo_sca|sca2`, `f2_07_tooltip_reejecutar_sca|sca2`, `f2_08_positivo_v16_sca`, `f2_20_positivo_v18_sca2`, `f2_09_plantilla_sca`, `f2_19_plantilla_v18_sca2`, `f2_10_subir_carta_sca|sca2`, `f2_11_carta_entregada_sca`, `f2_13_botones_detalle_sca|sca2`, `f2_15_finalizar_confirmacion_sca|sca2`, `f2_16_finalizar_resultado_sca|sca2`, `f2_18_f5_pierde_carta_sca2`, `f2_21_detalle_final_sca`, `f2_21_detalle_final_f5_sca2`, `f2_22_url_directa_sca|sca2`, `f2_23_buscador_final_sca`, `f2_25_filtro_pendiente_sca|sca2`, `f2_26_filtro_final_negativo_sca|sca2`, `f3_01_detalle_sca|sca2`, `f3_01_detalle_15787699_en_sca`, `f3_01_documentos_sca|sca2|15787699_en_sca`, `f3_02_buscador_sca2`, `f3_02_buscador_15787699_en_sca`, `f3_03_accion_sca2`, `f3_04_errores_sca2`, `f4_01_color_ca_sca|sca2`, `f4_01_color_ca_f5_sca2`, `f4_02_negativa_sca`.
