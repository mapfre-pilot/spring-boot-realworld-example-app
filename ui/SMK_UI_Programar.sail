a!localVariables(
  local!modo: "Todas",
  local!categorias: {},
  local!sistemas: {},
  local!pruebas: {},
  local!fechaHora: null,
  local!motivo: "",
  local!origen: "PROGRAMADO",
  local!mensaje: null,
  local!error: null,
  local!filtroEstado: {"PENDIENTE", "LANZADA", "CANCELADA"},
  local!refresco: 0,
  local!cancelarId: null,
  local!creada: null,
  local!catalogo: rule!SMK_seleccionarPruebas(codigos: null, categorias: null, sistemas: null),
  local!sistemaChoices: union(
    index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema', {}),
    index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{dba8c578-8951-4d8a-82f4-64ee769b8e90}sistema', {})
  ),
  local!seleccion: a!match(
    value: local!modo,
    equals: "Por categoría",
    then: if(a!isNullOrEmpty(local!categorias), {}, rule!SMK_seleccionarPruebas(codigos: null, categorias: local!categorias, sistemas: null)),
    equals: "Por sistema",
    then: if(a!isNullOrEmpty(local!sistemas), {}, rule!SMK_seleccionarPruebas(codigos: null, categorias: null, sistemas: local!sistemas)),
    equals: "Pruebas concretas",
    then: if(a!isNullOrEmpty(local!pruebas), {}, rule!SMK_seleccionarPruebas(codigos: local!pruebas, categorias: null, sistemas: null)),
    default: local!catalogo
  ),
  local!minutosHasta: if(
    a!isNullOrEmpty(local!fechaHora),
    null,
    tointeger((todecimal(local!fechaHora) - todecimal(now())) * 1440)
  ),
  local!fechaValida: and(a!isNotNullOrEmpty(local!fechaHora), a!defaultValue(local!minutosHasta, 0) >= 2),
  local!programaciones: a!refreshVariable(
    value: rule!SMK_getProgramaciones(id: null, estados: local!filtroEstado, batchSize: 200),
    refreshOnVarChange: {local!refresco, local!filtroEstado},
    refreshInterval: 1
  ),
  local!creadaYaEnBd: if(
    a!isNullOrEmpty(local!creada),
    true,
    count(
      wherecontains(
        true,
        a!forEach(
          local!programaciones,
          and(
            index(fv!item, 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada', null) = index(local!creada, 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada', null),
            index(fv!item, 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{d866a44f-0e71-4260-9fcf-50c537fed215}fechaCreacion', null) >= index(local!creada, 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{d866a44f-0e71-4260-9fcf-50c537fed215}fechaCreacion', null) - intervalds(0, 1, 0)
          )
        )
      )
    ) > 0
  ),
  local!programacionesVista: if(
    or(
      local!creadaYaEnBd,
      not(contains(local!filtroEstado, "PENDIENTE"))
    ),
    local!programaciones,
    {local!creada, local!programaciones}
  ),
  local!pendientes: a!refreshVariable(
    value: rule!SMK_getProgramaciones(id: null, estados: {"PENDIENTE"}, batchSize: 1),
    refreshOnVarChange: local!refresco,
    refreshInterval: 1
  ),
  local!proximaBd: if(
    a!isNullOrEmpty(local!pendientes),
    null,
    index(local!pendientes[1], 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada', null)
  ),
  local!proximaCreada: if(
    local!creadaYaEnBd,
    null,
    index(local!creada, 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada', null)
  ),
  local!proxima: if(
    a!isNullOrEmpty(local!proximaBd),
    local!proximaCreada,
    if(a!isNullOrEmpty(local!proximaCreada), local!proximaBd, min(local!proximaBd, local!proximaCreada))
  ),
  local!numPendientes: count(
    index(
      local!programacionesVista,
      wherecontains(
        "PENDIENTE",
        touniformstring(index(local!programacionesVista, 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado', {}))
      ),
      {}
    )
  ),
  a!headerContentLayout(
    header: rule!SMK_UI_Cabecera(
      icono: "calendar-check-o",
      titulo: "Programar pruebas de humo",
      subtitulo: "Planifica una ejecución para una fecha y hora concretas; Appian la lanzará automáticamente"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: rule!SMK_UI_KPI(
              etiqueta: "Próxima ejecución programada",
              valor: if(a!isNullOrEmpty(local!proxima), "Ninguna", text(local!proxima, "dd/mm/yyyy hh:mm")),
              icono: "clock-o",
              color: if(a!isNullOrEmpty(local!proxima), cons!SMK_COLOR_AZUL_GRIS, cons!SMK_COLOR_ROJO)
            )
          ),
          a!columnLayout(
            contents: rule!SMK_UI_KPI(
              etiqueta: "Programaciones pendientes",
              valor: tostring(local!numPendientes),
              icono: "hourglass-half",
              color: cons!SMK_COLOR_AZUL_OSCURO
            )
          ),
          a!columnLayout(
            contents: rule!SMK_UI_KPI(
              etiqueta: "Alcance de la nueva programación",
              valor: tostring(count(local!seleccion)) & " pruebas",
              icono: "tasks",
              color: cons!SMK_COLOR_ROJO
            )
          )
        },
        marginBelow: "STANDARD"
      ),
      a!cardLayout(
        contents: {
          a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: a!richTextItem(text: "Nueva programación", size: "MEDIUM", style: "STRONG", color: cons!SMK_COLOR_AZUL_OSCURO),
            marginBelow: "STANDARD"
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: {
                  a!dateTimeField(
                    label: "Fecha y hora de lanzamiento",
                    instructions: "Hora local del usuario. Debe ser al menos 2 minutos posterior a la actual.",
                    value: local!fechaHora,
                    saveInto: {local!fechaHora, a!save(local!mensaje, null), a!save(local!error, null)},
                    required: true,
                    validations: if(
                      or(a!isNullOrEmpty(local!fechaHora), local!fechaValida),
                      {},
                      "La fecha y hora de lanzamiento debe ser posterior a la actual (mínimo 2 minutos)"
                    )
                  ),
                  a!dropdownField(
                    label: "Origen de la ejecución",
                    instructions: "Se guarda en la ejecución para distinguirla en Histórico y Comparar",
                    choiceLabels: {"PROGRAMADO", "INSTALACION_APP", "CAMBIO_VERSION", "INTERVENCION_SAAS", "OTRO"},
                    choiceValues: {"PROGRAMADO", "INSTALACION_APP", "CAMBIO_VERSION", "INTERVENCION_SAAS", "OTRO"},
                    value: local!origen,
                    saveInto: local!origen
                  ),
                  a!paragraphField(
                    label: "Motivo",
                    placeholder: "P. ej. Comprobación tras la intervención SaaS del sábado",
                    value: local!motivo,
                    saveInto: local!motivo,
                    required: true,
                    characterLimit: 500,
                    height: "SHORT"
                  )
                }
              ),
              a!columnLayout(
                contents: {
                  a!radioButtonField(
                    label: "Pruebas a ejecutar",
                    choiceLabels: {"Todas", "Por categoría", "Por sistema", "Pruebas concretas"},
                    choiceValues: {"Todas", "Por categoría", "Por sistema", "Pruebas concretas"},
                    value: local!modo,
                    saveInto: local!modo,
                    choiceLayout: "COMPACT"
                  ),
                  a!checkboxField(
                    label: "Categorías",
                    choiceLabels: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
                    choiceValues: {"PLATAFORMA", "DB", "S3", "HTTP", "APIGW"},
                    value: local!categorias,
                    saveInto: local!categorias,
                    showWhen: local!modo = "Por categoría",
                    required: true
                  ),
                  a!multipleDropdownField(
                    label: "Sistemas",
                    choiceLabels: local!sistemaChoices,
                    choiceValues: local!sistemaChoices,
                    value: local!sistemas,
                    saveInto: local!sistemas,
                    showWhen: local!modo = "Por sistema",
                    required: true,
                    searchDisplay: "ON"
                  ),
                  a!multipleDropdownField(
                    label: "Pruebas",
                    choiceLabels: index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo', {}),
                    choiceValues: index(local!catalogo, 'recordType!{8cb90847-702c-4704-aae6-03acd830a9b7}SMK Test.fields.{b4635ff6-1317-41d5-af9f-e7cd4d61fa22}codigo', {}),
                    value: local!pruebas,
                    saveInto: local!pruebas,
                    showWhen: local!modo = "Pruebas concretas",
                    required: true,
                    searchDisplay: "ON"
                  ),
                  a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: {
                      a!richTextIcon(icon: "info-circle", color: cons!SMK_COLOR_AZUL_GRIS),
                      " ",
                      a!richTextItem(
                        text: if(
                          local!fechaValida,
                          "Se lanzarán " & count(local!seleccion) & " pruebas el " & text(local!fechaHora, "dd/mm/yyyy") & " a las " & text(local!fechaHora, "hh:mm") & " (dentro de " & if(local!minutosHasta >= 1440, tostring(tointeger(local!minutosHasta / 1440)) & " días", if(local!minutosHasta >= 60, tostring(tointeger(local!minutosHasta / 60)) & " h", tostring(local!minutosHasta) & " min")) & ")",
                          "Selecciona fecha, hora y alcance para ver el resumen"
                        ),
                        color: cons!SMK_COLOR_AZUL_GRIS,
                        style: "EMPHASIS"
                      )
                    },
                    marginAbove: "STANDARD"
                  )
                }
              )
            }
          ),
          a!buttonLayout(
            primaryButtons: a!buttonWidget(
              label: "Programar ejecución",
              icon: "calendar-plus-o",
              style: "SOLID",
              color: cons!SMK_COLOR_ROJO,
              submit: false,
              validate: true,
              disabled: or(not(local!fechaValida), count(local!seleccion) = 0),
              saveInto: a!startProcess(
                processModel: cons!SMK_PM_PROGRAMAR_PRUEBAS,
                processParameters: a!map(
                  fechaProgramada: local!fechaHora,
                  modo: local!modo,
                  codigosTxt: if(local!modo = "Pruebas concretas", left(joinarray(local!pruebas, ","), 4000), null),
                  categoriasTxt: if(local!modo = "Por categoría", joinarray(local!categorias, ","), null),
                  sistemasTxt: if(local!modo = "Por sistema", left(joinarray(local!sistemas, ","), 4000), null),
                  numPruebas: count(local!seleccion),
                  motivo: local!motivo,
                  origen: local!origen,
                  creadoPor: loggedInUser()
                ),
                onSuccess: {
                  a!save(local!mensaje, "Programación creada: " & count(local!seleccion) & " pruebas el " & text(local!fechaHora, "dd/mm/yyyy") & " a las " & text(local!fechaHora, "hh:mm") & ". Queda como PENDIENTE hasta su lanzamiento."),
                  a!save(
                    local!creada,
                    'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion'(
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada': local!fechaHora,
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado': "PENDIENTE",
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{c6ba445d-a508-4c70-a626-e6c4a7e804be}modo': local!modo,
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{3fab4644-0a96-437a-8f1b-48744d5da6d4}numPruebas': count(local!seleccion),
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{90095155-8d17-46d8-9cba-95f6be4c0beb}motivo': local!motivo,
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{89356b5f-9992-4548-8d58-82f8d924574a}origen': local!origen,
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{1202dd4f-496d-4462-a54f-ec133ff6d940}creadoPor': loggedInUser(),
                      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{d866a44f-0e71-4260-9fcf-50c537fed215}fechaCreacion': now()
                    )
                  ),
                  a!save(local!error, null),
                  a!save(local!fechaHora, null),
                  a!save(local!motivo, ""),
                  a!save(local!refresco, local!refresco + 1)
                },
                onError: a!save(local!error, "No se pudo crear la programación (error al iniciar el proceso)")
              )
            )
          ),
          a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            showWhen: a!isNotNullOrEmpty(local!mensaje),
            value: {
              a!richTextIcon(icon: "check-circle", color: cons!SMK_COLOR_EXITO),
              " ",
              a!richTextItem(text: local!mensaje, color: cons!SMK_COLOR_EXITO, style: "STRONG")
            }
          ),
          a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            showWhen: a!isNotNullOrEmpty(local!error),
            value: {
              a!richTextIcon(icon: "exclamation-triangle", color: cons!SMK_COLOR_ERROR),
              " ",
              a!richTextItem(text: local!error, color: cons!SMK_COLOR_ERROR, style: "STRONG")
            }
          )
        },
        shape: "ROUNDED",
        showBorder: true,
        showShadow: true,
        style: cons!SMK_COLOR_BLANCO,
        padding: "STANDARD",
        marginBelow: "STANDARD"
      ),
      a!cardLayout(
        showWhen: a!isNotNullOrEmpty(local!cancelarId),
        contents: {
          a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: {
              a!richTextIcon(icon: "exclamation-triangle", color: cons!SMK_COLOR_ERROR),
              " ",
              a!richTextItem(text: "¿Cancelar la programación #" & local!cancelarId & "? No se lanzarán las pruebas en la fecha prevista.", style: "STRONG", color: cons!SMK_COLOR_AZUL_OSCURO)
            }
          ),
          a!buttonLayout(
            primaryButtons: a!buttonWidget(
              label: "Sí, cancelar programación",
              icon: "times",
              style: "SOLID",
              color: cons!SMK_COLOR_ERROR,
              size: "SMALL",
              saveInto: a!writeRecords(
                records: 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion'(
                  'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{798cdcc5-071f-4872-9997-5a17b1a6124a}id': local!cancelarId,
                  'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado': "CANCELADA",
                  'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{85123178-7b55-4299-886d-04d4293e59fa}canceladoPor': loggedInUser(),
                  'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{1e919401-8cb7-4463-b272-8755ed19f628}fechaCancelacion': now()
                ),
                onSuccess: {
                  a!save(local!mensaje, "Programación #" & local!cancelarId & " cancelada"),
                  a!save(local!cancelarId, null),
                  a!save(local!refresco, local!refresco + 1)
                },
                onError: a!save(local!error, "No se pudo cancelar la programación #" & local!cancelarId)
              )
            ),
            secondaryButtons: a!buttonWidget(
              label: "Volver",
              style: "OUTLINE",
              size: "SMALL",
              saveInto: a!save(local!cancelarId, null)
            )
          )
        },
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false,
        style: cons!SMK_COLOR_BLANCO,
        padding: "STANDARD",
        marginBelow: "STANDARD"
      ),
      a!cardLayout(
        contents: {
          a!sideBySideLayout(
            items: {
              a!sideBySideItem(
                item: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: a!richTextItem(text: "Programaciones", size: "MEDIUM", style: "STRONG", color: cons!SMK_COLOR_AZUL_OSCURO)
                )
              ),
              a!sideBySideItem(
                item: a!checkboxField(
                  label: "Estado",
                  labelPosition: "COLLAPSED",
                  choiceLabels: {"Pendientes", "Lanzadas", "Canceladas"},
                  choiceValues: {"PENDIENTE", "LANZADA", "CANCELADA"},
                  value: local!filtroEstado,
                  saveInto: local!filtroEstado,
                  choiceLayout: "COMPACT"
                ),
                width: "MINIMIZE"
              ),
              a!sideBySideItem(
                item: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: a!richTextItem(
                    text: {a!richTextIcon(icon: "refresh"), " Actualizar"},
                    link: a!dynamicLink(value: local!refresco + 1, saveInto: local!refresco),
                    linkStyle: "STANDALONE",
                    color: cons!SMK_COLOR_AZUL_OSCURO
                  )
                ),
                width: "MINIMIZE"
              )
            },
            alignVertical: "MIDDLE",
            marginBelow: "STANDARD"
          ),
          a!gridField(
            label: "Programaciones",
            labelPosition: "COLLAPSED",
            data: local!programacionesVista,
            emptyGridMessage: "No hay programaciones con el filtro seleccionado",
            columns: {
              a!gridColumn(
                label: "#",
                value: a!richTextDisplayField(labelPosition: "COLLAPSED", value: a!richTextItem(text: a!defaultValue(tostring(fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{798cdcc5-071f-4872-9997-5a17b1a6124a}id']), "…"), style: "STRONG", color: cons!SMK_COLOR_AZUL_OSCURO)),
                width: "NARROW"
              ),
              a!gridColumn(
                label: "Fecha programada",
                value: text(fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada'], "dd/mm/yyyy hh:mm")
              ),
              a!gridColumn(
                label: "Estado",
                value: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: a!richTextItem(
                    text: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado'],
                    style: "STRONG",
                    color: a!match(
                      value: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado'],
                      equals: "PENDIENTE", then: cons!SMK_COLOR_AVISO,
                      equals: "LANZADA", then: cons!SMK_COLOR_EXITO,
                      equals: "CANCELADA", then: cons!SMK_COLOR_AZUL_GRIS,
                      default: cons!SMK_COLOR_ERROR
                    )
                  )
                ),
                width: "NARROW"
              ),
              a!gridColumn(
                label: "Alcance",
                value: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{c6ba445d-a508-4c70-a626-e6c4a7e804be}modo'] & " (" & a!defaultValue(fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{3fab4644-0a96-437a-8f1b-48744d5da6d4}numPruebas'], 0) & ")"
              ),
              a!gridColumn(
                label: "Origen",
                value: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{89356b5f-9992-4548-8d58-82f8d924574a}origen']
              ),
              a!gridColumn(
                label: "Motivo",
                value: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{90095155-8d17-46d8-9cba-95f6be4c0beb}motivo'],
                width: "WIDE"
              ),
              a!gridColumn(
                label: "Creada por",
                value: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{1202dd4f-496d-4462-a54f-ec133ff6d940}creadoPor']
              ),
              a!gridColumn(
                label: "Ejecución",
                value: if(
                  a!isNullOrEmpty(fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{9b2af594-6312-4940-933a-6bdc464217ef}ejecucionId']),
                  if(
                    fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado'] = "CANCELADA",
                    "Cancelada por " & a!defaultValue(fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{85123178-7b55-4299-886d-04d4293e59fa}canceladoPor'], "-"),
                    "-"
                  ),
                  a!recordActionField(
                    actions: a!recordActionItem(
                      action: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.actions.{197ca981-65ff-492d-a45f-c85ed6b95292}verDetalle',
                      identifier: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{9b2af594-6312-4940-933a-6bdc464217ef}ejecucionId']
                    ),
                    style: "LINKS",
                    display: "LABEL_AND_ICON",
                    openActionsIn: "DIALOG"
                  )
                )
              ),
              a!gridColumn(
                label: "Acción",
                value: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: if(
                    and(
                      fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado'] = "PENDIENTE",
                      a!isNotNullOrEmpty(fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{798cdcc5-071f-4872-9997-5a17b1a6124a}id'])
                    ),
                    a!richTextItem(
                      text: {a!richTextIcon(icon: "times-circle"), " Cancelar"},
                      link: a!dynamicLink(
                        value: fv!row['recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{798cdcc5-071f-4872-9997-5a17b1a6124a}id'],
                        saveInto: {local!cancelarId, a!save(local!mensaje, null), a!save(local!error, null)}
                      ),
                      linkStyle: "STANDALONE",
                      color: cons!SMK_COLOR_ERROR,
                      style: "STRONG"
                    ),
                    ""
                  )
                ),
                width: "NARROW"
              )
            },
            pageSize: 20,
            borderStyle: "LIGHT",
            shadeAlternateRows: true
          )
        },
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false,
        style: cons!SMK_COLOR_BLANCO,
        padding: "STANDARD",
        marginBelow: "STANDARD"
      )
    }
  )
)
