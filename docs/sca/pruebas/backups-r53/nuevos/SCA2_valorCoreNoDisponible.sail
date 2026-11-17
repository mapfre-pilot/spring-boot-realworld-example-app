/* R53: valor que devuelven las reglas SCA2 que llaman a CORE cuando CORE no responde (respuesta nula). Se detecta con rule!SCA2_esCoreNoDisponible. */
a!map(
  coreNoDisponible: true,
  mensaje: cons!SCA2_TXT_CORE_NO_DISPONIBLE
)
