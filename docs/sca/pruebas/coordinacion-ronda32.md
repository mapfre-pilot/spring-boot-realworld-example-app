# Coordinación ronda 32 — limpieza y constantes en SCA2

Origen: `docs/sca/54-...`. Cuatro sesiones hijas con propiedad exclusiva de objetos. R32-A crea las constantes primero (fase 1) y borra después (fase 2); B/C/D sustituyen literales en sus lotes.

### Constantes nuevas (nombres definitivos; las crea R32-A; el resto SOLO las usa con `cons!`)
Perfiles (TEXT): SCA2_TXT_PERFIL_CE_RM="CE_RM", SCA2_TXT_PERFIL_CE_MF_SI24="CE_MF_SI24", SCA2_TXT_PERFIL_CE_MF_RECIBOS="CE_MF_RECIBOS", SCA2_TXT_PERFIL_CE_MF_BK="CE_MF_BK", SCA2_TXT_PERFIL_CE_MF_CONTROL="CE_MF_CONTROL", SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT="CE_MF_CENTRAL_AT", SCA2_TXT_PERFIL_CE_RM_DT="CE_RM_DT".
Subperfiles (TEXT): SCA2_TXT_SUBPERFIL_CE_RM_OFICINA, _CE_RM_AGENTE, _CE_MF_SI24_EXPERTO, _CE_MF_SI24_FRONT, _CE_MF_SI24_TECNICO, _CE_MF_SI24_SA, _CE_MF_SI24_CENTRAL, _CE_MF_BK_EXPERTO_SI24, _CE_MF_RECIBOS_CCC, _CE_MF_RECIBOS_CCR, _CE_CONSULTA (valor = el código sin el prefijo SCA2_TXT_SUBPERFIL_).
Estados de solicitud (TEXT): SCA2_TXT_ESTADO_SOL_EN_ACCION, _PDTE_MECANIZAR, _PDTE_FINALIZAR, _PENDIENTE_AUTORIZACION, _FINALIZADA, _FINALIZADA_POSITIVO, _FINALIZADA_SIN_ANULAR, _FINALIZADA_NEG_CONTRA, _FINALIZADA_NO_REQ, _CADUCADA, _CADUCADA_NEGATIVA (valor = sufijo). Estados de tarea: SCA2_TXT_ESTADO_TAREA_PENDIENTE="PENDIENTE", SCA2_TXT_ESTADO_TAREA_COMPLETADA="COMPLETADA".
Acciones (TEXT): SCA2_TXT_ACCION_CONTRA_ANULAR="CONTRA ANULAR", SCA2_TXT_ACCION_CONTRAANULAR="CONTRAANULAR", SCA2_TXT_ACCION_MECANIZAR="MECANIZAR", SCA2_TXT_ACCION_AUTORIZACION="AUTORIZACION", SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS="ACCIONES ADMINISTRATIVAS", SCA2_TXT_ACCION_VENCIMIENTO="VENCIMIENTO". Tipos de gestión: SCA2_TXT_TIPO_GESTION_ACCADM="ACCADM", _CA="CA", _AU="AU" (la lista SCA2_TIPOS_DE_GESTION se conserva).
Códigos externos: SCA2_TXT_SGD_COD_DOCUMENTAL="DOCS_SCA_001", SCA2_TXT_SGD_QUERY_ARGUMENTOS="QUERY_SCA_AGD_001", SCA2_VAL_NSE_COD_ERROR_4022=4022 (INTEGER; A documenta su significado leyendo SCA2_obtenerMensajeErrorNSE), SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS="200" (SOLO donde "200" sea prefijo de póliza, NUNCA donde sea código HTTP), SCA2_TXT_CANAL_SGO="SGO", SCA2_TXT_CAUSA_BAJA_TEMPORAL="BAJA TEMPORAL", SCA2_TXT_CAUSA_BAJA_VEHICULO="BAJA VEHICULO", SCA2_TXT_TIPO_OFICINA_DIRECTA="OFICINA_DIRECTA", SCA2_TXT_CONTACTO_VERTI="VERTI".
Colores (TEXT): SCA2_VAL_COLOR_NEGRO="#000000", SCA2_VAL_COLOR_BLANCO="#FFFFFF" (sustituye también "#ffffff"), SCA2_VAL_COLOR_GRIS_CLARO="#F5F5F5", SCA2_VAL_COLOR_GRIS_MEDIO ya existe ("#9F9F9F"), SCA2_VAL_COLOR_VERDE="#008C47", SCA2_VAL_COLOR_AZUL_CLARO="#6495ED", SCA2_VAL_COLOR_NARANJA="#ff8000", SCA2_VAL_COLOR_NARANJA_OSCURO="#E46B15", SCA2_VAL_COLOR_ROJO_OSCURO="#BE0F0F", SCA2_VAL_COLOR_AZUL="#0D82BD". SCA2_VAL_COLOR_ROJO ya existe.
Todas en la carpeta de constantes de SCA2, con descripción en español; si una ya existe con ese valor, usar la existente y no duplicar.

## Reparto de objetos

### R32-B (28)
- `SCA2_AnulacionFueraNormaPrincipal` → literales: #000000, #FFFFFF, CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR
- `SCA2_BuscadorTabla` → literales: #ffffff, CADUCADA, CADUCADA_NEGATIVA, FINALIZADA, FINALIZADA_POSITIVO, FINALIZADA_SIN_ANULAR
- `SCA2_ContraAnulacionArgumentarioEstrategicas` → literales: #008C47, #ffffff, DOCS_SCA_001, QUERY_SCA_AGD_001
- `SCA2_ContraAnulacionCompaniaCatalogacion` → literales: #6495ED
- `SCA2_ContraAnulacionModalRecuperacionPoliza` → literales: CE_RM
- `SCA2_ContraAnulacionModalSiNo` → literales: CE_MF_RECIBOS, CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR
- `SCA2_ContraAnulacionOpciones` → literales: #000000, #6495ED, #FFFFFF, CE_MF_RECIBOS, CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR, CE_RM, FINALIZADA, OFICINA_DIRECTA
- `SCA2_ContraAnulacionRehabilitacion` → literales: #6495ED
- `SCA2_D_TiposGestiones` → literales: AUTORIZACION, CONTRA ANULAR, CONTRAANULAR, MECANIZAR
- `SCA2_DetalleSolicitud` → literales: #000000, #008C47, #0D82BD, #9F9F9F, #BE0F0F, #E46B15, #F5F5F5, #FFFFFF, #ffffff, AUTORIZACION, CADUCADA, CADUCADA_NEGATIVA, CE_MF_SI24, CE_MF_SI24_EXPERTO, COMPLETADA, CONTRA ANULAR, EN_ACCION, FINALIZADA, FINALIZADA_NEG_CONTRA, FINALIZADA_NO_REQ, FINALIZADA_POSITIVO, FINALIZADA_SIN_ANULAR, MECANIZAR, PENDIENTE, PENDIENTE_AUTORIZACION, SGO, VENCIMIENTO, VERTI
- `SCA2_FechaDisponibilidadVehiculo` → literales: CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR
- `SCA2_GestionArgumentos` → literales: #000000
- `SCA2_InduccionVertiPanel` → literales: #008C47, COMPLETADA, PENDIENTE
- `SCA2_MensajeDesactivarAplicacion` → literales: #000000
- `SCA2_ModalPlanPago` → literales: #000000
- `SCA2_TablaNotificaciones` → literales: #000000
- `SCA2_VertiVencimientoPrincipal` → literales: #000000, #9F9F9F, #FFFFFF, ACCIONES ADMINISTRATIVAS, VENCIMIENTO, VERTI
- `SCA2_altaGestionCore` → literales: ACCIONES ADMINISTRATIVAS, AUTORIZACION, CE_MF_SI24, CE_MF_SI24_EXPERTO, CE_RM, CE_RM_OFICINA, CONTRA ANULAR, CONTRAANULAR, MECANIZAR
- `SCA2_calculoMedioComunicacion` → literales: CE_MF_BK, CE_MF_CENTRAL_AT, CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR, CE_MF_SI24_EXPERTO, CE_MF_SI24_FRONT, CE_RM
- `SCA2_colorEstadoSolicitud` → literales: #008C47, #0D82BD, #9F9F9F, #BE0F0F, #E46B15
- `SCA2_construirContextoAlta` → literales: CE_RM, CE_RM_OFICINA
- `SCA2_consultarDocumentos` → literales: QUERY_SCA_AGD_001
- `SCA2_consultarDocumentosREST` → literales: QUERY_SCA_AGD_001
- `SCA2_datosPerfilesPcaSi24` → literales: CE_MF_SI24, CE_MF_SI24_EXPERTO, CE_MF_SI24_FRONT
- `SCA2_mostrarBotonCancelarPosponer` → literales: CE_MF_RECIBOS, CE_MF_SI24_EXPERTO, CE_MF_SI24_FRONT, CE_RM
- `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado` → literales: CE_MF_CENTRAL_AT, CE_MF_CONTROL, CE_MF_RECIBOS, CE_MF_SI24, CE_MF_SI24_EXPERTO, CE_MF_SI24_FRONT, CE_RM
- `SCA2_obtenerTipoPoliza` → literales: 200
- `SCA2_simularAnulacionPoliza` → literales: 4022

### R32-C (28)
- `SCA2_AccionesAdministrativasCatalogacion` → literales: #6495ED, CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR
- `SCA2_AccionesAdministrativasDocumentacion` → literales: #000000, BAJA TEMPORAL, BAJA VEHICULO, CE_MF_CENTRAL_AT, CE_MF_CONTROL
- `SCA2_AccionesAdministrativasPrincipal` → literales: #000000, #FFFFFF, ACCADM, ACCIONES ADMINISTRATIVAS, BAJA TEMPORAL, BAJA VEHICULO, FINALIZADA, OFICINA_DIRECTA, PENDIENTE
- `SCA2_AltaGestionArgumento` → literales: #000000, #F5F5F5, DOCS_SCA_001
- `SCA2_AltaGestionConcepto` → literales: #000000, CE_RM, CE_RM_OFICINA
- `SCA2_AnadirGestionConceptosyClases` → literales: #000000, CE_RM, CE_RM_OFICINA
- `SCA2_BandejaErrores` → literales: PENDIENTE
- `SCA2_BuscarCompaniasContrarias` → literales: #000000, #F5F5F5
- `SCA2_DatosCabecera_Estrategicas` → literales: #000000, #F5F5F5
- `SCA2_DetalleTareas` → literales: #FFFFFF, #ffffff, ACCIONES ADMINISTRATIVAS, AUTORIZACION, CADUCADA, COMPLETADA, CONTRA ANULAR, CONTRAANULAR, EN_ACCION, FINALIZADA, FINALIZADA_POSITIVO, MECANIZAR, PENDIENTE, VERTI
- `SCA2_GenerarContactoVerti` → literales: #000000, #6495ED, #FFFFFF
- `SCA2_GestionConceptosYClases` → literales: #000000
- `SCA2_MantenimientoPendientesAutorizar` → literales: SGO
- `SCA2_MensajeEliminacionConcepto` → literales: #ff8000
- `SCA2_MensajeEliminacionDocumento` → literales: #ff8000
- `SCA2_ModalClaveProduccion` → literales: #000000
- `SCA2_PieDePagina` → literales: #000000
- `SCA2_TablaOtrasSolAnulacion` → literales: #ffffff, CADUCADA, CADUCADA_NEGATIVA, FINALIZADA, FINALIZADA_NEG_CONTRA, FINALIZADA_NO_REQ, FINALIZADA_POSITIVO, FINALIZADA_SIN_ANULAR, PENDIENTE, PENDIENTE_AUTORIZACION
- `SCA2_actualizarVariable` → literales: CE_MF_CONTROL
- `SCA2_calcularEstadoSolicitud` → literales: CADUCADA
- `SCA2_catParametrosCarga` → literales: CE_MF_BK, CE_MF_SI24, CE_MF_SI24_EXPERTO, CE_RM, CE_RM_OFICINA
- `SCA2_companiasContrariasCompletas` → literales: 200
- `SCA2_consultarConceptoReutilizable` → literales: CE_RM, CE_RM_OFICINA
- `SCA2_erroresGuardarSolicitud` → literales: CE_MF_RECIBOS_CCC, CE_MF_RECIBOS_CCR, CE_RM
- `SCA2_mostrarMensajesOAlta` → literales: 200, CE_MF_BK, CE_MF_RECIBOS_CCC, CE_MF_SI24_EXPERTO, CE_MF_SI24_FRONT
- `SCA2_obtenerInformacionUsuario` → literales: CE_RM, CE_RM_OFICINA
- `SCA2_parametrosRelanzarCompletarAccion` → literales: PENDIENTE
- `SCA2_subirDocumentosGD` → literales: ACCADM, QUERY_SCA_AGD_001

### R32-D (28)
- `SCA2_AltaSolicitudAnulacionPopUp` → literales: #000000, 200
- `SCA2_AltaSolicitudPage` → literales: #000000, #6495ED, #F5F5F5, #FFFFFF, 4022, CE_RM_OFICINA, EN_ACCION, PENDIENTE
- `SCA2_AnadirModificarGestionAplicacion` → literales: #000000
- `SCA2_Buscador` → literales: #000000, #FFFFFF, 200, CADUCADA, CADUCADA_NEGATIVA, EN_ACCION, FINALIZADA, FINALIZADA_NEG_CONTRA, FINALIZADA_NO_REQ, FINALIZADA_POSITIVO, FINALIZADA_SIN_ANULAR, PDTE_FINALIZAR, PENDIENTE, PENDIENTE_AUTORIZACION
- `SCA2_D_ColorEstadoGestion` → literales: #9F9F9F, FINALIZADA, PENDIENTE
- `SCA2_DetalleErrores` → literales: PENDIENTE
- `SCA2_EliminarValorConcepto` → literales: #ff8000, CE_RM, CE_RM_OFICINA
- `SCA2_GestionAplicacionRecords` → literales: #000000
- `SCA2_GestionMantenimientoMenu` → literales: #000000, #9F9F9F
- `SCA2_MecanizacionPrincipal` → literales: #000000, #FFFFFF, VERTI
- `SCA2_MilestoneMasDatosAltaSolicitud` → literales: #000000, #F5F5F5, #FFFFFF
- `SCA2_MilestoneMasDatosAltaSolicitud_Estrategicas` → literales: #000000, #F5F5F5, #FFFFFF
- `SCA2_ModalDescuentosVida` → literales: #000000
- `SCA2_TablaGestionArgumentos` → literales: #000000, #008C47, #ffffff, DOCS_SCA_001
- `SCA2_ValoresConceptoGestionConceptosyClases` → literales: #000000, CE_RM, CE_RM_OFICINA
- `SCA2_altaDocumento` → literales: DOCS_SCA_001
- `SCA2_altaSGO` → literales: SGO
- `SCA2_altaSGORehabilitar` → literales: SGO
- `SCA2_altaSGOVida` → literales: SGO
- `SCA2_calculoCanalEntrada` → literales: CE_MF_BK, CE_MF_CENTRAL_AT, CE_MF_SI24, CE_MF_SI24_EXPERTO, CE_MF_SI24_FRONT, CE_RM
- `SCA2_checkDniObligatorioAndCermProfileAccAdm` → literales: CE_RM
- `SCA2_comprobarUserTareaActiva` → literales: CE_RM
- `SCA2_contarErroresPendientes` → literales: PENDIENTE
- `SCA2_isUsuarioProceso` → literales: CE_RM, CE_RM_OFICINA
- `SCA2_obtenerCaducidadNivel` → literales: CE_MF_SI24, CE_RM
- `SCA2_obtenerMensajeErrorNSE` → literales: 4022
- `SCA2_posponerGestionSGC` → literales: ACCADM, OFICINA_DIRECTA
- `SCA2_textoEstadoSolicitud` → literales: CADUCADA, CADUCADA_NEGATIVA, EN_ACCION, FINALIZADA, FINALIZADA_NEG_CONTRA, FINALIZADA_NO_REQ, FINALIZADA_POSITIVO, FINALIZADA_SIN_ANULAR, PDTE_FINALIZAR, PENDIENTE, PENDIENTE_AUTORIZACION

## R32-A borra (66 objetos, 14 constantes)
`SCA2_AltaSolicitud`, `SCA2_BuscadorTablaEstrategicas`, `SCA2_BuscarSolicitudClientePoliza`, `SCA2_CalcularListaParCargaSGCOnline`, `SCA2_CargaGcOnLine`, `SCA2_DatosCabecera`, `SCA2_DocumentosAccion`, `SCA2_GenerarSolicitudPopup`, `SCA2_GuardarDocumentos`, `SCA2_GuardarImprimir`, `SCA2_InterfazErrorDocumentos`, `SCA2_MensajeCancelarContraAnulacion`, `SCA2_ObtenerCredencialesConceptos`, `SCA2_ObtenerDatosBasicosSolicitud`, `SCA2_ObtenerDatosPerfilesPca`, `SCA2_ObtenerDatosPolizaAutos`, `SCA2_ObtenerDatosPolizaHogar`, `SCA2_ObtenerDatosPolizaVida`, `SCA2_ObtenerDatosProductorBBDD`, `SCA2_ObtenerDatosSolicitud`, `SCA2_ObtenerDocumentosArgumentos`, `SCA2_ObtenerMapaPoliza`, `SCA2_ObtenerNivelesCoberturaAutos`, `SCA2_RecordToCdtSolicitudAnulacion`, `SCA2_S2_diagnosticoSolicitud`, `SCA2_TM_ObtenerTransaccion`, `SCA2_VisualizarDocumentoContraanular`, `SCA2_aceptarAutorizacion`, `SCA2_bloquearPolizaEnCentral`, `SCA2_bloquearPolizaEnCentralEstrategicas`, `SCA2_calcularCaducidadNivel_test`, `SCA2_calcularDocumentosASubir`, `SCA2_calculoSumasAseguradas`, `SCA2_catCargarDesdeCore`, `SCA2_comprobarEliminarDocumentos`, `SCA2_configurarDatosContextoSolicitud`, `SCA2_construirEntradaReglas_test`, `SCA2_esPropietarioProvisional`, `SCA2_extraerCodClienteNIF`, `SCA2_gestionSegunOrigen`, `SCA2_guardarObservaciones`, `SCA2_guardarTrazabilidad`, `SCA2_liberarTarea`, `SCA2_mapSalidaRespuestaAccAdm`, `SCA2_mapSalidaRespuestaAutorizacion`, `SCA2_mapSalidaRespuestaCA`, `SCA2_mapSalidaRespuestaFinalizatrCA`, `SCA2_mapearDatosDecidirAccionEstrategicas`, `SCA2_mensajeCorreoElectronico`, `SCA2_monitorizarSolicitud`, `SCA2_monitorizarSolicitudRegla`, `SCA2_obtenerDescuentos`, `SCA2_obtenerFormaDeCobro`, `SCA2_obtenerOficinas`, `SCA2_obtenerOtrasSolicitudesCabecera`, `SCA2_obtenerSituacionRiesgo`, `SCA2_pmPorComando`, `SCA2_posponerTarea`, `SCA2_propietarioParaCaducidad`, `SCA2_relanzarError`, `SCA2_renovarCacheCabecera`, `SCA2_setDatosGestionDatosPoliza`, `SCA2_setDatosGestionSGC`, `SCA2_setDatosGestionSGCEstratégicas`, `SCA2_simularAnulacionPolizaRest`, `SCA2_tmpDevinQuery`

Constantes: `SCA2_PM_BATCH_CADUCIDAD`, `SCA2_TXT_EMAIL_DUE_PARA_ALTITUDE`, `SCA2_TXT_URL_HOST`, `SCA2_TXT_URL_LANZARDECISION_ANTIGUO`, `SCA2_PM_CMD_BARRIDO_CADUCIDAD`, `SCA2_TXT_EMAIL_ENVIO_ERRORES`, `SCA2_REP_PROCESS_MECANIZACIONES`, `SCA2_TXT_DUE_MENSAJE`, `SCA2_PLANTILLA_CONTRATO_COMPRA_VENTA`, `SCA2_TXT_EMAIL_DUE_PARA_EXPERTOS`, `SCA2_FLD_CLIENTE_TIPO_VALOR`, `SCA2_ARTIFACTS_FOLDER`, `SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION`, `SCA2_TEXTOS_GENERAR_SOLICITUD_POPUP_ESTRATEGICAS`

## Se conservan
`SCA2_MENSAJE_ERROR_DECISORA`, `SCA2_RedirigirGesvida`, `SCA2_TIPOS_DE_GESTION`, `SCA2_TXT_ACCIONES`, `SCA2_TXT_ESTADOS_SOLICITUD_CA`, `SCA2_TXT_GENERAR_SOLICITUD`, `SCA2_comprobarUserTareaActiva`, `SCA2_esOleadaDecisora`, `SCA2_flagVerti`, `SCA2_isUsuarioProceso`, `SCA2_obtenerTareasSolicitudAlta`
