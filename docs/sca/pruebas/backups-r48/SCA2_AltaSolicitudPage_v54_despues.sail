=a!localVariables(
  local!aceptarPulsado: false,
  local!usuario: index(rule!SCA2_obtenerInformacionUsuario(), "infoUsuarioDTO", {}),
  local!perfil: index(local!usuario, "codPerfil", ""),
  local!numPoliza: a!refreshVariable(value: ri!numPoliza, refreshOnVarChange: ri!numPoliza),
  local!tipoPolizaCalc: if(a!isNullOrEmpty(local!numPoliza), null,
    rule!SCA2_obtenerTipoPoliza(numPoliza: local!numPoliza)),
  local!polizawAutemis: local!tipoPolizaCalc = cons!SCA2_TXT_WAUTEMIS,
  /* R43-A: rama Vida Riesgo como SCA_AltaSolicitudAnulacionEstrategicas (servicio de Vida, cía 3, ramo 101, clave por oficina/agente de Vida) */
  local!polizaVidaAlta: local!tipoPolizaCalc = cons!SCA2_TXT_VIDA_RIESGO,
  local!polizaVidaRiesgo: if(local!polizaVidaAlta,
    rule!SCA2_consultarPolizaVidaRiesgo(numPoliza: local!numPoliza, responseDetailLevel: ""), null),
  local!codOficinaVida: reduce(index(_, _, null), local!polizaVidaRiesgo, {"producersData", 1, "salesOfficeCode"}),
  local!codAgtVida: if(local!polizaVidaAlta,
    rule!SCA2_getCodAgenteVida(producersData: index(local!polizaVidaRiesgo, "producersData", null)), null),
  /* R45-A (A1): sin productor válido (producerCode distinto de "1") no hay parte izquierda de la clave: póliza sin estructura comercial */
  local!sinEstructuraVida: and(local!polizaVidaAlta, a!isNotNullOrEmpty(local!polizaVidaRiesgo), a!isNullOrEmpty(local!codAgtVida)),
  local!claveProduccionVida: if(local!polizaVidaAlta,
    a!defaultValue(
      index(rule!SCA2_consultarEstructuraComercial(codCompania: cons!SCA2_INT_COD_CIA_VIDA,
        codOficinaDirecta: local!codOficinaVida, codAgenteVida: local!codAgtVida), "codAgente", null),
      index(rule!SCA2_consultarClavevida(codCia: cons!SCA2_INT_COD_CIA_VIDA,
        codOficina: local!codOficinaVida, codAgente: local!codAgtVida), "idClaveProduccion", null)),
    null),
  local!poliza: if(a!isNullOrEmpty(local!numPoliza), null,
    if(
      local!polizawAutemis,
      index(rule!SCA2_consultarPolizas(P_NUM_POLIZA: local!numPoliza), "MSSConsultarPolizas", null),
      a!localVariables(
        local!pObtenerPolizaFecha: rule!SCA2_pObtenerPolizaFecha(
          mSEPObtenerPolizaFechaDTO: a!map(
            pcodcia: 41, pnumpoliza: local!numPoliza, pnumapli: 0,
            pnumsptoapli: 0, pmcaconsultaglobal: "S", pmcalk: "S")),
        if(
          or(
            a!isNullOrEmpty(index(local!pObtenerPolizaFecha, "MSSPObtenerPolizaFecha", null)),
            a!isNullOrEmpty(index(index(local!pObtenerPolizaFecha, "MSSPObtenerPolizaFecha", null), "poconpolizat", null))),
          rule!SCA2_pObtenerPolizaFecha(
            mSEPObtenerPolizaFechaDTO: a!map(
              pcodcia: 41, pnumpoliza: local!numPoliza, pnumapli: 0,
              pnumsptoapli: 0, pmcaconsultaglobal: "S", pmcalk: "S",
              pfechaconsulta: todate(a!addDateTime(today(), 1)))),
          local!pObtenerPolizaFecha)))),
  local!pca: if(a!isNullOrEmpty(local!poliza), {}, index(local!poliza, "DATOS_PCA", {})),
  local!datosGeneralesPol: if(
    local!polizawAutemis,
    index(local!pca, "DATOS_POLIZA", {}),
    reduce(index(_, _, null), local!poliza,
      {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "datosgeneralespol", "array", 1})),
  local!tipoPoliza: if(local!polizawAutemis,
    a!match(value: index(local!datosGeneralesPol, "NOM_LINEA_NEGOCIO", ""),
      equals: "AUTOMÓVILES", then: "wAutemis",
      equals: "HOGAR", then: "NSE-Hogar",
      default: "Vida"),
    local!tipoPolizaCalc),
  local!dp: local!datosGeneralesPol,
  /* R43-A: en Vida Riesgo no hay datos generales de póliza (pObtenerPolizaFecha da CODIGO INEXISTENTE) y el valor por defecto 1 traía los catálogos de Autos.
     Igual que SCA_AltaSolicitudAnulacionEstrategicas: póliza Vida → línea de negocio 3. */
  local!lineaNegocio: if(
    local!tipoPolizaCalc = cons!SCA2_TXT_VIDA_RIESGO,
    cons!SCA2_INT_LINEA_NEGOCIO_VIDA,
    tointeger(index(local!datosGeneralesPol,
      if(local!polizawAutemis, "LINEA_NEGOCIO", "codsector"), 1))),
  local!estructuraCabecera: rule!SCA2_obtenerDatosCabecera(numPoliza: local!numPoliza, idSolicitud: null),
  local!fechaEfectoAnualidadCurso: a!localVariables(
    local!fecha: index(index(local!estructuraCabecera, "datosPoliza", {}), "fechaEfecto", null),
    if(
      a!isNullOrEmpty(local!fecha),
      null,
      a!localVariables(
        local!partes: split(left(tostring(local!fecha), 10), "/"),
        if(
          count(local!partes) = 3,
          todatetime(date(
            tointeger(index(local!partes, 3, null)),
            tointeger(index(local!partes, 2, null)),
            tointeger(index(local!partes, 1, null))
          )),
          todatetime(local!fecha)
        )
      )
    )
  ),
  local!fechaVencimiento: a!localVariables(
    local!fecha: index(index(local!estructuraCabecera, "datosPoliza", {}), "fechaVencimiento", null),
    if(
      a!isNullOrEmpty(local!fecha),
      null,
      a!localVariables(
        local!partes: split(left(tostring(local!fecha), 10), "/"),
        if(
          count(local!partes) = 3,
          todatetime(date(
            tointeger(index(local!partes, 3, null)),
            tointeger(index(local!partes, 2, null)),
            tointeger(index(local!partes, 1, null))
          )),
          todatetime(local!fecha)
        )
      )
    )
  ),
  local!solicitudVigente: if(
    or(
      a!isNullOrEmpty(local!fechaEfectoAnualidadCurso),
      a!isNullOrEmpty(local!fechaVencimiento)
    ),
    false,
    rule!SCA2_comprobarSolicitudesVigencia(
      numPoliza: local!numPoliza,
      fechaEfecto: local!fechaEfectoAnualidadCurso,
      fechaVencimiento: local!fechaVencimiento
    )
  ),
  local!datosPoliza: index(local!estructuraCabecera, "datosPoliza", {}),
  local!datosCliente: index(local!estructuraCabecera, "datosCliente", {}),
  local!motivoAnulacion: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!detalle: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!causa: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!motivosDD: if(a!isNullOrEmpty(local!numPoliza), {},
    a!forEach(
      items: a!defaultValue(index(
        rule!SCA2_consultarMotivo(infoUsuarioDTO: local!usuario, codLineaNegocio: local!lineaNegocio),
        "MSSConsultarMotivo", {}), {}),
      expression: a!map(
        codigo: if(search("<codigo>", tostring(fv!item)) > 0,
          tointeger(index(split(index(split(fv!item, "<codigo>"), 2, ""), "</codigo>"), 1, "")),
          tointeger(index(fv!item, "codigo", null))),
        descripcion: if(search("<codigo>", tostring(fv!item)) > 0,
          index(split(index(split(fv!item, "<descripcion>"), 2, ""), "</descripcion>"), 1, ""),
          index(fv!item, "descripcion", ""))))),
  local!detalleDD: if(a!isNullOrEmpty(local!motivoAnulacion), {},
    a!forEach(
      items: a!defaultValue(index(
        rule!SCA2_consultarDetalle(codMotivo: tostring(local!motivoAnulacion), codLineaNegocio: local!lineaNegocio),
        "MSSConsultarDetalle", {}), {}),
      expression: a!map(
        codigo: if(search("<codigo>", tostring(fv!item)) > 0,
          tointeger(index(split(index(split(fv!item, "<codigo>"), 2, ""), "</codigo>"), 1, "")),
          tointeger(index(fv!item, "codigo", null))),
        descripcion: if(search("<codigo>", tostring(fv!item)) > 0,
          index(split(index(split(fv!item, "<descripcion>"), 2, ""), "</descripcion>"), 1, ""),
          index(fv!item, "descripcion", ""))))),
  local!causaDD: if(or(a!isNullOrEmpty(local!motivoAnulacion), a!isNullOrEmpty(local!detalle)), {},
    a!forEach(
      items: a!defaultValue(index(
        rule!SCA2_consultarCausa(codMotivo: tostring(local!motivoAnulacion), codDetalle: tostring(local!detalle),
          codPerfil: local!perfil, codLineaNegocio: tostring(local!lineaNegocio)),
        "MSSConsultarCausa", {}), {}),
      expression: a!map(
        codigo: if(search("<codigo>", tostring(fv!item)) > 0,
          tointeger(index(split(index(split(fv!item, "<codigo>"), 2, ""), "</codigo>"), 1, "")),
          tointeger(index(fv!item, "codigo", null))),
        descripcion: if(search("<codigo>", tostring(fv!item)) > 0,
          index(split(index(split(fv!item, "<descripcion>"), 2, ""), "</descripcion>"), 1, ""),
          index(fv!item, "descripcion", ""))))),
  /* R11 #4 (analista): motivo→detalle→causa son jerárquicos; un detalle sin causas y un motivo sin detalles con causas no se muestran.
     Sólo se evalúa para perfiles SI24, que son los únicos a los que se les ocultan causas (SCA2_consultarCausa); el resto recibe las listas de CORE tal cual. */
  local!esSi24Alta: rule!SCA2_datosPerfilesPcaSi24(codPerfil: a!defaultValue(local!perfil, ""), codSubPerfil: a!defaultValue(index(local!usuario, "codSubPerfil", ""), "")),
  local!detalleTieneCausas: if(not(local!esSi24Alta), {},
    a!forEach(
      items: local!detalleDD,
      expression: length(a!defaultValue(index(
        rule!SCA2_consultarCausa(codMotivo: tostring(local!motivoAnulacion), codDetalle: tostring(index(fv!item, "codigo", "")),
          codPerfil: local!perfil, codLineaNegocio: tostring(local!lineaNegocio)),
        "MSSConsultarCausa", {}), {})) > 0)),
  local!detalleDDVisible: if(not(local!esSi24Alta), local!detalleDD,
    index(local!detalleDD, where(local!detalleTieneCausas, true), {})),
  local!motivosDDVisible: if(not(local!esSi24Alta), local!motivosDD,
    a!localVariables(
      local!motivoTieneDetalles: a!forEach(
        items: local!motivosDD,
        expression: a!localVariables(
          local!codMotivo: tostring(index(fv!item, "codigo", "")),
          local!detalles: a!forEach(
            items: a!defaultValue(index(
              rule!SCA2_consultarDetalle(codMotivo: local!codMotivo, codLineaNegocio: local!lineaNegocio),
              "MSSConsultarDetalle", {}), {}),
            expression: if(search("<codigo>", tostring(fv!item)) > 0,
              index(split(index(split(fv!item, "<codigo>"), 2, ""), "</codigo>"), 1, ""),
              tostring(index(fv!item, "codigo", "")))),
          or(a!forEach(
            items: local!detalles,
            expression: length(a!defaultValue(index(
              rule!SCA2_consultarCausa(codMotivo: local!codMotivo, codDetalle: tostring(fv!item),
                codPerfil: local!perfil, codLineaNegocio: tostring(local!lineaNegocio)),
              "MSSConsultarCausa", {}), {})) > 0)))),
      index(local!motivosDD, where(local!motivoTieneDetalles, true), {}))),
  local!subPerfil: a!defaultValue(index(local!usuario, "codSubPerfil", null), cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA),
  local!nuuma: index(local!usuario, "nuuma", null),
  local!datosAgente: if(local!polizawAutemis,
    index(local!pca, "DATOS_STR_COMER", null),
    reduce(index(_, _, null), local!poliza,
      {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "agente", "array", 1})),
  local!datosCaracteristicasVehiculo: if(local!polizawAutemis, null,
    reduce(index(_, _, null), local!poliza,
      {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "riesgos", "array", 1, "caracteristicas", "array"})),
  local!caracteristicasVehiculo: index(local!datosCaracteristicasVehiculo,
    wherecontains({"COD_CATEGORIA", "COD_MARCA", "COD_MODELO", "COD_TIPO_VEHIC", "FEC_PRIM_MATRIC", "NUM_MATRICULA"},
      index(local!datosCaracteristicasVehiculo, "codcampo", null))),
  local!datosVehiculo: if(local!polizawAutemis, index(local!pca, "DATOS_VEHIC", {}),
    {MATRICULA: index(index(local!caracteristicasVehiculo, 6, null), "valcampo", null),
     CAT_VEHIC: index(index(local!caracteristicasVehiculo, 1, null), "valcampo", null)}),
  local!figurasParticipantes: reduce(index(_, _, null), local!poliza,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", "figurasparticipantes", 1, "array", "figuraparticipante"}),
  local!tomador: if(local!polizawAutemis, null,
    index(index(local!figurasParticipantes,
      wherecontains("TO", index(local!figurasParticipantes, "codinterv", null))), 1, null)),
  local!impago: if(local!polizawAutemis,
    index(local!pca, "ESTADO_RECIBOS", "MCA_IMPAGADOS") = "S",
    reduce(index(_, _, null), local!tomador, {"mediospago", "array", 1, "mcaprimerrecibo"}) = "S"),
  local!claveProduccion: if(local!polizaVidaAlta, local!claveProduccionVida,
    index(local!datosAgente,
      if(local!polizawAutemis, "CLAVE_PRODUCCION", "codterceroagt"), null)),
  local!codCia: if(local!polizawAutemis,
    index(local!datosGeneralesPol, "COD_CIA", null),
    local!polizaVidaAlta, tostring(cons!SCA2_INT_COD_CIA_VIDA),
    reduce(index(_, _, null), local!poliza,
      {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "codcia"})),
  local!consultaFecUltimoSiniestro: rule!SCA2_consultarFechaUltimoSiniestro(
    numPoliza: local!numPoliza,
    matricula: index(local!datosVehiculo, "MATRICULA", null),
    idUsuario: local!nuuma,
    indConsultaHistorico: "S"),
  local!canalDD: rule!SCA2_calculoCanalEntrada(usuario: local!usuario, impago: local!impago),
  local!canalEntrada: index(local!canalDD, "default", null),
  local!medioDD: if(a!isNullOrEmpty(local!canalEntrada), null,
    rule!SCA2_calculoMedioComunicacion(usuario: local!usuario, codCanalEntrada: tointeger(local!canalEntrada))),
  local!medioComunicacion: index(local!medioDD, "default", null),
  local!consultaCatalogacion: if(
    or(
      a!isNullOrEmpty(local!causa),
      a!isNullOrEmpty(local!motivoAnulacion),
      a!isNullOrEmpty(local!detalle),
      a!isNullOrEmpty(local!canalEntrada)
    ),
    null,
    rule!SCA2_consultarCatalogacionRest(
      consulta: {
        numeroAplicacion: "0",
        canalEntrada: local!canalEntrada,
        perfilEjecucion: local!perfil,
        subperfilEjecucion: local!subPerfil,
        lineaNegocio: local!lineaNegocio,
        claveProduccion: local!claveProduccion,
        codigoMotivoAnulacion: local!motivoAnulacion,
        codigoCausaAnulacion: local!causa,
        fechaAnulacion: if(
          a!isNullOrEmpty(local!consultaFecUltimoSiniestro),
          text(gmt(today(), timezone()), "yyyy-mm-dd"),
          text(gmt(local!consultaFecUltimoSiniestro, timezone()), "yyyy-mm-dd")
        ),
        codigoDetalleAnulacion: local!detalle,
        nuuma: local!nuuma
      },
      numPoliza: local!numPoliza,
      compania: local!codCia
    )
  ),
  /* R46-B (duda 13): la catalogación se muestra tal como la propone el servicio de reglas de catalogación (p. ej. A VENCIMIENTO TRIMESTRAL en Más Móvil); si el valor por defecto no viene en la lista se añade para que el desplegable no quede con un valor inválido */
  local!catalogacionDD: a!localVariables(
    local!lista: index(local!consultaCatalogacion, "listaCatalogacion", {}),
    local!defecto: tostring(index(local!consultaCatalogacion, "codCatalogacionDefecto", null)),
    if(
      or(
        a!isNullOrEmpty(local!defecto),
        contains(touniformstring(a!defaultValue(index(local!lista, "codCatalogacion", {}), {})), local!defecto)
      ),
      local!lista,
      append(
        a!forEach(local!lista, a!map(codCatalogacion: tostring(index(fv!item, "codCatalogacion", null)))),
        a!map(codCatalogacion: local!defecto)
      )
    )
  ),
  local!catalogacionOriginal: index(local!consultaCatalogacion, "codCatalogacionDefecto", null),
  local!tipoCatalogacion: a!refreshVariable(
    value: index(local!consultaCatalogacion, "codCatalogacionDefecto", null),
    refreshOnVarChange: local!consultaCatalogacion),
  local!fechaAnulacion: a!refreshVariable(
    value: if(
      a!isNotNullOrEmpty(local!consultaCatalogacion),
      if(
        a!isNullOrEmpty(index(local!consultaCatalogacion, "fechaAnulacion", null)),
        null,
        gmt(index(local!consultaCatalogacion, "fechaAnulacion", null), "Europe/Madrid")
      ),
      null),
    refreshOnVarChange: local!tipoCatalogacion),
  /* Paridad SCA_AltaSolicitudAnulacion (local!fechaAnulacionCambio): la fecha mostrada y guardada depende de la catalogación elegida (1 A EFECTO → fecha efecto anualidad en curso; 2/3 → vencimiento; 4 → fecha del servicio; 5 → trimestral). Ronda 23-A. */
  local!fechaEfectoInicial: index(local!datosGeneralesPol, if(local!polizawAutemis, "FEC_EFEC_INI", "fecefecini"), null),
  local!fechaAnulacionCambio: a!refreshVariable(
    value: if(
      local!tipoCatalogacion = local!catalogacionOriginal,
      local!fechaAnulacion,
      a!match(
        value: local!tipoCatalogacion,
        equals: "1", then: local!fechaEfectoAnualidadCurso,
        equals: "2", then: local!fechaVencimiento,
        equals: "3", then: local!fechaVencimiento,
        equals: "4", then: local!fechaAnulacion,
        equals: "5", then: {
          a!localVariables(
            local!fechaInicio: todate(local!fechaEfectoInicial),
            local!fechaFin: todate(local!fechaVencimiento),
            local!hoy: today(),
            local!day: day(local!fechaInicio),
            local!mes: month(local!hoy),
            local!año: year(local!fechaInicio),
            a!match(
              value: tointeger(ceiling(local!mes / 3)),
              equals: 1, then: a!localVariables(local!fecha: date(local!año, 4, local!day), if(local!fecha > local!fechaFin, local!fechaFin, local!fecha)),
              equals: 2, then: a!localVariables(local!fecha: date(local!año, 7, local!day), if(local!fecha > local!fechaFin, local!fechaFin, local!fecha)),
              equals: 3, then: a!localVariables(local!fecha: date(local!año, 10, local!day), if(local!fecha > local!fechaFin, local!fechaFin, local!fecha)),
              equals: 4, then: a!localVariables(local!fecha: date(local!año + 1, 1, local!day), if(local!fecha > local!fechaFin, local!fechaFin, local!fecha)),
              default: null
            )
          )
        },
        default: null
      )
    ),
    refreshOnVarChange: local!tipoCatalogacion),
  local!telefonoExpertos: null,
  /* Simulación en el alta (paridad SCA_AltaSolicitudAnulacion / SCA_SimularAnulacionPopup, ronda 9 A1) */
  local!showPopupSimular: a!refreshVariable(value: false, refreshOnVarChange: ri!numPoliza),
  local!pasoANivel2: false,
  local!expertosSi: false,
  local!tlfSeleccionado: null,
  local!tlfEditable: null,
  local!isPolizaPRRA: a!refreshVariable(value: false, refreshOnVarChange: ri!numPoliza),
  local!codProducto: if(
    local!polizawAutemis,
    if(index(local!datosVehiculo, "CAT_VEHIC", "") = "1", "AU01", index(local!datosVehiculo, "CAT_VEHIC", "") = "3", "AU02", ""),
    local!tipoPoliza = "NSE-Autos",
    if(index(local!datosVehiculo, "CAT_VEHIC", "") = "00000009", "AU01",
      or(index(local!datosVehiculo, "CAT_VEHIC", "") = "00000006", index(local!datosVehiculo, "CAT_VEHIC", "") = "00000007",
        index(local!datosVehiculo, "CAT_VEHIC", "") = "00000008", index(local!datosVehiculo, "CAT_VEHIC", "") = "00000019"), "AU02", ""),
    local!tipoPoliza = "NSE-Hogar", "HG01",
    local!polizaVidaAlta, reduce(index(_, _, null), local!polizaVidaRiesgo, {"contractData", 1, "commercialProductCode"}),
    ""),
  /* Datos del productor y del tomador para la simulación/mensajes de alta (paridad SCA: canalProductor, isSi24, codInt, polizaVencida) */
  local!consultaClave: if(a!isNullOrEmpty(local!numPoliza), null,
    reduce(index(_, _, null),
      rule!SCA2_consultaClave(
        codCia: if(local!polizawAutemis, "1", "41"),
        codTerceroAgt: if(local!polizawAutemis, index(local!datosAgente, "CLAVE_PRODUCCION", ""), index(local!datosAgente, "codterceroagt", "")),
        codIdioma: "ES_es"),
      {"MSSConsultaClave", "p_objeto_agt_clave_s", "COD_CLASE_AGT"})),
  local!tipoProductor: if(a!isNullOrEmpty(local!consultaClave), null,
    reduce(index(_, _, null),
      rule!SCA2_obtenerDatosProductor(pidclaseclaveprod: local!consultaClave),
      {"MSSObtenerDatosProductor", "plistadatosprod", 1})),
  local!codIntTomador: if(local!polizawAutemis,
    index(index(local!pca, "DATOS_TO", {}), "COD_INT", null),
    index(local!tomador, "codint", null)),
  local!polizaVencida: contains({"SIN EFECTO", "SIN VIGOR", "ANULADA"}, a!defaultValue(tostring(index(local!datosGeneralesPol, "nomestadooperacion", null)), "")),
  local!datosTomador: a!map(
    telefono1: a!defaultValue(index(index(local!estructuraCabecera, "datosContacto", {}), "telMovil", null), ""),
    telefono2: a!defaultValue(index(index(local!estructuraCabecera, "datosContacto", {}), "telFijo", null), "")),
  local!observaciones: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!mensaje: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!esError: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!erroresGuardar: a!refreshVariable(value: null, refreshOnVarChange: {ri!numPoliza, local!fechaAnulacion, local!motivoAnulacion, local!detalle, local!causa}),
  local!codRamo: if(local!polizaVidaAlta, cons!SCA2_TXT_COD_RAMO_VIDA,
    index(local!datosGeneralesPol, if(local!polizawAutemis, "COD_RAMO", "codproducto"), null)),
  local!codAcuerdoPol: index(local!datosGeneralesPol, if(local!polizawAutemis, "COD_ACUERDO", "codacuerdo"), null),
  local!solicitudEnCurso: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!idSolGenerada: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!procesoLanzado: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  /* R42-A: COMPROBAR AHORA fuerza la relectura inmediata del sondeo de la espera */
  local!comprobarAhora: a!refreshVariable(value: 0, refreshOnVarChange: ri!numPoliza),
  local!fechaLanzamiento: a!refreshVariable(value: null, refreshOnVarChange: ri!numPoliza),
  local!instanteEspera: a!refreshVariable(value: now(), refreshOnVarChange: {local!procesoLanzado, local!comprobarAhora}, refreshInterval: if(a!defaultValue(local!procesoLanzado, false), cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60, null)),
  local!idSolRecuperada: a!refreshVariable(
    value: if(
      or(
        not(a!defaultValue(local!procesoLanzado, false)),
        a!isNotNullOrEmpty(local!idSolGenerada),
        a!defaultValue(local!esError, false)),
      null,
      index(
        index(
          index(a!queryRecordType(
            recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
            filters: a!queryLogicalExpression(operator: "AND", filters: {
              a!queryFilter(
                field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
                operator: "=",
                value: tostring(local!numPoliza)),
              a!queryFilter(
                field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
                operator: ">=",
                value: a!subtractDateTime(startDateTime: local!fechaLanzamiento, minutes: 1))}),
            fields: {'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud'},
            pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1,
              sort: a!sortInfo(
                field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
                ascending: false)),
            fetchTotalCount: false),
          "data", {}),
        1,
        {}),
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
      null)),
    refreshInterval: if(
      and(
        a!defaultValue(local!procesoLanzado, false),
        a!isNullOrEmpty(local!idSolGenerada)),
      cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60,
      null),
    refreshAlways: true),
  local!idSolEfectiva: a!defaultValue(local!idSolGenerada, local!idSolRecuperada),
  local!errorAlta: a!refreshVariable(
    value: if(
      left(tostring(local!idSolEfectiva), 5) = "PDTE-",
      index(index(a!queryRecordType(
        recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
        filters: a!queryLogicalExpression(operator: "AND", filters: {
          a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', operator: "=", value: tostring(local!idSolEfectiva)),
          a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', operator: "=", value: "SCA2 CMD Alta")}),
        fields: {
          'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo',
          'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje',
          'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1,
          sort: a!sortInfo(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', ascending: false)),
        fetchTotalCount: false), "data", {}), 1, null),
      null),
    refreshOnVarChange: local!idSolEfectiva),
  local!textoErrorAlta: "Los datos no se han podido guardar correctamente. La solicitud no se ha podido crear." &
    if(a!isNullOrEmpty(local!errorAlta), "",
      " Error: " & a!defaultValue(tostring(index(local!errorAlta, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo', null)), "") &
      " - " & left(a!defaultValue(tostring(index(local!errorAlta, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje', null)), ""), 500) &
      " (paso: " & a!defaultValue(tostring(index(local!errorAlta, 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo', null)), "") & ").") &
    " Póliza: " & a!defaultValue(tostring(ri!numPoliza), "") &
    if(left(tostring(local!idSolEfectiva), 5) = "PDTE-", ". Referencia: " & tostring(local!idSolEfectiva), "") &
    ". Reporte este error a mantenimiento SCA.",
  /* Tarea pendiente generada tras el alta (para abrir la acción directamente, paridad SCA) */
  local!tareaNueva: a!refreshVariable(
    value: index(index(a!queryRecordType(
      recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
      filters: a!queryLogicalExpression(operator: "AND", filters: {
        a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud', operator: "=",
          value: if(a!isNullOrEmpty(local!idSolEfectiva), "\u0001", tostring(local!idSolEfectiva))),
        a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado', operator: "=", value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE)}),
      fields: {
        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo'},
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1,
        sort: a!sortInfo(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', ascending: false)),
      fetchTotalCount: false), "data", {}), 1, {}),
    refreshInterval: if(a!isNullOrEmpty(local!idSolEfectiva), null, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60),
    refreshAlways: true),
  /* Estado de la solicitud recién creada: si la decisión no genera tarea humana (mecanizar/fin/error) el OK abre el detalle */
  local!estadoSolNueva: a!refreshVariable(
    value: if(a!isNullOrEmpty(local!idSolEfectiva), null,
      index(index(index(a!queryRecordType(
        recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
        filters: a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud', operator: "=", value: tostring(local!idSolEfectiva)),
        fields: {'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1), fetchTotalCount: false), "data", {}), 1, {}),
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud', null)),
    refreshInterval: if(a!isNullOrEmpty(local!idSolEfectiva), null, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60),
    refreshAlways: true),
  local!decisionLista: or(
    a!isNotNullOrEmpty(local!tareaNueva),
    not(contains({"ALTA", "DECIDIDA", cons!SCA2_TXT_ESTADO_SOL_EN_ACCION}, a!defaultValue(local!estadoSolNueva, "ALTA")))),
  /* R48-A: tope de la espera de respaldo; al agotarse se ofrece salida (consultar la solicitud / volver al buscador) en vez de esperar sin fin */
  local!esperaAgotada: if(
    or(
      not(a!defaultValue(local!procesoLanzado, false)),
      local!decisionLista,
      left(tostring(local!idSolEfectiva), 5) = "PDTE-",
      a!isNullOrEmpty(local!fechaLanzamiento)
    ),
    false,
    local!instanteEspera >= a!addDateTime(startDateTime: local!fechaLanzamiento, seconds: cons!SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS)),
  /* --- paridad SCA (tanda 13) --- */
  local!tab: 2, /* R27-A: pestaña inicial Datos póliza */
  local!masDatos: true,
  local!compania: null,
  local!showPopupCia: false,
  local!numFax: null,
  {
    /* Header (port de SCA_DatosCabecera_Estrategicas + SCA_MilestoneMasDatos):
       card gris #F5F5F5 sin borde, flecha arrow-left roja a la izquierda con
       separador vertical, título a la izquierda en negrita, "Más Datos" con
       chevron a la derecha; tabs con barra roja inferior en la seleccionada */
    a!cardLayout(
      contents: {
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
                          link: a!safeLink(uri: "/suite/sites/sca2/page/buscador", openLinkIn: "SAME_TAB"),
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_ROJO,
                          size: "MEDIUM"))),
                    a!columnLayout(
                      contents: a!richTextDisplayField(labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: tostring(local!numPoliza) & " - " &
                            index(local!datosCliente, "nombre", "") & " " &
                            index(local!datosCliente, "apellidos", "") &
                            " - NIF: " & index(local!datosCliente, "nif", ""),
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_NEGRO, size: "STANDARD", style: "STRONG")),
                      width: "WIDE_PLUS")
                  },
                  alignVertical: "MIDDLE",
                  showDividers: true)),
              a!columnLayout(contents: {}),
              a!columnLayout(
                contents: a!columnsLayout(
                  columns: {
                    a!columnLayout(contents: {}),
                    a!columnLayout(
                      contents: a!sideBySideLayout(
                        items: a!sideBySideItem(
                          item: a!richTextDisplayField(
                            labelPosition: "COLLAPSED",
                            value: {
                              a!richTextItem(
                                text: "Más Datos",
                                color: cons!SCA2_VAL_COLOR_NEGRO, size: "STANDARD", style: "STRONG"),
                              char(32),
                              a!richTextIcon(
                                icon: if(local!masDatos, "chevron-up", "chevron-down"),
                                link: a!dynamicLink(
                                  saveInto: a!save(local!masDatos, not(local!masDatos))),
                                linkStyle: "STANDALONE", color: cons!SCA2_VAL_COLOR_NEGRO)},
                            align: "RIGHT", marginAbove: "NONE", marginBelow: "NONE")),
                        alignVertical: "MIDDLE",
                        marginAbove: "EVEN_LESS", marginBelow: "EVEN_LESS"))
                  },
                  alignVertical: "MIDDLE"))
            },
            alignVertical: "MIDDLE"),
          style: cons!SCA2_VAL_COLOR_GRIS_CLARO, marginAbove: "NONE", marginBelow: "NONE",
          showBorder: false()),
        a!cardLayout(
          contents: {
            a!columnsLayout(
              columns: {
                a!columnLayout(),
                a!forEach(items: {"Datos cliente", "Datos póliza", "Otras sol. Anulación", "Datos contacto"},
                  expression: a!columnLayout(
                    contents: a!cardLayout(
                      contents: a!richTextDisplayField(labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: fv!item,
                          linkStyle: "STANDALONE", color: cons!SCA2_VAL_COLOR_NEGRO,
                          style: if(local!tab = fv!index, "STRONG", null)),
                        align: "CENTER"),
                      style: cons!SCA2_VAL_COLOR_GRIS_CLARO,
                      showBorder: false,
                      decorativeBarPosition: "BOTTOM",
                      decorativeBarColor: if(local!tab = fv!index,
                        cons!SCA2_VAL_COLOR_ROJO, cons!SCA2_VAL_COLOR_BLANCO),
                      link: a!dynamicLink(saveInto: a!save(local!tab, fv!index)),
                      accessibilityText: if(fv!index = local!tab,
                        "Selected section.",
                        "Unselected section. Press enter to select section.")),
                    width: "NARROW")),
                a!columnLayout()
              },
              alignVertical: "MIDDLE",
              marginAbove: "NONE", marginBelow: "NONE", spacing: "NONE"),
            a!horizontalLine(),
            a!cardLayout(
              contents: choose(local!tab,
                rule!SCA2_DatosCliente(datosCliente: local!datosCliente, numPoliza: local!numPoliza),
                rule!SCA2_DatosPoliza(datosPoliza: local!datosPoliza, acuerdoYDistribuidor: ""),
                rule!SCA2_TablaOtrasSolAnulacion(numPoliza: local!numPoliza, idSolicitudSel: null),
                rule!SCA2_DatosContacto(numPoliza: local!numPoliza,
                  datosContacto: index(local!estructuraCabecera, "datosContacto", {}))),
              style: cons!SCA2_VAL_COLOR_GRIS_CLARO, padding: "STANDARD", showBorder: "NONE")
          },
          showWhen: local!masDatos,
          style: cons!SCA2_VAL_COLOR_GRIS_CLARO, padding: "LESS",
          marginAbove: "NONE", marginBelow: "NONE", showBorder: false)
      },
      showBorder: false),
    if(a!defaultValue(local!procesoLanzado, false),
      a!cardLayout(style: "INFO", contents: {
        a!richTextDisplayField(value: a!richTextItem(text:
          if(left(tostring(local!idSolEfectiva), 5) = "PDTE-", local!textoErrorAlta,
            if(local!decisionLista, cons!SCA2_TXT_ESPERA_DECISION_LISTA,
              if(local!esperaAgotada, cons!SCA2_TXT_ESPERA_AGOTADA & if(a!isNullOrEmpty(local!idSolEfectiva), "", " Solicitud: " & local!idSolEfectiva & "."),
              if(a!isNullOrEmpty(local!fechaLanzamiento), cons!SCA2_TXT_ESPERA_DECISION_INICIAL,
                if(local!instanteEspera >= a!addDateTime(startDateTime: local!fechaLanzamiento,
                    seconds: cons!SCA2_VAL_ESPERA_DECISION_INICIAL_SEGUNDOS),
                  cons!SCA2_TXT_ESPERA_DECISION_ADICIONAL, cons!SCA2_TXT_ESPERA_DECISION_INICIAL))))))),
        a!buttonArrayLayout(buttons: {
          a!buttonWidget(
            label: cons!SCA2_TXT_COMPROBAR_AHORA, style: "OUTLINE",
            saveInto: a!save(local!comprobarAhora, a!defaultValue(local!comprobarAhora, 0) + 1),
            showWhen: not(or(local!decisionLista, left(tostring(local!idSolEfectiva), 5) = "PDTE-"))),
          a!buttonWidget(
          label: if(local!esperaAgotada, "CONSULTAR SOLICITUD", cons!SCA2_TXT_ACEPTAR_CONSULTA_SOLICITUD), style: "SOLID",
          showWhen: or(not(local!esperaAgotada), a!isNotNullOrEmpty(local!idSolEfectiva)),
          /* R44-A (analista #1): deshabilitado tras el primer clic, sin dobles envíos */
          disabled: or(a!defaultValue(local!aceptarPulsado, false), not(and(a!isNotNullOrEmpty(local!idSolEfectiva),
            or(local!decisionLista, local!esperaAgotada, left(tostring(local!idSolEfectiva), 5) = "PDTE-")))),
          saveInto: {a!save(local!aceptarPulsado, true), a!save(ri!idSolicitudSel, local!idSolEfectiva),
            a!save(ri!tipoAccion, index(local!tareaNueva, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo', null)),
            a!save(ri!idTarea, index(local!tareaNueva, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', null)),
            a!save(ri!vista, "DETALLE")}),
          a!buttonWidget(
            label: "VOLVER AL BUSCADOR", style: "OUTLINE",
            showWhen: local!esperaAgotada,
            saveInto: {a!save(local!procesoLanzado, null), a!save(local!idSolGenerada, null),
              a!save(local!fechaLanzamiento, null), a!save(ri!numPoliza, null), a!save(ri!vista, "BUSQUEDA")})})
      }), {}),
    if(a!isNotNullOrEmpty(local!solicitudEnCurso),
      a!cardLayout(style: "INFO", contents: {
        a!richTextDisplayField(value: cons!SCA2_TXT_SOLICITUD_EN_CURSO),
        a!buttonArrayLayout(buttons: a!buttonWidget(
          label: cons!SCA2_TXT_ACEPTAR_CONSULTA_SOLICITUD, style: "SOLID",
          saveInto: {a!save(ri!idSolicitudSel, local!solicitudEnCurso),
            a!save(ri!tipoAccion, null), a!save(ri!idTarea, null),
            a!save(ri!vista, "DETALLE")}))
      }), {}),
    /* R45-A (A1): póliza Vida sin parte izquierda de la clave de producción (sin estructura comercial): aviso y alta bloqueada, como SCA */
    if(local!sinEstructuraVida,
      a!cardLayout(style: "ERROR", showBorder: false, decorativeBarPosition: "START", decorativeBarColor: "NEGATIVE", contents: {
        a!richTextDisplayField(labelPosition: "COLLAPSED", value: {
          a!richTextIcon(icon: "exclamation-circle", color: "NEGATIVE"), " ",
          a!richTextItem(text: cons!SCA2_TXT_POLIZA_SIN_ESTRUCTURA_TITULO, style: "STRONG"), char(10),
          a!richTextItem(text: cons!SCA2_TXT_POLIZA_SIN_ESTRUCTURA_COMERCIAL)})}), {}),
    /* R20 #1 (analista): compañías contrarias como ventana: mientras está abierta sustituye al formulario */
    if(and(a!isNotNullOrEmpty(local!dp), not(a!defaultValue(local!showPopupCia, false)),
      not(a!defaultValue(local!procesoLanzado, false)), a!isNullOrEmpty(local!solicitudEnCurso)),
      a!cardLayout(
        contents: {
          /* título dentro de la card del formulario (literal SCA) */
          a!richTextDisplayField(labelPosition: "COLLAPSED",
            value: a!richTextItem(text: "Alta Solicitud Anulación",
              color: cons!SCA2_VAL_COLOR_NEGRO, size: "STANDARD", style: "STRONG")),
          a!columnsLayout(columns: {
            a!columnLayout(contents: {
              a!dropdownField(
                choiceLabels: index(local!motivosDDVisible, "descripcion", {}),
                choiceValues: index(local!motivosDDVisible, "codigo", {}),
                label: "Motivo anulación",
                labelPosition: "ABOVE",
                placeholder: "--- Seleccione ---",
                value: local!motivoAnulacion,
                saveInto: {local!motivoAnulacion, a!save(local!detalle, null), a!save(local!causa, null)},
                searchDisplay: "AUTO", required: true)}),
            a!columnLayout(contents: {
              /* R47-A (analista, duda 25): en Vida no se quita el 2.º detalle (MALA GESTION); en Autos/Hogar se sigue quitando IMPAGO DEL SEGURO como SCA */
              a!dropdownField(
                choiceLabels: {
                  if(a!isNullOrEmpty(local!motivoAnulacion),
                    index(local!detalleDDVisible, "descripcion", {}),
                    if(and(local!motivoAnulacion = 1, not(local!polizaVidaAlta)),
                      index(remove(local!detalleDDVisible, 2), "descripcion", {}),
                      index(local!detalleDDVisible, "descripcion", {})))},
                choiceValues: {
                  if(a!isNullOrEmpty(local!motivoAnulacion),
                    index(local!detalleDDVisible, "codigo", {}),
                    if(and(local!motivoAnulacion = 1, not(local!polizaVidaAlta)),
                      index(remove(local!detalleDDVisible, 2), "codigo", {}),
                      index(local!detalleDDVisible, "codigo", {})))},
                label: "Detalle",
                labelPosition: "ABOVE",
                placeholder: "--- Seleccione ---",
                value: local!detalle,
                saveInto: {local!detalle, a!save(local!causa, null)},
                searchDisplay: "AUTO", required: true,
                disabled: a!isNullOrEmpty(local!motivoAnulacion))}),
            a!columnLayout(contents: {
              a!dropdownField(
                choiceLabels: index(local!causaDD, "descripcion", {}),
                choiceValues: index(local!causaDD, "codigo", {}),
                label: "Causa",
                labelPosition: "ABOVE",
                placeholder: "--- Seleccione ---",
                value: local!causa,
                saveInto: local!causa,
                searchDisplay: "AUTO", required: true,
                disabled: a!isNullOrEmpty(local!detalle))})
          }),
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: a!textField(
                  label: "Compañía aseguradora contraria",
                  labelPosition: "ABOVE",
                  value: if(
                    a!isNullOrEmpty(local!compania), "",
                    concat(index(local!compania, "codigo"), " - ",
                      index(local!compania, "descripcion"))),
                  disabled: true),
                width: "MEDIUM_PLUS"),
              a!columnLayout(
                contents: a!buttonArrayLayout(
                  buttons: a!buttonWidget(
                    label: "", icon: "search",
                    value: true, saveInto: local!showPopupCia,
                    size: "SMALL", style: "OUTLINE", color: "SECONDARY"),
                  align: "START", marginAbove: "STANDARD", marginBelow: "NONE"))
            },
            alignVertical: "BOTTOM"),
          a!columnsLayout(columns: {
            a!columnLayout(contents: {
              a!dropdownField(
                choiceLabels: index(index(local!canalDD, "values"), "data", null),
                choiceValues: index(index(local!canalDD, "values"), "identifiers", null),
                label: "Canal entrada contacto", labelPosition: "ABOVE",
                placeholder: "--- Seleccione ---",
                value: local!canalEntrada,
                saveInto: {local!canalEntrada, a!save(local!medioComunicacion, null)},
                searchDisplay: "AUTO", required: true)}),
            a!columnLayout(contents: {
              a!dropdownField(
                choiceLabels: index(index(local!medioDD, "values"), "data", {}),
                choiceValues: index(index(local!medioDD, "values"), "identifiers", {}),
                label: "Medio comunicación", labelPosition: "ABOVE",
                placeholder: "--- Seleccione ---",
                value: local!medioComunicacion,
                saveInto: local!medioComunicacion,
                searchDisplay: "AUTO",
                required: tointeger(a!defaultValue(local!canalEntrada, 0)) = 5,
                disabled: tointeger(a!defaultValue(local!canalEntrada, 0)) <> 5)}),
            a!columnLayout(contents: {
              a!textField(
                label: "Número fax", labelPosition: "ABOVE",
                value: local!numFax, saveInto: local!numFax,
                refreshAfter: "UNFOCUS",
                required: tointeger(a!defaultValue(local!medioComunicacion, 0)) = 1,
                disabled: tointeger(a!defaultValue(local!medioComunicacion, 0)) <> 1,
                validations: if(
                  and(tointeger(a!defaultValue(local!medioComunicacion, 0)) = 1,
                    regexmatch("^[0-9]{1,9}$", local!numFax)),
                  null,
                  "El formato del fax es incorrecto"))})
          }),
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: {
                  a!textField(
                    label: "Tipo catalogación",
                    value: "--- Seleccione ---",
                    showWhen: a!isNullOrEmpty(local!catalogacionDD),
                    required: true,
                    disabled: true),
                  a!dropdownField(
                    choiceLabels: a!forEach(
                      local!catalogacionDD,
                      cons!SCA2_TXT_TIP_CATALOGACION_PCA[tointeger(index(fv!item, "codCatalogacion"))]),
                    choiceValues: a!defaultValue(
                      index(local!catalogacionDD, "codCatalogacion", null), {}),
                    label: "Tipo catalogación", labelPosition: "ABOVE",
                    placeholder: "--- Seleccione ---",
                    value: local!tipoCatalogacion,
                    saveInto: local!tipoCatalogacion,
                    searchDisplay: "AUTO",
                    showWhen: a!isNotNullOrEmpty(local!catalogacionDD),
                    required: true)
                },    
                width: "MEDIUM"),
              a!columnLayout(
                contents: a!dateField(
                  label: "Fecha anulación", labelPosition: "ABOVE",
                  value: left(a!defaultValue(local!fechaAnulacionCambio, ""), 10),
                  saveInto: local!fechaAnulacion,
                  required: true,
                  disabled: if(
                    and(
                      local!tipoCatalogacion <> local!catalogacionOriginal,
                      local!tipoCatalogacion = "4"),
                    false,
                    or(
                      not(a!defaultValue(
                        index(local!consultaCatalogacion, "fechaHabilitada", null), "false")),
                      a!isNullOrEmpty(local!tipoCatalogacion)))),
                width: "NARROW"),
              a!columnLayout(
                contents: {
                  a!richTextDisplayField(),
                  a!cardLayout(
                    contents: a!sideBySideLayout(
                      items: {
                        a!sideBySideItem(
                          item: a!richTextDisplayField(labelPosition: "COLLAPSED",
                            value: a!richTextIcon(icon: "info-circle",
                              color: cons!SCA2_VAL_COLOR_AZUL_CLARO, size: "MEDIUM")),
                          width: "MINIMIZE"),
                        a!sideBySideItem(
                          item: a!richTextDisplayField(labelPosition: "COLLAPSED",
                            value: "Verifica la correcta catalogación de la fecha de anulación."))
                      },
                      alignVertical: "MIDDLE"),
                    style: "INFO",
                    accessibilityText: "Mensaje informativo")
                },
                width: "MEDIUM_PLUS")
            },
            alignVertical: "BOTTOM"),
          a!paragraphField(
            label: "Observaciones",
            labelPosition: "ABOVE",
            value: local!observaciones,
            saveInto: local!observaciones,
            refreshAfter: "UNFOCUS",
            characterLimit: 240,
            height: "MEDIUM"),
          a!horizontalLine(color: cons!SCA2_VAL_COLOR_BLANCO),
          if(a!isNotNullOrEmpty(local!mensaje),
            a!richTextDisplayField(value: a!richTextItem(text: local!mensaje,
              color: if(a!defaultValue(local!esError, false), "NEGATIVE", "POSITIVE"))), {}),
          a!buttonLayout(
            primaryButtons: {
              a!buttonWidget(
                label: "GUARDAR",
                loadingIndicator: true,
                style: "SOLID", color: cons!SCA2_VAL_COLOR_ROJO,
                disabled: or(
                  and(
                    a!defaultValue(local!procesoLanzado, false),
                    not(a!defaultValue(local!esError, false))),
                  a!isNotNullOrEmpty(local!idSolEfectiva),
                  a!defaultValue(local!sinEstructuraVida, false),
                  a!isNullOrEmpty(local!numPoliza),
                  a!isNullOrEmpty(local!motivoAnulacion),
                  a!isNullOrEmpty(local!detalle),
                  a!isNullOrEmpty(local!causa),
                  a!isNullOrEmpty(local!canalEntrada),
                  a!isNullOrEmpty(local!tipoCatalogacion),
                  a!isNullOrEmpty(local!fechaAnulacion),
                  and(tointeger(a!defaultValue(local!canalEntrada, 0)) = 5, a!isNullOrEmpty(local!medioComunicacion)),
                  and(tointeger(a!defaultValue(local!medioComunicacion, 0)) = 1, a!isNullOrEmpty(local!numFax))),
                tooltip: if(
                  or(
                    a!isNullOrEmpty(local!motivoAnulacion),
                    a!isNullOrEmpty(local!detalle),
                    a!isNullOrEmpty(local!causa),
                    a!isNullOrEmpty(local!canalEntrada),
                    a!isNullOrEmpty(local!tipoCatalogacion),
                    a!isNullOrEmpty(local!fechaAnulacion),
                    and(tointeger(a!defaultValue(local!canalEntrada, 0)) = 5, a!isNullOrEmpty(local!medioComunicacion)),
                    and(tointeger(a!defaultValue(local!medioComunicacion, 0)) = 1, a!isNullOrEmpty(local!numFax))),
                  "Revise los parámetros obligatorios del formulario.",
                  null),
                submit: true,
                confirmHeader: if(local!solicitudVigente, "¿Desea continuar?", null),
                confirmMessage: if(
                  local!solicitudVigente,
                  "Está grabando una solicitud con los mismos datos que la anterior. ¿Desea continuar?",
                  null
                ),
                saveInto: {
                  a!save(local!solicitudEnCurso, rule!SCA2_consultarSolicitudEnCurso(numPoliza: local!numPoliza)),
                  if(a!isNotNullOrEmpty(local!solicitudEnCurso), {}, {
                  a!save(local!mensaje, null), a!save(local!esError, null),
                  /* Paridad SCA (GUARDAR): recatalogar según la fecha mostrada y guardar la fecha de anulación efectiva (ronda 23-A). */
                  /* R23-B: null-safe — pólizas a futuro sin efecto/vencimiento en Emisión (text(null) rompía el GUARDAR) */
                  if(
                    a!isNullOrEmpty(local!fechaAnulacionCambio),
                    null,
                    if(
                      if(a!isNullOrEmpty(local!fechaEfectoAnualidadCurso), false, text(local!fechaAnulacionCambio, "dd/MM/yyyy") = text(local!fechaEfectoAnualidadCurso, "dd/MM/yyyy")),
                      a!save(local!tipoCatalogacion, "1"),
                      if(
                        if(a!isNullOrEmpty(local!fechaVencimiento), false, text(local!fechaAnulacionCambio, "dd/MM/yyyy") = text(local!fechaVencimiento, "dd/MM/yyyy")),
                        a!save(local!tipoCatalogacion, "2"),
                        null
                      )
                    )
                  ),
                  a!save(local!fechaAnulacion, local!fechaAnulacionCambio),
                  /* Paridad SCA (GUARDAR, ronda 9 A1/A3): detección PRRA por simulación NSE (código 4022 → motivo 3 / detalle 8 / causa 19),
                     validaciones (SCA2_erroresGuardarSolicitud, que incluye la simulación SCA2_simularAnulacion y los mensajes de alta) y
                     popup de simulación como SCA_SimularAnulacionPopup. El proceso se lanza desde el popup (ACEPTAR / NO / SI-CONTINUAR). */
                  a!localVariables(
                    local!fmt: "dd/MM/yyyy",
                    local!traducciones: rule!SCA2_obtenerTraduccionMotivosSca(
                      codMotivo: tostring(local!motivoAnulacion), codDetalle: tostring(local!detalle), codCausa: tostring(local!causa),
                      codCia: local!codCia, codRamo: local!codRamo),
                    local!prra: a!defaultValue(
                      tostring(index(index(rule!SCA2_simularAnulacionAltaNse(
                        numPoliza: local!numPoliza,
                        fechaSuplemento: if(a!isNullOrEmpty(local!fechaAnulacion), null, todatetime(todate(local!fechaAnulacion))),
                        codMotivo: index(local!traducciones, "codMotivoTra", null),
                        codDetalle: index(local!traducciones, "codDetalleTra", null),
                        codCausa: index(local!traducciones, "codCausaTra", null),
                        claveProduccion: local!claveProduccion,
                        codCatalogacion: tostring(local!tipoCatalogacion),
                        devolucionPrima: null,
                        codCia: tostring(local!codCia),
                        codProducto: local!codProducto,
                        codAcuerdo: local!codAcuerdoPol), "error", null), "code", null)) = tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022),
                      false),
                    local!err: rule!SCA2_erroresGuardarSolicitud(infoSolicitud: {
                      fechaAnulacion: if(a!isNullOrEmpty(local!fechaAnulacion), null, text(todate(local!fechaAnulacion), local!fmt)),
                      fechaEfecto: if(a!isNullOrEmpty(local!fechaEfectoAnualidadCurso), null, text(todate(local!fechaEfectoAnualidadCurso), local!fmt)),
                      polizawAutemis: local!polizawAutemis,
                      polizaNSEHogar: local!tipoPoliza = "NSE-Hogar",
                      polizaNSEAutos: local!tipoPoliza = "NSE-Autos",
                      fechaVencimiento: if(a!isNullOrEmpty(local!fechaVencimiento), null, text(todate(local!fechaVencimiento), local!fmt)),
                      fechaUltimoSiniestro: if(a!isNullOrEmpty(local!consultaFecUltimoSiniestro), null, text(todate(local!consultaFecUltimoSiniestro), local!fmt)),
                      fechaImpago: if(local!polizawAutemis,
                        substitute(left(a!defaultValue(index(index(local!pca, "ESTADO_RECIBOS", {}), "FEC_EFEC_RECIBO", ""), ""), 10), "-", "/"),
                        null),
                      codCatalogacion: tostring(local!tipoCatalogacion),
                      perfil: local!perfil, subperfil: local!subPerfil, nuuma: local!nuuma,
                      codMotivo: if(local!prra, "3", tostring(local!motivoAnulacion)), codCausa: if(local!prra, "19", tostring(local!causa)), codDetalle: if(local!prra, "8", tostring(local!detalle)),
                      canalEntrada: tostring(local!canalEntrada), codCia: local!codCia, codRamo: local!codRamo,
                      codAcuerdo: local!codAcuerdoPol, claveProduccion: local!claveProduccion, numPoliza: local!numPoliza,
                      canalProductor: index(local!tipoProductor, "idcanal", null), isSi24: index(local!tipoProductor, "essi24", null), codInt: local!codIntTomador, devolucionPrima: null, polizaVencida: local!polizaVencida}),
                    {
                      a!save(local!isPolizaPRRA, local!prra),
                      a!save(local!erroresGuardar, local!err),
                      if(a!isNotNullOrEmpty(index(local!err, "erroresGuardar", null)),
                        {
                          a!save(local!esError, true),
                          a!save(local!mensaje, "Se han detectado los siguientes errores: " & joinarray(index(local!err, "erroresGuardar", null), " "))
                        },
                        {
                          a!save(local!pasoANivel2, false),
                          a!save(local!expertosSi, false),
                          a!save(local!tlfSeleccionado, null),
                          a!save(local!showPopupSimular, true)
                        }
                      )
                    }
                  )

                  })                })},
            secondaryButtons: {
              a!buttonWidget(
                label: "CANCELAR",
                style: "OUTLINE", color: cons!SCA2_VAL_COLOR_GRIS_MEDIO,
                disabled: and(
                  not(a!defaultValue(local!esError, false)),
                  a!isNotNullOrEmpty(local!idSolEfectiva),
                  not(left(tostring(local!idSolEfectiva), 5) = "PDTE-"),
                  not(local!decisionLista)
                ),
                confirmHeader: "",
                confirmMessage: "Si sale de esta pantalla sin guardar los datos se perderán. ¿Desea salir de todos modos?",
                confirmButtonLabel: "Sí",
                cancelButtonLabel: "No",
                saveInto: {
                  a!save(local!motivoAnulacion, null),
                  a!save(local!detalle, null), a!save(local!causa, null),
                  a!save(local!observaciones, null), a!save(local!mensaje, null),
                  a!save(local!esError, null), a!save(local!idSolGenerada, null), a!save(local!procesoLanzado, null),
                  a!save(local!fechaLanzamiento, null),
                  a!save(local!compania, null), a!save(local!showPopupCia, false),
                  a!save(ri!numPoliza, null), a!save(ri!vista, "BUSQUEDA")})})
        },
        shape: "ROUNDED", showShadow: true,
        showWhen: not(a!defaultValue(local!showPopupSimular, false))),
      {}),
    /* Popup de simulación del alta (port de SCA_SimularAnulacionPopup, ronda 9 A1) */
    if(a!defaultValue(local!showPopupSimular, false),
      a!localVariables(
        local!erroresSimular: index(local!erroresGuardar, "erroresSimular", null),
        local!esErrorSimular: a!defaultValue(tostring(index(local!erroresSimular, "errorSimularAlta", null)), "") = "true",
        local!avanzar: a!defaultValue(toboolean(index(local!erroresSimular, "avanzarAltaSolicitud", null)), false),
        local!mostrarMensajesOAlta: index(local!erroresGuardar, "mensajesOAlta", null),
        local!primerMensaje: index(local!mostrarMensajesOAlta, "primerMensaje", null),
        local!segundoMensaje: index(local!mostrarMensajesOAlta, "segundoMensaje", null),
        local!documentos: index(local!segundoMensaje, "documentos", null),
        local!preguntaExpertos: a!defaultValue(tostring(index(local!segundoMensaje, "mensajeAltaAccionesAdm", null)), "") = "Esta póliza puede ser tratada en Contra Anulación por Expertos en retención. ¿Quieres pasar la Contra Anulación a Expertos en retención o no?",
        local!telefono1: index(split(a!defaultValue(tostring(index(local!datosTomador, "telefono1", null)), ""), ";"), 1, ""),
        local!telefono2: index(split(a!defaultValue(tostring(index(local!datosTomador, "telefono2", null)), ""), ";"), 1, ""),
        local!unionTelefonos: union(local!telefono1, local!telefono2),
        local!variosTelefonos: length(local!unionTelefonos) = 2,
        a!columnsLayout(
          columns: {
            a!columnLayout(width: "NARROW"),
            a!columnLayout(
              contents: {
                a!cardLayout(
                  contents: {
                    a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: if(
                        local!esErrorSimular,
                        a!richTextItem(text: a!defaultValue(tostring(index(local!erroresSimular, "respuesta", null)), "")),
                        {
                          a!richTextItem(
                            text: "Se han completado todas las validaciones para permitir generar la solicitud de anulación, se va a proceder a dar de alta la solicitud en el sistema"
                          ),
                          if(
                            and(
                              a!isNullOrEmpty(local!primerMensaje),
                              or(
                                a!isNullOrEmpty(local!segundoMensaje),
                                a!defaultValue(toboolean(index(local!segundoMensaje, "mostrarFueraNorma", false)), false)
                              )
                            ),
                            {},
                            {
                              char(10), char(10),
                              a!richTextItem(text: "Advertencia: ", style: "STRONG"),
                              a!richTextItem(
                                text: if(
                                  a!isNullOrEmpty(local!primerMensaje),
                                  concat(
                                    a!defaultValue(tostring(index(local!segundoMensaje, "mensajeAltaAccionesAdm", null)), ""),
                                    char(10),
                                    if(a!isNullOrEmpty(local!documentos), "", a!forEach(local!documentos, { fv!item, char(10) })),
                                    a!defaultValue(tostring(index(local!segundoMensaje, "mensajeFinalAltaAccAdm", null)), "")
                                  ),
                                  local!primerMensaje
                                )
                              )
                            }
                          )
                        }
                      )
                    )
                  },
                  height: "AUTO",
                  style: if(local!esErrorSimular, "ERROR", "INFO"),
                  marginBelow: "STANDARD"
                ),
                a!cardLayout(
                  contents: {
                    a!textField(
                      label: "Introduzca un teléfono",
                      labelPosition: "ABOVE",
                      instructions: "Introduzca un nuevo número de teléfono si lo desea",
                      placeholder: "Introduzca un número de teléfono",
                      value: if(
                        a!isNullOrEmpty(local!tlfSeleccionado),
                        if(a!isNullOrEmpty(local!tlfEditable), local!telefono1, local!tlfEditable),
                        local!tlfSeleccionado
                      ),
                      saveInto: local!tlfSeleccionado,
                      refreshAfter: "KEYPRESS",
                      characterLimit: 9,
                      required: true,
                      inputPurpose: "PHONE_NUMBER"
                    ),
                    a!dropdownField(
                      choiceLabels: if(local!variosTelefonos, {local!telefono1, local!telefono2}, {local!telefono1}),
                      choiceValues: if(local!variosTelefonos, {local!telefono1, local!telefono2}, {local!telefono1}),
                      label: "Número de teléfono",
                      labelPosition: "ABOVE",
                      placeholder: "--- Seleccione un teléfono ---",
                      value: local!tlfEditable,
                      saveInto: local!tlfEditable
                    )
                  },
                  height: "AUTO",
                  showWhen: and(not(local!esErrorSimular), local!expertosSi),
                  style: "INFO",
                  marginBelow: "STANDARD"
                ),
                a!buttonLayout(
                  primaryButtons: a!forEach(
                    items: {
                      /* ACEPTAR del error de simulación: sólo si la simulación permite continuar (p. ej. M206); M201 no lo muestra */
                      a!map(label: "ACEPTAR", mostrar: and(local!esErrorSimular, local!avanzar), nivel2: false, estilo: "SOLID"),
                      /* ACEPTAR del alta sin pregunta de Expertos */
                      a!map(label: "ACEPTAR", mostrar: and(not(local!esErrorSimular), not(local!preguntaExpertos)), nivel2: false, estilo: "SOLID"),
                      /* NO / SI (CONTINUAR) cuando se pregunta por Expertos en retención */
                      a!map(label: "NO", mostrar: and(not(local!esErrorSimular), local!preguntaExpertos), nivel2: false, estilo: "OUTLINE"),
                      a!map(label: if(local!expertosSi, "CONTINUAR", "SI"), mostrar: and(not(local!esErrorSimular), local!preguntaExpertos), nivel2: true, estilo: "SOLID")
                    },
                    expression: a!buttonWidget(
                      label: fv!item.label,
                      showWhen: fv!item.mostrar,
                      style: fv!item.estilo,
                      color: cons!SCA2_VAL_COLOR_ROJO,
                      loadingIndicator: true,
                      disabled: and(fv!item.nivel2, local!expertosSi, or(a!isNullOrEmpty(local!tlfSeleccionado), tostring(local!tlfSeleccionado) = "0")),
                      saveInto: if(
                        and(fv!item.nivel2, not(local!expertosSi)),
                        {
                          a!save(local!pasoANivel2, true),
                          a!save(local!expertosSi, true)
                        },
                        {
                          a!save(local!solicitudEnCurso, rule!SCA2_consultarSolicitudEnCurso(numPoliza: local!numPoliza)),
                          if(a!isNotNullOrEmpty(local!solicitudEnCurso),
                            a!save(local!showPopupSimular, false), {
                          a!save(local!pasoANivel2, fv!item.nivel2),
                          if(fv!item.nivel2, a!save(local!telefonoExpertos, local!tlfSeleccionado), {}),
                          a!save(local!showPopupSimular, false),
        a!save(local!fechaLanzamiento, now()),
                                  a!startProcess(
                            processModel: cons!SCA2_PM_CMD_ALTA,
                            processParameters: {
                              datosContexto: rule!SCA2_construirContextoAlta(
                                numPoliza: local!numPoliza,
                                motivo: if(a!defaultValue(local!isPolizaPRRA, false), "3", tostring(local!motivoAnulacion)),
                                detalle: if(a!defaultValue(local!isPolizaPRRA, false), "8", tostring(local!detalle)),
                                causa: if(a!defaultValue(local!isPolizaPRRA, false), "19", tostring(local!causa)),
                                catalogacion: tostring(local!tipoCatalogacion),
                                canalEntrada: tostring(local!canalEntrada),
                                lineaNegocio: tostring(local!lineaNegocio),
                                idGestionSGC: "",
                                fecAnulacion: left(tostring(local!fechaAnulacion), 10),
                                observaciones: local!observaciones,
                                descCausa: if(a!isNullOrEmpty(local!causa), null, tostring(index(index(index(local!causaDD, "descripcion", {}), wherecontains(tointeger(local!causa), tointeger(index(local!causaDD, "codigo", {}))), {}), 1, null))),
                                idioma: "es",
                                usuario: local!nuuma,
                                numFax: local!numFax,
                                idCompania: if(a!isNullOrEmpty(local!compania), null,
                                  tostring(index(local!compania, "codigo", null)))),
                              numPoliza: local!numPoliza,
                              lineaNegocio: tostring(local!lineaNegocio),
                              origen: "SCA2",
                              origenPoliza: tostring(local!tipoPoliza),
                              canal: tostring(local!canalEntrada),
                              idioma: "es",
                              rol: local!perfil,
                              usuario: loggedInUser(),
                              gestionSGC: "",
                              motivoReal: tostring(local!motivoAnulacion),
                              detalleReal: tostring(local!detalle),
                              causaReal: tostring(local!causa),
                              telefonoExpertos: local!telefonoExpertos,
                              idCompania: if(a!isNullOrEmpty(local!compania), null,
                                tointeger(index(local!compania, "codigo", null))),
                              rsvPrima: index(local!datosCliente, "rsvPrima", null),
                              /* Marca de reserva/devolución de prima con la que la simulación fue aceptada (S/N); se registra para la mecanización */
                              mcaRsvPrima: index(index(local!erroresGuardar, "erroresSimular", null), "mcaRsvPrima", null),
                              isPolizaPRRA: a!defaultValue(local!isPolizaPRRA, false)
                            },
                            /* R42-A: síncrono (Alta → Decidir → CrearAccion ya son Start Process síncronos): al volver la primera gestión ya existe y ACEPTAR se habilita al instante.
                               Si Appian no lo completa en su límite síncrono (onIncomplete) se mantiene la espera con sondeo de R35-A/R41. */
                            isSynchronous: true,
                            onSuccess: {
                              a!save(local!procesoLanzado, true),
                              a!save(local!idSolGenerada, index(index(fv!processInfo, "pv", {}), "idSolicitud", null)),
                              /* R48-A: un solo aviso. Si al volver el alta síncrona ya existe la gestión pendiente se abre directamente, sin el segundo ACEPTAR */
                              a!localVariables(
                                local!idSolOk: tostring(index(index(fv!processInfo, "pv", {}), "idSolicitud", null)),
                                local!tareaOk: if(
                                  or(a!isNullOrEmpty(local!idSolOk), left(local!idSolOk, 5) = "PDTE-"),
                                  null,
                                  index(index(a!queryRecordType(
                                    recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                                      a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud', operator: "=", value: local!idSolOk),
                                      a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado', operator: "=", value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE)}),
                                    fields: {'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo'},
                                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1, sort: a!sortInfo(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', ascending: false)),
                                    fetchTotalCount: false), "data", {}), 1, null)
                                ),
                                if(
                                  a!isNullOrEmpty(local!tareaOk),
                                  {},
                                  {
                                    a!save(local!aceptarPulsado, true),
                                    a!save(ri!idSolicitudSel, local!idSolOk),
                                    a!save(ri!tipoAccion, index(local!tareaOk, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo', null)),
                                    a!save(ri!idTarea, index(local!tareaOk, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', null)),
                                    a!save(ri!vista, "DETALLE")
                                  }
                                )
                              )
                            },
                            onIncomplete: {
                              a!save(local!procesoLanzado, true)
                            },
                            onError: {
                              a!save(local!esError, true),
                              a!save(local!mensaje, "Los datos no se han podido guardar correctamente. La solicitud no se ha podido crear. Error técnico al lanzar el proceso de alta. Póliza: " & a!defaultValue(tostring(ri!numPoliza), "") & ". Reporte este error a mantenimiento SCA.")
                            })
                          })
                        }
                      )
                    )
                  ),
                  secondaryButtons: {
                    a!buttonWidget(
                      label: if(local!esErrorSimular, "VOLVER", "CANCELAR"),
                      saveInto: {
                        a!save(local!showPopupSimular, false),
                        a!save(local!expertosSi, false),
                        a!save(local!pasoANivel2, false)
                      },
                      color: cons!SCA2_VAL_COLOR_GRIS_MEDIO
                    )
                  }
                )
              }
            ),
            a!columnLayout(width: "NARROW")
          }
        )
      ),
      {}),
    if(local!showPopupCia,
      a!cardLayout(
        contents: rule!SCA2_BuscarCompaniasContrarias(
          show: local!showPopupCia, seleccion: local!compania),
        showBorder: false()),
      {})
  }
)
