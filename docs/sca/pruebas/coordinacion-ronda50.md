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
| `SCA2_limitesFilaCacheCabecera` | `_a-0000f09f-42ed-8000-9d42-011c48011c48_5649216` | R50-A | reservado | v1→? | límite fecha último siniestro 255→1000 |
| Web API `SCA2_refrescarCacheCabecera` | `324a1ee4-2312-4565-aa36-a383db17b36f` | R50-A | reservado | v9→? | tolerar unique_violation / sin segunda fila |
| `SCA2_renovarCacheCabecera` | `_a-0000f093-2064-8000-9d36-011c48011c48_5607622` | R50-A | reservado | v4→? | releer id justo antes de escribir |
| PM `SCA2 CMD RefrescarCacheCabecera` | `0000f095-81a8-8000-d613-7f0000014e7a` | R50-A | reservado | ? | solo si hace falta |
| PM `SCA2 CMD Alta` (nodo «Write Datos») | `0000f06f-28fc-8000-6693-7f0000014e7a` | R50-A | reservado | ? | la fila de cabecera del alta reutiliza el id |
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
