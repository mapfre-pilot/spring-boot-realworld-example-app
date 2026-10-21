# 43-D — Caché temporal de la cabecera de póliza/solicitud (SCA2, Appian TEST)

**Sesión D** de la fase 1 «lógica legacy en Appian» (diseño: `41-diseno-logica-appian-fase1.md` §4; reparto: `42-coordinacion-fase1.md` fila D).
Entorno: Appian TEST (`mapfrespain-test`), aplicación `SCA2 Sistema Comercial de Anulaciones SCA2` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`).

> Estado del documento: **HITO 1 alcanzado** (objetos nuevos creados y probados; análisis de cobertura hecho). Pendiente el OK del coordinador para modificar `SCA2_obtenerDatosCabecera`, el record `SCA2 Datos Cabecera` y `SCA2_DetalleSolicitud`.

## 1. Objetivo

`SCA2_obtenerDatosCabecera(numPoliza, idSolicitud)` se invoca desde 9 interfaces y desde el PM `SCA2 CMD Alta`; cada invocación dispara ~15 llamadas externas (REST `cargaCabecera`, TRON/NSE/Vida, API Clients, Estruage, productor, reserva de prima, siniestros, otras solicitudes). La pieza D guarda el resultado en el record `SCA2 Datos Cabecera` (por `idSolicitud`) y lo reutiliza hasta las **07:00 del día siguiente** a la carga, detrás del interruptor `cons!SCA2_USAR_CACHE_CABECERA` (= `false`: comportamiento idéntico al actual).

## 2. Objetos Appian (TEST)

| Objeto | Tipo | UUID | Versión | Estado |
|---|---|---|---|---|
| `SCA2_obtenerDatosCabeceraLive` | Expression Rule | `_a-0000f093-2064-8000-9d36-011c48011c48_5603393` | 1 | **Nuevo**. Copia exacta de la expresión de `SCA2_obtenerDatosCabecera` v2 (32.996 caracteres idénticos; mismos inputs `numPoliza` Text, `idSolicitud` Text) |
| `SCA2_USAR_CACHE_CABECERA` | Constante Boolean | `_a-0000f093-2064-8000-9d36-011c48011c48_5603399` | 1 | **Nuevo**. Valor `false` |
| `SCA2_HORA_CADUCIDAD_CACHE_CABECERA` | Constante Integer | `_a-0000f093-2064-8000-9d36-011c48011c48_5603405` | 1 | **Nuevo**. Valor `7` |
| `SCA2_calcularValidaHastaCache` | Expression Rule (pura) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603423` | 1 | **Nuevo**. 10 casos de prueba, 10/10 OK |
| `SCA2_obtenerDatosCabecera` | Expression Rule | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053304` | 2 (anotada, sin tocar) | Pendiente convertir en envoltorio tras el OK |
| `SCA2 Datos Cabecera` | Record Type | `04f597de-5acd-45b2-9ab3-277713cd00a6` | 1 (anotada, sin tocar) | Pendiente añadir `fechaCache`, `validaHasta`, `origenCache` |
| `SCA2_DetalleSolicitud` | Interface | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 59 (anotada, sin tocar) | Pendiente botón «Actualizar datos» |

Todos los objetos nuevos están en la carpeta `SCA2 Rules and Constants` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050135`) y asociados a la aplicación SCA2.

Nota operativa: el MCP `appian-dev-mcp-c90b` no arranca en esta sesión (el proceso no recibe `USERNAME/PASSWORD`); todo el trabajo se ha hecho con la API LCP REST (`/expression-rules`, `/constants`, `/record-types`, `/custom-data-types`, `/expression-rules/{uuid}/test-cases`).

## 3. SAIL de las reglas nuevas

### 3.1 `SCA2_obtenerDatosCabeceraLive(numPoliza: Text, idSolicitud: Text)`

Copia literal de `SCA2_obtenerDatosCabecera` v2 (no se reproduce aquí por tamaño; verificada igualdad carácter a carácter salvo el `=` inicial que añade el almacenamiento). Devuelve `SCAC_DS_datosCabecera` o `null` si `numPoliza` está vacío.

### 3.2 `SCA2_calcularValidaHastaCache(fechaHoraCarga: Date and Time, hora: Number (Integer)) → Date and Time`

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

Semántica: siempre «el día siguiente» a la fecha de carga a la hora indicada (una carga a las 03:00 caduca a las 07:00 del día siguiente, no del mismo día, tal como fija el diseño 41 §4). `hora` nula → `cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA`. `fechaHoraCarga` nula → `null`.

### 3.3 Casos de prueba (`a!test`, ejecutados en TEST el 2026-10-21)

| ID | Caso | fechaHoraCarga | hora | Esperado | Real | OK/KO |
|---|---|---|---|---|---|---|
| T01 | Carga de día tras las 07:00 | 2026-10-21 10:30:00 | 7 | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK |
| T02 | Carga de madrugada antes de las 07:00 | 2026-10-21 03:15:00 | 7 | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK |
| T03 | Carga junto a medianoche | 2026-10-21 23:59:59 | 7 | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK |
| T04 | Carga justo a las 00:00:00 | 2026-10-22 00:00:00 | 7 | 2026-10-23 07:00:00 | 2026-10-23 07:00:00 | OK |
| T05 | Cambio de mes | 2026-10-31 12:00:00 | 7 | 2026-11-01 07:00:00 | 2026-11-01 07:00:00 | OK |
| T06 | Cambio de año | 2026-12-31 22:00:00 | 7 | 2027-01-01 07:00:00 | 2027-01-01 07:00:00 | OK |
| T07 | Cambio horario verano→invierno (25/10/2026) | 2026-10-24 20:00:00 | 7 | 2026-10-25 07:00:00 | 2026-10-25 07:00:00 | OK |
| T08 | Hora distinta | 2026-10-21 10:00:00 | 0 | 2026-10-22 00:00:00 | 2026-10-22 00:00:00 | OK |
| T09 | Hora nula usa la constante | 2026-10-21 10:00:00 | null | 2026-10-22 07:00:00 | 2026-10-22 07:00:00 | OK |
| T10 | Fecha de carga nula | null | 7 | null | null | OK |

Resultado del `run` de la API: `passCount 10, failCount 0`.

## 4. Zona horaria (UTC vs CET)

- En Appian un `Date and Time` es un instante absoluto; `datetime()`, `todate()`, `hour()` lo interpretan en la **zona horaria del contexto** (la del usuario en interfaces; la del proceso en los PM). La base de datos guarda los DateTime en GMT y Appian los convierte al leer/escribir, por lo que la comparación `validaHasta > now()` es correcta sea cual sea la zona.
- Comprobación empírica: caso temporal con `fechaHoraCarga = now()` y `hora = hour(now())` ejecutado a las 10:16 UTC devolvió `2026-10-22 10:00:00` ⇒ el usuario de servicio con el que ejecuta la API (y por tanto los tests) está en **UTC**. Un usuario de negocio con zona `Europe/Madrid` obtendría «07:00 Madrid» (= 05:00 UTC en invierno, 06:00 UTC en verano).
- Consecuencia: el «07:00» se calcula en la zona de quien dispara la carga. En interfaz (usuarios de España) es exactamente lo que pide el diseño. Si la carga la hace el PM `SCA2 CMD Alta`, se usa la zona del proceso (zona primaria del sitio; no he podido leerla por API).
- **Decisión que pido al coordinador**: (a) aceptar la zona de contexto (recomendado: los usuarios de SCA2 están en España y las cargas vía PM se refrescan igualmente al día siguiente), o (b) fijar `Europe/Madrid` dentro de la regla con `gmt()/local()` + id de zona (añade complejidad y un segundo juego de tests). La implementación actual es (a).

## 5. Cobertura: salida actual vs. record `SCA2 Datos Cabecera` (44 campos)

Salida de la regla: CDT `SCAC_DS_datosCabecera` = `datosCliente` (`SCAC_DS_datosCliente`, 14 campos), `datosPoliza` (`SCAC_DS_datosPoliza`, 20 campos), `otrasSolicitudesCabecera` (lista de `mssConsultarSolicitudesDTO`), `datosContacto` (`SCAC_DS_datosContacto`, 13 campos).

| Elemento de la salida | En el record | Observación / propuesta |
|---|---|---|
| `datosCliente.*` (14 campos) | Sí, 14/14 (`cliente*`) | `tipoClienteValor` es **Document** en el CDT (icono devuelto por `SCA2_obtenerIconoClienteValor`) y `clienteTipoclientevalor` es TEXT: se guardará el id del documento como texto y se reconstruirá con `todocument()`. |
| `datosPoliza.*` 16 campos | Sí (`poliza*`) | — |
| `datosPoliza.ramo`, `cesionDeDerechos`, `revalorizacion` | **No** | Solo se rellenan para pólizas de Vida (`local!polizaVida`); en el resto son `""`. Propuesta: añadir 3 campos TEXT `polizaRamo`, `polizaCesionderechos`, `polizaRevalorizacion` (misma tabla Aurora). |
| `datosPoliza.sobrePrimas_SobreRiesgos` | **No** | La regla **nunca lo asigna** (siempre nulo). No hace falta campo. |
| `datosContacto.*` 12 campos | Sí (`contacto*`) | — |
| `datosContacto.pais` | **No** | Solo Vida. Propuesta: añadir campo TEXT `contactoPais`. |
| `otrasSolicitudesCabecera` (lista) | **No** | Proviene de `SCA2_consultarSolicitudes` (1 llamada, se excluye la propia solicitud). Opciones: (i) **dejarla en vivo** dentro del envoltorio (1 llamada en lugar de ~15; recomendado, además refleja solicitudes creadas hoy), o (ii) guardarla serializada en un campo EXTRA_LONG_TEXT `otrasSolicitudesJson`. |

Hallazgos adicionales relevantes para el envoltorio:
- El record tiene PK `id` (autogenerado) y `idSolicitud` **no es única**: `SCA2 CMD Alta` (sesión A) inserta su propia fila con solo 9 campos (`idSolicitud`, `clienteNombre/Apellidos/Nif`, `polizaNumeropoliza/Nombreproducto/Fechavencimiento/Lineanegocio/Formapago`) después de llamar a la regla. El envoltorio debe: consultar por `idSolicitud` **y** `validaHasta` no nulo y `> now()`, ordenar por `fechaCache` desc y usar la primera; al refrescar, actualizar la fila propia (por `id`) si existe y si no insertar. Las filas sin `validaHasta` (las del alta actual y las 206 existentes) nunca se consideran caché válida ⇒ sin cambio de comportamiento.
- `SCA2_obtenerEstadoPoliza` y `SCA2_consultarAnulacionPoliza` **no** se invocan dentro de `SCA2_obtenerDatosCabecera` (0 apariciones en la expresión): no quedan cacheadas.

## 6. Diseño del envoltorio (a implementar tras el OK)

```text
SCA2_obtenerDatosCabecera(numPoliza, idSolicitud, forzarRefresco?)
  si not(cons!SCA2_USAR_CACHE_CABECERA) o idSolicitud nulo/"0" o numPoliza vacío
      → rule!SCA2_obtenerDatosCabeceraLive(numPoliza, idSolicitud)
  si no:
      fila := query SCA2 Datos Cabecera where idSolicitud = ri!idSolicitud and validaHasta > now(), order fechaCache desc, 1
      si fila existe y not(forzarRefresco) → reconstruir SCAC_DS_datosCabecera desde la fila (+ otrasSolicitudesCabecera en vivo, ver §5)
      si no → live := …Live(); upsert fila (44 campos + fechaCache=now(), validaHasta=SCA2_calcularValidaHastaCache(now(), cons!…HORA…), origenCache="LIVE"); devolver live
```

Campos nuevos del record: `fechaCache` DATETIME, `validaHasta` DATETIME, `origenCache` TEXT (y, si se aprueba §5, `polizaRamo`, `polizaCesionderechos`, `polizaRevalorizacion`, `contactoPais` TEXT). Se intentará vía API (`POST /record-types/{uuid}/fields` con `updateTable=true`); si la tabla no admite el cambio se generará `docs/sca/sql/43-D-cabecera.sql` y se parará.

## 7. Invalidación (propuesta, sin tocar objetos ajenos)

- `SCA2_DetalleSolicitud`: botón «Actualizar datos» que pone `forzarRefresco: true` en la llamada existente (`local!estructuraCabecera`, `a!refreshVariable`).
- CMD que cambian el estado de la póliza/solicitud y deberían poner `validaHasta = now()` en la fila de `SCA2 Datos Cabecera` de la solicitud (lo asigna el coordinador): se detallará tras el OK.

## 8. Pendientes

- OK del coordinador (HITO 1) y decisiones de §4 y §5.
- Modificar record, envoltorio e interfaz; pruebas comparadas (5 pólizas), tiempos, caducidad, `forzarRefresco`; reservas en `pruebas/coordinacion-fase1.md`.
