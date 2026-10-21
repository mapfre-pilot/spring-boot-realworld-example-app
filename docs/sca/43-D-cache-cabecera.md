# 43-D — Caché temporal de la cabecera de póliza/solicitud (SCA2, Appian TEST)

**Sesión D** de la fase 1 «lógica legacy en Appian» (diseño: `41-diseno-logica-appian-fase1.md` §4; reparto: `42-coordinacion-fase1.md` fila D).
Entorno: Appian TEST (`mapfrespain-test`), aplicación `SCA2 Sistema Comercial de Anulaciones SCA2` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`).

> Estado: **construido y probado en TEST** con el interruptor `cons!SCA2_USAR_CACHE_CABECERA = false` (comportamiento visible idéntico al anterior). Pendientes en §9.

## 1. Objetivo y resumen del diseño final

`SCA2_obtenerDatosCabecera(numPoliza, idSolicitud)` se invoca desde 9 interfaces y desde los PM `SCA2 CMD Alta`, `SCA2 CMD CrearAccion` y `SCA2 CMD Mecanizar`; cada invocación dispara ~15 llamadas externas (REST `cargaCabecera`, TRON/NSE/Vida, API Clients, Estruage, productor, reserva de prima, siniestros, otras solicitudes) y tarda 3,4–6,6 s. La pieza D reutiliza el resultado guardado en el record `SCA2 Datos Cabecera` (por `idSolicitud`) hasta las **07:00 del día siguiente** a la carga.

Decisiones del coordinador aplicadas:
1. Zona horaria: la del contexto de evaluación (§5).
2. Record: 7 campos nuevos aprobados + 2 añadidos para reproducir exactamente la búsqueda de otras solicitudes (`tipoPoliza`, `clienteCodint`) (§3).
3. `otrasSolicitudesCabecera` **siempre en vivo** (1 llamada a `SCA2_consultarSolicitudes`, misma búsqueda que la regla original). `tipoClienteValor` (Document) se guarda como id y se reconstruye con `todocument()`.
4. Filas duplicadas por `idSolicitud`: lectura con `validaHasta` no nulo y `> now()`, orden `fechaCache` desc, 1 fila. Escritura siempre sobre la fila propia (`origenCache = "CACHE"`: update si existe, insert si no); las filas de `SCA2 CMD Alta` no se tocan.
5. **Opción A de escritura** (propuesta por D ante la limitación de Appian, ver §4.3): la regla solo lee; la escritura la hacen contextos con `saveInto`/proceso.

Flujo del envoltorio:

```text
SCA2_obtenerDatosCabecera(numPoliza, idSolicitud, forzarRefresco?)
  usarCache := cons!SCA2_USAR_CACHE_CABECERA and numPoliza≠"" and idSolicitud∉{null,"0"} and not(forzarRefresco)
  fila := si usarCache: query SCA2 Datos Cabecera (fields explícitos) where idSolicitud = ri!idSolicitud
            and validaHasta not null and validaHasta > now()  order by fechaCache desc  limit 1
  si no hay fila → rule!SCA2_obtenerDatosCabeceraLive(numPoliza, idSolicitud)          (sin escritura)
  si hay fila   → SCAC_DS_datosCabecera reconstruido desde la fila
                  + otrasSolicitudesCabecera en vivo (SCA2_consultarSolicitudes con tipoPoliza/clienteCodint de la fila,
                    quitando la propia solicitud, igual que la regla original)
```

## 2. Objetos Appian (TEST)

| Objeto | Tipo | UUID | Versión antes → después | Cambio |
|---|---|---|---|---|
| `SCA2_obtenerDatosCabeceraLive` | Expression Rule | `_a-0000f093-2064-8000-9d36-011c48011c48_5603393` | nuevo, v1 | Copia exacta (carácter a carácter) de `SCA2_obtenerDatosCabecera` v2; inputs `numPoliza` Text, `idSolicitud` Text |
| `SCA2_USAR_CACHE_CABECERA` | Constante Boolean | `_a-0000f093-2064-8000-9d36-011c48011c48_5603399` | nuevo, v9 | Valor **false** (v2–v8 son los cambios true/false de las pruebas) |
| `SCA2_HORA_CADUCIDAD_CACHE_CABECERA` | Constante Integer | `_a-0000f093-2064-8000-9d36-011c48011c48_5603405` | nuevo, v1 | Valor 7 |
| `SCA2_calcularValidaHastaCache` | Expression Rule (pura) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603423` | nuevo, v1 | 10 casos `a!test`, 10/10 OK |
| `SCA2_obtenerDatosCabecera` | Expression Rule | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053304` | 2 → **5** | Envoltorio con caché; input nuevo `forzarRefresco` (Boolean, opcional). v3: primera versión; v4: acceso a campos con `fila[campo]`; v5: `fields` explícitos en la consulta |
| `SCA2 Datos Cabecera` | Record Type | `04f597de-5acd-45b2-9ab3-277713cd00a6` | 1 → **11** | 9 campos nuevos (tabla `sca2_datos_cabecera`, columnas creadas por Appian, sin DDL manual) |
| `SCA2_DetalleSolicitud` | Interface | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 59 → **60** | Enlace «Actualizar datos» (solo visible con el interruptor en true) |

Campos nuevos del record (todos con `updateTable = true`, columna creada por Appian):

| Campo | Tipo | Columna | UUID |
|---|---|---|---|
| `fechaCache` | DATETIME | `FECHA_CACHE` | `816f4439-7cf7-4f9f-8e30-aff3256daeec` |
| `validaHasta` | DATETIME | `VALIDA_HASTA` | `c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf` |
| `origenCache` | TEXT(255) | `ORIGEN_CACHE` | `81701765-3488-401d-9169-822a28ca8451` |
| `polizaRamo` | TEXT(255) | `POLIZA_RAMO` | `7b3b8ddd-702f-4c10-ab5e-4e04d124cbcd` |
| `polizaCesionderechos` | TEXT(255) | `POLIZA_CESIONDERECHOS` | `7d8b7301-8498-4950-9c2a-ced856d45674` |
| `polizaRevalorizacion` | TEXT(255) | `POLIZA_REVALORIZACION` | `a39a470b-6c4f-4685-b1ee-f9d1d591b757` |
| `contactoPais` | TEXT(255) | `CONTACTO_PAIS` | `93830b86-140f-46ab-9b27-5e653c755c4b` |
| `tipoPoliza` | TEXT(100) | `TIPO_POLIZA` | `6593228e-78fa-4648-ab2b-eea03a3d632a` |
| `clienteCodint` | TEXT(100) | `CLIENTE_CODINT` | `c082796f-ace6-4ef6-8a19-797c89e2dfc6` |

Nota: el nombre `polizaCesionderechos` sigue la convención del record (`polizaFechaultimosiniestro`, …) en lugar de `polizaCesionDerechos`. El primer alta de `polizaRamo` devolvió OK (v5) pero el campo no quedó en el record; se volvió a añadir (v9). `SCA2 CMD Alta` sigue escribiendo sus 9 campos sin cambios.

Nota operativa: el MCP `appian-dev-mcp-c90b` no arranca en esta sesión (el proceso no recibe `USERNAME/PASSWORD`); todo se ha hecho con la API LCP REST.

## 3. Cobertura de la salida frente al record

Salida: `SCAC_DS_datosCabecera` = `datosCliente` (14), `datosPoliza` (20), `otrasSolicitudesCabecera` (lista `mssConsultarSolicitudesDTO`), `datosContacto` (13).

| Elemento | Tratamiento |
|---|---|
| `datosCliente.*` 14/14, `datosContacto.*` 13/13, `datosPoliza.*` 19/20 | Desde el record (TEXT). `tipoClienteValor` (Document) → id en `clienteTipoclientevalor`, reconstruido con `todocument(tointeger())`; nulo si está vacío |
| `datosPoliza.sobrePrimas_SobreRiesgos` | La regla original **nunca lo asigna** → no se persiste; se devuelve nulo como hoy |
| `datosPoliza.ramo`, `cesionDeDerechos`, `revalorizacion`, `datosContacto.pais` | Campos nuevos (solo informados en Vida) |
| `otrasSolicitudesCabecera` | En vivo. La regla original busca con `tpBusqueda "0"` (Vida) o `"1"` + `codInt` del tomador (resto); para reproducirlo sin TRON/NSE se guardan `tipoPoliza` y `clienteCodint`. Verificado en TEST que ambas búsquedas devuelven la misma lista para las pólizas probadas |

## 4. SAIL

### 4.1 `SCA2_calcularValidaHastaCache(fechaHoraCarga: Date and Time, hora: Number (Integer)) → Date and Time`

```sail
=if(
  a!isNullOrEmpty(ri!fechaHoraCarga),
  null,
  a!localVariables(
    local!horaCaducidad: if(
      a!isNullOrEmpty(ri!hora),
      cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA,
      tointeger(ri!hora)
    ),
    local!diaSiguiente: todate(ri!fechaHoraCarga) + 1,
    datetime(
      year(local!diaSiguiente),
      month(local!diaSiguiente),
      day(local!diaSiguiente),
      local!horaCaducidad,
      0,
      0
    )
  )
)
```

### 4.2 `SCA2_obtenerDatosCabecera` v5 (envoltorio)

```sail
=a!localVariables(
  /* Envoltorio con caché temporal de la cabecera (doc 43-D). Con cons!SCA2_USAR_CACHE_CABECERA = false
     el comportamiento es idéntico al original: delega en rule!SCA2_obtenerDatosCabeceraLive. */
  local!usarCache: and(
    a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false),
    a!isNotNullOrEmpty(ri!numPoliza),
    a!isNotNullOrEmpty(ri!idSolicitud),
    tostring(ri!idSolicitud) <> "0",
    not(a!defaultValue(ri!forzarRefresco, false))
  ),
  local!filaCache: if(
    local!usarCache,
    a!queryRecordType(
      recordType: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera',
      fields: {
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{be8a5c3b-b866-4aa7-8424-e0b9fb585790}clienteNombre',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9bb6458d-2b8a-46e4-950d-f443a4d99ab1}clienteApellidos',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{3fc54e3e-02fe-4079-98fd-6a59db42dfaa}clienteApoderado',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0356c6be-be84-438f-9115-a5d5a5a76724}clienteNuumapropietario',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{19903d82-74a4-4b2d-9363-442e085400ca}clienteRsvprima',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab2f2789-e49e-4b66-97cd-a7ef5bfec730}clienteDtointegralidadnuevaproduccion',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{f463d88a-b415-43aa-914b-9c8227fb4074}clienteTreboles',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{843d65a8-ba29-4b41-a9a8-1207882c8fd8}clienteActivoclubmapfre',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1faa3be-6dcf-44e0-ad0e-a8592206aab6}clientePerfilclubmapfre',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{653b9880-b834-460b-b109-03c0aa5d7f3f}clienteTipoclientevalor',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{bee4cebe-cf9d-415a-a1eb-ae8d17740f14}clienteTipoclientedesc',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{965531d7-d779-4a3a-ae0e-49f63e4cfe10}clienteIdcliente',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b4fbe9d5-5949-4693-9c2f-8acce0349ff5}polizaNumeropoliza',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{488a1def-2853-4526-85b9-e28cb686a8db}polizaNombreproducto',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4bb6981c-24f2-40d0-8852-06b0c9a064a6}polizaVehiculo',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{1c5f745d-37aa-49cb-8600-56a8e0fe9165}polizaLineanegocio',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{8dcfa2e7-3e34-4026-a59a-bcebb29be5c8}polizaFormapago',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{df03488b-3af6-400b-8083-a632f4c9c482}polizaFechaefecto',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e46d7b58-2fab-4fac-aa5d-0282c8ae58d7}polizaFechavencimiento',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6315089c-564a-471b-8835-a40ebdd10188}polizaAntiguedad',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab8c7579-6fc8-4a2e-bc13-2bf7da8123d5}polizaPlanpago',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1749b80-0132-47ac-9931-be0ee9c75d43}polizaPrimaactualrenovacion',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{48fcf401-d54c-45c6-805d-c1f5c9118187}polizaAcuerdo',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{349b1814-7050-4155-8ea1-87d2d9368eec}polizaClaveproduccion',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{65918aea-f30b-471b-a914-814c7317f0d9}polizaTipoproductor',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{882be471-06fe-4411-960a-f71371b7383f}polizaSiniestrosanoactual',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b76b461d-80a8-4f10-8c8a-ae915cd43760}polizaFechaultimosiniestro',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{261fa0dc-e00c-4805-b248-88955c5012bb}polizaDtointegralidadpoliza',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7b3b8ddd-702f-4c10-ab5e-4e04d124cbcd}polizaRamo',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7d8b7301-8498-4950-9c2a-ced856d45674}polizaCesionderechos',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a39a470b-6c4f-4685-b1ee-f9d1d591b757}polizaRevalorizacion',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcec67d4-c615-4990-9165-10bf5c0a4e30}contactoVia',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d579fd3f-6ba9-4759-8153-e6bb43d4f752}contactoDomicilio',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{79c6a806-89a5-4a14-8f4b-f51da6465263}contactoNumero',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{5e833491-162a-4fa3-811e-9106f72efc74}contactoProvincia',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcf9ec55-848a-4035-b468-3bfeb93adb7b}contactoLocalidad',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e9da29b2-2b7b-4570-baf4-3de4b9d8f9a0}contactoCodpostal',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{627820e0-fc57-4997-9e38-2e16fd1c8eca}contactoTelmovil',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9f8584e7-619b-489a-86ed-463e4e9830ab}contactoTelfijo',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4a1a4e27-0e23-47ae-ba19-35da1c61d478}contactoCorreo',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0e80fa4a-e936-4bab-997b-544a39e339a0}contactoPiso',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{baa3d3bc-79c0-49dc-b111-eacd1453e524}contactoPuerta',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d2f90a66-bd08-4610-a60a-988cae4049a4}contactoEscalera',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{93830b86-140f-46ab-9b27-5e653c755c4b}contactoPais',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6593228e-78fa-4648-ab2b-eea03a3d632a}tipoPoliza',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c082796f-ace6-4ef6-8a19-797c89e2dfc6}clienteCodint',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta',
        'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache'
      },
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', operator: "=", value: tostring(ri!idSolicitud)),
          a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta', operator: "not null"),
          a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta', operator: ">", value: now())
        }
      ),
      pagingInfo: a!pagingInfo(
        startIndex: 1,
        batchSize: 1,
        sort: a!sortInfo(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache', ascending: false)
      ),
      fetchTotalCount: false
    ).data,
    {}
  ),
  if(
    a!isNullOrEmpty(local!filaCache),
    rule!SCA2_obtenerDatosCabeceraLive(numPoliza: ri!numPoliza, idSolicitud: ri!idSolicitud),
    a!localVariables(
      local!fila: index(local!filaCache, 1, null),
      /* Otras solicitudes: siempre en vivo (1 llamada), misma búsqueda que la regla original */
      local!otrasSolicitudes: if(
        local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6593228e-78fa-4648-ab2b-eea03a3d632a}tipoPoliza'] = cons!SCA2_TXT_VIDA_RIESGO,
        index(rule!SCA2_consultarSolicitudes(numPoliza: ri!numPoliza, codInt: "", tpBusqueda: "0"), "MSSConsultarSolicitudes", null),
        index(rule!SCA2_consultarSolicitudes(numPoliza: ri!numPoliza, codInt: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c082796f-ace6-4ef6-8a19-797c89e2dfc6}clienteCodint'], tpBusqueda: "1"), "MSSConsultarSolicitudes", null)
      ),
      local!idSolic: index(wherecontains(ri!idSolicitud, index(local!otrasSolicitudes, "idSolicitud", null)), 1, null),
      'type!{urn:com:appian:types:SCAC}SCAC_DS_datosCabecera'(
        datosCliente: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosCliente'(
          nombre: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{be8a5c3b-b866-4aa7-8424-e0b9fb585790}clienteNombre'],
          apellidos: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9bb6458d-2b8a-46e4-950d-f443a4d99ab1}clienteApellidos'],
          nif: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif'],
          apoderado: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{3fc54e3e-02fe-4079-98fd-6a59db42dfaa}clienteApoderado'],
          carterizado: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado'],
          nuumaPropietario: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0356c6be-be84-438f-9115-a5d5a5a76724}clienteNuumapropietario'],
          rsvPrima: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{19903d82-74a4-4b2d-9363-442e085400ca}clienteRsvprima'],
          dtoIntegralidadNuevaProduccion: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab2f2789-e49e-4b66-97cd-a7ef5bfec730}clienteDtointegralidadnuevaproduccion'],
          treboles: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{f463d88a-b415-43aa-914b-9c8227fb4074}clienteTreboles'],
          activoClubMapfre: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{843d65a8-ba29-4b41-a9a8-1207882c8fd8}clienteActivoclubmapfre'],
          perfilClubMapfre: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1faa3be-6dcf-44e0-ad0e-a8592206aab6}clientePerfilclubmapfre'],
          tipoClienteValor: if(a!isNullOrEmpty(local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{653b9880-b834-460b-b109-03c0aa5d7f3f}clienteTipoclientevalor']), null, todocument(tointeger(local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{653b9880-b834-460b-b109-03c0aa5d7f3f}clienteTipoclientevalor']))),
          tipoClienteDesc: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{bee4cebe-cf9d-415a-a1eb-ae8d17740f14}clienteTipoclientedesc'],
          idCliente: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{965531d7-d779-4a3a-ae0e-49f63e4cfe10}clienteIdcliente']
        ),
        datosPoliza: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosPoliza'(
          numeroPoliza: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b4fbe9d5-5949-4693-9c2f-8acce0349ff5}polizaNumeropoliza'],
          nombreProducto: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{488a1def-2853-4526-85b9-e28cb686a8db}polizaNombreproducto'],
          vehiculo: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4bb6981c-24f2-40d0-8852-06b0c9a064a6}polizaVehiculo'],
          lineaNegocio: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{1c5f745d-37aa-49cb-8600-56a8e0fe9165}polizaLineanegocio'],
          formaPago: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{8dcfa2e7-3e34-4026-a59a-bcebb29be5c8}polizaFormapago'],
          fechaEfecto: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{df03488b-3af6-400b-8083-a632f4c9c482}polizaFechaefecto'],
          fechaVencimiento: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e46d7b58-2fab-4fac-aa5d-0282c8ae58d7}polizaFechavencimiento'],
          antiguedad: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6315089c-564a-471b-8835-a40ebdd10188}polizaAntiguedad'],
          planPago: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab8c7579-6fc8-4a2e-bc13-2bf7da8123d5}polizaPlanpago'],
          primaActualRenovacion: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1749b80-0132-47ac-9931-be0ee9c75d43}polizaPrimaactualrenovacion'],
          acuerdo: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{48fcf401-d54c-45c6-805d-c1f5c9118187}polizaAcuerdo'],
          claveProduccion: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{349b1814-7050-4155-8ea1-87d2d9368eec}polizaClaveproduccion'],
          tipoProductor: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{65918aea-f30b-471b-a914-814c7317f0d9}polizaTipoproductor'],
          siniestrosAnoActual: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{882be471-06fe-4411-960a-f71371b7383f}polizaSiniestrosanoactual'],
          fechaUltimoSiniestro: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b76b461d-80a8-4f10-8c8a-ae915cd43760}polizaFechaultimosiniestro'],
          dtoIntegralidadPoliza: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{261fa0dc-e00c-4805-b248-88955c5012bb}polizaDtointegralidadpoliza'],
          ramo: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7b3b8ddd-702f-4c10-ab5e-4e04d124cbcd}polizaRamo'],
          cesionDeDerechos: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7d8b7301-8498-4950-9c2a-ced856d45674}polizaCesionderechos'],
          revalorizacion: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a39a470b-6c4f-4685-b1ee-f9d1d591b757}polizaRevalorizacion']
        ),
        otrasSolicitudesCabecera: if(
          a!isNullOrEmpty(local!otrasSolicitudes),
          local!otrasSolicitudes,
          if(
            a!isNotNullOrEmpty(local!idSolic),
            remove(local!otrasSolicitudes, local!idSolic),
            local!otrasSolicitudes
          )
        ),
        datosContacto: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosContacto'(
          via: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcec67d4-c615-4990-9165-10bf5c0a4e30}contactoVia'],
          domicilio: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d579fd3f-6ba9-4759-8153-e6bb43d4f752}contactoDomicilio'],
          numero: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{79c6a806-89a5-4a14-8f4b-f51da6465263}contactoNumero'],
          provincia: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{5e833491-162a-4fa3-811e-9106f72efc74}contactoProvincia'],
          localidad: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcf9ec55-848a-4035-b468-3bfeb93adb7b}contactoLocalidad'],
          codPostal: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e9da29b2-2b7b-4570-baf4-3de4b9d8f9a0}contactoCodpostal'],
          telMovil: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{627820e0-fc57-4997-9e38-2e16fd1c8eca}contactoTelmovil'],
          telFijo: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9f8584e7-619b-489a-86ed-463e4e9830ab}contactoTelfijo'],
          correo: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4a1a4e27-0e23-47ae-ba19-35da1c61d478}contactoCorreo'],
          piso: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0e80fa4a-e936-4bab-997b-544a39e339a0}contactoPiso'],
          puerta: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{baa3d3bc-79c0-49dc-b111-eacd1453e524}contactoPuerta'],
          escalera: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d2f90a66-bd08-4610-a60a-988cae4049a4}contactoEscalera'],
          pais: local!fila['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{93830b86-140f-46ab-9b27-5e653c755c4b}contactoPais']
        )
      )
    )
  )
)
```

### 4.3 Escritura de la caché: por qué no está dentro de la regla

`a!writeRecords()` (y `a!startProcess()`) son funciones de smart service: Appian solo permite ejecutarlas en un `saveInto`, en una Web API o en un nodo de proceso. Las 9 interfaces invocan `rule!SCA2_obtenerDatosCabecera` al cargar (`a!refreshVariable`/`local!`), por lo que el «upsert en el miss» del doc 41 §4 no puede vivir dentro de la regla. Opciones valoradas: **A** (regla solo lee; escriben los puntos con contexto de guardado) — implementada; B (Web API + connected system + integración «de consulta» llamada desde la regla) — descartada por requerir objetos fuera de la fila D, credenciales y ~0,3 s por miss; C (procedimiento almacenado vía `a!executeStoredProcedureForQuery`) — descartada por requerir DDL fuera de Appian.

Puntos de escritura:
1. **`SCA2_DetalleSolicitud` → «Actualizar datos»** (hecho, §4.4): llama al envoltorio con `forzarRefresco: true`, actualiza `local!estructuraCabecera` y hace `a!writeRecords` sobre la fila `CACHE` (update por `id` si existe, insert si no).
2. **`SCA2 CMD Alta` (sesión A, propuesta)**: ya llama a la regla (`cabh` → `pv!cab`) y ya escribe `SCA2 Datos Cabecera` con 9 campos. Propuesta: en ese Write Records escribir los 53 campos con el mapeo de §4.4 (`fechaCache = now()`, `validaHasta = rule!SCA2_calcularValidaHastaCache(now(), cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA)`, `origenCache = "CACHE"`, `tipoPoliza = rule!SCA2_obtenerTipoPoliza(pv!numPoliza)`, `clienteCodint` desde `SCA2 Datos Poliza Autos/Hogar.tomadorCodint`). Con ello la caché queda vigente desde el alta hasta las 07:00 del día siguiente para todas las interfaces, sin cambios en ellas.

Hasta que se haga (2), con el interruptor en true la caché solo existe para las solicitudes en las que alguien pulse «Actualizar datos».

### 4.4 Bloque añadido a `SCA2_DetalleSolicitud` v60 (dentro del `a!sideBySideLayout` de «Más Datos», líneas 322–427)

```sail
/* [43-D] Caché de cabecera: recarga en vivo y actualiza la fila CACHE de SCA2 Datos Cabecera */
a!sideBySideItem(
  item: a!richTextDisplayField(
    labelPosition: "COLLAPSED",
    value: {
      a!richTextIcon(icon: "refresh", color: "#000000"),
      char(32),
      a!richTextItem(
        text: "Actualizar datos",
        link: a!dynamicLink(
          saveInto: a!localVariables(
            local!cabeceraLive: rule!SCA2_obtenerDatosCabecera(numPoliza: local!numPoliza, idSolicitud: ri!idSolicitud, forzarRefresco: true),
            local!tipoPolizaCache: rule!SCA2_obtenerTipoPoliza(numPoliza: local!numPoliza),
            local!codIntCache: if(
              local!tipoPolizaCache = cons!SCA2_TXT_VIDA_RIESGO,
              null,
              if(
                local!tipoPolizaCache = cons!SCA2_TXT_NSE_HOGAR,
                index(a!queryRecordType(recordType: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar', fields: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{55694c99-358f-4672-9708-eaee3cbfc652}tomadorCodint', filters: a!queryFilter(field: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{12da2701-7d53-4cc8-aa00-58a1afd6e43b}idSolicitud', operator: "=", value: tostring(ri!idSolicitud)), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{54110158-060d-41d5-a35d-41c45efd2e2b}id', ascending: false)), fetchTotalCount: false).data, 1, null)['recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{55694c99-358f-4672-9708-eaee3cbfc652}tomadorCodint'],
                index(a!queryRecordType(recordType: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos', fields: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{e988271d-9f4e-4055-81d5-76e8bd78293e}tomadorCodint', filters: a!queryFilter(field: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{a10e3b1f-5518-4f08-b1bc-9229040e3250}idSolicitud', operator: "=", value: tostring(ri!idSolicitud)), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{1858d98c-ef9c-419b-8498-ae27752a50d8}id', ascending: false)), fetchTotalCount: false).data, 1, null)['recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{e988271d-9f4e-4055-81d5-76e8bd78293e}tomadorCodint']
              )
            ),
            local!ahoraCache: now(),
            local!idSolicitudCache: ri!idSolicitud,
            local!filaPrevia: a!queryRecordType(
              recordType: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera',
              fields: {'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id', 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache'},
              filters: a!queryLogicalExpression(
                operator: "AND",
                filters: {
                  a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', operator: "=", value: tostring(ri!idSolicitud)),
                  a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache', operator: "=", value: "CACHE")
                }
              ),
              pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache', ascending: false)),
              fetchTotalCount: false
            ).data,
            local!idFilaCache: if(a!isNullOrEmpty(local!filaPrevia), null, index(local!filaPrevia, 1, null)['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id']),
            {
              a!save(local!estructuraCabecera, local!cabeceraLive),
              if(
                a!isNullOrEmpty(local!cabeceraLive),
                {},
                a!writeRecords(records: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera'(
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id': local!idFilaCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud': tostring(local!idSolicitudCache),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{be8a5c3b-b866-4aa7-8424-e0b9fb585790}clienteNombre': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "nombre", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "nombre", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9bb6458d-2b8a-46e4-950d-f443a4d99ab1}clienteApellidos': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "apellidos", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "apellidos", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "nif", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "nif", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{3fc54e3e-02fe-4079-98fd-6a59db42dfaa}clienteApoderado': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "apoderado", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "apoderado", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "carterizado", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "carterizado", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0356c6be-be84-438f-9115-a5d5a5a76724}clienteNuumapropietario': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "nuumaPropietario", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "nuumaPropietario", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{19903d82-74a4-4b2d-9363-442e085400ca}clienteRsvprima': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "rsvPrima", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "rsvPrima", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab2f2789-e49e-4b66-97cd-a7ef5bfec730}clienteDtointegralidadnuevaproduccion': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "dtoIntegralidadNuevaProduccion", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "dtoIntegralidadNuevaProduccion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{f463d88a-b415-43aa-914b-9c8227fb4074}clienteTreboles': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "treboles", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "treboles", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{843d65a8-ba29-4b41-a9a8-1207882c8fd8}clienteActivoclubmapfre': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "activoClubMapfre", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "activoClubMapfre", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1faa3be-6dcf-44e0-ad0e-a8592206aab6}clientePerfilclubmapfre': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "perfilClubMapfre", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "perfilClubMapfre", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{653b9880-b834-460b-b109-03c0aa5d7f3f}clienteTipoclientevalor': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "tipoClienteValor", null)), null, tostring(tointeger(index(local!cabeceraLive, "datosCliente", "tipoClienteValor", null)))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{bee4cebe-cf9d-415a-a1eb-ae8d17740f14}clienteTipoclientedesc': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "tipoClienteDesc", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "tipoClienteDesc", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{965531d7-d779-4a3a-ae0e-49f63e4cfe10}clienteIdcliente': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosCliente", "idCliente", null)), null, tostring(index(local!cabeceraLive, "datosCliente", "idCliente", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b4fbe9d5-5949-4693-9c2f-8acce0349ff5}polizaNumeropoliza': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "numeroPoliza", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "numeroPoliza", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{488a1def-2853-4526-85b9-e28cb686a8db}polizaNombreproducto': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "nombreProducto", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "nombreProducto", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4bb6981c-24f2-40d0-8852-06b0c9a064a6}polizaVehiculo': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "vehiculo", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "vehiculo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{1c5f745d-37aa-49cb-8600-56a8e0fe9165}polizaLineanegocio': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "lineaNegocio", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "lineaNegocio", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{8dcfa2e7-3e34-4026-a59a-bcebb29be5c8}polizaFormapago': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "formaPago", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "formaPago", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{df03488b-3af6-400b-8083-a632f4c9c482}polizaFechaefecto': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "fechaEfecto", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "fechaEfecto", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e46d7b58-2fab-4fac-aa5d-0282c8ae58d7}polizaFechavencimiento': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "fechaVencimiento", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "fechaVencimiento", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6315089c-564a-471b-8835-a40ebdd10188}polizaAntiguedad': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "antiguedad", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "antiguedad", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab8c7579-6fc8-4a2e-bc13-2bf7da8123d5}polizaPlanpago': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "planPago", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "planPago", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1749b80-0132-47ac-9931-be0ee9c75d43}polizaPrimaactualrenovacion': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "primaActualRenovacion", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "primaActualRenovacion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{48fcf401-d54c-45c6-805d-c1f5c9118187}polizaAcuerdo': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "acuerdo", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "acuerdo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{349b1814-7050-4155-8ea1-87d2d9368eec}polizaClaveproduccion': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "claveProduccion", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "claveProduccion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{65918aea-f30b-471b-a914-814c7317f0d9}polizaTipoproductor': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "tipoProductor", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "tipoProductor", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{882be471-06fe-4411-960a-f71371b7383f}polizaSiniestrosanoactual': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "siniestrosAnoActual", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "siniestrosAnoActual", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b76b461d-80a8-4f10-8c8a-ae915cd43760}polizaFechaultimosiniestro': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "fechaUltimoSiniestro", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "fechaUltimoSiniestro", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{261fa0dc-e00c-4805-b248-88955c5012bb}polizaDtointegralidadpoliza': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "dtoIntegralidadPoliza", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "dtoIntegralidadPoliza", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7b3b8ddd-702f-4c10-ab5e-4e04d124cbcd}polizaRamo': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "ramo", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "ramo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7d8b7301-8498-4950-9c2a-ced856d45674}polizaCesionderechos': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "cesionDeDerechos", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "cesionDeDerechos", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a39a470b-6c4f-4685-b1ee-f9d1d591b757}polizaRevalorizacion': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosPoliza", "revalorizacion", null)), null, tostring(index(local!cabeceraLive, "datosPoliza", "revalorizacion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcec67d4-c615-4990-9165-10bf5c0a4e30}contactoVia': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "via", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "via", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d579fd3f-6ba9-4759-8153-e6bb43d4f752}contactoDomicilio': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "domicilio", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "domicilio", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{79c6a806-89a5-4a14-8f4b-f51da6465263}contactoNumero': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "numero", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "numero", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{5e833491-162a-4fa3-811e-9106f72efc74}contactoProvincia': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "provincia", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "provincia", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcf9ec55-848a-4035-b468-3bfeb93adb7b}contactoLocalidad': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "localidad", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "localidad", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e9da29b2-2b7b-4570-baf4-3de4b9d8f9a0}contactoCodpostal': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "codPostal", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "codPostal", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{627820e0-fc57-4997-9e38-2e16fd1c8eca}contactoTelmovil': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "telMovil", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "telMovil", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9f8584e7-619b-489a-86ed-463e4e9830ab}contactoTelfijo': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "telFijo", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "telFijo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4a1a4e27-0e23-47ae-ba19-35da1c61d478}contactoCorreo': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "correo", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "correo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0e80fa4a-e936-4bab-997b-544a39e339a0}contactoPiso': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "piso", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "piso", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{baa3d3bc-79c0-49dc-b111-eacd1453e524}contactoPuerta': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "puerta", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "puerta", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d2f90a66-bd08-4610-a60a-988cae4049a4}contactoEscalera': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "escalera", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "escalera", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{93830b86-140f-46ab-9b27-5e653c755c4b}contactoPais': if(a!isNullOrEmpty(index(local!cabeceraLive, "datosContacto", "pais", null)), null, tostring(index(local!cabeceraLive, "datosContacto", "pais", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6593228e-78fa-4648-ab2b-eea03a3d632a}tipoPoliza': local!tipoPolizaCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c082796f-ace6-4ef6-8a19-797c89e2dfc6}clienteCodint': local!codIntCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache': local!ahoraCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta': rule!SCA2_calcularValidaHastaCache(fechaHoraCarga: local!ahoraCache, hora: cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache': "CACHE"
    ))
              )
            }
          )
        ),
        linkStyle: "STANDALONE", color: "#000000", size: "STANDARD", style: "STRONG")
    },
    align: "RIGHT", marginAbove: "NONE", marginBelow: "NONE"),
  showWhen: a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false)
),
```

## 5. Zona horaria (UTC vs CET)

- Un `Date and Time` es un instante absoluto; la BD guarda GMT; la comparación `validaHasta > now()` es correcta en cualquier zona.
- `datetime()`, `todate()`, `hour()` usan la **zona del contexto**: la del usuario en interfaces, la del proceso/usuario de servicio en PM y API.
- Comprobación empírica: `fechaHoraCarga = now()`, `hora = hour(now())` a las 10:16 UTC devolvió `2026-10-22 10:00:00` ⇒ el usuario de servicio de la API está en UTC.
- Consecuencia (aceptada por el coordinador): una carga desde interfaz por un usuario `Europe/Madrid` caduca a las **07:00 Madrid**; una carga desde PM (usuario de servicio en UTC, p. ej. `SCA2 CMD Alta` cuando se aplique la propuesta) caduca a las **07:00 UTC = 08:00 Madrid en invierno / 09:00 en verano**. Es aceptable.
- Las filas de prueba insertadas por API con `validaHasta = 2026-10-22 07:00:00` se leyeron tal cual desde la API (`/data`), coherente con almacenamiento GMT.

## 6. Pruebas

Formato: `ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución`. Datos reservados en `pruebas/coordinacion-fase1.md` (solo lectura, sin instancias nuevas). No existen pólizas Vida ni Verti en TEST (`origenPoliza` ∈ {NSE-Autos, wAutemis, NSE-Hogar}), por lo que la comparación se hizo sobre esos tres tipos.

### 6.1 `SCA2_calcularValidaHastaCache` (`a!test`, 2026-10-21)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T01 | Carga 2026-10-21 10:30, hora 7 | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK | — | — | Caso de prueba de la regla | — |
| T02 | Carga 03:15 (antes de las 07:00) | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK | — | — | ídem | — |
| T03 | Carga 23:59:59 | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK | — | — | ídem | — |
| T04 | Carga 2026-10-22 00:00:00 | 2026-10-23 07:00:00 | 2026-10-23 07:00:00 | OK | — | — | ídem | — |
| T05 | Cambio de mes (31/10 12:00) | 2026-11-01 07:00:00 | 2026-11-01 07:00:00 | OK | — | — | ídem | — |
| T06 | Cambio de año (31/12 22:00) | 2027-01-01 07:00:00 | 2027-01-01 07:00:00 | OK | — | — | ídem | — |
| T07 | Cambio horario verano→invierno (24/10 20:00) | 2026-10-25 07:00:00 | 2026-10-25 07:00:00 | OK | — | — | ídem | — |
| T08 | hora 0 | 2026-10-22 00:00:00 | 2026-10-22 00:00:00 | OK | — | — | ídem | — |
| T09 | hora nula → constante | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK | — | — | ídem | — |
| T10 | fecha nula | null | null | OK | — | — | ídem | — |

### 6.2 Regresión del envoltorio con el interruptor en **false** (`POST /expression-rules/{uuid}/test`)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| R01 | NSE-Autos 2002000024445, v2 (antes) vs v5 (después) | salida idéntica | 0 diferencias en 47 campos + otras solicitudes; 6,6 s → 5,6 s | OK | 15787499 | — | Salida de v2 guardada; misma llamada tras guardar v3/v5; comparación campo a campo (`""`≡null) | — |
| R02 | wAutemis 0000006610576 | idéntica | 0 diferencias; 6,3 s → 4,2 s | OK | 15787668 | — | ídem | — |
| R03 | NSE-Hogar 0732000028208 | idéntica | 0 diferencias (incl. 1 otra solicitud 15788007); 4,6 s → 3,7 s | OK | 15788005 | — | ídem | — |

### 6.3 Camino de caché (interruptor en **true** solo durante la prueba; filas `CACHE` insertadas por API a partir de la salida Live y borradas al terminar)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| C01 | Caché vigente NSE-Autos vs Live | idéntica | 0 diferencias; **0,94 s** (Live 5,6–6,6 s) | OK | 15787499 | — | Fila CACHE `validaHasta` 2026-10-22 07:00; interruptor true; `/test` | — |
| C02 | Caché vigente wAutemis vs Live | idéntica | 0 diferencias; **0,92 s** | OK | 15787668 | — | ídem | — |
| C03 | Caché vigente NSE-Hogar vs Live (con otra solicitud) | idéntica, lista de otras solicitudes igual | 0 diferencias; **0,91 s** | OK | 15788005 | — | ídem | — |
| FR1 | `forzarRefresco = true` con caché vigente | salida Live | igual que Live; 3,65 s | OK | 15788005 | — | `/test` con `forzarRefresco: true` | — |
| CAD1 | `validaHasta` pasado (hace 1 h) | recarga en vivo | igual que Live; 3,47 s | OK | 15788005 | — | `PUT /data` sobre la fila; `/test` | — |
| ID0 | `idSolicitud = "0"` con interruptor true | siempre en vivo | salida Live; 3,88 s | OK | 0 | — | `/test` | — |
| LEE1 | Campo alterado en la fila CACHE (`clienteTreboles = PRUEBA-CACHE`) | la salida refleja el record | `treboles = PRUEBA-CACHE`; 0,96 s | OK | 15787499 | — | Demuestra que lee del record y no de servicios | — |
| OFF1 | Interruptor false con fila CACHE presente | en vivo | `treboles = 0,00`; 3,54 s | OK | 15787499 | — | Constante a false; `/test` | — |
| UI1 | Render de `SCA2_DetalleSolicitud` (`/interfaces/{uuid}/test`) con interruptor false | sin error, sin enlace | sin error; enlace no visible; 3,7–4,2 s | OK | 15787499 / 15787668 / 15788005 | — | 3 renders | — |
| UI2 | Render con interruptor true y fila CACHE | sin error, enlace visible, más rápido | sin error; «Actualizar datos» visible; **1,3–1,7 s** | OK | 15787499 / 15787668 / 15788005 | — | 3 renders | — |

Pruebas intermedias que fallaron y se corrigieron: (1) v3 reconstruía con `index(fila, campo, null)` → todos los campos nulos; (2) v4 con `fila[campo]` seguía nulo porque `a!queryRecordType` **sin `fields`** devolvía filas sin datos en este contexto → v5 declara `fields` explícitos (y lo mismo en las consultas de la interfaz).

Limpieza: las filas CACHE de prueba (ids 207–209, 211–213, 217–219) se borraron; la constante quedó en false (v9); `SCA2_calcularValidaHastaCache` conserva solo sus 10 casos.

### 6.4 Tiempos (resumen)

| Medida | Antes (vivo) | Con caché vigente |
|---|---|---|
| `SCA2_obtenerDatosCabecera` (API `/test`) | 3,4 – 6,6 s | 0,9 s (incluye la llamada en vivo a otras solicitudes) |
| Render de `SCA2_DetalleSolicitud` (API `/interfaces/test`) | 3,7 – 4,2 s | 1,3 – 1,7 s |
| Alta (`SCA2_AltaSolicitudPage`) | no medido: con `idSolicitud` nulo/0 el alta va siempre en vivo (sin cambio) | — |

## 7. Lo que sigue siempre en vivo

- `SCA2_obtenerEstadoPoliza` y `SCA2_consultarAnulacionPoliza` no se invocan dentro de `SCA2_obtenerDatosCabecera` (0 apariciones en la expresión): no quedan cacheadas.
- `otrasSolicitudesCabecera` se consulta en vivo también con caché vigente.
- Alta sin solicitud (`idSolicitud` nulo/0) y `forzarRefresco = true`: en vivo.

## 8. Invalidación: propuesta (sin tocar objetos ajenos)

CMD que cambian el estado de la solicitud/póliza y donde propongo poner `validaHasta = now()` en la fila `origenCache = "CACHE"` de la solicitud (un nodo Write Records con `id` de la fila y `validaHasta`; si no hay fila, no hacer nada):

| PM | UUID | Momento propuesto |
|---|---|---|
| `SCA2 CMD Mecanizar` | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | Tras la mecanización en CORE (cambia estado de póliza; además ya llama a la regla, puede refrescar la fila en vez de invalidar) |
| `SCA2 CMD Finalizar` | `0000f06f-1309-8000-65b3-7f0000014e7a` | Al finalizar la solicitud |
| `SCA2 CMD Caducar` / `SCA2 CMD BarridoCaducidad` | `0000f06f-4f07-8000-670d-7f0000014e7a` / `0000f06f-4f69-8000-671e-7f0000014e7a` | Al caducar |
| `SCA2 CMD CompletarAccion` | `0000f06f-1307-8000-65b1-7f0000014e7a` | Al completar acciones que anulan/contra-anulan |
| `SCA2 CMD Decidir` | `0000f06f-0eab-8000-6595-7f0000014e7a` | Cuando la decisión cambia el estado |
| `SCA2 CMD CrearAccion` | `0000f06f-0eaa-8000-6594-7f0000014e7a` | Ya llama a la regla: puede refrescar la fila (mismo mapeo que §4.3-2) |

No requieren invalidar (no cambian datos de cabecera): `CambiarNivel`, `Posponer`, `GenerarPdf`, `ObtenerDocumentoGD`, `MarcarErrorRelanzado`.

## 9. Pendientes y decisiones

- **Prueba del clic «Actualizar datos» en la UI** (escritura real del record desde `saveInto`): requiere navegador con sesión en TEST y el interruptor en true unos minutos. Pendiente de autorización.
- **`SCA2 CMD Alta` (sesión A)**: aplicar la propuesta §4.3-2 para que la caché se cree en el alta; sin ello el beneficio con el interruptor en true depende del enlace manual.
- **Invalidación en CMD** (§8): asignar por el coordinador.
- **Limpieza futura**: `idSolicitud` no es única en `SCA2 Datos Cabecera` (`SCA2 CMD Alta` inserta su propia fila parcial; las 206 filas previas carecen de `validaHasta`). No se ha actuado.
- Vida/Verti: sin datos en TEST; cuando existan, repetir C01–C03 (campos `polizaRamo`, `polizaCesionderechos`, `polizaRevalorizacion`, `contactoPais`).
- Activación: poner `SCA2_USAR_CACHE_CABECERA = true` cuando el coordinador lo decida (reversible en cualquier momento volviendo a false).
