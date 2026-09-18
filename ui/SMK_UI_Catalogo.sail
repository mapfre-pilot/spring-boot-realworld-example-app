a!localVariables(
  local!categoria: null,
  local!texto: "",
  a!headerContentLayout(
    header: a!cardLayout(
      contents: a!richTextDisplayField(
      value: {
        a!richTextItem(text: "Catálogo de pruebas", style: "STRONG", size: "LARGE"),
        char(10),
        a!richTextItem(text: "Pruebas activas disponibles para las ejecuciones de humo", color: "SECONDARY")
      }
      ),
      style: "STANDARD",
      marginBelow: "STANDARD"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(contents: a!dropdownField(
            label: "Categoría",
            choiceLabels: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
            choiceValues: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
            value: local!categoria,
            saveInto: local!categoria,
            placeholder: "Todas"
          )),
          a!columnLayout(contents: a!textField(
            label: "Texto",
            placeholder: "Buscar por código o nombre",
            value: local!texto,
            saveInto: local!texto
          ))
        }
      ),
      a!gridField(
        label: "Pruebas",
        data: a!recordData(
          recordType: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test',
          filters: a!queryLogicalExpression(
            operator: "AND",
            filters: {
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria',
                operator: "=",
                value: local!categoria
              ),
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo',
                operator: "includes",
                value: local!texto
              )
            },
            ignoreFiltersWithEmptyValues: true
          ),
        ),
        columns: {
          a!gridColumn(label: "Código", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo']),
          a!gridColumn(label: "Nombre", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a47b7e2b-7082-494e-b909-a551766e2f69}nombre']),
          a!gridColumn(label: "Categoría", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria']),
          a!gridColumn(label: "Sistema", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema']),
          a!gridColumn(label: "Criticidad", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{7b63c157-05d3-4de7-a1b7-e8b1b0cce28e}criticidad']),
          a!gridColumn(label: "Activo", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo']),
          a!gridColumn(label: "Umbral ms", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs'])
        },
        pageSize: 20,
        borderStyle: "LIGHT",
        shadeAlternateRows: true
      )
    }
  )
)
