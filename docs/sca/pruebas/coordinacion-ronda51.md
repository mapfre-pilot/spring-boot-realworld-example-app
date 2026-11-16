# Coordinación ronda 51 (SCA2, Appian TEST)

Origen: respuestas de negocio a los mensajes MEJ-01 a MEJ-06 del informe R49 (16/11/2026).

| Sesión | Alcance |
|---|---|
| R51-A (https://mapfre.devinenterprise.com/sessions/bcb53dda3ab2484ab177e51eaa2d720e) | MEJ-01/02: enhorabuena después de los tréboles, mensaje NO Club con enlace a Club Mapfre |
| R51-B (https://mapfre.devinenterprise.com/sessions/8cbd0988b8854d26bf8034b43aa64d62) | MEJ-03/04/05/06: textos y quitar la confirmación de Verti/vencimiento |

## Objetos en edición

| Objeto | UUID | Sesión | Estado | Versión antes→después | Nota |
|---|---|---|---|---|---|
| SCA2_DetalleTareas | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055554 | R51-B | LIBERADO | v44→v45 | MEJ-03 textos tras completar acción |
| SCA2_AccionesAdministrativasPrincipal | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056429 | R51-B | LIBERADO | v25→v26 | MEJ-04 confirmMessage FINALIZAR |
| SCA2_AltaSolicitudPage | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055716 | R51-B | LIBERADO | v56→v57 | MEJ-05 texto validaciones |
| SCA2_ContraAnulacionOpciones | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056435 | R51-B | LIBERADO | v80→v81 | MEJ-06; R51-A: si lo necesitas, avísame aquí y guardo primero (cambio de 1 línea) |
| Constantes nuevas SCA2_TXT_MSG_ALTA_VALIDACIONES_OK, SCA2_TXT_MSG_ACUERDO_ESPECIAL_SI24, SCA2_TXT_MSG_GUARDADO_CA_NIVEL2, SCA2_TXT_MSG_GUARDADO_SIN_SIGUIENTE, SCA2_TXT_MSG_ACCADM_SIN_DOCUMENTACION, SCA2_TXT_MSG_ACCADM_SIN_COMPRAVENTA | (nuevas) | R51-B | LIBERADO | nuevas v1 | textos MEJ-03/04/05/06 |
| SCA2_ContraAnulacionSGO | _a-0000f069-4f37-8000-9cc8-011c48011c48_20060093 | R51-A | LIBERADO (guardado; reexport = enviado) | v5→v6 | MEJ-01/02: tréboles (Club+TTQ) al ACEPTAR la pantalla de tréboles; mensaje NO Club con enlace |
| Constantes nuevas SCA2_TXT_TREBOLES_NO_CLUB_MAPFRE, SCA2_TXT_ENLACE_CLUB_MAPFRE, SCA2_TXT_CONCEPTO_URL_ALTA_CLUB_MAPFRE | _a-0000f0b4-5b71-8000-9d56-011c48011c48_5750096 / _5750102 / _5750108 | R51-A | LIBERADO | nuevas v1 | MEJ-02 |

R51-A: no necesita tocar `SCA2_ContraAnulacionOpciones` ni `SCA2_ContraAnulacionModalRecuperacionPoliza` (solo lectura).
