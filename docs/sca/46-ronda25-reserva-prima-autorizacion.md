# Ronda 25 — Revisión de pruebas del analista: autorización CORE tras ANL y reserva/devolución de prima en la simulación del alta

> Origen: revisión del analista de las solicitudes 15788161 (cancelada, correcta), 15788166 (rechazada: la gestión de Autorización de CORE debía quedar **Rechazada**) y 15788168 (autorizada: debía anularse; la simulación del alta debe repetirse con reserva/devolución de prima = N cuando NEW/NSE la rechazan y esa marca debe llegar a la mecanización).
> Método: lectura de SCA (`SCA Finalizar Mecanización`, `SCA_ContraAnulacionDetalleAnulacionPoliza`) y SCA2 por LCP; cambios sólo en SCA2 (GET vivo → backup `sca2work/r25/` → PUT → readback). Sin PR; rama `feature/sca`.

## 1. Diagnóstico

| Caso | Qué pasó en SCA2 | Qué hace SCA | Causa en SCA2 |
|---|---|---|---|
| 15788166 RECHAZAR | ANL `ESTADO=2`, SCA2 reanudó, `actualizarMecanizacion` (estado 4) y «CERRADA SIN MECANIZAR»; la **autorización de CORE siguió pendiente** | `SCA Finalizar Mecanización` nodo «Guardar autorización»: tras la respuesta de ANL llama a `guardarAutorizacion` con `mcaAutorizada = S/N` y `codEstado = 2/3` según la póliza esté anulada (`polizaVigente = "A"`) o vigente | `SCA2 CMD Mecanizar` no llamaba nunca a `SCA2_guardarAutorizacion` (la regla existía sin uso) |
| 15788168 AUTORIZAR | Bloqueo NEW con `reservaPrima=N` pero **ANL `MCA_RESERVA_PRIMA = S`** (fila 2166; igual en 2164); «Anular Poliza NEW» no termina | La pantalla ANULAR PÓLIZA consulta NEW con reserva S y, si falla, con N, y guarda la marca que aceptó NEW (`confirReserva`) | (a) la pantalla `SCA2_MecanizacionPrincipal` pasaba a Mecanizar la marca calculada para NSE (`tointeger(null) <> 0` → "S") en vez de la de wAutemis; (b) el alta no controla la excepción de reserva/devolución de prima: `SCA2_consultarNewAlta` llamaba una sola vez con `S` si catalogación = 4 |

Petición del analista aplicada: cuando la simulación del alta devuelve la excepción «no se permite reserva de prima / devolución de prima», repetir la simulación con ese indicador a **N** y dejarlo **registrado** para la mecanización.

## 2. Cambios (TEST, app SCA2)

| # | Objeto | Versión | Cambio |
|---|---|---|---|
| 1 | Record `SCA2 Datos Solicitud` | v1 → v4 (v2/v3 sin efecto: `PUT` ignora campos nuevos; el campo se creó con `POST /record-types/{uuid}/fields`) | Campo nuevo `mcarsvprima` (TEXT, columna `MCARSVPRIMA`, uuid `a858c3df-b176-49f2-9f18-7336c9ddf748`): marca S/N con la que la simulación del alta fue aceptada |
| 2 | `SCA2_consultarNewAlta` (wAutemis) | v1 → v2 | Si la consulta a NEW con `mcaReservaPrima = S` (catalogación 4) falla y el mensaje contiene «reserva de prima», se repite con `N`. `result.mcaReservaPrima` (final) y `result.reservaPrimaForzada` |
| 3 | `SCA2_simularAnulacionAltaNse` (NSE) | v1 → v2 | Ídem con `indicadorReservaPrimas` («reserva de prima») e `indicadorDevolucionPrima` («devolución»): se repite con el indicador rechazado a `N`. `result.mcaReservaPrima`, `result.mcaDevolucionPrima`, `*Forzada` |
| 4 | `SCA2_simularAnulacion` | v16 → v17 | Devuelve siempre `{errorSimularAlta, mcaRsvPrima, mcaDevolucionPrima, reservaPrimaForzada, devolucionPrimaForzada}` (antes `null` cuando no había error bloqueante) |
| 5 | `SCA2_AltaSolicitudPage` | v37 → v38 | Pasa `mcaRsvPrima` (de `erroresSimular`) al `SCA2 CMD Alta` |
| 6 | PM `SCA2 CMD Alta` | PV nueva `mcaRsvPrima` (Text, parámetro) | Los dos Write de `SCA2 Datos Solicitud` graban `mcarsvprima` |
| 7 | `SCA2_cargarSolicitud` | v8 → v9 | Lee `mcarsvprima` → `datosSolicitud.mcaRsvPrima` |
| 8 | `SCA2_MecanizacionPrincipal` | v17 → v18 | Si `mcaRsvPrima = "N"` no se intenta la consulta/simulación con `S` (va directa a `N`). Paridad SCA: a Mecanizar viajan `mcaReservaPrima`/`importeRsvPrima` de **wAutemis** (`confirReserva`/`importeOperacion`) cuando la póliza es wAutemis |
| 9 | PM `SCA2 CMD Mecanizar` | v31 → v32 | Nodo 308 «Preparar actualización»: salida nueva `guardarAutorizacion` = `SCA2_guardarAutorizacion` (wAutemis y nivel 00000005/6; `mcaAutorizada`/`codEstado` = S/2 si la póliza está anulada, N/3 si sigue vigente; paridad SCA). Nodo 340: `reservaPrima = "S"` si la marca es "S" o "Sí" (antes sólo "Sí" → siempre N). PV nueva `guardarAutorizacion` |

No se ha tocado SCA, SCAC, CORE ni ANL. 15788166 y 15788168 no se han relanzado ni modificado.

## 3. Verificación por LCP (`/test`)

- `SCA2_consultarNewAlta` con 0001047017109, efecto 11/09/2026, catalogación 4: la 1.ª llamada (S) falla en NEW por la reserva de prima; la 2.ª (N) → `success=true`, `mcaReservaPrima=N`, `reservaPrimaForzada=true`.
- `SCA2_simularAnulacion` con el mismo contexto: `{errorSimularAlta:false, mcaRsvPrima:"N", reservaPrimaForzada:true}`.
- `SCA2_cargarSolicitud` v9 (15788168): `datos.mcaRsvPrima = null` (solicitud anterior al campo), resto igual.

## 4. Pruebas con solicitud nueva (UI)

_(se completa con el informe del agente de pruebas)_

## 5. Límite conocido

La salida «Guardar autorización» del nodo 308 sólo se ejecuta cuando ANL marca `CONCLUIDA` (criterio de espera decidido por el analista, duda #3). En PRE ANL no concluye el ciclo para solicitudes SCA2 (r23-a §7), así que en TEST sólo se puede comprobar simulando la conclusión en la fila ANL de la solicitud de prueba.
