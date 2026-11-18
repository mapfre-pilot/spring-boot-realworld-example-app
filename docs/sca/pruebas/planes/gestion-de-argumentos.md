# Plan de pruebas SCA — Gestión de Argumentos

Origen: `Plan_pruebas_SCA_-_Gestión_de_Argumentos.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test` (sin application_udf informado: se consideran todos de SCA)


### manual_test-1. Gestión Argumentos - Búsqueda argumento (validaciones)
- prioridad: 1-Low · tipo: Functional · descripción: Búsqueda de argumentos que cumplen las condiciones no rellenando todos los campos obligatorios
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos y pulsamos Buscar sin rellenar nada
  1. Salta alerta incidando rellenar el argumento obligatorio vacio **[validación]**

### manual_test-2. Gestión Argumentos - Búsqueda argumento
- prioridad: 2-Medium · tipo: Functional · descripción: Búsqueda de argumentos que cumplen las condiciones rellenando todos los campos obligatorios
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos y seleccionamos Linea de negocio y pulsamos Buscar
  1. Muestra listado de argumentos que cumplen las condiciones **[validación]**

### manual_test-3. Gestión Argumentos - Búsqueda argumento Datos
- prioridad: 2-Medium · tipo: Functional · descripción: Búsqueda de argumentos datos
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos y seleccionamos Linea de negocio y una fecha de modificación a futuro
  1. Aparece mensaje indicando que no se encuentran tales datos en la base de datos. **[validación]**

### manual_test-4. Gestión Argumentos - Búsqueda argumento Campos
- prioridad: 2-Medium · tipo: Unity · descripción: Búsqueda de argumentos. Campos
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos y seleccionamos Linea de negocio. Rellenamos los campos restantes en distintas combinaciones
  1. Comprobamos que las condiciones funcionan correctamente **[validación]**

### manual_test-5. Gestión Argumentos - Modificación argumento
- prioridad: 2-Medium · tipo: Functional · descripción: Modificación de algún dato de un argumento
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos; seleccionamos  y rellenamos todos los campos obligatorios y pulsamos Buscar
  1. Muestra listado de argumentos que cumplen las condiciones
  1. Seleccionamos un argumento del listado y pulsamos botón Modificar
  1. Revisamos que los datos mostrados son los correctos. Modificamos alguno de los datos y pulsamos botón Aceptar
  1. Comprobamos que se guardan los cambios de forma correcta **[validación]**

### manual_test-6. Gestión Argumentos - Modificación argumento actualizando documento
- prioridad: 2-Medium · tipo: Functional · descripción: Modificación de documento del argumento
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos y rellenamos todos los campos obligatorios y pulsamos Buscar
  1. Muestra listado de argumentos que cumplen las condiciones
  1. Seleccionamos un argumento del listado y pulsamos botón Modificar
  1. Revisamos que los datos mostrados son los correctos. Pulsamos actualizar documento y cargamos el nuevo
  1. Botón aceptar.
  1. Comprobamos que el argumento se ha modificado de forma correcta y al volver a entrar y pulsar Ver documento, este se muestra de forma correcta **[validación]**

### manual_test-7. Gestión Argumentos - Alta argumento Validación datos
- prioridad: 1-Low · tipo: Functional · descripción: Validación datos en pantalla alta de argumento
- Pasos:
  1. Accedemos a la pantalla de gestión de argumentos de contra anulación y pulsamos en botón de 'Alta argumento'
  1. Rellenamos todos los campos obligatorios menos uno y pulsamos botón Guardar
  1. Se resaltara el campo que nos falta informar como obligatorio y nos lo indicará **[validación]**

### manual_test-8. Gestión Argumentos - Alta argumento con documento asociado
- prioridad: 2-Medium · tipo: Functional · descripción: Alta de argumento con documento asociado
- Pasos:
  1. Accedemos a la pantalla de gestión de argumentos de contra anulación y pulsamos en botón de 'Alta argumento'
  1. Rellenamos todos los campos obligatorios. Pulsamos botón Cargar y seleccionamos pdf a cargar
  1. Pulsamos botón guardar
  1. Comprobamos que el argumento se ha dado de alta de forma correcta y el pdf se ha cargado y se puede visualizar de forma correcta **[validación]**

### manual_test-9. Gestión Argumentos - Visualización de documento cargado
- prioridad: 1-Low · tipo: Functional · descripción: Visualización de documento cargado
- Pasos:
  1. Entramos a la modificación de un argumento que contenga documento cargado.
  1. Pulsamos en el botón Ver documento
  1. Comprobamos que podemos visualizar el documento cargado de forma correcta **[validación]**

### manual_test-10. Gestión Argumentos - Alta argumento con referencia informado
- prioridad: 2-Medium · tipo: Functional · descripción: Alta argumento con referencia informado
- Pasos:
  1. Accedemos a la pantalla de gestión de argumentos de contra anulación y pulsamos en botón de 'Alta argumento'
  1. Rellenamos todos los campos obligatorios y referencia que no este ya en BD.
  1. Pulsamos botón guardar
  1. Comprobamos que el argumento se ha dado de alta de forma correcta. **[validación]**

### manual_test-11. Gestión Argumentos - Alta argumento con referencia existente informado
- prioridad: 2-Medium · tipo: Functional · descripción: Alta argumento con referencia informado
- Pasos:
  1. Accedemos a la pantalla de gestión de argumentos de contra anulación y pulsamos en botón de 'Alta argumento'
  1. Rellenamos todos los campos obligatorios y referencia que exista  ya en BD.
  1. Pulsamos botón guardar
  1. Deberá mostrarnos mensaje 'La referencia del argumetno introducida ya existe en el sistema, indique una referencia distinta' **[validación]**

### manual_test-12. Gestión Argumentos – Modificación argumento distintos campos
- prioridad: 2-Medium · tipo: Functional · descripción: Modificación argumento distintos campos
- Pasos:
  1. Accedemos a la pantalla de búsqueda de argumentos y rellenamos todos los campos obligatorios y pulsamos Buscar
  1. Muestra listado de argumentos que cumplen las condiciones
  1. Seleccionamos un argumento del listado y pulsamos botón Modificar
  1. Modificamos los distintos campos comprobando después que el argumento responde alas indicaciones **[validación]**

Casos en esta hoja: 12
