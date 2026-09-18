/* POST /smoke_runs  body: {"codigos":[], "categorias":[], "sistemas":[], "motivo":"...", "origen":"CI|INSTALACION|INTERVENCION|..."}
   Lanza SMK Ejecutar Pruebas y devuelve el id de la SMK Ejecucion creada (202 Accepted). */
a!localVariables(
  local!body: if(a!isNullOrEmpty(index(http!request, "body", "")), a!map(), a!fromJson(index(http!request, "body", ""))),
  local!codigos: touniformstring(a!flatten({index(local!body, "codigos", {})})),
  local!categorias: touniformstring(a!flatten({index(local!body, "categorias", {})})),
  local!sistemas: touniformstring(a!flatten({index(local!body, "sistemas", {})})),
  a!startProcess(
    processModel: cons!SMK_PM_EJECUTAR_PRUEBAS,
    processParameters: a!map(
      codigos: if(a!isNullOrEmpty(local!codigos), null, local!codigos),
      categorias: if(a!isNullOrEmpty(local!categorias), null, local!categorias),
      sistemas: if(a!isNullOrEmpty(local!sistemas), null, local!sistemas),
      motivo: left(a!defaultValue(index(local!body, "motivo", null), "Lanzado por Web API"), 4000),
      origen: left(a!defaultValue(index(local!body, "origen", null), "API"), 100),
      lanzadoPor: loggedInUser()
    ),
    onSuccess: a!httpResponse(
      statusCode: 202,
      headers: { a!httpHeader(name: "Content-Type", value: "application/json") },
      body: a!toJson(a!map(
        ejecucionId: fv!processInfo.pv.ejecucionId,
        processId: fv!processInfo.pp.id,
        totalPruebas: fv!processInfo.pv.esperadas,
        estado: "EN_CURSO",
        estadoUrl: "/suite/webapi/smoke_run?id=" & fv!processInfo.pv.ejecucionId,
        resultadosUrl: "/suite/webapi/smoke_run_results?id=" & fv!processInfo.pv.ejecucionId
      ))
    ),
    onError: a!httpResponse(
      statusCode: 500,
      headers: { a!httpHeader(name: "Content-Type", value: "application/json") },
      body: a!toJson(a!map(error: "No se pudo iniciar el runner de pruebas de humo"))
    )
  )
)
