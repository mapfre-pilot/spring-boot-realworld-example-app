/* [SCA2] Popup de alta — port de SCA_AltaSolicitudAnulacionPopUpEstrategicas
   (mismas validaciones y textos; records SCA2). Inputs:
   poliza (Text), vista (Text: BUSQUEDA/POPUP/ALTA), polizaAlta (Text) */
a!localVariables(
  local!errorRolAltitude: false,
  local!eleccionPoliza: 1,
  local!tipoPoliza: if(
    a!isNullOrEmpty(ri!poliza),
    null,
    rule!SCA2_obtenerTipoPoliza(numPoliza: ri!poliza)
  ),
  local!polizawAutemis: local!tipoPoliza = cons!SCA2_TXT_WAUTEMIS,
  local!polizaVida: local!tipoPoliza = cons!SCA2_TXT_VIDA_RIESGO,
  local!validacion: if(
    local!polizaVida,
    { msg: null, bloquear: false },
    if(
      a!isNullOrEmpty(ri!poliza),
      null,
      rule!SCA2_validacionesPreviasPopupAlta(numPoliza: ri!poliza)
    )
  ),
  local!detallesPoliza: if(
    local!polizawAutemis,
    rule!SCA2_consultarPolizas(P_NUM_POLIZA: ri!poliza),
    if(
      local!polizaVida,
      rule!SCA2_consultarPolizaVidaRiesgo(
        numPoliza: ri!poliza,
        responseDetailLevel: ""
      ),
      a!localVariables(
        local!pObtenerPolizaFecha: rule!SCA2_pObtenerPolizaFecha(
          mSEPObtenerPolizaFechaDTO: a!map(
            pcodcia: 41,
            pnumpoliza: ri!poliza,
            pnumapli: 0,
            pnumsptoapli: 0,
            pmcaconsultaglobal: "S",
            pmcalk: "S"
          )
        ),
        if(
          or(
            a!isNullOrEmpty(
              index(
                local!pObtenerPolizaFecha,
                "MSSPObtenerPolizaFecha",
                null
              )
            ),
            a!isNullOrEmpty(
              index(
                index(
                  local!pObtenerPolizaFecha,
                  "MSSPObtenerPolizaFecha",
                  null
                ),
                "poconpolizat",
                null
              )
            )
          ),
          rule!SCA2_pObtenerPolizaFecha(
            mSEPObtenerPolizaFechaDTO: a!map(
              pcodcia: 41,
              pnumpoliza: ri!poliza,
              pnumapli: 0,
              pnumsptoapli: 0,
              pmcaconsultaglobal: "S",
              pmcalk: "S",
              pfechaconsulta: todate(a!addDateTime(today(), 1))
            )
          ),
          local!pObtenerPolizaFecha
        )
      )
    )
  ),
  local!polizaVigente: rule!SCA2_polizaVigente(numPoliza: ri!poliza),
  local!datosPersonales: if(
    local!polizawAutemis,
    index(
      index(
        index(
          local!detallesPoliza,
          "MSSConsultarPolizas"
        ),
        "DATOS_PCA"
      ),
      "DATOS_TO"
    ),
    reduce(
      index(_, _, null),
      local!detallesPoliza,
      {
        "MSSPObtenerPolizaFecha",
        "poconpolizat",
        "array",
        1,
        "datospersonales",
        "array",
        1
      }
    )
  ),
  local!datosPoliza: reduce(
    index(_, _, null),
    local!detallesPoliza,
    if(
      local!polizawAutemis,
      {
        "MSSConsultarPolizas",
        "DATOS_PCA",
        "DATOS_POLIZA"
      },
      {
        "MSSPObtenerPolizaFecha",
        "poconpolizat",
        "array",
        1,
        "datosgeneralespol",
        "array",
        1
      }
    )
  ),
  local!detallesSuplemento: reduce(
    index(_, _, null),
    local!detallesPoliza,
    if(
      local!polizawAutemis,
      {
        "MSSConsultarPolizas",
        "DATOS_PCA",
        "DATOS_POLIZA"
      },
      {
        "MSSPObtenerPolizaFecha",
        "poconpolizat",
        "array",
        1,
        "datosgeneralesspto",
        "array",
        1
      }
    )
  ),
  local!codInt: index(
    local!datosPersonales,
    if(
      local!polizawAutemis,
      "COD_INT",
      "codint"
    ),
    null
  ),
  local!consultaSolicitudes: index(
    rule!SCA2_consultarSolicitudes(
      numPoliza: ri!poliza,
      codInt: local!codInt,
      tpBusqueda: 0
    ),
    "MSSConsultarSolicitudes",
    null
  ),
  local!solicitudSinResolucion: if(
    a!isNullOrEmpty(local!consultaSolicitudes),
    null,
    index(
      local!consultaSolicitudes,
      wherecontains(
        { "1", "2" },
        index(
          local!consultaSolicitudes,
          "codEstSolic",
          null
        )
      ),
      null
    )
  ),
  local!idSCA2EnCurso: rule!SCA2_consultarSolicitudEnCurso(numPoliza: ri!poliza),
  local!solicitudExistenteFuera: or(a!isNotNullOrEmpty(local!idSCA2EnCurso), if(
    a!isNullOrEmpty(ri!poliza),
    null,
    and(
      a!isNotNullOrEmpty(local!consultaSolicitudes),
      a!isNotNullOrEmpty(local!solicitudSinResolucion)
    )
  )),
  /* Solicitud abierta en CORE que existe en SCA2: se ofrece abrir su Detalle (SCA abre la decisora de la solicitud existente) */
  local!idSolicitudAbierta: a!defaultValue(local!idSCA2EnCurso, if(
    a!isNullOrEmpty(local!solicitudSinResolucion),
    null,
    tostring(
      a!defaultValue(
        index(
          index(
            local!solicitudSinResolucion,
            "idSolicitud",
            null
          ),
          1,
          null
        ),
        ""
      )
    )
  )),
  local!solicitudSCA2Abierta: if(
    a!isNullOrEmpty(local!idSolicitudAbierta),
    null,
    index(
      a!queryRecordType(
        recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
        fields: {
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud'
        },
        filters: a!queryFilter(
          field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
          operator: "=",
          value: local!idSolicitudAbierta
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
      ),
      "data",
      1,
      null
    )
  ),
  local!idSolicitudConsulta: a!defaultValue(
    local!idSolicitudAbierta,
    if(
      a!isNullOrEmpty(local!consultaSolicitudes),
      null,
      tostring(
        index(
          index(local!consultaSolicitudes, "idSolicitud", null),
          1,
          null
        )
      )
    )
  ),
  local!polizaPendiente: if(
    local!polizawAutemis,
    index(
      local!datosPoliza,
      "MCA_PENDIENTE",
      false
    ) = "S",
    index(
      local!datosPoliza,
      "nomestadooperacion",
      false
    ) = "VIGENTE - PENDIENTE DE SOLICITUD"
  ),
  local!polizaTemporal: index(
    local!detallesSuplemento,
    "tipduracion",
    null
  ) = "2",
  local!codRamo: if(
    local!polizaVida,
    reduce(
      index(_, _, null),
      local!detallesPoliza,
      { "contractData", 1, "accountingFieldCode" }
    ),
    index(
      local!datosPoliza,
      if(
        local!polizawAutemis,
        "COD_RAMO",
        "codproducto"
      ),
      null
    )
  ),
  local!bloquearAlta: or(
    a!isNullOrEmpty(trim(ri!poliza)),
    index(local!validacion, "bloquear", false),
    local!solicitudExistenteFuera,
    ri!poliza = "00000000000",
    regexmatch("[a-zA-Z]+", ri!poliza),
    a!isNullOrEmpty(
      if(
        local!polizaVida,
        index(
          local!detallesPoliza,
          "contractData",
          null
        ),
        if(
          local!polizawAutemis,
          index(
            local!detallesPoliza,
            "MSSConsultarPolizas",
            null
          ),
          reduce(
            index(_, _, null),
            local!detallesPoliza,
            {
              "MSSPObtenerPolizaFecha",
              "poconpolizat"
            }
          )
        )
      )
    ),
    and(
      local!codRamo <> "210",
      local!codRamo <> "200",
      local!codRamo <> "73",
      local!codRamo <> "101"
    ),
    local!polizaPendiente,
    local!polizaVigente = false
  ),
  a!columnsLayout(
    columns: {
      a!columnLayout(),
      a!columnLayout(
        contents: {
          a!cardLayout(
            contents: {
              a!cardLayout(
                contents: {
                  a!columnsLayout(
                    columns: {
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: a!richTextItem(
                            text: "Alta solicitud anulación",
                            linkStyle: "STANDALONE",
                            color: cons!SCA2_VAL_COLOR_NEGRO,
                            size: "MEDIUM",
                            style: "STRONG"
                          )
                        )
                      ),
                      a!columnLayout(
                        contents: a!buttonLayout(
                          primaryButtons: a!buttonWidget(
                            icon: "times",
                            saveInto: {
                              a!save(ri!vista, "BUSQUEDA"),
                              a!save(ri!poliza, null),
                              a!save(ri!polizaAlta, null)
                            },
                            size: "STANDARD",
                            style: "LINK",
                            color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                          )
                        )
                      )
                    }
                  )
                },
                showBorder: false()
              ),
              a!cardLayout(
                contents: a!dropdownField(
                  choiceLabels: { "NO VIDA", "VIDA" },
                  choiceValues: { 1, 2 },
                  label: "Tipo Poliza",
                  labelPosition: "ABOVE",
                  value: local!eleccionPoliza,
                  placeholder: "--- Seleccionar un valor ---",
                  saveInto: { local!eleccionPoliza },
                  searchDisplay: "AUTO"
                ),
                height: "AUTO",
                style: "TRANSPARENT",
                marginBelow: "STANDARD",
                showBorder: false
              ),
              a!richTextDisplayField(),
              a!cardLayout(
                contents: a!sideBySideLayout(
                  items: {
                    a!sideBySideItem(
                      item: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextIcon(
                          icon: "exclamation-circle",
                          color: "NEGATIVE",
                          size: "MEDIUM"
                        )
                      ),
                      width: "MINIMIZE"
                    ),
                    a!sideBySideItem(
                      item: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: "El usuario no tiene permisos para realizar altas."
                      )
                    )
                  },
                  alignVertical: "MIDDLE"
                ),
                showWhen: local!errorRolAltitude,
                style: "ERROR",
                marginAbove: "STANDARD",
                accessibilityText: "Mensaje informativo"
              ),
              a!cardLayout(
                contents: a!textField(
                  label: "Número póliza",
                  labelPosition: "ABOVE",
                  value: trim(ri!poliza),
                  saveInto: {
                    ri!poliza,
                    a!save(
                      ri!poliza,
                      if(
                        a!isNullOrEmpty(ri!poliza),
                        null,
                        if(
                          local!eleccionPoliza = 1,
                          concat(
                            repeat(13 - len(trim(ri!poliza)), "0"),
                            trim(ri!poliza)
                          ),
                          len(ri!poliza) > 10,
                          left(ri!poliza, 10),
                          concat(
                            repeat(10 - len(trim(ri!poliza)), "0"),
                            trim(ri!poliza)
                          )
                        )
                      )
                    )
                  },
                  refreshAfter: "UNFOCUS",
                  characterLimit: if(local!eleccionPoliza = 1, 13, 10),
                  showCharacterCount: false,
                  required: true,
                  validations: if(
                    regexmatch("[a-zA-Z]+", ri!poliza),
                    "El formato de la póliza no es el esperado",
                    if(
                      len(ri!poliza) > 13,
                      "La longitud del número de póliza debe ser inferior a 13 caracteres",
                      if(
                        or(
                          a!isNullOrEmpty(
                            if(
                              local!polizaVida,
                              index(
                                local!detallesPoliza,
                                "contractData",
                                null
                              ),
                              if(
                                local!polizawAutemis,
                                index(
                                  local!detallesPoliza,
                                  "MSSConsultarPolizas",
                                  null
                                ),
                                reduce(
                                  index(_, _, null),
                                  local!detallesPoliza,
                                  {
                                    "MSSPObtenerPolizaFecha",
                                    "poconpolizat"
                                  }
                                )
                              )
                            )
                          ),
                          and(
                            local!codRamo <> "210",
                            local!codRamo <> "200",
                            local!codRamo <> "73",
                            local!codRamo <> "101"
                          )
                        ),
                        "La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.",
                        if(
                          index(local!datosPoliza, "MCA_PRRA", null) = "S",
                          "POLIZA EN PRRA",
                          if(
                            local!polizaPendiente,
                            cons!SCA2_TXT_SOLICITUD_EN_CURSO,
                            if(
                              a!isNotNullOrEmpty(index(local!validacion, "msg", null)),
                              index(local!validacion, "msg", null),
                              if(
                                local!polizaTemporal,
                                "La póliza tiene una duración de caracter temporal. Esta póliza se anulará al vencimiento por lo que no se precisa contra anulación.",
                                if(
                                  local!solicitudExistenteFuera,
                                  if(
                                    a!isNotNullOrEmpty(local!solicitudSCA2Abierta),
                                    cons!SCA2_TXT_SOLICITUD_EN_CURSO,
                                    cons!SCA2_TXT_SOLICITUD_EN_CURSO
                                  ),
                                  ""
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                ),
                showBorder: false()
              ),
              a!horizontalLine(
                marginAbove: "STANDARD",
                marginBelow: "STANDARD"
              ),
              a!columnsLayout(
                columns: {
                  a!columnLayout(
                    contents: a!buttonLayout(
                      secondaryButtons: a!buttonWidget(
                        label: "CANCELAR",
                        saveInto: {
                          a!save(ri!vista, "BUSQUEDA"),
                          a!save(ri!poliza, null),
                          a!save(ri!polizaAlta, null)
                        },
                        width: if(
                          a!isPageWidth("TABLET_LANDSCAPE"),
                          "FILL",
                          "MINIMIZE"
                        ),
                        style: "LINK",
                        color: "NEGATIVE"
                      )
                    )
                  ),
                  a!columnLayout(
                    contents: a!buttonLayout(
                      /* R46-C (analista): con solicitud en curso el botón es CONSULTAR SOLICITUD y abre el Detalle de la solicitud de la póliza (SCA2 o CORE) */
                      primaryButtons: if(
                        and(
                          or(local!solicitudExistenteFuera, local!polizaPendiente),
                          a!isNotNullOrEmpty(local!idSolicitudConsulta)
                        ),
                        a!buttonWidget(
                          label: "CONSULTAR SOLICITUD",
                          saveInto: {
                            a!save(
                              ri!idSolicitud,
                              local!idSolicitudConsulta
                            ),
                            a!save(ri!vista, "DETALLE"),
                            a!save(ri!poliza, null),
                            a!save(ri!polizaAlta, null)
                          },
                          style: "SOLID",
                          color: cons!SCA2_VAL_COLOR_ROJO
                        ),
                        a!buttonWidget(
                          label: "ALTA SOLICITUD ANULACIÓN",
                          saveInto: if(
                            local!bloquearAlta,
                            {},
                            {
                              a!save(ri!polizaAlta, ri!poliza),
                              a!save(ri!vista, "ALTA")
                            }
                          ),
                          style: "SOLID",
                          disabled: a!isNullOrEmpty(ri!poliza),
                          color: cons!SCA2_VAL_COLOR_ROJO
                        )
                      )
                    ),
                    width: "NARROW_PLUS"
                  )
                },
                stackWhen: {
                  "PHONE",
                  "TABLET_PORTRAIT",
                  "TABLET_LANDSCAPE"
                }
              )
            },
            height: "AUTO",
            style: "TRANSPARENT",
            shape: "ROUNDED",
            marginBelow: "STANDARD",
            showShadow: true()
          )
        },
        width: "2X"
      ),
      a!columnLayout()
    }
  )
)