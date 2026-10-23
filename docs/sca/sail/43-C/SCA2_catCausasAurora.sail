/* [SCA2] Lectura del catálogo de CAUSAS desde Aurora (record SCA2 Cat Causa) con la misma salida que SCA2_consultarCausaCore (consultarCausaResponse).
   Filtra como CORE: línea de negocio + motivo + detalle + perfil; solo filas activas; orden = orden CORE.
   Aplica la misma ocultación que SCA2_consultarCausa para perfiles SI24 (causas 13,14,16,17,18,28,31,32). Devuelve NULL si no hay filas (fallback a la SOAP). Fase 1, sesión C. */
a!localVariables(
  local!filas: if(
    or(a!isNullOrEmpty(ri!codLineaNegocio), a!isNullOrEmpty(ri!codMotivo), a!isNullOrEmpty(ri!codDetalle), a!isNullOrEmpty(ri!codPerfil)),
    {},
    a!queryRecordType(
      recordType: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa',
      fields: {'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ae77f839-09fa-4aa5-9142-5dc00942c6dc}fechaAlta', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{045605ef-fabe-4f9a-b819-6b4d412ba81d}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio', operator: "=", value: tointeger(ri!codLineaNegocio)),
          a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo', operator: "=", value: tostring(ri!codMotivo)),
          a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle', operator: "=", value: tostring(ri!codDetalle)),
          a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil', operator: "=", value: tostring(ri!codPerfil))
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden', ascending: true), a!sortInfo(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id', ascending: true)}),
      fetchTotalCount: false
    ).data
  ),
  local!esSi24: rule!SCA2_datosPerfilesPcaSi24(codPerfil: a!defaultValue(ri!codPerfil, ""), codSubPerfil: a!defaultValue(ri!codPerfil, "")),
  local!causasOcultasSi24: {"13", "14", "16", "17", "18", "28", "31", "32"},
  local!visibles: if(
    local!esSi24,
    index(local!filas, where(a!forEach(items: local!filas, expression: not(contains(local!causasOcultasSi24, tostring(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa']))))), {}),
    local!filas
  ),
  if(
    a!isNullOrEmpty(local!filas),
    null,
    'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarCausaResponse'(
      MSSConsultarCausa: a!forEach(
        items: local!visibles,
        expression: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}tipoElementoBasicoDTO'(codigo: fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa'], descripcion: fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion'])
      )
    )
  )
)