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

## Resultados de la ronda 29 (23/10; informes `pruebas/r29-*.md`)

| # | Punto | Resultado | Objetos SCA2 | Pregunta abierta |
|---|---|---|---|---|
| 1 | Contacto reutilizable | **Aplicado**: primera respuesta persistida en `SCA2 Datos Solicitud` (`respContacto`, `fechaRespContacto`) y reutilizada (una sola llamada por solicitud). 15788323. | `SCA2_determinarContacto` (caché + fallback), `SCA2_determinarContactoLive` (nueva), Web API `SCA2_guardarContacto` + integración (nuevas), record type Datos Solicitud | La respuesta guardada incluye la URL de la tarea del componente de la 1.ª llamada: ¿se usa después? |
| 2 | Redirección tras ACEPTAR | **Aplicado**: ACEPTAR abre la siguiente tarea de la solicitud (Verti/Vencimiento) sin buscador; se habilita cuando el motor ha decidido (≈30-40 s). 15788314. | `SCA2_DetalleTareas` v37 | ¿Un único ACEPTAR o aviso adicional mientras decide? Tarea de nivel 2 (otro grupo): ¿abrir directo o Detalle → RETOMAR? Alta → siguiente tarea (#9) sigue pendiente de OK. |
| 3 | Checks Verti/Vencimiento | **Aplicado**: CONTINUAR deshabilitado sin check (SCA permite continuar sin marcar); opción guardada en la tarea VERTI (`tokenTarea VERTI:<sel>`) y leída por `CMD Mecanizar` → `tipoInduccion` I/V/A. | `SCA2_VertiVencimientoPrincipal` v14, `CMD CrearAccion` nodo 34, `CMD Mecanizar` | Variante Verti+Vencimiento (A) no probada en UI. |
| 4 | Componente en paralelo | **Aplicado**: `CMD Mecanizar` con ramas A (CMP encadenado) ∥ B (actualizar mecanización → ANL → decidir acción); CA nivel 2 creada con el CMP abierto (15788319/15788323). SCA: mecanización actualizada con CMP abierto pero sin CA nivel 2; 403 en el CMP de vencimientos de SCA. | PM `SCA2 CMD Mecanizar` (End 341) | **D-R29A-4**: en 15788314 SCA2 finalizó (FIN) con la mecanización CORE «INCOMPLETA» (SCA: Anulación Realizada + CA nivel 2): ¿la rama B debe esperar la confirmación de CORE antes de decidir nivel/FIN? Cierre de la gestión INDUCCION al terminar/caducar el CMP pendiente de verificar. |
| 6 | Dos tablas de argumentos | **Aplicado**: anteriores sólo lectura (alfabético) / disponibles con selección; NEGATIVO sobre la fila correcta. 15788313. | `SCA2_ContraAnulacionArgumentarioEstrategicas` v5 | En SCA TEST la CA nivel 1 negativa «enviado a SI24» no creó la CA nivel 2 (15788312): ¿esperado? POSITIVO en nivel 2 y orden con varios anteriores sin probar. |
| 7 | Documentos | **Corregido**: el ojo nunca lanzaba `SCA2 CMD ObtenerDocumentoGD` (id siempre texto); ahora las referencias SGD lo lanzan como SCA y el PDF se ve en CA y Detalle. | `SCA2_AccionesAdministrativasDocumentacion` v5 | — |
| 8 | Tarjetas del Detalle | **Aplicado**: Verti/Vencimiento con la opción seleccionada; componente con estado, resultado y detalle del error. Final feliz del CMP no visto (servicio Verti PRE caído). | `SCA2_DetalleSolicitud` v68, constante `SCA2_GRP_CMP_GLOBAL_VERTI` | — |

Otros: póliza 2002600060631 — SCA2 avisa de flota/wAutemis y bloquea, SCA crea sin aviso (15788322): ¿cuál es el correcto? Reglas temporales de R29-C pendientes de borrar.
