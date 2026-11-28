# Plan de pruebas SCA — Gestión de conceptos y clases

Origen: `Plan_pruebas_SCA_-_Gestión_de_conceptos_y_clases.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test` (sin application_udf informado: se consideran todos de SCA)


### manual_test-1. Gestión conceptos - Búsqueda de conceptos
- prioridad: 2-Medium · tipo: Functional · descripción: Búsqueda de conceptos
- Pasos:
  1. Seleccionamos un concepto en el desplegable y pulsamos botón Buscar Concepto
  1. Se realiza la búsqueda de los valores asociados al concepto, mostrándolos en la tabla o devolviendo el mensaje: "No hay elementos disponibles"

### manual_test-2. Gestión conceptos - Modificación valores de concepto
- prioridad: 2-Medium · tipo: Functional · descripción: Modificación valores de concepto
- Pasos:
  1. Seleccionamos un concepto en el desplegable y pulsamos botón Buscar Concepto
  1. Se realiza la búsqueda de los valores asociados al concepto, mostrándolos en la tabla
  1. Pinchamos en el icono para modificar un valor del concepto
  1. Modificamos el valor y comprobamos que se ha modificado de forma correcta

### manual_test-3. Gestión conceptos - Eliminación de valor de concepto
- prioridad: 2-Medium · tipo: Functional · descripción: Eliminación de valor de concepto
- Pasos:
  1. Seleccionamos un concepto en el desplegable y pulsamos botón Buscar Concepto
  1. Se realiza la búsqueda de los valores asociados al concepto, mostrándolos en la tabla
  1. Pinchamos en el icono para eliminar un valor
  1. Comprobamos que se elimina de forma correcta

### manual_test-4. Gestión conceptos - Alta concepto
- prioridad: 2-Medium · tipo: Functional · descripción: Alta concepto
- Pasos:
  1. Pulsamos botón alta Concepto
  1. Rellenamos valores
  1. Pulsamos botón Añadir y comprobamos que se da de alta de forma correcta

Casos en esta hoja: 4
