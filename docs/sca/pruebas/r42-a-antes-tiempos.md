# R42-A — línea base ANTES en UI

Fecha de ejecución: **03/11/2026**. Horas de esta tabla en **UTC**; la UI muestra hora local (UTC+1).

Entorno: [Appian TEST / SCA2](https://mapfrespain-test.appiancloud.com/suite/sites/sca2), incógnito, SSO Mapfre NO PRO, usuario JJGONZ2. Solo interacción con la UI y solicitudes nuevas propias. **No se modificaron objetos Appian ni se hizo commit. No se pulsó ANULAR PÓLIZA.**

## Resultado y límites

Se completó el procedimiento de medición con **tres altas**, CA negativa, CA positiva y POSPONER. Apareció Verti/Vencimiento y se eligió solo Vencimiento. Se abrió mecanización sin anular. **No es una validación global sin incidencias:** CA positiva muestra estado final positivo pero la tarjeta de gestión queda Incompleta. No aparecieron acciones administrativas ni autorización; no se forzaron.

Las tres altas tardaron entre **33,857 y 34,416 s**. Las tarjetas posteriores a CA negativa, Vencimiento y POSPONER también mostraron espera real, pero no exactamente 30 s desde el clic. El tiempo incluye red, ejecución remota y renderizado; no equivale a duración interna del proceso ni demuestra por sí solo el periodo del sondeo.

## Método

Playwright Python conectado al Chrome real por CDP `localhost:29229`. Captura de clic en fase capture con fecha UTC y `performance.now()`, lectura de `main.innerText` y estado `disabled` de botones cada 100–150 ms. Las cifras tienen tres decimales para trazabilidad, **no precisión garantizada de 1 ms**. No se usó «Cargando» como señal de finalización: persistía incluso después de habilitarse ACEPTAR.

En altas y tarjetas se observó ACEPTAR deshabilitado y luego habilitado. En CA positiva se observó la confirmación de retención seguida de retorno al buscador; no apareció tarjeta de sondeo durante el intervalo observado. Ese tiempo se reconstruyó del evento DOM conservado, porque el detector automático esperaba una tarjeta distinta.

## Tabla de tiempos ANTES

Todos los timestamps corresponden al 03/11/2026, UTC.

| Transición y criterio final | Póliza | Solicitud | Hora clic | Hora listo | Segundos | Texto visible durante la espera / al terminar |
|---|---|---|---|---|---:|---|
| Alta 1: ACEPTAR de confirmación → ACEPTAR habilitado | 2002100077567 | 15788693 | 10:15:30.189 | 10:16:04.604 | **34,416** | «Su solicitud se está generando. Determinando la siguiente gestión, espere un momento: el botón ACEPTAR se habilitará cuando esté lista.» → «Su solicitud se ha generado correctamente. Acepte para abrir la gestión correspondiente.» |
| CA negativa: Si de confirmación → ACEPTAR habilitado | 2002100077567 | 15788693 | 10:22:15.635 | 10:23:04.928 | **49,293** | «Procesando la decisión de la solicitud…» → «Se va a redirigir a la siguiente tarea: Gestión Verti/vencimiento.» |
| Vencimiento: ACEPTAR del popup de continuar → ACEPTAR habilitado | 2002100077567 | 15788693 | 10:31:36.649 | 10:32:05.371 | **28,723** | «Procesando la decisión de la solicitud…» → «Se va a redirigir a la anulación.» |
| Apertura mecanización: ACEPTAR de tarjeta → consulta NSE visible | 2002100077567 | 15788693 | ≈10:32:10.467 | ≈10:32:17.571 | **≈7,1, orientativo** | Se abrió «Detalle consulta NSE-Autos». Detector esperaba «Mecanización»; no es medida formal automatizada. No se probó ningún botón de finalización/anulación. |
| Alta 2: ACEPTAR de confirmación → ACEPTAR habilitado | 0732400243204 | 15788697 | 10:38:50.114 | 10:39:24.151 | **34,038** | Misma tarjeta de generación y de éxito del alta 1. |
| CA positiva: ACEPTAR de retención → buscador | 0732400243204 | 15788697 | 10:41:56.457 | 10:42:18.038 | **21,580, reconstruido** | «¡Enhorabuena en la retención de la póliza! Se van a finalizar las acciones de contra anulación en SCA. ¿Desea continuar?» → «Buscar solicitud por». Sin tarjeta intermedia de sondeo observada. |
| Alta 3: ACEPTAR de confirmación → ACEPTAR habilitado | 0732200060615 | 15788701 | 10:47:48.506 | 10:48:22.364 | **33,857** | Misma tarjeta de generación y de éxito del alta 1. |
| POSPONER: ACEPTAR del popup → ACEPTAR habilitado | 0732200060615 | 15788701 | 10:48:55.025 | 10:49:22.380 | **27,355** | «CORRECTO / Los datos se han guardado correctamente / Procesando la decisión de la solicitud…» con ACEPTAR deshabilitado → desaparece «Procesando…» y ACEPTAR habilitado. |

La pequeña diferencia entre resta de horas y duración se debe a usar reloj monotónico para los segundos y redondeo.

## Pólizas y estados finales

Se comprobaron las tres primeras pólizas del bloque, **en orden**, y cada una mostró «No hay resultados para dicha búsqueda» antes del alta. No hubo pólizas ocupadas ni altas fallidas en estas tres comprobaciones. Se actualizaron sus filas en `polizas/REGISTRO.md` con etiqueta **R42-A antes**. No se consultó ni utilizó la póliza prohibida.

| Póliza | Solicitud | Recorrido | Estado final observado |
|---|---|---|---|
| 2002100077567 | 15788693 | Alta → CA negativa, argumento INCREMENTO PRIMA SINIESTROS → Verti/Vencimiento, solo Vencimiento → consulta NSE-Autos | Solicitud pendiente; Mecanización Incompleta. No se pulsó ANULAR PÓLIZA. No reutilizar. |
| 0732400243204 | 15788697 | Alta → CA positiva, argumento ME HA SUBIDO MUCHO LA PRIMA, sin aplicar descuento | Solicitud FINALIZADA POSITIVAMENTE / tabla «Finalizado Contra Anulación Positiva». **Discrepancia:** tarjeta Contra Anulacion Incompleta después de volver a consultar la póliza. |
| 0732200060615 | 15788701 | Alta → CA POSPONER, sin ejecutar argumentos | Solicitud pendiente; CA Incompleta, observación «R42-A antes: POSPONER sin ejecutar argumentos» persistida y RETOMAR disponible. No se retomó. |

Oficina seleccionada en las CA: MADRID CORREDORES NORTE II. Altas con Decisión de cliente / Precio / Me ha subido mucho la prima, canal Presencial, catalogación ordinaria A VENCIMIENTO.

## Incidencias de instrumentación y cobertura pendiente

1. Primer intento de Verti/Vencimiento: se midió CONTINUAR sin confirmar todavía el popup «¿Desea continuar?». Timeout de 240 s, **descartado**; no es espera del proceso. La medida válida empieza en el ACEPTAR de ese popup.
2. Apertura mecanización: el detector esperaba un literal distinto del real. Solo se conserva tiempo orientativo y captura de la consulta abierta. No se pulsaron FINALIZAR SOLICITUD, CANCELAR ni ANULAR PÓLIZA para no alterar/destruir el caso.
3. CA positiva: detector configurado para tarjeta de gestión, pero el flujo volvió directamente al buscador. Timeout instrumental de 240 s, **no timeout de Appian**. El evento de retorno al buscador quedó registrado a los 21,580 s; estado positivo confirmado después desde UI. No hay captura de tarjeta deshabilitada/habilitada porque no se observó tal tarjeta en este flujo.
4. POSPONER: el detector inicial terminó prematuramente con «Los datos se han guardado correctamente» a los 0,827 s, aunque ACEPTAR seguía deshabilitado. **Ese valor no es válido.** Se continuó observando sin nuevo clic desde el mismo reloj inicial y se obtuvo ACEPTAR habilitado a los **27,355 s**. La captura `r42-a-antes-posponer-listo.png` es intermedia, **no estado listo**; usar `r42-a-antes-posponer-habilitado.png`.
5. Selectores de checkbox de Appian y tiempos de render exigieron ajustes; se seleccionaron filas mediante la UI. La espera inicial a un botón «POSITIVO» exacto no coincidía con su texto deshabilitado y agotó el timeout del selector; no implica un fallo de carga de la CA.
6. **NO PROBADO:** acciones administrativas, autorización fuera de norma y contacto Verti (no aparecieron o no se eligieron naturalmente); espera de botones de mecanización que podrían finalizar/destruir el caso. No se han medido todas las ramas que podrían contener sondeo de 30 s.
7. El shell emitió `/opt/.devin/envrc ... spec-graph.mjs: Permission denied` al iniciar comandos. No impidió la UI, CDP ni la captura. No se corrigió.

## Evidencia visual

### Alta 2 — tarjeta de espera

| 🔴 Antes: ACEPTAR deshabilitado | 🟢 Después: ACEPTAR habilitado |
|---|---|
| ![Alta 2 esperando](https://mapfre.devinenterprise.com/attachments/94ee189c-0512-4c16-a4c2-4c5aab2c2fe5/r42-a-antes-alta-2-deshabilitado.png) | ![Alta 2 lista](https://mapfre.devinenterprise.com/attachments/7d6d4374-46bc-44a4-9e0d-db31cc2e2ffc/r42-a-antes-alta-2-listo.png) |

### POSPONER — tarjeta de espera

| 🔴 Antes: procesando, deshabilitado | 🟢 Después: guardado, habilitado |
|---|---|
| ![POSPONER esperando](https://mapfre.devinenterprise.com/attachments/8caedcb1-825c-49c1-95de-4e93aebc36db/r42-a-antes-posponer-deshabilitado.png) | ![POSPONER listo](https://mapfre.devinenterprise.com/attachments/17d91877-eda8-45d9-8d53-a283dfd499b6/r42-a-antes-posponer-habilitado.png) |

### Estados finales — dos solicitudes distintas

| CA positiva: discrepancia de estados | POSPONER: observación persistida y RETOMAR |
|---|---|
| ![CA positiva finalizada con tarjeta incompleta](https://mapfre.devinenterprise.com/attachments/28ae9b6d-0310-4816-95a4-55f9ef0788f0/r42-a-antes-ca-positiva-finalizada.png) | ![POSPONER persistido](https://mapfre.devinenterprise.com/attachments/cdffa515-50f4-4c0a-9ea5-d08f9c6bb58b/r42-a-antes-posponer-guardado-retomar.png) |

Capturas locales: `docs/sca/img/r42-a-antes-*.png`. Incluyen las tres altas, CA negativa, Verti/Vencimiento, consulta NSE-Autos sin anular y los estados de las solicitudes.

Grabación continua: `/home/ubuntu/screencasts/r42-a-antes/r42-a-antes-edited.mp4`.

Log bruto de eventos y relojes: `/tmp/r42-a-tiempos.jsonl` (con intentos descartados, según se explica arriba). Instrumentación temporal: `/tmp/r42ui.py`.
