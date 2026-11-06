# R45-A — Vida: clave de producción, póliza sin estructura comercial, alta Vida y botón ACEPTAR

Sesión R45-A (puntos A1, A2 y A3 de `coordinacion-ronda45.md`). Entorno Appian TEST, aplicación SCA2. Fecha: 06/11/2026.
Herramientas: el MCP de Appian y la API LCP siguen caídos en TEST (endpoint 404, feature toggle `ae.dev-copilot-api.lcp-api-plugin` desactivado; comprobado una vez). Los cambios se hicieron con la Deployment API v2 (export → XML → ZIP parcial → inspect 0 errores / 0 warnings → import → reexport) y Appian Designer por navegador para evaluar reglas. Pruebas UI con JJGONZ2 (SSO Mapfre NO PRO).

## 1. Resumen

| Punto | Resultado |
|---|---|
| A1 Póliza sin estructura comercial | **OK.** Sin parte izquierda: aviso literal «Póliza sin estructura comercial. No es posible realizar la solicitud.» y GUARDAR bloqueado aunque se rellene el formulario. Sin parte derecha se puede continuar (no se encontró póliza del bloque con ese caso; verificado por código) |
| A2 Clave de producción | **OK** (con duda D1). `0006000328`, `0006000397`, `0006059601`: «184720372 / 0035099» en cabecera, y la misma parte derecha (`0035099`) va a CORE |
| Alta Vida completa | **KO (CORE).** Tres altas nuevas con clave, estructura comercial y prima correctas: CORE sigue respondiendo `4004 Datos insuficientes` en `generarStudAnul`. Dato pendiente: `numApli` (vacío en Vida, sin fuente). Ver §5. Fase 2: la solicitud Vida histórica 15788717 apunta a `codCiaUsuario` 3; probado en una alta (0006058198) → mismo 4004, revertido. Ver §10 |
| A3 ACEPTAR doble clic | **Fase 2 (Hogar/Autos): sin duplicados, pero el botón no se ve deshabilitado.** Hogar 15788809 y Autos 15788813: una sola solicitud por póliza en CORE y en `SCA2 Solicitud`. Tras el primer clic ACEPTAR sigue con aspecto y atributo habilitados (`disabled` false a 250 ms) hasta que se abre la gestión. SCA (15788814) se comporta igual con su OK. En Vida sigue sin poder probarse. Ver §9 |

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
A3-3 | Hogar SCA2 0731580218520: doble clic rápido en ACEPTAR del mensaje de éxito | ACEPTAR deshabilitado tras el 1.er clic; una sola solicitud e instancia | Mensaje «Su solicitud se ha generado correctamente. Acepte para abrir la gestión correspondiente.» Antes: habilitado. Tras `dblclick` (60 ms entre clics), a 250 ms: `disabled` false, mismo color con foco; luego abre la gestión CONTRA ANULACIÓN. CORE: una solicitud (15788809). `SCA2 Solicitud`: una fila, `procesoActivo` CONTRAANULAR | KO (aspecto) / OK (sin duplicados) | 15788809 | Una sola (fila única en `SCA2 Solicitud` con CONTRAANULAR; el id de la instancia no se pudo leer sin acceso a la monitorización de procesos) | Alta DECISION DE CLIENTE / ASEGURADO NO DESEA SEGURO / COMPROMISOS, A VENCIMIENTO › GUARDAR › ACEPTAR (popup) › mensaje › doble clic ACEPTAR › consulta CORE (`SCA2_consultarSolicitudes`) y `SCA2 Solicitud` | `local!aceptarPulsado` se guarda en el `saveInto` del primer clic, pero el `disabled` solo se repinta cuando vuelve la evaluación del servidor, y en ese momento la página ya navega a la gestión. Mientras tanto Appian muestra el botón «Cargando» y no lanza el segundo envío: por eso no hay duplicado. Ver D5
A3-4 | Autos SCA2 2002300352194: igual que A3-3 | Igual | Igual que A3-3: mensaje de éxito, ACEPTAR no se ve deshabilitado, abre la gestión. CORE: una solicitud (15788813); `SCA2 Solicitud`: una fila CONTRAANULAR | KO (aspecto) / OK (sin duplicados) | 15788813 | Una sola (como A3-3) | Igual que A3-3 (clave 0500694) | Igual que A3-3
A3-5 | Autos SCA2 2002500072375 (flujo interrumpido) | — | El script se cortó tras el ACEPTAR del popup; la solicitud se creó (una sola en CORE y en `SCA2 Solicitud`). El doble clic no se midió | No cuenta | 15788810 | Una sola | Alta como A3-3 | Se repitió con 2002300352194 (A3-4)
A3-6 | SCA Hogar 0732400243168: doble clic en OK del mensaje de éxito | Comparar | Mensaje «Su solicitud se ha generado correctamente. Se le va a redirigir a la acción correspondiente» con una tarjeta enlazada «OK» (no es un botón). Tras el doble clic no se deshabilita; aparece «Acción completada» y abre la gestión. CORE: una solicitud (15788814) | Igual que SCA2 | 15788814 | No leída | Mismo alta en `/sca-site` › doble clic OK › consulta CORE | SCA tampoco deshabilita; no duplica
VID-1 | Origen de la 15788717 (Vida 0005912432, 03/11 13:34) | Saber quién y por qué camino | CORE: usuario JJGONZ2 (CE_RM / CE_RM_OFICINA), canal 1, origen 2, contacto 1, catalogación 2, causa 30 / motivo 1 / detalle 9, acción 6098, agente 5324209. No está en `SCA2 Solicitud` (ni en las tablas de SCA, R43). Canal y origen son los mismos que ponen SCA2 y SCA (15788809/13/14), así que no distinguen el camino | No concluyente | 15788717 (solo lectura) | Ninguna en SCA2 | `SCA2_consultarCabeceraSolicitud`, `SCA2_consultarDetalleSolicitud`, `queryRecordType` de `SCA2 Solicitud` por `idSolicitud` | Se creó con JJGONZ2 fuera de SCA2 y de SCA. Ver §10
VID-2 | Campo a campo 15788717 vs altas SCA2 | Encontrar el dato que falta | Única diferencia de alta: la cola de la descripción CORE `…|JJGONZ2 RED MAPFRE|2|3` (15788717) frente a `…|2|41` (todas las de SCA2 y SCA). `41` es el `codCiaUsuario` que envían SCA2 y SCA; `3` es la compañía de Vida | Pista | — | — | Comparación de cabecera y detalle | Inferencia: 15788717 se dio de alta con `codCiaUsuario` 3
VID-3 | Alta Vida 0006058198 con `codCiaUsuario` = 3 | Solicitud creada | `ALTA_ERROR - Datos insuficientes para la operacion (paso: generarStudAnul)` | KO | PDTE-13377305 | — | `SCA2_construirContextoAlta` v7 (`codCiaUsuario` = `SCA2_INT_COD_CIA_VIDA` en Vida) › alta como ALT-1 | `codCiaUsuario` no es el dato que falta. Revertido (definición = v6). No se hizo la 2.ª alta: el resultado era el mismo con un dato que CORE guarda tal cual
VID-4 | Cuerpo completo de la respuesta 4004 | Leer qué campo falta | La UI solo muestra «Datos insuficientes para la operacion»; la tabla `SCA2 Error` no devuelve filas al usuario técnico y no hay acceso al log de la integración (MCP/LCP caídos) | No obtenido | — | — | Bandeja de errores, `queryRecordType` de `SCA2 Error` | Pedir a CORE el log de `generarStudAnul` de PDTE-13377305 / PDTE-269184469

## 3. Objetos modificados

Versiones según el historial que devuelve la exportación (antes → después). `SCA2_AltaSolicitudPage` llevaba v50 tras R44.

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| Integración `SCA2_consultaEstructuraComercialVida` | `c0fcfbfa-073c-49e2-b5c4-a9032942109b` | v2 → v3 | `codOficinaDirecta` con `text(ri!codOficinaDirecta, "0000")` (conserva los ceros: `372` → `0372`) |
| ER `SCA2_obtenerDatosCabeceraLive` (parte Vida) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603393` | v1 → v2 | Clave Vida = `producerCode` (sin "1") ‖ `salesOfficeCode` + « / » + `codAgente` de estructurasComerciales; sin productor válido la parte izquierda queda vacía |
| IF `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v50 → v51 | `local!sinEstructuraVida`, aviso A1 y GUARDAR deshabilitado. Se conserva el ACEPTAR de R44 |
| ER `SCA2_construirContextoAlta` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014` | v4 → v6 | v5: una sola llamada `local!estructuraVida` → `codClaveProduccion` = `codAgente` y `estructComercial` Vida = {`codDgt`, `codDt`, `codOficinaDirecta`}. v6: `prima` Vida = `premiumData.periodicContribution.premiumAmn` × frecuencia (igual que «Prima actual» de la cabecera). Ramas Autos/Hogar sin cambios |
| ER `SCA2_construirContextoAlta` (fase 2) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014` | v6 → v7 → v8 | v7: `codCiaUsuario` = `SCA2_INT_COD_CIA_VIDA` (3) solo en Vida (VID-3). 4004 igual, **revertido**: v8 tiene la misma definición que v6 (comparado en el reexport; el historial del export lista la versión de la reversión). Backup `backups-r45/r45-a-fase2-SCA2_construirContextoAlta-v6-*.xml` |
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
- `../img/r45-a-4-a3-sca2-hogar-antes.png` / `-despues.png` / `-gestion.png` — A3 Hogar SCA2 (0731580218520): antes del clic, 250 ms después del doble clic (sigue habilitado) y gestión abierta.
- `../img/r45-a-5-a3-sca2-autos-antes.png` / `-despues.png` / `-gestion.png` — A3 Autos SCA2 (2002300352194), igual.
- `../img/r45-a-6-a3-sca-hogar-antes.png` / `-despues.png` / `-gestion.png` — SCA (0732400243168): OK antes, «Acción completada» tras el doble clic y gestión.
- `../img/r45-a-7-alta-vida-cia3-4004-8198.png` — alta Vida 0006058198 con `codCiaUsuario` 3: mismo 4004.
- Antes: `../img/r45-analista-10.png`, `r45-analista-11.png`, `r45-analista-12.png`.

## 7. Dudas para el analista

1. **D1:** ¿la parte izquierda es `184720372` (concatenación literal, implementado) o `18420372` como pone el ejemplo? Si es lo segundo, ¿qué regla quita el `7`?
2. **Alta Vida en CORE:** con cía 3, ramo 101, producto, clave `codAgente`, estructura DGT/DT/oficina, prima y `codInt`, CORE sigue con 4004. ¿Qué dato exige CORE para Vida? ¿`numApli` (qué valor para Vida)? ¿Se puede obtener la petición de un alta Vida correcta (p. ej. la 15788717 de R43) o el detalle del 4004 en el log de CORE?
3. **`fecValidez`:** ¿debe enviarse explícitamente (y con qué fecha: hoy, efecto o anulación)? Hoy el servicio responde sin él.
4. **Estructura comercial y prima en Vida:** se envían ahora a CORE (antes vacías, también en SCA). Si CORE no las quiere para Vida, se pueden quitar (cambio solo en `SCA2_construirContextoAlta`).
5. **D5 – A3:** en SCA2 (y en SCA) el botón no se ve deshabilitado tras el primer clic, aunque no se duplica nada (Appian lo deja en «Cargando» hasta navegar). ¿Basta con que no haya duplicados o se quiere además un cambio visual inmediato? Lo segundo no se puede hacer en SAIL antes de la respuesta del servidor; habría que separar el clic (marcar) de la navegación, lo que añade un paso.

## 8. Pendientes

- Alta Vida completa y A3 en Vida: dependen de la duda 2 (log de CORE del 4004).
- A3: decisión D5.
- Caso «sin parte derecha» en UI: no hay póliza así en lo escaneado del bloque.
- Primera gestión y 2.ª apertura de una solicitud Vida.

## 9. A3 con Hogar y Autos (fase 2)

Pólizas del bloque `polizas/bloque-R45-A2.txt` (líneas 3601-3640 del CSV del analista). Usuario JJGONZ2.

- SCA2 llega al mensaje de éxito con Hogar (15788809, 16 s tras ACEPTAR del popup) y Autos (15788813).
- Doble clic rápido (`dblclick`, 60 ms) en ACEPTAR: a 250 ms el botón sigue con `disabled` false y el mismo aspecto; después abre la gestión. Sin segundo envío.
- Duplicados: `SCA2_consultarSolicitudes` (CORE) devuelve **una** solicitud para cada póliza (0731580218520 → 15788809, 2002300352194 → 15788813, 2002500072375 → 15788810, 0732400243168 → 15788814) y `SCA2 Solicitud` una fila por póliza con `procesoActivo` CONTRAANULAR.
- SCA (`/sca-site`): el mensaje es distinto y el OK es una tarjeta enlazada; tampoco se deshabilita y tampoco duplica.
- Conclusión: la protección de R44 evita el doble envío, pero el usuario no ve el botón deshabilitado. Queda como duda D5.

## 10. Solicitud Vida 15788717 y 4004 (fase 2, solo lectura)

Cabecera y detalle CORE (`SCA2_consultarCabeceraSolicitud` / `SCA2_consultarDetalleSolicitud`) frente a las altas nuevas. No se modificó ninguna solicitud.

| Campo CORE | 15788717 (Vida, histórica) | 15788809 / 15788813 (SCA2) | 15788814 (SCA) | Alta Vida SCA2 (lo que envía) |
|---|---|---|---|---|
| Usuario / perfil | JJGONZ2 / CE_RM / CE_RM_OFICINA | igual | igual | igual |
| `canalEntrada` / `origen` / `contacto` | 1 / 2 / 1 | 1 / 2 / 1 | 1 / 2 / 1 | 1 / 2 / 1 |
| `catalogacion` | 2 (A vencimiento) | 2 | 2 | 2 |
| Causa / motivo / detalle / acción | 30 / 1 / 9 / 6098 | igual | igual | igual (ASEGURADO NO DESEA SEGURO / COMPROMISOS) |
| `codTerceroAgente` | 5324209 (= `codAgente` de estructurasComerciales para 0005912432, misma regla que R45-A) | clave de la póliza | 5279474 | `codAgente` (0035099) |
| Cola de la descripción | `…\|JJGONZ2 RED MAPFRE\|2\|3` | `…\|2\|41` | `…\|2\|41` | 41 → probado con 3 (VID-3) |
| `nivelIntervencion` / estado | 2 / 4 (resuelta, carta 13:35) | 1 / 9-10 | 1 / 10 | — |
| `idCompania` | vacío | vacío | vacío | — |
| `numApli`, prima, estructura, parte izquierda de la clave | no los devuelven estos servicios | — | — | `numApli` vacío; prima y estructura informadas |

- **Quién la creó:** JJGONZ2 con los mismos canal (1) y origen (2) que SCA2 y SCA, así que el canal no separa los caminos. No hay fila en `SCA2 Solicitud` ni en las tablas de SCA, y no hay instancia SCA2. Lo más probable es que se diera de alta fuera de SCA2/SCA (llamada directa a CORE u otra herramienta) con `codCiaUsuario` 3; es una inferencia, no está confirmada.
- **Única pista:** el `3` final de la descripción (`codCiaUsuario`). Probado en una alta Vida nueva (0006058198, `SCA2_construirContextoAlta` v7): mismo 4004. Revertido (v8 = v6). No se hizo la 2.ª alta permitida porque la pista quedó descartada.
- **Cuerpo del 4004:** no disponible (solo «Datos insuficientes para la operacion»). Hace falta el log de CORE de `generarStudAnul` o la petición original de la 15788717.
