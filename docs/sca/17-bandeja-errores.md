# 17 — Pantalla de gestión de errores SCA2 (`/errores`)

## Problema reportado

Al pulsar **Relanzar** en `https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/errores`:

```
Expression evaluation error in rule 'sca2_bandejaerrores': An error occurred while executing a save:
... An error occurred when creating local!dummy. a!save() and smart service functions cannot be used
in a local variable unless "refreshAlways" is true ...
```

Causa: `SCA2_BandejaErrores` (v6) y `SCA2_DetalleErrores` (v2) lanzaban el proceso con
`a!save(local!dummy, a!startProcess(...))`. Appian no permite usar un smart service como valor de un
`a!save` sobre una variable local normal. El botón fallaba siempre, en la bandeja y en la sección
«Errores» del Detalle de solicitud.

Otros defectos encontrados en la revisión:

| # | Defecto | Dónde |
|---|---------|-------|
| 1 | Relanzar fallaba siempre (local!dummy) | Bandeja y Detalle |
| 2 | Tras relanzar la lista no se refrescaba (query sin `a!refreshVariable`) | Bandeja y Detalle |
| 3 | Sin mensaje de éxito/error tras la acción | Bandeja y Detalle |
| 4 | El grid recibía solo la lista de la página (`data: index(q,"data")`): la paginación nunca pasaba de los 15 primeros | Bandeja y Detalle |
| 5 | Filtro Comando con `=` exacto: no encontraba comandos con sufijo `" - dd/MM/yyyy HH:mm CEST"` | Bandeja |
| 6 | Bandeja: la columna Relanzar se mostraba para `Posponer`/`CambiarNivel`, que el PM `SCA2_CMD_MarcarErrorRelanzado` no enruta (marcaba RELANZADO sin relanzar nada) | Bandeja |
| 7 | Detalle: para comandos distintos de Alta lanzaba el PM del comando **y** además marcaba RELANZADO aunque el comando no se ejecutara; no pasaba `idError` ni el comando con sufijo | Detalle |
| 8 | Detalle: la columna Mensaje usaba `index(fv!row, mensaje, payload, null)` (índice anidado) y salía siempre vacía | Detalle |
| 9 | Sin forma de descartar errores no relanzables (Posponer/CORE_OBSERVACIONES, ObtenerDocumentoGD…) | Bandeja y Detalle |
| 10 | Sin filtro de estado ni de solicitud; sin contador | Bandeja |
| 11 | Filtro «Fecha desde» comparaba Date con Date and Time → error `GREATER_EQUALS_THAN ... fechaCreacion` (detectado en la prueba UI, ya existía en v6) | Bandeja (v8: `userdatetime(año, mes, día, 0, 0, 0)`) |

## Corrección (TEST)

| Objeto | Versión | Cambio |
|--------|---------|--------|
| `SCA2_BandejaErrores` | v6 → v9 | reescritura de la acción y mejoras de pantalla (v8: filtro Fecha desde; v9: el banner se limpia al cambiar filtros, Ver solicitud y Volver) |
| `SCA2_DetalleErrores` | v2 → v3 | misma lógica de acciones que la bandeja |

No se ha modificado ningún process model, regla, SCA, SCAC ni ANL.

Lógica por fila (común a bandeja y detalle):

```
cmdBase = primera parte de comando antes de " - "
pendiente = estado = "PENDIENTE" y no tratado en esta pantalla
relanzable = cmdBase ∈ {Decidir, CrearAccion, CompletarAccion, Finalizar, Mecanizar, Caducar}   // rutas del PM MarcarErrorRelanzado
             o (cmdBase = Alta y payload no vacío)

Relanzar (confirmación):
  Alta  → a!startProcess(SCA2_PM_CMD_ALTA, rule!SCA2_parametrosRelanzarAlta(error)) ; rule!SCA2_relanzarError(error)
  resto → a!startProcess(SCA2_PM_CMD_MARCAR_ERROR_RELANZADO, {idError, idSolicitud, comando (con sufijo)},
                         isSynchronous: true, onSuccess/onError/onIncomplete → banner + refresco)
          (el PM marca RELANZADO, normaliza el sufijo, carga params de CompletarAccion y lanza el CMD)
Descartar (confirmación): a!writeRecords(SCA2 Error{id, estado DESCARTADO, resueltoPor loggedInUser(), fechaResolucion now()})
Columna Relanzamiento: "Automático" | "Automático (alta)" | "Repetir alta desde la pantalla Alta" | "Repetir la acción desde la tarea"
```

Bandeja: filtros Estado (Pendiente por defecto / Todos / Relanzado / Descartado / Bloqueado), Comando
(`starts with`, cubre sufijos), Solicitud y Fecha desde; «Limpiar filtros», «Actualizar», contador en el
título, columnas Nodo/Intentos/Estado (Estado solo con «Todos»), paginación real con `a!dataSubset`,
mensaje de grid vacío; «Volver a la bandeja» refresca la lista.

`SCA2 CMD ObtenerDocumentoGD`, `Posponer` y `CambiarNivel` no tienen ruta en el PM de relanzamiento:
se muestran como «Repetir la acción desde la tarea» y solo se pueden descartar.

## Procedimiento seguido (skill appian)

- Verificación SAIL 4A/4B: `anexos/bandeja-errores/step4_verificacion.md`.
- Backup de las versiones vivas (v6/v2) antes del cambio, `validateExpression` (bandeja sin errores),
  `updateInterface`, readback idéntico byte a byte al enviado, diffs en `anexos/bandeja-errores/*.diff`.
- `validateExpression` detectó `fv!error` no disponible en `onError` de `a!startProcess` → mensaje genérico.
- `updateInterface` detectó que `a!gridField_25r3` no acepta `totalCount` → paginación con `a!dataSubset`.

## Pruebas

`testInterface` (API):

| Caso | Resultado |
|------|-----------|
| Bandeja sin filtros (23 pendientes reales) | renderiza sin error (238 ms); Relanzar solo en comandos con ruta; «Repetir la acción desde la tarea» en Posponer |
| Detalle 15787744 (error Posponer/CORE_OBSERVACIONES) | renderiza; Descartar sí, Relanzar no; Mensaje visible |
| Detalle con `idSolicitud` nulo | renderiza «La solicitud no tiene errores registrados.» |

Filas de prueba controladas insertadas en `SCA2 Error`: id 60 (`PRUEBA-ERR-01`, Decidir con sufijo) e
id 61 (`PRUEBA-ERR-02`, Posponer con sufijo).

Prueba UI (usuario administrador; `/errores` sigue siendo solo para administradores, JJGONZ2 no la ve): ver
`pruebas/11-bandeja-errores-informe-testing-agent.md`. Todo PASA: carga, contador, paginación, filtros
(Fecha desde tras v8), Relanzar de la fila 60 sin error `local!dummy` (banner verde, pasa a RELANZADO),
fila 61 sin Relanzar y Descartar → DESCARTADO, Ver solicitud / Volver a la bandeja, Errores del Detalle
15787744 y lista vacía. Tras la prueba se aplicó v9 (limpieza del banner, observación del informe),
validada con `testInterface`.

El relanzamiento de la fila 60 ejecutó realmente `SCA2 CMD Decidir` sobre la solicitud ficticia
`PRUEBA-ERR-01`, que registró 3 errores `DECISION_ERROR` (ids 62–64, reintentos del CMD: 2 PENDIENTE +
1 BLOQUEADO). Eso confirma que el comando se lanza de verdad. Al ser datos de prueba se marcaron
DESCARTADO tras la prueba.
