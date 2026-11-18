# R47-C — RECARGAR ARGUMENTO no refresca el argumento TTQ (CLUB / NO CLUB) y pruebas TTQ pendientes

Entorno: Appian TEST (`mapfrespain-test`), site SCA2 `/suite/sites/sca2`, usuario funcional JJGONZ2. Fecha: 11/11/2026. Etiquetas: [Observado] visto en pantalla, MCP o logs; [Inferido] deducido del código o de los tiempos.

## 1. Resumen

| # | Tema | Resultado |
|---|---|---|
| 1 | RECARGAR ARGUMENTO tras dar de alta al cliente en Club | **Corregido.** SCA2 sí volvía a llamar al servicio en el código, pero Appian devolvía la respuesta guardada de la llamada anterior cuando la petición era idéntica (misma compañía, catalogación y fecha). SCA lo evita pasando `rand()`; la copia SCA2 lo había perdido. Ahora SCA2 hace lo mismo que SCA |
| 2 | Clientes CLUB y NO CLUB entre las pólizas del analista | Encontrados: 3 NO CLUB y 1 CLUB (ver §4) |
| 3 | Pendientes de R46-D / R47-A | CANCELAR sin aplicar: OK. ACEPTAR con socio Club: el argumento TTQ queda Positivo con «Se han aplicado 2 tréboles al cliente - …», pero **la contra anulación no se finalizaba si la observación pasaba de 255 caracteres** (fallo SCA2, ver §3). **Corregido** y probado con 600 caracteres. SVA, fallo solo de TTQ y económicos: sin probar (ver §5) |
| 4 | RECARGAR con la compañía contraria vacía | Ahora tarda unos **63 s** (llamada real al servicio). Antes la respuesta guardada lo ocultaba. Ver duda D1 |

## 2. Causa

**Qué hace RECARGAR ARGUMENTO** (sección «Compañía contraria y catalogación»):

| | SCA (solo lectura) | SCA2 antes (v8) |
|---|---|---|
| Interfaz | `SCA_CompañiaContrariaCatalogacion` v7 | `SCA2_ContraAnulacionCompaniaCatalogacion` v8 |
| 1.ª llamada | `SCA_modificarCatalogacionCodCiaCntrAnul` (graba compañía/catalogación/fecha en CORE) | `SCA2_modificarCatalogacionCodCiaCntrAnul` (igual) |
| 2.ª llamada | `SCA_consultarListadoArgumentos(body, rand: rand())` → `SCAC_consultarListadoArgumentosREST(body, random)` | `SCA2_consultarListadoArgumentos(body)` → `SCA2_consultarListadoArgumentosREST(body)` — **sin `rand`** |
| Servicio | `POST …/es_pca_gestionartareas_bbe-web/esp/api/1.0/consultarListadoArgumentos` (el mismo para los dos) | igual |
| Dónde deja el resultado | `ri!listaArgumentos` (respuesta completa) | `ri!listaArgumentos` = `local!respArgumentario` del padre `SCA2_ContraAnulacionOpciones` (respuesta completa con `listadoArgumentos` y `treboles`) |
| Carga al abrir la contra anulación | `SCA_ContraAnulacionOpcionesEstrategicas` v11: `refreshVariable(SCA_consultarListadoArgumentos(body, rand: rand()), refreshOnVarChange: ri!tarea)` | `SCA2_ContraAnulacionOpciones` v78: `refreshVariable(SCA2_consultarListadoArgumentos(body), refreshOnVarChange: ri!idTarea)` |

- Las dos aplicaciones vuelven a pedir el argumentario al servicio; ninguna reutiliza datos propios de pantalla o BD [Observado en el código]. El texto TTQ («TU TE QUEDAS NO CLUB MAPFRE 20 TREBOLES DISPONIBLES» / «TU TE QUEDAS 70 TREBOLES DISPONIBLES») viene en la respuesta del servicio.
- El enlace padre/hijo de SCA2 es correcto: el hijo escribe en `local!respArgumentario` del padre (L1688 de Opciones) y de ahí se recalculan lista, selección y tréboles [Observado en el código].
- Las integraciones `consultarListadoArgumentosREST` son de tipo QUERY («Usage … Affects caching»): Appian puede devolver el resultado de una llamada anterior con las mismas entradas. SCA pasa un número aleatorio (`random`) que no se envía al servicio y solo sirve para que las entradas cambien en cada clic. La copia SCA2 se hizo sin esa entrada (la cabecera de la regla todavía documentaba `rand`) [Observado].
- **Prueba antes del cambio** [Observado]: en la solicitud nueva 15788888, RECARGAR sin cambiar nada tardó **0,246 / 0,241 / 0,240 s** (no se llama al servicio, respuesta guardada) y al cambiar la compañía a ALLIANZ 1109, **5,729 s** (llamada real). Por eso en R46-D (se cambió la compañía) RECARGAR parecía funcionar y en el caso del analista (mismo cliente, misma compañía) no: el servicio no se llegaba a llamar y el argumento seguía siendo NO CLUB.

## 3. Objetos cambiados (Appian TEST)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| INT `SCA2_consultarListadoArgumentosREST` | `5db48f50-b77a-47db-9ed9-25264966228a` | v3 → **v4** | Nueva entrada `random` (Number (Decimal)), igual que `SCAC_consultarListadoArgumentosREST`. No se envía al servicio; el resto de propiedades sin cambios |
| ER `SCA2_consultarListadoArgumentos` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053262` | v1 → **v2** | Nueva entrada `rand` (Number (Decimal)) que pasa como `random` a la integración, igual que `SCA_consultarListadoArgumentos` |
| IF `SCA2_ContraAnulacionCompaniaCatalogacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060061` | v8 → **v9** | RECARGAR ARGUMENTO: `rand: rand()` en la llamada. El argumento marcado se sigue conservando (R46-D) |
| IF `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | v78 → **v79** | Carga inicial: `rand: rand()` dentro del `refreshVariable` (como SCA); solo se evalúa al cambiar `idTarea`, no añade llamadas |
| PM `SCA2 CMD CompletarAccion` | `0000f06f-1307-8000-65b1-7f0000014e7a` | nodo 5 «Write Tarea» (el MCP no da número de versión) | La última observación se copia a `SCA2 Datos Solicitud.fecimpresion` (columna Observaciones del buscador), que es `VARCHAR(255)`. Ahora se guarda `left(…, 255)`. A CORE sigue yendo recortada a 999 (R46-D). Backup `backups-r47/SCA2_CMD_CompletarAccion_antes.json` y nodo antes/después `SCA2_CMD_CompletarAccion_nodo5_WriteTarea_{antes,despues}.json`. La expresión releída coincide con la enviada; conexiones y salidas sin cambios |

Protocolo [Observado]: `git pull` → reserva en `coordinacion-ronda47.md` (commit `5532d2c`) → export vivo → backups `backups-r47/SCA2_consultarListadoArgumentosREST_v3.json`, `SCA2_consultarListadoArgumentos_v1.json`, `SCA2_ContraAnulacionCompaniaCatalogacion_v8.sail`, `SCA2_ContraAnulacionOpciones_v78.sail` (commit `c19770b`) → cambio → actualización por MCP (respuestas con `previousVersionId` 3/1/8/78) → reexport `…_v4.json`, `…_v2.json`, `…_v9.sail`, `…_v79.sail`, idénticos a lo enviado (commit `f31cbcc`). `testInterface` de `SCA2_ContraAnulacionCompaniaCatalogacion` v9 sin errores. Otro dependiente de la integración: `SCA2_tmpMedicionArgumentario` (regla temporal); la entrada nueva es opcional y no le afecta. No se ha tocado ningún objeto SCA, SCAC, CORE, Club ni TTQ.

**Segundo fallo (observación de más de 255 caracteres)** [Observado]: al ACEPTAR la enhorabuena en 15788894 con 1.100 caracteres en Observaciones, la pantalla mostró «No se puede escribir en ni eliminar del origen debido a una violación de integridad de datos … value too long for type character varying(255) … bandeja de errores para su relanzamiento». `SCA2 Error` id **215**: `SCA2 CMD CompletarAccion`, nodo «Write Tarea», `WRITE_FAIL`, 15:00:02 UTC, `estado PENDIENTE`, `payload.resultado.observaciones` con 1.100 caracteres. El nodo «Write Tarea» es el primero del comando, así que no se llegó a llamar a CORE (Finalizar CA PCA). Origen: copia SCA2 (S4, paridad del buscador) que escribe la observación completa en una columna de 255. No ocurre en SCA, que no tiene esa tabla.

## 4. Pruebas

Horas en UTC (Madrid = UTC+1). Todas las solicitudes son nuevas, creadas por JJGONZ2 el 11/11/2026 con DECISIÓN DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA, a vencimiento, oficina VILLALBA. Tiempos medidos desde el clic hasta que la pantalla vuelve a estar disponible.

| # | Prueba | Solicitud | Póliza | Esperado | Real | OK/KO | Pasos / evidencia |
|---|---|---|---|---|---|---|---|
| P1 | Cliente NO CLUB | 15788888 | 2002100424269 (Autos) | Argumento TTQ NO CLUB | «TU TE QUEDAS NO CLUB MAPFRE 20 TREBOLES DISPONIBLES»; Datos cliente: Club no activo | OK | `../img/r47-c-01-no-club-antes.png`, `r47-c-10-no-club-datos-estado.png` |
| P2 | Cliente NO CLUB | 15788891 | 2002400364603 (Autos) | Argumento TTQ NO CLUB | Igual que P1 | OK | `../img/r47-c-05-segunda-no-club-ttq.png`, `r47-c-11-segunda-no-club-datos-estado.png` |
| P3 | Cliente NO CLUB (Hogar) | 15788893 | 0739988190913 (Hogar) | Argumento TTQ NO CLUB | «TU TE QUEDAS HOGAR NO CLUB 20 TREBOLES DISPONIBLES» | OK | `../img/r47-c-07-ttq-anterior.png`, `r47-c-12-hogar-no-club-datos-estado.png` |
| P4 | Cliente socio Club | 15788894 | 2002600036910 (Autos) | Argumento TTQ Club | «TU TE QUEDAS 70 TREBOLES DISPONIBLES» (el literal de socio no dice CLUB); Datos cliente: Activo Club Mapfre **Sí**, Plata | OK | `../img/r47-c-07-nueva-2002600036910-ttq.png`, `r47-c-13-club-datos-estado.png` |
| R1 | RECARGAR sin cambios, **antes** del arreglo | 15788888 | 2002100424269 | Debe volver a consultar el servicio | 0,246 / 0,241 / 0,240 s; no se llama al servicio | KO (causa) | `../img/r47-c-02-no-club-despues-tiempos.png`, `r47-c-03-no-club-ttq-tiempos.png` |
| R2 | RECARGAR cambiando compañía, antes | 15788888 | 2002100424269 | Consulta real | ALLIANZ 1109: 5,729 s | OK | Por eso R46-D no lo detectó |
| R3 | RECARGAR sin cambios, **después**, compañía informada | 15788888 | 2002100424269 | Consulta real en cada clic | ALLIANZ 1109: 4,961 s (14:49:33) y 3,199 s (14:49:42); argumento marcado y literal NO CLUB se mantienen | OK | `../img/r47-c-23-allianz-repetidas.png` |
| R4 | RECARGAR después, compañía vacía | 15788888 / 15788894 | 2002100424269 / 2002600036910 | Consulta real | 63,132 / 62,855 / 63,121 s; 62,970 s (14:46:56); 63,170 s sin argumento marcado (14:55:08). Sin errores, literales iguales | OK (lento, D1) | `../img/r47-c-21-no-club-recargas-tiempos.png`, `r47-c-22-club-recarga.png`, `r47-c-26-vacia-sin-seleccion.png`. En los logs del servidor no hay timeout de Appian a esas horas |
| R5 | Salir y volver a entrar en la contra anulación, después | 15788888 | 2002100424269 | Carga bien | Carga bien | OK | — |
| R6 | Cambio real NO CLUB → Club y RECARGAR | — | — | Pasa a «TU TE QUEDAS 70…» | No probado: no damos de alta a clientes en Club MAPFRE | PENDIENTE | Lo puede repetir el analista con su solicitud (ver §6) |
| S1 | Comparación con SCA, misma póliza | 15788888 (solo lectura en SCA) | 2002100424269 | Mismo argumentario | SCA muestra el mismo TTQ NO CLUB 20 pendiente. No ofrece RECARGAR en una solicitud SCA2; no se creó nada en SCA | OK parcial | `../img/r47-c-24-legacy-solo-lectura.png`, `r47-c-25-legacy-ttq.png`. La comparación de RECARGAR es de código (§2) |
| T1 | Socio Club: TTQ → POSITIVO → 2 → enhorabuena → **CANCELAR** (14:58:26) | 15788894 | 2002600036910 | No se aplica nada | TTQ sigue Pendiente, sin usuario, fecha ni observación | OK | Antes se hizo NEGATIVO el obligatorio INCREMENTO PRIMA SINIESTROS (lo exige: «DEBEN EJECUTARSE LOS ARGUMENTOS OBLIGATORIOS PREVIAMENTE»). `../img/r47-c-29-enhorabuena-antes-cancelar.png`, `r47-c-2A-ttq-cancelado-pendiente.png` |
| T2 | Igual con **ACEPTAR** (15:00:00) y 1.100 caracteres en Observaciones | 15788894 | 2002600036910 | Se aplican tréboles, observación «Se han aplicado Y tréboles», contra anulación positiva | TTQ **Positivo** con «Se han aplicado 2 tréboles al cliente - Se ha aplicado la reserva de prima del argumento TU TE QUEDAS 70 TREBOLES DISPONIBLES». La contra anulación **no** se finaliza: error 255 (§3, `SCA2 Error` 215) | KO → corregido | `../img/r47-c-2D-enhorabuena-antes-aceptar.png`, `r47-c-2E-ttq-confirmado.png`, `r47-c-2H-club-ttq-persistido.png`. Queda pendiente de relanzar (§7) |
| T3 | Económicos / datos cliente tras T2 | 15788894 | 2002600036910 | Tréboles y reserva de prima grabados | Datos cliente: Tréboles 0,00, RSV prima 0,00 € (también tras «Actualizar datos», 15:02); Solicitud anulación: Reserva prima «NO SOLICITADA / -». La pantalla no tiene otro apartado de económicos | PENDIENTE | `../img/r47-c-2I-club-datos-tras-ttq.png`, `r47-c-2J-club-actualizar-datos.png`. Ver D3 |
| O1 | Límite de Observaciones en pantalla | 15788894 / 15788891 | — | (Analista) la pantalla limita a 250 | Muestra «límite 250» y aviso, pero deja escribir o pegar más y **no bloquea** POSITIVO ni FINALIZAR | Documentado | `../img/r47-c-2B-observaciones-limite.png`. Ver D2 |
| O2 | FINALIZAR con 1.100 caracteres (15:08:16) | 15788891 | 2002400364603 | Como SCA | Bloquea con «El campo de observaciones ha sobrepasado el límite de 999 caracteres» (literal SCA; no se trunca en este camino) | OK | `../img/r47-c-2P-resultado-finalizar-1100.png` |
| O3 | FINALIZAR con 600 caracteres **tras el arreglo** (obligatorio y TTQ NEGATIVO; Sí 15:10:12) | 15788891 | 2002400364603 | Se finaliza; sin error | «CORRECTO / Los datos se han guardado correctamente»; Contra anulación **Finalizada Negativa**; sin filas nuevas en `SCA2 Error`; `fecimpresion` y columna Observaciones del buscador = 255 caracteres «R47C-600 …» | OK | `../img/r47-c-2S-finalizado-600.png`, `r47-c-2T-detalle-finalizado-600.png`, `r47-c-2U-buscador-despues-600.png`. El detalle de la contra anulación muestra Observaciones «-» (D4) |
| V1 | SVA | 15788888/91/93/94 | las 4 | Argumento SVA | No aparece ningún argumento SVA (sí «SERVICIOS MAPFRE», que no se ejecutó) | PENDIENTE | `../img/r47-c-2L-hogar-opciones-sva-reserva.png`, `r47-c-2M-no-club-opciones-sva-reserva.png` |
| V2 | Reserva de prima | 15788894 | 2002600036910 | Reserva aplicada | Solo la observación de T2 («Se ha aplicado la reserva de prima…»). Sin dato de reserva en pantalla | PENDIENTE | D3 |
| E1 | Fallo solo de TTQ y relanzamiento | — | — | Fila «SCA2 TTQ GrabarTreboles» relanzable | No se puede provocar sin tocar otros sistemas | PENDIENTE | — |
| E2 | `SCA2 Error` por MCP | todas | — | Solo el error esperado | Solo la fila 215 (T2). Ninguna de RECARGAR ni de O3 | OK | MCP `listRecordData` `d7111f93-55f3-4b43-b921-aedadd2af7c3` |

Vídeos de la prueba (no se suben al repositorio): fase 1 `rec-afe3abd6…`, fase 2 `rec-e92cef6c…`.

## 5. Sin probar

- Cambio real NO CLUB → Club y RECARGAR (R6). El arreglo hace que el servicio se consulte en cada clic, como SCA; que el texto cambie depende de lo que responda el servicio.
- Que los tréboles y la reserva de prima estén grabados en Club, en TTQ y en económicos (T3, V2).
- SVA (V1) y fallo solo de TTQ con relanzamiento (E1).
- Relanzar el error 215 de 15788894: JJGONZ2 no entra en `/errores` y no se ha relanzado con otro usuario. Con el arreglo, el relanzamiento ya no debería fallar en «Write Tarea».

## 6. Dudas para el analista

- **D1.** Con la compañía contraria **vacía**, RECARGAR (y cada llamada al argumentario) tarda unos 63 s; con compañía, 3–6 s. Appian no registra timeout, así que la demora es del servicio `consultarListadoArgumentos` (o de `modificarCatalogacionCodCiaCntrAnul`, que va antes). SCA hace las mismas dos llamadas con los mismos datos, así que debería tardar lo mismo [Inferido, no medido en SCA]. ¿Es normal en PRE? ¿Queréis que RECARGAR avise o pida la compañía antes?
- **D2.** El aviso de 250 caracteres en Observaciones no bloquea nada; el límite real es 999 (FINALIZAR bloquea por encima, POSITIVO TTQ recorta a 999 lo que va a CORE). ¿El 250 debe bloquear o basta con 999, como SCA?
- **D3.** Tras aplicar 2 tréboles a 15788894, Datos cliente sigue en Tréboles 0,00 y RSV prima 0,00 €, y Reserva prima «NO SOLICITADA». ¿Podéis confirmar en Club / TTQ / económicos si se grabaron? ¿Es normal que tarde en verse?
- **D4.** En 15788891 (negativa con 600 caracteres), el buscador muestra la observación (255), pero el detalle de la contra anulación muestra «-». ¿En SCA se ve la observación de una contra anulación negativa en el detalle?
- **D5.** ¿Repetís vuestra prueba (alta en Club y RECARGAR) en vuestra solicitud? Ahora el servicio se consulta en cada clic.
- **D6.** ¿Alguien con acceso a `/errores` puede relanzar el error 215 (15788894)? Así se cierra la contra anulación positiva y se prueba el relanzamiento con el arreglo.

## 7. Solicitudes creadas y estado final

| Solicitud | Póliza | Estado final [Observado en pantalla y en `SCA2 Solicitud`] |
|---|---|---|
| 15788888 | 2002100424269 | Solicitud Pendiente / Contra anulación Incompleta; ningún argumento ejecutado |
| 15788891 | 2002400364603 | Solicitud Pendiente / Contra anulación **Finalizada Negativa**; siguiente tarea Gestión Verti/vencimiento sin hacer |
| 15788893 | 0739988190913 | Solicitud Pendiente / Contra anulación Incompleta; ningún argumento ejecutado |
| 15788894 | 2002600036910 | Solicitud Pendiente / Contra anulación Incompleta; obligatorio Negativo, TTQ Positivo (2 tréboles); `SCA2 Error` 215 PENDIENTE de relanzar |

No se han modificado solicitudes históricas (15788859, 15788860, 15788878 solo se consultaron). La solicitud de la captura del analista es probablemente la **15788878** (póliza 2001900000476, creada el 11/11 a las 12:07 por JJGONZ2) [Inferido por fecha y estado].
