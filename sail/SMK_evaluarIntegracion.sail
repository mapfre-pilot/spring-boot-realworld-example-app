if(
  a!defaultValue(ri!res.success, false),
  a!map(
    resultado: "OK",
    mensaje: a!defaultValue(ri!mensajeOk, "Integración ejecutada correctamente"),
    detalle: left(a!defaultValue(ri!detalleOk, ""), 20000)
  ),
  a!map(
    resultado: "KO",
    mensaje: left(a!defaultValue(ri!res.error.title, "Error de integración") & ": " & a!defaultValue(ri!res.error.message, ""), 3900),
    detalle: left(tostring(a!defaultValue(ri!res.error.detail, "")), 20000)
  )
)
