# R9-C — Acciones Administrativas y SI24 (ronda 9, respuestas del analista B7)

Sesión R9-C. Entorno Appian TEST (`mapfrespain-test`). Referencia funcional: SCA; aplicación corregida: SCA2. Fecha: 2026-10-13.

Respuesta literal del analista (doc 24, B7): «Esta funcionalidad está pendiente de definir: 1) la pregunta de insiste en anular técnico debe desaparecer salvo para los perfiles CCC y solo se enviará valor a reglas para los perfiles CCC. 2) SI24 ya no debe ejecutar determinadas causas de Acción Administrativa: 13 Seguro regalado por compra de coche, 14 No voy a comprarme otro coche, 31 Venta con Reemplazo (Hogar), 32 Venta sin Reemplazo (Hogar), 16 Baja vehículo, 17 Baja temporal, 18 Siniestro total, 28 Anulación fuera de norma. 3) Si una póliza de acuerdos está en nivel 1 y debe tratarla SI24, Red Mapfre debe ver un mensaje informativo y no debe anularla. 4) Si una solicitud está pendiente de SI24, el Detalle debe mostrar un mensaje indicando que la gestiona SI24 (lo hace R9-B). 5) No debe enviarse gestión al CUE en esos casos. Faltan los textos definitivos de los mensajes.»

## 1. Resumen de decisiones del paquete

| Ref. doc 25 | Qué decía el analista | Qué hacía SCA2 antes | Qué hace SCA2 ahora | Cómo se probó (SCA / SCA2) | Veredicto |
|---|---|---|---|---|---|
| B7-causas | SI24 ya no ejecuta las causas de AA 13, 14, 16, 17, 18, 28, 31, 32 | La lista de causas del alta venía tal cual de CORE (`consultarCausa`), sin filtro por perfil: SISANS veía Baja vehículo/Baja temporal/Siniestro total, Seguro regalado/No voy a comprarme otro coche… | `SCA2_consultarCausa` elimina esas 8 causas cuando el perfil es SI24 (`SCA2_datosPerfilesPcaSi24`). Red Mapfre no cambia. | LCP: regla probada con `codPerfil` CE_MF_SI24 vs CE_RM para todas las combinaciones motivo/detalle de Autos. UI: alta en SCA2 con SISANS (desplegable Causa vacío en Baja de vehículo y Venta del vehículo; 3 causas en Precio) y con JJGONZ2 (todas visibles); alta en SCA con SISANS (SCA no filtra). | OK (diferencia deliberada con SCA: SCA no oculta nada; CORE tampoco filtra por perfil) |
| B7-insiste | La pregunta «¿insiste en anular?» desaparece salvo para perfiles CCC; sólo se envía valor a reglas para CCC | `SCA2_ContraAnulacionModalSiNo` (copia de SCA) mostraba la pregunta en los casos 4 (correspondencia/telefónico), 5 (telemática) y 6 (acuerdos) a perfiles GGE y SI24 (Experto/Front); `anulaTecnicos`/`anulaExpertos` se informaban siempre (datos del productor o respuesta «Sí» del modal) | La pregunta y sus tres variantes sólo se muestran a perfiles CCC/CCR (`codPerfil` = CE_MF_RECIBOS o subperfil CE_MF_RECIBOS_CCC / CE_MF_RECIBOS_CCR). `anulaTecnico`/`anulaExperto` enviados al motor (listado de argumentos, CMD de completar acción y POSITIVO/NEGATIVO) van vacíos (null) para el resto de perfiles | LCP: render de `SCA2_ContraAnulacionOpciones` (solicitud 15787870) y del modal con perfil CCC sin errores. UI: alta telefónica con SISANS en SCA (0001047017055) y SCA2 (0001047017047), argumento NEGATIVO + FINALIZAR: ver §3 | Ver §3 (diferencia deliberada con SCA: SCA sigue preguntando a SI24/GGE) |
| B7-acuerdos | Póliza de acuerdos en nivel 1 que debe tratar SI24: Red Mapfre ve un aviso y no la anula; sin gestión al CUE | `SCA2_ContraAnulacionOpciones` ya mostraba (ronda 8, paridad con SCA Estratégicas) el aviso «Esta poliza es de un acuerdo que trata SI24…» a todos los perfiles, sin bloquear nada | **Sólo el aviso**: para usuario Red Mapfre (CE_RM) con solicitud en nivel 1 y póliza de acuerdo (clase de agente 33/56/97/49/80/69 o acuerdo de la lista de SCA) el aviso pasa a «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.» **(texto provisional, pendiente del analista)**. El bloqueo de POSITIVO/NEGATIVO/FINALIZAR se implementó (v42) y **se retiró** (v43) tras la incidencia de R9-E: la lista de clases de agente incluye a las RCI (solicitud 15787911), cuyo salto a SI24 lo decide el motor tras el NEGATIVO de nivel 1. Como SCA, SCA2 no bloquea | LCP: render sin errores (15787870, 15787911). UI: NO PROBADO — ninguna póliza R9-C es de acuerdo | Aviso implementado; **bloqueo NO implementado — pendiente de decisión** (criterio «debe tratarla SI24» = motor, no lista) |
| B7 (AA con pólizas nuevas) | — (verificación SCA vs SCA2 del flujo AA) | — | — | UI: altas Más Móvil (SCA 0732400092972 / SCA2 0732400080727, causa Baja vehículo) y wAutemis (SCA 0001047017048 / SCA2 0001047017052, causa Baja temporal); catalogación, documentación, POSPONER/RETOMAR, FINALIZAR. Origen FDC: NO PROBADO (doc 25 §2) | Ver §3 |

## 2. Divergencias corregidas (objetos SCA2 modificados)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_consultarCausa` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050906` | 1 → 2 | Tras convertir la respuesta de CORE, si `SCA2_datosPerfilesPcaSi24(codPerfil)` es SI24 se eliminan de `MSSConsultarCausa` las causas 13, 14, 16, 17, 18, 28, 31, 32. Único consumidor: `SCA2_AltaSolicitudPage` (reservada por R9-A; por eso el filtro se hizo en la regla). Sólo se dispone del `codPerfil` (en SCA2 todos los grupos SI24 producen `CE_MF_SI24`). |
| `SCA2_ContraAnulacionModalSiNo` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052807` | 1 → 2 | Nueva `local!esCCC` (perfil CE_MF_RECIBOS o subperfil CE_MF_RECIBOS_CCC/CCR). Casos 4, 5 y 6 condicionados a `esCCC` en lugar de GGE/SI24. Todos los `anulaExpertos`/`anulaTecnicos` que se guardan en `datosContraAnulacion` (incl. la respuesta «Sí» = true) pasan a `if(esCCC, valor, null)`. |
| `SCA2_ContraAnulacionOpciones` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | 41 → 42 → 43 | v42: `local!esCCC`; `local!anulaTecnicos`/`anulaExpertos` (del productor) y los `mcaanulaexperto`/`mcaanulatecnico` enviados en POSITIVO/NEGATIVO sólo se informan si `esCCC` (resto null) — afectan al body de `SCA2_consultarListadoArgumentos`, al CMD Completar acción y al modal. `local!bloqueoAcuerdoRedMapfre` = acuerdo SI24 ∧ `codPerfil` CE_RM ∧ nivel 1 → texto provisional del aviso (v42 además deshabilitaba POSITIVO/NEGATIVO/FINALIZAR). v43: se retira el `disabled` de los tres botones (incidencia RCI 15787911 de R9-E); queda sólo el aviso. |

Backups SAIL antes/después guardados en local (`~/sca2work/obj/backup_*.json`, `*_NUEVO.sail`), no en el repo. SCA, SCAC, CORE no se han tocado.

### Perfiles CCC/CCR encontrados
- Constantes SCA2: `SCA2_GRP_CE_MF_RECIBOS_CCC` (grupo `SCA_CE_MF_RECIBOS_CCCold`), `SCA2_GRP_CE_MF_RECIBOS_CCR`, y sus `_TEST`. `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado` devuelve `codPerfil` = `CE_MF_RECIBOS` y `codSubPerfil` = `CE_MF_RECIBOS_CCC` o `CE_MF_RECIBOS_CCR` para esos grupos. En SCA sólo se usa `CE_MF_RECIBOS_CCC` (panel de catalogación); se ha incluido también CCR por ser el mismo perfil Recibos. **Pregunta funcional**: ¿CCR debe tratarse igual que CCC para la pregunta «¿insiste?»?
- Perfiles SI24 (misma detección que `SCA_ContraAnulacionOpciones`): `CE_MF_SI24`, `CE_MF_BK_EXPERTOSI24`, `CE_MF_SI24_SA`, `CE_MF_SI24_TECNICO`, `CE_MF_SI24_EXPERTO`, `CE_MF_SI24_FRONT` (regla `SCA2_datosPerfilesPcaSi24`). SISANS = perfil `CE_MF_SI24`, subperfil `CE_MF_SI24_EXPERTO`.

### Comprobaciones LCP de causas (regla `SCA2_consultarCausa`, línea Autos)
| Motivo/Detalle | CE_RM (antes = después) | CE_MF_SI24 antes | CE_MF_SI24 después |
|---|---|---|---|
| 2 Desaparición del riesgo / 7 Baja de vehículo | 17, 16, 18 | 17, 16, 18 | (vacío) |
| 1 Decisión de cliente / 5 Venta del vehículo | 14, 13 | 14, 13 | (vacío) |
| 1 / 1 Precio | 1, 3, 2 | 1, 3, 2 | 1, 3, 2 |
| 1 / 9 Asegurado no desea seguro | 30, 29 | 30, 29 | 30, 29 |
| 4 Decisión de la entidad / 9 | 28, 26, 27 | (CORE no devuelve nada a SI24) | (vacío) |

Nota: la causa 28 ya no la devuelve CORE a SI24 ni a GGE; 31/32 (Hogar) no se han podido comprobar en TEST (sin pólizas Hogar en el reparto), pero el filtro es por código.

## 3. Pruebas UI (SCA vs SCA2)

Grabación anotada: `r9c-ui-edited.mp4` (agente de pruebas, usuarios SISANS y JJGONZ2). Capturas: ver §7.

| Esc. | App / usuario | Qué se hizo | Resultado |
|---|---|---|---|
| A1 | SCA2 / SISANS | Alta con 0001047017041 (sin guardar): Desaparición del riesgo → Baja de vehículo; Decisión de cliente → Venta del vehículo; → Precio | Causa **vacía** en Baja de vehículo y en Venta del vehículo; Precio muestra las 3 causas | **OK** |
| A2 | SCA / SISANS | Mismos pasos | Baja de vehículo 3 causas (Baja temporal, Baja vehículo, Siniestro total), Venta 2, Precio 3 | OK — SCA no filtra (**diferencia deliberada**) |
| A3 | SCA2 / JJGONZ2 | Mismos pasos | Baja 3 causas, Venta 2 | **OK** (Red Mapfre no filtrado) |
| B1 | SCA / SISANS | Alta telefónica 0001047017055 → solicitud **15787907**; abrir Contra Anulación | El alta queda «Aún procesando» >3 min; al abrir/retomar: «Ha ocurrido un error / Failed to fetch» | **SCA no comparable por latencia** (no se pudo ver si SCA pregunta «¿insiste?») |
| B2 | SCA2 / SISANS | Alta telefónica 0001047017047 → solicitud **15787910**; Contra Anulación: argumento INCREMENTO PRIMA → NEGATIVO, plantilla, FINALIZAR («Se va a finalizar la gestión de contra anulación» → CORRECTO) | **No aparece** ninguna variante de «¿El cliente insiste…?». Bandeja: «Finalizada no requerida contraanulación» | **OK** |
| C1/C2 | SCA y SCA2 / JJGONZ2 | AA Más Móvil (0732400092972 / 0732400080727) | Las pólizas Más Móvil sólo ofrecen motivos «DECISION DE CLIENTE» y «DECISION DE LA ENTIDAD» (no existe Desaparición del riesgo → Baja vehículo). El caso 2-4 del plan exige origen FDC | **NO PROBADO** (datos: origen FDC no reproducible en TEST) |
| C1/C2 alt. | SCA y SCA2 / JJGONZ2 | Decisión de cliente → Asegurado no desea seguro → Ilocalizado, con distintos canales | Ambas apps: «No es posible dar de alta una solicitud presencial con este medio de comunicación. Por favor modifique el medio de comunicación.» SCA con A vencimiento trimestral: error NSE «Tipo de Anulación incorrecto: el producto al que pertenece la póliza no permite esta tipología». SCA2 con Correspondencia/Carta y A vencimiento: aviso **bloqueante** «Si das de alta la solicitud con estos datos, no podrás imprimir la carta de oposición a la renovación para entregar al cliente, ni tendrás acceso a los argumentos.» | Sin solicitudes creadas. Posible divergencia en `SCA2_AltaSolicitudPage` (en SCA ese texto es un aviso, no un error) → **objeto de R9-A: documentado, no corregido** |
| C3 | SCA / JJGONZ2 | Alta wAutemis 0001047017048, Desaparición del riesgo → Baja de vehículo → Baja temporal → solicitud **15787920** | Alta >5 min y «403 Acceso denegado / No tiene permiso para ver esta página»; reabierta desde bandeja sólo muestra «Alta Solicitud» finalizada, sin AA | **SCA no comparable por latencia/403** |
| C4 | SCA2 / JJGONZ2 | Alta wAutemis 0001047017052, misma causa → solicitud **15787922**; AA: oficina «Madrid Corredores Norte II», PDF en «Baja vehículo» y «DNI», FINALIZAR («Se va a finalizar la revisión de acciones administrativas» → CORRECTO) → Consulta New (nivel 00000005, importe −176,96, reserva prima Sí); bandeja: «La Norma 58 deja pendiente esta operación: Esta operación debe ser revisada por la subcentral» | Flujo AA completo en SCA2 (catalogación, documentación, FINALIZAR). No se pulsó ANULAR PÓLIZA. POSPONER/RETOMAR no ejercitados | **OK SCA2** (sin referencia SCA por latencia) |

Comprobaciones CORE/registros (LCP): 15787910 — `SCA2_cargarSolicitud` → `mcaanulatecnico`/`mcaanulaexperto` = "false" en el record Datos Solicitud (valor que fija el alta, `SCA2_construirContextoAlta`, y que `SCA2_mapearDatosDecidirAccion` sigue enviando al motor de decisión: ver pendiente 6). 15787907 (SCA) — `SCA2_consultaGestion`: gestión 8 (Alta) FINALIZADA, nivel 1.

## 4. Solicitudes creadas

| App | Usuario | Póliza | Solicitud | Estado observado |
|---|---|---|---|---|
| SCA | SISANS | 0001047017055 (wAutemis) | 15787907 | Alta finalizada en CORE (gestión 8), nivel 1; Contra Anulación no accesible en SCA (error/latencia) |
| SCA2 | SISANS | 0001047017047 (wAutemis) | 15787910 | Contra Anulación finalizada: «Finalizada no requerida contraanulación» |
| SCA | JJGONZ2 | 0001047017048 (wAutemis) | 15787920 | Alta finalizada; sin AA visible en SCA (403/latencia) |
| SCA2 | JJGONZ2 | 0001047017052 (wAutemis) | 15787922 | AA finalizada (CORRECTO) → Consulta New nivel 00000005; Norma 58 pendiente de subcentral |

Pólizas usadas sin crear solicitud: 0001047017041 (lista de causas), 0732400092972 y 0732400080727 (Más Móvil, altas no completadas). Las demás pólizas R9-C quedan libres.

## 5. Pendientes y preguntas funcionales (lenguaje de negocio)

1. **Textos definitivos**: el aviso de póliza de acuerdo para Red Mapfre es provisional («Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.»).
2. **Criterio «debe tratarla SI24» (bloqueo NO implementado)**: la única lista disponible es la de clases de agente/acuerdos de SCA (33/56/97/49/80/69 y acuerdos 10037931, 10038616, 10016396, 10039853, 10039807, 10043565, 10047605, 10047612, 10048093, 10048133, 10013971), pero incluye a las pólizas RCI, cuyo paso a SI24 lo decide el motor tras el NEGATIVO de nivel 1 (incidencia 15787911 detectada por R9-E). Pregunta: ¿qué pólizas de acuerdo «debe tratarlas SI24» desde el principio (y por tanto Red Mapfre no debe poder anularlas en nivel 1)? ¿Lo marca el motor de decisión (grupo SI24) o hay una lista cerrada distinta de la de RCI? Hasta tenerlo, Red Mapfre sólo ve el aviso y puede seguir gestionando como en SCA.
3. **CCR**: ¿la pregunta «¿insiste?» aplica a CCC y CCR (ambos Recibos) o sólo a CCC?
4. **Pregunta «¿insiste?» para SI24 con origen telemático/telefónico/acuerdos**: ahora SI24 no la ve y el motor recibe `anulaTecnico` vacío. En SCA la pregunta sigue existiendo para SI24/GGE: diferencia deliberada hasta que SCA incorpore el cambio.
5. **Valor «anula técnico/experto» en el alta**: el alta sigue guardando `mcaanulatecnico`/`mcaanulaexperto` = false en la solicitud (valores del productor, `SCA2_construirContextoAlta`) y `SCA2_mapearDatosDecidirAccion` los envía al motor de decisión para todos los perfiles. Lo corregido en R9-C cubre Contra Anulación (listado de argumentos, POSITIVO/NEGATIVO, FINALIZAR). Pregunta: ¿«no se pasará valor a reglas» aplica también a la decisión de acción del alta (enviar vacío en vez de false)? Afecta a objetos del alta (paquete R9-A) y al motor: no se ha tocado.
6. **Causas ocultas**: el filtro está en el alta (único punto de SCA2 donde se elige la causa). CORE sigue devolviéndolas; si un día SI24 debe ver otra causa, basta con quitarla de la lista en `SCA2_consultarCausa`. En `SCA2_AccionesAdministrativasPrincipal` no se elige causa (sólo se muestra), así que no se tocó.

## 6. Limitaciones

- Origen FDC: no reproducible en TEST (doc 25 §2) → NO PROBADO.
- Pólizas de acuerdo: ninguna de las pólizas R9-C es de acuerdo → B7-acuerdos NO PROBADO en UI (sólo render LCP).
- Perfiles CCC/CCR: no hay usuario de pruebas CCC → la rama «sí se pregunta» sólo se ha validado por render LCP del modal con perfil CE_MF_RECIBOS.
- `SCA2_AltaSolicitudPage` estaba reservada por R9-A durante toda la sesión: el filtro de causas se implementó en la regla `SCA2_consultarCausa` (equivalente funcional, único consumidor).
- Latencia de SCA en TEST (ver §3).

## 7. Grabaciones y capturas

- Grabación: `r9c-ui-edited.mp4` (una sola grabación con los escenarios A, B y C).
- Capturas comparadas (SCA → SCA2): causas Baja de vehículo SI24 `ss_bdfb3888` → `ss_75aa7828`; Venta del vehículo SI24 `ss_f521071e` → `ss_b2418c2d`; Precio SI24 `ss_edcaf248` → `ss_d35243e5`; B1 error SCA `ss_00a3d568` → B2 FINALIZAR sin «¿insiste?» `ss_8fae3b1a`; Más Móvil error canal `ss_774d8108` → `ss_9534fc30`; Más Móvil error NSE `ss_a33ef8d5` → aviso bloqueante SCA2 `ss_82bf975c`; C3 403 `ss_1505804f` → C4 AA inicial `ss_ac213524`; C3 detalle sin AA `ss_a6f452c5` → C4 documentación y botones `ss_06ea7046`.
- Otras: A3 Red Mapfre Baja `ss_e2031634`, Venta `ss_6cf4621f`; B2 CORRECTO `ss_e8bab9e1`, bandeja `ss_6de94468`; C4 aviso documental del alta `ss_6526a832`, PDF cargado `ss_60165ce3`, documentos entregados `ss_ffad5f0b`, modal finalizar `ss_1f9bc8fd`, CORRECTO `ss_636f1226`, Consulta New `ss_425af18e`; IDs en bandeja `ss_efbc1a31`.
(Grabación y capturas adjuntas al mensaje final de la sesión; no se suben al repositorio.)
