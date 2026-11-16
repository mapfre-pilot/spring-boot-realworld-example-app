# R51-A · MEJ-01/02: la enhorabuena sale después de dar los tréboles; mensaje NO Club con enlace a Club Mapfre

Entorno: Appian TEST (`appian-dev-mcp-c90b`), site SCA2 `/suite/sites/sca2`; referencia SCA `/suite/sites/sca-site`. Fecha: 16/11/2026.
Origen: respuesta de negocio a MEJ-01/MEJ-02 del informe R49 (`../anexos/r49/Informe_incidencias_SCA_polizas_y_mensajes.txt`). Coordinación: `coordinacion-ronda51.md`.

Este es un cambio funcional aprobado por negocio. En este punto SCA2 se aparta de SCA a propósito: SCA da la enhorabuena antes de dar los tréboles.

## 1. Qué pasaba antes (v5 de `SCA2_ContraAnulacionSGO`, tal como lo dejó R46-D)

Argumento con tréboles «TU TE QUEDAS … TREBOLES DISPONIBLES» → POSITIVO → pantalla «Indique el número de TTQ… a aplicar (máximo: N)» → ACEPTAR **solo cerraba la pantalla** → «¡Enhorabuena en la retención de la póliza! Se van a finalizar las acciones de contra anulación en SCA. ¿Desea continuar?» → ACEPTAR de la enhorabuena (`SCA2_ContraAnulacionModalRecuperacionPoliza` v16):
1. Club MAPFRE (`SCA2_executeAsignarIntegracion`). Si falla, el argumento vuelve a Pendiente y sale el aviso «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos…» (cliente sin Te Cuidamos) o «No se han podido asignar los tréboles al cliente por la siguiente causa:…» (otro error).
2. Si Club va bien, TTQ (`SCA2_gestionarTTQRESTIntegracion`). Si TTQ falla, se registra el error relanzable `SCA2 TTQ GrabarTreboles / TTQ_KO` y se avisa.
3. Argumento económico, `guardarEjecuArg` y cierre positivo.

Es decir, la enhorabuena salía **antes** de intentar dar los tréboles (T5 de R47-A, R47-C y R49-D). Retos y SVA ya se aplicaban al ACEPTAR su propia pantalla (R34-A), así que con ellos la enhorabuena ya salía después.

## 2. Decisión y cambio

Se aplica lo que pide negocio para el «Mensaje 01» y sus tres casos:

| Caso | Ahora (v6) |
|---|---|
| Cliente NO Club (Club MAPFRE rechaza la asignación y el cliente no está en Te Cuidamos, `mcaTeCuidamos = false`, la misma condición que antes) | Al ACEPTAR la pantalla de tréboles **no sale la enhorabuena**. Sale el mensaje 02 nuevo (constante `SCA2_TXT_TREBOLES_NO_CLUB_MAPFRE`, literal de negocio sin tocar), con «Mensaje obtenido de Club Mapfre: <mensaje del servicio>» y debajo el enlace «Club Mapfre». ACEPTAR vuelve a los argumentos y el argumento queda en Pendiente, como antes |
| Otro error de Club MAPFRE (cliente en Te Cuidamos o error de la integración) | Sale el error con el literal de siempre («No se han podido asignar los tréboles al cliente por la siguiente causa:…») y ACEPTAR vuelve a los argumentos. El argumento queda en Pendiente |
| Todo bien | Se aplican los tréboles (Club y TTQ) y **después** sale la enhorabuena, igual que ahora. Su ACEPTAR hace el resto (argumento económico, observación «Se han aplicado N tréboles…» y cierre positivo) sin volver a aplicar los tréboles |
| Club OK y TTQ KO (entrega parcial) | No lo nombra negocio. Se mantiene lo que había: error relanzable `TTQ_KO` y el mismo aviso. Su ACEPTAR lleva a la enhorabuena y la contra anulación se cierra como positiva (ver duda 3) |

Decisiones técnicas (no cambian el flujo):
- **Dónde**: la llamada a Club y TTQ se ha movido de la enhorabuena (`SCA2_ContraAnulacionModalRecuperacionPoliza`) al ACEPTAR de la pantalla de tréboles (`SCA2_ContraAnulacionSGO`). Es el mismo código, con los mismos datos (`dataServicio` = `local!dataRecuperacion` de Opciones) y los mismos literales. Cuando los tréboles se aplican bien, `tipoArgumentoVariable` pasa a 0, igual que ya hacían Retos y SVA. Así la enhorabuena no los vuelve a aplicar, porque su bloque de tréboles solo se ejecuta con `aplicarTreboles = (tipoArgumentoVariable = 1)`. No se ha tocado `SCA2_ContraAnulacionOpciones`, que estaba reservado por R51-B, ni `SCA2_ContraAnulacionModalRecuperacionPoliza`.
- **Corrección R49-D (Opciones v80)**: se mantiene. Si Club falla, el argumento vuelve a «0» y `estadoContraAnul` se recalcula, así que FINALIZAR no cierra la contra anulación como positiva.
- **Enlace a Club Mapfre**: SCA2 ya tiene la URL de alta. Es el concepto URL de CORE «Aplicación Club Mapfre» (`consultarConcepto`, `idConcepto = URL`), con valor en TEST `https://wportalinterno.pre.mapfre.net/webclub20/CHSinicio.do?p_CodCanal=20&p_NumDoc=`. Es el mismo que usa `SCA2_GetUrlArgumento` para el icono de enlace de los argumentos. El enlace es ese valor seguido del NIF del tomador. El concepto se busca por su descripción, guardada en la constante `SCA2_TXT_CONCEPTO_URL_ALTA_CLUB_MAPFRE`, y no por posición. Así se puede cambiar desde el mantenimiento de conceptos sin tocar Appian. Si el concepto no existe, el mensaje sale igual, pero sin enlace. El texto del enlace está en `SCA2_TXT_ENLACE_CLUB_MAPFRE` («Club Mapfre»). La URL solo se consulta cuando se muestra el aviso NO Club.
- La URL `https://www.clubmapfre.es/…/tarjeta-credito-mapfre-tecuidamos/` (`SCA2_URL_TECUIDAMOS`, concepto «Club Mapfre») no se ha usado, porque es una página comercial y no la aplicación de alta.

## 3. Objetos cambiados

| Objeto | UUID | Versión antes→después | Cambio |
|---|---|---|---|
| IF `SCA2_ContraAnulacionSGO` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060093` | v5 → **v6** | El ACEPTAR de la pantalla de tréboles aplica Club + TTQ. Nueva vista de aviso (NO_CLUB con enlace / ERROR / PARCIAL) dentro de la misma pantalla, con un ACEPTAR que vuelve a los argumentos o, si la entrega es parcial, lleva a la enhorabuena. Locales nuevas `resTreboles`, `resTTQ`, `vistaTreboles`, `mensajeTreboles`. Sin cambios en los inputs |
| CONS `SCA2_TXT_TREBOLES_NO_CLUB_MAPFRE` | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5750096` | nueva v1 | Literal de negocio del mensaje 02, con `{0}` = mensaje de Club MAPFRE |
| CONS `SCA2_TXT_ENLACE_CLUB_MAPFRE` | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5750102` | nueva v1 | «Club Mapfre» |
| CONS `SCA2_TXT_CONCEPTO_URL_ALTA_CLUB_MAPFRE` | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5750108` | nueva v1 | «Aplicación Club Mapfre» (descripción del concepto URL) |

Protocolo seguido: reserva en `coordinacion-ronda51.md` (commit `396d836`) → copia `backups-r51/R51-A_SCA2_ContraAnulacionSGO_v5_antes.sail` → `git pull` y comprobación de que la versión viva era la v5 (export idéntico a la copia) → `updateInterface` (respuesta `previousVersionId 5`, `versionId 6`, inputs sin cambios) → reexport `R51-A_SCA2_ContraAnulacionSGO_v6_despues.sail`, idéntico a lo enviado → diff `R51-A_SCA2_ContraAnulacionSGO_v5_v6.diff` → liberado (commit `0aae5e3`). `testInterface` con la pantalla de tréboles abierta: sin errores. Aviso de Appian sin efecto: «Interface has no test inputs saved as Default».

No se ha guardado ningún modelo de proceso. No hay SQL para el usuario.

## 4. Pruebas con solicitudes nuevas

Usuario JJGONZ2 (Red Mapfre / Oficina). Todas las solicitudes son nuevas: alta del 16/11/2026, hora de Madrid según `fecSolicitud` de CORE, con la observación «Prueba R51-A tréboles». No se ha tocado ninguna solicitud antigua.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Póliza | Pasos |
|---|---|---|---|---|---|---|---|
| P0 | NO Club con TTQ (2002300300497, «TU TE QUEDAS NO CLUB MAPFRE 20» en R10-C) | Alta nueva | **No se puede dar de alta**: «Existe una solicitud en curso para la póliza indicada». En CORE las dos solicitudes anteriores (15788003 y 15788040) están cerradas (codEstSolic 4), pero SCA2 las sigue viendo en curso (15788003 «Solicitud Pendiente», 15788040 «Mecanización Enviada») | BLOQUEADO | — | 2002300300497 | Buscador → ALTA → póliza + Tab (18:49 UTC). No se pulsó CONSULTAR |
| P1 | Buscar TTQ con cliente Club | Argumentario con «TU TE QUEDAS…» | 7 argumentos (SVA, Servicios Mapfre, Club Platino…), **sin TTQ**. Obligatorio «ME HA SUBIDO MUCHO LA PRIMA» en Negativo; FINALIZAR pide la carta | SIN TTQ | 15789194 (19:51:49) | 0732400120983 | Alta → CA → negativo 19:52:54 |
| P2 | Ídem | Ídem | 7 argumentos (Club Plata…), sin TTQ. Al RETOMAR después: «No hay argumentos disponibles para esta contra anulación» (ver §6) | SIN TTQ | 15789195 (19:55:22) | 0730380324165 | Alta → CA; RETOMAR más tarde. Captura `../img/r51-a-regresion-15789195-sin-argumentos.png` |
| P3 | Ídem | Ídem | 8 argumentos ordinarios, sin TTQ | SIN TTQ | 15789196 (19:57:52) | 0731380454474 | Alta → CA |
| P4 | Ídem | Ídem | 7 argumentos ordinarios, sin TTQ | SIN TTQ | 15789198 (20:00:25) | 0731380454486 | Alta → CA |
| P5 | Ídem | Ídem | «No hay argumentos disponibles para esta contra anulación» | SIN TTQ | 15789199 (20:02:52) | 0731700187136 | Alta → CA. Captura `../img/r51-a-candidata-15789199-sin-argumentos.png` |
| E1 | `SCA2 Error` de las solicitudes nuevas | Sin errores | Ninguna fila para 15789194–15789199 (MCP `listRecordData`, última fila 226, de otra solicitud) | OK | — | — | — |
| C1 | `testInterface` de SGO v6 con la pantalla de tréboles abierta | Sin errores | Renderiza «Indique el número de TTQHOGAR a aplicar (máximo: 20)» con ACEPTAR/CANCELAR, sin errores | OK | — | — | MCP |

Las 5 solicitudes nuevas quedan con la CA Incompleta: ninguna tiene argumentos ejecutados, salvo el negativo de 15789194. Las pólizas están anotadas en `polizas/REGISTRO.md`.

## 5. Comparación con SCA

SCA (`SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas`) llama a Club MAPFRE y a TTQ en el ACEPTAR de la enhorabuena, como hacía SCA2 v5, y muestra el literal antiguo de «te cuidamos» sin enlace. La diferencia es intencionada: la ha aprobado negocio (MEJ-01/02). En el resto del flujo (validaciones del número de tréboles, CANCELAR de la pantalla de tréboles, argumento en Pendiente tras el fallo y cierre positivo) SCA2 sigue igual que SCA.

## 6. Lo no probado

- **El flujo nuevo no se ha podido probar en pantalla (ni grabar)**: en TEST no queda ninguna póliza libre que ofrezca tréboles TTQ. Ya no los ofrecen las 5 pólizas de campaña de R10-C sin solicitud abierta, y la NO Club 2002300300497 está bloqueada en SCA2. Sin probar: el aviso NO Club con el enlace y su href, la vuelta a Pendiente y el FINALIZAR no positivo, los tréboles en Club antes de la enhorabuena con la CA Positiva, el CANCELAR de la pantalla de tréboles y el «otro error».
- Comprobado sin pantalla: export y reexport, `testInterface` y revisión del código. La lógica de Club/TTQ es la misma que se ejecutaba en la enhorabuena (R47-A T5 y R47-C T2 la vieron funcionar con NO Club y con Club); solo cambia el botón que la lanza.
- Para el caso NO Club se puede usar la solicitud 15788888 (2002100424269, «TU TE QUEDAS NO CLUB MAPFRE 20», CA Incompleta, sin argumentos ejecutados). La creamos nosotros en R47-C y no es del analista. No se ha usado porque es antigua: pendiente de que el usuario lo autorice.
- **Observación (no es de R51-A)**: 15789195 tenía argumentos en el alta y al RETOMAR muestra «No hay argumentos disponibles para esta contra anulación»; 15789199 ya salió vacía. `SCA2_ContraAnulacionSGO` no carga el argumentario, y Opciones v81 (R51-B) solo cambia el literal SI24. La causa probable es que el servicio `consultarListadoArgumentos` haya devuelto la lista vacía: con la compañía contraria vacía tarda unos 63 s (R47-C D1). No se ha pulsado RECARGAR. Conviene revisarlo en otra sesión.

## 7. Dudas para negocio / analista

1. **Erratas del texto validado (se ha aplicado el literal tal cual).** Corrección propuesta: «No se han podido asignar tréboles al cliente porque no está dado de alta en Club Mapfre. Utilice el enlace a Club Mapfre para dar de alta al cliente y finalizar el argumento como positivo. Mensaje obtenido de Club Mapfre: …». Las erratas son: espacio antes del punto («club mapfre .»), «club mapfre» en minúsculas frente a «Club Mapfre» en el resto del texto y falta la «y» en «al cliente finalizar». ¿La aplicamos?
2. **CANCELAR en la enhorabuena después de dar los tréboles.** Con el nuevo orden, cuando sale la enhorabuena los tréboles ya están dados en Club MAPFRE y TTQ. Si el gestor pulsa CANCELAR, el argumento vuelve a Pendiente pero el cliente se queda con los tréboles, y un nuevo POSITIVO los volvería a dar. Negocio ha pedido que la enhorabuena «quede igual que ahora», así que se ha dejado el CANCELAR. Propuesta: con tréboles ya dados, quitar CANCELAR (solo ACEPTAR) o avisar de que los tréboles ya se han dado. ¿Qué preferís?
3. **Entrega parcial (Club OK + TTQ KO).** Se mantiene el aviso de R46-D: «Se han aplicado N tréboles en Club MAPFRE, pero no se han podido grabar en Te Cuidamos (TTQ). Se ha registrado un error en el listado de errores para relanzar la grabación en TTQ. Pulse ACEPTAR para finalizar la contra anulación.». Ahora su ACEPTAR lleva primero a la enhorabuena y después al cierre. ¿Lo dejamos así o se trata como «otro error» (volver a los argumentos)? Si se deja así, ¿cambiamos «Pulse ACEPTAR para finalizar la contra anulación» por «Pulse ACEPTAR para continuar»?
4. **Enlace**: ¿es la URL correcta? Se usa el concepto «Aplicación Club Mapfre» (webclub20 `CHSinicio.do?p_CodCanal=20&p_NumDoc=` + NIF), el mismo de los argumentos. En TEST apunta a `wportalinterno.pre.mapfre.net`, que puede no abrirse desde fuera de la red interna. El texto del enlace es «Club Mapfre» (constante).
5. **SVA con cliente no Club.** El aviso de SVA «No se han podido asignar tréboles al cliente porque no está dado de alta en Club Mapfre. Utilice el enlace a te cuidamos existente en el argumento de SVA…» no se ha cambiado ni lleva enlace, porque negocio solo ha pedido el mensaje 02 de tréboles. ¿Se le pone también el enlace?
6. **Código que ya no se usa.** El bloque de tréboles de `SCA2_ContraAnulacionModalRecuperacionPoliza` (v16), con el literal antiguo de «te cuidamos», ya no se ejecuta. No se ha borrado para no tocar más objetos en esta ronda. Se puede limpiar en una ronda técnica.
7. **Datos de prueba TTQ.** Hacen falta pólizas TEST que ofrezcan «TU TE QUEDAS…», una con cliente Club y otra NO Club, sin solicitud en curso. Las de R10-C ya no los ofrecen. ¿Nos podéis pasar algunas? También: la 2002300300497 está cerrada en CORE pero SCA2 la ve en curso (15788003/15788040). ¿Se cierran en SCA2?
