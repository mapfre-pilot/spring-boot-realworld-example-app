# R49-B · INC-05: la solicitud no se recupera de forma coherente en la búsqueda o en el histórico

Entorno: **Appian TEST** (`mapfrespain-test`), MCP `appian-dev-mcp-c90b`, usuario de prueba JJGONZ2 (Red Mapfre). Nunca PRO. Solo se ha modificado un objeto de SCA2. Las solicitudes del analista solo se han consultado (registros SCA2 y consulta CORE de solo lectura); **no** se ha llamado a `SCA2_consultarListadoArgumentosREST` sobre ellas: el argumentario se ha leído con la integración de solo lectura `SCAC_listarDetalleArgumentosCntrAnuIntegracion`.

## 1. Resumen

| # | Apartado | Resultado |
|---|---|---|
| 1 | Caso 2 · buscador con/sin ceros a la izquierda | **Diferencia con SCA corregida.** SCA quita espacios y rellena con ceros hasta 13 (NO VIDA) o 10 (VIDA) antes de buscar; SCA2 buscaba el texto tal cual. `SCA2_Buscador` v36→v37. Probado con solicitud nueva 15789141 |
| 2 | Caso 2 · «Existe una solicitud en curso» sin solicitudes | **Igual que SCA, sin cambio.** El aviso no sale de una solicitud: sale de la marca `MCA_PENDIENTE = S` que CORE devuelve en la póliza (wAutemis migrada). CORE no tiene ninguna solicitud de 0002729391736 (ni con ni sin ceros). Duda D1 |
| 3 | Caso 1 · 15788901 sale como «Pendiente» | **Correcto según los datos.** La solicitud está abierta: SCA2 `EN_ACCION` con la tarea de contra anulación `PENDIENTE`, CORE `codEstSolic = 2` (pendiente). Nunca se finalizó la contra anulación |
| 4 | Caso 1 · «al retomarla ya no sale el TTQ» | **Sin causa SCA2 demostrada.** En CORE no consta ningún argumento ejecutado en 15788901 (0 ejecutados), así que el TTQ no llegó a aplicarse ni a grabarse. Duda D2 |
| 5 | Caso 1 · «no aparece si la busco» | **No reproducible con los datos.** 15788901 está en `SCA2 Solicitud` con 2001900000562 y CORE la devuelve; el buscador (v36 y v37) la encuentra por póliza. Duda D3 |
| 6 | Prueba con TTQ aplicado y retomar en solicitud nueva | **No realizada.** No hay en TEST póliza de socio Club con TTQ sin solicitud en curso (ver §5). Duda D4 |

## 2. Qué hay en TEST de cada caso (solo consulta)

### Caso 1 · póliza 2001900000562, solicitud 15788901

| Origen | Dato |
|---|---|
| CORE (`SCA2_consultarSolicitudes`, tpBusqueda 0) | 15788901, `codEstSolic = 2`, causa ME HA SUBIDO MUCHO LA PRIMA, fecha 12/11/2026 10:06:43, sin fecha de resolución. Es la única solicitud abierta de la póliza |
| `SCA2 Solicitud` | numPoliza `2001900000562` (13 dígitos), estado `EN_ACCION`, interfaz `CONTRA_ANULAR`, proceso `CONTRAANULAR`, tarea `PENDIENTE`, perfil `CE_MF_SI24`, usuario SISANS |
| `SCA2 Datos Solicitud` | Alta 12/11/2026 10:06 CET, línea 1 (Autos), fecha anulación 01/06/2027 |
| `SCA2 Tarea` | 835 · `CONTRAANULAR` · `PENDIENTE` · asignada a SISANS |
| `SCA2 Transicion` | `SCA2 CMD Alta` → ALTA · `SCA2 CMD Decidir` ALTA→DECIDIDA · `SCA2 CMD CrearAccion` DECIDIDA→EN_ACCION. **No hay** `SCA2 CMD CompletarAccion` |
| `SCA2 Error` | Ninguna fila de 15788901 |
| Argumentario (solo lectura) | `numArgEjecutados = 0`, sin detalle de argumentos ejecutados |

Conclusión: la solicitud se dio de alta, se abrió la contra anulación y se quedó ahí. No consta ningún argumento ejecutado (tampoco el TTQ) ni error de SCA2. Por eso sale como «Solicitud Pendiente» en el histórico («Otras sol. Anulación») y en el buscador: es su estado real, en SCA2 y en CORE.

Comparación útil (prueba propia anterior, R47-C): en 15788894 (2002600036910, socio Club) el TTQ sí quedó **Positivo** en CORE («Se han aplicado 2 tréboles al cliente…»), pero la contra anulación no se finalizó por el error de 255 caracteres (`SCA2 Error` 215, ya corregido en R47-C). Esa solicitud también sigue «Pendiente». Es decir: aplicar el TTQ marca el argumento, pero la solicitud solo deja de estar pendiente al **FINALIZAR** la contra anulación.

### Caso 2 · póliza 0002729391736

| Origen | Dato |
|---|---|
| CORE `consultarSolicitudes` con `0002729391736` y con `2729391736` | Sin solicitudes |
| `SCA2 Solicitud` | Ninguna fila con esa póliza (ni con ni sin ceros) |
| CORE `SCA2_consultarPolizas` | `COD_ESTADO_POLIZA = V`, `NOM_ESTADO_POLIZA = VIGENTE MIGRADA`, **`MCA_PENDIENTE = S`**, producto 00000131, línea 1 |
| `SCA2_pObtenerPolizaFecha` | Estado VIGENTE, póliza CORE 200 (wAutemis) |

## 3. Cómo lo hace SCA y qué hacía SCA2

| Punto | SCA (`SCA_BuscarSolClientePolizaEstr` / `SCA_PopUpEstr`) | SCA2 antes (v36) | SCA2 ahora (v37) |
|---|---|---|---|
| Espacios | `trim` del número | Texto tal cual | `trim` |
| Ceros a la izquierda | NO VIDA: rellena hasta 13; VIDA: hasta 10 | Texto tal cual | Igual que SCA |
| Búsqueda en CORE | `SCA_consultarSolicitudes(numPoliza normalizado, tpBusqueda 0)` | Igual pero con el texto sin normalizar | Igual que SCA |
| Búsqueda en tablas SCA2 | — (SCA no tiene) | `numPoliza = texto` | `numPoliza = normalizado` |
| Filtro de estados / fechas en el buscador | No filtra por estado ni fecha al buscar por póliza: muestra todas | Igual | Igual (sin cambio) |
| «Solicitud en curso» en el alta | Aviso si `MCA_PENDIENTE = S` (wAutemis) o estado «VIGENTE - PENDIENTE DE SOLICITUD» (resto) | Igual (`SCA2_AltaSolicitudAnulacionPopUp`), además el popup ya rellenaba con ceros | Sin cambio |

Por qué en el caso 2 «no hay resultados» y a la vez «existe una solicitud en curso»: son dos fuentes distintas. El buscador lista solicitudes (CORE + SCA2), y no hay ninguna. El aviso del alta mira la marca de la póliza `MCA_PENDIENTE`, que CORE tiene a `S`. SCA hace exactamente lo mismo con esa póliza, así que no es una diferencia de SCA2. Con la marca puesta y sin solicitud, «consultar la solicitud» no lleva a ninguna (D1).

## 4. Cambio aplicado

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| Interfaz `SCA2_Buscador` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | **36 → 37** | Nueva variable `local!fPolizaNorm` (trim + ceros hasta 13 NO VIDA / 10 VIDA, copia literal de la regla de SCA). La validación de la póliza (`SCA2_pObtenerPolizaFecha`, `SCA2_obtenerTipoPoliza`, regex) y la búsqueda (CORE y `SCA2 Solicitud`) usan ese valor. El campo de pantalla no cambia lo que escribe el usuario |

Reservado y liberado en `coordinacion-ronda49.md`. Copias: `backups-r49/SCA2_Buscador_v36.sail` (antes) y `backups-r49/SCA2_Buscador_v37.sail` (reexportada tras guardar; idéntica a la enviada).

No cambia lo que ve el usuario respecto a SCA: es la misma normalización que SCA, aplicada antes de buscar.

## 5. Pruebas con solicitudes nuevas

| # | Prueba | Solicitud | Pasos | Resultado | Evidencia |
|---|---|---|---|---|---|
| P1 | Buscar sin ceros una póliza sin solicitudes (caso 2) | — | Póliza · NO VIDA · `2729391736` · BUSCAR | Sin error de validación (la póliza se reconoce tras rellenar con ceros) y «No hay resultados para dicha búsqueda», igual que con `0002729391736`. Correcto: no hay solicitudes | `../img/r49-b-01-busqueda-sin-ceros-0002729391736.png` |
| P2 | Alta nueva escribiendo sin ceros | **15789141** | ALTA · NO VIDA · `2729392579` (el popup lo pone `0002729392579`) · DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA · A VENCIMIENTO 10/09/2027 · GUARDAR · «mismos datos que la anterior» → Sí · ACEPTAR | Solicitud 15789141 creada (CORE 16/11/2026 13:41:51, `codEstSolic 2`). Abre la contra anulación con 7 argumentos (sin TTQ) y el aviso «Esta póliza pertenece a un acuerdo especial y debe gestionarla SI24». Detalle: Alta Finalizada, Contra Anulación Incompleta. Se deja pendiente | `../img/r49-b-02-alta-15789141-contraanulacion.png` |
| P3 | Buscar la nueva **sin** ceros | 15789141 | Póliza · NO VIDA · `2729392579` · BUSCAR | 2 resultados: 15789141 «Solicitud Pendiente» y 15788156 (anterior, CORE) «Finalizada sin anular». Con v36 este texto no se normalizaba | `../img/r49-b-03-busqueda-sin-ceros-15789141.png` |
| P4 | Buscar la nueva **con** ceros | 15789141 | `0002729392579` · BUSCAR | Los mismos 2 resultados | `../img/r49-b-04-busqueda-con-ceros-15789141.png` |
| P5 | Con espacios alrededor | — | ` 0002729392579 ` (15 caracteres) | El propio campo lo rechaza: «no puede tener más de 13 caracteres», no se busca. El `trim` solo actúa con espacios dentro del límite | `../img/r49-b-05-busqueda-espacios-limite13.png` |
| P6 | TTQ aplicado + retomar en solicitud nueva | — | — | **No hecha.** La única póliza de socio Club con TTQ conocida en TEST (2002600036910) tiene abierta la 15788894 (prueba R47-C), y 2001900000562 tiene abierta la 15788901 del analista: el alta daría «solicitud en curso». Las pólizas TTQ NO CLUB no llegan a aplicar tréboles (R47-A) | — |

Ninguna prueba con VIDA (relleno a 10): no se ha usado una póliza VIDA con solicitudes; la lógica es la misma copiada de SCA.

## 6. Dudas para el analista

- **D1 (caso 2, marca de póliza).** 0002729391736 tiene en CORE `MCA_PENDIENTE = S` sin ninguna solicitud. SCA y SCA2 muestran el aviso «Existe una solicitud en curso» por esa marca. ¿Es una marca que se quedó colgada en CORE (migración wAutemis) y hay que limpiarla en origen? Desde SCA2 no se toca: sería un cambio de comportamiento respecto a SCA y es dato de CORE.
- **D2 (caso 1, TTQ al retomar).** En 15788901 CORE no tiene ningún argumento ejecutado, tampoco el TTQ. ¿Qué pasos se hicieron exactamente al «dar TTQ»: se llegó a ACEPTAR la enhorabuena y salió algún mensaje (por ejemplo, Club MAPFRE o error)? Si el TTQ no se grabó, al retomar se vuelve a pedir el argumentario a CORE; que no lo ofrezca ya puede deberse a que los tréboles se consumieron en Club MAPFRE aunque la contra anulación no se cerrara. Para comprobarlo habría que volver a cargar el argumentario de 15788901, y esa consulta borra y reinserta argumentos, por lo que no se ha hecho sobre su solicitud. ¿Nos autorizáis a hacerlo o preferís retomarla vosotros y pasarnos la captura?
- **D3 (caso 1, «no aparece si la busco»).** Por póliza 2001900000562 la solicitud sí está (SCA2 y CORE). ¿Cómo se buscó: por cliente, por número de solicitud, en SCA en lugar de SCA2, o mientras la pantalla seguía procesando? Con esos datos lo reproducimos.
- **D4 (prueba TTQ completa).** Para probar «TTQ aplicado → FINALIZAR → buscar → retomar» con solicitud nueva hace falta otra póliza de socio Club con campaña TTQ y sin solicitud abierta (ya pedida en N47-1). ¿Nos la podéis pasar?
- **D5 («Pendiente» tras aplicar TTQ).** Aplicar el TTQ deja el argumento Positivo, pero la solicitud sigue «Pendiente» hasta pulsar FINALIZAR en la contra anulación (igual que en SCA). Confirmad que el usuario debe finalizar después de aplicar los tréboles.
