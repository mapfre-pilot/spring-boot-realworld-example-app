/* [SCA2] Detalle — port de SCA_DecidirAccion + SCA_DetalleSolicitudEstrategicas:
   cabecera gris #F5F5F5 (flecha roja + título + "Más Datos" con chevron),
   tabs con barra roja inferior en la seleccionada (SCA_MilestoneMasDatos),
   acordeón de acciones (card blanca, filas chevron+título+tag, RETOMAR)
   y "Trazabilidad técnica" plegada solo para SCA2 Administrators.
   Inputs: idSolicitud (Text), idSel (Text), tipoAccion (Text), idTarea (Integer), numPoliza (Text, opcional: filas sólo-CORE del Buscador)
   tipoAccion/idTarea vienen del Buscador para persistir la acción abierta en la URL ($sp) */
a!localVariables(
  local!resRetomarCore: null,
  local!solBase: rule!SCA2_cargarSolicitud(ri!idSolicitud),
  /* Solicitud sin registro SCA2 (creada en SCA o histórica de CORE): Detalle de sólo consulta con datos de CORE, como SCA_DetalleSolicitud */
  local!soloCore: a!isNullOrEmpty(index(local!solBase, "estado", null)),
  local!cabCore: if(
    local!soloCore,
    index(
      rule!SCA2_consultarCabeceraSolicitud(codSolicitud: ri!idSolicitud),
      "MSSConsultarCabecera",
      null
    ),
    null
  ),
  local!solBBDDSCA: if(
    and(
      local!soloCore,
      a!isNullOrEmpty(ri!numPoliza)
    ),
    index(
      rule!SCA2_consultaBBDDSCA(
        idSolicitud: ri!idSolicitud,
        devolverSolicitud: true,
        devolverObservaciones: false,
        devolverGestiones: false,
        devolverMecanizacion: false,
        devolverAcciones: false,
        devolverAutorizaciones: false,
        devolverNotificaciones: false,
        devolverSGO: false,
        devolverCTO: false
      ),
      "solicitud",
      null
    ),
    null
  ),
  local!sol: a!refreshVariable(
    value: rule!SCA2_cargarSolicitud(ri!idSolicitud),
    refreshOnVarChange: { ri!tipoAccion, ri!idSolicitud },
    refreshInterval: if(local!soloCore, null, 0.5)
  ),
  local!est: a!defaultValue(index(local!sol, "estado", null), {}),
  local!solVersion: index(local!est, "version", null),
  local!numPoliza: if(
    local!soloCore,
    a!defaultValue(
      ri!numPoliza,
      /* consultaBBDDSCA.solicitud llega como texto "[numSolicitudPca:..., numPoliza:..., codRamo:...]" */
      if(
        a!isNullOrEmpty(local!solBBDDSCA),
        null,
        extract(
          tostring(local!solBBDDSCA) & ",",
          "numPoliza:",
          ","
        )
      )
    ),
    index(local!est, "numPoliza", null)
  ),
  local!origenPol: if(
    local!soloCore,
    rule!SCA2_obtenerTipoPoliza(local!numPoliza),
    index(local!est, "origenPoliza", null)
  ),
  /* codEstSolic CORE -> estado SCA2 (misma tabla que el Buscador / SCA_D_EstadosSolicitud) */
  local!estadoCore: a!match(
    value: tostring(
      a!defaultValue(
        index(local!cabCore, "estadoSolicitud", ""),
        ""
      )
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
    default: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE
  ),
  /* Pestaña "Solicitud Anulación" alimentada por la cabecera CORE (como SCA_SolicitudAnulaci_n) cuando no hay registro SCA2 */
  local!solCore: if(
    not(local!soloCore),
    null,
    a!map(
      estado: a!map(
        estadoSolicitud: local!estadoCore,
        procesoActivo: null,
        nivelIntervencion: index(local!cabCore, "nivelIntervencion", null),
        createdAt: null,
        modifiedAt: null
      ),
      datosSolicitud: a!map(
        fecsolicitudanul: index(local!cabCore, "fecSolicitudAnul", null),
        origen: index(local!cabCore, "origen", null),
        codcausa: index(local!cabCore, "codCausa", null),
        desccausa: index(local!cabCore, "descCausa", null),
        canalentrada: index(local!cabCore, "canalEntrada", null),
        fecestado: index(local!cabCore, "fecEstado", null),
        fecanulacion: index(local!cabCore, "fecAnulacion", null),
        catalogacion: index(local!cabCore, "catalogacion", null),
        fecimpresion: index(local!cabCore, "fecImpresion", null),
        fecefecimpagado: index(local!cabCore, "fecEfecImpagado", null),
        idcompania: index(local!cabCore, "idCompania", null),
        rsvPrima: null
      )
    )
  ),
  local!esVida: or(
    rule!SCA2_obtenerTipoPoliza(local!numPoliza) = cons!SCA2_TXT_VIDA_RIESGO,
    index(local!est, "lineaNegocio", null) = "3"
  ),
  /* Guard paridad SCA ("La tarea solicitada no está disponible"): con la solicitud cerrada la URL de la acción no reabre el formulario */
  local!solicitudCerrada: or(
    local!soloCore,
    index(local!est, "interfazActiva", "") = "FIN",
    contains(
      {
        cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
        cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR,
        cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
        "RECHAZADA",
        "CANCELADA",
        cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
        cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA
      },
      tostring(index(local!est, "estadoSolicitud", ""))
    )
  ),
  /* R28 (23/10): tras ANULAR PÓLIZA (a!startProcessLink encadenado → CMD Mecanizar → componente Inducir Cliente) el site vuelve a esta
     misma URL (tipoAccion/idTarea de la tarea desde la que se pulsó). Si esa tarea ya está cerrada o la anulación ya se lanzó
     (procesoActivo ≠ MECANIZAR*), se muestra el Detalle y no el formulario. Instantáneas al cargar (no se refrescan) para no alterar
     el flujo de la pantalla de tareas abierta (popup CORRECTO / redirección a la mecanización). */
  local!tareaUrlEstado: a!refreshVariable(
    value: if(
      a!isNullOrEmpty(ri!idTarea),
      null,
      tostring(
        index(
          index(
            index(
              a!queryRecordType(
                recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                fields: {
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado'
                },
                filters: a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                  operator: "=",
                  value: tointeger(ri!idTarea)
                ),
                pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                fetchTotalCount: false
              ),
              "data",
              {}
            ),
            1,
            null
          ),
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
          null
        )
      )
    ),
    refreshOnVarChange: { ri!tipoAccion, ri!idTarea },
    refreshOnReferencedVarChange: false
  ),
  local!procesoActivoCarga: a!refreshVariable(
    value: tostring(index(local!est, "procesoActivo", null)),
    refreshOnVarChange: { ri!tipoAccion, ri!idTarea },
    refreshOnReferencedVarChange: false
  ),
  local!tareaUrlCerrada: or(
    contains(
      { cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA, cons!SCA2_TXT_ESTADO_SOL_FINALIZADA, "CANCELADA" },
      upper(
        a!defaultValue(local!tareaUrlEstado, "")
      )
    ),
    and(
      search(
        "MECANIZA",
        upper(
          a!defaultValue(tostring(ri!tipoAccion), "")
        )
      ) > 0,
      a!isNotNullOrEmpty(local!procesoActivoCarga),
      left(upper(local!procesoActivoCarga), 9) <> cons!SCA2_TXT_ACCION_MECANIZAR
    )
  ),
  local!accionAbierta: and(
    a!isNotNullOrEmpty(ri!tipoAccion),
    not(local!solicitudCerrada),
    not(local!tareaUrlCerrada)
  ),
  /* --- cabecera --- */
  local!collapseData: false,
  local!tab: 2,
  /* R27-A: pestaña inicial Datos póliza */
  local!opciones: {
    "Datos cliente",
    "Datos póliza",
    "Solicitud Anulación",
    "Otras sol. Anulación",
    "Datos contacto",
    "Notificaciones"
  },
  local!estructuraCabecera: a!refreshVariable(
    value: if(
      a!isNullOrEmpty(local!numPoliza),
      {},
      rule!SCA2_obtenerDatosCabecera(
        numPoliza: local!numPoliza,
        idSolicitud: ri!idSolicitud
      )
    ),
    refreshOnVarChange: ri!tipoAccion
  ),
  local!datosCliente: a!defaultValue(
    index(
      local!estructuraCabecera,
      "datosCliente",
      null
    ),
    {}
  ),
  local!datosPoliza: a!defaultValue(
    index(
      local!estructuraCabecera,
      "datosPoliza",
      null
    ),
    {}
  ),
  local!acuerdoYDistribuidor: index(local!datosPoliza, "acuerdo", ""),
  local!gestionesCore: a!refreshVariable(
    value: a!defaultValue(
      index(
        rule!SCA2_consultaGestion(codSolicitud: ri!idSolicitud),
        "MSSConsultaGestion",
        {}
      ),
      {}
    ),
    refreshOnVarChange: {
      ri!tipoAccion,
      ri!idSolicitud,
      local!solVersion
    },
    refreshInterval: if(local!solicitudCerrada, null, 0.5)
  ),
  local!gestion: index(local!gestionesCore, 1, {}),
  local!gestionAlta: a!defaultValue(
    index(
      reject(
        fn!isnull,
        a!forEach(
          items: local!gestionesCore,
          expression: if(
            tostring(index(fv!item, "accionRealizada", "")) = "8",
            fv!item,
            null
          )
        )
      ),
      1,
      null
    ),
    local!gestion
  ),
  /* --- acordeón: "Alta Solicitud" siempre + tareas SCA2 --- */
  local!tareasQ: a!refreshVariable(
    refreshOnVarChange: { ri!tipoAccion, ri!idSolicitud },
    value: index(
      a!queryRecordType(
        recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
        fields: {
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b06d9250-9260-4788-87f1-041d09d9ac86}proceso',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ba1b2a33-3e00-4e18-96bf-d3cfd74f342b}fechaCierre',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea'
        },
        filters: a!queryFilter(
          field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
          operator: "=",
          value: ri!idSolicitud
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 50)
      ),
      "data",
      {}
    )
  ),
  local!tareas: a!refreshVariable(
    refreshOnVarChange: {
      ri!tipoAccion,
      ri!idSolicitud,
      local!solVersion
    },
    value: index(
      a!queryRecordType(
        recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
        fields: {
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b06d9250-9260-4788-87f1-041d09d9ac86}proceso',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ba1b2a33-3e00-4e18-96bf-d3cfd74f342b}fechaCierre',
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea'
        },
        filters: a!queryFilter(
          field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
          operator: "=",
          value: ri!idSolicitud
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 50)
      ),
      "data",
      {}
    ),
    refreshInterval: if(
      and(
        not(local!soloCore),
        or(
          a!isNullOrEmpty(local!tareasQ),
          index(local!est, "estadoSolicitud", "") <> cons!SCA2_TXT_ESTADO_SOL_EN_ACCION
        )
      ),
      0.5,
      null
    )
  ),
  /* Sin registro SCA2: las tarjetas salen de las gestiones CORE (2 CA, 3 AA, 4 Impresión, 5 Mecanización, 7 Autorización), como SCA_DetalleSolicitud */
  local!tareasCore: if(
    not(local!soloCore),
    {},
    reject(
      fn!isnull,
      a!forEach(
        items: local!gestionesCore,
        expression: a!localVariables(
          local!cod: tostring(
            a!defaultValue(index(fv!item, "accionRealizada", ""), "")
          ),
          local!niv: index(fv!item, "nivelIntervencion", null),
          if(
            not(
              contains({ "2", "3", "4", "5", "7" }, local!cod)
            ),
            null,
            a!map(
              nombre: a!match(
                value: local!cod,
                equals: "2",
                then: "Contra Anulacion",
                equals: "3",
                then: "Acciones Administrativas",
                equals: "4",
                then: "Impresion",
                equals: "5",
                then: "Mecanizacion",
                default: "Autorizacion"
              ),
              tipo: a!match(
                value: local!cod,
                equals: "2",
                then: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
                equals: "3",
                then: "ACCION ADMINISTRATIVA",
                equals: "4",
                then: "IMPRESION",
                equals: "5",
                then: cons!SCA2_TXT_ACCION_MECANIZAR,
                default: cons!SCA2_TXT_ACCION_AUTORIZACION
              ),
              estado: upper(
                tostring(
                  a!defaultValue(
                    index(fv!item, "codEstGestion", null),
                    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA
                  )
                )
              ),
              fecInicio: a!defaultValue(
                index(fv!item, "fecInicioGestion", null),
                "-"
              ),
              fecFin: a!defaultValue(
                index(fv!item, "fecFinGestion", null),
                "-"
              ),
              nivel: if(
                a!isNullOrEmpty(local!niv),
                "-",
                a!defaultValue(
                  index(
                    cons!SCA2_TXT_NIVEL_INTERVENCION,
                    tointeger(local!niv),
                    "-"
                  ),
                  "-"
                )
              ),
              perfil: a!defaultValue(
                index(
                  index(fv!item, "infoUsuario", null),
                  "codPerfil",
                  null
                ),
                "-"
              ),
              grupo: a!defaultValue(
                index(
                  index(fv!item, "infoUsuario", null),
                  "codSubPerfil",
                  null
                ),
                "-"
              ),
              asignadoA: null,
              nuuma: a!defaultValue(
                index(
                  index(fv!item, "infoUsuario", null),
                  "nuuma",
                  null
                ),
                "-"
              ),
              idTarea: null
            )
          )
        )
      )
    )
  ),
  /* R28 (23/10): las tareas internas VERTI cerradas («Gestión Verti/vencimiento», pantalla previa ya pasada) e INDUCCION («Inducción Verti/Vencimiento (componente)»,
     registro que CMD Mecanizar 332/333 sigue escribiendo) no se muestran como tarjetas en «Gestiones realizadas» (petición del analista) */
  local!tareasMaps: if(
    local!soloCore,
    local!tareasCore,
    reject(
      fn!isnull,
      a!forEach(
        items: local!tareas,
        /* La tarjeta VERTI se conserva mientras la tarea esté PENDIENTE: es la vía (RETOMAR) para abrir la pantalla previa Verti/Vencimiento, que se mantiene */
        expression: if(
          a!localVariables(
            local!tipoT: upper(
              a!defaultValue(
                tostring(
                  index(
                    fv!item,
                    'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                    ""
                  )
                ),
                ""
              )
            ),
            local!estT: upper(
              a!defaultValue(
                tostring(
                  index(
                    fv!item,
                    'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                    ""
                  )
                ),
                ""
              )
            ),
            /* R29-A (analista 23/10): vuelven a mostrarse «Gestión Verti/Vencimiento» (con la opción marcada) y la gestión del componente (con su resultado) */
            and(
              local!tipoT = "INDUCCION",
              local!estT = "CANCELADA"
            )
          ),
          null,
          a!localVariables(
            local!tipoG: upper(a!defaultValue(tostring(index(fv!item, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo', "")), "")),
            local!fcT: if(
              a!isNullOrEmpty(index(fv!item, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion', null)),
              null,
              todecimal(text(index(fv!item, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion', null), "yyyyMMddHHmmss"))
            ),
            local!mecsT: if(
              not(or(local!tipoG = "INDUCCION", local!tipoG = cons!SCA2_TXT_CONTACTO_VERTI)),
              {},
              reject(
                fn!isnull,
                a!forEach(
                  items: local!gestionesCore,
                  expression: a!localVariables(
                    local!fi: tostring(a!defaultValue(index(fv!item, "fecInicioGestion", null), "")),
                    if(
                      and(
                        tostring(index(fv!item, "accionRealizada", "")) = "5",
                        or(
                          a!isNullOrEmpty(local!fcT),
                          len(local!fi) < 19,
                          todecimal(mid(local!fi, 7, 4) & mid(local!fi, 4, 2) & left(local!fi, 2) & substitute(mid(local!fi, 12, 8), ":", "")) <= local!fcT
                        )
                      ),
                      fv!item,
                      null
                    )
                  )
                )
              )
            ),
            local!gT: if(a!isNullOrEmpty(local!mecsT), null, index(local!mecsT, length(local!mecsT), null)),
          a!map(
            nombre: index(
              fv!item,
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
              null
            ),
            tipo: index(
              fv!item,
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
              null
            ),
            estado: a!match(
              value: index(
                fv!item,
                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                null
              ),
              equals: cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA,
              then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
              equals: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
              then: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
              equals: "CANCELADA",
              then: "CANCELADA",
              default: if(
                upper(
                  a!defaultValue(
                    tostring(
                      index(
                        fv!item,
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                        ""
                      )
                    ),
                    ""
                  )
                ) = "INDUCCION",
                "EN CURSO",
                "INCOMPLETA"
              )
            ),
            fecInicio: if(
              a!isNullOrEmpty(
                index(
                  fv!item,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion',
                  null
                )
              ),
              "-",
              text(
                index(
                  fv!item,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion',
                  null
                ),
                "dd/MM/yyyy HH:mm:ss"
              )
            ),
            fecFin: if(
              a!isNullOrEmpty(
                index(
                  fv!item,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ba1b2a33-3e00-4e18-96bf-d3cfd74f342b}fechaCierre',
                  null
                )
              ),
              "-",
              text(
                index(
                  fv!item,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ba1b2a33-3e00-4e18-96bf-d3cfd74f342b}fechaCierre',
                  null
                ),
                "dd/MM/yyyy HH:mm:ss"
              )
            ),
            /* R46-A (analista 10/11): Inducción/Verti con el nivel, perfil, grupo y nuuma de la gestión CORE de mecanización en la que se generó la tarea (no el nivel actual de la solicitud); «Nivel X» se formatea en la tarjeta */
            nivel: if(
              a!isNotNullOrEmpty(local!gT),
              a!defaultValue(index(local!gT, "nivelIntervencion", null), "-"),
              a!defaultValue(index(local!est, "nivelIntervencion", null), "-")
            ),
            perfil: if(
              a!isNotNullOrEmpty(local!gT),
              a!defaultValue(index(index(local!gT, "infoUsuario", null), "codPerfil", null), "-"),
              "-"
            ),
            grupo: a!defaultValue(
              if(
                a!isNotNullOrEmpty(local!gT),
                index(index(local!gT, "infoUsuario", null), "codSubPerfil", null),
                null
              ),
              a!defaultValue(index(fv!item, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo', null), "-")
            ),
            asignadoA: index(
              fv!item,
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
              null
            ),
            nuuma: a!defaultValue(
              if(
                a!isNotNullOrEmpty(local!gT),
                index(index(local!gT, "infoUsuario", null), "nuuma", null),
                null
              ),
              a!localVariables(
                local!u: tostring(a!defaultValue(index(local!est, "usuario", null), "")),
                if(
                  a!isNullOrEmpty(local!u),
                  "-",
                  upper(if(find("@", local!u) > 0, left(local!u, find("@", local!u) - 1), local!u))
                )
              )
            ),
            idTarea: index(
              fv!item,
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
              null
            ),
            token: index(
              fv!item,
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea',
              null
            ),
            proceso: index(
              fv!item,
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b06d9250-9260-4788-87f1-041d09d9ac86}proceso',
              null
            )
          )
          )
        )
      )
    )
  ),
  /* Paridad SCA_DetalleSolicitud: la gestión CORE accionRealizada 4 (IMPRESION) se lista como fila solo-cabecera (en SCA su cuerpo es null), antes de la mecanización */
  local!impresiones: if(
    local!soloCore,
    {},
    reject(
      fn!isnull,
      a!forEach(
        items: local!gestionesCore,
        expression: if(
          tostring(index(fv!item, "accionRealizada", "")) = "4",
          a!map(
            nombre: "Impresion",
            tipo: "IMPRESION",
            estado: upper(
              tostring(
                a!defaultValue(
                  index(fv!item, "codEstGestion", null),
                  cons!SCA2_TXT_ESTADO_SOL_FINALIZADA
                )
              )
            ),
            fecInicio: a!defaultValue(
              index(fv!item, "fecInicioGestion", null),
              "-"
            ),
            fecFin: a!defaultValue(
              index(fv!item, "fecFinGestion", null),
              "-"
            ),
            /* R24 #11: fecha y usuario de la impresión de la carta (infoUsuario de la gestión CORE 4) */
            nivel: a!defaultValue(
              index(fv!item, "nivelIntervencion", null),
              "-"
            ),
            perfil: a!defaultValue(
              index(
                index(fv!item, "infoUsuario", null),
                "codPerfil",
                null
              ),
              "-"
            ),
            grupo: a!defaultValue(
              index(
                index(fv!item, "infoUsuario", null),
                "codSubPerfil",
                null
              ),
              "-"
            ),
            asignadoA: null,
            nuuma: a!defaultValue(
              index(
                index(fv!item, "infoUsuario", null),
                "nuuma",
                null
              ),
              "-"
            ),
            idTarea: null
          ),
          null
        )
      )
    )
  ),
  local!nAutTareas: length(
    reject(
      fn!isnull,
      a!forEach(
        items: local!tareasMaps,
        expression: if(
          search(
            cons!SCA2_TXT_ACCION_AUTORIZACION,
            upper(
              a!defaultValue(tostring(index(fv!item, "tipo", "")), "") & " " & a!defaultValue(
                tostring(index(fv!item, "nombre", "")),
                ""
              )
            )
          ) > 0,
          1,
          null
        )
      )
    )
  ),
  local!gestAut: reject(
    fn!isnull,
    a!forEach(
      items: local!gestionesCore,
      expression: if(
        tostring(index(fv!item, "accionRealizada", "")) = "7",
        fv!item,
        null
      )
    )
  ),
  /* Paridad SCA_DetalleSolicitud: gestión CORE 7 (Autorización) sin tarea SCA2 → fila desde CORE */
  local!autCore: if(
    length(local!gestAut) <= local!nAutTareas,
    {},
    a!forEach(
      items: index(
        local!gestAut,
        local!nAutTareas + enumerate(length(local!gestAut) - local!nAutTareas) + 1,
        {}
      ),
      expression: a!map(
        nombre: "Autorizacion",
        tipo: cons!SCA2_TXT_ACCION_AUTORIZACION,
        estado: upper(
          tostring(
            a!defaultValue(
              index(fv!item, "codEstGestion", null),
              "INCOMPLETA"
            )
          )
        ),
        fecInicio: a!defaultValue(
          index(fv!item, "fecInicioGestion", null),
          "-"
        ),
        fecFin: a!defaultValue(
          index(fv!item, "fecFinGestion", null),
          "-"
        ),
        nivel: "-",
        perfil: "-",
        grupo: "-",
        asignadoA: null,
        nuuma: "-",
        idTarea: null
      )
    )
  ),
  local!posMec: index(
    reject(
      fn!isnull,
      a!forEach(
        items: local!tareasMaps,
        expression: if(
          search(
            "MECANIZA",
            upper(
              a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
            )
          ) > 0,
          fv!index,
          null
        )
      )
    ),
    1,
    length(local!tareasMaps) + 1
  ),
  local!accionesBase: if(
    a!isNullOrEmpty(local!impresiones),
    local!tareasMaps,
    {
      if(
        local!posMec > 1,
        index(
          local!tareasMaps,
          enumerate(local!posMec - 1) + 1,
          {}
        ),
        {}
      ),
      local!impresiones,
      if(
        local!posMec <= length(local!tareasMaps),
        index(
          local!tareasMaps,
          local!posMec + enumerate(
            length(local!tareasMaps) - local!posMec + 1
          ),
          {}
        ),
        {}
      )
    }
  ),
  local!posMecBase: index(
    reject(
      fn!isnull,
      a!forEach(
        items: local!accionesBase,
        expression: if(
          search(
            "MECANIZA",
            upper(
              a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
            )
          ) > 0,
          fv!index,
          null
        )
      )
    ),
    1,
    length(local!accionesBase)
  ),
  local!accionesTodas: if(
    a!isNullOrEmpty(local!autCore),
    local!accionesBase,
    {
      if(
        local!posMecBase >= 1,
        index(
          local!accionesBase,
          enumerate(local!posMecBase) + 1,
          {}
        ),
        {}
      ),
      local!autCore,
      if(
        local!posMecBase < length(local!accionesBase),
        index(
          local!accionesBase,
          local!posMecBase + 1 + enumerate(
            length(local!accionesBase) - local!posMecBase
          ),
          {}
        ),
        {}
      )
    }
  ),
  /* R46-A (analista 10/11): el bloque «Gestión Verti/Vencimiento» ya no se muestra; solo queda «Inducción Verti/vencimiento (componente)». La tarea VERTI pendiente se mantiene para poder RETOMAR la pantalla previa */
  local!acciones: reject(
    fn!isnull,
    a!forEach(
      items: local!accionesTodas,
      expression: if(
        and(
          upper(a!defaultValue(tostring(index(fv!item, "tipo", "")), "")) = cons!SCA2_TXT_CONTACTO_VERTI,
          a!defaultValue(tostring(index(fv!item, "estado", "")), "") <> "INCOMPLETA"
        ),
        null,
        fv!item
      )
    )
  ),
  local!fecCre: if(
    a!isNullOrEmpty(index(local!est, "createdAt", null)),
    "-",
    text(
      index(local!est, "createdAt", null),
      "dd/MM/yyyy HH:mm:ss"
    )
  ),
  local!altaExpandida: false,
  local!tareaExpandida: null,
  local!tecAbierto: false,
  local!showPopupReasignar: false,
  local!esAdmin: a!isUserMemberOfGroup(
    loggedInUser(),
    cons!SCA2_GRP_ADMINISTRADORES
  ),
  /* [R9-B B7-SI24] subperfil de la solicitud (decidido por el motor) y si el usuario logado es SI24 */
  local!subPerfilSol: upper(
    a!defaultValue(
      tostring(
        index(
          index(local!sol, "datosPerfilesPca", null),
          "codsubperfil",
          null
        )
      ),
      ""
    )
  ),
  local!usuarioSI24: search(
    "SI24",
    upper(
      a!defaultValue(
        tostring(
          index(
            index(
              rule!SCA2_obtenerInformacionUsuario(),
              "infoUsuarioDTO",
              null
            ),
            "codSubPerfil",
            null
          )
        ),
        ""
      )
    )
  ) > 0,
  {
    if(
      local!accionAbierta,
      rule!SCA2_DetalleTareas(
        idSolicitud: ri!idSolicitud,
        accionAbierta: local!accionAbierta,
        tipoAccion: ri!tipoAccion,
        idTareaAccion: ri!idTarea
      ),
      {
        a!cardLayout(
          contents: a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: {
              a!richTextIcon(icon: "info-circle", color: "SECONDARY"),
              " ",
              a!richTextItem(
                text: "La tarea solicitada no está disponible",
                style: "STRONG"
              )
            }
          ),
          showWhen: and(
            a!isNotNullOrEmpty(ri!tipoAccion),
            local!solicitudCerrada,
            /* R29-A: vuelta del componente encadenado con la tarea de la URL ya cerrada (la solicitud pudo finalizar mientras tanto): Detalle sin aviso */not(local!tareaUrlCerrada)
          ),
          style: "WARN",
          showBorder: true,
          marginBelow: "STANDARD"
        ),
        a!cardLayout(
          contents: a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: {
              a!richTextIcon(icon: "info-circle", color: "SECONDARY"),
              " ",
              a!richTextItem(
                text: "Solicitud gestionada en SCA o histórica: datos de CORE, sólo consulta",
                style: "STRONG"
              )
            }
          ),
          showWhen: local!soloCore,
          style: "INFO",
          showBorder: true,
          marginBelow: "STANDARD"
        ),
        /* ===== Cabecera (port de SCA_DatosCabecera_Estrategicas) ===== */
        a!cardLayout(
          contents: a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: a!columnsLayout(
                  columns: {
                    a!columnLayout(
                      contents: a!richTextDisplayField(
                        value: a!richTextIcon(
                          icon: "arrow-left",
                          link: a!safeLink(
                            uri: "/suite/sites/sca2/page/buscador",
                            openLinkIn: "SAME_TAB"
                          ),
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_ROJO,
                          size: "MEDIUM"
                        )
                      )
                    ),
                    a!columnLayout(
                      contents: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: tostring(local!numPoliza) & " - " & index(local!datosCliente, "nombre", "") & " " & index(local!datosCliente, "apellidos", "") & " - NIF: " & index(local!datosCliente, "nif", ""),
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_NEGRO,
                          size: "STANDARD",
                          style: "STRONG"
                        )
                      ),
                      width: "MEDIUM_PLUS"
                    )
                  },
                  alignVertical: "MIDDLE",
                  showDividers: true
                )
              ),
              a!columnLayout(contents: {}),
              a!columnLayout(
                contents: a!columnsLayout(
                  columns: {
                    a!columnLayout(contents: {}),
                    a!columnLayout(
                      contents: a!sideBySideLayout(
                        items: {
                          /* [43-D] Caché de cabecera: forzarRefresco=true → la Web API SCA2_refrescarCacheCabecera recarga en vivo y renueva la fila CACHE */
                          a!sideBySideItem(
                            item: a!richTextDisplayField(
                              labelPosition: "COLLAPSED",
                              value: {
                                a!richTextIcon(icon: "refresh", color: cons!SCA2_VAL_COLOR_NEGRO),
                                char(32),
                                a!richTextItem(
                                  text: "Actualizar datos",
                                  link: a!dynamicLink(
                                    saveInto: a!save(
                                      local!estructuraCabecera,
                                      rule!SCA2_obtenerDatosCabecera(
                                        numPoliza: local!numPoliza,
                                        idSolicitud: ri!idSolicitud,
                                        forzarRefresco: true
                                      )
                                    )
                                  ),
                                  linkStyle: "STANDALONE",
                                  color: cons!SCA2_VAL_COLOR_NEGRO,
                                  size: "STANDARD",
                                  style: "STRONG"
                                )
                              },
                              align: "RIGHT",
                              marginAbove: "NONE",
                              marginBelow: "NONE"
                            ),
                            showWhen: a!defaultValue(cons!SCA2_USAR_CACHE_CABECERA, false)
                          ),
                          a!sideBySideItem(
                            item: a!richTextDisplayField(
                              labelPosition: "COLLAPSED",
                              value: {
                                a!richTextItem(
                                  text: "Más Datos",
                                  color: cons!SCA2_VAL_COLOR_NEGRO,
                                  size: "STANDARD",
                                  style: "STRONG"
                                ),
                                char(32),
                                a!richTextIcon(
                                  icon: if(
                                    local!collapseData,
                                    "chevron-down",
                                    "chevron-up"
                                  ),
                                  link: a!dynamicLink(
                                    saveInto: a!save(
                                      local!collapseData,
                                      not(local!collapseData)
                                    )
                                  ),
                                  linkStyle: "STANDALONE",
                                  color: cons!SCA2_VAL_COLOR_NEGRO
                                )
                              },
                              align: "RIGHT",
                              marginAbove: "NONE",
                              marginBelow: "NONE"
                            )
                          )
                        },
                        alignVertical: "MIDDLE",
                        marginAbove: "EVEN_LESS",
                        marginBelow: "EVEN_LESS"
                      )
                    )
                  },
                  alignVertical: "MIDDLE"
                )
              )
            },
            alignVertical: "MIDDLE"
          ),
          style: cons!SCA2_VAL_COLOR_GRIS_CLARO,
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false()
        ),
        a!cardLayout(
          contents: {
            a!columnsLayout(
              columns: {
                a!columnLayout(),
                a!forEach(
                  items: local!opciones,
                  expression: a!columnLayout(
                    contents: a!cardLayout(
                      contents: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: fv!item,
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_NEGRO,
                          style: if(local!tab = fv!index, "STRONG", null)
                        ),
                        align: "CENTER"
                      ),
                      style: cons!SCA2_VAL_COLOR_GRIS_CLARO,
                      showBorder: false,
                      decorativeBarPosition: "BOTTOM",
                      decorativeBarColor: if(
                        local!tab = fv!index,
                        cons!SCA2_VAL_COLOR_ROJO,
                        cons!SCA2_VAL_COLOR_BLANCO
                      ),
                      link: a!dynamicLink(saveInto: a!save(local!tab, fv!index)),
                      accessibilityText: if(
                        fv!index = local!tab,
                        "Selected section.",
                        "Unselected section. Press enter to select section."
                      )
                    ),
                    width: "NARROW"
                  )
                ),
                a!columnLayout()
              },
              alignVertical: "MIDDLE",
              marginAbove: "NONE",
              marginBelow: "NONE",
              spacing: "NONE"
            ),
            a!horizontalLine(),
            a!cardLayout(
              contents: choose(
                local!tab,
                rule!SCA2_DatosCliente(
                  datosCliente: local!datosCliente,
                  numPoliza: local!numPoliza
                ),
                rule!SCA2_DatosPoliza(
                  datosPoliza: local!datosPoliza,
                  acuerdoYDistribuidor: local!acuerdoYDistribuidor
                ),
                rule!SCA2_SolicitudAnulacion(
                  idSolicitud: ri!idSolicitud,
                  sol: if(local!soloCore, local!solCore, local!sol)
                ),
                rule!SCA2_TablaOtrasSolAnulacion(
                  numPoliza: local!numPoliza,
                  idSolicitudSel: ri!idSel
                ),
                rule!SCA2_DatosContacto(
                  numPoliza: local!numPoliza,
                  datosContacto: index(
                    local!estructuraCabecera,
                    "datosContacto",
                    {}
                  )
                ),
                rule!SCA2_TablaNotificaciones(
                  numSolicitud: ri!idSolicitud,
                  showWhen: true
                )
              ),
              style: cons!SCA2_VAL_COLOR_GRIS_CLARO,
              padding: "STANDARD",
              showBorder: "NONE"
            )
          },
          showWhen: not(local!collapseData),
          style: cons!SCA2_VAL_COLOR_GRIS_CLARO,
          padding: "LESS",
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        /* R28 (23/10): panel rule!SCA2_InduccionVertiPanel (R26) retirado del Detalle: el componente Inducir Cliente va encadenado tras ANULAR PÓLIZA */
        /* ===== Acordeón de acciones (port de SCA_DetalleSolicitudEstrategicas) ===== */
        a!cardLayout(
          contents: {
            a!cardLayout(
              contents: {
                a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: a!richTextItem(
                    text: "Gestiones realizadas",
                    size: "MEDIUM",
                    style: "STRONG"
                  )
                )
              },
              padding: "STANDARD",
              showBorder: false()
            ),
            a!horizontalLine(marginBelow: "NONE"),
            /* Fila fija "Alta Solicitud": toda solicitud la tiene (Finalizada, verde) */
            {
              a!cardLayout(
                contents: a!sideBySideLayout(
                  items: {
                    a!sideBySideItem(
                      item: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: {
                          a!richTextIcon(
                            icon: if(
                              local!altaExpandida,
                              "chevron-up",
                              "chevron-down"
                            ),
                            color: cons!SCA2_VAL_COLOR_NEGRO
                          ),
                          char(32),
                          a!richTextItem(
                            text: "Alta Solicitud",
                            linkStyle: "STANDALONE",
                            color: cons!SCA2_VAL_COLOR_NEGRO,
                            size: "STANDARD",
                            style: "STRONG"
                          )
                        },
                        marginAbove: "NONE",
                        marginBelow: "NONE"
                      )
                    ),
                    a!sideBySideItem(
                      item: a!tagField(
                        tags: a!tagItem_24r2(
                          text: "Finalizada",
                          backgroundColor: cons!SCA2_VAL_COLOR_VERDE_OSCURO
                        )
                      ),
                      width: "MINIMIZE"
                    )
                  },
                  alignVertical: "MIDDLE",
                  marginAbove: "NONE",
                  marginBelow: "NONE"
                ),
                link: a!dynamicLink(
                  saveInto: a!save(
                    local!altaExpandida,
                    not(local!altaExpandida)
                  )
                ),
                padding: "STANDARD",
                marginAbove: "NONE",
                marginBelow: "NONE",
                showBorder: false
              ),
              a!cardLayout(
                contents: {
                  a!columnsLayout(
                    columns: {
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: {
                            a!richTextItem(
                              text: "Fecha inicio de gestión" & char(10),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            ),
                            a!richTextItem(
                              text: a!defaultValue(
                                index(
                                  local!gestionAlta,
                                  "fecInicioGestion",
                                  null
                                ),
                                local!fecCre
                              ),
                              style: "STRONG"
                            )
                          }
                        )
                      ),
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: {
                            a!richTextItem(
                              text: "Fecha fin de gestión" & char(10),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            ),
                            a!richTextItem(
                              text: a!defaultValue(
                                index(local!gestionAlta, "fecFinGestion", null),
                                local!fecCre
                              ),
                              style: "STRONG"
                            )
                          }
                        )
                      ),
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: {
                            a!richTextItem(
                              text: "Nivel intervención" & char(10),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            ),
                            a!richTextItem(
                              text: a!localVariables(
                                  local!n: cleanwith(tostring(index(local!gestionAlta, "nivelIntervencion", "")), "0123456789"),
                                  if(local!n = "", "-", "Nivel " & local!n)
                                ),
                              style: "STRONG"
                            )
                          }
                        )
                      ),
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: {
                            a!richTextItem(
                              text: "Perfil de usuario" & char(10),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            ),
                            a!richTextItem(
                              text: index(
                                index(local!gestionAlta, "infoUsuario", null),
                                "codPerfil",
                                "-"
                              ),
                              style: "STRONG"
                            )
                          }
                        )
                      )
                    }
                  ),
                  a!columnsLayout(
                    columns: {
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: {
                            a!richTextItem(
                              text: "Grupo" & char(10),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            ),
                            a!richTextItem(
                              text: index(
                                index(local!gestionAlta, "infoUsuario", null),
                                "codSubPerfil",
                                "-"
                              ),
                              style: "STRONG"
                            )
                          }
                        )
                      ),
                      a!columnLayout(
                        contents: a!richTextDisplayField(
                          labelPosition: "COLLAPSED",
                          value: {
                            a!richTextItem(
                              text: "Nuuma de usuario" & char(10),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            ),
                            a!richTextItem(
                              text: index(
                                index(local!gestionAlta, "infoUsuario", null),
                                "nuuma",
                                "-"
                              ),
                              style: "STRONG"
                            )
                          }
                        )
                      ),
                      a!columnLayout(contents: {}),
                      a!columnLayout(contents: {})
                    }
                  ),
                  a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: {
                      a!richTextItem(
                        text: "Observaciones" & char(10),
                        color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                      ),
                      a!richTextItem(
                        text: a!defaultValue(
                          index(local!gestionAlta, "observaciones", null),
                          "-"
                        ),
                        style: "STRONG"
                      )
                    },
                    marginBelow: "MORE"
                  )
                },
                showWhen: local!altaExpandida,
                padding: "STANDARD",
                marginAbove: "NONE",
                marginBelow: "NONE",
                showBorder: false
              ),
              a!horizontalLine(marginBelow: "NONE")
            },
            a!forEach(
              items: local!acciones,
              expression: a!localVariables(
                local!idxAccion: fv!index,
                local!itemAccion: fv!item,
                local!detalleSuplemento,
                local!abierta: a!defaultValue(local!tareaExpandida, 0) = fv!index,
                local!esCA: search(
                  "CONTRA",
                  upper(
                    a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
                  )
                ) > 0,
                local!esAA: search(
                  "ACC",
                  upper(
                    a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
                  )
                ) > 0,
                /* [S4] tarjeta Autorizacion alimentada por la gestión CORE accionRealizada 7 + consultarAutorizacion (como SCA_DetalleAnulacionAutorizacion) */
                local!esAut: and(
                  not(local!esCA),
                  not(local!esAA),
                  search(
                    cons!SCA2_TXT_ACCION_AUTORIZACION,
                    upper(
                      a!defaultValue(tostring(index(fv!item, "tipo", "")), "") & " " & a!defaultValue(
                        tostring(index(fv!item, "nombre", "")),
                        ""
                      )
                    )
                  ) > 0
                ),
                /* [S2] tarjeta Mecanizacion alimentada por la gestión CORE accionRealizada 5 + consultaDetalleGestion (como SCA_DetalleAnulacionMecanizacionEstrategicas) */
                local!esMec: and(
                  not(local!esCA),
                  not(local!esAA),
                  not(local!esAut),
                  search(
                    "MECANIZA",
                    upper(
                      a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
                    )
                  ) > 0
                ),
                local!esImpr: upper(
                  a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
                ) = "IMPRESION",
                /* R29-A: tarjetas Gestión Verti/Vencimiento (VERTI) y componente Inducir Cliente (INDUCCION) */
                local!esVertiCard: upper(
                  a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
                ) = cons!SCA2_TXT_CONTACTO_VERTI,
                local!esIndCard: upper(
                  a!defaultValue(tostring(index(fv!item, "tipo", "")), "")
                ) = "INDUCCION",
                /* opción marcada: tokenTarea de la tarea VERTI (CMD CrearAccion 34, VERTI:<sel>) o, si no, el de la tarea MECANIZAR (CMD CrearAccion 9) */
                local!opcionVertiTxt: if(
                  not(or(local!esVertiCard, local!esIndCard)),
                  "-",
                  a!localVariables(
                    local!tokPropio: upper(
                      a!defaultValue(
                        tostring(index(local!itemAccion, "token", null)),
                        ""
                      )
                    ),
                    local!tokMec: index(
                      reject(
                        fn!isnull,
                        a!forEach(
                          items: local!tareasMaps,
                          expression: if(
                            left(
                              upper(
                                a!defaultValue(
                                  tostring(index(fv!item, "token", null)),
                                  ""
                                )
                              ),
                              6
                            ) = "VERTI:",
                            upper(tostring(index(fv!item, "token", ""))),
                            null
                          )
                        )
                      ),
                      1,
                      ""
                    ),
                    local!tok: if(
                      left(local!tokPropio, 6) = "VERTI:",
                      local!tokPropio,
                      local!tokMec
                    ),
                    local!sel: if(
                      left(local!tok, 6) = "VERTI:",
                      mid(local!tok, 7, 100),
                      ""
                    ),
                    if(
                      local!sel = "",
                      if(
                        index(local!itemAccion, "estado", "") = "INCOMPLETA",
                        "Pendiente de seleccionar",
                        "-"
                      ),
                      if(
                        and(
                          search(cons!SCA2_TXT_CONTACTO_VERTI, local!sel) > 0,
                          search(cons!SCA2_TXT_ACCION_VENCIMIENTO, local!sel) > 0
                        ),
                        "Verti y Vencimiento",
                        if(
                          search(cons!SCA2_TXT_ACCION_VENCIMIENTO, local!sel) > 0,
                          "Vencimiento",
                          if(
                            search(cons!SCA2_TXT_CONTACTO_VERTI, local!sel) > 0,
                            "Verti",
                            "Ninguna"
                          )
                        )
                      )
                    )
                  )
                ),
                local!indTerminado: index(local!itemAccion, "estado", "") = cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                /* resultado registrado por el componente (CMP Traza inducir cliente, por póliza; sólo visible para el grupo CMP Global Verti) */
                local!trazaInd: if(
                  and(
                    local!abierta,
                    local!esIndCard,
                    a!isNotNullOrEmpty(local!numPoliza),
                    a!isUserMemberOfGroup(
                      loggedInUser(),
                      cons!SCA2_GRP_CMP_GLOBAL_VERTI
                    )
                  ),
                  index(
                    index(
                      a!queryRecordType(
                        recordType: 'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente',
                        fields: {
                          'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{ec503ab3-6965-4599-a2e0-6792a4d4e55b}id',
                          'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{c681591b-5308-4f2d-8abd-6111f6f4145c}estado',
                          'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{9514bef9-9266-433c-a7b7-0bf791f9db61}servicio',
                          'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{1ade182a-c65d-484d-92bf-cf5d49702fc3}error',
                          'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{2ae6aebf-a1bd-4c85-8143-74172ac0d50c}fechahora'
                        },
                        filters: a!queryFilter(
                          field: 'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{67f5a5fa-e01a-4af9-a985-a86c5bc57c85}poliza',
                          operator: "=",
                          value: tostring(local!numPoliza)
                        ),
                        pagingInfo: a!pagingInfo(
                          startIndex: 1,
                          batchSize: 1,
                          sort: a!sortInfo(
                            field: 'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{ec503ab3-6965-4599-a2e0-6792a4d4e55b}id',
                            ascending: false
                          )
                        ),
                        fetchTotalCount: false
                      ),
                      "data",
                      {}
                    ),
                    1,
                    null
                  ),
                  null
                ),
                local!trazaEstado: upper(
                  a!defaultValue(
                    tostring(
                      index(
                        local!trazaInd,
                        'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{c681591b-5308-4f2d-8abd-6111f6f4145c}estado',
                        null
                      )
                    ),
                    ""
                  )
                ),
                local!trazaError: a!defaultValue(
                  tostring(
                    index(
                      local!trazaInd,
                      'recordType!{de0ac63d-30f6-4a2f-9424-f449b901dab2}CMP Traza inducir cliente.fields.{1ade182a-c65d-484d-92bf-cf5d49702fc3}error',
                      null
                    )
                  ),
                  ""
                ),
                local!resultadoIndTxt: if(
                  local!trazaEstado = "KO",
                  if(
                    local!indTerminado,
                    "Terminado con error",
                    "Con error (el componente sigue abierto)"
                  ),
                  if(
                    local!trazaEstado = "OK",
                    "Completado sin incidencias",
                    if(
                      local!indTerminado,
                      "Completado sin incidencias",
                      "En curso"
                    )
                  )
                ),
                /* accionRealizada CORE de la gestión asociada a la tarea: 2 = contra anulación, 3 = acciones administrativas */
                local!codCore: if(
                  local!esCA,
                  "2",
                  if(
                    local!esAA,
                    "3",
                    if(
                      local!esAut,
                      "7",
                      if(local!esMec, "5", null)
                    )
                  )
                ),
                local!gestionesTipo: if(
                  a!isNullOrEmpty(local!codCore),
                  {},
                  reject(
                    fn!isnull,
                    a!forEach(
                      items: local!gestionesCore,
                      expression: if(
                        tostring(index(fv!item, "accionRealizada", "")) = local!codCore,
                        index(fv!item, "numGestion", null),
                        null
                      )
                    )
                  )
                ),
                local!ordinalCA: if(
                  a!isNotNullOrEmpty(local!codCore),
                  length(
                    reject(
                      fn!isnull,
                      a!forEach(
                        items: local!acciones,
                        expression: if(
                          and(
                            fv!index <= local!idxAccion,
                            search(
                              if(
                                local!esCA,
                                "CONTRA",
                                if(
                                  local!esAA,
                                  "ACC",
                                  if(local!esMec, "MECANIZA", cons!SCA2_TXT_ACCION_AUTORIZACION)
                                )
                              ),
                              upper(
                                a!defaultValue(tostring(index(fv!item, "tipo", "")), "") & if(
                                  local!esAut,
                                  " " & a!defaultValue(
                                    tostring(index(fv!item, "nombre", "")),
                                    ""
                                  ),
                                  ""
                                )
                              )
                            ) > 0
                          ),
                          1,
                          null
                        )
                      )
                    )
                  ),
                  0
                ),
                /* Nº total de tareas locales de este tipo: si CORE tiene más gestiones de este tipo que tareas (p.ej. gestión CA reabierta/rehecha),
                   se alinean por el final para que la tarjeta muestre la gestión CORE más reciente (como SCA, que pinta la gestión CORE) y no una INCOMPLETA antigua */
                local!totalTareasTipo: if(
                  a!isNotNullOrEmpty(local!codCore),
                  length(
                    reject(
                      fn!isnull,
                      a!forEach(
                        items: local!acciones,
                        expression: if(
                          search(
                            if(
                              local!esCA,
                              "CONTRA",
                              if(
                                local!esAA,
                                "ACC",
                                if(local!esMec, "MECANIZA", cons!SCA2_TXT_ACCION_AUTORIZACION)
                              )
                            ),
                            upper(
                              a!defaultValue(tostring(index(fv!item, "tipo", "")), "") & if(
                                local!esAut,
                                " " & a!defaultValue(
                                  tostring(index(fv!item, "nombre", "")),
                                  ""
                                ),
                                ""
                              )
                            )
                          ) > 0,
                          1,
                          null
                        )
                      )
                    )
                  ),
                  0
                ),
                local!ordinalGestion: local!ordinalCA + max(
                  0,
                  length(local!gestionesTipo) - local!totalTareasTipo
                ),
                local!numGestionCA: if(
                  or(
                    a!isNullOrEmpty(local!codCore),
                    a!isNullOrEmpty(local!gestionesTipo)
                  ),
                  null,
                  index(
                    local!gestionesTipo,
                    local!ordinalGestion,
                    index(
                      local!gestionesTipo,
                      length(local!gestionesTipo),
                      null
                    )
                  )
                ),
                /* Paridad SCA_DetalleAnulacionContraAnulacion: argumentos y observaciones de la gestión CA salen del detalle de gestión de CORE */
                local!detalleCA: if(
                  and(
                    local!abierta,
                    local!esCA,
                    a!isNotNullOrEmpty(local!numGestionCA)
                  ),
                  index(
                    rule!SCA2_consultaDetalleGestion(
                      gestion: tostring(local!numGestionCA),
                      solicitud: ri!idSolicitud
                    ),
                    "MSSConsultaDetalleGestion",
                    null
                  ),
                  null
                ),
                local!argsCA: a!defaultValue(
                  index(local!detalleCA, "listadoContraAnul", {}),
                  {}
                ),
                /* Observaciones: SCA usa las de la gestión (consultaGestion); el detalle de gestión sólo como respaldo, sin el prefijo "#&#usuario fecha Nivel n: " */
                local!obsDetalleCA: a!localVariables(
                  local!raw: trim(
                    substitute(
                      a!defaultValue(
                        tostring(
                          index(local!detalleCA, "observaciones", null)
                        ),
                        ""
                      ),
                      "#&#",
                      ""
                    )
                  ),
                  local!pNivel: find("Nivel ", local!raw),
                  local!pSep: if(
                    local!pNivel > 0,
                    find(": ", local!raw, local!pNivel),
                    0
                  ),
                  if(
                    len(local!raw) = 0,
                    null,
                    if(
                      local!pSep > 0,
                      trim(
                        right(local!raw, len(local!raw) - local!pSep - 1)
                      ),
                      local!raw
                    )
                  )
                ),
                local!gestionCA: if(
                  a!isNullOrEmpty(local!numGestionCA),
                  null,
                  index(
                    reject(
                      fn!isnull,
                      a!forEach(
                        items: local!gestionesCore,
                        expression: if(
                          tostring(index(fv!item, "numGestion", "")) = tostring(local!numGestionCA),
                          fv!item,
                          null
                        )
                      )
                    ),
                    1,
                    null
                  )
                ),
                local!estadoAut: if(
                  or(
                    not(local!esAut),
                    a!isNullOrEmpty(local!gestionCA)
                  ),
                  null,
                  a!localVariables(
                    /* Sin codEstado en CORE (p. ej. rechazo recibido de NSE) la tarjeta toma el codEstGestion de la gestión 7, como SCA_DetalleAnulacionAutorizacion no asume "Pendiente" */
                    local!codEstadoAut: index(
                      index(
                        rule!SCA2_consultarAutorizacion(
                          mseConsultarAutorizacionesDTO: {
                            codSolicitud: ri!idSolicitud,
                            codGestion: tostring(local!numGestionCA)
                          }
                        ),
                        "MSSConsultarAutorizacion",
                        null
                      ),
                      "codEstado",
                      null
                    ),
                    if(
                      a!isNullOrEmpty(local!codEstadoAut),
                      null,
                      index(
                        cons!SCA2_TXT_ESTADOS_AUTORIZACION,
                        tointeger(local!codEstadoAut),
                        null
                      )
                    )
                  )
                ),
                local!detalleAut: if(
                  and(
                    local!abierta,
                    local!esAut,
                    a!isNotNullOrEmpty(local!numGestionCA)
                  ),
                  index(
                    rule!SCA2_consultaDetalleGestion(
                      gestion: tostring(local!numGestionCA),
                      solicitud: ri!idSolicitud
                    ),
                    "MSSConsultaDetalleGestion",
                    null
                  ),
                  null
                ),
                local!estadoCard: if(
                  a!isNotNullOrEmpty(local!estadoAut),
                  upper(local!estadoAut),
                  upper(
                    tostring(
                      a!defaultValue(
                        index(local!gestionCA, "codEstGestion", null),
                        index(local!itemAccion, "estado", "INCOMPLETA")
                      )
                    )
                  )
                ),
                local!fecInicioCard: a!defaultValue(
                  index(
                    local!gestionCA,
                    "fecInicioGestion",
                    null
                  ),
                  index(local!itemAccion, "fecInicio", "-")
                ),
                /* Paridad SCA_DetalleAnulacion* (local!disabled): RETOMAR/REASIGNAR solo si la gestión de ESTA tarjeta sigue abierta; una gestión finalizada nunca hereda la tarea pendiente de otra */
                local!tareaBtn: if(
                  and(
                    or(
                      local!estadoCard = "INCOMPLETA",
                      local!estadoCard = cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
                      local!estadoCard = "ANULACION PENDIENTE DE AUTORIZAR"
                    ),
                    index(local!itemAccion, "estado", cons!SCA2_TXT_ESTADO_SOL_FINALIZADA) = "INCOMPLETA",
                    a!isNotNullOrEmpty(index(local!itemAccion, "idTarea", null))
                  ),
                  local!itemAccion,
                  null
                ),
                local!fecFinCard: if(
                  a!isNotNullOrEmpty(local!gestionCA),
                  a!defaultValue(
                    index(local!gestionCA, "fecFinGestion", null),
                    "-"
                  ),
                  index(local!itemAccion, "fecFin", "-")
                ),
                local!nivelRaw: if(
                  a!isNotNullOrEmpty(local!gestionCA),
                  a!defaultValue(
                    index(
                      local!gestionCA,
                      "nivelIntervencion",
                      null
                    ),
                    "-"
                  ),
                  index(local!itemAccion, "nivel", "-")
                ),
                /* R46-A (analista 10/11): «Nivel X» también en el nivel 1 */
                local!nivelCard: a!localVariables(
                  local!n: cleanwith(tostring(local!nivelRaw), "0123456789"),
                  if(local!n = "", "-", "Nivel " & local!n)
                ),
                local!perfilCard: if(
                  a!isNotNullOrEmpty(local!gestionCA),
                  a!defaultValue(
                    index(
                      index(local!gestionCA, "infoUsuario", null),
                      "codPerfil",
                      null
                    ),
                    "-"
                  ),
                  index(local!itemAccion, "perfil", "-")
                ),
                local!grupoCard: if(
                  a!isNotNullOrEmpty(local!gestionCA),
                  a!defaultValue(
                    index(
                      index(local!gestionCA, "infoUsuario", null),
                      "codSubPerfil",
                      null
                    ),
                    "-"
                  ),
                  index(local!itemAccion, "grupo", "-")
                ),
                /* R20 #2: si CORE no tiene nuuma (gestión de nivel > 1 sin retomar) se muestra el usuario que retomó la tarea (SCA2 Tarea.asignadoA/fechaCaptura) o «-» */
                local!idTareaCard: a!defaultValue(
                  index(local!itemAccion, "idTarea", null),
                  index(local!tareaBtn, "idTarea", null)
                ),
                local!tareaRetomada: if(
                  a!isNullOrEmpty(local!idTareaCard),
                  null,
                  index(
                    index(
                      a!queryRecordType(
                        recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                        fields: {
                          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{fbf2e73f-38cb-4db5-abf6-50d8b7392118}fechaCaptura'
                        },
                        filters: a!queryFilter(
                          field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                          operator: "=",
                          value: tointeger(local!idTareaCard)
                        ),
                        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                        fetchTotalCount: false
                      ),
                      "data",
                      {}
                    ),
                    1,
                    null
                  )
                ),
                local!nuumaRetomada: if(
                  or(
                    a!isNullOrEmpty(local!tareaRetomada),
                    a!isNullOrEmpty(
                      index(
                        local!tareaRetomada,
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{fbf2e73f-38cb-4db5-abf6-50d8b7392118}fechaCaptura',
                        null
                      )
                    )
                  ),
                  "-",
                  a!localVariables(
                    local!u: tostring(
                      index(
                        local!tareaRetomada,
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                        ""
                      )
                    ),
                    if(
                      a!isNullOrEmpty(local!u),
                      "-",
                      upper(
                        if(
                          find("@", local!u) > 0,
                          left(local!u, find("@", local!u) - 1),
                          local!u
                        )
                      )
                    )
                  )
                ),
                local!nuumaCard: if(
                  a!isNotNullOrEmpty(local!gestionCA),
                  /* R20 #2 / R23: en nivel > 1 CORE guarda el nuuma del gestor del nivel anterior; se muestra quién ha retomado la tarea (o «-») */
                  if(
                    tointeger(
                      a!defaultValue(
                        index(local!itemAccion, "nivel", null),
                        index(local!est, "nivelIntervencion", 1)
                      )
                    ) > 1,
                    local!nuumaRetomada,
                    a!defaultValue(
                      index(
                        index(local!gestionCA, "infoUsuario", null),
                        "nuuma",
                        null
                      ),
                      local!nuumaRetomada
                    )
                  ),
                  index(local!itemAccion, "nuuma", "-")
                ),
                local!detalleMec: if(
                  and(
                    local!abierta,
                    local!esMec,
                    a!isNotNullOrEmpty(local!numGestionCA)
                  ),
                  index(
                    rule!SCA2_consultaDetalleGestion(
                      gestion: tostring(local!numGestionCA),
                      solicitud: ri!idSolicitud
                    ),
                    "MSSConsultaDetalleGestion",
                    null
                  ),
                  null
                ),
                /* [S2] Mecanizacion como SCA_DetalleAnulacionMecanizacionEstrategicas: cabecera CORE + observaciones BBDD SCA ordenadas por fecha */
                local!cabeceraMec: if(
                  and(local!abierta, local!esMec),
                  index(
                    rule!SCA2_consultarCabeceraSolicitud(codSolicitud: ri!idSolicitud),
                    "MSSConsultarCabecera",
                    ""
                  ),
                  ""
                ),
                local!catalogacionMec: tostring(
                  a!defaultValue(
                    index(local!cabeceraMec, "catalogacion", null),
                    ""
                  )
                ),
                local!esWAutemisMec: a!defaultValue(local!origenPol, "") = "wAutemis",
                local!resulMec: tostring(
                  a!defaultValue(
                    index(
                      local!detalleMec,
                      "resulMecanizacion",
                      null
                    ),
                    ""
                  )
                ),
                local!obsMec: a!defaultValue(
                  tostring(
                    index(local!detalleMec, "observaciones", null)
                  ),
                  ""
                ),
                local!hitosMec: if(
                  local!esWAutemisMec,
                  if(
                    or(
                      find("observaciones: 00000005", local!obsMec) <> 0,
                      find("observaciones: 00000006", local!obsMec) <> 0
                    ),
                    { "Mecaniza", "SGO", "STCAT", "Anulación" },
                    if(
                      or(
                        find(
                          "nvlCumplimiento: 00000005",
                          local!obsMec
                        ) <> 0,
                        find(
                          "nvlCumplimiento: 00000006",
                          local!obsMec
                        ) <> 0
                      ),
                      { "Mecaniza", "STCAT", "Anulación" },
                      { "Mecaniza", "Anulación" }
                    )
                  ),
                  if(
                    or(
                      find(
                        "txtObservaciones: 00000005",
                        local!obsMec
                      ) <> 0,
                      find(
                        "txtObservaciones: 00000006",
                        local!obsMec
                      ) <> 0
                    ),
                    { "Mecaniza", "Suscripción", "Anulación" },
                    { "Mecaniza", "Anulación" }
                  )
                ),
                local!obsBBDDMec: a!refreshVariable(
                  value: if(
                    and(
                      local!abierta,
                      local!esMec,
                      a!isNotNullOrEmpty(local!numGestionCA)
                    ),
                    index(
                      rule!SCA2_consultaBBDDSCA(
                        idSolicitud: ri!idSolicitud,
                        devolverSolicitud: false,
                        devolverObservaciones: true,
                        devolverGestiones: false,
                        devolverMecanizacion: false,
                        devolverAcciones: false,
                        devolverAutorizaciones: false,
                        devolverNotificaciones: false,
                        devolverSGO: false,
                        devolverCTO: false
                      ),
                      "observaciones",
                      null
                    ),
                    null
                  ),
                  refreshOnVarChange: ri!tipoAccion
                ),
                local!obsMecGestion: reject(
                  fn!isnull,
                  a!forEach(
                    items: local!obsBBDDMec,
                    expression: if(
                      tostring(index(fv!item, "numGestionPca", "")) = tostring(local!numGestionCA),
                      fv!item,
                      null
                    )
                  )
                ),
                local!obsMecOrdenadas: if(
                  a!isNullOrEmpty(local!obsMecGestion),
                  null,
                  index(
                    todatasubset(
                      arrayToPage: local!obsMecGestion,
                      pagingConfiguration: a!pagingInfo(
                        startIndex: 1,
                        batchSize: - 1,
                        sort: a!sortInfo(field: "fecObsPca", ascending: true)
                      )
                    ),
                    "data",
                    null
                  )
                ),
                local!hayObsMec: a!isNotNullOrEmpty(local!obsMecOrdenadas),
                local!txtObsMec: if(
                  local!hayObsMec,
                  a!forEach(
                    items: local!obsMecOrdenadas,
                    expression: tostring(index(fv!item, "txtObsPca", ""))
                  ),
                  {}
                ),
                local!fecObsMec: if(
                  local!hayObsMec,
                  a!forEach(
                    items: local!obsMecOrdenadas,
                    expression: tostring(index(fv!item, "fecObsPca", ""))
                  ),
                  {}
                ),
                local!indexMecaMec: if(
                  local!hayObsMec,
                  index(
                    wherecontains(
                      1,
                      find(
                        "Inicia Subproceso Appian",
                        local!txtObsMec
                      )
                    ),
                    1,
                    null
                  ),
                  null
                ),
                local!indexSGOMec: if(
                  local!hayObsMec,
                  index(
                    wherecontains(
                      1,
                      find("RESPUESTA ALTA SGO:", local!txtObsMec)
                    ),
                    1,
                    null
                  ),
                  null
                ),
                local!indexSTCATMec: if(
                  local!hayObsMec,
                  index(
                    wherecontains(
                      1,
                      find(
                        "RESPUESTA CARGA STCAT:",
                        local!txtObsMec
                      )
                    ),
                    1,
                    null
                  ),
                  null
                ),
                local!indexSuscMec: if(
                  local!hayObsMec,
                  index(
                    wherecontains(
                      1,
                      find(
                        "RESPUESTA SUSCRIPCION NSE:",
                        local!txtObsMec
                      )
                    ),
                    1,
                    null
                  ),
                  null
                ),
                local!mecanizaOk: or(
                  if(
                    local!hayObsMec,
                    or(
                      or(
                        find(
                          "Inicia Subproceso Appian",
                          local!txtObsMec
                        ) <> 0
                      ),
                      or(
                        find(
                          "INICIA SUBPROCESO ANULACION",
                          local!txtObsMec
                        ) <> 0
                      )
                    ),
                    false
                  ),
                  a!isNotNullOrEmpty(local!numGestionCA)
                ),
                local!sgoOk: if(
                  local!hayObsMec,
                  or(
                    find("RESPUESTA ALTA SGO", local!txtObsMec) <> 0
                  ),
                  false
                ),
                local!stcatOk: if(
                  local!hayObsMec,
                  or(
                    find(
                      "RESPUESTA CARGA STCAT",
                      local!txtObsMec
                    ) <> 0
                  ),
                  false
                ),
                local!suscripcionOk: if(
                  local!hayObsMec,
                  or(
                    find(
                      "RESPUESTA SUSCRIPCION NSE",
                      local!txtObsMec
                    ) <> 0
                  ),
                  false
                ),
                local!anulacionOk: if(
                  local!hayObsMec,
                  if(
                    local!esWAutemisMec,
                    or(find("ANULAR NEW", local!txtObsMec) <> 0),
                    or(
                      or(
                        find(
                          "RESPUESTA ANULACION NSE",
                          local!txtObsMec
                        ) <> 0
                      ),
                      local!resulMec = "1"
                    )
                  ),
                  false
                ),
                local!pasosOkMec: if(
                  local!esWAutemisMec,
                  if(
                    contains({ "1", "4" }, local!catalogacionMec),
                    {
                      local!mecanizaOk,
                      local!sgoOk,
                      local!stcatOk,
                      local!anulacionOk
                    },
                    { local!mecanizaOk, local!anulacionOk }
                  ),
                  if(
                    contains({ "1", "4" }, local!catalogacionMec),
                    {
                      local!mecanizaOk,
                      local!suscripcionOk,
                      local!anulacionOk
                    },
                    { local!mecanizaOk, local!anulacionOk }
                  )
                ),
                local!pasosCompletadosMec: tointeger(
                  count(wherecontains(true, local!pasosOkMec))
                ),
                local!fecTxtMec: if(
                  a!isNullOrEmpty(local!indexMecaMec),
                  left(
                    a!defaultValue(
                      tostring(
                        index(
                          local!gestionCA,
                          "fecInicioGestion",
                          null
                        )
                      ),
                      ""
                    ),
                    10
                  ),
                  text(
                    rule!SCA2_convertirAFecha(
                      index(local!fecObsMec, local!indexMecaMec, "")
                    ),
                    "dd/MM/yyyy"
                  )
                ),
                local!fecTxtSGO: if(
                  a!isNullOrEmpty(local!indexSGOMec),
                  "",
                  text(
                    rule!SCA2_convertirAFecha(
                      index(local!fecObsMec, local!indexSGOMec, "")
                    ),
                    "dd/MM/yyyy"
                  )
                ),
                local!fecTxtSTCAT: if(
                  a!isNullOrEmpty(local!indexSTCATMec),
                  "",
                  text(
                    rule!SCA2_convertirAFecha(
                      index(local!fecObsMec, local!indexSTCATMec, "")
                    ),
                    "dd/MM/yyyy"
                  )
                ),
                local!fecTxtSusc: if(
                  a!isNullOrEmpty(local!indexSuscMec),
                  "",
                  text(
                    rule!SCA2_convertirAFecha(
                      index(local!fecObsMec, local!indexSuscMec, "")
                    ),
                    "dd/MM/yyyy"
                  )
                ),
                local!fecAnulTxtMec: tostring(
                  a!defaultValue(
                    index(local!cabeceraMec, "fecAnulacion", null),
                    ""
                  )
                ),
                local!fecAnulacionMec: if(
                  and(
                    len(local!fecAnulTxtMec) >= 10,
                    mid(local!fecAnulTxtMec, 3, 1) = "/",
                    mid(local!fecAnulTxtMec, 6, 1) = "/"
                  ),
                  date(
                    tointeger(mid(local!fecAnulTxtMec, 7, 4)),
                    tointeger(mid(local!fecAnulTxtMec, 4, 2)),
                    tointeger(mid(local!fecAnulTxtMec, 1, 2))
                  ),
                  if(
                    and(
                      len(local!fecAnulTxtMec) >= 10,
                      mid(local!fecAnulTxtMec, 5, 1) = "-",
                      mid(local!fecAnulTxtMec, 8, 1) = "-"
                    ),
                    date(
                      tointeger(mid(local!fecAnulTxtMec, 1, 4)),
                      tointeger(mid(local!fecAnulTxtMec, 6, 2)),
                      tointeger(mid(local!fecAnulTxtMec, 9, 2))
                    ),
                    null
                  )
                ),
                local!fecTxtAnul: if(
                  a!isNullOrEmpty(local!fecAnulacionMec),
                  "",
                  text(local!fecAnulacionMec, "dd/MM/yyyy")
                ),
                local!fecHitosMec: if(
                  local!esWAutemisMec,
                  if(
                    contains({ "1", "4" }, local!catalogacionMec),
                    {
                      local!fecTxtMec,
                      local!fecTxtSGO,
                      local!fecTxtSTCAT,
                      local!fecTxtAnul
                    },
                    { local!fecTxtMec, local!fecTxtAnul }
                  ),
                  if(
                    contains({ "1", "4" }, local!catalogacionMec),
                    {
                      local!fecTxtMec,
                      local!fecTxtSusc,
                      local!fecTxtAnul
                    },
                    { local!fecTxtMec, local!fecTxtAnul }
                  )
                ),
                local!trazarAnulacion: false,
                local!docsCA: if(
                  and(
                    local!abierta,
                    or(local!esCA, local!esAA, local!esAut)
                  ),
                  a!defaultValue(
                    index(
                      index(
                        rule!SCA2_consultarDocumentos(codSolicitud: tointeger(ri!idSolicitud)),
                        "MSSConsultarDocumentos",
                        null
                      ),
                      "listaDocumentos",
                      {}
                    ),
                    {}
                  ),
                  {}
                ),
                local!docVis: null,
                local!verDoc: false,
                {
                  a!cardLayout(
                    contents: a!sideBySideLayout(
                      items: {
                        a!sideBySideItem(
                          item: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {
                              a!richTextIcon(
                                icon: if(
                                  local!abierta,
                                  "chevron-up",
                                  "chevron-down"
                                ),
                                color: cons!SCA2_VAL_COLOR_NEGRO
                              ),
                              char(32),
                              a!richTextItem(
                                text: if(
                                  local!esCA,
                                  "Contra Anulacion",
                                  if(
                                    local!esMec,
                                    "Mecanizacion",
                                    proper(
                                      index(local!itemAccion, "nombre", "Acción")
                                    )
                                  )
                                ),
                                linkStyle: "STANDALONE",
                                color: cons!SCA2_VAL_COLOR_NEGRO,
                                size: "STANDARD",
                                style: "STRONG"
                              )
                            },
                            marginAbove: "NONE",
                            marginBelow: "NONE"
                          )
                        ),
                        a!sideBySideItem(
                          item: a!tagField(
                            tags: a!tagItem_24r2(
                              text: proper(local!estadoCard),
                              backgroundColor: a!match(
                                value: local!estadoCard,
                                /* [S4] Autorización: ACEPTADA verde como SCA_D_ColorEstadoGestion */
                                equals: "ACEPTADA",
                                then: cons!SCA2_VAL_COLOR_VERDE_OSCURO,
                                /* SCA_D_ColorEstadoGestion(IMPRESION, FINALIZADA) = rojo */
                                equals: cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                                then: if(
                                  local!esImpr,
                                  cons!SCA2_VAL_COLOR_ROJO,
                                  cons!SCA2_VAL_COLOR_VERDE_OSCURO
                                ),
                                equals: "FINALIZADA POSITIVA",
                                then: cons!SCA2_VAL_COLOR_VERDE_OSCURO,
                                /* SCA_D_ColorEstadoGestion(FINALIZADA NEGATIVA) */
                                equals: "FINALIZADA NEGATIVA",
                                then: cons!SCA2_VAL_COLOR_ROJO_OSCURO,
                                equals: "FINALIZADA CANCELADA",
                                then: cons!SCA2_VAL_COLOR_AZUL,
                                equals: "CANCELADA",
                                then: cons!SCA2_VAL_COLOR_GRIS_MEDIO,
                                /* SCA_D_ColorEstadoGestion(MECANIZACION, ...) */
                                equals: "ANULACION REALIZADA",
                                then: cons!SCA2_VAL_COLOR_VERDE_OSCURO,
                                equals: "CERRADA SIN MECANIZAR",
                                then: cons!SCA2_VAL_COLOR_ROJO_OSCURO,
                                equals: cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                                then: "#734B30",
                                equals: "FINALIZADA CADUCADA",
                                then: "#734B30",
                                /* SCA_D_ColorEstadoGestion(AUTORIZACION, RECHAZADA) */
                                equals: "RECHAZADA",
                                then: cons!SCA2_VAL_COLOR_ROJO_OSCURO,
                                equals: "AUTORIZACION RECHAZADA",
                                then: cons!SCA2_VAL_COLOR_ROJO_OSCURO,
                                default: cons!SCA2_VAL_COLOR_NARANJA_OSCURO
                              )
                            )
                          ),
                          width: "MINIMIZE"
                        )
                      },
                      alignVertical: "MIDDLE",
                      marginAbove: "NONE",
                      marginBelow: "NONE"
                    ),
                    link: a!dynamicLink(
                      saveInto: a!save(
                        local!tareaExpandida,
                        if(local!abierta, null, fv!index)
                      )
                    ),
                    padding: "STANDARD",
                    marginAbove: "NONE",
                    marginBelow: "NONE",
                    showBorder: false
                  ),
                  a!cardLayout(
                    /* R24 #11: detalle de la gestión de impresión: cuándo y quién imprimió la carta */
                    contents: a!columnsLayout(
                      columns: {
                        a!columnLayout(
                          contents: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {
                              a!richTextItem(
                                text: "Fecha de impresión" & char(10),
                                color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                              ),
                              a!richTextItem(
                                text: a!defaultValue(index(fv!item, "fecInicio", null), "-"),
                                style: "STRONG"
                              )
                            }
                          )
                        ),
                        a!columnLayout(
                          contents: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {
                              a!richTextItem(
                                text: "Impresa por" & char(10),
                                color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                              ),
                              a!richTextItem(
                                text: a!defaultValue(index(fv!item, "nuuma", null), "-"),
                                style: "STRONG"
                              )
                            }
                          )
                        ),
                        a!columnLayout(
                          contents: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {
                              a!richTextItem(
                                text: "Grupo" & char(10),
                                color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                              ),
                              a!richTextItem(
                                text: a!defaultValue(index(fv!item, "grupo", null), "-"),
                                style: "STRONG"
                              )
                            }
                          )
                        ),
                        a!columnLayout(contents: {})
                      }
                    ),
                    showWhen: and(local!abierta, local!esImpr),
                    padding: "STANDARD",
                    showBorder: false,
                    marginAbove: "NONE",
                    marginBelow: "NONE"
                  ),
                  a!cardLayout(
                    contents: {
                      a!cardLayout(
                        showBorder: local!esMec,
                        padding: if(local!esMec, "STANDARD", "NONE"),
                        contents: {
                          a!columnsLayout(
                            columns: {
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Fecha inicio de gestión" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: local!fecInicioCard,
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Fecha fin de gestión" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(text: local!fecFinCard, style: "STRONG")
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Nivel intervención" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(text: local!nivelCard, style: "STRONG")
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Perfil de usuario" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(text: local!perfilCard, style: "STRONG")
                                  }
                                )
                              )
                            }
                          ),
                          a!columnsLayout(
                            columns: {
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Grupo" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(text: local!grupoCard, style: "STRONG")
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Nuuma de usuario" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(text: local!nuumaCard, style: "STRONG")
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: if(
                                  and(
                                    local!esVida,
                                    index(fv!item, "tipo", "") = cons!SCA2_TXT_CONTACTO_VERTI
                                  ),
                                  a!richTextDisplayField(
                                    labelPosition: "COLLAPSED",
                                    value: a!richTextItem(
                                      text: "GESVIDA",
                                      linkStyle: "BUTTON",
                                      style: "STRONG",
                                      link: a!safeLink(
                                        uri: substitute(
                                          cons!SCA2_TXT_LINK_GESVIDA,
                                          "*poliza*",
                                          a!defaultValue(local!numPoliza, "")
                                        ),
                                        openLinkIn: "NEW_TAB"
                                      )
                                    )
                                  ),
                                  {}
                                )
                              ),
                              a!columnLayout()
                            }
                          ),
                          /* R29-A (analista 23/10): opción marcada en Verti/Vencimiento y estado/resultado del componente */
                          a!columnsLayout(
                            showWhen: or(local!esVertiCard, local!esIndCard),
                            columns: {
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: if(
                                        local!esIndCard,
                                        "Opción enviada al componente",
                                        "Opción seleccionada"
                                      ) & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: local!opcionVertiTxt,
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              /* R46-A (analista 10/11): opción ejecutada en el componente; CMP Traza inducir cliente no la registra (pendiente de CMP) */
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  showWhen: local!esIndCard,
                                  value: {
                                    a!richTextItem(
                                      text: "Opción seleccionada en componente" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(text: "-", style: "STRONG")
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  showWhen: local!esIndCard,
                                  value: {
                                    a!richTextItem(
                                      text: "Estado del componente" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: if(
                                        local!indTerminado,
                                        "Terminado",
                                        "En curso"
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  showWhen: local!esIndCard,
                                  value: {
                                    a!richTextItem(
                                      text: "Resultado del componente" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: local!resultadoIndTxt,
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  showWhen: local!esIndCard,
                                  value: {
                                    a!richTextItem(
                                      text: "Instancia del componente" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(
                                        tostring(index(local!itemAccion, "proceso", null)),
                                        "-"
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              )
                            }
                          ),
                          a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            showWhen: and(local!esIndCard, local!trazaError <> ""),
                            value: {
                              a!richTextItem(
                                text: "Detalle del resultado" & char(10),
                                color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                              ),
                              a!richTextItem(text: local!trazaError, style: "STRONG")
                            }
                          ),
                          a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: a!richTextItem(
                              text: "Datos de la gestión" & char(10),
                              size: "MEDIUM",
                              style: "STRONG"
                            ),
                            marginBelow: "MORE",
                            showWhen: local!esMec
                          ),
                          a!horizontalLine(showWhen: local!esMec),
                          a!columnsLayout(
                            showWhen: local!esMec,
                            columns: {
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Sistema Anulación" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(local!origenPol, "-"),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Centro emisor" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(
                                        index(local!detalleMec, "centroEmisor", null),
                                        "-"
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Resultado de la mecanización" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: if(
                                        a!isNullOrEmpty(local!resulMec),
                                        "-",
                                        index(
                                          cons!SCA2_TXT_ESTADOS_MECANIZACION,
                                          tointeger(local!resulMec),
                                          "-"
                                        )
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Núm. Situación Autemis" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(
                                        index(local!detalleMec, "numSituacion", null),
                                        "-"
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              )
                            }
                          ),
                          /* Bolitas de progreso de la mecanización (como SCA) */
                          a!columnsLayout(
                            showWhen: and(
                              local!esMec,
                              or(
                                local!hayObsMec,
                                a!isNotNullOrEmpty(local!numGestionCA)
                              )
                            ),
                            alignVertical: "TOP",
                            columns: a!forEach(
                              items: local!hitosMec,
                              expression: {
                                a!columnLayout(
                                  width: "AUTO",
                                  contents: {
                                    if(
                                      fv!index <= local!pasosCompletadosMec,
                                      if(
                                        and(
                                          fv!isLast,
                                          local!catalogacionMec <> "1",
                                          a!isNotNullOrEmpty(local!fecAnulacionMec),
                                          today() < todate(local!fecAnulacionMec)
                                        ),
                                        a!stampField(
                                          icon: "clock-o",
                                          backgroundColor: "#ffb005",
                                          contentColor: cons!SCA2_VAL_COLOR_BLANCO,
                                          size: "TINY",
                                          align: "CENTER"
                                        ),
                                        a!stampField(
                                          icon: "check-circle-o",
                                          backgroundColor: "POSITIVE",
                                          size: "TINY",
                                          align: "CENTER"
                                        )
                                      ),
                                      if(
                                        fv!index = local!pasosCompletadosMec + 1,
                                        a!stampField(
                                          icon: "clock-o",
                                          backgroundColor: "ACCENT",
                                          size: "TINY",
                                          align: "CENTER"
                                        ),
                                        a!stampField(
                                          icon: "clipboard-o",
                                          backgroundColor: "#d4d4d4",
                                          contentColor: "STANDARD",
                                          size: "TINY",
                                          align: "CENTER"
                                        )
                                      )
                                    ),
                                    a!richTextDisplayField(
                                      labelPosition: "COLLAPSED",
                                      value: a!richTextItem(
                                        text: fv!item,
                                        size: "STANDARD",
                                        style: if(
                                          fv!index <= local!pasosCompletadosMec,
                                          "STRONG",
                                          null
                                        )
                                      ),
                                      align: "CENTER",
                                      marginAbove: "NONE",
                                      marginBelow: "NONE"
                                    ),
                                    a!richTextDisplayField(
                                      labelPosition: "COLLAPSED",
                                      value: a!richTextItem(
                                        text: a!defaultValue(
                                          index(local!fecHitosMec, fv!index, ""),
                                          ""
                                        ),
                                        size: "SMALL"
                                      ),
                                      showWhen: and(
                                        fv!index <= local!pasosCompletadosMec + 1,
                                        a!isNotNullOrEmpty(index(local!fecHitosMec, fv!index, ""))
                                      ),
                                      preventWrapping: true,
                                      align: "CENTER",
                                      marginAbove: "NONE",
                                      marginBelow: "NONE"
                                    )
                                  }
                                ),
                                if(
                                  fv!isLast,
                                  {},
                                  a!columnLayout(
                                    width: "1X",
                                    contents: a!horizontalLine(
                                      weight: "MEDIUM",
                                      color: if(
                                        fv!index <= local!pasosCompletadosMec,
                                        "#93c47d",
                                        "#d4d4d4"
                                      ),
                                      marginAbove: "MORE",
                                      marginBelow: "NONE"
                                    )
                                  )
                                )
                              }
                            )
                          ),
                          a!buttonArrayLayout(
                            showWhen: local!esMec,
                            align: "START",
                            buttons: a!buttonWidget(
                              label: if(
                                local!trazarAnulacion,
                                "OCULTAR ANULACIÓN",
                                "TRAZAR ANULACIÓN"
                              ),
                              saveInto: a!save(
                                local!trazarAnulacion,
                                not(local!trazarAnulacion)
                              ),
                              color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                            )
                          ),
                          a!textField(
                            labelPosition: "COLLAPSED",
                            readOnly: true,
                            showWhen: and(local!esMec, local!trazarAnulacion),
                            value: joinarray(
                              a!forEach(
                                items: local!obsMecOrdenadas,
                                expression: {
                                  tostring(index(fv!item, "fecObsPca", "")),
                                  reject(
                                    fn!isnull,
                                    split(
                                      tostring(index(fv!item, "txtObsPca", "")),
                                      { "<p>", "</p>" }
                                    )
                                  ),
                                  char(10)
                                }
                              ),
                              char(10)
                            )
                          ),
                          /* R46-C (analista): enlace NSE de la suscripción como SCA_DetalleAnulacionAutorizacionEstrategicas, con tipo (n) y documento (o) del cliente */
                          a!localVariables(
                            local!obsAutNse: if(
                              and(local!esAut, local!abierta, a!defaultValue(local!origenPol, "") <> "wAutemis"),
                              index(
                                rule!SCA2_consultaBBDDSCA(
                                  idSolicitud: ri!idSolicitud,
                                  devolverSolicitud: false,
                                  devolverObservaciones: true,
                                  devolverGestiones: false,
                                  devolverMecanizacion: false,
                                  devolverAcciones: false,
                                  devolverAutorizaciones: false,
                                  devolverNotificaciones: false,
                                  devolverSGO: false,
                                  devolverCTO: false
                                ),
                                "observaciones",
                                null
                              ),
                              null
                            ),
                            local!txtObsAutNse: if(
                              a!isNullOrEmpty(local!obsAutNse),
                              {},
                              a!forEach(
                                items: local!obsAutNse,
                                expression: tostring(index(fv!item, "txtObsPca", ""))
                              )
                            ),
                            local!idxSuscripcionNse: if(
                              a!isNullOrEmpty(local!txtObsAutNse),
                              null,
                              index(
                                wherecontains(
                                  true,
                                  a!forEach(
                                    items: local!txtObsAutNse,
                                    expression: find("RESPUESTA SUSCRIPCION NSE:", fv!item) <> 0
                                  )
                                ),
                                1,
                                null
                              )
                            ),
                            local!idSuscripcionNse: if(
                              a!isNullOrEmpty(local!idxSuscripcionNse),
                              null,
                              trim(
                                index(
                                  split(
                                    index(local!txtObsAutNse, local!idxSuscripcionNse, ""),
                                    "Num Solicitud Anulacion: "
                                  ),
                                  2,
                                  null
                                )
                              )
                            ),
                            local!docClienteNse: upper(trim(a!defaultValue(index(local!datosCliente, "nif", ""), ""))),
                            local!tipoDocClienteNse: if(
                              regexmatch("^[XYZ][0-9]{7}[A-Z]$", local!docClienteNse),
                              "NIE",
                              regexmatch("^[0-9]{8}[A-Z]$", local!docClienteNse),
                              "NIF",
                              regexmatch("^[ABCDEFGHJNPQRSUVW][0-9]{7}[0-9A-J]$", local!docClienteNse),
                              "CIF",
                              "PAS"
                            ),
                            a!columnsLayout(
                              showWhen: and(local!esAut, a!isNotNullOrEmpty(local!idSuscripcionNse)),
                              columns: {
                                a!columnLayout(
                                  contents: a!richTextDisplayField(
                                    labelPosition: "COLLAPSED",
                                    value: {
                                      a!richTextItem(
                                        text: "Detalle de la suscripción" & char(10),
                                        color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                      ),
                                      a!richTextItem(
                                        text: "NSE",
                                        style: "STRONG",
                                        link: a!safeLink(
                                          uri: cons!SCA2_TXT_URL_NSE_GUIADO & "?h=41&t=12&x=35&g=42&m=N&i=S&r=2&s=1&u=73&k=" & local!idSuscripcionNse & if(
                                            a!isNullOrEmpty(local!docClienteNse),
                                            "",
                                            "&n=" & local!tipoDocClienteNse & "&o=" & local!docClienteNse
                                          ),
                                          openLinkIn: "NEW_TAB"
                                        )
                                      )
                                    }
                                  )
                                ),
                                a!columnLayout(),
                                a!columnLayout()
                              }
                            )
                          ),
                          a!columnsLayout(
                            showWhen: local!esAut,
                            columns: {
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Centro emisor" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(
                                        index(local!detalleAut, "centroEmisor", null),
                                        "-"
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Número situación Autemis" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(
                                        index(local!detalleAut, "numSituacion", null),
                                        "-"
                                      ),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(
                                contents: a!richTextDisplayField(
                                  labelPosition: "COLLAPSED",
                                  value: {
                                    a!richTextItem(
                                      text: "Resultado de la autorización" & char(10),
                                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                    ),
                                    a!richTextItem(
                                      text: a!defaultValue(upper(local!estadoAut), "-"),
                                      style: "STRONG"
                                    )
                                  }
                                )
                              ),
                              a!columnLayout(contents: {})
                            }
                          ),
                          a!gridField_25r2(
                            label: "Argumentos ejecutados",
                            labelPosition: "ABOVE",
                            data: local!argsCA,
                            emptyGridMessage: "No hay argumentos para esta gestión",
                            pageSize: 10,
                            borderStyle: "STANDARD",
                            shadeAlternateRows: true,
                            showWhen: local!esCA,
                            columns: {
                              a!gridColumn(
                                label: "Argumento",
                                value: index(fv!row, "descTipoArgumento", "")
                              ),
                              a!gridColumn(
                                label: "Finalizado",
                                align: "CENTER",
                                value: a!match(
                                  value: tostring(index(fv!row, "codTpEstArgumento", "")),
                                  equals: "2",
                                  then: a!tagField(
                                    labelPosition: "COLLAPSED",
                                    tags: a!tagItem_24r2(
                                      text: index(
                                        cons!SCA2_TXT_ESTADO_ARGUMENTO,
                                        3,
                                        "Negativo"
                                      ),
                                      backgroundColor: cons!SCA2_VAL_COLOR_ROJO,
                                      textColor: cons!SCA2_VAL_COLOR_BLANCO
                                    )
                                  ),
                                  equals: "1",
                                  then: a!tagField(
                                    labelPosition: "COLLAPSED",
                                    tags: a!tagItem_24r2(
                                      text: index(
                                        cons!SCA2_TXT_ESTADO_ARGUMENTO,
                                        2,
                                        "Positivo"
                                      ),
                                      backgroundColor: cons!SCA2_VAL_COLOR_VERDE,
                                      textColor: cons!SCA2_VAL_COLOR_BLANCO
                                    )
                                  ),
                                  default: a!tagField(
                                    labelPosition: "COLLAPSED",
                                    tags: a!tagItem_24r2(
                                      text: index(
                                        cons!SCA2_TXT_ESTADO_ARGUMENTO,
                                        1,
                                        "Pendiente"
                                      ),
                                      backgroundColor: cons!SCA2_VAL_COLOR_GRIS_MEDIO,
                                      textColor: cons!SCA2_VAL_COLOR_BLANCO
                                    )
                                  )
                                )
                              ),
                              a!gridColumn(
                                label: "Observaciones",
                                value: index(fv!row, "textObservacionEjec", "")
                              ),
                              a!gridColumn(
                                label: "Detalle suplemento",
                                align: "CENTER",
                                value: a!buttonLayout(
                                  primaryButtons: {
                                    a!buttonWidget(
                                      label: "",
                                      icon: "eye",
                                      color: "SECONDARY",
                                      saveInto: a!save(local!detalleSuplemento, fv!row)
                                    )
                                  },
                                  showWhen: tostring(index(fv!row, "txtApliArgumento", "")) = "WAUTEMIS"
                                )
                              )
                            }
                          ),
                          if(
                            or(local!esCA, local!esAA, local!esAut),
                            {
                              a!cardLayout(
                                contents: {
                                  a!richTextDisplayField(
                                    labelPosition: "COLLAPSED",
                                    value: a!richTextItem(
                                      text: "Documentos presentados por el cliente",
                                      style: "STRONG",
                                      size: "MEDIUM",
                                      color: cons!SCA2_VAL_COLOR_NEGRO
                                    )
                                  ),
                                  a!horizontalLine(
                                    marginAbove: "STANDARD",
                                    marginBelow: "LESS"
                                  ),
                                  a!gridField_25r2(
                                    emptyGridMessage: "No hay documentos a mostrar",
                                    data: local!docsCA,
                                    columns: {
                                      a!gridColumn(
                                        label: "Tipo documento",
                                        value: if(
                                          local!esAut,
                                          if(
                                            tostring(index(fv!row, "tipoDocumento", "")) = "7",
                                            "Dni",
                                            "Autorización"
                                          ),
                                          a!match(
                                            value: tostring(index(fv!row, "tipoDocumento", "")),
                                            equals: "1",
                                            then: "Justificante compra",
                                            equals: "2",
                                            then: if(
                                              or(
                                                a!defaultValue(local!origenPol, "") = "NSE-Autos",
                                                a!defaultValue(local!origenPol, "") = "wAutemis"
                                              ),
                                              "Justificante gestoria",
                                              "Anulación firmada"
                                            ),
                                            equals: "3",
                                            then: "Baja vehículo",
                                            equals: "4",
                                            then: "Histórico tráfico",
                                            equals: "5",
                                            then: "Justificante desguace",
                                            equals: "6",
                                            then: "Carta firmada",
                                            equals: "7",
                                            then: "Dni",
                                            equals: "8",
                                            then: "Autorización",
                                            equals: "400",
                                            then: "Baja vehiculo",
                                            default: if(local!esAut, "Autorización", "-")
                                          )
                                        )
                                      ),
                                      a!gridColumn(
                                        label: "Referencia",
                                        value: index(fv!row, "idDocumento", "")
                                      ),
                                      a!gridColumn(
                                        label: "Fecha entrega",
                                        value: index(fv!row, "fechaDocumento", "")
                                      ),
                                      a!gridColumn(
                                        label: "",
                                        align: "CENTER",
                                        value: a!buttonLayout(
                                          primaryButtons: {
                                            a!buttonWidget(
                                              label: "",
                                              icon: "eye",
                                              saveInto: {
                                                a!startProcess(
                                                  processModel: cons!SCA2_PM_OBTENER_DOCUMENTO_GD,
                                                  processParameters: {
                                                    documentumId: index(fv!row, "idDocumento", null)
                                                  },
                                                  isSynchronous: true,
                                                  onSuccess: {
                                                    a!save(
                                                      local!docVis,
                                                      fv!processInfo.pv.documentId
                                                    ),
                                                    a!save(local!verDoc, true)
                                                  },
                                                  onError: null
                                                )
                                              },
                                              disabled: a!isNullOrEmpty(index(fv!row, "idDocumento", null))
                                            )
                                          }
                                        )
                                      )
                                    },
                                    borderStyle: "LIGHT",
                                    shadeAlternateRows: false
                                  )
                                },
                                style: "TRANSPARENT",
                                shape: "ROUNDED",
                                padding: "STANDARD",
                                marginAbove: "STANDARD",
                                marginBelow: "MORE",
                                showWhen: not(local!verDoc)
                              ),
                              a!sectionLayout(
                                contents: rule!SCA2_VisualizarDocumento(
                                  document: local!docVis,
                                  cancel: local!verDoc
                                ),
                                showWhen: and(
                                  local!verDoc,
                                  a!isNotNullOrEmpty(local!docVis)
                                )
                              ),
                              a!richTextDisplayField(
                                labelPosition: "COLLAPSED",
                                value: {
                                  a!richTextItem(
                                    text: "Observaciones" & char(10),
                                    color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                                  ),
                                  a!richTextItem(
                                    text: a!defaultValue(
                                      if(
                                        local!esAut,
                                        index(local!detalleAut, "observaciones", null),
                                        if(
                                          local!esCA,
                                          a!defaultValue(
                                            index(local!gestionCA, "observaciones", null),
                                            local!obsDetalleCA
                                          ),
                                          index(local!gestionCA, "observaciones", null)
                                        )
                                      ),
                                      "-"
                                    ),
                                    style: "STRONG"
                                  )
                                },
                                marginBelow: "MORE"
                              )
                            },
                            {}
                          ),
                          /* [R9-B B7-SI24] aviso a Red Mapfre cuando la tarea la gestiona SI24 (texto definitivo aceptado por el analista, R27-A) */
                          a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: a!richTextItem(
                              text: "Esta solicitud la está gestionando SI24",
                              color: "SECONDARY",
                              style: "EMPHASIS",
                              size: "SMALL"
                            ),
                            align: "RIGHT",
                            showWhen: and(
                              not(local!esImpr),
                              a!isNotNullOrEmpty(local!tareaBtn),
                              or(
                                search(
                                  "SI24",
                                  upper(
                                    a!defaultValue(
                                      tostring(index(local!tareaBtn, "grupo", "")),
                                      ""
                                    )
                                  )
                                ) > 0,
                                search("SI24", local!subPerfilSol) > 0
                              ),
                              not(local!usuarioSI24),
                              not(local!esAdmin),
                              /* R46-C: no se avisa al usuario del alta en su propia Verti */
                              not(
                                and(
                                  upper(a!defaultValue(tostring(index(local!tareaBtn, "tipo", "")), "")) = cons!SCA2_TXT_CONTACTO_VERTI,
                                  tostring(index(local!tareaBtn, "asignadoA", "")) = tostring(loggedInUser())
                                )
                              )
                            )
                          ),
                          /* BOTONES DE RETOMAR Y REASIGNAR (R27-A: una sola fila alineada a la derecha, mismo estilo que el resto de botones de las tarjetas del Detalle) */
                          a!buttonArrayLayout(
                            showWhen: and(
                              not(local!esImpr),
                              a!isNotNullOrEmpty(local!tareaBtn),
                              rule!SCA2_puedeGestionarTarea(
                                /* R22 #1: como en SCA, la asignación a otro usuario no oculta RETOMAR/REASIGNAR; se evalúa el permiso por grupo/nivel */
                                tarea: if(
                                  /* R46-C: la Verti asignada al usuario del alta se evalúa con su asignación */
                                  upper(a!defaultValue(tostring(index(local!tareaBtn, "tipo", "")), "")) = cons!SCA2_TXT_CONTACTO_VERTI,
                                  local!tareaBtn,
                                  a!update(local!tareaBtn, "asignadoA", null)
                                ),
                                nivelIntervencion: tostring(
                                  index(local!est, "nivelIntervencion", null)
                                ),
                                codSubPerfil: local!subPerfilSol
                              ),
                              not(
                                and(
                                  search(
                                    "MECANIZA",
                                    upper(
                                      a!defaultValue(
                                        tostring(index(local!tareaBtn, "tipo", "")),
                                        ""
                                      )
                                    )
                                  ) > 0,
                                  tostring(index(local!est, "procesoActivo", "")) = "ANL"
                                )
                              )
                            ),
                            buttons: {
                              a!buttonWidget(
                                /* R45-C F4: como SCA_DetalleAnulacionMecanizacion/ContraAnulacion, en Verti/Vencimiento, mecanización y contra anulación RETOMAR solo si la tarea está sin asignar o asignada al usuario conectado */
                                showWhen: or(
                                  not(or(local!esCA, local!esMec, local!esVertiCard)),
                                  a!isNullOrEmpty(index(local!tareaBtn, "asignadoA", null)),
                                  touser(index(local!tareaBtn, "asignadoA", null)) = loggedInUser()
                                ),
                                label: "RETOMAR",
                                style: "SOLID",
                                color: cons!SCA2_VAL_COLOR_ROJO,
                                saveInto: {
                                  /* R20 #2: al RETOMAR se registra quién retoma la tarea (nuuma mostrado en la gestión de nivel > 1) */
                                  a!writeRecords(
                                    records: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea'(
                                      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id': tointeger(index(local!tareaBtn, "idTarea", null)),
                                      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA': loggedInUser(),
                                      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{fbf2e73f-38cb-4db5-abf6-50d8b7392118}fechaCaptura': now()
                                    ),
                                    onSuccess: {},
                                    onError: {}
                                  ),
                                  /* R24 #12 (respuesta analista 12): al RETOMAR una Contra Anulación se lanza a CORE la misma llamada que el POSPONER
                                       (finalizarContraAnulPca mcaEstadoFinal "2") con el infoUsuario del usuario que retoma, para que CORE registre su nuuma */
                                  a!save(
                                    local!resRetomarCore,
                                    if(
                                      local!esCA,
                                      a!localVariables(
                                        local!iu: index(
                                          rule!SCA2_obtenerInformacionUsuario(),
                                          "infoUsuarioDTO",
                                          {}
                                        ),
                                        local!sub: tostring(
                                          a!defaultValue(index(local!iu, "codSubPerfil", null), "")
                                        ),
                                        rule!SCA2_finalizarContraAnulPca(
                                          finalizarContraAnulPca: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}finalizarContraAnulPca'(
                                            MSEFinalizarContraAnulPca: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}finalizarContraAnulDTO'(
                                              mcaEstadoFinal: "2",
                                              nivelIntervencion: a!defaultValue(
                                                tointeger(
                                                  index(local!est, "nivelIntervencion", null)
                                                ),
                                                1
                                              ),
                                              codSolicitud: ri!idSolicitud,
                                              infoUsuario: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}infoUsuarioDTO'(
                                                codCiaUsuario: if(
                                                  tostring(
                                                    a!defaultValue(
                                                      index(local!est, "origenPoliza", null),
                                                      ""
                                                    )
                                                  ) = "wAutemis",
                                                  "1",
                                                  "41"
                                                ),
                                                nuuma: index(local!iu, "nuuma", null),
                                                codPerfil: if(
                                                  local!sub = cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO,
                                                  cons!SCA2_TXT_PERFIL_CE_MF_SI24,
                                                  index(local!iu, "codPerfil", null)
                                                ),
                                                codSubPerfil: local!sub
                                              )
                                            )
                                          )
                                        )
                                      ),
                                      null
                                    )
                                  ),
                                  a!save(
                                    ri!tipoAccion,
                                    index(local!tareaBtn, "tipo", null)
                                  ),
                                  a!save(
                                    ri!idTarea,
                                    index(local!tareaBtn, "idTarea", null)
                                  ),
                                  a!save(local!accionAbierta, true)
                                }
                              ),
                              a!buttonWidget(
                                /* R45-C F4: como SCA_DetalleAnulacionContraAnulacion, REASIGNAR oculto en la contra anulación de nivel 2 para el subperfil CE_MF_SI24 */
                                showWhen: if(
                                  and(local!esCA, tostring(local!nivelCard) = "2"),
                                  tostring(index(index(rule!SCA2_obtenerInformacionUsuario(), "infoUsuarioDTO", null), "codSubPerfil", null)) <> cons!SCA2_TXT_PERFIL_CE_MF_SI24,
                                  true
                                ),
                                label: "REASIGNAR",
                                style: "OUTLINE",
                                color: "SECONDARY",
                                saveInto: {
                                  rule!SCA2_reasignarTarea(
                                    idTarea: index(local!tareaBtn, "idTarea", null)
                                  ),
                                  a!save(local!showPopupReasignar, true)
                                }
                              )
                            },
                            align: "END"
                          ),
                          
                        },
                        /* [S4 ronda 6] como SCA_Detalle*: la tarjeta de la gestión se oculta mientras se muestra el popup de REASIGNAR */
                        showWhen: not(local!showPopupReasignar)
                      ),
                      if(
                        local!showPopupReasignar,
                        rule!SCA2_PopUpReasignarTarea(showPopup: local!showPopupReasignar),
                        {}
                      )
                    },
                    showWhen: and(local!abierta, not(local!esImpr)),
                    padding: "STANDARD",
                    marginAbove: "NONE",
                    marginBelow: "NONE",
                    showBorder: false
                  ),
                  if(
                    fv!isLast,
                    {},
                    a!horizontalLine(marginBelow: "NONE")
                  )
                }
              )
            )
          },
          shape: "ROUNDED",
          padding: "NONE",
          marginAbove: "STANDARD",
          showShadow: true
        ),
        /* ===== Trazabilidad técnica: plegada y solo admins ===== */
        a!cardLayout(
          showWhen: and(local!esAdmin, not(local!soloCore)),
          contents: {
            a!columnsLayout(
              columns: {
                a!columnLayout(
                  contents: a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: a!richTextItem(
                      text: "Trazabilidad técnica",
                      style: "STRONG",
                      link: a!dynamicLink(
                        saveInto: a!save(local!tecAbierto, not(local!tecAbierto))
                      ),
                      linkStyle: "STANDALONE",
                      color: cons!SCA2_VAL_COLOR_NEGRO
                    )
                  )
                ),
                a!columnLayout(
                  width: "NARROW",
                  contents: a!buttonLayout(
                    secondaryButtons: a!buttonWidget(
                      icon: if(
                        local!tecAbierto,
                        "chevron-up",
                        "chevron-down"
                      ),
                      style: "LINK",
                      color: cons!SCA2_VAL_COLOR_NEGRO,
                      saveInto: a!save(local!tecAbierto, not(local!tecAbierto))
                    )
                  )
                )
              }
            ),
            a!columnsLayout(
              showWhen: local!tecAbierto,
              columns: a!columnLayout(
                contents: {
                  rule!SCA2_DetalleCabecera(idSolicitud: ri!idSolicitud),
                  rule!SCA2_DetalleDatos(idSolicitud: ri!idSolicitud),
                  rule!SCA2_DetalleTransiciones(idSolicitud: ri!idSolicitud),
                  rule!SCA2_DetalleErrores(idSolicitud: ri!idSolicitud)
                }
              )
            )
          },
          shape: "ROUNDED",
          showShadow: true,
          marginAbove: "MORE"
        )
      }
    )
  }
)