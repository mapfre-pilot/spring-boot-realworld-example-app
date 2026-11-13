# R48-C — Regresión de SCA2 en Appian TEST tras el paso 1 de índices de BD

Entorno: Appian TEST (`mapfrespain-test`), site `/suite/sites/sca2`, usuario funcional `JJGONZ2` (SSO Mapfre NO PRO). Lecturas técnicas con el MCP de TEST (`appian-dev-mcp-c90b`) y Designer en solo lectura. Fecha de la prueba: 13/11/2026 (horas en UTC salvo que se indique CET).
Cambio validado: `docs/sca/sql/66-paso1-test-indices.sql` (24 índices B-tree + `ANALYZE` + ampliación de `sca2_datos_cabecera.POLIZA_FECHAULTIMOSINIESTRO` 255→1000 y `sca2_transicion.CLAVE_IDEMPOTENCIA` 120→200). Detalle en [66 §9–§10](../66-indices-bd-sca2.md).

**Qué no se ha hecho:** no se ha cambiado ningún objeto Appian, no se ha ejecutado DDL ni DML, no se ha lanzado ninguna sincronización completa de record types, no se ha tocado SCA, SCAC, CORE, CMP, PRE, NSE ni ANL, y no se han modificado solicitudes antiguas.

## 1. Resumen

| Punto | Resultado |
|---|---|
| Record types (Datos Cabecera, Transicion, Datos Solicitud) | **OK.** Sincronizados, última sincronización «Éxito», sin avisos ni errores de esquema. No necesitan sincronización completa. |
| Regresión funcional con solicitudes nuevas | **OK, sin regresión atribuible al paso 1.** 3 solicitudes nuevas: **15788998** (Autos, contra anulación), **15788999** (Autos, Acción Administrativa), **15789000** (Hogar, contra anulación positiva). Un intento más (póliza 2001900000211) lo rechazó NSE sin crear solicitud. |
| Tiempos | En línea con las mediciones anteriores; ninguno empeora de forma clara (§4). |
| Cuadro de mando y `/errores` | `JJGONZ2` no tiene acceso (página de administradores, igual que antes). El cuadro de mando se evaluó en Designer: se pinta sin error en 152 ms. |
| `POLIZA_FECHAULTIMOSINIESTRO` > 255 | **No comprobable con datos reales:** el valor más largo que hay en TEST mide 241. Además, Appian sigue recortando a 255 por diseño (regla `SCA2_limitesFilaCacheCabecera`), así que la ampliación a 1000 **todavía no se aprovecha**. |
| `FECIMPRESION` (VARCHAR(255)) | Guarda la última observación de la solicitud. `SCA2 CMD CompletarAccion` la recorta a 255 (sin error). `SCA2 CMD Alta` y `SCA2 CMD Posponer` la escriben **sin recorte**: hoy no fallan porque la interfaz limita el texto (240/250), pero es un riesgo. SQL de ampliación propuesto en §6, **sin ejecutar**. |

## 2. Record types tras el cambio

Comprobado en Designer (pestaña Data Sync / campos) y con el MCP (`getRecordType`, `listDatabaseTableColumns`, `listObjectVersions`, `listRecordData`). Data source `SCA2 DataBase AWS` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050863`), esquema `sca2_anulaciones`.

| Record type (UUID, versión) | Tabla | Campos | Filas sincronizadas | Última sincronización visible | Avisos de esquema | ¿Sincronizar? |
|---|---|---|---|---|---|---|
| SCA2 Datos Cabecera (`04f597de-5acd-45b2-9ab3-277713cd00a6`, v12) | `sca2_datos_cabecera` | 53 | 490 al empezar; 493 al acabar (filas 743, 745, 747 nuevas) | 21/10/2026 12:33, «Guardado del tipo de registro», Éxito, 1,5 s | Ninguno | No |
| SCA2 Transicion (`0b46024c-58b4-48be-a2a4-20d54bc40815`, v1) | `sca2_transicion` | 12 | ~3,1K | 23/09/2026 15:36, «Importación del tipo de registro», Éxito, 1,5 s | Ninguno | No |
| SCA2 Datos Solicitud (`9a9209c7-aab4-4078-9bef-280de47fdd6e`, v6) | `sca2_datos_solicitud` | 33 | 478 al empezar; filas nuevas 479, 480, 481 | 23/10/2026 12:37, «Guardado del tipo de registro», Éxito, 1,5 s | Ninguno | No |

Los tres son «Optimizado (Sincronizado)» y `listDatabaseTableColumns` devuelve `canBackRecordType: true`. Las escrituras nuevas (`a!writeRecords` de los procesos) entraron en la sincronización al momento: las filas nuevas se leen por el record type sin esperar a ninguna sincronización programada.

**Tipos de las columnas ampliadas:**

| Columna | Tipo físico (BD, tras el paso 1) | Tipo que muestra Appian en la tabla del record type | Efecto |
|---|---|---|---|
| `sca2_datos_cabecera.POLIZA_FECHAULTIMOSINIESTRO` | VARCHAR(1000) | VARCHAR(255) | Ninguno en funcionamiento. Appian toma el metadato al guardar o importar el record type; el campo es Texto y el recorte real lo hace la regla de caché (255). |
| `sca2_transicion.CLAVE_IDEMPOTENCIA` | VARCHAR(200) | VARCHAR(255), con indicador de clave única | Ninguno. Ya se mostraba 255 antes (con 120 físicos); el campo es Texto y los valores reales son cortos. |
| `sca2_datos_solicitud.FECIMPRESION` | VARCHAR(255) | VARCHAR(255) | Ver §5. |

**¿Hace falta ajustar algo en Appian?** No para que funcione. Los índices no cambian columnas, y ampliar un VARCHAR no rompe el esquema que Appian espera (no salen avisos ni falla la sincronización). Si se quiere que el metadato de Designer refleje 1000/200, bastaría con volver a guardar el record type o lanzar una sincronización completa. **No se ha hecho**: no es necesario y una sincronización completa relee toda la tabla (Datos Cabecera ~493 filas, Transicion ~3,1K; ~1,5 s según el historial). Mientras dura la sincronización los datos siguen visibles y no se espera ningún error, pero se tendría que hacer en un momento controlado y quedar anotado. Para guardar de verdad textos de más de 255 en la caché hace falta además cambiar la regla de límites (§5.1); eso es un cambio funcional y va aparte.

## 3. Prueba de regresión con solicitudes nuevas

Todas las solicitudes son nuevas, creadas hoy por `JJGONZ2` en el site SCA2. Los tiempos «UI» son de reloj (Playwright, desde el clic hasta que aparece el texto esperado); los de «proceso» son de las instancias (inicio–fin).

### 3.1 Solicitudes creadas

| Solicitud | Póliza | Línea / origen | Flujo | Estado final (`SCA2_cargarSolicitud`) |
|---|---|---|---|---|
| **15788998** | 2002400321576 | Automóviles / NSE-Autos | Alta → Contra anulación (NEGATIVO) → Gestión Verti/vencimiento → mecanización NSE (anulada) → firma RGPD abierta | `EN_ACCION`, `CONTRA_ANULAR`, «CONTRA ANULAR NIVEL 2», tarea PENDIENTE, nivel 2, grupo CE_RM. Buscador: «Póliza Anulada. Solicitud Pendiente Nivel 2». |
| **15788999** | 2002000004992 | Automóviles / NSE-Autos | Alta → Acción Administrativa (sin documentación, anulación a vencimiento) → consulta NSE-Autos | `PDTE_MECANIZAR`, `CONTRA_ANULAR`, proceso activo MECANIZAR, tarea PENDIENTE. Buscador: «Solicitud Finalizada sin anular». No se pulsó ANULAR PÓLIZA. |
| **15789000** | 0730080000041 | Hogar / NSE-Hogar (HOGAR FAMILIAR) | Alta → Contra anulación POSITIVO → finalización | `FINALIZADA_POSITIVO`, `FIN`, sin proceso activo, tarea COMPLETADA, versión 5. Buscador: «Finalizado Contra Anulación Positiva». |
| (ninguna) | 2001900000211 | Automóviles | Alta rechazada por NSE | No se crea solicitud (`SCA2_consultarSolicitudEnCurso` = null). |

### 3.2 Resultado por paso

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa / solución |
|---|---|---|---|---|---|---|---|---|
| A1 | Alta Autos con cabecera | Cabecera cargada, validaciones y solicitud creada | Cabecera cargada; validaciones; «Su solicitud se ha generado correctamente»; gestión de contra anulación abierta. UI ACEPTAR→gestión 23,8 s | OK | 15788998 | `SCA2 CMD Alta` 13408727 (v43, COMPLETED, 11,37 s) | Buscador → póliza → ALTA SOLICITUD ANULACIÓN → motivo/detalle/causa/canal/catalogación → GUARDAR → SÍ → ACEPTAR | — |
| A2 | Caché de cabecera (alta Autos) | Fila nueva en SCA2 Datos Cabecera, `origenCache=CACHE` | Fila `id=743`, `CACHE`, `fechaCache` 07:29:35, `validaHasta` 14/11 04:00 | OK | 15788998 | — | `listRecordData` del record type | — |
| A3 | RECARGAR ARGUMENTO (Autos) | Recarga sin error, botón deshabilitado mientras carga | 3,607 s y 2,726 s; 7 argumentos antes y después; botón deshabilitado durante la carga | OK | 15788998 | — | Pulsar RECARGAR ARGUMENTO dos veces | — |
| A4 | Contra anulación Autos, decisión NEGATIVO | Guarda la gestión y redirige a la siguiente tarea | «CORRECTO. Los datos se han guardado correctamente. Se va a redirigir a la siguiente tarea: Gestión Verti/vencimiento.» Argumento «INCREMENTO PRIMA SINIESTROS» = Negativo (JJGONZ2) | OK | 15788998 | `CompletarAccion` 9203247 (v50, 13,35 s); `Decidir` 12346756; `CrearAccion` 12346757 | Oficina VILLALBA → argumento → NEGATIVO → observación larga (la UI la deja en 250) → FINALIZAR | — |
| A5 | Gestión Verti/vencimiento | Crea la acción y sigue a mecanización | «Generar un vencimiento a un año vista…»; mecanización NSE-Autos (avisos de cálculo provisional y condiciones modificadas, ANULAR PÓLIZA) | OK | 15788998 | `CrearAccion` 10257001 (1,20 s); `SCA2 CMD Mecanizar` 13408793 (ACTIVE, `success=true`, `numGestion=43708581`) | Seleccionar opción → continuar → ANULAR PÓLIZA | — |
| A6 | Firma RGPD / inducción | Se abre firma RGPD | Abierta («Interfaz Firma RGPD 13408800»); **no se completó** a propósito (es CMP) | Parcial | 15788998 | `Firma RGPD Main` 13408800 y `Firma RGPD Completo` 13408799 (ACTIVE) | — | Queda la tarea de inducción pendiente (sale en el aviso de operación del cuadro de mando). |
| B1 | Alta Autos para Acción Administrativa | Solicitud creada y gestión de AA abierta | Validaciones en 18,681 s desde SÍ; gestión «Acciones administrativas» abierta | OK | 15788999 | `SCA2 CMD Alta` 12346793 (v43, COMPLETED, 11,14 s) | DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE / PRESENCIAL → GUARDAR → SÍ → ACEPTAR | — |
| B2 | Caché de cabecera (AA) | Fila nueva | `id=745`, `CACHE`, `fechaCache` 07:55:24 | OK | 15788999 | — | `listRecordData` | — |
| B3 | Acción Administrativa, decisión y finalización | Confirmación y redirección a la anulación | Diálogo «¿Desea continuar? Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» (0,06 s); «CORRECTO… Se va a redirigir a la anulación.» (5,9 s); pantalla «Detalle consulta NSE-Autos» con fecha de anulación 01/02/2027, reserva prima Sí, nivel INFORMATIVO | OK | 15788999 | `CompletarAccion` 269214751 (4,97 s); `Decidir` 269214752 (4,12 s) | Oficina VILLALBA → «El cliente no entrega documentación…» → FINALIZAR → ACEPTAR | No se pulsó ANULAR PÓLIZA para no anular la póliza en NSE; la solicitud queda en `PDTE_MECANIZAR`. |
| C1 | Alta Hogar con cabecera | Cabecera Hogar y solicitud creada | Cabecera (Línea HOGAR, «Fecha último siniestro: -»); aviso de duplicidad de datos (se contestó SÍ); validaciones 17,845 s; ACEPTAR→gestión 33,1 s | OK | 15789000 | `SCA2 CMD Alta` 537648069 (v43, COMPLETED, 15,00 s) | DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA / PRESENCIAL / A VENCIMIENTO; fecha de anulación 29/12/2026 | Al entrar en la póliza salió «Existe una solicitud en curso…» (aviso del buscador); se siguió con el formulario y la solicitud se creó bien. |
| C2 | Caché de cabecera (Hogar) | Fila nueva | `id=747`, `CACHE`, `NSE-Hogar`, `fechaCache` 08:07:15; al finalizar, `validaHasta` pasa a 08:11:19 | OK | 15789000 | — | `listRecordData` | La caché caduca al cerrar la solicitud (observado, no es nuevo del paso 1). |
| C3 | RECARGAR ARGUMENTO (Hogar) | Recarga sin error | 0,38 s y 2,869 s; 7 argumentos antes y después | OK | 15789000 | — | Pulsar RECARGAR ARGUMENTO dos veces | — |
| C4 | Contra anulación Hogar POSITIVO y finalización | Mensaje de retención y cierre | «¡Enhorabuena en la retención de la póliza! Se van a finalizar las acciones de contra anulación en SCA. ¿Desea continuar?» → aceptar → solicitud cerrada `FINALIZADA_POSITIVO` | OK | 15789000 | `Decidir` 269214774 (3,91 s); `CompletarAccion` 10257108 (2,77 s) | Oficina VILLALBA → argumento «ME HA SUBIDO MUCHO LA PRIMA» → POSITIVO → aceptar | No apareció una instancia aparte de `SCA2 CMD Finalizar` para esta solicitud; el estado final es correcto. |
| D1 | Alta rechazada por NSE | Error controlado, sin solicitud | Cabecera en 8,635 s y error de NSE (literal abajo); no se crea solicitud | OK (comportamiento esperado) | — | — | Póliza 2001900000211 → ALTA → GUARDAR | Es un rechazo de NSE por el estado de la póliza, no tiene que ver con los índices. No se reintentó. |
| E1 | Buscador sin filtros | Lista sin error | 476 → 477 → 478 elementos según avanzaba la prueba; 2,34–4,43 s; la última carga (con 15789000 arriba) 2,65 s | OK | 15788998/99, 15789000 | — | Abrir `/suite/sites/sca2` | — |
| E2 | Buscador por póliza | Resultados de la póliza | Póliza 2002400321576 en ~0,89 s: 15788998 (nueva) y 15788897 (R48-A) | OK | 15788998 | — | Filtro Número póliza → BUSCAR | — |
| E3 | Detalle de la solicitud | Detalle con gestiones | ~0,97 s. 15788998: Alta Finalizada, Contra Anulación Finalizada Negativa, Impresión Finalizada, Mecanización Anulación Realizada, Inducción VV En Curso, Contra Anulación Incompleta | OK | 15788998 | — | Clic en la solicitud del buscador | — |
| F1 | Cuadro de mando (Gestiones mantenimiento) | Se pinta sin error | `JJGONZ2`: «Se ha producido un error. La página no existe o no tiene permiso para verla» (6,35 s). En Designer (`testInterface` de `SCA2_CuadroMando`, solo lectura): se pinta sin error en 152 ms, con «Aviso de operación: procesos en espera más de 1 hora (8)» y las gráficas de la pestaña Resumen | OK con limitación | — | — | Abrir `/page/gestiones-mantenimiento`; `testInterface` | Página limitada a `SCA2 Administradores` (igual que antes, ver [62](../62-cuadro-mando.md)). |
| F2 | Bandeja `/errores` | Se pinta sin error | `JJGONZ2`: «Se ha producido un error. La página no existe o no tiene permiso para verla» (6,38 s) | No probado | — | — | Abrir `/page/errores` | Página de administradores (igual que en [11](11-bandeja-errores-informe-testing-agent.md)). Hace falta un usuario de `SCA2 Administradores`. |

Error literal de D1:

```text
NSE nos indica una excepción que impide avanzar con su solicitud. Por favor, compruebe la situación de la póliza en NSE e inténtelo de nuevo más tarde. Si el error persiste póngase en contacto con el SAU  Mensaje de NSE: NO SE PUEDE ANULAR LA POLIZA: EL ESTADO EN QUE SE ENCUENTRA NO LO PERMITE
```

No ha salido ningún otro error en pantalla ni en los procesos durante la prueba.

## 4. Tiempos comparados con mediciones anteriores

Referencias: [65 §rendimiento](../65-valoracion-produccion-rendimiento.md) (instancias retenidas antes del paso 1) y [R48-A](r48-a-espera-alta-y-avisos.md) (15788897/98/99).

| Medición | Antes (referencia) | Ahora (tras el paso 1) | Valoración |
|---|---|---|---|
| `SCA2 CMD Alta` (proceso) | mediana 11,3 s; p90 14,1 s; máx 15 s (65). R48-A: 10,6–12,5 s | 11,37 s (15788998); 11,14 s (15788999); 15,00 s (15789000, Hogar) | Igual. El Hogar iguala el máximo anterior; las de Autos, en la mediana. |
| `SCA2 CMD Decidir` | mediana 5,6 s; p90 10,4 s | 4,12 s (15788999); 3,91 s (15789000) | Igual o algo mejor. |
| `SCA2 CMD CompletarAccion` | mediana 9,7 s; p90 12,8 s; máx 15 s | 13,35 s (15788998, CA negativo + Verti); 4,97 s (15788999, AA); 2,77 s (15789000, CA positivo) | Dentro del rango anterior. R48-A: completar CA positivo 2,955 s → ahora 2,77 s. |
| `SCA2 CMD CrearAccion` | mediana 0,9 s | 1,20 s (Verti/vencimiento, 15788998) | Igual. |
| UI: ACEPTAR del aviso → gestión abierta | R48-A: Autos CA 32,354 s; Hogar CA 28,012 s; AA 23,170 s | Autos CA 23,8 s; Hogar CA 33,1 s | Igual (la variación entre ejecuciones es de ese orden; los puntos de medida son parecidos pero no idénticos). |
| UI: SÍ → «Se han completado todas las validaciones» | — (no medido aparte antes) | 18,681 s (AA); 17,845 s (Hogar) | Sin referencia directa. Incluye las llamadas a NSE de la simulación. |
| UI: carga de cabecera | 65: media 3,9 s, máx 5 s; R47-B: medianas 1,4–4,8 s | ~8,4 s (Autos AA), ~7,8 s (Hogar), 8,6 s (póliza rechazada) | Más lento en reloj, pero no es la misma medida: aquí va desde el clic en la póliza del buscador hasta que se ve el formulario completo (incluye navegación y pintado) y la referencia es el tiempo de la consulta de cabecera. Los índices no intervienen en esta llamada (es a NSE/servicios, y la lectura de caché es por clave). Ver §7. |
| RECARGAR ARGUMENTO | R47-C: sin cifra comparable | 3,61 / 2,73 s (Autos); 0,38 / 2,87 s (Hogar) | Correcto. |
| Buscador sin filtros | — | 2,3–4,4 s | Correcto. |
| Buscador por póliza / detalle | — | ~0,9 s / ~1,0 s | Correcto. |

Conclusión: no hay empeoramiento atribuible al paso 1. Con pocas solicitudes por caso no se puede medir una mejora; los índices se notarán con más volumen (lecturas por `ID_SOLICITUD` y por fecha), como ya dice [66](../66-indices-bd-sca2.md).

## 5. Columnas de texto largo

### 5.1 `POLIZA_FECHAULTIMOSINIESTRO` (caché de cabecera)

- **Datos que hay en TEST:** el valor más largo de `polizaFechaultimosiniestro` en SCA2 Datos Cabecera mide **241** caracteres (fila `id=633`, `PDTE-269184418`, `CACHE`, 10/11/2026 14:30). Ninguno pasa de 255. En Vida/GesVida el campo lleva la cadena de parámetros de la póliza (fila `id=739`, ~217 caracteres). En las tres solicitudes nuevas el valor está vacío («-» en pantalla).
- **Qué hace Appian:** `SCA2_construirFilaCacheCabecera` arma la fila (en GesVida quita el prefijo), `SCA2_ajustarFilaCacheCabecera` recorta cada campo a su límite y `SCA2_limitesFilaCacheCabecera` fija **255** para `polizaFechaultimosiniestro`. En el refresco (PM `SCA2 RefrescarCacheCabecera`) el recorte se anota como `REFRESCO_CACHE_RECORTE`; en las solicitudes nuevas no había nada que recortar (valor vacío), y no se han revisado registros antiguos de esa marca.
- **Conclusión:** no se ha podido confirmar que ahora se guarde entera una cadena de más de 255, porque no hay ninguna póliza así en TEST y porque **Appian la seguiría recortando a 255** aunque la columna admita 1000. La ampliación de BD evita un error de escritura si alguien quita el recorte, pero para aprovecharla hay que subir el límite en `SCA2_limitesFilaCacheCabecera` (cambio funcional, no hecho: no es una regresión del paso 1).

### 5.2 `sca2_datos_solicitud.FECIMPRESION`

**Qué guarda.** A pesar del nombre, guarda la **última observación** de la solicitud (lo que sale en la columna Observaciones del buscador, `SCA2_BuscadorTabla`). La escriben:

| Quién escribe | Qué escribe | Recorte | Límite en la interfaz |
|---|---|---|---|
| `SCA2 CMD CompletarAccion` (CA, AA, autorizaciones) | `left(tostring(index(pv!resultado,"observaciones",null)), 255)` | **Sí, a 255** (comentario del modelo: «R47-C: recortada a 255 (VARCHAR(255)); en CORE se graba completa hasta 999») | 250 en contra anulación y Acción Administrativa; **999** en `SCA2_VertiVencimientoPrincipal` |
| `SCA2 CMD Alta` | observaciones del alta | **No** | 240 |
| `SCA2 CMD Posponer` | `tostring(pv!motivo)` | **No** | no comprobado en esta ronda |

**Comprobado con las solicitudes nuevas:**
- 15788998 (`datosSolicitud.id=479`): se escribió una observación larga; queda guardada con **255 caracteres justos** y `SCA2_cargarSolicitud` devuelve el mismo texto recortado. No hay error. Lo más probable es que los valores de 255 justos que ya había en TEST vengan de este mismo recorte.
- 15789000 (`id=481`): «R48-C regresion indices paso 1 - Hogar CA» (corto, entero).
- 15788999 (`id=480`): observación de la consulta NSE, corta.

**Riesgo.** Hoy no falla: lo que llega por CompletarAccion se recorta y lo que llega por Alta está limitado por la interfaz a 240. Pero:
1. se pierde texto: en CORE la observación se guarda hasta 999 y en SCA2 se queda en 255 (Verti/vencimiento deja escribir 999);
2. `SCA2 CMD Alta` y `SCA2 CMD Posponer` no recortan: si algún día llega más de 255 (por ejemplo, se sube el límite de la interfaz o el motivo de posponer es largo) **fallará la escritura** del `a!writeRecords` con error de longitud de PostgreSQL.

**Propuesta.** Ampliar la columna a 1000 (paridad con CORE, 999) igual que se hizo con `POLIZA_FECHAULTIMOSINIESTRO`, y luego (cambio Appian aparte, no hecho) quitar o subir el `left(…,255)` de CompletarAccion y añadir el mismo tope a Alta y Posponer. SQL en §6.

## 6. SQL propuesto (NO ejecutado)

Para TEST primero, en la misma ventana que el resto de pasos de [66](../66-indices-bd-sca2.md). Ampliar un VARCHAR en PostgreSQL 14 solo cambia el catálogo (no reescribe la tabla ni sus índices).

```sql
-- R48-C (propuesta, NO ejecutado): ampliar la última observación de la solicitud
ALTER TABLE sca2_anulaciones.sca2_datos_solicitud
  ALTER COLUMN "FECIMPRESION" TYPE VARCHAR(1000);

-- Verificación
SELECT column_name, data_type, character_maximum_length
  FROM information_schema.columns
 WHERE table_schema = 'sca2_anulaciones'
   AND table_name   = 'sca2_datos_solicitud'
   AND column_name  = 'FECIMPRESION';

-- Vuelta atrás (solo si ningún valor pasa de 255):
-- SELECT max(length("FECIMPRESION")) FROM sca2_anulaciones.sca2_datos_solicitud;
-- ALTER TABLE sca2_anulaciones.sca2_datos_solicitud ALTER COLUMN "FECIMPRESION" TYPE VARCHAR(255);
```

Tras ejecutarlo, el record type SCA2 Datos Solicitud seguirá funcionando sin sincronizar (igual que Datos Cabecera tras C5); el metadato de Designer seguirá mostrando 255 hasta que se vuelva a guardar o sincronizar.

## 7. Lo que no se ha podido probar y dudas

**No probado:**
1. Bandeja `/errores` y cuadro de mando en el site: `JJGONZ2` no tiene permiso (son de `SCA2 Administradores`). El cuadro de mando solo se evaluó en Designer.
2. Una fecha de último siniestro de más de 255 caracteres: no existe en TEST (máx 241) y Appian la recortaría igualmente.
3. Escritura de más de 255 caracteres en `FECIMPRESION` por Alta o Posponer (la interfaz no lo deja; no se forzó para no generar errores ni datos falsos).
4. 15788999: no se pulsó ANULAR PÓLIZA (habría anulado la póliza en NSE); queda en `PDTE_MECANIZAR`.
5. 15788998: no se completó la firma RGPD ni la inducción (CMP); quedan las instancias `Firma RGPD` 13408799/13408800 y `SCA2 CMD Mecanizar` 13408793 en ACTIVE.
6. Acción Administrativa de Hogar y una contra anulación Hogar negativa: no se hicieron por tiempo; el flujo Hogar probado (CA positiva) y las AA de Autos cubren los mismos procesos y tablas.
7. No se ha repetido en SCA porque no ha salido ninguna diferencia.

**Dudas:**
1. ¿Se quiere que el metadato de los record types refleje los nuevos tamaños (guardar/sincronizar SCA2 Datos Cabecera y SCA2 Transicion)? No hace falta para funcionar; si se hace, conviene anotarlo en 66.
2. ¿Se sube el límite de `polizaFechaultimosiniestro` en `SCA2_limitesFilaCacheCabecera` para aprovechar los 1000? Sin eso, la ampliación C5 no cambia nada en la práctica.
3. ¿Se amplía `FECIMPRESION` (§6) y se iguala el tope en Alta, Posponer y CompletarAccion?
4. 15788999 sale en el buscador como «Solicitud Finalizada sin anular» aunque en SCA2 está `PDTE_MECANIZAR`. La etiqueta sale de `SCA2_calcularEstadoSolicitud` con el estado de CORE (final sin mecanización realizada, regla R46-A), no de los índices; ¿es la etiqueta que espera negocio para una AA pendiente de anular a vencimiento?
5. La carga de la cabecera en reloj (~8 s) es mayor que las cifras de 65/R47-B, pero se midió de forma distinta (§4). Si se quiere comparar bien, habría que medir igual que en R47-B (tiempo de `SCA2_obtenerDatosCabecera`).
6. En el alta Hogar salió «Existe una solicitud en curso para la póliza indicada» antes de crear 15789000. La solicitud se creó bien, pero no se ha aclarado a qué solicitud anterior se refería el aviso.

## 8. Evidencias

- Solicitudes: 15788998, 15788999, 15789000 (y el rechazo de 2001900000211 sin solicitud).
- Instancias: Alta 13408727, 12346793, 537648069; Decidir 12346756, 269214752, 269214774; CrearAccion 12346757, 10257001; CompletarAccion 9203247, 269214751, 10257108; Mecanizar 13408793; Firma RGPD 13408799/13408800.
- Filas nuevas: SCA2 Datos Cabecera 743, 745, 747; SCA2 Datos Solicitud 479, 480, 481.
- Capturas y CSV de la prueba guardados en la máquina de la sesión (no se suben al repositorio).
