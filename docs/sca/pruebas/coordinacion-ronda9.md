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
| SCA2_AltaSolicitudPage (2ª reserva, ≤15 min) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-A | A6: pasar canalProductor/isSi24/codInt/polizaVencida a SCA2_erroresGuardarSolicitud como SCA (aviso misma anualidad) | 2026-10-13 17:15 | 2026-10-13 17:22 | v28 → v29: infoSolicitud de SCA2_erroresGuardarSolicitud lleva canalProductor/isSi24/codInt/polizaVencida (nuevas locals consultaClave/tipoProductor/codIntTomador/polizaVencida). LIBERADA: GET vivo de v29 |
| SCA2_AnulacionFueraNormaPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | R9-D | Decisión 4: CANCELAR muestra resultado real de guardarAutorizacion | 2026-10-13 16:36| 2026-10-13 16:39 | v22 → v23: CANCELAR graba guardarAutorizacion codEstado 5 síncrono y muestra el resultado real (popup ERROR si CORE falla) |
| SCA2_AltaSolicitudPage | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-A | restaurar simulación al GUARDAR (A1/A3), servicio caído (A5) | 2026-10-13 16:27 | 2026-10-13 17:00 | v27 → v28: simulación restaurada (popup inline + PRRA en GUARDAR). LIBERADA para R9-C: haced GET vivo de v28. Si las pruebas UI de R9-A exigen retoques, R9-A volverá a reservar |
| SCA2_simularAnulacionPolizaIntegracion (seguridad) | `a980b325-e149-4217-834e-234456d2c2df` | R9-A | seguridad para usuarios finales (A1) | 2026-10-13 16:27 | 2026-10-13 17:00 | Sin cambios: JJGONZ2/SISANS ya son Viewer (SCA2 Users + SCAC Usuarios en el CS compartido) |
| SCA2_simularAnulacion* (reglas simularAnulacion, simularAnulacionPoliza, simularAnulacionAltaNse, consultarNewAlta, obtenerUserPassSimularPoliza) | `20051692 / 20051194 / 20051650 / 20051608 / 20051704` | R9-A | seguridad / paridad con SCA (A1) | 2026-10-13 16:27 | 2026-10-13 17:00 | Sin cambios (misma expresión que SCA salvo guard null / errorHttp; seguridad heredada equivalente) |
| SCA2 CMD CrearSolicitud (= SCA2 CMD Alta) | `0000f06f-28fc-8000-6693-7f0000014e7a` | R9-A | simulación/PRRA tras guardar si persiste el 403 (A3) | 2026-10-13 16:27 | 2026-10-13 17:00 | Sin cambios de momento (la simulación/PRRA se ejecuta en la interfaz); se volverá a reservar si hace falta |
| SCA2_MecanizacionPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | R9-D | C1 patrón NSE / botones | 2026-10-13 16:26| 2026-10-13 16:39 | v14 → v15: aviso NSE pendiente de autorizar (observaciones 00000005) como SCA; la anulación se lanza al ACEPTAR |
| SCA2 CMD Mecanizar | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | R9-D | C1 patrón NSE / ANL (C3) | 2026-10-13 16:26| 2026-10-13 16:39 | sin cambios (la espera ANL 24 h vs. espera indefinida de SCA se documenta, depende de ANL) |
| SCA2_ContraAnulacionModalSiNo | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052807` | R9-C | B7-insiste: pregunta «¿insiste?» solo CCC/CCR; B7-acuerdos mensaje | 2026-10-13 16:40 | | |
| SCA2_ContraAnulacionOpciones | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | R9-C | B7-insiste: anulaTecnico/anulaExperto vacío salvo CCC; B7-acuerdos aviso/bloqueo Red Mapfre | 2026-10-13 16:40 | | |
| SCA2_AccionesAdministrativasPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | R9-C | B7-causas / B7-acuerdos en AA | 2026-10-13 16:40 | | |
| SCA2_consultarCausa | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050906` | R9-C | B7-causas: ocultar causas 13/14/16/17/18/28/31/32 a SI24 (alternativa si no se libera SCA2_AltaSolicitudPage) | 2026-10-13 16:40 | | |
| SCA2_AltaSolicitudPage (EN ESPERA, reservada por R9-A) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-C | B7-causas: filtrar local!causaDD para SI24 — R9-C espera a que R9-A libere | 2026-10-13 16:40 (en cola) | | |
| SCA2_DetalleSolicitud | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | R9-E | F1 detalle sólo consulta CORE/SCA (sin acciones) + F3 fecha resolución; cambios mínimos, máx. 60 min por edición | 2026-10-13 16:55 | | |
| SCA2_Buscador | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | R9-E | F1 apertura detalle filas sólo-CORE; F3 fecha resolución en «Otras solicitudes» | 2026-10-13 16:55 | | |
| SCA2_BuscadorTabla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | R9-E | F3 fecha resolución vacía mientras pendiente | 2026-10-13 16:55 | | |
| SCA2 CMD Decidir (nodo DUE SI24) y regla del cuerpo DUE (SCA2_notificarNivel, UUID pendiente de localizar) | `0000f06f-0eab-8000-6595-7f0000014e7a` | R9-E | E1 teléfono/correo de contacto en el correo DUE | 2026-10-13 16:55 | | |
| SCA2_notificarNivel (regla, fuera del listado de la app) | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505875` | R9-E | E1: teléfono de contacto (tlfexperto) en el cuerpo del DUE como SCA | 2026-10-13 17:25 | | |
| SCA2_TablaOtrasSolAnulacion | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065000` | R9-E | F1/F3: «Otras solicitudes» del Detalle con filas CORE y fecha resolución vacía si pendiente | 2026-10-13 17:25 | | |
| SCA2_puedeGestionarTarea | `_a-0000f06b-141a-8000-9d23-011c48011c48_5454993` | R9-B | B7-SI24 / Decisión 2 / B3: CE_RM no gestiona tareas SI24; SI24 no retoma AA nivel 1 pospuesta | 2026-10-13 16:55 | | |
| SCA2_DetalleSolicitud (máx. 60 min) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | R9-B | B7-SI24 mensaje «gestionando SI24»; Decisión 2 ocultar RETOMAR/REASIGNAR | 2026-10-13 16:55 | | |
| SCA2_DetalleTareas (máx. 60 min) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | R9-B | B5/B7: enlace Completar sólo si puedeGestionarTarea y solicitud no finalizada | 2026-10-13 16:55 | | |
| SCA2 CMD Posponer | `0000f06f-8a47-8000-6751-7f0000014e7a` | R9-B | B1: guardar oficina elegida al POSPONER | 2026-10-13 16:55 | | |
| SCA2_ContraAnulacionOpciones (EN ESPERA, reservada por R9-C) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | R9-B | B1: preseleccionar oficina guardada al RETOMAR — R9-B espera a que R9-C libere | 2026-10-13 16:55 (en cola) | | |
| SCA2_AccionesAdministrativasPrincipal (EN ESPERA, reservada por R9-C) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | R9-B | B1: preseleccionar oficina guardada al RETOMAR — R9-B espera a que R9-C libere | 2026-10-13 16:55 (en cola) | | |

## Estado por sesión

| Sesión | Estado | Último commit | Nota |
|---|---|---|---|
| R9-A | en curso | 7b630c1 | inicio 2026-10-13 16:27 UTC; SCA2_AltaSolicitudPage v28 liberada 17:00 |
| R9-B | en curso | | inicio 2026-10-13 16:25 UTC |
| R9-C | pendiente | | |
| R9-D | en curso | | inicio 2026-10-13 16:26 UTC |
| R9-E | en curso | | inicio 2026-10-13 16:55 UTC |

## Incidencias compartidas

| Hora (UTC) | Sesión | Incidencia | Afecta a | Resolución |
|---|---|---|---|---|
| 2026-10-13 17:00 | R9-A | SCA2_AltaSolicitudPage pasa a v28 (GUARDAR con simulación + popup; nuevas locals showPopupSimular/isPolizaPRRA/codProducto/datosTomador). Liberada para R9-C. Pendiente prueba UI de R9-A: si falla, R9-A reservará de nuevo | R9-C | GET vivo de v28 antes de editar |
