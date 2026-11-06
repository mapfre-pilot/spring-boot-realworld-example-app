# R45-B — ANL / mecanización: pendiente de autorizar, fecha de suplemento, Acc. Adm. a vencimiento y «Cancelada»

Entorno: Appian TEST, aplicación SCA2, usuario funcional JJGONZ2. Fecha: 06/11/2026. Solo se han modificado objetos SCA2.

## Resumen ejecutivo

| Punto | Resultado |
|---|---|
| B2a `fechaSuplemento` | **OK en ambas rutas en cuanto a la fecha enviada**. NSE-Autos verificado con 15788805. wAutemis (15788817 de R45-C, solo lectura): `<fechaSuplemento>2028-08-21</fechaSuplemento>` = fecha de anulación/vencimiento de la simulación, en formato ISO correcto. NEW rechaza la operación con «M218 … 916-.La Fecha de Efecto no puede ser mayor o menor en 18 meses que la Fecha de Mecanización» (regla externa NEW/GAIA; la póliza vence a ~21 meses). Duda D5. **Fase 3 (B2a-3 cerrado de principio a fin)**: solicitud nueva 15788828 (wAutemis, vence a ~15 meses). Integración 13638 `registrarOpeAnulPolizaEnCentral` con `<fechaSuplemento>2028-02-10</fechaSuplemento>`, igual que FECHA_ANULACION de ANL 2397. NEW responde HTTP 200 `resultadoOperacion` true. |
| B2b nivel 4/5 → pendiente de autorizar | **KO / no concluyente (fase 3)**. Cribado de 45 pólizas del bloque R45-B2 en Designer (PROBAR REGLA, sin guardar). Solo 3 wAutemis dan `nvlCumplimiento` 00000005 («La Norma 58 deja pendiente esta operación…»), y **solo con fecha de efecto cercana a hoy**. Las 42 NSE devuelven el error 4021 y no traen controles técnicos. Solicitud nueva **15788828** (wAutemis 0002729356790, A VENCIMIENTO 10/02/2028): en la pantalla de mecanización el nivel sale vacío, NEW acepta la anulación (`resultadoOperacion` true) y CORE queda en **solicitud 4 «Pendiente de Autorización» + mecanización 5 INCOMPLETA**. No sale ni 4/5 + 2 ni 4/5 + 7. Dudas D7 y D8. |
| B1 Acc. Adm. sin documentación | **OK en CORE** (15788805: anulación a vencimiento 03/03/2027, mecanización ANULACIÓN REALIZADA, solicitud 5). **Observación UI**: lista «Solicitud Finalizada sin anular» y tarjeta «Mecanización incompleta» no coinciden con CORE (objetos de R45-D). |
| B4 NO en Anulación/Suscripción | **KO para «solicitud 14»; mecanización 4 OK**. Fase 2: se reutilizó `SCA2_finalizarContraAnulPca` (`mcaEstadoFinal` 9, el servicio que deja la 15788807 en 14) en la rama CANCELADA. Con dos solicitudes nuevas (15788821, 15788826) CORE responde `true` pero **no** pasa la solicitud a 14 (queda 2 y después 5): ese servicio solo cancela si hay una gestión de contra anulación abierta. No hay otro servicio reutilizable para este camino → cambio de fase 2 **revertido** (contenido v4/v15 con `versionUuid` nuevos). Ver §B4 fase 2. |
| B3 (análisis) | Hecho: la espera NSE es necesaria en anulaciones directas (NSE tarda segundos-minutos); la cancelación no espera. Ver §B3. |

## Resultados

ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución
---|---|---|---|---|---|---|---|---
B2a-1 | Regla traducida con solicitud del analista (lectura) | `datosSolicitud.fecAnulacion` = fecha simulación 26/04/2027 | Antes 04/11/2026 (fecha alta), después 26/04/2027 | OK | 15788768 (solo lectura, prueba de regla) | — | Designer → PROBAR REGLA antes/después (`r45-b-02`, `r45-b-01`) | Origen: `SCA2_RecordToCdtSolicitudAnulacion` usa `fecanulacion` del record (fecha de alta). Corregido sobrescribiendo con CORE `fecAnulacion`.
B2a-2 | `FECHA_SUPLEMENTO` ANL en solicitud nueva NSE-Autos | = fecha de anulación de la simulación (03/03/2027) | ANL Anulacion ID 2394: FECHA_ANULACION 03/03/2027, FECHA_SUPLEMENTO 03/03/2027, suplemento 7, gestión 43708008 | OK | 15788805 | Finalizar 9171261 | Alta póliza 2002100087562 → AA sin doc → simulación 03/03/2027 → ANULAR PÓLIZA → traza NSE y tabla ANL (`r45-b-08`, `r45-b-09`) | — 
B2a-3 | Ruta wAutemis `ANULAR NEW` | `<fechaSuplemento>` = fecha simulación | Integración 13631 (06/11 12:24) `registrarOpeAnulPolizaEnCentral` con `<fechaSuplemento>2028-08-21</fechaSuplemento>` (= FECHA_ANULACION = FECHA_VENCIMIENTO 21/08/2028, ANL Anulacion 2395). Respuesta NEW HTTP 500, código 4004 «M218 No se ha podido inicializar el suplemento. 916-.La Fecha de Efecto no puede ser mayor o menor en 18 meses que la Fecha de Mecanización de la Operación» → tarea «ANL Gestionar Error Integración Anulacion #2395» | OK (fecha); KO externo (NEW) | 15788817 (R45-C, solo lectura) | ANL #2395 | `ANL_getAnulacionByFilter_qr` y `ANL_getIntegracionesByIdAnulacion` (PROBAR REGLA, sin guardar); Monitorización (variables de la tarea de error, sin completarla) | La fecha la pone el cambio B2a (antes iría la fecha de hoy y la validación de 18 meses no saltaría). Formato correcto. Precedente: con la 15788768 del analista (fecha de hoy, 04/11) NEW dio otro error («M519 Norma 58: debe ser revisada por la subcentral»). Hay tareas de error ANL desde el 30/10 (#2317, #2318, #2322). Decisión funcional → D5.
B2a-4 | Ruta wAutemis `ANULAR NEW` con solicitud nueva y vencimiento a menos de 18 meses (fase 3) | `<fechaSuplemento>` = fecha de anulación de la simulación y NEW sin error 916 | Integración 13638 (06/11 13:40, ANL 2397): `<fechaSuplemento>2028-02-10</fechaSuplemento>`, igual que FECHA_ANULACION y FECHA_SUPLEMENTO de ANL (10/02/2028). Respuesta HTTP 200 `<resultadoOperacion>true</resultadoOperacion>`. Observación CORE 13639 «ANULAR NEW: … fechaSuplemento2028-02-10+00:00 … nivelCumplimiento: » y 13640 «RESPUESTA ANULAR NEW: resultadoOperacion: true». Una consulta NEW posterior responde «La póliza ya está anulada» | OK | 15788828 | ANL 2397 | `ANL_getAnulacionByFilter_qr` / `ANL_getIntegracionesByIdAnulacion` (PROBAR REGLA, cabecera SOAP redactada) | —
B2b-1 | Cribado de nivel 4/5 o controles 05/06 en el bloque R45-B2 (fase 3) | Pólizas que den 00000004/00000005 o 05/06 | 45 pólizas probadas con una expresión temporal en `SCA2_pBuscarPoliza` (PROBAR REGLA, sin guardar). Para wAutemis se usó `SCA2_consultarNewAlta` → `nvlCumplimiento`; para NSE, `SCA2_simularAnulacionAltaNse` → `listaControlTecnico.tipoError`. **3 wAutemis dan 00000005** (0002729356790 vto 10/02/2028, 0002729372785 vto 16/05/2028, 0002729381955 vto 29/06/2029), con la fecha de efecto en hoy+1. **42 NSE** (1 en 000…, 5 en 873…, 21 en 200…, 15 en 073…) dan el fault 4021 «Se produjo un error no controlado al validar los datos de la anulación», sin `listaControlTecnico` | Parcial (wAutemis) / no concluyente (NSE) | — | — | Ver §Fase 3 | En NSE el 4021 aparece en todas las pólizas; puede venir de los códigos de motivo usados en la prueba o de NSE TEST. No se puede deducir 05/06.
B2b-2 | wAutemis con nivel 00000005 → «ANULACIÓN PENDIENTE DE AUTORIZAR» | Solicitud 4/5 + mecanización 2 (o 7) | Alta A VENCIMIENTO 10/02/2028. En la pantalla «Detalle consulta New», con la fecha de vencimiento, **el nivel de cumplimiento sale vacío** y el mensaje informativo es «-». La rama «¿wAutemis pdte. aceptar?» de `SCA2 CMD Mecanizar` necesita observaciones 00000005/06, así que no se activa y la anulación sigue el camino normal: ANL 2397 (TIPO_FLUJO 3 «Anulación New», REDIRIGIR_NEW true) → NEW true. CORE: **estadoSolicitud 4** (fecEstado 13:40:48) y **gestión 5 INCOMPLETA** (43708074, 13:37:42–13:40:48). La pantalla muestra «Pendiente de Autorización» y la tarjeta «Incompleta». A las 14:01 no ha cambiado nada | KO (no sale 4/5 + 2) | **15788828** | ANL Alta y ANL Aceptar 13:40–13:41 (completados); ANL 2397 CONCLUIDA=false | Alta → contra anulación negativa (MADRID CORREDORES NORTE II, COMPROMISOS) → carta → FINALIZAR → SÍ → ANULAR PÓLIZA (`r45-b-21`…`r45-b-25`) | El nivel 5 de NEW (Norma 58) depende de la fecha de efecto: con hoy+1 sale 00000005; con la fecha de vencimiento, vacío. No se cambia nada (D7). Falta saber quién deja CORE en 4 + INCOMPLETA (D8).
B1-1 | AA «El cliente no entrega documentación» | Confirmación «se anulará al vencimiento» y anulación a vencimiento | Modal mostrado; simulación y CORE 03/03/2027 (= vencimiento), catalogación A VENCIMIENTO en detalle, sin VERTI, mecanización ANULACIÓN REALIZADA, solicitud 5 | OK | 15788805 | Finalizar 9171261 | Alta A FECHA 06/11/2026 → AA VILLALBA → check sin doc → FINALIZAR → ACEPTAR (`r45-b-03`…`r45-b-07`) | —
B1-2 | Etiqueta lista/tarjeta coherente con CORE | «Finalizada. Anulación realizada» | Lista «Solicitud Finalizada sin anular»; tarjeta gestión «Mecanización incompleta» | KO (UI) | 15788805 | — | Lista «Otras sol.» y detalle | No es carrera NSE (Finalizar esperó 2 ciclos y vio ANULACIÓN REALIZADA). Objetos de R45-D (`SCA2_calcularEstadoSolicitud`, `SCA2_DetalleSolicitud`): comunicado en coordinación, no tocado.
B4-1 | NO en Anulación/Suscripción (antes del cambio) | Solicitud 14, mecanización 4, «Cancelada» | Solicitud 5, mecanización INCOMPLETA (43708029), lista «Pendiente de Autorización» | KO | 15788811 | — | Póliza 2002100092136, AA sin doc, simulación 03/03/2027 → CANCELAR (`r45-b-11`, `r45-b-12`) | `SCA2 CMD CompletarAccion` → `SCA2 CMD Finalizar` (estadoFinal CANCELADA) nunca llamaba a `actualizarMecanizacion` con 4 (SCA: `SCA_Finalizar_Mecanización`, `codEstMecanizacion = if(cancel,"4",…)`).
B4-2 | NO en Anulación/Suscripción (después del cambio) | Solicitud 14, mecanización 4, «Cancelada», no «Mecanización incompleta» | Gestión 5 (43708034) **CERRADA SIN MECANIZAR** 11:58:40–12:01:10; cabecera `estadoSolicitud` **5**, `mcaMecanizada` N, `codCausa` 14, fecAnulacion 01/05/2027; lista «Solicitud Finalizada. Rechazada anulación» | Mecanización OK / Solicitud 14 KO | 15788815 | Finalizar arrancada por CompletarAccion a las 12:01:05 | Póliza 2002400195593 → alta A FECHA → AA VILLALBA sin doc → «¿Desea anular la póliza…?» (01/05/2027 INFORMATIVO) → CANCELAR (= NO) → CORRECTO (`r45-b-13`…`r45-b-18`) | `finalizarSolicitud` de CORE (sin campo de estado) deja 5. El único servicio visto que deja 14 es `finalizarContraAnulPca` con `mcaEstadoFinal` 9 (contra-anulación, 15788807 de R45-D). SCA también termina en «SCA Finalizar Solicitud» tras cancelar, por lo que SCA daría 5+4. Duda D1.
B3-1 | Espera NSE en `SCA2 CMD Finalizar` | Saber si hace falta | 15788805: NSE respondió 10 s después de la llamada (11:12:48 → 11:12:58); Finalizar esperó 2 ciclos de 1 min y encontró suplemento 7 | Análisis | 15788805, 15788815 | 9171261 | Variables de la instancia (`r45-b-10`) y gestiones CORE | Ver §B3.
B4-3 | Fase 2: NO en Anulación/Suscripción con `finalizarContraAnulPca` 9 | Solicitud 14, mecanización 4, «Cancelada» | CORE 5, `mcaMecanizada` N, gestiones 8 FINALIZADA, 3 FINALIZADA, 5 CERRADA SIN MECANIZAR; lista «Solicitud Finalizada. Rechazada anulación» | KO | 15788821 (2002500441389) | `SCA2 CMD Finalizar` (fase 2) | Alta → AA sin documentación → simulación INFORMATIVO → CANCELAR | `finalizarContraAnulPca` responde `true` sin efecto en el estado; `finalizarSolicitud` deja 5.
B4-4 | Fase 2b: además se consulta CORE tras `finalizarContraAnulPca` y solo se omite `finalizarSolicitud` si CORE confirma 14 | Solicitud 14, mecanización 4, «Cancelada», no «Mecanización incompleta» | `mecNseRes` = {cancelada=false, estadoCoreCa=2, caResult=respuesta true, estadoMecanizacion=INCOMPLETA}; después `finalizarSolicitud` → CORE 5 (fecEstado 12:48:04), `mcaMecanizada` N; gestiones 8 FINALIZADA 12:45:16, 3 FINALIZADA 12:45:26–12:46:43, 5 CERRADA SIN MECANIZAR 12:46:46–12:48:02 (43708065/66/67); lista «Solicitud Finalizada. Rechazada anulació…» (`r45-b-20`) | KO | 15788826 (2002100314607, TERCEROS MOTOS, vto 01/08/2027) | `SCA2 CMD Finalizar` 12:48 | Alta 06/11 → AA VILLALBA sin documentación → simulación INFORMATIVO sin controles → CANCELAR (NO) | Tras la llamada CORE sigue en 2 (en mecanización): el servicio de contra anulación no cancela una solicitud sin gestión de contra anulación (la 15788807 tenía la acción 2, que quedó FINALIZADA CANCELADA). Revertido.

## Fase 3 — B2b en el bloque R45-B2 (solo pruebas, sin tocar objetos)

- **Método.** Expresión temporal pegada en el editor de `SCA2_pBuscarPoliza`, ejecutada con PROBAR REGLA y cerrada **sin guardar**. Para cada póliza: `SCA2_obtenerTipoPoliza`. Si es wAutemis, `SCA2_consultarNewAlta` (la consulta NEW que usa `SCA2_MecanizacionPrincipal` para `nvlCumplimiento`), con la fecha de efecto en hoy+1. Si es NSE, `SCA2_simularAnulacionAltaNse` → `listaControlTecnico.tipoError`. Se probaron 45 pólizas y se hicieron 6 consultas más para ver cómo influye la fecha: 51 consultas en total, por debajo del límite de 60.
- **wAutemis.** Las 3 wAutemis del bloque dan `nvlCumplimiento` 00000005, «La Norma 58 deja pendiente esta operación: Esta operación debe ser revisada por la subcentral». Solo 0002729356790 vence a menos de 18 meses (10/02/2028). Con la fecha de vencimiento, 0002729372785 (16/05/2028) da el error 916 de 18 meses. Por eso no se hizo una segunda alta: 0002729372785 y 0002729381955 repetirían el caso 15788817 (D5).
- **NSE.** Las 42 pólizas NSE devuelven el fault 4021 y ninguna trae controles técnicos. No hay ningún caso de 05/06.
- **Solicitud 15788828.** El alta (13:32) y la contra anulación negativa terminan bien y la aplicación redirige a la anulación. La pantalla «Detalle consulta New» (13:37) muestra fecha 10/02/2028, **nivel vacío** y el aviso «Las condiciones de anulación de la póliza se han modificado tras confirmar la fecha de anulación». Tras ANULAR PÓLIZA (13:40), ANL 2397 llama a NEW con `fechaSuplemento` 2028-02-10 y NEW responde true. CORE queda en estadoSolicitud **4** y la mecanización (acción 5) en **INCOMPLETA**, las dos a las 13:40:48. No es la combinación buscada (4/5 + 2 o 4/5 + 7).
- **Lectura del código (solo lectura).** `SCA2_MecanizacionPrincipal`: en wAutemis, `local!observaciones` = `nvlCumplimiento` de la consulta NEW hecha con la fecha de anulación. `SCA2 CMD Mecanizar` solo va a «Autorización» («¿wAutemis pdte. aceptar?») cuando las observaciones son 00000005/06. Con la fecha a vencimiento NEW no devuelve nivel, así que la rama de pendiente de autorizar no se activa. Para R45-D no hay caso real de 4/5 + 2 ni de 4/5 + 7.

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

b) **15788754** (solo lectura, sin relanzar ni modificar):
- CORE: solicitud **5** (`fecEstado` 03/11/2026 18:57:01), `mcaMecanizada` N, `catalogacion` 4, `codCausa` 28, `fecAnulacion` 03/11/2026. Gestiones 43707852 FINALIZADA (18:42:57), 43707853 FINALIZADA (18:47:00), **43707854 (mecanización) INCOMPLETA** (18:57:01).
- ANL: Anulacion **2350** (póliza 0001012089910, BASICar TERCEROS AMPLIADO, origen NSE-Autos, vto 21/08/2027), creada 18:47 por «ANL Alta» y «ANL Aceptar» (ambas terminadas en el mismo minuto). `FECHA_SUPLEMENTO` = `FECHA_ANULACION` = 03/11/2026 (fecha del día: anterior al cambio B2a), `TIPO_ANULACION` 3, **`REDIRIGIR_NEW` = true**, **`TIPO_FLUJO` vacío**, `NUMERO_SUPLEMENTO` vacío, `CONCLUIDA` false, último evento tipo 24.
- No hay integraciones ANL registradas para la 2350 (`ANL_getIntegracionesByIdAnulacion` → 0 elementos) ni procesos NSE/ANL posteriores en Monitorización (búsquedas por solicitud, póliza y «Anulacion# 2350»).
- Interpretación: ANL aceptó la anulación pero la marcó para redirigir a NEW sin tipo de flujo, así que no llamó a NSE ni a NEW y la anulación quedó abierta sin suplemento. `SCA2 CMD Finalizar` esperó los 10 ciclos de R44 (18:47 → 18:57) sin respuesta y cerró la mecanización como INCOMPLETA y la solicitud en 5. Es decir, SCA2 hizo lo previsto; el motivo de que no se anulara está en la decisión de ANL (`REDIRIGIR_NEW` con `TIPO_FLUJO` vacío), y ANL no es objeto SCA2. Duda D6: ¿qué debe hacer SCA2 cuando ANL acepta sin lanzar NSE/NEW (avisar, reintentar, dejar pendiente)?

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

15788805 (2002100087562, B1/B2a, Finalizar 9171261), 15788811 (2002100092136, B4 antes), 15788815 (2002400195593, B4 después), 15788821 (2002500441389, B4 fase 2), 15788826 (2002100314607, B4 fase 2b), **15788828** (0002729356790 wAutemis, B2b/B2a-3 fase 3, ANL 2397). Registradas en `polizas/REGISTRO.md`.

## Dudas para el analista

- D1 (B4): para que la solicitud quede en 14 hace falta una llamada de CORE que la cancele; `finalizarSolicitud` no tiene estado y deja 5. ¿Se acepta 5+4 («Rechazada anulación», como haría SCA) o debe usarse otro servicio (¿cuál?) para dejar 14? No se ha inventado.
- D1 (fase 2): con `finalizarContraAnulPca` 9 CORE no cancela una solicitud sin gestión de contra anulación (15788821, 15788826). ¿Qué servicio de CORE debe cancelar (14) desde la mecanización? Hasta entonces queda 5 + 4.
- D5 (B2a wAutemis): NEW rechaza la anulación a vencimiento a más de 18 meses (error 916). ¿Qué `fechaSuplemento` debe ir en ese caso, o SCA2 debe impedirlo?
- D6 (B3b): 15788754 — ANL acepta con `REDIRIGIR_NEW` y `TIPO_FLUJO` vacío y no lanza NSE/NEW; ¿cómo debe tratarlo SCA2?
- D7 (B2b fase 3): NEW solo devuelve 00000005 (Norma 58) cuando la fecha de efecto está cerca de hoy. En una anulación A VENCIMIENTO no devuelve nivel y SCA2 sigue el camino normal. ¿Debe SCA2 consultar el nivel con otra fecha (¿la de hoy?) para ir a pendiente de autorizar, como SCA? No se ha cambiado nada.
- D8 (B2b fase 3): en 15788828 CORE deja solicitud 4 «Pendiente de Autorización» + mecanización INCOMPLETA, aunque NEW respondió true y la póliza aparece anulada en NEW. ¿Qué estado final debe quedar (¿5 + ANULACIÓN REALIZADA?) y quién lo fija? Se sigue en solo lectura; hay que confirmarlo con R45-D (etiquetas) y con el analista.
- D2 (B3a): ¿máximo de espera NSE aceptable (10 min actual)?
- D3 (B3c): elegir opción 1–4 para «Tipo catalogación» wAutemis.
- D4 (B1): etiqueta «Finalizada sin anular» con CORE 5 + ANULACIÓN REALIZADA → revisar con R45-D.

## Limitaciones y pendientes

- B2b (fase 3): no se ha conseguido 4/5 + 2 ni 4/5 + 7. Las NSE del bloque R45-B2 dan 4021 en la simulación y las wAutemis solo dan nivel 5 con fecha cercana (D7). Para seguir haría falta un bloque NSE cuya simulación no dé 4021, o la decisión D7.
- B2a ruta wAutemis: cerrada con 15788828 (fecha correcta y NEW true). Queda abierto el estado final en CORE (D8).
- SCA real no comparado con solicitud nueva.
- LCP/MCP caídos: cambios por Deployment API y Designer.

## Capturas

`../img/r45-b-01` … `r45-b-10` (B2a/B1), `r45-b-11`, `r45-b-12` (B4 antes), `r45-b-13-b4-despues-acc-adm-sin-doc.png`, `r45-b-14-b4-despues-pantalla-anulacion-no.png`, `r45-b-15-b4-despues-tras-no-correcto.png`, `r45-b-16-b4-despues-lista-15788815.png`, `r45-b-17-b4-despues-core-gestiones-15788815.png`, `r45-b-18-b4-despues-core-cabecera-15788815.png`; fase 3: `r45-b-21-f3-alta-wautemis-0002729356790.png`, `r45-b-22-f3-contra-anulacion-redirige.png`, `r45-b-23-f3-mecanizacion-consulta-new.png`, `r45-b-24-f3-detalle-15788828-pendiente-autorizacion.png`, `r45-b-25-f3-gestion-mecanizacion-incompleta-15788828.png`.
