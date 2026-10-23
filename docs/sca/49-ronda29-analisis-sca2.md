# Ronda 29 — cuarto «Análisis SCA2» (prueba punto a punto del analista, 23/10/2026): clasificación y reparto

| # | Punto del analista | Qué hay que hacer | Quién |
|---|---|---|---|
| 1 | El servicio de contacto se llama varias veces con la misma respuesta | Persistir la primera respuesta en la solicitud y reutilizarla. | R29-C |
| 2 | Tras ACEPTAR en «Procesando la decisión…» SCA2 va al buscador; debe ir automáticamente a la siguiente tarea (Gestión Verti/Vencimiento) | Navegación automática a la siguiente tarea de la solicitud (y mismo criterio en el alta, #9). | R29-A |
| 3 | Pantalla Verti/Vencimiento: sin marcar un check no debe poder iniciarse el componente | CONTINUAR deshabilitado sin check; guardar la opción para el CMP (tipoInduccion). | R29-A (guardar) / R29-C (leer) |
| 4 | El componente Verti y «actualizar mecanización» van en secuencia; deben ir en paralelo para que la siguiente acción de SCA2 esté preparada aunque Verti falle | Ramas paralelas en `CMD Mecanizar`: CMP encadenado ∥ actualizar mecanización → ANL → decidir acción. | R29-C |
| 5 | Tras el componente calcula nivel 2 y CA nivel 2: **OK** | — | — |
| 6 | Pantalla de argumentos nivel 2 «genial», pero en dos tablas (anteriores sin checks / disponibles) | Dos grids. | R29-B |
| 7 | Documentos: «no se están cargando, no se lanzan las instancias de obtener documento» (visor «Documento no disponible») | Recuperar el documento del SGD como SCA al pulsar el ojo. | R29-B |
| 8 | Detalle: debe salir «Gestión Verti/Vencimiento» con el check seleccionado y la gestión del componente con su resultado | Tarjetas con contenido (la ronda 28 las ocultó). | R29-A |

Coordinación: `pruebas/coordinacion-ronda29.md`. Informes: `pruebas/r29-a-redireccion-verti-tarjetas.md`, `pruebas/r29-b-argumentos-dos-tablas-documentos.md`, `pruebas/r29-c-contacto-paralelo.md`.
