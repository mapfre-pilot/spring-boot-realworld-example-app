a!localVariables(
  local!hoy: today(),
  a!queryRecordType(
    recordType: 'recordType!{731137c0-0e74-4f8e-ab0d-870e2980e9e8}SCA2 Cola Reserva Prima',
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
