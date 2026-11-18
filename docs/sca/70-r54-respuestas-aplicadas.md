# R54 Cuadro de Mando: respuestas del analista aplicadas en TEST

Aplica las respuestas a las dudas de [69-cuadro-mando-respuestas-dudas.md](69-cuadro-mando-respuestas-dudas.md). Solo objetos SCA2 de Appian TEST, sin DDL/DML.

## Objetos

| Objeto | Cambio |
|---|---|
| `SCA2_CuadroMando` (interfaz) | v28 → v33. SAIL en `sail/62-cuadro-mando/SCA2_CuadroMando.sail` |
| `SCA2_BandejaErrores` (interfaz) | v14 → v17. SAIL en `sail/70-r54-respuestas/SCA2_BandejaErrores.sail` |
| `SCA2 CMD ProcesarLoteErrores` (modelo de proceso, nuevo) | Definición en `sail/70-r54-respuestas/SCA2_CMD_ProcesarLoteErrores.json` |
| `SCA2_PM_CMD_PROCESAR_LOTE_ERRORES` (constante, nueva) | Apunta al modelo anterior |
| `SCA2_FECHA_INICIO_DATOS` (constante, nueva) | Fecha 24/09/2026 en TEST; ajustar por entorno |

## Respuestas y cómo quedan

| # | Duda | Respuesta | Implementación |
|---|---|---|---|
| 1 | Fecha del filtro | Fecha de alta | Rótulos «Fecha de alta de la solicitud: desde/hasta» (ya filtraba por alta) |
| 2 | Calendario | El año cambiado debe verse en la caja; sin botones | El calendario de Appian solo navega y no guarda al cambiar de año. Junto a cada fecha hay un desplegable «Año» que reescribe la fecha de la caja (mismo día y mes) |
| 3 | Inicio de datos | Solo avisar | Aviso si «desde» es anterior a `SCA2_FECHA_INICIO_DATOS`; no bloquea |
| 4 | Menos registros que la BD | Nada por ahora | Sin cambios |
| 5 | Verti y Mecanizar | Quitar el aviso | Aviso de inducciones pendientes eliminado |
| 6 | Tarta de Verti | Terminada / Sin terminar | Tarta «Inducción Verti/Vencimiento» (tareas `INDUCCION`: COMPLETADA = Terminada, resto = Sin terminar) y nota con las que llevan más de 1 h sin terminar |
| 7 | Estado ERROR | Aparte como «Con error» | «Solicitudes por estado actual» usa las etiquetas funcionales de `SCA2_textoEstadoSolicitud` salvo `ERROR` → «Con error» |
| 8 | Detalle de la causa | Barras apiladas, de mayor a menor | «Causa indicada por el cliente y detalle»: causa × detalle apilado, causas por total descendente. Motivos también de mayor a menor |
| 9 | Nombre «Gestiones» | Indicador a «Pasos ejecutados» | Renombrado |
| 10 | Desglose de Finalizado | Solo etiqueta funcional | La tarta de cerradas agrupa por etiqueta funcional |
| 11 | COMPLETADA / FINALIZADA | Separadas | «Gestiones por tipo y estado»: «Cerrada por el gestor» / «Cerrada por el sistema» |
| 12 | Quitar pestaña Tareas | Solo «Tareas pendientes» al Resumen | Pestañas: Resumen, Gestiones y resultados, Servicios, Errores. Se quitan también Trazabilidad y las dos gráficas de transiciones; la gráfica de tareas pasa a «Gestiones y resultados» |
| 13 | Orden tiempo de respuesta | Por tiempo medio | Servicios ordenados por media descendente |
| 14 | Lista de errores | Una lista con Origen | «Errores recientes (procesos y servicios)» en Errores con columna Origen (Proceso / Servicio); se quita la lista de Servicios |
| 15 | Filtros de la bandeja | Mensaje «contiene»; Nodo, Código, Comando con búsqueda | Hecho; opciones de los desplegables sacadas de los valores existentes |
| 16 | Relanzar/descartar en bloque | Máx. 50, uno cada 10 s, solo PENDIENTE, un lote a la vez, sin motivo, con histórico | Ver abajo |

## Lote de errores

- La bandeja permite seleccionar filas y pulsar «Relanzar seleccionados» o «Descartar seleccionados». Sin motivo; cualquier usuario con acceso a la bandeja.
- Solo se envían los PENDIENTE (y, para relanzar, los comandos relanzables; la grabación de tréboles en TTQ queda fuera del lote). Más de 50 seleccionados desactiva los botones.
- Al lanzar se escribe en `SCA2 Transicion` una fila `idSolicitud = LOTE`, `comando = SCA2 Lote Errores`, `resultado = EN_CURSO`. Mientras la última fila de lote esté `EN_CURSO` y tenga menos de 15 min, los botones quedan desactivados y se muestra un aviso (un lote a la vez).
- `SCA2 CMD ProcesarLoteErrores` trata el primer error de la lista, espera 10 s y se lanza a sí mismo con el resto. Vuelve a leer el estado de cada error y omite el que ya no esté PENDIENTE. Relanzar usa `SCA2 CMD MarcarErrorRelanzado`; descartar marca `DESCARTADO` con usuario y fecha.
- Histórico: una fila por error en `SCA2 Transicion` (idSolicitud de la solicitud, `RELANZADO`/`DESCARTADO`, lote, error, comando y usuario) y la fila `FIN` del lote con tratados y omitidos.
- Se diseñó primero con un bucle dentro del modelo, pero la instancia se quedaba parada al volver a entrar en el gateway; por eso cada error es una instancia nueva.

## Pruebas en TEST

- `testInterface` sin errores en las 4 pestañas del cuadro y en la bandeja.
- `testProcessModel` con dos ids inexistentes: tres instancias encadenadas `COMPLETED` (omite ambos y escribe `FIN`).
- No se ha relanzado ni descartado ningún error real.
- Quedan dos instancias de prueba de versiones anteriores del modelo (12370344 y 16564192) activas, sin efecto; el MCP no las puede cancelar.

## Pendiente para otra ronda

- Estado «Con error» de la inducción Verti (obliga a tocar `SCA2 CMD Mecanizar`).
- Desglose real de Finalizado por tipo de cierre.
