# R45-A — Vida: clave de producción, póliza sin estructura comercial, alta Vida y botón ACEPTAR

Sesión R45-A (puntos A1, A2 y A3 de `coordinacion-ronda45.md`). Entorno Appian TEST, aplicación SCA2. Fecha: 06/11/2026.
Herramientas: el MCP de Appian y la API LCP siguen caídos en TEST (endpoint 404, feature toggle `ae.dev-copilot-api.lcp-api-plugin` desactivado; comprobado una vez). Los cambios se hicieron con la Deployment API v2 (export → XML → ZIP parcial → inspect 0 errores / 0 warnings → import → reexport) y Appian Designer por navegador para evaluar reglas. Pruebas UI con JJGONZ2 (SSO Mapfre NO PRO).

## 1. Resumen

| Punto | Resultado |
|---|---|
| A1 Póliza sin estructura comercial | **OK.** Sin parte izquierda: aviso literal «Póliza sin estructura comercial. No es posible realizar la solicitud.» y GUARDAR bloqueado aunque se rellene el formulario. Sin parte derecha se puede continuar (no se encontró póliza del bloque con ese caso; verificado por código) |
| A2 Clave de producción | **OK** (con duda D1). `0006000328`, `0006000397`, `0006059601`: «184720372 / 0035099» en cabecera, y la misma parte derecha (`0035099`) va a CORE |
| Alta Vida completa | **KO (CORE).** Tres altas nuevas con clave, estructura comercial y prima correctas: CORE sigue respondiendo `4004 Datos insuficientes` en `generarStudAnul`. Dato pendiente: `numApli` (vacío en Vida, sin fuente). Ver §5 |
| A3 ACEPTAR doble clic | **No verificable en Vida.** Es el mismo botón que R44 protegió (`local!aceptarPulsado`); ninguna alta Vida llega al mensaje de éxito |

## 2. Tabla de casos

ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución
---|---|---|---|---|---|---|---|---
A1-1 | Vida sin productor válido (solo `producerCode` "1" o vacío): 0006059023 | Aviso «Póliza sin estructura comercial. No es posible realizar la solicitud.» y alta bloqueada | Cabecera «Clave producción /», título «Póliza sin estructura comercial.» y texto literal; GUARDAR deshabilitado incluso con Motivo DECISION DE CLIENTE / ASEGURADO NO DESEA SEGURO / COMPROMISOS | OK | — (bloqueada) | — | SCA2 › ALTA SOLICITUD ANULACIÓN › VIDA › 0006059023 › rellenar motivo/detalle/causa | `local!sinEstructuraVida` en `SCA2_AltaSolicitudPage` (sin `codAgtVida`) |
A1-2 | Misma póliza en SCA | Comparar | SCA: «La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.» | No comparable | — | — | SCA › Alta solicitud anulación › 0006059023 | SCA rechaza las Vida en la validación previa (igual que en R43) |
A1-3 | Vida con parte izquierda y sin parte derecha | Se puede continuar | No hay póliza así entre las escaneadas del bloque (o tienen las dos partes o ninguna). Por código: el bloqueo solo mira la parte izquierda (`codAgtVida`); sin `codAgente` la clave cae a `SCA2_consultaClaveVida` y GUARDAR no se bloquea | OK (código) | — | — | Escaneo con `SCA2_getCodAgenteVida` + `SCA2_consultarEstructuraComercial` en Designer | — |
A2-1 | Clave completa: 0006000328 (producerCode 18472, salesOfficeCode 0372) | «18472‖0372 / codAgente» | «184720372 / 0035099»; sin aviso; GUARDAR habilitado | OK (ver D1) | — | — | Alta Vida › cabecera › formulario | Integración enviaba `372` (ORA-20004); ahora `text(..., "0000")` |
A2-2 | Productor "1" seguido de productor válido: 0006059703 | Saltar "1" | Productores `1,95900`, oficina 0728 → `959000728 / 5316255` (evaluado en Designer, sin alta) | OK | — | — | Designer › `SCA2_getCodAgenteVida` | `producerCode` sale de `producersData[1].producerCommissions` y `salesOfficeCode` de `producersData[1]`: mismo productor |
A2-3 | Servicio estructurasComerciales (cía 3, 18472, 0372) | `codAgente` 0035099 | `codAgente 0035099, codDgt 014, codDt 03, codOficinaDirecta 0372, codClaseAgt 28` | OK | — | — | Designer › `SCA2_consultarEstructuraComercial(3, 372, 18472)` | `fecValidez`: la integración existente no lo envía y el servicio responde sin él |
ALT-1 | Alta Vida 0006000328 (clave corregida, contexto antiguo) | Solicitud creada | `ALTA_ERROR - Datos insuficientes para la operacion (paso: generarStudAnul)` | KO | PDTE-269184418 | — | DECISION DE CLIENTE / ASEGURADO NO DESEA SEGURO / COMPROMISOS, A VENCIMIENTO › GUARDAR › ACEPTAR | Vida enviaba estructura comercial vacía |
ALT-2 | Alta Vida 0006000397 con estructura comercial de Vida | Solicitud creada | Mismo 4004 | KO | PDTE-748230 | — | Igual que ALT-1 | Contexto: DGT 014 / subcentral 03 / oficina 0372, clave 0035099, `prima` nula |
ALT-3 | Alta Vida 0006059601 con estructura y prima de Vida | Solicitud creada | Mismo 4004 | KO | PDTE-269184469 | — | Igual que ALT-1 | Contexto: prima 182.51, DGT 014/03/0372, clave 0035099, cía 3, ramo 101, producto 00593, `codInt` informado. Solo queda `numApli` vacío. Se para (3 fallos) |
A3-1 | ACEPTAR del mensaje «Su solicitud se ha generado correctamente…» | Deshabilitado tras el 1.er clic, sin duplicados | Ninguna alta Vida llega al mensaje | No probado | — | — | — | Depende de que CORE acepte el alta Vida (§5) |
A3-2 | ¿Es el mismo ACEPTAR que R44? | Confirmar | Sí: es el botón con `local!aceptarPulsado` (comentario «R44-A (analista #1): deshabilitado tras el primer clic, sin dobles envíos»). Los otros ACEPTAR de la página son los del popup de confirmación previo | OK (código) | — | — | Lectura del XML de `SCA2_AltaSolicitudPage` | R44 ya lo cubre; el caso del analista (`r45-analista-09.png`) es el mismo botón |

## 3. Objetos modificados

Versiones según el historial que devuelve la exportación (antes → después). `SCA2_AltaSolicitudPage` llevaba v50 tras R44.

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| Integración `SCA2_consultaEstructuraComercialVida` | `c0fcfbfa-073c-49e2-b5c4-a9032942109b` | v2 → v3 | `codOficinaDirecta` con `text(ri!codOficinaDirecta, "0000")` (conserva los ceros: `372` → `0372`) |
| ER `SCA2_obtenerDatosCabeceraLive` (parte Vida) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603393` | v1 → v2 | Clave Vida = `producerCode` (sin "1") ‖ `salesOfficeCode` + « / » + `codAgente` de estructurasComerciales; sin productor válido la parte izquierda queda vacía |
| IF `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v50 → v51 | `local!sinEstructuraVida`, aviso A1 y GUARDAR deshabilitado. Se conserva el ACEPTAR de R44 |
| ER `SCA2_construirContextoAlta` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014` | v4 → v6 | v5: una sola llamada `local!estructuraVida` → `codClaveProduccion` = `codAgente` y `estructComercial` Vida = {`codDgt`, `codDt`, `codOficinaDirecta`}. v6: `prima` Vida = `premiumData.periodicContribution.premiumAmn` × frecuencia (igual que «Prima actual» de la cabecera). Ramas Autos/Hogar sin cambios |
| Constante `SCA2_TXT_POLIZA_SIN_ESTRUCTURA_TITULO` (nueva) | `_a-0000f0a8-ce0f-8000-9d4b-011c48011c48_5680145` | — → v1 | «Póliza sin estructura comercial.» |
| Constante `SCA2_TXT_POLIZA_SIN_ESTRUCTURA_COMERCIAL` (nueva) | `_a-0000f0a8-ce0f-8000-9d4b-011c48011c48_5680187` | — → v1 | «Póliza sin estructura comercial. No es posible realizar la solicitud.» |

Sin cambios (solo lectura): `SCA2_getCodAgenteVida`, `SCA2_consultarEstructuraComercial`, `SCA2_PreGenerarStudAnul`, `SCA2_consultaClaveVida`. No se tocaron PMs ni objetos de SCA/SCAC/CORE. Backups en `backups-r45/r45-a-*.xml`.

## 4. Clave de producción (A2) y duda D1

- Parte izquierda: `producersData[1].producerCommissions[*].producerCode` (primer valor distinto de "1", regla `SCA2_getCodAgenteVida`) ‖ `producersData[1].salesOfficeCode` (texto, con ceros).
- Parte derecha: `codAgente` de `estructurasComerciales?codCompania=3&codOficinaDirecta=<oficina>&codAgenteVida=<productor>`. Ya existía la integración SCA2 (`SCA2_consultaEstructuraComercialVida`); no hizo falta crear otra.
- Causa del fallo anterior: la oficina viajaba como número (`372`) y el servicio devolvía `ORA-20004 Estructura comercial no existe`; con `0372` devuelve `0035099`.
- `fecValidez`: la integración no lo envía y el servicio responde sin él. No se añadió para no cambiar el contrato.
- A CORE (`codClaveProduccion`) va solo la parte derecha (`0035099`, 7 dígitos), como en las Vida que SCA dio de alta en TEST (R43: 15787947, 15787948). La parte izquierda es solo de presentación.

**D1 (formato):** el analista escribe «la parte izquierda del campo lleva 18472 y 0372 concatenado» (= `184720372`) pero pone como esperado `18420372`, que no es esa concatenación (falta el `7`). CORE no guarda la parte izquierda, así que no hay evidencia en datos. Implementado `184720372`. **Pendiente de confirmar.**

## 5. Alta Vida: 4004 en generarStudAnul

Contexto que llega a `SCA2_PreGenerarStudAnul` para 0006059601 (evaluado en Designer con `SCA2_construirContextoAlta` v6):

| Campo `generarStudAnul` | R43 (antes) | R45-A (ahora) | SCA |
|---|---|---|---|
| `codCompania` / `codRamo` / producto | 3 / 101 / 00593 | 3 / 101 / 00593 | Igual (R43) |
| `codClaveProduccion` | Clave alternativa o codAgente | `0035099` (codAgente) | codAgente, 7 dígitos |
| `codDGT` / `codSubcentral` / `codOfiDirecta` | vacíos | 014 / 03 / 0372 | vacíos (SCA los saca de `pObtenerPolizaFecha`, que no existe para Vida) |
| `prima` | nula | 182.51 | nula |
| `numApli` | vacío | vacío | vacío |
| `codInt`, motivo, detalle, causa, catalogación, canal | informados | informados | igual |
| `codCiaUsuario` | 41 (null probado en R43, sin efecto) | 41 | null |

Con clave, estructura comercial y prima informadas CORE sigue con 4004. El único campo de la cabecera de la solicitud que sigue vacío es `numApli`, y la consulta de póliza Vida no da un dato equivalente. SCA no es comparable: rechaza las pólizas Vida en la validación previa (captura `r45-a-1-sca-vida-no-valida.png`). La tabla `SCA2 Error` no se pudo leer con el usuario técnico (`queryRecordType` devuelve 0 filas), así que no se pudo ver la respuesta completa de CORE. Se pararon las altas tras 3 fallos: no se ve otro cambio que no requiera una decisión de CORE.

Las filas PDTE de las tres altas quedan en `SCA2 Solicitud` (bandeja de errores), como cualquier error de alta. No se relanzaron.

## 6. Capturas

- `../img/r45-a-1-sin-estructura-sca2.png` — A1: aviso en SCA2 (0006059023).
- `../img/r45-a-1-sin-estructura-guardar-bloqueado.png` — A1: formulario relleno y GUARDAR deshabilitado.
- `../img/r45-a-1-sca-vida-no-valida.png` — SCA con la misma póliza (no comparable).
- `../img/r45-a-2-clave-completa-0328.png` — A2: «184720372 / 0035099».
- `../img/r45-a-2-formulario-0397.png` — A2: formulario de 0006000397 listo para GUARDAR.
- `../img/r45-a-3-alta-4004-0328.png` — alta 0006000328, 4004.
- `../img/r45-a-3-alta-4004-9601-prima-estructura.png` — alta 0006059601 con estructura y prima, 4004.
- Antes: `../img/r45-analista-10.png`, `r45-analista-11.png`, `r45-analista-12.png`.

## 7. Dudas para el analista

1. **D1:** ¿la parte izquierda es `184720372` (concatenación literal, implementado) o `18420372` como pone el ejemplo? Si es lo segundo, ¿qué regla quita el `7`?
2. **Alta Vida en CORE:** con cía 3, ramo 101, producto, clave `codAgente`, estructura DGT/DT/oficina, prima y `codInt`, CORE sigue con 4004. ¿Qué dato exige CORE para Vida? ¿`numApli` (qué valor para Vida)? ¿Se puede obtener la petición de un alta Vida correcta (p. ej. la 15788717 de R43) o el detalle del 4004 en el log de CORE?
3. **`fecValidez`:** ¿debe enviarse explícitamente (y con qué fecha: hoy, efecto o anulación)? Hoy el servicio responde sin él.
4. **Estructura comercial y prima en Vida:** se envían ahora a CORE (antes vacías, también en SCA). Si CORE no las quiere para Vida, se pueden quitar (cambio solo en `SCA2_construirContextoAlta`).

## 8. Pendientes

- Alta Vida completa y A3 (doble clic en el ACEPTAR del mensaje de éxito) en Vida: dependen de la duda 2.
- Caso «sin parte derecha» en UI: no hay póliza así en lo escaneado del bloque.
- Primera gestión y 2.ª apertura de una solicitud Vida.
