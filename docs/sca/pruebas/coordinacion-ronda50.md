# Coordinación ronda 50 (SCA2, Appian TEST)

Origen: el usuario pide aplicar las decisiones técnicas que no cambian el flujo funcional de SCA2 y probarlo todo (dudas técnicas de `../67-dudas-pendientes-consolidado.md`).

Protocolo (igual que R49): `git pull` → reservar aquí (commit + push) → leer versión viva → backup en `backups-r50/` → cambio mínimo → justo antes de guardar, `git pull` y comprobar que la versión viva es la de tu copia → guardar → reexportar y comparar → liberar con versión antes→después.

| Sesión | Alcance |
|---|---|
| R50-A | Caché de cabecera sin duplicados, UNIQUE C1, límite de la fecha del último siniestro a 1000, record types |
| R50-B | Tareas pendientes y errores sin duplicados (C7), recorte de `FECIMPRESION`, error 215 de «Write Tarea», decisión sobre FKs (C8) |
| R50-C | Borrado de objetos sin uso, reglas SCA2 fuera de la aplicación, relanzar el error 215 |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| `SCA2_limitesFilaCacheCabecera` | `_a-0000f09f-42ed-8000-9d42-011c48011c48_5649216` | R50-A | **liberado** | v1→v2 | `polizaFechaultimosiniestro` 255→1000 |
| Web API `SCA2_refrescarCacheCabecera` | `324a1ee4-2312-4565-aa36-a383db17b36f` | R50-A | reservado | v9→? | tolerar unique_violation / sin segunda fila |
| `SCA2_renovarCacheCabecera` | `_a-0000f093-2064-8000-9d36-011c48011c48_5607622` | R50-A | reservado | v4→? | releer id justo antes de escribir |
| PM `SCA2 CMD RefrescarCacheCabecera` | `0000f095-81a8-8000-d613-7f0000014e7a` | R50-A | reservado | ? | solo si hace falta |
| PM `SCA2 CMD Alta` (nodo «Write Datos») | `0000f06f-28fc-8000-6693-7f0000014e7a` | R50-A | **liberado** | 43.0→44.0 | nodo 8: las dos filas de `SCA2 Datos Cabecera` llevan `id: rule!SCA2_obtenerIdFilaCacheCabecera(idSolicitud: pv!idSolicitud)` (UPDATE si ya existe). Resto del nodo idéntico. R50-B puede seguir sobre 44.0 |
| RT `SCA2 Datos Cabecera` | `04f597de-5acd-45b2-9ab3-277713cd00a6` | R50-A | reservado | v12→? | tamaños / sincronización |
| RT `SCA2 Transicion` | `0b46024c-58b4-48be-a2a4-20d54bc40815` | R50-A | reservado | ? | tamaños / sincronización |
| PM `SCA2 CMD CrearAccion` (nodos 7, 9, 31, 8) | `0000f06f-0eaa-8000-6594-7f0000014e7a` | R50-B | reservado | v27→? | tarea PENDIENTE del mismo tipo: reutilizar id; Write Error sin duplicar |
| PM `SCA2 CMD Mecanizar` (nodos 7, 332, 12) | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | R50-B | reservado | v46→? | tareas VERTI/INDUCCION sin duplicar; Write Error sin duplicar |
| PM `SCA2 CMD Posponer` (nodos 5, 199) | `0000f06f-8a47-8000-6751-7f0000014e7a` | R50-B | reservado | ? | recorte FECIMPRESION a 255; Write Error sin duplicar |
| PM `SCA2 CMD Decidir` (nodos 7, 8) | `0000f06f-0eab-8000-6595-7f0000014e7a` | R50-B | reservado | v17→? | Write Error sin duplicar |
| PM `SCA2 CMD ObtenerDocumentoGD` (nodo 200) | `0000f06f-c12b-8000-67ae-7f0000014e7a` | R50-B | reservado | ? | Write Error sin duplicar |
| PM `SCA2 CMD CompletarAccion` (nodo 199) | `0000f06f-1307-8000-65b1-7f0000014e7a` | R50-B | reservado | v50→? | Write Error sin duplicar (solo nodo 199) |
| PM `SCA2 CMD Alta` (nodos 8 «Write Datos» y 6) | `0000f06f-28fc-8000-6693-7f0000014e7a` | R50-B | reservado | ? | recorte FECIMPRESION a 255 y Write Error. **Espera a que R50-A libere** y se hace sobre su versión |
| ER nuevas `SCA2_obtenerIdTareaPendiente` / `SCA2_obtenerErrorPendiente` | `—` | R50-B | reservado | —→v1 | lectura de la PENDIENTE existente |
| PM `SCA2 CMD CambiarNivel` | `0000f06f-8a54-8000-6759-7f0000014e7a` | R50-C | Reservado | 7.0 (borrador vivo) → borrado | Sin uso |
| PM `SCA2 CMD RegistrarDesincronizacion` | `0000f095-791c-8000-d602-7f0000014e7a` | R50-C | Reservado | → borrado | Sin uso |
| IF `SCA2_RegistrarDesincronizacionForm` | `_a-0000f093-2064-8000-9d36-011c48011c48_5605245` | R50-C | Reservado | v1 → borrado | Sólo lo usa el PM anterior |
| ER `SCA2_tmpMedicionArgumentario` | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5643715` | R50-C | Reservado | v4 → borrado | Temporal, sin uso |
| ER `SCA2_tmpSolanulDateFmt_1791282137` | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5516094` | R50-C | Reservado | v1 → borrado | Temporal, fuera de la app, sin uso |
| CONS `SCA2_TXT_URL_AUTEMISDIST` | `_a-0000f09f-42ed-8000-9d42-011c48011c48_5650543` | R50-C | Reservado | v2 → borrado | Sin uso (se usa `SCA2_TXT_WAUTEMIS`) |
| CONS `SCA2_VAL_ESPERA_DECISION_INCREMENTO_SEGUNDOS` | `_a-0000f09f-42ed-8000-9d42-011c48011c48_5648803` | R50-C | Reservado | v1 → borrado | Sin uso (R35-A: reservada, no conectada) |
| CONS `SCA2_TXT_COD_ESTADO_SOL_CANCELADA` | `225d3e42-00bf-4753-98df-dfe6a04cff34` | R50-C | Reservado | v1 → borrado | Sin uso (R45-B revertido), fuera de la app |
| CONS `SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA` | `2bde13a5-2a36-4561-ab18-9718d57a4ee6` | R50-C | Reservado | v1 → borrado | Sin uso (R45-B revertido), fuera de la app |
| ER `SCA2_notificarNivel` | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505875` | R50-C | Reservado | v5 | Añadir a la app SCA2 y a `SCA2 Rules and Constants` (sin cambiar contenido) |
| ER `SCA2_finalizarGestionSGC` | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505931` | R50-C | Reservado | v2 | Ídem |
| ER `SCA2_construirSolicitudAnulacionAnl` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5493600` | R50-C | Reservado | v1 | Ídem |
| ER `SCA2_construirContextoSolicitudAnl` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5493604` | R50-C | Reservado | v2 | Ídem |
| ER `SCA2_construirSolicitudAnulacionAnlTraducida` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5501155` | R50-C | Reservado | v2 | Ídem |
| ER `SCA2_construirConsultaActualizarMecanizacion` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5493616` | R50-C | Reservado | v1 | Ídem |
| Aplicación `SCA2 Sistema Comercial de Anulaciones` (contenido) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128` | R50-C | Reservado | — | Sólo añadir las 6 reglas (no se desactiva la app) |
| PM `SCA2 CMD Caducar` (nodo 9) | `0000f06f-4f07-8000-670d-7f0000014e7a` | R50-B | reservado | ? | Write Error sin duplicar (intentos + 1) |
| PM `SCA2 CMD CambiarNivel` (nodo 199) | `0000f06f-8a54-8000-6759-7f0000014e7a` | R50-B | **cancelado** | sin cambios | lo borra R50-C (sin uso); R50-B no lo toca |
| PM `SCA2 CMD Finalizar` (nodos 9, 17) | `0000f06f-1309-8000-65b3-7f0000014e7a` | R50-B | reservado | ? | Write Error sin duplicar (intentos + 1) |
| PM `SCA2 CMD MecanizarNSE` (nodo 99) | `0000f095-7c8e-8000-d60a-7f0000014e7a` | R50-B | reservado | ? | Write Error sin duplicar (intentos + 1) |
