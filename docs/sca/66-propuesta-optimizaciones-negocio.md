# 66 — Optimizaciones de SCA2 que cambian el funcionamiento: propuesta para analistas y negocio

> Fecha: 10/11/2026. Entorno de medición: Appian TEST (que llama a los servicios de PRE).
> Estas propuestas **no están aplicadas**. Cada una necesita una decisión de negocio, porque cambia lo que ve o lo que hace el usuario.
> Las que no cambian el funcionamiento se han revisado aparte en R47-B: la cabecera ya hacía en paralelo las llamadas independientes, así que no se ha cambiado; el aviso de procesos en espera ya está en el cuadro de mando.
> Contexto y mediciones: doc 65.

## Resumen

| # | Propuesta | Tiempo hoy | Ganancia estimada | Qué cambia para el usuario | Decisión que se pide |
|---|---|---|---|---|---|
| 1 | Usar la caché de cabecera también en el alta | 1,4–4,8 s de cabecera en el alta (mediana según póliza, R47-B) | Bajar a ~0,1–0,2 s (estimado) | Los datos de cabecera pueden tener hasta un día de antigüedad | ¿Se acepta? ¿Con qué caducidad? |
| 2 | Argumentario más rápido | 8,7 s de media, 29 % de fallos, hasta 300 s bloqueado | < 1–2 s (estimado) | Error con «Reintentar» a los 30 s; los cambios de mantenimiento pueden tardar en verse; argumentario «en preparación» | Tiempo máximo de espera; refresco del catálogo; generación fuera de pantalla |
| 3 | Espera a NSE/ANL en segundo plano | Hasta 5 min de espera (una cadena llegó a 9,5 min) | El usuario no espera | El usuario sale con un estado «En proceso» y el resultado aparece después | ¿Se acepta? ¿Qué estado y qué aviso? |
| 4 | Decisión con salto a Si24 | 55–70 s (SCA: 25–45 s) | Acercarse a SCA (estimado) | Ninguno visible si sale bien; riesgo de leer un estado sin actualizar | ¿Se acepta probarlo? |

Las ganancias son estimaciones a partir de las mediciones de TEST; se medirían antes de aplicar nada.

## 1. Cabecera: usar la caché también en el alta

**Hoy.**
- Con una solicitud abierta, la cabecera ya se lee de una caché que caduca a las 05:00 del día siguiente. El botón «Actualizar datos» fuerza el refresco (doc 43-D, R38-A).
- En el **alta** no hay solicitud todavía. Por eso la cabecera se pide siempre en vivo a reserva de prima, siniestros, cliente, contactos, etc., y tarda entre 1,4 y 4,8 s de mediana según la póliza (R47-B). Las llamadas que no dependen de otra ya van en paralelo, así que **esta es la única mejora grande que queda en la cabecera**.

**Propuesta.** Guardar la caché también por póliza y usarla en el alta si es del mismo día.

**Qué cambia.**
- Un siniestro, un cambio de cliente o una reserva de prima hechos hoy podrían no verse en el alta hasta que se pulse «Actualizar datos» o caduque la caché.
- SCA no usa caché en el alta.

**Preguntas**
1. ¿Es aceptable que el alta enseñe datos de cabecera de hasta un día de antigüedad?
2. ¿Hay algún dato que tenga que ir siempre en vivo, como siniestros, reserva de prima o un cliente bloqueado?
3. Si se acepta, ¿con qué caducidad: las 05:00 como ahora, unas horas, u otra?

## 2. Argumentario (`consultarListadoArgumentos`)

**Hoy.** Es la integración más lenta de SCA2: 8,7 s de media, un 29 % de fallos y dos esperas de 300 s con la pantalla bloqueada. En SCA tarda más: 11,2 s. El tiempo se va en el backend (doc 59).

**Propuesta, en tres partes que se pueden decidir por separado.**

| Parte | Qué cambia para el usuario | Necesita backend |
|---|---|---|
| 2a. Bajar el tiempo máximo de espera de 300 s a 30 s, con mensaje y botón «Reintentar» | Si el servicio tarda más de 30 s, el usuario ve un aviso y reintenta. Hoy espera hasta 5 minutos | No |
| 2b. Guardar en Appian el catálogo de argumentos (descripción, instrucciones, URL), que casi no cambia, y refrescarlo al guardar en el Mantenimiento y una vez al día | Un cambio hecho en el Mantenimiento de SCA (no en el de SCA2) puede tardar hasta un día en verse en SCA2 | No |
| 2c. Generar el argumentario (motor de reglas BRMS) en el proceso al crear la tarea, no al abrir la pantalla, y leer el estado de los argumentos con un servicio rápido | La primera vez puede salir «Preparando argumentario» y refrescarse sola. Afecta a cuándo se genera el argumento 999 | Sí (servicio nuevo o cambio en `es_pca_gestionartareas_bbe-web`) |

**Preguntas**
1. 2a: ¿cuánto tiempo máximo puede esperar el usuario: 30 s, 60 s?
2. 2b: ¿el catálogo se mantiene solo desde SCA2, o también desde SCA mientras convivan las dos?
3. 2c: ¿se puede generar el argumentario al crear la tarea, aunque no se llegue a abrir? ¿Afecta a cómo se cuentan o se informan los argumentos?
4. 2c: ¿qué equipo del backend lo haría, y en qué plazo?

## 3. Espera a NSE/ANL en segundo plano

**Hoy.** Después de anular o decidir, SCA2 espera el resultado de NSE/ANL dentro del propio proceso: 10 consultas cada 30 s, es decir, 5 minutos como máximo.
- En una prueba, la cadena Finalizar → Decidir → CrearAccion tardó unos 9,5 minutos.
- Mientras tanto, el usuario ve un estado provisional y el proceso sigue ocupado.
- Con muchos usuarios a la vez, estas esperas se acumulan en el motor de procesos (inferido; no se ha medido).

**Propuesta.**
- La acción del usuario termina enseguida y la solicitud queda en un estado explícito, por ejemplo «En proceso de anulación».
- La espera la hace un subproceso aparte, que actualiza el estado al terminar. Si se pasa del tiempo máximo, envía el error al listado de errores, como ahora.

**Qué cambia.**
- El usuario no ve el resultado al terminar, sino después: tiene que volver o refrescar la pantalla.
- SCA no funciona así.

Es la duda 63-24 / doc 64 A.6, que sigue abierta.

**Preguntas**
1. ¿Se acepta que el resultado de NSE/ANL llegue después?
2. ¿Qué estado y qué texto se muestran mientras tanto?
3. ¿Hay que avisar al usuario cuando termine, o basta con que aparezca en la lista o en el detalle?
4. ¿Se puede trabajar sobre la solicitud mientras está «En proceso»? Proponemos que no: solo se podría consultar.

## 4. Decisión con salto a Si24

**Hoy.** Una contra anulación negativa que pasa a Si24 tarda en TEST unos 55–70 s; en SCA, unos 25–45 s.
- Son unos 38 s de backend, porque el motor da dos vueltas completas (CompletarAccion → Decidir → CrearAccion de nivel → Decidir → CrearAccion), más la llamada a CORE.
- A eso se suma una consulta de la pantalla cada 30 s, como máximo (doc 48).

**Propuesta.**
- Hacer en una sola vuelta del motor el cambio de nivel y la creación de la tarea Si24.
- Comprobar más a menudo si la tarea está lista, por ejemplo cada 5 s en lugar de cada 30 s.

**Qué cambia.**
- Si sale bien, nada visible: la tarea aparece antes.
- El riesgo es que, al juntar las dos vueltas, se lea el nivel o el grupo de CORE antes de que se actualice y la solicitud se asigne mal.
- Hay que probarlo con varias solicitudes nuevas y compararlo con SCA.

**Preguntas**
1. ¿Se acepta tocar este flujo, sabiendo que es el de asignación a Si24?
2. ¿Hay algún paso de la doble vuelta que negocio necesite ver, por ejemplo una traza o una observación intermedia?

## 5. Procesos que se quedan esperando (R47-B)

**Hoy.**
- Cuando una mecanización abre la inducción Verti en CMP, el proceso `SCA2 CMD Mecanizar` se queda esperando hasta que alguien completa esa tarea, aunque sean días.
- En TEST hay ahora 5 solicitudes así, de entre 7 y 18 días. Se ven en el aviso nuevo del cuadro de mando:
  - 15788699 y 15788703 tienen el proceso todavía activo.
  - 15788323, 15788326 y 15788540 tienen la tarea pendiente, pero el proceso ya no existe.
- Además, en la 15788703 hay una `CompletarAccion` parada en «Start decidir».

**Preguntas**
1. ¿Quién tiene que completar la tarea de inducción en CMP? ¿Hay un plazo máximo?
2. ¿Se cierran las 3 tareas huérfanas o se dejan?
3. ¿Se acepta que la mecanización no espere a la inducción (hacerla asíncrona)? Cambia cuándo se cierra la tarea `INDUCCION` y cuándo sigue la solicitud.
4. ¿Basta con el aviso del cuadro de mando, o hay que mandar un correo diario? Si es correo, ¿a quién?
5. Las instancias terminadas se borran al día siguiente. ¿Hay que guardarlas más tiempo (por ejemplo, 7 días) para poder investigar incidencias? Ocupa más memoria del motor.

## Lo que pedimos

Que cada propuesta quede marcada como **Sí / No / Sí con condiciones**, contestando a sus preguntas. Con eso, la implementamos en TEST, la probamos con solicitudes nuevas, la comparamos con SCA y medimos el antes y el después.
