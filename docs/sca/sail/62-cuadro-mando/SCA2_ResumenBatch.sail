a!localVariables(
  local!ejecuciones: a!queryProcessAnalytics(
    report: cons!SCA2_DOC_EJECUCIONES_BATCH,
    contextProcessModels: {
      cons!SCA2_PM_BATCH_MECANIZACION_NSE,
      cons!SCA2_PM_BATCH_RESERVA_PRIMA
    },
    query: a!query(
      pagingInfo: a!pagingInfo(
        startIndex: 1,
        batchSize: 25,
        sort: a!sortInfo(field: "c2", ascending: false)
      )
    )
  ),
  {
    a!richTextDisplayField(
      value: a!richTextItem(
        text: "Solo consulta. Este resumen no permite lanzar procesos.",
        color: "SECONDARY"
      )
    ),
    a!richTextDisplayField(
      value: {
        a!richTextItem(text: "Mecanización NSE: ", style: "STRONG"),
        if(cons!SCA2_BOOL_BATCH_NSE, "Habilitado", "Desactivado"),
        char(10),
        a!richTextItem(text: "Reserva Prima SCA2: ", style: "STRONG"),
        if(cons!SCA2_BOOL_BATCH_RESERVA_PRIMA, "Habilitado", "Desactivado; la ejecución y el volcado siguen en SCA")
      }
    ),
    if(
      a!isNotNullOrEmpty(local!ejecuciones.errorMessage),
      a!richTextDisplayField(
        value: a!richTextItem(
          text: "No se pudieron consultar las ejecuciones de Batch.",
          color: "NEGATIVE"
        )
      ),
      a!gridField(
        label: "Últimas ejecuciones de SCA2",
        instructions: "Hasta 25 ejecuciones visibles en Appian. El estado corresponde al proceso batch, no al resultado de cada solicitud.",
        emptyGridMessage: "No hay ejecuciones visibles para estos modelos.",
        data: local!ejecuciones.data,
        columns: {
          a!gridColumn(label: "Proceso", value: index(fv!row, "c0", null)),
          a!gridColumn(
            label: "Estado",
            value: a!localVariables(
              local!estado: tointeger(index(fv!row, "c1", null)),
              a!match(
                value: local!estado,
                equals: 0, then: "Activo",
                equals: 1, then: "Completado",
                equals: 2, then: "Cancelado",
                equals: 3, then: "En pausa",
                equals: 4, then: "En pausa por error",
                default: if(a!isNullOrEmpty(local!estado), "—", "Código " & local!estado)
              )
            )
          ),
          a!gridColumn(label: "Inicio", value: index(fv!row, "c2", null)),
          a!gridColumn(label: "Fin", value: index(fv!row, "c3", null)),
          a!gridColumn(label: "ID de proceso", value: index(fv!row, "c4", null))
        }
      )
    )
  }
)
