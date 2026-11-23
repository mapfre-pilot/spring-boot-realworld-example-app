/*
[SCA2] Cuadro de mando de SCA2 (página Gestiones mantenimiento).
Solo lectura: agrega los records SCA2 Solicitud, Datos Solicitud, Transicion, Tarea,
Llamada Servicio y Error. Filtros: fecha de alta de la solicitud, línea de negocio y origen.
R54: pestañas Resumen, Gestiones y resultados, Servicios y Errores.
R56: pestaña Cuadro de Gestión (solo consulta) sobre SCA2 Ejecucion Argumento.
*/
a!localVariables(
  local!fDesde: today() - 90,
  local!fHasta: today(),
  local!fLinea: null,
  local!fOrigen: null,
  local!tab: 1,
  local!tabs: {"Resumen", "Gestiones y resultados", "Servicios", "Errores", "Cuadro de Gestión"},
  /* Años del selector: al cambiar el año se reescribe la fecha de la caja (el calendario de Appian solo navega) */
  local!anios: reverse(enumerate(6) + year(today()) - 5),
  local!ini: if(a!isNullOrEmpty(local!fDesde), userdatetime(2000, 1, 1, 0, 0, 0), userdatetime(year(local!fDesde), month(local!fDesde), day(local!fDesde), 0, 0, 0)),
  local!fin: if(a!isNullOrEmpty(local!fHasta), now(), userdatetime(year(local!fHasta), month(local!fHasta), day(local!fHasta), 23, 59, 59)),
  local!estCerrados: {
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA, cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA, cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ,
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR, cons!SCA2_TXT_ESTADO_SOL_CANCELADA,
    cons!SCA2_TXT_ESTADO_SOL_CADUCADA, cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA
  },
  local!estError: {"ERROR", "ERROR_DECISION"},
  local!colores: {"#0D82BD", "#00A651", "#DF0027", "#FF8000", "#9F9F9F", "#6C3FB5", "#00A3A3", "#E5B700", "#7A4E2D", "#2C3E50"},
  /* Filtros por record */
  local!fSol: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
    a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt', operator: "between", value: {local!ini, local!fin}),
    a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', operator: "=", value: local!fLinea),
    a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: local!fOrigen)
  }),
  local!fDso: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
    a!queryFilter(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.relationships.{dcd9a794-a9c6-478d-a540-0baee529aaac}solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt', operator: "between", value: {local!ini, local!fin}),
    a!queryFilter(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.relationships.{dcd9a794-a9c6-478d-a540-0baee529aaac}solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', operator: "=", value: local!fLinea),
    a!queryFilter(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.relationships.{dcd9a794-a9c6-478d-a540-0baee529aaac}solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: local!fOrigen)
  }),
  local!fTra: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
    a!queryFilter(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha', operator: "between", value: {local!ini, local!fin}),
    a!queryFilter(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.relationships.{6e01950e-4dd3-423d-9fec-73037ec92b0e}solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', operator: "=", value: local!fLinea),
    a!queryFilter(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.relationships.{6e01950e-4dd3-423d-9fec-73037ec92b0e}solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: local!fOrigen)
  }),
  local!fTar: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
    a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion', operator: "between", value: {local!ini, local!fin}),
    a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.relationships.{e7eafc93-5361-430f-8209-19460fc01fc7}solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', operator: "=", value: local!fLinea),
    a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.relationships.{e7eafc93-5361-430f-8209-19460fc01fc7}solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: local!fOrigen)
  }),
  local!fLla: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
    a!queryFilter(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{185fce90-daeb-4cf5-9692-7dcc3d360b75}fechaInicio', operator: "between", value: {local!ini, local!fin}),
    a!queryFilter(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.relationships.{4cb0cec1-ec94-4c68-b3ee-b75863e3cb9e}solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', operator: "=", value: local!fLinea),
    a!queryFilter(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.relationships.{4cb0cec1-ec94-4c68-b3ee-b75863e3cb9e}solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: local!fOrigen)
  }),
  local!fErr: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
    a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', operator: "between", value: {local!ini, local!fin}),
    a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.relationships.{5c36a57b-5e68-4ebb-acbe-7c4ed9d9695a}solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', operator: "=", value: local!fLinea),
    a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.relationships.{5c36a57b-5e68-4ebb-acbe-7c4ed9d9695a}solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', operator: "=", value: local!fOrigen)
  }),
  /* Agregados de solicitudes (se usan en Resumen y Gestiones) */
  local!qEstado: a!queryRecordType(
    recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
    fields: a!aggregationFields(
      groupings: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud', alias: "g"),
      measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n")
    ),
    filters: local!fSol,
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 100, sort: a!sortInfo(field: "n", ascending: false))
  ).data,
  local!origenes: a!queryRecordType(
    recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
    fields: a!aggregationFields(
      groupings: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', alias: "g"),
      measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n")
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "g", ascending: true))
  ).data,
  local!listaOrigenes: reject(fn!isnull, touniformstring(index(local!origenes, "g", {}))),
  local!total: sum(tointeger(index(local!qEstado, "n", {}))),
  local!nCerradas: sum(a!forEach(items: local!qEstado, expression: if(contains(touniformstring(local!estCerrados), tostring(fv!item.g)), fv!item.n, 0))),
  local!nError: sum(a!forEach(items: local!qEstado, expression: if(contains(touniformstring(local!estError), tostring(fv!item.g)), fv!item.n, 0))),
  local!nPositivo: sum(a!forEach(items: local!qEstado, expression: if(tostring(fv!item.g) = cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO, fv!item.n, 0))),
  local!nCanceladas: sum(a!forEach(items: local!qEstado, expression: if(tostring(fv!item.g) = cons!SCA2_TXT_ESTADO_SOL_CANCELADA, fv!item.n, 0))),
  local!nResueltas: local!nCerradas - local!nCanceladas,
  local!pct: if(local!nResueltas > 0, round(100 * local!nPositivo / local!nResueltas, 1), 0),
  /* Etiqueta funcional del estado (SCA2_textoEstadoSolicitud); ERROR se muestra aparte como «Con error» */
  local!etqEstado: a!forEach(items: local!qEstado, expression: if(
    tostring(fv!item.g) = "ERROR",
    "Con error",
    a!defaultValue(rule!SCA2_textoEstadoSolicitud(tostring(fv!item.g)), a!defaultValue(fv!item.g, "Sin estado"))
  )),
  local!nEstado: tointeger(index(local!qEstado, "n", {})),
  local!agruparEtq: a!localVariables(
    local!u: union(touniformstring(local!etqEstado), touniformstring(local!etqEstado)),
    todatasubset(
      a!forEach(items: local!u, expression: a!map(e: fv!item, n: sum(index(local!nEstado, wherecontains(fv!item, touniformstring(local!etqEstado)), 0)))),
      a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "n", ascending: false))
    ).data
  ),
  {
    /* Filtros */
    a!cardLayout(
      contents: {
        a!columnsLayout(
          columns: {
            a!columnLayout(contents: a!sideBySideLayout(
              items: {
                a!sideBySideItem(item: a!dateField(label: "Fecha de alta de la solicitud: desde", value: local!fDesde, saveInto: local!fDesde)),
                a!sideBySideItem(
                  item: a!dropdownField(
                    label: "Año",
                    placeholder: "--",
                    choiceLabels: local!anios,
                    choiceValues: local!anios,
                    value: if(a!isNullOrEmpty(local!fDesde), null, if(contains(local!anios, year(local!fDesde)), year(local!fDesde), null)),
                    saveInto: a!save(
                      local!fDesde,
                      if(
                        a!isNullOrEmpty(save!value),
                        local!fDesde,
                        if(
                          a!isNullOrEmpty(local!fDesde),
                          date(save!value, 1, 1),
                          date(save!value, month(local!fDesde), min(day(local!fDesde), daysinmonth(month(local!fDesde), save!value)))
                        )
                      )
                    )
                  ),
                  width: "MINIMIZE"
                )
              },
              alignVertical: "BOTTOM"
            )),
            a!columnLayout(contents: a!sideBySideLayout(
              items: {
                a!sideBySideItem(item: a!dateField(label: "Fecha de alta de la solicitud: hasta", value: local!fHasta, saveInto: local!fHasta)),
                a!sideBySideItem(
                  item: a!dropdownField(
                    label: "Año",
                    placeholder: "--",
                    choiceLabels: local!anios,
                    choiceValues: local!anios,
                    value: if(a!isNullOrEmpty(local!fHasta), null, if(contains(local!anios, year(local!fHasta)), year(local!fHasta), null)),
                    saveInto: a!save(
                      local!fHasta,
                      if(
                        a!isNullOrEmpty(save!value),
                        local!fHasta,
                        if(
                          a!isNullOrEmpty(local!fHasta),
                          date(save!value, 12, 31),
                          date(save!value, month(local!fHasta), min(day(local!fHasta), daysinmonth(month(local!fHasta), save!value)))
                        )
                      )
                    )
                  ),
                  width: "MINIMIZE"
                )
              },
              alignVertical: "BOTTOM"
            ))
          },
          stackWhen: {"PHONE", "TABLET_PORTRAIT"}
        ),
        a!columnsLayout(
          columns: {
            a!columnLayout(contents: a!dropdownField(
              label: "Línea de negocio",
              placeholder: "Todas",
              choiceLabels: cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE,
              choiceValues: cons!SCA2_INT_ID_LINEA_NEGOCIO,
              value: local!fLinea,
              saveInto: local!fLinea
            )),
            a!columnLayout(contents: a!dropdownField(
              label: "Origen de la póliza",
              placeholder: "Todos",
              choiceLabels: local!listaOrigenes,
              choiceValues: local!listaOrigenes,
              value: local!fOrigen,
              saveInto: local!fOrigen
            ))
          },
          stackWhen: {"PHONE", "TABLET_PORTRAIT"}
        ),
        a!richTextDisplayField(
          labelPosition: "COLLAPSED",
          showWhen: and(a!isNotNullOrEmpty(local!fDesde), local!fDesde < cons!SCA2_FECHA_INICIO_DATOS),
          value: {
            a!richTextIcon(icon: "exclamation-triangle", color: "#FF8000"),
            " ",
            a!richTextItem(
              text: "SCA2 solo tiene datos desde el " & text(cons!SCA2_FECHA_INICIO_DATOS, "dd/mm/yyyy") & ". Las cifras anteriores a esa fecha no están en este cuadro.",
              color: "SECONDARY"
            )
          }
        )
      },
      style: "#F7F7F7",
      showBorder: false,
      padding: "STANDARD",
      marginBelow: "STANDARD"
    ),
    /* Pestañas */
    a!columnsLayout(
      columns: a!forEach(
        items: local!tabs,
        expression: a!columnLayout(
          contents: a!cardLayout(
            contents: a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              align: "CENTER",
              value: a!richTextItem(text: fv!item, color: "ACCENT", style: if(fv!index = local!tab, "STRONG", "PLAIN"))
            ),
            link: a!dynamicLink(value: fv!index, saveInto: local!tab),
            style: "NONE",
            padding: "EVEN_LESS",
            showBorder: false,
            decorativeBarPosition: "BOTTOM",
            decorativeBarColor: if(fv!index = local!tab, "ACCENT", "#FFFFFF"),
            accessibilityText: if(fv!index = local!tab, "Pestaña seleccionada", "Pestaña")
          )
        )
      ),
      stackWhen: {"PHONE"},
      marginBelow: "STANDARD"
    ),
    choose(
      local!tab,
      /* 1 - Resumen */
      a!localVariables(
        local!qLla: a!queryRecordType(
          recordType: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ab5ad5f7-dc3c-4ba4-b85c-9614357da937}resultado', alias: "g"),
            measures: a!measure(function: "COUNT", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{37c33a34-b8f9-4870-9230-5072062e7ecb}id', alias: "n")
          ),
          filters: local!fLla,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20)
        ).data,
        local!nLla: sum(tointeger(index(local!qLla, "n", {}))),
        local!nLlaOk: sum(a!forEach(items: local!qLla, expression: if(tostring(fv!item.g) = "OK", fv!item.n, 0))),
        local!nGestiones: a!queryRecordType(
          recordType: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion',
          fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{a4991d4a-1b0a-478c-b5ed-a406b2c4ec49}id', alias: "n")),
          filters: local!fTra,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
        ).data,
        local!nTarPend: a!queryRecordType(
          recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
          fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', alias: "n")),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fTar, filters: a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado', operator: "=", value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE)),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
        ).data,
        local!nMecanizadas: a!queryRecordType(
          recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
          fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n")),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fSol, filters: a!queryFilter(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{0dd20f14-e41a-423d-b5a1-9901b88e2287}mecanizacionRealizada', operator: "=", value: true)),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
        ).data,
        local!qLinea: a!queryRecordType(
          recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio', alias: "g"),
            measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n")
          ),
          filters: local!fSol,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20)
        ).data,
        local!qNivel: a!queryRecordType(
          recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6da95481-fa80-4768-9b86-2fae6259874e}nivelIntervencion', alias: "g"),
            measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n")
          ),
          filters: local!fSol,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20, sort: a!sortInfo(field: "g", ascending: true))
        ).data,
        local!kpis: {
          a!map(t: "Solicitudes de anulación", v: local!total, d: "Altas en el periodo", c: "#0D82BD"),
          a!map(t: "En curso", v: local!total - local!nCerradas - local!nError, d: "Pendientes de gestión", c: "#FF8000"),
          a!map(t: "Cerradas", v: local!nCerradas, d: "Finalizadas, canceladas o caducadas", c: "#2C3E50"),
          a!map(t: "Contra anulación positiva", v: local!nPositivo, d: local!pct & " % de las resueltas", c: "#00A651"),
          a!map(t: "Anulaciones mecanizadas", v: a!defaultValue(index(index(local!nMecanizadas, 1, null), "n", null), 0), d: "Mecanización realizada", c: "#6C3FB5"),
          a!map(t: "Pasos ejecutados", v: a!defaultValue(index(index(local!nGestiones, 1, null), "n", null), 0), d: "Comandos ejecutados", c: "#00A3A3"),
          a!map(t: "Tareas pendientes", v: a!defaultValue(index(index(local!nTarPend, 1, null), "n", null), 0), d: "Tareas creadas en el periodo y sin cerrar", c: "#E5B700"),
          a!map(t: "Llamadas a servicios", v: local!nLla, d: if(local!nLla > 0, round(100 * local!nLlaOk / local!nLla, 1) & " % correctas", "Sin llamadas"), c: "#9F9F9F"),
          a!map(t: "Solicitudes en error", v: local!nError, d: "Con error / Error en el servicio de decisión", c: "#DF0027")
        },
        {
          a!forEach(
            items: enumerate(ceiling(length(local!kpis) / 3)),
            expression: a!localVariables(
              local!fila: fv!item,
              a!columnsLayout(
                columns: a!forEach(
                  items: index(local!kpis, 3 * local!fila + enumerate(3) + 1, {}),
                  expression: a!columnLayout(contents: a!cardLayout(
                contents: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: {
                    a!richTextItem(text: fv!item.t, color: "SECONDARY", size: "SMALL", style: "STRONG"),
                    char(10),
                    a!richTextItem(text: fv!item.v, size: "LARGE", style: "STRONG", color: fv!item.c),
                    char(10),
                    a!richTextItem(text: fv!item.d, color: "SECONDARY", size: "SMALL")
                  }
                ),
                showBorder: true,
                padding: "STANDARD",
                decorativeBarPosition: "TOP",
                decorativeBarColor: fv!item.c,
                marginBelow: "STANDARD"
              ))
                ),
                stackWhen: {"PHONE"}
              )
            )
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!lineChartField(
                label: "Altas de solicitudes por día",
                data: a!recordData(recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud', filters: local!fSol),
                config: a!lineChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt', interval: "DATE_SHORT_TEXT", alias: "dia"),
                  secondaryGrouping: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', alias: "origen"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n", label: "Solicitudes"),
                  dataLimit: 500
                ),
                yAxisTitle: "Solicitudes",
                height: "MEDIUM",
                colorScheme: "OCEAN"
              ), width: "WIDE"),
              a!columnLayout(contents: a!barChartField(
                label: "Solicitudes por estado actual",
                categories: index(local!agruparEtq, "e", {}),
                series: a!chartSeries(label: "Solicitudes", data: tointeger(index(local!agruparEtq, "n", {})), color: "#0D82BD"),
                showDataLabels: true,
                showLegend: false,
                height: "MEDIUM"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT", "TABLET_LANDSCAPE", "DESKTOP_NARROW"}
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!pieChartField(
                label: "Por línea de negocio",
                series: a!forEach(items: local!qLinea, expression: a!chartSeries(
                  label: if(contains(touniformstring(cons!SCA2_INT_ID_LINEA_NEGOCIO), tostring(fv!item.g)), index(cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE, wherecontains(tostring(fv!item.g), touniformstring(cons!SCA2_INT_ID_LINEA_NEGOCIO))[1], ""), "Línea " & fv!item.g),
                  data: fv!item.n,
                  color: index(local!colores, mod(fv!index - 1, 10) + 1, "#9F9F9F")
                )),
                showDataLabels: true,
                showAsPercentage: true,
                height: "SHORT"
              )),
              a!columnLayout(contents: a!pieChartField(
                label: "Por origen de la póliza",
                data: a!recordData(recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud', filters: local!fSol),
                config: a!pieChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza', alias: "origen"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n", label: "Solicitudes"),
                  dataLimit: 10
                ),
                showDataLabels: true,
                height: "SHORT",
                colorScheme: "OCEAN"
              )),
              a!columnLayout(contents: a!pieChartField(
                label: "Por grupo de asignación",
                data: a!recordData(recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud', filters: local!fSol),
                config: a!pieChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{425684ff-66e8-4c2a-a9dd-254a071d3ecd}grupoAsignacion', alias: "grupo"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id', alias: "n", label: "Solicitudes"),
                  dataLimit: 10
                ),
                showDataLabels: true,
                height: "SHORT",
                colorScheme: "RAINFOREST"
              )),
              a!columnLayout(contents: a!columnChartField(
                label: "Por nivel de intervención",
                categories: a!forEach(items: local!qNivel, expression: if(a!isNullOrEmpty(fv!item.g), "Sin nivel", "Nivel " & fv!item.g)),
                series: a!chartSeries(label: "Solicitudes", data: tointeger(index(local!qNivel, "n", {})), color: "#0D82BD"),
                showDataLabels: true,
                showLegend: false,
                height: "SHORT"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT", "TABLET_LANDSCAPE"}
          )
        }
      ),
      /* 2 - Gestiones y resultados */
      a!localVariables(
        local!qMot: a!queryRecordType(
          recordType: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud',
          fields: a!aggregationFields(
            groupings: {a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{6442cb78-017d-4555-9dc1-2ce2cbb9cb5f}codmotivo', alias: "m"), a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{411a3de1-fdd8-425c-bfa3-af3eeeeab3ad}coddetalle', alias: "d")},
            measures: a!measure(function: "COUNT", field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{2d7b6a31-0f04-449a-b030-61dc1c3dc8b5}id', alias: "n")
          ),
          filters: local!fDso,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 200, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        local!catMot: a!queryRecordType(
          recordType: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo',
          fields: {'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion'},
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1000)
        ).data,
        local!catDet: a!queryRecordType(
          recordType: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle',
          fields: {'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion'},
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1000)
        ).data,
        local!codMotCat: touniformstring(index(local!catMot, 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', {})),
        local!clavesDet: a!forEach(items: local!catDet, expression: fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo'] & "-" & fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle']),
        local!motivos: union(touniformstring(index(local!qMot, "m", {})), touniformstring({})),
        local!descMot: a!forEach(items: local!motivos, expression: if(
          contains(local!codMotCat, fv!item),
          index(local!catMot, wherecontains(fv!item, local!codMotCat)[1], null)['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion'],
          if(a!isNullOrEmpty(fv!item), "Sin motivo", "Motivo " & fv!item)
        )),
        local!nMot: a!forEach(items: local!motivos, expression: a!localVariables(
          local!m: fv!item,
          sum(a!forEach(items: local!qMot, expression: if(tostring(fv!item.m) = local!m, fv!item.n, 0)))
        )),
        local!qDet: todatasubset(local!qMot, a!pagingInfo(startIndex: 1, batchSize: 10, sort: a!sortInfo(field: "n", ascending: false))).data,
        local!qCanal: a!queryRecordType(
          recordType: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{b0a636f9-1b0a-4d66-80d1-0d8003effdeb}canalentrada', alias: "g"),
            measures: a!measure(function: "COUNT", field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{2d7b6a31-0f04-449a-b030-61dc1c3dc8b5}id', alias: "n")
          ),
          filters: local!fDso,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        local!qCat: a!queryRecordType(
          recordType: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{c9ec6603-e54a-4469-884e-a8a9872fce1e}catalogacion', alias: "g"),
            measures: a!measure(function: "COUNT", field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{2d7b6a31-0f04-449a-b030-61dc1c3dc8b5}id', alias: "n")
          ),
          filters: local!fDso,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        local!cerradas: a!forEach(items: local!qEstado, expression: if(contains(touniformstring(local!estCerrados), tostring(fv!item.g)), fv!item, {})),
        local!etqCerr: a!forEach(items: local!cerradas, expression: a!defaultValue(rule!SCA2_textoEstadoSolicitud(tostring(fv!item.g)), tostring(fv!item.g))),
        local!nCerr: tointeger(index(local!cerradas, "n", {})),
        local!cerrEtq: a!localVariables(
          local!u: union(touniformstring(local!etqCerr), touniformstring(local!etqCerr)),
          todatasubset(
            a!forEach(items: local!u, expression: a!map(e: fv!item, n: sum(index(local!nCerr, wherecontains(fv!item, touniformstring(local!etqCerr)), 0)))),
            a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "n", ascending: false))
          ).data
        ),
        local!motOrden: todatasubset(
          a!forEach(items: local!motivos, expression: a!map(d: index(local!descMot, fv!index, ""), n: index(local!nMot, fv!index, 0))),
          a!pagingInfo(startIndex: 1, batchSize: 100, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        /* Causa x detalle (barras apiladas, causas de mayor a menor) */
        local!qCausa: a!queryRecordType(
          recordType: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud',
          fields: a!aggregationFields(
            groupings: {
              a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{b3b05401-6420-4d28-8c0a-d55c0665a687}desccausa', alias: "c"),
              a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{6442cb78-017d-4555-9dc1-2ce2cbb9cb5f}codmotivo', alias: "m"),
              a!grouping(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{411a3de1-fdd8-425c-bfa3-af3eeeeab3ad}coddetalle', alias: "d")
            },
            measures: a!measure(function: "COUNT", field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{2d7b6a31-0f04-449a-b030-61dc1c3dc8b5}id', alias: "n")
          ),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fDso, filters: a!queryFilter(field: 'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{b3b05401-6420-4d28-8c0a-d55c0665a687}desccausa', operator: "not null")),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        local!causaFila: touniformstring(index(local!qCausa, "c", {})),
        local!nCausaFila: tointeger(index(local!qCausa, "n", {})),
        local!detFila: a!forEach(items: local!qCausa, expression: a!localVariables(
          local!k: fv!item.m & "-" & fv!item.d,
          if(
            contains(local!clavesDet, local!k),
            index(local!catDet, wherecontains(local!k, local!clavesDet)[1], null)['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion'],
            if(a!isNullOrEmpty(fv!item.d), "Sin detalle", "Detalle " & local!k)
          )
        )),
        local!causaOrden: a!localVariables(
          local!u: union(local!causaFila, local!causaFila),
          todatasubset(
            a!forEach(items: local!u, expression: a!map(c: fv!item, n: sum(index(local!nCausaFila, wherecontains(fv!item, local!causaFila), 0)))),
            a!pagingInfo(startIndex: 1, batchSize: 15, sort: a!sortInfo(field: "n", ascending: false))
          ).data
        ),
        local!detalles: union(touniformstring(local!detFila), touniformstring(local!detFila)),
        /* Gestiones (tareas) por tipo y estado */
        local!qGes: a!queryRecordType(
          recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
          fields: a!aggregationFields(
            groupings: {a!grouping(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea', alias: "t"), a!grouping(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado', alias: "e")},
            measures: a!measure(function: "COUNT", field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', alias: "n")
          ),
          filters: local!fTar,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        local!gesTarea: a!forEach(items: local!qGes, expression: a!defaultValue(fv!item.t, "Sin nombre")),
        local!gesEtq: a!forEach(items: local!qGes, expression: a!localVariables(
          local!e: tostring(fv!item.e),
          if(
            local!e = cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA, "Cerrada por el gestor",
            if(local!e = "FINALIZADA", "Cerrada por el sistema",
            if(local!e = cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE, "Pendiente",
            if(local!e = "CANCELADA", "Cancelada", a!defaultValue(fv!item.e, "Sin estado"))))
          )
        )),
        local!nGes: tointeger(index(local!qGes, "n", {})),
        local!gesOrden: a!localVariables(
          local!u: union(touniformstring(local!gesTarea), touniformstring(local!gesTarea)),
          todatasubset(
            a!forEach(items: local!u, expression: a!map(t: fv!item, n: sum(index(local!nGes, wherecontains(fv!item, touniformstring(local!gesTarea)), 0)))),
            a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "n", ascending: false))
          ).data
        ),
        local!gesEstados: union(touniformstring(local!gesEtq), touniformstring(local!gesEtq)),
        /* Inducción Verti/Vencimiento (componente CMP): tareas INDUCCION del periodo */
        local!qInd: a!queryRecordType(
          recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado', alias: "e"),
            measures: a!measure(function: "COUNT", field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', alias: "n")
          ),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fTar, filters: a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo', operator: "=", value: "INDUCCION")),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20)
        ).data,
        local!nIndTot: sum(tointeger(index(local!qInd, "n", {}))),
        local!nIndOk: sum(a!forEach(items: local!qInd, expression: if(tostring(fv!item.e) = cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA, fv!item.n, 0))),
        local!nIndMas1h: a!defaultValue(index(index(a!queryRecordType(
          recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
          fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id', alias: "n")),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fTar, filters: {
            a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo', operator: "=", value: "INDUCCION"),
            a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado', operator: "=", value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE),
            a!queryFilter(field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion', operator: "<", value: now() - intervalds(1, 0, 0))
          }),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
        ).data, 1, null), "n", null), 0),
        {
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!pieChartField(
                label: "Resultado de las solicitudes cerradas",
                series: a!forEach(items: local!cerrEtq, expression: a!chartSeries(
                  label: fv!item.e,
                  data: fv!item.n,
                  color: index(local!colores, mod(fv!index - 1, 10) + 1, "#9F9F9F")
                )),
                showDataLabels: true,
                showAsPercentage: true,
                height: "MEDIUM"
              )),
              a!columnLayout(contents: a!barChartField(
                label: "Motivos de anulación",
                categories: index(local!motOrden, "d", {}),
                series: a!chartSeries(label: "Solicitudes", data: tointeger(index(local!motOrden, "n", {})), color: "#0D82BD"),
                showDataLabels: true,
                showLegend: false,
                height: "MEDIUM"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!barChartField(
                label: "Detalle del motivo (10 más frecuentes)",
                categories: a!forEach(items: local!qDet, expression: a!localVariables(
                  local!k: fv!item.m & "-" & fv!item.d,
                  if(contains(local!clavesDet, local!k), index(local!catDet, wherecontains(local!k, local!clavesDet)[1], null)['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion'], if(a!isNullOrEmpty(fv!item.d), "Sin detalle", "Detalle " & local!k))
                )),
                series: a!chartSeries(label: "Solicitudes", data: tointeger(index(local!qDet, "n", {})), color: "#00A3A3"),
                showDataLabels: true,
                showLegend: false,
                height: "MEDIUM"
              )),
              a!columnLayout(contents: a!barChartField(
                label: "Causa indicada por el cliente y detalle",
                categories: index(local!causaOrden, "c", {}),
                series: a!forEach(items: local!detalles, expression: a!localVariables(
                  local!det: fv!item,
                  a!chartSeries(
                    label: local!det,
                    data: a!forEach(items: index(local!causaOrden, "c", {}), expression: sum(index(local!nCausaFila, intersection(wherecontains(tostring(fv!item), local!causaFila), wherecontains(local!det, touniformstring(local!detFila))), 0))),
                    color: index(local!colores, mod(fv!index - 1, 10) + 1, "#9F9F9F")
                  )
                )),
                stacking: "NORMAL",
                showDataLabels: false,
                showLegend: true,
                height: "MEDIUM"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!columnChartField(
                label: "Canal de entrada",
                categories: a!forEach(items: local!qCanal, expression: if(
                  contains(cons!SCA2_INT_CANALES_ENTRADA_COD, tointeger(fv!item.g)),
                  index(cons!SCA2_TXT_CANALES_ENTRADA_DESC, wherecontains(tointeger(fv!item.g), cons!SCA2_INT_CANALES_ENTRADA_COD)[1], ""),
                  if(a!isNullOrEmpty(fv!item.g), "Sin canal", "Canal " & fv!item.g)
                )),
                series: a!chartSeries(label: "Solicitudes", data: tointeger(index(local!qCanal, "n", {})), color: "#6C3FB5"),
                showDataLabels: true,
                showLegend: false,
                height: "SHORT"
              )),
              a!columnLayout(contents: a!columnChartField(
                label: "Tipo de catalogación",
                categories: a!forEach(items: local!qCat, expression: if(
                  contains(cons!SCA2_INT_TIP_CATALOGACION_PCA, tointeger(fv!item.g)),
                  index(cons!SCA2_TXT_TIP_CATALOGACION_PCA, wherecontains(tointeger(fv!item.g), cons!SCA2_INT_TIP_CATALOGACION_PCA)[1], ""),
                  if(a!isNullOrEmpty(fv!item.g), "Sin catalogación", "Catalogación " & fv!item.g)
                )),
                series: a!chartSeries(label: "Solicitudes", data: tointeger(index(local!qCat, "n", {})), color: "#FF8000"),
                showDataLabels: true,
                showLegend: false,
                height: "SHORT"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!barChartField(
                label: "Gestiones por tipo y estado",
                categories: index(local!gesOrden, "t", {}),
                series: a!forEach(items: local!gesEstados, expression: a!localVariables(
                  local!est: fv!item,
                  a!chartSeries(
                    label: local!est,
                    data: a!forEach(items: index(local!gesOrden, "t", {}), expression: sum(index(local!nGes, intersection(wherecontains(tostring(fv!item), touniformstring(local!gesTarea)), wherecontains(local!est, touniformstring(local!gesEtq))), 0))),
                    color: if(local!est = "Cerrada por el gestor", "#00A651", if(local!est = "Cerrada por el sistema", "#0D82BD", if(local!est = "Pendiente", "#FF8000", if(local!est = "Cancelada", "#9F9F9F", "#6C3FB5"))))
                  )
                )),
                stacking: "NORMAL",
                showDataLabels: true,
                height: "MEDIUM"
              ), width: "WIDE"),
              a!columnLayout(contents: {
                a!pieChartField(
                  label: "Inducción Verti/Vencimiento",
                  instructions: "Tareas de inducción en el componente creadas en el periodo",
                  series: {
                    a!chartSeries(label: "Terminada", data: local!nIndOk, color: "#00A651"),
                    a!chartSeries(label: "Sin terminar", data: local!nIndTot - local!nIndOk, color: "#FF8000")
                  },
                  showDataLabels: true,
                  height: "MEDIUM"
                ),
                a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  showWhen: local!nIndMas1h > 0,
                  value: a!richTextItem(
                    text: local!nIndMas1h & " sin terminar desde hace más de 1 hora: la inducción en el componente no ha terminado. La solicitud sigue su curso.",
                    color: "SECONDARY",
                    size: "SMALL"
                  )
                )
              })
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          )
        }
      ),
      /* 3 - Servicios */
      a!localVariables(
        local!qSrv: a!queryRecordType(
          recordType: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{2b088145-2488-4745-aec9-cd44c60bfe2e}servicio', alias: "g"),
            measures: {
              a!measure(function: "COUNT", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{37c33a34-b8f9-4870-9230-5072062e7ecb}id', alias: "n"),
              a!measure(function: "AVG", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{add72869-c696-43fa-b2a7-3434f97457d1}duracionMs', alias: "avg"),
              a!measure(function: "MAX", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{add72869-c696-43fa-b2a7-3434f97457d1}duracionMs', alias: "max")
            }
          ),
          filters: local!fLla,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 100, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        local!qSrvErr: a!queryRecordType(
          recordType: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio',
          fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{37c33a34-b8f9-4870-9230-5072062e7ecb}id', alias: "n")),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fLla, filters: a!queryFilter(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ab5ad5f7-dc3c-4ba4-b85c-9614357da937}resultado', operator: "<>", value: "OK")),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
        ).data,
        local!qCmdDur: a!queryRecordType(
          recordType: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{cb874e4d-61fb-4bd1-8062-e138a364eb82}comando', alias: "g"),
            measures: a!measure(function: "AVG", field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{6d4684e9-86b1-48c7-a8ce-8a960d2e6509}duracionMs', alias: "avg")
          ),
          filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fTra, filters: a!queryFilter(field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{6d4684e9-86b1-48c7-a8ce-8a960d2e6509}duracionMs', operator: "not null")),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 50, sort: a!sortInfo(field: "avg", ascending: false))
        ).data,
        local!qSrvT: todatasubset(local!qSrv, a!pagingInfo(startIndex: 1, batchSize: 100, sort: a!sortInfo(field: "avg", ascending: false))).data,
        local!nTot: sum(tointeger(index(local!qSrv, "n", {}))),
        local!nErr: a!defaultValue(index(index(local!qSrvErr, 1, null), "n", null), 0),
        local!avgTot: if(local!nTot > 0, sum(a!forEach(items: local!qSrv, expression: a!defaultValue(fv!item.avg, 0) * fv!item.n)) / local!nTot, 0),
        {
          a!localVariables(
            local!tarjetasSrv: {
                a!map(t: "Llamadas a servicios", v: local!nTot, c: "#0D82BD"),
                a!map(t: "Correctas", v: local!nTot - local!nErr, c: "#00A651"),
                a!map(t: "Con error", v: local!nErr, c: "#DF0027"),
                a!map(t: "% de éxito", v: if(local!nTot > 0, round(100 * (local!nTot - local!nErr) / local!nTot, 1) & " %", "-"), c: "#2C3E50"),
                a!map(t: "Tiempo medio de respuesta", v: round(local!avgTot / 1000, 2) & " s", c: "#FF8000")
              },
            a!forEach(
              items: enumerate(ceiling(length(local!tarjetasSrv) / 3)),
              expression: a!localVariables(
                local!fila: fv!item,
                a!columnsLayout(
                  columns: a!forEach(
                    items: 3 * local!fila + 1 + enumerate(min(3, length(local!tarjetasSrv) - 3 * local!fila)),
                    expression: a!columnLayout(contents: a!cardLayout(
                contents: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: {
                    a!richTextItem(text: index(index(local!tarjetasSrv, fv!item, null), "t", null), color: "SECONDARY", size: "SMALL", style: "STRONG"),
                    char(10),
                    a!richTextItem(text: index(index(local!tarjetasSrv, fv!item, null), "v", null), size: "LARGE", style: "STRONG", color: index(index(local!tarjetasSrv, fv!item, null), "c", null))
                  }
                ),
                showBorder: true,
                padding: "STANDARD",
                decorativeBarPosition: "TOP",
                decorativeBarColor: index(index(local!tarjetasSrv, fv!item, null), "c", null),
                marginBelow: "STANDARD"
              ))
                  ),
                  stackWhen: {"PHONE"}
                )
              )
            )
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!barChartField(
                label: "Llamadas por servicio y resultado",
                data: a!recordData(recordType: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio', filters: local!fLla),
                config: a!barChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{2b088145-2488-4745-aec9-cd44c60bfe2e}servicio', alias: "servicio"),
                  secondaryGrouping: a!grouping(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ab5ad5f7-dc3c-4ba4-b85c-9614357da937}resultado', alias: "resultado"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{37c33a34-b8f9-4870-9230-5072062e7ecb}id', alias: "n", label: "Llamadas"),
                  dataLimit: 100
                ),
                stacking: "NORMAL",
                height: "MEDIUM",
                colorScheme: "OCEAN"
              )),
              a!columnLayout(contents: a!barChartField(
                label: "Tiempo de respuesta por servicio (ms), de mayor a menor tiempo medio",
                categories: index(local!qSrvT, "g", {}),
                series: {
                  a!chartSeries(label: "Media", data: a!forEach(items: local!qSrvT, expression: tointeger(round(a!defaultValue(fv!item.avg, 0), 0))), color: "#0D82BD"),
                  a!chartSeries(label: "Máximo", data: a!forEach(items: local!qSrvT, expression: tointeger(round(a!defaultValue(fv!item.max, 0), 0))), color: "#FF8000")
                },
                showDataLabels: true,
                height: "MEDIUM"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!columnChartField(
                label: "Llamadas a servicios por día",
                data: a!recordData(recordType: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio', filters: local!fLla),
                config: a!columnChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{185fce90-daeb-4cf5-9692-7dcc3d360b75}fechaInicio', interval: "DATE_SHORT_TEXT", alias: "dia"),
                  secondaryGrouping: a!grouping(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ab5ad5f7-dc3c-4ba4-b85c-9614357da937}resultado', alias: "resultado"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{37c33a34-b8f9-4870-9230-5072062e7ecb}id', alias: "n", label: "Llamadas"),
                  dataLimit: 500
                ),
                stacking: "NORMAL",
                height: "MEDIUM",
                colorScheme: "OCEAN"
              )),
              a!columnLayout(contents: a!barChartField(
                label: "Duración media de cada gestión (ms)",
                categories: index(local!qCmdDur, "g", {}),
                series: a!chartSeries(label: "Media", data: a!forEach(items: local!qCmdDur, expression: tointeger(round(a!defaultValue(fv!item.avg, 0), 0))), color: "#6C3FB5"),
                showDataLabels: true,
                showLegend: false,
                height: "MEDIUM"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          )
        }
      ),
      /* 4 - Errores */
      a!localVariables(
        local!qErrEst: a!queryRecordType(
          recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', alias: "g"),
            measures: a!measure(function: "COUNT", field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', alias: "n")
          ),
          filters: local!fErr,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20, sort: a!sortInfo(field: "n", ascending: false))
        ).data,
        {
          rule!SCA2_IndicadorFinalizacionesFallidas(
            desde: local!ini,
            hasta: local!fin,
            lineaNegocio: local!fLinea,
            origenPoliza: local!fOrigen
          ),
          a!localVariables(
            local!tarjetasErr: a!flatten({a!map(g: "registrados", n: sum(tointeger(index(local!qErrEst, "n", {})))), local!qErrEst}),
            a!forEach(
              items: enumerate(ceiling(length(local!tarjetasErr) / 3)),
              expression: a!localVariables(
                local!fila: fv!item,
                a!columnsLayout(
                  columns: a!forEach(
                    items: 3 * local!fila + 1 + enumerate(min(3, length(local!tarjetasErr) - 3 * local!fila)),
                    expression: a!columnLayout(contents: a!cardLayout(
                contents: a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: {
                    a!richTextItem(text: "Errores " & lower(index(index(local!tarjetasErr, fv!item, null), "g", null)), color: "SECONDARY", size: "SMALL", style: "STRONG"),
                    char(10),
                    a!richTextItem(text: index(index(local!tarjetasErr, fv!item, null), "n", null), size: "LARGE", style: "STRONG", color: if(index(index(local!tarjetasErr, fv!item, null), "g", null) = "PENDIENTE", "#DF0027", index(local!colores, mod(fv!item - 1, 10) + 1, "#9F9F9F")))
                  }
                ),
                showBorder: true,
                padding: "STANDARD",
                decorativeBarPosition: "TOP",
                decorativeBarColor: if(index(index(local!tarjetasErr, fv!item, null), "g", null) = "PENDIENTE", "#DF0027", index(local!colores, mod(fv!item - 1, 10) + 1, "#9F9F9F")),
                marginBelow: "STANDARD"
              ))
                  ),
                  stackWhen: {"PHONE"}
                )
              )
            )
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!barChartField(
                label: "Errores por código y estado",
                data: a!recordData(recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error', filters: local!fErr),
                config: a!barChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo', alias: "codigo"),
                  secondaryGrouping: a!grouping(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', alias: "estado"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', alias: "n", label: "Errores"),
                  dataLimit: 200
                ),
                stacking: "NORMAL",
                height: "TALL",
                colorScheme: "SUNSET"
              )),
              a!columnLayout(contents: a!barChartField(
                label: "Errores por gestión (comando)",
                data: a!recordData(recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error', filters: local!fErr),
                config: a!barChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', alias: "comando"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', alias: "n", label: "Errores"),
                  dataLimit: 20
                ),
                height: "TALL",
                colorScheme: "SUNSET"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          ),
          a!columnChartField(
            label: "Errores registrados por día",
            data: a!recordData(recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error', filters: local!fErr),
            config: a!columnChartConfig(
              primaryGrouping: a!grouping(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', interval: "DATE_SHORT_TEXT", alias: "dia"),
              secondaryGrouping: a!grouping(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', alias: "estado"),
              measures: a!measure(function: "COUNT", field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id', alias: "n", label: "Errores"),
              dataLimit: 500
            ),
            stacking: "NORMAL",
            height: "MEDIUM",
            colorScheme: "SUNSET"
          ),
          a!localVariables(
            /* Campos explícitos: payload es texto extra largo y no se muestra */
            local!qErrPend: a!queryRecordType(
              recordType: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error',
              fields: {'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos', 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje'},
              filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fErr, filters: a!queryFilter(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado', operator: "=", value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE)),
              pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20, sort: a!sortInfo(field: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion', ascending: false))
            ).data,
            a!localVariables(
              local!qLlaErr: a!queryRecordType(
                recordType: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio',
                fields: {'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{185fce90-daeb-4cf5-9692-7dcc3d360b75}fechaInicio', 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ec6fce18-5229-4904-be38-4f0aadaef7ee}idSolicitud', 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{d6ecceb8-f7ce-4b40-ab39-84158d9d827f}comando', 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{2b088145-2488-4745-aec9-cd44c60bfe2e}servicio', 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{f9756112-5aff-4efb-8a0f-0007ae15069a}codigoHttp', 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{a16b799a-627b-42c0-a146-82a37c295a2e}mensajeError'},
                filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fLla, filters: a!queryFilter(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ab5ad5f7-dc3c-4ba4-b85c-9614357da937}resultado', operator: "<>", value: "OK")),
                pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20, sort: a!sortInfo(field: 'recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{185fce90-daeb-4cf5-9692-7dcc3d360b75}fechaInicio', ascending: false))
              ).data,
              local!filas: todatasubset(
                append(
                  a!forEach(items: local!qErrPend, expression: a!map(
                    fecha: fv!item['recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion'],
                    origen: "Proceso",
                    solicitud: fv!item['recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud'],
                    gestion: fv!item['recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando'],
                    servicio: "",
                    codigo: tostring(fv!item['recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo']),
                    intentos: fv!item['recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos'],
                    mensaje: left(fv!item['recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje'], 200)
                  )),
                  a!forEach(items: local!qLlaErr, expression: a!map(
                    fecha: fv!item['recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{185fce90-daeb-4cf5-9692-7dcc3d360b75}fechaInicio'],
                    origen: "Servicio",
                    solicitud: fv!item['recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{ec6fce18-5229-4904-be38-4f0aadaef7ee}idSolicitud'],
                    gestion: fv!item['recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{d6ecceb8-f7ce-4b40-ab39-84158d9d827f}comando'],
                    servicio: fv!item['recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{2b088145-2488-4745-aec9-cd44c60bfe2e}servicio'],
                    codigo: "HTTP " & fv!item['recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{f9756112-5aff-4efb-8a0f-0007ae15069a}codigoHttp'],
                    intentos: null,
                    mensaje: left(fv!item['recordType!{1abca523-0067-41b0-a694-8f3ce677c2ff}SCA2 Llamada Servicio.fields.{a16b799a-627b-42c0-a146-82a37c295a2e}mensajeError'], 200)
                  ))
                ),
                a!pagingInfo(startIndex: 1, batchSize: 20, sort: a!sortInfo(field: "fecha", ascending: false))
              ).data,
              a!sectionLayout(
                label: "Errores recientes (procesos y servicios)",
                contents: {
                  a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: a!richTextItem(text: "Proceso: errores PENDIENTE de SCA2 Error. Servicio: llamadas a servicios externos con resultado distinto de OK. Se muestran las 20 más recientes.", color: "SECONDARY", size: "SMALL")
                  ),
                  a!gridField(
                    labelPosition: "COLLAPSED",
                    data: local!filas,
                    columns: {
                      a!gridColumn(label: "Fecha", value: fv!row.fecha),
                      a!gridColumn(label: "Origen", value: fv!row.origen),
                      a!gridColumn(label: "Solicitud", value: fv!row.solicitud),
                      a!gridColumn(label: "Gestión", value: fv!row.gestion),
                      a!gridColumn(label: "Servicio", value: fv!row.servicio),
                      a!gridColumn(label: "Código", value: fv!row.codigo),
                      a!gridColumn(label: "Intentos", value: fv!row.intentos, align: "END"),
                      a!gridColumn(label: "Mensaje", value: fv!row.mensaje)
                    },
                    pageSize: 10,
                    emptyGridMessage: "No hay errores recientes en el periodo."
                  )
                }
              )
            )
          )
        }
      ),
      /* 5 - Cuadro de Gestión (R56, solo consulta): argumentos cerrados en positivo o negativo que graba SCA2 CMD CompletarAccion en SCA2 Ejecucion Argumento */
      a!localVariables(
        local!fEje: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, filters: {
          a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{d0235378-9ca5-400b-91da-fb8ecca22a67}fecha', operator: "between", value: {local!ini, local!fin}),
          a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7f18836a-6382-44cb-88e9-e199c57b8b8d}lineaNegocio', operator: "=", value: if(a!isNullOrEmpty(local!fLinea), null, tointeger(local!fLinea)))
        }),
        local!nEje: a!defaultValue(index(index(a!queryRecordType(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n")), filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: {}), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)).data, 1, null), "n", null), 0),
        local!nPos: a!defaultValue(index(index(a!queryRecordType(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n")), filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{ac189f6c-5ce9-4138-a9af-73f02dc43ac6}resultado', operator: "=", value: "POSITIVO")), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)).data, 1, null), "n", null), 0),
        local!nEcoPos: a!defaultValue(index(index(a!queryRecordType(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n")), filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: {a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{ac189f6c-5ce9-4138-a9af-73f02dc43ac6}resultado', operator: "=", value: "POSITIVO"), a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{88836392-9228-43c3-8f79-ed440ebf00c9}mcaEconomico', operator: "=", value: "S")}), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)).data, 1, null), "n", null), 0),
        local!nEcoNeg: a!defaultValue(index(index(a!queryRecordType(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n")), filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: {a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{ac189f6c-5ce9-4138-a9af-73f02dc43ac6}resultado', operator: "=", value: "NEGATIVO"), a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{88836392-9228-43c3-8f79-ed440ebf00c9}mcaEconomico', operator: "=", value: "S")}), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)).data, 1, null), "n", null), 0),
        local!nReg: a!defaultValue(index(index(a!queryRecordType(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n")), filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{e04e2d7d-0d2e-43f7-b995-39cfbb95e273}mcaRegateable', operator: "=", value: "S")), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)).data, 1, null), "n", null), 0),
        local!nNoReg: a!defaultValue(index(index(a!queryRecordType(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', fields: a!aggregationFields(measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n")), filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{e04e2d7d-0d2e-43f7-b995-39cfbb95e273}mcaRegateable', operator: "=", value: "N")), pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)).data, 1, null), "n", null), 0),
        local!qTreLinea: a!queryRecordType(
          recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento',
          fields: a!aggregationFields(
            groupings: a!grouping(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7f18836a-6382-44cb-88e9-e199c57b8b8d}lineaNegocio', alias: "g"),
            measures: a!measure(function: "SUM", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{0bf2157c-4234-4ca1-b084-a1dc4fda6338}numTreboles', alias: "t")
          ),
          filters: local!fEje,
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 20)
        ).data,
        local!nTre: sum(a!forEach(items: local!qTreLinea, expression: a!defaultValue(tointeger(fv!item.t), 0))),
        local!fPoliza: null,
        local!kpisGes: {
          a!map(t: "Argumentos cerrados", v: local!nEje, d: "Positivos y negativos en el periodo", c: "#0D82BD"),
          a!map(t: "Positivos", v: local!nPos, d: if(local!nEje > 0, round(100 * local!nPos / local!nEje, 1) & " % de los cerrados", "Sin cierres"), c: "#00A651"),
          a!map(t: "Negativos", v: local!nEje - local!nPos, d: "Cliente no recuperado", c: "#DF0027"),
          a!map(t: "Económicos positivos", v: local!nEcoPos, d: "Argumento económico aceptado", c: "#6C3FB5"),
          a!map(t: "Económicos negativos", v: local!nEcoNeg, d: "Argumento económico no aceptado", c: "#FF8000"),
          a!map(t: "Tréboles aplicados", v: local!nTre, d: "En cierres positivos", c: "#00A3A3"),
          a!map(t: "Regateables", v: local!nReg, d: "Campañas comerciales (marca S del catálogo)", c: "#E5B700"),
          a!map(t: "No regateables", v: local!nNoReg, d: "Marca N del catálogo", c: "#7A4E2D"),
          a!map(t: "Sin marca regateable", v: local!nEje - local!nReg - local!nNoReg, d: "Argumento no encontrado en el catálogo", c: "#9F9F9F")
        },
        {
          a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: a!richTextItem(text: "Solo consulta. Cuenta los argumentos cerrados desde que se activó su registro en SCA2; las fechas se aplican a la fecha de cierre y el filtro de origen no se aplica. El histórico anterior está en CORE.", color: "SECONDARY", size: "SMALL")
          ),
          a!forEach(
            items: enumerate(ceiling(length(local!kpisGes) / 3)),
            expression: a!localVariables(
              local!fila: fv!item,
              a!columnsLayout(
                columns: a!forEach(
                  items: index(local!kpisGes, 3 * local!fila + enumerate(3) + 1, {}),
                  expression: a!columnLayout(contents: a!cardLayout(
                    contents: a!richTextDisplayField(
                      labelPosition: "COLLAPSED",
                      value: {
                        a!richTextItem(text: fv!item.t, color: "SECONDARY", size: "SMALL", style: "STRONG"),
                        char(10),
                        a!richTextItem(text: fv!item.v, size: "LARGE", style: "STRONG", color: fv!item.c),
                        char(10),
                        a!richTextItem(text: fv!item.d, color: "SECONDARY", size: "SMALL")
                      }
                    ),
                    height: "AUTO",
                    padding: "STANDARD",
                    decorativeBarPosition: "TOP",
                    decorativeBarColor: fv!item.c,
                    marginBelow: "STANDARD"
                  ))
                ),
                stackWhen: {"PHONE"}
              )
            )
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!barChartField(
                label: "Tréboles por línea de negocio",
                categories: a!forEach(items: local!qTreLinea, expression: a!defaultValue(index(cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE, wherecontains(tointeger(fv!item.g), tointeger(cons!SCA2_INT_ID_LINEA_NEGOCIO)), null), "Sin línea")),
                series: a!chartSeries(label: "Tréboles", data: a!forEach(items: local!qTreLinea, expression: a!defaultValue(tointeger(fv!item.t), 0)), color: "#00A3A3"),
                height: "MEDIUM"
              )),
              a!columnLayout(contents: a!barChartField(
                label: "Tréboles por tipo de argumento",
                data: a!recordData(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', filters: local!fEje),
                config: a!barChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{38db5010-03f3-4938-859c-2a779cef6e4b}descArg', alias: "arg"),
                  measures: a!measure(function: "SUM", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{0bf2157c-4234-4ca1-b084-a1dc4fda6338}numTreboles', alias: "t", label: "Tréboles"),
                  sort: a!sortInfo(field: "t", ascending: false),
                  dataLimit: 20
                ),
                height: "MEDIUM",
                colorScheme: "OCEAN"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT", "TABLET_LANDSCAPE"}
          ),
          a!columnChartField(
            label: "Positivos y tréboles por día",
            data: a!recordData(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', filters: a!queryLogicalExpression(operator: "AND", logicalExpressions: local!fEje, filters: a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{ac189f6c-5ce9-4138-a9af-73f02dc43ac6}resultado', operator: "=", value: "POSITIVO"))),
            config: a!columnChartConfig(
              primaryGrouping: a!grouping(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{d0235378-9ca5-400b-91da-fb8ecca22a67}fecha', interval: "DATE_SHORT_TEXT", alias: "dia"),
              measures: {
                a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n", label: "Positivos"),
                a!measure(function: "SUM", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{0bf2157c-4234-4ca1-b084-a1dc4fda6338}numTreboles', alias: "t", label: "Tréboles")
              },
              dataLimit: 500
            ),
            height: "MEDIUM",
            colorScheme: "OCEAN"
          ),
          a!columnsLayout(
            columns: {
              a!columnLayout(contents: a!pieChartField(
                label: "Económicos y no económicos",
                data: a!recordData(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', filters: local!fEje),
                config: a!pieChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{88836392-9228-43c3-8f79-ed440ebf00c9}mcaEconomico', alias: "eco"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n", label: "Argumentos")
                ),
                colorScheme: "OCEAN"
              )),
              a!columnLayout(contents: a!pieChartField(
                label: "Regateables y no regateables",
                data: a!recordData(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', filters: local!fEje),
                config: a!pieChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{e04e2d7d-0d2e-43f7-b995-39cfbb95e273}mcaRegateable', alias: "reg"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n", label: "Argumentos")
                ),
                colorScheme: "SUNSET"
              )),
              a!columnLayout(contents: a!pieChartField(
                label: "Positivos y negativos",
                data: a!recordData(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', filters: local!fEje),
                config: a!pieChartConfig(
                  primaryGrouping: a!grouping(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{ac189f6c-5ce9-4138-a9af-73f02dc43ac6}resultado', alias: "res"),
                  measures: a!measure(function: "COUNT", field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{7a4224f1-5e17-4461-8d81-a33a1149b8a3}id', alias: "n", label: "Argumentos")
                ),
                colorScheme: "PARACHUTE"
              ))
            },
            stackWhen: {"PHONE", "TABLET_PORTRAIT"}
          ),
          a!sectionLayout(
            label: "Argumentos por póliza",
            contents: {
              a!columnsLayout(columns: {
                a!columnLayout(contents: a!textField(label: "Póliza", placeholder: "Todas", value: local!fPoliza, saveInto: local!fPoliza, refreshAfter: "UNFOCUS")),
                a!columnLayout(contents: {}),
                a!columnLayout(contents: {})
              }, stackWhen: {"PHONE"}),
              a!gridField(
                labelPosition: "COLLAPSED",
                data: a!recordData(recordType: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento', filters: a!queryLogicalExpression(operator: "AND", ignoreFiltersWithEmptyValues: true, logicalExpressions: local!fEje, filters: a!queryFilter(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{20b39ade-728f-4cf4-9882-4410bc848395}numPoliza', operator: "=", value: local!fPoliza))),
                columns: {
                  a!gridColumn(label: "Fecha", sortField: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{d0235378-9ca5-400b-91da-fb8ecca22a67}fecha', value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{d0235378-9ca5-400b-91da-fb8ecca22a67}fecha']),
                  a!gridColumn(label: "Solicitud", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{516c0763-d747-4742-926d-0c750b3ed785}idSolicitud']),
                  a!gridColumn(label: "Póliza", sortField: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{20b39ade-728f-4cf4-9882-4410bc848395}numPoliza', value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{20b39ade-728f-4cf4-9882-4410bc848395}numPoliza']),
                  a!gridColumn(label: "Argumento", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{38db5010-03f3-4938-859c-2a779cef6e4b}descArg']),
                  a!gridColumn(label: "Campaña", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{061b7b9b-3fd3-4585-b34f-9d148aaf4c7a}codIdCampana']),
                  a!gridColumn(label: "Resultado", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{ac189f6c-5ce9-4138-a9af-73f02dc43ac6}resultado']),
                  a!gridColumn(label: "Económico", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{88836392-9228-43c3-8f79-ed440ebf00c9}mcaEconomico'], align: "CENTER"),
                  a!gridColumn(label: "Regateable", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{e04e2d7d-0d2e-43f7-b995-39cfbb95e273}mcaRegateable'], align: "CENTER"),
                  a!gridColumn(label: "Tréboles", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{0bf2157c-4234-4ca1-b084-a1dc4fda6338}numTreboles'], align: "END"),
                  a!gridColumn(label: "Usuario", value: fv!row['recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{9e55f98f-43ab-4cd9-8684-cf3a5b2e84f3}usuario'])
                },
                initialSorts: a!sortInfo(field: 'recordType!{22e52e08-b3bd-4770-9905-28b281f5e57b}SCA2 Ejecucion Argumento.fields.{d0235378-9ca5-400b-91da-fb8ecca22a67}fecha', ascending: false),
                pageSize: 10,
                emptyGridMessage: "No hay argumentos cerrados en el periodo."
              )
            }
          )
        }
      )
    )
  }
)
