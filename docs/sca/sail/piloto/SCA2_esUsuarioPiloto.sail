/* Indica si el gestor (nuuma) da de alta solicitudes nuevas en SCA2.
   true sólo si el interruptor SCA2_BOOL_PILOTO_ACTIVO está activo y el usuario pertenece a SCA2 Piloto. */
a!localVariables(
  local!nuuma: upper(trim(index(split(trim(ri!nuuma), "@"), 1, ""))),
  local!usuario: if(a!isNullOrEmpty(local!nuuma), null, local!nuuma & cons!SCA2_USERS_DOMAIN),
  if(
    not(cons!SCA2_BOOL_PILOTO_ACTIVO),
    false,
    if(
      a!isNullOrEmpty(local!usuario),
      false,
      if(
        isusernametaken(local!usuario),
        a!isUserMemberOfGroup(local!usuario, cons!SCA2_GRP_PILOTO),
        false
      )
    )
  )
)
