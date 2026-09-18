/* Calcula el rollup de una ejecución a partir de sus resultados persistidos.
   Devuelve {totalPruebas, totalOk, totalKo, totalWarn, totalSkip, estado}. */
a!localVariables(
  local!res: a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    fields: {
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'
    },
    filters: a!queryFilter(
      field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
      operator: "=",
      value: ri!ejecucionId
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1000),
    fetchTotalCount: true
  ),
  local!vals: index(local!res.data, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', {}),
  local!ok: count(wherecontains("OK", touniformstring(local!vals))),
  local!ko: count(wherecontains("KO", touniformstring(local!vals))),
  local!warn: count(wherecontains("WARN", touniformstring(local!vals))),
  local!skip: count(wherecontains("SKIP", touniformstring(local!vals))),
  local!total: local!res.totalCount,
  local!faltan: a!defaultValue(ri!esperadas, local!total) - local!total,
  a!map(
    totalPruebas: local!total,
    totalOk: local!ok,
    totalKo: local!ko + max(local!faltan, 0),
    totalWarn: local!warn,
    totalSkip: local!skip,
    estado: if(
      or(local!ko > 0, local!faltan > 0),
      "KO",
      if(local!warn > 0, "WARN", "OK")
    )
  )
)
