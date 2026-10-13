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
| SCA2_AnulacionFueraNormaPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | R9-D | Decisión 4: CANCELAR muestra resultado real de guardarAutorizacion | 2026-10-13 16:36 | | |
| SCA2_AltaSolicitudPage | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-A | restaurar simulación al GUARDAR (A1/A3), servicio caído (A5) | 2026-10-13 16:27 | | |
| SCA2_simularAnulacionPolizaIntegracion (seguridad) | `a980b325-e149-4217-834e-234456d2c2df` | R9-A | seguridad para usuarios finales (A1) | 2026-10-13 16:27 | | |
| SCA2_simularAnulacion* (reglas simularAnulacion, simularAnulacionPoliza, simularAnulacionAltaNse, consultarNewAlta, obtenerUserPassSimularPoliza) | `20051692 / 20051194 / 20051650 / 20051608 / 20051704` | R9-A | seguridad / paridad con SCA (A1) | 2026-10-13 16:27 | | |
| SCA2 CMD CrearSolicitud | `(pendiente de localizar UUID)` | R9-A | simulación/PRRA tras guardar si persiste el 403 (A3) | 2026-10-13 16:27 | | |
| SCA2_MecanizacionPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | R9-D | C1 patrón NSE / botones | 2026-10-13 16:26 | | |
| SCA2 CMD Mecanizar | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | R9-D | C1 patrón NSE / ANL (C3) | 2026-10-13 16:26 | | |
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
| R9-A | en curso | | inicio 2026-10-13 16:27 UTC |
| R9-B | en curso | | inicio 2026-10-13 16:25 UTC |
| R9-C | pendiente | | |
| R9-D | en curso | | inicio 2026-10-13 16:26 UTC |
| R9-E | en curso | | inicio 2026-10-13 16:55 UTC |

## Incidencias compartidas

| Hora (UTC) | Sesión | Incidencia | Afecta a | Resolución |
|---|---|---|---|---|
