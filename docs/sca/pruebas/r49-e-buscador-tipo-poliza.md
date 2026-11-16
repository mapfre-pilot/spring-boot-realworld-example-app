# R49-E · Error en el buscador de SCA2 al buscar por póliza

Entorno: **Appian TEST** (`mapfrespain-test`), MCP `appian-dev-mcp-c90b`, usuario de prueba JJGONZ2 (Red Mapfre). Nunca PRO. Solo se han modificado objetos de SCA2 (`SCA2_obtenerTipoPoliza` y `SCA2_Buscador`). La solicitud del analista (15789129) solo se ha consultado. Sin DDL ni DML.

## 1. Resumen

| # | Apartado | Resultado |
|---|---|---|
| 1 | Error `repeat` [line 5]: -1 en `sca2_obtenertipopoliza` (captura del usuario, 2002600074085 sin Tipo Póliza) | **Corregido.** La regla rellenaba con `repeat(13 - len(póliza), "0")`; con 14 o más caracteres (p. ej. la póliza con un espacio) la cantidad es negativa y Appian falla. `SCA2_obtenerTipoPoliza` v2→v3 |
| 2 | Error `and` [line 20] «Cannot compare … Null and … Number (Integer)» en `sca2_buscador` con Tipo Póliza sin elegir (encontrado al probar, y avisado después por el usuario al pulsar RECARGAR ARGUMENTO en el alta) | **Corregido.** La normalización añadida en v37 comparaba `local!eleccionPoliza = 1` con el desplegable vacío (nulo). `SCA2_Buscador` v37→v38 |
| 3 | Mismo riesgo al volver al placeholder del desplegable «Tipo Poliza» | **Corregido de forma preventiva.** `SCA2_Buscador` v38→v39 |
| 4 | Aviso «El texto no puede tener más de 13 caracteres» con un espacio al final | **Sin cambio, igual que SCA** (el campo tiene el mismo límite de 13). No bloquea la búsqueda. Duda D1 |
| 5 | SCA: error al «Volver» desde la consulta de la póliza | **Fuera de alcance (SCA no se toca).** Duda D2 |

## 2. Qué pasa en SCA2 y qué hace SCA

### 2.1 `repeat` -1 (captura del usuario)

- **SCA2 (antes):** `SCA2_obtenerTipoPoliza` v2 calcula los 3 primeros dígitos de la póliza rellenada a 13 con `repeat(13 - len(ri!numPoliza), "0")`, y lo mismo para `pnumpoliza`. Si llega un texto de 14 caracteres o más, `13 - len(...)` es negativo y `repeat()` da «-1». En la captura la póliza tiene 13 dígitos; con `SCA2_Buscador` v36 la póliza llegaba **tal cual** (sin `trim`), así que lo más probable es que llevara un espacio (inferencia: no se puede ver en la captura). Con `testRule` sobre v2: `"2002600074085 "` (14) y `"20026000740851"` (14) reproducen el error.
- **SCA:** `SCA_obtenerTipoPoliza` v7 tiene exactamente la misma fórmula y también falla con 14 caracteres (`testRule`: «at function 'repeat' [line 5]: -1»). Pero el buscador de SCA (`SCA_BuscarSolicitudClientePoliza` / `…Estrategicas`) hace antes `trim()` y rellena con ceros, así que en pantalla no le llega nunca un texto con espacios. SCA no se ha modificado.
- **Cambio:** `SCA2_obtenerTipoPoliza` **v2→v3**, en los dos sitios: `repeat(tointeger(max(0, 13 - len(ri!numPoliza))), "0")`. Hasta 13 caracteres el resultado es idéntico; con 14 o más ya no falla (no rellena). Backups: `backups-r49/SCA2_obtenerTipoPoliza_v2.sail` y `_v3.sail`.

### 2.2 `and` [line 20] con Tipo Póliza vacío

- **SCA2 (v37):** R49-B añadió (v36→v37) la normalización de SCA: `and(local!eleccionPoliza = 1, len(trim(local!fPoliza)) < 13)`. En SCA2 el desplegable arranca vacío (`local!eleccionPoliza` = nulo), y comparar nulo con un número da error en cuanto se escribe una póliza. Como el alta y el argumentario se pintan dentro de `SCA2_Buscador`, el error también salía al pulsar RECARGAR ARGUMENTO (aviso del usuario 13:50 CET, evaluation ID f1da1:b5092; en nuestra prueba c3586:c2ff8 al salir del campo). Captura: `capturas-r49/r49e-v37-error-and-linea20.png`.
- **SCA:** `local!eleccionPoliza` arranca con **1 (NO VIDA)**, así que sin tocar el desplegable trata la póliza como NO VIDA (relleno a 13).
- **Cambio:** `SCA2_Buscador` **v37→v38**, solo en `local!fPolizaNorm`: `a!defaultValue(local!eleccionPoliza, 1) = 1` y `… = 2`. Sin Tipo Póliza se normaliza como NO VIDA, igual que SCA. No cambia lo que se ve en pantalla (el desplegable sigue vacío al entrar, como antes en SCA2).

### 2.3 Volver al placeholder del desplegable

- **SCA2 (v38):** el `saveInto` del desplegable «Tipo Poliza» tenía dos `local!eleccionPoliza = 2` sin protección; si el usuario vuelve a «--- Seleccionar un valor ---» el valor es nulo.
- **SCA:** su desplegable tiene también `if(local!eleccionPoliza = 2, …)` en el `saveInto`. En la pantalla que se usó en SCA (`sca-site`, buscador por póliza) **no aparece** el desplegable Tipo Póliza, así que no se pudo comprobar si SCA falla ahí.
- **Cambio:** `SCA2_Buscador` **v38→v39**: `a!defaultValue(local!eleccionPoliza, 1) = 2` en los dos `a!save`. Con valor elegido, el resultado es el mismo; con nulo, no borra matrícula/bastidor (como NO VIDA). Backups: `backups-r49/SCA2_Buscador_v37.sail`, `_v38.sail`, `_v39.sail`.

## 3. Pruebas de la regla (`testRule`, v3)

Todas sin error. Hasta 13 caracteres, el resultado es igual al de v2 y al de `SCA_obtenerTipoPoliza`.

| Entrada | Longitud | Resultado v3 | v2 / SCA |
|---|---|---|---|
| `2002600074085` | 13 | NSE-Autos | igual |
| `2001900000562` | 13 | NSE-Autos | igual |
| `2002600074085 ` (espacio final) | 14 | NSE-Autos | **error -1** |
| `2002600074085` + tabulador | 14 | NSE-Autos | **error -1** |
| `20026000740851` | 14 | NSE-Autos | **error -1** |
| `200260007408512` | 15 | NSE-Autos | **error -1** |
| ` 2002600074085` (espacio delante) | 14 | Vida (la regla no hace `trim`; el buscador ya lo quita antes) | **error -1** |
| `730080003210` / `0730080003210` / `732400122940` | 12 / 13 / 12 | NSE-Hogar | igual |
| `0006000283` / `0000006000283` | 10 / 13 | Vida | igual |
| `0002729389242` / `0000006610576` / `0002729391736` | 13 | wAutemis | igual |
| `""` y nulo | 0 | Vida | igual |

## 4. Pruebas en pantalla (site SCA2, JJGONZ2, `SCA2_Buscador` v39)

Solicitud nueva: **15789149**, póliza **2002200150804** (Autos, 13 dígitos, bloque `polizas/bloque-R49-E.txt`, registrada en `polizas/REGISTRO.md`). La póliza de la captura (2002600074085) ya tenía la solicitud en curso 15789129 del analista, por eso no se usó para el alta.

| Caso | Pasos | Resultado |
|---|---|---|
| A | Buscar por > Póliza, sin Tipo Póliza, `2002600074085` | OK: devuelve 15789129 (solo consulta), sin error. `r49e-v39-A.png` |
| B | Tipo Póliza NO VIDA → VIDA → placeholder, con y sin póliza; VIDA → placeholder | OK: sin modal. `r49e-v39-B-con-poliza.png`, `r49e-v39-B-sin-poliza.png` |
| C | Sin Tipo Póliza, `2002200150804` (sin resultados) → ALTA SOLICITUD ANULACIÓN → GUARDAR (16/11/2026 13:59:26) → argumentario → RECARGAR ARGUMENTO 3 veces, esperando a que termine | OK: sin error de `and` ni ningún otro modal; 7 argumentos pendientes. Alta Finalizada, Contra Anulación Incompleta (no se ejecutaron argumentos). `r49e-v39-C-libre.png`, `r49e-v39-C-recarga1.png`, `r49e-v39-C-recarga3.png` |
| D | Volver al buscador, sin Tipo Póliza, `2002200150804` y `2002200150804 ` | OK: las dos devuelven 15789149; con el espacio sale el aviso de 13 caracteres (D1) pero se consulta sin error. `r49e-v39-D-13digitos.png`, `r49e-v39-D-espacio-final.png` |
| E | SCA (`sca-site`): buscar `2002600074085` y `2002200150804` | Las dos abren la consulta (mismo resultado que SCA2). Al «Volver» desde la primera, SCA muestra un error propio (D2). `r49e-v39-E-SCA-base.png`, `r49e-v39-E-SCA-nueva.png`, `r49e-v39-E-SCA-error-volver.png` |

Prueba previa con v38 (sin alta): sin Tipo Póliza con espacio delante/detrás → 15789129; `20026000740851` (14) → aviso de longitud y de póliza no válida, sin pantalla de error; VIDA + `0006000283` → «La póliza no es una póliza válida…», sin error; sin tipo + `730080003210` → normaliza a `0730080003210` y devuelve 15788861.

## 5. Dudas para el analista

- **D1.** Con un espacio al final, el campo «Número póliza» avisa «El texto no puede tener más de 13 caracteres» (límite de 13, igual que SCA), aunque la búsqueda funciona porque se quita el espacio. ¿Se deja así (como SCA) o se prefiere quitar el espacio al escribir para que no salga el aviso?
- **D2.** En SCA (no SCA2), al volver desde la consulta de la póliza 2002600074085 aparece «The save target must be a local variable… but instead was: 2002600074085» en `sca_datoscabecera` (`a!submitLink` [line 23], evaluation ID da31a:ccb79). No se ha tocado SCA; ¿se comunica al equipo de SCA?
- **D3.** En SCA el desplegable «Tipo Póliza» arranca en NO VIDA; en SCA2 arranca vacío (ahora vacío se trata como NO VIDA). ¿Queréis que SCA2 muestre NO VIDA ya seleccionado, como SCA? No se ha cambiado porque altera lo que ve el usuario.
