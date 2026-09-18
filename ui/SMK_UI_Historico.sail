a!localVariables(
  local!estado: null,
  local!desde: null,
  local!hasta: null,
  local!ejecucionSel: null,
  a!headerContentLayout(
    header: rule!SMK_UI_Cabecera(
      icono: "history",
      titulo: "Histórico de ejecuciones",
      subtitulo: "Consulta las ejecuciones realizadas y sus resultados"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(contents: a!dropdownField(
            label: "Estado",
            choiceLabels: {"OK", "KO", "WARN", "EN_CURSO"},
            choiceValues: {"OK", "KO", "WARN", "EN_CURSO"},
            value: local!estado,
            saveInto: local!estado,
            placeholder: "Todos"
          )),
          a!columnLayout(contents: a!dateField(label: "Desde", value: local!desde, saveInto: local!desde)),
          a!columnLayout(contents: a!dateField(label: "Hasta", value: local!hasta, saveInto: local!hasta))
        }
      ),
      a!cardLayout(
        contents: a!gridField(
        label: "Ejecuciones",
        data: a!recordData(
          recordType: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion',
          filters: a!queryLogicalExpression(
            operator: "AND",
            logicalExpressions: {},
            filters: {
              a!queryFilter(
                field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado',
                operator: "=",
                value: local!estado
              ),
              a!queryFilter(
                field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
                operator: ">=",
                value: local!desde
              ),
              a!queryFilter(
                field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
                operator: "<=",
                value: local!hasta
              )
            },
            ignoreFiltersWithEmptyValues: true
          ),
        ),
        columns: {
          a!gridColumn(
            label: "ID",
            value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(
              text: tostring(fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id']),
              link: a!dynamicLink(saveInto: a!save(local!ejecucionSel, fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id']))
            ))
          ),
          a!gridColumn(label: "Fecha inicio", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio']),
          a!gridColumn(label: "Estado", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado'], style: "STRONG", color: a!match(value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado'], equals: "OK", then: cons!SMK_COLOR_EXITO, equals: "KO", then: cons!SMK_COLOR_ERROR, equals: "WARN", then: cons!SMK_COLOR_AVISO, default: cons!SMK_COLOR_AZUL_GRIS)))),
          a!gridColumn(label: "Origen", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen']),
          a!gridColumn(label: "Motivo", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo']),
          a!gridColumn(label: "OK", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk']),
          a!gridColumn(label: "KO", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo']),
          a!gridColumn(label: "WARN", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn']),
          a!gridColumn(label: "Duración ms", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'])
        },
        initialSorts: a!sortInfo(
          field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
          ascending: false
        ),
        pageSize: 20,
        borderStyle: "LIGHT",
        shadeAlternateRows: true
      ),
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false,
        style: cons!SMK_COLOR_BLANCO,
        padding: "STANDARD",
        marginBelow: "STANDARD"
      ),
      if(
        isnull(local!ejecucionSel),
        {},
        {
          a!buttonArrayLayout(
            buttons: a!buttonWidget(label: "Cerrar detalle", icon: "times", style: "LINK", saveInto: a!save(local!ejecucionSel, null)),
            align: "END",
            marginAbove: "STANDARD"
          ),
          rule!SMK_UI_DetalleEjecucion(ejecucionId: local!ejecucionSel)
        }
      )
    }
  )
)
