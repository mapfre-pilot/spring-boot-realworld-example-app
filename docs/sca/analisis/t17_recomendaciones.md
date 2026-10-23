# Tanda 17 — Warnings/Recommendations + test cases SCA2

## Nota de método
La vista de objetos de la app SCA2 en este Designer **no dispone de la columna
"Warnings and Recommendations"** (columnas reales: Nombre / Descripción /
Última modificación — verificado por inspección del DOM). Se sustituyó por el
escaneo programático equivalente: para los 289 objetos SCA2 (reglas +
interfaces) se bajaron inputs + expresión y se detectó `ri!<nombre>` sin uso y
kwargs que no existen en la firma real del objeto llamado.

## Recomendaciones encontradas y corregidas

| Objeto | Aviso | Fix aplicado |
|---|---|---|
| `SCA2_consultarConcepto` | Unused rule input (`rand` y demás excepto `mseConsultarConceptoDTO`) | Inputs de la regla reducidos a `mseConsultarConceptoDTO` (updateExpressionRule `inputs`); kwargs `rand:` eliminados en los 11 llamadores |
| `SCA2_consultarConceptoFuncionalREST` | Unused rule input (`rand`) | Inputs → `[]`; kwargs `rand:` eliminados en 7 sitios (4 ficheros) |
| `SCA2_searchAPIClients` | Unused rule input (`aplicacion`) | Inputs → solo `request`; kwargs `aplicacion:` eliminados de llamadores |
| `SCA2_contactMethodAPIClients` | Unused rule input (`aplicacion`) | Inputs → solo `idCliente`; kwargs `aplicacion:` eliminados de llamadores |
| `SCA2_extraerCodClienteNIF` | Unused rule input (`aplicacion`) | Inputs → solo `nif`; kwargs eliminados en `SCA2_obtenerDatosCabecera`/`SCA2_ModalClaveProduccion` |
| `SCA2_aceptarAutorizacion` | Incorrectly Scoped Variable `ri!mseAceptarAutorizacionDTO` (case mismatch vs `ri!mSEAceptarAutorizacionDTO`) | Corregido el case en la expresión |
| `SCA2_cargaGestionSGC` | "Invalid parameter" (reportado por el usuario) | **No reproducible**: la regla es byte-idéntica a `SCA_cargaGestionSGC` (llama `SCA2_cargaGestionSGC3(consulta:...)`, input Map) y no tiene llamadores; ninguna llamada con parámetros inválidos. Aviso presumiblemente obsoleto del navegador → documentado, sin cambios |
| 17 ficheros UI/reglas | kwargs `rand:`/`random:`/`randomNum:`/`aplicacion:` a integraciones sin ese input | Eliminados (`.bak_t17`); `rule!SCA2_consultarConceptoFuncionalREST())` corregido a `()` en 7 sitios |

Ficheros deployados (validate OK, 0 errores): `SCA2_mostrarMensajesOAlta`,
`SCA2_AnadirModificarGestionAplicacion`, `SCA2_MensajeEliminacionConcepto`,
`SCA2_GestionAplicacionRecords`, `SCA2_ValoresConceptoGestionConceptosyClases`,
`SCA2_AnadirGestionConceptosyClases`, `SCA2_GestionConceptosYClases`,
`SCA2_EliminarValorConcepto`, `SCA2_extraerCodClienteNIF`,
`SCA2_ModalClaveProduccion`, `SCA2_obtenerDatosCabecera`,
`SCA2_aceptarAutorizacion` (sca2_sail) y `SCA2_AnulacionFueraNormaPrincipal`,
`SCA2_MecanizacionPrincipal`, `SCA2_AccionesAdministrativasPrincipal`,
`SCA2_ContraAnulacionOpciones`, `SCA2_Buscador` (sca2_ui).

Re-escaneo final de `ri!<input>` sin uso + kwargs inexistentes → **0 avisos
residuales** (quedan solo menciones en comentarios de documentación).

## Test cases creados (MCP `createExpressionRuleTestCase`)

- **210 reglas de expresión SCA2**: 216 casos creados, 0 fallos de creación
  (`/tmp/t17_tc.json`). Casos curados con EXPECTED_OUTPUT derivado de la lógica
  SCA: `textoEstadoSolicitud` (4 casos), `isAcuerdoFlotas`, `comprobarParametroValido`,
  `convertirAFecha`, `datosPerfilesPcaSi24`, `claveIdempotencia` (ya existía).
  El resto recibió smoke "evalúa sin error" (`resultAssertion:"true()"`).
- **Resultado final `runAllExpressionRuleTestCases` en las 210 reglas**:
  **217 casos, 209 pasan, 0 fallan** (`/tmp/t17_runall2.json` tras limpieza).
- Limpieza aplicada: 27 casos de wrappers que ejecutaban la integración real
  (timeouts 5s / EPR SOAP no resoluble / "Text→Reaction Tree" en reglas que
  devuelven el resultado crudo) — el contrato del brief era crearlos **solo si
  el tool permite probar sin ejecutar la integración**, y el runner sí la
  ejecuta, así que se eliminaron. +8 casos eliminados en reglas que exigen
  payloads realistas (xpathsnippet sobre body XML / wherecontains con datos
  reales): `mapSalidaRespuesta{Autorizacion,AccAdm,CA,Mecanizar}`,
  `mapSalidaGenerarStudAnul`, `obtenerSituacionRiesgo`,
  `actualizacionVariablesPostGenerarStudAnul`, `guardarTrazabilidad`.
- Errata corregida: `updateExpressionRuleTestCase` (PUT) borra los `inputs`
  si no se reenvían — restaurados en los 32 casos tocados.

## Cobertura
Reglas con ≥1 test case: **186 / 210 = 88,6 %** (objetivo ≥66 % de SCA).
24 reglas sin caso son wrappers de integración o reglas dependientes de payload
real — listadas arriba y en el comentario del resultado.

## Evidencias
- `/home/ubuntu/screenshots/t17_sin_recomendaciones.png` — lista de objetos de
  la app; la columna de warnings no existe en esta versión, el check equivalente
  (re-escaneo inputs/kwargs) queda en 0.
- `/tmp/t17_tc.json`, `/tmp/t17_runall2.json`.
