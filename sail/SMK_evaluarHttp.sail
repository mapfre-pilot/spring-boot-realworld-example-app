/* Convierte el resultado de una integración HTTP de conectividad (fv!result/success/error)
   en el contrato común de smoke test: {resultado, mensaje, detalle}. */
a!localVariables(
  local!ok: a!defaultValue(ri!res.success, false),
  local!status: if(local!ok, tointeger(a!defaultValue(ri!res.result.statusCode, 0)), 0),
  if(
    or(
      not(local!ok),
      local!status <= 0
    ),
    a!map(
      resultado: "KO",
      mensaje: left(
        if(
          local!ok,
          "Sin respuesta HTTP del host: No se recibió código de estado HTTP",
          a!defaultValue(ri!res.error.title, "Error de conexión") & ": " & a!defaultValue(ri!res.error.message, "")
        ),
        3900
      ),
      detalle: left(tostring(a!defaultValue(ri!res.error.detail, "")), 20000)
    ),
    a!map(
      resultado: "OK",
      mensaje: "Host alcanzable (HTTP " & local!status & ")",
      detalle: a!defaultValue(ri!res.result.statusLine, "")
    )
  )
)
