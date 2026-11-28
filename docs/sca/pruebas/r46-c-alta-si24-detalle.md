# R46-C — Alta, Si24/Verti, detalle y mensajes (Appian TEST, 10/11/2026)

Origen: «Analisis SCA2.docx» (2.ª entrega R46), respuestas a las dudas 15, 16, 17, 19, 20, 26, 28, 30, 33 y 44 de `../63-dudas-analista-pendientes.md` y correcciones nuevas (enlace NSE, CONSULTAR SOLICITUD, mensaje de fecha anterior a efecto). Herramienta: MCP de Appian TEST `appian-dev-mcp-c90b`. Usuarios: JJGONZ2 (Red Mapfre / Oficina) y SISANS (Si24). Solo se han modificado objetos SCA2; SCA se ha consultado en solo lectura.

## 1. Objetos modificados

Procedimiento por objeto: reserva en `coordinacion-ronda46.md` → lectura del objeto vivo → copia de seguridad → cambio mínimo → importación → reexportación y diff (0 diferencias con lo enviado) → liberación. [Observado]

| Objeto | Versión | Cambio |
|---|---|---|
| IF `SCA2_ContraAnulacionOpciones` | v70 → v71 (viva v74, ver nota) | `local!tratadaPorSi24` incluye central (`CE_MF_CENTRAL_AT`) y CCC (`local!esCCC`: `CE_MF_RECIBOS`, `CE_MF_RECIBOS_CCC`, `CE_MF_RECIBOS_CCR`): el aviso de póliza de acuerdo Si24 ya no se les muestra. `local!finalizarSinDocumentos` = `or(codPerfilGGE, codPerfilSi24Experto, codPerfilSi24Front)`, como SCA. |
| IF `SCA2_AltaSolicitudAnulacionPopUp` | v11 → v12 | Con «Existe una solicitud en curso…» el botón es **CONSULTAR SOLICITUD** y abre el Detalle de la solicitud de la póliza (la de SCA2 o, si no hay, la primera de CORE: `local!idSolicitudConsulta`). Vale también para `local!polizaPendiente`. |
| ER `SCA2_erroresGuardarSolicitud` | v2 → v3 | Solo el literal del error de fecha anterior a efecto; la condición no cambia. |
| ER `SCA2_puedeGestionarTarea` | v6 → v7 | Nueva `local!esVerti` (tipo = `SCA2_TXT_CONTACTO_VERTI`): la tarea asignada al usuario conectado se puede gestionar aunque la solicitud esté en un grupo SI24. |
| IF `SCA2_DetalleSolicitud` | v74 → v75 → v76 | (a) En la Verti se pasa la tarea con su `asignadoA` a `SCA2_puedeGestionarTarea` (el resto de tareas sigue igual) y no se muestra «Esta solicitud la está gestionando SI24» al usuario asignado de su propia Verti. (b) Tarjeta Autorización (NSE, no wAutemis): nuevo campo «Detalle de la suscripción: NSE» con enlace guiado `k`/`n`/`o`. v76 corrige un error de tipos de v75 (`wherecontains(Boolean, Any Type)`) al desplegar tarjetas sin observaciones (visto en CA2 de 15788853, `r46c-c4-ca2-error-wherecontains.png`). |

- [Observado] Nota `SCA2_ContraAnulacionOpciones`: R46-D guardó v72 sobre v70 y pisó la v71; R46-D la restauró en v73 (= v71 + 2 líneas suyas) y añadió v74 (SVA). Diff de la v74 viva frente a la v71 de R46-C: solo los dos bloques de R46-D; los cambios de R46-C están intactos.
- [Observado] N5 (error CMP) y la explicación de Vida, COMPROBAR AHORA, respaldo y doc 44 no requieren cambios.

## 2. Pruebas (Appian TEST, UI real)

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| C1 | Alta con solicitud en curso, póliza 2002400441596 (JJGONZ2) | Mensaje «Existe una solicitud en curso…», botón CONSULTAR SOLICITUD que abre la consulta | [Observado] Botón «CONSULTAR SOLICITUD»; abre el Detalle de 15788835 (la de esa póliza) (`r46c-c1-popup-consultar.png`, `r46c-c1-detalle-15788835.png`) | OK | 15788835 (solo consulta) | — | Nueva solicitud → póliza → mensaje → CONSULTAR SOLICITUD | — |
| C2 | Fecha de anulación anterior a efecto, póliza 2002400441598 | Mensaje completo nuevo; no se crea solicitud | [Observado] «Se han detectado los siguientes errores: La fecha de anulación no puede ser anterior a la de efecto. Para poder realizar una anulación con fecha anterior a la de efecto, se tiene que realizar un suplemento de anulación de suplemento…» y no se crea solicitud (`r46c-c2-error-fecha-completo.png`, `r46c-c2-sin-nueva-solicitud.png`) | OK | — | — | Alta con fecha anterior al efecto → GUARDAR | — |
| C3 | Enlace NSE de la tarjeta Autorización | URL guiada con `k` = solicitud de suscripción NSE, `n` = tipo, `o` = documento | [Observado] Histórica 15787950 (2002300361333): «Detalle de la suscripción: NSE» → `…/EVT21_NSE_FWEB/indexGuiado.jsp?h=41&t=12&x=35&g=42&m=N&i=S&r=2&s=1&u=73&k=2002642G0000067&n=NIE&o=Y3788733A` (`r46c-c3-nse-sca2-15787950.png`). SCA legacy no muestra ese enlace para la misma solicitud (`r46c-c3-nse-legacy-15787950.png`) | OK | 15787950 (solo consulta) | — | Detalle → tarjeta Autorización → href | [Inferido] En SCA el enlace depende de su propia observación de suscripción; ver §3.3 |
| C4a | N6: Verti nivel 2 asignada al usuario del alta (solicitud nueva) | JJGONZ2 ve RETOMAR, sin aviso SI24, y gestiona su Verti | [Observado] En 15788853 (0002729325312), tras la CA2 negativa de SISANS, la Verti queda asignada a JJGONZ2; JJGONZ2 ve RETOMAR sin aviso y completa la Verti hasta ANULAR PÓLIZA (`r46c-c4-verti-propia-retomar.png`) | OK | 15788853 | no visible | Alta JJGONZ2 (DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, A VENCIMIENTO 21/08/2026) → CA1 negativa → CA2 SISANS negativa → Verti JJGONZ2 → ANULAR PÓLIZA | — |
| C4b | Verti → inducción con Oficina | Tras ANULAR PÓLIZA, inducción (un error CMP «datos del agente» se acepta) | [Observado] 15788853 termina en Mecanización Incompleta sin inducción (`r46c-c4-mecanizacion-incompleta.png`). Repetición: 5313, 5307 y 5315–5319 tienen el vencimiento pasado; 5320 (vto. 21/08/2028) con PRECIO solo ofrece A VENCIMIENTO y NEW devuelve 916 (18 meses) (`r46c-c4-repeticion-5320-error-new-916.png`); con VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE (A FECHA 10/11/2026) se crea 15788857, pero va a Acciones Administrativas con documentación obligatoria (`r46c-c4-15788857-aa-incompleta.png`, `r46c-c4-15788857-documentacion.png`) | KO (bloqueado por datos) | 15788853, 15788857 | no visible | Ver C4a; cribado de pólizas y 2 combinaciones | [Inferido] La mecanización de 15788853 falla porque la fecha de anulación (vencimiento 21/08/2026) ya ha pasado (solicitud caducada), no por el cambio de R46-C. [Pendiente] Póliza de acuerdo con vencimiento admitido por NEW (< 18 meses) para repetir la inducción |
| C4c | Histórica 15788839 (solo consulta) | JJGONZ2 (usuario de la Verti) puede gestionarla; SISANS no ve REASIGNAR (analista: no se muestra) | [Observado] JJGONZ2: RETOMAR; SISANS: ni RETOMAR ni REASIGNAR, solo lectura (`r46c-c4-historica-15788839-jjgonz2.png`, `r46c-c4-historica-15788839-sisans.png`) | OK | 15788839 (no modificada) | — | Abrir Detalle con cada usuario | [Observado] Igual que SCA: en `SCA_DetalleAnulacionMecanizacion` RETOMAR solo se pinta si el propietario de la tarea es el usuario conectado (R45-C F3-D5b) |
| C5a | Oficina (Red Mapfre), póliza de acuerdo Si24 | Aviso Si24 visible; FINALIZAR exige carta | [Observado] Aviso visible; con argumento INCREMENTO PRIMA negativo FINALIZAR deshabilitado con «Se ha de imprimir la plantilla de la carta firmada»; tras imprimir la plantilla se habilita (`r46c-c5-oficina-aviso-si24.png`, `r46c-c5-oficina-carta-obligatoria.png`) | OK | 15788853 | — | CA1 con JJGONZ2 | — |
| C5b | SISANS (Si24) | Sin aviso Si24; finaliza sin carta con argumento negativo | [Observado] Sin aviso; FINALIZAR habilitado sin carta (`r46c-c5-sisans-finalizar-sin-carta.png`) | OK | 15788853 | — | CA2 con SISANS | [Observado] Al intentar repetir un argumento ya ejecutado sale «El argumento no puede volver a ejecutarse» (comportamiento previo, no de R46-C) |
| C5c | Central, CCC, GGE, Si24 front | Sin aviso; carta según §3.1 | [Pendiente] No hay usuarios de prueba con esos perfiles | — | — | — | — | Probar con usuarios de esos perfiles |
| C6 | Retorno al formulario tras el alta | No se vuelve al formulario; se pasa a la gestión | [Observado] Tras GUARDAR el formulario se oculta; confirmación del alta y ACEPTAR abre la CA sin volver al formulario. Tiempos: ≈12 s hasta validaciones, ≈18 s hasta «alta generada», ≈27 s hasta la gestión (`r46c-c6-alta-generada.png`). No se pasó al respaldo («Su solicitud se está generando…») | OK | 15788853 | — | Alta JJGONZ2 → GUARDAR → ACEPTAR | — |

Grabación de la ejecución principal: adjunta al mensaje de entrega (no se sube al repositorio). [Observado]

### Solicitudes de prueba abiertas al cierre
- [Observado] **15788857** (0002729325320): Solicitud Pendiente, nivel 1; Alta finalizada y Acciones Administrativas Incompleta (falta documentación). Creada 10/11/2026 16:38:21, PRESENCIAL, A FECHA 10/11/2026. No se ha cancelado.
- [Observado] **15788853** (0002729325312): «Solicitud Finalizada sin anular» en el listado; CA finalizada, Verti gestionada, Mecanización Incompleta. Sin tareas pendientes.
- [Observado] Instancias: no visibles desde el site; no se ha tocado ninguna instancia histórica.

## 3. Respuestas y explicaciones para el analista

### 3.1 Perfiles que exigen la carta firmada al FINALIZAR (duda 16)
- [Observado] En SCA (`SCA_ContraAnulacionOpcionesEstrategicas`) FINALIZAR exige la carta cuando `codPerfilGGE = false`, `codPerfilSi24Experto = false`, `codPerfilSi24Front = false`, la documentación aplica (`mostrarDocumentacion`, pólizas no Vida) y la carta no está impresa/adjunta. La comprobación del DNI está comentada en SCA: hoy SCA **no exige DNI**, solo la carta.
- [Observado] Finalizan sin carta (SCA y ahora SCA2): **GGE** (`CE_MF_BK`), **Si24 experto** (`CE_MF_SI24_EXPERTO`) y **Si24 front** (`CE_MF_SI24_FRONT`).
- [Observado] La exigen: Red Mapfre (`CE_RM`, `CE_RM_DT`, subperfil `CE_RM_OFICINA`), Si24 técnico (`CE_MF_SI24_TECNICO`), Si24 SA (`CE_MF_SI24_SA`), central (`CE_MF_CENTRAL_AT`), CCC/CCR (`CE_MF_RECIBOS`) y control (`CE_MF_CONTROL`).
- [Observado] Antes (v70, R45-C) SCA2 dejaba finalizar sin carta a todos menos Red Mapfre.

### 3.2 Aviso Si24 (duda 15)
- [Observado] Ya no se muestra a: gestor Si24, GGE, nivel > 1 (R45-C) y, desde R46-C, central (`CE_MF_CENTRAL_AT`) y CCC (`CE_MF_RECIBOS`, `CE_MF_RECIBOS_CCC`, `CE_MF_RECIBOS_CCR`). Se sigue mostrando a Red Mapfre (C5a) y a control (`CE_MF_CONTROL`).

### 3.3 Enlace NSE (corrección nueva)
- [Observado] SCA (`SCA_DetalleAnulacionAutorizacionEstrategicas`) construye `cons!SCA_TXT_URL_NSE & "indexGuiado.jsp?h=41&t=12&x=35&g=42&m=N&i=S&r=2&s=1&u=73&k=" & idSuscripcion`, sin `n` ni `o`, con `idSuscripcion` = el número que sigue a «Num Solicitud Anulacion: » en la observación «RESPUESTA SUSCRIPCION NSE:» (solo si la póliza no es wAutemis).
- [Observado] SCA2 no tenía este enlace en la tarjeta Autorización. Ahora usa `SCA2_TXT_URL_NSE_GUIADO` (`https://wportalinterno.es.mapfre.net/EVT21_NSE_FWEB/indexGuiado.jsp`) con los mismos parámetros y `k` obtenido igual que SCA, y añade `&n=<tipo>&o=<documento>`.
- [Inferido] La cabecera de SCA2 (`SCA2_obtenerDatosCabecera`) no trae el tipo de documento, solo `clienteNif`. El tipo se deduce del formato: `X/Y/Z + 7 dígitos + letra` → NIE; `8 dígitos + letra` → NIF; `letra (A–H, J, N, P–S, U–W) + 7 dígitos + control` → CIF; cualquier otro → PAS. Ejemplo real: 15787950 → `n=NIE&o=Y3788733A`. [Pendiente] Si hay un campo de tipo de documento en algún servicio de cliente que prefiráis, indicadlo.

### 3.4 Error de CMP «datos del agente» (duda 17, N5 de R46-A)
- [Observado] Según el analista, es normal en TEST (sin clave de producción coherente en PRE); el componente devuelve el control con el error y SCA2 da la inducción por finalizada.
- [Inferido] Es lo que ya hace la tarjeta (R45-C/R46-A). **No se cambia la tarjeta**; N5 queda cerrada.

### 3.5 Verti de nivel 2 (dudas 19 y 20, N6 de R46-A)
- [Observado] La Verti de nivel 2 se asigna al usuario del alta (igual que SCA: nodo de usuario asignado a `pp!initiator`, R45-C F3-D5a). Causa del bloqueo N6: `SCA2_puedeGestionarTarea` no dejaba gestionar a un usuario no Si24 una tarea de una solicitud en grupo SI24, ni aunque estuviera asignada a él, y `SCA2_DetalleSolicitud` le pasaba la tarea sin `asignadoA`.
- [Observado] Corregido (§1): JJGONZ2 retoma y gestiona su Verti (15788853 y la histórica 15788839). SISANS no ve REASIGNAR en la Verti de otro usuario, como confirma el analista.

### 3.6 Identificación de la póliza en el alta y la consulta (duda 26) — sin cambios
SCA2 usa `SCA2_obtenerTipoPoliza`, copia literal de `SCA_obtenerTipoPoliza` (y de `SCA_obtenerTipoPolizaDecisora`): [Observado]

| Paso | SCA (código) | SCA2 (código) | Descripción del analista |
|---|---|---|---|
| 1 | Rellena con ceros a la izquierda hasta 13 y mira los 3 primeros dígitos: `200` → NSE Autos; `073`/`873` → NSE Hogar | Igual (`SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS` = `200`) | «13 posiciones y empieza por 200 o 073» |
| 2 | Si no, `SCA_pBuscarPoliza` (pcodcia 90, póliza a 13 posiciones) y lee `codcia` | Igual (`SCA2_pBuscarPoliza`) | «consulta en Autemis a 13 posiciones» |
| 3 | `codcia` 1, 10 o 14 → wAutemis; 41 → NSE Autos | Igual | «si hay datos, Autemis» |
| 4 | Cualquier otro caso, también sin datos → Vida Riesgo | Igual | «si no, Vida con 10 dígitos» |

- [Observado] Diferencias con la descripción: no se exige que la póliza tenga ya 13 posiciones (se rellena); `873` también es NSE Hogar; en el paso 3 decide el `codcia` (41 = NSE Autos), no solo que haya datos.
- [Observado] Datos de póliza: wAutemis → `SCA2_consultarPolizas`; Vida → `SCA2_consultarPolizaVidaRiesgo(numPoliza: ri!poliza)` con el número tal y como queda en el popup (relleno a 13); NSE → `SCA2_pObtenerPolizaFecha` (cía 41, y reintento con fecha mañana si no hay datos). [Pendiente] Confirmad si la consulta Vida debe recibir 10 dígitos en lugar de 13; la conversión de la clave Vida es de R46-A.

### 3.7 COMPROBAR AHORA y espera de respaldo de 90 s (dudas 28 y 30)
- [Observado] Tras GUARDAR, `SCA2_AltaSolicitudPage` lanza el proceso de alta con `isSynchronous: true`. Mientras Appian espera (su límite síncrono es de unos 30 s) se ve el indicador de carga de Appian y no se puede pintar ningún botón: por eso COMPROBAR AHORA no puede aparecer en la espera síncrona.
- [Observado] Si Alta + Decidir + CrearAcción terminan dentro de ese tiempo (lo normal: 15–20 s; C6 de esta ronda), se muestra directamente la siguiente gestión con ACEPTAR.
- [Observado] Si no terminan (`onIncomplete`), la pantalla pasa a la **espera de respaldo**: «Su solicitud se está generando…», consulta la tarea cada 30 s y ofrece **COMPROBAR AHORA**, que hace esa consulta en el momento sin esperar al siguiente refresco (R42-A, 15788715: se actualizó al instante).
- [Observado] El respaldo dura como máximo `SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS` = 90 s; después se habilita ACEPTAR, que lleva al Detalle de la solicitud (ya creada en CORE), desde donde se retoma la gestión cuando el motor termine. Desde R42-A (`SCA2_DetalleTareas` v41) ACEPTAR no abre una gestión que aún no existe.
- [Inferido] 90 s cubren de sobra los 15–20 s habituales; bajarlo solo adelanta el paso al Detalle. Recomendación: mantener 90 s.

### 3.8 Aviso «cerca del vencimiento» (duda 33)
- [Observado] Es una variante del aviso de éxito de la entrega de tréboles en la contra anulación: «Se ha realizado la asignación de tréboles al usuario correctamente.» / «…muy cerca del Vencimiento…», que avisa de que los tréboles se aplican a una póliza a punto de vencer.
- [Observado] Ni en SCA ni en SCA2 llegaba a verse porque el mismo clic cerraba el argumento positivo; en R34-A se retiró al llevar la entrega al ACEPTAR de la enhorabuena (`r34-a-recarga-treboles-enhorabuena.md`, preguntas 4).
- [Pendiente] Si se quiere mostrar antes de la enhorabuena, es parte de tréboles (R46-D), no de R46-C.

### 3.9 Retorno al formulario tras el alta (duda 44, doc 44)
- [Observado] El doc 44 resolvía (a) que el usuario siga o vuelva al formulario tras GUARDAR y (b) el riesgo de doble alta. R35-A ya oculta el formulario y GUARDAR mientras se crea la gestión y el popup detecta la solicitud en curso (ahora con CONSULTAR SOLICITUD → Detalle); R42-A añade la espera síncrona y el respaldo con ACEPTAR → Detalle a los 90 s.
- [Observado] C6: tras GUARDAR no se vuelve al formulario.
- [Inferido] La propuesta queda cubierta por R35 + R42; la única diferencia es que el doc 44 abría el Detalle desde el primer momento y SCA2 muestra la espera en la misma página. No se aplica ningún cambio adicional.

## 4. Dudas nuevas
1. [Pendiente] **Tipo de documento para el enlace NSE:** se deduce del formato del documento (§3.3). ¿Hay un campo de tipo de documento del cliente que debamos usar?
2. [Pendiente] **Perfil control (`CE_MF_CONTROL`):** sigue viendo el aviso Si24 y debe tener la carta para FINALIZAR (como en SCA). ¿Correcto?
3. [Pendiente] **Póliza para Verti → inducción:** las pólizas de acuerdo del bloque R45-C tienen el vencimiento pasado o fuera de los 18 meses de NEW. ¿Nos pasáis una póliza de acuerdo que llegue a CA nivel 2 con una fecha de anulación válida?
4. [Pendiente] **Consulta Vida a 10 dígitos:** ¿SCA pasa a la consulta Vida la póliza con 10 dígitos y SCA2 la pasa con 13 (§3.6)?
