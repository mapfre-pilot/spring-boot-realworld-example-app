/*
Interfaz que contiene el formulario para dar de alta un argumento.
Los campos son los siguientes:
  - Referencia 
  - Línea de negocio
  - Rama de negocio
  - Estado
  - Descripción
  - Fecha vigencia
  - Fecha modificación
  - Campaña
  - Código de campañía 
  - Bonificación
  - SGO
  - URL
  - Aplicación a ejecutar
  - Documanto a visualizar
  - Instrucciones
  - Observaciones
*/
a!localVariables(
  
  local!mcaVentanaInfo: false,
  local!modificar: a!isNotNullOrEmpty(ri!argumento),
  /*Variable que almacena el valor del documento original en caso de que este exista*/
  local!docOriginal: ri!documento,
  /*Variable en la que se almacena el documento del argumento*/
  local!documento: ri!documento,
  /*Guarda la respuesta a la modificación del documento en documentum*/
  local!documentumResponseMod,
  /*Guarda la respuesta al alta del documento en documentum*/
  local!documentumResponse,
  /*Establece el nombre del documento cargado en Appian para guardar en el repositorio*/
  /**********************************************************************/
  /*REVISAR; NO SE PUEDE ACEDER AL DOCUMENTO HASTA QUE NO SE HA SUBIDO*/
  /**********************************************************************/
  
  /*Guarda la respuesta a la petición de alta/modificación*/
  local!response,
  /*Contiene el mensaje de error o de confirmación que se ha de mostrar*/
  local!mensaje: "",
  /*Contiene el id del argumento si ya existe*/
  local!referencia: ri!argumento.codTpArg,
  /*Contiene la línea de negocio*/
  local!lineaNegocio: ri!argumento.idLineaNegocio,
  /*Contiene la rama de negocio*/
  local!ramaNegocio: ri!argumento.idRamo,
  /*Contiene el estado*/
  local!estado: if(
    a!isNotNullOrEmpty(ri!argumento),
    ri!argumento.codEstado,
    null()
  ),
  /*Contiene la descripción*/
  local!descripcion: ri!argumento.descArg,
  /*Contiene la fecha de vigencia*/
  local!fechaVigente: ri!argumento.fecVigencia,
  /*Contiene la fecha de modificación*/
  local!fechaModificacion: ri!argumento.fecModificado,
  /*Contiene las opciones de campaña*/
  local!campana: rule!SCA2_consultarConceptoReutilizable(
    finalConcepto: "desConcepto",
    idConcepto: "CAMP"
  ),
  
  local!campana2: rule!SCA2_consultarConceptoReutilizable(
    finalConcepto: "valorConcepto",
    idConcepto: "CAMP"
  ),
  /* ESMSA-388*/
  local!flagEconomica: index(a!queryRecordType_25r3(
    recordType: 'recordType!{b59a827c-1188-41b8-923a-43d3f518ec7d}SCA Concepto Funcional',
    fields: {
      'recordType!{b59a827c-1188-41b8-923a-43d3f518ec7d}SCA Concepto Funcional.fields.{edf12742-8db1-46e4-a5e1-17730e933aaf}valVarFun'
    },
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        a!queryFilter(
          field: 'recordType!{b59a827c-1188-41b8-923a-43d3f518ec7d}SCA Concepto Funcional.fields.{e32e5746-9072-46d9-9bea-6ce145857a2c}codCtoFun',
          operator: "in",
          value: {"flagActivoEconomico"}
        )
      },
      ignoreFiltersWithEmptyValues: true
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 1
    )
  ).data['recordType!{b59a827c-1188-41b8-923a-43d3f518ec7d}SCA Concepto Funcional.fields.{edf12742-8db1-46e4-a5e1-17730e933aaf}valVarFun'],1,"N"),
  local!mcaEconomico: if (
    local!flagEconomica = "S",
    rule!SCA2_obtenerMarcaEconomica(codArg:local!referencia),
    null
  ),
  local!resultadoModificarMarcaEco,
  /*local!campana : index(*/
    /*index(*/
      /*index(*/
        /*index(*/
          /*rule!SCA2_consultarConcepto(*/
            /*mseConsultarConceptoDTO: a!map(*/
              /*tipoBusqueda: 1,*/
              /*idConcepto: "CAMP",*/
              /*infoUsuario: a!map(*/
                /*codCiaUsuario: 1,*/
                /*nuuma: "PCARAGE",*/
                /*codPerfil: "CE_RM",*/
                /*codSubPerfil: "CE_RM_OFICINA"*/
              /*)*/
            /*),*/
            /*rand: null*/
          /*),*/
          /*"MSSConsultarConcepto",*/
          /*null()*/
        /*),*/
        /*"listadoConceptos",*/
        /*null()*/
      /*)[1],*/
      /*"valoresConcepto",*/
      /*null()*/
  /*),*/
    /*"desConcepto",*/
    /*null()*/
  /*),*/
  /*local!campana2: index(*/
    /*index(*/
      /*index(*/
        /*index(*/
          /*rule!SCA2_consultarConcepto(*/
            /*mseConsultarConceptoDTO: a!map(*/
              /*tipoBusqueda: 1,*/
              /*idConcepto: "CAMP",*/
              /*infoUsuario: a!map(*/
                /*codCiaUsuario: 1,*/
                /*nuuma: "PCARAGE",*/
                /*codPerfil: "CE_RM",*/
                /*codSubPerfil: "CE_RM_OFICINA"*/
              /*)*/
            /*),*/
            /*rand: null*/
          /*),*/
          /*"MSSConsultarConcepto",*/
          /*null()*/
        /*),*/
        /*"listadoConceptos",*/
        /*null()*/
      /*)[1],*/
      /*"valoresConcepto",*/
      /*null()*/
    /*),*/
    /*"valorConcepto",*/
    /*null()*/
  /*),*/
  /*Contiene la campaña seleccionada*/
  local!campanaSeleccionada: ri!argumento.codIdCampana,
  /*Contiene el código de compañía*/
  local!codigoCompania:ri!argumento.codCompaniaArg,
  /*Contiene la cantidad de bonificación*/
  local!bonificacion: ri!argumento.numTipBon,
  /*Contiene la bonificación seleccionada*/
  local!selectBonificacion: ri!argumento.codTipBon,
  /*Contiene el valor de SGO (bool)*/
  local!sgo: if(
    or(a!defaultValue(ri!argumento.numDiasSgo, 1) = 0, a!isNullOrEmpty(ri!argumento)),
    null,
    ri!argumento.numDiasSgo
  ),
  /*Contiene las opciones de SGO*/
  local!selectSgo: rule!SCA2_consultarConceptoReutilizable(
    finalConcepto: "desConcepto",
    idConcepto: "TRSGO"
  ),
  local!selectSgo2: rule!SCA2_consultarConceptoReutilizable(
    finalConcepto: "desConcepto",
    idConcepto: "TRSGO"
  ),
  /*local!getSgo: index(*/
    /*rule!SCA2_consultarConcepto(*/
      /*mseConsultarConceptoDTO: a!map(*/
        /*tipoBusqueda: 1,*/
        /*idConcepto: "TRSGO",*/
        /*infoUsuario: a!map(*/
          /*codCiaUsuario: 1,*/
          /*nuuma: "PCARAGE",*/
          /*codPerfil: "CE_RM",*/
          /*codSubPerfil: "CE_RM_OFICINA"*/
        /*)*/
      /*),*/
      /*rand: null*/
    /*),*/
    /*"MSSConsultarConcepto",*/
    /*null*/
  /*),*/
  /*local!selectSgo: */
  /*if(*/
    /*a!isNullOrEmpty(local!getSgo),*/
    /*{},*/
    /*index(*/
      /*index(*/
        /*index(*/
          /*local!getSgo,*/
          /*"listadoConceptos",*/
          /*null*/
        /*)[1],*/
        /*"valoresConcepto",*/
        /*null*/
      /*),*/
      /*"desConcepto",*/
      /*null*/
    /*)*/
  /*),*/
  /*local!getSgo2: index(*/
    /*rule!SCA2_consultarConcepto(*/
      /*mseConsultarConceptoDTO: a!map(*/
        /*tipoBusqueda: 1,*/
        /*idConcepto: "TRSGO",*/
        /*infoUsuario: a!map(*/
          /*codCiaUsuario: 1,*/
          /*nuuma: "PCARAGE",*/
          /*codPerfil: "CE_RM",*/
          /*codSubPerfil: "CE_RM_OFICINA"*/
        /*)*/
      /*),*/
      /*rand: null*/
    /*),*/
    /*"MSSConsultarConcepto",*/
    /*null()*/
  /*), */
  /*local!selectSgo2: */
  /*if(*/
    /*a!isNullOrEmpty(local!getSgo2),*/
    /*{},*/
    /*index(*/
      /*index(*/
        /*index(*/
          /*local!getSgo2,*/
          /*"listadoConceptos",*/
          /*null()*/
        /*)[1],*/
        /*"valoresConcepto",*/
        /*null()*/
      /*),*/
      /*"valorConcepto",*/
      /*null()*/
    /*) */
  /*),*/
  /*Contiene el SGO seleccionado*/
  local!sgoseleccionado: ri!argumento.codTareaSgo,
  /*Contiene las opciones de URL*/
  
  local!url: a!map(
    name: rule!SCA2_consultarConceptoReutilizable(
      finalConcepto: "desConcepto",
      idConcepto: "URL"
    ),  
    /*name:index(*/
      /*index(*/
        /*index(*/
          /*index(*/
            /*rule!SCA2_consultarConcepto(*/
              /*mseConsultarConceptoDTO: a!map(*/
                /*tipoBusqueda: 1,*/
                /*idConcepto: "URL",*/
                /*infoUsuario: a!map(*/
                  /*codCiaUsuario: 1,*/
                  /*nuuma: "PCARAGE",*/
                  /*codPerfil: "CE_RM",*/
                  /*codSubPerfil: "CE_RM_OFICINA"*/
                /*)*/
              /*),*/
              /*rand: null*/
            /*),*/
            /*"MSSConsultarConcepto",*/
            /*null()*/
          /*),*/
          /*"listadoConceptos",*/
          /*null()*/
        /*)[1],*/
        /*"valoresConcepto",*/
        /*null()*/
      /*),*/
      /*"desConcepto",*/
      /*null()*/
/*),*/
    url: rule!SCA2_consultarConceptoReutilizable(
      finalConcepto: "valorConcepto",
      idConcepto: "URL"
    )
    /*url: index(*/
    /*index(*/
      /*index(*/
        /*index(*/
          /*rule!SCA2_consultarConcepto(*/
            /*mseConsultarConceptoDTO: a!map(*/
              /*tipoBusqueda: 1,*/
              /*idConcepto: "URL",*/
              /*infoUsuario: a!map(*/
                /*codCiaUsuario: 1,*/
                /*nuuma: "PCARAGE",*/
                /*codPerfil: "CE_RM",*/
                /*codSubPerfil: "CE_RM_OFICINA"*/
              /*)*/
            /*),*/
            /*rand: null*/
          /*),*/
          /*"MSSConsultarConcepto",*/
          /*null()*/
        /*),*/
        /*"listadoConceptos",*/
        /*null()*/
      /*)[1],*/
      /*"valoresConcepto",*/
      /*null()*/
    /*),*/
    /*"valorConcepto",*/
    /*null()*/
  /*)*/
  ),
  /*Contiene la URL seleccionada*/
  local!urlseleccionado: if(
      contains(index(local!url, "url"), ri!argumento.txtUrlArg),
      ri!argumento.txtUrlArg,
      null
    ),
  /*Contiene el valor de Finaliza en positivo (bool)*/
  local!selection1: if(
    a!isNotNullOrEmpty(ri!argumento),
    if(ri!argumento.mcaFinalizado = "S", true(), null()),
    null()
  ),
  /*Contiene el valor de Variable (bool)*/
  local!selection2: if(
    a!isNotNullOrEmpty(ri!argumento),
    if(ri!argumento.regateable = "S", true(), null()),
    null()
  ),
  /*Contiene el valor de Te cuidamos (bool)*/
  local!selection3: if(
    a!isNotNullOrEmpty(ri!argumento),
    if(ri!argumento.mcaTeCuidamos = "S", true(), null()),
    null()
  ),
  /*Contiene el valor de Tréboles calculados (bool)*/
  local!selection4: if(
    a!isNotNullOrEmpty(ri!argumento),
    if(ri!argumento.mcaTrebCalc = "S", true(), null()),
    null()
  ),
  /* ESMSA-388*/
  local!selection5:  if(
    a!isNotNullOrEmpty(local!mcaEconomico),
    if(local!mcaEconomico = "S", true, null),
    false
  ),
  /*Contiene las instrucciones*/
  local!instrucciones: ri!argumento.instruccion,
  /*Contiene las observaciones*/
  local!observaciones: ri!argumento.observaciones,
  /*Hace un mapeo entre el ID del argumento, el ID del documento en Appian y el ID del documento en Documentum*/
  /*local!argDocu: a!map(
    argumentoId: local!referencia,
    documentoId: null(),
    documentumId: null()
  ),*/
  
  /*Variable que determina si se muestra un mensaje de error*/
  local!error: false,
  
  /*Variable para conocer si se ha añadido/modificado el documento del argumento*/
  local!cambioDocumento: false,
  

  
  {
    
    a!cardLayout(
    contents: {
      a!cardLayout(
        contents: {
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: {
                  a!columnsLayout(
                    columns: {
                      /*Flecha hacia atrás*/
                      a!columnLayout(
                        contents: {
                          a!richTextDisplayField(
                            value: a!richTextIcon(
                              icon: "long-arrow-left",
                              link: a!dynamicLink(
                              saveInto: {
                                  /*Borramos el documento generado en Appian en caso de que haya*/  
                                  if(
                                    a!isNotNullOrEmpty(local!documento),
                                    a!deleteDocument(local!documento),
                                    null()
                                  ),  

                                  a!save(local!error, false),
                                  a!save(ri!modificacion, false),
                                  /*Devolvemos los valores por defecto al volver atrás*/
                                  a!save(local!referencia, ri!argumento.codTpArg),
                                  a!save(local!lineaNegocio, ri!argumento.idLineaNegocio),
                                  a!save(local!ramaNegocio, ri!argumento.idRamo),
                                  a!save(local!estado, if(a!isNotNullOrEmpty(ri!argumento), ri!argumento.codEstado, null)),
                                  a!save(local!descripcion, ri!argumento.descArg),
                                  a!save(local!fechaVigente, ri!argumento.fecVigencia),
                                  a!save(local!fechaModificacion, ri!argumento.fecModificado),
                                  a!save(local!campanaSeleccionada, ri!argumento.codIdCampana),
                                  a!save(local!codigoCompania, ri!argumento.codCompaniaArg),
                                  a!save(local!bonificacion, ri!argumento.numTipBon),
                                  a!save(local!selectBonificacion, ri!argumento.codTipBon),
                                  a!save(local!sgo, if(or(a!defaultValue(ri!argumento.numDiasSgo, 1) = 0, a!isNullOrEmpty(ri!argumento)), null, 1)),
                                  a!save(local!sgoseleccionado, ri!argumento.codTareaSgo),
                                  a!save(local!urlseleccionado, if(contains(index(local!url, "url"), ri!argumento.txtUrlArg), ri!argumento.txtUrlArg, null)),
                                  a!save(local!selection1, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaFinalizado = "S", true, null), null)),
                                  a!save(local!selection2, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.regateable = "S", true, null),null)),
                                  a!save(local!selection3, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaTeCuidamos = "S", true, null), null)),
                                  a!save(local!selection4, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaTrebCalc = "S", true, null),null)),
                                  a!save(local!instrucciones, ri!argumento.instruccion),
                                  a!save(local!observaciones, ri!argumento.observaciones),
                                  a!save(local!documentumResponse, null),
                                  a!save(local!documentumResponseMod, null),
                                  a!save(ri!documento, null),
                                  a!save(ri!argumento, null)
                                }
                              ),
                              linkStyle: "STANDALONE",
                              color: cons!SCA2_VAL_COLOR_ROJO,
                              size: "MEDIUM_PLUS"
                            )
                          )
                        }
                      ),
                      /*Título (alta/modificación)*/
                      a!columnLayout(
                        contents: {
                          a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: if(
                              a!isNullOrEmpty(ri!argumento),
                              {
                                a!richTextItem(
                                  text: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{679e3db9-9863-4706-a2d2-acdbadbe040e}Alta de argumento',
                                  linkStyle: "STANDALONE",
                                  color: cons!SCA2_VAL_COLOR_NEGRO,
                                  size: "MEDIUM",
                                  style: "STRONG"
                                )
                              },
                              {
                                a!richTextItem(
                                  text: index(ri!argumento, "codTpArg", "00")&" - "&index(ri!argumento, "descArg", ""),
                                  linkStyle: "STANDALONE",
                                  color: cons!SCA2_VAL_COLOR_NEGRO,
                                  size: "MEDIUM",
                                  style: "STRONG"
                                )
                              }
                            )
                          )
                        },
                        width: "MEDIUM_PLUS"
                      )
                    },
                    alignVertical: "MIDDLE",
                    showDividers: true()
                  )
                }
              ),
              a!columnLayout(contents: {}),
              a!columnLayout(
                contents: {
                  a!columnsLayout(
                    columns: {
                      a!columnLayout(contents: {})

                    }
                  )
                }
              )
            },
            alignVertical: "MIDDLE"
          )
        },
        style: cons!SCA2_VAL_COLOR_GRIS_CLARO,
        marginAbove: "NONE",
        marginBelow: "NONE",
        showBorder: false()
      ),
      a!cardLayout(
      contents: {
        a!cardLayout(
          contents: {
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: {
                a!richTextItem(
                  text: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{54c0d8bb-de29-44b7-9907-328e6208100c}Datos del argumento de contra anulación',
                  linkStyle: "STANDALONE",
                  color: cons!SCA2_VAL_COLOR_NEGRO,
                  size: "MEDIUM",
                  style: "STRONG"
                )
              }
            )
          },
          showBorder: false()
        ),
        a!horizontalLine(),
        if(
          local!error,
          a!richTextDisplayField(
          value: a!richTextItem(
            text: local!mensaje,
            color: "NEGATIVE",
            style: "STRONG"
          )
        ),
          null()
        ),
        a!cardLayout(
          contents: {
            /*1ª Fila*/
            a!columnsLayout(
              columns: {
                /*Campo Referencia*/
                a!columnLayout(
                  contents: {
                    a!integerField(
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{44f1a2f6-c6ba-4eca-a513-56e880e03bbd}Referencia',
                      value: tointeger(local!referencia),
                      saveInto: local!referencia,
                      required: true,
                      disabled: a!isNotNullOrEmpty(ri!argumento),
                      validations: if(
                        and(
                          a!isNotNullOrEmpty(local!referencia),
                          quotient(tointeger(local!referencia), 1000) > 0
                        ),
                        "No puede haber más de 3 dígitos",
                        ""
                      ),
                      validationGroup: "Reference"
                    )
                  }
                ),
                /*Campo Línea de Negocio*/
                a!columnLayout(
                  contents: {
                    a!dropdownField(
                      choiceLabels: cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE,
                      choiceValues: cons!SCA2_INT_ID_LINEA_NEGOCIO,
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{92e11580-843c-4e7f-b884-c52113d35d6b}Línea de negocio',
                      labelPosition: "ABOVE",
                      placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                      value:local!lineaNegocio,
                      saveInto: {local!lineaNegocio},
                      searchDisplay: "AUTO",
                      required: true(),
                      requiredMessage: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{e7bac9f0-8fb4-4b56-941f-2fbc7874fc45}Por favor, seleccione un valor',
                      disabled: if(
                        a!isNullOrEmpty(ri!argumento),
                        false(),
                        true()
                      ),
                      validations: {}
                    )
                  }
                ),
                /*Campo Rama de Negocio*/
                a!columnLayout(
                  contents: {
                    a!dropdownField(
                      choiceLabels: {cons!SCA_TXT_RAMA_NEGOCIO_ITEMS},
                      choiceValues: {cons!SCA_INT_RAMA_NEGOCIO_VALUES},
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{b5a61e74-47ee-49b4-bf9d-9b783cf7b605}Rama de negocio',
                      labelPosition: "ABOVE",
                      placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                      value: local!ramaNegocio,
                      saveInto: {local!ramaNegocio},
                      searchDisplay: "AUTO",
                      required: true(),
                      requiredMessage: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{e7bac9f0-8fb4-4b56-941f-2fbc7874fc45}Por favor, seleccione un valor',
                      validations: {}
                    )
                  }
                ),
                /*Campo Estado*/
                a!columnLayout(
                  contents: {
                    a!radioButtonField(
                      choiceLabels: {'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{10d736d8-79bf-4929-aa9f-3cfafdfd0ef7}Activo', 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{e510011f-3bd1-41f6-b218-2ac6dbf0cc7f}Inactivo'},
                      choiceValues: cons!SCA2_TXT_ESTADO_SI_NO,
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{50821279-38f0-4a9d-b2c3-1fc4b2fb45fd}Estado',
                      labelPosition: "ABOVE",
                      value: local!estado,
                      saveInto: {local!estado},
                      choiceLayout: "COMPACT",
                      validations: {}
                    )
                  }
                )
              }
            ),
            /*2ª Fila*/
            a!columnsLayout(
              columns: {
                /*Campo Descripción*/
                a!columnLayout(
                  contents: {
                    a!textField(
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{210aba70-f4db-43e3-b7f2-36dee38af96c}Descripción',
                      labelPosition: "ABOVE",
                      value: local!descripcion,
                      saveInto: {local!descripcion},
                      refreshAfter: "UNFOCUS",
                      characterLimit: 30,
                      required: true(),
                      validations: {}                      
                    )
                  }, 
                  width: "AUTO"
                ),
                a!columnLayout(
                  contents: {
                    a!columnsLayout(
                      columns: {
                        /*Campo Fecha de Vigencia*/
                        a!columnLayout(
                          contents: {
                              a!dateField( 
                              label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{a401a43a-499f-4fc5-9472-519fe4f6f8f0}Fecha de vigencia',
                              labelPosition: "ABOVE",
                              value: local!fechaVigente,
                              saveInto: {local!fechaVigente},
                              required: true,
                              readOnly: false,
                              disabled: false,
                              validations: {}
                            )
                          }
                        ),
                        a!columnLayout(
                          contents: {
                            a!columnsLayout(
                              columns: {
                                /*Campo Fecha de Modificación*/
                                a!columnLayout(
                                  contents: {
                                    a!dateField(
                                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{3dc1d1b6-4c38-42e2-bbc8-cb34ba5c04df}Fecha modificación',
                                      labelPosition: "ABOVE",
                                      value: ri!argumento.fecModificado,
                                      saveInto: {local!fechaModificacion},
                                      disabled: true(),
                                      validations: {}
                                    )
                                  }
                                )                                
                              }                 
                            )
                          }
                        )
                      }
                    )                                 
                  }
                )                
              }
            ),
            /*3ª Fila*/
            a!columnsLayout(
              columns: {
                /*Campo Campaña*/
                a!columnLayout(
                  contents: {
                    a!dropdownField(
                      choiceLabels: {a!defaultValue(local!campana, {})},
                      choiceValues: {a!defaultValue(local!campana2, {})},
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{f00741f4-4e4d-4e45-b5b6-97a1c523a8f7}Campaña',
                      labelPosition: "ABOVE",
                      placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                      value: local!campanaSeleccionada,
                      saveInto: {local!campanaSeleccionada},
                      searchDisplay: "AUTO"
                    )
                  }
                ),
                /*Campo Código de Compañía*/
                a!columnLayout(
                  contents: {
                    a!dropdownField(
                      choiceLabels: {cons!SCA_INT_CODIGO_COMPANIA},
                      choiceValues: {cons!SCA_INT_CODIGO_COMPANIA},
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{b2f0987c-bfe6-4bc8-8a3e-d78c979c9556}Código de compañía',
                      labelPosition: "ABOVE",
                      placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                      value: local!codigoCompania,
                      saveInto: {local!codigoCompania},
                      searchDisplay: "AUTO",
                      required: true(),
                      requiredMessage: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{e7bac9f0-8fb4-4b56-941f-2fbc7874fc45}Por favor, seleccione un valor',
                      validations: {}
                    )
                  }
                ),
                /*Campos Bonificación y su dropdown*/
                a!columnLayout(
                  contents: {
                    a!columnsLayout(
                      columns: {
                        a!columnLayout(
                          contents: {
                            a!textField(
                              label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{a35aa6b2-3e00-4402-9b7e-414d6e007b0c}Bonificación',
                              labelPosition: "ABOVE",
                              value: local!bonificacion,
                              saveInto: {local!bonificacion},
                              refreshAfter: "UNFOCUS",
                              validations: {}
                            )
                          }
                        ),
                        a!columnLayout(
                          contents: {                                                    
                            a!dropdownField(
                              choiceLabels: {cons!SCA_TXT_BONIFICACION_VALUES},
                              choiceValues: {cons!SCA_TXT_BONIFICACION_VALUES},
                              label: "",
                              labelPosition: "ABOVE",
                              placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                              value: local!selectBonificacion,
                              saveInto: {local!selectBonificacion},
                              searchDisplay: "AUTO",
                              validations: {}
                            )
                          }
                        )
                      },
                      alignVertical: "BOTTOM"
                    )
                  }
                ),
                /*Campos SGO y su dropdown*/
                a!columnLayout(
                  contents: {
                    a!columnsLayout(
                      columns: {
                        a!columnLayout(
                          contents: {
                            a!textField(
                              label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{27f5763e-221d-4d5f-b4ce-6ca167b43aee}SGO',
                              labelPosition: "ABOVE",
                              value: local!sgo,
                              saveInto: {local!sgo},
                              refreshAfter: "UNFOCUS",
                              validations: {}
                            )
                            /*a!cardLayout(
                              contents: {
                                a!checkboxField(
                                  choiceLabels: { "" },
                                  choiceValues: { 1 },
                                  label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{27f5763e-221d-4d5f-b4ce-6ca167b43aee}SGO',
                                  labelPosition: "ABOVE",
                                  value: local!sgo,
                                  saveInto: local!sgo,
                                  choiceLayout: "COMPACT"
                                )
                              },
                              padding: "NONE",
                              marginAbove: "NONE",
                              showBorder: false
                            )*/
                          },
                          width: "AUTO"
                        ),
                        a!columnLayout(
                          contents: {
                            a!dropdownField(
                            choiceLabels: {a!defaultValue(local!selectSgo, {})},
                            choiceValues: {a!defaultValue(local!selectSgo2, {})},
                            label: " ",
                            labelPosition: "ABOVE",
                            placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                            value: local!sgoseleccionado,
                            saveInto: {local!sgoseleccionado},
                            searchDisplay: "AUTO",
                            validations: {}
                          )
                            /*a!cardLayout(
                            contents: {
                              a!dropdownField(
                                choiceLabels: {local!selectSgo},
                                choiceValues: {local!selectSgo2},
                                label: "label",
                                labelPosition: "COLLAPSED",
                                placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                                value: local!sgoseleccionado,
                                saveInto: {local!sgoseleccionado},
                                searchDisplay: "AUTO",
                                validations: {}
                              )
                            },
                            padding: "NONE",
                            marginAbove: "MORE",
                            showBorder: false
                          )*/
                          }                          
                        )
                      },
                      alignVertical: "BOTTOM"
                    ) 
                  }                  
                )
              },
              alignVertical: "TOP"
            ),
            /*4ª Fila*/
            a!columnsLayout(
              columns: {
                /*Campo URL*/
                a!columnLayout(
                  contents: {
                    a!dropdownField(
                      choiceLabels: {a!defaultValue(local!url.name, {})},
                      choiceValues: {a!defaultValue(local!url.url, {})},
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c714f07a-2cb8-4b98-9079-6147ffe73fe7}URL',
                      labelPosition: "ABOVE",
                      placeholder: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{c255eede-e265-48fa-8578-eb6f5a0d78bc}--- Seleccione ---',
                      value: local!urlseleccionado,
                      saveInto: {
                        local!urlseleccionado
                      },
                      searchDisplay: "AUTO",
                      validations: {}
                    )
                  }
                ),
                /*Campo Aplicación*/
                a!columnLayout(
                  contents: {
                    a!textField(
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{53c17516-09d7-488d-b0d1-18f764feadc1}Aplicación a ejecutar',
                      labelPosition: "ABOVE",
                      value: local!url.name[wherecontains(
                        local!urlseleccionado,
                        local!url.url
                      )],
                      saveInto: {},
                      refreshAfter: "UNFOCUS",
                      readOnly: false,
                      disabled: true,
                      validations: {}
                    )
                  }
                ),
                /*Campo Documento*/
                a!columnLayout(
                  contents: {
                    a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: {
                        a!richTextItem(
                          text: {
                            "Documento a visualizar"
                          },
                          style: {
                            "STRONG"
                          }
                        )
                      }
                    ),
                    if(
                      and(a!isNotNullOrEmpty(ri!argumento.nombreDoc), not(local!cambioDocumento), local!docOriginal = local!documento),
                      a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: {
                        a!richTextItem(
                          text: ri!argumento.nombreDoc
                        )
                      }
                    ), {}),
                    a!fileUploadField_26r7(
                      label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{ca7d2103-fa28-4896-8530-11cb0080efca}Documento a visualizar',
                      labelPosition: "COLLAPSED",
                      instructions: if(
                        a!isNullOrEmpty(local!documento),
                        "*No hay ningún documento asociado",
                        ""
                      ),
                      target: cons!SCA2_FLD_DOCUMENTACION_ARGUMENTARIO,
                      fileNames: a!defaultValue(ri!argumento.nombreDoc, ""),
                      maxSelections: 1,
                      value: if(
                        a!isNotNullOrEmpty(local!documento),
                        local!documento,
                        null
                      ),
                      saveInto: {
                        local!documento,
                        a!save(local!cambioDocumento, true)
                      },
                      validations: {
                        if(
                          upper(fv!files.extension) <> "PDF",
                          "Los documentos adjuntos han de ser PDF",
                          ""
                        )
                      }
                    )
                  }
                ),
                /*Campo Ver Documento*/
                if(
                  and(
                    or(
                      a!isNotNullOrEmpty(local!documento),
                      a!isNullOrEmpty(ri!argumento.numDoc)
                    ), 
                    if(
                      and(
                        a!isNotNullOrEmpty(local!docOriginal),
                        a!isNotNullOrEmpty(local!documento)
                      ),
                      local!docOriginal = local!documento,
                      null
                    )
                  ),
                  a!columnLayout(
                    contents: {
                      a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: {
                          
                          a!richTextItem(
                            text: a!defaultValue(value: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{205c98c8-5581-428f-a38a-75236d25befe}Ver documento', default: "-"),
                            link: if(
                              a!isNullOrEmpty(ri!argumento.numDoc),
                              {},
                              a!dynamicLink(
                                saveInto: a!save(ri!visualizarDoc, true)
                              )
                            ),
                            color: if(
                              a!isNullOrEmpty(ri!argumento.numDoc),
                              "SECONDARY",
                              "ACCENT"
                            ),
                            style: { "STRONG", if(
                              a!isNullOrEmpty(ri!argumento.numDoc),
                              {},
                              "UNDERLINE"
                            ) }
                          )
                        },
                        align: "LEFT",
                        marginAbove: "MORE"
                      )
                    }
                  ),
                  a!columnLayout(
                    contents: {
                      a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: {
                          a!richTextItem(
                            text: a!defaultValue(value: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{205c98c8-5581-428f-a38a-75236d25befe}Ver documento', default: "-"),
                            color: cons!SCA2_VAL_COLOR_GRIS_MEDIO,
                            style: { "STRONG"}
                          )
                        },
                        tooltip: "No hay documento asociado",
                        align: "LEFT",
                        marginAbove: "MORE"
                      )
                    }
                  )
                )
              }
            ),
            /*5ª Fila*/
            a!columnsLayout(
              columns: {
                a!columnLayout(
                  contents: {
                    a!columnsLayout(
                      columns: {
                        /*Campo Finaliza en Positivo*/
                        a!columnLayout(
                        contents: {
                          a!checkboxField(
                            choiceLabels: {'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{2a5982dc-2b3e-4046-9041-1e740e7eb2b6}Finaliza en positivo'},
                            choiceValues: {true()},
                            label: "",
                            labelPosition: "ABOVE",
                            value: local!selection1,
                            saveInto: {local!selection1},
                            choiceLayout: "COMPACT",
                            validations: {}
                          )
                        }
                      ),
                        /*Campo Variable*/
                        a!columnLayout(
                        contents: {
                          a!checkboxField(
                            choiceLabels: {'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{317e875f-73f7-480a-9805-da46cf707c32}Variable'},
                            choiceValues: {true()},
                            label: "",
                            labelPosition: "ABOVE",
                            value: local!selection2,
                            saveInto: {local!selection2},
                            choiceLayout: "COMPACT",
                            validations: {}
                          )
                        }
                      ),
                        /*Campo Te çuidamos*/
                        a!columnLayout(
                        contents: {
                          a!checkboxField(
                            choiceLabels: {'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{8f69df18-af39-4aec-b895-315bd28d5e15}Te cuidamos'},
                            choiceValues: {true()},
                            label: "",
                            labelPosition: "ABOVE",
                            value: local!selection3,
                            saveInto: {local!selection3},
                            choiceLayout: "COMPACT",
                            validations: {}
                          )
                        }
                      ),
                        /*Campo Tréboles calculados*/
                        a!columnLayout(
                        contents: {
                          a!checkboxField(
                            choiceLabels: {'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{798e1473-ac7e-451a-92ca-9ed024e04e86}Tréboles calculados'},
                            choiceValues: {true()},
                            label: "",
                            labelPosition: "ABOVE",
                            value: local!selection4,
                            saveInto: {local!selection4},
                            choiceLayout: "COMPACT",
                            validations: {}
                          )
                        }
                        ),/*ESMSA-388*/
                        if(
                          local!flagEconomica = "S",                       
                        a!columnLayout(
                          contents: {
                            a!checkboxField(
                              choiceLabels: {"Económico"},
                              choiceValues: {true()},
                              label: "",
                              labelPosition: "ABOVE",
                              value: local!selection5,
                              saveInto: {local!selection5},
                              choiceLayout: "COMPACT",
                              validations: {}
                            )
                          }
                        ),
                        null
                        )
                      }
                    )

                  }
                ),
                a!columnLayout(
                  contents: {}
                )
              }
            ),
            /*Campo instrucciones*/
            a!paragraphField(
              label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{cc1ec718-fd2c-4c0d-8aca-a7682b959e21}Instrucciones',
              labelPosition: "ABOVE",
              value: local!instrucciones,
              saveInto: {local!instrucciones},
              refreshAfter: "UNFOCUS",
              characterLimit: 1000,
              height: "MEDIUM",
              required: true(),
              requiredMessage: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{e7bac9f0-8fb4-4b56-941f-2fbc7874fc45}Por favor, seleccione un valor',
              validations: {}
            ),
            /*Campo observaciones*/
            a!paragraphField(
              label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{ee4f6b48-57f5-4057-883d-cbd6c6303784}Observaciones',
              labelPosition: "ABOVE",
              value: local!observaciones,
              saveInto: {local!observaciones},
              refreshAfter: "UNFOCUS",
              characterLimit: 1000,
              height: "MEDIUM",
              validations: {}
            )
          },
          height: "AUTO",
          style: "TRANSPARENT",
          marginBelow: "STANDARD",
          showBorder: false()
        )
      },
      height: "AUTO",
      style: "TRANSPARENT",
      shape: "ROUNDED",
      marginAbove: "MORE",
      marginBelow: "STANDARD"
    ),
    a!buttonLayout(
      primaryButtons: {
        /*Botón Guardar*/
        a!buttonWidget(
          label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{3303cc79-5445-4beb-a056-5d7d05c45612}GUARDAR',
          saveInto: {
            
            a!save(local!error, false),
            /*ESMSA-388* Guardamos el resultado de argumento positivo*/
            if(
              local!flagEconomica = "S",
            a!save( local!resultadoModificarMarcaEco ,rule!SCA2_modificarMarcaEconomica(
              codArg: local!referencia,
              mcaEconomica: if(
                a!isNullOrEmpty(local!selection5),
                "N",
                "S"
              ),
            )),
            null
            ),
            /*Sube el archivo a Appian*/
            a!submitUploadedFiles(
              onSuccess: a!save(local!error, false),
              onError: a!save(local!error, fv!error),
              documents: local!documento
            ),
            
            /*En caso de que sea un alta de argumento y exista un documento, realiza el alta del documento en documentum*/
            if(
              and(a!isNullOrEmpty(ri!argumento), a!isNotNullOrEmpty(local!documento)),
              a!save(
                local!documentumResponse, 
                rule!SCA2_altaDocumento(
                file: local!documento
              )
              ),
              null()
            ),
            
            /*En caso de que sea una modificación, hay que ver si ya hay un documento previo o no y de si hay uno que sustituya*/
            if(
              and(
                a!isNotNullOrEmpty(ri!argumento),
                local!cambioDocumento = true,
                a!isNotNullOrEmpty(local!documento)
              ),
              /*Caso de que hubiese un documento y se haya modificado hay que dar de alta el nuevo*/
              {
                a!save(
                local!documentumResponse, 
                rule!SCA2_altaDocumento(
                  file: local!documento
                )
              ),
                a!save(local!documentumResponseMod, rule!SCA2_modificarDocument(
                  documentId: ri!argumento.numDoc,
                  template: cons!SCA2_TXT_SGD_COD_DOCUMENTAL,
                  modifiedDocument: local!documento,
                  fileName: local!documentumResponse.object_name
                ))
              },
              /*Caso de que hubiese un documento y no se haya modificado no hemos de hacer ningún cambio*/
              null
            ),
            
            
            /*Se realiza el alta/modificación del argumento con los datos proporcionados*/
            a!save(
              local!response,
              if(
                a!isNullOrEmpty(ri!argumento),
                rule!SCA2_guardarTipoArg(
                  MSEGuardarTipoArg: a!map(
                    codCompania: local!codigoCompania,
                    codEstado: if(
                      a!isNotNullOrEmpty(local!estado),
                      local!estado,
                      "N"
                    ),
                    descArg: if(
                      a!isNotNullOrEmpty(local!descripcion),
                      local!descripcion,
                      ""
                    ),
                    fecVigencia: if(
                      a!isNotNullOrEmpty(local!fechaVigente),
                      local!fechaVigente,
                      null()
                    ),
                    idLineaNegocio: local!lineaNegocio,
                    idRamo: local!ramaNegocio,
                    infoUsuario: a!map(
                      codCiaUsuario: 1,
                      nuuma: "PCAFCON",
                      codPerfil: local!referencia,
                      codSubPerfil: ""
                    ),
                    instruccion: local!instrucciones,
                    mcaFinalizado: if(
                      a!isNotNullOrEmpty(local!selection1),
                      "S",
                      "N"
                    ),
                    nombreDoc: if(
                      a!isNullOrEmpty(local!documento),
                      "",
                      if(
                          a!isNotNullOrEmpty(local!documentumResponse),
                          local!documentumResponse.object_name,
                          ""
                        )  
                    ),
                    numDoc: if(
                      a!isNullOrEmpty(local!documento),
                      "",
                      if(
                          a!isNotNullOrEmpty(local!documentumResponse),
                          local!documentumResponse.r_object_id,
                          ""
                        )
                    ),
                    observaciones: if(
                      a!isNotNullOrEmpty(local!observaciones),
                      local!observaciones,
                      ""
                    ),
                    codIdCampana: if(
                      a!isNotNullOrEmpty(local!campanaSeleccionada),
                      local!campanaSeleccionada,
                      ""
                    ),
                    codTipBon: if(
                      a!isNotNullOrEmpty(local!selectBonificacion),
                      local!selectBonificacion,
                      ""
                    ),
                    numTipBon: if(
                      a!isNotNullOrEmpty(local!bonificacion),
                      local!bonificacion,
                      ""
                    ),
                    regateable: if(
                      a!isNotNullOrEmpty(local!selection2),
                      "S",
                      "N"
                    ),
                    mcaTeCuidamos: if(
                      a!isNotNullOrEmpty(local!selection3),
                      "S",
                      "N"
                    ),
                    mcaTrebCalc: if(
                      a!isNotNullOrEmpty(local!selection4),
                      "S",
                      "N"
                    ),
                    numDiasSgo: if(
                      a!isNotNullOrEmpty(local!sgo),
                      local!sgo,
                      0
                    ),
                    codTareaSgo: if(
                      a!isNotNullOrEmpty(local!sgoseleccionado),
                      local!sgoseleccionado,
                      ""
                    ),
                    codCompaniaArg: local!codigoCompania,
                    txtUrlArg: if(
                      a!isNotNullOrEmpty(local!urlseleccionado),
                      local!urlseleccionado,
                      ""
                    )
                  )
                ),
                rule!SCA2_modificarArgumento(
                  MSEModificarArgumento: a!map(
                    codCompania: local!codigoCompania,
                    codDocumento:  if(
                      a!isNullOrEmpty(local!documento),
                      "",
                      if(
                        local!cambioDocumento = true,
                        if(
                          a!isNotNullOrEmpty(local!documentumResponse),
                          local!documentumResponse.r_object_id,
                          ""
                        ),
                        index(ri!argumento, "numDoc")
                      )
                    ),
                    codRamo: tostring(local!ramaNegocio),
                    codTipoArgumento: local!referencia,
                    codTipoNegocio: local!lineaNegocio,
                    descTipoArgumento: if(
                      a!isNotNullOrEmpty(local!descripcion),
                      local!descripcion,
                      ""
                    ),
                    fecVigencia: if(
                      a!isNotNullOrEmpty(local!fechaVigente),
                      local!fechaVigente,
                      ""
                    ),
                    infoUsuario: a!map(
                      codCiaUsuario: 1,
                      nuuma: "PCAFCON",
                      codPerfil: tostring(local!referencia),
                      codSubPerfil: ""
                    ),
                    instruccion: if(
                      a!isNotNullOrEmpty(local!instrucciones),
                      local!instrucciones,
                      ""
                    ),
                    mcaEstado:  if(
                      a!isNotNullOrEmpty(local!estado),
                      local!estado,
                      "N"
                    ),
                    mcaFinPositivo:  if(
                      a!isNotNullOrEmpty(local!selection1),
                      "S",
                      "N"
                    ),
                    nombreDoc: if(
                      a!isNullOrEmpty(local!documento),
                      "",
                      if(
                        local!cambioDocumento = true,
                        if(
                          a!isNotNullOrEmpty(local!documentumResponse),
                          local!documentumResponse.object_name,
                          ""
                        ),
                        index(ri!argumento, "nombreDoc")
                      )
                    ),
                    observaciones: if(
                      a!isNotNullOrEmpty(local!observaciones),
                      local!observaciones,
                      ""
                    ),
                    codIdCampana: if(
                      a!isNotNullOrEmpty(local!campanaSeleccionada),
                      local!campanaSeleccionada,
                      ""
                    ),
                    codTipBon: if(
                      a!isNotNullOrEmpty(local!selectBonificacion),
                      local!selectBonificacion,
                      ""
                    ),
                    numTipBon: if(
                      a!isNotNullOrEmpty(local!bonificacion),
                      local!bonificacion,
                      ""
                    ),
                    regateable:  if(
                      a!isNotNullOrEmpty(local!selection2),
                      "S",
                      "N"
                    ),
                    mcaTeCuidamos:  if(
                      a!isNotNullOrEmpty(local!selection3),
                      "S",
                      "N"
                    ),
                    numDiasSgo: if(
                      a!isNotNullOrEmpty(local!sgo),
                      local!sgo,
                      0
                    ),
                    codTareaSgo: if(
                      a!isNotNullOrEmpty(local!sgoseleccionado),
                      local!sgoseleccionado,
                      ""
                    ),
                    codCompaniaArg: local!codigoCompania,
                    txtUrlArg: if(
                      a!isNotNullOrEmpty(local!urlseleccionado),
                      local!urlseleccionado,
                      ""
                    ),
                    mcaTrebCalc: if(
                      a!isNotNullOrEmpty(local!selection4),
                      "S",
                      "N"
                    )
                  )
                )
              )
            ),
            
            /*Si ha habido algún error salta un mensaje*/
            if(
              or(
                a!isNullOrEmpty(index(local!response, 1, null)),
                a!isNullOrEmpty(index(index(local!response, 1, null), if(local!modificar, "MSSModificarArgumento", "MSSGuardarTipoArg")))
              ),
              {
                a!save(local!error, true),
                a!save(local!mensaje, substitute(local!response[2], "�", "ó"))
              },
              null
            ),
            
            /*Se elimina el documento actual y el original si había de Appian*/
            if(
              local!error,
              null,
              if(
                a!isNotNullOrEmpty(local!documento),
                a!deleteDocument(local!documento),
                null()
              )
            ),
            /*if(
              a!isNotNullOrEmpty(local!docOriginal),
              a!deleteDocument(local!docOriginal),
              null()
            ),*/
             if(
               local!error,
               null,
               {
                 
                 a!save(local!mcaVentanaInfo, true),
                 
             /*Ponemos las ri de nuevo a null y seteamos las variabes locales al valor por defecto*/
             a!save(local!referencia, ri!argumento.codTpArg),
             a!save(local!lineaNegocio, ri!argumento.idLineaNegocio),
             a!save(local!ramaNegocio, ri!argumento.idRamo),
             a!save(local!estado, if(a!isNotNullOrEmpty(ri!argumento), ri!argumento.codEstado, null)),
             a!save(local!descripcion, ri!argumento.descArg),
             a!save(local!fechaVigente, ri!argumento.fecVigencia),
             a!save(local!fechaModificacion, ri!argumento.fecModificado),
             a!save(local!campanaSeleccionada, ri!argumento.codIdCampana),
             a!save(local!codigoCompania, ri!argumento.codCompaniaArg),
             a!save(local!bonificacion, ri!argumento.numTipBon),
             a!save(local!selectBonificacion, ri!argumento.codTipBon),
             a!save(local!sgo, ri!argumento.numDiasSgo),
             a!save(local!sgoseleccionado, ri!argumento.codTareaSgo),
             a!save(local!urlseleccionado, if(contains(index(local!url, "url"), ri!argumento.txtUrlArg), ri!argumento.txtUrlArg, null)),
             a!save(local!selection1, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaFinalizado = "S", true, null), null)),
             a!save(local!selection2, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.regateable = "S", true, null),null)),
             a!save(local!selection3, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaTeCuidamos = "S", true, null), null)),
             a!save(local!selection4, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaTrebCalc = "S", true, null),null)),
             a!save(local!instrucciones, ri!argumento.instruccion),
             a!save(local!observaciones, ri!argumento.observaciones),
             a!save(local!documentumResponse, null),
             a!save(local!documentumResponseMod, null),
             a!save(local!docOriginal, ri!documento),
             a!save(ri!argumento, null),
             a!save(ri!documento, null),
             a!save(ri!documentoURL, null),
             a!save(ri!visualizarDoc, null),
             /*a!save(ri!buscarArgumento, null),*/
             /*a!save(ri!estadoArg, null),*/
             /*a!save(ri!descripcionArg, null),*/
             a!save(ri!modificarFechaArg, null),
             /*a!save(ri!lineaNegocio, null)*/
             }),
             
             /*Se vuelve a la interfaz de búsqueda a menos que haya ocurrido un error*/
             if(
               local!error = true,
               null,
               {
               /*a!save(ri!buscarArgumento.MSEConsultarTipoArg.codEstado, ri!estadoArg),*/
               /*a!save(ri!buscarArgumento.MSEConsultarTipoArg.desc, ri!descripcionArg),*/
               /*a!save(ri!buscarArgumento.MSEConsultarTipoArg.fechaMod, ri!modificarFechaArg),*/
               /*a!save(ri!buscarArgumento.MSEConsultarTipoArg.idLineaNegocio, ri!lineaNegocio),*/
               a!save(ri!buscarArgumento, rule!SCA2_consultarTipoArgCore(
                 mseConsultarTipoArgDTO: a!map(
                   codEstado: ri!estadoArg,
                   desc: ri!descripcionArg,
                   fechaMod: ri!modificarFechaArg,
                   idLineaNegocio: ri!lineaNegocio
                 )
               ))
               }
             )
            
          },
          style: "SOLID",
          color: cons!SCA2_VAL_COLOR_ROJO,
          validate: true(),
          validationGroup: "Reference"
        )
      },
      secondaryButtons: {
        /*Botón Cancelar*/
        a!buttonWidget(
          label: 'translation!{af55580e-8058-4c43-92d3-29e57c7d4445}SCA Traducciones.{1aa13f40-3be0-46ca-986e-756ad3bda23f}CANCELAR',
          saveInto: {
          /*Borramos el documento generado en Appian en caso de que haya*/  
          if(
              a!isNotNullOrEmpty(local!documento),
              a!deleteDocument(local!documento),
              null()
            ),  
            
          a!save(local!error, false),
          a!save(ri!modificacion, false),
          /*Devolvemos los valores por defecto al volver atrás*/
          a!save(local!referencia, ri!argumento.codTpArg),
          a!save(local!lineaNegocio, ri!argumento.idLineaNegocio),
          a!save(local!ramaNegocio, ri!argumento.idRamo),
          a!save(local!estado, if(a!isNotNullOrEmpty(ri!argumento), ri!argumento.codEstado, null)),
          a!save(local!descripcion, ri!argumento.descArg),
          a!save(local!fechaVigente, ri!argumento.fecVigencia),
          a!save(local!fechaModificacion, ri!argumento.fecModificado),
          a!save(local!campanaSeleccionada, ri!argumento.codIdCampana),
          a!save(local!codigoCompania, ri!argumento.codCompaniaArg),
          a!save(local!bonificacion, ri!argumento.numTipBon),
          a!save(local!selectBonificacion, ri!argumento.codTipBon),
          a!save(local!sgo, if(or(a!defaultValue(ri!argumento.numDiasSgo, 1) = 0, a!isNullOrEmpty(ri!argumento)), null, 1)),
          a!save(local!sgoseleccionado, ri!argumento.codTareaSgo),
          a!save(local!urlseleccionado, if(contains(index(local!url, "url"), ri!argumento.txtUrlArg), ri!argumento.txtUrlArg, null)),
          a!save(local!selection1, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaFinalizado = "S", true, null), null)),
          a!save(local!selection2, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.regateable = "S", true, null),null)),
          a!save(local!selection3, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaTeCuidamos = "S", true, null), null)),
          a!save(local!selection4, if(a!isNotNullOrEmpty(ri!argumento), if(ri!argumento.mcaTrebCalc = "S", true, null),null)),
          a!save(local!instrucciones, ri!argumento.instruccion),
          a!save(local!observaciones, ri!argumento.observaciones),
          a!save(local!documentumResponse, null),
          a!save(local!documentumResponseMod, null),
          a!save(local!docOriginal, null),
          a!save(ri!argumento, null),
          a!save(ri!modificacion, null),
          a!save(ri!documento, null),
          a!save(ri!documentoURL, null),
          a!save(ri!visualizarDoc, null),
          /*a!save(ri!buscarArgumento, null),*/
          /*a!save(ri!estadoArg, null),*/
          /*a!save(ri!descripcionArg, null),*/
          a!save(ri!modificarFechaArg, null),
          /*a!save(ri!lineaNegocio, null)*/
          },
          style: "LINK",
          color: cons!SCA2_VAL_COLOR_ROJO
        )
      }
    )
    },
    showWhen: and(or( ri!visualizarDoc = false, a!isNullOrEmpty(ri!visualizarDoc)), local!mcaVentanaInfo = false),
    showBorder: false()
    ),
    
    rule!SCA2_VisualizacionDocumento(
      show: ri!visualizarDoc,
      documento: local!documento
    ),
    
    a!cardLayout(
      contents: {
        rule!SCA2_ContraAnulacionModalInformativo(
      mcaVentanaInfo: local!mcaventanaInfo,
      mensaje: if(local!error, "Ha habido un error modificando el argumento", "El argumento se guardó correctamente"),
      mcaVentanaRecuperacion: ri!modificacion
    )
      },
      showWhen: local!mcaVentanaInfo
    )
  }
)
