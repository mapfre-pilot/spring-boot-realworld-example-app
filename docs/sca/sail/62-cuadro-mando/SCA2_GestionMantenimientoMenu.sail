=/*
[SCA2] Menú de Gestión de Mantenimiento — copia de SCA_GestionMantenimientoMenu.
Opciones: Cuadro de mando, Argumentos de contra anulación, Gestión de conceptos, Aplicación,
Variables de la aplicación, Batch, Pendientes de autorizar (wAutemis), Catálogos CORE (Aurora).
Inputs: (ninguno — la página carga datos propios)
*/
a!localVariables(
  /*Variables para interfaz SCA2_GestionConceptosYClases (como SCA_GestionMantenimientoMenu)*/
  local!idConcepto: null,
  local!descConceptoPca: null,
  local!modificar: null,
  local!modificarConcepto: false,
  local!altaValor: false,
  local!eliminar: false,
  local!identificador: null,
  local!opciones: {
    "Cuadro de mando",
    "Argumentos de contra anulación",
    "Gestión de conceptos",
    "Aplicación",
    "Variables de la aplicación",
    "Batch",
    "Pendientes de autorizar (wAutemis)",
    "Catálogos CORE (Aurora)"
  },
  local!seleccionado: 1,
  {
    a!columnsLayout(
      columns: {
        a!columnLayout(
          contents: {
            a!cardLayout(
              contents: {
                a!forEach(
                  items: local!opciones,
                  expression: a!cardLayout(
                    contents: {
                      a!sideBySideLayout(
                        items: {
                          a!sideBySideItem(width: "MINIMIZE"),
                          a!sideBySideItem(
                            item: a!richTextDisplayField(
                              labelPosition: "COLLAPSED",
                              value: {
                                a!richTextItem(
                                  text: fv!item,
                                  color: "ACCENT",
                                  style: if(local!seleccionado = fv!index, "STRONG", "PLAIN")
                                )
                              }
                            )
                          )
                        }
                      )
                    },
                    link: a!dynamicLink(saveInto: {a!save(local!seleccionado, fv!index)}),
                    style: "#F7F7F7",
                    padding: "NONE",
                    marginBelow: "STANDARD",
                    showBorder: false,
                    decorativeBarPosition: "START",
                    decorativeBarColor: if(local!seleccionado = fv!index, "ACCENT", "#F7F7F7"),
                    accessibilityText: if(fv!index = local!seleccionado, "Selected section.", "Section " & fv!index & " of " & length(local!opciones))
                  )
                )
              },
              style: "#F7F7F7",
              padding: "STANDARD",
              showBorder: false,
              height: "AUTO"
            )
          },
          width: "NARROW_PLUS"
        ),
        a!columnLayout(
          contents: {
            a!cardLayout(
              contents: {
                a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: {
                    a!richTextItem(
                      text: index(local!opciones, local!seleccionado, ""),
                      color: cons!SCA2_VAL_COLOR_NEGRO,
                      size: "MEDIUM",
                      style: "STRONG"
                    )
                  }
                ),
                a!horizontalLine(marginAbove: "STANDARD", marginBelow: "STANDARD"),
                a!localVariables(
                  local!modificacion: null,
                  local!argumentoEscogido: null,
                  local!documentum: null,
                  choose(
                    local!seleccionado,
                    /* 0 - Cuadro de mando (solo lectura) */
                    rule!SCA2_CuadroMando(),
                    /* 1 - Argumentos de contra anulación */
                    rule!SCA2_GestionArgumentos(
                      modificacion: local!modificacion,
                      argumentoEscogido: local!argumentoEscogido,
                      documentum: local!documentum),
                    /* 2 - Gestión de conceptos */
                    rule!SCA2_GestionConceptosYClases(
                      idConcepto: local!idConcepto,
                      descConceptoPca: local!descConceptoPca,
                      modificar: local!modificar,
                      modificarConcepto: local!modificarConcepto,
                      altaValor: local!altaValor,
                      eliminar: local!eliminar,
                      identificador: local!identificador),
                    /* 3 - Aplicación */
                    rule!SCA2_GestionAplicacionRecords(),
                  /* 4 - Variables de la aplicación */
                  a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: a!richTextItem(
                      text: "Gestión de variables de la aplicación no disponible en SCA2 (pendiente).",
                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO)),
                  /* 5 - Batch */
                  a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: a!richTextItem(
                      text: "Lanzamiento de batch no disponible en SCA2 (pendiente: SCA2 CMD BarridoCaducidad).",
                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO)),
                  rule!SCA2_MantenimientoPendientesAutorizar(),
                  /* 7 - Catálogos CORE cacheados en Aurora (fase 1, sesión C) */
                  rule!SCA2_CatMantenimiento()
                  )
                )
              },
              style: "TRANSPARENT",
              padding: "STANDARD",
              showBorder: true
            )
          }
        )
      }
    ),
    rule!SCA2_PieDePagina()
  }
)
