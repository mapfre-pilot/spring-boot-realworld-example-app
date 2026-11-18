/* [SCA2] Lectura del catálogo de MOTIVOS desde Aurora (record SCA2 Cat Motivo) con la misma salida que SCA2_consultarMotivoCore (consultarMotivoResponse).
   Filtra como CORE: línea de negocio + pareja (codPerfil, codSubPerfil) del infoUsuarioDTO; solo filas activas; orden = orden CORE.
   Devuelve NULL si no hay filas (el llamador hace fallback a la SOAP). Fase 1, sesión C. */
a!localVariables(
  local!perfil: tostring(a!defaultValue(index(ri!infoUsuarioDTO, "codPerfil", ""), "")),
  local!subPerfil: tostring(a!defaultValue(index(ri!infoUsuarioDTO, "codSubPerfil", ""), "")),
  local!filas: if(
    or(a!isNullOrEmpty(ri!codLineaNegocio), a!isNullOrEmpty(local!perfil), a!isNullOrEmpty(local!subPerfil)),
    {},
    a!queryRecordType(
      recordType: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo',
      fields: {'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{903c3810-4491-4d87-9fe6-4b40a22a1bb3}fechaAlta', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{90f6ec37-4193-4e82-8012-b8d2e5b5a18e}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio', operator: "=", value: tointeger(ri!codLineaNegocio)),
          a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil', operator: "=", value: local!perfil),
          a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil', operator: "=", value: local!subPerfil)
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden', ascending: true), a!sortInfo(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id', ascending: true)}),
      fetchTotalCount: false
    ).data
  ),
  if(
    a!isNullOrEmpty(local!filas),
    null,
    'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarMotivoResponse'(
      MSSConsultarMotivo: a!forEach(
        items: local!filas,
        expression: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}tipoElementoBasicoDTO'(codigo: fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo'], descripcion: fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion'])
      )
    )
  )
)