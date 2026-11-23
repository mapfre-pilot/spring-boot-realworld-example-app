a!localVariables(
  local!ids: union(
    touniformstring(a!defaultValue(ri!idsSolicitud, {})),
    touniformstring(a!defaultValue(ri!idsSolicitud, {}))
  ),
  local!retenidas: touniformstring(a!defaultValue(ri!idsRetenidos, {})),
  local!evaluados: touniformstring(a!defaultValue(index(ri!reintentos, "evaluados", {}), {})),
  local!reintentosBloqueados: touniformstring(a!defaultValue(index(ri!reintentos, "bloqueados", {}), {})),
  if(
    or(
      a!isNullOrEmpty(local!ids),
      a!isNullOrEmpty(ri!reporteProcesos),
      a!isNullOrEmpty(ri!modelosProcesos),
      count(local!retenidas) <> 34,
      count(union(local!retenidas, local!retenidas)) <> 34,
      contains(local!retenidas, ""),
      a!isNullOrEmpty(index(ri!reintentos, "evaluados", null)),
      not(contains(a!keys(ri!reintentos), "bloqueados")),
      a!isNotNullOrEmpty(difference(local!ids, local!evaluados)),
      a!isNotNullOrEmpty(difference(local!evaluados, local!ids)),
      a!isNotNullOrEmpty(difference(local!reintentosBloqueados, local!evaluados))
    ),
    {},
    a!localVariables(
      local!informe: a!queryProcessAnalytics(
        report: ri!reporteProcesos,
        contextProcessModels: ri!modelosProcesos,
        query: a!query(
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 500)
        )
      ),
      local!columnas: index(local!informe, "columnConfigs", {}),
      local!campos: index(local!columnas, "field", {}),
      local!columnasId: wherecontains("ID solicitud para archivo", touniformstring(index(local!columnas, "label", {}))),
      local!campoId: index(local!campos, index(local!columnasId, 1, 0), ""),
      local!filas: a!defaultValue(index(local!informe, "data", {}), {}),
      local!estados: a!forEach(
        items: local!filas,
        expression: a!defaultValue(tointeger(index(fv!item, "c1", null)), -1)
      ),
      local!indicesActivos: wherecontains({0, 3, 4}, tointeger(local!estados)),
      local!filasActivas: if(a!isNullOrEmpty(local!indicesActivos), {}, index(local!filas, local!indicesActivos, {})),
      local!procesosBloqueados: touniformstring(a!forEach(
        items: local!filasActivas,
        expression: tostring(index(fv!item, local!campoId, ""))
      )),
      if(
        or(
          a!isNotNullOrEmpty(index(local!informe, "errorMessage", null)),
          not(contains(touniformstring(local!campos), "c1")),
          count(local!columnasId) <> 1,
          a!isNullOrEmpty(local!campoId),
          a!defaultValue(index(local!informe, "totalCount", null), -1) <> count(local!filas),
          count(local!filas) >= 500,
          or(a!forEach(
            items: local!estados,
            expression: not(contains({0, 1, 2, 3, 4}, tointeger(fv!item)))
          )),
          contains(local!procesosBloqueados, ""),
          contains(local!procesosBloqueados, "0"),
          or(a!forEach(
            items: local!filasActivas,
            expression: or(
              count(index(fv!item, local!campoId, {})) <> 1,
              tostring(index(fv!item, local!campoId, "")) <> trim(tostring(index(fv!item, local!campoId, "")))
            )
          ))
        ),
        {},
        difference(local!ids, union(union(local!retenidas, local!reintentosBloqueados), local!procesosBloqueados))
      )
    )
  )
)
