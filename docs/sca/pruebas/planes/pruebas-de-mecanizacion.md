# Plan de pruebas SCA — Pruebas de mecanización

Origen: `Plan_pruebas_SCA_-_Pruebas_de_mecanización.xlsx`. Exportado para ejecutar en SCA2 TEST frente a SCA.


## Hoja `manual_test_2` (sin application_udf informado: se consideran todos de SCA)


### manual_test_2-1. Pantalla de mecanización - Mecanización póliza. Alerta
- prioridad: 2-Medium · tipo: Unit · descripción: Mecanización póliza. Alerta
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización para suscripción en una póliza que va a dar una prima distinta de cero (por ejemplo el cliente tiene aun importe de reserva de prima)
  1. El sistema muestra el modal con la simulación de anulación New de la póliza de tipo wAutemis
  1. Observamos entre las alertad de aviso en el modal se encuentra: “El cálculo de esta solicitud de anulación es provisional, consulte situación definitiva en Consuweb” **[validación]**

### manual_test_2-2. Pantalla de mecanización - Mecanización póliza. Alertas
- prioridad: 2-Medium · tipo: Unit · descripción: Mecanización póliza. Alerta
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización para suscripción
  1. El sistema muestra el modal con la simulación de anulación.
  1. Observamos que salen los avisos de alerta sobre los cambios de la póliza. **[validación]**

### manual_test_2-3. Pantalla de mecanización - Mecanización póliza wAutemis y Acepta
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza wAutemis y Acepta
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización en curso de contra anulación a vencimiento
  1. El sistema muestra el modal con la simulación de anulación New de la póliza de tipo wAutemis
  1. Pulsamos botón Aceptar y nos vamos al subproceso de anulación para poner en marcha la anulación correspondiente
  1. Comprobamos que la póliza se anula de forma correcta

### manual_test_2-4. Pantalla de mecanización - Mecanización póliza wAutemis y Acepta con autorización
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza wAutemis y Acepta con autorización
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización en curso de acción administrativa con catalogación a fecha
  1. El sistema muestra el modal con la simulación de anulación New de la póliza de tipo wAutemis
  1. Pulsamos botón Aceptar y nos vamos al subproceso de anulación para poner en marcha la anulación correspondiente con autorización
  1. Comprobamos que se crea el altaSTCAT /altaSGO de forma correcta y se queda a la espera de autorización
  1. Autorizamos desde STCAT
  1. Comprobamos que el proceso de anulación continua y finaliza la anulación de forma correcta

### manual_test_2-5. Pantalla de mecanización - Mecanización póliza NSE autos y cancela
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza NSE autos y cancela
- Pasos:
  1. Entramos en una póliza de tipo NSE autos que acabe de crear gestión de mecanización en curso
  1. El sistema muestra el modal con la simulación de anulación NSE de la póliza
  1. Pulsamos botón Cancelar
  1. El sistema muestra aviso correspondiente y si el usuario confirma cancela la solicitud en curso
  1. Comprobamos que la solicitud se ha cancelado de forma correcta

### manual_test_2-6. Pantalla de mecanización - Mecanización póliza  NSE autos y Acepta
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza wAutemis y Acepta
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización en curso de contra anulación a vencimiento de póliza tipo NSE autos
  1. El sistema muestra el modal con la simulación de anulación NSE de la póliza
  1. Pulsamos botón Aceptar y nos vamos al subproceso de anulación para poner en marcha la anulación correspondiente
  1. Comprobamos que la póliza se anula de forma correcta

### manual_test_2-7. Pantalla de mecanización - Mecanización póliza NSE Autos y Acepta con autorización
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza wAutemis y Acepta con autorización
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización en curso de acción administrativa con catalogación a fecha de póliza tipo NSE autos
  1. El sistema muestra el modal con la simulación de anulación NSE de la póliza
  1. Pulsamos botón Aceptar y nos vamos al subproceso de anulación para poner en marcha la anulación correspondiente con autorización
  1. Tras autorizar la anulación/rechazar la anulación desde NSE. Comprobamos que el proceso de anulación continua y finaliza la anulación de forma correcta

### manual_test_2-8. Pantalla de mecanización - Mecanización póliza NSE Hogar y cancela
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza NSE autos y cancela
- Pasos:
  1. Entramos en una póliza de tipo NSE Hogar que acabe de crear gestión de mecanización en curso
  1. El sistema muestra el modal con la simulación de anulación NSE de la póliza
  1. Pulsamos botón Cancelar
  1. El sistema muestra aviso correspondiente y si el usuario confirma cancela la solicitud en curso
  1. Comprobamos que la solicitud se ha cancelado de forma correcta

### manual_test_2-9. Pantalla de mecanización - Mecanización póliza  NSE Hogar y Acepta
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza wAutemis y Acepta
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización en curso de contra anulación a vencimiento de póliza tipo NSE Hogar
  1. El sistema muestra el modal con la simulación de anulación NSE de la póliza
  1. Pulsamos botón Aceptar y nos vamos al subproceso de anulación para poner en marcha la anulación correspondiente
  1. Comprobamos que la póliza se anula de forma correcta

### manual_test_2-10. Pantalla de mecanización - Mecanización póliza NSE Hogar y Acepta con autorización
- prioridad: 2-Medium · tipo: Functional · descripción: Mecanización póliza wAutemis y Acepta con autorización
- Pasos:
  1. Entramos en una póliza que acabe de crear gestión de mecanización en curso de acción administrativa con catalogación a fecha de póliza tipo NSE Hogar
  1. El sistema muestra el modal con la simulación de anulación NSE de la póliza
  1. Pulsamos botón Aceptar y nos vamos al subproceso de anulación para poner en marcha la anulación correspondiente con autorización
  1. Tras autorizar la anulación/rechazar la anulación desde NSE. Comprobamos que el proceso de anulación continua y finaliza la anulación de forma correcta

Casos en esta hoja: 10
