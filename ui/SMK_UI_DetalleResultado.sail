a!localVariables(
  local!r: index(
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
      filters: a!queryFilter(
        field: 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{fd4208ff-713a-4043-b70e-14d16dcd7bd2}id',
        operator: "=",
        value: ri!resultadoId
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
    ).data,
    1,
    {}
  ),
  local!codigo: tostring(index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo', "")),
  local!resultado: tostring(index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado', "")),
  local!duracionMs: tointeger(index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs', 0)),
  local!ejecucionId: tointeger(index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId', 0)),
  local!detalle: tostring(index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{089c041c-624d-4ce5-96ab-df18c74e5671}detalle', "")),
  /* Umbral de latencia definido en el catálogo para esta prueba */
  local!umbralMs: if(a!isNullOrEmpty(local!codigo), 0, tointeger(index(
    a!queryRecordType(
      recordType: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test',
      fields: {'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs'},
      filters: a!queryFilter(
        field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo',
        operator: "=",
        value: local!codigo
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
    ).data,
    1,
    'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs',
    0
  ))),
  local!color: a!match(value: local!resultado, equals: "OK", then: cons!SMK_COLOR_EXITO, equals: "KO", then: cons!SMK_COLOR_ERROR, equals: "WARN", then: cons!SMK_COLOR_AVISO, default: cons!SMK_COLOR_AZUL_GRIS),
  local!card: a!match(value: local!resultado, equals: "OK", then: "SUCCESS", equals: "KO", then: "ERROR", equals: "WARN", then: "WARN", default: "INFO"),
  local!icono: a!match(value: local!resultado, equals: "OK", then: "check-circle", equals: "KO", then: "times-circle", equals: "WARN", then: "exclamation-triangle", default: "question-circle"),
  local!explicacion: a!match(
    value: local!resultado,
    equals: "OK", then: "La prueba ha pasado: el sistema respondió correctamente dentro del umbral de latencia.",
    equals: "KO", then: "La prueba ha fallado: el sistema no responde o devolvió un error. Revisa el mensaje y el detalle técnico.",
    equals: "WARN", then: "La prueba respondió correctamente pero superó su umbral de latencia (" & tostring(local!umbralMs) & " ms).",
    equals: "SKIP", then: "La prueba no se ejecutó (sin implementación o dependencia no disponible).",
    default: "Resultado no disponible."
  ),
  a!formLayout(
    contents: {
      a!cardLayout(
        contents: a!sideBySideLayout(
          items: {
            a!sideBySideItem(
              item: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextIcon(icon: local!icono, color: local!color, size: "LARGE_PLUS")),
              width: "MINIMIZE"
            ),
            a!sideBySideItem(
              item: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextItem(text: local!codigo & "  ·  ", size: "LARGE"),
                  a!richTextItem(text: local!resultado, style: "STRONG", size: "LARGE", color: local!color),
                  char(10),
                  a!richTextItem(text: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre', ""), style: "STRONG", color: cons!SMK_COLOR_AZUL_OSCURO),
                  char(10),
                  a!richTextItem(text: local!explicacion, color: cons!SMK_COLOR_AZUL_GRIS)
                }
              )
            )
          },
          alignVertical: "MIDDLE"
        ),
        style: local!card,
        marginBelow: "STANDARD"
      ),
      a!columnsLayout(
        columns: {
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Latencia", valor: tostring(local!duracionMs) & " ms", icono: "clock-o", color: local!color)),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Umbral", valor: if(local!umbralMs = 0, "—", tostring(local!umbralMs) & " ms"), icono: "tachometer", color: cons!SMK_COLOR_AZUL_OSCURO)),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Categoría", valor: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria', "—"), icono: "tags", color: cons!SMK_COLOR_AZUL_OSCURO)),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Ejecución", valor: "#" & tostring(local!ejecucionId), icono: "play-circle", color: cons!SMK_COLOR_AZUL_OSCURO))
        },
        marginBelow: "STANDARD"
      ),
      a!cardLayout(
        contents: {
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: {
                a!textField(label: "Sistema", value: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema', ""), readOnly: true),
                a!textField(label: "Inicio", value: a!localVariables(local!f: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{dc44be34-fe85-4b8a-9c9b-e7817b3676c9}fechaInicio', null), if(isnull(local!f), "", text(local!f, "dd/mm/yyyy hh:mm:ss"))), readOnly: true)
              }),
              a!columnLayout(contents: {
                a!textField(label: "Categoría", value: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria', ""), readOnly: true),
                a!textField(label: "Fin", value: a!localVariables(local!f: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{ec728354-513b-47e3-9655-9a93e291654f}fechaFin', null), if(isnull(local!f), "", text(local!f, "dd/mm/yyyy hh:mm:ss"))), readOnly: true)
              })
            }
          ),
          a!paragraphField(
            label: "Mensaje",
            value: index(local!r, 'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje', ""),
            readOnly: true,
            height: "SHORT"
          ),
          a!paragraphField(
            label: "Detalle técnico",
            instructions: "Respuesta o error devuelto por el sistema durante la prueba",
            value: if(a!isNullOrEmpty(local!detalle), "Sin detalle técnico adicional.", local!detalle),
            readOnly: true,
            height: "TALL"
          )
        },
        style: cons!SMK_COLOR_BLANCO,
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false
      )
    },
    buttons: a!buttonLayout(
      secondaryButtons: a!buttonWidget(label: "Cerrar", icon: "times", style: "LINK", submit: true, validate: false)
    )
  )
)
