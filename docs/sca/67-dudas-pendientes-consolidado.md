# 67 — Listado consolidado de dudas pendientes (16/11/2026)

Junta todas las dudas abiertas hasta la ronda 49. Cada duda lleva entre paréntesis su origen, donde está el detalle. Mientras no haya respuesta, SCA2 sigue funcionando como se describe en el informe de origen.

Leyenda de quién responde: **[U]** el usuario o el responsable técnico · **[AN]** el analista · **[NEG]** negocio · **[EXT]** otro equipo (AM, CORE, CMP, Club, DBA).

Las duplicadas se han unido en una sola duda, con todos sus orígenes.

## 1. Ronda 49 (informe del analista del 16/11)

### 1.1 Mensajes y pantallas (MEJ-01 a MEJ-06) — no se ha tocado nada
1. [NEG] **Textos (MEJ-01, 02, 04 y 05):** ¿negocio ya ha decidido los textos? Si no, ¿se prepara una propuesta de redacción para que la validen?
2. [NEG] **MEJ-03:** ¿se sustituye «se gestiona desde el Detalle de la solicitud» por un botón «Ir a la gestión» que abra la tarea siguiente? Sería un flujo distinto del de SCA.
3. [NEG] **MEJ-04:** ¿hay que listar en el aviso los documentos que faltan? Si es así, ¿de dónde sale la lista: de la acción de SCA2 o de un catálogo de negocio?
4. [AN] **MEJ-06:** ¿cuál es la URL o el procedimiento hacia Si24 que tiene que seguir el gestor?
5. [AN] **Pólizas 200240…:** las 8 pólizas no tienen página de pruebas en el OneNote. ¿Hay alguna evidencia de ellas o las dejamos fuera?

### 1.2 R49-A — Bloqueo tras ACEPTAR en el alta (`pruebas/r49-a-bloqueo-tras-espera-alta.md`)
6. [NEG] **Texto del error de decisión:** el texto de SCA termina en dos puntos y no dice nada más. ¿Se mantiene o se pone otro más claro?
7. [AN] **Solicitud en `ERROR_DECISION`:** se queda «Pendiente» y bloquea nuevas altas de esa póliza hasta que se relance desde `/errores`. ¿Es lo esperado?
8. [NEG] **Detalle abierto más tarde:** si después se abre esa solicitud desde el buscador, ¿tiene que salir un aviso?
9. [AN] **Estado `ERROR`, cuando falla crear la acción:** el mensaje sigue diciendo «generada correctamente». ¿Se trata igual que `ERROR_DECISION`?
10. [EXT] **API de Clientes de TEST:** faltan los clientes de 2002600074290, 272, 293 y 304. ¿Se pueden corregir esos datos?

### 1.3 R49-B — Buscador e histórico (`pruebas/r49-b-busqueda-historico.md`)
11. [EXT] **Marca de CORE en 0002729391736:** tiene `MCA_PENDIENTE = S` sin ninguna solicitud. ¿Se quedó colgada? Si es así, hay que quitarla en CORE.
12. [AN] **15788901:** ¿qué pasos se hicieron al aplicar el TTQ? ¿Se pulsó ACEPTAR y salió algún mensaje?
13. [AN] **Recargar el argumentario de 15788901:** recargarlo borra y vuelve a crear sus argumentos. ¿Lo hacemos nosotros o lo retoma el analista y nos pasa una captura?
14. [AN] **Búsqueda de la solicitud «que no aparecía»:** ¿se buscó por cliente, por número de solicitud o en SCA?
15. [AN] **FINALIZAR tras aplicar tréboles:** ¿confirma que hay que pulsar FINALIZAR para cerrar la contra anulación, como en SCA?

### 1.4 R49-C — Validaciones del alta (`pruebas/r49-c-validaciones-alta.md`)
16. [EXT] **INC-01, Vida:** ¿hay alguna póliza Vida que SCA dé de alta en TEST, o los datos que faltan los tiene que indicar CORE? Ver también la duda 49.
17. [NEG] **OBS-01:** cuando negocio cierre los textos, ¿se pone en SCA2 el texto de SCA para el aviso de Si24 que ve Red Mapfre en nivel 1?
18. [AN] **INC-03, póliza renovada:** ¿está bien que una renovada «a fecha» se pueda grabar, como hace SCA y ahora SCA2 v56? ¿O el aviso de renovada debería bloquear en las dos aplicaciones?

### 1.5 R49-D — Error del servicio, Te Cuidamos y nivel 2 (`pruebas/r49-d-gestion-errores-tecuidamos-nivel2.md`)
19. [AN] **Pruebas 15789153 y 15789154:** son de antes de la v80 y quedaron Positivas por el fallo. ¿Se cancelan o se dejan como evidencia?
20. [AN] **Producto en Autemis:** SCA guarda AU01/AU02 y SCA2 guarda el código de TRON (por ejemplo, 00000124). No se ha visto ningún fallo por ello. ¿Lo igualamos a SCA?
21. [NEG] **Cambio de la v80:** CANCELAR ya no deja la contra anulación como Positiva, igual que en SCA. ¿Negocio está de acuerdo? Si no, se vuelve a la v79.
22. [NEG] **Ventana «Error del servicio» de CMP:** no dice qué servicio falla ni el código, igual que en SCA. ¿Se pide a CMP que lo muestre?

### 1.6 R49-E — Error del buscador por tipo de póliza (`pruebas/r49-e-buscador-tipo-poliza.md`)
23. [NEG] **Espacio al final del número:** el campo avisa de que tiene más de 13 caracteres, aunque la búsqueda funciona. ¿Se mantiene?
24. [U] **Error de SCA en `sca_datoscabecera`** («The save target must be a local variable…» al volver desde la consulta): ¿se comunica al equipo de SCA?
25. [NEG] **Tipo de póliza al entrar:** ¿SCA2 tiene que entrar con NO VIDA ya seleccionado, como SCA?

## 2. Base de datos (rondas 48 y 66)
26. [U] **Paso 3:** ¿se preparan los cambios de Appian y se prueban en TEST? Son la UNIQUE de la caché de cabecera, una sola tarea pendiente por solicitud y tipo, y las claves foráneas. ¿O primero el bloque A y el plan para PRO? **Resuelta 17/11:** en TEST ya existen las UNIQUE de la caché (script 70), de las tareas pendientes (71) y de los errores pendientes (72), sin duplicados. Las claves foráneas se descartan (R50-B). PRO queda en espera hasta que lo indique el usuario.
27. [U/NEG] **`FECIMPRESION` (observaciones):** ¿se amplía a 1000 y se iguala el recorte en el alta, POSPONER y completar acción? Está relacionado con el error `varchar(255)` de «Write Tarea» (id 215) del 11/11 (`pruebas/r48-d`, duda 3).
28. [U/NEG] **Fecha del último siniestro:** la base de datos ya admite 1000 caracteres. ¿Se sube también el límite de 255 en `SCA2_limitesFilaCacheCabecera`?
29. [U] **Metadatos de los record types:** ¿se guardan o se sincronizan SCA2 Datos Cabecera y SCA2 Transicion para que reflejen los nuevos tamaños? No hace falta para que funcionen (`pruebas/r48-c`).
30. [U] **Usuario de las transiciones encadenadas:** en Decidir y CrearAccion queda la cuenta técnica de Appian, como antes. ¿Se quiere registrar el usuario de la gestión? (`pruebas/r48-d`, duda 2)
31. [AN] **Etiqueta de 15788999:** una Acción Administrativa pendiente de anular a vencimiento sale como «Solicitud Finalizada sin anular». ¿Es la etiqueta correcta?

## 3. Rondas anteriores todavía abiertas

### 3.1 Funcionalidad (doc 64 A, R47 y R48)
32. [AN] **NO en Anulación/Suscripción:** ¿se acepta 5 + 4 o hay un servicio de CORE que deje la solicitud en 14? (64-1)
33. [AN] **Más Móvil:** ¿la fecha de anulación correcta es el 02/01/2027 o el 01/01/2027? (64-2)
34. [NEG] **Filtro «Estado»:** ¿se deja por estado interno o se filtra por etiqueta, que es más lento o requiere guardar más estados? (64-3)
35. [AN] **Combinaciones que «no pueden darse»:** hay casos reales (2+2, 2+4 y 3+1). ¿Qué etiqueta lleva cada una? (64-4)
36. [AN] **2 + 1 + gestión 5 sin pasar por nivel 2:** ¿es correcto «Póliza Anulada. Solicitud Pendiente Nivel 2»? (64-5)
37. [NEG] **Estado provisional mientras NSE/ANL termina:** ¿se deja, se pone «En proceso» o se refresca sola la pantalla? Es la misma decisión que la propuesta 3 del doc 66. (64-6, 66-3)
38. [AN] **COMPROBAR AHORA y espera de respaldo de 90 s:** ¿se mantiene? (64-7)
39. [NEG] **Aviso «cerca del vencimiento»:** ¿se quiere mostrar? Hoy no sale ni en SCA ni en SCA2. (64-8)
40. [NEG] **Fallo del SVA:** si falla, ¿el argumento se queda abierto? (64-9)
41. [AN] **Retos y SVA:** ¿se aplican al ACEPTAR la enhorabuena, como los tréboles? (64-10)
42. [AN] **Reserva de prima:** ¿es el argumento económico («Arg. Econ.» en `A2139022_MES`)? (64-11)
43. [NEG] **Texto del fallo del SVA:** dice «tréboles». ¿Se cambia por «el SVA»? (64-12)
44. [AN] **Entrega parcial de tréboles:** Club bien y TTQ mal. ¿Se finaliza Positiva y se relanza TTQ desde `/errores`? (64-13)
45. [AN] **Tipo de documento en el enlace NSE:** ¿hay algún campo con el tipo, o se sigue deduciendo del formato? (64-14)
46. [AN] **Perfil control `CE_MF_CONTROL`:** ¿tiene que ver el aviso Si24 y necesitar la carta, como en SCA? (64-15)
47. [AN] **Consulta Vida:** ¿se pasa el número con 13 dígitos, como hace hoy el código de SCA y de SCA2, o con 10? (64-16)
48. [EXT] **Opción seleccionada en CMP:** ¿puede CMP devolver o guardar qué se ejecutó? (64-17)
49. [NEG] **TTQ con cliente NO CLUB:** ¿basta el mensaje de SCA o se avisa antes de pulsar POSITIVO? (N47-2)
50. [AN] **RECARGAR sin compañía contraria:** tarda unos 63 s. ¿Es normal? ¿Se avisa o se pide la compañía antes? (R47-C D1)
51. [AN] **Aviso de 250 caracteres en Observaciones:** ¿tiene que bloquear o basta el límite de 999, como en SCA? (R47-C D2)
52. [EXT] **Tréboles de 15788894:** ¿se grabaron en Club, TTQ y económicos? (R47-C D3)
53. [AN] **Observación de una contra anulación negativa en el detalle:** sale «-». ¿En SCA se ve? (R47-C D4)
54. [AN] **Prueba del analista:** ¿repite el alta en Club y RECARGAR en su solicitud? (R47-C D5)
55. [U] **Error 215 (15788894):** ¿lo relanza alguien con acceso a `/errores`? (R47-C D6)
56. [NEG] **Textos de la espera del alta:** `SCA2_TXT_ESPERA_DECISION_ADICIONAL`, `SCA2_TXT_ESPERA_AGOTADA` y los botones. ¿Se validan? (R48-A 1)
57. [AN] **Sondeo después de 30 s:** ¿es aceptable que el texto pase a «generada correctamente» con un solo ACEPTAR? (R48-A 2)
58. [AN] **Caso real de negocio «no sale»:** ¿nos pasáis la solicitud, la póliza y la hora? (R48-A 4)
59. [AN] **«Incompleta» tras la contra anulación POSITIVO hasta recargar:** ¿lo habéis visto? (R48-A 5)
60. [AN] **Tareas de inducción Verti pendientes:** ¿quién completa las de 15788699 y 15788703? ¿Se cierran las tareas huérfanas 15788323, 15788326 y 15788540? (N47-B2)
61. [AN] **Mecanizar asíncrono (nodo 334):** ¿se cambia? Cambiaría el flujo. (N47-B3)
62. [NEG] **Alerta activa** de procesos parados por correo o notificación: ¿se quiere? (N47-B4)
63. [U] **Retención de instancias** en Process HQ: ¿se sube de 1 a 7 días? (N47-B5)

### 3.2 Optimizaciones que cambian el funcionamiento (doc 66)
64. [NEG] **Caché de cabecera en el alta:** ¿se acepta mostrar datos de hasta un día? ¿Hay datos que tengan que ir siempre en vivo? ¿Con qué caducidad? (66-1, N47-B1)
65. [NEG] **Argumentario:** ¿cuál es el tiempo máximo de espera (30 o 60 s)? ¿El catálogo se mantiene solo desde SCA2? ¿Se puede generar al crear la tarea? ¿Qué equipo del backend lo haría y en qué plazo? (66-2)
66. [NEG] **Decisión con salto a Si24:** ¿se acepta probar la optimización? (66-4)

### 3.3 Otros equipos (doc 64 B)
67. [EXT] **Alta Vida en CORE (4004):** ¿qué dato falta? ¿Se puede tener el log de PDTE-13377305 o PDTE-269184469? ¿Por qué aplicación se dio de alta la 15788717? (64-18, se une a la duda 16)
68. [EXT] **`fecValidez`:** ¿hay que enviarla y con qué fecha? (64-19)
69. [AN] **BAJAPRIM:** ¿se vuelve a dar de alta? El mantenimiento de SCA da 403. La próxima recarga desde CORE ya lo traerá. (64-20)
70. [AN] **Entrada desde FDC/Decisora:** falta la URL para simularla. (64-21)
71. [AN] **Switch Verti:** faltan los flags que abren la inducción. (64-22)

### 3.4 Datos y accesos de prueba en TEST (doc 64 C y R49)
72. [AN] **Póliza que llegue a «Pendiente de Autorización»** (00000005/06) y un caso en que ANL no lance NSE ni NEW. (64-24, R48-A 3)
73. [AN] **Póliza de acuerdo** que llegue a nivel 2 con fecha de anulación válida, para Verti → inducción con Oficina. (64-25)
74. [AN] **Póliza de socio Club con TTQ vigente** y sin solicitud abierta, y una forma de provocar un fallo solo en TTQ. (64-26, N47-1, R49-B 5)
75. [AN] **Póliza con TTQ y cliente sin Te Cuidamos.** (R49-D 1)
76. [AN] **Póliza de flota** (acuerdo 20, 33 o 35) sin solicitud en curso. (R49-C 4)
77. [U] **Usuarios de TEST:** administrador SCA2 para `/errores` y el mantenimiento, y perfiles Central, CCC, GGE y Si24 front. (64-27)

### 3.5 Para Álvaro
78. [U] **Objetos SCA2 sin uso:** de los 20 de la lista segura, 18 ya no existían y en R47 se borró uno; `SCA2_FLD_DOCUMENTOS` se usa. Quedan los candidatos de r33 §3.2–3.4. (64-28)

## Cerradas desde el doc 64
- 64-23 (DDL de la caché de cabecera): se ejecutó en TEST dentro del paso 1 (doc 66).
- 64-26, póliza NO CLUB: probada en R47-A.
