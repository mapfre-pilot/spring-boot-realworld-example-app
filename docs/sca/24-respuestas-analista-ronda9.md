# SCA2 — Dudas funcionales para el analista (lenguaje de negocio)

Documento para que el analista responda o corrija. Cada punto dice **qué hace SCA2 hoy**, **qué duda tenemos** y, cuando ayuda, **las opciones**. No hace falta conocer el código: basta con indicar el comportamiento esperado como lo haría un gestor de Red o de SI24.

Las preguntas del Excel que ya se respondieron (impresión por solicitud; RETOMAR/REASIGNAR correctos; buscador con todas las solicitudes; abrir el Detalle con un único resultado; /errores sólo administradores; validaciones de fecha al guardar; PRRA con códigos fijos; Vida pasa por contra anulación; sólo los estados 1 y 2 cuentan como solicitud abierta; posponer una Autorización crea SGC) **ya están implementadas o en curso** y no se repiten aquí, salvo cuando al implementarlas ha surgido una duda nueva.

---

## A. Alta de la solicitud

**A1. Simulación previa al alta (Excel 21).** El analista dijo que la simulación es obligatoria y que hay que investigar por qué no se usa.
- *Hoy en SCA2:* el alta se guarda sin simular. Cuando intentamos simular desde la pantalla, al usuario de oficina (JJGONZ2) le saltó un «cceso denegado» (el usuario normal no tiene permiso para llamar a la simulación de Emisión). Por eso la quitamos de la pantalla.
- *Duda:* ¿la simulación debe hacerse **antes de que el gestor pulse GUARDAR** (y mostrarle los avisos, como el popup de SCA), o basta con que la haga el sistema **justo después de guardar**, sin que el gestor la vea? ¿Qué avisos de la simulación deben bloquear el alta y cuáles sólo informar?
Es probable que devin esté lanzando las pruebas con WAutemis pero lanzando la simulacion de NSE y no el servicio para WAutemis 


**A2. Paso a Expertos en retención (Excel 21).** En SCA, según el resultado de la simulación, la solicitud puede ir directamente a un experto de retención en vez de a la oficina.
- *Duda:* ¿en qué casos exactos (qué aviso o resultado de la simulación) la solicitud debe ir a Expertos en retención? ¿Y a qué grupo (SI24 Experto, otro)?
El servicio de simulacion no indica si hay que hacer salto de nivel. Es el servicio de decisión del motor de reglas el que lo determina.Decidir Acción. 
estas son algunas de las respuestas donde CE_MF_BK_EXPERTOSI24 hace referencia a expertos Si24 y CE_RM a la oficina Red mapfre
{"accion":"CONTRA ANULAR NIVEL 2","grupo":"CE_RM","subgrupo":"CE_RM"}
{"accion":"ACCIONES ADMINISTRATIVAS NIVEL 2","grupo":"CE_RM","subgrupo":"CE_RM"}
{"accion":"CONTRA ANULAR NIVEL 2","grupo":"CE_MF_BK","subgrupo":"CE_MF_BK_EXPERTOSI24"} es de SI24

**A3. Pólizas en PRRA (Excel 22).** Confirmado que llevan motivo/detalle/causa fijos.
- *Duda:* ¿cómo sabe el gestor (o el sistema) que una póliza está en PRRA? En SCA lo dice la simulación (código 4022). Si la simulación no puede hacerse desde la pantalla (ver A1), ¿puede hacerla el sistema después de guardar y corregir los códigos él solo, sin preguntar al gestor?
Lo puede hacer sí.



**A4. Destino de la solicitud tras el alta.** Al dar de alta la póliza 0001047017036 (impago) con JJGONZ2, CORE decidió abrir una **Acción Administrativa** y la cabecera mostró «Origen IMPAGO».
- *Duda:* ¿es correcto que una póliza con recibo impagado vaya a Acciones Administrativas en lugar de a Contra Anulación? ¿La cabecera debe decir «IMPAGO» o el canal por el que entra la solicitud (oficina, teléfono…)?
Hay que hacer caso siempre a lo que diga el servicio de decisión a la hora de mandar a contra anulación o acciones administrativas



**A5. Servicio de pólizas caído (Excel 24).** En SCA, si no se puede consultar la póliza, aparece «Servicio caído» y no deja guardar.
- *Duda:* ¿SCA2 debe hacer lo mismo (bloquear el alta) o permitir guardar la solicitud y completarla después cuando el servicio vuelva?
Debe de hacer lo mismo que en SCA


**A6. Datos adicionales del alta (Excel 26).** SCA envía al proceso la IP del usuario y marcas del cliente (PECA, lista Robinson) y tiene una configuración («flagActivoPMO») que decide si se avisa de que ya hubo una solicitud en la misma anualidad.
- *Duda:* ¿se usan hoy para algo (informes, auditoría, correos)? ¿Sigue vigente el aviso de «solicitud anterior en la misma anualidad»? Si no se usan, los dejamos fuera.
Sigue vigente.



**A7. Pólizas de Vida (Excel 23).** Confirmado que crean solicitud y pasan por contra anulación.
- *Duda:* ¿la contra anulación de Vida la hace el mismo grupo que Autos/Hogar o un grupo específico? ¿Tiene argumentario y catalogación propios o los mismos? ¿Hay algún paso distinto (p. ej. no se mecaniza desde SCA2)?
Con vida pasa igual que con el resto, todo lo decide las reglas de decisión, tanto su catalogación como argumentario...etc





## B. Contra Anulación (tareas, POSPONER, RETOMAR, REASIGNAR)

**B1. Conservar la Oficina al retomar (Excel 12c).** Confirmado como deseable.
- *Hoy en SCA2:* igual que SCA, al retomar hay que volver a elegir la oficina si el gestor tiene varias. Para guardarla hace falta **un dato nuevo en la solicitud** (una columna en la base de datos de SCA2).
- *Duda:* ¿confirmáis que se cree ese dato nuevo? ¿La oficina debe conservarse también en Acciones Administrativas y Autorización, o sólo en Contra Anulación?
La oficina debe consevarse sí. Entiendo que devin está hablando de la base de datos de AWS 


**B2. Quién puede retomar una tarea de otro grupo tras un salto de nivel.** Con la póliza RCI 0005726674052, JJGONZ2 (oficina) hizo la contra anulación de nivel 1 y la de nivel 2 quedó para el grupo CE_MF_BK. SISANS (SI24 Experto) **no pudo retomarla**, igual que en SCA.
- *Duda:* ¿a qué grupo debe ir la contra anulación de nivel 2 de una póliza RCI: a SI24 Experto, a CE_MF_BK o lo decide el motor de reglas según la póliza? ¿Un experto de SI24 debe poder retomar tareas de otros grupos?
Si , lo decide el motor de reglas 
estas son algunas de las respuestas donde CE_MF_BK_EXPERTOSI24 hace referencia a expertos Si24 y CE_RM a la oficina Red mapfre
{"accion":"CONTRA ANULAR NIVEL 2","grupo":"CE_RM","subgrupo":"CE_RM"}
{"accion":"ACCIONES ADMINISTRATIVAS NIVEL 2","grupo":"CE_RM","subgrupo":"CE_RM"}
{"accion":"CONTRA ANULAR NIVEL 2","grupo":"CE_MF_BK","subgrupo":"CE_MF_BK_EXPERTOSI24"} es de SI24


**B3. Administradores y tareas asignadas (Excel 10).**
- *Duda:* ¿un administrador puede retomar una tarea que está asignada a otro gestor sin reasignársela antes? Hoy sí puede.
Pues si


**B4. Dos tareas pendientes en la misma solicitud (Excel 11).** Puede ocurrir que una solicitud tenga a la vez una contra anulación de nivel 2 pendiente y una autorización pendiente.
- *Duda:* ¿cuál debe ver primero el gestor al entrar en la solicitud? ¿Deben poder tramitarse las dos o una bloquea a la otra?
(Sería interesante ver si DEVIN pudiera tener acceso a aceptar o rechazar en NSE o WAutemis y completar las pruebas) 
En cualquier caso no puede haber nunca dos solicitudes funcionando a la vez. Hasta que una no ha terminado no se puede abrir otra.


**B5. Qué manda cuando CORE y SCA2 no coinciden (Excel 12).** Ejemplo: CORE dice que la gestión está finalizada pero en SCA2 la tarea sigue pendiente (o al revés).
- *Hoy en SCA2:* el estado que se muestra es el de CORE y los botones (RETOMAR, REASIGNAR) dependen de la tarea SCA2.
- *Duda:* ¿es correcto? Si CORE dice «finalizada», ¿debe cerrarse la tarea de SCA2 automáticamente?
Lo que dice CORE. los botones retomar y reasignar solo se muestran cuando el estado es distinto de finalizado

**B6. Grupo de asignación tras un cambio de nivel (Excel 19).** El analista indica que el motor de reglas devuelve también el grupo.
- *Hoy en SCA2:* cuando el motor decide subir de nivel, la tarea nueva se asigna al grupo que corresponde al perfil que devuelve el motor.
- *Duda:* ¿hay casos en los que el grupo devuelto por el motor y el perfil no coinciden (p. ej. perfil SI24 pero grupo de Backoffice)? Si es así, ¿manda siempre el grupo del motor?
Manda el motor estas son algunas de las respuestas donde CE_MF_BK_EXPERTOSI24 hace referencia a expertos Si24 y CE_RM a la oficina Red mapfre
{"accion":"CONTRA ANULAR NIVEL 2","grupo":"CE_RM","subgrupo":"CE_RM"}
{"accion":"ACCIONES ADMINISTRATIVAS NIVEL 2","grupo":"CE_RM","subgrupo":"CE_RM"}
{"accion":"CONTRA ANULAR NIVEL 2","grupo":"CE_MF_BK","subgrupo":"CE_MF_BK_EXPERTOSI24"} es de SI24

**B7. Perfil y subperfil de la Acción Administrativa de nivel 2.** Con SISANS, la Acción Administrativa de nivel 2 de la póliza 0000253500286 (15787865) dio un error técnico de CORE al registrar la acción.
- *Duda:* ¿qué perfil/subperfil debe enviarse a CORE cuando la Acción Administrativa de nivel 2 la hace un experto de SI24? ¿Debe existir siquiera una Acción Administrativa de nivel 2 o siempre es de nivel 1?
Falta una funcionalidad que resuelve esta duda:
Desaparece la pregunta de “Insiste en anular técnico” EXCEPTO para perfiles de CCC. 

No se pasará valor a reglas excepto, como decimos, a perfiles de CCC.

Como siempre, reglas determinará si la póliza va a mecanizar (abrir operacional en Vida) o a saltar de nivel, pero frontal va a tener que controlar el estado de la póliza como está haciendo ahora:

Al iniciar el proceso si la póliza está anulada, avisaremos del estado de la misma para que la rehabiliten en caso de querer tarificar.

Al finalizar positivo: Frontal determinará en el estado de la póliza si esta está anulada, en tal caso avisará al usuario de que es necesario que vaya a rehabilitar la póliza. 

Al finalizar negativo: Frontal determinará si el estado de la póliza es anulada, en cuyo caso no será necesario que abra la pantalla de anulación o en caso de Vida abra enlace a operacional.

Otro de los cambios especiales es que los perfiles de Si24 ya no harán Acciones administrativas, por lo que para ellos quedan ocultas las causas:

13-Seguro regalado por la compra de coche

14-No voy a comprarme otro coche

31-Venta con Reemplazo (Hogar)

32-Venta sin Reemplazo (Hogar)

16-Baja vehículo

17-Baja temporal

18-Siniestro total

28-Anulación fuera de norma

Cuando un perfil Red recupera una póliza que se envió a nivel 2 para Si24 y no puede anular, suele enviar un mensaje al CUE lo que finalmente conlleva doble trabajo burocrático. 

Por lo tanto se va hacer lo siguiente:

No aparecerá el botón de Recuperar para el perfil Red mapfre si la póliza se encuentra pendiente de nivel 2 para un usuario Si24 (obviamente no cuando sea para red mapfre).

En contra anulación, si se trata de una póliza de acuerdos y estamos en primer nivel, saldrá un mensaje indicando que las pólizas de acuerdos se tratan a través de SI24 y que red Mapfre no las puede anular (nos tienen que pasar un mensaje) 

En el detalle de la solicitud de anulación cuando la póliza esté pendiente de Si24 se mostrará un mensaje indicando que esta solicitud la está gestionando Si24 y al ser una póliza de acuerdos la solicitud de anulación la finalizará el usuario de Si24. No hay que mandar gestión de anulación al CUE en estos casos.  (nos tienen que pasar un mensaje) 


## C. Mecanización, Emisión y Autorización

**C1. Códigos de Emisión (Excel 1).** Tras lanzar la anulación, Emisión (wAutemis) responde con un código. Hoy, SCA y SCA2 consideran «pendiente de autorizar» sólo si la respuesta trae las observaciones 00000005 o 00000006; en cualquier otro caso se da por «anulación directa».
- *Duda:* ¿hay más códigos que signifiquen «pendiente de autorizar» o «rechazada»? ¿Las pólizas de NSE (Autos/Hogar) también pueden quedar pendientes de autorizar, o eso sólo pasa en wAutemis?
Esos código son de WAutemis. Para NSE existe otros procedimientos en código de SCA, haz lo mismo.


**C2. Tarjeta de Autorización (Excel 2).** Cuando la anulación queda **pendiente de autorizar**, en el Detalle aparece la tarjeta «Autorización».
- *Duda:* ¿quién debe poder verla y actuar (el director de oficina, SI24, Backoffice)? ¿Qué botones debe tener (ACEPTAR, RECHAZAR, RETOMAR) y qué pasa con la solicitud en cada caso?
Es un servicio externo a SCA que realiza el cambio de estado. No es necesario botones.


**C3. Si Emisión no responde nunca (Excel 3).** El analista indica que la solicitud **caduca**.
- *Duda:* ¿a los cuántos días caduca? ¿Debe avisar a alguien antes (correo, tarea)? ¿Puede el gestor cerrarla a mano antes de la caducidad? Hoy SCA2 espera 24 horas la respuesta de ANL y después registra un error; en las pólizas NSE ya no espera.
Los resolvemos haciendo más pruebas para ver el comportamiento



**C4. CORE dice «anulación realizada» pero Emisión no ha desbloqueado (Excel 4).** El analista indica que prevalece el no desbloqueo.
- *Duda:* entonces, ¿qué debe ver el gestor en el buscador y en el Detalle mientras tanto («Mecanización enviada», «Pendiente»)? ¿Y puede retomar la solicitud?

No se puede hacer nada mientras está bloqueada. 


**C5. Anulación directa NSE (Excel 12b).** Confirmado: puede seguir hasta el final y ser retomable.
- *Duda:* tras la anulación directa, ¿qué paso debe abrirse: una contra anulación de nivel 2 (como hace hoy) o directamente la finalización? ¿Qué texto de estado debe ver el gestor en el buscador?
Eso lo decide el servicio de decisión.


## D. Impresión y documentos

**D1. Dónde se considera guardado un documento (Excel 6).** El analista indica que depende del contexto.
- *Contexto concreto:* antes de **volver a generar la carta de impresión** (al retomar o relanzar una solicitud) comprobamos si ya existe para no duplicarla. Hoy miramos CORE (gestión 4) y la base de datos de SCA2.
- *Duda:* para esa comprobación, ¿basta con CORE + SCA2 o hay que consultar también Documentum?
No es necesario documentum.



**D2. Impresión a medias (Excel 7).** Puede pasar que exista la gestión de impresión en CORE pero no el documento, o al revés.
- *Duda:* ¿se repite sólo la parte que falta o se vuelve a generar todo (gestión + carta)?

Puede pasar que esté en documentum pero no en core. Hay que probarlo para poder decidir.



**D3. Relanzar un error que dejó cosas a medias en CORE (Excel 8).** Ejemplo: se creó la gestión en CORE pero falló el paso siguiente; al relanzar desde la bandeja de errores podría crearse la gestión dos veces.
- *Duda:* ¿preferís que el relanzamiento **reutilice** lo que ya está en CORE (comportamiento actual, cuando lo podemos detectar) o que cree siempre de nuevo y se limpie a mano?
que reutilice lo que ya está en core.


## E. SI24, DUE y correos

**E1. Correo DUE (Excel 16 y 17).** Pendiente de JE.
- *Duda:* texto definitivo del correo, buzón de destino por entorno (TEST/PRO) y cómo se confirma que ha llegado (hoy sólo se marca «enviado» en la solicitud). En TEST se registra el envío a JOSPENA@mapfre.com pero no hemos podido comprobar la recepción.
Los correos llegar correctamente. Falta informar un teléfono o email lo cual es obligatorio.


## F. Buscador y Detalle

**F1. Detalle de solicitudes de SCA / históricas (nuevo).** Ya se muestran en el buscador de SCA2 en una segunda tabla («Otras solicitudes…»), pero **no se puede abrir su Detalle**
 porque esas solicitudes no existen en SCA2 (ni sus tareas).
- *Duda:* ¿debe abrirse un Detalle de **sólo lectura** con los datos de CORE (cabecera, gestiones, documentos), como hace SCA? ¿O basta con verlas en la lista? Si se abre el Detalle,
 ¿debe poder retomarse una solicitud que se creó en SCA desde SCA2?
Lo que hace SCA. Solo lectura y no se puede actuar sobre esas solicitudes desde ahí. 


**F2. Filtros sobre las solicitudes de SCA / históricas (nuevo).** Los filtros de Estado y Línea de negocio hoy sólo se aplican a las solicitudes de SCA2.
- *Duda:* ¿deben aplicarse también a la segunda tabla?

¿qué segunda tabla? 

**F3. Fecha de resolución en solicitudes pendientes.** Tanto SCA como SCA2 muestran una fecha de resolución aunque la solicitud esté Pendiente (dato que viene de CORE).
- *Duda:* ¿es correcto o debería quedar vacía hasta que se resuelva?

Cuando esté pendiente que no lo muestre; después sí.

## G. Errores, reintentos y datos

**G1. Reintentos automáticos (Excel 27).** Hoy: 3 intentos en Documentum y en las grabaciones de CORE; ANL se consulta cada 5 minutos durante 24 horas.
- *Duda:* ¿os parecen bien esos números o queréis otros? ¿Hay alguna integración que no deba reintentarse nunca?
Todo correcto excepto ANL que necesitamos contexto de cuando se hace eso

**G2. Tras 24 horas sin respuesta de ANL (Excel 28).**
- *Duda:* ¿la solicitud debe quedar como error relanzable (hoy), caducar o avisar a alguien?
¿qué se hace en SCA?

**G3. Quién relanza o descarta errores (Excel 29).** Hoy sólo administradores, y queda registrado quién lo hizo.
- *Duda:* ¿correcto? ¿Debe poder hacerlo también Backoffice o SI24?

Solo administradores

**G4. Solicitudes de prueba que existen en CORE (Excel 30).** Quedan 75 solicitudes de pruebas antiguas en SCA2 que también existen en CORE.
- *Duda:* ¿se conservan o se borran de SCA2 (en CORE seguirían existiendo y se verían en la tabla de «Otras solicitudes»)?
Si son solicitudes que están sin termianr por eerores se finalizan par liberar


-1. **Alta:** SCA deja pulsar GUARDAR y avisa de los campos obligatorios; SCA2 no deja pulsar hasta completarlos. ¿Cuál se quiere?

- No dejar pulsar hasta completarlos.

2. **Acción Administrativa pospuesta de nivel 1:** en SCA SISANS sólo puede consultarla; en SCA2 puede retomarla. ¿Quién debe poder retomar?

- Solo puede consultarla por Si24.

3. **Autorización pendiente tras mecanizar:** SCA muestra el mensaje de petición de autorización y estado «Pendiente»; SCA2 muestra «anulación lanzada» y «Mecanización enviada». ¿Igualamos?

- No, se queda como está en SCA2.

4. **Cancelar una autorización:** CORE devuelve error en TEST tanto desde SCA como desde SCA2; SCA2 muestra «Correcto» y registra el fallo después. ¿Cómo debe verlo el usuario?

- Lo tenemos que probar.

5. **Buscador:** la lista inicial de SCA trae todas las solicitudes del gestor en CORE; SCA2 sólo las creadas en SCA2. ¿Debe traer todas? La pestaña «Otras solicitudes de anulación», ¿debe alimentarse de CORE como SCA?

- Dejarlo como está.

6. **SI24:** las preguntas de contacto, el cierre «Ilocalizable» a la tercera gestión y la impresión (activa en SCA aunque el plan la espera inactiva). ¿Qué comportamiento es el correcto?

- Necesitamos más contexto para responder esta pregunta.

7. **Presentación:** maquetación de la pestaña Cliente e icono del hito Anulación, ¿hay que igualarlos a SCA?

- Dejarlo como está en SCA2.

8. **Desactivar/Activar la aplicación:** no se ha probado porque el interruptor de CORE es común y apagaría también SCA. ¿Se prueba igualmente?

- No.

 