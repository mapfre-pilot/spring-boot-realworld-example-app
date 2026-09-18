/* GET /smoke_run_results?id={ejecucionId}[&resultado=KO,WARN]  -> resultados por prueba */
a!localVariables(
  local!id: tointeger(index(index(http!request, "queryParameters", a!map()), "id", null)),
  local!filtroRes: touniformstring(a!flatten(split(a!defaultValue(index(index(http!request, "queryParameters", a!map()), "resultado", ""), ""), ","))),
  local!filtroRes2: reject(fn!isnull, local!filtroRes),
  local!estado: if(a!isNullOrEmpty(local!id), null, rule!SMK_resumenEjecucion(ejecucionId: local!id)),
  local!res: if(a!isNullOrEmpty(local!id), a!map(data: {}, totalCount: 0), a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        a!queryFilter(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId', operator: "=", value: local!id),
        if(
          a!isNullOrEmpty(local!filtroRes2),
          {},
          a!queryFilter(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', operator: "in", value: local!filtroRes2)
        )
      }
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1000, sort: a!sortInfo(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', ascending: false)),
    fetchTotalCount: true
  )),
  a!httpResponse(
    statusCode: if(a!isNullOrEmpty(local!id), 400, 200),
    headers: { a!httpHeader(name: "Content-Type", value: "application/json") },
    body: a!toJson(a!map(
      ejecucionId: local!id,
      resumen: local!estado,
      total: local!res.totalCount,
      resultados: a!forEach(
        items: local!res.data,
        expression: a!map(
          testCodigo: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo'],
          testNombre: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre'],
          categoria: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria'],
          sistema: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema'],
          resultado: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'],
          mensaje: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje'],
          detalle: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{089c041c-624d-4ce5-96ab-df18c74e5671}detalle'],
          duracionMs: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs'],
          fechaInicio: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{dc44be34-fe85-4b8a-9c9b-e7817b3676c9}fechaInicio'],
          fechaFin: fv!item['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{ec728354-513b-47e3-9655-9a93e291654f}fechaFin']
        )
      )
    ))
  )
)
