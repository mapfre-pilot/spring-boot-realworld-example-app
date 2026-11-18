/* [SCA2] Lectura del catálogo de TIPOS DE ARGUMENTO desde Aurora (record SCA2 Cat Tipo Argumento) con la misma salida que SCA2_consultarTipoArgCore (consultarTipoArgResponse / detalleTpArgDTO).
   Replica el filtro de CORE sobre mseConsultarTipoArgDTO: desc obligatorio («contiene», sin mayúsculas; % = comodín), codEstado y idLineaNegocio por igualdad,
   fechaMod (dd/MM/yyyy) → fecModificado con fecha >= fechaMod (comprobado contra CORE: devuelve lo modificado desde esa fecha). fecModificado se guarda como texto, por eso se filtra en SAIL.
   Sin desc → MSSConsultarTipoArg vacío (como CORE). Devuelve NULL si no hay filas (fallback a la SOAP). Fase 1, sesión C. */
a!localVariables(
  local!desc: tostring(a!defaultValue(index(ri!mseConsultarTipoArgDTO, "desc", ""), "")),
  local!descSinComodin: trim(substitute(local!desc, "%", "")),
  local!codEstado: tostring(a!defaultValue(index(ri!mseConsultarTipoArgDTO, "codEstado", ""), "")),
  local!idLineaNegocio: tostring(a!defaultValue(index(ri!mseConsultarTipoArgDTO, "idLineaNegocio", ""), "")),
  local!fechaMod: tostring(a!defaultValue(index(ri!mseConsultarTipoArgDTO, "fechaMod", ""), "")),
  local!filas: if(
    a!isNullOrEmpty(local!desc),
    {},
    a!queryRecordType(
      recordType: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento',
      fields: {'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f7c00942-fcb3-4a18-b2c2-9d77b20b862c}numDiasSgo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2e399b24-37fe-4988-a915-3d73b41b9dfd}fechaAlta', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{35086732-fb4d-4e6d-a8e0-9a24dd8ac457}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg', operator: "includes", value: local!descSinComodin, applyWhen: a!isNotNullOrEmpty(local!descSinComodin)),
          a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado', operator: "=", value: local!codEstado, applyWhen: a!isNotNullOrEmpty(local!codEstado)),
          a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio', operator: "=", value: local!idLineaNegocio, applyWhen: a!isNotNullOrEmpty(local!idLineaNegocio))
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden', ascending: true), a!sortInfo(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id', ascending: true)}),
      fetchTotalCount: false
    ).data
  ),
  local!fechaValida: and(len(local!fechaMod) >= 10, mid(local!fechaMod, 3, 1) = "/", mid(local!fechaMod, 6, 1) = "/"),
  local!fechaDesde: if(local!fechaValida, date(tointeger(mid(local!fechaMod, 7, 4)), tointeger(mid(local!fechaMod, 4, 2)), tointeger(left(local!fechaMod, 2))), null),
  /* fechaMod informada pero no dd/MM/yyyy → CORE no devuelve nada */
  local!filasFecha: if(
    and(a!isNotNullOrEmpty(local!fechaMod), not(local!fechaValida)),
    {},
    if(
    or(a!isNullOrEmpty(local!fechaDesde), a!isNullOrEmpty(local!filas)),
    local!filas,
    index(
      local!filas,
      where(a!forEach(
        items: local!filas,
        expression: a!localVariables(
          local!f: tostring(a!defaultValue(fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado'], "")),
          and(len(local!f) >= 10, date(tointeger(mid(local!f, 7, 4)), tointeger(mid(local!f, 4, 2)), tointeger(left(local!f, 2))) >= local!fechaDesde)
        )
      )),
      {}
    )
    )
  ),
  if(
    a!isNullOrEmpty(local!desc),
    'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarTipoArgResponse'(MSSConsultarTipoArg: null),
    if(
      a!isNullOrEmpty(local!filasFecha),
      null,
      'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarTipoArgResponse'(
        MSSConsultarTipoArg: a!forEach(
          items: local!filasFecha,
          expression: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}detalleTpArgDTO'(
            apliArgumento: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento'], codCompania: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania'], codEstado: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado'], codTpArg: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg'], descArg: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg'], fecModificado: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado'], fecVigencia: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia'], idLineaNegocio: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio'], idRamo: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo'], instruccion: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion'], mcaFinalizado: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado'], nombreDoc: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc'], numDoc: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc'], observaciones: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones'], codIdCampana: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana'], codTipBon: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon'], numTipBon: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon'], regateable: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable'], mcaTeCuidamos: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos'], numDiasSgo: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f7c00942-fcb3-4a18-b2c2-9d77b20b862c}numDiasSgo'], codTareaSgo: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo'], codCompaniaArg: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg'], txtUrlArg: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg'], mcaTrebCalc: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc']
          )
        )
      )
    )
  )
)