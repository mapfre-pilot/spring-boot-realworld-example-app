# 43-C. Catálogos del CORE como records de tablas en Aurora (fase 1, sesión C)

**Fecha:** 21-10-2026 · **Entorno:** Appian TEST, aplicación SCA2 · **Estado:** HITO 1 (modelo definido, tablas creadas, pendiente OK para cargar datos y tocar las reglas existentes).

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

## 3. Objetos Appian (TEST)

| Objeto | Tipo | uuid | Versión | Estado |
|---|---|---|---|---|
| `SCA2 Cat Motivo` | Record type (DB) | `40727673-e6c7-46f4-b647-7c98ac09163a` | 1 | creado 21-10 |
| `SCA2 Cat Detalle` | Record type (DB) | `433c6bd0-8a5b-461f-9056-ddd37ffbf00b` | 1 | creado 21-10 |
| `SCA2 Cat Causa` | Record type (DB) | `a055e578-6ddb-4397-bad1-1ae361a38e56` | 1 | creado 21-10 |
| `SCA2 Cat Tipo Argumento` | Record type (DB) | `dc54d386-8cd9-4369-818a-13a5dc54d0ea` | 1 | creado 21-10 |
| `SCA2 Cat Concepto` | Record type (DB) | `ff259e4f-7a2a-4690-b4bf-011b68ce4dc7` | 1 | creado 21-10 |
| `SCA2 Cat Valor Concepto` | Record type (DB) | `774549b5-8a4a-4a4b-aeb8-f2960360ff18` | 1 | creado 21-10 |

Versiones actuales de los objetos existentes que tocará esta sesión tras el OK: `SCA2_consultarCausa` v2, `SCA2_consultarMotivo` v1, `SCA2_consultarDetalle` v1, `SCA2_consultarTipoArg` v5, `SCA2_consultarConcepto` v1, `SCA2_GestionMantenimientoMenu` v3 (`SCA2_obtenerOficinasFisicasNuuma` v1 no se toca si se acepta §1).

## 4. Plan tras el HITO 1

1. Reglas `SCA2_consultarMotivoCore`, `SCA2_consultarDetalleCore`, `SCA2_consultarCausaCore`, `SCA2_consultarTipoArgCore`, `SCA2_consultarConceptoCore` (copias exactas de las actuales).
2. Carga inicial `SCA2_cargarCatalogosAurora` (regla con `a!writeRecords`, idempotente por clave natural) que recorre: motivos para las 4 parejas perfil/subperfil × LN 1-3 → detalles por (LN, motivo) → causas por (LN, motivo, detalle, perfil CE_RM / CE_MF_SI24 / CE_MF_BK); tipos de argumento con `desc = "%"`; conceptos (`tipoBusqueda 0`) y valores (`tipoBusqueda 1` por concepto). Documentar recuentos. (En TEST no se pueden crear process models por la API de diseño; si se prefiere PM `SCA2 CAT Carga Inicial`, se pide al coordinador.)
3. Constante `SCA2_USAR_CATALOGOS_AURORA` = false; reglas existentes → `if(cons!…, <queryRecordType con la misma estructura CDT>, <llamada actual>)` con *fallback* a la SOAP si el record devuelve vacío. Los filtros de CORE se replican: motivo por (LN, perfil, subperfil); detalle por (LN, motivo); causa por (LN, motivo, detalle, perfil) + ocultación SI24 que ya hace la regla; tipoArg con `desc` «contiene», `codEstado`, `idLineaNegocio`, `fechaMod`; concepto por `tipoBusqueda`/`idConcepto`.
4. Interfaz `SCA2_CatMantenimiento` (+ `SCA2_CatMantenimientoFormulario`) y entrada «Catálogos CORE (Aurora)» en `SCA2_GestionMantenimientoMenu`.
5. Pruebas (§5) y documentación.

## 5. Pruebas

Pendiente (formato `ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución`).

## 6. Pendientes y decisiones

- Índices únicos `ux_*` (DBA).
- OK a dejar las oficinas BDEC fuera (§1).
- OK a «sin relaciones de record» (§2).
