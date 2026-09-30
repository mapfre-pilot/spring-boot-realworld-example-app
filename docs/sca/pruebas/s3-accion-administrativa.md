# S3 — Decisión → Acción Administrativa → POSPONER / RETOMAR / FINALIZAR (SCA vs SCA2, TEST)

Fecha de ejecución: 30/09/2026. Entorno: `https://mapfrespain-test.appiancloud.com` (sites `sca-site` y `sca2`). Usuario funcional: `JJGONZ2` (RED MAPFRE / OFICINA, canal CE_RM). Referencia funcional: **SCA**; sólo se corrige **SCA2**.

## 1. Pólizas y solicitudes

| App | Póliza | idSolicitud | Motivo / Detalle / Causa | Canal entrada | Catalogación alta |
|---|---|---|---|---|---|
| SCA | `2002000000291` | **15787700** | 1 DECISIÓN DE CLIENTE / 5 VENTA DEL VEHICULO / 14 NO VOY A COMPRARME OTRO COCHE | PRESENCIAL | A FECHA 30/09/2026 |
| SCA2 | `2002000044530` | **15787704** | 1 / 5 / 14 (idem) | PRESENCIAL | A FECHA 30/09/2026 |

Póliza de reserva `2002000087840`: **no usada**. No se ha tocado ninguna otra solicitud.

Combinación tomada de `docs/sca/11-…md` §11 y `docs/sca/analisis/t21_paridad_acciones.md` (decisión → Acciones Administrativas, nivel 1). El motor decidió **Acción Administrativa** en ambas apps y ambas navegaron directamente a la pantalla de Acción Administrativa tras el OK del alta.

## 2. Tabla paso a paso

Leyenda veredicto: **=** igual · **≠SCA2** divergencia exclusiva de SCA2 (corregida ✔ / pendiente ✎) · **≠SCA** divergencia cuyo origen está en SCA / servicio externo (se documenta, no se corrige).

| # | Paso | SCA (15787700) | SCA2 (15787704) | Veredicto |
|---|---|---|---|---|
| 1 | Alta (formulario, validaciones, mensaje OK) | Alta OK, mensaje de guardado, navega a Acción Administrativa | Igual: alta OK, mismo mensaje, navega a Acción Administrativa | = |
| 2 | Estado CORE tras alta (`SCA2_consultarSolicitudes`) | `codEstSolic=2`, `causaAnul=NO VOY A COMPRARME OTRO COCHE`, `fecAnul=30/09/2026` | Idéntico | = |
| 3 | Gestiones CORE tras alta (`SCA2_consultaGestion`) | Alta `accionRealizada=8 FINALIZADA` + AccAdm `accionRealizada=3 INCOMPLETA`, `nuuma JJGONZ2 / RED MAPFRE / OFICINA`, nivel 1 | Idéntico (numGestion 43704822 / 43704824) | = |
| 4 | Buscador tras alta: estado | **Pendiente** | **Acción administrativa en curso** | ≠SCA2 ✎ (decisión previa de SCA2, ver §5.6) |
| 5 | Pantalla AccAdm — cabecera / datos solicitud | Cabecera póliza-cliente, pestañas, datos solicitud | Igual | = |
| 6 | Pantalla AccAdm — «Tipo catalogación» | No se muestra (sección sólo para origen FDC; esta póliza es NSE-Autos): hueco en blanco | No se muestra (misma condición `origen = "FDC"`) | = (no comprobable el choiceValues para NSE) |
| 7 | Pantalla AccAdm — documentación | Documento compra/venta · compra/venta sin traspaso del seguro · **Justificante gestoría** · Dni | Inicialmente **Anulación firmada** en lugar de Justificante gestoría → corregido (v12) | ≠SCA2 ✔ |
| 8 | Pantalla AccAdm — «Fecha disponibilidad vehículo» | No aparece para esta causa | Aparecía siempre → corregido (`showWhen` equivalente al de SCA, v12) | ≠SCA2 ✔ |
| 9 | Pantalla AccAdm — botones | CANCELAR (link) · POSPONER (outline) · FINALIZAR (solid, deshabilitado hasta informar documentación) | Iguales; además mostraba texto técnico **`dbg:click`** al pie tras pulsar POSPONER → eliminado (v13) | ≠SCA2 ✔ |
| 10 | POSPONER — confirmación | «¿Desea continuar?» / «Se va a posponer la solicitud de anulación» / ACEPTAR-CANCELAR | Igual | = |
| 11 | POSPONER — oficina obligatoria | Exige «Seleccione oficina» («Se requiere un valor»); opciones MADRID CORREDORES NORTE II / VILLALBA | Permitía posponer sin oficina → añadido `validate: true` (v13) | ≠SCA2 ✔ |
| 12 | POSPONER — mensaje | «Los datos se han guardado correctamente» | Igual | = |
| 13 | POSPONER — observaciones en CORE | `SCA2_consultaGestion` → gestión AccAdm `observaciones="Prueba S3 posponer SCA"`; `consultarListadoObs(tipoGestion 3)` → «JJGONZ2 30/09/2026 11:48:18 Nivel 1: Prueba S3 posponer SCA» | No se escribía nada en CORE (Detalle/Buscador mostraban «-») → el botón POSPONER ahora llama a `SCA2_insertarObservaciones` (v13); para 15787704 se insertó la observación por LCP (POSPONER es de un solo uso) → gestión `observaciones="Prueba S3 posponer SCA2"` | ≠SCA2 ✔ |
| 14 | POSPONER — catalogación en CORE | Pasa de A FECHA 30/09/2026 a **A VENCIMIENTO 02/01/2027** (`fecAnul` CORE = 02/01/2027) sin marcar «no entrega documentación» | Mantiene A FECHA 30/09/2026 | ≠SCA (ver §5.4) — no corregido |
| 15 | POSPONER — estado CORE | `codEstSolic=2`, gestión AccAdm sigue `INCOMPLETA` | Igual | = |
| 16 | POSPONER — tarea | La tarea Appian pasa a `deployment.user` (`SCA_queryProcessReport`: owner `deployment.user`); en Detalle sólo aparece **REASIGNAR**; al abrir la tarea vieja: «La tarea solicitada no está disponible. Es posible que la tarea haya sido eliminada o completada por otro asignado.» | `SCA2 Tarea` id 21 `ACCIONES ADMINISTRATIVAS / PENDIENTE`, `SCA2 Solicitud`: `EN_ACCION / CONTRA_ANULAR / ACCIONES ADMINISTRATIVAS`, `estadoTarea PENDIENTE`, `caducidadTarea 07/10/2026`, `contadorPosponer` +1 | ≠SCA (ver §5.5) — no corregido |
| 17 | RETOMAR desde Detalle | No disponible hasta REASIGNAR (reasigna al usuario logueado: «La tarea se ha reasignado correctamente»); tras F5 aparece RETOMAR y abre la Acción Administrativa | RETOMAR disponible directamente; abre la Acción Administrativa sin error | ≠SCA (consecuencia de #16) |
| 18 | RETOMAR desde Buscador | Igual que #17 | Buscador → 15787704 → RETOMAR OK | ≠SCA (consecuencia de #16) |
| 19 | Detalle tras POSPONER — tarjeta Acciones Administrativas | Incompleta (naranja); fechas; Nivel 1; Perfil RED MAPFRE / Grupo OFICINA / Nuuma JJGONZ2; «Documentos presentados por el cliente» (vacío); Observaciones «Prueba S3 posponer SCA» | Inicialmente mostraba Perfil `CE_RM` / Nuuma `correo completo`, sin documentos ni observaciones → corregido `SCA2_DetalleSolicitud` v17 (datos desde la gestión CORE `accionRealizada=3`) | ≠SCA2 ✔ |
| 20 | Detalle tras POSPONER — datos solicitud | Estado PENDIENTE, Catalogación A VENCIMIENTO, Fecha anulación 02/01/2027 | Estado ACCIÓN ADMINISTRATIVA EN CURSO, Catalogación A FECHA, Fecha anulación 30/09/2026 | ≠ (mezcla de #4 y #14) |
| 21 | FINALIZAR — confirmación y mensaje | «¿Desea continuar?» / «Se va a finalizar la revisión de acciones administrativas»; «Los datos se han guardado correctamente» | Iguales | = |
| 22 | FINALIZAR — gestión CORE AccAdm | `43704814` pasa a **FINALIZADA** (`fecFin 12:07:54`), observaciones «Prueba S3 posponer SCA,Prueba S3 finalizar SCA» | UI OK y tarea SCA2 completada, pero `43704824` seguía **INCOMPLETA** (`fecFin null`): el flujo SCA2 (`SCA2 CMD CompletarAccion`) no llama a `guardarAccAdm(mcaFinalizar=S)`. Añadida la llamada en el botón FINALIZAR (v14) y cerrada la gestión de 15787704 por LCP con la misma regla → **FINALIZADA** (`fecFin 12:47:02`) | ≠SCA2 ✔ (v14; ver §5.1.10 y §6) |
| 23 | FINALIZAR — observación final en CORE | `consultaDetalleGestion`: «…12:07 Nivel 1: Prueba S3 finalizar SCA» | Igual («…12:33:36 Nivel 1: Prueba S3 finalizar SCA2») | = |
| 24 | FINALIZAR — navegación posterior | Navega a la pantalla de **mecanización NSE-Autos** (botón ANULAR PÓLIZA, no pulsado) y CORE recibe una gestión **Mecanización (5) INCOMPLETA** `43704834` | Vuelve al **Buscador**; solicitud SCA2 `PDTE_MECANIZAR` / `procesoActivo MECANIZAR`; no crea gestión CORE de mecanización hasta que se abra la mecanización | ≠SCA2 ✎ (decisión de diseño SCA2 ya documentada: mecanización como comando separado; no corregida) |
| 25 | FINALIZAR — `codEstSolic` / `fecAnul` | `codEstSolic=2`, `fecAnul=02/01/2027`, `fecResolucion=null` | `codEstSolic=2`, `fecAnul=05/05/2027` (FINALIZAR SCA2 llama a `modificarCatalogacion` con la fecha de vencimiento), `fecResolucion=30/09/2026 12:47:02` | ≠ (comportamiento de servicio CORE ante `guardarAccAdm S`; SCA no informa `fecResolucion`) — documentado |
| 26 | Buscador tras FINALIZAR | **Pendiente** (naranja) | Mostraba el código crudo **`PDTE_MECANIZAR`** (gris) → `SCA2_textoEstadoSolicitud` v7: «Solicitud Pendiente» naranja | ≠SCA2 ✔ |
| 27 | Detalle tras FINALIZAR — tarjeta AccAdm (F5) | Finalizada (verde), 11:36:00 → 12:07:54, Nivel 1, RED MAPFRE / OFICINA / JJGONZ2, «No hay documentos a mostrar», observaciones | Igual (11:39:55 → 12:47:02) | = |
| 28 | Detalle tras FINALIZAR — cabecera «Solicitud anulación» | Estado PENDIENTE, Fecha anulación y Catalogación **desde CORE** (`consultarCabecera`) | Mostraba **30/09/2026 / A FECHA** desde el record `SCA2 Datos Solicitud` (obsoleto) mientras SCA muestra para la misma 15787704 **05/05/2027 / A FECHA** → `SCA2_SolicitudAnulacion` v6 lee `fecAnulacion`/`catalogacion` de CORE | ≠SCA2 ✔ |
| 29 | Detalle tras FINALIZAR — tarjeta Mecanización | Presente (Incompleta, botones TRAZAR ANULACIÓN / REASIGNAR) | Ausente (consecuencia de #24) | ≠SCA2 ✎ (ligado a #24) |
| 30 | `/errores` SCA2 | n/a | `SCA2_contarErroresPendientes` = 0 para `SCA2 CMD CompletarAccion` / `Decidir` / `CompletarAccion`; la página `sites/sca2/page/errores` devuelve «La página no existe o no tiene permiso para verla» y no aparece en el menú del site para JJGONZ2 | no comprobable en UI |
| 31 | Alta SGC al POSPONER | `SCA_posponerAccAdm`: `cargaGestionPCA` (alta gestión SGC) + `guardarAccAdm(N)` + `actualizarSolicitud` + notificación externa; guarda `idGestionSGC` en el record | `SCA2 CMD Posponer` no hace nada de esto (`idgestionsgc` sigue 0). Además `SCA2_CargaGestionPCAIntegration` serializaba un `Map` sin tipo → SOAP fault 3001; corregida (v2) y verificada (gestión SGC 233844099 creada) | ≠SCA2 ✔ integración / ✎ port del flujo POSPONER pendiente (§5.3) |

## 3. Estados CORE / SCA2 observados

### 3.1 Tras el alta (ambas)
```
SCA2_consultarSolicitudes: codEstSolic=2, causaAnul="NO VOY A COMPRARME OTRO COCHE", fecAnul=30/09/2026 (ambas)
SCA2_consultaGestion 15787700: [8 FINALIZADA 11:35:04 (43704811)] [3 INCOMPLETA 11:36:00 (43704814)]
SCA2_consultaGestion 15787704: [8 FINALIZADA 11:39:37 (43704822)] [3 INCOMPLETA 11:39:55 (43704824)]
infoUsuario (todas): nuuma JJGONZ2, codPerfil RED MAPFRE, codSubPerfil OFICINA, nivel 1
SCA2_cargarSolicitud 15787704: estadoSolicitud EN_ACCION, interfazActiva CONTRA_ANULAR, procesoActivo ACCIONES ADMINISTRATIVAS,
  estadoTarea PENDIENTE, nivelIntervencion 1, grupoAsignacion CE_RM, origenPoliza NSE-Autos,
  datos: codmotivo 1, coddetalle 5, codcausa 14, catalogacion 4, canalentrada 1, fecanulacion 30/09/2026
```

### 3.2 Tras POSPONER
```
SCA 15787700: consultarSolicitudes fecAnul=02/01/2027 (catalogación pasa a vencimiento), codEstSolic=2
              consultaGestion AccAdm 43704814: INCOMPLETA, observaciones="Prueba S3 posponer SCA"
              consultarListadoObs(tipoGestion 3): "JJGONZ2 30/09/2026 11:48:18 Nivel 1: Prueba S3 posponer SCA"
              SCA_queryProcessReport: tarea "Acciones Administrativas" Activa, owner deployment.user, taskId 536872086
SCA2 15787704: consultarSolicitudes fecAnul=30/09/2026, codEstSolic=2
              consultaGestion AccAdm 43704824: INCOMPLETA, observaciones=null → (tras fix + inserción LCP) "Prueba S3 posponer SCA2"
              consultarListadoObs(tipoGestion 3): null → "JJGONZ2 30/09/2026 12:04:13 Nivel 1: Prueba S3 posponer SCA2"
              SCA2 Solicitud: version 4, modifiedAt 09:49:07, estadoTarea PENDIENTE, caducidadTarea 2026-10-07
              SCA2 Tarea 21: ACCIONES ADMINISTRATIVAS / PENDIENTE (proceso SCA2 CMD CrearAccion)
```

### 3.3 Tras FINALIZAR
```
SCA 15787700: consultaGestion → [8 FINALIZADA 43704811] [3 FINALIZADA 11:36:00→12:07:54 43704814 obs "Prueba S3 posponer SCA,Prueba S3 finalizar SCA"]
                               [5 INCOMPLETA 12:08:19 43704834]  (mecanización abierta por SCA al navegar a NSE-Autos)
              consultarSolicitudes: codEstSolic=2, fecAnul=02/01/2027, fecResolucion=null
SCA2 15787704 (tras FINALIZAR UI, v13): consultaGestion AccAdm 43704824 INCOMPLETA, fecFin null, obs "Prueba S3 posponer SCA2,Prueba S3 finalizar SCA2"
              consultaDetalleGestion: "#&#JJGONZ2 30/09/2026 12:04:13 Nivel 1: Prueba S3 posponer SCA2 #&#JJGONZ2 30/09/2026 12:33:36 Nivel 1: Prueba S3 finalizar SCA2#&#"
              SCA2 Solicitud: estadoSolicitud PDTE_MECANIZAR, procesoActivo MECANIZAR, interfazActiva CONTRA_ANULAR, estadoTarea PENDIENTE, version 6, grupo CE_RM
              SCA2 Tarea 21: ACCIONES ADMINISTRATIVAS / COMPLETADA (SCA2 CMD CrearAccion)
              SCA2_contarErroresPendientes(15787704, "SCA2 CMD CompletarAccion" | "SCA2 CMD Decidir" | "CompletarAccion") = 0
SCA2 15787704 (tras cierre por LCP con SCA2_guardarAccAdm, ver §5.1.10):
              consultaGestion → [8 FINALIZADA 43704822] [3 FINALIZADA 11:39:55→12:47:02 43704824]
              consultarSolicitudes: codEstSolic=2, fecAnul=05/05/2027 00:00:00, fecResolucion=30/09/2026 12:47:02
              consultarCabecera: estadoSolicitud 2, catalogacion 4, fecAnulacion 05/05/2027, fecEstado 12:47:02
              SGC: ID_GESTION_COMERCIAL 233844099 (COD_RETORNO 0, creada con SCA2_CargaGestionPCAIntegration v2); 233844098 creada antes con la integración SCAC de referencia (prueba de contraste)
              SCA2_actualizarSolicitud(15787704, idGestionSGC 233844099) → respuesta true; SCA2_insertarNotificacionExterna → fallo 500 (también con perfil CE_RM) — no bloqueante
```

## 4. Objetos SCA2 modificados

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_DetalleSolicitud` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 16 → 17 | La tarjeta de gestión localiza la gestión CORE por tipo (`accionRealizada` 2 = Contra Anulación, 3 = Acción Administrativa) en vez de usar siempre la de Contra Anulación; perfil/grupo/nuuma desde `infoUsuario` CORE; bloque «Documentos presentados por el cliente» y «Observaciones» también para Acción Administrativa; mapeo de tipos de documento 1-8 y 400 como SCA. |
| `SCA2_AccionesAdministrativasPrincipal` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | 11 → 12 | `local!origenPoliza` desde `estado.origenPoliza` (antes se pasaba `local!origen` = canal de entrada a Documentación → «Anulación firmada»); «Fecha disponibilidad vehículo» condicionada a causa BAJA TEMPORAL/BAJA VEHICULO y póliza NSE-Autos como SCA. |
| `SCA2_AccionesAdministrativasPrincipal` (interfaz) | idem | 12 → 13 | POSPONER: inserta observaciones en CORE (`SCA2_insertarObservaciones`, tipoGestion 3) como SCA; `validate: true` (oficina obligatoria); eliminado el texto de depuración `dbg:` (queda sólo el mensaje de error real). |
| `SCA2_puedeGestionarTarea` (regla) | `_a-0000f06b-141a-8000-9d23-011c48011c48_5454993` | 2 → 3 | Tarea pendiente sin asignar: se puede gestionar si `nivelIntervencion = "1"` **o** el perfil coincide con el grupo (antes exigía nivel ≠ 1, lo que ocultaba REASIGNAR/RETOMAR tras POSPONER en nivel 1). |
| `SCA2_DetalleSolicitud` (interfaz) | `…_20055572` | 18 → 19 | Botón REASIGNAR: `rule!SCA2_reasignarTarea(...)` directamente en `saveInto` (antes `a!save(local!reasignado, rule!…)` → error «smart service functions cannot be used in a local variable»). |
| `SCA2_AccionesAdministrativasPrincipal` (interfaz) | `…_20056429` | 13 → 14 | FINALIZAR: antes de `SCA2 CMD CompletarAccion`, inserta observaciones (`SCA2_insertarObservaciones`) y llama a `rule!SCA2_guardarAccAdm(mcaFinalizar: "S", numGestion, idGestionSGC del record, fecAnulacion = vencimiento, fecDispoVeh, listaDocumentos, infoUsuario CE_RM)` como el nodo `guardarAccAdm` del PM `SCA Acciones Administrativas`; `local!codCiaUsuario` desde `SCA2 Datos Perfiles Pca.codcompania` (fallback `infoUsuario.codCiaUsuario`). |
| `SCA2_CargaGestionPCAIntegration` (integración) | `3d3e77b8-a37f-4c92-8a87-7f275dbfc911` | 1 → 2 | `toxml(value: cast('type!{http://CARGAGESTION_SLIB/v4_0_0/ICargarGestionPCA}CargaGestionPCA', ri!consulta), …)`: el `Map` sin tipo producía SOAP fault 3001 en SGC; con el CDT (como `SCAC_CargaGestionPCAIntegration`) devuelve `COD_RETORNO 0`. |
| `SCA2_textoEstadoSolicitud` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063670` | 6 → 7 | `PDTE_MECANIZAR` → «Solicitud Pendiente» (color naranja vía `SCA2_colorEstadoSolicitud`), como SCA muestra «Pendiente» para `codEstSolic=2`. |
| `SCA2_SolicitudAnulacion` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064988` | 5 → 6 | Cabecera del Detalle: «Fecha anulación» y «Catalogación» desde CORE (`local!cab` = `SCA2_consultarCabeceraSolicitud`) con fallback al record, como `SCA_SolicitudAnulación` (`ri!consultarCabecera`). |

Procedimiento seguido en cada caso: GET vivo → backup JSON/SAIL en `~/sca2work/fix/` → edición mínima → PUT del objeto completo → re-GET (expresión idéntica) → `POST /interfaces/{uuid}/test` con `idSolicitud=15787704` → prueba UI.

### 4.1 Fragmentos SAIL relevantes

`SCA2_DetalleSolicitud` (v17) — selección de la gestión CORE por tipo de tarjeta:
```
local!esCA: search("CONTRA", upper(a!defaultValue(tostring(index(fv!item, "tipo", "")), ""))) > 0,
local!esAA: search("ACC",    upper(a!defaultValue(tostring(index(fv!item, "tipo", "")), ""))) > 0,
local!codCore: if(local!esCA, "2", if(local!esAA, "3", null)),
local!gestionesTipo: if(a!isNullOrEmpty(local!codCore), {},
  reject(fn!isnull, a!forEach(items: local!gestionesCore,
    expression: if(tostring(index(fv!item, "accionRealizada", "")) = local!codCore, index(fv!item, "numGestion", null), null)))),
...
showWhen: and(local!abierta, or(local!esCA, local!esAA))   /* antes: and(local!abierta, local!esCA) */
```

`SCA2_AccionesAdministrativasPrincipal` (v12):
```
local!origenPoliza: index(index(local!sol, "estado", null), "origenPoliza", ""),
local!descCausa:    index(index(local!sol, "datos", null), "desccausa", ""),
...
a!cardLayout(showBorder: false,
  contents: rule!SCA2_FechaDisponibilidadVehiculo(...),
  showWhen: and(or(upper(local!descCausa) = "BAJA TEMPORAL", upper(local!descCausa) = "BAJA VEHICULO"),
                local!origenPoliza = cons!SCA2_TXT_NSE_AUTOS)),
...
rule!SCA2_AccionesAdministrativasDocumentacion(..., origenPoliza: local!origenPoliza, ...)   /* antes: local!origen */
```

`SCA2_AccionesAdministrativasPrincipal` (v13) — botón POSPONER:
```
saveInto: {
  a!save(local!errorPosponer,
    if(or(a!isNullOrEmpty(local!observaciones),
          toboolean(a!defaultValue(index(rule!SCA2_insertarObservaciones(
            nuuma: local!nuuma, codSolicitud: ri!idSolicitud,
            txtObservaciones: local!observaciones, tipoGestion: local!tipoGestion), "success", false), false))),
       null, "Las observaciones no se han podido guardar en CORE")),
  a!startProcess(processModel: cons!SCA2_PM_CMD_POSPONER, ...)
},
..., validate: true
```
(SCA hace exactamente estas dos cosas en el botón POSPONER de `SCA_AccionesAdministrativasPrincipalEstrategicas`: `rule!SCA_insertarObservaciones(nuuma, codSolicitud, txtObservaciones, tipoGestion: "3")` y `validate: true`.)

`SCA2_puedeGestionarTarea` (v3):
```
and(a!isNullOrEmpty(local!asignadoA), or(ri!nivelIntervencion = "1", local!perfil = local!grupo))
/* antes: and(a!isNullOrEmpty(local!asignadoA), ri!nivelIntervencion <> "1", local!perfil = local!grupo) */
```

`SCA2_AccionesAdministrativasPrincipal` (v14) — botón FINALIZAR (extracto):
```
a!save(local!respuesta, and(
  local!respuesta = true,
  or(a!isNullOrEmpty(local!observaciones),
     toboolean(a!defaultValue(index(rule!SCA2_insertarObservaciones(nuuma: local!nuuma, codSolicitud: ri!idSolicitud,
       txtObservaciones: local!observaciones, tipoGestion: local!tipoGestion), "success", false), false))),
  toboolean(a!defaultValue(index(rule!SCA2_guardarAccAdm(guardarAccAdm: a!map(MSEGuardarAccAdm: a!map(
    fecAnulacion: tostring(todate(local!fechaVencimiento)), fecDispoVeh: tostring(todate(local!fechaDisponibilidadVehiculo)),
    idGestionSGC: index(index(index(local!sol, "datosCompletosSolicitud", {}), "datosBasicosSolicitud", {}), "idgestionsgc", null),
    idSolicitud: ri!idSolicitud,
    infoUsuario: a!map(codCiaUsuario: local!codCiaUsuario, nuuma: local!nuuma, codPerfil: local!codPerfil, codSubPerfil: local!codSubPerfil),
    listaDocumentos: ..., mcaFinalizar: "S", numGestion: local!numGestion))), "success", false), false))
)),
a!startProcess(processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION, ...)
```
Nota: CORE (`IGestionarAccAdmPCA`) devuelve `4007 Ocurrió un error en el acceso a la base de datos` si `infoUsuario.codPerfil/codSubPerfil` llevan la descripción (`RED MAPFRE` / `OFICINA`, que es lo que devuelve `consultaGestion`); acepta los códigos internos (`CE_RM` / `CE_RM_OFICINA`, que es lo que devuelve `SCA2_obtenerInformacionUsuario` y usa la interfaz). Verificado por LCP con la integración SCA2 y con la SCAC de referencia.

`SCA2_CargaGestionPCAIntegration` (v2):
```
toxml(value: cast('type!{http://CARGAGESTION_SLIB/v4_0_0/ICargarGestionPCA}CargaGestionPCA', ri!consulta), format: true, name: "CargaGestionPCA")
/* antes: toxml(value: ri!consulta, ...) → <soapenv:Fault> codigo 3001 CARGAGESTION_SMED */
```

`SCA2_SolicitudAnulacion` (v6):
```
text: a!defaultValue(if(a!isNullOrEmpty(index(local!cab, "fecAnulacion", null)), index(local!ds, "fecanulacion", null),
                        text(todatetime(index(local!cab, "fecAnulacion", null)), "dd/MM/yyyy")), "-"),
...
local!catalog: a!defaultValue(index(local!cab, "catalogacion", null), index(local!ds, "catalogacion", null)),
```

## 5. Divergencias y clasificación

### 5.1 Corregidas (exclusivas de SCA2)
1. **Detalle → tarjeta Acciones Administrativas** mostraba `CE_RM` / correo completo y no mostraba documentos ni observaciones: la tarjeta usaba la lógica de Contra Anulación (`accionRealizada="2"`) para todas las acciones. → `SCA2_DetalleSolicitud` v17.
2. **Documento tipo 2 «Anulación firmada»** en lugar de «Justificante gestoría»: se pasaba el canal de entrada como `origenPoliza`. → v12.
3. **«Fecha disponibilidad vehículo» siempre visible**: en SCA sólo para causas BAJA TEMPORAL / BAJA VEHICULO en NSE-Autos. → v12.
4. **POSPONER no escribía las observaciones en CORE** (Detalle/Buscador SCA2 mostraban «-»). Causa raíz: en el PM `SCA2 CMD Posponer` la llamada a `rule!SCA2_insertarObservaciones` estaba embebida en `a!localVariables(local!o: rule!…, pp!initiator)` dentro del campo `modifiedBy`; la variable local no se usa, por lo que Appian no la evalúa (evaluación perezosa) y la observación nunca llegaba a CORE. Corregido en la interfaz (mismo punto donde lo hace SCA). Se recomienda además limpiar ese `a!localVariables` del PM (no se ha tocado el PM en esta sesión).
5. **Oficina no obligatoria al POSPONER** (SCA sí la exige). → `validate: true` v13.
6. **Texto técnico `dbg:click`** al pie tras POSPONER. → eliminado v13.
7. **REASIGNAR/RETOMAR no visibles tras POSPONER en nivel 1** (`SCA2_puedeGestionarTarea` exigía nivel ≠ 1 para tareas sin asignar). → v3.
8. **Botón REASIGNAR de SCA2 fallaba** («a!save() and smart service functions cannot be used in a local variable…»). → `SCA2_DetalleSolicitud` v19. Tras la corrección, REASIGNAR → F5 → RETOMAR funciona igual que en SCA.
9. **Buscador mostraba `PDTE_MECANIZAR`** (código crudo, gris) donde SCA muestra «Pendiente». → `SCA2_textoEstadoSolicitud` v7.
10. **FINALIZAR no cerraba la gestión CORE AccAdm** (UI «CORRECTO», tarea SCA2 COMPLETADA, solicitud `PDTE_MECANIZAR`, pero `43704824` INCOMPLETA y `fecFin null`; `SCA2 CMD CompletarAccion` sólo escribe records/trazabilidad y `SCA2 CMD Finalizar` no se recorre en este camino). → `SCA2_AccionesAdministrativasPrincipal` v14 llama a `SCA2_guardarAccAdm(mcaFinalizar S)` como el nodo `guardarAccAdm` de `SCA Acciones Administrativas`. Como POSPONER/FINALIZAR ya se habían consumido en 15787704, el cierre de esa gestión se ejecutó por LCP con la misma regla y el mismo payload que ahora usa el botón (resultado `respuesta=true`, gestión FINALIZADA 12:47:02). **La v14 no se ha podido re-ejecutar desde la UI en una solicitud nueva** (no hay más pólizas asignadas): queda verificada la regla/payload (`POST …/test` OK) pero no el clic en una solicitud fresca.
11. **`SCA2_CargaGestionPCAIntegration` no funcionaba** (Map sin tipo → SOAP fault 3001; la SCAC equivalente con el mismo payload devuelve `COD_RETORNO 0`). → v2 (verificada: `ID_GESTION_COMERCIAL 233844099`).
12. **Cabecera del Detalle con fecha anulación / catalogación obsoletas** (record `SCA2 Datos Solicitud` no se actualiza cuando FINALIZAR modifica la catalogación en CORE; SCA lee CORE). → `SCA2_SolicitudAnulacion` v6. El acordeón `SCA2_DetalleDatos` sigue leyendo el record (no comparado con SCA en esta prueba; pendiente).

### 5.2 Comunes / no comprobables
- **«Tipo catalogación»**: en ambas apps la sección de catalogación sólo se muestra para origen `FDC`; con pólizas NSE-Autos no se puede comprobar en UI que el valor esté en `choiceValues` (SCA2: `choiceLabels: cons!SCA2_TXT_TIP_CATALOGACION_PCA`, `choiceValues: cons!SCA2_INT_TIP_CATALOGACION_PCA`, `value: ri!tipoCatalogacion`).

### 5.3 Pendiente (exclusiva de SCA2, no corregida): POSPONER no da de alta la gestión SGC
En SCA, el nodo «Posponer y caducidad» del PM `SCA Acciones Administrativas` ejecuta `SCA_posponerAccAdm`: alta de gestión comercial en SGC (`cargaGestionPCA`, acción 5799), `guardarAccAdm(mcaFinalizar N)`, `actualizarSolicitud(idGestionSGC)`, `insertarNotificacionExterna` y guarda `idGestionSGC` en `SCA datosBasicosSolicitud`. En SCA2, `SCA2 CMD Posponer` sólo cambia estado/tarea/dietario y `idgestionsgc` permanece `0`; existen las reglas `SCA2_guardarGestionSGC`, `SCA2_cargaGestionPCA`, `SCA2_actualizarSolicitud` e `SCA2_insertarNotificacionExterna` (copias de SCA) pero nadie las invoca. La integración ya funciona (v2), y el payload equivalente se validó por LCP para 15787704 (SGC 233844099, `actualizarSolicitud → true`); `insertarNotificacionExterna` devuelve 500 en CORE con cualquier perfil (no se ha podido aislar la causa). **No se ha portado el flujo** porque requiere elegir dónde (interfaz vs. PM `SCA2 CMD Posponer`), escribir `idgestionsgc` en el record y no puede re-probarse en UI con las pólizas asignadas (POSPONER es de un solo uso). Se pide decisión.

### 5.4 Divergencia con origen en SCA — catalogación tras POSPONER
SCA, al pulsar POSPONER, llama a `SCA_modificarCatalogacionCodCiaCntrAnul(fechaAnulacion: local!fecAnulacion, tipoCatalogacion: local!tipoCatalogacion)` con los valores de **su propio record `SCA datosSolicitud`**, no los de CORE; en 15787700 eso convirtió A FECHA 30/09/2026 en **A VENCIMIENTO 02/01/2027** sin que el usuario marcara «no entrega documentación». SCA2 no llama a ese servicio al posponer y conserva la catalogación del alta. No se replica en SCA2 porque el comportamiento de SCA parece un efecto lateral (datos locales desalineados con CORE), no una regla funcional. **Pregunta al analista**: ¿debe POSPONER cambiar la catalogación a vencimiento?

### 5.5 Divergencia con origen en SCA — RETOMAR tras POSPONER
En SCA la tarea `Acciones Administrativas` queda asignada a `deployment.user` tras POSPONER; el Detalle sólo ofrece REASIGNAR (tooltip/enlace de RETOMAR condicionado a `touser(local!taskOwner) = loggedInUser()`), y el enlace antiguo da «La tarea solicitada no está disponible…». En SCA2 la tarea (`SCA2 Tarea`) sigue asignada al usuario/grupo y RETOMAR está disponible desde Detalle y Buscador. SCA2 no reasigna la tarea a la oficina seleccionada al posponer (la oficina sólo se valida). **Pregunta al analista**: ¿la oficina elegida al POSPONER debe reasignar la tarea (como parece hacer SCA) o basta con exigirla?

### 5.6 Estado en Buscador (resuelto durante la prueba)
Al inicio SCA2 mostraba **Acción administrativa en curso** donde SCA muestra **Pendiente**. Durante la sesión otra sesión paralela dejó `SCA2_textoEstadoSolicitud` en v6 mostrando «Solicitud Pendiente» para `EN_ACCION` (paridad con SCA); en esta sesión se añadió `PDTE_MECANIZAR` (v7). Fila #4 queda por tanto resuelta.

## 6. Limitaciones / bloqueos
- POSPONER es de un solo uso por solicitud (`contadorPosponer`/`ri!posponer`): la corrección v13 (observaciones en CORE, oficina obligatoria) se ha verificado con `POST /interfaces/…/test` y, para dejar 15787704 en paridad con SCA, la observación se insertó por LCP con la misma regla que ahora usa el botón. La verificación UI completa de POSPONER v13 requiere una solicitud nueva (queda para la siguiente ronda).
- No se ha pulsado «ANULAR PÓLIZA» en la pantalla de mecanización a la que navega SCA tras FINALIZAR (fuera del alcance de S3).
- El PM `SCA2 CMD Posponer` no se ha modificado (ver §5.1.4).
- No se ha modificado ningún objeto de SCA, SCAC, CORE, GAIA, PRE ni Documentum. Sí se han **ejecutado** (sin modificar) por LCP la integración `SCAC_CargaGestionPCAIntegration` (prueba de contraste, creó la gestión SGC 233844098) y reglas de consulta SCA/SCAC.
- FINALIZAR v14 y el port de POSPONER (§5.3) no pueden re-probarse en UI con las pólizas asignadas: ambas acciones son de un solo uso y ya se consumieron en 15787700/15787704. Hace falta una póliza nueva para el ciclo completo Alta → POSPONER → RETOMAR → FINALIZAR con las versiones actuales.
- `sites/sca2/page/errores` no es accesible para JJGONZ2 («La página no existe o no tiene permiso para verla»); la bandeja se comprobó sólo por regla (`SCA2_contarErroresPendientes` = 0).
- `SCA2_insertarNotificacionExterna` (notificación SGC al posponer) devuelve HTTP 500 en CORE con perfil `RED MAPFRE/OFICINA` y con `CE_RM/CE_RM_OFICINA`; no comparado con SCA (SCA lo ejecuta dentro del PM y no expone el resultado).
- Fila #25: `fecResolucion` queda informada en 15787704 y no en 15787700 tras el mismo `guardarAccAdm(S)`; probablemente la fija CORE al no existir gestión de mecanización abierta (SCA la abre inmediatamente). No se corrige.
- El acordeón `SCA2_DetalleDatos` (Catalogación / Fecha anulación) sigue leyendo el record SCA2; sólo se corrigió la cabecera `SCA2_SolicitudAnulacion` que es la comparada con `SCA_SolicitudAnulación`.

## 7. Evidencias (no incluidas en el repo)
Grabaciones (`~/screencasts/`): `s3-checkpoint1/s3-checkpoint1-edited.mp4` (altas + pantalla AccAdm + Detalle), `s3-checkpoint2-verificacion/s3-checkpoint2-verificacion-edited.mp4` (POSPONER / RETOMAR / correcciones), `s3-checkpoint3/s3-checkpoint3-edited.mp4` (FINALIZAR SCA), `s3-final-v19/s3-final-v19-edited.mp4` (REASIGNAR v19 + FINALIZAR SCA2), `s3-lectura-final-core/s3-lectura-final-core-edited.mp4` (Detalle/Buscador tras el cierre CORE, `/errores`), `s3-lectura-v7-v6/s3-lectura-v7-v6-edited.mp4` (Buscador v7 + cabecera v6).

Capturas FINALIZAR y finales (`~/sca2work/shots/`): `s3-finalizar-confirmacion-sca.png`, `s3-finalizar-confirmacion-sca2.png`, `s3-finalizar-resultado-sca.png`, `s3-finalizar-resultado-sca2.png`, `s3-finalizar-nse-sca.png`, `s3-finalizar-destino-sca2.png`, `s3-finalizar-detalle-f5-sca.png`, `s3-finalizar-detalle-f5-sca2.png`, `s3-finalizar-buscador-f5-sca.png`, `s3-finalizar-buscador-f5-sca2.png`, `sca-detalle-final.png`, `sca2-detalle-final.png`, `sca-buscador-final.png`, `sca2-buscador-final.png`, `sca-buscador-poliza-sca2.png`, `s3-lectura-detalle-poliza-sca2-sca.png`, `sca2-errores.png`, `sca2-buscador-final-v7.png`, `sca2-detalle-final-v6.png`.

Capturas (`~/sca2work/shots/`): `s3-alta-formulario-sca.png`, `s3-alta-formulario-sca2.png`, `s3-alta-resultado-sca.png`, `s3-alta-resultado-sca2.png`, `s3-alta-tras-ok-sca.png`, `s3-alta-tras-ok-sca2.png`, `s3-alta-mensaje-ok-sca2.png`, `s3-buscador-previo-sca.png`, `s3-buscador-previo-sca2.png`, `s3-buscador-alta-sca2.png`, `s3-detalle-sca.png`, `s3-detalle-sca2.png`, `s3-detalle-datos-solicitud-sca.png`, `s3-detalle-inferior-sca.png`, `s3-detalle-tarea-no-disponible-sca.png`, `s3-posponer-buscador-detalle-sca.png`, `s3-posponer-detalle-sca2.png`, `s3-posponer-buscador-sca2.png`, `s3-retomar-corregida-sca2.png`.
