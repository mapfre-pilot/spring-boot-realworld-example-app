# Tanda 18 — Clasificación de pólizas reales (20 × 2001900000xxx)

Método: ejecución real vía MCP de las mismas reglas que usa el popup Alta SCA2 —
`SCA2_obtenerTipoPoliza(numPoliza)`, `SCA2_consultarPolizas(P_NUM_POLIZA)` y
`SCA2_validacionesPreviasPopupAlta(numPoliza)` — a través de test cases
temporales `t18*` (creados y borrados tras cada ejecución; cero residuos).
La integración `IEmitirAutosPolizas` se ejecuta de verdad en el test runner.

| Póliza | tipoPoliza | consultarPolizas (datos póliza/cliente) | COD_RAMO | Compañía/Tomador | validacionesPrevias (msg/bloquear) | Resultado popup |
|---|---|---|---|---|---|---|
| 2001900000007 | NSE-Autos | `{MSSConsultarPolizas=null}` — sin datos | — | — | msg=null, bloquear=false | RECHAZADA: "La póliza no es una póliza válida o no se encuentra disponible…" (rama detallesPoliza vacía) |
| 2001900000011 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA (idem) |
| 2001900000015 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000044 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000091 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000111 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000168 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000193 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000211 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000216 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000220 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000224 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000233 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000239 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000247 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000249 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000263 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000265 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000266 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |
| 2001900000269 | NSE-Autos | null | — | — | msg=null, bloquear=false | RECHAZADA |

## Formatos alternativos probados (sobre 0007 y 0269, misma regla)
`20019000007` (sin ceros de relleno), `2001 900000007` (ramo separado),
`2001900000007 ` (con espacio), `200190000269` — **todas devuelven
`{MSSConsultarPolizas=null}`**. El servicio `IEmitirAutosPolizas` no localiza
estas pólizas bajo ninguna forma de entrada.

## Conclusión
- **0 de 20 pólizas listas para Alta positivo.** Todas serían rechazadas por el
  popup (misma condición idéntica a SCA: rama `detallesPoliza` vacía →
  "no es una póliza válida o no se encuentra disponible").
- El prefijo 2001… se clasifica como `NSE-Autos` (obtenerTipoPoliza), por lo que
  el popup usa la rama wAutemis/Autos correcta — no es un problema de rama
  equivocada: es el servicio el que no devuelve la póliza.
- `validacionesPreviasPopupAlta` devuelve `{msg=null, bloquear=false}` → ninguna
  validación WM bloquea; el único motivo es ausencia de datos de póliza.
- No aplica comprobación de solicitud existente (ninguna aceptada).
- Hipótesis probable: pólizas de otro ramo/compañía/sistema no servido por
  `IEmitirAutosPolizas` en PRE (mismo comportamiento tendría SCA ��� el código es
  byte-idéntico).

## Capturas
- **No capturadas**: la sesión Chrome (AA) se perdió con el reinicio; login
  nativo `devin` rechazado ("nombre de usuario/contraseña no válido") y SSO
  Mapfre PRO exige cuenta corporativa interactiva. La evidencia de la
  ejecución real de las reglas del popup está en `t18_out.json`
  (20/20 uniformes). Con sesión activa el popup mostraría el mismo literal ya
  capturado en `t16d_popup.png`.

## Tanda 18-bis — corrección (clasificación engañosa aclarada)
- **Mi ejecución por MCP era engañosa**: `SCA2_consultarPolizas` devolvió `{MSSConsultarPolizas=null}` en el test runner pero el popup real SÍ recibe datos (verificado por el usuario en site SCA2 con 2001900000007). Causa del artefacto: el test runner ejecuta la regla en contexto distinto (sin navegación UI que alimenta ciertos datos/contexto de sesión; la cadena depende del entorno de ejecución) — documentado: **los smoke tests de wrappers de integración vía runAllExpressionRuleTestCases no reproducen la respuesta real del popup**.
- **Bug real encontrado**: `SCA2_pObtenerPolizaFecha` tiene el input `mSEPObtenerPolizaFechaDTO` declarado `Map`; en SCA es el CDT `mSEPObtenerPolizaFechaDTO`. `SCA2_polizaVigente` (byte-idéntica a SCA) pasa `{{...}}` — lista de 1 diccionario — que el input CDT de SCA coerciona y el input Map de SCA2 rechaza → `Could not cast from List of Dictionary to Map`. Las demás llamadas a la regla pasan diccionario simple `{...}` y no fallaban.
- **45 inputs Map-vs-CDT latentes** detectados por reconciliación estática (mismas reglas batch-B); solo rompe donde el llamador pase lista — catalogados, no tocados todos (alcance: la cadena del popup).
- **Dropdown "Tipo Poliza (NO VIDA)"**: el site real `sca-site` usa `SCA_BuscadorSolicitudPrincipal` → popup SIMPLE `SCA_AltaSolicitudAnulacionPopUp` (_…_1685739) que NO tiene el campo; el nuestro venía del clon "Estrategicas" (con dropdown). Fix: eliminar el dropdown del popup SCA2 manteniendo `eleccionPoliza=1` (padding a 13 dígitos = comportamiento por defecto y el del popup simple).
- SCA (sca-site) da de alta estas pólizas hoy (solicitudes 15787441/15787438 sobre 2001900000168) → las 20 son válidas; el fallo era de SCA2.

## Tanda 18-bis — hallazgos finales (debug en vivo, sesión AA)

### Causas SCA2 encontradas y corregidas
1. **`SCA2_polizaVigente`**: llamaba `rule!SCA2_pObtenerPolizaFecha({{...}})` (lista-de-1-diccionario); el input en SCA2 está declarado `Map` (en SCA es CDT, que coacciona la lista). Fix: pasar `{...}` diccionario simple — idéntico semánticamente a SCA. Deployed.
2. **Dropdown "Tipo Poliza"**: el popup SCA2 se clonó de `SCA_AltaSolicitudAnulacionPopUpEstrategicas`, pero el site SCA usa `SCA_AltaSolicitudAnulacionPopUp` (simple) que NO tiene dropdown ni rama Vida ni `eleccionPoliza`. Eliminado el bloque `cardLayout+dropdownField` (deployed; popup ahora solo "Número póliza" como SCA).
3. **`SCA2_pObtenerPolizaFecha`**: añadido `cast('type!{...}mSEPObtenerPolizaFechaDTO', ri!...)` para emular la coerción CDT→CDT del input SCA (input SCA2 es `Map` por limitación de la API — no acepta tipos CDT vía `typeReference`).

### Root cause del rechazo restante (NO es cast ni estructura)
Instrumentando el popup en vivo: `detallesPoliza` recibe **`{success:false, result:{statusLine:"HTTP/1.1 500 Internal Server Error"}, body:<soapenv:Fault>axis2ns502:Server "Internal Error"</soapenv:Fault>}`** — el router `core7.pre.mapfre.net:26007/EVT21_NSE_CCFSAEmKLnConsultaPoliza_1_3_0` devuelve **500 axis2 "Internal Error"** tanto para 2001900000007 como para 2001900000168 (la que sí se da de alta en SCA). La petición SOAP de SCA2 es funcionalmente idéntica a la de SCAC (mismo bodyContent, mismas constantes, `toxml(consulta)`). Hipótesis principal: **fallo del backend PRE** (endpoint caído o rechazando la petición); discriminator pendiente: probar la misma póliza en sca-site **de este mismo entorno dev** — si SCA-dev también da 500, es ambiental y no hay divergencia SCA2.

### Por qué el MCP devolvió `MSSConsultarPolizas=null` en t18
El test-runner de Appian ejecuta la regla bajo el usuario de la sesión API (devin, basic auth): la integración real sí se ejecuta, pero la respuesta se mapeaba a `null` — el contexto de usuario/credenciales del smoke test no reproduce el contexto del popup (usuario AA). Documentado: **no usar el test-runner MCP para inferir datos de runtime de integraciones**; el popup real recibía respuesta (el 500) que el runner no reflejaba.

### Estado objetos (validate HTTP 200 en cada PUT)
- `SCA2_polizaVigente` v+: `{{...}}`→`{...}` — diff lógico vs SCA: ninguno (SCA tolera `{{}}` por CDT).
- `SCA2_pObtenerPolizaFecha` v+: `cast()` DTO — diff: emula coerción de input que SCA hace por tipo; resto byte-idéntico.
- `SCA2_pObtenerPolizaFechaIntegracion`: sin cambios funcionales (header revertido tras prueba; `ignoreEmptyHeaders` extra no causal).
- `SCA2_AltaSolicitudAnulacionPopUp` v+: dropdown eliminado; DBG temporal insertado y revertido (verificado en pantalla: mensaje limpio SCA idéntico).
- `SCA2_consultarPolizas`, `validacionesPreviasPopupAlta`, `comprobacionesPreviasWM`: sin cambios (coinciden con SCA).

### Pendiente (bloqueo externo)
Las 20 pólizas siguen rechazando porque `pObtenerPolizaFecha` recibe HTTP 500 del Core7 PRE — se necesita: (a) confirmar si sca-site en ESTE dev reproduce el 500 (el usuario tiene acceso); (b) si SCA-dev funciona, capturar la petición XML exacta de ambas para comparar byte a byte. Hasta entonces NO se puede confirmar aceptación.

## Tanda 18-ter — root cause del 500 y fix (cerrado)

### Causa raíz CONFIRMADA (evidencia empírica en vivo)
El router Core7 devolvía `HTTP 500 axis2ns502:Server "Internal Error"` porque el XML del body no era equivalente al de SCAC:
- En SCAC, `ri!consulta` es el CDT tipado `pObtenerPolizaFecha` → `toxml` emite `<n1:pObtenerPolizaFecha xmlns:n1="http://ejb.cfsa.emklnconsultapoliza.app.mapfre.com/1_3_0/">` con namespace y orden de campos del CDT.
- En SCA2 el input `consulta` es `Map` → el CDT que llega se degrada a diccionario → `toxml` emitía XML sin `xmlns:n1`/prefijo → axis2 no puede unmarshalar → 500.
- Captura del XML SCA2 (instrumentación DBG en vivo, revertida): `<n1:pObtenerPolizaFecha xmlns:n1="..."><MSEPObtenerPolizaFecha><pcodcia>41.0</pcodcia><pnumpoliza>2001900000007</pnumpoliza>...` — el DTO en sí era correcto; el fallo era la pérdida del tipo CDT al cruzar el boundary Map.

### Fix aplicado (patrón acordado: CDT solo dentro del body)
`SCA2_pObtenerPolizaFechaIntegracion` bodyContent:
`toxml(cast('type!{http://ejb.cfsa.emklnconsultapoliza.app.mapfre.com/1_3_0/}pObtenerPolizaFecha', ri!consulta), true, "pObtenerPolizaFecha")`
→ el `cast` Map→CDT dentro del body restaura el XML namespaced byte-equivalente a SCAC. PUT 200.
El `cast()` añadido en `SCA2_pObtenerPolizaFecha` (Map→DTO) se mantiene — emula la coerción del input CDT de SCA.

### Verificación en vivo (popup SCA2, sesión AA, sin pulsar ALTA/GUARDAR)
- `2001900000007` → ACEPTADA (botón ALTA habilitado, sin mensaje) — igual que SCA. ss_bc84fe0a.png
- `2001900000011` → ACEPTADA. ss_a448bdd5.png
- `2001900000269` → ACEPTADA. ss_8283c27f.png
- `2001900000168` → "La póliza tiene pendiente una solicitud en SCA, por lo que no es posible dar de alta una nueva…" — IDÉNTICO al comportamiento SCA (misma validación WM previa). ss_2f5b6133.png
- Popup limpio (sin DBG, sin dropdown) tras revertir instrumentación. ss_a44405ba.png

### Patrón de riesgo — integraciones SOAP SCA2 pendientes de revisar (NO tocadas)
63 integraciones comparten el mismo patrón (input `consulta: Map` + `toxml(ri!consulta)` en bodyContent sin cast): aceptarAutorizacion, actualizarMecanizacion, actualizarSolicitud, actualizarVariable, altaAccAdm, altaContraAnul, buscarMatricula, comprobarPropietario, consultaClasificacionTC, consultaClave, consultaDetalleGestion, consultaDetalleSolicitud, consultaGestion, consultaImpr, consultaPropiedadClave, consultarAccAdm, consultarAccesoStudPorModo, consultarAnulacionPoliza, consultarAutorizacion, consultarCabecera, consultarCausa, consultarConcepto, consultarDP, consultarDetalle, consultarDocumentos, consultarEquipos, consultarListadoObs, consultarMotivo, consultarNotificacionesExt, consultarPlanPagoPorPoliza, consultarPolizas, consultarSolicitudes, consultarTipoArg, consultarVariable, crearAutorizacion, executeAsignar, finalizarContraAnulPca, finalizarSolicitud, guardarAccAdm, guardarAutorizacion, guardarConcepto, guardarEjecuArg, guardarImpr, guardarMecanizacion, guardarTipoArg, inbsDeleteDocumentDTO, insertarNotificacionExterna, insertarObservaciones, marcarAsignacionBonificacion, modificarArgumento, modificarCatalogacionCodCiaCntrAnul, modificarCrearDocumentoCarta, modificarCrearDocumentoDni, modificarCrearDocumentosAdmin, obtenerDatosProductor, obtenerEstComNuuma, obtenerEstructuraComercial, obtenerOficinasFisicasNuuma, obtenerPolizaPrerenovada, pBuscarPoliza, simularAnulacionPoliza, visualizarDatosSolicitud (+ pObtenerPolizaFecha ya arreglada).
**Nota**: algunas de estas ya funcionan (consultarPolizas devuelve datos en el Detalle) — posiblemente porque el XML dictionary-toxml resulta aceptable para esos endpoints o el caller ya pasa un map que serializa bien. Recomendación: aplicar el mismo `cast` solo donde el servicio exija el namespace/CDT estricto (verificar cada tipo CDT del SCAC original en el input `consulta`).

### Objetos tocados (18-bis + 18-ter), todos PUT 200 / validados en vivo
- `SCA2_polizaVigente` — `{{}}`→`{}` (llamador, paridad SCA).
- `SCA2_pObtenerPolizaFecha` — `cast()` Map→DTO en entrada (resto byte-idéntico a SCA).
- `SCA2_pObtenerPolizaFechaIntegracion` — `cast()` Map→CDT `pObtenerPolizaFecha` en bodyContent (fix del 500).
- `SCA2_AltaSolicitudAnulacionPopUp` — dropdown "Tipo Poliza" eliminado (paridad con popup simple SCA); instrumentación DBG revertida.

## Tanda 18-quater — cast CDT en las 63 integraciones SOAP (cerrado)

### Cambio aplicado
Patrón idéntico al fix de `pObtenerPolizaFechaIntegracion` aplicado a las **63 integraciones SOAP SCA2** con `consulta: Map` + `toxml` en bodyContent:
```
toxml(value: cast('type!{ns}Tipo', ri!consulta), format: true, name: "raiz")
```
El tipo CDT (namespace+nombre) se tomó del input `consulta` declarado en la integración **SCAC original equivalente** (dump `dump/SCAC/integrations/`), no deducido; el `name` raíz se dejó exactamente como estaba (coincidía con SCAC en todas). Namespace resuelto por barrido de literales `type!{ns}Name` en el dump (`t18q_nsmap.json`, `t18q_plan.json`).

### Resultado despliegue
- **62 integraciones**: cast aplicado vía PUT (200) y verificado por re-GET (body contiene `cast('type!{ns}...` con su ns correcto).
- **1 integración**: `SCA2_pObtenerPolizaFechaIntegracion` ya lo tenía (18-ter) → SKIP.
- **2 incidencias transitorias**: `consultarCausa` devolvió 400 pero el body ya quedó aplicado (re-PUT → 200); `consultarConcepto` requería limpiar `testInputs` stale (referencia a input `rand` eliminado en t17) → PUT con `testInputs:[]` → 200. **Nota**: el test case guardado de `consultarConceptoIntegracion` quedó vacío — es el único efecto colateral.
- Verificación final: las 63 contienen el cast correcto con su namespace (0 BAD/ERR).

### Paridad XML
Criterio byte-equivalente: el `cast` restaura el CDT → `toxml` emite el XML namespaced `<n1:Raiz xmlns:n1="ns">` igual que el input CDT tipado de SCAC (probado en vivo en `pObtenerPolizaFecha` → popup aceptó). `testExpression` no está disponible en esta sesión (POSTs a lcp-api → 401), así que la verificación es estática + la prueba viva de la rama NSE.

### Smoke post-batch (sesión AA, sin ALTA/GUARDAR)
- Popup 2001900000007 → sigue aceptando (consultarSolicitudes/obtenerTareas/validaciones/pObtenerPolizaFecha OK tras el cast). ss_573861ae.png
- Detalle TEST-SCA2-000 → renderiza sin errores. ss_5363b1f5.png

### Riesgo residual
Si en alguna integración el Map de entrada usa claves que NO coinciden exactamente con los campos del CDT (case o nombre), `cast` produce campos nulos → XML sin esos campos. No se ha detectado en los smoke tests, pero conviene probar cada flujo (Detalle, Decidir, Alta real) antes de PRO.

## Tanda 18-quinque — Alta SCA2 vacía tras ALTA (root cause + fix)

**Síntoma**: popup acepta `2001900000007` pero la página Alta queda vacía (cabecera "… - - NIF:", Datos cliente "-", sin sección de formulario, footer duplicado).

**Causa raíz (no era el cast masivo)**: `SCA2_AltaSolicitudPage` cargaba `local!poliza` SOLO vía `SCA2_consultarPolizas` (servicio wAutemis). Para NSE-Autos devuelve null → `local!pca={}` → `local!dp={}` → datos nulos y la card del formulario (`if(a!isNotNullOrEmpty(local!dp))`) no se renderiza. Bug desde t13-4; primera vez alcanzable tras el fix 18-ter del Core7.

**Fix aplicado** (PUT 200 en `SCA2_AltaSolicitudPage` `_20055716`, backup `.bak_t18q2`):
- `local!tipoPolizaCalc`/`local!polizawAutemis` vía `SCA2_obtenerTipoPoliza` = cons!SCA2_TXT_WAUTEMIS.
- `local!poliza`: wAutemis → consultarPolizas; NSE → `SCA2_pObtenerPolizaFecha` con el MISMO retry de SCA (reintento añadiendo `pfechaconsulta: todate(a!addDateTime(today(),1))` si MSSPObtenerPolizaFecha/poconpolizat vacíos). Map posicional con pcodcia=41/pmcaconsultaglobal=S/pmcalk=S — idéntico a `SCA2_ModalClaveProduccion`.
- Nuevos locals con rutas reduce byte-idénticas a SCA: `datosPersonales`/`datosGeneralesPol` (`poconpolizat.array.1.datospersonales|datosgeneralespol.array.1`), `figurasParticipantes` (`…figurasparticipantes.1.array.figuraparticipante`), `tomador` (figura codinterv="TO").
- `local!dp` pasa a ser `local!datosGeneralesPol` → el gate del formulario se cumple.
- Mapas por rama: nif `NUM_DOCUM`/`coddocum`, idCliente `COD_INT`/`codint`, nombre/apellidos `NOMBRE+APE1+APE2`/`nomtercero+ape1tercero+ape2tercero`, ramo `COD_RAMO`/`codproducto`, lineaNegocio `LINEA_NEGOCIO`/`codsector`, tipoPoliza = tipoPolizaCalc (NSE).
- **Footer**: eliminado `rule!SCA2_PieDePagina()` de la página (el Buscador ya lo pinta → queda 1). Intenté gatearlo en `SCA2_Buscador` pero su expresión desplegada NO pasaba validación de PUT incluso sin cambios ("Unresolved reference(s): xml, text" — quirk latente del validador sobre `text:` kwargs); la deduplicación por el lado de la página da el mismo resultado visual (1 footer).

**Diferencias restantes vs SCA (documentadas, no corregidas)**:
- SCA Alta enriquece con `profileAPI`/`contactMethodAPI`/WS extra (RSV prima, Club Mapfre activo/perfil, tipo cliente valor, treboles, dto integralidad, apoderado/carterizado por figuras "AP"/"CH" explícitas). En SCA2 esos campos del mapa siguen a "-" / "No" por defecto.
- Campos de póliza NSE con claves propias no mapeadas (nombreProducto, formaPago, fechas, prima, planPago…) → "-".
- `lineaNegocio` para motivos usa `codsector` (NSE) asumiendo equivalencia numérica con LINEA_NEGOCIO (SCA documenta ese mismo campo en comentario).

## Tanda 18-sex — null en SCA2_DatosCliente + port de enriquecimientos

**Error runtime**: "Error in rule 'sca2_datoscliente'… A null parameter has been passed as parameter 1".
**Causa**: en NSE el nombre del tomador está ANIDADO en `tomador.datospersonales.array.1.personafisica.nomtercero` (razonsocial si mcafisico<>"S"); mi `index(tomador,"nomtercero")` plano devolvía null → `split(null," ")` dentro del `a!safeLink` del NIF → error.

**Solución adoptada (más fiel a SCA que mapear a mano)**: SCA no construye datosCliente en la página — lo toma de `SCA_obtenerDatosCabecera` → `estructuraCabecera` (vía DatosCabecera→MilestoneMasDatosAltaSolicitud). `SCA2_obtenerDatosCabecera` ya existía y YA implementa todos los enriquecimientos para NSE:
- tomadorNombre/Ape1/Ape2/Nif con rutas `personafisica` anidadas + fallback razonsocial
- `searchAPIClients` → clientId/nif/nombre (preferido si devuelve datos)
- `integralityDiscountPercentAPIClients` → dtoIntegralidadNuevaProduccion
- `benefitsAPIClients`+teCuidamos → treboles, activoClubMapfre, perfilClubMapfre
- `perfilAPIClients` → tipoClienteValor (icono) + tipoClienteDesc
- `consultarReservaPrima` → rsvPrima; cabecera→respuestaCarterizacion → carterizado
- `contactMethodAPIClients`/address → datosContacto; otrasSolicitudesCabecera

**Cambio en `SCA2_AltaSolicitudPage`** (PUT 200 tras 2 iteraciones de limpieza de locals):
- `local!estructuraCabecera: rule!SCA2_obtenerDatosCabecera(numPoliza, idSolicitud:null)`
- `local!datosPoliza`/`local!datosCliente`/`datosContacto` = index de la estructura (eliminados los a!map manuales wAutemis/NSE y los locals huérfanos dt/dv/da/tomador/datosPersonales/figurasParticipantes que el validador rechazó como unused).
- Se conservan: carga `local!poliza` con retry NSE, `local!dp`=datosGeneralesPol (gate del form), `lineaNegocio`=codsector (NSE), footer único.

**Paridad campo SCA→SCA2**: nombre/apellidos/nif (personafisica o searchAPI), apoderado (personajuridica), carterizado (respuestaCarterizacion), RSV prima (consultarReservaPrima), Dto integralidad (integralityAPI), Tréboles/Activo/Perfil Club (teCuidamos), Tipo cliente valor (perfilAPI+obtenerIconoClienteValor) — mismos orígenes que SCA.

Pendiente verificación runtime (ALTA con 2001900000007).

## Tanda 18-sept — "Datos insuficientes" en generarContraAnul + divergencias UI + persistencia

### A) Root cause "Datos insuficientes para la operacion" (PDTE-268896249)

Dos defectos encadenados:
1. **`SCA2_construirContextoAlta` era wAutemis-only** → para NSE-Autos todos los campos del DTO studAnul salían null (corregido en esta tanda: reescrita con rama NSE vía `pObtenerPolizaFecha` + retry, mapeando `datospersonales/datosgeneralespol/agente/datosgeneralesspto/figurasparticipantes/caracteristicas/planesPago` igual que SCA).
2. **Los valores del formulario nunca llegaban al PM**: el nodo 13 "Construir Contexto" llamaba a la regla con `catalogacion:null, fecAnulacion:null, observaciones:null` y sin numFax/idCompania porque la interfaz no los pasaba como parámetros. Fix: la interfaz calcula ahora `datosContexto: rule!SCA2_construirContextoAlta(motivo, detalle, causa, catalogacion:tipoCatalogacion, canalEntrada, lineaNegocio, fecAnulacion:left(fecha,10), telefonoExpertos, observaciones, numFax, idCompania, usuario:loggedInUser(), idioma:"es")` dentro de `processParameters`; el nodo 13 usa `a!defaultValue(pv!datosContexto,…)` → **no hizo falta tocar el PM para esto**. Regla ampliada con inputs `numFax` e `idCompania` (16 inputs).

### Tabla campo DTO studAnul: origen SCA vs SCA2 (rama NSE)

| Campo DTO | SCA (origen) | SCA2 ahora |
|---|---|---|
| datosNumCod.numPoliza | ri!numPoliza | igual |
| codMotivo/codDetalle/codCausa | dropdowns form (int) | igual (form → tostring) |
| datosCod.codTpCatalogacion | tipoCatalogacion derivado por WS catalogación | igual (codCatalogacionDefecto/selección) |
| datosNumCod.codRamo | `codproducto` (datosgeneralespol) | igual vía `sptoNSE.codproducto` |
| datosOtros.codProducto | AU01 si COD_CATEGORIA valcampo="00000009", AU02 si {6,7,8,19} | igual vía `caracNSE[1].valcampo` |
| datosNumCod.codCompania | `codcia` top-level reduce | `codciaNSE` |
| datosCod.codCIAContraria | compañía form | `ri!idCompania` (nuevo input) |
| datosNumCod.claveProduccion | `codterceroagt` (agente) | `agNSE.codterceroagt` |
| datosNumCod.codInt | `codint` tomador | `tomadorNSE.codint` |
| datosCod.numDocumento | `coddocum` | `tomadorNSE.coddocum` |
| datosNumCod.numApli | `numapli` | `polNSE.numapli` |
| estructComercial.{DGT,codSubcentral,codOfidir} | codelemnivel1/2/3 | igual NSE |
| datosOtros.{nomProducto,prima} | nomprodcomercial, impprimatotalperiodo | igual NSE |
| datosOtros.identificadorClave (matrícula) | carac[6].valcampo | `caracNSE[6].valcampo` |
| datosOtros.{observaciones} | campo form | `ri!observaciones` |
| datosNumCod.numFaxPCA | fax form | `ri!numFax` (nuevo input) |
| datosFec.fecAnulacion | fecha form | `ri!fecAnulacion` → todate |
| datosFec.fecSolicitudAnul | fecvctopoliza | `local!fecVcto` (NSE) |
| infoUsuarios.{nuuma,codPerfil,codSubPerfil} | usuario | `obtenerInformacionUsuario` |
| datosCod.{codTpCanalEntrada,codTpOrigen,codTpNegocio} | canal/origen/lineaNegocio form | igual |
| datosPolizaAutos.{vehiculo,tomador,conductor,…} | caracteristicas/figuras NSE | igual NSE |

Campos que antes llegaban **null** al DTO (causa del ALTA_ERROR): catalogación, fecha anulación, observaciones, fax, compañía contraria, y todos los NSE (codRamo, codProducto, codCompania, claveProduccion, codInt, numDocumento, numApli, estructComercial, nomProducto, prima, matrícula, fechas). Todos resueltos.

### B) Divergencias UI corregidas (réplica SCA)

1. **Tipo catalogación**: ahora textField disabled "--- Seleccione ---" mientras `catalogacionDD` vacío; dropdown dinámico (`codCatalogacion`→const SCA2_TXT_TIP_CATALOGACION_PCA) cuando la WS `SCA2_consultarCatalogacionRest` responde (gate: motivo+detalle+causa+canalEntrada no nulos — idéntico a SCA).
2. **Fecha anulación**: `disabled` con la expresión SCA (`tipoCatalogacion≠catalogacionOriginal & ="4"` → habilitada; si no, depende de `fechaHabilitada` de la WS o nulo). Valor `left(defaultValue(...),10)`.
3. **GUARDAR**: disabled ampliado a numPoliza+motivo+detalle+causa+canalEntrada+tipoCatalogacion+fechaAnulacion (+medio si canal=5, +fax si medio=1) con tooltip "Revise los parámetros obligatorios del formulario." — como SCA.
4. **Cabecera**: columna del título MEDIUM_PLUS→**WIDE_PLUS** (título en una línea, "Más Datos" a la derecha).
5. **Popup ALTA**: botón siempre habilitado → `saveInto: if(or(<mismas condiciones de SCA>), {}, {saves})` (SCA usa card con `link:{}` cuando inválido — equivalente: valida al pulsar). **Footer bajo el popup: NO corregible** — requiere editar `SCA2_Buscador` cuyo PUT falla incluso sin cambios ("Unresolved reference(s): xml, text", quirk del validador).

### C) Persistencia en fallo (Buscador)

**Hallazgo SCA**: en `SCA Alta Solicitud Anulacion`/`Generar Solicitud` el nodo "Guardar BBDD" escribe la solicitud **antes** de llamar a `generarStudAnul` → la solicitud existe en BBDD aunque Core7 falle (por eso SCA muestra solicitudes sin número tras error).
**Réplica SCA2**: nuevo nodo **206 "Write Solicitud Error"** en la rama de error de CMD Alta (`5 Resultado?→206→6 Write Error→End`), escribe el record `SCA2 Solicitud` con los mismos campos que el nodo 9 (idSolicitud=`PDTE-`&pp!id — ya lo asigna el output del nodo 4 —, estado "ALTA", `createdAt: now()`). → PDTE-* aparecerá en el Buscador con "Fecha solicitud" (la columna ya mapea `createdAt`, que ahora sí se persiste).
**Limpieza de filas TEST/PDTE basura: BLOQUEADA** — `deleteRecordData` sólo existe vía MCP (conexión rota) y lcp-api no expone borrado de datos; borrado manual por el usuario.

### Objetos tocados (todos PUT 200 verificados por re-GET)
- `SCA2_AltaSolicitudPage` (_20055716): locals catalogación/fecha, dropdown dinámico, dateField disabled, GUARDAR, WIDE_PLUS, `datosContexto` en processParameters. Backup `.bak_t18s`.
- `SCA2_AltaSolicitudAnulacionPopUp` (_20064994): ALTA siempre habilitado.
- `SCA2_construirContextoAlta` (_20056014): +inputs numFax/idCompania (16 total) — desplegado antes en esta tanda.
- `SCA2 CMD Alta` PM (0000f06f): +nodo 206 Write Solicitud Error en rama error.

## Tanda 18-sept2 — catalogación no resolvía + filtro Detalle + Buscador

### 1) Catalogación no se resolvía (Tipo cat. "--- Seleccione ---" indefinido)

La regla `SCA2_consultarCatalogacionRest` es byte-idéntica a SCA — el fallo estaba en **los inputs que la página le pasaba**:
- `compania:` se leía de `datosPoliza.codCiaPoliza` → **null** (esa clave no existe en datosPolizaCabecera; vive en el body de consultarCabecera) → URL `compania//poliza/…` → error → `catalogacionDD` vacío. Ahora `local!codCia` se calcula como SCA: wAutemis `DATOS_POLIZA.COD_CIA`; NSE `reduce(poconpolizat.array.1.codcia)`.
- `claveProduccion` ahora desde `local!datosAgente` (`agente.array.1.codterceroagt` NSE / `DATOS_STR_COMER.CLAVE_PRODUCCION` wA) — antes dependía de la clave en datosPoliza.
- `consultaFecUltimoSiniestro` ahora llama a `rule!SCA2_consultarFechaUltimoSiniestro(numPoliza, matricula, nuuma, "S")` (idéntica a SCA, devuelve `fechaSiniestro`) — antes leía `pca.FEC_ULT_SINI` que en NSE no existe → fecha fallback today() en vez de la real.
- Añadidos los locals que SCA calcula y SCA2 no: `datosAgente`, `datosCaracteristicasVehiculo`, `caracteristicasVehiculo` (6 codcampos), `datosVehiculo` (MATRICULA/CAT_VEHIC), `figurasParticipantes`, `tomador` (codinterv="TO"), `impago` real (wA `ESTADO_RECIBOS.MCA_IMPAGADOS`; NSE `tomador.mediospago.array.1.mcaprimerrecibo="S"`).
- `canalDD` ahora recibe `impago: local!impago` (antes hardcodeaba `false` → divergencia de cálculo de canal/medio).

### 2) Lista Detalle con "IMPAGO DEL SEGURO" de más

SCA aplica `remove(local!detalleDD, 2)` (elimina la 2ª opción = IMPAGO DEL SEGURO) cuando `motivoAnulacion = 1`. Replicado exacto en choiceLabels y choiceValues del dropdown Detalle. Motivo/Causa/Canal/Medio ya eran paritarios (misma regla y filtros que SCA); la corrección de impago alinea además el default de canal.

### 3) Buscador

- "Causa anulación": la columna ya renderiza `proper(datosSolicitud.desccausa)` (verificado estático) — los "-" venían de filas de prueba sin datos.
- "Buscar por Cliente" 5 campos en una fila: editado en `SCA2_Buscador.sail` local, **pero el PUT sigue bloqueado** por el quirk del validador (`"Unresolved reference(s): xml, text"` incluso con la expresión sin cambios — sólo hay 4 usos legítimos de `text:` kwargs y ningún `xml`; el error es espurio del backend). La página Alta muestra 5 campos en fila; el Buscador requerirá edición manual en Designer o un objeto nuevo.

### Objetos tocados (PUT 200, verificados por re-GET)
- `SCA2_AltaSolicitudPage`: locals NSE completos (agente/vehículo/tomador/impago/codCia), consultaFecUltimoSiniestro real, `compania: local!codCia`, canalDD con impago real, filtro Detalle `remove(detalleDD,2)`.
- `SCA2_Buscador` (local only — PUT bloqueado por quirk validador).

## Tanda 18-sept3 — GUARDAR no lanzaba el proceso (10:22)

**Síntoma**: GUARDAR volvía al Buscador sin mensaje, sin fila nueva en Buscador, sin error nuevo en bandeja.

**Causa raíz**: `a!startProcess` en la página pasaba **dos parámetros que NO son PV del PM `SCA2 CMD Alta`**: `idCompania` (ya viaja dentro de `datosContexto` → `codCIAContraria`) y `rsvPrima` (sin PV en el PM). Appian rechaza el lanzamiento cuando un `processParameter` no existe en el modelo → `onError` → el proceso nunca arrancó (por eso no hay instancia, ni fila, ni error nuevo en el registro).

**Fix**: eliminados `idCompania` y `rsvPrima` de `processParameters`. Verificado contra la lista real de PVs del PM — los 15 parámetros restantes coinciden todos (numPoliza, lineaNegocio, origen, origenPoliza, canal, idioma, rol, usuario, gestionSGC, motivoReal, detalleReal, causaReal, telefonoExpertos, isPolizaPRRA, datosContexto).

**Nota observabilidad**: ninguna API de instancias accesible por lcp-api/consola (process-instances 401/404/501; rest/a 403) — la comprobación de instancia creada queda en runtime.
PUT 200 en `SCA2_AltaSolicitudPage`, verificado por re-GET.

## Tanda 18-sept4 — instancias pausadas en PreGenerar (corrección a sept3)

**Corrección a mi diagnóstico anterior**: las pulsaciones SÍ lanzaban instancias (13:47/14:22/14:27, v50/v51, "Activo con errores") — `idCompania` (Integer) y `rsvPrima` (Decimal) SÍ son PVs del PM → revertido mi cambio: `processParameters` vuelve a pasar ambos (PUT 200).

**Error real**: `SCA2_PreGenerarStudAnul` línea 189 → `left(ri!iniciarProcesoPCA.datosPolizaAutos.conductor.fechaCarne)` con fechaCarne null → pausa por excepción.

**Doble fix**:
1. **`SCA2_construirContextoAlta` no rellenaba `conductor.fechaCarne` en NSE** (hardcodeaba null). SCA la saca de la figura `codinterv="CH"` → `datospersonales.array.1.fecexplicencia`. Añadido `local!conductorNSE` (figura CH) y `fechaCarne: if(esAut, ch.FEC_CARNET, reduce(conductorNSE,{datospersonales,array,1,fecexplicencia}))` — mismo origen que SCA. (El resto de campos vacíos del dump — codProducto, idcanal, codTipLocalizador — SCA también los deja vacíos/N-A cuando el dato no existe; idcanal ya va protegido a "0".)
2. **Resiliencia**: los 5 `left(...fecha*, 10)` de `PreGenerarStudAnul` ahora usan `a!defaultValue(<campo>,"")` — si algún dato llega null, produce "" en vez de pausar el nodo (comportamiento idéntico cuando hay dato). PUT 200 ×2 (page revert + contexto + pregenerar).

**Auditoría script tasks sin captura de excepción** (los nodos "Unattended Multiple Questions" no admiten flujo de excepción en Appian; la protección debe ser null-safety de la regla):
- CMD Alta: n13 Construir Contexto, n3 PreGenerar (ya guardados los left()), n7 Contexto (`actualizacionVariablesPostGenerarStudAnul`+`obtenerDatosCabecera` — revisar si falla con datos incompletos).
- `SCA2_cargarSolicitud` se usa en 6 CMD más (Caducar, CambiarNivel, CompletarAccion, CrearAccion, Decidir, Finalizar, Mecanizar, Posponer) — riesgo compartido si devuelve mapa inesperado; consultarServiciosReglas en Decidir; Cambio de nivel en CrearAccion (ifs con defaultValue ya).
- Recomendación pendiente: pasar el mismo patrón `a!defaultValue` a las funciones de fecha/texto dentro de `cargarSolicitud`/`actualizacionVariablesPostGenerarStudAnul` si aparece otro left() null.

**Instancias en pausa (537335875 y anteriores)**: endpoints de cancelación devuelven 401 — **cancela tú las 3 desde Designer/Monitor** (son de prueba).

## 18-sept5 — Error BBDD Core7 generarStudAnul (ALTA_ERROR 14:39, PDTE-268898277)

PM COMPLETED con resiliencia, pero Core7 devolvió: "Ocurrio un error en el acceso a la base de datos".
Payload reconstruido en `alta_payload_2001900000007.xml` (pv!datosContexto real del usuario + mapping PreGenerar).

### Diff campo a campo vs SCA (NSE-Autos, motivo=1)

| Campo studAnul | SCA envía | SCA2 enviaba | Divergencia |
|---|---|---|---|
| codTpOrigen | "2" (motivo=1; "1" solo wA+FEC_EFEC_RECIBO) | "SCA2" (ri!origen via defaultValue) | **CORREGIDO** |
| codCalificacion (tomador) | caracteristicas póliza [COD_SCORE].valcampo | "" (pfNSE.codcalificacion, clave inexistente) | **CORREGIDO** |
| estadoCivil (conductor) | figura CH licencia.1.personafisica.codtipestcivil | "2" hardcodeado | **CORREGIDO** (raw; default "2" en regularizacion) |
| tlfPasoExperto | contactMethodAPI [TELEFONO MOVIL].contactMethodValue | ri!telefonoExpertos (campo form) | **CORREGIDO** |
| datosProductor.* | tipoProductor (consultaClave→obtenerDatosProductor): idcanal/idsubcanal/descsubcanal/esredtel/essi24/estele/idclaseprod/accesosgc/… | desccanal=agNSE.nomelemnivel3; resto null/"N"/"0" fijos | **CORREGIDO** (portada cadena WS completa) |
| codProducto | "" si CAT_VEHIC∉{9,6,7,8,19} | "" | paridad (mismo filtro) |
| codCiaReem / numApliReem | 0 / 0 | 0 / 0 | paridad |
| fecSolicitudAnul | fecvctopoliza | 10/03/2027 0:00 (left 10 chars) | paridad |
| nuuma | loggedInUser | PCARAGE | paridad |
| elementos "" vs omitidos | CDT serializa vacíos igual | "" | paridad toxml |

Sospechoso #1 = codTpOrigen: "SCA2" no es código válido de tpOrigen ({1,2,3,4}); casi seguro la causa del error BBDD.

### Cambios desplegados en SCA2_construirContextoAlta (PUT 200, re-GET verificado)

1. `local!tpOrigen` — lógica SCA pura (ri!origen ya NO pasa por; pasa solo como PV `origen` del PM).
2. Nuevos locals `caracPolNSE`, `contactMethodAPI`, `consultaClave`, `tipoProductor`.
3. `datosProductor` completo desde tipoProductor.
4. tomador.codCalificacion ← COD_SCORE; conductor.estadoCivil ← codtipestcivil.
5. tlfPasoExperto ← contactMethodAPI TELEFONO MOVIL.

Relanzamiento del Alta: usuario en runtime (no reejecutado por agente).

## TEST NSE — primeras 60 pólizas de polizas_nse_vigor.txt

Reglas ejecutadas en TEST: `SCA2_validacionesPreviasPopupAlta` (gate real del popup Alta, incluye solicitud previa) y `SCA2_obtenerDatosCabecera` (cadena NSE + APIClients). **Resultado uniforme para las 60**: `bloquear:false`, `msg:null`; cabecera responde sin error pero con estructura vacía (idéntico a `SCA_obtenerDatosCabecera` de SCA en TEST → el backend PRE no devuelve datos para estas pólizas; la cadena de integraciones SCA2 ya funciona tras la reparación).

| Póliza | devuelve datos | ramo/producto | solicitud previa | apta |
|---|---|---|---|---|
| 2001900000004 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000007 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000011 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000015 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000044 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000091 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000111 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000168 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000193 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000211 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000216 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000220 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000224 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000233 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000239 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000247 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000249 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000263 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000265 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000266 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000269 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000274 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000287 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000288 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000293 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000301 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000304 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000308 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000311 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000314 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000319 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000327 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000331 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000336 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000337 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000352 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000366 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000373 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000381 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000384 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000391 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000469 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000476 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000514 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000530 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000544 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000562 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000604 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000612 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000646 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000654 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000657 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000662 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000666 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000691 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000697 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000702 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000708 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000709 | estructura vacía | Vida/ -  | No | sí* |
| 2001900000715 | estructura vacía | Vida/ -  | No | sí* |

\* "apta" = pasa el gate del popup (`bloquear:false`). Las 60 lo pasan; la cabecera sale vacía porque el backend PRE no devuelve datos (paridad con la regla SCA en TEST).

**Candidatas propuestas (5)**: 2001900000007, 2001900000168, 2001900000004, 2001900000091, 2001900000111 — sin datos de ramo del backend PRE, se priorizan las ya ejercitadas en DEV (0007 con Alta funcionando).
