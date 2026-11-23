a!localVariables(
  local!solicitud: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
  local!estado: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
  local!nodo: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{3f50e032-f5da-44d7-837c-29ed11f7064b}nodoRelanzar',
  local!fechaAlta: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
  local!fechaCambio: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt',
  local!linea: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio',
  local!origen: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{9d6f5168-2056-4295-957e-68ad26d6a2b9}origenPoliza',
  local!id: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
  local!poliza: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
  local!filtros: a!queryLogicalExpression(
    operator: "AND",
    filters: {
      a!queryFilter(field: local!estado, operator: "=", value: "ERROR"),
      /* Finalizar registra este marcador también si el fallo es de SGC o de escritura local. */
      a!queryFilter(field: local!nodo, operator: "=", value: "Finalizar PCA"),
      a!queryFilter(field: local!fechaAlta, operator: ">=", value: ri!desde, applyWhen: a!isNotNullOrEmpty(ri!desde)),
      a!queryFilter(field: local!fechaAlta, operator: "<=", value: ri!hasta, applyWhen: a!isNotNullOrEmpty(ri!hasta)),
      a!queryFilter(field: local!linea, operator: "=", value: ri!lineaNegocio, applyWhen: a!isNotNullOrEmpty(ri!lineaNegocio)),
      a!queryFilter(field: local!origen, operator: "=", value: ri!origenPoliza, applyWhen: a!isNotNullOrEmpty(ri!origenPoliza))
    }
  ),
  local!total: a!queryRecordType(
    recordType: local!solicitud,
    filters: local!filtros,
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
    fetchTotalCount: true
  ).totalCount,
  a!sectionLayout(
    label: "Solicitudes con finalización fallida (" & local!total & ")",
    contents: {
      a!gridField(
        label: "Solicitudes que siguen sin finalizar tras un fallo",
        emptyGridMessage: "No hay solicitudes con finalización fallida para estos filtros.",
        data: a!recordData(
          recordType: local!solicitud,
          filters: local!filtros
        ),
        columns: {
          a!gridColumn(label: "Solicitud", value: fv!row[local!id], sortField: local!id),
          a!gridColumn(label: "Póliza", value: fv!row[local!poliza], sortField: local!poliza),
          a!gridColumn(label: "Último cambio", value: fv!row[local!fechaCambio], sortField: local!fechaCambio)
        },
        initialSorts: {
          a!sortInfo(field: local!fechaCambio, ascending: false),
          a!sortInfo(field: local!id, ascending: true)
        },
        pageSize: 10,
        showSearchBox: false,
        showRefreshButton: false
      )
    }
  )
)
