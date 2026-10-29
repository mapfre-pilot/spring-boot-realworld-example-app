# Coordinación ronda 35 — espera de decisión / solicitud en curso, documentos imagen, observaciones tréboles

Origen: `docs/sca/56-ronda35-analisis-sca2.md`. Dos sesiones hijas con objetos y pólizas disjuntos. Pólizas: cada sesión usa SOLO su bloque de `pruebas/polizas/` y anota cada póliza usada en `pruebas/polizas/REGISTRO.md` (commit en `feature/sca` al terminar y, si la sesión es larga, también a mitad).

## R35-A — alta y espera de decisión (punto 1)
Objetos propios: `SCA2_AltaSolicitudPage`, `SCA2_AltaSolicitud*`, `SCA2_DetalleTareas`, `SCA2_DetalleSolicitud` (sólo lo necesario para RETOMAR/consulta), `SCA2_Buscador*`, `SCA2_construirContextoAlta`, `SCA2_textoEstadoSolicitud`, PM `SCA2 CMD CrearSolicitud`/`CMD Decidir` (sólo lectura salvo necesidad justificada), reglas de consulta de solicitudes en vuelo por póliza, constantes nuevas de espera (`SCA2_VAL_ESPERA_DECISION_*`).
Pólizas: `polizas/bloque-R35-A.txt` (mezcla Hogar `073…` y Autos `200…`).

## R35-B — documentos imagen y observaciones de tréboles (puntos 2 y 3)
Objetos propios: carga de documentos (`SCA2_AccionesAdministrativasDocumentacion`, `SCA2_altaDocumento*`, `SCA2_CMD GenerarPdf`/`ObtenerDocumentoGD` sólo lectura, constantes de extensiones), y tréboles/observaciones: `SCA2_ContraAnulacionSGO` (v2 de R34-A), `SCA2_ContraAnulacionModalRecuperacionPoliza` (v11), `SCA2_guardarEjecuArg*`, `SCA2_ContraAnulacionArgumentarioEstrategicas` (sólo si hace falta mostrar observaciones), vista de argumentos del Detalle.
Pólizas: `polizas/bloque-R35-B.txt`. Para TTQ Hogar usar pólizas `073…` del bloque.

## Reglas comunes
- Sólo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD. Solicitudes NUEVAS; no tocar solicitudes antiguas.
- Lectura viva → backup JSON → cambio mínimo → relectura/comparación; validación LCP + UI con usuario de pantalla; comparar con SCA cuando sea posible.
- Buenas prácticas ronda 32: nada de literales de negocio a pelo (constantes `SCA2_*`); textos nuevos de usuario en constante.
- «La aplicación tiene que funcionar perfecta»: regresión mínima al final (alta → CA → detalle → bandeja de errores) con una póliza nueva del bloque.
- Informe `docs/sca/pruebas/r35-*.md`, capturas en `docs/sca/img/`, REGISTRO.md actualizado, commit/push en `feature/sca`.

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| `SCA2_AccionesAdministrativasDocumentacion` (v6) | R35-B | EN EDICIÓN |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` (v11) | R35-B | EN EDICIÓN |
| Constantes nuevas `SCA2_TXT_EXTENSIONES_DOCUMENTO`, `SCA2_TXT_MSG_EXTENSION_DOCUMENTO`, `SCA2_TXT_OBS_TREBOLES_APLICADOS` | R35-B | CREACIÓN |
