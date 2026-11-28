# R34-B — Mantenimiento SCA2: argumentos y conceptos (puntos 3, 4, 5 y 7 del 5.º «Análisis SCA2»)

Entorno: Appian **TEST** (`mapfrespain-test`). Fecha: 27/10/2026. Usuario de pruebas en pantalla: `devin` (los usuarios NO PRO JJGONZ2 y SISANS no tienen permiso en el mantenimiento).
Leyenda: **Observado** = visto en pantalla o en la respuesta del servicio; **Inferido** = deducción a partir de lo observado; **Pendiente** = no se pudo comprobar.

## 1. Resumen por punto

| Punto | Problema del analista | Causa raíz | Corrección | Resultado |
|---|---|---|---|---|
| 3 | Campaña y URL vacíos en alta/modificación | `SCA2_consultarConceptoReutilizable` tenía un control `typeof(...) = typeof(a!map())` (añadido en la fase 0, v2 del 24/09) que descartaba la respuesta del servicio (no es un `map`) y devolvía `null`. **No es regresión de la ronda 32** (la v3 de la ronda 32 sólo cambió literales por constantes). | Se quita sólo ese control (v3→v4). | **Observado:** CAMP devuelve 16 opciones y URL 3; los desplegables tienen opciones en alta y modificación; la opción elegida se graba y se relee (TTQAUTOS/Gesvida en el alta; PAGOTARJ/Club Mapfre en la modificación). |
| 4 | Tras ACTUALIZAR no se ven grabados estado, descripción, campaña, compañía, documento, checks, instrucciones, observaciones | El guardado sí llega a CORE con todos los campos (**observado**). El mantenimiento volvía a leer el argumento del catálogo Aurora (`SCA2_consultarTipoArg` con `SCA2_USAR_CATALOGOS_AURORA = 1`), que es una copia cargada el 26/10 y no se actualiza al guardar: la pantalla enseñaba los datos antiguos. El check «económico» sí parecía grabarse porque se lee con otro servicio (`SCA2_obtenerMarcaEconomica`), no del catálogo. **No es regresión de la ronda 32.** | Lecturas del mantenimiento de argumentos cambiadas a `SCA2_consultarTipoArgCore` (lee CORE directamente). | **Observado:** modificación de 991 cambiando todos los campos → releído en pantalla y en CORE: todos grabados (tabla 4.2). |
| 5 | El 999 está en BD pero no sale en el listado | Misma causa: el listado leía Aurora y el 999 se dio de alta en CORE después de la carga del catálogo (Aurora 343 argumentos sin 999; CORE 344 con 999). No era filtro, paginación ni ramo. | Igual que el punto 4. | **Observado:** el 999 aparece en el listado SCA2; el nuevo 991 aparece en el listado nada más darlo de alta. |
| 7 | BAJAPRIM no aparece ni está en BD | El alta de valor envía a CORE la **lista completa** de valores del concepto (`SCA2_guardarConcepto`) y CORE **sustituye** la lista. La pantalla construía esa lista a partir del catálogo Aurora, desactualizado respecto a CORE (p. ej. Aurora tenía `ESPTTQ18`, que CORE ya no tenía). **Inferido:** BAJAPRIM pudo grabarse y desaparecer en una escritura posterior que reenviara la lista antigua; no hemos podido reproducir el caso exacto del analista ni consultar la BD. | Lecturas de gestión de conceptos cambiadas a `SCA2_consultarConceptoCore` y sincronización del catálogo Aurora tras alta/borrado de valor. | **Observado:** alta de `PRUEBA_DEVIN_R34_2` por pantalla → aparece en listado, en CORE y en Aurora, y se conservan los 16 valores previos. |

## 2. Objetos modificados (sólo SCA2, Appian TEST)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_consultarConceptoReutilizable` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052825` | 3 → 4 | Quitado el control `typeof` que devolvía `null`. |
| `SCA2_GestionArgumentos` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053041` | 4 → 5 | 3 lecturas `SCA2_consultarTipoArg` → `SCA2_consultarTipoArgCore`. |
| `SCA2_AltaGestionArgumento` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063439` | 2 → 8 | Versión final = v2 original + lectura `SCA2_consultarTipoArgCore`. Las v3–v7 (intentos de sincronizar Aurora al guardar) se descartaron, ver §5. |
| `SCA2_GestionConceptosYClases` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053047` | 2 → 3 | Lectura → `SCA2_consultarConceptoCore`. |
| `SCA2_ValoresConceptoGestionConceptosyClases` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052987` | 2 → 3 | Lectura → `SCA2_consultarConceptoCore`. |
| `SCA2_AnadirGestionConceptosyClases` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052843` | 2 → 3 | 3 lecturas → Core; tras alta/modificación de valor, recarga del catálogo Aurora `VALOR_CONCEPTO` (`SCA2_catConstruirCarga` + `a!writeRecords`). |
| `SCA2_EliminarValorConcepto` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052837` | 2 → 3 | 2 lecturas → Core; recarga Aurora `VALOR_CONCEPTO` tras borrar. |
| `SCA2_AltaGestionConcepto` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051566` | 2 → 5 | Versión final idéntica a la v2 original (las v3/v4 con sincronización se revirtieron). |

No se han tocado constantes, objetos SCA/SCAC/CMP/CORE/NSE, ni los objetos de R34-A. Cada cambio siguió: lectura del objeto vivo → copia local → cambio mínimo → escritura → relectura y comparación; render/validación por LCP sin errores.

## 3. Datos de prueba

| Dato | Cómo se creó | Estado final |
|---|---|---|
| Valor CAMP `PRUEBA_DEVIN_R34_1` | Servicio (LCP) | Eliminado por pantalla. |
| Valor CAMP `PRUEBA_DEVIN_R34_2` | Pantalla | Eliminado por pantalla. |
| Argumento 991 (`PRUEBA_DEVIN_R34_991` → `_MOD`) | Pantalla | **Inactivo** (el mantenimiento no permite borrar). |
| PDF de prueba del 991 (V5–V8) | Pantalla | Asociado al 991 inactivo. |

Estado final comprobado: CAMP en CORE y Aurora = los 15 valores originales; 999 una sola vez en Aurora. No se tocaron 999, 981, 982 ni BAJAPRIM (sólo lectura).

Incidencias de datos creadas y corregidas durante la prueba (catálogo Aurora, tablas propias de SCA2):
- Una versión intermedia de la sincronización insertó el 999 **duplicado** en Aurora (ids 344 y 345). Se dio de baja lógica sólo el id 345 desde «Catálogos CORE (Aurora)».
- Una operación de prueba por servicio reintrodujo temporalmente `ESPTTQ18` en CORE; se restauró en el momento a la lista correcta.
- Tras eliminar `PRUEBA_DEVIN_R34_1`, Aurora lo seguía mostrando; se corrigió con «Recargar desde CORE» de Valores de concepto.

## 4. Pruebas

### 4.1 Campaña y URL (a)
- Alta: opciones en ambos desplegables (`r34b-alta-campana-opciones.png`, `r34b-alta-url-opciones.png`).
- Alta 991 con TTQAUTOS/Gesvida/compañía 1 → reabierto muestra los mismos valores (`r34b-991-relectura.png`).
- Primer intento con campaña `PRUEBA_DEVIN_R34_1`: CORE responde «Error al generar la insercion» y no crea el argumento (`r34b-alta-991-error.png`). **Inferido:** el código de campaña (18 caracteres) excede el campo; los códigos reales tienen ≤ 10. Es comportamiento del servicio, no de SCA2.

### 4.2 Modificación de todos los campos (b) — 991
| Campo | Pedido | Pantalla | CORE |
|---|---|---|---|
| Estado | Inactivo | Inactivo | `S` |
| Descripción | PRUEBA_DEVIN_R34_991_MOD | = | = |
| Campaña | PAGOTARJ | Pago Tarjeta Bonificado | PAGOTARJ |
| URL | Club Mapfre | Club Mapfre | URL Club Mapfre |
| Compañía | 41 | 41 | 41 |
| Documento | PDF de prueba | asociado, «Ver documento» visible | nombre e id documental nuevos |
| Finaliza en positivo / variable / Te cuidamos / tréboles | marcados | marcados | `S` |
| Económico | marcado | marcado | (servicio aparte) |
| Instrucciones / observaciones | textos nuevos | = | = |

Con la versión final (v8): guardado sin documento nuevo y con PDF nuevo → mensaje «El argumento se guardó correctamente», todo releído en pantalla y CORE (`r34b-v8-991-*.png`, vídeo `r34b-v8`).

### 4.3 Inserción y listado (c)
991 aparece en el listado inmediatamente tras el alta (`r34b-991-listado.png`); 999 visible (`r34b-cierre-sca2-999-listado.png`).

### 4.4 Conceptos (d)
`PRUEBA_DEVIN_R34_2` por pantalla → listado, CORE y Aurora (`r34b-camp-antes.png`, `r34b-camp-despues.png`). Limpieza final: `r34b-final-camp-antes.png`, `r34b-final-camp-15.png`, `r34b-final-recarga-valores.png`.

### 4.5 Paridad con SCA (e) — **Pendiente**
`devin`, JJGONZ2 y SISANS: la raíz `/suite/sites/sca` redirige a SCA2 y `/suite/sites/sca/page/gestiones-mantenimiento` da **403** (`r34b-cierre-sca-403.png`, `r34b-final-sisans-sca-403.png`). JJGONZ2/SISANS tampoco ven el mantenimiento de SCA2 (`r34b-final-jjgonz2-sca2.png`, `r34b-final-sisans-sca2.png`). No se pudo comparar en pantalla. Por código (sólo lectura): SCA lee los argumentos y conceptos directamente del servicio CORE, que es lo que hace ahora SCA2.

## 5. Limitación: el catálogo Aurora de argumentos no se actualiza solo
Se intentó sincronizar Aurora (`TIPO_ARGUMENTO`) al pulsar GUARDAR en `SCA2_AltaGestionArgumento` (v3–v7). Appian sólo permite **un** «smart service» por clic y ese botón ya ejecuta la subida de ficheros (`a!submitUploadedFiles`) y el borrado del documento temporal: con la sincronización salía el error «Attempted to run a second smart service…» (aunque CORE grababa), y encadenarla con `onSuccess` no lo resolvió (`r34b-v4/v5/v6/v7-*-error-*.png`). Se volvió a la lógica original (v8) sin error.

Consecuencia: tras dar de alta o modificar argumentos, el catálogo Aurora (que usan otras pantallas de SCA2, p. ej. contra anulación, mientras `SCA2_USAR_CATALOGOS_AURORA = 1`) queda desactualizado hasta pulsar **«Recargar desde CORE» → Tipos de argumento** en «Catálogos CORE (Aurora)» (probado: 345 filas, sin error). En valores de concepto la sincronización automática funcionó en el alta, pero tras un borrado Aurora conservó el valor borrado hasta la recarga manual (**inferido:** respuesta en caché del servicio CORE en la misma operación).

## 6. Dudas para el analista / decisión funcional
1. ¿Se acepta que, tras mantener argumentos o conceptos, haya que pulsar «Recargar desde CORE», o se prefiere otra solución (recarga programada, o que las demás pantallas lean CORE)? Es una decisión de diseño fuera del lote.
2. Confirmar si BAJAPRIM se volvió a dar de alta: con la corrección debería quedarse (ver §1, punto 7).
3. Paridad SCA: hace falta un usuario con acceso al mantenimiento de SCA en TEST.
4. El código de campaña tiene un tamaño máximo en CORE (inferido ≤ 10): sólo afecta a valores de prueba, los reales caben.

## 7. Evidencias
Vídeos (adjuntos al mensaje final): `r34b-principal`, `r34b-continuacion`, `r34b-v4`…`r34b-v7` (error de smart service), `r34b-v8` (versión final OK), `r34b-cierre`, `r34b-final-limpieza`. Capturas en `docs/sca/img/r34b-*.png`.
