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
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{541ebf63-f4c4-4892-a696-265d622c55fc}lanzadoPor',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'
    },
    filters: a!queryFilter(
      field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
      operator: "=",
      value: ri!ejecucionId
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
  ).data,
  local!fila: index(local!ejecucion, 1, {}),
  local!estado: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado', "")),
  local!resumen: rule!SMK_resumenEjecucion(
    ejecucionId: ri!ejecucionId,
    esperadas: index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas', 0)
  ),
  local!total: tointeger(index(local!resumen, "totalPruebas", 0)),
  local!ok: tointeger(index(local!resumen, "totalOk", 0)),
  local!ko: tointeger(index(local!resumen, "totalKo", 0)),
  local!warn: tointeger(index(local!resumen, "totalWarn", 0)),
  local!pctOk: if(local!total = 0, 0, tointeger(local!ok * 100 / local!total)),
  local!duracionMs: tointeger(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs', 0)),
  local!estadoColor: a!match(value: local!estado, equals: "OK", then: cons!SMK_COLOR_EXITO, equals: "KO", then: cons!SMK_COLOR_ERROR, equals: "WARN", then: cons!SMK_COLOR_AVISO, default: cons!SMK_COLOR_AZUL_GRIS),
  local!estadoCard: a!match(value: local!estado, equals: "OK", then: "SUCCESS", equals: "KO", then: "ERROR", equals: "WARN", then: "WARN", default: "INFO"),
  local!estadoIcono: a!match(value: local!estado, equals: "OK", then: "check-circle", equals: "KO", then: "times-circle", equals: "WARN", then: "exclamation-triangle", default: "clock-o"),
  local!estadoTexto: a!match(
    value: local!estado,
    equals: "OK", then: "Todas las pruebas activas han pasado. La plataforma y los sistemas conectados responden correctamente.",
    equals: "KO", then: "Hay pruebas fallidas: algún sistema no responde o devuelve error. Revisa las filas marcadas en rojo.",
    equals: "WARN", then: "Todas las pruebas responden, pero alguna supera su umbral de latencia. Revisa las filas en ámbar.",
    equals: "EN_CURSO", then: "La ejecución sigue en curso. Los resultados se irán completando.",
    default: "Estado de la ejecución no disponible."
  ),
  /* Resultados de la ejecución: base para los desgloses por categoría y sistema */
  local!todos: a!queryRecordType(
    recordType: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado',
    fields: {
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema',
      'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs'
    },
    filters: a!queryFilter(
      field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId',
      operator: "=",
      value: ri!ejecucionId
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1000)
  ).data,
  local!resultados: touniformstring(index(local!todos, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', {})),
  local!categorias: touniformstring(index(local!todos, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria', {})),
  local!duraciones: tointeger(index(local!todos, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs', {})),
  local!catsUnicas: union(local!categorias, local!categorias),
  local!resultadoFiltro: null,
  {
    /* Cabecera: estado global */
    a!cardLayout(
      contents: {
        a!sideBySideLayout(
          items: {
            a!sideBySideItem(
              item: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: a!richTextIcon(icon: local!estadoIcono, color: local!estadoColor, size: "LARGE_PLUS")
              ),
              width: "MINIMIZE"
            ),
            a!sideBySideItem(
              item: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(text: "Ejecución #" & tostring(ri!ejecucionId) & "  ·  ", size: "LARGE"),
                  a!richTextItem(text: local!estado, style: "STRONG", size: "LARGE", color: local!estadoColor),
                  char(10),
                  a!richTextItem(text: local!estadoTexto, color: cons!SMK_COLOR_AZUL_GRIS)
                }
              )
            )
          },
          alignVertical: "MIDDLE"
        )
      },
      style: local!estadoCard,
      marginBelow: "STANDARD"
    ),
    /* KPIs */
    a!columnsLayout(
      columns: {
        a!columnLayout(contents: rule!SMK_UI_KPI(
          etiqueta: "Pruebas ejecutadas",
          valor: tostring(local!total),
          icono: "list-ol",
          color: cons!SMK_COLOR_AZUL_OSCURO
        )),
        a!columnLayout(contents: rule!SMK_UI_KPI(
          etiqueta: "OK",
          valor: tostring(local!ok),
          icono: "check-circle",
          color: cons!SMK_COLOR_EXITO
        )),
        a!columnLayout(contents: rule!SMK_UI_KPI(
          etiqueta: "WARN (latencia)",
          valor: tostring(local!warn),
          icono: "exclamation-triangle",
          color: cons!SMK_COLOR_AVISO
        )),
        a!columnLayout(contents: rule!SMK_UI_KPI(
          etiqueta: "KO (fallos)",
          valor: tostring(local!ko),
          icono: "times-circle",
          color: cons!SMK_COLOR_ERROR
        )),
        a!columnLayout(contents: rule!SMK_UI_KPI(
          etiqueta: "Duración total",
          valor: text(local!duracionMs / 1000, "0.0") & " s",
          icono: "clock-o",
          color: cons!SMK_COLOR_AZUL_OSCURO
        ))
      },
      marginBelow: "STANDARD",
      showDividers: true,
      stackWhen: {"PHONE", "TABLET_PORTRAIT"}
    ),
    a!progressBarField(
      label: "Pruebas correctas",
      instructions: tostring(local!ok) & " de " & tostring(local!total) & " (" & tostring(local!pctOk) & "%)",
      percentage: local!pctOk,
      color: if(local!ko > 0, cons!SMK_COLOR_ERROR, if(local!warn > 0, cons!SMK_COLOR_AVISO, cons!SMK_COLOR_EXITO)),
      style: "THICK",
      marginBelow: "STANDARD"
    ),
    /* Contexto + desglose por categoría */
    a!columnsLayout(
      columns: {
        a!columnLayout(
          width: "MEDIUM",
          contents: a!cardLayout(
            contents: {
              a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: "Contexto de la ejecución", style: "STRONG", size: "MEDIUM"), marginBelow: "STANDARD"),
              a!richTextDisplayField(labelPosition: "COLLAPSED", value: {
                a!richTextItem(text: "Inicio: ", style: "STRONG"),
                a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio', "-"))), char(10),
                a!richTextItem(text: "Fin: ", style: "STRONG"),
                a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1bcfff8e-df5c-4bcf-be02-110148d4d995}fechaFin', "-"))), char(10),
                a!richTextItem(text: "Origen: ", style: "STRONG"),
                a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen', "-"))), char(10),
                a!richTextItem(text: "Motivo: ", style: "STRONG"),
                a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo', "-"))), char(10),
                a!richTextItem(text: "Lanzado por: ", style: "STRONG"),
                a!richTextItem(text: tostring(index(local!fila, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{541ebf63-f4c4-4892-a696-265d622c55fc}lanzadoPor', "-")))
              }),
              if(
                local!estado = "EN_CURSO",
                a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: "En curso: " & tostring(index(local!resumen, "completadas", 0)) & " de " & tostring(local!total) & " completadas", color: cons!SMK_COLOR_AZUL_GRIS)),
                {}
              )
            },
            style: cons!SMK_COLOR_BLANCO,
            shape: "ROUNDED",
            showBorder: true,
            showShadow: false
          )
        ),
        a!columnLayout(
          contents: a!cardLayout(
            contents: {
              a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: "Resultado por categoría", style: "STRONG", size: "MEDIUM"), marginBelow: "STANDARD"),
              a!gridLayout(
                label: "",
                labelPosition: "COLLAPSED",
                headerCells: {
                  a!gridLayoutHeaderCell(label: "Categoría"),
                  a!gridLayoutHeaderCell(label: "Estado", align: "CENTER"),
                  a!gridLayoutHeaderCell(label: "Pruebas", align: "RIGHT"),
                  a!gridLayoutHeaderCell(label: "OK", align: "RIGHT"),
                  a!gridLayoutHeaderCell(label: "WARN", align: "RIGHT"),
                  a!gridLayoutHeaderCell(label: "KO", align: "RIGHT"),
                  a!gridLayoutHeaderCell(label: "Latencia máx.", align: "RIGHT")
                },
                columnConfigs: {
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 3),
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 2),
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 1),
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 1),
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 1),
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 1),
                  a!gridLayoutColumnConfig(width: "DISTRIBUTE", weight: 2)
                },
                rows: a!forEach(
                  items: local!catsUnicas,
                  expression: a!localVariables(
                    local!idx: wherecontains(fv!item, local!categorias),
                    local!res: index(local!resultados, local!idx, {}),
                    local!cOk: count(wherecontains("OK", local!res)),
                    local!cWarn: count(wherecontains("WARN", local!res)),
                    local!cKo: count(wherecontains("KO", local!res)),
                    local!cEstado: if(local!cKo > 0, "KO", if(local!cWarn > 0, "WARN", "OK")),
                    local!maxMs: if(length(local!idx) = 0, 0, max(index(local!duraciones, local!idx, 0))),
                    a!gridRowLayout(
                      contents: {
                        a!textField(value: fv!item, readOnly: true),
                        a!richTextDisplayField(labelPosition: "COLLAPSED", align: "CENTER", value: {
                          a!richTextIcon(icon: a!match(value: local!cEstado, equals: "OK", then: "check-circle", equals: "KO", then: "times-circle", default: "exclamation-triangle"), color: a!match(value: local!cEstado, equals: "OK", then: cons!SMK_COLOR_EXITO, equals: "KO", then: cons!SMK_COLOR_ERROR, default: cons!SMK_COLOR_AVISO)),
                          a!richTextItem(text: " " & local!cEstado, style: "STRONG", color: a!match(value: local!cEstado, equals: "OK", then: cons!SMK_COLOR_EXITO, equals: "KO", then: cons!SMK_COLOR_ERROR, default: cons!SMK_COLOR_AVISO))
                        }),
                        a!textField(value: tostring(length(local!idx)), readOnly: true, align: "RIGHT"),
                        a!textField(value: tostring(local!cOk), readOnly: true, align: "RIGHT"),
                        a!textField(value: tostring(local!cWarn), readOnly: true, align: "RIGHT"),
                        a!textField(value: tostring(local!cKo), readOnly: true, align: "RIGHT"),
                        a!textField(value: tostring(local!maxMs) & " ms", readOnly: true, align: "RIGHT")
                      }
                    )
                  )
                ),
                borderStyle: "LIGHT",
                shadeAlternateRows: true
              )
            },
            style: cons!SMK_COLOR_BLANCO,
            shape: "ROUNDED",
            showBorder: true,
            showShadow: false
          )
        )
      },
      marginBelow: "STANDARD"
    ),
    /* Incidencias destacadas */
    if(
      local!ko + local!warn = 0,
      {},
      a!cardLayout(
        contents: {
          a!richTextDisplayField(labelPosition: "COLLAPSED", value: {
            a!richTextIcon(icon: "exclamation-triangle", color: cons!SMK_COLOR_ERROR),
            a!richTextItem(text: " Incidencias detectadas (" & tostring(local!ko + local!warn) & ")", style: "STRONG", size: "MEDIUM")
          }, marginBelow: "STANDARD"),
          a!gridField(
            labelPosition: "COLLAPSED",
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
                  a!queryFilter(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId', operator: "=", value: ri!ejecucionId),
                  a!queryFilter(field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', operator: "in", value: {"KO", "WARN"})
                }
              )
            ),
            columns: {
              a!gridColumn(label: "Resultado", width: "NARROW", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'], style: "STRONG", color: if(fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'] = "KO", cons!SMK_COLOR_ERROR, cons!SMK_COLOR_AVISO)))),
              a!gridColumn(label: "Categoría", width: "NARROW", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria']),
              a!gridColumn(label: "Sistema", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema']),
              a!gridColumn(label: "Prueba", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre']),
              a!gridColumn(label: "Mensaje", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje']),
              a!gridColumn(label: "ms", width: "NARROW", align: "END", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs'])
            },
            pageSize: 10,
            borderStyle: "LIGHT",
            shadeAlternateRows: true,
            rowHeader: 4
          )
        },
        style: "#FFEBEB",
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false,
        marginBelow: "STANDARD"
      )
    ),
    /* Todos los resultados */
    a!cardLayout(
      contents: {
        a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: "Todos los resultados", style: "STRONG", size: "MEDIUM"), marginBelow: "STANDARD"),
        a!dropdownField(
          label: "Filtrar resultado",
          choiceLabels: {"OK", "KO", "WARN", "SKIP"},
          choiceValues: {"OK", "KO", "WARN", "SKIP"},
          value: local!resultadoFiltro,
          saveInto: local!resultadoFiltro,
          placeholder: "Todos"
        ),
        a!gridField(
          labelPosition: "COLLAPSED",
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
            )
          ),
          columns: {
            a!gridColumn(label: "Resultado", width: "NARROW", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'], style: "STRONG", color: a!match(value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado'], equals: "OK", then: cons!SMK_COLOR_EXITO, equals: "KO", then: cons!SMK_COLOR_ERROR, equals: "WARN", then: cons!SMK_COLOR_AVISO, default: cons!SMK_COLOR_AZUL_GRIS)))),
            a!gridColumn(label: "Categoría", width: "NARROW", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria']),
            a!gridColumn(label: "Sistema", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema']),
            a!gridColumn(label: "Código", value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo'], style: "STRONG", color: cons!SMK_COLOR_AZUL_OSCURO))),
            a!gridColumn(label: "Detalle", width: "NARROW", value: a!recordActionField(actions: a!recordActionItem(action: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.actions.{1eff2867-5c5b-4223-90e5-d10e6ecd83fd}verDetalle', identifier: fv!identifier), style: "LINKS", display: "LABEL_AND_ICON", openActionsIn: "DIALOG")),
            a!gridColumn(label: "Nombre", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre']),
            a!gridColumn(label: "Mensaje", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje']),
            a!gridColumn(label: "ms", width: "NARROW", align: "END", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs']),
            a!gridColumn(label: "Fin", value: fv!row['recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{ec728354-513b-47e3-9655-9a93e291654f}fechaFin'])
          },
          pageSize: 20,
          borderStyle: "LIGHT",
          shadeAlternateRows: true,
          rowHeader: 4
        )
      },
      style: cons!SMK_COLOR_BLANCO,
      shape: "ROUNDED",
      showBorder: true,
      showShadow: true
    )
  }
)
