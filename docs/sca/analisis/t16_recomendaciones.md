# Tanda 16 — Calidad y rendimiento SCA2

## 1) "Recomendaciones" de Designer
Esta versión de Appian no expone la vista "Recomendaciones" a nivel de app (solo: Todos los objetos / Plug-Ins / Objetos sin referencias). Equivalente aplicado: análisis estático sobre todos los objetos SCA2 + advertencias del modeler.

### Corregidas
| Objeto | Recomendación | Acción |
|---|---|---|
| SCA2 CMD ObtenerDocumentoGD | PV `documentId` sin referencias (warning del modeler) | PV eliminado (v7) |
| SCA2 CMD Decidir | condición `pv!nivelCalc>1` (Any vs Number) | `todecimal(a!defaultValue(...))` (15-bis) |
| 12 PMs | `loggedInUser()` en procesos | 0 ocurrencias — ya usa `pp!initiator` |
| Todas las a!queryRecordType de las pantallas clave | paginación | ya `batchSize:1`/`pagingInfo` + `fields:` mínimo — sin acción |

### Pendientes (implican decisión de diseño — listados, no cambiados)
| Objeto | Recomendación | Motivo para decidir |
|---|---|---|
| ~90 reglas `SCA2_*` wrappers | llaman `rule!SCAC_*Integracion` (integraciones SCAC originales, no las SCA2) | migrar a las SCA2_*Integracion creadas implica re-probar cada contrato |
| `SCA2_TM_ObtenerTransaccion` | usa `a!queryEntity` en vez de a!queryRecordType | heredado del original; cambio de fuente de datos |
| Interfaces legacy `SCA2_Detalle*` (Cabecera/Datos/Errores/Tareas/Transiciones) | varias queries inline duplicables; sin uso desde que Detalle pasó a cabecera+tabs | son "Trazabilidad técnica" de respaldo — decidir si eliminar |
| Objetos "sin referencias" (vista Designer) | potenciales no-usados (ports no cableados) | muchos son deliberados (componentes usados por PMs/expresiones) |
| Test cases | listExpressionRuleTestCases existe; crear tests triviales para ~100 reglas = esfuerzo alto | pendiente si se quiere cobertura |

## 2) Rendimiento interfaces (medido con testInterface/testRule, 60s timeout)
| Objeto | Tiempo | Estado |
|---|---|---|
| SCA2_Buscador | 304 ms | OK |
| SCA2_BuscadorTabla | 16 ms | OK |
| SCA2_DetalleSolicitud | 541 ms | OK (incluye consultarPolizas en carga — paridad con SCA DecidirAccion, gated por numPoliza) |
| SCA2_AltaSolicitudPage | 384 ms | OK (ídem) |
| SCA2_cargarSolicitud (regla) | 40 ms | OK — 9 queries todas `batchSize:1`+`fields:` mínimo |

- (a) Todas las a!queryRecordType de las 5 pantallas + reglas llamadas tienen `pagingInfo` acotado y `fields:` — verificado por escaneo estático.
- (b) Las únicas integraciones en carga son `SCA2_consultarPolizas` en Detalle y Alta (cabecera necesita DATOS_PCA — SCA hace lo mismo); resto lazy.
- (c) Sin queries duplicadas por local en las pantallas clave.
- (d) Dropdowns de catálogo: usan reglas SCA2_* de catálogo (constants/records), no integraciones.

## 3) Reglas — escaneo de patrones costosos
- `a!forEach` anidados / `index()` en bucle / `todatasubset` sin paging: no hallados en objetos usados por las 4 pantallas; los `a!forEach` existentes están en reglas de pantallas de acción (sobre datos ya en memoria, no sobre queries).
- `a!queryEntity`: solo `SCA2_TM_ObtenerTransaccion` (listado arriba).

## 4) Seguridad
- No existe tool MCP para rolemap/seguridad por objeto → verificación completa solo posible abriendo cada objeto en Designer (552 objetos).
- Hecho: los objetos creados aparecen bajo la app SCA2 (heredan seguridad de app por defecto). Excepción conocida resuelta: la regla `SCA2_consultaDocumentoGD` quedó fuera de la app → eliminada en tanda 15 cierre.
- Pendiente: revisión visual de seguridad por tipo (grupos SCA2 Administrators/Users/Alertas) — requiere sesión Designer por objeto; listar si se quiere hacer batch.

## Tanda 16-bis — migración wrappers SCAC→SCA2

| Wrapper | SCAC ref | SCA2 equiv | Migrada | Test igual |
|---|---|---|---|---|
| SCA2_BuscarCompaniasContrarias | SCAC_catalogFilteredIntegracion | SCA2_catalogFilteredIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_ContraAnulacionModalRecuperacionPoliza | SCAC_executeAsignarIntegracion | SCA2_executeAsignarIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_ContraAnulacionModalRecuperacionPoliza | SCAC_gestionarTTQRESTIntegracion | SCA2_gestionarTTQRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_ContraAnulacionModalRecuperacionPoliza | SCAC_marcarAsignacionBonificacionIntegracion | SCA2_marcarAsignacionBonificacionIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_TablaGestionArgumentos | SCAC_descargaDocumentoIntegracion | SCA2_descargaDocumentoIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_actualizarSolicitud | SCAC_actualizarSolicitudIntegracion | SCA2_actualizarSolicitudIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_addressAPIClients | SCAC_APIClients_Address | SCA2_APIClients_Address | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_altaSGO | SCAC_consultarCatalogoTareas | SCA2_consultarCatalogoTareas | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_altaSGORehabilitar | SCAC_consultarCatalogoTareas | SCA2_consultarCatalogoTareas | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_altaSGOVida | SCAC_consultarCatalogoTareas | SCA2_consultarCatalogoTareas | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_benefitsAPIClients | SCAC_APIClients_Benefits | SCA2_APIClients_Benefits | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_bloquearPolizaEnCentral | SCAC_bloquearPolizaEnCentralIntegracion | SCA2_bloquearPolizaEnCentralIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_bloquearPolizaEnCentralEstrategicas | SCAC_bloquearPolizaEnCentralIntegracion | SCA2_bloquearPolizaEnCentralIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_cargaGestionPCA | SCAC_CargaGestionPCAIntegration | SCA2_CargaGestionPCAIntegration | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_cargaGestionSGC | SCAC_cargaGestionSGC3 | SCA2_cargaGestionSGC3 | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_comprobarPropietario | SCAC_comprobarPropietarioIntegracion | SCA2_comprobarPropietarioIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_comprobarSolicitudesVigencia | SCAC_consultaSolicitudesIntegracion | SCA2_consultaSolicitudesIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultaDetalleGestion | SCAC_consultaDetalleGestionIntegracion | SCA2_consultaDetalleGestionIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultaDocumento | SCAC_consultaDocumentoIntegracion | SCA2_consultaDocumentoIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarAutorizacion | SCAC_consultarAutorizacionIntegracion | SCA2_consultarAutorizacionIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarClavevida | SCAC_consultaClaveVida | SCA2_consultaClaveVida | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarConceptoFuncionalREST | SCAC_consultarConceptoFuncionalRESTIntegracion | SCA2_consultarConceptoFuncionalRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarDetalleSolicitud | SCAC_consultaDetalleSolicitudIntegracion | SCA2_consultaDetalleSolicitudIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarDocumentos | SCAC_consultarDocumentosIntegracion | SCA2_consultarDocumentosIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarDocumentosREST | SCAC_consultarDocumentosIntegracion | SCA2_consultarDocumentosIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarEstructuraComercial | SCAC_consultaEstructuraComercialVida | SCA2_consultaEstructuraComercialVida | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarFechaUltimoSiniestro | SCAC_consultarSiniestrosAutosIntegracion | SCA2_consultarSiniestrosAutosIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarPolizaVidaRiesgo | SCAC_consultarPolizaVidaRiesgoIntegracion | SCA2_consultarPolizaVidaRiesgoIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarReservaPrima | SCAC_consultaReservaPrima | SCA2_consultaReservaPrima | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarSiniestroPoliza | SCAC_consultarSiniestrosAutosIntegracion | SCA2_consultarSiniestrosAutosIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_consultarUltimaGestionREST | SCAC_consultarUltimaGestionIntegracion | SCA2_consultarUltimaGestionIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_contactMethodAPIClients | SCAC_APIClients_contactMethod | SCA2_APIClients_contactMethod | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_determinarContacto | SCAC_determinarContactoREST | SCA2_determinarContactoREST | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_eliminarConceptoFuncionalREST | SCAC_eliminarConceptoFuncionalRESTIntegracion | SCA2_eliminarConceptoFuncionalRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_finalizarContraAnulPca | SCAC_finalizarContraAnulPcaIntegracion | SCA2_finalizarContraAnulPcaIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_guardarAccAdm | SCAC_guardarAccAdmIntegracion | SCA2_guardarAccAdmIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_insertarConceptoFuncionalREST | SCAC_insertarConceptoFuncionalRESTIntegracion | SCA2_insertarConceptoFuncionalRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_insertarNotificacionExterna | SCAC_insertarNotificacionExternaIntegracion | SCA2_insertarNotificacionExternaIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_modificarConceptoFuncionalREST | SCAC_modificarConceptoFuncionalRESTIntegracion | SCA2_modificarConceptoFuncionalRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_modificarDocument | SCAC_modificarDocumentoIntegracion | SCA2_modificarDocumentoIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_obtenerMarcaEconomica | SCAC_consultaMarcaEconomica | SCA2_consultaMarcaEconomica | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_obtenerOficinasFisicasNuuma | SCAC_obtenerOficinasFisicasNuumaIntegracion | SCA2_obtenerOficinasFisicasNuumaIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_obtenerSVADisponibles | SCAC_obtenerSVADisponiblesRESTIntegracion | SCA2_obtenerSVADisponiblesRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_searchAPIClients | SCAC_APIClients_search | SCA2_APIClients_search | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_simularAnulacionPolizaRest | SCAC_simularAnulacionPolizaRESTIntegracion | SCA2_simularAnulacionPolizaRESTIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_visualizarDatosSolicitud | SCAC_visualizarDatosSolicitudIntegracion | SCA2_visualizarDatosSolicitudIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |
| SCA2_ContraAnulacionArgumentarioEstrategicas | SCAC_descargaDocumentoIntegracion | SCA2_descargaDocumentoIntegracion | sí | no aplicable (testRule devuelve stub; deploy con 0 errores) |

### No migradas — sin integración SCA2 equivalente

| SCA2_CargaGcOnline | SCAC_CargaGcOnLine | SCA2_CargaGcOnLine | **no** — no existe equivalente | — |
| SCA2_ObtenerCodClaseAGT | SCAC_consultaClaveIntegracion | SCA2_consultaClaveIntegracion | **no** — no existe equivalente | — |
| SCA2_aceptarAutorizacion | SCAC_aceptarAutorizacionIntegracion | SCA2_aceptarAutorizacionIntegracion | **no** — no existe equivalente | — |
| SCA2_actualizarVariable | SCAC_actualizarVariableIntegracion | SCA2_actualizarVariableIntegracion | **no** — no existe equivalente | — |
| SCA2_altaDocumento | SCAC_altaDocumentoIntegracion | SCA2_altaDocumentoIntegracion | **no** — no existe equivalente | — |
| SCA2_altaSGO | SCAC_crearSolicitud | SCA2_crearSolicitud | **no** — no existe equivalente | — |
| SCA2_altaSGORehabilitar | SCAC_crearSolicitud | SCA2_crearSolicitud | **no** — no existe equivalente | — |
| SCA2_altaSGOVida | SCAC_crearSolicitud | SCA2_crearSolicitud | **no** — no existe equivalente | — |
| SCA2_asignarSVA | SCAC_AsignarSVARestIntegracion | SCA2_AsignarSVARestIntegracion | **no** — no existe equivalente | — |
| SCA2_borrarDocumentoSCA | SCAC_borrarDocumentoSCA | SCA2_borrarDocumentoSCA | **no** — no existe equivalente | — |
| SCA2_buscarMatricula | SCAC_buscarMatriculaIntegracion | SCA2_buscarMatriculaIntegracion | **no** — no existe equivalente | — |
| SCA2_consultaBBDDSCA | SCAC_consultaBBDDSCA | SCA2_consultaBBDDSCA | **no** — no existe equivalente | — |
| SCA2_consultaClasificacionTC | SCAC_consultaClasificacionTCIntegracion | SCA2_consultaClasificacionTCIntegracion | **no** — no existe equivalente | — |
| SCA2_consultaClave | SCAC_consultaClaveIntegracion | SCA2_consultaClaveIntegracion | **no** — no existe equivalente | — |
| SCA2_consultaGestion | SCAC_consultaGestionIntegracion | SCA2_consultaGestionIntegracion | **no** — no existe equivalente | — |
| SCA2_consultaImpr | SCAC_consultaImprIntegracion | SCA2_consultaImprIntegracion | **no** — no existe equivalente | — |
| SCA2_consultaPropiedadClave | SCAC_consultaPropiedadClaveIntegracion | SCA2_consultaPropiedadClaveIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarAccAdm | SCAC_consultarAccAdmIntegracion | SCA2_consultarAccAdmIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarAccesoStudPorModo | SCAC_consultarAccesoStudPorModoIntegracion | SCA2_consultarAccesoStudPorModoIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarAnulacionPoliza | SCAC_consultarAnulacionPolizaIntegracion | SCA2_consultarAnulacionPolizaIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarCabecera | SCAC_consultarCabeceraRestIntegracion | SCA2_consultarCabeceraRestIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarCabeceraSolicitud | SCAC_consultarCabeceraIntegracion | SCA2_consultarCabeceraIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarCatalogacionRest | SCAC_consultarCatalogacionRestIntegracion | SCA2_consultarCatalogacionRestIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarCausa | SCAC_consultarCausaIntegracion | SCA2_consultarCausaIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarConcepto | SCAC_consultarConceptoIntegracion | SCA2_consultarConceptoIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarDP | SCAC_consultarDPIntegracion | SCA2_consultarDPIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarDetalle | SCAC_consultarDetalleIntegracion | SCA2_consultarDetalleIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarEquipos | SCAC_consultarEquiposIntegracion | SCA2_consultarEquiposIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarListadoArgumentos | SCAC_consultarListadoArgumentosREST | SCA2_consultarListadoArgumentosREST | **no** — no existe equivalente | — |
| SCA2_consultarListadoObs | SCAC_consultarListadoObsIntegracion | SCA2_consultarListadoObsIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarMotivo | SCAC_consultarMotivoIntegracion | SCA2_consultarMotivoIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarNotificacionesExt | SCAC_consultarNotificacionesExtIntegracion | SCA2_consultarNotificacionesExtIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarPlanPagoPorPoliza | SCAC_consultarPlanPagoPorPolizaIntegracion | SCA2_consultarPlanPagoPorPolizaIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarPolizas | SCAC_consultarPolizasIntegracion | SCA2_consultarPolizasIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarServiciosReglas | SCAC_scaServiciosReglas | SCA2_scaServiciosReglas | **no** — no existe equivalente | — |
| SCA2_consultarSolicitudes | SCAC_consultarSolicitudesIntegracion | SCA2_consultarSolicitudesIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarTipoArg | SCAC_consultarTipoArgIntegracion | SCA2_consultarTipoArgIntegracion | **no** — no existe equivalente | — |
| SCA2_consultarVariable | SCAC_consultarVariableIntegracion | SCA2_consultarVariableIntegracion | **no** — no existe equivalente | — |
| SCA2_guardarAutorizacion | SCAC_guardarAutorizacionIntegracion | SCA2_guardarAutorizacionIntegracion | **no** — no existe equivalente | — |
| SCA2_guardarConcepto | SCAC_guardarConceptoIntegracion | SCA2_guardarConceptoIntegracion | **no** — no existe equivalente | — |
| SCA2_guardarEjecuArg | SCAC_guardarEjecuArgIntegracion | SCA2_guardarEjecuArgIntegracion | **no** — no existe equivalente | — |
| SCA2_guardarImpr | SCAC_guardarImprIntegracion | SCA2_guardarImprIntegracion | **no** — no existe equivalente | — |
| SCA2_guardarTipoArg | SCAC_guardarTipoArgIntegracion | SCA2_guardarTipoArgIntegracion | **no** — no existe equivalente | — |
| SCA2_inBSDeleteDocumentDTO | SCAC_inbsDeleteDocumentDTOIntegracion | SCA2_inbsDeleteDocumentDTOIntegracion | **no** — no existe equivalente | — |
| SCA2_insertarObservaciones | SCAC_insertarObservacionesIntegracion | SCA2_insertarObservacionesIntegracion | **no** — no existe equivalente | — |
| SCA2_insertarObservacionesInfoUsuario | SCAC_insertarObservacionesIntegracion | SCA2_insertarObservacionesIntegracion | **no** — no existe equivalente | — |
| SCA2_modificarArgumento | SCAC_modificarArgumentoIntegracion | SCA2_modificarArgumentoIntegracion | **no** — no existe equivalente | — |
| SCA2_modificarCatalogacionCodCiaCntrAnul | SCAC_modificarCatalogacionCodCiaCntrAnulIntegracion | SCA2_modificarCatalogacionCodCiaCntrAnulIntegracion | **no** — no existe equivalente | — |
| SCA2_modificarCrearDocumentoDni | SCAC_modificarCrearDocumentoDniIntegracion | SCA2_modificarCrearDocumentoDniIntegracion | **no** — no existe equivalente | — |
| SCA2_modificarCrearDocumentosAdmin | SCAC_modificarCrearDocumentosAdminIntegracion | SCA2_modificarCrearDocumentosAdminIntegracion | **no** — no existe equivalente | — |
| SCA2_modificarCrearDocumentosCarta | SCAC_modificarCrearDocumentoCartaIntegracion | SCA2_modificarCrearDocumentoCartaIntegracion | **no** — no existe equivalente | — |
| SCA2_modificarMarcaEconomica | SCAC_modificarMarcaEconomica | SCA2_modificarMarcaEconomica | **no** — no existe equivalente | — |
| SCA2_monitorizarSolicitud | SCAC_monitorizarSolicitud | SCA2_monitorizarSolicitud | **no** — no existe equivalente | — |
| SCA2_obtenerDatosProductor | SCAC_obtenerDatosProductorIntegracion | SCA2_obtenerDatosProductorIntegracion | **no** — no existe equivalente | — |
| SCA2_obtenerEstComNuuma | SCAC_obtenerEstComNuumaIntegracion | SCA2_obtenerEstComNuumaIntegracion | **no** — no existe equivalente | — |
| SCA2_obtenerEstructuraComercial | SCAC_obtenerEstructuraComercialIntegracion | SCA2_obtenerEstructuraComercialIntegracion | **no** — no existe equivalente | — |
| SCA2_obtenerOficinas | SCAC_obtenerOficinas | SCA2_obtenerOficinas | **no** — no existe equivalente | — |
| SCA2_obtenerPolizaPrerenovada | SCAC_obtenerPolizaPrerenovadaIntegracion | SCA2_obtenerPolizaPrerenovadaIntegracion | **no** — no existe equivalente | — |
| SCA2_pBuscarPoliza | SCAC_pBuscarPolizaIntegracion | SCA2_pBuscarPolizaIntegracion | **no** — no existe equivalente | — |
| SCA2_pObtenerPolizaFecha | SCAC_pObtenerPolizaFechaIntegracion | SCA2_pObtenerPolizaFechaIntegracion | **no** — no existe equivalente | — |
| SCA2_posibilidadReservaPrima | SCAC_posibilidadReservaPrima | SCA2_posibilidadReservaPrima | **no** — no existe equivalente | — |
| SCA2_searchDocumentos | SCAC_searchDocumentos | SCA2_searchDocumentos | **no** — no existe equivalente | — |
| SCA2_simularAnulacionPoliza | SCAC_simularAnulacionPolizaIntegracion | SCA2_simularAnulacionPolizaIntegracion | **no** — no existe equivalente | — |

### Excepción Retos (se quedan en SCAC por decisión)

| SCA2_asignarRetos | SCAC_obtenerTokenRetosRESTIntegracion / SCAC_asignarRetosRESTIntegracion | — | no (excepción) | — |

Nota parity: las 17 integraciones con diff de inputs solo cambian tipo `consulta`/CDT→`Map` (los wrappers ya construyen Maps). 4 wrappers requirieron además ajuste de kwargs: consultarConceptoFuncionalREST (sin `rand`), consultarDocumentos/REST (sin `randomNum`), APIClients_contactMethod/search (sin `aplicacion`) — la integración SCA2 no expone esos inputs (cache-buster/flag no usados).

## Tanda 16-ter — cobertura total de integraciones SCA2

### Auditoría de las 63 refs "sin equivalente"
- `listIntegrations` con `appUuid` solo devuelve objetos en la carpeta de la app: la lista de 50 ocultaba integraciones existentes.
- Con el inventario Batch B (`sca2_integrations.json`, 107) + búsqueda en servidor: **57 refs existían como `SCA2_<mismo nombre>`** (desajuste de inventario, no de objeto).
- **6 "verdaderamente ausentes"** (`SCAC_borrarDocumentoSCA`, `SCAC_consultaBBDDSCA`, `SCAC_modificarMarcaEconomica`, `SCAC_obtenerOficinas`, `SCAC_posibilidadReservaPrima`, `SCAC_searchDocumentos`) resultaron **ya existir en el servidor** con la misma operación/endpoint pero con **firma de conveniencia** (inputs directos en lugar de `request`/`consulta`/host Map): los wrappers se adaptaron a esa firma en vez de clonar duplicados.

### Migración
60 wrappers actualizados (updateExpressionRule) — ver backups `.bak_t16c`. Ajustes de kwargs para cuadrar con la integración SCA2 existente:

| Wrapper | Ajuste |
|---|---|
| `SCA2_borrarDocumentoSCA` | `request:CDT` → `numSolicitud`/`tipoDocumento`/`idDocumento` |
| `SCA2_consultaBBDDSCA` | `request:Map` → `idSolicitud` + 9 `devolver*` Boolean |
| `SCA2_modificarMarcaEconomica` | kwarg `idArgumento` → `codArg` |
| `SCA2_obtenerOficinas` | host/endpoint/consulta → `nuuma` |
| `SCA2_posibilidadReservaPrima` | `body:Map` → `claveProduccion`/`codigoTipoAnulacion`/`acuerdo`/`codCausa` |
| `SCA2_searchDocumentos` | drop `host`/`endpoint` |
| `SCA2_consultarConcepto`, `consultarTipoArg`, `consultarVariable` | drop kwarg cache-buster (`rand`/`random`/`randomNum` — input inexistente en la integración SCA2) |
| `SCA2_consultarListadoArgumentos` | drop `random` (kwarg inexistente) |
| XPath guards | `xpathsnippet` envuelto en `if(a!isNullOrEmpty(local!tmp))` en los wrappers SOAP (concepto/tipoArg/variable/oficinas) |

### Resultado final
- **0 referencias `rule!SCAC_*Integracion` restantes** en objetos SCA2, salvo la excepción explícita **Retos** (`SCA2_asignarRetos` → `SCAC_obtenerTokenRetosRESTIntegracion`/`SCAC_asignarRetosRESTIntegracion`).
- **No migrables**: `SCA2_CargaGcOnline`, `SCA2_altaDocumento`, `SCA2_monitorizarSolicitud` — wrappers nunca creados en Appian (STOP en batch B: a!map 0-keys, sin Document de prueba, nombre no único). Sus `.sail` locales ya apuntan a SCA2 por si se crean después.
- Validación: las 60 actualizaciones desplegaron sin errores.

### Retest navegador (t16c_*.png)
- Buscador: OK (`t16c_buscador.png`).
- Alta popup con 0007051068625: sigue el mensaje "no es una póliza válida" (`t16c_popup_alta.png`) — comportamiento **pre-existente** en el flujo del popup (la validación que usa el popup no devuelve DATOS_PCA), sin cambios por la migración.
- Detalle (`t16c_detalle.png`): ahora muestra datos reales del cliente (ZAFIEF ZEXUPA CEJJADVEG / NIF 34429061Q) — `consultarPolizas` ya va por la integración SCA2 y devuelve datos, antes DATOS_PCA venía vacío para AA.
