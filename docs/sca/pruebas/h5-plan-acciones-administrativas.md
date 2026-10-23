# H5 — Plan «Acciones Administrativas» (15 casos) · SCA vs SCA2 en TEST

Ronda 8 (planes de prueba del analista). Sesión H5, 13/10/2026. Plan: `docs/sca/pruebas/planes/acciones-administrativas.md` (hoja `manual_test_2`, 15 casos; la segunda hoja no tiene casos). Coordinación: `docs/sca/pruebas/coordinacion-ronda8.md`.

Usuarios: `JJGONZ2` (Red Mapfre, oficina CE_RM, nivel 1) y `SISANS` (SI24 Experto). Sites: SCA `/suite/sites/sca-site`, SCA2 `/suite/sites/sca2`. Pruebas UI con grabación anotada; comprobación de CORE/BBDD por LCP (`SCA2_consultaGestion`, `SCA2_cargarSolicitud`, `SCA2_consultarCabeceraSolicitud`, `SCA2_consultarDocumentos`, `SCA2_consultarListadoObs`, bandeja `SCA2_BandejaErrores`).

## 1. Resumen

| | Casos |
|---|---|
| OK (igual que SCA o conforme al plan cuando SCA no es comparable) | 8 — 2-1, 2-6, 2-7, 2-8, 2-9, 2-10, 2-11, 2-14 |
| DIVERGENCIA corregida | 2 — 2-13 (catalogación a vencimiento al no entregar documentación), 2-15 (observación al CANCELAR) |
| DIVERGENCIA pendiente | 2 — 2-2 (SISANS ve RETOMAR tras POSPONER; duda B2/B3 del doc 22), 2-12 (POSPONER: igual que SCA en pantalla y CORE, pero el CMD dejaba error por el documento tipo 9 — corregido en `SCA2_subirDocumentosGD`; queda relanzar el error de 15787868, sólo administradores). Además, en 2-13 la pantalla de mecanización de SCA2 sigue mostrando la fecha del alta en vez de la de vencimiento (§4.2.5, objeto de H4) |
| NO PROBADO | 3 — 2-3 (catalogación, sólo origen FDC), 2-4 (póliza Mas Movil), 2-5 (fecha disponibilidad, causa BAJA TEMPORAL/BAJA VEHÍCULO) |

**SCA no comparable en las acciones**: el alta en SCA con 0001047017063 (15787882) tardó >4 min y terminó en «403 Acceso denegado»; CORE sólo registró la gestión 8 (alta) y no decidió la acción siguiente, por lo que no se pudo abrir la pantalla de Acción Administrativa en SCA. Los casos 2-6…2-15 se han validado en SCA2 contra la descripción del plan y contra el SAIL de SCA (`SCA_AccionesAdministrativasPrincipal` v7, `SCA_AccionesAdministrativasDocumentacion` v7, `SCA_AccionesAdministrativasCatalogacion`, `SCA_checkDniObligatorioAndCermProfileAccAdm`, `SCA_mostrarBotonCancelarPosponer`, `SCA_calcularDocumentosASubir`, PM «SCA Subir Docs Documentum BBDD»), que es idéntico a SCA2 salvo en los puntos corregidos. El caso 2-2 sí se comparó en las dos aplicaciones (sólo lectura).

## 2. Solicitudes utilizadas / creadas

| Póliza | App alta | Solicitud | Acción decidida por CORE | Qué se hizo | Estado final (CORE / record SCA2) |
|---|---|---|---|---|---|
| 0001047017036 | SCA2 (ronda 7) | **15787868** (autorizada para H5) | Acción Administrativa, nivel 1, CE_RM | RETOMAR, adjuntar DNI + «compra/venta sin traspaso», visualizar, eliminar/readjuntar, POSPONER, SISANS consulta, RETOMAR, FINALIZAR con documentación | CORE: gestión 3 (AccAdm) `43705372` **FINALIZADA** 13/10 12:21:56, observaciones «Pospuesta prueba H5,Finalizada prueba H5»; `codEstSolic` 2. Record SCA2: sigue `EN_ACCION / PENDIENTE` v4 porque el CMD CompletarAccion falló en «Subir documentos GD» (ver §4.2); sin gestión 5 de mecanización |
| 0001047017063 | SCA | 15787882 | sin decidir (SCA 403 tras >4 min) | Alta | CORE: sólo gestión 8 FINALIZADA 12:26:59 |
| 0001047017066 | SCA2 | 15787884 | Acción Administrativa, nivel 1, CE_RM | Alta → «No entrega documentación» → FINALIZAR (2-13) | CORE: gestión 3 `43705409` FINALIZADA 12:30:04 obs «Sin documentación prueba H5»; gestión 5 (mecanización) `43705410` INCOMPLETA; catalogación **4 (A FECHA) 13/10/2026** en `datosSolicitud` y `fecAnulacion 19/05/2027` en la cabecera (inconsistencia que motiva la corrección). Record: `PDTE_MECANIZAR / MECANIZAR / PENDIENTE` v5 |
| 0005726679775 (RCI) | SCA2 | 15787889 | Acción Administrativa, nivel 1, CE_RM (no saltó de nivel: la AA la decide CORE) | Alta → CANCELAR (2-15) | CORE: gestión 3 `43705419` FINALIZADA 12:35:44, **observaciones null**; record `CANCELADA / FIN / COMPLETADA` v5 |
| 0005726681055 (RCI reserva) | SCA2 | ver §5 (re-test tras la corrección) | | | |

## 3. Casos del plan

Leyenda veredicto: **OK** igual / **DIV✔** divergencia corregida / **DIV✎** divergencia pendiente / **NP** no probado. Evidencia = captura (`~/sca2work/h5-evidencias/`, no se suben al repo) o comprobación LCP.

| Id plan | Nombre | Resultado SCA | Resultado SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| manual_test_2-1 | Acceso mismo usuario | Pantalla AA no alcanzable (403 / sin decisión CORE). Diseño: Detalle → tarea propia → pantalla AA | JJGONZ2: Buscador → Detalle 15787868 → RETOMAR → pantalla AA (cabecera, Documentación, oficina, observaciones, CANCELAR/POSPONER/FINALIZAR). Sin sección Catalogación ni «Fecha disponibilidad vehículo» (correcto: origen no FDC, causa sin baja). Tras POSPONER + RETOMAR conserva DNI y segundo documento, oficina y observación | OK | `h5-c01-sca2-detalle.png`, `h5-c01-c06-sca2-accion-administrativa.png`, `h5-c01bis-sca2-documentos-persistidos.png` |
| manual_test_2-2 | Acceso distinto usuario | SISANS abre 15787868: Detalle de **consulta**, sin RETOMAR ni REASIGNAR | SISANS abre 15787868 (tras el POSPONER de JJGONZ2): Detalle con **RETOMAR visible** (no pulsado), sin REASIGNAR | DIV✎ | `h5-c02-sca-sisans-consulta-sin-retomar.png`, `h5-c02-sca2-sisans-retomar-visible.png`, `h5-c02-sca2-sisans-sin-reasignar.png` |
| manual_test_2-3 | Catalogación (FDC / Red Mapfre) | No hay solicitud de origen FDC en TEST con las pólizas asignadas | Ídem. SAIL `SCA2_AccionesAdministrativasCatalogacion` idéntico a SCA; se renderiza sólo con origen FDC | NP (sin dato FDC) | comparación SAIL |
| manual_test_2-4 | Póliza Mas Movil | Sin póliza Mas Movil asignada | Ídem | NP (sin dato) | — |
| manual_test_2-5 | Validaciones fecha disponibilidad | Requiere causa BAJA TEMPORAL / BAJA VEHÍCULO (campo oculto con otra causa) | Ídem; `showWhen` idéntico a SCA | NP (sin dato) | comparación SAIL |
| manual_test_2-6 | Validaciones documentos | Lista por causa (SAIL idéntico) | Causa «NO VOY A COMPRARME OTRO COCHE»: Documento compra/venta · Documento compra/venta sin traspaso del seguro · Justificante gestoría · DNI. FINALIZAR deshabilitado («Es necesario informar la entrega de algún documento») hasta DNI + otro documento o «no entrega» | OK | `h5-c01-c06-sca2-accion-administrativa.png` |
| manual_test_2-7 | Adjuntar documentos | SAIL idéntico (AÑADIR exige oficina seleccionada; «ojo» deshabilitado hasta que el documento está en el gestor documental) | «+» → fichero → AÑADIR exige oficina («Se requiere un valor»); DNI y segundo documento quedan «Entregado»; FINALIZAR se habilita. El «ojo» sigue deshabilitado hasta POSPONER/FINALIZAR (igual que SCA: `disabled: idDocumento no está en consultaDocumentosGD`) | OK | `h5-c07-sca2-adjuntar-dni.png`, `h5-c07-sca2-oficina-requerida.png`, `h5-c07-sca2-dni-entregado-ojo-inactivo.png`, `h5-c07-sca2-dos-documentos-finalizar-activo.png` |
| manual_test_2-8 | Eliminar documento | SAIL idéntico | Papelera → «El documento seleccionado se eliminará / ¿Confirma la eliminación?» → desaparece y FINALIZAR se deshabilita; readjuntar OK | OK | `h5-c08-sca2-confirmacion-eliminar.png`, `h5-c08-sca2-documento-eliminado.png` |
| manual_test_2-9 | Marcar como entregado sin adjuntar | «Entregado» es un icono de sólo lectura (`a!richTextIcon`), no un check editable: el paso del plan no es ejecutable en SCA TEST | Ídem: no se puede marcar sin adjuntar; FINALIZAR no se habilita | OK (paso no ejecutable en ninguna) | `h5-c09-c10-sca2-entregado-no-editable.png` |
| manual_test_2-10 | DNI obligatorio Red Mapfre | `SCA_checkDniObligatorioAndCermProfileAccAdm` idéntica a SCA2; DNI no marcable sin adjunto | DNI no marcable sin adjunto; FINALIZAR exige DNI + otro documento | OK | `h5-c09-c10-sca2-entregado-no-editable.png`, comparación SAIL |
| manual_test_2-11 | Imprimir | Icono impresora sólo en «Carta firmada» (tipo 6, deshabilitado sin oficina) y «compra/venta sin traspaso» (tipo 9 → plantilla) — SAIL idéntico | Impresora en «compra/venta sin traspaso del seguro» abre el visor de la plantilla | OK | `h5-c11-sca2-plantilla-compra-venta.png` |
| manual_test_2-12 | Posponer | Modal «¿Desea continuar? / Se va a posponer la solicitud de anulación» → «Los datos se han guardado correctamente» → buscador; CORE `codEstSolic 2`, gestión AccAdm INCOMPLETA, observación en CORE (s3 §3.2) | Igual: modal, CORRECTO, buscador; CORE gestión `43705372` INCOMPLETA obs «Pospuesta prueba H5», `consultarListadoObs` «JJGONZ2 13/10/2026 12:18:17 Nivel 1: Pospuesta prueba H5»; record `contadorPosponer 1`, caducidad 20/10/2026; estado «Pendiente» (igual que SCA). SGC: `idGestionSGC 1410065407` en el record. **Pero** el CMD Posponer dejó error DOC_GD_FAIL al registrar el documento tipo 9 en CORE (sólo quedó el DNI) → corregido (§4.1) | DIV✎ (el error del CMD ya corregido; pantalla/CORE iguales) | `h5-c12-sca2-modal-posponer.png`, `h5-c12-sca2-posponer-correcto.png`, `h5-c12-sca2-detalle-pendiente-solo-dni.png` |
| manual_test_2-13 | Finalizar No entrega Docs., Red Mapfre | SCA: `modificarCatalogacion(tipo 2, fechaVencimiento)` y aviso «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» (SAIL) | 15787884: «El cliente no entrega documentación (la póliza se anulará a vencimiento)» habilita FINALIZAR y oculta documentos; modal genérico; CORRECTO «Se va a redirigir a la anulación.»; mecanización con fecha **13/10/2026**; Detalle: catalogación **A FECHA**, fecha anulación 19/05/2027. CORE: catalogación 4. → Corregido en `SCA2_AccionesAdministrativasPrincipal` v21 (§4.1); re-test en §5 | DIV✔ | `h5-c13-sca2-modal-sin-documentacion.png`, `h5-c13-sca2-mecanizacion-fecha.png`, `h5-c13-sca2-detalle-fecha-catalogacion.png` |
| manual_test_2-14 | Finaliza entregando documentación | Advierte, guarda, finaliza la gestión AccAdm y navega a mecanización (s3 #24) | 15787868: modal «Se va a finalizar la revisión de acciones administrativas» → CORRECTO → AA **Finalizada** (12:21:56) en el Detalle; CORE gestión 3 FINALIZADA. No navegó a mecanización ni se creó la gestión 5 porque el CMD CompletarAccion falló al subir el documento tipo 9 (error en bandeja, §4.2) | OK en pantalla/CORE AccAdm; mecanización pendiente de relanzar el CMD (§4.2) | `h5-c14-sca2-modal-finalizar.png`, `h5-c14-sca2-aa-finalizada.png`, `h5-c14-sca2-solicitud-pendiente-aa-finalizada.png` |
| manual_test_2-15 | Cancelar | Modal «Va a proceder a cancelar la solicitud de anulación»; `guardarAccAdm(CANCELADO, observaciones)` (SAIL) | 15787889: modal igual, CORRECTO, buscador «Cancelada»; Detalle «FINALIZADA NO REQUERIDA CONTRAANULACIÓN» (texto CORE `codEstSolic 5`, igual criterio que SCA) y AA Finalizada; **observación «Cancelada prueba H5» no llegó a CORE** (gestión `43705419` obs null) → corregido (§4.1) | DIV✔ (observación); estados iguales | `h5-c15-sca2-modal-cancelar.png`, `h5-c15-sca2-solicitud-cancelada.png`, `h5-c15-sca2-detalle-estado-discrepante.png`, `h5-c15-sca2-aa-observacion-vacia.png` |

## 4. Divergencias

### 4.1 Corregidas (exclusivas de SCA2; procedimiento skill `appian`: GET vivo → backup JSON/SAIL en `~/sca2work/live/` → edición mínima → PUT del objeto completo → re-GET idéntico → `POST …/test` → re-test UI)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_AccionesAdministrativasPrincipal` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | 20 → 21 | Nuevas locales `fechaVencimiento` (cabecera `datosPoliza.fechaVencimiento`), `causaExigeContrato`, `anulaAVencimiento` (= «no entrega documentación» **o** causa «NO VOY A COMPRARME OTRO COCHE»/«SEGURO REGALADO POR LA COMPRA DE COCHE» sin documento tipo 9), `fecAnulacionFinal`, `tipoCatalogacionFinal`. FINALIZAR usa esos valores en `SCA2_modificarCatalogacionCodCiaCntrAnul`, en `guardarAccAdm.fecAnulacion` y en el `tipoCatalogacion` que recibe el CMD; `confirmMessage` «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» cuando la causa exige contrato y no se aporta (como SCA). CANCELAR inserta la observación en CORE (`SCA2_insertarObservaciones`, tipoGestion 3) si está informada. Test LCP de la interfaz con 15787884 y 15787868: render OK |
| `SCA2_subirDocumentosGD` (regla) | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351` | 5 → 6 | Paridad con `SCA_calcularDocumentosASubir`: sólo se suben al SGD y se registran en BBDD CORE los tipos previstos por acción (ACCADM 1,2,3,4,5,7; CA 6,7; AUT 7,8). El resto (p. ej. tipo 9 «compra/venta sin traspaso», que CORE rechaza con «Los datos pasados como parametro no son los esperados») se devuelve como `omitido` con `success=true`. Test LCP: `{999999999_9, 999999998_7}` → tipo 9 omitido OK, tipo 7 inexistente sigue fallando |

No se ha tocado POSPONER (SCA también pasa la catalogación a vencimiento al posponer, pero está abierto como pregunta al analista en s3 §5.4).

### 4.2 Pendientes

1. **2-2 — SISANS ve RETOMAR en SCA2 tras el POSPONER de JJGONZ2.** El PM `SCA2 CMD Posponer` (nodo «Write Posponer») deja la tarea sin asignado y `SCA2_puedeGestionarTarea` v4 permite gestionar una tarea sin asignar de nivel 1 a cualquier usuario. En SCA la tarea pospuesta queda en `deployment.user` y nadie ve RETOMAR (s3 §5.5). Es la zona de dudas B2/B3 del doc 22 (quién puede retomar), por lo que no se corrige. **Pregunta funcional**: tras posponer una Acción Administrativa de nivel 1, ¿debe poder retomarla sólo el gestor que la pospuso (y su oficina), o cualquier usuario de nivel 1 / SI24?
2. **15787868 — CMD CompletarAccion en error** (bandeja `/errores`: comando «SCA2 CMD CompletarAccion», nodo «Subir documentos GD», código DOC_GD_FAIL, «Error registrando documento en BBDD CORE tras 3 intento(s): Los datos pasados como parametro no son los esperados», relanzamiento «Automático»). La causa (tipo 9) está corregida en `SCA2_subirDocumentosGD` v6; falta **Relanzar** la fila desde la bandeja (sólo administradores; JJGONZ2 recibe «La página no existe o no tiene permiso para verla», y por LCP no se pueden arrancar procesos). Al relanzar, la solicitud debería pasar a `PDTE_MECANIZAR` y crearse la gestión 5 como en 15787884. La fila «SCA2 CMD Posponer» del mismo id (relanzamiento «Repetir la acción desde la tarea») queda superada por el FINALIZAR; puede marcarse como resuelta.
3. **15787884 y 15787889 no se corrigen retroactivamente**: 15787884 conserva catalogación 4 (A FECHA) con `fecAnulacion` 19/05/2027 en cabecera y mecanización pendiente con fecha 13/10/2026; 15787889 no tiene la observación «Cancelada prueba H5». Son datos de prueba: no se modifican por LCP.
4. **SCA en TEST**: alta 15787882 terminó en 403 y CORE no decidió la acción; `fecimpresion` de `datosSolicitud` devuelve el texto de la última observación (CORE, igual en SCA).

5. **Pantalla de mecanización SCA2 (`SCA2_MecanizacionPrincipal`, `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481`) muestra la fecha de anulación del alta** (`local!fechaAnul` = `datosCompletosSolicitud.datosSolicitud.fecanulacion`, copia local de SCA2), no la vigente en CORE tras la Acción Administrativa (cabecera `fecAnulacion`, que es la que usa el Detalle y la que usan `SCA_DetalleAnulacionMecanizacion*` en SCA). En 15787898 la pantalla dice 13/10/2026 y CORE/Detalle 24/01/2028; en 15787884 13/10/2026 frente a 19/05/2027. Es objeto del plan de Mecanización (H4): anotado en «Incidencias» de la coordinación, no se ha tocado desde H5. **Pregunta funcional**: la pantalla de anulación debe mostrar (y usar) la fecha de anulación vigente en CORE, ¿correcto?

## 5. Re-test tras la corrección (RCI de reserva 0005726681055)

Alta en SCA2 con 0005726681055 → **15787898**, CORE la envía a Acción Administrativa (nivel 1, CE_RM). JJGONZ2: RETOMAR → observación «Sin documentación prueba H5 bis» → «El cliente no entrega documentación» → FINALIZAR:

| Paso | Resultado SCA2 v21 | Esperado (SCA) | |
|---|---|---|---|
| Modal | «¿Desea continuar?» / **«Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento»** | igual | ✔ |
| Guardado / navegación | «CORRECTO / Los datos se han guardado correctamente» → «Procesando la decisión de la solicitud…» → «Se va a redirigir a la anulación.» → mecanización | igual (s3 #24) | ✔ |
| CORE | gestión 3 `43705435` FINALIZADA 12:50:58 obs «Sin documentación prueba H5 bis»; gestión 5 `43705437` INCOMPLETA; **cabecera `catalogacion 2`, `fecAnulacion 24/01/2028`** (vencimiento de la póliza) | catalogación 2 a vencimiento | ✔ |
| Detalle | Catalogación **A VENCIMIENTO**, Fecha anulación **24/01/2028**; AA Finalizada, Mecanización Incompleta, solicitud Pendiente | igual | ✔ |
| Pantalla de mecanización | «Fecha anulación póliza **13/10/2026**» (fecha del alta) | fecha de anulación vigente en CORE (24/01/2028) | ✘ ver §4.2.5 |

No se pulsó «ANULAR PÓLIZA». El relanzamiento del error de 15787868 (apartado B del re-test) no fue posible: JJGONZ2 no tiene acceso a `/errores` («La página no existe o no tiene permiso para verla»). La corrección de CANCELAR (observación en CORE) se ha verificado sólo por test LCP de la interfaz (render) y por lectura del SAIL: no quedaban pólizas para una nueva Acción Administrativa.

## 6. Estados CORE observados (LCP, 13/10/2026)

```
15787868: gestiones [8 FINALIZADA 43705371 09/10 14:35:48] [3 FINALIZADA 43705372 13/10 12:21:56 obs "Pospuesta prueba H5,Finalizada prueba H5"]
          consultarListadoObs(3): "JJGONZ2 13/10/2026 12:18:17 Nivel 1: Pospuesta prueba H5"
          consultarDocumentos: [{tipo 7, 0900ab4481a09ebd}]  (tipo 9 no registrado: rechazado por CORE)
          record SCA2 id 113: EN_ACCION / CONTRA_ANULAR / ACCIONES ADMINISTRATIVAS / PENDIENTE, contadorPosponer 1, caducidad 2026-10-20, v4
          errores pendientes: CMD Posponer (12:18) y CMD CompletarAccion (12:22), nodo Subir documentos GD, DOC_GD_FAIL
15787882 (SCA): gestiones [8 FINALIZADA 43705406 13/10 12:26:59]
15787884: gestiones [8 FINALIZADA 43705408] [3 FINALIZADA 43705409 12:30:04 obs "Sin documentación prueba H5"] [5 INCOMPLETA 43705410]
          datosSolicitud: catalogacion 4, fecanulacion 13/10/2026 · cabecera: fecAnulacion 19/05/2027, catalogacion 4, estadoSolicitud 8
          record id 125: PDTE_MECANIZAR / MECANIZAR / PENDIENTE v5
15787889: gestiones [8 FINALIZADA 43705418] [3 FINALIZADA 43705419 12:35:44 obs null]; cabecera estadoSolicitud 5; record CANCELADA / FIN / COMPLETADA v5
```

## 7. Limitaciones

- SCA no comparable en las acciones (latencia >4 min y 403 en el alta); comparación de SCA hecha sobre el SAIL vivo de TEST y sobre el caso 2-2 (lectura).
- 2-3, 2-4 y 2-5 necesitan datos que no existen en TEST con las pólizas asignadas (origen FDC, póliza Mas Movil, causa BAJA TEMPORAL/BAJA VEHÍCULO).
- El visor del DNI («ojo») no se pudo abrir en la pantalla AA porque el documento sólo llega al gestor documental al posponer/finalizar (mismo diseño en SCA).
- No se ha pulsado «ANULAR PÓLIZA» en mecanización. No se han borrado solicitudes ni modificado datos CORE por LCP. SCA, SCAC, CORE, GAIA, PRE y Documentum no se han tocado.
- Las pólizas RCI asignadas fueron a Acción Administrativa (lo decide CORE), así que no hubo salto a nivel 2 en este plan.

## 8. Grabaciones y capturas (fuera del repo)

- Grabación 1 (15 casos): `~/screencasts/h5-sca-sca2/h5-sca-sca2-edited.mp4`.
- Capturas: `~/sca2work/h5-evidencias/h5-c01-…` a `h5-c15-…` (nombres por caso/aplicación/pantalla, ver tabla).
- Grabación 2 (re-test 2-13 bis con 0005726681055 + intento de bandeja de errores): `~/screencasts/h5-bis-sca2/h5-bis-sca2-edited.mp4`; capturas `h5-bis-a-*.png`, `h5-bis-b-errores-sin-permiso.png`.
