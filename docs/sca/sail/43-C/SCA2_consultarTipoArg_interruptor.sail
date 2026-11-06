=/* [SCA2] Fase 1 (catálogos CORE en Aurora): misma firma y misma salida que antes.
   cons!SCA2_USAR_CATALOGOS_AURORA = false → llamada SOAP a CORE de siempre (SCA2_consultarTipoArgCore, copia exacta del SAIL original v5).
   cons!SCA2_USAR_CATALOGOS_AURORA = true  → lectura del record SCA2 Cat * (SCA2_catTiposArgAurora); si el record no devuelve nada, fallback a la SOAP. */
if(
  a!defaultValue(cons!SCA2_USAR_CATALOGOS_AURORA, false),
  a!localVariables(
    local!aurora: rule!SCA2_catTiposArgAurora(mseConsultarTipoArgDTO: ri!mseConsultarTipoArgDTO),
    if(
      a!isNullOrEmpty(local!aurora),
      rule!SCA2_consultarTipoArgCore(mseConsultarTipoArgDTO: ri!mseConsultarTipoArgDTO),
      local!aurora
    )
  ),
  rule!SCA2_consultarTipoArgCore(mseConsultarTipoArgDTO: ri!mseConsultarTipoArgDTO)
)