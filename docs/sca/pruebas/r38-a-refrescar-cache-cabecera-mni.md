# R38-A — `SCA2 CMD RefrescarCacheCabecera`: revisión MNI y errores de campos de la caché de cabecera

Entorno: **Appian TEST** (`mapfrespain-test`), aplicación SCA2. Fecha: 30/10/2026. Sesión hija R38-A (coordinación en [`coordinacion-ronda38.md`](coordinacion-ronda38.md)).

Petición: «revisa el modelo SCA2 CMD RefrescarCacheCabecera para ver si se puede optimizar con un MNI, para que no sea un proceso que tenga un bucle muy grande. Además, revisa los errores de la consola sobre los campos de la cabecera de caché».

## 1. Resumen

| Tema | Resultado |
|---|---|
| MNI en el PM | **No se aplica.** Es viable técnicamente, pero no mejora lo suficiente para compensar los riesgos (§4). El PM **no se ha modificado** (sigue en v6.0, temporizador 07:05 intacto). |
| Errores de campos de la caché | **Corregido.** Causa: el campo `polizaFechaultimosiniestro` guarda, en pólizas Vida, el **enlace GESVIDA (~287 caracteres)** y la columna es `VARCHAR(255)`: el refresco lo recortaba (avisos `REFRESCO_CACHE_RECORTE`, antes `value too long for type character varying(255)`) y la cabecera servida desde caché mostraba el enlace **truncado**. Ahora se guarda sin el prefijo fijo y se recompone al leer (§5). |
| Regresión | Alta nueva (póliza 0731900095024, solicitud 15788603) → CA y detalle con cabecera correcta, sin errores de evaluación en consola (§6). |
| Hallazgos de §7 (decididos por el usuario después) | Caducidad a las **05:00 Europe/Madrid** (§10); **una sola fila por solicitud** y limpieza de duplicados (§11); fila id 471 borrada (§12); **refresco programado desactivado** por decisión funcional (§13). |

## 2. Estado actual del PM (v6.0, sin cambios)

![PM en Designer](../img/r38a-pm-designer.png)

![Temporizador 07:05](../img/r38a-pm-timer.png)

![Zona horaria Europe/Madrid](../img/r38a-pm-zona-horaria.png)

Flujo (uuid `0000f095-81a8-8000-d613-7f0000014e7a`, archivado automático a los 7 días):

```text
Inicio 07:05 → Seleccionar filas caducadas → ¿Quedan filas? ──no──→ ¿Hubo recorte? → Fin
                                                │sí
                    ┌──────────── Siguiente ◄───┤ (indice+1, limpia variables)
                    │                           ▼
                    │                  Cargar cabecera en vivo (timer 2 min → Anotar error)
                    │                           ▼
                    │                  ¿Cabecera válida? ──no──→ Anotar error → Registrar en SCA2 Error
                    │                           ▼ sí
                    │                  Actualizar fila caché (Write Records, recorte opcional)
                    │                           ▼
                    └──── Contar renovada ◄── ¿Escritura correcta? ──no──→ Anotar error → SCA2 Error
```

- **Selección:** filas `SCA2 Datos Cabecera` con `origenCache = CACHE`, `validaHasta <= now()` y solicitud abierta, ordenadas por `validaHasta`, **máximo `cons!SCA2_CACHE_REFRESCO_BATCH` = 50** por ejecución.
- **Por fila:** 1 carga en vivo (`SCA2_obtenerDatosCabeceraLive`, ~15 integraciones) + 1 Write Records; ~6–8 nodos ejecutados por iteración.
- El PM no escribe en `SCA2 Transicion` (no es un comando de solicitud); R36 no le afecta.

### Métricas de las ejecuciones (variables de proceso por LCP)

| Proceso | Fecha | Filas | Solicitudes distintas | Procesadas | Errores | Duración aprox. |
|---|---|---|---|---|---|---|
| 9114790 | 22–28/10 | 28 | 26 | 28 | 0 | ~3 min |
| 11218107 | 22–28/10 (v3.0) | 28 | 26 | 22 | 6 (`varchar(255)`) | ~3 min |
| 537586185 | 29/10 07:05 | 50 | 34 | 50 | 0 (3 avisos de recorte) | ~4 min 45 s |
| 14391740 | 30/10 07:05 | 4 | 3 | 4 | 0 (3 avisos de recorte) | ~24 s |
| **537589429** | **30/10 08:02 (prueba R38-A, manual)** | **50** | — | **50** | **0** | **~5 min** |

![Monitorización](../img/r38a-monitorizacion.png)

![Inicio y fin](../img/r38a-monitorizacion-horas.png)

![Variables del proceso 537589429](../img/r38a-proceso-variables-procesadas.png)

![Sin errores de instancia](../img/r38a-proceso-errores.png)

Coste medio: **~5,7 s por fila**, dominado por la carga en vivo (servicios CORE/API), no por el motor de procesos. Máximo por instancia: 50 iteraciones ≈ 350–400 nodos. Appian no muestra AMU/memoria por instancia en la monitorización de la app.

## 3. Datos de la caché (antes de la prueba)

458 filas; 238 con `origenCache = CACHE` para 132 solicitudes; **106 solicitudes con 2 filas** (duplicadas); 91 filas caducadas a las 07:00.

## 4. MNI frente a otras opciones — decisión

| Opción | Ventaja | Inconvenientes en este PM |
|---|---|---|
| A. Bucle actual por lotes de 50 (sin cambios) | Aislamiento de errores por fila (timer 2 min, registro en SCA2 Error), lote acotado por constante, 1 instancia de proceso | Tiempo secuencial (~5 min para 50) y ~400 nodos por instancia |
| B. Subproceso por fila con **MNI** (secuencial) | Elimina el bucle del diagrama | Mismo tiempo; 50 instancias hijas extra al día (más carga de motor y archivado); **LCP no expone la configuración MNI** (ningún nodo SCA2 la tiene y el JSON no trae el campo) → solo se configura en Designer y una edición posterior por LCP podría perderla sin aviso |
| C. Subproceso con **MNI en paralelo** | Tiempo total mucho menor | 50 cabeceras × ~15 llamadas simultáneas a CORE/API Clients a las 07:05 (riesgo de timeouts y saturación); los contadores `procesadas`/`errores` y el aviso de recorte hay que agregarlos desde 50 hijos |
| D. `a!forEach` + 1 escritura por lista | 4–5 nodos en total | 50 cargas en vivo en **una sola expresión** (~5 min, sin el timer de 2 min por fila); un fallo de escritura invalida el lote entero; Appian recomienda no encadenar integraciones en bucles de expresión |

**Decisión: no modificar el PM.** El bucle ya está acotado a 50 iteraciones (lejos del límite de 1000 instancias MNI y de los avisos de bucles grandes), el tiempo lo marcan los servicios externos y no el número de nodos, y las alternativas empeoran el aislamiento de errores, la carga sobre CORE o la mantenibilidad por LCP. Si en el futuro se quiere procesar **todas** las filas caducadas cada día (hoy 91 > 50), la opción recomendada sería B/C con un subproceso por **lote** (p. ej. 25 filas por hijo, MNI sobre los lotes) y configurar el MNI en Designer; queda como decisión (§8).

## 5. Errores de campos de la caché: causa y corrección

**Evidencia (SCA2 Error, bandeja de errores):**
- 29/10 06:05 (ids 177–181): `Actualizar fila caché` → `value too long for type character varying(255)`.
- 30/10 06:05 (ids 184–186): `REFRESCO_CACHE_RECORTE` → «Campos recortados al límite de su columna: polizaFechaultimosiniestro 287/255».
- En Monitorización no hay errores de proceso (las incidencias se registran como avisos y el PM termina `COMPLETED`).

**Causa raíz:** `SCA2_obtenerDatosCabeceraLive` (copia de SCA) rellena `datosPoliza.fechaUltimoSiniestro` con el **enlace GESVIDA** (`cons!SCA2_TXT_LINK_GESVIDA_CABECERA` de 116 caracteres + póliza + nombres de tomador/asegurado) cuando la póliza es de Vida. La columna `POLIZA_FECHAULTIMOSINIESTRO` de `sca2_datos_cabecera` es `VARCHAR(255)`; el usuario `devin` no puede cambiar el DDL. Resultado: escrituras fallidas (antes) o enlace recortado (después del recorte de R37), y la cabecera servida desde caché mostraba un enlace incompleto (filas 402/403 con 255 caracteres).

**Corrección (sin cambiar firma ni tabla):**

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_construirFilaCacheCabecera` (uuid `_a-0000f09f-42ed-8000-9d42-011c48011c48_5649210`) | v1 → **v2** | Al construir la fila del PM, si el valor empieza por `cons!SCA2_TXT_LINK_GESVIDA_CABECERA` se guarda sin ese prefijo |
| `SCA2_renovarCacheCabecera` (`_a-0000f093-2064-8000-9d36-011c48011c48_5607622`) | v2 → **v3** | Mismo cambio en la fila que escribe la Web API |
| `SCA2_obtenerDatosCabecera` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20053304`) | v6 → **v7** | Al leer de caché, si el valor no empieza por `http` y contiene `&stGNombreTomador=`, antepone el prefijo → enlace completo |

Cada regla: lectura viva → backup JSON local → reemplazo de una sola línea → relectura (expresión idéntica a la enviada, mismas entradas, 2 líneas de diferencia). Fechas normales (`dd/mm/aaaa`) y nulos no cambian.

**Pruebas de la corrección:**

| Caso | Esperado | Real | OK/KO |
|---|---|---|---|
| `construir` con enlace de 318 caracteres | Se guarda sin prefijo (202) | 202 caracteres | OK |
| `construir` con fecha `15/03/2024` / nulo | Sin cambios | `15/03/2024` / nulo | OK |
| PM manual 537589429 (50 filas) | 0 errores, 0 avisos de recorte | 50 procesadas, `errores`/`excesosCache` vacíos, 0 filas nuevas en SCA2 Error | OK |
| Fila con enlace Vida escrita tras el cambio (id 471) | Guardada en 171 caracteres | 171 | OK |
| `obtener` v7 sobre esa fila | Enlace recompuesto de 287 caracteres, igual al vivo | 287, empieza por el prefijo GESVIDA | OK |
| `obtener` v7 en solicitudes sin enlace (15788436, 15788454) | Sin error | 0,2 s, sin error | OK |

## 6. Comparación de la caché antes/después y regresión

| Medida | Antes | Después |
|---|---|---|
| Filas `SCA2 Datos Cabecera` | 458 | 461 (+2 de la solicitud nueva 15788603, +1 fila `X`/`X` §8) |
| Filas renovadas | — | 52 (50 PM + 2 por Web API) |
| Campos cambiados | — | `fechaCache` y `validaHasta` (52/50); contenido: solo `polizaVehiculo` (24, dato vivo `1,576 → 1,578`) y 3 filas con datos de cliente actualizados en origen |
| Longitud máx. `polizaFechaultimosiniestro` | 255 (recortado) | 171 (codificado) |
| Avisos/errores de recorte | 3 por ejecución | 0 |

Muestra: filas 230/231/233 (solicitudes 15788204/05/08) conservan nombre y producto (`TERCEROS AMPLIADO`, `BASICAR TR CON FRANQUICIA`, `TODO RIESGO 100`); solo cambian `fechaCache` (→ 30/10) y `validaHasta` (→ 31/10).

Regresión UI (JJGONZ2, testing agent): alta nueva con la póliza **0731900095024** (Hogar) → solicitud **15788603** → CA con cabecera de cliente/póliza correcta y detalle correcto; sin argumentos ejecutados. Consola: ningún `pageerror`, warning ni error de evaluación/campos de la cabecera. Sí aparecen **38 errores HTTP 404** de recursos `https://mapfrespain-test.appiancloud.com/suite/...` cuya causa no se ha determinado (no se relacionan con la cabecera; quedan como duda §8).

![Solicitud nueva](../img/r38a-regresion-solicitud-id.png)

![Consola](../img/r38a-consola.png)

![CA con cabecera](../img/r38a-regresion-ca-cabecera.png)

![Detalle](../img/r38a-regresion-detalle.png)

## 7. Hallazgos no corregidos (fuera del encargo)

1. **Hora de caducidad en GMT:** las filas se graban con `validaHasta = 07:00 GMT` (08:00 en Madrid en invierno, 09:00 en verano), mientras que el temporizador corre a las 07:05 Madrid. A las 07:05 la mayoría de filas aún no ha caducado: la ejecución diaria del 30/10 solo encontró 4 filas, y la caché sirve datos del día anterior hasta las 08:00. Afecta a `SCA2_calcularValidaHastaCache`.
2. **Filas duplicadas por solicitud:** 106 de 132 solicitudes tienen 2 filas de caché; la solicitud nueva 15788603 generó 2 filas en 3 s (inserciones simultáneas de la Web API al abrir la cabecera). La lectura usa la más reciente, pero el PM renueva ambas (doble llamada en vivo).
3. Hoy el servicio en vivo ya no devuelve el enlace GESVIDA para 0000063001441/0000063001442 (vacío), aunque a las 07:05 sí lo hacía: el dato de origen varía.

## 8. Riesgos y dudas (para decidir)

- Lote de 50: decidido **no tocar** (la cabecera renueva en vivo al abrir si está caducada); con el refresco programado desactivado (§13) ya no aplica.
- Hora de caducidad (§7.1): **resuelto**, 05:00 Madrid (§10).
- Duplicidad (§7.2): **resuelto**, una fila por solicitud (§11).
- Fila id 471 (`X`/`X`): **borrada** con backup (§12).
- 38 errores HTTP 404 de recursos `/suite/...` en la consola: decidido **no tocar**.
- Alternativa definitiva al recorte: ampliar la columna `POLIZA_FECHAULTIMOSINIESTRO` (requiere DDL de BD).

## 9. No probado y motivo

- Cabecera de una solicitud **Vida nueva** en la UI con el enlace GESVIDA: no hay póliza Vida libre en el bloque de reserva; verificado por regla (`obtener` v7 recompone 287 caracteres).
- AMU/memoria por instancia: Appian no lo muestra en la monitorización de la aplicación.

Backups locales (fuera del repo, sin secretos): `pm_live_before.json`, `bk_construir_v1_before.json`, `bk_renovar_v2_before.json`, `bk_obtener_v6_before.json`, `cache_before.csv`, `cache_after.csv`.

## 10. Caducidad a las 05:00 de Madrid (decisión del usuario)

Decisión: «la idea es que caduque a las 5 am de España […] para asegurarnos que cuando empieza la jornada laboral no haya nada antiguo».

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_HORA_CADUCIDAD_CACHE_CABECERA` | v1→v3 | Valor 7 → **5**. Descripción actualizada (sin refresco programado). |
| `SCA2_TXT_ZONA_HORARIA_CACHE_CABECERA` | nueva (v1) | Texto `Europe/Madrid`: zona en la que se interpreta la hora. |
| `SCA2_calcularValidaHastaCache` | v1→v2 | Devuelve el **primer corte a las 05:00 Madrid posterior a la carga**. Construye los cortes de los días −1…+2 a la hora de la constante y los pasa a GMT con `gmt(…, cons!SCA2_TXT_ZONA_HORARIA_CACHE_CABECERA)`, de modo que no depende de la zona del usuario ni del proceso y cambia sola entre invierno (04:00 GMT) y verano (03:00 GMT). |

Antes, la regla usaba la zona del contexto (en PM y Web API, GMT): las filas caducaban a las 07:00 GMT = 08:00/09:00 en Madrid.

Pruebas por `POST /expression-rules/{uuid}/test` (resultado en GMT, 12/12 correctas):

| Carga (GMT) | `validaHasta` (GMT) | En Madrid |
|---|---|---|
| 30/10/2026 09:15 (hoy) | 31/10/2026 04:00 | 31/10 05:00 CET |
| 30/10/2026 03:30 | 30/10/2026 04:00 | 30/10 05:00 CET |
| 30/10/2026 04:00 (justo en el corte) | 31/10/2026 04:00 | 31/10 05:00 CET |
| 30/10/2026 23:30 | 31/10/2026 04:00 | 31/10 05:00 CET |
| 15/07/2026 09:15 (verano) | 16/07/2026 03:00 | 16/07 05:00 CEST |
| 15/07/2026 02:30 | 15/07/2026 03:00 | 15/07 05:00 CEST |
| 15/07/2026 03:30 | 16/07/2026 03:00 | 16/07 05:00 CEST |
| 24/10/2026 09:00 (víspera cambio de hora) | 25/10/2026 04:00 | 25/10 05:00 CET |
| 24/10/2026 23:30 | 25/10/2026 04:00 | 25/10 05:00 CET |
| 28/03/2026 12:00 (víspera cambio a verano) | 29/03/2026 03:00 | 29/03 05:00 CEST |
| 29/03/2026 12:00 | 30/03/2026 03:00 | 30/03 05:00 CEST |
| 31/12/2026 23:59 | 01/01/2027 04:00 | 01/01 05:00 CET |

Además: con `hora = 7` explícita devuelve 06:00 GMT (07:00 Madrid) y con fecha nula devuelve nulo. La regla la usan `SCA2 CMD Alta` (nodo `Write Datos`), `SCA2_construirFilaCacheCabecera` (PM de refresco) y `SCA2_renovarCacheCabecera` (Web API): todos pasan a grabar 05:00 Madrid sin tocarlos. Fila real renovada por la Web API tras el cambio: solicitud 15788603, `validaHasta = 2026-10-31 04:00:00` GMT (05:00 Madrid).

## 11. Una sola fila de caché por solicitud (decisión del usuario: «no debería haber duplicados»)

**Causa.** La Web API `SCA2_refrescarCacheCabecera` (la llama la cabecera al abrirla si la caché está caducada o no existe) buscaba la fila previa antes de la carga en vivo (≈5–8 s) y solo entre las filas `CACHE`. Dos evaluaciones casi simultáneas de la cabecera (p. ej. la carga de la página y su recarga, o dos pestañas) no encontraban fila y las dos insertaban (106 parejas `CACHE+CACHE` separadas 3–6 s). Las 6 parejas «fila parcial sin origen + CACHE» venían de altas antiguas con el interruptor de caché apagado.

**Solución (sin DDL):**

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_obtenerIdFilaCacheCabecera` | nueva (v1) | Id de la fila de la solicitud con **mayor id, de cualquier origen** (`null` si no hay). |
| `SCA2_obtenerFilasDuplicadasCacheCabecera` | nueva (v2) | Filas de la solicitud **salvo la de mayor id**, listas para `a!deleteRecords` (`{}` si no sobra ninguna). |
| `SCA2_renovarCacheCabecera` | v3→v4 | La fila a actualizar es la de `SCA2_obtenerIdFilaCacheCabecera`, y se consulta **después** de la carga en vivo (reduce la ventana de carrera de ≈6 s a milisegundos). Si existe una fila parcial del alta, se reutiliza y pasa a ser `CACHE` completa: no se pierde nada, porque la fila completa contiene todos los campos de la parcial. |
| `SCA2_obtenerDatosCabecera` | v7→v8 | Si la caché está vigente pero la solicitud tiene **más de una fila**, va por la ruta de la Web API (carga en vivo, reescribe la fila de mayor id y borra las demás). Cubre el duplicado que deja `SCA2 CMD Alta` (ver abajo). Con una sola fila no cambia nada (sigue sirviéndose de caché, 0,2 s). |
| Web API `SCA2_refrescarCacheCabecera` | Designer | En el `onSuccess` de `a!writeRecords`, `a!deleteRecords` de las filas sobrantes de la solicitud (misma respuesta 200 con éxito o error del borrado). Si aun así dos llamadas insertan a la vez, la que termina después borra la de menor id: siempre queda 1 fila. |

**Criterio de unificación.** Se conserva una fila por solicitud: la `CACHE` más reciente (en la limpieza) o la de mayor id (en la escritura, que tras la limpieza es la única). Los lectores de la tabla (`SCA2_obtenerDatosCabecera`, `SCA2_cargarSolicitud`, `SCA2_DetalleCabecera`, `SCA2_esPropietarioPoliza`, `SCA2_evaluarPropietarioContraAnulacion`, `SCA2_invalidarCacheCabecera`) toman una sola fila: con una fila por solicitud todos leen la misma.

**`SCA2 CMD Alta` no se modifica.** La prueba con una solicitud nueva (15788604, §14) mostró que el alta deja siempre dos filas: durante el propio proceso (269154000, 07:51:19–07:51:41 GMT) la cabecera se evalúa, no encuentra fila y llama a la Web API (fila 474, 07:51:23), y después el nodo de escritura del alta inserta la suya sin buscar la existente (fila 475, 07:51:29). En lugar de editar el alta, `SCA2_obtenerDatosCabecera` v8 detecta las dos filas en la primera apertura y deja una por la Web API (coste: una carga en vivo de 5–8 s en esa primera apertura). No se guarda el PM por LCP porque eso hace que sus subprocesos graben el usuario de la sesión en los datos. **PM de refresco**: actualiza la fila seleccionada por su id, no crea filas; con una fila por solicitud, una llamada por solicitud.

**Limpieza (30/10/2026).** Backup previo de las 460 filas y de las 113 que se borran (fuera del repo: `cache_pre_limpieza.csv`, `backup_filas_borradas.csv`). Borradas con una regla temporal `a!deleteRecords` (eliminada después): 106 `CACHE` antiguas de parejas `CACHE+CACHE`, 6 filas parciales de parejas parcial+`CACHE` y la fila 471 (§12). Resultado: **347 filas, 347 solicitudes, 0 duplicados**. La solicitud 15788603 (dos filas, 472/473) quedó con una al llamar a la Web API nueva: se borró la 472.

**Propuesta (no aplicada, requiere DDL):** índice único sobre `ID_SOLICITUD` en la tabla de `SCA2 Datos Cabecera`. Con él la segunda inserción simultánea fallaría en vez de duplicar; antes habría que confirmar que ningún flujo inserta a propósito dos filas.

## 12. Fila id 471 (decisión del usuario: «puedes borrar esa fila»)

Contenido guardado antes de borrar: `id 471`, `idSolicitud X`, `polizaNumeropoliza X`, `tipoPoliza/polizaLineanegocio Vida`, `origenCache CACHE`, `fechaCache 2026-10-30 06:55:27`, `validaHasta 2026-10-31 07:00:00` (GMT), cliente vacío (`clienteApellidos " "`, `clienteCarterizado Sí`, `clienteNuumapropietario "null"`), producto `" - "`, acuerdo `" - "`, clave `" / "`, vehículo `" /  / 0 años"`, prima `-`, siniestros 0, enlace GESVIDA solo con los parámetros vacíos. Borrada en la limpieza del §11; comprobado por API que no queda.

## 13. Refresco programado desactivado (decisión funcional)

Decisión: «la renovación de la caché la hace SOLO el usuario al abrir la cabecera (recarga en vivo si caducada/inexistente). NO muevas el temporizador a las 06:00: DESACTÍVALO […] sin borrar el PM ni sus nodos (el PM queda disponible para lanzarse a mano)».

- **Antes** (Designer, evento de inicio `Inicio 07:05` → Desencadenadores): desencadenador `Timer Diario 07:05`, recurrencia diaria a las 07:05, zona `pm!timezone` (Madrid). Designer 26.x no tiene casilla de activar/desactivar el temporizador; desmarcar «Recurrencia del temporizador» lo habría dejado como arranque único, así que se **retiró solo el desencadenador**.
- **Después**: PM publicado **v7.0**; el evento de inicio muestra «No hay eventos configurados». Se conservan el nodo `Inicio 07:05`, los 13 nodos, las 9 variables, conexiones y expresiones (comparación LCP antes/después nodo a nodo). Única diferencia de serialización: en `Actualizar fila caché` y `Registrar en SCA2 Error` desaparece el literal `value: 1` de `PauseOnError`, que mantiene su expresión `=false()` (equivalente).
- **Arranque manual**: proceso 537589544 (PM v7.0), 07:43:40–07:47:51 GMT, COMPLETED, 43 filas procesadas, sin errores de escritura.
- Para volver a programarlo basta con añadir de nuevo el desencadenador Timer en el evento de inicio.

Capturas: `../img/r38a-pm-timer-antes.png`, `../img/r38a-pm-timer-condiciones-antes.png`, `../img/r38a-pm-zona-horaria-antes.png`, `../img/r38a-pm-timer-desactivado.png`, `../img/r38a-pm-designer-despues.png`, `../img/r38a-pm-manual.png`.

## 14. Pruebas de fila única y caducada (datos nuevos)

Ronda con datos nuevos (usuario de pantalla JJGONZ2, sitio SCA2; filas comprobadas por API). Fechas en GMT; `31/10/2026 04:00` GMT = 05:00 Madrid.

| Caso | Esperado | Real | OK/KO | Solicitud |
|---|---|---|---|---|
| Alta nueva (v7) | 1 fila | **2 filas** (474/475, 07:51:23/07:51:29): la Web API durante el alta y el nodo de escritura del alta. Motivó `SCA2_obtenerDatosCabecera` v8 (§11) | KO → corregido | 15788604 (póliza 0731900342035, Hogar) |
| Abrir la cabecera con 2 filas vigentes (v8) | Queda 1, la de mayor id | 474/475 → **475**, CACHE, `fechaCache 07:56:20`, `validaHasta 31/10 04:00` | OK | 15788604 |
| Tres recargas | Misma fila y fecha (se sirve de caché) | 475 sin cambios | OK | 15788604 |
| Alta nueva (v8) y primera apertura | 2 filas tras el alta, 1 tras abrir | 477/478 → **478** (08:01:22) | OK | 15788607 (póliza 2002500019302, Autos) |
| Dos pestañas JJGONZ2 a la vez (clics con 1 ms de diferencia), partiendo de 2 filas (clon temporal de 478) | Queda 1 | 478/479 → **479** (`fechaCache 08:08:38`); dos recargas paralelas más sin cambios | OK | 15788607 |
| Fila caducada (`validaHasta` puesta a 29/10 04:00 con una regla temporal, ya borrada) | Al abrir, recarga en vivo y queda 1 fila con el siguiente corte | Fila **479**, CACHE, `fechaCache 08:15:40`, `validaHasta 31/10 04:00` (05:00 CET) | OK | 15788607 |
| Recuento global final | 0 solicitudes con más de una fila | **350 filas, 0 duplicadas** (08:17:27) | OK | Todas |
| CA y detalle | Mismos datos de cabecera | Cabecera coincidente en alta, detalle y CA; argumentos sin ejecutar | OK | 15788604, 15788607 |
| Consola | Sin errores de campos de cabecera | 0 errores de cabecera; quedan 5 HTTP 404 `/suite/...` ya conocidos (fuera de alcance) y 1 aviso de metadatos | OK | 15788604, 15788607 |

Las reglas temporales de prueba (clon de fila y caducar fila) se borraron tras usarlas (GET 404).

Capturas: `../img/r38a-r3-15788604-detalle-1600.png`, `../img/r38a-r3-cache-estable-1600.png`, `../img/r38a-r3-alta-generada-1600.png`, `../img/r38a-r3-jjg-dos-pestanas-final-1600.png`, `../img/r38a-r3-recargas-paralelas-estables-1600.png`, `../img/r38a-r3-caducada-renovada-1600.png`, `../img/r38a-r3-ca-cabecera-1600.png`, `../img/r38a-r3-ca-argumentos-pendientes-1600.png`.

**Límites:**
- Sin índice único en BD, dos escrituras exactamente simultáneas pueden dejar dos filas un instante; la siguiente apertura las reduce a una (v8). La garantía estructural es la propuesta DDL del §11.
- Sigue sin verse en pantalla una cabecera Vida con el enlace GESVIDA largo (no hay póliza Vida libre en el bloque de reserva).
- La primera apertura tras cada alta hace una carga en vivo (5–8 s) para dejar una sola fila. Evitarlo exigiría que el nodo de escritura de `SCA2 CMD Alta` reutilice la fila existente (`rule!SCA2_obtenerIdFilaCacheCabecera`); no se ha hecho porque guardar ese PM con el usuario técnico deja rastro en los datos de sus subprocesos. **Decisión pendiente del usuario.**
