/* [SCA2] copia de SCA_ModalFechaSolicitudAnulacion v7. Modal para la fecha de anulación perteneciente al apartado de Solicitud Anulación de la cabecera*/
a!localVariables(
  /*index(ri!solicitud, "idSolicitud", null)*/
  local!gestiones: index(
    rule!SCA2_consultaGestion(ri!idSolicitud),
    "MSSConsultaGestion",
    null
  ),
  {
    a!columnsLayout(
      columns: {
        a!columnLayout(),
        a!columnLayout(
          contents: {
            a!cardLayout(
              contents: {
                a!columnLayout(
                  contents: {
                    a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: {
                        a!richTextItem(
                          text: "Histórico de gestiones: ",
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_ROJO,
                          size: "MEDIUM_PLUS",
                          style: "STRONG"
                        )
                      }
                    )
                  }
                ),
                a!horizontalLine(
                  marginAbove: "STANDARD",
                  marginBelow: "STANDARD",
                  color: "#ffffff"
                ),
                a!gridField_24r3(
                  label: "Gestión de la solicitud de anulación Num. " & ri!idSolicitud,
                  labelPosition: "ABOVE",
                  data: local!gestiones,
                  columns: {
                    a!gridColumn(
                      label: "Fecha inicio",
                      value: fv!row.fecInicioGestion
                    ),
                    a!gridColumn(
                      label: "Fecha fin",
                      value: fv!row.fecFinGestion
                    ),
                    a!gridColumn(
                      label: "Acción realizada",
                      value: a!match(
                        value: fv!row.accionRealizada,
                        equals: "8",
                        then: "Alta Solicitud",
                        equals: "2",
                        then: "Contra Anulación",
                        equals: "5",
                        then: "Mecanización",
                        equals: "3",
                        then: "Acciones Administrativas",
                        default: "Autorización"
                      )
                    ),
                    a!gridColumn(
                      label: "Nivel intervención",
                      value: fv!row.nivelIntervencion
                    ),
                    a!gridColumn(
                      label: "Perfil usuario",
                      value: fv!row.infoUsuario.codPerfil
                    ),
                    a!gridColumn(
                      label: "Nuuma",
                      value: fv!row.infoUsuario.nuuma
                    ),
                    a!gridColumn(
                      label: "Observaciones",
                      value: fv!row.observaciones
                    )
                  }
                ),
                a!buttonLayout(
                  primaryButtons: {
                    a!buttonWidget(
                      label: "ACEPTAR",
                      style: "SOLID",
                      color: cons!SCA2_VAL_COLOR_ROJO,
                      saveInto: a!save(ri!showFechaAnulacion, false),
                      validate: true(),
                      iconPosition: "END"
                    )
                  }
                )
              },
              shape: "ROUNDED",
              
            )
          },
          width: "WIDE_PLUS"
        ),
        a!columnLayout()
      }
    )
  }
)