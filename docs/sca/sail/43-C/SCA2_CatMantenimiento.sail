/* [SCA2] Mantenimiento de catálogos CORE cacheados en Aurora (records SCA2 Cat *): lista por catálogo con búsqueda, alta, edición y baja/alta lógica,
   y «Recargar desde CORE» (SCA2_catCargarDesdeCore, upsert idempotente que respeta las filas de origen MANUAL).
   Solo escriben los administradores de SCA2 (cons!SCA2_GRP_ADMINISTRADORES); el resto ve la lista en solo lectura.
   Las filas se sirven a las pantallas de SCA2 únicamente cuando cons!SCA2_USAR_CATALOGOS_AURORA = true. Fase 1, sesión C. */
a!localVariables(
  local!esAdmin: a!isUserMemberOfGroup(loggedInUser(), cons!SCA2_GRP_ADMINISTRADORES),
  local!catalogos: {a!map(id: "MOTIVO", nombre: "Motivos de anulación"), a!map(id: "DETALLE", nombre: "Detalles de anulación"), a!map(id: "CAUSA", nombre: "Causas de anulación"), a!map(id: "TIPO_ARGUMENTO", nombre: "Tipos de argumento"), a!map(id: "CONCEPTO", nombre: "Conceptos PCA"), a!map(id: "VALOR_CONCEPTO", nombre: "Valores de concepto")},
  local!catalogo: "MOTIVO",
  local!busqueda: null,
  local!soloActivos: true,
  local!refresco: 0,
  local!sel: null,
  local!form: null,
  local!mensaje: null,
  local!tipoMensaje: null,
  local!duplicados: 0,
  {
    a!sectionLayout(
      label: "Catálogos CORE en Aurora",
      contents: {
        a!richTextDisplayField(
          labelPosition: "COLLAPSED",
          value: {
            a!richTextItem(text: "Copia en la base de datos de SCA2 de los catálogos de CORE (motivos, detalles, causas, tipos de argumento y conceptos). ", color: "SECONDARY"),
            a!richTextItem(text: if(a!defaultValue(cons!SCA2_USAR_CATALOGOS_AURORA, false), "Las pantallas están leyendo de Aurora (SCA2_USAR_CATALOGOS_AURORA = true).", "Las pantallas siguen leyendo de CORE (SCA2_USAR_CATALOGOS_AURORA = false); esta copia aún no se usa."), color: if(a!defaultValue(cons!SCA2_USAR_CATALOGOS_AURORA, false), "POSITIVE", "SECONDARY"), style: "STRONG")
          }
        ),
        a!columnsLayout(
          columns: {
            a!columnLayout(contents: {
              a!dropdownField(label: "Catálogo", choiceLabels: index(local!catalogos, "nombre", {}), choiceValues: index(local!catalogos, "id", {}), value: local!catalogo,
                saveInto: {local!catalogo, a!save(local!sel, null), a!save(local!form, null), a!save(local!mensaje, null), a!save(local!busqueda, null)})
            }, width: "MEDIUM"),
            a!columnLayout(contents: {
              a!textField(label: "Buscar", placeholder: "código o descripción", value: local!busqueda, saveInto: {local!busqueda, a!save(local!sel, null), a!save(local!form, null)}, refreshAfter: "KEYPRESS")
            }, width: "MEDIUM"),
            a!columnLayout(contents: {
              a!checkboxField(label: "Filtro", choiceLabels: {"Solo activos"}, choiceValues: {true}, value: if(local!soloActivos, {true}, {}), saveInto: a!save(local!soloActivos, a!isNotNullOrEmpty(save!value)))
            }, width: "NARROW")
          }
        ),
        a!richTextDisplayField(
          labelPosition: "COLLAPSED",
          showWhen: a!isNotNullOrEmpty(local!mensaje),
          value: a!richTextItem(text: local!mensaje, color: a!defaultValue(local!tipoMensaje, "ACCENT"), style: "STRONG")
        ),
        a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: a!gridField(
          label: "",
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id', operator: "not null"),
                if(local!soloActivos, a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo', operator: "=", value: true), {})
              },
              logicalExpressions: if(
                a!isNullOrEmpty(local!busqueda),
                {},
                a!queryLogicalExpression(
                  operator: "OR",
                  filters: {
                    a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion', operator: "includes", value: local!busqueda)
                  }
                )
              )
            )
          ),
          columns: {
            a!gridColumn(label: "Línea de negocio", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio'], width: "NARROW"),
            a!gridColumn(label: "Perfil", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil']),
            a!gridColumn(label: "Subperfil", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil']),
            a!gridColumn(label: "Cód. motivo", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo']),
            a!gridColumn(label: "Descripción", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion']),
            a!gridColumn(label: "Orden", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden'], width: "NARROW"),
            a!gridColumn(label: "Activo", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo', value: if(a!defaultValue(fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo'], false), "Sí", "No"), width: "NARROW"),
            a!gridColumn(label: "Origen", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen'], width: "NARROW"),
            a!gridColumn(label: "Modificación", sortField: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion', value: fv!row['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion'])
          },
          pageSize: 15,
          initialSorts: {a!sortInfo(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden', ascending: true), a!sortInfo(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id', ascending: true)},
          selectable: true,
          selectionStyle: "ROW_HIGHLIGHT",
          selectionValue: if(a!isNullOrEmpty(local!sel), {}, {local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id']}),
          selectionSaveInto: {
            a!save(local!sel, if(a!isNullOrEmpty(fv!selectedRows), null, index(fv!selectedRows, 1, null))),
            a!save(local!form, if(a!isNullOrEmpty(fv!selectedRows), null, a!localVariables(local!sel: index(fv!selectedRows, 1, null), a!map(codLineaNegocio: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio'], codPerfil: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil'], codSubPerfil: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil'], codMotivo: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo'], descripcion: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion'], orden: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden'], id: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id'], activo: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo'], origen: local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen'])))),
            a!save(local!mensaje, null)
          },
          refreshAfter: "RECORD_ACTION",
          refreshOnVarChange: local!refresco,
          emptyGridMessage: "Sin filas en este catálogo (todavía no se ha cargado desde CORE o no hay coincidencias)",
          rowHeader: 1
        ),
          equals: "DETALLE",
          then: a!gridField(
          label: "",
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id', operator: "not null"),
                if(local!soloActivos, a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo', operator: "=", value: true), {})
              },
              logicalExpressions: if(
                a!isNullOrEmpty(local!busqueda),
                {},
                a!queryLogicalExpression(
                  operator: "OR",
                  filters: {
                    a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion', operator: "includes", value: local!busqueda)
                  }
                )
              )
            )
          ),
          columns: {
            a!gridColumn(label: "Línea de negocio", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio'], width: "NARROW"),
            a!gridColumn(label: "Cód. motivo", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo']),
            a!gridColumn(label: "Cód. detalle", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle']),
            a!gridColumn(label: "Descripción", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion']),
            a!gridColumn(label: "Orden", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden'], width: "NARROW"),
            a!gridColumn(label: "Activo", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo', value: if(a!defaultValue(fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo'], false), "Sí", "No"), width: "NARROW"),
            a!gridColumn(label: "Origen", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen'], width: "NARROW"),
            a!gridColumn(label: "Modificación", sortField: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion', value: fv!row['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion'])
          },
          pageSize: 15,
          initialSorts: {a!sortInfo(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden', ascending: true), a!sortInfo(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id', ascending: true)},
          selectable: true,
          selectionStyle: "ROW_HIGHLIGHT",
          selectionValue: if(a!isNullOrEmpty(local!sel), {}, {local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id']}),
          selectionSaveInto: {
            a!save(local!sel, if(a!isNullOrEmpty(fv!selectedRows), null, index(fv!selectedRows, 1, null))),
            a!save(local!form, if(a!isNullOrEmpty(fv!selectedRows), null, a!localVariables(local!sel: index(fv!selectedRows, 1, null), a!map(codLineaNegocio: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio'], codMotivo: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo'], codDetalle: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle'], descripcion: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion'], orden: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden'], id: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id'], activo: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo'], origen: local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen'])))),
            a!save(local!mensaje, null)
          },
          refreshAfter: "RECORD_ACTION",
          refreshOnVarChange: local!refresco,
          emptyGridMessage: "Sin filas en este catálogo (todavía no se ha cargado desde CORE o no hay coincidencias)",
          rowHeader: 1
        ),
          equals: "CAUSA",
          then: a!gridField(
          label: "",
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id', operator: "not null"),
                if(local!soloActivos, a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo', operator: "=", value: true), {})
              },
              logicalExpressions: if(
                a!isNullOrEmpty(local!busqueda),
                {},
                a!queryLogicalExpression(
                  operator: "OR",
                  filters: {
                    a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion', operator: "includes", value: local!busqueda)
                  }
                )
              )
            )
          ),
          columns: {
            a!gridColumn(label: "Línea de negocio", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio'], width: "NARROW"),
            a!gridColumn(label: "Cód. motivo", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo']),
            a!gridColumn(label: "Cód. detalle", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle']),
            a!gridColumn(label: "Perfil", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil']),
            a!gridColumn(label: "Cód. causa", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa']),
            a!gridColumn(label: "Descripción", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion']),
            a!gridColumn(label: "Orden", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden'], width: "NARROW"),
            a!gridColumn(label: "Activo", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo', value: if(a!defaultValue(fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo'], false), "Sí", "No"), width: "NARROW"),
            a!gridColumn(label: "Origen", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen'], width: "NARROW"),
            a!gridColumn(label: "Modificación", sortField: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion', value: fv!row['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion'])
          },
          pageSize: 15,
          initialSorts: {a!sortInfo(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden', ascending: true), a!sortInfo(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id', ascending: true)},
          selectable: true,
          selectionStyle: "ROW_HIGHLIGHT",
          selectionValue: if(a!isNullOrEmpty(local!sel), {}, {local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id']}),
          selectionSaveInto: {
            a!save(local!sel, if(a!isNullOrEmpty(fv!selectedRows), null, index(fv!selectedRows, 1, null))),
            a!save(local!form, if(a!isNullOrEmpty(fv!selectedRows), null, a!localVariables(local!sel: index(fv!selectedRows, 1, null), a!map(codLineaNegocio: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio'], codMotivo: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo'], codDetalle: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle'], codPerfil: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil'], codCausa: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa'], descripcion: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion'], orden: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden'], id: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id'], activo: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo'], origen: local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen'])))),
            a!save(local!mensaje, null)
          },
          refreshAfter: "RECORD_ACTION",
          refreshOnVarChange: local!refresco,
          emptyGridMessage: "Sin filas en este catálogo (todavía no se ha cargado desde CORE o no hay coincidencias)",
          rowHeader: 1
        ),
          equals: "TIPO_ARGUMENTO",
          then: a!gridField(
          label: "",
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id', operator: "not null"),
                if(local!soloActivos, a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo', operator: "=", value: true), {})
              },
              logicalExpressions: if(
                a!isNullOrEmpty(local!busqueda),
                {},
                a!queryLogicalExpression(
                  operator: "OR",
                  filters: {
                    a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc', operator: "includes", value: local!busqueda)
                  }
                )
              )
            )
          ),
          columns: {
            a!gridColumn(label: "Cód. tipo arg.", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg']),
            a!gridColumn(label: "Descripción", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg']),
            a!gridColumn(label: "Estado (S/N)", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado'], width: "NARROW"),
            a!gridColumn(label: "Línea negocio", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio']),
            a!gridColumn(label: "Ramo", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo']),
            a!gridColumn(label: "Compañía", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania']),
            a!gridColumn(label: "Compañía arg.", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg']),
            a!gridColumn(label: "Aplicación", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento']),
            a!gridColumn(label: "Orden", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden'], width: "NARROW"),
            a!gridColumn(label: "Activo", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo', value: if(a!defaultValue(fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo'], false), "Sí", "No"), width: "NARROW"),
            a!gridColumn(label: "Origen", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen'], width: "NARROW"),
            a!gridColumn(label: "Modificación", sortField: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion', value: fv!row['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion'])
          },
          pageSize: 15,
          initialSorts: {a!sortInfo(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden', ascending: true), a!sortInfo(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id', ascending: true)},
          selectable: true,
          selectionStyle: "ROW_HIGHLIGHT",
          selectionValue: if(a!isNullOrEmpty(local!sel), {}, {local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id']}),
          selectionSaveInto: {
            a!save(local!sel, if(a!isNullOrEmpty(fv!selectedRows), null, index(fv!selectedRows, 1, null))),
            a!save(local!form, if(a!isNullOrEmpty(fv!selectedRows), null, a!localVariables(local!sel: index(fv!selectedRows, 1, null), a!map(codTpArg: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg'], descArg: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg'], codEstado: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado'], idLineaNegocio: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio'], idRamo: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo'], codCompania: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania'], codCompaniaArg: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg'], apliArgumento: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento'], instruccion: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion'], mcaFinalizado: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado'], nombreDoc: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc'], numDoc: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc'], observaciones: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones'], fecVigencia: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia'], fecModificado: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado'], codIdCampana: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana'], codTipBon: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon'], numTipBon: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon'], regateable: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable'], mcaTeCuidamos: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos'], numDiasSgo: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f7c00942-fcb3-4a18-b2c2-9d77b20b862c}numDiasSgo'], codTareaSgo: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo'], txtUrlArg: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg'], mcaTrebCalc: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc'], orden: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden'], id: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id'], activo: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo'], origen: local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen'])))),
            a!save(local!mensaje, null)
          },
          refreshAfter: "RECORD_ACTION",
          refreshOnVarChange: local!refresco,
          emptyGridMessage: "Sin filas en este catálogo (todavía no se ha cargado desde CORE o no hay coincidencias)",
          rowHeader: 1
        ),
          equals: "CONCEPTO",
          then: a!gridField(
          label: "",
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', operator: "not null"),
                if(local!soloActivos, a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', operator: "=", value: true), {})
              },
              logicalExpressions: if(
                a!isNullOrEmpty(local!busqueda),
                {},
                a!queryLogicalExpression(
                  operator: "OR",
                  filters: {
                    a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh', operator: "includes", value: local!busqueda)
                  }
                )
              )
            )
          ),
          columns: {
            a!gridColumn(label: "Id concepto", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca']),
            a!gridColumn(label: "Descripción", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca']),
            a!gridColumn(label: "Inhabilitado (S/N)", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh'], width: "NARROW"),
            a!gridColumn(label: "Fec. actualización", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu']),
            a!gridColumn(label: "Orden", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden'], width: "NARROW"),
            a!gridColumn(label: "Activo", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', value: if(a!defaultValue(fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo'], false), "Sí", "No"), width: "NARROW"),
            a!gridColumn(label: "Origen", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen'], width: "NARROW"),
            a!gridColumn(label: "Modificación", sortField: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion', value: fv!row['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion'])
          },
          pageSize: 15,
          initialSorts: {a!sortInfo(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', ascending: true), a!sortInfo(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', ascending: true)},
          selectable: true,
          selectionStyle: "ROW_HIGHLIGHT",
          selectionValue: if(a!isNullOrEmpty(local!sel), {}, {local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id']}),
          selectionSaveInto: {
            a!save(local!sel, if(a!isNullOrEmpty(fv!selectedRows), null, index(fv!selectedRows, 1, null))),
            a!save(local!form, if(a!isNullOrEmpty(fv!selectedRows), null, a!localVariables(local!sel: index(fv!selectedRows, 1, null), a!map(idnConceptoPca: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca'], desConceptoPca: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca'], mcaInh: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh'], fecActu: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu'], orden: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden'], id: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id'], activo: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo'], origen: local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen'])))),
            a!save(local!mensaje, null)
          },
          refreshAfter: "RECORD_ACTION",
          refreshOnVarChange: local!refresco,
          emptyGridMessage: "Sin filas en este catálogo (todavía no se ha cargado desde CORE o no hay coincidencias)",
          rowHeader: 1
        ),
          equals: "VALOR_CONCEPTO",
          then: a!gridField(
          label: "",
          labelPosition: "COLLAPSED",
          data: a!recordData(
            recordType: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id', operator: "not null"),
                if(local!soloActivos, a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo', operator: "=", value: true), {})
              },
              logicalExpressions: if(
                a!isNullOrEmpty(local!busqueda),
                {},
                a!queryLogicalExpression(
                  operator: "OR",
                  filters: {
                    a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto', operator: "includes", value: local!busqueda),
                a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh', operator: "includes", value: local!busqueda)
                  }
                )
              )
            )
          ),
          columns: {
            a!gridColumn(label: "Id concepto", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca']),
            a!gridColumn(label: "Id valor", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca'], width: "NARROW"),
            a!gridColumn(label: "Valor", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto']),
            a!gridColumn(label: "Descripción", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto']),
            a!gridColumn(label: "Inhabilitado (S/N)", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh'], width: "NARROW"),
            a!gridColumn(label: "Fec. actualización", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu']),
            a!gridColumn(label: "Orden", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden'], width: "NARROW"),
            a!gridColumn(label: "Activo", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo', value: if(a!defaultValue(fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo'], false), "Sí", "No"), width: "NARROW"),
            a!gridColumn(label: "Origen", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen'], width: "NARROW"),
            a!gridColumn(label: "Modificación", sortField: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion', value: fv!row['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion'])
          },
          pageSize: 15,
          initialSorts: {a!sortInfo(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden', ascending: true), a!sortInfo(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id', ascending: true)},
          selectable: true,
          selectionStyle: "ROW_HIGHLIGHT",
          selectionValue: if(a!isNullOrEmpty(local!sel), {}, {local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id']}),
          selectionSaveInto: {
            a!save(local!sel, if(a!isNullOrEmpty(fv!selectedRows), null, index(fv!selectedRows, 1, null))),
            a!save(local!form, if(a!isNullOrEmpty(fv!selectedRows), null, a!localVariables(local!sel: index(fv!selectedRows, 1, null), a!map(idnConceptoPca: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca'], idnPca: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca'], valorConcepto: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto'], desConcepto: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto'], mcaInh: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh'], fecActu: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu'], orden: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden'], id: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id'], activo: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo'], origen: local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen'])))),
            a!save(local!mensaje, null)
          },
          refreshAfter: "RECORD_ACTION",
          refreshOnVarChange: local!refresco,
          emptyGridMessage: "Sin filas en este catálogo (todavía no se ha cargado desde CORE o no hay coincidencias)",
          rowHeader: 1
        ),
          default: {}
        ),
        a!buttonArrayLayout(
          showWhen: local!esAdmin,
          align: "START",
          buttons: {
            a!buttonWidget(label: "Nuevo", style: "OUTLINE", icon: "plus",
              saveInto: {a!save(local!sel, null), a!save(local!mensaje, null), a!save(local!form, a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: a!map(codLineaNegocio: null, codPerfil: null, codSubPerfil: null, codMotivo: null, descripcion: null, orden: null, id: null, activo: true, origen: "MANUAL"),
          equals: "DETALLE",
          then: a!map(codLineaNegocio: null, codMotivo: null, codDetalle: null, descripcion: null, orden: null, id: null, activo: true, origen: "MANUAL"),
          equals: "CAUSA",
          then: a!map(codLineaNegocio: null, codMotivo: null, codDetalle: null, codPerfil: null, codCausa: null, descripcion: null, orden: null, id: null, activo: true, origen: "MANUAL"),
          equals: "TIPO_ARGUMENTO",
          then: a!map(codTpArg: null, descArg: null, codEstado: null, idLineaNegocio: null, idRamo: null, codCompania: null, codCompaniaArg: null, apliArgumento: null, instruccion: null, mcaFinalizado: null, nombreDoc: null, numDoc: null, observaciones: null, fecVigencia: null, fecModificado: null, codIdCampana: null, codTipBon: null, numTipBon: null, regateable: null, mcaTeCuidamos: null, numDiasSgo: null, codTareaSgo: null, txtUrlArg: null, mcaTrebCalc: null, orden: null, id: null, activo: true, origen: "MANUAL"),
          equals: "CONCEPTO",
          then: a!map(idnConceptoPca: null, desConceptoPca: null, mcaInh: null, fecActu: null, orden: null, id: null, activo: true, origen: "MANUAL"),
          equals: "VALOR_CONCEPTO",
          then: a!map(idnConceptoPca: null, idnPca: null, valorConcepto: null, desConcepto: null, mcaInh: null, fecActu: null, orden: null, id: null, activo: true, origen: "MANUAL"),
          default: {}
        ))}),
            a!buttonWidget(label: "Recargar desde CORE", style: "OUTLINE", icon: "refresh", confirmMessage: "Se consultará CORE y se actualizarán las filas de origen CORE de este catálogo (las filas de origen MANUAL no se tocan). ¿Continuar?",
              saveInto: a!localVariables(
                /* La construcción (lectura de CORE + comparación con Aurora) no escribe; la escritura va directamente en a!writeRecords (un smart service por clic) */
                local!carga: rule!SCA2_catConstruirCarga(catalogo: local!catalogo),
                local!registros: a!defaultValue(index(local!carga, "registros", {}), {}),
                local!resumen: a!defaultValue(index(local!carga, "filasCore", 0), 0) & " filas en CORE, " & a!defaultValue(index(local!carga, "manualesRespetadas", 0), 0) & " manuales respetadas, " & a!defaultValue(index(local!carga, "bajas", 0), 0) & " bajas lógicas",
                if(
                  a!isNullOrEmpty(local!registros),
                  {a!save(local!tipoMensaje, "NEGATIVE"), a!save(local!mensaje, "Recarga desde CORE no realizada: CORE no ha devuelto filas o no hay cambios (" & local!resumen & ").")},
                  a!writeRecords(
                    records: local!registros,
                    onSuccess: {
                      a!save(local!refresco, local!refresco + 1), a!save(local!sel, null), a!save(local!form, null),
                      a!save(local!tipoMensaje, "POSITIVE"),
                      a!save(local!mensaje, "Recarga desde CORE completada: " & local!resumen & ", " & count(fv!recordsUpdated) & " filas escritas.")
                    },
                    onError: {a!save(local!tipoMensaje, "NEGATIVE"), a!save(local!mensaje, "Recarga desde CORE no realizada: " & tostring(fv!error))}
                  )
                )
              ))
          }
        )
      }
    ),
    a!sectionLayout(
      label: if(a!isNullOrEmpty(local!form), "", if(a!isNullOrEmpty(local!form.id), "Nueva fila", "Fila seleccionada" & if(local!form.origen = "CORE", " (origen CORE: al editarla deja de actualizarse desde CORE si cambia su clave)", ""))),
      showWhen: and(local!esAdmin, a!isNotNullOrEmpty(local!form)),
      contents: {
        a!columnsLayout(
          columns: {
            a!columnLayout(contents: {
              a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: {
              a!integerField(label: "Línea de negocio" & " *", value: local!form.codLineaNegocio, saveInto: local!form.codLineaNegocio, required: true, instructions: "Línea de negocio (codsector TRON / LINEA_NEGOCIO wAutemis): 1 Autos, 2 Diversos, 3 Vida"),
              a!textField(label: "Perfil" & " *", value: local!form.codPerfil, saveInto: local!form.codPerfil, required: true, characterLimit: 30, instructions: "Perfil PCA del usuario (infoUsuarioDTO.codPerfil) para el que CORE devuelve el motivo"),
              a!textField(label: "Subperfil" & " *", value: local!form.codSubPerfil, saveInto: local!form.codSubPerfil, required: true, characterLimit: 30, instructions: "Subperfil PCA del usuario (infoUsuarioDTO.codSubPerfil)"),
              a!textField(label: "Cód. motivo" & " *", value: local!form.codMotivo, saveInto: local!form.codMotivo, required: true, characterLimit: 5, instructions: "Código del motivo en CORE (tipoElementoBasicoDTO.codigo)"),
              a!textField(label: "Descripción", value: local!form.descripcion, saveInto: local!form.descripcion, required: false, characterLimit: 100, instructions: "Descripción del motivo (tipoElementoBasicoDTO.descripcion)"),
              a!integerField(label: "Orden", value: local!form.orden, saveInto: local!form.orden, required: false, instructions: "Posición en la respuesta del CORE (orden de presentación)")
              },
          equals: "DETALLE",
          then: {
              a!integerField(label: "Línea de negocio" & " *", value: local!form.codLineaNegocio, saveInto: local!form.codLineaNegocio, required: true, instructions: "Línea de negocio"),
              a!textField(label: "Cód. motivo" & " *", value: local!form.codMotivo, saveInto: local!form.codMotivo, required: true, characterLimit: 5, instructions: "Código del motivo padre"),
              a!textField(label: "Cód. detalle" & " *", value: local!form.codDetalle, saveInto: local!form.codDetalle, required: true, characterLimit: 5, instructions: "Código del detalle en CORE"),
              a!textField(label: "Descripción", value: local!form.descripcion, saveInto: local!form.descripcion, required: false, characterLimit: 100, instructions: "Descripción del detalle"),
              a!integerField(label: "Orden", value: local!form.orden, saveInto: local!form.orden, required: false, instructions: "Posición en la respuesta del CORE (orden de presentación)")
              },
          equals: "CAUSA",
          then: {
              a!integerField(label: "Línea de negocio" & " *", value: local!form.codLineaNegocio, saveInto: local!form.codLineaNegocio, required: true, instructions: "Línea de negocio"),
              a!textField(label: "Cód. motivo" & " *", value: local!form.codMotivo, saveInto: local!form.codMotivo, required: true, characterLimit: 5, instructions: "Código del motivo"),
              a!textField(label: "Cód. detalle" & " *", value: local!form.codDetalle, saveInto: local!form.codDetalle, required: true, characterLimit: 5, instructions: "Código del detalle"),
              a!textField(label: "Perfil" & " *", value: local!form.codPerfil, saveInto: local!form.codPerfil, required: true, characterLimit: 30, instructions: "Perfil PCA (listadoCausaAnulDTO.codPerfil) para el que CORE devuelve la causa"),
              a!textField(label: "Cód. causa" & " *", value: local!form.codCausa, saveInto: local!form.codCausa, required: true, characterLimit: 5, instructions: "Código de la causa en CORE"),
              a!textField(label: "Descripción", value: local!form.descripcion, saveInto: local!form.descripcion, required: false, characterLimit: 100, instructions: "Descripción de la causa"),
              a!integerField(label: "Orden", value: local!form.orden, saveInto: local!form.orden, required: false, instructions: "Posición en la respuesta del CORE (orden de presentación)")
              },
          equals: "TIPO_ARGUMENTO",
          then: {
              a!textField(label: "Cód. tipo arg." & " *", value: local!form.codTpArg, saveInto: local!form.codTpArg, required: true, characterLimit: 5, instructions: "Código del tipo de argumento (clave CORE)"),
              a!textField(label: "Descripción", value: local!form.descArg, saveInto: local!form.descArg, required: false, characterLimit: 100, instructions: "Descripción del argumento"),
              a!textField(label: "Estado (S/N)", value: local!form.codEstado, saveInto: local!form.codEstado, required: false, characterLimit: 1, instructions: "Estado S/N"),
              a!textField(label: "Línea negocio", value: local!form.idLineaNegocio, saveInto: local!form.idLineaNegocio, required: false, characterLimit: 2, instructions: "Línea de negocio 1/2/3"),
              a!integerField(label: "Ramo", value: local!form.idRamo, saveInto: local!form.idRamo, required: false, instructions: "Ramo (200 Autos, 73 Diversos, 101 Vida)"),
              a!integerField(label: "Compañía", value: local!form.codCompania, saveInto: local!form.codCompania, required: false, instructions: "Compañía (vacío en CORE)"),
              a!integerField(label: "Compañía arg.", value: local!form.codCompaniaArg, saveInto: local!form.codCompaniaArg, required: false, instructions: "Compañía del argumento (41, 1, 3)"),
              a!textField(label: "Aplicación", value: local!form.apliArgumento, saveInto: local!form.apliArgumento, required: false, characterLimit: 30, instructions: "Aplicación (VISUALIZAR_PDF, WAUTEMIS, TE_CUIDAMOS, …)"),
              a!textField(label: "Instrucción", value: local!form.instruccion, saveInto: local!form.instruccion, required: false, characterLimit: 255, instructions: "Instrucción"),
              a!textField(label: "Finalizado (S/N)", value: local!form.mcaFinalizado, saveInto: local!form.mcaFinalizado, required: false, characterLimit: 1, instructions: "Marca finalizado S/N"),
              a!textField(label: "Nombre doc.", value: local!form.nombreDoc, saveInto: local!form.nombreDoc, required: false, characterLimit: 100, instructions: "Nombre del documento"),
              a!textField(label: "Num. doc.", value: local!form.numDoc, saveInto: local!form.numDoc, required: false, characterLimit: 30, instructions: "Identificador Documentum"),
              a!textField(label: "Observaciones", value: local!form.observaciones, saveInto: local!form.observaciones, required: false, characterLimit: 255, instructions: "Observaciones"),
              a!textField(label: "Fec. vigencia", value: local!form.fecVigencia, saveInto: local!form.fecVigencia, required: false, characterLimit: 19, instructions: "Fecha de vigencia tal como la devuelve CORE (dd/MM/yyyy HH:mm:ss)"),
              a!textField(label: "Fec. modificado", value: local!form.fecModificado, saveInto: local!form.fecModificado, required: false, characterLimit: 19, instructions: "Fecha de modificación tal como la devuelve CORE (dd/MM/yyyy HH:mm:ss)"),
              a!textField(label: "Campaña", value: local!form.codIdCampana, saveInto: local!form.codIdCampana, required: false, characterLimit: 20, instructions: "Campaña (valor del concepto CAMP)"),
              a!textField(label: "Tipo bonif.", value: local!form.codTipBon, saveInto: local!form.codTipBon, required: false, characterLimit: 10, instructions: "Tipo de bonificación (TREBOLES, EUROS)"),
              a!textField(label: "Núm. bonif.", value: local!form.numTipBon, saveInto: local!form.numTipBon, required: false, characterLimit: 5, instructions: "Importe/número de la bonificación"),
              a!textField(label: "Regateable (S/N)", value: local!form.regateable, saveInto: local!form.regateable, required: false, characterLimit: 1, instructions: "Regateable S/N"),
              a!textField(label: "Te Cuidamos (S/N)", value: local!form.mcaTeCuidamos, saveInto: local!form.mcaTeCuidamos, required: false, characterLimit: 1, instructions: "Marca Te Cuidamos S/N"),
              a!integerField(label: "Días SGO", value: local!form.numDiasSgo, saveInto: local!form.numDiasSgo, required: false, instructions: "Días SGO"),
              a!textField(label: "Tarea SGO", value: local!form.codTareaSgo, saveInto: local!form.codTareaSgo, required: false, characterLimit: 20, instructions: "Tarea SGO"),
              a!textField(label: "URL", value: local!form.txtUrlArg, saveInto: local!form.txtUrlArg, required: false, characterLimit: 255, instructions: "URL del argumento"),
              a!textField(label: "Tréboles calc. (S/N)", value: local!form.mcaTrebCalc, saveInto: local!form.mcaTrebCalc, required: false, characterLimit: 1, instructions: "Marca tréboles calculados S/N"),
              a!integerField(label: "Orden", value: local!form.orden, saveInto: local!form.orden, required: false, instructions: "Posición en la respuesta del CORE (orden de presentación)")
              },
          equals: "CONCEPTO",
          then: {
              a!textField(label: "Id concepto" & " *", value: local!form.idnConceptoPca, saveInto: local!form.idnConceptoPca, required: true, characterLimit: 10, instructions: "Identificador del concepto en CORE"),
              a!textField(label: "Descripción", value: local!form.desConceptoPca, saveInto: local!form.desConceptoPca, required: false, characterLimit: 50, instructions: "Descripción del concepto"),
              a!textField(label: "Inhabilitado (S/N)", value: local!form.mcaInh, saveInto: local!form.mcaInh, required: false, characterLimit: 1, instructions: "Marca inhabilitado S/N"),
              a!dateField(label: "Fec. actualización", value: local!form.fecActu, saveInto: local!form.fecActu, instructions: "Fecha de actualización en CORE"),
              a!integerField(label: "Orden", value: local!form.orden, saveInto: local!form.orden, required: false, instructions: "Posición en la respuesta del CORE (orden de presentación)")
              },
          equals: "VALOR_CONCEPTO",
          then: {
              a!textField(label: "Id concepto" & " *", value: local!form.idnConceptoPca, saveInto: local!form.idnConceptoPca, required: true, characterLimit: 10, instructions: "Identificador del concepto padre"),
              a!textField(label: "Id valor" & " *", value: local!form.idnPca, saveInto: local!form.idnPca, required: true, characterLimit: 5, instructions: "Identificador del valor dentro del concepto"),
              a!textField(label: "Valor", value: local!form.valorConcepto, saveInto: local!form.valorConcepto, required: false, characterLimit: 255, instructions: "Valor"),
              a!textField(label: "Descripción", value: local!form.desConcepto, saveInto: local!form.desConcepto, required: false, characterLimit: 100, instructions: "Descripción del valor"),
              a!textField(label: "Inhabilitado (S/N)", value: local!form.mcaInh, saveInto: local!form.mcaInh, required: false, characterLimit: 1, instructions: "Marca inhabilitado S/N"),
              a!dateField(label: "Fec. actualización", value: local!form.fecActu, saveInto: local!form.fecActu, instructions: "Fecha de actualización en CORE"),
              a!integerField(label: "Orden", value: local!form.orden, saveInto: local!form.orden, required: false, instructions: "Posición en la respuesta del CORE (orden de presentación)")
              },
          default: {}
        )
            })
          }
        ),
        a!buttonArrayLayout(
          align: "START",
          buttons: {
            a!buttonWidget(label: "Guardar", style: "SOLID", icon: "save", submit: false,
              disabled: not(a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: and(a!isNotNullOrEmpty(local!form.codLineaNegocio), a!isNotNullOrEmpty(local!form.codPerfil), a!isNotNullOrEmpty(local!form.codSubPerfil), a!isNotNullOrEmpty(local!form.codMotivo)),
          equals: "DETALLE",
          then: and(a!isNotNullOrEmpty(local!form.codLineaNegocio), a!isNotNullOrEmpty(local!form.codMotivo), a!isNotNullOrEmpty(local!form.codDetalle)),
          equals: "CAUSA",
          then: and(a!isNotNullOrEmpty(local!form.codLineaNegocio), a!isNotNullOrEmpty(local!form.codMotivo), a!isNotNullOrEmpty(local!form.codDetalle), a!isNotNullOrEmpty(local!form.codPerfil), a!isNotNullOrEmpty(local!form.codCausa)),
          equals: "TIPO_ARGUMENTO",
          then: and(a!isNotNullOrEmpty(local!form.codTpArg)),
          equals: "CONCEPTO",
          then: and(a!isNotNullOrEmpty(local!form.idnConceptoPca)),
          equals: "VALOR_CONCEPTO",
          then: and(a!isNotNullOrEmpty(local!form.idnConceptoPca), a!isNotNullOrEmpty(local!form.idnPca)),
          default: {}
        )),
              saveInto: {
                a!save(local!duplicados, a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: a!queryRecordType(
                    recordType: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo',
                    fields: {'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id'},
                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                      a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio', operator: "=", value: tointeger(local!form.codLineaNegocio)),
                      a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil', operator: "=", value: trim(tostring(local!form.codPerfil))),
                      a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil', operator: "=", value: trim(tostring(local!form.codSubPerfil))),
                      a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo', operator: "=", value: trim(tostring(local!form.codMotivo))),
                      a!queryFilter(field: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id', operator: "<>", value: a!defaultValue(local!form.id, -1))
                    }),
                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                    fetchTotalCount: true
                  ).totalCount,
          equals: "DETALLE",
          then: a!queryRecordType(
                    recordType: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle',
                    fields: {'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id'},
                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                      a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio', operator: "=", value: tointeger(local!form.codLineaNegocio)),
                      a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo', operator: "=", value: trim(tostring(local!form.codMotivo))),
                      a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle', operator: "=", value: trim(tostring(local!form.codDetalle))),
                      a!queryFilter(field: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id', operator: "<>", value: a!defaultValue(local!form.id, -1))
                    }),
                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                    fetchTotalCount: true
                  ).totalCount,
          equals: "CAUSA",
          then: a!queryRecordType(
                    recordType: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa',
                    fields: {'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id'},
                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                      a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio', operator: "=", value: tointeger(local!form.codLineaNegocio)),
                      a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo', operator: "=", value: trim(tostring(local!form.codMotivo))),
                      a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle', operator: "=", value: trim(tostring(local!form.codDetalle))),
                      a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil', operator: "=", value: trim(tostring(local!form.codPerfil))),
                      a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa', operator: "=", value: trim(tostring(local!form.codCausa))),
                      a!queryFilter(field: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id', operator: "<>", value: a!defaultValue(local!form.id, -1))
                    }),
                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                    fetchTotalCount: true
                  ).totalCount,
          equals: "TIPO_ARGUMENTO",
          then: a!queryRecordType(
                    recordType: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento',
                    fields: {'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id'},
                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                      a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg', operator: "=", value: trim(tostring(local!form.codTpArg))),
                      a!queryFilter(field: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id', operator: "<>", value: a!defaultValue(local!form.id, -1))
                    }),
                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                    fetchTotalCount: true
                  ).totalCount,
          equals: "CONCEPTO",
          then: a!queryRecordType(
                    recordType: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto',
                    fields: {'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id'},
                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                      a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', operator: "=", value: trim(tostring(local!form.idnConceptoPca))),
                      a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', operator: "<>", value: a!defaultValue(local!form.id, -1))
                    }),
                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                    fetchTotalCount: true
                  ).totalCount,
          equals: "VALOR_CONCEPTO",
          then: a!queryRecordType(
                    recordType: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto',
                    fields: {'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id'},
                    filters: a!queryLogicalExpression(operator: "AND", filters: {
                      a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca', operator: "=", value: trim(tostring(local!form.idnConceptoPca))),
                      a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca', operator: "=", value: trim(tostring(local!form.idnPca))),
                      a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id', operator: "<>", value: a!defaultValue(local!form.id, -1))
                    }),
                    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                    fetchTotalCount: true
                  ).totalCount,
          default: {}
        )),
                if(
                  local!duplicados > 0,
                  {a!save(local!tipoMensaje, "NEGATIVE"), a!save(local!mensaje, "Ya existe una fila con esa misma clave en este catálogo: no se guarda.")},
                  a!writeRecords(
                    records: a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo'(
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id': local!form.id,
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{d921b067-668c-43bd-8bae-794e4aa500c8}codLineaNegocio': if(a!isNullOrEmpty(local!form.codLineaNegocio), null, tointeger(local!form.codLineaNegocio)),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{afb004b8-547d-46d1-b83e-fd7d31fbc799}codPerfil': if(a!isNullOrEmpty(local!form.codPerfil), null, trim(tostring(local!form.codPerfil))),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{660d5d41-f7f3-4f36-abcd-12420c4ae4eb}codSubPerfil': if(a!isNullOrEmpty(local!form.codSubPerfil), null, trim(tostring(local!form.codSubPerfil))),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{16dfb5b2-3427-424f-8c09-9113c31958b8}codMotivo': if(a!isNullOrEmpty(local!form.codMotivo), null, trim(tostring(local!form.codMotivo))),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{c01a0e40-3713-49c1-aa0f-ceaa16a92e2b}descripcion': if(a!isNullOrEmpty(local!form.descripcion), null, trim(tostring(local!form.descripcion))),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{8af8e425-be9f-425e-b5a2-cfc616bcba1f}orden': if(a!isNullOrEmpty(local!form.orden), null, tointeger(local!form.orden)),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo': a!defaultValue(local!form.activo, true),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{300c04da-0af1-45db-9f10-9fdc5e7d9af1}origen': if(a!isNullOrEmpty(local!form.id), "MANUAL", a!defaultValue(local!form.origen, "MANUAL")),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{903c3810-4491-4d87-9fe6-4b40a22a1bb3}fechaAlta': if(a!isNullOrEmpty(local!form.id), now(), local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{903c3810-4491-4d87-9fe6-4b40a22a1bb3}fechaAlta']),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion': now(),
                  'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{90f6ec37-4193-4e82-8012-b8d2e5b5a18e}usuarioModificacion': user(loggedInUser(), "username")
                ),
          equals: "DETALLE",
          then: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle'(
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id': local!form.id,
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{40991f2d-7729-4c57-8dc0-d8ac6bf9eda6}codLineaNegocio': if(a!isNullOrEmpty(local!form.codLineaNegocio), null, tointeger(local!form.codLineaNegocio)),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d0a6c364-be53-4499-ad61-8c5c80b8fb7b}codMotivo': if(a!isNullOrEmpty(local!form.codMotivo), null, trim(tostring(local!form.codMotivo))),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{9acc8291-028e-43c2-b2d4-f743e9d276c0}codDetalle': if(a!isNullOrEmpty(local!form.codDetalle), null, trim(tostring(local!form.codDetalle))),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{a3b03d72-e17b-48e1-8958-6e8c053b6056}descripcion': if(a!isNullOrEmpty(local!form.descripcion), null, trim(tostring(local!form.descripcion))),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{8267d5dc-2ba0-49c6-885e-0d3dab351f71}orden': if(a!isNullOrEmpty(local!form.orden), null, tointeger(local!form.orden)),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo': a!defaultValue(local!form.activo, true),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{538a3e95-301f-429e-90c8-332e2e298160}origen': if(a!isNullOrEmpty(local!form.id), "MANUAL", a!defaultValue(local!form.origen, "MANUAL")),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d980d776-17d4-4236-8724-5612547ac669}fechaAlta': if(a!isNullOrEmpty(local!form.id), now(), local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{d980d776-17d4-4236-8724-5612547ac669}fechaAlta']),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion': now(),
                  'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{488228af-08b5-4df1-a7fd-0a8f08947f3b}usuarioModificacion': user(loggedInUser(), "username")
                ),
          equals: "CAUSA",
          then: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa'(
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id': local!form.id,
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a12921e3-e72a-4041-a1b6-9db2a0599c3d}codLineaNegocio': if(a!isNullOrEmpty(local!form.codLineaNegocio), null, tointeger(local!form.codLineaNegocio)),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{b0eacf17-e66c-4818-9ebe-3049fd08df40}codMotivo': if(a!isNullOrEmpty(local!form.codMotivo), null, trim(tostring(local!form.codMotivo))),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{650c3bb4-f290-4fd2-9e4c-e7a906cdced9}codDetalle': if(a!isNullOrEmpty(local!form.codDetalle), null, trim(tostring(local!form.codDetalle))),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{69a0bdd8-b9a8-4b9a-a796-cade679da3ce}codPerfil': if(a!isNullOrEmpty(local!form.codPerfil), null, trim(tostring(local!form.codPerfil))),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ddcd11d0-0177-4680-9ddc-78855ae9f53d}codCausa': if(a!isNullOrEmpty(local!form.codCausa), null, trim(tostring(local!form.codCausa))),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2c1db12-da25-4198-822d-17568aeb5bf1}descripcion': if(a!isNullOrEmpty(local!form.descripcion), null, trim(tostring(local!form.descripcion))),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{36ba7add-3b88-4ef3-a206-3340bce4c0c8}orden': if(a!isNullOrEmpty(local!form.orden), null, tointeger(local!form.orden)),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo': a!defaultValue(local!form.activo, true),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{a2cc8d76-d7f9-486e-88f2-45fbef81daeb}origen': if(a!isNullOrEmpty(local!form.id), "MANUAL", a!defaultValue(local!form.origen, "MANUAL")),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ae77f839-09fa-4aa5-9142-5dc00942c6dc}fechaAlta': if(a!isNullOrEmpty(local!form.id), now(), local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{ae77f839-09fa-4aa5-9142-5dc00942c6dc}fechaAlta']),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion': now(),
                  'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{045605ef-fabe-4f9a-b819-6b4d412ba81d}usuarioModificacion': user(loggedInUser(), "username")
                ),
          equals: "TIPO_ARGUMENTO",
          then: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento'(
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id': local!form.id,
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f64fe1b5-b44f-4f83-9ce4-ba41f3272a52}codTpArg': if(a!isNullOrEmpty(local!form.codTpArg), null, trim(tostring(local!form.codTpArg))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{68228ed1-7b66-4f86-9308-03ecf912dcb4}descArg': if(a!isNullOrEmpty(local!form.descArg), null, trim(tostring(local!form.descArg))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{368a9935-e09a-4056-a979-55b424c21455}codEstado': if(a!isNullOrEmpty(local!form.codEstado), null, trim(tostring(local!form.codEstado))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e916ded6-444a-4d96-b1d7-6e22fdd66f9e}idLineaNegocio': if(a!isNullOrEmpty(local!form.idLineaNegocio), null, trim(tostring(local!form.idLineaNegocio))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{fb436615-697f-4422-b44c-e882af8538cf}idRamo': if(a!isNullOrEmpty(local!form.idRamo), null, tointeger(local!form.idRamo)),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{906e17d2-6926-4120-9273-b798b5ba07b6}codCompania': if(a!isNullOrEmpty(local!form.codCompania), null, tointeger(local!form.codCompania)),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{e4d5439f-48ba-4d1b-8b9d-bf81426e2791}codCompaniaArg': if(a!isNullOrEmpty(local!form.codCompaniaArg), null, tointeger(local!form.codCompaniaArg)),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{4ce9a69e-6168-4068-821d-c1869f5dd9df}apliArgumento': if(a!isNullOrEmpty(local!form.apliArgumento), null, trim(tostring(local!form.apliArgumento))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{10eebac0-1b6f-49b7-8a7b-34a6cca818dd}instruccion': if(a!isNullOrEmpty(local!form.instruccion), null, trim(tostring(local!form.instruccion))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2fa460dd-9899-481b-835e-ca82f54b60f8}mcaFinalizado': if(a!isNullOrEmpty(local!form.mcaFinalizado), null, trim(tostring(local!form.mcaFinalizado))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{78444ddc-daec-4a08-9d2b-20d2aaa75dd8}nombreDoc': if(a!isNullOrEmpty(local!form.nombreDoc), null, trim(tostring(local!form.nombreDoc))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f6c6a2a5-8849-481a-b5c3-44bee5a997a2}numDoc': if(a!isNullOrEmpty(local!form.numDoc), null, trim(tostring(local!form.numDoc))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{dad5b78b-b4c6-44d3-ad91-84a45b90d232}observaciones': if(a!isNullOrEmpty(local!form.observaciones), null, trim(tostring(local!form.observaciones))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{813dfd30-eba2-4592-a967-e05404d11479}fecVigencia': if(a!isNullOrEmpty(local!form.fecVigencia), null, trim(tostring(local!form.fecVigencia))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{cc243a1e-b376-4b04-afb6-f511565bc003}fecModificado': if(a!isNullOrEmpty(local!form.fecModificado), null, trim(tostring(local!form.fecModificado))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{67dbd622-ead4-4f4c-a212-fa7ecbc42192}codIdCampana': if(a!isNullOrEmpty(local!form.codIdCampana), null, trim(tostring(local!form.codIdCampana))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{95cbe6b0-0408-468b-ab29-8972c9101e1f}codTipBon': if(a!isNullOrEmpty(local!form.codTipBon), null, trim(tostring(local!form.codTipBon))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f949c78c-b815-4be6-9ccc-052edd6111af}numTipBon': if(a!isNullOrEmpty(local!form.numTipBon), null, trim(tostring(local!form.numTipBon))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{84deea8e-1971-4f57-8066-a04e8cafb897}regateable': if(a!isNullOrEmpty(local!form.regateable), null, trim(tostring(local!form.regateable))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{d3232165-9020-4a97-ad0e-f5949d0667e3}mcaTeCuidamos': if(a!isNullOrEmpty(local!form.mcaTeCuidamos), null, trim(tostring(local!form.mcaTeCuidamos))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{f7c00942-fcb3-4a18-b2c2-9d77b20b862c}numDiasSgo': if(a!isNullOrEmpty(local!form.numDiasSgo), null, tointeger(local!form.numDiasSgo)),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{a101503b-ad0e-4b70-b124-5045c63b83de}codTareaSgo': if(a!isNullOrEmpty(local!form.codTareaSgo), null, trim(tostring(local!form.codTareaSgo))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2464a951-ed14-4e6f-a6a0-bb7d12c02ca9}txtUrlArg': if(a!isNullOrEmpty(local!form.txtUrlArg), null, trim(tostring(local!form.txtUrlArg))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{7e25b67d-5943-4e84-b32e-dd19c782bf9c}mcaTrebCalc': if(a!isNullOrEmpty(local!form.mcaTrebCalc), null, trim(tostring(local!form.mcaTrebCalc))),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{458c6cdb-d3ed-4a6e-ad6e-2c231a17a2c5}orden': if(a!isNullOrEmpty(local!form.orden), null, tointeger(local!form.orden)),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo': a!defaultValue(local!form.activo, true),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{13c67d10-26e3-4aad-b830-a83d66869256}origen': if(a!isNullOrEmpty(local!form.id), "MANUAL", a!defaultValue(local!form.origen, "MANUAL")),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2e399b24-37fe-4988-a915-3d73b41b9dfd}fechaAlta': if(a!isNullOrEmpty(local!form.id), now(), local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{2e399b24-37fe-4988-a915-3d73b41b9dfd}fechaAlta']),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion': now(),
                  'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{35086732-fb4d-4e6d-a8e0-9a24dd8ac457}usuarioModificacion': user(loggedInUser(), "username")
                ),
          equals: "CONCEPTO",
          then: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto'(
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id': local!form.id,
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca': if(a!isNullOrEmpty(local!form.idnConceptoPca), null, trim(tostring(local!form.idnConceptoPca))),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca': if(a!isNullOrEmpty(local!form.desConceptoPca), null, trim(tostring(local!form.desConceptoPca))),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh': if(a!isNullOrEmpty(local!form.mcaInh), null, trim(tostring(local!form.mcaInh))),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu': local!form.fecActu,
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden': if(a!isNullOrEmpty(local!form.orden), null, tointeger(local!form.orden)),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo': a!defaultValue(local!form.activo, true),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen': if(a!isNullOrEmpty(local!form.id), "MANUAL", a!defaultValue(local!form.origen, "MANUAL")),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta': if(a!isNullOrEmpty(local!form.id), now(), local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta']),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion': now(),
                  'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion': user(loggedInUser(), "username")
                ),
          equals: "VALOR_CONCEPTO",
          then: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto'(
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id': local!form.id,
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca': if(a!isNullOrEmpty(local!form.idnConceptoPca), null, trim(tostring(local!form.idnConceptoPca))),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca': if(a!isNullOrEmpty(local!form.idnPca), null, trim(tostring(local!form.idnPca))),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto': if(a!isNullOrEmpty(local!form.valorConcepto), null, trim(tostring(local!form.valorConcepto))),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto': if(a!isNullOrEmpty(local!form.desConcepto), null, trim(tostring(local!form.desConcepto))),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh': if(a!isNullOrEmpty(local!form.mcaInh), null, trim(tostring(local!form.mcaInh))),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu': local!form.fecActu,
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden': if(a!isNullOrEmpty(local!form.orden), null, tointeger(local!form.orden)),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo': a!defaultValue(local!form.activo, true),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen': if(a!isNullOrEmpty(local!form.id), "MANUAL", a!defaultValue(local!form.origen, "MANUAL")),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{6bffd08a-a36f-4656-b3c0-82725b43a8a3}fechaAlta': if(a!isNullOrEmpty(local!form.id), now(), local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{6bffd08a-a36f-4656-b3c0-82725b43a8a3}fechaAlta']),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion': now(),
                  'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{bd11a237-199f-41e7-9c3d-e9550a0a009b}usuarioModificacion': user(loggedInUser(), "username")
                ),
          default: {}
        ),
                    onSuccess: {a!save(local!tipoMensaje, "POSITIVE"), a!save(local!mensaje, "Guardado."), a!save(local!sel, null), a!save(local!form, null), a!save(local!refresco, local!refresco + 1)},
                    onError: {a!save(local!tipoMensaje, "NEGATIVE"), a!save(local!mensaje, "No se ha podido guardar: " & tostring(fv!error))}
                  )
                )
              }),
            a!buttonWidget(label: if(a!defaultValue(local!form.activo, true), "Dar de baja", "Reactivar"), style: "OUTLINE", icon: if(a!defaultValue(local!form.activo, true), "ban", "check"),
              showWhen: a!isNotNullOrEmpty(local!form.id),
              confirmMessage: if(a!defaultValue(local!form.activo, true), "La fila dejará de devolverse a las pantallas (baja lógica, no se borra). ¿Continuar?", "La fila volverá a devolverse a las pantallas. ¿Continuar?"),
              saveInto: a!writeRecords(
                records: a!match(
          value: local!catalogo,
          equals: "MOTIVO",
          then: 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo'('recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id': local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{9a1c0090-aa42-48b4-8253-8be1643e2f6b}id'], 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo': not(a!defaultValue(local!sel['recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{5d23d245-e05a-4e66-abb8-5838e0d739b8}activo'], false)), 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{1205e0cb-dfa7-4ec3-9141-35304f1d3061}fechaModificacion': now(), 'recordType!{40727673-e6c7-46f4-b647-7c98ac09163a}SCA2 Cat Motivo.fields.{90f6ec37-4193-4e82-8012-b8d2e5b5a18e}usuarioModificacion': user(loggedInUser(), "username")),
          equals: "DETALLE",
          then: 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle'('recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id': local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{cad7c6d2-6e3f-4cdc-a8e1-1f3989851db9}id'], 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo': not(a!defaultValue(local!sel['recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{4415dc04-e0e4-4f48-8a75-43f862d37122}activo'], false)), 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{09858628-eb32-4c4e-b015-8e520b16af94}fechaModificacion': now(), 'recordType!{433c6bd0-8a5b-461f-9056-ddd37ffbf00b}SCA2 Cat Detalle.fields.{488228af-08b5-4df1-a7fd-0a8f08947f3b}usuarioModificacion': user(loggedInUser(), "username")),
          equals: "CAUSA",
          then: 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa'('recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id': local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{2d35a657-f164-4436-93dc-de680618f389}id'], 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo': not(a!defaultValue(local!sel['recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{8e81dca0-038f-4920-85b9-1b88ef86499b}activo'], false)), 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{52b026e4-4153-4985-8856-36b365ebcc7f}fechaModificacion': now(), 'recordType!{a055e578-6ddb-4397-bad1-1ae361a38e56}SCA2 Cat Causa.fields.{045605ef-fabe-4f9a-b819-6b4d412ba81d}usuarioModificacion': user(loggedInUser(), "username")),
          equals: "TIPO_ARGUMENTO",
          then: 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento'('recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id': local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{75b6e975-fe67-44df-a8db-aad456869775}id'], 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo': not(a!defaultValue(local!sel['recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{bffabdb9-dfc2-4b44-ba5d-f2bc81139496}activo'], false)), 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{05da74f9-b095-42a4-9505-0ab57a2aa1f0}fechaModificacion': now(), 'recordType!{dc54d386-8cd9-4369-818a-13a5dc54d0ea}SCA2 Cat Tipo Argumento.fields.{35086732-fb4d-4e6d-a8e0-9a24dd8ac457}usuarioModificacion': user(loggedInUser(), "username")),
          equals: "CONCEPTO",
          then: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto'('recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id': local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id'], 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo': not(a!defaultValue(local!sel['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo'], false)), 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion': now(), 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion': user(loggedInUser(), "username")),
          equals: "VALOR_CONCEPTO",
          then: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto'('recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id': local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id'], 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo': not(a!defaultValue(local!sel['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo'], false)), 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion': now(), 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{bd11a237-199f-41e7-9c3d-e9550a0a009b}usuarioModificacion': user(loggedInUser(), "username")),
          default: {}
        ),
                onSuccess: {a!save(local!tipoMensaje, "POSITIVE"), a!save(local!mensaje, if(a!defaultValue(local!form.activo, true), "Fila dada de baja.", "Fila reactivada.")), a!save(local!sel, null), a!save(local!form, null), a!save(local!refresco, local!refresco + 1)},
                onError: {a!save(local!tipoMensaje, "NEGATIVE"), a!save(local!mensaje, "No se ha podido actualizar: " & tostring(fv!error))}
              )),
            a!buttonWidget(label: "Cancelar", style: "LINK", saveInto: {a!save(local!sel, null), a!save(local!form, null), a!save(local!mensaje, null)})
          }
        )
      }
    )
  }
)