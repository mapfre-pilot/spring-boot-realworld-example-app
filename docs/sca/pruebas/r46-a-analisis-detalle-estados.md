# R46-A: análisis «Analisis SCA2.docx», detalle (nivel, inducción Verti) y etiquetas de estado

Fecha: 10/11/2026. Entorno: Appian TEST (`mapfrespain-test`), site `sca2`; nunca PRO. Herramienta: MCP de Appian TEST (`appian-dev-mcp-c90b`, plugin 26.9.15). Usuarios funcionales: JJGONZ2 (Red Mapfre / Oficina) y SISANS (Si24), con «SSO Mapfre NO PRO».
Origen: documento del analista «Analisis SCA2.docx», que responde a `../63-dudas-analista-pendientes.md`. Coordinación: `coordinacion-ronda46.md`.

## 1. Resumen

| Punto | Resultado |
|---|---|
| Nivel «Nivel X» en el detalle, también en el nivel 1 | Aplicado (`SCA2_DetalleSolicitud` v73→v74) [Observado] |
| Nivel real en «Inducción Verti/vencimiento (componente)» | Aplicado: se toma de la gestión CORE de mecanización en la que se generó la inducción. 15788817 pasa de «NIVEL 2» a «Nivel 1» [Observado] |
| Quitar «Gestión Verti/Vencimiento» y dejar solo la inducción | Aplicado. La tarea VERTI solo se ve mientras está pendiente (Incompleta), porque es la vía de RETOMAR [Observado] |
| Campos del bloque de inducción | Aplicados: perfil = `codPerfil` CORE, grupo = `codSubPerfil` CORE y nuuma sin dominio. Se añade «Opción seleccionada en componente», que muestra «-» porque CMP no registra la opción [Observado]/[Pendiente] |
| Etiqueta 4/5 + mecanización 3/5 | Aplicado: «Solicitud Finalizada sin anular», en rojo (`SCA2_calcularEstadoSolicitud` v6→v7) [Observado] |
| Revisión completa de la tabla frente a R45-D | Coincide salvo 4/5 + 3/5, ya corregido (sección 4) [Observado] |
| Filtro «Estado» | Sin cambios. Interpretación y propuesta en la sección 5 [Inferido] |
| Combinaciones fuera de la tabla | Hay ejemplos reales en TEST (sección 6) [Observado] |
| ACEPTAR en Vida | Por código es igual que en Autos y Hogar; no se puede probar en funcional por el 4004 de CORE [Observado] |
| Clave de producción `184720372 / 0035099` | Confirmada por el analista; no se cambia (verificación funcional en la sección 7) [Observado] |

## 2. Clasificación de los puntos del documento

| # | Punto del analista | Clasificación | Acción en R46-A |
|---|---|---|---|
| 1 | «Nivel» delante del número también en el nivel 1 | Cambio en SCA2 | `SCA2_DetalleSolicitud`: `local!nivelCard` y la cabecera de Alta pasan a «Nivel n» [Observado] |
| 2 | La inducción está en nivel 1 hasta que se retoma la solicitud y vuelve a contra anulación | Cambio en SCA2 | El nivel de la tarea INDUCCION/VERTI sale de la gestión CORE de mecanización (`accionRealizada = 5`) con inicio igual o anterior a la creación de la tarea, no del nivel actual de la solicitud [Observado] |
| 3 | Quitar «Gestión Verti/Vencimiento» y dejar «Inducción Verti/vencimiento (componente)» | Cambio en SCA2 | `local!acciones` excluye la tarea VERTI que no está pendiente [Observado] |
| 4 | Fechas dd/mm/aaaa hh:mm:ss | Ya cumplido | Sin cambio (`text(…, "dd/MM/yyyy HH:mm:ss")`) [Observado] |
| 5 | Perfil (Red Mapfre, Si24…) en lugar del usuario | Cambio en SCA2 | `codPerfil` de `infoUsuario` de la gestión CORE [Observado] |
| 6 | Grupo según el perfil (Red Mapfre → Oficina) | Cambio en SCA2 | `codSubPerfil` CORE (p. ej. RED MAPFRE / OFICINA, SI24 / SI24 EXPERTOS); si no hay gestión, el grupo de la tarea [Observado] |
| 7 | Nuuma solo con el código (JJGONZ2) | Cambio en SCA2 | `nuuma` CORE; si no hay, el usuario sin dominio y en mayúsculas [Observado] |
| 8 | Opción enviada al componente | Ya cumplido | Sin cambio [Observado] |
| 9 | Opción seleccionada en el componente (Verti, Vencimiento o ambas) | Cambio en SCA2 parcial; depende de CMP | Campo añadido con «-»: `CMP Traza inducir cliente` no guarda la opción ejecutada (solo `servicio`, `estado`, `error`…). Ver duda N2 [Pendiente] |
| 10 | Estado, instancia, resultado y detalle del resultado como ahora | Ya cumplido | Sin cambio [Observado] |
| 11 | Clave de producción `184720372 / 0035099` | Responde una duda (cerrada) | Solo verificación [Observado] |
| 12 | ACEPTAR: igual que en Autos y Hogar | Responde una duda (cerrada) | Comprobado por código (sección 7) [Observado] |
| 13 | Alta Vida, 4004, `numApli`, logs, 15788717, `fecValidez`, estructura comercial y prima | Abierta; depende del AM/CORE | Sin cambios [Pendiente] |
| 14 | 4/5 + mecanización 3 o 5 | Cambio en SCA2 | «Solicitud Finalizada sin anular», en rojo [Observado] |
| 15 | Tabla completa de etiquetas | Revisión | Sección 4 [Observado] |
| 16 | Filtro «Estado»: «Son los estados los que indican la etiqueta» | Responde una duda; interpretación | Sección 5 [Inferido] |
| 17 | Combinaciones fuera de la tabla: «no pueden darse; si hay ejemplo, exponlo» | Responde una duda | Ejemplos en la sección 6 [Observado] |
| 18 | Estado provisional durante NSE/ANL | Abierta; depende de negocio | Sin cambios [Pendiente] |

## 3. Cambio en el detalle (`SCA2_DetalleSolicitud` v73→v74)

- **`local!tareasMaps`**: en las tareas INDUCCION o VERTI, `local!gT` es la última gestión CORE con `accionRealizada = "5"` cuyo `fecInicioGestion` es igual o anterior a `fechaCreacion` de la tarea. De ella salen `nivel` (`nivelIntervencion`), `perfil` (`infoUsuario.codPerfil`), `grupo` (`infoUsuario.codSubPerfil`) y `nuuma` (`infoUsuario.nuuma`). Si no hay gestión, el nivel actual de la solicitud, el grupo de la tarea y el usuario sin dominio. Antes, perfil y nuuma eran el email del usuario y el nivel era el actual de la solicitud. Por eso la inducción salía en «NIVEL 2» [Observado].
- **`local!nivelCard`**: normaliza cualquier valor («1», «NIVEL 2») a «Nivel n». Igual en la cabecera «Nivel intervención» de Alta [Observado].
- **`local!acciones`**: es `local!accionesTodas` sin las tareas VERTI que no están Incompletas. La VERTI pendiente se sigue mostrando, con RETOMAR/REASIGNAR (R45-C) [Observado].
- **Bloque de inducción**: columna nueva «Opción seleccionada en componente» [Observado].
- Protocolo: reservada en la coordinación (commit `48a7156`), lectura de la v73, backup local, cambio mínimo, `updateInterface` (v74), reexportación idéntica al fichero subido y `validateDesignObjects`. El único error que aparece es el de siempre: el caso de prueba con `idSolicitud` nulo en `sca2_cargarsolicitud`, ajeno al cambio [Observado].
- Riesgo [Inferido]: si CORE no devuelve la gestión 5 (p. ej. por una mecanización en curso), la tarjeta usa el nivel actual de la solicitud, como antes del cambio.

## 4. Tabla de etiquetas: analista frente a R45-D

Comprobado con `testRule` sobre la regla desplegada v7 (22 casos, con y sin gestiones) [Observado].

| Combinación del analista | Etiqueta esperada | R45-D (v6) | v7 |
|---|---|---|---|
| 1/2 + mecanización vacía | Solicitud Pendiente | OK | OK |
| 4/5 + mecanización N/A + gestión máxima 8 | Solicitud Pendiente | OK | OK |
| 2 + mecanización 1 + gestión 5 | Póliza Anulada. Solicitud Pendiente Nivel 2 | OK | OK |
| 4/5 + mecanización 7 | Mecanización Enviada | OK | OK |
| 14 + mecanización vacía o 4 | Cancelada | OK | OK |
| 4/5 + mecanización vacía; 2 + mecanización 3 | Solicitud Finalizada sin anular | OK | OK |
| **4/5 + mecanización 3 o 5** | **Solicitud Finalizada sin anular (rojo)** | **KO**: con gestiones reales daba «Pendiente de Autorización» o «Solicitud Caducada» | **OK** |
| 4/5 + mecanización 4 | Solicitud Finalizada. Rechazada anulación | OK | OK |
| 3 + mecanización vacía | Finalizado Contra Anulación Positiva | OK | OK |
| 4/5 + mecanización 1 | Finalizada. Anulación realizada | OK | OK |
| 4/5 + mecanización 2 | Pendiente de Autorización | OK | OK |
| 6/12 + mecanización vacía, 3 o 5 | Solicitud Caducada | OK | OK |
| 11 + mecanización vacía, 3 o 5; 20 | Anulada Caducada | OK | OK |

Color de «Solicitud Finalizada sin anular»: `#BE0F0F` (rojo, `SCA2_colorEstadoSolicitud`) [Observado].

## 5. Filtro «Estado»

- Situación [Observado]: `SCA2_Buscador` filtra la consulta paginada de `SCA2 Solicitud` por `estadoSolicitud`, que es el estado interno de SCA2 (EN_ACCION, FINALIZADA, CANCELADA…). La etiqueta se calcula después, fila a fila, con `SCA2_calcularEstadoSolicitud`, a partir del estado CORE de la solicitud, la mecanización (BBDD SCA) y las gestiones (CORE).
- Interpretación [Inferido]: «Son los estados los que indican la etiqueta» quiere decir que la etiqueta es función de los estados (solicitud + mecanización + gestión) según la tabla. El filtro debería devolver las filas cuyos estados dan la etiqueta elegida.
- Decisión [Inferido]: **no se cambia en R46-A**. Para filtrar por etiqueta hay que calcularla antes de paginar: una consulta CORE y otra a BBDD SCA por cada una de las 441 solicitudes de TEST (unos 60 s en lote en esta ronda). También se puede persistir en `SCA2 Solicitud` el estado CORE y la mecanización, que hoy no se guardan. Las dos opciones superan el «cambio mínimo» y afectan al rendimiento de la lista. Se propone como duda N1.

## 6. Combinaciones fuera de la tabla (TEST, solo lectura)

Método [Observado]: `SCA2_consultaBBDDSCA` (solicitud y mecanización) y `SCA2_consultaGestion` (gestiones) con `testRule` sobre las 441 solicitudes de `SCA2 Solicitud`, sin escribir nada. Ficheros de trabajo locales, no versionados.

| Combinación | Ejemplos en TEST | Etiqueta actual (v7) |
|---|---|---|
| 2 + mecanización 2 | 15788155, 15788199, 15788205, 15788218, 15788310 | Pendiente de Autorización |
| 2 + mecanización 4 | 15788166, 15788168 | Solicitud Pendiente |
| 3 + mecanización 1 | 15787942, 15788726 | Finalizado Contra Anulación Positiva |
| 2 + mecanización 1 sin gestión 5 | Ninguna: las 27 solicitudes 2 + 1 tienen gestión 5 (ANULACION REALIZADA). 15787772, 15787783 y 15788781 no tienen ninguna gestión de nivel 2 | Póliza Anulada. Solicitud Pendiente Nivel 2 |
| 2 + mecanización 7 | Ninguna | — |
| 14 + mecanización distinta de vacía o 4 | Ninguna (13 solicitudes 14, todas sin mecanización) | — |
| Estados 7–10, 13, 15–19 | Ninguna | — |
| Sin estado CORE | 19 altas Vida rechazadas (`PDTE-…`), p. ej. PDTE-13377305 y PDTE-269184469 | — |

Distribución observada (solicitud + mecanización): 2+vacía 158, 2+3 56, 3+vacía 49, 5+3 29, 2+1 27, 5+vacía 22, 4+vacía 19, 4+3 15, 14+vacía 13, 5+1 10, 4+1 6, 5+4 6, 2+2 5, 2+4 2, 3+1 2, 4+2 2, 4+4 1 [Observado].

## 7. Vida: ACEPTAR y clave

- ACEPTAR [Observado]: `SCA2_AltaSolicitudPage` v51 tiene un único botón ACEPTAR del mensaje de éxito, `disabled: or(local!aceptarPulsado, …)`, que se guarda en el primer clic. No hay ninguna rama por ramo, así que Vida se comporta como Autos y Hogar (R44/R45-A: sin duplicados). No se modifica. La prueba funcional en Vida no es posible mientras CORE devuelva 4004 en el alta [Pendiente].
- Clave [Observado]: `184720372 / 0035099` es lo implementado (R45-A A2) y el analista lo confirma. Verificación funcional: ver la sección 8.

## 8. Pruebas

<!-- UI -->

## 9. Objetos modificados

| Objeto | UUID | Versión | Backup |
|---|---|---|---|
| ER `SCA2_calcularEstadoSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052795` | v6 → v7 | copia local de la v6 (exportación MCP) |
| IF `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | v73 → v74 | copia local de la v73 (exportación MCP) |
| IF `SCA2_BuscadorTabla` / `SCA2_Buscador` | `…_20056379` / `…_20055660` | sin cambios (v18 / v36) | — |

No se ha desactivado ni activado la aplicación. No se han tocado SCA, CORE, CMP ni otros sistemas [Observado].

## 10. Dudas nuevas para el analista

- **N1. Filtro «Estado».** ¿El filtro debe usar las 13 etiquetas de la tabla en lugar de los estados internos? Hacerlo exige calcular la etiqueta de todas las solicitudes antes de paginar, o guardar en SCA2 el estado CORE y la mecanización, con impacto en el tiempo de carga. ¿Se prioriza?
- **N2. «Opción seleccionada en componente».** CMP (`CMP Traza inducir cliente`) no guarda qué se ejecutó en el componente (Verti, Vencimiento o ambas). ¿Puede CMP devolverlo o guardarlo? Mientras tanto se muestra «-».
- **N3. Combinaciones reales fuera de la tabla:** 2+2 (p. ej. 15788155), 2+4 (15788166) y 3+1 (15787942). ¿Qué etiqueta llevan? Hoy: «Pendiente de Autorización», «Solicitud Pendiente» y «Finalizado Contra Anulación Positiva».
- **N4.** 2 + mecanización 1 + gestión 5 sin haber pasado a nivel 2 (15787772, 15787783, 15788781) muestra «Póliza Anulada. Solicitud Pendiente Nivel 2». ¿Es correcto o debería ser «Finalizada. Anulación realizada»?

## 11. Capturas

- Antes: `../img/r46-a-antes-detalle-induccion-15788817.png` (inducción «NIVEL 2», email en perfil y nuuma), `../img/r46-a-antes-detalle-gestion-verti-15788817.png` (bloque «Gestión Verti/Vencimiento») y `../img/r46-a-antes-otras-15788817.png` (lista).
- Después: `../img/r46-a-despues-detalle-induccion-15788817.png` (Nivel 1, SI24, SI24 EXPERTOS, SISANS; sin «Gestión Verti/Vencimiento») y `../img/r46-a-despues-otras-15788817.png`.
- La captura «antes» de la lista se hizo con la regla v7 ya desplegada. 15788817 es 2 + mecanización 3, una combinación que ya era «Solicitud Finalizada sin anular» en R45-D, así que la lista no cambia en esta solicitud [Observado].
