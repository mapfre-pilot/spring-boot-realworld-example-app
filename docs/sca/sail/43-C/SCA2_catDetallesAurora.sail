/* [SCA2] Lectura del catálogo de DETALLES desde Aurora (record SCA2 Cat Detalle) con la misma salida que SCA2_consultarDetalleCore (consultarDetalleResponse).
   Filtra como CORE: línea de negocio + motivo; solo filas activas; orden = orden CORE. Devuelve NULL si no hay filas (fallback a la SOAP). Fase 1, sesión C. */
a!localVariables(
  local!filas: if(
    or(a!isNullOrEmpty(ri!codLineaNegocio), a!isNullOrEmpty(ri!codMotivo)),
    {},
    a!queryRecordType(
      recordType: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle',
      fields: {'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d980d776-17d4-4236-8724-5612547ac669}fechaAlta', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{488228af-08b5-4df1-a7fd-0a8f08947f3b}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio', operator: "=", value: tointeger(ri!codLineaNegocio)),
          a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', operator: "=", value: tostring(ri!codMotivo))
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden', ascending: true), a!sortInfo(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id', ascending: true)}),
      fetchTotalCount: false
    ).data
  ),
  if(
    a!isNullOrEmpty(local!filas),
    null,
    'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarDetalleResponse'(
      MSSConsultarDetalle: a!forEach(
        items: local!filas,
        expression: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}tipoElementoBasicoDTO'(codigo: fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle'], descripcion: fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion'])
      )
    )
  )
)