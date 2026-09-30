# S1 — Alta + navegación + Contra Anular NSE con cierre POSITIVO/FINALIZAR (SCA vs SCA2, TEST)

Fecha: 30/09/2026 · Entorno: `mapfrespain-test` · Usuario funcional UI: `JJGONZ2` (SSO NOPRO) · Referencia funcional: **SCA TEST**.
Sesión Devin: https://mapfre.devinenterprise.com/sessions/88dee0a40d484f0c9903bfaa0563bd53

## 1. Pólizas y solicitudes creadas

| App | Póliza | idSolicitud | Alta (CORE `fecSolicitud`) | Gestión ALTA (CORE) | Gestión CA inicial (CORE) |
|---|---|---|---|---|---|
| SCA  | `2002000040660` | **15787701** | 30/09/2026 11:36:37 | numGestion 43704816, accionRealizada 8, FINALIZADA, obs. «Prueba S1 Devin» | numGestion 43704821, accionRealizada 2, INCOMPLETA, inicio 11:38:45 |
| SCA2 | `2002000012482` | **15787702** | 30/09/2026 11:37:45 | numGestion 43704817, accionRealizada 8, FINALIZADA, obs. «Prueba S1 Devin» | numGestion 43704819, accionRealizada 2, INCOMPLETA, inicio 11:38:02 |

Póliza de reserva `2002000068129`: usada en Fase 1 para la segunda Alta sin guardar (Cancelar) y, en Fase 3 (reintento tras las correcciones), para un Alta real en **SCA2**:

| App | Póliza | idSolicitud | Alta (CORE) | Gestión ALTA (CORE) | Gestión CA inicial (CORE) |
|---|---|---|---|---|---|
| SCA2 (reintento) | `2002000068129` | **15787713** | 30/09/2026 12:36:02 | numGestion 43704853, accionRealizada 8, FINALIZADA, obs. «Prueba S1 Devin reintento» | numGestion 43704854, accionRealizada 2, INCOMPLETA, inicio 12:36:21 |
Record SCA2 de 15787702 tras el Alta (`SCA2_cargarSolicitud`): `estadoSolicitud=EN_ACCION`, `interfazActiva=CONTRA_ANULAR`, `procesoActivo=CONTRAANULAR`, `estadoTarea=PENDIENTE`, `nivelIntervencion=1`, `grupoAsignacion=CE_RM`, `usuario=JJGONZ2@…`.

Valores introducidos en ambas Altas: motivo DECISIÓN DE CLIENTE → detalle PRECIO → causa ME HA SUBIDO MUCHO LA PRIMA; canal PRESENCIAL; catalogación A VENCIMIENTO; observaciones «Prueba S1 Devin». La fecha de anulación la fija la app (vencimiento): 05/05/2027 (SCA) y 06/02/2027 (SCA2).

## 2. Fase 1 — Buscador, Alta, Cancelar, segunda Alta, navegación (grabación `sca_sca2_alta_fase1`)

| # | Paso | SCA | SCA2 | Veredicto |
|---|---|---|---|---|
| 1 | Buscador pestañas Cliente / Póliza | Tipo documento (6 tipos), Nº documento; póliza: Tipo Poliza (NO VIDA/VIDA), Nº póliza, Matrícula, Bastidor | Mismos campos y tipos documentales (N.I.F., C.I.F., N.I.F. otros países, C.I.F. otros países, N.I.E., PASAPORTE); distribución visual distinta | Igual funcionalmente (layout distinto, no se corrige) |
| 2 | Botón Alta → cabecera póliza/cliente | Cliente, NIF, producto, vehículo, línea AUTOMÓVILES, **antigüedad 6 años**, forma pago, efecto/vencimiento, prima, clave producción, tipo productor, contacto | Mismos bloques y campos para su póliza (**6 años**) | Igual |
| 3 | Guardar con formulario vacío | GUARDAR deshabilitado; aviso inferior «Revise los parámetros obligatorios del formulario.» | Igual | Igual |
| 4 | Cancelar | Diálogo de confirmación → vuelve al buscador y limpia la búsqueda | Diálogo de confirmación → vuelve al buscador; conserva el filtro de póliza | Divergencia menor **pendiente** (§5) |
| 5 | Segunda Alta con `2002000068129` sin guardar | Carga cliente ASESE NAMIODA IYAD / 39619011Q; no arrastra datos de la póliza anterior | Igual | Igual |
| 6 | Alta real (Guardar) | 15787701; ~40–45 s hasta el aviso «Su solicitud se ha generado correctamente. Se le va a redirigir a la acción correspondiente» + OK; el formulario se sustituye por el aviso | 15787702; ~45–50 s; aviso intermedio «…Determinando la acción a realizar, espere un momento…» y después el mismo aviso final + OK; el formulario permanecía y **GUARDAR seguía habilitado** | Divergencia **corregida** (GUARDAR deshabilitado tras generar, §4) |
| 7 | Navegación tras OK | Directo a Contra Anular (sin lista/RETOMAR) | Directo a Contra Anular (sin lista/RETOMAR) | Igual (analista OK) |
| 8 | Contra Anular: argumentarios GAIA, compañía, documentos | 7 argumentos (INCREMENTO PRIMA SINIESTROS obligatorio, GESTION COMPETENCIA, SUPLEMENTO EN GENERAL, CAMBIO DE FORMA DE PAGO, CLUB MAPFRE PLATA, SERVICIOS MAPFRE, REDUCCION DE COBERTURAS); selector de compañía 314; documentos Carta firmada + Dni en sección propia; sin «documento no disponible» | Igual | Igual |
| 9 | Contra Anular: título / secciones / FINALIZAR / popup compañías | Título «Contra anulación»; secciones expandidas; FINALIZAR deshabilitado con tooltip «Se debe ejecutar al menos 1 argumento»; el popup de compañías se abre con la lupa y se cierra con X/CANCELAR | Sin título; secciones colapsadas; FINALIZAR habilitado; popup de compañías siempre visible (no se cerraba) | Divergencia **corregida** (§4) |
| 10 | Buscador: fila de la misma solicitud 15787702 | Estado «Solicitud Pendiente», fecha 30/09/2026 11:37:45, causa «Más Prima», fecha resolución «-», observaciones «Prueba S1 Devin» | Estado «Contra anulación en curso», fecha 30/09/2026 11:37:54, causa «Me Ha Subido Mucho La Prima», fecha resolución = `modifiedAt`, observaciones «-» | Estado/causa/fecha resolución **corregidos**; fecha solicitud (createdAt del record, +9 s) y observaciones («-») **pendientes** (§5) |
| 11 | Cruce SCA2 → SCA | SCA encuentra 15787702 buscando `2002000012482` | — | Igual |
| 12 | Cruce SCA → SCA2 | — | SCA2 **no** encuentra 15787701 buscando `2002000040660` («No hay resultados para dicha búsqueda») | Divergencia **pendiente de decisión** (§5) |
| 13 | Flecha «volver» del Detalle de SCA | Error de evaluación en `sca_datoscabecera` (`a!submitLink`, saveInto literal `2002000040660`) | n/a | Fallo **de SCA** (no se corrige) |

## 3. Fase 2 — Contra Anular POSITIVO + cierre (grabación `sca_sca2_fase2_positivo_finalizar`)

Argumento obligatorio marcado en ambas apps: **INCREMENTO PRIMA SINIESTROS** (`codTipoArgumento` 267). Orden de ejecución: SCA primero, SCA2 después. No se ejecutó NEGATIVO, POSPONER, CANCELAR ni REASIGNAR. FINALIZAR manual no fue necesario: en SCA el ACEPTAR del aviso de POSITIVO cierra la contra anulación (`mcaEstadoFinal=3`) y la tarea desaparece; SCA2 debe hacer lo mismo.

| # | Paso | SCA (15787701) | SCA2 (15787702) | Veredicto |
|---|---|---|---|---|
| 14 | Pulsar POSITIVO | Argumento en verde «Positivo»; un único bloque «Se van a finalizar las acciones de contra anulación en SCA. ¿Desea continuar?» con CANCELAR/ACEPTAR; el formulario se oculta | Argumento en verde; **dos** bloques de confirmación (uno arriba, otro centrado) y el formulario seguía visible | Divergencia **corregida** (§4.6) — tras la corrección: un solo bloque centrado y formulario oculto (captura 31) |
| 15 | F5 antes de ACEPTAR | n/p | El argumento vuelve a Pendiente (el POSITIVO aún no se ha confirmado en CORE) | Coherente con el diseño de SCA (el guardado se hace en el ACEPTAR) |
| 16 | ACEPTAR del aviso | ~10:22:50 UTC. Vuelve **directamente** al buscador de Decidir Acción; sin aviso intermedio | ACEPTAR #1 ~10:23:20 UTC → «Los datos se han guardado correctamente. Pulse ACEPTAR para continuar» → ACEPTAR #2 ~10:23:34 → popup «CORRECTO / Los datos se han guardado correctamente» con un tercer ACEPTAR (no pulsado) | Divergencia de navegación **pendiente** (§5): SCA2 muestra dos avisos más que SCA |
| 17 | CORE `consultaGestion` tras ACEPTAR | Gestión CA 43704821 → **FINALIZADA POSITIVA**, fecFin 30/09/2026 12:22:52 | Gestión CA 43704819 → **INCOMPLETA** con fecFin 12:23:44 | **Divergencia exclusiva SCA2, corregida** (§4.7/§4.8) |
| 18 | CORE `consultarSolicitudes` | `codEstSolic=2`, fecResolucion 12:22:52 | `codEstSolic=5`, fecResolucion 12:23:44 | Ídem |
| 19 | CORE `consultaDetalleGestion` (argumento 267) | `codTpEstArgumento=1` (positivo), `impCIAContraria=0` | `codTpEstArgumento=0` (**pendiente**) | **Divergencia exclusiva SCA2, corregida** (§4.9) |
| 20 | Record SCA2 (`SCA2_cargarSolicitud`) | n/a | `estadoSolicitud=FINALIZADA`, `interfazActiva=FIN`, `procesoActivo=null`, `estadoTarea=PENDIENTE` (campo no actualizado por CMD Finalizar), version 5, modifiedAt 10:23:45 UTC | Estado esperado tras la corrección: `FINALIZADA_POSITIVO` |
| 21 | Buscador propio tras F5 | «Finalizada positivamente», resolución 12:24:55 | «Finalizada. Anulación realizada», resolución 12:23:45 | Divergencia (consecuencia de 17/18) |
| 22 | Detalle → tarjeta Contra Anulación | **Finalizada Positiva**; argumento INCREMENTO PRIMA SINIESTROS **Positivo** verde; inicio 11:38:45, fin 12:22:52; JJGONZ2 / RED MAPFRE / OFICINA / nivel 1 | **Incompleta**; argumento **Pendiente** gris; inicio 11:38:02, fin 12:23:44; mismos datos de usuario | Divergencia (consecuencia de 17/19) |
| 23 | Misma 15787702 en ambos buscadores | Estado «Finalizada no requerida contraanulación», fecha 11:37:45, resolución 12:23:44, causa Más Prima, obs. «Prueba S1 Devin» | Estado «Finalizada. Anulación realizada», fecha 11:37:54, resolución 12:23:45, causa Más Prima, obs. «-» | Texto de estado, fecha y observaciones **pendientes** (§5) |
| 24 | F5 sobre la pantalla de la acción tras finalizar | n/p (SCA vuelve al buscador) | Reabre el formulario de Contra Anular con 7 argumentos Pendiente aunque la solicitud ya está finalizada | Divergencia **pendiente** (§5) |
| 25 | Flecha volver del Detalle | Error `sca_datoscabecera` / `a!submitLink` (fallo de SCA, ya documentado) | Vuelve a `/sca2/page/buscador` | Fallo de SCA (no se corrige) |
| 26 | Bandeja `/errores` de SCA2 | n/a | «Se ha producido un error» / «La página no existe o no tiene permiso para verla» | No probado (§7). `SCA2_contarErroresPendientes(15787702)` devuelve null (sin errores registrados) |

### 3.1 Análisis de la divergencia de cierre (causa raíz)

1. **Argumento no persistido.** `SCA2_ContraAnulacionModalRecuperacionPoliza` (copia de la de SCA) llama a `SCA2_guardarEjecuArg` con `index(ri!data,"codTipoArgumento")`, `"codCia"`, `"lineaNegocio"`, `"observacionesArgumento"`, `"impCiaContra"`. En SCA, `SCA_ContraAnulacionOpciones*` construye `data: a!map(...)` inline con el argumento seleccionado; en SCA2 `local!data` no contenía esas claves (solo `codCiaUsuario`, `codGestion`, `codSolicitud`…), así que la ejecución del argumento llegaba a CORE sin `codTipoArgumento` y el argumento seguía `codTpEstArgumento=0`. Además `SCA2_ContraAnulacionRehabilitacion` pasaba `anulada: ri!positiva` (SCA pasa `anulada: local!comprobarSolicitud`).
2. **Cierre encadenado a `finalizarSolicitud`.** En SCA, POSITIVO → proceso `SCA Contra Anulación` → `SCA_finalizarContraAnulPca(mcaEstadoFinal=3)` → fin (CORE: gestión FINALIZADA POSITIVA, `codEstSolic=2`). En SCA2, `SCA2 CMD CompletarAccion` llamaba a `Finalizar CA PCA` y después **siempre** arrancaba `SCA2 CMD Finalizar` (`finalizarSolicitud`, FINPCA), que en CORE deja `codEstSolic=5` y la gestión INCOMPLETA con fecha fin, y en el record `FINALIZADA` («Anulación realizada»).
3. El mapa `finalizarCAPca` original (`{codSolicitud, ciaContraria, catalogacion, resultado…}`) no tenía la forma del CDT `finalizarContraAnulPca` (`MSEFinalizarContraAnulPca.finalizarContraAnulDTO{mcaEstadoFinal,nivelIntervencion,codSolicitud,infoUsuario}`), por lo que el `cast` de la integración enviaba la petición vacía. Este punto fue corregido en `SCA2_ContraAnulacionOpciones` **v20 por otra sesión paralela** entre nuestras v19 y v21 (se conserva).

## 4. Divergencias exclusivas de SCA2 corregidas (objetos vivos en TEST)

Procedimiento por objeto: GET vivo → backup local JSON → edición mínima → PUT completo (con `inputs`/`nodes`) → re-GET y comparación → `POST …/test` → repetición UI. Backups y SAIL antes/después en `~/sca2work/backup/` y `~/sca2work/after/` (fuera del repo).

| § | Objeto | UUID | Versión | Cambio |
|---|---|---|---|---|
| 4.1 | `SCA2_BuscadorTabla` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | v4 → v5 | Columna «Estado» con `SCA2_textoEstadoSolicitud` (EN_ACCION → «Solicitud Pendiente» como SCA); causa con `desccausa` en formato SCA («Más Prima»); fecha resolución «-» mientras no esté finalizada (antes mostraba `modifiedAt`) |
| 4.2 | `SCA2_Buscador` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | v10 → v11 | Mapeo de estado/causa para las filas del buscador (coherente con 4.1) |
| 4.3 | `SCA2_AltaSolicitudPage` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v16 → v17 | GUARDAR deshabilitado una vez generada la solicitud (SCA sustituye el formulario por el aviso) |
| 4.4 | `SCA2_ContraAnulacionOpciones` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | v14 → v15 | Título «Contra anulación»; secciones expandidas por defecto; FINALIZAR deshabilitado hasta ejecutar ≥1 argumento con tooltip «Se debe ejecutar al menos 1 argumento» |
| 4.5 | `SCA2_ContraAnulacionCompaniaCatalogacion` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060061` | v2 → v3 | El popup de compañías solo se muestra al pulsar la lupa y se cierra con X/CANCELAR |
| 4.6 | `SCA2_ContraAnulacionOpciones` / `SCA2_ContraAnulacionRehabilitacion` / `SCA2_ContraAnulacionModalRecuperacionPoliza` / `SCA2_ContraAnulacionDescuentos` | `…_20056435` / `…_20060049` / `…_20052951` / `…_20060055` | v18 → v19 / v2 → v3 / v1 → v2 / v1 → v2 | Un solo bloque de confirmación (la modal informativa y la de recuperación no se renderizan a la vez); el formulario se oculta mientras hay una modal abierta; nuevo input `onFinalizarPositivo` en modal/rehabilitación: el ACEPTAR de «Los datos se han guardado correctamente…» arranca `SCA2 CMD CompletarAccion` con `mcaEstadoFinal=3`, `estadoFinalizar=3`, `finalizadoCA=true` (paridad con el submit de la modal de SCA) |
| 4.7 | `SCA2 CMD CompletarAccion` (proceso) | `0000f06f-1307-8000-65b1-7f0000014e7a` | (LCP no expone versión; backup `backup/SCA2_CMD_CompletarAccion.*.json`) | Nodo `Write PDTE_FINALIZAR`: si el cierre es CA positiva escribe `FINALIZADA_POSITIVO`, `interfazActiva=FIN`, `procesoActivo=null` (y `estadoDestino` de la transición); XOR `¿Write fail?`: nueva rama «CA positiva» → End, de modo que **no** se arranca `SCA2 CMD Finalizar` (`finalizarSolicitud`) para el cierre positivo, igual que SCA |
| 4.8 | `SCA2_ContraAnulacionOpciones` | `…_20056435` | v19 → **v20 (otra sesión)** | Mapa `finalizarCAPca` con la forma del CDT `finalizarContraAnulPca` (`MSEFinalizarContraAnulPca{mcaEstadoFinal, nivelIntervencion, codSolicitud, infoUsuario}`), tanto en FINALIZAR como en el cierre positivo. Se documenta porque afecta a este escenario; no lo hizo esta sesión |
| 4.9 | `SCA2_ContraAnulacionOpciones` / `SCA2_ContraAnulacionRehabilitacion` | `…_20056435` / `…_20060049` | v20 → v21 / v3 → v4 | La llamada a `SCA2_ContraAnulacionRehabilitacion` construye `data: a!map(...)` inline (como SCA) con `codCia`, `lineaNegocio`, `codTipoArgumento`, `observacionesArgumento`, `impCiaContra`, `numTipBon`, `codTipBon`, `codCampania`, `mcaEstadoFinal`, `anulaExpertos/Tecnicos`, `observaciones` actuales; nuevo input `anulada` (Boolean) en Rehabilitación pasado a la modal (`anulada: a!defaultValue(ri!anulada,false)`), alimentado con `local!comprobarSolicitud` |
| 4.10 | `SCA2 CMD CompletarAccion` (proceso) | `0000f06f-1307-8000-65b1-7f0000014e7a` | (LCP no expone versión; backup `backup/SCA2_CMD_CompletarAccion.pre_eq.110248.json`, después `after/SCA2_CMD_CompletarAccion.eq.110248.json`) | Nodos `Finalizar CA PCA` (301) y `Aceptar Autorizacion` (302): el input `consulta` de la integración estaba guardado **sin el prefijo `=`**, es decir, como **texto literal** `index(pv!resultado,"finalizarCAPca",null)` en lugar de como expresión. De los 224 inputs con expresión de los 13 PM de SCA2 eran los **únicos dos** sin `=`. Se añade el `=` (diff exacto: +2 caracteres, 33 nodos y 12 pv sin otros cambios) |

Fragmentos relevantes:

```sail
/* 4.9 SCA2_ContraAnulacionOpciones v21 — llamada a rule!SCA2_ContraAnulacionRehabilitacion */
data: a!map(
  numPoliza: local!numPoliza, codSolicitud: ri!idSolicitud, codGestion: local!codGestion,
  nivelIntervencion: local!nivelIntervencion, codCia: local!codCiaUsuario, codCiaUsuario: local!codCiaUsuario,
  nuuma: local!nuuma, codPerfil: local!codPerfil, codSubPerfil: index(local!data, "codSubPerfil", ""),
  /* … codDetalle, canalEntrada, codMotivo, codCausa, tipoCatalogacion, mecanizada, numDoc … */
  observaciones: local!observaciones,
  lineaNegocio: local!lineaNegocio,
  codTipoArgumento: index(local!argumentoSeleccionado, "codTipoArgumento", ""),
  observacionesArgumento: index(local!argumentoSeleccionado, "observaciones", ""),
  impCiaContra: index(local!argumentoSeleccionado, "impCiaContra", null),
  numTipBon: index(local!argumentoSeleccionado, "numTipBon", null),
  codTipBon: index(local!argumentoSeleccionado, "codTipBon", null),
  codCampania: index(local!argumentoSeleccionado, "codIdCampana", null),
  mcaEstadoFinal: local!estadoContraAnul,
  anulaExpertos: tostring(a!defaultValue(index(local!datos, "mcaanulaexperto", null), "false")) = "true",
  anulaTecnicos: tostring(a!defaultValue(index(local!datos, "mcaanulatecnico", null), "false")) = "true"),
anulada: a!defaultValue(local!comprobarSolicitud, false),
```

```sail
/* 4.7 SCA2 CMD CompletarAccion — XOR "¿Write fail?" (nodo 200), nueva condición antes del default (Start finalizar) */
and(a!defaultValue(index(pv!resultado,"finalizadoCA",null),false)=true,
    a!defaultValue(index(pv!resultado,"estadoFinalizar",null),"")="3")   /* → End (nodo 2), etiqueta "CA positiva" */

/* nodo 7 "Write PDTE_FINALIZAR" */
estadoSolicitud: if(<CA positiva>, "FINALIZADA_POSITIVO", "PDTE_FINALIZAR"),
interfazActiva:  if(<CA positiva>, "FIN",  index(index(pv!sol,"estado",null),"interfazActiva",null)),
procesoActivo:   if(<CA positiva>, null(), index(index(pv!sol,"estado",null),"procesoActivo",null))
```

```sail
/* 4.6 SCA2_ContraAnulacionModalRecuperacionPoliza v2 — ACEPTAR de la modal informativa */
a!save(local!mcaVentanaInfo, false), a!save(ri!mcaVentanaInfo, false),
if(a!defaultValue(local!submit, false), ri!onFinalizarPositivo, {})
```

Pruebas LCP tras cada PUT: `POST /interfaces/{uuid}/test` de `SCA2_ContraAnulacionOpciones` (idSolicitud 15787702) y `SCA2_ContraAnulacionRehabilitacion` → HTTP 200, `diagnostics.error=null`.


```sail
/* 4.10 SCA2 CMD CompletarAccion — nodo 301 "Finalizar CA PCA", input consulta (Map) */
-  index(pv!resultado,"finalizarCAPca",null)            /* literal: la integración recibía un texto */
+ =index(pv!resultado,"finalizarCAPca",null)            /* expresión */
/* nodo 302 "Aceptar Autorizacion", input consulta */
-  'type!{…}aceptarAutorizacion'(MSEAceptarAutorizacion: index(pv!resultado,"mSE…
+ ='type!{…}aceptarAutorizacion'(MSEAceptarAutorizacion: index(pv!resultado,"mSE…
```

## 4bis. Fase 3 — Reintento del cierre POSITIVO en SCA2 con la póliza de reserva (grabación `sca2_fase3_reintento_positivo`)

Tras las correcciones 4.6–4.9 se repitió **solo en SCA2** (SCA ya había cerrado 15787701 en Fase 2 y no quedaban pólizas para repetir SCA) el Alta + Contra Anular + POSITIVO con `2002000068129` → **15787713**. Se compararon después las dos UIs sobre 15787713 (SCA lee la misma solicitud de CORE).

| # | Paso | SCA (lectura de 15787713) | SCA2 (15787713) | Veredicto |
|---|---|---|---|---|
| 27 | Alta con la reserva (mismos valores que §1) | n/p | Aviso «…Determinando la acción…» → «Su solicitud se ha generado correctamente…» + OK; **GUARDAR deshabilitado** tras generar (4.3); la UI tardó >90 s en dar el OK, LCP ya devolvía la solicitud creada; se recuperó por buscador sin repetir el Alta (captura 43/44) | Corrección 4.3 verificada |
| 28 | Navegación directa a Contra Anular | n/p | Directa, sin lista/RETOMAR (captura 45) | Igual que SCA (paso 7) |
| 29 | Pantalla Contra Anular | n/p | Título, secciones expandidas, FINALIZAR deshabilitado con tooltip, popup de compañías cerrado (4.4/4.5) | Correcciones verificadas |
| 30 | POSITIVO en INCREMENTO PRIMA SINIESTROS | n/p | Un único bloque de confirmación centrado, formulario oculto (captura 46) | Corrección 4.6 verificada |
| 31 | ACEPTAR ×3 («Se van a finalizar…» → «Los datos se han guardado correctamente…» → «CORRECTO») | SCA: 1 ACEPTAR y vuelve al buscador | Tres ACEPTAR; el tercero vuelve al buscador (capturas 47–49) | Divergencia de navegación **pendiente** (§5.4) |
| 32 | CORE `consultaDetalleGestion` (43704854, arg. 267) | `codTpEstArgumento=1`, `impCIAContraria=0` (idéntico a la gestión SCA 43704821) | Ídem | **Corrección 4.9 verificada** (el argumento ya se persiste como en SCA) |
| 33 | Record SCA2 tras el cierre | n/a | `estadoSolicitud=FINALIZADA_POSITIVO`, `interfazActiva=FIN`, `procesoActivo=null`, `estadoTarea=PENDIENTE`, version 4, modifiedAt 10:43:22 UTC; transiciones `ALTA→DECIDIDA→EN_ACCION→FINALIZADA_POSITIVO` (`SCA2 CMD Alta/Decidir/CrearAccion/CompletarAccion`), todas `OK`; `SCA2 Error` = `[]` | **Corrección 4.7 verificada** (ya no se arranca `SCA2 CMD Finalizar`) |
| 34 | CORE `consultaGestion` tras el cierre desde la UI | Gestión CA **INCOMPLETA**, fecFin null (SCA para 15787701 había quedado FINALIZADA POSITIVA) | Ídem (mismo CORE) | **Divergencia exclusiva SCA2**: el proceso no cerró la gestión (causa raíz en §4bis.1, corregida en 4.10) |
| 35 | Buscador tras F5 | «Solicitud Pendiente», resolución «-» (captura 53) | «Finalizada positivo», resolución «-» (captura 50/54) | Consecuencia de 34: el record local dice finalizada y CORE no |
| 36 | Detalle → tarjeta Contra Anulación | Argumento **Positivo** verde; gestión **Incompleta**; fin «-» (captura 51) | Argumento **Positivo** verde; gestión **Incompleta**; fin «-» (captura 52) | Igual entre sí (ambas leen CORE); ambas reflejan el cierre no realizado |
| 37 | F5 sobre la URL de la acción tras el cierre | n/p | Reabre el formulario de Contra Anular (captura 55) | Divergencia **pendiente** (§5.5) |

### 4bis.1 Diagnóstico de la gestión CORE no cerrada (15787713)

Comprobaciones por LCP (regla temporal de diagnóstico `SCA2_tmpDevinXmlFinalizarCA`, `_a-0001f076-8f0a-8000-9d26-011c48011c48_5483180`, creada en «SCA2 Rules and Constants» y **eliminada** al terminar — `DELETE` 204, `GET` 404):

1. **El XML es idéntico** tanto si `SCA2_finalizarContraAnulPcaIntegracion` recibe el mapa anidado (v20) y hace `cast('type!finalizarContraAnulPca', ri!consulta)` como si SCA (`SCAC_finalizarContraAnulPcaIntegracion`) recibe el CDT: `toxml` produce el mismo cuerpo para los datos de 15787713. El `cast` **no** es la causa.
2. **Los datos CORE de ambas solicitudes son equivalentes**: `consultarDetalleSolicitud` (15787701 vs 15787713) solo difiere en póliza/tercero/fechas/observaciones; `consultaDetalleGestion` devuelve la misma ejecución del argumento 267; los perfiles (`SCA2 Datos Perfiles Pca`: `codcompania 41, codperfil CE_RM, codsubperfil CE_RM_OFICINA, nuuma JJGONZ2`) coinciden con lo que SCA usa (`SCA2_GRP_*` y `SCA_GRP_*` apuntan a los mismos grupos, p. ej. `SCA_CE_RM_OFICINAold`).
3. **Llamada directa a CORE** (`IContraAnularPCA`, `finalizarContraAnulPca`, `mcaEstadoFinal=3`, `codSolicitud=15787713`):
   - con `codPerfil/codSubPerfil` = descripciones («RED MAPFRE»/«OFICINA», como las devuelve `consultaGestion`) o con `codCiaUsuario` null/`0041` → **HTTP 500**, SOAP Fault `codigo 4007` «Ocurrio un error en el acceso a la base de datos. Compruebe que los valores introducidos son correctos.» (`GestionEAO`, `PCA_CORECEAR`). Ocurre igual llamando a la regla **de SCA** `SCA_finalizarContraAnulPca` (solo lectura/test): el error es de CORE ante valores inválidos, no de la integración SCA2.
   - con los **códigos** que envía la UI (`codCiaUsuario 41, nuuma JJGONZ2, codPerfil CE_RM, codSubPerfil CE_RM_OFICINA, nivelIntervencion 1`) a través de la integración **SCA2** → `<respuesta>true</respuesta>`: gestión 43704854 **FINALIZADA POSITIVA** (fecFin 30/09/2026 12:58:45) y `consultarSolicitudes` → `codEstSolic=2`, `fecResolucion 12:58:45`, igual que la SCA 15787701. La integración y el payload de SCA2 son válidos.
4. **Causa raíz del fallo en el proceso**: en `SCA2 CMD CompletarAccion` el input `consulta` del nodo `Finalizar CA PCA` carecía del prefijo `=` (ver 4.10), por lo que la integración recibía el **texto** `index(pv!resultado,"finalizarCAPca",null)`, el `cast` generaba una petición vacía y CORE respondía 4007. En el momento del reintento (10:43 UTC) el nodo además **descartaba** `Success/Result/Error` y el PM terminaba sin `SCA2 Error` (por eso `SCA2 Error=[]` y la UI mostraba CORRECTO). Otra sesión paralela añadió después (≈11:01 UTC, backup `SCA2_CMD_CompletarAccion.110125.json`) las pv `caSuccess/caErr/caBody`, el XOR `¿CA ok?` (320) y `Capturar error CA` (321) → `Write Error`, de modo que un nuevo fallo quedaría en la bandeja `/errores` con el `faultstring`. Esta sesión solo añadió el `=` (4.10).
5. **Pendiente de re-ejecución UI**: la corrección 4.10 no se ha podido probar de extremo a extremo desde la UI porque las tres pólizas asignadas ya tienen solicitud (15787701, 15787702, 15787713). Hace falta una póliza NSE nueva para repetir Alta → POSITIVO → ACEPTAR y comprobar `consultaGestion` = FINALIZADA POSITIVA sin intervención por LCP.

Estado final de las gestiones CA (CORE, 30/09/2026 ~13:00): 15787701 → 43704821 FINALIZADA POSITIVA (cerrada por la UI de SCA, 12:22:52); 15787702 → 43704819 INCOMPLETA con fecFin 12:23:44 y `codEstSolic=5` (cierre erróneo vía `finalizarSolicitud` de la versión previa a 4.7, no se ha tocado); 15787713 → 43704854 FINALIZADA POSITIVA (cerrada por LCP con la integración SCA2 en el diagnóstico, 12:58:45). El record SCA2 de 15787713 (`FINALIZADA_POSITIVO/FIN`) es ahora coherente con CORE; el buscador SCA debe mostrar ya «Finalizada positivamente» (no re-verificado en UI).

## 5. Divergencias pendientes (no corregidas) y motivo

| § | Divergencia | Motivo de no corregir |
|---|---|---|
| 5.1 | Cancelar en Alta conserva el filtro de póliza en SCA2 (SCA limpia la búsqueda) | **Corregida en ronda 2** (§9.2, `SCA2_Buscador` v13) |
| 5.2 | Buscador SCA2: fecha de solicitud = `createdAt` del record (+9 s frente a `fecSolicitud` CORE) y observaciones «-» (SCA muestra las de CORE) | **Corregida en ronda 2** (§9.2: `CMD Alta` persiste `fecSolicitud` CORE en `SCA2 Datos Solicitud`; `SCA2_BuscadorTabla` v6 la muestra desde el record) |
| 5.3 | SCA2 no encuentra solicitudes creadas en SCA (15787701) al buscar por póliza | SCA2 solo lista records `SCA2 Solicitud`; que muestre solicitudes de SCA es una decisión funcional (doc 11 §alineación) |
| 5.4 | Tras POSITIVO, SCA2 muestra dos avisos más («Los datos se han guardado correctamente…» y «CORRECTO») antes de volver al buscador; SCA vuelve directo | **Corregida en ronda 2** (§9.2: avisos suprimidos, `onVolver` hasta `SCA2_DetalleTareas`). La rama de éxito sigue **sin validar por UI** porque CORE falló en los dos ciclos (§9.4) |
| 5.5 | F5 sobre la URL de la acción con la solicitud finalizada reabre el formulario de Contra Anular en SCA2 (SCA no tiene URL directa) | **Corregida en ronda 2** (§9.2, guard en `SCA2_DetalleSolicitud` v21: «La tarea solicitada no está disponible», validado por UI en 15787719 y 15787722) |
| 5.6 | Texto de estado en cruce SCA/SCA2 de 15787702 («Finalizada no requerida contraanulación» vs «Finalizada. Anulación realizada») | Consecuencia del cierre erróneo previo a 4.7 (`codEstSolic=5`); no se re-cierra 15787702 |
| 5.7 | Record `FINALIZADA_POSITIVO` aunque CORE falle (gestión INCOMPLETA; SCA muestra Pendiente) | **Sigue pendiente — lo lleva S5** (`SCA2 CMD CompletarAccion`, no tocado por S1 en la ronda 2). Reproducido en 15787719 (PM v17) y en 15787722 (PM v19): la UI ya no muestra CORRECTO sino el error CORE, pero el nodo 7 `Write PDTE_FINALIZAR` sigue escribiendo `FINALIZADA_POSITIVO`/`FIN` **antes** del nodo 301 `Finalizar CA PCA` y la rama 321→199 no revierte el estado (§9.4) |

Problemas **comunes / de SCA** (no se corrigen): flecha «volver» del Detalle de SCA (error `sca_datoscabecera` / `a!submitLink`, paso 13/25); tiempos de Alta de 40–90 s en ambas apps (servicios CORE/motor de reglas); CORE responde 4007 ante `codPerfil` descriptivo o `codCiaUsuario` vacío también desde la regla de SCA.

## 6. Records, tareas y errores SCA2 (15787713)

- `SCA2 Solicitud`: id 39, `FINALIZADA_POSITIVO`, `interfazActiva FIN`, `procesoActivo null`, `nivelIntervencion 1`, `grupoAsignacion CE_RM`, `estadoTarea PENDIENTE` (campo no actualizado por CompletarAccion — igual que en 15787702, ver paso 20), version 4.
- `SCA2 Transicion`: `SCA2 CMD Alta` ALTA→null, `SCA2 CMD Decidir` ALTA→DECIDIDA, `SCA2 CMD CrearAccion` DECIDIDA→EN_ACCION, `SCA2 CMD CompletarAccion` EN_ACCION→FINALIZADA_POSITIVO (10:43:22 UTC), resultado OK.
- `SCA2 Error`: sin filas para 15787713 (consulta por LCP). La bandeja `/errores` **no es verificable por UI** con JJGONZ2 («La página no existe o no tiene permiso para verla»: `visibilityExpr` restringida a `SCA2_GRP_ADMINISTRADORES`); la ausencia de errores se afirma únicamente por la consulta LCP al record type.

## 7. Limitaciones y pasos no ejecutados

- No se ejecutó NEGATIVO, POSPONER, CANCELAR solicitud, REASIGNAR ni FINALIZAR manual (en el cierre positivo SCA no lo requiere).
- El reintento (Fase 3) se hizo solo en SCA2; SCA se comparó leyendo la misma solicitud. La corrección 4.10 queda **sin prueba UI** por falta de póliza (ver 4bis.1.5).
- Versiones de los PM: LCP devuelve `versionId` vacío para process models; se conservan backups JSON antes/después en `~/sca2work/backup|after`.
- No existe lint/typecheck aplicable al repositorio para este entregable (solo documentación Markdown; los objetos Appian se validaron con `POST …/test` HTTP 200 y `diagnostics.error=null`).
- La cuenta LCP no es JJGONZ2: las pruebas de interfaz por LCP evalúan `loggedInUser()` con el usuario técnico; la persistencia real se comprobó con la UI (JJGONZ2) y con las consultas a CORE.

## 8. Evidencias (fuera del repo)

Grabaciones: `sca_sca2_alta_fase1`, `sca_sca2_fase2_positivo_finalizar` (`…/sca_sca2_fase2_positivo_finalizar-edited.mp4`), `sca2_fase3_reintento_positivo` (`…/sca2_fase3_reintento_positivo-edited.mp4`).
Capturas Fase 2: 30–40 (`30_sca2_pendiente_tras_f5`, `31_sca_confirmacion`, `31_sca2_confirmacion`, `32_sca_aceptar_retorna_buscador`, `32_sca2_aviso_guardado`, `33_sca2_segundo_aceptar_correcto`, `34_sca2_f5_argumentos_pendientes`, `35_sca2_buscador_propia`, `36_sca_detalle_contra_positiva`, `36_sca2_detalle_contra_incompleta`, `37_sca_buscador_ambas_finalizadas`, `37_sca2_cruce_15787701_sin_resultados`, `38_sca_error_volver`, `39_sca_cruce_detalle_15787702`, `40_sca2_errores_sin_permiso`). Fase 3: 41–55 (`41_sca2_reserva_sin_solicitud` … `55_sca2_f5_accion_reabre_formulario`).
Objetos de SCA leídos sin modificar: `SCA_ContraAnulacionOpcionesEstrategicas` (v8), `SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas` (v7), `SCA_ContraAnulacionModalInformativoEstrategicas` (v3), PM `SCA Contra Anulación`, `SCA Finalizar Contra Anulacion`, `SCA_finalizarContraAnulPca`, `SCA_obtenerInformacionUsuario`, constantes `SCA_GRP_*`.

## 9. Ronda 2 — correcciones 5.1/5.2/5.4/5.5 y ciclos completos en SCA2 (pólizas nuevas)

Pólizas asignadas en la ronda 2 (Devin Bot, 30/09/2026): `2002000058825` (SCA2, ciclo completo) y `2002000011336` (reserva). SCA se comparó **en lectura** sobre las mismas solicitudes (mismo backend CORE), sin alta nueva en SCA.

### 9.1 Solicitudes creadas en la ronda 2

| Póliza | App Alta | idSolicitud | Alta (gestión CORE) | Contra Anular (gestión CORE) | `codEstSolic` | Record `SCA2 Solicitud` | Instancia `SCA2 CMD CompletarAccion` |
|---|---|---|---|---|---|---|---|
| `2002000058825` | SCA2 | **15787719** | 43704868, accion 8, FINALIZADA, `fecSolicitud 30/09/2026 13:29:08`, obs. «Prueba S1 Devin ciclo2» | 43704870, accion 2, **INCOMPLETA**, inicio 13:29:26, sin fecha fin | 2 | `FINALIZADA_POSITIVO`, `interfazActiva FIN`, `procesoActivo null`, `estadoTarea PENDIENTE` | processId 521788, **COMPLETED** (no pausada), PM v17.0, 8 tareas, 11:31:32–11:31:40 UTC; `wrErr=true`, `wrCodigo=FINALIZAR_CA_ERROR` |
| `2002000011336` | SCA2 | **15787722** | 43704874, accion 8, FINALIZADA, `fecSolicitud 30/09/2026 13:40:25`, obs. «Prueba S1 Devin ciclo3» | 43704875, accion 2, **INCOMPLETA**, inicio 13:40:42, sin fecha fin | 2 | `FINALIZADA_POSITIVO`, `interfazActiva FIN`, `procesoActivo null`, `estadoTarea PENDIENTE`, `modifiedAt 11:42:30 UTC` | processId 537393577, **COMPLETED** (no pausada), PM **v19.0** (versión de S5), 11:42:27–11:42:33 UTC; `wrErr=true`, `wrNodo=Finalizar CA PCA`, `wrCodigo=FINALIZAR_CA_ERROR`, `wrErrMsg=Failed to connect to https://core7.pre.mapfre.net:26007/PCA_CORECFSA_HTTPRouter/IContraAnularPCA` |

`SCA2 Error`: `SCA2_contarErroresPendientes(idSolicitud, comando)` devuelve **1** para 15787719 con `comando="SCA2 CMD CompletarAccion - 30/09/2026 13:31 CEST"` (v17 guardaba `pp!name`) y **1** para 15787722 con `comando="SCA2 CMD CompletarAccion"` (v19 guarda `index(split(pp!name," - "),1)`), estado PENDIENTE en ambos. Ningún ciclo llevaba adjuntos, por lo que «Subir documentos GD» (aviso S4) no aplicó: las dos instancias terminaron COMPLETED.

### 9.2 Objetos SCA2 modificados en la ronda 2 (GET vivo → backup → PUT completo → re-GET → `POST …/test` HTTP 200, `diagnostics.error=null` → UI)

| § | Objeto | UUID | Versión | Cambio (paridad con SCA) |
|---|---|---|---|---|
| 5.1 | `SCA2_Buscador` | `…_20055660` | v12 → **v13** | Los filtros (`local!fPoliza`, `fSolicitud`, `fNombre`, `fApe1`, `fApe2`, `fTipoDoc`, `fNumDoc`, `eleccionPoliza`, `fEstado`, `fLineaNegocio`, `fMatricula`, `fBastidor`) pasan a `a!refreshVariable(value: null, refreshOnVarChange: ri!vista)`: al volver de Alta (Cancelar) la búsqueda queda limpia y se muestra la lista de últimas solicitudes, como SCA. La query añade los campos relacionados `datosSolicitud.fecsolicitudanul` y `datosSolicitud.fecimpresion` |
| 5.2 | `SCA2_BuscadorTabla` | `…_20056379` | v5 → **v6** | Columna «Fecha solicitud» = `SCA2 Datos Solicitud.fecsolicitudanul` (fecha CORE; `createdAt` solo como fallback) y columna «Observaciones» = `SCA2 Datos Solicitud.fecimpresion` (observaciones del Alta), leídas del record relacionado, sin llamar a CORE por fila |
| 5.2 | PM `SCA2 CMD Alta` | `0000f06f-28fc-8000-6693-7f0000014e7a` | (LCP sin versión; backup `r2/backup/pm_SCA2_CMD_Alta_v_112257.json`) | Nodo 8 `Write Datos`: `fecsolicitudanul` se rellena con `fecSolicitud` de `SCA2_consultarSolicitudes(numPoliza, "", "0")` filtrando por `idSolicitud` (fallback `now()`); 22 nodos / 32 pv conservados. Verificado: `fecsolicitudanul = 30/09/2026 13:29:08` (15787719) y `13:40:25` (15787722), idénticas a `fecSolicitud` CORE y a lo que muestra SCA |
| 5.4 | `SCA2_ContraAnulacionModalRecuperacionPoliza` | `…_20052951` | v2 → v3 → **v4** | El ACEPTAR de la confirmación positiva ya no muestra «Los datos se han guardado correctamente. Pulse ACEPTAR para continuar»: `{a!save(ri!return, true), a!save(ri!mcaVentanaInfo, false), ri!onFinalizarPositivo}` en las dos ramas positivas. v4 añade el cierre de la ventana de recuperación (`mcaVentanaInfo=false`) porque en v3 el error CORE se pintaba en **dos bloques** (captura 68); en 15787722 aparece **una sola vez** (captura 86) |
| 5.4 | `SCA2_ContraAnulacionOpciones` | `…_20056435` | v24 → **v25** (hoy v26 por S2, `a!submitUploadedFiles`; cambio conservado) | Nuevo input `onVolver`; el cierre positivo lo invoca en lugar de `onCompletar` (no se muestra el popup CORRECTO). No se tocó la subida de documentos (S2) |
| 5.4 | `SCA2_ContraAnulacionPrincipal` | `…_20056441` | v3 → **v4** | Nuevo input `onVolver`, pasado a `SCA2_ContraAnulacionOpciones` |
| 5.4 | `SCA2_DetalleTareas` | `…_20055554` | v7 → **v8** | `onVolver` = `{a!save(ri!accionAbierta,false), a!save(ri!tipoAccion,null), a!save(ri!idTareaAccion,null), a!save(local!hecho,false), a!save(ri!idSolicitud,null)}` → vuelve directo al buscador como SCA |
| 5.5 | `SCA2_DetalleSolicitud` | `…_20055572` | v20 → **v21** (hoy v22 por otra sesión; guard conservado) | `local!solicitudCerrada: or(interfazActiva="FIN", contains({FINALIZADA, FINALIZADA_SIN_ANULAR, FINALIZADA_POSITIVO, RECHAZADA, CANCELADA, CADUCADA, CADUCADA_NEGATIVA}, estadoSolicitud))`; si llega `ri!tipoAccion` con la solicitud cerrada se muestra el Detalle con la tarjeta WARN «La tarea solicitada no está disponible» (texto de SCA) en vez de reabrir el formulario |

No se modificó `SCA2 CMD CompletarAccion` (S5) ni ningún objeto de SCA/SCAC/CORE. Backups y JSON posteriores en `~/sca2work/r2/backup|after` (fuera del repo).

### 9.3 Tabla paso a paso ronda 2 (SCA2 con 2002000058825 → 15787719 y 2002000011336 → 15787722; SCA en lectura)

| Paso | SCA (referencia) | SCA2 | Veredicto |
|---|---|---|---|
| Buscador por póliza nueva | «Sin resultados» y botón Alta | Igual (capturas 60, 80) | igual |
| Alta → Cancelar | Vuelve al buscador con la búsqueda limpia y la lista de últimas solicitudes | v13: filtros vacíos, BUSCAR deshabilitado, lista restablecida (62) | divergencia corregida (5.1) |
| Alta (segunda, misma póliza) | Formulario con datos de la póliza | Igual; motivo DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, PRESENCIAL, A VENCIMIENTO, fecha automática (63, 81) | igual |
| Guardar → aviso → redirección | Aviso «generado correctamente…» y navega a Contra Anular | «Determinando la acción…» → «Se le va a redirigir a la acción correspondiente» → OK abre Contra Anular directamente (64–65, 82–83) | igual |
| Argumentarios GAIA | 8 argumentos; obligatorio según póliza | 8 argumentos; INCREMENTO PRIMA PLATINO (15787719) / INCREMENTO PRIMA SINIESTROS (15787722) (66, 84) | igual |
| POSITIVO → confirmación | Un bloque «¡Enhorabuena en la retención de la póliza!…» | Un solo bloque, formulario oculto (67, 85) | igual |
| ACEPTAR → cierre CORE | SCA: `SCA_finalizarContraAnulPca` (no probado en esta ronda: no hubo alta en SCA) | Error CORE «Failed to connect …/IContraAnularPCA», una sola vez en v4 (dos veces en v3, corregido) (68, 86) | no probado en SCA / servicio externo caído |
| Estado tras el fallo CORE — buscador | **Pendiente**, resolución «-» | **Finalizada positivo**, resolución `13:42:30` (69, 87, 72, 89) | divergencia pendiente (5.7, S5) |
| Estado tras el fallo CORE — detalle | Contra Anulación **Incompleta**, argumento **Positivo** verde, usuario JJGONZ2 RED MAPFRE/OFICINA nivel 1 | Igual (70, 73, 88, 90, 91) | igual (tarjeta CORE) |
| Fecha solicitud / observaciones en buscador | `2026-09-30 13:29:08` / `13:40:25`; «Prueba S1 Devin ciclo2/3» | `30/09/2026 13:29:08` / `13:40:25`; mismas observaciones (69/72, 87/89) | divergencia corregida (5.2) |
| F5 sobre `/suite/sites/sca2/page/buscador?$sp=…` con acción finalizada | SCA: «La tarea solicitada no está disponible» | Detalle con tarjeta «La tarea solicitada no está disponible», sin reabrir el formulario (75, 92) | divergencia corregida (5.5) |
| Retorno directo al buscador tras cierre positivo con éxito | Vuelve directo | No validable: CORE falló antes en los dos ciclos | no probado |

### 9.4 Diagnóstico del fallo de cierre en la ronda 2

- **Servicio externo**: `IContraAnularPCA` (`https://core7.pre.mapfre.net:26007/PCA_CORECFSA_HTTPRouter/IContraAnularPCA`) devolvió `Failed to connect` a las 11:31 y 11:42 UTC desde el PM; el resto de servicios CORE (alta, argumentos, consulta de gestiones, `IGenerarContraAnul`) respondieron. No es una divergencia de SCA2 y no se reintentó ningún cierre (no se relanzaron los `SCA2 Error`).
- **Divergencia SCA2 pendiente (5.7 / S5)**: en `SCA2 CMD CompletarAccion` (v17 y v19 vivos) el flujo es `7 Write PDTE_FINALIZAR` → `310 Subir documentos GD` → `300` → `301 Finalizar CA PCA` → `320 ¿CA ok?` → (KO) `321 Capturar error CA` → `199 Write Error` → End. El nodo 7 ya escribe `estadoSolicitud=FINALIZADA_POSITIVO`, `interfazActiva=FIN`, `procesoActivo=null` cuando `finalizadoCA=true` y `estadoFinalizar="3"`, y la rama de error no lo revierte: por eso SCA2 muestra «Finalizada positivo» y SCA «Pendiente» con la misma gestión INCOMPLETA. La UI ya no muestra CORRECTO (v19 + Modal v4 de S1): muestra el error CORE y «queda registrado en la bandeja de errores para su relanzamiento».
- Los dos avisos suprimidos (5.4) no aparecieron; el retorno directo al buscador en la rama de éxito solo podrá validarse cuando `IContraAnularPCA` vuelva a responder, con una póliza nueva autorizada.

### 9.5 Evidencias ronda 2 (fuera del repo)

- Grabaciones: `sca2_s1_ciclo2` (`~/screencasts/sca2_s1_ciclo2/sca2_s1_ciclo2-edited.mp4`, 2002000058825) y `sca2_s1_ciclo3` (`~/screencasts/sca2_s1_ciclo3/sca2_s1_ciclo3-edited.mp4`, 2002000011336).
- Capturas ciclo 2 (`~/sca2work/shots/`): `60_sca2_popup_alta`, `61_sca2_alta_antes_cancelar`, `62_sca2_cancelar_filtros_limpios`, `63_sca2_alta_ciclo2_rellena`, `64_sca2_alta_generada_esperando`, `65_sca2_alta_generada_ok`, `66_sca2_argumentos_platino`, `67_sca2_confirmacion_positivo`, `68_sca2_error_finalizar_duplicado` (v3), `69_sca2_buscador_15787719`, `70_sca2_detalle_positivo_incompleta`, `71_sca2_url_accion_retorna_buscador`, `72_sca_buscador_15787719`, `73_sca_detalle_positivo_incompleta`, `74_sca2_detalle_comparativa`, `75_sca2_f5_banner_tarea_no_disponible`.
- Capturas ciclo 3: `80_sca2_ciclo3_sin_resultados`, `81_sca2_alta_ciclo3_rellena`, `82_sca2_alta_generada_esperando`, `83_sca2_alta_ok`, `84_sca2_argumentos_siniestros`, `85_sca2_confirmacion_positivo`, `86_sca2_error_core7_unico` (v4, un solo bloque), `87_sca2_buscador_15787722`, `88_sca2_detalle_incompleta`, `89_sca_buscador_15787722`, `90_sca_detalle_incompleta`, `91_sca2_detalle_comparativa`, `92_sca2_f5_tarea_no_disponible`.
- La bandeja `/errores` sigue sin ser visible para JJGONZ2 (solo administradores); los `SCA2 Error` se verificaron por LCP.

### 9.6 Decisión técnica a revisar

Devin Bot pidió persistir `fecSolicitud`/`observaciones` en `SCA2 Solicitud`. Se ha hecho **sin cambiar el esquema**: `CMD Alta` ya escribía el record relacionado `SCA2 Datos Solicitud` (1:N), cuyos campos `fecsolicitudanul` y `fecimpresion` contienen la fecha CORE y las observaciones del Alta, y el buscador los lee por la relación `datosSolicitud`. Si se prefiere un campo propio en `SCA2 Solicitud` (y que los CMD que modifican observaciones lo actualicen), hay que añadirlo al record type/tabla: no se ha hecho para no alterar el modelo compartido con S2/S3/S5.
