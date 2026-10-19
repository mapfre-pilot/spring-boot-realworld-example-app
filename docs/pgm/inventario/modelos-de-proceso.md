### PGM Abrir Mas Datos Clientes
Proceso que abre la pestaña de Más datos del cliente
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: camposBusquedaPosicionada, cliente
- nombres de nodos: Start Node, End Node

### PGM Abrir enlace SGC
Proceso que permite abrir SGC como una record action, da de alta el cliente si no tiene idContacto
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'XOR': 3, 'User Input Task': 2, 'Call Integration': 1, 'SUB_PROC': 1}
- PVs: camposBusquedaPosicionada, cliente, contactoCreado, contexto, errorServicioFirma, estructuraComercial, idContacto, successRGPD, url
- nombres de nodos: Start Node, End Node, Script Task, ¿Error?, RGPD completado?, Pantalla error, Dar de alta contacto, Pantalla URL, Firma RGPD, ¿Tiene idContacto y RGPD?

### PGM Abrir enlace externo
Proceso que permite abrir una url externa como una record action
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: aplicacion, url
- nombres de nodos: Start Node, End Node

### PGM AbrirAccionesPoliza
Proceso que contiene la pantalla modal para abrir las acciones de una poliza
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: idCliente, numeroPoliza
- nombres de nodos: Start Node, End Node

### PGM AbrirConsultaDocumentos
proceso de mapeo y Observación de  documentos
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: idCliente
- nombres de nodos: Start Node, End Node

### PGM AbrirCreatividades
Muestra la creación de actividades
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: creativityId, documento
- nombres de nodos: Start Node, End Node

### PGM AbrirSuperbonus
Apertura de superbonus
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'User Input Task': 1}
- PVs: idCliente, superbonus
- nombres de nodos: Start Node, End Node, Get Superbonus, Detalle superbonus

### PGM Acceso Ficha Ampliada Socio

- nodos: {'Start Node': 1, 'End Node': 1, 'Write to Data Store Entity': 1, 'User Input Task': 1}
- PVs: documentoCliente
- nombres de nodos: Start Node, End Node, escribir solicitud acceso, FAS

### PGM Actualizar Cliente
Proceso que actualiza la info del cliente temporal y agenda una transaction con el dato cambiado
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 1, 'Write to Data Store Entity': 1, 'Write Records and Related Records': 1, 'Unattended Multiple Questions': 1}
- PVs: campos, cliente, codAccion, guardarCliente, idCliente, modifiedData, motivoContacto, nuuma, transaction
- nombres de nodos: Start Node, End Node, XOR, Write to Data Store Entity, Write Records, Script Task

### PGM Actualizar Vencimiento Incompleto

- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1}
- PVs: ResultActualizarVencimientoIncompleto, cliente, opportunityId, perfilComercial, vencimiento
- nombres de nodos: Start Node, End Node, Act Vencimiento Incompleto

### PGM Anadir documentos PGO
Proceso de añadir documento en PGO
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'SUB_PROC': 1, 'XOR': 3, 'User Input Task': 3}
- PVs: actualizarDomino, anadirDocumentos, anadirOtroDoc, cancelar, cliente, documento, esAlta, llamadaVencimientos, nuuma, opportunityId, otroVencimiento, resultadoAnexo
- nombres de nodos: Start Node, End Node, Script Task, Subprocess - PGM Subida Documentos PGO, XOR, XOR, Script Task, XOR, Pantalla exito , Pantalla error, Añadir documento

### PGM AnadirObservacionesPGO
Proceso para añadir observaciones a PGO
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'User Input Task': 1}
- PVs: llamadaVencimientos, nuevaObservacion, nuuma, observacion, opportunityId
- nombres de nodos: Start Node, End Node, Script Task, editar Observacion PGO

### PGM Avisos
Proceso de navegación de la pestaña "Avisos"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM AñadirVencimientoPresupuesto
Añadir vencimiento de un presupuesto
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 3, 'XOR': 4, 'Call Integration': 1, 'SUB_PROC': 1, 'User Input Task': 2, 'ModifySecurity': 1}
- PVs: bodyResult, cliente, contactoCreado, contexto, error, errorServicioFirma, estructuraComercial, idContacto, listaContactos, result, successRGPD, tipoVencimiento, vencimientos
- nombres de nodos: Start Node, End Node, Comprobación idContacto, Estructura comercial?, Alta contacto, RGPD completado y id Conacto?, Firma RGPD, XOR, Obtener listado vencimientos, RGPD?, Error Alta, Alta vencimiento, Modify Process Security, Mapear lista contactos

### PGM AñadirVencimientoPresupuestoPGO
Proceso para dar de alta un vencimiento
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'XOR': 7, 'SUB_PROC': 2, 'User Input Task': 3, 'ModifySecurity': 1}
- PVs: actualizarDomino, bodyError, camposBusquedaPosicionada, cliente, contactoCreado, contexto, documento, envioDatosAlta, errorServicioFirma, esAlta, estructuraComercial, opportunityId, otroVencimiento, successRGPD, tipoVencimiento, vencimientos, vueltaExitosa
- nombres de nodos: Start Node, End Node, Obtener listado vencimientos, XOR, RGPD completado?, RGPD?, Perfil SGC 3.0, Firma RGPD, XOR, Script Task, XOR, Subprocess - PGM Anadir documentos PGO, Error en Alta, Datos de contacto?, Alta Vencimientos v2, alerta Anadir Vencimiento PGO, Modify Process Security

### PGM Borrado Record
Modelo de proceso que que hace un borrado al record, usando el TM
- nodos: {'End Node': 1, 'SUB_PROC': 1, 'Delete Records and Related Records': 1, 'Start Node': 1, 'Intermediate Consuming Event': 1}
- PVs: clientes, transaction
- nombres de nodos: End Node, Mark Transactions as complete, Delete Records, Start Node, Timer_1

### PGM CargaInfoClienteRendimiento
Carga de info de cliente por detras para mejorar rendimiento
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 2, 'Complex': 2, 'Unattended Multiple Questions': 9, 'SUB_PROC': 2, 'XOR': 2, 'User Input Task': 2}
- PVs: camposBusquedaPosicionada, cliente, clienteCompleto, contactos, delay, errores, estructuraComercial, idContacto, iteraciones, polizas, presupuestos, procesoCliente, respuestaVencimientosPresupuestos, usuarioAppian, vencimientos
- nombres de nodos: Start Node, End Node, AND, AND, Complex, Buscar cliente en procesos anteriores, Actualizar variable proceso, Recuperar recibos y prestaciones, Actualizar variable proceso, Mapear datos, ¿Datos cargados?, Esperar ~1 segundo, ¿Se ha consultado el cliente?, Mapear datos, Script Task, Error al cargar los datos?, Mapear vencimientos y presupuestos, Recuperar datos cliente, Consultar vencimientos y presupuestos, User Input Task, Mostrar ficha cliente

### PGM Cargando Datos

- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: completado
- nombres de nodos: Start Node, End Node, Cargando datos

### PGM Citrix
Proceso de navegación de la pestaña "Citrix"
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 4, 'Unattended Multiple Questions': 4, 'User Input Task': 3, 'DeleteDocument': 1, 'SUB_PROC': 1}
- PVs: cancel, credenciales, ficherosIcaGenerados, ficherosIcon, iconosCargados, indexIcono, recursos, recursosSinIcono
- nombres de nodos: Start Node, End Node, XOR, XOR, Script Task, Script Task, Script Task, User Input Task, User Input Task, Delete Document, Script Task, XOR, Sin icono?, Obtener Iconos, User Input Task

### PGM Cliente cacheado
Obtención de un cliente cacheado
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'XOR': 1, 'SUB_PROC': 1}
- PVs: camposBusquedaPosicionada, cliente, clienteCompleto, contactos, errores, estructuraComercial, idContacto, polizas, presupuestos, procesoCliente, respuestaVencimientosPresupuestos, usuarioAppian, vencimientos
- nombres de nodos: Start Event, End Event, Script Task, XOR, Subprocess, Script Task

### PGM ClienteTotal Documentos
Proceso para obtener documentos de un Cliente Total
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 2, 'XOR': 1, 'Call Integration': 1}
- PVs: ResultadoGenerarDoc, documento, idDocumento, nombreDoc
- nombres de nodos: Start Node, End Node, Error, XOR, obtener documento, Visualizar documento

### PGM Clientes
Proceso de navegación de la pestaña "Clientes"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM CompletarInfoCliente Paralelo
Completa la información de un cliente con la extracción de datos de varios servicios
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 3, 'Call Integration': 12, 'XOR': 1, 'OR': 1}
- PVs: categoriaCliente, documento, errorBeneficios, errorChecks, errorDatosCliente, errorDatosExternos, errorDirecciones, errorEncuestas, errorFamilias, errorIntegralidad, errorLogin, errorMetodosContacto, errorMetodosIdentificativos, errorProfile, idCliente, respuestaAPIchecks, respuestaAPIdatosCliente, respuestaAPIdatosExternos, respuestaAPIdescuentoIntegralidad, respuestaAPIdirecciones, respuestaAPIencuestas, respuestaAPIfamilias, respuestaAPImetodosIdentificativos, respuestaAPIprofile, respuestaMetodosContacto, resultAPIbenefits, token
- nombres de nodos: Start Node, End Node, AND, AND, Perfil Cliente, Beneficos Cliente, Encuestas Cliente, Checks Cliente, Metodos contacto, Metodos identificativos, Datos Cliente, families search, Datos externos, Empresa?, AND, Clients Login, OR, descuento integralidad, Direcciones Cliente

### PGM ConsultarDatosPrestacion
Proceso que rellena la plantilla y llama a la integración
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'DeleteDocument': 1, 'Call Integration': 1, 'Generate Text': 1}
- PVs: Result, created, expediente, nuuma, password, requestDocumentp, respuestaAPI, user
- nombres de nodos: Start Node, End Node, mapear request, Delete Document, Call Integration, mapear integraciones, XML request

### PGM ConsultarDatosSiniestro
Proceso que rellena la plantilla y llama a la integración
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Call Integration': 1, 'Generate Text': 1, 'Unattended Multiple Questions': 2}
- PVs: Result, created, expediente, nuuma, password, requestDocumentp, respuestaAPI, user
- nombres de nodos: Start Node, End Node, Delete Document, Call Integration, XML request, mapear request, mapear integraciones

### PGM ConsultarRecibosPorPoliza
Consulta los recibos asociados a una póliza
- nodos: {'Start Node': 1, 'Call Integration': 1, 'End Node': 1}
- PVs: idCliente, numPoliza, recibos, respuestaRecibos
- nombres de nodos: Start Node, Llamada recibos, End Node

### PGM CrearUsuariosViaCSV
Proceso de creación de usuarios vis csv
- nodos: {'Start Node': 1, 'End Node': 1, 'Create User With i18n': 1, 'Unattended Multiple Questions': 1, 'Add Members to Group': 1}
- PVs: users
- nombres de nodos: Start Node, End Node, Create User With i18n, Leer excel, Añdair a usuarios territorio

### PGM Descargar información cliente
Abre un proceso que permite descargar un Excel con las pólizas/recibos/prestaciones/presupuestos de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1, 'Write to Data Store Entity': 1}
- PVs: idCliente, nombreCliente, startDate, tipo
- nombres de nodos: Start Node, End Node, User Input Task, Write to Data Store Entity

### PGM Detalle Gestion SGC3.0
Proceso para obtener el detalle de una gestión
- nodos: {'Start Node': 1, 'Call Integration': 1, 'End Node': 1, 'ModifySecurity': 1}
- PVs: IdGestion, nuumaEncriptado, resultado
- nombres de nodos: Start Node, Call Integration - PGM_SGC30_DetalleGestion, End Node, Modify Process Security

### PGM Documentos SGO

- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1, 'Unattended Multiple Questions': 2, 'XOR': 1, 'User Input Task': 1}
- PVs: count, documentos, idDocumentos, idGestion, idSGO, nombreDocumentos, time
- nombres de nodos: Start Node, End Node, Call Integration, Script Task, XOR, Script Task, User Input Task

### PGM DocumentosGestionSGC3
Proceso para generar y descargar los documentos de una gestión del SGC 3.0
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'DeleteDocument': 1, 'XOR': 1, 'User Input Task': 1, 'Call Integration': 1}
- PVs: documentos, documentosGenerados, idGestion, nuumaEncriptado
- nombres de nodos: Start Node, End Node, Comprobar Documentos Generados, Borrado documentos, Documento generado?, Interfaz de descarga, Obtener documentos

### PGM Eliminar documento PGO
Eliminación de documentos en PGO
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: attachmentId, bodyResult, nuuma, opportunityId
- nombres de nodos: Start Node, End Node, Interfaz confirmacion

### PGM EliminarObservacionPGO
Eliminación de observaciones en PGO
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 1, 'Call Integration': 1, 'User Input Task': 1}
- PVs: Result, comentarioEliminado, observacionId, opportunityId
- nombres de nodos: Start Node, End Node, XOR, Eliminar Observacion, eliminar ObservacionvPGO

### PGM Ficha Cliente TEST
Proceso principal que consume los servicios necesarios para mostrar la ficha de un cliente.
- nodos: {'Start Node': 1, 'Add Members to Group': 1, 'Write to Data Store Entity': 2, 'User Input Task': 3, 'XOR': 3, 'End Node': 2, 'AND': 1, 'Unattended Multiple Questions': 1}
- PVs: alertas, alertasCdt, atras, avisoCliente, bankingPosition, camposBusquedaPosicionada, canal, cliente, clienteCompleto, completado, contactos, datosPDP, errores, estructuraComercial, fechaBusqueda, idContacto, interacciones, motivo, numeroPoliza, nuumaEncriptado, nuumaSGC, perfilSGC3, planDePagos, polizas, presupuestos, recargar, reclamaciones, responseDatosAgente, respuestaCrosseling, resultadosBusqueda, servicioFamilieSearch, servicioFamilyId, statusCodePdP, sumarioVencimientoCliente, susceptiblePDP, tiempoInfoCliente, usuarioAppian
- nombres de nodos: Start Node, Add Group Members, save registro CdM, Resultados busqueda, Cláusula mediadores, Mediador?, usuarioSGC?, nResultados?, End Node, AND, End Event, Agendar consulta al TM, Completar info cliente, Mostrar ficha cliente

### PGM Ficha Cliente WebAPI
Proceso que completa la información de un cliente y muestra su ficha cuando se accede desde la webAPI.
- nodos: {'Start Node': 1, 'End Node': 2, 'Add Members to Group': 1, 'XOR': 3, 'Write to Data Store Entity': 2, 'User Input Task': 2, 'Unattended Multiple Questions': 2, 'AND': 1}
- PVs: alertas, alertasCdt, bankingPosition, camposBusquedaPosicionada, cliente, clienteCompleto, completado, contactos, datosPDP, errores, estructuraComercial, idContacto, interacciones, numeroPoliza, nuumaEncriptado, nuumaSGC, perfilSGC3, planDePagos, polizas, presupuestos, recargar, reclamaciones, responseDatosAgente, respuestaCrosseling, resultadosBusqueda, servicioFamilieSearch, servicioFamilyId, statusCodePdP, sumarioVencimientoCliente, susceptiblePDP, tiempoInfoCliente, usuarioAppian, vencimientos
- nombres de nodos: Start Node, End Node, Add Group Members, usuarioSGC?, save registro CdM, Cláusula mediadores, puente, AND, End Event, recargar?, Mediador?, Agendar consulta al TM, Completar info cliente, Mostrar ficha cliente

### PGM Ficha Poliza
Proceso para abrir la Ficha de una Póliza en búsqueda por póliza
- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 2, 'Unattended Multiple Questions': 2, 'XOR': 3, 'SUB_PROC': 2, 'AND': 2, 'User Input Task': 2}
- PVs: cliente, errores, numeroPoliza, poliza, prestaciones, ramoPoliza, recibos, respuestaSOAP, resultadoAPIBusqueda, resultadoAPIPolizas, selectedTab
- nombres de nodos: Start Node, End Node, Detalle de poliza, Busqueda por poliza, Mapear integracion de busqueda, XOR, XOR, Subprocess - PGM_ConsultaPolizaHogar, Mapear y seleccionar, AND, AND, Recibos y prestaciones asin, Cliente encontrado?, Ficha Poliza, Sin resultados

### PGM GestionSCA
Proceso que gestiona cuando se quiere hacer una anulación
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: numeroPoliza
- nombres de nodos: Start Node, End Node

### PGM Gestión comercial
Proceso de navegación de la pestaña "Gestión comercial"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM Gestión de cartera
Proceso de navegación de la pestaña "Gestión de cartera"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM Guardar Más Datos Cliente
Proceso para guardar y actualizar los datos introducidos en la pestaña Más Datos Cliente
- nodos: {'End Node': 1, 'XOR': 8, 'Call Integration': 2, 'Unattended Multiple Questions': 4, 'User Input Task': 3, 'AND': 1, 'Write to Data Store Entity': 1, 'Write Records and Related Records': 1, 'Start Node': 1, 'SUB_PROC': 2, 'ModifySecurity': 1}
- PVs: ResultContractual, ResultNoContractual, SuccessContractual, SuccessEmail, SuccessFijo, SuccessMovil, SuccessNacionalidad, SuccessNoContractual, cliente, clienteRecord, comunicacionContractual, comunicacionNoContractual, edits, intentoBorrado, medioContractual, medioNoContractual, motivoCP, nuevaClave, nuevaNacionalidad, nuevoFijo, nuevoMail, nuevoMovil, validacionContractual, validacionFijo, validacionMail, validacionMovil, validacionNoContractual
- nombres de nodos: End Node, validacion, Actualizar contractual, Actualizar no contractual, Success?, Comunicación Contractual editada?, Comunicación No contractual editada?, XOR, Mapear medios contacto, Error Canal Comuniación, intento de borrado, Edits?, Hay modificaciones?, AND, Error Validación, Agendar registro de consulta al transaction manager, Validación?, Write Records, Datos guardados correctamente, Start Node, Hay errores?, actualizar record, validar modificaciones, Subprocess, Modify Process Security

### PGM Guardar Más Datos Cliente Modificacion
Proceso para guardar y actualizar los datos introducidos en la pestaña Más Datos Cliente, modificado para reducir nodos
- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 5, 'XOR': 12, 'SUB_PROC': 1, 'User Input Task': 4, 'Unattended Multiple Questions': 6}
- PVs: ResultContractual, ResultNoContractual, SuccessContractual, SuccessEmail, SuccessFijo, SuccessMovil, SuccessNacionalidad, SuccessNoContractual, camposBusquedaPosicionada, cliente, comunicacionContractual, comunicacionNoContractual, edits, intentoBorrado, medioContractual, medioNoContractual, motivoCP, nuevaClave, nuevaNacionalidad, nuevoFijo, nuevoMail, nuevoMovil, validacionContractual, validacionFijo, validacionMail, validacionMovil, validacionNoContractual
- nombres de nodos: Start Node, End Node, Actualizar fijo, Actualizar movil, Actualizar email, Fijo editado?, email editado?, validacion, Actualizar contractual, Actualizar no contractual, Móvil válido?, Fijo valido?, email valido?, Success?, Subprocess, Comunicación Contractual editada?, Comunicación No contractual editada?, XOR, Error datos, Error Validación, Mapear medios contacto, Edits?, Error Canal Comuniación, Validación móvil, Validación Fijo, validación email, intento de borrado, Datos guardados correctamente, Movil editado?, Validación?

### PGM GuardarMotivosYCanales

- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1}
- PVs: canal, clientId, documento, idMotivo, nuuma, tipoDocumento
- nombres de nodos: Start Node, End Node, Call Integration - PGM_ClientsEDGE_ContactoBDC

### PGM GuardarMotivosYCanalesAppian

- nodos: {'Start Node': 1, 'End Node': 1, 'Write Records': 1}
- PVs: canal, motivo
- nombres de nodos: Start Node, End Node, Write Records

### PGM Imprimir Duplicado
Proceso que imprime los recibos duplicados
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: 
- nombres de nodos: Start Node, End Node, Imprimir duplicado

### PGM Inducir Cliente Santander
Inducir cliente santander
- nodos: {'Start Node': 1, 'End Node': 1, 'SUB_PROC': 1, 'User Input Task': 1}
- PVs: camposBusquedaPosicionada, cliente, requestId, santanderAlta, solicitudEnCurso, usuarioAppian
- nombres de nodos: Start Node, End Node, Consultar Santander, Inducir cliente

### PGM Informacion Tomador Recibo

- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'User Input Task': 1}
- PVs: detallePoliza
- nombres de nodos: Start Node, End Node, Mapear Datos, Popup datosTomador

### PGM Inicio
Navegación a la pestaña de inicio sinregistro de usuarios
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM LlamarAlCliente
Proceso de llamada al cliente
- nodos: {'Start Node': 1, 'Call Integration': 1, 'User Input Task': 1, 'End Node': 1}
- PVs: idCliente, nuuma, success, telefono
- nombres de nodos: Start Node, Click To Call, Llamando al Cliente, End Node

### PGM Mostrar Comunicaciones
Proceso que muestra la interfaz PGM_CentroDeComunicaciones
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cliente, fechaInteracciones, fechaReclamaciones
- nombres de nodos: Start Node, End Node

### PGM MotivoConsultaYSCA
Proceso que llama a la integración de motivos de consulta y si existe SCA lo haria
- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1, 'XOR': 2}
- PVs: canal, cliente, motivo, motivoSCA
- nombres de nodos: Start Node, End Node, Call Integration - PGM_ClientsEDGE_ContactoBDC, comprueba SCA, solo pre y dev

### PGM Nueva Producción
Proceso de navegación de la pestaña "Nueva producción"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM Obtener Actividad Comercial
Proceso para recuperar la actividad comercial de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1}
- PVs: diarioActividad, idContacto, nuuma, origen
- nombres de nodos: Start Node, End Node, Obtener actividad comercial

### PGM ObtenerArgumentarioSCA

- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1}
- PVs: argumentario, causaSCA, cia, claveAgente, nuuma, poliza, ramo
- nombres de nodos: Start Node, End Node, Obtener Argumentario

### PGM ObtenerIconosRecursoCitrix

- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1, 'Write to Data Store Entity': 1}
- PVs: credenciales, indexIcono, recursos, recursosSinIcono, resultado
- nombres de nodos: Start Node, End Node, Obtener documento, Write to Data Store Entity

### PGM ObtenerIntegraciones
Proceso que recupera las integraciones y lanzaderas guiadas para una póliza
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'Generate Text': 1, 'Call Integration': 1}
- PVs: cia, created, integraciones, password, ramo, requestCatalogo, respuestaAPI, user
- nombres de nodos: Start Node, End Node, Delete Document, mapear request, XML request, Call Integration, mapear integraciones

### PGM Prestaciones y siniestros
Proceso de navegación de la pestaña "Prestaciones y siniestros"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM Página no disponible
Proceso de navegación para las pestañas no disponibles actualmente
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: selectedTab
- nombres de nodos: Start Node, End Node

### PGM Recargar Ficha Cliente
Proceso que muestra la ficha de un cliente y carga los datos de nuevo sí o sí
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 1, 'Complex': 1, 'XOR': 3, 'Unattended Multiple Questions': 5, 'SUB_PROC': 1, 'User Input Task': 3}
- PVs: camposBusquedaPosicionada, cliente, clienteCompleto, contactos, count, delay, errores, estructuraComercial, idContacto, polizas, presupuestos, procesoCliente, respuestaVencimientosPresupuestos, soloRecargar, usuarioAppian, vencimientos
- nombres de nodos: Start Node, End Node, AND, Complex, ¿Sólo recargar?, Actualizar variable proceso, Recuperar datos cliente, ¿Sólo recargar?, Delay ~1s, Mapear vencimientos y presupuestos, Consultar vencimientos y presupuestos, Mapear datos, cliente cargado?, Mostrar ficha cliente, Error, Reintento

### PGM Recibos
Proceso de navegación de la pestaña "Recibos"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM Recuperar borrador Salud
Recupera los datos de una tarificación que ha sido guardada como borrador y continúa el proceso
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'SUB_PROC': 1}
- PVs: cancel, guardarBorrador, registro, tarificacion
- nombres de nodos: Start Node, End Node, Script Task, Subprocess

### PGM Recuperar duplicado recibo
Proceso para obtener un documento PDF de duplicado de recibo
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 3, 'Call Integration': 2, 'User Input Task': 2, 'DeleteDocument': 1, 'Unattended Multiple Questions': 1}
- PVs: ResultLoopBack, ResultadoGenerarDoc, documento, documentoGenerado, documentoXML, numRecibo, nuuma, success
- nombres de nodos: Start Node, End Node, XOR, Obtener duplicado, Copy of XOR, XOR, Visualizar duplicado, Pantalla error, Borrado documento, getPDF, CMP_LoopBack_ base64ADoc

### PGM SelecionarTarficiacionConjuntaSalud
Seleccion de tarificación conjunta de salud
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cancelarTarificacion, guardarBorradorTarificacion
- nombres de nodos: Start Node, End Node

### PGM Subida Documentos PGO
Proceso para subir documentos en el API de PGO
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'Call Integration': 2, 'XOR': 1, 'DeleteDocument': 1}
- PVs: docB64, documento, errorServicios, exito, nombreDoc, nuuma, opportunityId, respuestaAnexo, respuestaB64, statusCode
- nombres de nodos: Start Node, End Node, Actualizar estado, Adjuntar doc en PGO, Convertir Doc a B64, Script Task, XOR, Delete Document

### PGM Tarificación rápida Salud
Proceso que permite registrar una tarificación de productos de salud
- nodos: {'End Node': 1, 'Start Node': 1, 'Write to Data Store Entity': 4, 'OR': 2, 'XOR': 1, 'SUB_PROC': 1, 'User Input Task': 1}
- PVs: cancel, guardarBorrador, pasoTarificacion, producto, registro, tarificacion
- nombres de nodos: End Node, Start Node, Write to Data Store Entity, Write to Data Store Entity, Write to Data Store Entity, OR, Write to Data Store Entity, XOR, Subprocess, OR, User Input Task

### PGM Utilidades
Proceso de navegación de la pestaña "Gestión de operaciones"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM consultarDatosAgente
Proceso para realizar la llamada SOAP para consultar los datos de un agente
- nodos: {'Start Node': 1, 'End Node': 1, 'Generate Text': 4, 'DeleteDocument': 4, 'Unattended Multiple Questions': 2, 'AND': 2, 'Call Integration': 4, 'XOR': 1, 'SUB_PROC': 1}
- PVs: apellidoAgente1, apellidoAgente2, bodyObtenerAgente, bodyconsultaPropiedadClave, bodyobtenerEstComClave, bodyobtenerEstructuraComercial, cia, claveAgente, codInt, created, datosAgente, documento, email, esSantander, fijo, movil, nombreAgente, nonce, nuuma, password, requestId, requestXML, requestXML2, santanderAlta, solicitudEnCurso, user
- nombres de nodos: Start Node, End Node, Crear XML obtenerEstComClave, Borrar XML, Borrar XML, mapear datos request, AND, AND, Crear XML consultaPropiedadClave, Borrar XML, obtenerEstructuraComercial, Crear XML obtenerEstructura, borrar XML, Crear XML obtenerAgente,  obtenerAgente, esSantander?, Search_Santander, Script Task, consultaPropiedadClave, obtenerEstComClave

### PGM crearClienteACI
Proceso para dar de alta a un cliente en ACI
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 3, 'Unattended Multiple Questions': 1, 'Call Integration': 1, 'User Input Task': 4}
- PVs: Result, apellido1, apellido2, cancelar, codigoPostal, documento, email, fechaNacimiento, localidad, nombre, nombreVia, requestService, statusCode, success, telefono, tipoDocumento, tipoVia
- nombres de nodos: Start Node, End Node, Cancelar?, Script Task, crearCliente ACI, Success?, Email y/o movil vacios?, Error email y/o telefono, Iniciar proceso?, Error, Alta en ACI completada

### PGM crearRegistroConsultaModificacion
Proceso destinado al registro de consulta/modificaciones de los datos del cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'SUB_PROC': 1, 'Unattended Multiple Questions': 1, 'Call Integration': 1}
- PVs: cod_accion, contextJSON, data, errorInt, fechaAudit, nuuma, result, resultadoInt, solicitud, transaction
- nombres de nodos: Start Node, End Node, Mark Transactions as complete, Mapeo de entrada y creación del cuerpo solicitud, RegistrarConsultaModificacion

### PGM obtenerLanzaderaIntegracion

- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'AND': 2, 'Call Integration': 2, 'DeleteDocument': 2, 'Generate Text': 2}
- PVs: codURL, created, idAplicaion, parametros, password, requestParams, requestURL, respuestaAPIparams, respuestaAPIurl, url, user
- nombres de nodos: Start Node, End Node, Script Task, AND, AND, Call Integration, Delete Document, Call Integration, Delete Document, XML request params, XML request URL, Script Task

### PGM recuperar documentos PGO
Proceso para obtener documentos de PGO
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 3, 'Call Integration': 2, 'Unattended Multiple Questions': 1, 'User Input Task': 2, 'DeleteDocument': 1}
- PVs: ResultLoopBack, ResultadoGenerarDoc, docB64, documento, idDocumento, nombreDoc, nuuma, opportunityId
- nombres de nodos: Start Node, End Node, XOR, obtener documento, Script Task, Visualizar documento, XOR, Copy of XOR, Error, Borrado documento, CMP_LoopBack_ base64ADoc

### PGM testHTMLtoPDF

- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 2, 'HTML to PDF [Deprecated]': 1, 'Generate HTML': 1, 'User Input Task': 1}
- PVs: CreatividadHTML, CreatividadPDF
- nombres de nodos: Start Node, End Node, Delete Document, Delete Document, HTML to PDF, HTML Doc from Template, User Input Task

### PGM validarModificacionDatosCliente
Subproceso que se encarga de validar que datos se han modificado y llamar a la integración correspondiente para su modificación
- nodos: {'Start Node': 1, 'Unattended Multiple Questions': 3, 'End Node': 1, 'XOR': 2, 'Call Integration': 3}
- PVs: SuccessEmail, SuccessFijo, SuccessMovil, contador, error, idCliente, n_vuelta, nuevoFijo, nuevoMail, nuevoMovil, response, validacionFijo, validacionMail, validacionMovil
- nombres de nodos: Start Node, puente modificaciones, End Event, Hay que modificar?, validacion de campos, Actualizar movil, Actualizar fijo, Actualizar email, puente vueltas, Quedan vueltas?

### PGM_Abrir_Ficha_Por_DNI
Proceso que abre la ficha de cliente al hacer click en DNI
- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1, 'SUB_PROC': 1}
- PVs: Documento, ResultadosBusqueda
- nombres de nodos: Start Node, End Node, Búsqueda clientes, Ficha cliente

### PGM_ActualizaNacionalidad
Proceso que modifica la nacionalidad del cliente al nuevo valor
- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 1}
- PVs: Result, Success, client, newNationality
- nombres de nodos: Start Node, End Node, Call Integration

### PGM_AgruparRecibos
Proceso que agrupa recibos anteriormente comprobados que son agrupables
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'Call Integration': 1, 'Generate Text': 1}
- PVs: numRecibo, rawResult, rawResultDatos, requestService, requestXMLDatos
- nombres de nodos: Start Node, End Node, Delete Document, Script Task, Script Task, Call Integration, Text Doc from Template

### PGM_AltaContratoIniciado_Santander
Proceso para Alta Contrato iniciado de Santander
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node

### PGM_AltaContrato_Santander
Proceso para Alta Contrato de Santander
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node

### PGM_AplicarGestionEnvioAlBanco
Aplica la gestión de enviar al banco al recibo seleccionado
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'Generate Text': 1, 'Call Integration': 1}
- PVs: numRecibo, rawResult, rawResultDatos, requestService, requestXMLDatos
- nombres de nodos: Start Node, End Node, Delete Document, Script Task, Text Doc from Template, Call Integration, Script Task

### PGM_BajaContratoIniciado_Santander
Proceso para Baja Contrato Iniciado de Santander
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node

### PGM_BajaContrato_Santander
Proceso para Baja Contrato  de Santander
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node

### PGM_Cancelar_InducirCliente
Proceso para cancelar el formulario de inducir cliente y te lleve a la ficha
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: camposBusquedaPosicionada, cliente
- nombres de nodos: Start Node, End Node

### PGM_Cancelar_InducirCliente_Savia
Proceso para cancelar el formulario de inducir cliente  Savia y te lleve a la ficha
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node

### PGM_ClienteTotal
Navegación con datos para cliente total
- nodos: {'End Node': 1, 'Start Node': 1, 'User Input Task': 5, 'XOR': 3, 'SUB_PROC': 1, 'Unattended Multiple Questions': 1, 'Call Integration': 1}
- PVs: accion, cargos, cliente, datosEmpresas, envioDatos, errorIntegracion, fiabilidad
- nombres de nodos: End Node, Start Event, PGM_Pantalla_ExitoError_ClienteTotal, XOR, PGM ClienteTotal Documentos, XOR, Script Task, XOR, PGM_Incluir_Empresa_Vinculada , PGM_ClienteTotal_Juridico, PGM_Pantalla_ErrorServicio_ClienteTotal, PGM_GET_ClienteTotal_Cargos, PGM_ClienteTotal_Fisico

### PGM_CompletarInfoCliente
Proceso que obtiene la información al completo de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 2, 'XOR': 8, 'Unattended Multiple Questions': 9, 'Call Integration': 8}
- PVs: cliente, clienteCompleto, delayVariable, resultadoAPIBenefits, resultadoAPIChecks, resultadoAPIDatosCliente, resultadoAPIDescuentoIntegralidad, resultadoAPIMetodosContacto, resultadoAPIMetodosIdentificativos, resultadoAPIProfile, resultadoAPISurveys
- nombres de nodos: Start Node, End Node, AND, AND, XOR, XOR, XOR, XOR, XOR, XOR, Script Task, Script Task, Script Task, Script Task, Script Task, Script Task, Call Integration, Call Integration, Call Integration, Call Integration, Call Integration, Call Integration, XOR, XOR, Script Task, Script Task, Call Integration, Call Integration, Script Task

### PGM_ConsultaDetSolicitudSGO
Consulta el detalle de una solicitud SGO de un usuario
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'XOR': 1, 'Generate Text': 1, 'Call Integration': 1}
- PVs: Result, detSolicitud, idSGO, rawResult, requestService, requestXML, success
- nombres de nodos: Start Node, End Node, Delete Document, Script Task, Script Task, XOR, Text Doc from Template, Call Integration

### PGM_ConsultaPolizaHogar
Recupera la información sobre una póliza del ramo Hogar
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'Call Integration': 1, 'Generate Text': 1, 'DeleteDocument': 1}
- PVs: poliza, rawResult, requestService, requestXML
- nombres de nodos: Start Node, End Node, Script Task, Call Integration, Text Doc from Template, Delete Document

### PGM_ConsultaSolicitudesActivasSGO
Consulta el listado de solicitudes SGO de un usuario
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Generate Text': 1, 'Unattended Multiple Questions': 2, 'Call Integration': 1, 'XOR': 1}
- PVs: filtros, rawResult, requestService, requestXML, solicitudes, success
- nombres de nodos: Start Node, End Node, Delete Document, Text Doc from Template, Script Task, Call Integration, Script Task, XOR

### PGM_ConsultarAgrupables
Consulta con que recibos se puede agrupar el recibo en cuestión
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'Generate Text': 1, 'Call Integration': 1}
- PVs: numRecibo, rawResult, rawResultDatos, requestService, requestXMLDatos
- nombres de nodos: Start Node, End Node, Delete Document, Script Task, Script Task, Text Doc from Template, Call Integration

### PGM_ConsultarDatosRecibo
Recupera la información sobre un recibo
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1}
- PVs: numRecibo, rawResult
- nombres de nodos: Start Node, End Node, Consultar datos recibo completo

### PGM_ConsultarGestiones
Recupera la información sobre un recibo
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 2, 'AND': 2, 'Generate Text': 2, 'Unattended Multiple Questions': 3, 'Call Integration': 2}
- PVs: ResultAbiertas, ResultCerradas, delay, documento, gestiones, nuuma, rawResultAbiertas, rawResultCerradas, requestService, requestXMLabiertas, requestXMLcerradas
- nombres de nodos: Start Node, End Node, Delete Document, AND, AND, Text Doc from Template, Delete Document, Script Task, Call Integration, Call Integration, Script Task, Text Doc from Template, Script Task

### PGM_ConsultarPresupuestos
Consulta de presupuestos.
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 3, 'Unattended Multiple Questions': 3, 'Call Integration': 2}
- PVs: cliente, delay, errores, nPresupuesto, presupuestos, resultadoAPIPresupuestos
- nombres de nodos: Start Node, End Node, XOR, XOR, XOR, Script Task, Mapear presupuestos, Script Task, API Presupuestos por Id, API Presupuestos por nº ppto

### PGM_ConsultarProductorVida
Consulta de productos de vida
- nodos: {'Start Node': 1, 'DeleteDocument': 1, 'Call Integration': 1, 'End Node': 1, 'Generate Text': 1, 'Unattended Multiple Questions': 2}
- PVs: detallePoliza, numeroPoliza, rawResult, requestService, requestXML
- nombres de nodos: Start Node, Delete Document, Call Integration, End Node, Text Doc from Template, Script Task, Script Task

### PGM_DPVE_Inicio

- nodos: {'End Node': 1, 'Start Node': 1, 'XOR': 4, 'Call Integration': 1, 'Unattended Multiple Questions': 6, 'User Input Task': 3}
- PVs: CIF, ClienteConflictivo, Duplicado, IdCliente, Ramos, RazonSocial, camposBusquedaPosicionada, cliente, integralidad, listaProductos, tipologia, valorTipologia
- nombres de nodos: End Node, Start Node, Cliente conflictivo?, Check Conflictivo, Obtener tipología, Obtener razon social, Existe cliente?, Ramos y productos contratados, Obtener producto, Error Cliente duplicado?, Cliente duplicado?, Cliente duplicado, Obtener ID Cliente, Formulario DPVE, Mensaje error, Mensaje error

### PGM_Eliminar_BorradorTarificacion
A partir del registro de un borrador de tarificaciones, elimina ese registro y todos los datos asociados a él
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2, 'Delete from Data Store Entities': 3, 'OR': 2}
- PVs: index, intervinientes, registros, tarificacion
- nombres de nodos: Start Node, End Node, Script Task, Delete from Data Store Entities, Delete from Data Store Entities, OR, Delete from Data Store Entities, Script Task, OR

### PGM_EnviarCentroRecibos
Proceso de envio centro de recibos
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: 
- nombres de nodos: Start Node, End Node, User Input Task

### PGM_GestionarSCA
Modelo de proceso para llamar a la integración de SCA
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'Generate Text': 1, 'Call Integration': 1}
- PVs: numRecibo, rawResult, rawResultDatos, requestService, requestXMLDatos
- nombres de nodos: Start Node, End Node, Delete Document, Script Task, Script Task, Text Doc from Template, Call Integration

### PGM_ImprimirDuplicado
Proceso para llamar al servicio de imprimir duplicado de un recibo
- nodos: {'Start Node': 1, 'End Node': 1, 'DeleteDocument': 1, 'Unattended Multiple Questions': 2, 'Generate Text': 1, 'Call Integration': 1}
- PVs: numRecibo, rawResult, rawResultDatos, requestService, requestXMLDatos
- nombres de nodos: Start Node, End Node, Delete Document, Script Task, Text Doc from Template, Call Integration, Script Task

### PGM_InducirCliente
Proceso para la sección de inducir cliente
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: camposBusquedaPosicionada, cliente
- nombres de nodos: Start Node, End Node

### PGM_InducirClienteRGPD
sección inducir cliente con cláusula RGPD firmada
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: camposBusquedaPosicionada, cliente
- nombres de nodos: Start Node, End Node

### PGM_InducirCliente_Robinson
InducirCliente Robinson (Prueba)
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: 
- nombres de nodos: Start Node, End Node, Mensaje cliente robinson

### PGM_InducirCliente_SinRGPD
Inducir cliente sin RGPD firmada
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 2, 'User Input Task': 1, 'SUB_PROC': 1}
- PVs: camposBusquedaPosicionada, cliente, contexto, errorServicioFirma, nuuma, successFirmaRGPD, usuarioAppian
- nombres de nodos: Start Node, End Node, ¿Error firma? o cancelar, RGPD?, Inducir cliente, Firma RGPD

### PGM_LanzaderaCitrix_v2
Proceso que incluye interfaces para el login y la descarga de un fichero .ica
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 5, 'AND': 3, 'Unattended Multiple Questions': 8, 'DeleteDocument': 1, 'Call Integration': 2, 'Write to Data Store Entity': 1, 'User Input Task': 4}
- PVs: credenciales, ficherosIca, ficherosIcon, icasCargados, iconosCargados, indexIca, indexIcono, recursos, recursosSinIcono
- nombres de nodos: Start Node, End Node, XOR, AND, AND, Script Task, XOR, AND, Script Task, Script Task, Delete Document, Script Task, Script Task, XOR, Call Integration, Script Task, XOR, XOR, Script Task, Script Task, Write to Data Store Entity, Call Integration, User Input Task, User Input Task, User Input Task, User Input Task

### PGM_Llamada_Gestionar_SAVIA
Llamadas a los servicios para finalizar inducción a Savia
- nodos: {'Start Node': 1, 'End Node': 1, 'Call Integration': 2, 'XOR': 1, 'Unattended Multiple Questions': 1}
- PVs: BodyInteraction, BodySavia, ErrorInteraction, ErrorSavia, GestionarLeadSavia, inducir, interaction, statusCode, statusCodeApi, succesAPI
- nombres de nodos: Start Node, End Node, Gestionar Lead Savia, Error?, inducir?, Interaction

### PGM_Llamada_Gestionar_Santander 
Llamada a los servicios para inducir a Santander
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 5, 'Call Integration': 6, 'Unattended Multiple Questions': 7, 'DeleteDocument': 4, 'Generate Text': 2}
- PVs: Bodyrequest, ExstreamDocumentation, ExstreamDocumentationBaja, StatusCodeDocumento, StatusCodeRequest, bodyDocumentoG, canalFirma, cliente, esAlta, inducir, interaction, requestSignature, statusCodeInteraction
- nombres de nodos: Start Node, End Node, error?, error?, esAlta?, ApiClient.interaction, ApiClient-interaction, statusCode, statusCode, statusCode, statusCode, Delete Document, Delete Document Plantilla Alta, statusCode, Script Task,  error?, error?,  Delete Document, statusCode,  Delete Document Plantilla Baja, GenerarDocumento, GenerarDocumento, SignatureRequest, SignatureRequest, Plantilla Alta, Plantilla Baja

### PGM_Llamada_Gestionar_Verti
Llamadas a los servicios para finalizar inducción a Verti
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 2, 'Call Integration': 3, 'XOR': 1, 'Unattended Multiple Questions': 2}
- PVs: BodyNeurona, BodyVerti, ErrorNeurona, ErrorVerti, Poliza41, StatusCodeNeurona, agente, bodyInteraction, cliente, errorInteraction, inducir, interaction, nse, numeroPoliza, producto, statusCode, statusCodeApi
- nombres de nodos: Start Node, End Node, AND, AND, NSE, ClientsApi_Interaction, esNSE?, Inducir Neurona, Script Task, inducir?

### PGM_MapearIconosCitrix

- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1}
- PVs: ficherosIcon, recursos
- nombres de nodos: Start Node, End Node, Mapeo

### PGM_MostrarObservacionInteraccion
Mostrar observación con interacción
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: interaccion
- nombres de nodos: Start Node, End Node

### PGM_Nav_Inicio
Proceso de navegación de la pestaña "Inicio"
- nodos: {'Start Node': 1, 'End Node': 1}
- PVs: 
- nombres de nodos: Start Node, End Node

### PGM_NuevoIdContactoWA
Proceso que muestra la modal para crear el alta de un idContacto en caso de que el usuario no tenga mediante un recordAction
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 1, 'Call Integration': 1, 'User Input Task': 2}
- PVs: Error, Result, cliente, datosTelefono, idContacto, vida
- nombres de nodos: Start Node, End Node, XOR, AltaIdContacto, Error en el alta, Contacto creado

### PGM_PUEBA
Llamada a los servicios para inducir a Santander
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'Call Integration': 1}
- PVs: BodyDocumento, BodySearch, Bodyrequest, ExstreamDocumentation, StatusCodeDocumento, StatusCodeRequest, cliente, esAlta, identityDocumentNumber, inducir, interaction, requestId, requestSignature, statusCodeCancellation, statusCodeInteraction, statusCodeSearch
- nombres de nodos: Start Node, End Node, statusCode, Signature_search

### PGM_ProcesoCitrix
Proceso que incluye interfaces para el login y la descarga de un fichero .ica
- nodos: {'Start Node': 1, 'XOR': 3, 'Unattended Multiple Questions': 5, 'End Node': 1, 'AND': 1, 'DeleteDocument': 2, 'Call Integration': 2, 'User Input Task': 3}
- PVs: credenciales, documentoIca, documentoIcono, indexRecursos, pathIcon, recursos
- nombres de nodos: Start Node, XOR, Script Task, End Node, AND, Script Task, XOR, Delete Document, Delete Document, Script Task, XOR, Call Integration, Call Integration, Script Task, Script Task, User Input Task, User Input Task, User Input Task

### PGM_Proceso_Mensaje_ErrorSolicitud
Proceso para mostrar el mensaje de error de envío en inducir cliente (Santanter)
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node, Solicitud enviada

### PGM_Proceso_Mensaje_SolicitudEnvio
Proceso para mostrar el mensaje solicitud de envío en inducir cliente (Santanter)
- nodos: {'Start Node': 1, 'End Node': 1, 'User Input Task': 1}
- PVs: cliente
- nombres de nodos: Start Node, End Node, Solicitud enviada

### PGM_Prueba_ConsultaVerti
Proceso de boceto para Fase II del componente de Verti
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 4, 'XOR': 1}
- PVs: 
- nombres de nodos: Start Node, End Node, Indentificación a inducir, Autemis, NSE Presupuestos, NSE anulación, XOR

### PGM_Prueba_VERTI
Proceso de boceto para Fase II del componente de Verti
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 11, 'XOR': 6, 'SUB_PROC': 1}
- PVs: 
- nombres de nodos: Start Node, End Node, Recuperar datos Cliente / Mapeo de campos Web API, Mensaje, Mensaje, UNION, Consultar datos agente, Mensaje, Componente RGPD, Preguntar Verti + Selector Vencimiento / VERTI, Mensaje, UNION, Error? , Cliente Robinson?, Error?, ¿Cláusula 360 firmada?, Consulta Verti, Mensaje, ¿Cláusula 360 firmada?, ¿Ha confirmado previamente algún agente?

### PGM_R_agendarBorrado
Proceso que agenda el borrado del record de cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'Write to Data Store Entity': 1, 'Unattended Multiple Questions': 1}
- PVs: transaction
- nombres de nodos: Start Node, End Node, Write to Data Store Entity, write transaction

### PGM_R_borradoRecord
Proceso que borra los record del cliente fuera de horario por TM
- nodos: {'Start Node': 1, 'End Node': 1, 'Write to Data Store Entity': 1, 'Unattended Multiple Questions': 2, 'Delete Records and Related Records': 1, 'XOR': 1, 'Start Process': 1}
- PVs: clientes, transaction
- nombres de nodos: Start Node, End Node, Write to Data Store Entity, write transaction, get clientes, Delete Records, XOR, Start Process - TM Mark Transactions as Complete

### PGM_R_borradoRecordCliente
Proceso temporal para borrar los records
- nodos: {'Start Node': 1, 'End Node': 1, 'Delete Records and Related Records': 1}
- PVs: 
- nombres de nodos: Start Node, End Node, Delete Records

### PGM_R_registrarConsultaCliente
Modelo de proceso creado para agendar el registro de la consulta de un cliente en el registro de operaciones
- nodos: {'Start Node': 1, 'End Node': 1, 'Write to Data Store Entity': 1}
- PVs: idCliente, nuuma
- nombres de nodos: Start Node, End Node, Write to Data Store Entity

### PGM_RecibosYPrestaciones
Llama y mapea a os recibos y las prestaciones de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1}
- PVs: cliente, idCliente, prestaciones, recibos, recibosyprestaciones
- nombres de nodos: Start Node, End Node, Recibos y prestaciones

### PGM_RecuperarCliente
Subproceso que permite recuperar de forma asíncrona los datos de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 2, 'Unattended Multiple Questions': 1, 'XOR': 1, 'SUB_PROC': 2}
- PVs: cliente, countProcesosCliente
- nombres de nodos: Start Node, End Node, AND, AND, Script Task, XOR, Subprocess, Subprocess

### PGM_RecuperarDatosCliente
Subproceso que permite recuperar de forma asíncrona los datos de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1}
- PVs: alertas, cliente, clienteCompleto, errores, infoBancaria, planDePagos, polizas, respuestaCrosseling, resultadoInfoCliente
- nombres de nodos: Start Node, End Node, Completar info cliente

### PGM_RecuperarDatosFichaCliente
Recupera de manera paralela toda la información necesaria para abrir la ficha de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 2}
- PVs: cliente, clienteCompleto, errores, polizas, resultadoInfoCliente
- nombres de nodos: Start Node, End Node, Script Task, Script Task

### PGM_RecuperarRecibosYPrestaciones
Subproceso que permite recuperar de forma asíncrona los datos de un cliente
- nodos: {'Start Node': 1, 'End Node': 1, 'AND': 2, 'Unattended Multiple Questions': 4, 'XOR': 2, 'Call Integration': 2}
- PVs: resultadoAPIRecibos, resultadoAPIPrestaciones, idCliente, nombre, prestaciones, recibos
- nombres de nodos: Start Node, End Node, AND, AND, Script Task, Script Task, Script Task, Script Task, XOR, XOR, Call Integration, Call Integration

### PGM_SeleccionTelefonoWA
Proceso que encapsula el recordAction para la selección de número de teléfono para acceder a WA
- nodos: {'End Node': 1, 'Start Node': 1}
- PVs: cliente, datosCliente, datosTelefono, idContacto, vida
- nombres de nodos: End Node, Start Node

### PGM_SignatureManagemen_Search_Resultado
Llamada a SignatureManagemen_Search y obtener si el cliente tiene un alta o baja en curso
- nodos: {'Start Node': 1, 'End Node': 1, 'XOR': 3, 'Call Integration': 2, 'Unattended Multiple Questions': 4}
- PVs: Documento, body, requestID, santanderAlta, solicitudEnCurso, statusCode
- nombres de nodos: Start Node, End Node, esAlta?, Signature_search Baja,  statusCode, Signature_search, requestID, solicitudEnCurso?, solicitudEnCurso?, statusCode, requestID

### PGM_cancelar_InducirSantander
Llamada al servicio cancellation
- nodos: {'Start Node': 1, 'End Node': 1, 'Unattended Multiple Questions': 1, 'Call Integration': 1}
- PVs: BodyCancelation, inducir, requestId, statusCodeCancellation
- nombres de nodos: Start Node, End Node, statusCode, Signature cancellation

