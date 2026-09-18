/* GET /smoke_run?id={ejecucionId}  -> estado y totales de la ejecución */
a!localVariables(
  local!id: tointeger(index(index(http!request, "queryParameters", a!map()), "id", null)),
  local!ej: if(
    a!isNullOrEmpty(local!id),
    {},
    a!queryRecordType(
      recordType: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion',
      filters: a!queryFilter(field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id', operator: "=", value: local!id),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
    ).data
  ),
  if(
    a!isNullOrEmpty(local!ej),
    a!httpResponse(
      statusCode: 404,
      headers: { a!httpHeader(name: "Content-Type", value: "application/json") },
      body: a!toJson(a!map(error: "Ejecución no encontrada", id: local!id))
    ),
    a!localVariables(
      local!e: local!ej[1],
      local!estado: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado'],
      local!parcial: rule!SMK_resumenEjecucion(ejecucionId: local!id, esperadas: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas']),
      a!httpResponse(
        statusCode: 200,
        headers: { a!httpHeader(name: "Content-Type", value: "application/json") },
        body: a!toJson(a!map(
          ejecucionId: local!id,
          estado: local!estado,
          terminada: local!estado <> "EN_CURSO",
          origen: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen'],
          motivo: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo'],
          lanzadoPor: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{541ebf63-f4c4-4892-a696-265d622c55fc}lanzadoPor'],
          fechaInicio: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio'],
          fechaFin: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1bcfff8e-df5c-4bcf-be02-110148d4d995}fechaFin'],
          duracionMs: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'],
          totalPruebas: local!e['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas'],
          completadas: local!parcial.totalPruebas,
          totalOk: local!parcial.totalOk,
          totalKo: local!parcial.totalKo,
          totalWarn: local!parcial.totalWarn,
          totalSkip: local!parcial.totalSkip
        ))
      )
    )
  )
)
