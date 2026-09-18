a!localVariables(
  local!refresh: 0,
  local!ejecucionSel: null,
  local!ejecuciones: a!queryRecordType(
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
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'
    },
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 10,
      sort: a!sortInfo(
        field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
        ascending: false
      )
    )
  ),
  local!ultima: index(local!ejecuciones.data, 1, {}),
  local!ultimaId: index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id', null),
  local!estado: index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado', null),
  local!estadoColor: if(
    local!estado = "OK",
    "POSITIVE",
    if(local!estado = "WARN", "ACCENT", if(local!estado = "KO", "NEGATIVE", "SECONDARY"))
  ),
  local!categorias: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
  a!headerContentLayout(
    header: a!cardLayout(
      contents: a!richTextDisplayField(
        value: {
          a!richTextItem(text: "Panel de pruebas de humo", style: "STRONG", size: "LARGE"),
          char(10),
          a!richTextItem(text: "Visión general de la última ejecución y del histórico reciente", color: "SECONDARY")
        }
      ),
      style: "STANDARD",
      marginBelow: "STANDARD"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: {
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: {
                      a!richTextItem(text: "Última ejecución", style: "STRONG"),
                      char(10),
                      a!richTextItem(text: tostring(local!ultimaId), size: "LARGE"),
                      char(10),
                      a!richTextItem(text: tostring(local!estado), color: local!estadoColor, style: "STRONG")
                    }
                  )
                },
                style: "STANDARD",
                marginBelow: "STANDARD"
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: {
                      a!richTextItem(text: "Totales", style: "STRONG"),
                      char(10),
                      a!richTextItem(text: "OK: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk', 0)), color: "POSITIVE"),
                      char(10),
                      a!richTextItem(text: "KO: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo', 0)), color: "NEGATIVE"),
                      char(10),
                      a!richTextItem(text: "WARN: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn', 0)), color: "ACCENT")
                    }
                  )
                },
                style: "STANDARD",
                marginBelow: "STANDARD"
              )
            }
          ),
          a!columnLayout(
            contents: {
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: {
                      a!richTextItem(text: "Contexto", style: "STRONG"),
                      char(10),
                      a!richTextItem(text: "Fecha: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio', ""))),
                      char(10),
                      a!richTextItem(text: "Origen: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen', ""))),
                      char(10),
                      a!richTextItem(text: "Motivo: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo', "")))
                    }
                  )
                },
                style: "STANDARD",
                marginBelow: "STANDARD"
              )
            }
          )
        }
      ),
      a!richTextDisplayField(
        value: a!richTextItem(text: "Semáforo por categoría", style: "STRONG", size: "MEDIUM"),
        marginAbove: "STANDARD"
      ),
      a!columnsLayout(
        columns: a!forEach(
          items: local!categorias,
          expression: a!localVariables(
            local!cat: fv!item,
            local!catData: a!queryRecordType(
              recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
              fields: {
                'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'
              },
              filters: a!queryLogicalExpression(
                operator: "AND",
                filters: {
                  a!queryFilter(
                    field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
                    operator: "=",
                    value: local!ultimaId
                  ),
                  a!queryFilter(
                    field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria',
                    operator: "=",
                    value: local!cat
                  )
                }
              ),
              pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 100)
            ),
            local!resultados: index(local!catData.data, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', {}),
            local!ko: count(wherecontains("KO", local!resultados)),
            local!warn: count(wherecontains("WARN", local!resultados)),
            local!ok: count(wherecontains("OK", local!resultados)),
            a!columnLayout(
              contents: a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: {
                      a!richTextItem(text: local!cat, style: "STRONG"),
                      char(10),
                      a!richTextItem(text: "OK " & tostring(local!ok), color: "POSITIVE"),
                      a!richTextItem(text: " · WARN " & tostring(local!warn), color: "ACCENT"),
                      a!richTextItem(text: " · KO " & tostring(local!ko), color: "NEGATIVE")
                    }
                  )
                },
                style: if(local!ko > 0, "ERROR", if(local!warn > 0, "ACCENT", "SUCCESS")),
                marginBelow: "STANDARD"
              )
            )
          )
        )
      ),
      a!gridField(
        label: "Últimas ejecuciones",
        labelPosition: "ABOVE",
        data: a!recordData(
          recordType: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion',
          fields: {
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn',
            'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'
          },
        ),
        columns: {
          a!gridColumn(label: "ID", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: tostring(fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id']), link: a!dynamicLink(saveInto: a!save(local!ejecucionSel, fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id']))))),
          a!gridColumn(label: "Fecha inicio", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio']),
          a!gridColumn(label: "Estado", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado'], style: "STRONG", color: a!match(value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado'], equals: "OK", then: "POSITIVE", equals: "KO", then: "NEGATIVE", equals: "WARN", then: "ACCENT", default: "SECONDARY")))),
          a!gridColumn(label: "Origen", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen']),
          a!gridColumn(label: "Motivo", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo']),
          a!gridColumn(label: "OK", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk']),
          a!gridColumn(label: "KO", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo']),
          a!gridColumn(label: "WARN", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn']),
          a!gridColumn(label: "Duración ms", value: fv!row['recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'])
        },
        pageSize: 10,
        borderStyle: "LIGHT",
        shadeAlternateRows: true
      ),
      a!buttonLayout(
        primaryButtons: a!buttonWidget(
          label: "Actualizar",
          style: "OUTLINE",
          saveInto: a!save(local!refresh, local!refresh + 1)
        )
      ),
      if(
        isnull(local!ejecucionSel),
        {},
        rule!SMK_UI_DetalleEjecucion(ejecucionId: local!ejecucionSel)
      )
    }
  )
)
