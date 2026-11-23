# SCA2 — Corrección de Decidir y relanzamiento de errores

Incidencia y corrección en Appian TEST, 18/11/2026. Este informe recoge los resultados de la intervención; no se repitieron las pruebas para redactarlo.

## 1. Diagnóstico

Un alta acabó en `ERROR_DECISION`. Al relanzar, un reintento obtuvo `CONTRAANULAR`: CrearAccion dejó la solicitud en `EN_ACCION`, con la Contra Anulación abierta, pero no se resolvió el error pendiente. Otro relanzamiento volvió a llamar al motor de reglas. Tras tres fallos, «Write Error bloqueado» sobrescribió el estado bueno con `ERROR_DECISION`.

La guarda «¿Ya ejecutado?» solo comparaba la clave de idempotencia de la versión actual. Los nodos «Write Decidida» no cerraban los errores pendientes y la Bandeja permitía relanzar sin comprobar el estado de la solicitud.

## 2. Cambios en Appian TEST

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2 CMD MarcarErrorRelanzado` | v37 | El nodo 3 marca `DESCARTADO` si el comando es Decidir y la solicitud ya salió de `ERROR_DECISION`. El nodo 4 no lanza Decidir en ese caso. |
| `SCA2 CMD Decidir` | v25 | Los nodos 10, 9 y 13 («Write Decidida DETALLE», «Write Decidida POPUP_SGO» y «Write Destino Mecanizar») resuelven los `DECISION_ERROR` en `PENDIENTE` o `BLOQUEADO` como `RELANZADO`, con `resueltoPor` y `fechaResolucion`. |
| `SCA2_BandejaErrores` / `SCA2_DetalleErrores` | v14 / v8 | `local!relanzable` oculta Relanzar para errores pendientes de Decidir cuando la solicitud ya salió de `ERROR_DECISION`. |

## 3. Corrección de datos

Se restauró `EN_ACCION` con la Contra Anulación pendiente, se marcaron cuatro errores como `DESCARTADO` y se registró la transición «SCA2 Correccion manual». Se utilizaron operaciones sobre records de Appian, sin DML directo.

## 4. Pruebas registradas

| Caso | Resultado |
|---|---|
| Relanzar Decidir con la solicitud fuera de `ERROR_DECISION` | El error quedó `DESCARTADO`; Decidir no arrancó y la solicitud conservó `EN_ACCION`. |
| Relanzar Decidir con la solicitud en `ERROR_DECISION` | Arrancó Decidir v25. El motor volvió a fallar y la solicitud siguió en `ERROR_DECISION`. |
| Bandeja y Detalle, solo lectura | Relanzar visible para Decidir pendiente en `ERROR_DECISION`; oculto fuera de ese estado y para errores descartados. Alta y Finalizar pendientes conservaron Relanzar. |

**Sin probar:** el cierre automático de los errores pendientes cuando Decidir acierta; el motor no devolvió una acción válida durante la prueba.

**Comparación con SCA:** se dedujo, sin verificarlo en sus objetos, que SCA trata el error dentro de la instancia larga y no lanza una decisión aparte desde una Bandeja.
