/* Construye el registro SMK Resultado de una prueba a partir del contrato {resultado, mensaje, detalle}
   devuelto por SMK_ejecutarPrueba, aplicando el umbral de latencia (OK -> WARN si se supera). */
a!localVariables(
  local!duracion: tointeger(todecimal(ri!fechaFin - ri!fechaInicio) * 86400000),
  local!res: a!defaultValue(ri!res, a!map(resultado: "KO", mensaje: "La prueba no devolvió resultado", detalle: "")),
  local!resultado: a!defaultValue(local!res.resultado, "KO"),
  local!superaUmbral: and(
    local!resultado = "OK",
    a!isNotNullOrEmpty(ri!umbralMs),
    ri!umbralMs > 0,
    local!duracion > ri!umbralMs
  ),
  'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado'(
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{07788adb-63de-481c-9f2d-3723a9a63d4e}ejecucionId': ri!ejecucionId,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{4f718430-38ea-4337-972b-113c6c8d186b}testCodigo': ri!testCodigo,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{09690489-a838-47b8-b2a3-6d79bf0f12b1}testNombre': ri!testNombre,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{59e09557-6cf0-4346-9da8-fea279aba42a}categoria': ri!categoria,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{aa8ec9d3-cba2-488e-85a2-f8dc716427a5}sistema': ri!sistema,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{8bbe1e8e-1859-4ec0-b2ee-3f270d34c902}resultado': if(local!superaUmbral, "WARN", local!resultado),
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{e14cacb4-f42c-448a-a784-a4d0d392bf2a}mensaje': left(
      if(
        local!superaUmbral,
        "Latencia " & local!duracion & " ms supera el umbral de " & ri!umbralMs & " ms. " & a!defaultValue(local!res.mensaje, ""),
        a!defaultValue(local!res.mensaje, "")
      ),
      4000
    ),
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{089c041c-624d-4ce5-96ab-df18c74e5671}detalle': tostring(a!defaultValue(local!res.detalle, "")),
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{27d05113-c572-4037-b5a4-adc767e053be}duracionMs': local!duracion,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{dc44be34-fe85-4b8a-9c9b-e7817b3676c9}fechaInicio': ri!fechaInicio,
    'recordType!{bf6adbc0-a010-4ed4-8868-ec70acc74366}SMK Resultado.fields.{ec728354-513b-47e3-9655-9a93e291654f}fechaFin': ri!fechaFin
  )
)
