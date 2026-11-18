a!localVariables(
  /*Construimos la peticion que usaremos para las pruebas  */
  local!polizasDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}polizasDTO'(
    numPoliza: ri!numPoliza
  ),
  local!codIntDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}codIntDTO'(
    codInt: ri!codInt
  ),
  local!mseConsultarSolicitudesDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarSolicitudesDTO'(
    numPoliza: local!polizasDTO,
    tpBusqueda: ri!tpBusqueda,
    listCodInt: local!codIntDTO
  ),
  local!consultarSolicitudes: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarSolicitudes'(
    MSEConsultarSolicitudes: local!mseConsultarSolicitudesDTO
  ),
  /*Ejecutamos la integracion*/
  local!resultado: rule!SCA2_consultarSolicitudesIntegracion(
    host: cons!SCAC_VAL_HOST_CORE7,
    endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
    consulta: local!consultarSolicitudes
  ),

  /*Recibimos la respuesta y nos quedamos con el xml del body*/
  local!tmp: index(index(local!resultado, "result", null), "body", null),
  local!cdtTmp: xpathsnippet(local!tmp, "/*/soapenv:Body/*"),

  /*Convertimos la respuesta al CDT en cuestion.*/
  torecord(local!cdtTmp, 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarSolicitudesResponse'())
)