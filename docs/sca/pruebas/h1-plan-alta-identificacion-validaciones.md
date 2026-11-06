# H1 — Plan oficial «Alta» (hoja `manual_test`, 39 casos): SCA frente a SCA2 en TEST

Ronda 8 (planes de prueba del analista). Sesión H1. Fecha de ejecución: 13/10/2026. Entorno: Appian TEST (`mapfrespain-test`), sites `sca-site` (SCA, referencia funcional) y `sca2` (SCA2). Plan ejecutado: `docs/sca/pruebas/planes/alta.md`, hoja `manual_test` (los casos de `manual_test_2` los ejecuta H2). Usuarios: JJGONZ2 (Red Mapfre / oficina) y SISANS (SI24 Experto). Pólizas asignadas: A `0000428646610`, B `0001047016997`, C `0001047017003` (wAutemis normales) y D `0005726674055` (RCI).

## Resumen

| Veredicto | Casos |
|---|---|
| OK igual | 8 (manual_test-1, 2, 5, 7, 8, 29, 30, 31) |
| DIVERGENCIA corregida | 0 |
| DIVERGENCIA pendiente | 1 (manual_test-6, presentación de obligatorios) |
| NO PROBADO | 30 (datos/perfiles inexistentes en TEST, pólizas consumidas o comparación SCA no concluyente) |

- **No se ha dejado ningún cambio en SCA2.** El único PUT de la sesión (`SCA2_AltaSolicitudPage`, validación residual de fax) se revirtió a los pocos minutos al comprobar que SCA tiene el mismo comportamiento (ver «Divergencias corregidas / revertidas»).
- Las validaciones de GUARDAR (regla `SCA2_erroresGuardarSolicitud`) son idénticas a las de SCA (`SCA_erroresGuardarSolicitud`) salvo formato: se verificó por comparación de SAIL y con `POST /expression-rules/{uuid}/test` (causa Ilocalizado con canal 1/5/9 devuelve los mismos textos).
- Las dos altas reales de SCA2 (Contra Anulación con póliza C y Autorización con póliza D) se crearon correctamente en CORE, redirigieron a la pantalla esperada (Contra anulación / Revisión autorización de fecha de anulación) y son visibles en el buscador de SCA.
- Hallazgo sobre SCA (referencia): en TEST, con estas pólizas, el botón GUARDAR de SCA **crea el alta directamente**, sin popup de simulación previo. Dos pólizas (A y B) quedaron consumidas por altas en SCA no previstas (una por un GUARDAR implícito con la tecla Return en un desplegable; otra al pulsar GUARDAR esperando el popup de simulación), lo que redujo la cobertura comparativa de los casos 3, 11, 12, 13, 14 y 18.

## Tabla de los 39 casos

`ss_xxx` = captura nativa del agente de pruebas; `comparacion-*` = composición SCA (izquierda) / SCA2 (derecha). Las capturas se adjuntan al mensaje final de la sesión (no se suben al repo).

| ID | Nombre | Resultado SCA observado | Resultado SCA2 observado | Veredicto y alcance | Evidencia |
|---|---|---|---|---|---|
| manual_test-1 | Motivo Detalle Causa | Dependencias cargan: Decisión de cliente → Precio → Me ha subido mucho la prima; Decisión de la entidad → Decisión de la entidad → Anulación fuera de norma; Ilocalizado disponible | Mismas combinaciones recorridas; carga las catalogaciones al elegir causa | **OK igual** — para combinaciones recorridas; no barrido exhaustivo de todas las combinaciones activas | comparacion-causas; ss_45fa08e8; ss_598aff7e; ss_38f1cc8c; ss_cdb89520 |
| manual_test-2 | Catalogaciones | Anulación fuera de norma → A FECHA editable; Precio permite catalogaciones según póliza; B quedó A EFECTO 15/01/2026 | Anulación fuera de norma → A FECHA editable; C Precio quedó A VENCIMIENTO 22/01/2027 con fecha deshabilitada | **OK igual** — para comportamiento observado de A FECHA / A VENCIMIENTO; no todas las catalogaciones y sin equivalencia de defaults B/C | comparacion-catalogacion; ss_ce762651; ss_a27c8829; ss_c1d8929f |
| manual_test-3 | Compañía aseguradora | C muestra ALLIANZ-RAS,S.A. en cabecera y Contra Anulacion Incompleta; no se realizó un alta propia SCA con compañía contraria | Lupa seleccionó 1109 ALLIANZ-RAS,S.A.; persistió en Contra anulación y cabecera C | **NO PROBADO** — comparativo completo: persistencia demostrada SCA2 y consulta cruzada SCA, no guardado propio SCA con compañía | comparacion-c-detalle; ss_9f57f62a; ss_c1d8929f |
| manual_test-4 | Canal de Entrada | JJGONZ2: PRESENCIAL. SISANS: popup A bloqueado; no formulario | JJGONZ2: PRESENCIAL. SISANS: mismo bloqueo | **NO PROBADO** — completo: OK igual Red Mapfre; no SI24 ni restantes perfiles/impagado | comparacion-alta-inicial; comparacion-bloqueo-sisans |
| manual_test-5 | Medios de comunicación | Correspondencia habilita medio/Fax obligatorio; formato inválido muestra «El formato del fax es incorrecto»; error residual al cambiar canal | Mismo error de formato y residual al pasar a Presencial | **OK igual** — mismo comportamiento en ambas (error residual de fax al cambiar canal; posible mejora) | comparacion-fax-residual; ss_d98b9d3e; ss_d181f33f |
| manual_test-6 | Campos obligatorios | Presentación de GUARDAR habilitado en estados incompletos y avisos de campos/validación | GUARDAR deshabilitado si faltan obligatorios, tooltip «Revise los parámetros obligatorios del formulario.» | **DIVERGENCIA pendiente** — NO PROBADO barrido de cada obligatorio vacío | comparacion-alta-inicial; ss_30b3b958; ss_da69eadb |
| manual_test-7 | Cancelación | Confirmación de pérdida de datos, botones NO/SÍ; salida al buscador | Misma confirmación y salida al buscador | **OK igual** — para cancelación del formulario sin alta | comparacion-cancelar; ss_95b4c722 |
| manual_test-8 | Cabecera wAutemis | Cabecera A/B cargada; solicitud PENDIENTE, NIVEL 1; detalles cruzados consultables | Cabeceras A/C/D cargadas; C conserva compañía, catalogación, fecha y causa; D autorización pendiente | **OK igual** — para cabeceras y consulta cruzada observadas; no igualdad de datos entre pólizas distintas | comparacion-alta-inicial; comparacion-b-solo-consulta; comparacion-d-detalle; ss_c1d8929f |
| manual_test-9 | Cabecera NSE Autos | No ejecutado | No ejecutado | **NO PROBADO** — solo pólizas wAutemis asignadas; prohibido usar otras | — |
| manual_test-10 | Cabecera NSE Hogar | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza NSE Hogar asignada | — |
| manual_test-11 | Guardar Contra Anulación | B → 15787892 pendiente; no popup previo observado; destino original no demostrado; detalle solo Alta Finalizada | C → 15787896 pendiente; destino Contra anulación tras ~100 s; compañía Allianz conservada; sin aviso post-alta visible | **NO PROBADO** — comparativo completo: alta/destino SCA2 comprobados, aviso/destino SCA inconclusos; catalogaciones B/C distintas | comparacion-b-solo-consulta; ss_7446523a; ss_9f57f62a; ss_c1d8929f |
| manual_test-12 | Guardar Acción Administrativa | Solo recorrido de combinación; sin guardar | Solo recorrido de combinación; sin guardar | **NO PROBADO** — reasignación final consumió C/D; ninguna póliza libre para AA | — |
| manual_test-13 | AA: mensajes y cancelación | No se alcanzó pantalla AA | No se alcanzó pantalla AA | **NO PROBADO** — sin alta AA; documentos y CANCELAR de destino no verificados | — |
| manual_test-14 | Guardar Autorización | A → 15787883 pendiente, FUERA NORMA, A FECHA; alta implícita, aviso/destino no observados; solo Alta Finalizada en detalle | D → 15787900 pendiente, A FECHA 13/10/2026; destino «Revisión autorización de fecha de anulación»; Autorizacion pendiente; sin modal post-alta visible | **NO PROBADO** — comparativo completo: creación/destino SCA2 sí; destino original SCA no verificable. Diferencia de gestiones documentada sin atribución causal | comparacion-autorizacion; comparacion-d-detalle; ss_58c30b99 |
| manual_test-15 | Mecanización directa | No ejecutado | No ejecutado | **NO PROBADO** — sin perfil/póliza apta o flota asignada; no se pulsa ANULAR PÓLIZA | — |
| manual_test-16 | Fecha y último siniestro | A mostró siniestro año actual 0 y último siniestro «-» | Misma falta de siniestro; se observó bloqueo adicional de fecha de hace >18 meses, no sustituye este caso | **NO PROBADO** — no póliza con siniestro en anualidad. No se confunde antigüedad >18 meses con fecha anterior a último siniestro | ss_43b248f9 |
| manual_test-17 | Exención CCC/CCR (siniestro) | No ejecutado | No ejecutado | **NO PROBADO** — sin usuario CCC/CCR ni póliza con siniestro asignados | — |
| manual_test-18 | Fecha posterior a vencimiento | Se introdujo 20/07/2029 en A (vencimiento 19/07/2029), pero fax residual y alta implícita impiden evidencia concluyente del mensaje específico SCA | Se observó «La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.»; bloqueo | **NO PROBADO** — comparativo completo: validación observada SCA2, texto/bloqueo SCA no demostrado con evidencia concluyente | ss_65aa2a5a; ss_6c6d447e |
| manual_test-19 | Exención CCC/CCR (vencimiento) | No ejecutado | No ejecutado | **NO PROBADO** — sin usuario CCC/CCR | — |
| manual_test-20 | MásMóvil | No ejecutado | No ejecutado | **NO PROBADO** — ninguna póliza MásMóvil autorizada | — |
| manual_test-21 | Paso experto No | SISANS: popup bloqueado por solicitud pendiente | Mismo bloqueo | **NO PROBADO** — sin póliza libre susceptible; SISANS es SI24 Experto, no Información general | comparacion-bloqueo-sisans |
| manual_test-22 | Paso experto Sí | SISANS: popup bloqueado por solicitud pendiente | Mismo bloqueo | **NO PROBADO** — no se alcanzó modal ni teléfono ni valor anula_expertos; perfil distinto al requerido | comparacion-bloqueo-sisans |
| manual_test-23 | AA telemática telefónica No | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza de origen telemática telefónica autorizada | — |
| manual_test-24 | AA telemática telefónica Sí | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza de origen telemática telefónica autorizada | — |
| manual_test-25 | AA Ibericar No | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza Ibericar/corredor asignada | — |
| manual_test-26 | AA Ibericar Sí | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza Ibericar/corredor asignada | — |
| manual_test-27 | Contra Anulación CCC No | No ejecutado | No ejecutado | **NO PROBADO** — sin usuario CCC ni póliza libre | — |
| manual_test-28 | Contra Anulación CCC Sí | No ejecutado | No ejecutado | **NO PROBADO** — sin usuario CCC ni póliza libre | — |
| manual_test-29 | Ilocalizado Red Mapfre no correspondencia | Selección solo con ratón: sin alerta antes de GUARDAR; tras GUARDAR texto de solicitud presencial y bloqueo | Alerta solo tras GUARDAR y bloqueo con mismo texto | **OK igual** — ambas avisan al GUARDAR, no al seleccionar; diferencia compartida respecto al momento descrito por el plan | comparacion-ilocalizado |
| manual_test-30 | Ilocalizado Red Mapfre correspondencia | Correspondencia/Carta + GUARDAR bloquea con aviso de carta/argumentos; no simulación ni alta | Mismo aviso bloqueante; sin alta | **OK igual** — texto y bloqueo; no mera confirmación para continuar | comparacion-ilocalizado-carta |
| manual_test-31 | Ilocalizado no correspondencia ni área clientes | Presencial: bloquea tras GUARDAR | Presencial: bloquea tras GUARDAR | **OK igual** — para Presencial; otros canales no barridos | comparacion-ilocalizado |
| manual_test-32 | SI24 corredor/banca misma anualidad | SISANS: popup bloqueado por solicitud pendiente | Mismo bloqueo | **NO PROBADO** — no formulario ni solicitud previa resuelta/póliza libre de corredor o banca | comparacion-bloqueo-sisans |
| manual_test-33 | Simulación New M201 no continúa | No ejecutado con M201 reproducible | No ejecutado con M201 reproducible | **NO PROBADO** — no dato de operación pendiente M201 autorizado; no se inyectó error | — |
| manual_test-34 | Simulación NSE no continúa | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza NSE con error/null/SQL reproducible | — |
| manual_test-35 | Simulación New M206 continúa | No se observó popup M206 en las altas propias | No se observó popup M206 | **NO PROBADO** — sin dato que fuerce M206; ausencia en alta normal no verifica este caso | — |
| manual_test-36 | Simulación NSE continúa | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza NSE con error controlado | — |
| manual_test-37 | PRRA NSE Autos | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza PRRA NSE Autos | — |
| manual_test-38 | PRRA NSE Hogar | No ejecutado | No ejecutado | **NO PROBADO** — sin póliza PRRA NSE Hogar; finalización anulando prohibida | — |
| manual_test-39 | Error al vuelo | No ejecutado | No ejecutado | **NO PROBADO** — no fallo controlado preparado y prohibido modificar objetos de diseño | — |

## Solicitudes creadas en esta ronda

| Póliza | App que creó el alta | Solicitud CORE | Pantalla tras el alta | Buscador SCA | Buscador SCA2 |
|---|---|---|---|---|---|
| A `0000428646610` | SCA (alta implícita, tecla Return en desplegable durante los casos 1/2) | 15787883 | No observada | Pendiente | Pendiente, «Otras solicitudes… (SCA e históricas en CORE, sin gestión en SCA2)» |
| B `0001047016997` | SCA (GUARDAR de referencia; SCA creó el alta directamente sin popup de simulación) | 15787892 | No observada (latencia) | Pendiente | Pendiente, «Otras solicitudes…» |
| C `0001047017003` | SCA2 (caso 11 + 3 + 8) | 15787896 | Contra anulación (tras ~100 s) | Pendiente | Pendiente, Contra anulación incompleta |
| D `0005726674055` (RCI) | SCA2 (caso 14) | 15787900 | Revisión autorización de fecha de anulación | Pendiente | Pendiente, Autorización pendiente |

No se ejecutó ninguna acción sobre estas solicitudes (ni POSITIVO/NEGATIVO/FINALIZAR, ni ANULAR PÓLIZA, ni documentación). Quedan abiertas en CORE para rondas posteriores.

## Estados CORE observados (LCP, `SCA2_consultaGestion` / `SCA2_consultarCabeceraSolicitud`)

| Solicitud | Póliza | App alta | Fecha alta (TEST) | Motivo/Detalle/Causa | Catalogación · fecha anulación | estadoSolicitud (cabecera) | Gestiones (consultaGestion) |
|---|---|---|---|---|---|---|---|
| 15787883 | 0000428646610 (A) | SCA (alta implícita por tecla Return durante caso 1/2) | 13/10/2026 12:27:18 | 4/9/28 Anulación fuera de norma | 4 (A FECHA) · 13/10/2026 | 2 | 43705407 acc. 8 (Alta) FINALIZADA, nivel 1 |
| 15787892 | 0001047016997 (B) | SCA (GUARDAR de referencia: en SCA GUARDAR crea el alta directamente, sin popup de simulación) | 13/10/2026 12:37:42 | 1/1/1 Me ha subido mucho la prima | 1 (A EFECTO) · 15/01/2026, origen 1 (IMPAGO) | 2 | 43705423 acc. 8 FINALIZADA, nivel 1 |
| 15787896 | 0001047017003 (C) | SCA2 (caso 11+3+8) | 13/10/2026 12:45:20 | 1/1/1 Me ha subido mucho la prima, cía. contraria 1109 Allianz | 2 (A VENCIMIENTO) · 22/01/2027, origen 2 | 10 | 43705431 acc. 8 FINALIZADA + acc. 2 (Contra anulación) INCOMPLETA 12:45:37 (abierta por la redirección automática), nivel 1 |
| 15787900 | 0005726674055 (D, RCI) | SCA2 (caso 14) | 13/10/2026 12:51:12 | 4/9/28 Anulación fuera de norma | 4 (A FECHA) · 13/10/2026 | 13 | 43705438 acc. 8 FINALIZADA + acc. 7 (Autorización) 12:51:28, nivel 1 |

Observación: en SCA2 la redirección automática tras el alta abre ya la gestión siguiente (acción 2 Contra anulación INCOMPLETA en C; acción 7 Autorización en D), de modo que la cabecera CORE pasa a estado 10/13. En las altas de SCA (A, B) la cabecera queda en estado 2 con una única gestión de alta FINALIZADA porque el usuario no llegó a navegar a la gestión. Es coherente con la navegación directa al detalle/gestión acordada en rondas anteriores (doc 21); no se considera divergencia.

## Divergencias corregidas / revertidas

| Objeto | UUID | Versiones | Cambio | Resultado |
|---|---|---|---|---|
| `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v25 → v26 → **v27** (v27 idéntica a v25) | v26: al cambiar el canal de entrada se limpiaba también el número de fax y la validación «El formato del fax es incorrecto» solo se evaluaba con medio Fax (caso manual_test-5). | **Revertido** en v27: la prueba comparativa demostró que SCA muestra el mismo error residual (`comparacion-fax-residual.png`), luego no es una divergencia exclusiva de SCA2. Sin cambio neto. Registrado en `coordinacion-ronda8.md`. |

Ningún otro objeto de SCA2 ha sido modificado. No se ha tocado ningún objeto de SCA, SCAC, CORE, GAIA, PRE ni Documentum.

## Divergencias pendientes (con pregunta funcional)

| # | Caso | Qué ocurre | Pregunta para el analista |
|---|---|---|---|
| P1 | manual_test-6 | SCA2 deshabilita el botón GUARDAR mientras falten campos obligatorios y muestra el tooltip «Revise los parámetros obligatorios del formulario.»; SCA deja el botón habilitado y avisa al pulsarlo. El resultado funcional es el mismo (no se guarda), cambia la presentación. | ¿Se acepta que en SCA2 el botón GUARDAR esté deshabilitado hasta completar los obligatorios, o se quiere el comportamiento de SCA (botón activo y mensajes de campo obligatorio al pulsarlo)? |
| P2 | manual_test-5 (ambas apps) | Al rellenar Correspondencia → Fax → número y cambiar después el canal a Presencial, el campo de fax queda deshabilitado pero con el error «El formato del fax es incorrecto» visible, tanto en SCA como en SCA2. | ¿Se desea corregir en SCA2 (limpiar el fax al cambiar de canal) aunque SCA tenga el mismo defecto? Si sí, la corrección ya está preparada y probada (v26). |
| P3 | manual_test-11 / 14 | Tras GUARDAR, SCA2 no muestra ningún mensaje de confirmación de alta: redirige directamente a la gestión (Contra anulación / Autorización). El plan describe un aviso de alta previo a la redirección; en SCA no se pudo observar por latencia/alta implícita. | ¿Debe SCA2 mostrar un mensaje de confirmación («Se ha dado de alta la solicitud…») antes de abrir la gestión, o basta con la redirección directa? |
| P4 | manual_test-29 / 31 | El plan indica que la alerta de Ilocalizado aparece al seleccionar la causa; en SCA y en SCA2 aparece al pulsar GUARDAR (misma regla, mismo texto). En una ejecución de SCA el agente vio la alerta sin pulsar GUARDAR (`ss_93ce672c`), no reproducido en la repetición final; en el SAIL de SCA la regla solo se evalúa en GUARDAR. | ¿Es aceptable que el aviso de Ilocalizado aparezca solo al pulsar GUARDAR (como hoy en ambas) o debe anticiparse al elegir la causa? |
| P5 | manual_test-30 | Con Ilocalizado + Correspondencia/Carta, el texto «Si das de alta la solicitud con estos datos, no podrás imprimir la carta…» **bloquea** el alta en ambas apps (la regla lo devuelve como error). El plan lo describe como aviso que permite continuar. | ¿El aviso de la carta de oposición debe bloquear el alta (comportamiento actual de SCA y SCA2) o solo informar y dejar guardar? |

Ninguna de ellas se ha corregido: P1 y P3 son decisiones de presentación/flujo ya presentes en SCA2 desde rondas anteriores; P2, P4 y P5 ocurren igual en SCA (referencia), por lo que, según el criterio de la ronda, se documentan y no se corrigen. La simulación previa al alta y la detección PRRA siguen siendo dudas abiertas del doc 22 (A1–A3) y no se han tocado.

## Limitaciones

- **Pólizas consumidas en SCA**: A (15787883) y B (15787892) se dieron de alta en SCA sin intención. Causa raíz: en SCA el botón GUARDAR (`submit: true`) crea el alta directamente en TEST (no apareció el popup de simulación que el plan y el SAIL contemplan), y la tecla Return en un desplegable dispara el botón submit del formulario. Consecuencia: no hubo póliza para el alta de Acción Administrativa (casos 12/13), ni para comparar destino/aviso de SCA en 11/14, ni para repetir el caso 18 en SCA con evidencia limpia.
- **Perfiles y datos inexistentes en TEST** para esta sesión: NSE Autos/Hogar, PRRA, MásMóvil, telemática telefónica, Ibericar, subperfiles CCC/CCR, SI24 Información general, póliza con siniestro en la anualidad, solicitud previa resuelta en la misma anualidad, errores controlados M201/M206/NSE y «error al vuelo» (requeriría provocar un fallo en Appian, prohibido). Todos marcados NO PROBADO.
- **SISANS** (SI24 Experto) no pudo abrir el formulario de alta: todas las pólizas asignadas ya tenían solicitud abierta cuando se cambió de usuario; ambas apps bloquean con el mismo texto («La póliza tiene pendiente una solicitud en SCA…»); SCA ofrece «SALIR DE APPIAN» y SCA2 mantiene la pantalla de alta (diferencia menor de botones del popup, no evaluada por el plan).
- **Latencia de SCA**: el alta de C en SCA2 tardó ~100 s en redirigir; en SCA la flecha «volver» desde el detalle produce un error de expresión propio de SCA (`sca_datoscabecera`, `a!submitLink`, «The save target must be a local variable…»), ya conocido (doc 21) y no corregible desde SCA2.
- **Comprobación previa de solicitudes abiertas**: `SCA2_consultarSolicitudes(numPoliza, codInt:"", tpBusqueda:"0")` devolvió `null` para las cuatro pólizas al inicio y devolvió correctamente las solicitudes nuevas después, así que la comprobación es fiable.
- `POST /interfaces/{uuid}/test` devolvió 400 sin cuerpo para `SCA2_AltaSolicitudPage` (inputs `numPoliza`/`vista`); la validación de la interfaz se hizo por UI.
- El agente de pruebas no pudo garantizar barridos exhaustivos de todas las combinaciones motivo/detalle/causa ni de todas las catalogaciones: los OK de los casos 1 y 2 se limitan a las combinaciones recorridas.

## Textos de mensajes recogidos

| Situación | Texto exacto | Aplicación / alcance |
|---|---|---|
| Fax | `El formato del fax es incorrecto` | Ambas, incluyendo residual al cambiar canal |
| Campos incompletos | `Revise los parámetros obligatorios del formulario.` | Tooltip GUARDAR SCA2; no se atribuye este texto a SCA |
| Fecha/catalogación | `Verifica la correcta catalogación de la fecha de anulación.` | Ambas |
| Cancelar | `Si sale de esta pantalla sin guardar los datos se perderán. ¿Desea salir de todos modos?` | Ambas; botones NO / SÍ |
| Fecha posterior a vencimiento | `Se han detectado los siguientes errores: La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.` | Observado SCA2; comparación SCA incompleta |
| Antigüedad de fecha >18 meses | `Se han detectado los siguientes errores: La fecha de anulación no puede ser más antigua de los 18 meses anteriores a la fecha de hoy.` | Observado SCA2; no sustituye caso de último siniestro |
| Ilocalizado/Presencial | `Se han detectado los siguientes errores: No es posible dar de alta una solicitud presencial con este medio de comunicación. Por favor modifique el medio de comunicación.` | Ambas tras GUARDAR |
| Ilocalizado/Correspondencia/Carta | `Se han detectado los siguientes errores: Si das de alta la solicitud con estos datos, no podrás imprimir la carta de oposición a la renovación para entregar al cliente, ni tendrás acceso a los argumentos.` | Ambas tras GUARDAR; bloquea |
| Póliza pendiente | `La póliza tiene pendiente una solicitud en SCA, por lo que no es posible dar de alta una nueva. Por favor, retome la solicitud abierta, para finalizarla` | Ambas con SISANS |
| Consulta de solicitud SCA en SCA2 | `Solicitud gestionada en SCA o histórica: datos de CORE, sólo consulta` | SCA2 A/B |
| Falta de búsqueda | `Completa al menos uno de los campos marcados *` | Buscador |
| Búsqueda vacía | `No hay resultados para dicha búsqueda` | Ambas en búsquedas libres; no indica ausencia CORE si existe tabla secundaria |
| Aviso tras alta C/D | Ninguno visible observado | SCA2: no se inventa el modal que esperaba el plan |
| Error al volver en SCA | `Ha ocurrido un error` / `Expression evaluation error: The save target must be a local variable that does not refresh on every evaluation or on an interval, a process variable, or a node input (or a rule input passed one of those three), but instead was: 0000428646610` | SCA, regla `sca_datoscabecera`, función `a!submitLink`, línea 23; captura contiene mensaje completo y evaluation ID |

No se han copiado como «observados» los mensajes M201/M206/NSE del plan: no se reprodujeron.

## Grabación y evidencia visual

- Grabación anotada única: `h1-alta-sca-vs-sca2-final` (`h1-alta-sca-vs-sca2-final-edited.mp4`, adjunta al mensaje final de la sesión).
- Composiciones SCA (izq.) / SCA2 (der.): `comparacion-alta-inicial.png`, `comparacion-causas.png`, `comparacion-catalogacion.png`, `comparacion-fax-residual.png`, `comparacion-cancelar.png`, `comparacion-ilocalizado.png`, `comparacion-ilocalizado-carta.png`, `comparacion-autorizacion.png`, `comparacion-b-solo-consulta.png`, `comparacion-bloqueo-sisans.png`, `comparacion-c-detalle.png`, `comparacion-d-detalle.png`.
- Capturas individuales relevantes: `ss_9f57f62a.png` (destino Contra anulación tras alta C), `ss_c1d8929f.png` (cabecera C con Allianz), `ss_58c30b99.png` (destino Autorización tras alta D), `ss_12aa374c.png` (error de SCA al volver), `ss_65aa2a5a.png` / `ss_6c6d447e.png` (validaciones de fecha SCA2).
- Backups SAIL antes/después de la versión revertida: locales (`~/sca2work/h1/SCA2_AltaSolicitudPage_pre_fax.*`, `_post_fax.*`, `_revert_fax.json`), no en el repo.

## Qué haría falta para completar el plan

Pólizas libres adicionales (al menos 2 normales para Acción Administrativa y para repetir Contra Anulación/Autorización en SCA con observación del destino; 1 para el caso 18 en SCA), usuarios con perfiles CCC/CCR y SI24 Información general, y pólizas NSE Autos/Hogar, PRRA, MásMóvil, telemática e Ibericar en TEST.
