# R52b — Validación con CORE operativo y límite de reintentos de Decidir (SCA2, Appian TEST)

Fecha: 17/11/2026. Continuación de [R52](r52-tareas-repetidas-usuario-real.md). El informe omite identificadores y copias completas de los objetos.

## 1. Validación en pantalla con CORE operativo

El site y el buscador cargaron sin aviso de CORE. Se abrieron cuatro solicitudes y cada una tenía una sola tarea `PENDIENTE`; las tareas canceladas no se reactivaron. En un caso se vieron dos tarjetas «Mecanización Incompleta»; falta cruzarlas con las transiciones.

## 2. Bucle de reintentos y corrección v22

En las versiones 18 y 21 de `SCA2 CMD Decidir`, el nodo 5 «Consultar reglas» calculaba `pv!intentos` contando los errores pendientes. Como «Write Error» actualiza una sola fila, el contador del proceso se quedaba en 2 y nunca llegaba al límite de 3. En una prueba, la solicitud llegó a 99 intentos y Appian cortó la cadena por el límite de profundidad de subprocesos. Un administrador de TEST canceló la instancia que quedó activa; eso detuvo la ejecución, pero no verificó la corrección.

En v22 solo cambió la salida del nodo 5 a `pv!intentos`.

Antes:

```text
a!defaultValue(rule!SCA2_contarErroresPendientes(idSolicitud: pv!idSolicitud, comando: "SCA2 CMD Decidir"), 0) + 1
```

Después:

```text
a!defaultValue(index(rule!SCA2_obtenerErrorPendiente(idSolicitud: pv!idSolicitud, comando: "SCA2 CMD Decidir", nodo: a!defaultValue(pv!wrNodo, "Consultar reglas"), codigo: a!defaultValue(pv!wrCodigo, "DECISION_ERROR")), "intentos", 0), 0) + 1
```

La expresión lee `intentos` de la misma clave que actualiza «Write Error». Sin fila devuelve 1; con un contador de 2 devuelve 3 y toma la rama existente `Error>=3`. El validador no resolvía las variables del proceso; la expresión se validó sustituyéndolas por literales.

## 3. Verificación del límite y del usuario funcional

En un alta posterior, se lanzaron exactamente tres instancias, con `pv!intentos` de 1, 2 y 3. «Write Error bloqueado» registró el error bloqueado tras el tercer intento, sin lanzar otro. La transición de alta y `modifiedBy` conservaron el usuario funcional que ejecutó la prueba.

## 4. Pendientes y comparación SCA/SCA2

- No se probaron POSPONER/RETOMAR, Contra Anulación, Acción Administrativa ni RECARGAR: los intentos de alta de la muestra acabaron en `DECISION_ERROR` sin generar tarea.
- Se comparó en lectura la integración de decisión en SCA y SCA2 para dos casos: se enviaron los mismos DTO y las cuatro respuestas devolvieron el mismo HTTP 500 / 1107 / ERROR, con `CODE005` y `CODE011`. La prueba no apunta a una regresión de SCA2; no confirma la causa raíz del fallo común.
- Se cribaron otras 15 pólizas sin solicitud SCA2 en curso, con canal y subcanal informados en los datos de productor. El mapeador y la integración de SCA2 devolvieron el mismo fallo en todas. Para verificar el ciclo completo hace falta un caso que produzca una decisión válida en TEST.
