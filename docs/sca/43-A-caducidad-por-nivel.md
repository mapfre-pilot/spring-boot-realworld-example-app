# 43-A — Caducidad por nivel de intervención (SCA2, Appian TEST)

**Sesión A** de la fase 1 «lógica legacy en Appian» (diseño: `41-diseno-logica-appian-fase1.md` §1; reparto: `42-coordinacion-fase1.md` fila A).
Entorno: Appian TEST (`mapfrespain-test`), aplicación `SCA2 Sistema Comercial de Anulaciones SCA2` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`).

> Estado del documento: **HITO 1 alcanzado** (constantes, regla y pruebas creadas y ejecutadas; estado actual de los PM verificado leyendo su definición). Pendiente el OK del coordinador para modificar los PM `SCA2 CMD Alta`, `SCA2 CMD CrearAccion`, `SCA2 CMD CambiarNivel`, `SCA2 CMD Posponer` y la regla `SCA2_cargarSolicitud`.
>
> Nota de método: el MCP `appian-dev-mcp-c90b` no arranca en esta sesión (faltan credenciales en su entorno), así que todo el trabajo Appian se ha hecho con la API LCP REST (`/objects`, `/process-models/{uuid}`, `/expression-rules/{uuid}`, `/constants`, `/expression-rules/{uuid}/test-cases`, `/expression-rules/{uuid}/test-cases/run`, `/expression-rules/{uuid}/test`). La API de PM no devuelve `versionId`; se anota la fecha de lectura.

## 1. Criterio funcional aprobado

La caducidad pertenece al **nivel de intervención**, no a la tarea:

- Se fija al **entrar en un nivel** (alta → N1; salto a N2/N3/N4): `hoy + 14` si el gestor es propietario de la póliza, `hoy + 7` si no.
- Nunca es posterior a la **fecha de vencimiento** de la póliza: si `hoy + N >= vencimiento`, caduca en el vencimiento.
- Mientras la solicitud siga en el mismo nivel, las tareas (capturar, posponer, crear acción, contacto…) **no la recalculan**.
- Si llega la fecha sin finalizar ni cambiar de nivel, `SCA2 CMD Caducar` la caduca y finaliza como `FINALIZADO_CADUCADO`.
- Sin fecha de vencimiento la regla devuelve `null` (equivale al `ERROR` del servicio legacy); el llamador conserva lo que hace hoy.

Es la única pieza de la fase 1 que cambia comportamiento visible (aprobado).

## 2. Objetos Appian (TEST)

### 2.1 Nuevos (creados en esta sesión)

| Objeto | Tipo | UUID | Versión | Estado |
|---|---|---|---|---|
| `SCA2_DIAS_CADUCIDAD_PROPIETARIO` | Constante Integer | `_a-0000f093-2064-8000-9d36-011c48011c48_5603454` | 2 | **Nuevo**. Valor `14` (v2 solo corrige la descripción) |
| `SCA2_DIAS_CADUCIDAD_NO_PROPIETARIO` | Constante Integer | `_a-0000f093-2064-8000-9d36-011c48011c48_5603464` | 1 | **Nuevo**. Valor `7` |
| `SCA2_calcularCaducidadNivel` | Expression Rule (pura) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603490` | 1 | **Nuevo**. 10 casos de prueba nativos, 10/10 OK |
| `SCA2_calcularCaducidadNivel_test` | Expression Rule (sin entradas) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603502` | 1 | **Nuevo**. Batería autocontenida: devuelve `total/ok/ko` y la lista de casos; 10/10 OK |

Todos en la carpeta `SCA2 Rules and Constants` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050135`) y asociados a la aplicación SCA2. Las constantes se han creado como constantes normales (la API LCP no expone el marcador «por entorno»); si se exige el marcador, se activa desde el diseñador sin cambiar el valor.

### 2.2 Existentes (versión anotada, **sin tocar** hasta el OK)

| Objeto | Tipo | UUID | Versión / lectura | Papel |
|---|---|---|---|---|
| `SCA2 CMD Alta` | Process Model | `0000f06f-28fc-8000-6693-7f0000014e7a` | leído 2026-10-21 | Entrada en N1 |
| `SCA2 CMD CrearAccion` | Process Model | `0000f06f-0eaa-8000-6594-7f0000014e7a` | leído 2026-10-21 | Salto de nivel (IR A NIVEL N / NO_MECANIZAR) y escritura actual de `caducidadTarea` |
| `SCA2 CMD CambiarNivel` | Process Model | `0000f06f-8a54-8000-6759-7f0000014e7a` | leído 2026-10-21 | Cambio manual de nivel |
| `SCA2 CMD Posponer` | Process Model | `0000f06f-8a47-8000-6751-7f0000014e7a` | leído 2026-10-21 | Escritura actual de `caducidadTarea` |
| `SCA2 CMD Decidir` | Process Model | `0000f06f-0eab-8000-6595-7f0000014e7a` | leído 2026-10-21 | No cambia nivel ni caducidad (sin cambios) |
| `SCA2 CMD Caducar` | Process Model | `0000f06f-4f07-8000-670d-7f0000014e7a` | leído 2026-10-21 | Lee `caducidadTarea` (sin cambios) |
| `SCA2 CMD BarridoCaducidad` | Process Model | `0000f06f-4f69-8000-671e-7f0000014e7a` | leído 2026-10-21 | Filtra por `caducidadTarea < now()` (sin cambios) |
| `SCA2_cargarSolicitud` | Expression Rule | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | 7 | Carga `pv!sol`; se propone ampliar `datosCabecera` (aditivo) |
| `SCA2_configurarDatosContextoSolicitud` | Expression Rule | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052669` | 1 | Inicializa `caducidadTarea: null`; sin cambios |
| `SCA2_posponerTarea` | Expression Rule | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056361` | 2 | No escribe `caducidadTarea`; sin cambios |
| `SCA2_obtenerCaducidadNivel` | Expression Rule (legacy) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051362` | 1 | Copia de SCA; se mantiene para `SCA2 Tarea.fechaCaducidad` |
| `SCA2 Solicitud` | Record Type | `c531595c-c3b5-454c-a355-8145e7e27e9a` | 1 | Campo `caducidadTarea` (Date, `d7ef3591-6cc4-4094-9ebf-878665a93660`), `nivelIntervencion` (`6da95481-…`), `fecInicioNivel` (`6117c6fa-…`), `fechaDietario` (`138ed76e-…`), `contadorPosponer` (`db73fd3a-…`) |
| `SCA2 Datos Cabecera` | Record Type (fila D, solo lectura) | `04f597de-5acd-45b2-9ab3-277713cd00a6` | 1 | `clienteCarterizado`, `clienteNuumapropietario`, `polizaFechavencimiento`, `polizaClaveproduccion` (todos VARCHAR) |

## 3. Regla nueva `SCA2_calcularCaducidadNivel`

Entradas: `propietario` (Boolean), `mismoNivel` (Boolean), `fechaCaducidadAnterior` (Date), `fechaVencimiento` (Date), `fechaBase` (Date). Salida: Date (o `null`).

```sail
/* Caducidad por nivel de intervención (fase 1 lógica legacy en Appian).
   Regla pura: sin consultas ni integraciones.
   - mismoNivel y hay fecha anterior -> se conserva la caducidad del nivel.
   - Sin fecha de vencimiento -> null (el llamador conserva su comportamiento actual).
   - Si no: fechaBase (hoy por defecto) + N días (propietario 14 / no propietario 7),
     nunca posterior a la fecha de vencimiento de la póliza. */
a!localVariables(
  local!dias: if(
    a!defaultValue(ri!propietario, false),
    cons!SCA2_DIAS_CADUCIDAD_PROPIETARIO,
    cons!SCA2_DIAS_CADUCIDAD_NO_PROPIETARIO
  ),
  local!base: todate(a!defaultValue(ri!fechaBase, today())),
  local!calculada: local!base + local!dias,
  if(
    and(
      a!defaultValue(ri!mismoNivel, false),
      a!isNotNullOrEmpty(ri!fechaCaducidadAnterior)
    ),
    todate(ri!fechaCaducidadAnterior),
    if(
      a!isNullOrEmpty(ri!fechaVencimiento),
      null,
      if(
        local!calculada >= todate(ri!fechaVencimiento),
        todate(ri!fechaVencimiento),
        local!calculada
      )
    )
  )
)
```

Funciones usadas (verificadas en la referencia de la skill): `a!localVariables`, `a!defaultValue`, `a!isNullOrEmpty`, `a!isNotNullOrEmpty`, `todate`, `today`, `if`, `and`. `today()` en TEST devuelve la fecha del servidor (UTC); al ser Date sin hora no hay desfase CET/UTC salvo entre las 00:00 y las 02:00.

### 3.1 Pruebas de la regla (fecha base fija 2026-10-21; vencimiento lejano 2027-06-30)

Ejecutadas dos veces: como **casos de prueba nativos** del objeto (`POST …/test-cases/run`, 10/10 `success`) y con la regla `SCA2_calcularCaducidadNivel_test` (`total: 10, ok: 10, ko: 0`).

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T01 | Propietario, nuevo nivel | 2026-11-04 (hoy+14) | 2026-11-04 | OK | — | — | `propietario=true, mismoNivel=false` | — |
| T02 | No propietario, nuevo nivel | 2026-10-28 (hoy+7) | 2026-10-28 | OK | — | — | `propietario=false, mismoNivel=false` | — |
| T03 | Propietario, mismo nivel con anterior 2026-10-25 | 2026-10-25 | 2026-10-25 | OK | — | — | `mismoNivel=true` | — |
| T04 | No propietario, mismo nivel con anterior 2026-10-25 | 2026-10-25 | 2026-10-25 | OK | — | — | `mismoNivel=true` | — |
| T05 | Tope por vencimiento (vence 2026-10-28, hoy+14) | 2026-10-28 | 2026-10-28 | OK | — | — | — | — |
| T06 | Sin vencimiento | null | null | OK | — | — | `fechaVencimiento=null` | — |
| T07 | Vencimiento igual a hoy+7 | 2026-10-28 | 2026-10-28 | OK | — | — | `>=` → vencimiento | — |
| T08 | Mismo nivel sin anterior | 2026-11-04 | 2026-11-04 | OK | — | — | calcula como nuevo nivel | — |
| T09 | Vencimiento ya pasado (2026-10-01) | 2026-10-01 | 2026-10-01 | OK | — | — | caducará en el primer barrido | — |
| T10 | `fechaBase` null (usa `today()`), no propietario | today()+7 | 2026-10-28 | OK | — | — | ejecutado el 2026-10-21 | — |
| T11 | Todas las entradas null (solo `/test`) | null | null | OK | — | — | sin error de evaluación | — |

## 4. Estado actual verificado (quién escribe qué)

Leído de la definición de cada PM el 2026-10-21 (ids de nodo de la API LCP):

| Objeto / nodo | Escribe en `SCA2 Solicitud` | Observación |
|---|---|---|
| `CMD Alta` · nodo 13 «Construir Contexto», 7 «Contexto» | — | Nodo 7 obtiene `pv!cab = rule!SCA2_obtenerDatosCabecera(numPoliza, idSolicitud)` (Map con `carterizado` «Sí»/«No», `nuumaPropietario`, `datosPoliza.fechaVencimiento` texto 10 car., `datosPoliza.claveProduccion`) |
| `CMD Alta` · nodo 9 «Write Solicitud» | `idSolicitud, numPoliza, estadoSolicitud="ALTA", nivelIntervencion=1, origenPoliza, lineaNegocio, canal, idioma, rol, usuario, createdAt/By, modifiedAt/By` + `SCA2 Transicion` | **No escribe** `caducidadTarea` ni `fecInicioNivel`. Nodo 206 «Write Solicitud Error» es la rama de error (mismos campos) |
| `SCA2_configurarDatosContextoSolicitud` | — | Devuelve `caducidadTarea: null, fechaDietario: null, contadorPosponer: null` (mapa de contexto; no escribe) |
| `CMD Decidir` · nodos 3 «Cargar», 5 «Consultar reglas», 31 «Write Tarea VERTI (previa)» | solo `SCA2 Tarea` en 31 | **No cambia** `nivelIntervencion` ni `caducidadTarea`. Confirmado: el salto de nivel no está aquí |
| `CMD CrearAccion` · nodo 10 «Cambio de nivel (IR A NIVEL N / NO_MECANIZAR)» | — | `pv!nuevoNivel = min(nivel+1, 3)`; `pv!destino = FIN si nivel>=3, si no DECIDIR` |
| `CMD CrearAccion` · nodo 11 «Write Nivel» | `estadoSolicitud (FIN/EN_DECISION), nivelIntervencion = pv!nuevoNivel, version+1, modifiedAt/By` | **Salto de nivel real.** No escribe `fecInicioNivel` ni `caducidadTarea` |
| `CMD CrearAccion` · nodo 7 «Write Tarea» | `estadoSolicitud="EN_ACCION", estadoTarea="PENDIENTE", caducidadTarea = rule!SCA2_obtenerCaducidadNivel(codPerfil: pv!sol.datosPerfilesPca.codperfil, mecanizar:false, fechaVencimiento: pv!sol.datosPoliza.fechaDeVencimiento, nivel: pv!sol.estado.nivelIntervencion), version+1, modifiedAt/By` + `SCA2 Tarea.fechaCaducidad` (misma regla) + `SCA2 Transicion` | **Escritura actual de `caducidadTarea`** (regla legacy: N1 → +1 día; N≥2 → +7 perfiles SI24/CE_RM, +15 resto) |
| `CMD CrearAccion` · nodo 9 «Write PDTE_MECANIZAR + Tarea» | `estadoSolicitud="PDTE_MECANIZAR", estadoTarea, version, modifiedAt/By` + `SCA2 Tarea.fechaCaducidad` | No escribe `caducidadTarea` |
| `CMD CambiarNivel` · nodo 6 «Write CambiarNivel» | `nivelIntervencion = tostring(pv!nivelDestino), fecInicioNivel = now(), grupoAsignacion, version+1, modifiedAt/By` | Cambio manual de nivel; no escribe `caducidadTarea` |
| `CMD Posponer` · nodo 5 «Write Posponer» | `fechaDietario = pv!fechaDietario, contadorPosponer = anterior+1, estadoTarea="PENDIENTE", caducidadTarea = pv!fechaDietario, …` + `SCA2 Tarea.fechaCaducidad = pv!fechaDietario` | **Escritura actual de `caducidadTarea`** (= fecha del dietario elegida por el gestor) |
| `SCA2_posponerTarea` | `contadorPosponer+1, fechaDietario = now(), modifiedAt` + `SCA2 Tarea.fechaCaducidad` (regla legacy nivel 2) | No escribe `caducidadTarea` (difiere de lo indicado por el coordinador: `fechaDietario = now()` sí, `caducidadTarea` no) |
| `CMD Caducar` · nodo 4 «¿Caducada?» | — | `now() >= a!defaultValue(sol.estado.caducidadTarea, a!defaultValue(sol.estado.fechaDietario, now()+1))` → **sí lee `caducidadTarea`**; nodo 6 «Write Caducada» (`estadoSolicitud="CADUCADA"`, observación), nodo 7 integración «Finalizar Solicitud», nodo 5 «Write Skip» (idempotencia por nivel) |
| `CMD BarridoCaducidad` · nodo 6 «Obtener caducadas» | — | `caducidadTarea < now()` y `estadoSolicitud` no en {FINALIZADA, CADUCADA, ERROR} → lanza `CMD Caducar` por solicitud |

Dónde está el dato «propietario» y «vencimiento» hoy:

- En el alta (`pv!cab`, salida de `SCA2_obtenerDatosCabecera`): `carterizado` («Sí»/«No»), `nuumaPropietario`, `datosPoliza.fechaVencimiento` (texto, 10 caracteres: TRON `FEC_VCTO_PER` / NSE `fecvctopoliza` / Vida `contractData.duedate`), `datosPoliza.claveProduccion`.
- Tras el alta (`pv!sol`, salida de `SCA2_cargarSolicitud`): `datosCabecera.polizaFechavencimiento` (texto), `datosPoliza.fechadevencimiento` (texto; Autos/Hogar/Vida), `datosPerfilesPca.nuuma` y `codperfil`. `datosCabecera` **no** expone hoy `clienteCarterizado`, `clienteNuumapropietario` ni `polizaClaveproduccion` (están en el record, no en el mapa).
- `rule!SCA2_nuumaEsPropietario(codCia, nuuma, claveProd)` se usa hoy en `SCA2_ContraAnulacionOpciones` con `codCia: "41"`, `nuuma` del usuario conectado y `claveProduccion` de `datosPolizaAutos/Hogar/Vida`; llama a CORE (`SCA2_consultaPropiedadClave`).

## 5. Plan de cambios por nodo (aprobado en el HITO 1; implementación en §8)

Convención común: `local!venc = todate(<texto vencimiento>)` protegido con `a!isNullOrEmpty` → `null`; propietario provisional = `or(carterizado = "Sí", rule!SCA2_nuumaEsPropietario(codCia: "41", nuuma: <NUUMA gestor>, claveProd: <clave producción>))`, también protegido (si falta clave o NUUMA → solo `carterizado`). Cuando la sesión B entregue `SCA2_esPropietarioPoliza` se sustituye esa expresión en los tres puntos (Alta, CrearAccion, CambiarNivel).

| # | Objeto · nodo | Cambio | Resultado |
|---|---|---|---|
| A1 | `CMD Alta` · nueva PV `caducidadNivel` (Date) | Variable de proceso para dejar trazable la fecha calculada en la instancia | — |
| A2 | `CMD Alta` · nodo 7 «Contexto» | Nueva salida: `pv!caducidadNivel = rule!SCA2_calcularCaducidadNivel(propietario: <provisional con pv!cab.carterizado, pv!cab.nuumaPropietario / rule!SCA2_nuumaEsPropietario(codCia:"41", nuuma: rule!CMP_obtenerNuuma(user(pp!initiator,"email")), claveProd: pv!cab.datosPoliza.claveProduccion)>, mismoNivel: false, fechaCaducidadAnterior: null, fechaVencimiento: todate(pv!cab.datosPoliza.fechaVencimiento), fechaBase: today())` | Entrada en N1: hoy+14 / hoy+7 con tope vencimiento |
| A3 | `CMD Alta` · nodo 9 «Write Solicitud» | Añadir `caducidadTarea: pv!caducidadNivel` y `fecInicioNivel: now()` (hoy no se informa en el alta; lo propone esta sesión, ver decisión D2) | Solicitud nace con caducidad de N1 |
| B1 | `CMD CrearAccion` · nodo 11 «Write Nivel» | Añadir `caducidadTarea: rule!SCA2_calcularCaducidadNivel(propietario: <provisional con pv!sol.datosCabecera.clienteCarterizado / pv!sol.datosPerfilesPca.nuuma / clave de pv!sol.datosPoliza>, mismoNivel: tointeger(pv!nuevoNivel) = tointeger(pv!sol.estado.nivelIntervencion), fechaCaducidadAnterior: todate(pv!sol.estado.caducidadTarea), fechaVencimiento: todate(a!defaultValue(pv!sol.datosCabecera.polizaFechavencimiento, pv!sol.datosPoliza.fechadevencimiento)), fechaBase: today())` y `fecInicioNivel: now()` | Salto a N2/N3 recalcula; si no cambia de nivel conserva |
| B2 | `CMD CambiarNivel` · nodo 6 «Write CambiarNivel» | Igual que B1 con `pv!nivelDestino` (ya escribe `fecInicioNivel`) | Cambio manual de nivel recalcula |
| B3 | `SCA2_cargarSolicitud` (v7) | Añadir a `datosCabecera` las claves `clienteCarterizado`, `clienteNuumapropietario`, `polizaClaveproduccion` (solo lectura del record; aditivo, sin cambiar nada existente) | Necesario para B1/B2 sin consultas nuevas en los PM |
| C1 | `CMD CrearAccion` · nodo 7 «Write Tarea» | Quitar `caducidadTarea: rule!SCA2_obtenerCaducidadNivel(...)` del `SCA2 Solicitud`. Se mantiene `SCA2 Tarea.fechaCaducidad` (propio de la tarea) | Crear acción no cambia la caducidad del nivel |
| D1 | `CMD Posponer` · nodo 5 «Write Posponer» | Quitar `caducidadTarea: pv!fechaDietario`. Se conservan `fechaDietario`, `contadorPosponer`, `estadoTarea` y `SCA2 Tarea.fechaCaducidad` | Posponer no cambia la caducidad del nivel |
| E | `CMD Caducar`, `CMD BarridoCaducidad`, `CMD Decidir`, `SCA2_configurarDatosContextoSolicitud`, `SCA2_posponerTarea`, `SCA2_obtenerCaducidadNivel` | **Sin cambios** | `Caducar` ya lee `caducidadTarea`; el resto no la escribe |

Efectos a tener en cuenta (derivados del criterio aprobado):

1. Con `caducidadTarea` siempre informada, el `fechaDietario` deja de influir en «¿Caducada?» (hoy actúa de respaldo): posponer a una fecha posterior a la caducidad del nivel ya no alarga la vida de la solicitud.
2. Las solicitudes **ya en vuelo** sin `caducidadTarea` seguirán con el respaldo actual (`fechaDietario`) hasta su próximo salto de nivel; no se propone migración de datos.
3. Los envíos a CORE no cambian: la fecha solo se guarda en Appian (Date).

## 6. Decisiones del coordinador (OK HITO 1, 21/10/2026)

- D1 Propietario provisional → regla propia `SCA2_esPropietarioProvisional` (carterizado por ese gestor OR Estruage), un único punto de llamada por PM.
- D2 `fecInicioNivel = now()` en Alta nodo 9 y en cada salto (CrearAccion nodo 11, CambiarNivel nodo 6). Campo verificado en `SCA2 Solicitud` (`6117c6fa-c350-4877-b742-f11225ec3df0`).
- D3 Confirmado: posponer ya no alarga; sin migración de solicitudes en vuelo; `SCA2 Tarea.fechaCaducidad` y `SCA2_obtenerCaducidadNivel` no cambian.
- D4 `SCA2_cargarSolicitud` es de la fila A; cambio aditivo.

### 6.1 Decisiones planteadas originalmente

- **D1** Propietario provisional: ¿aplicar literalmente `SCA2_nuumaEsPropietario(...) OR carterizado = "Sí"` (añade una llamada CORE en Alta y en cada salto de nivel) o, hasta que llegue `SCA2_esPropietarioPoliza` (sesión B), usar solo datos ya cargados: `carterizado = "Sí" OR nuumaPropietario = NUUMA del gestor`? Propuesta de esta sesión: la segunda (sin llamadas nuevas), salvo indicación contraria.
- **D2** `fecInicioNivel`: hoy solo lo escribe `CMD CambiarNivel`. ¿Se informa también en Alta (nodo 9) y en `CrearAccion` nodo 11 al cambiar de nivel? Es coherente con «caducidad del nivel» y no afecta a nada visible.
- **D3** Formato de `polizaFechavencimiento` / `datosPoliza.fechaVencimiento` (texto): se verificará con pólizas reales en las pruebas (TRON/NSE/Vida); si algún origen no es `todate()`-able se añadirá la conversión en el llamador, no en la regla pura.
- **D4** Confirmación de que la ampliación aditiva de `SCA2_cargarSolicitud` (B3) está dentro de la fila A (está listada como objeto de la fila A en el doc 42).

## 7. Pendientes

- OK del coordinador → aplicar §5 (A1–A3, B1–B3, C1, D1) con cambios mínimos y versiones anotadas.
- Pruebas funcionales en TEST con solicitudes nuevas (alta N1 propietario / no propietario / vencimiento cercano; crear acción y posponer sin cambio; salto a N2; caducidad vencida → `CMD Caducar` → `FINALIZADO_CADUCADO`), registro en `docs/sca/pruebas/coordinacion-fase1.md` y comparación con SCA cuando sea posible.
- Sustituir el propietario provisional por `SCA2_esPropietarioPoliza` cuando lo entregue la sesión B.

## 8. Implementación realizada tras el OK del HITO 1 (21/10/2026)
### 8.1 Objetos nuevos adicionales

| Objeto | Tipo | UUID | Versión | Para qué |
|---|---|---|---|---|
| `SCA2_esPropietarioProvisional` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604058` | 1 | Propietario provisional (D1): carterizado por ese gestor o Estruage (`SCA2_nuumaEsPropietario`). 6 casos de prueba nativos (parte pura) 6/6 OK. Se sustituirá por `SCA2_esPropietarioPoliza` (sesión B) cambiando una línea por PM. |
| `SCA2_textoAFecha` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604118` | 1 | Convierte a Date el texto de vencimiento (`dd/MM/yyyy`, `yyyy-MM-dd`, `dd-MM-yyyy`, con o sin hora; Date/DateTime → `todate`). 9 casos nativos 9/9 OK. |
### 8.2 SAIL de las reglas nuevas

`SCA2_esPropietarioProvisional(nuuma, codCia, claveProd, carterizado, nuumaPropietario: Text) → Boolean`

```sail
/* Propietario PROVISIONAL de la póliza para la caducidad por nivel (fase 1).
   Sustituir por rule!SCA2_esPropietarioPoliza (sesión B) cuando esté disponible.
   - Parte pura: cliente carterizado por ESE gestor (carterizado = "Sí" y nuumaPropietario = nuuma).
   - Si no, propiedad de la clave en Estruage (rule!SCA2_nuumaEsPropietario). */
a!localVariables(
  local!carterizadoPorGestor: and(
    a!defaultValue(ri!carterizado, "") = "Sí",
    a!isNotNullOrEmpty(ri!nuuma),
    a!defaultValue(ri!nuumaPropietario, "") = ri!nuuma
  ),
  if(
    local!carterizadoPorGestor,
    true,
    if(
      or(a!isNullOrEmpty(ri!nuuma), a!isNullOrEmpty(ri!claveProd)),
      false,
      a!defaultValue(
        rule!SCA2_nuumaEsPropietario(
          codCia: a!defaultValue(ri!codCia, "41"),
          nuuma: ri!nuuma,
          claveProd: ri!claveProd
        ),
        false
      )
    )
  )
)
```

`SCA2_textoAFecha(texto: Any Type) → Date`

```sail
/* Convierte a Date el texto de fecha de vencimiento que llega de CORE/NSE/Vida
   (caducidad por nivel, fase 1). Acepta "yyyy-MM-dd", "dd/MM/yyyy" y "dd-MM-yyyy",
   con o sin hora detrás; si ya es Date/DateTime lo convierte; si no se reconoce -> null. */
a!localVariables(
  local!t: trim(tostring(a!defaultValue(ri!texto, ""))),
  local!s: left(local!t, 10),
  if(
    a!isNullOrEmpty(ri!texto),
    null,
    if(
      or(typeof(ri!texto) = typeof(today()), typeof(ri!texto) = typeof(now())),
      todate(ri!texto),
      if(
        and(len(local!s) = 10, mid(local!s, 5, 1) = "-", mid(local!s, 8, 1) = "-"),
        date(tointeger(left(local!s, 4)), tointeger(mid(local!s, 6, 2)), tointeger(right(local!s, 2))),
        if(
          and(len(local!s) = 10, or(mid(local!s, 3, 1) = "/", mid(local!s, 3, 1) = "-"), or(mid(local!s, 6, 1) = "/", mid(local!s, 6, 1) = "-")),
          date(tointeger(right(local!s, 4)), tointeger(mid(local!s, 4, 2)), tointeger(left(local!s, 2))),
          null
        )
      )
    )
  )
)
```
### 8.3 Objetos existentes modificados (versión antes → después)

| Objeto | UUID | Antes → después | Cambio |
|---|---|---|---|
| `SCA2_cargarSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | v7 → v8 | Aditivo: la consulta de `SCA2 Datos Cabecera` pide además `clienteCarterizado`, `clienteNuumapropietario`, `polizaClaveproduccion` y el mapa `datosCabecera` expone esas tres claves al final (nada renombrado ni reordenado). |
| `SCA2 CMD Alta` | `0000f06f-28fc-8000-6693-7f0000014e7a` | API sin versionId; copia antes/después guardada (`obj/Alta_antes.json`/`_despues.json`) | PV nueva `propietarioNivel` (Boolean). Nodo 7 «Contexto»: salida adicional → `pv!propietarioNivel`. Nodo 9 «Write Solicitud»: campos nuevos `fecInicioNivel: now()` y `caducidadTarea: rule!SCA2_calcularCaducidadNivel(...)` tras `nivelIntervencion: 1`. Resto de nodos (22) idéntico. |
| `SCA2 CMD CrearAccion` | `0000f06f-0eaa-8000-6594-7f0000014e7a` | ídem | Nodo 11 «Write Nivel»: añade `fecInicioNivel: now()` y `caducidadTarea` recalculada con `mismoNivel = (pv!nuevoNivel = nivel actual)`. Nodo 7 «Write Tarea»: se elimina SOLO el campo `caducidadTarea` de `SCA2 Solicitud`; `SCA2 Tarea.fechaCaducidad` (regla legacy) se conserva. Resto de nodos (40) idéntico. |
| `SCA2 CMD CambiarNivel` | `0000f06f-8a54-8000-6759-7f0000014e7a` | ídem | Nodo 6 «Write CambiarNivel»: añade `caducidadTarea` recalculada con `mismoNivel = (pv!nivelDestino = nivel actual)`; `fecInicioNivel: now()` ya existía. Resto (13 nodos) idéntico. |
| `SCA2 CMD Posponer` | `0000f06f-8a47-8000-6751-7f0000014e7a` | ídem | Nodo 5 «Write Posponer»: se elimina SOLO `caducidadTarea: pv!fechaDietario`; conserva `fechaDietario`, `contadorPosponer`, `estadoTarea` y `SCA2 Tarea.fechaCaducidad`. Resto (12 nodos) idéntico. |

Sin cambios: `SCA2 CMD Caducar`, `SCA2 CMD BarridoCaducidad`, `SCA2 CMD Decidir`, `SCA2_configurarDatosContextoSolicitud`, `SCA2_posponerTarea`, `SCA2_obtenerCaducidadNivel`.
### 8.4 SAIL exacto añadido en los PM

`SCA2 CMD Alta` · nodo 7 «Contexto» · salida → `pv!propietarioNivel`:

```sail
rule!SCA2_esPropietarioProvisional(nuuma: rule!CMP_obtenerNuuma(user(pp!initiator, "email")), codCia: "41", claveProd: a!defaultValue(index(index(ac!cabh,"datosPoliza",null),"claveProduccion",null), index(ac!cabh,"claveProduccion",null)), carterizado: index(ac!cabh,"carterizado",null), nuumaPropietario: index(ac!cabh,"nuumaPropietario",null))
```

`SCA2 CMD Alta` · nodo 9 «Write Solicitud» · campos añadidos a `SCA2 Solicitud` (tras `nivelIntervencion: 1`):

```sail
'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6117c6fa-c350-4877-b742-f11225ec3df0}fecInicioNivel': now(), 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{d7ef3591-6cc4-4094-9ebf-878665a93660}caducidadTarea': rule!SCA2_calcularCaducidadNivel(propietario: a!defaultValue(pv!propietarioNivel, false), mismoNivel: false, fechaCaducidadAnterior: null, fechaVencimiento: rule!SCA2_textoAFecha(texto: index(index(pv!cab,"datosPoliza",null),"fechaVencimiento",null)), fechaBase: today()), 
```

`SCA2 CMD CrearAccion` · nodo 11 «Write Nivel» · campos añadidos (tras `nivelIntervencion: pv!nuevoNivel`):

```sail
'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6117c6fa-c350-4877-b742-f11225ec3df0}fecInicioNivel': now(), 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{d7ef3591-6cc4-4094-9ebf-878665a93660}caducidadTarea': rule!SCA2_calcularCaducidadNivel(propietario: rule!SCA2_esPropietarioProvisional(nuuma: index(index(pv!sol,"datosPerfilesPca",null),"nuuma",null), codCia: "41", claveProd: index(index(pv!sol,"datosPoliza",null),"claveproduccion",null), carterizado: index(index(pv!sol,"datosCabecera",null),"clienteCarterizado",null), nuumaPropietario: index(index(pv!sol,"datosCabecera",null),"clienteNuumapropietario",null)), mismoNivel: tointeger(pv!nuevoNivel) = tointeger(index(index(pv!sol,"estado",null),"nivelIntervencion",null)), fechaCaducidadAnterior: todate(index(index(pv!sol,"estado",null),"caducidadTarea",null)), fechaVencimiento: rule!SCA2_textoAFecha(texto: a!defaultValue(index(index(pv!sol,"datosCabecera",null),"polizaFechavencimiento",null), index(index(pv!sol,"datosPoliza",null),"fechadevencimiento",null))), fechaBase: today()), 
```

`SCA2 CMD CambiarNivel` · nodo 6: el mismo campo `caducidadTarea` que en CrearAccion con `pv!nivelDestino` en lugar de `pv!nuevoNivel`.

Notas: `fechaVencimiento` se toma de `datosCabecera.polizaFechavencimiento` (`dd/MM/yyyy`) con respaldo `datosPoliza.fechadevencimiento` (`dd/MM/yyyy HH:mm CET`); en el alta, de `pv!cab.datosPoliza.fechaVencimiento` (`dd/MM/yyyy`). Todas se convierten con `SCA2_textoAFecha`. `claveProd` en los saltos: `datosPoliza.claveproduccion`; `nuuma` en los saltos: `datosPerfilesPca.nuuma` (gestor que dio de alta; documentado como provisional). No se creó la PV `caducidadNivel` propuesta en el HITO 1: el cálculo va inline en la escritura (misma trazabilidad en el record, menos cambios).

## 9. Alcance añadido: escritura de la caché de cabecera en `SCA2 CMD Alta` (coordinación con la sesión D)

Petición del coordinador (21/10/2026): el Write Records de `SCA2 Datos Cabecera` del alta (nodo 8 «Write Datos», hasta ahora 9 campos) debe escribir la cabecera completa + metadatos de caché con el mapeo de `43-D-cache-cabecera.md` §4.3/4.4, **solo** si `cons!SCA2_USAR_CACHE_CABECERA` es true; con la constante en false el alta escribe exactamente lo de hoy.

Implementación (`SCA2 CMD Alta`, `0000f06f-28fc-8000-6693-7f0000014e7a`; solo cambia el nodo 8, verificado nodo a nodo antes/después; 22 nodos, 33 PV):

```sail
/* nodo 8 «Write Datos», elemento SCA2 Datos Cabecera del array de records */
if(a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false),
  'recordType!…SCA2 Datos Cabecera'(
    idSolicitud: pv!idSolicitud,
    /* 45 campos cliente/póliza/contacto con el MISMO mapeo de D (§4.4): if(a!isNullOrEmpty(index(pv!cab,"datosX","campo",null)), null, tostring(...)) */
    tipoPoliza: rule!SCA2_obtenerTipoPoliza(numPoliza: pv!numPoliza),
    clienteCodint: if(rule!SCA2_obtenerTipoPoliza(numPoliza: pv!numPoliza) = cons!SCA2_TXT_VIDA_RIESGO, null,
                      if(a!isNullOrEmpty(index(pv!datosContexto,"datosCod","codInt",null)), null, tostring(index(pv!datosContexto,"datosCod","codInt",null)))),
    fechaCache: now(),
    validaHasta: rule!SCA2_calcularValidaHastaCache(fechaHoraCarga: now(), hora: cons!SCA2_HORA_CADUCIDAD_CACHE_CABECERA),
    origenCache: "CACHE"
  ),
  'recordType!…SCA2 Datos Cabecera'( /* los 9 campos de siempre, sin cambios */ )
)
```

Diferencias respecto al bloque de D: `local!cabeceraLive` → `pv!cab` (misma salida de `SCA2_obtenerDatosCabecera`, ya cargada en el nodo 7); no se informa `id` (insert); `clienteCodint` sale de `pv!datosContexto.datosCod.codInt` (el mismo valor que el alta escribe en `SCA2 Datos Poliza Autos/Hogar.tomadorCodint`) porque las filas de póliza se escriben en el mismo nodo y aún no se pueden consultar. No se ha tocado `SCA2_obtenerDatosCabecera` (v5) ni el record (v11).

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| CA1 | Alta con constante **false** (v11) tras el cambio | fila igual que hoy (9 campos) | fila id 229: `id` + 9 campos, `origenCache`/`fechaCache`/`validaHasta` vacíos | OK | 15788202 (2002600000012) | PM Alta (UI 11:45 UTC) | alta por UI; lectura `/record-types/{DatosCabecera}/data` | — |
| CA2 | Alta con constante **true** (v12, solo durante la prueba) | fila completa, `origenCache = CACHE`, `validaHasta` = 07:00 del día siguiente | fila id 230: 44/53 campos informados (los 9 vacíos son nulos legítimos: apoderado, piso, puerta, escalera, telfijo, pais, fechaUltimoSiniestro, ramo, revalorizacion), `origenCache` CACHE, `fechaCache` 2026-10-21 11:49:47 UTC, `validaHasta` 2026-10-22 07:00:00, `tipoPoliza` NSE-Autos, `clienteCodint` 81895242007, `polizaClaveproduccion` 5244559 | OK | 15788204 (2002300392341) | PM Alta (UI 11:49 UTC) | constante → true; alta por UI; lectura del record; constante → **false (v13)** | Observación: `clienteNuumapropietario` llega como texto `"null"` desde la salida de la regla (mismo mapeo de D) |

Estado final: `SCA2_USAR_CACHE_CABECERA` = **false** (v13).

## 10. Pruebas funcionales en TEST con solicitudes nuevas (21/10/2026, usuario JJGONZ2, no propietario de ninguna póliza)

Lectura de `SCA2 Solicitud` por `/record-types/{uuid}/data` tras cada paso de UI (la UI del gestor no muestra `caducidadTarea`; «Fecha anulación» es el vencimiento de la póliza).

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| F1 | Alta N1 no propietario (JJGONZ2, carterizado No) | `caducidadTarea` = hoy+7 = 2026-10-28; `fecInicioNivel` = ahora | 2026-10-28 00:00; `fecInicioNivel` 2026-10-21 10:52:53 | OK | 15788192 (2002500495555, flota) | PM Alta | alta UI; lectura record | — |
| F2 | Alta N1 segunda póliza | ídem | 2026-10-28; `fecInicioNivel` 10:59:15 | OK | 15788193 (2002600007357) | PM Alta | ídem | — |
| F3 | Posponer en N1 no recalcula | `caducidadTarea` igual; `fechaDietario`/`contadorPosponer` informados | `caducidadTarea` 2026-10-28 (igual); `fechaDietario` 2026-10-28; `contadorPosponer` 1 | OK | 15788193 | PM Posponer (UI 11:02 UTC) | POSPONER → confirmar; lectura record antes/después | — |
| F4 | Finalizar CA negativa en N1 no recalcula | igual mientras siga N1 | sigue N1, `caducidadTarea` 2026-10-28; el motor creó «Gestión Verti/vencimiento» y después «Mecanización» (no ejecutada: alta de gestión en CORE) | OK | 15788193 | PM Decidir/CrearAccion (UI 11:05 y 11:14 UTC) | argumento INCREMENTO PRIMA SINIESTROS → Negativo → FINALIZAR; Verti → CONTINUAR | — |
| F5 | Alta N1 tercera póliza | hoy+7 | 2026-10-28; `fecInicioNivel` 11:20:02 | OK | 15788195 (2002600009065) | PM Alta | alta UI | — |
| F6 | Vencimiento cercano (03/11/2026) | hoy+7 = 28/10 < 03/11 → 28/10 (el tope solo aplicaría a propietario: 04/11) | 2026-10-28 | OK | 15788194 (2002500478924) | PM Alta | alta UI (aviso acuerdo especial SI24 aceptado) | — |
| F7 | Vencimiento pasado (27/08/2026) → tope | `caducidadTarea` = 2026-08-27 | 2026-08-27 00:00; `fecInicioNivel` 11:24:16 | OK | 15788196 (2002500378119) | PM Alta | alta UI | — |
| F8 | Vencimiento pasado (17/08/2026) → tope | 2026-08-17 | 2026-08-17 | OK | 15788204 (2002300392341) | PM Alta | alta UI (prueba CA2) | — |
| F9 | `SCA2 CMD BarridoCaducidad` selecciona la vencida | arranca Caducar para 15788196 | la consulta devuelve 100 ids antiguos (sin orden, `batchSize` 100) y 15788196 no entra; ninguna de las 100 cambió de estado | KO (defecto preexistente) | 15788196 | Barrido 11:28 UTC (Designer) | arranque manual «Iniciar proceso para depuración» | ver §11 |
| F10 | `SCA2 CMD Caducar` directo sobre la vencida | caduca y finaliza | Cargar → ¿Ya ejecutado? → ¿Caducada? (now() ≥ 2026-08-27) → Write Caducada → estado `CADUCADA` (Transicion 1494 OK, version 4) → Finalizar Solicitud: integración CORE `IGenerarContraAnul` HTTP 500 «Error no catalogable 0999» → Write Error | OK parcial | 15788196 | 13307120 (11:32–11:36 UTC; PV `idSolicitud` fijada en monitorización porque el PV no es parámetro) | arranque manual + edición de PV + reintento de Cargar | el error es de CORE TEST (preexistente); la UI del gestor sigue mostrando PENDIENTE porque lee de CORE |
| F11 | Salto a N2 recalcula `caducidadTarea` y `fecInicioNivel` | nueva caducidad hoy+N desde el salto | **no reproducido**: el motor no devolvió «IR A NIVEL 2» en el camino negativa → Verti → Mecanización, y `SCA2 CMD CambiarNivel` no tiene llamadores (ni interfaces, ni PM, ni acciones de record) | pendiente | 15788193 | — | — | ver §11 |

## 11. Hallazgos fuera de la fila A (sin tocar) y pendientes

1. **`SCA2 CMD BarridoCaducidad` (`0000f06f-4f69-8000-671e-7f0000014e7a`)**: nodo 6 consulta `estadoSolicitud not in {FINALIZADA, CADUCADA, ERROR}` y `caducidadTarea < now()` con `batchSize: 100` **sin orden**; nodo 4 arranca `SCA2 CMD Caducar` **una sola vez** con `{idSolicitud: pv!lista}` (lista entera en un PV Text). Con 115 solicitudes vencidas sin finalizar en TEST la tanda es siempre la misma y no caduca ninguna (sin Transicion de Caducar tras la ejecución). Propuesta: `a!forEach` o MNI por fila, orden por `caducidadTarea`, e incluir los estados finales que falten (`FINALIZADA_POSITIVO`, `CANCELADA`, `MECANIZADA`…).
2. **`SCA2 CMD Caducar`** escribe `estadoSolicitud = "CADUCADA"` (no `FINALIZADO_CADUCADO` como dice el diseño) y después llama a CORE `IGenerarContraAnul`; en TEST devuelve 500/0999. El PV `idSolicitud` no está marcado como parámetro de arranque.
3. **Salto de nivel**: sólo lo produce el motor de decisión (`accionCalc` «IR A NIVEL 2/3» → CrearAccion nodo 10/11) o `CMD CambiarNivel`, que hoy nadie llama. Para probar F11 hace falta un argumento/tabla de decisión que devuelva «IR A NIVEL 2» o exponer `CambiarNivel`; el SAIL del recálculo (§8.4) es el mismo que el del alta, verificado en F1–F8.
4. Avisos de UI en TEST: «póliza flota / sin tratamiento en SCA» (2002500495555, 2002600000012) y «acuerdo especial SI24» (2002500478924) no impiden el alta ni la CA N1.
5. `SCA2 Transicion.usuario` = «devin» en Decidir/CrearAccion: es el nombre de la cuenta de sistema que arranca los PM en TEST (preexistente, no dato de prueba).
6. Pendiente: sustituir `rule!SCA2_esPropietarioProvisional` por `SCA2_esPropietarioPoliza` (sesión B) en los 3 PM (una línea por PM); prueba F11 cuando haya camino a N2.
