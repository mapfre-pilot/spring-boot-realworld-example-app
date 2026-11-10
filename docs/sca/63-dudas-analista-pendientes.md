# Dudas pendientes para el analista (06/11/2026; respuestas del 10/11/2026 incorporadas)

> **Ronda 46 (10/11/2026, «Analisis SCA2.docx»):** el analista responde los puntos 1, 2–6 y 21–24. Cada punto lleva su estado: **RESPONDIDA** (cerrada), **RESPONDIDA → cambio en SCA2** (aplicado en R46-A) o **ABIERTA** (sigue pendiente o depende de terceros). Detalle y pruebas en `pruebas/r46-a-analisis-detalle-estados.md`. Los puntos sin marca siguen sin respuesta.

Parte A: dudas de la ronda 45, que salen de las pruebas de esta ronda. Parte B: dudas de rondas anteriores de las que no tengo respuesta registrada; si ya están contestadas, indicadlo y las cierro. Mientras no haya respuesta, SCA2 sigue funcionando como se describe en cada punto.

## A. Ronda 45

### Vida
1. **Clave de producción:** 18472 + 0372 da `184720372 / 0035099` (es lo implementado), pero el documento pone `18420372 / 0035099`. ¿Cuál es la correcta? Si es la segunda, ¿qué regla quita el 7?
   - **RESPONDIDA:** la correcta es `184720372 / 0035099` (lo implementado); el documento tenía una errata. No se cambia nada. [Observado]
2. **Alta Vida en CORE (error 4004 «Datos insuficientes» en `generarStudAnul`):** se envían la clave, la estructura comercial y la prima, y sigue fallando. ¿Qué dato pide CORE para Vida? ¿Es `numApli`, y con qué valor? ¿Puede CORE pasar el log de las altas PDTE-13377305 o PDTE-269184469?
   - **ABIERTA (AM/CORE):** el analista no lo sabe; pide acceso al servicio de alta para probarlo él (pregunta a José Enrique Peñarrubia). [Pendiente]
3. **Solicitud Vida 15788717** (JJGONZ2, 03/11 13:34): no está ni en SCA ni en SCA2. ¿Por qué aplicación se dio de alta? La única diferencia que he encontrado es la compañía del usuario: 3 en esa solicitud y 41 en las de SCA/SCA2. He probado con 3 y CORE sigue dando 4004.
   - **ABIERTA (AM):** hay que preguntar al AM cómo dan de alta Vida; en teoría no debería haber diferencia con otros ramos. [Pendiente]
4. **`fecValidez`** del servicio de estructuras comerciales: ¿hay que enviarla, y con qué fecha (hoy, efecto o anulación)? Ahora el servicio responde bien sin ella.
   - **ABIERTA:** la respuesta está incompleta («Hay que ver qué»). SCA2 sigue sin enviarla. [Pendiente]
5. **Estructura comercial y prima en el alta Vida:** SCA2 las envía y SCA las manda vacías. ¿Las mantenemos?
   - **ABIERTA:** «Tiene que funcionar como Autos y Hogar», pero el analista necesita el servicio para comprobarlo. Se mantiene el envío actual. [Pendiente]
6. **ACEPTAR tras el alta:** no se duplican solicitudes ni en SCA2 ni en SCA, pero el botón no se ve deshabilitado al momento. ¿Basta con que no haya duplicados? Que se vea deshabilitado al instante obliga a añadir un paso más.
   - **RESPONDIDA:** «Debe hacer lo mismo que con Autos y Hogar». Por código, el ACEPTAR de `SCA2_AltaSolicitudPage` es único para todos los ramos (`local!aceptarPulsado`), así que Vida ya se comporta igual. La prueba funcional en Vida sigue bloqueada por el 4004 del punto 2. [Observado]

### ANL, CORE, NEW y NSE
7. **«Cancelada» al decir NO en Anulación/Suscripción:** la tabla pide solicitud 14 + mecanización 4. SCA2 deja 5 + 4 («Rechazada anulación»). El servicio que pone 14 en la contra anulación no sirve si no hay una contra anulación abierta. ¿Qué servicio de CORE hay que llamar? ¿O aceptamos 5 + 4?
8. **wAutemis a más de 18 meses:** NEW rechaza la anulación a vencimiento con el error 916 («La Fecha de Efecto no puede ser mayor o menor en 18 meses…»). ¿Qué fecha de suplemento hay que enviar? ¿O SCA2 debe impedir la anulación y avisar?
9. **ANL acepta pero no lanza NSE ni NEW** (15788754: REDIRIGIR_NEW sin TIPO_FLUJO): SCA2 espera 10 minutos y cierra la mecanización como Incompleta. ¿Hay que avisar, reintentar o dejarla pendiente?
10. **Fecha para consultar el nivel de NEW en una anulación a vencimiento:** SCA2 usa la fecha de anulación (igual que SCA según el código). Con esa fecha NEW no devuelve nivel 5; con una fecha cercana a hoy, sí. ¿Qué fecha hay que usar?
11. **Nivel 00000004 en wAutemis** (15788830): ahora solo se va a pendiente de autorizar con 00000005/06. ¿El nivel 4 también debe ir?
12. **Espera a NSE/ANL antes de finalizar:** hoy son hasta 10 minutos, consultando cada minuto. ¿Se puede bajar a 3–5 minutos o consultar cada 30 segundos?
13. **«Tipo catalogación» en el alta wAutemis:** el servicio propone un valor que no está en el desplegable (solo hay «A FECHA») y salta un error. Opciones: a) poner «A FECHA» por defecto; b) añadir el valor que propone el servicio; c) limpiar el valor al cargar; d) que wAutemis vaya siempre a «A FECHA».
14. **Casos de prueba:** ¿tenéis alguna póliza que llegue a «Pendiente de Autorización» (4/5 + 2) o a «Mecanización Enviada» (4/5 + 7)? No he conseguido ninguna: las wAutemis no dan nivel a vencimiento y las NSE dan el error 4021 en la simulación.

### Si24, Verti e inducción
15. **Aviso Si24:** se ha quitado para el gestor Si24, GGE y nivel > 1. ¿Se quita también para central y CCC?
16. **FINALIZAR sin carta ni DNI:** se permite a todos los perfiles menos Red Mapfre. ¿Hay algún otro perfil que deba seguir exigiéndolos?
17. **Inducción:** CMP da «error al consultar los datos del agente» (0002729325300, acuerdo VW PLURI). ¿Es normal en TEST para pólizas de acuerdo o concesionario? SCA2 da la inducción por finalizada.
18. **ANL en «Gestionar Error Integración»** (0002729325306, GO INSURANCE PLURIANUAL): la causa era el límite de 18 meses de NEW (punto 8). ¿Hay algo más que revisar?
19. **Verti de nivel 2:** se asigna al usuario que hizo el alta, igual que en SCA. ¿Se deja así o debe ir al usuario o grupo Si24?
20. **Contra anulación de nivel 1 de otro grupo o nivel:** SCA2 no muestra ningún botón, tampoco REASIGNAR; SCA sí muestra REASIGNAR. ¿Hay que mostrarlo?

### Etiquetas de estado
21. ¿Qué etiqueta lleva una solicitud 4/5 con mecanización 3 (incompleta) o 5? Ejemplo: 15788455.
   - **RESPONDIDA → cambio en SCA2:** «Solicitud Finalizada sin anular», en rojo. Aplicado en `SCA2_calcularEstadoSolicitud` (v6→v7). [Observado]
22. El filtro «Estado» filtra por el estado interno y no por la etiqueta nueva. Por eso, al elegir «Cancelada» salen filas con otras etiquetas. ¿Debe filtrar por la etiqueta?
   - **RESPONDIDA (interpretación en R46-A):** «Son los estados los que indican la etiqueta». Se interpreta que la etiqueta se obtiene siempre de los estados (solicitud + mecanización + gestión), según la tabla. El filtro no se ha cambiado; ver la decisión y la duda nueva en el informe R46-A. [Inferido]
23. ¿Qué etiqueta llevan las combinaciones que no están en la tabla? Son 2 + mecanización 1 sin gestión 5; 2 + mecanización 2/4/7; 14 con mecanización distinta de vacía o 4; 3 con mecanización; y los estados 7–10, 13 y 15–19. Hoy se aplica la lógica anterior.
   - **RESPONDIDA:** «En teoría esos estados no pueden darse; si tienes algún ejemplo, exponlo». En TEST sí hay ejemplos: 2 + mecanización 2, 2 + mecanización 4 y 3 + mecanización 1. Están listados en el informe R46-A. [Observado]
24. Durante 1–2 minutos, mientras NSE/ANL termina, se ve un estado provisional («Incompleta» o «Pendiente Nivel 2»). ¿Se deja así, se pone un estado explícito tipo «En proceso» o se refresca la pantalla sola?
   - **ABIERTA (negocio):** hay que decidirlo con negocio. [Pendiente]

## B. Rondas anteriores sin respuesta registrada

### Vida (ronda 43)
25. **Detalle en Vida:** con el motivo DECISIÓN DE CLIENTE se quita el segundo detalle por posición. En Autos y Hogar es IMPAGO DEL SEGURO, pero en Vida es MALA GESTIÓN. ¿Debe verse MALA GESTIÓN en Vida, o se deja como en SCA?
26. SCA TEST rechaza las pólizas Vida («La póliza no es una póliza válida…»). ¿Por dónde hacéis la consulta de Vida para comparar?

### Tiempos y espera (ronda 42)
27. El alta tarda 15–20 s. Es el tiempo del propio proceso (servicios de Alta, Decidir y CrearAccion). ¿Hay que revisar esos servicios?
28. COMPROBAR AHORA solo aparece cuando se pasa a la espera de respaldo. ¿Debe verse también durante la espera síncrona?
29. La contra anulación positiva deja ahora la tarjeta en «Finalizada Positiva» (antes quedaba «Incompleta»). ¿Es correcto?
30. La espera de respaldo dura como máximo 90 s, y después se habilita ACEPTAR. ¿Es un valor adecuado?
31. ¿Tenéis pólizas o casos que generen acciones administrativas o anulación fuera de norma, para medir sus tiempos?

### Argumentario y tréboles (rondas 34–35)
32. Al RECARGAR, SCA2 desmarca el argumento; SCA lo deja marcado con los datos antiguos. ¿Os parece bien? **→ RESPONDIDA (R46-D):** se deja marcado como en SCA; hecho y probado (`pruebas/r46-d-argumentario-treboles.md`).
33. Tras entregar tréboles: ¿qué hace CANCELAR en la enhorabuena? ¿Y la entrega parcial (Club OK + TTQ KO)? ¿Y las observaciones de más de 999 caracteres? ¿Hace falta el aviso «cerca del vencimiento»? Si falla SVA, ¿el argumento se queda abierto? ¿Tenéis una póliza NO CLUB para probar el fallo de tréboles? **→ RESPONDIDA en parte (R46-D):** tréboles en Club+TTQ al ACEPTAR la enhorabuena y CANCELAR sin aplicar; entrega parcial → error relanzable en `/errores`; >999 se truncan; hecho. Fallo SVA: pendiente de negocio (hoy el argumento queda pendiente). Aviso «cerca del vencimiento»: lo explica R46-C. Póliza NO CLUB: pendiente de que la paséis.
34. Después de mantener argumentos, el catálogo Aurora de contra anulación no se actualiza hasta pulsar «Recargar desde CORE». ¿Vale así, se hace una recarga programada o todo lee de CORE? **→ RESPONDIDA (R46-D):** recarga automática tras alta/modificación/baja de argumento; hecho.
35. ¿Podéis volver a dar de alta BAJAPRIM? Tampoco he podido comparar con SCA, porque su mantenimiento da 403 a todos los usuarios de prueba.
36. Observación «Se han aplicado Y tréboles»: ¿va separada de las observaciones del gestor? ¿Es solo para TTQ? ¿Tenéis pólizas con TTQ, Retos o SVA vigentes para probarla en pantalla? **→ RESPONDIDA (R46-D):** extendida a SVA (con el SVA aplicado) y a reserva de prima; hecho, pendiente de prueba en pantalla.

### Otros
37. **Objetos SCA2 sin uso** (ronda 33, `pruebas/r33-objetos-sin-uso-verificados.md`): hay 20 que se pueden borrar sin riesgo. ¿Los borro? Por ahora no he borrado nada.
38. **Caché de cabecera** (ronda 38): para no tener que recortar el enlace GESVIDA, la solución definitiva es ampliar la columna `POLIZA_FECHAULTIMOSINIESTRO`, lo que necesita un cambio en la base de datos (DDL). ¿Se hace? **→ RESPONDIDA (R46-D):** sí; tabla exclusiva de SCA2, DDL bloqueado en TEST (tabla no gestionada por Appian); script en `sql/63-r46d-ampliar-poliza-fechaultimosiniestro.sql`.
39. **Entrada desde FDC/Decisora:** ¿hay que mantenerla? Para ello necesito ejemplos de las llamadas.
40. **Switch Verti:** se usa el FLAG global `vertiSuscripcionInteligente`, porque `SCA2_flagVerti` por nuuma da false con los usuarios de prueba. ¿Es ese el switch?
41. **Inducciones de tipo A** (iniciador APP-SCAN) que aparecen junto a la de tipo I y que SCA2 no lanza: ¿es normal que el cliente reciba las dos?
42. **ANL CONCLUIDA en PRE:** ANL no marca CONCLUIDA en las solicitudes SCA2. ¿Quién la marca? ¿El rechazo se da por concluido con ESTADO=2?
43. **Catalogación final NSE en CORE** (SCA pone 1 y SCA2 pone 2): la corrección en `SCA2_ContraAnulacionOpciones` está preparada a falta de vuestro OK.
44. **Retorno al formulario tras el alta** (doc 44): la propuesta está pendiente de vuestro OK. Puede que ya esté cubierta por las rondas 35 y 42.
