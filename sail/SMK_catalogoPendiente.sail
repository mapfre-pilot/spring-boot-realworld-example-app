/* Devuelve, como registros SMK Test listos para a!writeRecords, las pruebas del catálogo base
   (rule!SMK_catalogoBase) cuyo código aún no existe en SMK_TEST. Lista vacía si está sincronizado. */
a!localVariables(
  local!base: rule!SMK_catalogoBase(),
  local!existentes: touniformstring(
    index(
      a!queryRecordType(
        recordType: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test',
        fields: {'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000)
      ).data,
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo',
      {}
    )
  ),
  local!codigosBase: touniformstring(index(local!base, "codigo", {})),
  local!faltan: touniformstring(
    reject(
      fn!contains(local!existentes, _),
      local!codigosBase
    )
  ),
  a!forEach(
    items: index(local!base, wherecontains(local!faltan, local!codigosBase), {}),
    expression: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test'(
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo': fv!item.codigo,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a47b7e2b-7082-494e-b909-a551766e2f69}nombre': fv!item.nombre,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria': fv!item.categoria,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema': fv!item.sistema,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a99c7f60-a4b0-48ea-8ab2-918ddc2d2831}descripcion': fv!item.descripcion,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{7b63c157-05d3-4de7-a1b7-e8b1b0cce28e}criticidad': fv!item.criticidad,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo': fv!item.activo,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{90077757-4a1d-4ddf-a4b9-6e666c6a6606}orden': fv!item.orden,
        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs': fv!item.umbralMs
      )
  )
)
