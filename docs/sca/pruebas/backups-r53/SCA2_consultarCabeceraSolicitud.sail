/**********************************************************************************

  Llamada a integracion 
  https://core7.pre.mapfre.net:26007/PCA_CORECFSA_HTTPRouter/IGenerarContraAnul
  Autor: NTT Data
  Parámetro:
    Entrada:
      - codSolicitud: Código solicitud

***********************************************************************************/
a!localVariables(
  /*Construimos la peticion que usaremos para las pruebas*/
  local!MSEConsultarCabecera: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}solicitudDTO'(
    codSolicitud: ri!codSolicitud
  ),
  local!consultarCabecera: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarCabecera'(
    MSEConsultarCabecera: local!MSEConsultarCabecera 
  ),
  /*Ejecutamos la integracion*/
  local!resultado: rule!SCA2_consultarCabeceraIntegracion(
    host: cons!SCAC_VAL_HOST_CORE7,
    endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
    consulta: local!consultarCabecera
  ),
  /*Recibimos la respuesta y nos quedamos con el xml del body*/
  local!tmp: index(local!resultado, "result","body", null), 
  local!cdtTmp: xpathsnippet(local!tmp, "/*/soapenv:Body/*"),
  /*Convertimos la respuesta al CDT en cuestion.*/
  torecord(local!cdtTmp, 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarCabeceraResponse'())
)