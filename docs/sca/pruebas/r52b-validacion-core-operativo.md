# R52b — Validación con CORE operativo y límite de reintentos de Decidir (SCA2, Appian TEST)

Fecha: 17/11/2026. Entorno: Appian TEST (`mapfrespain-test`), site `/suite/sites/sca2`, usuario JJGONZ2. Continuación de [R52](r52-tareas-repetidas-usuario-real.md). Copias: [`backups-r52/`](backups-r52/).

## 1. Validación UI con CORE operativo

Pasó: site y buscador sin aviso de CORE; apertura de los detalles 15788025, 15788607, 15788673 y 15788677. Una sola tarea `PENDIENTE` por solicitud: 220, 617, 622 y 632, respectivamente; 375 y 711–714 siguen `CANCELADA`.

Observación: 15788025 muestra dos tarjetas «Mecanización Incompleta»; todavía no se han cruzado con las transiciones.

## 2. Bucle de reintentos y corrección v22

El bug de `SCA2 CMD Decidir` ya estaba en v18 y v21: `pv!intentos` se calculaba con `SCA2_contarErroresPendientes + 1`, pero «Write Error» hace upsert de una sola fila. El gateway veía siempre 2 y reintentaba sin fin.

La solicitud 15789202 (póliza 0005726681370) llegó a 99 intentos en el Error 227. Appian cortó la cadena por el límite de profundidad de subproceso 100: instancia **14473993**, v21, inicio 17/11/2026 22:19:34.690 UTC. Quedó `ACTIVE` con error hasta que un administrador de TEST la canceló el 17/11/2026 (comprobado después: getProcessInstance devuelve 404 y SCA2 CMD Decidir no tiene instancias RUNNING). El contador quedó en 99 antes y después de publicar; este cese no demuestra por sí solo la corrección.

Único cambio: nodo **5 «Consultar reglas»**, salida a `pv!intentos`. Expresiones literales del diff entre `R52b_SCA2_CMD_Decidir_v21_antes.json` y `R52b_SCA2_CMD_Decidir_v22_despues.json`:

Antes:
```text
a!defaultValue(rule!SCA2_contarErroresPendientes(idSolicitud: pv!idSolicitud, comando: "SCA2 CMD Decidir"), 0) + 1
```

Después:
```text
a!defaultValue(index(rule!SCA2_obtenerErrorPendiente(idSolicitud: pv!idSolicitud, comando: "SCA2 CMD Decidir", nodo: a!defaultValue(pv!wrNodo, "Consultar reglas"), codigo: a!defaultValue(pv!wrCodigo, "DECISION_ERROR")), "intentos", 0), 0) + 1
```

Lee el contador de la misma clave que usa el upsert de «Write Error», más 1. Sin fila devuelve 1; con contador 2 devuelve 3 y toma la rama existente `Error>=3`. Sin cambios en el resto del modelo ni en otros objetos. Publicado como **v22.0**; `validateExpression` sin errores con valores literales en lugar de `pv!` (el validador no resolvía esas referencias).

## 3. Verificación del corte y del usuario real

Alta 15789203 (póliza 0002729355511): instancias **14474013 / 10276837 / 17601725**, con `pv!intentos` **1 / 2 / 3**. «Write Error bloqueado» a las **22:27:08 UTC**: Error **228** `PENDIENTE`, intentos **2**, y Error **229** `BLOQUEADO`. El tercer intento sigue la rama de fin/error existente, sin otro reintento.

Transición **3381** y `modifiedBy` como **JJGONZ2**. Ambas altas (15789202 y 15789203) tienen `origenPoliza = wAutemis`.

## 4. Pendiente y pólizas descartadas

- Pendiente: **POSPONER/RETOMAR, CA, Acción Administrativa y RECARGAR**.
- Las altas con pólizas libres acaban en `DECISION_ERROR` (firma de [R49-A](r49-a-bloqueo-tras-espera-alta.md), causa sin confirmar) y no generan tarea.
- Descartadas: **0005726681221** y **0005726682856** (solicitud en curso), **2002600060544** (`SfConsultaCtrlTecnicos`). No usar las reservadas por R53: **0000253500305/338** y **0732100072097**.

## Comparación de la decisión SCA vs SCA2

Comparación en lectura con `testRule` sobre las reglas y las integraciones `accion` (tipo `QUERY`) de SCA y SCA2, sin UI y sin guardar nada.

| Póliza (solicitud) | SCA | SCA2 | DTO |
|---|---|---|---|
| 0005726681370 (15789202) | HTTP 500 / 1107 / ERROR | HTTP 500 / 1107 / ERROR | idéntico |
| 0002729355511 (15789203) | HTTP 500 / 1107 / ERROR | HTTP 500 / 1107 / ERROR | idéntico |

En las cuatro respuestas aparecen `CODE005` (identificador del canal del agente nulo) y `CODE011` (identificador del subcanal de la clase productora nulo). Es un problema de datos o del servicio de reglas de TEST, no una regresión de SCA2. Para probar el ciclo de tarea hace falta una póliza cuyo agente tenga canal y subcanal en TEST.

## Búsqueda de pólizas válidas

Se cribaron en lectura 15 pólizas sin solicitud SCA2 en curso y con canal/subcanal informados en `SCA2 Datos Productor`, usando el mapeador de SCA2 y la integración `accion`. Todas devolvieron HTTP 500 / 1107 con CODE005/CODE011. La traza de ejemplo es `57223e2cb7624c8c84492aed1e8de8ff` (póliza 0731700187136).

| Póliza | Solicitud histórica | Canal / subcanal |
|---|---|---|
| 0731700187136 | 15789199 | 1 / 2 |
| 0732000041110 | 15789177 | 1 / 2 |
| 2002500346247 | 15789153 | 4 / 11 |
| 0732300314838 | 15789172 | 1 / 2 |
| 0005726693313 | 15788934 | 10 / 81 |
| 0732400097946 | 15789156 | 1 / 2 |
| 0731980054928 | 15789154 | 4 / 11 |
| 2002600052339 | 15789122 | 8 / 8 |
| 0732600004219 | 15789121 | 1 / 2 |
| 2002600073945 | 15789120 | 8 / 8 |
| 0732200187237 | 15789115 | 1 / 2 |
| 2002600073939 | 15789114 | 8 / 8 |
| 0732200155595 | 15789110 | 1 / 2 |
| 2002200295382 | 15789112 | 1 / 4 |
| 2002600017649 | 15789118 | 2 / 1 |

R53 descartó además 0002729230967, 0002729296759 y 0002729392059 por el mismo error. POSPONER/RETOMAR, CA, Acción Administrativa y RECARGAR siguen bloqueados hasta que haya datos de prueba válidos o se corrija el servicio de reglas de TEST.
