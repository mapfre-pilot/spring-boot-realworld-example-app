# Ronda 10 — Consolidado (telemáticas, corredor, campañas, plan de pagos, HU3978/HU3980 y Analisis SCA2)

> Estado: EN CURSO. Se completa cuando terminen R10-A/B/C/D. Plan: `27-plan-ronda10.md`; reparto: `pruebas/polizas-ronda10.md`; coordinación: `pruebas/coordinacion-ronda10.md`.

## 1. Materiales de entrada
- Excel `PolizasPruebaPRE.xlsx` (pestañas telemáticas 20 únicas, corredor 187, campañas 33, plan de pagos 134; PRRA vacía; RCI, Más Móvil y Vida ya usadas en rondas anteriores).
- HU3978 (estados de solicitud y de mecanización) y HU3980 (etiquetas y colores del listado por NUUMA).
- `Analisis SCA2.docx`: documentos de venta en AA (15787945, 15787966) y actualización desde NSE no reflejada en el Detalle (15787950).

## 2. Trabajo del PADRE (hecho)
Ver `pruebas/r10-padre-hu3980-nse-documentos.md`.

| Punto | Resultado | Objetos SCA2 (versión) |
|---|---|---|
| HU3980 etiquetas/colores del buscador | Implementado y probado (LCP + UI). SCA TEST no implementa HU3980: ahí la referencia es el PDF. | calcularEstadoSolicitud 1→2, textoEstadoSolicitud 13→14, colorEstadoSolicitud 6→7, BuscadorTabla 11→12 |
| Detalle no reflejaba el rechazo NSE (15787950) | Corregido: tarjeta Autorización «Autorizacion Rechazada» (rojo) + «Actualizacion desde NSE», como SCA («Rechazada»). | DetalleSolicitud 52→54 |
| Documentos de venta en AA sólo DNI (15787945/15787966) | Misma regla que SCA (`calcularDocumentosASubir` idénticas): no es divergencia de SCA2. Pendiente caso nuevo de R10-D y decisión funcional (tipo 1 / tipo 9; CORE rechaza el tipo 9). | sin cambios |

## 3. Resultados de las sesiones
| Sesión | Informe | OK | Corregidas | Pendientes decisión | No probados |
|---|---|---|---|---|---|
| R10-A Telemáticas | `pruebas/r10a-telematicas.md` | OK 5 · corregidas 0 (hallazgo alta Hogar NSE corregido por el PADRE, anexo A del informe del padre: `SCA2_construirContextoAlta` v11, solicitud 15788005) · texto distinto 1 (mensaje de solicitud abierta) · decisión 1 (pregunta «¿insiste?» para SI24) · no comparables por SCA 2 (decisora SCA TEST 403) · sin datos 3 (todas las telemáticas del Excel son NSE; 5 vigentes) |
| R10-B Corredor | `pruebas/r10b-corredor.md` | OK 3 (altas/CA corredor, FORD→AA, SI24 en corredor, alta Hogar corredor 15788009 tras v11) | corregidas 2 (alta Hogar NSE, PADRE v11; FINALIZAR de CA abre la cadena Sí/No de SCA y el canal del productor llega al modal: `SCA2_ContraAnulacionModalSiNo` v3, `SCA2_ContraAnulacionOpciones` v48, `SCA2_cargarSolicitud` v7; UI con SISANS 15788001 y JJGONZ2 15788014) | decisión 5 (§6 CORR-1…5) | SCA TEST no ejecutó la decisora en sus 6 altas (sin UI de referencia); misma anualidad sin comparar |
| R10-C Campañas | `pruebas/r10c-campanas.md` | OK 2 (NEGATIVO con argumento TTQ; TTQ con cliente no activo en Club MAPFRE) | corregidas 1 caso / 4 defectos (TTQ tréboles: máximo y campaña reales, llamada a gestionarTTQ, NIF del tomador, cabecera `SOAPAction`) → 1 trébol asignado en Club MAPFRE y CA finalizada positiva en CORE (15788000/15788003/15788004) | decisión 2 (SVA regalos, pérdida de descuentos) + 4 menores (§6 CAMP-*) | PREMFIDE y RETOS: ninguna póliza del Excel tiene esas campañas en TEST; SCA TEST sin tarea de CA tras 4 altas |
| R10-D Plan de pagos / AA documentos / NSE | `pruebas/r10d-plan-pagos-documentos-nse.md` | OK 5 · corregidas 0 · decisión 1 (plan de pagos: ni SCA ni SCA2 avisan/bloquean) · tipo 9 «compraventa sin traspaso» no llega a CORE en ninguna app (diseño heredado de SCA; tipo 1, 3 y 7 sí) · NSE: autorización positiva de 15787945 nunca llegó a CORE (externo) · no probados 3 (recorridos SCA por latencia) · solicitudes nuevas 15787977/78, 15787986/92, 15787996/98 |

## 4. Divergencias corregidas en SCA2
| # | Origen | Qué pasaba en SCA2 | Corrección | Objeto / versión | Prueba |
|---|---|---|---|---|---|
| 1 | PADRE (HU3980) | Etiquetas/colores del buscador con textos internos antiguos | Tarjetas y colores según HU3980 (SCA TEST sigue con los textos antiguos; referencia = PDF) | `SCA2_calcularEstadoSolicitud` v2, `SCA2_textoEstadoSolicitud` v14, `SCA2_colorEstadoSolicitud` v7, `SCA2_BuscadorTabla` v12 | LCP + UI buscador |
| 2 | PADRE (Análisis SCA2) | Rechazo de autorización desde NSE no se veía en el Detalle (15787950) | Si `consultarAutorizacion` no da `codEstado`, se lee la gestión 7 de CORE → «Autorizacion Rechazada» en rojo con «Actualizacion desde NSE» | `SCA2_DetalleSolicitud` v54 | UI Detalle 15787950 (SCA y SCA2 iguales) |
| 3 | R10-A → PADRE | Alta de pólizas **Hogar NSE** volvía al formulario sin solicitud ni error (0732000028208) | `datosPolizaHogar` vacío hacía fallar `SCA2_PreGenerarStudAnul` en el PM de alta; ahora se rellena (calificación, fecha nacimiento, oficina comercial) como en Autos | `SCA2_construirContextoAlta` v11 | LCP (Hogar/Autos NSE y wAutemis) + UI: solicitud 15788005 → AA |

| 4 | R10-C | TTQ/tréboles: el modal mostraba un máximo fijo sin campaña, nunca llamaba a gestionarTTQ; Club MAPFRE fallaba por cliente vacío y por falta de cabecera `SOAPAction` | Respuesta DEFCART completa (`treboles`, campaña, máximo), NIF del tomador desde póliza/cabecera, `ignoreEmptyHeaders: false`; «¡Enhorabuena…!» no se solapa con el modal de tréboles | `SCA2_ContraAnulacionOpciones` 44→47, `SCA2_executeAsignarIntegracion` 1→2, `SCA2_ContraAnulacionModalRecuperacionPoliza` 4→5 | UI + Club MAPFRE (0,88 → 1,88 tréboles) + CORE FINALIZADA POSITIVA en 15788000 |
| 5 | R10-B | FINALIZAR de Contra Anulación lanzaba directamente el cierre con una confirmación genérica; no salía el aviso de corredor ni las preguntas de ilocalizable/canal/telemática/acuerdo de SCA | FINALIZAR abre `SCA2_ContraAnulacionModalSiNo` (caso 1, «Se van a finalizar las acciones de contra anulación. ¿Desea continuar?») y el modal, cuando en SCA haría submit, finaliza vía `onFinalizar` con el estado final de su casuística (corredor → 4) | `SCA2_ContraAnulacionModalSiNo` 2→3, `SCA2_ContraAnulacionOpciones` 47→48, `SCA2_cargarSolicitud` 6→7 (idcanal/idsubcanal/estele/essi24 en `datosProductor`, sin los cuales el modal nunca detectaba corredor/telemática) | LCP (modal caso corredor → botón OK sin error; render de Opciones y `cargarSolicitud` con 15788001) + UI: SISANS 15788001 (cadena Sí/No) y JJGONZ2 15788014 (caso simple). El aviso de corredor en sí no es alcanzable en TEST (sólo nivel 1 y SI24 siempre va a nivel 2): pregunta CORR-6 |

Revisados por el PADRE sin cambio: (a) tarjeta «Contra anulación» del Detalle tras CA positiva (pregunta 5 de R10-C): con CORE respondiendo, `SCA2_DetalleSolicitud` v54 pinta «Finalizada Positiva» para 15787994 y 15788000 (comprobado por LCP); lo visto por R10-C coincidió con la caída de `consultaGestion` de CORE (~17:00 UTC), en la que la tarjeta cae al estado local. (b) `SCA2_consultarDPIntegracion` y `SCA2_inbsDeleteDocumentDTOIntegracion`: la cabecera `SOAPAction` lleva el valor literal `""` (no vacío) y la configuración coincide con SCAC; no procede el cambio de `ignoreEmptyHeaders` que sí necesitó `SCA2_executeAsignarIntegracion`.

## 5. Diferencias externas / no reproducibles
- **SCA TEST**: la decisora del motor no ejecutó en las altas de SCA (15787971/76/84: «Aún procesando» >5 min → 403); el GUARDAR de la Contra Anulación se queda procesando y la flecha «volver» de la cabecera da error de evaluación (`sca_datoscabecera`). Impide comparar en SCA las decisiones del motor y los recorridos completos (R10-A, R10-D).
- **NSE → CORE**: la autorización positiva de 15787945 hecha en NSE nunca llegó a CORE (sigue INCOMPLETA, sin gestión 7); el rechazo de 15787950 sí llegó. Ninguna app puede mostrar lo que CORE no tiene.
- **CORE**: `consultarAutorizacion` devuelve `codEstado` vacío en el rechazo NSE; el estado se deduce de la gestión 7.
- **Documentos tipo 9** («compraventa sin traspaso»): no se registran en CORE en ninguna app (misma regla de documentos en SCA y SCA2; CORE rechaza el tipo); tipos 1, 3 y 7 sí llegan. Sin error en bandeja.
- **Datos de prueba**: las 20 telemáticas del Excel son NSE anonimizadas (5 vigentes sin solicitud); no hay telemáticas wAutemis, de corredor ni Ford/Bankia. Plan de pagos: sólo cabecera informativa en ambas apps.
- **Permisos**: la bandeja de errores de SCA2 no es visible para el perfil Oficina (JJGONZ2).
- **SCA TEST (R10-B/R10-C)**: 10 altas más desde SCA (15787975/80/89/95/99, 15788002 y las 4 de campañas) sin tarea de CA/AA nunca generada; CORE `consultaGestion` devolvió vacío para todas las solicitudes desde ~17:00 UTC durante un rato (afecta a la tarjeta del Detalle en ambas apps).
- **Campañas (R10-C)**: regalos SVA no abren ventana ni en SCA (defecto heredado); «Pérdida de descuentos» (290) no genera SGO en ninguna app; PREMFIDE/RETOS sin pólizas en TEST.
- **CORE cierra por su cuenta (R10-B)**: en 15788014 (JJGONZ2, corredor) 1 s después de grabar el argumento NEGATIVO la cabecera CORE pasó a «FINALIZADA NO REQUERIDA CONTRAANULACIÓN» (Nuuma PCARAGE) con la tarea SCA2 aún pendiente; no depende de SCA2 → pregunta CORR-7.
- **Datos de prueba (R10-B)**: las 10 pólizas 2002500499276…301 figuran como productor «RED AGEN / Expertos» y sin cabecera en CORE; no sirven como corredor.

## 6. Preguntas para el analista
1. **HU3980-1**: solicitud finalizada en CORE (estado 5) con mecanización `INCOMPLETA` porque NSE no respondió (15787945): ¿«Solicitud Pendiente», «Pendiente de Autorización» o «Solicitud Finalizada sin anular»? CORE no informa el estado de mecanización «pendiente de autorizar».
2. **HU3980-2**: ¿se actualizará SCA TEST con las etiquetas HU3980? Hasta entonces no hay comparación literal SCA/SCA2 en el buscador.
3. **NSE-1**: texto de la tarjeta de Autorización tras rechazo NSE: SCA «Rechazada» vs SCA2 «Autorizacion Rechazada» (CORE no devuelve `codEstado`). ¿Cuál se quiere?
4. **DOC-1**: en AA por venta del vehículo, el «Documento compra/venta sin traspaso del seguro» (tipo 9) no queda en CORE en ninguna de las dos aplicaciones (sólo DNI y contrato con traspaso). ¿Debe conservarse en CORE/gestor documental? ¿Debe avisar la pantalla a la oficina?
5. **DOC-2**: con el contrato de compraventa **con traspaso** adjunto, ambas apps avisan «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» (sólo el «sin traspaso» cuenta como documentación completa). ¿Es correcto?
6. **PLAN-1** (R10-D): ni SCA ni SCA2 avisan ni bloquean cuando la póliza está en un plan de pagos (sólo cabecera + detalle del plan). El plan de pruebas espera un aviso al finalizar la autorización («sacar la póliza del plan»). ¿Aviso o bloqueo, y en qué pantalla?
7. **TEL-1** (R10-A): la pregunta «¿El cliente insiste en que se anule su póliza por este canal?» la ve en SCA SI24 y Gestión Especial; en SCA2 (decisión ronda 9) sólo CCC/CCR. ¿Se confirma que SI24 no debe verla? ¿Debe preguntarse también en el alta cuando deriva a AA (casos 23/24 del plan)?
8. **TEL-2** (R10-A): mensaje de solicitud abierta: SCA «La póliza ya tiene una solicitud abierta en Appian»; SCA2 texto largo con instrucciones (esperar, no generar nueva, añadir documentos en NSE/SGO). ¿Cuál se mantiene?
9. **TEL-3** (R10-A): póliza telemática gestionada por Oficina → SCA2 la deja en Contra Anulación nivel 1 de la misma oficina, sin salto a SI24. ¿Es lo esperado o debe saltar a SI24/Expertos por ser telemática?
10. **NSE-2** (R10-D): autorización NSE de 15787945 que no llegó a CORE: ¿quién revisa el canal NSE→CORE? Mientras, ¿qué debe mostrar SCA2 (hoy «Mecanización Incompleta» / «Solicitud Finalizada sin anular»)?

11. **CORR-1** (R10-B): SI24 Experto finaliza negativa la CA de una póliza de **corredor** (canal 4/5): SCA avisa «La póliza es de un corredor, es necesario que el cliente se dirija a su oficina bancaria o corredor…» y cierra como «finalizada sin anular, derivada». SCA2 lo está reproduciendo (§4 #5): ¿se confirma ese comportamiento y ese estado?
12. **CORR-2** (R10-B): ¿se mantiene en SCA2 toda la cadena de preguntas de FINALIZAR de SCA (continuar → ilocalizable «¿se ha podido contactar?» → «¿insiste por este canal?» en correspondencia/telemática/acuerdo)? Se está igualando a SCA salvo indicación contraria.
13. **CORR-3** (R10-B): pólizas FORD/Automoción entran como Acción Administrativa sin la pregunta de «acuerdo especial» de los casos 25/26 del plan. ¿Sigue vigente esa pregunta en el alta?
14. **CORR-4** (R10-B): si el alta no consigue crear la solicitud y no hay error registrado, ¿debe la oficina ver «no se ha podido crear la solicitud, inténtelo de nuevo» (propuesta) en vez de volver al formulario sin aviso?
15. **CORR-5** (R10-B): ¿sustituir las pólizas 2002500499276…301 (sin productor corredor real en TEST) por pólizas de corredor válidas?
15b. **CORR-6** (R10-B): el aviso de corredor sólo aplica a Contra Anulación de **nivel 1** y las solicitudes de SI24 van siempre a nivel 2 por el motor; en TEST un SI24 no puede llegar a una CA de corredor de nivel 1 (no puede retomar tareas de Oficina). ¿Es correcto que ese aviso quede en la práctica sin uso, o debe mostrarse también en nivel 2 / a la Oficina?
15c. **CORR-7** (R10-B): al grabar un argumento NEGATIVO en 15788014, CORE cerró la solicitud en 1 s como «FINALIZADA NO REQUERIDA CONTRAANULACIÓN» (usuario PCARAGE) mientras la tarea seguía abierta. ¿Qué proceso de CORE cierra la solicitud al grabar un negativo y es el comportamiento esperado?
16. **CAMP-1** (R10-C): regalos SVA: ni SCA ni SCA2 abren la ventana de regalo/correo al finalizar positivo con «Servicio valor añadido». ¿Debe hacerlo SCA2 como dice el plan, o se mantiene como SCA?
17. **CAMP-2** (R10-C): «PÉRDIDA DE DESCUENTOS» no genera la solicitud SGO en ninguna app (sólo los argumentos de descuento por vinculación/retención, inexistentes en TEST). ¿Es lo esperado?
18. **CAMP-3** (R10-C): al confirmar tréboles la solicitud se finaliza sin mostrar «Se ha realizado la asignación de tréboles…» (igual que SCA). ¿Mostrar el mensaje antes de cerrar? Y al cancelar la ventana de tréboles la casilla del argumento sigue marcada (igual que SCA): ¿desmarcar?
19. **CAMP-4** (R10-C): pólizas de acuerdo especial (RCI) con «Tu te quedas RCI»: aviso de que la gestiona SI24 y no se puede anular desde la pantalla. ¿Debe permitirse asignar tréboles desde Oficina?

## 7. Cambios Appian de la ronda
Ver tabla de reservas en `pruebas/coordinacion-ronda10.md`.

| Objeto | Versiones | Sesión |
|---|---|---|
| `SCA2_calcularEstadoSolicitud` / `SCA2_textoEstadoSolicitud` / `SCA2_colorEstadoSolicitud` / `SCA2_BuscadorTabla` / `SCA2_TablaOtrasSol` | v2 / v14 / v7 / v12 (HU3980) | PADRE |
| `SCA2_DetalleSolicitud` | → v54 (autorización rechazada NSE) | PADRE |
| `SCA2_construirContextoAlta` | 10 → 11 (alta Hogar NSE) | PADRE |
| `SCA2_ContraAnulacionOpciones` | 44 → 47 (TTQ) · 47 → 48 (FINALIZAR → modal Sí/No) | R10-C · R10-B |
| `SCA2_cargarSolicitud` | 6 → 7 (canal/subcanal/estele/essi24 del productor) | R10-B |
| `SCA2_executeAsignarIntegracion` | 1 → 2 (`SOAPAction`) | R10-C |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | 4 → 5 (TTQ) | R10-C |
| `SCA2_ContraAnulacionModalSiNo` | 2 → 3 (`onFinalizar`) | R10-B |
