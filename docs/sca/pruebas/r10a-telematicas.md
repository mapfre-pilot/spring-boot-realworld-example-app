# R10-A · Telemáticas — Alta y Contra Anulación con pólizas de productor telemático/telefónico (SCA vs SCA2, Appian TEST)

Sesión: R10-A (ronda 10). Fecha: 2026-10-14. Usuarios: JJGONZ2 (Oficina CE_RM) y SISANS (SI24 Experto). Regla: SCA TEST es la referencia.

## 1. Pólizas de la sección R10-A (clasificación por consulta de sólo lectura NSE/productor)

Todas las pólizas asignadas son NSE (Hogar `073…` / Autos `200…`, `0003166101513`) y todas tienen productor de canal **INTERNET-TELEFO** (`estele = S`, `essi24 = S`). Ninguna informa `anulatecnicos`/`anulaexpertos` en el productor.

| Póliza | Producto | Estado póliza | Clase productor | Solicitudes CORE previas (abiertas) | Uso en R10-A |
|---|---|---|---|---|---|
| 0731480190624 | Hogar | Vigente – pendiente de anulación | 35 Negocio directo teléfono | 7 (0) | S3 SCA |
| 2002200588051 | Autos | Vigente – pendiente de anulación | 35 Negocio directo teléfono | 3 (1 abierta: 15787783) | S5 reserva |
| 2002200222543 | Autos | Anulada | 06 Delegados producción Internet | 3 (0) | S5 anulada (SCA y SCA2) |
| 0732000028208 | Hogar | Vigente | 35 Negocio directo teléfono | 0 | S3 SCA2 |
| 2001900000272 | Autos | Vigente – pendiente de anulación | 06 Delegados producción Internet | 1 (0) | reserva |
| 0003166101513 | Autos | Vencida | 39 Gestores remotos | 1 (0) | S5 vencida SCA |
| 0732000180872 | Hogar | Vencida | 05 Delegados producción teléfono | 23 (0) | — |
| 0731600111867 | Hogar | Vencida | 05 | 0 | — |
| 2002400517348 | Autos | Vencida | 06 | 0 | S5 vencida SCA2 |
| 2002500378119 | Autos | Vencida | 05 | 0 | — |
| 2002200142401 | Autos | Vencida | 05 | 4 (0) | — |
| 2002400515036 | Autos | Vencida | 78 eBrokers comparadores (Rastreator) | 1 (0) | — |
| 2002600042666 | Autos | Vigente | 06 Delegados producción Internet (web mapfre.es) | 1 (0) | S1 SCA |
| 2002600018038 | Autos | Vigente | 06 | 1 (0) | S2 SCA |
| 0732500051934 | Hogar | Vencida | 05 | 1 (0) | — |
| 2002500448422 | Autos | Vigente – pendiente de solicitud | 05 | 1 (1 abierta: 15786466) | S5 solicitud abierta (SCA y SCA2) |
| 2002600042650 | Autos | Vigente | 06 | 1 (0) | S1 SCA2 |
| 2002600038741 | Autos | Vigente | 06 | 1 (0) | S2 SCA2 |
| 0732400093704 | Hogar | Anulada | 05 | 38 (1 abierta: 15786379) | — |
| 2002200111333 | Autos | Vencida | 35 | 1 (0) | — |

Limitación de datos: sólo 5 pólizas están vigentes y sin solicitud abierta; el resto están vencidas, anuladas o con solicitud abierta en CORE, por lo que sólo sirven para comparar mensajes de bloqueo.

## 2. Casos del plan cubiertos (telemáticas / canal telefónico)

Casos filtrados de `planes/alta.md` y `planes/contra-anular-v2.md` que mencionan el canal telemático/telefónico o dependen de él, más los que H1–H3 dejaron «no probados por falta de pólizas telemáticas».

| Id plan | Descripción | Resultado SCA | Resultado SCA2 | Veredicto | Solicitudes / pólizas |
|---|---|---|---|---|---|
| manual_test-23 / manual_test_2-19 (alta) | Alta telemática que deriva a Acción Administrativa (Desaparición del riesgo → Baja de vehículo), respuesta **No** a «¿insiste en anular por este canal?» | Alta creada; popup con aviso de repetición + advertencia de documentos (baja de tráfico / historial / desguace). **No aparece ninguna pregunta de insistencia**. La decisora de SCA no llegó a crear la tarea de Acciones Administrativas (ver §5). | Alta creada; mismo texto de advertencia de documentos; **no aparece la pregunta**; navega a Acciones Administrativas con documentación Baja vehículo / Histórico tráfico / Justificante desguace / DNI. | **OK (igual)** en lo comparable: ninguna de las dos apps pregunta «¿insiste?» en el alta. El plan describe un modal que el SCA TEST actual no tiene (el dato «anula técnicos» se toma del productor, y en estas pólizas es «no»). Finalización de la AA en SCA **no probada** (sin tarea). | SCA 15787976 (2002600018038) · SCA2 15787979 (2002600038741) |
| manual_test-24 / manual_test_2-20 (alta) | Igual que el anterior con respuesta **Sí** | No aplicable: la pregunta no existe en el alta de SCA TEST | Idem | **No probado** (precondición inexistente en SCA TEST) — pregunta al analista nº 1 | — |
| manual_test_2-17 (CA) | Paso a experto: SI24 finaliza negativa una CA telemática y ve «Esta póliza es de origen telemático o telefónico, ¿el cliente insiste…?» | Ninguna solicitud saltó a SI24 (el motor dejó todo en nivel 1 Oficina) y la decisora de SCA no creó la CA. SISANS ve las solicitudes pero no tiene tarea. | SISANS ve 15787973 (CA ya finalizada negativa por Oficina) sin tarea pendiente. Por diseño (decisión del analista ronda 9) SCA2 sólo hace la pregunta a CCC/CCR. | **Pendiente de decisión** (ya documentado en ronda 9): en SCA la pregunta la ve SI24/GGE; en SCA2 sólo CCC/CCR. **No probado** en UI con SISANS por falta de solicitud en nivel 2. | 15787971 / 15787973 |
| manual_test_2-18 (CA) | Paso a experto con póliza Ford/Bankia telemática | No hay pólizas Ford/Bankia en la sección R10-A | — | **No probado** (sin datos) | — |
| manual_test_2-19 (CA) | Telemática + corredor (aviso «dirigirse a oficina») | Las 20 pólizas de R10-A son de productor directo/delegado/eBroker, ninguna de corredor | — | **No probado** (sin datos; corresponde a R10-B) | — |
| H3 D2 / posponer sin contacto, 3ª gestión «Ilocalizable», impresión, DUE (SI24) | Cadena de preguntas al FINALIZAR y cierre Ilocalizable para SI24 | Sin tarea de CA en SCA (decisora no ejecutó) | CA Oficina: POSPONER pide oficina y confirma «Se va a posponer la solicitud de contra anulación»; RETOMAR correcto; NEGATIVO + FINALIZAR genera carta (Impresión Finalizada) y redirige a la anulación NSE; **no aparece ninguna pregunta** (contacto, correspondencia, telemática, acuerdos). | **No comparable hoy** (SCA sin CA). La ausencia de cadena de preguntas en SCA2 para Oficina coincide con lo esperado para CE_RM (en SCA esas preguntas son de SI24/GGE/CCC). Ilocalizable/DUE con SI24: **no probado** (sin solicitud en nivel 2). | 15787973 |
| Alta – motor telemática (decisión) | A dónde envía el motor una solicitud de Oficina sobre póliza telemática (precio) | Alta 15787971 creada en CORE con catalogación «A VENCIMIENTO». SCA se quedó «Aún procesando» >5 min y terminó en «403 Acceso denegado»; detalle sólo «Alta Solicitud — Finalizada». | Alta 15787973; a los 17 s el motor creó la gestión de Contra Anulación (nivel 1, Oficina) y la app navegó a ella. | **Pendiente**: la decisora de SCA TEST no ejecuta hoy (hallazgo externo), por lo que no se puede confirmar que la decisión de SCA2 (CA nivel 1 Oficina, sin paso a SI24) sea la misma. | 15787971 / 15787973 |
| Alta – Hogar telefónica (positivo) | Alta + CA POSITIVO sobre Hogar de productor «Negocio directo teléfono» | Alta 15787984 creada (póliza en estado «pendiente de anulación»); sin CA. | **Fallo**: tras ACEPTAR en la pantalla de validaciones, SCA2 volvió al formulario relleno sin mensaje; CORE no tiene solicitud y el registro de errores de SCA2 no tiene ningún error de esa hora. | **Divergencia propia de SCA2 pendiente de reproducir/corregir** (ver §3 S3 y §4). POSITIVO **no probado** en ninguna. | SCA 15787984 (0731480190624) · SCA2 — (0732000028208) |
| Alta – mensajes de bloqueo | Solicitud abierta / póliza vencida / póliza anulada | Abierta: «La póliza ya tiene una solicitud abierta en Appian» (botón Alta inactivo). Vencida y anulada: entra al formulario sin aviso previo. | Abierta: «No puede crear una nueva solicitud ya que existe una solicitud de anulación abierta. Puede realizar las siguientes acciones…» (botón Alta visible en rojo) + campo «Tipo Póliza: NO VIDA». Vencida y anulada: entra al formulario sin aviso previo. | Abierta: **Divergencia de texto** (SCA2 da más explicación; decidir si se quiere el literal de SCA) — pregunta nº 3. Vencida/anulada: **OK (igual)**; no se guardó para no consumir pólizas. | 2002500448422 · 0003166101513 / 2002400517348 · 2002200222543 |
| Alta – popup repetición | «Está grabando una solicitud con los mismos datos que la anterior. ¿Desea continuar?» | Texto igual; en la misma pantalla de confirmación con CANCELAR/ACEPTAR. | Texto igual; modal propio «¿Desea continuar?» con NO/SÍ y después la pantalla de validaciones. | **OK** (misma función, presentación distinta) | — |
| Alta – paso a Expertos (popup) | Oferta «pasar a Expertos en retención» + teléfono en el popup del alta | No se ofreció en ninguna póliza telemática probada | No se ofreció | **OK (igual)** | — |

Resumen: OK/igual 5 · divergencia propia SCA2 pendiente 1 (alta Hogar SCA2) · divergencia de texto 1 (mensaje solicitud abierta) · pendiente de decisión 1 (pregunta «¿insiste?» para SI24) · no comparable por SCA 2 (decisión del motor; cadena CA) · no probado por falta de datos 3 (Ford/Bankia, corredor telemático, SI24 nivel 2).

## 3. Resultados por escenario de UI (JJGONZ2 Oficina; consulta con SISANS)

Informe de UI del testing agent con 49 capturas y grabación: resumen aquí; capturas clave adjuntas al mensaje final de la sesión.

- **S1 Autos telemática (Internet), precio.** SCA 2002600042666 → 15787971; SCA2 2002600042650 → 15787973. Popups del alta iguales en texto (aviso de repetición; validaciones). En SCA el ACEPTAR tardó >5 min y terminó en «403 Acceso denegado»; la solicitud existe en CORE pero sólo con la gestión de alta. En SCA2 el motor creó la Contra Anulación en 17 s; POSPONER (pide oficina) → RETOMAR → argumento «Incremento prima siniestros», NEGATIVO, FINALIZAR (carta generada; «CORRECTO. Los datos se han guardado correctamente. Se va a redirigir a la anulación») → detalle NSE de anulación con botones CANCELAR / ANULAR PÓLIZA / VOLVER AL DETALLE (no se pulsó ANULAR PÓLIZA). Estado final SCA2: Pendiente, nivel 1; tarjetas Contra Anulación Finalizada Negativa, Impresión Finalizada, Mecanización Incompleta. CORE: gestión CA 43705614 FINALIZADA NEGATIVA, gestión de impresión FINALIZADA, gestión de anulación INCOMPLETA.
- **S2 Baja de vehículo → Acciones Administrativas.** SCA 2002600018038 → 15787976; SCA2 2002600038741 → 15787979. Advertencia de documentos idéntica en ambas. Ninguna pregunta telemática. SCA2 navega a Acciones Administrativas (documentación pendiente; no se finalizó). SCA sin tarea (decisora).
- **S3 Hogar telefónica.** SCA 0731480190624 → 15787984 (sin CA). SCA2 0732000028208: alta no creada tras ACEPTAR, sin mensaje (ver §4).
- **S4 SISANS.** Ve y abre las solicitudes de ambas apps; en SCA2 la tarjeta de Mecanización muestra «MECANIZACIÓN INCOMPLETA» y botón TRAZAR ANULACIÓN (no pulsado). Ninguna solicitud en nivel 2, por lo que no se pudo probar la retoma SI24 (contacto, impresión, Ilocalizable, DUE).
- **S5 Bloqueos.** Ver tabla §2.
- **S6 Bandeja de errores SCA2.** Ni JJGONZ2 ni SISANS tienen acceso a `/sca2/page/errores` («La página no existe o no tiene permiso para verla»). Se consultó el registro de errores por regla (`SCA2_consultarErroresSolicitud`): ningún error registrado hoy desde las 15:45 UTC.

## 4. Objetos Appian modificados

Ninguno. La única divergencia propia de SCA2 detectada (alta Hogar 0732000028208 sin solicitud ni error) no se pudo diagnosticar en esta sesión: la interfaz `SCA2_AltaSolicitudPage` lanza el proceso de alta de forma síncrona y sólo muestra mensaje si el proceso devuelve error; el proceso no registró error y CORE no recibió el alta. Se deja para reproducción con trazas de proceso (ver §6 recomendaciones). `SCA2_ContraAnulacionOpciones` estaba reservada por R10-C durante la sesión y no se ha tocado.

Nota de diseño confirmada (no es cambio): SCA2 obtiene el indicador telemático del productor (`estele`) igual que SCA y lo lleva hasta la Contra Anulación; la pregunta «¿insiste en anular por este canal?» existe en el modal de Contra Anulación de SCA2 pero, por la decisión del analista de la ronda 9, sólo se muestra a CCC/CCR (SCA la muestra a SI24 Experto/Front y GGE).

## 5. Hallazgos externos (CORE / NSE / Emisión / Documentum / PRE)

1. **Decisora de SCA TEST sin ejecutar**: las tres altas de SCA (15787971, 15787976, 15787984) quedaron sólo con la gestión de alta; la pantalla de SCA estuvo «Aún procesando» >5 min y acabó en «403 Acceso denegado». Esto impide comparar en SCA la decisión del motor, la Contra Anulación y las Acciones Administrativas con pólizas telemáticas. Comportamiento ya conocido de latencia de SCA TEST, hoy agravado.
2. **Datos de prueba**: las 20 pólizas de R10-A son NSE con tomador sin nombre (datos anonimizados); 12 están vencidas/anuladas, 3 «pendientes de anulación» y 3 con solicitud abierta en CORE. Sólo 5 vigentes sin solicitud abierta. No hay pólizas telemáticas wAutemis, ni de corredor, ni Ford/Bankia.
3. **Emisión (wAutemis)** devuelve «Error al obtener los datos de la póliza» para pólizas NSE como 0731480190624 (esperado: no son wAutemis); SCA2 las clasifica correctamente como NSE.
4. **CORE**: la descripción de catalogación en CORE («A VENCIMIENTO REALIZADA CONTRA ANULACION CON RESULTADO NEGATIVO», «A FECHA REALIZADAS ACCIONES ADMINISTRATIVAS») la escribe la decisión del motor; coincide con solicitudes históricas de la ronda 9. No es divergencia.

## 6. Preguntas para el analista (lenguaje funcional)

1. En el **alta** de una póliza telemática/telefónica que deriva a Acciones Administrativas, ¿debe preguntarse al gestor si el cliente insiste en anular por ese canal (como describen los casos 23/24 del plan)? Hoy ni SCA TEST ni SCA2 lo preguntan en el alta; la pregunta sólo existe al finalizar la Contra Anulación.
2. La pregunta «Esta póliza es de origen telemático o telefónico. ¿El cliente insiste en que se anule su póliza por este canal?» en SCA la ve SI24 (Experto y Front) y Gestión Especial; en SCA2, por la decisión de la ronda 9, sólo CCC/CCR. ¿Se confirma que SI24 **no** debe verla? ¿Aplica a CCC y CCR o sólo a CCC?
3. Mensaje de **solicitud abierta**: SCA dice «La póliza ya tiene una solicitud abierta en Appian»; SCA2 da un texto más largo con instrucciones (esperar contestación, no generar nueva solicitud, añadir documentos en NSE/SGO). ¿Se mantiene el texto de SCA2 o se iguala al de SCA?
4. Para una póliza telemática gestionada por **Oficina**, SCA2 envía la solicitud a Contra Anulación de nivel 1 (la misma oficina) sin paso a SI24 ni preguntas al finalizar. ¿Es el comportamiento esperado o debería saltar a SI24/Expertos por ser telemática?
5. Pólizas **vencidas o anuladas**: ninguna de las dos apps avisa al introducir la póliza (se llega al formulario). ¿Es correcto que el aviso se dé sólo al guardar?

Recomendaciones de prueba: reproducir el alta Hogar SCA2 (0732000028208 u otra Hogar vigente) con trazas del proceso de alta; cuando la decisora de SCA TEST vuelva a funcionar, repetir S1/S2 en SCA con las pólizas vigentes restantes (2001900000272 si deja de estar pendiente de anulación) para comparar la decisión del motor; para SI24 se necesita una póliza telemática cuyo productor tenga marcado «anula técnicos/expertos» o un acuerdo SI24.
