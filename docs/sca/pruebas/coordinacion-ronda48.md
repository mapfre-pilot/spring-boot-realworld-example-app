# Coordinación ronda 48 (SCA2, Appian TEST)

Protocolo (igual que R47): `git pull` → reservar aquí → leer versión viva → backup en `backups-r48/` → cambio mínimo → importar → reexportar y comparar → liberar con versión antes→después.

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| SCA2_AltaSolicitudPage | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055716 | R48-A | LIBERADO | 53→54 | Espera tras GUARDAR (tope y salida) y un solo aviso |
| SCA2_DetalleTareas | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055554 | R48-A | LIBERADO | 43→44 | Espera «Procesando la decisión…»: mensaje de tope |
| SCA2_TXT_ESPERA_DECISION_ADICIONAL | _a-0000f09f-42ed-8000-9d42-011c48011c48_5648821 | R48-A | LIBERADO | 1→2 | Texto «el sistema está tardando» |
| SCA2_TXT_ESPERA_AGOTADA (nueva) | _a-0000f0af-4eea-8000-9d50-011c48011c48_5705249 | R48-A | LIBERADO | —→1 | Texto de salida al agotar la espera |
| SCA2_CatMantenimiento | _a-0000f093-2064-8000-9d36-011c48011c48_5604449 | R48-D | LIBERADO | 8→9 | Reactivar: avisar si ya hay otra fila activa con la misma clave |
| SCA2_catConstruirCarga | _a-0000f093-2064-8000-9d36-011c48011c48_5604038 | R48-D | LIBERADO | 3→4 | Al casar existentes por clave, priorizar la fila activa |
