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
| `SCA2_USAR_CACHE_CABECERA` | Constante Boolean | `_a-0000f093-2064-8000-9d36-011c48011c48_5603399` | nuevo, **v11** | Valor **false** (v2–v10 son los cambios true/false durante las pruebas) |
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
2. **`SCA2 CMD Alta` (sesión A, aceptado por el coordinador)**: ya llama a la regla (`cabh` → `pv!cab`) y ya escribe `SCA2 Datos Cabecera` con 9 campos. Añadir un nodo Write Records **nuevo** «Guardar caché cabecera» (sin tocar el existente) con la expresión exacta de §4.5, que con el interruptor en false devuelve `{}` y no escribe nada. Con ello la caché queda vigente desde el alta hasta las 07:00 del día siguiente para todas las interfaces, sin cambios en ellas.
3. **Renovación al caducar**: PM programado `SCA2 CMD RefrescarCacheCabecera` (especificación en §10; no creado).

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

### 4.5 Expresión lista para pegar en el Write Records de `SCA2 CMD Alta` (sesión A)

Nodo Write Records nuevo «Guardar caché cabecera», a continuación del Write Records actual de `SCA2 Datos Cabecera` (para que `SCA2 Datos Poliza Autos/Hogar` ya estén escritos). Input `Records` = la expresión siguiente; con `cons!SCA2_USAR_CACHE_CABECERA = false` devuelve `{}` (sin fila; si el smart service no admite lista vacía, poner la misma condición en un gateway XOR delante del nodo). `pv!cab` es la salida de `rule!SCA2_obtenerDatosCabecera` (`cabh`), `pv!idSolicitud` y `pv!numPoliza` las pv existentes. Se inserta siempre una fila nueva (`id` nulo): en el alta no existe fila `CACHE` previa.

```sail
=if(
  not(a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false)),
  {},
  a!localVariables(
    local!ahoraCache: now(),
    /* Si el PM ya tiene el tipo de póliza en una pv, usarla en lugar de volver a llamar a la regla */
    local!tipoPolizaCache: rule!SCA2_obtenerTipoPoliza(numPoliza: pv!numPoliza),
    /* codInt del tomador: SCA2 Datos Poliza Hogar / Autos (deben estar ya escritos para pv!idSolicitud) */
    local!codIntCache: if(
      local!tipoPolizaCache = cons!SCA2_TXT_VIDA_RIESGO,
      null,
      if(
        local!tipoPolizaCache = cons!SCA2_TXT_NSE_HOGAR,
        index(a!queryRecordType(recordType: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar', fields: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{55694c99-358f-4672-9708-eaee3cbfc652}tomadorCodint', filters: a!queryFilter(field: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{12da2701-7d53-4cc8-aa00-58a1afd6e43b}idSolicitud', operator: "=", value: tostring(pv!idSolicitud)), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{54110158-060d-41d5-a35d-41c45efd2e2b}id', ascending: false)), fetchTotalCount: false).data, 1, null)['recordType!{55afc46c-c433-4351-94ab-1a464ffa7146}SCA2 Datos Poliza Hogar.fields.{55694c99-358f-4672-9708-eaee3cbfc652}tomadorCodint'],
        index(a!queryRecordType(recordType: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos', fields: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{e988271d-9f4e-4055-81d5-76e8bd78293e}tomadorCodint', filters: a!queryFilter(field: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{a10e3b1f-5518-4f08-b1bc-9229040e3250}idSolicitud', operator: "=", value: tostring(pv!idSolicitud)), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{1858d98c-ef9c-419b-8498-ae27752a50d8}id', ascending: false)), fetchTotalCount: false).data, 1, null)['recordType!{eda2fe07-8058-472e-a245-ba87b85663ac}SCA2 Datos Poliza Autos.fields.{e988271d-9f4e-4055-81d5-76e8bd78293e}tomadorCodint']
      )
    ),
    'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera'(
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id': null,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud': tostring(pv!idSolicitud),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{be8a5c3b-b866-4aa7-8424-e0b9fb585790}clienteNombre': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "nombre", null)), null, tostring(index(pv!cab, "datosCliente", "nombre", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9bb6458d-2b8a-46e4-950d-f443a4d99ab1}clienteApellidos': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "apellidos", null)), null, tostring(index(pv!cab, "datosCliente", "apellidos", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "nif", null)), null, tostring(index(pv!cab, "datosCliente", "nif", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{3fc54e3e-02fe-4079-98fd-6a59db42dfaa}clienteApoderado': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "apoderado", null)), null, tostring(index(pv!cab, "datosCliente", "apoderado", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "carterizado", null)), null, tostring(index(pv!cab, "datosCliente", "carterizado", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0356c6be-be84-438f-9115-a5d5a5a76724}clienteNuumapropietario': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "nuumaPropietario", null)), null, tostring(index(pv!cab, "datosCliente", "nuumaPropietario", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{19903d82-74a4-4b2d-9363-442e085400ca}clienteRsvprima': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "rsvPrima", null)), null, tostring(index(pv!cab, "datosCliente", "rsvPrima", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab2f2789-e49e-4b66-97cd-a7ef5bfec730}clienteDtointegralidadnuevaproduccion': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "dtoIntegralidadNuevaProduccion", null)), null, tostring(index(pv!cab, "datosCliente", "dtoIntegralidadNuevaProduccion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{f463d88a-b415-43aa-914b-9c8227fb4074}clienteTreboles': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "treboles", null)), null, tostring(index(pv!cab, "datosCliente", "treboles", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{843d65a8-ba29-4b41-a9a8-1207882c8fd8}clienteActivoclubmapfre': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "activoClubMapfre", null)), null, tostring(index(pv!cab, "datosCliente", "activoClubMapfre", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1faa3be-6dcf-44e0-ad0e-a8592206aab6}clientePerfilclubmapfre': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "perfilClubMapfre", null)), null, tostring(index(pv!cab, "datosCliente", "perfilClubMapfre", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{653b9880-b834-460b-b109-03c0aa5d7f3f}clienteTipoclientevalor': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "tipoClienteValor", null)), null, tostring(tointeger(index(pv!cab, "datosCliente", "tipoClienteValor", null)))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{bee4cebe-cf9d-415a-a1eb-ae8d17740f14}clienteTipoclientedesc': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "tipoClienteDesc", null)), null, tostring(index(pv!cab, "datosCliente", "tipoClienteDesc", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{965531d7-d779-4a3a-ae0e-49f63e4cfe10}clienteIdcliente': if(a!isNullOrEmpty(index(pv!cab, "datosCliente", "idCliente", null)), null, tostring(index(pv!cab, "datosCliente", "idCliente", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b4fbe9d5-5949-4693-9c2f-8acce0349ff5}polizaNumeropoliza': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "numeroPoliza", null)), null, tostring(index(pv!cab, "datosPoliza", "numeroPoliza", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{488a1def-2853-4526-85b9-e28cb686a8db}polizaNombreproducto': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "nombreProducto", null)), null, tostring(index(pv!cab, "datosPoliza", "nombreProducto", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4bb6981c-24f2-40d0-8852-06b0c9a064a6}polizaVehiculo': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "vehiculo", null)), null, tostring(index(pv!cab, "datosPoliza", "vehiculo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{1c5f745d-37aa-49cb-8600-56a8e0fe9165}polizaLineanegocio': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "lineaNegocio", null)), null, tostring(index(pv!cab, "datosPoliza", "lineaNegocio", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{8dcfa2e7-3e34-4026-a59a-bcebb29be5c8}polizaFormapago': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "formaPago", null)), null, tostring(index(pv!cab, "datosPoliza", "formaPago", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{df03488b-3af6-400b-8083-a632f4c9c482}polizaFechaefecto': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "fechaEfecto", null)), null, tostring(index(pv!cab, "datosPoliza", "fechaEfecto", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e46d7b58-2fab-4fac-aa5d-0282c8ae58d7}polizaFechavencimiento': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "fechaVencimiento", null)), null, tostring(index(pv!cab, "datosPoliza", "fechaVencimiento", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6315089c-564a-471b-8835-a40ebdd10188}polizaAntiguedad': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "antiguedad", null)), null, tostring(index(pv!cab, "datosPoliza", "antiguedad", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab8c7579-6fc8-4a2e-bc13-2bf7da8123d5}polizaPlanpago': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "planPago", null)), null, tostring(index(pv!cab, "datosPoliza", "planPago", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1749b80-0132-47ac-9931-be0ee9c75d43}polizaPrimaactualrenovacion': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "primaActualRenovacion", null)), null, tostring(index(pv!cab, "datosPoliza", "primaActualRenovacion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{48fcf401-d54c-45c6-805d-c1f5c9118187}polizaAcuerdo': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "acuerdo", null)), null, tostring(index(pv!cab, "datosPoliza", "acuerdo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{349b1814-7050-4155-8ea1-87d2d9368eec}polizaClaveproduccion': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "claveProduccion", null)), null, tostring(index(pv!cab, "datosPoliza", "claveProduccion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{65918aea-f30b-471b-a914-814c7317f0d9}polizaTipoproductor': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "tipoProductor", null)), null, tostring(index(pv!cab, "datosPoliza", "tipoProductor", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{882be471-06fe-4411-960a-f71371b7383f}polizaSiniestrosanoactual': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "siniestrosAnoActual", null)), null, tostring(index(pv!cab, "datosPoliza", "siniestrosAnoActual", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b76b461d-80a8-4f10-8c8a-ae915cd43760}polizaFechaultimosiniestro': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "fechaUltimoSiniestro", null)), null, tostring(index(pv!cab, "datosPoliza", "fechaUltimoSiniestro", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{261fa0dc-e00c-4805-b248-88955c5012bb}polizaDtointegralidadpoliza': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "dtoIntegralidadPoliza", null)), null, tostring(index(pv!cab, "datosPoliza", "dtoIntegralidadPoliza", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7b3b8ddd-702f-4c10-ab5e-4e04d124cbcd}polizaRamo': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "ramo", null)), null, tostring(index(pv!cab, "datosPoliza", "ramo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7d8b7301-8498-4950-9c2a-ced856d45674}polizaCesionderechos': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "cesionDeDerechos", null)), null, tostring(index(pv!cab, "datosPoliza", "cesionDeDerechos", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a39a470b-6c4f-4685-b1ee-f9d1d591b757}polizaRevalorizacion': if(a!isNullOrEmpty(index(pv!cab, "datosPoliza", "revalorizacion", null)), null, tostring(index(pv!cab, "datosPoliza", "revalorizacion", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcec67d4-c615-4990-9165-10bf5c0a4e30}contactoVia': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "via", null)), null, tostring(index(pv!cab, "datosContacto", "via", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d579fd3f-6ba9-4759-8153-e6bb43d4f752}contactoDomicilio': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "domicilio", null)), null, tostring(index(pv!cab, "datosContacto", "domicilio", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{79c6a806-89a5-4a14-8f4b-f51da6465263}contactoNumero': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "numero", null)), null, tostring(index(pv!cab, "datosContacto", "numero", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{5e833491-162a-4fa3-811e-9106f72efc74}contactoProvincia': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "provincia", null)), null, tostring(index(pv!cab, "datosContacto", "provincia", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcf9ec55-848a-4035-b468-3bfeb93adb7b}contactoLocalidad': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "localidad", null)), null, tostring(index(pv!cab, "datosContacto", "localidad", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e9da29b2-2b7b-4570-baf4-3de4b9d8f9a0}contactoCodpostal': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "codPostal", null)), null, tostring(index(pv!cab, "datosContacto", "codPostal", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{627820e0-fc57-4997-9e38-2e16fd1c8eca}contactoTelmovil': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "telMovil", null)), null, tostring(index(pv!cab, "datosContacto", "telMovil", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9f8584e7-619b-489a-86ed-463e4e9830ab}contactoTelfijo': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "telFijo", null)), null, tostring(index(pv!cab, "datosContacto", "telFijo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4a1a4e27-0e23-47ae-ba19-35da1c61d478}contactoCorreo': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "correo", null)), null, tostring(index(pv!cab, "datosContacto", "correo", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0e80fa4a-e936-4bab-997b-544a39e339a0}contactoPiso': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "piso", null)), null, tostring(index(pv!cab, "datosContacto", "piso", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{baa3d3bc-79c0-49dc-b111-eacd1453e524}contactoPuerta': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "puerta", null)), null, tostring(index(pv!cab, "datosContacto", "puerta", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d2f90a66-bd08-4610-a60a-988cae4049a4}contactoEscalera': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "escalera", null)), null, tostring(index(pv!cab, "datosContacto", "escalera", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{93830b86-140f-46ab-9b27-5e653c755c4b}contactoPais': if(a!isNullOrEmpty(index(pv!cab, "datosContacto", "pais", null)), null, tostring(index(pv!cab, "datosContacto", "pais", null))),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6593228e-78fa-4648-ab2b-eea03a3d632a}tipoPoliza': local!tipoPolizaCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c082796f-ace6-4ef6-8a19-797c89e2dfc6}clienteCodint': local!codIntCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache': local!ahoraCache,
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta': rule!SCA2_calcularValidaHastaCache(fechaHoraCarga: local!ahoraCache, hora: cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA),
      'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache': "CACHE"
    )
  )
)
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
| UI3 | Clic real en «Actualizar datos» (navegador, usuario de servicio, interruptor true) — 1.er clic | sin error; cabecera conservada; se crea 1 fila `CACHE` | sin error; LAPOVA / 94516056V / HOGAR FAMILIAR conservados; 5,7 s; fila `id 221` creada (`origenCache = CACHE`, `fechaCache 10:54`, `validaHasta 2026-10-22 07:00:00` UTC, 51 campos, `tipoPoliza NSE-Hogar`, `clienteCodint 418620322020`) | OK | 15788005 | — | Buscador → detalle → clic; comprobación de la fila por API `/data` | — |
| UI4 | F5 tras el clic (caché vigente) | datos iguales, enlace visible, más rápido | iguales; enlace visible; 3,2 s (carga inicial 4,7 s) | OK | 15788005 | — | Recarga de la página | — |
| UI5 | 2.º clic en «Actualizar datos» | sin error; **actualiza** la misma fila (sin duplicar) | sin error; 3,9 s; sigue 1 sola fila `CACHE` (`id 221`, `fechaCache 10:55:19`) | OK | 15788005 | — | Clic; API `/data` | — |
| UI6 | Limpieza final | constante false, filas CACHE borradas | fila 221 borrada; constante v11 = false | OK | — | — | API | — |

Pruebas intermedias que fallaron y se corrigieron: (1) v3 reconstruía con `index(fila, campo, null)` → todos los campos nulos; (2) v4 con `fila[campo]` seguía nulo porque `a!queryRecordType` **sin `fields`** devolvía filas sin datos en este contexto → v5 declara `fields` explícitos (y lo mismo en las consultas de la interfaz).

Limpieza: las filas CACHE de prueba (ids 207–209, 211–213, 217–219 por API; 221 creada por el clic en la UI) se borraron; la constante quedó en **false (v11)**; `SCA2_calcularValidaHastaCache` conserva solo sus 10 casos. Grabación y capturas de la prueba UI en la sesión. Observación de la UI: el buscador muestra 15788005 como «Solicitud Pendiente» aunque `estadoSolicitud = EN_ACCION` (etiqueta funcional, no relacionado con la caché).

### 6.4 Tiempos (resumen)

| Medida | Antes (vivo) | Con caché vigente |
|---|---|---|
| `SCA2_obtenerDatosCabecera` (API `/test`) | 3,4 – 6,6 s | 0,9 s (incluye la llamada en vivo a otras solicitudes) |
| Render de `SCA2_DetalleSolicitud` (API `/interfaces/test`) | 3,7 – 4,2 s | 1,3 – 1,7 s |
| Detalle en navegador (usuario de servicio) | 4,7 s (carga inicial, en vivo) | 3,2 s (F5 con caché; incluye el resto de la pantalla: tareas, gestiones CORE…) |
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

- **`SCA2 CMD Alta` (sesión A)**: añadir el Write Records de §4.5 para que la caché se cree en el alta; sin ello el beneficio con el interruptor en true depende del enlace manual.
- **PM `SCA2 CMD RefrescarCacheCabecera`** (§10): crear desde la UI de Designer según la especificación (+ constante `SCA2_CACHE_REFRESCO_BATCH`).
- **Invalidación en CMD** (§8): asignar por el coordinador.
- **Limpieza futura**: `idSolicitud` no es única en `SCA2 Datos Cabecera` (`SCA2 CMD Alta` inserta su propia fila parcial; las 206 filas previas carecen de `validaHasta`). No se ha actuado.
- Vida/Verti: sin datos en TEST; cuando existan, repetir C01–C03 (campos `polizaRamo`, `polizaCesionderechos`, `polizaRevalorizacion`, `contactoPais`).
- Activación: poner `SCA2_USAR_CACHE_CABECERA = true` cuando el coordinador lo decida (reversible en cualquier momento volviendo a false).

## 10. Especificación del PM `SCA2 CMD RefrescarCacheCabecera` (no creado: la API no permite crear PM en TEST)

**Propósito**: renovar cada mañana las filas de caché caducadas de solicitudes abiertas, para que la primera apertura del día ya sea rápida. Mientras no exista: la regla sirve en vivo cuando no hay caché vigente (= comportamiento actual); la fila caducada se renueva al pulsar «Actualizar datos» (y, cuando A lo aplique, en cada alta).

**Disparo**: evento de inicio con temporizador, diario a las **07:05** en la zona del proceso. Si el servidor de procesos está en UTC (como el usuario de servicio, §5), 07:05 UTC = 08:05/09:05 Madrid; en ese momento ya han caducado tanto las filas escritas por usuarios de Madrid (07:00 Madrid = 05:00/06:00 UTC) como las escritas por PM (07:00 UTC). Sin gateway de fin de semana (la caché del lunes se crea igualmente). Carpeta `SCA2 Artifacts`; seguridad como el resto de `SCA2 CMD *`; ejecutar como el usuario de servicio de los CMD.

**Constante nueva propuesta**: `SCA2_CACHE_REFRESCO_BATCH` (Integer, 50) = máximo de filas por ejecución (las que no entren se renuevan al día siguiente o bajo demanda).

**Variables de proceso**: `filas` (SCA2 Datos Cabecera, múltiple), `indice` (Integer, 1), `cabecera` (SCAC_DS_datosCabecera), `ahora` (Date and Time), `errores` (Text, múltiple), `procesadas` (Integer, 0).

**Nodos** (flujo secuencial, tolerante a errores por fila):

| # | Nodo | Tipo | Expresión / configuración |
|---|---|---|---|
| 1 | Inicio 07:05 | Start event (timer) | Recurrencia diaria, 07:05 |
| 2 | Seleccionar filas caducadas | Script Task | `pv!filas` ← expresión A (abajo). Si `a!isNullOrEmpty(pv!filas)` → nodo 9 |
| 3 | ¿Quedan filas? | XOR | `pv!indice <= length(pv!filas)` → 4; si no → 9 |
| 4 | Cargar cabecera en vivo | Script Task (con flujo de excepción) | `pv!ahora` ← `now()`; `pv!cabecera` ← `rule!SCA2_obtenerDatosCabeceraLive(numPoliza: pv!filas[pv!indice][polizaNumeropoliza], idSolicitud: pv!filas[pv!indice][idSolicitud])`. Excepción (timer 90 s o error) → nodo 7 |
| 5 | ¿Cabecera válida? | XOR | `a!isNotNullOrEmpty(pv!cabecera)` → 6; si no → 7 |
| 6 | Actualizar fila caché | Write Records | `Records` = expresión B (abajo): misma fila (`id`), 51 campos, `fechaCache = pv!ahora`, `validaHasta = rule!SCA2_calcularValidaHastaCache(pv!ahora, cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA)`, `origenCache = "CACHE"`; `pv!procesadas` ← `pv!procesadas + 1`. Excepción → nodo 7 |
| 7 | Anotar error de la fila | Script Task | `pv!errores` ← `append(pv!errores, "idSolicitud " & pv!filas[pv!indice][idSolicitud] & ": " & <mensaje>)`. **No** se modifica la fila (sigue caducada → la regla sirve en vivo) |
| 8 | Siguiente | Script Task | `pv!indice` ← `pv!indice + 1`; `pv!cabecera` ← `null` → vuelve a 3 |
| 9 | Fin | End event | Opcional: si `length(pv!errores) > 0`, nodo de aviso (correo al grupo de administradores o fila en `SCA2 Error`, objeto de otra sesión) |

Expresión A (nodo 2, `pv!filas`). Estados cerrados a excluir, según los valores observados en TEST: `FINALIZADA`, `FINALIZADA_POSITIVO`, `CANCELADA` (y `CADUCADA` si se usa); el resto (`EN_ACCION`, `PDTE_MECANIZAR`, `MECANIZADA`, `ALTA`, `ERROR`, `PDTE_FINALIZAR`, `ERROR_DECISION`) se consideran abiertas. Los uuid de `SCA2 Solicitud.idSolicitud/estadoSolicitud` son los del record en TEST (`GET /record-types/c531595c-c3b5-454c-a355-8145e7e27e9a`):

```sail
=a!localVariables(
  local!abiertas: a!queryRecordType(
    recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
    fields: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
    filters: a!queryFilter(
      field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
      operator: "not in",
      value: {"FINALIZADA", "FINALIZADA_POSITIVO", "CANCELADA", "CADUCADA"}
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
    fetchTotalCount: false
  ).data['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud'],
  a!queryRecordType(
    recordType: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera',
    fields: {'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id', 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b4fbe9d5-5949-4693-9c2f-8acce0349ff5}polizaNumeropoliza', 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta'},
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache', operator: "=", value: "CACHE"),
        a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta', operator: "<=", value: now()),
        a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', operator: "in", value: a!defaultValue(touniformstring(local!abiertas), {"-"}))
      }
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: cons!SCA2_CACHE_REFRESCO_BATCH,
      sort: a!sortInfo(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta', ascending: true)
    ),
    fetchTotalCount: false
  ).data
)
```

Expresión B (nodo 6, `Records`):

```sail
='recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera'(
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id': pv!filas[pv!indice]['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id'],
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud': pv!filas[pv!indice]['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud'],
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{be8a5c3b-b866-4aa7-8424-e0b9fb585790}clienteNombre': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "nombre", null)), null, tostring(index(pv!cabecera, "datosCliente", "nombre", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9bb6458d-2b8a-46e4-950d-f443a4d99ab1}clienteApellidos': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "apellidos", null)), null, tostring(index(pv!cabecera, "datosCliente", "apellidos", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4ff02b25-e235-434c-ba96-b422befd7510}clienteNif': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "nif", null)), null, tostring(index(pv!cabecera, "datosCliente", "nif", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{3fc54e3e-02fe-4079-98fd-6a59db42dfaa}clienteApoderado': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "apoderado", null)), null, tostring(index(pv!cabecera, "datosCliente", "apoderado", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e5e221c1-1e05-4152-9c5e-a9a7e1e40a90}clienteCarterizado': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "carterizado", null)), null, tostring(index(pv!cabecera, "datosCliente", "carterizado", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0356c6be-be84-438f-9115-a5d5a5a76724}clienteNuumapropietario': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "nuumaPropietario", null)), null, tostring(index(pv!cabecera, "datosCliente", "nuumaPropietario", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{19903d82-74a4-4b2d-9363-442e085400ca}clienteRsvprima': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "rsvPrima", null)), null, tostring(index(pv!cabecera, "datosCliente", "rsvPrima", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab2f2789-e49e-4b66-97cd-a7ef5bfec730}clienteDtointegralidadnuevaproduccion': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "dtoIntegralidadNuevaProduccion", null)), null, tostring(index(pv!cabecera, "datosCliente", "dtoIntegralidadNuevaProduccion", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{f463d88a-b415-43aa-914b-9c8227fb4074}clienteTreboles': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "treboles", null)), null, tostring(index(pv!cabecera, "datosCliente", "treboles", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{843d65a8-ba29-4b41-a9a8-1207882c8fd8}clienteActivoclubmapfre': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "activoClubMapfre", null)), null, tostring(index(pv!cabecera, "datosCliente", "activoClubMapfre", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1faa3be-6dcf-44e0-ad0e-a8592206aab6}clientePerfilclubmapfre': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "perfilClubMapfre", null)), null, tostring(index(pv!cabecera, "datosCliente", "perfilClubMapfre", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{653b9880-b834-460b-b109-03c0aa5d7f3f}clienteTipoclientevalor': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "tipoClienteValor", null)), null, tostring(tointeger(index(pv!cabecera, "datosCliente", "tipoClienteValor", null)))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{bee4cebe-cf9d-415a-a1eb-ae8d17740f14}clienteTipoclientedesc': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "tipoClienteDesc", null)), null, tostring(index(pv!cabecera, "datosCliente", "tipoClienteDesc", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{965531d7-d779-4a3a-ae0e-49f63e4cfe10}clienteIdcliente': if(a!isNullOrEmpty(index(pv!cabecera, "datosCliente", "idCliente", null)), null, tostring(index(pv!cabecera, "datosCliente", "idCliente", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b4fbe9d5-5949-4693-9c2f-8acce0349ff5}polizaNumeropoliza': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "numeroPoliza", null)), null, tostring(index(pv!cabecera, "datosPoliza", "numeroPoliza", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{488a1def-2853-4526-85b9-e28cb686a8db}polizaNombreproducto': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "nombreProducto", null)), null, tostring(index(pv!cabecera, "datosPoliza", "nombreProducto", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4bb6981c-24f2-40d0-8852-06b0c9a064a6}polizaVehiculo': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "vehiculo", null)), null, tostring(index(pv!cabecera, "datosPoliza", "vehiculo", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{1c5f745d-37aa-49cb-8600-56a8e0fe9165}polizaLineanegocio': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "lineaNegocio", null)), null, tostring(index(pv!cabecera, "datosPoliza", "lineaNegocio", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{8dcfa2e7-3e34-4026-a59a-bcebb29be5c8}polizaFormapago': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "formaPago", null)), null, tostring(index(pv!cabecera, "datosPoliza", "formaPago", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{df03488b-3af6-400b-8083-a632f4c9c482}polizaFechaefecto': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "fechaEfecto", null)), null, tostring(index(pv!cabecera, "datosPoliza", "fechaEfecto", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e46d7b58-2fab-4fac-aa5d-0282c8ae58d7}polizaFechavencimiento': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "fechaVencimiento", null)), null, tostring(index(pv!cabecera, "datosPoliza", "fechaVencimiento", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6315089c-564a-471b-8835-a40ebdd10188}polizaAntiguedad': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "antiguedad", null)), null, tostring(index(pv!cabecera, "datosPoliza", "antiguedad", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{ab8c7579-6fc8-4a2e-bc13-2bf7da8123d5}polizaPlanpago': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "planPago", null)), null, tostring(index(pv!cabecera, "datosPoliza", "planPago", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a1749b80-0132-47ac-9931-be0ee9c75d43}polizaPrimaactualrenovacion': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "primaActualRenovacion", null)), null, tostring(index(pv!cabecera, "datosPoliza", "primaActualRenovacion", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{48fcf401-d54c-45c6-805d-c1f5c9118187}polizaAcuerdo': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "acuerdo", null)), null, tostring(index(pv!cabecera, "datosPoliza", "acuerdo", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{349b1814-7050-4155-8ea1-87d2d9368eec}polizaClaveproduccion': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "claveProduccion", null)), null, tostring(index(pv!cabecera, "datosPoliza", "claveProduccion", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{65918aea-f30b-471b-a914-814c7317f0d9}polizaTipoproductor': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "tipoProductor", null)), null, tostring(index(pv!cabecera, "datosPoliza", "tipoProductor", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{882be471-06fe-4411-960a-f71371b7383f}polizaSiniestrosanoactual': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "siniestrosAnoActual", null)), null, tostring(index(pv!cabecera, "datosPoliza", "siniestrosAnoActual", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{b76b461d-80a8-4f10-8c8a-ae915cd43760}polizaFechaultimosiniestro': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "fechaUltimoSiniestro", null)), null, tostring(index(pv!cabecera, "datosPoliza", "fechaUltimoSiniestro", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{261fa0dc-e00c-4805-b248-88955c5012bb}polizaDtointegralidadpoliza': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "dtoIntegralidadPoliza", null)), null, tostring(index(pv!cabecera, "datosPoliza", "dtoIntegralidadPoliza", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7b3b8ddd-702f-4c10-ab5e-4e04d124cbcd}polizaRamo': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "ramo", null)), null, tostring(index(pv!cabecera, "datosPoliza", "ramo", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{7d8b7301-8498-4950-9c2a-ced856d45674}polizaCesionderechos': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "cesionDeDerechos", null)), null, tostring(index(pv!cabecera, "datosPoliza", "cesionDeDerechos", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{a39a470b-6c4f-4685-b1ee-f9d1d591b757}polizaRevalorizacion': if(a!isNullOrEmpty(index(pv!cabecera, "datosPoliza", "revalorizacion", null)), null, tostring(index(pv!cabecera, "datosPoliza", "revalorizacion", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcec67d4-c615-4990-9165-10bf5c0a4e30}contactoVia': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "via", null)), null, tostring(index(pv!cabecera, "datosContacto", "via", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d579fd3f-6ba9-4759-8153-e6bb43d4f752}contactoDomicilio': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "domicilio", null)), null, tostring(index(pv!cabecera, "datosContacto", "domicilio", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{79c6a806-89a5-4a14-8f4b-f51da6465263}contactoNumero': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "numero", null)), null, tostring(index(pv!cabecera, "datosContacto", "numero", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{5e833491-162a-4fa3-811e-9106f72efc74}contactoProvincia': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "provincia", null)), null, tostring(index(pv!cabecera, "datosContacto", "provincia", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{fcf9ec55-848a-4035-b468-3bfeb93adb7b}contactoLocalidad': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "localidad", null)), null, tostring(index(pv!cabecera, "datosContacto", "localidad", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{e9da29b2-2b7b-4570-baf4-3de4b9d8f9a0}contactoCodpostal': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "codPostal", null)), null, tostring(index(pv!cabecera, "datosContacto", "codPostal", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{627820e0-fc57-4997-9e38-2e16fd1c8eca}contactoTelmovil': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "telMovil", null)), null, tostring(index(pv!cabecera, "datosContacto", "telMovil", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{9f8584e7-619b-489a-86ed-463e4e9830ab}contactoTelfijo': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "telFijo", null)), null, tostring(index(pv!cabecera, "datosContacto", "telFijo", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{4a1a4e27-0e23-47ae-ba19-35da1c61d478}contactoCorreo': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "correo", null)), null, tostring(index(pv!cabecera, "datosContacto", "correo", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{0e80fa4a-e936-4bab-997b-544a39e339a0}contactoPiso': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "piso", null)), null, tostring(index(pv!cabecera, "datosContacto", "piso", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{baa3d3bc-79c0-49dc-b111-eacd1453e524}contactoPuerta': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "puerta", null)), null, tostring(index(pv!cabecera, "datosContacto", "puerta", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{d2f90a66-bd08-4610-a60a-988cae4049a4}contactoEscalera': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "escalera", null)), null, tostring(index(pv!cabecera, "datosContacto", "escalera", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{93830b86-140f-46ab-9b27-5e653c755c4b}contactoPais': if(a!isNullOrEmpty(index(pv!cabecera, "datosContacto", "pais", null)), null, tostring(index(pv!cabecera, "datosContacto", "pais", null))),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6593228e-78fa-4648-ab2b-eea03a3d632a}tipoPoliza': pv!filas[pv!indice]['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6593228e-78fa-4648-ab2b-eea03a3d632a}tipoPoliza'],
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c082796f-ace6-4ef6-8a19-797c89e2dfc6}clienteCodint': pv!filas[pv!indice]['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c082796f-ace6-4ef6-8a19-797c89e2dfc6}clienteCodint'],
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{816f4439-7cf7-4f9f-8e30-aff3256daeec}fechaCache': pv!ahora,
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta': rule!SCA2_calcularValidaHastaCache(fechaHoraCarga: pv!ahora, hora: cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA),
  'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache': "CACHE"
)
```

**Volumen en TEST** (2026-10-21): 218 solicitudes, 144 abiertas (EN_ACCION 84, PDTE_MECANIZAR 34, MECANIZADA 9, ALTA 7, ERROR 7, PDTE_FINALIZAR 2, ERROR_DECISION 1). Hoy no hay filas `CACHE` (solo se crearán con «Actualizar datos» y, cuando A lo aplique, en el alta), así que la primera ejecución procesaría 0 filas; en régimen, como máximo las solicitudes abiertas con fila CACHE: ≤ 144 en TEST. A 3,5–6,6 s por carga en vivo, 50 filas ≈ 3–6 min secuenciales; 144 filas ≈ 8–16 min (o 3 días con batch 50). Si en PRO el volumen fuese mayor, elevar el batch o usar MNI (instancias múltiples) en el nodo 4 con `tp!instanceIndex`, manteniendo la excepción por instancia.

**Pruebas sugeridas al crearlo**: (1) sin filas caducadas → termina sin escribir; (2) 2 filas caducadas de solicitudes abiertas + 1 de solicitud FINALIZADA → renueva 2, ignora 1; (3) una fila con póliza inexistente → error anotado, fila intacta, el resto renovado; (4) batch 1 → una fila por ejecución; (5) interruptor en false → el PM puede ejecutarse igualmente (solo mantiene filas; la regla no las usará) o añadir un gateway inicial `cons!SCA2_USAR_CACHE_CABECERA` para no gastar llamadas.

## 11. Renovación automática en la primera carga tras la caducidad — análisis y propuesta (FASE 1, sin cambios en TEST)

Requisito (21/10/2026): si al abrir la solicitud la caché no existe o está caducada, la regla llama a los servicios **y además guarda la fila y la nueva `validaHasta`** sin que el usuario pulse nada; F5 / salir y entrar deben ser rápidos. El enlace «Actualizar datos» queda como refresco opcional.

### 11.1 Cómo se abren hoy las pantallas que llaman a `SCA2_obtenerDatosCabecera`

| Pantalla | Cómo se llega | ¿Hay contexto de escritura (saveInto/PM) justo antes de la carga? |
|---|---|---|
| `SCA2_DetalleSolicitud` | Embebida en la site page `SCA2_Buscador` (`rule!SCA2_DetalleSolicitud(idSolicitud: ri!idSolicitud, …)`, `ri!` del site/URL). Se llega (1) pulsando el id en `SCA2_BuscadorTabla` (filas Aurora) o en la tabla CORE de `SCA2_Buscador` → `a!dynamicLink` con `a!save(ri!idSel / ri!idSolicitud …)`; (2) «BUSCAR SOLICITUD» con resultado único; (3) **URL directa / F5** (`$sp`) | Solo en (1) y (2) hay `saveInto`, en interfaces de **otras sesiones** (`SCA2_Buscador`, `SCA2_BuscadorTabla`); en (3) no hay ninguno |
| `SCA2_AltaSolicitudPage` | Embebida en `SCA2_Buscador` (pestaña alta) | No; además `idSolicitud` nulo/0 → siempre en vivo (sin caché) |
| `SCA2_AccionesAdministrativasPrincipal`, `SCA2_AnulacionFueraNormaPrincipal`, `SCA2_ContraAnulacionPrincipal` (+ `SCA2_DatosCabecera_Estrategicas`, `SCA2_ContraAnulacionOpciones`, `SCA2_MilestoneMasDatosAltaSolicitud*`) | Embebidas en `SCA2_DetalleTareas` dentro del Detalle (pestaña de acción abierta, `ri!tipoAccion`) | No (mismo contexto de carga del Detalle) |
| `SCA2 CMD Alta`, `SCA2 CMD CrearAccion`, `SCA2 CMD Mecanizar` | Nodos de PM | Sí: ya escriben records (A escribe la fila CACHE en el alta) |

Conclusión: no existe un record action ni un `a!startProcess` previo que abra el Detalle; la vía (a) «paso previo en el PM/acción que abre la pantalla» obligaría a tocar `SCA2_Buscador` y `SCA2_BuscadorTabla` (otras sesiones), **no cubriría la URL directa ni el F5** y dejaría fuera a las sub-pantallas. Se descarta.

### 11.2 Propuesta: vía (b) Web API interna + integración de consulta, invocada desde el envoltorio solo cuando la caché no sirve

Idea: `SCA2_obtenerDatosCabecera` sigue leyendo la caché como hoy; cuando **no hay fila vigente** (y hay `idSolicitud` real y no `forzarRefresco`), en lugar de llamar a `…Live` directamente llama a una integración GET de SCA2 → Web API `SCA2_refrescarCacheCabecera` de la propia instancia, que ejecuta `…Live`, hace el upsert de la fila `CACHE` (`fechaCache = now()`, `validaHasta` = 07:00 del día siguiente, `tipoPoliza`, `clienteCodint`) y devuelve la cabecera en JSON. El envoltorio reconstruye `SCAC_DS_datosCabecera` y lo devuelve. Si la integración falla o tarda más del timeout → **degrada a `…Live` en vivo** (resultado idéntico a hoy, sin error, solo sin guardar). Con `forzarRefresco = true` se usa la misma Web API (así el enlace «Actualizar datos» deja de necesitar su `a!writeRecords`; se puede simplificar a `a!save(local!estructuraCabecera, rule!SCA2_obtenerDatosCabecera(…, forzarRefresco: true))`).

Objetos nuevos (todos de la sesión D):

| Objeto | Tipo | Detalle |
|---|---|---|
| `SCA2_refrescarCacheCabecera` | Web API (GET, `url alias` `sca2-cache-cabecera`) | Parámetros `idSolicitud`, `numPoliza`, `forzar` (opcional). Seguridad del objeto: solo el grupo de servicio (el usuario de servicio de SCA2) como *Viewer*; el resto sin acceso. Expresión en §11.3 |
| `SCA2 Appian Interno` | Connected System HTTP | `baseUrl` = URL de la propia instancia (`https://mapfrespain-test.appiancloud.com/suite/webapi/`), autenticación **Basic con el usuario de servicio** (contraseña guardada cifrada en el CS; en PRO, cuenta de servicio con API key: la crea un administrador en Admin Console). Un CS por entorno (TEST/PRO) con valores por entorno |
| `SCA2_refrescarCacheCabeceraIntegracion` | Integration (GET, **«consulta de datos / no modifica»** para que Appian permita invocarla al cargar) | `relativePath` `sca2-cache-cabecera`, query params `idSolicitud`, `numPoliza`, `forzar`; timeout 30 s; `a!httpResponse` JSON |
| `SCA2_USAR_WEBAPI_CACHE_CABECERA` | Constante Boolean | Sub-interruptor (false por defecto): permite activar/desactivar la renovación automática sin tocar la caché de lectura |

Cambios en `SCA2_obtenerDatosCabecera` (misma firma: `numPoliza`, `idSolicitud`, `forzarRefresco`):

```text
usarCache (igual que hoy) → fila vigente → reconstruir (igual que hoy, sin llamadas salvo otras solicitudes)
sin fila vigente (o forzarRefresco) y cons!SCA2_USAR_WEBAPI_CACHE_CABECERA y idSolicitud real:
    local!resp: rule!SCA2_refrescarCacheCabeceraIntegracion(idSolicitud, numPoliza, forzar: forzarRefresco)
    si local!resp.success y a!isNotNullOrEmpty(local!resp.result.body) → cast(SCAC_DS_datosCabecera, a!fromJson(local!resp.result.body))
       (Document: todocument(tointeger(...)); otrasSolicitudesCabecera: lista → cast a mssConsultarSolicitudesDTO)
    si no → rule!SCA2_obtenerDatosCabeceraLive(numPoliza, idSolicitud)      ← degradación a vivo, nunca error
resto de casos (constante principal false, idSolicitud nulo/0) → …Live, como hoy
```

Seguridad: la Web API no es pública: exige autenticación Appian y solo el grupo de servicio tiene permiso sobre el objeto; la contraseña vive en el connected system (cifrada, no en SAIL ni en el repo); la Web API no acepta más parámetros que `idSolicitud/numPoliza/forzar` y solo escribe en `SCA2 Datos Cabecera` (fila `CACHE`). Punto a decidir: la Web API ejecuta `…Live` como el **usuario de servicio** (no el usuario que abre la pantalla), igual que `SCA2 CMD Alta` y el PM de F; `local!nuuma` de la regla sale de `loggedInUser()` → los campos que dependan del usuario (carterización/propietario) en la fila CACHE se calculan con el usuario de servicio. Es la misma limitación que ya tiene la caché compartida por solicitud. Si se quiere evitar, la Web API puede recibir `usuario` y no se puede inyectar en `…Live` sin cambiar su firma (sería un cambio de `…Live`, a decidir).

Latencia: solo en el miss (una vez al día por solicitud): Live 3,4–6,6 s (igual que hoy) + salto HTTP interno ≈ 0,1–0,3 s + `a!writeRecords` ≈ 0,1 s. Los hits siguen en ≈ 0,9 s. Fallo de la Web API: coste = Live (una vez) + el intento fallido (timeout acotado a 30 s en el peor caso de red; normalmente error inmediato).

### 11.3 SAIL propuesto

Web API `SCA2_refrescarCacheCabecera` (GET):

```sail
=a!localVariables(
  local!idSolicitud: a!defaultValue(http!request.queryParameters.idSolicitud, ""),
  local!numPoliza: a!defaultValue(http!request.queryParameters.numPoliza, ""),
  if(
    or(a!isNullOrEmpty(local!idSolicitud), local!idSolicitud = "0", a!isNullOrEmpty(local!numPoliza)),
    a!httpResponse(statusCode: 400, headers: {a!httpHeader(name: "Content-Type", value: "application/json")}, body: a!toJson(a!map(error: "idSolicitud/numPoliza obligatorios"))),
    a!localVariables(
      local!cabecera: rule!SCA2_obtenerDatosCabeceraLive(numPoliza: local!numPoliza, idSolicitud: local!idSolicitud),
      local!tipoPoliza: rule!SCA2_obtenerTipoPoliza(numPoliza: local!numPoliza),
      local!codInt: /* igual que el bloque de la interfaz: Vida → null; Hogar → SCA2 Datos Poliza Hogar.tomadorCodint; resto → SCA2 Datos Poliza Autos.tomadorCodint */ ...,
      local!ahora: now(),
      local!filaPrevia: /* query fila origenCache = CACHE de la solicitud (fields: id, fechaCache) */ ...,
      local!idFila: if(a!isNullOrEmpty(local!filaPrevia), null, index(local!filaPrevia, 1, null)['…id']),
      if(
        a!isNullOrEmpty(local!cabecera),
        a!httpResponse(statusCode: 204),
        a!writeRecords(
          records: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera'( /* MISMO mapeo de §4.4 con local!cabecera, local!idFila, local!tipoPoliza, local!codInt, local!ahora */ ),
          onSuccess: a!httpResponse(statusCode: 200, headers: {a!httpHeader(name: "Content-Type", value: "application/json")}, body: a!toJson(local!cabecera)),
          onError: a!httpResponse(statusCode: 200, headers: {a!httpHeader(name: "Content-Type", value: "application/json")}, body: a!toJson(local!cabecera))
        )
      )
    )
  )
)
```

(En `onError` se devuelve igualmente la cabecera: el usuario no se entera de un fallo de escritura; queda sin caché hasta la siguiente apertura.)

Envoltorio (solo cambia la rama «sin fila vigente»):

```sail
if(
  a!isNullOrEmpty(local!filaCache),
  if(
    and(
      a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false),
      a!defaultValue(cons!SCA2_USAR_WEBAPI_CACHE_CABECERA, false),
      a!isNotNullOrEmpty(ri!idSolicitud), tostring(ri!idSolicitud) <> "0", a!isNotNullOrEmpty(ri!numPoliza)
    ),
    a!localVariables(
      local!resp: rule!SCA2_refrescarCacheCabeceraIntegracion(idSolicitud: tostring(ri!idSolicitud), numPoliza: ri!numPoliza, forzar: a!defaultValue(ri!forzarRefresco, false)),
      local!body: if(a!defaultValue(index(local!resp, "success", false), false), index(local!resp, "result", "body", null), null),
      if(
        a!isNullOrEmpty(local!body),
        rule!SCA2_obtenerDatosCabeceraLive(numPoliza: ri!numPoliza, idSolicitud: ri!idSolicitud),
        a!localVariables(
          local!json: a!fromJson(local!body),
          'type!{urn:com:appian:types:SCAC}SCAC_DS_datosCabecera'(
            datosCliente: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosCliente'( /* campos desde local!json.datosCliente; tipoClienteValor: todocument(tointeger(...)) */ ),
            datosPoliza: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosPoliza'( /* campos desde local!json.datosPoliza */ ),
            otrasSolicitudesCabecera: a!forEach(items: a!defaultValue(index(local!json, "otrasSolicitudesCabecera", {}), {}), expression: cast('type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mssConsultarSolicitudesDTO', fv!item)),
            datosContacto: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosContacto'( /* campos desde local!json.datosContacto */ )
          )
        )
      )
    ),
    rule!SCA2_obtenerDatosCabeceraLive(numPoliza: ri!numPoliza, idSolicitud: ri!idSolicitud)
  ),
  /* rama con fila vigente: igual que hoy */ ...
)
```

Nota: hoy la rama sin fila vigente también se toma con `forzarRefresco = true`; con la Web API ese caso pasa `forzar: true` (la Web API siempre recarga en vivo, el parámetro es informativo para trazas).

### 11.4 Alternativa (c) valorada: hacer la escritura en `saveInto` de los puntos de entrada
Modificar `SCA2_Buscador`/`SCA2_BuscadorTabla` (clic en el id → `a!startProcess` de un PM que renueve la caché y luego abra el Detalle) evita Web API y credenciales, pero toca interfaces de otras sesiones, añade un proceso por apertura, no cubre URL directa/F5 ni las sub-pantallas, y cambia la navegación actual. Se descarta salvo que (b) no sea aceptable por la gestión de credenciales.

### 11.5 Plan de pruebas (FASE 2)

| ID | Caso | Esperado |
|---|---|---|
| W01 | Web API por API (`GET …/webapi/sca2-cache-cabecera?idSolicitud=&numPoliza=`) con una solicitud propia | 200 JSON con la cabecera; fila `CACHE` creada/actualizada con `validaHasta` = 07:00 del día siguiente |
| W02 | Caché caducada (fila con `validaHasta` pasado) → `/test` del envoltorio | llama a servicios (tiempo Live), devuelve cabecera idéntica a Live, y la fila queda renovada (`fechaCache` nueva, `validaHasta` futura) |
| W03 | Segunda llamada inmediata (F5) | desde caché (< 1 s), sin llamadas a servicios (verificado con `LEE`: campo alterado en la fila se refleja) |
| W04 | `forzarRefresco = true` | recarga en vivo vía Web API y renueva la fila |
| W05 | Fallo de la Web API (sub-interruptor con URL inválida en el CS o Web API sin permisos) | el envoltorio devuelve la cabecera en vivo, sin error; sin fila |
| W06 | Sub-interruptor `SCA2_USAR_WEBAPI_CACHE_CABECERA = false` | comportamiento actual (lee caché / Live sin escribir) |
| W07 | Constante principal `false` | regresión idéntica (3 solicitudes) |
| W08 | Seguridad: `GET` a la Web API sin autenticación / con un usuario sin permiso sobre el objeto | 401/403 |
| W09 | UI: abrir Detalle con caché caducada, F5 | 1.ª carga lenta, F5 rápida; «Actualizar datos» sigue funcionando |
| W10 | Convivencia con A/F/G: alta (fila A), invalidación de G (`validaHasta = now()`) → siguiente apertura renueva por Web API; PM de F no encuentra filas caducadas de solicitudes abiertas tras una apertura | coherente |

Decisiones que necesito antes de la FASE 2: (1) OK a la vía (b); (2) credenciales del connected system en TEST: usuario de servicio actual con Basic (lo configuro yo con la contraseña del entorno, sin escribirla en ningún sitio) o cuenta de servicio + API key (la crea un administrador); (3) aceptar que la fila CACHE renovada por la Web API se calcula con el usuario de servicio (como ya ocurre en A y F); (4) simplificar el enlace «Actualizar datos» para que use la Web API (quitar su `a!writeRecords`).

### 11.6 Implementación FASE 2 (21/10/2026, por LCP REST; sub-interruptor en `false`, sin cambios de comportamiento visibles)

Objetos (nombre · tipo · uuid · versión):

| Objeto | Tipo | UUID | Versión | Detalle |
|---|---|---|---|---|
| `SCA2_USAR_WEBAPI_CACHE_CABECERA` | Constante Boolean | `_a-0000f093-2064-8000-9d36-011c48011c48_5607587` | v1 = **false** | Sub-interruptor de la renovación automática |
| `SCA2 Appian Interno` | Connected System HTTP | `_a-0000f093-2064-8000-9d36-011c48011c48_5607593` | v2 | `baseUrl` `https://mapfrespain-test.appiancloud.com/suite/webapi/`, autenticación Basic con el usuario de servicio (contraseña cifrada en el CS, preemptiva). **En PRO: cuenta de servicio + API key** (Admin Console) y `baseUrl` de PRO |
| `SCA2_refrescarCacheCabecera` | Web API **POST** `sca2-cache-cabecera` | `324a1ee4-2312-4565-aa36-a383db17b36f` | — (la API no devuelve versión) | `?idSolicitud=&numPoliza=&usuario=`; 400 si faltan parámetros, 204 si no hay cabecera, 200 JSON con la cabecera; `isPublic = false` (401 sin autenticación) |
| `SCA2_renovarCacheCabecera` | Expression Rule | `_a-0000f093-2064-8000-9d36-011c48011c48_5607622` | v2 | Lógica de la Web API: `…Live(usuario)` + construcción de la fila `CACHE` (update si existe fila `CACHE` de la solicitud, insert si no; `tipoPoliza`, `clienteCodint`, `fechaCache = now()`, `validaHasta` = `SCA2_calcularValidaHastaCache`). Devuelve `a!map(fila, cabecera, error)`; **no escribe** |
| `SCA2_refrescarCacheCabeceraIntegracion` | Integration POST, uso **QUERY** | `0002bd57-3b75-480f-8e36-6f3bd3f9f3f9` | v4 | Query params `idSolicitud`, `numPoliza`, `usuario`, `forzar`; timeout 30 s; `bodyType application/json` (sin cuerpo); respuesta `RETURN_RAW` |
| `SCA2_obtenerDatosCabeceraLive` | Expression Rule | `…_5603393` | v1 → **v2** | Input opcional `usuario` (Text). Cambios mínimos: `local!nuuma: rule!CMP_obtenerNuuma(user(a!defaultValue(ri!usuario, loggedInUser()), "email"))` y en las dos consultas de siniestros `idUsuario: if(a!isNullOrEmpty(ri!usuario), <igual que hoy>, index(split(user(ri!usuario, "username"), "@"), 1, ""))`. Sin `usuario` el comportamiento es idéntico |
| `SCA2_obtenerDatosCabecera` | Expression Rule | `…_20053304` | v5 → **v6** | Rama «sin fila vigente»: si `cons!SCA2_USAR_CACHE_CABECERA` y `cons!SCA2_USAR_WEBAPI_CACHE_CABECERA` e `idSolicitud` real → integración (`usuario: loggedInUser()`, `forzar: ri!forzarRefresco`); si `success` y 200 → `cast(SCAC_DS_datosCabecera, a!fromJson(body))` con `tipoClienteValor` reconstruido (`todocument(tointeger(json.datosCliente.tipoClienteValor.id))`); en cualquier otro caso → `…Live` (como hoy) |

Dependencia del usuario conectado (decisión 3): en `…Live` dependen de `loggedInUser()` el `nuuma` que se envía a `cargaCabecera` (carterización/propietario) y el `idUsuario` de las consultas de siniestros. Por eso el envoltorio pasa `usuario: loggedInUser()` a la Web API y ésta a `…Live(usuario)`: la fila `CACHE` se calcula con el usuario que abre la pantalla, aunque la Web API se ejecute con el usuario de servicio. `SCA2_obtenerInformacionUsuario()` (roles/perfil) sigue evaluándose con el usuario de servicio: solo se usa para el `idUsuario` de siniestros, que ya se deriva de `usuario`.

Hallazgos técnicos de la implementación:
- **`a!writeRecords` no se ejecuta en una Web API GET** (HTTP 500 en TEST con cualquier escritura, incluso `records: {}`); con **POST** funciona. Por eso Web API e integración son POST; la integración se marca de uso «consulta» (`usage = QUERY`) para poder invocarla al cargar las interfaces (el uso es independiente del método HTTP).
- La expresión de una Web API no puede superar **4.000 caracteres** → la lógica va en `SCA2_renovarCacheCabecera` y la Web API solo llama a la regla y hace el `a!writeRecords`.
- La API LCP **evalúa** la expresión de la Web API al guardarla (sin `http!request`): la expresión empieza con `if(a!isNullOrEmpty(http!request), a!httpResponse(statusCode: 204), …)` y los parámetros se leen con `index(index(http!request, "queryParameters", a!map()), "idSolicitud", "")`.
- En el JSON `tipoClienteValor` llega como `{"id": 44}` (Document); el resto de campos son texto y el `cast` al CDT los reconstruye sin pérdida.

Pruebas realizadas (sub-interruptor en `false`; la Web API probada directamente con el usuario de servicio):

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| W01 | `POST /suite/webapi/sca2-cache-cabecera?idSolicitud=15788005&numPoliza=0732000028208` (Basic, usuario de servicio) | 200 JSON = cabecera Live; fila `CACHE` creada con `validaHasta` 07:00 del día siguiente | 200 en 4,0 s, JSON completo (LAPOVA, 94516056V, HOGAR FAMILIAR…); fila id 247: `fechaCache 2026-10-21 17:10:29`, `validaHasta 2026-10-22 07:00:00`, `tipoPoliza NSE-Hogar`, `clienteCodint 418620322020` | OK | 15788005 | — | curl + `GET /record-types/{uuid}/data` | — |
| W01b | Misma llamada sin parámetros | 400 | 400 `{"error":"Parámetros idSolicitud y numPoliza obligatorios"}` | OK | — | — | curl | — |
| W08a | Misma llamada sin autenticación | 401 | 401 `APNX-1-4187-000` | OK | — | — | curl | — |
| W01c | `POST /integrations/{uuid}/test` (idSolicitud 15788005) | `success = true`, 200, body JSON | `success true`, `statusCode 200`, `Content-Type application/json`, 1.420 bytes, 4,5 s | OK | 15788005 | — | LCP | Antes de fijar `bodyType` fallaba con «MIME type may not be blank» |
| W07 | Regresión envoltorio v6 (sub-interruptor false) vs `…Live` v2, `POST /expression-rules/{uuid}/test` | salida idéntica | 0 diferencias en 47/47/55 campos (Autos 15787499, wAutemis 15787668, Hogar 15788005 —ésta servida desde la fila 247 en 0,9 s—) | OK | 15787499 / 15787668 / 15788005 | — | LCP | — |
| W00 | Regresión `…Live` v2 sin `usuario` vs v1 | idéntica | misma salida que la regresión anterior (0 diferencias en las 3 solicitudes) | OK | ídem | — | LCP | — |

Seguridad del objeto Web API aplicada (`PUT /objects/{uuid}/security`): rol *Administrator* = grupo administrador de la aplicación SCA2 (`_e-0000f069-4e92-8000-9c18-01075c01075c_8069`, 3 miembros, incluye el usuario de servicio); *Editor* y *Viewer* vacíos (se retiró el grupo *Viewer* de la aplicación, que incluye a los usuarios de negocio). Comprobado: el usuario de servicio sigue obteniendo 200; sin autenticación 401; un usuario que no sea administrador de la aplicación no tiene permiso sobre el objeto (pendiente de comprobar con un usuario de negocio real en W08b, no dispongo de credenciales de negocio).

Pendiente (esperando OK del coordinador tras la sesión H): poner `SCA2_USAR_WEBAPI_CACHE_CABECERA = true`, simplificar «Actualizar datos» (quitar su `a!writeRecords`: con `forzarRefresco: true` la regla ya renueva vía Web API) y pruebas W02–W06, W08b, W09, W10 en UI.
