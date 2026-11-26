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
      idDocumento: tostring(index(local!adjunto, 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{DOCUMENTO}idDocumentoAppian', null)),
      fechaDocumento: text(index(local!adjunto, 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{FECHA}fechaEntrega', null), "dd/MM/yyyy"),
      origenAppian: true
    )
  )
)
