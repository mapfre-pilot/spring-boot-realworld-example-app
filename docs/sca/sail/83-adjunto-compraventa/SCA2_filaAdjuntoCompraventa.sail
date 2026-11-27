a!localVariables(
  local!adjunto: rule!SCA2_consultarAdjuntosCompraventa(
    idSolicitud: ri!idSolicitud,
    tipoGestion: ri!tipoGestion,
    numGestion: ri!numGestion
  ),
  if(
    a!isNullOrEmpty(local!adjunto),
    {},
    a!map(
      tipoDocumento: "9",
      idDocumento: tostring(index(local!adjunto, 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{a903da73-4a73-451f-9c0e-7a8162b6efeb}idDocumentoAppian', null)),
      fechaDocumento: text(index(local!adjunto, 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{b8c3124e-242c-4776-a5c6-8569aa918253}fechaEntrega', null), "dd/MM/yyyy"),
      origenAppian: true
    )
  )
)
