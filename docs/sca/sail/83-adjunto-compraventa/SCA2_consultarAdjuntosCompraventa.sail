if(
  or(a!isNullOrEmpty(ri!idSolicitud), a!isNullOrEmpty(ri!numGestion), not(contains({"ACCADM", "AUT"}, tostring(ri!tipoGestion)))),
  null,
  index(
    a!queryRecordType(
      recordType: 'recordType!{RT}SCA2 Adjunto Compraventa',
      fields: {
        'recordType!{RT}SCA2 Adjunto Compraventa.fields.{ID}id',
        'recordType!{RT}SCA2 Adjunto Compraventa.fields.{DOCUMENTO}idDocumentoAppian',
        'recordType!{RT}SCA2 Adjunto Compraventa.fields.{FECHA}fechaEntrega'
      },
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{SOLICITUD}idSolicitud', operator: "=", value: ri!idSolicitud),
          a!queryFilter(field: 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{TIPO}tipoGestion', operator: "=", value: ri!tipoGestion),
          a!queryFilter(field: 'recordType!{RT}SCA2 Adjunto Compraventa.fields.{GESTION}numGestion', operator: "=", value: ri!numGestion)
        }
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1)
    ).data,
    1,
    null
  )
)
