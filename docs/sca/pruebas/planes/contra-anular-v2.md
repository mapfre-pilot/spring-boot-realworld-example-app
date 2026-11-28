# Plan de pruebas SCA — Contra Anular v2

Origen: `Plan_pruebas_SCA_-_Contra_Anular_v2.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test_2` (sin application_udf informado: se consideran todos de SCA)


### manual_test_2-1. Contra Anular - Acceso mismo usuario
- prioridad: 2-Medium · tipo: Functional · descripción:  Acceso usuario que dio el alta
- Pasos:
  1. Entramos a la solicitud con usuario que estaba gestionando la contra anulación en curso
  1. Comprobamos entra a la contra anulación y carga la pantalla de forma correcta

### manual_test_2-2. Contra Anular - Acceso distinto usuario
- prioridad: 2-Medium · tipo: Functional · descripción:  Acceso distinto usuario
- Pasos:
  1. Entramos a la solicitud de anulación en curso que estaba parada en gestión de contra anulación con usuario de perfil distinto
  1. Coprobamos que redirige a la consulta de la solicitud en modo gestión

### manual_test_2-3. Contra Anular - Cambio catalogación y fecha
- prioridad: 2-Medium · tipo: Functional · descripción: Cambio catalogación y fecha
- Pasos:
  1. Entro a la pantalla de contra anulación  y usuario perfil Red Mapfre
  1. Compruebo que aparece la posibilidad de modificar la catalogación y fecha de anulación
  1. Modifico catalogación y fecha de anulación y al finalizar contra anulación compruebo que se guardan y actualizan de forma correcta

### manual_test_2-4. Contra Anular - Compañía contraria
- prioridad: 2-Medium · tipo: Functional · descripción: Compañía contraria
- Pasos:
  1. Entro a la pantala de contra anulación con usuario Red Mapfre
  1. Compruebo que da opción a elegir compañía contraria y si la hemos informado en el alta aparece rellena con el valor correspondiente.
  1. Selecciono compañía contraria. Pulso botón posponer y compruebo que guarda el dato de forma correcta

### manual_test_2-5. Contra Anular – Recarga Argumentario
- prioridad: 2-Medium · tipo: Functional · descripción: Recarga Argumentario
- Pasos:
  1. Entramos a la pantalla de contra anulación y comprobamos que carga el argumentario de forma correcta
  1. Inactivamos uno de los argumentos y pulsamos en la recarga de argumentos y comprobamos que se actualizan correctamente.

### manual_test_2-6. Contra Anular – Orden,prioridad y activos. Argumentario
- prioridad: 2-Medium · tipo: Functional · descripción: Orden,prioridad y activos. Argumentario
- Pasos:
  1. Entramos a la pantalla de contra anulación y comprobamos que carga el argumentario de forma correcta
  1. Comprobamos que salen en el orden establecido por reglas según prioridad, así como que no salen aquellos argumentos devueltos por reglas que están inactivos

### manual_test_2-7. Contra Anular - Ver pdf y aplicación de argumento
- prioridad: 2-Medium · tipo: Functional · descripción: Ver pdf y aplicación de argumento
- Pasos:
  1. Entramos a la pantalla de contra anulación
  1. Pulsamos en el icono de visualización de PDF de alguno de los argumentos activos y compruebo que se abre pdf y se visualiza de forma correcta
  1. Pulso icono de aplicación de alguno de los argumentos activos que tenga enlace y compruebo que se abre nueva ventana y carga la url de forma correcta

### manual_test_2-8. Contra Anular - Argumentos obligatorios
- prioridad: 2-Medium · tipo: Functional · descripción: Argumentos obligatorios
- Pasos:
  1. Entro a la pantalla de contra anulación con una solicitud que no tenga argumentos obligatorios ejecutados
  1. Compruebo que en los argumentos no obligatorios no esta activa la opción de ver pdf, aplicación ni botón positivo o negativo
  1. Pulso finalizar sin haber ejecutado todos los argumentos obligatorios
  1. Salta aviso indicando la finalización de los argumentos obligatorios

### manual_test_2-9. Contra Anular - Fin positivo
- prioridad: 2-Medium · tipo: Functional · descripción: Fin positivo
- Pasos:
  1. En la pantalla de contra anulación pulsamos en argumento y fin positivo
  1. Muestra aviso de finalización correspondiente y finaliza gestión y solicitud de forma correcta

### manual_test_2-10. Contra Anular - Fin positivo argumento TTQ
- prioridad: 2-Medium · tipo: Functional · descripción:  Fin positivo argumento TTQ
- Pasos:
  1. En la pantalla de contra anulación selecciono argumento tipo TTQ y finalizo positivo
  1. Muestra modal con TTQs a asignar. Asigno TTQs  en exceso o en defecto para probar mensajes)
  1. Cancelo para comprobar que regreso a pantalla de contra anulación y vuelvo a seleccionar TTQ para ver modal. Asigno Tréboles y finalizo.
  1. Muestra modales de aviso correspondientes y finaliza gestión y solicitud en curso asignando los TTQ de forma correta
  1. Compruebo que se han asignado los TTQ de forma correcta y se han registrado en BD correctamente.
  1. Compruebo que se ha finalizado la gestión de contra anulación y solicitud de forma correcta **[validación]**

### manual_test_2-11. Contra Anular - Fin positivo argumento PREMFIDE
- prioridad: 2-Medium · tipo: Functional · descripción: Fin positivo argumento PREMFIDE
- Pasos:
  1. Comprobamos que la descripción del argumento de PREMFIDE tiene concatenado de forma correcta el número de tréboles.
  1. Entro a una contra anulación que ofrezca argumento PREMFIDE. Selecciono argumento PREMFIDE y finalizo positivo
  1. Muestra modal con TTQs a asignar. Asigno TTQs y finalizo
  1. Muestra modales de aviso correspondientes y finaliza gestión y solicitud en curso asignando los TTQ de forma correta
  1. Compruebo que se han asignado los TTQ de forma correcta y se han registrado en BD correctamente.
  1. Compruebo que se ha finalizado la gestión de contra anulación y solicitud de forma correcta

### manual_test_2-12. Contra Anular - Fin positivo argumento RETOS
- prioridad: 2-Medium · tipo: Functional · descripción: Fin positivo argumento RETOS
- Pasos:
  1. Comprobamos que la descripción del argumento de RETOS tiene concatenado de forma correcta el número de tréboles.
  1. Entro a una contra anulación que ofrezca argumento RETOS. Selecciono argumento RETOS y finalizo positivo
  1. Muestra modal con TTQs a asignar. Asigno TTQs y finalizo
  1. Muestra modales de aviso correspondientes y finaliza gestión y solicitud en curso asignando los TTQ de forma correta
  1. Compruebo que se han asignado los TTQ de forma correcta y se han registrado en BD correctamente.
  1. Compruebo que se ha finalizado la gestión de contra anulación y solicitud de forma correcta

### manual_test_2-13. Contra Anular - Fin positivo argumento SVA
- prioridad: 2-Medium · tipo: Functional · descripción:  Fin positivo argumento SVA
- Pasos:
  1. En la pantalla de contra anulación selecciono argumento tipo Regalo Servicio Valor añadido
  1. Muestra modal con con regalos para asignar. Selecciono un regalo y muestra pantalla de correo, modifico el correo y compruebo que se ha cambiando en RIC
  1. Cancelo para comprobar que regreso a pantalla de contra anulación y vuelvo a seleccionar SVA  para ver modal. Asigno regalos y finalizo.
  1. Muestra modales de aviso correspondientes y finaliza gestión y solicitud en curso asignando los SVA de forma correta
  1. Compruebo que se han asignado los SVA de forma correcta y se han registrado en BD correctamente.
  1. Compruebo que se ha finalizado la gestión de contra anulación y solicitud de forma correcta **[validación]**

### manual_test_2-14. Contra Anular – Pérdida de Descuento
- prioridad: 2-Medium · tipo: Functional · descripción:  Fin positivo argumento SVA
- Pasos:
  1. En la pantalla de contra anulación selecciono argumento tipo Perdida de descuento
  1. En el icono de acceso a aplicación (habichuela) hago click
  1. Aparece una pantalla que me permite ver las diferencias de descuentos de la anualidad pasada con la actual **[validación]**

### manual_test_2-15. Contra Anular - Ejecutar argumento negativo
- prioridad: 2-Medium · tipo: Functional · descripción: Ejecutar argumento negativo
- Pasos:
  1. Entro a la pantalla de contra anulación. Selecciono argumento y ejecuto Negativo
  1. Compruebo que se actualiza correctamente la ejecución negativa de dicho argumento

### manual_test_2-16. Contra Anular - Finaliza negativo Red Mapfre
- prioridad: 2-Medium · tipo: Functional · descripción: Finaliza negativo Red Mapfre
- Pasos:
  1. Entramos a la pantalla de contra anulación con usuario perfil Red Mapfre
  1. Ejecutamos argumentos obligatorios y pulsamos botón Finalizar
  1. Advierte de la finalización y finaliza gestión de contra anulación
  1. Observamos que finaliza la gestión de contra anulación de forma correcta y redirige a otro nivel de contra anulación o mecanización según sea el caso

### manual_test_2-17. Contra Anular - Paso a experto
- prioridad: 2-Medium · tipo: Functional · descripción:  Paso a experto
- Pasos:
  1. Entramos a pantalla de contra anulación con póliza telemática o telefónica y usuario del grupo Si24 Información general o Si24 Expertos en retención
  1. Al finalizar contra anulación negativa. Mensaje de aviso para póliza telemática y el valor de paso_expertos es falso. Se muestra un mensaje de aviso indicando la posibilidad de que el cliente quiera anular por el canal telefónico.
  1. El sistema muestra el mensaje de aviso "Esta póliza es de origen telemático o telefónico, ¿El cliente insiste en que se anule su póliza por este canal?" se contesta Sí
  1. Almacenar el valor de anula_tecnicos en el sistema y la contra anulación finaliza.

### manual_test_2-18. Contra Anular – Paso expertos Bankia
- prioridad: 2-Medium · tipo: Functional · descripción:  Paso a experto
- Pasos:
  1. Entramos a pantalla de contra anulación con póliza telemática o telefónica y usuario del grupo Si24 Información general o Si24 Expertos en retención con poliza Ford o Bankia

### manual_test_2-19. Contra Anular – Paso expertos Corredores
- prioridad: 2-Medium · tipo: Functional · descripción:  Paso a experto
- Pasos:
  1. Entramos a pantalla de contra anulación con póliza telemática o telefónica y usuario del grupo Si24 Información general o Si24 Expertos en retención con poliza de corredor (canal  4 ó 5 )
  1. Al finalizar contra anulación negativa,  aparece un mensaje indicando que el cliente tiene que dirigirse a su oficina para anular la póliza.

### manual_test_2-20. Contra Anular - Posponer una oficina
- prioridad: 2-Medium · tipo: Functional · descripción: Posponer una oficina
- Pasos:
  1. Entro a la pantalla de contra anulación con usuario perfil Red Mapfre y una sola oficina
  1. Pulso botón Posponer
  1. Compruebo que se han guardado los cambios y se ha generado altaSGC de forma correcta

### manual_test_2-21. Contra Anular - Posponer mas de una oficina
- prioridad: 2-Medium · tipo: Functional · descripción: Posponer mas de una oficina
- Pasos:
  1. Entro a la pantalla de contra anulación con usuario perfil Red Mapfre y que tenga mas de una oficina
  1. Pulso botón Posponer y me muestra listado de oficinas a seleccionar. Selecciono una y acepto. Continua.
  1. Compruebo que se han guardado los cambios y se ha generado altaSGC de forma correcta

### manual_test_2-22. Contra Anular - Posponer sin contacto. Ilocalizado
- prioridad: 2-Medium · tipo: Functional · descripción: Posponer sin contacto
- Pasos:
  1. Entramos a la pantalla de contra anulación con usuario perfil SI24
  1. Pulsamos botón posponer y muestra mensaja preguntando si se ha podido contactar con el cliente
  1. Pulso en No y guarda y cierra ventana
  1. Entramos de nuevo y realizamos la misma acción.
  1. A la tercera vez que le damos indicando que no se ha podido contactar con el cliente muestra modal de aviso y finaliza la gestión de contra anulación en curso y solicitud con estado finalizado Ilocalizable sin contacto.

### manual_test_2-23. Contra Anular - Imprimir Red Mapfre
- prioridad: 2-Medium · tipo: Functional · descripción:  Imprimir Red Mapfre
- Pasos:
  1. Entro a la pantalla de contra anulación con usuario perfil Red Mapfre
  1. Compruebo que aparece el botón de impresión activo y lo pulso
  1. Compruebo que se imprimi la carta de anulación de forma correcta y se actualiza la fecha de impresión correspondiente

### manual_test_2-24. Contra Anular - Imprimir SI24
- prioridad: 2-Medium · tipo: Functional · descripción: Imprimir SI24
- Pasos:
  1. Entro a la pantalla de contra anulación con usuario perfil SI24
  1. Compruebo que no aparece activado el boton de Imprimir

### manual_test_2-25. Contra Anular - Botón Cancelar. No
- prioridad: 2-Medium · tipo: Functional · descripción: Botón Cancelar. No
- Pasos:
  1. Entramos a la pantalla de contra anulación con usuario Red Mapfre nivel 1.
  1. Con este usuario y nivel ha de mostrar botón cancelar. Comprobamos que se muestra y lo pulsamos.
  1. Muestra modal de aviso de la cancelación de la solicitud en curso
  1. Pulsamos cancelar y cierra modal y no hace nada.

### manual_test_2-26. Contra Anular - Botón Cancelar. Sí
- prioridad: 2-Medium · tipo: Functional · descripción:  Botón Cancelar. Sí
- Pasos:
  1. Entramos a la pantalla de contra anulación con usuario Red Mapfre nivel 1.
  1. Con este usuario y nivel ha de mostrar botón cancelar. Comprobamos que se muestra y lo pulsamos.
  1. Muestra modal de aviso de la cancelación de la solicitud en curso. Aceptamos la cancelación
  1. Comprobamos que finaliza la gestión y solicitud en curso con el estado cancelada correspondiente

### manual_test_2-27. Contra Anular - Adjuntar documento
- prioridad: 2-Medium · tipo: Functional · descripción:  Adjuntar documento
- Pasos:
  1. Entramos a la pantalla de contra anulación y pulsamos en botón Adjuntar Documento
  1. Nos muestra modal para adjuntar documento. Adjuntamos un documento y cerramos
  1. Comprobamos que se adjunta de forma correcta y se muestra en el listado correspondiente de la cabecera pudiendose visualizar

### manual_test_2-28. Contra Anular - Modificar documento
- prioridad: 2-Medium · tipo: Functional · descripción: Modificar documento
- Pasos:
  1. Entramos a la pantalla de contra anulación con póliza que tenga un documento adjunto. Pulsamos en botón Adjuntar Documento
  1. Nos muestra modal con documentos adjuntos. Adjuntamos un documento distinto a uno de los tipos adjuntados
  1. Comprobamos que se adjunta de forma correcta y se muestra en el listado correspondiente de la cabecera pudiendose visualizar

### manual_test_2-29. Contra Anular - Eliminar documento
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminar documento
- Pasos:
  1. Entramos a la pantalla de contra anulación con póliza que tenga un documento adjunto. Pulsamos en botón Adjuntar Documento
  1. Nos muestra modal con documentos adjuntos. Borramos documento adjunto.
  1. Comprobamos que se ha borrado el documento de forma correcta

### manual_test_2-30. Contra Anular – Campo observaciones
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminar documento
- Pasos:
  1. Entramos a la pantalla de contra anulación. Añadimos observaciones y posponemos
  1. Recuperamos la solicitud y comprobamos que no podemos modificar la observación anterior **[validación]**

### manual_test_2-31. Contra Anular – Obligatoriedad DNI Red Mapfre
- prioridad: 2-Medium · tipo: Functional · descripción: Obligatoriedad DNI
- Pasos:
  1. En la configuración de SCA se ha marcado DNI como obligatorio
  1. Entramos en pantalla de contra anulación con RED Mapfre y finalizamos negativo. **[validación]**
  1. No es posible continuar con la finalización si no adjuntamos el DNI, el sistema nos avisa y solo al adjuntarlo nos permite continuar **[validación]**

### manual_test_2-32. Contra Anular – Obligatoriedad DNI SI24
- prioridad: 2-Medium · tipo: Functional · descripción: Obligatoriedad DNI
- Pasos:
  1. En la configuración de SCA se ha marcado DNI como obligatorio
  1. Entramos en pantalla de contra anulación con SI24 y finalizamos negativo. **[validación]**
  1. Es posible continuar con la finalización si no adjuntamos el DNI, el sistema nos permite terminar sin dar el aviso, solo un mensaje de advertencia. **[validación]**

### manual_test_2-33. Contra Anular - Mas Movil
- prioridad: 2-Medium · tipo: Functional · descripción: Mas Movil
- Pasos:
  1. Entramos a la pantalla de contra anulación con un alta de póliza tipo Mas Movil y catalogación A vencimiento Trimestral
  1. Comprobamos que aparece el desplegable de catalogación con A Vencimiento trimestral. No permite cambiar la fecha de anulación generada y esta pertenece al primer día del trimestre siguiente de la anualidad contratrada
  1. Finalizar contra anulación en curso y comprobar que se realiza la anulación de forma correcta

### manual_test_2-34. Contra Anular - Inducción Verti
- prioridad: 2-Medium · tipo: Functional · descripción: Inducción Verti
- Pasos:
  1. Entramos a pantalla de contra anulación con póliza que sea susceptible de inducir a Verti
  1. Finalizamos contra anulación negativa y comprobamos que salte el modal de inducción a Verti
  1. Continuamos con la secuencia de inducción a Verti y revisamos que se realiza de forma correcta
  1. Despues de finalizar la contra anulación. Finalizamos la solicitud de anulación correspondiente habiendo inducido a Verti y comprobamos que finaliza de forma correcta y registra dicha inducción

### manual_test_2-35. Contra Anular - Generar Contacto
- prioridad: 2-Medium · tipo: Functional · descripción: Generar Contacto
- Pasos:
  1. Entramos a pantalla de contra anulación con póliza que sea susceptible de Generar contacto Vencimiento
  1. Finalizamos contra anulación negativa y comprobamos que salte el modal de inducción a Generación de Contacto Vencimiento
  1. Continuamos con la secuencia correspondiente marcando check de generación contacto Vencimiento
  1. Despues de finalizar la contra anulación. Finalizamos la solicitud de anulación correspondiente habiendo inducido a Contacto Vencimiento y comprobamos que se registra de forma correcta.

Casos en esta hoja: 35
