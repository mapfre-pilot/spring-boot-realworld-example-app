# 14. Tercera revisión del analista funcional: alta, vigencia y mecanización ANL

Entorno: **Appian TEST** (`mapfrespain-test`), aplicación `SCA2`; cambios aplicados por LCP API con backup previo y
relectura de los objetos modificados. Referencia funcional: **SCA TEST**. No se ha modificado ningún objeto de
SCA, SCAC ni ANL.

Fecha: 01/10/2026. Documento de entrada: `analista_texto_v3.txt`. La tabla cruza los puntos del analista con el
estado de SCA2 y sus correcciones posteriores. Los resultados detallados de interfaz se recogen en el informe
del testing agent enlazado al final.

## 14.1 Cruce punto a punto

| Punto del analista | Estado | Objeto SCA2 | Versión / backup | Evidencia |
|---|---|---|---|---|
| Alta: mostrar el detalle del error de creación (código, mensaje y paso/nodo), póliza y referencia; permitir CANCELAR tras el error y volver a BUSQUEDA | **Corregido** | `SCA2_AltaSolicitudPage` | v19 → v20; `backup_20261001_r3_SCA2_AltaSolicitudPage.json` | El detalle procede de SCA2 Error; `onError` muestra la póliza y la referencia `PDTE-`. CANCELAR limpia `esError`, `idSolGenerada` y `procesoLanzado`, y vuelve a BUSQUEDA. El error original de la póliza `2002100649057` no se reprodujo en esta pasada UI; el flujo de error se verificó por API. |
| Alta: evitar una segunda solicitud si CMD Alta ya creó la solicitud, pero la interfaz aún no recibió `idSolicitud` | **Corregido** | `SCA2_AltaSolicitudPage` | v21 → v22; `backup_20261001_r3e_SCA2_AltaSolicitudPage.json` | Para `2002000094372`, el alta `15787759` alcanzó ALTA (18:17:50), DECIDIDA (18:17:58) y EN_ACCION (18:18:01; tarea 68), aunque la UI v21 volvió al formulario sin mensaje ni redirección. v22 guarda `fechaLanzamiento` antes de iniciar el proceso y sondea `SCA2 Solicitud` por `numPoliza` (Text) y `createdAt` desde un minuto antes, ordenando de más reciente a más antiguo. `idSolEfectiva` alimenta las consultas y la tarjeta/acción OK; mientras falta, GUARDAR queda deshabilitado y se muestra el mensaje de espera. Prueba LCP `/interfaces/{uuid}/test` con `numPoliza = "2002000094372"`: HTTP 200, sin error, timeout ni truncamiento; evidencia `/home/ubuntu/sca2work/test_20261001_r3e_interface.json`. |
| GUARDAR: mostrar confirmación si existen solicitudes en el período de vigencia | **Corregido** | `SCA2_AltaSolicitudPage` | v20 → v21; `backup_20261001_r3c_SCA2_AltaSolicitudPage.json` | Las fechas se leen de `datosPoliza.fechaEfecto` y `datosPoliza.fechaVencimiento` —no de la raíz— y se convierten al tipo Date and Time de `SCA2_comprobarSolicitudesVigencia`. La confirmación existente sigue ligada a `local!solicitudVigente`. Para `2002200566753`, el período `15/11/2024–15/11/2025` no incluye solicitudes de 2026; SCA tampoco mostró confirmación, por lo que en esa prueba hubo paridad. |
| Contra-Anulación negativa + «ANULAR PÓLIZA»: encadenar la mecanización con ANL y no finalizar antes de que ANL desbloquee | **Corregido** | `SCA2 CMD Mecanizar` (`0000f06f-4cfc-8000-66d3-7f0000014e7a`) | Backup `backup_20261001c_SCA2_CMD_Mecanizar_before_anl_polling.json` | Si no existe una fila ANL para la solicitud, se crea una; después SCA2 consulta periódicamente `ANL Anulacion`. La señal de desbloqueo se detecta por `DESBLOQUEO_ANULACION` o `ESTADO`; no se usa el mensaje que ANL envía a procesos SCA. |
| Mientras ANL está pendiente, mantener la solicitud pendiente y la gestión sin cerrar | **Corregido** | `SCA2 CMD Mecanizar` | Backup `backup_20261001c_SCA2_CMD_Mecanizar_before_anl_polling.json` | El nodo 13 deja la solicitud `MECANIZADA`, `mecanizacionRealizada: false` y `procesoActivo: "ANL"`; la tarea permanece `PENDIENTE` y sin `fechaCierre`. La transición también queda en `MECANIZADA`. |
| Finalizar con el estado de anulación o rechazo correcto; si el usuario elige NO, guardar CANCELADA | **Corregido** | `SCA2 CMD Mecanizar`, `SCA2 CMD CompletarAccion` y `SCA2 CMD Finalizar` | Backups `backup_20261001c_SCA2_CMD_Mecanizar_before_anl_polling.json`, `backup_20261001c_SCA2_CMD_CompletarAccion_before_estadoFinal.json` y `backup_20261001c_SCA2_CMD_Finalizar_before_estadoFinal.json` | Tras actualizar la mecanización, Mecanizar inicia Finalizar con `FINALIZADA_ANULADA` para póliza vigente `"A"` o `FINALIZADA_RECHAZADA_ANULACION` en otro caso. CompletarAccion pasa `CANCELADA` cuando `mcaEstadoFinal` es `CANCELADO` o `"9"`; Finalizar usa `"FINALIZADA"` como valor por defecto para el resto de los flujos. |
| Mostrar los nuevos estados finales y el estado de mecanización enviada | **Corregido** | `SCA2_textoEstadoSolicitud` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20063670`) | v11 | Pruebas LCP: `CANCELADA` → «Cancelada» (`#9F9F9F`); `MECANIZADA` → «Mecanización Enviada» (`#E46B15`); `FINALIZADA_ANULADA` → «Finalizada. Anulación realizada» (`#0D82BD`); `FINALIZADA_RECHAZADA_ANULACION` → «Finalizada. Rechazada anulación» (`#BE0F0F`). |
| Construir los datos tipados que necesita ANL y mapear la matrícula del vehículo | **Corregido** | `SCA2_RecordToCdtSolicitudAnulacion`, `SCA2_construirSolicitudAnulacionAnl`, `SCA2_construirContextoSolicitudAnl`, `SCA2_construirConsultaActualizarMecanizacion` | Mapper v2 → v3; backup `backup_20261001b_SCA2_RecordToCdtSolicitudAnulacion.json`. Reglas creadas para SCA2. | Los constructores se probaron por LCP con `idSolicitud = 15787751`; el CDT de solicitud contiene la matrícula `7028CZF`, tomada de `vehiculoMatricula` y no de `vehiculoMarca`. |
| Buscador: evitar el error de Observaciones cuando `consultarUltimaGestion` devuelve una lista vacía | **Corregido** | `SCA2_BuscadorTabla` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379`) | v7 → v8; `backup_20261001_r3d_SCA2_BuscadorTabla.json` | La búsqueda de posición queda protegida para listas vacías y se normalizan los valores con `touniformstring()`. Tras el cambio, Detalle y RETOMAR de `15787757` cargaron sin 403; RETOMAR tardó aproximadamente 43 s. |
| Desplegable de causa vacío para `2002000094372` | **No reproducible** | Servicios SCA2/SCA consultados para el desplegable | Sin cambio de objeto en esta ronda | LCP mostró servicios idénticos entre SCA y SCA2; en UI v21 aparecieron las tres opciones. El vacío de la prueba anterior se atribuye a latencia del entorno. |
| Validar la anulación real y el cierre administrativo de la instancia `9994107` | **Pendiente** | `SCA2 CMD Mecanizar` / instancia de monitorización | No aplica | Queda pendiente la cancelación administrativa de `9994107` y la prueba punta a punta de un desbloqueo real de ANL. |

## 14.2 Orquestación SCA2 → ANL

El flujo añadido después del camino satisfactorio de mecanización es:

1. **300 ¿ANL ya creada?**: si existe una fila `ANL Anulacion` para `ID_SOLICITUD`, continúa en 302; si no, crea ANL en 301 y después continúa en 302.
2. **302 Esperar ANL** espera cinco minutos; **303 Consultar ANL** lee `DESBLOQUEO_ANULACION` y `ESTADO` e incrementa el contador.
3. **304 ¿ANL desbloqueada?**: si alguno de esos campos tiene valor, continúa a 308; si no, vuelve al temporizador mientras el contador sea menor que 288. Al agotar las 24 horas, el nodo 312 escribe `ANL_TIMEOUT` y deriva al nodo existente 12 (Write Error).
4. **308–309** prepara la actualización y construye la consulta de mecanización. **305 Actualizar Mecanización** llama a `SCA2_actualizarMecanizacionIntegracion`; el nodo 310 decide el resultado y permite hasta tres reintentos (`contador < 3`) mediante 311. El fallo final pasa por 315, escribe `MECANIZACION_UPDATE_FAIL` y deriva al nodo 12.
5. **306 Write Mecanización OK** actualiza los registros; 313 comprueba el resultado de escritura. En éxito, **307 Start Finalizar** pasa `estadoFinal` y termina el proceso; si falla la escritura, 314 deriva al nodo 12.

La integración ANL no puede despertar directamente al proceso SCA2: `ANL_Desbloquear` busca procesos mediante
`SCA_obtenerIdMecanizacionDesbloqueo`, que consulta analítica de `SCA_PM_MECANIZACION`. Por eso SCA2 sondea la
fila `ANL Anulacion`. `ANL_Desbloquear` escribe `ESTADO`/`DESBLOQUEO_ANULACION` con `ANL_updateAnulacion` en el
nodo 3, antes de «Desbloquear Póliza en Central». **Cualificación pendiente:** si esta última operación falla,
SCA2 podría detectar ya los campos escritos y continuar, mientras que el proceso SCA basado en el mensaje
seguiría esperando. El estado final de SCA2 se vuelve a decidir mediante `SCA2_polizaVigente` (CORE).

## 14.3 Hallazgos y límites de la prueba

- La solicitud de alta de SCA2 para `2002100649057` no falló esta vez. La solicitud `15787757` pasó de ALTA
  (17:52:45) a DECIDIDA y EN_ACCION (17:52:58), con la tarea 67 `CONTRAANULAR`; por tanto, la presentación del
  error se verificó por API, no reproduciendo un fallo en UI.
- En la reproducción tardía de `2002000094372`, GUARDAR se pulsó a las 18:17:13 UTC; CMD Alta tardó
  aproximadamente 37 s en generar `15787759`, y la UI v21 volvió al formulario unos 60 s después con GUARDAR
  activo. v22 añade la recuperación del ID y el estado de espera. La prueba LCP de interfaz v22 tuvo
  `diagnostics.error = null`, `timedOut = false` y `truncated = false`; no se pulsó ningún control.
- La espera de aproximadamente 350 s terminó mostrando 403 en la prueba inicial. Tras el guard de
  `SCA2_BuscadorTabla`, Detalle y RETOMAR de `15787757` cargaron sin 403; la latencia del entorno sigue siendo
  observable.
- El flujo de sondeo y finalización de ANL está implementado, pero la secuencia completa con un desbloqueo real
  no se ha ejecutado. También sigue pendiente la cancelación administrativa de la instancia `9994107`.

## 14.4 Correcciones posteriores y trazabilidad LCP

### r3g — `numGestion` de la solicitud correcta

En `SCA2_CMD_Mecanizar` (UUID `0000f06f-4cfc-8000-66d3-7f0000014e7a`), nodo 8 «Guardar Mecanización», se
cambió la salida `numGestion` para seleccionar la gestión de la solicitud actual, en vez de devolver el
`numGestion` de todas las gestiones del usuario. El modelo expone `versionId` vacío por LCP, por lo que no hay
una versión numérica que consignar.

La verificación de extremo a extremo encontró exactamente una fila ANL por solicitud, con `NUM_GESTION`
correcto, y `SCA2 Error` vacío:

| Solicitud | `NUM_GESTION` | Código | Observación |
|---|---:|---|---|
| `15787761` | `43704999` | `GPC55-0015787761-1` | Fila creada a las 18:54:03 UTC |
| `15787764` | `43705012` | — | Una fila |
| `15787765` | `43705017` | — | Una fila |

Backup: `/home/ubuntu/sca2work/backup_20261001_r3g_SCA2_CMD_Mecanizar.json`. Diff del nodo 8:
`/home/ubuntu/sca2work/diff_r3g_Mecanizar_node8.patch`. Pruebas y selección:
`/home/ubuntu/sca2work/test_20261001_r3g_consultarUltimaGestionREST.json` y
`/home/ubuntu/sca2work/test_20261001_r3g_python_selection.json`. El resultado UI de las tres solicitudes se
resume en [el informe 08](pruebas/08-ronda3-informe-testing-agent.md).

### r3h — ocultar RETOMAR/REASIGNAR durante ANL

`SCA2_DetalleSolicitud` (UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572`) pasó de v37 a **v38**:
las acciones RETOMAR/REASIGNAR quedan ocultas para tareas MECANIZAR mientras `procesoActivo = "ANL"`. Se
confirmó en UI después de recargar la página.

Backup: `/home/ubuntu/sca2work/backup_20261001_r3h_SCA2_DetalleSolicitud.json`. Diff:
`/home/ubuntu/sca2work/diff_r3h_DetalleSolicitud.patch`. Pruebas de interfaz:
`/home/ubuntu/sca2work/test_20261001_r3h_DetalleSolicitud_15787759.json` y
`/home/ubuntu/sca2work/test_20261001_r3h_DetalleSolicitud_15787751.json`.

### r3i — señal inmediata de ANULAR y refresco de Detalle

- `SCA2_MecanizacionPrincipal` (UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481`) pasó de v9 a
  **v10**. Se añadió la entrada Boolean `onAnular` y se guarda al terminar ANULAR PÓLIZA. Backup:
  `/home/ubuntu/sca2work/backup_20261001_r3i_SCA2_MecanizacionPrincipal.json`; diff:
  `/home/ubuntu/sca2work/diff_r3i_SCA2_MecanizacionPrincipal.patch`; prueba:
  `/home/ubuntu/sca2work/test_20261001_r3i_MecanizacionPrincipal_15787761_71.json`.
- `SCA2_DetalleTareas` (UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554`) pasó de v14 a **v15**.
  La señal `onAnular` hace visible de inmediato la línea de envío, sin esperar el sondeo de ANL; se eliminó
  así el ACEPTAR intermedio observado en D. Backup:
  `/home/ubuntu/sca2work/backup_20261001_r3i_SCA2_DetalleTareas.json`; diff:
  `/home/ubuntu/sca2work/diff_r3i_SCA2_DetalleTareas.patch`; prueba:
  `/home/ubuntu/sca2work/test_20261001_r3i_DetalleTareas_15787761_MECANIZAR_71.json`.
- `SCA2_DetalleSolicitud` (UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572`) pasó de v38 a **v39**.
  `local!sol` y `local!gestionesCore` se actualizan cada 30 segundos mientras corresponde; las cuatro consultas
  locales también se refrescan si cambia `ri!idSolicitud`. Backup:
  `/home/ubuntu/sca2work/backup_20261001_r3i_SCA2_DetalleSolicitud.json`; diff:
  `/home/ubuntu/sca2work/diff_r3i_SCA2_DetalleSolicitud.patch`; pruebas:
  `/home/ubuntu/sca2work/test_20261001_r3i_DetalleSolicitud_15787761.json` y
  `/home/ubuntu/sca2work/test_20261001_r3i_DetalleSolicitud_15787751.json`.

### r3j — navegación completa al aceptar en MECANIZACIÓN

`SCA2_DetalleTareas` (UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554`) quedó en **v17**. El primer
PUT creó v16, pero una prueba detectó temporalmente un error de parámetros de `if`; se corrigió en minutos y
se volvió a publicar. El ACEPTAR final de MECANIZACIÓN ahora navega en la misma pestaña al buscador, lo que
recarga el documento y evita el Detalle obsoleto visto en D (`15787761`) y F (`15787764`). El sondeo de v39,
por sí solo, no quedó demostrado como solución: F siguió mostrando CA Incompleta y RETOMAR hasta F5. La
navegación v17 sí pasó la comprobación en G (`15787765`, póliza `2002000068248`) sin F5.

Backup de v15: `/home/ubuntu/sca2work/backup_20261001_r3j_SCA2_DetalleTareas.json`; backup adicional del
v16 temporal: `/home/ubuntu/sca2work/backup_20261001_r3j_SCA2_DetalleTareas_v16_before_fix.json`. Diff final
v15→v17: `/home/ubuntu/sca2work/diff_r3j_SCA2_DetalleTareas.patch`. Pruebas finales v17:
`/home/ubuntu/sca2work/test_20261001_r3j_DetalleTareas_15787764_mecanizacion_75_v17.json` y
`/home/ubuntu/sca2work/test_20261001_r3j_DetalleTareas_15787761_grid_v17.json`. El test fallido del v16 se
conserva en `/home/ubuntu/sca2work/test_20261001_r3j_DetalleTareas_15787764_mecanizacion_75.json`.

## Resultados de prueba UI

La evidencia completa, incluidas capturas, tiempos y límites de cada pasada, está en el
[informe de pruebas UI de ronda 3](pruebas/08-ronda3-informe-testing-agent.md). Resumen:

- **D — `15787761` / póliza `2002000026784`.** La pasada inicial del informe 08 (DetalleTareas v14) mostró
  primero sólo «Los datos se han guardado correctamente» y requirió otro ACEPTAR para volver al buscador.
  Con r3i/v15 la línea «La anulación se ha lanzado al sistema de emisión.» quedó visible en la primera card y
  se eliminó ese ACEPTAR intermedio. r3g verificó una sola fila ANL con `NUM_GESTION=43704999` y `SCA2 Error`
  vacío.
- **E — `15787763` / póliza `2002000032024`.** Tras CANCELAR desde NSE, el buscador mostró «Cancelada» en
  gris `#9F9F9F`. La póliza `2002000011520` no se usó porque estaba bloqueada por una solicitud SCA pendiente.
- **B — SCA `15787762` / póliza `2002000041364`.** SCA mostró el mismo «Se va a redirigir a la anulación.»
  que SCA2 en FINALIZAR de la CA. No se pulsó ANULAR en SCA.
- **C — póliza `2002000094372`.** Se mostró el texto exacto «Está grabando una solicitud con los mismos datos
  que la anterior. ¿Desea continuar?». Se eligió No y no se creó una solicitud nueva.
- **F — `15787764` / póliza `2002000042310`.** Con r3i/v15 se vio la primera card con ambos textos y un único
  ACEPTAR al buscador, pero al abrir Detalle sin recargar seguían CA Incompleta y RETOMAR, incluso tras más
  de dos minutos. F5 mostró CA Finalizada Negativa y ocultó RETOMAR/REASIGNAR.
- **G — `15787765` / póliza `2002000068248`.** Con r3j/v17 un único ACEPTAR hizo una navegación completa en
  la misma pestaña. Al abrir Detalle sin F5 se vieron CA Finalizada Negativa, Impresión Finalizada y
  Mecanización Incompleta, sin RETOMAR/REASIGNAR. El buscador mostró una única fila, «Mecanización
  Enviada» en naranja `#E46B15`.

En la repetición F y en G se observó la primera card con los mensajes de guardado y envío; en G también se
confirmó la navegación completa con un único ACEPTAR. Sin embargo, el desbloqueo de ANL y la finalización
posterior no se alcanzaron en estas pasadas.

Grabaciones citadas como referencia (los vídeos y capturas no se incluyen en este repositorio):

- `/home/ubuntu/screencasts/sca-ronda3-v38-clean/sca-ronda3-v38-clean-edited.mp4`
- `/home/ubuntu/screencasts/sca-retest-f-v10-v15-v39/sca-retest-f-v10-v15-v39-edited.mp4`
- `/home/ubuntu/screencasts/sca-retest-g-v17/sca-retest-g-v17-edited.mp4`

## Pendientes y limitaciones

- A las **19:45 UTC**, las filas ANL de `15787761`, `15787764` y `15787765` seguían con `ESTADO` y
  `DESBLOQUEO_ANULACION` nulos y `CONCLUIDA=false`. Las solicitudes permanecían `MECANIZADA`,
  `procesoActivo="ANL"` y `mecanizacionRealizada=false`, estado esperado mientras ANL siga pendiente.
- No se verificó de extremo a extremo la secuencia de sondeo tras el desbloqueo, actualización de mecanización
  en CORE y Finalizar. Tampoco se comprobó el timeout de 24 h (`ANL_TIMEOUT`).
- `15787759` conserva la instancia padre `526741` en «Esperar ANL» sin fila ANL; es un intento previo a la
  corrección de `numGestion` y alcanzará `ANL_TIMEOUT` tras 24 h si no se resuelve. El proceso hijo `526742`
  terminó en el intento anterior con `Data too long for column 'NUM_GESTION'`. Se requiere decisión
  administrativa.
- El error de alta para `2002100649057` no se reprodujo en UI; esa ruta se verificó por API.
- La instancia de monitorización `9994107` todavía requiere cancelación administrativa.
- El alcance de la búsqueda histórica SCA/CORE sigue pendiente de decisión del usuario.
