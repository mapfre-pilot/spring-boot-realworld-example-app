# R50-A · Caché de cabecera sin duplicados, paso 3 de BD (UNIQUE C1) y límite de la fecha del último siniestro

Fecha: 16/11/2026 · Entorno: Appian TEST (`mapfrespain-test`), aplicación SCA2. Nunca PRO.

## 1. Resultado en una línea

El alta ya no deja una segunda fila de caché de cabecera: reutiliza la que haya creado la Web API durante el propio alta. Se han borrado las filas sobrantes (0 duplicados), el enlace GESVIDA ya no se corta a 255 y el SQL C1 está listo para que lo ejecute el usuario.

## 2. Decisión y por qué

**Quién escribía la segunda fila.** Se ha repasado todo lo que escribe en `sca2_datos_cabecera`:

| Escritor | Qué hacía | ¿Inserta una segunda fila? | Decisión |
|---|---|---|---|
| Web API `SCA2_refrescarCacheCabecera` → `SCA2_renovarCacheCabecera` | Relee el id de la fila de la solicitud (`SCA2_obtenerIdFilaCacheCabecera`) **después** de la carga en vivo y escribe con ese id (UPDATE). En el `onSuccess` borra las sobrantes; en el `onError` responde 200 con la cabecera. | Solo si dos llamadas coinciden en milisegundos | **Sin cambios.** Con C1 la segunda llamada falla con `unique_violation`, cae en el `onError` y responde 200 con la cabecera calculada: se comporta como «ya refrescada». |
| PM `SCA2 CMD RefrescarCacheCabecera` | Actualiza la fila que recibe (por id) | No | **Sin cambios.** |
| PM `SCA2 CMD Alta`, nodo 8 «Write Datos» | Dos constructores de `SCA2 Datos Cabecera` **sin id** (fila completa si `SCA2_USAR_CACHE_CABECERA`, fila parcial si no) | **Sí, siempre** (r38-a §14: la cabecera se evalúa durante el alta, llama a la Web API y luego el nodo inserta otra) | **Cambiado**: los dos constructores llevan `id: rule!SCA2_obtenerIdFilaCacheCabecera(idSolicitud: pv!idSolicitud)`. Si ya hay fila, es un UPDATE; si no, un INSERT como antes. |

Con C1 creado y sin este cambio, el nodo 8 del alta fallaría con `unique_violation` y el alta iría a su ruta de error: por eso el cambio del alta es requisito previo de C1. El contenido grabado no cambia (mismos campos y valores), solo se evita la fila extra. Además, la primera apertura tras el alta deja de hacer la carga en vivo de 5–8 s que hacía `SCA2_obtenerDatosCabecera` v8 para limpiar el duplicado.

**Doble disparo.** No hay un doble disparo propio del código: las dos escrituras venían de dos caminos distintos (Web API y alta) y de dos evaluaciones simultáneas de la cabecera (carga y recarga, o dos pestañas). Lo primero se corrige con el cambio del alta. Lo segundo ya estaba reducido a milisegundos (r38-a §11); con C1 la base de datos lo impide del todo y la Web API lo tolera.

**Límite.** El recorte estaba en `SCA2_ajustarFilaCacheCabecera` con los límites de `SCA2_limitesFilaCacheCabecera` (lo usa el PM de refresco; la Web API no recorta). La columna ya es `VARCHAR(1000)` (R46-D), así que el límite pasa de 255 a 1000.

## 3. Objetos cambiados (versión antes→después)

| Objeto | Antes→después | Cambio |
|---|---|---|
| PM `SCA2 CMD Alta` | 43.0→44.0 | Nodo 8: `id` en las dos filas de `SCA2 Datos Cabecera`. El resto del nodo (otros registros, entradas, salidas, conexiones, asignación) es idéntico (comparado tras reexportar). |
| `SCA2_limitesFilaCacheCabecera` | v1→v2 | `polizaFechaultimosiniestro`: 255→1000 |
| `SCA2_renovarCacheCabecera` | v4 (sin cambios) | — |
| Web API `SCA2_refrescarCacheCabecera` | v9 (sin cambios) | — |
| PM `SCA2 CMD RefrescarCacheCabecera` | 7.0 (sin cambios) | — |
| RT `SCA2 Datos Cabecera` | v12 (sin cambios de diseño) | Sincronización completa manual 16/11 16:37: 519/519 filas, «Completado», sin avisos |
| RT `SCA2 Transicion` | v1 (sin cambios de diseño) | Sincronización completa manual 16/11 16:38: 3.251/3.251 filas, «Completado», sin avisos |

Copias: `backups-r50/r50a/` (antes y después).

Comprobación del límite (test runner de Appian): `SCA2_limitesFilaCacheCabecera` devuelve `limite: 1000`; `SCA2_ajustarFilaCacheCabecera` con 900 caracteres en la fecha del último siniestro los conserva todos y con 300 en `clienteNombre` sigue recortando a 255.

## 4. Datos técnicos borrados desde Appian

Lectura previa (LCP, 16/11 15:3x GMT): 524 filas y 5 solicitudes con 2 filas, todas `CACHE` separadas 4–8 s (la pareja Web API + alta). Se ha borrado la de menor id de cada una con `deleteRecordData` del MCP (equivale a `SCA2_obtenerFilasDuplicadasCacheCabecera` + `a!deleteRecords`) y se ha dejado la más reciente:

| Solicitud | Filas | Borrada | Conservada |
|---|---|---|---|
| 15788810 | 584, 585 | 584 | 585 |
| 15788865 | 661, 662 | 661 | 662 |
| 15788867 | 665, 666 | 665 | 666 |
| 15788876 | 683, 684 | 683 | 684 |
| 15789144 (alta de hoy 12:46, otra sesión R50) | 786, 787 | 786 | 787 |

La 15789144 no estaba en la lista: es un duplicado nuevo del mismo origen y, si se dejaba, C1 no podría crearse. Lectura posterior: 519 filas, 519 solicitudes, 0 duplicados. La copia de las filas borradas se guarda fuera del repositorio porque contiene datos de clientes.

## 5. SQL para el usuario (paso 3 de BD, C1)

Script: `docs/sca/sql/70-r50a-c1-unique-cache-cabecera.sql`. Se ejecuta en TEST con DBeaver, con **Auto-commit activado** y **Alt+X** (ejecutar script). Ejecútalo **después** de que el alta 44.0 esté publicada, que ya lo está.

1. **Bloque 1** (solo lectura): cuenta los duplicados y el estado del índice. Si hay duplicados, lanza un `ERROR` y DBeaver (Alt+X) o `psql -v ON_ERROR_STOP=1` paran el script **sin crear el índice**. Si no, avisa con `RAISE NOTICE`.
2. **Bloque 2**: `CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS ux_sca2_datos_cabecera_id_solicitud`. Va suelto porque `CONCURRENTLY` no admite ni `DO` ni transacción, y no bloquea las escrituras. Si hay duplicados, falla y no crea nada útil.
3. **Bloque 3**: si el índice ha quedado `INVALID` (creación fallida), lo borra y avisa.
4. **Verificación**: un único JSON con filas, solicitudes, duplicados, estado del índice, longitud de la columna y su uso máximo, e índices de la tabla. Es lo que hay que devolver.

Es idempotente: si se repite con el índice ya válido, no hace nada. Rollback: `DROP INDEX CONCURRENTLY IF EXISTS sca2_anulaciones.ux_sca2_datos_cabecera_id_solicitud;`.

Prueba en PostgreSQL 14 local (misma tabla y columnas clave):

| Caso | Resultado |
|---|---|
| Con un duplicado | Bloque 1 `ERROR C1: hay 1 ID_SOLICITUD duplicados… script detenido`; el script para y el índice no existe. En la versión anterior, con `WARNING`, el bloque 2 llegaba a ejecutarse y fallaba; el bloque 3 borraba el `INVALID` |
| Sin duplicados | `NOTICE … creado y VALIDO`; JSON con `valido: true, unico: true` |
| Repetir | `NOTICE … ya existe`, `already exists, skipping` |
| INSERT de un `ID_SOLICITUD` repetido | `duplicate key value violates unique constraint "ux_sca2_datos_cabecera_id_solicitud"` (el `unique_violation` que tolera la Web API) |
| Rollback | `DROP INDEX` correcto |

Después de C1 no hace falta sincronizar `SCA2 Datos Cabecera`: un índice no cambia datos ni columnas.

## 6. Pruebas con solicitudes nuevas

Ronda 1, antes de C1. Usuario funcional JJGONZ2 en el site SCA2 de TEST, 16/11 15:45–16:01 UTC. Pólizas del bloque `polizas/bloque-R50-A.txt`, libres en el buscador antes del alta. Filas contadas por LCP (solo lectura) en cada paso.

| Paso | Hogar 0732300117491 → **15789174** | Autos 2002500069552 → **15789178** |
|---|---|---|
| Justo después del alta (sin abrir el detalle) | 1 fila (810) | 1 fila (812) |
| Primera apertura del detalle | 1 fila (810) | 1 fila (812) |
| «Actualizar datos» 4 veces seguidas | 1 fila (810) tras cada una | 1 fila (812) tras cada una |
| Dos pestañas con «Actualizar datos» casi a la vez | 1 fila (810) | 1 fila (812); las peticiones se solaparon |
| Comprobación final (16:01) | 1 fila (810) | 1 fila (812) |
| Errores `SCA2 Error` | ninguno de estas solicitudes | ninguno |

Antes del cambio, la misma prueba dejaba 2 filas tras el alta (r38-a §14, solicitud 15788604). La pantalla queda estable y sin errores en todas las recargas. La CA se abrió sin ejecutar argumentos y las dos solicitudes quedan pendientes.

Tiempos aproximados (petición principal): primera apertura del detalle de Autos ≈0,68 s, ya que no hace la carga en vivo de limpieza que hacía v8; primer «Actualizar datos» ≈2,2–2,7 s; recarga en una pestaña nueva ≈4 s. A partir del segundo clic, ≈0,08 s sin cambiar `fechaCache` (ver duda 3).

Capturas: `../img/r50a-hogar-antes.png`, `../img/r50a-hogar-despues.png`, `../img/r50a-autos-antes.png`, `../img/r50a-autos-despues.png`.

Ronda 2, después de C1: pendiente de que el usuario ejecute el SQL (§5).

## 7. Comparación con SCA

Con JJGONZ2 en `/suite/sites/sca-site` y la misma póliza, los datos de cliente y póliza de la cabecera coinciden en Hogar y Autos: prima, vencimiento, productor, vehículo y siniestros (en las dos, «fecha último siniestro» vale «-»). Capturas: `../img/r50a-hogar-sca.png`, `../img/r50a-autos-sca.png`.

Incidencia de SCA, ajena a R50-A y no tocada (ya figura en la duda 24 de doc 67): la flecha «Volver» de la cabecera de SCA da HTTP 500 (`sca_datoscabecera`, `a!submitLink` línea 23, «save target must be a local variable», evaluación `8e9a8:22611`). Captura: `../img/r50a-sca-error-volver.png`.

## 8. No probado

- **Ronda 2 con C1 creado**: espera al JSON del usuario. Habrá que repetir el alta, «Actualizar datos» y las dos pestañas, y comprobar que no salen errores (`unique_violation` tolerado).
- **Enlace GESVIDA de más de 255 caracteres en pantalla**: ninguna póliza de prueba tiene siniestros con enlace. La regla se ha probado con el test runner (§3).
- **Simultaneidad exacta**: dos pestañas con clics casi a la vez, no al mismo milisegundo.

## 9. Dudas

1. **Usuario `devin` como diseñador del alta.** Al guardar `SCA2 CMD Alta` por MCP, la 44.0 queda publicada por `devin`. Su nodo 12 «Start Decidir» se ejecuta «como diseñador», y `SCA2 CMD Decidir` graba `pp!initiator` en `SCA2 Transicion.usuario` y `SCA2 Solicitud.modifiedBy`. Las altas nuevas grabarán `devin` donde antes grababan GGALV10, que tampoco era el usuario real. **Propuesta:** cuando R50-B termine con Alta y Decidir, el usuario los abre en Designer y pulsa «Guardar y publicar» sin cambios. Alternativa, si se quiere el usuario real: nodo 12 «ejecutar como iniciador», como en R28. Esa alternativa cambia la traza y no se ha aplicado.
2. **Metadatos de longitud del record type.** Designer/MCP siguen mostrando `VARCHAR(255)` en `POLIZA_FECHAULTIMOSINIESTRO` tras la sincronización completa. No afecta a la escritura: la BD admite 1000, y el límite real es el de la regla. Para refrescar el metadato habría que usar «Modificar campos de origen» y guardar el record type, lo que crea una versión nueva del RT de cabecera. No se ha hecho porque no aporta nada funcional.
3. **«Actualizar datos» repetido no siempre refresca. No se aplica: SCA no tiene equivalente.** El primer clic tarda ≈2,5 s y cambia `fechaCache`. Los siguientes responden en ≈0,08 s con la misma `fechaCache`, incluso pasados más de 60 s. La causa probable es que la integración QUERY `SCA2_refrescarCacheCabeceraIntegracion` (v9) recibe siempre las mismas entradas (`idSolicitud`, `numPoliza`, `usuario`, `forzar=true`) y Appian reutiliza la respuesta. El primer clic sí consulta porque `forzar` pasa de `false` (apertura) a `true`. Ya pasaba antes de R50-A.
   - **Comparación con SCA (TEST, solo lectura, 16/11):** SCA no tiene botón «Actualizar datos» ni caché de cabecera. `SCA_DatosCabecera_Estrategicas` v3 calcula la cabecera al abrir con `rule!SCA_obtenerDatosCabecera(numPoliza, idSolicitud)` (v7). Esa regla llama a unas 30 reglas de servicios sin `rand()` y no tiene forma de forzar una nueva consulta en la misma pantalla. El enlace solo existe en SCA2, como parte de la caché (doc 43-D). Siguiendo la indicación de la coordinación («si SCA tampoco refresca, no lo apliques»), se deja como duda.
   - **Propuesta:** añadir a la integración una entrada `random` que no se envíe al servicio y que `SCA2_obtenerDatosCabecera` le pase `rand()` solo cuando `forzarRefresco` es verdadero. Así, cada clic hace una carga en vivo (≈2,5 s y una escritura de la fila de caché por clic). Con C1 creado, dos clics solapados no pueden duplicar la fila. Necesita el OK del usuario, porque cambia lo que ocurre al pulsar el botón.
