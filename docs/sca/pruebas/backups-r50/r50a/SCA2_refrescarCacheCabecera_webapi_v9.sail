=if(
  a!isNullOrEmpty(http!request),
  a!httpResponse(statusCode: 204),
  a!localVariables(
    local!r: rule!SCA2_renovarCacheCabecera(idSolicitud: index(index(http!request, "queryParameters", a!map()), "idSolicitud", ""), numPoliza: index(index(http!request, "queryParameters", a!map()), "numPoliza", ""), usuario: index(index(http!request, "queryParameters", a!map()), "usuario", "")),
    local!cab: {a!httpHeader(name: "Content-Type", value: "application/json")},
    if(
      a!isNotNullOrEmpty(index(local!r, "error", null)),
      a!httpResponse(statusCode: 400, headers: local!cab, body: a!toJson(a!map(error: index(local!r, "error", null)))),
      if(
        a!isNullOrEmpty(index(local!r, "cabecera", null)),
        a!httpResponse(statusCode: 204),
        a!writeRecords(
          records: index(local!r, "fila", null),
          /* r38-a §11: tras escribir, borra las filas sobrantes de la solicitud (queda solo la de mayor id) */
          onSuccess: a!localVariables(
            local!sobrantes: rule!SCA2_obtenerFilasDuplicadasCacheCabecera(idSolicitud: index(index(http!request, "queryParameters", a!map()), "idSolicitud", "")),
            if(
              a!isNullOrEmpty(local!sobrantes),
              a!httpResponse(statusCode: 200, headers: local!cab, body: a!toJson(index(local!r, "cabecera", null))),
              a!deleteRecords(
                records: local!sobrantes,
                onSuccess: a!httpResponse(statusCode: 200, headers: local!cab, body: a!toJson(index(local!r, "cabecera", null))),
                onError: a!httpResponse(statusCode: 200, headers: local!cab, body: a!toJson(index(local!r, "cabecera", null)))
              )
            )
          ),
          onError: a!httpResponse(statusCode: 200, headers: local!cab, body: a!toJson(index(local!r, "cabecera", null)))
        )
      )
    )
  )
)