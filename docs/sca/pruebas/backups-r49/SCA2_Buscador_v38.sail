a!localVariables(
  local!pagingInfo: a!pagingInfo(
    startIndex: 1,
    batchSize: 10,
    sort: {
      a!sortInfo(
        field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
        ascending: false
      )
    }
  ),
  /* Paridad SCA (Cancelar en Alta limpia la búsqueda): los filtros se reinician al cambiar de vista */
  local!fPoliza: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!eleccionPoliza: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  /* R49-B (paridad SCA_BuscarSolicitudClientePoliza): sin espacios y con ceros a la izquierda hasta 13 (NO VIDA) o 10 (VIDA) */
  /* R49-E: sin Tipo Póliza se trata como NO VIDA (SCA arranca con NO VIDA); evita comparar nulo con número */
  local!fPolizaNorm: if(
    a!isNullOrEmpty(trim(local!fPoliza)),
    null,
    if(
      and(a!defaultValue(local!eleccionPoliza, 1) = 1, len(trim(local!fPoliza)) < 13),
      concat(repeat(13 - len(trim(local!fPoliza)), "0"), trim(local!fPoliza)),
      and(a!defaultValue(local!eleccionPoliza, 1) = 2, len(trim(local!fPoliza)) < 10),
      concat(repeat(10 - len(trim(local!fPoliza)), "0"), trim(local!fPoliza)),
      trim(local!fPoliza)
    )
  ),
  /* Paridad SCA_BuscarSolicitudClientePoliza: validación de la póliza tecleada (existe y es anulable por SCA) */
  local!polizaDetailsBusq: if(
    or(
      a!isNullOrEmpty(local!fPolizaNorm),
      regexmatch("[a-zA-Z]+", local!fPolizaNorm)
    ),
    null,
    reduce(
      index(_, _, null),
      rule!SCA2_pObtenerPolizaFecha(
        {
          pcodcia: 41,
          pnumpoliza: local!fPolizaNorm,
          pnumapli: 0,
          pnumsptoapli: 0,
          pmcaconsultaglobal: "S",
          pmcalk: "S"
        }
      ),
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
  local!tipoPolizaBusq: if(
    a!isNullOrEmpty(local!polizaDetailsBusq),
    null,
    rule!SCA2_obtenerTipoPoliza(numPoliza: local!fPolizaNorm)
  ),
  local!codRamoBusq: if(
    a!isNotNullOrEmpty(local!polizaDetailsBusq),
    index(
      local!polizaDetailsBusq,
      "codproducto",
      "000"
    ),
    "000"
  ),
  local!errorPolizaBusq: if(
    a!isNullOrEmpty(local!fPolizaNorm),
    null,
    if(
      regexmatch("[a-zA-Z]+", local!fPolizaNorm),
      "El formato de la póliza no es el esperado",
      if(
        or(
          a!isNullOrEmpty(local!polizaDetailsBusq),
          and(
            local!tipoPolizaBusq <> "wAutemis",
            local!codRamoBusq <> "210",
            local!codRamoBusq <> "200",
            local!codRamoBusq <> "73"
          )
        ),
        "La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.",
        null
      )
    )
  ),
  /* Con póliza inválida no se filtra: se conserva la tabla de últimas solicitudes, como SCA */
  local!fPolizaBusq: if(
    a!isNullOrEmpty(local!errorPolizaBusq),
    local!fPolizaNorm,
    null
  ),
  local!fSolicitud: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fNombre: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fApe1: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fApe2: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fTipoDoc: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fNumDoc: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fEstado: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fLineaNegocio: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fMatricula: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!fBastidor: a!refreshVariable(value: null, refreshOnVarChange: ri!vista),
  local!seleccionado: 1,
  /* vista: BUSQUEDA / POPUP / ALTA / DETALLE (port de SCA_BuscadorSolicitudPrincipalEstrategicas)
     Persistida en la URL del site vía ri!vista/ri!numPoliza/ri!idSolicitud/ri!tipoAccion/ri!idTarea */
  local!vista: a!defaultValue(ri!vista, "BUSQUEDA"),
  local!mensajeAlta: null,
  /* Matrícula / bastidor -> lista de pólizas (buscarMatricula) */
  local!polizasMatricula: if(
    and(
      a!isNullOrEmpty(local!fMatricula),
      a!isNullOrEmpty(local!fBastidor)
    ),
    null,
    index(
      rule!SCA2_buscarMatricula(
        bastidor: local!fBastidor,
        matricula: local!fMatricula
      ),
      "MSSBuscarMatricula",
      "RESP_EXT_GEST_DOC",
      "LISTA_POLIZAS",
      null
    )
  ),
  /* Búsqueda por cliente (paridad SCA_BuscarSolicitudClientePoliza): consultarDP por tipo+nº documento o por
     nombre+apellido1 -> dpersonal[].COD_INT -> consultarSolicitudes (tpBusqueda 1) por cada tercero */
  local!buscaCliente: and(
    local!seleccionado = 1,
    or(
      and(
        a!isNotNullOrEmpty(local!fTipoDoc),
        a!isNotNullOrEmpty(local!fNumDoc)
      ),
      and(
        a!isNotNullOrEmpty(local!fNombre),
        a!isNotNullOrEmpty(local!fApe1)
      )
    )
  ),
  local!detallesPersonales: if(
    not(local!buscaCliente),
    null,
    if(
      and(
        a!isNotNullOrEmpty(local!fTipoDoc),
        a!isNotNullOrEmpty(local!fNumDoc)
      ),
      rule!SCA2_consultarDP(
        MSEconsultarDP: 'type!{http://ARQ_DatTercero_SLIB/PARAMETROS_ACTDIR/4_0_0}PARAMETROS_CONDP_DPER'(
          p_cod_docum: upper(trim(local!fNumDoc)),
          p_tip_docum: local!fTipoDoc,
          p_cod_cia: 1,
          p_mca_lk: "N",
          p_cod_idioma: "es_ES",
          p_rows: 100,
          p_mca_potencial: "N",
          p_cabecera: "N",
          p_cod_act_tercero: 1,
          p_mca_temporal: "N",
          p_cod_act_tercero_acceso: 1
        )
      ),
      rule!SCA2_consultarDP(
        MSEconsultarDP: 'type!{http://ARQ_DatTercero_SLIB/PARAMETROS_ACTDIR/4_0_0}PARAMETROS_CONDP_DPER'(
          p_nom_tercero: local!fNombre,
          p_ape1_tercero: local!fApe1,
          p_ape2_tercero: local!fApe2,
          p_cod_cia: 1,
          p_mca_lk: "N",
          p_cod_idioma: "es_ES",
          p_rows: 100,
          p_mca_potencial: "N",
          p_cabecera: "N",
          p_cod_act_tercero: 1,
          p_mca_temporal: "N",
          p_cod_act_tercero_acceso: 1
        )
      )
    )
  ),
  local!codsCliente: a!forEach(
    items: a!flatten(
      a!defaultValue(
        index(
          index(
            local!detallesPersonales,
            "MSSconsultarDP",
            null
          ),
          "dpersonal",
          null
        ),
        {}
      )
    ),
    expression: tostring(
      a!defaultValue(index(fv!item, "COD_INT", null), "")
    )
  ),
  local!solsCliente: if(
    a!isNullOrEmpty(local!codsCliente),
    {},
    a!flatten(
      a!forEach(
        items: local!codsCliente,
        expression: a!flatten(
          a!defaultValue(
            index(
              rule!SCA2_consultarSolicitudes(
                numPoliza: "",
                codInt: fv!item,
                tpBusqueda: "1"
              ),
              "MSSConsultarSolicitudes",
              null
            ),
            {}
          )
        )
      )
    )
  ),
  local!polizasCliente: a!forEach(
    items: a!flatten(local!solsCliente),
    expression: tostring(
      a!defaultValue(
        index(
          fv!item,
          "numPoliza",
          index(fv!item, "numPolizaDTO", null)
        ),
        ""
      )
    )
  ),
  /* Paridad SCA_BuscarSolicitudClientePoliza: CORE devuelve también las solicitudes históricas y las creadas en SCA */
  local!solsCore: if(
    a!isNotNullOrEmpty(local!fPolizaBusq),
    a!flatten(
      index(
        rule!SCA2_consultarSolicitudes(
          numPoliza: local!fPolizaBusq,
          codInt: "",
          tpBusqueda: "0"
        ),
        "MSSConsultarSolicitudes",
        {}
      )
    ),
    if(
      a!isNotNullOrEmpty(local!codsCliente),
      a!flatten(local!solsCliente),
      {}
    )
  ),
  local!dummy,
  local!q: a!queryRecordType(
    recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        /* Solicitudes sin idSolicitud de Core7 (PDTE-*) solo se ven en la bandeja de Errores */
        a!queryFilter(
          field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
          operator: "not starts with",
          value: "PDTE-"
        ),
        if(
          a!isNullOrEmpty(local!fPolizaBusq),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
            operator: ">",
            value: 0
          ),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
            operator: "=",
            value: local!fPolizaBusq
          )
        ),
        if(
          a!isNullOrEmpty(local!fSolicitud),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
            operator: ">",
            value: 0
          ),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
            operator: "=",
            value: local!fSolicitud
          )
        ),
        if(
          a!isNullOrEmpty(local!fEstado),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
            operator: ">",
            value: 0
          ),
          /* Paridad SCA_D_EstadosFinalesBuscador: cada opción del desplegable agrupa varios estados internos SCA2 */
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
            operator: "in",
            value: a!flatten(
              a!forEach(
                items: local!fEstado,
                expression: a!match(
                  value: tostring(fv!item),
                  equals: cons!SCA2_TXT_ESTADO_SOL_PENDIENTE,
                  then: {
                    cons!SCA2_TXT_ESTADO_SOL_PENDIENTE,
                    "EN_PROCESO",
                    "PDTE",
                    "ALTA",
                    "DECIDIDA",
                    cons!SCA2_TXT_ESTADO_SOL_EN_ACCION,
                    cons!SCA2_TXT_ESTADO_SOL_PDTE_FINALIZAR,
                    cons!SCA2_TXT_ESTADO_SOL_PDTE_MECANIZAR
                  },
                  equals: cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION,
                  then: {
                    cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION,
                    "PENDIENTE_AUTORIZACION_ANULACION"
                  },
                  equals: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA,
                  then: {
                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA,
                    "RECHAZADA",
                    "ERROR"
                  },
                  equals: cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                  then: { cons!SCA2_TXT_ESTADO_SOL_CADUCADA, cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA },
                  default: tostring(fv!item)
                )
              )
            )
          )
        ),
        if(
          a!isNullOrEmpty(local!fLineaNegocio),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
            operator: ">",
            value: 0
          ),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio',
            operator: "=",
            value: local!fLineaNegocio
          )
        ),
        if(
          not(local!buscaCliente),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
            operator: ">",
            value: 0
          ),
          /* Cliente sin solicitudes en CORE: ningún resultado (el operador "in" no admite lista vacía) */
          if(
            a!isNullOrEmpty(local!polizasCliente),
            a!queryFilter(
              field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
              operator: "<",
              value: 0
            ),
            a!queryFilter(
              field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
              operator: "in",
              value: local!polizasCliente
            )
          )
        ),
        if(
          and(
            a!isNullOrEmpty(local!fMatricula),
            a!isNullOrEmpty(local!fBastidor)
          ),
          a!queryFilter(
            field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
            operator: ">",
            value: 0
          ),
          if(
            a!isNullOrEmpty(local!polizasMatricula),
            a!queryFilter(
              field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
              operator: "<",
              value: 0
            ),
            a!queryFilter(
              field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
              operator: "in",
              value: local!polizasMatricula
            )
          )
        )
      }
    ),
    fields: {
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud.fields.{b3b05401-6420-4d28-8c0a-d55c0665a687}desccausa',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud.fields.{d3ea438a-426e-4524-b46c-052fb101097d}codcausa',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud.fields.{78fc061f-12bd-441e-aa55-dcff066af9fe}fecsolicitudanul',
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud.fields.{ef1b0aa7-41ee-4590-83b2-52f89c8be7f5}fecimpresion'
    },
    pagingInfo: local!pagingInfo,
    fetchTotalCount: true
  ),
  local!idsSca2: touniformstring(
    a!forEach(
      items: index(local!q, "data", {}),
      expression: tostring(
        index(
          fv!item,
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
          ""
        )
      )
    )
  ),
  local!solsCoreOtras: a!localVariables(
    local!idx: where(
      a!forEach(
        items: local!solsCore,
        expression: not(
          contains(
            local!idsSca2,
            tostring(index(fv!item, "idSolicitud", ""))
          )
        )
      )
    ),
    if(
      a!isNullOrEmpty(local!idx),
      {},
      index(local!solsCore, local!idx, {})
    )
  ),
  local!mecPrecargadas: a!forEach(
    items: local!solsCoreOtras,
    expression: a!localVariables(
      local!idMec: tostring(index(fv!item, "idSolicitud", "")),
      local!estMec: tostring(index(fv!item, "codEstSolic", "")),
      local!mecTexto: if(
        and(a!isNotNullOrEmpty(local!idMec), contains({"2", "4", "5"}, local!estMec)),
        tostring(index(rule!SCA2_consultaBBDDSCA(
          idSolicitud: local!idMec,
          devolverSolicitud: false, devolverObservaciones: false,
          devolverGestiones: false, devolverMecanizacion: true,
          devolverAcciones: false, devolverAutorizaciones: false,
          devolverNotificaciones: false, devolverSGO: false, devolverCTO: false
        ), "mecanizacion", "")),
        ""
      ),
      local!codigo: trim(if(
        find("codTipEstMecaniza:", local!mecTexto) = 0,
        "",
        index(split(index(split(local!mecTexto, "codTipEstMecaniza:"), 2, ""), {",", "]"}), 1, "")
      )),
      a!map(idSolicitud: local!idMec, codigo: if(a!isNullOrEmpty(local!codigo), cons!SCA2_TXT_COD_EST_MECANIZACION_SIN, local!codigo))
    )
  ),
  {
    if(
      local!vista = "POPUP",
      rule!SCA2_AltaSolicitudAnulacionPopUp(
        poliza: ri!numPoliza,
        vista: ri!vista,
        polizaAlta: ri!numPoliza,
        idSolicitud: ri!idSolicitud
      ),
      if(
        local!vista = "ALTA",
        rule!SCA2_AltaSolicitudPage(
          numPoliza: ri!numPoliza,
          vista: ri!vista,
          idSolicitudSel: ri!idSolicitud,
          tipoAccion: ri!tipoAccion,
          idTarea: ri!idTarea
        ),
        if(
          a!isNotNullOrEmpty(ri!idSolicitud),
          rule!SCA2_DetalleSolicitud(
            idSolicitud: ri!idSolicitud,
            idSel: ri!idSolicitud,
            tipoAccion: ri!tipoAccion,
            idTarea: ri!idTarea,
            numPoliza: ri!numPoliza
          ),
          {
            if(
              a!isNotNullOrEmpty(local!mensajeAlta),
              a!cardLayout(
                contents: a!sideBySideLayout(
                  items: {
                    a!sideBySideItem(
                      item: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextIcon(icon: "check-circle", color: "POSITIVE")
                      ),
                      width: "MINIMIZE"
                    ),
                    a!sideBySideItem(
                      item: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: local!mensajeAlta,
                          color: "POSITIVE"
                        )
                      )
                    ),
                    a!sideBySideItem(
                      item: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextIcon(
                          icon: "times",
                          link: a!dynamicLink(
                            saveInto: a!save(local!mensajeAlta, null)
                          ),
                          color: "SECONDARY",
                          linkStyle: "STANDALONE"
                        )
                      ),
                      width: "MINIMIZE"
                    )
                  },
                  alignVertical: "MIDDLE"
                ),
                marginBelow: "STANDARD",
                style: "SUCCESS",
                shape: "ROUNDED"
              ),
              {}
            ),
            a!cardLayout(
              contents: {
                a!columnsLayout(
                  columns: {
                    a!columnLayout(
                      contents: {
                        a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: a!richTextItem(
                            text: "Buscar solicitud por",
                            size: "MEDIUM",
                            color: cons!SCA2_VAL_COLOR_NEGRO,
                            style: "STRONG",
                            linkStyle: "STANDALONE"
                          )
                        )
                      },
                      width: "NARROW"
                    ),
                    a!forEach(
                      items: { "Cliente", "Póliza" },
                      expression: a!columnLayout(
                        contents: {
                          a!columnsLayout(
                            columns: {
                              a!columnLayout(
                                contents: {
                                  a!richTextDisplayField(
                                    labelPosition: "COLLAPSED",
                                    value: a!richTextItem(
                                      text: fv!item,
                                      link: a!dynamicLink(
                                        saveInto: a!save(local!seleccionado, fv!index)
                                      ),
                                      style: if(
                                        local!seleccionado = fv!index,
                                        "STRONG",
                                        "PLAIN"
                                      ),
                                      linkStyle: "STANDALONE"
                                    ),
                                    accessibilityText: if(
                                      fv!index = local!seleccionado,
                                      "Selected section.",
                                      "Unselected section. Press enter to select section."
                                    ),
                                    align: "RIGHT"
                                  )
                                }
                              )
                            },
                            showDividers: true()
                          )
                        },
                        width: "EXTRA_NARROW"
                      )
                    ),
                    a!columnLayout(contents: {}),
                    a!columnLayout(
                      contents: {
                        a!buttonLayout(
                          primaryButtons: a!buttonWidget(
                            label: "ALTA SOLICITUD ANULACIÓN",
                            value: "POPUP",
                            saveInto: {
                              a!save(ri!numPoliza, null),
                              a!save(local!mensajeAlta, null),
                              a!save(ri!vista, save!value)
                            },
                            color: cons!SCA2_VAL_COLOR_ROJO,
                            style: "SOLID",
                            size: "SMALL"
                          )
                        )
                      }
                    )
                  },
                  alignVertical: "MIDDLE"
                ),
                a!horizontalLine(
                  marginAbove: "NONE",
                  marginBelow: "STANDARD"
                ),
                a!cardLayout(
                  showBorder: false,
                  contents: {
                    a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: a!richTextItem(
                        text: "Completa al menos uno de los campos marcados *",
                        size: "SMALL",
                        color: cons!SCA2_VAL_COLOR_NEGRO,
                        style: "STRONG"
                      )
                    ),
                    if(
                      local!seleccionado = 1,
                      /* Pestaña Cliente (consultarDP -> consultarSolicitudes, como SCA) */
                      a!columnsLayout(
                        columns: {
                          a!columnLayout(
                            contents: {
                              a!textField(
                                label: "Nombre o razón social",
                                labelPosition: "ABOVE",
                                value: local!fNombre,
                                saveInto: local!fNombre,
                                refreshAfter: "UNFOCUS",
                                required: true
                              )
                            }
                          ),
                          a!columnLayout(
                            contents: {
                              a!textField(
                                label: "Primer apellido",
                                labelPosition: "ABOVE",
                                value: local!fApe1,
                                saveInto: local!fApe1,
                                refreshAfter: "UNFOCUS",
                                required: true
                              )
                            }
                          ),
                          a!columnLayout(
                            contents: {
                              a!textField(
                                label: "Segundo apellido",
                                labelPosition: "ABOVE",
                                value: local!fApe2,
                                saveInto: local!fApe2,
                                refreshAfter: "UNFOCUS"
                              )
                            }
                          ),
                          a!columnLayout(
                            contents: {
                              a!dropdownField(
                                label: "Tipo documento",
                                labelPosition: "ABOVE",
                                placeholder: "--- Selecione ---",
                                value: local!fTipoDoc,
                                saveInto: {
                                  /* Limpiamos los parámetros de búsqueda que no aplican (paridad SCA) */
                                  a!save(local!fPoliza, null),
                                  a!save(local!fMatricula, null),
                                  a!save(local!fBastidor, null),
                                  local!fTipoDoc
                                },
                                choiceLabels: cons!SCA2_TXT_DESCRIPCIONES_TIPO_DOCUMENTO_BUSQUEDA,
                                choiceValues: cons!SCA2_TXT_TIPO_DOCUMENTO_BUSQUEDA
                              )
                            }
                          ),
                          a!columnLayout(
                            contents: {
                              a!textField(
                                label: "Número documento",
                                labelPosition: "ABOVE",
                                value: local!fNumDoc,
                                saveInto: local!fNumDoc,
                                refreshAfter: "UNFOCUS",
                                required: true
                              )
                            }
                          )
                        }
                      ),
                      /* Pestaña Póliza: Tipo Poliza (NO VIDA/VIDA) como SCA */
                      {
                        a!columnsLayout(
                          columns: {
                            a!columnLayout(
                              contents: {
                                a!dropdownField(
                                  label: "Tipo Poliza",
                                  labelPosition: "ABOVE",
                                  placeholder: "--- Seleccionar un valor ---",
                                  value: local!eleccionPoliza,
                                  saveInto: {
                                    local!eleccionPoliza,
                                    a!save(
                                      local!fMatricula,
                                      if(
                                        local!eleccionPoliza = 2,
                                        null,
                                        local!fMatricula
                                      )
                                    ),
                                    a!save(
                                      local!fBastidor,
                                      if(
                                        local!eleccionPoliza = 2,
                                        null,
                                        local!fBastidor
                                      )
                                    )
                                  },
                                  choiceLabels: { "NO VIDA", "VIDA" },
                                  choiceValues: { 1, 2 },
                                  searchDisplay: "AUTO"
                                )
                              }
                            ),
                            a!columnLayout(
                              contents: {
                                a!textField(
                                  label: "Número póliza",
                                  labelPosition: "ABOVE",
                                  value: local!fPoliza,
                                  saveInto: local!fPoliza,
                                  refreshAfter: "UNFOCUS",
                                  required: true,
                                  validations: local!errorPolizaBusq,
                                  characterLimit: 13,
                                  showCharacterCount: false
                                )
                              }
                            ),
                            a!columnLayout(
                              contents: {
                                a!textField(
                                  label: "Matrícula",
                                  labelPosition: "ABOVE",
                                  value: local!fMatricula,
                                  saveInto: local!fMatricula,
                                  refreshAfter: "UNFOCUS",
                                  required: true
                                )
                              }
                            ),
                            a!columnLayout(
                              contents: {
                                a!textField(
                                  label: "Número bastidor",
                                  labelPosition: "ABOVE",
                                  value: local!fBastidor,
                                  saveInto: local!fBastidor,
                                  refreshAfter: "UNFOCUS",
                                  required: true
                                )
                              }
                            )
                          }
                        )
                      }
                    ),
                    a!horizontalLine(
                      marginAbove: "STANDARD",
                      marginBelow: "STANDARD"
                    ),
                    a!buttonArrayLayout(
                      buttons: {
                        a!buttonWidget(
                          label: "LIMPIAR",
                          saveInto: {
                            a!save(local!fPoliza, null),
                            a!save(local!fSolicitud, null),
                            a!save(local!fNombre, null),
                            a!save(local!fApe1, null),
                            a!save(local!fApe2, null),
                            a!save(local!fTipoDoc, null),
                            a!save(local!fNumDoc, null),
                            a!save(local!fEstado, null),
                            a!save(local!fLineaNegocio, null),
                            a!save(local!fMatricula, null),
                            a!save(local!fBastidor, null)
                          },
                          width: "MINIMIZE",
                          color: "SECONDARY",
                          size: "SMALL"
                        ),
                        a!buttonWidget(
                          label: "BUSCAR SOLICITUD",
                          saveInto: {
                            a!save(local!dummy, null),
                            /* Paridad SCA_BuscarSolicitudClientePoliza: con un único resultado se abre su Detalle */
                            if(
                              tointeger(
                                a!defaultValue(index(local!q, "totalCount", 0), 0)
                              ) = 1,
                              a!save(
                                ri!idSolicitud,
                                tostring(
                                  index(
                                    index(index(local!q, "data", {}), 1, null),
                                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                                    null
                                  )
                                )
                              ),
                              {}
                            )
                          },
                          disabled: if(
                            local!seleccionado = 1,
                            /* Paridad SCA: tipo+nº documento, o nombre+primer apellido */
                            not(
                              or(
                                and(
                                  a!isNotNullOrEmpty(local!fTipoDoc),
                                  a!isNotNullOrEmpty(local!fNumDoc)
                                ),
                                and(
                                  a!isNotNullOrEmpty(local!fNombre),
                                  a!isNotNullOrEmpty(local!fApe1)
                                )
                              )
                            ),
                            and(
                              a!isNullOrEmpty(local!fPoliza),
                              a!isNullOrEmpty(local!fMatricula),
                              a!isNullOrEmpty(local!fBastidor)
                            )
                          ),
                          width: "MINIMIZE",
                          color: cons!SCA2_VAL_COLOR_ROJO,
                          style: "SOLID",
                          size: "SMALL"
                        )
                      },
                      align: "END"
                    ),
                    a!cardLayout(
                      contents: {
                        a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: a!richTextItem(
                            text: "Últimas solicitudes gestionadas",
                            size: "MEDIUM",
                            color: cons!SCA2_VAL_COLOR_NEGRO,
                            style: "STRONG"
                          )
                        ),
                        a!columnsLayout(
                          columns: {
                            a!columnLayout(
                              contents: {
                                a!multipleDropdownField(
                                  label: "Estado",
                                  labelPosition: "ABOVE",
                                  placeholder: "-- Selecciona un estado --",
                                  value: local!fEstado,
                                  saveInto: local!fEstado,
                                  choiceLabels: {
                                    "Pendiente",
                                    "Finalizada positivamente",
                                    "Finalizado negativo con contraanulación",
                                    "Finalizada no requerida contraanulación",
                                    "Caducada",
                                    "Cancelada",
                                    "Pendiente de Autorizar",
                                    "Finalizado autorizado (sí anulada)",
                                    "Finalizada no autorizado (no anulada)"
                                  },
                                  choiceValues: {
                                    cons!SCA2_TXT_ESTADO_SOL_PENDIENTE,
                                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
                                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA,
                                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ,
                                    cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                                    "CANCELADA",
                                    cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION,
                                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR
                                  },
                                  searchDisplay: "AUTO"
                                )
                              }
                            ),
                            a!columnLayout(
                              contents: {
                                a!dropdownField(
                                  label: "Línea de negocio",
                                  placeholder: "-- Selecciona una línea de negocio --",
                                  value: local!fLineaNegocio,
                                  saveInto: local!fLineaNegocio,
                                  choiceLabels: cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE,
                                  choiceValues: cons!SCA2_INT_ID_LINEA_NEGOCIO
                                )
                              }
                            ),
                            a!columnLayout(contents: {})
                          }
                        ),
                        a!horizontalLine(),
                        rule!SCA2_BuscadorTabla(
                          data: index(local!q, "data", {}),
                          pagingInfo: local!pagingInfo,
                          idSel: ri!idSolicitud,
                          /* totalCount del DataSubset para que el grid pagine como SCA */
                          totalCount: tointeger(
                            a!defaultValue(index(local!q, "totalCount", 0), 0)
                          )
                        ),
                        if(
                          a!isNullOrEmpty(local!solsCoreOtras),
                          {},
                          {
                            a!richTextDisplayField(
                              labelPosition: "COLLAPSED",
                              value: a!richTextItem(
                                text: "Otras solicitudes de la póliza / cliente (SCA e históricas en CORE, sin gestión en SCA2)",
                                size: "MEDIUM",
                                color: cons!SCA2_VAL_COLOR_NEGRO,
                                style: "STRONG"
                              ),
                              marginAbove: "STANDARD"
                            ),
                            a!gridField_25r3(
                              labelPosition: "COLLAPSED",
                              emptyGridMessage: "No hay resultados para dicha búsqueda",
                              data: local!solsCoreOtras,
                              columns: {
                                a!gridColumn(
                                  label: "Número solicitud",
                                  value: a!linkField(
                                    links: a!dynamicLink(
                                      /* Paridad SCA_BuscadorTabla (SCA_PM_REDIRIGIRDETALLE): la fila CORE abre su Detalle de sólo consulta */
                                      label: tostring(
                                        a!defaultValue(index(fv!row, "idSolicitud", "-"), "-")
                                      ),
                                      saveInto: {
                                        a!save(
                                          ri!numPoliza,
                                          tostring(
                                            a!defaultValue(index(fv!row, "numPoliza", null), "")
                                          )
                                        ),
                                        a!save(
                                          ri!idSolicitud,
                                          tostring(index(fv!row, "idSolicitud", null))
                                        )
                                      }
                                    )
                                  )
                                ),
                                a!gridColumn(
                                  label: "Estado",
                                  value: a!localVariables(
                                    /* codEstSolic CORE → estado SCA2 (misma tabla que SCA_D_EstadosSolicitud) */
                                    local!estSca2: a!match(
                                      value: tostring(
                                        a!defaultValue(index(fv!row, "codEstSolic", ""), "")
                                      ),
                                      equals: "3",
                                      then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
                                      equals: "4",
                                      then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA,
                                      equals: "15",
                                      then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA,
                                      equals: "5",
                                      then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ,
                                      equals: "6",
                                      then: cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                                      equals: "11",
                                      then: cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                                      equals: "12",
                                      then: cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                                      equals: "14",
                                      then: "CANCELADA",
                                      equals: "16",
                                      then: cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION,
                                      equals: "17",
                                      then: cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION,
                                      equals: "18",
                                      then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                                      equals: "19",
                                      then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR,
                                      default: cons!SCA2_TXT_ESTADO_SOL_PENDIENTE
                                    ),
                                    /* R45-D: estados de la tabla de etiquetas (cod_tip_est_solic + cod_tip_est_mecaniza) con la misma regla que la lista */
                                    local!codEstLista: tostring(a!defaultValue(index(fv!row, "codEstSolic", ""), "")),
                                    local!idLista: tostring(a!defaultValue(index(fv!row, "idSolicitud", ""), "")),
                                    local!estLista: if(
                                      and(
                                        a!isNotNullOrEmpty(local!idLista),
                                        contains({"1", "2", "3", "4", "5", "6", "11", "12", "14", "20"}, local!codEstLista)
                                      ),
                                      rule!SCA2_calcularEstadoSolicitud(
                                        codEstMecaniza: index(index(local!mecPrecargadas, index(wherecontains(local!idLista, touniformstring(index(local!mecPrecargadas, "idSolicitud", {}))), 1, 0), null), "codigo", cons!SCA2_TXT_COD_EST_MECANIZACION_SIN),
                                        estadoSolicitud: local!codEstLista,
                                        idSolicitud: local!idLista,
                                        datosGestiones: rule!SCA2_consultaGestion(codSolicitud: local!idLista)
                                      ),
                                      local!estSca2
                                    ),
                                    a!tagField(
                                      tags: a!tagItem_24r2(
                                        text: rule!SCA2_textoEstadoSolicitud(estado: local!estLista),
                                        backgroundColor: rule!SCA2_colorEstadoSolicitud(estado: local!estLista),
                                        textColor: cons!SCA2_VAL_COLOR_BLANCO
                                      )
                                    )
                                  )
                                ),
                                a!gridColumn(
                                  label: "Fecha solicitud",
                                  value: tostring(
                                    a!defaultValue(index(fv!row, "fecSolicitud", "-"), "-")
                                  )
                                ),
                                a!gridColumn(
                                  label: "Número póliza",
                                  value: tostring(
                                    a!defaultValue(index(fv!row, "numPoliza", "-"), "-")
                                  )
                                ),
                                a!gridColumn(
                                  label: "Línea negocio",
                                  value: a!localVariables(
                                    local!ln: tostring(
                                      a!defaultValue(index(fv!row, "idLineaNegocio", ""), "")
                                    ),
                                    if(
                                      a!isNullOrEmpty(local!ln),
                                      "-",
                                      a!defaultValue(
                                        index(
                                          cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE,
                                          tointeger(local!ln),
                                          "-"
                                        ),
                                        "-"
                                      )
                                    )
                                  )
                                ),
                                a!gridColumn(
                                  label: "Causa anulación",
                                  value: tostring(
                                    a!defaultValue(index(fv!row, "causaAnul", "-"), "-")
                                  )
                                ),
                                /* [R9-E F3] CORE rellena fecResolucion también en pendientes (= fecha solicitud): vacía salvo que codEstSolic sea un estado final (3/4/5/6/11/12/14/15/18/19), como SCA_BuscadorTabla */
                                a!gridColumn(
                                  label: "Fecha resolución",
                                  value: if(
                                    not(
                                      contains(
                                        {
                                          "3",
                                          "4",
                                          "5",
                                          "6",
                                          "11",
                                          "12",
                                          "14",
                                          "15",
                                          "18",
                                          "19"
                                        },
                                        tostring(
                                          a!defaultValue(index(fv!row, "codEstSolic", ""), "")
                                        )
                                      )
                                    ),
                                    "-",
                                    tostring(
                                      a!defaultValue(index(fv!row, "fecResolucion", "-"), "-")
                                    )
                                  )
                                ),
                                a!gridColumn(label: "Observaciones", value: "-")
                              },
                              pageSize: 10
                            )
                          }
                        )
                      },
                      showBorder: true,
                      shape: "ROUNDED"
                    ),
                    
                  },
                  padding: "STANDARD"
                ),
                if(
                  a!isNullOrEmpty(ri!idSolicitud),
                  rule!SCA2_PieDePagina(),
                  {}
                )
              },
              shape: "ROUNDED"
            )
          }
        )
      )
    )
  }
)