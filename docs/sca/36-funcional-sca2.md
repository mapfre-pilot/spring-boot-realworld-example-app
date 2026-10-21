# SCA2 — Documento funcional (cómo funciona la aplicación)

Destinatarios: analistas funcionales de SCA. Fecha: octubre 2026. Entorno de referencia: Appian TEST (`/suite/sites/sca2`).

SCA2 es la nueva versión del **Sistema Comercial de Anulaciones**. Hace **lo mismo que SCA** (gestionar las solicitudes de anulación de pólizas de Autos, Hogar y Vida desde que se detecta la intención de anular hasta que la póliza se anula, se retiene al cliente o la solicitud caduca), pero con una arquitectura distinta: la pantalla manda, cada acción es un "comando" corto que graba el resultado en base de datos y no hay procesos esperando días. Este documento describe **qué hace la aplicación tal y como está construida hoy**, incorporando todas las decisiones del analista de las rondas 1–13. Las diferencias con SCA están marcadas con ⚠️ y las decisiones pendientes con ❓.

Diagrama del ciclo de vida: `img/36-ciclo-vida-sca2.svg` (también en PNG).

---

## 1. Quién usa SCA2 y con qué permisos

| Perfil (grupo del usuario en CORE) | Qué puede hacer |
|---|---|
| **Oficina / Red Mapfre** (CE_RM, CE_RM_OFICINA) | Dar de alta solicitudes, gestionar las tareas de **nivel 1** de su oficina (contra anulación, acciones administrativas, mecanización, autorización), consultar el detalle. No puede gestionar tareas que están en SI24 (sólo consultarlas; ve el aviso «la está gestionando SI24»). |
| **SI24 Experto / Front** (CE_MF_SI24, CE_MF_BK) | Gestiona las tareas de **nivel 2** (cualquier CA de nivel 2, aunque la oficina no sea la suya). En nivel 1 sólo consulta. En el alta no ve los motivos/detalles/causas que no puede usar (cascada motivo → detalle → causa). |
| **CCC / CCR** (contact center) | Como Oficina; al enviar la solicitud al motor se informa «el cliente insiste en anular» = sí por defecto, sin preguntarlo (decisión ronda 12). |
| **Administradores SCA2** | Además, bandeja de errores (`/errores`), relanzar/descartar errores, mantenimiento (conceptos, argumentos, aplicaciones, compañías contrarias). |

El perfil, la oficina (NUUMA), la compañía y la estructura comercial se leen de CORE al entrar; la aplicación no tiene usuarios propios.

## 2. Pantallas y navegación

```
Site SCA2 ─ Buscador ──(póliza / cliente / NIF)──► Lista de solicitudes de la póliza ──► Detalle de la solicitud
            │                                        └─ «Nueva solicitud» ──► Alta ──► (motor decide) ──► pantalla de la acción
            └─ Errores (solo administradores)
Detalle ──► tarjetas de gestiones (Contra anulación, Acción administrativa, Autorización, Mecanización, Verti/vencimiento)
            └─ RETOMAR en la tarjeta abierta ──► pantalla de la acción (misma ventana)
```

- **Un solo site** (`/sca2`); no existe la «Decisora» como entrada separada: el usuario entra por el buscador. ⚠️ Las aplicaciones que abrían SCA por URL con `origen` (SGC, STCAT, ALT, FDC…) hoy no están conectadas a SCA2 (todas las solicitudes se graban con origen `SCA2`). ❓ Pendiente decidir si SCA2 debe aceptar esas entradas (p. ej. origen FDC muestra «Tipo catalogación»).
- La navegación mantiene el estado en la URL: al refrescar (F5) se vuelve a la misma solicitud/pantalla.
- Las pantallas de acción se abren **dentro del Detalle** («en la misma cadena»): al terminar una acción cuyo resultado lleva a otra (por ejemplo contra anulación negativa → mecanización → inducción Verti), la siguiente pantalla se abre automáticamente sin pasar por el buscador.

## 3. Buscador y lista de solicitudes

- Búsqueda por **número de póliza**, por **cliente** (datos de CORE) o por **NIF**.
- Para una póliza se muestran las **solicitudes existentes en CORE** («Últimas solicitudes», incluidas las creadas con SCA o históricas) y las de SCA2. Las solicitudes creadas con SCA se abren en un **Detalle de sólo consulta** (como hace SCA con las ajenas).
- Cada fila lleva la **etiqueta de estado y color de la HU3980** (listado por NUUMA): «Solicitud Pendiente» (naranja), «Mecanización Enviada», «Pendiente de Autorización» (naranja), «Finalizado Contra Anulación Positiva» (verde), «Solicitud Finalizada sin anular» (rojo), «Finalizada. Anulación realizada» (azul), «Solicitud Finalizada. Rechazada anulación» (rojo), «Cancelada», «Solicitud Caducada», «Anulada Caducada» (gris), «Póliza Anulada. Solicitud Pendiente Nivel 2». La etiqueta se calcula con el estado de la solicitud en CORE y el estado de la última gestión de mecanización/autorización. Decisión ronda 12: una solicitud finalizada en CORE con la mecanización «INCOMPLETA» (NSE sin responder) se muestra como **«Pendiente de Autorización»**. ⚠️ SCA TEST sigue mostrando los textos antiguos (pendiente de actualizar SCA).
- Si la póliza ya tiene una solicitud abierta en CORE (estado 1 o 2), el botón de alta se sustituye por **VER SOLICITUD** y el aviso explica que no debe generarse otra (texto de SCA2, confirmado por el analista).

## 4. Alta de la solicitud

1. **Identificación de la póliza**: se consulta CORE/Emisión; se muestran cabecera (tomador, producto, vencimiento, forma de pago, plan de pagos si lo hay con su detalle) y datos del productor. Pólizas **vencidas o anuladas** también pueden darse de alta (el aviso se da al guardar, como SCA). Pólizas de **Vida** redirigen a GESVIDA; **Más Móvil** no permite alta (como SCA).
2. **Formulario**: motivo → detalle → causa (listas de CORE; para SI24 se ocultan los que no tienen causas disponibles), fecha de anulación, canal de entrada, medio de comunicación, observaciones, teléfono de contacto, datos de otras solicitudes de la póliza. Validaciones de fecha al GUARDAR (anterior al efecto, posterior al vencimiento, más de 18 meses, impagos…) como SCA.
3. **Simulación de anulación** obligatoria para pólizas wAutemis (popup con prima/deducciones como SCA) y detección de pólizas **PRRA**. Errores del servicio de simulación: **M201** («la póliza tiene una operación pendiente», bloquea) y **M206** («error al consultar la situación», deja continuar).
4. **GUARDAR**: SCA2 crea la solicitud en CORE (número de solicitud) y graba todos los datos en su base de datos (datos básicos, solicitud, perfiles, póliza, productor, coberturas, trazabilidad). A continuación, de forma automática, **el motor de reglas decide la acción** (§5) y se crea la tarea; la pantalla salta a la pantalla de la acción decidida. Mientras el motor decide se muestra «Determinando la acción…». ❓ Propuesta pendiente de decisión: saltar al Detalle en cuanto CORE devuelve el número (evita que el formulario reaparezca si la decisión tarda). Si el alta falla, el error queda en la bandeja de errores y no se crea nada a medias.
5. **Segunda solicitud sobre la misma póliza**: bloqueada mientras la anterior esté abierta en CORE (ver §3).

## 5. Decisión de la acción (motor de reglas)

Tras el alta, tras cada acción completada y tras la mecanización, SCA2 pregunta al **motor de reglas corporativo** (el mismo servicio que usa SCA) qué hacer con la solicitud. Datos enviados: póliza, perfil/estructura del gestor, canal, SI24 o no, código de intermediario, catalogación, `anulaExperto` (sólo SI24 + póliza con acuerdo) y `anulaTecnicos` (true por defecto para CCC/CCR). El motor devuelve **acción + nivel + grupo**:

| Acción del motor | Qué hace SCA2 |
|---|---|
| CONTRA ANULAR nivel 1/2/3 | Crea una tarea de contra anulación para el grupo/nivel indicado (nivel 1: oficina del gestor; nivel 2: SI24 / GGE Expertos). |
| ACCIONES ADMINISTRATIVAS nivel 1/2/3 | Crea una tarea de acción administrativa. |
| AUTORIZACIÓN nivel 1/2/3 | Crea una tarea de autorización fuera de norma (y la autorización en CORE). |
| MECANIZAR | Crea la tarea de mecanización (anulación efectiva). |
| NO MECANIZAR / FIN PROCESO | Finaliza la solicitud sin anular. |
| IR A NIVEL 2/3 | Cambio de nivel: gestión SGC + notificación (DUE para SI24) y nueva decisión. |

Cada tarea tiene **caducidad** (por nivel); al vencer, el barrido de caducidad la caduca y finaliza la solicitud como caducada (como SCA). Si el motor falla, reintenta hasta 3 veces y deja el error en la bandeja.

## 6. Contra anulación (retención del cliente)

Pantalla con cabecera de póliza y cliente, trazabilidad del cliente, **argumentario** (argumentos de GAIA por producto; marcar los usados), **ofertas de campaña** cuando la póliza las tiene (TTQ/tréboles: asigna los tréboles de la campaña y finaliza como SCA; Club MAPFRE; Retos; SVA; descuentos Vida ❓ regalos SVA y «Pérdida de descuentos» pendientes de decisión), compañía contraria y catalogación, oficina gestora y observaciones.

Resultados posibles:

- **POSITIVO** (el cliente se queda): la contra anulación queda «Finalizada Positiva», la póliza se conserva y la solicitud termina (la pantalla vuelve al buscador, como SCA).
- **NEGATIVO** (el cliente insiste): tras marcar un argumento y **FINALIZAR**, SCA2 encadena las preguntas de SCA («Se van a finalizar las acciones…» → Sí/No; aviso de **corredor** «el cliente debe dirigirse a su oficina/corredor» en nivel 1; **ilocalizable**; canal telemático; póliza con acuerdo), cierra la CA en CORE con el estado final derivado y pregunta de nuevo al motor, que normalmente lleva a **Mecanización** (§9) o a **nivel 2** (SI24) si la póliza tiene acuerdo especial.
- **POSPONER**: se guarda la fecha de dietario, la **oficina elegida**, compañía/catalogación; al **RETOMAR** se recuperan (⚠️ SCA pierde la oficina al retomar; mejora aceptada por el analista).
- **CANCELAR**: cierra la gestión en CORE con estado 9 y deja la solicitud «Cancelada».
- Impresión de la **carta** (plantilla) necesaria para habilitar FINALIZAR cuando aplica; los documentos adjuntados se envían al gestor documental (Documentum) y se registran en CORE al finalizar. Desde la ronda 13, **el botón «ojo» permite ver el documento recién adjuntado** antes de guardarlo; el visor tiene CONTINUAR arriba y vuelve a la lista de documentos; **Imprimir** sigue mostrando la plantilla.
- Reglas de permisos: la pregunta «¿el cliente insiste en anular por este canal?» ya no se hace a nadie (decisión ronda 11/12); SI24 sólo gestiona en nivel 2; Red Mapfre no retoma tareas de SI24.

## 7. Acciones administrativas

Para causas administrativas (baja del vehículo, venta con/sin traspaso, duplicidad, fallecimiento…). Pantalla con cabecera, **catalogación / compañía contraria** y **documentación** por causa: DNI, contrato de compraventa (con traspaso) o «Documento compra/venta sin traspaso». Reglas: sólo el documento «sin traspaso» cuenta como documentación completa; con el contrato «con traspaso» se avisa «al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» (como SCA, confirmado). ⚠️ El documento tipo 9 (sin traspaso) no queda en CORE, sólo el DNI, igual que en SCA (CORE lo rechaza) — decisión: como SCA.

Visor del adjunto con el botón «ojo» (ronda 13), impresión de plantilla, POSPONER/RETOMAR con oficina, FINALIZAR → nueva decisión del motor (normalmente mecanización). SI24 no ve las causas 13/14/16/17/18/28/31/32.

## 8. Autorización fuera de norma

Se crea sólo cuando Emisión deja la anulación «pendiente de aceptar» (pólizas wAutemis con avisos 00000005/00000006) o cuando el motor lo decide. Pantalla con los datos de la anulación y botones **ACEPTAR / RECHAZAR / CANCELAR / POSPONER**: aceptar o rechazar se graba en CORE (gestión 7 «Actualización desde NSE» si viene de NSE), cancelar graba en CORE y muestra el resultado real. El Detalle muestra «Autorización Rechazada» en rojo cuando NSE la rechaza. Si la autorización se concede, la mecanización continúa; si no, la solicitud finaliza sin anular.

## 9. Mecanización (anulación efectiva)

1. Pantalla de **confirmación**: datos de la anulación (fecha de CORE, motivo/detalle/causa traducidos para NEW/NSE, reserva de prima para wAutemis, importe) y botones **CANCELAR / ANULAR PÓLIZA**. Desde la ronda 13 **sólo** se muestra la confirmación; la inducción Verti no aparece aquí (error del análisis corregido).
2. **ANULAR PÓLIZA** llama a Emisión (guardar mecanización) y crea la gestión en CORE. Avisos NSE 00000005/00000006 → autorización pendiente (§8).
3. **Derivación a Verti / Vencimiento** (criterio del analista, ronda 24): la pantalla previa «Verti / Vencimiento» se muestra **después de la Contra Anulación** y sólo si se cumplen las tres condiciones a la vez: el switch funcional `vertiSuscripcionInteligente` está activo, el motor de contactos devuelve VERTI o VENCIMIENTO y la acción decidida es MECANIZAR. No aparece con contacto vacío, en saltos de nivel, en Acciones Administrativas ni con el switch apagado. Lleva la cabecera común de la solicitud y un único botón **CONTINUAR**; no decide el flujo. La **inducción** (mismo proceso corporativo CMP que SCA) se lanza al mecanizar siempre que el contacto sea VERTI/VENCIMIENTO, con independencia del switch y de la pantalla. ❓ La casilla de **vencimiento (SGC a un año)** no está implementada todavía en SCA2. ❓ Pendiente confirmar si el switch es el FLAG global del concepto funcional (lo implementado) o la marca por usuario.
4. Tras mecanizar: si la póliza es wAutemis «pendiente de aceptar» se espera a **ANL** hasta que concluya el **ciclo completo** (Central + NEW + SGO y respuesta de autorización/rechazo); ya no basta con que ANL marque autorizado/rechazado. Si tras la respuesta aparecen errores, se esperan 24 h y la solicitud termina con error `ANL_TIMEOUT` (criterio del analista, ronda 24). Después se actualiza la mecanización en CORE, se finaliza la gestión SGC y se vuelve a preguntar al motor (que puede crear una **contra anulación de nivel 2** para SI24). Si NSE no responde, la mecanización queda «Incompleta» hasta que el servicio externo la actualice («Pendiente de Autorización» en el listado). Para pruebas, la página de mantenimiento **Pendientes de autorizar (wAutemis)** permite AUTORIZAR/RECHAZAR (lanzan `ANL Desbloquear` igual que lo haría SGO) y CANCELAR (cierra la solicitud sin pasar por ANL).
5. SCA2 tiene su propio **batch de mecanización NSE** (`SCA2 Batch Mecanizacion NSE`), que sólo procesa solicitudes de SCA2 de origen NSE y envía los fallos a la bandeja de errores. Está **desactivado** (`SCA2_BOOL_BATCH_NSE = false`, sin planificación) hasta que el analista autorice activarlo.

## 10. Finalización, niveles y notificaciones

- **Finalizar**: cierra la solicitud en CORE (estado final según el resultado), finaliza la gestión **SGC** cuando existe (`idGestionSGC` ≠ 0, p. ej. tras posponer o cambiar de nivel), envía el **correo DUE** a SI24 cuando corresponde (con tomador, DNI, email y teléfono), guarda la trazabilidad y marca la solicitud como finalizada en SCA2.
- **Cambio de nivel** (IR A NIVEL 2/3 o CA negativa con acuerdo): gestión SGC de nivel 2, notificación `SGC`/`SI24`, nueva decisión del motor y tarea para el grupo de destino. Nivel 2 = SI24 / GGE Expertos.
- **Caducidad**: barrido periódico; tarea caducada → solicitud «Caducada» o «Anulada Caducada» en CORE.
- **Finalizadas**: no se puede Completar ni Retomar nada; Detalle de consulta.

## 11. Detalle de la solicitud

- **Cabecera** (póliza, tomador, producto, estado CORE, fechas de solicitud/resolución — la de resolución vacía mientras está pendiente).
- **Tarjetas de gestiones** (una por acción): Contra anulación, Acción administrativa, Autorización, Mecanización, Gestión Verti/vencimiento, con estado («Incompleta», «Finalizada Positiva/Negativa», «Anulación Realizada», «Autorización Rechazada»…), nivel, fechas y botón **RETOMAR** sólo en la tarjeta abierta que el usuario puede gestionar.
- **Pestañas**: Solicitud de anulación (datos del alta y compañías contrarias), Datos de la póliza, Tareas, Transiciones (historial de comandos) y Errores (sólo administradores).

## 12. Documentos

Los documentos se adjuntan en Appian durante la gestión (visibles con el «ojo»), se suben al gestor documental **Documentum** al finalizar la acción y se registran en CORE (tipo de documento según la causa). Al relanzar una acción fallida se **reutiliza** la referencia de Documentum (sin duplicados). Al subir, SCA2 **valida la referencia** que devuelve el gestor documental antes de darla por buena: si falta o no es correcta, la acción no se considera completada, el usuario ve un error accionable (puede volver a adjuntar y reintentar) y queda una fila `DOC_GD_FAIL` en la bandeja de errores. ❓ Al reintentar desde pantalla el fichero puede quedar duplicado en el SGD (CORE conserva uno por tipo); ❓ si el reintento va bien, quién descarta la fila `DOC_GD_FAIL`. La impresión de plantillas genera la gestión 4 y el documento una sola vez (idempotente).

## 13. Bandeja de errores y relanzamiento (administradores)

Cada comando que falla (alta, decisión, crear/completar acción, mecanizar, finalizar…) deja una fila con solicitud, comando, nodo, mensaje y payload. El administrador puede **relanzar** (vuelve a ejecutar el comando desde el punto fallido, con idempotencia: lo ya hecho no se repite) o **descartar**. Tres fallos seguidos → BLOQUEADO. Los errores de CORE/Emisión/Documentum/ANL se distinguen de los propios. Además de los comandos, la bandeja registra las subidas fallidas al SGD (`DOC_GD_FAIL`), los fallos del batch NSE y las **desincronizaciones CORE/SCA2** (`DESINCRONIZACION_CORE`: CORE da la solicitud por cerrada y SCA2 no, con el payload de ambos estados) para resolverlas desde ahí y no a mano. ❓ Quién debe ver la bandeja (hoy sólo administradores).

## 14. Lo que SCA2 hace distinto de SCA (resumen) y decisiones abiertas

| Tema | SCA | SCA2 | Estado |
|---|---|---|---|
| Entrada | Site + Decisora por URL con `origen` | Un site, sin Decisora | ❓ origen FDC |
| Procesos | Instancias de larga duración (días) | Comandos atómicos + estado en BBDD + bandeja de errores | Decidido |
| Etiquetas del listado | Textos antiguos | HU3980 | Confirmado; falta actualizar SCA |
| Oficina al retomar | Se pierde | Se conserva | Confirmado |
| Pregunta «¿insiste el cliente?» | SI24 y Gestión Especial | No se pregunta; CCC/CCR = sí por defecto | Confirmado |
| Causas SI24 | Visibles | Ocultas 13/14/16/17/18/28/31/32 + cascada | Confirmado |
| Espera ANL | Indefinida | Ciclo completo de ANL; 24 h tras la respuesta si hay errores → error | Confirmado (ronda 24) |
| Batch NSE | Propio | Propio, desactivado (`SCA2_BOOL_BATCH_NSE`) | Confirmado; activar cuando lo autorice el analista |
| Documento sin traspaso en CORE | No llega | No llega | Como SCA |
| Visionado al adjuntar | No | Sí (ojo + CONTINUAR) | Evolutivo ronda 13 |
| Pantalla previa Verti / Vencimiento | No existe | Tras la CA, sólo con switch ON + contacto VERTI/VENCIMIENTO + MECANIZAR; un botón CONTINUAR | Confirmado (ronda 24); ❓ qué switch |
| RETOMAR (AA y nivel 2) | Sólo propietario | Cualquier usuario del grupo; la misma llamada a CORE que POSPONER con el nuuma que retoma | Confirmado (ronda 24) |
| Impresión de la carta | Una por solicitud | Una por solicitud; fecha, usuario y grupo visibles en el Detalle | Confirmado (ronda 24) |
| Validación de la subida al SGD | No | Referencia validada, error accionable y reintento | Evolutivo ronda 24 |
| Mantenimiento «Pendientes de autorizar (wAutemis)» | No existe | AUTORIZAR / RECHAZAR (vía ANL Desbloquear) / CANCELAR, para pruebas | Evolutivo ronda 19 |
| Inducción vencimiento (SGC a un año) | Sí | Pendiente | ❓ |
| Retorno al formulario tras el alta | — | Puede verse mientras el motor decide | ❓ saltar al Detalle |

Preguntas abiertas completas: `20-pendientes-y-dudas-funcionales.md`, `26-consolidado-ronda9.md` §6, `28-consolidado-ronda10.md`, `33-respuestas-analista-ronda12.md` §3 y `34-ronda13-visionado-verti-alta.md`.
