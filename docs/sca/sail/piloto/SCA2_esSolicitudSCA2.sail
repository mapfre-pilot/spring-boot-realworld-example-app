/* Indica si la solicitud ya pertenece a SCA2 y debe abrirse en SCA2 para cualquier usuario.
   - Con idSolicitud: true si esa solicitud existe en SCA2 Solicitud (cualquier estado).
   - Sólo con numPoliza: true si la póliza tiene en SCA2 alguna solicitud no cerrada
     (cerradas: finalizadas, caducadas y canceladas). */
a!localVariables(
  local!estadosCerrados: {
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA,
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ,
    cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR,
    cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
    cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA,
    "CANCELADA"
  },
  if(
    a!isNotNullOrEmpty(ri!idSolicitud),
    a!queryRecordType(
      recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
      fields: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
      filters: a!queryFilter(
        field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
        operator: "=",
        value: trim(ri!idSolicitud)
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
      fetchTotalCount: true
    ).totalCount > 0,
    if(
      a!isNotNullOrEmpty(ri!numPoliza),
      a!queryRecordType(
        recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
        fields: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{11313fc1-239e-4e39-9a00-d8494bcd63c2}id',
        filters: a!queryLogicalExpression(
          operator: "AND",
          filters: {
            a!queryFilter(
              field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
              operator: "=",
              value: trim(ri!numPoliza)
            )
          },
          logicalExpressions: a!queryLogicalExpression(
            operator: "OR",
            filters: {
              a!queryFilter(
                field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
                operator: "not in",
                value: local!estadosCerrados
              ),
              a!queryFilter(
                field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
                operator: "is null"
              )
            }
          )
        ),
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
        fetchTotalCount: true
      ).totalCount > 0,
      false
    )
  )
)
