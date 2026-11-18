# R55 — Alta parada en «Write Datos» por `left(null, 255)` y texto de espera

Entorno: Appian TEST (`mapfrespain-test`), aplicación SCA2. Fecha: 18/11/2026. Nada en PRO.

## 1. Incidencia

«En el siguiente caso, cuando le hemos dado a comprobar. El sistema dice "No vuelva a pulstar guardar..." Pero no hay ningún botón guardar. Además todas las pólizas se están quedando aquí. No consigo pasar de este punto. No aparece tampoco en la consola de errores». Pantalla: espera de `SCA2_AltaSolicitudPage` (póliza de ejemplo 2002600081162).

## 2. Causa

- En `SCA2 CMD Alta` v48, nodo 8 «Write Datos», el campo `fecimpresion` de `SCA2 Datos Solicitud` (recorte a 255 de R50-B) era
  `left(if(a!isNullOrEmpty(obs), null, tostring(obs)), 255)`.
  Sin observaciones el `if` devuelve `null` y `left(null, 255)` da «A null parameter has been passed as parameter 1».
- El fallo es de **evaluación de la expresión de entrada** del nodo: Appian no llega a ejecutar la escritura, el nodo queda en error y la instancia sigue ACTIVE. La pantalla no recibe nunca la decisión y se queda en la espera adicional.
- Desde que se publicó v48 (17/11 10:57 UTC) fallaba toda alta sin observaciones.

## 3. Cambios (TEST)

Antes de guardar se comprobó que la versión viva era la leída (nadie había guardado mientras tanto). Copias y comparaciones en `backups-r55/`.

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2 CMD Alta` (`0000f06f-28fc-8000-6693-7f0000014e7a`), nodo 8 «Write Datos» | 48 → 49 | `fecimpresion: if(a!isNullOrEmpty(obs), null, left(tostring(obs), 255))`. Salidas `ErrorOccurred → wrErr` y `Error → wrErrMsg` (ver §4). |
| `SCA2 CMD Posponer` (`0000f06f-8a47-8000-6751-7f0000014e7a`), nodo 5 «Write Posponer» | 19 → 20 | `fecimpresion: if(a!isNullOrEmpty(pv!motivo), <fecimpresion actual>, left(tostring(pv!motivo), 255))` (antes `left(...)` fallaba si no había motivo ni observación previa). Salida `ErrorOccurred → wrErr`. |
| Constante `SCA2_TXT_ESPERA_DECISION_ADICIONAL` | versionId 2 → 3 | «El sistema está tardando en responder más de lo habitual. Espere, por favor: su solicitud se está procesando. No vuelva a dar de alta la solicitud ni cierre la pantalla.» |

Comparación exportada: `backups-r55/SCA2_CMD_Alta_v48_v49.diff`, `SCA2_CMD_Posponer_v19_v20.diff`, `SCA2_TXT_ESPERA_DECISION_ADICIONAL_v2_v3.diff`: solo cambian las líneas anteriores.

Con observaciones el resultado es el mismo que antes (`left(tostring(obs), 255)`). Sin observaciones se guarda `null`.

En Posponer no se conecta `Error → wrErrMsg` porque los nodos 6-8 (SGC, observación CORE, documentos) guardan su mensaje en `wrErrMsg` y se pisaría.

Publicar por MCP deja el PM publicado por `devin`. En `SCA2 CMD Alta` el único Start Process («Start Decidir», nodo 12) ya está en `runAs: INITIATOR` (R52) y los Write graban `pp!initiator`, así que el histórico conserva al usuario real (comprobado en §6).

### Revisión de otros `left`/`right`/`mid` (todos los PMs SCA2)

| PM / nodo | Expresión | Riesgo |
|---|---|---|
| Alta 8 `fecimpresion` | `left(if(...null...), 255)` | **Fallaba**. Corregido. |
| Posponer 5 `fecimpresion` | `left(if(vacío, fecimpresion actual, motivo), 255)` | **Fallaba** si no hay motivo ni observación previa. Corregido. |
| CompletarAccion 5 `fecimpresion` | `left(tostring(obs), 255)` | Sin riesgo: `tostring(null)` = "". |
| Alta 4/5/7/14/207, Caducar, Finalizar, Mecanizar, MecanizarNSE, CompletarAccion (mensajes de error y `idSolicitud` de llamadas) | `left(tostring(...))`, `left(a!defaultValue(...,""))`, concatenaciones, o `and/or` con la comprobación de vacío delante | Sin riesgo. |
| CrearAccion 9/34, Mecanizar 7 `tokenTarea` | `left("VERTI:" & ..., 64)` | Sin riesgo (concatenación). |
| Decidir 13/14 `left(pv!destinoMecanizar, 9)` | Fallaría si `destinoMecanizar` es nulo | **No se toca** (Decidir lo modifica otra sesión). Solo se evalúa en la rama tras mecanizar; anotado como propuesta P3. |

## 4. Por qué no sale en la consola de errores

- La consola (`/errores`) lee el record `SCA2 Error`. Los PMs lo rellenan con su rama «¿Write fail?» → «Capturar error escritura» → «Write Error», que depende de la salida `ErrorOccurred` del Write (`PauseOnError = false`).
- Un error de **evaluación de una expresión de entrada** no es un fallo de escritura: el nodo no se ejecuta, no hay `ErrorOccurred` y el flujo no avanza. Appian lo deja como error del nodo en la instancia (y avisa a los grupos de alertas del PM, `alertConfigured = true`). SAIL no tiene try/catch, así que el propio proceso no puede capturarlo.
- Además, en «Write Datos» (Alta 8) y «Write Posponer» (Posponer 5) las salidas `ErrorOccurred`/`Error` **no estaban conectadas** a `wrErr`/`wrErrMsg` (ya en las copias de R52, v46). Un fallo real de escritura (p. ej. longitud de columna) tampoco habría llegado a `SCA2 Error`: el XOR «¿Write fail?» siguiente siempre iba por «no» y el alta continuaba sin datos. Se han conectado (cambio técnico sin cambio de flujo: el XOR y la rama de error ya existían). Ahora un WRITE_FAIL en esos nodos se registra en `SCA2 Error` y se puede relanzar como los demás.

Propuestas (no implementadas, cambian el comportamiento visible o requieren decisión):

- **P1. Detector de instancias paradas**: proceso planificado (o aviso en el cuadro de mando) que liste instancias de `SCA2 CMD *` ACTIVE con error de nodo más de N minutos y escriba una fila en `SCA2 Error` (código `NODO_PARADO`) con el `idSolicitud` y el nodo. El relanzamiento de esos casos no sería el habitual (la instancia sigue viva), por eso se deja a decisión.
- **P2. Espera agotada en el alta**: la pantalla ya tiene `SCA2_TXT_ESPERA_AGOTADA` tras `SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS`; revisar si debe indicar «contacte con soporte» con el número de solicitud cuando la instancia está en error.
- **P3. Decidir 13/14**: proteger `left(pv!destinoMecanizar, 9)` con `a!defaultValue(pv!destinoMecanizar, "")` cuando la otra sesión libere `SCA2 CMD Decidir`.

## 5. Las cinco instancias paradas (no se ha tocado nada)

| Instancia | Inicio (CET) | Póliza | Solicitud CORE | Estado CORE (`consultarSolicitudes`) |
|---|---|---|---|---|
| 801006 | 18/11 10:58 | 0732000079235 | 15789208 | codEstSolic 2 |
| 801060 | 18/11 11:14 | 2002600081162 | 15789209 | codEstSolic 2 |
| 10279314 | 18/11 11:29 | 2001900000936 | 15789210 | codEstSolic 2 |
| 9225358 | 18/11 11:33 | 2001900000943 | 15789211 | codEstSolic 2 |
| 13430821 | 18/11 11:48 | 2001900000988 | 15789212 | codEstSolic 2 |

Todas sin observaciones, iniciadas por JJGONZ2, en v48, paradas en el nodo 8. En SCA2 no existen `SCA2 Solicitud` ni `SCA2 Datos Solicitud` de esas solicitudes (Write Datos es anterior a Write Solicitud).

- **Reintentar el nodo** en la instancia no sirve: sigue en v48 y vuelve a evaluar `left(null, 255)`. Solo funcionaría editando la variable `datosContexto` de cada instancia (poner una observación), lo que cambia los datos del cliente: no se recomienda.
- **Repetir el alta en SCA2** no reanuda: la página de alta no pasa `idSolicitudExistente`, así que «¿Reanudar?» va por «no» y vuelve a llamar a `generarStudAnul`, con la solicitud de CORE todavía en curso (estado 2) para la misma póliza.
- **Propuesta**: (a) cancelar las cinco instancias (Designer > Monitorización); (b) decidir qué se hace con las cinco solicitudes de CORE: anularlas/cerrarlas en CORE para que las pólizas queden libres y el usuario repita el alta en SCA2 (ya con v49), o mantenerlas y reconstruir sus datos SCA2 (requeriría un proceso o script específico, más arriesgado). Recomendación: (a) + cerrar en CORE + repetir alta.

## 6. Pruebas

Usuario funcional JJGONZ2 en `/suite/sites/sca2`, pólizas del bloque `polizas/bloque-R55.txt` (libres según `SCA2_consultarSolicitudes`). Capturas en `capturas-r55/`.

| Caso | Póliza | Solicitud | Instancia Alta | Resultado |
|---|---|---|---|---|
| A · sin observaciones | 0732400035057 | 15789213 | 11318015 · v49 · COMPLETED | Alta y datos SCA2 grabados; `fecimpresion` vacío; `wrErr = false`. |
| B · 240 caracteres (máximo de la pantalla) | 0732100072097 | 15789214 | 537670098 · v49 · COMPLETED | `fecimpresion` con los 240 caracteres completos. |

- Histórico: «Nuuma de usuario: JJGONZ2» en ambas fichas; transiciones 3385 y 3386 `ALTA / OK` con `JJGONZ2@mapfrenopro.onmicrosoft.com`. Ningún rastro de `devin`.
- El texto nuevo de espera adicional se mostró en A.
- Ningún `SCA2 Error` de `SCA2 CMD Alta`.
- **No llegan a la gestión**: `SCA2 CMD Decidir` (10278143 y la de B) termina con `accion = "ERROR"` y registra `DECISION_ERROR` en «Consultar reglas» (`SCA2 Error` 237-240); la pantalla muestra el error de decisión y ACEPTAR vuelve al buscador. No viene del cambio de Alta: las Decidir de las 10:01 UTC (v22, antes de los cambios de la otra sesión) ya devolvían `ERROR`. Decidir lo está modificando la sesión 9801c384; no se ha tocado. Los errores no se han relanzado.
- Recorte a más de 255: la pantalla de alta limita las observaciones a 240 caracteres, así que no se puede alcanzar desde la UI. Con observaciones la expresión es la misma que antes (`left(tostring(obs), 255)`).
- `SCA2 CMD Posponer` v20 no se ha probado en UI (no forma parte de estas altas).

Pendiente: repetir A y B hasta la gestión cuando el servicio de decisión responda.
