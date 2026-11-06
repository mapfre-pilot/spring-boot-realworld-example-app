# Plan de pruebas SCA — Gestión aplicación

Origen: `Plan_pruebas_SCA_-_Gestión_aplicación.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test` (sin application_udf informado: se consideran todos de SCA)


### manual_test-1. Gestión Aplicación - Desactivar aplicación y Cancelar
- prioridad: 2-Medium · tipo: Functional · descripción: Desactivar aplicación y Cancelar
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación. Pulsamos botón Desactivar
  1. Muestra mensaje para desactivar aplicación. Modificamos mensaje y pulsamos Cancelar
  1. Comprobamos que vuelve a pantalla anterior. No desactiva la aplicación ni cambia mensaje a mostrar **[validación]**

### manual_test-2. Gestión Aplicación - Desactivar aplicación y Aceptar
- prioridad: 2-Medium · tipo: Functional · descripción: Desactivar aplicación y Aceptar
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación. Pulsamos botón Desactivar
  1. Comprobamos que se desactiva la aplicación y se muestra el mensaje correspondiente **[validación]**

### manual_test-3. Gestión Aplicación - Activar aplicación
- prioridad: 2-Medium · tipo: Functional · descripción: Activar aplicación
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación. Pulsamos botón Activar
  1. Comprobamos que la aplicación se activa de forma correcta **[validación]**

### manual_test-4. Gestión aplicación - Listado conceptos funcionales
- prioridad: 2-Medium · tipo: Functional · descripción: Listado conceptos funcionales
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Comprobamos que se listan los conceptos funcionales de forma correcta **[validación]**

### manual_test-5. Gestión aplicación - Alta concepto funcional Validación
- prioridad: 2-Medium · tipo: Functional · descripción: Alta concepto funcional Validació
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Pulsamos en el icono + del apartado de Conceptos funcionales
  1. Rellenamos los campos dejando algún obligatorio sin informar y pulsamos botón añadir

### manual_test-6. Gestión aplicación - Alta concepto funcional
- prioridad: 2-Medium · tipo: Functional · descripción: Alta concepto funcional
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Pulsamos en el icono + del apartado de Conceptos funcionales
  1. Rellenamos todos los campos y pulsamos botón Añadir
  1. Comprobamos que se da de alta de forma correcta **[validación]**

### manual_test-7. Gestión aplicación - Alta concepto funcional y Cancelar
- prioridad: 1-Low · tipo: Functional · descripción: Alta concepto funcional y Cancelar
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Pulsamos en el icono + del apartado de Conceptos funcionales
  1. Rellenamos todos los campos y pulsamos botón Cancelar
  1. Comprobamos que retorna a la pantalla anterior de forma correcta y no da de alta **[validación]**

### manual_test-8. Gestión aplicación - Modificar concepto funcional
- prioridad: 2-Medium · tipo: Functional · descripción: Modificar concepto funcional
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Pulsamos en icono de modificación de un concepto funcional
  1. Modificamos uno de los campos
  1. Comprobamos que se modifica correctamente **[validación]**

### manual_test-9. Gestión aplicación - Eliminar concepto funcional y Cancelar
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminar concepto funcional
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Pulsamos en icono para eliminar un concepto funcional
  1. Aparece modal de confirmación del concepto. Pulso Cancelar
  1. Vuelve a la pantalla anterior y no lo elimina **[validación]**

### manual_test-10. Gestión aplicación - Eliminar concepto funcional y Confirmar
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminar concepto funcional y Confirmar
- Pasos:
  1. Entramos en Gestiones Mantenimiento, apartado Aplicación.
  1. Pulsamos en icono para eliminar un concepto funcional
  1. Aparece modal de confirmación del concepto. Pulso Confirmar
  1. Compruebo que se elimina el concepto funcional de forma correcta **[validación]**

Casos en esta hoja: 10
