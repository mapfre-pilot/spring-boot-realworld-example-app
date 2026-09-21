# 3. Inventario de objetos

Inventario generado a partir del volcado read-only (MCP `listApplicationObjects`, `list*`, `get*`).

| Tipo | Cantidad |
|---|---|
| Reglas de expresión | 172 |
| Interfaces | 96 |
| Modelos de proceso | 28 |
| Constantes | 209 |
| Integraciones | 20 |
| Sistemas conectados | 4 |
| Web APIs | 2 |
| Sites | 2 |
| Record types | 1 |
| Grupos | 11 |
| Carpetas | 5 |
| Documentos | 8 |

## Interfaces (96)

| Nombre | Descripción |
|---|---|
| `TVA_Admin_ActivarDesactivar` | Pantalla de Administración para Activar/Desactivar opciones |
| `TVA_Admin_AperturaCierre` | Pantalla de Administración para la Apertura/Cierre |
| `TVA_Admin_GestionCaches` | Pantalla de la Gestión de Caches de TVA |
| `TVA_Beneficiarios_Datos` | Subordinado de la sección de beneficiarios |
| `TVA_Beneficiarios_Estandar` | Subordinado de la sección de beneficiarios |
| `TVA_Beneficiarios_Personas` | Subordinado de la sección de beneficiarios |
| `TVA_Beneficiarios_TextoLibre` | Subordinado de la sección de beneficiarios |
| `TVA_Botonera` | Botonera inferior en las pantallas de la aplicación |
| `TVA_Cabecera` | Interfaz con la cabecera de la aplicación |
| `TVA_CajaDatosDelSeguro` | Caja con los Datos del Seguro |
| `TVA_CajaDatosFirma` | Caja con los Datos de la firma |
| `TVA_CajaDatosFirma_DUP` | Caja con los Datos de la firma duplicada para pruebas |
| `TVA_CajaDatosProductores` | Caja de los datos de los productores |
| `TVA_CajaDocumentosPrecontractuales` | Caja de Documentos precontractuales |
| `TVA_CajaDomiciliacionTomador` | Caja con la Domiciliación del Tomador |
| `TVA_CajaIntervinientes` | Caja de Intervinientes |
| `TVA_CajaRequisitosContratacionInformada` | Caja de Requisitos de Emisión para VIA |
| `TVA_CajaResultadoFirma` | Caja Resultado de la firma |
| `TVA_CajaResumenContratacionInformada` | Caja Resumen de la contratación para VIA |
| `TVA_CajaResumenContratacionRentas` | Caja Resumen Contratación de Rentas |
| `TVA_CajaSeleccionTipoFirma` | Caja Selección del tipo de firma |
| `TVA_Caja_ControlDeCaja` | Caja de Control de caja |
| `TVA_Caja_ControlDeSeccion` | Caja de Control de Sección |
| `TVA_CapturaTomador_CajaParticipante` | Caja de Participante en la Captura del tomador |
| `TVA_CapturaTomador_PanelDerecho` | Pantalla con los Requisitos del Tomador y el Representante |
| `TVA_CapturaTomador_SeccionDatosPersonales` | Sección de datos personales de la Captura del tomador |
| `TVA_CapturaTomador_SeccionDomicilioHabitual` | Sección del Domicilio habitual en la captura del tomador |
| `TVA_CesionDerechos` | Cesión de Derechos |
| `TVA_CesionDerechos_EntidadBancaria` | Subordinado de la sección de cesión de derechos |
| `TVA_CesionDerechos_EntidadNoBancaria` | Subordinado de la sección de cesión de derechos |
| `TVA_DatosContacto` | Seccion que que captura los datos de contacto de un participante, partiendo de la estructura de datos Saving_ClientComplete |
| `TVA_DatosParticipanteV1` | Interfaz de captura de los datos de una persona participante en el seguro. Versión con los controles de Digitalizacion DNI y RGPD dentro de la sección. Se usa para captura de Aportante y Asegurado |
| `TVA_DatosParticipanteV2` | Sección de datos personales de la caja de captura de datos del tomador o representante legal. No se incluyen los controles para digitalización DNI y RGPD. Se usa en modo funcionamiento VIA |
| `TVA_DatosProductores_Detalle` | Pantalla Detalle de los Datos de los productores |
| `TVA_Debug` | Pantalla Debug |
| `TVA_DomicilioV1` | Pantalla para rellenar los datos del domicilio |
| `TVA_DomicilioV2` | Pantalla que recoge el domicilio |
| `TVA_ImpresionVerDocumento` | Pantalla para ver el documento a imprimir |
| `TVA_LogAplicacion` | Log de la aplicación |
| `TVA_MediosContacto` | Sección que que captura los medios de contacto de un participante (teléfonos y correo electrónico) |
| `TVA_MigasDePan` | Pantalla Migas de Pan |
| `TVA_MostrarAvisos` | Sección para mostrar avisos |
| `TVA_OpcionImporteRenta` | Opción importe renta |
| `TVA_PantallaResumenContratacion_PanelDerecho` | Pantalla del Panel derecho del Resumen Contratación |
| `TVA_Pantalla_Administracion` | Interfaz para usuarios administradores del portal TVA |
| `TVA_Pantalla_CapturaDatosSolicitud` | Pantalla de Captura de datos de la solicitud |
| `TVA_Pantalla_CapturaTomador` | Pantalla de la Captura del tomador |
| `TVA_Pantalla_R2C_Captura` | Pantalla de Captura de R2C |
| `TVA_Pantalla_R2C_Precios` | Pantalla de precios de R2C |
| `TVA_Pantalla_ResultadoFirma` | Pantalla Resultado de la firma |
| `TVA_Pantalla_ResumenContratacion` | Pantalla resumen de la contratación para VIR y VIA |
| `TVA_Pantalla_SegurosAhorro` | Pantalla de seguros de ahorro |
| `TVA_Pantalla_SeleccionProductoAhorro` | Pantalla de selección del producto de ahorro |
| `TVA_Principal` | Pantalla principal |
| `TVA_R2C_CajaPrecios` | Caja de Precios para R2C |
| `TVA_R2C_CajaTomadores` | Caja de los Tomadores para R2C |
| `TVA_R2C_PanelDerecho` | Pantalla del panel derecho de R2C |
| `TVA_R2C_SeccionDatosEconomicos` | Sección de Datos económicos en R2C |
| `TVA_R2C_SeccionPrecios` | Sección de precios R2C |
| `TVA_R2C_SeccionTomadores` | Pantalla de Sección de Tomadores para R2C |
| `TVA_SeccionAportante` | Sección del Aportante |
| `TVA_SeccionAsegurado` | Pantalla de la Sección del Asegurado |
| `TVA_SeccionBeneficiarios` | Sección de Beneficiarios |
| `TVA_SeccionCargaPoliza` | Sección de Carga de póliza |
| `TVA_SeccionCargaPoliza_DUP` | Sección de Carga de póliza DUP |
| `TVA_SeccionCesionDerechos` | Sección de Cesión de Derechos |
| `TVA_SeccionDatosContacto` | Sección Datos de contacto |
| `TVA_SeccionDatosDeLaOperacionAhorro` | Datos de la Operación para Venta asesorada VA |
| `TVA_SeccionDatosDeLaOperacionInformada` | Datos de la Operación para Venta informada VIA |
| `TVA_SeccionDatosDeLaOperacionRenta` | Sección de datos de la operación en R2C |
| `TVA_SeccionDatosProductores` | Interfaz de productores |
| `TVA_SeccionDocumentacionPrecontractual` | Sección documentación precontractual |
| `TVA_SeccionDomiciliaciones` | Sección de Domiciliaciones |
| `TVA_SeccionDomiciliacionesTomador` | Sección que que muestra los datos de domiciliaciones de un tomador dentro de una Caja |
| `TVA_SeccionFirma` | Sección de Firma |
| `TVA_SeccionFirma_popup` | Sección de Firma con popup |
| `TVA_SeccionFirma_popup_DUP` | Sección de Firma con popup para pruebas |
| `TVA_SeccionGarantias` | Sección de la caja de datos del seguro |
| `TVA_SeccionInterviniente` | Interfaz de presentación de datos de un interviniente |
| `TVA_SeccionNotas` | Sección de Notas |
| `TVA_SeccionOpcionesDeInversion` | Sección de Opciones de Inversión de venta asesorada |
| `TVA_SeccionOpcionesDeInversionInformada` | Sección de Opciones de Inversión de venta informada para Preferencias de Inversión y Cestas no libres |
| `TVA_SeccionOpcionesDeInversionInformadaCestaLibre` | Sección de Opciones de Inversión de venta informada para CestaLibre |
| `TVA_SeccionRequisitosContratacionInformada` | Sección Requisitos de Emisión |
| `TVA_SeccionResultadoFirma` | Sección Resultado de la Firma |
| `TVA_SeccionResumenContratacionInformada` | Sección del resumen de contratación de la venta informada VIA |
| `TVA_SeccionResumenContratacionRentas` | Sección del Resumen de Contratación de Rentas |
| `TVA_SeccionSeleccionTipoFirma` | Sección de selección del tipo de firma |
| `TVA_SeccionSeleccionTipoFirma_DUP` | Sección de selección del tipo de firma para pruebas |
| `TVA_SistemaCerrado` | Pantalla con el mensaje de que el sistema está cerrado |
| `TVA_Utilidades` | Pantalla de Utilidades de TVA |
| `TVA_Utilidades_Constantes` | Pantalla para modificar valores de constantes |
| `TVA_Utilidades_Inicio` | Pantalla desde donde se lanzan las pruebas de VA, VIA y VIR |
| `TVA_Utilidades_Inicio_DUP` | Pantalla desde donde se lanzan las pruebas de VA, VIA y VIR |
| `TVA_Utilidades_Log` | Pantalla del log de utilidades |
| `TVA_Utilidades_ModalidadesAhorro` | Pantalla de modalidades de ahorro de Utilidades |

## Reglas de expresión (172)

| Nombre | Descripción |
|---|---|
| `TVA_ActualizarAtributoSeccion` | Recibe la estructura de sesion y devuelve la misma estructura con el atributo de la seccion indicada actualizado |
| `TVA_ActualizarSesionParaCapturaDatosAhorro` | Configura la sesión para iniciar la aplicación en la pantalla de captura de datos (sin pasar por la de seguros de ahorro) |
| `TVA_ActualizarSesionParaCapturaDatosRentas` | Configura la sesión para iniciar la aplicación en la pantalla de captura de datos de Rentas (sin pasar por la de seguros de ahorro) |
| `TVA_Address_Validacion` | Validación de datos capturados |
| `TVA_AjustarTomadores` | La regla se asegura de que los tomadores tengan registro de movil y correo electrónico en ContactMethods y de direccion fiscal y correspondencia en Addresses |
| `TVA_AjusteDeCuentas` | Tratamiento de las cuentas de domiciliación (de donde cobra Mapfre) y prestaciones (a la que paga Mapfre) |
| `TVA_ArregloNIF_PFM` | Quita los ceros a la izquierda del NIF |
| `TVA_Avisos_Eliminar` | Eliminar avisos de la sesion. Si se especifica una clase de aviso, se eliminan unicamente los de esa clase, si no se especifica ninguna se elmininan todos los avisos |
| `TVA_Avisos_HayAvisosDeClase` | Devuelve si hay o no avisos de la clase indicada |
| `TVA_Beneficiarios_InicializarBeneficiario` | Inicializar Beneficiario |
| `TVA_Beneficiarios_Validacion` | Validaciones de los Beneficiarios |
| `TVA_CalcularImporteTotalPeriodo` | Regla que calcula el importe total del periodo que correspondería en lo que queda de año natural |
| `TVA_CapturaTomador2_Continuar_inicializarDatosRentas` | Inicializa Datos Renta desde el continuar de la captura del tomador 2 |
| `TVA_CapturaTomador_DatosPersonales_Validacion` | Validación de los datos personales en la captura del tomador |
| `TVA_CapturaTomador_DomicilioHabitual_Validacion` | Validación del domicilio habitual en la captura del tomador |
| `TVA_CesionDerechos_Validacion` | Regla de la validación de la cesión de derechos |
| `TVA_ComparaEntradaClientComplete` | Compara la entrada ClientComplete |
| `TVA_CompararEntradaConClienteVida` | La regla se encarga de realizar una comparación de los datos de un tomador recibidos en la entrada al servicio de inicio con los obtenidos de Personas para el mismo DNI, devuelve una lista de mensajes indicando las discrepancias encontradas |
| `TVA_Conectar_ContrasennaUsuarioVida` | Devuelve la contraseña del usuario APPRIMO (Servicios Vida).  La regla tiene en cuenta el entorno de Appian en el que ejecuta para devolver un valor u otro. Si el parámetro forzarPreEnDev es true, devuelve la contraseña del entorno de pre aunque estemos en el entorno de DEV de Appian, en otro caso, devuelve la contraseña del entorno de inte |
| `TVA_ContactMethod_Validacion` | Validación de datos capturados |
| `TVA_DatosContacto_Validacion` | Validación de los Datos de Contacto |
| `TVA_DatosDeLaOperacionRentas_Validacion` | Validación de los datos de la operación de Rentas |
| `TVA_DatosDeLaOperacion_Validacion` | Validaciones sobre los datos de la operación |
| `TVA_Domiciliaciones_Validacion` | Validación de Domiciliaciones |
| `TVA_DummyRecord` | Expresion dummy para configuracion del record type que se utiliza para montar los pop ups |
| `TVA_EsModalidadPPA` | A partir de la configuración de una modalidad en el taller de productos, devuelve si dicha modalidad es o no PPA |
| `TVA_EsModalidadUnitLinked` | Regla que devuelve si la modalidad de producto es de UnitLinked |
| `TVA_EsValidoTestConveniencia` | Valida si el test de conveniencia es válido |
| `TVA_EsValidoTestIdoneidad` | Regla que determina si es válido el test de idoneidad |
| `TVA_FactoriaRequestAnnuityInsuranceApplication` | Construye la request para el servicio AnnuityInsuranceApplication |
| `TVA_FactoriaRequestAnnuitySimulation` | Construye la request para la llamada al servicio AnnuitySimulation |
| `TVA_FactoriaRequestGuardarPropuesta` | Construye la request para el servicio GuardarPropuesta |
| `TVA_FactoriaRequestIndividualDocumentsVIA` | Regla que construye la request para el envío de documentos precontractuales de VIA |
| `TVA_FactoriaRequestIndividualDocumentsVIR` | Regla que construye la request para el envío de documentos precontractuales de VIR |
| `TVA_FactoriaRequestIndividualNotes` | Construye la estructura de Notas Individuales |
| `TVA_FactoriaRequestPolicyDocuments` | Construye la request para la llamada al servicio PolicyDocuments |
| `TVA_FactoriaRequestSBCMaximo` | Crea la request para la llamada a recuperar el importe máximo |
| `TVA_FactoriaRequestSavingInsuranceApplication` | Construye la request para el servicio SavingInsuranceApplication |
| `TVA_FactoriaRequestSavingInsuranceApplicationVIA` | Construye la request para la llamada a InsuranceApplication para VIA |
| `TVA_FactoriaRequestValidateReinvestment` | Crea la request para el servicio ValidateReinvestment |
| `TVA_FactoriaRequestVerifyProducers` | Genera la request para el verifyproducers |
| `TVA_Factoria_Caja_Privado` | Construye los datos privados de la caja |
| `TVA_Factoria_Caja_Seccion_Privado` | Construye la sección privada de la caja |
| `TVA_FiltroFuncionalidades` | Al llamar al servicio para obtener el perfil de usuario nos quedamos solo con las funcionalidades incluidas en la lista que devuelve esta regla, que son las relevantes para la aplicación. Así evitamos arrastrar una larga lista de valores (hay unas 200 funcionalidades distintas y subiendo) que no tienen utilidad ninguna en la aplicación. |
| `TVA_Garantias_HayGarantiasFallecimientoIncluidas` | Devuelve si hay garantías de fallecimiento incluidas |
| `TVA_Garantias_HayGarantiasVidaIncluidas` | Devuelve si hay garantías de vida incluidas en el producto |
| `TVA_Garantias_HaySucesoFallecimiento` | Devuelve si hay beneficiario de suceso de fallecimiento |
| `TVA_Garantias_HaySucesoVida` | Devuelve si hay beneficiario de suceso de vida |
| `TVA_GetCombinacionPrima` | Devuelve las combinaciones de tipo de prima 0 --> ninguna 1 --> sólo prima única 2 --> sólo prima periódica 3 --> ambas |
| `TVA_GetInfoTraza` | Regla que muestra información de la traza |
| `TVA_GetListaProductos` | Obtiene la Lista de Productos |
| `TVA_GetListaProductosAhorro` | Obtiene la lista de productos de ahorro |
| `TVA_GetListaProductosRentas` | Obtiene la lista de productos de rentas |
| `TVA_GetUuid` | Obtiene el UUID de un objeto |
| `TVA_HayDocPrecontractuales` | Devuelve true si hay algún documento precontractual |
| `TVA_InicializarSesion` | Inicializa una sesión desde el supuesto de que ya tiene los tomadores correctamente asignados |
| `TVA_InicializarTipoBeneficiario` | Inicializa el tipo de beneficiario |
| `TVA_InitBeneficiarios` | Inicializar beneficiarios |
| `TVA_InitBeneficiariosParaCapturaDatos` | Regla para inicializar los beneficiarios en la captura de datos |
| `TVA_InitCajas` | Regla que inicializa las cajas |
| `TVA_InitCajasParaCapturaDatos` | Inicializa las cajas para la captura de datos |
| `TVA_InitClientComplete` | Inicializa una instancia del tipo de datos API_Life_ClientComplete según los datos proporcionados. |
| `TVA_InitContactMethods` | devuelve una lista de medios de contacto con un item de tipo móvil y otro de tipo email, ambos con los valores nulos |
| `TVA_InitDatosOperacionParaCapturaDatos` | Inicializa los datos de la operación para captura de datos |
| `TVA_InitGarantias` | Regla que inicializa las garantías |
| `TVA_InitOpcionesInversion` | Regla que construye la estructura para almacenar las opciones de inversión |
| `TVA_InitOpcionesInversionParaCapturaDatos` | Init para rellenar InvestmentOption para VIA |
| `TVA_InitParticipant` | Inicializa una instancia del tipo de datos API_Saving_Participant según los datos proporcionados. Solo se debe usar para inicializar las estructuras de datos correspondientes al Asegurado y el Aportante |
| `TVA_InitTaxObligationCountries` | devuelve una lista de países de contribución con 3 elementos de valores nulos |
| `TVA_InitTiposOpcionesInversion` | Regla que construye la estructura para almacenar el tipo de inversión |
| `TVA_InitTomador` | Inicializa los datos de un tomador cuando se crea la variable de sesión |
| `TVA_MOCK_ClienteVida01` | Mock ClienteVida01 |
| `TVA_MOCK_DatosSesionCompleto` | objeto completo de la variable Sesion para pasar casos de prueba |
| `TVA_MOCK_InPersonas` | Mock de InPersonas |
| `TVA_MOCK_IndividualDocumentsRequest` | Mock de IndividualDocumentsRequest |
| `TVA_MOCK_IndividualDocumentsRequest2` | Mock de IndividualDocumentsRequest2 |
| `TVA_MOCK_ObtenerClienteRic` | Mock con ClienteRic |
| `TVA_MOCK_OutContractingProposal` | Mock para OutContractingProposal |
| `TVA_MOCK_ParametrosEntrada` | Regla que genera distintos valores de la estructura de datos de los parámetros de entrada de la aplicación |
| `TVA_MOCK_ParametrosEntradaFijo` | Mock para parámetros de entrada fijo |
| `TVA_MOCK_Participante` | Mock de un participante |
| `TVA_MOCK_ParticipanteTomador` | Mock de participante tomador |
| `TVA_MOCK_Perfil_NoEncontrado` | Mock perfil no encontrado |
| `TVA_MOCK_Perfil_Ok` | Mock de perfil ok |
| `TVA_MOCK_PolicyHolder` | Prueba de una PolicyHolder |
| `TVA_MOCK_RequestProposal` | Mock para RequestProposal |
| `TVA_MOCK_RightsAssignment` | MOCK para RightsAssignment |
| `TVA_MOCK_SESION_PFM_06960319J` | TVA_MOCK_SESION_PFM_06960319J |
| `TVA_MOCK_Sesion` | Mock de Sesion |
| `TVA_MOCK_SesionParaFirma` | Mock de la sesión para firma |
| `TVA_MOCK_Sesion_Expresion` | Mock de sesión |
| `TVA_MOCK_Sesion_Expresion_DUP` | Duplico para modificar y pruebas |
| `TVA_MOCK_Sesion_VA_REINVERSION` | Mock de Sesion |
| `TVA_MOCK_Sesion_VIA` | Sesion para probar VIA |
| `TVA_MOCK_Sesion_VIA_584` | Sesion para probar VIA para el producto 584 |
| `TVA_MOCK_Sesion_VIA_Cesta_Libre` | Sesion para probar VIA con cesta libre |
| `TVA_MOCK_Sesion_VIA_Cesta_No_Libre_una` | Sesion para probar VIA con cesta no libre y una opción |
| `TVA_MOCK_Sesion_VIA_Cesta_No_Libre_varias` | Sesion para probar VIA con cesta no libre y varias opciones |
| `TVA_MOCK_Sesion_VIA_FIRMA` | Sesion para probar VIA FIRMA |
| `TVA_MOCK_Sesion_VIA_FIRMA_PAPEL` | Sesion para probar VIA FIRMA en papel |
| `TVA_MOCK_Sesion_VIA_Preferencias` | Sesion para probar VIA |
| `TVA_MOCK_Sesion_VIA_Sin_Tomadores` | Sesión sin tomadores para probar la captura del tomador por VIA |
| `TVA_MOCK_Sesion_VIA_prueba_doc_precontractuales` | Sesion para probar VIA |
| `TVA_MOCK_Taller` | Mock de un taller |
| `TVA_MOCK_Tomador` | Mock tomador |
| `TVA_MOCK_Tomador2` | Mock Tomador 2 |
| `TVA_MOCK_Tomador_Discrepancias` | Mock tomador con discrepancias |
| `TVA_MOCK_VIA_CIF_PolicyHolder` | Mock de PolicyHolder para VIA y de un CIF |
| `TVA_MOCK_VIA_No_Vida_PolicyHolder` | Mock de PolicyHolder para VIA que el cliente no es VIDA |
| `TVA_MOCK_VIA_OpcionesInversion` | Mock de Opciones de inversion |
| `TVA_MOCK_VIA_PolicyHolder` | Mock de PolicyHolder para VIA |
| `TVA_MOCK_VIA_PolicyHolder_agrupaciones` | Mock de PolicyHolder para VIA |
| `TVA_MOCK_VIA_RL_PolicyHolder` | Mock de PolicyHolder para VIA y con RL |
| `TVA_MensajeAuxiliarSeleccionTipoFirma` | Muestra el mensaje auxiliar en la selección del tipo de firma |
| `TVA_MensajeErrorServicioRetencion` | Compone el texto de las retenciones |
| `TVA_Notas_Validacion` | Regla de la validación de las notas |
| `TVA_ObtenerClienteVida` | Obtiene el cliente vida |
| `TVA_ObtenerConvenienciaCliente` | Convierte el campo profileCode que viene alfanumérico en numérico para comparar con la conveniencia de producto, inversion, cestas "" --> 0 BA --> 1 ME -->2 AL --> 3 Otro --> 0 |
| `TVA_ObtenerEmailParticipante` | Obtener el mail del participante |
| `TVA_ObtenerFuncionalidades` | Devuelve un array con los identificadores de las funcionalidades asignadas al usuario partiendo de la respuesta del servicio IGestionarPerfilUsuario |
| `TVA_ObtenerFuncionalidades2` | Devuelve un array con los identificadores de las funcionalidades asignadas al usuario partiendo de la respuesta del servicio IGestionarPerfilUsuario |
| `TVA_ObtenerNuuma` | Obtener nuuma |
| `TVA_ObtenerPerfilUsuario` | Se obtiene el nuuma y se llama al WSDL de IGestionarPerfilUsuario para conseguir la oficina y codProductor. |
| `TVA_ObtenerPerfilUsuario2` | Se obtiene el nuuma y se llama al individual/search/ para conseguir la oficina y codProductor. |
| `TVA_ObtenerProductGroups` | La modalidad pertenece a una agrupación fiscal: en el bloque “productGroups” dentro de “commercialProductSetting” si tiene ProductGroups |
| `TVA_ObtenerRespuestaImporteMaximo` | Regla que obtiene la respuesta de la llamada al importe máximo para agrupaciones fiscales |
| `TVA_ObtenerTelefonoParticipante` | Devuelve el teléfono de una estructura Participant. Si phoneType es nulo, devuelve el movil si lo hay y si no el fijo. Si phoneType=1 devuelve el móvil si lo hay, si no lo hay devuelve nulo. Si honeType=2 devuelve el fijo si lo hay, si no lo hay devuelve nulo |
| `TVA_ObtenerTestConveniencia` | Llama al servicio para recuperar los datos del perfilado |
| `TVA_ObtenerTraza` | Recupera el ultimo valor de traza que cumpla los criterios indicados |
| `TVA_ObtenerURLEntorno` | Regla para obtener la URL del entorno |
| `TVA_OpcionIncluidaSinImporte` | Devuelve true si la opción incluida tiene importe |
| `TVA_OpcionesDeInversion_Validacion` | Validaciones de las opciones de inversión |
| `TVA_Participante_Validacion` | Validación de los datos del participante |
| `TVA_PerfilCliente_ProcesarRespuesta` | Procesa la respuesta del PerfilCliente |
| `TVA_PerfilCliente_TC_Relleno` | Devuelve true si el perfil del test de conveniencia viene relleno y no es necesario llamar al perfilado |
| `TVA_R2C_MOCK_Entrada` | Mock de Entrada para R2C |
| `TVA_R2C_MOCK_Taller` | Mock de taller para R2C |
| `TVA_R2C_WebApi_Inicio_ObtenerMensajeError` | Obtiene el mensaje de error en el Inicio del WebApi para R2C |
| `TVA_RecalcularPrimaPeriodicayPorcentaje` | Recalcula la prima periódica y el porcentaje de la fila seleccionada y las demás, en relación al ajuste que hay que hacer con los decimiales |
| `TVA_RequestSavingInsurancesApplication_Participantes` | Construye los participantes de la request de SavingInsurancesApplication |
| `TVA_RequisitosContratacion_Validacion` | Validaciones de los Requisitos de contratación |
| `TVA_ResponseInicio` | Regla que genera la respuesta de la webApi TVA Inicio desde WebApi |
| `TVA_SimuladorRentas_Captura_Validacion` | Validación de la captura en Simulación de Rentas |
| `TVA_SimuladorRentas_InicializarSesion` | Inicializar la sesión en la simulación de Rentas |
| `TVA_VA_ValidacionPolicyHolder` | Validación de los parámetros de entrada cuando el modo de funcionamiento es VA |
| `TVA_VIA_ActualizarSesionParaCapturaDatosAhorro` | Configura la sesión para iniciar la aplicación en la pantalla de captura de datos (sin pasar por la de seguros de ahorro) para VIA |
| `TVA_VIA_InitBeneficiariosParaCapturaDatos` | Regla para inicializar los beneficiarios en la captura de datos para VIA |
| `TVA_VIA_InitDatosOperacionParaCapturaDatos` | Inicializa los datos de la operación para captura de datos de VIA |
| `TVA_VIA_ValidacionInvestmentOption` | Validación de los parámetros de entrada para VIA InvestmentOption |
| `TVA_VIA_ValidacionPolicyHolder` | Validación de los parámetros de entrada cuando el modo de funcionamiento es VIA |
| `TVA_ValidacionAddress` | Validación de los parámetros de entrada |
| `TVA_ValidacionClientComplete` | Validación de los parámetros de entrada |
| `TVA_ValidacionContactMethod` | Validación de los parámetros de entrada |
| `TVA_ValidacionIdentificationMethod` | Validación de los parámetros de entrada |
| `TVA_ValidacionInvestmentOption` | Validación de los parámetros de entrada |
| `TVA_ValidacionLabourInformation` | Validación de los parámetros de entrada |
| `TVA_ValidacionNaturalPerson` | Validación de los parámetros de entrada |
| `TVA_ValidacionPersonName` | Validación de los parámetros de entrada |
| `TVA_ValidacionTaxObligationCountry` | Validación de los parámetros de entrada |
| `TVA_ValidacionTestData` | Validación para comprobar que viene relleno el test de conveniencia |
| `TVA_ValidarSeccionesParaCapturaDatosAhorro` | Regla que valida las secciones para captura de datos ahorro |
| `TVA_ValidarSeccionesParaCapturaDatosRentas` | Valida las secciones para la captura de datos de rentas |
| `TVA_WRAP_Taller` | Wrap de taller |
| `TVA_WebApi_Inicio_ObtenerMensajeError` | Validaciones para mostrar los mensajes de error de los parámetros de entrada al WebAPI |
| `TVA_propuestaProductosAhorro_siguientePantalla` | Determina la siguiente pantalla desde propuesta Productos Ahorro |
| `TVA_prueba` | prueba |
| `TVA_prueba2` | prueba2 |
| `TVA_prueba3` | prueba3 |
| `TVA_prueba4` | prueba4 |
| `TVA_prueba5` | pruebas |
| `TVA_prueba_tax` | TVA_prueba_tax |
| `TVA_responseTVAWebAPI` | Guarda la respuesta de TVA para que el llamante se entere de lo que ha pasado. |

## Modelos de proceso (28)

| Nombre | Descripción | Nodos | Variables |
|---|---|---|---|
| `TVA Batch Apertura-Cierre` | Proceso Batch que se encarga de cerrar/abrir la aplicación según la programación efectuada por el usuario | 8 | 0 |
| `TVA Batch Borrar traza` | Batch Borrar traza | 6 | 1 |
| `TVA CapturaDatosRentas-Contratar` | CapturaDatosRentas-Contratar | 11 | 10 |
| `TVA CapturaTomador1-Continuar` | Acción para el botón Continuar en Captura de tomador 1 | 13 | 2 |
| `TVA CapturaTomador2-Continuar` | Acción para el botón Continuar en Captura de tomador 2 | 9 | 2 |
| `TVA DocumentacionPrecontractual` | Proceso que envía los documentos precontractuales | 20 | 10 |
| `TVA Firma-EnvioFirmaManuscrita` | Record action | 7 | 1 |
| `TVA Firmar` | Proceso que firma la póliza | 7 | 8 |
| `TVA Guardar y volver` | Guardar y Volver en VA Contratar en VIA | 17 | 13 |
| `TVA IPs` | Proceso que manda un aviso a los Administradores | 4 | 1 |
| `TVA ImporteMaximo` | Modelo de proceso que llama al servicio para recuperar el importe máximo cuando el producto pertenece a agrupaciones fiscales | 11 | 7 |
| `TVA IndividualNotes` | Proceso para notas individuales | 6 | 6 |
| `TVA Inicio Ahorro` | Inicio | 25 | 6 |
| `TVA Inicio SimuladorRentas` | Inicio SimuladorRentas | 8 | 2 |
| `TVA Perfil cliente` | Perfil cliente | 8 | 9 |
| `TVA PopUp Cesion derechos` | Proceso para la cesión de derechos | 9 | 5 |
| `TVA PopUp DigitalizacionDNI` | Proceso para la digitalización del DNI | 8 | 5 |
| `TVA PopUp Firmar` | Proceso que firma la póliza | 9 | 8 |
| `TVA PopUp Intervinientes` | PopUp Intervinientes | 5 | 2 |
| `TVA PopUp RGPD` | Proceso para gestionar la captura del consentimiento para el uso de datos personales | 8 | 5 |
| `TVA PopUp TestConveniencia` | Modelo de proceso que lanza el test de conveniencia | 8 | 5 |
| `TVA R2C Capt-Siguiente` | Se lanza al pulsar el botón Siguiente en la pantalla de captura de R2C | 11 | 8 |
| `TVA R2C Precios-Contratar` | R2C Precios-Contratar | 15 | 6 |
| `TVA R2C Precios-Recalcular` | Se lanza al pulsar el botón Recalcular en la pantalla de precios de R2C | 14 | 7 |
| `TVA ValidarReinversion` | Proceso que valida la reinversión | 7 | 7 |
| `TVA VerificarProductores` | Verificar Productores | 8 | 7 |
| `TVA modalidadProductosAhorro` | Proceso que persiste la modalidad de producto y llama otros servicios necesarios (perfilCliente y verificarProductores) | 15 | 5 |
| `TVA propuestaProductosAhorro` | Proceso que persiste la propuesta de ahorro y llama otros servicios necesarios (perfilCliente y verificarProductores) | 13 | 8 |

## Constantes (209) — agrupadas por prefijo

| Prefijo | Nº | Uso |
|---|---|---|
| `TVA_TRAZA_*` | 60 | Códigos de traza (clase, tipo contenido, ubicación…) |
| `TVA_VAL_*` | 17 | Valores de negocio (modos de venta, códigos de proceso, mensajes) |
| `TVA_CAJA_*` | 17 | Identificadores de cajas de UI |
| `TVA_SECCION_*` | 16 | Identificadores de secciones de UI |
| `TVA_ID_*` | 15 | Identificadores de pantalla |
| `TVA_AVISOS_*` | 14 | Clases y ubicaciones de avisos |
| `TVA_PM_*` | 14 | Referencias a modelos de proceso |
| `TVA_FUNCIONALIDAD_*` | 9 | Interruptores de funcionalidad |
| `TVA_LITERALES_*` | 9 | Literales/prefijos de texto |
| `TVA_CODIGOS_*` | 7 | Códigos varios |
| `TVA_FLAG_*` | 5 | Flags |
| `TVA_GRP_*` | 5 | Referencias a grupos |
| `TVA_R2C_*` | 3 | Rentas |
| `TVA_DOC_*` | 2 | Documentos |
| `TVA_MENSAJE_*` | 2 | Mensajes |
| `TVA_NOMBRE_*` | 2 | Nombres de aplicación |
| `TVA_FECHA_*` | 2 | Fechas apertura/cierre |
| `TVA_FOL_*` | 1 | Carpeta |
| `TVA_FORMATO_*` | 1 | Formato |
| `TVA_ENT_*` | 1 | Entidad data store (traza) |
| `TVA_TIMEOUT_*` | 1 | Timeout |
| `TVA_APLICACION_*` | 1 | Aplicación |
| `TVA_FIRMA_*` | 1 | Firma |
| `TVA_ACRONIMO_*` | 1 | Acrónimo aplicación |
| `CMP_VAL_*` | 1 | Constante con prefijo CMP dentro de la app TVA (`CMP_VAL_SIGLAS_APLICACION_TVA`) |
| `TVA_USUARIOS_*` | 1 | Usuarios |

Nota: `listConstants` devolvió 209 constantes pero una (`TVA_LITERALES_PREFIJO_DISCREPANCIA_VALOR_VIDA`) no pudo serializarse por el MCP.

## Tipos de datos (CDT) más usados

Los CDT no forman parte del inventario devuelto por la aplicación, pero se referencian desde SAIL:

- Propios (`urn:com:appian:types:TVA`): `TVA_Sesion`, `TVA_Caja_Publico`, `TVA_Caja_Seccion_Publico`, `TVA_Aviso`, `TVA_Discrepancia`, `TVA_Participante`, `TVA_PolicyHolder`, `TVA_ClientComplete`, `TVA_Address`, `TVA_ContactMethod`, `TVA_IdentificationMethod`, `TVA_NaturalPerson`, `TVA_PersonName`, `TVA_LabourInformation`, `TVA_TaxObligationCountry`, `TVA_DatosOperacion`, `TVA_DatosGestion`, `TVA_DatosRIC`, `TVA_Beneficiarios`, `TVA_Comisiones`, `TVA_Firma`, `TVA_DocumentoPrecontractual`, `TVA_PerfilUsuario`, `TVA_PerfilCliente`, `TVA_Rentas`, `TVA_VIA`, `TVA_VIA_InvestmentOption`, `TVA_SuitabilityConvenience`, `TVA_DataTest`, `TVA_Traza`.
- De la app VIDA (`urn:com:appian:types:VIDA`), espejo del contrato API Life: `VIDA_API_Life_ContactMethod`, `VIDA_API_Life_InvestmentOption`, `VIDA_API_Life_Address`, `VIDA_API_Life_IdentificationMethod`, `VIDA_API_Life_ClientComplete`, `VIDA_API_Life_Participant`, `VIDA_API_Life_PaymentMethod`, `VIDA_API_Life_BankAccountInfo`, `VIDA_API_Life_NaturalPerson`, `VIDA_API_Life_PrintType`, `VIDA_API_Life_ContractingProposal`, `VIDA_API_Life_InsurancesApplicationProposal`, `VIDA_API_Life_OutPostIndividualPolicy`, `VIDA_API_Life_InPostIndividualSavingPolicy`, `VIDA_API_Life_FundBasket`, `VIDA_API_SBC_MSSDatosImporteMaximo`, entre otros.
- De CMP: `CMP_Errors_List`.

Se observa duplicidad de modelo: para casi cada CDT `VIDA_API_Life_X` existe un `TVA_X` equivalente (Address, ContactMethod, IdentificationMethod, NaturalPerson, PersonName, LabourInformation, TaxObligationCountry, ClientComplete, PolicyHolder), con reglas `TVA_Validacion<X>` y `TVA_<X>_Validacion` en paralelo.

## Record type

- `TVA Dummy` (`aa327b76-9e53-4a80-a65c-5d1a052c296e`): "Tipo de registro Dummy para levantar PopUp". Sin campos de negocio, `titleExpression: rv!identifier`; soporte para acciones en diálogo.

## Carpetas y documentos

- Carpeta de reglas y constantes `TVA` (`f1cd977d-d796-4a2a-8e16-dfb9eee1f28f`)
- Carpeta de modelos de proceso `TVA Modelos de procesos` (`2cfe12d8-b256-4ef3-9927-4669b45304ed`)
- Knowledge Center `TVA` (`aa541fd2-9ee2-47a0-ac8a-ea526b82bcec`) con 8 documentos (imágenes y logos):

  - `TVA Descarga documento` Imagen descarga de documento
  - `TVA Logo aplicacion` Logo de la aplicación
  - `TVA No perfilado` Imagen no perfilado
  - `TVA Perfil_Arriesgado` PGM Perfil_Arriesgado
  - `TVA Perfil_Moderado` PGM Perfil_Moderado
  - `TVA Perfil financiero_conservador` Imagen perfil financiero conservador
  - `TVA Perfil financiero_decidido` Imagen perfil financiero decidido
  - `TVA_ico_descarga_documento` Icono descarga documento
