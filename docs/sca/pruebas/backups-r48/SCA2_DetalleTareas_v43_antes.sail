a!localVariables(
  local!pagingInfo: a!pagingInfo(
    startIndex: 1,
    batchSize: 10,
    sort: {
      a!sortInfo(
        field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
        ascending: false
      )
    }
  ),
  local!q: a!queryRecordType(
    recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
    filters: a!queryLogicalExpression(
      operator: "AND",
      filters: {
        a!queryFilter(
          field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
          operator: "=",
          value: if(
            a!isNullOrEmpty(ri!idSolicitud),
            "\u0001",
            ri!idSolicitud
          )
        )
      }
    ),
    fields: {
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo',
      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{9630cc5f-a395-4247-9fa1-5eaf51984c08}fechaCaducidad'
    },
    pagingInfo: local!pagingInfo,
    fetchTotalCount: true
  ),
  local!hecho: false,
  /* R42-A: COMPROBAR AHORA fuerza la relectura inmediata de las consultas de espera */
  local!comprobarAhora: 0,
  local!anularPulsado: false,
  local!comprobandoInduccion: false,
  /* Redirección tras ACEPTAR (paridad SCA: la mecanización se abre en la misma cadena): pantalla/tarea locales, sin depender de los parámetros de URL del site */
  local!pantallaTras,
  local!pantallaActual: a!match(
    value: a!defaultValue(
      local!pantallaTras,
      tostring(ri!tipoAccion)
    ),
    equals: cons!SCA2_TXT_ACCION_AUTORIZACION,
    then: cons!SCA2_TXT_ACCION_AUTORIZACION,
    equals: "AUTORIZACION NIVEL 2",
    then: cons!SCA2_TXT_ACCION_AUTORIZACION,
    equals: "AUTORIZACION NIVEL 3",
    then: cons!SCA2_TXT_ACCION_AUTORIZACION,
    equals: cons!SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS,
    then: "ACC ADM",
    equals: "ACCIONES ADMINISTRATIVAS NIVEL 2",
    then: "ACC ADM",
    equals: "ACCIONES ADMINISTRATIVAS NIVEL 3",
    then: "ACC ADM",
    equals: "ACC ADM",
    then: "ACC ADM",
    equals: cons!SCA2_TXT_ACCION_CONTRAANULAR,
    then: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
    equals: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
    then: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
    equals: "CONTRA ANULAR NIVEL 2",
    then: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
    equals: "CONTRA ANULAR NIVEL 3",
    then: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
    equals: cons!SCA2_TXT_ACCION_MECANIZAR,
    then: "MECANIZACION",
    equals: "MECANIZAR NIVEL 2",
    then: "MECANIZACION",
    equals: "MECANIZAR NIVEL 3",
    then: "MECANIZACION",
    equals: "MECANIZACION",
    then: "MECANIZACION",
    equals: cons!SCA2_TXT_CONTACTO_VERTI,
    then: cons!SCA2_TXT_CONTACTO_VERTI,
    equals: "INDUCCION",
    then: "INDUCCION",
    default: ""
  ),
  local!idTareaTras,
  /* [R9-B B5/B7-SI24] nivel, estado y subperfil (motor) de la solicitud para decidir si se puede Completar la tarea */
  local!solR9B: index(
    index(
      a!queryRecordType(
        recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
        filters: a!queryLogicalExpression(
          operator: "AND",
          filters: {
            a!queryFilter(
              field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
              operator: "=",
              value: a!defaultValue(ri!idSolicitud, "#")
            )
          }
        ),
        fields: {
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6da95481-fa80-4768-9b86-2fae6259874e}nivelIntervencion'
        },
        pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
        fetchTotalCount: false
      ),
      "data",
      {}
    ),
    1,
    null
  ),
  local!nivelSol: tostring(
    index(
      local!solR9B,
      'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{6da95481-fa80-4768-9b86-2fae6259874e}nivelIntervencion',
      null
    )
  ),
  local!estadoSol: upper(
    a!defaultValue(
      tostring(
        index(
          local!solR9B,
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
          null
        )
      ),
      ""
    )
  ),
  local!subPerfilSol: tostring(
    index(
      index(
        index(
          a!queryRecordType(
            recordType: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(
                  field: 'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{116b0806-8137-44e8-93a6-ae2a50704514}idSolicitud',
                  operator: "=",
                  value: a!defaultValue(ri!idSolicitud, "#")
                )
              }
            ),
            fields: {
              'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{9e7da6f2-78d1-4f46-bfdf-ba8fe8a70e10}codsubperfil'
            },
            pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
            fetchTotalCount: false
          ),
          "data",
          {}
        ),
        1,
        null
      ),
      'recordType!{284ca30d-11c7-49ea-9de0-15f2193e8f32}SCA2 Datos Perfiles Pca.fields.{9e7da6f2-78d1-4f46-bfdf-ba8fe8a70e10}codsubperfil',
      null
    )
  ),
  local!procesoActivoSol: a!refreshVariable(
    value: if(
      a!isNullOrEmpty(ri!idSolicitud),
      null,
      tostring(
        index(
          index(
            index(
              a!queryRecordType(
                recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
                filters: a!queryLogicalExpression(
                  operator: "AND",
                  filters: {
                    a!queryFilter(
                      field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                      operator: "=",
                      value: ri!idSolicitud
                    )
                  }
                ),
                fields: {
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo'
                },
                pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                fetchTotalCount: false
              ),
              "data",
              {}
            ),
            1,
            null
          ),
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo',
          null
        )
      )
    ),
    refreshOnVarChange: { ri!idSolicitud, local!hecho, local!comprobarAhora },
    refreshInterval: if(local!hecho, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60, null)
  ),
  local!anulacionEnviada: and(
    local!pantallaActual = "MECANIZACION",
    tostring(local!procesoActivoSol) = "ANL"
  ),
  /* Estado de la solicitud sondeado tras completar: la decisión posterior puede acabar sin tarea MECANIZAR (NO MECANIZAR → cambio de nivel / FIN PROCESO), paridad SCA_Particion */
  local!estadoSolPoll: a!refreshVariable(
    value: if(
      or(
        not(local!hecho),
        a!isNullOrEmpty(ri!idSolicitud)
      ),
      null,
      tostring(
        index(
          index(
            index(
              a!queryRecordType(
                recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
                filters: a!queryLogicalExpression(
                  operator: "AND",
                  filters: {
                    a!queryFilter(
                      field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                      operator: "=",
                      value: ri!idSolicitud
                    )
                  }
                ),
                fields: {
                  'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud'
                },
                pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                fetchTotalCount: false
              ),
              "data",
              {}
            ),
            1,
            null
          ),
          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
          null
        )
      )
    ),
    refreshOnVarChange: { ri!idSolicitud, local!hecho, local!comprobarAhora },
    refreshInterval: if(local!hecho, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60, null)
  ),
  /* Otra tarea PENDIENTE (distinta de la recién completada): la decisión ha continuado por otra acción/nivel */
  local!tareaPendiente: a!refreshVariable(
    value: if(
      or(
        not(local!hecho),
        a!isNullOrEmpty(ri!idSolicitud),
        local!pantallaActual = "MECANIZACION"
      ),
      null,
      index(
        index(
          a!queryRecordType(
            recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
                  operator: "=",
                  value: ri!idSolicitud
                ),
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                  operator: "=",
                  value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE
                ),
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                  operator: "<>",
                  value: ri!idTareaAccion,
                  applyWhen: a!isNotNullOrEmpty(ri!idTareaAccion)
                ),
                /* R29-A: tras un salto en la misma pantalla (pantallaTras) la tarea recién gestionada es local!idTareaTras; INDUCCION es interna */
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                  operator: "<>",
                  value: local!idTareaTras,
                  applyWhen: a!isNotNullOrEmpty(local!idTareaTras)
                ),
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                  operator: "<>",
                  value: "INDUCCION"
                )
              }
            ),
            fields: {
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo'
            },
            pagingInfo: a!pagingInfo(
              startIndex: 1,
              batchSize: 1,
              sort: a!sortInfo(
                field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                ascending: false
              )
            )
          ),
          "data",
          {}
        ),
        1,
        null
      )
    ),
    refreshOnVarChange: { local!hecho, local!comprobarAhora },
    refreshInterval: cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60
  ),
  /* Estado de la tarea recién gestionada: COMPLETADA = decisión en curso; PENDIENTE + transición CMD Posponer posterior = pospuesta; CANCELADA = cancelada */
  local!tareaAccionEstado: a!refreshVariable(
    value: if(
      or(
        not(local!hecho),
        a!isNullOrEmpty(
          a!defaultValue(local!idTareaTras, ri!idTareaAccion)
        )
      ),
      null,
      tostring(
        index(
          index(
            index(
              a!queryRecordType(
                recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                filters: a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                  operator: "=",
                  value: a!defaultValue(local!idTareaTras, ri!idTareaAccion)
                ),
                fields: {
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado'
                },
                pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                fetchTotalCount: false
              ),
              "data",
              {}
            ),
            1,
            null
          ),
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
          null
        )
      )
    ),
    refreshOnVarChange: {
      ri!idTareaAccion,
      local!idTareaTras,
      local!hecho,
      local!comprobarAhora
    },
    refreshInterval: if(local!hecho, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60, null)
  ),
  /* Última transición registrada: tras POSPONER (CMD Posponer) no hay decisión posterior que esperar */
  local!ultimaTransicion: a!refreshVariable(
    value: if(
      or(
        not(local!hecho),
        a!isNullOrEmpty(ri!idSolicitud)
      ),
      null,
      index(
        index(
          a!queryRecordType(
            recordType: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion',
            filters: a!queryFilter(
              field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{b2f33c59-6234-472c-b7ec-5065bbdc20fd}idSolicitud',
              operator: "=",
              value: ri!idSolicitud
            ),
            fields: {
              'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{cb874e4d-61fb-4bd1-8062-e138a364eb82}comando',
              'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha'
            },
            pagingInfo: a!pagingInfo(
              startIndex: 1,
              batchSize: 1,
              sort: a!sortInfo(
                field: 'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha',
                ascending: false
              )
            ),
            fetchTotalCount: false
          ),
          "data",
          {}
        ),
        1,
        null
      )
    ),
    refreshOnVarChange: { ri!idSolicitud, local!hecho, local!comprobarAhora },
    refreshInterval: if(local!hecho, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60, null)
  ),
  local!accionCerrada: a!defaultValue(local!tareaAccionEstado, "") = cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA,
  local!tsHecho: a!refreshVariable(
    value: now(),
    refreshOnVarChange: local!hecho
  ),
  local!accionPospuesta: and(
    local!hecho,
    a!isNotNullOrEmpty(local!ultimaTransicion),
    left(
      upper(
        tostring(
          index(
            local!ultimaTransicion,
            'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{cb874e4d-61fb-4bd1-8062-e138a364eb82}comando',
            ""
          )
        )
      ),
      17
    ) = "SCA2 CMD POSPONER",
    a!defaultValue(
      index(
        local!ultimaTransicion,
        'recordType!{0b46024c-58b4-48be-a2a4-20d54bc40815}SCA2 Transicion.fields.{430f97d9-9430-4dab-86e6-4ac327b05db1}fecha',
        null
      ),
      local!tsHecho - intervalds(0, 0, 1)
    ) >= local!tsHecho - intervalds(0, 1, 0)
  ),
  local!ahora: a!refreshVariable(value: now(), refreshOnVarChange: local!comprobarAhora, refreshInterval: cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60),
  local!esperaAgotada: and(
    local!hecho,
    local!ahora > a!addDateTime(startDateTime: local!tsHecho, seconds: cons!SCA2_VAL_ESPERA_AGOTADA_SEGUNDOS)
  ),
  local!accionEnCurso: and(
    local!hecho,
    local!pantallaActual <> "MECANIZACION",
    not(local!accionCerrada),
    not(local!accionPospuesta),
    a!defaultValue(local!tareaAccionEstado, cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE) = cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
    not(local!esperaAgotada)
  ),
  /* Paridad SCA (SCA_GenerarSolicitudPopup "Se va a redirigir a la anulación."): tras completar, si el motor ha creado una tarea MECANIZAR pendiente, ACEPTAR la abre */
  local!tareaMecanizar: a!refreshVariable(
    value: if(
      or(
        not(local!hecho),
        a!isNullOrEmpty(ri!idSolicitud),
        local!pantallaActual = "MECANIZACION"
      ),
      null,
      index(
        index(
          a!queryRecordType(
            recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
            filters: a!queryLogicalExpression(
              operator: "AND",
              filters: {
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
                  operator: "=",
                  value: ri!idSolicitud
                ),
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                  operator: "=",
                  value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE
                ),
                a!queryFilter(
                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                  operator: "starts with",
                  value: cons!SCA2_TXT_ACCION_MECANIZAR
                )
              }
            ),
            pagingInfo: a!pagingInfo(
              startIndex: 1,
              batchSize: 1,
              sort: a!sortInfo(
                field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                ascending: false
              )
            )
          ),
          "data",
          {}
        ),
        1,
        null
      )
    ),
    refreshOnVarChange: { local!hecho, local!comprobarAhora },
    refreshInterval: cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60
  ),
  /* Paridad SCA_GenerarSolicitudPopup(mecanizar: true): la frase de redirección depende del resultado CORE (CA FINALIZADA NEGATIVA), no de que la tarea MECANIZAR ya exista */
  local!caNegativa: a!refreshVariable(
    value: if(
      or(
        not(local!hecho),
        a!isNullOrEmpty(ri!idSolicitud),
        not(local!accionCerrada)
      ),
      false,
      a!isNotNullOrEmpty(
        reject(
          fn!isnull,
          a!forEach(
            items: a!defaultValue(
              index(
                rule!SCA2_consultaGestion(codSolicitud: ri!idSolicitud),
                "MSSConsultaGestion",
                {}
              ),
              {}
            ),
            expression: if(
              and(
                tostring(index(fv!item, "accionRealizada", "")) = "2",
                upper(
                  tostring(
                    a!defaultValue(index(fv!item, "codEstGestion", null), "")
                  )
                ) = "FINALIZADA NEGATIVA"
              ),
              fv!item,
              null
            )
          )
        )
      )
    ),
    refreshOnVarChange: { local!hecho, local!accionCerrada, local!comprobarAhora }
  ),
  /* CA negativa cuya decisión posterior NO crea tarea MECANIZAR (NO MECANIZAR → IR A NIVEL / FIN PROCESO / otra acción): ACEPTAR vuelve al buscador como en SCA */
  local!decisionSinMecanizar: and(
    local!hecho,
    local!caNegativa,
    a!isNullOrEmpty(local!tareaMecanizar),
    or(
      a!isNotNullOrEmpty(local!tareaPendiente),
      contains(
        {
          "FIN",
          cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
          "FINALIZADA_ANULADA",
          "FINALIZADA_RECHAZADA_ANULACION",
          cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO,
          "FINALIZADA_NEGATIVO",
          "FINALIZADA_CANCELADA",
          "RECHAZADA",
          "CANCELADA",
          cons!SCA2_TXT_ESTADO_SOL_CADUCADA,
          cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
          "PDTE_REDIRECCION_VIDA",
          "ERROR",
          "ERROR_DECISION"
        },
        upper(tostring(local!estadoSolPoll))
      ),
      local!esperaAgotada
    )
  ),
  /* R42-A: si la acción ya está cerrada pero la decisión aún no ha creado la siguiente tarea ni cerrado la solicitud (respaldo/sondeo), se sigue esperando: evita habilitar ACEPTAR antes de tiempo */
  local!esperandoDecision: and(
    local!hecho,
    local!pantallaActual <> "MECANIZACION",
    local!accionCerrada,
    not(local!accionPospuesta),
    not(local!caNegativa),
    a!isNullOrEmpty(local!tareaPendiente),
    a!isNullOrEmpty(local!tareaMecanizar),
    a!isNotNullOrEmpty(local!estadoSolPoll),
    not(
      or(
        left(upper(tostring(local!estadoSolPoll)), 9) = "FINALIZAD",
        contains(
          {
            "FIN",
            "RECHAZADA",
            "CANCELADA",
            upper(cons!SCA2_TXT_ESTADO_SOL_CADUCADA),
            "PDTE_REDIRECCION_VIDA",
            "ERROR",
            "ERROR_DECISION"
          },
          upper(tostring(local!estadoSolPoll))
        )
      )
    ),
    not(local!esperaAgotada)
  ),
  /* R29-A (analista 23/10): siguiente tarea de la solicitud creada por el motor tras completar la acción.
     ACEPTAR la abre aquí mismo (sin pasar por el buscador) si está asignada al usuario conectado; si no, va al Detalle.
     Las tareas de nivel > 1 (p. ej. CONTRA ANULAR NIVEL 2) se abren desde el Detalle con RETOMAR (registra la captura en CORE, R24 #12). */
  local!sigTipo: upper(
    a!defaultValue(
      tostring(
        index(
          local!tareaPendiente,
          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
          null
        )
      ),
      ""
    )
  ),
  local!sigNombre: a!defaultValue(
    tostring(
      index(
        local!tareaPendiente,
        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
        null
      )
    ),
    ""
  ),
  local!sigPantalla: if(
    search("NIVEL", local!sigTipo) > 0,
    "",
    if(
      left(local!sigTipo, 6) = "CONTRA",
      cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
      if(
        left(local!sigTipo, 9) = cons!SCA2_TXT_ACCION_MECANIZAR,
        "MECANIZACION",
        if(
          local!sigTipo = cons!SCA2_TXT_CONTACTO_VERTI,
          cons!SCA2_TXT_CONTACTO_VERTI,
          if(
            left(local!sigTipo, 3) = "ACC",
            "ACC ADM",
            if(
              left(local!sigTipo, 12) = cons!SCA2_TXT_ACCION_AUTORIZACION,
              cons!SCA2_TXT_ACCION_AUTORIZACION,
              ""
            )
          )
        )
      )
    )
  ),
  local!sigEsMia: and(
    a!isNotNullOrEmpty(local!tareaPendiente),
    upper(
      a!defaultValue(
        tostring(
          index(
            local!tareaPendiente,
            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
            null
          )
        ),
        ""
      )
    ) = upper(tostring(loggedInUser()))
  ),
  if(
    ri!accionAbierta,
    {
      /* VOLVER AL DETALLE: navegación a la página del Detalle (recarga completa, como vuelve SCA por navegación) */
      a!richTextDisplayField(
        labelPosition: "COLLAPSED",
        value: a!richTextItem(
          text: {
            a!richTextIcon(icon: "arrow-left"),
            " VOLVER AL DETALLE"
          },
          link: a!safeLink(
            uri: a!urlForSite(
              sitePage: 'site!{bb62c468-0f71-4985-980a-6db65a9dc1f5}SCA2 Anulaciones.pages.{ee42d0ad-aae1-442e-be8e-3e954e6a193d}buscador',
              urlParameters: a!map(idSolicitud: ri!idSolicitud)
            ),
            openLinkIn: "SAME_TAB"
          ),
          linkStyle: "STANDALONE",
          color: cons!SCA2_VAL_COLOR_ROJO
        ),
        align: "RIGHT"
      ),
      if(
        local!hecho,
        /* Popup paridad SCA_PopUpMensajeAutorizacion (CORRECTO) — ACEPTAR vuelve al buscador */
        a!cardLayout(
          contents: {
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextIcon(
                icon: "check-circle",
                color: "SECONDARY",
                size: "EXTRA_LARGE"
              ),
              align: "CENTER"
            ),
            a!horizontalLine(),
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "CORRECTO",
                style: "STRONG",
                size: "MEDIUM_PLUS"
              ),
              align: "CENTER"
            ),
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "Los datos se han guardado correctamente",
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER"
            ),
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: if(
                  local!pantallaActual = "MECANIZACION",
                  "La anulación se ha lanzado al sistema de emisión.",
                  "Se va a redirigir a la anulación."
                ),
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER",
              showWhen: if(
                local!pantallaActual = "MECANIZACION",
                or(
                  local!anularPulsado,
                  local!anulacionEnviada
                ),
                a!isNotNullOrEmpty(local!tareaMecanizar)
              )
            ),
            /* R28 (23/10): panel «Inducción Verti (componente Inducir Cliente)» (rule!SCA2_InduccionVertiPanel, R26) retirado:
             el componente se ejecuta entero, síncrono y encadenado tras ANULAR PÓLIZA (a!startProcessLink + Sub-Process en CMD Mecanizar). */
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "Comprobando si procede la inducción Verti/vencimiento… pulse ACEPTAR de nuevo en unos segundos.",
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER",
              showWhen: and(
                local!comprobandoInduccion,
                local!pantallaActual = "MECANIZACION",
                local!hecho
              )
            ),
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "Procesando la decisión de la solicitud…",
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER",
              showWhen: and(
                local!pantallaActual <> "MECANIZACION",
                or(
                  local!accionEnCurso,
                  local!esperandoDecision,
                  and(
                    local!caNegativa,
                    a!isNullOrEmpty(local!tareaMecanizar),
                    not(local!decisionSinMecanizar)
                  )
                )
              )
            ),
            /* R42-A: la acción se lanza síncrona; si al volver aún no está la siguiente gestión se mantiene el sondeo con aviso y COMPROBAR AHORA */
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: cons!SCA2_TXT_ESPERA_DECISION_ADICIONAL,
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER",
              showWhen: and(
                local!pantallaActual <> "MECANIZACION",
                or(
                  local!accionEnCurso,
                  local!esperandoDecision,
                  and(
                    local!caNegativa,
                    a!isNullOrEmpty(local!tareaMecanizar),
                    not(local!decisionSinMecanizar)
                  )
                )
              )
            ),
            a!buttonArrayLayout(
              buttons: a!buttonWidget(
                label: cons!SCA2_TXT_COMPROBAR_AHORA,
                style: "OUTLINE",
                color: cons!SCA2_VAL_COLOR_ROJO,
                saveInto: a!save(local!comprobarAhora, local!comprobarAhora + 1)
              ),
              align: "CENTER",
              showWhen: or(
                and(
                local!pantallaActual <> "MECANIZACION",
                or(
                  local!accionEnCurso,
                  local!esperandoDecision,
                  and(
                    local!caNegativa,
                    a!isNullOrEmpty(local!tareaMecanizar),
                    not(local!decisionSinMecanizar)
                  )
                )
              ),
                and(
                  local!comprobandoInduccion,
                  local!pantallaActual = "MECANIZACION",
                  local!hecho
                )
              )
            ),
            /* R29-A: aviso de la siguiente tarea (no MECANIZAR: esa ya tiene «Se va a redirigir a la anulación.») */
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: if(
                  /* R45-C C2: la Gestión Verti/Vencimiento sin asignar (grupo SCA2) también se abre; nunca la asignada a otro usuario */
                  and(or(local!sigEsMia, and(local!sigTipo = cons!SCA2_TXT_CONTACTO_VERTI, a!isNullOrEmpty(index(local!tareaPendiente, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA', null)))), local!sigPantalla <> ""),
                  "Se va a redirigir a la siguiente tarea: " & proper(local!sigNombre) & ".",
                  "La siguiente tarea (" & proper(local!sigNombre) & ") se gestiona desde el Detalle de la solicitud."
                ),
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER",
              showWhen: and(
                local!pantallaActual <> "MECANIZACION",
                a!isNotNullOrEmpty(local!tareaPendiente),
                a!isNullOrEmpty(local!tareaMecanizar),
                not(local!accionEnCurso)
              )
            ),
            a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "No se ha podido abrir la pantalla de anulación. Consulte el Detalle de la solicitud.",
                style: "PLAIN",
                size: "MEDIUM"
              ),
              align: "CENTER",
              showWhen: and(
                local!pantallaActual <> "MECANIZACION",
                local!decisionSinMecanizar,
                local!esperaAgotada,
                a!isNullOrEmpty(local!tareaPendiente)
              )
            ),
            a!buttonLayout(
              primaryButtons: a!buttonWidget(
                label: "ACEPTAR",
                style: "SOLID",
                color: cons!SCA2_VAL_COLOR_ROJO,
                disabled: or(
                  local!accionEnCurso,
                  local!esperandoDecision,
                  and(
                    local!pantallaActual <> "MECANIZACION",
                    local!caNegativa,
                    a!isNullOrEmpty(local!tareaMecanizar),
                    not(local!decisionSinMecanizar)
                  )
                ),
                saveInto: if(
                  local!pantallaActual = "MECANIZACION",
                  /* Tras ANULAR PÓLIZA: si el motor pidió inducción, CMD Mecanizar ha creado la tarea VERTI → se abre la pantalla de inducción en la misma cadena */
                  a!localVariables(
                    local!tareaVerti: index(
                      index(
                        a!queryRecordType(
                          recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                          filters: a!queryLogicalExpression(
                            operator: "AND",
                            filters: {
                              a!queryFilter(
                                field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
                                operator: "=",
                                value: ri!idSolicitud
                              ),
                              a!queryFilter(
                                field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                                operator: "=",
                                value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE
                              ),
                              a!queryFilter(
                                field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                                operator: "=",
                                value: cons!SCA2_TXT_CONTACTO_VERTI
                              )
                            }
                          ),
                          fields: {
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id'
                          },
                          pagingInfo: a!pagingInfo(
                            startIndex: 1,
                            batchSize: 1,
                            sort: a!sortInfo(
                              field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                              ascending: false
                            )
                          ),
                          fetchTotalCount: false
                        ),
                        "data",
                        {}
                      ),
                      1,
                      null
                    ),
                    /* Lectura fresca en el clic: CMD Mecanizar es asíncrono (tarea VERTI o MECANIZADA/ANL); mientras siga en MECANIZAR sin decidir, el popup se mantiene */
                    local!solAhora: index(
                      index(
                        a!queryRecordType(
                          recordType: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud',
                          filters: a!queryLogicalExpression(
                            operator: "AND",
                            filters: {
                              a!queryFilter(
                                field: 'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{f2b6f90b-183b-493e-81c1-d1dd65a6cbd9}idSolicitud',
                                operator: "=",
                                value: ri!idSolicitud
                              )
                            }
                          ),
                          fields: {
                            'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{b32247b9-b752-4358-8764-f21df479a82a}interfazActiva',
                            'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo',
                            'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud'
                          },
                          pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                          fetchTotalCount: false
                        ),
                        "data",
                        {}
                      ),
                      1,
                      null
                    ),
                    local!sinDecidir: and(
                      a!isNullOrEmpty(local!tareaVerti),
                      tostring(
                        index(
                          local!solAhora,
                          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{074b8e94-466e-4e45-8fed-074610396bed}procesoActivo',
                          null
                        )
                      ) = cons!SCA2_TXT_ACCION_MECANIZAR,
                      tostring(
                        index(
                          local!solAhora,
                          'recordType!{c531595c-c3b5-454c-a355-8145e7e27e9a}SCA2 Solicitud.fields.{65f4378b-cf90-4761-b1d0-16ace177a82c}estadoSolicitud',
                          null
                        )
                      ) = cons!SCA2_TXT_ESTADO_SOL_EN_ACCION,
                      not(local!esperaAgotada)
                    ),
                    if(
                      a!isNotNullOrEmpty(local!tareaVerti),
                      {
                        a!save(
                          local!idTareaTras,
                          index(
                            local!tareaVerti,
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                            null
                          )
                        ),
                        a!save(local!pantallaTras, cons!SCA2_TXT_CONTACTO_VERTI),
                        a!save(local!comprobandoInduccion, false),
                        a!save(local!hecho, false),
                        a!save(local!anularPulsado, false)
                      },
                      if(
                        local!sinDecidir,
                        a!save(local!comprobandoInduccion, true),
                        {
                          a!save(ri!accionAbierta, false),
                          a!save(ri!tipoAccion, null),
                          a!save(ri!idTareaAccion, null),
                          a!save(local!hecho, false),
                          a!save(local!anularPulsado, false),
                          a!save(ri!idSolicitud, null),
                          a!save(local!pantallaTras, null),
                          a!save(local!idTareaTras, null)
                        }
                      )
                    )
                  ),
                  a!localVariables(
                    /* Consulta directa en el saveInto: local!tareaMecanizar se calculó antes del clic y el CMD (CompletarAccion → Decidir → CrearAccion) puede tardar unos segundos en crear la tarea MECANIZAR */
                    local!tareaMec: a!defaultValue(
                      local!tareaMecanizar,
                      index(
                        index(
                          a!queryRecordType(
                            recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                            filters: a!queryLogicalExpression(
                              operator: "AND",
                              filters: {
                                a!queryFilter(
                                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
                                  operator: "=",
                                  value: ri!idSolicitud
                                ),
                                a!queryFilter(
                                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                                  operator: "=",
                                  value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE
                                ),
                                a!queryFilter(
                                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                                  operator: "starts with",
                                  value: cons!SCA2_TXT_ACCION_MECANIZAR
                                )
                              }
                            ),
                            pagingInfo: a!pagingInfo(
                              startIndex: 1,
                              batchSize: 1,
                              sort: a!sortInfo(
                                field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                                ascending: false
                              )
                            )
                          ),
                          "data",
                          {}
                        ),
                        1,
                        null
                      )
                    ),
                    /* R29-A: lectura fresca de la siguiente tarea en el clic (local!tareaPendiente se sondea cada 30 s) */
                    local!sigT: a!defaultValue(
                      local!tareaPendiente,
                      if(
                        a!isNullOrEmpty(ri!idSolicitud),
                        null,
                        index(
                          index(
                            a!queryRecordType(
                              recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                              filters: a!queryLogicalExpression(
                                operator: "AND",
                                filters: {
                                  a!queryFilter(
                                    field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{32e5a534-ad1a-4f96-b824-41690f0aba43}idSolicitud',
                                    operator: "=",
                                    value: ri!idSolicitud
                                  ),
                                  a!queryFilter(
                                    field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                                    operator: "=",
                                    value: cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE
                                  ),
                                  a!queryFilter(
                                    field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                                    operator: "<>",
                                    value: ri!idTareaAccion,
                                    applyWhen: a!isNotNullOrEmpty(ri!idTareaAccion)
                                  ),
                                  a!queryFilter(
                                    field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                                    operator: "<>",
                                    value: local!idTareaTras,
                                    applyWhen: a!isNotNullOrEmpty(local!idTareaTras)
                                  ),
                                  a!queryFilter(
                                    field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                                    operator: "<>",
                                    value: "INDUCCION"
                                  )
                                }
                              ),
                              fields: {
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo'
                              },
                              pagingInfo: a!pagingInfo(
                                startIndex: 1,
                                batchSize: 1,
                                sort: a!sortInfo(
                                  field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                                  ascending: false
                                )
                              )
                            ),
                            "data",
                            {}
                          ),
                          1,
                          null
                        )
                      )
                    ),
                    local!sigTTipo: upper(
                      a!defaultValue(
                        tostring(
                          index(
                            local!sigT,
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                            null
                          )
                        ),
                        ""
                      )
                    ),
                    local!sigTPantalla: if(
                      search("NIVEL", local!sigTTipo) > 0,
                      "",
                      if(
                        left(local!sigTTipo, 6) = "CONTRA",
                        cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
                        if(
                          left(local!sigTTipo, 9) = cons!SCA2_TXT_ACCION_MECANIZAR,
                          "MECANIZACION",
                          if(
                            local!sigTTipo = cons!SCA2_TXT_CONTACTO_VERTI,
                            cons!SCA2_TXT_CONTACTO_VERTI,
                            if(
                              left(local!sigTTipo, 3) = "ACC",
                              "ACC ADM",
                              if(
                                left(local!sigTTipo, 12) = cons!SCA2_TXT_ACCION_AUTORIZACION,
                                cons!SCA2_TXT_ACCION_AUTORIZACION,
                                ""
                              )
                            )
                          )
                        )
                      )
                    ),
                    local!sigTEsMia: upper(
                      a!defaultValue(
                        tostring(
                          index(
                            local!sigT,
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                            null
                          )
                        ),
                        ""
                      )
                    ) = upper(tostring(loggedInUser())),
                    if(
                      a!isNotNullOrEmpty(local!tareaMec),
                      {
                        a!save(
                          local!idTareaTras,
                          index(
                            local!tareaMec,
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                            null
                          )
                        ),
                        a!save(local!pantallaTras, "MECANIZACION"),
                        a!save(local!hecho, false)
                      },
                      if(
                        and(
                          a!isNotNullOrEmpty(local!sigT),
                          /* R45-C C2: la Gestión Verti/Vencimiento que sigue a la CA se abre aquí si es mía o está sin asignar (grupo SCA2); nunca la asignada a otro usuario */
                          or(local!sigTEsMia, and(local!sigTTipo = cons!SCA2_TXT_CONTACTO_VERTI, a!isNullOrEmpty(index(local!sigT, 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA', null)))),
                          local!sigTPantalla <> ""
                        ),
                        /* siguiente tarea del usuario (p. ej. Gestión Verti/Vencimiento tras la CA negativa): se abre aquí, sin buscador */
                        {
                          a!save(
                            local!idTareaTras,
                            index(
                              local!sigT,
                              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                              null
                            )
                          ),
                          a!save(local!pantallaTras, local!sigTPantalla),
                          a!save(local!hecho, false)
                        },
                        if(
                          a!isNotNullOrEmpty(local!sigT),
                          /* siguiente tarea de otro usuario/grupo o de nivel > 1: Detalle de la solicitud (no buscador) */
                          {
                            a!save(ri!accionAbierta, false),
                            a!save(ri!tipoAccion, null),
                            a!save(ri!idTareaAccion, null),
                            a!save(local!hecho, false),
                            a!save(local!pantallaTras, null),
                            a!save(local!idTareaTras, null)
                          },
                          if(
                            or(
                              local!accionEnCurso,
                              local!esperandoDecision,
                              and(
                                local!caNegativa,
                                not(local!decisionSinMecanizar)
                              )
                            ),
                            {},
                            {
                              a!save(ri!accionAbierta, false),
                              a!save(ri!tipoAccion, null),
                              a!save(ri!idTareaAccion, null),
                              a!save(local!hecho, false),
                              a!save(ri!idSolicitud, null)
                            }
                          )
                        )
                      )
                    )
                  )
                )
              ),
              /* En MECANIZACION el botón decide entre inducción Verti (misma cadena) y buscador */
              showWhen: or(
                local!pantallaActual = "MECANIZACION",
                not(local!decisionSinMecanizar),
                a!isNotNullOrEmpty(local!tareaPendiente)
              )
            ),
            a!columnsLayout(
              columns: {
                a!columnLayout(),
                a!columnLayout(
                  width: "NARROW",
                  contents: {
                    a!cardLayout(
                      contents: a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: "ACEPTAR",
                          color: cons!SCA2_VAL_COLOR_BLANCO,
                          style: "STRONG"
                        ),
                        align: "CENTER"
                      ),
                      link: a!safeLink(
                        uri: a!urlForSite(
                          sitePage: 'site!{bb62c468-0f71-4985-980a-6db65a9dc1f5}SCA2 Anulaciones.pages.{ee42d0ad-aae1-442e-be8e-3e954e6a193d}buscador'
                        ),
                        openLinkIn: "SAME_TAB"
                      ),
                      style: cons!SCA2_VAL_COLOR_ROJO,
                      showBorder: false,
                      padding: "STANDARD",
                      accessibilityText: "Aceptar"
                    )
                  }
                )
              },
              showWhen: and(
                local!pantallaActual <> "MECANIZACION",
                local!decisionSinMecanizar,
                a!isNullOrEmpty(local!tareaPendiente)
              )
            )
          },
          style: "TRANSPARENT",
          marginAbove: "EVEN_MORE"
        ),
        /* tipo escrito = procesoActivo (SCA_TXT_ACCIONES); normalizar a pantalla */
        a!localVariables(
          local!pantalla: local!pantallaActual,
          a!match(
            value: local!pantalla,
            equals: cons!SCA2_TXT_ACCION_AUTORIZACION,
            then: rule!SCA2_AnulacionFueraNormaPrincipal(
              idSolicitud: ri!idSolicitud,
              idTarea: a!defaultValue(local!idTareaTras, ri!idTareaAccion),
              onCompletar: local!hecho
            ),
            equals: "ACC ADM",
            then: rule!SCA2_AccionesAdministrativasPrincipal(
              idSolicitud: ri!idSolicitud,
              idTarea: a!defaultValue(local!idTareaTras, ri!idTareaAccion),
              onCompletar: local!hecho
            ),
            equals: cons!SCA2_TXT_ACCION_CONTRA_ANULAR,
            then: rule!SCA2_ContraAnulacionPrincipal(
              idSolicitud: ri!idSolicitud,
              idTarea: a!defaultValue(local!idTareaTras, ri!idTareaAccion),
              onCompletar: local!hecho,
              /* Paridad SCA: el cierre positivo vuelve directamente al buscador */
              onVolver: {
                a!save(ri!accionAbierta, false),
                a!save(ri!tipoAccion, null),
                a!save(ri!idTareaAccion, null),
                a!save(local!hecho, false),
                a!save(ri!idSolicitud, null)
              }
            ),
            equals: "MECANIZACION",
            then: rule!SCA2_MecanizacionPrincipal(
              idSolicitud: ri!idSolicitud,
              idTarea: a!defaultValue(local!idTareaTras, ri!idTareaAccion),
              onCompletar: local!hecho
            ),
            equals: cons!SCA2_TXT_CONTACTO_VERTI,
            then: rule!SCA2_VertiVencimientoPrincipal(
              idSolicitud: ri!idSolicitud,
              idTarea: a!defaultValue(local!idTareaTras, ri!idTareaAccion),
              onCompletar: local!hecho
            ),
            /* Componente externo CMP Inducir Cliente Completo: sus formularios son tareas Appian asignadas al usuario que pulsó ANULAR PÓLIZA; se completan desde las tareas de Appian y la mecanización de SCA2 continúa al terminar */
            equals: "INDUCCION",
            then: a!localVariables(
              local!refrescarCmp: 0,
              /* La tarea SCA2 se relee cada 30 s (y con ACTUALIZAR) hasta que el nodo 333 de CMD Mecanizar la marca COMPLETADA al volver del componente */
              local!tarea: a!refreshVariable(
                value: index(
                  index(
                    a!queryRecordType(
                      recordType: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea',
                      fields: {
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ba1b2a33-3e00-4e18-96bf-d3cfd74f342b}fechaCierre',
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion'
                      },
                      filters: a!queryFilter(
                        field: 'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                        operator: "=",
                        value: tointeger(ri!idTareaAccion)
                      ),
                      pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 1),
                      fetchTotalCount: false
                    ),
                    "data",
                    {}
                  ),
                  1,
                  null
                ),
                refreshOnVarChange: local!refrescarCmp,
                refreshInterval: cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60
              ),
              local!completada: tostring(
                index(
                  local!tarea,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                  ""
                )
              ) = cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA,
              /* Tarea Appian activa del componente (CMP Fase 1/2) asignada al usuario; se abre dentro del site con a!processTaskLink */
              local!tareaCmp: a!refreshVariable(
                value: if(
                  local!completada,
                  null,
                  rule!SCA2_obtenerTareaInduccion(
                    usuario: user(loggedInUser(), "username"),
                    fechaDesde: if(
                      a!isNullOrEmpty(
                        index(
                          local!tarea,
                          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion',
                          null
                        )
                      ),
                      null,
                      index(
                        local!tarea,
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{b563186d-85c1-43ca-b9ec-74548e606e12}fechaCreacion',
                        null
                      ) - intervalds(3, 0, 0)
                    ),
                    idCliente: null
                  )
                ),
                refreshOnVarChange: { local!refrescarCmp, local!completada },
                refreshInterval: if(local!completada, null, cons!SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS / 60)
              ),
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    labelPosition: "COLLAPSED",
                    value: {
                      a!richTextItem(
                        text: "Inducción Verti / Vencimiento (componente de inducción de cliente)",
                        style: "STRONG"
                      ),
                      char(10),
                      if(
                        local!completada,
                        a!richTextItem(
                          text: "Componente completado el " & text(
                            index(
                              local!tarea,
                              'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ba1b2a33-3e00-4e18-96bf-d3cfd74f342b}fechaCierre',
                              null
                            ),
                            "dd/MM/yyyy HH:mm"
                          ) & ". La mecanización de SCA2 ha continuado.",
                          color: cons!SCA2_VAL_COLOR_VERDE
                        ),
                        a!richTextItem(
                          text: "El componente está pendiente de completar por " & a!defaultValue(
                            tostring(
                              index(
                                local!tarea,
                                'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                                null
                              )
                            ),
                            "el usuario que mecanizó"
                          ) & ". Complete sus pantallas desde esta misma página; la mecanización de SCA2 continuará automáticamente al terminarlo.",
                          color: cons!SCA2_VAL_COLOR_ROJO
                        )
                      )
                    }
                  ),
                  if(
                    local!completada,
                    {},
                    if(
                      a!isNullOrEmpty(local!tareaCmp),
                      a!richTextDisplayField(
                        labelPosition: "COLLAPSED",
                        value: a!richTextItem(
                          text: "No tiene en este momento ninguna pantalla del componente pendiente (puede estar generándose o asignada a otro usuario). Pulse ACTUALIZAR para volver a comprobarlo.",
                          color: "SECONDARY"
                        )
                      ),
                      a!linkField(
                        labelPosition: "COLLAPSED",
                        links: a!processTaskLink(
                          label: "Completar el componente ahora: " & a!defaultValue(index(local!tareaCmp, "nombre", ""), ""),
                          task: index(local!tareaCmp, "taskId", null)
                        )
                      )
                    )
                  ),
                  a!buttonArrayLayout(
                    align: "START",
                    buttons: {
                      a!buttonWidget(
                        label: "VOLVER",
                        style: "OUTLINE",
                        saveInto: {
                          a!save(ri!accionAbierta, false),
                          a!save(ri!tipoAccion, null)
                        }
                      ),
                      a!buttonWidget(
                        label: "ACTUALIZAR",
                        style: "OUTLINE",
                        showWhen: not(local!completada),
                        saveInto: a!save(
                          local!refrescarCmp,
                          local!refrescarCmp + 1
                        )
                      )
                    }
                  )
                }
              )
            ),
            default: a!richTextDisplayField(
              labelPosition: "COLLAPSED",
              value: a!richTextItem(
                text: "Tipo de tarea sin pantalla asociada: " & ri!tipoAccion,
                color: cons!SCA2_VAL_COLOR_ROJO
              )
            )
          )
        )
      )
    },
    if(
      local!hecho,
      a!richTextDisplayField(
        label: "Tareas",
        value: a!richTextItem(
          text: "Acción registrada. Vuelva a consultar la solicitud para ver el estado actualizado.",
          color: cons!SCA2_VAL_COLOR_VERDE
        )
      ),
      a!sectionLayout(
        label: "Tareas",
        contents: {
          a!gridField_25r3(
            labelPosition: "COLLAPSED",
            label: "grid",
            data: index(local!q, "data", {}),
            columns: {
              a!gridColumn(
                label: "Tarea",
                value: index(
                  fv!row,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{892f047d-1737-4a64-9c7e-81e0ff00b563}nombreTarea',
                  null
                )
              ),
              a!gridColumn(
                label: "Tipo",
                value: rule!SCA2_D_TiposGestiones(
                  index(
                    fv!row,
                    'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                    null
                  )
                )
              ),
              a!gridColumn(
                label: "Estado",
                value: a!tagField(
                  tags: a!tagItem_24r2(
                    text: index(
                      fv!row,
                      'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                      null
                    ),
                    backgroundColor: rule!SCA2_D_ColorEstadoGestion(
                      index(
                        fv!row,
                        'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                        null
                      )
                    ),
                    textColor: cons!SCA2_VAL_COLOR_BLANCO
                  ),
                  align: "CENTER"
                )
              ),
              a!gridColumn(
                label: "Asignado a",
                value: index(
                  fv!row,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{ca504656-ecb9-4d9a-9930-639d875198fb}asignadoA',
                  null
                )
              ),
              a!gridColumn(
                label: "Grupo",
                value: index(
                  fv!row,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{07a5e61d-e9af-47dd-8e7d-293ce1ff7a00}grupo',
                  null
                )
              ),
              a!gridColumn(
                label: "Caducidad",
                value: index(
                  fv!row,
                  'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{9630cc5f-a395-4247-9fa1-5eaf51984c08}fechaCaducidad',
                  null
                )
              ),
              a!gridColumn(
                label: "",
                value: a!linkField(
                  links: {
                    a!dynamicLink(
                      label: "Completar",
                      saveInto: {
                        a!save(
                          ri!idTareaAccion,
                          index(
                            fv!row,
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{82a6a3b4-5afe-4dd3-a7f3-46f806490910}id',
                            null
                          )
                        ),
                        a!save(
                          ri!tipoAccion,
                          index(
                            fv!row,
                            'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                            null
                          )
                        ),
                        a!save(ri!accionAbierta, true)
                      },
                      showWhen: and(
                        index(
                          fv!row,
                          'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{e7be363c-399e-48a5-9242-3b2a65680f0f}estado',
                          null
                        ) = cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE,
                        /* [R9-B B5] sin Completar si la solicitud ya está finalizada/cancelada en SCA2 */
                        not(
                          or(
                            left(local!estadoSol, 10) = cons!SCA2_TXT_ESTADO_SOL_FINALIZADA,
                            local!estadoSol = "FIN",
                            local!estadoSol = "CANCELADA"
                          )
                        ),
                        /* [R9-B B7-SI24 / B3] mismos permisos que RETOMAR en el Detalle */
                        rule!SCA2_puedeGestionarTarea(
                          tarea: fv!row,
                          nivelIntervencion: local!nivelSol,
                          codSubPerfil: local!subPerfilSol
                        ),
                        not(
                          and(
                            left(
                              upper(
                                tostring(
                                  index(
                                    fv!row,
                                    'recordType!{696285d3-cb21-4f27-adce-66354ebf2b89}SCA2 Tarea.fields.{1a10cef3-4704-407c-8c2d-5ff372a15121}tipo',
                                    null
                                  )
                                )
                              ),
                              9
                            ) = cons!SCA2_TXT_ACCION_MECANIZAR,
                            tostring(local!procesoActivoSol) = "ANL"
                          )
                        )
                      )
                    )
                  }
                )
              )
            },
            pagingSaveInto: local!pagingInfo,
            validations: {}
          )
        }
      )
    )
  )
)
