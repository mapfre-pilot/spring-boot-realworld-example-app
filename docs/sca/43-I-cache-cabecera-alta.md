# 43-I — Caché de la cabecera en la pantalla de alta (clave por número de póliza)

Entorno: **Appian TEST** (`mapfrespain-test`), aplicación `SCA2 Sistema Comercial de Anulaciones` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`), MCP `appian-dev-mcp-c90b`. Fecha: 2026-11-27. Paquete: **SCA2 Caducidad TM 27-11-2026** (`230be394-bb39-4d0c-bb48-e7966391839f`).

## 1. Decisión

La caché de la cabecera (43-D) se busca por `idSolicitud`. `SCA2_AltaSolicitudPage` pide la cabecera antes de que exista la solicitud (`idSolicitud: null`), así que el alta iba siempre en vivo (5–8 s). ggalv10 decidió el 27/11 **cachear también el alta por número de póliza, aceptando datos de hasta un día** (cierra la duda 64).

## 2. Diseño

- Clave de la fila del alta: `idSolicitud = "POL-" & numPoliza` en el mismo record `SCA2 Datos Cabecera`, con `origenCache = "CACHE"` y la misma caducidad (05:00 Europe/Madrid del día siguiente). Una fila por póliza: la Web API hace upsert por clave, como con las solicitudes.
- Solo la usa la pantalla de alta: `SCA2_obtenerDatosCabecera` tiene una entrada nueva `cachearPorPoliza` (Boolean, por defecto false). Sin ella, cualquier llamada con `idSolicitud` vacío sigue en vivo como antes.
- Interruptor propio `SCA2_USAR_CACHE_CABECERA_ALTA` (true). En false el alta vuelve a ir en vivo. También manda `SCA2_USAR_CACHE_CABECERA` (y `SCA2_USAR_WEBAPI_CACHE_CABECERA` para la escritura).
- La primera consulta de una póliza en el día va en vivo por la Web API `sca2-cache-cabecera` y guarda la fila. Las siguientes se leen de la fila. «Otras solicitudes» sigue siempre en vivo (1 llamada), como en el resto de la caché.
- Las filas `POL-` no las tocan ni el refresco (`SCA2 CMD RefrescarCacheCabecera` filtra por solicitudes abiertas) ni la invalidación por estado (43-G, por `idSolicitud` real): caducan a las 05:00. El enlace «Actualizar datos» no está en el alta; `forzarRefresco: true` sí renueva la fila.
- Las solicitudes no cambian: con `idSolicitud` informado la clave sigue siendo la solicitud. `SCA2 CMD Alta` (nodo «Contexto») sigue creando la fila de la solicitud como hasta ahora.

## 3. Objetos tocados (copia previa: versión anterior en Appian)

| Objeto | UUID | Antes → después | Cambio |
|---|---|---|---|
| `SCA2_obtenerDatosCabecera` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053304` | v8 → v9 | `local!claveCache` (solicitud, o `POL-numPoliza` si `cachearPorPoliza` y el interruptor); se usa en la consulta de la fila, la comprobación de duplicados y la llamada a la Web API. Las llamadas en vivo siguen recibiendo `ri!idSolicitud`. Entrada nueva `cachearPorPoliza`. |
| `SCA2_renovarCacheCabecera` | `_a-0000f093-2064-8000-9d36-011c48011c48_5607622` | v4 → v5 | Para claves `POL-`, `clienteCodint` sale del tomador de la póliza (`SCA2_consultarPolizas` / `SCA2_pObtenerPolizaFecha`, igual que la carga en vivo), porque no hay Datos Poliza de solicitud. Sin esto «Otras solicitudes» salía vacío desde la caché. |
| `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v60 → v61 | `rule!SCA2_obtenerDatosCabecera(numPoliza: local!numPoliza, idSolicitud: null, cachearPorPoliza: true)`. |
| `SCA2_USAR_CACHE_CABECERA_ALTA` (nueva) | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5822445` | — → v1 | Boolean true. |

Vuelta atrás: `SCA2_USAR_CACHE_CABECERA_ALTA = false` (sin desplegar nada), o restaurar las versiones anteriores de la tabla.

## 4. Pruebas en TEST (sin gastar pólizas: solo lectura de la cabecera con `testRule`)

| Póliza | Tipo | En vivo | 1ª alta (escribe fila) | 2ª alta | 3ª alta | Otras solicitudes vivo / caché |
|---|---|---|---|---|---|---|
| 2002300300497 | NSE-Autos | 4,8 s | 4,1 s | 1,6 s | 1,5 s | 3 / 3 |
| 8739204450170 | NSE-Hogar | 6,9 s | 5,0 s | 1,6 s | 1,8 s | 0 / 0 |
| 0001047017079 | wAutemis | 4,2 s | 3,6 s | 1,5 s | 1,5 s | 1 / 1 |

Tiempos medidos desde el MCP (incluyen ~1 s de ida y vuelta). La salida de la 2ª y 3ª consulta es igual a la de la 1ª y a la carga en vivo, salvo `tipoProductor` en wAutemis, que depende del usuario que ejecuta la carga (la Web API la hace con su propio usuario): pasa lo mismo con la caché de solicitudes desde 43-D.

- Filas creadas: `POL-2002300300497`, `POL-8739204450170`, `POL-0001047017079`, una por póliza, `validaHasta` 28/11 04:00 UTC (05:00 Madrid), con `clienteCodint` informado.
- Regresión: solicitud 15789437 sigue leyendo su fila; las llamadas sin `cachearPorPoliza` y sin solicitud siguen en vivo y no crean filas.
- Pantalla de alta (`testInterface` de `SCA2_AltaSolicitudPage` v61): 2002100194588 sin fila previa, 9,4 s la 1.ª vez y 2,3 s al reabrir, con los mismos 38 textos de cabecera y una sola fila `POL-2002100194588`; 2002300300497, ya cacheada, 3,1 s y 3 otras solicitudes.
- En el site no se pudo abrir el alta de esas pólizas porque ya tienen una solicitud en curso. No se envió ni se creó nada.
