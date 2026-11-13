/* [SCA2] Parámetros de la carga inicial de catálogos CORE → Aurora (fase 1, sesión C).
   perfiles: parejas (codPerfil, codSubPerfil) con las que CORE filtra los MOTIVOS (las que usa SCA2: sca2_datos_perfiles_pca + SCA2_datosPerfilesPcaSi24).
   perfilesCausa: perfiles con los que CORE filtra las CAUSAS. lineasNegocio: 1 Autos, 2 Diversos, 3 Vida (CORE no devuelve nada a partir de 4).
   infoUsuario: usuario administrativo con el que se consultan conceptos y tipos de argumento (mismo que SCA2_obtenerInformacionUsuario para administradores). */
a!map(
  perfiles: {
    a!map(codPerfil: "CE_RM", codSubPerfil: "CE_RM_OFICINA"),
    a!map(codPerfil: "CE_MF_SI24", codSubPerfil: "CE_MF_SI24_EXPERTO"),
    a!map(codPerfil: "CE_MF_BK", codSubPerfil: "CE_MF_BK_EXPERTOSI24")
  },
  perfilesCausa: {"CE_RM", "CE_MF_SI24", "CE_MF_BK"},
  lineasNegocio: {1, 2, 3},
  codCiaUsuario: 41,
  infoUsuario: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}infoUsuarioDTO'(
    codCiaUsuario: 41,
    nuuma: cons!SCA2_TXT_EJEMPLO_NUUMA,
    codPerfil: "CE_RM",
    codSubPerfil: "CE_RM_OFICINA"
  ),
  catalogos: {"MOTIVO", "DETALLE", "CAUSA", "TIPO_ARGUMENTO", "CONCEPTO", "VALOR_CONCEPTO"}
)