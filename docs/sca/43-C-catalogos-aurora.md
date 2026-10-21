# 43-C. Catálogos del CORE como records de tablas en Aurora (fase 1, sesión C)

**Fecha:** 21-10-2026 · **Entorno:** Appian TEST, aplicación SCA2 · **Estado:** construido y probado en TEST (HITO 1 aprobado; carga, reglas con interruptor y página de mantenimiento hechas). Constante `SCA2_USAR_CATALOGOS_AURORA` = **false**: las pantallas siguen leyendo de CORE hasta que el coordinador decida activarla.

Decisión del usuario (doc 41 §3 ajustado, doc 42 fila C): los catálogos cambian poco → **records de tablas** en la BD de SCA2 (Aurora PostgreSQL, data source `SCA2 DataBase AWS`, esquema `sca2_anulaciones`, el mismo que usa `SCA2 Solicitud`), con **carga inicial** desde CORE por las integraciones SOAP que ya existen, **sin sincronización periódica**, editables desde una página nueva de *Gestiones de mantenimiento*. CORE no se toca; las interfaces consumidoras no se tocan: el cambio va detrás de las reglas `SCA2_consultar*`, manteniendo firma y estructura de salida, tras la constante `SCA2_USAR_CATALOGOS_AURORA` (= false).

## 1. Qué devuelve hoy cada operación (verificado en TEST, 21-10-2026)

| Regla (versión) | Entrada | Salida (CDT) | De qué depende la lista en CORE | Consumidores |
|---|---|---|---|---|
| `SCA2_consultarMotivo` (v1) | `infoUsuarioDTO` (codCiaUsuario, nuuma, codPerfil, codSubPerfil), `codLineaNegocio` (Int) | `consultarMotivoResponse.MSSConsultarMotivo[]` = `tipoElementoBasicoDTO {codigo, descripcion}` | **línea de negocio + pareja (perfil, subperfil)**. LN1 CE_RM/CE_RM_OFICINA → 1,4,2; CE_MF_SI24/CE_MF_SI24_EXPERTO y CE_MF_BK/CE_MF_BK_EXPERTOSI24 → 1,2 (sin 4 «DECISION DE LA ENTIDAD»); pareja no reconocida → vacío. codCia 1 ó 41 no influye. LN2 → 1,4; LN3 → 1; LN ≥ 4 → vacío. Orden alfabético por descripción. | `SCA2_AltaSolicitudPage` |
| `SCA2_consultarDetalle` (v1) | `codMotivo` (Text), `codLineaNegocio` (Int) | `consultarDetalleResponse.MSSConsultarDetalle[]` (`tipoElementoBasicoDTO`) | **línea de negocio + motivo** (LN1 M1 → 9,6,4,1,2,3,5; LN2 M1 añade 10 y quita 5; LN3 M1 → 9,4,1,2,10; M4 → 9; M2 → 7). Sin LN → vacío. | `SCA2_AltaSolicitudPage` |
| `SCA2_consultarCausa` (v2) | `codMotivo`, `codDetalle`, `codPerfil`, `codLineaNegocio` (Text) | `consultarCausaResponse.MSSConsultarCausa[]` (`tipoElementoBasicoDTO`); la regla además oculta a SI24 las causas 13,14,16,17,18,28,31,32 | **LN + motivo + detalle + perfil** (CE_RM todo; CE_MF_SI24 M2D7 → vacío y M4D9 → vacío; CE_MF_BK M2D7 → 17,16,18; perfil desconocido/vacío → vacío) | `SCA2_AltaSolicitudPage` |
| `SCA2_consultarTipoArg` (v5) | `mseConsultarTipoArgDTO {codEstado, desc, fechaMod, idLineaNegocio}` | `consultarTipoArgResponse.MSSConsultarTipoArg[]` = `detalleTpArgDTO` (24 campos) | Catálogo único de **343** tipos (`codTpArg` único). Filtro CORE: `desc` obligatorio («contiene», sin mayúsculas, `%` comodín; sin `desc` → vacío), `codEstado` igualdad (S/N), `idLineaNegocio` igualdad (1/2/3 ↔ idRamo 200/73/101), `fechaMod` `dd/MM/yyyy` = fecha de `fecModificado`. | `SCA2_ContraAnulacionOpciones`, `SCA2_GestionArgumentos`, `SCA2_AltaGestionArgumento` |
| `SCA2_consultarConcepto` (v1) | `mseConsultarConceptoDTO {tipoBusqueda, idConcepto, infoUsuario}` | `consultarConceptoResponse.MSSConsultarConcepto.listadoConceptos[]` = `conceptoDTO {idnConceptoPca, desConceptoPca, mcaInh, fecActu, valoresConcepto[] = valorConceptoDTO {idnPca, idnConceptoPca, valorConcepto, desConcepto, mcaInh, fecActu}}` | `tipoBusqueda 0` + id vacío → cabecera de **17** conceptos (0..14, CAMP, URL); `tipoBusqueda 1` + id → el concepto con sus valores (**100** valores en total). El perfil no influye. | `SCA2_GestionConceptosYClases`, `SCA2_ValoresConceptoGestionConceptosyClases`, `SCA2_AnadirGestionConceptosyClases`, `SCA2_EliminarValorConcepto`, `SCA2_consultarConceptoReutilizable` (CAMP, URL, TRSGO), `SCA2_AltaGestionArgumento`, `SCA2_GetUrlArgumento` |
| `SCA2_obtenerOficinasFisicasNuuma` (v1) | `nuuma` | `obtenerOficinasFisicasNuumaResponse.MSSObtenerOficinasFisicasNuuma {COD_RETORNO, LISTA_OFICINAS[] = bdecoPcaS (28 campos)}` | **Depende del usuario** (estructura comercial BDEC del nuuma): JJGONZ2 → 2 oficinas, PCARAGE → ninguna. | `SCA2_AccionesAdministrativasPrincipal`, `SCA2_AnulacionFueraNormaPrincipal`, `SCA2_ContraAnulacionOpciones` |

**Oficinas (BDEC) — propuesta: fuera del alcance.** No es un catálogo sino la asignación oficina↔gestor de la estructura comercial: no existe una lista finita de combinaciones que cargar (habría que cargar todos los nuumas), cambia con altas/traslados de gestores y, sin sincronización periódica, una copia daría oficinas equivocadas al posponer/retomar tareas (el token `OFICINA:<OFICINA_DIRECTA>|<DESC_OFICINA>` de `SCA2 Tarea`). Se deja en SOAP (una llamada por apertura de pantalla de tarea).

## 2. Modelo (6 tablas, creadas)

Campos comunes en todas: `orden` (posición en la respuesta CORE; las listas se devuelven ordenadas por `orden`), `activo` (baja lógica), `origen` (`CORE` carga inicial / `MANUAL` mantenimiento), `fechaAlta`, `fechaModificacion`, `usuarioModificacion`. PK técnica `id` (serial). Columnas en UPPER_SNAKE_CASE como el resto del esquema.

| Record type (tabla) | Clave natural (índice único propuesto) | Campos propios |
|---|---|---|
| `SCA2 Cat Motivo` (`sca2_cat_motivo`) | `codLineaNegocio, codPerfil, codSubPerfil, codMotivo` | `descripcion` |
| `SCA2 Cat Detalle` (`sca2_cat_detalle`) | `codLineaNegocio, codMotivo, codDetalle` | `descripcion` |
| `SCA2 Cat Causa` (`sca2_cat_causa`) | `codLineaNegocio, codMotivo, codDetalle, codPerfil, codCausa` | `descripcion` |
| `SCA2 Cat Tipo Argumento` (`sca2_cat_tipo_argumento`) | `codTpArg` | los 23 campos restantes de `detalleTpArgDTO` (`descArg, codEstado, idLineaNegocio, idRamo, codCompania, codCompaniaArg, apliArgumento, instruccion, mcaFinalizado, nombreDoc, numDoc, observaciones, fecVigencia, fecModificado, codIdCampana, codTipBon, numTipBon, regateable, mcaTeCuidamos, numDiasSgo, codTareaSgo, txtUrlArg, mcaTrebCalc`); las fechas se guardan como texto `dd/MM/yyyy HH:mm:ss` para devolverlas exactamente igual |
| `SCA2 Cat Concepto` (`sca2_cat_concepto`) | `idnConceptoPca` | `desConceptoPca, mcaInh, fecActu` |
| `SCA2 Cat Valor Concepto` (`sca2_cat_valor_concepto`) | `idnConceptoPca, idnPca` | `valorConcepto, desConcepto, mcaInh, fecActu` |

**Por qué perfil/subperfil en motivo y perfil en causa:** CORE filtra por ellos (tabla §1); para que la salida del record sea idéntica a la SOAP para cada usuario, la fila lleva la combinación para la que CORE la devuelve. La carga inicial recorre las combinaciones que usa SCA2 (`sca2_datos_perfiles_pca` + `SCA2_datosPerfilesPcaSi24`): `CE_RM/CE_RM_OFICINA`, `CE_MF_SI24/CE_MF_SI24_EXPERTO`, `CE_MF_BK/CE_MF_BK_EXPERTOSI24` (+ `CE_RM/CE_MF_SI24_EXPERTO`, que CORE devuelve vacío) × LN 1, 2, 3. Para una combinación no cargada el record devuelve vacío y la regla hace *fallback* a la SOAP, así ningún perfil pierde funcionalidad.

**Relaciones causa→motivo→detalle:** no se crean relaciones de record. La jerarquía del CORE es por claves compuestas (`detalle` depende de LN+motivo, `causa` de LN+motivo+detalle+perfil) y las relaciones Appian son de un solo campo; las reglas filtran por los códigos, que es lo que hace hoy la SOAP. Se documenta como decisión; si se quisiera navegar desde el record list se añadiría un `idMotivo`/`idDetalle` técnico más adelante.

**Creación de tablas:** hecha desde Appian TEST por la API de diseño (record type nuevo → *crear tabla* sobre `SCA2 DataBase AWS`, esquema `sca2_anulaciones`), sin problema de permisos; las 6 tablas existen con las longitudes indicadas (verificado contra el data source). DDL *as-built* en [sql/43-C-catalogos.sql](sql/43-C-catalogos.sql). **Pendiente DBA:** los índices únicos `ux_*` (Appian no los crea; mientras tanto la unicidad la garantizan la carga y el mantenimiento).

## 3. Objetos Appian (TEST) — estado final

### 3.1 Nuevos

| Objeto | Tipo | uuid | Versión | Para qué |
|---|---|---|---|---|
| `SCA2 Cat Motivo` | Record type (DB, tabla `sca2_cat_motivo`) | `40727673-e6c7-46f4-b647-7c98ac09163a` | 1 | catálogo de motivos por LN + perfil/subperfil |
| `SCA2 Cat Detalle` | Record type (DB, `sca2_cat_detalle`) | `433c6bd0-8a5b-461f-9056-ddd37ffbf00b` | 1 | detalles por LN + motivo |
| `SCA2 Cat Causa` | Record type (DB, `sca2_cat_causa`) | `a055e578-6ddb-4397-bad1-1ae361a38e56` | 1 | causas por LN + motivo + detalle + perfil |
| `SCA2 Cat Tipo Argumento` | Record type (DB, `sca2_cat_tipo_argumento`) | `dc54d386-8cd9-4369-818a-13a5dc54d0ea` | 1 | tipos de argumento (`detalleTpArgDTO`) |
| `SCA2 Cat Concepto` | Record type (DB, `sca2_cat_concepto`) | `ff259e4f-7a2a-4690-b4bf-011b68ce4dc7` | 1 | conceptos PCA |
| `SCA2 Cat Valor Concepto` | Record type (DB, `sca2_cat_valor_concepto`) | `774549b5-8a4a-4a4b-aeb8-f2960360ff18` | 1 | valores de concepto |
| `SCA2_USAR_CATALOGOS_AURORA` | Constante (Boolean) | `_a-0000f093-2064-8000-9d36-011c48011c48_5603869` | 5 (valor **false**) | interruptor de lectura; se puso a true solo durante la comparación y la medición y se devolvió a false |
| `SCA2_consultarMotivoCore` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603864` | 1 | copia exacta del SAIL original de `SCA2_consultarMotivo` v1 (SOAP CORE) |
| `SCA2_consultarDetalleCore` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603876` | 1 | copia exacta de `SCA2_consultarDetalle` v1 |
| `SCA2_consultarCausaCore` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603893` | 1 | copia exacta de `SCA2_consultarCausa` v2 (incluye la ocultación SI24) |
| `SCA2_consultarTipoArgCore` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603903` | 1 | copia exacta de `SCA2_consultarTipoArg` v5 |
| `SCA2_consultarConceptoCore` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5603910` | 1 | copia exacta de `SCA2_consultarConcepto` v1 |
| `SCA2_catParametrosCarga` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604030` | 1 | parejas perfil/subperfil, perfiles de causa, LN 1-3 y usuario de consulta de la carga |
| `SCA2_catConstruirCarga(catalogo)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604038` | 3 | lee CORE con las `*Core`, compara con el record y construye las filas a escribir (no escribe) |
| `SCA2_catCargarDesdeCore(catalogo)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604046` | 1 | `a!writeRecords` de lo anterior; es la carga inicial / recarga (idempotente) |
| `SCA2_catMotivosAurora(infoUsuarioDTO, codLineaNegocio)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604171` | 1 | lectura del record con la salida `consultarMotivoResponse` |
| `SCA2_catDetallesAurora(codMotivo, codLineaNegocio)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604177` | 1 | salida `consultarDetalleResponse` |
| `SCA2_catCausasAurora(codMotivo, codDetalle, codPerfil, codLineaNegocio)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604183` | 1 | salida `consultarCausaResponse` + misma ocultación SI24 |
| `SCA2_catTiposArgAurora(mseConsultarTipoArgDTO)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604189` | 3 | salida `consultarTipoArgResponse`; replica el filtro CORE (ver §5, C-14) |
| `SCA2_catConceptosAurora(mseConsultarConceptoDTO)` | Regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604195` | 1 | salida `consultarConceptoResponse` (tipoBusqueda 0 / 1) |
| `SCA2_CatMantenimiento` | Interfaz | `_a-0000f093-2064-8000-9d36-011c48011c48_5604449` | 8 | mantenimiento: lista por catálogo, búsqueda, alta/edición/baja lógica, «Recargar desde CORE» |

### 3.2 Existentes modificados (cambio mínimo: el cuerpo pasa a ser el interruptor; el SAIL original vive íntegro en la regla `*Core`)

| Objeto | uuid | Antes → después | Cambio |
|---|---|---|---|
| `SCA2_consultarMotivo` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052556` | v1 → v2 | `if(cons!SCA2_USAR_CATALOGOS_AURORA, a!defaultValue(rule!SCA2_catMotivosAurora(...), rule!SCA2_consultarMotivoCore(...)), rule!SCA2_consultarMotivoCore(...))` |
| `SCA2_consultarDetalle` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050900` | v1 → v2 | ídem con `SCA2_catDetallesAurora` / `SCA2_consultarDetalleCore` |
| `SCA2_consultarCausa` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050906` | v2 → v3 | ídem con `SCA2_catCausasAurora` / `SCA2_consultarCausaCore` |
| `SCA2_consultarTipoArg` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052550` | v5 → v6 | ídem con `SCA2_catTiposArgAurora` / `SCA2_consultarTipoArgCore` |
| `SCA2_consultarConcepto` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052544` | v1 → v2 | ídem con `SCA2_catConceptosAurora` / `SCA2_consultarConceptoCore` |
| `SCA2_GestionMantenimientoMenu` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060073` | v3 → v4 | opción 7 «Catálogos CORE (Aurora)» en `local!opciones` y rama 7 del `choose` → `rule!SCA2_CatMantenimiento()` (nada más cambia) |

Firmas, tipos de entrada y estructura de salida de las cinco reglas no cambian. Fallback: si la regla `*Aurora` devuelve null (sin filas para esa combinación, catálogo vacío, entrada no traducible) se llama a la SOAP. El site `SCA2 Anulaciones` no se toca (la página «Gestiones mantenimiento» ya apunta al menú y ya está restringida a `cons!SCA2_GRP_ADMINISTRADORES`). `SCA2_obtenerOficinasFisicasNuuma` no se toca (decisión del HITO 1).

SAIL completo de todo lo nuevo y de los interruptores: `docs/sca/sail/43-C/` (es el SAIL exacto guardado en Appian). Resumen de cada pieza:

- **Carga** (`SCA2_catConstruirCarga`): por catálogo, lee CORE con las `*Core` recorriendo `SCA2_catParametrosCarga` (motivos: 3 parejas perfil/subperfil × LN 1-3; detalles: por cada (LN, motivo) obtenido; causas: por cada (LN, motivo, detalle) × perfiles CE_RM / CE_MF_SI24 / CE_MF_BK; tipos de argumento: `desc = "%"`; conceptos: `tipoBusqueda 0` + `tipoBusqueda 1` por concepto para `mcaInh`/`fecActu`; valores: `tipoBusqueda 1` por concepto). Construye la clave natural de cada fila, la busca en el record y: si no existe → alta (`origen = CORE`, `activo = true`); si existe con `origen = CORE` → actualización conservando `id` y `fechaAlta`; si existe con `origen = MANUAL` → **no se toca** (se cuenta en `manualesRespetadas`); filas `CORE` activas que CORE ya no devuelve → `activo = false` (baja lógica, nunca borrado físico). `orden` = posición en la respuesta de CORE. Devuelve `a!map(catalogo, filasCore, existentesAntes, manualesRespetadas, bajas, registros)`.
- **Cómo lanzar la carga**: (a) botón «Recargar desde CORE» de la página de mantenimiento (solo administradores; un catálogo por clic; muestra el resumen), o (b) `POST /expression-rules/_a-0000f093-2064-8000-9d36-011c48011c48_5604046/test` con `{"inputs":{"catalogo":"MOTIVO"}}` por cada catálogo (`MOTIVO`, `DETALLE`, `CAUSA`, `TIPO_ARGUMENTO`, `CONCEPTO`, `VALOR_CONCEPTO`). Re-ejecutable las veces que haga falta.
- **Lectura** (`*Aurora`): `a!queryRecordType` filtrando por la misma clave con la que filtra CORE + `activo = true`, ordenado por `orden`, y reconstrucción del mismo CDT de respuesta (`tipoElementoBasicoDTO`, `detalleTpArgDTO`, `conceptoDTO`/`valorConceptoDTO`). Casos especiales replicados de CORE: `consultarTipoArg` sin `desc` → lista vacía (no fallback); `fechaMod` = «modificado en fecha ≥ fechaMod» (dd/MM/yyyy); `fechaMod` con formato distinto → vacío; `%` en `desc` = comodín («contiene»); concepto `tipoBusqueda 0` sin `mcaInh`/`fecActu` (como CORE).
- **Mantenimiento** (`SCA2_CatMantenimiento`): desplegable de catálogo, búsqueda («contiene» sobre los campos de texto), filtro «Solo activos», rejilla paginada ordenada por `orden`; selección de fila → formulario con los campos del catálogo (clave natural obligatoria); **Guardar** valida duplicado de clave natural (excluyendo la propia fila) antes de `a!writeRecords`; **Dar de baja / Reactivar** = baja lógica (`activo`); **Recargar desde CORE**. Las filas nuevas nacen con `origen = MANUAL` (la recarga no las pisa). Botones y formulario solo para `cons!SCA2_GRP_ADMINISTRADORES` (`a!isUserMemberOfGroup`); el resto ve la lista en solo lectura. Un smart service por clic.

## 4. Carga inicial ejecutada en TEST (21-10-2026) — recuentos

| Catálogo | Filas en CORE | Escritas | Por combinación |
|---|---|---|---|
| MOTIVO | 14 | 14 | LN1: CE_RM/CE_RM_OFICINA 3, CE_MF_SI24/CE_MF_SI24_EXPERTO 2, CE_MF_BK/CE_MF_BK_EXPERTOSI24 2; LN2: 2 + 1 + 1; LN3: 1 + 1 + 1 |
| DETALLE | 22 | 22 | (LN1,M1) 7 · (LN1,M2) 1 · (LN1,M4) 1 · (LN2,M1) 7 · (LN2,M4) 1 · (LN3,M1) 5 |
| CAUSA | 146 | 146 | 22 (LN, motivo, detalle) × 3 perfiles; las combinaciones que CORE devuelve vacías (p. ej. SI24 en M2/D7, M4/D9) no generan fila → fallback a SOAP (que también devuelve vacío) |
| TIPO_ARGUMENTO | 343 | 343 | `desc = "%"` (85 con `codEstado = S`; LN2 79) |
| CONCEPTO | 17 | 17 | ids 0–14, CAMP, URL |
| VALOR_CONCEPTO | 100 | 100 | 17 conceptos |

Idempotencia comprobada: segunda ejecución de CONCEPTO → `existentesAntes 17`, 17 actualizaciones, 0 altas, 17 filas en tabla. Tercera ejecución desde el botón tras crear una fila manual → «17 filas en CORE, 1 manuales respetadas, 0 bajas lógicas, 17 filas escritas»; la fila manual quedó intacta (misma `fechaModificacion`).

## 5. Pruebas (TEST, 21-10-2026; usuario `devin`, miembro de `SCA2 Administrators`)

Sin solicitudes ni instancias: las reglas son puras y las pruebas de pantalla son sobre la página de mantenimiento. Datos propios reservados en `docs/sca/pruebas/coordinacion-fase1.md` (concepto manual `ZZC1`, inactivo).

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| C-01 | Regresión con la constante en **false** tras modificar las 5 reglas | Misma salida que antes | 12/12 casos idénticos a las `*Core` (motivo ×3, detalle ×2, causa ×3, tipoArg ×2, concepto ×2) | OK | — | — | `POST /expression-rules/{uuid}/test` sobre regla modificada y sobre su copia `*Core`, mismas entradas, comparación del JSON | — |
| C-02 | Carga MOTIVO/DETALLE/CAUSA/TIPO_ARGUMENTO/CONCEPTO/VALOR_CONCEPTO | Recuentos de §4, sin errores | 14/22/146/343/17/100; `success: true` | OK | — | — | `SCA2_catCargarDesdeCore` por API, lectura de los records | — |
| C-03 | Carga re-ejecutada (CONCEPTO) | Sin duplicados, mismas 17 filas | `existentesAntes 17`, 17 filas | OK | — | — | segunda ejecución + recuento | — |
| C-04 | Comparación lista a lista con la constante en **true** (reglas existentes vs `*Core`), motivos: 4 parejas perfil/subperfil (incl. una no cargada, CE_RM/CE_MF_SI24_EXPERTO) × LN 1-4 | Códigos, textos y orden iguales | 16/16 iguales (las combinaciones no cargadas y LN4 caen al fallback y coinciden) | OK | — | — | script: referencia CORE → constante true → reglas existentes → constante false | — |
| C-05 | Ídem detalles: (LN,motivo) de todos los motivos cargados + (LN1, M99) | Iguales | 7/7 | OK | — | — | ídem | — |
| C-06 | Ídem causas: 22 ternas (LN, motivo, detalle) × perfiles CE_RM, CE_MF_SI24, CE_MF_BK y uno inexistente (`XX`) | Iguales, incluida la ocultación SI24 | 88/88 | OK | — | — | ídem | — |
| C-07 | Ídem tipos de argumento: `desc="%"` (343), `Club`, `servicios`, `SERVICIOS MAPFRE`, `%`+`codEstado S`, `%`+LN2, `%`+N+LN3, `%`+fechaMod 27/03/2026 (43), 01/06/2026 (7), fechaMod ISO (vacío), `%MAPFRE`, `MAPFRE%`, sin `desc` (vacío), `{}`, `zzzz` | Iguales (campos, orden) | 15/15 | OK | — | — | ídem | ver C-14 |
| C-08 | Ídem conceptos: `tipoBusqueda 0` (17) y `tipoBusqueda 1` para los 17 ids + `TRSGO` (inexistente) | Iguales (concepto + valores) | 19/19 | OK | — | — | ídem | — |
| C-09 | Constante devuelta a false al terminar | `false` | v5 = false (comprobado por GET) | OK | — | — | GET /constants | — |
| C-10 | Tiempo de apertura de `SCA2_AltaSolicitudPage` (solo medir): 3 pólizas × 3 repeticiones, `POST /interfaces/{uuid}/test` | — | mediana **6,69 s** con CORE (5,07–11,89) vs **5,94 s** con Aurora (5,05–7,05); ≈ −0,75 s por apertura | OK | — | — | `medir_alta.py`; pólizas 2002100649057, 2002200566753, 2002200566791 (solo lectura) | el resto del tiempo es NSE/cabecera, fuera de esta pieza |
| C-11 | Menú: opción 7 visible y abre la página; lista de motivos con datos | Página «Catálogos CORE (Aurora)» con rejilla | OK (captura) | OK | — | — | site `sca2` → Gestiones mantenimiento → opción 7 (Playwright) | — |
| C-12 | Cambiar de catálogo (Tipos de argumento) y buscar «club» | Rejilla filtrada | 56 coincidencias, rejilla correcta | OK | — | — | desplegable + campo Buscar | 1.ª versión: la búsqueda reiniciaba el menú → `a!queryLogicalExpression` anidada debe ir en `logicalExpressions` (corregido, v4) |
| C-13 | Alta manual de concepto `ZZC1` «CONCEPTO PRUEBA FASE1 C», orden 99 | «Guardado.», fila con `origen MANUAL` | OK (id 18) | OK | — | — | Nuevo → rellenar → Guardar | 1.ª versión: el formulario no se abría (`a!match` con varios campos sin llaves; corregido, v7) |
| C-14 | Alta duplicada de `ZZC1` | Bloqueada por clave natural | «Ya existe una fila con esa misma clave en este catálogo: no se guarda.» | OK | — | — | Nuevo → mismo id → Guardar | — |
| C-15 | Edición de `ZZC1` (descripción «… EDITADO») | «Guardado.» y fila actualizada | OK (`fechaModificacion` 12:51) | OK | — | — | buscar ZZC1 → seleccionar → editar → Guardar | — |
| C-16 | Baja lógica de `ZZC1` y filtro «Solo activos» | «Fila dada de baja.», desaparece con el filtro y aparece con `Activo = No` sin él | OK (captura) | OK | — | — | seleccionar → Dar de baja → confirmar → quitar filtro | — |
| C-17 | «Recargar desde CORE» (CONCEPTO) con una fila manual presente | Mensaje con resumen; fila manual intacta; sin duplicados | «Recarga desde CORE completada: 17 filas en CORE, 1 manuales respetadas, 0 bajas lógicas, 17 filas escritas.»; 18 filas (17 CORE + 1 MANUAL), ZZC1 sin cambios | OK | — | — | botón → confirmar | 1.ª versión: error «a!save() and smart service functions cannot be used in a local variable» → el `a!writeRecords` se hace directamente en el `saveInto` (v8) |
| C-18 | Filtro `fechaMod` de `consultarTipoArg` | Igual que CORE | 1.ª versión KO (interpretado como igualdad de fecha → 1 fila vs 43 de CORE); CORE devuelve lo modificado **desde** esa fecha. Corregido en `SCA2_catTiposArgAurora` v2/v3 y revalidado en C-07 | OK (tras corrección) | — | — | comparación de códigos devueltos | — |
| C-19 | Página en solo lectura para un usuario no administrador | Sin botones ni formulario | **No probado** (no dispongo de un usuario de TEST sin el grupo) | — | — | — | — | pedir al coordinador un usuario no administrador o aceptar la revisión por código (`showWhen: local!esAdmin`) |

## 6. Pendientes y decisiones

- **Activar la lectura**: poner `SCA2_USAR_CATALOGOS_AURORA = true` en TEST cuando el coordinador lo decida (hoy false). Con true, cualquier combinación no cargada o catálogo vacío sigue yendo a SOAP.
- **Índices únicos** `ux_*` (DBA; script en `docs/sca/sql/43-C-catalogos.sql`). Mientras, la unicidad la garantizan la carga y la validación de la página.
- **Recarga completa**: la página recarga un catálogo por clic; por API se lanzan los seis. Orden recomendado: MOTIVO → DETALLE → CAUSA → TIPO_ARGUMENTO → CONCEPTO → VALOR_CONCEPTO.
- **Fila manual con clave que luego aparezca en CORE**: la carga la respeta y no crea otra (se cuenta en `manualesRespetadas`); si se quiere que CORE prevalezca, cambiar manualmente `origen` a CORE desde la base de datos (la página no edita `origen`).
- **Formato de fechas de tipos de argumento**: se guardan como texto `dd/MM/yyyy HH:mm:ss` tal como llegan de CORE (el CDT las trata como texto); si se desea filtrar en BD por fecha habría que añadir una columna `DATE` derivada.
- C-19 (solo lectura para no administradores) pendiente de usuario de prueba.
- Fila de prueba `ZZC1` (concepto, `origen MANUAL`, inactiva) queda en la tabla como evidencia; se puede borrar desde la BD si molesta.
