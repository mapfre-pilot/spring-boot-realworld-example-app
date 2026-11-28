# Ronda 22 — Análisis SCA2 del analista (20/10/2026): cinco hallazgos

Origen: documento «Analisis SCA2.docx» (20/10/2026) con cuatro capturas. Se cruzó cada punto con los objetos vivos de SCA2 TEST y con SCA; los cambios se aplicaron con backup previo, PUT y relectura (workspace `sca2work/r22`, notas en `NOTAS.md`).

| # | Hallazgo del analista | Diagnóstico | Resultado |
|---|---|---|---|
| 1 | AA incompleta sin botón RETOMAR (póliza 0002729296240, solicitud 15788109) | La tarea AA está asignada a quien dio el alta (`estado.usuario` = JOSPENA@mapfre.net, José Enrique Peñarrubia); el Detalle sólo pinta RETOMAR si `asignadoA` = usuario logado, igual que SCA (`SCA_DetalleAnulacionAltaSolicitud`: `touser(local!taskOwner) = loggedInUser()`; la tarea AA de SCA se asigna a `pp!initiator`). Quien miraba (JJGONZ2) no era el propietario. | Sin cambio: paridad SCA. Opción disponible: REASIGNAR. Si los analistas quieren que cualquier usuario de la oficina pueda retomar, es un cambio funcional a decidir. |
| 2 | Bloqueo de póliza en NEW no visible tras ANULAR PÓLIZA (0005726682910, solicitud 15788111) | El nodo «Bloquear póliza en Central (NEW)» (CMD Mecanizar, nodo 340) existe en la rama wAutemis + Emisión 00000005/00000006 y sus entradas para 15788111 son correctas (póliza, CE_RM, JJGONZ2, motivo 1 / detalle 5 / causa 14, 20/10/2026). SCA tampoco comprueba la respuesta del servicio (nodo 20 → 27). | Pendiente de la lectura de `pv!bloqueoCentral` en la instancia (Monitor de Designer) — ver §Pruebas. |
| 3 | Salto a nivel 2 sin nuuma: CORE no crea la gestión (0002729373066, solicitud 15788118, error `CORE_ALTA_GESTION` «Datos insuficientes para la operacion») | Causa propia: R20 #2 dejó `nuuma: ""` en `SCA2_altaGestionCore` para nivel > 1. CORE exige nuuma. | **`SCA2_altaGestionCore` v4 → v5**: vuelve a enviar el nuuma (perfiles / usuario), como SCA. El «-» hasta retomar se mantiene sólo en pantalla (Detalle usa `Tarea.asignadoA`/`fechaCaptura`). |
| 4 | SI24 nivel 1 → mecanizar con `anulaTecnico`/`anulaExperto` = false (0005888549030, solicitud 15788120, CE_MF_SI24_EXPERTO, póliza de acuerdos clase 33) | En `SCA2_ContraAnulacionOpciones` los 7 mapas `resultado` que arrancan CMD CompletarAccion no llevaban las marcas; CompletarAccion grababa `mcaanulatecnico`/`mcaanulaexperto` = "false" (`a!defaultValue`) y `SCA2_mapearDatosDecidirAccion` las enviaba así al motor. Las marcas calculadas (`*Motor`) sólo llegaban al modal. | **`SCA2_ContraAnulacionOpciones` v53 → v54**: cada mapa incluye `anulaExpertos`/`anulaTecnicos` = `a!defaultValue(resultadoModal.x, local!xMotor)`. Probado: Datos Solicitud true/true (15788129). |
| 5 | Corrección funcional: la decisión de contacto y la pantalla de inducción VERTI van **tras la Contra Anulación negativa**, antes de la mecanización; AA y fuera de norma no lanzan contactos ni VERTI | Paridad con `SCA_Mecanizacion` (46 determinarContacto → 44 pantalla Verti/Vencimiento → 5 Detalle Anulación → 20 BloquearPoliza → 28 inducción CMP). R13 lo había montado al revés (confirmación → Verti) por la respuesta anterior. | Rediseño en CMD CrearAccion + 2 pantallas (ver §5). |

## 5. Inducción VERTI tras la Contra Anulación (diseño aplicado)

- **CMD CrearAccion** (lee la acción decidida de `estado.procesoActivo`; idempotente por `version`). Nuevos parámetros `seleccionVerti` (Text) e `idTareaVerti` (Text) y variable `pedirVerti`.
  - «Cargar» calcula `pedirVerti` = sin selección previa **y** la última tarea cerrada de la solicitud es una Contra Anulación **y** `SCA2_determinarContacto` devuelve VERTI o VENCIMIENTO (con las marcas ya grabadas por CompletarAccion, #4).
  - Nodos nuevos: 30 «¿Inducción VERTI previa?» → 31 «Write Tarea VERTI (previa)» (tarea tipo VERTI, `interfazActiva` = VERTI, token `VERTI-PRE`; no toca `procesoActivo`) → 32/39 control de error. Si no procede → 33 «¿Vuelve de VERTI?» → 34 «Write cierre tarea VERTI» (COMPLETADA) → 37/40 control → 35 «¿Inducir Verti sin mecanizar?» → 36 «Inducción Verti (CMP) sin mecanizar» (sólo si la acción decidida no es mecanizar) → 5 «Accion?» (flujo anterior).
  - Nodo 9 (tarea MECANIZAR): `tokenTarea` = `VERTI:<selección>` cuando viene de la pantalla VERTI.
- **`SCA2_VertiVencimientoPrincipal` v11 → v12**: CONTINUAR ya no arranca CMD Mecanizar; arranca CMD CrearAccion con `seleccionVerti` (VERTI / VENCIMIENTO / NINGUNO) e `idTareaVerti`. Mensaje: «Se va a continuar con la solicitud».
- **`SCA2_MecanizacionPrincipal` v16 → v17**: ANULAR PÓLIZA arranca CMD Mecanizar con `verti: false` e `inducirVerti` leído del token de su tarea; ya no llama a `SCA2_determinarContacto` ni crea la tarea VERTI después de la confirmación.
- **CMD Mecanizar**: los nodos 6/7 (tarea VERTI posterior) quedan inertes (`pv!verti` siempre false). Corrección en «Write Éxito»: el cierre de tareas MECANIZAR pendientes (vuelta desde VERTI de R13) excluye la propia `pv!idTarea` (provocaba `WRITE_FAIL` «mismo registro referenciado varias veces», visto en 15788129).
- Hallazgo externo durante el PUT: el subproceso **ANL Alta** (app Anulaciones, desplegada el 20/10 11:51) ya no declara el parámetro `datosCabecera`; se eliminó del nodo 301 de CMD Mecanizar para poder guardar el modelo.

Flujo resultante (CA negativa): FINALIZAR → CompletarAccion (graba marcas) → Decidir → CrearAccion: pantalla «Inducción Verti / Vencimiento» → CONTINUAR → CrearAccion cierra la tarea VERTI y crea la acción decidida (mecanización → «Detalle consulta …» → ANULAR PÓLIZA → bloqueo NEW si wAutemis pendiente → inducción CMP si se marcó → ANL/fin; u otra gestión, con inducción CMP inmediata si se marcó Verti). AA y fuera de norma: sin pantalla VERTI (la última tarea cerrada no es Contra Anulación).

## Objetos modificados en SCA2 TEST

| Objeto | Antes | Después |
|---|---|---|
| `SCA2_altaGestionCore` | v4 | v5 |
| `SCA2_ContraAnulacionOpciones` | v53 | v54 |
| `SCA2 CMD CrearAccion` | 29 nodos | 40 nodos, +3 variables |
| `SCA2_VertiVencimientoPrincipal` | v11 | v12 |
| `SCA2_MecanizacionPrincipal` | v16 | v17 |
| `SCA2 CMD Mecanizar` | — | nodo 13 (filtro) y nodo 301 (sin `datosCabecera`) |

## Pruebas

Ver `pruebas/r22-pruebas.md` (testing agent, datos nuevos). Resumen al cierre de la ronda.

## Pendientes / para el analista

- #1: confirmar si RETOMAR en AA debe ser sólo del propietario (SCA) o de cualquier usuario de la oficina.
- #2: resultado de `pv!bloqueoCentral` en 15788111 (se completa en pruebas) y, si NEW devuelve error, acordar si la mecanización debe detenerse (hoy ni SCA ni SCA2 comprueban la respuesta).
- Tras cerrar la CA, SCA2 vuelve al buscador y la tarea VERTI se retoma desde el Detalle (sin apertura automática); misma mecánica que el salto a CA/AA tras el alta (pendiente de la decisión del doc 34 §1).
- Solicitudes de prueba del analista afectadas por #3/#4 (15788118 en ERROR, 15788120 finalizada sin mecanizar): no se han tocado; 15788118 puede relanzarse desde la bandeja de errores si se desea.

### 8.8 Segunda pasada (tras reinicio de la sesión, 20/10 12:00–14:40)

La sesión se reinició a media ronda y esta segunda pasada volvió a diagnosticar los puntos con LCP; aporta causas adicionales a las de la tabla inicial.

Fuente: `Analisis SCA2.docx` (texto en `sca2work/r22/analisis.txt`, capturas `r22/media/`). Cinco puntos; los cuatro primeros son resultados de
sus pruebas sobre lo aplicado en la ronda 20; el quinto es una corrección funcional del propio analista.

### 8.1 Acciones Administrativas sin botón RETOMAR (póliza 0002729296240 → solicitud 15788109)

**Causa (verificada):** la tarea AA 292 estaba asignada a otro usuario (JOSPENA). En `SCA2_DetalleSolicitud` la fila de botones sólo se mostraba si
`SCA2_puedeGestionarTarea` devolvía true (admin | asignado = usuario | sin asignar y grupo/nivel) y además RETOMAR exigía `asignadoA = loggedInUser()`.
En SCA (`SCA_DetalleAccionesAdministrativas`) RETOMAR y REASIGNAR se ven para cualquiera mientras la gestión siga abierta.

**Corrección:** `SCA2_DetalleSolicitud` v55 → v57: el permiso se evalúa como si la tarea no estuviera asignada (grupo/nivel) y RETOMAR + REASIGNAR se
muestran juntos con la gestión abierta (como SCA).

### 8.2 Bloqueo NEW no visible al pulsar ANULAR PÓLIZA (póliza 0005726682910 → solicitud 15788111)

**Lo que sí ocurrió:** el flujo pendiente de autorizar funcionó entero: ANL 2141 creada a las 10:39 con `OBSERVACIONES=00000005`, autorizada desde la
página de mantenimiento («Autorizada desde SCA2 mantenimiento», 11:04), mecanización actualizada → nivel 2 → finalizada.

**Causa del bloqueo ausente (verificada llamando a la integración con los datos de 15788111):** NEW devolvía HTTP 500, código 4004
`(BLOQUEAR) 01- Parámetro de entrada vacío o inválido - MOTIVO - DETALLE - CAUSA`: el nodo «Bloquear póliza en Central (NEW)» enviaba los códigos CORE
sin traducir ni rellenar (Motivo 1, Detalle 5, Causa 14). NEW/ANL usan los códigos traducidos de 8 dígitos (00000001 / 00000004 / 00000012).

**Corrección:** `SCA2 CMD Mecanizar` nodo 340: el cuerpo se construye desde `SCA2_construirSolicitudAnulacionAnlTraducida` (códigos traducidos,
perfil/nuuma, fecha). Repetida la llamada con los datos corregidos ya no hay error de parámetros; NEW PRE devuelve «Invalid SOAP fault content /
UNKNOWN_ERROR» para esa póliza, que ya estaba anulada a las 11:04. **Falta** verlo con un caso nuevo de Autemis pendiente de autorizar.

### 8.3 Salto a nivel 2: CORE «Datos insuficientes para la operación» (póliza 0002729373066 → solicitud 15788118)

**Causa (verificada):** no era el nuuma vacío (ese cambio ya no estaba en TEST). `SCA2 CMD Decidir` sobrescribe `Datos Perfiles Pca` con el grupo
destino que devuelve el motor (`CE_MF_BK / CE_MF_BK_EXPERTOSI24`) y `SCA2_altaGestionCore` enviaba a CORE ese perfil con el nuuma del finalizador
(JJGONZ2) → CORE lo rechaza. SCA (`SCA_ContraAnulacion`) envía el perfil del usuario que gestiona, con el remap `CE_MF_SI24_EXPERTO → CE_MF_SI24`.

**Corrección:** `SCA2_altaGestionCore` v5 → v6: en nivel > 1 el `infoUsuario` lleva perfil/subperfil del usuario (Datos Solicitud
`canaldeejecucion` / `perfilredmapfre`) + remap SI24 de SCA; nuuma = perfiles.nuuma ?? estado.usuario. El «-» hasta retomar lo da el Detalle
(`SCA2 Tarea.fechaCaptura`, ronda 20).

### 8.4 SI24 + acuerdos: `anulaTecnico` / `anulaExperto` false en el JSON de mecanizar (solicitud 15788120, póliza 0005888549030)

**Causa (verificada):** `SCA2_ContraAnulacionOpciones` sí calculaba true (SISANS es SI24, codClaseAgt = 33) y lo pasaba al modal, pero
`SCA2_ContraAnulacionModalSiNo` (cadena FINALIZAR de la ronda 10) construía su propio resultado con `anulaExpertos/anulaTecnicos` sólo para CCC/CCR y
descartaba los valores recibidos → Datos Solicitud `mcaanulaexperto/mcaanulatecnico = false` → el JSON del motor llevaba false.

**Corrección:** `SCA2_ContraAnulacionModalSiNo` v5 → v6: fuera de CCC/CCR toma `ri!data.anulaExpertos / anulaTecnicos` (los calculados en Opciones).

### 8.5 Corrección funcional del analista: inducción VERTI tras la Contra Anulación, no en Mecanización

Texto del analista: «El servicio de decisión contacto se tiene que lanzar después de la contra anulación finalizada negativa al igual que el servicio de
decisión de mecanizar y montar la pantalla de selección de inducción a VERTI tras la contra anulación. Tras seleccionar las opciones de la pantalla de
inducción VERTI, se navega o no a la mecanización dependiendo de lo que devolvió Mecanizar. Tras la finalización de las acciones administrativas y la
anulación fuera de norma no se lanza el servicio de contactos, sólo el de reglas de mecanizar. La inducción a VERTI sólo desde contra anulación.»

Diseño previsto (pendiente de implementar y probar; ver `r22/NOTAS.md` §P5): `SCA2 CMD CrearAccion`, al venir de una Contra Anulación negativa,
llama a `SCA2_determinarContacto`; si hay VERTI/VENCIMIENTO crea la tarea VERTI (token `CA:<acción>|<destino>|<nivel>`) antes de crear la de
mecanización; la pantalla Verti, al CONTINUAR, lanza la inducción (CMP) si procede y reanuda `CrearAccion` con la acción decidida (MECANIZAR → pantalla
de mecanización; otra → nivel/fin). `SCA2_MecanizacionPrincipal` deja de mostrar/lanzar la inducción (sólo confirmación + ANULAR PÓLIZA);
AA y Anulación fuera de norma no llaman a contacto.

### 8.6 Objetos tocados en esta ronda
| Objeto | Tipo | Versión | Cambio |
|---|---|---|---|
| SCA2_DetalleSolicitud | Interfaz | v55 → v57 | RETOMAR/REASIGNAR con gestión abierta aunque la tarea esté asignada a otro |
| SCA2 CMD Mecanizar | Proceso | nodo 340 | Bloqueo NEW con códigos traducidos de 8 dígitos (ANL traducida) |
| SCA2_altaGestionCore | Regla | v5 → v6 | Nivel > 1: perfil/subperfil del usuario + remap SI24 (paridad SCA) |
| SCA2_ContraAnulacionModalSiNo | Interfaz | v5 → v6 | Usa anulaExpertos/anulaTecnicos calculados por Opciones fuera de CCC |

Backups antes/después en `sca2work/r22/`.


### 8.7 Pruebas UI de la segunda pasada (testing agent, R22 A/B/C)
- A (RETOMAR AA, 15788109, JJGONZ2): PASA con Detalle v57 (con v56 seguía oculto por `SCA2_puedeGestionarTarea`).
- B (relanzar error 98 de 15788118 con altaGestionCore v6): el relanzamiento no da error, pero `CMD CrearAccion` (ya con la lógica VERTI previa de §5) creó la tarea VERTI 303 (`VERTI-PRE`) en lugar de la Contra Anulación de nivel 2 → no concluyente para #3; hay que continuar desde la pantalla VERTI de 15788118.
- C (SI24 + acuerdos): ver `pruebas/r22-pruebas.md`.
