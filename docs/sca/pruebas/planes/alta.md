# Plan de pruebas SCA — Alta

Origen: `Plan_pruebas_SCA_-_Alta.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test` (filtrada por application_udf = SCA)


### manual_test-1. Alta - Motivo Detalle Causa
- prioridad: 2-Medium · tipo: Functional · descripción:  Motivo Detalle Causa · condiciones de datos: Póliza válida; combinaciones activas de Motivo, Detalle y Causa.
- Pasos:
  1. Con pantalla de alta cargada de forma correcta
  1. Seleccionamos motivo y comprobamos que se rellena el desplegable de Detalle correctamente
  1. Seleccionamos un Detalle y comprobamos que rellena las causas de forma correcta
  1. Seleccinonamos Causa y comprobamos que carga catalogaciones de forma correcta

### manual_test-2. Alta - Catalogaciones
- prioridad: 2-Medium · tipo: Unit · descripción: Catalogaciones · condiciones de datos: Póliza válida; causa con varias catalogaciones.
- Pasos:
  1. Con pantalla de alta cargada de forma correcta, al seleccionar una causa rellana el listado de catalogaciones
  1. Seleccionamos catalogación y comprobamos que se rellena la fecha de anulación y habilita o no el calendario según el caso
  1. En esta prueba seria conveniente comprobar las diferentes catalogaciones **[validación]**

### manual_test-3. Alta - Compañía aseguradora
- prioridad: 2-Medium · tipo: Functional · descripción: Compañía aseguradora · condiciones de datos: Póliza válida; compañía contraria activa.
- Pasos:
  1. Con la pantalla de alta cargada, seleccionamos compañía contraria
  1. Comprobamos que se selecciona de forma correcta y se rellena el campo descripción con lo correspondiente. Al dar de alta guarda el dato de forma correcta

### manual_test-4. Alta – Canal de Entrada
- prioridad: 2-Medium · tipo: Functional · descripción: Canal de Entrada · condiciones de datos: Pólizas con y sin impagado; perfiles Red Mapfre, CCR, CCC, SI24, Central y GGE.
- Pasos:
  1. Con la pantalla de alta cargada, observamos comportamiento de canal de entrada
  1. Canal de entrada sigue estas reglas según perfiles: Si la póliza tiene un impagado, el canal de entrada será “impago”. En caso contrario, se aplicarán las siguientes reglas: Si el canal de ejecución es Red Mapfre, el canal de entrada es “Presencial” Si el canal de ejecución es CCR el canal de entrada es “Correspondencia” ​Si el canal de ejecución es CCC el canal de entrada es 'Impago' *Ver Nota. Si el canal de ejecución es SI24 (soporte a acuerdos), el canal de entrada es ‘Mediador’ Si el canal de ejecución es SI24 (Atención clientes), el canal de entrada es 'Telefónico' ​Si el canal de ejecución es SI24 (Expertos retención), el canal de entrada es 'Telefónico'​​ Si el canal de ejecución es Central o Direcciones Técnicas, el canal de entrada se deja vacío ​​Si el canal de ejecución es GGE, el canal de entrada es telefónico. **[validación]**

### manual_test-5. Alta – Canal de Entrada. Medios de comunicación
- prioridad: 2-Medium · tipo: Functional · descripción: Canal de Entrada. Medios de comunicación · condiciones de datos: Póliza válida; medios Fax, Email y Carta, con Fax informado y vacío.
- Pasos:
  1. Con la pantalla de alta cargada, observamos comportamiento de canal de entrada al seleccionar Medio de comunicación
  1. Entre los distintos medios está el fax, email o carta. Al seleccionar Fax es obligatorio añadirlo. **[validación]**

### manual_test-6. Alta - Validación campos obligatorios
- prioridad: 2-Medium · tipo: Functional · descripción: Validación campos obligatorios · condiciones de datos: Póliza válida; un campo obligatorio vacío en cada ejecución.
- Pasos:
  1. En la pantalla de alta. Rellenamos todos los datos obligatorios menos uno y pulsamos Guardar
  1. Comprobamos que aparece el aviso de campo obligatorio sin rellenar

### manual_test-7. Alta – Cancelación de solicitud
- prioridad: 2-Medium · tipo: Unit · descripción: Cancelación · condiciones de datos: Póliza válida; solicitud nueva sin guardar.
- Pasos:
  1. En la pantallla de alta aparece el botón cancelar, el cual presionamos.
  1. SCA cancela la solicitud previo mensaje de confirmación **[validación]**

### manual_test-8. Alta - Cabecera wAutemis
- prioridad: 2-Medium · tipo: Functional · descripción: Cabecera wAutemis · condiciones de datos: Póliza wAutemis vigente y sin solicitud en curso.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo wAutemis que no esté anulada
  1. Comprobamos que redirige y carga la pantalla de alta de forma correspondiente
  1. Muestra todos los datos de cabecera de forma correcta. Se comprueba también en solicitud creada

### manual_test-9. Alta - Cabecera NSE Autos
- prioridad: 2-Medium · tipo: Functional · descripción: Cabecera NSE Autos · condiciones de datos: Póliza NSE Autos vigente y sin solicitud en curso.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo NSE autos en vigor sin solicitud en curso
  1. Comprobamos que redirige y carga la pantalla de alta de forma correspondiente
  1. Muestra todos los datos de cabecera de forma correcta. Se comprueba también en solicitud creada

### manual_test-10. Alta - Cabecera NSE Hogar
- prioridad: 2-Medium · tipo: Functional · descripción: Cabecera NSE Hogar · condiciones de datos: Póliza NSE Hogar vigente y sin solicitud en curso.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo NSE Hogar en vigor sin solicitud en curso
  1. Comprobamos que redirige y carga la pantalla de alta de forma correspondiente
  1. Muestra todos los datos de cabecera de forma correcta. Se comprueba también en solicitud creada

### manual_test-11. Alta - Guardar Contra Anulación
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación · condiciones de datos: Póliza apta para Contra Anulación; causa Me ha subido mucho la prima.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a contra anulación (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta. Advertimos el mensaje de paso y redirige a la pantalla de contra anulación

### manual_test-12. Alta - Guadar Acción Administrativa
- prioridad: 2-Medium · tipo: Functional · descripción: Alta - Guadar Acción Administrativa · condiciones de datos: Póliza apta para Acción Administrativa; causa Baja Vehículo.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de acciones administrativas

### manual_test-13. Alta - Guadar Acción Administrativa. Mensajes y cancelación
- prioridad: 2-Medium · tipo: Functional · descripción: Alta - Guadar Acción Administrativa. Mensajes · condiciones de datos: Pólizas con distinta documentación requerida; causa Baja Vehículo.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos casos distintos para ver el mensaje de aviso de los documentos a incluir en cada caso. Comprobamos botón cancelar

### manual_test-14. Alta - Guardar Autorización
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Autorización · condiciones de datos: Póliza que requiera Autorización; causa Anulación fuera de norma.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a Autorización (Decisión de la entidad- Decisión de la entidad - Anulación Fuera de norma) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de Autorizaciones tras mostrar mensaje de aviso correspondiente

### manual_test-15. Alta - Guardar Mecanización directa
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Mecanización directa · condiciones de datos: Póliza apta para mecanización directa o flota wAutemis.
- Pasos:
  1. Entramos a la pantalla de alta con usuario perfil y póliza que salte a mecanización directa o con póliza de flotas en Wautemis. Rellenamos motivo-detalle-causa que salte a mecanización directa.
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla Mecanización mostrando la pantalla de simulación correspondiente

### manual_test-16. Alta - Validación fecha de anulación con póliza con siniestros en la anualidad
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha de anulación con póliza con siniestros en la anualidad · condiciones de datos: Póliza con siniestro en la anualidad; usuario distinto de CCC/CCR.
- Pasos:
  1. Entramos a pantalla de alta con póliza que tenga siniestros en la anualidad en curso y perfil distinto a CCC o CCR
  1. Rellenamos datos obligatorios y catalogación A fecha. Pulsamos botón guardar
  1. Validara que la fecha de anulación introducida en la catalogación de la solicitud es estríctamente superior a la fecha de último siniestro existente en la póliza en la anualidad
  1. Si no es el caso mostrará modal de aviso indicandolo. Comprobar que muestra modal con el aviso correcto si fuera el caso

### manual_test-17. Alta - Validación fecha anulación. No realizar validaciones para subperfiles CCC y CCR.
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha anulación. No realizar validaciones para subperfiles CCC y CCR. · condiciones de datos: Póliza válida para el caso.
- Pasos:
  1. Entramos a pantalla de alta con póliza que tenga siniestros en la anualidad en curso y perfil CCC o CCR
  1. Rellenamos datos obligatorios y catalogación A fecha. Pulsamos botón guardar
  1. No realizará las validaciones de fecha y no mostrará aviso correspondiente por tratarse de subperfiles CCC o CCR

### manual_test-18. Alta - Validación fecha anulación mayor fecha vencimiento
- prioridad: 2-Medium · tipo: Functional · condiciones de datos: Póliza con fecha de anulación posterior al vencimiento; usuario distinto de CCC/CCR.
- Pasos:
  1. Entramos a la pantalla de alta con usuario distinto de subperfil CCC o CCR. Rellenamos datos obligatorios y ponemos fecha de anulación mayor a la de vencimiento de la póliza. Pulsamos botón guardar
  1. Validará que la fecha introducida sea mayor que la de vencimiento de la póliza y mostrará mensaje de aviso, no dejando continuar.

### manual_test-19. Alta - Validación fecha anulación mayor fecha vencimiento. No realizar validaciones para CCC y CCR
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha anulación mayor fecha vencimiento. No realizar validaciones para CCC y CCR · condiciones de datos: Póliza con fecha de anulación posterior al vencimiento; usuario CCC o CCR.
- Pasos:
  1. Entramos a la pantalla de alta con usuario de subperfil CCC o CCR. Rellenamos datos obligatorios y ponemos fecha de anulación mayor a la de vencimiento de la póliza. Pulsamos botón guardar
  1. No realizará las validaciones de fecha y no mostrará aviso correspondiente por tratarse de subperfiles CCC o CCR

### manual_test-20. Alta - Mas Movil
- prioridad: 2-Medium · tipo: Functional · descripción: Mas Movil · condiciones de datos: Póliza MásMóvil sin siniestros en la anualidad.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo Mas Movil sin siniestros en la anualidad en curso
  1. Rellenamos datos del alta con detalle Precio y Causa Me ha subido mucho la prima
  1. Observamos que en la catalogación aparece A Vencimiento Trimestral y en la caja de fecha el primer día del trimestre siguiente según las fechas de la anualidad sin posibilidad de editarlo

### manual_test-21. Alta - Guardar Contra Anulación paso experto No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación paso experto No · condiciones de datos: Póliza susceptible de paso a experto; usuario SI24 Información general; respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con usuario perfil SI24 informacion general y póliza susceptible de paso a experto. Rellenamos motivo-detalle-causa que derive a contra anulación (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si se queire pasar la solicitud de anulación al grupo de expertos y los botones Si y No
  1. Pulsamos botón No
  1. Comprobamos que se guarda de forma correcta el valor correspondiente en anula_expertos y redirige a la pantalla de contra anulación

### manual_test-22. Alta - Guardar Contra Anulación paso experto Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación paso experto Si · condiciones de datos: Póliza susceptible de paso a experto; usuario SI24 Información general; respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con usuario perfil SI24 informacion general y póliza susceptible de paso a experto. Rellenamos motivo-detalle-causa que derive a contra anulación (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si se queire pasar la solicitud de anulación al grupo de expertos y los botones Si y No
  1. Pulsamos botón Si
  1. Comprobamos que aparcen los siguientes modales para introducir teléfono del cliente
  1. Comprobamos que se guarda de forma correcta el valor correspondiente en anula_expertos y redirige a la pantalla de contra anulación

### manual_test-23. Alta - Guardar Acción Administrativa telematica telefonica No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa telematica telefonica No · condiciones de datos: Póliza de origen telemática telefónica; respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de origen telematica telefonica. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal de aviso preguntando si el cliente insiste en que se anule por este canal y los botones Si y No
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de acciones administrativas
  1. Pulso botón No
  1. Compruebo que se guarda en valor false en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test-24. Alta - Guardar Acción Administrativa telematica telefonica Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa telematica telefonica Sí · condiciones de datos: Póliza de origen telemática telefónica; respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de origen telematica telefonica. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal de aviso preguntando si el cliente insiste en que se anule por este canal y los botones Si y No
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de acciones administrativas
  1. Pulso botón Sí
  1. Compruebo que se guarda en valor true en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test-25. Alta - Guardar Acción Administrativa acuerdo especial Botón No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa acuerdo especial Botón No · condiciones de datos: Póliza de acuerdo especial Ibericar; canal productor Corredor (4); respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de acuerdo especial tipo Ibericar. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo), canal productor corredor (4) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente avisando de que la póliza es de un acuerdo especial y preguntando si el cliente insiste en que se anule por este canal. Y los botones Si y No
  1. Pulso botón No
  1. Compruebo que se guarda en valor false en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test-26. Alta - Guardar Acción Administrativa acuerdo especial Botón Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa acuerdo especial Botón Sí · condiciones de datos: Póliza de acuerdo especial Ibericar; canal productor Corredor (4); respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de acuerdo especial tipo Ibericar. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo), canal productor corredor (4) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente avisando de que la póliza es de un acuerdo especial y preguntando si el cliente insiste en que se anule por este canal. Y los botones Si y No
  1. Pulso botón Sí
  1. Compruebo que se guarda en valor true en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test-27. Alta - Guardar Contra Anulación subperfil CCC Botón No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación subperfil CCC Botón No · condiciones de datos: Póliza apta para Contra Anulación; usuario CCC; respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con usuario de subperfil CCC. Rellenamos motivo-detalle-causa que derive a Contra Anulación (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si desa realizar contra anulación para esta solicitud
  1. Pulso botón No
  1. Compruebo que se guarda en valor false en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test-28. Alta - Guardar Contra Anulación subperfil CCC Botón Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación subperfil CCC Botón Sí · condiciones de datos: Póliza apta para Contra Anulación; usuario CCC; respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con usuario de subperfil CCC. Rellenamos motivo-detalle-causa que derive a Contra Anulación (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si desa realizar contra anulación para esta solicitud
  1. Pulso botón Sí
  1. Compruebo que se guarda en valor true en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test-29. Alta - Ilocalizado, Red Mapfre y no correspondencia
- prioridad: 2-Medium · tipo: Functional · descripción: Ilocalizado, Red Mapfre y no correspondencia · condiciones de datos: Póliza válida; usuario Red Mapfre; causa Ilocalizado; canal distinto de Correspondencia.
- Pasos:
  1. En la pantalla de alta entramos con usuario de perfil Red Mapfre, causa ilocalizado y canal de entrada distinto de correspondencia.
  1. Al rellenar esta combinación, el sistema deberá mostrar alerta de aviso en la pantalla de alta indicando que no es posible dar de alta una solicitud presencial con este medio de comunicación.

### manual_test-30. Alta - Ilocalizado, Red Mapfre y correspondencia
- prioridad: 2-Medium · tipo: Functional · descripción: Ilocalizado, Red Mapfre y correspondencia · condiciones de datos: Póliza válida; usuario Red Mapfre; causa Ilocalizado; canal Correspondencia.
- Pasos:
  1. En la pantalla de alta entramos con usuario de perfil Red Mapfre, causa ilocalizado, canal de entrada correspondencia y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. El sistema mostrará un aviso indicando al usuario que al dar de alta la solicitud con esas condiciones no se podrá imprimir la carta de anulación ni se tendra acceso al argumentario

### manual_test-31. Alta - Ilocalizado y canal no correspondencia ni area clientes
- prioridad: 2-Medium · tipo: Functional · descripción: Ilocalizado y canal no correspondencia ni area clientes · condiciones de datos: Póliza válida; causa Ilocalizado; canal distinto de Correspondencia y Área Clientes.
- Pasos:
  1. En la pantalla de alta causa ilocalizado y canal de entrada: distinto de correspondencia y area clientes
  1. Al rellenar esta combinación, el sistema deberá mostrar alerta de aviso en la pantalla de alta indicando que no es posible dar de alta una solicitud presencial con este medio de comunicación.

### manual_test-32. Alta - Si24 Corredor o Banca y solicitud misma anualidad
- prioridad: 2-Medium · tipo: Functional · descripción: Si24 Corredor o Banca y solicitud misma anualidad · condiciones de datos: Póliza con solicitud en la misma anualidad; usuario SI24 Experto; canal Corredor o Banca.
- Pasos:
  1. En la pantalla de alta entramos con usuario de subperfil SI24 experto, canal productor y póliza con solicitud en la misma anualidad. Rellenamos resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Muestra mensaje arriba en la cabecera avisando de que existen solicitudes de anulación realizadas para ese cliente y póliza

### manual_test-33. Alta - Mensaje de error controlado simulación New, No continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación New, No continua · condiciones de datos: Póliza wAutemis con operación pendiente; simulación devuelve M201.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta contra anulación con póliza tipo wAutemis que presente una autoriación pendiente y retorne por tanto dicho error en la consulta a simulación
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo wAutemis el servicio de simulación correspondiente retorna error M201
  1. Se muestra al usuario mensaje 'Se ha detectado una operación pendiente de revisión para esta póliza. Hasta que no se apruebe o rechace la operación pendiente no es posible acutar sobre ella'. No dejará continuar y se quedará en dicha pantalla.

### manual_test-34. Alta - Mensaje de error controlado simulación NSE, No continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación NSE, No continua · condiciones de datos: Póliza NSE cuya simulación devuelve error, null o error SQL.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta accion administrativa con póliza tipo NSE que presente algún tipo de problema y con los datos rellenos el servicio de simulación retorne Error en la consulta.
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE el servicio de simulación correspondiente retorna error en la consulta, null o Error de tipo SQL en el acceso a las Logicas d eAcceso a Datos
  1. Se muestra al usuario mensaje 'NSE no nos está indicando el estado actual de la pólia. Por favor, compruebe la situación de la misma en NSE e inténtelo mas tarde...'. No dejará continuar y se quedará en dicha pantalla.

### manual_test-35. Alta - Mensaje de error controlado simulación New, Continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación New, Continua · condiciones de datos: Póliza wAutemis cuya simulación devuelve M206.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta contra anulación con póliza tipo wAutemis que en el servicio de simulación con dichos datos retorne el mensaje M206 Error al consutlar el estado de la situación de l apóliza
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo wAutemis el servicio de simulación correspondiente retorna error M206
  1. Se muestra al usuario mensaje 'New nos indica que no puede determinar el estado de la póliza. Se continúa a contra anulación, si finalmente va a anular la póliza, por favor, compruebe la situación…...'.
  1. El usuario acepta dicho modal de aviso y continua con el alta y redirige a la pantalla de contra anulación

### manual_test-36. Alta - Mensaje de error controlado simulación NSE, continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación NSE, continua · condiciones de datos: Póliza NSE cuya simulación devuelve error, null o error SQL; flujo permite continuar.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta Contra Anulación con póliza tipo NSE que presente algún tipo de problema y con los datos rellenos el servicio de simulación retorne Error en la consulta.
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE el servicio de simulación correspondiente retorna error en la consulta, null o Error de tipo SQL en el acceso a las Logicas d eAcceso a Datos
  1. Se muestra al usuario mensaje 'NSE no nos está indicando el estado actual de la pólia. Por favor, compruebe la situación de la misma en NSE e inténtelo mas tarde...'.
  1. El usuario acepta dicho modal de aviso y continua con el alta y redirige a la pantalla de contra anulación

### manual_test-37. Alta - Excepción pólizas PRRA NSE autos
- prioridad: 2-Medium · tipo: Functional · descripción: Excepción pólizas PRRA NSE autos · condiciones de datos: Póliza PRRA NSE Autos.
- Pasos:
  1. En la pantalla de alta entro con póliza tipo PRRA NSE autos. Relleno todos los campos obligatorios para dar de alta una contra anulación
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE autos, detecta que es de tipo PRRA y muestra mensaje correspondiente al usuario modificando el motivo,detalle causa por el 3, 8 y 10 antes de realizar el guardado correspondiente y alta de la solicitud
  1. Comprobamos que se realiza el guardado de forma correta y redirige a la contra anulación de forma correcta

### manual_test-38. Alta - Excepción pólizas PRRA NSE Hogar
- prioridad: 2-Medium · tipo: Functional · descripción: Excepción pólizas PRRA NSE autos · condiciones de datos: Póliza PRRA NSE Hogar.
- Pasos:
  1. En la pantalla de alta entro con póliza tipo PRRA NSE Hogar. Relleno todos los campos obligatorios para dar de alta una contra anulación
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE hogar, detecta que es de tipo PRRA. No mostrará ningún mensaje de aviso y dara de alta la contra anulación correspondiente pero en las invocaciones a simulación de póliza cambiara en dicha invocación el motivo-detalle causa NSE 0013-0008-0021 correspondientes.
  1. Comprobar que se da de alta la contra anulación de forma correcta y se finaliza anulando sin problema para este tipo de póliza concreto

### manual_test-39. Alta – Error al vuelo
- prioridad: 2-Medium · tipo: Unit · descripción: Excepción pólizas PRRA NSE autos · condiciones de datos: Póliza válida; Appian preparado para provocar un fallo controlado.
- Pasos:
  1. En la pantalla de alta rellenamos con valores correctos pero con Appian preparado para el fallo
  1. Pulsamos botón guardar
  1. Se queda la póliza parada en proceso
  1. La solicitud redirige a Detalles de la solicitud indicando el error **[validación]**

Casos en esta hoja: 39

## Hoja `manual_test_2` (sin application_udf informado: se consideran todos de SCA)


### manual_test_2-1. Alta - Cabecera wAutemis
- prioridad: 2-Medium · tipo: Functional · descripción: Cabecera wAutemis · condiciones de datos: Póliza wAutemis vigente y sin solicitud en curso.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo wAutemis que no esté anulada
  1. Comprobamos que redirige y carga la pantalla de alta de forma correspondiente
  1. Muestra todos los datos de cabecera de forma correcta

### manual_test_2-2. Alta - Motivo Detalle Causa
- prioridad: 2-Medium · tipo: Functional · descripción:  Motivo Detalle Causa · condiciones de datos: Póliza válida; combinaciones activas de Motivo, Detalle y Causa.
- Pasos:
  1. Entramos en el caso de prueba 1 con pantalla de alta cargada de forma correcta
  1. Seleccionamos motivo y comprobamos que se rellena el desplegable de Detalle correctamente
  1. Seleccionamos un Detalle y comprobamos que rellena las causas de forma correcta
  1. Seleccinonamos Causa y comprobamos que carga catalogaciones de forma correcta

### manual_test_2-3. Alta - Catalogaciones
- prioridad: 2-Medium · tipo: Functional · descripción: Catalogaciones · condiciones de datos: Póliza válida; causa con varias catalogaciones.
- Pasos:
  1. En el caso de prueba 2, al seleccionar una causa rellana el listado de catalogaciones
  1. Seleccionamos catalogación y comprobamos que se rellena la fecha de anulación y habilita o no el calendario según el caso
  1. En esta prueba seria conveniente comprobar las diferentes catalogaciones

### manual_test_2-4. Alta - Compañía aseguradora
- prioridad: 2-Medium · tipo: Functional · descripción: Compañía aseguradora · condiciones de datos: Póliza válida; compañía contraria activa.
- Pasos:
  1. Con la pantalla de alta cargada, seleccionamos compañía contraria
  1. Comprobamos que se selecciona de forma correcta y se rellena el campo descripción con lo correspondiente. Al dar de alta guarda el dato de forma correcta

### manual_test_2-5. Alta - Validación campos obligatorios
- prioridad: 2-Medium · tipo: Functional · descripción: Validación campos obligatorios · condiciones de datos: Póliza válida; un campo obligatorio vacío en cada ejecución.
- Pasos:
  1. En la pantalla de alta. Rellenamos todos los datos obligatorios menos uno y pulsamos Guardar
  1. Comprobamos que aparece el aviso de campo obligatorio sin rellenar

### manual_test_2-6. Alta - Guardar Contra Anulación
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación · condiciones de datos: Póliza apta para Contra Anulación; causa Me ha subido mucho la prima.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a contra anulación  (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de contra anulación

### manual_test_2-7. Alta - Guadar Acción Administrativa
- prioridad: 2-Medium · tipo: Functional · descripción: Alta - Guadar Acción Administrativa · condiciones de datos: Póliza apta para Acción Administrativa; causa Baja Vehículo.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de acciones administrativas

### manual_test_2-8. Alta - Guardar Autorización
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Autorización · condiciones de datos: Póliza que requiera Autorización; causa Anulación fuera de norma.
- Pasos:
  1. En la pantalla de alta. Rellenamos motivo-detalle-causa que derive a Autorización (Decisión de la entidad- Decisión de la entidad - Anulación Fuera de norma) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de Autorizaciones tras mostrar mensaje de aviso correspondiente

### manual_test_2-9. Alta - Guardar Mecanización directa
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Mecanización directa · condiciones de datos: Póliza apta para mecanización directa o flota wAutemis.
- Pasos:
  1. Entramos a la pantalla de alta con usuario perfil y póliza que salte a mecanización directa. Rellenamos motivo-detalle-causa que salte a mecanización directa.
  1. Pulsamos botón guardar
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla Mecanización mostrando la pantalla de simulación correspondiente

### manual_test_2-10. Alta - Cabecera NSE Autos
- prioridad: 2-Medium · tipo: Functional · descripción: Cabecera NSE Autos · condiciones de datos: Póliza NSE Autos vigente y sin solicitud en curso.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo NSE autos en vigor sin solicitud en curso
  1. Comprobamos que redirige y carga la pantalla de alta de forma correspondiente
  1. Muestra todos los datos de cabecera de forma correcta

### manual_test_2-11. Alta - Cabecera NSE Hogar
- prioridad: 2-Medium · tipo: Functional · descripción: Cabecera NSE Hogar · condiciones de datos: Póliza NSE Hogar vigente y sin solicitud en curso.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo NSE Hogar en vigor sin solicitud en curso
  1. Comprobamos que redirige y carga la pantalla de alta de forma correspondiente
  1. Muestra todos los datos de cabecera de forma correcta

### manual_test_2-12. Alta - Validación fecha de anulación con póliza con siniestros en la anualidad
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha de anulación con póliza con siniestros en la anualidad · condiciones de datos: Póliza con siniestro en la anualidad; usuario distinto de CCC/CCR.
- Pasos:
  1. Entramos a pantalla de alta con póliza que tenga siniestros en la anualidad en curso y perfil distinto a CCC o CCR
  1. Rellenamos datos obligatorios y catalogación A fecha. Pulsamos botón guardar
  1. Validara que la fecha de anulación introducida en la catalogación de la solicitud es estríctamente superior a la fecha de último siniestro existente en la póliza en la anualidad
  1. Si no es el caso mostrará modal de aviso indicandolo. Comprobar que muestra modal con el aviso correcto si fuera el caso

### manual_test_2-13. Alta - Validación fecha anulación. No realizar validaciones para subperfiles CCC y CCR.
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha anulación. No realizar validaciones para subperfiles CCC y CCR. · condiciones de datos: Póliza válida para el caso.
- Pasos:
  1. Entramos a pantalla de alta con póliza que tenga siniestros en la anualidad en curso y perfil CCC o CCR
  1. Rellenamos datos obligatorios y catalogación A fecha. Pulsamos botón guardar
  1. No realizará las validaciones de fecha y no mostrará aviso correspondiente por tratarse de subperfiles CCC o CCR

### manual_test_2-14. Alta - Validación fecha anulación mayor fecha vencimiento
- prioridad: 2-Medium · tipo: Functional · condiciones de datos: Póliza con fecha de anulación posterior al vencimiento; usuario distinto de CCC/CCR.
- Pasos:
  1. Entramos a la pantalla de alta con usuario distinto de subperfil CCC o CCR. Rellenamos datos obligatorios y ponemos fecha de anulación mayor a la de vencimiento de la póliza.  Pulsamos botón guardar
  1. Validará que la fecha introducida sea mayor que la de vencimiento de la póliza y mostrará mensaje de aviso, no dejando continuar.

### manual_test_2-15. Alta - Validación fecha anulación mayor fecha vencimiento. No realizar validaciones para CCC y CCR
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha anulación mayor fecha vencimiento. No realizar validaciones para CCC y CCR · condiciones de datos: Póliza con fecha de anulación posterior al vencimiento; usuario CCC o CCR.
- Pasos:
  1. Entramos a la pantalla de alta con usuario de subperfil CCC o CCR. Rellenamos datos obligatorios y ponemos fecha de anulación mayor a la de vencimiento de la póliza.  Pulsamos botón guardar
  1. No realizará las validaciones de fecha y no mostrará aviso correspondiente por tratarse de subperfiles CCC o CCR

### manual_test_2-16. Alta - Mas Movil
- prioridad: 2-Medium · tipo: Functional · descripción: Mas Movil · condiciones de datos: Póliza MásMóvil sin siniestros en la anualidad.
- Pasos:
  1. Entramos a la pantalla de alta con una póliza de tipo Mas Movil sin siniestros en la anualidad en curso
  1. Rellenamos datos del alta con detalle Precio y Causa Me ha subido mucho la prima
  1. Observamos que en la catalogación aparece A Vencimiento Trimestral y en la caja de fecha el primer día del trimestre siguiente según las fechas de la anualidad sin posibilidad de editarlo

### manual_test_2-17. Alta - Guardar Contra Anulación paso experto No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación paso experto No · condiciones de datos: Póliza susceptible de paso a experto; usuario SI24 Información general; respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con usuario perfil SI24 informacion general y póliza susceptible de paso a experto. Rellenamos motivo-detalle-causa que derive a contra anulación  (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si se queire pasar la solicitud de anulación al grupo de expertos y los botones Si y No
  1. Pulsamos botón  No
  1. Comprobamos que se guarda de forma correcta el valor correspondiente en anula_expertos y redirige a la pantalla de contra anulación

### manual_test_2-18. Alta - Guardar Contra Anulación paso experto Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación paso experto Si · condiciones de datos: Póliza susceptible de paso a experto; usuario SI24 Información general; respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con usuario perfil SI24 informacion general y póliza susceptible de paso a experto. Rellenamos motivo-detalle-causa que derive a contra anulación  (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si se queire pasar la solicitud de anulación al grupo de expertos y los botones Si y No
  1. Pulsamos botón  Si
  1. Comprobamos que aparcen los siguientes modales para introducir teléfono del cliente
  1. Comprobamos que se guarda de forma correcta el valor correspondiente en anula_expertos y redirige a la pantalla de contra anulación

### manual_test_2-19. Alta - Guardar Acción Administrativa telematica telefonica No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa telematica telefonica No · condiciones de datos: Póliza de origen telemática telefónica; respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de origen telematica telefonica. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal de aviso preguntando si el cliente insiste en que se anule por este canal y los botones Si y No
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de acciones administrativas
  1. Pulso botón No
  1. Compruebo que se guarda en valor false en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test_2-20. Alta - Guardar Acción Administrativa telematica telefonica Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa telematica telefonica Sí · condiciones de datos: Póliza de origen telemática telefónica; respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de origen telematica telefonica. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal de aviso preguntando si el cliente insiste en que se anule por este canal y los botones Si y No
  1. Comprobamos que se guarda de forma correcta y redirige a la pantalla de acciones administrativas
  1. Pulso botón Sí
  1. Compruebo que se guarda en valor true en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test_2-21. Alta - Guardar Acción Administrativa acuerdo especial Botón No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa acuerdo especial Botón No · condiciones de datos: Póliza de acuerdo especial Ibericar; canal productor Corredor (4); respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de acuerdo especial tipo Ibericar. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo), canal productor corredor (4) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente avisando de que la póliza es de un acuerdo especial y preguntando si el cliente insiste en que se anule por este canal. Y los botones Si y No
  1. Pulso botón No
  1. Compruebo que se guarda en valor false en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test_2-22. Alta - Guardar Acción Administrativa acuerdo especial Botón Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Acción Administrativa acuerdo especial Botón Sí · condiciones de datos: Póliza de acuerdo especial Ibericar; canal productor Corredor (4); respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con una póliza de acuerdo especial tipo Ibericar. Rellenamos motivo-detalle-causa que derive a Acción administrativa (Desaparición del riesgo - Baja de vehiculo - Baja Vehículo), canal productor corredor (4) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente avisando de que la póliza es de un acuerdo especial y preguntando si el cliente insiste en que se anule por este canal. Y los botones Si y No
  1. Pulso botón Sí
  1. Compruebo que se guarda en valor true en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test_2-23. Alta - Guardar Contra Anulación subperfil CCC Botón No
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación subperfil CCC Botón No · condiciones de datos: Póliza apta para Contra Anulación; usuario CCC; respuesta No.
- Pasos:
  1. En la pantalla de alta entramos con usuario de subperfil CCC. Rellenamos motivo-detalle-causa que derive a Contra Anulación  (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si desa realizar contra anulación para esta solicitud
  1. Pulso botón No
  1. Compruebo que se guarda en valor false en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test_2-24. Alta - Guardar Contra Anulación subperfil CCC Botón Sí
- prioridad: 2-Medium · tipo: Functional · descripción: Guardar Contra Anulación subperfil CCC Botón Sí · condiciones de datos: Póliza apta para Contra Anulación; usuario CCC; respuesta Sí.
- Pasos:
  1. En la pantalla de alta entramos con usuario de subperfil CCC. Rellenamos motivo-detalle-causa que derive a Contra Anulación  (Decisión de cliente - precio - Me ha subido mucho la prima) y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Comprobamos que aparece el modal correspondiente preguntando si desa realizar contra anulación para esta solicitud
  1. Pulso botón Sí
  1. Compruebo que se guarda en valor true en el parámetro anula_tecnicos y se da de alta de forma correcta

### manual_test_2-25. Alta - Ilocalizado, Red Mapfre y no correspondencia
- prioridad: 2-Medium · tipo: Functional · descripción: Ilocalizado, Red Mapfre y no correspondencia · condiciones de datos: Póliza válida; usuario Red Mapfre; causa Ilocalizado; canal distinto de Correspondencia.
- Pasos:
  1. En la pantalla de alta entramos con usuario de perfil Red Mapfre, causa ilocalizado y canal de entrada distinto de correspondencia.
  1. Al rellenar esta combinación, el sistema deberá mostrar alerta de aviso en la pantalla de alta indicando que no es posible dar de alta una solicitud presencial con este medio de comunicación.

### manual_test_2-26. Alta - Ilocalizado, Red Mapfre y correspondencia
- prioridad: 2-Medium · tipo: Functional · descripción: Ilocalizado, Red Mapfre y correspondencia · condiciones de datos: Póliza válida; usuario Red Mapfre; causa Ilocalizado; canal Correspondencia.
- Pasos:
  1. En la pantalla de alta entramos con usuario de perfil Red Mapfre, causa ilocalizado, canal de entrada correspondencia y resto de campos obligatorios
  1. Pulsamos botón guardar
  1. El sistema mostrará un aviso indicando al usuario que al dar de alta la solicitud con esas condiciones no se podrá imprimir la carta de anulación ni se tendra acceso al argumentario

### manual_test_2-27. Alta - Ilocalizado y canal no correspondencia ni area clientes
- prioridad: 2-Medium · tipo: Functional · descripción: Ilocalizado y canal no correspondencia ni area clientes · condiciones de datos: Póliza válida; causa Ilocalizado; canal distinto de Correspondencia y Área Clientes.
- Pasos:
  1. En la pantalla de alta causa ilocalizado y canal de entrada: distinto de correspondencia y area clientes
  1. Al rellenar esta combinación, el sistema deberá mostrar alerta de aviso en la pantalla de alta indicando que no es posible dar de alta una solicitud presencial con este medio de comunicación.

### manual_test_2-28. Alta - Si24 Corredor o Banca y solicitud misma anualidad
- prioridad: 2-Medium · tipo: Functional · descripción: Si24 Corredor o Banca y solicitud misma anualidad · condiciones de datos: Póliza con solicitud en la misma anualidad; usuario SI24 Experto; canal Corredor o Banca.
- Pasos:
  1. En la pantalla de alta entramos con usuario de subperfil SI24 experto, canal productor y póliza con solicitud en la misma anualidad. Rellenamos resto de campos obligatorios
  1. Pulsamos botón guardar
  1. Muestra mensaje arriba en la cabecera avisando de que existen solicitudes de anulación realizadas para ese cliente y póliza

### manual_test_2-29. Alta - Mensaje de error controlado simulación New, No continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación New, No continua · condiciones de datos: Póliza wAutemis con operación pendiente; simulación devuelve M201.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta contra anulación con póliza tipo wAutemis que presente una autoriación pendiente y retorne por tanto dicho error en la consulta a simulación
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo wAutemis el servicio de simulación correspondiente retorna error M201
  1. Se muestra al usuario mensaje 'Se ha detectado una operación pendiente de revisión para esta póliza. Hasta que no se apruebe o rechace la operación pendiente no es posible acutar sobre ella'. No dejará continuar y se quedará en dicha pantalla.

### manual_test_2-30. Alta - Mensaje de error controlado simulación NSE, No continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación NSE, No continua · condiciones de datos: Póliza NSE cuya simulación devuelve error, null o error SQL.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta accion administrativa con póliza tipo NSE que presente algún tipo de problema y con los datos rellenos el servicio de simulación retorne Error en la consulta.
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE el servicio de simulación correspondiente retorna error en la consulta, null o Error de tipo SQL en el acceso a las Logicas d eAcceso a Datos
  1. Se muestra al usuario mensaje 'NSE no nos está indicando el estado actual de la pólia. Por favor, compruebe la situación de la misma en NSE e inténtelo mas tarde...'. No dejará continuar y se quedará en dicha pantalla.

### manual_test_2-31. Alta - Mensaje de error controlado simulación New, Continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación New, Continua · condiciones de datos: Póliza wAutemis cuya simulación devuelve M206.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta contra anulación con póliza tipo wAutemis que en el servicio de simulación con dichos datos retorne el mensaje M206 Error al consutlar el estado de la situación de l apóliza
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo wAutemis el servicio de simulación correspondiente retorna error M206
  1. Se muestra al usuario mensaje 'New nos indica que no puede determinar el estado de la póliza. Se continúa a contra anulación, si finalmente va a anular la póliza, por favor, compruebe la situación…...'.
  1. El usuario acepta dicho modal de aviso y continua con el alta y redirige a la pantalla de contra anulación

### manual_test_2-32. Alta - Mensaje de error controlado simulación NSE, continua
- prioridad: 2-Medium · tipo: Functional · descripción: Mensaje de error controlado simulación NSE, continua · condiciones de datos: Póliza NSE cuya simulación devuelve error, null o error SQL; flujo permite continuar.
- Pasos:
  1. En la pantalla de alta rellenamos todos los campos obligatorios y damos de alta Contra Anulación con póliza tipo NSE que presente algún tipo de problema y con los datos rellenos el servicio de simulación retorne Error en la consulta.
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE el servicio de simulación correspondiente retorna error en la consulta, null o Error de tipo SQL en el acceso a las Logicas d eAcceso a Datos
  1. Se muestra al usuario mensaje 'NSE no nos está indicando el estado actual de la pólia. Por favor, compruebe la situación de la misma en NSE e inténtelo mas tarde...'.
  1. El usuario acepta dicho modal de aviso y continua con el alta y redirige a la pantalla de contra anulación

### manual_test_2-33. Alta - Excepción pólizas PRRA NSE autos
- prioridad: 2-Medium · tipo: Functional · descripción: Excepción pólizas PRRA NSE autos · condiciones de datos: Póliza PRRA NSE Autos.
- Pasos:
  1. En la pantalla de alta entro con póliza tipo PRRA NSE autos. Relleno todos los campos obligatorios para dar de alta una contra anulación
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE autos, detecta que es de tipo PRRA y muestra mensaje correspondiente al usuario modificando el motivo,detalle causa por el 3, 8 y 10 antes de realizar el guardado correspondiente y alta de la solicitud
  1. Comprobamos que se realiza el guardado de forma correta y redirige a la contra anulación de forma correcta

### manual_test_2-34. Alta - Excepción pólizas PRRA NSE Hogar
- prioridad: 2-Medium · tipo: Functional · descripción: Excepción pólizas PRRA NSE autos · condiciones de datos: Póliza PRRA NSE Hogar.
- Pasos:
  1. En la pantalla de alta entro con póliza tipo PRRA NSE Hogar. Relleno todos los campos obligatorios para dar de alta una contra anulación
  1. Pulsamos botón guardar
  1. Al simular la anulación de la póliza de tipo NSE autos, detecta que es de tipo PRRA. No mostrará ningún mensaje de aviso y dara de alta la contra anulación correspondiente pero en las invocaciones a simulación de póliza cambiara en dicha invocación el motivo-detalle causa  NSE 0013-0008-0021 correspondientes.
  1. Comprobar que se da de alta la contra anulación de forma correcta y se finaliza anulando sin problema para este tipo de póliza concreto

Casos en esta hoja: 34
