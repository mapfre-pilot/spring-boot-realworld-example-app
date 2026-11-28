# R42-A — respaldo y COMPROBAR AHORA

Fecha: **03/11/2026**. Entorno: **Appian TEST / SCA2**, UI real en incógnito con JJGONZ2. Solo medición y creación de solicitudes expresamente autorizadas; **sin modificar objetos Appian, sin ANULAR PÓLIZA y sin commit**.

## Resultado y límites

- **Pasó la validación del fix DetalleTareas v41:** en `15788712`, dos comprobaciones manuales a +2,339 y +15,265 s conservaron «Procesando la decisión…», el aviso, COMPROBAR AHORA y ACEPTAR deshabilitado. La siguiente tarea real, **Gestión Verti/vencimiento**, apareció a **51,913 s** desde SI; solo entonces quedó ACEPTAR habilitado.
- **Adelanto observado en alta:** en `15788715`, COMPROBAR AHORA a +20,164 s produjo el estado listo **0,466 s después**, total **20,630 s**, antes del ciclo natural observado en las altas de control (~34 s). Diferencia frente al alta sin clic de `15788708`: **13,739 s**. Son solicitudes distintas, no un contrafactual de la misma ejecución ni una garantía de duración.
- **CA adicional:** `15788715` quedó lista a **30,672 s**, 0,465 s después del clic manual a +30,207 s. **No se puede atribuir el adelanto exclusivamente al clic:** coincide con el primer ciclo de sondeo de 30 s.
- **Incidencia histórica corregida, no ocultada:** con DetalleTareas v40 + temporal CA v66, `15788710` habilitó ACEPTAR a +2,323 s sin siguiente tarea. No se pulsó ese ACEPTAR; la tarea real llegó a +37,004 s. El caso nuevo v41 no reprodujo esa habilitación prematura.
- **Regresión positiva:** `15788713` volvió al buscador sin esperar 90 s. Su tarjeta CA aparecía inicialmente **Incompleta**, aunque la solicitud ya era positiva; en consulta tardía a `11:47:51.565Z` (+366,616 s desde la confirmación) ya era **Finalizada Positiva**. Se documenta como **desfase transitorio**, sin conocer el instante exacto de actualización. Comparación de solo lectura `15788704`: Finalizada Positiva.
- No se observaron errores de expresión SAIL en los recorridos ejecutados. Las reconsultas mostraron una solicitud por póliza utilizada.
- Esto prueba el **estado de respaldo forzado de forma controlada**, no un `onIncomplete` natural por superar 30 s en una llamada síncrona. No se validó por agotamiento el límite de 90 s ni todas las rutas administrativas/autorización/mecanización.

## Versiones y método

1. Alta v45 / CA v65: async solo para `0731380586960` y `0731380586989`. El usuario aclaró que v65 no cubría `onFinalizar` del modal: la primera CA fue síncrona y **no se repitió**.
2. CA v66 (TEMP2): añadió el modal; permitió detectar la habilitación prematura en `0731380586989`.
3. Alta v46 / CA v67: añadieron `0731380586910` y `0732300150954` a la lista temporal. DetalleTareas **v41** añadió `local!esperandoDecision`, manteniendo la espera si la acción está cerrada pero aún falta la siguiente tarea y el estado no es final. Límite comunicado: `SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS = 90`.
4. Fuentes consultadas, sin editarlas: `/home/ubuntu/sca2work/r42a/despues/SCA2_DetalleTareas.v41.sail` (446–457, 580–607, 775–879, 1217–1225), `SCA2_AltaSolicitudPage.TEMPb.sail` (1068–1078), `SCA2_ContraAnulacionOpciones.TEMP2b.sail` (2304–2350 y 3294–3405).

Mismo método ANTES/DESPUÉS: Playwright sobre CDP `localhost:29229`, clic real UI y captura de UTC + `performance.now()`; muestra DOM cada ~150 ms con `main.innerText`, visibilidad y atributo `disabled`. Las capturas corroboran visualmente los estados. No se usa «Cargando» como detector.

**Listo alta:** «Su solicitud se ha generado correctamente» y ACEPTAR habilitado. **Listo CA:** texto de siguiente tarea/redirección real y ACEPTAR habilitado, sin «Procesando la decisión» ni confirmación pendiente. «CORRECTO» solo **no** es finalización.

UTC y reloj monotónico se capturan en instantes cercanos; diferencias de 1 ms por resolución/redondeo son posibles. `performance.now()` se reinicia al navegar: no se restan relojes de documentos distintos. Los tiempos principales se calculan sobre el mismo documento.

## Mediciones completas

Todos los timestamps son del 03/11/2026, **UTC**; la UI mostraba hora local UTC+1. Monotónicos en milisegundos.

| Caso | Póliza / solicitud | Clic UTC | Mono clic | Listo real UTC | Mono listo | Segundos | Resultado |
|---|---|---|---:|---|---:|---:|---|
| Alta sin pulsar, v45 | 0731380586960 / 15788708 | 11:19:10.852Z | 216164,6 | 11:19:45.222Z | 250533,9 | **34,369** | Sondeo natural |
| CA negativa, v65 no cubría modal | 0731380586960 / 15788708 | 11:22:57.043Z (SI) | 442355,3 | 11:23:09.452Z | 454764,8 | **12,409** | Síncrona; no prueba respaldo |
| Alta manual, v45 | 0731380586989 / 15788710 | 11:25:41.820Z | 116945,9 | 11:26:02.712Z | 137837,9 | **20,892** | 0,502 s tras manual |
| CA negativa, v66/v40 | 0731380586989 / 15788710 | 11:28:08.448Z (SI) | 263573,6 | 11:28:45.452Z | 300578,0 | **37,004** | Fallo previo: ACEPTAR prematuro |
| Alta manual, v46/v41 | 0731380586910 / 15788712 | 11:33:58.246Z | 168646,0 | 11:34:31.795Z | 202194,4 | **33,548** | Sondeo; clic a 20 s no adelantó |
| CA negativa, v67/v41 | 0731380586910 / 15788712 | 11:36:09.394Z (SI) | 299793,7 | 11:37:01.308Z | 351707,1 | **51,913** | Espera correcta tras ambos clics |
| Regresión alta fuera de lista | 2002500044508 / 15788713 | 11:39:37.372Z | 63072,3 | 11:39:52.169Z | 77869,2 | **14,797** | Síncrona, sin COMPROBAR/aviso |
| Alta manual adicional v46/v41 | 0732300150954 / 15788715 | 11:43:58.789Z | 57694,0 | 11:44:19.420Z | 78324,2 | **20,630** | Manual antes del sondeo |
| CA negativa adicional v67/v41 | 0732300150954 / 15788715 | 11:46:24.357Z (SI) | 203261,3 | 11:46:55.029Z | 233933,4 | **30,672** | Clic y sondeo coinciden |

### Clics COMPROBAR AHORA

| Caso | Clic manual UTC | Mono clic | Desde inicio | Desde manual hasta listo real | Estado al comprobar |
|---|---|---:|---:|---:|---|
| Alta 15788710 | 11:26:02.210Z | 137335,7 | 20,390 s | **0,502 s** | Generada correctamente tras clic |
| CA 15788710, fallo anterior | 11:28:10.214Z | 265339,8 | 1,766 s | 35,238 s | ACEPTAR habilitado indebidamente a +2,323 s; no siguiente tarea |
| Alta 15788712 | 11:34:18.468Z | 188867,5 | 20,221 s | **13,327 s** | Continuó esperando; listo por sondeo |
| CA 15788712, temprano | 11:36:11.734Z | 302133,1 | 2,339 s | 49,574 s | Procesando + aviso + COMPROBAR; ACEPTAR deshabilitado |
| CA 15788712, segundo | 11:36:24.659Z | 315059,1 | 15,265 s | **36,648 s** | Mismo estado de espera correcto |
| Alta 15788715 | 11:44:18.954Z | 77858,3 | 20,164 s | **0,466 s** | Generada correctamente; no hizo falta segundo clic |
| CA 15788715 | 11:46:54.564Z | 233468,6 | 30,207 s | **0,465 s** | Siguiente tarea real; no hizo falta segundo clic |

En `15788710` se adelantó intencionadamente la comprobación CA para verificar el bloqueo temprano: produjo el hallazgo que motivó v41; no se ejecutó un segundo clic a 15 s cuando COMPROBAR ya había desaparecido indebidamente. En `15788715` se programaron comprobaciones cada ~5 s desde +20 s (alta) / +30 s (CA), pero ambas quedaron listas tras la primera y se detuvieron los clics.

### Aparición de espera y aviso

| Solicitud / acción | COMPROBAR AHORA visible desde | Aviso «Está tardando…» | ACEPTAR |
|---|---:|---|---|
| 15788708 alta natural | +3,514 s | No observado durante los 34,369 s | Deshabilitado hasta listo |
| 15788710 alta manual | +4,107 s | No observado | Deshabilitado hasta listo |
| 15788710 CA, v40/v66 | +0,814 s | Sí, +0,814 s | **Fallo:** habilitado a +2,323 s sin tarea real |
| 15788712 alta | +3,365 s | No observado | Deshabilitado hasta listo |
| 15788712 CA, v41 | +0,674 s | Sí, +0,674 s | Deshabilitado tras ambos clics hasta tarea real |
| 15788713 alta síncrona | No observado | No observado | Deshabilitado durante ejecución y habilitado al terminar |
| 15788715 alta | +3,743 s | No observado | Deshabilitado hasta listo |
| 15788715 CA | +0,495 s | Sí, +0,495 s | Deshabilitado hasta tarea real |

### FINALIZAR frente a SI

El inicio efectivo medido de la CA es **SI**, que confirma el modal. FINALIZAR solo abre la confirmación. Se conservan ambos clics para no mezclar espera humana y duración del proceso:

| Solicitud | FINALIZAR UTC | SI UTC | Listo desde FINALIZAR, aprox. | Listo desde SI |
|---|---|---|---:|---:|
| 15788708 | 11:21:49.813Z | 11:22:57.043Z | 79,640 s | 12,409 s |
| 15788710 | 11:28:03.448Z | 11:28:08.448Z | 42,004 s | 37,004 s |
| 15788712 | 11:36:04.526Z | 11:36:09.394Z | 56,781 s | 51,913 s |
| 15788715 | 11:45:11.008Z | 11:46:24.357Z | 104,021 s | 30,672 s |

El intervalo de 73,349 s entre FINALIZAR y SI del último caso fue preparación/instrumentación (selector literal `SI` no coincidía con el nombre accesible `Si`), **no** una espera del backend. La confirmación seguía abierta y el intento fallido no envió nada.

## Regresión de CA positiva fuera de la lista

`2002500044508` estaba libre y fuera de la lista temporal. Se creó solo `15788713`. Alta síncrona en 14,797 s. Para Automóviles, el argumento obligatorio disponible fue **INCREMENTO PRIMA SINIESTROS**, no el de Hogar; se seleccionó por UI y se ejecutó POSITIVO, seguido del ACEPTAR de la confirmación de retención.

- Confirmación: `11:41:44.949Z`, mono `190648,4`.
- Se observó vuelta al buscador en **≤5,3 s**; es un límite de observación, **no** un cronometraje terminal exacto comparable a las otras filas. El detector de siguiente tarea no corresponde a esta ruta de cierre.
- Primera reconsulta: solicitud «Finalizado Contra Anulación Positiva», tarjeta CA **Incompleta**.
- Consulta tardía: `11:47:51.565Z`, **366,616 s después** de confirmar; tarjeta **Finalizada Positiva**, Alta Finalizada, una solicitud. No se afirma que tardara 366,616 s en actualizar: solo que a esa hora ya se había actualizado.
- Comparación autorizada, solo lectura: `15788704`, póliza `0731800073132`, también mostraba Finalizada Positiva. La discrepancia ya se había observado en ANTES (`15788697`); aquí no se volvió a abrir esa solicitud.

| 🔴 Regresión: primera reconsulta, CA Incompleta | 🟢 Regresión: reconsulta tardía, CA Finalizada Positiva |
|---|---|
| ![Regresión inicial](https://mapfre.devinenterprise.com/attachments/63f6086d-2863-44fa-98d3-48dcd4231088/r42-a-respaldo-fix-v41-regresion-ca-positiva.png) | ![Regresión tardía](https://mapfre.devinenterprise.com/attachments/418f46cf-e31a-4903-a621-f957f8376b1f/r42-a-respaldo-fix-v41-regresion-ca-positiva-tardia.png) |

## Solicitudes y estados finales

Todas las pólizas nuevas se comprobaron libres antes del alta y se anotaron en [REGISTRO.md](polizas/REGISTRO.md), incluso los casos con limitaciones.

| Póliza | Solicitud | Etiqueta | Estado final observado |
|---|---|---|---|
| 0731380586960 | 15788708 | R42-A respaldo | Una solicitud pendiente; Alta Finalizada, CA Finalizada Negativa, Verti/vencimiento Incompleta |
| 0731380586989 | 15788710 | R42-A respaldo | Una solicitud pendiente; Alta Finalizada, CA Finalizada Negativa, Verti/vencimiento Incompleta |
| 0731380586910 | 15788712 | R42-A respaldo (fix v41) | Una solicitud pendiente; Alta Finalizada, CA Finalizada Negativa, Verti/vencimiento Incompleta |
| 2002500044508 | 15788713 | R42-A respaldo (regresión v41) | Una solicitud finalizada positiva; Alta Finalizada, CA Finalizada Positiva en consulta tardía |
| 0732300150954 | 15788715 | R42-A respaldo (fix v41) | Una solicitud pendiente; Alta Finalizada, CA Finalizada Negativa, Verti/vencimiento Incompleta |

Las gestiones siguientes quedaron pendientes deliberadamente: no se abrió mecanización ni se pulsó ANULAR PÓLIZA. No se tocaron solicitudes ajenas. Las reconsultas no demuestran exhaustivamente ausencia de envíos CORE duplicados, solo unicidad UI.

## Evidencias

### Fix v41: bloqueo preservado y siguiente tarea real

| 🔴 Comprobación temprana completada: sigue esperando | 🟢 Tarea real lista a 51,913 s |
|---|---|
| ![CA temprana v41](https://mapfre.devinenterprise.com/attachments/9f1a364c-632b-46fe-97a2-2b380be4e112/r42-a-respaldo-fix-v41-ca-manual-manual-1-despues.png) | ![CA lista v41](https://mapfre.devinenterprise.com/attachments/a6f19130-01fc-44a4-b003-ceecf059ed15/r42-a-respaldo-fix-v41-ca-manual-listo.png) |

| Segunda comprobación: bloqueo correcto | Histórico v40/v66: ACEPTAR sin tarea real |
|---|---|
| ![Segundo refresco v41](https://mapfre.devinenterprise.com/attachments/3d194b84-6b2d-441e-a187-a3cc8a1f39d3/r42-a-respaldo-fix-v41-ca-manual-manual-2-despues.png) | ![Fallo histórico](https://mapfre.devinenterprise.com/attachments/a14ab7c3-e507-42de-b5ab-a1fd7a132292/r42-a-respaldo-ca-manual-temp2-manual-1-despues.png) |

### Alta adicional: respuesta al clic antes del sondeo

| 🔴 Antes del clic a +20,164 s | 🟢 Lista 0,466 s después |
|---|---|
| ![Alta antes de comprobar](https://mapfre.devinenterprise.com/attachments/ac141c12-e139-4f70-95ad-543a57d96545/r42-a-respaldo-fix-v41-periodico-alta-manual-1-antes.png) | ![Alta lista](https://mapfre.devinenterprise.com/attachments/e8a3f89a-1c0f-48ea-9264-c1435b4633ad/r42-a-respaldo-fix-v41-periodico-alta-listo.png) |

| Solicitud adicional única y CA negativa finalizada | Regresión: comparación 15788704, positiva |
|---|---|
| ![Unicidad 15788715](https://mapfre.devinenterprise.com/attachments/be008fc0-5eaa-4212-a3f4-ae029aebb196/r42-a-respaldo-fix-v41-periodico-unicidad.png) | ![Comparación 15788704](https://mapfre.devinenterprise.com/attachments/8ee89019-f2b5-4462-bb97-5d7871f9493b/r42-a-respaldo-fix-v41-comparacion-15788704.png) |

### Artefactos reproducibles

- [Grabación continua del fix v41 y comprobaciones adicionales](https://mapfre.devinenterprise.com/attachments/39046dfa-218d-4667-a4dc-552188507d1d/r42-a-respaldo-fix-v41-edited.mp4).
- [Log bruto UTC/monotónico de todos los casos controlados](https://mapfre.devinenterprise.com/attachments/5c06c44f-a1b4-409f-95e9-898da50cdf42/r42-a-respaldo-tiempos.jsonl).
- [Snapshot de la reconsulta tardía positiva](https://mapfre.devinenterprise.com/attachments/78bdbe6c-fd96-4b0d-a283-fb22127406fe/r42-a-positiva-regresion-v41-tardia.json).
- Capturas locales: `docs/sca/img/r42-a-respaldo-*.png` y `r42-a-respaldo-fix-v41-*.png`.
- Informes de comparación: [ANTES](r42-a-antes-tiempos.md), [DESPUÉS](r42-a-despues-tiempos.md).

## Incidencias instrumentales y cobertura pendiente

- Intentos descartados sin envío adicional: selector no único de input al preparar alta, argumentos invertidos al arrancar un cronómetro, argumento de Hogar ausente en la regresión Automóviles y nombre accesible `Si` frente al literal visual SI. Se corrigieron antes de ejecutar la acción correspondiente. No son medidas válidas de duración.
- Todas las shells emiten un aviso preexistente de `/opt/.devin/envrc`: `spec-graph.mjs: Permission denied`. No impidió la prueba UI.
- No se probó un `onIncomplete` natural por timeout de una llamada síncrona; la ruta fue forzada por las versiones temporales. Tampoco se alcanzaron 90 s para comprobar el agotamiento.
- No se atribuye causalidad exclusiva manual a la CA que coincide con el sondeo. La CA positiva conserva solo un límite temporal observado, no una muestra exacta del detector habitual.
- Acciones administrativas, autorización y botones de mecanización no se ejecutaron en esta prueba controlada.

## Cierre

Las pruebas autorizadas han terminado y **las versiones temporales Alta v46 / CA v67 pueden revertirse a las versiones síncronas definitivas**. Conservar la corrección funcional de DetalleTareas **v41**; no confundirla con las excepciones temporales por póliza. La reversión corresponde al responsable de Appian: el agente de pruebas no la realizó. Queda documentado el desfase transitorio de la tarjeta positiva para su valoración, sin solicitar nuevas pólizas.
