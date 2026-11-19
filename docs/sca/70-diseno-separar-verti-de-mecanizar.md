# 70 — Diseño técnico: sacar la inducción Verti de `SCA2 CMD Mecanizar`

> Consulta de diseño (19/11/2026). Análisis en solo lectura de Appian TEST (MCP `appian-dev-mcp-c90b`). No se ha modificado ningún objeto ni dato. Copias de lo leído en `~/sca2work/verti-sep/` de la sesión.

Petición: «cuando se llama a Verti, se llama en Mecanizar, ¿verdad? […] pensar cómo se puede sacar de ese proceso, para que la instancia del proceso de mecanizar termine y el componente de Verti se ejecute, pero que funcionalmente sea igual, lo único que la instancia sea independiente una de otra».

## 1. Situación actual (comprobado en TEST)

Sí, Verti se llama dentro de `SCA2 CMD Mecanizar` (`0000f06f-4cfc-8000-66d3-7f0000014e7a`, v52).

- El usuario pulsa ANULAR PÓLIZA en `SCA2_MecanizacionPrincipal`. Ese botón es un `a!startProcessLink` a `cons!SCA2_PM_CMD_MECANIZAR`, con `inducirVerti` = selección de la pantalla Verti.
- Camino **encadenado** (el usuario se queda en «espere» mientras corre): `1 Start → 16 Cargar → 3 → 4 → 6 → 8 Guardar Mecanización → 343 → 9 → 340 Bloquear póliza en Central → 10 Crear Autorización → 342 → 11 → 13 Write Éxito → 200 → 300/301 ANL Alta → 331 ¿Inducir Verti? → 332 Write Tarea INDUCCION → 334 Inducción Verti (CMP) [SUB encadenado]`.
- `331`: induce si la solicitud no viene de una AA y el contacto (nodo 16) incluye VERTI o VENCIMIENTO.
- `332` tiene dos salidas: la encadenada a `334` y otra **sin encadenar** a `324` (rama principal: espera ANL, `305/306` actualización de la mecanización, `325/326/320` cierre y cambio de nivel, `322` Start CrearAccion).
- `334` es un subproceso **síncrono** (`isAsynchronous = 0`), con `chainsInto = 1` y `runAs = INITIATOR`. Lanza `CMP Inducir Cliente Completo` (`0002ea05-…`) con aplicacion, cliente, codCia, entidad, inducirA, nPoliza, nuuma, perfilSi24, producto, tipoInduccion (del token `VERTI:` de la tarea) y `usuarioAppian = user(pp!initiator,"username")`. Guarda `subProcessID` en `pv!induccionProcessId`.
- `333 Write cierre Tarea INDUCCION`: pone la tarea INDUCCION en COMPLETADA (con `proceso` = id del CMP) cuando el CMP termina. Después `341 End Inducción`.
- El CMP **no tiene parámetros de salida**: sus 14 variables son de entrada. Mecanizar no recibe ningún resultado.

Consecuencia: la solicitud no espera a Verti, pero la **instancia** de Mecanizar sigue ACTIVE hasta que termina el CMP. Esa espera puede durar horas o días (en TEST hay 6 instancias ACTIVE de Mecanizar del 3 al 16/11, v44 y v46).

**Por qué hoy la primera pantalla del componente se abre sola:** el encadenamiento que empieza en el `a!startProcessLink` atraviesa Mecanizar y entra en el CMP porque `334` es síncrono y encadenado.

## 2. Restricción de Appian que condiciona el diseño

Según la documentación de Appian 26.x (*Sub-Process Activity* y *Start Process Smart Service*):

| Forma de lanzar el CMP | ¿Instancia independiente? | ¿Sigue el encadenamiento (se abre la pantalla)? |
|---|---|---|
| Subproceso síncrono (hoy) | No, el padre espera | Sí |
| Subproceso asíncrono | Sí | **No**: «Asynchronous subprocesses do not allow activity-chaining» |
| Start Process asíncrono | Sí | **No**: el encadenamiento queda separado; la tarea se asigna, pero «it will not open the associated form» |
| Start Process síncrono con encadenamiento al hijo | No, el padre espera (y exige autoscale en los dos PM) | Sí |

Conclusión: **desde un proceso no se puede encadenar al usuario hacia otro proceso que sea independiente**. Si la instancia de Verti es independiente de la de Mecanizar, la primera pantalla del CMP no puede abrirse por encadenamiento desde Mecanizar. Hay que abrirla desde la interfaz.

## 3. Diseño propuesto (opción A, recomendada)

### 3.1 Nuevo proceso `SCA2 CMD InducirVerti`

- Parámetros: `idSolicitud`, `idTarea`, `usuarioAppian` y los datos que hoy calcula `334` (o calcularlos dentro a partir de `idSolicitud`).
- Nodos:
  1. `¿Ya hay INDUCCION en curso?`: idempotencia. Si existe una tarea INDUCCION PENDIENTE con CMP vivo, termina sin lanzar otro.
  2. `Write Tarea INDUCCION`: se mueve aquí desde el 332, sin cambios.
  3. `Inducción Verti (CMP)`: subproceso síncrono al CMP, igual que el 334. El encadenamiento ya no importa.
  4. `Write cierre Tarea INDUCCION`: se mueve aquí desde el 333, sin cambios.
  5. End.
- Constante nueva `SCA2_PM_CMD_INDUCIR_VERTI`.
- Ejecución como el iniciador. `usuarioAppian` se pasa explícito para que las tareas del CMP sigan asignadas al gestor.

### 3.2 Cambios en `SCA2 CMD Mecanizar`

- `331` Sí → nuevo nodo `Start InducirVerti`: Start Process asíncrono, mismo patrón que el `322 Start CrearAccion` que ya existe. Después, `341 End Inducción`.
- Se mantiene la salida sin encadenar a `324`, así que la rama principal no cambia.
- Se quitan `332`, `333` y `334`, y la variable `induccionProcessId`.
- El orden se conserva: la inducción se sigue lanzando después de Guardar Mecanización y del alta ANL (paridad R27-C), con la misma condición `331`.
- Resultado: Mecanizar termina cuando acaba su rama principal. El CMP vive en la instancia de `SCA2 CMD InducirVerti`.

### 3.3 Apertura de la primera pantalla desde la interfaz

- Al acabar el encadenamiento de Mecanizar, el usuario vuelve a `SCA2_MecanizacionPrincipal`.
- Esa pantalla muestra «COMPLETAR INDUCCIÓN VERTI»: un `a!processTaskLink` a la primera tarea del CMP del usuario conectado.
- La tarea se busca con `SCA2_obtenerTareaInduccion`, que ya busca en los PM del CMP y sus subprocesos (R26-b) y ya la usa `SCA2_DetalleTareas` para RETOMAR.
- Como la tarea puede tardar uno o dos segundos en crearse, se añade `refreshAfter`/ACTUALIZAR. Si el CMP termina sin pantallas (caso visto en R26-b, 15788275), se muestra «El componente ha terminado».
- La vía de RETOMAR desde el Detalle sigue igual.

### 3.4 Diferencia funcional que queda

- **Un clic más**: la primera pantalla del componente ya no se abre sola. El usuario pulsa «COMPLETAR INDUCCIÓN VERTI».
- Todo lo demás es igual: mismas condiciones, mismo orden, mismo CMP con los mismos parámetros, misma tarea INDUCCION y mismos estados.

## 4. Alternativas descartadas

- **B. El botón lanza Verti y Verti lanza Mecanizar.** `a!startProcessLink` a `SCA2 CMD InducirVerti`, que arranca Mecanizar asíncrono y entra encadenado en el CMP. Mantiene la apertura automática, pero el CMP correría **antes o a la vez** que Guardar Mecanización/ANL, y se induciría aunque la mecanización falle. Rompe la paridad R27-C con `SCA_Mecanizacion` y la regla del analista (doc 45: «se induce si se mecaniza»). Esperar el resultado de Mecanizar exige un temporizador, que también rompe el encadenamiento.
- **C. Start Process síncrono con encadenamiento al hijo (autoscale).** El padre sigue esperando al hijo, así que no resuelve nada.
- **D. Terminar Mecanizar con un End «terminate».** El subproceso síncrono quedaría huérfano o cancelado. Comportamiento no garantizado: descartada.

## 5. Afectación

| Ámbito | Afectación |
|---|---|
| `SCA2 CMD Mecanizar` | Nodos 331 (destino), 332/333/334 (se eliminan), nuevo Start Process, pv `induccionProcessId` |
| Nuevo PM `SCA2 CMD InducirVerti` + constante | Objetos nuevos en la app SCA2 y en el paquete a PROD |
| `SCA2_MecanizacionPrincipal` | Botón/enlace «COMPLETAR INDUCCIÓN VERTI» tras el encadenamiento |
| `SCA2_obtenerTareaInduccion` / `SCA2_DetalleTareas` (RETOMAR) | Sin cambio de firma; revisar el filtro «tareas desde que se abrió la INDUCCION» |
| Cuadro de mando (aviso de operación y tarta Verti) | Mismo dato (`SCA2 Tarea` INDUCCION). Cambia el texto: la que queda activa es la instancia de `SCA2 CMD InducirVerti`, no la de Mecanizar |
| Datos (`SCA2 Tarea`) | Sin cambios de modelo ni migración |
| Instancias en curso | Las de Mecanizar ya activas siguen en su versión hasta que vuelva su CMP. No se tocan |
| Relanzar desde la bandeja de errores | Mecanizar ya tiene la guarda `3 ¿Ya ejecutado?`. La idempotencia del paso 3.1-1 evita un segundo CMP |
| Fase 2 «Con error» en la tarta | Sale más fácil: el nuevo PM es el sitio donde registrarlo. Pero el CMP sigue sin devolver resultado: habría que leer `CMP Auditoria Inducir` / `ADM Log Servicios Componentes` |
| SCA, SCAC, CORE y CMP | Sin cambios |

Esfuerzo estimado: una ronda (PM nuevo, ajuste de Mecanizar, botón y prueba de Alta → CA → Verti → ANULAR PÓLIZA con un contacto VERTI, en TEST).

## 6. Decisión para el analista

¿Aceptan que la primera pantalla del componente Verti se abra con un clic («COMPLETAR INDUCCIÓN VERTI») en lugar de abrirse sola? Es la única diferencia visible y la impone Appian.

- Si **sí**: opción A.
- Si **no**: no hay forma de tener instancias independientes y apertura automática a la vez sin cambiar el orden acordado (opción B).
