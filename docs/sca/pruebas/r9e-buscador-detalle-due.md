# R9-E — Buscador, Detalle y DUE (E1, E2, F1, F2, F3)

Sesión hija R9-E de la ronda 9 (respuestas del analista en `../24-respuestas-analista-ronda9.md`; plan en `../25-plan-ronda9.md`). Entorno Appian TEST; SCA (aplicación original) es la referencia funcional y SCA2 la que se corrige. Sólo se han modificado objetos de SCA2 (reservados y liberados en `coordinacion-ronda9.md`). No se ha tocado SCA, SCAC, CORE, GAIA, PRE ni Documentum, ni se ha borrado ninguna solicitud de CORE.

## 1. Resumen

| Ref (doc 25) | Qué dijo el analista | Qué hacía SCA2 | Qué hace ahora | Cómo se probó (SCA / SCA2) | Veredicto |
|---|---|---|---|---|---|
| F1 Detalle sólo lectura de solicitudes de SCA / históricas | «Lo que hace SCA. Solo lectura y no se puede actuar sobre esas solicitudes desde ahí» | El Buscador ya listaba las filas sólo-CORE en un segundo grid y `SCA2_DetalleSolicitud` ya tenía la rama «sin registro SCA2» (cabecera y gestiones de CORE, aviso «sólo consulta»). Pero la pestaña «Otras solicitudes de anulación» del Detalle sólo listaba solicitudes con registro SCA2 (para una solicitud creada en SCA salía vacía) | El enlace del número en el grid «Otras solicitudes de la póliza / cliente» abre el Detalle de sólo consulta; la pestaña «Otras solicitudes de anulación» del Detalle (`SCA2_TablaOtrasSolAnulacion`) lista ahora también las solicitudes de la póliza que sólo existen en CORE (creadas en SCA / históricas) y permite navegar entre ellas. Sin RETOMAR / REASIGNAR / POSPONER ni botones de acción (las tarjetas de CORE no llevan tarea SCA2) | Solicitud 15787864 (póliza 0000253500329, creada en SCA por SI24, pendiente): Detalle en SCA y en SCA2; prueba LCP de la tabla con las pólizas 0000253500329, 0001047017037 y 0005726698173 | **OK** (ver §2.1 y resultados UI en §4) |
| F3 Fecha de resolución | «Cuando esté pendiente que no lo muestre; después sí» | La tabla principal del Buscador (`SCA2_BuscadorTabla`) ya iba vacía en pendientes (usa `consultarUltimaGestion`, que devuelve la fecha a null). Pero el grid «Otras solicitudes…» del Buscador y la tabla «Otras solicitudes de anulación» del Detalle mostraban fecha en pendientes: CORE `consultarSolicitudes` rellena `fecResolucion` con la fecha de solicitud aunque esté pendiente, y la tabla del Detalle usaba la fecha de última modificación del registro SCA2 | En las dos tablas la «Fecha resolución» va «-» salvo que el estado CORE sea final (3, 4, 5, 6, 11, 12, 14, 15, 18, 19); el respaldo con el registro SCA2 sólo muestra fecha si el estado SCA2 es final | 15787864 (pendiente) → «-»; 15787869 (póliza 0001047017037, finalizada positivamente) → 09/10/2026 14:48:17; 15787911 (nueva, en acción, estado CORE 10) → «-». Comparado con SCA: la tabla principal de SCA también va «-» en pendientes; su tabla «Otras solicitudes de anulación» sí muestra la fecha en pendientes (divergencia **deliberada** por decisión del analista) | **OK** |
| E1 Correo DUE: teléfono / correo de contacto | «Los correos llegan correctamente. Falta informar un teléfono o email lo cual es obligatorio» | El cuerpo del DUE de SCA2 (`SCA2_notificarNivel`) llevaba Tomador, DNI, Email y Teléfono tomados de los registros SCA2 de la póliza, que **no persisten** nombre, email ni teléfono del tomador: las cuatro filas salían vacías. En SCA el DUE lleva `ae-key-telefono1/2` = teléfono de contacto de la solicitud (`tlfexperto`) y `ae-key-email` / nombre / DNI del tomador de la póliza | El cuerpo lleva «Tomador», «DNI», «Email contacto» y «Teléfono contacto». Orden de fuentes: teléfono de contacto de la solicitud (`SCA2 Datos Solicitud.tlfexperto`, como SCA) → teléfono del tomador del registro → teléfono móvil / fijo de los datos de contacto en vivo de la póliza (`SCA2_obtenerDatosCabecera`, el mismo servicio que pinta la pestaña «Datos de contacto» del Alta y del Detalle); email: tomador del registro → correo de contacto en vivo; nombre y DNI: registro → datos de cliente en vivo | Prueba de la regla por LCP con dos solicitudes de SI24 (15787875 y 15787877) simulando la decisión `CONTRA ANULAR NIVEL 2 / CE_MF_SI24`: antes Tomador, Email y Teléfono vacíos; después los cuatro datos informados. Prueba real de extremo a extremo bloqueada en TEST (ver §2.3) | **Corregido; envío real no probado** |
| F2 «¿Qué segunda tabla?» | — | — | Explicación en §2.4 (lenguaje de negocio) | Capturas de los filtros de SCA y SCA2 | **Explicado** |
| E2 Contexto SI24 (preguntas de contacto, impresión, Ilocalizable, 3.ª gestión) | «Necesitamos más contexto» | — | Explicación en §2.5 | Lectura de los flujos de SCA y SCA2 y del consolidado de ronda 8 | **Explicado**; sin cambios en SCA2 (dudas abiertas) |

## 2. Detalle por punto

### 2.1 F1 — Detalle de sólo lectura para solicitudes de SCA / históricas

**Qué hace SCA.** En el buscador de SCA cada número de solicitud es un enlace que abre el Detalle (`SCA_DetalleSolicitud` vía `SCA_PM_REDIRIGIRDETALLE`) con los datos que devuelve CORE (cabecera, gestiones, documentos y la tabla «Otras solicitudes de anulación» de la misma póliza). Las acciones (retomar, reasignar, posponer) sólo aparecen cuando la gestión sigue abierta y el usuario puede gestionarla.

**Qué hacía SCA2.** `SCA2_DetalleSolicitud` ya contenía la rama «sin registro SCA2» (`local!soloCore`): cabecera desde `SCA2_consultarCabeceraSolicitud`, tarjetas desde `SCA2_consultaGestion` (contra anulación, acciones administrativas, impresión, mecanización, autorización), aviso azul «Solicitud gestionada en SCA o histórica: datos de CORE, sólo consulta» y trazabilidad técnica oculta. El grid «Otras solicitudes de la póliza / cliente (SCA e históricas en CORE, sin gestión en SCA2)» del Buscador ya enlazaba al Detalle. Lo que faltaba era la pestaña «Otras solicitudes de anulación» del Detalle, que consultaba sólo el record `SCA2 Solicitud` por póliza y, para una solicitud creada en SCA, salía vacía.

**Cambio en SCA2.** `SCA2_TablaOtrasSolAnulacion` (uuid `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065000`) v2 → v6: la tabla une las solicitudes SCA2 de la póliza con las filas de CORE (`SCA2_consultarSolicitudes(numPoliza, codInt:"", tpBusqueda:"0")`, el mismo servicio que usa SCA) que no tienen registro SCA2. Estado CORE → estado SCA2 con la misma tabla que el Buscador (`SCA_D_EstadosSolicitud`), causa y línea de negocio de CORE, enlace del número que selecciona la solicitud (abre su Detalle, de sólo consulta si no tiene registro SCA2). Los botones RETOMAR / REASIGNAR del Detalle sólo se pintan si la tarjeta tiene una tarea SCA2 abierta (`local!tareaBtn`), por lo que en una solicitud sólo-CORE no aparecen; no se ha necesitado tocar `SCA2_DetalleSolicitud`.

**Pruebas.** LCP (`POST /interfaces/{uuid}/test`): póliza 0000253500329 → fila 15787864 «Pendiente», fecha resolución «-»; póliza 0001047017037 → fila 15787869 «Finalizada positivamente», 09/10/2026 14:48:17; póliza 0005726698173 (antes del alta) → sin filas. UI: ver §4.

### 2.2 F3 — Fecha de resolución

**Dato de CORE.** `consultarUltimaGestion(nuuma)` (lo que usa la tabla principal de SCA y de SCA2) devuelve `fechaResolucion` a null mientras la solicitud está pendiente (comprobado sobre las 25 solicitudes de SISANS y las 541 de JJGONZ2 en TEST: ninguna pendiente con fecha, ninguna resuelta sin fecha). En cambio `consultarSolicitudes(numPoliza)` (lo que usan las tablas «Otras solicitudes…» de SCA y de SCA2) devuelve `fecResolucion` = fecha de solicitud también en pendientes (15787864: 09/10/2026 13:37:42 con estado 2). Por eso el analista veía una fecha en pendientes.

**Cambios en SCA2.**
- `SCA2_Buscador` (uuid `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660`) v27 → v29: en el grid «Otras solicitudes de la póliza / cliente» la columna «Fecha resolución» va «-» salvo que `codEstSolic` sea un estado final (3, 4, 5, 6, 11, 12, 14, 15, 18, 19).
- `SCA2_TablaOtrasSolAnulacion` v2 → v6 (mismo cambio, descrito en 2.1); para las filas con registro SCA2 manda la fila de CORE y, si no existe, la fecha de modificación del registro sólo se muestra con estado SCA2 final.
- `SCA2_BuscadorTabla` (tabla principal) no necesitaba cambio: ya iba «-» en pendientes (fila de CORE) y el respaldo SCA2 ya exigía estado final.
- Detalle: la pestaña «Solicitud anulación» (`SCA2_SolicitudAnulacion`) no muestra fecha de resolución (muestra «Fecha estado» y «Fecha anulación», como SCA); sin cambio.

**Divergencia deliberada con SCA.** La tabla «Otras solicitudes de anulación» de SCA (`SCA_TablaOtrasSolAnulación` v7) muestra la fecha de CORE tal cual (fecha en pendientes). SCA2 la deja vacía por decisión del analista (F3). No se ha tocado SCA.

### 2.3 E1 — Correo DUE

**Dónde se genera el DUE.**
- SCA: proceso `SCA Notificar Cambio Nivel` (subproceso «Notificar/DUE» de `SCA Alta Solicitud Anulacion` y `SCA Consulta Reglas`). Nodo «DUE» (Send E-Mail) con plantilla `SCA mailDUETemplate` y datos: agente, póliza, motivo, hora, observaciones, **teléfono1 / teléfono2 = `datosSolicitud.tlfexperto`** (teléfono de contacto de la solicitud), origen, negocio (HOGAR / AUTOS), nombre y DNI del tomador, **email del tomador**. Destinatario por constante según producto / perfil (expertos o Altitude). Tras enviar marca `dueEnviado = S` e inserta la notificación externa «Envio DUE - Correo enviado SI24». Condición: nivel ≠ 1, acción `CONTRA ANULAR NIVEL 2`, grupo CE_MF_SI24 / CE_MF_BK y DUE no enviado.
- SCA2: proceso `SCA2 CMD Decidir` (uuid `0000f06f-0eab-8000-6595-7f0000014e7a`), nodo «Notificar nivel (SGC CE_RM / DUE SI24)» → regla `SCA2_notificarNivel` (uuid `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505875`; no está asociada a la aplicación SCA2 en el listado de LCP, se localizó recorriendo todas las reglas del entorno) devuelve destinatario, asunto, cuerpo HTML y la notificación externa; el nodo «DUE SI24» envía el correo, se escribe `dueEnviado` en `SCA2 Solicitud` y se registra la notificación externa en CORE. Misma condición que SCA.
- `SCA2_mensajeCorreoElectronico` / `SCA_mensajeCorreoElectronico` **no** son el DUE: son el correo de error de proceso (idénticos entre sí). No se han tocado.

**Qué hacía SCA2 (divergencia).** El cuerpo HTML construía Tomador / DNI / Email / Teléfono a partir de los registros SCA2 de datos de póliza, que no guardan nombre, email ni teléfonos del tomador, y nunca usaba el teléfono de contacto de la solicitud. Resultado: las cuatro filas vacías (comprobado por LCP con 15787875 y 15787877). Además `SCA2_AltaSolicitudPage` nunca rellena `telefonoExpertos` (`local!telefonoExpertos: null`), así que `tlfexperto` queda vacío en todas las solicitudes de SCA2 (en SCA es un parámetro del proceso de alta).

**Cambio en SCA2.** `SCA2_notificarNivel` v3 → v5 (backups y SAIL antes/después guardados en local, no en el repo):
- `local!tlfContacto`: teléfono de contacto de la solicitud leído del record `SCA2 Datos Solicitud.tlfexperto` por `idSolicitud` (como SCA).
- `local!cabContacto`: sólo cuando hay que enviar el DUE, `SCA2_obtenerDatosCabecera(numPoliza, idSolicitud)` (datos de contacto y de cliente en vivo de la póliza, los mismos que ve el gestor en la cabecera del Alta / Detalle).
- Filas del cuerpo: «Tomador» (registro → nombre y apellidos del cliente), «DNI» (registro → NIF del cliente), «Email contacto» (tomador del registro → correo de contacto), «Teléfono contacto» (`tlfexperto` → teléfono del tomador del registro → móvil → fijo). Asunto y destinatario sin cambios.

**Pruebas.** LCP `POST /expression-rules/{uuid}/test` con `sol = SCA2_cargarSolicitud(id)` y decisión `{grupo: CE_MF_SI24, accion: CONTRA ANULAR NIVEL 2}`, `soloPayload: true`:

| Solicitud | Antes (v3) | Después (v5) |
|---|---|---|
| 15787875 (AUTOS, SI24) | Tomador «», DNI informado, Email «», Teléfono «» | Tomador informado (26 car.), DNI informado, Email contacto informado (32 car.), Teléfono contacto informado (9 dígitos) |
| 15787877 (AUTOS, SI24) | Tomador «», Email «», Teléfono «» | Tomador, DNI, Email contacto y Teléfono contacto informados |

(Valores no reproducidos aquí por ser datos personales de TEST.) Contenido generado (anonimizado): `Negocio AUTOS · Póliza 00027293xxxxx · Tomador NOMBRE APELLIDOS · DNI 1145xxxxQ · Email contacto xxxx@xxxx · Teléfono contacto 6xxxxxxxx · Agente (vacío en TEST) · Motivo ME HA SUBIDO MUCHO LA PRIMA · Solicitud 15787875 · Fecha dd/MM/yyyy HH:mm`.

**Prueba real de extremo a extremo (no completada).** Alta propia en SCA2 con la póliza RCI 0005726698173 (JJGONZ2) → solicitud **15787911** (CORE: gestión 8 finalizada y contra anulación nivel 1 incompleta; `SCA2 Solicitud`: EN_ACCION / CONTRAANULAR / nivel 1 / `dueEnviado` null; sin notificaciones externas). Al retomar la contra anulación de nivel 1 para resolverla NEGATIVO (para que el motor la pasara a nivel 2, grupo CE_MF_BK, y se disparase el DUE), la pantalla muestra el aviso «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.» y POSITIVO / NEGATIVO / FINALIZAR deshabilitados: es el bloqueo B7-acuerdos implementado hoy por la sesión R9-C (`SCA2_ContraAnulacionOpciones` v42, pólizas de acuerdo con usuario Red Mapfre en nivel 1), conforme a la respuesta del analista. Por tanto en TEST ya no se puede provocar el salto a nivel 2 (y el DUE) desde un usuario de oficina con una póliza RCI, que era el camino de la ronda 8. La solicitud 15787911 queda pendiente sin modificar; incidencia anotada en `coordinacion-ronda9.md`. Observación: con el argumento obligatorio seleccionado los botones no muestran tooltip explicativo (el aviso está encima del marco); se ha comunicado a R9-C.

**Limitación.** Que `dueEnviado` = true y la notificación externa existan demuestra que el correo se **generó y marcó como enviado**, no que se **recibió**; la recepción sólo puede confirmarla el buzón destinatario.

### 2.4 F2 — «¿Qué segunda tabla?»

En lenguaje de negocio: el buscador de SCA2 muestra **dos listas**. La primera es la tabla de resultados normal (solicitudes gestionadas en SCA2). La segunda, que aparece debajo cuando se busca por póliza o cliente, se titula **«Otras solicitudes de la póliza / cliente (SCA e históricas en CORE, sin gestión en SCA2)»** y lista las solicitudes de esa misma póliza o cliente que existen en CORE pero no se crearon en SCA2: las que se dieron de alta en SCA (la aplicación actual) y las históricas. En SCA no existen dos listas porque SCA lee todo de CORE; en SCA2 hace falta la segunda para que el gestor vea el histórico completo mientras conviven las dos aplicaciones. Además, dentro del Detalle de una solicitud, la pestaña **«Otras solicitudes de anulación»** (igual que en SCA) lista todas las solicitudes de la misma póliza; desde esta ronda incluye también las de SCA / históricas.

**Filtros.** En SCA2 los desplegables «Estado» (Pendiente, Finalizada positivamente, Finalizado negativo con contraanulación, Finalizada no requerida contraanulación, Caducada, Cancelada, Pendiente de Autorizar, Finalizado autorizado, Finalizada no autorizado) y «Línea de negocio» están en el buscador, encima de los resultados, y filtran **sólo la primera lista** (la de SCA2); la segunda lista no se filtra. En SCA los dos desplegables equivalentes están dentro de la tabla de resultados (`SCA_BuscadorTabla`) y filtran la única lista que hay. La duda que sigue abierta para el analista: **¿deben aplicarse los filtros de Estado y Línea de negocio también a la segunda lista (solicitudes de SCA / históricas)?** No se ha cambiado nada a la espera de respuesta.

### 2.5 E2 — Contexto sobre SI24: preguntas de contacto, impresión, «Ilocalizable» y tercera gestión

Qué hace cada aplicación hoy en TEST (sin cambios en SCA2 en esta ronda; son dudas abiertas D-SI24 del documento 22 y P2/P3 del consolidado de ronda 8):

1. **Preguntas de contacto al posponer / finalizar.** En SCA, al posponer o finalizar una contra anulación, al gestor se le hacen las preguntas de contacto configuradas para su perfil (¿se ha contactado con el cliente?, medio, etc.), que se guardan como «contacto» de la solicitud (campo `contacto` / `codmediocomunicacion` de CORE). En TEST el perfil SI24 **no tiene preguntas de contacto configuradas**, así que ni SCA ni SCA2 se las muestran a SISANS; SCA2 reproduce el mismo flujo que SCA (lee la misma configuración de CORE). Para probarlo haría falta configurar las preguntas de SI24 en TEST o hacerlo en un entorno con la configuración de PRO.
2. **Impresión para SI24.** En SCA la tarjeta / acción de Impresión está **activa** para SI24 en TEST; SCA2 hace lo mismo. El plan de pruebas del analista la esperaba **inactiva** para SI24. Pregunta de negocio: ¿debe un experto de SI24 poder imprimir la carta al cliente o sólo la oficina? Si debe estar inactiva, se corrige SCA2 (y quedaría una diferencia con SCA actual).
3. **Cierre «Ilocalizable» a la tercera gestión.** El plan de contra anulación describe que, cuando el gestor indica tres veces que no ha podido contactar con el cliente, a la tercera se avisa y la solicitud se cierra como «Ilocalizable sin contacto» (o «con contacto»). En TEST ni SCA ni SCA2 llegan a ese cierre con SISANS porque depende de las preguntas de contacto (punto 1) y de la marca de ilocalizables del productor (`mcaIlocalizables`), que en los datos de TEST no se dan. SCA2 lleva portada la lógica de SCA (contador de intentos y marca), pero no se ha podido observar el cierre. Pregunta de negocio: ¿a qué se refiere «tercera gestión»: tres intentos de contacto en la misma contra anulación o tres gestiones de contra anulación distintas sobre la solicitud? ¿Debe aplicarse también cuando el gestor es SI24?

## 3. Solicitudes creadas y estados CORE observados

| Solicitud | Póliza | Dónde | Usuario | Estado SCA2 | CORE |
|---|---|---|---|---|---|
| 15787911 | 0005726698173 (RCI, R9-E) | SCA2 | JJGONZ2 | EN_ACCION / CONTRAANULAR / nivel 1 / `dueEnviado` null | cabecera estado 10, nivel 1, contacto 1, causa 1; gestiones: 8 (alta) FINALIZADA y 2 (contra anulación) INCOMPLETA; `consultarSolicitudes`: codEstSolic 2, `fecResolucion` null |
| 15787917 | 0005726697972 (RCI, R9-E) | SCA | JJGONZ2 | sin registro SCA2 (sólo-CORE) | cabecera estado 2, nivel 1, contacto 1, causa 1; gestión 8 (alta) FINALIZADA; `consultarSolicitudes`: codEstSolic 2 |

Solicitudes de sólo lectura usadas (no modificadas): 15787864 (SCA, SI24, pendiente, póliza 0000253500329), 15787869 (SCA2, finalizada positivamente, póliza 0001047017037), 15787875 y 15787877 (SCA2, SI24, finalizadas nivel 2; usadas sólo para la prueba de la regla del DUE por LCP).

## 4. Pruebas UI (SCA frente a SCA2)

Pruebas realizadas por el agente de pruebas con el usuario JJGONZ2 (oficina, CE_RM) en SCA (`/suite/sites/sca-site`) y SCA2 (`/suite/sites/sca2`), con grabación anotada y capturas (rutas en §8).

| Prueba | SCA | SCA2 | Veredicto |
|---|---|---|---|
| A. Buscar póliza 0000253500329 (15787864, creada en SCA por SI24, pendiente) | Abre directamente el Detalle (único resultado). Cabecera, gestión «Alta» finalizada por SISANS (SI24 EXPERTOS), 5 pestañas | La tabla principal no la lista; aparece en el grid «Otras solicitudes de la póliza / cliente» con estado Pendiente y fecha resolución «-». El número abre el Detalle con el aviso «Solicitud gestionada en SCA o histórica: datos de CORE, sólo consulta»; mismos datos de solicitud y gestión que SCA; 6 pestañas (añade Notificaciones) | **OK** |
| A. Acciones en el Detalle de 15787864 | Sin acciones (gestión de alta finalizada) | Recorridas las 6 pestañas (cliente, póliza, solicitud anulación, otras solicitudes, contacto, notificaciones): sin RETOMAR, REASIGNAR, POSPONER ni ningún botón de acción | **OK** |
| A. Pestaña «Otras solicitudes de anulación» de 15787864 | Fila 15787864 con fecha resolución 09/10/2026 13:37:42 (pendiente) | Fila 15787864 con fecha resolución «-»; columna Observaciones añadida («-») | **OK** (divergencia deliberada F3) |
| B. Fecha resolución pendiente (15787864) | Tabla «Otras»: fecha aunque está pendiente | «-» en el grid del Buscador y en «Otras» del Detalle | **OK** |
| B. Fecha resolución finalizada (15787869, póliza 0001047017037) | «Otras»: 09/10/2026 14:48:17 | Buscador y «Otras»: 09/10/2026 14:48:17 | **OK** |
| B. Fecha de solicitud de 15787869 en «Otras» | 09/10/2026 14:45:09 (CORE) | Mostraba 14:45:17 (fecha de creación del registro SCA2, 8 s después) → corregido en `SCA2_TablaOtrasSolAnulacion` v6: manda la fecha de CORE (prueba LCP: 14:45:09) | **Corregido** |
| C. Pólizas sin solicitud: RCI 0005726697972 y Más Móvil 0732500056305 | «No hay resultados para dicha búsqueda» | «No hay resultados para dicha búsqueda» | **OK** |
| C. Filtros Estado / Línea de negocio | Desplegables en la tabla de resultados: 9 estados, líneas Automóviles / Hogar | Desplegables encima de los resultados: mismos 9 estados y mismas líneas; sólo filtran la tabla SCA2 (ver §2.4) | **OK** (pregunta F2 abierta) |
| C. Columnas de la tabla principal | 8: solicitud, estado, fecha solicitud, póliza, línea, causa, resolución, observaciones | Las mismas 8 | **OK** |
| D. Alta SCA2 RCI 0005726698173 (JJGONZ2) | — | Solicitud 15787911 creada; visible en SCA y SCA2 como pendiente, nivel 1, fecha resolución «-» | **OK** |
| D. Contra anulación nivel 1 de 15787911 (para provocar nivel 2 → DUE) | — | Aviso «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.»; POSITIVO / NEGATIVO / FINALIZAR deshabilitados (bloqueo B7-acuerdos de R9-C). Sin tooltip al pasar sobre POSITIVO/NEGATIVO con el argumento obligatorio seleccionado | **No probado** (DUE real) |
| E. Alta SCA RCI 0005726697972 (JJGONZ2) | Solicitud 15787917 creada en CORE (gestión 8 finalizada), pero la pantalla del alta estuvo «procesando» más de 5 min y acabó en «403 Acceso denegado» (latencia / 403 propio de SCA). No se pudo abrir la contra anulación | Aparece en SCA2 como sólo-CORE (aviso sólo consulta) con fecha resolución «-» en Buscador y «Otras» | **SCA no comparable por latencia** (contra anulación / nivel 2) |
| E. «Otras» con 15787917 pendiente | Fecha resolución 13/10/2026 19:06:45 | «-» | **OK** (divergencia deliberada F3, reproducida con datos nuevos) |
| Observaciones de filas sólo-CORE | Tabla principal de SCA muestra «R9-E prueba DUE» (última observación de CORE) | Grid «Otras solicitudes de la póliza / cliente» del Buscador y «Otras» del Detalle muestran «-» (CORE `consultarSolicitudes` no devuelve observaciones; la tabla principal de SCA2 sí las muestra) | **Divergencia menor, documentada** (ver §6) |
| Error de SCA al «Volver» desde el Detalle de 15787864 | Error Appian en `SCA_BuscadorSolicitudPrincipal` (`a!submitLink`, destino de guardado no válido) | No aplica | Fallo de SCA, no se corrige |

Recuento UI: 11 OK, 1 corregido durante la ronda (fecha de solicitud), 1 divergencia menor documentada (observaciones), 2 no probados / no comparables (DUE real y contra anulación en SCA).

## 5. Divergencias corregidas (objetos SCA2)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_notificarNivel` (regla) | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505875` | 3 → 5 | Teléfono de contacto (`tlfexperto`) y datos de contacto / cliente en vivo (`SCA2_obtenerDatosCabecera`) en el cuerpo del DUE: filas Tomador, DNI, Email contacto, Teléfono contacto |
| `SCA2_TablaOtrasSolAnulacion` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065000` | 2 → 6 | Filas de CORE (SCA / históricas) además de las de SCA2; fecha resolución vacía salvo estado CORE final; fecha de solicitud de CORE cuando existe (v6) |
| `SCA2_Buscador` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | 27 → 29 | Grid «Otras solicitudes de la póliza / cliente»: fecha resolución vacía salvo estado CORE final |

Reservados y no modificados: `SCA2_DetalleSolicitud` (v51), `SCA2_BuscadorTabla` (v11), `SCA2 CMD Decidir`. Las versiones intermedias (v4 de la regla, v3/v4/v5 de la tabla, v28 del buscador) son pasos de la misma corrección (primero sólo estados pendientes 1/2/16/17, después «vacía salvo estado final» al ver que la nueva 15787911 tiene estado CORE 10).

## 6. Pendientes y preguntas para el analista (lenguaje de negocio)

1. **F2 filtros:** ¿los filtros de Estado y Línea de negocio del buscador de SCA2 deben aplicarse también a la segunda lista (solicitudes de SCA / históricas)?
2. **E1 teléfono de contacto en el alta:** en SCA2 el alta no recoge el «teléfono de contacto» de la solicitud (`tlfexperto`), por lo que el DUE lo rellena con el teléfono del tomador de la póliza. ¿Debe el alta de SCA2 pedir / guardar ese teléfono como SCA (y en qué pantalla lo informa hoy el gestor de SCA)?
3. **E1 confirmación de recepción:** sólo se puede comprobar que el DUE se generó y marcó como enviado; para confirmar recepción hace falta acceso al buzón de TEST (en TEST el destinatario es el buzón de expertos / Altitude configurado en constantes).
4. **E1 prueba real:** con el nuevo bloqueo de pólizas de acuerdo para Red Mapfre (B7), ¿cómo debe llegar una solicitud de RCI a nivel 2 / SI24 para que se envíe el DUE: la crea directamente SI24, o la oficina la crea y SI24 la retoma? Hace falta esta respuesta para probar el envío real en TEST.
5. **E2:** las tres preguntas del §2.5 (preguntas de contacto de SI24 en TEST, impresión activa para SI24, significado de «tercera gestión»).
6. **Observaciones en las filas sólo-CORE:** el grid «Otras solicitudes de la póliza / cliente» del Buscador y la tabla «Otras» del Detalle de SCA2 muestran «-» en Observaciones porque el servicio `consultarSolicitudes` de CORE no las devuelve (la tabla principal de SCA y de SCA2 sí las muestra, desde `consultarUltimaGestion`). ¿Hace falta ver la última observación también en esas listas? Si sí, habría que consultar las gestiones de cada solicitud (una llamada por fila).
7. **Error de SCA (no SCA2):** en SCA TEST, al pulsar la flecha «Volver» de la cabecera del Detalle de 15787864 aparece un error de Appian en `SCA_BuscadorSolicitudPrincipal` (`a!submitLink`, destino de guardado no válido). No se corrige (objeto de SCA); se documenta.

## 7. Limitaciones

- SCA en TEST con latencia alta; algunas comparaciones se han hecho por navegación directa por URL.
- El contenido del documento `SCA mailDUETemplate` (plantilla del DUE de SCA) no se puede descargar por LCP (501); la comparación se ha hecho con los datos que el proceso pasa a la plantilla.
- Prueba real del DUE bloqueada en TEST por el bloqueo B7-acuerdos (ver §2.3).
- No se han añadido vídeos ni capturas al repositorio; se adjuntan al mensaje final de la sesión.

## 8. Grabaciones y capturas

Grabación: `r9e-sca-comparativa-edited.mp4` (adjunta al mensaje final de la sesión, no en el repo).

Capturas (adjuntas al mensaje final; prefijo SCA_ / SCA2_ y letra de la prueba): `SCA2_A_B_buscador_pendiente`, `SCA2_A_datos_cliente`, `SCA2_A_datos_poliza`, `SCA2_A_solicitud_anulacion`, `SCA2_A_gestiones`, `SCA2_A_B_otras_pendiente`, `SCA2_A_contacto`, `SCA2_A_notificaciones`, `SCA2_B_buscador_finalizada`, `SCA2_B_otras_finalizada`, `SCA_A_solicitud_gestiones`, `SCA_A_B_otras_pendiente`, `SCA_A_datos_cliente`, `SCA_A_error_volver`, `SCA_B_otras_finalizada`, `SCA2_C_RCI_sin_resultados`, `SCA2_C_MasMovil_sin_resultados`, `SCA2_C_filtro_estado`, `SCA2_C_filtro_linea`, `SCA_C_RCI_sin_resultados`, `SCA_C_MasMovil_sin_resultados`, `SCA_C_filtro_estado`, `SCA_C_filtro_linea`, `SCA2_D_alta_formulario`, `SCA2_D_creada_15787911`, `SCA2_D_negativo_bloqueado`, `SCA2_D_aviso_SI24`, `SCA2_D_hover_positivo`, `SCA2_D_hover_negativo`, `SCA2_D_15787911_buscador`, `SCA2_D_15787911_otras`, `SCA_D_15787911_buscador`, `SCA_D_15787911_detalle`, `SCA_E_alta_formulario`, `SCA_E_alta_espera_90s`, `SCA_E_creada_15787917`, `SCA_E_detalle_15787917`, `SCA_E_error_403`, `SCA_E_otras_15787917`, `SCA2_E_15787917_buscador_CORE`, `SCA2_E_otras_15787917`.
