# Ronda 4 — comparación SCA/SCA2 y traducción ANL

Fecha: 02/10/2026. Entorno Appian TEST. UI: JJGONZ2; lecturas LCP: credenciales administrativas existentes. Sin cambios de objetos Appian, sin commit.

Se completó el procedimiento UI y la lectura backend. Los dos cambios específicos pasan en el caso probado: espera v18 y códigos traducidos persistidos en ANL. **No se declara cierre completo del ciclo de emisión:** Detalle ya mostraba «Anulacion Realizada», pero el registro SCA2 y la tarea MECANIZAR seguían pendientes de ANL. La consulta de instancia por LCP no está implementada.

## A. Cabecera — PASA, mismo hueco

Solicitud histórica **15787766**, póliza **2002200566837**, sólo lectura. Misma ventana y resolución; viewport medido 1600 × 1091 CSS px, DPR 2.

| Medición | SCA | SCA2 |
|---|---:|---:|
| Borde derecho del SVG flecha → comienzo del texto | 34 CSS px | 34 CSS px |
| Diferencia | — | 0 CSS px |

No se reprodujo un hueco mayor en SCA2. Ambas cabeceras tienen separador vertical y el NIF ocupa una segunda línea. La ubicación global difiere: SCA contiene el detalle dentro del buscador y SCA2 lo presenta directamente; esto no cambia el espacio flecha/texto medido. Referencia funcional real: `/suite/sites/sca-site`; `/suite/sites/sca` no sirvió como referencia en esta sesión.

| SCA — referencia | SCA2 — comparación |
|---|---|
| ![Cabecera SCA](https://mapfre.devinenterprise.com/attachments/ac9b25a4-162f-4fc2-8f6c-22bcbf330aa6/ss_a11268a2.png) | ![Cabecera SCA2](https://mapfre.devinenterprise.com/attachments/089bb0f8-1dfd-4902-ba93-1687e659a7da/ss_d914d8e4.png) |

Rutas locales: `/home/ubuntu/screenshots/ss_a11268a2.png` (SCA), `/home/ubuntu/screenshots/ss_d914d8e4.png` (SCA2).

## B. Flujo nuevo — espera v18 y envío PASAN; observación en Detalle

**Póliza 2002000014753 → solicitud 15787772.** Un único Alta y un único ANULAR PÓLIZA. No fue necesaria la reserva 2002000011892. No se realizaron acciones de negocio sobre las solicitudes protegidas.

Datos elegidos: DECISION DE CLIENTE → PRECIO → ME HA SUBIDO MUCHO LA PRIMA; A VENCIMIENTO, fecha 01/03/2027. Observación «Ronda4 Devin - traduccion ANL v18». CA: MADRID CORREDORES NORTE II, argumento INCREMENTO PRIMA SINIESTROS, NEGATIVO; carta `documento_prueba.pdf` cargada y añadida.

- **PASA:** GUARDAR único crea la solicitud y abre CA.
- **PASA:** después de FINALIZAR y confirmar, primera card CORRECTO con «Los datos se han guardado correctamente», «Se va a redirigir a la anulación.» y «Preparando la pantalla de anulación…».
- **PASA:** ACEPTAR deshabilitado, verificado visualmente y mediante propiedad DOM `disabled=true`. Intento temprano de clic no abandona la card ni abre el buscador.
- **PASA:** sin F5, desaparece Preparando y se habilita ACEPTAR. Un clic abre Detalle consulta NSE-Autos, no el buscador.
- **Observación NSE:** muestra aviso «Las condiciones de anulación de la póliza se han modificado tras confirmar la fecha de anulación», nivel INFORMATIVO; causa y fecha correctas. No bloqueó el flujo.
- **PASA:** ANULAR PÓLIZA exactamente una vez. La primera card posterior ya contiene simultáneamente guardado y «La anulación se ha lanzado al sistema de emisión.».
- **PASA:** un ACEPTAR vuelve al buscador mediante navegación en la misma pestaña; búsqueda por póliza devuelve sólo 15787772, «Mecanización Enviada», fondo `rgb(228,107,21)` = **#E46B15**, sin fecha de resolución.
- **PASA:** Detalle abierto sin F5 muestra CA «Finalizada Negativa», sin RETOMAR/REASIGNAR en MEC expandida.
- **NO PROBADO en la fase esperada:** no se capturó MEC «Incompleta». En la primera apertura ya aparecía **«Anulacion Realizada»**, con fin de gestión **14:36:10 local**, resultado «ANULACIÓN REALIZADA» y fecha de anulación 01/03/2027. La lectura SCA2 posterior seguía MECANIZADA/ANL/PENDIENTE. Se comunica esta diferencia al lead; no se asume finalización global.

### Tiempos

Fecha 02/10/2026; UTC en tabla, hora local UI = UTC+2. Observador DOM de sólo lectura cada 100 ms para transiciones; capturas respaldan los estados visibles. Los intervalos incluyen procesamiento Appian, no son un benchmark.

| Evento | UTC | Intervalo relevante |
|---|---|---|
| GUARDAR Alta | 12:32:20.441 | Una vez |
| Fecha solicitud visible en buscador | 12:32:26 | 14:32:26 local |
| Creación registro SCA2 | 12:32:35 | Backend |
| Creación tarea CA 84 | 12:32:45 | Backend |
| NEGATIVO | 12:33:44.448 | Una vez |
| CARGAR carta / AÑADIR | 12:33:52.178 / 12:33:59.903 | Carta entregada |
| FINALIZAR | 12:34:17.318 | Abre confirmación |
| ACEPTAR confirmación FINALIZAR | 12:34:22.101 | Inicio procesamiento |
| Primera CORRECTO + Preparando + disabled | 12:34:39.260 | 17,159 s tras confirmar |
| Creación tarea MECANIZAR 85 | 12:34:46 | Backend |
| ACEPTAR habilitado / Preparando desaparece | 12:35:01.560 | Espera visible 22,300 s |
| Clic ACEPTAR habilitado | 12:35:07.238 | Abre MEC |
| NSE-Autos visible | 12:35:17.160 | 9,922 s tras clic |
| ANULAR PÓLIZA único | **12:35:29.478** | **14:35:29.478 local** |
| Primera CORRECTO posterior | 12:35:30.160 | 0,682 s; ambos mensajes |
| Registro SCA2 MECANIZADA/ANL | 12:35:34 | Backend |
| Creación fila ANL | 12:35:40.240 | 10,762 s tras ANULAR |
| Captura buscador tras un ACEPTAR | ~12:35:55 | Fecha de captura, no clic exacto |
| Captura buscador filtrado | ~12:36:05 | Mecanización Enviada |
| Fin gestión MEC mostrado en Detalle | 12:36:10 | Dato UI |
| Primera captura Detalle | ~12:36:24 | Ya Anulacion Realizada |

| Espera — ACEPTAR deshabilitado | Preparado — ACEPTAR habilitado |
|---|---|
| ![Espera v18](https://mapfre.devinenterprise.com/attachments/96608f20-2b6b-4d7a-8aff-b592934053b0/ss_50defd7b.png) | ![ACEPTAR habilitado](https://mapfre.devinenterprise.com/attachments/446dff89-17a3-495a-853a-f1a8900fe208/ss_4772fa0d.png) |

| NSE-Autos — antes de ANULAR | Primera card — después de ANULAR |
|---|---|
| ![NSE-Autos](https://mapfre.devinenterprise.com/attachments/be18df16-9d70-4029-8c07-ad6d52ce9151/ss_73f08d44.png) | ![Ambos mensajes](https://mapfre.devinenterprise.com/attachments/20f0df63-274a-4ffe-9e2d-01e4ee8dd523/ss_ff0471d7.png) |

| Buscador — naranja | Detalle sin F5 — MEC realizada |
|---|---|
| ![Buscador filtrado](https://mapfre.devinenterprise.com/attachments/7d12c7ff-24ea-4550-b887-5c91d6b63177/ss_64cfcad0.png) | ![Detalle sin reentrada](https://mapfre.devinenterprise.com/attachments/69f8dd36-f8fb-4753-b0e7-693363ec2e08/ss_2ed0ee5f.png) |

## C. Backend — unicidad y traducción PASAN; instancia no consultable

Lecturas LCP con Basic Auth, sin cookies UI. Se ejecutó únicamente la regla de consulta `ANL_getAnulacionByFilter_qr(idSolicitud:"15787772", pagingInfo:{startIndex:1,batchSize:100})`, HTTP 200, resultado no truncado, una fila. Contrastada con exportación CSV del record ANL, 68 filas en esa lectura: **exactamente una** para 15787772. Esto consulta datos runtime persistidos, no ejecuta el builder traductor como sustituto.

| Campo ANL | Valor observado |
|---|---|
| ID_ANULACION | **2086** |
| ID_SOLICITUD / NUM_POLIZA | **15787772 / 2002000014753** |
| CODIGO_ANULACION | GPC55-0015787772-1 |
| NUM_GESTION | **43705044**, un valor |
| COD_COMPANIA / ORIGEN_POLIZA | 41 / NSE-Autos |
| COD_MOTIVO | **00000001** |
| COD_DETALLE | **00000001** |
| COD_CAUSA | **00000002** |
| CREACION | 2026-10-02 12:35:40.240 |
| MODIFICACION | 2026-10-02 12:35:48.580 |
| NUMERO_SUPLEMENTO | 9 |
| CONCLUIDA | false |

- **PASA:** los tres códigos coinciden con la traducción esperada y tienen ocho dígitos.
- **PASA:** SCA2 Error filtrado por idSolicitud devuelve `[]` a ~12:38 UTC y nuevamente a **12:39:23 UTC**.
- **PASA:** una sola transición CMD Mecanizar, id 359, proceso **529803**, resultado OK, destino MECANIZADA a 12:35:34.
- **Observación pendiente de reconciliación:** a 12:39:23 UTC SCA2 seguía `estadoSolicitud=MECANIZADA`, `procesoActivo=ANL`, `estadoTarea=PENDIENTE`, `mecanizacionRealizada=false`. CA 84 COMPLETADA; MEC 85 PENDIENTE, sin fechaCierre. Es diferente del resultado CORE expuesto en Detalle. No se probó eventual convergencia ni timeout.
- **NO PROBADO:** status/nodo/variables de la instancia ANL Aceptar. `GET /runtime/processes/529803` devuelve **501**, `Operation not implemented by this plugin version`; no fue posible seguir el hijo mediante ese endpoint. No se modificó ni reanudó proceso alguno.

### Comparación histórica de formato

| Procedencia comprobada | Solicitud / ANL | Motivo / detalle / causa |
|---|---|---|
| Nueva SCA2 de esta prueba | 15787772 / 2086 | **00000001 / 00000001 / 00000002** |
| Antigua SCA2 de ronda 3, sólo lectura | 15787761 / 2081 | 1 / 1 / 1 |
| Registro histórico presente en SCA solicitudAnulacion y ANL | 15787605 / 2058 | **00000001 / 00000001 / 00000005** |

La referencia SCA 15787605, póliza 0000253500290, ANL creada 29/09/2026 10:46:08, compañía 1, NSE-Autos, permite comparar el **formato a ocho dígitos**, no la semántica de una causa o compañía distinta. Se verificó pertenencia al record SCA por id; no se inspeccionó su antigua instancia creadora. Otra fila histórica NSE compañía 41 (15787280 / ANL 2020, 31/08/2026) usa 00000001/00000001/00000002, pero no se confirmó su instancia/procedencia, por lo que no se usa como prueba de origen SCA.

## Artefactos y límites

Grabación anotada A+B: `/home/ubuntu/screencasts/sca-ronda4-v18/sca-ronda4-v18-edited.mp4`.

Capturas clave:
- SCA: `/home/ubuntu/screenshots/ss_a11268a2.png`.
- SCA2: `/home/ubuntu/screenshots/ss_d914d8e4.png`.
- Preparando/disabled: `/home/ubuntu/screenshots/ss_50defd7b.png`.
- Habilitado: `/home/ubuntu/screenshots/ss_4772fa0d.png`.
- NSE: `/home/ubuntu/screenshots/ss_73f08d44.png`.
- Primera card: `/home/ubuntu/screenshots/ss_ff0471d7.png`.
- Buscador: `/home/ubuntu/screenshots/ss_64cfcad0.png`.
- Detalle: `/home/ubuntu/screenshots/ss_2ed0ee5f.png`.

Comparación UI SCA limitada a la cabecera solicitada; no se repitió un envío SCA nuevo. No se probaron otros motivos/compañías/ramos, finalización global, desbloqueos, reintentos ni timeout. Una ejecución con espera real demuestra el guard v18 en este caso, no toda combinación de carreras de concurrencia.

Blueprint consultado: sin instalaciones ni servicios nuevos. El setup genérico cubre MCP; sería útil documentar los helpers locales `env.sh/lcp.py` y la separación de identidad funcional UI y administrativa LCP. Ninguna credencial nueva necesaria.
