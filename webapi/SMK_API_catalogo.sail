/* GET /smoke_tests[?categoria=HTTP&sistema=host]  -> catálogo de pruebas activas */
a!localVariables(
  local!cat: index(index(http!request, "queryParameters", a!map()), "categoria", null),
  local!sis: index(index(http!request, "queryParameters", a!map()), "sistema", null),
  local!tests: rule!SMK_seleccionarPruebas(
    codigos: null,
    categorias: if(a!isNullOrEmpty(local!cat), null, split(local!cat, ",")),
    sistemas: if(a!isNullOrEmpty(local!sis), null, split(local!sis, ","))
  ),
  a!httpResponse(
    statusCode: 200,
    headers: { a!httpHeader(name: "Content-Type", value: "application/json") },
    body: a!toJson(a!map(
      total: count(local!tests),
      tests: a!forEach(
        items: local!tests,
        expression: a!map(
          codigo: fv!item['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo'],
          nombre: fv!item['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a47b7e2b-7082-494e-b909-a551766e2f69}nombre'],
          categoria: fv!item['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria'],
          sistema: fv!item['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema'],
          criticidad: fv!item['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{7b63c157-05d3-4de7-a1b7-e8b1b0cce28e}criticidad'],
          umbralMs: fv!item['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs']
        )
      )
    ))
  )
)
