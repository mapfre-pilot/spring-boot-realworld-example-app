# Coordinación ronda 10 (sesiones R10-A … R10-D + PADRE)

Mismo protocolo que `coordinacion-ronda9.md` (léelo entero antes de empezar). Resumen obligatorio:

1. **Antes de modificar un objeto Appian**: `git pull --rebase origin feature/sca`, añadir fila en «Reservas» (objeto, UUID real, sesión, motivo, hora UTC), commit + push. Si el objeto ya está reservado por otra sesión, esperar o coordinar en «Incidencias».
2. GET vivo del objeto justo antes del PUT; backup en disco; PUT completo; relectura; comparación payload/readback; `testInterface`/`testRule`/prueba de proceso; prueba UI SCA vs SCA2.
3. Al terminar: liberar la reserva anotando versión anterior → nueva y resultado.
4. Objetos compartidos de alto riesgo (`SCA2_DetalleSolicitud`, `SCA2_DetalleTareas`, `SCA2_AltaSolicitudPage`, `SCA2_ContraAnulacionOpciones`, `SCA2_MecanizacionPrincipal`, `SCA2 CMD Mecanizar`, `SCA2 CMD Decidir`): reserva de máximo 60 min y cambios mínimos.
5. **Reservados por el PADRE durante toda la ronda** (no tocar): `SCA2_textoEstadoSolicitud`, `SCA2_colorEstadoSolicitud`, `SCA2_calcularEstadoSolicitud`, `SCA2_BuscadorTabla`, `SCA2_TablaOtrasSolAnulacion`, `SCA2_subirDocumentosGD`, `SCA2_calcularDocumentosASubir` (estados/etiquetas HU3980 y documentos AA).
6. **Nunca** desactivar SCA2, tocar SCA/SCAC/CORE/GAIA/Emisión/Documentum, finalizar o borrar solicitudes CORE, ni usar pólizas de otra sesión (`polizas-ronda10.md`). Solicitudes de prueba de rondas anteriores: solo consulta.
7. Usuarios: JJGONZ2 (Oficina/CE_RM) y SISANS (SI24 Experto). Contraseñas en secretos `APPIAN_TEST_NOPRO_JJGONZ2_PASSWORD` y `APPIAN_TEST_NOPRO_SISANS_PASSWORD`; no escribirlas nunca.
8. Cada sesión escribe solo su informe `r10X-*.md` (resultado por caso: OK / divergencia corregida / pendiente de decisión / no probado + motivo, con ids de solicitud y pólizas consumidas) y actualiza su fila en «Estado por sesión».

## Reservas

| Objeto | UUID | Sesión | Motivo | Reservado (UTC) | Liberado (UTC) | Versión ant. → nueva / resultado |
|---|---|---|---|---|---|---|
| SCA2_textoEstadoSolicitud, SCA2_colorEstadoSolicitud, SCA2_calcularEstadoSolicitud, SCA2_BuscadorTabla, SCA2_TablaOtrasSolAnulacion | `20063670 / 20063676 / 20052795 / 20056379 / 20065000` | PADRE | Etiquetas y colores del listado por NUUMA según HU3980 | 2026-10-07 17:00 | | |
| SCA2_subirDocumentosGD, SCA2_calcularDocumentosASubir | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351 / _a-0000f069-4f37-8000-9cc8-011c48011c48_20052759` | PADRE | Documento de venta (con/sin traspaso) no llega al gestor documental en AA (Analisis SCA2 14/10) | 2026-10-07 17:00 | | |
| SCA2_ContraAnulacionOpciones | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | R10-C | Campañas: pasar tuTeQuedas/numBonAplic/svaElegido/email/fecVencimiento al modal de recuperación (hoy SCA2 nunca llama gestionarTTQ) y usar DEFCART (tréboles disponibles/recomendados, tipoBonificacion) como SCA | 2026-10-14 14:20 | | |
| SCA2_ContraAnulacionModalRecuperacionPoliza | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951` | R10-C | Paridad SCA en asignación TTQ/tréboles/SVA (reset estado argumento en error, mensaje cerca de vencimiento) | 2026-10-14 14:20 | | |

## Estado por sesión

| Sesión | Estado | Último commit | Nota |
|---|---|---|---|
| R10-A Telemáticas | en curso (inicio 2026-10-14 13:40 UTC) | | lectura de planes/h1-h3; pólizas §R10-A de arriba abajo; informe r10a-telematicas.md |
| R10-B Corredor | EN CURSO (inicio 2026-10-14 13:35 UTC) | | Alta + CA con pólizas de corredor (§R10-B); informe r10b-corredor.md |
| R10-C Campañas TTQ/PREMFIDE/RETOS/SVA | en curso (2026-10-14 13:35 UTC) | | Leyendo planes; análisis SAIL CA campañas; pólizas §R10-C de arriba abajo |
| R10-D Plan de pagos + NSE autorización | en curso (inicio 2026-10-14 13:40 UTC) | | Lectura de planes; informe `r10d-plan-pagos-documentos-nse.md`; sin reservas todavía |
| PADRE | en curso | | HU3980 estados, Detalle tras actualización NSE, documentos AA |

## Incidencias compartidas

| Hora (UTC) | Sesión | Incidencia | Afecta a | Resolución |
|---|---|---|---|---|
