/**********************************************************************************

  SE EJECUTA LA INTEGRACIÓN 
  https://esb.desa.mapfre.net:25005/ARQ_Usuarios_SMEDWeb/sca/wUsuarios
  NOS QUEDAMOS CON EL BODY Y FINALMENTE CONVERTIMOS A CDT

  Autor: NTT Data
  Parámetro:
    Entrada:
      - nuuma: Nombre corto(nickname)     

***********************************************************************************/
a!localVariables(
  /*Llamada a la integración para recuperar los roles*/
  local!response: rule!CMP_APIUsuarios_ObtenerRoles(nuuma: ri!nuuma),
  /*Transformamos la respuesta XML*/
  local!xpathSnippet: xpathsnippet(index(index(local!response, "result", null),"body", null), "/*/soapenv:Body/*"),
  local!roles: torecord(local!xpathSnippet, 'type!{http://ARQ_Usuarios_SMED/wsdl/ARQ_Usuarios_SMED}consultarRolesResponse'()),
  reduce(
    index(_,_,null),
    local!roles,
    {"roles", "rol"}
  )
)