# R42-A — Espera síncrona en SCA2 (sin depender del sondeo de 30 s)

Sesión: https://mapfre.devinenterprise.com/sessions/7845b0c4431b4d05b723fefd0f5bf177 · Entorno: Appian TEST (`/suite/sites/sca2`) · Usuario de prueba: JJGONZ2 · Fecha: 03/11/2026.

## 1. Qué se pedía

> «no se puede hacer de alguna manera que no se espere 30s y que se espere a la respuesta? … los usuarios van a estar esperando 30s cuando puede ser menos tiempo» → «sí, quiero que lo pruebes y esto lo hagas donde se esté esperando siempre esos 30s».

Antes del cambio, las pantallas lanzaban el proceso y comprobaban cada 30 s si ya estaba la siguiente gestión. Aunque el proceso terminara antes, el usuario seguía esperando hasta la siguiente comprobación. Esos 30 s son el mínimo de `a!refreshVariable`: `refreshInterval: 0.5` equivale a 0,5 minutos.

## 2. Resultado en una frase

El botón espera ahora a que el proceso termine y la pantalla muestra la siguiente gestión en cuanto existe. Si Appian no termina el proceso dentro de su límite síncrono, la pantalla vuelve automáticamente a la espera con sondeo de 30 s, con el aviso «Está tardando un poco más…» y el botón **COMPROBAR AHORA**.

## 3. Tiempos medidos antes y después (UI real, solicitudes nuevas)

Medición desde el clic hasta que ACEPTAR se habilita o se abre la siguiente pantalla, con el mismo detector DOM y reloj monotónico en las dos fases. El detalle de cada medida está en [r42-a-antes-tiempos.md](r42-a-antes-tiempos.md) y [r42-a-despues-tiempos.md](r42-a-despues-tiempos.md).

| Espera | Antes | Después | Mejora |
|---|---:|---:|---:|
| Alta → primera gestión (ACEPTAR habilitado) | 34,4 / 34,0 / 33,9 s | 18,8 / 15,1 / 20,2 s | ≈ −16 s (−50 %) |
| CA negativa → gestión Verti/Vencimiento | 49,3 s | 14,0 s | −35 s |
| Verti/Vencimiento → anulación (mecanización) | 28,7 s | 1,7 s | −27 s |
| CA positiva → vuelta al buscador | 21,6 s | 3,5 s | −18 s |
| POSPONER → ACEPTAR habilitado | 27,4 s | 2,1 s | −25 s |
| Apertura de mecanización (sin ANULAR PÓLIZA) | ≈7,1 s (orientativo) | 7,4 s | sin cambio (no dependía del sondeo) |
| Acciones administrativas / anulación fuera de norma | no aparecieron | no aparecieron | no medido |

Observación adicional: antes, después de una CA positiva, la tarjeta de gestión seguía como «Contra Anulación / Incompleta» al volver al buscador, porque el cierre se ejecutaba en segundo plano. Ahora el cierre termina antes de volver y la tarjeta muestra «Finalizada Positiva».

## 4. Respaldo y botón COMPROBAR AHORA (prueba controlada)

Detalle completo en [r42-a-respaldo-tiempos.md](r42-a-respaldo-tiempos.md).

No se consiguió que el proceso superara de forma natural el límite de 30 s: todas las esperas síncronas reales terminaron antes. Para probar el respaldo, se subieron temporalmente versiones de `SCA2_AltaSolicitudPage` (v45–v46) y `SCA2_ContraAnulacionOpciones` (v65–v67). Esas versiones lanzaban el proceso en asíncrono **solo para 4 pólizas de prueba**, lo que deja la pantalla en el mismo estado que `onIncomplete`. Después de la prueba se **revirtieron** a la versión definitiva (Alta v47, CAO v68, idénticas a v44/v64).

| Prueba | Resultado |
|---|---|
| Alta en respaldo, sin pulsar nada (15788708) | ACEPTAR deshabilitado y COMPROBAR AHORA visible; lista por sondeo a 34,4 s. |
| Alta en respaldo, COMPROBAR AHORA a +20,2 s (15788715) | Lista **0,47 s después del clic** (20,6 s en total), antes del sondeo (~34 s). |
| CA negativa en respaldo con DetalleTareas v40 (15788710) | **Fallo detectado:** COMPROBAR AHORA a +1,8 s habilitó ACEPTAR **sin siguiente tarea** (solo «CORRECTO»). La gestión real llegó a 37,0 s. No se pulsó ese ACEPTAR. |
| Corrección → `SCA2_DetalleTareas` v41 | Nueva condición `local!esperandoDecision`: con la acción ya cerrada, si aún no hay siguiente tarea y la solicitud no está en un estado final, se sigue esperando (máximo `SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS` = 90 s). |
| CA negativa en respaldo con v41 (15788712), COMPROBAR AHORA a +2,3 s y +15,3 s | Se mantienen «Procesando…», el aviso y ACEPTAR deshabilitado. ACEPTAR solo se habilita al llegar la gestión real (51,9 s). |
| CA negativa en respaldo con v41 (15788715), COMPROBAR AHORA a +30,2 s | Lista 0,47 s después del clic, a 30,7 s. Coincide con el ciclo de sondeo, así que no se atribuye al botón. |
| Regresión fuera de la lista temporal (15788713) | Alta síncrona en 14,8 s, sin aviso ni COMPROBAR AHORA; la CA positiva vuelve al buscador en ≤5,3 s, sin esperar 90 s. |

El fallo de la v40 no es nuevo de R42-A: el sondeo de 30 s antiguo también podía caer en ese hueco (acción cerrada, decisión sin terminar). COMPROBAR AHORA solo lo hacía más fácil de provocar. La v41 lo corrige en los dos casos.


## 5. Qué se ha cambiado

### 5.1 Pantallas (interfaces)

| Objeto | Versión antes → después | Cambio |
|---|---|---|
| `SCA2_AltaSolicitudPage` | 43 → 44 (v45–v46 temporales de prueba; definitiva v47 = v44) | `a!startProcess` del alta con `isSynchronous: true`; `onIncomplete` deja la espera con sondeo (R35-A/R41). Se añade el botón COMPROBAR AHORA mientras ACEPTAR está deshabilitado. |
| `SCA2_DetalleTareas` | 39 → 41 | Las consultas de la espera se releen en cuanto vuelve la acción (`refreshOnVarChange` con `local!hecho`). Se añaden el aviso «Está tardando…» y COMPROBAR AHORA. `0.5` pasa a `cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60`, e `intervalds(0,1,30)` pasa a `cons!SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS`. En la v41 se añade `local!esperandoDecision` (§4). |
| `SCA2_ContraAnulacionOpciones` | 63 → 64 (v65–v67 temporales de prueba; definitiva v68 = v64) | La CA negativa sin modal y POSPONER pasan a síncronos. `onIncomplete` vuelve a la espera. Las llamadas del modal ya eran síncronas. |
| `SCA2_MecanizacionPrincipal` | 22 → 23 | CANCELAR y ACEPTAR (finalizar) pasan a síncronos con `onIncomplete`. ANULAR PÓLIZA no cambia: sigue con `a!startProcessLink`, por paridad con CMP. |
| `SCA2_AccionesAdministrativasPrincipal` | 24 → 25 | 2 llamadas a CompletarAccion y 1 a Posponer pasan a síncronas con `onIncomplete`. |
| `SCA2_AnulacionFueraNormaPrincipal` | 24 → 25 | Ídem (3 llamadas). |
| `SCA2_VertiVencimientoPrincipal` | 16 → 17 | CONTINUAR (CrearAccion) pasa a síncrono con `onIncomplete`. |

En todos los casos, `onIncomplete` ejecuta las mismas acciones que `onSuccess`. Así, si Appian corta la espera, la pantalla queda igual que antes y sigue el sondeo.

### 5.2 Procesos (PM)

| PM | Nodos / PV (antes = después) | Cambio |
|---|---|---|
| `SCA2 CMD Alta` | 23 / 40 | Activity chaining en las 28 conexiones. `Start Decidir` ya era síncrono. |
| `SCA2 CMD Decidir` | 26 / 22 | Chaining en las 37 conexiones. `Start Finalizar` pasa a síncrono. `Start CrearAccion` ya lo era. `Start Decidir (reintento)` sigue asíncrono porque es el bucle de error. |
| `SCA2 CMD CrearAccion` | 40 / 15 | Chaining en las 59 conexiones. `Start Decidir` y `Start Finalizar` pasan a síncronos. La inducción Verti (CMP) no cambia. |
| `SCA2 CMD CompletarAccion` | 42 / 24 | Chaining en las 64 conexiones. `Start decidir`, `Start crearaccion` y `Start finalizar` pasan a síncronos. |
| `SCA2 CMD Posponer` | 12 / 26 | Chaining en las 14 conexiones. No tiene subprocesos. |

Comprobación nodo a nodo tras la relectura viva: se mantienen el mismo número de nodos, los mismos destinos de cada conexión y las mismas variables de proceso. El contenido de los nodos solo cambia en el valor `IsSynchronous` de los nodos citados. No se modifica ninguna lógica de negocio. Ningún PM tiene temporizadores ni tareas de usuario, así que el chaining no se corta por esos motivos. Todo se hizo por LCP REST (`activityChained` e `IsSynchronous` se exponen en el JSON), sin pasar por Designer.

### 5.3 Constantes nuevas

| Constante | Valor | Uso |
|---|---|---|
| `SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS` | 90 | Sustituye `intervalds(0,1,30)` en `SCA2_DetalleTareas`. |
| `SCA2_TXT_COMPROBAR_AHORA` | COMPROBAR AHORA | Etiqueta del botón. |

Se reutilizan `SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS` (30) y `SCA2_TXT_ESPERA_DECISION_ADICIONAL` («Está tardando un poco más en generar la siguiente gestión, espere un momento.»).

## 6. Tramos síncronos y tramos con respaldo

| Tramo | Modo actual | Motivo |
|---|---|---|
| GUARDAR alta → Alta → Decidir → CrearAccion (primera gestión) | Síncrono de extremo a extremo | Todos los Start Process del camino son síncronos. |
| ACEPTAR/FINALIZAR CA (negativa, positiva) → CompletarAccion → Decidir → CrearAccion / Finalizar | Síncrono | Los Start Process hijos pasan a síncronos. |
| POSPONER → CMD Posponer | Síncrono | No hay subprocesos. |
| Verti/Vencimiento CONTINUAR → CrearAccion → Decidir | Síncrono | `Start Decidir` de CrearAccion pasa a síncrono. |
| Cualquier tramo que supere 30 s, o que Appian cancele o marque con error | Respaldo: sondeo de 30 s + aviso + COMPROBAR AHORA | Límite documentado de `a!startProcess` síncrono (ver §7). |
| Decidir → reintento de Decidir | Asíncrono (con respaldo en pantalla) | Bucle de reintento ante error de escritura. Hacerlo síncrono encadenaría reintentos dentro de la misma espera. |
| ANULAR PÓLIZA (mecanización) → CMP | Sin cambio (`a!startProcessLink`) | Necesita continuar la cadena hasta la tarea del CMP (R28). `a!startProcess` no la conecta. |
| CrearAccion → Inducción Verti (CMP) | Sin cambio | Es un objeto CMP, fuera del alcance. |

## 7. Qué dice la documentación oficial de Appian (26.6)

- *Start Process Smart Service* (`/suite/help/26.6/Start_Process_Smart_Service.html`): con `isSynchronous: true`, «onSuccess is not evaluated until the child process is complete, regardless of any activity chaining»; «If the process is not completed within 30 seconds, onIncomplete is triggered»; `onIncomplete` también se activa si el proceso se cancela, falla o el iniciador no puede verlo. En `onIncomplete`, `fv!processInfo.pv` llega vacío.
- *Process Model Recipes* / activity chaining: las cadenas de más de 50 nodos, o con más de 5 s entre actividades atendidas, están «strongly discouraged». Más allá del límite de nodos desatendidos (`CHAINED_EXECUTION_NODE_LIMIT`, *Configuring the Process Engine Servers*), la cadena se rompe y el proceso continúa en segundo plano.
- *Autoscale patterns and practices*: en procesos autoscalados, la cadena también termina por timeout de 30 s y los temporizadores la rompen.

Conclusión: el límite síncrono es de 30 s y no se puede ampliar. Por eso se conserva el respaldo.

## 8. Lo no probado

- **`onIncomplete` natural:** no se dio ningún caso real de más de 30 s. El respaldo se probó forzándolo con las versiones temporales (§4).
- **Agotamiento de 90 s** (`SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS`): no se esperó hasta ese límite.
- **Acciones administrativas y anulación fuera de norma:** no aparecieron en los recorridos naturales. El cambio en esas pantallas (lanzamiento síncrono con `onIncomplete`) se aplicó y se releyó, pero **no se ha probado en la UI**.
- **Botones de mecanización** (ANULAR PÓLIZA, FINALIZAR, CANCELAR): no se pulsaron, para no destruir casos. Solo se midió la apertura.
- **Contacto Verti** (solo se eligió Vencimiento) y **RETOMAR** tras POSPONER. En 15788705 se abrió RETOMAR por error de navegación y se volvió sin guardar.
- **Duplicados:** dobles clics rápidos en GUARDAR/ACEPTAR del alta y en FINALIZAR de la CA. La reconsulta mostró una sola solicitud y una sola tarjeta por póliza. No se pueden comprobar desde la UI los envíos a CORE.
- **Tarjeta de la CA positiva:** en 15788713 apareció «Incompleta» al volver y pasó a «Finalizada Positiva» en una consulta posterior (+6 min). Desfase transitorio; ya pasaba antes del cambio (15788697).

## 9. Dudas para el analista

1. Las altas siguen tardando 15–20 s. Ese tiempo ya es del propio proceso (llamadas a servicios en Alta/Decidir/CrearAccion), no de la espera. Si se quiere bajar más, habría que revisar esos servicios.
2. ¿Debe COMPROBAR AHORA verse también cuando la espera es síncrona? Ahora solo aparece cuando la pantalla cae al respaldo, porque durante la espera síncrona Appian muestra su propio indicador de carga.
3. La CA positiva actualiza ahora la tarjeta a «Finalizada Positiva» antes de volver al buscador. Antes la tarjeta quedaba «Incompleta». Hay que confirmar que este es el comportamiento esperado de SCA.

4. El límite de la espera de respaldo es de 90 s (`SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS`); al superarlo, ACEPTAR se habilita y lleva al Detalle o al buscador. ¿Es un valor adecuado?
5. Acciones administrativas y anulación fuera de norma: indicar una póliza o un caso que las genere para poder medirlas.

## 10. Pólizas usadas

Todas están registradas en [polizas/REGISTRO.md](polizas/REGISTRO.md) con «R42-A antes», «R42-A después» o «R42-A respaldo».

## 11. Vídeos

- ANTES: `r42-a-antes-edited.mp4` · DESPUÉS: `r42-a-despues-edited.mp4` · Respaldo: `r42-a-respaldo-fix-v41-edited.mp4` (se entregan con el mensaje final de la sesión; no se suben al repositorio).
