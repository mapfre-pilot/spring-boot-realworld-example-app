# Coordinación ronda 37 — respuestas del analista a la ronda 35 (`.jpeg`, observaciones en Retos/SVA)

Origen: respuestas del analista (29/10) a las dudas de `docs/sca/56-ronda35-analisis-sca2.md`. Una sola sesión hija (R37-A). Numeración: la ronda 36 es la observabilidad en Process HQ (`coordinacion-ronda36.md`).

## Decisiones del analista
1. Añadir `.jpeg` a las extensiones admitidas en la carga de documentos (también al DNI).
2. Observaciones de tréboles: se graban en el argumento sólo cuando, tras introducir el número y ACEPTAR, el servicio ha aplicado los tréboles en Club MAPFRE y en el candidato (igual que ya hace SCA). Probado por el analista con póliza TTQ: correcto («Se han aplicado 15 tréboles al cliente»).
3. Extender la observación a **Retos** y **SVA**, indicando en cada caso lo que se ha aplicado; sólo se graba cuando el servicio lo registra (Retos en su servicio; SVA en Club MAPFRE).
4. Anchura del visor ≈800 px: OK, no tocar.

## R37-A — objetos propios
`SCA2_TXT_EXTENSIONES_DOCUMENTO` (añadir JPEG), `SCA2_AccionesAdministrativasDocumentacion` (v7; sólo si hace falta por el mensaje del DNI), `SCA2_ContraAnulacionSGO` (v2), `SCA2_ContraAnulacionModalRetos` (v2), `SCA2_ContraAnulacionModalSVAEmail` (v2), `SCA2_ContraAnulacionModalRecuperacionPoliza` (v13), `SCA2_ContraAnulacionOpciones` (v61, sólo si hace falta pasar el dato aplicado), constantes nuevas `SCA2_TXT_OBS_RETOS_APLICADOS`, `SCA2_TXT_OBS_SVA_APLICADO` (y las que necesite). No tocar `SCA2_VisualizarDocumento*`, alta ni PMs.
Pólizas: `polizas/bloque-reserva-1.txt` (801-1200), anotando cada una en `polizas/REGISTRO.md`.

## Reglas comunes
- Sólo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD/Club MAPFRE. Solicitudes NUEVAS; no tocar solicitudes antiguas.
- Lectura viva → backup JSON → cambio mínimo → relectura/comparación; validación LCP + UI con usuario de pantalla; comparar con SCA (código) para el texto que graba en Retos/SVA.
- Textos de usuario y valores de negocio en constantes `SCA2_*`.
- Regresión mínima al final (alta → CA → documento → detalle) con póliza nueva del bloque.
- Informe `docs/sca/pruebas/r37-a-*.md`, capturas en `docs/sca/img/`, REGISTRO.md, commit/push en `feature/sca`.

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| `SCA2_TXT_EXTENSIONES_DOCUMENTO` (v1) | R37-A | EN EDICIÓN |
| `SCA2_TXT_MSG_EXTENSION_DOCUMENTO` (v1) | R37-A | EN EDICIÓN |
| `SCA2_AccionesAdministrativasDocumentacion` (v7) | R37-A | EN EDICIÓN (mensaje DNI a constante) |
| `SCA2_ContraAnulacionSGO` (v2) | R37-A | EN EDICIÓN |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` (v13) | R37-A | EN EDICIÓN |
| `SCA2_ContraAnulacionOpciones` (v61) | R37-A | EN EDICIÓN (dato aplicado) |
| `SCA2_ContraAnulacionModalRetos` (v2), `SCA2_ContraAnulacionModalSVAEmail` (v2) | R37-A | RESERVADO (sólo si hace falta) |
| Constantes nuevas `SCA2_TXT_OBS_RETOS_APLICADOS`, `SCA2_TXT_OBS_SVA_APLICADO`, `SCA2_TXT_MSG_EXTENSION_DNI` | R37-A | EN CREACIÓN |
