# 21. Ronda 7: JJGONZ2 + SISANS (SI24), pólizas wAutemis normales y RCI, y dudas funcionales resueltas

Fuente: instrucciones de los analistas (nuevo usuario SISANS, pólizas wAutemis y RCI con salto de nivel) y el Excel
`SCA2_pendientes_dudas_seguimiento_SOLO FUNCIONALES.xlsx` con la resolución de parte de las 32 dudas de
[20-pendientes-y-dudas-funcionales.md](20-pendientes-y-dudas-funcionales.md). Informe UI del testing agent:
[pruebas/13-ronda7-informe-testing-agent.md](pruebas/13-ronda7-informe-testing-agent.md).

Todos los cambios siguen el procedimiento de la skill `appian` (lectura completa → backup → validación → PUT mínimo →
relectura → prueba). Backups y relecturas en `~/sca2work/r11/*_live.json` / `*_after.json` (fuera del repo).

## 1. Pruebas SCA vs SCA2 (JJGONZ2 y SISANS)

| Póliza | Usuario | App | Solicitud | Flujo | Resultado |
|---|---|---|---|---|---|
| 0000253500328 | SISANS | SCA2 | 15787863 | Alta → POSPONER → RETOMAR → CA positiva → FINALIZAR | OK, finalizada. Canal vacío al entrar y Medio deshabilitado tras elegir SI24, igual que SCA |
| 0000253500329 | SISANS | SCA | 15787864 | Alta | **Bloqueado por SCA**: modal «403 Acceso denegado» tras el alta (propio de SCA, no se modifica) |
| 0000253500286 | SISANS | SCA2 | 15787865 | Acción Administrativa nivel 2 | **ERROR técnico CORE** en `Alta gestion CORE` («Ocurrio un error en el acceso a la base de datos») con `codperfil=CE_RM` + `codsubperfil=CE_MF_SI24_EXPERTO` + nivel 2. Pendiente de confirmar la combinación perfil/subperfil que espera CORE |
| 0000253500332 | SISANS | SCA | 15787866 | Alta | Se quedó en Alta; la flecha «volver» da error `sca_datoscabecera/a!submitLink` (propio de SCA) |
| 0005726678405 (RCI) | JJGONZ2 | SCA2 | 15787867 | Alta → CA1 negativa + impresión → CA2 nivel 2 | OK. La tarea de nivel 2 se crea **sin asignadoA y con grupo `CE_MF_BK`** (corrección de `CMD CrearAccion`, antes quedaba asignada al usuario) |
| 0005726674052 (RCI) | JJGONZ2 | SCA | 15787862 | Alta | Se quedó en Alta (latencia de SCA en TEST) |

Sin ejecutar: cierre de la CA de nivel 2 con SISANS (su grupo es `CE_MF_SI24`, la tarea va a `CE_MF_BK`: ni
JJGONZ2 ni SISANS ven RETOMAR/REASIGNAR, que es lo que dicta la regla de permisos actual). No se pulsó ANULAR
PÓLIZA ni se repitieron altas durante el cierre de la ronda.

## 2. Correcciones aplicadas en SCA2 TEST

| # | Objeto | Cambio | Origen |
|---|---|---|---|
| 1 | `SCA2 CMD CrearAccion` (asignación) | Tarea de nivel ≠ 1 para perfil SI24/GGE o no CE_RM → `asignadoA = null` (al grupo), como el nodo CONTRA ANULACIÓN de SCA | Prueba 15787861 |
| 2 | `SCA2 CMD CrearAccion` nodo `Write Error` | Persiste el error técnico real (`pv!wrErrMsg`) en vez de «Accion no reconocida: …» | Diagnóstico 15787865 |
| 3 | `SCA2_AltaSolicitudAnulacionPopUp` | Solicitud abierta en CORE sólo con `codEstSolic` 1 y 2 (antes 1,2,7,8,9,10,16,17) | Excel 12b/12c |
| 4 | `SCA2_textoEstadoSolicitud` | Estado interno `ERROR` → «Pendiente» (CORE sigue en 2; el error técnico se ve en Detalle y bandeja) | 15787865 |
| 5 | `SCA2_Buscador` | Si la búsqueda devuelve un único resultado se abre directamente el Detalle (como SCA) | Excel 14 |
| 6 | `SCA2 CMD Posponer` nodo `Alta gestión SGC` | POSPONER de Autorización también da de alta la gestión SGC (`tipoAccion AUT`, payload `mSEGuardarAutorizacionDTO` probado) | Excel 18 |
| 7 | `SCA2_AltaSolicitudPage` GUARDAR | Validaciones de fecha de SCA (`SCA2_erroresGuardarSolicitud`: anterior a efecto, posterior a vencimiento, > 18 meses, anterior al último siniestro, aviso impago): si hay errores no se lanza el alta y se muestran en rojo | Excel 20 |
| 8 | `SCA2_AltaSolicitudPage` GUARDAR | Detección PRRA con `SCA2_simularAnulacionAltaNse` (código 4022) → motivo 3 / detalle 8 / causa 19 e `isPolizaPRRA` en el proceso, como SCA; motivo/detalle/causa reales se conservan en `motivoReal/detalleReal/causaReal` | Excel 22 |

Verificación: PUT 200 + relectura idéntica en todos; `SCA2_erroresGuardarSolicitud` probado por LCP (fecha
01/01/2024 → «no puede ser más antigua de los 18 meses»); `SCA2_posponerGestionSGC` con `tipoAccion AUT` probado en
modo `soloPayload`. Los puntos 6, 7 y 8 **no están probados en pantalla** todavía (ver pendientes).

## 3. Decisiones del Excel pendientes de implementar

| Duda | Decisión | Estado / necesidad |
|---|---|---|
| 13 Buscador: solicitudes históricas y creadas en SCA | «Todas» | Pendiente. SCA2 busca en su record; hay que añadir la consulta CORE (como SCA) y un Detalle de sólo lectura para solicitudes sin record SCA2. Cambio grande, propuesto para la siguiente ronda |
| 12c Oficina al RETOMAR | «Sería lo deseable» | Pendiente: no existe campo persistente (ni en Tarea, Solicitud ni Datos Básicos). Requiere un campo nuevo (p. ej. `SCA2 Tarea.codOficina`) y su columna en BBDD → necesita aprobación |
| 21 Simulación previa / Expertos en retención | «Sí» | Pendiente: popup de simulación de SCA (`showPopupSimular`) y paso a Expertos; depende de que `SCA2_simularAnulacion` devuelva datos (hoy NEW responde error de simulación en TEST) |
| 23 Vida | Crea solicitud y pasa por CA | Pendiente de diseño: el formulario SCA2 no trata Vida |
| 16/17 Grupo de nivel 2 y perfil/subperfil de Acción Administrativa nivel 2 | Sin cerrar | La tarea va a `CE_MF_BK` (motor de reglas); SISANS está en `CE_MF_SI24`. Hace falta un usuario del grupo destino o confirmar el grupo |
| Resto (DUE, reintentos, caducidad ANL, limpieza de las 75 solicitudes CORE) | Sin respuesta | Siguen en [20-pendientes-y-dudas-funcionales.md](20-pendientes-y-dudas-funcionales.md) |

## 4. Divergencias propias de SCA (no modificadas)

- Modal «403 Acceso denegado» tras el alta con SISANS (15787864).
- Flecha «volver» del Detalle: `sca_datoscabecera/a!submitLink línea 23` («The save target must be a local variable… 0000253500332»).
- Altas de SCA que se quedan en estado Alta por latencia del entorno TEST (15787862, 15787866).

## Ronda 7b — validaciones de fecha al GUARDAR, PRRA y alta válida (JJGONZ2, 0001047017036)

Informe UI completo: `pruebas/13-ronda7-informe-testing-agent.md` (sección «Ronda 7b»).

| Paso | SCA | SCA2 | Resultado |
|---|---|---|---|
| Fecha 01/01/2024 (A FECHA) | Popup de simulación NEW; tras VOLVER, error «…más antigua de los 18 meses…» | Error rojo con el mismo texto, sin alta | Igual (texto); SCA muestra antes el popup de simulación |
| Fecha 03/03/2027 (vencimiento 02/03/2027) | No probado | Error «…superior a la fecha de vencimiento…», sin alta | Validación SCA2 correcta |
| Alta válida (fecha propuesta 09/10/2026), 1.er intento | — | **403 Acceso denegado**; sin solicitud ni error en bandeja | Fallo SCA2 |
| Alta válida, 2.º intento (PRRA desactivado) | — | **ALTA_ERROR CORE 4005** `generarStudAnul` «Los datos pasados como parametro no son los esperados» (PDTE-14230000) | Fallo SCA2 |
| Alta válida, 3.er intento (fecImpagoPCA null) | — | Solicitud **15787868** creada; navega a Acciones Administrativas; cabecera «Origen IMPAGO» | Alta OK |

### Correcciones aplicadas en SCA2 TEST

1. **`SCA2_AltaSolicitudPage` — validaciones al GUARDAR.** GUARDAR evalúa `rule!SCA2_erroresGuardarSolicitud` con los mismos datos que SCA (fechas anulación/efecto/vencimiento/último siniestro, catalogación, perfil, códigos) y, si hay errores, los muestra en la zona de mensaje y **no lanza** `SCA2_PM_CMD_ALTA`. Probado en UI (18 meses y vencimiento).
2. **`SCA2_AltaSolicitudPage` — PRRA desactivado (pendiente).** La primera versión detectaba PRRA llamando a `rule!SCA2_simularAnulacionAltaNse` desde la interfaz (código 4022 → motivo 3 / detalle 8 / causa 19 e `isPolizaPRRA`, como SCA). Con JJGONZ2 el GUARDAR devolvió **403 Acceso denegado** sin llegar al proceso (sin solicitud ni error). Tras quitar esa llamada el 403 no reapareció. Hipótesis (no confirmada): privilegios del usuario final sobre la cadena `SCA2_simularAnulacionPoliza → SCA2_simularAnulacionPolizaIntegracion` (connected system `…11566210`) / `SCA2_obtenerUserPassSimularPoliza → rule!SCA_rolesUsuarioSimular`. El proceso sigue recibiendo `isPolizaPRRA` y los códigos reales, así que la detección puede hacerse en el PM (credenciales de diseño) o tras revisar la seguridad de esos objetos. El 403 de SCA con SISANS (15787864) es el mismo síntoma en la misma fase.
3. **`SCA2_construirContextoAlta` — `fecImpagoPCA: null`.** SCA2 enviaba a CORE la fecha del recibo cruda (`"02-03-2026"`) y CORE respondía 4005. SCA envía siempre `null` (`SCA_AltaSolicitudAnulacion` l.1890, «mapeo en AltaProcesoSolicitudCmd.java»). Solo afectaba a pólizas con recibo en `ESTADO_RECIBOS`; por eso las altas anteriores no fallaban.

### Observaciones / dudas nuevas

- **Destino Acciones Administrativas** con DECISION CLIENTE / VENTA VEHICULO / NO VOY A COMPRARME OTRO COCHE: lo decide CORE (`Decidir Acción`), igual que en SCA; no se ha hecho el alta espejo en SCA para confirmarlo (no repetir altas en esta ronda).
- **Cabecera «Origen IMPAGO»** en 15787868 con fecha de recibo «-»: proviene de CORE/estado de recibos de la póliza; confirmar con el analista si es el origen esperado para esa póliza.
- **SCA muestra el popup de simulación antes del error de fecha** (su `showPopupSimular` evalúa `erroresGuardar` sin refrescar). SCA2 muestra el error directamente. Se considera comportamiento más correcto en SCA2; confirmar.
- 15787868 queda en Acciones Administrativas **Incompleta**, disponible para la prueba de RETOMAR/AA con SISANS.
