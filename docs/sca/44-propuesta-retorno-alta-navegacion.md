# Propuesta: qué pasa tras GUARDAR en el alta de SCA2 — navegación simulada (ronda 24, duda #9)

> Respuesta a la petición del analista: «Necesitamos entender qué supone y una propuesta de navegación simulada de cómo actuaría el sistema». No está implementado; es una propuesta para decidir.

## 1. Qué pasa hoy (SCA2) y por qué molesta

```
[Alta] GUARDAR ──► CORE crea la solicitud (1–2 s) ──► SCA2 graba sus datos ──► motor decide la acción (CORE decidirAccion + crear tarea: 3–30 s)
                                                                              │
          mientras tanto la pantalla sigue en el FORMULARIO con el aviso «Determinando la acción…» (se refresca cada 30 s)
                                                                              ▼
                                                      salto a Contra Anulación / Acción Administrativa / Autorización
```

Problemas: (a) el usuario ve el formulario con los datos durante hasta 30 s y puede volver a pulsar GUARDAR (segunda alta) o irse; (b) si el motor tarda o falla, el formulario «vuelve» y parece que no se ha grabado nada (caso 15788025); (c) el refresco de Appian es de 30 s como mínimo, no se puede acelerar desde el formulario.

En SCA el alta se hace con un proceso: el usuario queda en una tarea de espera y la siguiente pantalla aparece cuando el proceso llega a ella (también con refresco de 30 s, pero sin volver nunca al formulario).

## 2. Propuesta

Regla: **el formulario desaparece en cuanto CORE devuelve el número de solicitud**. A partir de ahí el usuario está siempre «dentro» de la solicitud (Detalle), y es el Detalle el que abre la acción cuando existe.

```
[Alta] GUARDAR
   │ 1–2 s: CORE devuelve nº solicitud (p. ej. 15788200)
   ▼
[Detalle de la solicitud 15788200]  ← ya con número, póliza, catalogación, estado «Alta realizada»
   │  tarjeta «Siguiente acción»: «Determinando la acción…» (spinner)         ← mientras el motor decide
   │  botones: ninguno de acción (sólo «Volver al buscador»)
   ▼ (3–30 s, en cuanto existe la tarea; el Detalle se refresca solo)
[Pantalla de la acción decidida]  → Contra Anulación / Acción Administrativa / Autorización fuera de norma
   │  se abre automáticamente, sin pulsar nada, como ocurre hoy desde el formulario
   ▼
… flujo normal (FINALIZAR, Verti, mecanización, etc.)
```

Casos de borde:

| Situación | Qué ve el usuario |
|---|---|
| El motor tarda más de lo normal | Sigue en el Detalle con «Determinando la acción…»; puede irse al buscador y la solicitud aparece en «Mis tareas» cuando exista la tarea. Nunca vuelve al formulario. |
| El motor falla (3 reintentos) | Detalle con aviso «No se ha podido determinar la acción; el administrador la relanzará» y la fila en la bandeja de errores. La solicitud existe en CORE y en SCA2; no hay que volver a darla de alta. |
| El usuario pulsa atrás o F5 | Vuelve al Detalle (la URL ya es la de la solicitud), no al formulario. GUARDAR no puede repetirse. |
| CORE falla al crear la solicitud | Se queda en el formulario con el error de CORE (como hoy): no hay número, no hay nada que mostrar. |
| El usuario abre la solicitud desde el buscador antes de que exista la tarea | Mismo Detalle con «Determinando la acción…». |

## 3. Qué supone

- Pantallas: el alta deja de esperar al motor (sólo espera a CORE); el Detalle incorpora la tarjeta «Siguiente acción» con el aviso y el salto automático a la acción cuando la tarea existe (la lógica del salto ya existe en el formulario; se mueve al Detalle).
- Procesos/datos: ninguno. El motor (Decidir + Crear acción) sigue igual, encadenado tras el alta; sólo cambia dónde está el usuario mientras tanto.
- Tiempo visible: el formulario desaparece en 1–2 s; la espera hasta la acción es la misma que hoy (3–30 s) pero se pasa en el Detalle con la solicitud ya visible. Se puede acortar encadenando Decidir/Crear acción en el mismo comando del alta (hoy son pasos separados).
- Riesgo: bajo; no toca CORE ni ANL. Se prueba con solicitudes nuevas comparando con SCA (alta → acción) y forzando un fallo del motor para ver el aviso.

## 4. Alternativas descartadas

- **Esperar en el formulario con GUARDAR deshabilitado**: evita la doble alta, pero el usuario sigue hasta 30 s mirando un formulario y, si el motor falla, el formulario «vuelve» igual.
- **Esperar al motor dentro del propio GUARDAR**: no es posible en Appian (un clic no puede esperar a varios smart services) y bloquearía la pantalla.
- **Pantalla intermedia «Procesando…»**: equivalente a la propuesta pero sin mostrar la solicitud; el Detalle da la misma información y ya existe.

## 5. Decisión que se pide
Aprobar la navegación del §2 (Alta → Detalle con «Determinando la acción…» → acción automática) o indicar qué debe ver el usuario en cada paso.
