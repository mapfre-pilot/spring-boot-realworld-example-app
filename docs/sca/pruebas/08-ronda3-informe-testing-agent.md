# Ronda 3 — comparación UI SCA / SCA2

Fecha: 01/10/2026. Entorno Appian TEST. Usuario funcional: JJGONZ2.
Se ejecutó el procedimiento por Chrome, con grabación anotada, y consultas
LCP de solo lectura para contrastar solicitudes, tareas y ANL. No se
modificaron objetos Appian. Horas UI en CEST; timestamps de records en UTC.

## Conclusión y puntos pendientes

La ronda **no queda completamente aprobada**. El envío D genera una sola
fila ANL y E termina Cancelada; B permite comparar la CA y NSE-Autos; C
evita una segunda solicitud. Persisten dos divergencias observables:

1. Después de ANULAR en D hay una **card intermedia adicional** que sólo
   muestra «Los datos se han guardado correctamente». Un primer ACEPTAR
   abre otra card que sí añade «La anulación se ha lanzado al sistema de
   emisión.»; el segundo ACEPTAR vuelve al buscador. No se reabre NSE-Autos.
   Por tanto, no se cumple literalmente la secuencia de una sola card.
2. La primera apertura del Detalle D seguía ofreciendo RETOMAR y mostraba
   CA Incompleta. Después de F5 y nueva apertura: CA Finalizada Negativa,
   Mecanización Incompleta y sin RETOMAR/REASIGNAR. Posible estado obsoleto
   de la pantalla; no afirmar que v38 falla siempre ni que la recarga
   elimina la incidencia de consistencia inicial.

No se observó finalización de ANL durante la ronda. La lectura final D
seguía en MECANIZADA / ANL / PENDIENTE, sin errores SCA2. No están
demostrados el desbloqueo de emisión, actualización final CORE, los dos
estados finales, reintentos ni timeout de 24 horas.

## Matriz de escenarios de la pasada vigente

Versiones comunicadas por el lead al inicio: Alta v22, DetalleTareas v14,
DetalleSolicitud v38 y CMD Mecanizar con selección escalar de numGestion.

| Escenario | SCA | SCA2 | Veredicto |
|---|---|---|---|
| 0: solicitud 15787759, póliza 2002000094372 | No aplica | Detalle en solo lectura: Mecanización Incompleta, sin RETOMAR/REASIGNAR. No se abrió acción ni se repitió ANULAR. | Pasó |
| D: Alta → CA negativa + carta → mecanización | Comparación con B hasta NSE; no se envió ANULAR en SCA | 2002000026784 → **15787761**. GUARDAR único, redirección automática a CA entre 44–80 s; no OK manual observado. FINALIZAR muestra «Se va a redirigir a la anulación.» | Pasó hasta redirección; rama de espera+OK no observada |
| D: ANULAR y retorno | No probado por restricción de esta pasada | ANULAR una vez. Dos cards sucesivas como se describe arriba; finalmente buscador, no NSE. | Divergencia: ACEPTAR extra |
| D: estado y protección de reentrada | No se hizo envío SCA | Mecanización Enviada naranja; Detalle Incompleta. RETOMAR visible inicialmente, oculto tras F5 junto a REASIGNAR. | Pasó tras recarga; incidencia inicial abierta |
| E: CANCELAR desde NSE | No probado en SCA en esta pasada | 2002000011520 bloqueada por solicitud pendiente; alternativa autorizada **2002000032024 → 15787763**. Alta única, CA negativa, carta, FINALIZAR → NSE → CANCELAR → CORRECTO → ACEPTAR → buscador **Cancelada #9F9F9F** | Pasó con póliza alternativa |
| B: referencia CA negativa → NSE | **2002000041364 → 15787762**. Carta entregada, negativo INCREMENTO PRIMA SINIESTROS, FINALIZAR → «Se va a redirigir a la anulación.» → OK → NSE-Autos. No ANULAR | Mismo texto de redirección, presentado en card CORRECTO con ACEPTAR | Pasó en alcance autorizado |
| C: duplicado | No repetido en SCA en esta pasada | 2002000094372: GUARDAR muestra exactamente «Está grabando una solicitud con los mismos datos que la anterior. ¿Desea continuar?». Se elige No; buscador conserva sólo 15787759 | Pasó SCA2; comparación SCA pendiente |

La navegación alternó pestañas SCA y SCA2. Se comprobó expresamente la
póliza en NSE antes de CANCELAR E: 2002000032024; no se canceló B por
confusión de pestaña. B quedó en NSE-Autos sin ANULAR.

## IDs, tiempos y comprobaciones de backend

| Caso | Identificador y tiempo observado | Resultado |
|---|---|---|
| D | 15787761; fecSolicitud UI **20:49:10** | GUARDAR una sola vez; CA automática observada entre 44–80 s. No cronometraje más preciso de carga |
| D CA | CompletarAccion **18:51:47.630 UTC**; tarea MEC creada **18:52:01.010 UTC** | CA completada; tarea MEC 71 PENDIENTE |
| D envío | CMD Mecanizar **18:53:58.930 UTC** (20:53:58 local) | Este es timestamp backend, no instante exacto del clic ANULAR. Clic único anterior a la primera captura de resultado 20:54:14 |
| D ANL | Fila **2081**, creada **18:54:03.740 UTC** | Una sola fila para 15787761 con consulta batchSize 100. NUM_GESTION **43704999**, código **GPC55-0015787761-1** |
| D cierre de ronda | Lectura final aprox. 21:12 local | Estado MECANIZADA, procesoActivo ANL, estadoTarea PENDIENTE; tarea 71 MECANIZAR PENDIENTE; errores `[]`. No finalización observada |
| B | 15787762; fecSolicitud **21:00:16** | Alta tardó; no medida exacta de GUARDAR a CA. CORE también devolvió fecResolucion 21:00:16/codEstSolic 2: dato observado, no prueba de envío ANL |
| B UI | Mensaje de redirección capturado **21:08:44**; NSE **21:09:10** | No se pulsó ANULAR |
| E | 15787763; fecSolicitud **21:04:27** | Lectura SCA2_consultarSolicitudes confirmó ID y póliza; negativo ejecutado 21:07:20 |
| E cancelación | CANCELAR aprox. **21:09:52**; fecha resolución UI **21:09:59** | Buscador Cancelada; rgb(159,159,159), equivalente exacto #9F9F9F |

Los timestamps backend no sustituyen la medición visual de latencia. No
se ejecutaron acciones mutadoras mediante LCP ni se simuló desbloqueo ANL.

## Evidencia visual comparada

### D: cards sucesivas después de ANULAR

| 🔴 Primera card: falta texto de envío | 🟢 Tras primer ACEPTAR: aparecen ambos textos |
|---|---|
| ![Primera card D](https://mapfre.devinenterprise.com/attachments/dd54d971-4570-4dbc-bdd5-671020585b1d/ss_5e53efcb.png) | ![Segunda card D](https://mapfre.devinenterprise.com/attachments/4e640015-11ba-4bae-a7aa-d66ca4659489/ss_16e2dd63.png) |

### D: buscador y detalle tras recarga

| D: Mecanización Enviada | D: Incompleta, sin RETOMAR tras F5 |
|---|---|
| ![Buscador D](https://mapfre.devinenterprise.com/attachments/7de6c72d-660c-480b-83be-956eed21c142/ss_63b9df3e.png) | ![Detalle D recargado](https://mapfre.devinenterprise.com/attachments/bbb497df-40ef-4f90-9e7a-893ecea4533a/ss_714a5d5c.png) |

### Comparación de finalización negativa

| SCA B: redirección | SCA2 E: mismo texto en card |
|---|---|
| ![SCA B redirección](https://mapfre.devinenterprise.com/attachments/97cac354-97e9-4e8b-a0b4-9fadec012af8/ss_065b0e78.png) | ![SCA2 E redirección](https://mapfre.devinenterprise.com/attachments/46f19311-15fc-498c-ae63-f89e8c2c6a11/ss_98304634.png) |

| SCA B: NSE-Autos sin ANULAR | SCA2 E: Cancelada tras CANCELAR de NSE |
|---|---|
| ![SCA NSE B](https://mapfre.devinenterprise.com/attachments/5223ec29-774b-43f2-8cf4-3172fcb6d8ac/ss_aff8b782.png) | ![SCA2 Cancelada E](https://mapfre.devinenterprise.com/attachments/739552ad-3597-4a77-8e23-df94799b5e61/ss_43e288b1.png) |

### C: No evita segunda solicitud

| Confirmación con texto exacto | Buscador después de No |
|---|---|
| ![C confirmación](https://mapfre.devinenterprise.com/attachments/25b2452c-415b-4ed0-a42f-ef9a67558481/ss_1972b73f.png) | ![C solicitud única](https://mapfre.devinenterprise.com/attachments/7b6cf5ac-4ac9-418d-b8e6-d7421e59220e/ss_78602340.png) |

## Etiquetas y colores

| Estado visible | App y alcance | Color |
|---|---|---|
| Mecanización Enviada | SCA2 D y 15787759, sin fecha resolución | Naranja #E46B15 |
| Cancelada | SCA2 E 15787763, fecha resolución 21:09:59 | Gris #9F9F9F medido por estilo DOM |
| Pendiente | Filas previas SCA2 15787757/15787756 | Naranja visible; no nueva medición hexadecimal |
| Finalizada no requerida contraanulación | Filas previas SCA2 | Rojo visible; no prueba de transición en esta pasada |
| Finalizada positivamente | Fila histórica SCA2 15787749 | Sólo etiqueta en DOM; no prueba funcional nueva |
| Finalizada. Anulación realizada / Finalizada. Rechazada anulación | No alcanzados | No comprobados #0D82BD / #BE0F0F |

No se equiparan los colores de cards de gestión con el estado del buscador.
La comparación completa de estados finales SCA/SCA2 sigue pendiente.

## Escenarios iniciales no resueltos por esta pasada

- **Alta con error 2002100649057:** en el intento anterior no falló el
  backend; creó 15787757. Hubo espera UI superior a 350 s y 403; no se
  puede presentar como validación de la card PDTE. El mensaje concreto,
  Referencia y CANCELAR tras error siguen sin reproducirse. SCA rechazó
  luego la misma póliza por solicitud pendiente compartida.
- **Duplicado inicial 2002200566753:** la solicitud previa no caía dentro
  de la vigencia devuelta por CORE; SCA creó 15787758 sin confirmación.
  No se repitió GUARDAR. La prueba positiva de confirmación vigente se
  hizo con C en SCA2, no con esa precondición inválida.
- **15787759, diagnóstico anterior:** padre 526741 activo en Esperar ANL;
  hijo 526742 terminó con error resuelto en Write Anulacion:
  `Unable to write to or delete from the source due to system error.
  Error Details: (conn=1506) Data too long for column 'NUM_GESTION' at row 1`.
  No se reanudó ni canceló. La fila ANL de D demuestra el nuevo envío,
  pero no repara retroactivamente aquella solicitud.
- No se hizo ANULAR ni CANCELAR de mecanización en SCA B, conforme a la
  última restricción. No se ha demostrado paridad de esos resultados.
- No se esperaron 24 horas ni se forzaron errores de actualización CORE.

## Artefactos y operación

Grabación vigente:
`/home/ubuntu/screencasts/sca-ronda3-v38-clean/sca-ronda3-v38-clean-edited.mp4`

Capturas clave absolutas:

| Hito | Ruta |
|---|---|
| D primera card | `/home/ubuntu/screenshots/ss_5e53efcb.png` |
| D segunda card | `/home/ubuntu/screenshots/ss_16e2dd63.png` |
| D buscador | `/home/ubuntu/screenshots/ss_63b9df3e.png` |
| D detalle después de F5 | `/home/ubuntu/screenshots/ss_714a5d5c.png` |
| C confirmación | `/home/ubuntu/screenshots/ss_1972b73f.png` |
| C solicitud única | `/home/ubuntu/screenshots/ss_78602340.png` |
| B mensaje | `/home/ubuntu/screenshots/ss_065b0e78.png` |
| B NSE | `/home/ubuntu/screenshots/ss_aff8b782.png` |
| E NSE antes de cancelar | `/home/ubuntu/screenshots/ss_0dec3085.png` |
| E Cancelada | `/home/ubuntu/screenshots/ss_43e288b1.png` |

Comentario PR: ninguno; no hay PR asociado.
SKILL.md: ninguno nuevo.
Blueprint consultado: sin instalaciones ni servicios nuevos; reutilizados
Chrome autenticado y helper LCP existente. Sugerencia de documentación de
setup: registrar el helper local env.sh/lcp.py/testrule.py como alternativa
de lectura y la separación entre usuario funcional JJGONZ2 y Designer;
el blueprint genérico de MCP no describe ese helper local.
Necesario del usuario: ninguna credencial adicional. Queda decidir/corregir
las dos divergencias UI y verificar ANL después del desbloqueo real de
emisión; para la card PDTE hará falta una precondición de error reproducible.

## Retest F (v10/v15/v39)

**Veredicto: parcial; falla el Detalle sin F5.** Se completó el flujo UI
con JJGONZ2 en TEST. La primera card y el ACEPTAR único ya cumplen lo
esperado; el refresco de Detalle no corrigió los datos obsoletos durante
la espera. No se modificaron objetos Appian.

- Póliza: **2002000042310**, primera candidata que alcanzó Alta; lectura
  previa sin solicitudes. No se usaron las otras candidatas.
- Solicitud: **15787764**, fecha UI **01/10/2026 21:22:36**.
- GUARDAR una sola vez; seguía cargando a ~30 s y CA ya abierta a ~58 s.
  Se observó auto-redirección, no card de espera + OK.
- Oficina MADRID CORREDORES NORTE II; argumento INCREMENTO PRIMA SINIESTROS
  negativo a **21:23:50** local; carta de prueba cargada.
- ANULAR PÓLIZA exactamente una vez, aproximadamente **19:25:17 UTC /
  21:25:17 local**. ID y hora comunicados al lead durante el flujo.
- Horarios siguientes derivados de las capturas de herramienta; no son
  mediciones de latencia interna del servidor.

| Comprobación | Resultado observado | Veredicto |
|---|---|---|
| FINALIZAR CA negativa con carta | 19:24:46 UTC: «Los datos se han guardado correctamente» + «Se va a redirigir a la anulación.» | Pasó |
| ACEPTAR abre NSE-Autos | Póliza F y fecha 01/05/2027; se mostró aviso de condiciones modificadas | Pasó |
| Primera card después de ANULAR | 19:25:19 UTC: CORRECTO con ambos textos, incluido «La anulación se ha lanzado al sistema de emisión.» | Pasó |
| Un único ACEPTAR | 19:25:35 UTC: buscador directo, sin otra card ni reapertura NSE | Pasó |
| Fila F al buscar póliza | 19:25:59 UTC: Mecanización Enviada, sin fecha resolución; DOM rgb(228,107,21) = #E46B15 | Pasó |
| Detalle sin F5 | Abierto ~19:26:20 UTC; CA Incompleta. Tras esperar 40 s y expandir MEC: Incompleta con RETOMAR visible | **Falló** |
| Lectura adicional sin recarga solicitada por lead | 19:28:18 UTC: mismos estados y RETOMAR, casi 2 min después de abrir Detalle | **Falló** |
| Diagnóstico adicional con F5 autorizado por lead | F5 ~19:28:23; a 19:28:43 CA Finalizada Negativa e Impresión Finalizada; MEC expandida a 19:28:58 Incompleta sin RETOMAR/REASIGNAR | Pasó sólo después de F5 |

La corrección después de F5 **no convierte en aprobado** el requisito
principal sin recarga. No se pulsó RETOMAR/REASIGNAR ni se repitió ANULAR.
Después de la comprobación del Detalle sólo se realizaron lecturas,
expansión visual, scroll y el F5 expresamente solicitado.

| Confirmación inmediata — ambos mensajes | Buscador F — naranja |
|---|---|
| ![Primera card F](https://mapfre.devinenterprise.com/attachments/6e8b6c3f-debb-4d1d-accb-fa37832e00d4/ss_2cad0d43.png) | ![Buscador F](https://mapfre.devinenterprise.com/attachments/81d90fcc-5247-4589-83e2-a4367bcb1278/ss_ea389f17.png) |

| 🔴 Antes de F5 — 19:28:18 UTC | 🟢 Después de F5 — 19:28:58 UTC |
|---|---|
| ![Detalle obsoleto sin F5](https://mapfre.devinenterprise.com/attachments/db6a811a-a16a-4756-a84f-2836f4236925/ss_6fb491ba.png) | ![Detalle después de F5](https://mapfre.devinenterprise.com/attachments/5db89692-9a9a-4754-bdb4-d751526470ff/ss_f8721009.png) |

Grabación F:
`/home/ubuntu/screencasts/sca-retest-f-v10-v15-v39/sca-retest-f-v10-v15-v39-edited.mp4`

La grabación cubre el flujo F hasta el fallo tras 40 s. La comparación
adicional antes/después de F5 fue solicitada después de detenerla y está
documentada mediante capturas, no incluida en ese vídeo.

| Captura | Ruta absoluta |
|---|---|
| Mensaje tras CA | `/home/ubuntu/screenshots/ss_f2557409.png` |
| NSE-Autos F | `/home/ubuntu/screenshots/ss_2beea019.png` |
| Primera card ANULAR | `/home/ubuntu/screenshots/ss_2cad0d43.png` |
| Buscador tras único ACEPTAR | `/home/ubuntu/screenshots/ss_05cfbed1.png` |
| Fila F naranja | `/home/ubuntu/screenshots/ss_ea389f17.png` |
| Detalle fallido tras 40 s | `/home/ubuntu/screenshots/ss_5252d9bc.png` |
| Detalle sin recarga 19:28:18 UTC | `/home/ubuntu/screenshots/ss_6fb491ba.png` |
| Detalle tras F5 19:28:58 UTC | `/home/ubuntu/screenshots/ss_f8721009.png` |

No se verificaron en esta reprueba el desbloqueo de emisión, estado final
CORE ni timeout/reintentos. No se repitió SCA de referencia. Ninguna
credencial adicional necesaria. No hay PR asociado ni SKILL nuevo.
Blueprint consultado nuevamente; sin instalaciones ni servicios nuevos.
Se mantiene la sugerencia de documentar el helper LCP local y la
separación de usuarios funcional/Designer.

## Retest G (v17)

**Veredicto: pasan los criterios UI del ciclo G.** Prueba end-to-end en
SCA2 TEST con JJGONZ2: Alta → CA negativa con carta → NSE-Autos →
ANULAR una sola vez → ACEPTAR una sola vez → buscador → Detalle sin F5.
La navegación completa introducida por v17 evita el Detalle obsoleto en
esta pasada. Esto no demuestra por separado que el polling de v39
resuelva el escenario anterior F.

- Póliza **2002000068248**, primera candidata que alcanzó Alta. No se
  utilizaron 2001900006477 ni 2002000062822.
- Solicitud **15787765**, fecha UI **01/10/2026 21:36:14**.
- Alta: DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA;
  A VENCIMIENTO, fecha 05/06/2027; observación `Retest G v17 - Devin`.
- GUARDAR pulsado una sola vez ~19:36:08 UTC. A ~20 s seguía deshabilitado
  y cargando; a ~48 s ya estaba en CA por auto-redirección. No se observó
  la ruta de mensaje de generación + OK.
- Oficina MADRID CORREDORES NORTE II; INCREMENTO PRIMA SINIESTROS negativo
  a **21:37:36 local**, carta de prueba añadida y entrega visible 01/10/2026.
- ANULAR PÓLIZA exactamente una vez ~**19:39:21 UTC / 21:39:21 local**.
  ID y hora comunicados al lead durante la prueba.
- Los tiempos son aproximados a partir de capturas/herramientas, no
  latencias internas del servidor.

| Comprobación | Resultado observado | Veredicto |
|---|---|---|
| FINALIZAR CA con carta | 19:38:42 UTC: CORRECTO con guardado y «Se va a redirigir a la anulación.» | Pasó |
| ACEPTAR CA | NSE-Autos con póliza G y fecha 05/06/2027; aviso de condiciones modificadas | Pasó |
| Primera card tras ANULAR | 19:39:26 UTC: «Los datos se han guardado correctamente» y «La anulación se ha lanzado al sistema de emisión.» simultáneamente | Pasó |
| ACEPTAR v17 único | 19:39:44 UTC: buscador en la misma pestaña, sin segunda card ni reapertura NSE; URL sin `$sp` | Pasó |
| Navegación completa | `performance.timeOrigin` cambia de `1790883244151` a `1790883581356.1`; entrada de navegación `type=navigate` | Pasó |
| Buscar por póliza | 19:40:34 UTC: única fila 15787765, Mecanización Enviada, sin fecha resolución | Pasó |
| Color de fila | Lectura DOM 19:40:39 UTC: `rgb(228,107,21)` = **#E46B15**, junto con captura visible | Pasó |
| Abrir Detalle SIN F5 | 19:40:56 UTC: CA Finalizada Negativa, Impresión Finalizada y Mecanización Incompleta desde la primera vista | Pasó |
| Expandir Mecanización SIN F5 | 19:41:23 UTC: fecha fin vacía, MECANIZACIÓN INCOMPLETA y ningún RETOMAR/REASIGNAR | Pasó |

No hubo recarga manual ni cambio manual de URL entre ANULAR y la
comprobación de Detalle. Sólo la navegación de ACEPTAR v17 recargó el
documento. Después del Detalle no se ejecutaron más acciones de negocio.
No se modificó ningún objeto Appian.

| Primera card G — ambos mensajes | Buscador G — búsqueda y naranja |
|---|---|
| ![Primera card G](https://mapfre.devinenterprise.com/attachments/2fc8ff61-a742-47c3-8beb-91ff439e372a/ss_92489295.png) | ![Fila G naranja](https://mapfre.devinenterprise.com/attachments/571dd207-3754-4afb-9b61-be307b037844/ss_829d5946.png) |

| Un ACEPTAR — nueva carga del buscador | Detalle sin F5 — estados correctos y sin reentrada |
|---|---|
| ![Buscador recargado v17](https://mapfre.devinenterprise.com/attachments/7ab05687-17c1-4e2f-8be2-e65d2d378574/ss_2d4385ba.png) | ![Detalle G sin F5](https://mapfre.devinenterprise.com/attachments/aa51c3f6-497b-4346-8d7f-762b833fa82b/ss_7e196eb2.png) |

Grabación G:
`/home/ubuntu/screencasts/sca-retest-g-v17/sca-retest-g-v17-edited.mp4`

| Captura | Ruta absoluta |
|---|---|
| Mensaje CA | `/home/ubuntu/screenshots/ss_68fd2ad1.png` |
| NSE-Autos | `/home/ubuntu/screenshots/ss_a60a3f83.png` |
| Primera card ANULAR | `/home/ubuntu/screenshots/ss_92489295.png` |
| Buscador tras ACEPTAR único | `/home/ubuntu/screenshots/ss_2d4385ba.png` |
| Búsqueda póliza / naranja | `/home/ubuntu/screenshots/ss_829d5946.png` |
| Primera vista Detalle sin F5 | `/home/ubuntu/screenshots/ss_a0a67616.png` |
| Mecanización expandida sin F5 | `/home/ubuntu/screenshots/ss_7e196eb2.png` |

Cobertura no incluida en G: consulta backend ANL/errores, desbloqueo
de emisión, actualización final CORE, estados finales, timeout/reintentos
y nueva comparación SCA. No se infiere nada de estos puntos a partir de
la card CORRECTO. Ninguna necesidad adicional del usuario para esta
reprueba. Sin PR asociado ni SKILL nuevo. Blueprint consultado: no se
instalaron dependencias ni iniciaron servicios; se reutilizó Chrome
autenticado. Sigue siendo útil documentar el helper LCP y la separación
funcional/Designer mencionados en la ronda anterior.
