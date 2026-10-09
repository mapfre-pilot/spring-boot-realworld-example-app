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
