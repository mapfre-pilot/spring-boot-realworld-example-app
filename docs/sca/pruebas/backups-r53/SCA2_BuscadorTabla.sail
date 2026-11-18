a!localVariables(
  /* [S4 ronda 5] Misma fuente que SCA_BuscadorTabla para Observaciones: consultarUltimaGestion(nuuma) una vez por carga de la tabla */
  local!usuario: rule!SCA2_obtenerInformacionUsuario(),
  local!ultimas: a!defaultValue(
    rule!SCA2_consultarUltimaGestionREST(
      nuuma: reduce(
        index(_, _, null),
        local!usuario,
        { "infoUsuarioDTO", "nuuma" }
      )
    ),
    {}
  ),
  local!ultimasIds: a!forEach(
    items: local!ultimas,
    expression: tostring(index(fv!item, "numSolicitud", null))
  ),
  local!gestionesPrecargadasIds: a!forEach(
    items: ri!data,
    expression: tostring(
      index(
        fv!item,
        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
        null
      )
    )
  ),
  local!gestionesPrecargadas: if(
    cons!SCA2_USAR_GESTION_PRECARGADA_BUSCADOR,
    a!forEach(
      items: ri!data,
      expression: a!localVariables(
        local!idSolicitud: tostring(
          index(
            fv!item,
            'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
            null
          )
        ),
        local!posCorePrecarga: if(
          a!isNullOrEmpty(local!ultimasIds),
          {},
          wherecontains(local!idSolicitud, touniformstring(local!ultimasIds))
        ),
        local!coreRowPrecarga: if(
          length(local!posCorePrecarga) > 0,
          index(local!ultimas, index(local!posCorePrecarga, 1, 0), null),
          null
        ),
        local!estCorePrecarga: tostring(
          a!defaultValue(index(local!coreRowPrecarga, "estSolicitud", null), "")
        ),
        a!map(
          g: if(
            a!isNotNullOrEmpty(local!estCorePrecarga),
            rule!SCA2_consultaGestion(codSolicitud: local!idSolicitud),
            null
          )
        )
      )
    ),
    {}
  ),
  local!mecPrecargadas: a!forEach(
    items: ri!data,
    expression: a!localVariables(
      local!idMec: tostring(index(fv!item, 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud', null)),
      local!estMec: tostring(index(index(local!ultimas, index(wherecontains(local!idMec, touniformstring(local!ultimasIds)), 1, 0), null), "estSolicitud", "")),
      local!mecTexto: if(
        and(a!isNotNullOrEmpty(local!idMec), contains({"2", "4", "5"}, local!estMec)),
        tostring(index(rule!SCA2_consultaBBDDSCA(
          idSolicitud: local!idMec,
          devolverSolicitud: false, devolverObservaciones: false,
          devolverGestiones: false, devolverMecanizacion: true,
          devolverAcciones: false, devolverAutorizaciones: false,
          devolverNotificaciones: false, devolverSGO: false, devolverCTO: false
        ), "mecanizacion", "")),
        ""
      ),
      local!codigo: trim(if(
        find("codTipEstMecaniza:", local!mecTexto) = 0,
        "",
        index(split(index(split(local!mecTexto, "codTipEstMecaniza:"), 2, ""), {",", "]"}), 1, "")
      )),
      a!map(codigo: if(a!isNullOrEmpty(local!codigo), cons!SCA2_TXT_COD_EST_MECANIZACION_SIN, local!codigo))
    )
  ),
  a!gridField_25r3(
    labelPosition: "ABOVE",
    label: "",
    emptyGridMessage: "No hay resultados para dicha búsqueda",
    /* Con totalCount informado (Buscador) se construye un DataSubset para que el grid pagine en servidor como SCA */
    data: if(
      or(
        a!isNullOrEmpty(ri!totalCount),
        a!isNullOrEmpty(ri!data)
      ),
      ri!data,
      'type!{http://www.appian.com/ae/types/2009}DataSubset'(
        startIndex: a!defaultValue(index(ri!pagingInfo, "startIndex", 1), 1),
        batchSize: a!defaultValue(index(ri!pagingInfo, "batchSize", 10), 10),
        sort: index(ri!pagingInfo, "sort", null),
        totalCount: ri!totalCount,
        data: ri!data,
        identifiers: enumerate(count(ri!data)) + a!defaultValue(index(ri!pagingInfo, "startIndex", 1), 1)
      )
    ),
    columns: {
      a!gridColumn(
        label: "Número solicitud",
        value: a!linkField(
          links: {
            a!dynamicLink(
              label: tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              saveInto: {
                a!save(
                  ri!idSel,
                  index(
                    fv!row,
                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                    null
                  )
                )
              }
            )
          }
        ),
        sortField: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud'
      ),
      a!gridColumn(
        label: "Estado",
        value: a!localVariables(
          /* HU3980 / paridad SCA_BuscadorTabla: etiqueta desde el estado CORE de la fila (consultarUltimaGestion) + consultaGestion; el estado del record SCA2 es respaldo */
          local!posCore: if(
            a!isNullOrEmpty(local!ultimasIds),
            {},
            wherecontains(
              tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              local!ultimasIds
            )
          ),
          local!coreRow: if(
            length(local!posCore) > 0,
            index(
              local!ultimas,
              index(local!posCore, 1, 0),
              null
            ),
            null
          ),
          local!estCore: tostring(
            a!defaultValue(
              index(local!coreRow, "estSolicitud", null),
              ""
            )
          ),
          local!posGestionPrecargada: if(
            a!isNullOrEmpty(local!gestionesPrecargadasIds),
            {},
            wherecontains(
              tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              touniformstring(local!gestionesPrecargadasIds)
            )
          ),
          local!datosGestionesPrecargados: if(
            length(local!posGestionPrecargada) > 0,
            index(
              index(
                local!gestionesPrecargadas,
                index(local!posGestionPrecargada, 1, 0),
                null
              ),
              "g",
              null
            ),
            null
          ),
          local!estadoTxt: if(
            a!isNotNullOrEmpty(local!estCore),
            rule!SCA2_calcularEstadoSolicitud(
              codEstMecaniza: index(index(local!mecPrecargadas, index(local!posGestionPrecargada, 1, 0), null), "codigo", cons!SCA2_TXT_COD_EST_MECANIZACION_SIN),
              estadoSolicitud: local!estCore,
              idSolicitud: tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              datosGestiones: if(
                cons!SCA2_USAR_GESTION_PRECARGADA_BUSCADOR,
                local!datosGestionesPrecargados,
                rule!SCA2_consultaGestion(
                codSolicitud: tostring(
                  index(
                    fv!row,
                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                    null
                  )
                )
              )
              )
            ),
            rule!SCA2_textoEstadoSolicitud(
              estado: index(
                fv!row,
                'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
                null
              )
            )
          ),
          a!tagField(
            tags: a!tagItem_24r2(
              text: local!estadoTxt,
              backgroundColor: rule!SCA2_colorEstadoSolicitud(estado: local!estadoTxt),
              textColor: cons!SCA2_VAL_COLOR_BLANCO
            ),
            align: "CENTER"
          )
        ),
        sortField: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud'
      ),
      a!gridColumn(
        label: "Fecha solicitud",
        value: a!localVariables(
          /* Paridad SCA_BuscadorTabla: la fila de CORE (consultarUltimaGestion) manda; el record SCA2 es respaldo */
          local!posCore: if(
            a!isNullOrEmpty(local!ultimasIds),
            {},
            wherecontains(
              tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              touniformstring(local!ultimasIds)
            )
          ),
          local!coreRow: if(
            length(local!posCore) > 0,
            index(
              local!ultimas,
              index(local!posCore, 1, 0),
              null
            ),
            null
          ),
          local!fecSolCore: index(local!coreRow, "fecSolicitud", null),
          /* Paridad SCA: fecSolicitud de Core7 persistida en el Alta (SCA2 Datos Solicitud.fecsolicitudanul); createdAt como respaldo */
          local!fecCore: index(
            index(
              index(
                fv!row,
                'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud',
                {}
              ),
              1,
              null
            ),
            'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{78fc061f-12bd-441e-aa55-dcff066af9fe}fecsolicitudanul',
            null
          ),
          if(
            a!isNotNullOrEmpty(local!fecSolCore),
            tostring(local!fecSolCore),
            if(
              a!isNotNullOrEmpty(local!fecCore),
              tostring(local!fecCore),
              if(
                a!isNullOrEmpty(
                  index(
                    fv!row,
                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
                    null
                  )
                ),
                "-",
                text(
                  index(
                    fv!row,
                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt',
                    null
                  ),
                  "dd/MM/yyyy HH:mm:ss"
                )
              )
            )
          )
        ),
        sortField: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt'
      ),
      a!gridColumn(
        label: "Número póliza",
        value: index(
          fv!row,
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza',
          null
        ),
        sortField: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{ea9a37fd-f033-4f83-ad3d-55d6d4a8ae7b}numPoliza'
      ),
      a!gridColumn(
        label: "Línea negocio",
        value: if(
          a!isNullOrEmpty(
            index(
              fv!row,
              'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio',
              null
            )
          ),
          "-",
          index(
            cons!SCA2_TXT_LINEA_NEGOCIO_CONSTANTE,
            tointeger(
              index(
                fv!row,
                'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio',
                null
              )
            ),
            "-"
          )
        ),
        sortField: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{2242a3b0-3166-45d7-91fc-3082f21a1a34}lineaNegocio'
      ),
      a!gridColumn(
        label: "Causa anulación",
        value: a!localVariables(
          /* Paridad SCA_BuscadorTabla: la fila de CORE (consultarUltimaGestion) manda; el record SCA2 es respaldo */
          local!posCore: if(
            a!isNullOrEmpty(local!ultimasIds),
            {},
            wherecontains(
              tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              touniformstring(local!ultimasIds)
            )
          ),
          local!coreRow: if(
            length(local!posCore) > 0,
            index(
              local!ultimas,
              index(local!posCore, 1, 0),
              null
            ),
            null
          ),
          local!codCausaCore: index(local!coreRow, "codCausaPca", null),
          local!codCausa: index(
            index(
              index(
                fv!row,
                'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud',
                {}
              ),
              1,
              null
            ),
            'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{d3ea438a-426e-4524-b46c-052fb101097d}codcausa',
            null
          ),
          if(
            a!isNotNullOrEmpty(local!codCausaCore),
            proper(
              a!defaultValue(
                index(
                  cons!SCA2_TXT_CAUSA_ANULACION,
                  tointeger(local!codCausaCore),
                  null
                ),
                "-"
              )
            ),
            proper(
              if(
                a!isNullOrEmpty(local!codCausa),
                a!defaultValue(
                  index(
                    index(
                      index(
                        fv!row,
                        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud',
                        {}
                      ),
                      1,
                      null
                    ),
                    'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{b3b05401-6420-4d28-8c0a-d55c0665a687}desccausa',
                    null
                  ),
                  "-"
                ),
                a!defaultValue(
                  index(
                    cons!SCA2_TXT_CAUSA_ANULACION,
                    tointeger(local!codCausa),
                    null
                  ),
                  index(
                    index(
                      index(
                        fv!row,
                        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud',
                        {}
                      ),
                      1,
                      null
                    ),
                    'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{b3b05401-6420-4d28-8c0a-d55c0665a687}desccausa',
                    null
                  ),
                  "-"
                )
              )
            )
          )
        )
      ),
      a!gridColumn(
        label: "Fecha resolución",
        value: a!localVariables(
          /* Paridad SCA_BuscadorTabla: la fila de CORE (consultarUltimaGestion) manda; el record SCA2 es respaldo */
          local!posCore: if(
            a!isNullOrEmpty(local!ultimasIds),
            {},
            wherecontains(
              tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              touniformstring(local!ultimasIds)
            )
          ),
          local!coreRow: if(
            length(local!posCore) > 0,
            index(
              local!ultimas,
              index(local!posCore, 1, 0),
              null
            ),
            null
          ),
          if(
            a!isNotNullOrEmpty(local!coreRow),
            a!defaultValue(
              index(local!coreRow, "fechaResolucion", "-"),
              "-"
            ),
            if(
              or(
                a!isNullOrEmpty(
                  index(
                    fv!row,
                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt',
                    null
                  )
                ),
                not(
                  contains(
                    {
                      cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                      cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR,
                      cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
                      "RECHAZADA",
                      "CANCELADA",
                      cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
                      cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA,
                      "ERROR"
                    },
                    tostring(
                      index(
                        fv!row,
                        'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
                        null
                      )
                    )
                  )
                )
              ),
              "-",
              text(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt',
                  null
                ),
                "dd/MM/yyyy HH:mm:ss"
              )
            )
          )
        ),
        sortField: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{022e0915-97a9-4742-b07f-1361765eee72}modifiedAt'
      ),
      a!gridColumn(
        label: "Observaciones",
        /* [S4 ronda 5] Paridad SCA_BuscadorTabla: SCA muestra fv!row.txtObs de consultarUltimaGestion(nuuma) = ultima observacion registrada en CORE
           (max codObs, incluida la traza tecnica que CORE escribe al crear la gestion de mecanizacion). Una sola llamada por carga (local!ultimas),
           join por numSolicitud; respaldo: observacion persistida por los CMD en SCA2 Datos Solicitud.fecimpresion. */
        value: a!localVariables(
          local!pos: if(
            a!isNullOrEmpty(local!ultimasIds),
            {},
            wherecontains(
              tostring(
                index(
                  fv!row,
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                  null
                )
              ),
              touniformstring(local!ultimasIds)
            )
          ),
          local!txtObs: if(
            length(local!pos) > 0,
            index(
              index(
                local!ultimas,
                index(local!pos, 1, 0),
                null
              ),
              "txtObs",
              null
            ),
            null
          ),
          if(
            a!isNotNullOrEmpty(local!txtObs),
            tostring(local!txtObs),
            a!defaultValue(
              index(
                index(
                  index(
                    fv!row,
                    'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.relationships.{63161335-1bdd-4c7a-82eb-3560786a41d5}datosSolicitud',
                    {}
                  ),
                  1,
                  null
                ),
                'recordType!{9a9209c7-aab4-4078-9bef-280de47fdd6e}SCA2 Datos Solicitud.fields.{ef1b0aa7-41ee-4590-83b2-52f89c8be7f5}fecimpresion',
                null
              ),
              "-"
            )
          )
        )
      )
    },
    pagingSaveInto: ri!pagingInfo,
    initialSorts: if(
      a!isNullOrEmpty(ri!totalCount),
      {
        a!sortInfo(
          field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{331a1fda-174e-4caf-976e-0e259856800f}createdAt'
        )
      },
      null
    ),
    validations: {}
  )
)