a!localVariables(
  local!filtros: a!flatten({
    a!queryFilter(
      field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo',
      operator: "=",
      value: if(a!isNullOrEmpty(ri!codigos), true(), null())
    ),
    if(a!isNullOrEmpty(ri!codigos), {}, a!queryFilter(
      field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo',
      operator: "in",
      value: a!flatten({ri!codigos})
    )),
    if(a!isNullOrEmpty(ri!categorias), {}, a!queryFilter(
      field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria',
      operator: "in",
      value: a!flatten({ri!categorias})
    )),
    if(a!isNullOrEmpty(ri!sistemas), {}, a!queryFilter(
      field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema',
      operator: "in",
      value: a!flatten({ri!sistemas})
    ))
  }),
  a!queryRecordType(
    recordType: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test',
    fields: {
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b7020821-b4b7-41fc-a9eb-4f11ced13c7c}id',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a47b7e2b-7082-494e-b909-a551766e2f69}nombre',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a99c7f60-a4b0-48ea-8ab2-918ddc2d2831}descripcion',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{7b63c157-05d3-4de7-a1b7-e8b1b0cce28e}criticidad',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{90077757-4a1d-4ddf-a4b9-6e666c6a6606}orden',
      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs'
    },
    filters: a!queryLogicalExpression(operator: "AND", filters: local!filtros, ignoreFiltersWithEmptyValues: true),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500, sort: {
      a!sortInfo(field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{90077757-4a1d-4ddf-a4b9-6e666c6a6606}orden', ascending: true),
      a!sortInfo(field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo', ascending: true)
    }),
    fetchTotalCount: false
  ).data
)
