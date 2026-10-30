# Plan de pruebas SCA — Gestión de solicitudes

Origen: `Plan_pruebas_SCA_-_Gestión_de_solicitudes.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `Sheet1` (sin application_udf informado: se consideran todos de SCA)


### Sheet1-1. Gestión de solicitudes – Campos
- prioridad: 2-Medium · tipo: Unit · descripción: Campos
- Pasos:
  1. Entramos a opción de gestión de solicitud
  1. Revisamos campos de pantalla número, diseño y alineación **[validación]**

### Sheet1-2. Gestión de solicitudes - Últimas solicitudes
- prioridad: 2-Medium · tipo: Functional · descripción: Últimas solicitudes
- Pasos:
  1. Entramos a opción de gestión de solicitud
  1. Revisamos que se listen las últimas soliciudes gestionadas por el usuario que ha accedido al menú **[validación]**

### Sheet1-3. Gestión de solicitudes - Últimas solicitudes
- prioridad: 2-Medium · tipo: Unit · descripción: Últimas solicitudes
- Pasos:
  1. Listado de solicitudes con cero
  1. Comprobamos que sale vacío sin inconsistencias de diseño **[validación]**

### Sheet1-4. Gestión de solicitudes - Últimas solicitudes
- prioridad: 2-Medium · tipo: Unit · descripción: Últimas solicitudes
- Pasos:
  1. Listado de solicitudes con paginación
  1. Comprobamos bondad de paginación sin inconsistencias de diseño **[validación]**

### Sheet1-5. Gestión de solicitudes - Búsqueda por cliente (dni)
- prioridad: 2-Medium · tipo: Functional · descripción: Búsqueda por cliente (dni)
- Pasos:
  1. Seleccionamos opción Cliente, rellenamos dni y tipo documento. Pulsamos botón Buscar
  1. Muestra listado de solicitudes de anulación realizadas de ese dni **[validación]**

### Sheet1-6. Gestión de solicitudes - Búsqueda por póliza
- prioridad: 2-Medium · tipo: Functional · descripción: Búsqueda por póliza
- Pasos:
  1. Seleccionamos opción Póliza, rellenamos número de póliza y pulsamos botón Buscar
  1. Muestra listado de solicitudes de anulación realizadas de la poliza indicada **[validación]**

### Sheet1-7. Gestión de solicitudes – Resultados
- prioridad: 2-Medium · tipo: Unit · descripción: Resultados
- Pasos:
  1. Buscamos por póliza o NIF de un solo resultado
  1. Te manda directamente al detalle de la póliza **[validación]**

### Sheet1-8. Gestión de solicitudes – Resultados
- prioridad: 2-Medium · tipo: Unit · descripción: Resultados
- Pasos:
  1. Buscamos por NIF o póliza con varios resultados
  1. Comprobamos campos de resultado **[validación]**

### Sheet1-9. Gestión de solicitudes – Botones
- prioridad: 2-Medium · tipo: Functional · descripción: Alta desde la gestión
- Pasos:
  1. Comprobamos botones de Alta y Búsqueda
  1. Solo usuarios de gestión tiene habilitado el alta **[validación]**

### Sheet1-10. Gestión de solicitudes – Alta
- prioridad: 2-Medium · tipo: Functional · descripción: Alta desde la gestión
- Pasos:
  1. Alta para Póliza sin solicitudes
  1. Navega hasta la pantalla de alta de solicitud. **[validación]**

### Sheet1-11. Gestión de solicitudes - Robinson con anulación a futuro
- prioridad: 2-Medium · tipo: Unit · descripción: Robinson con anulación a futuro
- Pasos:
  1. Alta con una póliza de cliente Robinson y anulación a futuro
  1. Mostrará mensaje ': “La solicitud de anulación que se quiere consultar es un cliente Robinson, no se puede realizar venta cruzada ni labores de recuperación pero si consultar sus datos de solicitud de anulación, se pasará a los datos de consultaEntramos a la pantalla de gestión de solicitudes con una póliza de cliente Robinson y anulación a futuro' Y tras pulsar botón aceptar va al detalle de solicitud

### Sheet1-12. Gestión de solicitudes - Robinson sin pólizas vigentes
- prioridad: 2-Medium · tipo: Unit · descripción: Robinson sin pólizas vigentes
- Pasos:
  1. Alta con una póliza de cliente Robinson sin pólizas vigentes
  1. Mostrará mensaje ': “La solicitud de anulación que se quiere consultar es un cliente Robinson, no se puede realizar venta cruzada ni labores de recuperación pero si consultar sus datos de solicitud de anulación, se pasará a los datos de consultaEntramos a la pantalla de gestión de solicitudes con una póliza de cliente Robinson y anulación a futuro' Y tras pulsar botón aceptar va al detalle de solicitud

### Sheet1-13. Gestión de solicitudes - Detalle de solicitud
- prioridad: 2-Medium · tipo: Functional
- Pasos:
  1. Una vez estoy en el listado de solicitudes de anulación. Pincho en una solicitud y botón Detalle
  1. Compruebo que va al detalle de la solicutd de anulación con las gestiones realizadas y datos de la cabecera correctos **[validación]**

Casos en esta hoja: 13
