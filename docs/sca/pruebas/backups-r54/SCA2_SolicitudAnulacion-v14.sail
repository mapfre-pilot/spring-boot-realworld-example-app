/* [SCA2] Tab "Solicitud Anulación" — port de SCA_SolicitudAnulaci_n:
   etiqueta gris (SCA2_VAL_COLOR_GRIS_MEDIO) + valor en negrita,
   mismo orden de columnas que el original:
   Fecha solicitud anulación / Origen / Causa / Canal entrada
   Estado solicitud anulación / Fecha estado / Fecha anulación
   Nivel intervención / Catalogación / Fecha impresión / Fecha efecto recibo impago
   Reserva prima / Compañía contraria / Número de Solicitud
   Inputs: idSolicitud (Text), sol (Map: resultado de SCA2_cargarSolicitud) */
a!localVariables(
  local!cab: a!refreshVariable(
    value: index(rule!SCA2_consultarCabeceraSolicitud(codSolicitud: ri!idSolicitud), "MSSConsultarCabecera", null),
    refreshOnVarChange: ri!sol),
  local!ciasContrarias: a!forEach(
    items: a!defaultValue(reduce(index(_, _, null), rule!SCA2_catalogFilteredIntegracion(), {"result", "body", "data", "item", "str"}), {}),
    expression: a!map(codigo: tostring(index(fv!item, 1, null)), descripcion: index(fv!item, 2, null))),
  local!ds: a!defaultValue(index(index(ri!sol, "datosCompletosSolicitud", null), "datosSolicitud", null),
    a!defaultValue(index(ri!sol, "datosSolicitud", null), {})),
  local!est: a!defaultValue(index(ri!sol, "estado", null), {}),
  local!numPoliza: a!defaultValue(index(local!est, "numPoliza", null),
    index(index(index(ri!sol, "datosCompletosSolicitud", null), "datosBasicosSolicitud", null), "numpoliza", null)),
  local!solicitudesCore: if(
    a!isNotNullOrEmpty(local!numPoliza),
    index(rule!SCA2_consultarSolicitudes(
      numPoliza: local!numPoliza, codInt: "", tpBusqueda: "0"
    ), "MSSConsultarSolicitudes", {}),
    {}
  ),
  local!codEstSolic: index(index(local!solicitudesCore,
    index(wherecontains(tostring(ri!idSolicitud), touniformstring(index(local!solicitudesCore, "idSolicitud", {}))), 1, 0), null),
    "codEstSolic", null),
  local!estadoSolicitudTxt: if(
    a!isNotNullOrEmpty(local!codEstSolic),
    rule!SCA2_calcularEstadoSolicitud(
      estadoSolicitud: local!codEstSolic,
      idSolicitud: ri!idSolicitud,
      datosGestiones: rule!SCA2_consultaGestion(codSolicitud: ri!idSolicitud)
    ),
    upper(if(
      a!isNotNullOrEmpty(index(local!cab, "estadoSolicitud", null)),
      rule!SCA_D_EstadosSolicitud(estado: tointeger(index(local!cab, "estadoSolicitud", null))),
      rule!SCA2_textoEstadoSolicitud(estado: index(local!est, "estadoSolicitud", null))))
  ),
  /* [S4] Fechas/origen/estado desde la cabecera CORE (mismo origen que SCA_SolicitudAnulaci_n): solo fecha dd/mm/yyyy */
  local!fecCabSol: index(local!cab, "fecSolicitudAnul", null),
  /* Como SCA_SolicitudAnulaci_n: la fecha abre el histórico de gestiones (SCA2_ModalFechaSolicitudAnulacion) */
  local!showFechaAnulacion: false,
  local!fec: if(
    a!isNotNullOrEmpty(local!fecCabSol),
    left(tostring(local!fecCabSol), 10),
    index(local!ds, "fecsolicitudanul",
      index(local!ds, "fecSolicitud",
        if(a!isNullOrEmpty(index(local!est, "createdAt", null)), null, text(index(local!est, "createdAt", null), "dd/MM/yyyy"))))),
  if(
    local!showFechaAnulacion,
    rule!SCA2_ModalFechaSolicitudAnulacion(showFechaAnulacion: local!showFechaAnulacion, idSolicitud: ri!idSolicitud),
  a!cardLayout(
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Fecha solicitud anulación" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: a!defaultValue(local!fec, "-"),
                    link: if(
                      a!isNotNullOrEmpty(local!fecCabSol),
                      a!dynamicLink(saveInto: a!save(local!showFechaAnulacion, true)),
                      null
                    ),
                    color: "ACCENT",
                    style: { "STRONG", "UNDERLINE" }
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Origen" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(
                      a!isNotNullOrEmpty(index(local!cab, "origen", null)),
                      index(cons!SCA2_TXT_ORIGEN,
                        tointeger(index(local!cab, "origen", null)),
                        "-"),
                      "-"
                    ),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Causa" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(
                      a!isNotNullOrEmpty(index(local!ds, "codcausa", null)),
                      index(cons!SCA2_TXT_CAUSA_ANULACION,
                        tointeger(index(local!ds, "codcausa", null)),
                        a!defaultValue(index(local!ds, "desccausa", null), "-")),
                      a!defaultValue(index(local!ds, "desccausa", null), "-")
                    ),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Canal entrada" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(
                      a!isNotNullOrEmpty(index(local!ds, "canalentrada", null)),
                      index(cons!SCA2_TXT_CANALES_ENTRADA_DESC,
                        tointeger(index(local!ds, "canalentrada", null)),
                        "-"),
                      "-"
                    ),
                    style: "STRONG"
                  )
                }
              )
            }
          )
        }
      ),
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Estado solicitud anulación" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: local!estadoSolicitudTxt,
                    color: if(
                      a!isNotNullOrEmpty(local!codEstSolic),
                      rule!SCA2_colorEstadoSolicitud(estado: local!estadoSolicitudTxt),
                      "STANDARD"
                    ),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Fecha estado " & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(
                      a!isNotNullOrEmpty(index(local!cab, "fecEstado", null)),
                      left(tostring(index(local!cab, "fecEstado", null)), 10),
                      a!defaultValue(
                        index(local!ds, "fecestado",
                          if(a!isNullOrEmpty(index(local!est, "modifiedAt", null)), null, text(index(local!est, "modifiedAt", null), "dd/MM/yyyy"))),
                        "-")),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Fecha anulación" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: a!defaultValue(
                      if(a!isNullOrEmpty(index(local!cab, "fecAnulacion", null)), index(local!ds, "fecanulacion", null),
                        if(
  mid(tostring(index(local!cab, "fecAnulacion", null)), 3, 1) = "/",
  left(tostring(index(local!cab, "fecAnulacion", null)), 10),
  if(
    mid(tostring(index(local!cab, "fecAnulacion", null)), 5, 1) = "-",
    mid(tostring(index(local!cab, "fecAnulacion", null)), 9, 2) & "/" & mid(tostring(index(local!cab, "fecAnulacion", null)), 6, 2) & "/" & left(tostring(index(local!cab, "fecAnulacion", null)), 4),
    "-"
  )
)),
                      "-"),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(contents: {})
        }
      ),
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Nivel intervención" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(
                      a!isNotNullOrEmpty(index(local!est, "nivelIntervencion", null)),
                      index(cons!SCA2_TXT_NIVEL_INTERVENCION,
                        tointeger(index(local!est, "nivelIntervencion", null)),
                        "-"),
                      "-"
                    ),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Catalogación" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: a!localVariables(
                      local!catalog: a!defaultValue(index(local!cab, "catalogacion", null), index(local!ds, "catalogacion", null)),
                      if(
                        a!isNotNullOrEmpty(local!catalog),
                        index(cons!SCA2_TXT_TIP_CATALOGACION_PCA, tointeger(local!catalog), local!catalog),
                        "-"
                      )
                    ),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Fecha impresion" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(a!isNullOrEmpty(index(local!cab, "fecImpresion", null)), "-", left(index(local!cab, "fecImpresion", null), 10)),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Fecha efecto recibo impago" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: a!defaultValue(index(local!ds, "fecefecimpagado", null), "-"),
                    style: "STRONG"
                  )
                }
              )
            }
          )
        }
      ),
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Reserva prima" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: if(tointeger(a!defaultValue(index(local!ds, "rsvPrima", 0), 0)) = 1, "SOLICITADA /", "NO SOLICITADA / -"),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Compañía contraria" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: a!defaultValue(
                      index(local!ciasContrarias,
                        a!defaultValue(index(
                          wherecontains(
                            tostring(a!defaultValue(index(local!ds, "idcompania", null), index(local!cab, "idCompania", null))),
                            touniformstring(a!forEach(
                              items: local!ciasContrarias,
                              expression: tostring(index(fv!item, "codigo", null))))),
                          1, 0), 0), "descripcion", null), "-"),
                    style: "STRONG"
                  )
                }
              )
            }
          ),
          a!columnLayout(contents: {}),
          a!columnLayout(
            contents: {
              a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(
                    text: "Número de Solicitud" & char(10),
                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                  ),
                  a!richTextItem(
                    text: ri!idSolicitud,
                    style: "STRONG"
                  )
                },
                showWhen: a!isUserMemberOfGroup(loggedInUser(), {cons!SCA2_GRP_ADMINISTRADORES})
              )
            }
          )
        }
      )
    },
    height: "AUTO",
    style: "TRANSPARENT",
    marginBelow: "STANDARD",
    showBorder: false()
  )
  )
)
