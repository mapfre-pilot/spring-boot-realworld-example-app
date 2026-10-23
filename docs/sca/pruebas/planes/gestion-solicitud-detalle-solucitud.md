# Plan de pruebas SCA — Gestion solicitud Detalle solucitud

Origen: `Plan_pruebas_SCA_-_Gestion_solicitud_Detalle_solucitud.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test` (sin application_udf informado: se consideran todos de SCA)


### manual_test-1. Gestión solicitud – Entrada desde Solicitud
- prioridad: 2-Medium · tipo: Unit · descripción: Entradas
- Pasos:
  1. Entrando en una solicitud e anulación de SCA, en la cabecera seleccionamos “Otras solicitudes”
  1. Seleccionamos una solicitud para ver el destalle de la gestión.
  1. Se abra una pantalla flotante con el detalle. Navegamos por los detalles para comprobar sosteniblidad técnica **[validación]**

### manual_test-2. Gestión solicitud - Cabecera
- prioridad: 2-Medium · tipo: Unit · descripción: Cabecera
- Pasos:
  1. Nos ha redirigido a la pantalla de Detalle de la solicitud  en curso y comprobamos que en la cabecera se visualizan los datos correctos

### manual_test-3. Gestión solicitud - Notificaciones
- prioridad: 2-Medium · tipo: Functional · descripción: Notificaciones
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con póliza y solicitud que tenga notificaciones dadas de alta
  1. Pulsamos botón Notificaciones y comprobamos que se muestran de forma correcta **[validación]**

### manual_test-4. Gestión solicitud - Detalle gestión Alta
- prioridad: 2-Medium · tipo: Functional · descripción: Detalle gestión Alta
- Pasos:
  1. Entramos a la pantalla de gestión de solicitudes con una póliza que tenga solicitud con gestión de alta
  1. Comprobamos que el listado de gestiones realizadas se esta mostrando de forma correcta
  1. Pinchamos en gestión de alta y botón Detalle
  1. Comprobamos que el detalle de la gestión de Alta se está mostrando de forma correcta **[validación]**

### manual_test-5. Gestión solicitud - Detalle gestión contra anulación
- prioridad: 2-Medium · tipo: Functional · descripción: Detalle gestión contra anulación
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con una póliza que tenga solicitud con gestión de contra anulación
  1. Comprobamos que el listado de gestiones realizadas se esta mostrando de forma correcta
  1. Pinchamos en gestión de contra anulación y botón Detalle
  1. Comprobamos que el detalle de la gestión de contra anulación se está mostrando de forma correcta **[validación]**
  1. Pinchamos en uno de los argumentos del listado que tenga Detalle Suplemento y en el botón correspondiente
  1. Se muestra detalle del suplemento realizado **[validación]**

### manual_test-6. Gestión solicitud - Detalle gestión Acciones Administrativas
- prioridad: 2-Medium · tipo: Functional · descripción: Detalle gestión Acciones Administrativas
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con una póliza que tenga solicitud con gestión de Acción administrativa
  1. Comprobamos que el listado de gestiones realizadas se esta mostrando de forma correcta **[validación]**
  1. Pinchamos en gestión de Acción Administrativa y botón Detalle
  1. Comprobamos que el detalle de la gestión de Acciones Administrativas se está mostrando de forma correcta. **[validación]**

### manual_test-7. Gestión solicitud - Detalle gestión Autorización
- prioridad: 2-Medium · tipo: Functional · descripción: Detalle gestión Autorización
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con una póliza que tenga solicitud con gestión de Autorización
  1. Comprobamos que el listado de gestiones realizadas se esta mostrando de forma correcta **[validación]**
  1. Pinchamos en gestión de Autorización y botón Detalle
  1. Comprobamos que el detalle de la gestión de Autorización se está mostrando de forma correcta **[validación]**

### manual_test-8. Gestión solicitud - Detalle gestión Mecanización
- prioridad: 2-Medium · tipo: Functional · descripción: Detalle gestión Mecanización
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con una póliza que tenga solicitud con gestión de Mecanización
  1. Comprobamos que el listado de gestiones realizadas se esta mostrando de forma correcta **[validación]**
  1. Pinchamos en gestión de Mecanización y botón Detalle
  1. Comprobamos que el detalle de la gestión de Mecanización se está mostrando de forma correcta **[validación]**

### manual_test-9. Gestión solicitud - Detalle gestión Mecanización
- prioridad: 2-Medium · tipo: Functional · descripción: Detalle gestión Mecanización
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con una póliza que tenga solicitud con gestión de Mecanización
  1. Comprobamos que el listado de gestiones realizadas se esta mostrando de forma correcta **[validación]**

### manual_test-10. Gestión solicitud – Póliza pendiente RdP
- prioridad: 2-Medium · tipo: Unit · descripción: Detalle gestión RdP
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud con una póliza pendiente de Reserva de prima
  1. Comprobamos que en el lista de gestiones, en contra anulación, en “Estado gestión” aparece “Finalizado positivo” y al lado un signo de alerta, en el cual, al posar el ratón, aparece un mensaje indicando que está pendiente de reserva de prima
  1. Seleccionamos  Contra anulación y vamos a detalle; en la lista de argumentos, en el argumento de Reserva de prima, se indica, en las observaciones, que está pendiente de la gestión de la reserva de prima **[validación]**

### manual_test-11. Gestión solicitud – Póliza pendiente RdP. Cancelanción
- prioridad: 2-Medium · tipo: Unit · descripción: Detalle gestión RdP. Cancelación
- Pasos:
  1. Entramos a la pantalla de Detalle de la solicitud  con una póliza pendiente de Reserva de prima
  1. Comprobamos que en el lista de gestiones, en contra anulación, en “Estado gestión” aparece “Finalizado positivo” y al lado un signo de alerta, en el cual, al posar el ratón, aparece un mensaje indicando que está pendiente de reserva de prima **[validación]**
  1. En la parte inferior aparece el botón Cancela, el cual pulsamos.
  1. Aparece un mensaje de advertencia respecto a que se va a cancelar la solicitud, y con ello se cancelará la petición de reserva de prima a SGO **[validación]**
  1. Al presionar Aceptar, la solicitud se cancela; llegado el día de enviarse el SGO, éste no se envia. **[validación]**

### manual_test-12. Gestión solicitud - Recuperar
- prioridad: 2-Medium · tipo: Functional · descripción: Recuperar
- Pasos:
  1. Entramos a pantalla de Detalle de la solicitud  con condiciones para botón Recuperar activo (solicitud en curso parada en tarea manual y usuario de ditinto perfil no propietario de la póliza)
  1. Comprobamos que aparece habilitado el botón de Recuperar y lo pulsamos **[validación]**
  1. Comprobamos que aparece el mensaje de aviso de captura de tarea y se recupera y redirige a la pantalla correspondiente **[validación]**

### manual_test-13. Gestión solicitud – No Recuperar
- prioridad: 2-Medium · tipo: Unit · descripción: No Recuperar
- Pasos:
  1. Entramos a pantalla de Detalle de la solicitud  con condiciones para botón Recuperar inactivo (perfil no propietario de la póliza en situación donde no hubo salto de nivel)
  1. Comprobamos que no aparece el botón de Recuperar o no está habilitado. **[validación]**

### manual_test-14. Gestión solicitud - Imprimir
- prioridad: 2-Medium · tipo: Functional · descripción: Imprimir
- Pasos:
  1. Entramos a pantalla de Detalle de la solicitud  con condiciones para botón Imprimir activo (Red Mapfre, causa A vencimiento o A vencimiento con impago)
  1. Comprobamos que aparece habilitado el botón de Imprimir y lo pulsamos **[validación]**
  1. Si el nuuma tiene mas de una oficina mostrará modal de selección de oficina
  1. Seleccionamos oficina y nos muestra el documento de solicitud de anulación a imprimir de forma correcta **[validación]**

### manual_test-15. Gestión solicitud – Reintentar
- prioridad: 2-Medium · tipo: Unit · descripción: Reintentar
- Pasos:
  1. Entramos a pantalla de Detalle de la solicitud con una póliza que nos envía directamente por estar atorada en proceso
  1. Comprobamos que aparece habilitado el botón de Reintentar y lo pulsamos
  1. Después de mensaje de confirmación, la solicitud es relanzada y aparece en la situación que le tocaba antes del error al vuelo **[validación]**

### manual_test-16. Gestión solicitud – No Reintentar
- prioridad: 2-Medium · tipo: Unit · descripción: No Reintentar
- Pasos:
  1. Entramos a pantalla de Detalle de la solicitud de una póliza que se encuentra en situación de normalidad funcional.
  1. Comprobamos que no aparece el botón de Reintentar o no está habilitado. **[validación]**

### manual_test-17. Gestión solicitud – Cancelar en error al vuelo
- prioridad: 2-Medium · tipo: Unit · descripción: Cancelar al vuelo
- Pasos:
  1. Entramos a pantalla de Detalle de la solicitud con una póliza que nos envía directamente por estar atorada en proceso
  1. Comprobamos que aparece habilitado el botón de Cancelar y lo pulsamos
  1. Después de mensaje de confirmación, la solicitud es cancelara y es posible hacer una nueva. **[validación]**

Casos en esta hoja: 17
