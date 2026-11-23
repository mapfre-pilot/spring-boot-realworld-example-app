a!localVariables(
  local!hoy: today(),
  a!queryRecordType(
    recordType: 'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima',
    fields: {
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{4619bae7-bfa7-42f8-bae5-c0fb4bb3b772}id',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{35adefad-93ec-46f4-badf-8dd7f30c6943}solicitudAnulacion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{d15fda8e-3cc3-4a01-b893-3c2e11842b6c}codGestion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{d2e5352f-93d2-44b2-960a-ddb37ad70e6b}tipoGestion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{f604affe-e652-4738-b14f-d5d8401bf997}tipoAccion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{17069919-203b-40b9-9b02-109762bf0cf8}codAnulacion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{7cd3a8aa-2803-4cc7-a857-fb1b445f3e88}nif',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{3323009d-139a-49a5-af4c-edd8dba85b63}nivelIntervencion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{860c0de4-4b21-4859-ba91-9a84ec7c087d}datosContraanulacion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{a6a25645-5462-468e-8b25-5dcaf621cb59}fechaEjecucion',
      'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{14b36308-17b3-45f9-9c7f-0b193df8ff5c}ejecutado'
    },
    filters: {
      a!queryFilter(
        field: 'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{a6a25645-5462-468e-8b25-5dcaf621cb59}fechaEjecucion',
        operator: "<=",
        value: datetime(year(local!hoy), month(local!hoy), day(local!hoy))
      ),
      a!queryFilter(
        field: 'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{14b36308-17b3-45f9-9c7f-0b193df8ff5c}ejecutado',
        operator: "is null"
      )
    },
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 30)
  ).data
)
