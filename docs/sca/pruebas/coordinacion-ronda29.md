# Coordinación ronda 29 (23/10/2026) — 3 sesiones hijas en paralelo

| | R29-A redirección / checks Verti / tarjetas Detalle | R29-B argumentos dos tablas / documentos | R29-C contacto reutilizable / CMP en paralelo |
|---|---|---|---|
| Objetos | `SCA2_DetalleTareas`, `SCA2_VertiVencimientoPrincipal`, `SCA2_DetalleSolicitud`, `CMD CrearAccion` (guardar opción), CDT `SCA2 Datos Solicitud`/`SCA2_cargarSolicitud` (campo opción Verti/Vencimiento) | `SCA2_ContraAnulacion*`, reglas/integraciones/PM de documentos (`SCA2_*Documento*`, `*SGD*`, `*Documentum*`) | PM `CMD Mecanizar`, `CMD Finalizar`, reglas de contacto (`SCA2_*Contacto*`, `SCA2_decidir*`), `SCA2_MecanizacionPrincipal`, CDT `SCA2 Datos Solicitud`/`SCA2_cargarSolicitud` (campo contacto; PUT propio con GET vivo) |
| Pólizas | NSE «recién emitidas» desde el PRINCIPIO | wAutemis «que derivan» libres o NSE desde el FINAL | NSE «recién emitidas» desde la MITAD |
| Informe | `r29-a-redireccion-verti-tarjetas.md` | `r29-b-argumentos-dos-tablas-documentos.md` | `r29-c-contacto-paralelo.md` |

## Estado (cada sesión añade una línea al empezar/terminar)
- R29-B (sesión https://mapfre.devinenterprise.com/sessions/16462ce826d4426fab0de5f2d80caccb) EMPEZADA 23/10 10:45 UTC — en edición: `SCA2_ContraAnulacionArgumentarioEstrategicas`, `SCA2_AccionesAdministrativasDocumentacion` (ojo de documentos de la CA; no está en otra columna). Pólizas wAutemis libres a 10:50 y reservadas: 0005726681408 (SCA2), 0005726682856 (SCA), 0005726681221 (reserva). Las otras 24 de la lista ya tienen solicitud.
- R29-C (sesión 78fd04db) EMPIEZA 23/10 ~10:50 UTC. Objetos en edición: PM `SCA2 CMD Mecanizar`, regla `SCA2_determinarContacto` (+ objetos nuevos de caché de contacto), campo nuevo `contacto`/`contactoFecha` en `SCA2 Datos Solicitud`.
