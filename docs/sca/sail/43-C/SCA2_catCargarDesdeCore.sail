/* [SCA2] Carga (upsert) un catálogo CORE en Aurora: escribe con a!writeRecords las filas que construye SCA2_catConstruirCarga.
   ri!catalogo: MOTIVO | DETALLE | CAUSA | TIPO_ARGUMENTO | CONCEPTO | VALOR_CONCEPTO. Orden recomendado: MOTIVO, DETALLE, CAUSA, TIPO_ARGUMENTO, CONCEPTO, VALOR_CONCEPTO.
   Re-ejecutable (idempotente): no borra filas, no pisa las de origen MANUAL. Se lanza desde «Recargar desde CORE» de la página de mantenimiento de catálogos o con POST /expression-rules/{uuid}/test.
   Devuelve a!map(catalogo, filasCore, existentesAntes, manualesRespetadas, bajas, escritas, error). */
a!localVariables(
  local!carga: rule!SCA2_catConstruirCarga(catalogo: ri!catalogo),
  local!registros: a!defaultValue(index(local!carga, "registros", {}), {}),
  if(
    a!isNullOrEmpty(local!registros),
    a!update(local!carga, {"escritas", "error"}, {0, if(a!isNullOrEmpty(index(local!carga, "error", null)), "CORE no ha devuelto filas: no se escribe nada", index(local!carga, "error", null))}),
    a!writeRecords(
      records: local!registros,
      onSuccess: a!update(local!carga, {"escritas", "error"}, {count(fv!recordsUpdated), null}),
      onError: a!update(local!carga, {"escritas", "error"}, {0, tostring(fv!error)})
    )
  )
)