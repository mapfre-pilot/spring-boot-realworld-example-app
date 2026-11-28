# R54 — Cuadro de Mando SCA2: respuestas a los analistas y dudas

Respuesta al documento «Cuadro de Mando.docx». Este documento sigue su mismo orden.

**En esta ronda no se ha cambiado nada.** Solo se ha leído Appian TEST (`mapfrespain-test`): interfaces, modelos de proceso, constantes, reglas y datos de los records. No se ha guardado ningún objeto, no se han escrito datos y no se ha ejecutado SQL. PRO no se ha tocado.

Cada respuesta indica de dónde sale:

- **Comprobado**: visto en la SAIL viva, en el modelo de proceso o en los datos de TEST (leídos el 17/11/2026).
- **Deducido**: conclusión a partir de lo anterior, sin prueba directa.
- **Propuesta**: cómo se haría el cambio. No está hecho.

Objetos revisados (versión viva en TEST):

| Objeto | Tipo | Versión |
|---|---|---|
| `SCA2_CuadroMando` | Interfaz | v28 (igual que `docs/sca/sail/62-cuadro-mando/SCA2_CuadroMando.sail`) |
| `SCA2_GestionMantenimientoMenu` | Interfaz | v6 |
| `SCA2_BandejaErrores` | Interfaz | v13 |
| `SCA2 CMD Mecanizar`, `SCA2 CMD CompletarAccion`, `SCA2 CMD CrearAccion`, `SCA2 CMD Finalizar`, `SCA2 CMD MarcarErrorRelanzado` | Modelos de proceso | vivos |
| `SCA2_textoEstadoSolicitud`, `SCA2_calcularEstadoSolicitud` | Reglas | vivas |
| `SCA2_TXT_ESTADO_SOL_*`, `SCA2_TXT_ESTADO_TAREA_*`, `SCA2_TXT_ETQ_ESTADO_*` | Constantes | vivas |

---

## 1. Gestión de mantenimiento (cabecera y filtros)

### 1.1 ¿Qué fecha usan «Desde» y «Hasta»?

**Comprobado.** Es la **fecha de creación** de cada registro, no la de la última actuación. Por defecto el cuadro muestra los últimos 90 días (`local!fDesde: today() - 90`, `local!fHasta: today()`). «Desde» cuenta desde las 00:00:00 y «Hasta» hasta las 23:59:59.

Cada bloque filtra por la fecha de creación de su propio record:

| Bloque del cuadro | Record | Campo de fecha |
|---|---|---|
| Solicitudes, estados, cerradas, causas, motivos | `SCA2 Solicitud` | `createdAt` (alta de la solicitud en SCA2) |
| Gestiones (comandos) | `SCA2 Transicion` | `fecha` (cuándo se ejecutó la gestión) |
| Tareas | `SCA2 Tarea` | `fechaCreacion` |
| Servicios | `SCA2 Llamada Servicio` | `fechaInicio` |
| Errores | `SCA2 Error` | `fechaCreacion` |
| Trazabilidad | `SCA2 Trazabilidad Cliente` | fecha de la operación |

```sail
a!queryFilter(
  field: 'recordType!{…}SCA2 Solicitud.fields.{…}createdAt',
  operator: "between",
  value: {local!ini, local!fin}
)
```

**Consecuencia (deducido):** una solicitud creada el 30/09 sobre la que se actúa el 10/11 cuenta en «Solicitudes» solo si el periodo incluye el 30/09. En cambio, la gestión del 10/11 cuenta en «Gestiones» si el periodo incluye el 10/11. Por eso las cifras de solicitudes y de gestiones de un mismo periodo no tienen por qué cuadrar. Los filtros de línea y de origen se aplican a través de la solicitud. La pestaña Trazabilidad solo filtra por fecha.

### 1.2 El calendario no funciona al cambiar el año

**Comprobado.** Los campos son `a!dateField` estándar de Appian, sin lógica propia. Las capturas lo confirman: con el selector en 2026, el campo sigue mostrando 27/11/2025.

**Deducido.** Es el comportamiento estándar del selector de Appian. Las flechas de mes y año solo **mueven la vista** del calendario. La fecha no cambia hasta que se **pulsa un día**. No es un fallo del cuadro y no se puede cambiar en un `a!dateField`.

**Propuesta (a elegir, ver duda 2):**

- Escribir la fecha a mano (dd/mm/aaaa). Ya funciona hoy.
- Añadir un texto de ayuda bajo los campos: «Para cambiar de año, navegue y pulse el día».
- Añadir botones de periodo rápido: «Últimos 30 días», «Últimos 90 días», «Año en curso», «Desde el inicio de SCA2». Cada botón rellena Desde/Hasta.

Afecta solo a `SCA2_CuadroMando`. Riesgo bajo.

### 1.3 Desde qué fecha hay datos (aviso para fechas anteriores)

**Comprobado (datos de TEST leídos el 17/11/2026):**

| Record | Primer registro | Total |
|---|---|---|
| `SCA2 Solicitud` (`createdAt`) | 24/09/2026 14:26 | 546 |
| `SCA2 Transicion` (`fecha`) | 24/09/2026 15:34 | 3.335 |
| `SCA2 Tarea` (`fechaCreacion`) | 24/09/2026 16:29 | 934 |
| `SCA2 Error` (`fechaCreacion`) | 07/10/2026 13:20 | 149 |

Solicitudes por mes: septiembre 2026 (desde el 24) 43, octubre 326 y noviembre (hasta el 16) 177. En TEST **no hay ningún dato de SCA2 anterior al 24/09/2026**. El filtro Desde 24/09/2025 de las capturas devuelve lo mismo que Desde 24/09/2026.

**Propuesta:**

- Crear una constante `SCA2_FECHA_INICIO_DATOS` con valor propio en cada entorno: en TEST 24/09/2026 y en PRO la fecha de arranque.
- Si `local!fDesde` es anterior a esa fecha, mostrar un aviso: «SCA2 solo tiene datos desde el dd/mm/aaaa. Las cifras anteriores a esa fecha no están en este cuadro».
- Opcionalmente, no dejar elegir una fecha anterior.

Objetos: `SCA2_CuadroMando` y una constante nueva. No afecta a nada fuera del cuadro. Riesgo bajo. Ver duda 3, sobre qué fecha poner en PRO.

### 1.4 «Da menos registros de los que hay en base de datos»

**Comprobado.** El cuadro solo lee los records SCA2 (`SCA2 Solicitud`, `SCA2 Tarea`, `SCA2 Transicion`, etc.), es decir, el esquema `sca2_anulaciones`. Ninguna consulta del cuadro lee las tablas del SCA actual ni del CORE. En TEST hay 546 solicitudes SCA2, todas con un `idSolicitud` distinto.

**Deducido.** El analista tiene razón: el cuadro solo cuenta lo que ha pasado por SCA2, la aplicación nueva. Además, influyen otros tres motivos:

1. El periodo por defecto es de 90 días, contados por fecha de creación (ver 1.1).
2. Si se elige línea u origen, se excluyen las demás.
3. Algunas gráficas tienen un límite de categorías (`dataLimit: 15` o `30`). Esto no cambia los totales.

Para comparar con una cifra concreta de base de datos, hay que saber qué tabla y qué filtro se usaron (duda 4).

---

## 2. Pestaña Resumen

### 2.1 ¿Qué significa «Gestiones realizadas» / «Gestiones registradas»?

**Comprobado.** El indicador «Gestiones registradas» (subtítulo «Comandos ejecutados») cuenta las filas de `SCA2 Transicion` del periodo:

```sail
local!nGestiones: a!queryRecordType(
  recordType: 'recordType!{…}SCA2 Transicion',
  fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: '…SCA2 Transicion.fields.{…}id', alias: "n")),
  filters: local!fTra, …
).data
```

Se escribe una fila en `SCA2 Transicion` cada vez que un comando SCA2 termina un paso sobre una solicitud. Los comandos son Alta, Decidir, CrearAccion, CompletarAccion, Mecanizar, Finalizar, Posponer y Caducar. Cada fila guarda el estado de origen, el estado de destino y el resultado (OK o ERROR).

En TEST hay 3.335 filas:

| Comando | Filas |
|---|---|
| CrearAccion | 1.032 |
| Decidir | 949 |
| Alta | 525 |
| CompletarAccion | 400 |
| Mecanizar | 252 |
| Finalizar | 104 |
| Posponer | 70 |
| Caducar | 3 |

Resultados: 3.330 OK y 5 ERROR.

**Deducido.** No son solicitudes ni tareas. Son los **pasos automáticos** que ha dado el sistema. Una solicitud normal genera varios. Propuesta: renombrarlo a «Pasos ejecutados (comandos)» para no confundirlo con las «Gestiones por tipo y estado» que se piden en 3.4 (duda 9).

### 2.2 El aviso «… SCA2 CMD Mecanizar … queda esperando»

**Qué es `SCA2 CMD Mecanizar` (comprobado).** Es el proceso que mecaniza la anulación en CORE:

- Guarda la mecanización.
- Crea la autorización si hace falta.
- Da de alta la ANL.
- Si procede, lanza la inducción Verti/Vencimiento.
- Cierra la gestión en SGC.
- Cambia de nivel o termina el proceso.

Recorrido real del modelo vivo, con los números de nodo:

1. `8 Guardar Mecanización` → `13 Write Éxito`. Aquí la solicitud ya queda en `estadoSolicitud = "MECANIZADA"`, `procesoActivo = "ANL"`.
2. `300/301 ANL Alta`.
3. `331 ¿Inducir Verti?`. Es «Sí» si el contacto es VERTI o VENCIMIENTO y la solicitud no viene de una Acción Administrativa.
4. `332 Write Tarea INDUCCION`. Crea la tarea `SCA2 Tarea` de tipo `INDUCCION` («Inducción Verti/Vencimiento (componente)»), en estado `PENDIENTE`.
5. **El nodo 332 tiene dos salidas, que corren en paralelo:**
   - **Rama Verti:** `334 Inducción Verti (CMP) [SUB encadenado]` → `333 Write cierre Tarea INDUCCION`, que deja la tarea en `COMPLETADA` cuando vuelve el componente → `341 End Inducción`.
   - **Rama principal:** `324 ¿wAutemis pdte. aceptar?` → `325 Recargar solicitud` → `326 Finalizar gestión SGC` → `320 Write Cambio nivel` → `322 Start CrearAccion` → `End`. El nodo 320 marca `mecanizacionRealizada = true` y `procesoActivo = "FIN PROCESO"` o `"IR A NIVEL n+1"`. También cierra la tarea MECANIZAR en `FINALIZADA` y escribe la transición.

**Conclusión (comprobado en el modelo, coherente con la prueba de R47-B).** El analista tiene razón: **la solicitud no se queda parada por Verti**. Cuando empieza la inducción, la mecanización ya está hecha (`MECANIZADA`). La rama principal sigue en paralelo y deja la solicitud en su estado: fin de proceso o salto de nivel.

Lo único que «espera» es la **rama Verti** de esa misma instancia de proceso. Mientras el componente CMP no responda, la instancia de `SCA2 CMD Mecanizar` sigue activa en Monitoring y la tarea `INDUCCION` sigue `PENDIENTE`. Eso no bloquea la solicitud.

Por tanto, el texto actual del aviso («queda esperando») es engañoso. Debería decir que «la inducción en el componente no ha terminado».

**Datos de TEST (comprobado):**

- Hay 41 tareas `INDUCCION`: 32 `COMPLETADA` y 9 `PENDIENTE`. Las 9 pendientes son del 23/10 al 16/11 y todas llevan más de una hora.
- Estado actual de las solicitudes con tarea INDUCCION: 20 EN_ACCION, 13 FINALIZADA, 5 ERROR, 1 MECANIZADA, 1 PDTE_FINALIZAR y 1 FINALIZADA_POSITIVO.
- Es decir, la solicitud avanza con independencia de la tarea de inducción.

**La contradicción aparente.** La inducción es un subproceso **síncrono y encadenado** dentro de Mecanizar. Esto se decidió en R27-C/R47-B por paridad con `SCA_Mecanizacion`. Pero es síncrono solo para su propia rama, no para el estado de la solicitud. Sacarla a un proceso independiente (asíncrono, sin encadenar) **cambiaría el flujo** de Mecanizar. Por eso no se propone como cambio, sino como duda (duda 5).

### 2.3 Sustituir el aviso por una tarta Verti en «Gestiones y resultados»

**De qué dato saldría (comprobado).** Hoy SCA2 guarda dos tipos de tarea relacionados con Verti:

| Tarea | Quién la crea | Estados en TEST |
|---|---|---|
| `INDUCCION`, «Inducción Verti/Vencimiento (componente)»: llamada automática al componente CMP | `SCA2 CMD Mecanizar`, nodos 332 y 333 | 32 COMPLETADA, 9 PENDIENTE |
| `VERTI`, «Gestión VERTI/Vencimiento»: pantalla del gestor | `SCA2 CMD Mecanizar` (nodo 7) y `SCA2 CMD CrearAccion` (nodos 31 y 34) | 72 COMPLETADA, 12 FINALIZADA, 22 PENDIENTE |

**Limitación (comprobado).** SCA2 **no guarda si el componente Verti terminó con error**. El nodo 333 pone la tarea `INDUCCION` en `COMPLETADA` siempre que el subproceso vuelve, sin guardar ningún resultado. Tampoco se escribe ningún `SCA2 Error` para la inducción: en TEST no hay errores de ese tipo.

Por tanto, hoy solo se pueden pintar dos de las tres porciones que piden:

- «Terminó»: tarea `INDUCCION` `COMPLETADA`.
- «No terminó»: tarea `INDUCCION` `PENDIENTE`. Se puede separar en «menos de 1 h» y «más de 1 h», que es lo que hoy enseña el aviso.

**Propuesta:**

- **Fase 1, solo en el cuadro.** Quitar el aviso del Resumen y añadir en «Gestiones y resultados» una tarta «Inducción Verti/Vencimiento». Agrupar `SCA2 Tarea` con `tipo = "INDUCCION"` por estado, en el periodo filtrado por `fechaCreacion`, con las porciones «Terminada» y «Sin terminar». Bajo la tarta, mantener el número de las que llevan más de 1 h sin terminar, con el texto corregido.
  - Objetos: solo `SCA2_CuadroMando`. Riesgo bajo.
- **Fase 2, «con error en Verti».** Requiere tocar `SCA2 CMD Mecanizar`, fuera del cuadro. Habría que leer la salida del subproceso CMP y guardarla, por ejemplo en `SCA2 Tarea.tokenTarea` o en un estado propio (`ERROR`), o escribir un `SCA2 Error`.
  - Cambia un proceso productivo. Riesgo medio. Requiere confirmar qué devuelve el componente CMP cuando falla (duda 6).

---

## 3. Pestaña «Gestiones y resultados»

### 3.0 Gráfico «Solicitudes por estado actual» (pedido en el Resumen)

**Comprobado.** Hoy agrupa por el valor interno de `SCA2 Solicitud.estadoSolicitud`, sin traducir. Por eso salen `EN_ACCION`, `PDTE_MECANIZAR`, etc.

Valores en TEST:

| Estado interno | Solicitudes |
|---|---|
| EN_ACCION | 234 |
| FINALIZADA | 82 |
| FINALIZADA_POSITIVO | 82 |
| PDTE_MECANIZAR | 48 |
| CANCELADA | 36 |
| ALTA | 21 |
| ERROR | 15 |
| MECANIZADA | 12 |
| ERROR_DECISION | 7 |
| CADUCADA | 5 |
| PDTE_FINALIZAR | 3 |
| DECIDIDA | 1 |

**Regla de etiquetas que ya existe (comprobado).** `SCA2_textoEstadoSolicitud(estado)` («Etiquetas del listado según HU3980») traduce el estado interno a la etiqueta funcional:

| Estado interno | Etiqueta |
|---|---|
| ALTA, DECIDIDA, EN_DECISION, EN_ACCION, PENDIENTE, PDTE_FINALIZAR, PDTE_MECANIZAR, ERROR | Solicitud Pendiente |
| MECANIZADA | Mecanización Enviada |
| PENDIENTE_AUTORIZACION | Pendiente de Autorización |
| FINALIZADA_POSITIVO | Finalizado Contra Anulación Positiva |
| FINALIZADA, FIN, FINALIZADA_SIN_ANULAR, RECHAZADA, FINALIZADA_NEG_CONTRA, FINALIZADA_NO_REQ | Solicitud Finalizada sin anular |
| FINALIZADA_ANULADA | Finalizada. Anulación realizada |
| FINALIZADA_RECHAZADA_ANULACION | Solicitud Finalizada. Rechazada anulación |
| CANCELADA | Cancelada |
| CADUCADA | Solicitud Caducada |
| CADUCADA_NEGATIVA | Anulada Caducada |
| ERROR_DECISION | Error en el servicio de decisión |

Hay otra regla, `SCA2_calcularEstadoSolicitud`, que calcula la etiqueta de la bandeja a partir del estado de CORE (`cod_tip_est_solic` + `cod_tip_est_mecaniza`, tabla R45-D). Para el cuadro no sirve: necesita consultar CORE solicitud a solicitud y no se puede agregar en una gráfica.

**Propuesta.**

- Agrupar por estado interno igual que ahora y pintar cada barra con `SCA2_textoEstadoSolicitud`, sumando las que comparten etiqueta. Con los datos de TEST saldrían: Solicitud Pendiente 322, Solicitud Finalizada sin anular 82, Finalizado Contra Anulación Positiva 82, Cancelada 36, Mecanización Enviada 12, Error en el servicio de decisión 7 y Solicitud Caducada 5.
- Objetos: solo `SCA2_CuadroMando`. Riesgo bajo.
- **Ojo:** con esta regla, `ERROR` (15) se suma a «Solicitud Pendiente» y desaparece de la vista (duda 7).
- **Deducido:** la etiqueta del cuadro, que sale del estado SCA2, puede no coincidir con la de la bandeja, que sale de CORE. Por ejemplo, «Póliza Anulada. Solicitud Pendiente Nivel 2» solo existe en la bandeja.

### 3.1 Gráfica de causa ordenada de mayor a menor

**Comprobado.** «Causa indicada por el cliente» es un `a!barChartField` con `a!recordData` sobre `SCA2 Datos Solicitud`, agrupado por `desccausa` con `dataLimit: 15`. No tiene orden explícito.

Para comparar:

- «Detalle del motivo» ya ordena por `n` descendente (`a!sortInfo(field: "n", ascending: false)`).
- «Motivo» no está ordenado.

**Propuesta.** Calcular la gráfica con `a!queryRecordType` (agrupación + `COUNT`, `sort: a!sortInfo(field: "n", ascending: false)`) y pasar categorías y series, como en «Detalle del motivo».

- Aplicarlo también a «Motivo».
- Objetos: solo `SCA2_CuadroMando`. Riesgo bajo.

### 3.2 Añadir a la leyenda el detalle de cada causa

**Comprobado.** `SCA2 Datos Solicitud` tiene `codcausa`, `desccausa` y `coddetalle`, pero no tiene la descripción del detalle. La descripción está en el catálogo `SCA2 Cat Detalle`, que ya usa la gráfica «Detalle del motivo».

En TEST hay 528 filas y 17 combinaciones causa–detalle. Ejemplos:

- Causa 1, «ME HA SUBIDO MUCHO LA PRIMA», detalle 1: 372.
- Causa 14, «NO VOY A COMPRARME OTRO COCHE», detalle 5: 71.

**Propuesta.** En una gráfica de barras de una sola serie, Appian no saca la leyenda por categoría. Opciones:

- **(a)** Barras apiladas: causa en el eje y detalle como serie. La leyenda queda con los detalles.
- **(b)** Mantener la gráfica ordenada y añadir debajo una tabla «Causa → Detalle → Solicitudes».

Objetos: solo `SCA2_CuadroMando`. Riesgo bajo. Ver duda 8.

### 3.3 Tarta «Resultado de las solicitudes cerradas»: ¿qué agrupa «Finalizado»?

**Comprobado.** La tarta toma las solicitudes con alguno de estos estados (`local!estCerrados`) y usa como etiqueta el valor interno, sin agrupar:

`FINALIZADA`, `FINALIZADA_POSITIVO`, `FINALIZADA_NEG_CONTRA`, `FINALIZADA_NO_REQ`, `FINALIZADA_SIN_ANULAR`, `CANCELADA`, `CADUCADA`, `CADUCADA_NEGATIVA`.

Es decir, el cuadro **no junta nada en «Finalizado»**. Cada estado interno es una porción. Si solo aparece «FINALIZADA» es porque, en TEST, es el único valor de ese grupo con datos:

| Estado | Solicitudes en TEST |
|---|---|
| FINALIZADA | 82 |
| FINALIZADA_POSITIVO | 82 |
| CANCELADA | 36 |
| CADUCADA | 5 |
| FINALIZADA_NEG_CONTRA, FINALIZADA_NO_REQ, FINALIZADA_SIN_ANULAR, CADUCADA_NEGATIVA | 0 |

**Quién escribe «FINALIZADA» (comprobado).** El nodo 8 de `SCA2 CMD Finalizar` guarda `estadoSolicitud = a!defaultValue(pv!estadoFinal, "FINALIZADA")`. Si quien lo llama no pasa un estado final más concreto, queda «FINALIZADA» genérico. `SCA2 CMD CompletarAccion` (nodo 340) escribe `FINALIZADA_POSITIVO` o `CANCELADA`.

**Deducido.** El «FINALIZADA» genérico junta hoy, en la práctica, los cierres sin anulación positiva: contra-anulación negativa, no requerida, etc. El dato no deja distinguirlos.

**Propuesta.**

- Pintar la tarta con las etiquetas de `SCA2_textoEstadoSolicitud`.
- Para desglosar de verdad, hay que guardar el estado final concreto al cerrar. Eso es pasar `estadoFinal` (`FINALIZADA_NEG_CONTRA`, `FINALIZADA_NO_REQ`, …) desde los procesos que llaman a `SCA2 CMD Finalizar`, o deducirlo del resultado de mecanización guardado en CORE.
- Este segundo paso cambia procesos fuera del cuadro. Riesgo medio (duda 10).

### 3.4 Quitar dos gráficas y traer «Tareas por tipo y estado» como «Gestiones por tipo y estado»

**Comprobado.**

- «Gestiones realizadas por comando y resultado» y «Estado al que lleva cada gestión (15 más frecuentes)» salen de `SCA2 Transicion`.
- «Tareas por tipo y estado» está en la pestaña Tareas. Son barras de `SCA2 Tarea` agrupadas por `nombreTarea` y apiladas por `estado`.

**Propuesta.**

- Borrar los dos bloques de `SCA2 Transicion` de la pestaña 2.
- Mover allí la gráfica de tareas con el título «Gestiones por tipo y estado».
- Objetos: solo `SCA2_CuadroMando`. Riesgo bajo.

**FINALIZADA frente a COMPLETADA (comprobado en los modelos de proceso):**

| Tarea | COMPLETADA | FINALIZADA |
|---|---|---|
| **MECANIZAR**. En TEST: 22 COMPLETADA, 100 FINALIZADA, 59 PENDIENTE, 1 CANCELADA | La cierra **el gestor al completar su acción**: `SCA2 CMD CompletarAccion`, nodo 5 «Write Tarea». También `SCA2 CMD Mecanizar`, nodo 13, cuando cierra tareas MECANIZAR pendientes repetidas de la misma solicitud con interfaz VERTI. | La cierra **el propio proceso de mecanización** al terminar: nodo 320 «Write Cambio nivel», nodo 306 «Write Mecanización OK» y nodo 5 «Write Caducada». |
| **VERTI**, «Gestión VERTI/Vencimiento». En TEST: 72 COMPLETADA, 12 FINALIZADA, 22 PENDIENTE | La cierra la pantalla Verti/Vencimiento: `SCA2 CMD CrearAccion`, nodo 34 «Write cierre tarea VERTI». Guarda la opción elegida en `tokenTarea`. | **Ningún proceso vivo escribe hoy FINALIZADA en tareas VERTI.** Las 12 que hay se crearon entre el 15/10 y el 20/10/2026. |
| **INDUCCION** | La deja así el nodo 333 cuando vuelve el componente CMP. | No se usa. |

Sobre las 12 tareas VERTI en FINALIZADA, **lo deducido** es que vienen de una versión anterior de los procesos y no del flujo actual.

**Deducido.** «COMPLETADA» quiere decir que una persona (o la pantalla) terminó la tarea. «FINALIZADA» quiere decir que el sistema la cerró al terminar el paso automático. Para el negocio, las dos son «cerrada». Propuesta para la gráfica: mostrar «Cerrada por el gestor» (COMPLETADA) y «Cerrada por el sistema» (FINALIZADA), o juntarlas en «Cerrada» (duda 11).

---

## 4. Pestaña Tareas

**Propuesta.** Quitar «Tareas» de `local!tabs` y su rama en el `choose`. Hoy la pestaña tiene cuatro indicadores por estado, «Tareas por tipo y estado» (que se mueve a la pestaña 2), tareas por día y tareas por grupo.

- Se pierden los indicadores de tareas pendientes y por grupo. Ver duda 12.
- Objetos: solo `SCA2_CuadroMando`. No afecta a las tareas reales ni a la bandeja. Riesgo bajo.

---

## 5. Pestaña Servicios

### 5.1 «Tiempo de respuesta por servicio (ms)» de mayor a menor

**Comprobado.** Hoy las categorías salen de `local!qSrv`, ordenado por **número de llamadas** (`a!sortInfo(field: "n", ascending: false)`), no por tiempo. La gráfica tiene dos series: Media y Máximo.

**Propuesta.** Ordenar por `avg` descendente. Hay que hacer una consulta propia para esta gráfica, para no cambiar las otras que usan `local!qSrv`. Objetos: solo `SCA2_CuadroMando`. Riesgo bajo. Ver duda 13: ordenar por media o por máximo.

### 5.2 Quitar «Últimas llamadas con error» y fusionarla con «Errores pendientes más recientes»

**Comprobado.** Las dos listas vienen de records distintos:

| Lista | Record | Qué muestra | Columnas |
|---|---|---|---|
| «Últimas llamadas con error» (Servicios) | `SCA2 Llamada Servicio` | Llamadas con `resultado <> "OK"`: cada llamada a un servicio externo que respondió mal | Fecha, Solicitud, Gestión, Servicio, HTTP, Mensaje |
| «Errores pendientes más recientes» (Errores) | `SCA2 Error` | Errores en `PENDIENTE`: fallos de proceso que esperan que alguien los relance o los descarte | Fecha, Solicitud, Gestión, Código, Intentos, Mensaje |

**Deducido:** una llamada con error **no siempre** genera un `SCA2 Error`, porque puede haberse reintentado bien. Y un `SCA2 Error` puede no venir de ninguna llamada (por ejemplo `WRITE_FAIL`).

**Propuesta.** Una sola lista «Errores recientes (procesos y servicios)» con una columna **Origen** («Proceso» o «Servicio»). Se juntan en la interfaz las dos consultas, ya ordenadas por fecha, con un límite de 20 filas en total.

Objetos: solo `SCA2_CuadroMando`. Riesgo bajo.

El documento pide fusionarla con «Errores pendientes más recientes» y, en la pestaña Errores, quitar esa misma lista. Falta confirmar en qué pestaña va la lista fusionada (duda 14).

---

## 6. Pestaña Errores

### 6.1 ¿Qué es «completarAcción»?

**Comprobado.** Es el comando `SCA2 CMD CompletarAccion`. Se ejecuta cuando el gestor **completa la acción de su tarea**: contra-anulación, acción administrativa, autorización, etc.

El proceso:

- Cierra la tarea en `COMPLETADA`.
- Llama a los servicios de cierre: «Finalizar CA PCA», «Aceptar Autorización», «Subir documentos GD», «Finalizar Solicitud» y «Guardar impresión CA».
- Escribe el estado: `PDTE_FINALIZAR`, `FINALIZADA_POSITIVO` o `CANCELADA`.
- Lanza el siguiente comando: Decidir, CrearAccion o Finalizar.

Si algún paso falla, escribe un `SCA2 Error` con `comando = "SCA2 CMD CompletarAccion"`. En TEST hay 10.

### 6.2 ¿Qué significa que un error esté PENDIENTE?

**Comprobado.** `SCA2 Error.estado` puede tener estos valores:

| Estado | Significado | En TEST |
|---|---|---|
| **PENDIENTE** | El fallo se ha registrado y **nadie lo ha tratado todavía**. La solicitud se quedó en el paso que falló. | 73 |
| **RELANZADO** | Alguien pulsó Relanzar en la bandeja. `SCA2 CMD MarcarErrorRelanzado` lo marca y vuelve a lanzar el comando. Si falla otra vez, se crea un error nuevo. | 19 |
| **DESCARTADO** | Alguien lo dio por resuelto sin relanzar. | 47 |
| **BLOQUEADO** | La bandeja lo ofrece como filtro. En esta ronda no se ha comprobado qué proceso escribe este estado. | 10 |

Además:

- Solo puede haber **un** error PENDIENTE por (solicitud, comando, nodo, código). Lo garantizan la UNIQUE `ux_sca2_error_pendiente_clave`, que existe en TEST desde el 17/11, y la regla `SCA2_obtenerErrorPendiente`. Si el mismo fallo se repite, se reutiliza la fila y aumenta `intentos`.
- La pestaña Errores cuenta por comando lo que falló. Los comandos con más errores en TEST son RefrescarCacheCabecera (44), Decidir (40) y Alta (21).

### 6.3 Quitar «Errores pendientes más recientes»

**Propuesta.** Borrar el bloque. Objetos: solo `SCA2_CuadroMando`. Riesgo bajo. Ver 5.2 y la duda 14.

---

## 7. Pestaña Trazabilidad

**Comprobado.** Muestra `SCA2 Trazabilidad Cliente` con tres gráficas: operaciones por sistema, operaciones por perfil de usuario y resultado de las operaciones.

**Propuesta.** Quitarla de `local!tabs` y del `choose`. Los datos se siguen guardando: solo deja de verse en el cuadro. Objetos: solo `SCA2_CuadroMando`. Riesgo bajo.

---

## 8. Cambios en «Errores - Sistema Comercial de Anulaciones» (`SCA2_BandejaErrores`)

### 8.1 Filtros por Nodo, Código y Mensaje, con búsqueda

**Comprobado.** Hoy la bandeja tiene estos filtros:

- **Estado**: por defecto `PENDIENTE`.
- **Comando**: desplegable con una **lista fija** de 10 comandos (Alta, Decidir, CrearAccion, CompletarAccion, Finalizar, Mecanizar, Caducar, Posponer, CambiarNivel, ObtenerDocumentoGD) y filtro `starts with`.
- **Solicitud**: texto, igualdad.
- **Fecha desde**.

La tabla ya muestra Nodo, Código y Mensaje. En TEST hay 15 nodos distintos, 14 códigos y 23 mensajes.

**Propuesta.**

- **Nodo y Código:** `a!dropdownField` con `searchDisplay: "ON"`, que es la búsqueda dentro del combo propia de Appian. Las opciones se calculan a partir de los valores que existen en `SCA2 Error`, con agrupación por `nodo` o `codigo` y respetando los demás filtros. Así, al buscar o filtrar, el combo solo ofrece valores con resultados.
- **Comando:** pasar a la misma lógica dinámica. La lista fija actual no incluye comandos que sí aparecen en errores, como `SCA2 CMD RefrescarCacheCabecera`.
- **Mensaje:** los textos son largos y muy variables (incluyen ids y fechas). Propuesta: un campo de texto «contiene» (`a!queryFilter(… operator: "search" …)` o `includes`) en lugar de un combo (duda 15).
- Objetos: solo `SCA2_BandejaErrores`. Riesgo bajo.

### 8.2 Relanzar o descartar en bloque lo filtrado, de forma controlada

**Comprobado (situación actual):**

- La tabla (`a!gridField`) no permite selección.
- **Relanzar** es fila a fila. Llama a `a!startProcess(cons!SCA2_PM_CMD_MARCAR_ERROR_RELANZADO, {idError, idSolicitud, comando}, isSynchronous: true)`.
- `SCA2 CMD MarcarErrorRelanzado` hace tres cosas:
  1. Marca el error como `RELANZADO` con `resueltoPor` y `fechaResolucion`.
  2. Prepara los parámetros (`SCA2_parametrosRelanzarCompletarAccion`, `SCA2_parametrosRelanzarAlta`).
  3. Lanza el comando que corresponde: Decidir, CrearAccion, CompletarAccion, Finalizar, Mecanizar, Caducar, Alta o MecanizarNSE.
- `SCA2 TTQ GrabarTreboles` se relanza con su integración y un `a!writeRecords`.
- **Descartar** es un `a!writeRecords` que pone `estado = "DESCARTADO"`, `resueltoPor` y `fechaResolucion`.
- Solo se ofrece Relanzar para los comandos de `local!cmdsRelanzables`.

**Propuesta de mecanismo (no implementado):**

1. **Selección.** Activar `selectable` en la tabla y añadir un botón «Seleccionar todo lo filtrado». El botón vuelve a lanzar **la misma consulta con los mismos filtros** y guarda solo los `id`. Así el lote coincide siempre con lo que se ve en pantalla y nunca con la tabla entera. Solo se admiten errores en `PENDIENTE`; si el filtro de estado es otro, el botón queda desactivado.
2. **Límite.** Como máximo 50 errores por lote (constante `SCA2_MAX_LOTE_ERRORES`). Si lo filtrado supera el límite, la pantalla avisa y pide filtrar más.
3. **Confirmación.** Un diálogo con el número de errores, cuántos por comando y la acción elegida.
4. **Cola y espaciado.** Un proceso nuevo, `SCA2 CMD RelanzarLote`, recibe la lista de `id` y la procesa **de uno en uno**:
   - Antes de cada error, vuelve a leer su fila. Si ya no está en `PENDIENTE` (porque otro usuario lo trató), lo salta y lo anota como «omitido».
   - **Relanzar:** llama a `SCA2 CMD MarcarErrorRelanzado` como subproceso **síncrono**, el mismo camino que el botón individual. No se duplica la lógica de cada comando.
   - **Descartar:** el mismo `Write Records` que hoy, de uno en uno.
   - Entre cada elemento espera un tiempo configurable (constante `SCA2_ESPERA_LOTE_SEG`, propuesta 10 s). Si el comando falla, la espera sigue igual: no se acelera.
   - Lo lanza la pantalla con `a!startProcess(isSynchronous: false)`. El usuario no espera y puede cerrar la pantalla.
5. **Un solo lote a la vez.** Antes de empezar, el proceso comprueba si ya hay otro lote en curso. Si lo hay, la pantalla no deja lanzar otro.
6. **UNIQUE `ux_sca2_error_pendiente_clave`.** Al relanzar, el error pasa a `RELANZADO` **antes** de lanzar el comando: así lo hace hoy `MarcarErrorRelanzado`. Por tanto, si el comando vuelve a fallar, se crea un PENDIENTE nuevo sin chocar con la UNIQUE. Lo que no se debe hacer es relanzar en paralelo dos errores con la misma clave. La cola de uno en uno lo evita.
7. **Fallo a mitad del lote.** Cada error se trata por separado. Si uno falla, el lote sigue con los demás. Al terminar, el lote queda con el resultado: tratados, omitidos y fallidos.
8. **Auditoría.**
   - Cada error guarda `resueltoPor` y `fechaResolucion`, como ahora.
   - Se registra una fila en `SCA2 Transicion` con `comando = "SCA2 CMD RelanzarLote"`, el usuario, el número de elementos y el resultado.
   - Si se quiere guardar la lista de ids del lote, hace falta una tabla nueva `sca2_error_lote` con SQL preparado (duda 16).
9. **Por qué no lanzar todos a la vez (deducido).** Cada relanzamiento llama a servicios de CORE, PCA, SGC y GD. Lanzar 50 a la vez multiplicaría esas llamadas y, en Mecanizar, las instancias que esperan a Verti (ver 2.2).

Objetos afectados:

- `SCA2_BandejaErrores`.
- Un modelo de proceso nuevo, `SCA2 CMD RelanzarLote`.
- Dos o tres constantes nuevas.
- Opcionalmente, una tabla nueva de lote.

`SCA2 CMD MarcarErrorRelanzado` y los comandos de negocio no cambian.

Riesgo: medio, porque relanzar actúa sobre las solicitudes. Se probaría primero en TEST con lotes de 2 a 3 errores.

---

## 9. Dudas para los analistas

Cada duda lleva una propuesta por defecto. Si no se indica otra cosa, se aplicará esa propuesta.

1. **Fecha del filtro.** ¿Desde/Hasta deben seguir filtrando por **fecha de creación** de la solicitud, o quieren la **última actuación** (`modifiedAt`)? *Por defecto:* mantener la creación y rotular «Fecha de alta de la solicitud».
2. **Calendario.** El selector de Appian solo navega por meses y años y obliga a pulsar un día; no se puede cambiar. ¿Les sirve añadir botones de periodo rápido y un texto de ayuda? *Por defecto:* sí, con los botones «Últimos 30 días», «Últimos 90 días», «Año en curso» y «Desde el inicio de SCA2».
3. **Fecha de inicio de datos.** En TEST el primer dato es del 24/09/2026. ¿Qué fecha ponemos en PRO? ¿Solo avisamos, o impedimos elegir una fecha anterior? *Por defecto:* una constante por entorno y solo un aviso.
4. **Comparación con base de datos.** ¿Con qué tabla y con qué filtro compararon («da menos registros»)? *Por defecto:* el cuadro solo muestra lo que ha pasado por SCA2, y se añade un texto que lo diga.
5. **Verti y Mecanizar (contradicción aparente).** El estado de la solicitud **no** espera a Verti: se fija antes y la rama principal sigue en paralelo. Solo la instancia de `SCA2 CMD Mecanizar` sigue activa hasta que vuelve el componente CMP. ¿Quieren además que la inducción salga de Mecanizar y vaya a un proceso independiente? Eso cambia el flujo acordado por paridad con SCA. *Por defecto:* no cambiar el flujo, quitar el aviso y corregir su texto en la nueva tarta.
6. **Tarta Verti: «con error».** Hoy no se guarda si el componente Verti falló. ¿Les vale de momento una tarta con «Terminada» y «Sin terminar»? Para añadir «Con error» hay que cambiar `SCA2 CMD Mecanizar` y saber qué devuelve el CMP cuando falla. ¿La tarta debe contar la inducción automática (`INDUCCION`) o la tarea del gestor «Gestión VERTI/Vencimiento» (`VERTI`)? *Por defecto:* fase 1 con `INDUCCION` y dos porciones; «Con error» queda para otra ronda.
7. **Etiquetas de estado.** Con `SCA2_textoEstadoSolicitud`, las solicitudes en `ERROR` (15 en TEST) se suman a «Solicitud Pendiente». ¿Las mostramos aparte como «Con error»? *Por defecto:* sí, aparte.
8. **Detalle de la causa.** ¿Prefieren barras apiladas (causa × detalle, con los detalles en la leyenda) o una tabla «Causa → Detalle» debajo de la gráfica? *Por defecto:* barras apiladas, ordenadas por total.
9. **Nombre «Gestiones».** Si la gráfica de tareas pasa a llamarse «Gestiones por tipo y estado», el indicador «Gestiones registradas» (comandos) se confunde con ella. ¿Lo renombramos? *Por defecto:* «Pasos ejecutados (comandos)».
10. **Desglose de «Finalizado».** El cuadro no junta nada: lo que sale como «FINALIZADA» es lo que se guarda así al cerrar, sin un estado más concreto. ¿Basta con mostrarlo con la etiqueta funcional, o quieren que los procesos guarden el tipo de cierre (`FINALIZADA_NEG_CONTRA`, `FINALIZADA_NO_REQ`, …)? Lo segundo cambia procesos fuera del cuadro. *Por defecto:* solo la etiqueta ahora, y el desglose real queda en una ronda aparte.
11. **COMPLETADA y FINALIZADA en la gráfica de gestiones.** ¿Las mostramos por separado («Cerrada por el gestor» y «Cerrada por el sistema») o juntas como «Cerrada»? *Por defecto:* por separado, con esas etiquetas.
12. **Indicadores de la pestaña Tareas.** Al quitarla, se pierden los indicadores de tareas pendientes y las tareas por grupo. ¿Movemos alguno a la pestaña Resumen? *Por defecto:* mover solo «Tareas pendientes».
13. **Orden del tiempo de respuesta.** ¿Por tiempo medio o por tiempo máximo? *Por defecto:* por tiempo medio.
14. **Lista de errores fusionada.** Piden fusionarla con «Errores pendientes más recientes» y también quitar esa lista de la pestaña Errores. ¿En qué pestaña va la lista única? *Por defecto:* una lista «Errores recientes (procesos y servicios)» en la pestaña Errores, con una columna Origen.
15. **Filtro por Mensaje.** Hay demasiados mensajes y muy largos para un combo. ¿Les vale un campo de texto «contiene»? *Por defecto:* sí. Nodo, Código y Comando serían combos con búsqueda.
16. **Acción en bloque.** Proponemos un límite de 50 por lote, 10 segundos entre cada uno, solo errores PENDIENTE y un lote a la vez. ¿Lo aceptan? ¿Quién puede usarlo? ¿Descartar en bloque debe pedir un motivo? ¿Hace falta guardar la lista de cada lote (tabla nueva)? *Por defecto:* esos valores, cualquier usuario con acceso a la bandeja, sin motivo, y auditoría en `SCA2 Transicion` sin tabla nueva.
