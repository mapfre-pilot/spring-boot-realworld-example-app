# R10-D — Plan de pagos, Acción Administrativa con documentos y autorización/rechazo por NSE

Sesión hija R10-D de la ronda 10 (`27-plan-ronda10.md`, coordinación `coordinacion-ronda10.md`). Entorno Appian TEST; SCA es la referencia funcional y SCA2 la reimplementación. Pólizas: sección R10-D de `polizas-ronda10.md` (plan de pagos), de arriba abajo; no se han usado pólizas de reserva del padre. Fecha: 2026-10-14. UI con JJGONZ2 (Red Mapfre / CE_RM Oficina); comprobaciones en CORE con las reglas `SCA2_consultaGestion`, `SCA2_consultarDetalleSolicitud`, `SCA2_consultaDetalleGestion`, `SCA2_consultarDocumentos`, `SCA2_consultarAutorizacion` y `SCA2_consultarErroresSolicitud` ejecutadas por LCP `test`.

Evidencias (pantallazos): `docs/sca/pruebas/evidencias/r10d/` (prefijo `sca_` / `sca2_`).

## 1. Resumen

| Bloque | Caso del plan | SCA | SCA2 | Veredicto |
|---|---|---|---|---|
| 1 Plan de pagos | `revision-autorizacion` manual_test_2-14 «Finalizar con plan de pagos» (aviso/bloqueo) | No existe lógica de plan de pagos en Mecanización ni Autorización (código leído por LCP). UI: Alta OK con «Plan de pago P1024692P25» y ventana del plan; la Contra Anulación no se registró en CORE (latencia TEST) | Igual que SCA en código (sólo informativo en cabecera). UI: Alta → CA negativa → Mecanización NSE-Autos → «ANULAR PÓLIZA» sin ningún aviso de plan de pagos; `CORRECTO / Los datos se han guardado correctamente / La anulación se ha lanzado al sistema de emisión.` | **Pendiente de decisión** (no implementado en SCA TEST; SCA2 = SCA). No probado el botón FINALIZAR de Autorización: la solicitud SCA2 no pasó por Autorización (NSE la anuló directamente) |
| 1 Plan de pagos | Cabecera «Plan de pago» + ventana «Plan de pagos» (`*_DatosPoliza`, `*_ModalPlanPago`) | P1024692P25 · N.º pólizas 1 · 0 € · MENSUAL · 01/04/2025 · día 5 · DOMICILIACIÓN EN TARJETA · TARJETA DE COBRO · ACEPTAR | M071059P23 · 4 · 2229.38 € · MENSUAL · 26/07/2023 · día 22 · DOMICILIACIÓN BANCARIA · IBAN · ACEPTAR (valores de otra póliza) | **OK** (mismos campos, mismo botón; SAIL idéntico salvo prefijos) |
| 2 AA venta CON traspaso | `acciones-administrativas` validación de documentos / adjuntar / finalizar | Alta 15787992 OK; GUARDAR de Contra Anulación «Aún procesando» → sólo gestión 8 en CORE. **No probado** más allá del Alta | 15787986: AA con «Documento compra/venta» (tipo 1) + «Dni» (tipo 7) entregados → FINALIZAR muestra «¿Desea continuar? Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento». CORE conserva **tipo 1 y tipo 7**; Detalle los muestra como «Justificante compra» + «Dni» | **OK** respecto a SCA: el aviso y la etiqueta «Justificante compra» son literalmente el mismo código en SCA (ver §3.2). El documento CON traspaso **no se pierde** |
| 2 AA venta SIN traspaso | ídem | Alta 15787996 OK; misma latencia; sólo gestión 8 en CORE. **No probado** | 15787998: AA con «Documento compra/venta sin traspaso del seguro» (tipo 9) + «Dni» entregados → FINALIZAR con confirmación normal («Se va a finalizar la revisión de acciones administrativas»). CORE conserva **sólo tipo 7**; Detalle (SCA2 y consulta cruzada desde SCA) sólo «Dni». Bandeja de errores SCA2: **sin registros** para la solicitud | **Pendiente (PADRE)**: el tipo 9 se pierde entre la pantalla de AA y CORE; objetos `SCA2_subirDocumentosGD` / `SCA2_calcularDocumentosASubir` reservados por el PADRE (§3.3). Reproducido con caso nuevo como pedía el PADRE |
| 3 NSE caso nuevo pendiente de autorizar | `pruebas-de-mecanizacion` NSE autorización | No alcanzado (latencia en CA) | 15787998: Mecanización NSE «Nivel cumplimiento PENDIENTE DE AUTORIZAR», reserva de prima Sí, importe −406.77, controles «Anulación con reserva de prima. La operación requiere autorización del Departamento Técnico - [AUDITORÍA]» y «Por tratarse de una anulación a la fecha, la operación se debe revisar desde la Subcentral - [AUDITORÍA]»; ANULAR PÓLIZA → petición de autorización iniciada → CORRECTO. CORE: gestión 5 INCOMPLETA con «Llamada a Suscripcion NSE…». Detalle: «Mecanizacion Incompleta» | **OK** (misma secuencia que los históricos del analista). Queda pendiente de que alguien autorice en NSE (analista) |
| 3 Histórico 15787950 (rechazo NSE) | Consulta/Detalle/gestiones | Tarjeta Autorización **«Rechazada»** (rojo), gestión APP-PCAE 14/10/2026 12:13:30, observación «Actualizacion desde NSE»; listado «Finalizada no requerida contraanulación» | Tarjeta **«Autorizacion Rechazada»** (rojo), misma gestión; listado «Solicitud Finalizada sin anular» | **OK** (Detalle corregido por el PADRE en v54; etiquetas del listado = HU3980, intencionadas) |
| 3 Histórico 15787945 (autorizado en NSE según el analista) | ídem | Alta/AA Finalizadas, Mecanización Incompleta NSE-Autos, **sin tarjeta Autorización**; «Finalizada no requerida contraanulación» | Igual; «Solicitud Finalizada sin anular» | **OK entre SCA y SCA2**; hallazgo externo: CORE no tiene gestión 7 ni cambio de estado → la autorización de NSE no ha llegado a CORE (§5) |

Totales: **OK 5** · divergencias corregidas **0** · pendientes de decisión **1** (plan de pagos) + **1** reservado al PADRE (tipo 9) · **no probados 3** (los tres recorridos de SCA más allá del Alta, por latencia de Appian TEST).

Solicitudes creadas y pólizas consumidas (6 de las 40):

| Caso | SCA | SCA2 |
|---|---|---|
| Plan de pagos (causa «Decisión de cliente / precio / Me ha subido mucho la prima», obs. «R10-D plan de pagos») | 2002500188047 → **15787978** | 2002400061669 → **15787977** |
| AA venta CON traspaso (causa 14 «Venta del vehículo / No voy a comprarme otro coche», obs. «R10-D AA venta CON traspaso») | 2002400046024 → **15787992** | 2002400319124 → **15787986** |
| AA venta SIN traspaso (ídem, obs. «R10-D AA venta SIN traspaso») | 2002400324926 → **15787996** | 2002500065932 → **15787998** |

Descartada: 0731600003780 (sin plan de pagos en GESYCORE). Sin consumir: las 33 restantes de la sección.

## 2. Bloque 1 — Plan de pagos

### 2.1 Qué hacen SCA y SCA2 con el plan de pagos (código, LCP)

Búsqueda en todos los objetos `SCA_*` / `SCA2_*` (interfaces y reglas) de `PlanPago`, `planPago`, «plan de pago»:

| Objeto | SCA | SCA2 | Uso |
|---|---|---|---|
| `*_consultarPlanPagoPorPoliza` | `_a-0000eb9b-717e-8000-9c54-011c48011c48_12082664` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050942` | Servicio GESYCORE `consultarPlanPagoPorPoliza`; misma expresión |
| `*_obtenerDatosCabecera` | | | `datosPoliza.planPago` = `idnplanpago` (p. ej. `P1024692P25`) |
| `*_DatosPoliza` (cabecera «Datos póliza») | | | «Plan de pago: <id>» + enlace (`cons!*_PLANPAGO_URL`) que abre la ventana |
| `*_ModalPlanPago` | `_a-0000ec31-13b0-8000-9c78-011c48011c48_14024890` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053035` | Ventana «Plan de pagos / Detalle del plan de pagos»: N. de pólizas, Importe, Periodicidad, Fecha Inicio, Plan de pago, Día de cobro, Cobro, Detalle de cobro, ACEPTAR. Diferencia: sólo prefijos (16 líneas) |
| Mecanización / Autorización (`SCA_DetalleAnulacionMecanizacion`, `SCA_DetalleAnulacionAutorizacion`, `SCA_ContraAnulacionDetalleAnulacionPoliza`, `SCA2_MecanizacionPrincipal`, `SCA2_DetalleSolicitud`, `SCA2_PopUpMensajeAutorizacion`…) | sin referencias | sin referencias | **Ninguna de las dos aplicaciones avisa ni bloquea por plan de pagos** |

Conclusión: manual_test_2-14 («el sistema advierte que no es posible seguir adelante mientras la póliza esté dentro de un plan de pagos») **no está implementado en SCA TEST**; SCA2 se comporta igual. Sigue como pendiente de decisión (abierto en `22-dudas-funcionales-para-el-analista.md`).

Pólizas R10-D comprobadas con `*_consultarPlanPagoPorPoliza` (misma respuesta en SCA y SCA2):

| Póliza | `idnplanpago` |
|---|---|
| 2002500188047 | P1024692P25 |
| 0731600003780 | **sin plan** → descartada |
| 2002400061669 | M071059P23 |
| 0730580045025 | P054378P18 |
| 2002400046024 | P866798P24 |
| 2002400319124 | P914104P24 |

### 2.2 UI

- Cabecera y ventana del plan: `sca_b1_alta_cabecera_plan.png`, `sca2_b1_alta_cabecera_plan.png`, `sca_b1_modal_plan.png`, `sca2_b1_modal_plan.png` (tabla de valores en §1).
- SCA 15787978: tras GUARDAR en Contra Anulación la pantalla quedó en «Aún procesando» (consola Appian: `Could not apply update, cIds not found`); Detalle sólo «Alta Solicitud / Finalizada» (`sca_b1_detalle_solo_alta.png`); CORE: sólo gestión 8. En `/suite/tempo/tasks` no apareció la tarea de Contra Anulación (`sca_tempo_sin_contraanulacion.png`). No se repitió el Alta para no duplicar. Incidencia adicional de SCA: la flecha «volver» de la cabecera da «Ha ocurrido un error» (`sca_datoscabecera`, `a!submitLink` línea 23, «The save target must be … but instead was: 2002500188047») — `sca_b1_error_volver_cabecera.png`.
- SCA2 15787977: Alta → CA negativa (hubo que imprimir la plantilla de carta) → Mecanización NSE-Autos (fecha anulación 01/02/2027, nivel INFORMATIVO, `sca2_b1_mecanizacion_nse.png`) → ANULAR PÓLIZA → `CORRECTO…` sin aviso de plan (`sca2_b1_resultado_anular_sin_aviso_plan.png`). CORE: gestiones 8 FINALIZADA · 2 FINALIZADA NEGATIVA · 4 FINALIZADA · **5 ANULACION REALIZADA** · 2 INCOMPLETA (nivel 2); codEstSolicitud 2; buscador «Póliza Anulada. Solicitud Pendiente Nivel 2»; observaciones «RESPUESTA ANULACION NSE [Num Suplemento: 4]».

## 3. Bloque 2 — Acción Administrativa de venta con documentos

### 3.1 Qué queda en CORE (`SCA2_consultarDocumentos`)

| Solicitud | App | Causa | Documentos adjuntados y marcados entregados en la pantalla de AA | Documentos en CORE | Bandeja de errores SCA2 (`SCA2_consultarErroresSolicitud`) |
|---|---|---|---|---|---|
| 15787986 | SCA2 | 14 NO VOY A COMPRARME OTRO COCHE | Dni (7) + **Documento compra/venta (1)** | **1** (0900ab4481a0a479) + **7** (0900ab4481a0a40d) | vacía |
| 15787998 | SCA2 | 14 | Dni (7) + **Documento compra/venta sin traspaso del seguro (9)** | **sólo 7** (0900ab4481a0a838) | vacía |
| 15787945 (analista) | SCA2 | 14 | (histórico) | sólo 7 | vacía |
| 15787966 (analista) | SCA2 | 14 | (histórico, «sin traspaso») | sólo 7 | vacía |
| 15787950 (analista) | SCA2 | 16 BAJA VEHICULO | (histórico) | 3 + 7 | vacía |
| 15787992 / 15787996 | SCA | 14 | no se llegó a la AA (latencia) | — | — |

Lo que se pierde es **exclusivamente el tipo 9** («Documento compra/venta sin traspaso del seguro»); el tipo 1 (con traspaso), el 3 y el 7 sí llegan a CORE. Con tipo 9 el proceso no deja ningún error en la bandeja de SCA2 (la pantalla `/suite/sites/sca2/page/errores` no es visible para JJGONZ2 — «La página no existe o no tiene permiso para verla», `sca2_bandeja_errores_sin_permiso.png` — por eso se consultó el record `SCA2 Error` por LCP). En la gestión 3 de CORE (`consultaDetalleGestion`) el `listadoDocumentos` propio de CORE (5 CONTRATO COMPRA/VENTA PUBLICO O PRIVADO, 6 JUSTIFICANTE DE GESTORIA…, 9 y 10 NO ENTREGA DOCUMENTACIÓN) queda con `fecEntrega` null y `mcaDocCliente` false en los dos casos nuevos y en los históricos.

Pantallazos: `sca2_venta_con_documentos_entregados.png`, `sca2_venta_con_detalle_documentos.png`, `sca2_venta_sin_documentos_entregados.png`, `sca2_venta_sin_detalle_solo_dni.png`, `sca_consulta_cruzada_15787998_solo_dni.png` (la consulta de 15787998 desde SCA también muestra sólo Dni: SCA lee los mismos documentos de CORE).

### 3.2 Comportamientos de SCA2 que coinciden literalmente con SCA (no son divergencias)

- Aviso al FINALIZAR con tipo 1 adjunto: `SCA_AccionesAdministrativasPrincipal` (línea 732) y `SCA2_AccionesAdministrativasPrincipal` (línea 342) tienen el mismo `confirmMessage`: si la causa es «NO VOY A COMPRARME OTRO COCHE» o «SEGURO REGALADO POR LA COMPRA DE COCHE» y **no hay tipo 9** adjunto → «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento». Es decir, para esas causas sólo el documento «sin traspaso» (tipo 9) cuenta como contrato; con el tipo 1 ambas apps avisan de anulación a vencimiento.
- Etiqueta «Justificante compra» para el tipo 1 en el Detalle: igual en `SCA_DetalleAccionesAdministrativas` (línea 202) y `SCA2_DetalleSolicitud` (línea 1025).
- Lista de documentos de la pantalla de AA para la causa 14: «Documento compra/venta», «Documento compra/venta sin traspaso del seguro», «Justificante gestoría», «Dni» (igual que `h5-plan-acciones-administrativas.md`).

### 3.3 Causa probable de la pérdida del tipo 9 (para el PADRE; objetos reservados, no tocados)

Según `h5-plan-acciones-administrativas.md` (reserva H5 de la ronda 8), `SCA2_subirDocumentosGD` se igualó en v6 a `SCA_calcularDocumentosASubir`: «sólo se suben al SGD y se registran en BBDD CORE los tipos previstos por acción (ACCADM 1,2,3,4,5,7…)», porque CORE rechazaba el tipo 9. El PADRE confirma que `SCA_calcularDocumentosASubir` y `SCA2_calcularDocumentosASubir` son idénticas. Por tanto el tipo 9 no llega a CORE **por diseño heredado de SCA**, sin error en bandeja. Lo que falta por confirmar es si SCA, en TEST, deja el tipo 9 en Documentum aunque no en CORE (en esta ronda no se pudo completar una AA en SCA).

## 4. Bloque 3 — Autorización / rechazo por NSE

### 4.1 Históricos (sólo consulta)

| Solicitud | CORE (`consultaGestion` / `consultarDetalleSolicitud`) | `consultarAutorizacion` | SCA (UI) | SCA2 (UI) |
|---|---|---|---|---|
| 15787945 · 2002100194827 · causa 14 · codEstSolicitud 5 | 8 FINALIZADA · 3 FINALIZADA · 5 INCOMPLETA («RESPUESTA SUSCRIPCION NSE: Num Solicitud Anulacion 2002642G0000066»). **Sin gestión 7** | null | Alta/AA Finalizada, Mecanización Incompleta NSE-Autos (11:23:57–11:27:36), sin tarjeta Autorización; listado «Finalizada no requerida contraanulación» (`sca_historico_15787945_mecanizacion.png`) | Igual; listado «Solicitud Finalizada sin anular» (`sca2_historico_15787945_estado_mecanizacion.png`) |
| 15787950 · 2002300361333 · causa 16 · codEstSolicitud 5 | 8 · 3 · 5 INCOMPLETA (NSE 2002642G0000067) · **7 «AUTORIZACION RECHAZADA»** APP-PCAE 12:13:30 «Actualizacion desde NSE» | gestión 7: `codEstado` **null**, `mcaAutorizada` N | Tarjeta Autorización «Rechazada» (rojo), APP-PCAE 14/10/2026 12:13:30; documentos Autorización + Dni (`sca_historico_15787950_autorizacion_app_pcae.png`) | «Autorizacion Rechazada» (rojo), misma gestión (`sca2_historico_15787950_autorizacion_app_pcae.png`) |

Estado del listado calculado con las gestiones reales de CORE (LCP):

| Solicitud | `SCA_calcularEstadoSolicitud` | `SCA2_calcularEstadoSolicitud` v2 (HU3980, PADRE) |
|---|---|---|
| 15787945 | Solicitud Pendiente | Solicitud Pendiente |
| 15787950 | Solicitud Pendiente | **Solicitud Finalizada. Rechazada anulación** |
| 15787966 | Solicitud Pendiente | Solicitud Pendiente |

La diferencia en 15787950 es deliberada (HU3980): SCA no interpreta la gestión 7 «AUTORIZACION RECHAZADA» en el listado. En el Detalle, SCA (`SCA_DetalleAnulacionAutorizacion`) toma el estado de `consultarAutorizacion.codEstado`, que en este rechazo viene vacío; el PADRE corrigió `SCA2_DetalleSolicitud` (v54) para usar `codEstGestion` de la gestión 7. Otra diferencia observada: SCA2 tiene pestaña «Notificaciones» en la consulta y SCA no.

### 4.2 Caso nuevo pendiente de autorización en NSE

- SCA2 15787998 (2002500065932): ver §1 y §3. CORE: codEstSolicitud 5; gestión 5 INCOMPLETA con «Consulta NEW… nvlCumplimiento: 00000005… Llamada a Suscripcion NSE – rol NSE_EMISOR_P8 – idSolicitudExt 15787998». Pantallazos `sca2_venta_sin_nse_pendiente_autorizar.png`, `sca2_venta_sin_resultado_emision.png`. Quién autoriza en NSE: analista (no simulado).
- SCA: no se pudo crear (los tres recorridos de SCA se quedaron en el Alta).

## 5. Objetos Appian modificados por R10-D

**Ninguno.** No se ha encontrado ninguna divergencia propia de SCA2 fuera de los objetos reservados por el PADRE: el aviso y las etiquetas de la AA son idénticos a SCA, el plan de pagos es sólo informativo en ambas, y la tarjeta de Autorización ya la corrigió el PADRE (v54). No se han hecho reservas.

## 6. Hallazgos externos (CORE / NSE / Emisión / Documentum / TEST)

1. **NSE → CORE (15787945):** el analista autorizó en NSE, pero CORE no tiene gestión 7 ni cambio de estado (sigue 5 INCOMPLETA). Ni SCA ni SCA2 pueden mostrar una autorización que no ha llegado a CORE. Hay que revisar el canal de respuesta NSE → CORE (APP-PCAE) para la autorización positiva (el rechazo de 15787950 sí llegó).
2. **CORE `consultarAutorizacion`:** en el rechazo recibido de NSE devuelve `codEstado` vacío; el estado sólo se deduce de `codEstGestion` de la gestión 7.
3. **Documentos tipo 9:** no se registran en CORE en ninguna app (diseño heredado de SCA, §3.3); sin error en bandeja. Pendiente de confirmar qué hace Documentum en SCA.
4. **Appian TEST – SCA:** el GUARDAR de la Contra Anulación se queda «Aún procesando» (consola `Could not apply update, cIds not found`) y la gestión 2 no llega a CORE; tampoco aparece la tarea en Tempo. Mismo síntoma que en la ronda 9 (latencia). Además, la flecha «volver» de la cabecera de SCA da error de evaluación (`sca_datoscabecera`, `a!submitLink` línea 23). Son incidencias de SCA/TEST, no de SCA2.
5. **Permisos:** la bandeja de errores de SCA2 no es visible para el perfil Oficina (JJGONZ2); se ha consultado por LCP.

## 7. Preguntas para el analista (lenguaje funcional)

1. **Plan de pagos:** hoy ni SCA ni SCA2 avisan ni bloquean nada cuando la póliza está en un plan de pagos; sólo se muestra el identificador del plan en la cabecera y una ventana con su detalle. El caso del plan dice que al finalizar la autorización debería avisar de que hay que sacar la póliza del plan. ¿Se quiere ese aviso/bloqueo (y en qué pantalla: mecanización, autorización o ambas)? ¿Debe ser bloqueo o sólo aviso?
2. **Documento de venta sin traspaso:** cuando la oficina adjunta el «Documento compra/venta sin traspaso del seguro», ese documento no queda registrado en CORE (sólo el DNI), igual que en SCA. ¿Debe conservarse en CORE/gestor documental como el resto? ¿Debe la pantalla avisar a la oficina de que ese documento no se guarda?
3. **Aviso de anulación a vencimiento:** con el contrato de compraventa «con traspaso» adjunto, las dos aplicaciones avisan «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento», porque sólo el documento «sin traspaso» cuenta como documentación completa. ¿Es correcto que el contrato con traspaso no evite ese aviso?
4. **Autorización NSE que no llega:** la anulación 15787945 se autorizó en NSE pero CORE no ha recibido ninguna respuesta, por eso ninguna de las dos aplicaciones la muestra autorizada. ¿Quién revisa en NSE/CORE el envío de la respuesta positiva? Mientras tanto, ¿qué debe mostrar SCA2 (hoy: «Mecanización Incompleta» y «Solicitud Finalizada sin anular»)?
5. **Etiquetas del listado:** para una solicitud rechazada por NSE, SCA muestra «Finalizada no requerida contraanulación» y SCA2 «Solicitud Finalizada. Rechazada anulación» (HU3980). ¿Confirmas que el texto nuevo es el deseado?
