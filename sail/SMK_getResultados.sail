/* Resultados de una ejecución, opcionalmente filtrados por resultado (OK/KO/WARN/SKIP).
   Devuelve el datasubset completo (data + totalCount). */
a!localVariables(
  local!lista: reject(fn!isnull, touniformstring(a!flatten({ri!resultados}))),
  local!filtro: index(local!lista, where(len(local!lista) > 0), {}),
  a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    fields: {
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{fd4208ff-713a-4043-b70e-14d16dcd7bd2}id',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{089c041c-624d-4ce5-96ab-df18c74e5671}detalle',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{dc44be34-fe85-4b8a-9c9b-e7817b3676c9}fechaInicio',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{ec728354-513b-47e3-9655-9a93e291654f}fechaFin'
    },
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        a!queryFilter(
          field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
          operator: "=",
          value: ri!ejecucionId
        ),
        if(
          a!isNullOrEmpty(local!filtro),
          {},
          a!queryFilter(
            field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
            operator: "in",
            value: local!filtro
          )
        )
      }
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 1000,
      sort: {
        a!sortInfo(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', ascending: false),
        a!sortInfo(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo', ascending: true)
      }
    ),
    fetchTotalCount: true
  )
)
