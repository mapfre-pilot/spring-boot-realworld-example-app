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
| SCA2_AltaSolicitudPage | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | R9-A | restaurar simulación al GUARDAR (A1/A3), servicio caído (A5) | 2026-10-13 16:27 | | |
| SCA2_simularAnulacionPolizaIntegracion (seguridad) | `a980b325-e149-4217-834e-234456d2c2df` | R9-A | seguridad para usuarios finales (A1) | 2026-10-13 16:27 | | |
| SCA2_simularAnulacion* (reglas simularAnulacion, simularAnulacionPoliza, simularAnulacionAltaNse, consultarNewAlta, obtenerUserPassSimularPoliza) | `20051692 / 20051194 / 20051650 / 20051608 / 20051704` | R9-A | seguridad / paridad con SCA (A1) | 2026-10-13 16:27 | | |
| SCA2 CMD CrearSolicitud | `(pendiente de localizar UUID)` | R9-A | simulación/PRRA tras guardar si persiste el 403 (A3) | 2026-10-13 16:27 | | |
| SCA2_MecanizacionPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | R9-D | C1 patrón NSE / botones | 2026-10-13 16:26 | | |
| SCA2 CMD Mecanizar | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | R9-D | C1 patrón NSE / ANL (C3) | 2026-10-13 16:26 | | |

## Estado por sesión

| Sesión | Estado | Último commit | Nota |
|---|---|---|---|
| R9-A | en curso | | inicio 2026-10-13 16:27 UTC |
| R9-B | pendiente | | |
| R9-C | pendiente | | |
| R9-D | en curso | | inicio 2026-10-13 16:26 UTC |
| R9-E | pendiente | | |

## Incidencias compartidas

| Hora (UTC) | Sesión | Incidencia | Afecta a | Resolución |
|---|---|---|---|---|
