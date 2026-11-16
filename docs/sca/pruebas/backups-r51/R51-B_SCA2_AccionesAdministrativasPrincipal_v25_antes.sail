=a!localVariables(
  local!usuario: index(rule!SCA2_obtenerInformacionUsuario(), "infoUsuarioDTO", {}),
  local!sol: rule!SCA2_cargarSolicitud(idSolicitud: ri!idSolicitud),
  local!numPoliza: index(local!sol, "estado", "numPoliza", ""),
  local!nivelIntervencion: index(local!sol, "estado", "nivelIntervencion", 1),
  local!cab: rule!SCA2_obtenerDatosCabecera(numPoliza: local!numPoliza, idSolicitud: tointeger(ri!idSolicitud)),
  local!perfiles: index(index(a!queryRecordType(
      recordType: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca',
      filters: a!queryFilter(field: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud', operator: "=", value: ri!idSolicitud),
    fields: {
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud',
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{fe4f7b10-d017-4191-ab3a-3a532f3f9b69}codcompania',
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{9e7da6f2-78d1-4f46-bfdf-ba8fe8a70e10}codsubperfil',
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{a71794d3-baab-46d5-9fcc-d2d6845cd0ec}nuuma',
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil'},
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1), fetchTotalCount: false),
    "data", {}), 1, null),
  local!nuuma: a!defaultValue(index(local!perfiles, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{a71794d3-baab-46d5-9fcc-d2d6845cd0ec}nuuma', null), index(local!usuario, "nuuma", "")),
  local!codPerfil: a!defaultValue(index(local!usuario, "codPerfil", null), index(local!perfiles, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil', null)),
  local!codSubPerfil: a!defaultValue(index(local!usuario, "codSubPerfil", null), index(local!perfiles, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{9e7da6f2-78d1-4f46-bfdf-ba8fe8a70e10}codsubperfil', null)),
  local!codCiaUsuario: a!defaultValue(index(local!perfiles, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{fe4f7b10-d017-4191-ab3a-3a532f3f9b69}codcompania', null), index(local!usuario, "codCiaUsuario", "41")),
  local!obtenerOficinas: reduce(
    index(_, _, null),
    rule!SCA2_obtenerOficinasFisicasNuuma(nuuma: local!nuuma),
    {"MSSObtenerOficinasFisicasNuuma", "LISTA_OFICINAS"}),
  local!oficinas: a!defaultValue(local!obtenerOficinas, {}),
  local!masDeUnaOficina: or(length(local!oficinas) > 1, a!isNullOrEmpty(local!oficinas)),
  /* B1: al RETOMAR se preselecciona la oficina elegida al POSPONER (SCA2 Tarea.tokenTarea = OFICINA:<OFICINA_DIRECTA>|<DESC_OFICINA>) */
  local!tokenTarea: if(
    a!isNullOrEmpty(ri!idTarea),
    "",
    tostring(index(index(index(a!queryRecordType(
      recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
      fields: {'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea'},
      filters: a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', operator: "=", value: tointeger(ri!idTarea)),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1), fetchTotalCount: false), "data", {}), 1, null),
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea', ""))),
  local!oficinaGuardada: if(
    or(a!isNullOrEmpty(local!tokenTarea), left(local!tokenTarea, 8) <> "OFICINA:", a!isNullOrEmpty(local!oficinas)),
    null,
    a!localVariables(
      local!codOficina: index(split(right(local!tokenTarea, len(local!tokenTarea) - 8), "|"), 1, ""),
      local!posOficina: wherecontains(local!codOficina, touniformstring(index(local!oficinas, "OFICINA_DIRECTA", {}))),
      if(a!isNullOrEmpty(local!posOficina), null, index(local!oficinas, index(local!posOficina, 1, 1), null)))),
  local!detalleOficina: if(a!isNotNullOrEmpty(local!oficinaGuardada), local!oficinaGuardada, if(length(local!oficinas) = 1, index(local!oficinas, 1, null), null)),
  local!noEntregaDoc,
  local!listaNombreDocs,
  /* --- tanda 11: variables documentación como en el original --- */
  local!consultarDocumento: rule!SCA2_consultarDocumentos(codSolicitud: ri!idSolicitud),
  local!listaDocumentos: index(index(local!consultarDocumento, "MSSConsultarDocumentos", null), "listaDocumentos", null),
  local!documentosOk: false,
  local!documentosACargar1, local!documentosACargar2, local!documentosACargar3,
  local!documentosACargar4, local!documentosACargar5, local!documentosACargar6,
  local!documentosACargar7, local!documentosACargar8, local!documentosACargar9,
  /* Paridad SCA_AccionesAdministrativasPrincipal: FINALIZAR se habilita con «no entrega documentación»
     o con DNI (tipo 7) + otro documento (tipos 1-5, 9), ya entregado en CORE o cargado en pantalla. */
  local!dniAdjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "7"), true)),
    a!isNotNullOrEmpty(local!documentosACargar7)),
  local!1Adjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "1"), true)),
    a!isNotNullOrEmpty(local!documentosACargar1)),
  local!2Adjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "2"), true)),
    a!isNotNullOrEmpty(local!documentosACargar2)),
  local!3Adjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "3"), true)),
    a!isNotNullOrEmpty(local!documentosACargar3)),
  local!4Adjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "4"), true)),
    a!isNotNullOrEmpty(local!documentosACargar4)),
  local!5Adjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "5"), true)),
    a!isNotNullOrEmpty(local!documentosACargar5)),
  local!9Adjunto: or(
    and(
      a!isNotNullOrEmpty(local!listaDocumentos),
      contains(a!forEach(items: local!listaDocumentos, expression: index(fv!item, "tipoDocumento", null) = "9"), true)),
    a!isNotNullOrEmpty(local!documentosACargar9)),
  local!documentosEntregados: or(
    a!defaultValue(local!noEntregaDoc, false),
    and(local!dniAdjunto, or(local!1Adjunto, local!2Adjunto, local!3Adjunto, local!4Adjunto, local!5Adjunto, local!9Adjunto))),
  local!mcaVentanaVisualizarDoc: false,
  local!flecha: false,
  local!docSinTraspasoSeguro: false,
  local!collapse1: true,
  local!collapse2: true,
  local!respuesta,
  local!mensaje,
  local!errorPosponer,
  local!fechaDisponibilidadVehiculo,
  local!tipoCatalogacion,
  local!origen: index(local!sol, "datos", "canalentrada", index(local!sol, "estado", "origenPoliza", "")),
  local!origenPoliza: index(index(local!sol, "estado", null), "origenPoliza", ""),
  local!descCausa: index(index(local!sol, "datos", null), "desccausa", ""),
  /* Paridad SCA_AccionesAdministrativasPrincipal: si el cliente no entrega documentación, o la causa exige el contrato de
     compra/venta sin traspaso (tipo 9) y no se aporta, la póliza se anula a vencimiento (catalogación 2, fecha de vencimiento). */
  local!fechaVencimiento: index(index(local!cab, "datosPoliza", null), "fechaVencimiento", null),
  local!causaExigeContrato: or(
    upper(a!defaultValue(local!descCausa, "")) = "NO VOY A COMPRARME OTRO COCHE",
    upper(a!defaultValue(local!descCausa, "")) = "SEGURO REGALADO POR LA COMPRA DE COCHE"),
  local!anulaAVencimiento: or(
    a!defaultValue(local!noEntregaDoc, false),
    and(local!causaExigeContrato, not(local!9Adjunto))),
  local!fecAnulacionFinal: if(local!anulaAVencimiento, local!fechaVencimiento,
    index(index(index(local!sol, "datosCompletosSolicitud", {}), "datosSolicitud", {}), "fecanulacion", null)),
  local!tipoCatalogacionFinal: if(local!anulaAVencimiento, "2", tostring(local!tipoCatalogacion)),
  local!tipoGestion: "3",
  /* --- tanda 9: bloque API Clients + consultas de gestión idénticas al original --- */
  local!searchAPI: rule!SCA2_searchAPIClients(
      request: {
        "policyNumber": local!numPoliza,
        "policyRolesFilter":{
          "startDate": datetext(today(),"yyyy-MM-dd"),
          "policyRoleIds":{"12"}},
        "searchDetail": {
          "potencialInd": true,
          "notVisible": true }}),
  local!checksPECA: if(a!isNullOrEmpty(local!searchAPI), {},
    reject(fn!isnull,a!forEach(rule!SCA2_checksAPIClients(
      clientId: index(local!searchAPI, "clientId", null),
      preguntas: { 1,2,3,4,5,6,7,8,9,10,11,12 }),
      if(index(fv!item,"responseId","")="1",index(fv!item,"questionDesc","")&index(fv!item,"responseDesc",""),"")))),
  local!datosAccAdm: rule!SCA2_consultarAccAdm(codSolicitud: ri!idSolicitud),
  local!numGestion: reduce(
    index(_,_,null),
    local!datosAccAdm,
    {"MSSConsultarAccAdm", "numGestion"}),
  local!consultaListadoObservacionesAccAdm: rule!SCA2_consultarListadoObs(
    codSolicitud: ri!idSolicitud,
    tipoGestion: local!tipoGestion),
  local!listadoObservaciones: index(
    index(local!consultaListadoObservacionesAccAdm, "MSSConsultarListadoObs", null),
    "listaObservaciones", null),
  local!observaciones: if(
    a!isNullOrEmpty(local!listadoObservaciones),
    "",
    index(local!listadoObservaciones, "obs", null)),
  local!mostrarBotones: a!defaultValue(rule!SCA2_mostrarBotonCancelarPosponer(
    codPerfil: local!codPerfil,
    codSubPerfil: local!codSubPerfil,
    nuumaGestion: local!nuuma,
    nuumaPropietario: index(local!usuario, "nuuma", ""),
    nivelIntervencion: local!nivelIntervencion,
    tipoAcceso: index(local!perfiles, "tipoAcceso", ""),
    clienteCarterizado: index(local!perfiles, "clienteCarterizado", "")), {}),
  local!mostrarBotonCancelar: index(local!mostrarBotones, "mostrarBotonCancelar", true),
  local!mostrarBotonPosponer: index(local!mostrarBotones, "mostrarBotonPosponer", true),
  {
    a!cardLayout(
      contents: {
        /* R24-D #16 (analista): si la última subida al SGD/CORE de esta solicitud falló (fila SCA2 Error DOC_GD_FAIL pendiente),
           la tarea vuelve a abrirse y se avisa aquí para volver a adjuntar el documento y pulsar FINALIZAR de nuevo */
        a!localVariables(
          local!erroresDocs: a!refreshVariable(
            value: index(a!queryRecordType(
              recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
              fields: {'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion'},
              filters: a!queryLogicalExpression(operator: "AND", filters: {
                a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', operator: "=", value: tostring(ri!idSolicitud)),
                a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo', operator: "=", value: "DOC_GD_FAIL"),
                a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', operator: "=", value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE)}),
              pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 3, sort: a!sortInfo(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', ascending: false))), "data", {}),
            refreshAlways: false),
          a!cardLayout(
            showWhen: a!isNotNullOrEmpty(local!erroresDocs),
            style: "ERROR", padding: "STANDARD", marginBelow: "STANDARD",
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextIcon(icon: "exclamation-triangle", color: "NEGATIVE"), " ",
                  a!richTextItem(text: "Los documentos de la última finalización NO se han subido correctamente al gestor documental (SGD) o no constan en CORE, por lo que la acción no se ha dado por completada.", style: "STRONG"),
                  char(10),
                  a!richTextItem(text: a!defaultValue(index(index(local!erroresDocs, 1, null), 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje', null), ""), size: "SMALL"),
                  char(10),
                  a!richTextItem(text: "Vuelva a adjuntar el documento afectado (AÑADIR / MODIFICAR) y pulse FINALIZAR de nuevo. El error queda registrado en la bandeja de errores de SCA2.", size: "SMALL", color: "SECONDARY")
                })
            })
        ),
        a!cardLayout(
          contents: {
            rule!SCA2_DatosCabecera_Estrategicas(
              numPoliza: local!numPoliza,
              collapseData: false,
              datosCabecera: local!cab,
              numSolicitud: tointeger(ri!idSolicitud),
              esAccion: true),
            a!cardLayout(
              contents: {
                a!cardLayout(
                  contents: {
                    a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: a!richTextItem(
                        text: "Acciones administrativas",
                        linkStyle: "STANDALONE", color: cons!SCA2_VAL_COLOR_NEGRO, size: "MEDIUM", style: "STRONG"))
                  },
                  showBorder: false()),
                a!horizontalLine(marginAbove: "STANDARD", marginBelow: "STANDARD"),
                if(local!masDeUnaOficina,
                  rule!SCA2_selectorOficinas(detalleOficina: local!detalleOficina, oficinas: local!oficinas),
                  {}),
                a!cardLayout(
                  showBorder: false,
                  contents: rule!SCA2_FechaDisponibilidadVehiculo(
                    fechaDisponibilidadVehiculo: local!fechaDisponibilidadVehiculo,
                    datosCabecera: local!cab,
                    usuario: local!nuuma),
                  showWhen: and(
                    or(
                      upper(local!descCausa) = cons!SCA2_TXT_CAUSA_BAJA_TEMPORAL,
                      upper(local!descCausa) = cons!SCA2_TXT_CAUSA_BAJA_VEHICULO
                    ),
                    local!origenPoliza = cons!SCA2_TXT_NSE_AUTOS
                  )
                ),
                /* Catalogación colapsable (solo origen FDC) */
                if(local!origen = "FDC",
                  a!cardLayout(
                    contents: {
                      a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: {
                          a!richTextIcon(icon: if(not(local!collapse1), "chevron-right", "chevron-down"), color: cons!SCA2_VAL_COLOR_NEGRO),
                          char(32),
                          a!richTextItem(text: "Catalogación", linkStyle: "STANDALONE", color: cons!SCA2_VAL_COLOR_NEGRO, size: "STANDARD", style: "STRONG")
                        })
                    },
                    link: a!dynamicLink(saveInto: {a!save(local!collapse1, not(local!collapse1))}),
                    marginAbove: "NONE", marginBelow: "NONE", showBorder: false), {}),
                a!horizontalLine(showWhen: local!collapse1),
                a!cardLayout(
                  contents: rule!SCA2_AccionesAdministrativasCatalogacion(
                    tipoCatalogacion: local!tipoCatalogacion,
                    activoPanCatalogacion: index(local!sol, "datos", "activoPanCatalogacion", true),
                    fechaAnulacion: index(index(index(local!sol, "datosCompletosSolicitud", {}), "datosSolicitud", {}), "fecanulacion", null),
                    datosCabecera: local!cab,
                    usuario: local!nuuma),
                  showWhen: and(local!origen = "FDC", local!collapse1),
                  padding: "STANDARD", marginAbove: "NONE", marginBelow: "NONE", showBorder: false),
                /* Documentación colapsable */
                a!cardLayout(
                  contents: {
                    a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: {
                        a!richTextIcon(icon: if(not(local!collapse2), "chevron-right", "chevron-down"), color: cons!SCA2_VAL_COLOR_NEGRO),
                        char(32),
                        a!richTextItem(text: "Documentación", linkStyle: "STANDALONE", color: cons!SCA2_VAL_COLOR_NEGRO, size: "STANDARD", style: "STRONG")
                      })
                  },
                  link: a!dynamicLink(saveInto: {a!save(local!collapse2, not(local!collapse2))}),
                  marginAbove: "NONE", marginBelow: "NONE", showBorder: false),
                a!horizontalLine(showWhen: local!collapse2),
                a!cardLayout(
                  contents: rule!SCA2_AccionesAdministrativasDocumentacion(
                    codSolicitud: ri!idSolicitud,
                    noEntregaDoc: local!noEntregaDoc,
                    observaciones: local!observaciones,
                    listaDocumentos: local!listaDocumentos,
                    documentosOk: local!documentosOk,
                    causa: index(local!sol, "datos", "desccausa", index(local!sol, "datos", "codcausa", "")),
                    listaNombreDocs: local!listaNombreDocs,
                    documentosACargar1: local!documentosACargar1,
                    documentosACargar2: local!documentosACargar2,
                    documentosACargar3: local!documentosACargar3,
                    documentosACargar4: local!documentosACargar4,
                    documentosACargar5: local!documentosACargar5,
                    documentosACargar6: local!documentosACargar6,
                    documentosACargar7: local!documentosACargar7,
                    documentosACargar8: local!documentosACargar8,
                    documentosACargar9: local!documentosACargar9,
                    accion: "1",
                    solicitudAnulacion: local!sol,
                    dniOK: local!dniAdjunto,
                    origenPoliza: local!origenPoliza,
                    mcaVisualizarDoc: local!mcaVentanaVisualizarDoc,
                    flecha: local!flecha,
                    docSinTraspasoSeguro: local!docSinTraspasoSeguro),
                  showWhen: and(not(local!mcaVentanaVisualizarDoc), local!collapse2),
                  padding: "STANDARD", marginAbove: "NONE", marginBelow: "NONE", showBorder: false),
                a!columnsLayout(
                  columns: {
                    a!columnLayout(
                      contents: {
                        rule!SCA2_VisualizarDocumentoContraanularEstrategicas(
                          document: cons!SCA_PLANTILLA_CONTRATO_COMPRA_VENTA,
                          cancel: local!mcaVentanaVisualizarDoc,
                          flecha: local!flecha,
                          accAdm: true)})},
                  showWhen: and(local!mcaVentanaVisualizarDoc, local!collapse2))
              },
              shape: "ROUNDED", padding: "NONE", marginAbove: "MORE", showShadow: true),
            if(a!isNotNullOrEmpty(local!mensaje),
              rule!SCA2_PopUpMensajeAutorizacion(
                texto: local!mensaje, titulo: "Acciones administrativas",
                resCargaGestionPCA: null, modificarCatalogacionResponse: null,
                insertarObservacionesResponse: null), {}),
            a!horizontalLine(color: cons!SCA2_VAL_COLOR_BLANCO),
            a!buttonLayout(
              primaryButtons: {
                a!buttonWidget(
                  label: "FINALIZAR",
                  /* Los adjuntos ya están consolidados (a!submitUploadedFiles en AÑADIR/MODIFICAR de SCA2_AccionesAdministrativasDocumentacion) */
                  saveInto: {
                    a!save(local!respuesta, index(rule!SCA2_modificarCatalogacionCodCiaCntrAnul(
                        solicitud: ri!idSolicitud, ciaContraria: "",
                        fechaAnulacion: local!fecAnulacionFinal,
                        tipoCatalogacion: local!tipoCatalogacionFinal), "success", false)),
                    a!save(local!respuesta, and(
                      local!respuesta = true,
                      or(a!isNullOrEmpty(local!observaciones),
                        toboolean(a!defaultValue(index(rule!SCA2_insertarObservaciones(
                          nuuma: local!nuuma, codSolicitud: ri!idSolicitud,
                          txtObservaciones: local!observaciones, tipoGestion: local!tipoGestion), "success", false), false))),
                      toboolean(a!defaultValue(index(rule!SCA2_guardarAccAdm(guardarAccAdm: a!map(MSEGuardarAccAdm: a!map(
                        fecAnulacion: local!fecAnulacionFinal,
                        fecDispoVeh: if(a!isNullOrEmpty(local!fechaDisponibilidadVehiculo), null, tostring(todate(local!fechaDisponibilidadVehiculo))),
                        idGestionSGC: index(index(index(local!sol, "datosCompletosSolicitud", {}), "datosBasicosSolicitud", {}), "idgestionsgc", null),
                        idSolicitud: ri!idSolicitud,
                        infoUsuario: a!map(codCiaUsuario: local!codCiaUsuario, nuuma: local!nuuma, codPerfil: local!codPerfil, codSubPerfil: local!codSubPerfil),
                        listaDocumentos: a!forEach(items: a!defaultValue(local!listaDocumentos, {}), expression: a!map(
                          fecEntrega: index(fv!item, "fechaDocumento", null),
                          idDocumento: a!match(value: tostring(index(fv!item, "tipoDocumento", "")),
                            equals: "1", then: if(local!origenPoliza = cons!SCA2_TXT_NSE_AUTOS, "5", "12"),
                            equals: "2", then: if(local!origenPoliza = cons!SCA2_TXT_NSE_AUTOS, "6", "11"),
                            equals: "3", then: "1", equals: "4", then: "2", equals: "5", then: "3",
                            default: index(fv!item, "tipoDocumento", null)),
                          nomDocumento: index(fv!item, "idDocumento", null))),
                        mcaFinalizar: "S",
                        numGestion: local!numGestion))), "success", false), false)))),
                    a!save(local!mensaje, if(local!respuesta = true,
                      "Los datos se han guardado correctamente",
                      "Los datos no se han podido guardar correctamente")),
                    a!startProcess(
                      processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                      processParameters: {
                        idSolicitud: ri!idSolicitud, idTarea: ri!idTarea,
                        resultado: a!map(
                          listaNombreDocs: local!listaNombreDocs, tipoGestion: cons!SCA2_TXT_TIPO_GESTION_ACCADM, nuuma: local!nuuma,
                          mcaEstadoFinal: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                          observaciones: local!observaciones,
                          tipoCatalogacion: local!tipoCatalogacionFinal,
                          fechaDisponibilidadVehiculo: local!fechaDisponibilidadVehiculo,
                          operacion: cons!SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS,
                          resultadoOperacion: "OK",
                          poliza: local!numPoliza,
                          cliente: index(local!searchAPI, "clientId", null),
                          tipoPersona: local!checksPECA,
                          perfilUsuario: local!codSubPerfil)},
                      onSuccess: {},
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: {}),
                    a!save(ri!onCompletar, true)
                  },
                  submit: true, style: "SOLID", color: cons!SCA2_VAL_COLOR_ROJO,
                  disabled: not(local!documentosEntregados),
                  tooltip: if(local!documentosEntregados, "", "Es necesario informar la entrega de algún documento"),
                  confirmHeader: "¿Desea continuar?",
                  confirmMessage: if(and(local!causaExigeContrato, not(local!9Adjunto)),
                    "Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento",
                    "Se va a finalizar la revisión de acciones administrativas"),
                  confirmButtonLabel: "ACEPTAR", cancelButtonLabel: "CANCELAR")
              },
              secondaryButtons: {
                if(local!mostrarBotonCancelar,
                  a!buttonWidget(
                    label: "CANCELAR",
                    saveInto: {
                      /* Paridad SCA (datosAccionesAdministrativas.observaciones → guardarAccAdm CANCELADO): la observación llega a la gestión CORE */
                      if(a!isNullOrEmpty(local!observaciones), {},
                        a!save(local!respuesta, index(rule!SCA2_insertarObservaciones(
                          nuuma: local!nuuma, codSolicitud: ri!idSolicitud,
                          txtObservaciones: local!observaciones, tipoGestion: local!tipoGestion), "success", false))),
                      a!startProcess(
                        processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                        processParameters: {
                          idSolicitud: ri!idSolicitud, idTarea: ri!idTarea,
                          resultado: a!map(
                            mcaEstadoFinal: "CANCELADO",
                            operacion: cons!SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS,
                            resultadoOperacion: "CANCELAR",
                            poliza: local!numPoliza,
                            cliente: index(local!searchAPI, "clientId", null),
                            tipoPersona: local!checksPECA,
                            perfilUsuario: local!codSubPerfil)},
                      onSuccess: {},
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: {}),
                      a!save(ri!onCompletar, true)
                    },
                    submit: true, style: "LINK", color: cons!SCA2_VAL_COLOR_ROJO,
                    confirmHeader: "¿Desea continuar?",
                    confirmMessage: "Va a proceder a cancelar la solicitud de anulación",
                    confirmButtonLabel: "ACEPTAR", cancelButtonLabel: "CANCELAR"),
                  {}),
                if(local!mostrarBotonPosponer,
                  a!buttonWidget(
                    label: "POSPONER",
                    saveInto: {
                      a!save(local!errorPosponer, null),
                      a!startProcess(
                        processModel: cons!SCA2_PM_CMD_POSPONER,
                        processParameters: {
                          idSolicitud: ri!idSolicitud, idTarea: ri!idTarea,
                          fechaDietario: todate(rule!SCA2_obtenerCaducidadNivel(
                            codPerfil: local!codPerfil, mecanizar: false,
                            fechaVencimiento: null, nivel: "2")),
                          motivo: local!observaciones,
                          /* Paridad SCA_posponerAccAdm: el CMD da de alta la gestión SGC, guarda idGestionSGC e inserta la observación en CORE */
                          tipoAccion: cons!SCA2_TXT_TIPO_GESTION_ACCADM,
                          tipoGestionObs: local!tipoGestion,
                          detalleOficina: local!detalleOficina,
                          fecDispoVeh: if(a!isNullOrEmpty(local!fechaDisponibilidadVehiculo), null, tostring(todate(local!fechaDisponibilidadVehiculo))),
                          /* Paridad PM SCA Acciones Administrativas (Caducada? → Subir Docs Documentum BBDD → Posponer): los adjuntos consolidados en pantalla se suben a GD/CORE al POSPONER */
                          listaNombreDocs: if(a!defaultValue(local!noEntregaDoc, false), {}, local!listaNombreDocs),
                          nuuma: local!nuuma},
                        onError: {
                          a!save(local!errorPosponer, "Error al posponer la solicitud")},
                        onSuccess: {
                          a!save(ri!onCompletar, true)},
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: {
                          a!save(ri!onCompletar, true)}),
                    },
                    style: "OUTLINE", color: cons!SCA2_VAL_COLOR_ROJO,
                    submit: true,
                    disabled: a!defaultValue(index(local!sol, "estado", "contadorPosponer", 0), 0) > 0,
                    tooltip: if(a!defaultValue(index(local!sol, "estado", "contadorPosponer", 0), 0) > 0,
                      "La acción ya ha sido pospuesta", ""),
                    confirmHeader: "¿Desea continuar?",
                    confirmMessage: "Se va a posponer la solicitud de anulación",
                    confirmButtonLabel: "ACEPTAR", cancelButtonLabel: "CANCELAR",
                    validate: true),
                  {})
              }),
            if(a!isNotNullOrEmpty(local!errorPosponer),
              a!richTextDisplayField(labelPosition: "COLLAPSED",
                value: a!richTextItem(text: local!errorPosponer, style: "STRONG", color: "NEGATIVE")),
              {}),
            /* Traza cliente + gestión accAdm (sustituye al PM SCA_GUARDAR_TRAZABILIDAD, inexistente en SCA2) */
            a!richTextDisplayField(value: tostring(local!numGestion), showWhen: false),
            rule!SCA2_PieDePagina()
          },
          padding: "NONE", marginAbove: "NONE", showBorder: false())
      },
      showBorder: false)
  }
)
