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
| SCA2_textoEstadoSolicitud, SCA2_colorEstadoSolicitud, SCA2_calcularEstadoSolicitud, SCA2_BuscadorTabla, SCA2_TablaOtrasSolAnulacion | `20063670 / 20063676 / 20052795 / 20056379 / 20065000` | PADRE | Etiquetas y colores del listado por NUUMA según HU3980 | 2026-10-07 17:00 | 2026-10-14 17:05 | calcularEstadoSolicitud 1→2, textoEstado 13→14, colorEstado 6→7, BuscadorTabla 11→12 (TablaOtrasSol sin cambios, v6). Validación LCP + render buscador OK; etiquetas/colores HU3980 |
| SCA2_DetalleSolicitud | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | PADRE | Tarjeta Autorización: sin codEstado en consultarAutorizacion (rechazo NSE, 15787950) mostraba «Pendiente»; ahora usa codEstGestion de la gestión 7 («Autorizacion Rechazada», rojo) como SCA_DetalleAnulacionAutorizacion | 2026-10-14 16:40 | 2026-10-14 17:00 | 52→54, readback OK, render 15787950/15787945 OK |
| SCA2_subirDocumentosGD, SCA2_calcularDocumentosASubir | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351 / _a-0000f069-4f37-8000-9cc8-011c48011c48_20052759` | PADRE | Documento de venta (con/sin traspaso) no llega al gestor documental en AA (Analisis SCA2 14/10) | 2026-10-07 17:00 | | |
| SCA2_ContraAnulacionOpciones | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | R10-C | Campañas: pasar tuTeQuedas/numBonAplic/svaElegido/email/fecVencimiento al modal de recuperación (hoy SCA2 nunca llama gestionarTTQ) y usar DEFCART (tréboles disponibles/recomendados, tipoBonificacion) como SCA | 2026-10-14 14:20 | 2026-10-14 17:40 | v44 → v47 (v45 DEFCART+datos campaña, v46 retención oculta bajo modal, v47 NIF tomador); probado UI 15787994/15788000/15788003/15788004: TTQ asigna tréboles y finaliza |
| SCA2_ContraAnulacionModalRecuperacionPoliza | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951` | R10-C | Paridad SCA en asignación TTQ/tréboles/SVA (reset estado argumento en error, mensaje cerca de vencimiento) | 2026-10-14 14:20 | 2026-10-14 17:40 | v4 → v5; probado UI 15788004 (argumento vuelve a Pendiente tras error Club MAPFRE) |
| SCA2_executeAsignarIntegracion | `6eb7470e-5807-4050-801c-442bdab112c3` | R10-C | Asignación de tréboles Club MAPFRE falla en SCA2 (500 «no SOAPAction header!») mientras SCAC_executeAsignarIntegracion responde 200 con el mismo payload | 2026-10-14 16:30 | 2026-10-14 16:40 | v1 → v2: `ignoreEmptyHeaders` a false para que se envíe `SOAPAction: ""`; test LCP con NIF inválido devuelve 200/inderror=1 como SCAC |
| SCA2_construirContextoAlta | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056014 | PADRE | Alta Hogar NSE (hallazgo R10-A 0732000028208): datosPolizaHogar vacío ({}) rompe SCA2_PreGenerarStudAnul («Cannot index codCalificacion into List of Variant»); se rellena como en datosPolizaAutos | 2026-10-14 17:20 | 2026-10-14 17:35 | v10 → v11 OK: LCP construirContextoAlta+PreGenerarStudAnul sin error para Hogar NSE 0732000028208 (origenPoliza NSE-Hogar), Autos NSE 2002100194827 y wAutemis 0000253500329; pendiente alta UI |

## Estado por sesión

| Sesión | Estado | Último commit | Nota |
|---|---|---|---|
| R10-A Telemáticas | TERMINADA (2026-10-14 ~17:00 UTC) | ninguna reserva; ningún objeto SCA2 modificado | Informe `pruebas/r10a-telematicas.md`. 20 pólizas R10-A clasificadas (todas NSE telemáticas; sólo 5 vigentes sin solicitud abierta). Solicitudes creadas: SCA 15787971/15787976/15787984; SCA2 15787973/15787979. Hallazgos: decisora SCA TEST no ejecuta (403/«Aún procesando») → CA/AA no comparables en SCA; **alta Hogar SCA2 (0732000028208) no crea solicitud ni error, reproducido 2 veces → pendiente de diagnóstico con trazas de proceso**; texto distinto en mensaje «solicitud abierta»; pregunta «¿insiste?» SI24 sigue pendiente de decisión (ronda 9). |
| R10-B Corredor | EN CURSO (inicio 2026-10-14 13:35 UTC) | | Alta + CA con pólizas de corredor (§R10-B); informe r10b-corredor.md |
| R10-C Campañas TTQ/PREMFIDE/RETOS/SVA | TERMINADA (2026-10-14 17:40 UTC) | ver último commit R10-C | Informe `pruebas/r10c-campanas.md`: 2 OK, 1 corregido (TTQ: Opciones v47, ModalRecuperacionPoliza v5, executeAsignarIntegracion v2), 2 pendientes de decisión (SVA, pérdida de descuento), RETOS/PREMFIDE no existen en TEST; SCA sin tarea CA (latencia/403). Aviso: `SCA2_consultarDPIntegracion` y `SCA2_inbsDeleteDocumentDTOIntegracion` tienen el mismo defecto SOAPAction |
| R10-D Plan de pagos + NSE autorización | TERMINADA (2026-10-14 17:40 UTC) | ver `r10d-plan-pagos-documentos-nse.md` | 6 solicitudes nuevas (SCA 15787978/15787992/15787996 sólo Alta por latencia; SCA2 15787977/15787986/15787998). Sin objetos modificados ni reservas. Tipo 9 confirmado perdido con caso nuevo (15787998), tipo 1 se conserva (15787986); sin error en bandeja |
| PADRE | en curso | | HU3980 estados aplicado (v2/14/7/12); Detalle NSE corregido (v54); documentos AA en análisis (misma regla que SCA; espera caso nuevo de R10-D) |

## Incidencias compartidas

| Hora (UTC) | Sesión | Incidencia | Afecta a | Resolución |
|---|---|---|---|---|
