# R29-B — Dos tablas de argumentos en la CA nivel 2 y documentos que no se cargan (SCA vs SCA2, TEST)

Sesión: https://mapfre.devinenterprise.com/sessions/16462ce826d4426fab0de5f2d80caccb · 23/10/2026 · Appian TEST (nunca PRO).

## 1. Pólizas y solicitudes

Comprobación con `SCA2_consultarSolicitudes` (10:50 UTC) de las 27 pólizas wAutemis «que derivan»: 24 ya tenían solicitud (descartadas); libres 0005726681408, 0005726682856 y 0005726681221.

| App | Póliza | idSolicitud | Resultado |
|---|---|---|---|
| SCA2 | 0005726681408 | **15788313** | Alta → CA N1 negativa (JJGONZ2) → CA N2 retomada por SISANS (queda INCOMPLETA) |
| SCA | 0005726682856 | **15788312** | Alta → CA N1 negativa (JJGONZ2) → mensaje «enviado a SI24», pero no aparece CA N2 |
| — | 0005726681221 | — | Reserva, no usada |

Estados CORE (`SCA2_consultaGestion`, al terminar):

| Solicitud | Gestiones (accionRealizada → codEstGestion, usuario) | codEstSolic |
|---|---|---|
| 15788313 (SCA2) | 43706642 alta(8) FINALIZADA JJGONZ2 · 43706643 CA(2) FINALIZADA NEGATIVA JJGONZ2 · 43706653 (4) FINALIZADA JJGONZ2 · 43706655 CA(2) **INCOMPLETA** SISANS (SI24 EXPERTOS) | 2 |
| 15788312 (SCA) | 43706641 alta(8) FINALIZADA · 43706644 CA(2) FINALIZADA NEGATIVA · 43706651 (4) FINALIZADA (todas JJGONZ2); **sin gestión CA nivel 2** | 2 |

## 2. Causa de «Documento no disponible» (documentos)

- SCA (`SCA_AccionesAdministrativasDocumentacion`): el ojo siempre llama `a!startProcess_26r3(cons!SCA_PM_OBTENER_DOCUMENTO_GD, documentumId: fv!row.idDocumento)` → PM «SCA Obtener Documento GD» → `SCAC_consultaDocumentoIntegracion` (`documents-web/api/sgd/1.0/documents/{id}/content`, CONVERT_BINARY) → `pv!documentId`. Sólo está habilitado si la referencia está en `consultarDocumentos` (un adjunto recién añadido tiene el ojo deshabilitado).
- SCA2 (`SCA2_AccionesAdministrativasDocumentacion` v4): para poder ver también el adjunto recién añadido se añadió una rama `if(typeof(idDocumento) = 3, todocument(idDocumento), a!startProcess(PM))`. Pero `idDocumento` es **siempre Text** (tanto la referencia SGD `0900ab44…` que devuelve CORE como el id Appian del adjunto, que se guarda con `split(nombreDoc,"_")`), así que nunca se lanzaba el PM y `todocument("0900ab44…")` daba el visor «Documento no disponible». Exactamente lo que vio el analista («no se lanzan las instancias de obtener documento»).
- El resto de la cadena SCA2 era correcta: `SCA2 CMD ObtenerDocumentoGD` y `SCA2_consultaDocumentoIntegracion` (test LCP con `0900ab4481a0cf66`: HTTP 200, PDF convertido a documento Appian, igual que `SCAC_consultaDocumentoIntegracion`).

Corrección: se distingue por la longitud de la referencia (las del SGD tienen 16 caracteres; los ids Appian son numéricos cortos):

```appian
/* R29-B: las referencias del SGD (16 caracteres, p.ej. 0900ab44...) se obtienen con el PM como en SCA;
   los adjuntos de esta sesión llevan el id numérico del documento Appian */
if(
  len(tostring(index(fv!row, "idDocumento", ""))) <> 16,
  { a!save(local!documento, todocument(tointeger(index(fv!row, "idDocumento", null)))), a!save(local!visualizar, true) },
  a!startProcess(processModel: cons!SCA2_PM_OBTENER_DOCUMENTO_GD, processParameters: {documentumId: fv!row.idDocumento}, ...)
)
...
disabled: if(
  len(tostring(index(fv!row, "idDocumento", ""))) <> 16,
  a!isNullOrEmpty(index(fv!row, "idDocumento", null)),
  or(a!isNullOrEmpty(fv!row.idDocumento), search(fv!row.idDocumento, local!consultaDocumentosGD) = 0)
)
```

`SCA2_DetalleSolicitud` (R29-A, no tocado) ya lanzaba siempre el PM: en la prueba su ojo abrió el PDF de la referencia SGD sin cambios.

## 3. Dos tablas de argumentos

`SCA2_ContraAnulacionArgumentarioEstrategicas` recibe del padre (`SCA2_ContraAnulacionOpciones`, sin cambios) la lista con los `numArgAnteriores` argumentos de CA anteriores al principio (alfabético) y luego los de esta CA (orden del servicio). Antes: un grid con fila separadora. Ahora:

- **«Argumentos ejecutados en contra anulaciones anteriores»**: `selectable: false()`, sólo se muestra si hay anteriores; mantiene Orden, Argumento, Obligatorio, Argumentario (ojo), Aplicación (enlace), Estado, Usuario, Fecha.
- **«Argumentos disponibles para esta contra anulación»**: con selección (`maxSelections: 1`) que guarda `indiceArgumentoSeleccionado`/`argumentoSeleccionado` con el índice real (`fv!row.idx`), por lo que POSITIVO/NEGATIVO del padre siguen actuando sobre la fila correcta; Orden = `idx - numArgAnteriores` (1..n).
- Nivel 1 (`numArgAnteriores = 0`): sólo la segunda tabla. Fila separadora eliminada.

```appian
local!filasAnteriores: if(and(local!numAnt > 0, local!numAnt <= length(local!filas)), index(local!filas, enumerate(local!numAnt) + 1, {}), {}),
local!filasDisponibles: if(and(local!numAnt > 0, local!numAnt <= length(local!filas)),
  if(local!numAnt = length(local!filas), {}, index(local!filas, enumerate(length(local!filas) - local!numAnt) + local!numAnt + 1, {})),
  local!filas),
...
a!gridField_25r3(label: "Argumentos ejecutados en contra anulaciones anteriores", data: local!filasAnteriores, ..., selectable: false(), showWhen: length(local!filasAnteriores) > 0),
a!gridField_25r3(label: "Argumentos disponibles para esta contra anulación", data: local!filasDisponibles, ..., selectable: true(), maxSelections: 1, ...)
```

Test LCP de la interfaz con 3 argumentos y `numArgAnteriores` = 0 / 1 / 3: sin errores; 1 grid con 0, 2 grids con 1 y 3.

## 4. Objetos SCA2 modificados

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_ContraAnulacionArgumentarioEstrategicas` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060043` | 4 → 5 | Dos grids, sin separador (§3) |
| `SCA2_AccionesAdministrativasDocumentacion` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060475` | 4 → 5 | Ojo: referencia SGD → PM ObtenerDocumentoGD (§2) |

Procedimiento: GET vivo (comprobado igual al volcado) → backup local → PUT completo (inputs conservados: 14 y 31) → re-GET idéntico → test LCP → prueba UI. `SCA2_AccionesAdministrativasDocumentacion` no figuraba en ninguna columna de `coordinacion-ronda29.md`; se reservó allí antes de editar porque es la interfaz del ojo de Documentación de la CA.

## 5. Comparación paso a paso (UI)

| # | Paso | SCA (15788312) | SCA2 (15788313) | Veredicto |
|---|---|---|---|---|
| 1 | Alta de solicitud (JJGONZ2) | OK, deriva a CA N1 | OK, deriva a CA N1 | Igual |
| 2 | Argumentos N1 | Una tabla | Sólo «Argumentos disponibles para esta contra anulación» | Igual en contenido (título nuevo pedido por el analista) |
| 3 | Adjuntar PDF nuevo en Documentación N1 | Entregado; ojo **deshabilitado** hasta que esté en el SGD | Entregado; ojo habilitado y muestra el PDF | Diferencia ya aceptada en ronda 2 (punto 15 «visualizar tras cargar»); se mantiene |
| 4 | NEGATIVO del argumento obligatorio, carta, FINALIZAR N1 | OK, mensaje «enviado a SI24» | OK, mensaje «enviado a SI24» | Igual |
| 5 | CA nivel 2 (SISANS) | **No se crea** CA N2: la solicitud sigue en Nivel 1 y CORE no tiene gestión N2 | CA N2 creada, RETOMAR OK | No comparable (SCA TEST no generó N2; no atribuible a SCA2) |
| 6 | Dos tablas N2 | — | Tabla histórica (INCREMENTO PRIMA, Negativo, JJGONZ2, fecha, 0 checks) + tabla disponibles (7 filas con check) | Cumple lo pedido |
| 7 | NEGATIVO en N2 sobre fila seleccionada | — | Actualiza la fila seleccionada (obligatoria y «SUPLEMENTO EN GENERAL») sin tocar la histórica | OK |
| 8 | Ojo Documentación N2 (referencia SGD `0900ab4481a0dc57`) | — | Muestra el PDF (antes «Documento no disponible») | **Corregido** |
| 9 | Ojo del Detalle (referencia SGD) | `0900ab4481a0dc55` → PDF visible | `0900ab4481a0dc57` → PDF visible | Igual |

## 6. Divergencias

- **Corregida**: ojo de documentos de la CA en SCA2 no lanzaba el PM de obtener documento (§2).
- **Implementada** (petición del analista): dos tablas de argumentos (§3).
- **No corregida / no comparable**: en SCA TEST la CA N1 negativa de 15788312 no generó CA N2 (sin gestión N2 en CORE), así que no se pudo comparar N2 con SCA. Es comportamiento de SCA/CORE, no de SCA2.

## 7. Limitaciones y pendientes

- POSITIVO en N2 abre la confirmación de cierre de la retención; se canceló para no finalizar la CA N2 (queda INCOMPLETA en 15788313). No se verificó el resultado de confirmar POSITIVO.
- Sólo había un argumento histórico: el orden alfabético con varios históricos lo garantiza el padre (R27-B, sin cambios), no se volvió a ver en UI.
- No se ejercitó el ojo de argumentario de la tabla histórica (se muestra habilitado).
- La regla de 16 caracteres asume el formato de referencia Documentum (`0900…`, 16 hex) observado en todas las solicitudes; si el SGD devolviera otro formato habría que ajustarla.

## 8. Grabaciones y evidencias (no se suben al repo)

- Vídeo: `r29b-ui-test-edited.mp4`.
- Capturas: `04-sca-argumentos-n1.png`/`04-sca2-argumentos-n1.png`, `07-sca2-visor-adjunto-visible.png`, `14-sca2-dos-tablas-n2.png`, `17-sca2-negativo-fila4-n2.png`, `19-sca2-visor-sgd-n2-visible.png`, `22-sca2-visor-detalle-sgd-visible.png`, `24-sca-visor-detalle-sgd-visible.png`, `26-sca-nivel1-sin-ca2.png`, `26-sca2-nivel2-incompleto.png` y el resto en `r29b-capturas-y-registro.zip`.
