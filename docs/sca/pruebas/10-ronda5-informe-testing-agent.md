# Ronda 5 — NO_MECANIZAR, post-mecanización, acuerdo SI24 y Acción Administrativa

Fechas: 05–06/10/2026. Entorno Appian TEST; UI funcional JJGONZ2. Informe consolidado de las ejecuciones de ronda 5 y de la continuación con `SCA2_notificarNivel` v3. Sin commit. No se modificaron diseños funcionales durante esta continuación; las lecturas LCP usaron la regla scratch temporal autorizada.

**Actualización posterior:** la sección 9 recoge la verificación sólo lectura de `SCA2_DetalleSolicitud` v43. Corrige la ausencia de Autorización y el RETOMAR indebido de D; queda una diferencia en el nombre de un documento. Las secciones 1–8 conservan los resultados históricos previos a v43. Los artefactos locales se identifican por nombre de fichero relativo; las grabaciones se adjuntan por separado.

Se completó el procedimiento con **diferencias y cobertura pendiente**. D recuperó la simulación y completó el envío único y la decisión posterior NSE, pero no se aprueba globalmente Detalle: ofrece RETOMAR sobre una tarea finalizada y omite una gestión visible en SCA. La nueva inserción SGC v3 **no queda probada end-to-end** con estos datos.

## 1. Veredicto por escenario

| Escenario | Solicitud / póliza | Resultado |
|---|---|---|
| A — NO_MECANIZAR | 15787791 / 0007051051140 | **PASA avance a nivel 2 SI24 y regresión de render. Con reservas:** en la ejecución inicial hubo falsa redirección/Preparando y datos obsoletos hasta recargar; no se repitió ese tránsito con versiones posteriores. Solicitud CE_RM y tarea CE_MF_BK siguen discrepando. |
| B — post-mecanización | 15787792 / 2001900006477 | **PASA envío único, retorno y nivel 2 CE_RM; regresión actual PASA.** Fallos históricos de XML NSE y refresco de nivel documentados. Nueva notificación SGC v3 no reejecutada. |
| C — banner acuerdo | 15787793 / 0002729326376 | **PASA** banner SI24 encima de Contra anulación, tanto en evidencia anterior como en la apertura actual. No se completó la CA. |
| D — Acción Administrativa → MEC | 15787794 / 2002000062822 | **PASA simulación, reserva, envío único, retorno sin bucle y finalización NSE persistida. FALLA paridad de Detalle:** RETOMAR indebido y ausencia del acordeón Autorización. ANL sin desbloqueo, no considerado defecto de la ruta NSE. |

No se pulsó ANULAR en A, C ni solicitudes históricas en esta continuación. En B se conserva exclusivamente la evidencia del envío anterior; en D se pulsó una sola vez en esta ejecución.

## 2. Método y alcance de comparación

- SCA2: `https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/buscador`.
- Referencia SCA: `https://mapfrespain-test.appiancloud.com/suite/sites/sca-site`.
- Navegación y verificaciones visuales grabadas; consultas persistidas mediante LCP Basic Auth, no mediante cookies extraídas del navegador.
- A–C: reapertura actual sin reejecutar resultados, documentos ni envíos. C se abrió con RETOMAR sólo para visualizar el banner.
- D: comparación actual SCA/SCA2 del mismo ID en buscador y Detalle. No se ejecutó un segundo flujo destructivo en SCA. La comparación de A–C es limitada: se conservan expectativas y resultados de rondas previas, pero esta continuación no vuelve a ejecutar ni certificar un flujo equivalente completo en SCA.
- Se distingue **estado SCA2 de orquestación**, **tareas**, **gestiones CORE** y **estado externo ANL**. No son intercambiables.
- Fuentes históricas: planes y capturas `r7/out`, anotaciones de grabaciones anteriores, y `persisted_ronda5_lead.md`. Se identifican como históricas, no como prueba de v3.

## 3. A — NO_MECANIZAR → nivel 2 SI24

### Pasos y UI

En la ejecución inicial se creó 15787791 sobre póliza 0007051051140: DECISIÓN CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, A VENCIMIENTO; CA negativa con carta y FINALIZAR. El caso avanzó por NO_MECANIZAR a nivel 2, sin envío de anulación.

La primera card de la versión entonces probada mostró falsa redirección/«Preparando» antes de desaparecer. En Detalle ambas CA parecían Incompleta antes de recargar; después la primera fue Finalizada Negativa y la segunda Incompleta, nivel 2 GGE EXPERTOS SI24. **Este defecto histórico no se borra del veredicto:** la reapertura actual no prueba que el tránsito sin F5 esté corregido.

En el repaso del 06/10: buscador → 15787791 → segunda Contra Anulación. **PASA:** Incompleta, nivel 2, perfil GGE, grupo GGE EXPERTOS SI24. No se retomó ni completó la tarea.

### Persistencia y SCA frente a SCA2

Lectura actual a 06:05:48 UTC:

- SCA2 Solicitud: EN_ACCION, procesoActivo CONTRA ANULAR NIVEL 2, nivelIntervencion 2, version 8, dueEnviado=true.
- Tarea 95 CONTRAANULAR COMPLETADA; tarea 96 CONTRA ANULAR NIVEL 2 PENDIENTE, grupo CE_MF_BK.
- **Diferencia persistida:** solicitud.grupoAsignacion=CE_RM frente a tarea.grupo=CE_MF_BK. No se declara alineación completa solicitud/tarea.
- Notificación histórica aportada por el lead: SI24 «Envio DUE - Correo enviado SI24», perfil CE_MF_BK.
- SCA2 Error vacío en la consulta de A–D.
- El resultado SI24 es coherente con el destino funcional esperado de SCA, pero no se repitió una CA destructiva en SCA. **No verificada la recepción del correo en JOSPENA@mapfre.com.**

| 🔴 A — card inicial histórica, falsa redirección | 🟢 A — regresión actual, nivel 2 SI24 |
|---|---|
| ![A card histórica](https://mapfre.devinenterprise.com/attachments/82abaed4-01e4-4808-9668-1ced9dc2bb22/r5-A-card.png) | ![A nivel 2 actual](https://mapfre.devinenterprise.com/attachments/5fd68090-02d0-4b8a-9b20-89ffb04cd6fb/ss_2ad639dd.png) |

Capturas locales: `r5-A-card.png`, `r5-A-antes-recarga.png`, `r5-A-ca-tras-recarga.png`, `r5-A-nivel2.png`, `ss_2ad639dd.png`.

## 4. B — POSPONER/RETOMAR y decisión post-mecanización

### Secuencia de las ejecuciones anteriores

1. Alta única 15787792, póliza 2001900006477. CA → POSPONER → buscador.
2. En continuación v40: RETOMAR visible sin F5, misma solicitud; negativa y carta; FINALIZAR/confirmar. La card esperó con ACEPTAR deshabilitado.
3. **Fallo histórico:** ACEPTAR al abrir NSE produjo error `xpathsnippet`, línea 83, XML inválido. No se considera esa ejecución aprobada.
4. En continuación NSE v13/v41: inicialmente importe «-» y sin prueba de recuperación. Después importe **0**; un ANULAR, primera card con guardado y envío, un ACEPTAR volvió al buscador.
5. La nueva CA apareció sin F5, pero mostró datos antiguos de nivel 1 pese a persistencia nivel 2: **fallo histórico de refresco**.
6. Reapertura v42: CA Incompleta nivel 2 OFICINA; MEC realizada, fin 05/10 21:20:36. No se volvió a pulsar ANULAR.

### Repaso actual y persistencia

Buscador → 15787792 → CA de nivel 2: **PASA** Incompleta, nivel 2, RED MAPFRE / OFICINA. MEC conserva Anulación Realizada.

- Solicitud: EN_ACCION, procesoActivo CONTRA ANULAR NIVEL 2, nivel 2, CE_RM, version 12, mecanizacionRealizada=true.
- Tareas: 97 CONTRAANULAR COMPLETADA; 99 MECANIZAR FINALIZADA; 102 CONTRA ANULAR NIVEL 2 PENDIENTE CE_RM.
- Historial: Mecanizar PDTE_MECANIZAR→MECANIZADA → IR A NIVEL 2; CrearAccion→NIVEL; Decidir EN_DECISION→DECIDIDA; CrearAccion→EN_ACCION.
- idgestionsgc=233844144. Notificaciones históricas: NSE Salida Anular Póliza, suplemento 12; SGC INFORMAR 233844162 por POSPONER; SGC MODIFICACION identificador 0 al finalizar la gestión de posponer.
- **Faltaba la notificación SGC correspondiente a 233844144 en la ejecución anterior.** Es precisamente el caso cubierto por el cambio v3, pero no se recreó el cambio de nivel de B para probarlo. No se confunde el INFORMAR de POSPONER con la nueva notificación de nivel.
- Error vacío. No se presenta la reapertura como prueba del refresco inmediato sin F5 ni de la inserción v3.

Comparación SCA/SCA2: destino funcional esperado CE_RM y datos de gestión consultables; no se ejecutó anulación paralela en SCA, ni se prueba aquí paridad completa del tránsito.

| B — regresión actual, MEC y CA nivel 2 | C — regresión actual, banner SI24 |
|---|---|
| ![B nivel 2 actual](https://mapfre.devinenterprise.com/attachments/cd0fd100-688b-4efa-96ab-9846920cd574/ss_d95e9028.png) | ![C banner actual](https://mapfre.devinenterprise.com/attachments/849d05b5-be67-4eea-bf67-7daf7ba14afd/ss_808fc61f.png) |

Capturas B: `r5-B-final.png`, `r5-B-tras-recarga.png`, `ss_ce623d8b.png`, `ss_d95e9028.png`.

## 5. C — acuerdo SI24, póliza 0002729326376

Solicitud 15787793. En la ronda 5 inicial se comprobó la advertencia; en el repaso actual: buscador → solicitud → Contra Anulación → RETOMAR → parte superior del formulario.

**PASA:** banner informativo visible entre cabecera y título Contra anulación:

> Esta poliza es de un acuerdo que trata SI24. La retención o anulación de la póliza se trasladara al SI24

No se guardó, pospuso, canceló ni finalizó. Persistencia consultada: EN_ACCION, procesoActivo CONTRAANULAR, nivel 1, grupo CE_RM, version 3; tarea 98 CONTRAANULAR PENDIENTE. Error vacío.

SCA frente a SCA2: el contenido y ubicación cumplen la advertencia funcional de referencia; esta continuación verifica visualmente SCA2, no ejecuta la tarea equivalente en SCA. No se prueba el envío posterior SI24 de C.

Capturas: `r5-C-banner.png`, `r5-C-banner-verificado.png`, `ss_808fc61f.png`.

## 6. D — Acción Administrativa → mecanización, 15787794

### Preparación histórica y bloqueo anterior

Alta única de 15787794 sobre 2002000062822: DECISIÓN CLIENTE / VENTA VEHÍCULO / NO VOY A COMPRARME OTRO COCHE, A FECHA. La entrega de justificante de compraventa y DNI habilitó FINALIZAR. Confirmar la AA y un ACEPTAR abrieron NSE.

Las continuaciones anteriores dejaron D en PDTE_MECANIZAR con tarea pendiente. Se documentaron importe «-» y un episodio de indisponibilidad HTTP 500/mensaje controlado en el contexto recibido. Las anotaciones v13/v41 y v42 conservadas sólo prueban importe «-», sin ANULAR, y no prueban por sí mismas la rama HTTP 500. **No se fusionan esos intentos en un supuesto envío anterior:** D no fue anulado hasta esta continuación.

### Ejecución actual, 06/10/2026

1. Abrir D → Mecanización → RETOMAR. **PASA:** simulación con importe **-396.54**, reserva **Sí**, nivel cumplimiento **PENDIENTE DE AUTORIZAR**, ANULAR habilitado; sin mensaje de indisponibilidad.
2. Pulsar **ANULAR PÓLIZA una sola vez**. Aparece aviso de reserva; ACEPTAR una vez.
3. **PASA:** card CORRECTO de guardado/envío y ACEPTAR retorna al buscador. No hay bucle mensaje → volver a mecanización ni segundo ANULAR.
4. Buscador final SCA2: **Finalizada no requerida contraanulación**, resolución 06/10/2026 **08:05:58**, observación `RESPUESTA SUSCRIPCION NSE: Num Solicitud Anulacion: 2002642G0000063`.
5. SCA, mismo ID en lectura: mismo estado final, resolución **08:05:57**. Diferencia de un segundo entre fecha externa y fecha de cierre SCA2, no un segundo envío.

| D — simulación recuperada | D — confirmación de reserva |
|---|---|
| ![D importe numérico](https://mapfre.devinenterprise.com/attachments/bafabc44-65b0-44e3-941b-a34bc4ef072d/ss_79257816.png) | ![D reserva](https://mapfre.devinenterprise.com/attachments/1732fd35-aa3b-49cd-9f80-2fd6d3be1a6f/ss_86621002.png) |

| D — card tras envío | D — buscador final |
|---|---|
| ![D correcto](https://mapfre.devinenterprise.com/attachments/67aa76ff-ab0e-463e-a8c3-2f941daeee54/ss_eab7b829.png) | ![D finalizada](https://mapfre.devinenterprise.com/attachments/c0c607da-2606-4caf-b983-33bee29a5f6a/ss_b7e930ee.png) |

### Persistencia final y cronología

Lectura final SCA2: **06:06:43 UTC**; UI local UTC+2.

| Objeto/campo | Resultado |
|---|---|
| Solicitud.estadoSolicitud / interfazActiva | FINALIZADA / FIN |
| procesoActivo / estadoTarea | null / COMPLETADA |
| nivelIntervencion / grupoAsignacion | 2 / CE_RM |
| mecanizacionRealizada / version | true / 11 |
| modifiedAt | 2026-10-06 06:05:58.230 UTC |
| Tarea 100, ACCIONES ADMINISTRATIVAS | COMPLETADA, CE_RM; cierre 05/10 19:17:28.190 UTC |
| Tarea 101, MECANIZAR | FINALIZADA, CE_RM; cierre 06/10 06:05:36.940 UTC |
| SCA2 Error | `[]` |
| CORE codEstSolicitud | `"5"` |
| CORE gestión 5 / numGestion | INCOMPLETA / 43705114; fin 06/10 08:05:57 local |
| CORE gestión 7 / numGestion | FINALIZADA / 43705117; fin 06/10 08:05:57 local |
| ANL ID_ANULACION / NUM_GESTION | 2091 / 43705114 |
| ANL ESTADO / DESBLOQUEO_ANULACION | null / null |
| Datos básicos idgestionsgc | `"0"` |
| Lookup notificaciones externas D | MSSConsultarNotificacionesExt=null |

Transiciones persistidas, todas resultado OK:

| Hora UTC 06/10 | Comando | Origen → destino |
|---|---|---|
| 06:05:28.260 | Mecanizar | PDTE_MECANIZAR → MECANIZADA |
| 06:05:36.940 | Mecanizar / CambioNivel | MECANIZADA → IR A NIVEL 2 |
| 06:05:39.590 | CrearAccion | MECANIZADA → NIVEL |
| 06:05:50.360 | Decidir | EN_DECISION → DECIDIDA |
| 06:05:54.120 | CrearAccion | DECIDIDA → FIN |
| 06:05:58.230 | Finalizar | FIN → FINALIZADA |

**Decidir posterior a mecanización sí queda demostrado por las transiciones; destino final FIN/FINALIZADA, no una tarea CA nivel 2 pendiente.** No se capturó la variable literal de retorno de Decidir (`FIN PROCESO`), por lo que no se presenta ese literal como observado directamente.

ANL se leyó a **06:06:13 UTC** con ESTADO y DESBLOQUEO_ANULACION nulos. **No se observó desbloqueo ANL ni se afirma una decisión causada por él.** Según aclaración del lead, la espera de SCA Mecanizacion nodo 14 corresponde a ciertas variantes wAutemis/observaciones 00000005/6; NSE termina la mecanización y el padre decide sin esperar ANL. Así se interpreta la cadena observada de D, no como defecto por ausencia de desbloqueo.

### Diferencias de Detalle — pendientes de corrección/verificación

**FALLA:** SCA2 ofrece RETOMAR en MEC aunque tarea 101 está FINALIZADA y solicitud FINALIZADA. No se pulsó: no se prueba qué ocurriría al usar ese control ni se arriesgó un segundo envío. El lead confirmó que corregirá el tratamiento de ese estado después del informe; esa futura corrección no está cubierta aquí.

**Diferencia funcional:** SCA presenta además acordeón **Autorización — Pendiente**; SCA2 no lo muestra. CORE devuelve gestión de acción 7 FINALIZADA, por lo que tampoco se equipara automáticamente ese rótulo de SCA a una autorización activa real.

Ambos muestran **MECANIZACIÓN INCOMPLETA**, coincidente con CORE gestión 5. Esa etiqueta compartida no se transforma en defecto exclusivo de SCA2 ni en prueba de anulación emitida; lo demostrado es cierre de la orquestación y respuesta de suscripción NSE.

| D — referencia SCA, sin RETOMAR y con Autorización | D — SCA2, RETOMAR indebido y sin Autorización |
|---|---|
| ![D Detalle SCA](https://mapfre.devinenterprise.com/attachments/a9196134-a05a-47d7-898a-66ec14512bca/ss_1a88dbaa.png) | ![D Detalle SCA2](https://mapfre.devinenterprise.com/attachments/dbce5584-08a8-46e3-ad6e-e4ec63af9eec/ss_d7189348.png) |

### Notificación SGC v3

Se confirmó versión 3 desplegada por lectura LCP. **Esto no demuestra ejecución de su inserción.** D termina en FIN y tiene idgestionsgc `"0"`; según alcance confirmado por el lead, no aplica nueva notificación SGC en D. B conserva la gestión de nivel 2 anterior a v3 y no se reprodujo su cambio de nivel. Queda pendiente una ejecución nueva y autorizada que genere gestión CE_RM válida y permita correlacionar la notificación con su nuevo ID_GESTION_COMERCIAL. No se invocaron helpers mutadores para fabricar la evidencia.

## 7. Evidencias y archivos

### Grabaciones

- D + comparación SCA + regresión A/B/C, antes de v43: `sca-ronda5-v3-final-edited.mp4`.
- Histórica inicial A/C y preparación B: `sca-ronda5-r7-recuperada-final.mp4`.
- Histórica B RETOMAR y error XML: `sca-ronda5-continuacion-v40-edited.mp4`.
- Histórica AA de D y envío B: `sca-ronda5-nse-v13-v41-edited.mp4`.
- Histórica reapertura B / D bloqueado: `sca-ronda5-cierre-v42-edited.mp4`.

Las grabaciones históricas reflejan versiones e incidencias anteriores; no son aprobación de la versión actual. Las duraciones de vídeos editados no sirven para medir tiempos de servicios.

### Capturas actuales D

- Simulación: `ss_79257816.png`.
- Reserva: `ss_86621002.png`.
- Card: `ss_eab7b829.png`.
- Retorno buscador: `ss_9d149cf9.png`.
- Buscador final: `ss_b7e930ee.png`.
- Detalle SCA2: `ss_d7189348.png`.
- Detalle SCA: `ss_1a88dbaa.png`.

### Lecturas persistidas y trazabilidad

- A–D, Solicitud/Tarea/Transicion/Error, lectura intermedia: `current_after_D.json`.
- D final, Solicitud/Tarea/Transicion/Error: `D_final_records.json`.
- D ANL, lookup notificaciones y datos completos: `D_anl_notificaciones.json`.
- Metadatos para resolver UUID de campos ANL: `anl_metadata.json`.
- D CORE, detalle y gestiones: `D_core_final.json`.
- Persistencia histórica del lead: `persisted_ronda5_lead.md`.
- Versión desplegada: `notificarNivel_v3_readback.json`.
- Plan: `plan-testing-v3.md`; excepción NSE/ANL aclarada por el lead durante la ejecución.

La primera consulta scratch de CORE devolvió las claves de la expresión anterior. Se descartó como evidencia CORE y se repitió serialmente; la segunda devuelve `detalle`/`gestiones`, sin error ni truncamiento. No se contaron respuestas cacheadas como nuevas lecturas.

## 8. Limitaciones y pendientes

1. Corregir y revalidar RETOMAR sobre MEC FINALIZADA y revisar paridad del acordeón Autorización.
2. Resolver/aceptar la discrepancia A entre grupoAsignacion CE_RM y tarea CE_MF_BK.
3. No probada end-to-end la inserción SGC v3 con una nueva gestión de nivel CE_RM. No se repiten B ni D para forzarla.
4. No probada recepción del correo en **JOSPENA@mapfre.com**; dueEnviado y notificación registrada no equivalen a recepción en buzón.
5. ANL D no desbloqueado en la lectura registrada; no se afirma ruta post-desbloqueo ni cierre externo de emisión.
6. No probada como literal de variable la decisión `FIN PROCESO`; sí probada la secuencia persistida hasta FIN/FINALIZADA.
7. La reapertura A/B no revalida los tránsitos inmediatos sin F5 que fallaron en las versiones anteriores.
8. La página `/errores` no estuvo disponible para JJGONZ2 en la ronda anterior; el vacío de errores se verificó por LCP, no en esa cola UI.
9. MCP configurado no arrancó por ausencia de APPIAN_USERNAME/APPIAN_PASSWORD en su proceso. Se usó el cliente LCP existente y sesión UI abierta; no se instalaron dependencias ni se levantaron servidores locales.

**Conclusión:** A/B/C conservan los resultados visibles esperados en la regresión actual y D completa la cadena NSE autorizada sin bucle. No procede declarar aprobación global sin atender las diferencias de Detalle y las coberturas pendientes anteriores.

## 9. Verificación posterior — Detalle v43, sólo lectura

Fecha: 06/10/2026. UI TEST JJGONZ2. Delta comunicado: tareas FINALIZADA excluidas de pendientes y fila Autorizacion desde gestión CORE 7 cuando falta tarea equivalente. Fuente de navegación/condiciones: `detsol_v43_readback.sail` (líneas 85–93, 116–164 y 990–1033); plan `plan-v43-ui.md`.

**Procedimiento completado con una diferencia de contenido; no se declara paridad completa.** Se abrieron detalles y se desplegaron acordeones. No se pulsaron RETOMAR, REASIGNAR, ANULAR, TRAZAR ANULACIÓN, descarga de documentos ni acciones de tarea. No se hicieron nuevas consultas de persistencia ni se reejecutaron los procesos anteriores.

### 9.1 D — 15787794, correcciones visibles

Desde últimos resultados del buscador SCA2 se abrió 15787794 y se inspeccionaron Alta, AA, MEC y Autorización. En otra pestaña se abrió el mismo ID desde el buscador SCA, referencia equivalente a `ss_1a88dbaa.png`.

- **PASA:** cuatro etiquetas en el orden esperado: Alta Solicitud **Finalizada**, Acciones Administrativas **Finalizada**, Mecanizacion **Incompleta**, Autorizacion **Pendiente**.
- **PASA:** Autorizacion está al final del acordeón y se despliega.
- **PASA:** no aparece RETOMAR ni REASIGNAR al inspeccionar las gestiones de D, incluidas MEC y Autorización. La diferencia de controles registrada antes de v43 queda corregida en esta reapertura.

| 🔴 SCA2 antes de v43 — RETOMAR indebido, sin Autorización | 🟢 SCA2 v43 — cuatro gestiones |
|---|---|
| ![D antes de v43](https://mapfre.devinenterprise.com/attachments/dbce5584-08a8-46e3-ad6e-e4ec63af9eec/ss_d7189348.png) | ![D etiquetas v43](https://mapfre.devinenterprise.com/attachments/f29301b4-2eb1-4d1d-9ade-60bf5a572921/ss_3572897d.png) |

### 9.2 D — contenido de Autorización frente a SCA

| Campo | SCA | SCA2 v43 | Resultado |
|---|---|---|---|
| Inicio / fin gestión | 06/10/2026 08:05:28 / 08:05:57 | Igual | PASA |
| Nivel / perfil / grupo / usuario | 1 / RED MAPFRE / OFICINA / JJGONZ2 | Igual | PASA |
| Centro emisor / situación Autemis | - / - | Igual | PASA |
| Resultado / observaciones | PENDIENTE / - | Igual | PASA |
| Documento 0900ab4481a06c6d, 05/10/2026 | **Autorización** | **Justificante compra** | **FALLA paridad del nombre** |
| Documento 0900ab4481a06dc9, 05/10/2026 | Dni | Dni | PASA |

La referencia, fecha y número de filas documentales coinciden, pero el nombre del primer tipo documental no. Se notificó al lead; no se atribuye automáticamente el error a un sistema concreto sin decidir cuál es el catálogo funcional correcto. Los documentos no se abrieron, por lo que su contenido binario queda fuera de esta comprobación.

| SCA — Autorización desplegada | SCA2 v43 — Autorización desplegada |
|---|---|
| ![D contenido SCA](https://mapfre.devinenterprise.com/attachments/41ad2b41-1368-4d28-ba42-9f0c564f54b0/ss_afdd43eb.png) | ![D contenido SCA2 v43](https://mapfre.devinenterprise.com/attachments/2291ec7a-bf80-4c0d-853e-3707d8bb1eae/ss_49bffad6.png) |

### 9.3 Regresiones solicitadas

- **PASA — S4 15787703:** búsqueda por póliza 2002000066389 → solicitud → Autorizacion. Hay exactamente **una** fila Autorizacion Pendiente, antes y después de desplegarla; no se sintetiza una segunda. Muestra inicio 30/09/2026 11:38:20, sin fin, nivel 1, OFICINA, sin documentos y observación «Prueba S4 posponer 2». No se valida de nuevo el proceso histórico S4.
- **PASA — B 15787792:** segunda Contra Anulacion **Incompleta**, nivel **2**, grupo **OFICINA**, conserva **RETOMAR** visible. No se pulsa. RETOMAR/REASIGNAR son alternativas condicionadas por asignación: con esta sesión se mostró RETOMAR; la rama REASIGNAR no se verificó porque requeriría otra asignación/usuario y no se autorizó modificar tareas. También aparece Autorizacion Pendiente al final por el nuevo tratamiento CORE; no impide el control de la CA pendiente.

| Regresión S4 — una única Autorización | Regresión B — CA nivel 2 conserva RETOMAR |
|---|---|
| ![S4 sin duplicado](https://mapfre.devinenterprise.com/attachments/2fc5a52e-ece7-4a82-8057-5444e2a574d7/ss_b7e052a3.png) | ![B conserva RETOMAR](https://mapfre.devinenterprise.com/attachments/779dde56-88cc-49b6-af15-066550b29e98/ss_ce427fd7.png) |

### 9.4 Evidencia y veredicto del delta

- Grabación: `sca-detalle-v43-readonly-edited.mp4`.
- D etiquetas: `ss_3572897d.png`; MEC sin acciones: `ss_cace50bc.png`; Alta/AA sin acciones: `ss_a8c50b9c.png`.
- D Autorización SCA2: `ss_49bffad6.png`; referencia SCA: `ss_afdd43eb.png` y `ss_b3ed9580.png`.
- S4: `ss_5b83b0df.png` (cerrado), `ss_b7e052a3.png` (desplegado).
- B: `ss_ce427fd7.png`.

**Veredicto:** PASAN exclusión de FINALIZADA de acciones pendientes, incorporación de Autorización en D, ausencia de duplicado S4 y conservación de RETOMAR en B. **FALLA la paridad exacta de contenido documental** por «Autorización» frente a «Justificante compra». Los dos hallazgos originales de Detalle quedan corregidos visualmente; permanece esta diferencia nueva y las limitaciones ajenas al delta de la sección 8 (SGC v3, correo, ANL y refrescos históricos).

## 10. Verificación posterior — Detalle v44, etiquetas documentales

**Entorno y alcance:** Appian TEST, sesión JJGONZ2; sólo lectura. Se reabrió D `15787794` desde el buscador SCA2 para cargar v44 y se desplegaron Autorización y Acciones Administrativas. Después se reabrió D en SCA para contrastar AA y B `15787792` en SCA2 para comprobar CA. No se pulsaron acciones de tarea, RETOMAR/REASIGNAR ni apertura/descarga de documentos.

### 10.1 Resultados

| Comprobación | Esperado y observado en pantalla | Resultado |
|---|---|---|
| D — Autorización | `0900ab4481a06c6d` = **Autorización**; `0900ab4481a06dc9` = **Dni** | **PASA**; corrige la diferencia documental de la sección 9 |
| Regresión D — Acciones Administrativas SCA2 | Las mismas referencias conservan **Justificante compra** / **Dni** | **PASA** |
| Referencia D — Acciones Administrativas SCA | **Justificante compra** / **Dni**, mismas referencias y fecha 05/10/2026 | **PASA**; coincide con SCA2 |
| Regresión B — Contra Anulación nivel 2 | `0900ab4481a06887` conserva **Carta firmada** | **PASA**; RETOMAR sigue visible, no pulsado |

**Incidencia de navegación recuperada:** la pestaña antigua de SCA mostró «La tarea solicitada no está disponible» al desplegar AA (`ss_29981879.png`). Se navegó al buscador SCA y se abrió D de nuevo; AA se desplegó correctamente y permitió completar la comparación. No se atribuye este mensaje al cambio v44 de SCA2.

### 10.2 Evidencia visual

| D — Autorización SCA2 v44, corrección | Regresión D — AA SCA2, sin cambio |
|---|---|
| ![Autorización v44](https://mapfre.devinenterprise.com/attachments/5c2e5acd-5674-40c1-ad44-d5ef98537abf/ss_fd2ad541.png) | ![AA SCA2](https://mapfre.devinenterprise.com/attachments/e1bc40fa-f49b-432f-bc09-16ac9a992b64/ss_d6ee7df0.png) |

| Referencia D — AA SCA | Regresión B — CA SCA2 |
|---|---|
| ![AA SCA](https://mapfre.devinenterprise.com/attachments/aae1413f-740a-402b-929d-7370f822713f/ss_9e7705ab.png) | ![CA conserva Carta firmada](https://mapfre.devinenterprise.com/attachments/d30e9a09-271a-4d72-af27-c69b793c3210/ss_bffe3108.png) |

- Grabación: `sca-detalle-v44-documentos-edited.mp4`.
- Capturas: `ss_fd2ad541.png` (Autorización), `ss_d6ee7df0.png` (AA SCA2), `ss_9e7705ab.png` (AA SCA), `ss_bffe3108.png` (CA B).
- Plan: `plan-v44-ui.md`.

**Veredicto del delta v44:** pasan las tres comprobaciones documentales solicitadas. La diferencia Autorización/Justificante compra detectada en v43 queda corregida en D, sin alterar los tipos de AA ni CA observados. Esta verificación no amplía cobertura a otros tipos documentales/casos, ni reejecuta S4, mecanización, SGC, correo o ANL; siguen aplicando las limitaciones históricas que no corresponden a este delta.

## 11. Verificación posterior — Detalle v45, parseo explícito de Anulación

**Entorno y alcance:** Appian TEST, sesión JJGONZ2; comprobación UI sólo lectura. Desde el buscador SCA2 se abrió cada solicitud y se desplegó Mecanizacion; se abrió la misma solicitud en SCA y se comparó literalmente la fecha del hito **Anulación**. No se pulsaron acciones de tarea, RETOMAR, TRAZAR ANULACIÓN ni ANULAR; tampoco se modificaron preferencias.

El error comunicado antes de v45 era `Error in a!forEach() during iteration 2 ... at function 'todate' [line 596]: Could not cast from Time to Date with Timezone`. **No apareció este error ni otro error visible de renderizado en las siete aperturas SCA2 verificadas.**

### 11.1 Configuración de la sesión

JG → Configuración mostró los siguientes valores, sin guardar cambios:

- Configuración regional: **Usar valor predeterminado del sistema: Español (España)**.
- Zona horaria: **Usar valor predeterminado del sistema: (UTC+01:00) hora de Europa central (Europe/Madrid)**.
- Calendario: **Usar valor predeterminado del sistema: Gregoriano**.
- Evidencia: `ss_47062af6.png`.

### 11.2 Comparación de fechas visibles

| Solicitud | Póliza | Anulación SCA2 v45 | Anulación SCA | Resultado | Capturas SCA2 / SCA |
|---|---|---|---|---|---|
| 15787794 (D) | 2002000062822 | 05/10/2026 | 05/10/2026 | **PASA**, sin error | `ss_caae6b2e.png` / `ss_dd712dcb.png` |
| 15787792 (B) | 2001900006477 | 02/08/2027 | 02/08/2027 | **PASA**, sin error | `ss_4987158a.png` / `ss_430cf6d2.png` |
| 15787761 | 2002000026784 | 06/03/2027 | 06/03/2027 | **PASA**, sin error | `ss_f876613f.png` / `ss_1a08e75e.png` |
| 15787764 | 2002000042310 | 01/05/2027 | 01/05/2027 | **PASA**, sin error | `ss_37b1be30.png` / `ss_5d20839b.png` |
| 15787765 | 2002000068248 | 05/06/2027 | 05/06/2027 | **PASA**, sin error | `ss_3bd87481.png` / `ss_a3666029.png` |
| 15787783, adicional reciente (05/10/2026) | 2002200588051 | 03/01/2027 | 03/01/2027 | **PASA**, sin error | `ss_d861223a.png` / `ss_abf1b297.png` |
| 15787751, adicional con **día >12** | 2002200566753 | **15/11/2025** | **15/11/2025** | **PASA**, sin error | `ss_52dfc98d.png` / `ss_bca0d297.png` |

Los seis primeros casos tienen días de anulación ≤12. Se añadió 15787751 para cubrir expresamente un día >12, sin alterar datos. La comparación usa el hito Anulación de Mecanizacion, no la fecha de inicio/fin de gestión ni la fecha del buscador.

### 11.3 Evidencia visual

| 15787751 — SCA, referencia día >12 | 15787751 — SCA2 v45, día >12 |
|---|---|
| ![SCA Anulación 15/11/2025](https://mapfre.devinenterprise.com/attachments/0a171e05-4e87-41ba-b31f-70432c8f6831/ss_bca0d297.png) | ![SCA2 Anulación 15/11/2025](https://mapfre.devinenterprise.com/attachments/aaffc260-2c4f-4f95-9508-75f3ae94c203/ss_52dfc98d.png) |

| 15787783 — SCA, adicional reciente | 15787783 — SCA2 v45, adicional reciente |
|---|---|
| ![SCA Anulación 03/01/2027](https://mapfre.devinenterprise.com/attachments/8f6cbb53-379c-44f9-ad76-0eeacc3f8fa3/ss_abf1b297.png) | ![SCA2 Anulación 03/01/2027](https://mapfre.devinenterprise.com/attachments/1d780f22-8411-44b2-8525-e94c94458be2/ss_d861223a.png) |

![Configuración regional de JJGONZ2](https://mapfre.devinenterprise.com/attachments/af12c402-db70-47d1-b4c6-763e712c8779/ss_47062af6.png)

- Grabación: `sca-detalle-v45-fechas-edited.mp4`.
- Plan: `plan-v45-ui.md`.

**Veredicto del delta v45:** pasan las siete comprobaciones UI: Detalle y Mecanizacion se renderizan sin el error comunicado y las fechas de Anulación coinciden con SCA, incluidas fechas ambiguas día/mes y el caso 15/11/2025. Cobertura solicitada completada en la sesión indicada. No se demuestra funcionamiento en otros locales, formatos CORE nulos/incorrectos o todos los registros posibles; no se cambió el locale para esta verificación sólo lectura. Tampoco se reejecutan procesos ni se amplía la cobertura histórica de SGC, correo o ANL.
