# Coordinación ronda 9 (sesiones R9-A … R9-E)

Mismo protocolo que `coordinacion-ronda8.md`. Resumen obligatorio:

1. **Antes de modificar un objeto Appian**: `git pull --rebase origin feature/sca`, añadir fila en «Reservas» (objeto, UUID, sesión, motivo, hora UTC), commit + push. Si el objeto ya está reservado por otra sesión, esperar o coordinar por este fichero (sección «Incidencias»).
2. GET vivo del objeto inmediatamente antes del PUT; backup en disco; PUT completo; relectura; comparación; `testInterface`/`testRule`/prueba de proceso.
3. Al terminar: liberar la reserva anotando versión anterior → nueva y resultado.
4. Objetos compartidos de alto riesgo (`SCA2_DetalleSolicitud`, `SCA2_DetalleTareas`, `SCA2_AltaSolicitudPage`, `SCA2 CMD Mecanizar`): reserva de máximo 60 min y cambios mínimos.
5. **Nunca** desactivar SCA2, tocar SCA/SCAC/CORE/GAIA/Documentum, borrar solicitudes CORE, ni usar pólizas de otra sesión (`polizas-ronda9.md`).
6. Usuarios: JJGONZ2 (Oficina/CE_RM) y SISANS (SI24 Experto). Las contraseñas están en secretos (`APPIAN_TEST_NOPRO_JJGONZ2_PASSWORD`, `APPIAN_TEST_NOPRO_SISANS_PASSWORD`); no escribirlas nunca.
7. Cada sesión escribe solo su informe `r9X-*.md`; las incidencias que afecten a otras van en este fichero.

## Reservas

| Objeto | UUID | Sesión | Motivo | Reservado (UTC) | Liberado (UTC) | Versión ant. → nueva / resultado |
|---|---|---|---|---|---|---|
| SCA2 CMD CompletarAccion (máx. 60 min) | `0000f06f-1307-8000-65b1-7f0000014e7a` | R9-D | Decisión 4: nodo «Actualizar Autorizacion» no repite guardarAutorizacion si la pantalla ya lo grabó (autorizacionGuardada) | 2026-10-13 16:57| 2026-10-13 16:57 | nodo «Actualizar Autorizacion» (303): no repite guardarAutorizacion si resultado.autorizacionGuardada; resto del PM idéntico |
| SCA2_AltaSolicitudPage (2ª reserva, ≤15 min) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-A | A6: pasar canalProductor/isSi24/codInt/polizaVencida a SCA2_erroresGuardarSolicitud como SCA (aviso misma anualidad) | 2026-10-13 17:15 | 2026-10-13 17:22 | v28 → v29: infoSolicitud de SCA2_erroresGuardarSolicitud lleva canalProductor/isSi24/codInt/polizaVencida (nuevas locals consultaClave/tipoProductor/codIntTomador/polizaVencida). LIBERADA: GET vivo de v29 |
| SCA2_AnulacionFueraNormaPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | R9-D | Decisión 4: CANCELAR muestra resultado real de guardarAutorizacion | 2026-10-13 16:36| 2026-10-13 16:39 | v22 → v23: CANCELAR graba guardarAutorizacion codEstado 5 síncrono y muestra el resultado real (popup ERROR si CORE falla) |
| SCA2_AltaSolicitudPage | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-A | restaurar simulación al GUARDAR (A1/A3), servicio caído (A5) | 2026-10-13 16:27 | 2026-10-13 17:00 | v27 → v28: simulación restaurada (popup inline + PRRA en GUARDAR). LIBERADA para R9-C: haced GET vivo de v28. Si las pruebas UI de R9-A exigen retoques, R9-A volverá a reservar |
| SCA2_simularAnulacionPolizaIntegracion (seguridad) | `a980b325-e149-4217-834e-234456d2c2df` | R9-A | seguridad para usuarios finales (A1) | 2026-10-13 16:27 | 2026-10-13 17:00 | Sin cambios: JJGONZ2/SISANS ya son Viewer (SCA2 Users + SCAC Usuarios en el CS compartido) |
| SCA2_simularAnulacion* (reglas simularAnulacion, simularAnulacionPoliza, simularAnulacionAltaNse, consultarNewAlta, obtenerUserPassSimularPoliza) | `20051692 / 20051194 / 20051650 / 20051608 / 20051704` | R9-A | seguridad / paridad con SCA (A1) | 2026-10-13 16:27 | 2026-10-13 17:00 | Sin cambios (misma expresión que SCA salvo guard null / errorHttp; seguridad heredada equivalente) |
| SCA2 CMD CrearSolicitud (= SCA2 CMD Alta) | `0000f06f-28fc-8000-6693-7f0000014e7a` | R9-A | simulación/PRRA tras guardar si persiste el 403 (A3) | 2026-10-13 16:27 | 2026-10-13 17:00 | Sin cambios de momento (la simulación/PRRA se ejecuta en la interfaz); se volverá a reservar si hace falta |
| SCA2_MecanizacionPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | R9-D | C1 patrón NSE / botones | 2026-10-13 16:26| 2026-10-13 16:39 | v14 → v15: aviso NSE pendiente de autorizar (observaciones 00000005) como SCA; la anulación se lanza al ACEPTAR |
| SCA2 CMD Mecanizar | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | R9-D | C1 patrón NSE / ANL (C3) | 2026-10-13 16:26| 2026-10-13 16:39 | sin cambios (la espera ANL 24 h vs. espera indefinida de SCA se documenta, depende de ANL) |
| SCA2_ContraAnulacionModalSiNo | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052807` | R9-C | B7-insiste: pregunta «¿insiste?» solo CCC/CCR | 2026-10-13 16:40 | 2026-10-13 19:05 | v1 → v2 OK (UI B2 15787910 sin pregunta; render LCP OK) |
| SCA2_ContraAnulacionOpciones | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | R9-C | B7-insiste: anulaTecnico/anulaExperto vacío salvo CCC; B7-acuerdos aviso Red Mapfre | 2026-10-13 16:40 | 2026-10-13 19:05 | v41 → v42 → v43 OK (v43 retira el bloqueo de botones; ver Incidencias) |
| SCA2_AccionesAdministrativasPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | R9-C | B7-causas / B7-acuerdos en AA | 2026-10-13 16:40 | 2026-10-13 19:05 | sin cambios (en AA no se elige causa) |
| SCA2_consultarCausa | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050906` | R9-C | B7-causas: ocultar causas 13/14/16/17/18/28/31/32 a SI24 | 2026-10-13 16:40 | 2026-10-13 19:05 | v1 → v2 OK (LCP + UI A1/A3) |
| SCA2_AltaSolicitudPage (EN ESPERA, reservada por R9-A) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-C | B7-causas: finalmente no necesaria (filtro en SCA2_consultarCausa) | 2026-10-13 16:40 (en cola) | 2026-10-13 19:05 | sin cambios por R9-C |
| SCA2_DetalleSolicitud | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | R9-E | F1 detalle sólo consulta CORE/SCA (sin acciones) + F3 fecha resolución; cambios mínimos, máx. 60 min por edición | 2026-10-13 16:55 | 2026-10-13 19:50 | sin cambios (v51): la rama sólo-CORE ya existía y los botones dependen de tarea SCA2 |
| SCA2_Buscador | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | R9-E | F1 apertura detalle filas sólo-CORE; F3 fecha resolución en «Otras solicitudes» | 2026-10-13 16:55 | 2026-10-13 19:50 | v27 → v29: fecha resolución «-» en grid Otras solicitudes salvo estado CORE final |
| SCA2_BuscadorTabla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | R9-E | F3 fecha resolución vacía mientras pendiente | 2026-10-13 16:55 | 2026-10-13 19:50 | sin cambios (v11): ya iba vacía en pendientes |
| SCA2 CMD Decidir (nodo DUE SI24) y regla del cuerpo DUE (SCA2_notificarNivel, UUID pendiente de localizar) | `0000f06f-0eab-8000-6595-7f0000014e7a` | R9-E | E1 teléfono/correo de contacto en el correo DUE | 2026-10-13 16:55 | 2026-10-13 19:50 | sin cambios en el PM; la corrección está en SCA2_notificarNivel |
| SCA2_notificarNivel (regla, fuera del listado de la app) | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505875` | R9-E | E1: teléfono de contacto (tlfexperto) en el cuerpo del DUE como SCA | 2026-10-13 17:25 | 2026-10-13 19:50 | v3 → v5: Tomador/DNI/Email contacto/Teléfono contacto (tlfexperto + datos de contacto en vivo) en el DUE |
| SCA2_TablaOtrasSolAnulacion | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065000` | R9-E | F1/F3: «Otras solicitudes» del Detalle con filas CORE y fecha resolución vacía si pendiente | 2026-10-13 17:25 | 2026-10-13 19:50 | v2 → v6: filas CORE/SCA + fecha resolución «-» salvo estado final + fecha solicitud de CORE |
| SCA2_puedeGestionarTarea | `_a-0000f06b-141a-8000-9d23-011c48011c48_5454993` | R9-B | B7-SI24 / Decisión 2 / B3: CE_RM no gestiona tareas SI24; SI24 no retoma AA nivel 1 pospuesta | 2026-10-13 16:55 | 2026-10-13 19:05 | v4 → v6 OK (codSubPerfil; tareas SI24 sólo SI24; SI24 sólo consulta nivel 1) |
| SCA2_DetalleSolicitud (máx. 60 min) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | R9-B | B7-SI24 mensaje «gestionando SI24»; Decisión 2 ocultar RETOMAR/REASIGNAR | 2026-10-13 16:55 | 2026-10-13 17:25 | v51 → v52 OK (aviso SI24, codSubPerfil) |
| SCA2_DetalleTareas (máx. 60 min) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | R9-B | B5/B7: enlace Completar sólo si puedeGestionarTarea y solicitud no finalizada | 2026-10-13 16:55 | 2026-10-13 17:25 | v23 → v24 OK (Completar sólo si puedeGestionarTarea y no finalizada) |
| SCA2 CMD Posponer | `0000f06f-8a47-8000-6751-7f0000014e7a` | R9-B | B1: guardar oficina elegida al POSPONER | 2026-10-13 16:55 | 2026-10-13 17:35 | nodo Write Posponer: guarda oficina en SCA2 Tarea.tokenTarea OK |
| SCA2_ContraAnulacionOpciones (EN ESPERA, reservada por R9-C) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | R9-B | B1: preseleccionar oficina guardada al RETOMAR — R9-B espera a que R9-C libere | 2026-10-13 16:55 (en cola) | 2026-10-13 19:05 | no modificado por R9-B (R9-C no liberó); relectura de oficina pendiente, ver r9b-*.md §4 |
| SCA2_AccionesAdministrativasPrincipal (EN ESPERA, reservada por R9-C) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | R9-B | B1: preseleccionar oficina guardada al RETOMAR — R9-B espera a que R9-C libere | 2026-10-13 16:55 (en cola) | 2026-10-13 19:05 | no modificado por R9-B (R9-C no liberó); relectura de oficina pendiente |
| SCA2_ContraAnulacionOpciones | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | PADRE (consolidación R9) | B1: preseleccionar oficina guardada en SCA2 Tarea.tokenTarea al RETOMAR | 2026-10-13 17:37 | 2026-10-13 20:05 | v43 → v44 OK: local!detalleOficina se inicializa con la oficina guardada en SCA2 Tarea.tokenTarea (render LCP tarea 157 → MADRID CORREDORES NORTE II, tarea 162 → VILLALBA). LIBERADA |
| SCA2_AccionesAdministrativasPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | PADRE (consolidación R9) | B1: preseleccionar oficina guardada al RETOMAR | 2026-10-13 17:37 | 2026-10-13 20:05 | v21 → v22 OK: misma relectura de oficina (render LCP tareas 157/162 preseleccionan la oficina). LIBERADA |
| SCA2_VertiVencimientoPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063389` | PADRE (consolidación R9) | Verti: fechaAnulacion a determinarContacto en yyyy-MM-dd como SCA (hoy 400 del servicio) | 2026-10-13 17:37 | 2026-10-13 20:05 | v2 → v3 OK: fechaAnulacion en yyyy-MM-dd (render LCP 15787912 sin errores). LIBERADA |
| SCA2 CMD Mecanizar | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | PADRE (consolidación R9) | Verti: nodo Cargar pasa a determinarContacto los mismos datos que SCA Mecanizacion (hoy canalEntrada nulo → 400) | 2026-10-13 17:37 | 2026-10-13 20:05 | nodo «Cargar» (contacto): mismas entradas que SCA Mecanizacion nodo determinarContacto (canal, línea, clave de producción, catalogación, motivo, causa, fecha yyyy-MM-dd, detalle, anulaTecnico/Experto). 42 nodos antes y después. LIBERADA |

## Estado por sesión

| Sesión | Estado | Último commit | Nota |
|---|---|---|---|
| R9-A | TERMINADA | ver informe r9a-alta-simulacion-polizas-nuevas.md | SCA2_AltaSolicitudPage v29 liberada; solicitudes 15787912, 15787921 |
| R9-B | terminada | ver r9b-tareas-permisos-oficina-si24.md | inicio 16:25, fin 19:05 UTC; reservas liberadas |
| R9-C | pendiente | | |
| R9-D | TERMINADA | ver informe r9d-mecanizacion-autorizacion-anl.md | 3 objetos SCA2 modificados (AnulacionFueraNorma v23, MecanizacionPrincipal v15, CMD CompletarAccion nodo 303); reservas liberadas |
| R9-E | terminada | | informe docs/sca/pruebas/r9e-buscador-detalle-due.md; solicitud propia 15787911 (RCI 0005726698173) pendiente |

## Incidencias compartidas

| Hora (UTC) | Sesión | Incidencia | Afecta a | Resolución |
|---|---|---|---|---|
| 2026-10-13 19:35 | R9-E | Prueba UI DUE: alta SCA2 15787911 (RCI 0005726698173, JJGONZ2). Al RETOMAR la contra anulación nivel 1, con el argumento obligatorio seleccionado POSITIVO/NEGATIVO quedan deshabilitados sin aviso visible y el ojo del argumentario no abre nada; FINALIZAR deshabilitado («Se debe ejecutar al menos 1 argumento»). Puede ser el nuevo bloqueo B7-acuerdos (local!bloqueoAcuerdoRedMapfre, SCA2_ContraAnulacionOpciones v42) o un cambio en curso. R9-E deja 15787911 pendiente y no la toca más. | R9-C (SCA2_ContraAnulacionOpciones) | pendiente: R9-C confirmar si es el bloqueo esperado y que el aviso se muestre |
| 2026-10-13 17:00 | R9-A | SCA2_AltaSolicitudPage pasa a v28 (GUARDAR con simulación + popup; nuevas locals showPopupSimular/isPolizaPRRA/codProducto/datosTomador). Liberada para R9-C. Pendiente prueba UI de R9-A: si falla, R9-A reservará de nuevo | R9-C | GET vivo de v28 antes de editar |

- **R9-C (2026-10-13 ~18:30) — Incidencia B7-acuerdos**: la v42 de `SCA2_ContraAnulacionOpciones` deshabilitaba POSITIVO/NEGATIVO/FINALIZAR para CE_RM en nivel 1 cuando la póliza cumplía la lista codClaseAgt/codAcuerdo de `SCA_ContraAnulacionModalSiNo`; R9-E detectó que bloqueaba la RCI 0005726698173 (solicitud 15787911). Corregido en v43: se mantiene sólo el aviso informativo (texto provisional) y se elimina el bloqueo; el criterio «debe tratarla SI24» queda como duda funcional (lo decide el motor tras el NEGATIVO de nivel 1).
