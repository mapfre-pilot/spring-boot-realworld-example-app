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

> **Actualización ronda 2 (§8.2): corregida.** Causa real: fichero temporal de `a!fileUploadField` en página de site (S4) + `nuuma` nulo en el registro CORE. Con `a!submitUploadedFiles` (v26) la Carta firmada de 15787717 queda en GD/CORE (`0900ab4481a0470c`, tipo 6) y se muestra en el Detalle de SCA2 y de SCA.

- SCA: al FINALIZAR, el PM `SCA_Finalizar_Contra_Anulacion` ejecuta el subproceso «Subir Docs Documentum BBDD» → alta en Documentum (`SCAC_altaDocumentoIntegracion`) + registro en BBDD CORE (`SCA_modificarCrearDocumentosCarta`). Resultado verificable: `SCA_consultarDocumentos(15787705)` devuelve `idDocumento=0900ab4481a049c7`, tipo `6`.
- SCA2: `SCA2_CMD_CompletarAccion` nodo 7 «Write PDTE_FINALIZAR» → nodo 310 «Subir documentos GD» (`rule!SCA2_subirDocumentosGD(codSolicitud: pv!idSolicitud, listaNombreDocs: index(pv!resultado,"listaNombreDocs",{}), tipoGestion, nuuma)`) → nodo 311 «¿Docs GD ok?» → 300 «Llamada cierre?» → 301 `SCA2_finalizarContraAnulPca`. `SCA2_ContraAnulacionOpciones` sí envía `listaNombreDocs: local!listaNombreDocs, tipoGestion: "CA"` en el `resultado` del FINALIZAR (líneas 675-680 de la v17), y `SCA2_altaDocumento` / `SCA2_modificarCrearDocumentosCarta` son idénticas a las de SCA salvo el prefijo.
- Evidencia: `SCA2_consultarDocumentos(15787706)` y `SCA_consultarDocumentos(15787706)` → `MSSConsultarDocumentos=null`; no hay filas `SCA2 Error` pendientes para la solicitud; el proceso terminó con `CORRECTO`.
- Hipótesis (no verificables sin acceso a la instancia del proceso ni a la bandeja de errores): (a) `listaNombreDocs` llegó vacío al PM (el `a!map` `resultado` se persiste en `pv!resultado` de tipo *Any Type*); (b) `CMP_existeObjeto` devolvió `false` y la regla marcó el documento como `omitido` con `success=true` (no se considera error y no deja rastro); (c) el alta en GD respondió `success=true` sin `codigo_documento` y `SCA2_modificarCrearDocumentosCarta` falló silenciosamente (su resultado no se evalúa).
- **No se corrige** en esta prueba: hace falta reproducirlo con una solicitud nueva observando `pv!docsResult` (o trazándolo a `SCA2 Transicion`) para no cambiar la lógica a ciegas. Propuesta: en `SCA2_subirDocumentosGD` tratar `omitido` como error visible y comprobar el resultado de `SCA2_modificarCrearDocumentos*`; añadir `docsResult` a la transición.

### 3.3 Pendiente exclusiva SCA2 — estado final tras FINALIZAR negativo

> **Actualización ronda 2 (§8.3-8.5): decisión resuelta (SCA es la referencia) y parcialmente corregida.** El cierre CORE de la gestión CA como `FINALIZADA NEGATIVA` con `codEstSolic=2` ya funciona en SCA2 (15787717); la mecanización local/redirección sigue sin verificarse por el defecto del operador `in` en el nodo 200 (corregido al final, sin solicitud nueva sobre la que probar).

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

## 6. Limitaciones y pendientes (ronda 1; ver §8.7 para el estado tras la ronda 2)

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

## 8. Ronda 2 (30/09/2026 tarde) — semántica del NEGATIVO, GD/CORE y reintentos sobre 15787717

Coordinación recibida: SCA es la referencia (tras NEGATIVO, SCA2 debe cerrar la gestión CA en CORE como `FINALIZADA NEGATIVA`, dejar `codEstSolic=2`, crear las gestiones de mecanización y redirigir a la anulación, sin cerrar la solicitud); el documento debe quedar en GD/CORE; autorizada la póliza de reserva `2002000004992` para una solicitud nueva en SCA2. S5 trabajó en paralelo sobre los mismos objetos (rama de error `SCA2 Error`, CDT tipado del nodo `Finalizar CA PCA`, colores del Detalle): todas las ediciones de S2 se hicieron sobre GET vivo inmediatamente anterior y se verificó tras cada PUT que los nodos/fragmentos de S5 seguían intactos.

### 8.1 Solicitud nueva SCA2

| App | Póliza | Solicitud | Alta (8) | Contra Anular (2) | `codEstSolic` final |
|---|---|---|---|---|---|
| SCA2 | `2002000004992` (reserva) | **15787717** | 43704864 `FINALIZADA` 13:10:33 | 43704865 `FINALIZADA NEGATIVA` (inicio 13:10:51, fin **13:59:29**) | `2` tras el cierre CA (correcto) → **`4`** a las 14:14:46 por el defecto de §8.5 |

Referencia SCA (solo lectura): 15787705 → CA 43704825 `FINALIZADA NEGATIVA`, 43704828 acción 4 `FINALIZADA`, 43704830 acción 5 `INCOMPLETA`, `codEstSolic=2`. Motivo/causa idénticos a la ronda 1 («ME HA SUBIDO MUCHO LA PRIMA», catalogación 2).

### 8.2 Documento → GD/CORE (divergencia exclusiva SCA2, corregida)

Cadena verificada por LCP con un documento Appian persistido (`prueba_s2_lcp_15787717`, id 555730): `SCA2_altaDocumento` → GD `r_object_id=8934f1a0f20d7386` (plantilla `DOCS_SCA_AUAN_0001`) → `SCA2_modificarCrearDocumentosCarta`. Hallazgos:

1. Con `nuuma` nulo CORE responde `4004 Datos insuficientes para la operacion`; `SCA2_subirDocumentosGD` devolvía `success=true` igualmente. Corregido: `success = gdOk AND bbddOk` y mensaje con el `faultString` (v2; S5 publicó después la v3 con el guard `SCA2_documentoAccesible`, conservando el cambio).
2. Los ficheros de `a!fileUploadField` en una página de site son temporales (hallazgo S4): `document()` lanza «Document Does Not Exist or has been Deleted» y la instancia del PM quedaba pausada (12088128). Corregido en `SCA2_ContraAnulacionOpciones` v26: los cuatro puntos que lanzan `SCA2 CMD CompletarAccion` (subida por fila/REVISIÓN, FINALIZAR, cierre POSITIVO) pasan por `a!submitUploadedFiles(onSuccess: a!startProcess(...), onError: mensaje)`.
3. Resultado en UI: Carta firmada de 15787717 marcada como entregada (30/09/2026), fila `SCA2_consultarDocumentos(15787717)` = `{idDocumento: 0900ab4481a0470c, tipoDocumento: 6, fechaDocumento: 2026-09-30}`, visible en «Documentos presentados» del Detalle de SCA2 **y** de SCA. Paridad alcanzada.

### 8.3 Tarjeta Contra Anulación del Detalle (defecto de presentación exclusivo SCA2, corregido)

`SCA2_DetalleSolicitud` v22: `local!ordinalGestion` elige la gestión CORE más reciente del tipo cuando hay más gestiones CORE que tareas locales (antes tomaba la primera y mostraba `Incompleta` con CORE finalizada). Verificado en UI: 15787717 muestra `Finalizada Negativa` en rojo (color de S5), inicio/fin/usuario de CORE.

### 8.4 Cierre CORE de la CA como FINALIZADA NEGATIVA (corregido, verificado)

Secuencia de fallos encontrados en `SCA2 CMD CompletarAccion` al FINALIZAR con NEGATIVO y su corrección:

| # | Síntoma UI | Causa (instancia) | Corrección |
|---|---|---|---|
| 1 | `CORRECTO` sin efecto en CORE (CA seguía `INCOMPLETA`) | Nodo 7 escribía la `SCA2 Transicion` `OK` **antes** de las llamadas externas; el reintento salía por `¿Ya ejecutado?` | Transición movida a un nodo nuevo **330 «Write Transicion OK»** tras Subir docs GD / Finalizar CA PCA / Aceptar Autorización (rutas 300/302/320 → 330 → 200) |
| 2 | «Se ha producido un error al finalizar la contra anulación: Failed to connect … IContraAnularPCA» (`SCA2 Error` 38, `FINALIZAR_CA_ERROR`) | El nodo 301 pasaba el `Dictionary` de `pv!resultado` a la integración; `toxml` no genera el body → fault CORE «EPR for Operation not found / WSA Action = null» (también en 15787716/15787722 de S5/S1) | S5 cambió el nodo 301 a CDT tipado `finalizarContraAnulPca` (equivalente a `SCA_finalizarContraAnulPca`). **Con esa versión la llamada funcionó: CA 43704865 → `FINALIZADA NEGATIVA` 13:59:29, `codEstSolic=2`, `fecResolucion` informada — misma semántica que SCA** |
| 3 | «…violación de integridad de datos: duplicate key … CLAVE_IDEMPOTENCIA=(SCA2 CMD CompletarAccion\|15787717\|27)» (`SCA2 Error` 41) | El nodo 330 insertaba una transición con la misma clave que la fila `KO` del intento anterior | Nodo 330 y nodo 11 «Write Decidir» hacen *upsert* (`a!localVariables(local!prev: a!queryRecordType(... claveIdempotencia = local!clave ...), id: local!idPrevio, ...)`) |
| 4 | Tras un error el Detalle no ofrecía RETOMAR | Nodo 5 marcaba la `SCA2 Tarea` `COMPLETADA` al inicio y la rama de error no la reabría | Nodo 199 «Write Error» (S5) escribe además `SCA2 Tarea(id: pv!idTarea, estado: "PENDIENTE", fechaCierre: null)` si `pv!idTarea` está informado |
| 5 | Con la CA ya cerrada en CORE, Contra Anular muestra «No hay elementos disponibles» y FINALIZAR deshabilitado («Se debe ejecutar al menos 1 argumento») | `SCA2_consultarListadoArgumentos` no devuelve argumentos de una gestión finalizada (SCA nunca reabre esa pantalla) | `SCA2_ContraAnulacionOpciones` v27: `local!caFinalizadaCore` (última gestión acción 2 con `codEstGestion` `FINALIZADA*`) habilita FINALIZAR sin argumentario y fija `estadoFinalizarCA` = `3` (`FINALIZADA`) / `4` (`FINALIZADA NEGATIVA`); nodo 300 del PM salta la llamada `IContraAnularPCA` si CORE ya la tiene finalizada («CA ya finalizada en CORE» → 330) |

### 8.5 Mecanización local y redirección (exclusivo SCA2, causa raíz corregida, **sin verificar**)

Con todo lo anterior, el último FINALIZAR sobre 15787717 (instancia 14190487, `pv!resultado.estadoFinalizar="4"`, `finalizadoCA=true`, `docsResult.success=true`) terminó con `CORRECTO`, **sin** «Se va a redirigir a la anulación.», sin gestión de mecanización y con la solicitud cerrada: `SCA2 CMD Finalizar` (16283052, transición 171 `SCA2 CMD Finalizar|15787717|7`) llamó a `finalizarSolicitud` en CORE (`respuesta=true`) → `codEstSolic=4`, buscador SCA2 «Finalizada. Anulación realizada» (SCA muestra para la misma solicitud «Finalizado negativo con contraanulación»). No se lanzó ninguna instancia de `SCA2 CMD Decidir`.

Causa raíz: la condición del nodo 200 «CA negativa (Decidir → mecanizar)» usaba `a!defaultValue(index(pv!resultado,"estadoFinalizar",null),"") in {"2","4"}`. `in` no es un operador de Appian: la condición nunca se cumple y el XOR cae al `defaultPath` = nodo 8 «Start finalizar». Es la misma causa del cierre `codEstSolic=5` de 15787706 en la ronda 1 (§3.3) y del error «Cannot compare incompatible operands of type Any Type and type Boolean» de las instancias v21 de S5 pausadas en `Cancel?` (nodo 6, también con `in`). Corrección aplicada en ambos nodos: `contains({"2","4"}, tostring(...))` / `contains({"9","3","CANCELADO"}, tostring(...))`. La ruta correcta queda: 200 → 11 «Write Decidir» → 12 `SCA2 CMD Decidir(regla: "mecanizar")` → 13/14 → `SCA2 CMD CrearAccion` (mecanización) y la interfaz redirige. **No se ha podido verificar**: 15787717 ya está cerrada en CORE (`codEstSolic=4`, irreversible desde Appian; no se ha tocado CORE) y no queda póliza autorizada. Hace falta una póliza nueva para una re-prueba completa (alta → carta → NEGATIVO → FINALIZAR → mecanización sin ANULAR PÓLIZA).

Consecuencia sobre 15787717: solicitud cerrada en CORE por SCA2 (efecto del defecto, no una acción manual); la póliza `2002000004992` **no** ha sido anulada (no se ejecutó ninguna mecanización ni ANULAR PÓLIZA).

### 8.6 Objetos SCA2 modificados en la ronda 2

| Objeto | UUID | Versión antes → después | Cambio S2 (los de S5/S1 se conservan) |
|---|---|---|---|
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 25 → 26 → **27** | v26 `a!submitUploadedFiles(onSuccess: a!startProcess(cons!SCA2_PM_CMD_COMPLETAR_ACCION …))` en los 4 lanzamientos; v27 `local!estadoCACore`/`local!caFinalizadaCore` (FINALIZAR sin argumentario cuando la CA ya está cerrada en CORE; `estadoFinalizarCA` 3/4) |
| `SCA2_subirDocumentosGD` | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351` | 1 → 2 (S5 → 3) | `success = and(gdOk, bbddOk)`; mensaje con `faultString` del registro CORE |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 21 → 22 | `local!totalTareasTipo` / `local!ordinalGestion`: tarjeta CA con la gestión CORE más reciente |
| `SCA2 CMD CompletarAccion` | `0000f06f-1307-8000-65b1-7f0000014e7a` | v19 → … → v26+ (versiones intercaladas con S5; LCP no devuelve `versionId` del PM) | Nodo 7 sin transición; nodo **330** «Write Transicion OK» (upsert) tras 300/302/320; nodo 300 condición «CA ya finalizada en CORE» → 330; nodo 11 upsert; nodo 199 reabre la tarea; nodos 6 y 200 `in {…}` → `contains({…}, tostring(…))` |

Datos alterados a mano (solo 15787717, para poder reintentar): `SCA2 Transicion` 128 → `KO` (luego actualizada a `OK` por el nodo 330); `SCA2 Tarea` 27 → `PENDIENTE` (dos veces; la segunda ya la reabre el nodo 199). Backups JSON antes/después de cada PUT en `~/sca2work/backup2/` (fuera del repo).

### 8.7 Estado de las divergencias tras la ronda 2

| Paso | Veredicto |
|---|---|
| Alta, argumentario, NEGATIVO (`codTpEstArgumento=2`), plantilla | igual (ronda 1) |
| Documentos por motivo `MSSConsultarDocumentos=null` | común a SCA y SCA2 (servicio) |
| Subida de Carta firmada → GD/CORE → «Documentos presentados» | **corregida y verificada** (SCA2 y SCA muestran la misma fila) |
| FINALIZAR negativo → gestión CA `FINALIZADA NEGATIVA`, `codEstSolic=2`, tarjeta CA | **corregida y verificada** (15787717) |
| FINALIZAR negativo → gestiones acción 4/5, tarea de mecanización, redirección «Se va a redirigir a la anulación.» | **causa raíz corregida (nodo 200), pendiente de verificar** con póliza nueva |
| Etiqueta del buscador para `codEstSolic=4` («Finalizada. Anulación realizada» vs SCA «Finalizado negativo con contraanulación») | pendiente (S5 es propietaria de `SCA2_textoEstadoSolicitud`; el estado 4 solo se alcanzó por el defecto anterior) |
| `/errores` solo administradores; instancias pausadas no reanudables por LCP (`/processes/{id}/resume|retry`, arranque de PM → 501) | limitación de entorno, documentada |

### 8.8 Evidencias ronda 2 (fuera del repo)

Grabaciones: `s2-v26-reintento-edited.mp4`, `s2-idempotencia-reintento-edited.mp4`, `s2-pm21-ultimo-edited.mp4`, `s2-tarea27-reabierta-edited.mp4`, `s2-transicion-actualizada-edited.mp4`, `s2-v27-finalizar-edited.mp4` (en `~/screencasts/`). Capturas SCA/SCA2 consecutivas (gestiones, tarjeta CA/NEGATIVO, documento, buscador, errores literales) adjuntas al mensaje final de la sesión.

## 9. Ronda 3 (30/09/2026, 14:28–16:30 CEST) — ciclo limpio en SCA2 con `2002000047913` y tarjeta «Mecanizacion»

Objetivo: verificar en un ciclo limpio (alta → Contra Anular → NEGATIVO + Carta firmada por fila + carta → FINALIZAR) que SCA2 se comporta como SCA tras las correcciones de la ronda 2 (nodo 200 `contains`, nodo 330, GD/CORE), parando antes de ANULAR PÓLIZA, y comparar la pantalla/tarjeta de mecanización con SCA. Objetos de S5 conservados en todo momento: nodo 301 (CDT tipado), nodos 350-353 (`finalizarSolicitud` solo POSITIVO) y la rama de relanzamiento; `SCA2_subirDocumentosGD` no se ha tocado.

### 9.1 Solicitud creada

| App | Póliza | idSolicitud | Estado final |
|---|---|---|---|
| SCA2 | `2002000047913` | **15787726** | CORE `codEstSolic=2` (pendiente, mecanización incompleta), `fecResolucion=null`; record `PDTE_MECANIZAR` / tarea `MECANIZAR` PENDIENTE |

La reserva `2002000066861` **no se ha usado**; la referencia SCA se ha tomado en lectura de la misma solicitud 15787726 (mismo CORE) y de 15787705.

### 9.2 Verificación backend (todo igual que SCA)

| Comprobación | Resultado SCA2 (15787726) | Veredicto |
|---|---|---|
| Gestiones CORE (`SCA2_consultaGestion`) | 8 Alta `FINALIZADA` (43704886); **2 Contra Anulación `FINALIZADA NEGATIVA`** (43704887, 14:28:41 → 14:33:29); **5 Mecanización `INCOMPLETA`** (43704891, 14:33:39, sin fin) | igual que SCA (gestión de acción 5 creada por CORE al cerrar la CA negativa) |
| Solicitud (`SCA2_consultarSolicitudes`) | `codEstSolic="2"`, `fecResolucion=null` | igual (no 4/5) |
| Detalle gestión 5 (`SCA2_consultaDetalleGestion`) | `tpGestion="5"`, `resulMecanizacion="3"` (MECANIZACIÓN INCOMPLETA), `centroEmisor`/`numSituacion` nulos | igual |
| Documento (`SCA2_consultarDocumentos(codSolicitud)`) | `idDocumento=0900ab4481a04e6`, `tipoDocumento="6"` (Carta firmada), `fechaDocumento=2026-09-30`; alta Documentum `idDoc=555840`, plantilla `DOCS_SCA_SOAN_0001`, `idReferencia=893641a0f24e2ea2` | igual; **sin `DOC_GD_FAIL`** a la primera |
| `SCA2 CMD CompletarAccion` | instancia 13144743 **COMPLETED**; `docsResult.success=true` (1/1 subidos), `caSuccess=true`, `finalizarContraAnulPcaResponse.respuesta=true` | — |
| `SCA2 Transicion` | 179 Alta ALTA · 180 Decidir DECIDIDA · 181 CrearAccion EN_ACCION · 185 CompletarAccion DECIDIR · 186 Decidir MECANIZAR · **187 CrearAccion PDTE_MECANIZAR**, todas `OK` | ruta NEGATIVO → Decidir → mecanizar correcta (nodo 200) |
| `SCA2 Solicitud` (id 50) | `estadoSolicitud=PDTE_MECANIZAR`, `interfazActiva=CONTRA_ANULAR`, `procesoActivo=MECANIZAR`, `estadoTarea=PENDIENTE`, `version=6` — fuera de `PDTE_FINALIZAR` y coherente con CORE | — |
| `SCA2 Tarea` | 38 CONTRAANULAR COMPLETADA (12:33:21Z); 40 MECANIZAR PENDIENTE (`SCA2 CMD CrearAccion`) | — |
| `SCA2 Error` | sin filas para 15787726 | — |

Nota: `SCA2_consultarDocumentos` espera `codSolicitud` (con `idSolicitud` devuelve `null`).

### 9.3 UI: FINALIZAR negativo → redirección a mecanización

| Paso | SCA (15787705, lectura) | SCA2 (15787726) | Veredicto |
|---|---|---|---|
| NEGATIVO + Carta firmada por fila + carta | argumento rojo, fila con `idDocumento`, visor | igual (fichero consolidado con `a!submitUploadedFiles`, ronda 2) | igual |
| FINALIZAR | mensaje «Se va a redirigir a la anulación.» y pantalla de mecanización | mismo mensaje en `SCA2_DetalleTareas`; tarea MECANIZAR pendiente y `SCA2_MecanizacionPrincipal` (botón ANULAR PÓLIZA rojo, **no pulsado**) | igual |
| Tras ACEPTAR | — | el Detalle mostraba datos obsoletos hasta recargar (F5); tras recargar aparece la tarea MECANIZAR y RETOMAR | divergencia menor de refresco, exclusiva SCA2, **pendiente** (no reproducible de forma estable; sin corrección) |
| Buscador | Pendiente | Pendiente | igual |
| Pantalla operativa «Mecanizar» SCA vs SCA2 | en SCA la solicitud 15787705 mostraba REASIGNAR (tarea de otro usuario) y no se ejecutó ninguna acción para no alterarla; la pantalla operativa de anulación de SCA **no se ha podido abrir** en las mismas condiciones | `SCA2_MecanizacionPrincipal` abierta hasta el botón | **no comparable** en esta ronda (solo tarjetas del Detalle) |

### 9.4 Tarjeta «Mecanizacion» del Detalle (divergencia exclusiva SCA2, corregida en 3 iteraciones)

Antes (v24): la tarjeta se construía solo con la tarea local (`SCA2 Tarea`) — mostraba `CE_RM`, el correo completo del usuario y ninguno de los bloques que SCA pinta en `SCA_DetalleAnulacionMecanizacionEstrategicas` (Datos de la gestión, hitos, TRAZAR ANULACIÓN).

| Versión | Cambio en `SCA2_DetalleSolicitud` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572`) |
|---|---|
| 24 → **25** | `local!esMec` / `local!codCore="5"`: la tarjeta se alimenta de la gestión CORE `accionRealizada=5` (fechas, perfil, grupo, nuuma como la tarjeta CA) + `SCA2_consultaDetalleGestion`; título «Mecanizacion»; bloque «Datos de la gestión» (Sistema Anulación, Centro emisor, Resultado de la mecanización, Núm. Situación Autemis); hitos Mecaniza/[Suscripción]/Anulación con `a!stampField`; botón TRAZAR/OCULTAR ANULACIÓN |
| 25 → **26** | Igual que SCA: catalogación y fecha de anulación de `SCA2_consultarCabeceraSolicitud`; observaciones de BBDD SCA (`SCA2_consultaBBDDSCA(devolverObservaciones)`) filtradas por `numGestionPca` y ordenadas por `fecObsPca`; hitos/`pasosOk` con los mismos textos que SCA («Inicia Subproceso Appian», «RESPUESTA SUSCRIPCION NSE», «RESPUESTA ANULACION NSE», «ANULAR NEW», SGO/STCAT para wAutemis); la traza muestra `fecObsPca` + texto + línea en blanco por observación; bolitas solo si hay observaciones |
| 26 → **27** | La fecha bajo un hito solo se pinta en hitos completados o en el hito en curso (`fv!index <= pasosCompletados + 1`), como las ramas de SCA; desaparece el `01/06/2027` bajo «Anulación» |

Fragmento (v26):

```sail
local!obsMecOrdenadas: index(todatasubset(arrayToPage: local!obsMecGestion,
  pagingConfiguration: a!pagingInfo(startIndex: 1, batchSize: -1,
    sort: a!sortInfo(field: "fecObsPca", ascending: true))), "data", null),
...
value: joinarray(a!forEach(items: local!obsMecOrdenadas, expression: {
  tostring(index(fv!item, "fecObsPca", "")),
  reject(fn!isnull, split(tostring(index(fv!item, "txtObsPca", "")), {"<p>", "</p>"})),
  char(10)}), char(10))
```

Procedimiento por PUT: GET vivo (v24/v25/v26) → backup en `~/sca2work/backups/` → edición → PUT completo (inputs conservados) → re-GET (v25/v26/v27, expresión idéntica) → `POST /interfaces/{uuid}/test` con 15787726/15787705/15787717 (HTTP 200, `diagnostics.error=null`; en v27 el render de 15787726 ya no contiene `01/06/2027`) → UI en lectura (§9.6). Comprobación de la referencia: `POST /interfaces/{SCA_DetalleAnulacionMecanizacionEstrategicas}/test` con 15787726 tampoco contiene `2027`.

Resultado UI v27 vs SCA (misma solicitud 15787726, ambas en lectura): título, tag naranja «Incompleta», fechas, nivel, perfil, grupo, nuuma, «Datos de la gestión» (NSE-Autos / MECANIZACIÓN INCOMPLETA / — / —), hitos e iconos, TRAZAR/OCULTAR y las 8 observaciones (fecha, texto, orden 14:40:29 … 14:43:21 y separación) **iguales**.

### 9.5 Divergencias visuales restantes (no corregidas)

| Aspecto | SCA | SCA2 | Clasificación |
|---|---|---|---|
| Botón RETOMAR | no aparece para 15787726 (SCA no tiene tarea Appian propia de una solicitud creada en SCA2; en solicitudes SCA sale abajo a la derecha) | RETOMAR rojo a la derecha de Grupo/Nuuma (misma posición que en la tarjeta CA de SCA2, ya validada) | dependiente de datos/posición común a todas las tarjetas SCA2 — no se corrige |
| Marco interior | contenido dentro de un recuadro gris con márgenes | sin recuadro, más ancho | estilo común a todas las tarjetas del Detalle SCA2 (también la CA validada en §12.4) — no se corrige en S2 |
| Bolitas sin observaciones | no se pintan | no se pintan (v26) | no probado en UI (15787726 tiene observaciones) |

### 9.6 Evidencias ronda 3 (fuera del repo)

Grabaciones (`~/screencasts/`): `s2-ronda3-limpia-edited.mp4` (ciclo completo hasta la pantalla de mecanización), `s2-ronda3-consulta-mecanizar-edited.mp4` (comparación SCA/SCA2), `s2-tarjeta-v25-lectura-edited.mp4`, `s2-tarjeta-v26-lectura-edited.mp4`, `s2-tarjeta-v27-fecha-edited.mp4`. Capturas SCA2/SCA consecutivas (buscador, estado + CA negativa, NEGATIVO + Carta, tarjeta Mecanizacion completa, traza abierta/oculta) adjuntas al mensaje final de la sesión.

### 9.7 Estado final de las divergencias S2

| Paso | Veredicto |
|---|---|
| Alta, argumentario, NEGATIVO, plantilla, documentos por motivo (`null` común) | igual |
| Documento → GD/CORE → «Documentos presentados» | igual (verificado en 15787717 y 15787726) |
| FINALIZAR negativo → CA `FINALIZADA NEGATIVA`, `codEstSolic=2`, gestión acción 5, tarea/record de mecanización, redirección «Se va a redirigir a la anulación.» | **igual, verificado** (15787726) |
| Tarjeta Mecanizacion del Detalle | **corregida (v25→v27)**; quedan RETOMAR/marco (§9.5) |
| Refresco del Detalle tras ACEPTAR | pendiente (menor) |
| Pantalla operativa de anulación SCA vs `SCA2_MecanizacionPrincipal` | no comparada (no se puede abrir en SCA sin alterar una solicitud ajena; ANULAR PÓLIZA no ejecutado) |
| Etiqueta buscador `codEstSolic=4`, `/errores`, buscador SCA2 con solicitudes de SCA | fuera de alcance / propietario S5-S1 |

## 10. Ronda 4 (30/09/2026, 15:00–16:20 CEST) — referencia SCA `2002000062827`, pantalla operativa, RETOMAR, marcos, ojo y refresco

Decisiones recibidas: SCA es la referencia también para el estilo de las tarjetas (marco), para la regla de visibilidad de RETOMAR/REASIGNAR y para el refresco del Detalle; nueva póliza NSE para **SCA** `2002000062827`; no pulsar ANULAR PÓLIZA en ninguna app; no tocar los CMD (S4 añade la persistencia genérica de `observaciones`); `SCA2_DetalleSolicitud` compartida con S3/S4 (GET vivo antes de cada PUT).

### 10.1 Solicitud SCA creada (referencia) y ciclo completo

| | SCA `15787734` (póliza `2002000062827`) | SCA2 `15787726` (póliza `2002000047913`, ronda 3, en lectura salvo RETOMAR) |
|---|---|---|
| Alta → Contra Anular → argumento NEGATIVO → Carta firmada (PDF) → FINALIZAR → «Se va a redirigir a la anulación.» → pantalla operativa | hecho en UI (grabación `s2-ronda4-sca-sca2-edited.mp4`); parado antes de ANULAR PÓLIZA | ya hecho en ronda 3; en esta ronda solo RETOMAR → pantalla operativa → VOLVER AL DETALLE |
| Gestiones CORE (`SCA2_consultaGestion`) | acción 8 `43704919` FINALIZADA; acción 2 `43704921` **FINALIZADA NEGATIVA**; acción 4 `43704922` FINALIZADA; acción 5 `43704924` INCOMPLETA | acción 8 `43704886`; acción 2 `43704887` FINALIZADA NEGATIVA; acción 5 `43704891` INCOMPLETA (no hay acción 4) |
| Solicitud | `codEstSolic=2`, `fecResolucion=null` | `codEstSolic=2` |
| Documento (`SCA2_consultarDocumentos`) | tipo 6, `0900ab4481a04e22` | tipo 6, `0900ab4481a04e6` |
| Traza BBDD (`SCA2_consultaBBDDSCA.observaciones`) | 1 fila: «Inicia Subproceso Appian 15787734 - 2002000062827» (no aparece la observación «Consulta NEW…» ni la del alta) | 11 filas al inicio de la ronda (alta 14:28:22 + 10 de la gestión de mecanización); cada apertura de la pantalla operativa añade 2 «Consulta NEW…» (con/sin importe) |

**Acción 4**: SCA crea acción 4 (FINALIZADA) y 5 (INCOMPLETA) al finalizar el NEGATIVO; SCA2 solo crea la 5. Sin efecto visible en Detalle/buscador (la tarjeta Mecanización lee la 5); queda como diferencia backend documentada, pendiente de decidir si SCA2 debe crear también la 4 (S5 es propietaria de `SCA2 CMD CompletarAccion`).

**Observación técnica del alta** (hallazgo de S3): en la solicitud SCA nueva la traza tampoco la muestra, así que **no se confirma** como divergencia exclusiva de SCA2 en esta ronda.

### 10.2 Pantalla operativa de anulación: `SCA_ContraAnulacionDetalleAnulacionPolizaEstrategicas` vs `SCA2_MecanizacionPrincipal`

Comparación campo a campo (capturas `ss_21f1cb63.png` SCA / `ss_3a652609.png` SCA2): mismo título «Detalle consulta NSE-Autos», mismo aviso naranja y misma pregunta «¿Desea anular la póliza con la información que se indica?»; mismos campos en el mismo orden (Póliza, Causa, Fecha anulación póliza, Importe anulación, Reserva prima, Nivel cumplimiento, Controles técnicos) y mismos botones CANCELAR / ANULAR PÓLIZA (mismo estilo). Única diferencia: SCA2 añade arriba el botón **VOLVER AL DETALLE** (SCA no lo tiene: se vuelve por navegación del site, que recarga el Detalle). Los valores difieren solo por ser solicitudes distintas. **No se pulsó ANULAR PÓLIZA ni CANCELAR en ninguna app.** Veredicto: igual (botón adicional documentado, ver §10.5).

### 10.3 RETOMAR / REASIGNAR en la tarjeta Mecanización

| | SCA (15787734, mecanización pendiente) | SCA2 (15787726, tarea MECANIZAR pendiente) |
|---|---|---|
| Botones | REASIGNAR + RETOMAR abajo a la derecha de la tarjeta (usuario asignado) | RETOMAR abajo a la derecha (v28+; antes estaba junto a Grupo/Nuuma) → abre la pantalla operativa |
| Regla | tarea Appian propia pendiente y asignada | tarea `SCA2 Tarea` MECANIZAR pendiente; REASIGNAR se muestra con la misma condición (popup de S4, `local!showPopupReasignar`) pero **no se ha verificado en UI** en esta ronda |

### 10.4 Marco interior, ojo documental e hitos (`SCA2_DetalleSolicitud` v28→v29)

Comprobado en UI con SCA: la tarjeta Mecanización de SCA **sí** lleva un recuadro interior con margen (la CA no); el icono «ojo» de los documentos es rojo en SCA; los hitos Mecaniza/Anulación se pintan cuando hay gestión de mecanización aunque no haya observaciones. Cambios v29 (GET vivo v28 → backup → PUT → re-GET v29 → `/test` 15787726/15787734/15787705 HTTP 200 → UI):

```sail
/* ojo documental: se quita style: "OUTLINE", color: "SECONDARY" → estilo por defecto (rojo, como SCA) */
/* tarjeta Mecanización: recuadro interior solo en Mecanización, como SCA */
a!cardLayout(showBorder: local!esMec, padding: if(local!esMec, "STANDARD", "NONE"), contents: {...})
/* hitos/fecha con la gestión CORE aunque no haya observaciones */
local!mecanizaOk: or(if(local!hayObsMec, ..., false), a!isNotNullOrEmpty(local!numGestionCA)),
local!fecTxtMec: if(a!isNullOrEmpty(local!indexMecaMec), left(tostring(index(local!gestionCA, "fecInicioGestion", null)), 10), ...),
showWhen: and(local!esMec, or(local!hayObsMec, a!isNotNullOrEmpty(local!numGestionCA))),
```

Resultado UI (grabación `s2-v29-marcos-refresco-edited.mp4`; capturas SCA `ss_deb714e0.png`/`ss_ebe5becd.png`/`ss_zoom_ed685d39.png` vs SCA2 `ss_36286d23.png`/`ss_3821454a.png`/`ss_zoom_654e4275.png`): marco, ojo rojo, hitos y posición de RETOMAR **iguales** a SCA; CA sin marco general en ambas. Otras tarjetas (Impresión, Autorización…) no aparecen en estas solicitudes: paridad no probada.

### 10.5 Refresco del Detalle tras volver de la pantalla operativa (**no corregido**; causa raíz identificada)

Síntoma (S3 §9.5 y esta ronda): tras RETOMAR → pantalla operativa → VOLVER AL DETALLE, la traza de la tarjeta Mecanización no muestra las 2 observaciones «Consulta NEW…» nuevas hasta F5 (10→12, 12→14, 14→16 entradas en tres repeticiones), aunque la tarjeta y la traza permanecen abiertas. Intentos (todos con GET vivo → backup → PUT → re-GET → `/test` → UI con grabación):

| Versión | Cambio | Resultado UI |
|---|---|---|
| v29 | `local!obsBBDDMec` envuelta en `a!refreshVariable(refreshOnVarChange: {ri!tipoAccion, local!versionRT})` | sigue obsoleta (`s2-v29-marcos-refresco-edited.mp4`) |
| v30 | + `local!ultimoRetorno: a!refreshVariable(value: now(), refreshOnVarChange: ri!tipoAccion)` en el nivel superior y en el `refreshOnVarChange` de la tarjeta | sigue obsoleta a los 9 s y 64 s (`s2-v30-refresco-edited.mp4`) |
| v31 | consulta subida al nivel superior (`local!obsBBDD`) con `refreshOnVarChange` **y `refreshInterval: 0.5`** | sigue obsoleta a los 10 s y 60 s (`s2-v31-refresco-edited.mp4`) |
| v33 | vuelta al contenido de v29 (consulta perezosa en la tarjeta, sin sondeo) sobre v32 de S4 | — (`/test` OK) |

Diagnóstico: el backend **no** tiene retardo — con LCP, `SCA2_MecanizacionPrincipal/test` (equivale a abrir la pantalla) añade las 2 observaciones y `SCA2_consultaBBDDSCA/test` las devuelve 11 s después (17→19, `lag_test.py`). La integración SCAC `SCAC_consultaBBDDSCA` (uuid `e9720d1a-5bf4-42a0-a4e6-a24cb435a763`, v4, `usage: QUERY`, objeto SCAC, no modificable) devuelve el mismo resultado a la interfaz mientras la página no se recarga aunque `a!refreshVariable` la reevalúe (por cambio de variable o por intervalo); F5 sí la refresca. Inferencia: caché de Appian de las integraciones de tipo «consulta» con los mismos inputs dentro de la misma instancia de la página (no verificado en documentación). SCA no tiene el síntoma porque **no tiene VOLVER AL DETALLE**: el regreso es una navegación del site que recarga el Detalle. Opciones (decisión pendiente, no aplicadas): (a) que VOLVER AL DETALLE de `SCA2_DetalleTareas` (S3) navegue a la página del Detalle (`a!sitePageLink`) en vez de `a!save(ri!tipoAccion, null)`, replicando SCA; (b) eliminar el botón como en SCA. El refresco de estado/gestiones CORE tras ACEPTAR sí funciona con el sondeo del record de v28 (`local!estadoRT`, 30 s), porque `SCA2_consultaGestion` cambia de inputs al cambiar la versión del record — no se ha re-probado en esta ronda.

### 10.6 Objetos SCA2 modificados en la ronda 4

| Objeto | uuid | Antes → después | Cambio |
|---|---|---|---|
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | v27 → v28 → v29 → v30 → v31 → (v32 S4) → **v33** | v28 sondeo del record/`versionRT` y RETOMAR/REASIGNAR abajo a la derecha; v29 ojo rojo, marco interior de Mecanización, hitos con gestión CORE; v30/v31 intentos de refresco (revertidos); v33 = v29 + v32 de S4 (`showWhen: not(local!showPopupReasignar)`). Inputs conservados (`idSolicitud`, `idSel`, `tipoAccion`, `idTarea`). Backups en `~/sca2work/backups/`. |

No se han tocado los CMD, `SCA2_subirDocumentosGD`, `SCA2_DetalleTareas` ni ningún objeto de SCA/SCAC.

### 10.7 Evidencias ronda 4 (fuera del repo)

Grabaciones (`~/screencasts/`): `s2-ronda4-sca-sca2-edited.mp4` (ciclo SCA 15787734 + comparación pantalla operativa y tarjetas), `s2-v29-marcos-refresco-edited.mp4`, `s2-v30-refresco-edited.mp4`, `s2-v31-refresco-edited.mp4`. Capturas (`~/screenshots/`): SCA `ss_5dd03fe5.png` (buscador), `ss_21f1cb63.png` (pantalla operativa), `ss_ea7abbe6.png` (REASIGNAR/RETOMAR), `ss_deb714e0.png`, `ss_ebe5becd.png`; SCA2 `ss_3a652609.png`, `ss_649f6cd4.png`, `ss_36286d23.png`, `ss_3821454a.png`; refresco `ss_15f027ad.png`/`ss_8d032659.png` (v29), `ss_11444057.png`/`ss_3b8efbdf.png` (v30), `ss_dc47747a.png`/`ss_1a34b74a.png` (v31).

### 10.8 Estado de las divergencias tras la ronda 4

| Aspecto | Veredicto |
|---|---|
| Pantalla operativa NSE-Autos | igual (SCA2 añade VOLVER AL DETALLE) |
| RETOMAR en Mecanización | igual (posición y regla); REASIGNAR SCA2 no verificado en UI |
| Marco interior / ojo documental / hitos | igual (v29) |
| Refresco de la traza tras VOLVER AL DETALLE | **pendiente** (§10.5, decisión a/b) |
| Acción 4 en el FINALIZAR negativo | diferencia backend documentada, pendiente de decisión |
| Observación técnica del alta | no confirmada como divergencia (SCA nueva tampoco la muestra) |

## 11. Ronda 5 (30/09/2026, 16:20–17:40 CEST) — VOLVER AL DETALLE por navegación, gestión de acción 4 en SCA2, ciclo `2002000066861`, tarjeta «Impresion» y RETOMAR/REASIGNAR

Decisiones aplicadas (SCA TEST como referencia): (a) VOLVER AL DETALLE de `SCA2_DetalleTareas` navega a la página del Detalle (recarga completa) y se retiran los sondeos sin efecto de `SCA2_DetalleSolicitud`; (b) SCA2 crea también la gestión CORE de acción 4 (Impresión) en el FINALIZAR negativo, como SCA.

### 11.1 Solicitud creada y ciclo

| App | Póliza | idSolicitud | Ciclo | Estado final |
|---|---|---|---|---|
| SCA2 | `2002000066861` (reserva autorizada) | **15787741** | Alta 16:36 → Contra Anular → argumento NEGATIVO + Carta firmada (subida por fila, `0900ab4481a0486a`) → FINALIZAR ①16:41 (fallo, §11.3) → FINALIZAR ②16:48 (CORRECTO) → redirección NSE-Autos → VOLVER AL DETALLE | `codEstSolic=2`, record `PDTE_MECANIZAR`/`MECANIZAR`/`PENDIENTE`, tarea MECANIZAR pendiente (`CE_RM`), **ANULAR PÓLIZA no pulsado** |
| SCA (referencia, solo lectura) | `2002000062827` | 15787734 | — | igual que en §10 |

### 11.2 Gestiones CORE: acción 4 creada como en SCA

`SCA2_consultaGestion(15787741)` tras el ciclo:

| numGestion | accionRealizada | codEstGestion | inicio → fin |
|---|---|---|---|
| 43704940 | 8 (Alta) | FINALIZADA | 16:36:51 |
| 43704941 | 2 (Contra Anulación) | **FINALIZADA NEGATIVA** | 16:37:08 → 16:41:29 |
| **43704944** | **4 (Impresión)** | FINALIZADA | 16:41:30 (creada en el 1er FINALIZAR; el reintento **no** la duplicó) |
| 43704945 | 5 (Mecanización) | INCOMPLETA | 16:48:32 |

Misma secuencia 8 → 2 → 4 → 5 que SCA 15787734 (43704919 / 43704921 / 43704922 / 43704924). BBDD SCA: `codTipEstSolicPca=2`, mecanización `codTipEstMecaniza=3`, `codUsr=JJGONZ2`. Documento: `idDoc=555974`, tipo 6, `DOCS_SCA_SOAN_0001`, `idReferencia=b8ccb1a0f2c35b0d`, GD y BBDD `success=true`, 1 intento, sin `DOC_GD_FAIL`. Sin fila `SCA2 Error` para 15787741 (comprobado con `/test` de la interfaz de errores).

**Cómo crea SCA la 4** (leído en `SCA_Finalizar_Contra_Anulacion`): el nodo 19 «Resultado Contra Anulación» separa POSITIVO (→24) / NEGATIVO (→21) / CANCELAR (→15); en el camino NEGATIVO el nodo 21 llama a `SCA_GuardarImprimir` (→ `SCA_consultaImpr` para la plantilla → `SCAC_guardarImprIntegracion`, SOAP `IGenerarContraAnul.guardarImpr` con `codCia, nuuma, codPerfil, codSubPerfil, codSolicitud, codPlantilla, nivelIntervencion`); es CORE quien registra la gestión 4 y después se crea la 5. Solo ocurre en la CA negativa (no en Acción Administrativa ni Autorización).

**Réplica en SCA2** (`SCA2 CMD CompletarAccion`, uuid `0000f06f-1307-8000-65b1-7f0000014e7a`, 46 → **49 nodos**, GET vivo antes de cada PUT): tras `Finalizar CA PCA` (350) y antes de `Write Transicion OK` (330) se añaden 360 «Guardar impresion CA» (`rule!SCA2_GuardarImprimir`, misma lógica que SCA con `SCA2_consultaImpr`/`SCA2_guardarImprIntegracion` uuid `0d02f616-3464-4b12-8d83-55be07f945ea`), 361 «¿Impresion ok?» y 362 «Capturar error impresion» (fila `SCA2 Error` `IMPR_GUARDAR_FAIL` sin cortar el flujo). Conservados: 301 (CDT tipado), 303-305, 313-314, 330/200 (`contains()`), 340, 350-353, rama Acción Administrativa, nodo 5 y relanzamiento (S4/S5).

### 11.3 Fallo del 1er FINALIZAR (exclusivo SCA2, corregido)

Instancia `9994107` (PM v33) quedó `ACTIVE` en el nodo 360 con `Expression evaluation error at function 'and': Cannot compare incompatible operands of type Any Type and type Boolean` (`index(local!res,"success",null)=true`). La UI mostró «No se ha podido confirmar la finalización de la contra anulación. Revise el estado de la solicitud o la bandeja de errores antes de volver a intentarlo.» (captura `ss_bec25211.png`); CORE ya tenía la CA `FINALIZADA NEGATIVA` y la gestión 4, y el record quedó `PDTE_FINALIZAR`. Corrección (PM v34): `tostring(a!defaultValue(index(local!res,"success",null),false))="true"` en 360 y la misma forma en la condición del 361. El 2º FINALIZAR (instancia `8942224`, PM v34, `COMPLETED` en 6,7 s) siguió la ruta `¿Ya ejecutado?` → `Finalizar CA PCA` (CA ya finalizada) → 330 → Decidir → mecanizar sin duplicar gestiones. La instancia `9994107` sigue `ACTIVE`: el plugin LCP devuelve 501 `Operation not implemented` en `/processes/{id}/cancel|resume`; hay que cancelarla desde Appian Designer (no se ha insistido).

### 11.4 Navegación y refresco (corregido y verificado)

- `SCA2_DetalleTareas` v10 → **v11**: VOLVER AL DETALLE pasa de saves locales a `a!safeLink(uri: a!urlForSite(sitePage: 'site!{bb62c468-…}SCA2 Anulaciones.pages.{ee42d0ad-…}buscador', urlParameters: a!map(idSolicitud: ri!idSolicitud)), openLinkIn: "SAME_TAB")` (recarga completa, como vuelve SCA por navegación). Verificado: la tarjeta Mecanización muestra sin F5 los hitos y las observaciones nuevas (dos «Consulta NEW» de 16:48:57) y F5 no cambia nada.
- `SCA2_DetalleSolicitud` v33 → **v34**: eliminados `local!estadoRT`/`local!versionRT` (sondeo `refreshInterval: 0.5` sin efecto) y `local!versionRT` de los `refreshOnVarChange`; se conserva el `refreshOnVarChange: ri!tipoAccion` de S3.
- `SCA2_ContraAnulacionOpciones` v27 → **v28**: `mcaFisicoJuridico` en las 6 llamadas de insertar observaciones con `tipoGestion: "CA"` (mismo payload que SCA).

### 11.5 Popup CORRECTO doble (exclusivo SCA2, corregido en `SCA2_DetalleTareas` v12, **sin re-verificar**)

En el 2º FINALIZAR aparecieron dos pantallas CORRECTO: la primera sin «Se va a redirigir a la anulación.» (16:48:32,9) y, tras ACEPTAR, otra con la frase (16:48:46) que sí abrió NSE-Autos. Causa: la frase dependía de `local!tareaMecanizar` (`a!refreshVariable(refreshAlways: true, refreshInterval: 0.5)`) y la tarea MECANIZAR se creó a las 16:48:33, un instante después del primer render; el `refreshAlways` re-evaluó la interfaz con el clic. SCA (`SCA_GenerarSolicitudPopup(mecanizar: ri!mecanizar)`) muestra la frase por el resultado, no por la tarea. Cambio v12: `local!caNegativa` (CORE `SCA2_consultaGestion` → gestión 2 `FINALIZADA NEGATIVA`, `refreshOnVarChange: local!hecho`), `showWhen: or(isNotNullOrEmpty(tareaMecanizar), caNegativa)` y sin `refreshAlways`. `/test` OK; requiere un FINALIZAR nuevo para verificarlo en UI (no queda póliza autorizada).

### 11.6 Tarjeta «Impresion» y RETOMAR/REASIGNAR en el Detalle (exclusivo SCA2, corregido y verificado)

- SCA (`SCA_DetalleSolicitud`) lista todas las gestiones CORE; para `SCA_D_TiposGestiones(4)="IMPRESION"` pinta cabecera «Impresion» + tag `Finalizada` **rojo** (`SCA_D_ColorEstadoGestion`) y cuerpo `null` (franja vacía). SCA2 construía el acordeón solo con sus tareas y no mostraba la 4. `SCA2_DetalleSolicitud` v34 → **v35/v36**: `local!impresiones` (gestiones `accionRealizada=4`) insertadas en `local!acciones` antes de la tarea MECANIZAR; fila solo-cabecera (`local!esImpr`), tag rojo para IMPRESION/FINALIZADA y franja vacía al desplegar. Verificado en UI: orden Alta → Contra Anulacion → Impresion → Mecanizacion como SCA 15787734 (`ss_ba59234a.png` vs `ss_bdf78580.png`).
- REASIGNAR/RETOMAR: en SCA los botones usan la tarea pendiente de la solicitud (`SCA_queryProcessReport`) desde cualquier tarjeta (`local!disabled` solo si la gestión está finalizada **y** no hay tarea), por eso la CA `Finalizada Negativa` de 15787734 muestra REASIGNAR. SCA2 v35: `local!tareaPendiente` + `local!tareaBtn` (tarea propia si pendiente, si no la pendiente de la solicitud); RETOMAR si `asignadoA = loggedInUser()`, REASIGNAR en caso contrario (`SCA2_puedeGestionarTarea`), ocultos en la fila Impresion. Verificado: CA y Mecanización de 15787741 muestran RETOMAR abajo a la derecha (`ss_23806c96.png`, `ss_518c0934.png`); SCA muestra REASIGNAR (`ss_819687d3.png`) porque su tarea está asignada al grupo, mientras `SCA2 CMD CrearAccion` asigna la tarea MECANIZAR al usuario (`asignadoA=JJGONZ2`) → **REASIGNAR no verificable en UI** con datos propios (divergencia de asignación en el CMD de S5, no corregida aquí).

### 11.7 Divergencias observadas no corregidas (documentadas)

| Divergencia | Ámbito | Motivo |
|---|---|---|
| Traza Mecanización: SCA «Inicia Subproceso Appian 15787734 - 2002000062827» (lo escribe el PM `SCA_Mecanizacion`, `ANL_INT_InsertarObservaciones`); SCA2 no la tiene | `SCA2 CMD CrearAccion` (S5) | fuera de los CMD asignados a S2 |
| Traza Mecanización: SCA2 muestra dos «Consulta NEW …» (16:48:57); SCA 15787734 no | común en código: `SCA_ContraAnulacionDetalleAnulacionPoliza` también llama 2× a `SCA_guardarObservaciones` al abrir la pantalla; en SCA la observación no llegó a BBDD | servicio/datos SCA, no exclusivo SCA2 |
| Tarea MECANIZAR asignada al usuario (RETOMAR) vs grupo en SCA (REASIGNAR) | `SCA2 CMD CrearAccion` (S5) | ver §11.6 |
| Página `/errores` no accesible a JJGONZ2 («La página no existe o no tiene permiso», `ss_052a81ba.png`) | seguridad del site | decisión de diseño ya elevada (§8) |
| Reabrir la CA finalizada para reintentar solo fue posible por el historial del navegador (sin RETOMAR en la CA hasta v35) | flujo de recuperación | ahora la CA muestra RETOMAR/REASIGNAR sobre la tarea pendiente (v35) |

### 11.8 Objetos SCA2 modificados en la ronda 5

| Objeto | uuid | Antes → después | Cambio |
|---|---|---|---|
| `SCA2_DetalleTareas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | v10 → v11 → **v12** | v11 VOLVER AL DETALLE por `a!urlForSite`; v12 frase de redirección por resultado CORE, sin `refreshAlways` |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | v33 → v34 → v35 → **v36** | v34 sin sondeo `estadoRT/versionRT`; v35 fila Impresion + RETOMAR/REASIGNAR sobre la tarea pendiente; v36 tag rojo Impresion y franja vacía |
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | v27 → **v28** | `mcaFisicoJuridico` en observaciones CA |
| `SCA2 CMD CompletarAccion` | `0000f06f-1307-8000-65b1-7f0000014e7a` | 46 → **49 nodos** (PM v33 → v34) | nodos 360-362 Guardar impresión CA (acción 4) + corrección de tipos |

No se han tocado `SCA2_subirDocumentosGD`, `SCA2 CMD CrearAccion`/`Decidir`, ni objetos de SCA/SCAC/CORE/GAIA/PRE/Documentum. Backups y SAIL antes/después en `~/sca2work/backups/` (fuera del repo).

### 11.9 Evidencias ronda 5 (fuera del repo)

Grabaciones (`~/screencasts/`): `s2-ronda5-ciclo-edited.mp4` (alta → CA → NEGATIVO + carta → 1er FINALIZAR con fallo), `s2-ronda5-segundo-intento-edited.mp4` (2º FINALIZAR, redirección, VOLVER AL DETALLE, traza sin F5, comparación SCA), `s2-v35-lectura-final-edited.mp4` (Impresion y RETOMAR/REASIGNAR v35). Capturas (`~/screenshots/`): `ss_bec25211.png` (fallo 1er FINALIZAR), `ss_052a81ba.png` (/errores), `ss_e7890ea5.png`/`ss_c0714465.png` (doble CORRECTO), `ss_cb9d8a08.png` (NSE-Autos), `ss_91929afc.png`/`ss_0a949bb8.png` (traza sin F5 / con F5), `ss_ba59234a.png`/`ss_bdf78580.png` (acordeón SCA2/SCA), `ss_23806c96.png`/`ss_819687d3.png` (CA RETOMAR/REASIGNAR), `ss_518c0934.png` (MEC).

### 11.10 Estado final S2

| Aspecto | Veredicto |
|---|---|
| FINALIZAR negativo a la primera (CMD v34) | corregido; el ciclo 15787741 necesitó 2 pulsaciones por el fallo de tipos ya corregido (**sin ciclo limpio posterior**) |
| Gestiones 8/2/4/5, `codEstSolic=2`, documento GD/CORE, record, `SCA2 Error`, CMD COMPLETED | igual que SCA |
| Redirección + VOLVER AL DETALLE con traza refrescada | igual (v11) |
| Fila Impresion, RETOMAR/REASIGNAR en tarjetas | igual (v35/v36); REASIGNAR no verificable con tarea asignada al usuario |
| Popup CORRECTO doble | corregido en v12, sin verificar en UI |
| Traza «Inicia Subproceso Appian» / asignación al grupo | pendiente (CMD CrearAccion, S5) |

## 12. Ronda 6 (30/09/2026, 17:00–18:10 CEST) — asignación de la tarea, traza «Inicia Subproceso Appian», color CA y ciclo limpio `2002000085510`

### 12.1 Solicitud creada

| App | Póliza | Solicitud CORE | Acción 8 | Acción 2 | Acción 4 | Acción 5 | `codEstSolic` |
|---|---|---|---|---|---|---|---|
| SCA2 | `2002000085510` | **15787743** | 43704946 `FINALIZADA` (17:21:14) | 43704947 `FINALIZADA NEGATIVA` (17:21:36 → 17:24:10) | 43704948 `FINALIZADA` (17:24:11) | 43704949 `INCOMPLETA` (17:24:24) | **2** |

Referencia SCA en lectura: 15787734 (`2002000062827`). No se pulsó ANULAR PÓLIZA, RETOMAR ni REASIGNAR en ninguna de las dos apps.

### 12.2 Asignación de la tarea MECANIZAR (decisión 1) — SCA no asigna al grupo

Lectura del código SCA (dump `dump/sca/process-models/`):

- `SCA_Contra_Anulaci_n`, nodo «CONTRA ANULACIÓN»: `assignTo = if(pv!pasoANivel2, pv!cambioAsignacion, if(and(nivelIntervencion<>1, codSubPerfil="CE_MF_SI24_EXPERTO"), cons!SCA_GRP_CE_RM_OFICINA, pp!initiator))`.
- `SCA_Mecanizacion`, nodo «Detalle Anulacion»: `assignTo = pp!initiator`.
- El REASIGNAR que muestra SCA 15787734 se debe a que `SCA_queryProcessReport` devuelve `asignadoA = propietario = deployment.user` (el proceso `SCA_Mecanizacion` lo arranca el proceso padre iniciado por el usuario técnico de TEST), no a una asignación a grupo.

`SCA2 CMD CrearAccion` ya escribe `asignadoA` con la misma regla (`null` → grupo `codperfil` solo si `nivelIntervencion<>1` y `codsubperfil="CE_MF_SI24_EXPERTO"`; en caso contrario el usuario) y `grupo = datosPerfilesPca.codperfil`; `SCA2_puedeGestionarTarea` permite gestionar si asignado = usuario o (sin asignado, nivel≠1 y perfil = grupo), equivalente a `SCA_comprobarUserTareaActiva`. **No se ha cambiado la asignación**: hacerlo global al grupo divergiría del código SCA. En el ciclo limpio la tarea queda `asignadoA=JJGONZ2`, `grupoAsignacion=CE_RM`, y las tarjetas CA y Mecanización muestran RETOMAR (SCA 15787734 muestra REASIGNAR por el propietario técnico). REASIGNAR sigue sin ser verificable con datos propios.

### 12.3 Traza «Inicia Subproceso Appian» (decisión 2) — corregido en `SCA2 CMD CrearAccion`

SCA la escribe al arrancar `SCA_Mecanizacion` (`ANL_INT_InsertarObservaciones`, tipo 05, texto `Inicia Subproceso Appian <idSolicitud> - <numPoliza>`). En SCA2 se añade el nodo **19 «Inicia Subproceso (obs CORE)»** entre la decisión del nodo 18 (acción calculada = MECANIZAR) y el nodo 9 (creación de la tarea), con PV nuevo `obsRes`:

```
rule!SCA2_insertarObservacionesInfoUsuario(
  nuuma: pv!sol.datosPerfilesPca.nuuma, codSolicitud: tostring(pv!idSolicitud),
  txtObservaciones: "Inicia Subproceso Appian " & pv!idSolicitud & " - " & pv!sol.estado.numPoliza,
  tipoGestion: "5", codCiaUsuario/codPerfil/codSubPerfil: pv!sol.datosPerfilesPca.*)
```

PM 27 → **28 nodos**; PUT completo sobre GET vivo, re-GET verificado (backups `~/sca2work/backups/CrearAccion.live.*.json` / `CrearAccion.after19.*.json`). Verificado en CORE (`SCA2_consultaBBDDSCA`): observación `codObsPca=41323203`, tipo 05, gestión 43704949, `Inicia Subproceso Appian 15787743 - 2002000085510` (17:24:26), visible en trazabilidad y como última observación. Instancias `CrearAccion` 537394224 (alta) y 8942364 (mecanización) `COMPLETED` (v13). Igual que SCA 15787734.

### 12.4 Instancia 9994107 (decisión 3) — no cancelable con el usuario disponible

`SCA2 CMD CompletarAccion` **9994107**, PM v33, `ACTIVE` desde 30/09/2026 16:41 CEST, pausada por excepción en «Guardar impresion CA» (error de tipos corregido en v34). LCP `/processes/{id}/cancel|resume` → HTTP 501 (no implementado); Designer → Monitor → Process Activity con JJGONZ2 → HTTP 403 (`ss_b44288c9.png`). Queda documentada para cancelación por un administrador; no afecta al ciclo limpio (la instancia de 15787743 es otra).

### 12.5 Color de «Finalizada Negativa» (exclusivo SCA2, corregido)

Medido sobre las capturas (`convert … histogram`): SCA pinta `Finalizada Negativa` en **#BE0F0F** (`SCA_D_ColorEstadoGestion`) e `Impresion/Finalizada` en #DF0027; SCA2 v36 usaba `cons!SCA2_VAL_COLOR_ROJO` (#DF0027) para ambas. `SCA2_DetalleSolicitud` v36 → **v37**: `equals: "FINALIZADA NEGATIVA", then: "#BE0F0F"` (resto sin cambios; conserva colores de S5 y `refreshOnVarChange` de S3). `/test` OK; verificado en UI tras recarga completa: tonos iguales a SCA (`ss_f4964330.png` SCA2 vs `ss_37e23168.png` SCA).

### 12.6 Ciclo limpio 15787743 (decisión 4) — paso a paso

| Paso | SCA 15787734 | SCA2 15787743 | Paridad |
|---|---|---|---|
| Alta NSE | ok | ok (alta 17:21:14, CrearAccion 537394224) | igual |
| Contra Anular → argumento NEGATIVO («INCREMENTO PRIMA PLATINO») | ok | ok (`ss_8e64c11b.png`) | igual |
| Carta firmada: subida individual de PDF | ok | ok (`ss_2756d351.png`) | igual |
| FINALIZAR **a la primera** | ok | ok, una sola pulsación, sin `SCA2 Error` (`ss_74ba4819.png`) | igual |
| Popup CORRECTO único con «Se va a redirigir a la anulación.» | ok | ok, **una sola vez** (`DetalleTareas` v12; `ss_040ba267.png`) | igual (corregido ronda 5, verificado) |
| CORE: CA `FINALIZADA NEGATIVA`, acciones 4 `FINALIZADA` / 5 `INCOMPLETA`, `codEstSolic=2` | ok | ok (43704947/48/49) | igual |
| Documento GD/CORE (`SCA2_consultarDocumentos`) | ok | `0900ab4481a0486c`, tipo 6 | igual |
| Record SCA2 | n/a | `PDTE_MECANIZAR` / `CONTRA_ANULAR` / `MECANIZAR` / tarea `PENDIENTE`, `grupoAsignacion=CE_RM` | coherente con CORE |
| CMD CompletarAccion | n/a | 14191223 `COMPLETED` (v34, 17:24:03–17:24:15) | ok |
| Redirección → pantalla operativa NSE-Autos (sin ANULAR PÓLIZA) | ok | ok (`ss_6bb89f17.png`) | igual |
| VOLVER AL DETALLE con traza refrescada sin F5 | (navegación) | ok | igual |
| Fila Impresion roja, franja vacía; CA rojo oscuro | ok | ok (v36/v37) | igual |
| Observación «Inicia Subproceso Appian …» en trazabilidad y última observación | ok | ok (`ss_36f83143.png` vs `ss_7292532e.png`) | igual (corregido) |
| RETOMAR/REASIGNAR | REASIGNAR (propietario `deployment.user`) | RETOMAR (asignado al usuario) | divergencia de datos de la referencia, misma regla (§12.2) |
| Buscador: una fila, estado Pendiente | ok | ok (`ss_029b2893.png` vs `ss_3b66eb1b.png`) | igual |
| `SCA2 Error` | n/a | sin filas (`SCA2_contarErroresPendientes` = 0) | ok |

Incidencia ajena a SCA2: la flecha de retorno del Detalle SCA 15787734 lanza «Error de evaluación de expresión … in rule 'sca_datoscabecera' … a!submitLink [line 23]» (`ss_55757980.png`); es un defecto de SCA TEST, no se toca.

### 12.7 Divergencias que permanecen

| Divergencia | Ámbito | Estado |
|---|---|---|
| SCA2 registra dos «Consulta NEW …» (17:24:48) al abrir la pantalla operativa; en SCA 15787734 no aparecen | código común (ambas llaman 2× a guardar observaciones) / datos SCA | no exclusivo SCA2, no corregido |
| REASIGNAR no verificado con datos propios | asignación por `pp!initiator` en ambas apps | requiere una solicitud iniciada por otro usuario |
| Instancia 9994107 `ACTIVE` | permisos Monitoring | pendiente de administrador |
| `/errores` no accesible a JJGONZ2 | seguridad del site | decisión de diseño ya elevada |

### 12.8 Objetos SCA2 modificados en la ronda 6

| Objeto | uuid | Antes → después | Cambio |
|---|---|---|---|
| `SCA2 CMD CrearAccion` | `0000f06f-0eaa-8000-6594-7f0000014e7a` | 27 → **28 nodos** (instancias v13) | nodo 19 «Inicia Subproceso (obs CORE)» + PV `obsRes`; ruta nodo 18 → 19 → 9 para MECANIZAR |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | v36 → **v37** | `FINALIZADA NEGATIVA` → `#BE0F0F` |

No se han tocado `SCA2 CMD CompletarAccion` (sigue v34, 49 nodos), `SCA2 CMD Decidir`, `SCA2_subirDocumentosGD`, `SCA2_DetalleTareas` (v12) ni objetos de SCA/SCAC/CORE/GAIA/PRE/Documentum. Del PM no existe `/test` en LCP; la validación fue el ciclo completo en UI + CORE.

### 12.9 Evidencias ronda 6 (fuera del repo)

Grabaciones (`~/screencasts/`): `s2-ronda6-ciclo-limpio/s2-ronda6-ciclo-limpio-edited.mp4`, `s2-v37-color/s2-v37-color-edited.mp4`. Capturas (`~/screenshots/`): `ss_6bb89f17.png` (pantalla operativa), `ss_8e64c11b.png` (NEGATIVO), `ss_2756d351.png` (carta), `ss_74ba4819.png` (FINALIZAR), `ss_040ba267.png` (popup único), `ss_681eb260.png` (CA + documento), `ss_6662a26c.png`/`ss_7ff048d8.png` (acordeón SCA/SCA2), `ss_f3b1c8fd.png`/`ss_bd2d0f55.png` (Impresion), `ss_83c8164a.png`/`ss_97e107d6.png` (Mecanización REASIGNAR/RETOMAR), `ss_7292532e.png`/`ss_36f83143.png` (traza), `ss_3b66eb1b.png`/`ss_029b2893.png` (buscador), `ss_37e23168.png`/`ss_f4964330.png` (color v37), `ss_b44288c9.png` (Designer 403), `ss_55757980.png` (error retorno SCA).

### 12.10 Estado final S2 (cierre)

| Aspecto | Veredicto |
|---|---|
| FINALIZAR negativo a la primera con PM v34 + DetalleTareas v12 | **igual que SCA** (ciclo limpio 15787743, popup único) |
| Gestiones 8/2/4/5, `codEstSolic=2`, documento GD/CORE, record, CMD COMPLETED, sin `SCA2 Error` | igual |
| Traza «Inicia Subproceso Appian» | igual (CrearAccion 28 nodos) |
| Color CA / fila Impresion | igual (v37) |
| Asignación de la tarea | misma regla que el código SCA (`pp!initiator` salvo nivel≠1 + `CE_MF_SI24_EXPERTO`); no se asigna al grupo |
| Pendientes | 9994107 ACTIVE (administrador); REASIGNAR sin verificar con datos propios; doble «Consulta NEW» (común) |
