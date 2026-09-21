a!localVariables(
  local!agg: a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    fields: a!aggregationFields(
      groupings: {
        a!grouping(
          field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
          alias: "resultado"
        )
      },
      measures: {
        a!measure(
          field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{fd4208ff-713a-4043-b70e-14d16dcd7bd2}id',
          function: "COUNT",
          alias: "n"
        )
      }
    ),
    filters: a!queryFilter(
      field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
      operator: "=",
      value: a!defaultValue(ri!ejecucionId, -1)
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20)
  ),
  local!filas: if(a!isNullOrEmpty(local!agg.data), {}, local!agg.data),
  local!ok: sum(a!forEach(items: local!filas, expression: if(index(fv!item, "resultado", "") = "OK", tointeger(index(fv!item, "n", 0)), 0))),
  local!ko: sum(a!forEach(items: local!filas, expression: if(index(fv!item, "resultado", "") = "KO", tointeger(index(fv!item, "n", 0)), 0))),
  local!warn: sum(a!forEach(items: local!filas, expression: if(index(fv!item, "resultado", "") = "WARN", tointeger(index(fv!item, "n", 0)), 0))),
  local!skip: sum(a!forEach(items: local!filas, expression: if(index(fv!item, "resultado", "") = "SKIP", tointeger(index(fv!item, "n", 0)), 0))),
  local!total: sum(a!forEach(items: local!filas, expression: tointeger(index(fv!item, "n", 0)))),
  local!faltan: a!defaultValue(ri!esperadas, local!total) - local!total,
  a!map(
    totalPruebas: local!total,
    totalOk: local!ok,
    totalKo: tointeger(local!ko + max(local!faltan, 0)),
    totalWarn: local!warn,
    totalSkip: local!skip,
    estado: if(
      or(local!ko > 0, local!faltan > 0),
      "KO",
      if(local!warn > 0, "WARN", "OK")
    )
  )
)
