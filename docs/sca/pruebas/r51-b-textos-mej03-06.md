# R51-B — Textos MEJ-03, MEJ-04, MEJ-05 y MEJ-06 (SCA2, Appian TEST)

Fecha: 16/11/2026. Entorno: Appian TEST, site `sca2` (referencia SCA: `sca-site`). Sesión: https://mapfre.devinenterprise.com/sessions/8cbd0988b8854d26bf8034b43aa64d62

Respuesta de negocio aplicada (ggalv10, 16/11/2026): «Mensaje 05», «Mensaje 06», «Mensajes en 03» y MEJ-04. MEJ-01/02 (tréboles y enhorabuena) los hace R51-A y no se han tocado.

## 1. Decisiones

| Mensaje | Qué se ha hecho | Por qué |
|---|---|---|
| MEJ-05 (alta) | El texto de validaciones completadas sale de la constante nueva `SCA2_TXT_MSG_ALTA_VALIDACIONES_OK`: «Se han completado todas las validaciones para permitir generar la solicitud de contra anulación, se va a proceder a dar de alta la solicitud en el sistema». | Literal de negocio. |
| MEJ-06 (acuerdo especial SI24) | El aviso amarillo que ve Red Mapfre (perfil CE_RM, nivel 1) en la contra anulación de una póliza de acuerdo SI24 sale de `SCA2_TXT_MSG_ACUERDO_ESPECIAL_SI24`: «Esta póliza pertenece a un Acuerdo Especial. Puedes retenerla e iniciar la gestión de anulación. La finalización de la anulación será gestionada por SI24». El texto que ven los demás perfiles (igual que SCA) no cambia. | Literal de negocio. El aviso no bloquea nada: `local!bloqueoAcuerdoRedMapfre` solo elige el texto. La pantalla deja hacer argumentos, retener, ir a negativo y FINALIZAR, así que el texto nuevo coincide con lo que la pantalla permite hacer. No se ha cambiado el flujo. |
| MEJ-03 (Contra Anular Nivel 2) | En la pantalla CORRECTO que sale después de completar una acción (`SCA2_DetalleTareas`), si la siguiente tarea es CONTRA ANULAR NIVEL 2 sale una sola línea, `SCA2_TXT_MSG_GUARDADO_CA_NIVEL2`: «Los datos se han guardado correctamente. La gestión salta al SI24 en Nivel 2 para su finalización». Antes salían dos líneas: «Los datos se han guardado correctamente» y «La siguiente tarea (Contra Anular Nivel 2) se gestiona desde el Detalle de la solicitud». ACEPTAR no cambia: lleva al Detalle. | Literal de negocio. Sin cambio de flujo («No, finalmente no se cambia el flujo»). |
| MEJ-03 (Gestión Verti/vencimiento) | **La pantalla no se ha podido quitar.** Cuando la siguiente tarea es la Gestión Verti/vencimiento y no se abre aquí (está asignada a otro usuario), ahora sale solo `SCA2_TXT_MSG_GUARDADO_SIN_SIGUIENTE`: «Los datos se han guardado correctamente.». Antes salía también «La siguiente tarea (Gestión Verti/vencimiento) se gestiona desde el Detalle de la solicitud». Cuando la Verti sí se abre (es del usuario o no tiene usuario asignado), todo sigue igual: «Se va a redirigir a la siguiente tarea: Gestión Verti/vencimiento.» y se abre. | Esta pantalla es la tarjeta CORRECTO de `SCA2_DetalleTareas`, que se pinta dentro de `SCA2_DetalleSolicitud`. Para volver al Detalle hay que poner a falso `accionAbierta` en el `SCA2_DetalleSolicitud` padre, y eso solo lo hace el `saveInto` del botón ACEPTAR. En Appian una pantalla no guarda nada ni cambia de página sin que el usuario haga clic (ya lo vimos en R29-A §3). Además, la siguiente tarea la crea el motor después de la acción, así que se sabe con el sondeo y no en el momento del clic de FINALIZAR. Quitar la pantalla obligaría a reestructurar la navegación del Detalle, con riesgo para el resto de casos. Por eso se aplica la alternativa que ha dado negocio. |
| MEJ-04 (Acción Administrativa) | Confirmación de FINALIZAR (título «¿Desea continuar?»). Si se marca «el cliente no entrega documentación», sale `SCA2_TXT_MSG_ACCADM_SIN_DOCUMENTACION`: «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento». Si la causa exige el contrato de compra/venta (NO VOY A COMPRARME OTRO COCHE / SEGURO REGALADO POR LA COMPRA DE COCHE) y no se adjunta el documento tipo 9 (compra/venta sin traspaso), sale `SCA2_TXT_MSG_ACCADM_SIN_COMPRAVENTA`: «Al no adjuntar la documento de compra/venta sin traspaso del seguro, la póliza se anulará al vencimiento». En los demás casos sigue «Se va a finalizar la revisión de acciones administrativas». | Literal de negocio. Para distinguir los casos se usan los dos datos que la acción ya tenía y que deciden la anulación a vencimiento (`local!anulaAVencimiento` = `noEntregaDoc` o causa con contrato sin tipo 9). Si se dan las dos cosas, sale el mensaje de «sin documentación». No cambia lo que se guarda. |

## 2. Objetos cambiados (solo SCA2)

| Objeto | UUID | Versión antes → después | Cambio |
|---|---|---|---|
| IF `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v56 → v57 | Una línea: el literal pasa a `cons!SCA2_TXT_MSG_ALTA_VALIDACIONES_OK`. |
| IF `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | v80 → v81 | Una línea: el aviso de Red Mapfre pasa a `cons!SCA2_TXT_MSG_ACUERDO_ESPECIAL_SI24`. MEJ-01/02 intactos (R51-A no necesitaba este objeto). |
| IF `SCA2_AccionesAdministrativasPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | v25 → v26 | `confirmMessage` de FINALIZAR, con los dos casos. |
| IF `SCA2_DetalleTareas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | v44 → v45 | Locales nuevas `sigEnDetalle` (la siguiente tarea no se abre aquí; es la condición contraria a la redirección actual) y `msgGuardadoSiguiente`. La primera línea de CORRECTO usa el mensaje nuevo cuando lo hay, y la segunda («La siguiente tarea (…) se gestiona desde el Detalle…») se oculta en esos dos casos. No se ha tocado ni botones ni `saveInto` ni sondeo. |
| CONS (nuevas, v1) | `SCA2_TXT_MSG_ALTA_VALIDACIONES_OK` `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5750060`; `SCA2_TXT_MSG_ACUERDO_ESPECIAL_SI24` `…_5750066`; `SCA2_TXT_MSG_GUARDADO_CA_NIVEL2` `…_5750072`; `SCA2_TXT_MSG_GUARDADO_SIN_SIGUIENTE` `…_5750078`; `SCA2_TXT_MSG_ACCADM_SIN_DOCUMENTACION` `…_5750084`; `SCA2_TXT_MSG_ACCADM_SIN_COMPRAVENTA` `…_5750090` | — → v1 | Textos literales de negocio (tipo Texto, carpeta de reglas y constantes de SCA2). |

- No se ha guardado ningún modelo de proceso: no hay que republicar nada en Designer.
- No hay SQL.
- Copias antes y después en `docs/sca/pruebas/backups-r51/R51-B_*`. Reexportado después de guardar: lo guardado es idéntico al fichero editado. Diferencias: AltaSolicitudPage y ContraAnulacionOpciones, 1 línea cada una; AccionesAdministrativasPrincipal, solo `confirmMessage`; DetalleTareas, las dos locales y los dos puntos de uso.
- Coordinación: los objetos se reservaron y se liberaron en `coordinacion-ronda51.md`. Antes de guardar se comprobó que nadie más los había guardado entretanto (versión viva = la de la copia).

## 3. Pruebas en TEST (solicitudes nuevas)

Usuarios: JJGONZ2 (Red Mapfre) y SISANS (Si24), por «SSO Mapfre NO PRO». Pólizas del bloque nuevo `polizas/bloque-R51-B.txt` y la wAutemis 0002729325307. No se ha pulsado ANULAR PÓLIZA, no se han tocado solicitudes antiguas y no se ha llamado a `SCA2_consultarListadoArgumentosREST`. Capturas en `capturas-r51/`. Vídeo de toda la prueba (9 min 28 s): se entrega adjunto en el mensaje de la sesión; pesa demasiado para el repositorio.

| Caso | Solicitud (póliza) | Usuario | Pasos | Resultado | Captura |
|---|---|---|---|---|---|
| MEJ-05 alta normal | 15789193 (0002729325307, VW CARTERA, acuerdo Si24) | JJGONZ2 | Alta → GUARDAR | **OK**: «…generar la solicitud de contra anulación…» | `r51b-01-MEJ05-alta.png` |
| MEJ-06 acuerdo especial | 15789193 | JJGONZ2 | CA nivel 1 | **OK**: aviso amarillo con el literal nuevo. La pantalla deja seguir: argumento INCREMENTO PRIMA negativo e imprimir la carta → FINALIZAR | `r51b-02-MEJ06-aviso-acuerdo.png` |
| MEJ-03 Contra Anular Nivel 2 | 15789193 | JJGONZ2 | Negativo → carta → FINALIZAR → SÍ | **OK**: una sola línea «Los datos se han guardado correctamente. La gestión salta al SI24 en Nivel 2 para su finalización». ACEPTAR → Detalle. La CA nivel 2 queda en GGE EXPERTOS SI24 sin usuario | `r51b-03-MEJ03a-ca-nivel2.png`, `r51b-04-MEJ03a-detalle.png` |
| MEJ-03 Gestión Verti/vencimiento | 15789193 | SISANS | RETOMAR CA nivel 2 → negativo → FINALIZAR → SÍ → contacto SÍ | **OK**: solo «Los datos se han guardado correctamente.». ACEPTAR → Detalle. La Verti queda asignada a JJGONZ2 y SISANS no la abre (igual que R45-C) | `r51b-05-MEJ03b-verti.png`, `r51b-06-MEJ03b-detalle-verti.png` |
| MEJ-04 sin documentación | 15789197 (2002300088767) | JJGONZ2 | Alta NO VOY A COMPRARME OTRO COCHE → Acción Administrativa → «no entrega documentación» → FINALIZAR | **OK**: «¿Desea continuar?» / «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento». ACEPTAR → CORRECTO → NSE con fecha de vencimiento 07/04/2027 (sin ANULAR) | `r51b-07-MEJ04a-sin-documentacion.png`, `r51b-08-MEJ04a-nse-vencimiento.png` |
| MEJ-04 sin compra/venta sin traspaso | 15789200 (2001900034165) | JJGONZ2 | Misma causa → DNI + justificante de gestoría, sin tipo 9 → FINALIZAR | **OK**: «Al no adjuntar la documento de compra/venta sin traspaso del seguro, la póliza se anulará al vencimiento». ACEPTAR → NSE con vencimiento 05/01/2027 (sin ANULAR) | `r51b-09-MEJ04b-sin-compraventa.png`, `r51b-10-MEJ04b-nse-vencimiento.png` |
| MEJ-04 regresión (todo entregado) | 15789201 (2002200338520) | JJGONZ2 | Misma causa → DNI + tipo 9 → FINALIZAR | **OK**: «Se va a finalizar la revisión de acciones administrativas». Se canceló y se POSPUSO; queda pendiente | `r51b-11-MEJ04c-generico.png` |

Observación (no es de esta ronda): justo después de la CA nivel 1 negativa, el Detalle de JJGONZ2 mostró un rato dos CA nivel 1 incompletas. Al volver a entrar con SISANS ya estaba bien: CA1 finalizada negativa y CA2 nivel 2. Parece un estado de lectura transitorio. El listado enseña «Solicitud Finalizada sin anular» con la mecanización pendiente; es la etiqueta HU3980 de siempre.


## 4. Comparación con SCA

| Mensaje | SCA (lectura del objeto / pruebas anteriores) | SCA2 ahora | Veredicto |
|---|---|---|---|
| MEJ-05 | «…generar la solicitud de anulación…» (popup de simulación, igual que SCA2 antes; R48-A §3) | «…generar la solicitud de contra anulación…» | Diferencia a propósito (decisión de negocio). |
| MEJ-06 | `SCA_ContraAnulacionOpcionesEstrategicas` v12 enseña a todos «Esta poliza es de un acuerdo que trata SI24. La retención o anulación de la póliza se trasladara al SI24» (R49-C OBS-01). | Red Mapfre nivel 1: literal nuevo. Los demás: el texto de SCA. | El texto de Red Mapfre ya era propio de SCA2 (R9-C); ahora es el validado. |
| MEJ-03 | SCA no tiene esta pantalla con la siguiente tarea: después de la CA vuelve al buscador (R29-A). La tarjeta CORRECTO con la siguiente tarea es de SCA2 (R29-A/R45-C). | Literales nuevos. | Sin equivalente en SCA. |
| MEJ-04 | `SCA_AccionesAdministrativasPrincipal`: `confirmMessage` «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» solo si la causa es NO VOY A COMPRARME OTRO COCHE / SEGURO REGALADO POR LA COMPRA DE COCHE sin documento tipo 9. En otro caso, vacío (y también con «no entrega documentación» y otra causa). | Dos textos según la causa; con «no entrega documentación», siempre el de «documentación requerida». | Diferencia a propósito (decisión de negocio). |

## 5. Lo que no se ha probado

- **Regresión de la redirección directa** (siguiente tarea propia o Verti sin asignar → «Se va a redirigir a la siguiente tarea…»): no se pudo hacer. El alta de 2002200349694 falló dos veces al guardar con `Could not access remote service … ITarifaNseExport1` (NSE), y antes el servicio de pólizas estuvo unos 10-20 min respondiendo «La póliza no es una póliza válida o no se encuentra disponible» también en SCA (`r51b-12-regresion-error-nse.png`). Revisión del código: `local!sigEnDetalle` es exactamente la condición contraria a la redirección, así que en ese caso `msgGuardadoSiguiente` queda vacío y la pantalla sale como en v44.
- MEJ-06: no se ha hecho la retención positiva de punta a punta (solo el aviso y la vía negativa). El flujo no ha cambiado.
- Comparación en pantalla con SCA: no se hizo por la caída. Se ha comparado leyendo los objetos de SCA (§4).
- MEJ-04c: no se ha completado FINALIZAR (se pospuso para no perder la documentación). Se mantiene como antes.


## 6. Dudas

1. **Erratas en los literales (no corregidas, se han puesto tal cual):**
   - MEJ-04: «Al no adjuntar **la documento** de compra/venta…». Propuesta: «Al no adjuntar **el documento** de compra/venta sin traspaso del seguro, la póliza se anulará al vencimiento».
   - MEJ-03 Verti: el literal venía con un espacio delante (« Los datos se han guardado correctamente.»). Se ha quitado el espacio inicial porque es del entrecomillado. MEJ-06 llegó en el informe R49 con un espacio antes del punto en el texto antiguo; el nuevo no lo tiene.
   - MEJ-03, MEJ-05 y MEJ-06 no terminan en punto (como en la respuesta de negocio). Propuesta: añadir el punto final.
   - Mayúsculas: «Acuerdo Especial» y «Nivel 2» van en mayúscula en el literal. Se han dejado así.
2. **MEJ-03 Contra Anular Nivel 2:** el texto dice siempre que «salta al SI24». En las pruebas la CA nivel 2 va al grupo GGE EXPERTOS SI24. ¿Hay algún caso en que la CA nivel 2 no la gestione SI24 (por ejemplo otra red)? Si lo hay, propuesta: usar el texto nuevo solo cuando el grupo de la tarea sea de SI24 y dejar el genérico en el resto.
3. **MEJ-03 Verti/vencimiento:** la pantalla se mantiene con «Los datos se han guardado correctamente.» (motivo en §1). Si negocio quiere quitarla de verdad, la propuesta es que FINALIZAR, cuando la siguiente gestión no se pueda abrir, vuelva directamente al Detalle sin la tarjeta CORRECTO. Eso es reestructurar `SCA2_DetalleSolicitud`/`SCA2_DetalleTareas` y la espera asíncrona, y habría que repetir la regresión de todas las acciones.
4. **MEJ-04:** con «no entrega documentación» y una causa que no exige contrato, antes salía «Se va a finalizar la revisión de acciones administrativas» (SCA, vacío). Ahora sale «Al no adjuntar la documentación requerida…», que es lo que dice negocio y además es lo que pasa (se anula al vencimiento). Se confirma como intencionado.
5. **MEJ-06:** el texto nuevo coincide con la pantalla (no hay bloqueo). Solo queda la duda de mayúsculas del punto 1.
