# R24-D — Batch NSE (desactivado), validación de subida al SGD y desincronizaciones CORE ↔ SCA2 en la bandeja de errores

Ronda 24 (respuestas del analista en `docs/sca/43-ronda24-respuestas-analista.md`, puntos **#14**, **#16** y **#17**). Entorno: Appian TEST (`mapfrespain-test`), aplicación SCA2. Fecha: 21/10/2026.

> Resumen para el analista: (1) el batch nocturno de NSE existe ya en SCA2 pero está **apagado** por una constante y no tiene temporizador; (2) al finalizar una acción con documentos, SCA2 comprueba ahora que el gestor documental devolvió una referencia real y que CORE la tiene registrada; si no, la tarea vuelve a la oficina con un aviso para volver a adjuntar; (3) las desincronizaciones CORE/SCA2 (como la solicitud 15788025) quedan como una fila visible en la bandeja de errores y se resuelven desde allí.

## 1. Objetos tocados y versiones

| Objeto | Tipo | UUID | Antes → Después | Tarea |
|---|---|---|---|---|
| `SCA2_BOOL_BATCH_NSE` | Constante (Boolean) | `_a-0000f093-2064-8000-9d36-011c48011c48_5605022` | **nueva**, valor `false` | #14 |
| `SCA2_PM_ANL_FINALIZAR_MECANIZACION` | Constante (PM) | `_a-0000f093-2064-8000-9d36-011c48011c48_5605266` | nueva → PM ANL `ANL OS FinalizarMecanizacion` (`0012eabd-4050-8000-bc63-7f0000014e7a`) | #14 |
| `SCA2 CMD MecanizarNSE` | Modelo de proceso | `0000f095-7c8e-8000-d60a-7f0000014e7a` | **nuevo** (v1.0, 28 nodos) | #14 |
| `SCA2_PM_CMD_MECANIZAR_NSE` | Constante (PM) | `_a-0000f093-2064-8000-9d36-011c48011c48_5605273` | nueva | #14 |
| `SCA2 Batch Mecanizacion NSE` | Modelo de proceso | `0000f095-7c92-8000-d60c-7f0000014e7a` | **nuevo** (v1.0, 7 nodos), sin temporizador | #14 |
| `SCA2_BandejaErrores` | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055578` | v10 → **v11** (`SCA2 CMD MecanizarNSE` relanzable) | #14/#17 |
| `SCA2_DetalleErrores` | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055566` | v4 → **v5** (ídem) | #14/#17 |
| `SCA2 CMD MarcarErrorRelanzado` | Modelo de proceso | `0000f073-49f2-8000-d0e7-7f0000014e7a` | + rama `MecanizarNSE` (nodo 17 *Start MecanizarNSE*) | #14 |
| `SCA2_subirDocumentosGD` | Regla | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351` | v8 → v9 (validación de referencia SGD + CORE) → **v11** (acepta el id resuelto por el SGD; versionId 11 en Designer) | #16 |
| `SCA2_AccionesAdministrativasPrincipal` | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | v22 → **v23**: aviso rojo si hay `DOC_GD_FAIL` pendiente | #16 |
| `SCA2 CMD RegistrarDesincronizacion` | Modelo de proceso | `0000f095-791c-8000-d602-7f0000014e7a` | **nuevo** (v3.0: formulario + guarda + escritura en `SCA2 Error`) | #17 |
| `SCA2_RegistrarDesincronizacionForm` | Interfaz | `_a-0000f093-2064-8000-9d36-011c48011c48_5605245` | nueva (formulario de arranque, uso administrador) | #17 |
| `SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION` | Constante (PM) | `_a-0000f093-2064-8000-9d36-011c48011c48_5605082` | nueva | #17 |

No se ha tocado ningún objeto de las otras sesiones (`SCA2 CMD Mecanizar`, `SCA2_AltaSolicitudPage`, reglas de consulta de póliza, `SCA2_DetalleSolicitud`, `SCA2_ContraAnulacionOpciones`), ni SCA/SCAC/CORE/ANL/GAIA/PRE/Documentum. Todas las escrituras se hicieron con backup local previo, PUT mínimo y relectura/comparación (iguales).

Hallazgo de herramienta: **la API LCP de TEST sí permite crear modelos de proceso nuevos** (`POST /process-models` con `appUuid`, `parentFolderUuid`, `errorAlertGroupUuid`, `nodes`, `processVariables`), al contrario de lo anotado en rondas anteriores. No permite: validar (`/validate` → 501), arrancar instancias (`/processes` → 501) ni evaluar reglas (`/run` → 501); eso se hizo desde Appian Designer (usuario `devin`, «Iniciar proceso para depuración»).

## 2. #14 — Batch NSE propio de SCA2 (desactivado)

### 2.1 Qué hace (funcional)
En SCA, un proceso nocturno (`SCA Batch Mecanizacion NSE`) repasa en CORE las solicitudes con la mecanización pendiente, descarta las wAutemis y, según la póliza esté **vigente** o **anulada**, deja la mecanización en estado 4 con la autorización **rechazada** (vigente) o **aceptada** (anulada; además finaliza la solicitud en CORE e inserta las observaciones de post-anulación en ANL) y cierra la instancia de ANL.

SCA2 tiene ahora su equivalente, siguiendo el diseño ya propuesto en `29-respuestas-analista-ronda11.md §3`:

- **`SCA2 Batch Mecanizacion NSE`** (orquestador, sin temporizador). Primer nodo: *¿Batch activo?* → lee la constante **`SCA2_BOOL_BATCH_NSE`**; con `false` (valor actual) termina sin hacer nada. Si algún día se activa: lee del record `SCA2 Solicitud` las solicitudes con `estadoSolicitud = MECANIZADA`, `procesoActivo = ANL` y `origenPoliza ∈ {NSE-Autos, NSE-Hogar}` (máx. 500) y lanza, una a una, el comando `SCA2 CMD MecanizarNSE`. No barre CORE, por lo que sólo toca solicitudes creadas en SCA2.
- **`SCA2 CMD MecanizarNSE`** (comando por solicitud, relanzable desde la bandeja, idempotente por `SCA2 Transicion` con clave `SCA2 CMD MecanizarNSE|idSolicitud|version`):
  1. *Cargar* (`SCA2_cargarSolicitud`, `SCA2_obtenerAnulacion`) → *¿Aplica?*: termina si ya se ejecutó o si la solicitud no está `MECANIZADA/ANL/NSE` o la póliza es wAutemis (`SCA2_obtenerTipoPoliza`).
  2. *Consultar póliza* (`SCA2_polizaVigente`, `NUMERO_SUPLEMENTO` de ANL, `centro_emisor` de `SCA2_consultarEquipos`).
  3. Vigente → `actualizarMecanizacion` (`SCA2_construirConsultaActualizarMecanizacion`, `polizaVigente = "V"`, estado 4) + `crearAutorizacion` (`mcaAutorizada = "N"`, `codEstado = "3"`).
     Anulada → `actualizarMecanizacion` (`"A"`, estado 4) + `crearAutorizacion` (`mcaAutorizada = "S"`, `codEstado = "2"`, `fecAnulAutorizada = hoy`) + `finalizarSolicitud` CORE + `ANL_PM_INSERTAR_OBSERVACIONES` con `ANL_mapObservaciones_PostAnulacionNSE`.
  4. *Cerrar instancia ANL* (`ANL OS FinalizarMecanizacion`, el mismo subproceso que usa el batch de SCA; constante `SCA2_PM_ANL_FINALIZAR_MECANIZACION`).
  5. Transición del record: anulada → `FINALIZADA` (misma escritura que `SCA2 CMD Finalizar`); vigente → mismo cambio de nivel que `SCA2 CMD Mecanizar` (`mecanizacionRealizada`, `procesoActivo = IR A NIVEL n+1`) y arranque de `SCA2 CMD CrearAccion`.
  6. Cualquier fallo (póliza sin estado V/A, mecanización, autorización, finalizar, escritura) → fila en `SCA2 Error` con comando `SCA2 CMD MecanizarNSE` (códigos `POLIZA_ESTADO_DESCONOCIDO`, `MECANIZACION_FAIL`, `AUTORIZACION_FAIL`, `FINALIZAR_FAIL`, `WRITE_FAIL`) y payload con las respuestas de CORE. La bandeja (v11) y el detalle (v5) lo muestran como «Automático» y `SCA2 CMD MarcarErrorRelanzado` lo relanza con `relanzado = true`.

Diferencias/decisiones respecto al batch de SCA (para el analista):
- El batch de SCA pone `codEstMecanizacion = "1"` en la rama anulada (aunque la documentación dice 4). SCA2 usa **4 en ambas ramas**, como pidió el analista; si se quiere paridad exacta con SCA basta cambiar `polizaVigente`/estado en el nodo *Preparar anulada*.
- SCA2 no reintenta 3 veces las integraciones del batch: un fallo deja fila en la bandeja y se relanza desde allí (patrón general de SCA2).
- Con `SCA2 CMD Mecanizar` (R23-A) esperando ya la respuesta de ANL, el batch sólo encontraría solicitudes que se quedaron en `MECANIZADA/ANL` (p. ej. por el corte de 24 h). Sigue abierta la pregunta de `29 §3`: si conviven los dos batch, el de SCA ya cierra en CORE las solicitudes de SCA2 y el de SCA2 sólo sincronizaría el record.

### 2.2 Prueba realizada (batch apagado)
1. Constante `SCA2_BOOL_BATCH_NSE = false` (creada así).
2. Designer → `SCA2 Batch Mecanizacion NSE` → *Iniciar proceso para depuración* (usuario `devin`, 21/10/2026 13:56 CEST, instancia `16444058`).
3. Resultado: la instancia recorre **Start → ¿Batch activo? → End** en 0,8 s (`startTime 11:56:01.870Z`, `endTime 11:56:02.660Z`, `COMPLETED`); los nodos *Cargar solicitudes*, *Siguiente solicitud* y *Start SCA2 CMD MecanizarNSE* no se ejecutan. Ninguna llamada a CORE/ANL; `SCA2 Solicitud`, `SCA2 Transicion` y `SCA2 Error` sin cambios. Captura: `evidencias/r24d-batch-nse-desactivado-primer-nodo.png` (monitorización) y `evidencias/r24d-batch-nse-modelo-sin-errores.png` (el modelo no tiene errores de validación).
4. No se ha activado la constante ni se ha lanzado `SCA2 CMD MecanizarNSE` contra ninguna solicitud real (orden del analista: «déjalo desactivado»). El modelo `SCA2 CMD MecanizarNSE` está validado por el diseñador (sin errores) pero **no ejecutado**.

Para activarlo en el futuro: poner `SCA2_BOOL_BATCH_NSE = true` y añadir un temporizador al nodo Start (p. ej. diario 02:00) o lanzarlo a mano desde Designer. Antes conviene probarlo con una solicitud NSE nueva dejada en `MECANIZADA/ANL`.


## 3. #16 — Validación de la subida al SGD (Documentum) al finalizar una acción

### 3.1 Qué cambia (funcional)
Hasta ahora, al pulsar **FINALIZAR** en Contra Anulación / Acciones Administrativas con documentos adjuntos, SCA2 daba la acción por terminada en cuanto el gestor documental (SGD) y el registro en CORE respondían «OK», sin comprobar qué referencia se había guardado (R21 descubrió 5 solicitudes con el nº de solicitud grabado como referencia). Ahora, en `SCA2_subirDocumentosGD`, para cada documento:

1. Se sube al SGD (`SCA2_altaDocumento`) y se registra en CORE (`SCA2_modificarCrearDocumentos*`) como antes (hasta 3 intentos).
2. **Nuevo**: la referencia devuelta por el SGD debe ser un id Documentum real: 16 caracteres y distinta del nº de solicitud (`refValida`).
3. **Nuevo**: se consulta CORE (`SCA2_consultarDocumentos`) y la referencia tiene que aparecer en la lista de documentos de la solicitud (`coreOk`). CORE guarda la referencia tal cual se registró (p. ej. `c29381a15e60e07e`), pero `SCA2_consultarDocumentos` la devuelve ya **resuelta** por el buscador del SGD (`SCA2_searchDocumentos`, `QUERY_SCA_AGD_001` → `0900ab4481a0cc22`, el `r_object_id` del documento), por lo que la regla acepta cualquiera de las dos (v11).
4. Si falla 2 o 3, el documento **no** se da por subido (`success = false`): `SCA2 CMD CompletarAccion` no completa la acción, deja la fila `DOC_GD_FAIL` en `SCA2 Error` (como ya hacía con los fallos de subida) y la pantalla muestra el error con la instrucción «Vuelva a adjuntar el documento y pulse FINALIZAR». La tarea sigue abierta y la oficina puede reintentar sin pasar por la bandeja.
5. En Acciones Administrativas (`SCA2_AccionesAdministrativasPrincipal` v23) se muestra además un aviso rojo al entrar si la solicitud tiene un `DOC_GD_FAIL` pendiente, con el mensaje del último error.

SAIL relevante (`SCA2_subirDocumentosGD` v11, dentro del `a!forEach` por documento):
```sail
local!refValida: and(a!isNotNullOrEmpty(local!idRef), len(tostring(local!idRef)) = 16, tostring(local!idRef) <> tostring(ri!codSolicitud)),
local!coreDocs: if(and(local!gdOk, local!bbddOk, local!refValida), rule!SCA2_consultarDocumentos(codSolicitud: ri!codSolicitud), null),
local!idRefResuelto: if(and(local!gdOk, local!bbddOk, local!refValida),
  tostring(a!defaultValue(index(rule!SCA2_searchDocumentos(query: "QUERY_SCA_AGD_001", idDocumento: tostring(local!idRef)), 1, null), local!idRef)), null),
local!coreDocsJson: tostring(a!toJson(local!coreDocs)),
local!coreOk: if(and(local!gdOk, local!bbddOk, local!refValida),
  or(search(tostring(local!idRef), local!coreDocsJson) > 0, and(a!isNotNullOrEmpty(local!idRefResuelto), search(local!idRefResuelto, local!coreDocsJson) > 0)), false),
...
success: and(local!gdOk, local!bbddOk, local!refValida, local!coreOk),
refValida: local!refValida, idReferenciaResuelta: local!idRefResuelto, coreOk: local!coreOk,
error: a!match(... not(local!refValida), "Referencia SGD no válida para el documento … debe ser un id Documentum de 16 caracteres distinto del nº de solicitud. Vuelva a adjuntar el documento y pulse FINALIZAR",
               not(local!coreOk), "La referencia SGD … (resuelta …) del documento … no consta registrada en CORE (consultarDocumentos). Vuelva a adjuntar el documento y pulse FINALIZAR", ...)
```
El resultado global (`success`) sigue siendo `and()` de todos los documentos, así que basta un documento no verificado para no completar la acción. No se ha tocado `SCA2 CMD CompletarAccion` (ya trataba `success = false` como `DOC_GD_FAIL` y devolvía el error a la pantalla).

### 3.2 Prueba paso a paso (solicitud nueva 15788209)
Usuario `JJGONZ2` (SSO NO PRO), ventana de incógnito; póliza **0005726683648** (libre en SCA2 y en CORE, lista «Wautemis que derivan» de R23-C); PDF sintético `prueba_r24d_sgd.pdf` (602 bytes, 1 página «R24-D prueba SGD 2026-10-21»). No se han tocado los 5 documentos históricos ni las solicitudes protegidas.

| Paso | Acción | Resultado |
|---|---|---|
| 1 | Buscador → ALTA SOLICITUD ANULACIÓN → póliza 0005726683648 → BUSCAR | Ficha CESEFOZO SARXERVADO VIAG (97650347Y), Automóviles; aviso «acuerdo especial, debe gestionarla SI24» |
| 2 | Motivo DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, PRESENCIAL, A VENCIMIENTO (28/03/2028), observaciones «Prueba R24-D validacion subida SGD (Devin)» → GUARDAR → aviso NEW simulación → ACEPTAR | Solicitud CORE **15788209** (14:08:39), record `SCA2 Solicitud` 260 `EN_ACCION / CONTRAANULAR`; abre la Contra Anulación |
| 3 | Contra anulación: oficina VILLALBA; Documentación → **+** Carta firmada → CARGAR `prueba_r24d_sgd.pdf` → AÑADIR | Carta firmada «Entregado ✔ 21/10/2026» (doc Appian 569600) |
| 4 | Argumento 1 INCREMENTO PRIMA PLATINO (obligatorio) → NEGATIVO | Argumento ejecutado «Negativo» |
| 5 | FINALIZAR → «Se van a finalizar las acciones de contra anulación» → SÍ (**regla v10**, antes de la corrección de 3.1 §3) | Pantalla de error: «Se ha producido un error al finalizar la contra anulación: Error subiendo documentos: La referencia SGD **c29381a15e60e07e** del documento 569600 no consta registrada en CORE (consultarDocumentos). Vuelva a adjuntar el documento y pulse FINALIZAR. El error queda registrado en la bandeja de errores para su relanzamiento.» → ACEPTAR vuelve a la Contra Anulación con la carta aún adjunta. Fila **121** en `SCA2 Error` (`SCA2 CMD CompletarAccion` / `Subir documentos GD` / `DOC_GD_FAIL`, PENDIENTE, payload con `listaNombreDocs = 569600_6_15788209`). |
| 6 | Diagnóstico (LCP, test-cases temporales ya borrados): `SCA2_consultarDocumentos(15788209)` → `[{idDocumento=0900ab4481a0cc22, tipo 6, 2026-10-21}]`; `SCA2_searchDocumentos("QUERY_SCA_AGD_001", "c29381a15e60e07e")` → `0900ab4481a0cc22` | La referencia **sí** estaba en CORE: la regla la comparaba con el id ya resuelto por el SGD → falso negativo. Corregido en **v11** (acepta ref registrada o id resuelto). |
| 7 | En la misma pantalla (sin volver a adjuntar): FINALIZAR → SÍ (**regla v11**) | «CORRECTO. Los datos se han guardado correctamente» → ACEPTAR → buscador. `SCA2_consultarDocumentos(15788209)` → `[{idDocumento=0900ab4481a0cf66, tipo 6, 2026-10-21}]` (nueva subida; CORE conserva un documento por tipo). `SCA2 Solicitud` 260 → `EN_ACCION / CONTRA ANULAR NIVEL 2 / nivel 2` (acuerdo especial SI24). **Sin filas nuevas** en `SCA2 Error`. |
| 8 | Detalle de la solicitud → Contra Anulacion (Finalizada Negativa) → Documentos → ojo | Ver 3.3. |

Capturas: `evidencias/r24d-16-01-buscador-jjgonz2.png`, `-02-alta-formulario.png`, `-03-alta-aviso-new-simulacion.png`, `-04-contraanulacion.png`, `-05-adjuntar-carta-firmada.png`, `-05b-carta-firmada-adjunta.png`, `-06-argumento-negativo.png`, `-07-error-referencia-no-en-core.png` (la pantalla de error de #16), `-08-tras-aceptar-vuelve-a-ca.png`, `-09-reintento-correcto.png`, `-09b-correcto-aceptar.png`, `-12-bandeja-fila121-doc-gd-fail.png` (la fila en la bandeja, usuario administrador), `-13-bandeja-fila121-descartada.png`.

Sobre la simulación de un fallo: no hizo falta forzar la rama de error, el primer intento la recorrió de verdad (paso 5) y mostró exactamente el comportamiento pedido por el analista (error claro en pantalla, posibilidad de reintentar y fila en la bandeja). La rama «referencia = nº de solicitud» (el fallo original de R21) queda cubierta por `refValida` pero no se ha podido reproducir porque el SGD de TEST responde ahora correctamente.

### 3.3 Comprobaciones finales (15788209)
- Detalle de la solicitud → *Contra Anulacion* (Finalizada Negativa) → **Documentos presentados por el cliente**: `Carta firmada · Referencia 0900ab4481a0cf66 · 21/10/2026`; el **ojo** abre el PDF sintético («R24-D prueba SGD 2026-10-21») en el visor (`evidencias/r24d-16-10-detalle-referencia-0900ab4481a0cf66.png`, `r24d-16-11-ojo-abre-pdf.png`).
- Referencia en CORE: 16 caracteres, ≠ 15788209, coincide con el documento abierto (la referencia es la resuelta por el SGD, la misma que muestra SCA).
- `SCA2 Error`: una sola fila de la solicitud (121, `DOC_GD_FAIL` del primer intento con la regla v10). Tras el reintento correcto no se genera ninguna fila. La 121 se descarta desde la bandeja (es un dato de esta prueba) — ver §5.
- Efecto colateral del reintento: el PDF se ha subido **dos veces** al SGD (`c29381a15e60e07e` y la del segundo intento); CORE sólo conserva la última por tipo de documento. Es el mismo comportamiento que tendría la oficina al reintentar tras un fallo real; la reutilización de la referencia previa (`refPrevia`, R21) sólo aplica cuando el relanzamiento viene de la bandeja con `idDoc_tipo_<ref16>`.
- **No probado**: el aviso rojo de `SCA2_AccionesAdministrativasPrincipal` v23 (la póliza derivó a Contra Anulación, no a Acciones Administrativas; ninguna de las pólizas libres de la lista deriva a AA). El SAIL del aviso es una consulta al record `SCA2 Error` (`idSolicitud = ri!…`, `codigo = "DOC_GD_FAIL"`, `estado = "PENDIENTE"`) y un `a!messageBanner`/`richText` de error, sin lógica adicional; queda pendiente de verlo en pantalla con una solicitud que pase por AA.

## 4. #17 — Desincronización CORE ↔ SCA2 → bandeja de errores

### 4.1 Caso 15788025
CORE tiene la solicitud **anulada** (gestión CORE 43705728) mientras `SCA2 Solicitud` (id 181, versión 8) la mantiene en `PDTE_MECANIZAR / procesoActivo = MECANIZAR / estadoTarea = PENDIENTE` («Incompleta» en pantalla). Decisión del analista: «se tienen que quedar reflejados en la traza de errores de SCA y resolverlos por ahí manualmente». **No** se ha relanzado ni finalizado la solicitud: sólo se ha registrado la fila.

Fila creada en `SCA2 Error` (**id 120**, PENDIENTE, 21/10/2026 13:51 CEST):
- `idSolicitud = 15788025`, `comando = SCA2 CMD Mecanizar` (el comando que debería haber dado el paso), `nodo = Desincronizacion CORE/SCA2`, `codigo = DESINCRONIZACION_CORE`.
- `mensaje = Desincronización CORE/SCA2: CORE=ANULADA en CORE (gestion CORE 43705728) / SCA2=PDTE_MECANIZAR / procesoActivo=MECANIZAR / estadoTarea=PENDIENTE / version 8 (pantalla: Incompleta). R24-D #17 (decision analista): CORE ya tiene hecha la anulacion que SCA2 aun considera pendiente de mecanizar. Caso registrado manualmente para resolverlo desde la bandeja (Relanzar/Descartar). NO relanzar ni finalizar a mano sin revisar CORE.`
- `payload` JSON con `estadoCore`, `estadoSca2`, póliza `0000253500305`, origen `wAutemis`, gestión CORE `43705728`, record SCA2 id 181.

Se ve en *Errores* del site `sca2` (usuario administrador) como primera fila, con `Relanzamiento = Automático` y botones **Relanzar / Descartar** (`evidencias/r24d-bandeja-fila-15788025-desincronizacion.png`).

### 4.2 Cómo se registra (mecanismo reutilizable)
- **`SCA2 CMD RegistrarDesincronizacion`** (PM nuevo, v3): `Start (formulario) → ¿Datos válidos? → Write Error desincronización → End`. Parámetros: `idSolicitud` (obligatorio), `comandoOrigen`, `estadoCore`, `estadoSca2`, `detalle`, `datos` (payload adicional). El XOR termina sin escribir si falta `idSolicitud` (en el primer arranque de prueba, sin formulario, se creó la fila vacía 119, ya **descartada** desde la bandeja: `evidencias/r24d-bandeja-fila119-descartada.png`).
- **`SCA2_RegistrarDesincronizacionForm`**: formulario de arranque (Designer → *Iniciar proceso*; o acción de administrador si se publica en el site) para registrar un caso a mano (`evidencias/r24d-form-registrar-desincronizacion.png`, `r24d-registrar-desinc-15788025-ejecutado.png`).
- **`SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION`**: constante para arrancarlo desde cualquier comando (`a!startProcess` / subproceso) cuando éste detecte que CORE ya está más avanzado.

Expresión de la fila (nodo *Write Error desincronización*):
```sail
a!writeRecords(records: 'recordType!SCA2 Error'(
  idSolicitud: pv!idSolicitud, comando: a!defaultValue(pv!comandoOrigen, "SCA2 CMD RegistrarDesincronizacion"),
  nodo: "Desincronizacion CORE/SCA2", codigo: "DESINCRONIZACION_CORE",
  mensaje: "Desincronización CORE/SCA2: CORE=" & pv!estadoCore & " / SCA2=" & pv!estadoSca2 & if(a!isNotNullOrEmpty(pv!detalle), ". " & pv!detalle, ""),
  payload: a!toJson(a!map(estadoCore: pv!estadoCore, estadoSca2: pv!estadoSca2, datos: pv!datos, registradoPor: loggedInUser(), fecha: now())),
  intentos: 1, estado: "PENDIENTE", fechaCreacion: now()))
```

### 4.3 Regla general en los comandos (propuesta, pendiente de aplicar)
Pedido: «cuando un comando de SCA2 detecte que CORE ya tiene hecho lo que va a hacer, deje una fila de error visible en vez de quedarse en silencio». El mecanismo (4.2) está listo; los puntos donde hay que invocarlo son, en cada caso, el `XOR` que hoy «salta» en silencio:

| Comando | Punto | Hoy | Propuesta |
|---|---|---|---|
| `SCA2 CMD Mecanizar` (**R23-A, no tocado**) | `guardarMecanizacion` / `actualizarMecanizacion` devuelve fault «solicitud ya finalizada/anulada», o `SCA2_consultarSolicitudes` da `codEstSolic = 4` antes de mecanizar | continúa o se queda sin tarea | `Start SCA2 CMD RegistrarDesincronizacion` (`comandoOrigen = "SCA2 CMD Mecanizar"`, estados) y terminar sin tocar el record |
| `SCA2 CMD Finalizar` | `finalizarSolicitud` CORE responde que ya estaba finalizada | se trata como éxito | registrar desincronización informativa (no bloquea) |
| `SCA2 CMD CompletarAccion` | alta/finalización de gestión CORE devuelve «gestión ya finalizada» (fault 4115 y similares) | R23-C ya lo omite (`imprRes.omitida`) | registrar desincronización informativa |
| `SCA2 CMD MecanizarNSE` (nuevo) | póliza ni vigente ni anulada / CORE ya finalizada | fila `POLIZA_ESTADO_DESCONOCIDO` / `FINALIZAR_FAIL` | ya deja fila; usar `DESINCRONIZACION_CORE` cuando el fault sea «ya finalizada» |

No se ha modificado ninguno de esos comandos en esta sesión (R23-A trabaja en `Mecanizar`; `Finalizar`/`CompletarAccion` exigirían cambiar lógica funcional fuera del alcance indicado). Queda como pendiente para el padre.

### 4.4 Cómo resuelve el administrador una desincronización desde la bandeja
1. Abrir *Errores* (site `sca2`, administradores), filtro *Comando* o *Solicitud*; la fila `DESINCRONIZACION_CORE` lleva en el mensaje los dos estados y en *Ver solicitud* el detalle.
2. Comprobar en CORE (Detalle → gestiones, o SCA) qué está hecho realmente.
3. **Descartar** (botón existente): si CORE ya tiene la operación hecha y SCA2 sólo está «atrasado» en pantalla → la fila pasa a `DESCARTADO` (con `resueltoPor`/`fechaResolucion`) y la solicitud se deja como está (es el caso de 15788025 mientras no exista «Sincronizar»). Con esto la traza queda en la bandeja (filtro *Estado = Descartado*).
4. **Relanzar** (botón existente): sólo si CORE **no** tiene la operación hecha (falsa desincronización) → relanza el comando origen (`SCA2 CMD MarcarErrorRelanzado` → `comandoBase`), que volvería a intentar la mecanización. En 15788025 **no** debe pulsarse: repetiría la mecanización sobre una póliza ya anulada.
5. **Propuesta (no implementada, requiere confirmación del padre): acción «Sincronizar con CORE»** en la fila `DESINCRONIZACION_CORE`: leer el estado CORE (`SCA2_consultarSolicitudes`/gestiones), escribir la transición idempotente del record (`SCA2 Solicitud` → `FINALIZADA`/`MECANIZADA` según CORE, `SCA2 Transicion` con comando `SCA2 CMD SincronizarCore`), cerrar la tarea pendiente (`SCA2 Tarea`) y marcar la fila `RELANZADO`, **sin** llamar a CORE. Sería un comando nuevo `SCA2 CMD SincronizarCore` + botón en `SCA2_BandejaErrores`/`SCA2_DetalleErrores` visible sólo para `codigo = DESINCRONIZACION_CORE`.

## 5. Limitaciones, pendientes y preguntas abiertas
- **Batch NSE no ejecutado en caliente**: sólo se ha probado el corte con la constante en `false`. `SCA2 CMD MecanizarNSE` está validado por el diseñador pero sus integraciones (actualizarMecanizacion, crearAutorizacion, finalizarSolicitud, observaciones ANL, cierre ANL) no se han ejecutado; antes de activar el batch hay que probarlo con una solicitud NSE nueva dejada en `MECANIZADA/ANL`. El diseñador muestra un aviso (no error) por una puerta dentro de un bucle con más de una salida.
- **Fila 121** (`DOC_GD_FAIL` de 15788209, primer intento con v10): descartada por el administrador al cerrar la prueba (dato propio).
- **Reintento desde pantalla duplica el fichero en el SGD** (3.3). Si se quiere evitar, `SCA2 CMD CompletarAccion` tendría que pasar la referencia previa (`idDoc_tipo_<ref16>`) también en el reintento desde la tarea, no sólo en el relanzamiento desde la bandeja. Pregunta para el analista: ¿es aceptable el duplicado en el SGD (hoy ocurre igual en SCA al reintentar)?
- **Fila `DOC_GD_FAIL` tras un reintento correcto**: queda `PENDIENTE` en la bandeja aunque la oficina ya haya resuelto el problema. Propuesta: que `SCA2 CMD CompletarAccion`, al completar con éxito, marque como `DESCARTADO` (resuelto) las filas `DOC_GD_FAIL` pendientes de la misma solicitud/tarea. No implementado (lógica de un comando fuera del alcance).
- **Aviso rojo en Acciones Administrativas (v23)** no visto en pantalla (ninguna póliza de prueba deriva a AA).
- **15788025**: sigue `PDTE_MECANIZAR` en SCA2 y anulada en CORE; sólo tiene la fila 120. Decisión pendiente del padre/analista: descartar la fila y dejarla así, o implementar «Sincronizar con CORE» (4.4.5).
- **Regla general en comandos** (4.3) no aplicada: `SCA2 CMD Mecanizar` pertenece a R23-A y los otros dos exigirían cambiar lógica funcional.
- Pregunta: el batch de SCA (`SCA Batch Mecanizacion NSE`) sigue barriendo CORE y por tanto también cerrará las solicitudes NSE creadas desde SCA2; si en PRO conviven las dos aplicaciones, ¿se mantiene el de SCA y el de SCA2 sólo sincroniza el record (29 §3), o se desactiva el de SCA para las solicitudes de SCA2?
- Herramienta: LCP no permite validar/arrancar PM ni evaluar reglas; para evaluar reglas en TEST sirve `POST /expression-rules/{uuid}/test-cases` (`NO_ERRORS`) + `/test-cases/run`, que devuelve `output` (los test-cases temporales se han borrado).

## 6. Datos usados y evidencias
- Solicitud nueva: **15788209** (póliza 0005726683648, JJGONZ2, 21/10/2026 14:08). Documento Appian 569600; referencias SGD `c29381a15e60e07e` (1.er intento, resuelta `0900ab4481a0cc22`) y `0900ab4481a0cf66` (2.º intento, la que consta en CORE).
- Fila de desincronización: `SCA2 Error` 120 (15788025). Filas propias descartadas: 119 (vacía), 121 (DOC_GD_FAIL de la prueba).
- Instancia del batch apagado: 16444058.
- Capturas en `docs/sca/pruebas/evidencias/r24-d/` (prefijo `r24d-`). Backups y PUT en `~/sca2work/r24d/` (local, no se suben).
