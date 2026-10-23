# Plan de pruebas SCA — Acciones Administrativas

Origen: `Plan_pruebas_SCA_-_Acciones_Administrativas.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test_2` (sin application_udf informado: se consideran todos de SCA)


### manual_test_2-1. Acciones Administrativas - Acceso mismo usuario
- prioridad: 2-Medium · tipo: Functional · descripción: Acceso mismo usuario
- Pasos:
  1. Entramos a la solicitud con usuario que estaba gestionando una acción administrativa y esta sigue en curso
  1. Comprobamos que entra a la acción administrativa de forma correcta

### manual_test_2-2. Acciones Administrativas - Acceso distinto usuario
- prioridad: 2-Medium · tipo: Functional · descripción: Acceso distinto usuario
- Pasos:
  1. Entramos a la solicitud de anulación en curso que estaba parada en gestión de acción administrativa con usuario de perfil distinto
  1. Coprobamos que redirige a la consulta de la solicitud en modo gestión

### manual_test_2-3. Acciones Administrativas - Catalogación
- prioridad: 2-Medium · tipo: Functional · descripción: Catalogación
- Pasos:
  1. Entramos a la pantalla de Acciones Administrativas con origen FDC y Red Mapfre
  1. Comprobamos que aparece la opción para modificar la catalogación y fecha de anulación en caso necesario
  1. Modificamos catalogación y/o fecha y comprobamos que se realiza la validación de fechas necesaria y se guardan los cambios de forma correcta

### manual_test_2-4. Acciones Administrativas - Mas Movil
- prioridad: 2-Medium · tipo: Functional · descripción: Mas Movil
- Pasos:
  1. Entramos a la pantalla de Acciones Administrativas con póliza tipo Mas Movil y catalogación A vencimiento Trimestral con origen FDC
  1. Comprobamos que aparece el desplegable de catalogación con A Vencimiento con impago. No permite cambiar la fecha de anulación generada y esta pertenece al primer día del trimestre siguiente de la anualidad contratrada
  1. Finalizar anulación en curso y comprobar que se realiza la anulación de forma correcta

### manual_test_2-5. Acciones Administrativas - Validaciones Fecha
- prioridad: 2-Medium · tipo: Functional · descripción: Validaciones Fecha
- Pasos:
  1. Entramos a la pantalla de Acciones Administrativas con usuario de subperfil distinto de CCC o CCR, catalogación a fecha y con opción de mostrar fecha y catalogación para opción a cambio.
  1. Rellenamos fecha de anulación mayor a la de vencimiento y catalogación a fecha
  1. Validará que la fecha introducida sea mayor que la de vencimiento de la póliza y mostrará mensaje de aviso indicandolo y no dejando continuar.

### manual_test_2-6. Acciones Administrativas - Validaciones Documentos
- prioridad: 2-Medium · tipo: Unit · descripción: Validaciones documentos
- Pasos:
  1. Entramos a la pantalla de Acciones Administrativas desde Autos y Hogar y diversos causas
  1. Comprobamos que salen los documentos que tocan en cada momento. **[validación]**

### manual_test_2-7. Acciones Administrativas - Adjuntar documentos
- prioridad: 2-Medium · tipo: Functional · descripción: Adjuntar documentos
- Pasos:
  1. Entramos a la pantalla de acciones administrativas y pulsamos botón para adjuntar documentos
  1. Adjuntamos documento de uno de los tipos que aparecen.
  1. Comprobamos que el documento se adjunta correctamente y se puede visualizar
  1. En el listado de documentos de la acción administrativas se marca el documento adjuntado como adjunto y se actualiza de forma correcta

### manual_test_2-8. Acciones Administrativas - Eliminar documento
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminar documento
- Pasos:
  1. Entramos a la pantalla de acciones administrativas con documentos adjuntos y pulsamos botón para adjuntar documentos
  1. Seleccionamos un documento adjunto y pulsamos en Eliminar
  1. Comprobamos que el documento se elimina de forma correcta y se actualiza en el listado correspondiente

### manual_test_2-9. Acciones Administrativas – Marcar como entregado
- prioridad: 2-Medium · tipo: Functional · descripción:  Marcar como entregado
- Pasos:
  1. Entramos a la pantalla de acciones administrativas.
  1. Seleccionamos los documentos  y los marcamos como entregado sin adjuntarlo
  1. Pulsamos botón Finalizar
  1. Advierte de la finalización y guardar los cambios y finaliza la gestión de acción administrativa de forma correcta
  1. Tras decidir la siguiente acción crea la gestión de mecanización y nos redirige a dicha pantalla

### manual_test_2-10. Acciones Administrativas – Obligatoriedad DNI Red Mapfre
- prioridad: 2-Medium · tipo: Functional · descripción: Obligatoriedad DNI
- Pasos:
  1. En la configuración de SCA se ha marcado DNI como obligatorio
  1. Entramos en pantalla de Acciones administrativos con RED Mapfre
  1. Uno de los documento que aparecen como requeridos es el DNI. No es posible marcarlo como adjunto. **[validación]**
  1. No es posible continuar con la finalización si no adjuntamos el DNI, el sistema nos avisa y solo al adjuntarlo nos permite continuar **[validación]**

### manual_test_2-11. Acciones Administrativas - Imprimir
- prioridad: 2-Medium · tipo: Functional · descripción: Imprimir
- Pasos:
  1. Entramos a pantalla de Acciones administrativas con condiciones para botón Imprimir activo
  1. Comprobamos que aparece habilitado el botón de Imprimir y lo pulsamos
  1. Nos muestra el documento de solicitud de anulación a imprimir de forma correcta

### manual_test_2-12. Acciones Administrativas - Posponer
- prioridad: 2-Medium · tipo: Functional · descripción: Posponer
- Pasos:
  1. Entramos a pantalla de Acciones administrativas con condiciones para mostrar botón Posponer
  1. Pulsamos botón Posponer
  1. Guarda los cambios mostrando modal correspondiente y sale de la aplicación
  1. Comprobamos que crea la notificación correspondiente a SGC si es Red Mapfre

### manual_test_2-13. Acciones Administrativas - Finalizar No entrega Docs., Red Mapfre
- prioridad: 2-Medium · tipo: Functional · descripción: Finalizar No entrega Docs., Red Mapfre
- Pasos:
  1. Entramos a pantalla de Acciones administrativas, con usuario Red Mapfre y no habiendo impreso anteriormente
  1. Marcamos No entrega Documentación la póliza se anulará a vencimiento
  1. Muestra modal de aviso correspondiente, realiza impresión de documento y finaliza gestión de acción administrativa
  1. Comprobamos que se ha finalizado de forma correcta imprimiento el documento y modificando catalogación a vencimiento de forma correcta

### manual_test_2-14. Acciones Administrativas - Finaliza entregando documentación
- prioridad: 2-Medium · tipo: Functional · descripción: Finaliza entregando documentación
- Pasos:
  1. Entramos a pantalla de Acciones administrativas, habiendo entregado algun documento
  1. Pulsamos botón Finalizar
  1. Advierte de la finalización y guardar los cambios y finaliza la gestión de acción administrativa de forma correcta
  1. Tras decidir la siguiente acción crea la gestión de mecanización y nos redirige a dicha pantalla

### manual_test_2-15. Acciones Administrativas - Cancelar
- prioridad: 2-Medium · tipo: Functional · descripción: Cancelar
- Pasos:
  1. Entramos a la pantalla de Acciones Administrativas con las condiciones necesarias para que aparezca el botón Cancelar
  1. Pulsamos botón Cancelar. Nos avisa de que se va a cancelar la solicitud de anulación. Pulsamos en Si
  1. Finaliza la gestión y solicitud de anulación con el estado cancelada
  1. Comprobamos que ha finalizado y se ha cancelado de forma correcta

Casos en esta hoja: 15

## Hoja `manual_test` (sin application_udf informado: se consideran todos de SCA)


Casos en esta hoja: 0
