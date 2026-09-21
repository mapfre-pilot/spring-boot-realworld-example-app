/* Devuelve la SMK Ejecucion con id = ri!ejecucionId (lista vacía si no existe). */
if(
  a!isNullOrEmpty(ri!ejecucionId),
  {},
  a!queryRecordType(
    recordType: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion',
    fields: {
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1e84e153-8cd3-492b-9b7f-3c97575a75e5}fechaInicio',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1bcfff8e-df5c-4bcf-be02-110148d4d995}fechaFin',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4215f124-b13e-4aab-a280-50ebcff87ab8}estado',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{1a5bd16b-1600-4449-9b6c-acf1abb1a5af}origen',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6}motivo',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{541ebf63-f4c4-4892-a696-265d622c55fc}lanzadoPor',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e01d8d88-4458-4cad-8812-d58fb66d43bb}totalPruebas',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{7b2b1ba6-9f90-4046-9e3f-bba4ff192345}totalOk',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e184f153-2a40-46a3-9d6e-654fa1923e89}totalKo',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{9f2e3659-99d3-4ffe-9112-429eca4743e0}totalWarn',
      'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{e3bf3113-5265-4932-8306-4043885eec95}duracionMs'
    },
    filters: a!queryFilter(
      field: 'recordType!{e0fef5cc-80d6-491b-b74b-71d623d7a0ec}SMK Ejecucion.fields.{4a743dda-a9e3-46c9-8bc3-2826f9586ce1}id',
      operator: "=",
      value: ri!ejecucionId
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
    fetchTotalCount: false
  ).data
)
