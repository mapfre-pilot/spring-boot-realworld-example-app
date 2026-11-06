# R39 — Errores de exportación en SCA2 CMD Mecanizar y SCA2 CMD MecanizarNSE

## Error
Al exportar la aplicación SCA2, Appian descartaba dos modelos de proceso (APNX-1-4070-005 / APNX-1-4071-003):

- `SCA2 CMD Mecanizar` (id 1180, `0000f06f-4cfc-8000-66d3-7f0000014e7a`), nodo «Preparar actualización» → salida del nodo.
- `SCA2 CMD MecanizarNSE` (id 4196, `0000f095-7c8e-8000-d60a-7f0000014e7a`), nodo «Consultar póliza» → salida del nodo.

Ambos apuntaban a un campo del tipo de registro `ANL Anulacion` (`5d975d44-07f7-435f-9ffc-947cfdff459d`) que «no existe».

## Causa
La salida que rellena `pv!numSituacion` usaba el campo `NUMERO_SUPLEMENTO` con un UUID mal escrito (dos caracteres transpuestos):

| | UUID |
|---|---|
| En los dos PMs (incorrecto) | `762eab69-4178-4b70-9c37-1afcd6cd5edc` |
| Campo real `NUMERO_SUPLEMENTO` del registro | `762eab69-4178-4b70-9c37-1afdc6cd5edc` |

El error venía de la ronda 3/4 (copias `live4/` del PM ya lo tenían). En ejecución Appian no fallaba: `index()` devolvía su valor por defecto (`null`), así que `numSituacion` llegaba siempre vacío a `SCA2_construirConsultaActualizarMecanizacion`.

## Corrección (TEST)
Cambio mínimo: solo se sustituye el UUID en la expresión de salida de cada nodo; resto del PM idéntico (46/31 nodos, 41/31 variables, limpieza `AUTO_DELETE` sin cambios). Backups: `~/sca2work/r39/`.

## Comprobaciones
- Relectura de los dos PMs: 0 referencias al UUID incorrecto, 1 al correcto, resto del JSON igual al backup.
- Validación de la expresión: sin errores ni avisos.
- `SCA2_obtenerAnulacion` (solicitudes 15788166 y 15788275) devuelve el campo con el UUID correcto (valor nulo en esas anulaciones).
- Pendiente: repetir la exportación de la aplicación (LCP no permite exportar).

## Efecto funcional
Desde ahora, cuando la anulación tenga número de suplemento, se envía en `numSituacion` al actualizar la mecanización (antes iba siempre vacío). Las instancias ya en curso siguen con la versión anterior.
