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

PENDIENTE_PRUEBAS

## 7. Comparación con SCA

PENDIENTE_SCA

## 8. No probado

PENDIENTE_NOPROBADO

## 9. Dudas

1. **Usuario `devin` como diseñador del alta.** Al guardar `SCA2 CMD Alta` por MCP, la 44.0 queda publicada por `devin`. Su nodo 12 «Start Decidir» se ejecuta «como diseñador», y `SCA2 CMD Decidir` graba `pp!initiator` en `SCA2 Transicion.usuario` y `SCA2 Solicitud.modifiedBy`. Las altas nuevas grabarán `devin` donde antes grababan GGALV10, que tampoco era el usuario real. **Propuesta:** cuando R50-B termine con Alta y Decidir, el usuario los abre en Designer y pulsa «Guardar y publicar» sin cambios. Alternativa, si se quiere el usuario real: nodo 12 «ejecutar como iniciador», como en R28. Esa alternativa cambia la traza y no se ha aplicado.
2. **Metadatos de longitud del record type.** Designer/MCP siguen mostrando `VARCHAR(255)` en `POLIZA_FECHAULTIMOSINIESTRO` tras la sincronización completa. No afecta a la escritura: la BD admite 1000, y el límite real es el de la regla. Para refrescar el metadato habría que usar «Modificar campos de origen» y guardar el record type, lo que crea una versión nueva del RT de cabecera. No se ha hecho porque no aporta nada funcional.
