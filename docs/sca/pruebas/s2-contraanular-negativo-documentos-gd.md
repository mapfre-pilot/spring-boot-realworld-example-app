# S2 — Contra Anular NSE con NEGATIVO, documentos por motivo y subida a Gestión Documental (Documentum)

Prueba comparativa funcional **SCA (referencia) vs SCA2** en Appian TEST (`mapfrespain-test`), ejecutada el 30/09/2026 con el usuario funcional `JJGONZ2` (SSO NOPRO). SCA TEST es la referencia: toda divergencia exclusiva de SCA2 se corrige en SCA2; no se ha modificado ningún objeto de SCA, SCAC, CORE, GAIA, PRE ni Documentum.

Sesión Devin: https://mapfre.devinenterprise.com/sessions/2fdc9d72428e4b56ae2073f058b8cbff

## 1. Pólizas y solicitudes

| App | Póliza | Solicitud CORE | Gestión Alta (acción 8) | Gestión Contra Anular (acción 2) | Estado final `codEstSolic` |
|---|---|---|---|---|---|
| SCA | `2002000050936` | **15787705** | 43704823 `FINALIZADA` | 43704825 `FINALIZADA NEGATIVA` (+ 43704828 acción 4 `FINALIZADA`, 43704830 acción 5 `INCOMPLETA`) | `2` (pendiente; redirigida a anulación, **no** se pulsó ANULAR PÓLIZA) |
| SCA2 | `2001900027763` | **15787706** | 43704826 `FINALIZADA` | 43704827 `FINALIZADA` (tras FINALIZAR) | `5` (resolución 30/09/2026 12:04) |

La póliza de reserva `2002000004992` no se usó. No se tocó ninguna solicitud ajena (durante la UI se abrió por error el detalle de `15787707` sin ejecutar ninguna acción).

Motivo/causa usados en ambas: motivo `1` / detalle `1` / causa `1` **«ME HA SUBIDO MUCHO LA PRIMA»**, catalogación `2` (a vencimiento, fecha anulación 01/01/2027), canal `CE_RM`, observación de alta `Prueba S2`. Ambas altas quedan en CORE como gestión acción 8 `FINALIZADA` con la misma observación (S1 cubre la cabecera en detalle).

## 2. Tabla paso a paso

| # | Paso | SCA (15787705) | SCA2 (15787706) | Veredicto |
|---|---|---|---|---|
| 1 | Alta con motivo «me ha subido mucho la prima», catalogación a vencimiento | Alta OK; gestión 43704823 acción 8 `FINALIZADA`, obs. `Prueba S2` | Alta OK; gestión 43704826 acción 8 `FINALIZADA`, obs. `Prueba S2`; record `SCA2 Solicitud` id 37 `estadoSolicitud=ALTA→…`, `origen=SCA2` | igual |
| 2 | Pantalla Contra Anular — selección de argumento en el argumentario | Grid de argumentos seleccionable; argumento 267 `INCREMENTO PRIMA SINIESTROS` | **Error** al seleccionar fila: `Cannot compare incompatible operands of type Number (Integer) and type List of Variant` (modal de error) | **divergencia exclusiva SCA2 → corregida** (`SCA2_ContraAnulacionArgumentarioEstrategicas` v1→v2, §4.1) |
| 3 | Sección Documentación: documentos configurados por motivo | Servicio CORE `SCA_consultarDocumentos(15787705)` → `MSSConsultarDocumentos=null` antes de subir nada; la interfaz muestra la lista fija de tipos documentales (Carta firmada, DNI…) con una fila por documento y carga individual | `SCA2_consultarDocumentos(15787706)` → `MSSConsultarDocumentos=null`; misma lista de filas/tipos y carga individual | igual (lista por motivo `null` en **ambas** apps: comportamiento común del servicio CORE, no se corrige) |
| 4 | Subida del mismo PDF (605 bytes, 1 página) al tipo **Carta firmada** (tipo documental `6`) | Fila actualizada con el nombre del fichero, sin mensaje adicional; el documento queda en `local!listaNombreDocs` (`<idDoc>_6`) | Fila actualizada igual; sin mensaje adicional | igual (en pantalla) |
| 5 | Marcar argumento **NEGATIVO** | Botón NEGATIVO → estado rojo `NEGATIVO` en la fila; sin observaciones obligatorias; CORE `codTpEstArgumento=2` | Estado rojo `NEGATIVO` en pantalla, pero al reabrir la solicitud volvía a `Pendiente` y CORE `codTpEstArgumento=0` | **divergencia exclusiva SCA2 → corregida** (`SCA2_ContraAnulacionOpciones` v13→v14, §4.2). Tras la corrección: NEGATIVO persiste y `codTpEstArgumento=2` en ambas |
| 6 | Imprimir plantilla / carta (PDF generado con `SCA_PM_DOCXPDF` vs `SCA2_PM_DOCXPDF`) | Se abre visor con PDF de 2 páginas «COMUNICACIÓN DE OPOSICIÓN A LA RENOVACIÓN DE LA PÓLIZA»; gestión acción 4 (Impresión) `FINALIZADA` | El PDF se genera (`plantillaCarta` informado) y se habilita FINALIZAR, pero **no se abre el visor** ni hay mensaje | **divergencia exclusiva SCA2 → corregida** (`SCA2_ContraAnulacionOpciones` v16→v17, §4.3). **Sin re-prueba UI** (la solicitud ya estaba finalizada); validada solo con `POST /interfaces/{uuid}/test` = 200 |
| 7 | FINALIZAR con resultado negativo — confirmación | Modal «Se van a finalizar las acciones de contra anulación. ¿Desea continuar?» | Modal «¿Desea continuar? / Se va a finalizar la gestión de contra anulación» | igual (texto ligeramente distinto, misma semántica) |
| 8 | FINALIZAR — resultado en pantalla | Mensaje «Se va a redirigir a la anulación.» y navega a la pantalla de anulación (no se pulsó ANULAR PÓLIZA) | Mensaje «CORRECTO / Los datos se han guardado correctamente» y vuelve al buscador | **divergencia pendiente** (SCA encadena la anulación; SCA2 cierra la gestión). Ver §3.3 |
| 9 | Estados CORE tras FINALIZAR | Gestión CA 43704825 `FINALIZADA NEGATIVA`; `codEstSolic=2`; argumento 267 `codTpEstArgumento=2`; `observaciones="#&#"` | Gestión CA 43704827 `FINALIZADA`; `codEstSolic=5`; argumento 267 `codTpEstArgumento=2`; `observaciones=null`; `SCA2 Solicitud.estadoSolicitud=FINALIZADA`, `interfazActiva=FIN` | **divergencia pendiente** (estado de gestión/solicitud distintos; ver §3.3) |
| 10 | Buscador tras FINALIZAR | Solicitud `Pendiente` (mecanización incompleta) | `Finalizada. Anulación realizada` | divergencia pendiente (consecuencia de #8/#9) |
| 11 | Detalle tras FINALIZAR — tarjeta Contra Anulación | `Finalizada Negativa`; Impresión `Finalizada`; Mecanización `Incompleta` | Cabecera `FINALIZADA NO REQUERIDA CONTRAANULACIÓN`; tarjeta Contra Anulación `Incompleta` (incoherente con CORE, que devuelve la gestión finalizada) | **divergencia pendiente** exclusiva SCA2 (§3.3) |
| 12 | Detalle — «Documentos presentados por el cliente» | Fila `Carta firmada`, id Documentum `0900ab4481a049c7`, fecha 30/09/2026. `SCA_consultarDocumentos(15787705)` → `{listaDocumentos:[{idDocumento:"0900ab4481a049c7",tipoDocumento:"6",fechaDocumento:"2026-09-30"}]}` | «No hay documentos a mostrar». `SCA2_consultarDocumentos(15787706)` → `MSSConsultarDocumentos=null` (CORE no tiene ningún documento registrado para la solicitud SCA2) | **divergencia pendiente** exclusiva SCA2: la subida a GD/BBDD de SCA2 no ha dejado rastro en CORE (§3.2) |
| 13 | Regla de lectura de documentos con datos reales | `SCA_consultarDocumentos(15787705)` OK (ver #12) | `SCA2_consultarDocumentos(15787705)` (misma solicitud SCA, vía backend común) → **error** `a!forEach [line 28] … Error de evaluación de expresión` | **divergencia exclusiva SCA2 → corregida** (`SCA2_searchDocumentos` era recursiva; §4.4). Tras la corrección devuelve exactamente lo mismo que SCA |
| 14 | Búsqueda cruzada (solicitud SCA en el buscador SCA2) | El buscador SCA consulta CORE y encuentra `15787706` (creada en SCA2) | El buscador SCA2 solo consulta el record `SCA2 Solicitud` (`a!queryRecordType`, filtro `idSolicitud not starts with PDTE-`) y **no** encuentra `15787705` | divergencia de diseño SCA2 (no corregida; decisión funcional pendiente, §6) |
| 15 | Bandeja de errores SCA2 (`/errores`) | n/a | «La página no existe o no tiene permiso para verla». La página del site tiene `visibilityExpr = a!isUserMemberOfGroup(loggedInUser(), cons!SCA2_GRP_ADMINISTRADORES)`; JJGONZ2 no es administrador. Por LCP, `SCA2_contarErroresPendientes(15787706, "SCA2 CMD CompletarAccion"/"SCA2 CMD Finalizar")` = `0` | no probado por UI (permisos); por LCP no hay errores pendientes |

## 3. Divergencias

### 3.1 Corregidas (exclusivas de SCA2)

| Divergencia | Causa raíz | Corrección |
|---|---|---|
| Error al seleccionar argumento en el argumentario | `a!save(ri!indiceArgumentoSeleccionado, local!selection)` guardaba una lista en un input entero | `tointeger(index(local!selection, 1, null))` (§4.1) |
| NEGATIVO no persistía en CORE (`codTpEstArgumento=0`) | `SCA2_ContraAnulacionOpciones` enviaba a `SCA2_guardarEjecuArg` una gestión incorrecta como `codGestion`; SCA filtra la gestión Contra Anular por `accionRealizada="2"` y `codEstGestion="INCOMPLETA"` | Misma selección de gestión que SCA con fallback a `idgestionsgc` (§4.2) |
| No se mostraba el visor de la plantilla tras Imprimir | SCA renderiza `SCA_VisualizarDocumentoContraanularEstrategicas`; SCA2 guardaba `plantillaCarta` y `mcaVisualizarDoc` pero no renderizaba `SCA2_VisualizarDocumentoContraanularEstrategicas` | Añadido el bloque del visor con `showWhen: local!mcaVentanaVisualizarDoc` (§4.3). **Pendiente de re-prueba UI** |
| `SCA2_consultarDocumentos` falla cuando CORE devuelve documentos | `SCA2_searchDocumentos` se llamaba **a sí misma** (recursión infinita) en lugar de la integración `search-web/api/sgd/1.0/advancedSearch` (en SCA: `SCAC_searchDocumentos`). SCA2 no tenía integración equivalente | Creada `SCA2_searchDocumentosIntegracion` (clon aislado de `SCAC_searchDocumentos`) y `SCA2_searchDocumentos` v2→v3 la invoca con `cons!SCA2_WEBSERVICES_URL` (§4.4) |

### 3.2 Pendiente exclusiva SCA2 — el documento subido en SCA2 no queda registrado en CORE/GD

- SCA: al FINALIZAR, el PM `SCA_Finalizar_Contra_Anulacion` ejecuta el subproceso «Subir Docs Documentum BBDD» → alta en Documentum (`SCAC_altaDocumentoIntegracion`) + registro en BBDD CORE (`SCA_modificarCrearDocumentosCarta`). Resultado verificable: `SCA_consultarDocumentos(15787705)` devuelve `idDocumento=0900ab4481a049c7`, tipo `6`.
- SCA2: `SCA2_CMD_CompletarAccion` nodo 7 «Write PDTE_FINALIZAR» → nodo 310 «Subir documentos GD» (`rule!SCA2_subirDocumentosGD(codSolicitud: pv!idSolicitud, listaNombreDocs: index(pv!resultado,"listaNombreDocs",{}), tipoGestion, nuuma)`) → nodo 311 «¿Docs GD ok?» → 300 «Llamada cierre?» → 301 `SCA2_finalizarContraAnulPca`. `SCA2_ContraAnulacionOpciones` sí envía `listaNombreDocs: local!listaNombreDocs, tipoGestion: "CA"` en el `resultado` del FINALIZAR (líneas 675-680 de la v17), y `SCA2_altaDocumento` / `SCA2_modificarCrearDocumentosCarta` son idénticas a las de SCA salvo el prefijo.
- Evidencia: `SCA2_consultarDocumentos(15787706)` y `SCA_consultarDocumentos(15787706)` → `MSSConsultarDocumentos=null`; no hay filas `SCA2 Error` pendientes para la solicitud; el proceso terminó con `CORRECTO`.
- Hipótesis (no verificables sin acceso a la instancia del proceso ni a la bandeja de errores): (a) `listaNombreDocs` llegó vacío al PM (el `a!map` `resultado` se persiste en `pv!resultado` de tipo *Any Type*); (b) `CMP_existeObjeto` devolvió `false` y la regla marcó el documento como `omitido` con `success=true` (no se considera error y no deja rastro); (c) el alta en GD respondió `success=true` sin `codigo_documento` y `SCA2_modificarCrearDocumentosCarta` falló silenciosamente (su resultado no se evalúa).
- **No se corrige** en esta prueba: hace falta reproducirlo con una solicitud nueva observando `pv!docsResult` (o trazándolo a `SCA2 Transicion`) para no cambiar la lógica a ciegas. Propuesta: en `SCA2_subirDocumentosGD` tratar `omitido` como error visible y comprobar el resultado de `SCA2_modificarCrearDocumentos*`; añadir `docsResult` a la transición.

### 3.3 Pendiente exclusiva SCA2 — estado final tras FINALIZAR negativo

- SCA finaliza la gestión CA como `FINALIZADA NEGATIVA` (`IContraAnularPCA` con `mcaResultado="2"` en `SCA_Finalizar_Contra_Anulacion`, nodo 19 distingue POSITIVO/NEGATIVO/CANCELAR), mantiene la solicitud en `codEstSolic=2` y redirige a la pantalla de anulación (mecanización pendiente).
- SCA2 (`SCA2_CMD_CompletarAccion` → `SCA2_finalizarContraAnulPca` → `SCA2_CMD_Finalizar` → `IGenerarContraAnul` → `Write FINALIZADA`) deja la gestión CA `FINALIZADA` (sin el sufijo NEGATIVA), la solicitud en `codEstSolic=5` («Finalizada. Anulación realizada» en el buscador) y el record `SCA2 Solicitud` en `FINALIZADA/FIN`. El Detalle SCA2 muestra la cabecera `FINALIZADA NO REQUERIDA CONTRAANULACIÓN` y la tarjeta Contra Anulación `Incompleta` (no coincide con CORE).
- No se ha corregido: el comportamiento correcto (¿debe SCA2 encadenar la anulación como SCA o cerrar la solicitud?) es una **decisión funcional** que se eleva en el mensaje final. La incoherencia de la tarjeta `Incompleta` en el Detalle SCA2 sí parece un defecto de presentación (estado leído de otra fuente que CORE) pero no se ha tocado sin una solicitud nueva sobre la que verificar.

### 3.4 Comunes / externas (no se corrigen)

- Lista de documentos por motivo (`consultarDocumentos` de CORE, endpoint `PCA_CORECFSA_HTTPRouter/IGestionarAccAdmPCA`): `MSSConsultarDocumentos=null` para una solicitud recién dada de alta en **ambas** apps. Request: `mseConsultarDocumentosDTO(codSolicitud)`; response: `consultarDocumentosResponse(MSSConsultarDocumentos: null)`.
- Servicio search SGD (`search-web/api/sgd/1.0/advancedSearch`, query `QUERY_SCA_AGD_001`, `idDocument=0900ab4481a049c7`): devuelve `null` (sin `r_object_id`) tanto en `SCA_searchDocumentos` como en `SCA2_searchDocumentos` v3 → ambas caen al `idDocumento` original. Comportamiento idéntico.
- Documentum/GD: no se ha podido consultar directamente si el documento SCA2 existe en Documentum (no hay id de referencia); el de SCA sí (`0900ab4481a049c7`).
- Error transitorio SCA al abrir el detalle (`sca_datoscabecera` / `a!submitLink` «The save target must be a local variable…was: 2002000050936»); desapareció al recargar. No se ha modificado SCA.

## 4. Objetos SCA2 modificados/creados

Procedimiento por objeto: `GET` vivo inmediatamente antes → backup local JSON (fuera del repo, `~/sca2work/backup/`) → edición mínima → `PUT` del objeto completo → re-`GET` y comparación → `POST …/test`.

| # | Objeto | UUID | Versión | Cambio |
|---|---|---|---|---|
| 4.1 | `SCA2_ContraAnulacionArgumentarioEstrategicas` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060043` | 1 → 2 | `a!save(ri!indiceArgumentoSeleccionado, local!selection)` → `a!save(ri!indiceArgumentoSeleccionado, tointeger(index(local!selection, 1, null)))` |
| 4.2 | `SCA2_ContraAnulacionOpciones` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 13 → 14 | `local!codGestion` pasa a seleccionar la gestión con `accionRealizada="2"` y `codEstGestion="INCOMPLETA"` (como SCA), con fallback `index(local!basicos,"idgestionsgc","")` |
| 4.3 | `SCA2_ContraAnulacionOpciones` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 16 → 17 | Añadido `a!columnsLayout(… rule!SCA2_VisualizarDocumentoContraanularEstrategicas(document: local!plantillaCarta, cancel: local!mcaVentanaVisualizarDoc, flecha: local!flecha) …, showWhen: local!mcaVentanaVisualizarDoc)` y `showWhen` de la tarjeta principal negado mientras se muestra el visor |
| 4.4a | `SCA2_searchDocumentosIntegracion` (integración, **nueva**) | `5b2f22f2-1522-48fe-a804-150100c9e9d7` | — → 1 | Clon aislado de `SCAC_searchDocumentos`: `POST ri!endpoint` sobre el mismo connected system, header `Host: ri!host`, body `{"queryName": ri!query, "parameters": {"idDocument": ri!idDocumento}}`, inputs `host, endpoint, query, idDocumento` |
| 4.4b | `SCA2_searchDocumentos` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051374` | 2 → 3 | `rule!SCA2_searchDocumentos(query, idDocumento)` (recursión) → `rule!SCA2_searchDocumentosIntegracion(host: cons!SCA2_WEBSERVICES_URL, endpoint: "search-web/api/sgd/1.0/advancedSearch", query: ri!query, idDocumento: ri!idDocumento)` |

Fragmentos:

```sail
/* 4.2 — SCA2_ContraAnulacionOpciones v14 */
local!codGestion: a!defaultValue(
  index(
    reject(fn!isnull, a!forEach(items: local!gestiones,
      expression: if(and(index(fv!item, "accionRealizada", "") = "2",
                         index(fv!item, "codEstGestion", "") = "INCOMPLETA"),
                      index(fv!item, "numGestion", ""), null))),
    1, null),
  index(local!basicos, "idgestionsgc", ""))
```

```sail
/* 4.4b — SCA2_searchDocumentos v3 */
local!resultado: rule!SCA2_searchDocumentosIntegracion(
  host: cons!SCA2_WEBSERVICES_URL,
  endpoint: "search-web/api/sgd/1.0/advancedSearch",
  query: ri!query,
  idDocumento: ri!idDocumento
),
```

Tests LCP tras cada cambio: `POST /interfaces/…20060043/test` 200; `POST /interfaces/…20056435/test` 200 (v14 y v17); `POST /expression-rules/…20051374/test` 200 (`null`, igual que SCA); `POST /expression-rules/…20051626/test` (`SCA2_consultarDocumentos`) con `15787705` → misma lista que SCA, con `15787706` → `null`.

## 5. Estados CORE observados

| Momento | SCA 15787705 | SCA2 15787706 |
|---|---|---|
| Tras Alta | 43704823 acc. 8 `FINALIZADA` | 43704826 acc. 8 `FINALIZADA` |
| Tras entrar en Contra Anular | 43704825 acc. 2 `INCOMPLETA` | 43704827 acc. 2 `INCOMPLETA` |
| Tras NEGATIVO (antes de corregir) | arg. 267 `codTpEstArgumento=2` | arg. 267 `codTpEstArgumento=0` |
| Tras NEGATIVO (con v14) | `codTpEstArgumento=2` | `codTpEstArgumento=2` |
| Tras Imprimir | 43704828 acc. 4 `FINALIZADA` | (sin gestión de impresión propia) |
| Tras FINALIZAR | 43704825 `FINALIZADA NEGATIVA`; 43704830 acc. 5 `INCOMPLETA`; `codEstSolic=2` | 43704827 `FINALIZADA`; `codEstSolic=5`; record `SCA2 Solicitud` `FINALIZADA` / `interfazActiva=FIN` / `version=5` |
| Documentos CORE | `[{0900ab4481a049c7, tipo 6, 2026-09-30}]` | `null` |

## 6. Limitaciones y pendientes

1. **Re-prueba UI de v17** (visor de plantilla) y de `SCA2_searchDocumentos` v3 en pantalla: la solicitud SCA2 ya estaba finalizada cuando se aplicaron; hace falta una solicitud nueva (póliza de reserva `2002000004992` u otra asignada).
2. **Documento SCA2 no registrado en CORE/GD** (§3.2): reproducir con solicitud nueva observando `pv!docsResult`; después decidir el endurecimiento de `SCA2_subirDocumentosGD`.
3. **Estado final tras NEGATIVO** (§3.3): decisión funcional — ¿SCA2 debe redirigir a la anulación y dejar la gestión `FINALIZADA NEGATIVA`/solicitud pendiente como SCA, o cerrar la solicitud? Tarjeta Contra Anulación `Incompleta` en el Detalle SCA2 a revisar.
4. **Buscador SCA2** solo muestra solicitudes creadas en SCA2 (record `SCA2 Solicitud`); SCA muestra todas las de CORE. Decidir si SCA2 debe consultar también CORE.
5. **Bandeja `/errores`** restringida a `SCA2_GRP_ADMINISTRADORES`: no verificable con JJGONZ2 (por LCP: 0 errores pendientes para 15787706).
6. No se ejecutó ANULAR PÓLIZA en SCA (fuera de alcance); la solicitud SCA queda `Pendiente` con mecanización incompleta.
7. Lista de documentos por motivo `null` en ambas apps: dependencia del servicio CORE, sin corrección.

## 7. Evidencias (no incluidas en el repo)

- Grabación fase 1 (alta, argumentario, NEGATIVO, corrección selector): `s2-fase1-verificacion-edited.mp4`
- Grabación fase 2 (subida PDF, NEGATIVO persistido, impresión, FINALIZAR, detalle/buscador): `s2-fase2-edited.mp4`
- Capturas SCA/SCA2 consecutivas por pantalla adjuntas al mensaje final de la sesión.
- Backups JSON antes/después de cada objeto y SAIL local en `~/sca2work/backup/` (fuera del repo).
