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
  /* R51-A (MEJ-01/02): los tréboles (Club MAPFRE + TTQ) se aplican al ACEPTAR esta pantalla y la enhorabuena sale después */
  local!resTreboles,
  local!resTTQ,
  /* "" pantalla de número de tréboles; NO_CLUB / ERROR / PARCIAL: aviso tras aplicar */
  local!vistaTreboles: "",
  local!mensajeTreboles: "",
  {
    /* Modal Tréboles (regateo) — SCA_ContraAnulacionModalTréboles */
    if(ri!mcaVentanaRegateo,
    if(
      a!defaultValue(local!vistaTreboles, "") <> "",
      /* R51-A (MEJ-01/02): aviso tras intentar aplicar los tréboles */
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
                    value: a!richTextItem(text: local!mensajeTreboles, color: "STANDARD", style: "STRONG"),
                    align: "CENTER"
                  ),
                  /* Enlace a la aplicación de alta en Club MAPFRE (concepto URL de CORE) con el NIF del tomador */
                  if(
                    local!vistaTreboles = "NO_CLUB",
                    a!localVariables(
                      local!conceptosUrl: rule!SCA2_consultarConceptoReutilizable(idConcepto: "URL"),
                      local!urlAltaClub: if(
                        a!isNullOrEmpty(local!conceptosUrl),
                        null,
                        a!localVariables(
                          local!pos: wherecontains(
                            cons!SCA2_TXT_CONCEPTO_URL_ALTA_CLUB_MAPFRE,
                            touniformstring(index(local!conceptosUrl, "desConcepto", {}))
                          ),
                          if(
                            length(local!pos) = 0,
                            null,
                            concat(
                              tostring(index(touniformstring(index(local!conceptosUrl, "valorConcepto", {})), local!pos[1], "")),
                              tostring(a!defaultValue(index(ri!dataServicio, "numDoc", null), ""))
                            )
                          )
                        )
                      ),
                      a!richTextDisplayField(
                        value: a!richTextItem(
                          text: cons!SCA2_TXT_ENLACE_CLUB_MAPFRE,
                          link: a!safeLink(uri: local!urlAltaClub),
                          linkStyle: "STANDALONE",
                          color: cons!SCA2_VAL_COLOR_AZUL_CLARO,
                          style: "STRONG"
                        ),
                        align: "CENTER",
                        showWhen: a!isNotNullOrEmpty(local!urlAltaClub)
                      )
                    ),
                    {}
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
                  /* NO_CLUB / ERROR: vuelve a los argumentos (la enhorabuena ya está cerrada). PARCIAL: sale la enhorabuena */
                  a!save(local!vistaTreboles, ""),
                  a!save(local!mensajeTreboles, ""),
                  a!save(ri!mcaVentanaRegateo, false)
                },
                style: "SOLID",
                color: "NEGATIVE"
              )
            },
            align: "CENTER"
          )
        },
        showBorder: false,
        marginAbove: "EVEN_MORE"
      ),
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
                /* R51-A (MEJ-01/02): se aplican aquí los tréboles (Club MAPFRE y después TTQ), antes de la enhorabuena.
                   Club KO: aviso (NO_CLUB con enlace a Club MAPFRE, o ERROR) y el argumento vuelve a pendiente.
                   Club OK + TTQ KO: error relanzable y aviso; su ACEPTAR lleva a la enhorabuena.
                   Todo OK: enhorabuena. tipoArgumentoVariable pasa a 0 para que la enhorabuena no los vuelva a aplicar. */
                if(
                  and(a!defaultValue(ri!tipoArgumentoVariable, 0) = 1, a!defaultValue(ri!return, false) = false),
                  {
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
                            a!fromJson(xmltojson(index(fv!result, "body", null))),
                            "soapenv:Envelope", "soapenv:Body", "executeResponse", "executeReturn", "inderror", ""
                          ) = "1",
                          a!save(
                            local!resTreboles,
                            {
                              false,
                              index(
                                a!fromJson(xmltojson(index(fv!result, "body", null))),
                                "soapenv:Envelope", "soapenv:Body", "executeResponse", "executeReturn", "smensaje", ""
                              )
                            }
                          ),
                          a!save(local!resTreboles, {true, null})
                        ),
                        onError: a!save(local!resTreboles, {false, "Ha ocurrido un error en la llamada a la integración. Por favor, inténtelo más tarde."})
                      ),
                      if(
                        toboolean(index(local!resTreboles, 1, false)) = false,
                        /* Club KO: no se aplica nada y el argumento vuelve a pendiente */
                        {
                          a!save(ri!return, true),
                          a!save(ri!estadoArgumentos[ri!indiceArgumentoSeleccionado], "0"),
                          /* R51-A (MEJ-01/02): no sale la enhorabuena; aviso y ACEPTAR vuelve a los argumentos */
                          a!save(ri!mcaVentanaRecuperacion, false),
                          a!save(
                            local!vistaTreboles,
                            if(a!defaultValue(index(ri!dataServicio, "mcaTeCuidamos", false), false) = false, "NO_CLUB", "ERROR")
                          ),
                          a!save(
                            local!mensajeTreboles,
                            if(
                              a!defaultValue(index(ri!dataServicio, "mcaTeCuidamos", false), false) = false,
                              substitute(cons!SCA2_TXT_TREBOLES_NO_CLUB_MAPFRE, "{0}", tostring(a!defaultValue(index(local!resTreboles, 2, null), ""))),
                              concat("No se han podido asignar los tréboles al cliente por la siguiente causa:", tostring(a!defaultValue(index(local!resTreboles, 2, null), "")))
                            )
                          )
                        },
                        /* Club OK: grabación en TTQ */
                        {
                          rule!SCA2_gestionarTTQRESTIntegracion(
                            numPoliza: index(ri!dataServicio, "numPoliza", null),
                            codTipBon: index(ri!dataServicio, "codCampania", null),
                            numTipBon: index(ri!dataServicio, "numTipBon", null),
                            fecVigencia: index(ri!dataServicio, "fecVencimiento", null),
                            numSolicitudPca: index(ri!dataServicio, "codSolicitud", null),
                            numBonAplic: index(ri!dataServicio, "numBonAplic", null),
                            onSuccess: a!save(local!resTTQ, index(a!fromJson_19r2(index(fv!result, "body", null)), "valor", null)),
                            onError: a!save(local!resTTQ, null)
                          ),
                          if(
                            a!isNotNullOrEmpty(local!resTTQ),
                            /* R51-A: tréboles aplicados → se cierra esta pantalla y sale la enhorabuena (ya no se vuelven a aplicar al aceptarla) */
                            {
                              a!save(ri!tipoArgumentoVariable, 0),
                              a!save(ri!mcaVentanaRegateo, false)
                            },
                            /* Entrega parcial (Club OK + TTQ KO): error relanzable en el listado de errores y se continúa el positivo */
                            {
                              a!save(ri!tipoArgumentoVariable, 0),
                              a!save(local!vistaTreboles, "PARCIAL"),
                              a!save(
                                local!mensajeTreboles,
                                concat("Se han aplicado ", tostring(index(ri!dataServicio, "numBonAplic", "")), " tréboles en Club MAPFRE, pero no se han podido grabar en Te Cuidamos (TTQ). Se ha registrado un error en el listado de errores para relanzar la grabación en TTQ. Pulse ACEPTAR para finalizar la contra anulación.")
                              ),
                              a!writeRecords(
                                records: 'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error'(
                                  /* R52: reutiliza el error PENDIENTE equivalente (R50-B) */
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{e5dc602a-1e18-44df-bbde-5d580de8ad21}id': index(rule!SCA2_obtenerErrorPendiente(idSolicitud: tostring(index(ri!dataServicio, "codSolicitud", null)), comando: "SCA2 TTQ GrabarTreboles", nodo: "Aplicar tréboles en TTQ (enhorabuena contra anulación)", codigo: "TTQ_KO"), "id", null),
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{263ccc68-f8c2-4913-b78d-8fce31e7ed9a}idSolicitud': tostring(index(ri!dataServicio, "codSolicitud", null)),
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{bf283c94-bf1e-49f4-840c-9a96ce858a37}comando': "SCA2 TTQ GrabarTreboles",
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4b654a26-b60f-478f-ad9c-31f5be706df2}nodo': "Aplicar tréboles en TTQ (enhorabuena contra anulación)",
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{975c87c8-8ee9-49ca-a414-15e1e45393a4}codigo': "TTQ_KO",
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{7e3bd67f-1c1d-4721-a6ac-98d3f688cb68}mensaje': concat("Tréboles aplicados en Club MAPFRE (", tostring(index(ri!dataServicio, "numBonAplic", "")), ") pero no grabados en TTQ para la póliza ", tostring(index(ri!dataServicio, "numPoliza", "")), ". Relanzar para grabarlos en TTQ."),
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f4cbb383-4659-42ed-a22b-d5fa91a09a5f}payload': a!toJson(
                                    a!map(
                                      numPoliza: index(ri!dataServicio, "numPoliza", null),
                                      codTipBon: index(ri!dataServicio, "codCampania", null),
                                      numTipBon: index(ri!dataServicio, "numTipBon", null),
                                      fecVigencia: index(ri!dataServicio, "fecVencimiento", null),
                                      numSolicitudPca: index(ri!dataServicio, "codSolicitud", null),
                                      numBonAplic: index(ri!dataServicio, "numBonAplic", null)
                                    )
                                  ),
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{8c9c24c7-239a-4f72-b442-88508c7836ea}intentos': a!defaultValue(index(rule!SCA2_obtenerErrorPendiente(idSolicitud: tostring(index(ri!dataServicio, "codSolicitud", null)), comando: "SCA2 TTQ GrabarTreboles", nodo: "Aplicar tréboles en TTQ (enhorabuena contra anulación)", codigo: "TTQ_KO"), "intentos", null) + 1, 0),
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{f891dbfa-4fcb-42e9-9d7d-b5799ddf7d02}estado': cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
                                  'recordType!{d7111f93-55f3-4b43-b921-aedadd2af7c3}SCA2 Error.fields.{4cedd947-8bd9-4a5c-aa77-cf8e5c65308a}fechaCreacion': now()
                                ),
                                onError: a!save(local!mensajeTreboles, concat(local!mensajeTreboles, " (Aviso: no se ha podido registrar el error: ", tostring(fv!error), ")"))
                              )
                            }
                          )
                        }
                      )
                  },
                  a!save(ri!mcaVentanaRegateo, false)
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
    )),
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
