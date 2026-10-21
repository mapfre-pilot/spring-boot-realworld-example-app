# 43-B — Propietario de la póliza y carterización (fase 1, lógica legacy en Appian)

Sesión B de la fase 1 (doc 41 §2, doc 42 fila B). Entorno: **Appian TEST**, aplicación `SCA2 Sistema Comercial de Anulaciones SCA2` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`). Todo el trabajo se hizo por la API LCP REST (el MCP `appian-dev-mcp-c90b` no recibía credenciales). Fecha: 21-10-2026.

## 1. Resumen

- «Propietario» = el gestor (nuuma) *lleva* la póliza/cliente. Fórmula del legacy (`comprobarPropietario` / `cPropietarioYNivel`): **carterizado (`pcodretorno = 0`) O `MCA_PROPIEDAD_CLAVE = "S"` O `MCA_PROPIEDAD_POLIZA = "S"`**.
- Estado anterior en SCA2: `SCA2_nuumaEsPropietario` devolvía `and(MCA_PROPIEDAD_POLIZA = "S", MCA_PROPIEDAD_CLAVE = "S")` (AND, sin carterización); `SCA2_setDatosGestionSGC(+Estratégicas)` obtenían el propietario del ESB (`wIObtenerInformacionSCA.comprobarPropietario`).
- Se han creado las reglas de la fórmula legacy, la regla de caducidad N1–N4, la constante interruptor (`false`) y el modo sombra. **La funcionalidad visible no cambia** mientras `cons!SCA2_USAR_PROPIETARIO_APPIAN = false` (verificado por regresión antes/después).

## 2. Diseño final

```
SCA2_nuumaEsPropietario(codCia, nuuma, claveProd [, idSolicitud, numPoliza])      ← firma compatible (2 inputs opcionales nuevos)
  └─ SCA2_evaluarPropietarioContraAnulacion(...) → Map {actual, legacy, mcaPropiedadClave, mcaPropiedadPoliza, codRetornoCarterizacion, detalle}
        ├─ SCA2_consultaPropiedadClave (Estruage, UNA llamada, la que ya existía)
        ├─ record SCA2 Datos Cabecera.clienteCarterizado (solo si idSolicitud; sin dato → NA)
        └─ SCA2_esPropietarioPoliza(..., soloDatosLocales: true)  ← pura, sin llamadas
  devuelve if(cons!SCA2_USAR_PROPIETARIO_APPIAN, legacy, actual)

SCA2_sombraPropietarioContraAnulacion(codCia, nuuma, claveProd, idSolicitud, numPoliza)   ← para un saveInto de la interfaz
  └─ evaluar(...) + SCA2_registrarSombraPropietario(origen "CONTRAANULACION") → fila en SCA2 Trazabilidad Cliente

SCA2_setDatosGestionSGC / …Estratégicas (proceso; hoy sin llamadores)
  local!comprobarPropietario  : ESB solo si not(cons)
  local!propietarioAppian     : SCA2_esPropietarioPoliza(..., soloDatosLocales: not(cons))
  local!setPropietario        : if(cons, rama nueva (condición corregida), rama actual intacta)
  local!sombraPropietario     : SCA2_registrarSombraPropietario(origen "SGC" / "SGC_ESTRATEGICAS") si not(cons)
```

### 2.1 Reglas de negocio implementadas

| Regla | Lógica |
|---|---|
| `SCA2_esPropietarioPoliza` | `or(codRetornoCarterizacion = 0, mcaPropiedadClave = "S", mcaPropiedadPoliza = "S")` (mayúsculas/minúsculas y espacios tolerados). Si los tres datos llegan informados no hace ninguna llamada. Si faltan y `soloDatosLocales = false`: Estruage vía `SCA2_consultaPropiedadClave`; carterización primero del record `SCA2 Datos Cabecera` (`clienteCarterizado` "Sí"/"No") y, si está vacío y hay `clienteNif`, `SCA2_consultarCabecera(invocarCarterizacion)`; carterizado solo si `pcodretorno = 0` **y** `pnuuma` informado. Con `soloDatosLocales = true` (sombra): ninguna llamada externa; solo el record. |
| `SCA2_propietarioParaCaducidad` | N1/N2 → `esPropietario`; N3 → `resultadoSD = "ENVIAR A NIVEL 2" and codPerfil = "CE_RM"`; N4 → `resultadoSD = "ENVIAR_A_NIVEL_3"`; nivel desconocido/nulo → `esPropietario` (false si nulo). |
| `SCA2_registrarSombraPropietario` | Escribe en `SCA2 Trazabilidad Cliente`: `fecha = now()`, `sistema = "SCA2"`, `plataforma = "APPIAN"`, `perfilUsuario = nuuma`, `operacion = "SOMBRA_PROPIETARIO_<origen>"`, `resultadoOperacion = "ESB=x;APPIAN=y;COINCIDE=S/N[;detalle]"`, `cliente = idSolicitud`, `poliza = numPoliza`. Devuelve `S`/`N` o `"ERROR"` (`onError`, no propaga). |

### 2.2 Record elegido para la sombra: `SCA2 Trazabilidad Cliente`

- `SCA2 Trazabilidad Cliente` (`30d97aab-7165-4183-9fbc-049afa38da63`, tabla `sca2_trazabilidad_cliente`) solo lo escribe `SCA2_guardarTrazabilidad` y **ninguna interfaz ni regla de SCA2 lo lee** → las filas de sombra no aparecen en pantalla ni alteran nada.
- `SCA2 Transicion` (`0b46024c-58b4-48be-a2a4-20d54bc40815`) lo leen `SCA2_DetalleTransiciones`, `SCA2_DetalleTareas` y `SCA2_S2_diagnosticoSolicitud` por `idSolicitud` sin filtrar por comando: las filas de sombra se mostrarían en el detalle de la solicitud. Descartado.
- Consulta de la sombra: filas con `operacion LIKE 'SOMBRA_PROPIETARIO%'`; `resultadoOperacion` contiene los datos crudos (`CARTERIZACION=0|1|NA;CLAVE=S|N|NA;POLIZA=S|N|NA`).

## 3. Objetos Appian (TEST)

| Objeto | Tipo | UUID | Versión | Estado |
|---|---|---|---|---|
| `SCA2_USAR_PROPIETARIO_APPIAN` | Constante (Boolean) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603472` | v9 (= **false**; v2/v4/v6/v8 = true solo durante las pruebas, v3/v5/v7/v9 vuelta a false) | nuevo |
| `SCA2_esPropietarioPoliza` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603496` | v4 | nuevo (8 tests) |
| `SCA2_propietarioParaCaducidad` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603576` | v1 | nuevo (10 tests) |
| `SCA2_registrarSombraPropietario` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603783` | v2 | nuevo |
| `SCA2_evaluarPropietarioContraAnulacion` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604455` | v1 | nuevo |
| `SCA2_sombraPropietarioContraAnulacion` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604465` | v1 | nuevo (enganchada en el saveInto de FINALIZAR de `SCA2_ContraAnulacionOpciones`) |
| `SCA2_nuumaEsPropietario` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051614` | v1 → **v6** (v2–v5 iteraciones de depuración) | modificado: +inputs opcionales `idSolicitud`, `numPoliza`; delega en `evaluar…`; firma y salida compatibles |
| `SCA2_setDatosGestionSGC` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052999` | v1 → **v2** | modificado (cambio mínimo, ver §4) |
| `SCA2_setDatosGestionSGCEstratégicas` | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053432` | v1 → **v2** | modificado (cambio mínimo, ver §4) |
| `SCA2_ContraAnulacionOpciones` | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | v54 → **v56** (v55 intermedia) | modificado: enganche de la sombra en el saveInto de FINALIZAR y paso de `idSolicitud`/`numPoliza` a `nuumaEsPropietario` (ver §4.3) |

No se ha tocado ningún otro objeto (otras interfaces, integraciones, connected systems, CDTs, records, PMs, objetos SCA/SCAC).

## 4. Cambios en objetos existentes

### 4.1 `SCA2_nuumaEsPropietario` (v1 → v6)
Antes: Estruage + `and(POLIZA = "S", CLAVE = "S")`. Ahora: mantiene los mismos valores por defecto de los inputs (`"-1"` si nulo) y delega en `SCA2_evaluarPropietarioContraAnulacion`, devolviendo `actual` (AND) con la constante en `false` y `legacy` (OR) con `true`. Única llamada externa: la misma consulta a Estruage que ya hacía. Con `idSolicitud` informado añade una consulta al record `SCA2 Datos Cabecera` (local, ~40 ms). `SCA2_ContraAnulacionOpciones` (l.122-123) sigue llamándola con `codCia/nuuma/claveProd`; no se ha modificado.

### 4.2 `SCA2_setDatosGestionSGC` y `…Estratégicas` (v1 → v2)
Bloque `local!comprobarPropietario` (l.285-306 / l.297-318) y `local!setPropietario` (l.307-311 / l.319-323); consumo en `gestionarSGCFinal.datosSGCCaducidad.propietario` (l.359 / l.426).

- `local!comprobarPropietario`: condición `local!llamadas.llamarPropietario = "true"` → `and(local!llamadas.llamarPropietario = "true", not(cons!SCA2_USAR_PROPIETARIO_APPIAN))` (con el interruptor en `true` no se llama al ESB).
- Nuevo `local!propietarioAppian`: `rule!SCA2_esPropietarioPoliza(codCia: datosSGCPoliza.codCia, nuuma: gestionarSGC.nuuma, claveProd: datosSGCPoliza.claveProduccion, numPoliza: datosSGCSolicitud.numPoliza, idSolicitud: gestionarSGC.idSolicitud, soloDatosLocales: not(cons))` solo si `llamarPropietario = "true"`.
- `local!setPropietario`: `if(cons, <rama nueva>, <rama actual sin cambios>)`. Rama nueva: `if(llamarPropietario = "true", tostring(local!propietarioAppian), datosSGCCaducidad.propietario)`.
- Nuevo `local!sombraPropietario`: `rule!SCA2_registrarSombraPropietario(... valorEsb: tostring(ESB), valorAppian: tostring(local!propietarioAppian), origen: "SGC" | "SGC_ESTRATEGICAS")` si `llamarPropietario = "true"` y `not(cons)`.
- Línea de consumo: `propietario: if(a!isNullOrEmpty(local!sombraPropietario), local!setPropietario, local!setPropietario)` (referencia necesaria para que Appian acepte la local; el valor no cambia).

**Hallazgo 2 (condición invertida, documentado, no corregido en la rama actual):** la rama actual hace `if(llamarPropietario = "true", datosSGCCaducidad.propietario, tostring(ESB))`: cuando hay que calcular el propietario usa el valor de entrada (vacío) y descarta el resultado del ESB. Con la muestra de prueba, `propietario` sale `null` antes y después del cambio (interruptor `false`) y `"false"` con el interruptor en `true` (rama nueva corregida).

### 4.3 `SCA2_ContraAnulacionOpciones` (v54 → v56)
Dos cambios mínimos (autorizados por el coordinador; la interfaz es de la fila B):
- l.123: `rule!SCA2_nuumaEsPropietario(codCia: "41", nuuma: local!nuuma, claveProd: local!claveProduccion, idSolicitud: ri!idSolicitud, numPoliza: local!numPoliza)` (dos inputs opcionales nuevos; mismo resultado con la constante en `false`).
- Botón **FINALIZAR**, primer elemento del `saveInto`: `rule!SCA2_sombraPropietarioContraAnulacion(codCia: "41", nuuma: local!nuuma, claveProd: a!defaultValue(local!claveProduccion, index(index(local!sol, "datosPoliza", {}), "claveproduccion", "")), idSolicitud: ri!idSolicitud, numPoliza: local!numPoliza)`. Se eligió FINALIZAR porque su `saveInto` no contiene ningún smart service (CANCELAR y POSPONER ya lanzan `a!startProcess` y Appian solo ejecuta un smart service por `saveInto`), es la acción habitual del gestor y la escritura es tolerante a fallos (`onError` en `SCA2_registrarSombraPropietario`; una incidencia de la sombra no impide la acción). Con la constante en `false` la pantalla no cambia.

## 5. SAIL de las reglas nuevas

### `SCA2_esPropietarioPoliza`

```sail
=a!localVariables(
  /* Fórmula legacy comprobarPropietario: propietario si el cliente está carterizado (pcodretorno = 0)
     O MCA_PROPIEDAD_CLAVE = "S" O MCA_PROPIEDAD_POLIZA = "S" (Estruage).
     Si los tres datos vienen informados la regla es pura (sin llamadas).
     soloDatosLocales = true (modo sombra): no se hace ninguna llamada externa; la carterización se toma solo del record SCA2 Datos Cabecera. */
  local!soloLocales: a!defaultValue(ri!soloDatosLocales, false),
  local!faltanFlagsEstruage: or(a!isNullOrEmpty(ri!mcaPropiedadClave), a!isNullOrEmpty(ri!mcaPropiedadPoliza)),
  local!faltaCarterizacion: a!isNullOrEmpty(ri!codRetornoCarterizacion),
  /* 1) Estruage solo si faltan flags, se permiten llamadas y hay datos para consultar */
  local!consultaPropiedad: if(
    and(local!faltanFlagsEstruage, not(local!soloLocales), a!isNotNullOrEmpty(ri!nuuma), a!isNotNullOrEmpty(ri!claveProd)),
    rule!SCA2_consultaPropiedadClave(
      codCia: a!defaultValue(ri!codCia, "41"),
      nuuma: ri!nuuma,
      claveProd: ri!claveProd
    ),
    null
  ),
  local!mcaClave: upper(trim(tostring(a!defaultValue(
    ri!mcaPropiedadClave,
    reduce(index(_, _, null), local!consultaPropiedad, {"MSSConsultaPropiedadClave", "resultado", "MCA_PROPIEDAD_CLAVE"})
  )))),
  local!mcaPoliza: upper(trim(tostring(a!defaultValue(
    ri!mcaPropiedadPoliza,
    reduce(index(_, _, null), local!consultaPropiedad, {"MSSConsultaPropiedadClave", "resultado", "MCA_PROPIEDAD_POLIZA"})
  )))),
  /* 2) Carterización: primero el record SCA2 Datos Cabecera de la solicitud */
  local!cabecera: if(
    and(local!faltaCarterizacion, a!isNotNullOrEmpty(ri!idSolicitud)),
    index(
      a!queryRecordType(
        recordType: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera',
        fields: {'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado', 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif'},
        filters: a!queryLogicalExpression(
          operator: "AND",
          filters: {a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', operator: "=", value: tostring(ri!idSolicitud))},
          ignoreFiltersWithEmptyValues: true
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id', ascending: false)),
        fetchTotalCount: false
      ).data,
      1,
      null
    ),
    null
  ),
  local!carterizadoCabecera: index(local!cabecera, 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado', null),
  local!nifCabecera: index(local!cabecera, 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif', null),
  /* 3) Solo con llamadas permitidas y NIF: consulta de carterización (mismo REST que usa SCA2_obtenerDatosCabecera).
     Carterizado solo si pcodretorno = 0 Y pnuuma informado (con parámetros nulos el servicio devuelve 0 sin nuuma). */
  local!consultaCarterizacion: if(
    and(local!faltaCarterizacion, not(local!soloLocales), a!isNullOrEmpty(local!carterizadoCabecera), a!isNotNullOrEmpty(local!nifCabecera), a!isNotNullOrEmpty(ri!nuuma)),
    reduce(index(_, _, null), rule!SCA2_consultarCabecera(
      body: {
        invocarCarterizacion: "true",
        invocarEstruage: "false",
        invocarSolicitud: "false",
        numDocumento: local!nifCabecera,
        claveProduccion: a!defaultValue(ri!claveProd, ""),
        numPoliza: a!defaultValue(ri!numPoliza, ""),
        nuuma: ri!nuuma,
        codCiaPoliza: a!defaultValue(ri!codCia, "41"),
        codSolicitud: null
      }
    ), {"respuestaCarterizacion", "respuestaCarterizacion"}),
    null
  ),
  local!pnuumaServicio: lower(trim(tostring(a!defaultValue(index(local!consultaCarterizacion, "pnuuma", null), "")))),
  local!codRetornoServicio: if(
    a!isNullOrEmpty(local!consultaCarterizacion),
    null,
    if(
      and(tointeger(index(local!consultaCarterizacion, "pcodretorno", null)) = 0, a!isNotNullOrEmpty(local!pnuumaServicio), local!pnuumaServicio <> "null"),
      0,
      1
    )
  ),
  local!codRetorno: if(
    not(local!faltaCarterizacion),
    tointeger(ri!codRetornoCarterizacion),
    if(
      a!isNotNullOrEmpty(local!carterizadoCabecera),
      if(left(upper(tostring(local!carterizadoCabecera)), 1) = "S", 0, 1),
      local!codRetornoServicio
    )
  ),
  or(
    and(a!isNotNullOrEmpty(local!codRetorno), tointeger(local!codRetorno) = 0),
    local!mcaClave = "S",
    local!mcaPoliza = "S"
  )
)
```

### `SCA2_propietarioParaCaducidad`

```sail
=a!localVariables(
  /* Lógica legacy cPropietarioYNivel: N1/N2 usan el propietario calculado; N3 y N4 dependen del resultado del servicio de decisión */
  local!nivel: upper(trim(tostring(a!defaultValue(ri!servicioDecision, "")))),
  local!resultado: upper(trim(tostring(a!defaultValue(ri!resultadoSD, "")))),
  local!perfil: upper(trim(tostring(a!defaultValue(ri!codPerfil, "")))),
  a!match(
    value: local!nivel,
    equals: "N3", then: and(local!resultado = "ENVIAR A NIVEL 2", local!perfil = "CE_RM"),
    equals: "N4", then: local!resultado = "ENVIAR_A_NIVEL_3",
    default: a!defaultValue(ri!esPropietario, false)
  )
)
```

### `SCA2_registrarSombraPropietario`

```sail
=a!localVariables(
  /* Modo sombra fase 1: compara el propietario del ESB / lógica actual con el de la regla Appian SCA2_esPropietarioPoliza
     y deja una fila en SCA2 Trazabilidad Cliente (record solo de escritura en SCA2, sin lecturas en pantallas). No altera el valor efectivo.
     La escritura es tolerante a fallos: si falla devuelve "ERROR" sin propagar el error. */
  local!esb: upper(trim(tostring(a!defaultValue(ri!valorEsb, "")))),
  local!appian: upper(trim(tostring(a!defaultValue(ri!valorAppian, "")))),
  local!coincide: if(local!esb = local!appian, "S", "N"),
  a!writeRecords(
    records: {
      'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente'(
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{e5a3a873-e5ce-4412-adae-9750c221cd62}fecha': now(),
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{b19679aa-4754-4c4d-bb3a-711a9fc2070d}sistema': "SCA2",
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{2c4ee947-4c8b-4e87-9a84-f678f0f849b0}plataforma': "APPIAN",
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{7e4b11fe-9463-4259-b1de-e906e9cbb00f}perfilUsuario': a!defaultValue(ri!nuuma, ""),
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{c105a257-3659-4d13-a65b-c2273dbac274}operacion': "SOMBRA_PROPIETARIO" & if(a!isNullOrEmpty(ri!origen), "", "_" & upper(ri!origen)),
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{a70b1ae7-2037-4e9c-8b57-856aa80564f4}resultadoOperacion': "ESB=" & local!esb & ";APPIAN=" & local!appian & ";COINCIDE=" & local!coincide & if(a!isNullOrEmpty(ri!detalle), "", ";" & ri!detalle),
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{3f5c0040-ee35-4aee-85db-8166e00ac26e}cliente': tostring(a!defaultValue(ri!idSolicitud, "")),
        'recordType!{30d97aab-7165-4183-9fbc-049afa38da63}SCA2 Trazabilidad Cliente.fields.{c26ca059-44f1-4c8c-a1aa-17a766327a06}poliza': a!defaultValue(ri!numPoliza, "")
      )
    },
    onSuccess: local!coincide,
    onError: "ERROR"
  )
)
```

### `SCA2_evaluarPropietarioContraAnulacion`

```sail
=a!localVariables(
  /* Fase 1 lógica legacy. Evalúa el propietario para Contra Anulación con UNA sola llamada a Estruage y devuelve:
     actual  = comportamiento actual de SCA2_nuumaEsPropietario (clave Y póliza),
     legacy  = fórmula del legacy comprobarPropietario (carterizado O clave O póliza) vía SCA2_esPropietarioPoliza sin llamadas adicionales,
     detalle = datos crudos para la traza de sombra. La carterización se toma solo del record SCA2 Datos Cabecera (si no hay dato: NA). */
  local!codCia: if(isnull(ri!codCia), "-1", ri!codCia),
  local!nuuma: if(isnull(ri!nuuma), "-1", ri!nuuma),
  local!claveProd: if(isnull(ri!claveProd), "-1", ri!claveProd),
  local!consultaPropiedadClave: rule!SCA2_consultaPropiedadClave(
    codCia: local!codCia,
    nuuma: local!nuuma,
    claveProd: local!claveProd
  ),
  local!MCA_PROPIEDAD_POLIZA: reduce(index(_,_,null), local!consultaPropiedadClave, {"MSSConsultaPropiedadClave", "resultado", "MCA_PROPIEDAD_POLIZA"}),
  local!MCA_PROPIEDAD_CLAVE: reduce(index(_,_,null), local!consultaPropiedadClave, {"MSSConsultaPropiedadClave", "resultado", "MCA_PROPIEDAD_CLAVE"}),
  local!carterizadoCabecera: if(
    a!isNullOrEmpty(ri!idSolicitud),
    null,
    index(
      index(
        a!queryRecordType(
          recordType: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera',
          fields: {'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado'},
          filters: a!queryLogicalExpression(
            operator: "AND",
            filters: {a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', operator: "=", value: tostring(ri!idSolicitud))},
            ignoreFiltersWithEmptyValues: true
          ),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id', ascending: false)),
          fetchTotalCount: false
        ).data,
        1,
        null
      ),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado',
      null
    )
  ),
  local!codRetornoCarterizacion: if(
    a!isNullOrEmpty(local!carterizadoCabecera),
    null,
    if(left(upper(tostring(local!carterizadoCabecera)), 1) = "S", 0, 1)
  ),
  local!actual: and(
    local!MCA_PROPIEDAD_POLIZA = "S",
    local!MCA_PROPIEDAD_CLAVE = "S"
  ),
  local!legacy: rule!SCA2_esPropietarioPoliza(
    codCia: local!codCia,
    nuuma: local!nuuma,
    claveProd: local!claveProd,
    numPoliza: ri!numPoliza,
    idSolicitud: null,
    codRetornoCarterizacion: local!codRetornoCarterizacion,
    mcaPropiedadClave: a!defaultValue(local!MCA_PROPIEDAD_CLAVE, "N"),
    mcaPropiedadPoliza: a!defaultValue(local!MCA_PROPIEDAD_POLIZA, "N"),
    soloDatosLocales: true
  ),
  a!map(
    actual: local!actual,
    legacy: local!legacy,
    mcaPropiedadClave: local!MCA_PROPIEDAD_CLAVE,
    mcaPropiedadPoliza: local!MCA_PROPIEDAD_POLIZA,
    codRetornoCarterizacion: local!codRetornoCarterizacion,
    detalle: "CARTERIZACION=" & if(a!isNullOrEmpty(local!codRetornoCarterizacion), "NA", tostring(local!codRetornoCarterizacion)) & ";CLAVE=" & a!defaultValue(local!MCA_PROPIEDAD_CLAVE, "NA") & ";POLIZA=" & a!defaultValue(local!MCA_PROPIEDAD_POLIZA, "NA")
  )
)
```

### `SCA2_sombraPropietarioContraAnulacion`

```sail
=a!localVariables(
  /* Fase 1 lógica legacy, modo sombra de Contra Anulación. Pensada para ejecutarse en un saveInto (a!writeRecords solo se ejecuta en ese contexto):
     evalúa actual y legacy con una sola llamada a Estruage y registra la comparación en SCA2 Trazabilidad Cliente. No devuelve el propietario ni altera la pantalla. */
  local!evaluacion: rule!SCA2_evaluarPropietarioContraAnulacion(
    codCia: ri!codCia,
    nuuma: ri!nuuma,
    claveProd: ri!claveProd,
    idSolicitud: ri!idSolicitud,
    numPoliza: ri!numPoliza
  ),
  rule!SCA2_registrarSombraPropietario(
    idSolicitud: ri!idSolicitud,
    nuuma: ri!nuuma,
    numPoliza: ri!numPoliza,
    valorEsb: tostring(index(local!evaluacion, "actual", false)),
    valorAppian: tostring(index(local!evaluacion, "legacy", false)),
    origen: "CONTRAANULACION",
    detalle: index(local!evaluacion, "detalle", "")
  )
)
```

### `SCA2_nuumaEsPropietario` (v6, modificado)

```sail
/**********************************************************************************

  SE HACE CONTROL DE NULOS, Y SE LLAMA AL SERVICIO PARA RECUPERAR LA INFORMACION DEL 
  PROPIETARIO, SI AMBOS CAMPOS RECUPERADOS SON "S", EL PROPIETARIO ES EL USUARIO 
  INFORMADO EN EL CAMPO NUUMA

  Autor: NTT Data
  Parámetro:
    Entrada:
      - codCia: Código CIA del usuario
      - nuuma: Nombre corto(nickname) 
      - claveProd: Clave de la propiedad      

***********************************************************************************/

a!localVariables(
  /*Declaración de variables y tratamiento de nulls*/
  local!codCia: if(isnull(ri!codCia), "-1", ri!codCia),
  local!nuuma: if(isnull(ri!nuuma), "-1", ri!nuuma),
  local!claveProd: if(isnull(ri!claveProd), "-1", ri!claveProd),
  
  /*Llamada al servicio para recuperar la información de propietario a tratar*/
  /* Fase 1 lógica legacy: una sola evaluación (Estruage + carterización del record) que devuelve la lógica actual y la del legacy.
     Con cons!SCA2_USAR_PROPIETARIO_APPIAN = false el resultado es el actual (clave Y póliza); con true, la fórmula del legacy. */
  local!evaluacion: rule!SCA2_evaluarPropietarioContraAnulacion(
    codCia: local!codCia,
    nuuma: local!nuuma,
    claveProd: local!claveProd,
    idSolicitud: ri!idSolicitud,
    numPoliza: ri!numPoliza
  ),
  if(
    cons!SCA2_USAR_PROPIETARIO_APPIAN,
    a!defaultValue(index(local!evaluacion, "legacy", false), false),
    a!defaultValue(index(local!evaluacion, "actual", false), false)
  )
)
```

## 6. Hallazgos relevantes

1. **`a!writeRecords` fuera de saveInto no escribe.** Devuelve un «Reaction Tree» que Appian solo ejecuta en un saveInto, una Web API o el test harness de nivel superior. Llamado desde una local de carga de la interfaz (vía `SCA2_nuumaEsPropietario`) no escribe ni da error (comprobado con test de regla, test de interfaz y depuración: `[Reaction Tree]|false`). Por eso la sombra de Contra Anulación se ha separado en `SCA2_sombraPropietarioContraAnulacion`, pensada para un saveInto. En proceso (`setDatosGestionSGC`) aplica la misma limitación: la fila de sombra solo se escribiría si el proceso ejecuta la reacción (no verificado al no haber llamadores).
2. **`SCA2_setDatosGestionSGC` y `…Estratégicas` no tienen llamadores**: ninguna regla, interfaz ni PM `SCA2 CMD *` (13 modelos, búsqueda por nombre y uuid) las referencia. Los flujos SGC reales (`SCA2_posponerGestionSGC`, `SCA2_finalizarGestionSGC`, `SCA2_altaGestionCore`) no manejan el propietario. El cambio se ha hecho igualmente por diseño y es inocuo.
3. **`SCA2 Datos Cabecera.clienteCarterizado` y `clienteNuumapropietario` están vacíos en las 208 filas**: `SCA2_cargarSolicitud` no los persiste. Hasta que la sesión D guarde la cabecera completa, la sombra anota `CARTERIZACION=NA`.
4. **Carterización con parámetros nulos devuelve `pcodretorno = 0`** (`pdesretorno = "Los parámetros de entrada son nulos"`, `pnuuma = "null"`). `SCA2_obtenerDatosCabecera` marca `carterizado = "Sí"` cuando `pcodretorno <> 1`, lo que daría «carterizado» en ese caso. `SCA2_esPropietarioPoliza` exige `pcodretorno = 0` **y** `pnuuma` informado.
5. **AND vs OR**: `SCA2_nuumaEsPropietario` (AND de clave y póliza) es más restrictiva que el legacy (OR con carterización). Con los datos de TEST disponibles (JJGONZ2 y SISANS sobre las claves de las solicitudes existentes) Estruage devuelve `N/N` y el ESB `NO PROPIETARIO`, por lo que ambas fórmulas coinciden; la sombra aportará los datos en cuanto haya gestores propietarios/carterizados. Decisión funcional pendiente (usuario).
6. `SCA2_comprobarPropietario` con un nuuma desconocido para el ESB (`GGALV10`) devuelve vacío (sin excepción): en la rama actual `tostring(null)` → `""`.
7. `SCAC_comprobarClienteCarterizadoIntegracion` (`_a-0000ebdd-82f8-8000-9c64-011c48011c48_12943135`): el CDT `comprobarCliente` exige `MSEComprobarCliente{pcodclien, pnumdocum}` y necesita host/endpoint; no se usa. El fallback de carterización usa `SCA2_consultarCabecera` (mismo REST que `SCA2_obtenerDatosCabecera`), solo con el interruptor en `true` y con NIF.
8. **`local!claveProduccion` de `SCA2_ContraAnulacionOpciones` (l.104) llega vacía**: lee `datosCompletosSolicitud.datosPolizaAutos/Hogar/Vida.claveproduccion`, pero `SCA2_cargarSolicitud` devuelve la clave en `datosPoliza.claveproduccion` (nivel superior; comprobado con 15788189: `datosCompletosSolicitud` solo trae `datosBasicosSolicitud` y `datosSolicitud`). Consecuencia preexistente: `local!mcaPropietarioPoliza` es siempre `false` y `SCA2_nuumaEsPropietario` **nunca llega a invocarse** desde la pantalla (la revisión de póliza renovada no se habilita por propietario). No se ha corregido (cambiaría el comportamiento visible); el enganche de la sombra usa la clave de `datosPoliza` como respaldo. Decisión pendiente del coordinador/usuario.
9. LCP: los valores de los test cases son expresiones SAIL (texto entre comillas); los UUID de test case se regeneran en cada escritura; hay que pasar todos los inputs (`null`) en los casos de nulos; `a!toJson` exige argumentos con palabra clave.

## 7. Pruebas

Formato: `ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución`.

### 7.1 Tests `a!test` (LCP `/test-cases/run`)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T01 | `esPropietarioPoliza` vía carterizado (`codRetorno 0`, flags N) | true | true | OK | — | test case | run all | — |
| T02 | `esPropietarioPoliza` vía clave S | true | true | OK | — | test case | run all | — |
| T03 | `esPropietarioPoliza` vía póliza S | true | true | OK | — | test case | run all | — |
| T04 | `esPropietarioPoliza` ninguna vía (1, N, N) | false | false | OK | — | test case | run all | — |
| T05 | `esPropietarioPoliza` flags en minúscula (`s`) | true | true | OK | — | test case | run all | — |
| T06 | `esPropietarioPoliza` todo nulo (sin datos para consultar) | false | false | OK | — | test case | run all | — |
| T07 | `esPropietarioPoliza` carterización nula y flags N | false | false | OK | — | test case | run all | — |
| T08 | `esPropietarioPoliza` `soloDatosLocales` sin flags ni cabecera | false (sin llamadas) | false | OK | — | test case | run all | — |
| T09 | `propietarioParaCaducidad` N1 esPropietario true / false | true / false | true / false | OK | — | test case | run all | — |
| T10 | `propietarioParaCaducidad` N2 esPropietario true | true | true | OK | — | test case | run all | — |
| T11 | `propietarioParaCaducidad` N3 "ENVIAR A NIVEL 2" + CE_RM | true | true | OK | — | test case | run all | — |
| T12 | `propietarioParaCaducidad` N3 "ENVIAR A NIVEL 2" + SI24 | false | false | OK | — | test case | run all | — |
| T13 | `propietarioParaCaducidad` N3 otro resultado + CE_RM | false | false | OK | — | test case | run all | — |
| T14 | `propietarioParaCaducidad` N4 "ENVIAR_A_NIVEL_3" | true | true | OK | — | test case | run all | — |
| T15 | `propietarioParaCaducidad` N4 otro resultado | false | false | OK | — | test case | run all | — |
| T16 | `propietarioParaCaducidad` todo nulo | false | false | OK | — | test case | run all | — |
| T17 | `propietarioParaCaducidad` nivel desconocido (N9) | esPropietario | true | OK | — | test case | run all | — |

### 7.2 Pruebas con datos reales de TEST (LCP `/expression-rules/{uuid}/test` e `/interfaces/{uuid}/test`)

Datos nuevos creados para esta sesión (anotados en `pruebas/coordinacion-fase1.md`): solicitud **15788189** (póliza 0001047017110, wAutemis, clave 0280999, gestor CE_RM JJGONZ2, PM `SCA2 CMD Alta` 12247493) y **15788190** (póliza 0001047017112, usuario SISANS, PM 17484381). Ambas en `EN_ACCION`, nivel 1, caducidad 28/10/2026. `createdBy` es el usuario técnico de la API.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| R01 | Regresión `nuumaEsPropietario` v1 vs v6 (4 entradas: JJGONZ2/0280999, JJGONZ2/0000000, nulos, XXXXXX/0280999) con interruptor false | mismo booleano | false ×4 antes y después (130-160 ms) | OK | — | — | `/test` antes del cambio, PUT, `/test` después | — |
| R02 | Regresión `SCA2_ContraAnulacionOpciones` (pantalla) con interruptor false | renderiza sin error | sin error; 11,6 s antes, 7,5-9,0 s después | OK | 15788168, 15788189, 15788190 | — | `/interfaces/{uuid}/test` idSolicitud | — |
| R03 | Regresión `setDatosGestionSGC` v1 vs v2 (muestra `gestionarSGC` con `llamarPropietario` activo) | salida idéntica | única diferencia `fechaInicio` (now()); `propietario` = null en ambas | OK | 15788168 | — | `/test` antes/después, diff de la salida | null por la condición invertida (hallazgo 2) |
| R04 | Regresión `setDatosGestionSGCEstratégicas` v1 vs v2 | salida idéntica | mismo error preexistente `Invalid index (3)` antes y después, también con 15788189 y con el interruptor en `true` (ajeno al cambio: `descPca` de la solicitud) | OK | 15788168, 15788189 | — | `/test` antes/después | error preexistente de la regla con esos datos |
| P01 | Gestor CE_RM (JJGONZ2) sobre su solicitud: Estruage / carterización / ESB / reglas | coherentes | Estruage CLAVE=N POLIZA=N; carterización `pcodretorno=1` «El cliente no está carterizado»; ESB `propietario=false` «NO PROPIETARIO»; `actual=false`, `legacy=false`; `esPropietarioPoliza` con llamadas = false (344-467 ms), solo locales = false (38-41 ms) | OK | 15788189 | 12247493 | ver `nueva.py` | no hay gestor propietario de clave en TEST (ver pendientes) |
| P02 | Usuario SI24 (SISANS, CE_MF_SI24) sobre la misma póliza | no propietario, coincide | Estruage N/N; ESB `false` «NO PROPIETARIO»; `actual=legacy=false` | OK | 15788189 / 15788190 | 17484381 | ídem | — |
| P03 | Usuario ajeno (GGALV10, desconocido para el ESB) | ESB vacío, Appian false | ESB devuelve vacío sin excepción; `nuumaEsPropietario`/`evaluar` = false | OK | 15788189 | — | ídem | en la rama actual `tostring(null)` = "" |
| P04 | Carterizador no propietario | `pcodretorno=0` con `pnuuma` → legacy true, actual false | **no reproducible**: ningún cliente de TEST está carterizado (`pcodretorno=1` en todas las consultas) | KO (sin datos) | — | — | `SCA2_consultarCabecera(invocarCarterizacion)` con NIF | pedir cliente carterizado en TEST; la regla pura lo cubre (T01) |
| P05 | CE_RM en N3 | `propietarioParaCaducidad(N3, "ENVIAR A NIVEL 2", "CE_RM")` = true | true (T11/T12) | OK | — | — | a!test | el servicio de decisión no se invoca en esta fila |
| P06 | Sombra: registro de coincidencia | fila `COINCIDE=S` | fila 388: `SOMBRA_PROPIETARIO_CONTRAANULACION`, `ESB=FALSE;APPIAN=FALSE;COINCIDE=S;CARTERIZACION=NA;CLAVE=N;POLIZA=N`, cliente 15788168, póliza 0001047017109 | OK | 15788168 | — | `/test` de `SCA2_sombraPropietarioContraAnulacion` | — |
| P07 | Sombra: registro de discrepancia | fila `COINCIDE=N` | fila 387: `ESB=FALSE;APPIAN=TRUE;COINCIDE=N;CARTERIZACION=NA;CLAVE=N;POLIZA=N` (valores sintéticos) | OK | — | — | `/test` de `SCA2_registrarSombraPropietario` | — |
| P08 | Sombra desde carga de pantalla (`nuumaEsPropietario` v2) | fila nueva | **ninguna fila** (Reaction Tree no ejecutado), sin error en pantalla | KO → rediseñado | 15788168 | — | `/test` regla, `/test` interfaz, consulta del record | hallazgo 1; enganche en saveInto de FINALIZAR (P11) |
| R05 | Regresión `SCA2_ContraAnulacionOpciones` v54 → v55/v56 con interruptor false | misma salida renderizada | salida idéntica normalizando `_cId` y tokens cifrados de saveInto (15788168 y 15788190; 15788189 difiere solo por el estado cambiado en P11: argumento ejecutado y carta impresa); 7,4–11,9 s; sin error | OK | 15788168, 15788189, 15788190 | — | `/interfaces/{uuid}/test` antes/después | — |
| P11 | **UI** (usuario técnico): detalle 15788189 → Contra Anulación → RETOMAR → oficina → argumento 1 NEGATIVO → imprimir carta → CONTINUAR → **FINALIZAR** → modal Sí/No → NO | fila de sombra y pantalla igual | fila **397**: `JJGONZ2 / SOMBRA_PROPIETARIO_CONTRAANULACION / ESB=FALSE;APPIAN=FALSE;COINCIDE=S;CARTERIZACION=NA;CLAVE=N;POLIZA=N / 15788189 / 0001047017110`; pantalla y modal como antes; solicitud sigue `EN_ACCION` | OK | 15788189 | — | Playwright sobre el site `sca2` (TEST) | con v55 no escribía por el hallazgo 8 (clave vacía → hook saltado); corregido en v56 |
| P09 | Interruptor en `true` (solo durante la prueba): `nuumaEsPropietario` y `setDatosGestionSGC` | sin error; SGC `propietario` = regla Appian | `nuumaEsPropietario` = false (legacy coincide); SGC `propietario` = `"false"` (rama nueva) frente a `null` con `false`; constante devuelta a `false` (v9, value 0) | OK | 15788189 / 15788168 | — | PUT constante true → `/test` → PUT false → GET | — |
| P10 | Rendimiento del modo sombra en Contra Anulación | sin llamadas añadidas en la carga | `evaluar` 150-183 ms (≈ la llamada a Estruage que ya existía); record cabecera +40 ms; pantalla 7,5-9,0 s (antes 11,6 s) | OK | 15788189 | — | diagnostics `durationMs` | — |

### 7.3 Pendientes de prueba
- Repetir P11 con usuarios de negocio de cada perfil (pedido al usuario por el coordinador). Guion en §9.
- Casos con gestor propietario de clave y con cliente carterizado: no existen en los datos de TEST consultados. Matriz Estruage JJGONZ2 y SISANS × las 134 claves de producción de las solicitudes existentes: 268 consultas, todas `CLAVE=N, POLIZA=N`. ESB `comprobarPropietario` para 6 solicitudes × 2 usuarios: `NO PROPIETARIO` en 10, respuesta vacía en 2 (póliza 2002500495484, NSE-Autos).

## 8. Pendientes y decisiones

1. ~~Enganche de la sombra~~ Hecho en `SCA2_ContraAnulacionOpciones` v56 (§4.3). Solo se registra al pulsar FINALIZAR; CANCELAR/POSPONER no (un smart service por saveInto).
2. **Persistencia de `clienteCarterizado`/`clienteNuumapropietario`** en `SCA2 Datos Cabecera`: la sesión D la cubre (CMD Alta + PM de refresco); la sombra pasará de `CARTERIZACION=NA` a 0/1 automáticamente.
7. **Clave de producción vacía en la pantalla** (hallazgo 8): decidir si se corrige `local!claveProduccion` para que `SCA2_nuumaEsPropietario` vuelva a evaluarse en Contra Anulación.
3. **Decisión funcional AND vs OR** en `SCA2_nuumaEsPropietario` (usuario): la sombra dará los datos; el cambio es poner la constante en `true`.
4. **Condición invertida** de `setDatosGestionSGC(+Estratégicas)` (hallazgo 2): corregida solo en la rama nueva; decidir si se corrige la actual (sin llamadores hoy).
5. `SCA2_propietarioParaCaducidad` queda disponible para la sesión A (caducidad); no está conectada a ningún flujo.
6. Si se quiere la sombra también en proceso (SGC), usar el smart service *Write Records* en el PM (fuera de esta fila) en lugar de `a!writeRecords` en la regla.

## 9. Guion de prueba para usuarios de negocio (por perfil)

Objetivo: comprobar que la pantalla de Contra Anulación no cambia (constante en `false`) y que cada FINALIZAR deja una fila de sombra. Repetir con un gestor **propietario de su clave**, un **carterizador** del cliente, un **usuario ajeno** (otra clave/oficina), un **SI24** y un **CE_RM**.

1. Dar de alta una solicitud nueva (póliza propia del perfil, no reutilizar las de la tabla de reservas) y anotar `idSolicitud`.
2. Buscador → abrir la solicitud → desplegar «Contra Anulacion» → **RETOMAR**.
3. Seleccionar oficina, marcar un argumento y pulsar **NEGATIVO** (o POSITIVO si se quiere finalizar de verdad); si el perfil lo exige, imprimir la carta y **CONTINUAR**.
4. Pulsar **FINALIZAR**: aparece el modal «Se van a finalizar las acciones de contra anulación. ¿Desea continuar?». Pulsar **NO** si no se quiere finalizar (la sombra ya se ha registrado al pulsar FINALIZAR).
5. Comprobar la fila en `SCA2 Trazabilidad Cliente` (tabla `sca2_trazabilidad_cliente`): `operacion = 'SOMBRA_PROPIETARIO_CONTRAANULACION'`, `cliente = <idSolicitud>`; `resultadoOperacion` = `ESB=<actual>;APPIAN=<legacy>;COINCIDE=S|N;CARTERIZACION=0|1|NA;CLAVE=S|N;POLIZA=S|N`.
6. Esperado por perfil: propietario de clave → `CLAVE=S` y `APPIAN=TRUE` (si además `POLIZA=S`, `ESB=TRUE` y `COINCIDE=S`; si no, `COINCIDE=N`: es la diferencia AND/OR); carterizador → `CARTERIZACION=0` y `APPIAN=TRUE`, `ESB=FALSE` → `COINCIDE=N` (requiere la cabecera persistida por la sesión D); ajeno, SI24, CE_RM no propietarios → todo `N`/`FALSE`, `COINCIDE=S`.
7. Anotar cualquier `COINCIDE=N` con los datos crudos de la fila y la solicitud para la decisión AND vs OR.
