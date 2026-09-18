a!localVariables(
  local!modo: "Todas",
  local!categorias: {},
  local!sistemas: {},
  local!pruebas: {},
  local!motivo: "",
  local!origen: "MANUAL",
  local!ejecucionId: null,
  local!catalogo: rule!SMK_seleccionarPruebas(codigos: null, categorias: null, sistemas: null),
  local!sistemaChoices: union(
    index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema', {}),
    index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema', {})
  ),
  local!seleccion: if(
    local!modo = "Por categoría",
    rule!SMK_seleccionarPruebas(codigos: null, categorias: local!categorias, sistemas: null),
    if(
      local!modo = "Por sistema",
      rule!SMK_seleccionarPruebas(codigos: null, categorias: null, sistemas: local!sistemas),
      if(local!modo = "Pruebas concretas", rule!SMK_seleccionarPruebas(codigos: local!pruebas, categorias: null, sistemas: null), local!catalogo)
    )
  ),
  a!headerContentLayout(
    header: rule!SMK_UI_Cabecera(
      icono: "play-circle",
      titulo: "Ejecutar pruebas de humo",
      subtitulo: "Lanza una ejecución controlada del catálogo activo"
    ),
    contents: {
      a!cardLayout(
        contents: {
      a!radioButtonField(
        label: "Modo de selección",
        choiceLabels: {"Todas", "Por categoría", "Por sistema", "Pruebas concretas"},
        choiceValues: {"Todas", "Por categoría", "Por sistema", "Pruebas concretas"},
        value: local!modo,
        saveInto: local!modo,
        choiceLayout: "COMPACT"
      ),
      if(
        local!modo = "Por categoría",
        a!checkboxField(
          label: "Categorías",
          choiceLabels: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
          choiceValues: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
          value: local!categorias,
          saveInto: local!categorias
        ),
        {}
      ),
      if(
        local!modo = "Por sistema",
        a!multipleDropdownField(
          label: "Sistemas",
          choiceLabels: local!sistemaChoices,
          choiceValues: local!sistemaChoices,
          value: local!sistemas,
          saveInto: local!sistemas
        ),
        {}
      ),
      if(
        local!modo = "Pruebas concretas",
        a!multipleDropdownField(
          label: "Pruebas",
          choiceLabels: index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo', {}),
          choiceValues: index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo', {}),
          value: local!pruebas,
          saveInto: local!pruebas
        ),
        {}
      ),
      a!paragraphField(
        label: "Motivo",
        placeholder: "Indica el motivo de la ejecución",
        value: local!motivo,
        saveInto: local!motivo,
        required: true,
        characterLimit: 500
      ),
      a!dropdownField(
        label: "Origen",
        choiceLabels: {"MANUAL", "INSTALACION_APP", "CAMBIO_VERSION", "INTERVENCION_SAAS", "OTRO"},
        choiceValues: {"MANUAL", "INSTALACION_APP", "CAMBIO_VERSION", "INTERVENCION_SAAS", "OTRO"},
        value: local!origen,
        saveInto: local!origen
      ),
      a!richTextDisplayField(
        value: a!richTextItem(
          text: "Se ejecutarán " & tostring(count(local!seleccion)) & " pruebas",
          style: "STRONG"
        ),
        marginAbove: "STANDARD"
      ),
      rule!SMK_UI_KPI(
        etiqueta: "Alcance de la ejecución",
        valor: tostring(count(local!seleccion)) & " pruebas",
        icono: "tasks",
        color: cons!SMK_COLOR_ROJO
      ),
      a!buttonLayout(
        primaryButtons: a!buttonWidget(
          label: "Ejecutar pruebas de humo",
          style: "SOLID",
          color: cons!SMK_COLOR_ROJO,
          submit: false,
          validate: true,
          saveInto: a!startProcess(
            processModel: cons!SMK_PM_EJECUTAR_PRUEBAS,
            processParameters: a!map(
              codigos: if(local!modo = "Pruebas concretas", local!pruebas, {}),
              categorias: if(local!modo = "Por categoría", local!categorias, {}),
              sistemas: if(local!modo = "Por sistema", local!sistemas, {}),
              motivo: local!motivo,
              origen: local!origen,
              lanzadoPor: loggedInUser()
            ),
            onSuccess: a!save(local!ejecucionId, fv!processInfo.pv.ejecucionId)
          )
        )
      ),
        },
        shape: "ROUNDED",
        showBorder: true,
        showShadow: true,
        style: cons!SMK_COLOR_BLANCO,
        padding: "STANDARD",
        marginBelow: "STANDARD"
      ),
      if(
        isnull(local!ejecucionId),
        {},
        {
          a!richTextDisplayField(
            value: a!richTextItem(
              text: "Ejecución #" & tostring(local!ejecucionId) & " lanzada",
              color: cons!SMK_COLOR_EXITO,
              style: "STRONG"
            ),
            marginAbove: "STANDARD"
          ),
          rule!SMK_UI_DetalleEjecucion(ejecucionId: local!ejecucionId)
        }
      )
    }
  )
)
