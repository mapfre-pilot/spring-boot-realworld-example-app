# R49-D · Gestión frente a SCA: INC-04, INC-07 y OBS-02

Entorno: Appian TEST (`appian-dev-mcp-c90b`), site SCA2 `/suite/sites/sca2`; referencia SCA `/suite/sites/sca-site`. Fecha: 16/11/2026.
Solicitudes del analista solo consultadas (no se han tocado): 15788907, 15788859, 15788903.

## Resumen

| Apartado | ¿Igual que SCA? | Decisión | Cambio |
|---|---|---|---|
| INC-04 · 2002500484915 | **No** | Defecto de SCA2 | ER `SCA2_construirContextoAlta` v18→v19 |
| INC-07 · 0732400122931 | El aviso, sí. El cierre posterior de la CA, **no** | Aviso esperado; defecto de SCA2 en el estado de la CA después del aviso o al CANCELAR la enhorabuena | IF `SCA2_ContraAnulacionOpciones` v79→v80 |
| OBS-02 · 2001900000747 | Sí | Comportamiento esperado | Ninguno |

## INC-04 · 2002500484915 (solicitud 15788907)

### Qué pasa en SCA2
- La solicitud 15788907 aparece FINALIZADA en `SCA2 Solicitud`. En `SCA2 Llamada Servicio` todas las llamadas de SCA2 terminaron bien (generarStudAnul, finalizarContraAnulPca, guardarMecanizacion y finalizarSolicitud, todas OK/200). En `SCA2 Error` no hay ningún error para esa solicitud. El fallo no está en un servicio de SCA2.
- La mecanización (`SCA2 CMD Mecanizar`, instancia 269210329) arranca la inducción de CMP (`CMP Inducir Cliente Completo` 269210332 → `CMP Inducir Cliente Completo Fase 2` 269210333). La Fase 2 pasó por «Firma RGPD» (10:13:16–10:14:39 UTC), «error RGPD» y «Solicitud Cotización» (tarea completada a las 10:16:00 UTC).
- Después falló el nodo «Vencimiento» (Start Process de `CMP Grabado Vencimiento V2`, id de modelo 21325) con este error: «Vencimiento: No se puede iniciar el proceso especificado. No se proporcionaron valores para los parámetros requeridos…». La instancia sigue ACTIVA y parada en ese nodo.
- Motivo: `CMP Grabado Vencimiento V2` exige el parámetro `ramo`. La Fase 2 rellena `ramo` con el `producto` que le pasa SCA2, y SCA2 se lo pasó vacío (`producto = null`).
- No es un caso aislado. Les pasa lo mismo a todas las mecanizaciones de SCA2 con vencimiento revisadas: 15788909 / 2002600074474 (10252472), 0731186049897 (10270365), 2001900000216 (770281), 0732600005004 (9157662) y 0731480115289 (11252033).
- La ventana «Error del servicio» (REINTENTAR / ENTENDIDO) es la interfaz de CMP `CMP_MensajeErrorComun`. Muestra el `titulo` y el `mensaje` del error que le pasa CMP. La usan los procesos de CMP (Firma RGPD, Inducir Cliente Fase 1/2, VENC Vencimiento Completo…), no un objeto de SCA2.

### Qué hace SCA
- `SCA Mecanizacion` llama a la misma `CMP Inducir Cliente Completo` con `producto = datosBasicosSolicitud.codProducto`. Es el mismo dato que usa SCA2.
- SCA calcula ese producto en el alta (`SCA_AltaSolicitudAnulacionEstrategicas`, `local!codProducto`):
  - Autemis: AU01 si CAT_VEHIC = 1 y AU02 si CAT_VEHIC = 3.
  - NSE Hogar: HG01.
  - Vida: commercialProductCode.
  - NSE Autos: AU02 si el tipo de vehículo (4.ª característica, COD_TIPO_VEHIC) es 00000006/07/08/19; si no, AU01.
- Datos reales de TEST en `SCA datosBasicosSolicitud`: las Verti recientes tienen AU01/AU02 y las Hogar tienen HG01. Así CMP recibe `ramo` y puede grabar el vencimiento.
- La ventana de error de CMP es la misma para SCA y SCA2, porque las dos usan el mismo componente CMP. SCA tampoco muestra el servicio ni el código.

### Causa
`SCA2_construirContextoAlta` (v18) calculaba `codProducto` de otra forma que SCA en las pólizas NSE:
- miraba la 1.ª característica (COD_CATEGORIA, que vale «1» o «3») en lugar de la 4.ª (COD_TIPO_VEHIC);
- comparaba con 00000009 y, si no coincidía, devolvía «»;
- no tenía la rama de Hogar (HG01).

Resultado en TEST: en `SCA2 Datos Basicos Solicitud`, 249 de 249 solicitudes Verti y todas las de Hogar tienen `codproducto` vacío.

### Cambio realizado
- ER `SCA2_construirContextoAlta` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014`), **v18→v19**.
- Solo cambia la rama NSE de `codProducto`: Hogar → HG01; Autos NSE → AU02 si COD_TIPO_VEHIC es 00000006/07/08/19, si no AU01. Es igual que en SCA. No se ha cambiado ningún texto.
- Se ha seguido la coordinación: reserva, copia `backups-r49/SCA2_construirContextoAlta_v18.sail`, comprobación de que la versión viva era la v18, guardado, reexportación `…_v19.sail`, comparación y liberación en `coordinacion-ronda49.md`.
- Prueba de la regla con `testRule` (solo lectura):

| Póliza | Antes | Después | SCA |
|---|---|---|---|
| 2002500484915 | vacío | AU01 | AU01 |
| 2002200144753 | vacío | AU02 | AU02 |
| 2001900000268 | vacío | AU01 | AU01 |
| 0731186049897 (Hogar) | vacío | HG01 | HG01 |
| 0005726693313 (Autemis) | 00000124 | 00000124 (sin cambio) | — |

Las solicitudes ya creadas no cambian: el producto se graba en el alta.

### Pruebas con solicitudes nuevas

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T1 | Verti con vencimiento después de v19 (póliza 2002500316012, primera Verti libre del bloque R49-D) | codproducto AU01; CMP graba el vencimiento sin el error 21325; sin la ventana «Error del servicio» | `SCA2 Datos Basicos Solicitud`: codproducto **AU01**. Fase 2 recibe producto=AU01 y ramo=AU01. `CMP Grabado Vencimiento V2` termina bien (inicio 12:58:19 UTC). Fase 2 COMPLETED a las 13:00:01 UTC. En la UI: «Proceso de inducción completado» y ninguna ventana de error | OK | 15789145 | Fase 2 269228650; Grabado Vencimiento 17596147 | JJGONZ2: alta 13:48:28 CET; CA1 negativa (CORE 13:52:40) → FINALIZAR (13:53:43); Verti + Vencimiento (tipo A) → ANULAR PÓLIZA 13:57:13; cotización → vencimiento 05/06/2027 (13:58:21) → consulta Verti → riesgo ASEGURABLE → «Completar derivación definitiva» → inducción completada 13:59:48 CET | Antes del cambio se paraba en «Vencimiento» (ramo nulo). En esta póliza no apareció la Firma RGPD (el cliente no la necesitaba). Después de la mecanización (Anulación Realizada, inducción Finalizada) se abrió una CA2 de nivel 2 RED MAPFRE / OFICINA (13:57:29), que queda pendiente y no se ha tocado. Captura `../img/r49-d-t1-induccion-completada.png` |

### Dudas para el analista
1. **Ventana «Error del servicio»**: es de CMP y es igual en SCA. No se cambia. Propuesta, si negocio la quiere: que CMP pase en `CMP_ErrorIntegracion.mensaje` el servicio y el código. Se haría en CMP, no en SCA2.
2. **Autemis**: SCA graba AU01/AU02 (según CAT_VEHIC) y SCA2 graba el COD_PRODUCTO de TRON (p. ej. 00000124). Con ese valor CMP sí arranca el vencimiento, y no se ha visto ningún fallo, así que no se cambia. ¿Lo igualamos a SCA?
3. Las inducciones de SCA2 que ya están paradas en «Vencimiento» (15788907, 15788909 y las de la lista) se quedan como están. No se relanzan porque son solicitudes antiguas.

## INC-07 · 0732400122931 (solicitud 15788859)

### Qué pasa en SCA2
- 15788859 está EN_ACCION / CONTRA_ANULAR / PENDIENTE (nivel 1). No tiene filas en `SCA2 Error`. En `SCA2 Llamada Servicio` solo aparece el alta, con resultado OK.
- El aviso sale de `SCA2_ContraAnulacionModalRecuperacionPoliza`, en el caso siguiente: se finaliza POSITIVO un argumento con tréboles, se ACEPTA la enhorabuena, falla la asignación (`SCA2_executeAsignarIntegracion`) y el cliente no está en Te Cuidamos (`mcaTeCuidamos = false`). Entonces muestra «No se han podido asignar tréboles al cliente porque no está dado de alta en te cuidamos… Mensaje obtenido de Te Cuidamos: <mensaje del servicio>» y devuelve el argumento a Pendiente (`estadoArgumentos[i] = "0"`).
- **Defecto encontrado al probar el «resto de la contra anulación».** En SCA2, `local!estadoContraAnul` de `SCA2_ContraAnulacionOpciones` (v79) era una variable sin definición: al pulsar POSITIVO se guardaba «3» (positiva) y ya no se recalculaba. Por eso, si después:
  - fallaban los tréboles (el caso de INC-07), o
  - se pulsaba CANCELAR en la enhorabuena,

  el argumento volvía a Pendiente, pero FINALIZAR seguía enviando `mcaEstadoFinal = 3`. La CA y la solicitud terminaban **«Finalizado Contra Anulación Positiva» sin ningún argumento positivo**, y la póliza no seguía a Verti / anulación. Se ha visto con solicitudes nuevas de esta ronda, antes del cambio:
  - **15789153** / 2002500346247: CLUB MAPFRE PLATA POSITIVO → CANCELAR → negativo → FINALIZAR. Resultado: Positiva, con 1 negativo y 10 pendientes (captura `../img/r49-d-15789153-positiva-sin-argumento.png`).
  - **15789154** / 0731980054928: igual. `SCA2 CMD CompletarAccion` 14468505 envió `mcaEstadoFinal 3`.

### Qué hace SCA
- `SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas` tiene el mismo literal y lo muestra en el mismo caso (falla la asignación y `SCA_consultaClasificacionTC.indActivo ≠ 1`). El argumento también vuelve a Pendiente. El aviso es igual en SCA y SCA2.
- En `SCA_ContraAnulacionOpcionesEstrategicas` el estado de la CA se calcula siempre a partir de los argumentos:
  - `local!mcaEjecutarPositivo` es un `a!refreshVariable` que se actualiza con `estadoArgumentos` (¿hay algún argumento en «1»?);
  - `local!estadoContraAnul = if(mcaEjecutarPositivo, "3", 2/4)`.

  Si el argumento vuelve a Pendiente, SCA deja de considerar positiva la CA y FINALIZAR la cierra como negativa (2/4). El CANCELAR del modal es igual en SCA y en SCA2: solo pone el argumento a «0».

### Causa / decisión
- Aviso de Te Cuidamos: es el comportamiento esperado, igual que SCA (el cliente no tiene contrato en vigor en Te Cuidamos). No se toca ningún texto.
- Cierre de la CA: es un defecto de SCA2, que se comporta distinto de SCA. Se corrige.

### Cambio realizado
- IF `SCA2_ContraAnulacionOpciones` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435`), **v79→v80**.
- Solo cambia `local!estadoContraAnul`. Ahora es un `a!refreshVariable` que se actualiza con `local!estadoArgumentos`: vale «3» mientras haya algún argumento en «1» y nulo en otro caso. Es la misma regla que SCA (`mcaEjecutarPositivo`). El `a!save(local!estadoContraAnul, "3")` del botón POSITIVO y el cálculo de `local!estadoFinalizarCA` (3/2/4) no cambian. No se ha tocado ningún texto.
- Se ha seguido la coordinación: reserva, copia `backups-r49/SCA2_ContraAnulacionOpciones_v79.sail`, comprobación de que la versión viva era la v79, guardado, reexportación `…_v80.sail`, comparación (solo cambia esa variable) y liberación.
- No se ha usado la póliza 0732400122931, que tiene una solicitud en curso.

### Pruebas con solicitudes nuevas

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T2 | Aviso de Te Cuidamos con un cliente sin Te Cuidamos | El aviso y el argumento vuelven a Pendiente | **No reproducido**: ninguna de las 3 pólizas con tomador sin Te Cuidamos (`SCA2_consultaClasificacionTC.indActivo = 0`) ofreció un argumento con tréboles (TTQ / «TU TE QUEDAS…»). Solo había CLUB MAPFRE PLATA/ORO, que muestra la enhorabuena sin tréboles | SIN PROBAR | 15789153, 15789154, 15789157 | — | Cribado del bloque con consultas de solo lectura y alta de 2002500346247, 0731980054928 y 2002400000428 | Hace falta una póliza TEST con argumento TTQ y cliente sin Te Cuidamos (duda 1) |
| T4a | v80: POSITIVO → CANCELAR la enhorabuena → negativo → FINALIZAR | CA1 Finalizada **Negativa** y derivación | Club vuelve a Pendiente. FINALIZAR: CA1 **Finalizada Negativa** y CA2 de nivel 2 SI24 EXPERTOS (14:29:33). En backend, nivel 2 y rol CE_MF_SI24 | OK | 15789155 (2001900003064, SISANS) | Finalizar CA PCA 16556069 | Negativo obligatorio INCREMENTO PRIMA SINIESTROS 14:28:13 (la UI lo exige antes) → CLUB MAPFRE PLATA POSITIVO 14:28:29 → CANCELAR 14:28:37 → FINALIZAR 14:29:04 → Sí | Antes de v80 este caso terminaba Positiva (15789153, 15789154) |
| T4b | Regresión v80: POSITIVO → ACEPTAR la enhorabuena | CA Finalizada **Positiva** | «Finalizado Contra Anulación Positiva» a las 14:38:36. Backend FINALIZADA_POSITIVO; Finalizar CA PCA y Finalizar Solicitud OK a las 13:38:34 UTC. Tras recargar, el detalle muestra «Finalizada Positiva» | OK | 15789156 (0732400097946, SISANS) | 13423233 | Alta 14:37:16 → CLUB MAPFRE ORO POSITIVO → ACEPTAR | Justo después del cierre, el detalle mostró un momento «Incompleta»; al recargar salió bien |
| T2b | Cierre limpio de la última solicitud del cribado | CA negativa sin anular (aviso de corredor) | CA «Finalizada Negativa», solicitud «Finalizada sin anular» (14:45:12) | OK | 15789157 (2002400000428) | — | Negativo obligatorio 14:44:34 → FINALIZAR → aviso de corredor → OK | La CA tardó unos 2 min en mostrarse en la UI, aunque el backend ya estaba listo (13:42:28 UTC) |

Capturas: `../img/r49-d-t4-club-pendiente-tras-cancelar.png`, `../img/r49-d-t4-ca1-negativa.png`, `../img/r49-d-t4-aceptar-positiva.png`, `../img/r49-d-t2-argumentos-sin-treboles.png`.

### Dudas para el analista
1. Para probar el aviso de Te Cuidamos de principio a fin hace falta una póliza TEST que ofrezca un argumento con tréboles (TTQ) y cuyo tomador no esté en Te Cuidamos. ¿Nos puede pasar una? En el bloque R49-D no apareció ninguna.
2. Las solicitudes 15789153 y 15789154 (pruebas de esta ronda, de antes de la v80) quedaron Finalizadas Positivas por error. No se han tocado. ¿Se cancelan o se dejan como evidencia?

## OBS-02 · 2001900000747 (solicitud 15788903)

### Qué pasa en SCA2
- 15788903 está EN_ACCION / CONTRA_ANULAR / PENDIENTE, en nivel 2, con rol CE_MF_SI24, canal 8 y alta hecha por SISANS. La CA de nivel 1 se finalizó a las 09:26:34 (`SCA2_finalizarContraAnulPcaIntegracion` OK).
- En el detalle (`SCA2_DetalleSolicitud`), la tabla de argumentos de cada gestión muestra los **argumentos ya ejecutados** (`listadoContraAnul` de `SCA2_consultaDetalleGestion`). Si no hay ninguno, sale el mensaje de tabla vacía «No hay argumentos para esta gestión». La CA de nivel 2 recién creada todavía no tiene argumentos ejecutados.
- El pie «Esta solicitud la está gestionando SI24» es el aviso a la oficina cuando la tarea es de SI24 (R9-B; el texto lo aceptó el analista en R27-A).

### Qué hace SCA
- `SCA_DetalleAnulacionContraAnulacion` muestra la tabla «Argumentos ejecutados». En nivel 2 con SI24 (`nivelIntervencion = "2"` y subperfil `CE_MF_SI24`) oculta las acciones a la oficina. Los argumentos para gestionar solo los ve el gestor de SI24 cuando abre la tarea. SCA tampoco carga en el detalle el argumentario de una CA de nivel 2 sin gestionar.

### Causa / decisión
Es el comportamiento esperado. La tabla vacía no quiere decir que la CA no tenga argumentario: al RETOMAR, el gestor de SI24 sí lo carga. No se cambia nada.

### Pruebas con solicitudes nuevas

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T3a | Oficina: detalle de la CA2 nivel 2 SI24 | «No hay argumentos para esta gestión», pie SI24 y sin acciones | CA2 nivel 2 SI24 EXPERTOS, sin usuario; tabla «No hay argumentos para esta gestión»; pie «Esta solicitud la está gestionando SI24»; sin RETOMAR/REASIGNAR | OK | 15789155 (2001900003064) | — | Alta con SISANS 14:26 (canal 8, como la del analista) → CA1 negativa → FINALIZAR → CA2 14:29:33 → JJGONZ2 abre el detalle | Igual que OBS-02 |
| T3b | SI24: RETOMAR la CA2 | Carga el argumentario | RETOMAR abre la CA2 con **8 argumentos Pendientes** (incluido el obligatorio INCREMENTO PRIMA SINIESTROS). No se ejecutó ninguno | OK | 15789155 | — | SISANS → detalle → RETOMAR | — |
| T3c | CA2 de nivel 2 después de Verti (no SI24) | Tabla vacía y RETOMAR/REASIGNAR | CA2 Incompleta nivel 2 RED MAPFRE / OFICINA (inicio 13:57:29); «No hay argumentos para esta gestión»; pie con RETOMAR/REASIGNAR, sin texto SI24 | OK | 15789145 | — | Solo lectura del detalle después de T1 | El mensaje de tabla vacía no depende de SI24 |
| — | Descartada | — | 0730286021042 derivó a Verti en nivel 1 (no escaló a nivel 2). Queda con Verti Incompleta | — | 15789151 | — | Alta JJGONZ2 14:05:33 → negativo → FINALIZAR 14:08:30 | — |

Capturas: `../img/r49-d-t3-oficina-sin-argumentos-si24.png`, `../img/r49-d-t3-sisans-argumentos.png`.

### Dudas para el analista
- Ninguna. Si quiere que la oficina vea el argumentario pendiente en el detalle, sería un cambio respecto a SCA y necesitaría decisión de negocio.

## Solicitudes y pólizas de esta ronda
Bloque `polizas/bloque-R49-D.txt` (líneas 8001-8400), anotado en `polizas/REGISTRO.md`:
15789145 (2002500316012), 15789151 (0730286021042, descartada), 15789153 (2002500346247), 15789154 (0731980054928), 15789155 (2001900003064), 15789156 (0732400097946), 15789157 (2002400000428).

Sin probar en esta ronda: la comparación en `sca-site` del CANCELAR de la enhorabuena y T1 con una póliza Hogar (HG01) o AU02. La regla sí se ha comprobado con `testRule` para esos valores.
