/* [SCA2] Lectura del catálogo de CONCEPTOS PCA desde Aurora (records SCA2 Cat Concepto / SCA2 Cat Valor Concepto) con la misma salida que SCA2_consultarConceptoCore (consultarConceptoResponse).
   tipoBusqueda "0": cabecera de conceptos (como CORE: sin valores, sin mcaInh ni fecActu). tipoBusqueda "1" + idConcepto: el concepto con sus valores ordenados.
   Otros casos o sin filas → NULL (fallback a la SOAP). Fase 1, sesión C. */
a!localVariables(
  local!tipoBusqueda: tostring(a!defaultValue(index(ri!mseConsultarConceptoDTO, "tipoBusqueda", ""), "")),
  local!idConcepto: tostring(a!defaultValue(index(ri!mseConsultarConceptoDTO, "idConcepto", ""), "")),
  local!conceptos: if(
    local!tipoBusqueda = "0",
    a!queryRecordType(
      recordType: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto',
      fields: {'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', operator: "not null")
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', ascending: true), a!sortInfo(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', ascending: true)}),
      fetchTotalCount: false
    ).data,
    if(
      and(local!tipoBusqueda = "1", a!isNotNullOrEmpty(local!idConcepto)),
      a!queryRecordType(
      recordType: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto',
      fields: {'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{1a5c9ce7-9968-4036-834b-1a2bcccfbe23}origen', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{11676b73-eaec-46a1-8655-5b18ad9ba5b1}fechaAlta', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{86ee2f00-a74e-40c8-a851-534d85dc26b9}fechaModificacion', 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{9cb837b8-a41b-41ff-9d0f-03849aec7d97}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{f1a406bc-0de4-431f-9784-29def178db39}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca', operator: "=", value: local!idConcepto)
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{b3cf160b-02a4-4460-a51c-e92fbaf0d535}orden', ascending: true), a!sortInfo(field: 'recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{fa8f99e9-b6cc-46bf-93f6-945136cb3ab8}id', ascending: true)}),
      fetchTotalCount: false
    ).data,
      {}
    )
  ),
  local!valores: if(
    and(local!tipoBusqueda = "1", a!isNotNullOrEmpty(local!conceptos)),
    a!queryRecordType(
      recordType: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto',
      fields: {'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{d3eaef14-da1c-4f63-9813-ad066c563081}origen', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{6bffd08a-a36f-4656-b3c0-82725b43a8a3}fechaAlta', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{4615a463-74b1-43d3-b3fc-ee066e523085}fechaModificacion', 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{bd11a237-199f-41e7-9c3d-e9550a0a009b}usuarioModificacion'},
      filters: a!queryLogicalExpression(
        operator: "AND",
        filters: {
          a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{b453422f-1344-46e9-b354-9feb8850f743}activo', operator: "=", value: true),
          a!queryFilter(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca', operator: "=", value: local!idConcepto)
        },
        ignoreFiltersWithEmptyValues: false
      ),
      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000, sort: {a!sortInfo(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f16c9d61-9b71-4a9a-a81f-25307e133b17}orden', ascending: true), a!sortInfo(field: 'recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{2459e0fa-8121-41ef-b485-7f317a6d79a5}id', ascending: true)}),
      fetchTotalCount: false
    ).data,
    {}
  ),
  if(
    a!isNullOrEmpty(local!conceptos),
    null,
    'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}consultarConceptoResponse'(
      MSSConsultarConcepto: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mssConsultarConceptoDTO'(
        listadoConceptos: a!forEach(
          items: local!conceptos,
          expression: if(
            local!tipoBusqueda = "0",
            'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}conceptoDTO'(idnConceptoPca: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca'], desConceptoPca: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca']),
            'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}conceptoDTO'(
              idnConceptoPca: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{22f9819c-22e7-4caf-b5c1-a1551fcb0ad6}idnConceptoPca'],
              desConceptoPca: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{4b0b4526-07ca-4581-8740-883c82bd67c7}desConceptoPca'],
              mcaInh: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{a2de871d-2d2d-4c0b-9888-d02b477f1ef2}mcaInh'],
              fecActu: fv!item['recordType!{ff259e4f-7a2a-4690-b4bf-011b68ce4dc7}SCA2 Cat Concepto.fields.{7410a601-01a1-4ecf-ae6d-7a7358da3547}fecActu'],
              valoresConcepto: a!forEach(
                items: local!valores,
                expression: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}valorConceptoDTO'(idnPca: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{1800cc74-5621-46f5-9a32-71e4a6c0a83a}idnPca'], idnConceptoPca: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{11a05b6a-eb54-4dc0-8ace-3b5bf7e878e1}idnConceptoPca'], valorConcepto: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{f8066703-1612-45e5-8832-22aa2f0d422d}valorConcepto'], desConcepto: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{e7bf6556-d670-4821-bbb0-5c832506e893}desConcepto'], mcaInh: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{0a4aa819-7769-4233-b60d-2417051f0f40}mcaInh'], fecActu: fv!item['recordType!{774549b5-8a4a-4a4b-aeb8-f2960360ff18}SCA2 Cat Valor Concepto.fields.{7f703eb7-df12-40c8-88b6-b133b172eff4}fecActu'])
              )
            )
          )
        )
      )
    )
  )
)