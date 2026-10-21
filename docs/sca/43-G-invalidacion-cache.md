# 43-G — Invalidación de la caché de cabecera al cambiar el estado (sesión G, fase 1)

Entorno: **Appian TEST** (`mapfrespain-test`), aplicación `SCA2 Sistema Comercial de Anulaciones SCA2` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`). Fecha: 2026-10-21. Todo el trabajo Appian se ha hecho con la API LCP REST (`/objects`, `/process-models/{uuid}`, `/expression-rules`, `/expression-rules/{uuid}/test`, `/expression-rules/{uuid}/test-cases[/run]`, `/record-types/{uuid}/data`), porque el MCP de Appian no arranca en la sesión. La API de PM no devuelve `versionId`; se anota la fecha de lectura/escritura.

## 1. Objetivo

La caché de la cabecera (doc 43-D) sirve la fila `SCA2 Datos Cabecera` con `origenCache = "CACHE"` mientras `validaHasta > now()`. Falta que, cuando un comando cambie el estado de la solicitud/póliza, esa fila deje de ser válida para que la siguiente apertura del Detalle recargue en vivo (y la regenere). Esta sesión implementa la propuesta de 43-D §8 **sin borrar la fila**, **sin tocar filas sin `origenCache = "CACHE"`** y condicionada a `cons!SCA2_USAR_CACHE_CABECERA` (con la constante en `false` los PM se comportan exactamente como antes).

## 2. Diseño

Un único patrón, el mismo en todos los nodos: **se añade un elemento al array `Records` del nodo *Write Records* que ya escribe el cambio de estado**:

```
, rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)
```

La regla devuelve la lista de filas CACHE vigentes de la solicitud con `validaHasta = now()`, o `{}` si no procede. Appian aplana las listas, de modo que `{'SCA2 Solicitud'(...), 'SCA2 Transicion'(...), {}}` escribe lo mismo que hoy. Es el mismo recurso que los PM ya usan (`if(a!isNotNullOrEmpty(pv!idTarea), 'SCA2 Tarea'(...), {})` en `SCA2 CMD Mecanizar` nodos 13 y 306). Ventajas frente a un nodo nuevo: sin nodos ni conexiones nuevas, misma transacción de escritura que el cambio de estado, y una sola línea por nodo que se puede revertir borrando ese elemento.

### 2.1 Regla nueva `SCA2_invalidarCacheCabecera`

| Campo | Valor |
|---|---|
| UUID | `_a-0000f093-2064-8000-9d36-011c48011c48_5605449` |
| Carpeta | `SCA2 Rules and Constants` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050135`), asociada a la app SCA2 |
| Entrada | `idSolicitud` (Text; es el tipo de `pv!idSolicitud` en los CMD y del campo `idSolicitud` del record, `VARCHAR`) |
| Salida | lista de `SCA2 Datos Cabecera` (`id`, `validaHasta = now()`) o `{}` |
| Versión | 1 |

```
=a!localVariables(
  /* [SCA2] Invalidación de la caché de cabecera (doc 43-G).
     Devuelve la lista de filas CACHE vigentes de la solicitud con validaHasta = now(),
     pensada para añadirse como último elemento del array Records de un nodo Write Records.
     Devuelve {} (no añade nada al Write) si cons!SCA2_USAR_CACHE_CABECERA está en false,
     si idSolicitud está vacío o es "0", o si no hay fila CACHE vigente.
     Nunca inserta ni borra filas; nunca toca filas sin origenCache = "CACHE". */
  local!idSolicitud: tostring(a!defaultValue(ri!idSolicitud, "")),
  local!activo: and(
    a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false),
    a!isNotNullOrEmpty(ri!idSolicitud),
    local!idSolicitud <> "",
    local!idSolicitud <> "0"
  ),
  if(
    not(local!activo),
    {},
    a!localVariables(
      local!filas: a!defaultValue(
        index(
          a!queryRecordType(
            recordType: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera',
            fields: {
              'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id',
              'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta'
            },
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{09dabc7f-a0c8-468c-9b60-085a8a9bd1cc}idSolicitud', operator: "=", value: local!idSolicitud),
                a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{81701765-3488-401d-9169-822a28ca8451}origenCache', operator: "=", value: "CACHE"),
                a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta', operator: "not null"),
                a!queryFilter(field: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta', operator: ">", value: now())
              }
            ),
            pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 10),
            fetchTotalCount: false
          ),
          "data",
          {}
        ),
        {}
      ),
      a!forEach(
        items: local!filas,
        expression: 'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera'(
          'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id': fv!item['recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{6757400e-5b8a-42fb-874b-19e5fbd8edbc}id'],
          'recordType!{04f597de-5acd-45b2-9ab3-277713cd00a6}SCA2 Datos Cabecera.fields.{c2c91c9b-df4f-4a96-96fc-1dcf1e6902bf}validaHasta': now()
        )
      )
    )
  )
)
```

Comportamiento:
- Constante en `false`, `idSolicitud` nulo/vacío/`"0"` o sin fila `CACHE` con `validaHasta > now()` → `{}` (el Write no cambia).
- Con fila(s) vigente(s) → una actualización por fila con solo `id` y `validaHasta`; no inserta, no borra, no toca las filas sin `origenCache = "CACHE"` ni las ya caducadas.
- Tolerancia a errores: SAIL no tiene «try/catch»; la regla solo evalúa null-safety (`a!defaultValue`, `a!isNotNullOrEmpty`) y una consulta de lectura al mismo origen de datos (BD Appian) en el que el nodo escribe `SCA2 Solicitud`; si ese origen no respondiera, el nodo fallaría igualmente por su propia escritura. No llama a servicios externos.
- El campo `idSolicitud` del record es texto; la comparación se hace con `tostring` (no `tointeger`) para no fallar con valores no numéricos.

Casos de prueba nativos (`POST /expression-rules/{uuid}/test-cases`, ejecutados con `/test-cases/run`: **5/5 OK**):

| Caso | Entrada | Aserción | Resultado |
|---|---|---|---|
| T01 | `""` | `{}` | OK |
| T02 | `"0"` | `{}` | OK |
| T03 | `"999999999"` (sin fila) | `{}` | OK |
| T04 | `null` | `{}` | OK |
| T05 | `"G-TEMP-1"` (fila CACHE temporal `id 239`, `validaHasta` 2026-10-23 07:00, insertada por API y borrada al terminar) | `a!isNullOrEmpty(test!output)` o 1 fila con `validaHasta <= now()` | OK (1 fila, `validaHasta 2026-10-21 12:37:28`) |

Prueba manual por `/test` (solo lectura, no escribe): `"G-TEMP-1"` → 1 registro `{id: 239, validaHasta: 2026-10-21 12:36:21}`; `"15788215"` (fila CACHE real `id 238`) → 1 registro `{id: 238, validaHasta: 12:36:22}`; `""` y `"999999999"` → `[]`. Tipo devuelto `List of SCA2 Datos Cabecera`.

### 2.2 PM modificados (PUT 2026-10-21 ≈12:40 UTC; relectura por GET: mismo número de nodos, sin nodos nuevos, variables de proceso idénticas, y en los nodos indicados solo cambia `data.inputs[Records].expression` con el sufijo anotado)

| PM | UUID | Nodo(s) tocado(s) | Qué escribe el nodo |
|---|---|---|---|
| `SCA2 CMD Finalizar` | `0000f06f-1309-8000-65b3-7f0000014e7a` | [8] «Write FINALIZADA» | `estadoSolicitud = pv!estadoFinal` (FINALIZADA/…) + Transición |
| `SCA2 CMD Caducar` | `0000f06f-4f07-8000-670d-7f0000014e7a` | [6] «Write Caducada» | `estadoSolicitud = CADUCADA` + Transición (antes de la llamada CORE «Finalizar Solicitud», que en TEST devuelve 500/0999; no se toca) |
| `SCA2 CMD Mecanizar` | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | [13] «Write Éxito», [306] «Write Mecanización OK», [5] «Write Caducada» | MECANIZADA tras Guardar Mecanización/Crear Autorización en CORE; `mecanizacionRealizada = true` tras Actualizar Mecanización (ANL); CADUCADA |
| `SCA2 CMD CompletarAccion` | `0000f06f-1307-8000-65b1-7f0000014e7a` | [340] «Write FINALIZADA_POSITIVO / CANCELADA», [7] «Write PDTE_FINALIZAR» | Cierre tras «Finalizar Solicitud» CORE OK; CA cancelada → PDTE_FINALIZAR (arranca Finalizar) |

No se tocan: [9] «Write AUTORIZACION» ni [330] «Write Transicion OK» de CompletarAccion (solo `procesoActivo`/Transición), [12] «Write Error» de Mecanizar, ni ningún otro nodo.

### 2.3 PM de la lista que NO se tocan (justificación aceptada en el HITO 1)

- `SCA2 CMD Decidir` (`0000f06f-0eab-8000-6595-7f0000014e7a`; nodos [9]/[10] «Write Decidida», [13] «Write Destino Mecanizar») y `SCA2 CMD CrearAccion` (`0000f06f-0eaa-8000-6594-7f0000014e7a`; nodos [7] EN_ACCION, [9] PDTE_MECANIZAR, [11] Nivel, [13] FIN): cambian el estado interno de la solicitud (DECIDIDA → EN_ACCION), pero se ejecutan **encadenados inmediatamente después del Alta** (Alta → Decidir → CrearAccion). Invalidar ahí dejaría caducada la fila CACHE segundos después de escribirla, y la caché nunca serviría la primera apertura del Detalle, que es su objetivo. Además no cambian en CORE nada que afecte a los campos cacheados (cliente/póliza/contacto): el alta de gestión CORE no modifica la póliza. Si más adelante se quiere, el patrón es el mismo (una línea por nodo).
- `SCA2 CMD BarridoCaducidad`: fuera de alcance (propuesta pendiente en 43-A §11).

### 2.4 SAIL antes/después por nodo

#### SCA2 CMD Finalizar — nodo [8] «Write FINALIZADA» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 3058 caracteres):

```
…-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now())}
```

Después (3121 caracteres; solo cambia el cierre del array):

```
…be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now()), rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)}
```

#### SCA2 CMD Caducar — nodo [6] «Write Caducada» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 2544 caracteres):

```
…-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now())}
```

Después (2607 caracteres; solo cambia el cierre del array):

```
…be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now()), rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)}
```

#### SCA2 CMD Mecanizar — nodo [13] «Write Éxito» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 5220 caracteres):

```
…-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now())}
```

Después (5283 caracteres; solo cambia el cierre del array):

```
…be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now()), rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)}
```

#### SCA2 CMD Mecanizar — nodo [306] «Write Mecanización OK» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 4488 caracteres):

```
…20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now())
}
```

Después (4552 caracteres; solo cambia el cierre del array):

```
…-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now())
, rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)
}
```

#### SCA2 CMD Mecanizar — nodo [5] «Write Caducada» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 2956 caracteres):

```
…-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now())}
```

Después (3019 caracteres; solo cambia el cierre del array):

```
…be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now()), rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)}
```

#### SCA2 CMD CompletarAccion — nodo [340] «Write FINALIZADA_POSITIVO / CANCELADA» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 1339 caracteres):

```
…27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo': null())}
```

Después (1402 caracteres; solo cambia el cierre del array):

```
…8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo': null()), rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)}
```

#### SCA2 CMD CompletarAccion — nodo [7] «Write PDTE_FINALIZAR» (internal3.write_records_to_source_23r3)

Antes (final del array `Records`, 1204 caracteres):

```
…fed-074610396bed}procesoActivo': index(index(pv!sol,"estado",null),"procesoActivo",null))}
```

Después (1267 caracteres; solo cambia el cierre del array):

```
…-4e45-8fed-074610396bed}procesoActivo': index(index(pv!sol,"estado",null),"procesoActivo",null)), rule!SCA2_invalidarCacheCabecera(idSolicitud: pv!idSolicitud)}
```


## 3. Pruebas

Formato: `ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa`.

### 3.1 Regla (API)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa |
|---|---|---|---|---|---|---|---|---|
| R01 | T01–T05 casos nativos | 5/5 | 5/5 `success` | OK | G-TEMP-1 (fila temporal) | — | `POST /test-cases/run` | — |
| R02 | `/test` con fila CACHE real vigente (solo lectura) | 1 registro con `validaHasta` = ahora | `id 238`, `validaHasta 12:36:22` | OK | 15788215 | — | `POST /test` | — |

### 3.2 PM desde la UI (solicitudes nuevas)

Pruebas ejecutadas desde la UI del sitio SCA2 (`/suite/sites/sca2`) y, para los PM sin disparador de UI, desde la monitorización del diseñador de procesos (arranque para depuración → Propiedades → Variables → nodo «Cargar» → Iniciar; es el mismo método que usó la sesión A). Comprobaciones por API con `GET /record-types/{uuid}/data` (fechas en UTC) y hora del servidor (`Date`). Constante `SCA2_USAR_CACHE_CABECERA` en **true** durante todas estas pruebas. Solicitudes nuevas de esta sesión: **15788217** (póliza 2002600009083) y **15788220** (póliza 2002600009084); la póliza 2002600009082 fue rechazada en el alta («no es una póliza válida o no se encuentra disponible»).

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa |
|---|---|---|---|---|---|---|---|---|
| S0 | Alta + primera apertura del Detalle crean la fila CACHE | fila `origenCache = CACHE`, `validaHasta` 22/10 07:00 | 15788217 → fila **241** (`fechaCache` 12:44:44); 15788220 → fila **243** (`fechaCache` 12:52:14) | OK | 15788217 / 15788220 | Alta 15418233 / 16444212 | Alta desde la UI → Detalle → GET | — |
| S1 | `SCA2 CMD CompletarAccion` nodo [7] «Write PDTE_FINALIZAR»: RETOMAR → argumento negativo → plantilla → FINALIZAR | fila 241 con `validaHasta <= ahora`, misma fila, misma `fechaCache` | `validaHasta` **12:48:09** ≤ servidor 12:48:17; `fechaCache` 12:44:44 conservada; transición 1572 EN_ACCION → DECIDIR; después `Decidir` (10154236) la encaminó a MECANIZAR/VERTI (no a `CMD Finalizar`) | OK | 15788217 | CompletarAccion 10154235 | UI → GET | — |
| S1-R | Siguiente apertura del Detalle recarga en vivo y regenera | Detalle sin error; misma fila, `fechaCache` nueva, `validaHasta` 22/10 07:00 | Al volver al Detalle la fila 241 se regeneró sola (`fechaCache` 12:48:33) y con «Actualizar datos» otra vez (12:49:06); `validaHasta` 22/10 07:00 | OK | 15788217 | — | Detalle → «Actualizar datos» → GET | — |
| S2 | `SCA2 CMD CompletarAccion` nodo [340] «Write FINALIZADA_POSITIVO / CANCELADA»: RETOMAR → CANCELAR → ACEPTAR | fila 243 con `validaHasta <= ahora`, misma fila | `validaHasta` **12:54:53** ≤ servidor 12:55:00; `fechaCache` 12:52:14 conservada; transición 1580 EN_ACCION → CANCELADA OK; solicitud CANCELADA / FIN | OK | 15788220 | CompletarAccion 16444220 | UI → GET | — |
| S2-R | Reapertura y regeneración | Detalle sin error; con «Actualizar datos» misma fila regenerada | Reapertura sin error (la fila siguió caducada: el Detalle cargó en vivo); «Actualizar datos» → `fechaCache` 12:55:48, `validaHasta` 22/10 07:00 | OK | 15788220 | — | Detalle → GET → «Actualizar datos» → GET | — |
| P1 | `SCA2 CMD Finalizar` nodo [8] «Write FINALIZADA» (arranque desde el diseñador con `idSolicitud` 15788217, `estadoFinal` FINALIZADA) | fila 241 con `validaHasta <= ahora`; solicitud FINALIZADA | «Write FINALIZADA» ejecutado, End 13:17:11; `validaHasta` **13:17:10** ≤ servidor 13:17:39; `fechaCache` 12:49:06 conservada; FINALIZADA v7; transición 1582 OK (PCA respondió `true`) | OK | 15788217 | Finalizar 12248097 | Depuración → Variables → «Cargar» → Iniciar → GET | — |
| P2 | `SCA2 CMD Caducar` nodo [6] «Write Caducada» (arranque desde el diseñador con `idSolicitud` 15788220; `caducidadTarea` puesta a 20/10 para entrar por «Caducada») | fila 243 con `validaHasta <= ahora`; CADUCADA; después error CORE esperado | «Write Caducada» ejecutado; `validaHasta` **13:20:12** ≤ servidor 13:20:40; `fechaCache` 12:55:48 conservada; CADUCADA v6; transición 1583 OK; CORE «Finalizar Solicitud» 500/0999 → Write Error → End 13:20:15 | OK | 15788220 | Caducar 13307577 | Depuración → Variables → «Cargar» → Iniciar → GET | Error CORE TEST conocido (43-A), no se arregla |
| S3 | `SCA2 CMD Mecanizar` nodos [13]/[306]/[5] | — | **No probado**: la única ruta de UI (gestión VERTI de 15788217) exige alta de gestión en CORE | No probado | 15788217 | — | — | Restricción de la tarea |
| X1 | Arranque para depuración sin parámetros (exploración del método) | — | `SCA2 CMD Finalizar` arranca sin pedir variables y falla en «Cargar» (`a!queryFilter` con valor nulo); se reutilizó la instancia fijando las variables e «Iniciar» sobre «Cargar» (la ejecución anterior pasa a Cancelado automáticamente) | — | — | 12248097 | — | El PM no tiene formulario de inicio |

Nota: tras cada invalidación la **misma** fila sigue existiendo (ids 241 y 243; ninguna fila borrada; total de filas 228 → 232 solo por las altas nuevas de la tarde) y ninguna fila sin `origenCache = "CACHE"` cambió.

### 3.3 Regresión con la constante en `false`

Constante puesta en **false** solo durante cada intento y devuelta a **true** verificando por GET (`/constants/_a-0000f093-2064-8000-9d36-011c48011c48_5603399`): v15 false (13:23) → v16 true (13:28) → v17 false (13:28) → v18 true (13:33) → v19 false (13:33) → **v20 true (13:37 UTC, verificada: `value: 1`)**.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos | Causa |
|---|---|---|---|---|---|---|---|---|
| R1a | `SCA2 CMD Caducar` con constante false (v15), fila 243 vigente | PM igual que hoy; fila intacta | Salió por «¿Ya ejecutado?» (idempotencia: ya existía la transición 1583 OK); fila intacta pero sin ejecutar «Write Caducada» | Inconcluso | 15788220 | 10154347 | Depuración → Variables → Iniciar → GET | Idempotencia del CMD |
| R1b | Ídem con `version` de la solicitud subida a 7 (v17) | ídem | Misma salida «¿Ya ejecutado?» (la clave `SCA2 CMD Caducar|15788220|1` no depende de `version`) | Inconcluso | 15788220 | 537551372 | ídem | Idempotencia |
| **R1** | Ídem con la clave de la transición 1583 renombrada (`…|G-R1`), constante false (v19) | «Write Caducada» ejecutado, transición OK nueva, error CORE esperado; **fila 243 intacta** | «Write Caducada» 13:35:35; transición **1587 OK**; CORE 500/0999 → Write Error → End 13:35:39; fila 243 **sin cambios** (`validaHasta` 22/10 07:00, `fechaCache` 12:55:48); solicitud v8 | **OK** | 15788220 | Caducar 679182 | GET constante = 0 → depuración → Variables → «Cargar» → Iniciar → GET | — |
| R2 | Regla con constante false (`/test` y casos nativos T01–T05) | `{}` | `[]` en todos los casos | OK | — | — | `POST /test` | — |

Datos de prueba manipulados por API (solo filas de las solicitudes de esta sesión): `SCA2 Solicitud` id 268 (15788220): `caducidadTarea` → 2026-10-20 00:00:00 y `version` 6 → 7; `SCA2 Transicion` id 1583: `claveIdempotencia` → `SCA2 CMD Caducar|15788220|1|G-R1`; `SCA2 Datos Cabecera` id 243: `validaHasta` → 2026-10-22 07:00:00 (para dejarla vigente antes de la regresión); fila temporal `G-TEMP-1` (id 239) insertada y borrada para T05.

## 4. Pendientes

- `SCA2 CMD Mecanizar` (nodos [13], [306], [5]) no se ha podido ejecutar en TEST sin alta de gestión en CORE; el cambio es el mismo sufijo de una línea que en los otros 7 nodos (verificado por relectura de la definición) y la regla está probada, pero falta una ejecución real. Candidato: probarlo con el analista cuando haya una mecanización real en TEST.
- No se ha probado la rama de error CORE/PCA previa a «Write FINALIZADA» en `CMD Finalizar` (en la prueba PCA respondió `true`).
- Hallazgo (no es de esta sesión): la clave de idempotencia de `CMD Caducar` es `SCA2 CMD Caducar|<idSolicitud>|1` (no depende de `version`), así que un relanzamiento del CMD sobre la misma solicitud sale siempre por «¿Ya ejecutado?». Es coherente con «caducar una vez», pero conviene tenerlo en cuenta para la propuesta pendiente de 43-A §11.
- Estado dejado en TEST: 15788217 FINALIZADA (fila CACHE 241 caducada; se regenerará al abrir el Detalle), 15788220 CADUCADA (fila 243 vigente hasta 22/10 07:00); instancias de depuración con la primera ejecución de «Cargar» cancelada (12248097, 13307577, 10154347, 537551372, 679182). Constante en **true (v20)**.
- `SCA2 CMD Decidir` y `SCA2 CMD CrearAccion` sin tocar (§2.3); si se decide incluirlos, mismo patrón.
- Las grabaciones y capturas de las pruebas de UI están adjuntas en la sesión (no se suben al repo).
