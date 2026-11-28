/*
[SCA2] Modales de regateo/SGO de contra anulación — copia del bloque de modales de
SCA_ContraAnulacionOpcionesEstrategicas (Tréboles, Retos, SVA, SVAEmail).
Tréboles portado inline (SCA_ContraAnulacionModalTréboles, 103 l. originales).
Inputs: mcaVentanaRegateo, mcaVentanaRetos, mcaVentanaSVADisponibles, mcaVentanaEmail,
maximo, tipoBonificacion, numBonAplic, SVADisponibles, svaElegido, email, data, dataServicio,
tipoArgumentoVariable, return, mensajeInfo, mcaVentanaInfo, mcaSVADisponiblesEjecutado,
mcaVentanaRecuperacion, estadoArgumentos, indiceArgumentoSeleccionado
*/
a!localVariables(
  local!error,
  local!resultado,
  {
    /* Modal Tréboles (regateo) — SCA_ContraAnulacionModalTréboles */
    if(ri!mcaVentanaRegateo,
    a!cardLayout(
      contents: {
        a!columnsLayout(
          columns: {
            a!columnLayout(),
            a!columnLayout(
              contents: {
                a!integerField(
                  label: concat(
                    "Indique el número de ",
                    ri!tipoBonificacion,
                    " a aplicar (máximo: ",
                    ri!maximo,
                    if(
                      and(
                        a!isNotNullOrEmpty(index(ri!data, "trebolesRecomendados", null)),
                        index(ri!data, "trebolesRecomendados", null) <> 0
                      ),
                      concat(" recomendados: ", index(ri!data, "trebolesRecomendados", null)),
                      ""
                    ),
                    ")"
                  ),
                  value: ri!numBonAplic,
                  saveInto: ri!numBonAplic,
                  validations: if(
                    ri!numBonAplic < 1,
                    "El valor ha de ser mayor que 0",
                    if(ri!numBonAplic > ri!maximo,
                      "El valor no puede ser mayor que el máximo indicado",
                      null)
                  )
                )
              },
              width: "MEDIUM_PLUS"
            ),
            a!columnLayout()
          }
        ),
        a!columnsLayout(
          columns: {
            a!columnLayout(
              contents: {
                a!richTextDisplayField(
                  value: a!richTextItem(
                    text: if(
                      a!isNotNullOrEmpty(local!error),
                      a!forEach(items: local!error, expression: fv!item & char(10)),
                      null),
                    color: "NEGATIVE"),
                  align: "CENTER")
              }
            )
          }
        ),
        a!buttonLayout(
          primaryButtons: {
            a!buttonWidget(
              label: "ACEPTAR",
              saveInto: {
                a!save(ri!mcaVentanaRegateo, false),
                  /*5. Comprueba si el estado del argumento es de TREBOLES o de RETOS y muestra mensaje de error o de confirmación*/
                  if(
                    /*Si es de tipo tréboles*/
                    and(ri!tipoArgumentoVariable = 1, ri!return = false),
                    {
                      /*Guardamos el resultado*/
                      rule!SCA2_executeAsignarIntegracion(
                        consulta: a!localVariables(
                          local!parametrosEntrada: 'type!{http://SocioAsignarTreboles}EntradaSocioAsignarTreboles'(
                            identificadorCliente: index(ri!dataServicio, "numDoc", ""),
                            impoperacion: index(ri!dataServicio, "numBonAplic", ""),
                            imptreboles: index(ri!dataServicio, "numBonAplic", ""),
                            desoperacion: concat("ASIGNA ", index(ri!dataServicio, "numBonAplic", ""), " TREBOLES EN SOL. ", index(ri!dataServicio, "codSolicitud", "")),
                            codcampania: index(ri!dataServicio, "codCampania", "")
                          ),
                          local!execute: 'type!{http://SocioAsignarTreboles}execute'(
                            parametrosEntrada: local!parametrosEntrada
                          ),
                          local!execute
                        ),
                        onSuccess: if(
                          index(
                            a!fromJson(xmltojson(index(fv!result, "body",null))),
                            "soapenv:Envelope", "soapenv:Body", "executeResponse", "executeReturn", "inderror", ""
                          ) = "1",
                          a!save(
                            local!resultado, 
                            {
                              false,
                              index(
                                a!fromJson(xmltojson(index(fv!result, "body",null))),
                                "soapenv:Envelope", "soapenv:Body", "executeResponse", "executeReturn", "smensaje", ""
                              )
                            }
                          ),
                          a!save(local!resultado, {true, null})

                        ),
                        onError: a!save(local!resultado, {false, "Ha ocurrido un error en la llamada a la integración. Por favor, inténtelo más tarde."})
                      ),
                      /*Si se ha dado un error muestra unos errores y sino muestra el de confirmación*/
                      if(
                        toboolean(index(local!resultado, 1,null)) = false,
                        {
                          if(
                            index(ri!dataServicio, "mcaTeCuidamos", false) = false,
                            {
                              a!save(ri!mensajeInfo, concat("No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos. Utilice el enlace a te cuidamos existente en el argumento para dar de alta al cliente en te cuidamos y posteriormente finalizar el argumento como positivo. Mensaje obtenido de Te Cuidamos: ", if(a!isNullOrEmpty(index(local!resultado, 2,null)), "", index(local!resultado, 2,null)))),
                              a!save(ri!mcaVentanaInfo, true),
                              a!save(ri!return, true),
                              a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                            },
                            {
                              a!save(ri!mensajeInfo, concat("No se han podido asignar los tréboles al cliente por la siguiente causa:", index(local!resultado, 2,null))),
                              a!save(ri!mcaVentanaInfo, true),
                              a!save(ri!return, true),
                              a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                            }
                          )
                        },
                        null
                      )
                    },
                    null
                  ),
                  
                  /*6. Comprueba de nuevo si es de tipo TREBOLES o RETOS y ejecuta ciertas operaciones -siempre que no haya dado error-*/
                  if(
                    /*Si no ha dado error*/
                    ri!return = false,
                    /*Si es de tipo TRÉBOLES o RETOS*/
                    if(
                      or(ri!tipoArgumentoVariable = 1, ri!tipoArgumentoVariable = 2),
                      {
                        /*Si es del tipo TTQ se llama al método gestionarTTQ y sino y es de tipo TRÉBOLES a marcarBonificacion*/
                        if(
                          index(ri!dataServicio, "tuTeQuedas", false) = true,
                          {
                            /*Guardamos el resultado*/
                            rule!SCA2_gestionarTTQRESTIntegracion(
                              numPoliza: index(ri!dataServicio, "numPoliza", null),
                              codTipBon: index(ri!dataServicio, "codCampania", null),
                              numTipBon: index(ri!dataServicio, "numTipBon", null),
                              fecVigencia: index(ri!dataServicio, "fecVencimiento", null),
                              numSolicitudPca: index(ri!dataServicio, "codSolicitud", null),
                              numBonAplic: index(ri!dataServicio, "numBonAplic", null),
                              onSuccess: a!save(local!resultado, index(a!fromJson_19r2(index(fv!result, "body", null)), "valor", null)),
                              onError: a!save(local!resultado, null)
                            ),
                            /*Comprobamos si ha dado o no error*/
                            if(
                              a!isNotNullOrEmpty(local!resultado),
                              null,
                              {
                                a!save(ri!mcaVentanaInfo, true),
                                a!save(ri!mensajeInfo, "No se han podido asignar los tréboles al cliente"),
                                a!save(ri!return, true),
                                a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0")
                              }
                            )
                          },
                          if(
                            ri!tipoArgumentoVariable = 1,
                            rule!SCA2_marcarAsignacionBonificacionIntegracion(
                              host: cons!SCAC_VAL_HOST_CORE7,
                              endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
                              consulta: a!localVariables(
                                local!asignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}asignacionBonificacionDTO'(
                                  numPoliza: index(ri!dataServicio, "numPoliza", ""),
                                  codIdCampana: index(ri!dataServicio, "codCampania", ""),
                                  codTipBon: index(ri!dataServicio, "codTipBon", ""),
                                  numTipBon: index(ri!dataServicio, "numTipBon", ""),
                                  numSolicitud: index(ri!dataServicio, "codSolicitud", ""),
                                  mcaAplicada: "S",
                                  codDocum: index(ri!dataServicio, "numDoc", ""),
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
                              onSuccess: a!save(local!resultado, fv!result)
                            ),
                            null
                          )
                        ),
                        /*Si el perfil es de RED MAPFRE y la póliza está anulada crea solicitud SGO -esto lo hace el proceso-*/
                        null
                      },
                      null
                    ),
                    null
                  ),
                if(
                  ri!return = false,
                  a!save(ri!tipoArgumentoVariable, 0),
                  a!save(ri!mcaVentanaRecuperacion, false)
                )
              },
              style: "SOLID",
              color: "NEGATIVE",
              disabled: if(and(ri!numBonAplic > 0, ri!numBonAplic < ri!maximo + 1), false, true)
            )
          },
          secondaryButtons: {
            a!buttonWidget(
              label: "CANCELAR",
              saveInto: {
                a!save(ri!numBonAplic, null),
                a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                a!save(ri!mcaVentanaRegateo, false),
                a!save(ri!mcaVentanaRecuperacion, false)
              },
              style: "GHOST",
              color: "NEGATIVE"
            )
          }
        )
      },
      showBorder: false,
      marginAbove: "EVEN_MORE"
    ),
    ""),
    /* Modal Retos */
    if(ri!mcaVentanaRetos,
    rule!SCA2_ContraAnulacionModalRetos(
      mcaVentanaRetos: ri!mcaVentanaRetos,
      maximo: ri!maximo,
      tipoBonificacion: ri!tipoBonificacion,
      numBonAplic: ri!numBonAplic,
      mcaVentanaRecuperacion: ri!mcaVentanaRecuperacion,
      estadoArgumentos: ri!estadoArgumentos,
      indiceArgumentoSeleccionado: ri!indiceArgumentoSeleccionado,
      onAceptar: {
                  /*5. Comprueba si el estado del argumento es de TREBOLES o de RETOS y muestra mensaje de error o de confirmación*/
                  
                  if(
                    /*Si es de tipo retos*/
                    and(ri!tipoArgumentoVariable = 2, ri!return = false),
                    {
                      a!save(
                        local!resultado,
                        rule!SCA2_asignarRetos(
                          nuuma: index(ri!dataServicio, "nuuma", ""),
                          numDoc: index(ri!dataServicio, "numDoc", ""),
                          retos: index(ri!dataServicio, "numTipBon", "")
                        )
                      ),
                      if(
                        toboolean(index(local!resultado, 1,null)) = false,
                        {
                          a!save(ri!mcaVentanaInfo, true),
                          a!save(ri!mensajeInfo, concat("No se han podido asignar los Tréboles en Retos. Mensaje obtenido de Retos: ", index(local!resultado, 2,null))),
                          a!save(ri!return, true),
                          a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                        },
                        {
                          /* R37-A: el servicio de Retos ha asignado los tréboles → observación para el argumento positivo */
                          a!save(
                            ri!obsServicioAplicado,
                            substitute(cons!SCA2_TXT_OBS_RETOS_APLICADOS, "{0}", index(ri!dataServicio, "numTipBon", ""))
                          )
                        }
                      )
                    },
                    null
                  ),
                  /*6. Comprueba de nuevo si es de tipo TREBOLES o RETOS y ejecuta ciertas operaciones -siempre que no haya dado error-*/
                  if(
                    /*Si no ha dado error*/
                    ri!return = false,
                    /*Si es de tipo TRÉBOLES o RETOS*/
                    if(
                      or(ri!tipoArgumentoVariable = 1, ri!tipoArgumentoVariable = 2),
                      {
                        /*Si es del tipo TTQ se llama al método gestionarTTQ y sino y es de tipo TRÉBOLES a marcarBonificacion*/
                        if(
                          index(ri!dataServicio, "tuTeQuedas", false) = true,
                          {
                            /*Guardamos el resultado*/
                            rule!SCA2_gestionarTTQRESTIntegracion(
                              numPoliza: index(ri!dataServicio, "numPoliza", null),
                              codTipBon: index(ri!dataServicio, "codCampania", null),
                              numTipBon: index(ri!dataServicio, "numTipBon", null),
                              fecVigencia: index(ri!dataServicio, "fecVencimiento", null),
                              numSolicitudPca: index(ri!dataServicio, "codSolicitud", null),
                              numBonAplic: index(ri!dataServicio, "numBonAplic", null),
                              onSuccess: a!save(local!resultado, index(a!fromJson_19r2(index(fv!result, "body", null)), "valor", null)),
                              onError: a!save(local!resultado, null)
                            ),
                            /*Comprobamos si ha dado o no error*/
                            if(
                              a!isNotNullOrEmpty(local!resultado),
                              null,
                              {
                                a!save(ri!mcaVentanaInfo, true),
                                a!save(ri!mensajeInfo, "No se han podido asignar los tréboles al cliente"),
                                a!save(ri!return, true),
                                a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0")
                              }
                            )
                          },
                          if(
                            ri!tipoArgumentoVariable = 1,
                            rule!SCA2_marcarAsignacionBonificacionIntegracion(
                              host: cons!SCAC_VAL_HOST_CORE7,
                              endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
                              consulta: a!localVariables(
                                local!asignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}asignacionBonificacionDTO'(
                                  numPoliza: index(ri!dataServicio, "numPoliza", ""),
                                  codIdCampana: index(ri!dataServicio, "codCampania", ""),
                                  codTipBon: index(ri!dataServicio, "codTipBon", ""),
                                  numTipBon: index(ri!dataServicio, "numTipBon", ""),
                                  numSolicitud: index(ri!dataServicio, "codSolicitud", ""),
                                  mcaAplicada: "S",
                                  codDocum: index(ri!dataServicio, "numDoc", ""),
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
                              onSuccess: a!save(local!resultado, fv!result)
                            ),
                            null
                          )
                        ),
                        /*Si el perfil es de RED MAPFRE y la póliza está anulada crea solicitud SGO -esto lo hace el proceso-*/
                        null
                      },
                      null
                    ),
                    null
                  ),
        if(
          ri!return = false,
          a!save(ri!tipoArgumentoVariable, 0),
          a!save(ri!mcaVentanaRecuperacion, false)
        )
      }
    ),
    ""),
    /* Modal SVA disponibles */
    if(ri!mcaVentanaSVADisponibles,
    rule!SCA2_ContraAnulacionModalSVA(
      SVADisponibles: ri!SVADisponibles,
      mcaVentanaSVADisponibles: ri!mcaVentanaSVADisponibles,
      mcaSVADisponiblesEjecutado: ri!mcaSVADisponiblesEjecutado,
      svaElegido: ri!svaElegido,
      estadoArgumentos: ri!estadoArgumentos,
      indiceArgumentoSeleccionado: ri!indiceArgumentoSeleccionado,
      mcaVentanaEmail: ri!mcaVentanaEmail,
      mcaVentanaRecuperacion: ri!mcaVentanaRecuperacion
    ),
    ""),
    /* Modal email SVA */
    if(ri!mcaVentanaEmail,
    rule!SCA2_ContraAnulacionModalSVAEmail(
      data: ri!data,
      mcaVentana: ri!mcaVentanaEmail,
      email: ri!email,
      mcaVentanaSVADisponibles: ri!mcaVentanaSVADisponibles,
      onAceptar: {
                  /*7. Comprueba si el estado del argumento es de SVA y muestra mensaje de error o confirmación*/
                  if(
                    /*Si es de tipo SVA*/
                    and(ri!tipoArgumentoVariable = 3, ri!return = false),
                    if(
                      /*Si es de tipo TeCuidamos*/
                      index(ri!dataServicio, "mcaTeCuidamos", false) = true,
                      /*Asignamos SVA*/
                      {
                        a!save(local!resultado ,rule!SCA2_asignarSVA(
                          codAccion: index(ri!dataServicio, "svaElegido", null),
                          numDoc: index(ri!dataServicio, "numDoc", null),
                          numPoliza: index(ri!dataServicio, "numPoliza", null),
                          email: a!defaultValue(ri!email, index(ri!dataServicio, "email", null)),
                          nuuma: index(ri!dataServicio, "nuuma", null),
                          fechaVencimiento: index(ri!dataServicio, "fecVencimiento", null)
                        )),
                        if(
                          /*Si hay error*/
                          index(local!resultado, 1, false) = false,
                          {
                            a!save(ri!mensajeInfo, "No ha sido posible asignar el SVA al cliente: " & local!resultado),
                            a!save(ri!return, true),
                            a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                            a!save(ri!mcaVentanaInfo, true)
                          },
                          /*Si no lo hay*/
                          {
                            rule!SCA2_marcarAsignacionBonificacionIntegracion(
                              host: cons!SCAC_VAL_HOST_CORE7,
                              endpoint: "PCA_CORECFSA_HTTPRouter/IGenerarContraAnul",
                              consulta: a!localVariables(
                                local!asignacionBonificacionDTO: 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}asignacionBonificacionDTO'(
                                  numPoliza: index(ri!dataServicio, "numPoliza", ""),
                                  codIdCampana: index(ri!dataServicio, "codCampania", ""),
                                  codTipBon: index(ri!dataServicio, "codTipBon", ""),
                                  numTipBon: index(ri!dataServicio, "numTipBon", ""),
                                  numSolicitud: index(ri!dataServicio, "codSolicitud", ""),
                                  mcaAplicada: "S",
                                  codDocum: index(ri!dataServicio, "numDoc", ""),
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
                              onSuccess: {
                                a!save(local!resultado, fv!result),
                                /* R37-A: SVA asignado en Club MAPFRE y marcado → observación para el argumento positivo */
                                a!save(
                                  ri!obsServicioAplicado,
                                  a!localVariables(
                                    local!codSva: tostring(index(ri!dataServicio, "svaElegido", null)),
                                    local!posSva: wherecontains(
                                      local!codSva,
                                      a!forEach(items: index(ri!SVADisponibles, "codAccion", {}), expression: tostring(fv!item))
                                    ),
                                    substitute(
                                      substitute(
                                        cons!SCA2_TXT_OBS_SVA_APLICADO,
                                        "{0}",
                                        a!defaultValue(
                                          if(
                                            length(local!posSva) > 0,
                                            tostring(index(index(ri!SVADisponibles, "desAccion", {}), local!posSva[1], null)),
                                            null
                                          ),
                                          local!codSva
                                        )
                                      ),
                                      "{1}",
                                      tostring(a!defaultValue(ri!email, index(ri!dataServicio, "email", null)))
                                    )
                                  )
                                )
                              }
                            ),
                            null
                          }
                        )
                      },
                      /*Mostramos error de no pertenecer al club mapfre*/
                      {
                        a!save(ri!mensajeInfo, "No se han podido asignar tréboles al cliente porque no está dado de alta en Club Mapfre. Utilice el enlace a te cuidamos existente en el argumento de SVA para dar de alta al cliente en Club Mapfre y posteriormente finalizar el argumento como positivo."),
                        a!save(ri!mcaVentanaInfo, true),
                        a!save(ri!return, true),
                        a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0")
                      }
                    ),
                    null
                  ),
        if(
          ri!return = false,
          a!save(ri!tipoArgumentoVariable, 0),
          a!save(ri!mcaVentanaRecuperacion, false)
        )
      }
    ),
    "")
  }
)
