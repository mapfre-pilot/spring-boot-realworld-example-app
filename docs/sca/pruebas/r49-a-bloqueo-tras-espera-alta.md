# R49-A — Bloqueo tras ACEPTAR después del aviso de espera del alta (INC-06, Appian TEST)

Sesión hija R49-A. Entorno: Appian TEST, site `/suite/sites/sca2` (referencia: SCA, `/suite/sites/sca-site`). Usuario de las pruebas: SISANS (Si24 experto), como el analista. Solo se ha modificado SCA2. Coordinación: `coordinacion-ronda49.md`; copias y diff: `backups-r49/`; capturas: `capturas-r49/r49a-*`.

Nota sobre la skill `appian`: no aparece como skill de Devin en esta sesión; se ha usado su copia en disco del bundle del MCP (`~/appian-dev-mcp-server/skills/appian/SKILL.md`).

## 1. Resumen

| | |
|---|---|
| Qué pasa en SCA2 | Tras GUARDAR y ACEPTAR, sale «Su solicitud se está generando…» con COMPROBAR AHORA; a los ~15–30 s cambia a «Su solicitud se ha generado correctamente. Acepte para abrir la gestión correspondiente»; ACEPTAR abre el Detalle, que solo tiene «Alta Solicitud – Finalizada»: no hay gestión, ni aviso, ni botón. El buscador la muestra como «Solicitud Pendiente». |
| Qué hace SCA con el mismo caso | Muestra «Se ha producido el siguiente error en el servicio de decisión:» y un botón OK que vuelve al buscador. La solicitud queda creada («Solicitud Pendiente»). |
| Causa | El **servicio de reglas (decisora) falla** para esa póliza. SCA2 deja la solicitud en `ERROR_DECISION` sin tarea, pero la pantalla del alta trataba ese estado como «decisión lista» y decía «generada correctamente». |
| ¿Lo provocó R48-A? | **No.** La condición que da por lista la decisión es anterior (v53 y antes, R35/R41). Ya había solicitudes así antes de R48-A: 15788200 (21/10), 15788369 (26/10), 15788391 (28/10). R48-A solo añadió la salida de 90 s y la apertura directa de la gestión. |
| Corrección | `SCA2_AltaSolicitudPage` v54→v55 + constante nueva `SCA2_TXT_ERROR_SERVICIO_DECISION` v1: con `ERROR_DECISION` se muestra el texto de SCA y el número de solicitud, y ACEPTAR vuelve al buscador. |

## 2. Solicitud del analista (solo consulta)

- Solicitud **15788918**, póliza 2002600074290 (IMPULSO TODO RIESGO, corredores), SISANS / CE_MF_SI24, creada 12/11/2026 11:47 (hora de España). DECISION DE CLIENTE / PRODUCTO / EL PRODUCTO NO SATISFACE AL CLIENTE, telefónico, a vencimiento 23/11/2027.
- Estado SCA2: `ERROR_DECISION`, paso «Consultar reglas». **No se creó ninguna tarea siguiente**: ni Si24, ni Verti, ni otra. No es una tarea que SCA2 no sepa abrir: no existe.
- Errores `SCA2 Error` 216, 217 (PENDIENTE) y 218 (BLOQUEADO), de 11:47:16 a 11:47:27: `SCA2 CMD Decidir / Consultar reglas / DECISION_ERROR`, con respuesta `accion = ERROR` (la integración no ha devuelto éxito).
- Capturas: `r49a-0-analista-15788918-buscador.png`, `r49a-0-analista-15788918-detalle.png`, `r49a-0-analista-15788918-solicitud-pendiente.png`.

**Por qué falla el servicio.** Hoy, con los mismos datos y llamando solo para leer (`SCA2_scaServiciosReglas`, uso QUERY), el servicio de reglas responde **HTTP 500**, código 1001: «Error en procesamientos de primer nivel en SCA – Error al consultar search en Cliente REST API Business Clients 404». Detrás: «No se han encontrado registros» en la API de Clientes. El cliente de la póliza no está en la API de Clientes de TEST. El fallo se repite siempre con esa póliza: no es un servicio lento. En un barrido de 40 pólizas vecinas (2002600074270–309) fallan igual 74272, 74290, 74293 y 74304; las demás devuelven `CONTRAANULAR`.

**Por qué sale primero el aviso de espera.** Cuando falla la decisión, `SCA2 CMD Decidir` reintenta lanzándose en asíncrono (nodo «Start Decidir (reintento)»). Eso rompe la espera síncrona del alta, la pantalla pasa al sondeo de 30 s («se está generando… COMPROBAR AHORA») y, en la siguiente lectura, encuentra el estado `ERROR_DECISION`.

## 3. Cambios (TEST, solo SCA2)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| SCA2_AltaSolicitudPage | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055716 | 54→55 | Nueva `local!errorDecision` (estado de la solicitud nueva = `ERROR_DECISION`). Con ella, la tarjeta muestra `SCA2_TXT_ERROR_SERVICIO_DECISION` + « Solicitud: N.» en vez de «generada correctamente»; el ACEPTAR que abría el Detalle se oculta y aparece un ACEPTAR que vuelve al buscador (como el OK de `SCA_GenerarSolicitudPopupEstrategicas`). El resto de casos no cambia. |
| SCA2_TXT_ERROR_SERVICIO_DECISION (nueva) | _a-0000f0b4-5b71-8000-9d56-011c48011c48_5744796 | —→1 | «Se ha producido el siguiente error en el servicio de decisión: », el mismo texto que `SCA_TEXTOS_GENERAR_SOLICITUD_POPUP_ESTRATEGICAS[8]`. |

Antes de guardar se comprobó que la versión viva era la 54 de la copia. Después se reexportó: la versión viva coincide con lo enviado. Ficheros: `backups-r49/SCA2_AltaSolicitudPage_v54_antes.sail`, `_v55_despues.sail` y `_v54_v55.diff`. La coordinación está liberada.

No se duplica ni se pierde la solicitud: solo cambia el texto y el destino del botón. La solicitud sigue creada (como en SCA) y GUARDAR sigue bloqueado tras el primer clic.

## 4. Pruebas (TEST, SISANS, solicitudes nuevas del 16/11/2026)

Pasos comunes: ALTA SOLICITUD ANULACIÓN → póliza → DECISION DE CLIENTE / PRODUCTO / EL PRODUCTO NO SATISFACE AL CLIENTE → TELEFONICO → A VENCIMIENTO → GUARDAR → ACEPTAR del popup.

| # | Aplicación / versión | Póliza | Solicitud | Esperado | Real | OK/KO |
|---|---|---|---|---|---|---|
| 1 | SCA2 v54 (antes) | 2002600074272 | 15789139 | Reproducir INC-06 | Popup (con Advertencia de flota/wAutemis) → «se está generando… COMPROBAR AHORA» → «generada correctamente» → ACEPTAR → Detalle solo con «Alta Solicitud – Finalizada». `ERROR_DECISION`, errores 221–223, 0 tareas | Reproducido |
| 2 | SCA (referencia) | 2002600074293 | 15789142 (CORE) | Ver qué hace SCA | Tras GUARDAR: «Se ha producido el siguiente error en el servicio de decisión:» + OK → buscador; solicitud «Solicitud Pendiente». La cabecera del cliente sale vacía | Referencia |
| 3 | SCA2 v55 (después) | 2002600074304 | 15789144 | Aviso de error como SCA y salida | Popup → espera → «Se ha producido el siguiente error en el servicio de decisión:  Solicitud: 15789144.» + ACEPTAR → buscador. Una sola solicitud, `ERROR_DECISION`, 0 tareas | OK |
| 4 | Salida de los 90 s | — | — | Mensaje de espera agotada | No se ha podido provocar: hace falta que la solicitud se quede en ALTA/DECIDIDA/EN_ACCION sin tarea más de 90 s, y en TEST no hay forma de forzarlo sin tocar procesos o servicios. Con `ERROR_DECISION` no aplica: la pantalla sale por el error en el primer sondeo | Sin probar |

Capturas: `r49a-1-antes-popup.png`, `r49a-1-antes-espera.png`, `r49a-1-antes-generada-correctamente.png`, `r49a-1-antes-detalle-sin-gestion.png`, `r49a-2-sca-error-servicio-decision.png`, `r49a-2-sca-ok-vuelve-buscador.png`, `r49a-3-despues-error-servicio-decision.png`, `r49a-3-despues-aceptar-buscador.png`.

Pendientes de limpiar (de estas pruebas, no tocadas): 15789139, 15789144 (SCA2, `ERROR_DECISION`) y 15789142 (SCA).

## 5. Dudas para el analista

1. **Texto.** Se usa el de SCA («Se ha producido el siguiente error en el servicio de decisión: »). El servicio no devuelve el motivo, así que tras los dos puntos no aparece nada, igual que en SCA. SCA2 añade « Solicitud: N.». ¿Lo dejamos así o preferís un texto más claro, por ejemplo «No se ha podido determinar la siguiente gestión. Reporte este error a mantenimiento SCA»? Cambiarlo solo requiere editar la constante.
2. **Qué hacer con estas solicitudes.** En SCA y en SCA2 quedan como «Solicitud Pendiente» sin gestión. En SCA2 la póliza queda con una solicitud en curso (`SCA2_consultarSolicitudEnCurso` la devuelve) y no se puede dar otra de alta hasta que mantenimiento relance la decisión desde la bandeja de errores. ¿Es lo esperado o queréis otro tratamiento (relanzar, cancelar…)?
3. **Detalle de una solicitud en `ERROR_DECISION`.** Si se abre después desde el buscador, sigue mostrando solo «Alta Solicitud – Finalizada», sin ningún aviso. No lo hemos cambiado porque no consta qué muestra SCA en ese caso. ¿Añadimos un aviso?
4. **Estado `ERROR`** (fallo al crear la acción): la pantalla del alta lo sigue tratando como antes, con «generada correctamente» y Detalle. No se ha podido reproducir ni comparar con SCA. ¿Lo tratamos igual que `ERROR_DECISION`?
5. **Datos de TEST.** Las pólizas 2002600074290/272/293/304 fallan porque su cliente no está en la API de Clientes de TEST. Es un problema de datos del entorno, no de SCA2. Para probar el resto de la gestión con 2002600074290 hace falta corregir esos datos.
