/* R53: true solo si el valor es el centinela de rule!SCA2_valorCoreNoDisponible (CORE no ha respondido). Para cualquier otro valor, false. */
if(
  typename(typeof(ri!valor)) = "Map",
  a!defaultValue(toboolean(index(ri!valor, "coreNoDisponible", false)), false),
  false
)
