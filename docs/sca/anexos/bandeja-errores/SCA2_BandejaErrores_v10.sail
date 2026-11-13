a!localVariables(
  local!pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 15,
    sort: {a!sortInfo(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', ascending: false)}),
  local!fEstado: "PENDIENTE",
  local!fComando,
  local!fSolicitud,
  local!fFecha,
  local!cmdsRelanzables: {"SCA2 CMD Decidir", "SCA2 CMD CrearAccion", "SCA2 CMD CompletarAccion", "SCA2 CMD Finalizar", "SCA2 CMD Mecanizar", "SCA2 CMD Caducar"},
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
          choiceValues: {"PENDIENTE", "RELANZADO", "DESCARTADO", "BLOQUEADO"},
          value: local!fEstado, saveInto: {local!fEstado, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!dropdownField(label: "Comando", placeholder: "Todos",
          choiceLabels: {"Alta", "Decidir", "CrearAccion", "CompletarAccion", "Finalizar", "Mecanizar", "Caducar", "Posponer", "CambiarNivel", "ObtenerDocumentoGD"},
          choiceValues: {"SCA2 CMD Alta", "SCA2 CMD Decidir", "SCA2 CMD CrearAccion", "SCA2 CMD CompletarAccion", "SCA2 CMD Finalizar", "SCA2 CMD Mecanizar", "SCA2 CMD Caducar", "SCA2 CMD Posponer", "SCA2 CMD CambiarNivel", "SCA2 CMD ObtenerDocumentoGD"},
          value: local!fComando, saveInto: {local!fComando, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!textField(label: "Solicitud", value: local!fSolicitud, refreshAfter: "UNFOCUS",
          saveInto: {local!fSolicitud, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})}),
        a!columnLayout(contents: {a!dateField(label: "Fecha desde", value: local!fFecha,
          saveInto: {local!fFecha, a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))})})
      }),
      a!buttonLayout(secondaryButtons: {
        a!buttonWidget(label: "Limpiar filtros", style: "GHOST", size: "SMALL",
          saveInto: {a!save(local!fEstado, "PENDIENTE"), a!save(local!fComando, null), a!save(local!fSolicitud, null), a!save(local!fFecha, null), a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!pagingInfo, a!pagingInfo(startIndex: 1, batchSize: 15, sort: index(local!pagingInfo, "sort", null)))}),
        a!buttonWidget(label: "Actualizar", style: "OUTLINE", size: "SMALL",
          saveInto: {a!save(local!msgOk, null), a!save(local!msgError, null), a!save(local!refresco, local!refresco + 1)})
      }),
      a!gridField_25r3(
        labelPosition: "COLLAPSED", label: "grid",
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
                a!defaultValue(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', null), "") = "PENDIENTE",
                not(contains(tointeger(local!tratados), tointeger(local!idErr)))),
              local!esAlta: local!cmdBase = "SCA2 CMD Alta",
              local!altaConDatos: and(local!esAlta, a!isNotNullOrEmpty(index(fv!row, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload', null))),
              local!relanzable: or(contains(local!cmdsRelanzables, local!cmdBase), local!altaConDatos),
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