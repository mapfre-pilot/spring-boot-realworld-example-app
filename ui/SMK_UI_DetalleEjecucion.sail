a!localVariables(
  local!ejecucion: a!queryRecordType(
    recordType: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion',
    fields: {
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1bcfff8e-df5c-4bcf-be02-110148d4d995}fechaFin',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn'
    },
    filters: a!queryFilter(
      field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
      operator: "=",
      value: ri!ejecucionId
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
  ).data,
  local!fila: index(local!ejecucion, 1, {}),
  local!resumen: rule!SMK_resumenEjecucion(
    ejecucionId: ri!ejecucionId,
    esperadas: index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas', 0)
  ),
  local!resultadoFiltro: null,
  local!resultadoSel: null,
  local!detalle: if(
    isnull(local!resultadoSel),
    "",
    index(
      a!queryRecordType(
        recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
        fields: {'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{089c041c-624d-4ce5-96ab-df18c74e5671}detalle'},
        filters: a!queryFilter(
          field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{fd4208ff-713a-4043-b70e-14d16dcd7bd2}id',
          operator: "=",
          value: local!resultadoSel
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
      ).data,
      1,
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{089c041c-624d-4ce5-96ab-df18c74e5671}detalle',
      ""
    )
  ),
  a!headerContentLayout(
    header: a!cardLayout(
      contents: a!richTextDisplayField(
      value: {
        a!richTextItem(text: "Detalle de ejecución #" & tostring(ri!ejecucionId), style: "STRONG", size: "LARGE"),
        char(10),
        a!richTextItem(
          text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado', "")),
          style: "STRONG"
        )
      }
      ),
      style: "STANDARD",
      marginBelow: "STANDARD"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(contents: a!richTextDisplayField(value: {
            a!richTextItem(text: "Inicio: ", style: "STRONG"),
            a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio', ""))),
            char(10),
            a!richTextItem(text: "Fin: ", style: "STRONG"),
            a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1bcfff8e-df5c-4bcf-be02-110148d4d995}fechaFin', "")))
          })),
          a!columnLayout(contents: a!richTextDisplayField(value: {
            a!richTextItem(text: "OK: " & tostring(index(local!resumen, "totalOk", 0)), color: "POSITIVE"),
            char(10),
            a!richTextItem(text: "KO: " & tostring(index(local!resumen, "totalKo", 0)), color: "NEGATIVE"),
            char(10),
            a!richTextItem(text: "WARN: " & tostring(index(local!resumen, "totalWarn", 0)), color: "ACCENT"),
            char(10),
            a!richTextItem(text: "Total: " & tostring(index(local!resumen, "totalPruebas", 0)))
          }))
        }
      ),
      if(
        index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado', "") = "EN_CURSO",
        a!richTextDisplayField(value: a!richTextItem(text: "En curso: " & tostring(index(local!resumen, "completadas", 0)) & " de " & tostring(index(local!resumen, "totalPruebas", 0)) & " completadas", color: "SECONDARY")),
        {}
      ),
      a!dropdownField(
        label: "Filtrar resultado",
        choiceLabels: {"OK", "KO", "WARN", "SKIP"},
        choiceValues: {"OK", "KO", "WARN", "SKIP"},
        value: local!resultadoFiltro,
        saveInto: local!resultadoFiltro,
        placeholder: "Todos"
      ),
      a!gridField(
        label: "Resultados",
        data: a!recordData(
          recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
          fields: {
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{fd4208ff-713a-4043-b70e-14d16dcd7bd2}id',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje',
            'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs',
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
              a!queryFilter(
                field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
                operator: "=",
                value: local!resultadoFiltro
              )
            },
            ignoreFiltersWithEmptyValues: true
          ),
        ),
        columns: {
          a!gridColumn(label: "Resultado", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'], style: "STRONG", color: a!match(value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'], equals: "OK", then: "POSITIVE", equals: "KO", then: "NEGATIVE", equals: "WARN", then: "ACCENT", default: "SECONDARY")))),
          a!gridColumn(label: "Categoría", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria']),
          a!gridColumn(label: "Sistema", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema']),
          a!gridColumn(label: "Código", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo'], link: a!dynamicLink(saveInto: a!save(local!resultadoSel, fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{fd4208ff-713a-4043-b70e-14d16dcd7bd2}id']))))),
          a!gridColumn(label: "Nombre", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre']),
          a!gridColumn(label: "Mensaje", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje']),
          a!gridColumn(label: "Duración ms", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs']),
          a!gridColumn(label: "Fin", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{ec728354-513b-47e3-9655-9a93e291654f}fechaFin'])
        },
        pageSize: 20,
        borderStyle: "LIGHT",
        shadeAlternateRows: true
      ),
      a!paragraphField(
        label: "Detalle",
        value: local!detalle,
        readOnly: true,
        showWhen: not(isnull(local!resultadoSel))
      )
    }
  )
)
