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
