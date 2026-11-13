# Appian dump — SCA & SCAC (mapfrespain-dev)

Source: MCP `appian-dev-mcp-desarrollo-05c9` server, read-only get/list calls.

## Object counts

| type | SCA | SCAC |
|---|---|---|
| connectedSystems | 0 | 25 |
| constants | 145 | 12 |
| documents | 68 | 2 |
| expressionRules | 250 | 2 |
| folders | 17 | 5 |
| groups | 5 | 2 |
| integrations | 0 | 176 |
| interfaces | 103 | 0 |
| portals | 0 | 0 |
| processModels | 60 | 0 |
| recordTypes | 19 | 0 |
| sites | 2 | 0 |
| webApis | 5 | 8 |

## Process models (SCA — 60)

| name | description | nodes | node types | subprocesses called |
|---|---|---|---|---|
| SCA Alta Solicitud Anulacion | Proceso que muestra la interfaz de alta de solicitud de anulación para que el usuario pueda rellenar los datos | 52 | Unattended Multiple Questions×15, XOR×13, SUB_PROC×11, User Input Task×3, End Node×2, AND×2, Start Node×1, Reassign Task×1, Write Records and Related Records×1, Call Integration×1, Delete Records and Related Records×1, ModifySecurity×1 | Finalizar Gestion SGC→SCA Finalizar Gestión SGC; ERROR→SCA Notificacion Errores; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Guardar tarea→SCA Guardar Tarea Activa en BBDD; Finalizar Gestion SGC 1→SCA Finalizar Gestión SGC; SCA Finalizar Solicitud→SCA Finalizar Solicitud; Notificar/DUE→SCA Notificar Cambio Nivel; AUTORIZACIÓN→SCA Autorización; ACC ADM→SCA Acciones Administrativas; CONTRA ANULAR→SCA Contra Anulación; MECANIZAR→SCA Mecanizacion |
| SCA Crear Concepto Funcional | PMO para el alta de conceptos funcionales | 8 | XOR×2, Start Node×1, End Node×1, Sync Records×1, Call Integration×1, Unattended Multiple Questions×1, ModifySecurity×1 |  |
| SCA Crear Concepto | Proceso para la creación de conceptos con records | 8 | XOR×2, Start Node×1, End Node×1, Sync Records×1, Call Integration×1, Unattended Multiple Questions×1, ModifySecurity×1 |  |
| SCA Eliminar Concepto Funcional | PMO para eliminar un concepto funcional | 9 | XOR×2, Unattended Multiple Questions×2, Start Node×1, End Node×1, Sync Records×1, Call Integration×1, ModifySecurity×1 |  |
| SCA Modificar Concepto Funcional | PMO para modificar un concepto funcional | 8 | XOR×2, Start Node×1, End Node×1, Sync Records×1, Unattended Multiple Questions×1, ModifySecurity×1, Call Integration×1 |  |
| SCA DocxPDF | Modelo de proceso para rellenar la plantilla de la carta firmada y convertirla a PDF | 9 | PDF From DOCX×2, Generate Docx×2, Start Node×1, End Node×1, XOR×1, DeleteDocument×1, ModifySecurity×1 |  |
| SCA Mecanizacion | Proceso que encargado de gestionar las tarea de mecanización | 64 | Unattended Multiple Questions×16, XOR×15, SUB_PROC×11, Call Integration×6, AND×5, Intermediate Consuming Event×2, End Node×2, User Input Task×2, Start Node×1, Complex×1, Send E-Mail×1, ModifySecurity×1, Write Records and Related Records×1 | Guardar Tarea Verti→SCA Guardar Tarea Activa Verti en BBDD; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Insertar Observaciones 1→0002ea8d-8eea-8000-aead-7f0000014e7a; Guardar tarea→SCA Guardar Tarea Activa en BBDD; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Insertar Observaciones 4→0002ea8d-8eea-8000-aead-7f0000014e7a; ANL Alta→0002ea90-3244-8000-afaa-7f0000014e7a; Insertar Observaciones 5→0002ea8d-8eea-8000-aead-7f0000014e7a; Insertar Observaciones 6→0002ea8d-8eea-8000-aead-7f0000014e7a; ANL Alta→0002ea90-3244-8000-afaa-7f0000014e7a; Inducción VERTI→0002ea05-adcc-8000-8c7a-7f0000014e7a |
| SCA Acciones Administrativas | Proceso encargado de gestionar la tarea de acciones administrativas | 37 | Unattended Multiple Questions×10, XOR×9, SUB_PROC×5, User Input Task×3, Call Integration×3, End Node×2, AND×2, Start Node×1, [Deprecated] Start Process×1, ModifySecurity×1 | Subir Docs Documentum BBDD→SCA Subir Docs Documentum BBDD; Obtener Documentos→SCA Obtener documentos; Obtener Documentos→SCA Obtener documentos; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Guardar tarea→SCA Guardar Tarea Activa en BBDD |
| SCA Alta Contra Anulacion |  | 14 | Unattended Multiple Questions×4, End Node×2, XOR×2, Start Node×1, Write Records and Related Records×1, Call Integration×1, ModifySecurity×1, SUB_PROC×1, Reassign Task×1 | Subprocess - TM Add Transactions to Job Type→SCA TM Add Transactions to Job Type |
| SCA Alta Mecanización | Proceso encargado de generar el alta de la gestión de mecanización para una solicitud específica | 10 | XOR×2, Unattended Multiple Questions×2, Start Node×1, End Node×1, Call Integration×1, SUB_PROC×1, Write Records and Related Records×1, ModifySecurity×1 | Insertar observaciones→0002ea8d-8eea-8000-aead-7f0000014e7a |
| SCA Alta Solicitud Anulacion Particionado | Proceso que muestra la interfaz de alta de solicitud de anulación para que el usuario pueda rellenar los datos | 46 | Unattended Multiple Questions×12, XOR×12, SUB_PROC×12, AND×2, User Input Task×2, Start Process×2, Start Node×1, End Node×1, ModifySecurity×1, Reassign Task×1 | ERROR→SCA Notificacion Errores; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Guardar tarea→SCA Guardar Tarea Activa en BBDD; REDIRECCION VIDA→SCA Redirigir Vida; Borrar registros BBDD→SCA Eliminar Tablas BBDD; CONTRA ANULAR→SCA Contra Anulación; Finalizar Gestion SGC→SCA Finalizar Gestión SGC; MECANIZAR→SCA Mecanizacion; ACC ADM→SCA Acciones Administrativas; AUTORIZACIÓN→SCA Autorización; Finalizar Gestion SGC→SCA Finalizar Gestión SGC; Notificar/DUE→SCA Notificar Cambio Nivel |
| SCA Autorización | Proceso encargado de la gestión de la autorización | 37 | Unattended Multiple Questions×12, XOR×9, SUB_PROC×5, User Input Task×3, End Node×2, AND×2, Start Node×1, Call Integration×1, ModifySecurity×1, [Deprecated] Start Process×1 | Obtener Documentos→SCA Obtener documentos; Obtener Documentos→SCA Obtener documentos; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Guardar tarea→SCA Guardar Tarea Activa en BBDD; Subir Docs Documentum BBDD→SCA Subir Docs Documentum BBDD |
| SCA Batch Caducidad Previo | Modelo de proceso que procesa las caducidades de las distintas solicitudes abiertas | 6 | End Node×1, Unattended Multiple Questions×1, Start Process×1, XOR×1, Start Node×1, ModifySecurity×1 |  |
| SCA Batch Caducidad | Modelo de proceso que procesa las caducidades de las distintas solicitudes abiertas | 23 | Unattended Multiple Questions×8, XOR×5, SUB_PROC×3, Call Integration×3, Start Node×1, End Node×1, Write Records and Related Records×1, ModifySecurity×1 | Subprocess - TM Mark Transaction as Complete→0002e398-aab5-8000-855d-014d98014d98; SCA Finalizar solicitud→SCA Finalizar Solicitud; Borrar BBDD→SCA Eliminar Tablas BBDD |
| SCA Batch Mecanizacion NSE (1) | Modelo de proceso encargado de actualizar los estados de mecanización y las gestiones de autorización | 19 | Unattended Multiple Questions×5, XOR×5, Call Integration×2, [Deprecated] Start Process×2, End Node×1, AND×1, Complex×1, Start Node×1, ModifySecurity×1 |  |
| SCA Batch Mecanizacion NSE (2) | Modelo de proceso encargado de actualizar los estados de mecanización y las gestiones de autorización | 15 | Unattended Multiple Questions×5, XOR×2, Call Integration×2, End Node×1, Start Node×1, Complex×1, AND×1, SUB_PROC×1, ModifySecurity×1 | Finalizar instancia de mecanizacion→0012eabd-4050-8000-bc63-7f0000014e7a |
| SCA Batch Mecanizacion NSE | Modelo de proceso encargado de actualizar los estados de mecanización y las gestiones de autorización | 18 | Unattended Multiple Questions×6, XOR×4, Call Integration×3, Start Node×1, End Node×1, SUB_PROC×1, [Deprecated] Start Process×1, ModifySecurity×1 | Finalizar instancia de mecanizacion→0012eabd-4050-8000-bc63-7f0000014e7a |
| SCA Batch Rsva Prima SGO |  | 9 | SUB_PROC×2, End Node×1, Unattended Multiple Questions×1, Start Node×1, ModifySecurity×1, XOR×1, [Deprecated] Start Process×1, Send E-Mail×1 | Subprocess - TM Mark Transaction as Complete→0002e398-aab5-8000-855d-014d98014d98; Subprocess - TM Add Transactions to Job Type→0002e3ab-560e-8000-855d-014d98014d98 |
| SCA Borrar tarea Finalizada en BBDD |  | 8 | XOR×2, Start Node×1, End Node×1, Intermediate Consuming Event×1, ModifySecurity×1, Delete Records and Related Records×1, Unattended Multiple Questions×1 |  |
| SCA Cierre SGO y STCAT | Modelo de proceso para el cierre de tareas SGO y STCAT | 10 | Unattended Multiple Questions×4, XOR×3, Start Node×1, End Node×1, ModifySecurity×1 |  |
| SCA Compañia Contraria Vida |  | 4 | Start Node×1, End Node×1, Write Records and Related Records×1, ModifySecurity×1 |  |
| SCA Comprobar Carterizacion | Comprueba si la póliza está carterizada y el nivel carterizador | 7 | Unattended Multiple Questions×3, Start Node×1, End Node×1, XOR×1, ModifySecurity×1 |  |
| SCA Consulta Gestion | Búsqueda de las gestiones de una solicitud | 6 | Unattended Multiple Questions×2, Start Node×1, End Node×1, XOR×1, ModifySecurity×1 |  |
| SCA Consulta Reglas | Modelo de proceso que realiza la llamada al servicio de reglas y escribe la información correspondiente en BBDD para actualizar la solicitud | 11 | Unattended Multiple Questions×4, XOR×2, SUB_PROC×2, Start Node×1, End Node×1, ModifySecurity×1 | Guardar tablas BBDD→SCA Guardar Tablas BBDD; Notificar/DUE→SCA Notificar Cambio Nivel Estrategicas |
| SCA Contra Anulación | Proceso encargado de la gestión de la contra anulación | 49 | Unattended Multiple Questions×17, XOR×12, SUB_PROC×5, End Node×4, User Input Task×4, AND×2, Start Node×1, Write Records and Related Records×1, [Deprecated] Start Process×1, ModifySecurity×1, Call Integration×1 | Subir Docs Documentum BBDD→SCA Subir Docs Documentum BBDD; Obtener Documentos→SCA Obtener documentos; Obtener Documentos→SCA Obtener documentos; Borrar tarea→SCA Borrar tarea Finalizada en BBDD; Guardar tarea→SCA Guardar Tarea Activa en BBDD |
| SCA Decidir Accion | Llama al servicio de reglas para determinar cual es la siguiente acción a realizar en el proceso | 10 | Unattended Multiple Questions×4, XOR×2, Start Node×1, End Node×1, SUB_PROC×1, ModifySecurity×1 | Consulta Gestión→SCA Consulta Gestion |
| SCA Desbloquear Proceso Principal |  | 4 | Start Node×1, Intermediate Producing Event×1, End Node×1, ModifySecurity×1 |  |
| SCA Documents to Record |  | 5 | Unattended Multiple Questions×2, End Node×1, Write Records and Related Records×1, Start Node×1 |  |
| SCA Eliminar Tablas BBDD | Proceso que elimina los registros asociados a la solicitud | 24 | Delete Records and Related Records×10, XOR×10, AND×1, Start Node×1, End Node×1, ModifySecurity×1 |  |
| SCA Eliminar documentos | Reglas de expresión que a partir del documento obtenido según su ubicación e id , lo borra de Appian | 4 | Start Node×1, End Node×1, SUB_PROC×1, ModifySecurity×1 | CMP - Eliminar Documentos→0005ee33-22ee-8000-0640-7f0000014e7a |
| SCA Envio correos mecanizacion | Proceso que se ejecutara de madrugada para enviar correos informativos para que confirmen la anulacion/suscripcion para evitar la caducidad. | 10 | Unattended Multiple Questions×4, XOR×2, End Node×1, Send E-Mail×1, Start Node×1, ModifySecurity×1 |  |
| SCA Finalizar Contra Anulacion |  | 33 | Unattended Multiple Questions×9, XOR×7, SUB_PROC×5, End Node×2, Delete from Data Store Entities×2, Write Records and Related Records×2, Call Integration×2, Start Node×1, [Deprecated] Start Process×1, ModifySecurity×1, Start Process×1 | Subir Docs Documentum BBDD→SCA Subir Docs Documentum BBDD; Consulta Reglas→SCA Consulta Reglas; SCA Finalizar Solicitud→SCA Finalizar Solicitud; Borrar BBDD→SCA Eliminar Tablas BBDD; Consulta Reglas→SCA Consulta Reglas |
| SCA Finalizar Gestión SGC Estratégicas | Proceso encargado del final de la gestión (finalizarGestionSGC en WM) | 15 | Unattended Multiple Questions×6, XOR×3, Call Integration×2, Start Node×1, End Node×1, SUB_PROC×1, ModifySecurity×1 | Gestion SGC→SCA Gestion SGC Estratégicas |
| SCA Finalizar Gestión SGC | Proceso encargado del final de la gestión (finalizarGestionSGC en WM) | 15 | Unattended Multiple Questions×6, XOR×3, Call Integration×2, Start Node×1, End Node×1, SUB_PROC×1, ModifySecurity×1 | Gestion SGC→SCA Gestion SGC |
| SCA Finalizar Mecanización | Modelo de proceso para finalizar la gestión de la mecanización | 40 | Unattended Multiple Questions×13, SUB_PROC×9, XOR×9, Call Integration×3, Start Node×1, End Node×1, AND×1, Intermediate Consuming Event×1, Write Records and Related Records×1, ModifySecurity×1 | Insertar observaciones →0002ea8d-8eea-8000-aead-7f0000014e7a; Insertar observaciones→0002ea8d-8eea-8000-aead-7f0000014e7a; Insertar observaciones→0002ea8d-8eea-8000-aead-7f0000014e7a; Finalizar gestión SGC→SCA Finalizar Gestión SGC Estratégicas; SCA Finalizar Solicitud→SCA Finalizar Solicitud; Borrar BBDD→SCA Eliminar Tablas BBDD; ANL Alta→0002ea90-3244-8000-afaa-7f0000014e7a; ANL Alta→0002ea90-3244-8000-afaa-7f0000014e7a; Inducción Verti→0002ea05-adcc-8000-8c7a-7f0000014e7a |
| SCA Finalizar Solicitud | Proceso para finalizar la gestión de una solicitud | 44 | Unattended Multiple Questions×17, XOR×17, Start Process×3, Start Node×1, End Node×1, AND×1, Intermediate Consuming Event×1, Delete Records and Related Records×1, Call Integration×1, ModifySecurity×1 |  |
| SCA Generar Solicitud | Proceso que da de alta una solicitud o muestra mensaje de error en caso de que ya exista. | 12 | End Node×2, Unattended Multiple Questions×2, SUB_PROC×2, Start Node×1, XOR×1, Call Integration×1, Start Process×1, User Input Task×1, ModifySecurity×1 | Guardar BBDD→SCA Guardar Tablas BBDD; Reglas→SCA Consulta Reglas |
| SCA Gestion SGC Estratégicas | Proceso encargado de la gestión de SGC llamado tras el finalizarSGC de WM | 12 | Unattended Multiple Questions×7, XOR×2, Start Node×1, End Node×1, ModifySecurity×1 |  |
| SCA Gestion SGC Estrategicas | Proceso encargado de la gestión de SGC llamado tras el finalizarSGC de WM | 12 | Unattended Multiple Questions×7, XOR×2, Start Node×1, End Node×1, ModifySecurity×1 |  |
| SCA Gestion SGC | Proceso encargado de la gestión de SGC llamado tras el finalizarSGC de WM | 12 | Unattended Multiple Questions×7, XOR×2, Start Node×1, End Node×1, ModifySecurity×1 |  |
| SCA Guardar Tablas BBDD |  | 5 | Start Node×1, End Node×1, XOR×1, Write Records and Related Records×1, ModifySecurity×1 |  |
| SCA Guardar Tarea Activa Verti en BBDD | PMO para guardar las tareas en BBDD en tiempo real | 7 | Unattended Multiple Questions×2, Start Node×1, End Node×1, Write Records and Related Records×1, XOR×1, ModifySecurity×1 |  |
| SCA Guardar Tarea Activa en BBDD | PMO para guardar las tareas en BBDD en tiempo real | 7 | Unattended Multiple Questions×2, Start Node×1, End Node×1, Write Records and Related Records×1, ModifySecurity×1, XOR×1 |  |
| SCA Guardar Trazabilidad |  | 4 | Start Node×1, End Node×1, Write Records and Related Records×1, ModifySecurity×1 |  |
| SCA Notificacion Errores | Proceso para mandar por correo electrónico un error de flujo | 5 | Start Node×1, End Node×1, Unattended Multiple Questions×1, Send E-Mail×1, ModifySecurity×1 |  |
| SCA Notificar Cambio Nivel Estrategicas | Proceso que se encarga de notificar ya sea por SGC o por DUE del cambio de nivel. Estrategicas | 13 | Unattended Multiple Questions×4, Write Records and Related Records×2, XOR×2, Start Node×1, End Node×1, ModifySecurity×1, Start Process×1, Send E-Mail×1 |  |
| SCA Notificar Cambio Nivel | Proceso que se encarga de notificar ya sea por SGC o por DUE del cambio de nivel | 13 | Unattended Multiple Questions×6, XOR×2, Start Node×1, End Node×1, ModifySecurity×1, SUB_PROC×1, Send E-Mail×1 | Gestion SGC→SCA Gestion SGC |
| SCA Obtener Documento Argumentos | Proceso que invoca el servicio para obtener los documentos de los argumentos | 7 | Unattended Multiple Questions×2, Start Node×1, End Node×1, XOR×1, ModifySecurity×1, Call Integration×1 |  |
| SCA Obtener Documento GD | Proceso que llama a la integración de obtener documento para obtener su id | 6 | Start Node×1, End Node×1, Unattended Multiple Questions×1, XOR×1, ModifySecurity×1, Call Integration×1 |  |
| SCA Obtener documentos | Proceso para la obtención de documentos para las gestiones Contra Anulación, Acciones Administrativas y Autorización | 17 | Unattended Multiple Questions×8, XOR×4, Call Integration×2, Start Node×1, End Node×1, ModifySecurity×1 |  |
| SCA Posponer Accion |  | 4 | Start Node×1, End Node×1, Unattended Multiple Questions×1, ModifySecurity×1 |  |
| SCA Posponer Contra Anulacion | PMO para realizar la acción de posponer la contra anulación de una solicitud | 15 | Unattended Multiple Questions×5, XOR×3, Start Node×1, End Node×1, Start Process×1, SUB_PROC×1, ModifySecurity×1, Write to Data Store Entity×1, Write Records and Related Records×1 | Subir Docs Documentum BBDD→SCA Subir Docs Documentum BBDD |
|  SCA Procesamiento Batch Rsva Prima SGO  | Procesamiento de la propia reserva de prima que se encuentra dentro del batch de reserva de prima | 17 | Unattended Multiple Questions×6, XOR×2, End Node×1, Delete Records and Related Records×1, Start Node×1, [Deprecated] Start Process×1, Call Integration×1, Write Records and Related Records×1, Write Records 23.2×1, ModifySecurity×1, Send E-Mail×1 |  |
| SCA Reasignar Tarea Estrategica | Nuevo proceso para reasignar tareas
 | 5 | Start Node×1, End Node×1, Write Records and Related Records×1, Unattended Multiple Questions×1, ModifySecurity×1 |  |
| SCA Reasignar Tarea | Proceso para reasignar una tarea | 7 | Start Node×1, End Node×1, ModifySecurity×1, Reassign Task×1, Unattended Multiple Questions×1, Delete Records and Related Records×1, Write Records and Related Records×1 |  |
| SCA Redirigir Detalle Solicitud | Proceso encargado de redirigir al detalle de otra solicitud | 4 | Start Node×1, End Node×1, User Input Task×1, ModifySecurity×1 |  |
| SCA Redirigir Vida | Proceso encargado de redirigir a VIDA | 4 | Start Node×1, End Node×1, User Input Task×1, ModifySecurity×1 |  |
| SCA Subir Docs Documentum BBDD | Proceso que se encarga de guardar los documentos de manera temporal en Appian y hacer las subidas de los mismos tanto a Documentum como a BBDD, cuenta con una interfaz para controlar errores en la ejecucion de los servicios y redirigir a la pantalla de acciones administrativas  | 17 | Unattended Multiple Questions×6, XOR×5, End Node×2, Start Node×1, User Input Task×1, [Deprecated] Start Process×1, ModifySecurity×1 |  |
| SCA TM Add Transactions to Job Type | Add One Or More Transactions to Job Type Queue | 5 | Start Node×1, End Node×1, ModifySecurity×1, Unattended Multiple Questions×1, Write to Data Store Entity×1 |  |
| SCA Crear CDTs desde WSDL |  | 2 | Start Node×1, End Node×1 |  |

> 5 process models could not be read via `getProcessModel` (MCP server bug: `'interfaceUuid'` KeyError): SCA Alta Solicitud Anulacion, SCA Eliminar Concepto Funcional, SCA Modificar Concepto Funcional, SCA Crear Concepto Funcional, SCA Crear Concepto. For these the file contains inventory metadata + `listProcessModelNodes` output + security.

## Integrations (SCAC — 176)

| name | connected system | method | path / operation |
|---|---|---|---|
| CMP_APIClients_search | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8634288 | POST | `/clients/search` |
| SCAC_APIClients_Address | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8634288 | GET | `system.http` |
| SCAC_APIClients_Benefits | SCAC API Clients | GET | `system.http` |
| SCAC_APIClients_Login | SCAC Login Token | POST | `system.http` |
| SCAC_APIClients_contactMethod | SCAC API Clients | GET | `system.http` |
| SCAC_APIClients_integralityDiscountPercent_POST | SCAC API Clients | POST | `client/integralityDiscountPercent` |
| SCAC_APIClients_search | SCAC API Clients | POST | `/clients/search` |
| SCAC_AnularPolizaRESTIntegracion | SCAC SCA WebServicesEmision | POST | `system.http` |
| SCAC_AsignarSVARestIntegracion | SCAC SCA Webservice | POST | `es_mkfd_tc_movil_app_be-web/api/tecuidamos/socios/svaAsignar` |
| SCAC_CargaGcOnLine | SCAC SCA Webservice | POST | `sgc_bbe-web/api/1.0/services/cargaGcOnLine` |
| SCAC_CargaGestionPCAIntegration | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_ClientsAPI_ActualizarMetodoContacto | SCAC API Clients | PUT | `system.http` |
| SCAC_IGenerarContraAnul | - | POST | `system.http` |
| SCAC_InBSGetDocumentContentIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_ObtenerCredencialesConceptos | SCAC API Key Obtener Credenciales | GET | `webapi/obtenerCredencialesConceptos` |
| SCAC_ObtenerDocumentosArgumentos | _a-0000ec31-13b0-8000-9c78-011c48011c48_13979606 |  | `plugin.[com.appian.ps.aws.s3.cst].[AWSS3ConnectedSystemTemplate].[AWSS3DownloadObjectIntegrationTemplate].WRITE@2` |
| SCAC_PF_getDocTemporal | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | POST | `system.http` |
| SCAC_SolicitudAnulacionPolizaRESTIntegracion | SCAC SCA WebServicesEmision | POST | `system.http` |
| SCAC_aceptarAutorizacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_aceptarPolizaParaAnularNewIntegracion | SCAC SCA Wmbig1is | POST | `system.http` |
| SCAC_actualizarEstadoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_actualizarMecanizacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_actualizarResPCA | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_actualizarSolicitudIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_actualizarVariableIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_adjuntarDocumentosSGO | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | POST | `system.http` |
| SCAC_altaAccAdmIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_altaContraAnulIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_altaDocumentoIntegracion | SCAC SCA Webservices Documentacion | POST | `documents-web/api/sgd/1.0/documents` |
| SCAC_asignarRetosRESTIntegracion | - | POST | `system.http` |
| SCAC_bloquearPolizaEnCentralIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_borrarDocumentoSCA | SCAC SCA Webservice | PUT | `es_pca_gestionartareas_bbe-web/esp/api/1.0/borrarDocumento` |
| SCAC_buscarMatriculaIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_buscarPersonaIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_busquedaAvanzadaIntegracion | SCAC SCA Webservices Documentacion | POST | `search-web/api/sgd/1.0/advancedSearch` |
| SCAC_cargaGestionSGC3 | SCAC_SGC3 | POST | `/external/api/1.0/tasks` |
| SCAC_catalogFilteredIntegracion | SCAC SCA Webservice | POST | `ARQ_Catalogo_be-web/api/1.0/catalogos/catalog/filtered` |
| SCAC_cerrarOperacion | _a-0000eaca-9685-8000-9c24-011c48011c48_9628615 | POST | `system.http` |
| SCAC_cerrarSolicitudSGO | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | POST | `system.http` |
| SCAC_comprobarClienteCarterizadoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_comprobarClienteIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_comprobarPropietarioIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_consultaAgenteIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_consultaBBDDSCA | SCAC SCA Webservice | POST | `es_pca_gestionartareas_bbe-web/esp/api/1.0/consultarOptimizadoProceso` |
| SCAC_consultaClasificacionTCIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_consultaClaveIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_consultaClaveVida | SCAC WEBSERVICES VIDA | GET | `system.http` |
| SCAC_consultaDetalleGestionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultaDetalleSolicitudIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultaDocumentoIntegracion | SCAC SCA Webservices Documentacion | GET | `system.http` |
| SCAC_consultaEstructuraComercialVida | SCAC WPORTALINTERNO VIDA | GET | `system.http` |
| SCAC_consultaGestionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultaImprIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultaMarcaEconomica | SCAC SCA Webservice | GET | `system.http` |
| SCAC_consultaPolizaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultaPropiedadClaveIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_consultaReservaPrima | SCAC SCA Webservice APP-SCAN | GET | `system.http` |
| SCAC_consultaSolicitudesIntegracion | SCAC SCA Webservice | GET | `system.http` |
| SCAC_consultaTallerVida | SCAC WEBSERVICES VIDA | GET | `system.http` |
| SCAC_consultaTipoArgIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarAccAdmIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarAccesoPorNuumaIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_consultarAccesoStudPorModoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarAnulacionPolizaIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_consultarAsignacionBonificacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarAutorizacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarBonoClienteIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarCabeceraIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarCabeceraRestIntegracion | SCAC SCA Webservice | POST | `es_pca_gestionartareas_bbe-web/esp/api/1.0/cargaCabecera` |
| SCAC_consultarCatalogacionIntegracion | SCAC SCA Core8 | POST | `system.http` |
| SCAC_consultarCatalogacionRestIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_consultarCatalogoTareas | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | GET | `system.http` |
| SCAC_consultarCausaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarClaseProductoraIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarConceptoFuncionalRESTIntegracion | SCAC SCA Webservice | GET | `es_pca_gestionartareas_bbe-web/esp/api/1.0/gestionAplicacionGET` |
| SCAC_consultarConceptoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarConfigTareaRamo | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | GET | `system.http` |
| SCAC_consultarContactoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarDPIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_consultarDatosIdentificativosIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_consultarDecJurIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarDetalleDPIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_consultarDetalleIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarDocumentosIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarEquiposIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_consultarListadoArgumentosREST | SCAC SCA Webservice | POST | `es_pca_gestionartareas_bbe-web/esp/api/1.0/consultarListadoArgumentos` |
| SCAC_consultarListadoObsIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarMotivoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarNotificacionesExtIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarPlanPagoPorNIFIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarPlanPagoPorPolizaIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_consultarPolizaVidaRiesgoIntegracion | SCAC WEBSERVICES VIDA | GET | `system.http` |
| SCAC_consultarPolizasIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_consultarPolizasPlanesPagoIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_consultarProdCiaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarSiniestrosAutosIntegracion | SCAC SCA Webservice | GET | `es_aupr_atn_mets_be-web/api/autos/siniestros` |
| SCAC_consultarSolicitudesIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarSusceptibilidadPdpIntegracion | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8633590 | POST | `system.http` |
| SCAC_consultarTipoArgIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_consultarUltimaGestionIntegracion | SCAC SCA Webservice | GET | `system.http` |
| SCAC_consultarVariableIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_crearAutorizacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_crearDocumentoIntegracion | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_crearSolicitud | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | POST | `system.http` |
| SCAC_descargaDocumentoIntegracion | SCAC SCA Webservices Documentacion | GET | `system.http` |
| SCAC_determinarContactoREST | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8633590 | POST | `system.http` |
| SCAC_eliminarConceptoFuncionalRESTIntegracion | SCAC SCA Webservice | DELETE | `system.http` |
| SCAC_executeAsignarIntegracion | SCAC SCA Wmapfre | POST | `MUTUACLUBWSLAVED/services/SocioAsignarTreboles` |
| SCAC_executeIntegracion | SCAC SCA Webservice APP-SCAN | POST | `system.http` |
| SCAC_finalizarContraAnulPcaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_finalizarSolicitudIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_generarCntrAnuIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_generarFicheroIntegracion | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8633590 | POST | `system.http` |
| SCAC_generarFicheroSgcdIntegracion | SCAC SCA Scgd | POST | `system.http` |
| SCAC_generarStudAnul | SCAC SCA Core7 | POST | `system.http` |
| SCAC_gestionarTTQRESTIntegracion | SCAC SCA Webservice | POST | `es_pca_gestionartareas_bbe-web/esp/api/1.0/gestionarTTQ` |
| SCAC_getFilteredCatalogIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_guardarAccAdmIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarAutorizacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarClaseProductoraIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarConceptoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarContactoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarDecJurIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarEjecuArgIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarImprIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarMecanizacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_guardarTipoArgIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_inBsCreateFolderDTOIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_inbsCreateDocumentDTOIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_inbsDeleteDocumentDTOIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_insertarConceptoFuncionalRESTIntegracion | SCAC SCA Webservice | POST | `es_pca_gestionartareas_bbe-web/esp/api/1.0/gestionAplicacionPOST` |
| SCAC_insertarNotificacionExternaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_insertarObservacionesIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_listarDetalleArgumentosCntrAnuIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_marcarAsignacionBonificacionIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarArgumentoIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarCatalogacionCodCiaCntrAnulIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarConceptoFuncionalRESTIntegracion | SCAC SCA Webservice | PUT | `es_pca_gestionartareas_bbe-web/esp/api/1.0/gestionAplicacionPUT` |
| SCAC_modificarCrearDocumentoCartaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarCrearDocumentoDniIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarCrearDocumentosAdminIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarDocumentoIntegracion | SCAC SCA Webservices Documentacion | POST | `system.http` |
| SCAC_modificarEstadoAutorizacionIntegracion | SCAC SCA Wmbig1is | POST | `system.http` |
| SCAC_modificarIDSTCATCntrAnulIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_modificarMarcaEconomica | SCAC SCA Webservice | POST | `es_pca_gestionartareas_bbe-web/esp/api/1.0/modifMarcaEconomica` |
| SCAC_modificarTipoConsentimientoIntegracion | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8633590 | POST | `system.http` |
| SCAC_monitorizarSolicitud | SCAC SCA Core7 | POST | `system.http` |
| SCAC_notificarPorMailteckIntegracion | _a-0000ea92-10b3-8000-9c1b-011c48011c48_8633590 | POST | `system.http` |
| SCAC_obtenerArgumentarioIntegracion | SCAC SCA Core8 | POST | `system.http` |
| SCAC_obtenerDatosProductorIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_obtenerEstComClaveIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_obtenerEstComNuumaIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_obtenerEstructuraComercialIntegracion | SCAC SCA Esb | POST | `system.http` |
| SCAC_obtenerListadoDocsSGO | _a-0000e7dd-f179-8000-9bc1-011c48011c48_364620 | GET | `system.http` |
| SCAC_obtenerMarcaRvaPrimasIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_obtenerOficinasFisicasNuumaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_obtenerOficinas | SCAC SCA Soa7 | POST | `system.http` |
| SCAC_obtenerPolizaPrerenovadaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_obtenerSVADisponiblesRESTIntegracion | SCAC SCA Webservice | POST | `es_mkfd_tc_movil_app_be-web/api/tecuidamos/socios/svaDisponibles` |
| SCAC_obtenerSolicitudesNuumaRESTIntegracion | SCAC SCA Wmbig1s REST | GET | `system.http` |
| SCAC_obtenerTokenRetosRESTIntegracion | - | POST | `system.http` |
| SCAC_obtenerTraduccionMotivosSca | SCAC SCA Wmbig1s REST | POST | `traducciones/v1_0/motivos` |
| SCAC_obtenerUrlGestionCompetenciaIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_pBuscarPolizaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_pListarCiasPolizaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_pObtenerPolizaFechaIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_posibilidadReservaPrima | SCAC SCA Webservice APP-PCA-SOLIC | POST | `system.http` |
| SCAC_prueba2 | - | POST | `system.http` |
| SCAC_reasignarTareaNivelIIIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCAC_scaServiciosReglas | SCAC SCA Webservice | POST | `system.http` |
| SCAC_searchDocumentos | SCAC SCA WEBSERVICE SEARCH | POST | `system.http` |
| SCAC_simularAnulacionPolizaIntegracion | SCAC SCA Webservice | POST | `system.http` |
| SCAC_simularAnulacionPolizaRESTIntegracion | SCAC SCA WebServicesEmision | POST | `system.http` |
| SCAC_tokenSGC3 | - | GET | `system.http` |
| SCAC_visualizarDatosSolicitudIntegracion | SCAC SCA Core7 | POST | `system.http` |
| SCA_CMP_APIClients_Perfil | SCAC API Clients | GET | `system.http` |

## Record types (SCA — 19)

| name | sourceType | table / dataSource | fields | relationships |
|---|---|---|---|---|
| SCA Compañia Contraria | WEB_SERVICE |   | 3 | 1 |
| SCA Concepto Funcional | WEB_SERVICE |   | 4 | 1 |
| SCA Concepto | WEB_SERVICE |   | 2 | 1 |
| SCA Datos Poliza Vida | DATABASE | datosPolizaVida SCAC AWS DB | 89 | 1 |
| SCA Documentos Estaticos | DATABASE | documentosEstaticos SCAC AWS DB | 2 | 1 |
| SCA Reserva Prima | DATABASE | polizas_exclusiva_rsva SCAC AWS DB | 11 | 1 |
| SCA TareasPorPolizaAWS | DATABASE | tareas_por_poliza SCAC AWS DB | 11 | 1 |
| SCA Traduccion Motivo Detalle Causa | DATABASE | sca_traduccion_motivos SCAC AWS DB | 15 | 1 |
| SCA Trazabilidad Cliente | DATABASE | sca_trazabilidad_cliente SCAC AWS DB | 11 | 1 |
| SCA datosBasicosSolicitud | DATABASE | datosBasicosSolicitud SCAC AWS DB | 8 | 1 |
| SCA datosCabecera | DATABASE | datosCabecera SCAC AWS DB | 43 | 1 |
| SCA datosPerfilesPca | DATABASE | datosPerfilesPca SCAC AWS DB | 5 | 1 |
| SCA datosPolizaAutos | DATABASE | datosPolizaAutos SCAC AWS DB | 83 | 1 |
| SCA datosPolizaHogar | DATABASE | datosPolizaHogar SCAC AWS DB | 89 | 1 |
| SCA datosProductor | DATABASE | datosProductor SCAC AWS DB | 15 | 1 |
| SCA datosSolicitud | DATABASE | datosSolicitud SCAC AWS DB | 27 | 1 |
| SCA nivelesCoberturaAutos | DATABASE | nivelesCoberturaAutos SCAC AWS DB | 5 | 1 |
| SCA otrasSolicitudesCabecera | DATABASE | otrasSolicitudesCabecera SCAC AWS DB | 10 | 1 |
| SCA solicitudAnulacion | DATABASE | solicitudAnulacion SCAC AWS DB | 26 | 1 |

## Sites

### SCA Decidir Accion (`decidir-accion`)
- Solicitudes anulación (INTERFACE → SCA_DecidirAccion, /decidiraccion, visibility: `fn!true()`)
- Gestiones mantenimiento (INTERFACE → SCA_GestionMantenimientoMenu, /gestiones-mantenimiento, visibility: `rule!SCA_isUsuarioProceso()`)
### SCA_Site (`sca-site`)
- Solicitudes anulación (INTERFACE → SCA_BuscadorSolicitudPrincipal, /b-squeda, visibility: `fn!true()`)
- Gestiones mantenimiento (INTERFACE → SCA_GestionMantenimientoMenu, /gestiones-mantenimiento, visibility: `rule!SCA_isUsuarioProceso()`)

## Web APIs

| app | name | method | alias | public |
|---|---|---|---|---|
| SCA | SCA Decisora | GET | decisora | False |
| SCA | SCA Eliminar Tareas AWS | POST | eliminarTareas | False |
| SCA | SCA Eliminar Tareas BBDD | POST | eliminarTareasBBDD | False |
| SCA | SCA Lanzar Reserva Prima | POST | ejecutarRsvPrima | False |
| SCA | SCA Volcado Datos Reserva Prima | POST | volcadoReservaPrima | False |
| SCAC | SCAC_GestionarAutorizacionIA | POST | gestionarAutorizacionIA | False |
| SCAC | SCAC_GestionarAutorizacionSTCAT | POST | 2v1iyg | False |
| SCAC | SCAC_GestionarAutorizacionSgo | POST | modificaEstadoAutorizacion | False |
| SCAC | SCAC LanzarDocumentsToRecord | POST | DocumentsToRecord | False |
| SCAC | SCAC Obtener Credenciales Conceptos | GET | obtenerCredencialesConceptos | False |
| SCAC | SCAC Prueba | POST | uYqGGA | False |
| SCAC | SCAC Submit Uploaded File | POST | submitUploadedFile | False |
| SCAC | SCAC_insertarCompañiasContrariasVida | POST | KdX27Q | False |

## Constants referencing process models / other objects

| app | constant | type | value | resolves to |
|---|---|---|---|---|
| SCA | SCA_BOOL_BATCH_NSE | BOOLEAN | `1` | 1 (?) |
| SCA | SCA_BUZON_CUE_AUTOS | EMAIL_ADDRESS | `cueanulacionautos@mapfre.com` | cueanulacionautos@mapfre.com (?) |
| SCA | SCA_BUZON_CUE_HOGAR | EMAIL_ADDRESS | `cueanulacionhogar@mapfre.com` | cueanulacionhogar@mapfre.com (?) |
| SCA | SCA_COMPAÑIAS_CONTRARIAS_VIDA | PROCESS_MODEL | `0002edf5-164b-8000-f361-7f0000014e7a` | SCA Compañia Contraria Vida (SCA) |
| SCA | SCA_DSE_TM_TRANSACTION | DATA_STORE_ENTITY | `dd5ec92b-58dc-4d22-a48e-df09144d30d0@7417` | dd5ec92b-58dc-4d22-a48e-df09144d30d0@7417 (?) |
| SCA | SCA_FLD_ACCION_ADMINISTRATIVA | FOLDER | `_a-0000ebf6-689c-8000-9c69-011c48011c48_13293248` | SCA Documentos Acciones Administrativas (SCA) |
| SCA | SCA_FLD_AUTORIZACION | FOLDER | `_a-0000ebf6-689c-8000-9c69-011c48011c48_13293292` | SCA Documentos Autorizacion (SCA) |
| SCA | SCA_FLD_CLIENTE_TIPO_VALOR | FOLDER | `_a-0000eba7-4ece-8000-9c59-011c48011c48_12352654` | SCA Cliente Tipo Valor (SCA) |
| SCA | SCA_FLD_CONTRA_ANULACION | FOLDER | `_a-0000ebf6-689c-8000-9c69-011c48011c48_13293254` | SCA Documentos Contra Anulación (SCA) |
| SCA | SCA_FLD_DOCUMENTACION_ARGUMENTARIO | FOLDER | `_a-0000eba7-4ece-8000-9c59-011c48011c48_12308402` | SCA Documentación argumentario (SCA) |
| SCA | SCA_FLD_DOCUMENTACION | FOLDER | `654396ce-33d1-4d39-95bd-811cc65605c2` | SCA Documentación de aplicación (SCA) |
| SCA | SCA_FLD_DOCUMENTOS_ARGUMENTOS | FOLDER | `_a-0000ed7d-cf02-8000-9c8d-011c48011c48_16620181` | SCA Documentos Argumentos Temporales (SCA) |
| SCA | SCA_GENERAR_SOLICITUD | PROCESS_MODEL | `0002ee63-b680-8000-0def-7f0000014e7a` | SCA Generar Solicitud (SCA) |
| SCA | SCA_GRP_ACCESO_DECISORA_NUUMAS | GROUP | `SCA Acceso Decisora` | SCA Acceso Decisora (?) |
| SCA | SCA_GRP_ACCESO_DECISORA_VIDA_NUUMAS | GROUP | `SCA Acceso Decisora Vida` | SCA Acceso Decisora Vida (?) |
| SCA | SCA_GRP_ADMINISTRADORES | GROUP | `SCA Administradores` | SCA Administradores (?) |
| SCA | SCA_GRP_ALERTAS | GROUP | `SCA Alertas` | SCA Alertas (?) |
| SCA | SCA_GRP_CE_CONSULTA_TEST | GROUP | `SCA_CE_CONSULTA_TEST` | SCA_CE_CONSULTA_TEST (?) |
| SCA | SCA_GRP_CE_CONSULTA | GROUP | `SCA_CE_CONSULTAold` | SCA_CE_CONSULTAold (?) |
| SCA | SCA_GRP_CE_MF_BK_EXPERTO_SI24_TEST | GROUP | `SCA_CE_MF_BK_EXPERTO_SI24_TEST` | SCA_CE_MF_BK_EXPERTO_SI24_TEST (?) |
| SCA | SCA_GRP_CE_MF_BK_EXPERTO_SI24 | GROUP | `SCA_CE_MF_BK_EXPERTO_SI24old` | SCA_CE_MF_BK_EXPERTO_SI24old (?) |
| SCA | SCA_GRP_CE_MF_CENTRAL_AT_TEST | GROUP | `SCA_CE_MF_CENTRAL_AT_TEST` | SCA_CE_MF_CENTRAL_AT_TEST (?) |
| SCA | SCA_GRP_CE_MF_CENTRAL_AT | GROUP | `SCA_CE_MF_CENTRAL_ATold` | SCA_CE_MF_CENTRAL_ATold (?) |
| SCA | SCA_GRP_CE_MF_CONTROL_TEST | GROUP | `SCA_CE_MF_CONTROL_TEST` | SCA_CE_MF_CONTROL_TEST (?) |
| SCA | SCA_GRP_CE_MF_CONTROL | GROUP | `SCA_CE_MF_CONTROLold` | SCA_CE_MF_CONTROLold (?) |
| SCA | SCA_GRP_CE_MF_RECIBOS_CCC_TEST | GROUP | `SCA_CE_MF_RECIBOS_CCC_TEST` | SCA_CE_MF_RECIBOS_CCC_TEST (?) |
| SCA | SCA_GRP_CE_MF_RECIBOS_CCC | GROUP | `SCA_CE_MF_RECIBOS_CCCold` | SCA_CE_MF_RECIBOS_CCCold (?) |
| SCA | SCA_GRP_CE_MF_RECIBOS_CCR_TEST | GROUP | `SCA_CE_MF_RECIBOS_CCR_TEST` | SCA_CE_MF_RECIBOS_CCR_TEST (?) |
| SCA | SCA_GRP_CE_MF_RECIBOS_CCR | GROUP | `SCA_CE_MF_RECIBOS_CCRold` | SCA_CE_MF_RECIBOS_CCRold (?) |
| SCA | SCA_GRP_CE_MF_SI24_CENTRAL_TEST | GROUP | `SCA_CE_MF_SI24_CENTRAL_TEST` | SCA_CE_MF_SI24_CENTRAL_TEST (?) |
| SCA | SCA_GRP_CE_MF_SI24_CENTRAL | GROUP | `SCA_CE_MF_SI24_CENTRALold` | SCA_CE_MF_SI24_CENTRALold (?) |
| SCA | SCA_GRP_CE_MF_SI24_EXPERTO_TEST | GROUP | `SCA_CE_MF_SI24_EXPERTO_TEST` | SCA_CE_MF_SI24_EXPERTO_TEST (?) |
| SCA | SCA_GRP_CE_MF_SI24_EXPERTO | GROUP | `SCA_CE_MF_SI24_EXPERTOold` | SCA_CE_MF_SI24_EXPERTOold (?) |
| SCA | SCA_GRP_CE_MF_SI24_FRONT_TEST | GROUP | `SCA_CE_MF_SI24_FRONT_TEST` | SCA_CE_MF_SI24_FRONT_TEST (?) |
| SCA | SCA_GRP_CE_MF_SI24_FRONT | GROUP | `SCA_CE_MF_SI24_FRONTold` | SCA_CE_MF_SI24_FRONTold (?) |
| SCA | SCA_GRP_CE_MF_SI24_SA_TEST | GROUP | `SCA_CE_MF_SI24_SA_TEST` | SCA_CE_MF_SI24_SA_TEST (?) |
| SCA | SCA_GRP_CE_MF_SI24_SA | GROUP | `SCA_CE_MF_SI24_SAold` | SCA_CE_MF_SI24_SAold (?) |
| SCA | SCA_GRP_CE_MF_SI24_TECNICO_TEST | GROUP | `SCA_CE_MF_SI24_TECNICO_TEST` | SCA_CE_MF_SI24_TECNICO_TEST (?) |
| SCA | SCA_GRP_CE_MF_SI24_TECNICO | GROUP | `SCA_CE_MF_SI24_TECNICOold` | SCA_CE_MF_SI24_TECNICOold (?) |
| SCA | SCA_GRP_CE_RM_AGENTE_TEST | GROUP | `SCA_CE_RM_AGENTE_TEST` | SCA_CE_RM_AGENTE_TEST (?) |
| SCA | SCA_GRP_CE_RM_AGENTE | GROUP | `SCA_CE_RM_AGENTEold` | SCA_CE_RM_AGENTEold (?) |
| SCA | SCA_GRP_CE_RM_DT_TEST | GROUP | `SCA_CE_RM_DT_TEST` | SCA_CE_RM_DT_TEST (?) |
| SCA | SCA_GRP_CE_RM_DT | GROUP | `SCA_CE_RM_DTold` | SCA_CE_RM_DTold (?) |
| SCA | SCA_GRP_CE_RM_OFICINA_TEST | GROUP | `SCA_CE_RM_OFICINA_TEST` | SCA_CE_RM_OFICINA_TEST (?) |
| SCA | SCA_GRP_CE_RM_OFICINA | GROUP | `SCA_CE_RM_OFICINAold` | SCA_CE_RM_OFICINAold (?) |
| SCA | SCA_GRP_PROCESO | GROUP | `SCA_PROCESO` | SCA_PROCESO (?) |
| SCA | SCA_GUARDAR_TRAZABILIDAD | PROCESS_MODEL | `0002ed71-8e90-8000-df18-7f0000014e7a` | SCA Guardar Trazabilidad (SCA) |
| SCA | SCA_INT_CANALES_ENTRADA_COD | INTEGER | `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]` | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] (?) |
| SCA | SCA_INT_CODIGO_COMPANIA | INTEGER | `[1, 41, 3]` | [1, 41, 3] (?) |
| SCA | SCA_INT_MEDIOS_COMUNICACION_COD | INTEGER | `[1, 2, 3, 4, 5, 6]` | [1, 2, 3, 4, 5, 6] (?) |
| SCA | SCA_INT_RAMA_NEGOCIO_VALUES | INTEGER | `[200, 210, 73, 0, 101]` | [200, 210, 73, 0, 101] (?) |
| SCA | SCA_INT_TIP_CATALOGACION_PCA | INTEGER | `[1, 2, 3, 4, 5]` | [1, 2, 3, 4, 5] (?) |
| SCA | SCA_OBETENER_DOCUMENTO_ARGUMENTO | PROCESS_MODEL | `0002ed8e-3f29-8000-8032-7f0000014e7a` | SCA Obtener Documento Argumentos (SCA) |
| SCA | SCA_PLANTILLA_CONTRATO_COMPRA_VENTA | DOCUMENT | `_a-0000f012-d2f8-8000-9cbe-011c48011c48_19745745` | SCA Plantilla contrato compra venta (SCA) |
| SCA | SCA_PM_ALTA_CONTRA_ANULACION | PROCESS_MODEL | `0003ee68-f88a-8000-0e66-7f0000014e7a` | SCA Alta Contra Anulacion (SCA) |
| SCA | SCA_PM_ALTA_MECANIZACION | PROCESS_MODEL | `0002eebd-894d-8000-205c-7f0000014e7a` | SCA Alta Mecanización (SCA) |
| SCA | SCA_PM_ALTA_SOLICITUD_ANULACION_ANTIGUO | PROCESS_MODEL | `0002eb8b-09db-8000-c7f1-7f0000014e7a` | SCA Alta Solicitud Anulacion (SCA) |
| SCA | SCA_PM_ALTA_SOLICITUD_ANULACION_PARTICION | PROCESS_MODEL | `0038ee6b-8ea7-8000-0ec5-7f0000014e7a` | SCA Alta Solicitud Anulacion Particionado (SCA) |
| SCA | SCA_PM_BATCH_CADUCIDAD | TEXT | `0002eea4-5cfb-8000-1a24-7f0000014e7a` | SCA Batch Caducidad (SCA) |
| SCA | SCA_PM_BATCH_RESERVA_PRIMA | PROCESS_MODEL | `0002ed20-bc58-8000-d006-7f0000014e7a` | SCA Batch Rsva Prima SGO (SCA) |
| SCA | SCA_PM_BATCH_RSV_PRIMA | TEXT | `0002ed20-bc58-8000-d006-7f0000014e7a` | SCA Batch Rsva Prima SGO (SCA) |
| SCA | SCA_PM_DOCUMENTS_TO_RECORD | PROCESS_MODEL | `0002efb9-8297-8000-4b6e-7f0000014e7a` | SCA Documents to Record (SCA) |
| SCA | SCA_PM_DOCXPDF | PROCESS_MODEL | `0002ec42-3de5-8000-8e91-7f0000014e7a` | SCA DocxPDF (SCA) |
| SCA | SCA_PM_ELIMINAR_DOCUMENTOS | PROCESS_MODEL | `0002ec09-316e-8000-6612-7f0000014e7a` | SCA Eliminar documentos (SCA) |
| SCA | SCA_PM_ELIMINAR_TAREAS_BBDD | PROCESS_MODEL | `0016ee97-2987-8000-1690-7f0000014e7a` | SCA Eliminar Tablas BBDD (SCA) |
| SCA | SCA_PM_FINALIZAR_CONTRA_ANULACION | PROCESS_MODEL | `0003ee68-fcf2-8000-0e6e-7f0000014e7a` | SCA Finalizar Contra Anulacion (SCA) |
| SCA | SCA_PM_FINALIZAR_MECANIZACION | PROCESS_MODEL | `0002eebd-9493-8000-2062-7f0000014e7a` | SCA Finalizar Mecanización (SCA) |
| SCA | SCA_PM_MECANIZACION | PROCESS_MODEL | `0002ec01-57f1-8000-612e-7f0000014e7a` | SCA Mecanizacion (SCA) |
| SCA | SCA_PM_OBTENER_DOCUMENTO_GD | PROCESS_MODEL | `0002ed21-1fa0-8000-d071-7f0000014e7a` | SCA Obtener Documento GD (SCA) |
| SCA | SCA_PM_POSPONER_CONTRA_ANULACION | PROCESS_MODEL | `0008ee8e-10c3-8000-14d8-7f0000014e7a` | SCA Posponer Contra Anulacion (SCA) |
| SCA | SCA_PM_REASIGNAR_TAREA_ESTRATEGICA | PROCESS_MODEL | `0002ee91-d163-8000-1604-7f0000014e7a` | SCA Reasignar Tarea Estrategica (SCA) |
| SCA | SCA_PM_REASIGNAR_TAREA | PROCESS_MODEL | `0002ec14-0a43-8000-6b64-7f0000014e7a` | SCA Reasignar Tarea (SCA) |
| SCA | SCA_PM_REDIRIGIRDETALLE | PROCESS_MODEL | `0002ec38-8cf5-8000-8881-7f0000014e7a` | SCA Redirigir Detalle Solicitud (SCA) |
| SCA | SCA_REP_PROCESS_MECANIZACIONES | DOCUMENT | `_a-0000ecf1-045c-8000-9c82-011c48011c48_15634446` | SCA Mecanizaciones (SCA) |
| SCA | SCA_REP_PROCESS_REPORT_POLIZA_NEW | DOCUMENT | `_a-0000ecf1-045c-8000-9c82-011c48011c48_15634439` | SCA Tareas Por Poliza (SCA) |
| SCA | SCA_TIMER_OK | INTEGER | `5` | 5 (?) |
| SCA | SCA_TXT_EMAIL_DUE_PARA_ALTITUDE_TEST | EMAIL_ADDRESS | `<correo-personal-redactado>` | <correo-personal-redactado> (?) |
| SCA | SCA_TXT_EMAIL_DUE_PARA_ALTITUDE | EMAIL_ADDRESS | `APP-ALTITUDEMAIL93@mapfre.com` | APP-ALTITUDEMAIL93@mapfre.com (?) |
| SCA | SCA_TXT_EMAIL_DUE_PARA_EXPERTOS | EMAIL_ADDRESS | `APP-ALTITUDEMAIL93@mapfre.com` | APP-ALTITUDEMAIL93@mapfre.com (?) |
| SCA | SCA_TXT_EMAIL_ENVIO_ERRORES | EMAIL_ADDRESS | `pruebasca@mapfre.com` | pruebasca@mapfre.com (?) |
| SCA | SCA_VAL_ID_ACCION_COMERCIAL | INTEGER | `5799` | 5799 (?) |
| SCAC | ANL_DESBLOQUEARSGO | PROCESS_MODEL | `0002eab3-dea6-8000-b85c-7f0000014e7a` | 0002eab3-dea6-8000-b85c-7f0000014e7a (?) |

## Constants not matching their app prefix (cross-app candidates)

- SCA: none
- SCAC: ANL_DESBLOQUEARSGO, SCA_FORMAPAGOVIDA_URL

## Expression reference prefixes (from .sail files + PM/integration expressions)

Prefix tallies across all dumped expressions:

- `SCA`: 2416 references
- `SCA_`: 2289 references
- `SCAC_`: 455 references
- `CMP_`: 160 references
- `PGM_`: 112 references
- `ANL_`: 68 references
- `ANL`: 65 references
- `TM_`: 3 references
- `SCAT_`: 1 references

By scheme (top 30):

- `recordType!SCA…`: 2404
- `cons!SCA_…`: 1197
- `rule!SCA_…`: 1091
- `cons!SCAC_…`: 309
- `rule!SCAC_…`: 146
- `rule!CMP_…`: 125
- `rule!PGM_…`: 103
- `recordType!ANL…`: 65
- `rule!ANL_…`: 40
- `cons!CMP_…`: 35
- `cons!ANL_…`: 28
- `site!SCA…`: 12
- `cons!PGM_…`: 9
- `cons!TM_…`: 2
- `site!SCA_…`: 1
- `rule!SCAT_…`: 1
- `rule!TM_…`: 1

## SCA objects referencing SCAC_* objects

- `SCA/expressionRules/SCAC_consultarConceptoFuncionalRESTIntegracion_syncER___a-0000ec66-e1cc-8000-9c7b-011c48011c48_14558363.sail`: rule!SCAC_consultarConceptoFuncionalRESTIntegracion
- `SCA/expressionRules/SCAC_consultarConceptoIntegracion_syncExpression___a-0000ec95-047c-8000-9c80-011c48011c48_14816173.sail`: rule!SCAC_consultarConceptoIntegracion
- `SCA/expressionRules/SCA_AsignarTrebolesClubMapfre___a-0000ee64-4a6f-8000-9c9f-011c48011c48_17658071.sail`: rule!SCAC_executeAsignarIntegracion
- `SCA/expressionRules/SCA_CargaGcOnline___a-0000ee81-5c2e-8000-9cb8-011c48011c48_3135470.sail`: rule!SCAC_CargaGcOnLine
- `SCA/expressionRules/SCA_ObtenerCodClaseAGT___a-0000efdc-ca1b-8000-9cba-011c48011c48_19547779.sail`: rule!SCAC_consultaClaveIntegracion
- `SCA/expressionRules/SCA_aceptarAutorizacion___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12546433.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_aceptarAutorizacionIntegracion
- `SCA/expressionRules/SCA_actualizarSolicitud___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12616307.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_actualizarSolicitudIntegracion
- `SCA/expressionRules/SCA_actualizarVariable___a-0000eba7-4ece-8000-9c59-011c48011c48_12281869.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_actualizarVariableIntegracion
- `SCA/expressionRules/SCA_addressAPIClients___a-0000ec29-030c-8000-9c73-011c48011c48_13873422.sail`: rule!SCAC_APIClients_Address
- `SCA/expressionRules/SCA_altaDocumento___a-0000eba7-4ece-8000-9c59-011c48011c48_12336159.sail`: rule!SCAC_altaDocumentoIntegracion
- `SCA/expressionRules/SCA_altaSGORehabilitar___a-0000eed3-5c82-8000-9cab-011c48011c48_18360464.sail`: rule!SCAC_consultarCatalogoTareas, rule!SCAC_crearSolicitud
- `SCA/expressionRules/SCA_altaSGOVida___a-0000efdc-ca1b-8000-9cba-011c48011c48_19575123.sail`: rule!SCAC_consultarCatalogoTareas, rule!SCAC_crearSolicitud
- `SCA/expressionRules/SCA_altaSGO___a-0001efc0-657e-8000-9cb5-011c48011c48_19361219.sail`: rule!SCAC_consultarCatalogoTareas, rule!SCAC_crearSolicitud
- `SCA/expressionRules/SCA_asignarRetos__396d45bf-03f0-4e42-be92-a7d73b1a7bba.sail`: rule!SCAC_asignarRetosRESTIntegracion, rule!SCAC_obtenerTokenRetosRESTIntegracion
- `SCA/expressionRules/SCA_asignarSVA__3f9f6156-4e40-4143-93bb-0d083e85de29.sail`: rule!SCAC_AsignarSVARestIntegracion
- `SCA/expressionRules/SCA_benefitsAPIClients___a-0000eba7-4ece-8000-9c59-011c48011c48_12331007.sail`: rule!SCAC_APIClients_Benefits
- `SCA/expressionRules/SCA_bloquearPolizaEnCentralEstrategicas___a-0000eebe-52f3-8000-9ca6-011c48011c48_18183665.sail`: rule!SCAC_bloquearPolizaEnCentralIntegracion
- `SCA/expressionRules/SCA_bloquearPolizaEnCentral___a-0000ec4b-f117-8000-9c47-011c48011c48_1597994.sail`: rule!SCAC_bloquearPolizaEnCentralIntegracion
- `SCA/expressionRules/SCA_borrarDocumentoSCA___a-0000ebf6-689c-8000-9c69-011c48011c48_13320258.sail`: rule!SCAC_borrarDocumentoSCA
- `SCA/expressionRules/SCA_buscarMatricula___a-0000eba3-574b-8000-9c56-011c48011c48_12211202.sail`: rule!SCAC_buscarMatriculaIntegracion
- `SCA/expressionRules/SCA_cargaGestionPCA___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12649479.sail`: rule!SCAC_CargaGestionPCAIntegration
- `SCA/expressionRules/SCA_cargaGestionSGC___a-0000f036-fd58-8000-9cc1-011c48011c48_19915868.sail`: rule!SCAC_cargaGestionSGC3
- `SCA/expressionRules/SCA_cerrarOperacion___a-0000ec13-1536-8000-9c71-011c48011c48_13530125.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_cerrarOperacion
- `SCA/expressionRules/SCA_comprobarCliente___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12537169.sail`: rule!SCAC_comprobarClienteIntegracion
- `SCA/expressionRules/SCA_comprobarPropietario__125477f8-5129-4430-8bbb-42273a41e7cb.sail`: cons!SCAC_VAL_HOST_ESB, rule!SCAC_comprobarPropietarioIntegracion
- `SCA/expressionRules/SCA_comprobarSolicitudesVigencia___a-0001ef2c-f97c-8000-9cb0-011c48011c48_18777586.sail`: rule!SCAC_consultaSolicitudesIntegracion
- `SCA/expressionRules/SCA_consultaBBDDSCA___a-0000ebf6-689c-8000-9c69-011c48011c48_13318441.sail`: rule!SCAC_consultaBBDDSCA
- `SCA/expressionRules/SCA_consultaClasificacionTC__6c95149c-76c0-4227-ba76-0fb22d4a08de.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultaClasificacionTCIntegracion
- `SCA/expressionRules/SCA_consultaClave___a-0000edf5-ee9a-8000-9c96-011c48011c48_17300435.sail`: rule!SCAC_consultaClaveIntegracion
- `SCA/expressionRules/SCA_consultaDetalleGestion___a-0000eba7-4ece-8000-9c59-011c48011c48_12283574.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultaDetalleGestionIntegracion
- `SCA/expressionRules/SCA_consultaDocumento___a-0000eba3-574b-8000-9c56-011c48011c48_12240079.sail`: rule!SCAC_consultaDocumentoIntegracion
- `SCA/expressionRules/SCA_consultaGestion___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12495037.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultaGestionIntegracion
- `SCA/expressionRules/SCA_consultaImpr___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12485081.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultaImprIntegracion
- `SCA/expressionRules/SCA_consultaPropiedadClave___a-0000ebec-27b2-8000-9c65-011c48011c48_13089797.sail`: cons!SCAC_VAL_HOST_ESB, rule!SCAC_consultaPropiedadClaveIntegracion
- `SCA/expressionRules/SCA_consultarAccAdm___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12485113.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarAccAdmIntegracion
- `SCA/expressionRules/SCA_consultarAccesoStudPorModo___a-0000ebf6-689c-8000-9c69-011c48011c48_13351235.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarAccesoStudPorModoIntegracion
- `SCA/expressionRules/SCA_consultarAnulacionPoliza___a-0000ebec-27b2-8000-9c65-011c48011c48_13078745.sail`: rule!SCAC_consultarAnulacionPolizaIntegracion
- `SCA/expressionRules/SCA_consultarAutorizacion___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12546566.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarAutorizacionIntegracion
- `SCA/expressionRules/SCA_consultarCabeceraSolicitud___a-0000eba7-4ece-8000-9c59-011c48011c48_12389367.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarCabeceraIntegracion
- `SCA/expressionRules/SCA_consultarCabecera___a-0000eb9b-717e-8000-9c54-011c48011c48_12082656.sail`: rule!SCAC_consultarCabeceraRestIntegracion
- `SCA/expressionRules/SCA_consultarCatalogacionRest___a-0000eba3-574b-8000-9c56-011c48011c48_12156411.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_consultarCatalogacionRestIntegracion
- `SCA/expressionRules/SCA_consultarCausa___a-0000eb8a-166b-8000-9c4c-011c48011c48_11835932.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarCausaIntegracion
- `SCA/expressionRules/SCA_consultarClavevida___a-0000edd8-a766-8000-9c93-011c48011c48_17022195.sail`: rule!SCAC_consultaClaveVida
- `SCA/expressionRules/SCA_consultarCompa_iasContrarias_recordDataSource___a-0000ec66-e1cc-8000-9c7b-011c48011c48_14509286.sail`: rule!SCAC_catalogFilteredIntegracion
- `SCA/expressionRules/SCA_consultarConceptoFuncionalREST___a-0000eba3-574b-8000-9c56-011c48011c48_12219093.sail`: rule!SCAC_consultarConceptoFuncionalRESTIntegracion
- `SCA/expressionRules/SCA_consultarConceptoFuncionalREST_recordDataSource___a-0000ec66-e1cc-8000-9c7b-011c48011c48_14504716.sail`: rule!SCAC_consultarConceptoFuncionalRESTIntegracion
- `SCA/expressionRules/SCA_consultarConceptoIntegracion_recordDataSource___a-0000ec66-e1cc-8000-9c7b-011c48011c48_14559186.sail`: rule!SCAC_consultarConceptoIntegracion
- `SCA/expressionRules/SCA_consultarConcepto___a-0000eb8a-166b-8000-9c4c-011c48011c48_11827697.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarConceptoIntegracion
- `SCA/expressionRules/SCA_consultarContacto___a-0000ebf6-689c-8000-9c69-011c48011c48_13297580.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarContactoIntegracion
- `SCA/expressionRules/SCA_consultarDP___a-0000eba3-574b-8000-9c56-011c48011c48_12156671.sail`: rule!SCAC_consultarDPIntegracion
- `SCA/expressionRules/SCA_consultarDatosIdentificativos___a-0000eb93-88e3-8000-9c50-011c48011c48_12002466.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_consultarDatosIdentificativosIntegracion
- `SCA/expressionRules/SCA_consultarDetalleSolicitud___a-0000ebf6-689c-8000-9c69-011c48011c48_13235949.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultaDetalleSolicitudIntegracion
- `SCA/expressionRules/SCA_consultarDetalle___a-0000eb8a-166b-8000-9c4c-011c48011c48_11835859.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarDetalleIntegracion
- `SCA/expressionRules/SCA_consultarDocumentosREST___a-0000ee64-4a6f-8000-9c9f-011c48011c48_17999207.sail`: rule!SCAC_consultarDocumentosIntegracion
- `SCA/expressionRules/SCA_consultarDocumentos___a-0000eba3-574b-8000-9c56-011c48011c48_12170267.sail`: rule!SCAC_consultarDocumentosIntegracion
- `SCA/expressionRules/SCA_consultarEquipos___a-0000eba3-574b-8000-9c56-011c48011c48_12233343.sail`: rule!SCAC_consultarEquiposIntegracion
- `SCA/expressionRules/SCA_consultarEstructuraComercial___a-0000edd8-a766-8000-9c93-011c48011c48_17042193.sail`: rule!SCAC_consultaEstructuraComercialVida
- `SCA/expressionRules/SCA_consultarFechaUltimoSiniestro___a-0000eb9b-717e-8000-9c54-011c48011c48_12056902.sail`: rule!SCAC_consultarSiniestrosAutosIntegracion
- `SCA/expressionRules/SCA_consultarListadoArgumentos___a-0000ec31-13b0-8000-9c78-011c48011c48_13965521.sail`: rule!SCAC_consultarListadoArgumentosREST
- `SCA/expressionRules/SCA_consultarListadoObs___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12485097.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarListadoObsIntegracion
- `SCA/expressionRules/SCA_consultarMotivo___a-0000eb8a-166b-8000-9c4c-011c48011c48_11835851.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarMotivoIntegracion
- `SCA/expressionRules/SCA_consultarNotificacionesExt___a-0000ec0b-9d5f-8000-9c6d-011c48011c48_13500693.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarNotificacionesExtIntegracion
- `SCA/expressionRules/SCA_consultarPlanPagoPorPoliza___a-0000eb9b-717e-8000-9c54-011c48011c48_12082664.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_consultarPlanPagoPorPolizaIntegracion
- `SCA/expressionRules/SCA_consultarPolizaVidaRiesgo__e18623ab-1a6e-41b8-a4ad-7ef18ffb7654.sail`: rule!SCAC_consultarPolizaVidaRiesgoIntegracion
- `SCA/expressionRules/SCA_consultarPolizas___a-0000eb93-88e3-8000-9c50-011c48011c48_11897083.sail`: rule!SCAC_consultarPolizasIntegracion
- `SCA/expressionRules/SCA_consultarReservaPrima___a-0000eb9b-717e-8000-9c54-011c48011c48_12086602.sail`: rule!SCAC_consultaReservaPrima
- `SCA/expressionRules/SCA_consultarServiciosReglas___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12495568.sail`: rule!SCAC_scaServiciosReglas
- `SCA/expressionRules/SCA_consultarSiniestroPoliza___a-0000eb9b-717e-8000-9c54-011c48011c48_12056147.sail`: rule!SCAC_consultarSiniestrosAutosIntegracion
- `SCA/expressionRules/SCA_consultarSolicitudes___a-0000eb9b-717e-8000-9c54-011c48011c48_12076283.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarSolicitudesIntegracion
- `SCA/expressionRules/SCA_consultarTipoArg___a-0000eb8a-166b-8000-9c4c-011c48011c48_11827800.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarTipoArgIntegracion
- `SCA/expressionRules/SCA_consultarUltimaGestionREST___a-0000ec29-030c-8000-9c73-011c48011c48_13850951.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_consultarUltimaGestionIntegracion
- `SCA/expressionRules/SCA_consultarValoresConcepto___a-0000eba7-4ece-8000-9c59-011c48011c48_12435974.sail`: rule!SCAC_consultarConceptoIntegracion
- `SCA/expressionRules/SCA_consultarVariable___a-0000eba7-4ece-8000-9c59-011c48011c48_12272039.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_consultarVariableIntegracion
- `SCA/expressionRules/SCA_contactMethodAPIClients___a-0000eba7-4ece-8000-9c59-011c48011c48_12331799.sail`: rule!SCAC_APIClients_contactMethod
- `SCA/expressionRules/SCA_crearAutorizacion___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12546478.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_crearAutorizacionIntegracion
- `SCA/expressionRules/SCA_determinarContacto__f3aeaf04-99f7-4b40-913e-3b26d8044550.sail`: rule!SCAC_determinarContactoREST
- `SCA/expressionRules/SCA_eliminarConceptoFuncionalREST___a-0000eba3-574b-8000-9c56-011c48011c48_12219101.sail`: rule!SCAC_eliminarConceptoFuncionalRESTIntegracion
- `SCA/expressionRules/SCA_finalizarContraAnulPca___a-0000ebdd-82f8-8000-9c64-011c48011c48_13020293.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_finalizarContraAnulPcaIntegracion
- `SCA/expressionRules/SCA_finalizarSolicitud__c3401fab-e0a3-4fdb-a4fa-2441541f9201.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_finalizarSolicitudIntegracion
- `SCA/expressionRules/SCA_generarStudAnul___a-0000ebf6-689c-8000-9c69-011c48011c48_13135409.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_generarStudAnul
- `SCA/expressionRules/SCA_guardarAccAdm___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12485105.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_guardarAccAdmIntegracion
- `SCA/expressionRules/SCA_guardarAutorizacion___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12546512.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_guardarAutorizacionIntegracion
- `SCA/expressionRules/SCA_guardarConcepto___a-0000eb9b-717e-8000-9c54-011c48011c48_12021865.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_guardarConceptoIntegracion
- `SCA/expressionRules/SCA_guardarEjecuArg___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12575473.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_guardarEjecuArgIntegracion
- `SCA/expressionRules/SCA_guardarImpr___a-0000ec31-13b0-8000-9c78-011c48011c48_14181950.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_guardarImprIntegracion
- `SCA/expressionRules/SCA_guardarTipoArg___a-0000eb93-88e3-8000-9c50-011c48011c48_11986910.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_guardarTipoArgIntegracion
- `SCA/expressionRules/SCA_inBSDeleteDocumentDTO___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12649945.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_inbsDeleteDocumentDTOIntegracion
- `SCA/expressionRules/SCA_insertarConceptoFuncionalREST___a-0000eba3-574b-8000-9c56-011c48011c48_12219130.sail`: rule!SCAC_insertarConceptoFuncionalRESTIntegracion
- `SCA/expressionRules/SCA_insertarNotificacionExterna__4f414038-4908-4f15-8ff5-510dde1dd820.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_insertarNotificacionExternaIntegracion
- `SCA/expressionRules/SCA_insertarObservaciones___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12485089.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_insertarObservacionesIntegracion
- `SCA/expressionRules/SCA_listarCiasPoliza___a-0000eebe-52f3-8000-9ca6-011c48011c48_18291833.sail`: rule!SCAC_pListarCiasPolizaIntegracion
- `SCA/expressionRules/SCA_listarDetalleArgumentosCntrAnu___a-0000eba7-4ece-8000-9c59-011c48011c48_12283810.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_listarDetalleArgumentosCntrAnuIntegracion
- `SCA/expressionRules/SCA_modificarArgumento___a-0000eb93-88e3-8000-9c50-011c48011c48_11911315.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_modificarArgumentoIntegracion
- `SCA/expressionRules/SCA_modificarCatalogacionCodCiaCntrAnul___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12485070.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_modificarCatalogacionCodCiaCntrAnulIntegracion
- `SCA/expressionRules/SCA_modificarConceptoFuncionalREST___a-0000eba3-574b-8000-9c56-011c48011c48_12219122.sail`: rule!SCAC_modificarConceptoFuncionalRESTIntegracion
- `SCA/expressionRules/SCA_modificarCrearDocumentoDni___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12614664.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_modificarCrearDocumentoDniIntegracion
- `SCA/expressionRules/SCA_modificarCrearDocumentosAdmin___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12614682.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_modificarCrearDocumentosAdminIntegracion
- `SCA/expressionRules/SCA_modificarCrearDocumentosCarta___a-0000ec31-13b0-8000-9c78-011c48011c48_14019895.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_modificarCrearDocumentoCartaIntegracion
- `SCA/expressionRules/SCA_modificarDocument___a-0000eba7-4ece-8000-9c59-011c48011c48_12336183.sail`: rule!SCAC_modificarDocumentoIntegracion
- `SCA/expressionRules/SCA_modificarMarcaEconomica___a-0000ef5f-2b36-8000-9cb2-011c48011c48_19009995.sail`: rule!SCAC_modificarMarcaEconomica
- `SCA/expressionRules/SCA_monitorizarSolicitud___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12521587.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_monitorizarSolicitud
- `SCA/expressionRules/SCA_obtenerDatosProductor___a-0000eba7-4ece-8000-9c59-011c48011c48_12357183.sail`: rule!SCAC_obtenerDatosProductorIntegracion
- `SCA/expressionRules/SCA_obtenerEstComClave___a-0000ecf1-045c-8000-9c82-011c48011c48_15854891.sail`: rule!SCAC_obtenerEstComClaveIntegracion
- `SCA/expressionRules/SCA_obtenerEstComNuuma___a-0000eba3-574b-8000-9c56-011c48011c48_12186133.sail`: cons!SCAC_VAL_HOST_ESB, rule!SCAC_obtenerEstComNuumaIntegracion
- `SCA/expressionRules/SCA_obtenerEstructuraComercial___a-0000eb9b-717e-8000-9c54-011c48011c48_12044542.sail`: cons!SCAC_VAL_HOST_ESB, rule!SCAC_obtenerEstructuraComercialIntegracion
- `SCA/expressionRules/SCA_obtenerMarcaEconomica___a-0000ef5f-2b36-8000-9cb2-011c48011c48_19008974.sail`: rule!SCAC_consultaMarcaEconomica
- `SCA/expressionRules/SCA_obtenerOficinasFisicasNuuma___a-0000ec55-424b-8000-9c7a-011c48011c48_14294096.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_obtenerOficinasFisicasNuumaIntegracion
- `SCA/expressionRules/SCA_obtenerOficinas___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12616954.sail`: rule!SCAC_obtenerOficinas
- `SCA/expressionRules/SCA_obtenerPolizaPrerenovada___a-0000eb9b-717e-8000-9c54-011c48011c48_12066127.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_obtenerPolizaPrerenovadaIntegracion
- `SCA/expressionRules/SCA_obtenerSVADisponibles___a-0000ebb9-d1d3-8000-9c5d-011c48011c48_12608625.sail`: rule!SCAC_obtenerSVADisponiblesRESTIntegracion
- `SCA/expressionRules/SCA_pBuscarPoliza___a-0000ef5f-2b36-8000-9cb2-011c48011c48_18956809.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_pBuscarPolizaIntegracion
- `SCA/expressionRules/SCA_pObtenerPolizaFecha___a-0000eb93-88e3-8000-9c50-011c48011c48_11897604.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_pObtenerPolizaFechaIntegracion
- `SCA/expressionRules/SCA_posibilidadReservaPrima___a-0000f05d-70b6-8000-9cc3-011c48011c48_20007412.sail`: rule!SCAC_posibilidadReservaPrima
- `SCA/expressionRules/SCA_searchAPIClients___a-0000eba7-4ece-8000-9c59-011c48011c48_12330831.sail`: rule!SCAC_APIClients_search
- `SCA/expressionRules/SCA_searchDocumentos___a-0000edd8-a766-8000-9c93-011c48011c48_16957109.sail`: rule!SCAC_searchDocumentos
- `SCA/expressionRules/SCA_simularAnulacionPolizaRest___a-0000ef5f-2b36-8000-9cb2-011c48011c48_18910851.sail`: rule!SCAC_simularAnulacionPolizaRESTIntegracion
- `SCA/expressionRules/SCA_simularAnulacionPoliza___a-0000ebec-27b2-8000-9c65-011c48011c48_13077560.sail`: cons!SCAC_VAL_HOST_WEBSERVICES, rule!SCAC_simularAnulacionPolizaIntegracion
- `SCA/expressionRules/SCA_visualizarDatosSolicitud___a-0000eba7-4ece-8000-9c59-011c48011c48_12283461.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_visualizarDatosSolicitudIntegracion
- `SCA/interfaces/SCA_ArgumentosContraAnulacionEstrategicas___a-0000ee64-4a6f-8000-9c9f-011c48011c48_17848003.sail`: rule!SCAC_descargaDocumentoIntegracion
- `SCA/interfaces/SCA_BuscarCompaniasContrarias___a-0000eb64-971e-8000-9c0e-011c48011c48_1686934.sail`: rule!SCAC_catalogFilteredIntegracion
- `SCA/interfaces/SCA_BuscarSolicitudClientePolizaEstrategicas___a-0000eec6-fe87-8000-9ca7-011c48011c48_18311500.sail`: rule!SCAC_consultarPolizaVidaRiesgoIntegracion
- `SCA/interfaces/SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas___a-0000ee64-4a6f-8000-9c9f-011c48011c48_18033401.sail`: rule!SCAC_executeAsignarIntegracion, rule!SCAC_gestionarTTQRESTIntegracion, rule!SCAC_marcarAsignacionBonificacionIntegracion
- `SCA/interfaces/SCA_ContraAnulacionModalRecuperacionPoliza___a-0000ebec-27b2-8000-9c65-011c48011c48_13087468.sail`: cons!SCAC_VAL_HOST_CORE7, rule!SCAC_executeAsignarIntegracion, rule!SCAC_gestionarTTQRESTIntegracion, rule!SCAC_marcarAsignacionBonificacionIntegracion
- `SCA/interfaces/SCA_ContraAnulacionOpcionesEstrategicas___a-0000ee64-4a6f-8000-9c9f-011c48011c48_17849055.sail`: rule!SCAC_catalogFilteredIntegracion
- `SCA/interfaces/SCA_ContraAnulacionOpciones___a-0000ebf6-689c-8000-9c69-011c48011c48_13272174.sail`: rule!SCAC_catalogFilteredIntegracion
- `SCA/interfaces/SCA_DetalleAnulacionContraAnulacion___a-0000eb64-971e-8000-9c0e-011c48011c48_1681704.sail`: rule!SCAC_descargaDocumentoIntegracion
- `SCA/interfaces/SCA_SolicitudAnulaci_n___a-0000eb64-971e-8000-9c0e-011c48011c48_1701045.sail`: rule!SCAC_catalogFilteredIntegracion
- `SCA/interfaces/SCA_TablaGestionArgumentos___a-0000eb64-971e-8000-9c0e-011c48011c48_1705769.sail`: rule!SCAC_descargaDocumentoIntegracion
- `SCA/processModels/SCA_Crear_Concepto__0002eca5-1517-8000-a7c8-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_SCA_Mecanizacion_es_SCA_Mecanizacion__0002ec01-57f1-8000-612e-7f0000014e7a.json`: cons!SCAC_TXT_CORE7_ENDPOINT, cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Acciones_Administrativas__0002ebf0-6f30-8000-5b42-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Alta_Contra_Anulacion__0003ee68-f88a-8000-0e66-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Alta_Mecanizaci_n__0002eebd-894d-8000-205c-7f0000014e7a.json`: cons!SCAC_TXT_CORE7_ENDPOINT, cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Autorizaci_n__0009ebf0-4fc9-8000-5b17-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Batch_Caducidad__0002eea4-5cfb-8000-1a24-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Batch_Mecanizacion_NSE_2__0012edc7-30fa-8000-82ff-7f0000014e7a.json`: cons!SCAC_TXT_CORE7_ENDPOINT, cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Batch_Mecanizacion_NSE__0002ecf2-fb2e-8000-6f80-7f0000014e7a.json`: cons!SCAC_TXT_CORE7_ENDPOINT, cons!SCAC_VAL_HOST_CORE7, rule!SCAC_actualizarMecanizacionIntegracion
- `SCA/processModels/en_US_es_SCA_Finalizar_Contra_Anulacion__0003ee68-fcf2-8000-0e6e-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Finalizar_Gesti_n_SGC_Estrat_gicas__000fee9a-19a4-8000-175c-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Finalizar_Gesti_n_SGC__0002ec01-93cd-8000-6168-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Finalizar_Mecanizaci_n__0002eebd-9493-8000-2062-7f0000014e7a.json`: cons!SCAC_TXT_CORE7_ENDPOINT, cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Finalizar_Solicitud__0002ec12-be50-8000-6a6a-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Generar_Solicitud__0002ee63-b680-8000-0def-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7
- `SCA/processModels/en_US_es_SCA_Procesamiento_Batch_Rsva_Prima_SGO__0013ed84-e83c-8000-e20b-7f0000014e7a.json`: cons!SCAC_VAL_HOST_CORE7

## SCAC objects referencing SCA_* (non-SCAC) objects

- `SCAC/integrations/SCAC_descargaDocumentoIntegracion__2fed1595-c5a0-4347-a15e-949edd45ff0c.json`: cons!SCA_WEBSERVICES_URL
- `SCAC/integrations/SCAC_simularAnulacionPolizaIntegracion___a-0000eb7f-c182-8000-9c48-011c48011c48_11605719.json`: rule!SCA_obtenerUserPassSimularPoliza