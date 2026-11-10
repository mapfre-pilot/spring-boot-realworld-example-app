a!localVariables(
  local!r: choose(
    a!defaultValue(ri!modo, 1),
    rule!SCA2_consultarPolizaVidaRiesgo(numPoliza: ri!numPoliza, responseDetailLevel: ""),
    rule!SCA2_searchAPIClients(request: {
      "policyNumber": ri!numPoliza,
      "policyRolesFilter": "policyRolesFilter":{
        "startDate": datetext(today(),"yyyy-MM-dd"),
        "policyRoleIds":{"12"},
      },
      "searchDetail": {"potencialInd": true, "notVisible": true}
    }),
    rule!SCA2_consultarSolicitudes(numPoliza: ri!numPoliza, codInt: "", tpBusqueda: "0"),
    a!localVariables(
      local!a: rule!SCA2_consultarPolizaVidaRiesgo(numPoliza: ri!numPoliza, responseDetailLevel: ""),
      local!b: rule!SCA2_searchAPIClients(request: {
        "policyNumber": ri!numPoliza,
        "policyRolesFilter": "policyRolesFilter":{
          "startDate": datetext(today(),"yyyy-MM-dd"),
          "policyRoleIds":{"12"},
        },
        "searchDetail": {"potencialInd": true, "notVisible": true}
      }),
      local!c: rule!SCA2_consultarSolicitudes(numPoliza: ri!numPoliza, codInt: "", tpBusqueda: "0"),
      {a: local!a, b: local!b, c: local!c}
    ),
    a!forEach(
      items: {1, 2, 3},
      expression: choose(
        fv!item,
        rule!SCA2_consultarPolizaVidaRiesgo(numPoliza: ri!numPoliza, responseDetailLevel: ""),
        rule!SCA2_searchAPIClients(request: {
          "policyNumber": ri!numPoliza,
          "policyRolesFilter": "policyRolesFilter":{
            "startDate": datetext(today(),"yyyy-MM-dd"),
            "policyRoleIds":{"12"},
          },
          "searchDetail": {"potencialInd": true, "notVisible": true}
        }),
        rule!SCA2_consultarSolicitudes(numPoliza: ri!numPoliza, codInt: "", tpBusqueda: "0")
      )
    )
  ),
  {modo: ri!modo, tamano: len(tostring(local!r))}
)
