# R49-C — Validaciones del alta frente a SCA (INC-01, INC-02, INC-03, OBS-01, OBS-03)

Fecha: 16/11/2026. Entorno: Appian TEST, site `/suite/sites/sca2`; referencia SCA `/suite/sites/sca-site`. Usuario de las pruebas UI: JJGONZ2 (Red Mapfre, perfil CE_RM). Solo se ha modificado SCA2. No se ha ejecutado DDL/DML, no se han tocado solicitudes antiguas y no se ha anulado ninguna póliza en CORE. No se ha cambiado ningún texto de mensaje.

Skill `appian`: no aparece como skill de Devin en la sesión; se ha seguido la copia del bundle del MCP (`~/appian-dev-mcp-server/skills/appian/SKILL.md`).

## Resumen

| Apartado | ¿SCA2 igual que SCA? | Resultado |
|---|---|---|
| INC-01 Vida 4004 | No comprobable con altas nuevas | SCA rechaza Vida en el popup inicial («La póliza no es una póliza válida…»): no hay `solicitudAnulacionDTO` de SCA con el que comparar. Las dos pólizas Vida tienen solicitud en curso en SCA2, así que no se ha creado ninguna Vida. Sin cambios. |
| INC-02 732400122940 | Sí (salvo relleno visual) | La póliza real es 0732400122940. Sin el cero, CORE responde «20001 CODIGO INEXISTENTE» (de ahí el mensaje de póliza no válida). Ambas apps completan con ceros al consultar; SCA2 además lo muestra en el campo. Sin cambios. |
| INC-03 póliza renovada | **No → corregido** | SCA muestra el aviso de renovada pero deja grabar si la simulación permite avanzar («fecha fuera de la situación actual»). SCA2 se quedaba siempre en el error. `SCA2_AltaSolicitudPage` v55→v56. Probado con solicitud nueva 15789148. |
| OBS-01 acuerdo SI24 | Igual en comportamiento; texto distinto | Ninguna de las dos muestra aviso en el alta; las dos lo muestran en la contra anulación nivel 1 con los mismos botones. El texto de SCA2 para Red Mapfre nivel 1 es otro (decidido en R9-C, provisional). Sin cambios (textos en revisión por negocio). Duda D2. |
| OBS-03 flota / wAutemis | Igual en código; no comprobable en UI | Mismo aviso y misma condición (acuerdo 20/33/35) en las dos apps; el aviso solo informa y ACEPTAR graba. Ninguna de las dos abre wAutemis desde el alta. La póliza y las alternativas tienen solicitud en curso. Sin cambios. |

## Solicitudes nuevas creadas (ninguna avanzada)

| App | Solicitud | Póliza | Para qué |
|---|---|---|---|
| SCA | 15789140 | 2002500484784 | INC-03: SCA graba pese al aviso de renovada (A FECHA 12/11/2026) |
| SCA | 15789143 | 0730080000252 | INC-03: ídem en hogar (A FECHA 11/11/2026) |
| SCA2 | 15789148 | 0730080003931 | INC-03: prueba de v56 (A FECHA 11/11/2026) |
| SCA2 | 15789150 | 0002729325315 (GRUPO VW CARTERA) | OBS-01: aviso SI24 en contra anulación |
| SCA | 15789152 | 0002729325313 (GRUPO VW FINANCIADO 1 AÑO) | OBS-01: aviso SI24 en contra anulación |

Todas quedan en Solicitud Pendiente, nivel 1, sin ejecutar argumentos ni decisiones. Los números de instancia no se ven en la UI del usuario funcional.

## INC-01 — Vida 0006000283 / 0006000495 (generarStudAnul, 4004)

- **SCA2**: las dos pólizas tienen ya solicitud en curso («Existe una solicitud en curso para la póliza indicada. ¿Quiere consultar la solicitud?»). No se han retomado. No hay otra póliza Vida candidata y el encargo limita las altas Vida, así que no se ha creado ninguna.
- **SCA**: con 0006000283, el popup del alta rechaza la póliza antes del formulario: «La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.» (captura `capturas-r49/r49c-SCA_INC01_vida_rechazada.png`).
- **Causa**: el 4004 es el ya documentado en `42-estado-sca2-ronda23.md` y `r43-a-poliza-vida-cabecera-motivos.md` (CORE devuelve «Datos insuficientes» en `generarStudAnul`; ya se probó `codCiaUsuario` 3). SCA no llega nunca a construir el `solicitudAnulacionDTO` de Vida, así que **no hay referencia SCA con la que comparar campo a campo**.
- **Cambio**: ninguno.
- **Duda D1**: ver abajo.

## INC-02 — 732400122940 / 0732400122940

- **Análisis en lectura**: `SCA2_obtenerTipoPoliza` y `SCA_obtenerTipoPoliza` dan «NSE-Hogar» para las dos variantes. `SCA2_pObtenerPolizaFecha` con 0732400122940 devuelve la póliza (producto 73 Hogar, estado «VIGENTE - PENDIENTE DE ANULACION», suplemento 4 de renovación, vencimiento 30/06/2027); con 732400122940 (12 cifras) CORE responde «20001 CODIGO INEXISTENTE», que es lo que se traduce en «La póliza no es una póliza válida o no se encuentra disponible…».
- **SCA2**: el popup del alta completa con ceros a 13 cifras al salir del campo (`SCA2_AltaSolicitudAnulacionPopUp` v12) y lo muestra: 732400122940 → 0732400122940.
- **SCA**: `SCA_AltaSolicitudAnulacionPopUpEstrategicas` v7 también completa a 13 cifras para las consultas, pero en el campo sigue mostrando 732400122940.
- **UI**: con las dos variantes, las dos apps encuentran la solicitud antigua 15789128 de esa póliza y no dejan dar de alta otra (SCA2: «Existe una solicitud en curso para la póliza indicada. ¿Quiere consultar la solicitud?»; SCA: «La póliza tiene pendiente una solicitud en SCA, por lo que no es posible dar de alta una nueva…»). Que con 12 cifras encuentren la solicitud confirma que las dos completan el número. Capturas `r49c-SCA_INC02_12_en_curso.png`, `r49c-SCA2_INC02_12_normalizada_en_curso.png`. La diferencia de texto ante solicitud en curso es la decidida en R46-C (botón CONSULTAR SOLICITUD).
- **Conclusión**: comportamiento esperado. El mensaje del analista sale si el número llega a CORE sin el cero; hoy no se reproduce desde el popup del alta de ninguna de las dos apps. La entrada por buscador la ha normalizado R49-B (`SCA2_Buscador` v37). La 15789128 no se ha tocado.
- **Cambio**: ninguno.

## INC-03 — Póliza renovada (2002500484784, 0730080000252)

- **Análisis en lectura**: `SCA2_polizaRenovada` v1 y `SCA_polizaRenovada` v4 dan `true` para las dos pólizas. El error «La póliza está renovada. Cancele el suplemento para poder retomar la solicitud de anulación.» se genera igual en `SCA2_erroresGuardarSolicitud` v3 y `SCA_erroresGuardarSolicitud` v7: póliza renovada y catalogación A FECHA (`"4"`).
- **SCA** (`SCA_AltaSolicitudAnulacionEstrategicas` v11 + `SCA_SimularAnulacionPopupEstrategicas` v3): si hay errores de guardado, al pulsar GUARDAR abre igualmente el popup de simulación. Si la simulación devuelve un error con `avanzarAltaSolicitud = true` sale ACEPTAR y graba. En el resto de casos los botones no envían (no graba).
- **SCA2** (`SCA2_AltaSolicitudPage` v55): con errores de guardado, mostraba el error al pie y no abría nunca la simulación. **Diferencia con SCA**.
- **Pruebas antes del cambio (mismos datos en las dos apps)**:
  - SCA, 2002500484784, DECISIÓN DE CLIENTE / VENTA DEL VEHÍCULO / NO VOY A COMPRARME OTRO COCHE, A FECHA 12/11/2026: aviso de renovada → GUARDAR → «La fecha de anulación está fuera de la situación actual de la póliza. Revise en NSE las situaciones de la póliza antes de poder anular a la fecha indicada.» → ACEPTAR → **15789140** creada. Con esta póliza no se pudo repetir en SCA2 porque la solicitud recién creada la bloquea.
  - SCA2, 0730080000252, DECISIÓN DE CLIENTE / VENTA/DESAPARICIÓN DEL RIESGO / VENTA SIN REEMPLAZO, A FECHA 11/11/2026: GUARDAR → error de renovada al pie, se queda en el formulario (`r49c-SCA2_INC03_hogar_bloqueo_renovada.png`).
  - SCA, misma póliza y datos: popup de fecha fuera de situación → ACEPTAR → **15789143** creada (`r49c-SCA_INC03_hogar_fecha_fuera_situacion.png`, `r49c-SCA_INC03_hogar_creada_15789143.png`).
- **Cambio** (`SCA2_AltaSolicitudPage`, UUID `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716`, **v55→v56**): en GUARDAR, con errores de guardado, si la simulación devuelve `errorSimularAlta = "true"` y `avanzarAltaSolicitud = true` se abre el popup de simulación (que ya solo muestra ACEPTAR en ese caso), como SCA. Si no, se mantiene el bloqueo con el error. Sin textos nuevos. Copias y diff: `backups-r49/R49-C_SCA2_AltaSolicitudPage_v55_antes.sail`, `_v56_despues.sail`, `_v55_v56.diff`. Antes de guardar se comprobó que la versión viva era la 55 de la copia (la reserva de R49-A ya estaba liberada); tras guardar se reexportó y coincide con lo enviado.
- **Pruebas después del cambio**:
  - SCA2 v56, 0730080003931 (otra póliza hogar renovada, libre), DECISIÓN DE CLIENTE / VENTA/DESAPARICIÓN DEL RIESGO / VENTA SIN REEMPLAZO, A FECHA 11/11/2026: GUARDAR → aviso de datos repetidos (Sí) → popup de fecha fuera de situación con VOLVER/ACEPTAR → ACEPTAR → **15789148**, Solicitud Pendiente, nivel 1, A FECHA 11/11/2026 (`r49c-SCA2_INC03_v56_fecha_fuera_situacion.png`, `r49c-SCA2_INC03_v56_solicitud_15789148.png`). Igual que SCA.
  - Regresión, 2002600073907 (no renovada), A FECHA 16/11/2026: GUARDAR abre la simulación normal («Se han completado todas las validaciones…»); CANCELAR vuelve al formulario sin grabar (`r49c-SCA2_INC03_v56_regresion_no_renovada_popup.png`).
  - No probado en UI: renovada con una simulación que no deja avanzar (sigue el camino anterior al cambio, que no se ha tocado). En el hogar, para esa causa solo se ofrece A FECHA, así que no se ha comparado otra catalogación.
- **Duda D3**: ver abajo.

## OBS-01 — Acuerdo especial SI24 (0005726696720, RCI)

- **Póliza del analista**: tiene solicitud en curso en las dos apps; no se ha retomado.
- **Análisis en lectura**: `SCA2_validacionesPreviasPopupAlta` y `SCA_validacionesPreviasPopupAlta` no avisan nada en el alta (`msg` nulo, `bloquear` falso). El aviso está en la contra anulación: `SCA_ContraAnulacionOpcionesEstrategicas` v12 muestra siempre «Esta poliza es de un acuerdo que trata SI24. La retención o anulación de la póliza se trasladara al SI24» (estilo WARN) cuando la póliza es de acuerdo SI24. `SCA2_ContraAnulacionOpciones` v79 usa la misma lista de acuerdos, pero para Red Mapfre (CE_RM) en nivel 1 muestra «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.» (R9-C B7, marcado como texto provisional pendiente del analista); al resto, el texto de SCA. Desde R45-C/R46-C no se muestra a SI24/GGE, central, CCC ni en nivel > 1.
- **Pruebas** (pólizas alternativas libres del grupo VW, misma causa: DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, presencial, A VENCIMIENTO):
  - SCA2, 0002729325315 (GRUPO VW CARTERA): alta sin aviso SI24 → **15789150**. Contra anulación nivel 1: aviso «Esta póliza pertenece a un acuerdo especial…» (icono azul). CANCELAR habilitado; POSPONER, FINALIZAR, POSITIVO y NEGATIVO deshabilitados hasta elegir oficina y argumento.
  - SCA, 0002729325313 (GRUPO VW FINANCIADO 1 AÑO): alta sin aviso SI24 → **15789152**. Contra anulación nivel 1: aviso «Esta poliza es de un acuerdo que trata SI24…» (amarillo). Mismos botones habilitados/deshabilitados.
  - Capturas `r49c-SCA_OBS01_VW_aviso_CA.png`, `r49c-SCA2_OBS01_VW_aviso_CA.png`. No son la misma póliza (acuerdos VW distintos), pero los dos acuerdos activan el aviso en el código de ambas apps.
- **Conclusión**: el comportamiento es el de SCA (aviso informativo, no bloquea botones). Solo cambia el texto para Red Mapfre nivel 1, que es una decisión anterior y un texto. **Cambio**: ninguno. Duda D2.

## OBS-03 — Flota 2002600073906 y wAutemis

- **Análisis en lectura**: el texto «La póliza que está gestionando es una flota y no tiene tratamiento en SCA, va a acceder a Mecanizar en wAutemis. Pulse Aceptar para continuar con la grabación de la solicitud, Cancelar para regresar a la captura de datos de la solicitud» está igual en `SCA2_mostrarMensajesOAlta` v2 y `SCA_mostrarMensajesOAlta` v7, con la misma condición (acuerdo 20, 33 o 35). Sale como «Advertencia» en el popup final de simulación (captura del analista `image13.png`). Ni SCA (`SCA_AltaSolicitudAnulacionEstrategicas`, `SCA_SimularAnulacionPopupEstrategicas`) ni SCA2 (`SCA2_AltaSolicitudPage`) abren wAutemis ni hay enlace: ACEPTAR graba la solicitud y CANCELAR vuelve al formulario. La «mecanización en wAutemis» es lo que se hace después en la tarea de mecanización, no una navegación del alta.
- **Pruebas**: 2002600073906 tiene solicitud en curso en las dos apps (`r49c-SCA2_OBS03_en_curso.png`, `r49c-SCA_OBS03_en_curso.png`). Las alternativas documentadas (2002500495555, 2002600000012, 2002600007357) también; 2002600009171 está libre pero no es de flota (sin aviso; cancelada sin grabar). No se ha podido ver el aviso en UI con una solicitud nueva.
- **Antecedente**: en R29-C (2002600060631) SCA2 avisaba de flota y no dejaba seguir, mientras SCA creaba la 15788322. Hoy el código de SCA2 es igual al de SCA (aviso con ACEPTAR que graba); ese bloqueo no se reproduce en lectura.
- **Cambio**: ninguno.

## Dudas para el analista

- **D1 (INC-01)**: SCA no permite dar de alta pólizas Vida (las rechaza como no válidas en el popup), así que no hay referencia SCA para el 4004 de `generarStudAnul`. ¿Hay alguna póliza Vida que SCA dé de alta en TEST, o los datos que faltan los tiene que indicar CORE? Mientras, no se crean más altas Vida.
- **D2 (OBS-01)**: para Red Mapfre en nivel 1, SCA2 dice «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.» y SCA «Esta poliza es de un acuerdo que trata SI24. La retención o anulación de la póliza se trasladara al SI24». El de SCA2 se puso en R9-C como provisional. Propuesta: cuando negocio cierre los textos, usar en SCA2 el de SCA (o el que decidan) y su mismo estilo de aviso; no se ha cambiado porque los textos están en revisión.
- **D3 (INC-03)**: SCA deja grabar una póliza renovada A FECHA si la simulación solo avisa de fecha fuera de situación, aunque antes muestra el aviso «La póliza está renovada…». SCA2 hace ahora lo mismo. ¿Es lo que se quiere, o el aviso de renovada debería bloquear en las dos?
- **D4 (OBS-03)**: para probar el aviso de flota con una solicitud nueva hace falta una póliza de flota (acuerdo 20/33/35) sin solicitud en curso. ¿Podéis facilitar una o liberar la 2002600073906?
