a!localVariables(
  local!submit,
  local!resultado,
  local!errorEconomico,
  local!mcaVentanaInfo: false,
  local!mensajeInfo: "",
  /* R35-B: al aplicar tréboles TTQ (pantalla «Indique el número de…», ejecutada en SCA2_ContraAnulacionSGO) se añade a las observaciones del argumento el número aplicado, sin sustituir las del gestor */
  local!obsArgumentoPositivo: a!localVariables(
    local!obsGestor: tostring(a!defaultValue(index(ri!data, "observacionesArgumento", null), "")),
    local!numAplicados: tointeger(index(ri!data, "numBonAplic", null)),
    local!obsTreboles: if(
      and(
        a!defaultValue(index(ri!data, "tuTeQuedas", false), false) = true,
        a!defaultValue(local!numAplicados, 0) > 0
      ),
      substitute(cons!SCA2_TXT_OBS_TREBOLES_APLICADOS, "{0}", local!numAplicados),
      ""
    ),
    /* R37-A: Retos/SVA aplicados por el servicio (dato que rellena SCA2_ContraAnulacionSGO) */
    local!obsAplicada: if(
      a!isNullOrEmpty(local!obsTreboles),
      tostring(a!defaultValue(index(ri!data, "obsServicioAplicado", null), "")),
      local!obsTreboles
    ),
    if(
      a!isNullOrEmpty(local!obsAplicada),
      index(ri!data, "observacionesArgumento", null),
      if(
        a!isNullOrEmpty(trim(local!obsGestor)),
        local!obsAplicada,
        concat(local!obsGestor, " - ", local!obsAplicada)
      )
    )
  ),
  /*Comprueba si el usuario es propietario*/
  /*local!mcaPropietarioPoliza: index(ri!data, "mcaPropietarioPoliza", null),*/
  {
    a!cardLayout(
      contents: {
        /*Mensaje*/
        a!columnsLayout(
          columns: {
            a!columnLayout(),
            a!columnLayout(
              contents: {
                a!richTextDisplayField(
                  value: a!richTextIcon(
                    icon: "Warning",
                    color: "SECONDARY",
                    size: "EXTRA_LARGE"
                  ),
                  align: "CENTER"
                ),
                a!horizontalLine(),
                a!richTextDisplayField(
                  value: a!richTextItem(
                    text: ri!mensaje,
                    color: "STANDARD",
                    style: "STRONG"
                  ),
                  align: "CENTER"
                )
              },
              width: "WIDE",
            ),
            a!columnLayout()
          }
        ),
        /*Botones ACEPTAR y CANCELAR*/
        a!buttonLayout(
          primaryButtons: {
            a!buttonWidget(
              label: "ACEPTAR",
              saveInto: { 
                {
                  /*1. Comprobamos límite observaciones*/
                  if(
                    and(len(index(ri!data, "observaciones", 0)) > 999, a!isNotNullOrEmpty(index(ri!data, "observaciones", ""))),
                    {
                      a!save(ri!return, true),
                      a!save(local!mensajeInfo, "El campo de observaciones ha sobrepasado el límite de 999 caracteres"),
                      a!save(local!mcaVentanaInfo, true)
                    },
                    null
                  ),
                  /* R34-A: tréboles/retos/SVA se ejecutan al aceptar su pantalla (SCA2_ContraAnulacionSGO); aquí llegan ya hechos */
                  /* R30: argumento económico → inserción en A2139022_MES vía marcarAsignacionBonificacion, sólo con positivo definitivo (tréboles/TTQ/SVA OK) */
                  if(
                    and(index(ri!data, "argumentoEconomico", "N") = "S", ri!return = false),
                    rule!SCA2_marcarAsignacionBonificacionIntegracion(
                      host: cons!SCAC_VAL_HOST_CORE7,
                      endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
                      consulta: a!localVariables(
                        local!asignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}asignacionBonificacionDTO'(
                          numPoliza: index(ri!data, "numPoliza", ""),
                          codIdCampana: "ECONOMICO",
                          codTipBon: "Arg. Econ.",
                          numTipBon: index(ri!data, "codTipoArgumento", null),
                          numSolicitud: index(ri!data, "codSolicitud", ""),
                          mcaAplicada: "S",
                          codDocum: left(index(ri!data, "descTipoArgumento", null), 20),
                          fecAplicacion: today()
                        ),
                        local!mseMarcarAsignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}mseMarcarAsignacionBonificacionDTO'(
                          asignacionBonificacion: local!asignacionBonificacionDTO
                        ),
                        local!marcarAsignacionBonificacion: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}marcarAsignacionBonificacion'(
                          MSEMarcarAsignacion: local!mseMarcarAsignacionBonificacionDTO
                        ),
                        local!marcarAsignacionBonificacion
                      ),
                      onSuccess: a!save(local!errorEconomico, null),
                      /* Un error del servicio no bloquea el positivo (no se puede registrar en SCA2 Error: sólo un smart service por evaluación) */
                      onError: a!save(local!errorEconomico, fv!error)
                    ),
                    null
                  ),
                  /*8. Comprueba si el estado del argumento es positivo, si el perfil es de RED MAPFRE y si la póliza está anulada*/
                  if(
                    and(index(ri!data, "codPerfil", "") = cons!SCA2_TXT_PERFIL_CE_RM, ri!return = false, ri!anulada = true),
                    {
                      a!save(ri!return, true),
                      /*Guardar la ejecución del argumento positivo*/ /*CAMBIO 27_6_24*/
                      a!save(local!resultado, rule!SCA2_guardarEjecuArg(
                        ejecucionArgDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}ejecucionArgDTO'(
                          codCContraria: index(ri!data, "codCia"),
                          codGestion: index(ri!data, "codGestion"),
                          codSolicitud: index(ri!data, "codSolicitud"),
                          codTipoArgumento: index(ri!data, "codTipoArgumento"),
                          codTipoNegocio: index(ri!data, "lineaNegocio"),
                          infoUsuario: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}infoUsuarioDTO'(
                            codCiaUsuario: index(ri!data, "codCia"),
                            nuuma: index(ri!data, "nuuma"),
                            codPerfil: index(ri!data, "codPerfil"),
                            codSubPerfil: index(ri!data, "codSubPerfil"),
                          ),
                          mcaResultado: "1",
                          observaciones: local!obsArgumentoPositivo,
                          precio: index(ri!data, "impCiaContra")
                        ))),
                        a!save(
                          ri!datosContraAnulacion,
                          'type!{urn:com:appian:types:SCAC}SCAC_DS_datosContraAnulacion'(
                            nivelIntervencion: index(ri!data, "nivelIntervencion"),
                            codSolicitud: index(ri!data, "codSolicitud"),
                            codTIpoArgumento: index(ri!data, "codTipoArgumento"),
                            mcaEstadoFinal: "3"/*index(ri!data, "mcaEstadoFinal")*/,
                            observaciones: index(ri!data, "observaciones"),
                            datosPerfilesPca: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosPerfilesPca'(
                              codCompania: index(ri!data, "codCia"),
                              codPerfil: index(ri!data, "codPerfil"),
                              codSubPerfil: index(ri!data, "codSubPerfil"),
                              nuuma: index(ri!data, "nuuma"),
                            ),
                            anulaExpertos: index(ri!data, "anulaExpertos", false),
                            anulaTecnicos: index(ri!data, "anulaTecnicos", false)
                          )
                        ),
                        /*Mostramos mensaje para avanzar el proceso*/
                        {
                          a!save(ri!return, true),
                          /* Paridad SCA: cierra la ventana de recuperación y, sin aviso intermedio, continúa el cierre positivo (CMD CompletarAccion) */
                          a!save(ri!mcaVentanaInfo, false),
                          ri!onFinalizarPositivo
                        }
                    },
                    null
                  ),
                  /*9. Si no da ninguno de los otros casos llama al guardarEjecuArg, y por tanto, al botón Finalizar*/
                  if(
                    ri!return = false,
                    {
                      /*Guardar la ejecución del argumento positivo*/
                      a!save(local!resultado, rule!SCA2_guardarEjecuArg(
                        ejecucionArgDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}ejecucionArgDTO'(
                          codCContraria: index(ri!data, "codCia"),
                          codGestion: index(ri!data, "codGestion"),
                          codSolicitud: index(ri!data, "codSolicitud"),
                          codTipoArgumento: index(ri!data, "codTipoArgumento"),
                          codTipoNegocio: index(ri!data, "lineaNegocio"),
                          infoUsuario: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}infoUsuarioDTO'(
                            codCiaUsuario: index(ri!data, "codCia"),
                            nuuma: index(ri!data, "nuuma"),
                            codPerfil: index(ri!data, "codPerfil"),
                            codSubPerfil: index(ri!data, "codSubPerfil"),
                          ),
                          mcaResultado: "1",
                          observaciones: local!obsArgumentoPositivo,
                          precio: index(ri!data, "impCiaContra")
                        ))),
                        /*Flujo del botón finalizar positivo*/
                        { /*CAMBIO 27_06_24*/
                          /*Se llamaría a la impresión pero no lo hace porque la contraanulación es positiva*/
                          /*Se comprueba si se han completado los argumentos, pero ya lo habíamos hecho con anterioridad*/
                          /*Se llama a altaActualizarSGC*/
                          /*Se llama a finalizarContraAnulacion -> esto lo hace el proceso, al que nosotros le pasamos la información mediante la rule input 'datosContraAnulacion'*/
                          if(
                            ri!return = false,
                            {
                              a!save(
                                ri!datosContraAnulacion,
                                'type!{urn:com:appian:types:SCAC}SCAC_DS_datosContraAnulacion'(
                                  nivelIntervencion: index(ri!data, "nivelIntervencion"),
                                  codSolicitud: index(ri!data, "codSolicitud"),
                                  codTIpoArgumento: index(ri!data, "codTipoArgumento"),
                                  mcaEstadoFinal: "3"/*index(ri!data, "mcaEstadoFinal")*/,
                                  observaciones: index(ri!data, "observaciones"),
                                  datosPerfilesPca: 'type!{urn:com:appian:types:SCAC}SCAC_DS_datosPerfilesPca'(
                                    codCompania: index(ri!data, "codCia"),
                                    codPerfil: index(ri!data, "codPerfil"),
                                    codSubPerfil: index(ri!data, "codSubPerfil"),
                                    nuuma: index(ri!data, "nuuma"),
                                  ),
                                  anulaExpertos: index(ri!data, "anulaExpertos", false),
                                  anulaTecnicos: index(ri!data, "anulaTecnicos", false)
                                )
                              ),
                              {
                                a!save(ri!return, true),
                                /* Paridad SCA: cierra la ventana de recuperación y, sin aviso intermedio, continúa el cierre positivo (CMD CompletarAccion) */
                                a!save(ri!mcaVentanaInfo, false),
                                ri!onFinalizarPositivo
                              }
                            },
                            null
                          )
                        }
                    },
                    null
                  )
                }
              },
              style: "SOLID",
              color: cons!SCA2_VAL_COLOR_ROJO,
              submit: false
            )
          },
          secondaryButtons: {
            a!buttonWidget(
              label: "CANCELAR",
              saveInto: {
                if(
                  ri!positiva,
                  a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                  null
                ),
                a!save(ri!mcaVentanaInfo, false)
              },
              style: "GHOST",
              color: cons!SCA2_VAL_COLOR_ROJO
            )
          }
        ),
      },
      showWhen: local!mcaVentanaInfo = false,
      showBorder: false,
      marginAbove: "EVEN_MORE"
    ),

    /*Modal informativo*/
    a!columnsLayout(
      columns: {
        a!columnLayout(),
        a!columnLayout(
          contents: {
            a!cardLayout(
              contents: {
                a!columnsLayout(
                  columns: {
                    a!columnLayout(),
                    a!columnLayout(
                      contents: {
                        a!richTextDisplayField(
                          value: a!richTextIcon(icon: "info-circle", color: "SECONDARY", size: "EXTRA_LARGE"),
                          align: "CENTER"
                        ),
                        a!horizontalLine(),
                        a!richTextDisplayField(
                          value: a!richTextItem(text: local!mensajeInfo, color: "STANDARD", style: "STRONG"),
                          align: "CENTER"
                        )
                      },
                      width: "WIDE"
                    ),
                    a!columnLayout()
                  }
                ),
                a!buttonArrayLayout(
                  buttons: {
                    a!buttonWidget(
                      label: "ACEPTAR",
                      saveInto: {
                        a!save(local!mcaVentanaInfo, false),
                        a!save(ri!mcaVentanaInfo, false),
                        /* Equivalente al submit del formulario SCA: continúa el proceso de cierre positivo */
                        if(a!defaultValue(local!submit, false), ri!onFinalizarPositivo, {})
                      },
                      style: "SOLID",
                      color: cons!SCA2_VAL_COLOR_ROJO
                    )
                  },
                  align: "CENTER"
                )
              },
              showBorder: false,
              marginAbove: "EVEN_MORE"
            )
          },
          width: "WIDE_PLUS"
        ),
        a!columnLayout()
      },
      showWhen: local!mcaVentanaInfo
    )
  }
)