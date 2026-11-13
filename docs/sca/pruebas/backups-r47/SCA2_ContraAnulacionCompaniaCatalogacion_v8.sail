=/*
[SCA2] Apartado "Compañía contraria y catalogación" — copia de SCA_CompañiaContrariaCatalogacion.
Campos: compañía aseguradora contraria (+ popup buscador y RECARGAR ARGUMENTO),
tipo catalogación, fecha anulación, mensaje INFO.
Inputs: showPopup, compania, tipoCatalogacion, fechaAnulacion, solicitud,
listaArgumentos, activoPanCatalogacion, codCiaContraria, data, argumentoSeleccionado, indiceArgumentoSeleccionado
*/
a!localVariables(
  local!resultado,
  {
    a!cardLayout(
      contents: {
        a!columnsLayout(
          columns: {
            a!columnLayout(
              contents: {
                a!textField(
                  label: "Compañía aseguradora contraria",
                  labelPosition: "ABOVE",
                  value: if(a!isNullOrEmpty(ri!compania), "", concat(tostring(index(ri!compania, "codigo")), " - ", index(ri!compania, "descripcion"))),
                  disabled: true
                )
              },
              width: "MEDIUM_PLUS"
            ),
            a!columnLayout(
              contents: {
                a!buttonArrayLayout(
                  buttons: {
                    a!buttonWidget(
                      label: "",
                      icon: "search",
                      value: true(),
                      saveInto: ri!showPopup,
                      size: "SMALL",
                      style: "OUTLINE",
                      color: "SECONDARY"
                    )
                  },
                  align: "START",
                  marginAbove: "STANDARD",
                  marginBelow: "NONE"
                )
              }
            ),
            a!columnLayout(
              contents: {
                a!buttonLayout(
                  primaryButtons: {
                    a!buttonWidget(
                      label: "RECARGAR ARGUMENTO",
                      color: "SECONDARY",
                      saveInto: {
                        a!save(
                          local!resultado,
                          index(
                            rule!SCA2_modificarCatalogacionCodCiaCntrAnul(
                              solicitud: ri!solicitud,
                              ciaContraria: index(ri!compania, "codigo", ""),
                              fechaAnulacion: ri!fechaAnulacion,
                              tipoCatalogacion: ri!tipoCatalogacion
                            ),
                            "result",
                            null
                          )
                        ),
                        /* Paridad SCA_CompañiaContrariaCatalogacion: recarga el argumentario con la misma petición del padre
                           (ri!data.body) actualizada con la compañía contraria, catalogación y fecha actuales.
                           Guarda la respuesta completa (listadoArgumentos + treboles/DEFCART) como SCA. */
                        a!save(
                          ri!listaArgumentos,
                          rule!SCA2_consultarListadoArgumentos(
                            body: a!update(
                              a!update(
                                a!update(
                                  a!update(
                                    a!defaultValue(index(ri!data, "body", null), {}),
                                    "codCompaniaContraria",
                                    tostring(index(a!flatten({index(ri!compania, "codigo", null)}), 1, ""))
                                  ),
                                  "codigoCompaniaContraria",
                                  tostring(index(a!flatten({index(ri!compania, "codigo", null)}), 1, ""))
                                ),
                                "codCatalogacion",
                                tostring(a!defaultValue(ri!tipoCatalogacion, ""))
                              ),
                              "fecAnulPca",
                              if(a!isNullOrEmpty(ri!fechaAnulacion), "", datetext(todate(ri!fechaAnulacion), "yyyy-MM-dd"))
                            )
                          )
                        ),
                        /* R46-D (paridad SCA): RECARGAR no desmarca el argumento; queda seleccionado con los datos anteriores */
                        a!save(ri!codCiaContraria, index(ri!compania, "codigo", ""))
                      },
                      loadingIndicator: true
                    )
                  }
                )
              }
            )
          },
          alignVertical: "BOTTOM"
        ),
        a!columnsLayout(
          columns: {
            a!columnLayout(
              contents: {
                a!dropdownField(
                  choiceLabels: cons!SCA2_TXT_TIP_CATALOGACION_PCA,
                  choiceValues: cons!SCA2_INT_TIP_CATALOGACION_PCA,
                  label: "Tipo catalogación",
                  labelPosition: "ABOVE",
                  placeholder: "--- Seleccione ---",
                  value: if(a!isNullOrEmpty(ri!tipoCatalogacion), null, tointeger(index(ri!tipoCatalogacion, 1, ri!tipoCatalogacion))),
                  saveInto: {ri!tipoCatalogacion},
                  searchDisplay: "AUTO",
                  required: true(),
                  validations: {},
                  disabled: not(if(isnull(ri!activoPanCatalogacion), false, ri!activoPanCatalogacion))
                )
              },
              width: "MEDIUM"
            ),
            a!columnLayout(
              contents: {
                a!dateField(
                  label: "Fecha anulación",
                  labelPosition: "ABOVE",
                  value: ri!fechaAnulacion,
                  saveInto: {ri!fechaAnulacion},
                  required: true(),
                  readOnly: false,
                  disabled: true,
                  validations: {}
                )
              },
              width: "NARROW"
            ),
            a!columnLayout(
              contents: {
                a!richTextDisplayField(),
                a!cardLayout(
                  contents: {
                    a!sideBySideLayout(
                      items: {
                        a!sideBySideItem(
                          item: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {
                              a!richTextIcon(icon: "info-circle", color: cons!SCA2_VAL_COLOR_AZUL_CLARO, size: "MEDIUM")
                            }
                          ),
                          width: "MINIMIZE"
                        ),
                        a!sideBySideItem(
                          item: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {"Verifica la correcta catalogación de la fecha de anulación. "}
                          )
                        )
                      },
                      alignVertical: "MIDDLE"
                    )
                  },
                  style: "INFO",
                  accessibilityText: "Information message"
                )
              },
              width: "WIDE"
            )
          },
          alignVertical: "BOTTOM"
        )
      },
      height: "AUTO",
      style: "TRANSPARENT",
      marginBelow: "STANDARD",
      showBorder: false()
    )
  }
)
