# Plan de pruebas SCA — Revision Autorizacion

Origen: `Plan_pruebas_SCA_-_Revision_Autorizacion.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test_2` (sin application_udf informado: se consideran todos de SCA)


### manual_test_2-1. Revision Autorizacion - Acceso mismo usuario
- prioridad: 2-Medium · tipo: Functional · descripción: Acceso mismo usuario
- Pasos:
  1. Entramos a la solicitud con usuario que estaba gestionando una Revisión de autorización y esta sigue en curso
  1. Comprobamos que entra a la pantalla de autorizaciones de forma correcta **[validación]**

### manual_test_2-2. Revision Autorizacion - Acceso distinto usuario
- prioridad: 2-Medium · tipo: Functional · descripción: Acceso distinto usuario
- Pasos:
  1. Entramos a la solicitud de anulación en curso que estaba parada en gestión de Revisión de Autorización con usuario de perfil distinto
  1. Coprobamos que redirige a la consulta de la solicitud en modo gestión **[validación]**

### manual_test_2-3. Revisión Autorización - Cambio Fecha anulación autorizada
- prioridad: 2-Medium · tipo: Functional · descripción: Cambio Fecha anulación autorizada
- Pasos:
  1. Entramos a la pantalla de Autorizaciones y modificamos fecha de anulación autorizada
  1. Finalizamos y revisamos que se modifica de forma correcta la fecha de anulación
  1. Se manda a anular y se comprueba que anula a la fecha correcta **[validación]**

### manual_test_2-4. Revisión Autorización - Validación fecha anulación mayor fecha vencimiento
- prioridad: 2-Medium · tipo: Functional · descripción: Validación fecha anulación mayor fecha vencimiento
- Pasos:
  1. Entramos a la pantalla de Autorizaciones y modificamos fecha de anulación autorizada poniendo una mayor que la de vencimiento de la póliza
  1. Finalizamos y comprobamos que muestra mensaje de error 'La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza' **[validación]**

### manual_test_2-5. Revisión Autorización - Comprobación fecha informada
- prioridad: 2-Medium · tipo: Functional · descripción: Comprobación fecha informada
- Pasos:
  1. Entramos a la pantalla de Autorizaciones y dejamos la fecha sin informar
  1. Finalizamos y comprobamos que muestra mensaje de error “Debe seleccionar si autoriza o deniega la revisión de la fecha de autorización **[validación]**

### manual_test_2-6. Revision Autorizacion - Mas Movil
- prioridad: 2-Medium · tipo: Functional · descripción: Mas Movil
- Pasos:
  1. Entramos a la pantalla de Revisión de autorización con póliza tipo Mas Movil y catalogación A vencimiento Trimestral con origen FDC
  1. Comprobamos que aparece el desplegable de catalogación con A Vencimiento trimestral. No permite cambiar la fecha de anulación generada y esta pertenece al primer día del trimestre siguiente de la anualidad contratrada
  1. Finalizar anulación en curso y comprobar que se realiza la anulación de forma correcta **[validación]**

### manual_test_2-7. Revisión Autorización - Adjuntar documentos
- prioridad: 2-Medium · tipo: Functional · descripción: Adjuntar documentos
- Pasos:
  1. Entramos a la pantalla de Autorizaciones y pulsamos botón para adjuntar documentos
  1. Adjuntamos documento de uno de los tipos que aparecen.
  1. Comprobamos que el documento se adjunta correctamente y se puede visualizar **[validación]**

### manual_test_2-8. Revisión Autorización - Eliminar documento
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminar documento
- Pasos:
  1. Entramos a la pantalla de Autorización  con documentos adjuntos y pulsamos botón para adjuntar documentos
  1. Seleccionamos un documento adjunto y pulsamos en Eliminar
  1. Comprobamos que el documento se elimina de forma correcta y se actualiza en el listado correspondiente **[validación]**

### manual_test_2-9. Revisión Autorización - Modificar documento
- prioridad: 2-Medium · tipo: Functional · descripción: Modificar documento
- Pasos:
  1. Entramos a la pantalla de  Autorización con póliza que tenga un documento adjunto. Pulsamos en botón Adjuntar Documento
  1. Nos muestra modal con documentos adjuntos. Adjuntamos un documento distinto a uno de los tipos adjuntados
  1. Comprobamos que se adjunta de forma correcta y se muestra en el listado correspondiente de la cabecera pudiendose visualizar **[validación]**

### manual_test_2-10. Revisión Autorización – DNI como documento
- prioridad: 2-Medium · tipo: Functional · descripción: DNI
- Pasos:
  1. Entramos a la pantalla de Autorizaciones y pulsamos botón para adjuntar documentos
  1. Comprobamos que existe el DNI como posible documento **[validación]**

### manual_test_2-11. Revisión Autorización - Posponer una oficina
- prioridad: 2-Medium · tipo: Functional · descripción: Posponer una oficina
- Pasos:
  1. Entro a la pantalla de Autorización con usuario perfil Red Mapfre y una sola oficina
  1. Pulso botón Posponer
  1. Compruebo que se han guardado los cambios y se ha generado altaSGC de forma correcta **[validación]**

### manual_test_2-12. Revisión Autorización - Posponer mas de una oficina
- prioridad: 2-Medium · tipo: Functional · descripción: Posponer mas de una oficina
- Pasos:
  1. Entro a la pantalla de Autorización con usuario perfil Red Mapfre y que tenga mas de una oficina
  1. Pulso botón Posponer y me muestra listado de oficinas a seleccionar. Selecciono una y acepto. Continua.
  1. Compruebo que se han guardado los cambios y se ha generado altaSGC de forma correcta **[validación]**

### manual_test_2-13. Revisión Autorización  - Cancelar
- prioridad: 2-Medium · tipo: Functional · descripción: Cancelar
- Pasos:
  1. Entramos a la pantalla de Autorización con las condiciones necesarias para que aparezca el botón Cancelar
  1. Pulsamos botón Cancelar. Nos avisa de que se va a cancelar la solicitud de anulación. Pulsamos en Si
  1. Finaliza la gestión y solicitud de anulación con el estado cancelada
  1. Comprobamos que ha finalizado y se ha cancelado de forma correcta **[validación]**

### manual_test_2-14. Revisión Autorización – Finalizar con plan de pagos
- prioridad: 2-Medium · tipo: Functional · descripción: Finalizar con un plan de pagos
- Pasos:
  1. Entro a la pantalla de Autorización con usuario perfil Red Mapfre y una póliza en plan de pagos
  1. Después de las acciones pertinentes finalizamos
  1. El sistema advierte que no es posible seguir adelante mientras la póliza esté dentro de un plan de pagos y es pertinente sacarla para poder seguir con la anulación por autorización. **[validación]**

Casos en esta hoja: 14
