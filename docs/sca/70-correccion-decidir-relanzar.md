# SCA2 — Corrección de Decidir y relanzamiento de errores

Incidencia de la solicitud **15789203**, póliza **0002729355511**, y corrección en Appian TEST (`mapfrespain-test`), 18/11/2026.

Este documento recoge el diagnóstico, los cambios y los resultados facilitados para su documentación. En esta tarea solo se ha actualizado el repositorio: **no se ha accedido a Appian ni se han repetido las pruebas**.

## 1. Problema

- **17/11, 23:26:** el alta de JJGONZ2 acabó en `DECISION_ERROR`: el motor de reglas devolvió `ERROR`, con el error **228 PENDIENTE** y el **229 BLOQUEADO**.
- **18/11, 11:00:** MASCARP relanzó el 228 desde la Bandeja y se creó el error **230**. El reintento automático (**Decidir 17603837**) sí obtuvo `CONTRAANULAR` y CrearAccion dejó la solicitud en `EN_ACCION`, con la tarea **935** y la gestión CORE **43709217 INCOMPLETA**. Pero el error 230 siguió `PENDIENTE`.
- MASCARP relanzó después los errores **230 y 231** sobre la solicitud ya en `EN_ACCION`. Decidir volvió a consultar el motor, que falló, y tras tres intentos el nodo **8 «Write Error bloqueado»** escribió `ERROR_DECISION` encima de `EN_ACCION`, con la Contra Anulación abierta.

### Causa

1. La guarda **«¿Ya ejecutado?» (nodo 4)** solo compara la clave de idempotencia de la versión actual.
2. Los nodos **«Write Decidida»** no cerraban los errores pendientes.
3. La Bandeja dejaba relanzar sin mirar el estado de la solicitud.

## 2. Cambios en Appian TEST

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2 CMD MarcarErrorRelanzado` | **v37** | El nodo 3 marca `DESCARTADO`, en vez de `RELANZADO`, cuando el comando es Decidir y la solicitud ya no está en `ERROR_DECISION`. El nodo 4 (`Comando?`) solo lanza Decidir si la solicitud sigue en `ERROR_DECISION`. |
| `SCA2 CMD Decidir` | **v25** | Los nodos 10 (`Write Decidida DETALLE`), 9 (`Write Decidida POPUP_SGO`) y 13 (`Write Destino Mecanizar`) marcan como `RELANZADO`, con `resueltoPor` y `fechaResolucion`, los `DECISION_ERROR` `PENDIENTE` o `BLOQUEADO` de la solicitud. |
| `SCA2_BandejaErrores` | **versionId 14** | `local!relanzable` oculta Relanzar en los errores `PENDIENTE` de Decidir cuya solicitud no está en `ERROR_DECISION`. |
| `SCA2_DetalleErrores` | **versionId 8** | Misma condición de `local!relanzable` para ocultar Relanzar. |

## 3. Corrección de datos de 15789203

Corrección realizada mediante **`updateRecordData` / `insertRecordData`, sin DML**:

| Registro | Antes | Después |
|---|---|---|
| Solicitud **572** | `ERROR_DECISION`, **v5** | `EN_ACCION`, **v6**; `interfazActiva=CONTRA_ANULAR`, `procesoActivo=CONTRAANULAR`, `estadoTarea=PENDIENTE`. |
| Errores **229, 232, 233 y 234** | 232 `PENDIENTE`; 229, 233 y 234 `BLOQUEADO` | `DESCARTADO` por `devin`. |

Se insertó la transición **3384**, comando **«SCA2 Correccion manual»**, de `ERROR_DECISION` a `EN_ACCION`.

La copia previa de los procesos, las interfaces y las filas está en la memoria del bot, **`files/sca2-fix-decidir-relanzar/`**, fuera del repositorio.

## 4. Pruebas

### 4.1 Relanzamiento de un error de una solicitud que ya avanzó

Relanzar el error **232** de **15789203** mediante **MarcarErrorRelanzado 10277703** no lanzó Decidir: el error quedó `DESCARTADO` y la solicitud siguió en `EN_ACCION`.

### 4.2 Regresión: solicitud en ERROR_DECISION

Relanzar el error **224** de **15789144**, que sí está en `ERROR_DECISION` (instancia **537670046**), lanzó **Decidir v25**, instancias **13431001 y 10277738**.

El motor volvió a devolver `ERROR`: se generaron los errores **235 PENDIENTE** y **236 BLOQUEADO**, y la solicitud siguió en `ERROR_DECISION`.

### 4.3 Prueba en el site

(pendiente de completar)

## 5. Sin probar

**El cierre automático de errores pendientes cuando Decidir acierta no se ha probado**, porque el motor no devolvió una acción válida en ninguna solicitud de prueba.

## 6. Comparación con SCA

**Deducción, no verificada en los objetos de SCA:** SCA trata el error de decisión dentro de la misma instancia larga y no tiene una Bandeja que relance otra decisión aparte.
