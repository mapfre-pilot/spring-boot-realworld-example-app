# R29-C — contacto reutilizable y CMP en paralelo

**Entorno:** Appian TEST, evidencias LCP y recorrido de pruebas del 23/10/2026.  
**Alcance:** reutilización de la respuesta REST de contacto y paralelización del CMP en `SCA2 CMD Mecanizar`. Este informe no incorpora datos personales ni el contenido de la respuesta de contacto.

## 1. Objetivo y puntos del analista

La coordinación de la ronda denomina esta columna «R29-C contacto reutilizable / CMP en paralelo» (`coordinacion-ronda29.md`). El brief operativo separa los cambios como «Regla única de contacto» y «paralelo» (`~/sca2work/r29c/BRIEF.md`). Las fuentes locales no contienen una transcripción literal adicional del analista sobre la caché; no se atribuyen citas que no estén documentadas.

El límite de almacenamiento sí consta literalmente en el brief: «Si LCP solo admite VARCHAR(255), aplicarlo igualmente y no guardar `a!toJson` si supera 255 caracteres; dejar que la llamada se haga en vivo y anotarlo».

La pregunta registrada por R29-A para el hallazgo D-R29A-4 (`r29-a-redireccion-verti-tarjetas.md`):

> «con la mecanización en paralelo al componente, ¿la decisión debe esperar a que CORE confirme la anulación (como SCA) antes de decidir nivel/FIN?»

Objetivos implementados:

- Evitar que cada evaluación de `SCA2_determinarContacto` vuelva a invocar el REST para una solicitud cuya respuesta ya se ha almacenado.
- Abrir el CMP de inducción por la rama A mientras la rama B continúa la mecanización y la CA de nivel 2 sin esperar al cierre del CMP.
- Leer la opción Verti/Vencimiento de la tarea MECANIZAR para seleccionar el tipo de inducción.

## 2. Solicitudes y comparaciones

| Aplicación y solicitud | Póliza | Recorrido / resultado relevante |
|---|---:|---|
| SCA2 `15788319` | `2002600060637` | Recorrido previo a la corrección del transporte de caché: no se guardó respuesta. Opción Verti; se abrió el CMP con RGPD. La Web API aún recibía el POST JSON mientras esperaba parámetros de query y devolvía 500. |
| SCA2 `15788323` | `2002600060638` | Recorrido posterior a la corrección. Opción Vencimiento; el CMP abrió «Captura de vencimientos completos», sin la pantalla RGPD. La caché se guardó tras la CA negativa. |
| SCA `15788316` | `2002600060642` | Recorrido de Vencimiento; no había CA nivel 2 mientras el CMP seguía abierto. Al continuar, la llamada terminó en 403. Captura local: `/home/ubuntu/screenshots/ss_a6802ad6.png` (referencia únicamente; no se adjunta ni se sube). |
| SCA `15788322` | `2002600060631` | Alta creada sin querer al comparar el aviso de flota. SCA2 mostró aviso por flota/wAutemis y no dejó continuar con `0631`/`0632`; SCA permitió crear con `0631` sin ese aviso. Es una divergencia del ALTA fuera de esta columna. La existencia de solicitudes SCA2 para `0631`/`0632` no está confirmada. |

Las evidencias de alta y navegación están en `~/sca2work/r29c/testing/` (capturas de los recorridos SCA2 y SCA, y de la comparación de flota), además de los ficheros `LCP_SCA2_*`, `LCP_SCA_*` y `LCP_process_*`.

## 3. Contacto: llamadas, caché y límites

### Inventario antes del cambio

`NOTAS.md` identifica estos consumidores de `SCA2_determinarContacto` / `SCA2_determinarContactoREST`:

1. `SCA2 CMD CrearAccion`, nodo 3 «Cargar», durante la condición de pantalla Verti (trabajo de R29-A).
2. `SCA2_VertiVencimientoPrincipal`, evaluación de `local!determinarContacto`.
3. `SCA2 CMD Mecanizar`, nodo 16 «Cargar», asignación a `pv!contacto`.

La regla original resolvía el resultado a partir del cuerpo del REST (`a!fromJson(body)`) o `null`; por tanto, cada evaluación que alcanzaba esa regla podía volver a llamar al servicio.

### Funcionamiento después del cambio

Se implementó P1. Para una solicitud con `codSolicitud`, `SCA2_determinarContacto` primero consulta `SCA2 Datos Solicitud.respContacto`. Si hay JSON, lo devuelve desde caché; si no, llama a `SCA2_guardarContactoIntegracion`, que invoca la Web API `SCA2_guardarContacto`. La Web API reutiliza una respuesta ya guardada o llama a Live y guarda la respuesta cuando existe fila, no hay valor previo y la serialización cabe en 255 caracteres. Si la respuesta supera 255 caracteres, no se guarda y se recurre a Live en las llamadas posteriores.

El campo de alta existente `contacto` permanece intacto. Los campos nuevos son `respContacto` (`VARCHAR(255)`) y `fechaRespContacto` (Date and Time). LCP limitó el tamaño de `respContacto` a 255, inferior al objetivo inicial de 4000.

La integración pasó a transmitir los 16 inputs como query parameters; la Web API quedó con `requestBodyType=NONE` y lee `http!request.queryParameters`. Esto corrige el 500 del recorrido inicial: la integración enviaba JSON en el body, mientras la Web API debía seguir el patrón de `sca2-cache-cabecera` basado en query parameters. La corrección se registró a las **11:29 UTC** del 23/10/2026. La Web API directa y la integración dieron 204 / éxito para `codSolicitud="0"` después del cambio.

### Evidencia de caché

- **15788319, pre-fix:** no hay caché guardada para ese recorrido; el transporte de la Web API todavía fallaba con 500. Esta ejecución no demuestra una lectura posterior desde caché.
- **15788323, post-fix:** `respContacto` se guardó tras la CA negativa. La respuesta JSON compacta mide **165 caracteres** y `fechaRespContacto` es **2026-10-23 13:42:51 CEST**.
- Las lecturas de caché tras Verti, ANULAR, CMP abierto y CMP enviado conservaron el mismo `id`, `lenResp=165` y fecha `23/10/2026 13:42 CEST`. Evidencias: `LCP_SCA2_15788323_02_cache_Verti.txt`, `_03_post_Vencimiento.txt`, `_04_CMP_abierto.txt`, `_05_post_CMP.txt` y `_06_cache_precisa.txt`.

La estructura de la respuesta de contacto es `{listaContactos[], url}`. **Riesgo para confirmar con el analista:** el JSON cacheado conserva la `url` de tarea de la primera llamada (`sites/inducir/task/<token>`). Si un consumidor usa esa URL después, utilizará la de la primera llamada, no una URL nueva. ¿Es correcto cachearla junto con el resto de la respuesta?

**Formato de fecha:** el REST responde 400 si `fechaAnulacion` no se envía como `yyyy-MM-dd`. La integración transmite esa fecha como texto en dicho formato.

## 4. Paralelo en `CMD Mecanizar`

### SCA2: ramas A y B

En `SCA2 CMD Mecanizar`, el XOR 331 («¿Inducir Verti?») conserva el camino de «no» hacia 324. En el camino «sí», el nodo 332 escribe la tarea de inducción y abre dos salidas:

```text
331 sí → 332 Write Tarea INDUCCION
             ├─ Rama A, encadenada: 334 SUB CMP → 333 Write cierre INDUCCION → 341 End Inducción
             └─ Rama B, no encadenada: 324 → … → espera/gestión ANL → cambio de nivel → Start CrearAccion
331 no ───────────────────────────────────────────────→ 324
```

La primera pantalla del CMP puede abrirse por la rama A mientras la rama B sigue su curso. La conexión 332→334 está encadenada y 332→324 no encadenada; 333 lleva al nuevo End 341.

### Comparación con SCA

En `SCA_Mecanizacion`, el nodo 24 tiene dos salidas: inducción Verti (nodo 28) y ANL Alta (nodo 12), con el AND 23 y la actualización síncrona mediante `SCA_PB_buclesActualizarMecanizacion`. Esa topología no permite afirmar que SCA espere a que se envíe el CMP para actualizar la mecanización: en SCA `15788316`, CORE pasó de «Mecanización Enviada» a «ANULACION REALIZADA» mientras el CMP seguía abierto y aún no se había enviado.

La diferencia demostrada por estos recorridos es más acotada: SCA2 creó la CA de nivel 2 con el CMP abierto; en SCA `15788316` no se creó una CA de nivel 2 mientras el CMP estaba abierto (CORE seguía mostrando cuatro acciones). Es una observación de estos casos, no una afirmación general sobre todos los procesos SCA.

### Evidencias observadas

- SCA2 `15788319`: la rama B creó la CA de nivel 2 con el CMP abierto. CORE muestra acción 5 «ANULACION REALIZADA» y la nueva acción de nivel 2 `43706676` «INCOMPLETA»; la solicitud estaba en `EN_ACCION/CONTRA_ANULAR`. Evidencias del recorrido: `LCP_SCA2_15788319_03_CMP_abierto.txt`, `_04_post_CMP.txt`, `_05_final.txt`.
- SCA2 `15788323`: con el CMP abierto, la mecanización `43706683` figura «ANULACION REALIZADA» y se creó la CA de nivel 2 `43706684`. Evidencias: `LCP_SCA2_15788323_04_CMP_abierto.txt` y `_05_post_CMP.txt`.
- SCA `15788316`: a las 11:06 UTC, con el CMP abierto, CORE mostraba la mecanización `43706659` como «Mecanización Enviada». A las 11:17:49 UTC pasó a «ANULACION REALIZADA» con el CMP aún abierto y sin enviar; CORE seguía mostrando cuatro acciones y no apareció CA de nivel 2. El intento de continuar Vencimiento terminó en 403 (captura citada en §2).
- En SCA2 `15788323`, el proceso `CMD Decidir` corresponde al proceso `14361705`. No se localizó el proceso principal `CMD Mecanizar` de esa solicitud en el rango `14361600`–`14361900`.

## 5. `tipoInduccion` y opción R29-A

El nodo 334 consulta `SCA2 Tarea.tokenTarea` por `id = pv!idTarea`, lote 1. `SCA2_MecanizacionPrincipal` pasa el id de la tarea MECANIZAR como `pv!idTarea`. Los tokens con prefijo `VERTI:` se mapean así:

| Token | `tipoInduccion` |
|---|---|
| `VERTI:VERTI` | `I` |
| `VERTI:VENCIMIENTO` | `V` |
| `VERTI:VERTI VENCIMIENTO` | `A` |
| nulo, tarea inexistente u otro valor | `I` |

Fragmento de extracción y normalización:

```sail
local!opcion: if(
  and(left(local!tokenTareaMec, 6) = "VERTI:", len(local!tokenTareaMec) > 6),
  upper(trim(right(local!tokenTareaMec, len(local!tokenTareaMec) - 6))),
  ""
)
```

El prefijo se elimina solo al inicio; no se usa una sustitución global. La regla temporal `SCA2_tmpR29cMapeo(token)`, UUID `_a-0000f097-8800-8000-9d3b-011c48011c48_5616702`, pasó los cinco casos de prueba: `VERTI:VERTI`→`I`, `VERTI:VENCIMIENTO`→`V`, `VERTI:VERTI VENCIMIENTO`→`A`, `null`→`I` y `OTRO`→`I` (HTTP 200 en todos). En SCA2 `15788323`, la opción Vencimiento abrió «Captura de vencimientos completos» sin RGPD (`26_SCA2_15788323_solo_vencimiento.png` y `28_SCA2_15788323_CMP_vencimiento_abierto.png`).

## 6. Hallazgo R29-A D-R29A-4

En SCA2 `15788314`, la solicitud terminó en FIN con la mecanización «INCOMPLETA»; la decisión de FIN se toma en `CMD Decidir`, nodo 5 «Consultar reglas». Es el hallazgo D-R29A-4 documentado por R29-A. En `15788319` y `15788323`, la rama B creó la CA de nivel 2 antes o alrededor de la confirmación de CORE, con CMP abierto. Esos recorridos muestran que la rama puede avanzar; no prueban que retrasar la decisión hasta `ANULACION REALIZADA` hubiera cambiado la regla/decisión de FIN.

La comparación de SCA `15788317` corresponde a **otra póliza**, por lo que no es un control de la misma póliza. No se cambió la lógica de decisión. Se mantiene para el analista la pregunta registrada en R29-A:

> «con la mecanización en paralelo al componente, ¿la decisión debe esperar a que CORE confirme la anulación (como SCA) antes de decidir nivel/FIN?»

La decisión funcional pendiente se concreta así: ¿esperar a `ANULACION REALIZADA` antes de decidir, como hace SCA en secuencia?

## 7. Cierre y límites de observabilidad

La inducción sigue figurando **«En Curso»** después de enviar el CMP en SCA2 `15788319` y `15788323`. Comprobación LCP posterior (≈12:05 UTC) de 15788319: `SCA2 CMD Mecanizar` 14361587 ACTIVE (`currentTaskCount=1`), `CMP Inducir Cliente` 14361592 ACTIVE y `CMP Inducir Cliente Fase 2` 14361593 ACTIVE con 1 tarea. Es decir, el propio componente CMP sigue abierto (fase 2 asíncrona, p. ej. consentimiento/firma no inmediata) y por eso la rama A no ha llegado al nodo 333 (cierre de la tarea INDUCCION) ni al End 341: no se ha demostrado un defecto de cierre de SCA2, pero tampoco el cierre. En R28 (15788296) la tarea INDUCCION se cerró en ≈2,5 min cuando el CMP terminó. Para 15788323 no se localizó el proceso principal (`/processes` lista → 501; búsqueda acotada 14361600–14361900 sin resultado); su `CMD Decidir` 14361705 terminó COMPLETED 11:42:53 UTC. La rama B ya terminó su trabajo (CA nivel 2 creada) en ambas: la solicitud no queda bloqueada por el CMP. Pendiente: confirmar el cierre de la rama A cuando el CMP termine (o caduque a los 60 min) — no hay endpoint LCP de nodos/tareas (501).

Los endpoints LCP `/processes/{id}/nodes` y `/tasks` devolvieron **501** en la consulta documentada en `LCP_SCA2_proceso_nodos_tareas.txt`; no se pudo usar esa vía para confirmar el estado final de nodos/tareas. Las capturas y los ficheros de recorrido se conservan en `~/sca2work/r29c/testing/`.

## 8. Objetos modificados y fragmentos SAIL

| Objeto | UUID | Versión / cambio registrado |
|---|---|---|
| Record type `SCA2 Datos Solicitud` | `9a9209c7-aab4-4078-9bef-280de47fdd6e` | v4→v6; 31→33 campos. Añadidos `respContacto` (`71db6fce-b013-4cd0-9282-e768b00cf052`, Text/VARCHAR(255)) y `fechaRespContacto` (`1a702174-fa60-4582-a0e5-cbf3d217dcb2`, Date and Time). `contacto` original no se alteró. |
| Regla `SCA2_cargarSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | v9→v10; incluye los dos campos de caché. |
| Regla `SCA2_determinarContacto` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051500` | v1→v2. |
| Regla nueva `SCA2_determinarContactoLive` | `_a-0000f097-8800-8000-9d3b-011c48011c48_5615156` | Creada, v1. |
| Web API nueva `SCA2_guardarContacto` (`sca2-contacto`) | `e36a8789-e01b-4bf7-9120-08563d379f79` | Creada; LCP no expone versión numérica. Configurada con `requestBodyType=NONE` y query parameters. |
| Integración `SCA2_guardarContactoIntegracion` | `0f24a431-894a-44ac-bdbf-b53eb4bf0ca1` | Creada v1; actualización a v2 para POST/QUERY con 16 parámetros, `bodyContent=null` e `ignoreEmptyQueryParameters=true`. |
| PM `SCA2 CMD Mecanizar` | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | LCP no expone `versionId`; 42→43 nodos al añadir las ramas y End 341 (UUID `073cb6ff-927b-4e6f-a0ea-b877e6ddf9a2`). En una actualización posterior solo cambió el input `tipoInduccion` del nodo 334; re-GET: 43 nodos. |
| Regla temporal `SCA2_tmpR29cMapeo` | `_a-0000f097-8800-8000-9d3b-011c48011c48_5616702` | Creada v1; cinco casos LCP correctos. |
| Regla temporal `SCA2_tmpR29cLeerCacheContacto` | `_a-0000f097-8800-8000-9d3b-011c48011c48_5616731` | UUID registrado en notas; versión no consignada en las evidencias locales. |

La rama de lectura de caché devuelve el JSON guardado:

```sail
a!fromJson(local!cachedJson)
```

En una ausencia de caché se invoca `SCA2_guardarContactoIntegracion` con los mismos inputs; si la integración falla, se recurre a `SCA2_determinarContactoLive`. La Web API persiste solo cuando existe fila, la caché está vacía y se cumple:

```sail
len(local!responseJson) <= 255
```

La escritura guarda `respContacto` y `fechaRespContacto: now()`. El campo de alta `contacto` no forma parte de esa escritura.

En el nodo 334, la consulta obtiene el campo de R29-A mediante `a!queryRecordType`/`a!queryFilter`; el mapeo resultante es `VERTI VENCIMIENTO`→`A`, `VENCIMIENTO`→`V`, `VERTI`→`I`, por defecto `I`. La expresión completa, con UUID de record type/campos, queda en `/home/ubuntu/sca2work/r29c/CAMBIOS.md` y en los backups del PM.

## 9. Grabación

- Grabación anotada única (8 min 49 s): `R29C_UI-edited.mp4` (no se sube al repo; adjunta en el mensaje final de la sesión).
- Informe UI y capturas fuera del repo: `~/sca2work/r29c/testing/INFORME_UI.md`, `30_LCP_cache_post_CMP_15788323.png`, `29_SCA2_15788323_post_CMP_induccion_abierta.png`, `20_SCA_CMP_403.png`.
