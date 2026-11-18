/*
[SCA2] Mantenimiento — Pendientes de autorizar (wAutemis).
Listado de solicitudes cuya mecanización está esperando la respuesta de ANL/wAutemis
(SCA2 Solicitud: procesoActivo = "ANL" y origenPoliza = "wAutemis").
Acciones de prueba (no cambian la lógica de SCA2):
 - AUTORIZAR / RECHAZAR: lanzan el PM «ANL Desbloquear» (cons!SCA2_PM_ANL_DESBLOQUEAR) con los
   mismos parámetros que la Web API «ANL Desbloquear SGO» (estado "1" = autorizar, "2" = rechazar).
   El PM actualiza ANL Anulacion y «SCA2 CMD Mecanizar» lo detecta en su siguiente sondeo (≤ 5 min).
 - CANCELAR: igual que CANCELAR de la pantalla de Autorización (CORE guardarAutorizacion codEstado 5)
   y «SCA2 CMD Finalizar» con estadoFinal CANCELADA, sin llamar a ANL.
Inputs: (ninguno)
*/
a!localVariables(
  local!usuario: index(rule!SCA2_obtenerInformacionUsuario(), "infoUsuarioDTO", {}),
  local!nuumaUsuario: a!defaultValue(index(local!usuario, "nuuma", null), loggedInUser()),
  local!refresco: 0,
  local!idSel: null,
  local!mensaje: null,
  local!tipoMensaje: null,
  local!accionEnCurso: false,
  local!observaciones: null,
  local!pendientes: a!refreshVariable(
    value: a!queryRecordType(
      recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
      fields: {
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6da95481-fa80-4768-9b86-2fae6259874e}nivelIntervencion',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{425684ff-66e8-4c2a-a9dd-254a071d3ecd}grupoAsignacion',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ed8367f4-e16c-41fc-88c3-da2cc19d6ef6}usuario',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza',
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt'
      },
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo', operator: "=", value: "ANL"),
          a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: "wAutemis")
        }
      ),
      pagingInfo: a!pagingInfo(
        startIndex: 1,
        batchSize: 100,
        sort: a!sortInfo(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt', ascending: false)
      ),
      fetchTotalCount: true
    ).data,
    refreshOnVarChange: local!refresco,
    refreshInterval: 1
  ),
  local!ids: a!forEach(items: local!pendientes, expression: fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud']),
  /* Grupo / subgrupo del usuario SCA que dejó la solicitud pendiente de autorizar (Datos Perfiles Pca) */
  local!perfiles: if(
    a!isNullOrEmpty(local!ids),
    {},
    a!queryRecordType(
      recordType: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca',
      fields: {
        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud',
        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{9e7da6f2-78d1-4f46-bfdf-ba8fe8a70e10}codsubperfil',
        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{a71794d3-baab-46d5-9fcc-d2d6845cd0ec}nuuma'
      },
      filters: a!queryFilter(field: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud', operator: "in", value: local!ids),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500)
    ).data
  ),
  if(
    a!isNotNullOrEmpty(local!idSel),
    /* ---- Detalle navegable de la solicitud seleccionada ---- */
    {
      a!buttonArrayLayout(
        buttons: a!buttonWidget(
          label: "VOLVER AL LISTADO",
          icon: "arrow-left",
          style: "LINK",
          saveInto: a!save(local!idSel, null)
        ),
        align: "START",
        marginBelow: "NONE"
      ),
      rule!SCA2_DetalleSolicitud(idSolicitud: local!idSel, idSel: local!idSel)
    },
    /* ---- Listado ---- */
    {
      a!richTextDisplayField(
        labelPosition: "COLLAPSED",
        value: {
          a!richTextItem(
            text: "Solicitudes de pólizas wAutemis cuya mecanización está pendiente de autorizar en ANL (SGO). ",
            color: "SECONDARY"
          ),
          a!richTextItem(
            text: "Autorizar y Rechazar lanzan el proceso ANL Desbloquear (como la Web API «ANL Desbloquear SGO»); SCA2 recoge la respuesta en su siguiente sondeo (máx. 5 min). Cancelar cierra la solicitud directamente sin pasar por ANL.",
            color: "SECONDARY",
            size: "SMALL"
          )
        }
      ),
      a!textField(
        label: "Observaciones (opcional, se envían a ANL en Autorizar / Rechazar)",
        value: local!observaciones,
        saveInto: local!observaciones,
        characterLimit: 220,
        showCharacterCount: true
      ),
      a!sideBySideLayout(
        items: {
          a!sideBySideItem(
            item: a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: length(local!pendientes) & " solicitud(es) pendiente(s)",
                style: "STRONG"
              )
            )
          ),
          a!sideBySideItem(
            item: a!buttonArrayLayout(
              buttons: a!buttonWidget(
                label: "ACTUALIZAR",
                icon: "refresh",
                size: "SMALL",
                style: "OUTLINE",
                saveInto: a!save(local!refresco, local!refresco + 1)
              ),
              align: "END",
              marginBelow: "NONE"
            ),
            width: "MINIMIZE"
          )
        },
        alignVertical: "MIDDLE"
      ),
      a!gridLayout(
        label: "",
        labelPosition: "COLLAPSED",
        emptyGridMessage: "No hay solicitudes wAutemis pendientes de autorizar",
        headerCells: {
          a!gridLayoutHeaderCell(label: "Solicitud"),
          a!gridLayoutHeaderCell(label: "Póliza"),
          a!gridLayoutHeaderCell(label: "Grupo"),
          a!gridLayoutHeaderCell(label: "Subgrupo"),
          a!gridLayoutHeaderCell(label: "Usuario"),
          a!gridLayoutHeaderCell(label: "Fecha"),
          a!gridLayoutHeaderCell(label: "Acciones", align: "CENTER")
        },
        columnConfigs: {
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 2),
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 2),
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 2),
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 3),
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 2),
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 3),
          a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 5)
        },
        rows: a!forEach(
          items: local!pendientes,
          expression: a!localVariables(
            local!idSolicitud: tostring(fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud']),
            local!numPoliza: tostring(fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza']),
            local!nivel: tostring(a!defaultValue(fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6da95481-fa80-4768-9b86-2fae6259874e}nivelIntervencion'], 1)),
            local!perfil: index(
              a!forEach(items: local!perfiles, expression: if(tostring(fv!item['recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud']) = local!idSolicitud, fv!item, {})),
              1, null
            ),
            local!grupo: a!defaultValue(
              index(local!perfil, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil', null),
              fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{425684ff-66e8-4c2a-a9dd-254a071d3ecd}grupoAsignacion']
            ),
            local!subgrupo: index(local!perfil, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{9e7da6f2-78d1-4f46-bfdf-ba8fe8a70e10}codsubperfil', null),
            local!nuumaSol: a!defaultValue(
              index(local!perfil, 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{a71794d3-baab-46d5-9fcc-d2d6845cd0ec}nuuma', null),
              fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ed8367f4-e16c-41fc-88c3-da2cc19d6ef6}usuario']
            ),
            a!gridRowLayout(
              contents: {
                a!linkField(
                  labelPosition: "COLLAPSED",
                  links: a!dynamicLink(label: local!idSolicitud, saveInto: a!save(local!idSel, local!idSolicitud))
                ),
                a!textField(labelPosition: "COLLAPSED", value: local!numPoliza, readOnly: true),
                a!textField(labelPosition: "COLLAPSED", value: local!grupo, readOnly: true),
                a!textField(labelPosition: "COLLAPSED", value: local!subgrupo, readOnly: true),
                a!textField(labelPosition: "COLLAPSED", value: local!nuumaSol, readOnly: true),
                a!textField(
                  labelPosition: "COLLAPSED",
                  value: text(fv!item['recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt'], "dd/mm/yyyy hh:mm"),
                  readOnly: true
                ),
                a!buttonArrayLayout(
                  buttons: {
                    a!buttonWidget(
                      label: "AUTORIZAR",
                      size: "SMALL",
                      style: "SOLID",
                      color: "#2E7D32",
                      disabled: local!accionEnCurso,
                      confirmMessage: "Se va a AUTORIZAR en ANL la anulación de la solicitud " & local!idSolicitud & " (póliza " & local!numPoliza & "). ¿Continuar?",
                      saveInto: {
                        a!save(local!accionEnCurso, true),
                        a!startProcess(
                          processModel: cons!SCA2_PM_ANL_DESBLOQUEAR,
                          processParameters: {
                            idSolicitud: local!idSolicitud,
                            estado: "1",
                            desbloqueoAnulacion: "S",
                            nuumaNew: local!nuumaUsuario,
                            observacionesNew: left(a!defaultValue(local!observaciones, "Autorizada desde SCA2 mantenimiento"), 220),
                            sistema: "SGO",
                            nivelGestion: local!nivel
                          },
                          onSuccess: {
                            a!save(local!tipoMensaje, "OK"),
                            a!save(local!mensaje, "Solicitud " & local!idSolicitud & ": AUTORIZACIÓN enviada a ANL (proceso " & fv!processInfo.pp.id & "). SCA2 la recogerá en su siguiente sondeo (máx. 5 min)."),
                            a!save(local!accionEnCurso, false)
                          },
                          onError: {
                            a!save(local!tipoMensaje, "ERROR"),
                            a!save(local!mensaje, "No se ha podido lanzar ANL Desbloquear para la solicitud " & local!idSolicitud & "."),
                            a!save(local!accionEnCurso, false)
                          }
                        )
                      }
                    ),
                    a!buttonWidget(
                      label: "RECHAZAR",
                      size: "SMALL",
                      style: "SOLID",
                      color: "NEGATIVE",
                      disabled: local!accionEnCurso,
                      confirmMessage: "Se va a RECHAZAR en ANL la anulación de la solicitud " & local!idSolicitud & " (póliza " & local!numPoliza & "). ¿Continuar?",
                      saveInto: {
                        a!save(local!accionEnCurso, true),
                        a!startProcess(
                          processModel: cons!SCA2_PM_ANL_DESBLOQUEAR,
                          processParameters: {
                            idSolicitud: local!idSolicitud,
                            estado: "2",
                            desbloqueoAnulacion: "S",
                            nuumaNew: local!nuumaUsuario,
                            observacionesNew: left(a!defaultValue(local!observaciones, "Rechazada desde SCA2 mantenimiento"), 220),
                            sistema: "SGO",
                            nivelGestion: local!nivel
                          },
                          onSuccess: {
                            a!save(local!tipoMensaje, "OK"),
                            a!save(local!mensaje, "Solicitud " & local!idSolicitud & ": RECHAZO enviado a ANL (proceso " & fv!processInfo.pp.id & "). SCA2 lo recogerá en su siguiente sondeo (máx. 5 min)."),
                            a!save(local!accionEnCurso, false)
                          },
                          onError: {
                            a!save(local!tipoMensaje, "ERROR"),
                            a!save(local!mensaje, "No se ha podido lanzar ANL Desbloquear para la solicitud " & local!idSolicitud & "."),
                            a!save(local!accionEnCurso, false)
                          }
                        )
                      }
                    ),
                    a!buttonWidget(
                      label: "CANCELAR",
                      size: "SMALL",
                      style: "OUTLINE",
                      color: "SECONDARY",
                      disabled: local!accionEnCurso,
                      confirmMessage: "Se va a CANCELAR la solicitud " & local!idSolicitud & " (póliza " & local!numPoliza & ") directamente, sin pasar por ANL. ¿Continuar?",
                      saveInto: {
                        a!save(local!accionEnCurso, true),
                        a!localVariables(
                          local!datosAut: index(
                            rule!SCA2_consultarAutorizacion(mseConsultarAutorizacionesDTO: {codSolicitud: local!idSolicitud}),
                            "MSSConsultarAutorizacion", {}
                          ),
                          local!res: rule!SCA2_guardarAutorizacion(
                            mseGuardarAutorizacionDTO: {
                              codSolicitud: local!idSolicitud,
                              codPca: "", descPca: "",
                              mcaAutorizada: "N",
                              nivelIntervencion: local!nivel,
                              numSgo: "",
                              fecAnulAutorizada: tostring(today()),
                              infoUsuario: {
                                codCiaUsuario: index(local!usuario, "codCiaUsuario", null),
                                nuuma: local!nuumaUsuario,
                                codPerfil: index(local!usuario, "codPerfil", null),
                                codSubPerfil: index(local!usuario, "codSubPerfil", null)
                              },
                              codEstado: "5",
                              codGestion: index(local!datosAut, "codGestion", null),
                              tipoAutorizacion: index(local!datosAut, "tipoAutorizacion", null)
                            }
                          ),
                          local!cuerpo: tostring(a!defaultValue(index(index(local!res, "result", null), "body", null), "")),
                          local!ok: and(
                            a!defaultValue(index(local!res, "success", false), false),
                            search("<faultcode>", local!cuerpo) = 0,
                            search("<faultstring>", local!cuerpo) = 0,
                            a!isNullOrEmpty(index(index(local!res, "error", null), "faultString", null))
                          ),
                          if(
                            local!ok,
                            a!startProcess(
                              processModel: cons!SCA2_PM_CMD_FINALIZAR,
                              processParameters: {idSolicitud: local!idSolicitud, estadoFinal: "CANCELADA"},
                              onSuccess: {
                                a!save(local!tipoMensaje, "OK"),
                                a!save(local!mensaje, "Solicitud " & local!idSolicitud & " cancelada en CORE (autorización codEstado 5) y finalizada en SCA2 como CANCELADA."),
                                a!save(local!accionEnCurso, false),
                                a!save(local!refresco, local!refresco + 1)
                              },
                              onError: {
                                a!save(local!tipoMensaje, "ERROR"),
                                a!save(local!mensaje, "Cancelada en CORE pero no se ha podido lanzar SCA2 CMD Finalizar para " & local!idSolicitud & "."),
                                a!save(local!accionEnCurso, false)
                              }
                            ),
                            {
                              a!save(local!tipoMensaje, "ERROR"),
                              a!save(
                                local!mensaje,
                                "No se ha podido cancelar la autorización en CORE (guardarAutorizacion): " &
                                  a!defaultValue(
                                    index(index(local!res, "error", null), "faultString", null),
                                    a!defaultValue(index(index(local!res, "error", null), "message", null), "sin detalle")
                                  )
                              ),
                              a!save(local!accionEnCurso, false)
                            }
                          )
                        )
                      }
                    )
                  },
                  align: "CENTER",
                  marginBelow: "NONE"
                )
              }
            )
          )
        ),
        rowHeader: 1
      ),
      a!richTextDisplayField(
        labelPosition: "COLLAPSED",
        showWhen: a!isNotNullOrEmpty(local!mensaje),
        value: a!richTextItem(
          text: local!mensaje,
          color: if(local!tipoMensaje = "OK", "POSITIVE", "NEGATIVE"),
          style: "STRONG"
        )
      )
    }
  )
)
