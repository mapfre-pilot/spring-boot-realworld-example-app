# Coordinación ronda 38 — optimización de `SCA2 CMD RefrescarCacheCabecera` (MNI) y errores de consola de la caché de cabecera

Origen: petición del usuario (30/10): revisar el PM `SCA2 CMD RefrescarCacheCabecera` para ver si se puede optimizar con MNI (Multiple Node Instances) y evitar un bucle muy grande; revisar los errores de consola sobre los campos de la caché de cabecera. Una sola sesión hija (R38-A).

## Contexto
- PM con temporizador diario 07:05 (R33 §3.4); renueva la caché de cabecera. Diseño original en `43-D-cache-cabecera.md`, `43-F-pm-refresco-cache.md`, prueba `43-H-prueba-integrada.md`.
- Consumidores: Web API `SCA2_refrescarCacheCabecera` ← integración `SCA2_refrescarCacheCabeceraIntegracion` ← `SCA2_obtenerDatosCabecera` (`SCA2_USAR_WEBAPI_CACHE_CABECERA = 1`); regla `SCA2_renovarCacheCabecera`.

## R38-A — objetos propios
PM `SCA2 CMD RefrescarCacheCabecera` (y subprocesos nuevos que necesite), `SCA2_renovarCacheCabecera`, `SCA2_obtenerDatosCabecera`, Web API `SCA2_refrescarCacheCabecera`, integración `SCA2_refrescarCacheCabeceraIntegracion`, record type/CDT de la caché de cabecera, constantes nuevas `SCA2_*` de la caché.
Pólizas (si hace falta solicitud nueva para la regresión): `polizas/bloque-reserva-2.txt` (1201-1600), anotando cada una en `polizas/REGISTRO.md`.

## Reglas
- Sólo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD. No tocar solicitudes antiguas.
- Lectura viva → backup JSON (PM incluido) → cambio mínimo → relectura/comparación nodo a nodo; conservar el temporizador 07:05.
- Comparar caché antes/después (nº de filas y campos) y tiempos/nº de nodos ejecutados en Monitorización.

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| `SCA2_construirFilaCacheCabecera` (v1→v2) | R38-A | Modificado y probado |
| `SCA2_renovarCacheCabecera` (v2→v3) | R38-A | Modificado |
| `SCA2_obtenerDatosCabecera` (v6→v7) | R38-A | Modificado |
| PM `SCA2 CMD RefrescarCacheCabecera` (v6.0) | R38-A | Solo lectura y ejecución de prueba (sin cambios) |
| `SCA2_calcularValidaHastaCache` (v1→v2) | R38-A | Modificado y probado (05:00 Europe/Madrid) |
| `SCA2_HORA_CADUCIDAD_CACHE_CABECERA` (v1→v3, valor 7→5) | R38-A | Modificado |
| `SCA2_TXT_ZONA_HORARIA_CACHE_CABECERA` (nueva, v1) | R38-A | Creada |
| `SCA2_obtenerIdFilaCacheCabecera` (nueva, v1) | R38-A | Creada y probada |
| `SCA2_obtenerFilasDuplicadasCacheCabecera` (nueva, v2) | R38-A | Creada y probada |
| `SCA2_renovarCacheCabecera` (v3→v4) | R38-A | Modificado (fila única) |
| Web API `SCA2_refrescarCacheCabecera` | R38-A | Modificada en Designer (borra filas sobrantes) |
| PM `SCA2 CMD RefrescarCacheCabecera` (v6.0→v7.0) | R38-A | Temporizador retirado en Designer (refresco programado desactivado); 13 nodos y 9 variables intactos; arranque manual probado |
| `SCA2_obtenerDatosCabecera` (v7→v8) | R38-A | Modificado (con más de una fila por solicitud renueva por la Web API, que deja una) |
