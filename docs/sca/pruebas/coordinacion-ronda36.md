# Coordinación ronda 36 — observabilidad SCA2 para Process HQ

Origen: petición de cuadro de mando en Process HQ sobre SCA2 (ver `docs/sca/61-observabilidad-process-hq.md`). Una sola sesión (R36-A). Cambios detrás de la constante `SCA2_USAR_OBSERVABILIDAD` (true = registra duración y nombre de comando normalizado; false = comportamiento anterior).

## Reglas comunes
- Sólo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD. Solicitudes NUEVAS; no tocar solicitudes antiguas.
- Lectura viva → backup JSON → cambio mínimo → relectura/comparación nodo a nodo.
- Sólo se tocan las escrituras en `SCA2 Transicion` (campo `duracionMs` y, en Posponer, `comando`). La lógica funcional no cambia.

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| Constante nueva `SCA2_USAR_OBSERVABILIDAD` y regla nueva `SCA2_calcularDuracionMs` | R36-A | HECHO |
| PM `SCA2 CMD Alta`, `CMD Caducar`, `CMD CompletarAccion`, `CMD CrearAccion`, `CMD Decidir`, `CMD Finalizar`, `CMD Mecanizar`, `CMD MecanizarNSE`, `CMD Posponer` (sólo nodos de escritura de `SCA2 Transicion`) | R36-A | LIBERADO. Hecho en los 9 (Caducar y Mecanizar: quitado `local!o` sin uso; ver doc 61 §3) |
| Record nuevo `SCA2 Llamada Servicio` (tabla `sca2_llamada_servicio`) y relación `llamadasServicio` en `SCA2 Solicitud` | R36-A | HECHO |
| PM `Alta`, `CompletarAccion`, `Mecanizar`, `MecanizarNSE`, `Caducar`, `Finalizar`: 14 nodos de llamada + paso «Registrar llamada …» | R36-A | LIBERADO. Probado con solicitud 15788581 |
