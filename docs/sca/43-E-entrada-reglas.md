# 43-E — Preparación de la entrada al motor de reglas (`SCA2_construirEntradaReglas`)

**Sesión E** de la fase 1 «lógica legacy en Appian» (doc 41 §5, doc 42 fila E). Entorno: **Appian TEST**, aplicación `SCA2 Sistema Comercial de Anulaciones SCA2`. Estado: **HITO 1 alcanzado** (inventario + regla nueva + pruebas; `SCA2_mapearDatosDecidirAccion` **sin tocar**, pendiente de OK para la delegación).

## 1. Situación actual verificada (objetos leídos por LCP)

| Objeto | Tipo | UUID | Versión | Papel hoy |
|---|---|---|---|---|
| `SCA2 CMD Decidir` | PM | `0000f06f-0eab-8000-6595-7f0000014e7a` | — | Nodo «Cargar»: `pv!sol = rule!SCA2_cargarSolicitud(pv!idSolicitud)`. Nodo «Consultar reglas»: `rule!SCA2_mapearDatosDecidirAccion(datosSolicitud: pv!sol, origenPoliza: pv!sol.estado.origenPoliza, nivelIntervencion: pv!sol.estado.nivelIntervencion ó 1)` y después `rule!SCA2_consultarServiciosReglas(scaServicioReglas: index(dto,1,dto), poliza: sol.datosCompletosSolicitud.datosBasicosSolicitud.numpoliza, codCia: sol.datosPerfilesPca.codcompania, regla: pv!regla ó "accion")`. Salidas: `accion`, `codPerfil` (grupo o perfil), `codSubPerfil`, `destinoMecanizar` (MECANIZAR + lineaNegocio 3 → REDIRECCION_VIDA). **No se toca** (solo lectura). |
| `SCA2_mapearDatosDecidirAccion` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052813` | **3** | Construye el CDT. **No es pura**: llama a `rule!SCA2_consultaBBDDSCA(idSolicitud, devolverSolicitud: true, devolverGestiones: true, devolverMecanizacion: true, resto false)` (REST `consultarOptimizadoProceso`). Tres ramas por `origenPoliza`: `NSE-Hogar` / `NSE-Autos`+`wAutemis`+`wAutemisM` / resto (CDT a nulo). Devuelve una **lista de 1 CDT**. |
| `SCA2_mapearDatosDecidirAccionEstrategicas` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051782` | 1 | Variante con inputs de record y rama Vida. **Sin consumidores** en la aplicación (código muerto). No se toca. |
| `SCA2_consultarServiciosReglas` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053316` | 1 | Si `regla = "mecanizar"` y `mecanizada = true` y `rule!SCA2_obtenerEstadoPoliza(poliza) = "V"`, **reconstruye** el CDT con `mecanizada: false` (y sin `descripcionSCA`, `codigoCompaniaContraria`, `numeroFax`, `subgrupo`, `motivoContacto`, `modoAcceso`); llama a la integración y devuelve `{error, accion, grupo, subgrupo}`. **No tocada** en el HITO 1. |
| `SCA2_consultaBBDDSCA` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051242` | 3 | `cast(SCAC_consultaBBDDSCA, body)`. Devuelve `solicitud` como **texto** `[numSolicitudPca:…,codTipEstSolicPca:2,…]` y `mecanizacion` como **lista de textos** `[numGestionPca:43706156,codTipEstMecaniza:2,codUsr:…]`. |
| `SCA2_cargarSolicitud` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | 7 | Mapa `estado`, `datosCompletosSolicitud{datosBasicosSolicitud, datosSolicitud}`, `datosPerfilesPca`, `datosPolizaAutos/Hogar/Vida`, `datosProductor`, `datosCabecera` (sin `clienteCarterizado`/`clienteNuumapropietario`). |
| `SCA2_scaServiciosReglas` | Integración | `1670a583-311b-4f10-94d3-ff0e3bdf00b3` | 1 | `POST sca_servicios/api/1.0/compania/{codCia}/poliza/{poliza}/{regla}`, body `a!toJson_17r1(parametros)`. No se toca. |
| `SCA2 Datos Cabecera` | Record | `04f597de-5acd-45b2-9ab3-277713cd00a6` | 1 | Campos `clienteCarterizado`, `clienteNuumapropietario`, `polizaClaveproduccion`, `polizaLineanegocio`, `polizaFechavencimiento` (`dd/MM/yyyy`). Solo lectura. |

Consumidores de `SCA2_mapearDatosDecidirAccion` y de `SCA2_consultarServiciosReglas` en los 436 objetos de la aplicación: **únicamente el PM `SCA2 CMD Decidir`**.

## 2. Inventario de campos del CDT `SCAC_scaServiciosReglas` (24 campos)

Origen hoy en `SCA2_mapearDatosDecidirAccion` (rama Hogar = H, rama Autos/wAutemis/wAutemisM = A, rama por defecto = D). `sol` = `ri!datosSolicitud` (salida de `SCA2_cargarSolicitud`); `consulta` = `SCA2_consultaBBDDSCA`. Tipo según la serialización observada en las pruebas.

| Campo | Tipo | Origen (H / A) | Transformación | Rama D | Observaciones / inconsistencias |
|---|---|---|---|---|---|
| `numeroAplicacion` | Text | constante `0` | — | null | Sale `"0"` (texto). |
| `canalEntrada` | Int | `sol.datosCompletosSolicitud.datosSolicitud.canalentrada` | — | null | |
| `perfilEjecucion` | Text | `sol.datosPerfilesPca.codperfil` | — | null | |
| `subperfilEjecucion` | Text | `sol.datosPerfilesPca.codsubperfil` | — | null | |
| `lineaNegocio` | Text | H: `sol.datosPolizaHogar.lineadenegocio`; A: `sol.datosPolizaAutos.lineadenegocio` | — | null | **Vida no tiene rama**: una solicitud con `origenPoliza = "Vida"` cae en D (todo a nulo). Hoy no hay solicitudes Vida en TEST (218 solicitudes: 115 NSE-Autos, 100 wAutemis, 3 NSE-Hogar). |
| `claveProduccion` | Text | H: `datosPolizaHogar.claveproduccion`; A: `datosPolizaAutos.claveproduccion` | — | null | |
| `codigoCatalogacion` | Int | `datosSolicitud.catalogacion` | — | null | |
| `codigoMotivoAnulacion` | Int | `datosSolicitud.codmotivo` | — | null | |
| `codigoCausaAnulacion` | Int | `datosSolicitud.codcausa` | — | null | |
| `nivelDecidirAccion` | Int | `ri!nivelIntervencion` | nulo → `1` | null | El PM ya pasa `nivelIntervencion ó 1`. |
| `fechaAnulacion` | Text | `datosSolicitud.fecanulacion` (Date del record, CORE `dd/MM/yyyy`) | `text(x, "yyyy-mm-dd")` | null | Con un texto ISO de entrada devuelve basura (`"Date out of range (-20261105)"`); con nulo devuelve nulo. |
| `codigoDetalleAnulacion` | Int | `datosSolicitud.coddetalle` | — | null | |
| `codigoSCA` | Text | `datosBasicosSolicitud.idSolicitud` | — | null | |
| `descripcionSCA` | Text | `datosSolicitud.descpca` | — | null | **Siempre nulo**: `SCA2_cargarSolicitud` no expone `descpca`. |
| `codigoCompaniaContraria` | Text | `datosBasicosSolicitud.codciacontraria` | — | null | **Siempre nulo**: el mapa de básicos no tiene `codciacontraria`. |
| `numeroFax` | Text | `datosBasicosSolicitud.numfax` | — | null | Nulo en todas las solicitudes vistas. |
| `estadoUltimaGestion` | Int | `consulta.mecanizacion.codTipEstMecaniza` si no vacío; si no, primer token tras `codTipEstSolicPca:` en `consulta.solicitud`; si no `""` | `split` del texto | **solo** `consulta.mecanizacion.codTipEstMecaniza` (sin fallback) | Como `mecanizacion` es una lista de textos, `index(…,"codTipEstMecaniza")` es **siempre nulo** → en H/A sale el **estado de la solicitud** (`codTipEstSolicPca`, p. ej. 2) aunque la mecanización diga 4; en D sale **nulo**. Inconsistente entre ramas y con el nombre del campo. |
| `anulaTecnico` | Boolean | `datosSolicitud.mcaanulatecnico` | cast a Boolean | null | El record ya trae Boolean. Si llegara texto `"S"` el cast da **false**. |
| `anulaExperto` | Boolean | `datosSolicitud.mcaanulaexperto` | cast a Boolean | null | Ídem. |
| `nuuma` | Text | `datosSolicitud.usuario` | `upper()` | null | `usuario` nulo → nulo. |
| `subgrupo` | Text | constante `""` | — | null | Se serializa como nulo. |
| `mecanizada` | Boolean | `consulta.mecanizacion`: existe token no vacío tras `numGestionPca:` | `split` del texto | **igual** | Único campo calculado también en D. `SCA2_consultarServiciosReglas` lo vuelve a poner a `false` para `mecanizar` si la póliza está vigente. |
| `motivoContacto` | Text | constante `""` | — | null | |
| `modoAcceso` | Text | constante `""` | — | null | |

**Datos del legacy `cPrepararDatosSD` que el CDT no transporta hoy:** recibo impagado (`fecefecimpagado` sí está en `datosSolicitud`, pero el CDT no tiene campo), carterización (`clienteCarterizado`, `pcodretorno = 0`) y propietario (`clienteNuumapropietario` / `SCA2_nuumaEsPropietario`). El motor de reglas de SCA2 **no los recibe** en ninguna rama; añadirlos exigiría cambiar el CDT `SCAC_scaServiciosReglas` (fuera de la fila E) o el contrato del servicio. Ver decisiones en §7.

## 3. Diseño final

Regla **pura** `SCA2_construirEntradaReglas` (sin `rule!` externas ni consultas), con la misma salida que la regla actual (lista de 1 `SCAC_scaServiciosReglas`):

| Input | Tipo | Contenido |
|---|---|---|
| `datosSolicitud` | Map | Salida de `SCA2_cargarSolicitud` (igual que hoy). |
| `datosPoliza` | Map | Opcional. Póliza ya resuelta; si es nulo se toma `datosPolizaHogar` / `datosPolizaAutos` / `datosPolizaVida` según `origenPoliza`. |
| `origenPoliza` | Text | `NSE-Hogar`, `NSE-Autos`, `wAutemis`, `wAutemisM`, `Vida`. |
| `nivelIntervencion` | Text | Nulo → 1. |
| `regla` | Text | `accion` / `alta` / `mecanizar` / `cambioNivel`. Solo influye con `mecanizar` + `extras.estadoPoliza`. |
| `mecanizacion` | Map | Salida de `SCA2_consultaBBDDSCA` (`solicitud`, `mecanizacion`). La llamada externa queda en quien invoca (hoy `SCA2_mapearDatosDecidirAccion`). |
| `extras` | Map | Opcional: `numeroAplicacion`, `subgrupo`, `motivoContacto`, `modoAcceso`, `estadoPoliza`. |

Conversiones concentradas: fecha CORE `dd/MM/yyyy` (texto, Date, DateTime con hora) → `yyyy-MM-dd`; marcas `S`/`N`/`true`/`false`/Boolean → Boolean (nulo se mantiene); nivel nulo → 1; `estadoUltimaGestion` y `mecanizada` con la misma lógica de `split` que hoy; `mecanizar` + mecanización previa + `extras.estadoPoliza = "V"` → `mecanizada = false` (la lógica que hoy hace `SCA2_consultarServiciosReglas`, de forma opcional: si `extras` no llega, el resultado es el de hoy). Rama por defecto idéntica a la actual (todo nulo salvo `estadoUltimaGestion` = `codTipEstMecaniza` y `mecanizada`).

Diferencias **deliberadas** respecto a la regla actual, solo alcanzables con datos que hoy no se dan en TEST (verificado en §5): (1) `origenPoliza = "Vida"` monta el CDT completo con `datosPolizaVida` (hoy: todo nulo); (2) marca texto `"S"` → `true` (hoy: `false` por cast); (3) fecha en texto ISO → se respeta (hoy: basura). Para la delegación del HITO 2 se mantiene todo lo demás idéntico.

## 4. Objetos creados (TEST)

| Objeto | Tipo | UUID | Versión | Carpeta |
|---|---|---|---|---|
| `SCA2_construirEntradaReglas` | Regla de expresión | `_a-0000f093-2064-8000-9d36-011c48011c48_5603604` | 2 | `SCA2 Rules and Constants` |
| `SCA2_construirEntradaReglas_test` | Regla de expresión (13 casos, sin inputs) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603728` | 1 | `SCA2 Rules and Constants` |
| Casos de prueba (test cases) de `SCA2_construirEntradaReglas` | 12 test cases `RESULT_ASSERTIONS` (TC01–TC12, §5.2) | — | — | en la propia regla |

Objetos **no modificados**: `SCA2_mapearDatosDecidirAccion` (v3), `SCA2_consultarServiciosReglas` (v1), PM `SCA2 CMD Decidir`.

## 5. Pruebas

### 5.1 Regresión «antes» (regla actual v3 por `POST /expression-rules/{uuid}/test`) vs. regla nueva (misma entrada)

Entradas reales: `datosSolicitud` = `SCA2_cargarSolicitud(id)` y `mecanizacion` = `SCA2_consultaBBDDSCA(id, …)` ejecutadas por LCP sobre solicitudes **ya existentes** en TEST (solo lectura; no se crearon ni modificaron solicitudes en el HITO 1). Comparación campo a campo de los 24 campos del CDT.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| R01 | NSE-Autos, nivel 2 (póliza 2002000157937) | CDT idéntico | Idéntico (24/24) | OK | 15788155 | — | cargarSolicitud + consultaBBDDSCA por LCP → `mapear` v3 y `construirEntradaReglas` v2 → diff | — |
| R02 | wAutemis, nivel 2 (póliza 0001047017109) | CDT idéntico | Idéntico | OK | 15788168 | — | ídem | — |
| R03 | NSE-Hogar, nivel 1 (póliza 0730780285731) | CDT idéntico | Idéntico (`lineaNegocio` 2, `mecanizada` false) | OK | 15788163 | — | ídem | — |
| R04 | wAutemis PDTE_MECANIZAR, nivel 1 (póliza 0005726682097) | CDT idéntico | Idéntico (`mecanizada` true, `estadoUltimaGestion` 2) | OK | 15788149 | — | ídem | — |
| R05 | `origenPoliza` nulo | CDT vacío idéntico | Idéntico | OK | 15788155 | — | variante de entrada | — |
| R06 | `nivelIntervencion` nulo | `nivelDecidirAccion` 1, resto idéntico | Idéntico | OK | 15788155 | — | variante | — |
| R07 | `origenPoliza` = wAutemisM, nivel 3 | rama Autos, nivel 3 | Idéntico | OK | 15788155 | — | variante | — |
| R08 | `usuario` y `fecanulacion` nulos | `nuuma` y `fechaAnulacion` nulos | Idéntico | OK | 15788155 | — | variante | — |
| R09 | sin `datosPolizaAutos` | `lineaNegocio`/`claveProduccion` nulos | Idéntico | OK | 15788155 | — | variante | — |
| R10 | sin `datosSolicitud` (mapa interno nulo) | campos de solicitud nulos, `mecanizada` true | Idéntico | OK | 15788155 | — | variante | — |
| R11 | `origenPoliza` = "Vida" | **Diferencia deliberada**: hoy todo nulo; nuevo CDT completo con `datosPolizaVida` | Difiere solo en esta rama | OK (documentado) | 15788155 | — | variante | Decisión §7.1 |
| R12 | marcas `mcaanulatecnico` = "S" (texto) | **Diferencia deliberada**: hoy `false`; nuevo `true` | Difiere solo en `anulaTecnico` | OK (documentado) | 15788155 | — | variante | El record trae Boolean; no alcanzable hoy |
| R13 | `fecanulacion` texto ISO "2026-11-05" | **Diferencia deliberada**: hoy "Date out of range (-20261105)"; nuevo "2026-11-05" | Difiere solo en `fechaAnulacion` | OK (documentado) | 15788155 | — | variante | El record trae Date; no alcanzable hoy |

Salidas «antes» guardadas (fuera del repo, sesión E): `antes_cargar_<id>.json`, `antes_consulta_<id>.json`, `antes_mapear.json`, `antes_mapear_variantes.json`; «después»: `despues_nueva.json`. Tiempo de evaluación de la regla nueva por LCP: < 1 s por caso (la actual, 0,9 s incluida la consulta REST).

### 5.2 Casos de prueba (test cases) de `SCA2_construirEntradaReglas` — 12/12 OK (datos sintéticos, póliza ficticia 2002000000001, solicitud ficticia 99000001)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| TC01 | Autos, nivel 1, regla `alta`, mecanización previa | lineaNegocio 1, clave 5259034, fecha 2026-11-05, nuuma USUPRUEBA, mecanizada true, estadoUltimaGestion 2, nivel 1, codigoSCA 99000001 | igual | OK | sintética | — | `POST …/test-cases/run` | — |
| TC02 | Hogar, regla `alta`, sin mecanizar | lineaNegocio 2, clave 0084048, mecanizada false | igual | OK | sintética | — | ídem | — |
| TC03 | Vida, regla `alta` | lineaNegocio 3, clave 0099001, fecha 2026-11-05 | igual | OK | sintética | — | ídem | — |
| TC04 | wAutemisM, regla `cambioNivel`, nivel 3 | lineaNegocio 1, nivel 3, mecanizada true | igual | OK | sintética | — | ídem | — |
| TC05 | regla `mecanizar`, mecanización previa, `extras.estadoPoliza` = V | mecanizada false | igual | OK | sintética | — | ídem | — |
| TC06 | regla `mecanizar` sin `extras` (como hoy) | mecanizada true | igual | OK | sintética | — | ídem | — |
| TC07 | marcas texto S / N | anulaTecnico true, anulaExperto false | igual | OK | sintética | — | ídem | — |
| TC08 | fecha texto con hora "05/11/2026 16:01 CEST" | fechaAnulacion 2026-11-05 | igual | OK | sintética | — | ídem | — |
| TC09 | origen nulo | lineaNegocio/nuuma/estadoUltimaGestion nulos, mecanizada true | igual | OK | sintética | — | ídem | — |
| TC10 | `datosSolicitud` y `mecanizacion` nulos | sin error; lineaNegocio nulo, nivel 1, mecanizada false | igual | OK | sintética | — | ídem | — |
| TC11 | `datosPoliza` explícito | lineaNegocio 7, clave 1234567 | igual | OK | sintética | — | ídem | — |
| TC12 | con recibo impagado (`fecefecimpagado` informado) | mismo CDT que TC01 (el CDT no lo transporta) | igual | OK | sintética | — | ídem | — |

La regla `SCA2_construirEntradaReglas_test` (sin inputs) repite estos casos más «fecha como Date» y devuelve `{todosOk: true, casos: 13}` (ejecutada por LCP: 13/13 OK).

### 5.3 Pruebas funcionales en TEST (alta → `CMD Decidir`)

**No realizadas en el HITO 1** (no hay cambio funcional todavía: `mapearDatosDecidirAccion` no ha sido modificada). Se harán en el HITO 2 con solicitudes nuevas (misma póliza/causa/motivo antes y después, comparación de `SCA2 Transicion` y del resultado del motor, tiempos) y se registrarán en `docs/sca/pruebas/coordinacion-fase1.md`.

## 6. Plan del HITO 2 (tras el OK)

1. Anotar versión actual de `SCA2_mapearDatosDecidirAccion` (v3) y sustituir su cuerpo por: misma cabecera y la llamada a `rule!SCA2_consultaBBDDSCA(...)` como hoy, y a continuación `rule!SCA2_construirEntradaReglas(datosSolicitud: ri!datosSolicitud, datosPoliza: null, origenPoliza: ri!origenPoliza, nivelIntervencion: ri!nivelIntervencion, regla: null, mecanizacion: local!consulta, extras: null)`. Firma y salida idénticas (lista de 1 CDT). Sin constante interruptor: la reversibilidad es volver a la v3 (doc 42 no asigna interruptor a E).
2. Repetir R01–R10 contra la regla modificada y comparar con las salidas «antes» guardadas.
3. Solicitudes nuevas en TEST (Autos NSE, wAutemis, Hogar) → `CMD Decidir`; comparar `accion`/`codPerfil`/`SCA2 Transicion` con una solicitud equivalente anterior y registrar póliza/idSolicitud/instancia/tiempos.
4. `SCA2_consultarServiciosReglas` **no** se toca salvo petición expresa (su reconstrucción del CDT para `mecanizar` pierde 6 campos hoy nulos; mover esa lógica a `extras.estadoPoliza` sería un segundo paso con su propia regresión).

## 7. Pendientes y decisiones que necesita la sesión E

1. **Rama Vida** (R11/TC03): la regla nueva monta el CDT completo para `origenPoliza = "Vida"` (hoy la regla actual devuelve todo nulo). No hay solicitudes Vida en TEST. ¿Se mantiene así en la delegación (impacto solo para Vida, hoy inexistente) o se replica exactamente el comportamiento actual (todo nulo) hasta decidir?
2. **Recibo impagado, carterización y propietario**: el CDT `SCAC_scaServiciosReglas` no tiene campos para ellos y el motor no los recibe hoy en ninguna rama. Opciones: (a) dejarlos fuera (lo hecho: la regla no incluye un input `cabecera` sin uso); (b) añadir una segunda regla pura `SCA2_construirContextoReglas(datosSolicitud, cabecera) → Map {reciboImpagado, fecEfecReciboImpagado, carterizado, propietario}` para diagnóstico/`SCA2 Transicion.detalle` (objeto fuera de la fila E: lo gestiona el coordinador); (c) esperar a `SCA2_esPropietarioPoliza` de la sesión B.
3. **`estadoUltimaGestion`**: hoy sale siempre el estado de la solicitud (`codTipEstSolicPca`) porque `mecanizacion` es una lista de textos y `codTipEstMecaniza` nunca se lee; en la rama por defecto sale nulo. La regla nueva replica el comportamiento (impacto cero). ¿Se quiere corregir (leer `codTipEstMecaniza` del texto) en una fase posterior? Afectaría a la decisión del motor.
4. `descripcionSCA` y `codigoCompaniaContraria` van **siempre nulos** porque `SCA2_cargarSolicitud` no expone `descpca` ni `codciacontraria`. Replicado tal cual; anotar para el equipo funcional.
5. `SCA2_mapearDatosDecidirAccionEstrategicas` no tiene consumidores (candidata a retirar; fuera de la fila E).

## 8. SAIL de los objetos nuevos

### 8.1 `SCA2_construirEntradaReglas`

```sail
/**********************************************************************************
  SCA2_construirEntradaReglas
  Regla PURA (sin llamadas externas) que monta la entrada al motor de reglas
  (CDT SCAC_scaServiciosReglas) a partir de los datos ya cargados.
  Equivale al legacy cPrepararDatosSD (mediación IGestionarProcesoSCA).

  Entradas:
    - datosSolicitud (Map): salida de rule!SCA2_cargarSolicitud (estado, datosCompletosSolicitud,
      datosPerfilesPca, datosPolizaAutos/Hogar/Vida, datosCabecera...).
    - datosPoliza (Map, opcional): datos de póliza ya resueltos. Si es nulo se toma
      datosPolizaHogar / datosPolizaAutos / datosPolizaVida según origenPoliza.
    - origenPoliza (Text): "NSE-Hogar" | "NSE-Autos" | "wAutemis" | "wAutemisM" | "Vida".
    - nivelIntervencion (Text): nivel actual; nulo -> 1.
    - regla (Text): "accion" | "alta" | "mecanizar" | "cambioNivel"... Solo influye si
      regla = "mecanizar" y extras.estadoPoliza está informado.
    - mecanizacion (Map): salida de rule!SCA2_consultaBBDDSCA (campos de texto
      "solicitud" y "mecanizacion" con pares campo:valor separados por coma).
    - extras (Map, opcional): numeroAplicacion, subgrupo, motivoContacto, modoAcceso,
      estadoPoliza ("V" = vigente; si regla = "mecanizar", mecanizada = true y "V" -> mecanizada false).

  Salida: lista con un único SCAC_scaServiciosReglas (misma forma que SCA2_mapearDatosDecidirAccion).
  Si origenPoliza no es ninguno de los soportados, devuelve el CDT con todo a nulo salvo
  estadoUltimaGestion (codTipEstMecaniza) y mecanizada, igual que la regla original.
***********************************************************************************/
a!localVariables(
  local!origenPoliza: if(
    a!isNullOrEmpty(ri!origenPoliza),
    "NULL_OR_EMPTY",
    ri!origenPoliza
  ),
  local!esHogar: local!origenPoliza = "NSE-Hogar",
  local!esAutos: or(
    local!origenPoliza = "NSE-Autos",
    local!origenPoliza = "wAutemis",
    local!origenPoliza = "wAutemisM"
  ),
  local!esVida: local!origenPoliza = "Vida",
  local!soportada: or(local!esHogar, local!esAutos, local!esVida),

  /* Póliza: la recibida o la del origen */
  local!poliza: if(
    a!isNotNullOrEmpty(ri!datosPoliza),
    ri!datosPoliza,
    if(
      local!esHogar,
      index(ri!datosSolicitud, "datosPolizaHogar", null),
      if(
        local!esAutos,
        index(ri!datosSolicitud, "datosPolizaAutos", null),
        if(
          local!esVida,
          index(ri!datosSolicitud, "datosPolizaVida", null),
          null
        )
      )
    )
  ),
  local!datosSol: reduce(
    index(_, _, null),
    ri!datosSolicitud,
    { "datosCompletosSolicitud", "datosSolicitud" }
  ),
  local!datosBasicos: reduce(
    index(_, _, null),
    ri!datosSolicitud,
    { "datosCompletosSolicitud", "datosBasicosSolicitud" }
  ),
  local!perfiles: index(ri!datosSolicitud, "datosPerfilesPca", null),

  /* Última gestión y mecanización (texto "campo:valor,campo:valor" de SCA2_consultaBBDDSCA) */
  local!textoSolicitud: a!defaultValue(index(ri!mecanizacion, "solicitud", ""), ""),
  local!textoMecanizacion: a!defaultValue(index(ri!mecanizacion, "mecanizacion", ""), ""),
  local!splitCodUltimaGestion1: split(local!textoSolicitud, "codTipEstSolicPca:"),
  local!splitCodUltimaGestion2: if(
    length(local!splitCodUltimaGestion1) >= 2,
    split(local!splitCodUltimaGestion1[2], ","),
    {}
  ),
  local!splitMecanizacion: split(local!textoMecanizacion, "numGestionPca:"),
  local!splitMecanizacion2: if(
    length(local!splitMecanizacion) >= 2,
    split(local!splitMecanizacion[2], ","),
    {}
  ),
  local!mcaMecanizada: and(
    length(local!splitMecanizacion2) >= 1,
    a!isNotNullOrEmpty(local!splitMecanizacion2[1])
  ),
  local!codTipEstMecaniza: reduce(
    index(_, _, null),
    ri!mecanizacion,
    { "mecanizacion", "codTipEstMecaniza" }
  ),
  local!estadoUltimaGestion: if(
    a!isNotNullOrEmpty(local!codTipEstMecaniza),
    local!codTipEstMecaniza,
    if(
      length(local!splitCodUltimaGestion2) >= 1,
      local!splitCodUltimaGestion2[1],
      ""
    )
  ),
  /* regla mecanizar: si la póliza sigue vigente ("V") la mecanización previa no cuenta */
  local!mecanizada: if(
    and(
      a!defaultValue(ri!regla, "") = "mecanizar",
      local!mcaMecanizada,
      a!defaultValue(index(ri!extras, "estadoPoliza", ""), "") = "V"
    ),
    false,
    local!mcaMecanizada
  ),

  /* Fecha de anulación: CORE dd/MM/yyyy (texto, Date o DateTime) -> TRON yyyy-MM-dd */
  local!fecAnulacion: index(local!datosSol, "fecanulacion", null),
  local!fecAnulacionTexto: if(
    a!isNullOrEmpty(local!fecAnulacion),
    "",
    tostring(local!fecAnulacion)
  ),
  local!fechaAnulacion: if(
    a!isNullOrEmpty(local!fecAnulacion),
    null,
    if(
      typeof(local!fecAnulacion) = typeof(""),
      if(
        and(len(local!fecAnulacionTexto) >= 10, mid(local!fecAnulacionTexto, 3, 1) = "/"),
        right(left(local!fecAnulacionTexto, 10), 4) & "-" & mid(local!fecAnulacionTexto, 4, 2) & "-" & left(local!fecAnulacionTexto, 2),
        if(
          and(len(local!fecAnulacionTexto) >= 10, mid(local!fecAnulacionTexto, 5, 1) = "-"),
          left(local!fecAnulacionTexto, 10),
          text(local!fecAnulacion, "yyyy-mm-dd")
        )
      ),
      text(local!fecAnulacion, "yyyy-mm-dd")
    )
  ),

  /* Marcas S/N o booleanos -> Boolean (nulo se mantiene nulo) */
  local!mcaTecnico: index(local!datosSol, "mcaanulatecnico", null),
  local!mcaExperto: index(local!datosSol, "mcaanulaexperto", null),
  local!anulaTecnico: if(
    a!isNullOrEmpty(local!mcaTecnico),
    null,
    if(
      typeof(local!mcaTecnico) = typeof(true),
      local!mcaTecnico,
      a!match(
        value: upper(tostring(local!mcaTecnico)),
        equals: "S", then: true,
        equals: "N", then: false,
        equals: "TRUE", then: true,
        equals: "FALSE", then: false,
        default: null
      )
    )
  ),
  local!anulaExperto: if(
    a!isNullOrEmpty(local!mcaExperto),
    null,
    if(
      typeof(local!mcaExperto) = typeof(true),
      local!mcaExperto,
      a!match(
        value: upper(tostring(local!mcaExperto)),
        equals: "S", then: true,
        equals: "N", then: false,
        equals: "TRUE", then: true,
        equals: "FALSE", then: false,
        default: null
      )
    )
  ),

  local!usuario: index(local!datosSol, "usuario", null),
  local!nivel: if(
    a!isNullOrEmpty(ri!nivelIntervencion),
    1,
    ri!nivelIntervencion
  ),

  if(
    local!soportada,
    {
      'type!{urn:com:appian:types:SCAC}SCAC_scaServiciosReglas'(
        numeroAplicacion: a!defaultValue(index(ri!extras, "numeroAplicacion", null), 0),
        canalEntrada: index(local!datosSol, "canalentrada", null),
        perfilEjecucion: index(local!perfiles, "codperfil", null),
        subperfilEjecucion: index(local!perfiles, "codsubperfil", null),
        lineaNegocio: index(local!poliza, "lineadenegocio", null),
        claveProduccion: index(local!poliza, "claveproduccion", null),
        codigoCatalogacion: index(local!datosSol, "catalogacion", null),
        codigoMotivoAnulacion: index(local!datosSol, "codmotivo", null),
        codigoCausaAnulacion: index(local!datosSol, "codcausa", null),
        nivelDecidirAccion: local!nivel,
        fechaAnulacion: local!fechaAnulacion,
        codigoDetalleAnulacion: index(local!datosSol, "coddetalle", null),
        codigoSCA: index(local!datosBasicos, "idSolicitud", null),
        descripcionSCA: index(local!datosSol, "descpca", null),
        codigoCompaniaContraria: index(local!datosBasicos, "codciacontraria", null),
        numeroFax: index(local!datosBasicos, "numfax", null),
        estadoUltimaGestion: local!estadoUltimaGestion,
        anulaTecnico: local!anulaTecnico,
        anulaExperto: local!anulaExperto,
        nuuma: if(a!isNullOrEmpty(local!usuario), null, upper(local!usuario)),
        subgrupo: a!defaultValue(index(ri!extras, "subgrupo", null), ""),
        mecanizada: local!mecanizada,
        motivoContacto: a!defaultValue(index(ri!extras, "motivoContacto", null), ""),
        modoAcceso: a!defaultValue(index(ri!extras, "modoAcceso", null), "")
      )
    },
    {
      'type!{urn:com:appian:types:SCAC}SCAC_scaServiciosReglas'(
        numeroAplicacion: null,
        canalEntrada: null,
        perfilEjecucion: null,
        subperfilEjecucion: null,
        lineaNegocio: null,
        claveProduccion: null,
        codigoCatalogacion: null,
        codigoMotivoAnulacion: null,
        codigoCausaAnulacion: null,
        nivelDecidirAccion: null,
        fechaAnulacion: null,
        codigoDetalleAnulacion: null,
        codigoSCA: null,
        descripcionSCA: null,
        codigoCompaniaContraria: null,
        numeroFax: null,
        estadoUltimaGestion: local!codTipEstMecaniza,
        anulaTecnico: null,
        anulaExperto: null,
        nuuma: null,
        subgrupo: null,
        mecanizada: local!mecanizada,
        motivoContacto: null,
        modoAcceso: null
      )
    }
  )
)
```

### 8.2 `SCA2_construirEntradaReglas_test`

```sail
/**********************************************************************************
  SCA2_construirEntradaReglas_test
  Casos de prueba de la regla pura SCA2_construirEntradaReglas (datos sintéticos).
  Devuelve una lista de mapas {id, caso, esperado, real, ok}; todosOk indica si pasan todos.
***********************************************************************************/
a!localVariables(
  local!datosSol: a!map(
    idSolicitud: "99000001",
    codmotivo: 1,
    coddetalle: 9,
    codcausa: 30,
    usuario: "usuprueba",
    fecanulacion: "05/11/2026",
    catalogacion: 1,
    canalentrada: 1,
    mcaanulaexperto: false,
    mcaanulatecnico: false,
    fecefecimpagado: null
  ),
  local!sol: a!map(
    estado: a!map(idSolicitud: "99000001", numPoliza: "2002000000001", nivelIntervencion: 1, origenPoliza: "NSE-Autos", lineaNegocio: "1"),
    datosCompletosSolicitud: a!map(
      datosBasicosSolicitud: a!map(idSolicitud: "99000001", numpoliza: "2002000000001", codramo: "200", numfax: null),
      datosSolicitud: local!datosSol
    ),
    datosPerfilesPca: a!map(codcompania: "41", codperfil: "CE_RM", codsubperfil: "CE_RM_OFICINA", nuuma: "USUPRUEBA"),
    datosPolizaAutos: a!map(lineadenegocio: "1", claveproduccion: "5259034", fechadevencimiento: "02/09/2027 16:01 CEST"),
    datosPolizaHogar: a!map(lineadenegocio: "2", claveproduccion: "0084048", fechadevencimiento: "06/06/2027 12:00 CEST"),
    datosPolizaVida: a!map(lineadenegocio: "3", claveproduccion: "0099001", fechadevencimiento: "01/01/2028")
  ),
  local!consMecanizada: a!map(
    solicitud: "[numSolicitudPca:99000001,codTipCatalogaPca:2,codTipEstSolicPca:2,numPoliza:2002000000001,codRamo:200,codCia:41]",
    mecanizacion: { "[numGestionPca:43700001,codTipEstMecaniza:3,codUsr:USUPRUEBA]" }
  ),
  local!consSinMecanizar: a!map(
    solicitud: "[numSolicitudPca:99000001,codTipCatalogaPca:2,codTipEstSolicPca:2,numPoliza:2002000000001,codRamo:200,codCia:41]",
    mecanizacion: { "[numGestionPca:,codTipEstMecaniza:,codUsr:]" }
  ),

  /* T01 Autos, nivel 1, regla alta */
  local!t01: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consMecanizada), 1, null),
  /* T02 Hogar */
  local!t02: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "NSE-Hogar", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consSinMecanizar), 1, null),
  /* T03 Vida */
  local!t03: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "Vida", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consSinMecanizar), 1, null),
  /* T04 wAutemisM, cambio de nivel a 3 */
  local!t04: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "wAutemisM", nivelIntervencion: "3", regla: "cambioNivel", mecanizacion: local!consMecanizada), 1, null),
  /* T05 mecanizar con mecanización previa y póliza vigente */
  local!t05: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "mecanizar", mecanizacion: local!consMecanizada, extras: a!map(estadoPoliza: "V")), 1, null),
  /* T06 mecanizar sin estado de póliza (comportamiento actual) */
  local!t06: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "mecanizar", mecanizacion: local!consMecanizada), 1, null),
  /* T07 marcas S/N en texto */
  local!solSN: a!update(local!sol, "datosCompletosSolicitud", a!update(local!sol.datosCompletosSolicitud, "datosSolicitud", a!update(local!datosSol, {"mcaanulatecnico", "mcaanulaexperto"}, {"S", "N"}))),
  local!t07: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!solSN, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consMecanizada), 1, null),
  /* T08 fecha de anulación como Date y como texto con hora */
  local!solFecDate: a!update(local!sol, "datosCompletosSolicitud", a!update(local!sol.datosCompletosSolicitud, "datosSolicitud", a!update(local!datosSol, "fecanulacion", date(2026, 11, 5)))),
  local!solFecHora: a!update(local!sol, "datosCompletosSolicitud", a!update(local!sol.datosCompletosSolicitud, "datosSolicitud", a!update(local!datosSol, "fecanulacion", "05/11/2026 16:01 CEST"))),
  local!t08a: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!solFecDate, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consMecanizada), 1, null),
  local!t08b: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!solFecHora, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consMecanizada), 1, null),
  /* T09 origen nulo -> CDT vacío */
  local!t09: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: null, nivelIntervencion: null, regla: null, mecanizacion: local!consMecanizada), 1, null),
  /* T10 datos de solicitud nulos */
  local!t10: index(rule!SCA2_construirEntradaReglas(datosSolicitud: null, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: null), 1, null),
  /* T11 nivel nulo y mecanización vacía */
  local!t11: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, origenPoliza: "NSE-Autos", nivelIntervencion: null, regla: "alta", mecanizacion: local!consSinMecanizar), 1, null),
  /* T12 datosPoliza explícito prevalece */
  local!t12: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!sol, datosPoliza: a!map(lineadenegocio: "7", claveproduccion: "1234567"), origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consMecanizada), 1, null),
  /* T13 con recibo impagado (fecefecimpagado informado) -> mismo CDT que sin él */
  local!solImpagado: a!update(local!sol, "datosCompletosSolicitud", a!update(local!sol.datosCompletosSolicitud, "datosSolicitud", a!update(local!datosSol, "fecefecimpagado", "01/10/2026"))),
  local!t13: index(rule!SCA2_construirEntradaReglas(datosSolicitud: local!solImpagado, origenPoliza: "NSE-Autos", nivelIntervencion: "1", regla: "alta", mecanizacion: local!consMecanizada), 1, null),

  local!casos: {
    a!map(id: "T01", caso: "Autos nivel 1 regla alta", esperado: "1|5259034|2026-11-05|USUPRUEBA|true|2|1|CE_RM|99000001",
      real: tostring(local!t01.lineaNegocio) & "|" & tostring(local!t01.claveProduccion) & "|" & tostring(local!t01.fechaAnulacion) & "|" & tostring(local!t01.nuuma) & "|" & tostring(local!t01.mecanizada) & "|" & tostring(local!t01.estadoUltimaGestion) & "|" & tostring(local!t01.nivelDecidirAccion) & "|" & tostring(local!t01.perfilEjecucion) & "|" & tostring(local!t01.codigoSCA)),
    a!map(id: "T02", caso: "Hogar", esperado: "2|0084048|false",
      real: tostring(local!t02.lineaNegocio) & "|" & tostring(local!t02.claveProduccion) & "|" & tostring(local!t02.mecanizada)),
    a!map(id: "T03", caso: "Vida", esperado: "3|0099001|2026-11-05",
      real: tostring(local!t03.lineaNegocio) & "|" & tostring(local!t03.claveProduccion) & "|" & tostring(local!t03.fechaAnulacion)),
    a!map(id: "T04", caso: "wAutemisM cambio de nivel a 3", esperado: "1|3|true",
      real: tostring(local!t04.lineaNegocio) & "|" & tostring(local!t04.nivelDecidirAccion) & "|" & tostring(local!t04.mecanizada)),
    a!map(id: "T05", caso: "mecanizar con mecanización previa y póliza vigente", esperado: "false",
      real: tostring(local!t05.mecanizada)),
    a!map(id: "T06", caso: "mecanizar sin estado de póliza (como hoy)", esperado: "true",
      real: tostring(local!t06.mecanizada)),
    a!map(id: "T07", caso: "marcas S/N en texto", esperado: "true|false",
      real: tostring(local!t07.anulaTecnico) & "|" & tostring(local!t07.anulaExperto)),
    a!map(id: "T08", caso: "fecha Date y texto con hora", esperado: "2026-11-05|2026-11-05",
      real: tostring(local!t08a.fechaAnulacion) & "|" & tostring(local!t08b.fechaAnulacion)),
    a!map(id: "T09", caso: "origen nulo -> CDT vacío", esperado: "||||true",
      real: tostring(local!t09.lineaNegocio) & "|" & tostring(local!t09.nivelDecidirAccion) & "|" & tostring(local!t09.nuuma) & "|" & tostring(local!t09.estadoUltimaGestion) & "|" & tostring(local!t09.mecanizada)),
    a!map(id: "T10", caso: "datosSolicitud y mecanizacion nulos", esperado: "||1||false",
      real: tostring(local!t10.lineaNegocio) & "|" & tostring(local!t10.nuuma) & "|" & tostring(local!t10.nivelDecidirAccion) & "|" & tostring(local!t10.estadoUltimaGestion) & "|" & tostring(local!t10.mecanizada)),
    a!map(id: "T11", caso: "nivel nulo -> 1; mecanización vacía", esperado: "1|false|2",
      real: tostring(local!t11.nivelDecidirAccion) & "|" & tostring(local!t11.mecanizada) & "|" & tostring(local!t11.estadoUltimaGestion)),
    a!map(id: "T12", caso: "datosPoliza explícito prevalece", esperado: "7|1234567",
      real: tostring(local!t12.lineaNegocio) & "|" & tostring(local!t12.claveProduccion)),
    a!map(id: "T13", caso: "con recibo impagado: CDT idéntico (el CDT no lo transporta)", esperado: "true",
      real: tostring(a!toJson(local!t13) = a!toJson(local!t01)))
  },
  local!resultado: a!forEach(
    items: local!casos,
    expression: a!update(fv!item, "ok", fv!item.esperado = fv!item.real)
  ),
  a!map(
    todosOk: and(a!forEach(local!resultado, fv!item.ok)),
    casos: local!resultado
  )
)
```
