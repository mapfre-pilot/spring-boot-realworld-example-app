# Coordinación ronda 51 (SCA2, Appian TEST)

Origen: respuestas de negocio a los mensajes MEJ-01 a MEJ-06 del informe R49 (16/11/2026).

| Sesión | Alcance |
|---|---|
| R51-A (https://mapfre.devinenterprise.com/sessions/bcb53dda3ab2484ab177e51eaa2d720e) | MEJ-01/02: enhorabuena después de los tréboles, mensaje NO Club con enlace a Club Mapfre |
| R51-B (https://mapfre.devinenterprise.com/sessions/8cbd0988b8854d26bf8034b43aa64d62) | MEJ-03/04/05/06: textos y quitar la confirmación de Verti/vencimiento |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| SCA2_DetalleTareas | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055554 | R51-B | RESERVADO | v44→ | MEJ-03 textos tras completar acción |
| SCA2_AccionesAdministrativasPrincipal | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056429 | R51-B | RESERVADO | v25→ | MEJ-04 confirmMessage FINALIZAR |
| SCA2_AltaSolicitudPage | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055716 | R51-B | RESERVADO | v56→ | MEJ-05 texto validaciones |
| SCA2_ContraAnulacionOpciones | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056435 | R51-B | RESERVADO (solo línea del aviso SI24 Red Mapfre, ~1607) | v80→ | MEJ-06; R51-A: si lo necesitas, avísame aquí y guardo primero (cambio de 1 línea) |
| Constantes nuevas SCA2_TXT_MSG_MEJ* | (nuevas) | R51-B | RESERVADO | nuevas | textos MEJ-03/04/05/06 |
