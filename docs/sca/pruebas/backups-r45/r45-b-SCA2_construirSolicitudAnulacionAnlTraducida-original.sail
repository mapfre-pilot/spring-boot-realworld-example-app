a!localVariables(
  local!s: rule!SCA2_construirSolicitudAnulacionAnl(idSolicitud: ri!idSolicitud),
  local!dcs: index(local!s, "datosCompletosSolicitud", null),
  local!ds: index(local!dcs, "datosSolicitud", null),
  local!motivo: index(local!ds, "codMotivo", null),
  local!detalle: index(local!ds, "codDetalle", null),
  local!causa: index(local!ds, "codCausa", null),
  local!cia: index(index(local!s, "datosPerfilesPca", null), "codCompania", null),
  local!ramo: index(index(local!dcs, "datosBasicosSolicitud", null), "codRamo", null),
  local!completo: and(a!isNotNullOrEmpty(local!motivo), a!isNotNullOrEmpty(local!detalle), a!isNotNullOrEmpty(local!causa), a!isNotNullOrEmpty(local!cia), a!isNotNullOrEmpty(local!ramo)),
  local!tr: if(local!completo, rule!SCA2_obtenerTraduccionMotivosSca(codMotivo: local!motivo, codDetalle: local!detalle, codCausa: local!causa, codCia: local!cia, codRamo: local!ramo), null),
  local!m: tostring(index(local!tr, "codMotivoTra", "")),
  local!d: tostring(index(local!tr, "codDetalleTra", "")),
  local!c: tostring(index(local!tr, "codCausaTra", "")),
  if(
    or(not(local!completo), a!isNullOrEmpty(local!m), a!isNullOrEmpty(local!d), a!isNullOrEmpty(local!c)),
    local!s,
    a!update(local!s, "datosCompletosSolicitud",
      a!update(local!dcs, "datosSolicitud",
        a!update(local!ds, {"codMotivo", "codDetalle", "codCausa"}, {
          if(len(local!m) >= 8, local!m, concat(joinarray(repeat(8 - len(local!m), "0")), local!m)),
          if(len(local!d) >= 8, local!d, concat(joinarray(repeat(8 - len(local!d), "0")), local!d)),
          if(len(local!c) >= 8, local!c, concat(joinarray(repeat(8 - len(local!c), "0")), local!c))
        })))
  )
)
