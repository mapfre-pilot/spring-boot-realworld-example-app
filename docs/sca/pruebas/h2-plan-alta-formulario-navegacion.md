# H2 — Plan de pruebas «Alta» (hoja `manual_test_2`, 34 casos): SCA vs SCA2 en TEST

- Ronda 8 (planes oficiales del analista). Plan: `docs/sca/pruebas/planes/alta.md`, hoja `manual_test_2`. Hoja `manual_test` → sesión H1.
- Entorno: Appian TEST. SCA `/suite/sites/sca-site` (referencia funcional) · SCA2 `/suite/sites/sca2`. Fecha de ejecución: 2026-10-13 (10:00–13:30 UTC).
- Usuario UI: JJGONZ2 (RED MAPFRE / OFICINA, CE_RM; configuración regional comprobada: Español (España), Europe/Madrid). SISANS no fue necesario.
- Pólizas asignadas (wAutemis, cía. 1): 0001047017007, 0001047017008, 0001047017009 y RCI 0005726678312. Antes de los altas se comprobó con `SCA2_consultarSolicitudes(numPoliza, codInt:"", tpBusqueda:"0")` que ninguna tenía solicitud (`MSSConsultarSolicitudes: null`).
- Grabación: `sca2-h2-ui-edited.mp4` (testing agent, única grabación anotada; incluye el primer intento con fecha no confirmada y su rectificación con teclado nativo). Capturas `cNN-sca-*.png` / `cNN-sca2-*.png` (no se suben al repo; adjuntas en el mensaje final de la sesión).

## 1. Veredicto

**SCA2 se comporta igual que SCA en los 10 casos del plan reproducibles con pólizas wAutemis y perfil de oficina** (cabecera, cascada motivo/detalle/causa/catalogación, compañía contraria, obligatorios, fecha > vencimiento, Ilocalizado ×3, navegación a Acción Administrativa, aviso de solicitud previa). **No se ha detectado ninguna divergencia exclusiva de SCA2 que corregir**; no se ha modificado ningún objeto Appian en esta sesión. Los 24 casos restantes son NO PROBADO por falta de datos/condiciones en TEST (NSE, Vida, CCC/CCR, MásMóvil, Ibericar, telemática, PRRA, códigos M201/M206, misma anualidad, mecanización directa) o por falta de pólizas libres; para los que dependen del popup de simulación/Expertos de SCA se recuerda que están cubiertos por las dudas abiertas A1/A2/A3/A6 del doc 22 (no se corrigen).

Recuento: **OK igual 10 · DIVERGENCIA corregida 0 · DIVERGENCIA pendiente 0 · NO PROBADO 24** (total 34).

Hallazgos colaterales (SCA, no corregibles desde SCA2): latencia/403 de SCA al guardar (las solicitudes sí se crean en CORE) y error de evaluación en SCA al volver del detalle con la flecha atrás (`sca_datoscabecera` / `a!submitLink`). SCA2 no presenta ninguno de los dos.

## 2. Tabla de casos

| Id plan | Nombre | Resultado SCA | Resultado SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| manual_test_2-1 | Cabecera wAutemis | Redirige al alta; secciones Cliente y Póliza con los mismos campos (efecto 29/01/2026, vencimiento 29/01/2027, producto, vehículo, prima, forma de pago, productor…). | Igual (mismas secciones/campos; valores de otra póliza de la misma serie). | **OK igual** | c01-sca-cabecera-cliente/poliza, c01-sca2-cabecera-cliente/poliza |
| manual_test_2-2 | Motivo / Detalle / Causa | Cascada operativa: 3 motivos; 6 detalles bajo «Decisión de cliente»; 3 causas bajo «Precio» (incl. «ME HA SUBIDO MUCHO LA PRIMA»); carga catalogaciones. | Igual (mismas opciones). | **OK igual** | c02-sca-motivos/detalles/causas, c02-sca2-motivos/detalles/causas |
| manual_test_2-3 | Catalogaciones | Para Precio → Me ha subido mucho la prima sólo «A VENCIMIENTO»: fecha 29/01/2027 autocompletada y calendario bloqueado. Con Baja Vehículo, «A FECHA» habilita el calendario. | Igual en ambas catalogaciones. | **OK igual** | c03-sca-catalogaciones, c03-sca-a-vencimiento, c03-sca2-catalogaciones, c03-sca2-a-vencimiento |
| manual_test_2-4 | Compañía aseguradora contraria | Selección «3107 - AIG EUROPE», descripción rellena; persistida en la solicitud 15787894. | Igual; persistida en 15787880 (detalle SCA2). | **OK igual** | c04-sca-compania-seleccionada, c04-sca2-compania-persistida |
| manual_test_2-5 | Validación campos obligatorios | Con Canal o Motivo vacío GUARDAR deshabilitado, tooltip «Revise los parámetros obligatorios del formulario.» | Igual (mismo tooltip, mismo comportamiento). | **OK igual** | c05-sca-canal-vacio, c05-sca-motivo-vacio, c05-sca2-canal-vacio, c05-sca2-motivo-vacio |
| manual_test_2-6 | Guardar Contra Anulación | Póliza 0001047017007: GUARDAR crea 15787894 (Más prima, A VENCIMIENTO 29/01/2027, PRESENCIAL, AIG EUROPE, CORE: gestión Alta 8 FINALIZADA) pero el formulario queda «Aún procesando» >300 s y después 403 de SCA: **destino Contra Anulación no comparable por latencia**. | **No ejecutado en esta ronda**: las dos pólizas normales de SCA2 se consumieron en el caso 14/7 (ver §6). El flujo Alta→Contra Anulación en SCA2 ya fue probado en `s1-alta-contraanular-positivo-finalizar.md` y ronda 7. | **NO PROBADO** — sin póliza libre para SCA2; SCA no comparable por latencia | c06-sca-guardar-latencia, c06-sca-detalle-solicitud, c06-sca2-007-id-creado-en-sca |
| manual_test_2-7 | Guardar Acción Administrativa | Póliza RCI 0005726678312: crea 15787897 (Baja Vehículo) pero no muestra la pantalla destino (latencia >180 s y 403). | Pólizas 0001047017008 → 15787880 y 0001047017009 → 15787885: guarda y **navega directamente a Acciones Administrativas** (tarea Incompleta, nivel 1). | **OK** (SCA2 según plan; SCA no comparable por latencia) | c07-sca2-008-detalle, c07-sca2-009-buscador-id, c07-sca2-009-detalle, c07-sca-rci-antes-guardar, c07-sca-guardar-latencia, c07-sca-rci-detalle |
| manual_test_2-8 | Guardar Autorización | Existe la combinación Decisión de la entidad → Decisión de la entidad → Anulación fuera de norma. No se guardó (sin póliza libre). | Igual (misma combinación disponible). | **NO PROBADO** — sin póliza libre; flujo ya cubierto en `s4-autorizacion-fuera-norma.md` | c08-sca-fuera-norma-opciones, c08-sca2-fuera-norma-opciones |
| manual_test_2-9 | Guardar Mecanización directa | — | — | **NO PROBADO** — no hay perfil/póliza que salte a mecanización directa en TEST | — |
| manual_test_2-10 | Cabecera NSE Autos | — | — | **NO PROBADO** — sin pólizas NSE en TEST | diseño §5 |
| manual_test_2-11 | Cabecera NSE Hogar | — | — | **NO PROBADO** — sin pólizas NSE | diseño §5 |
| manual_test_2-12 | Fecha anulación con siniestros | — | — | **NO PROBADO** — las pólizas asignadas no tienen siniestros (`fechaUltimoSiniestro: null`) | diseño §5 (regla idéntica) |
| manual_test_2-13 | Excepción fecha/siniestros CCC-CCR | — | — | **NO PROBADO** — sin usuario CCC/CCR | diseño §5 (regla idéntica) |
| manual_test_2-14 | Fecha anulación > vencimiento | Con fecha 30/01/2027 (venc. 29/01/2027) y 30/06/2028: muestra «Se han detectado los siguientes errores: La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.». Al pulsar GUARDAR de nuevo SCA pasa al aviso de simulación NEW (VOLVER/ACEPTAR; no se aceptó). | Mismo literal; GUARDAR bloqueado, permanece en el formulario (no continúa, como pide el plan). Verificado con teclado nativo tras re-render (Observaciones). Regla `SCA2_erroresGuardarSolicitud` probada también por LCP (devuelve el error). | **OK igual** (mismo mensaje; la pantalla de simulación posterior de SCA es la duda abierta A1) | c14-sca-fecha-nativa-antes/guardar, c14-sca-fecha-18meses-aviso/guardar, c14-sca2-fecha-nativa-antes/guardar, c14-sca2-fecha-18meses-nativa |
| manual_test_2-15 | Excepción vencimiento CCC-CCR | — | — | **NO PROBADO** — sin usuario CCC/CCR | diseño §5 |
| manual_test_2-16 | MásMóvil | — | — | **NO PROBADO** — sin póliza MásMóvil | diseño §5 |
| manual_test_2-17 | Paso a experto — No | — | — | **NO PROBADO** — pregunta del popup de simulación de SCA; SCA2 no tiene popup (duda abierta A1/A2) | diseño §5 |
| manual_test_2-18 | Paso a experto — Sí | — | — | **NO PROBADO** — ídem 17 | diseño §5 |
| manual_test_2-19 | AA telemática/telefónica — No | — | — | **NO PROBADO** — pólizas asignadas «No Telemática»; pregunta del popup SCA | diseño §5 |
| manual_test_2-20 | AA telemática/telefónica — Sí | — | — | **NO PROBADO** — ídem 19 | diseño §5 |
| manual_test_2-21 | Acuerdo especial Ibericar — No | — | — | **NO PROBADO** — sin póliza Ibericar | diseño §5 |
| manual_test_2-22 | Acuerdo especial Ibericar — Sí | — | — | **NO PROBADO** — ídem 21 | diseño §5 |
| manual_test_2-23 | Contra Anulación CCC — No | — | — | **NO PROBADO** — sin usuario CCC | diseño §5 |
| manual_test_2-24 | Contra Anulación CCC — Sí | — | — | **NO PROBADO** — ídem 23 | diseño §5 |
| manual_test_2-25 | Ilocalizado, Red Mapfre, canal ≠ Correspondencia | Causa «Ilocalizado» (Decisión de cliente → Asegurado no desea seguro), canal Presencial: «Se han detectado los siguientes errores: No es posible dar de alta una solicitud presencial con este medio de comunicación. Por favor modifique el medio de comunicación.» No se crea solicitud. | Mismo literal, mostrado al pulsar GUARDAR, bloquea. | **OK igual** | c25-sca-ilocalizado-presencial, c25-sca2-ilocalizado-presencial |
| manual_test_2-26 | Ilocalizado, Red Mapfre, Correspondencia | Canal Correspondencia / medio Carta, GUARDAR: «Se han detectado los siguientes errores: Si das de alta la solicitud con estos datos, no podrás imprimir la carta de oposición a la renovación para entregar al cliente, ni tendrás acceso a los argumentos.» | Mismo literal; se muestra como error del formulario, sin diálogo. No se guardó con esta causa en ninguna de las dos. | **OK igual** | c26-sca-ilocalizado-correspondencia, c26-sca2-ilocalizado-correspondencia |
| manual_test_2-27 | Ilocalizado, canal ≠ Correspondencia/Área Clientes | Igual que el 25 (perfil Red Mapfre es el único disponible). | Igual. | **OK igual** | c25-* |
| manual_test_2-28 | SI24 Corredor/Banca, solicitud misma anualidad | — | — | **NO PROBADO** — sin usuario SI24 Corredor/Banca ni póliza con solicitud cerrada en la misma anualidad; aviso ligado a `flagActivoPMO` (duda abierta A6) | diseño §5 |
| manual_test_2-29 | Error M201 simulación wAutemis (no continúa) | — | — | **NO PROBADO** — no se puede forzar M201; en TEST NEW devuelve siempre error genérico con `avanzarAltaSolicitud: true` | diseño §5 |
| manual_test_2-30 | Error simulación NSE (no continúa) | — | — | **NO PROBADO** — sin pólizas NSE | diseño §5 |
| manual_test_2-31 | Error M206 simulación wAutemis (continúa) | — | — | **NO PROBADO** — ídem 29 | diseño §5 |
| manual_test_2-32 | Error simulación NSE (continúa) | — | — | **NO PROBADO** — sin pólizas NSE | diseño §5 |
| manual_test_2-33 | Excepción PRRA NSE Autos | — | — | **NO PROBADO** — sin pólizas NSE; detección PRRA en UI de SCA2 desactivada (403; doc 21, duda A3) | diseño §5 |
| manual_test_2-34 | Excepción PRRA NSE Hogar | — | — | **NO PROBADO** — ídem 33 | diseño §5 |

Comprobación adicional (no numerada en el plan, «aviso de solicitud previa»): al buscar 0001047017008 tras el alta, SCA abre el detalle de la solicitud existente y SCA2 muestra la solicitud 15787880 y permite abrir su detalle; ninguna ofrece un alta nueva. Igual funcionalmente (c05b-sca-008-solicitud-previa, c05b-sca2-solicitud-previa).

## 3. Solicitudes creadas (todas PENDIENTE, canal PRESENCIAL, usuario JJGONZ2, nivel 1)

| Creada en | Póliza | Id solicitud | Fecha anulación | Causa / catalogación | Cía. contraria | CORE (`SCA2_consultaGestion`) |
|---|---|---|---|---|---|---|
| SCA2 | 0001047017008 | 15787880 | 13/10/2026 | BAJA VEHÍCULO / A FECHA | AIG EUROPE | gestión 43705402 acción 8 (Alta) FINALIZADA 12:25:48; gestión 43705403 acción 3 (Acción Administrativa) INCOMPLETA; `codEstSolic` 2 |
| SCA2 | 0001047017009 | 15787885 | 13/10/2026 | BAJA VEHÍCULO / A FECHA | — | gestión 43705411 acción 8 FINALIZADA 12:31:51; gestión 43705412 acción 3 INCOMPLETA; `codEstSolic` 2 |
| SCA | 0001047017007 | 15787894 | 29/01/2027 | ME HA SUBIDO MUCHO LA PRIMA / A VENCIMIENTO | AIG EUROPE | gestión 43705426 acción 8 FINALIZADA 12:41:46 (observaciones «Prueba H2 caso 6»); `codEstSolic` 2; sin gestión de Contra Anulación todavía (SCA no llegó a navegar) |
| SCA | 0005726678312 (RCI) | 15787897 | 13/10/2026 | BAJA VEHÍCULO / A FECHA | — | creada en CORE; SCA terminó en 403 sin mostrar destino |

Nota sobre 15787880/15787885: la fecha tecleada por el agente (30/01/2027 y 30/06/2028) con `fill()+Tab` de Playwright **no fue confirmada por Appian** (el `a!dateField` conservó la fecha por defecto de la catalogación, 13/10/2026), por lo que el alta fue válida y CORE decidió Acción Administrativa. Repetido el caso con teclado nativo, SCA2 bloqueó correctamente (caso 14). No son evidencia de fallo de validación.

## 4. Divergencias

### 4.1 Corregidas
Ninguna. No se ha modificado ningún objeto Appian (SCA2_* incluidos). Tabla de coordinación `coordinacion-ronda8.md`: sin reservas de H2.

### 4.2 Pendientes
Ninguna nueva. Los casos 17–24, 29–34 y 28 dependen de comportamientos de SCA que ya están registrados como **dudas funcionales abiertas** en `docs/sca/22-dudas-funcionales-para-el-analista.md` y no se corrigen hasta decisión del analista:
- **A1/A2 — Simulación y paso a Expertos antes de GUARDAR**: SCA abre un popup de simulación (con las preguntas Sí/No de Expertos, telemática, Ibericar, CCC y el aviso «NEW nos indica un error al realizar la simulación…» con VOLVER/ACEPTAR). SCA2 guarda directamente y navega a la acción decidida por CORE. Pregunta de negocio: *¿debe SCA2 reproducir el popup de simulación con las preguntas de paso a Expertos/técnicos, o basta con la decisión de CORE tras el alta?*
- **A3 — PRRA**: detección desde la interfaz desactivada en SCA2 (403 al simular como usuario final). Pregunta: *¿cómo debe detectarse una póliza PRRA si la simulación no puede ejecutarse desde la UI?*
- **A6 — Aviso «existen solicitudes…» (misma anualidad / `flagActivoPMO`)**.

### 4.3 Hallazgos sólo de SCA (no se corrigen; SCA no se toca)
- Latencia/403 de SCA al guardar: los altas de 0001047017007 y 0005726678312 crearon la solicitud en CORE pero el formulario quedó «Aún procesando» (>180–300 s) y después mostró «403 Acceso denegado — No tiene permiso para ver esta página». Ya documentado en rondas anteriores.
- Al volver del detalle de solicitud con la flecha atrás, SCA muestra «Error de evaluación de expresión … in rule 'sca_datoscabecera' (called by rules 'sca_detallesolicitud' > 'sca_buscarsolicitudclientepoliza' > 'sca_buscadorsolicitudprincipal') at function a!submitLink [line 23]: … The save target must be a local variable that does not refresh on every evaluation…». SCA2 vuelve al buscador sin error (c05b-sca-error-volver-detalle, c05b-sca2-volver-detalle).

## 5. Casos no reproducibles en TEST (NO PROBADO) — motivo y comprobación de diseño

Sólo hay pólizas wAutemis (compañía 1, Autos) asignadas y un único perfil de oficina (CE_RM / RED MAPFRE-OFICINA) más SI24 Experto. Para los casos siguientes no existe en TEST el dato o la condición que exige el plan; se ha hecho, como evidencia complementaria, una comparación del diseño SAIL de SCA y SCA2 (reglas descargadas por LCP y comparadas normalizando espacios y prefijos `SCA_`/`SCA2_`).

| Caso | Motivo NO PROBADO | Comprobación de diseño SCA vs SCA2 |
|---|---|---|
| 10, 11 | Cabecera NSE Autos / NSE Hogar: no hay pólizas NSE en TEST. | `SCA2_obtenerDatosCabecera` contempla NSE (`datosSpto`), pero la rama NSE no es verificable sin póliza. |
| 12 | Necesita póliza con siniestro posterior a la fecha de anulación; las pólizas asignadas devuelven `fechaUltimoSiniestro: null`. | Validación idéntica en `SCA_erroresGuardarSolicitud` y `SCA2_erroresGuardarSolicitud` («No es posible anular a la fecha solicitada, ya que existe un siniestro con fecha posterior…»). |
| 13, 15 | Requieren usuario con subperfil CCC/CCR (`CE_MF_RECIBOS_CCC`/`CCR`); no disponemos de ese usuario. | Excepción CCC/CCR idéntica en ambas reglas (`subperfil <> "CE_MF_RECIBOS_CCC"` y `<> "CE_MF_RECIBOS_CCR"`). |
| 16 | Requiere póliza MásMóvil (acuerdo específico); no hay en TEST. | Tratamiento por `codAcuerdo` en `SCA2_validacionesPreviasPopupAlta` idéntico a SCA (diff vacío). |
| 17, 18 | Paso a Expertos (pregunta Sí/No con teléfono): en SCA forma parte del popup de simulación previo al alta; en SCA2 no existe el popup (duda funcional abierta A1/A2 del doc 22: simulación/Expertos antes de GUARDAR). | **Divergencia de diseño ya documentada como duda abierta**: `SCA2_AltaSolicitudPage` no tiene `anulaExpertos`/`tlfPasoExperto`; envía `telefonoExpertos: null`. No se corrige (decisión funcional pendiente). |
| 19, 20 | Acción Administrativa telemática/telefónica: requiere póliza de productor «Telemática»; las asignadas son «RED AGEN DIR / Expertos / No Telemática». | Igual que 17/18: pregunta del popup de simulación de SCA, inexistente en SCA2 (duda A1/A2). |
| 21, 22 | Acuerdo especial Ibericar: no hay póliza con ese acuerdo en TEST. | Idem (pregunta del popup SCA). |
| 23, 24 | Contra Anulación con subperfil CCC: sin usuario CCC. | Idem; además `anulaTecnicos` sólo existe en SCA (duda A1/A2). |
| 28 | SI24 Corredor/Banca con solicitud de la misma anualidad: sin póliza con solicitud cerrada en la misma anualidad y sin usuario SI24 Corredor/Banca (SISANS es SI24 Experto). | Aviso de cabecera «existen solicitudes…» ligado a `flagActivoPMO` (duda abierta A6). |
| 29, 31 | Códigos M201/M206 de simulación wAutemis: no se puede forzar la respuesta del servicio de simulación. En TEST el servicio NEW devuelve siempre «NEW nos indica un error al realizar la simulación…» con `avanzarAltaSolicitud: true` (observado por LCP en `SCA2_erroresGuardarSolicitud.erroresSimular`). | Mensajes M201/M206 existen en `SCA_mostrarMensajesOAlta`/`SCA2_mostrarMensajesOAlta` (diff sólo en `rand()`); la presentación al usuario en SCA es el popup de simulación (duda A1). |
| 30, 32, 33, 34 | Simulación NSE y PRRA NSE: sin pólizas NSE; la detección PRRA desde la interfaz SCA2 está desactivada (`local!prra: false`, 403 al simular como usuario final; doc 21). | Pendiente ya documentado en doc 20/21/22 (A3). |
| 8, 9 | Autorización / Mecanización directa: la decisión la toma CORE según perfil+póliza; con perfil oficina y las pólizas asignadas CORE decidió Contra Anulación / Acción Administrativa. No quedaban pólizas para probar «Anulación fuera de norma» y no hay póliza/perfil de mecanización directa. | Navegación directa a la tarea decidida (`SCA2 Tarea` PENDIENTE) es común a todas las acciones en `SCA2_AltaSolicitudPage`. Autorización ya probada en ronda anterior (`s4-autorizacion-fuera-norma.md`). |

Comparación de reglas por LCP (diff tras normalizar espacios y prefijos): `SCA2_erroresGuardarSolicitud` ≡ `SCA_erroresGuardarSolicitud`; `SCA2_calculoCanalEntrada`, `SCA2_calculoMedioComunicacion`, `SCA2_validacionesPreviasPopupAlta` ≡ SCA (diff vacío); `SCA2_mostrarMensajesOAlta` sólo difiere en `rand()` del REST de conceptos. Divergencias de diseño en la interfaz de alta (`SCA2_AltaSolicitudPage` vs `SCA_AltaSolicitudAnulacion`): sin popup de simulación, sin `anulaExpertos`/`anulaTecnicos`/`tlfPasoExperto`, `local!prra: false`; `SCA2_PM_CMD_ALTA` síncrono y navegación directa a la tarea `SCA2 Tarea` PENDIENTE → todas ellas corresponden a las dudas A1/A2/A3.

## 6. Limitaciones
- Sólo 4 pólizas: el fallo de confirmación de fecha del primer intento (Playwright `fill()`) consumió las dos pólizas normales de SCA2 con altas válidas de Baja Vehículo, dejando sin póliza el caso 6 en SCA2. Se pide una póliza RCI de reserva para repetir Alta→Contra Anulación en SCA2 si se considera necesario (ya probado en s1/ronda 7).
- SCA: latencia >180 s y 403 al guardar; destino de Contra Anulación / Acción Administrativa no observable en SCA en esta ronda.
- Perfil disponible: sólo RED MAPFRE/OFICINA (y SI24 Experto, no usado). Sin CCC/CCR, SI24 Corredor/Banca, NSE, Vida, MásMóvil, Ibericar, telemática ni PRRA en TEST.
- Lección para próximas rondas: en `a!dateField` de Appian hay que teclear la fecha de forma nativa y pulsar Enter/clic fuera y comprobar que persiste tras un re-render antes de GUARDAR.

## 7. Evidencias
- Grabación: `sca2-h2-ui-edited.mp4`.
- Capturas (fuera del repo): c01-* (cabecera), c02-* (motivos/detalles/causas), c03-* (catalogaciones), c04-* (compañía), c05-* (obligatorios), c05b-* (solicitud previa y vuelta del detalle), c06-* (alta SCA 007), c07-* (Acción Administrativa 008/009/RCI), c08-* (fuera de norma), c14-* (fecha > vencimiento, 18 meses, configuración regional), c25-*/c26-* (Ilocalizado).
