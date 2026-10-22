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

## 5. Ronda 26-b (22/10): todas las pantallas del componente hasta que termine el proceso principal

Decisión del usuario: «El componente de verti se tiene que completar, si se va por la firma, también se tiene que mostrar. Es hasta que termine el proceso principal que se lanza. Y mantén las dos vías de apertura».

### 5.1 Hallazgo

- El CMP no es sólo Fase 1 / Fase 2: la firma RGPD y las pantallas de Verti son **subprocesos** con sus propias tareas de usuario, todas asignadas al `usuarioAppian` que SCA2 pasa al lanzar el CMP (JJGONZ2 en la prueba). Las búsquedas de la ronda 26 (contexto Fase 1/2) no las veían.
- Árbol de PM con tareas de usuario (lectura del diseño en TEST): `CMP Firma RGPD Completo` → `CMP Firma RGPD Main` (Interfaz Firma RGPD, Mensaje Éxito/Error, CMP_InduccionFirmaRGPD) → `CMP Firma y PerfilSi24`; `CMP Firma RGPD OneTrust` → `CMP Servicios Firma RGPD OneTrust`; `CMP Flujo Induccion Verti V2` (Confirmación POST consulta previa); `CMP Reintentos Inducciones V2` → `CMP Consulta Verti V2` (pantalla espera) / `CMP Gestionar Induccion Verti` (Confirmación proceso inducción); `CMP Resumen Consulta` y `CMP Opcion1y2` (Completar vencimiento, Resumen / Opción 1 y 2).
- Instancia de 15788266: el CMP 11201231 seguía ACTIVE y la Fase 2 (11201232) tenía otra vez una tarea «Solicitud Cotización» (4198630) PENDIENTE desde las 12:54 para JJGONZ2 (la opción «Consultar respuesta antes de derivar» vuelve a la cotización); la Fase 2 figuraba PAUSED con `lockedBy GGALV10` (bloqueo de monitorización, no de SCA2). `contextProcessIds` no sirve: el informe no devuelve tareas de subprocesos por id de proceso.
- La gestión INDUCCION de SCA2 ya dura lo que el proceso principal: `CMD Mecanizar` nodo 330 lanza el CMP con `IsSynchronous = 1` y el nodo 333 sólo la cierra cuando el CMP termina; por tanto «hasta que termine el proceso principal» = «mientras la gestión INDUCCION no esté COMPLETADA».

### 5.2 Objetos (TEST, app SCA2)

| Objeto | Versión | Cambio |
|---|---|---|
| Constantes nuevas `SCA2_PM_CMP_FIRMA_RGPD_COMPLETO`, `_FIRMA_RGPD_MAIN`, `_FIRMA_PERFIL_SI24`, `_FIRMA_RGPD_ONETRUST`, `_SERVICIOS_FIRMA_ONETRUST`, `_FLUJO_INDUCCION_VERTI`, `_CONSULTA_VERTI`, `_GESTIONAR_INDUCCION_VERTI`, `_RESUMEN_CONSULTA`, `_OPCION_1_2` | 1 | Process Model de cada subproceso del CMP con tareas de usuario. |
| `SCA2_obtenerTareaInduccion` | 3 | `contextProcessModels` = Fase 1/2 + los 10 subprocesos (misma firma; la usan la gestión INDUCCION → RETOMAR y el panel). |
| `SCA2_tareasInduccionVerti` | 4 | Mismo contexto ampliado (+ PM principal). |
| `SCA2_InduccionVertiPanel` | 4 | Lee la gestión INDUCCION de la solicitud (`SCA2 Tarea` tipo INDUCCION): la tarjeta se muestra mientras esté abierta aunque no haya pantalla pendiente («EN CURSO … puede estar esperando una respuesta externa»), botón ACTUALIZAR, texto «Complete aquí todas las pantallas del componente (cotización, firma RGPD, consulta a Verti…) hasta que termine su proceso principal» y, al cerrarse, «El componente ha terminado; la mecanización continúa en SCA2». |

Sin cambios en `SCA2_DetalleTareas` (35) ni `SCA2_DetalleSolicitud` (63): se mantienen las dos vías. Verificado por LCP: `SCA2_obtenerTareaInduccion(JJGONZ2)` → tarea 4198630 «Solicitud Cotización» (Fase 2 11201232); el panel con `idSolicitud 15788266` pinta la fila PENDIENTE + «COMPLETAR INDUCCIÓN» + ACTUALIZAR. Regla temporal de sondeo `SCA2_tmpProbeTareasCmp` creada y borrada. Backups: `~/sca2work/r25/r26b_live_*.json` / `r26b_after_*.json`, `consts_cmp_subpm.json`, `cmp_pm_tree.json`.

### 5.3 Prueba UI (22/10, JJGONZ2, solicitud nueva 15788275 / NSE Autos 2002100296038 / cliente 20287412)

| Paso | Resultado |
|---|---|
| Alta → CA negativa → Verti CONTINUAR → Mecanización → ANULAR PÓLIZA | OK («CORRECTO / La anulación se ha lanzado al sistema de emisión»). Gestión INDUCCION abierta 15:19:07 con proceso CMP **683917** (`devin`, tipo I, usuarioAppian JJGONZ2@mapfrenopro…), Fase 2 683918. |
| Panel en CORRECTO y en Detalle | **Aparece** (vía A verificada). Con v4 mezclaba tareas ajenas: la «Solicitud Cotización» 14:54 de 15788266 (mismo usuario) y varias «Inducir con RGPD - 20287412» de CMP iniciados por **APP-SCAN** (tipo A, procesos 13312141/13312142, asignadas a la identidad `JJGONZ2@mapfre.net`, distinta de la del usuario conectado `JJGONZ2@mapfrenopro.onmicrosoft.com`; por eso el formulario salía deshabilitado). Corregido en **v5** (sólo tareas creadas desde que esta solicitud abrió la gestión INDUCCION) y **v6** (sólo tareas asignadas al usuario conectado; al terminar el CMP no se lista ninguna). |
| Pantallas del componente | **El CMP de SCA2 terminó solo en 53 s** (13:19:12 → 13:20:05): su única tarea «Solicitud Cotización» (15314, Fase 2 683918, nombre de proceso con `id:` vacío) se creó a las 13:19:13 y quedó completada en el mismo segundo sin intervención del usuario. Es decir, para este cliente el componente no presentó ninguna pantalla; no hubo firma RGPD. |
| Fin del componente / continuación | OK: gestión INDUCCION **Finalizada** 15:20:07, Mecanización **ANULACIÓN REALIZADA** 15:20:39 (NSE-Autos, efecto 09/08/2027), bandeja de errores de la solicitud vacía. Panel (v6, tras F5): «El componente ha terminado; la mecanización continúa en SCA2», sin tareas. La CA nivel 2 posterior «Incompleta» es el comportamiento NSE ya conocido (R23-B). |
| «Resultado del componente» | No se mostró (sin filas en `CMP Auditoria Inducir` para el proceso). |

Vídeo: `~/screencasts/sca2-r26b-v6-final/sca2-r26b-v6-final-edited.mp4`. Capturas en `~/screenshots/ss_730f0112.png`, `ss_b9e26e3f.png`, `ss_3541a6c9.png`, `ss_17afeb95.png`.

Sobre 15788266 (sólo lectura): el subproceso `CMP Firma RGPD Completo` 11201233 / `Main` 11201234 terminó a las 12:53:35, **exactamente 60 min** después de arrancar (su tarea «Interfaz Firma RGPD» quedó con estado 14, sin asignados), y acto seguido la Fase 2 creó otra «Solicitud Cotización» (4198630, 12:54), que a las 15:30 ya figuraba completada (estado 2) sin que el testing agent la tocase. El CMP principal 11201231 seguía ACTIVE y la gestión INDUCCION de 15788266 PENDIENTE (panel: «EN CURSO…»).

### 5.4 Qué queda por demostrar / dudas para el analista

1. **Firma RGPD dentro de SCA2**: la búsqueda ya cubre los PM de firma (verificado por diseño y por LCP), pero no se ha visto una pantalla de firma en vivo: en 15788275 el CMP no presentó pantallas y en 15788266 la firma caducó a los 60 min sin tarea asignable. Hace falta un cliente de TEST que obligue a firma inmediata (o confirmación del equipo CMP de cómo se dispara).
2. **Vía B (gestión → RETOMAR) con los subprocesos**: usa la misma regla `SCA2_obtenerTareaInduccion` v3 (misma búsqueda que el panel), pero no se ha re-ejecutado en pantalla en esta ronda porque la gestión se cerró antes.
3. **Q7 (doble inducción A + I)**: confirmado que los CMP tipo A los inicia APP-SCAN para el mismo cliente/póliza y asignados a `JJGONZ2@mapfre.net`; SCA2 ya no los muestra. ¿Es el comportamiento esperado en TEST?
4. ¿Por qué la Fase 2 del CMP de SCA2 nace con `id:` vacío y completa «Solicitud Cotización» automáticamente (683918)? Posible dependencia de los datos del cliente 20287412 en el servicio de inducción (ajeno a SCA2).
5. `CMP Auditoria Inducir` no registra nada para estos procesos → «Resultado del componente» queda vacío; alternativa: leer `ADM Log Servicios Componentes` (pendiente de ejemplo real).
