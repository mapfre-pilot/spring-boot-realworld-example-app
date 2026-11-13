# R42-A — medición DESPUÉS en UI

Ejecución: **03/11/2026**, horas **UTC** (UI: UTC+1). Entorno: [Appian TEST / SCA2](https://mapfrespain-test.appiancloud.com/suite/sites/sca2), incógnito, SSO NO PRO JJGONZ2.

Solo UI real y solicitudes nuevas propias. **Sin modificar objetos Appian, sin commit y sin pulsar ANULAR PÓLIZA.**

## Resultado y límites

Se ejecutaron tres altas y los recorridos CA positiva, POSPONER y CA negativa → Vencimiento → apertura de mecanización. Todos los tiempos medidos resultaron inferiores a 30 s. **No se observó respaldo, aviso «Está tardando un poco más…» ni COMPROBAR AHORA:** su funcionamiento y la comparación con/sin pulsación quedan **NO PROBADOS**, no aprobados por inferencia. A petición del usuario se detuvo la búsqueda de una espera natural; no se consultó ni usó ninguna póliza posterior a `2002200060693`. `0731380586960` y `0731380586989` quedan reservadas para su prueba controlada.

La CA positiva ahora muestra tarjeta **Finalizada Positiva**, no la discrepancia Incompleta de ANTES. No aparecieron acciones administrativas ni autorización. No es una validación global de todas las ramas ni de los envíos internos CORE.

## Método conservado

Referencia: [línea base ANTES](r42-a-antes-tiempos.md). Mismo Chrome real por CDP `localhost:29229`, listener de clic en capture, UTC del navegador y `performance.now()`, lectura de `main.innerText` y `disabled` cada 150 ms. Tres decimales son trazabilidad, no precisión garantizada de 1 ms. Se mide clic → primer estado final observado, incluyendo red, proceso y render.

Se conserva el criterio de alta: «Su solicitud se ha generado correctamente» **y** ACEPTAR habilitado. Las tarjetas requieren ACEPTAR habilitado y ausencia de la espera/confirmación pendiente. «Los datos se han guardado correctamente» solo no basta. «Cargando» accesible nunca es señal final. CA positiva termina en buscador; mecanización usa el literal real «Detalle consulta NSE-Autos», corrigiendo el detector instrumental de ANTES. No se refrescó ni pulsó comprobación manual durante ninguna medida.

En DESPUÉS la petición síncrona permanece inicialmente en el formulario/confirmación anterior; no apareció la antigua tarjeta de sondeo. En las tres altas se observó ACEPTAR deshabilitado durante la petición y habilitado al éxito. En CA negativa/POSPONER/Vencimiento no se observó una tarjeta intermedia con ACEPTAR deshabilitado: se pasó del formulario/confirmación a la tarjeta final lista. Por tanto R41 en una **tarjeta de respaldo pendiente** sigue sin cobertura.

## Comparación ANTES / DESPUÉS

Parejas por recorrido, no por orden cronológico: las siguientes pólizas del bloque son Hogar, Hogar y Autos. Son solicitudes/pólizas distintas y una muestra por recorrido; no es un experimento controlado ni permite atribuir toda diferencia únicamente al cambio.

| Recorrido | ANTES (s) | DESPUÉS (s) | Diferencia (s) | Solicitud DESPUÉS |
|---|---:|---:|---:|---|
| Alta Autos para CA negativa | 34,416 | **20,237** | −14,179 | 15788706 |
| CA negativa → lista para Verti/Vencimiento | 49,293 | **13,954** | −35,339 | 15788706 |
| Vencimiento → lista para anulación | 28,723 | **1,705** | −27,018 | 15788706 |
| Apertura mecanización | ≈7,1, orientativo | **7,433** | No comparable formalmente | 15788706 |
| Alta Hogar para CA positiva | 34,038 | **18,787** | −15,251 | 15788704 |
| CA positiva → buscador | 21,580, reconstruido | **3,505** | −18,075 | 15788704 |
| Alta Hogar para POSPONER | 33,857 | **15,108** | −18,749 | 15788705 |
| POSPONER → ACEPTAR habilitado | 27,355 | **2,101** | −25,254 | 15788705 |

## Timestamps y textos DESPUÉS

Todos del 03/11/2026, UTC. Los segundos proceden del reloj monotónico; puede haber 1 ms de diferencia respecto a la resta UTC.

| Transición | Póliza / solicitud | Hora clic | Hora listo | Segundos | Estado durante la petición → criterio final |
|---|---|---|---|---:|---|
| Alta 1, ACEPTAR de simulación | 0731800073132 / 15788704 | 10:56:29.886 | 10:56:48.673 | 18,787 | «Se han completado todas las validaciones… se va a proceder a dar de alta…», ACEPTAR disabled → «Su solicitud se ha generado correctamente. Acepte para abrir la gestión correspondiente.», enabled |
| CA positiva, ACEPTAR retención | 0731800073132 / 15788704 | 10:57:20.473 | 10:57:23.978 | 3,505 | «¡Enhorabuena en la retención de la póliza!… ¿Desea continuar?» → «Buscar solicitud por» |
| Alta 2, ACEPTAR de simulación | 0731800076048 / 15788705 | 10:59:36.264 | 10:59:51.372 | 15,108 | Confirmación de validaciones con ACEPTAR disabled → mismo texto de éxito del alta 1 y enabled |
| POSPONER, ACEPTAR popup | 0731800076048 / 15788705 | 11:00:15.931 | 11:00:18.032 | 2,101 | Formulario CA, argumentos pendientes → «CORRECTO / Los datos se han guardado correctamente», ACEPTAR enabled, sin «Procesando…» |
| Alta 3, ACEPTAR de simulación | 2002200060693 / 15788706 | 11:05:50.381 | 11:06:10.618 | 20,237 | Confirmación de validaciones; ACEPTAR disabled observado +0,164 s → éxito y enabled |
| CA negativa, Si de confirmación | 2002200060693 / 15788706 | 11:08:01.794 | 11:08:15.748 | 13,954 | «Se van a finalizar las acciones de contra anulación. ¿Desea continuar?» → «CORRECTO / Los datos se han guardado correctamente / Se va a redirigir a la siguiente tarea: Gestión Verti/vencimiento.», ACEPTAR enabled |
| Vencimiento, ACEPTAR popup CONTINUAR | 2002200060693 / 15788706 | 11:09:23.514 | 11:09:25.220 | 1,705 | Formulario Verti/Vencimiento, CONTINUAR disabled → «CORRECTO… Se va a redirigir a la anulación.», ACEPTAR enabled |
| Apertura mecanización, ACEPTAR tarjeta | 2002200060693 / 15788706 | 11:09:33.292 | 11:09:40.725 | 7,433 | Tarjeta de redirección → «Detalle consulta NSE-Autos», póliza correcta y controles de anulación visibles; no pulsados |

En ninguna medida apareció COMPROBAR AHORA ni el aviso de tardanza. Tiempo natural CA negativa **13,954 s**; tiempo con comprobación manual **NO PROBADO**. No hubo una espera >30 s que documentar como respaldo real.

## Pólizas, regresión y estados finales

Se comprobaron las siguientes tres pólizas del bloque **en orden**, todas con «No hay resultados para dicha búsqueda» antes del alta. Cada una registrada con **R42-A después** en [REGISTRO.md](polizas/REGISTRO.md), sin ocupadas ni altas fallidas.

Altas: Decisión de cliente / Precio / Me ha subido mucho la prima; Presencial, A VENCIMIENTO. Oficina CA: MADRID CORREDORES NORTE II.

| Póliza | Solicitud | Recorrido y comprobación | Estado final observado |
|---|---|---|---|
| 0731800073132 | 15788704 | Alta con doble clic rápido GUARDAR y ACEPTAR (80 ms). CA positiva, argumento ME HA SUBIDO MUCHO LA PRIMA, sin descuento. Reconsulta por póliza: **una sola fila**. | Finalizado Contra Anulación Positiva; tarjeta CA **Finalizada Positiva**, Alta Finalizada. |
| 0731800076048 | 15788705 | Alta → POSPONER sin argumentos. Reconsulta y Otras sol. Anulación: **una sola solicitud**. Observación «R42-A después: POSPONER sin ejecutar argumentos» persistida. | Solicitud Pendiente; CA Incompleta y RETOMAR disponible. Se abrió RETOMAR por error y se volvió al detalle sin guardar cambios ni ejecutar otra gestión. |
| 2002200060693 | 15788706 | Alta → argumento obligatorio INCREMENTO PRIMA SINIESTROS negativo → plantilla Carta firmada/CONTINUAR → doble clic rápido FINALIZAR (80 ms), Si separado → solo Vencimiento → consulta NSE. Reconsulta por póliza y Otras sol. Anulación: **una sola solicitud y una tarjeta CA**. | Solicitud Pendiente; CA Finalizada Negativa; Gestión Verti/vencimiento Finalizada; Impresión Finalizada; Mecanización Incompleta. Sin ANULAR. |

Los dobles clics fueron interacciones reales de Playwright (`dblclick(delay=80)`), no dos llamadas backend. En ACEPTAR de alta 1 solo se registró un evento de clic aceptado tras el bloqueo del botón. No se observaron solicitudes ni tarjetas de gestión duplicadas. **La unicidad de envíos internos CORE no es demostrable desde estas pantallas**; queda sin verificar exhaustivamente.

No se observaron errores de expresión SAIL en las pantallas recorridas. No se tocaron solicitudes de ANTES ni ajenas ni la póliza prohibida.

## Incidencias y cobertura incompleta

1. **Respaldo no alcanzado:** no se aprobó onIncomplete, sondeo de respaldo, aviso ni COMPROBAR AHORA. El usuario preparará prueba controlada con pólizas reservadas; no se consumieron más pólizas para provocarlo.
2. **Desviación de navegación:** RETOMAR se abrió accidentalmente en 15788705, después de verificar guardado/persistencia; se volvió al detalle sin cambios ni reenvío. La medida original de POSPONER no se repitió ni se alteró.
3. Ajustes instrumentales: algunos selectores esperaron textos no exactos o solo accesibles (p. ej. «1 elemento disponible», encabezado Verti sin espacios), o intentaron actuar antes del nuevo formulario. Se cancelaron/agotaron esas esperas y se verificó la pantalla real. No son tiempos del proceso ni medidas fallidas de negocio. En Autos se corrigió selección hacia el argumento **obligatorio**; FINALIZAR permaneció bloqueado hasta generar la plantilla y pulsar CONTINUAR. Ninguna de esas esperas entra en las cifras.
4. El listener de alta 1 quedó activo y duplicó **el registro instrumental** del clic único de CA positiva (+0,3 ms entre entradas), no la interacción. Se tomó el primer timestamp del mismo evento. Se corrigió eliminación del listener para las medidas posteriores y se recargó al volver al buscador. No implica dos envíos.
5. En alta 3, la muestra inicial a +0,007 s aún mostró la confirmación ACEPTAR enabled; a +0,164 s estaba disabled y permaneció así hasta éxito. No se ensayó clic en esa pequeña ventana: no se afirma atomicidad instantánea. En la tarjeta final nunca se aceptó «guardado» sin comprobar enabled.
6. **NO PROBADO:** AA, autorización fuera de norma (no aparecieron), contacto Verti (solo Vencimiento), acciones destructivas/finalización de mecanización y unicidad exhaustiva de envíos internos. No se inventaron capturas de tarjetas pendientes que no aparecieron.
7. Persistió el aviso de shell `/opt/.devin/envrc: line 4: .../spec-graph.mjs: Permission denied`. No impidió UI/CDP. Sin nuevas dependencias ni servidor local.

## Evidencia visual

### Alta 1 DESPUÉS — bloqueo durante petición y éxito

| 🔴 Antes de estar lista: ACEPTAR bloqueado | 🟢 Después: éxito y ACEPTAR habilitado |
|---|---|
| ![Alta 1 pendiente](https://mapfre.devinenterprise.com/attachments/a24f03eb-eff8-4d83-b47f-cc4167a4c826/r42-a-despues-alta-1-deshabilitado.png) | ![Alta 1 lista](https://mapfre.devinenterprise.com/attachments/be9484ee-1cf3-4e37-a9cc-a5cc724051c3/r42-a-despues-alta-1-listo.png) |

### CA positiva — discrepancia ANTES y estado DESPUÉS

| 🔴 ANTES: tarjeta Incompleta | 🟢 DESPUÉS: Finalizada Positiva |
|---|---|
| ![CA positiva ANTES](https://mapfre.devinenterprise.com/attachments/28ae9b6d-0310-4816-95a4-55f9ef0788f0/r42-a-antes-ca-positiva-finalizada.png) | ![CA positiva DESPUÉS](https://mapfre.devinenterprise.com/attachments/219be506-3681-4b80-af4f-e7850211edde/r42-a-despues-ca-positiva-finalizada.png) |

### CA negativa y Vencimiento — tarjetas listas

| CA negativa: siguiente tarea lista, 13,954 s | Vencimiento: anulación lista, 1,705 s |
|---|---|
| ![CA negativa lista](https://mapfre.devinenterprise.com/attachments/0030a3a3-20bd-4a89-91fd-e0a9e956bf9f/r42-a-despues-ca-negativa-listo.png) | ![Vencimiento listo](https://mapfre.devinenterprise.com/attachments/7f99d755-f440-4dac-83aa-627453dbddbd/r42-a-despues-vencimiento-listo.png) |

### POSPONER — final de medida y persistencia

| ACEPTAR habilitado, 2,101 s | Observación y RETOMAR disponibles |
|---|---|
| ![POSPONER listo](https://mapfre.devinenterprise.com/attachments/6a249409-acc3-4452-a6a9-7a105bacab44/r42-a-despues-posponer-listo.png) | ![POSPONER persistido](https://mapfre.devinenterprise.com/attachments/fd557f34-6cca-4aac-9380-3fbd6bba9af7/r42-a-despues-posponer-guardado-retomar.png) |

### Regresión — unicidad visible tras dobles clics

| GUARDAR/ACEPTAR alta: una solicitud | FINALIZAR CA: una solicitud y una CA |
|---|---|
| ![Alta sin duplicados](https://mapfre.devinenterprise.com/attachments/186de05e-e017-48ba-acc3-4799fbe33bee/r42-a-despues-alta-1-sin-duplicados.png) | ![CA negativa sin duplicados](https://mapfre.devinenterprise.com/attachments/c787bcab-53d4-426b-ba70-119a28502222/r42-a-despues-ca-negativa-sin-duplicados.png) |

Mecanización abierta, sin anular: [captura](https://mapfre.devinenterprise.com/attachments/22a679b6-d578-47a3-bdb8-fe639b0aacc2/r42-a-despues-mecanizacion-listo.png).

Capturas locales: `docs/sca/img/r42-a-despues-*.png`.

Grabación nueva continua anotada: `/home/ubuntu/screencasts/r42-a-despues/r42-a-despues-edited.mp4`.

Log bruto: `/tmp/r42-a-despues-tiempos.jsonl`. Instrumentación temporal: `/tmp/r42after.py`. Plan: `/tmp/r42-a-despues-plan.md`.
