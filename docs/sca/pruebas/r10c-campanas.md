# R10-C · Contra Anulación con pólizas de campaña (TTQ / PREMFIDE / RETOS / SVA) — SCA vs SCA2 (TEST)

Sesión R10-C de la ronda 10 (ver `docs/sca/27-plan-ronda10.md`). Alcance: alta + Contra Anulación con las pólizas de la sección R10-C de `polizas-ronda10.md`, casos del plan `planes/contra-anular-v2.md` que dependen de campaña (2-10 TTQ, 2-11 PREMFIDE, 2-12 RETOS, 2-13 SVA, 2-14 pérdida de descuento), que H3 dejó «no probados por falta de pólizas de campaña».

Referencia de comportamiento: SCA TEST. Sólo se corrigen objetos `SCA2_*`.

## 1. Resumen

_(se completa al cerrar la sesión)_

## 2. Análisis previo del diseño (SCA vs SCA2) — qué hace cada aplicación con una campaña

Flujo SCA (`SCA_ContraAnulacionOpcionesEstrategicas` v9 → modales → `SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas` v7):

1. El listado de argumentos (`consultarListadoArgumentos`) devuelve, además de `listadoArgumentos`, un bloque `treboles` (DEFCART) con, por campaña, `codTrebol`, `descTrebol`, `trebolesDisponibles` y `trebolesRecomendados`.
2. Al seleccionar un argumento, SCA busca su `codTipoArgumento` en DEFCART (`campanaDescart`). Si lo encuentra, el argumento es «Tu te quedas» (`tuTeQuedas`) salvo que la campaña sea `RETOS`. Además consulta `consultarTipoArg` y sólo abre un modal de regateo si el argumento es `regateable = "S"` o está en DEFCART.
3. POSITIVO con argumento de campaña: modal de tréboles («Indique el número de <campaña> a aplicar (máximo: N recomendados: R)»), modal de RETOS (tipos 286/287) o modal de SVA (tipos 252/254/365, lista de regalos y pantalla de correo).
4. Al ACEPTAR el modal de recuperación se ejecutan las acciones: tréboles → `executeAsignar` (Club MAPFRE) y, si es TTQ, `gestionarTTQ` (si no, `marcarAsignacionBonificacion`); RETOS → `asignarRetos` + `gestionarTTQ`; SVA → `asignarSVA` + `marcarAsignacionBonificacion`. Mensajes: «Se ha realizado la asignación de tréboles al usuario correctamente.» (con variante «…muy cerca del Vencimiento…» si vence en ≤ 5 días), «Ha comenzado el proceso de asignación de SVA al cliente de forma correcta.», «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos/Club Mapfre…».

Divergencias propias de SCA2 encontradas en el diseño (antes de probar en UI):

| # | Dónde | SCA | SCA2 (v44 / v4) | Efecto funcional |
|---|---|---|---|---|
| D1 | `SCA2_ContraAnulacionOpciones` → datos que recibe el modal de recuperación | Pasa `tuTeQuedas`, `numBonAplic` (tréboles elegidos), `svaElegido`, `email`, `fecVencimiento`, `mcaTeCuidamos`… | No los pasaba | SCA2 **nunca llamaba a `gestionarTTQ`**, asignaba tréboles con cantidad vacía y el SVA sin regalo elegido |
| D2 | Uso de DEFCART | Máximo y recomendados de la campaña, nombre de la bonificación (`descTrebol`), comprobación «regateable» | Máximo fijo 5, texto fijo «tréboles», sin recomendados, sin comprobar «regateable»; abría regateo según el código de campaña del argumento | Textos y límites del modal distintos; podía abrir regateo en argumentos que en SCA no lo abren |
| D3 | `SCA2_ContraAnulacionModalRecuperacionPoliza` | Tras error de TTQ/Club Mapfre desmarca el argumento; mensaje de éxito con aviso de vencimiento cercano | No desmarcaba; sin aviso | Estado del argumento inconsistente tras error |
| D4 | Correo / cliente para SVA | Correo de contacto de la cabecera e `idCliente` al modal de correo | Correo vacío y sin `idCliente` | La pantalla de correo del SVA salía vacía y no podía actualizar RIC |

Los modales `SCA2_ContraAnulacionModalRetos`, `…ModalSVA` y `…ModalSVAEmail` son idénticos a los de SCA (diff vacío salvo prefijo).

## 3. Objetos Appian modificados

| Objeto | UUID | Versión | Qué cambió | Cómo se probó |
|---|---|---|---|---|
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 44 → 45 | Conserva la respuesta completa del listado (`treboles` DEFCART); `arrayTrebolesDisponibles/Recomendados`, `campanaDescart`, `codCampana`, `tuTeQuedas`, `consultarTipoArg` → `esRegateable`; `maximo`/`tipoBonificacion` dinámicos; `fecVencimientoPoliza`; correo desde `SCA2_obtenerDatosCabecera`; puerta `esRegateable` en el despacho de modales; `data` del SGO con `codCampania`, `trebolesRecomendados`, `nuuma`, `idCliente`; `data` del modal de recuperación con `mcaTeCuidamos`, `tuTeQuedas`, `fecVencimiento`, `numBonAplic`, `svaElegido`, `email`, `mcaPropietarioPoliza`, `claveProduccion`, `argumentoEconomico`, `descTipoArgumento` | GET vivo + backup, PUT completo, relectura idéntica, `testInterface` con una solicitud existente sin errores; UI (§4) |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951` | 4 → 5 | Mensaje de éxito TTQ con variante «muy cerca del Vencimiento»; desmarca el argumento (`estadoArgumentos = "0"`) en error de TTQ y de Club Mapfre | Idem; `testInterface` sin errores; UI (§4) |

## 4. Resultados por caso

_(se completa con las pruebas de UI)_

## 5. Hallazgos externos (CORE / NSE / Emisión / Documentum)

_(pendiente)_

## 6. Preguntas para el analista

_(pendiente)_
