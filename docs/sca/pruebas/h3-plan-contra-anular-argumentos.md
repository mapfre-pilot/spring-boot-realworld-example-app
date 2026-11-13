# H3 — Planes «Contra Anular v2» (35 casos) y «Gestión de Argumentos» (12 casos): SCA vs SCA2 en TEST

Fecha: 13/10/2026. Sesión H3 de la ronda 8 (planes oficiales del analista). Entorno Appian TEST. Usuarios: JJGONZ2 (CE_RM oficina), SISANS (SI24 Experto), `devin` (administrador, único con acceso a «Gestiones mantenimiento» en SCA y SCA2). Pruebas UI ejecutadas por el agente de pruebas con grabación; análisis y correcciones por API LCP siguiendo la skill `appian` (GET vivo → backup → PUT completo → readback → test). Coordinación con las otras sesiones en `coordinacion-ronda8.md`.

## Veredicto

**47 casos: 24 OK, 4 divergencias corregidas, 3 divergencias pendientes, 16 no probados.** Contra Anular: 17 OK, 1 corregida (recarga de argumentario), 3 pendientes (posposiciones/finalización SI24, impresión SI24, observación en el Detalle), 14 no probados (argumentos de campaña TTQ/PREMFIDE/RETOS/SVA/descuento, pólizas telemáticas/Ford/Bankia/corredor/Más Móvil/Verti/contacto y DNI obligatorio: no existen en TEST con las pólizas asignadas). Gestión de Argumentos: 7 OK, 3 corregidas (la búsqueda devolvía resultados cacheados tras modificar), 2 no probados como alta en SCA2 (los argumentos de prueba se dieron de alta desde SCA por error del agente; la BBDD es compartida y se usaron para el resto de casos; ambos quedan **inactivos** en las dos aplicaciones).

**Limitación principal:** SCA TEST no abrió la Contra Anulación de la póliza B (GUARDAR > 90 s, el Detalle sólo muestra «Alta Finalizada») y el flujo E no se ejecutó; los casos marcados «OK» en Contra Anular se han validado en SCA2 contra la descripción del plan y la paridad de diseño con SCA (misma lógica SAIL), no pantalla a pantalla con SCA. Las 6 correcciones son exclusivas de SCA2 y están re-probadas en UI.

Grabación: `h3-ga-fix2-final` (persistencia y limpieza de Gestión de Argumentos tras la corrección). Capturas (locales, no versionadas): `~/sca2work/h3-evidence/ca-XX-*.png`, `ga-XX-*.png`.


## Solicitudes creadas (sólo con las pólizas asignadas)

| Póliza | App | Usuario | Solicitud CORE | Recorrido |
|---|---|---|---|---|
| 0001047017010 (A) | SCA2 | JJGONZ2 | 15787879 | Alta → CA nivel 1: argumentario, cía contraria 3247, catalogación A FECHA, documentos, impresión, observación, POSPONER (×1) → RETOMAR → NEGATIVO → FINALIZAR → mecanización (sin ANULAR PÓLIZA) |
| 0001047017019 (B) | SCA | JJGONZ2 | 15787887 | Alta (GUARDAR > 90 s «procesando»); el Detalle sólo muestra Alta Finalizada, sin CA → SCA no comparable por latencia |
| 0001047017039 (C) | SCA2 | JJGONZ2 | 15787890 | Alta → CA: CANCELAR → No; argumento POSITIVO → «Finalizada positivamente» |
| 0005726680285 (D, RCI) | SCA2 | JJGONZ2 / SISANS | 15787893 | CA1 negativa (JJGONZ2) → CA2 nivel 2 (GGE EXPERTOS SI24); SISANS RETOMAR → POSPONER ×3 → NEGATIVO → FINALIZAR (error de conexión CORE7 `IGenerarContraAnul`; CORE deja la CA2 FINALIZADA NEGATIVA) |
| 0005726679137 (E, RCI) | SCA | — | — | No ejecutado (se priorizó cerrar las correcciones y la limpieza de argumentos); póliza sin solicitud, disponible |

## Plan «Contra Anular v2» (hoja manual_test_2, 35 casos)

Veredictos: **OK** (SCA2 cumple el plan; SCA comparado cuando fue posible, si no «SCA n/c» = no comparable por latencia, con paridad de diseño comprobada por LCP), **CORREGIDA**, **PENDIENTE**, **NO PROBADO**.

| Id | Caso | SCA | SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| 2-1 | Acceso mismo usuario | n/c | RETOMAR de 15787879 abre la CA con compañía, catalogación/fecha, argumento Negativo y documentos recuperados | OK | `ca-01-sca2.png` |
| 2-2 | Acceso distinto usuario | n/c | SISANS sobre la póliza A ve el Detalle en consulta (CA finalizada, mecanización) sin formulario de CA; sobre D (CA2 de su nivel) ve RETOMAR | OK | `ca-02-sca2-a-final.png`, `ca-02-sca2-d-sisans.png` |
| 2-3 | Cambio catalogación y fecha | n/c | A FECHA + 02/02/2027 persisten al posponer/retomar (fecha deshabilitada al retomar, igual que SCA cuando la catalogación ya está fijada) | OK | `ca-03-sca2.png` |
| 2-4 | Compañía contraria | n/c | Lupa → popup con filtros → 3247 ALLIANZ DIRECT; persiste tras POSPONER (record `idcompania 3247` y CORE) | OK | `ca-04-sca2-filtro.png`, `ca-04-sca2.png` |
| 2-5 | Recarga argumentario | n/c (misma lógica SAIL) | **Antes**: RECARGAR ARGUMENTO dejaba la tabla vacía (7 → 0) y bloqueaba NEGATIVO/FINALIZAR. **Después (C2/C3)**: RETOMAR 7 argumentos, RECARGAR mantiene 7 | CORREGIDA | `ca-05-sca2-fix-antes.png`, `ca-05-sca2-fix.png` |
| 2-6 | Orden, prioridad y activos | n/c | 7 argumentos en orden 1–7, Obligatorio SI (INCREMENTO PRIMA) / NO; el servicio GAIA (`consultarListadoArgumentos`) es el mismo que usa SCA y sólo devuelve activos | OK | `ca-06-sca2.png` |
| 2-7 | Ver PDF y aplicación | n/c (integración de descarga idéntica a SCAC) | Ojo de INCREMENTO PRIMA abre el visor con el PDF; iconos de aplicación sin URL configurada no son interactivos (igual que SCA: `SCA2_GetUrlArgumento` = `SCA_GetUrlArgumento`) | OK (parcial: URL externa no disponible en TEST) | `ca-07-sca2.png` |
| 2-8 | Argumentos obligatorios | n/c | FINALIZAR sin obligatorios → aviso «Deben ejecutarse los argumentos obligatorios previamente» | OK | `ca-08-sca2-obligatorio.png` |
| 2-9 | Fin positivo | n/c | 15787890: argumento POSITIVO → modal → «Finalizada positivamente» en buscador y Detalle | OK | `ca-09-sca2-confirmacion.png`, `ca-09-sca2-core.png` |
| 2-10 | Fin positivo TTQ | — | — | NO PROBADO: ningún argumento de tréboles/campaña (DEFCART) en las pólizas asignadas | — |
| 2-11 | Fin positivo PREMFIDE | — | — | NO PROBADO: sin argumento PREMFIDE | — |
| 2-12 | Fin positivo RETOS | — | — | NO PROBADO: sin argumento RETOS (286/287) | — |
| 2-13 | Fin positivo SVA | — | — | NO PROBADO: `obtenerSVADisponibles` sin SVA para el tomador | — |
| 2-14 | Pérdida de descuento | — | — | NO PROBADO: sin argumento de pérdida de descuento | — |
| 2-15 | Ejecutar argumento negativo | n/c | NEGATIVO → fila con estado Negativo, usuario JJGONZ2 y fecha (CORE `mcaEstado 2`) | OK | `ca-15-sca2-a.png`, `ca-15-sca2.png` |
| 2-16 | Finaliza negativo Red Mapfre | n/c | 15787879: aviso → ACEPTAR → «Se va a redirigir a la anulación» → pantalla de mecanización con ANULAR PÓLIZA (no pulsado). RCI 15787893: salta a CA nivel 2 (GGE EXPERTOS SI24) | OK | `ca-16-sca2-a-confirmacion.png`, `ca-16-sca2-a-mecanizacion.png`, `ca-16-sca2-nivel2.png` |
| 2-17 | Paso a experto (telemática) | — | En D (SISANS) FINALIZAR no hace ninguna pregunta (ver D2) | NO PROBADO: sin póliza telemática/telefónica | `ca-17-sca2-finalizar-sisans.png` |
| 2-18 | Paso expertos Bankia/Ford | — | — | NO PROBADO: sin póliza Ford/Bankia | — |
| 2-19 | Paso expertos Corredores | — | — | NO PROBADO: sin póliza de corredor (canal 4/5) | — |
| 2-20 | Posponer una oficina | — | — | NO PROBADO: JJGONZ2 tiene 2 oficinas y SISANS ninguna; no hay usuario con una sola | — |
| 2-21 | Posponer más de una oficina | n/c | Selector de oficinas (MADRID CORREDORES NORTE II / VILLALBA) → POSPONER → confirmación → vuelve al buscador; SGC: CORE `idgestionsgc` informado en posposiciones anteriores (ronda 2), no re-verificado aquí | OK (SGC no re-verificado) | `ca-21-sca2.png`, `ca-21-sca2-modal.png` |
| 2-22 | Posponer sin contacto (SI24, 3 veces) | E no ejecutado; por diseño SCA pregunta «¿Ha podido contactar con el cliente?» (SI/NO) al posponer y, al FINALIZAR tras 2 posposiciones, finaliza «Ilocalizable con/sin contacto» | 15787893 (SISANS): 3 POSPONER con confirmación estándar, sin pregunta de contacto; `contadorPosponer` ahora cuenta 1→2→3 (C1). FINALIZAR no pregunta y cerró la CA2 en CORE como FINALIZADA NEGATIVA; el CMD falló después por conectividad CORE7 (`IGenerarContraAnul`, error en bandeja) | PENDIENTE (D2/D3) | `ca-22-sca2-posponer1..3.png`, `ca-22-sca2-error-core.png`, `ca-22-sca2-final-negativa.png` |
| 2-23 | Imprimir Red Mapfre | n/c | Icono impresora activo en «Carta firmada» (con oficina seleccionada) → plantilla PDF en el visor; CORE registra gestión 4 Impresión (43705429 en D). Fecha de impresión en pantalla no comprobada | OK (parcial) | `ca-23-sca2.png` |
| 2-24 | Imprimir SI24 (no activo) | E no ejecutado; **misma lógica SAIL** (`oficinaSeleccionada` = true si no hay varias oficinas → impresora habilitada) | SISANS en CA2 ve la impresora activa. Tras C4 ya no ve las oficinas de JJGONZ2 | PENDIENTE (duda funcional: SCA se comporta igual por diseño; el plan espera impresora inactiva para SI24) | `ca-24-sca2.png`, `ca-24-sca2-fix-sin-oficina.png` |
| 2-25 | Botón Cancelar → No | n/c | CANCELAR visible (CE_RM nivel 1) → modal → CANCELAR cierra sin cambios | OK | `ca-25-sca2-modal.png`, `ca-25-sca2.png` |
| 2-26 | Botón Cancelar → Sí | — | No re-ejecutado (validado en ronda 2: 15787744 «Cancelada», CORE `mcaEstadoFinal 9`) | OK (evidencia ronda 2) | `13-revision-analista-ronda2.md` |
| 2-27 | Adjuntar documento | n/c | «+» en DNI → PDF subido y visible en el listado | OK | `ca-27-sca2.png` |
| 2-28 | Modificar documento | n/c | Segundo tipo (Carta firmada) adjuntado; ambos listados | OK | `ca-28-sca2.png` |
| 2-29 | Eliminar documento | n/c | DNI eliminado, Carta conservada | OK | `ca-29-sca2.png` |
| 2-30 | Campo observaciones | n/c (en SCA el textarea también arranca vacío al retomar; ronda 2) | Observación guardada en CORE (gestión 43705401) y visible en el buscador; al retomar el textarea está vacío/editable; la tarjeta CA del Detalle muestra «-» pese a existir en CORE | PENDIENTE (Detalle no muestra la observación de la gestión) | `ca-30-sca2.png`, `ca-30-sca2-detalle.png` |
| 2-31 | Obligatoriedad DNI Red Mapfre | — | Finaliza sin DNI sin aviso (no hay configuración «DNI obligatorio» en TEST; en SCA la validación está comentada en SAIL) | NO PROBADO: configuración no disponible | `ca-31-sca2.png` |
| 2-32 | Obligatoriedad DNI SI24 | — | Sin aviso DNI | NO PROBADO: configuración no disponible | `ca-32-sca2.png` |
| 2-33 | Más Móvil | — | — | NO PROBADO: sin póliza Más Móvil | — |
| 2-34 | Inducción Verti | — | — | NO PROBADO: sin póliza susceptible de Verti | — |
| 2-35 | Generar contacto | — | — | NO PROBADO: sin póliza susceptible de contacto vencimiento | — |


## Plan «Gestión de Argumentos» (hoja manual_test, 12 casos) — usuario `devin`

Argumentos de prueba: `PRUEBA_DEVIN_H3_1` (id 981, con PDF) y `PRUEBA_DEVIN_H3_2` (id 982). Nota: el agente los dio de alta desde SCA (sca-site) por error de ventana; la BBDD de argumentos es compartida (mismo servicio `IGestionarArgumentosPCA`), así que se usaron para los casos de SCA2 y **ambos quedan inactivos** en SCA y SCA2 (`ga-final-inactivos-*.png`, `ga-final-activos-*.png` sin resultados).

| Id | Caso | SCA | SCA2 | Veredicto | Evidencia |
|---|---|---|---|---|---|
| 1 | Búsqueda sin obligatorios | Alerta de Línea de negocio obligatoria | Igual | OK | `ga-01-sca.png`, `ga-01-sca2.png` |
| 2 | Búsqueda por línea | Listado | Listado | OK | `ga-02-*.png` |
| 3 | Fecha de modificación futura | «No hay datos» | Igual | OK | `ga-03-*.png` |
| 4 | Combinaciones de filtros | Coherentes | Coherentes (tras C5/C6) | OK | `ga-04-*.png` |
| 5 | Modificar argumento | Consulta nueva muestra `_FIX` y Variable desmarcada | **Antes**: «guardado correctamente» pero BUSCAR volvía a mostrar los valores antiguos (respuesta cacheada). **Después (C5/C6)**: BUSCAR → 981 muestra lo guardado | CORREGIDA | `ga-05-sca-persistencia-fix.png`, `ga-05-sca2-fix2.png` |
| 6 | Modificar actualizando documento | Ver documento → Documento 2 | Actualizar PDF → BUSCAR → Ver documento muestra Documento 2 | CORREGIDA (misma causa) | `ga-06-sca-fix.png`, `ga-06-sca2-fix.png` |
| 7 | Alta: validación de datos | Resalta obligatorios (cancelado) | Igual (cancelado) | OK | `ga-07-sca.png`, `ga-07-sca2.png` |
| 8 | Alta con documento | 981 creado (desde SCA, por error) con PDF visible | Alta no ejecutada en SCA2 (la alta en SCA2 usa la misma regla `SCA2_guardarTipoArg`, port de `SCA_guardarTipoArg`) | NO PROBADO como alta SCA2 | `ga-08-sca-inicial.png` |
| 9 | Visualización documento cargado | Visor OK | Visor OK | OK | `ga-09-*.png` |
| 10 | Alta con referencia nueva | 982 creado (desde SCA, por error) | Alta no ejecutada en SCA2 | NO PROBADO como alta SCA2 | `ga-10-sca-inicial.png` |
| 11 | Alta con referencia existente | Rechazada | «Ya existe el código del argumento indicado»; no se creó un tercero | OK (texto del mensaje distinto al literal del plan en ambas apps) | `ga-11-sca-inicial.png`, `ga-11-sca2.png` |
| 12 | Modificación de distintos campos | Instrucciones/Variable/estado confirmados | Instrucciones «Validación GA12 fix2» persisten tras BUSCAR; desactivación persiste | CORREGIDA (misma causa) | `ga-12-sca-fix2.png`, `ga-12-sca2-fix2.png` |


## Divergencias corregidas en SCA2 (TEST)

| # | Objeto · uuid | Versión | Cambio | Caso(s) | Verificación |
|---|---|---|---|---|---|
| C1 | `SCA2_cargarSolicitud` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | v4 → v6 | La consulta y el mapa `estado` no incluían `contadorPosponer`, por lo que `SCA2 CMD Posponer` escribía siempre 1 y el modal Sí/No nunca veía la 3ª posposición | 22 | `testRule` 15787867/15787747/15787863 → 1 (antes null); 15787893 tras 3 POSPONER → `contadorPosponer = 3` |
| C2 | `SCA2_ContraAnulacionOpciones` · `…_20056435` | v39 → v40 | `local!data` incluye `body: local!body` (petición de argumentos del padre) | 5 | testInterface OK |
| C3 | `SCA2_ContraAnulacionCompaniaCatalogacion` · `…_20060061` | v3 → v4 | RECARGAR ARGUMENTO guardaba en `ri!listaArgumentos` la respuesta completa del servicio (el padre SCA2 ya extrae `listadoArgumentos`) y construía la petición con claves inexistentes en `local!data` → la tabla quedaba vacía y bloqueaba NEGATIVO/FINALIZAR. Ahora reutiliza `ri!data.body` (con cía/catalogación/fecha actuales) y guarda `index(…, "listadoArgumentos", {})` | 5 | UI 15787879: RETOMAR → 7 argumentos; RECARGAR → 7 (`ca-05-sca2-fix.png`) |
| C4 | `SCA2_ContraAnulacionOpciones` · `…_20056435` | v40 → v41 | `local!nuuma` tomaba el NUUMA del record (creador) y sólo después el del usuario logado; SISANS veía las oficinas de JJGONZ2 (selector, impresión, infoUsuario CORE). Ahora el usuario logado con respaldo del record, como `SCA_ContraAnulacionOpciones` | 24, 21 | UI 15787893 (SISANS): desaparece el selector de oficinas (`ca-24-sca2-fix-sin-oficina.png`) |
| C5 | `SCA2_GestionArgumentos` · `…_20053041` | v1 → v2 | Las 3 llamadas a `SCA2_consultarTipoArg` pasan `random: rand()` como SCA | GA-5/6/12 | testInterface OK |
| C6 | `SCA2_consultarTipoArg` · `…_20052550` + integración `SCA2_consultarTipoArgIntegracion` · `ed101238-00f4-46e4-9629-a863ed63747a` | v1 → v3 / v1 → v2 | Input `random` añadido y propagado a la integración (paridad `SCA_consultarTipoArg`/`SCAC_consultarTipoArgIntegracion`): sin él Appian reutilizaba la respuesta cacheada y BUSCAR mostraba los datos anteriores a la modificación | GA-5/6/12 | `testRule` devuelve 981 «PRUEBA_DEVIN_H3_1_FIX» (valor modificado) |

Backups SAIL/JSON antes y después en local (`~/sca2work/h3/`, no versionados).

## Análisis de diseño previo (LCP, 13/10/2026)

Objetos comparados (SCA → SCA2), versión viva al inicio de la sesión:

| SCA | SCA2 | versionId SCA2 | Diferencias relevantes |
|---|---|---|---|
| `SCA_GestionArgumentos` v7 | `SCA2_GestionArgumentos` (`…_20053041`) | 1 | Idéntica salvo que SCA pasa `random: rand()` a `consultarTipoArg` en 3 llamadas (fuerza la recarga del listado tras alta/modificación); SCA2 no lo pasa |
| `SCA_TablaGestionArgumentos` v4 | `SCA2_TablaGestionArgumentos` (`…_20052538`) | 1 | Idéntica (descarga del documento vía `SCA2_descargaDocumentoIntegracion`, plantilla `DOCS_SCA_001`) |
| `SCA_AltaGestionArgumento` v7 | `SCA2_AltaGestionArgumento` (`…_20063439`) | 1 | Idéntica en lógica: tipos CDT → `a!map`, `numDiasSgo` null-safe, usa las constantes `SCA_*` de ramas/compañía/bonificación (lectura), sin `random: rand()` en el visor |
| `SCA_GestionMantenimientoMenu` v6 | `SCA2_GestionMantenimientoMenu` (`…_20060073`) | 1 | Menú con las mismas opciones; visibilidad de la página: SCA `rule!SCA_isUsuarioProceso()` (administradores/rol PROCESO o CONTROL), SCA2 `cons!SCA2_GRP_ADMINISTRADORES`. En TEST sólo `devin` (admin en ambas) ve la página |
| `SCA_ContraAnulacionOpcionesEstrategicas` v9 | `SCA2_ContraAnulacionOpciones` (`…_20056435`) | 39 | Ver hallazgos D1–D3 |
| `SCA_ArgumentosContraAnulacionEstrategicas` v6 | `SCA2_ContraAnulacionArgumentarioEstrategicas` | 2 | Misma tabla; estado por `mcaEstado` con lista local en vez de `cons!SCA_TXT_ESTADO_ARGUMENTO` |
| `SCA_Compa_iaContrariaCatalogacion` v7 | `SCA2_ContraAnulacionCompaniaCatalogacion` | 3 | Port validado en rondas anteriores |
| `SCA_ContraAnulacionModalSiNoEstrategicas` v8 | `SCA2_ContraAnulacionModalSiNo` | 1 | Port completo de los casos 1–6 (corredor, ilocalizables, correspondencia, telemática, acuerdos) pero **nunca se abre** desde SCA2 (ver D2) |
| `SCA_ContraAnulacionModalRetos`/`ModalSVA` | `SCA2_ContraAnulacionModalRetos`/`ModalSVA` | 1 | Idénticas |
| `SCA_ContraAnulacionModalTréboles` | `SCA2_ContraAnulacionSGO` | 1 | Port a `a!cardLayout` |
| PM `SCA Posponer Contra Anulacion` | PM `SCA2 CMD Posponer` | — | SCA incrementa `solicitudAnulacion.contadorposponer`; SCA2 escribe `contadorPosponer + 1` leyendo `sol.estado.contadorPosponer`, que `SCA2_cargarSolicitud` **no devolvía** (ver D1) |

### Hallazgos de diseño

- **D1 (corregida, C1)** `SCA2_cargarSolicitud` no incluía `contadorPosponer` ni en los `fields` de la consulta ni en el mapa `estado`; por eso `SCA2 CMD Posponer` escribía siempre 1 y `SCA2_ContraAnulacionModalSiNo` nunca veía `contadorPosponer = 2` (finalización «Ilocalizable con/sin contacto» a la tercera gestión SI24). Corrección: v4 → v6 (campo añadido a la consulta y al mapa). `testRule`: 15787867 / 15787747 / 15787863 → `contadorPosponer = 1` (antes `null`).
- **D2 (pendiente)** En SCA el botón FINALIZAR abre siempre `SCA_ContraAnulacionModalSiNoEstrategicas` (caso 1 «¿Desea continuar?») y, para perfiles SI24/GGE, el modal encadena las preguntas de corredor / ilocalizable («¿Se ha podido contactar con el cliente?») / correspondencia / telemática / acuerdos, fijando `mcaEstadoFinal` 2/4/6/7/8 y `anulaExpertos`/`anulaTecnicos`. En SCA2 `local!mcaVentanaSiNo` nunca se pone a `true`: FINALIZAR usa un `confirmMessage` estándar y lanza `SCA2 CMD CompletarAccion` con `mcaEstadoFinal 6` directamente; `SCA2_ContraAnulacionModalSiNo` existe pero sólo rellena `ri!datosContraAnulacion`, que nadie consume (en SCA el `submit` del formulario de tarea continúa el PM; en SCA2 la pantalla es una página de site). Afecta a los casos 17, 18, 19, 22 (tercera gestión) y 31/32 del plan para SI24/GGE; para Red Mapfre (CE_RM) el comportamiento es equivalente. Para corregirlo hay que hacer que el modal lance el CMD con los parámetros del padre (idTarea, documentos, `mcaEstadoFinal` resultante), un cambio de diseño que se deja documentado y a decisión del analista.
- **D3 (visual, pendiente)** En SCA el botón POSPONER para perfiles GGE/SI24 muestra su propia ventana «Se va a posponer la solicitud de contra anulación — ¿Ha podido contactar con el cliente?» (SI/NO); la respuesta sólo cambia la variable local `estadoPosponerContraAnul` (10/11), que no se envía a CORE ni al PM (`SCA_posponerCAEstrategicas` siempre envía `mcaEstadoFinal 2`). SCA2 muestra la confirmación estándar «¿Desea continuar?». Sin efecto funcional conocido.
- SCA2 condiciona el modal de regateo (tréboles/retos/SVA) igual que SCA pero sin la comprobación `esRegateable` (SCA: argumento `regateable = "S"` o campaña DEFCART). Sólo observable con argumentos de campaña, no disponibles en las pólizas de la sesión.


## Divergencias pendientes y dudas para el analista (lenguaje de negocio)

1. **Preguntas de SI24 al finalizar/posponer (casos 17, 22; D2/D3).** En SCA, cuando un gestor de SI24/GGE pulsa FINALIZAR, la aplicación le pregunta según el caso («¿Se ha podido contactar con el cliente?», «la póliza es de un corredor…», «¿el cliente insiste en anular por este canal?») y, a la tercera gestión sin contacto, cierra la solicitud como «Ilocalizable». Al POSPONER también pregunta si ha contactado (sin efecto posterior en SCA). En SCA2 FINALIZAR cierra directamente como negativa y POSPONER sólo pide confirmación. *Pregunta:* ¿deben mantenerse exactamente esas preguntas y el cierre «Ilocalizable con/sin contacto» a la tercera gestión? Si sí, SCA2 necesita que el modal Sí/No lance el comando de finalización (cambio de diseño de `SCA2_ContraAnulacionOpciones`/`SCA2_ContraAnulacionModalSiNo`), que no se ha hecho en esta sesión por su alcance.
2. **Impresión para SI24 (caso 24).** El plan dice que un usuario SI24 no debe tener la impresión activa; en SCA y SCA2 el botón sólo se deshabilita si el usuario tiene varias oficinas y no ha elegido una, así que para SISANS (sin oficinas) aparece activo en ambas. *Pregunta:* ¿debe ocultarse la impresión (y la sección «Carta firmada») para SI24/GGE? Si se confirma, se corrige en SCA2 (y queda la discrepancia con SCA).
3. **Observación de la contra anulación en el Detalle (caso 30).** La observación escrita al posponer queda registrada en CORE y se ve en el buscador, pero la tarjeta «Contra Anulación» del Detalle de SCA2 muestra «-». *Pregunta:* ¿debe verse ahí la observación de la gestión (como el histórico de observaciones de SCA)? Pendiente de corregir en `SCA2_DetalleSolicitud`.
4. **Estado tras el error CORE7 en 15787893.** CORE tiene la CA2 FINALIZADA NEGATIVA (SISANS) pero la tarea SCA2 sigue PENDIENTE y la solicitud `PDTE_FINALIZAR` con un error relanzable en `/errores` (`IGenerarContraAnul` no conecta). Es la duda B5 del doc 22 (qué manda cuando CORE y SCA2 no coinciden). Un administrador debería relanzar el error cuando CORE7 responda.

## Limitaciones

- SCA TEST no abrió la Contra Anulación de 15787887 (latencia) y el flujo E (RCI en SCA) no se ejecutó; la comparación pantalla a pantalla con SCA en Contra Anular queda pendiente. La paridad se ha comprobado leyendo el SAIL de ambas aplicaciones.
- No hay en TEST pólizas telemáticas/Ford/Bankia/corredor/Más Móvil/Verti ni argumentos de campaña (tréboles, RETOS, SVA, PREMFIDE, descuento) para las pólizas asignadas; tampoco la configuración «DNI obligatorio».
- Las altas de los argumentos de prueba se hicieron desde SCA por error del agente de pruebas; el alta desde SCA2 (casos GA-8/GA-10) queda sin ejecutar. No se dejó ningún argumento activo.
- Datos modificados en TEST: solicitudes 15787879, 15787890, 15787893 (SCA2) y 15787887 (SCA, sólo alta); argumentos 981/982 (inactivos).

