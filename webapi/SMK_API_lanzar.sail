/* POST /smoke_runs  body: {"codigos":[], "categorias":[], "sistemas":[], "motivo":"...", "origen":"CI|INSTALACION|INTERVENCION|..."}
   Crea la SMK Ejecucion (EN_CURSO), lanza SMK Ejecutar Pruebas con su id y responde 202 con el id definitivo. */
a!localVariables(
  local!body: if(a!isNullOrEmpty(index(http!request, "body", "")), a!map(), a!fromJson(index(http!request, "body", ""))),
  local!codigosRaw: touniformstring(a!flatten({index(local!body, "codigos", {})})),
  local!categoriasRaw: touniformstring(a!flatten({index(local!body, "categorias", {})})),
  local!sistemasRaw: touniformstring(a!flatten({index(local!body, "sistemas", {})})),
  local!codigos: index(local!codigosRaw, where(len(local!codigosRaw) > 0), {}),
  local!categorias: index(local!categoriasRaw, where(len(local!categoriasRaw) > 0), {}),
  local!sistemas: index(local!sistemasRaw, where(len(local!sistemasRaw) > 0), {}),
  local!motivo: left(a!defaultValue(index(local!body, "motivo", null), "Lanzado por Web API"), 4000),
  local!origen: left(a!defaultValue(index(local!body, "origen", null), "API"), 100),
  local!json: a!httpHeader(name: "Content-Type", value: "application/json"),
  a!writeRecords(
    records: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion'(
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio': now(),
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado': "EN_CURSO",
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen': local!origen,
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo': local!motivo,
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{541ebf63-f4c4-4892-a696-265d622c55fc}lanzadoPor': loggedInUser()
    ),
    onSuccess: a!localVariables(
      local!id: fv!recordsUpdated[1]['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id'],
      a!startProcess(
        processModel: cons!SMK_PM_EJECUTAR_PRUEBAS,
        processParameters: a!map(
          ejecucionId: local!id,
          codigos: if(a!isNullOrEmpty(local!codigos), null, local!codigos),
          categorias: if(a!isNullOrEmpty(local!categorias), null, local!categorias),
          sistemas: if(a!isNullOrEmpty(local!sistemas), null, local!sistemas),
          motivo: local!motivo,
          origen: local!origen,
          lanzadoPor: loggedInUser()
        ),
        onSuccess: a!httpResponse(
          statusCode: 202,
          headers: { local!json },
          body: a!toJson(a!map(
            ejecucionId: local!id,
            processId: fv!processInfo.pp.id,
            estado: "EN_CURSO",
            estadoUrl: "/suite/webapi/smoke_run?id=" & local!id,
            resultadosUrl: "/suite/webapi/smoke_run_results?id=" & local!id
          ))
        ),
        onError: a!httpResponse(
          statusCode: 500,
          headers: { local!json },
          body: a!toJson(a!map(error: "No se pudo iniciar el runner de pruebas de humo", ejecucionId: local!id))
        )
      )
    ),
    onError: a!httpResponse(
      statusCode: 500,
      headers: { local!json },
      body: a!toJson(a!map(error: "No se pudo crear la ejecución"))
    )
  )
)
