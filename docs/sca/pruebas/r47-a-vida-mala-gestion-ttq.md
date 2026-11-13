# R47-A — Vida «MALA GESTIÓN» y tréboles TTQ con clientes NO CLUB (ronda 47, 10/11/2026)

Origen: respuesta del analista a `../63-dudas-analista-pendientes.md` (rectificación de la duda 25 y pólizas TTQ NO CLUB para la duda 33). Entorno: **Appian TEST** (`mapfrespain-test`), MCP `appian-dev-mcp-c90b` (plugin 26.9.15). Usuario de prueba: JJGONZ2 (Red Mapfre / Oficina). Nunca PRO. Solo objetos SCA2. Sin tocar solicitudes ni instancias históricas.

Leyenda: **[Observado]** visto en TEST (pantalla, export o respuesta de servicio) · **[Inferido]** deducido del código o del comportamiento · **[Pendiente]** no verificado.

## Resumen

| # | Petición del analista | Estado |
|---|---|---|
| 1 | Vida: con DECISIÓN DE CLIENTE debe verse MALA GESTIÓN, sin cambiar Autos ni Hogar | Corregido en `SCA2_AltaSolicitudPage` v52→v53 y probado OK en Vida, Autos y Hogar [Observado] |
| 2 | Tréboles TTQ con clientes NO CLUB (0732400122931 y 0731700076776) | Probado en pantalla con 2 solicitudes nuevas: modal de tréboles, validaciones, CANCELAR y ACEPTAR de la enhorabuena [Observado]. Con cliente NO CLUB, Club MAPFRE rechaza la asignación, no se aplica nada y el argumento vuelve a Pendiente, como en SCA [Observado]. Sin cambios en Appian |
| 3 | Club OK + TTQ KO → error relanzable; observaciones >999; «Se han aplicado Y tréboles»; SVA y reserva de prima | No alcanzable con estas pólizas: el flujo se corta antes, en Club MAPFRE [Pendiente]. Lógica revisada en el export [Observado en export] |

## Objetos modificados

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| IF `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v52 → **v53** | En el desplegable «Detalle», el borrado por posición del 2.º detalle con el motivo 1 (DECISIÓN DE CLIENTE) se limita a pólizas no Vida: `if(and(local!motivoAnulacion = 1, not(local!polizaVidaAlta)), remove(local!detalleDDVisible, 2), …)` en `choiceLabels` y `choiceValues`. `local!polizaVidaAlta` ya existía (`local!tipoPolizaCalc = cons!SCA2_TXT_VIDA_RIESGO`) |

Protocolo [Observado]: reserva en `coordinacion-ronda47.md` (commit `efc62c1`) → export vivo v52 → backup `backups-r47/R47-A_SCA2_AltaSolicitudPage_v52_antes.sail` → cambio mínimo (2 condiciones y un comentario) → `updateInterface` (respuesta `versionId 53`, `previousVersionId 52`, inputs sin cambios) → reexport `backups-r47/R47-A_SCA2_AltaSolicitudPage_v53_despues.sail`, idéntico al enviado (`diff` vacío) → liberado. Aviso de Appian «Interface has no test inputs saved as Default» sin efecto en el guardado.

No se ha modificado ningún otro objeto. Para TTQ no hacía falta corregir nada: el comportamiento coincide con SCA (ver T5).

## Resultados

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| V1 | Vida, DECISIÓN DE CLIENTE, antes del cambio (v52) | (Analista) debe verse MALA GESTIÓN | [Observado] Detalle: ASEGURADO NO DESEA SEGURO, PRECIO, PRODUCTO, VENTA/DESAPARICION DEL RIESGO. **Falta MALA GESTION** | KO | Sin solicitud (no se pulsa GUARDAR) | — | Alta → NO VIDA/VIDA → póliza 0006059703 (00593 Solución Global Autónomos - Vida Riesgo) → Motivo DECISION DE CLIENTE → abrir Detalle. Captura `../img/r47-a-01-antes-vida-detalle-v52.png` | `remove(local!detalleDDVisible, 2)` quita la 2.ª opción por posición; en Vida es MALA GESTION (en Autos y Hogar, IMPAGO DEL SEGURO) |
| V2 | Vida, DECISIÓN DE CLIENTE, después (v53) | Se ve MALA GESTION | [Observado] ASEGURADO NO DESEA SEGURO, **MALA GESTION**, PRECIO, PRODUCTO, VENTA/DESAPARICION DEL RIESGO | OK | Sin solicitud (no se pulsa GUARDAR; el alta Vida falla en CORE con 4004) | — | Igual que V1 con v53. Captura `../img/r47-a-02-despues-vida-detalle-v53.png` | Corregido en v53 |
| V3 | Regresión Autos | Sin cambios: no aparece IMPAGO DEL SEGURO | [Observado] ASEGURADO NO DESEA SEGURO, MALA GESTION, PRECIO, PRODUCTO, SINIESTRO, VENTA DEL VEHICULO (sin IMPAGO DEL SEGURO) | OK | Sin solicitud | — | Póliza 2002500199777 (TERCEROS AMPLIADO) → DECISION DE CLIENTE → Detalle. Captura `../img/r47-a-03-despues-autos-detalle.png` | — |
| V4 | Regresión Hogar | Sin cambios: no aparece IMPAGO DEL SEGURO | [Observado] ASEGURADO NO DESEA SEGURO, MALA GESTION, PRECIO, PRODUCTO, SINIESTRO, VENTA/DESAPARICION DEL RIESGO (sin IMPAGO DEL SEGURO). Lo mismo en 0731700076776 | OK | 15788859 (se guardó después para T1) | 12334035 (SCA2 CMD Alta) | Póliza 0732400122931 (HOGAR FAMILIAR) → DECISION DE CLIENTE → Detalle. Captura `../img/r47-a-04-despues-hogar-detalle.png` | — |
| T1 | Alta nueva con póliza TTQ NO CLUB 1 | Solicitud y contra anulación con argumento TTQ | [Observado] Solicitud 15788859 generada; contra anulación con 8 argumentos, el 8.º es «TU TE QUEDAS HOGAR NO CLUB 20 TREBOLES DISPONIBLES» | OK | 15788859 (0732400122931, Hogar, DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, A VENCIMIENTO, 01/07/2027) | Alta 12334035 · CrearAccion 11283382 | GUARDAR → ACEPTAR → ACEPTAR → oficina VILLALBA. Captura `../img/r47-a-05-ca-15788859-ttq.png` | — |
| T2 | POSITIVO con argumento TTQ: modal de tréboles | «Indique el número de <campaña> a aplicar (máximo: N)» | [Observado] «Indique el número de TTQHOGAR a aplicar (máximo: 20)»; con 0731700076776, «(máximo: 30)» | OK | 15788859, 15788860 | — | Marcar el argumento TTQ → POSITIVO. Captura `../img/r47-a-06-ttq-numero-treboles.png` | — |
| T3 | Validaciones del número de tréboles | 0 → «El valor ha de ser mayor que 0»; > máximo → «El valor no puede ser mayor que el máximo indicado» | [Observado] 0 → «El valor ha de ser mayor que 0»; 31 → «El valor no puede ser mayor que el máximo indicado»; 2 → sin mensaje | OK | 15788860 | — | Escribir 0, 31 y 2. Capturas `../img/r47-a-10-ttq-validacion-0.png`, `../img/r47-a-11-ttq-validacion-31.png` | Literales iguales a SCA (R10-C) |
| T4 | CANCELAR en la enhorabuena | Vuelve a la contra anulación sin aplicar tréboles | [Observado] Tras 2 tréboles → ACEPTAR → «¡Enhorabuena en la retención de la póliza!…» → CANCELAR: vuelve a la contra anulación, argumento TTQ «Pendiente», sin mensajes de Club ni de TTQ y sin filas nuevas en `SCA2 Error` | OK | 15788859 | — | Capturas `../img/r47-a-07-enhorabuena.png`, `../img/r47-a-08-enhorabuena-cancelar.png` | — |
| T5 | ACEPTAR en la enhorabuena con cliente **NO CLUB** | Como SCA: si Club MAPFRE rechaza, no se aplica nada y el argumento vuelve a Pendiente | [Observado] Mensaje «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos. Utilice el enlace a te cuidamos existente en el argumento para dar de alta al cliente en te cuidamos y posteriormente finalizar el argumento como positivo. Mensaje obtenido de Te Cuidamos: El cliente no tiene ningún contrato en vigor en la fecha indicada.» → ACEPTAR → argumento «Pendiente», la contra anulación sigue abierta. Igual en las 2 pólizas | OK | 15788859, 15788860 | CrearAccion 11283382 / 16529642 | Marcar TTQ → POSITIVO → 2 → ACEPTAR → ACEPTAR. Capturas `../img/r47-a-09-enhorabuena-aceptar-no-club.png`, `../img/r47-a-12-enhorabuena-aceptar-no-club-15788860.png`, `../img/r47-a-13-ca-15788860-pendiente.png` | Club MAPFRE (`executeAsignar`) devuelve `inderror=1` [Inferido del export v16]; no se llama a TTQ. Mismo literal que SCA (R10-C, 2002300379272) |
| T6 | Errores de la prueba por API/MCP | Club KO no es relanzable: no se escribe en `SCA2 Error` | [Observado] `listRecordData` de `SCA2 Error`: última fila 214 (15788840, de R46); ninguna de 15788859 ni 15788860 | OK | 15788859, 15788860 | — | MCP `listRecordData` (record `d7111f93-55f3-4b43-b921-aedadd2af7c3`). `testRule` de `SCA2_consultarErroresSolicitud` → HTTP 403 con el usuario del MCP | Solo Club OK + TTQ KO escribe `SCA2 TTQ GrabarTreboles / TTQ_KO` [Observado en export] |
| T7 | Club OK + TTQ KO → error relanzable | Fila `TTQ_KO` en `SCA2 Error` y relanzamiento | No alcanzable: con NO CLUB el flujo se corta en Club | PENDIENTE | — | — | — | Hace falta un cliente Club activo con campaña TTQ en TEST y un fallo de TTQ |
| T8 | Observación «Se han aplicado Y tréboles» y recorte a 999 | Observación del argumento positivo con el número de tréboles, recortada a 999 | No alcanzable: el argumento no llega a positivo. El campo de observaciones de la contra anulación admite 250 caracteres, así que no se pueden superar 999 desde pantalla | PENDIENTE | — | — | — | [Observado en export v16] `left(…, 999)` y `SCA2_TXT_OBS_TREBOLES_APLICADOS` cuando `tuTeQuedas` y `numBonAplic > 0` |
| T9 | SVA y reserva de prima | Observación del SVA aplicado y de la reserva de prima | Estas pólizas no ofrecen argumento SVA ni económico con reserva de prima | PENDIENTE | — | — | Revisar los argumentarios de 15788859 (8) y 15788860 (9) | [Observado en export] se añade «reserva de prima» si `argumentoEconomico = "S"` |
| T10 | Comparación con SCA | Mismo comportamiento | [Inferido] Mismo literal y mismo reset a Pendiente que el diseño de SCA documentado en R10-C. No se ha creado una solicitud en SCA (`/sca-site`) para no dejar datos en SCA | OK (por diseño) | — | — | — | — |

## Respuestas para el analista

- **Duda 25 (MALA GESTIÓN en Vida).** Hecho. Con DECISIÓN DE CLIENTE, en Vida ya aparece MALA GESTION; en Autos y Hogar se sigue quitando IMPAGO DEL SEGURO, como en SCA. Ejemplo: póliza Vida 0006059703, motivo DECISION DE CLIENTE, detalles ASEGURADO NO DESEA SEGURO / MALA GESTION / PRECIO / PRODUCTO / VENTA/DESAPARICION DEL RIESGO [Observado]. No se ha pulsado GUARDAR porque el alta Vida falla en CORE con 4004.
- **Duda 33 (tréboles TTQ con cliente NO CLUB).** Con 0732400122931 (solicitud 15788859, «TU TE QUEDAS HOGAR NO CLUB 20 TREBOLES DISPONIBLES») y 0731700076776 (15788860, «… 30 TREBOLES DISPONIBLES»), Hogar, DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, A VENCIMIENTO:
  - El modal pide el número de TTQHOGAR (máximo 20 / 30) y valida 0 y el exceso con los literales de SCA [Observado].
  - CANCELAR en la enhorabuena vuelve a la contra anulación sin aplicar nada [Observado].
  - ACEPTAR en la enhorabuena: Club MAPFRE rechaza porque el cliente no es socio («El cliente no tiene ningún contrato en vigor en la fecha indicada»). **No se aplica ningún trébol, ni en Club ni en TTQ**, no se finaliza la contra anulación, el argumento vuelve a Pendiente y el gestor puede usar el enlace a Te Cuidamos del argumento (`webclub20/CHSinicio.do?…&p_NumDoc=<NIF>`) para dar de alta al cliente y repetir el positivo. Es lo mismo que hace SCA [Observado + Inferido].
  - No se genera error en `SCA2 Error`: solo se registra (relanzable) el caso Club OK + TTQ KO [Observado].
  - Club OK + TTQ KO, «Se han aplicado Y tréboles», recorte a 999, SVA y reserva de prima siguen **sin probar en pantalla**: con un cliente NO CLUB el flujo no pasa de Club [Pendiente].

## Dudas nuevas

- **N47-1.** Para cerrar la duda 33 hace falta una póliza con campaña TTQ vigente cuyo cliente **sí** sea socio Club MAPFRE (para ver la aplicación y «Se han aplicado Y tréboles»), y una forma de provocar un fallo solo en TTQ (para el error relanzable). ¿Nos la podéis pasar?
- **N47-2.** Con cliente NO CLUB, ¿basta el mensaje actual (igual que SCA) o queréis que SCA2 oculte o avise del argumento TTQ «NO CLUB» antes de pulsar POSITIVO?

## Solicitudes e instancias de prueba abiertas

| Solicitud | Póliza | Estado | Instancias |
|---|---|---|---|
| 15788859 | 0732400122931 | Solicitud Pendiente; contra anulación incompleta, argumento TTQ Pendiente | SCA2 CMD Alta 12334035 (completada), SCA2 CMD CrearAccion 11283382 (completada) |
| 15788860 | 0731700076776 | Solicitud Pendiente; contra anulación incompleta, argumento TTQ Pendiente | SCA2 CMD Alta 11283419 (completada), SCA2 CMD CrearAccion 16529642 (completada) |

Las pruebas de Vida, Autos y Hogar del desplegable no crearon solicitudes.
