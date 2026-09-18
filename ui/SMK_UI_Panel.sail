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
    cons!SMK_COLOR_EXITO,
    if(local!estado = "WARN", cons!SMK_COLOR_AVISO, if(local!estado = "KO", cons!SMK_COLOR_ERROR, cons!SMK_COLOR_AZUL_GRIS))
  ),
  local!categorias: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
  a!headerContentLayout(
    header: rule!SMK_UI_Cabecera(
      icono: "heartbeat",
      titulo: "Pruebas de Humo — Panel",
      subtitulo: "Estado de la plataforma según la última ejecución"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(contents: rule!SMK_UI_KPI(
            etiqueta: "Estado global",
            valor: tostring(local!estado),
            icono: if(local!estado = "OK", "check-circle", if(local!estado = "KO", "times-circle", "exclamation-triangle")),
            color: local!estadoColor
          )),
          a!columnLayout(contents: rule!SMK_UI_KPI(
            etiqueta: "Pruebas",
            valor: tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas', 0)),
            icono: "list-ol",
            color: cons!SMK_COLOR_AZUL_OSCURO
          )),
          a!columnLayout(contents: rule!SMK_UI_KPI(
            etiqueta: "OK",
            valor: tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk', 0)),
            icono: "check-circle",
            color: cons!SMK_COLOR_EXITO
          )),
          a!columnLayout(contents: rule!SMK_UI_KPI(
            etiqueta: "WARN",
            valor: tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn', 0)),
            icono: "exclamation-triangle",
            color: cons!SMK_COLOR_AVISO
          )),
          a!columnLayout(contents: rule!SMK_UI_KPI(
            etiqueta: "KO",
            valor: tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo', 0)),
            icono: "times-circle",
            color: cons!SMK_COLOR_ERROR
          )),
          a!columnLayout(contents: rule!SMK_UI_KPI(
            etiqueta: "Duración",
            valor: text(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs', 0) / 1000, "0.0") & " s",
            icono: "clock-o",
            color: cons!SMK_COLOR_AZUL_OSCURO
          ))
        },
        showDividers: true,
        stackWhen: {"PHONE", "TABLET_PORTRAIT"}
      ),
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
                style: cons!SMK_COLOR_BLANCO,
                shape: "ROUNDED",
                showBorder: true,
                showShadow: false,
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
                      a!richTextItem(text: "OK: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk', 0)), color: cons!SMK_COLOR_EXITO),
                      char(10),
                      a!richTextItem(text: "KO: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo', 0)), color: cons!SMK_COLOR_ERROR),
                      char(10),
                      a!richTextItem(text: "WARN: " & tostring(index(local!ultima, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn', 0)), color: cons!SMK_COLOR_AVISO)
                    }
                  )
                },
                style: cons!SMK_COLOR_BLANCO,
                shape: "ROUNDED",
                showBorder: true,
                showShadow: false,
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
                style: cons!SMK_COLOR_BLANCO,
                shape: "ROUNDED",
                showBorder: true,
                showShadow: false,
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
            local!ko: count(wherecontains("KO", touniformstring(local!resultados))),
            local!warn: count(wherecontains("WARN", touniformstring(local!resultados))),
            local!ok: count(wherecontains("OK", touniformstring(local!resultados))),
            a!columnLayout(
              contents: a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: {
                      a!richTextIcon(icon: "circle", color: if(local!ko > 0, cons!SMK_COLOR_ERROR, if(local!warn > 0, cons!SMK_COLOR_AVISO, cons!SMK_COLOR_EXITO))),
                      a!richTextItem(text: " " & local!cat, style: "STRONG"),
                      char(10),
                      a!richTextItem(text: "OK " & tostring(local!ok), color: cons!SMK_COLOR_EXITO),
                      a!richTextItem(text: " · WARN " & tostring(local!warn), color: cons!SMK_COLOR_AVISO),
                      a!richTextItem(text: " · KO " & tostring(local!ko), color: cons!SMK_COLOR_ERROR)
                    }
                  )
                },
                style: if(local!ko > 0, cons!SMK_COLOR_ERROR, if(local!warn > 0, cons!SMK_COLOR_AVISO, cons!SMK_COLOR_EXITO)),
                shape: "ROUNDED",
                showBorder: true,
                showShadow: false,
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
