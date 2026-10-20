# R23 — Pruebas UI (20/10/2026, SCA2 TEST)

Usuarios: JJGONZ2 (Oficina), SISANS (SI24 Experto), devin (mantenimiento). Sólo datos nuevos.

## A. Consulta de los casos del analista (sin acciones)
| Solicitud | Póliza | Resultado |
|---|---|---|
| 15788140 | 0000253500327 | Verti previa FINALIZADA 15:49:46 → Mecanización 15:49:47 → Emisión `00000004` → tarjeta «Mecanización Incompleta / MECANIZACIÓN INCOMPLETA» (CORE) + **CA nivel 2** pendiente (R23-1). ANL Alta: NEW `M518` (R23-3). |
| 15788143 | 0000253500334 | Igual que 15788140 (16:00:32 / 16:00:33). |
| 15788145 | 0000253500337 | Sólo Alta + CA incompleta (el analista no la finalizó). |
| Mantenimiento | — | Tras ACTUALIZAR sólo lista 15787878 (correcto: las anteriores no están en espera ANL). |

Vídeo: `~/screencasts/sca2-r23-consulta-tres/…-edited.mp4`. Capturas `ss_24b673b8`, `ss_fe61785e`, `ss_9384803a`, `ss_1f1c9575`.

## B. Nivel 2 con póliza «deriva» nueva — 15788148 / 0005726681713
1. Alta 16:59:32 (sólo ofrecía A VENCIMIENTO 08/02/2027) → CA negativa 17:02 (COMPROMISOS) → **Verti previa** (flujo nuevo) → CONTINUAR sin marcar 17:06 → motor `NO_MECANIZAR` → **NIVEL 2** → `CORE_ALTA_GESTION` «error en el acceso a la base de datos» (**R23-4**).
2. `SCA2_altaGestionCore` v7 → relanzamiento desde la bandeja 17:20:08 → CA nivel 2 creada 17:20:13 (grupo SI24 EXPERTOS). La tarjeta mostraba Nuuma JJGONZ2 (CORE) → `SCA2_DetalleSolicitud` v58: «-» hasta retomar / usuario que retoma.
3. SISANS RETOMAR → tarjeta «SISANS» → FINALIZAR NEGATIVO 17:28:37 → error externo `IMPR_GUARDAR_FAIL` (CORE PRE «Failed to connect …/IGenerarContraAnul») → relanzado 17:32:40 OK → 2ª Verti previa 17:33 → CONTINUAR → motor `NO_MECANIZAR` → nivel 3 → `FIN` → **FINALIZADA 17:35** («FINALIZADO NEGATIVO CON CONTRAANULACIÓN», nivel 3).
4. v59: la CA nivel 2 finalizada conserva Nuuma SISANS (`ss_822988b6`).

Resultado: **nivel 2 PASA** (alta CORE, retomar, finalizar, cambio a nivel 3 y fin). No hubo mecanización → no sirve para el caso pendiente de autorizar. Vídeo: `~/screencasts/sca2-r23-b-recuperacion-core/…-edited.mp4`.

## C. Caso pendiente de autorizar + bloqueo NEW + ANL completo — 15788149 / 0005726682097
Vía: AA por venta del vehículo (motivo 1 / detalle 5 / causa 14, como 15788111) → Mecanización → `00000005` → ANULAR PÓLIZA → mantenimiento AUTORIZAR. Alta 17:45:11; aviso «se anulará al vencimiento» con DNI + contrato con traspaso (esperado, confirmado por el analista en R12). Resultado: pendiente de completar (ver §C.1 cuando se cierre).

## Descartes
- «Derivan» con solicitud previa en SCA: 0005726674052, …4055 (15787900), …4004 (15787861), …8312, …8405 (15787867). Sin solicitud previa (servicio `consultaSolicitudes`): ver `~/sca2work/r23/derivan_check.txt`.
