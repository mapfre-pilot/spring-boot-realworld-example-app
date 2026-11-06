# R45-D — Etiquetas y colores de estado de la lista de solicitudes (D1)

Entorno: Appian TEST, aplicación SCA2. Fecha: 06/11/2026. Usuario funcional JJGONZ2 (SSO Mapfre NO PRO). Referencia funcional cerrada: tabla de etiquetas de `../anexos/r45-Analisis_SCA2.txt` (D2 resuelta: «los estados de Pedro» = esta tabla).

## Resumen

| Punto | Resultado |
|---|---|
| Localización de reglas SCA2/SCA | OK |
| Implementación tabla D1 (29 combinaciones) + constantes | OK |
| Regla de prueba en Designer: 29/29 | OK |
| Reales nuevas: pendiente, anulación realizada, CA positiva, cancelada | OK |
| Real nueva: mecanización enviada / pendiente de autorización | NO REPRODUCIDO (la póliza acabó en nivel 2); cubierto solo por la regla de prueba |
| Comparación SCA | Parcial (casos 1–3 en lista inicial; después error de navegación de SCA) |

## 1. Dónde se calcula la etiqueta y el color

- **SCA2** (lista «Últimas solicitudes gestionadas», buscador y «Otras solicitudes»): `SCA2_BuscadorTabla` / `SCA2_Buscador` → `SCA2_calcularEstadoSolicitud` (estado CORE de solicitud + gestiones; ahora también `cod_tip_est_mecaniza`) → etiqueta; `SCA2_colorEstadoSolicitud` (etiqueta → constante `SCA2_VAL_COLOR_*`). `SCA2_textoEstadoSolicitud` mapea los estados internos SCA2 y queda como fallback. `SCA2_TablaOtrasSolAnulacion` y las tarjetas de `SCA2_DetalleSolicitud` no se tocaron (ver pendientes).
- **SCA**: la lista de `sca-site` muestra el estado de su propia tabla de solicitudes («Pendiente», etc.), no la tabla combinada del analista; por eso en SCA los casos 1–3 aparecen como «Pendiente» (`../img/r45-d-sca-casos123-lista.png`).

## 2. Cambio realizado

`SCA2_calcularEstadoSolicitud` obtiene `codTipEstMecaniza` (entrada opcional `codEstMecaniza` o, si falta, consulta `SCA2_consultaBBDDSCA` con `idSolicitud`, solo para solicitud 2/4/5) y aplica la tabla D1 antes del cálculo anterior. Lo no cubierto por la tabla sigue con la lógica anterior sin cambios. `SCA2_BuscadorTabla` y `SCA2_Buscador` pasan `idSolicitud`. `SCA2_colorEstadoSolicitud` compara contra las constantes de etiqueta. No se tocan PMs (R42/R44 intactos).

### Objetos modificados y versiones

| Objeto | UUID | Versión | Backup |
|---|---|---|---|
| ER `SCA2_calcularEstadoSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052795` | v3→v4 | `backups-r45/r45-d-SCA2_calcularEstadoSolicitud-original.xml` |
| ER `SCA2_colorEstadoSolicitud` | `..._20063676` | v3→v4 | `backups-r45/r45-d-SCA2_colorEstadoSolicitud-original.xml` |
| IF `SCA2_BuscadorTabla` | `..._20056379` | v3→v4 | `backups-r45/r45-d-SCA2_BuscadorTabla-original.xml` |
| IF `SCA2_Buscador` | `..._20055660` | v3→v4 | `backups-r45/r45-d-SCA2_Buscador-original.xml` |
| 15 constantes nuevas (abajo) | — | nuevas (v1) | — |

Despliegue con Deployment API v2: inspección `18b180ce-306e-4ee2-9959-56b82f9fc7ff` (0 errores, 0 avisos), importación `d5191e65-c37c-4b34-8ffc-d7166c5052bb` (19 objetos, 0 fallos). Reexport de la aplicación `9af63180-522b-4ea5-8a04-98235a9c98f5`: los 4 objetos en su nueva versión y las 15 constantes dentro de SCA2.

### Constantes nuevas

| Constante | Valor |
|---|---|
| `SCA2_TXT_COD_EST_MECANIZACION_PDTE_AUTORIZAR` | `2` |
| `SCA2_TXT_COD_EST_MECANIZACION_INCOMPLETA` | `3` |
| `SCA2_TXT_COD_EST_MECANIZACION_CERRADA` | `4` |
| `SCA2_TXT_COD_EST_MECANIZACION_ENVIADA` | `7` |
| `SCA2_TXT_ETQ_ESTADO_PENDIENTE` | `Solicitud Pendiente` |
| `SCA2_TXT_ETQ_ESTADO_POLIZA_ANULADA_NIVEL2` | `Póliza Anulada. Solicitud Pendiente Nivel 2` |
| `SCA2_TXT_ETQ_ESTADO_MECANIZACION_ENVIADA` | `Mecanización Enviada` |
| `SCA2_TXT_ETQ_ESTADO_PDTE_AUTORIZACION` | `Pendiente de Autorización` |
| `SCA2_TXT_ETQ_ESTADO_CANCELADA` | `Cancelada` |
| `SCA2_TXT_ETQ_ESTADO_FINALIZADA_SIN_ANULAR` | `Solicitud Finalizada sin anular` |
| `SCA2_TXT_ETQ_ESTADO_RECHAZADA_ANULACION` | `Solicitud Finalizada. Rechazada anulación` |
| `SCA2_TXT_ETQ_ESTADO_CA_POSITIVA` | `Finalizado Contra Anulación Positiva` |
| `SCA2_TXT_ETQ_ESTADO_ANULACION_REALIZADA` | `Finalizada. Anulación realizada` |
| `SCA2_TXT_ETQ_ESTADO_CADUCADA` | `Solicitud Caducada` |
| `SCA2_TXT_ETQ_ESTADO_ANULADA_CADUCADA` | `Anulada Caducada` |

Colores reutilizados: `SCA2_VAL_COLOR_NARANJA_OSCURO` (#E46B15), `SCA2_VAL_COLOR_ROJO_OSCURO` (#BE0F0F), `SCA2_VAL_COLOR_VERDE_OSCURO` (#008C47), `SCA2_VAL_COLOR_AZUL` (#0D82BD), `SCA2_VAL_COLOR_GRIS_MEDIO` (#9F9F9F).

## 3. Resultados

T = regla de prueba en Designer (todas las combinaciones de la tabla); F = solicitudes nuevas reales.

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| T01 | sol 1 + mec vacía | Solicitud Pendiente (#E46B15) | Solicitud Pendiente (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T02 | sol 2 + mec vacía | Solicitud Pendiente (#E46B15) | Solicitud Pendiente (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T03 | sol 4 + mec vacía + gestión máx 8 | Solicitud Pendiente (#E46B15) | Solicitud Pendiente (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T04 | sol 5 + mec vacía + gestión máx 8 | Solicitud Pendiente (#E46B15) | Solicitud Pendiente (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T05 | sol 2 + mec 1 | Póliza Anulada. Solicitud Pendiente Nivel 2 (#E46B15) | Póliza Anulada. Solicitud Pendiente Nivel 2 (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T06 | sol 4 + mec 7 | Mecanización Enviada (#E46B15) | Mecanización Enviada (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T07 | sol 5 + mec 7 | Mecanización Enviada (#E46B15) | Mecanización Enviada (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T08 | sol 14 + mec vacía | Cancelada (#9F9F9F) | Cancelada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T09 | sol 14 + mec 4 | Cancelada (#9F9F9F) | Cancelada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T10 | sol 4 + mec vacía | Solicitud Finalizada sin anular (#BE0F0F) | Solicitud Finalizada sin anular (#BE0F0F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T11 | sol 5 + mec vacía | Solicitud Finalizada sin anular (#BE0F0F) | Solicitud Finalizada sin anular (#BE0F0F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T12 | sol 2 + mec 3 | Solicitud Finalizada sin anular (#BE0F0F) | Solicitud Finalizada sin anular (#BE0F0F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T13 | sol 4 + mec 4 | Solicitud Finalizada. Rechazada anulación (#BE0F0F) | Solicitud Finalizada. Rechazada anulación (#BE0F0F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T14 | sol 5 + mec 4 | Solicitud Finalizada. Rechazada anulación (#BE0F0F) | Solicitud Finalizada. Rechazada anulación (#BE0F0F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T15 | sol 3 + mec vacía | Finalizado Contra Anulación Positiva (#008C47) | Finalizado Contra Anulación Positiva (#008C47) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T16 | sol 4 + mec 1 | Finalizada. Anulación realizada (#0D82BD) | Finalizada. Anulación realizada (#0D82BD) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T17 | sol 5 + mec 1 | Finalizada. Anulación realizada (#0D82BD) | Finalizada. Anulación realizada (#0D82BD) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T18 | sol 4 + mec 2 | Pendiente de Autorización (#E46B15) | Pendiente de Autorización (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T19 | sol 5 + mec 2 | Pendiente de Autorización (#E46B15) | Pendiente de Autorización (#E46B15) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T20 | sol 6 + mec vacía | Solicitud Caducada (#9F9F9F) | Solicitud Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T21 | sol 6 + mec 3 | Solicitud Caducada (#9F9F9F) | Solicitud Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T22 | sol 6 + mec 5 | Solicitud Caducada (#9F9F9F) | Solicitud Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T23 | sol 12 + mec vacía | Solicitud Caducada (#9F9F9F) | Solicitud Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T24 | sol 12 + mec 3 | Solicitud Caducada (#9F9F9F) | Solicitud Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T25 | sol 12 + mec 5 | Solicitud Caducada (#9F9F9F) | Solicitud Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T26 | sol 11 + mec vacía | Anulada Caducada (#9F9F9F) | Anulada Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T27 | sol 11 + mec 3 | Anulada Caducada (#9F9F9F) | Anulada Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T28 | sol 11 + mec 5 | Anulada Caducada (#9F9F9F) | Anulada Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| T29 | sol 20 + mec vacía | Anulada Caducada (#9F9F9F) | Anulada Caducada (#9F9F9F) | OK | — (regla de prueba) | — | Designer: `SCA2_calcularEstadoSolicitud(estadoSolicitud, datosGestiones, codEstMecaniza)` + `SCA2_colorEstadoSolicitud` | — |
| F1 | Pendiente; póliza 0732400126579 | Solicitud Pendiente, naranja | Solicitud Pendiente, naranja | OK | 15788799 | No visible en el site | Alta → DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA → A VENCIMIENTO → guardar/aceptar → dejar contra-anulación sin terminar → lista. SCA real: PENDIENTE en detalle. | Ninguna discrepancia de etiqueta/color observada. |
| F2 | Mecanización enviada o autorización; póliza 2002200407025 | Mecanización Enviada o Pendiente de Autorización, naranja, según respuesta CORE | Póliza Anulada. Solicitud Pendiente Nivel 2, naranja; suplemento NSE 6 | NO PROBADO para la rama objetivo; etiqueta alternativa observada | 15788802 | No visible en el site | Alta por precio → contra-anulación, oficina MADRID CORREDORES NORTE II → argumento INCREMENTO PRIMA SINIESTROS negativo → finalizar → vencimiento → consulta NSE → ANULAR PÓLIZA → impresión manuscrita RGPD, sin certificar firma → salir de gestiones auxiliares → lista. SCA real: Pendiente en lista inicial. | La póliza no produjo enviada/autorización. Para completar la cobertura se necesita una póliza libre del bloque que produzca esa respuesta técnica o instrucciones funcionales para reproducirla. |
| F3 | Anulación realizada; póliza 2002100303453 | Finalizada. Anulación realizada, azul | Finalizada. Anulación realizada, azul; suplemento NSE 7 | OK | 15788803 | No visible en el site | Alta → DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE → A FECHA → Acción Administrativa → oficina MADRID CORREDORES NORTE II → marcar no entrega documentación → confirmar anulación a vencimiento → NSE → ANULAR PÓLIZA → esperar procesamiento → volver a lista. | Inicialmente tarjeta Mecanizacion Incompleta; el procesamiento terminó y la lista mostró el azul esperado. SCA inicial aún Pendiente; no se comprobó el SCA final. |
| F4 | Contra-anulación positiva; póliza 2002500316057 | Finalizado Contra Anulación Positiva, verde | Finalizado Contra Anulación Positiva, verde | OK | 15788806 | No visible en el site | Alta por precio, A VENCIMIENTO → aceptar generación y abrir gestión → oficina MADRID CORREDORES NORTE II → seleccionar INCREMENTO PRIMA SINIESTROS → POSITIVO → aceptar retención → recargar lista. | La lista de retorno necesitó recarga para mostrar la nueva fila. SCA no comparado por error de retorno ya documentado. |
| F5 | Cancelada; póliza 0732000131328 | Cancelada, gris | Cancelada, gris | OK | 15788807 | No visible en el site | Alta por precio, A VENCIMIENTO → abrir contra-anulación → CANCELAR → aceptar «Va a proceder a cancelar la solicitud de contra anulación» → aceptar confirmación → recargar lista. | Caso cubierto por cancelación desde contra-anulación. No demuestra la rama NO de Anulación/Suscripción (14/4) reservada a R45-B. SCA no comparado por error ya documentado. |
| F6 | Filtro Estado = Cancelada (observación) | La nueva cancelada se conserva y las filas mostradas corresponden a Cancelada | 15788807 gris se conserva, pero aparecen etiquetas de autorización y finalizadas sin anular | KO (preexistente, no causado por R45-D) | 15788807; otras filas solo consulta | No aplica | Abrir filtro Estado → Cancelada → cerrar selector → leer filas. | Preexistente: con la regla anterior (regla de prueba ANTES/AHORA) esas filas ya daban la misma etiqueta (15788455 sol 4 + mec 3 → Pendiente de Autorización; 15788141/15788109/15788044 sol 5 sin mec → Finalizada sin anular). El filtro usa el estado persistido SCA2, no la etiqueta calculada. Ver duda Q2. |

Comprobación adicional con solicitudes existentes (solo lectura, mecanización real de BBDD): 15788751 (5+1) azul; 15788316 (2+1) nivel 2 naranja; 15787741 (2+3) rojo; 15788704 (3) verde; 15788790 (14) gris.

## 4. Capturas

| Antes | Después |
|---|---|
| ![antes](../img/r45-d-lista-antes.png) | ![después](../img/r45-d-lista-despues.png) |

| SCA2 casos nuevos | SCA (lista inicial casos 1–3) |
|---|---|
| ![SCA2](../img/r45-d-casos-resumen.png) | ![SCA](../img/r45-d-sca-casos123-lista.png) |

Otras: regla de prueba `../img/r45-d-regla-prueba-designer.png`; casos `../img/r45-d-caso*.png`; error SCA `../img/r45-d-sca-error-retorno.png`; filtro `../img/r45-d-regresion-filtro-cancelada.png`.

## 5. Comparación SCA vs SCA2

- SCA (`/suite/sites/sca-site`) cargó sin 403: casos 1–3 se ven como «Pendiente» (SCA no aplica la tabla combinada; la diferencia es la pedida por el analista).
- Al volver del detalle de 15788799, SCA falló en `sca_datoscabecera` (`a!submitLink`, línea 23, destino de guardado inválido; evaluation ID `c802e:029b7`). Casos 4–5 y el estado final del caso 3: **no comparables** en SCA; no se insistió.

## 6. Dudas para el analista (fuera de la tabla; se conserva el comportamiento actual)

- Q1: solicitud 4/5 + mecanización 3 (incompleta) o 5: hoy «Pendiente de Autorización» o lo que dé la lógica anterior por gestiones. ¿Qué etiqueta? (ejemplo real 15788455).
- Q2: el filtro «Estado» de la lista usa el estado SCA2 persistido, no la etiqueta D1; con «Cancelada» salen filas con otras etiquetas (preexistente). ¿Debe filtrar por la etiqueta D1?
- Q3: solicitud 2 + mecanización 1 sin gestión 5; 2 + mecanización 2/4/7; 14 + mecanización distinta de vacía/4; 3 + cualquier mecanización; estados 7–10, 13, 15–19: no están en la tabla → lógica anterior.

## 7. Pendientes

- Probar con solicitud nueva real 4/5 + mecanización 7 (enviada) y 4/5 + 2 (autorización): la póliza 2002200407025 acabó en nivel 2. Hace falta una póliza cuya simulación/NSE devuelva esa respuesta.
- Aplicar la tabla en las tarjetas del detalle (`SCA2_DetalleSolicitud`) y `SCA2_TablaOtrasSolAnulacion` si el analista lo confirma (no reservados en esta ronda).
- La lista no se refresca sola al volver de finalizar (hace falta recargar); preexistente.
- Cancelada por la rama NO de Anulación/Suscripción (14/4) depende de R45-B; aquí se probó la cancelación desde contra-anulación.
