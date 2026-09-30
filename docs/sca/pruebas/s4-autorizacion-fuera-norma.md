# S4 — Decisión → Autorización (anulación fuera de norma): SCA vs SCA2 en TEST

Prueba de paridad funcional ejecutada el 30/09/2026 en `https://mapfrespain-test.appiancloud.com`
(usuario funcional `JJGONZ2`, perfil `RED MAPFRE` / `OFICINA`, canal `CE_RM`). SCA TEST es la
referencia funcional; solo se corrigen objetos de SCA2.

## 1. Pólizas y solicitudes creadas

| App | Póliza | idSolicitud | Combinación de alta | Gestiones CORE creadas |
|---|---|---|---|---|
| SCA (`sca-site`) | `2001900033136` | **15787698** | Motivo 4 `DECISIÓN DE LA ENTIDAD` → Detalle 9 `DECISIÓN DE LA ENTIDAD` → Causa 28 `ANULACIÓN FUERA DE NORMA`, catalogación 4 `A FECHA`, fecha anulación 30/09/2026 | Alta `43704809` (acción 8), Autorización `43704813` (acción 7) |
| SCA2 (`sca2`) | `2002000066389` | **15787703** | Idéntica | Alta `43704818` (acción 8), Autorización `43704820` (acción 7) |
| SCA2 (`sca2`), repetición tras corregir | `2002000024237` (reserva) | **15787714** | Idéntica | Alta `43704858` (acción 8), Autorización `43704859` (acción 7) |

La póliza de reserva se usó para repetir FINALIZAR en SCA2 tras la primera corrección del PM (§3.4). No se ha
tocado ninguna otra solicitud.

Ambas pólizas son NSE-Autos (`idLineaNegocio = 1`, compañía 41). El motor de reglas decidió en
ambas apps `Autorización` (nivel de intervención 1, grupo `CE_RM`), y la navegación tras el alta
llevó directamente a la pantalla «Revisión autorización de fecha de anulación».

## 2. Tabla paso a paso SCA vs SCA2

| # | Paso | SCA 15787698 | SCA2 15787703 | Veredicto |
|---|---|---|---|---|
| 1 | Alta (motivo 4 / detalle 9 / causa 28 / a fecha) | Alta OK, decisión Autorización, navegación directa a la pantalla de autorización | Igual | igual |
| 2 | Estado CORE inicial | `codEstSolic=2`, gestión 8 FINALIZADA, gestión 7 (`codEstGestion=FINALIZADA`, `fecFinGestion=null`, nivel 1); autorización `codEstado=1`, `mcaAutorizada=N`, `tipoAutorizacion=SI24` | Igual (gestiones 43704818/43704820) | igual |
| 3 | Estado SCA2 inicial | n/a | Solicitud `EN_ACCION` / `interfazActiva=AUTORIZACION` / `estadoTarea=PENDIENTE` / `grupoAsignacion=CE_RM` / nivel 1; Tarea id 20 `AUTORIZACION` PENDIENTE | igual (equivalente) |
| 4 | Pantalla de autorización: cabecera, pestañas, oficinas, fecha, botones | Pestañas Datos cliente/póliza/Solicitud Anulación/Otras sol./Datos contacto; selector oficina (MADRID CORREDORES NORTE II, VILLALBA); fecha 30/09/2026; CANCELAR / POSPONER / FINALIZAR | Igual; SCA2 añade «Notificaciones» y «VOLVER AL DETALLE» (diseño propio, ya documentado) | igual |
| 5 | Sección Documentación | Desplegada al abrir, línea separadora solo si está plegada | Antes: plegada y línea invertida → **corregido** (`SCA2_AnulacionFueraNormaPrincipal` v11) | divergencia_corregida |
| 6 | Tooltip / deshabilitado de FINALIZAR sin documentos | «Es necesario entregar los documentos que se precisan para poder continuar» | Antes: texto distinto y condición sobre `noEntregaDoc` → **corregido** (v11: `documentosEntregados = noEntregaDoc or documentosOk`) | divergencia_corregida |
| 7 | Pestaña «Solicitud Anulación» del detalle | Fechas `dd/MM/yyyy` de cabecera CORE, origen, estado y fecha estado de CORE | Antes: fecha con hora y CEST, estado/fecha de la fila SCA2 → **corregido** (`SCA2_SolicitudAnulacion` v5) | divergencia_corregida |
| 8 | Tarjeta de la gestión Autorización en el Detalle | Título «Gestiones realizadas»; tarjeta con estado CORE (Pendiente), fecha inicio, nivel, perfil, grupo, nuuma, centro emisor, nº situación Autemis, resultado, documentos y observaciones | Antes: encabezado vacío y tarjeta sin datos CORE → **corregido** (`SCA2_DetalleSolicitud` v18: la tarjeta Autorización lee `SCA2_consultaGestion` acción 7, `SCA2_consultarAutorizacion` y `SCA2_consultaDetalleGestion`) | divergencia_corregida |
| 9 | Cambio de nivel | No existe acción visible de «cambiar nivel/escalar» en la pantalla de autorización; el nivel lo fija el motor al alta | Igual: `SCA2 CMD CambiarNivel` existe como PM pero ninguna pantalla lo expone; `nivelIntervencion` permanece 1 en CORE y en `SCA2 Solicitud` | igual (no aplicable en este flujo) |
| 10 | REASIGNAR / RETOMAR antes de POSPONER | REASIGNAR → «La tarea se ha reasignado correctamente» → RETOMAR abre la tarea | RETOMAR visible (tarea asignada al creador) y abre la autorización | igual |
| 11 | POSPONER sin oficina | Bloqueado: «Seleccione oficina — Se requiere un valor» | Antes: guardaba `CORRECTO` sin oficina → **corregido** (`SCA2_selectorOficinas` v4 + `SCA2_AnulacionFueraNormaPrincipal` v13, ver §3) | divergencia_corregida (verificado en fase 3: mensaje rojo «Se requiere un valor» y sin `CORRECTO`) |
| 12 | POSPONER con oficina y observaciones | `CORRECTO`; CORE gestión 7 `observaciones = "Prueba S4 posponer"`; tras F5 sigue Pendiente y la tarjeta muestra la observación | Antes: `CORRECTO` pero CORE `observaciones = null` y tarjeta `-` → **corregido** (v12: el botón inserta observaciones en CORE con `tipoGestion "7"` como SCA); tras la corrección CORE muestra `"Prueba S4 posponer 2"` | divergencia_corregida |
| 13 | Botones tras POSPONER (vuelta al pool) | REASIGNAR visible | Tras el primer POSPONER no aparecía ningún botón (regla `SCA2_puedeGestionarTarea` excluía nivel 1); con la v3 de la regla (publicada por otra sesión durante la prueba) aparece REASIGNAR y RETOMAR funciona | divergencia_corregida (otra sesión) |
| 14 | RETOMAR tras POSPONER | «La tarea solicitada no está disponible…» (el proceso SCA sustituye la tarea al posponer y el detalle apunta a la antigua) | RETOMAR abre la autorización de `2002000066389` | divergencia_comun_sca (fallo del lado SCA; no se corrige) |
| 15 | FINALIZAR (autorizar) con oficina, fecha 30/09/2026, 2 PDF (tipos 7 y 8) y observación | `CORRECTO`; tras F5 la tarjeta Autorización muestra **Aceptada**, fecha fin, los 2 documentos y la observación `Prueba S4 finalizar` añadida a la anterior | `CORRECTO` en pantalla, pero tras F5 (y >4 min) la autorización sigue **Pendiente**, sin fecha fin ni documentos. Causa raíz: el PM `SCA2 CMD CompletarAccion` no aceptaba la autorización en CORE y, tras corregirlo, la instancia queda **pausada por excepción** en «Subir documentos GD» porque los adjuntos del site son temporales (§3.4). Corregido en `SCA2_AnulacionFueraNormaPrincipal` v15 (`a!submitUploadedFiles`) + PM; **pendiente de repetir** con un alta nueva | divergencia_pendiente |
| 16 | Estado final CORE / Detalle / buscador / F5 | CORE: autorización `codEstado=2`, `mcaAutorizada=S`, `fecAnulAutorizada=30/09/2026`; gestión 7 `FINALIZADA` con `fecFinGestion=12:43:12`; nueva gestión 5 (Mecanización) `43704856` `INCOMPLETA`; `codEstSolic=2`. Buscador SCA: Pendiente (la solicitud sigue viva hasta mecanizar) | 15787703: `SCA2 Solicitud` = `PDTE_MECANIZAR`/`procesoActivo MECANIZAR` (Decidir sí se ejecutó por la rama genérica), pero CORE sigue `codEstado=1`, sin gestión 5; buscador SCA2 «PDTE_MECANIZAR» vs SCA «Pendiente». 15787714: `EN_ACCION`/`AUTORIZACION`, tarea 25 `COMPLETADA`, CORE `codEstado=1`, sin transición ni fila `SCA2 Error` (proceso pausado) | divergencia_pendiente |
| 17 | FINALIZAR habilitado con un solo documento entregado | Habilitado (`documentosOk = or(documentoOk1..9)`) | Igual (mismo `SCA2_AccionesAdministrativasDocumentacion`, solo cambian constantes) | igual |
| 18 | Documentos registrados en CORE tras FINALIZAR (`consultarDocumentos`) | 2 documentos (tipos 7 y 8, Documentum `0900ab44…`) | `null` en 15787703 y 15787714 (los adjuntos se perdieron antes de llegar al GD) | divergencia_pendiente (misma causa que 15) |

## 3. Divergencias y correcciones en SCA2

Procedimiento por objeto: GET vivo → backup local JSON → edición mínima → PUT completo (con `inputs`) →
re-GET → `POST .../test` → repetición UI. SAIL antes/después guardado en local (`~/sca2work/live`,
`~/sca2work/backup`), no en el repositorio.

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_AnulacionFueraNormaPrincipal` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | 10 → 11 → 12 → 13 → 14 → 15 | v14: FINALIZAR inserta las observaciones en CORE (`tipoGestion "7"`) antes de lanzar el PM, como SCA. v15: FINALIZAR envuelve la acción en `a!submitUploadedFiles(onSuccess: …)` cuando hay adjuntos (§3.4). v11: documentación desplegada por defecto (`collapse1: true`, `horizontalLine(showWhen: not(collapse1))`) y tooltip/`disabled` de FINALIZAR con `documentosEntregados`. v12: POSPONER inserta observaciones en CORE (`SCA2_insertarObservaciones(..., tipoGestion: "7")`) antes de lanzar `SCA2 CMD Posponer`. v13: validación manual de oficina en POSPONER y FINALIZAR (`local!faltaOficina` → mensaje «Se requiere un valor»). |
| `SCA2_SolicitudAnulacion` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064988` | 4 → 5 | Fechas (`fecSolicitudAnul`, `fecEstado`), origen y estado de la solicitud tomados de la cabecera CORE (`left(tostring(...),10)`, `SCA_D_EstadosSolicitud`) con fallback a la fila SCA2. |
| `SCA2_DetalleSolicitud` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 17 → 18 | Encabezado «Gestiones realizadas»; la tarjeta de la acción Autorización se asocia a la gestión CORE `accionRealizada = "7"` y muestra estado (`SCA2_consultarAutorizacion.codEstado` → `SCA2_TXT_ESTADOS_AUTORIZACION`), fechas, nivel, perfil/grupo/nuuma, centro emisor, nº situación, resultado, documentos y observaciones (`SCA2_consultaDetalleGestion`). |
| `SCA2 CMD CompletarAccion` (PM) | `0000f06f-1307-8000-65b1-7f0000014e7a` | 12.0 → 15.0 (versión de proceso; LCP no expone `versionId` de PMs) | XOR 6 «Cancel?»: nueva condición `operacion="Autorizacion" and codEstado="2"` → nodo 310 «Subir documentos GD» (antes iba por el `defaultPath` a «Write Decidir» sin aceptar la autorización en CORE ni subir documentos). XOR 200 «¿Write fail?»: misma condición → nodo 11 «Write Decidir» tras «Aceptar Autorizacion». Backups en `~/sca2work/backup/pm/`. |
| `SCA2_selectorOficinas` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053256` | 1 → 2 → 3 → 4 | v2: input `validationGroup` (descartado: fuera de un formulario Appian no evalúa `required` y ocultaba el asterisco). v3: **versión rota durante ~3 min** (`if` con 4 parámetros; detectada por el test LCP y corregida de inmediato). v4: input `mensajeError` (Text) mostrado en rojo bajo el desplegable y limpiado al seleccionar oficina; se elimina `validationGroup`. |

### 3.1 Fragmentos relevantes

`SCA2_AnulacionFueraNormaPrincipal` v12/v13 — botón POSPONER:

```
saveInto: if(local!faltaOficina, a!save(local!mensajeOficina, "Se requiere un valor"), {
  /* Paridad SCA: las observaciones de POSPONER se insertan en CORE (tipoGestion "7") desde el botón */
  a!save(local!insertarObservacionesResponse,
    index(rule!SCA2_insertarObservaciones(nuuma: local!nuuma, codSolicitud: ri!idSolicitud,
          txtObservaciones: local!observaciones, tipoGestion: "7"), "success", false)),
  a!startProcess(processModel: cons!SCA2_PM_CMD_POSPONER, ...)
}),
```

con `local!faltaOficina: and(local!masDeUnaOficina, a!isNullOrEmpty(local!detalleOficina))` y
`rule!SCA2_selectorOficinas(..., mensajeError: local!mensajeOficina)`. El mismo `if` envuelve el
`saveInto` de FINALIZAR.

`SCA2_selectorOficinas` v4:

```
saveInto: {ri!detalleOficina, a!save(ri!mensajeError, null)}
...
a!richTextDisplayField(labelPosition: "COLLAPSED",
  value: a!richTextItem(text: ri!mensajeError, color: "NEGATIVE", size: "SMALL"),
  showWhen: and(length(ri!oficinas) > 1, a!isNotNullOrEmpty(ri!mensajeError)))
```

### 3.2 Por qué SCA valida la oficina y SCA2 no lo hacía

En SCA la pantalla es el formulario de una tarea de proceso: al pulsar un botón `submit` Appian
evalúa los `required` de todo el formulario. En SCA2 la misma interfaz se muestra dentro del Detalle
(página de site, sin formulario de tarea), donde `required: true` del desplegable no se evalúa y el
botón (con `validationGroup: "FechaDeAnulacion"`) no lo bloquea. Añadir el mismo `validationGroup`
al desplegable (v2) no sirvió: el diálogo de confirmación aparecía igual, se guardaba sin oficina y
además desaparecía el asterisco de obligatorio. Por eso la v4/v13 valida a mano y reproduce el
mensaje estándar «Se requiere un valor».

### 3.3 Causa raíz de las observaciones perdidas en POSPONER

`SCA2 CMD Posponer` (nodo *Write Posponer*) llama a `SCA2_insertarObservaciones` con
`tipoGestion: ""`; el servicio CORE devuelve `success=false` (comprobado con `POST .../test`
reproduciendo la llamada), por lo que nunca se persiste. SCA inserta las observaciones desde el propio
botón con `tipoGestion: "7"`. La corrección replica el botón SCA; el PM no se ha modificado (la llamada
embebida sigue fallando de forma inocua; se recomienda eliminarla en una revisión del PM).

### 3.4 Causa raíz de FINALIZAR: `CORRECTO` en pantalla pero autorización Pendiente

1. **Primera causa (PM).** En `SCA2 CMD CompletarAccion` el XOR «Cancel?» solo distinguía *Cancelado*
   (`finalizadoCA`/`mcaEstadoFinal` 9-3/`codEstado` 5) y *Autorizacion* (`estadoFinalizar = "6"`, que es el
   caso en que una Contra Anulación deriva a autorización). Una autorización **aceptada** (`operacion =
   "Autorizacion"`, `codEstado = "2"`) caía en el `defaultPath` → «Write Decidir» → `SCA2 CMD Decidir`, por eso
   15787703 pasó a `PDTE_MECANIZAR` en SCA2 sin que CORE registrase la aceptación (`SCA2_aceptarAutorizacion`
   nunca se llamaba) ni se subiesen los documentos. SCA, en cambio, ejecuta `SCAC_aceptarAutorizacion` y
   «SCA Subir Docs Documentum BBDD» en el formulario de la tarea. Corrección: nuevas condiciones en los XOR 6 y
   200 para encadenar `Subir documentos GD → Aceptar Autorizacion → Write Decidir` (tabla §3).
2. **Segunda causa (adjuntos temporales), detectada al repetir con 15787714.** Con el endpoint LCP
   `GET /process-models/{uuid}/processes` + `GET /processes/{id}` (y `/variables`) se localizó la instancia
   `17325135` (`idSolicitud 15787714`, `idTarea 25`) en estado `ACTIVE` pausada por excepción:

   ```
   Subir documentos GD: An error occurred while evaluating expression: docsResult:
   rule!SCA2_subirDocumentosGD(codSolicitud: pv!idSolicitud, listaNombreDocs: index(pv!resultado,"listaNombreDocs",{}), ...)
   (Expression evaluation error in rule 'sca2_subirdocumentosgd' at function a!forEach [line 23]: ... in rule
   'sca2_altadocumento' at function 'document' [line 27]: Document Does Not Exist or has been Deleted)
   ```

   `pv!resultado.listaNombreDocs = {"555703_8_15787714", "555704_7_15787714"}`. En SCA la pantalla es el
   formulario de una tarea y Appian consolida los ficheros de `a!fileUploadField` al enviar el formulario. En
   SCA2 la misma pantalla se muestra en una página del site (sin formulario): los ficheros quedan
   **temporales** y, al pasar sus ids como texto dentro de un `a!map` a `a!startProcess`, Appian no los
   persiste; cuando el PM los busca ya no existen. La misma excepción aparece en instancias de otras sesiones
   por la rama Contra Anulación (`11036933` → 15787716, `268956156` → 15787699), luego afecta a todas las
   pantallas SCA2 que adjuntan documentos.

   Corrección en `SCA2_AnulacionFueraNormaPrincipal` v15 (solo FINALIZAR):

   ```
   saveInto: if(local!faltaOficina, a!save(local!mensajeOficina, "Se requiere un valor"),
     if(a!isNullOrEmpty(local!listaNombreDocs),
       { /* insertarObservaciones + a!startProcess(SCA2_PM_CMD_COMPLETAR_ACCION, ...) + a!save(ri!onCompletar, true) */ },
       a!submitUploadedFiles(
         onSuccess: { /* mismo bloque */ },
         onError: a!save(local!mensaje, "No se han podido guardar los documentos adjuntos. Inténtelo de nuevo.")))),
   ```

   `POST /interfaces/{uuid}/test` con `idSolicitud 15787714 / idTarea 25` → 200, `error: null`. **La repetición
   UI de FINALIZAR con v15 + PM corregido queda pendiente**: 15787714 ya tiene la tarea `COMPLETADA` y su
   proceso pausado no puede reanudarse ni relanzarse por API (`POST /process-models/{uuid}/processes` → 501;
   no hay fila en `SCA2 Error` porque la excepción pausa el nodo en vez de ir al XOR «¿Docs GD ok?»), y no
   quedan pólizas asignadas.
3. Comportamiento de `SCA2_subirDocumentosGD` con ids inexistentes probado por LCP (`{"999999999_7"}`):
   devuelve `success=true, omitido=true, "Documento inexistente en Appian"`; con los ids reales del proceso,
   `CMP_existeObjeto` pasó pero `document()` en `SCA2_altaDocumento` falló, lo que confirma que el documento
   dejó de existir entre la subida y la ejecución del PM.

## 4. Estados CORE observados

### 4.1 Tras el alta (ambas apps)

`SCA2_consultarSolicitudes`: `codEstSolic = "2"`, `causaAnul = "ANULACIÓN FUERA DE NORMA"`,
`fecAnul = 30/09/2026`, `fecResolucion = null`.
`SCA2_consultaGestion`: acción 8 `FINALIZADA` (con `fecFinGestion`), acción 7 `codEstGestion = FINALIZADA`
con `fecFinGestion = null` (así lo devuelve CORE; no se reinterpreta), `nivelIntervencion = "1"`.
`SCA2_consultarAutorizacion`: `codEstado = "1"`, `mcaAutorizada = "N"`, `numSgo = "N"`, `tipoAutorizacion = "SI24"`.

### 4.2 Tras POSPONER

| Dato | SCA 15787698 (gestión 43704813) | SCA2 15787703 (gestión 43704820) |
|---|---|---|
| `codEstGestion` / `fecFinGestion` | FINALIZADA / null | FINALIZADA / null |
| `nivelIntervencion` | 1 | 1 |
| `observaciones` | `Prueba S4 posponer` | `null` tras el 1er POSPONER (divergencia) → `Prueba S4 posponer 2` tras la corrección v12 |
| `codEstSolic` | 2 | 2 |
| `SCA2 Solicitud` | n/a | `EN_ACCION` / `estadoTarea PENDIENTE` / `caducidadTarea 2026-10-07` / `contadorPosponer` incrementado / version 5 |
| `SCA2 Tarea` 20 | n/a | `PENDIENTE`, `asignadoA` vuelto a null (pool del grupo) |

### 4.3 Tras FINALIZAR

| Dato | SCA 15787698 | SCA2 15787703 (antes de corregir PM) | SCA2 15787714 (PM corregido, sin v15) |
|---|---|---|---|
| `SCA2_consultarAutorizacion.codEstado` / `mcaAutorizada` / `fecAnulAutorizada` | `2` / `S` / `30/09/2026` | `1` / `N` / null | `1` / `N` / null |
| Gestión 7 (`codEstGestion` / `fecFinGestion` / `observaciones`) | FINALIZADA / `30/09/2026 12:43:12` / `Prueba S4 posponer,Prueba S4 finalizar` | FINALIZADA / null / `Prueba S4 posponer 2` | FINALIZADA / null / `Prueba S4 finalizar v2` |
| Gestión 5 Mecanización | `43704856` INCOMPLETA, nivel 1 | no existe | no existe |
| `codEstSolic` / `fecAnul` | 2 / 30/09/2026 | 2 / 30/09/2026 | 2 / 30/09/2026 |
| `consultarDocumentos` | 2 documentos (tipos 7 y 8) | null | null |
| `SCA2 Solicitud` | n/a | `PDTE_MECANIZAR` / `procesoActivo MECANIZAR` / tarea PENDIENTE / version 7 | `EN_ACCION` / `AUTORIZACION` / version 3 |
| `SCA2 Tarea` | n/a | 20 `COMPLETADA` (+ tarea de mecanización) | 25 `COMPLETADA` |
| `SCA2 Transicion` (`SCA2_DetalleTransiciones`) | n/a | Alta, CrearAccion, Decidir, CompletarAccion→Decidir | solo Alta, CrearAccion, Decidir (ninguna de CompletarAccion) |
| `SCA2 Error` (`contarErroresPendientes`) | n/a | 0 | 0 |
| Instancia `SCA2 CMD CompletarAccion` | n/a | `15250872` COMPLETED (versión 12.0) | `17325135` ACTIVE, pausada en «Subir documentos GD» (versión 15.0) |

## 5. Limitaciones y pendientes

- LCP: `GET /process-models/{uuid}/processes`, `GET /processes/{id}` y `GET /processes/{id}/variables`
  **sí funcionan** (lista de instancias, estado, error de pausa y `pv!`); en cambio `POST .../processes`,
  `/processes/{id}/errors|nodes|tokens|history` y `/runtime/processes` devuelven 501. Las acciones de negocio se
  han ejecutado por UI y la lectura de CORE/records por `POST /expression-rules/{uuid}/test`.
- **Pendiente principal**: repetir FINALIZAR en SCA2 con `SCA2_AnulacionFueraNormaPrincipal` v15 y el PM
  corregido sobre un alta nueva (no quedan pólizas asignadas) y verificar: autorización Aceptada en CORE,
  documentos en `consultarDocumentos`, gestión 5 Mecanización creada, tarjeta/buscador/F5 iguales a SCA.
- La misma corrección (`a!submitUploadedFiles`) hace falta en `SCA2_ContraAnulacionPrincipal` y
  `SCA2_AccionesAdministrativasPrincipal` (sus instancias de CompletarAccion 268956156 y 11036933 están
  pausadas por la misma excepción); no se han tocado por pertenecer a otros escenarios.
- Quedan en TEST estados inconsistentes de las solicitudes de prueba: 15787703 (`PDTE_MECANIZAR` en SCA2 con
  autorización Pendiente en CORE) y 15787714 (tarea completada, proceso `17325135` pausado). Reanudar/cancelar
  esas instancias requiere el monitor de procesos de Appian Designer.
- Buscador SCA2: la columna Observaciones muestra `-` para 15787703/15787714 aunque CORE tiene observaciones
  (la tarjeta del Detalle sí las muestra). No se ha comprobado qué columna equivalente muestra el listado SCA.
- No hay endpoint LCP de datos de record types (`/record-types/{uuid}/records` → 501): `SCA2 Tarea`
  y `SCA2 Transicion` se han observado a través de `SCA2_cargarSolicitud`, `SCA2_obtenerTareasSolicitudAlta`
  y de la UI; la bandeja `/errores` del site SCA2 devolvió 403 al usuario funcional, por lo que no se
  puede afirmar que no existan filas en `SCA2 Error` para estas solicitudes.
- `SCA2 CMD CambiarNivel` no está expuesto en ninguna pantalla de SCA ni de SCA2 en este flujo; el
  cambio de nivel no se ha podido probar de extremo a extremo (no existe la acción equivalente en SCA).
- SCA: tras POSPONER, RETOMAR desde el Detalle abre una tarea ya sustituida («La tarea solicitada no está
  disponible»); es comportamiento del SCA original, no se corrige.
- `SCA2 CMD Posponer` sigue llamando a `SCA2_insertarObservaciones` con `tipoGestion ""` (inocuo, falla
  siempre); conviene limpiarlo en el PM. SCA además registra el POSPONER en SGC
  (`SCA_posponerAutorizacion` → `SCA_guardarGestionSGC` con la oficina); SCA2 no llama a SGC al posponer
  (`SCA2_guardarGestionSGC` existe pero no se usa en `SCA2 CMD Posponer`). No se ha corregido: requiere
  decisión funcional (ver preguntas).
- Diferencias de presentación no corregidas (diseño propio SCA2 ya documentado): «Notificaciones» y
  «VOLVER AL DETALLE», ancho/distribución de cabecera, «Fecha estado» en otra columna, `-` en lugar de
  vacío para «Fecha fin de gestión».
- La versión 3 de `SCA2_selectorOficinas` estuvo rota unos minutos en TEST (afecta también a las pantallas
  de Acciones Administrativas y Contra Anulación de SCA2 que la reutilizan); se corrigió con la v4 y los
  cuatro casos de test (2 oficinas con/sin mensaje, 1 oficina, 0 oficinas) devuelven 200 sin error.

## 6. Evidencias (no incluidas en el repo)

Grabaciones (`~/screencasts/<nombre>/<nombre>-edited.mp4`, anotadas):

| Grabación | Contenido | Capturas |
|---|---|---|
| `s4-fase1` | Alta SCA 15787698 y SCA2 15787703, pantalla de autorización inicial (pestañas, documentos, tooltip), detalles cruzados, F5, bandeja `/errores` (403) | `s4-00` … `s4-20` |
| `s4-fase2a` | Detalle corregido (v5/v18), sin cambio de nivel, REASIGNAR/RETOMAR SCA, POSPONER SCA con validación de oficina, POSPONER SCA2 sin oficina (`CORRECTO`, divergencia), estados tras F5 | `s4-21` … `s4-47` |
| `s4-fase2b` | REASIGNAR/RETOMAR SCA2, POSPONER sin oficina con v2 del selector (sigue sin validar) | `s4-50` … `s4-57` |
| `s4-fase2b-continuacion` | POSPONER SCA2 con oficina + observación 2 (v12), RETOMAR SCA no disponible, error de expresión al volver en SCA, búsquedas cruzadas | `s4-58` … `s4-70` |
| `s4-fase3` | Validación oficina v13 en SCA2, FINALIZAR SCA (Aceptada, docs, fecha fin) y FINALIZAR SCA2 15787703 (`CORRECTO` pero Pendiente tras F5), buscador PDTE_MECANIZAR vs Pendiente | `s4-71` … `s4-91` |
| `s4-fase4` | Alta SCA2 15787714 con la reserva, FINALIZAR con PM corregido: `CORRECTO`, pero Pendiente tras >2 min; referencia SCA aceptada | `s4-92` … `s4-106` |

Capturas: `~/sca2work/capturas/s4-NN-<app>-<pantalla>.png` (113 ficheros, también en `~/sca2work/s4-faseN-capturas.zip`).
Estados de procesos: `~/sca2work/proceso_<id>.json` y `procesos_completaraccion.json`. SAIL antes/después:
`~/sca2work/live/`, `~/sca2work/backup/`.

## 7. Preguntas para el analista

- ¿Debe SCA2 registrar el POSPONER en SGC (`SCA2_guardarGestionSGC`) como hace `SCA_posponerAutorizacion`?
- Tras aceptar la autorización, SCA crea la gestión 5 Mecanización (`INCOMPLETA`) y la solicitud sigue
  «Pendiente» en el buscador; SCA2 muestra «PDTE_MECANIZAR». ¿Se acepta esa etiqueta propia o debe mostrar
  el estado CORE («Pendiente») como SCA?
- ¿Se propaga `a!submitUploadedFiles` a Contra Anulación y Acciones Administrativas de SCA2 (misma causa)?
