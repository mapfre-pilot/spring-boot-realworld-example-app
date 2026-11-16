a!localVariables(
  /*Nos quedamos con los tres primeros números de la póliza, ya que son los que nos dirán de qué tipo es*/
  /* R49-E: max(0, …) evita el error de repeat() con 14 o más caracteres (p. ej. un espacio al final); hasta 13 el resultado no cambia */
  local!inicio: left(
    concat(
      repeat(tointeger(max(0, 13 - len(ri!numPoliza))), "0"),
      ri!numPoliza
    ),
    3
  ),
  local!tipoPoliza: a!match(
    value: local!inicio,
    equals: cons!SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS,
    then: cons!SCA2_TXT_NSE_AUTOS,
    equals: "073",
    then: cons!SCA2_TXT_NSE_HOGAR,
    equals: "873",
    then: cons!SCA2_TXT_NSE_HOGAR,
    default: "otro"
  ),
  if(
    local!tipoPoliza = "otro",
    {
      a!localVariables(
        local!codCia: index(rule!SCA2_pBuscarPoliza(
          a!map(
            pcodcia: 90,
            pnumpoliza: concat(repeat(tointeger(max(0, 13 - len(ri!numPoliza))), "0"), ri!numPoliza),
            pnumapli: 0,
            pfechaconsulta: now(),
            pmcalk:"S",
          )
        ), "MSSPBuscarPoliza", "pconinfobasicat", "array", 1, "codcia", null),
        local!match:a!match(
          value: tointeger(local!codCia),
          equals: 1,
          then: cons!SCA2_TXT_WAUTEMIS,
          equals: 14,
          then: cons!SCA2_TXT_WAUTEMIS,
          equals: 10,
          then: cons!SCA2_TXT_WAUTEMIS,
          equals: 41,
          then: cons!SCA2_TXT_NSE_AUTOS,
          default: cons!SCA2_TXT_VIDA_RIESGO
        ),
        local!match
      )
    },
    local!tipoPoliza
  )

)