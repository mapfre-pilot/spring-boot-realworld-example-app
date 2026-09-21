/* Devuelve SMK Programaciones. ri!id: una programación concreta (prioridad). ri!estados: filtra por estado (PENDIENTE|LANZADA|CANCELADA); vacío = todas.
   Orden: pendientes por fecha programada ascendente; el resto por fecha programada descendente. */
a!localVariables(
  local!estados: a!defaultValue(ri!estados, {}),
  local!soloPendientes: and(count(local!estados) = 1, local!estados[1] = "PENDIENTE"),
  a!queryRecordType(
    recordType: 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion',
    fields: {
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{798cdcc5-071f-4872-9997-5a17b1a6124a}id',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{c6ba445d-a508-4c70-a626-e6c4a7e804be}modo',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{9ed6819f-a42d-4c2c-9461-d076d57fc391}codigos',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{a0cf551c-172f-4e01-b09f-3246bb70169f}categorias',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{c43f5b47-1255-4001-9247-1c632350ec97}sistemas',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{3fab4644-0a96-437a-8f1b-48744d5da6d4}numPruebas',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{90095155-8d17-46d8-9cba-95f6be4c0beb}motivo',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{89356b5f-9992-4548-8d58-82f8d924574a}origen',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{1202dd4f-496d-4462-a54f-ec133ff6d940}creadoPor',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{d866a44f-0e71-4260-9fcf-50c537fed215}fechaCreacion',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{fdeeb26b-143e-46eb-8452-08ea35205331}procesoId',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{9b2af594-6312-4940-933a-6bdc464217ef}ejecucionId',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{9432966e-1991-4fe3-b49e-9e159f39cfaf}fechaLanzamiento',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{85123178-7b55-4299-886d-04d4293e59fa}canceladoPor',
      'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{1e919401-8cb7-4463-b272-8755ed19f628}fechaCancelacion'
    },
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        a!queryFilter(
          field: 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{798cdcc5-071f-4872-9997-5a17b1a6124a}id',
          operator: "=",
          value: ri!id,
          applyWhen: a!isNotNullOrEmpty(ri!id)
        ),
        a!queryFilter(
          field: 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{56e7aa5c-8bfe-494e-ba68-de5e1828388f}estado',
          operator: "in",
          value: local!estados,
          applyWhen: a!isNotNullOrEmpty(local!estados)
        )
      },
      ignoreFiltersWithEmptyValues: true
    ),
    pagingInfo: a!pagingInfo(
      startIndex: 1,
      batchSize: if(a!isNullOrEmpty(ri!id), a!defaultValue(ri!batchSize, 200), 1),
      sort: a!sortInfo(
        field: 'recordType!{7e501b5f-6715-46e2-976a-092858c8bdc8}SMK Programacion.fields.{abf0f0a4-17fa-4de6-8aeb-b5c85e35b646}fechaProgramada',
        ascending: local!soloPendientes
      )
    ),
    fetchTotalCount: false
  ).data
)
