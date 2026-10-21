# R23-A — Autemis: bloqueo NEW + AUTORIZAR / RECHAZAR / CANCELAR desde mantenimiento (SCA vs SCA2, TEST)

Sesión: https://mapfre.devinenterprise.com/sessions/f7c1e09a292540bda9a8909f099f33a4 · Fechas: 20/10/2026 (tandas 1-3) y 21/10/2026 (tanda 4) · Entorno: Appian TEST (`mapfrespain-test`) · Usuarios: JJGONZ2 (Oficina, SSO NOPRO), SISANS (SI24, sólo relevo), `devin` (página de mantenimiento, acceso básico).

## 1. Resumen ejecutivo

| Pregunta del encargo | Respuesta |
|---|---|
| ¿Funciona el bloqueo NEW corregido (nodo 340) con pólizas nuevas? | **Sí, tras dos correcciones más.** Con los códigos traducidos (R22) el bloqueo seguía fallando por (a) la fecha de anulación —SCA2 guardaba la de vencimiento al elegir «A EFECTO», Emisión respondía `00000004` y no había pendiente de autorizar— y (b) `reservaPrima=S` (fault NEW 4004 «Para realizar reserva de primas la fecha de anulación no puede ser al efecto ni al vencimiento»). Corregidos ambos, NEW responde `200 BLOQUEO SCA. nivelCumplimiento 00000006` en 15788166, 15788168, 15788199 y 15788205 (igual que SCA en 15788167). |
| ¿Completa `ANL Desbloquear`? | **No en PRE.** AUTORIZAR: la fila ANL se actualiza (ESTADO=1, DESBLOQUEO=S), NEW desbloquea (`La póliza ha quedado desbloqueada.`) y el subproceso «Anular Poliza NEW» queda ACTIVE indefinidamente (4 instancias del 20/10 y 2 del 21/10 sin terminar); no llega a «Cierre SGO y STCAT», no hay evento y `CONCLUIDA` sigue `false`. RECHAZAR: el PM termina en 17 s (ESTADO=2, NEW desbloquea), sin instancias de «Cierre SGO y STCAT» ni «Desbloquear proceso principal» y `CONCLUIDA=false`. CANCELAR: no pasa por ANL (CORE codEstado 5 + `CMD Finalizar CANCELADA`), OK. |
| ¿Debe SCA2 esperar CONCLUIDA/evento en vez de ESTADO? | **Sí (decidido por el analista, duda #3) y ya aplicado** en `SCA2 CMD Mecanizar` (nodos 303/304/312). Evidencia del problema: con el criterio antiguo, 15788168 (AUTORIZADA) y 15788166 (RECHAZADA) reanudaron a los 5 min con la póliza aún vigente y CORE quedó «CERRADA SIN MECANIZAR» + Contra Anulación de nivel 2. Con el nuevo criterio, 15788199/15788205 siguen en espera (`contadorRespuestaAnl` 2/1, `concluidaAnl=false`). **Riesgo**: como ANL PRE no marca `CONCLUIDA` ni en autorizar ni en rechazar, terminarán en `ANL_TIMEOUT` a las 24 h de la respuesta (ver §7). |

Veredicto por acción (tandas 3 y 4): **AUTORIZAR** — mantenimiento OK, ANL actualiza y desbloquea en NEW, pero la anulación NEW no concluye (PRE); **RECHAZAR** — mantenimiento OK, ANL actualiza y desbloquea, PM termina sin cierre SGO/STCAT ni CONCLUIDA; **CANCELAR** — OK de extremo a extremo (CORE codEstSolic 4, gestión 7 «FINALIZADA CANCELADA», SCA2 `CANCELADA`, desaparece del listado); la instancia de `CMD Mecanizar` de la cancelada sigue sondeando (fuera de alcance, ya documentado en R19).

## 2. Pólizas y solicitudes (todas nuevas de esta sesión)

| Póliza (`Wautemis a Efecto`) | App | Solicitud | Resultado |
|---|---|---|---|
| 0000253500338 | SCA2 | — | Ya tenía solicitud abierta (otra sesión). |
| 0002729392571 | SCA2 | 15788152 | Tanda 1. «A EFECTO» guardó 08/09/2027 (bug SCA2) → Emisión `00000004` → nivel 2. |
| 0002729392579 | SCA2 | 15788156 | Tanda 1, vía AA venta vehículo sin documentos → vencimiento 10/09/2027 → `00000004` → CORE codEstSolic 5, SCA2 FINALIZADA. |
| 0002729392580 | SCA2 | 15788159 | Tanda 2 (v36): fecAnul 14/09/2026 ✔. CA con aviso «acuerdo especial… debe gestionarla SI24» (acuerdo VW; esperado). SISANS no ve RETOMAR (tarea del grupo CE_RM). Queda EN_ACCION/CONTRA_ANULAR. |
| 0002729392590 | SCA2 | 15788161 | Tanda 2: `00000005` ✔, bloqueo NEW **fault 4004 reservaPrima** (PM v27), ANL 2161. Tanda 3: **CANCELAR** OK. |
| 0007051071638 | SCA2 | — | No ofrece «A EFECTO» (sólo A VENCIMIENTO 20/08/2027 y A FECHA). Saltada. |
| 0001047017096 | SCA2 | 15788164 | Motor de decisión devolvió ERROR tras la CA (`DECISION_ERROR`, reintento automático a los 30 min → «Solicitud Pendiente»). No llegó a mecanizar. |
| 0001047017100 | SCA2 | 15788165 | `00000005` no devuelto (observaciones vacías, «nivel» vacío en pantalla) → nivel 2. |
| 0001047017104 | SCA2 | 15788166 | `00000005` ✔, bloqueo NEW OK (PM v28), ANL 2164. Tanda 3: **RECHAZAR** → «CERRADA SIN MECANIZAR» (criterio antiguo). |
| 0001047017106 | **SCA** | 15788167 | Referencia SCA: A EFECTO 11/09/2026, `00000005`, bloqueo NEW OK con `mcaReservaPrima=N`, SCA Mecanizacion v197 en «Pausar hasta ANL_Desbloquear». CORE acc. 5 «Mecanización Enviada». |
| 0001047017109 | SCA2 | 15788168 | `00000005` ✔, bloqueo OK (numSituacion 4), ANL 2166. Tanda 3: **AUTORIZAR** → «CERRADA SIN MECANIZAR» (criterio antiguo). |
| 0001047017103 / 7112 / 7099 | SCA2 | — | «Póliza no válida o no disponible». |
| 0001047017110 | SCA2 | — | Ya tenía solicitud (15788189, otra sesión). |
| 0001047017114 | SCA2 | 15788199 | Tanda 4 (PM v30): `00000005`, bloqueo OK (numSit 3), ANL 2172. **AUTORIZAR** 14:01:11 → ANL Desbloquear 14351928 (ACTIVE). Mecanizar en espera (criterio nuevo). |
| 0001047017118 | SCA2 | 15788205 | Tanda 4: `00000005`, bloqueo OK (numSit 2), ANL 2173. **RECHAZAR** 14:03:00 → ANL Desbloquear 17484791 COMPLETED (sin cierre). Mecanizar en espera. |

Solicitudes protegidas (15787909, 15787759, 15787911, 15787917, 15788025, 15788118, 15788137, 15788109, 15788111, 15788103, 15788105, 15787878) no tocadas; 15787878 aparece en el listado de mantenimiento y se dejó intacta.

## 3. Objetos SCA2 modificados (GET vivo → backup → PUT completo → re-GET → test)

| # | Objeto | uuid | Versión | Cambio |
|---|---|---|---|---|
| 1 | Interfaz `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | 35 → 36 (otra hija la dejó después en 37; no tocar) | Paridad `SCA_AltaSolicitudAnulacion`: nuevas `local!fechaEfectoInicial` y `local!fechaAnulacionCambio` (1 A EFECTO → fecha efecto anualidad en curso; 2/3 → vencimiento; 4 → fecha del servicio; 5 → trimestral); el `a!dateField` «Fecha anulación» muestra `fechaAnulacionCambio`; en GUARDAR se recataloga por fecha (1/2) y `a!save(local!fechaAnulacion, local!fechaAnulacionCambio)` antes de validaciones/simulación/alta. Antes, al elegir A EFECTO la fecha enviada seguía siendo la del servicio de catalogación (vencimiento). Verificado en UI (7 altas) y en CORE (`fecAnul` 14/09/2026, 06/10/2026…); SCA muestra lo mismo (15788167). |
| 2 | PM `SCA2 CMD Mecanizar`, nodo 340 «Bloquear póliza en Central (NEW)» | `0000f06f-4cfc-8000-66d3-7f0000014e7a` | v27 → v28 | `reservaPrima`: de `if(or(mca="S", mca="Sí"),"S","N")` a `if(tostring(a!defaultValue(pv!mcaReservaPrima,""))="Sí","S","N")` — paridad exacta con `SCA_bloquearPolizaEnCentral(importeRsvPrima: pv!mcaReservaPrima)` → `if(ri!importeRsvPrima="Sí","S","N")`. Antes NEW devolvía fault 4004 (§5). |
| 3 | PM `SCA2 CMD Mecanizar`, nodos 303/304/312 + 2 PV nuevas (`concluidaAnl` Boolean, `contadorRespuestaAnl` Integer) | ídem | v29 → v30 | Duda #3 del analista: 303 guarda además `CONCLUIDA` y `contadorRespuestaAnl` (+1 sólo si ESTADO/DESBLOQUEO informados, si no 0); 304 «Sí» = respuesta informada **y** `concluidaAnl=true`; «Reintentar» = `contadorRespuestaAnl < 288` (sin respuesta espera indefinida como SCA; con respuesta 288×5 min = 24 h); 312 mensaje «ANL no ha concluido el ciclo (Central/NEW/SGO) en 24 h desde la respuesta de autorización/rechazo». |
| 4 | PM `SCA2 CMD Mecanizar`, nodos 331/330 | ídem | v30 (mismo día) | Doc 45 (Verti): 331 «¿Inducir Verti?» = `pv!contacto.listaContactos[].codContacto ∈ {VERTI, VENCIMIENTO}` (antes `pv!inducirVerti`); 330 añade `tipoInduccion: "I"` y `perfilSi24: codperfil ∈ {CE_MF_SI24, CE_MF_BK}` (paridad `SCA_Mecanizacion` nodo 28 sin pantalla). Primer PUT rechazado (400, `contains()` con lista vacía); segundo PUT con `or(a!forEach(...))` OK. |

Nota R23-B: `SCA2_construirConsultaActualizarMecanizacion` **existe y funciona** aunque no esté en ninguna aplicación visible por LCP: el nodo 309 la ejecutó en 15788166/15788168 (`MSEActualizarMecanizacion [idSol,"4",null,"O3IT","","V",infoUsuario]`) y CORE7 respondió `true`. Produce el mismo DTO que `SCA_Finalizar_Mecanización` nodos 5/31 (`codEstMecanizacion = if(cancel,"4", polizaVigente="A","1","4")`, `codEstPoliza = if(polizaVigente="A","A","V")`). Con el criterio nuevo, cuando la póliza ya no esté vigente dará `"1"/"A"` (ANULACIÓN REALIZADA). No se ha creado ninguna regla.

Backups locales (no en repo): `~/sca2work/r23a/backup/` (JSON PRE/POST y SAIL antes/después de cada objeto).

## 4. Paso a paso SCA vs SCA2 (ciclo wAutemis pendiente de autorizar)

| Paso | SCA (15788167) | SCA2 (15788161 / 166 / 168 / 199 / 205) | ¿Igual? |
|---|---|---|---|
| Alta, catalogación A EFECTO | Fecha = efecto anualidad (11/09/2026) | Antes de v36: fecha de vencimiento (15788152 → 08/09/2027). Tras v36: efecto (06/10, 10/09, 11/09, 14/09, 17/09/2026) | Sí tras corrección 1 |
| Servicio de catalogación | Error transitorio 1151 «Could not roll back JDBC transaction… DSRA9110E» en el alta; reintento OK | Mismo servicio REST; reproducido por LCP en el mismo minuto | Sí (externo) |
| Contra Anulación negativa (INCREMENTO PRIMA + plantilla) | OK | OK. Aviso SI24 en póliza de acuerdo VW (15788159), bloqueo para CE_RM nivel 1; SISANS sin RETOMAR | Sí (SCA tiene el mismo aviso); RETOMAR SI24 pendiente de aclarar |
| Pantalla Verti/Vencimiento previa | No aparece | Aparece tras cada CA negativa (R23-C la está ajustando al switch) | No — ya asignado a R23-C |
| Mecanización → ANULAR PÓLIZA | nivel `00000005`, mensaje «…a través de la gestión de la petición de autorización…» | Igual | Sí |
| Bloqueo NEW | `bloquearPoliza ["2","00000006","BLOQUEO SCA.",""]`, `mcaReservaPrima=N` | PM v27: fault 4004 (reservaPrima S). PM ≥ v28: `200 BLOQUEO SCA. 00000006` | Sí tras corrección 2 |
| CORE gestión 5 tras ANULAR | «Mecanización Enviada» | «ANULACION PENDIENTE DE AUTORIZAR» | **No** (etiqueta CORE distinta; ambas UIs muestran «Mecanización Enviada»/Autorización Pendiente). No corregido: contrato CORE / decisión funcional |
| CORE gestión 7 (autorización) | FINALIZADA | FINALIZADA | Sí |
| Fila ANL | 2165: STCAT se crea después | 2161/2164/2166/2172/2173: `COD_OPER_STCAT` informado, `COD_SGO` null, `ESTADO` null, `CONCLUIDA` false | Sí |
| Espera | «Pausar hasta ANL_Desbloquear» (indefinida; la despierta ANL «Desbloquear proceso principal») | Antes: sondeo 5 min con ESTADO/DESBLOQUEO (reanudaba antes de concluir). Ahora: sondeo con `CONCLUIDA` + 24 h desde la respuesta | Sí tras corrección 3 (ver riesgo §7) |
| Mantenimiento | No existe página; la autorización llega por ANL/Autemis | Página opción 6: AUTORIZAR / RECHAZAR / CANCELAR funcionan y lanzan `ANL Desbloquear` | n/a |
| Listado tras ANULAR | «Pendiente» | «Pendiente de Autorización» | Textos distintos (ya conocido) |
| Detalle tras ANULAR | Mecanización wAutemis «ANULACIÓN PENDIENTE DE AUTORIZAR», Autorización PENDIENTE, situación «-» | Igual | Sí |
| Volver desde el Detalle | **Bug SCA**: `sca_datoscabecera` → `a!submitLink [line 23]` «The save target must be a local variable… was: 000…» (3 pólizas) | OK | No (bug de SCA; no se corrige) |

## 5. Faults y respuestas literales de NEW

- **Bloqueo (PM v27, 15788161, 19:54:16 CEST)**: HTTP 500 `soap:Fault` «Error en servicio bloquearPolizaEnCentral», `<codigo>4004</codigo><mensaje>01- Para realizar reserva de primas la fecha de anulación no puede ser al efecto ni al vencimiento.. Entrada new XML: c_NUUMA JJGONZ2, c_Perfil_Usuario CE_RM, c_Reserva_Prima S, lpcAccion BLOQUEAR, lpcFechaEfectoSuplemento 06/10/2026, lpcNumeroPoliza 0002729392590, lpc_Causa 00000002, lpc_Detalle 00000001, lpc_Motivo 00000001</mensaje>`. Causa: `pv!mcaReservaPrima="S"` (la pantalla mostraba «Reserva prima: No» porque para wAutemis pinta `confirReserva` de NEW; el PV sale de `local!mcaReservaPrimaAutos` sin simulación NSE).
- **Bloqueo (PM ≥ v28)**: `200` `<mensaje>BLOQUEO SCA.</mensaje><nivelCumplimiento>00000006</nivelCumplimiento><numSituacion>2|3|4</numSituacion>`; en 15788168 «Existen situaciones posteriores al efecto que no tomarán vigor.BLOQUEO SCA.».
- **Desbloqueo (ANL Desbloquear, autorizar y rechazar)**: `200` `<mensaje>La póliza ha quedado desbloqueada.</mensaje>` (16441015, 675661, 14351928, 17484791). Ya no aparece el M555 de R22/R23 (su causa era el bloqueo fallido).
- **Anular Poliza NEW** (sub `0002eaa5-51a8-8000-b42f-7f0000014e7a`): sin respuesta — instancias 17481373, 14348370, 15414658, 16441021 (20/10) y 14351932 (21/10) ACTIVE sin terminar; `resultAnularNew` null.

## 6. Estados CORE / SCA2 tras cada acción

| Solicitud | Acción (hora CEST) | ANL Desbloquear | Fila ANL | CMD Mecanizar | CORE | SCA2 Solicitud |
|---|---|---|---|---|---|---|
| 15788168 | AUTORIZAR 20/10 21:12:29 | 16441015 ACTIVE v50: Update OK, NEW desbloquea 200, sub Anular NEW 16441021 ACTIVE, `idProcesoDesbloquear=0` | 2166 ESTADO 1, DESBLOQUEO S, CONCLUIDA false | 14348552 (v28) reanudó 21:17:19 con `polizaVigente=V` → actualizarMecanizacion estado 4 | acc. 5 «CERRADA SIN MECANIZAR», acc. 7 FINALIZADA, nueva acc. 2 nivel 2 (43706213) | EN_ACCION / CONTRA ANULAR NIVEL 2 |
| 15788166 | RECHAZAR 21:13:08 | 675661 COMPLETED 19:13:08–19:13:26Z (ESTADO 2); sin instancias de «Cierre SGO y STCAT» ni «Desbloquear proceso principal» | 2164 ESTADO 2, DESBLOQUEO S, CONCLUIDA false | 12244655 reanudó 21:16:57 → estado 4 | acc. 5 «CERRADA SIN MECANIZAR», acc. 2 nivel 2 (43706212) | EN_ACCION / CONTRA ANULAR NIVEL 2 |
| 15788161 | CANCELAR 21:13:57 | no aplica | 2161 sin cambios | 17481426 (v27) sigue ACTIVE sondeando | codEstSolic 4, acc. 7 «FINALIZADA CANCELADA», acc. 5 sigue «ANULACION PENDIENTE DE AUTORIZAR» | CANCELADA / FIN; `CMD Finalizar` 12244768 `estadoFinal=CANCELADA`; desaparece del listado |
| 15788199 | AUTORIZAR 21/10 14:01:11 | 14351928 ACTIVE: Update OK, NEW desbloquea 200, sub Anular NEW 14351932 ACTIVE | 2172 ESTADO 1, DESBLOQUEO S, CONCLUIDA false | 15417971 (v30) **en espera**: contadorAnl 4, contadorRespuestaAnl 2, concluidaAnl false | acc. 5 «ANULACION PENDIENTE DE AUTORIZAR», acc. 7 FINALIZADA | MECANIZADA / VERTI / procesoActivo ANL |
| 15788205 | RECHAZAR 14:03:00 | 17484791 COMPLETED en 17 s (ESTADO 2) sin cierre SGO/STCAT | 2173 ESTADO 2, DESBLOQUEO S, CONCLUIDA false | 13307279 (v30) **en espera**: contadorRespuestaAnl 1 | igual | MECANIZADA / VERTI / ANL; observación de listado «La póliza ha quedado desbloqueada.» |

UI (SCA2 y SCA, M1 y M2 a +7 y +14 min): 15788199/15788205 siguen «ANULACIÓN PENDIENTE DE AUTORIZAR» / Autorización PENDIENTE en ambas apps; bandeja de errores sin filas. Errores SCA2 observados: `DECISION_ERROR` (motor de reglas «Consultar reglas» devuelve `{"accion":"ERROR"}`) en 15788161 (2, continuó) y 15788164 (bloqueó la solicitud hasta el reintento automático).

## 7. Divergencias, correcciones y preguntas abiertas

Corregidas (exclusivas de SCA2): fecha A EFECTO en el alta (#1), `reservaPrima` del bloqueo NEW (#2), criterio de espera a ANL (#3, decisión analista), condición de inducción Verti (#4, decisión analista).

No corregidas / documentadas:
1. **ANL PRE nunca marca `CONCLUIDA`**: en autorizar porque «Anular Poliza NEW» no termina; en rechazar porque el PM termina sin «Cierre SGO y STCAT» ni evento (sub-PMs sin instancias). Con el criterio nuevo, 15788199/15788205 acabarán en `ANL_TIMEOUT` a las 24 h de la respuesta (≈14:01/14:03 del 22/10). **Pregunta**: ¿es aceptable en PRE o debe considerarse concluido el rechazo con ESTADO=2 + evento «No Autorizado»? ¿Quién debe marcar `CONCLUIDA` (ANL «Desbloquear proceso principal» busca el PM de SCA con `SCA_obtenerIdMecanizacionDesbloqueo` → 0/null para solicitudes SCA2)?
2. **`pv!contacto` llega null al nodo 331**: `SCA2_determinarContacto` devuelve `[VERTI, VENCIMIENTO]` para las mismas pólizas (probado por LCP con los inputs del nodo 16), pero en las instancias 15417971/13307279 `pv!contacto` es null (el nodo 16 «Cargar» se ejecuta cuando `pv!sol` aún no está cargado: `sol` sólo se guarda en 308/325). Consecuencia: la rama positiva de la corrección #4 **no queda verificada** (no se lanzó ningún `CMP Inducir Cliente` para 15788199/15788205; los 4 CMP del 21/10 son de 0005726683419, otra sesión). La rama negativa (contacto vacío → no induce) sí. Propuesta: cargar `sol` antes de `contacto` en el nodo 16 o evaluar `SCA2_determinarContacto` en el propio 331. Pendiente de confirmar con R23-C (dueña de `CrearAccion`) que el contacto no deba venir como parámetro.
3. Etiqueta CORE de la gestión 5 tras ANULAR: SCA «Mecanización Enviada» vs SCA2 «ANULACION PENDIENTE DE AUTORIZAR» (duda #5 del analista, ligada al estado final). No se toca sin decisión.
4. SISANS no puede RETOMAR la CA de una póliza de acuerdo SI24 abierta por Oficina (tarea del grupo CE_RM). SCA muestra el mismo aviso; comportamiento esperado de la tarea pendiente de definir.
5. Motor de decisión (`CMD Decidir`/«Consultar reglas») devuelve ERROR intermitente (15788161, 15788164); reintento automático a los 30 min lo resuelve. Externo.
6. Servicio de catalogación: error transitorio 1151/DSRA9110E (ambas apps). Externo.
7. Bug SCA «Volver» (`sca_datoscabecera` a!submitLink). No se corrige (SCA).
8. La instancia de `CMD Mecanizar` de una solicitud CANCELADA sigue sondeando ANL (R19, fuera de alcance).
9. CORE `fecAnul` de 15788165 quedó «04/09/2026 02:00:00» (componente horario de `fechaEfecto`); el resto 00:00:00. Revisar `todate()` en la nueva `fechaAnulacionCambio` si se repite.
10. Las observaciones del listado SCA2 muestran códigos motivo/detalle/causa traducidos (1/1/2) frente a los elegidos (1/1/1): es la traducción `SCA2_obtenerTraduccionMotivosSca`, no un error.

Duda #4 (CE_MF_BK es perfil SI24): sin cambios, conforme a lo indicado.

## 8. Limitaciones

- No se ha consultado Emisión/Consuweb directamente; el «Núm. Situación Autemis» permanece «-» en todas.
- La verificación final del criterio nuevo (reanudación tras `CONCLUIDA`) no puede observarse en PRE porque ANL no concluye; sólo se ha comprobado que **no** reanuda con ESTADO/DESBLOQUEO.
- La corrección #4 (Verti) sólo verificada en su rama negativa (ver §7.2).
- Las tandas 1-3 se hicieron con pólizas de la lista; 3 pólizas no válidas en CORE y 2 con solicitud previa de otras sesiones.

## 9. Evidencias (no incluidas en el repo; adjuntas en el mensaje final de la sesión)

- Grabaciones: `sca2-r23a-jjgonz2-edited.mp4` (tanda 1), `sca2-r23a-tanda2-edited.mp4` (tanda 2), `sca2-r23a-tanda4-edited.mp4` (tanda 4). La tanda 3 (mantenimiento 20/10) quedó en vídeo bruto (`sca2-r23a-tanda3-raw-*.mkv`) por la suspensión de la máquina; sus 34 capturas sí se conservan.
- Capturas (122 + 34 + 71) por póliza/solicitud/paso; informe del agente de pruebas `sca2-r23a-informe.md`.
