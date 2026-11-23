a!localVariables(
  local!hechas: a!queryRecordType(
    recordType: 'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima',
    fields: {'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{35adefad-93ec-46f4-badf-8dd7f30c6943}solicitudAnulacion'},
    filters: a!queryFilter(
      field: 'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{14b36308-17b3-45f9-9c7f-0b193df8ff5c}ejecutado',
      operator: "=",
      value: text(today(), "dd/mm/yyyy")
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 5000)
  ).data,
  a!map(
    ejecutadas: length(local!hechas),
    solicitudes: local!hechas['recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima.fields.{35adefad-93ec-46f4-badf-8dd7f30c6943}solicitudAnulacion']
  )
)
