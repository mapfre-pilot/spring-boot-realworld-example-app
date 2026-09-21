a!localVariables(
  local!ejecuciones: a!queryRecordType(
    recordType: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion',
    fields: {
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo'
    },
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: 50,
      sort: a!sortInfo(
        field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
        ascending: false
      )
    )
  ),
  local!ids: index(local!ejecuciones.data, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id', {}),
  local!labels: a!forEach(
    items: local!ejecuciones.data,
    expression: "#" & tostring(index(fv!item, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id', null())) &
      " · " & text(index(fv!item, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio', null()), "dd/mm/yyyy HH:mm") &
      " · " & tostring(index(fv!item, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado', null())) &
      " · " & left(a!defaultValue(index(fv!item, 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo', null()), ""), 40)
  ),
  local!antes: if(a!isNullOrEmpty(local!ids), null(), index(local!ids, 2, null())),
  local!despues: if(a!isNullOrEmpty(local!ids), null(), index(local!ids, 1, null())),
  local!mostrarSoloCambios: true,
  local!comparacion: if(
    or(a!isNullOrEmpty(local!antes), a!isNullOrEmpty(local!despues)),
    {},
    rule!SMK_compararEjecuciones(idAntes: local!antes, idDespues: local!despues)
  ),
  local!cambiosComparacion: touniformstring(index(local!comparacion, "cambio", {})),
  local!filas: if(
    local!mostrarSoloCambios,
    index(local!comparacion, wherecontains({"REGRESION", "NUEVA", "AUSENTE", "MEJORA"}, local!cambiosComparacion), {}),
    local!comparacion
  ),
  local!regresiones: count(wherecontains("REGRESION", local!cambiosComparacion)),
  local!mejoras: count(wherecontains("MEJORA", local!cambiosComparacion)),
  local!nuevas: count(wherecontains("NUEVA", local!cambiosComparacion)),
  local!ausentes: count(wherecontains("AUSENTE", local!cambiosComparacion)),
  local!iguales: count(wherecontains("IGUAL", local!cambiosComparacion)),
  a!headerContentLayout(
    header: rule!SMK_UI_Cabecera(
      icono: "exchange",
      titulo: "Comparar ejecuciones",
      subtitulo: "Antes / después de una intervención"
    ),
    contents: {
      a!columnsLayout(
        columns: {
          a!columnLayout(
            contents: a!dropdownField(
              label: "Antes",
              choiceLabels: local!labels,
              choiceValues: local!ids,
              value: local!antes,
              saveInto: a!save(local!antes, save!value)
            )
          ),
          a!columnLayout(
            contents: a!dropdownField(
              label: "Después",
              choiceLabels: local!labels,
              choiceValues: local!ids,
              value: local!despues,
              saveInto: a!save(local!despues, save!value)
            )
          )
        }
      ),
      a!columnsLayout(
        columns: {
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Regresiones", valor: tostring(local!regresiones), icono: "times-circle", color: if(local!regresiones > 0, cons!SMK_COLOR_ERROR, cons!SMK_COLOR_EXITO))),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Mejoras", valor: tostring(local!mejoras), icono: "arrow-up", color: cons!SMK_COLOR_EXITO)),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Nuevas", valor: tostring(local!nuevas), icono: "plus-circle", color: cons!SMK_COLOR_AVISO)),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Ausentes", valor: tostring(local!ausentes), icono: "minus-circle", color: cons!SMK_COLOR_ERROR)),
          a!columnLayout(contents: rule!SMK_UI_KPI(etiqueta: "Sin cambio", valor: tostring(local!iguales), icono: "equals", color: cons!SMK_COLOR_AZUL_GRIS))
        },
        stackWhen: {"PHONE", "TABLET_PORTRAIT"}
      ),
      a!cardLayout(
        contents: a!richTextDisplayField(
          labelPosition: "COLLAPSED",
          value: a!richTextItem(
            text: if(local!regresiones = 0, "Sin regresiones: la plataforma está igual o mejor que antes", tostring(local!regresiones) & " regresiones detectadas"),
            color: if(local!regresiones = 0, cons!SMK_COLOR_EXITO, cons!SMK_COLOR_ERROR),
            style: "STRONG"
          )
        ),
        style: if(local!regresiones = 0, cons!SMK_COLOR_EXITO, cons!SMK_COLOR_ERROR),
        shape: "ROUNDED",
        showBorder: true,
        showShadow: false
      ),
      a!checkboxField(
        label: "",
        choiceLabels: {"Mostrar solo cambios"},
        choiceValues: {true()},
        value: if(local!mostrarSoloCambios, {true()}, {}),
        saveInto: a!save(local!mostrarSoloCambios, contains(save!value, true()))
      ),
      a!gridField(
        label: "Comparativa",
        data: local!filas,
        columns: {
          a!gridColumn(label: "Código", value: fv!row.codigo),
          a!gridColumn(label: "Sistema", value: fv!row.sistema),
          a!gridColumn(label: "Antes", value: fv!row.resultadoAntes),
          a!gridColumn(label: "Después", value: fv!row.resultadoDespues),
          a!gridColumn(label: "Cambio", value: fv!row.cambio),
          a!gridColumn(label: "Mensaje después", value: fv!row.mensajeDespues)
        },
        pageSize: 20,
        borderStyle: "LIGHT",
        shadeAlternateRows: true
      )
    }
  )
)
