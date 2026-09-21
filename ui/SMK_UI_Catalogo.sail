a!localVariables(
  local!categoria: null,
  local!texto: "",
  local!estado: null,
  local!idADesactivar: null,
  local!codigoADesactivar: null,
  local!motivoADesactivar: "",
  local!refresh: 0,
  local!mensaje: "",
  local!pendientes: a!refreshVariable(
    value: rule!SMK_catalogoPendiente(),
    refreshOnVarChange: local!refresh
  ),
  local!nPendientes: length(local!pendientes),
  a!headerContentLayout(
    header: rule!SMK_UI_Cabecera(
      icono: "list-alt",
      titulo: "Catálogo de pruebas",
      subtitulo: "Pruebas disponibles para las ejecuciones de humo"
    ),
    contents: {
      a!cardLayout(
        contents: a!sideBySideLayout(
          items: {
            a!sideBySideItem(
              item: a!richTextDisplayField(
                labelPosition: "COLLAPSED",
                value: {
                  a!richTextIcon(icon: if(local!nPendientes = 0, "check-circle", "info-circle"), color: if(local!nPendientes = 0, cons!SMK_COLOR_EXITO, cons!SMK_COLOR_AVISO)),
                  a!richTextItem(
                    text: if(
                      local!nPendientes = 0,
                      " Catálogo sincronizado con el catálogo base de la aplicación.",
                      " Hay " & tostring(local!nPendientes) & " prueba(s) del catálogo base que aún no están dadas de alta en este entorno."
                    ),
                    style: "STRONG"
                  ),
                  if(
                    len(local!mensaje) = 0,
                    {},
                    {char(10), a!richTextItem(text: local!mensaje, color: cons!SMK_COLOR_AZUL_GRIS)}
                  )
                }
              )
            ),
            a!sideBySideItem(
              item: a!buttonArrayLayout(
                buttons: a!buttonWidget(
                  label: "Sincronizar catálogo",
                  icon: "refresh",
                  style: "SOLID",
                  disabled: local!nPendientes = 0,
                  saveInto: {
                    a!writeRecords(
                      records: local!pendientes,
                      onSuccess: {
                        a!save(local!mensaje, "Se han dado de alta " & tostring(local!nPendientes) & " prueba(s)."),
                        a!save(local!refresh, local!refresh + 1)
                      },
                      onError: a!save(local!mensaje, "Error al sincronizar el catálogo.")
                    )
                  }
                ),
                align: "END",
                marginBelow: "NONE"
              ),
              width: "MINIMIZE"
            )
          },
          alignVertical: "MIDDLE"
        ),
        style: if(local!nPendientes = 0, cons!SMK_COLOR_EXITO, cons!SMK_COLOR_AZUL_GRIS),
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false,
        marginBelow: "STANDARD"
      ),
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
            placeholder: "Buscar por código",
            value: local!texto,
            saveInto: local!texto
          )),
          a!columnLayout(contents: a!dropdownField(
            label: "Estado",
            choiceLabels: {"Activas", "Desactivadas", "Pendientes de revisión"},
            choiceValues: {"Activas", "Desactivadas", "Pendientes de revisión"},
            value: local!estado,
            saveInto: local!estado,
            placeholder: "Todas"
          ))
        }
      ),
      if(
        a!isNullOrEmpty(local!idADesactivar),
        {},
        a!cardLayout(
          contents: {
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "Desactivar prueba " & local!codigoADesactivar,
                style: "STRONG",
                color: cons!SMK_COLOR_AZUL_OSCURO
              )
            ),
            a!textField(
              label: "Motivo",
              value: local!motivoADesactivar,
              saveInto: local!motivoADesactivar,
              required: true,
              placeholder: "Indica por qué se desactiva la prueba"
            ),
            a!buttonArrayLayout(
              buttons: {
                a!buttonWidget(
                  label: "Confirmar",
                  style: "SOLID",
                  color: cons!SMK_COLOR_ROJO,
                  disabled: a!isNullOrEmpty(trim(local!motivoADesactivar)),
                  saveInto: a!writeRecords(
                    records: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test'(
                      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b7020821-b4b7-41fc-a9eb-4f11ced13c7c}id': local!idADesactivar,
                      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo': false,
                      'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{ef3be308-44eb-4704-8c10-a3ff8cf11b73}motivoInactivo': trim(local!motivoADesactivar)
                    ),
                    onSuccess: {
                      a!save(local!mensaje, "Prueba desactivada."),
                      a!save(local!idADesactivar, null),
                      a!save(local!codigoADesactivar, null),
                      a!save(local!motivoADesactivar, ""),
                      a!save(local!refresh, local!refresh + 1)
                    },
                    onError: a!save(local!mensaje, "Error al desactivar la prueba.")
                  )
                ),
                a!buttonWidget(
                  label: "Cancelar",
                  style: "LINK",
                  saveInto: {
                    a!save(local!idADesactivar, null),
                    a!save(local!codigoADesactivar, null),
                    a!save(local!motivoADesactivar, "")
                  }
                )
              },
              align: "END",
              marginBelow: "NONE"
            )
          },
          style: cons!SMK_COLOR_AVISO,
          shape: "ROUNDED",
          showBorder: true,
          showShadow: false,
          marginBelow: "STANDARD"
        )
      ),
      a!cardLayout(
        contents: a!gridField(
        label: "Pruebas",
        data: a!recordData(
          recordType: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test',
          filters: a!queryLogicalExpression(
            operator: "AND",
            filters: {
              /* Filtro siempre verdadero: fuerza el refresco del grid tras activar/desactivar o sincronizar */
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b7020821-b4b7-41fc-a9eb-4f11ced13c7c}id',
                operator: ">",
                value: local!refresh * 0
              ),
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria',
                operator: "=",
                value: local!categoria
              ),
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo',
                operator: "=",
                value: if(local!estado = "Activas", true(), if(or(local!estado = "Desactivadas", local!estado = "Pendientes de revisión"), false(), null()))
              ),
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{e4ae6ce4-2eb3-4401-9124-19e8a5dd36ac}origenAlta',
                operator: "=",
                value: if(local!estado = "Pendientes de revisión", "DESCUBRIMIENTO", null())
              ),
              a!queryFilter(
                field: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo',
                operator: "includes",
                value: local!texto
              )
            },
            ignoreFiltersWithEmptyValues: true
          )
        ),
        columns: {
          a!gridColumn(label: "Código", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo']),
          a!gridColumn(label: "Nombre", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a47b7e2b-7082-494e-b909-a551766e2f69}nombre']),
          a!gridColumn(label: "Categoría", width: "NARROW", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{8493a0cc-cd79-4cc4-988c-a6f4dd7da18e}categoria']),
          a!gridColumn(label: "Sistema", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema']),
          a!gridColumn(label: "Criticidad", width: "NARROW", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{7b63c157-05d3-4de7-a1b7-e8b1b0cce28e}criticidad']),
          a!gridColumn(label: "Umbral ms", width: "NARROW", align: "END", value: fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{a0e22f2d-181d-4e27-a4c1-4661e21f5e60}umbralMs']),
          a!gridColumn(
            label: "Activo",
            width: "NARROW",
            value: a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: {
                a!richTextIcon(
                  icon: if(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo'], "toggle-on", "toggle-off"),
                  color: if(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo'], cons!SMK_COLOR_EXITO, cons!SMK_COLOR_AZUL_GRIS),
                  size: "MEDIUM"
                ),
                a!richTextItem(
                  text: if(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo'], " Sí", " No"),
                  color: if(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo'], cons!SMK_COLOR_EXITO, cons!SMK_COLOR_AZUL_GRIS)
                )
              }
            )
          ),
          a!gridColumn(
            label: "Motivo",
            value: a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: {
                if(
                  and(
                    not(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo']),
                    fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{e4ae6ce4-2eb3-4401-9124-19e8a5dd36ac}origenAlta'] = "DESCUBRIMIENTO"
                  ),
                  a!richTextItem(text: "Pendiente de revisión · ", color: cons!SMK_COLOR_AVISO, style: "STRONG"),
                  {}
                ),
                a!richTextItem(
                  text: a!defaultValue(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{ef3be308-44eb-4704-8c10-a3ff8cf11b73}motivoInactivo'], "")
                )
              }
            )
          ),
          a!gridColumn(
            label: "",
            width: "NARROW",
            value: a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: if(fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo'], "Desactivar", "Activar"),
                link: a!dynamicLink(
                  saveInto: if(
                    fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo'],
                    {
                      a!save(local!idADesactivar, fv!identifier),
                      a!save(local!codigoADesactivar, fv!row['recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo'])
                    },
                    a!writeRecords(
                      records: 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test'(
                        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b7020821-b4b7-41fc-a9eb-4f11ced13c7c}id': fv!identifier,
                        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{bfd955f5-5d0e-4d73-b79e-75a3c3dd903c}activo': true,
                        'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{ef3be308-44eb-4704-8c10-a3ff8cf11b73}motivoInactivo': null()
                      ),
                      onSuccess: {
                        a!save(local!mensaje, "Prueba activada."),
                        a!save(local!refresh, local!refresh + 1)
                      },
                      onError: a!save(local!mensaje, "Error al activar la prueba.")
                    )
                  )
                ),
                linkStyle: "STANDALONE"
              )
            )
          )
        },
        pageSize: 20,
        borderStyle: "LIGHT",
        shadeAlternateRows: true
      )
        ,
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false,
        style: cons!SMK_COLOR_BLANCO,
        padding: "STANDARD"
      )
    }
  )
)
