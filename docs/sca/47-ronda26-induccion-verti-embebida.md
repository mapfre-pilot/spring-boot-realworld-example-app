# 47 — Ronda 26: componente Inducir Cliente (Verti) completable dentro del sitio SCA2

Petición (22/10): «Cuando se llama al proceso de Verti [CMP Inducir Cliente Completo] se tiene que mostrar en la pantalla para que el usuario pueda completar el componente … no quiero que lo abra en el tempo, sino en la misma página de SCA2 … y vemos que tal queda».

## 1. Qué es el CMP y por qué no se puede «embeber»

`CMP Inducir Cliente Completo` (PM `0002ea05-adcc-8000-8c7a-7f0000014e7a`) no es una pantalla sino un proceso con dos subprocesos (Fase 1 `0021ef3e-…`, Fase 2 `0022ef3e-…`) y varias tareas de usuario encadenadas (Inducir con/sin RGPD, errores/Robinson, Mensaje Consentimiento, Solicitud Cotización, derivación manual, reintentos…). Appian no permite pintar una tarea de otro proceso dentro de una interfaz ni iframes del propio Appian; lo que sí permite es abrir la tarea **dentro del sitio** con `a!processTaskLink` (URL `/suite/sites/sca2/page/buscador/task/…`, cabecera SCA2, sin Tempo) y volver a la página al enviarla.

## 2. Objetos (TEST, app SCA2)

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_tareasInduccionVerti` (regla nueva, `…_5610408`) | 1 | Lista las tareas del CMP (report `SCA_REP_PROCESS_REPORT_POLIZA` con contexto de los tres PM del CMP) filtrando por póliza (c5) o usuario asignado (c7). Las tareas de **Fase 2 no llevan póliza** en el informe. |
| `SCA2_InduccionVertiPanel` (interfaz nueva, `…_5610492`) | 3 | Tarjeta «Inducción Verti (componente Inducir Cliente)»: una fila por tarea (PENDIENTE / EN CURSO / COMPLETADA, nombre, proceso, fecha) y enlace **COMPLETAR INDUCCIÓN** (`a!processTaskLink`, misma pestaña). Tareas = por póliza ∪ tarea activa del usuario conectado (`rule!SCA2_obtenerTareaInduccion`, la misma búsqueda que la gestión INDUCCION de 46 §6.2). Resuelve la póliza desde `idSolicitud` si no se pasa. Se muestra sólo si hay tareas activas. |
| `SCA2_DetalleTareas` | 35 | El panel aparece en la tarjeta «CORRECTO / La anulación se ha lanzado…» nada más pulsar ANULAR PÓLIZA (`mostrar: pantalla MECANIZACION y anularPulsado/anulacionEnviada`). Convive con la gestión «Inducción Verti / Vencimiento (componente)» → RETOMAR → «Completar el componente ahora» de 46 §6.2 (DetalleTareas v33/v34), que es la vía que funcionó en la prueba. |
| `SCA2_DetalleSolicitud` | 63 | Panel encima del acordeón «Gestiones realizadas». |

Backups/readbacks en `~/sca2work/r25/` (`live_*`/`after_*`). Sin cambios en CMP, SCA, SCAC, CORE ni ANL.

## 3. Prueba UI (22/10, JJGONZ2, solicitud nueva 15788266 / NSE Autos 2002600013207 / cliente 38878844)

| Paso | Resultado |
|---|---|
| Alta → CA negativa → Verti CONTINUAR → Mecanización → ANULAR PÓLIZA | OK, «CORRECTO». El nodo de inducción lanzó el CMP (instancia 11201231 `devin`, Fase 2 11201232, tarea «Solicitud Cotización»); además apareció otra instancia CMP con iniciador APP-SCAN (Fase 1), la doble inducción A+I de la pregunta Q7. |
| Panel amarillo en CORRECTO / Detalle | **KO con v2**: la tarea era de Fase 2 (sin póliza en el informe) y no se mostró. Corregido en v3 (añade la tarea activa del usuario), **no re-probado con tarea activa**: cuando llegó la corrección la tarea ya estaba enviada. |
| Abrir el componente | OK por Detalle → gestión Inducción → RETOMAR → «Completar el componente ahora: Solicitud Cotización»: se abre en la misma pestaña, URL `/suite/sites/sca2/page/buscador/task/WQzzMdzwLd47VcsG`, cabecera SCA2, **sin Tempo**. |
| Completar pantallas del CMP | «Solicitud de consulta Verti (asegurable/no asegurable)» + pantalla RGPD no inmediata («Consultar respuesta antes de derivar a Verti») → CONTINUAR → vuelve a la página de SCA2 de la solicitud; el enlace desaparece. |
| Fin del componente / continuación de SCA2 | **No alcanzado**: el CMP queda esperando la firma del consentimiento RGPD (no se simuló); la gestión «Inducción Verti/vencimiento (componente)» y la mecanización siguen *Incompleta* (Mecanizar espera al CMP, 46 §6). |
| Reserva de prima en NSE | Se muestra «Reserva prima Sí» de sólo lectura (no se ofrece cambiarla). Anotado. |

Vídeo: `~/screencasts/sca2-r26-cmp/sca2-r26-cmp-edited.mp4`.

## 4. Pendiente / dudas para el analista

1. Re-probar el panel v3 con una tarea CMP activa (nueva solicitud) y, con el consentimiento RGPD resuelto en TEST, ver el fin del CMP y la continuación ANULAR → ANL.
2. Hay dos vías para abrir el componente (panel en CORRECTO + gestión INDUCCION → RETOMAR): decidir si se mantienen ambas o sólo la gestión (más coherente con el resto de SCA2); el panel es un objeto independiente y se puede retirar sin tocar lo demás.
3. «Resultado del componente» sólo puede mostrar lo que el CMP registra (`CMP Auditoria Inducir`: proceso/iniciador/fecha); el detalle de errores/Robinson/derivación está en los PV del CMP y en `ADM Log Servicios Componentes`, no probado.
4. Q7 sigue abierta: para la misma póliza arrancan dos CMP (APP-SCAN tipo A y SCA2 tipo I).
5. ¿Debe SCA2 esperar al CMP si éste queda esperando una firma RGPD que puede tardar días (hoy la mecanización no continúa hasta que el CMP termina)?
