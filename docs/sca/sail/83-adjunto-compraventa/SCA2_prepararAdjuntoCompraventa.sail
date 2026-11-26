a!localVariables(
  local!tipo: tostring(index(ri!resultado, "tipoGestion", null)),
  local!gestion: tostring(index(ri!resultado, "codGestion", null)),
  local!adjuntos: reject(
    fn!isnull,
    a!forEach(
      items: a!defaultValue(index(ri!docsResult, "resultados", null), {}),
      expression: if(
        and(
          tostring(index(fv!item, "tipoDocumento", null)) = "9",
          a!defaultValue(index(fv!item, "omitido", false), false)
        ),
        tointeger(index(fv!item, "idDoc", null)),
        null
      )
    )
  ),
  if(
    or(
      not(contains({"ACCADM", "AUT"}, local!tipo)),
      and(local!tipo = "ACCADM", tostring(index(ri!resultado, "mcaEstadoFinal", null)) <> "FINALIZADA"),
      and(local!tipo = "AUT", tostring(index(ri!resultado, "codEstado", null)) <> "2"),
      a!isNullOrEmpty(local!adjuntos)
    ),
    {},
    a!localVariables(
      local!doc: index(local!adjuntos, length(local!adjuntos), null),
      local!previo: rule!SCA2_consultarAdjuntosCompraventa(
        idSolicitud: ri!idSolicitud,
        tipoGestion: local!tipo,
        numGestion: local!gestion
      ),
      if(
        a!defaultValue(index(local!previo, 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{DOCUMENTO}idDocumentoAppian', null), 0) = local!doc,
        {},
        'recordType!{RT}SCA2 Adjunto Compraventa'(
          'recordType!{RT}SCA2 Adjunto Compraventa.fields.{ID}id': index(local!previo, 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{ID}id', null),
          'recordType!{RT}SCA2 Adjunto Compraventa.fields.{SOLICITUD}idSolicitud': ri!idSolicitud,
          'recordType!{RT}SCA2 Adjunto Compraventa.fields.{TIPO}tipoGestion': local!tipo,
          'recordType!{RT}SCA2 Adjunto Compraventa.fields.{GESTION}numGestion': local!gestion,
          'recordType!{RT}SCA2 Adjunto Compraventa.fields.{DOCUMENTO}idDocumentoAppian': local!doc,
          'recordType!{RT}SCA2 Adjunto Compraventa.fields.{FECHA}fechaEntrega': ri!fechaEntrega
        )
      )
    )
  )
)
