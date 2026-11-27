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
        a!defaultValue(index(local!previo, 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{a903da73-4a73-451f-9c0e-7a8162b6efeb}idDocumentoAppian', null), 0) = local!doc,
        {},
        'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa'(
          'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{51a8336b-ce3f-4162-a585-f657e2595891}id': index(local!previo, 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{51a8336b-ce3f-4162-a585-f657e2595891}id', null),
          'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{8003fe4b-d36d-48eb-a10b-7aa33a06adde}idSolicitud': ri!idSolicitud,
          'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{c79a8446-3960-4404-b6c0-25ade0130dc7}tipoGestion': local!tipo,
          'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{45de9ab8-44e7-4fa9-9648-257d82412cdc}numGestion': local!gestion,
          'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{a903da73-4a73-451f-9c0e-7a8162b6efeb}idDocumentoAppian': local!doc,
          'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{b8c3124e-242c-4776-a5c6-8569aa918253}fechaEntrega': ri!fechaEntrega
        )
      )
    )
  )
)
