# Ronda UI3 — SCA frente a SCA2 en Appian TEST

Fecha de ejecución visible en Appian: 01/10/2026. Usuario funcional: JJGONZ2.
Pruebas reales de navegador, sin modificar objetos Appian, sin ANULAR PÓLIZA ni mecanización.
Este informe consolida las comprobaciones no invalidadas de la ronda y la última reprueba v36 con el PM Write corregido. **La persistencia v36 pasa; la ronda general no se considera completamente aprobada por la cobertura pendiente.**

## Incidencias y límites

- **Persistencia corregida en la reprueba vigente v36:** solicitud 15787747. Catálogo → ABANCA 1808 → ACEPTAR aplicó ABANCA al campo; POSPONER/ACEPTAR terminó en CORRECTO sin error smart service. Después de Buscador → Detalle → REASIGNAR → F5 → RETOMAR, se recuperó 1808 - ABANCA GENERALES DE SEGUROS Y REASEGUROS, junto con 01/03/2027, A VENCIMIENTO e INCREMENTO PRIMA SINIESTROS Negativo. La observación UI3 v36 ABANCA - Devin quedó visible en Buscador y Detalle.
- **Histórico, no veredicto vigente:** v35 recuperaba ALLIANZ pese a seleccionar ABANCA. Ese fallo ya no se reproduce en la pasada v36. No se usa evidencia concurrente con despliegues para aprobar v36.
- **Latencia recuperada en v35:** primer RETOMAR permaneció procesando más de 90 s. Una navegación limpia desde Buscador permitió abrir el formulario aproximadamente 55 s después. La reentrada posterior al guardado abrió en menos de 20 s. No se atribuye esa latencia a v35 ni a una caída CORE sin diagnóstico adicional.
- **Alta SCA bloqueada:** póliza 2002000041047. Tras recarga completa y un reintento, no navegó en más de 90 segundos. La comparación editable CA contra SCA quedó sin probar; no se consumió otra póliza para sustituirla.
- La anterior tarjeta CA «Incompleta» de 15787744/15787745 **ya no se reproduce** al navegar de nuevo desde Buscador. Ahora ambas muestran estado finalizado y fecha fin.
- El visor AA corregido muestra el PDF tanto en SCA2 como en SCA. No se verificó en una tarea editable SCA el ojo inmediatamente después de AÑADIR.
- La creación de gestión SGC no es demostrable por las tarjetas UI observadas. El identificador comunicado por el lead no sustituye una comprobación UI.
- No se da por verificada la comparación completa Argumentario/Aplicación del mismo argumento entre tareas editables SCA/SCA2. El bloqueo de Alta SCA impidió esa secuencia comparativa.
- SCA presentó además un error de evaluación al usar su flecha de retorno; se documentó y se recuperó navegando al buscador.

## Solicitudes utilizadas

| Póliza | Solicitud | Resultado observado |
|---|---|---|
| 2002000026491 | 15787744 | Cancelada; tarjeta CA Finalizada Cancelada |
| 2002000023187 | 15787745 | Finalizada positivamente; tarjeta CA Finalizada Positiva |
| 2002000025762 | 15787746 | AA pendiente, pospuesta y retomada con documentos |
| 2002000022901 | 15787747 | CA pendiente, utilizada para repruebas de persistencia; no se creó otra solicitud |
| 2002000041047 | No confirmado | Alta SCA no navega |

## 1. Buscador

| Comprobación | Comportamiento SCA | Comportamiento SCA2 | Veredicto | Captura |
|---|---|---|---|---|
| Botones y separador | LIMPIAR/BUSCAR dentro del filtro | Dentro del marco y bajo línea horizontal | igual | [SCA][sca-nif] / [SCA2][v16-nif] |
| Póliza conocida | Acceso a 15787672, 2002100648994 | Acceso a la misma solicitud | igual | [Referencia][sca-destino] |
| NIF 74010262B con N.I.F. | Resuelve 15787672 | v16 resuelve 15787672 / 2002100648994 | igual | [SCA][sca-destino] / [SCA2][v16-nif] |
| Nombre OTDAF / apellido POPAZ | Misma solicitud | v16 devuelve misma solicitud | igual | [SCA2][v16-nombre] |
| NIF sin tipo | Requiere campos válidos | BUSCAR deshabilitado | igual | Archivo local sca2-v16-sin-tipo-deshabilitado.png |
| NIF sintético 99999999R | No se afirma equivalencia de datos sin cliente confirmado | Sin resultados ni error IN vacío | no probado (paridad); pasa no-error SCA2 | [SCA2][v16-vacio] |

## 2. Alta CA

| Comprobación | Comportamiento SCA | Comportamiento SCA2 | Veredicto | Captura |
|---|---|---|---|---|
| Guardar y destino | 2002000041047 permanece en Alta tras >90 s y recarga/reintento | 2002000026491 creó 15787744 y navegó a Contra Anulación sin enlace OK | no probado (comparación bloqueada) | [Alta SCA bloqueada][alta-bloqueada] |
| Indicador y CANCELAR durante procesamiento | Bloqueo impide cerrar comparación | No se conserva evidencia visual suficiente para aprobar por separado indicador transitorio y deshabilitado | no probado | — |
| Popup style ERROR | No aplicable al delta | No observado en las altas SCA2 completadas | no probado (paridad); sin error observado | [Solicitudes creadas][estados] |

## 3. Contra Anulación negativa, posponer, retomar y cancelar

| Comprobación | Comportamiento SCA | Comportamiento SCA2 | Veredicto | Captura |
|---|---|---|---|---|
| Secciones / campos | Tarea editable nueva bloqueada | Compañía/catalogación, acciones y documentación abiertas; compañía, fecha y catalogación disponibles | no probado (paridad) | [Reentrada CA][retomar] |
| Catálogo compañía | Comparación editable pendiente | Selección ABANCA, 10 filas iniciales de 314 y paginación visibles | no probado (paridad) | [ABANCA seleccionada][abanca] |
| Filtros Código/Descripción/Grupo escribibles | Sin comparación completa | No se aprueba cada modalidad de filtro por separado | no probado | — |
| NEGATIVO | No ejecutado en la Alta SCA bloqueada | INCREMENTO PRIMA SINIESTROS rojo Negativo, sin error de tipos; persiste | no probado (paridad); pasa SCA2 | [Negativo retomado][retomar] |
| Argumentario / Aplicación | No se completó secuencia en la misma fila editable | No se afirma equivalencia funcional de todos los enlaces/ojos | no probado | — |
| Margen FINALIZAR | Sin comparación editable nueva | Margen derecho visible | no probado (paridad); pasa SCA2 | [Botonera][margen] |
| POSPONER v36 | Sin secuencia equivalente nueva | CORRECTO sin error de segundo smart service | no probado (paridad); pasa SCA2 | [CORRECTO][correcto] |
| RETOMAR, compañía cambiada | Sin secuencia equivalente nueva | Recupera 1808 ABANCA, no vacía ni ALLIANZ | no probado (paridad); pasa requisito SCA2 | [Selección][abanca] / [Reentrada][retomar] |
| RETOMAR, resto de campos | Sin secuencia equivalente nueva | A VENCIMIENTO, 01/03/2027 y Negativo conservados | no probado (paridad); pasa SCA2 | [Reentrada][retomar] |
| Observación | Textarea vacía no clasificada como defecto sin comparación UI | Detalle conserva UI3 v36 ABANCA - Devin junto al historial previo | no probado (paridad); pasa historial SCA2 | [Observación][observacion] |
| Gestión SGC | No se obtuvo prueba UI equivalente | No se identificó una tarjeta SGC separada; no se infiere fallo de integración | no probado | — |
| CANCELAR 15787744 | No ejecutado sobre Alta bloqueada | Buscador Cancelada azul; al reabrir desde Buscador, CA Finalizada Cancelada, fin 01/10/2026 10:21:20 | no probado (paridad); pasa SCA2 | [Buscador][estados] / [CA cancelada][cancelada] |

### Evidencia vigente de persistencia v36

| Antes de POSPONER — ABANCA aplicada al campo principal | Después de RETOMAR — ABANCA conservada |
|---|---|
| ![ABANCA seleccionada][abanca] | ![ABANCA al retomar][retomar] |

La pantalla CORRECTO por sí sola no demuestra persistencia: la evidencia determinante es la reentrada desde Buscador y RETOMAR. La observación nueva identifica el guardado v36.
Las versiones v31/v32 habían fallado con «Attempted to run a second smart service, but only one smart service can be run per expression evaluation»; ese popup no apareció en v36.

### Reprueba final v36 — 15787747

| Comprobación | SCA | SCA2 v36 + PM Write corregido | Veredicto | Captura |
|---|---|---|---|---|
| Catálogo → ABANCA 1808 → ACEPTAR | No repetido | Campo principal cambia a 1808 - ABANCA GENERALES DE SEGUROS Y REASEGUROS | Pasa requisito SCA2; paridad no probada | [Campo aplicado][abanca] |
| POSPONER con oficina MADRID CORREDORES NORTE II | No repetido | CORRECTO, sin error smart service | Pasa requisito SCA2; paridad no probada | [Guardado][correcto] |
| Buscador → Detalle → REASIGNAR → F5 → RETOMAR | No repetido | Recupera 1808 - ABANCA GENERALES DE SEGUROS Y REASEGUROS | Pasa requisito SCA2; paridad no probada | [Reentrada][retomar] |
| Fecha / catalogación / argumento | No repetido | 01/03/2027 / A VENCIMIENTO / INCREMENTO PRIMA SINIESTROS Negativo | Pasa requisito SCA2; paridad no probada | [Reentrada][retomar] |
| Observación v36 | No repetido | UI3 v36 ABANCA - Devin visible en Buscador y en historial Detalle | Pasa requisito SCA2; paridad no probada | [Detalle][observacion] |

Solo se reutilizó 15787747. No se crearon solicitudes ni se cerró la tarea ni se ejecutó ANULAR PÓLIZA.

## 4. Contra Anulación positiva

| Comprobación | Comportamiento SCA | Comportamiento SCA2 | Veredicto | Captura |
|---|---|---|---|---|
| POSITIVO y FINALIZAR 15787745 | No se realizó una nueva secuencia positiva SCA | Argumento Positivo verde sin error de tipos; Buscador Finalizada positivamente verde | no probado (paridad); pasa SCA2 | [Estados][estados] |
| Detalle fresco desde Buscador | No se toma respuesta CORE del lead como prueba SCA UI | Una fila CA: Finalizada Positiva, inicio 01/10/2026 10:23:54, fin 01/10/2026 10:25:09 | no probado (paridad); pasa SCA2 | [Detalle positivo][positiva] |

Las tarjetas finales ya no muestran Incompleta. La solicitud cancelada tiene inicio CA 01/10/2026 10:15:07 y fin 10:21:20; la positiva termina a 10:25:09. Ambas acordeones tienen una sola fila CA. La verificación fresca fue de solo lectura, sin pulsar acciones.

## 5. Acción Administrativa

| Comprobación | Comportamiento SCA | Comportamiento SCA2 | Veredicto | Captura |
|---|---|---|---|---|
| Documentación abierta | No se creó Alta AA de comparación | Abierta por defecto en 15787746 | no probado (paridad); pasa SCA2 | [Documentación][aa-abierta] |
| FINALIZAR con solo DNI | Sin tarea editable de comparación | Deshabilitado | no probado (paridad); pasa SCA2 | [Solo DNI][aa-dni] |
| FINALIZAR con DNI + otro documento | Sin tarea editable de comparación | Habilitado con ambos, sin «no entrega». No se pulsó FINALIZAR | no probado (paridad); pasa SCA2 | [Dos documentos][aa-dos] |
| POSPONER / RETOMAR | No ejecutado en nueva AA SCA | Los documentos siguen listados en tarea y Detalle | no probado (paridad); pasa SCA2 | Archivo local sca2-aa-retomada-documentos.png |
| Visor tras corrección | PDF real visible desde Detalle | PDF real visible desde Detalle y tarea retomada; no Documento no disponible | igual para visor comprobado | [SCA][aa-sca-pdf] / [SCA2][aa-pdf] |
| Ojo inmediatamente tras AÑADIR | No probado; no se mutaron tareas históricas ajenas | No equivale al visor de documento ya persistido | no probado | — |
| Gestión SGC | No identificada mediante UI | No identificada mediante UI | no probado | — |

| Visor SCA — referencia | Visor SCA2 — corrección |
|---|---|
| ![PDF SCA][aa-sca-pdf] | ![PDF SCA2][aa-pdf] |

## Artefactos y siguiente acción

- Grabación actual anotada de reprueba v36: `/home/ubuntu/screencasts/sca-ui3-v36/sca-ui3-v36-edited.mp4`.
- Capturas descriptivas: `/home/ubuntu/sca2work/ui3/`.
- Informe: `/home/ubuntu/sca2work/ui3/informe.md`.
- La pasada v36 cierra el defecto de persistencia observado en esta solicitud. Se dejó 15787747 retomada, sin finalizar/cancelar ni crear otra solicitud.
- Para cerrar comparativa editable completa, resolver primero el bloqueo Alta SCA; no crear más solicitudes sin autorización.
- No se instalaron dependencias ni se iniciaron servicios. Blueprint de organización consultado; no se propone actualización.

[sca-nif]: https://mapfre.devinenterprise.com/attachments/08d7a5cd-7c26-4d26-b8e0-6d526ab6cb58/sca-nif-filtros.png
[sca-destino]: https://mapfre.devinenterprise.com/attachments/284a6ed1-23f4-4db2-b16d-7aa5e7ae6449/sca-nif-destino.png
[v16-nif]: https://mapfre.devinenterprise.com/attachments/b5bcb171-3abc-40fe-ba34-a52945ca08b3/sca2-v16-nif-resultado.png
[v16-nombre]: https://mapfre.devinenterprise.com/attachments/0d9abb6c-e325-409e-a62d-7bcd4791c086/sca2-v16-nombre-resultado.png
[v16-vacio]: https://mapfre.devinenterprise.com/attachments/1aad4fb5-5d4f-4ac0-bb09-db773ad023fa/sca2-v16-sin-resultados.png
[alta-bloqueada]: https://mapfre.devinenterprise.com/attachments/146707b6-04f1-4fa3-a907-00c0bac81285/sca-alta-reintento-bloqueado.png
[abanca]: https://mapfre.devinenterprise.com/attachments/52fdc1bd-4a98-4f8f-a8d8-5d3e37de3ae3/sca2-v36-abanca-aplicada.png
[correcto]: https://mapfre.devinenterprise.com/attachments/e1cfc440-3109-4f58-826c-a08a482e3a2a/sca2-v36-posponer-correcto.png
[observacion]: https://mapfre.devinenterprise.com/attachments/9e7633cd-49a9-419e-b3a6-eadb84efb7a9/sca2-v36-observacion-persistida.png
[retomar]: https://mapfre.devinenterprise.com/attachments/7e70db35-da88-481a-903b-e206f637e85c/sca2-v36-retomar-abanca-persistida.png
[cancelada]: https://mapfre.devinenterprise.com/attachments/f8ac703b-05c2-44d9-8406-43c74dc5c543/sca2-ca-cancelada-detalle-refrescado.png
[positiva]: https://mapfre.devinenterprise.com/attachments/8233c28c-8cae-42a1-89c5-a8aef6c373c6/sca2-ca-positiva-detalle-refrescado.png
[estados]: https://mapfre.devinenterprise.com/attachments/07a41c77-34bc-4e27-852a-29ec579b6baa/sca2-estados-finales-buscador.png
[margen]: https://mapfre.devinenterprise.com/attachments/2cca6255-bfbc-48c1-a42c-903437389baa/sca2-ca-margen-botones.png
[aa-abierta]: https://mapfre.devinenterprise.com/attachments/7828ada7-932f-4a95-b967-b892cfef975b/sca2-aa-documentacion-abierta.png
[aa-dni]: https://mapfre.devinenterprise.com/attachments/d0330b2f-34b6-4d68-802a-991dce28f5e0/sca2-aa-solo-dni.png
[aa-dos]: https://mapfre.devinenterprise.com/attachments/d57f4dbe-1f35-4027-b9a4-b142eb028e1d/sca2-aa-dos-documentos.png
[aa-pdf]: https://mapfre.devinenterprise.com/attachments/29cb50a5-dc56-4a25-89f7-d90d0f1981db/sca2-aa-pdf-corregido.png
[aa-sca-pdf]: https://mapfre.devinenterprise.com/attachments/5167d026-95f0-48f8-b092-99683e611329/sca-aa-pdf.png
