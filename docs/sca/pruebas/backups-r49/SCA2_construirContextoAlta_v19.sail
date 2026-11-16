a!localVariables(
  local!tipoP: rule!SCA2_obtenerTipoPoliza(numPoliza: ri!numPoliza),
  local!esAut: local!tipoP = cons!SCA2_TXT_WAUTEMIS,
  /* R43-A: rama Vida Riesgo como SCA_AltaSolicitudAnulacionEstrategicas (servicio de Vida, cía 3, ramo 101) */
  local!esVida: local!tipoP = cons!SCA2_TXT_VIDA_RIESGO,
  local!polVida: if(local!esVida,
    rule!SCA2_consultarPolizaVidaRiesgo(numPoliza: ri!numPoliza, responseDetailLevel: ""), null),
  local!contratoVida: reduce(index(_, _, null), local!polVida, {"contractData", 1}),
  local!codOficinaVida: reduce(index(_, _, null), local!polVida, {"producersData", 1, "salesOfficeCode"}),
  local!codAgtVida: if(local!esVida,
    rule!SCA2_getCodAgenteVida(producersData: index(local!polVida, "producersData", null)), null),
  /* R45-A (A2): una sola consulta a estructurasComerciales (cía 3, codAgenteVida, codOficinaDirecta) para la clave (codAgente) y la estructura comercial de Vida */
  local!estructuraVida: if(and(local!esVida, a!isNotNullOrEmpty(local!codAgtVida)),
    rule!SCA2_consultarEstructuraComercial(codCompania: cons!SCA2_INT_COD_CIA_VIDA,
      codOficinaDirecta: local!codOficinaVida, codAgenteVida: local!codAgtVida),
    null),
  local!claveProduccionVida: if(local!esVida,
    a!defaultValue(
      index(local!estructuraVida, "codAgente", null),
      index(rule!SCA2_consultarClavevida(codCia: cons!SCA2_INT_COD_CIA_VIDA,
        codOficina: local!codOficinaVida, codAgente: local!codAgtVida), "idClaveProduccion", null)),
    null),
  local!fechaVida: a!forEach(
    items: {index(local!contratoVida, "effectiveDate", null), index(local!contratoVida, "dueDate", null)},
    expression: a!localVariables(
      local!p: split(left(a!defaultValue(tostring(fv!item), ""), 10), "/"),
      if(count(local!p) = 3,
        date(tointeger(index(local!p, 3, null)), tointeger(index(local!p, 2, null)), tointeger(index(local!p, 1, null))),
        null))),
  local!polizaNSE: if(
    or(local!esAut, local!esVida),
    null,
    a!localVariables(
      local!r: rule!SCA2_pObtenerPolizaFecha({
        pcodcia: 41, pnumpoliza: ri!numPoliza, pnumapli: 0,
        pnumsptoapli: 0, pmcaconsultaglobal: "S", pmcalk: "S"
      }),
      if(
        or(
          a!isNullOrEmpty(index(local!r, "MSSPObtenerPolizaFecha", null)),
          a!isNullOrEmpty(index(index(local!r, "MSSPObtenerPolizaFecha", null), "poconpolizat", null))
        ),
        rule!SCA2_pObtenerPolizaFecha({
          pcodcia: 41, pnumpoliza: ri!numPoliza, pnumapli: 0,
          pnumsptoapli: 0, pmcaconsultaglobal: "S", pmcalk: "S",
          pfechaconsulta: todate(a!addDateTime(today(), 1))
        }),
        local!r
      )
    )
  ),
  local!pca: if(local!esVida, null, index(
    rule!SCA2_consultarPolizas(P_NUM_POLIZA: ri!numPoliza),
    "MSSConsultarPolizas",
    "DATOS_PCA",
    null
  )),
  local!pol: index(local!pca, "DATOS_POLIZA", {}),
  local!to: index(local!pca, "DATOS_TO", {}),
  local!strc: index(local!pca, "DATOS_STR_COMER", {}),
  local!veh: index(local!pca, "DATOS_VEHIC", {}),
  local!ch: index(local!pca, "DATOS_CH", {}),
  local!rec: index(local!pca, "ESTADO_RECIBOS", {}),
  local!polNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "datosgeneralespol", "array", 1}),
  local!agNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "agente", "array", 1}),
  local!sptoNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "datosgeneralesspto", "array", 1}),
  local!figNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", "figurasparticipantes", 1, "array", "figuraparticipante"}),
  local!tomadorNSE: index(index(local!figNSE,
    wherecontains("TO", index(local!figNSE, "codinterv", null))), 1, null),
  local!conductorNSE: index(index(local!figNSE,
    wherecontains("CH", index(local!figNSE, "codinterv", null))), 1, null),
  local!caracPolNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "caracteristicas", "array"}),
  local!caracNSE: index(
    reduce(index(_, _, null), local!polizaNSE,
      {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "riesgos", "array", 1, "caracteristicas", "array"}),
    wherecontains(
      {"COD_CATEGORIA", "COD_MARCA", "COD_MODELO", "COD_TIPO_VEHIC", "FEC_PRIM_MATRIC", "NUM_MATRICULA"},
      index(reduce(index(_, _, null), local!polizaNSE,
        {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "riesgos", "array", 1, "caracteristicas", "array"}),
        "codcampo", null))),
  local!planesNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", "planespago", 1, "array", 1}),
  local!codciaNSE: reduce(index(_, _, null), local!polizaNSE,
    {"MSSPObtenerPolizaFecha", "poconpolizat", "array", 1, "codcia"}),
  local!pfNSE: reduce(index(_, _, null), local!tomadorNSE,
    {"datospersonales", "array", 1, "personafisica"}),
  local!usr: index(rule!SCA2_obtenerInformacionUsuario(), "infoUsuarioDTO", {}),
  local!perfil: a!defaultValue(index(local!usr, "codPerfil", null), cons!SCA2_TXT_PERFIL_CE_RM),
  local!subPerfil: a!defaultValue(index(local!usr, "codSubPerfil", null), cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA),
  local!nuuma: a!defaultValue(index(split(tostring(ri!usuario), "@"), 1, null), index(local!usr, "nuuma", null)),
  local!catalog: a!defaultValue(ri!catalogacion, "1"),
  local!impago: if(
    local!esAut,
    index(local!rec, "MCA_IMPAGADOS", "N") = "S",
    index(local!sptoNSE, "codestadopoliza", "") = "5"
  ),
  local!usrMap: {codPerfil: local!perfil, codSubPerfil: local!subPerfil},
  local!canal: a!defaultValue(
    ri!canalEntrada,
    index(rule!SCA2_calculoCanalEntrada(usuario: local!usrMap, impago: local!impago), "default", null)
  ),
  local!medio: index(
    rule!SCA2_calculoMedioComunicacion(usuario: local!usrMap, codCanalEntrada: local!canal),
    "default",
    null
  ),
  /* codTpOrigen como SCA: "1" solo si wAutemis con FEC_EFEC_RECIBO; si no, por motivo */
  local!tpOrigen: if(
    and(local!esAut, a!isNotNullOrEmpty(index(local!rec, "FEC_EFEC_RECIBO", null))),
    "1",
    a!match(
      value: tostring(ri!motivo),
      equals: "3", then: "3",
      equals: "1", then: "2",
      equals: "2", then: "4",
      default: null
    )
  ),
  local!searchAPI: rule!SCA2_searchAPIClients(
    request: {"policyNumber": ri!numPoliza, "searchDetail": {"potencialInd": true()}}),
  local!profileAPI: rule!SCA2_perfilAPIClients(clientId: index(local!searchAPI, "clientId", null)),
  local!contactMethodAPI: rule!SCA2_contactMethodAPIClients(idCliente: index(local!searchAPI, "clientId", null)),
  local!consultaClave: reduce(index(_, _, null),
    rule!SCA2_consultaClave(
      codCia: if(local!esAut, "1", "41"),
      codTerceroAgt: if(local!esAut,
        index(local!strc, "CLAVE_PRODUCCION", ""),
        index(local!agNSE, "codterceroagt", "")),
      codIdioma: "ES_es"),
    {"MSSConsultaClave", "p_objeto_agt_clave_s", "COD_CLASE_AGT"}),
  local!tipoProductor: reduce(index(_, _, null),
    rule!SCA2_obtenerDatosProductor(pidclaseclaveprod: local!consultaClave),
    {"MSSObtenerDatosProductor", "plistadatosprod", 1}),
  local!fecEfec: if(local!esAut, index(local!pol, "FEC_EFEC_PER", null), local!esVida, index(local!fechaVida, 1, null), index(local!sptoNSE, "fecefecpoliza", null)),
  local!fecVcto: if(local!esAut, index(local!pol, "FEC_VCTO_PER", null), local!esVida, index(local!fechaVida, 2, null), index(local!sptoNSE, "fecvctopoliza", null)),
  {
    infoUsuarios: {
      codCiaUsuario: index(local!usr, "codCiaUsuario", 41),
      nuuma: local!nuuma,
      codPerfil: local!perfil,
      codSubPerfil: local!subPerfil
    },
    datosCod: {
      codCausa: ri!causa,
      codMedioComunicacion: local!medio,
      codTpCanalEntrada: local!canal,
      codTpNegocio: ri!lineaNegocio,
      codTpOrigen: local!tpOrigen,
      codTpCatalogacion: local!catalog,
      codCIAContraria: ri!idCompania,
      codClaveProduccion: if(local!esAut,
        index(local!strc, "CLAVE_PRODUCCION", null),
        local!esVida, local!claveProduccionVida,
        index(local!agNSE, "codterceroagt", null)),
      codInt: if(local!esAut,
        index(local!to, "COD_INT", null),
        local!esVida, index(local!searchAPI, "clientId", null),
        index(local!tomadorNSE, "codint", null)),
      perfilTeCuidamos: null,
      socioTeCuidamos: null,
      numDocumento: if(local!esAut,
        index(local!to, "NUM_DOCUM", null),
        local!esVida, index(local!searchAPI, "identityDocumentNumber", null),
        index(local!tomadorNSE, "coddocum", null))
    },
    datosNumCod: {
      numPoliza: ri!numPoliza,
      codMotivo: ri!motivo,
      codDetalle: ri!detalle,
      numApli: index(if(local!esAut, local!pol, local!polNSE),
        if(local!esAut, "NUM_APLI", "numapli"), null),
      codRamo: if(local!esVida, cons!SCA2_TXT_COD_RAMO_VIDA,
        index(if(local!esAut, local!pol, local!polNSE),
        if(local!esAut, "COD_RAMO", "codproducto"), null)),
      codProducto: if(
        local!esAut,
        index(local!pol, "COD_PRODUCTO", null),
        local!esVida,
        index(local!contratoVida, "commercialProductCode", null),
        /* R49-D: como SCA_AltaSolicitudAnulacionEstrategicas (Hogar HG01; Autos por TIP_VEHICULO = 4ª característica) */
        if(
          local!tipoP = cons!SCA2_TXT_NSE_HOGAR,
          "HG01",
          local!tipoP = cons!SCA2_TXT_NSE_AUTOS,
          if(
            or(
              index(index(local!caracNSE, 4, null), "valcampo", "") = "00000006",
              index(index(local!caracNSE, 4, null), "valcampo", "") = "00000007",
              index(index(local!caracNSE, 4, null), "valcampo", "") = "00000008",
              index(index(local!caracNSE, 4, null), "valcampo", "") = "00000019"
            ),
            "AU02",
            "AU01"
          ),
          ""
        )
      ),
      codCompania: if(local!esAut, index(local!pol, "COD_CIA", null), local!esVida, tostring(cons!SCA2_INT_COD_CIA_VIDA), local!codciaNSE),
      idSolicitud: null,
      idGestionSGC: a!defaultValue(ri!idGestionSGC, 0),
      idGestionSTCAT: null,
      txtSistemaOrigen: "",
      codAccionComercial: if(
        or(local!catalog = "4", local!catalog = "1"),
        "2707",
        if(or(local!catalog = "2", local!catalog = "3"), "6098", null)
      ),
      numFaxPCA: ri!numFax,
      /* R45-A: en Vida la estructura comercial sale de estructurasComerciales (codDgt, codDt, codOficinaDirecta) */
      estructComercial: {
        DGT: if(local!esVida, index(local!estructuraVida, "codDgt", null), index(local!agNSE, "codelemnivel1", index(local!strc, "DGT", null))),
        codSubcentral: if(local!esVida, index(local!estructuraVida, "codDt", null), index(local!agNSE, "codelemnivel2", index(local!strc, "COD_SUBCENTRAL", null))),
        codOfidir: if(local!esVida, index(local!estructuraVida, "codOficinaDirecta", null), index(local!agNSE, "codelemnivel3", index(local!strc, "COD_OFIDIR", null)))
      }
    },
    datosOtros: {
      nomProducto: if(local!esAut,
        index(local!pol, "NOM_PRODUCTO", null),
        local!esVida, index(local!contratoVida, "commercialProductName", null),
        index(local!sptoNSE, "nomprodcomercial", null)),
      observaciones: ri!observaciones,
      descCausa: ri!descCausa,
      /* R45-A: en Vida la prima anual sale de premiumData de la póliza, como «Prima actual» de la cabecera */
      prima: if(local!esAut,
        index(local!pol, "IMP_PRIMA", null),
        local!esVida,
        a!localVariables(
          local!importeVida: todecimal(reduce(index(_, _, null), local!polVida, {"premiumData", 1, "periodicContribution", 1, "premiumAmn"})),
          local!frecVida: tointeger(reduce(index(_, _, null), local!polVida, {"premiumData", 1, "periodicContribution", 1, "contributionFrequencyCode"})),
          if(a!isNullOrEmpty(local!importeVida), null,
            local!importeVida * a!match(value: local!frecVida, equals: 2, then: 2, equals: 3, then: 4, equals: 4, then: 12, default: 1))
        ),
        todecimal(index(local!planesNSE, "impprimatotalperiodo", null))),
      tipCliente: rule!SCA2_obtenerMcaTipoCliente(
        desc: reduce(index(_, _, null), local!profileAPI, {"actualTypology", "typologyDesc"}),
        value: reduce(index(_, _, null), local!profileAPI, {"actualTypology", "typologyValue"}),
        category: reduce(index(_, _, null), local!profileAPI, {"actualTypology", "clientCategory"})),
      identificadorClave: if(local!esAut,
        index(local!veh, "MATRICULA", null),
        index(index(local!caracNSE, 6, null), "valcampo", null)),
      canalDeEjecucion: local!perfil,
      contacto: local!canal,
      tlfPasoExperto: index(index(index(local!contactMethodAPI,
        wherecontains("TELEFONO MOVIL",
          touniformstring(index(local!contactMethodAPI, "contactMethodTypeDesc", null)))),
        "contactMethodValue", null), 1, null),
      codIntegridadCliente: null
    },
    datosFec: {
      fecAnulacion: if(
        a!isNotNullOrEmpty(ri!fecAnulacion),
        a!localVariables(
          local!fs: left(tostring(ri!fecAnulacion), 10),
          local!f: split(local!fs, "-"),
          if(length(local!f) = 3,
            index(local!f, 3, "") & "/" & index(local!f, 2, "") & "/" & index(local!f, 1, ""),
            local!fs)),
        if(
          local!catalog = "4",
          text(today(), "dd/MM/yyyy"),
          if(
            or(local!catalog = "2", local!catalog = "3"),
            text(local!fecVcto, "dd/MM/yyyy"),
            text(local!fecEfec, "dd/MM/yyyy")
          )
        )
      ),
      /* Paridad SCA (SCA_AltaSolicitudAnulacion): CORE no admite la fecha de recibo aquí (4005) */
      fecImpagoPCA: null,
      fecEstado: null,
      fecSolicitudAnul: local!fecVcto
    },
    datosReemplazo: {
      numPolizaReemplazo: null,
      numApliReemplazo: "0",
      codCiaReemplazo: if(local!esAut, index(local!pol, "COD_CIA", null), local!esVida, tostring(cons!SCA2_INT_COD_CIA_VIDA), local!codciaNSE),
      oficinaUsuario: null,
      oficinaDirectaUsuario: null
    },
    datosProductor: {
      accesosgc: index(local!tipoProductor, "accesosgc", null),
      desccanal: index(local!tipoProductor, "desccanal", null),
      descclaseprod: index(local!tipoProductor, "descclaseprod", null),
      descsubcanal: index(local!tipoProductor, "descsubcanal", null),
      esredtel: index(local!tipoProductor, "esredtel", null),
      essi24: index(local!tipoProductor, "essi24", null),
      estele: index(local!tipoProductor, "estele", null),
      idcanal: index(local!tipoProductor, "idcanal", null),
      idclaseprod: index(local!tipoProductor, "idclaseprod", null),
      idsubcanal: index(local!tipoProductor, "idsubcanal", null),
      tipoaccesosgc: index(local!tipoProductor, "tipoaccesosgc", null),
      tipomediacion: index(local!tipoProductor, "tipomediacion", null),
      anulaExpertos: a!defaultValue(index(local!tipoProductor, "anulaExpertos", null), false),
      anulaTecnicos: a!defaultValue(index(local!tipoProductor, "anulaTecnicos", null), false)
    },
    datosPolizaAutos: {
      vehiculo: {
        codTipCntrLocalizador: if(local!esAut, index(local!veh, "COD_TIP_CONTR_LOCALIZADOR", null), null),
        codTipLocalizador: if(local!esAut, index(local!veh, "COD_TIP_LOCALIZADOR", null), null)
      },
      codPromocion: if(local!esAut, index(local!pol, "COD_PROMOCION", null), null),
      tomador: {
        codCalificacion: if(local!esAut,
          index(local!to, "COD_CALIFICACION", null),
          index(index(local!caracPolNSE,
            wherecontains("COD_SCORE", index(local!caracPolNSE, "codcampo", null))),
            "valcampo", null)),
        fechaDeNacimiento: if(local!esAut,
          index(local!to, "FEC_NACIMIENTO", null),
          index(local!pfNSE, "fecnac", null))
      },
      conductor: {
        estadoCivil: if(local!esAut,
          index(local!to, "ESTADO_CIVIL", null),
          a!defaultValue(
            reduce(index(_, _, null), local!conductorNSE,
              {"licencia", "array", 1, "personafisica", "codtipestcivil"}),
            "2")),
        fechaCarne: if(local!esAut, index(local!ch, "FEC_CARNET", null),
          reduce(index(_, _, null), local!conductorNSE,
            {"datospersonales", "array", 1, "fecexplicencia"}))
      },
      codGama: if(local!esAut, index(local!pol, "COD_GAMA", null), null),
      descGama: if(local!esAut, index(local!pol, "DESC_GAMA", null), null),
      estructuraComercial: {
        codOficinaComercial: if(local!esAut,
          index(local!strc, "OFICINA_COMERCIAL", null),
          index(local!agNSE, "nomelemnivel4", null)),
        codClaseAgente: index(local!tipoProductor, "idclaseprod", null)
      },
      acuerdo: if(local!esAut,
        index(local!pol, "COD_ACUERDO", null),
        index(local!polNSE, "codacuerdo", null)),
      tipoDeAcuerdo: if(local!esAut, index(local!pol, "TIP_ACUERDO", null), null),
      fechaEfectoAnualidadCurso: local!fecEfec,
      fechaDeEfectoInicial: if(local!esAut,
        index(local!pol, "FEC_EFECT_INI", null),
        index(local!sptoNSE, "fecefecspto", null)),
      fechaDeVencimiento: local!fecVcto,
      fechaDeEfectoAnulacion: if(local!esAut, index(local!pol, "FEC_EFEC_ANUL", null), null)
    },
    datosPolizaHogar: {
      tomador: {
        codCalificacion: if(local!esAut, null,
          index(index(local!caracPolNSE,
            wherecontains("COD_SCORE", index(local!caracPolNSE, "codcampo", null))),
            "valcampo", null)),
        fechaDeNacimiento: if(local!esAut, null, index(local!pfNSE, "fecnac", null)),
        tomadorEsConductor: null
      },
      estructuraComercial: {
        codOficinaComercial: if(local!esAut, null, index(local!agNSE, "nomelemnivel4", null))
      }
    },
    datosContexto: {
      canal: local!perfil,
      idioma: ri!idioma,
      idNegocio: ri!lineaNegocio,
      rol: "SOLICITUD",
      usuario: local!nuuma
    }
  }
)
