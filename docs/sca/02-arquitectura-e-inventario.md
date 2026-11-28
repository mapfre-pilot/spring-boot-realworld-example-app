# 2. Arquitectura e inventario

## 2.1 Arquitectura lógica

```
 ┌────────────────────────────────────────────────────────────────────────────┐
 │  PRESENTACIÓN  (app SCA)                                                    │
 │  Sites: SCA_Site, SCA Decidir Accion  ·  103 interfaces SAIL               │
 │  Web API SCA Decisora (redirección desde PCA / portal interno)              │
 ├────────────────────────────────────────────────────────────────────────────┤
 │  ORQUESTACIÓN  (app SCA)                                                    │
 │  60 process models: alta, decisión, autorización, mecanización, contra      │
 │  anulación, acciones administrativas, finalización, batch, mantenimiento    │
 ├────────────────────────────────────────────────────────────────────────────┤
 │  LÓGICA / ACCESO  (app SCA)                                                 │
 │  250 expression rules: wrappers de integración (SCA_*Integracion), mapeos   │
 │  XML↔CDT, consultas a records (a!queryRecordType), utilidades, validaciones │
 ├────────────────────────────────────────────────────────────────────────────┤
 │  INTEGRACIÓN  (app SCA CORE / SCAC)                                         │
 │  176 integrations (116 SOAP, 60 REST/otros) · 25 connected systems          │
 │  8 Web APIs de entrada (callbacks de autorización, documentos, credenciales)│
 ├────────────────────────────────────────────────────────────────────────────┤
 │  DATOS                                                                      │
 │  19 record types SCA (16 sobre BBDD `SCAC AWS DB`, 3 WEB_SERVICE)           │
 │  1 Data Store legacy (SCA TM Add Transactions to Job Type)                  │
 └────────────────────────────────────────────────────────────────────────────┘
        │ Core7 (PCA)  │ Webservices │ SOA7 │ ESB │ WM/BIG │ SGO │ SGC3 │ Documentum │ Verti │ Clients API │ ANL
```

Patrón dominante: **SCA no contiene ni integraciones ni sistemas conectados**; todo el acceso a sistemas externos
pasa por objetos `SCAC_*`. SCA aporta las reglas `SCA_*` que construyen el CDT de petición, llaman a
`rule!SCAC_<op>Integracion(host, endpoint, consulta)` y convierten la respuesta SOAP con `xpathsnippet` + `torecord`.
Ejemplo representativo (`SCA_aceptarAutorizacion`):

```sail
local!resultado: rule!SCAC_aceptarAutorizacionIntegracion(
  host: cons!SCAC_VAL_HOST_CORE7,
  endpoint: "PCA_CORECFSA_HTTPRouter/IGestionarAutorizacionesPCA",
  consulta: local!aceptarAutorizacion
),
local!cdtTmp: xpathsnippet(index(local!resultado, "result", "body", null), "/*/soapenv:Body/*"),
torecord(local!cdtTmp, 'type!{http://ejb.cfsa.pca.mapfami.dgtp.mapfre.com/}aceptarAutorizacionResponse'())
```

## 2.2 Inventario por tipo

| Tipo | SCA | SCAC | Notas |
|---|---:|---:|---|
| Record types | 19 | 0 | 16 sobre `SCAC AWS DB`, 3 `WEB_SERVICE` (Concepto, Concepto Funcional, Compañía Contraria). Sin relaciones, sin record actions, solo vista *summary* por defecto. |
| Interfaces | 103 | 0 | 26 variantes `*Estrategicas`. Las 5 mayores: 4.771 / 3.592 / 3.307 / 2.228 / 1.587 líneas. |
| Expression rules | 250 | 2 | Mayor: `SCA_companiasContrariasCompletas` (1.290 líneas). 31 usan `a!queryRecordType`. |
| Process models | 60 | 0 | 16 sin descripción; 10 usos de `[Deprecated] Start Process`. |
| Integrations | 0 | 176 | Core7 ≈ 69, Webservice ≈ 31, SOA7 ≈ 10, ESB ≈ 10, resto repartido. |
| Connected systems | 0 | 25 | Ver `03-integraciones-y-dependencias.md`. |
| Web APIs | 5 | 8 | Todas privadas (`isPublic=false`). |
| Constantes | 145 | 12 | Listas de estados/acciones, hosts, buzones, punteros a PM/grupos/carpetas/documentos. |
| Grupos | 5 | 2 | |
| Sites | 2 | 0 | |
| Documentos / carpetas | 68 / 17 | 2 / 5 | Plantillas DOCX de carta firmada, documentos estáticos, iconos. |

## 2.3 Sites

| Site | Alias | Página | Interfaz | Visibilidad |
|---|---|---|---|---|
| `SCA_Site` | `sca-site` | Solicitudes anulación (`/b-squeda`) | `SCA_BuscadorSolicitudPrincipal` | todos |
| | | Gestiones mantenimiento | `SCA_GestionMantenimientoMenu` | `rule!SCA_isUsuarioProceso()` |
| `SCA Decidir Accion` | `decidir-accion` | Solicitudes anulación (`/decidiraccion`) | `SCA_DecidirAccion` | todos |
| | | Gestiones mantenimiento | `SCA_GestionMantenimientoMenu` | `rule!SCA_isUsuarioProceso()` |

`SCA_DecidirAccion` es el "shell" de trabajo: carga la solicitud por póliza (`SCA_ObtenerSolicitudAnulacion`,
`SCA_ObtenerEstado`, `SCA_comprobarUserTareaActiva`) y decide por `interfazactiva` qué sub-interfaz mostrar
(cabecera, pop-up Decisora, alta, autorización, mecanización, contra anulación, acciones administrativas).

## 2.4 Process models

Clasificación de los 60 PMs (detalle de nodos en el [anexo](anexos/inventario-generado.md#process-models-sca--60)):

| Categoría | Process models |
|---|---|
| Flujo principal | Alta Solicitud Anulacion, Alta Solicitud Anulacion Particionado, Generar Solicitud, Decidir Accion, Consulta Reglas, Consulta Gestion, Comprobar Carterizacion |
| Tareas de negocio | Autorización, Mecanizacion, Alta Mecanización, Contra Anulación, Alta Contra Anulacion, Acciones Administrativas, Posponer Accion, Posponer Contra Anulacion |
| Finalización | Finalizar Solicitud, Finalizar Mecanización, Finalizar Contra Anulacion, Finalizar Gestión SGC (+ Estratégicas), Gestion SGC (+ Estratégicas ×2), Cierre SGO y STCAT, Desbloquear Proceso Principal |
| Asignación / notificación | Reasignar Tarea, Reasignar Tarea Estrategica, Notificar Cambio Nivel (+ Estrategicas), Notificacion Errores, Envio correos mecanizacion |
| Persistencia | Guardar Tablas BBDD, Eliminar Tablas BBDD, Guardar Trazabilidad, Guardar Tarea Activa en BBDD, Guardar Tarea Activa Verti en BBDD, Borrar tarea Finalizada en BBDD, Documents to Record, Compañia Contraria Vida |
| Documentos | Subir Docs Documentum BBDD, Subir Documento, Eliminar documentos, Eliminar Documento, Obtener documentos, Obtener Documento GD, Obtener Documento Argumentos, DocxPDF |
| Batch | Batch Caducidad, Batch Caducidad Previo, Batch Mecanizacion NSE (+ "(1)", "(2)"), Batch Rsva Prima SGO, Procesamiento Batch Rsva Prima SGO |
| Mantenimiento | Crear Concepto, Crear/Modificar/Eliminar Concepto Funcional, Gestion Aplicacion, Gestion Argumentos |
| Navegación | Redirigir Vida, Redirigir Detalle Solicitud |
| Otros | TM Add Transactions to Job Type (usa Data Store Entity), Crear CDTs desde WSDL (vacío: solo Start/End) |

Características transversales de los PMs:

- Prácticamente todos incluyen un nodo **Modify Process Security** al inicio.
- Uso intensivo de **Unattended Multiple Questions** (script tasks) con reintentos por contador (`numReintentos++`,
  `intentos = 3?`) en las llamadas a integración.
- Estado de la tarea persistido en BBDD (`SCA TareasPorPolizaAWS`, `SCA solicitudAnulacion`) en paralelo al estado
  del proceso, para poder relanzar/reasignar (`nodorelanzar`, `tareacapturada`).
- Coordinación con la app ANL mediante eventos (`Pausar hasta ANL_Desbloquear` ↔ `SCA Desbloquear Proceso Principal`).

## 2.5 Web APIs

| App | Nombre | Método | Alias | Pública | Uso |
|---|---|---|---|---|---|
| SCA | SCA Decisora | GET | `decisora` | No | Devuelve URL de redirección al site (logging habilitado). |
| SCA | SCA Lanzar Reserva Prima | POST | `ejecutarRsvPrima` | No | Dispara el batch de reserva de prima. |
| SCA | SCA Volcado Datos Reserva Prima | POST | `volcadoReservaPrima` | No | Carga de datos de reserva de prima. |
| SCA | SCA Eliminar Tareas AWS | POST | `eliminarTareas` | No | Limpieza de tareas activas. |
| SCA | SCA Eliminar Tareas BBDD | POST | `eliminarTareasBBDD` | No | Limpieza de tablas de la solicitud. |
| SCAC | SCAC_GestionarAutorizacionIA / STCAT / Sgo | POST | — | No | Callbacks de resolución de autorizaciones desde sistemas externos. |
| SCAC | SCAC LanzarDocumentsToRecord | POST | — | No | Persistencia de documentos en records. |
| SCAC | SCAC Submit Uploaded File | POST | — | No | Subida de ficheros. |
| SCAC | SCAC Obtener Credenciales Conceptos | GET | — | No | Devuelve credenciales para los record types WEB_SERVICE (ver §5). |
| SCAC | SCAC_insertarCompañiasContrariasVida | POST | — | No | Carga de compañías contrarias Vida. |
| SCAC | SCAC Prueba | POST | — | No | Objeto de pruebas. |

## 2.6 Interfaces — agrupación funcional

| Bloque | Interfaces (sin sufijo Estrategicas) |
|---|---|
| Buscador | `SCA_BuscadorSolicitudPrincipal`, `SCA_BuscadorTabla`, `SCA_BuscarSolicitudClientePoliza`, `SCA_TablaOtrasSolAnulaci_n`, `SCA_DetalleSolicitud` |
| Alta | `SCA_AltaSolicitudAnulacion`, `SCA_AltaSolicitudAnulacionPopUp`, `SCA_GenerarSolicitudPopup`, `SCA_SimularAnulacionPopup`, `SCA_MilestoneMasDatosAltaSolicitud`, `SCA_DetalleAnulacionAltaSolicitud`, `SCA_ModalFechaSolicitudAnulacion`, `SCA_FechaDisponibilidadVehiculo`, `SCA_Deducciones` |
| Cabecera / datos | `SCA_DatosCabecera`, `SCA_DatosCliente`, `SCA_DatosContacto`, `SCA_DatosPoliza`, `SCA_PieDePagina` |
| Decisora | `SCA_DecidirAccion`, `SCA_PopUpDecisora`, `SCA_RedirigirGesvida` |
| Autorización | `SCA_DetalleAnulacionAutorizacion`, `SCA_PopUpMensajeAutorizacion` |
| Mecanización | `SCA_MecanizacionEstrategicas`, `SCA_DetalleAnulacionMecanizacion`, `SCA_ModalPlanPago`, `SCA_ModalClaveProduccion`, `SCA_AnulacionFueraNormaPrincipal` |
| Contra anulación | `SCA_ContraAnulacionPrincipal`, `SCA_ContraAnulacionOpciones`, `SCA_ContraAnulacionDetalleAnulacionPoliza`, `SCA_ContraAnulacionModal{Informativo,RecuperacionPoliza,Retos,SVA,SVAEmail,SiNo,Tr_boles}`, `SCA_ArgumentosContraAnulacion`, `SCA_AltaGestionArgumento`, `SCA_GenerarContactoVerti`, `SCA_ModalDescuentosVida`, `SCA_MensajeCancelarContraAnulacion`, `SCA_VisualizarDocumentoContraanular` |
| Acciones administrativas | `SCA_AccionesAdministrativasPrincipal`, `...Catalogacion`, `...Documentacion`, `SCA_DetalleAccionesAdministrativas`, `SCA_Compa_iaContrariaCatalogacion`, `SCA_ErroresDocumentacion`, `SCA_InterfazErrorDocumentos` |
| Documentos | `SCA_VisualizacionDocumento`, `SCA_VisualizarDocumento`, `SCA_MensajeEliminacionDocumento` |
| Tareas | `SCA_PopUpReasignarTarea`, `SCA_selectorOficinas`, `SCA_TablaNotificaciones`, `SCA_EjecucionBatch` |
| Mantenimiento | `SCA_GestionMantenimientoMenu`, `SCA_GestionConceptosYClases`, `SCA_AnadirGestionConceptosyClases`, `SCA_ValoresConceptoGestionConceptosyClases`, `SCA_A_adirConcepto`, `SCA_A_adirModificarConceptoFuncional`, `SCA_EliminarValorConcepto`, `SCA_MensajeEliminacionConcepto`, `SCA_MensajeEliminarConceptoFuncional`, `SCA_GestionArgumentos`, `SCA_TablaGestionArgumentos`, `SCA_GestionAplicacionRecords`, `SCA_AnadirModificarGestionAplicacion`, `SCA_MensajeDesactivarAplicacion`, `SCA_IF_ArgumentoAplicacionUrl`, `SCA_BuscarCompaniasContrarias` |
