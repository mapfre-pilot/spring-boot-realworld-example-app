if(
  or(a!isNullOrEmpty(ri!idSolicitud), a!isNullOrEmpty(ri!numGestion), not(contains({"ACCADM", "AUT"}, tostring(ri!tipoGestion)))),
  null,
  index(
    a!queryRecordType(
      recordType: 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa',
      fields: {
        'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{51a8336b-ce3f-4162-a585-f657e2595891}id',
        'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{a903da73-4a73-451f-9c0e-7a8162b6efeb}idDocumentoAppian',
        'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{b8c3124e-242c-4776-a5c6-8569aa918253}fechaEntrega'
      },
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{8003fe4b-d36d-48eb-a10b-7aa33a06adde}idSolicitud', operator: "=", value: ri!idSolicitud),
          a!queryFilter(field: 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{c79a8446-3960-4404-b6c0-25ade0130dc7}tipoGestion', operator: "=", value: ri!tipoGestion),
          a!queryFilter(field: 'recordType!{a2953258-c308-418f-b5b3-1b3fd024ad92}SCA2 Adjunto Compraventa.fields.{45de9ab8-44e7-4fa9-9648-257d82412cdc}numGestion', operator: "=", value: ri!numGestion)
        }
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
    ).data,
    1,
    null
  )
)
