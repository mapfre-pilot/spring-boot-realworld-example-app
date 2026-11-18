a!localVariables(
  local!pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 15,
    sort: {a!sortInfo(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', ascending: false)}),
  local!fEstado: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
  local!fComando,
  local!fSolicitud,
  local!fFecha,
  local!fNodo,
  local!fCodigo,
  local!fMensaje,
  /* R54: selección para relanzar/descartar en bloque (máx. 50, solo PENDIENTE, un lote a la vez) */
  local!sel: tointeger({}),
  local!maxLote: 50,
  local!cmdsRelanzables: {"SCA2 CMD Decidir", "SCA2 CMD CrearAccion", "SCA2 CMD CompletarAccion", "SCA2 CMD Finalizar", "SCA2 CMD Mecanizar", "SCA2 CMD Caducar", "SCA2 CMD MecanizarNSE", "SCA2 TTQ GrabarTreboles"},
  /* R46-D: relanzamiento de la grabación de tréboles en TTQ (entrega parcial Club OK + TTQ KO) */
  local!resTTQ,
  local!refresco: 0,
  local!tratados: tointeger({}),
  local!msgOk,
  local!msgError,
  local!q: a!refreshVariable(
    value: a!queryRecordType(
      recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
      filters: a!queryLogicalExpression(operator: "AND", filters: {
        a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', operator: ">", value: 0),
        if(a!isNullOrEmpty(local!fEstado), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', operator: "=", value: local!fEstado)),
        if(a!isNullOrEmpty(local!fComando), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', operator: "starts with", value: local!fComando)),
        if(a!isNullOrEmpty(local!fNodo), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo', operator: "=", value: local!fNodo)),
        if(a!isNullOrEmpty(local!fCodigo), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo', operator: "=", value: local!fCodigo)),
        if(a!isNullOrEmpty(trim(local!fMensaje)), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje', operator: "includes", value: trim(local!fMensaje))),
        if(a!isNullOrEmpty(local!fSolicitud), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', operator: "=", value: trim(local!fSolicitud))),
        if(a!isNullOrEmpty(local!fFecha), {}, a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', operator: ">=", value: userdatetime(year(local!fFecha), month(local!fFecha), day(local!fFecha), 0, 0, 0)))
      }),
      fields: {
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado',
      'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion'},
      pagingInfo: local!pagingInfo,
      fetchTotalCount: true),
    refreshOnVarChange: local!refresco),
  local!opciones: a!localVariables(
    local!agr: a!forEach(items: {'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo'}, expression: index(a!queryRecordType(
      recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
      fields: a!aggregationFields(groupings: a!grouping(field: fv!item, alias: "g"), measures: a!measure(function: "COUNT", field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', alias: "n")),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500, sort: a!sortInfo(field: "g", ascending: true))
    ).data, "g", {})),
    local!cmds: a!forEach(items: touniformstring(a!flatten(local!agr[1])), expression: index(split(fv!item, " - "), 1, fv!item)),
    a!map(
      comando: union(touniformstring(local!cmds), touniformstring(local!cmds)),
      nodo: reject(fn!isnull, touniformstring(a!flatten(local!agr[2]))),
      codigo: reject(fn!isnull, touniformstring(a!flatten(local!agr[3])))
    )
  ),
  /* Lote en curso: última fila de SCA2 Transicion del lote; caduca a los 15 min por si el proceso se interrumpe */
  local!ultLote: a!refreshVariable(
    value: index(a!queryRecordType(
      recordType: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion',
      fields: {'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{afb1bd95-e12a-4919-a15d-9a414a6857cd}resultado', 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha', 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{0b577c50-0666-4463-9ef5-2685e450e1f4}usuario', 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{c5a7d996-9a79-4c92-afa2-7930f4d967c1}detalle'},
      filters: a!queryLogicalExpression(operator: "AND", filters: {
        a!queryFilter(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{cb874e4d-61fb-4bd1-8062-e138a364eb82}comando', operator: "=", value: "SCA2 Lote Errores"),
        a!queryFilter(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{b2f33c59-6234-472c-b7ec-5065bbdc20fd}idSolicitud', operator: "=", value: "LOTE")
      }),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha', ascending: false))
    ).data, 1, null),
    refreshOnVarChange: local!refresco,
    refreshInterval: 0.5
  ),
  local!loteEnCurso: and(
    a!isNotNullOrEmpty(local!ultLote),
    a!defaultValue(index(local!ultLote, 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{afb1bd95-e12a-4919-a15d-9a414a6857cd}resultado', null), "") = "EN_CURSO",
    a!defaultValue(index(local!ultLote, 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha', null), now() - 1) > now() - intervalds(0, 15, 0)
  ),
  local!filasSel: if(
    a!isNullOrEmpty(local!sel),
    {},
    a!queryRecordType(
      recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
      fields: {'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload'},
      filters: a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', operator: "in", value: tointeger(a!flatten(local!sel))),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 100)
    ).data
  ),
  local!selPend: if(
    a!isNullOrEmpty(local!filasSel),
    {},
    index(local!filasSel, wherecontains(cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE, touniformstring(a!forEach(items: local!filasSel, expression: a!defaultValue(index(fv!item, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', null), "")))), {})
  ),
  local!selRelanzables: if(
    a!isNullOrEmpty(local!selPend),
    {},
    index(local!selPend, where(a!forEach(items: local!selPend, expression: a!localVariables(
      local!base: index(split(a!defaultValue(index(fv!item, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', null), ""), " - "), 1, ""),
      or(
        and(contains(local!cmdsRelanzables, local!base), local!base <> "SCA2 TTQ GrabarTreboles"),
        and(local!base = "SCA2 CMD Alta", a!isNotNullOrEmpty(index(fv!item, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null)))
      )
    ))), {})
  ),
  local!idSel,
  if(a!isNotNullOrEmpty(local!idSel),
    a!sectionLayout(label: "Detalle", contents: {
      a!buttonLayout(secondaryButtons: {
        a!buttonWidget(label: "Volver a la bandeja", style: "GHOST", saveInto: {a!save(local!idSel, null), a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!refresco, local!refresco + 1)})
      }),
      rule!SCA2_DetalleSolicitud(idSolicitud: local!idSel)
    }),
    a!sectionLayout(label: "Bandeja de errores (" & a!defaultValue(index(local!q, "totalCount", null), 0) & ")", contents: {
      a!messageBanner(primaryText: local!msgOk, backgroundColor: "SUCCESS", highlightColor: "POSITIVE", icon: "check-circle", showWhen: a!isNotNullOrEmpty(local!msgOk)),
      a!messageBanner(primaryText: local!msgError, backgroundColor: "ERROR", highlightColor: "NEGATIVE", icon: "exclamation-circle", showWhen: a!isNotNullOrEmpty(local!msgError)),
      a!columnsLayout(columns: {
        a!columnLayout(contents: {a!dropdownField(label: "Estado", placeholder: "Todos",
          choiceLabels: {"Pendiente", "Relanzado", "Descartado", "Bloqueado"},
          choiceValues: {cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE, "RELANZADO", "DESCARTADO", "BLOQUEADO"},
          value: local!fEstado, saveInto: {local!fEstado, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!dropdownField(label: "Comando", placeholder: "Todos", searchDisplay: "ON",
          choiceLabels: a!forEach(items: local!opciones.comando, expression: substitute(fv!item, "SCA2 CMD ", "")),
          choiceValues: local!opciones.comando,
          value: if(contains(touniformstring(local!opciones.comando), tostring(local!fComando)), local!fComando, null), saveInto: {local!fComando, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!dropdownField(label: "Nodo", placeholder: "Todos", searchDisplay: "ON",
          choiceLabels: local!opciones.nodo, choiceValues: local!opciones.nodo,
          value: if(contains(local!opciones.nodo, tostring(local!fNodo)), local!fNodo, null), saveInto: {local!fNodo, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!dropdownField(label: "Código", placeholder: "Todos", searchDisplay: "ON",
          choiceLabels: local!opciones.codigo, choiceValues: local!opciones.codigo,
          value: if(contains(local!opciones.codigo, tostring(local!fCodigo)), local!fCodigo, null), saveInto: {local!fCodigo, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})})
      }),
      a!columnsLayout(columns: {
        a!columnLayout(contents: {a!textField(label: "Mensaje contiene", placeholder: "Texto del mensaje", value: local!fMensaje, refreshAfter: "UNFOCUS",
          saveInto: {local!fMensaje, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!textField(label: "Solicitud", value: local!fSolicitud, refreshAfter: "UNFOCUS",
          saveInto: {local!fSolicitud, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!dateField(label: "Fecha desde", value: local!fFecha,
          saveInto: {local!fFecha, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})})
      }),
      a!messageBanner(
        primaryText: "Hay un lote en curso (" & a!defaultValue(index(local!ultLote, 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{c5a7d996-9a79-4c92-afa2-7930f4d967c1}detalle', null), "") & "). Espere a que termine para lanzar otro.",
        backgroundColor: "INFO", highlightColor: "ACCENT", icon: "hourglass-half",
        showWhen: local!loteEnCurso
      ),
      a!messageBanner(
        primaryText: "Ha seleccionado " & length(local!sel) & " errores; el máximo por lote es " & local!maxLote & ".",
        backgroundColor: "WARN", highlightColor: "WARN", icon: "exclamation-triangle",
        showWhen: length(local!sel) > local!maxLote
      ),
      a!buttonLayout(primaryButtons: {
        a!buttonWidget(label: "Relanzar seleccionados (" & length(local!selRelanzables) & ")", style: "OUTLINE", size: "SMALL", color: "ACCENT",
          disabled: or(local!loteEnCurso, length(local!selRelanzables) = 0, length(local!sel) > local!maxLote),
          confirmHeader: "Relanzar en bloque",
          confirmMessage: "Se van a relanzar " & length(local!selRelanzables) & " errores PENDIENTE, uno cada 10 segundos. Los no pendientes se omiten. ¿Desea continuar?",
          confirmButtonLabel: "Relanzar", cancelButtonLabel: "Cancelar",
          saveInto: a!localVariables(
            local!idLote: "L" & text(now(), "yyyyMMddHHmmss"),
            {
              a!save(local!msgOk, null),
              a!save(local!msgError, null),
              a!writeRecords(
                records: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion'(
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{b2f33c59-6234-472c-b7ec-5065bbdc20fd}idSolicitud': "LOTE",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{cb874e4d-61fb-4bd1-8062-e138a364eb82}comando': "SCA2 Lote Errores",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{da4a8a6f-4328-4c24-a224-11e161e714fd}estadoOrigen': "RELANZAR",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{d90be983-e71a-4e50-9d1c-47ef9409f016}estadoDestino': "EN_CURSO",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{7d88ecb4-e44a-4769-9406-e6f929dde5e1}claveIdempotencia': local!idLote,
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{afb1bd95-e12a-4919-a15d-9a414a6857cd}resultado': "EN_CURSO",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{c5a7d996-9a79-4c92-afa2-7930f4d967c1}detalle': "Lote " & local!idLote & ": relanzar " & length(local!selRelanzables) & " errores, iniciado por " & loggedInUser(),
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{0b577c50-0666-4463-9ef5-2685e450e1f4}usuario': loggedInUser(),
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now()
                ),
                onSuccess: a!startProcess(
                  processModel: cons!SCA2_PM_CMD_PROCESAR_LOTE_ERRORES,
                  processParameters: {
                    ids: tointeger(index(local!selRelanzables, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', {})),
                    solicitudes: touniformstring(index(local!selRelanzables, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', {})),
                    comandos: touniformstring(index(local!selRelanzables, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', {})),
                    accion: "RELANZAR",
                    idLote: local!idLote,
                    procesados: 0,
                    omitidos: 0
                  },
                  onSuccess: {
                    a!save(local!msgOk, "Lote " & local!idLote & " iniciado: " & length(local!selRelanzables) & " errores, uno cada 10 segundos. Pulse Actualizar para ver el avance."),
                    a!save(local!sel, tointeger({})),
                    a!save(local!refresco, local!refresco + 1)
                  },
                  onError: a!save(local!msgError, "No se ha podido iniciar el lote. El bloqueo se libera solo en 15 minutos.")
                ),
                onError: a!save(local!msgError, "No se ha podido registrar el lote.")
              )
            }
          )
        ),
        a!buttonWidget(label: "Descartar seleccionados (" & length(local!selPend) & ")", style: "OUTLINE", size: "SMALL", color: "SECONDARY",
          disabled: or(local!loteEnCurso, length(local!selPend) = 0, length(local!sel) > local!maxLote),
          confirmHeader: "Descartar en bloque",
          confirmMessage: "Se van a descartar " & length(local!selPend) & " errores PENDIENTE, uno cada 10 segundos. Los no pendientes se omiten. ¿Desea continuar?",
          confirmButtonLabel: "Descartar", cancelButtonLabel: "Cancelar",
          saveInto: a!localVariables(
            local!idLote: "L" & text(now(), "yyyyMMddHHmmss"),
            {
              a!save(local!msgOk, null),
              a!save(local!msgError, null),
              a!writeRecords(
                records: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion'(
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{b2f33c59-6234-472c-b7ec-5065bbdc20fd}idSolicitud': "LOTE",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{cb874e4d-61fb-4bd1-8062-e138a364eb82}comando': "SCA2 Lote Errores",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{da4a8a6f-4328-4c24-a224-11e161e714fd}estadoOrigen': "DESCARTAR",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{d90be983-e71a-4e50-9d1c-47ef9409f016}estadoDestino': "EN_CURSO",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{7d88ecb4-e44a-4769-9406-e6f929dde5e1}claveIdempotencia': local!idLote,
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{afb1bd95-e12a-4919-a15d-9a414a6857cd}resultado': "EN_CURSO",
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{c5a7d996-9a79-4c92-afa2-7930f4d967c1}detalle': "Lote " & local!idLote & ": descartar " & length(local!selPend) & " errores, iniciado por " & loggedInUser(),
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{0b577c50-0666-4463-9ef5-2685e450e1f4}usuario': loggedInUser(),
                  'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha': now()
                ),
                onSuccess: a!startProcess(
                  processModel: cons!SCA2_PM_CMD_PROCESAR_LOTE_ERRORES,
                  processParameters: {
                    ids: tointeger(index(local!selPend, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', {})),
                    solicitudes: touniformstring(index(local!selPend, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', {})),
                    comandos: touniformstring(index(local!selPend, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', {})),
                    accion: "DESCARTAR",
                    idLote: local!idLote,
                    procesados: 0,
                    omitidos: 0
                  },
                  onSuccess: {
                    a!save(local!msgOk, "Lote " & local!idLote & " iniciado: " & length(local!selPend) & " errores, uno cada 10 segundos. Pulse Actualizar para ver el avance."),
                    a!save(local!sel, tointeger({})),
                    a!save(local!refresco, local!refresco + 1)
                  },
                  onError: a!save(local!msgError, "No se ha podido iniciar el lote. El bloqueo se libera solo en 15 minutos.")
                ),
                onError: a!save(local!msgError, "No se ha podido registrar el lote.")
              )
            }
          )
        ),
        a!buttonWidget(label: "Quitar selección", style: "GHOST", size: "SMALL", showWhen: length(local!sel) > 0, saveInto: a!save(local!sel, tointeger({})))
      }, secondaryButtons: {
        a!buttonWidget(label: "Limpiar filtros", style: "GHOST", size: "SMALL",
          saveInto: {a!save(local!fEstado, cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE), a!save(local!fComando, null), a!save(local!fSolicitud, null), a!save(local!fFecha, null), a!save(local!fNodo, null), a!save(local!fCodigo, null), a!save(local!fMensaje, null), a!save(local!sel, tointeger({})), a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))}),
        a!buttonWidget(label: "Actualizar", style: "OUTLINE", size: "SMALL",
          saveInto: {a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!refresco, local!refresco + 1)})
      }),
      a!gridField_25r3(
        labelPosition: "COLLAPSED", label: "grid",
        selectable: true,
        selectionValue: local!sel,
        selectionSaveInto: {a!save(local!sel, tointeger(a!flatten(save!value))), a!save(local!msgOk, null), a!save(local!msgError, null)},
        emptyGridMessage: "No hay errores con los filtros seleccionados.",
        data: a!dataSubset(
          startIndex: index(local!pagingInfo, "startIndex", 1),
          batchSize: index(local!pagingInfo, "batchSize", 15),
          sort: index(local!pagingInfo, "sort", null),
          totalCount: a!defaultValue(index(local!q, "totalCount", null), 0),
          data: index(local!q, "data", {}),
          identifiers: index(index(local!q, "data", {}), 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', {})
        ),
        columns: {
          a!gridColumn(label: "Solicitud", value: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null)),
          a!gridColumn(label: "Comando", value: index(split(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', null), ""), " - "), 1, "")),
          a!gridColumn(label: "Nodo", value: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo', null)),
          a!gridColumn(label: "Código", value: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo', null)),
          a!gridColumn(label: "Mensaje", value: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje', null)),
          a!gridColumn(label: "Intentos", value: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos', null), align: "END"),
          a!gridColumn(label: "Fecha", value: if(a!isNullOrEmpty(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', null)), "", text(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', null), "dd/mm/yyyy hh:mm"))),
          a!gridColumn(label: "Estado", value: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', null), showWhen: a!isNullOrEmpty(local!fEstado)),
          a!gridColumn(label: "Relanzamiento",
            value: a!localVariables(
              local!cmdBase: index(split(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', null), ""), " - "), 1, ""),
              if(contains(local!cmdsRelanzables, local!cmdBase), "Automático",
                if(local!cmdBase = "SCA2 CMD Alta",
                  if(a!isNotNullOrEmpty(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null)), "Automático (alta)", "Repetir alta desde la pantalla Alta"),
                  "Repetir la acción desde la tarea")))
          ),
          a!gridColumn(label: "Acciones", width: "MEDIUM",
            value: a!localVariables(
              local!idErr: index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', null),
              local!cmd: a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', null), ""),
              local!cmdBase: index(split(local!cmd, " - "), 1, ""),
              local!esPendiente: and(
                a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', null), "") = cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
                not(contains(tointeger(local!tratados), tointeger(local!idErr)))),
              local!esAlta: local!cmdBase = "SCA2 CMD Alta",
              local!altaConDatos: and(local!esAlta, a!isNotNullOrEmpty(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null))),
              local!relanzable: and(or(contains(local!cmdsRelanzables, local!cmdBase), local!altaConDatos), /* Decidir solo se relanza si la solicitud sigue en ERROR_DECISION (MarcarErrorRelanzado v37 descarta el resto) */ if(and(local!esPendiente, local!cmdBase = "SCA2 CMD Decidir"), a!defaultValue(tostring(index(index(rule!SCA2_cargarSolicitud(tostring(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null))), "estado", null), "estadoSolicitud", null)), "") = "ERROR_DECISION", true)),
              a!buttonArrayLayout(align: "START", marginBelow: "NONE", buttons: {
                a!buttonWidget(label: "Relanzar", size: "SMALL", style: "OUTLINE", color: "ACCENT",
                  showWhen: and(local!esPendiente, local!relanzable),
                  confirmHeader: "Relanzar error",
                  confirmMessage: "Se va a relanzar «" & local!cmdBase & "» para la solicitud " & a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null), "-") & ". ¿Desea continuar?",
                  confirmButtonLabel: "Relanzar", cancelButtonLabel: "Cancelar",
                  loadingIndicator: true,
                  saveInto: {
                    a!save(local!msgOk, null),
                    a!save(local!msgError, null),
                      if(
                      local!cmdBase = "SCA2 TTQ GrabarTreboles",
                      {
                        a!save(local!resTTQ, null),
                        rule!SCA2_gestionarTTQRESTIntegracion(
                          numPoliza: index(a!fromJson(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null), "{}")), "numPoliza", null),
                          codTipBon: index(a!fromJson(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null), "{}")), "codTipBon", null),
                          numTipBon: index(a!fromJson(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null), "{}")), "numTipBon", null),
                          fecVigencia: index(a!fromJson(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null), "{}")), "fecVigencia", null),
                          numSolicitudPca: index(a!fromJson(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null), "{}")), "numSolicitudPca", null),
                          numBonAplic: index(a!fromJson(a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null), "{}")), "numBonAplic", null),
                          onSuccess: a!save(local!resTTQ, index(a!fromJson_19r2(index(fv!result, "body", null)), "valor", null)),
                          onError: a!save(local!resTTQ, null)
                        ),
                        if(
                          a!isNullOrEmpty(local!resTTQ),
                          a!save(local!msgError, "TTQ no ha grabado los tréboles de la solicitud " & a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null), "-") & ". El error sigue pendiente; inténtelo más tarde."),
                          a!writeRecords(
                            records: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error'(
                              'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id': local!idErr,
                              'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado': "RELANZADO",
                              'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos': a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos', null), 0) + 1,
                              'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{a447ab30-a57c-45b1-a57f-5784bd6897a1}resueltoPor': loggedInUser(),
                              'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{6222f0af-bc41-4207-aad2-e756495f3d81}fechaResolucion': now()
                            ),
                            onSuccess: {
                              a!save(local!msgOk, "Tréboles grabados en TTQ para la solicitud " & a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null), "-")),
                              a!save(local!tratados, append(local!tratados, local!idErr)),
                              a!save(local!refresco, local!refresco + 1)
                            },
                            onError: a!save(local!msgError, "Tréboles grabados en TTQ, pero no se ha podido marcar el error como relanzado: " & tostring(fv!error))
                          )
                        )
                      },
                      a!startProcess(
                        processModel: cons!SCA2_PM_CMD_MARCAR_ERROR_RELANZADO,
                        processParameters: {
                          idError: local!idErr,
                          idSolicitud: tostring(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null)),
                          comando: local!cmd
                        },
                        isSynchronous: true,
                        onSuccess: {
                          a!save(local!msgOk, "Relanzado «" & local!cmdBase & "» para la solicitud " & a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null), "-") & ". El error queda marcado como RELANZADO; si vuelve a fallar aparecerá un error nuevo."),
                          a!save(local!tratados, append(local!tratados, local!idErr)),
                          a!save(local!refresco, local!refresco + 1)
                        },
                        onError: {a!save(local!msgError, "No se ha podido iniciar el relanzamiento. Inténtelo de nuevo o revise el proceso en Monitoring.")},
                        onIncomplete: {
                          a!save(local!msgOk, "El relanzamiento se ha iniciado pero sigue en curso. Actualice la bandeja en unos segundos."),
                          a!save(local!tratados, append(local!tratados, local!idErr)),
                          a!save(local!refresco, local!refresco + 1)
                        }
                      )
                    )
                  }
                ),
                a!buttonWidget(label: "Descartar", size: "SMALL", style: "GHOST", color: "SECONDARY",
                  showWhen: local!esPendiente,
                  confirmHeader: "Descartar error",
                  confirmMessage: "El error dejará de aparecer como pendiente y no se relanzará. ¿Desea continuar?",
                  confirmButtonLabel: "Descartar", cancelButtonLabel: "Cancelar",
                  saveInto: {
                    a!save(local!msgOk, null),
                    a!save(local!msgError, null),
                    a!writeRecords(
                      records: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error'(
                        'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id': local!idErr,
                        'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado': "DESCARTADO",
                        'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{a447ab30-a57c-45b1-a57f-5784bd6897a1}resueltoPor': loggedInUser(),
                        'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{6222f0af-bc41-4207-aad2-e756495f3d81}fechaResolucion': now()
                      ),
                      onSuccess: {
                        a!save(local!msgOk, "Error descartado."),
                        a!save(local!tratados, append(local!tratados, local!idErr)),
                        a!save(local!refresco, local!refresco + 1)
                      },
                      onError: {a!save(local!msgError, "No se ha podido descartar el error.")}
                    )
                  }
                )
              })
            )
          ),
          a!gridColumn(label: "", value: a!linkField(links: {a!dynamicLink(label: "Ver solicitud",
              showWhen: a!isNotNullOrEmpty(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null)),
              saveInto: {a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!idSel, index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', null))}
            )}))
        },
        pagingSaveInto: local!pagingInfo,
        validations: {}
      )
    })
  )
)