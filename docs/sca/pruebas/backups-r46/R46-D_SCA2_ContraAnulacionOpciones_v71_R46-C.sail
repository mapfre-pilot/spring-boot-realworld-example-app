/*
[SCA2] Opciones de contra anulación — copia condensada de SCA_ContraAnulacionOpcionesEstrategicas
(2228 l.): selector de oficinas, secciones colapsables "Compañía contraria y catalogación",
"Acciones contra anulación" (argumentario + POSITIVO/NEGATIVO con regateo, recuperación,
descuentos y SGO) y "Documentación"; FINALIZAR/CANCELAR/POSPONER.
Inputs: idSolicitud, idTarea, onCompletar
*/
a!localVariables(
  local!usuario: index(
    rule!SCA2_obtenerInformacionUsuario(),
    "infoUsuarioDTO",
    {}
  ),
  local!sol: rule!SCA2_cargarSolicitud(idSolicitud: ri!idSolicitud),
  local!estado: index(local!sol, "estado", {}),
  local!datos: index(
    index(local!sol, "datosCompletosSolicitud", {}),
    "datosSolicitud",
    {}
  ),
  local!basicos: index(
    index(local!sol, "datosCompletosSolicitud", {}),
    "datosBasicosSolicitud",
    {}
  ),
  /* NIF del tomador (paridad SCA ri!nifTomador): los datos básicos SCA2 no lo guardan; se toma de la póliza o de la cabecera */
  local!nifTomadorCalc: a!defaultValue(
    index(local!basicos, "niftomador", null),
    index(local!estado, "nifTomador", null),
    index(
      local!sol,
      "datosPoliza",
      "niftomador",
      null
    ),
    index(
      local!sol,
      "datosPolizaAutos",
      "niftomador",
      null
    ),
    index(
      local!sol,
      "datosPolizaHogar",
      "niftomador",
      null
    ),
    index(
      local!sol,
      "datosPolizaVida",
      "niftomador",
      null
    ),
    index(
      local!sol,
      "datosCabecera",
      "clienteNif",
      null
    ),
    ""
  ),
  local!perfiles: index(
    index(
      a!queryRecordType(
        recordType: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca',
        filters: a!queryFilter(
          field: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud',
          operator: "=",
          value: ri!idSolicitud
        ),
        fields: {
          'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud',
          'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{a71794d3-baab-46d5-9fcc-d2d6845cd0ec}nuuma',
          'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil'
        },
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
        fetchTotalCount: false
      ),
      "data",
      {}
    ),
    1,
    null
  ),
  /* Paridad SCA_ContraAnulacionOpciones: NUUMA del usuario logado (oficinas, impresión, infoUsuario CORE); el NUUMA del record (creador) sólo como respaldo */
  local!nuuma: a!defaultValue(
    index(local!usuario, "nuuma", null),
    index(
      local!perfiles,
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{a71794d3-baab-46d5-9fcc-d2d6845cd0ec}nuuma',
      ""
    )
  ),
  local!codPerfil: a!defaultValue(
    index(local!usuario, "codPerfil", null),
    index(
      local!perfiles,
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
      null
    )
  ),
  local!numPoliza: a!defaultValue(
    index(local!basicos, "numpoliza", null),
    index(local!estado, "numPoliza", "")
  ),
  local!polizaRenovada: rule!SCA2_polizaRenovada(poliza: local!numPoliza),
  local!obtenerOficinas: reduce(
    index(_, _, null),
    rule!SCA2_obtenerOficinasFisicasNuuma(nuuma: local!nuuma),
    {
      "MSSObtenerOficinasFisicasNuuma",
      "LISTA_OFICINAS"
    }
  ),
  local!oficinas: a!defaultValue(local!obtenerOficinas, {}),
  local!masDeUnaOficina: and(
    a!isNotNullOrEmpty(local!oficinas),
    length(local!oficinas) > 1
  ),
  /* B1: al RETOMAR se preselecciona la oficina elegida al POSPONER (SCA2 Tarea.tokenTarea = OFICINA:<OFICINA_DIRECTA>|<DESC_OFICINA>) */
  local!tokenTarea: if(
    a!isNullOrEmpty(ri!idTarea),
    "",
    tostring(
      index(
        index(
          index(
            a!queryRecordType(
              recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
              fields: {
                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea'
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
        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{90ecf1b6-4da4-477f-923b-d4ad9431fa98}tokenTarea',
        ""
      )
    )
  ),
  local!oficinaGuardada: if(
    or(
      a!isNullOrEmpty(local!tokenTarea),
      left(local!tokenTarea, 8) <> "OFICINA:",
      a!isNullOrEmpty(local!oficinas)
    ),
    null,
    a!localVariables(
      local!codOficina: index(
        split(
          right(
            local!tokenTarea,
            len(local!tokenTarea) - 8
          ),
          "|"
        ),
        1,
        ""
      ),
      local!posOficina: wherecontains(
        local!codOficina,
        touniformstring(
          index(local!oficinas, "OFICINA_DIRECTA", {})
        )
      ),
      if(
        a!isNullOrEmpty(local!posOficina),
        null,
        index(
          local!oficinas,
          index(local!posOficina, 1, 1),
          null
        )
      )
    )
  ),
  local!detalleOficina: if(
    a!isNotNullOrEmpty(local!oficinaGuardada),
    local!oficinaGuardada,
    if(
      length(local!oficinas) = 1,
      index(local!oficinas, 1, null),
      null
    )
  ),
  local!origenPoliza: a!defaultValue(
    index(local!estado, "origenPoliza", null),
    index(local!estado, "lineaNegocio", "")
  ),
  local!polizaVida: local!origenPoliza = cons!SCA2_TXT_VIDA_RIESGO,
  local!mostrarDocumentacion: not(local!polizaVida),
  local!polizawAutemis: local!origenPoliza = cons!SCA2_TXT_WAUTEMIS,
  local!codCiaUsuario: if(local!polizawAutemis, "1", "41"),
  local!flagVida: index(
    rule!SCA2_ConsultaConceptosFuncionalesFlagSgoVida(),
    1,
    ""
  ) = "S",
  local!nivelIntervencion: a!defaultValue(
    tointeger(
      index(local!estado, "nivelIntervencion", null)
    ),
    1
  ),
  local!mostrarBotonesCancelarPosponer: rule!SCA2_mostrarBotonCancelarPosponer(
    codPerfil: local!codPerfil,
    codSubPerfil: index(
      local!usuario,
      "codSubPerfil",
      index(
        local!perfiles,
        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
        null
      )
    ),
    nuumaGestion: local!nuuma,
    nuumaPropietario: index(
      local!sol,
      "datosCompletosSolicitud",
      "datosCabecera",
      "clienteNuumapropietario",
      null
    ),
    nivelIntervencion: index(local!estado, "nivelIntervencion", null),
    clienteCarterizado: index(
      local!sol,
      "datosCompletosSolicitud",
      "datosCabecera",
      "clienteCarterizado",
      null
    )
  ),
  local!codCiaContraria: if(
    a!isNullOrEmpty(index(local!datos, "idcompania", null)),
    null,
    tostring(index(local!datos, "idcompania", null))
  ),
  local!gestiones: index(
    rule!SCA2_consultaGestion(codSolicitud: ri!idSolicitud),
    "MSSConsultaGestion",
    null
  ),
  /* Gestión CA ya cerrada en CORE (reintento tras fallo local posterior a IContraAnularPCA): FINALIZAR completa la transición local sin argumentario */
  local!estadoCACore: a!localVariables(
    local!ca: reject(
      fn!isnull,
      a!forEach(
        items: a!defaultValue(local!gestiones, {}),
        expression: if(
          tostring(
            a!defaultValue(index(fv!item, "accionRealizada", ""), "")
          ) = "2",
          fv!item,
          null
        )
      )
    ),
    upper(
      tostring(
        a!defaultValue(
          index(
            index(local!ca, length(local!ca), null),
            "codEstGestion",
            ""
          ),
          ""
        )
      )
    )
  ),
  local!caFinalizadaCore: left(local!estadoCACore, 10) = cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
  local!codGestion: a!defaultValue(
    index(
      reject(
        fn!isnull,
        a!forEach(
          items: local!gestiones,
          expression: if(
            and(
              index(fv!item, "accionRealizada", "") = "2",
              index(fv!item, "codEstGestion", "") = "INCOMPLETA"
            ),
            index(fv!item, "numGestion", ""),
            null
          )
        )
      ),
      1,
      null
    ),
    index(local!basicos, "idgestionsgc", "")
  ),
  local!observaciones,
  local!noEntregaDoc,
  local!collapse1: true,
  local!collapse2: true,
  local!collapse3: true,
  local!respuesta,
  local!mensaje,
  local!mensajeInfo,
  local!ciaContraria,
  local!seleccionCia,
  local!showPopup,
  local!catalogacion: index(local!datos, "catalogacion", null),
  local!fechaAnulacion: index(local!datos, "fecanulacion", null),
  local!activarPanCatalogacion: true,
  local!tipoGestion: "2",
  /* --- tanda 9: port literal de bloques del original --- */
  local!datosProductor: a!defaultValue(
    index(local!sol, "datosProductor", null),
    {}
  ),
  /* R11 #9 (analista): las marcas del productor se envían siempre (ya no dependen de CCC/CCR) */
  local!anulaTecnicos: tostring(
    a!defaultValue(
      index(
        local!datosProductor,
        "anulatecnicos",
        false
      ),
      false
    )
  ) = "true",
  local!anulaExpertos: tostring(
    a!defaultValue(
      index(
        local!datosProductor,
        "anulaexpertos",
        false
      ),
      false
    )
  ) = "true",
  /* Fase 1 (sesión B): SCA2_cargarSolicitud devuelve la clave de producción en datosPoliza/datosPolizaAutos (nivel superior); las rutas bajo datosCompletosSolicitud llegaban vacías */
  local!claveProduccion: a!defaultValue(
    index(
      index(local!sol, "datosPoliza", {}),
      "claveproduccion",
      ""
    ),
    index(
      index(local!sol, "datosPolizaAutos", {}),
      "claveproduccion",
      ""
    ),
    a!defaultValue(
      a!defaultValue(
        index(
          index(
            index(local!sol, "datosCompletosSolicitud", {}),
            "datosPolizaAutos",
            {}
          ),
          "claveproduccion",
          ""
        ),
        index(
          index(
            index(local!sol, "datosCompletosSolicitud", {}),
            "datosPolizaHogar",
            {}
          ),
          "claveproduccion",
          ""
        )
      ),
      index(
        index(
          index(local!sol, "datosCompletosSolicitud", {}),
          "datosPolizaVida",
          {}
        ),
        "claveproduccion",
        ""
      )
    ),
    ""
  ),
  local!idCliente: index(
    index(
      local!sol,
      "datosCompletosSolicitud",
      "datosCabecera",
      {}
    ),
    "datosCliente",
    "idCliente",
    index(
      index(
        local!sol,
        "datosCompletosSolicitud",
        "datosCabecera",
        {}
      ),
      "clienteId",
      ""
    )
  ),
  local!checksPECA: if(
    a!isNullOrEmpty(local!idCliente),
    {},
    reject(
      fn!isnull,
      a!forEach(
        rule!SCA2_checksAPIClients(
          clientId: local!idCliente,
          preguntas: { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
        ),
        if(
          index(fv!item, "responseId", "") = "1",
          index(fv!item, "questionDesc", "") & index(fv!item, "responseDesc", ""),
          ""
        )
      )
    )
  ),
  local!searchAPI: rule!SCA2_searchAPIClients(
    request: {
      "policyNumber": local!numPoliza,
      "policyRolesFilter": {
        "startDate": datetext(today(), "yyyy-MM-dd"),
        "policyRoleIds": { "12" }
      },
      "searchDetail": { "potencialInd": true, "notVisible": true }
    }
  ),
  local!mcaPropietarioPoliza: if(
    a!isNullOrEmpty(local!claveProduccion),
    false,
    rule!SCA2_nuumaEsPropietario(
      codCia: "41",
      nuuma: local!nuuma,
      claveProd: local!claveProduccion,
      idSolicitud: ri!idSolicitud,
      numPoliza: local!numPoliza
    )
  ),
  local!cabeceraCA: rule!SCA2_obtenerDatosCabecera(
    numPoliza: local!numPoliza,
    idSolicitud: tointeger(ri!idSolicitud)
  ),
  local!fechaEfectoAnualidad: todate(
    index(
      index(local!cabeceraCA, "datosPoliza", null),
      "fechaEfecto",
      null
    )
  ),
  local!documentosOk: false,
  local!mostrarRevision: if(
    and(
      local!mcaPropietarioPoliza,
      if(
        cons!SCA2_USAR_POLIZA_RENOVADA_UNICA,
        local!polizaRenovada,
        rule!SCA2_polizaRenovada(poliza: local!numPoliza)
      ) = true,
      a!isNotNullOrEmpty(local!fechaEfectoAnualidad),
      local!fechaEfectoAnualidad < today(),
      local!fechaEfectoAnualidad > edate(today(), - 2)
    ),
    true,
    false
  ),
  /* Argumentario — body alineado con SCA_ContraAnulacionOpcionesEstrategicas */
  local!numApli: a!defaultValue(
    a!defaultValue(
      a!defaultValue(
        index(
          index(
            index(local!sol, "datosCompletosSolicitud", {}),
            "datosPolizaAutos",
            {}
          ),
          "numapli",
          null
        ),
        index(
          index(
            index(local!sol, "datosCompletosSolicitud", {}),
            "datosPolizaHogar",
            {}
          ),
          "numapli",
          null
        )
      ),
      index(
        index(
          index(local!sol, "datosCompletosSolicitud", {}),
          "datosPolizaVida",
          {}
        ),
        "numapli",
        null
      )
    ),
    "0"
  ),
  local!lineaNegocio: a!defaultValue(
    a!defaultValue(
      a!defaultValue(
        index(
          index(
            index(local!sol, "datosCompletosSolicitud", {}),
            "datosPolizaHogar",
            {}
          ),
          "lineadenegocio",
          null
        ),
        index(
          index(
            index(local!sol, "datosCompletosSolicitud", {}),
            "datosPolizaAutos",
            {}
          ),
          "lineadenegocio",
          null
        )
      ),
      index(
        index(
          index(local!sol, "datosCompletosSolicitud", {}),
          "datosPolizaVida",
          {}
        ),
        "lineadenegocio",
        null
      )
    ),
    a!defaultValue(
      index(local!estado, "lineaNegocio", null),
      local!origenPoliza
    )
  ),
  local!fechaAnulacionMod: if(
    a!isNullOrEmpty(local!fechaAnulacion),
    null,
    datetext(
      todate(local!fechaAnulacion),
      "yyyy-MM-dd"
    )
  ),
  local!centroEmisor: index(
    rule!SCA2_consultarEquipos(codNuuma: local!nuuma),
    "MSSConsultarEquipos",
    "centro_emisor",
    ""
  ),
  local!codGestionArg: a!defaultValue(
    index(
      reject(
        fn!isnull,
        a!forEach(
          items: a!defaultValue(local!gestiones, {}),
          expression: if(
            and(
              index(fv!item, "accionRealizada", "") = "2",
              index(fv!item, "codEstGestion", "") = "INCOMPLETA"
            ),
            index(fv!item, "numGestion", ""),
            null
          )
        )
      ),
      1,
      null
    ),
    index(
      local!gestiones,
      "numGestion",
      local!codGestion
    )
  ),
  local!body: {
    compania: if(
      local!polizawAutemis,
      "1",
      local!polizaVida,
      "3",
      "41"
    ),
    numPoliza: local!numPoliza,
    numSolicitud: ri!idSolicitud,
    codGestion: local!codGestionArg,
    nivel: index(local!estado, "nivelIntervencion", ""),
    lineaNegocio: local!lineaNegocio,
    codCompaniaContraria: local!codCiaContraria,
    claveProduccion: local!claveProduccion,
    codigoDetalleAnulacion: index(local!datos, "coddetalle", ""),
    codigoSCA: ri!idSolicitud,
    descripcionSCA: "1",
    codigoCompaniaContraria: local!codCiaContraria,
    anulaTecnico: local!anulaTecnicos,
    anulaExperto: local!anulaExpertos,
    mecanizada: toboolean(
      index(
        local!estado,
        "mecanizacionrealizada",
        false
      )
    ),
    motivoContacto: index(local!datos, "codmotivo", ""),
    modoAcceso: "G",
    numApli: local!numApli,
    codTipCanalEntPca: index(local!datos, "canalentrada", ""),
    codMotivo: index(local!datos, "codmotivo", ""),
    codCausa: index(local!datos, "codcausa", ""),
    fecAnulPca: local!fechaAnulacionMod,
    codCatalogacion: index(local!datos, "catalogacion", ""),
    estadoUltimaGestion: "1",
    subgrupo: "",
    codCentroEmisor: local!centroEmisor,
    infoUsuario: {
      nuuma: local!nuuma,
      codCiaUsuario: local!codCiaUsuario,
      codPerfil: local!codPerfil,
      codSubPerfil: index(local!usuario, "codSubPerfil", "")
    }
  },
  /* Paridad SCA: se conserva la respuesta completa del listado (incluye "treboles" = DEFCART: codTrebol/descTrebol/trebolesDisponibles/trebolesRecomendados) */
  local!respArgumentario: a!refreshVariable(
    value: rule!SCA2_consultarListadoArgumentos(body: local!body),
    refreshOnVarChange: ri!idTarea
  ),
  local!argumentario: index(
    local!respArgumentario,
    "listadoArgumentos",
    {}
  ),
  /* R27-B (analista 22/10): en la CA se muestran primero los argumentos ejecutados en contra anulaciones
     anteriores (nivelArgumento < nivelIntervencion) por orden alfabético y después los disponibles para la
     nueva CA en el orden que devuelve el servicio; el hijo pinta un separador tras local!numArgAnteriores.
     Todos los índices (estado/usuario/fecha/selección/tréboles) se calculan sobre esta lista ya ordenada. */
  local!idxArgAnteriores: if(
    a!isNullOrEmpty(local!argumentario),
    {},
    where(
      a!forEach(
        items: local!argumentario,
        expression: a!defaultValue(
          tointeger(index(fv!item, "nivelArgumento", null)),
          local!nivelIntervencion
        ) < local!nivelIntervencion
      )
    )
  ),
  local!idxArgAnterioresAlfa: if(
    a!isNullOrEmpty(local!idxArgAnteriores),
    {},
    index(
      index(
        todatasubset(
          a!forEach(
            items: local!idxArgAnteriores,
            expression: a!map(
              idx: fv!item,
              desc: upper(
                tostring(
                  index(
                    local!argumentario,
                    fv!item,
                    "descTipoArgumento",
                    ""
                  )
                )
              )
            )
          ),
          a!pagingInfo(
            startIndex: 1,
            batchSize: - 1,
            sort: a!sortInfo(field: "desc", ascending: true)
          )
        ),
        "data",
        {}
      ),
      "idx",
      {}
    )
  ),
  local!idxArgNuevos: if(
    a!isNullOrEmpty(local!argumentario),
    {},
    difference(
      enumerate(count(local!argumentario)) + 1,
      local!idxArgAnteriores
    )
  ),
  local!numArgAnteriores: count(local!idxArgAnteriores),
  local!listaArgumentos: if(
    a!isNullOrEmpty(local!argumentario),
    local!argumentario,
    index(
      local!argumentario,
      append(
        local!idxArgAnterioresAlfa,
        local!idxArgNuevos
      ),
      {}
    )
  ),
  local!descart: if(
    a!isNotNullOrEmpty(local!listaArgumentos),
    index(local!respArgumentario, "treboles", null),
    null
  ),
  local!arrayTrebolesDisponibles: a!forEach(
    items: a!defaultValue(local!listaArgumentos, {}),
    expression: if(
      a!isNullOrEmpty(local!descart),
      null,
      index(
        local!descart,
        where(
          tostring(index(local!descart, "codTrebol", {})) = tostring(index(fv!item, "codTipoArgumento", ""))
        ),
        "trebolesDisponibles",
        1,
        null
      )
    )
  ),
  local!arrayTrebolesRecomendados: a!forEach(
    items: a!defaultValue(local!listaArgumentos, {}),
    expression: if(
      a!isNullOrEmpty(local!descart),
      null,
      index(
        local!descart,
        where(
          tostring(index(local!descart, "codTrebol", {})) = tostring(index(fv!item, "codTipoArgumento", ""))
        ),
        "trebolesRecomendados",
        1,
        null
      )
    )
  ),
  local!argumentoSeleccionado,
  local!indiceArgSeleccionado,
  local!estadoArgumentos: index(local!listaArgumentos, "mcaEstado", {}),
  local!usuarioArgumentos: index(local!listaArgumentos, "usuario", {}),
  local!fecEjecucionArgumentos: index(
    local!listaArgumentos,
    "fecEjecutado",
    {}
  ),
  local!obligEjecu: if(
    a!isNullOrEmpty(local!listaArgumentos),
    true,
    and(
      a!forEach(
        items: index(
          local!listaArgumentos,
          "mcaObligatorio",
          {}
        ),
        expression: or(
          fv!item <> "S",
          index(local!estadoArgumentos, fv!index, "0") <> "0"
        )
      )
    )
  ),
  local!numArgEjec: if(
    a!isNotNullOrEmpty(local!listaArgumentos),
    count(
      reject(
        fn!isnull,
        a!forEach(
          items: local!listaArgumentos,
          expression: if(
            not(
              index(local!estadoArgumentos, fv!index, "") = "0"
            ),
            1,
            null
          )
        )
      )
    ),
    null
  ),
  /* ¿Hay algún argumento obligatorio de mayor prioridad sin ejecutar? (literal SCA) */
  local!mayorOrdenObligNoEjecutados: if(
    a!isNullOrEmpty(local!argumentoSeleccionado),
    false,
    and(
      index(
        local!argumentoSeleccionado,
        "mcaObligatorio",
        ""
      ) = "S",
      contains(
        a!forEach(
          items: local!listaArgumentos,
          expression: if(
            not(fv!index = local!indiceArgSeleccionado),
            and(
              index(fv!item, "mcaObligatorio", "") = "S",
              tointeger(index(fv!item, "orden", "")) < tointeger(
                index(local!argumentoSeleccionado, "orden", "")
              ),
              index(local!estadoArgumentos, fv!index, null) = "0"
            ),
            false
          )
        ),
        true
      )
    )
  ),
  local!deducciones,
  local!mcaDeducciones: false,
  local!documento,
  local!data: {
    /* body de argumentos del padre, para que RECARGAR ARGUMENTO (SCA2_ContraAnulacionCompaniaCatalogacion) use la misma petición */
    body: local!body,
    numPoliza: local!numPoliza,
    codSolicitud: ri!idSolicitud,
    codGestion: local!codGestion,
    nivelIntervencion: local!nivelIntervencion,
    codCiaUsuario: "41",
    nuuma: local!nuuma,
    codPerfil: local!codPerfil,
    codSubPerfil: index(
      local!usuario,
      "codSubPerfil",
      index(
        local!perfiles,
        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
        null
      )
    ),
    codDetalle: index(local!datos, "coddetalle", ""),
    canalEntrada: index(local!datos, "canalentrada", ""),
    codMotivo: index(local!datos, "codmotivo", ""),
    codCausa: index(local!datos, "codcausa", ""),
    tipoCatalogacion: local!catalogacion,
    mecanizada: a!defaultValue(
      index(
        local!estado,
        "mecanizacionRealizada",
        null
      ),
      false
    ),
    numDoc: local!nifTomadorCalc,
    observaciones: local!observaciones
  },
  /* Regateo / recuperación / descuentos */
  local!return: false,
  local!estadoContraAnul,
  /* Resultado del FINALIZAR (paridad SCA local!estadoContraAnul / nodo 19 SCA_Finalizar_Contra_Anulacion): 3 positivo, 2 negativo con argumentos obligatorios sin ejecutar, 4 negativo */
  local!estadoFinalizarCA: if(
    local!caFinalizadaCore,
    if(
      local!estadoCACore = cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
      "3",
      "4"
    ),
    if(
      a!defaultValue(local!estadoContraAnul, "") = "3",
      "3",
      if(
        and(
          a!isNotNullOrEmpty(
            reject(
              fn!isnull,
              a!forEach(
                items: a!defaultValue(local!listaArgumentos, {}),
                expression: if(
                  index(fv!item, "mcaObligatorio", "") = "S",
                  fv!item,
                  null
                )
              )
            )
          ),
          local!obligEjecu = false
        ),
        "2",
        "4"
      )
    )
  ),
  local!comprobarSolicitud,
  local!urlNSE,
  local!mcaVentanaRegateo: false,
  local!mcaVentanaRetos: false,
  local!mcaVentanaSVADisponibles: false,
  local!mcaVentanaEmail: false,
  local!mcaVentanaRecuperacion: false,
  local!mcaVentanaInfo: false,
  local!showDescuentosVida: false,
  local!mcaSVADisponiblesEjecutado: false,
  local!SVADisponibles: index(
    rule!SCA2_obtenerSVADisponibles(numDoc: index(local!data, "numDoc", "")),
    "sva",
    {}
  ),
  local!SVAElegido,
  /* Paridad SCA: correo de contacto de la cabecera (SCA: ri!datosCabecera.datosContacto.correo) */
  local!email: a!defaultValue(
    index(
      index(local!cabeceraCA, "datosContacto", null),
      "correo",
      null
    ),
    ""
  ),
  /* Paridad SCA (SCA_ContraAnulacionOpcionesEstrategicas): campaña DEFCART del argumento seleccionado, TuTeQuedas y regateable */
  local!codTpArg: if(
    a!isNotNullOrEmpty(local!argumentoSeleccionado),
    index(
      local!argumentoSeleccionado,
      "codTipoArgumento",
      ""
    ),
    null
  ),
  local!campanaDescart: if(
    and(
      a!isNotNullOrEmpty(local!descart),
      a!isNotNullOrEmpty(local!codTpArg)
    ),
    index(
      local!descart,
      index(
        wherecontains(
          tostring(local!codTpArg),
          a!forEach(
            items: index(local!descart, "codTrebol", {}),
            expression: tostring(fv!item)
          )
        ),
        1,
        null
      ),
      null
    ),
    null
  ),
  local!codCampana: index(local!campanaDescart, "descTrebol", null),
  local!tuTeQuedas: and(
    a!isNotNullOrEmpty(local!codCampana),
    local!codCampana <> "RETOS"
  ),
  local!detalleArgumento: if(
    a!isNullOrEmpty(local!argumentoSeleccionado),
    null,
    rule!SCA2_consultarTipoArg(
      mseConsultarTipoArgDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarTipoArgDTO'(
        desc: index(
          local!argumentoSeleccionado,
          "descTipoArgumento",
          null
        )
      )
    )
  ),
  local!detalleArgumento2: a!flatten(
    reject(
      fn!isnull,
      a!forEach(
        items: index(
          local!detalleArgumento,
          "MSSConsultarTipoArg",
          null
        ),
        expression: if(
          index(fv!item, "codTpArg", null) = index(
            local!argumentoSeleccionado,
            "codTipoArgumento",
            ""
          ),
          fv!item,
          null
        )
      )
    )
  ),
  local!esRegateable: or(
    and(
      a!isNotNullOrEmpty(local!detalleArgumento2),
      index(
        local!detalleArgumento2,
        "regateable",
        null
      ) = "S"
    ),
    a!isNotNullOrEmpty(local!campanaDescart)
  ),
  local!maximo: if(
    a!isNotNullOrEmpty(
      index(
        local!arrayTrebolesDisponibles,
        local!indiceArgSeleccionado,
        null
      )
    ),
    index(
      local!arrayTrebolesDisponibles,
      local!indiceArgSeleccionado,
      null
    ),
    index(
      local!argumentoSeleccionado,
      "numTipBon",
      null
    )
  ),
  local!tipoBonificacion: if(
    local!mcaVentanaRetos,
    index(
      local!argumentoSeleccionado,
      "codTipBon",
      null
    ),
    local!codCampana
  ),
  local!fecVencimientoPoliza: a!defaultValue(
    index(
      local!sol,
      "datosPolizaHogar",
      "fechadevencimiento",
      null
    ),
    index(
      local!sol,
      "datosPolizaAutos",
      "fechadevencimiento",
      null
    ),
    index(
      local!sol,
      "datosPolizaVida",
      "fechadevencimiento",
      null
    ),
    index(
      local!sol,
      "datosPoliza",
      "fechadevencimiento",
      null
    )
  ),
  local!numBonAplic,
  local!tipoArgumentoVariable: 0,
  /* R37-A: observación del servicio aplicado (Retos/SVA), la rellena SCA2_ContraAnulacionSGO sólo si el servicio responde OK */
  local!obsServicioAplicado,
  /* --- tanda 11: auxiliares del original (Estrategicas) --- */
  local!poliza: if(
    local!polizawAutemis,
    rule!SCA2_consultarPolizas(P_NUM_POLIZA: local!numPoliza),
    rule!SCA2_pObtenerPolizaFecha(
      mSEPObtenerPolizaFechaDTO: a!map(
        pcodcia: 41,
        pnumpoliza: local!numPoliza,
        pnumapli: 0,
        pnumsptoapli: 0,
        pmcaconsultaglobal: "S",
        pmcalk: "S"
      )
    )
  ),
  local!datosPersonales: a!defaultValue(
    index(
      local!poliza,
      "MSSConsultarPolizas",
      "DATOS_PCA",
      "DATOS_TO",
      null
    ),
    index(
      local!poliza,
      "MSSPObtenerPolizaFecha",
      "poconpolizat",
      "array",
      "datospersonales",
      1,
      "array",
      1,
      null
    )
  ),
  local!nifTomador: local!nifTomadorCalc,
  local!mcaFisicoJuridico: if(
    local!polizawAutemis,
    if(
      index(local!datosPersonales, "MCA_FISICO") = "S",
      "F",
      "J"
    ),
    if(
      index(local!datosPersonales, "mcafisico", null) = "S",
      "F",
      "J"
    )
  ),
  local!nombre: index(
    local!sol,
    "datosCabecera",
    "clienteNombre",
    ""
  ),
  local!apellido1: index(
    local!sol,
    "datosCabecera",
    "clienteApellidos",
    ""
  ),
  local!apellido2: "",
  local!localidad: "",
  local!razonSocial: index(
    local!sol,
    "datosCabecera",
    "clienteNombre",
    ""
  ),
  local!mcaClienteTeCuidamos: index(
    index(
      rule!SCA2_consultaClasificacionTC(numDoc: local!nifTomador),
      "MSSConsultaClasificacionTC",
      false
    ),
    "indActivo",
    0
  ) = 1,
  local!companias: reduce(
    index(_, _, null),
    rule!SCA2_catalogFilteredIntegracion(),
    { "result", "body", "data", "item", "str" }
  ),
  local!meses: {
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre"
  },
  local!fechaAnulacionMod2: if(
    a!isNullOrEmpty(local!fechaAnulacion),
    null,
    datetext(
      todate(local!fechaAnulacion),
      "dd-MM-yyyy"
    )
  ),
  local!oficina: if(
    a!isNullOrEmpty(local!detalleOficina),
    index(local!obtenerOficinas, 1, null),
    local!detalleOficina
  ),
  local!codigoPostal: index(local!oficina, "COD_POSTAL", ""),
  local!tipoVia: index(local!oficina, "ID_TIPO_VIA", ""),
  local!nombreVia: index(local!oficina, "NOMBRE_VIA", ""),
  local!localidadOficina: index(local!oficina, "LOCALIDAD", ""),
  local!numeroDomicilio: index(local!oficina, "NUMERO", ""),
  local!oficinaDirecta: index(local!oficina, "OFICINA_DIRECTA", ""),
  local!provincia: if(
    a!isNullOrEmpty(local!oficina),
    "",
    index(
      cons!SCA2_TXT_PROVINCIAS,
      tointeger(index(local!oficina, "ID_PROVINCIA", 0)),
      ""
    )
  ),
  local!tlfFijo: index(local!oficina, "TELEFONO_1", ""),
  local!tlfMovil: if(
    a!isNullOrEmpty(index(local!oficina, "TELEFONO_2", "")),
    index(local!oficina, "TELEFONO_3", ""),
    index(local!oficina, "TELEFONO_2", "")
  ),
  local!consultaImpr: index(
    rule!SCA2_consultaImpr(
      codCia: local!codCiaUsuario,
      nuuma: local!nuuma,
      codPerfil: local!codPerfil,
      codSubPerfil: index(local!data, "codSubPerfil", ""),
      codSolicitud: ri!idSolicitud,
      mcaFisicoJuridico: local!mcaFisicoJuridico
    ),
    "MSSConsultaImpr",
    null
  ),
  local!yaImpreso: index(local!consultaImpr, "mcaImprAnt", false),
  /* variables documentación */
  local!consultarDocumento: rule!SCA2_consultarDocumentos(codSolicitud: ri!idSolicitud),
  local!listaDocumentos: index(
    index(
      local!consultarDocumento,
      "MSSConsultarDocumentos",
      null
    ),
    "listaDocumentos",
    null
  ),
  local!listaNombreDocs,
  local!documentosACargar1,
  local!documentosACargar2,
  local!documentosACargar3,
  local!documentosACargar4,
  local!documentosACargar5,
  local!documentosACargar6,
  local!documentosACargar7,
  local!documentosACargar8,
  local!listadoMostrar,
  local!idCartaFirmada,
  local!cartaAdjunta: a!isNotNullOrEmpty(
    index(
      local!listaDocumentos,
      wherecontains(
        "6",
        index(
          local!listaDocumentos,
          "tipoDocumento",
          null
        )
      ),
      "idDocumento",
      null
    )
  ),
  local!dniAdjunto: a!isNotNullOrEmpty(
    index(
      local!listaDocumentos,
      wherecontains(
        "7",
        index(
          local!listaDocumentos,
          "tipoDocumento",
          null
        )
      ),
      "idDocumento",
      null
    )
  ),
  local!plantillaCarta: index(
    local!consultaImpr,
    "listadoPlantillaDTO",
    1,
    "plantilla",
    null
  ),
  local!mcaVentanaVisualizarDoc: false,
  local!flecha: false,
  local!oficinaSeleccionada: if(
    and(
      local!masDeUnaOficina = true,
      a!isNullOrEmpty(local!detalleOficina)
    ),
    false,
    true
  ),
  local!infoPlantilla: {
    anho: tostring(year(today())),
    apellido1: local!apellido1,
    apellido2: local!apellido2,
    dia: tostring(day(today())),
    fecAnulacion: local!fechaAnulacionMod2,
    idTipoVia: if(
      a!isNullOrEmpty(local!tipoVia),
      "CALLE",
      local!tipoVia
    ),
    localidad: local!localidad,
    mcaFisicaJuridico: local!mcaFisicoJuridico,
    mes: index(local!meses, month(today())),
    nombre: local!nombre,
    nombreVia: local!nombreVia,
    numPoliza: local!numPoliza,
    numero: local!numeroDomicilio,
    razonSocial: local!razonSocial,
    codigoPostal: local!codigoPostal,
    domicilio: concat(
      if(
        a!isNullOrEmpty(local!tipoVia),
        "CALLE",
        local!tipoVia
      ),
      " ",
      local!nombreVia
    ),
    localidadOficina: local!localidadOficina,
    numeroDomicilio: local!numeroDomicilio,
    provincia: local!provincia,
    tlfFijo: local!tlfFijo,
    tlfMovil: local!tlfMovil
  },
  local!companiaContraria: if(
    a!isNotNullOrEmpty(local!codCiaContraria),
    a!defaultValue(
      reject(
        fn!isnull,
        a!forEach(
          items: local!companias,
          expression: if(
            index(fv!item, 1, "") = local!codCiaContraria,
            a!map(
              codigo: index(fv!item, 1, ""),
              descripcion: index(fv!item, 2, ""),
              grupo: index(fv!item, 3, "")
            ),
            null
          )
        )
      ),
      index(
        local!datos,
        "codCiaContraria",
        index(local!basicos, "codCiaContraria", null)
      )
    ),
    local!seleccionCia
  ),
  /* modal Si/No (casos corredor/ilocalizables/telefónico/acuerdos) */
  local!mcaVentanaSiNo: false,
  local!caso,
  /* R10-B: resultado que devuelve SCA2_ContraAnulacionModalSiNo (mcaEstadoFinal 4 en corredor/ilocalizable, 8 posponer) */
  local!resultadoModal,
  /* R45-C D2: como SCA, los perfiles se calculan del subperfil/perfil del usuario (el DTO no trae estos campos) */
  local!codPerfilSi24Experto: index(local!usuario, "codSubPerfil", "") = cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO,
  local!codPerfilSi24Front: index(local!usuario, "codSubPerfil", "") = cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT,
  local!codPerfilGGE: a!defaultValue(local!codPerfil, "") = cons!SCA2_TXT_PERFIL_CE_MF_BK,
  local!llamarAGeneracionContactos: index(
    local!usuario,
    "llamarAGeneracionContactos",
    false
  ),
  /* Paridad SCA_ContraAnulacionOpciones: clase de agente de la estructura comercial de la póliza (Autos/Hogar); el record Datos Productor no la almacena */
  local!codClaseAgt: a!defaultValue(
    index(
      index(local!sol, "datosPolizaAutos", {}),
      "estructuracomercialCodclaseagente",
      null
    ),
    a!defaultValue(
      index(
        index(local!sol, "datosPolizaHogar", {}),
        "estructuracomercialCodclaseagente",
        null
      ),
      index(local!datosProductor, "codclaseagt", "")
    )
  ),
  local!codAcuerdo: a!defaultValue(
    index(
      index(local!sol, "datosPolizaAutos", {}),
      "acuerdo",
      null
    ),
    index(
      index(local!sol, "datosPolizaHogar", {}),
      "acuerdo",
      ""
    )
  ),
  /* Paridad SCA_ContraAnulacionOpcionesEstrategicas local!isAcuerdoSi24 */
  local!isAcuerdoSi24: or(
    tostring(local!codClaseAgt) = "33",
    tostring(local!codClaseAgt) = "56",
    tostring(local!codClaseAgt) = "97",
    tostring(local!codClaseAgt) = "49",
    tostring(local!codClaseAgt) = "80",
    tostring(local!codClaseAgt) = "69",
    tostring(local!codAcuerdo) = "10037931",
    tostring(local!codAcuerdo) = "10038616",
    tostring(local!codAcuerdo) = "10016396",
    tostring(local!codAcuerdo) = "10039853",
    tostring(local!codAcuerdo) = "10039807",
    tostring(local!codAcuerdo) = "10043565",
    tostring(local!codAcuerdo) = "10047605",
    tostring(local!codAcuerdo) = "10047612",
    tostring(local!codAcuerdo) = "10048093",
    tostring(local!codAcuerdo) = "10048133",
    tostring(local!codAcuerdo) = "10013971"
  ),
  /* R9-C B7-acuerdos: póliza de acuerdo en nivel 1 con usuario Red Mapfre (CE_RM): sólo aviso (texto provisional, pendiente del analista). Sin bloqueo de botones: el salto a SI24 lo decide el motor (RCI) */
  local!bloqueoAcuerdoRedMapfre: and(
    local!isAcuerdoSi24,
    local!codPerfil = cons!SCA2_TXT_PERFIL_CE_RM,
    local!nivelIntervencion = 1
  ),
  /* R11 #9 (analista): si el gestor es SI24 y la póliza es de acuerdos, al motor va anulaExperto = true; el resto conserva la marca del productor */
  local!esSi24Gestor: rule!SCA2_datosPerfilesPcaSi24(
    codPerfil: a!defaultValue(local!codPerfil, ""),
    codSubPerfil: a!defaultValue(
      index(local!usuario, "codSubPerfil", ""),
      ""
    )
  ),
  local!anulaExpertosMotor: if(
    and(local!esSi24Gestor, local!isAcuerdoSi24),
    true,
    local!anulaExpertos
  ),
  local!esCCC: or(
    local!codPerfil = cons!SCA2_TXT_PERFIL_CE_MF_RECIBOS,
    index(local!usuario, "codSubPerfil", "") = cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC,
    index(local!usuario, "codSubPerfil", "") = cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR
  ),
  /* R20 #3 (analista): SI24 + póliza de acuerdos también envía anulaTecnico = true al motor */
  local!anulaTecnicosMotor: if(
    or(
      local!esCCC,
      and(local!esSi24Gestor, local!isAcuerdoSi24)
    ),
    true,
    local!anulaTecnicos
  ),
  /* R45-C C1/C3 y R46-C (analista): el aviso de póliza de acuerdo SI24 no se muestra a SI24/GGE, central, CCC ni en nivel > 1 */
  local!tratadaPorSi24: or(
    local!esSi24Gestor,
    local!codPerfil = cons!SCA2_TXT_PERFIL_CE_MF_BK,
    local!codPerfil = cons!SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT,
    local!esCCC,
    a!defaultValue(local!nivelIntervencion, 1) > 1
  ),
  /* R46-C (analista «no sólo Red Mapfre»): como SCA_ContraAnulacionOpcionesEstrategicas, sólo GGE, SI24 experto y SI24 front finalizan sin carta */
  local!finalizarSinDocumentos: or(
    local!codPerfilGGE,
    local!codPerfilSi24Experto,
    local!codPerfilSi24Front
  ),
  local!hayArgNegativo: if(
    a!isNullOrEmpty(local!estadoArgumentos),
    false,
    or(
      a!forEach(
        items: local!estadoArgumentos,
        expression: index(
          cons!SCA2_TXT_ESTADO_ARGUMENTO,
          tointeger(a!defaultValue(fv!item, "0")) + 1,
          ""
        ) = index(cons!SCA2_TXT_ESTADO_ARGUMENTO, 3, null)
      )
    )
  ),
  local!telefonicaTelematica: index(local!datosProductor, "estele", false),
  local!mcaIlocalizables: index(
    local!datosProductor,
    "mcailocalizables",
    false
  ),
  local!resultado,
  local!idArgumento,
  local!dataRecuperacion: a!map(
    numPoliza: local!numPoliza,
    codSolicitud: ri!idSolicitud,
    codGestion: local!codGestion,
    nivelIntervencion: local!nivelIntervencion,
    codCia: local!codCiaUsuario,
    codCiaUsuario: local!codCiaUsuario,
    nuuma: local!nuuma,
    codPerfil: local!codPerfil,
    codSubPerfil: index(local!data, "codSubPerfil", ""),
    codDetalle: index(local!datos, "coddetalle", ""),
    canalEntrada: index(local!datos, "canalentrada", ""),
    codMotivo: index(local!datos, "codmotivo", ""),
    codCausa: index(local!datos, "codcausa", ""),
    tipoCatalogacion: local!catalogacion,
    mecanizada: a!defaultValue(
      index(
        local!estado,
        "mecanizacionRealizada",
        null
      ),
      false
    ),
    numDoc: local!nifTomadorCalc,
    observaciones: local!observaciones,
    lineaNegocio: local!lineaNegocio,
    codTipoArgumento: index(
      local!argumentoSeleccionado,
      "codTipoArgumento",
      ""
    ),
    observacionesArgumento: index(
      local!argumentoSeleccionado,
      "observaciones",
      ""
    ),
    impCiaContra: index(
      local!argumentoSeleccionado,
      "impCiaContra",
      null
    ),
    numTipBon: index(
      local!argumentoSeleccionado,
      "numTipBon",
      null
    ),
    codTipBon: index(
      local!argumentoSeleccionado,
      "codTipBon",
      null
    ),
    codCampania: index(
      local!argumentoSeleccionado,
      "codIdCampana",
      null
    ),
    /* Paridad SCA: datos de campaña/regateo que consume el modal (gestionarTTQ, executeAsignar, asignarSVA) */
    mcaTeCuidamos: local!mcaClienteTeCuidamos,
    tuTeQuedas: local!tuTeQuedas,
    fecVencimiento: local!fecVencimientoPoliza,
    numBonAplic: if(
      a!isNullOrEmpty(local!numBonAplic),
      index(
        local!argumentoSeleccionado,
        "numTipBon",
        null
      ),
      local!numBonAplic
    ),
    svaElegido: local!SVAElegido,
    obsServicioAplicado: local!obsServicioAplicado,
    email: local!email,
    mcaPropietarioPoliza: local!mcaPropietarioPoliza,
    claveProduccion: local!claveProduccion,
    argumentoEconomico: index(
      local!argumentoSeleccionado,
      "mcaEconomico",
      null
    ),
    descTipoArgumento: index(
      local!argumentoSeleccionado,
      "descTipoArgumento",
      null
    ),
    mcaEstadoFinal: local!estadoContraAnul,
    anulaExpertos: local!anulaExpertosMotor,
    anulaTecnicos: local!anulaTecnicosMotor
  ),
  {
    /* Aviso póliza de acuerdos SI24 (paridad SCA_ContraAnulacionOpcionesEstrategicas, encima del marco Contra anulación) */
    a!cardLayout(
      contents: {
        a!sideBySideLayout(
          items: {
            a!sideBySideItem(
              item: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: a!richTextIcon(
                  icon: "info-circle",
                  color: cons!SCA2_VAL_COLOR_AZUL_CLARO,
                  size: "MEDIUM"
                )
              ),
              width: "MINIMIZE"
            ),
            a!sideBySideItem(
              item: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: if(
                  local!bloqueoAcuerdoRedMapfre,
                  "Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24. No es posible anularla desde esta pantalla.",
                  "Esta poliza es de un acuerdo que trata SI24. La retención o anulación de la póliza se trasladara al SI24"
                )
              )
            )
          },
          alignVertical: "MIDDLE"
        )
      },
      style: "WARN",
      accessibilityText: "Information message",
      marginBelow: "STANDARD",
      showWhen: and(local!isAcuerdoSi24, not(local!tratadaPorSi24))
    ),
    a!cardLayout(
      contents: {
        /* Título (paridad SCA_ContraAnulacionOpcionesEstrategicas) */
        a!cardLayout(
          contents: a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: a!richTextItem(
              text: "Contra anulación",
              linkStyle: "STANDALONE",
              color: cons!SCA2_VAL_COLOR_NEGRO,
              size: "MEDIUM",
              style: "STRONG"
            )
          ),
          padding: "STANDARD",
          showBorder: false
        ),
        a!horizontalLine(
          marginAbove: "NONE",
          marginBelow: "STANDARD"
        ),
        a!cardLayout(
          contents: {
            rule!SCA2_selectorOficinas(
              detalleOficina: local!detalleOficina,
              oficinas: local!oficinas
            ),
            a!horizontalLine(
              marginAbove: "STANDARD",
              marginBelow: "STANDARD"
            )
          },
          showWhen: local!masDeUnaOficina,
          showBorder: false
        ),
        /* Compañía contraria y catalogación */
        a!cardLayout(
          contents: {
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: {
                a!richTextIcon(
                  icon: if(
                    not(local!collapse1),
                    "chevron-right",
                    "chevron-down"
                  ),
                  color: cons!SCA2_VAL_COLOR_NEGRO
                ),
                char(32),
                a!richTextItem(
                  text: "Compañía contraria y catalogación",
                  linkStyle: "STANDALONE",
                  color: cons!SCA2_VAL_COLOR_NEGRO,
                  size: "STANDARD",
                  style: "STRONG"
                )
              }
            )
          },
          link: a!dynamicLink(
            saveInto: {
              a!save(local!collapse1, not(local!collapse1))
            }
          ),
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        a!horizontalLine(showWhen: local!collapse1),
        a!cardLayout(
          contents: rule!SCA2_ContraAnulacionCompaniaCatalogacion(
            showPopup: local!showPopup,
            compania: local!companiaContraria,
            tipoCatalogacion: if(
              if(
                cons!SCA2_USAR_POLIZA_RENOVADA_UNICA,
                local!polizaRenovada,
                rule!SCA2_polizaRenovada(poliza: local!numPoliza)
              ) = true,
              index(
                local!datos,
                "catalogacion",
                local!catalogacion
              ),
              local!catalogacion
            ),
            fechaAnulacion: local!fechaAnulacion,
            solicitud: ri!idSolicitud,
            listaArgumentos: local!respArgumentario,
            argumentoSeleccionado: local!argumentoSeleccionado,
            indiceArgumentoSeleccionado: local!indiceArgSeleccionado,
            activoPanCatalogacion: local!activarPanCatalogacion,
            codCiaContraria: local!codCiaContraria,
            data: local!data
          ),
          showWhen: local!collapse1,
          padding: "STANDARD",
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        /* Acciones contra anulación */
        a!cardLayout(
          contents: {
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: {
                a!richTextIcon(
                  icon: if(
                    not(local!collapse2),
                    "chevron-right",
                    "chevron-down"
                  ),
                  color: cons!SCA2_VAL_COLOR_NEGRO
                ),
                char(32),
                a!richTextItem(
                  text: "Acciones contra anulación",
                  linkStyle: "STANDALONE",
                  color: cons!SCA2_VAL_COLOR_NEGRO,
                  size: "STANDARD",
                  style: "STRONG"
                )
              }
            )
          },
          link: a!dynamicLink(
            saveInto: {
              a!save(local!collapse2, not(local!collapse2))
            }
          ),
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        a!horizontalLine(showWhen: local!collapse2),
        a!cardLayout(
          contents: {
            rule!SCA2_ContraAnulacionArgumentarioEstrategicas(
              listaArgumentos: local!listaArgumentos,
              numArgAnteriores: local!numArgAnteriores,
              argumentoSeleccionado: local!argumentoSeleccionado,
              indiceArgumentoSeleccionado: local!indiceArgSeleccionado,
              obligatoriosEjecutados: local!obligEjecu,
              estadoArgumentos: local!estadoArgumentos,
              usuarioArgumentos: local!usuarioArgumentos,
              fecEjecucionArgumentos: local!fecEjecucionArgumentos,
              deducciones: local!deducciones,
              mcaDeducciones: local!mcaDeducciones,
              numPoliza: local!numPoliza,
              tipoPoliza: local!origenPoliza,
              data: local!data,
              documento: local!documento
            ),
            a!buttonLayout(
              primaryButtons: {
                a!buttonWidget(
                  label: "POSITIVO",
                  color: cons!SCA2_VAL_COLOR_ROJO,
                  saveInto: {
                    a!save(local!return, false),
                    a!save(
                      local!estadoArgumentos[local!indiceArgSeleccionado],
                      "1"
                    ),
                    a!save(local!tipoArgumentoVariable, 0),
                    a!save(local!obsServicioAplicado, null),
                    a!save(
                      local!idArgumento,
                      index(
                        local!argumentoSeleccionado,
                        "codTipoArgumento",
                        null
                      )
                    ),
                    {
                      if(
                        local!activarPanCatalogacion,
                        a!save(
                          local!resultado,
                          rule!SCA2_modificarCatalogacionCodCiaCntrAnul(
                            solicitud: ri!idSolicitud,
                            ciaContraria: index(local!companiaContraria, "codigo", ""),
                            fechaAnulacion: local!fechaAnulacion,
                            tipoCatalogacion: local!catalogacion
                          )
                        ),
                        null
                      ),
                      a!save(local!estadoContraAnul, "3"),
                      /* Regateo: tréboles / retos / SVA */
                      if(
                        local!esRegateable,
                        if(
                          local!tuTeQuedas,
                          {
                            a!save(local!tipoArgumentoVariable, 1),
                            a!save(local!mcaVentanaRegateo, true)
                          },
                          if(
                            contains(
                              { 252, 254, 365 },
                              tointeger(
                                index(
                                  local!argumentoSeleccionado,
                                  "codTipoArgumento",
                                  0
                                )
                              )
                            ),
                            if(
                              a!isNotNullOrEmpty(local!SVADisponibles),
                              {
                                a!save(local!tipoArgumentoVariable, 3),
                                a!save(
                                  local!SVAElegido,
                                  index(
                                    local!SVADisponibles,
                                    1,
                                    "codAccion",
                                    null
                                  )
                                ),
                                a!save(local!mcaVentanaSVADisponibles, true)
                              },
                              null
                            ),
                            if(
                              contains(
                                { "286", "287" },
                                tostring(
                                  index(
                                    local!argumentoSeleccionado,
                                    "codTipoArgumento",
                                    ""
                                  )
                                )
                              ),
                              {
                                a!save(local!tipoArgumentoVariable, 2),
                                a!save(local!mcaVentanaRetos, true)
                              },
                              null
                            )
                          )
                        ),
                        null
                      ),
                      /* Recuperación / rehabilitación de póliza */
                      if(
                        rule!SCA2_obtenerEstadoPoliza(numPoliza: local!numPoliza) = "A",
                        {
                          a!save(local!comprobarSolicitud, true),
                          a!save(
                            local!respuesta,
                            rule!SCA2_altaSGORehabilitar(
                              nif: index(local!data, "numDoc", ""),
                              poliza: local!numPoliza,
                              cliente: index(local!data, "numDoc", ""),
                              codApp: "01",
                              nuuma: local!nuuma,
                              matricula: "",
                              telefonoContacto: index(local!data, "telefono", ""),
                              oficinaDirecta: index(local!data, "oficinaDirecta", ""),
                              numSolicitud: ri!idSolicitud
                            )
                          ),
                          a!save(
                            local!mensajeInfo,
                            if(
                              local!respuesta = true,
                              "¡Enhorabuena en la retención de la póliza! Se va a generar un SGO para gestionar el desmarcado de la anulación de esta póliza. Podrá hacer el seguimiento de esta gestión en su bandeja de gestiones de SGO.",
                              "La póliza está anulada, debe proceder a su operativa habitual para gestionar la rehabilitación de la póliza. ¿Desea continuar?"
                            )
                          ),
                          a!save(local!mcaVentanaRecuperacion, true)
                        },
                        {
                          a!save(
                            local!mensajeInfo,
                            "¡Enhorabuena en la retención de la póliza! Se van a finalizar las acciones de contra anulación en SCA. ¿Desea continuar?"
                          ),
                          a!save(local!mcaVentanaRecuperacion, true)
                        }
                      ),
                      /* Descuentos por vinculación/retención (SGO) */
                      if(
                        contains(
                          { "358", "356" },
                          tostring(
                            index(
                              local!argumentoSeleccionado,
                              "codTipoArgumento",
                              ""
                            )
                          )
                        ),
                        {
                          a!save(
                            local!respuesta,
                            if(
                              and(local!flagVida, local!polizaVida),
                              rule!SCA2_altaSGOVida(
                                nif: index(local!data, "numDoc", ""),
                                poliza: local!numPoliza,
                                cliente: index(local!data, "numDoc", ""),
                                codApp: "01",
                                nuuma: local!nuuma,
                                matricula: "",
                                telefonoContacto: index(local!data, "telefono", ""),
                                numSolicitud: ri!idSolicitud,
                                observaciones: if(
                                  index(
                                    local!argumentoSeleccionado,
                                    "codTipoArgumento",
                                    ""
                                  ) = "358",
                                  "DESCUENTO POR VINCULACIÓN",
                                  "DESCUENTO POR RETENCIÓN"
                                )
                              ),
                              rule!SCA2_altaSGO(
                                nif: index(local!data, "numDoc", ""),
                                poliza: local!numPoliza,
                                cliente: index(local!data, "numDoc", ""),
                                codApp: "01",
                                nuuma: local!nuuma,
                                matricula: "",
                                telefonoContacto: index(local!data, "telefono", ""),
                                oficinaDirecta: index(local!data, "oficinaDirecta", ""),
                                numSolicitud: ri!idSolicitud,
                                observaciones: if(
                                  index(
                                    local!argumentoSeleccionado,
                                    "codTipoArgumento",
                                    ""
                                  ) = "358",
                                  "DESCUENTO POR VINCULACIÓN",
                                  "DESCUENTO POR RETENCIÓN"
                                ),
                                idTarea: "1134"
                              )
                            )
                          ),
                          a!save(
                            local!mensajeInfo,
                            if(
                              local!respuesta = true,
                              "¡Enhorabuena se ha generado el SGO correctamente!",
                              "No se ha generado el SGO, por favor contacte con el SAU"
                            )
                          ),
                          a!save(local!mcaVentanaRecuperacion, true)
                        },
                        null
                      )
                    }
                  },
                  disabled: or(
                    a!isNullOrEmpty(local!argumentoSeleccionado),
                    not(
                      or(
                        index(
                          local!estadoArgumentos,
                          local!indiceArgSeleccionado,
                          ""
                        ) = "0",
                        index(
                          local!listaArgumentos,
                          local!indiceArgSeleccionado,
                          "codTipEstArgumento",
                          ""
                        ) = "99"
                      )
                    ),
                    local!mayorOrdenObligNoEjecutados,
                    and(
                      local!obligEjecu = false,
                      index(
                        local!listaArgumentos,
                        local!indiceArgSeleccionado,
                        "mcaObligatorio",
                        ""
                      ) = "N"
                    ),
                    tointeger(
                      index(
                        local!listaArgumentos,
                        local!indiceArgSeleccionado,
                        "nivelArgumento",
                        ""
                      )
                    ) < local!nivelIntervencion
                  ),
                  tooltip: if(
                    a!isNullOrEmpty(local!argumentoSeleccionado),
                    "Debe seleccionarse 1 argumento",
                    if(
                      not(
                        or(
                          index(
                            local!estadoArgumentos,
                            local!indiceArgSeleccionado,
                            ""
                          ) = "0",
                          index(
                            local!listaArgumentos,
                            local!indiceArgSeleccionado,
                            "codTipEstArgumento",
                            ""
                          ) = "99"
                        )
                      ),
                      "El argumento no puede volver a ejecutarse",
                      if(
                        and(
                          local!obligEjecu = false,
                          index(
                            local!listaArgumentos,
                            local!indiceArgSeleccionado,
                            "mcaObligatorio",
                            ""
                          ) = "N"
                        ),
                        "Deben ejecutarse los argumentos obligatorios previamente",
                        if(
                          local!mayorOrdenObligNoEjecutados,
                          "Hay argumentos obligatorios de mayor prioridad que no han sido ejecutados",
                          ""
                        )
                      )
                    )
                  )
                ),
                a!buttonWidget(
                  label: "NEGATIVO",
                  color: cons!SCA2_VAL_COLOR_ROJO,
                  saveInto: {
                    if(
                      a!isNotNullOrEmpty(local!argumentoSeleccionado),
                      a!save(
                        local!resultado,
                        rule!SCA2_guardarEjecuArg(
                          ejecucionArgDTO: a!map(
                            codCContraria: index(local!companiaContraria, "codigo", ""),
                            codGestion: local!codGestion,
                            codSolicitud: ri!idSolicitud,
                            codTipoArgumento: index(
                              local!argumentoSeleccionado,
                              "codTipoArgumento",
                              ""
                            ),
                            codTipoNegocio: a!defaultValue(
                              index(local!estado, "lineaNegocio", null),
                              ""
                            ),
                            infoUsuario: a!map(
                              codCiaUsuario: "41",
                              nuuma: local!nuuma,
                              codPerfil: local!codPerfil,
                              codSubPerfil: index(local!data, "codSubPerfil", "")
                            ),
                            mcaResultado: "2",
                            observaciones: index(
                              local!argumentoSeleccionado,
                              "observaciones",
                              ""
                            ),
                            precio: index(
                              local!argumentoSeleccionado,
                              "infoCiaContraria",
                              "impCiaContra",
                              ""
                            )
                          )
                        )
                      ),
                      null
                    ),
                    {
                      a!save(
                        local!estadoArgumentos[local!indiceArgSeleccionado],
                        "2"
                      ),
                      a!save(
                        local!fecEjecucionArgumentos[local!indiceArgSeleccionado],
                        concat(
                          datetext(today(), "yyyy-MM-dd"),
                          " ",
                          text(now(), "HH:MM:SS")
                        )
                      ),
                      a!save(
                        local!usuarioArgumentos[local!indiceArgSeleccionado],
                        local!nuuma
                      )
                    }
                  },
                  disabled: or(
                    a!isNullOrEmpty(local!argumentoSeleccionado),
                    not(
                      or(
                        index(
                          local!estadoArgumentos,
                          local!indiceArgSeleccionado,
                          ""
                        ) = "0",
                        index(
                          local!listaArgumentos,
                          local!indiceArgSeleccionado,
                          "codTipEstArgumento",
                          ""
                        ) = "99"
                      )
                    ),
                    local!mayorOrdenObligNoEjecutados,
                    and(
                      local!obligEjecu = false,
                      index(
                        local!listaArgumentos,
                        local!indiceArgSeleccionado,
                        "mcaObligatorio",
                        ""
                      ) = "N"
                    ),
                    tointeger(
                      index(
                        local!listaArgumentos,
                        local!indiceArgSeleccionado,
                        "nivelArgumento",
                        ""
                      )
                    ) < local!nivelIntervencion
                  ),
                  tooltip: if(
                    a!isNullOrEmpty(local!argumentoSeleccionado),
                    "Debe seleccionarse 1 argumento",
                    if(
                      not(
                        or(
                          index(
                            local!estadoArgumentos,
                            local!indiceArgSeleccionado,
                            ""
                          ) = "0",
                          index(
                            local!listaArgumentos,
                            local!indiceArgSeleccionado,
                            "codTipEstArgumento",
                            ""
                          ) = "99"
                        )
                      ),
                      "El argumento no puede volver a ejecutarse",
                      if(
                        and(
                          local!obligEjecu = false,
                          index(
                            local!listaArgumentos,
                            local!indiceArgSeleccionado,
                            "mcaObligatorio",
                            ""
                          ) = "N"
                        ),
                        "Deben ejecutarse los argumentos obligatorios previamente",
                        if(
                          local!mayorOrdenObligNoEjecutados,
                          "Hay argumentos obligatorios de mayor prioridad que no han sido ejecutados",
                          ""
                        )
                      )
                    )
                  )
                )
              },
              showWhen: local!mcaDeducciones = false
            )
          },
          showWhen: local!collapse2,
          padding: "STANDARD",
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        /* Documentación */
        a!cardLayout(
          contents: {
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: {
                a!richTextIcon(
                  icon: if(
                    not(local!collapse3),
                    "chevron-right",
                    "chevron-down"
                  ),
                  color: cons!SCA2_VAL_COLOR_NEGRO
                ),
                char(32),
                a!richTextItem(
                  text: "Documentación",
                  linkStyle: "STANDALONE",
                  color: cons!SCA2_VAL_COLOR_NEGRO,
                  size: "STANDARD",
                  style: "STRONG"
                )
              }
            )
          },
          link: a!dynamicLink(
            saveInto: {
              a!save(local!collapse3, not(local!collapse3))
            }
          ),
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        a!horizontalLine(showWhen: local!collapse3),
        a!cardLayout(
          contents: rule!SCA2_AccionesAdministrativasDocumentacion(
            oficinaSeleccionada: local!oficinaSeleccionada,
            flecha: local!flecha,
            codSolicitud: ri!idSolicitud,
            noEntregaDoc: local!noEntregaDoc,
            observaciones: local!observaciones,
            listaDocumentos: local!listaDocumentos,
            documentosOk: local!documentosOk,
            causa: index(local!datos, "desccausa", ""),
            listaNombreDocs: local!listaNombreDocs,
            documentosACargar1: local!documentosACargar1,
            documentosACargar2: local!documentosACargar2,
            documentosACargar3: local!documentosACargar3,
            documentosACargar4: local!documentosACargar4,
            documentosACargar5: local!documentosACargar5,
            documentosACargar6: local!documentosACargar6,
            documentosACargar7: local!documentosACargar7,
            documentosACargar8: local!documentosACargar8,
            idCartaFirmada: local!idCartaFirmada,
            accion: "2",
            infoPlantilla: local!infoPlantilla,
            plantillaCarta: local!plantillaCarta,
            mcaVisualizarDoc: local!mcaVentanaVisualizarDoc,
            yaImpreso: local!yaImpreso,
            dniOK: local!dniAdjunto,
            cartaFirmadaOK: local!cartaAdjunta,
            listadoMostrar: local!listadoMostrar,
            origenPoliza: local!origenPoliza
          ),
          showWhen: local!collapse3,
          padding: "STANDARD",
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        ),
        a!horizontalLine(color: cons!SCA2_VAL_COLOR_BLANCO),
        a!cardLayout(
          contents: {
            a!buttonLayout(
              primaryButtons: {
                a!buttonWidget(
                  label: "REVISIÓN",
                  color: cons!SCA2_VAL_COLOR_ROJO,
                  style: "GHOST",
                  submit: true,
                  confirmMessage: "Para anular a una fecha correspondiente a un periodo anterior, tiene que solicitar permiso a su director de oficina. Cuando éste se lo dé, genere un SGO al CCR con la evidencia (correo electrónico, documento, etc.) de dicho permiso. Pulse 'Aceptar' si va a solicitar el permiso, 'Cancelar' para volver a la contra anulación",
                  confirmButtonLabel: "Aceptar",
                  cancelButtonLabel: "Cancelar",
                  saveInto: {
                    a!save(
                      local!resultado,
                      a!map(
                        nivelIntervencion: local!nivelIntervencion,
                        codSolicitud: ri!idSolicitud,
                        codTipoArgumento: index(
                          local!argumentoSeleccionado,
                          "codTipoArgumento",
                          null
                        ),
                        mcaEstadoFinal: "6",
                        estadoFinalizar: "6",
                        observaciones: local!observaciones,
                        datosPerfilesPca: a!map(
                          codCompania: "41",
                          codPerfil: local!codPerfil,
                          codSubPerfil: index(local!data, "codSubPerfil", ""),
                          nuuma: local!nuuma
                        ),
                        anulaExpertos: local!anulaExpertos,
                        anulaTecnicos: local!anulaTecnicosMotor
                      )
                    ),
                    if(
                      a!isNullOrEmpty(local!listaNombreDocs),
                      a!startProcess(
                        processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                        processParameters: {
                          idSolicitud: ri!idSolicitud,
                          idTarea: ri!idTarea,
                          resultado: a!map(
                            listaNombreDocs: local!listaNombreDocs,
                            tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                            /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                              index(
                                local!resultadoModal,
                                "anulaExpertos",
                                null
                              ),
                              local!anulaExpertosMotor
                            ),
                            anulaTecnicos: a!defaultValue(
                              index(
                                local!resultadoModal,
                                "anulaTecnicos",
                                null
                              ),
                              local!anulaTecnicosMotor
                            ),
                            nuuma: local!nuuma,
                            mcaFisicoJuridico: local!mcaFisicoJuridico,
                            mcaEstadoFinal: "6",
                            estadoFinalizar: "6",
                            codTipoArgumento: index(
                              local!argumentoSeleccionado,
                              "codTipoArgumento",
                              null
                            ),
                            observaciones: local!observaciones
                          )
                        },
                        onSuccess: a!save(ri!onCompletar, true),
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: a!save(ri!onCompletar, true)
                      ),
                      a!submitUploadedFiles(
                        onSuccess: a!startProcess(
                          processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                          processParameters: {
                            idSolicitud: ri!idSolicitud,
                            idTarea: ri!idTarea,
                            resultado: a!map(
                              listaNombreDocs: local!listaNombreDocs,
                              tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                              /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                                index(
                                  local!resultadoModal,
                                  "anulaExpertos",
                                  null
                                ),
                                local!anulaExpertosMotor
                              ),
                              anulaTecnicos: a!defaultValue(
                                index(
                                  local!resultadoModal,
                                  "anulaTecnicos",
                                  null
                                ),
                                local!anulaTecnicosMotor
                              ),
                              nuuma: local!nuuma,
                              mcaFisicoJuridico: local!mcaFisicoJuridico,
                              mcaEstadoFinal: "6",
                              estadoFinalizar: "6",
                              codTipoArgumento: index(
                                local!argumentoSeleccionado,
                                "codTipoArgumento",
                                null
                              ),
                              observaciones: local!observaciones
                            )
                          },
                          onSuccess: a!save(ri!onCompletar, true),
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: a!save(ri!onCompletar, true)
                        ),
                        onError: {
                          a!save(
                            local!mensajeInfo,
                            "No se han podido guardar los documentos adjuntos (" & tostring(fv!error) & "). Vuelva a adjuntarlos antes de continuar."
                          ),
                          a!save(local!mcaVentanaInfo, true)
                        }
                      )
                    )
                  },
                  disabled: if(
                    and(
                      or(
                        a!isNullOrEmpty(local!numArgEjec),
                        local!numArgEjec = 0
                      ),
                      not(
                        or(local!noEntregaDoc, local!documentosOk)
                      )
                    ),
                    true,
                    false
                  ),
                  tooltip: if(
                    or(
                      a!isNullOrEmpty(local!numArgEjec),
                      local!numArgEjec = 0
                    ),
                    "Se ha de ejecutar al menos 1 argumento",
                    ""
                  ),
                  showWhen: local!mostrarRevision
                ),
                a!buttonWidget(
                  label: "FINALIZAR",
                  saveInto: {
                    /* Fase 1 lógica legacy (sesión B): sombra del propietario (actual vs legacy) en SCA2 Trazabilidad Cliente; tolerante a fallos, no altera la acción */
                    rule!SCA2_sombraPropietarioContraAnulacion(
                      codCia: "41",
                      nuuma: local!nuuma,
                      claveProd: a!defaultValue(
                        local!claveProduccion,
                        index(
                          index(local!sol, "datosPoliza", {}),
                          "claveproduccion",
                          ""
                        )
                      ),
                      idSolicitud: ri!idSolicitud,
                      numPoliza: local!numPoliza
                    ),
                    /* Observaciones no pueden superar los 999 caracteres (literal SCA) */
                    a!save(
                      local!return,
                      len(a!defaultValue(local!observaciones, "")) > 999
                    ),
                    if(
                      local!return,
                      {
                        a!save(
                          local!mensajeInfo,
                          "El campo de observaciones ha sobrepasado el límite de 999 caracteres"
                        ),
                        a!save(local!mcaVentanaInfo, true)
                      },
                      {
                        /* R10-B (paridad SCA_ContraAnulacionOpcionesEstrategicas): FINALIZAR abre el modal Sí/No (caso 1); el modal encadena corredor/ilocalizables/«¿insiste?» y, cuando SCA haría submit, invoca onFinalizar (CMD CompletarAccion) */
                        if(
                          or(
                            local!codPerfilSi24Experto,
                            local!codPerfilGGE
                          ),
                          a!save(local!mcaIlocalizables, true),
                          {}
                        ),
                        a!save(local!resultadoModal, null),
                        a!save(local!caso, 1),
                        a!save(
                          local!mensajeInfo,
                          "Se van a finalizar las acciones de contra anulación. ¿Desea continuar?"
                        ),
                        a!save(local!mcaVentanaSiNo, true)
                      }
                    )
                  },
                  submit: true,
                  style: "SOLID",
                  color: cons!SCA2_VAL_COLOR_ROJO,
                  /* R45-C C4: fuera de Red Mapfre basta un argumento negativo */
                  disabled: if(
                    local!finalizarSinDocumentos,
                    and(not(local!caFinalizadaCore), not(local!hayArgNegativo)),
                    if(
                    or(
                      and(
                        not(local!caFinalizadaCore),
                        or(
                          a!isNullOrEmpty(local!numArgEjec),
                          local!numArgEjec = 0
                        )
                      ),
                      and(
                        local!codPerfilGGE = false,
                        local!codPerfilSi24Experto = false,
                        local!codPerfilSi24Front = false,
                        local!mostrarDocumentacion,
                        local!yaImpreso = false,
                        not(
                          or(
                            local!cartaAdjunta,
                            and(local!cartaAdjunta, local!dniAdjunto)
                          )
                        )
                      )
                    ),
                    true,
                    if(
                      and(
                        local!codPerfilGGE = false,
                        local!codPerfilSi24Experto = false,
                        local!obligEjecu = false
                      ),
                      true,
                      false
                    )
                  )),
                  tooltip: if(
                    local!finalizarSinDocumentos,
                    if(
                      and(not(local!caFinalizadaCore), not(local!hayArgNegativo)),
                      "Se debe ejecutar al menos 1 argumento",
                      ""
                    ),
                    if(
                    and(
                      not(local!caFinalizadaCore),
                      or(
                        a!isNullOrEmpty(local!numArgEjec),
                        local!numArgEjec = 0
                      )
                    ),
                    "Se debe ejecutar al menos 1 argumento",
                    if(
                      and(
                        local!codPerfilGGE = false,
                        local!codPerfilSi24Experto = false,
                        local!codPerfilSi24Front = false,
                        local!obligEjecu = false
                      ),
                      "Quedan argumentos obligatorios por ejecutar",
                      if(
                        and(
                          local!codPerfilGGE = false,
                          local!codPerfilSi24Experto = false,
                          local!codPerfilSi24Front = false,
                          local!mostrarDocumentacion,
                          local!yaImpreso = false,
                          local!cartaAdjunta = false
                        ),
                        "Se ha de imprimir la plantilla de la carta firmada",
                        ""
                      )
                    )
                  )
                  ),
                  
                )
              },
              secondaryButtons: {
                a!buttonWidget(
                  label: "CANCELAR",
                  saveInto: {
                    a!startProcess(
                      processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                      processParameters: {
                        idSolicitud: ri!idSolicitud,
                        idTarea: ri!idTarea,
                        resultado: a!map(
                          /* Paridad SCA: CANCELAR cierra la gestión CA en CORE con mcaEstadoFinal 9 (Cancelada) y finaliza la solicitud */
                          tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                          /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                            index(
                              local!resultadoModal,
                              "anulaExpertos",
                              null
                            ),
                            local!anulaExpertosMotor
                          ),
                          anulaTecnicos: a!defaultValue(
                            index(
                              local!resultadoModal,
                              "anulaTecnicos",
                              null
                            ),
                            local!anulaTecnicosMotor
                          ),
                          nuuma: local!nuuma,
                          mcaFisicoJuridico: local!mcaFisicoJuridico,
                          mcaEstadoFinal: "9",
                          estadoFinalizar: "9",
                          finalizadoCA: true,
                          finalizarCAPca: a!map(
                            MSEFinalizarContraAnulPca: a!map(
                              mcaEstadoFinal: "9",
                              nivelIntervencion: local!nivelIntervencion,
                              codSolicitud: ri!idSolicitud,
                              infoUsuario: a!map(
                                codCiaUsuario: local!codCiaUsuario,
                                nuuma: local!nuuma,
                                codPerfil: local!codPerfil,
                                codSubPerfil: index(local!data, "codSubPerfil", "")
                              )
                            )
                          ),
                          observaciones: local!observaciones,
                          operacion: "CONTRAANULACION",
                          resultadoOperacion: "CANCELAR",
                          poliza: local!numPoliza,
                          cliente: local!idCliente,
                          tipoPersona: local!checksPECA,
                          perfilUsuario: index(
                            local!usuario,
                            "codSubPerfil",
                            index(
                              local!perfiles,
                              'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
                              null
                            )
                          )
                        )
                      },
                      onSuccess: {
                        if(
                          a!defaultValue(
                            index(fv!processInfo, "pv", "wrErr", null),
                            false
                          ),
                          {
                            a!save(
                              local!mensajeInfo,
                              "Se ha producido un error al cancelar la contra anulación: " & a!defaultValue(
                                index(fv!processInfo, "pv", "wrErrMsg", null),
                                ""
                              ) & ". El error queda registrado en la bandeja de errores para su relanzamiento."
                            ),
                            a!save(local!mcaVentanaInfo, true)
                          },
                          a!save(ri!onCompletar, true)
                        )
                      },
                      onIncomplete: {
                        a!save(
                          local!mensajeInfo,
                          "No se ha podido confirmar la cancelación de la contra anulación. Revise el estado de la solicitud o la bandeja de errores antes de volver a intentarlo."
                        ),
                        a!save(local!mcaVentanaInfo, true)
                      },
                      isSynchronous: true
                    )
                  },
                  submit: true,
                  style: "LINK",
                  color: cons!SCA2_VAL_COLOR_ROJO,
                  showWhen: index(
                    local!mostrarBotonesCancelarPosponer,
                    "mostrarBotonCancelar",
                    false
                  ),
                  confirmHeader: "¿Desea continuar?",
                  confirmMessage: "Va a proceder a cancelar la solicitud de contra anulación",
                  confirmButtonLabel: "ACEPTAR",
                  cancelButtonLabel: "CANCELAR"
                ),
                a!buttonWidget(
                  label: "POSPONER",
                  saveInto: {
                    /* Paridad SCA (POSPONER): persiste compañía contraria/fecha/catalogación en CORE antes de posponer */
                    if(
                      local!activarPanCatalogacion,
                      a!save(
                        local!resultado,
                        rule!SCA2_modificarCatalogacionCodCiaCntrAnul(
                          solicitud: ri!idSolicitud,
                          ciaContraria: index(local!companiaContraria, "codigo", ""),
                          fechaAnulacion: local!fechaAnulacion,
                          tipoCatalogacion: local!catalogacion
                        )
                      ),
                      null
                    ),
                    /* Paridad PM SCA Contra Anulación (Caducada? → Subir Docs Documentum BBDD → posponer Contra anulación):
                   el CMD da de alta la gestión SGC (finalizarContraAnulPca 2), inserta la observación y sube los adjuntos */
                    /* SCA relee compañía/catalogación de CORE al retomar; SCA2 las lee de su record: el CMD Posponer las persiste (idCompania/catalogacion/fecAnulacion) */
                    if(
                      or(
                        a!isNullOrEmpty(local!listaNombreDocs),
                        a!defaultValue(local!noEntregaDoc, false)
                      ),
                      a!startProcess(
                        processModel: cons!SCA2_PM_CMD_POSPONER,
                        processParameters: {
                          idSolicitud: ri!idSolicitud,
                          idTarea: ri!idTarea,
                          fechaDietario: todate(
                            rule!SCA2_obtenerCaducidadNivel(
                              codPerfil: local!codPerfil,
                              mecanizar: false,
                              fechaVencimiento: null,
                              nivel: "2"
                            )
                          ),
                          motivo: local!observaciones,
                          tipoAccion: cons!SCA2_TXT_TIPO_GESTION_CA,
                          tipoGestionObs: local!tipoGestion,
                          detalleOficina: local!detalleOficina,
                          listaNombreDocs: if(
                            a!defaultValue(local!noEntregaDoc, false),
                            {},
                            local!listaNombreDocs
                          ),
                          nuuma: local!nuuma,
                          idCompania: if(
                            a!isNullOrEmpty(
                              index(local!companiaContraria, "codigo", null)
                            ),
                            null,
                            tointeger(
                              index(
                                a!flatten(
                                  {
                                    index(local!companiaContraria, "codigo", null)
                                  }
                                ),
                                1,
                                null
                              )
                            )
                          ),
                          catalogacion: local!catalogacion,
                          fecAnulacion: local!fechaAnulacion
                        },
                        onSuccess: { a!save(ri!onCompletar, true) },
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: { a!save(ri!onCompletar, true) }
                      ),
                      a!submitUploadedFiles(
                        onSuccess: a!startProcess(
                          processModel: cons!SCA2_PM_CMD_POSPONER,
                          processParameters: {
                            idSolicitud: ri!idSolicitud,
                            idTarea: ri!idTarea,
                            fechaDietario: todate(
                              rule!SCA2_obtenerCaducidadNivel(
                                codPerfil: local!codPerfil,
                                mecanizar: false,
                                fechaVencimiento: null,
                                nivel: "2"
                              )
                            ),
                            motivo: local!observaciones,
                            tipoAccion: cons!SCA2_TXT_TIPO_GESTION_CA,
                            tipoGestionObs: local!tipoGestion,
                            detalleOficina: local!detalleOficina,
                            listaNombreDocs: if(
                              a!defaultValue(local!noEntregaDoc, false),
                              {},
                              local!listaNombreDocs
                            ),
                            nuuma: local!nuuma,
                            idCompania: if(
                              a!isNullOrEmpty(
                                index(local!companiaContraria, "codigo", null)
                              ),
                              null,
                              tointeger(
                                index(
                                  a!flatten(
                                    {
                                      index(local!companiaContraria, "codigo", null)
                                    }
                                  ),
                                  1,
                                  null
                                )
                              )
                            ),
                            catalogacion: local!catalogacion,
                            fecAnulacion: local!fechaAnulacion
                          },
                          onSuccess: { a!save(ri!onCompletar, true) },
  /* R42-A: síncrono; si Appian no lo completa en su límite (onIncomplete) se mantiene el sondeo de la espera */
  isSynchronous: true,
  onIncomplete: { a!save(ri!onCompletar, true) }
                        ),
                        onError: {
                          a!save(
                            local!mensajeInfo,
                            "No se han podido guardar los documentos adjuntos (" & tostring(fv!error) & "). Vuelva a adjuntarlos antes de continuar."
                          ),
                          a!save(local!mcaVentanaInfo, true)
                        }
                      )
                    )
                  },
                  style: "OUTLINE",
                  color: cons!SCA2_VAL_COLOR_ROJO,
                  submit: true,
                  showWhen: index(
                    local!mostrarBotonesCancelarPosponer,
                    "mostrarBotonPosponer",
                    false
                  ),
                  disabled: if(
                    and(
                      local!masDeUnaOficina = true,
                      a!isNullOrEmpty(local!detalleOficina)
                    ),
                    true,
                    false
                  ),
                  tooltip: if(
                    and(
                      local!masDeUnaOficina = true,
                      a!isNullOrEmpty(local!detalleOficina)
                    ),
                    "Se ha de seleccionar una de las oficinas",
                    ""
                  ),
                  confirmHeader: "¿Desea continuar?",
                  confirmMessage: "Se va a posponer la solicitud de contra anulación",
                  confirmButtonLabel: "ACEPTAR",
                  cancelButtonLabel: "CANCELAR"
                )
              }
            )
          },
          padding: "STANDARD",
          marginAbove: "NONE",
          marginBelow: "NONE",
          showBorder: false
        )
      },
      shape: "ROUNDED",
      padding: "NONE",
      marginAbove: "MORE",
      showShadow: true,
      /* Paridad SCA: el formulario se oculta mientras hay una ventana modal abierta */
      showWhen: and(
        not(a!defaultValue(local!showPopup, false)),
        not(
          a!defaultValue(local!mcaVentanaVisualizarDoc, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaRecuperacion, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaInfo, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaSiNo, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaRegateo, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaRetos, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaSVADisponibles, false)
        ),
        not(
          a!defaultValue(local!mcaVentanaEmail, false)
        ),
        not(
          a!defaultValue(local!showDescuentosVida, false)
        )
      )
    ),
    /* Ventana para buscar compañías contrarias (paridad SCA: se muestra sola mientras está abierta) */
    a!columnsLayout(
      columns: {
        a!columnLayout(),
        a!columnLayout(
          contents: a!cardLayout(
            contents: rule!SCA2_BuscarCompaniasContrarias(
              show: local!showPopup,
              seleccion: local!companiaContraria
            ),
            marginAbove: "EVEN_MORE",
            showBorder: false
          ),
          width: "WIDE_PLUS"
        ),
        a!columnLayout()
      },
      showWhen: a!defaultValue(local!showPopup, false)
    ),
    /* Traza cliente (sustituye al PM SCA_GUARDAR_TRAZABILIDAD, inexistente en SCA2) */
    a!richTextDisplayField(
      value: tostring(index(local!searchAPI, "clientId", null)) & tostring(local!mcaClienteTeCuidamos) & tostring(local!centroEmisor) & tostring(local!oficinaDirecta),
      showWhen: false
    ),
    /* Modales: regateo/SGO, rehabilitación, descuentos e informativos */
    rule!SCA2_ContraAnulacionSGO(
      mcaVentanaRegateo: local!mcaVentanaRegateo,
      mcaVentanaRetos: local!mcaVentanaRetos,
      mcaVentanaSVADisponibles: local!mcaVentanaSVADisponibles,
      mcaVentanaEmail: local!mcaVentanaEmail,
      maximo: local!maximo,
      tipoBonificacion: local!tipoBonificacion,
      numBonAplic: local!numBonAplic,
      SVADisponibles: local!SVADisponibles,
      svaElegido: local!SVAElegido,
      email: local!email,
      data: a!map(
        numDoc: index(local!data, "numDoc", ""),
        solicitud: ri!idSolicitud,
        codCampania: local!codCampana,
        trebolesRecomendados: index(
          local!arrayTrebolesRecomendados,
          local!indiceArgSeleccionado,
          null
        ),
        nuuma: local!nuuma,
        idCliente: local!idCliente
      ),
      dataServicio: local!dataRecuperacion,
      obsServicioAplicado: local!obsServicioAplicado,
      tipoArgumentoVariable: local!tipoArgumentoVariable,
      return: local!return,
      mensajeInfo: local!mensajeInfo,
      mcaVentanaInfo: local!mcaVentanaInfo,
      mcaSVADisponiblesEjecutado: local!mcaSVADisponiblesEjecutado,
      mcaVentanaRecuperacion: local!mcaVentanaRecuperacion,
      estadoArgumentos: local!estadoArgumentos,
      indiceArgumentoSeleccionado: local!indiceArgSeleccionado
    ),
    /* Paridad SCA: la ventana de recuperación no se muestra mientras está abierto un modal de regateo/retos/SVA/correo */
    if(
      and(
        or(
          local!mcaVentanaRecuperacion,
          local!mcaVentanaInfo,
          a!isNotNullOrEmpty(local!urlNSE)
        ),
        not(local!mcaVentanaRegateo),
        not(local!mcaVentanaRetos),
        not(local!mcaVentanaSVADisponibles),
        not(local!mcaVentanaEmail)
      ),
      rule!SCA2_ContraAnulacionRehabilitacion(
        mcaVentanaRecuperacion: local!mcaVentanaRecuperacion,
        mensaje: local!mensajeInfo,
        /* Paridad SCA: el modal recibe el argumento seleccionado y el contexto CORE para guardarEjecuArg/finalizar */
        data: local!dataRecuperacion,
        anulada: a!defaultValue(local!comprobarSolicitud, false),
        datosContraAnulacion: local!resultado,
        positiva: local!estadoContraAnul = "3",
        estadoArgumentos: local!estadoArgumentos,
        indiceArgumentoSeleccionado: local!indiceArgSeleccionado,
        return: local!return,
        urlNSE: local!urlNSE,
        mcaVentanaInfo: local!mcaVentanaInfo,
        /* Cierre positivo integrado (paridad SCA: el submit del modal finaliza la contra anulación con mcaEstadoFinal 3) */
        onFinalizarPositivo: {
          if(
            a!isNullOrEmpty(local!listaNombreDocs),
            a!startProcess(
              processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
              processParameters: {
                idSolicitud: ri!idSolicitud,
                idTarea: ri!idTarea,
                resultado: a!map(
                  listaNombreDocs: local!listaNombreDocs,
                  tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                  /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                    index(
                      local!resultadoModal,
                      "anulaExpertos",
                      null
                    ),
                    local!anulaExpertosMotor
                  ),
                  anulaTecnicos: a!defaultValue(
                    index(
                      local!resultadoModal,
                      "anulaTecnicos",
                      null
                    ),
                    local!anulaTecnicosMotor
                  ),
                  nuuma: local!nuuma,
                  mcaFisicoJuridico: local!mcaFisicoJuridico,
                  mcaEstadoFinal: "3",
                  estadoFinalizar: "3",
                  finalizadoCA: true,
                  finalizarCAPca: a!map(
                    MSEFinalizarContraAnulPca: a!map(
                      mcaEstadoFinal: "3",
                      nivelIntervencion: local!nivelIntervencion,
                      codSolicitud: ri!idSolicitud,
                      infoUsuario: a!map(
                        codCiaUsuario: local!codCiaUsuario,
                        nuuma: local!nuuma,
                        codPerfil: local!codPerfil,
                        codSubPerfil: index(local!data, "codSubPerfil", "")
                      )
                    )
                  ),
                  ciaContraria: local!ciaContraria,
                  catalogacion: local!catalogacion,
                  observaciones: local!observaciones,
                  operacion: "CONTRAANULACION",
                  resultadoOperacion: "OK",
                  poliza: local!numPoliza,
                  cliente: local!idCliente,
                  tipoPersona: local!checksPECA,
                  perfilUsuario: index(
                    local!usuario,
                    "codSubPerfil",
                    index(
                      local!perfiles,
                      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
                      null
                    )
                  )
                )
              },
              onSuccess: {
                if(
                  a!defaultValue(
                    index(fv!processInfo, "pv", "wrErr", null),
                    false
                  ),
                  {
                    a!save(
                      local!mensajeInfo,
                      "Se ha producido un error al finalizar la contra anulación: " & a!defaultValue(
                        index(fv!processInfo, "pv", "wrErrMsg", null),
                        ""
                      ) & ". El error queda registrado en la bandeja de errores para su relanzamiento."
                    ),
                    a!save(local!mcaVentanaInfo, true)
                  },
                  {
                    a!save(ri!onCompletar, true),
                    /* Paridad SCA: tras el cierre positivo se vuelve directamente al buscador (sin aviso CORRECTO intermedio) */
                    ri!onVolver
                  }
                )
              },
              onIncomplete: {
                a!save(
                  local!mensajeInfo,
                  "No se ha podido confirmar la finalización de la contra anulación. Revise el estado de la solicitud o la bandeja de errores antes de volver a intentarlo."
                ),
                a!save(local!mcaVentanaInfo, true)
              },
              isSynchronous: true
            ),
            a!submitUploadedFiles(
              onSuccess: a!startProcess(
                processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                processParameters: {
                  idSolicitud: ri!idSolicitud,
                  idTarea: ri!idTarea,
                  resultado: a!map(
                    listaNombreDocs: local!listaNombreDocs,
                    tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                    /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                      index(
                        local!resultadoModal,
                        "anulaExpertos",
                        null
                      ),
                      local!anulaExpertosMotor
                    ),
                    anulaTecnicos: a!defaultValue(
                      index(
                        local!resultadoModal,
                        "anulaTecnicos",
                        null
                      ),
                      local!anulaTecnicosMotor
                    ),
                    nuuma: local!nuuma,
                    mcaFisicoJuridico: local!mcaFisicoJuridico,
                    mcaEstadoFinal: "3",
                    estadoFinalizar: "3",
                    finalizadoCA: true,
                    finalizarCAPca: a!map(
                      MSEFinalizarContraAnulPca: a!map(
                        mcaEstadoFinal: "3",
                        nivelIntervencion: local!nivelIntervencion,
                        codSolicitud: ri!idSolicitud,
                        infoUsuario: a!map(
                          codCiaUsuario: local!codCiaUsuario,
                          nuuma: local!nuuma,
                          codPerfil: local!codPerfil,
                          codSubPerfil: index(local!data, "codSubPerfil", "")
                        )
                      )
                    ),
                    ciaContraria: local!ciaContraria,
                    catalogacion: local!catalogacion,
                    observaciones: local!observaciones,
                    operacion: "CONTRAANULACION",
                    resultadoOperacion: "OK",
                    poliza: local!numPoliza,
                    cliente: local!idCliente,
                    tipoPersona: local!checksPECA,
                    perfilUsuario: index(
                      local!usuario,
                      "codSubPerfil",
                      index(
                        local!perfiles,
                        'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
                        null
                      )
                    )
                  )
                },
                onSuccess: {
                  if(
                    a!defaultValue(
                      index(fv!processInfo, "pv", "wrErr", null),
                      false
                    ),
                    {
                      a!save(
                        local!mensajeInfo,
                        "Se ha producido un error al finalizar la contra anulación: " & a!defaultValue(
                          index(fv!processInfo, "pv", "wrErrMsg", null),
                          ""
                        ) & ". El error queda registrado en la bandeja de errores para su relanzamiento."
                      ),
                      a!save(local!mcaVentanaInfo, true)
                    },
                    {
                      a!save(ri!onCompletar, true),
                      /* Paridad SCA: tras el cierre positivo se vuelve directamente al buscador (sin aviso CORRECTO intermedio) */
                      ri!onVolver
                    }
                  )
                },
                onIncomplete: {
                  a!save(
                    local!mensajeInfo,
                    "No se ha podido confirmar la finalización de la contra anulación. Revise el estado de la solicitud o la bandeja de errores antes de volver a intentarlo."
                  ),
                  a!save(local!mcaVentanaInfo, true)
                },
                isSynchronous: true
              ),
              onError: {
                a!save(
                  local!mensajeInfo,
                  "No se han podido guardar los documentos adjuntos (" & tostring(fv!error) & "). Vuelva a adjuntarlos antes de finalizar."
                ),
                a!save(local!mcaVentanaInfo, true)
              }
            )
          )
        }
      ),
      {}
    ),
    /* Paridad SCA: el modal informativo lo renderiza una sola vez SCA2_ContraAnulacionRehabilitacion */
    if(
      local!showDescuentosVida,
      rule!SCA2_ContraAnulacionDescuentos(
        showDescuentosVida: local!showDescuentosVida,
        numPoliza: local!numPoliza,
        mcaVentanaInfo: false,
        mensaje: local!mensajeInfo,
        mcaVentanaRecuperacion: local!mcaVentanaRecuperacion
      ),
      {}
    ),
    if(
      local!mcaVentanaSiNo,
      a!columnsLayout(
        columns: {
          a!columnLayout(),
          a!columnLayout(
            contents: {
              rule!SCA2_ContraAnulacionModalSiNo(
                mcaVentanaInfo: local!mcaVentanaSiNo,
                mensaje: local!mensajeInfo,
                data: a!map(
                  mcaPropietarioPoliza: local!mcaPropietarioPoliza,
                  codPerfilSi24Experto: local!codPerfilSi24Experto,
                  codPerfilSi24Front: local!codPerfilSi24Front,
                  codPerfilGGE: local!codPerfilGGE,
                  llamarAGeneracionContactos: local!llamarAGeneracionContactos,
                  caso: local!caso,
                  estadoContraAnul: local!estadoFinalizarCA,
                  numArgEjecu: local!numArgEjec,
                  canalProductor: index(local!datosProductor, "idcanal", ""),
                  subcanalProductor: index(local!datosProductor, "idsubcanal", ""),
                  canalEntrada: index(local!datos, "canalentrada", ""),
                  nivelIntervencion: local!nivelIntervencion,
                  codClaseAgt: local!codClaseAgt,
                  codAcuerdo: local!codAcuerdo,
                  telefonicaTelematica: local!telefonicaTelematica,
                  mcaIlocalizables: local!mcaIlocalizables,
                  codSolicitud: ri!idSolicitud,
                  codTipoArgumento: index(
                    local!argumentoSeleccionado,
                    "codTipoArgumento",
                    ""
                  ),
                  observaciones: local!observaciones,
                  codCia: local!codCiaUsuario,
                  codPerfil: local!codPerfil,
                  codSubPerfil: index(local!data, "codSubPerfil", ""),
                  nuuma: local!nuuma,
                  anulaExpertos: local!anulaExpertosMotor,
                  anulaTecnicos: local!anulaTecnicosMotor,
                  idCliente: local!idCliente,
                  numPoliza: local!numPoliza,
                  codProducto: index(local!basicos, "codproducto", ""),
                  username: user(
                    username: loggedInUser(),
                    property: "username"
                  ),
                  dniAdjunto: local!dniAdjunto,
                  cartaAdjunta: local!cartaAdjunta,
                  companiaContraria: local!companiaContraria,
                  fechaAnulacion: local!fechaAnulacion,
                  tipoCatalogacion: local!catalogacion,
                  tipoGestion: local!tipoGestion,
                  datosProductor: local!datosProductor
                ),
                datosContextoSolicitud: a!map(
                  contadorPosponer: index(local!estado, "contadorPosponer", 0)
                ),
                datosContraAnulacion: local!resultadoModal,
                argumentoSeleccionado: local!argumentoSeleccionado,
                codCiaContraria: local!codCiaContraria,
                noEntregaDoc: local!noEntregaDoc,
                onFinalizar: {
                  /* Paridad SCA: fuera de un formulario de tarea los ficheros del fileUploadField son temporales; a!submitUploadedFiles los consolida y solo entonces (onSuccess) se lanza CMD CompletarAccion, que los sube a GD/BBDD */
                  if(
                    a!isNullOrEmpty(local!listaNombreDocs),
                    a!startProcess(
                      processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                      processParameters: {
                        idSolicitud: ri!idSolicitud,
                        idTarea: ri!idTarea,
                        resultado: a!map(
                          listaNombreDocs: local!listaNombreDocs,
                          tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                          /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                            index(
                              local!resultadoModal,
                              "anulaExpertos",
                              null
                            ),
                            local!anulaExpertosMotor
                          ),
                          anulaTecnicos: a!defaultValue(
                            index(
                              local!resultadoModal,
                              "anulaTecnicos",
                              null
                            ),
                            local!anulaTecnicosMotor
                          ),
                          nuuma: local!nuuma,
                          mcaFisicoJuridico: local!mcaFisicoJuridico,
                          mcaEstadoFinal: a!defaultValue(
                            index(
                              local!resultadoModal,
                              "mcaEstadoFinal",
                              null
                            ),
                            local!estadoFinalizarCA
                          ),
                          estadoFinalizar: a!defaultValue(
                            index(
                              local!resultadoModal,
                              "mcaEstadoFinal",
                              null
                            ),
                            local!estadoFinalizarCA
                          ),
                          finalizadoCA: true,
                          finalizarCAPca: a!map(
                            MSEFinalizarContraAnulPca: a!map(
                              mcaEstadoFinal: a!defaultValue(
                                index(
                                  local!resultadoModal,
                                  "mcaEstadoFinal",
                                  null
                                ),
                                local!estadoFinalizarCA
                              ),
                              nivelIntervencion: local!nivelIntervencion,
                              codSolicitud: ri!idSolicitud,
                              infoUsuario: a!map(
                                codCiaUsuario: local!codCiaUsuario,
                                nuuma: local!nuuma,
                                codPerfil: local!codPerfil,
                                codSubPerfil: index(local!data, "codSubPerfil", "")
                              )
                            )
                          ),
                          ciaContraria: local!ciaContraria,
                          catalogacion: local!catalogacion,
                          observaciones: local!observaciones,
                          operacion: "CONTRAANULACION",
                          resultadoOperacion: "OK",
                          poliza: local!numPoliza,
                          cliente: local!idCliente,
                          tipoPersona: local!checksPECA,
                          perfilUsuario: index(
                            local!usuario,
                            "codSubPerfil",
                            index(
                              local!perfiles,
                              'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
                              null
                            )
                          )
                        )
                      },
                      onSuccess: {
                        if(
                          a!defaultValue(
                            index(fv!processInfo, "pv", "wrErr", null),
                            false
                          ),
                          {
                            a!save(
                              local!mensajeInfo,
                              "Se ha producido un error al finalizar la contra anulación: " & a!defaultValue(
                                index(fv!processInfo, "pv", "wrErrMsg", null),
                                ""
                              ) & ". El error queda registrado en la bandeja de errores para su relanzamiento."
                            ),
                            a!save(local!mcaVentanaInfo, true)
                          },
                          a!save(ri!onCompletar, true)
                        )
                      },
                      onIncomplete: {
                        a!save(
                          local!mensajeInfo,
                          "No se ha podido confirmar la finalización de la contra anulación. Revise el estado de la solicitud o la bandeja de errores antes de volver a intentarlo."
                        ),
                        a!save(local!mcaVentanaInfo, true)
                      },
                      isSynchronous: true
                    ),
                    a!submitUploadedFiles(
                      onSuccess: a!startProcess(
                        processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
                        processParameters: {
                          idSolicitud: ri!idSolicitud,
                          idTarea: ri!idTarea,
                          resultado: a!map(
                            listaNombreDocs: local!listaNombreDocs,
                            tipoGestion: cons!SCA2_TXT_TIPO_GESTION_CA,
                            /* R22 #4: las marcas del motor (SI24+acuerdo / CCC) viajan a CMD CompletarAccion, que las graba en Datos Solicitud antes de Decidir */anulaExpertos: a!defaultValue(
                              index(
                                local!resultadoModal,
                                "anulaExpertos",
                                null
                              ),
                              local!anulaExpertosMotor
                            ),
                            anulaTecnicos: a!defaultValue(
                              index(
                                local!resultadoModal,
                                "anulaTecnicos",
                                null
                              ),
                              local!anulaTecnicosMotor
                            ),
                            nuuma: local!nuuma,
                            mcaFisicoJuridico: local!mcaFisicoJuridico,
                            mcaEstadoFinal: a!defaultValue(
                              index(
                                local!resultadoModal,
                                "mcaEstadoFinal",
                                null
                              ),
                              local!estadoFinalizarCA
                            ),
                            estadoFinalizar: a!defaultValue(
                              index(
                                local!resultadoModal,
                                "mcaEstadoFinal",
                                null
                              ),
                              local!estadoFinalizarCA
                            ),
                            finalizadoCA: true,
                            finalizarCAPca: a!map(
                              MSEFinalizarContraAnulPca: a!map(
                                mcaEstadoFinal: a!defaultValue(
                                  index(
                                    local!resultadoModal,
                                    "mcaEstadoFinal",
                                    null
                                  ),
                                  local!estadoFinalizarCA
                                ),
                                nivelIntervencion: local!nivelIntervencion,
                                codSolicitud: ri!idSolicitud,
                                infoUsuario: a!map(
                                  codCiaUsuario: local!codCiaUsuario,
                                  nuuma: local!nuuma,
                                  codPerfil: local!codPerfil,
                                  codSubPerfil: index(local!data, "codSubPerfil", "")
                                )
                              )
                            ),
                            ciaContraria: local!ciaContraria,
                            catalogacion: local!catalogacion,
                            observaciones: local!observaciones,
                            operacion: "CONTRAANULACION",
                            resultadoOperacion: "OK",
                            poliza: local!numPoliza,
                            cliente: local!idCliente,
                            tipoPersona: local!checksPECA,
                            perfilUsuario: index(
                              local!usuario,
                              "codSubPerfil",
                              index(
                                local!perfiles,
                                'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{e188ba06-83ee-4cad-82f1-c56bf9e79732}codperfil',
                                null
                              )
                            )
                          )
                        },
                        onSuccess: {
                          if(
                            a!defaultValue(
                              index(fv!processInfo, "pv", "wrErr", null),
                              false
                            ),
                            {
                              a!save(
                                local!mensajeInfo,
                                "Se ha producido un error al finalizar la contra anulación: " & a!defaultValue(
                                  index(fv!processInfo, "pv", "wrErrMsg", null),
                                  ""
                                ) & ". El error queda registrado en la bandeja de errores para su relanzamiento."
                              ),
                              a!save(local!mcaVentanaInfo, true)
                            },
                            a!save(ri!onCompletar, true)
                          )
                        },
                        onIncomplete: {
                          a!save(
                            local!mensajeInfo,
                            "No se ha podido confirmar la finalización de la contra anulación. Revise el estado de la solicitud o la bandeja de errores antes de volver a intentarlo."
                          ),
                          a!save(local!mcaVentanaInfo, true)
                        },
                        isSynchronous: true
                      ),
                      onError: {
                        a!save(
                          local!mensajeInfo,
                          "No se han podido guardar los documentos adjuntos (" & tostring(fv!error) & "). Vuelva a adjuntarlos antes de finalizar."
                        ),
                        a!save(local!mcaVentanaInfo, true)
                      }
                    )
                  )
                }
              )
            }
          ),
          a!columnLayout()
        }
      ),
      {}
    ),
    if(
      a!isNotNullOrEmpty(local!mensaje),
      rule!SCA2_PopUpMensajeAutorizacion(
        texto: local!mensaje,
        titulo: "Contra anulación",
        resCargaGestionPCA: null,
        modificarCatalogacionResponse: null,
        insertarObservacionesResponse: null
      ),
      {}
    ),
    /* Ventana para mostrar la plantilla de la carta firmada (paridad SCA_ContraAnulacionOpcionesEstrategicas) */
    a!columnsLayout(
      columns: {
        a!columnLayout(
          contents: {
            rule!SCA2_VisualizarDocumentoContraanularEstrategicas(
              document: local!plantillaCarta,
              cancel: local!mcaVentanaVisualizarDoc,
              flecha: local!flecha
            )
          }
        )
      },
      showWhen: local!mcaVentanaVisualizarDoc
    )
  }
)
