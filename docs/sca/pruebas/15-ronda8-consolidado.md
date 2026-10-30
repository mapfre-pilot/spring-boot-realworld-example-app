# Ronda 8 — Consolidado de los 10 planes de prueba del analista (SCA vs SCA2, TEST)

Fecha: 13/10/2026. Entorno Appian TEST (`mapfrespain-test`), sites `sca-site` (SCA, referencia) y `sca2`. Usuarios: JJGONZ2 (Red Mapfre / oficina, CE_RM), SISANS (SI24 Experto) y `devin` (administrador, mantenimiento). Seis sesiones hijas (H1–H6) ejecutaron los planes en paralelo con el protocolo de `coordinacion-ronda8.md` (reparto cerrado de pólizas, reserva/liberación de cada objeto Appian antes de modificarlo, GET vivo → backup → PUT → relectura → prueba). La sesión padre cerró las correcciones que quedaron pendientes (§4).

Criterio de filtrado: sólo el Excel «Alta» tenía la columna `application_udf` informada (39 casos SCA; se descartaron PGM, Altitude, SGC, STCAT y Portal Interno). En los otros 9 Excel la columna está vacía en todas las filas y se tomaron todos sus casos como de SCA. Planes exportados en `planes/`.

## 1. Resumen global (203 casos)

| Sesión | Planes | Casos | OK igual | Corregidas | Pendientes | No probados | Informe |
|---|---|---|---|---|---|---|---|
| H1 | Alta (`manual_test`: identificación y validaciones) | 39 | 8 | 0 | 1 | 30 | `h1-plan-alta-identificacion-validaciones.md` |
| H2 | Alta (`manual_test_2`: formulario y navegación) | 34 | 10 | 0 | 0 | 24 | `h2-plan-alta-formulario-navegacion.md` |
| H3 | Contra Anular v2 + Gestión de Argumentos | 47 | 24 | 4 | 3 | 16 | `h3-plan-contra-anular-argumentos.md` |
| H4 | Pruebas de mecanización + Revisión Autorización | 24 | 7 | 0 | 3 | 14 | `h4-plan-mecanizacion-autorizacion.md` |
| H5 | Acciones Administrativas | 15 | 8 | 2 | 2 | 3 | `h5-plan-acciones-administrativas.md` |
| H6 | Gestión de solicitudes + Detalle + Gestión aplicación + Conceptos y clases | 44 | 22 | 4 | 5 | 13 | `h6-plan-buscador-detalle-mantenimiento.md` |
| **Total** | 10 planes | **203** | **79** | **10** | **14** | **100** | |

Tras la consolidación (§4) quedan corregidas **13** divergencias y pendientes **11** (3 de las 14 se han cerrado: fecha de anulación vigente en mecanización, observaciones de la tarjeta Contra Anulación y relanzamiento del error de 15787868).

Los 100 casos no probados se deben, casi en su totalidad, a datos inexistentes en TEST (pólizas NSE, Vida, Más Móvil, Ibericar, telemáticas, CCC/CCR, PRRA, corredor, Verti, campañas TTQ/PREMFIDE/RETOS/SVA, origen FDC, plan de pagos, errores M201/M206) y a que SCA TEST no es comparable en varios flujos (latencia > 25 min, 403 «Acceso denegado», tarea siguiente no generada). Ningún caso quedó sin probar por falta de tiempo salvo el flujo E de H3 (póliza 0005726679137, disponible).

## 2. Divergencias corregidas en SCA2 TEST (13)

| # | Sesión | Qué hacía SCA2 | Qué hace ahora (como SCA) | Objetos (versión) |
|---|---|---|---|---|
| 1 | H3 | `SCA2_cargarSolicitud` no devolvía `contadorPosponer`; POSPONER escribía siempre 1 | Contador real de posposiciones | `SCA2_cargarSolicitud` v4→v6 |
| 2 | H3 | RECARGAR ARGUMENTO vaciaba el argumentario (respuesta incompleta) | Se recarga la lista completa | `SCA2_ContraAnulacionOpciones` v39→v41 |
| 3 | H3 | SISANS veía las oficinas del creador (JJGONZ2) | Oficinas del usuario logado (fallback al record) | `SCA2_ContraAnulacionCompaniaCatalogacion` v3→v4 |
| 4 | H3 | Búsqueda de argumentos con resultados cacheados tras modificar | Consulta siempre viva | `SCA2_GestionArgumentos` v1→v2, `SCA2_consultarTipoArg` v1→v3, `SCA2_consultarTipoArgIntegracion` v1→v2 |
| 5 | H5 | FINALIZAR sin documentación (o causa que exige contrato sin tipo 9) finalizaba sin más | Catalogación a vencimiento, aviso funcional y actualización de CORE | `SCA2_AccionesAdministrativasPrincipal` v20→v21 |
| 6 | H5 | CANCELAR no registraba observación en CORE | Inserta la observación | `SCA2_AccionesAdministrativasPrincipal` v21 |
| 7 | H5 | Documento tipo 9 hacía fallar `SCA2 CMD CompletarAccion` | Tipos de documento permitidos por acción | `SCA2_subirDocumentosGD` v5→v6 |
| 8 | H6 | Menú de Gestión de conceptos pasaba literales `null/false` | Variables locales; Gestión de conceptos operativa | `SCA2_GestionMantenimientoMenu` v1→v2 |
| 9 | H6 | «Últimas solicitudes» sólo mostraba 10 filas | Paginación con `totalCount` | `SCA2_BuscadorTabla` v8→v11 |
| 10 | H6 | Póliza inexistente: «No hay resultados» | Mensaje de póliza no válida (texto SCA) | `SCA2_Buscador` v23→v27 |
| 11 | H6 | Causa y fechas de la fila desde el record SCA2 | Desde CORE (`consultarUltimaGestion`), como SCA | `SCA2_Buscador` v27 |
| 12 | Padre (H4/H5) | Mecanización con la fecha de anulación copiada en el alta; tras una Autorización o una Acción Administrativa que cambia la catalogación, CORE y SCA ya usaban otra fecha | Fecha vigente de CORE (cabecera `fecAnulacion`), con la copia del alta sólo de respaldo; aplica a la pantalla y al alta en ANL del comando | `SCA2_MecanizacionPrincipal` v13→v14, `SCA2 CMD Mecanizar` (nodo «ANL Alta», input `fechaAnulacion`) |
| 13 | Padre (H3 CA-30) | Tarjeta Contra Anulación del Detalle con observaciones «-» | Observaciones de la gestión CORE (misma fuente que SCA) y, si CORE no las ha consolidado aún en la gestión, las del detalle de gestión sin el prefijo «#&#usuario fecha Nivel n: » | `SCA2_DetalleSolicitud` v49→v51 |

Además, la sesión padre relanzó desde el proceso `SCA2 CMD MarcarErrorRelanzado` el error 74 de la solicitud 15787868 (`SCA2 CMD CompletarAccion`, documento tipo 9): quedó RELANZADO, el comando terminó bien (CORE abrió la gestión 5 de mecanización `43705455` y SCA2 creó la tarea MECANIZAR 155 para JJGONZ2) y no se generó ningún error nuevo. El error 73 (`SCA2 CMD Posponer` 12:18) de la misma solicitud sigue PENDIENTE: no es relanzable (la acción ya se finalizó) y se puede descartar desde la bandeja.

### Pruebas de las correcciones del padre (13/10/2026)

- `SCA2_MecanizacionPrincipal`: `testInterface` con 15787898 sin errores y fecha 24/01/2028 (CORE) en lugar de 13/10/2026 (record). UI con JJGONZ2 (agente de pruebas, grabación `sca-core-observaciones-fecha-1310`; informe `16-ronda8-informe-testing-agent-padre.md`): Detalle → Mecanización → RETOMAR muestra «Fecha anulación póliza 24/01/2028»; la tarjeta de SCA para la misma solicitud muestra «Anulación 24/01/2028» (SCA no ofrece RETOMAR en esa solicitud, la pantalla de tarea de SCA no se pudo comparar).
- `SCA2_DetalleSolicitud`: `testInterface` con 15787879 sin errores; UI: la tarjeta Contra Anulación muestra «Prueba H3 observaciones» como SCA. La primera versión (v50) mostraba el texto literal del detalle de gestión con prefijo «#&#JJGONZ2 13/10/2026 12:28:51 Nivel 1: …»; v51 prioriza la observación de la gestión (fuente de SCA) y limpia el prefijo cuando hay que usar el respaldo.
- `SCA2 CMD Mecanizar`: relectura del modelo idéntica al payload; sin instancia nueva ejecutada (ninguna póliza de reserva libre para mecanizar; la expresión es la misma que la de la interfaz probada).

## 3. Divergencias pendientes (11) — necesitan decisión funcional

| # | Sesión | Comportamiento SCA | Comportamiento SCA2 | Pregunta (doc 22 cuando existe) |
|---|---|---|---|---|
| P1 | H1 | GUARDAR activo; al pulsar avisa de los obligatorios | GUARDAR deshabilitado con tooltip hasta completar obligatorios | ¿Igualar la presentación? |
| P2 | H3 | — (plan) | SI24 no recibe las preguntas de contacto al posponer/finalizar ni el cierre «Ilocalizable con/sin contacto» a la 3.ª gestión (igual que SCA en TEST) | D2/D3 |
| P3 | H3 | Impresión activa para SI24 | Igual que SCA; el plan la espera inactiva | ¿Debe estar inactiva para SI24? |
| P4 | H3 | — | 15787893: CORE dejó la CA2 FINALIZADA NEGATIVA pero la tarea SCA2 quedó PDTE_FINALIZAR por un error de conexión CORE7 (`IGenerarContraAnul`) | Confirmar que es conectividad TEST; el error se puede relanzar desde la bandeja |
| P5 | H4 | CANCELAR autorización: CORE 4007 también con la regla de SCA | SCA2 muestra «CORRECTO» antes de conocer el fallo asíncrono y lo registra en la bandeja | ¿Cómo mostrar al usuario el fallo asíncrono? |
| P6 | H4 | Autorización pendiente (wAutemis 00000005): mensaje específico de autorización y buscador «Pendiente» | «La anulación se ha lanzado al sistema de emisión» y «Mecanización Enviada» | ¿Igualar texto y estado? |
| P7 | H5 | Tras POSPONER una AA de nivel 1, SISANS sólo consulta | SISANS ve RETOMAR | B2/B3 |
| P8 | H6 | «Últimas solicitudes gestionadas» inicial con todas las del gestor en CORE (542) | Sólo las de SCA2 (109) | ¿Debe traer todas las de CORE? |
| P9 | H6 | «Otras solicitudes de anulación» desde CORE | Desde el record por póliza | ¿Alimentar desde CORE? |
| P10 | H6 | Estado tras salto de nivel y «Pendiente» vs «Mecanización Enviada» | — | Relacionada con P6 |
| P11 | H6 | Maquetación de la pestaña Cliente e icono del hito Anulación gris | Maquetación distinta; reloj rojo | ¿Igualar? |

Sin probar por decisión: Desactivar/Activar aplicación (la variable de CORE es común a SCA y SCA2: desactivar SCA2 desactivaría también SCA).

## 4. Trabajo de la sesión padre

1. Reservas en `coordinacion-ronda8.md` de `SCA2_MecanizacionPrincipal`, `SCA2 CMD Mecanizar` y `SCA2_DetalleSolicitud`; GET vivo, backup (`~/sca2work/r12/out/*_before.json`), PUT del objeto completo, relectura idéntica, `testInterface` y UI (§2).
2. Fecha vigente de CORE en la mecanización (corrección 12). La propuesta de H4 de escribir la fecha autorizada en `SCA2 Datos Solicitud.fecanulacion` desde `SCA2 CMD CompletarAccion` no se ha aplicado: leer la fecha de CORE cubre también la Acción Administrativa (H5) y no toca el proceso compartido con la Contra Anulación.
3. Observaciones de la tarjeta Contra Anulación (corrección 13).
4. Relanzamiento del error 74 de 15787868.

## 5. Solicitudes CORE creadas en la ronda (no borrar sin autorización)

H1: 15787883, 15787892, 15787896, 15787900 · H2: 15787880, 15787885, 15787894, 15787897 · H3: 15787879, 15787887, 15787890, 15787893 · H4: 15787878, 15787881, 15787891, 15787895, 15787899 · H5: 15787882, 15787884, 15787889, 15787898 (y 15787868 de la ronda 7) · H6: 15787886, 15787888, 15787901. Detalle de póliza, usuario y recorrido en cada informe.

## 6. Limitaciones de TEST observadas por todas las sesiones

- SCA TEST: latencia > 25 min al guardar, 403 «Acceso denegado», error `a!submitLink` en `sca_datoscabecera` al volver del Detalle, tarea siguiente no generada tras el alta. Las solicitudes sí se crean en CORE.
- CORE TEST: `guardarAutorizacion` (CANCELAR) devuelve 4007 «error en el acceso a la base de datos» con cualquier cliente; `IGenerarContraAnul` falló puntualmente por conexión.
- Datos: no existen en TEST pólizas NSE, Vida, Más Móvil, Ibericar, telemáticas, CCC/CCR, PRRA, corredor, Verti, campañas ni origen FDC; SI24 no tiene preguntas de contacto configuradas.
- ANL nunca desbloquea en TEST.

## 7. Qué haría falta para completar los 100 casos no probados

Pólizas vigentes en TEST de los tipos anteriores, acuerdos/campañas activos, un usuario de perfil Expertos para los casos de simulación, acceso a Monitoring para los procesos pausados por error, y respuesta a las preguntas de `../22-dudas-funcionales-para-el-analista.md` y de la tabla §3.
