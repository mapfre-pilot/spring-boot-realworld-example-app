# Ronda 6 — informe de pruebas funcionales Appian TEST

Fecha: 07/10/2026. Horas de negocio/UI: CEST (UTC+2).
Prueba realizada en navegador real, con usuario administrativo provisionado;
los datos funcionales de las gestiones muestran JJGONZ2 / RED MAPFRE.
No se modificaron objetos ni código por el agente de pruebas; sin commit.

## 1. Resultado y pendientes

Se completó el procedimiento con incidencias y cobertura parcial; no se declara
éxito global. Durante la ronda el lead publicó v47 de Detalle y corrigió Finalizar.
La verificación final se hizo reabriendo las solicitudes, sin repetir acciones.

| Escenario | Resultado |
|---|---|
| A — 15787843 / 2002300361315 | PASA el delta visual v47: MEC verde, Autorización justo después de MEC y ausencia de acciones en las tarjetas finalizadas comprobadas. La precondición de CA2 pendiente no se cumplía: CA2 estaba Finalizada Negativa y Autorización Pendiente. |
| B — reintento IMPR_GUARDAR_FAIL | PASA confirmación, banner y original RELANZADO; FALLA el criterio inicial «ningún error nuevo»: apareció FINALIZAR_ERROR. Tras corrección y reintento del lead, ambos errores figuran RELANZADO y no quedan pendientes. |
| C — 15787844 / 2001900000715 | PASA flujo NSE y ausencia de Autorización; v47 elimina RETOMAR indebido en MEC y conserva RETOMAR en CA2. PARCIAL respecto al estado esperado: MEC queda Incompleta en SCA y SCA2, no Anulación Realizada. |
| D — 15787845 / 2001900000716 | PASA POSPONER → RETOMAR → vuelta sin finalizar. PARCIAL respecto a conservación completa de datos: Oficina aparece sin seleccionar al retomar. |

Pendientes para el analista:

- C: el buscador mostró inicialmente **Mecanización Enviada**, pero en la lectura
  final muestra **Pendiente**, coincidiendo con SCA y con CA2 abierta. MEC conserva
  **Incompleta**, centro emisor `-`, sin fecha fin. No se demuestra anulación
  externa completada ni persistencia definitiva de «Mecanización Enviada».
- D: confirmar si Oficina vacía al retomar es el comportamiento previsto o una
  pérdida de selección; no se volvió a seleccionar ni guardar.
- No se instrumentaron llamadas a IGenerarContraAnul ni se hizo lectura
  independiente de base de datos. La UI no demuestra por sí sola que una
  integración no se invocó ni que no existen duplicados fuera de lo mostrado.
- No se ejecutó un caso wAutemis con observaciones 00000005/00000006, ni los
  estados visuales Cerrada sin mecanizar/Caducada, ni la alternativa REASIGNAR
  con otra asignación tras v47.

## 2. Entorno, límites y ejecución

- SCA2: `https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/buscador`.
- Errores: `https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/errores`.
- Referencia SCA: `https://mapfrespain-test.appiancloud.com/suite/sites/sca-site`.
  La ruta `/sites/sca` redirigía a SCA2.
- Credenciales utilizadas sin imprimir ni incorporar al informe.
- Se confirmó un único reintento del error autorizado IMPR_GUARDAR_FAIL.
  No se pulsó RETOMAR en 15787843. No se tocó el error 69 desde la bandeja:
  su reintento posterior pertenece al lead.
- Se creó una solicitud C y otra D. ANULAR se ejecutó sólo una vez en C.
  No se ejecutaron anulaciones de otras solicitudes.
- Las tareas SCA y SCA2 viven en procesos distintos: la ausencia de RETOMAR
  en SCA no se utiliza como defecto de paridad.
- Las observaciones anteriores a v47 se identifican expresamente como históricas.
  La grabación final corresponde a la comprobación v47, no a la creación completa.

## 3. A — tarjetas, estados, colores y acciones

Solicitud **15787843**, póliza **2002300361315**.

La precondición comunicada no coincidió con la UI. Se observó Autorización
**Pendiente**, no Finalizada, y CA nivel 2 **Finalizada Negativa**, no Pendiente.
Por ello no se afirma haber probado en A una tarea CE_RM pendiente.
Las gestiones desplegadas muestran **OFICINA / JJGONZ2 / RED MAPFRE**.

En la observación anterior a v47, Mecanización era naranja y Autorización se
colocaba al final. Se vio REASIGNAR en la tarjeta Autorización pendiente.
Tras la publicación v47 y la reapertura, alrededor de 19:14–19:15:

1. Alta Solicitud — Finalizada, verde.
2. Contra Anulacion nivel 1 — Finalizada Negativa, rojo.
3. Impresion — Finalizada, rojo.
4. Mecanizacion — Anulacion Realizada, **verde**.
5. Autorizacion — Pendiente, naranja.
6. Contra Anulacion nivel 2 — Finalizada Negativa, rojo.

**PASA:** orden y colores finales coinciden con SCA reabierta desde su buscador.
MEC desplegada no muestra RETOMAR/REASIGNAR. CA2 finalizada desplegada tampoco.
Autorización desplegada no ofrece acciones en la lectura final.
No se pulsaron acciones de estas tarjetas.

El buscador final muestra **Finalizada no requerida contraanulación** en ambas
aplicaciones; la fecha resolución visible es 19:07:12 en SCA2 y 19:07:06 en SCA.
Esta diferencia de seis segundos se anota, sin atribuir causa.

| SCA — referencia final | SCA2 — v47 final |
|---|---|
| ![A SCA](https://mapfre.devinenterprise.com/attachments/ee7164e2-b272-4a8e-b17d-5a7b858b171c/A-sca.png) | ![A SCA2 v47](https://mapfre.devinenterprise.com/attachments/f5384d88-8813-4c75-a294-99db7ba9eeb2/A-v47-sca2.png) |

Capturas locales adicionales: `ss/A-mec-v47.png`, `ss/A-aut-v47.png`,
`ss/A-doc-ca2-v47.png`, `ss/buscador-final.png`.

## 4. B — reintento de impresión y error posterior

Solicitud **15787843**, póliza **2002300361315**.
Fila autorizada: IMPR_GUARDAR_FAIL, SCA2 CMD CompletarAccion,
nodo Guardar impresion CA.
Mensaje original exacto:

```text
Failed to connect to https://core7.pre.mapfre.net:26007/PCA_CORECFSA_HTTPRouter/IGenerarContraAnul
```

Se pulsó Relanzar y se confirmó una única vez, alrededor de **18:50**.
La UI mostró:

```text
Relanzado «SCA2 CMD CompletarAccion» para la solicitud 15787843. El error queda marcado como RELANZADO; si vuelve a fallar aparecerá un error nuevo.
```

**PASA:** original RELANZADO y banner de éxito sin error de expresión.
**FALLA:** ya en las actualizaciones posteriores inmediatas apareció:

| Campo | Valor |
|---|---|
| Código | FINALIZAR_ERROR |
| Comando | SCA2 CMD Finalizar |
| Nodo | Finalizar PCA/SGC |
| Mensaje exacto | Error no catalogable |
| Fecha visible | 07/10/2026 18:50 |
| Estado inicial | PENDIENTE |

El error nuevo se documentó sin relanzarlo. El lead comunicó la sustitución del
stub de Finalizar Gestion SGC por SCA2_finalizarGestionSGC y su reintento por API.
No se atribuye esa acción al agente de pruebas ni se considera limpio el primer
intento.

Lectura final sólo UI alrededor de **19:16**:
- filtro Pendiente + 15787843: **0**, «No hay errores con los filtros seleccionados.»
- filtro Todos: **2**, ambos RELANZADO (IMPR_GUARDAR_FAIL y FINALIZAR_ERROR).
- No apareció otra fila de impresión en esa lectura.
- Solicitud finalizada en buscador; tarjetas finales descritas en A.

| B — banner del reintento autorizado | B — error nuevo del primer intento |
|---|---|
| ![Banner](https://mapfre.devinenterprise.com/attachments/12647294-ae24-4a4c-9a24-28c76cf3bec1/B-banner.png) | ![FINALIZAR_ERROR](https://mapfre.devinenterprise.com/attachments/65908c85-423d-4e40-91d1-af32c30aecfe/B-error-nuevo.png) |

| B — estado final tras intervención del lead | Alcance |
|---|---|
| ![Ambos relanzados](https://mapfre.devinenterprise.com/attachments/2bc04157-3166-4ba3-b2bb-3d086f39f823/B-final-relanzados.png) | No prueba una recuperación sin intervención; el primer intento falló. |

### Documento

La referencia visible antes y después es **0900ab4481a07851**, fecha 07/10/2026.
La tabla documental de CA muestra una fila Carta firmada; Autorización muestra
la misma referencia con etiqueta Autorización, no una referencia nueva.
Impresión mantiene una tarjeta Finalizada; al desplegarla no se obtuvo contenido
documental propio. **PASA la ausencia de duplicado visible en las tablas
comprobadas**, no una auditoría completa de almacenamiento.
**NO VERIFICADO directamente:** contador de invocaciones IGenerarContraAnul.

Evidencia local: `ss/B-doc-antes-sca.png`, `ss/B-doc-despues-sca2.png`,
`ss/A-doc-ca2-v47.png`, `ss/A-aut-v47.png`, `ss/B-final-pendientes-vacio.png`.

## 5. C — NSE-Autos sin Autorización

Póliza **2001900000715**, nueva solicitud **15787844** (alta 18:53:46).
Popup vigente: efecto 03/06/2026, vencimiento 03/06/2027; Automóviles,
BASICar TERCEROS AMPLIADO.

Valores de prueba: DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA,
PRESENCIAL, A VENCIMIENTO, fecha 03/06/2027, oficina MADRID CORREDORES NORTE II.
Observación: `Ronda6 C TEST - NSE Autos sin Autorizacion`.

Pasos:
1. Alta una vez, Contra Anulación NEGATIVO, sin aportar documento de cliente.
2. FINALIZAR exigió «Se ha de imprimir la plantilla de la carta firmada».
   Se imprimió una vez; se abrió PDF real de dos páginas, sin subir documento.
3. FINALIZAR y continuación hacia NSE-Autos.
4. Simulación: importe `-`, reserva prima Sí, nivel INFORMATIVO, aviso de
   condiciones modificadas; ANULAR PÓLIZA habilitado, sin pantalla de HTTP 500
   ni «servicio no disponible». Se siguió el criterio autorizado para ese estado.
5. ANULAR PÓLIZA una sola vez; resultado:

```text
CORRECTO
Los datos se han guardado correctamente
La anulación se ha lanzado al sistema de emisión.
```

6. ACEPTAR devolvió al buscador sin bucle. Mostró **Mecanización Enviada**.

| C — anulación lanzada | C — buscador inicial |
|---|---|
| ![C lanzada](https://mapfre.devinenterprise.com/attachments/82110142-24bc-434e-88cd-01b8a9c7e5a3/C-anulacion-lanzada.png) | ![C enviada](https://mapfre.devinenterprise.com/attachments/c5a12bb6-8577-4742-a703-0806d6d51225/C-buscador-enviada.png) |

Detalle posterior en SCA2 y SCA:
- Alta Finalizada.
- CA nivel 1 Finalizada Negativa.
- Impresión Finalizada.
- MEC **Incompleta**, NSE-Autos, centro emisor `-`, sin fecha fin,
  hito Anulación 03/06/2027.
- CA nivel 2 Incompleta, OFICINA / JJGONZ2.
- **Sin tarjeta Autorización**.

La lectura final del buscador es **Pendiente** en ambas aplicaciones.
No se etiqueta esta evolución como error probado de orquestación: coincide con
CA2 abierta; sí se marca como discrepancia respecto al estado final solicitado.

Antes de v47 MEC ofrecía RETOMAR indebidamente. Tras reapertura v47,
alrededor de 19:13:
- **PASA:** MEC sigue Incompleta pero ya no tiene RETOMAR ni REASIGNAR.
- **PASA:** CA nivel 2 conserva RETOMAR; no se pulsó.
- **PASA:** no hay Autorización.
- **PASA:** Alta desplegada y CA1 finalizada comprobadas sin acciones.
- **PASA:** /errores, Estado Todos + 15787844 = 0 al final.

| C v47 — MEC sin acciones | C v47 — CA2 abierta con RETOMAR |
|---|---|
| ![MEC](https://mapfre.devinenterprise.com/attachments/0e21c4b7-c733-43fe-a95f-8be802b36ae5/C-v47-mec.png) | ![CA2](https://mapfre.devinenterprise.com/attachments/c0772a7b-4eaf-4fd1-94b7-a4ced85ba197/C-v47-ca2-retomar.png) |

Ausencia de Autorización comprobada en UI de ambas aplicaciones, no mediante
consulta independiente a gestión CORE 7. No se afirma cierre externo de Emisión.
Capturas adicionales: `ss/C-simulacion.png`, `ss/C-v47-tarjetas.png`,
`ss/C-sca-mec.png`, `ss/C-errores-vacio.png`.

## 6. D — regresión POSPONER / RETOMAR

Póliza **2001900000716**, nueva solicitud **15787845** (alta 19:04:43).
Popup: Automóviles, TODO RIESGO, vencimiento 03/06/2027.
Mismos motivo/detalle/causa/canal/catalogación/fecha que C.
Observación: `Ronda6 D TEST - Posponer y retomar`.

1. POSPONER una vez.
2. Confirmación «¿Desea continuar? / Se va a posponer la solicitud de contra anulación».
3. Resultado CORRECTO / Los datos se han guardado correctamente.
4. Detalle CA **Incompleta**, con **RETOMAR**.
5. RETOMAR una vez: abrió Contra Anulación con la póliza/cliente y argumentos.
6. **Incidencia de datos:** Oficina quedó sin seleccionar, aunque antes se había
   seleccionado MADRID CORREDORES NORTE II. No hubo mensaje de error.
7. VOLVER AL DETALLE, sin FINALIZAR, sin cancelar la solicitud.
8. Detalle final: Alta Finalizada / CA Incompleta. SCA muestra lo mismo.
9. /errores, Estado Todos + 15787845 = **0**.

**PASA** reanudación y vuelta sin cierre. **PARCIAL** conservación completa de
datos por Oficina vacía. **NO VERIFICADO** REASIGNAR bajo otra asignación: no se
exige que ambos botones estén simultáneamente visibles.

| D — flujo reabierto, Oficina vacía | D — regreso a Detalle sin finalizar |
|---|---|
| ![D reabierta](https://mapfre.devinenterprise.com/attachments/9fc9cd7c-2b24-490d-a5a4-3fa44ec515d4/D-reabierta.png) | ![D vuelta](https://mapfre.devinenterprise.com/attachments/75126cc4-2f9d-4f6c-8be3-c4e176898ae9/D-sca2-vuelta.png) |

| D — referencia SCA | D — alcance de comparación |
|---|---|
| ![D SCA](https://mapfre.devinenterprise.com/attachments/20e0aa32-e15f-46c6-9cf5-a1b57609e3a9/D-sca.png) | Coinciden estados; no se comparan botones de procesos diferentes. |

Capturas adicionales: `ss/D-posponer.png`, `ss/D-guardado.png`,
`ss/D-retomar.png`, `ss/D-errores-vacio.png`.

## 7. Incidencias de navegación y limitaciones

- Sobre la pestaña antigua de SCA, al volver desde C, alrededor de 19:16:57:
  «La tarea solicitada no está disponible. Es posible que la tarea haya sido
  eliminada o completada por otro asignado.» Se recuperó entrando de nuevo a
  `/sites/sca-site` y abriendo solicitudes desde el buscador. No impidió A/D.
  Evidencia: `ss/incidencia-sca-tarea.png`.
- El render de Appian es asíncrono; una captura inmediatamente tras pulsar puede
  mostrar aún la pantalla anterior. Se esperó al contenido final.
- No se investigaron notificaciones, correo recibido, ANL ni otras ramas
  wAutemis en esta ronda. No se extrapola el caso NSE a esas ramas.
- No se reejecutó C o D después del cambio de Finalizar: el delta se verificó
  sólo por los estados finales y la bandeja; A fue reintentada por el lead.
- No se midió el hexadecimal del color por instrumentación: se comprobó verde
  visual y coincidencia con SCA.

## 8. Artefactos y setup

Grabación final: `sca-ronda6-v47-final-edited.mp4`
(directorio de grabaciones `sca-ronda6-v47-final`). Contiene la vuelta de D,
comprobaciones v47 A/C, bandeja final y comparación SCA. No presenta como
actual la grabación anterior al cambio de versión.

Las capturas seleccionadas se guardaron bajo `ss/`; las imágenes incrustadas
usan URLs alojadas para que sean legibles fuera de esta máquina.
Plan: `plan-testing-agent.md`.

Blueprint consultado: no se instalaron dependencias ni se arrancaron servicios
locales. Se reutilizó la sesión y herramientas existentes. Para selección de
evidencia, PIL no estaba disponible y un primer montaje excedió caché; se
generaron miniaturas secuencialmente con ImageMagick ya instalado. Son
incidencias de preparación de artefactos, no pruebas funcionales fallidas.
Actualizaciones de blueprint sugeridas: ninguna.

Comentario PR sugerido: ninguno; no se indicó PR.
SKILL.md adicional: ninguno.
Necesario del usuario para entregar este informe: ninguno.
Para cerrar los pendientes se requiere decisión/investigación sobre Oficina en D
y resultado externo de MEC C; no se deben repetir las anulaciones ya ejecutadas.
