# R45-B — ANL / mecanización: pendiente de autorizar, fecha de suplemento, Acc. Adm. a vencimiento y «Cancelada»

Entorno: Appian TEST, aplicación SCA2, usuario funcional JJGONZ2. Fecha: 06/11/2026. Solo se han modificado objetos SCA2.

## Resumen ejecutivo

| Punto | Resultado |
|---|---|
| B2a `fechaSuplemento` | **OK en ambas rutas en cuanto a la fecha enviada**. NSE-Autos verificado con 15788805. wAutemis (15788817 de R45-C, solo lectura): `<fechaSuplemento>2028-08-21</fechaSuplemento>` = fecha de anulación/vencimiento de la simulación, en formato ISO correcto. NEW rechaza la operación con «M218 … 916-.La Fecha de Efecto no puede ser mayor o menor en 18 meses que la Fecha de Mecanización» (regla externa NEW/GAIA; la póliza vence a ~21 meses). Duda D5. |
| B2b nivel 4/5 → pendiente de autorizar | **No probado**: en el tiempo de la sesión no se encontró en el bloque una póliza cuya simulación diese controles técnicos 05/06 o nivel 00000004/00000005 (las probadas dieron INFORMATIVO). Pendiente. |
| B1 Acc. Adm. sin documentación | **OK en CORE** (15788805: anulación a vencimiento 03/03/2027, mecanización ANULACIÓN REALIZADA, solicitud 5). **Observación UI**: lista «Solicitud Finalizada sin anular» y tarjeta «Mecanización incompleta» no coinciden con CORE (objetos de R45-D). |
| B4 NO en Anulación/Suscripción | **KO para «solicitud 14»; mecanización 4 OK**. Fase 2: se reutilizó `SCA2_finalizarContraAnulPca` (`mcaEstadoFinal` 9, el servicio que deja la 15788807 en 14) en la rama CANCELADA. Con dos solicitudes nuevas (15788821, 15788826) CORE responde `true` pero **no** pasa la solicitud a 14 (queda 2 y después 5): ese servicio solo cancela si hay una gestión de contra anulación abierta. No hay otro servicio reutilizable para este camino → cambio de fase 2 **revertido** (contenido v4/v15 con `versionUuid` nuevos). Ver §B4 fase 2. |
| B3 (análisis) | Hecho: la espera NSE es necesaria en anulaciones directas (NSE tarda segundos-minutos); la cancelación no espera. Ver §B3. |

## Resultados

ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución
---|---|---|---|---|---|---|---|---
B2a-1 | Regla traducida con solicitud del analista (lectura) | `datosSolicitud.fecAnulacion` = fecha simulación 26/04/2027 | Antes 04/11/2026 (fecha alta), después 26/04/2027 | OK | 15788768 (solo lectura, prueba de regla) | — | Designer → PROBAR REGLA antes/después (`r45-b-02`, `r45-b-01`) | Origen: `SCA2_RecordToCdtSolicitudAnulacion` usa `fecanulacion` del record (fecha de alta). Corregido sobrescribiendo con CORE `fecAnulacion`.
B2a-2 | `FECHA_SUPLEMENTO` ANL en solicitud nueva NSE-Autos | = fecha de anulación de la simulación (03/03/2027) | ANL Anulacion ID 2394: FECHA_ANULACION 03/03/2027, FECHA_SUPLEMENTO 03/03/2027, suplemento 7, gestión 43708008 | OK | 15788805 | Finalizar 9171261 | Alta póliza 2002100087562 → AA sin doc → simulación 03/03/2027 → ANULAR PÓLIZA → traza NSE y tabla ANL (`r45-b-08`, `r45-b-09`) | — 
B2a-3 | Ruta wAutemis `ANULAR NEW` | `<fechaSuplemento>` = fecha simulación | Integración 13631 (06/11 12:24) `registrarOpeAnulPolizaEnCentral` con `<fechaSuplemento>2028-08-21</fechaSuplemento>` (= FECHA_ANULACION = FECHA_VENCIMIENTO 21/08/2028, ANL Anulacion 2395). Respuesta NEW HTTP 500, código 4004 «M218 No se ha podido inicializar el suplemento. 916-.La Fecha de Efecto no puede ser mayor o menor en 18 meses que la Fecha de Mecanización de la Operación» → tarea «ANL Gestionar Error Integración Anulacion #2395» | OK (fecha); KO externo (NEW) | 15788817 (R45-C, solo lectura) | ANL #2395 | `ANL_getAnulacionByFilter_qr` y `ANL_getIntegracionesByIdAnulacion` (PROBAR REGLA, sin guardar); Monitorización (variables de la tarea de error, sin completarla) | La fecha la pone el cambio B2a (antes iría la fecha de hoy y la validación de 18 meses no saltaría). Formato correcto. Precedente: con la 15788768 del analista (fecha de hoy, 04/11) NEW dio otro error («M519 Norma 58: debe ser revisada por la subcentral»). Hay tareas de error ANL desde el 30/10 (#2317, #2318, #2322). Decisión funcional → D5.
B2b-1 | Nivel 00000004/00000005 o controles 05/06 → pendiente de autorizar | Gestión mecanización «ANULACIÓN PENDIENTE DE AUTORIZAR», etiqueta «Pendiente de Autorización» | No probado | Pendiente | — | — | Simulaciones probadas (2002100087562, 2002100092136, 2002400195593): INFORMATIVO sin controles | Buscar póliza con controles técnicos; en SCA2 el flujo `crearAutorizacion` (CMD Mecanizar) ya existe (R23).
B1-1 | AA «El cliente no entrega documentación» | Confirmación «se anulará al vencimiento» y anulación a vencimiento | Modal mostrado; simulación y CORE 03/03/2027 (= vencimiento), catalogación A VENCIMIENTO en detalle, sin VERTI, mecanización ANULACIÓN REALIZADA, solicitud 5 | OK | 15788805 | Finalizar 9171261 | Alta A FECHA 06/11/2026 → AA VILLALBA → check sin doc → FINALIZAR → ACEPTAR (`r45-b-03`…`r45-b-07`) | —
B1-2 | Etiqueta lista/tarjeta coherente con CORE | «Finalizada. Anulación realizada» | Lista «Solicitud Finalizada sin anular»; tarjeta gestión «Mecanización incompleta» | KO (UI) | 15788805 | — | Lista «Otras sol.» y detalle | No es carrera NSE (Finalizar esperó 2 ciclos y vio ANULACIÓN REALIZADA). Objetos de R45-D (`SCA2_calcularEstadoSolicitud`, `SCA2_DetalleSolicitud`): comunicado en coordinación, no tocado.
B4-1 | NO en Anulación/Suscripción (antes del cambio) | Solicitud 14, mecanización 4, «Cancelada» | Solicitud 5, mecanización INCOMPLETA (43708029), lista «Pendiente de Autorización» | KO | 15788811 | — | Póliza 2002100092136, AA sin doc, simulación 03/03/2027 → CANCELAR (`r45-b-11`, `r45-b-12`) | `SCA2 CMD CompletarAccion` → `SCA2 CMD Finalizar` (estadoFinal CANCELADA) nunca llamaba a `actualizarMecanizacion` con 4 (SCA: `SCA_Finalizar_Mecanización`, `codEstMecanizacion = if(cancel,"4",…)`).
B4-2 | NO en Anulación/Suscripción (después del cambio) | Solicitud 14, mecanización 4, «Cancelada», no «Mecanización incompleta» | Gestión 5 (43708034) **CERRADA SIN MECANIZAR** 11:58:40–12:01:10; cabecera `estadoSolicitud` **5**, `mcaMecanizada` N, `codCausa` 14, fecAnulacion 01/05/2027; lista «Solicitud Finalizada. Rechazada anulación» | Mecanización OK / Solicitud 14 KO | 15788815 | Finalizar arrancada por CompletarAccion a las 12:01:05 | Póliza 2002400195593 → alta A FECHA → AA VILLALBA sin doc → «¿Desea anular la póliza…?» (01/05/2027 INFORMATIVO) → CANCELAR (= NO) → CORRECTO (`r45-b-13`…`r45-b-18`) | `finalizarSolicitud` de CORE (sin campo de estado) deja 5. El único servicio visto que deja 14 es `finalizarContraAnulPca` con `mcaEstadoFinal` 9 (contra-anulación, 15788807 de R45-D). SCA también termina en «SCA Finalizar Solicitud» tras cancelar, por lo que SCA daría 5+4. Duda D1.
B3-1 | Espera NSE en `SCA2 CMD Finalizar` | Saber si hace falta | 15788805: NSE respondió 10 s después de la llamada (11:12:48 → 11:12:58); Finalizar esperó 2 ciclos de 1 min y encontró suplemento 7 | Análisis | 15788805, 15788815 | 9171261 | Variables de la instancia (`r45-b-10`) y gestiones CORE | Ver §B3.
B4-3 | Fase 2: NO en Anulación/Suscripción con `finalizarContraAnulPca` 9 | Solicitud 14, mecanización 4, «Cancelada» | CORE 5, `mcaMecanizada` N, gestiones 8 FINALIZADA, 3 FINALIZADA, 5 CERRADA SIN MECANIZAR; lista «Solicitud Finalizada. Rechazada anulación» | KO | 15788821 (2002500441389) | `SCA2 CMD Finalizar` (fase 2) | Alta → AA sin documentación → simulación INFORMATIVO → CANCELAR | `finalizarContraAnulPca` responde `true` sin efecto en el estado; `finalizarSolicitud` deja 5.
B4-4 | Fase 2b: además se consulta CORE tras `finalizarContraAnulPca` y solo se omite `finalizarSolicitud` si CORE confirma 14 | Solicitud 14, mecanización 4, «Cancelada», no «Mecanización incompleta» | `mecNseRes` = {cancelada=false, estadoCoreCa=2, caResult=respuesta true, estadoMecanizacion=INCOMPLETA}; después `finalizarSolicitud` → CORE 5 (fecEstado 12:48:04), `mcaMecanizada` N; gestiones 8 FINALIZADA 12:45:16, 3 FINALIZADA 12:45:26–12:46:43, 5 CERRADA SIN MECANIZAR 12:46:46–12:48:02 (43708065/66/67); lista «Solicitud Finalizada. Rechazada anulació…» (`r45-b-20`) | KO | 15788826 (2002100314607, TERCEROS MOTOS, vto 01/08/2027) | `SCA2 CMD Finalizar` 12:48 | Alta 06/11 → AA VILLALBA sin documentación → simulación INFORMATIVO sin controles → CANCELAR (NO) | Tras la llamada CORE sigue en 2 (en mecanización): el servicio de contra anulación no cancela una solicitud sin gestión de contra anulación (la 15788807 tenía la acción 2, que quedó FINALIZADA CANCELADA). Revertido.

## B2a — detalle

Cadena: `SCA2 CMD Mecanizar` → ANL Alta (`solicitudAnulacion` = `SCA2_construirSolicitudAnulacionAnlTraducida`) → `SCAC_DS_solicitudAnulacion.datosCompletosSolicitud.datosSolicitud.fecAnulacion` → ANL Aceptar → `ANL_updateAnulacion` → `ANL Anulacion.FECHA_SUPLEMENTO` → `ANL_getXMLAnularPolizasAutosNew` → `<fechaSuplemento>`.

- SCA: la simulación y ANL usan la `fecAnulacion` de CORE (misma que la simulación).
- SCA2 antes: `fecAnulacion` venía del record SCA2 (fecha de alta de la solicitud, la «de hoy» que vio el analista en 15788768).
- Cambio: la regla toma `MSSConsultarCabecera.fecAnulacion` (left 10) y, si está vacía, conserva la anterior; actualiza solo `datosSolicitud.fecAnulacion`.
- `15788805` prueba la ruta NSE-Autos (ANL guarda la fecha); la ruta `ANULAR NEW` wAutemis usa la misma regla pero no se ha probado.

## B4 — detalle del cambio

- `SCA2_actualizarMecanizacionAnulacionNse` (v3→v4): nuevo parámetro `estadoFinal`; si es `SCA2_TXT_ESTADO_SOL_CANCELADA` y la gestión de mecanización de CORE está INCOMPLETA, llama a `actualizarMecanizacion` con `SCA2_TXT_COD_EST_MECANIZACION_CERRADA` (4); con cancelación no espera a NSE. La rama R44 (NSE OK → 1) no cambia.
- `SCA2 CMD Finalizar` (v14→v15): el nodo «Actualizar mecanización NSE» pasa `estadoFinal: pv!estadoFinal`. Encadenado/síncrono de R42 y espera R44 intactos.
- Backups: `backups-r45/r45-b-SCA2_actualizarMecanizacionAnulacionNse-original.xml`, `backups-r45/r45-b-SCA2_CMD_Finalizar-original.xml`.
- Deployment API: inspect `f9cda774-7401-4ca4-bf2e-4dce2d50140a` (0 errores, 0 avisos), import `d9ff0843-ba59-4186-983e-add460281c22` (2 importados). Nota: con los `versionUuid` originales el inspect marca los objetos como «skipped»; hay que generar uno nuevo por objeto.

## B4 fase 2 — servicio para dejar la solicitud en 14

- Origen del 14 (solo lectura): 15788807 (R45-D) → `SCA2_ContraAnulacionOpciones` → `SCA2_finalizarContraAnulPca` (`PCA_CORECFSA_HTTPRouter/IContraAnularPCA`) con `mcaEstadoFinal` «9». CORE: estado 14, gestión de la acción 2 (contra anulación) FINALIZADA CANCELADA (43708012).
- Acc. Adm. y Fuera de Norma cancelan con sus propios servicios sobre su gestión (`SCA2_AccionesAdministrativasPrincipal` → `SCA2 CMD CompletarAccion` con `mcaEstadoFinal` «CANCELADO»; Fuera de Norma `guardarAutorizacion` `codEstado` 5). Para la mecanización, el equivalente ya aplicado es `actualizarMecanizacion` con estado 4, que no cambia el estado de la solicitud.
- Prueba con el servicio de contra anulación en la rama CANCELADA de `SCA2 CMD Finalizar` (dos importaciones, 15788821 y 15788826): responde `true` pero CORE no pasa a 14. **No existe en SCA2 un servicio reutilizable que cancele la solicitud desde la mecanización**; no se inventa otro. El cambio se revierte y queda la fase 1 (5 + 4, «Rechazada anulación»).
- Deployment API: fase 2b inspect `904ba2aa-0b6b-47f2-a4da-88f8fed85ac9` / import `c7219393-2af4-4231-b36a-18083f1c0ba1` (3 objetos); reversión inspect `2157f746-68c8-47fa-ac08-673ebc8df12b` (2 objetos, 0 errores, 0 avisos) / import `ae314b49-0981-479b-9ab0-000b979e7785` (2 importados). Reexportación: regla `versionUuid` a8bf2392-2754-4b6f-be8a-632cec44d766, PM 7aaea0ac-cbbd-41b1-a401-c73f1716b8ed, sin `finalizarContraAnulPca` ni el flujo «Cancelada (CORE 14)».
- Constantes creadas en fase 2 y que quedan sin uso: `SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA` (9) y `SCA2_TXT_COD_ESTADO_SOL_CANCELADA` (14). No se borran (la Deployment API no elimina objetos); se pueden reutilizar si el analista indica el servicio.

## B3 — análisis (sin cambios)

a) **Espera NSE (R44, hasta 10 × 1 min)**. NSE responde de forma asíncrona: en 15788805 la respuesta (suplemento 7) llegó 10 s después de la llamada y `SCA2 CMD Finalizar` 9171261 la encontró al 2.º ciclo (`contadorNse` = 2). En R44 bastó 1 ciclo. Sin espera, Finalizar cerraría la solicitud con la mecanización INCOMPLETA (el error original de R44). **Propuesta: mantenerla**, valorando bajar el máximo (p. ej. 3–5 min) o el intervalo a 30 s; no aplica a cancelaciones (B4) ni a wAutemis.

b) **15788754** (solo lectura): **no investigada en esta sesión** por falta de tiempo. Pendiente revisar su instancia ANL (sin relanzar ni modificar nada).

c) **«Tipo catalogación» en el alta wAutemis** (lenguaje funcional): al dar de alta una póliza wAutemis el desplegable «Tipo catalogación» solo ofrece «A FECHA», pero la pantalla arranca con el valor 1 propuesto por el servicio de catalogación, que no está entre las opciones; Appian lo considera inválido y muestra el error. Opciones para el analista:
1. Inicializar el desplegable con el valor por defecto válido («A FECHA») cuando solo exista esa opción.
2. Ampliar las opciones para incluir el valor que propone el servicio de catalogación.
3. Impedir que la pantalla mantenga valores fuera de la lista (limpiar el valor al cargar las opciones).
4. Decidir funcionalmente qué catalogación debe aplicar wAutemis (si debe ser siempre A FECHA).

## Comparativa SCA / SCA2

| Caso | SCA | SCA2 |
|---|---|---|
| B2a | ANL con fecha de simulación | Antes fecha de alta; ahora fecha de simulación |
| B1 | Anulación a vencimiento sin documentación | Igual en CORE; etiqueta UI incoherente (R45-D) |
| B4 | `SCA_Finalizar_Mecanización` con cancel → `actualizarMecanizacion` 4 y después «SCA Finalizar Solicitud» | Ahora igual (mecanización 4, solicitud 5). Antes: mecanización INCOMPLETA |
| SCA real | No ejecutado en esta sesión (lentitud/errores documentados en R45-D); comparación por código | — |

## Comparativa con R44

- Se conserva la espera NSE y la actualización a ANULACIÓN REALIZADA de R44-A; B4 añade solo la rama de cancelación.
- R44 mostraba la tarjeta «Anulación realizada»; ahora (15788805) muestra «Mecanización incompleta» con CORE correcto → posible regresión de la fase 2 de R45-D.

## Objetos modificados

| Objeto | Versión | Cambio |
|---|---|---|
| ER `SCA2_construirSolicitudAnulacionAnlTraducida` | +1 (un guardado en Designer) | `fecAnulacion` = CORE `fecAnulacion` (B2a) |
| ER `SCA2_actualizarMecanizacionAnulacionNse` | v3→v4 | parámetro `estadoFinal`, rama cancelación → mecanización 4 (B4) |
| PM `SCA2 CMD Finalizar` | v14→v15 | pasa `estadoFinal` a la regla (B4) |
| ER `SCA2_actualizarMecanizacionAnulacionNse` (fase 2) | v4→v5→v6→v7 (estimado: 3 importaciones; contenido final = v4) | llamada a `finalizarContraAnulPca` 9 + consulta CORE; **revertido** |
| PM `SCA2 CMD Finalizar` (fase 2b) | v15→v16→v17 (estimado: 2 importaciones; contenido final = v15) | rama «Cancelada (CORE 14)» sin `finalizarSolicitud`; **revertido** |
| Constantes `SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA`, `SCA2_TXT_COD_ESTADO_SOL_CANCELADA` | nuevas (v1) | sin uso tras la reversión |

## Solicitudes e instancias nuevas

15788805 (2002100087562, B1/B2a, Finalizar 9171261), 15788811 (2002100092136, B4 antes), 15788815 (2002400195593, B4 después), 15788821 (2002500441389, B4 fase 2), 15788826 (2002100314607, B4 fase 2b). Registradas en `polizas/REGISTRO.md`.

## Dudas para el analista

- D1 (B4): para que la solicitud quede en 14 hace falta una llamada de CORE que la cancele; `finalizarSolicitud` no tiene estado y deja 5. ¿Se acepta 5+4 («Rechazada anulación», como haría SCA) o debe usarse otro servicio (¿cuál?) para dejar 14? No se ha inventado.
- D1 (fase 2): con `finalizarContraAnulPca` 9 CORE no cancela una solicitud sin gestión de contra anulación (15788821, 15788826). ¿Qué servicio de CORE debe cancelar (14) desde la mecanización? Hasta entonces queda 5 + 4.
- D5 (B2a wAutemis): NEW rechaza la anulación a vencimiento a más de 18 meses (error 916). ¿Qué `fechaSuplemento` debe ir en ese caso, o SCA2 debe impedirlo?
- D2 (B3a): ¿máximo de espera NSE aceptable (10 min actual)?
- D3 (B3c): elegir opción 1–4 para «Tipo catalogación» wAutemis.
- D4 (B1): etiqueta «Finalizada sin anular» con CORE 5 + ANULACIÓN REALIZADA → revisar con R45-D.

## Limitaciones y pendientes

- B2b sin probar (no hay póliza con controles 05/06 en el bloque usado).
- B2a ruta wAutemis: fecha verificada en 15788817 (R45-C); falta una wAutemis nueva con vencimiento a menos de 18 meses para ver la anulación completa.
- SCA real no comparado con solicitud nueva.
- LCP/MCP caídos: cambios por Deployment API y Designer.

## Capturas

`../img/r45-b-01` … `r45-b-10` (B2a/B1), `r45-b-11`, `r45-b-12` (B4 antes), `r45-b-13-b4-despues-acc-adm-sin-doc.png`, `r45-b-14-b4-despues-pantalla-anulacion-no.png`, `r45-b-15-b4-despues-tras-no-correcto.png`, `r45-b-16-b4-despues-lista-15788815.png`, `r45-b-17-b4-despues-core-gestiones-15788815.png`, `r45-b-18-b4-despues-core-cabecera-15788815.png`.
