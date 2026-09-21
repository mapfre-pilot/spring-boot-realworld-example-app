a!localVariables(
  local!antes: a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    fields: {
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs'
    },
    filters: a!queryFilter(
      field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
      operator: "=",
      value: ri!idAntes
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500)
  ).data,
  local!despues: a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    fields: {
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs'
    },
    filters: a!queryFilter(
      field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
      operator: "=",
      value: ri!idDespues
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500)
  ).data,
  local!codigoAntes: index(local!antes, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo', {}),
  local!codigoDespues: index(local!despues, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo', {}),
  local!codigos: union(local!codigoAntes, local!codigoDespues),
  local!filas: a!forEach(
    items: local!codigos,
    expression: a!localVariables(
      local!a: index(local!antes, wherecontains(fv!item, local!codigoAntes), null()),
      local!d: index(local!despues, wherecontains(fv!item, local!codigoDespues), null()),
      local!ra: index(local!a, 1, null()),
      local!rd: index(local!d, 1, null()),
      local!resultadoAntes: index(local!ra, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', null()),
      local!resultadoDespues: index(local!rd, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', null()),
      a!map(
        codigo: fv!item,
        nombre: a!defaultValue(index(local!rd, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre', null()), index(local!ra, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre', null())),
        categoria: a!defaultValue(index(local!rd, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria', null()), index(local!ra, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria', null())),
        sistema: a!defaultValue(index(local!rd, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema', null()), index(local!ra, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema', null())),
        resultadoAntes: local!resultadoAntes,
        resultadoDespues: local!resultadoDespues,
        mensajeAntes: index(local!ra, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje', null()),
        mensajeDespues: index(local!rd, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje', null()),
        duracionAntes: index(local!ra, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs', null()),
        duracionDespues: index(local!rd, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs', null()),
        cambio: if(
          isnull(local!resultadoAntes), "NUEVA",
          if(isnull(local!resultadoDespues), "AUSENTE",
            if(or(and(or(local!resultadoAntes = "OK", local!resultadoAntes = "WARN"), local!resultadoDespues = "KO"), and(local!resultadoAntes = "OK", local!resultadoDespues = "WARN")), "REGRESION",
              if(or(and(local!resultadoAntes = "KO", or(local!resultadoDespues = "OK", local!resultadoDespues = "WARN")), and(local!resultadoAntes = "WARN", local!resultadoDespues = "OK")), "MEJORA",
                if(local!resultadoAntes = local!resultadoDespues, "IGUAL", "IGUAL")
              )
            )
          )
        )
      )
    )
  ),
  local!prioridad: {"REGRESION", "NUEVA", "AUSENTE", "MEJORA", "IGUAL"},
  local!cambios: touniformstring(index(local!filas, "cambio", {})),
  a!flatten(
    a!forEach(
      items: local!prioridad,
      expression: index(local!filas, wherecontains(fv!item, local!cambios), {})
    )
  )
)
