/* [SCA2] Construye las filas a escribir (upsert) en el record SCA2 Cat <catálogo> a partir de CORE (reglas SCA2_consultar*Core).
   ri!catalogo: MOTIVO | DETALLE | CAUSA | TIPO_ARGUMENTO | CONCEPTO | VALOR_CONCEPTO (CAUSA se construye a partir de los detalles ya cargados en Aurora: cargar antes DETALLE).
   Reglas: clave natural CORE → insert o update; filas con origen MANUAL no se tocan; filas CORE que CORE ya no devuelve → activo=false (solo si CORE ha respondido).
   No escribe nada: devuelve a!map(catalogo, filasCore, existentesAntes, manualesRespetadas, bajas, registros). Escribe SCA2_catCargarDesdeCore. */
a!localVariables(
  local!p: rule!SCA2_catParametrosCarga(),
  a!match(
    value: upper(a!defaultValue(ri!catalogo, "")),
    equals: "MOTIVO",
    then: a!localVariables(
      local!usuario: user(loggedInUser(), "username"),
      local!core: a!flatten(
        a!forEach(
          items: local!p.perfiles,
          expression: a!localVariables(
            local!perfil: fv!item,
            a!forEach(
              items: local!p.lineasNegocio,
              expression: a!localVariables(
                local!ln: fv!item,
                a!forEach(
                  items: a!defaultValue(index(rule!SCA2_consultarMotivoCore(infoUsuarioDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}infoUsuarioDTO'(codCiaUsuario: local!p.codCiaUsuario, nuuma: local!p.infoUsuario.nuuma, codPerfil: local!perfil.codPerfil, codSubPerfil: local!perfil.codSubPerfil), codLineaNegocio: local!ln), "MSSConsultarMotivo", {}), {}),
                  expression: a!map(codLineaNegocio: local!ln, codPerfil: local!perfil.codPerfil, codSubPerfil: local!perfil.codSubPerfil, codigo: tostring(fv!item.codigo), descripcion: tostring(fv!item.descripcion), orden: fv!index)
                )
              )
            )
          )
        )
      ),
      local!existentes: a!queryRecordType(
        recordType: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo',
        fields: {'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{903c3810-4491-4d87-9fe6-4b40a22a1bb3}fechaAlta', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion', 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{90f6ec37-4193-4e82-8012-b8d2e5b5a18e}usuarioModificacion'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
        fetchTotalCount: false
      ).data,
      local!clavesExistentes: touniformstring(a!forEach(items: local!existentes, expression: tostring(fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio']) & "|" & tostring(fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil']) & "|" & tostring(fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil']) & "|" & tostring(fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo']))),
      local!clavesCore: touniformstring(a!forEach(items: local!core, expression: tostring(fv!item.codLineaNegocio) & "|" & tostring(fv!item.codPerfil) & "|" & tostring(fv!item.codSubPerfil) & "|" & tostring(fv!item.codigo))),
      /* Upsert por clave natural: nueva → insert; existente origen CORE → update; existente origen MANUAL → no se toca */
      local!filas: a!forEach(
        items: local!core,
        expression: a!localVariables(
          local!pos: wherecontains(index(local!clavesCore, fv!index, ""), local!clavesExistentes),
          local!ex: if(a!isNullOrEmpty(local!pos), null, index(local!existentes, index(local!pos, 1, 1), null)),
          if(
            and(a!isNotNullOrEmpty(local!ex), local!ex['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen'] = "MANUAL"),
            null,
            'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo'(
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id': if(a!isNullOrEmpty(local!ex), null, local!ex['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id']),
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio': fv!item.codLineaNegocio,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil': fv!item.codPerfil,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil': fv!item.codSubPerfil,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo': fv!item.codigo,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion': fv!item.descripcion,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden': fv!item.orden,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo': true,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen': "CORE",
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{903c3810-4491-4d87-9fe6-4b40a22a1bb3}fechaAlta': if(a!isNullOrEmpty(local!ex), now(), local!ex['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{903c3810-4491-4d87-9fe6-4b40a22a1bb3}fechaAlta']),
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion': now(),
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{90f6ec37-4193-4e82-8012-b8d2e5b5a18e}usuarioModificacion': local!usuario
        )
          )
        )
      ),
      /* Filas CORE activas que ya no devuelve CORE → baja lógica (solo si CORE ha devuelto algo) */
      local!bajas: if(
        a!isNullOrEmpty(local!core),
        {},
        a!forEach(
          items: local!existentes,
          expression: if(
            and(
              fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen'] = "CORE",
              a!defaultValue(fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo'], false),
              not(contains(local!clavesCore, index(local!clavesExistentes, fv!index, "")))
            ),
            'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo'(
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id': fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id'],
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo': false,
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion': now(),
          'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{90f6ec37-4193-4e82-8012-b8d2e5b5a18e}usuarioModificacion': local!usuario
        ),
            null
          )
        )
      ),
      a!map(
        catalogo: "SCA2 Cat Motivo",
        filasCore: count(local!core),
        existentesAntes: count(local!existentes),
        manualesRespetadas: count(where(a!forEach(items: local!existentes, expression: fv!item['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen'] = "MANUAL"))),
        bajas: count(reject(fn!isnull, local!bajas)),
        registros: reject(fn!isnull, append(local!filas, local!bajas))
      )
    ),
    equals: "DETALLE",
    then: a!localVariables(
      local!usuario: user(loggedInUser(), "username"),
      local!core: a!localVariables(
        local!motivos: a!flatten(a!forEach(items: local!p.lineasNegocio, expression: a!localVariables(local!ln: fv!item, a!forEach(items: local!p.perfiles, expression: a!forEach(items: a!defaultValue(index(rule!SCA2_consultarMotivoCore(infoUsuarioDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}infoUsuarioDTO'(codCiaUsuario: local!p.codCiaUsuario, nuuma: local!p.infoUsuario.nuuma, codPerfil: fv!item.codPerfil, codSubPerfil: fv!item.codSubPerfil), codLineaNegocio: local!ln), "MSSConsultarMotivo", {}), {}), expression: local!ln & "|" & tostring(fv!item.codigo)))))),
        local!parejas: union(local!motivos, local!motivos),
        a!flatten(
          a!forEach(
            items: local!parejas,
            expression: a!localVariables(
              local!ln: tointeger(index(split(fv!item, "|"), 1, null)),
              local!motivo: index(split(fv!item, "|"), 2, null),
              a!forEach(
                items: a!defaultValue(index(rule!SCA2_consultarDetalleCore(codMotivo: local!motivo, codLineaNegocio: local!ln), "MSSConsultarDetalle", {}), {}),
                expression: a!map(codLineaNegocio: local!ln, codMotivo: local!motivo, codigo: tostring(fv!item.codigo), descripcion: tostring(fv!item.descripcion), orden: fv!index)
              )
            )
          )
        )
      ),
      local!existentes: a!queryRecordType(
        recordType: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle',
        fields: {'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d980d776-17d4-4236-8724-5612547ac669}fechaAlta', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{488228af-08b5-4df1-a7fd-0a8f08947f3b}usuarioModificacion'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
        fetchTotalCount: false
      ).data,
      local!clavesExistentes: touniformstring(a!forEach(items: local!existentes, expression: tostring(fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio']) & "|" & tostring(fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo']) & "|" & tostring(fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle']))),
      local!clavesCore: touniformstring(a!forEach(items: local!core, expression: tostring(fv!item.codLineaNegocio) & "|" & tostring(fv!item.codMotivo) & "|" & tostring(fv!item.codigo))),
      /* Upsert por clave natural: nueva → insert; existente origen CORE → update; existente origen MANUAL → no se toca */
      local!filas: a!forEach(
        items: local!core,
        expression: a!localVariables(
          local!pos: wherecontains(index(local!clavesCore, fv!index, ""), local!clavesExistentes),
          local!ex: if(a!isNullOrEmpty(local!pos), null, index(local!existentes, index(local!pos, 1, 1), null)),
          if(
            and(a!isNotNullOrEmpty(local!ex), local!ex['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen'] = "MANUAL"),
            null,
            'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle'(
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id': if(a!isNullOrEmpty(local!ex), null, local!ex['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id']),
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio': fv!item.codLineaNegocio,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo': fv!item.codMotivo,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle': fv!item.codigo,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion': fv!item.descripcion,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden': fv!item.orden,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo': true,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen': "CORE",
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d980d776-17d4-4236-8724-5612547ac669}fechaAlta': if(a!isNullOrEmpty(local!ex), now(), local!ex['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d980d776-17d4-4236-8724-5612547ac669}fechaAlta']),
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion': now(),
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{488228af-08b5-4df1-a7fd-0a8f08947f3b}usuarioModificacion': local!usuario
        )
          )
        )
      ),
      /* Filas CORE activas que ya no devuelve CORE → baja lógica (solo si CORE ha devuelto algo) */
      local!bajas: if(
        a!isNullOrEmpty(local!core),
        {},
        a!forEach(
          items: local!existentes,
          expression: if(
            and(
              fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen'] = "CORE",
              a!defaultValue(fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo'], false),
              not(contains(local!clavesCore, index(local!clavesExistentes, fv!index, "")))
            ),
            'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle'(
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id': fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id'],
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo': false,
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion': now(),
          'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{488228af-08b5-4df1-a7fd-0a8f08947f3b}usuarioModificacion': local!usuario
        ),
            null
          )
        )
      ),
      a!map(
        catalogo: "SCA2 Cat Detalle",
        filasCore: count(local!core),
        existentesAntes: count(local!existentes),
        manualesRespetadas: count(where(a!forEach(items: local!existentes, expression: fv!item['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen'] = "MANUAL"))),
        bajas: count(reject(fn!isnull, local!bajas)),
        registros: reject(fn!isnull, append(local!filas, local!bajas))
      )
    ),
    equals: "CAUSA",
    then: a!localVariables(
      local!usuario: user(loggedInUser(), "username"),
      local!core: a!localVariables(
        local!detalles: a!queryRecordType(
          recordType: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle',
          fields: {'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle'},
          filters: a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen', operator: "=", value: "CORE"),
          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
          fetchTotalCount: false
        ).data,
        a!flatten(
          a!forEach(
            items: local!detalles,
            expression: a!localVariables(
              local!det: fv!item,
              a!forEach(
                items: local!p.perfilesCausa,
                expression: a!localVariables(
                  local!perfil: fv!item,
                  a!forEach(
                    items: a!defaultValue(index(rule!SCA2_consultarCausaCore(codMotivo: local!det['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo'], codDetalle: local!det['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle'], codPerfil: local!perfil, codLineaNegocio: tostring(local!det['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio'])), "MSSConsultarCausa", {}), {}),
                    expression: a!map(codLineaNegocio: local!det['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio'], codMotivo: local!det['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo'], codDetalle: local!det['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle'], codPerfil: local!perfil, codigo: tostring(fv!item.codigo), descripcion: tostring(fv!item.descripcion), orden: fv!index)
                  )
                )
              )
            )
          )
        )
      ),
      local!existentes: a!queryRecordType(
        recordType: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa',
        fields: {'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ae77f839-09fa-4aa5-9142-5dc00942c6dc}fechaAlta', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion', 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{045605ef-fabe-4f9a-b819-6b4d412ba81d}usuarioModificacion'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
        fetchTotalCount: false
      ).data,
      local!clavesExistentes: touniformstring(a!forEach(items: local!existentes, expression: tostring(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio']) & "|" & tostring(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo']) & "|" & tostring(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle']) & "|" & tostring(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil']) & "|" & tostring(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa']))),
      local!clavesCore: touniformstring(a!forEach(items: local!core, expression: tostring(fv!item.codLineaNegocio) & "|" & tostring(fv!item.codMotivo) & "|" & tostring(fv!item.codDetalle) & "|" & tostring(fv!item.codPerfil) & "|" & tostring(fv!item.codigo))),
      /* Upsert por clave natural: nueva → insert; existente origen CORE → update; existente origen MANUAL → no se toca */
      local!filas: a!forEach(
        items: local!core,
        expression: a!localVariables(
          local!pos: wherecontains(index(local!clavesCore, fv!index, ""), local!clavesExistentes),
          local!ex: if(a!isNullOrEmpty(local!pos), null, index(local!existentes, index(local!pos, 1, 1), null)),
          if(
            and(a!isNotNullOrEmpty(local!ex), local!ex['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen'] = "MANUAL"),
            null,
            'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa'(
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id': if(a!isNullOrEmpty(local!ex), null, local!ex['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id']),
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio': fv!item.codLineaNegocio,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo': fv!item.codMotivo,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle': fv!item.codDetalle,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil': fv!item.codPerfil,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa': fv!item.codigo,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion': fv!item.descripcion,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden': fv!item.orden,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo': true,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen': "CORE",
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ae77f839-09fa-4aa5-9142-5dc00942c6dc}fechaAlta': if(a!isNullOrEmpty(local!ex), now(), local!ex['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ae77f839-09fa-4aa5-9142-5dc00942c6dc}fechaAlta']),
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion': now(),
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{045605ef-fabe-4f9a-b819-6b4d412ba81d}usuarioModificacion': local!usuario
        )
          )
        )
      ),
      /* Filas CORE activas que ya no devuelve CORE → baja lógica (solo si CORE ha devuelto algo) */
      local!bajas: if(
        a!isNullOrEmpty(local!core),
        {},
        a!forEach(
          items: local!existentes,
          expression: if(
            and(
              fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen'] = "CORE",
              a!defaultValue(fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo'], false),
              not(contains(local!clavesCore, index(local!clavesExistentes, fv!index, "")))
            ),
            'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa'(
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id': fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id'],
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo': false,
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion': now(),
          'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{045605ef-fabe-4f9a-b819-6b4d412ba81d}usuarioModificacion': local!usuario
        ),
            null
          )
        )
      ),
      a!map(
        catalogo: "SCA2 Cat Causa",
        filasCore: count(local!core),
        existentesAntes: count(local!existentes),
        manualesRespetadas: count(where(a!forEach(items: local!existentes, expression: fv!item['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen'] = "MANUAL"))),
        bajas: count(reject(fn!isnull, local!bajas)),
        registros: reject(fn!isnull, append(local!filas, local!bajas))
      )
    ),
    equals: "TIPO_ARGUMENTO",
    then: a!localVariables(
      local!usuario: user(loggedInUser(), "username"),
      local!core: a!forEach(
        items: a!defaultValue(index(rule!SCA2_consultarTipoArgCore(mseConsultarTipoArgDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarTipoArgDTO'(desc: "%")), "MSSConsultarTipoArg", {}), {}),
        expression: a!map(codTpArg: fv!item.codTpArg, descArg: fv!item.descArg, codEstado: fv!item.codEstado, idLineaNegocio: fv!item.idLineaNegocio, idRamo: fv!item.idRamo, codCompania: fv!item.codCompania, codCompaniaArg: fv!item.codCompaniaArg, apliArgumento: fv!item.apliArgumento, instruccion: fv!item.instruccion, mcaFinalizado: fv!item.mcaFinalizado, nombreDoc: fv!item.nombreDoc, numDoc: fv!item.numDoc, observaciones: fv!item.observaciones, fecVigencia: fv!item.fecVigencia, fecModificado: fv!item.fecModificado, codIdCampana: fv!item.codIdCampana, codTipBon: fv!item.codTipBon, numTipBon: fv!item.numTipBon, regateable: fv!item.regateable, mcaTeCuidamos: fv!item.mcaTeCuidamos, numDiasSgo: fv!item.numDiasSgo, codTareaSgo: fv!item.codTareaSgo, txtUrlArg: fv!item.txtUrlArg, mcaTrebCalc: fv!item.mcaTrebCalc, orden: fv!index)
      ),
      local!existentes: a!queryRecordType(
        recordType: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento',
        fields: {'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f7c00942-fcb3-4a18-b2c2-9d77b20b862c}numDiasSgo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2e399b24-37fe-4988-a915-3d73b41b9dfd}fechaAlta', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion', 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{35086732-fb4d-4e6d-a8e0-9a24dd8ac457}usuarioModificacion'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
        fetchTotalCount: false
      ).data,
      local!clavesExistentes: touniformstring(a!forEach(items: local!existentes, expression: tostring(fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg']))),
      local!clavesCore: touniformstring(a!forEach(items: local!core, expression: tostring(tostring(a!defaultValue(fv!item.codTpArg, ""))))),
      /* Upsert por clave natural: nueva → insert; existente origen CORE → update; existente origen MANUAL → no se toca */
      local!filas: a!forEach(
        items: local!core,
        expression: a!localVariables(
          local!pos: wherecontains(index(local!clavesCore, fv!index, ""), local!clavesExistentes),
          local!ex: if(a!isNullOrEmpty(local!pos), null, index(local!existentes, index(local!pos, 1, 1), null)),
          if(
            and(a!isNotNullOrEmpty(local!ex), local!ex['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen'] = "MANUAL"),
            null,
            'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento'(
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id': if(a!isNullOrEmpty(local!ex), null, local!ex['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id']),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg': tostring(a!defaultValue(fv!item.codTpArg, "")),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg': if(a!isNullOrEmpty(fv!item.descArg), null, tostring(fv!item.descArg)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado': if(a!isNullOrEmpty(fv!item.codEstado), null, tostring(fv!item.codEstado)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio': if(a!isNullOrEmpty(fv!item.idLineaNegocio), null, tostring(fv!item.idLineaNegocio)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo': if(a!isNullOrEmpty(fv!item.idRamo), null, tointeger(fv!item.idRamo)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania': if(a!isNullOrEmpty(fv!item.codCompania), null, tointeger(fv!item.codCompania)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg': if(a!isNullOrEmpty(fv!item.codCompaniaArg), null, tointeger(fv!item.codCompaniaArg)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento': if(a!isNullOrEmpty(fv!item.apliArgumento), null, tostring(fv!item.apliArgumento)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion': if(a!isNullOrEmpty(fv!item.instruccion), null, tostring(fv!item.instruccion)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado': if(a!isNullOrEmpty(fv!item.mcaFinalizado), null, tostring(fv!item.mcaFinalizado)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc': if(a!isNullOrEmpty(fv!item.nombreDoc), null, tostring(fv!item.nombreDoc)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc': if(a!isNullOrEmpty(fv!item.numDoc), null, tostring(fv!item.numDoc)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones': if(a!isNullOrEmpty(fv!item.observaciones), null, tostring(fv!item.observaciones)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia': if(a!isNullOrEmpty(fv!item.fecVigencia), null, tostring(fv!item.fecVigencia)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado': if(a!isNullOrEmpty(fv!item.fecModificado), null, tostring(fv!item.fecModificado)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana': if(a!isNullOrEmpty(fv!item.codIdCampana), null, tostring(fv!item.codIdCampana)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon': if(a!isNullOrEmpty(fv!item.codTipBon), null, tostring(fv!item.codTipBon)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon': if(a!isNullOrEmpty(fv!item.numTipBon), null, tostring(fv!item.numTipBon)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable': if(a!isNullOrEmpty(fv!item.regateable), null, tostring(fv!item.regateable)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos': if(a!isNullOrEmpty(fv!item.mcaTeCuidamos), null, tostring(fv!item.mcaTeCuidamos)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f7c00942-fcb3-4a18-b2c2-9d77b20b862c}numDiasSgo': if(a!isNullOrEmpty(fv!item.numDiasSgo), null, tointeger(fv!item.numDiasSgo)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo': if(a!isNullOrEmpty(fv!item.codTareaSgo), null, tostring(fv!item.codTareaSgo)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg': if(a!isNullOrEmpty(fv!item.txtUrlArg), null, tostring(fv!item.txtUrlArg)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc': if(a!isNullOrEmpty(fv!item.mcaTrebCalc), null, tostring(fv!item.mcaTrebCalc)),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden': fv!item.orden,
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo': true,
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen': "CORE",
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2e399b24-37fe-4988-a915-3d73b41b9dfd}fechaAlta': if(a!isNullOrEmpty(local!ex), now(), local!ex['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2e399b24-37fe-4988-a915-3d73b41b9dfd}fechaAlta']),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion': now(),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{35086732-fb4d-4e6d-a8e0-9a24dd8ac457}usuarioModificacion': local!usuario
        )
          )
        )
      ),
      /* Filas CORE activas que ya no devuelve CORE → baja lógica (solo si CORE ha devuelto algo) */
      local!bajas: if(
        a!isNullOrEmpty(local!core),
        {},
        a!forEach(
          items: local!existentes,
          expression: if(
            and(
              fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen'] = "CORE",
              a!defaultValue(fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo'], false),
              not(contains(local!clavesCore, index(local!clavesExistentes, fv!index, "")))
            ),
            'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento'(
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id': fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id'],
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo': false,
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion': now(),
          'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{35086732-fb4d-4e6d-a8e0-9a24dd8ac457}usuarioModificacion': local!usuario
        ),
            null
          )
        )
      ),
      a!map(
        catalogo: "SCA2 Cat Tipo Argumento",
        filasCore: count(local!core),
        existentesAntes: count(local!existentes),
        manualesRespetadas: count(where(a!forEach(items: local!existentes, expression: fv!item['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen'] = "MANUAL"))),
        bajas: count(reject(fn!isnull, local!bajas)),
        registros: reject(fn!isnull, append(local!filas, local!bajas))
      )
    ),
    equals: "CONCEPTO",
    then: a!localVariables(
      local!usuario: user(loggedInUser(), "username"),
      local!core: a!localVariables(
        local!cabecera: a!defaultValue(index(rule!SCA2_consultarConceptoCore(mseConsultarConceptoDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarConceptoDTO'(tipoBusqueda: "0", idConcepto: "", infoUsuario: local!p.infoUsuario)), "MSSConsultarConcepto", "listadoConceptos", {}), {}),
        /* La cabecera (tipoBusqueda 0) no trae mcaInh ni fecActu: se completan con la consulta por concepto (tipoBusqueda 1) */
        a!forEach(
          items: local!cabecera,
          expression: a!localVariables(
            local!det: index(rule!SCA2_consultarConceptoCore(mseConsultarConceptoDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarConceptoDTO'(tipoBusqueda: "1", idConcepto: tostring(fv!item.idnConceptoPca), infoUsuario: local!p.infoUsuario)), "MSSConsultarConcepto", "listadoConceptos", 1, null),
            a!map(idnConceptoPca: fv!item.idnConceptoPca, desConceptoPca: fv!item.desConceptoPca, mcaInh: index(local!det, "mcaInh", null), fecActu: index(local!det, "fecActu", null), orden: fv!index)
          )
        )
      ),
      local!existentes: a!queryRecordType(
        recordType: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto',
        fields: {'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
        fetchTotalCount: false
      ).data,
      local!clavesExistentes: touniformstring(a!forEach(items: local!existentes, expression: tostring(fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca']))),
      local!clavesCore: touniformstring(a!forEach(items: local!core, expression: tostring(tostring(a!defaultValue(fv!item.idnConceptoPca, ""))))),
      /* Upsert por clave natural: nueva → insert; existente origen CORE → update; existente origen MANUAL → no se toca */
      local!filas: a!forEach(
        items: local!core,
        expression: a!localVariables(
          local!pos: wherecontains(index(local!clavesCore, fv!index, ""), local!clavesExistentes),
          local!ex: if(a!isNullOrEmpty(local!pos), null, index(local!existentes, index(local!pos, 1, 1), null)),
          if(
            and(a!isNotNullOrEmpty(local!ex), local!ex['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen'] = "MANUAL"),
            null,
            'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto'(
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id': if(a!isNullOrEmpty(local!ex), null, local!ex['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id']),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca': tostring(a!defaultValue(fv!item.idnConceptoPca, "")),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca': if(a!isNullOrEmpty(fv!item.desConceptoPca), null, tostring(fv!item.desConceptoPca)),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh': if(a!isNullOrEmpty(fv!item.mcaInh), null, tostring(fv!item.mcaInh)),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu': if(a!isNullOrEmpty(fv!item.fecActu), null, todate(fv!item.fecActu)),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden': fv!item.orden,
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo': true,
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen': "CORE",
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta': if(a!isNullOrEmpty(local!ex), now(), local!ex['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta']),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion': now(),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion': local!usuario
        )
          )
        )
      ),
      /* Filas CORE activas que ya no devuelve CORE → baja lógica (solo si CORE ha devuelto algo) */
      local!bajas: if(
        a!isNullOrEmpty(local!core),
        {},
        a!forEach(
          items: local!existentes,
          expression: if(
            and(
              fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen'] = "CORE",
              a!defaultValue(fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo'], false),
              not(contains(local!clavesCore, index(local!clavesExistentes, fv!index, "")))
            ),
            'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto'(
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id': fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id'],
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo': false,
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion': now(),
          'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion': local!usuario
        ),
            null
          )
        )
      ),
      a!map(
        catalogo: "SCA2 Cat Concepto",
        filasCore: count(local!core),
        existentesAntes: count(local!existentes),
        manualesRespetadas: count(where(a!forEach(items: local!existentes, expression: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen'] = "MANUAL"))),
        bajas: count(reject(fn!isnull, local!bajas)),
        registros: reject(fn!isnull, append(local!filas, local!bajas))
      )
    ),
    equals: "VALOR_CONCEPTO",
    then: a!localVariables(
      local!usuario: user(loggedInUser(), "username"),
      local!core: a!localVariables(
        local!cabecera: a!defaultValue(index(rule!SCA2_consultarConceptoCore(mseConsultarConceptoDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarConceptoDTO'(tipoBusqueda: "0", idConcepto: "", infoUsuario: local!p.infoUsuario)), "MSSConsultarConcepto", "listadoConceptos", {}), {}),
        a!flatten(
          a!forEach(
            items: local!cabecera,
            expression: a!forEach(
              items: a!defaultValue(index(rule!SCA2_consultarConceptoCore(mseConsultarConceptoDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseConsultarConceptoDTO'(tipoBusqueda: "1", idConcepto: tostring(fv!item.idnConceptoPca), infoUsuario: local!p.infoUsuario)), "MSSConsultarConcepto", "listadoConceptos", 1, "valoresConcepto", {}), {}),
              expression: a!map(idnConceptoPca: fv!item.idnConceptoPca, idnPca: fv!item.idnPca, valorConcepto: fv!item.valorConcepto, desConcepto: fv!item.desConcepto, mcaInh: fv!item.mcaInh, fecActu: fv!item.fecActu, orden: fv!index)
            )
          )
        )
      ),
      local!existentes: a!queryRecordType(
        recordType: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto',
        fields: {'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{6bffd08a-a36f-4656-b3c0-82725b43a8a3}fechaAlta', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{bd11a237-199f-41e7-9c3d-e9550a0a009b}usuarioModificacion'},
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000),
        fetchTotalCount: false
      ).data,
      local!clavesExistentes: touniformstring(a!forEach(items: local!existentes, expression: tostring(fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca']) & "|" & tostring(fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca']))),
      local!clavesCore: touniformstring(a!forEach(items: local!core, expression: tostring(tostring(a!defaultValue(fv!item.idnConceptoPca, ""))) & "|" & tostring(tostring(a!defaultValue(fv!item.idnPca, ""))))),
      /* Upsert por clave natural: nueva → insert; existente origen CORE → update; existente origen MANUAL → no se toca */
      local!filas: a!forEach(
        items: local!core,
        expression: a!localVariables(
          local!pos: wherecontains(index(local!clavesCore, fv!index, ""), local!clavesExistentes),
          local!ex: if(a!isNullOrEmpty(local!pos), null, index(local!existentes, index(local!pos, 1, 1), null)),
          if(
            and(a!isNotNullOrEmpty(local!ex), local!ex['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen'] = "MANUAL"),
            null,
            'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto'(
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id': if(a!isNullOrEmpty(local!ex), null, local!ex['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id']),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca': tostring(a!defaultValue(fv!item.idnConceptoPca, "")),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca': tostring(a!defaultValue(fv!item.idnPca, "")),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto': if(a!isNullOrEmpty(fv!item.valorConcepto), null, tostring(fv!item.valorConcepto)),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto': if(a!isNullOrEmpty(fv!item.desConcepto), null, tostring(fv!item.desConcepto)),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh': if(a!isNullOrEmpty(fv!item.mcaInh), null, tostring(fv!item.mcaInh)),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu': if(a!isNullOrEmpty(fv!item.fecActu), null, todate(fv!item.fecActu)),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden': fv!item.orden,
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo': true,
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen': "CORE",
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{6bffd08a-a36f-4656-b3c0-82725b43a8a3}fechaAlta': if(a!isNullOrEmpty(local!ex), now(), local!ex['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{6bffd08a-a36f-4656-b3c0-82725b43a8a3}fechaAlta']),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion': now(),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{bd11a237-199f-41e7-9c3d-e9550a0a009b}usuarioModificacion': local!usuario
        )
          )
        )
      ),
      /* Filas CORE activas que ya no devuelve CORE → baja lógica (solo si CORE ha devuelto algo) */
      local!bajas: if(
        a!isNullOrEmpty(local!core),
        {},
        a!forEach(
          items: local!existentes,
          expression: if(
            and(
              fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen'] = "CORE",
              a!defaultValue(fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo'], false),
              not(contains(local!clavesCore, index(local!clavesExistentes, fv!index, "")))
            ),
            'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto'(
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id': fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id'],
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo': false,
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion': now(),
          'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{bd11a237-199f-41e7-9c3d-e9550a0a009b}usuarioModificacion': local!usuario
        ),
            null
          )
        )
      ),
      a!map(
        catalogo: "SCA2 Cat Valor Concepto",
        filasCore: count(local!core),
        existentesAntes: count(local!existentes),
        manualesRespetadas: count(where(a!forEach(items: local!existentes, expression: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen'] = "MANUAL"))),
        bajas: count(reject(fn!isnull, local!bajas)),
        registros: reject(fn!isnull, append(local!filas, local!bajas))
      )
    ),
    default: a!map(catalogo: ri!catalogo, error: "Catálogo no reconocido", registros: {})
  )
)