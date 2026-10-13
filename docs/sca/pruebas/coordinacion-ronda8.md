# Coordinación ronda 8 (sesiones H1–H6 en paralelo sobre SCA2 TEST)

Fichero compartido en `feature/sca`. **Protocolo obligatorio** para las 6 sesiones:

1. **Antes de modificar cualquier objeto Appian de SCA2** (interfaz, regla, PM, constante, record type…): `git pull --rebase origin feature/sca`, lee este fichero, añade una fila en «Objetos en edición» con tu sesión, el objeto (nombre + uuid), el motivo y la hora UTC, haz commit (`coord(ronda8): Hx reserva <objeto>`) y push. Si el push falla por conflicto, rebasa y vuelve a leer: si otra sesión ya reservó ese objeto, **no lo toques**: espera a que su fila pase a «liberado» (vuelve a hacer pull cada pocos minutos) y entonces haz tu `GET` vivo y tu cambio sobre la versión ya modificada.
2. Tras publicar (PUT + readback OK), actualiza tu fila a `liberado (vN → vM)` con un resumen de una línea del cambio, commit y push. Nunca dejes un objeto reservado más de 60 minutos.
3. Siempre `GET` del objeto vivo justo antes del `PUT` (aunque esté reservado por ti): otra sesión puede haber publicado en el intervalo. Si el readback no coincide con lo esperado, no vuelvas a hacer PUT: anota incidencia aquí.
4. **Datos**: cada sesión usa SOLO sus pólizas (reparto abajo) y las solicitudes que crea con ellas; las solicitudes históricas (15787858–15787869 y anteriores) son de sólo lectura, excepto 15787868 (H5). Los argumentos/conceptos/valores de prueba se nombran `PRUEBA_DEVIN_Hx_*` y se eliminan al terminar.
5. **Aplicación SCA2**: nadie la desactiva (casos «Desactivar aplicación» de H6) hasta que las otras 5 sesiones hayan marcado «TERMINADA» en la tabla de estado. **SCA nunca se desactiva ni se modifica.**
6. **Informes**: cada sesión escribe sólo su fichero `docs/sca/pruebas/hX-*.md` y este fichero; no edites los informes de otras sesiones.
7. Si descubres un fallo de SCA2 que afecta a otras sesiones (p. ej. el alta deja de funcionar, la bandeja de errores se llena con un comando común), anótalo en «Incidencias» con hora y objeto, antes de corregirlo.

## Reparto

| Sesión | Plan | Pólizas normales | Pólizas RCI | Informe |
|---|---|---|---|---|
| H1 | Alta (`manual_test`, 39 casos SCA) | 0000428646610, 0001047016997, 0001047017003 | 0005726674055 | h1-plan-alta-identificacion-validaciones.md |
| H2 | Alta (`manual_test_2`, 34 casos) | 0001047017007, 0001047017008, 0001047017009 | 0005726678312 | h2-plan-alta-formulario-navegacion.md |
| H3 | Contra Anular (35) + Argumentos (12) | 0001047017010, 0001047017019, 0001047017039 | 0005726680285, 0005726679137 | h3-plan-contra-anular-argumentos.md |
| H4 | Mecanización (10) + Autorización (14) | 0001047017040, 0001047017054, 0001047017061 | 0005726677758, 0005726680401 | h4-plan-mecanizacion-autorizacion.md |
| H5 | Acciones Administrativas (15) | 0001047017063, 0001047017066 (+ solicitud 15787868) | 0005726679775, 0005726681055 | h5-plan-acciones-administrativas.md |
| H6 | Buscador (13) + Detalle (17) + Gestión aplicación (10) + Conceptos (4) | 0001047017068, 0001047017069 | 0005726685339 | h6-plan-buscador-detalle-mantenimiento.md |

Reserva RCI (pedir a la sesión padre antes de usar): 0005726681805 0005726681713 0005726682097 0005726681936 0005726681296 0005726681221 0005726682856 0005726681370 0005726681408 0005726682038 0005726684215 0005726684349 0005726685618 0005726683648 0005726685247 0005726683419 0005726689061 0005726688765

## Estado de las sesiones

| Sesión | Estado (EN CURSO / TERMINADA) | Hora UTC | Nota |
|---|---|---|---|
| H1 | EN CURSO | | |
| H2 | TERMINADA | 2026-10-13 13:40 | 34 casos: 10 OK igual, 0 divergencias, 24 NO PROBADO; sin objetos SCA2 modificados; solicitudes 15787880, 15787885, 15787894, 15787897. Informe h2-plan-alta-formulario-navegacion.md |
| H3 | EN CURSO | | |
| H4 | EN CURSO | | |
| H5 | TERMINADA | 2026-10-13 13:25 | Informe h5-plan-acciones-administrativas.md; objetos liberados (Principal v21, subirDocumentosGD v6) |
| H6 | EN CURSO | | |

## Objetos en edición

| Sesión | Objeto (nombre · uuid) | Motivo | Reservado (UTC) | Estado |
|---|---|---|---|---|
| H1 | SCA2_AltaSolicitudPage · _a-0000f069-4f37-8000-9cc8-011c48011c48_20055716 | Validación residual de fax al cambiar canal (caso manual_test-5); se comprobó después que SCA hace lo mismo | 2026-10-13 10:40 (antes de recibir el protocolo) | liberado (v25 → v27): cambio aplicado en v26 y REVERTIDO en v27 (expresión idéntica a v25); sin cambio neto |
| H6 | `SCA2_GestionMantenimientoMenu` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060073` | Gestión de conceptos: el menú pasaba literales (null/false) a `SCA2_GestionConceptosYClases`, los `a!save(ri!…)` fallaban | 2026-10-13 11:05 (publicado antes del protocolo) | liberado (v1 → v2): locals del menú pasados como en `SCA_GestionMantenimientoMenu` |
| H6 | `SCA2_BuscadorTabla` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | Paginación de «Últimas solicitudes» (sólo 10 filas, sin «siguiente») | 2026-10-13 12:40 (publicado antes del protocolo) | liberado (v8 → v10): input nuevo `totalCount`; con él construye un DataSubset para que el grid pagine en servidor |
| H6 | `SCA2_Buscador` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | Paginación de «Últimas solicitudes» | 2026-10-13 12:40 (publicado antes del protocolo) | liberado (v23 → v26): pasa `totalCount` del DataSubset a `SCA2_BuscadorTabla` (v24 descartada y revertida en v25) |
| H3 | `SCA2_cargarSolicitud` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054954` | Devolver `estado.contadorPosponer` (CMD Posponer escribía siempre 1) | 2026-10-13 10:40 (publicado antes de existir este protocolo) | liberado (v4 → v6): campo `contadorPosponer` añadido a `fields` y al mapa `estado`; readback OK |
| H3 | `SCA2_ContraAnulacionOpciones` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | RECARGAR ARGUMENTO vacía la tabla: pasar `body` de argumentos al hijo vía `local!data` | 2026-10-13 11:45 | liberado (v39 → v40) 12:05: `local!data` incluye `body: local!body`; readback y testInterface OK |
| H3 | `SCA2_ContraAnulacionCompaniaCatalogacion` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060061` | RECARGAR ARGUMENTO: usar el body del padre y guardar `listadoArgumentos` (no la respuesta completa) | 2026-10-13 11:45 | liberado (v3 → v4) 12:05: el botón recarga con `ri!data.body` (+ cía/catalogación/fecha actuales) y guarda `index(…, "listadoArgumentos", {})`; readback OK |
| H5 | `SCA2_AccionesAdministrativasPrincipal` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | FINALIZAR sin documentación / causa sin contrato: catalogación a vencimiento (paridad SCA) y observaciones al CANCELAR | 2026-10-13 11:05 | liberado (v20 → v21): FINALIZAR con «no entrega documentación» o causa que exige contrato sin tipo 9 → catalogación 2 a fecha de vencimiento (modificarCatalogacion, guardarAccAdm y CMD) + aviso SCA; CANCELAR inserta la observación en CORE |
| H5 | `SCA2_subirDocumentosGD` · `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351` | Subida de documentos AccAdm: tipo 9 (contrato sin traspaso) no se registra en CORE y deja CMD Posponer/CompletarAccion en error; paridad con SCA_calcularDocumentosASubir (tipos permitidos por acción) | 2026-10-13 11:20 | liberado (v5 → v6): sólo sube al SGD/CORE los tipos previstos por acción (ACCADM 1-5,7; CA 6,7; AUT 7,8) como SCA_calcularDocumentosASubir; el resto se omite con success=true |
| H3 | `SCA2_ContraAnulacionOpciones` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | CA-24: `local!nuuma` toma el NUUMA del record (creador) en vez del usuario logado → SISANS ve las oficinas de JJGONZ2 y la impresora activa | 2026-10-13 12:20 | liberado (v40 → v41) 12:25: `local!nuuma` = usuario logado con respaldo del record; readback y testInterface OK |
| H6 | `SCA2_Buscador` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | Validación de póliza inexistente al BUSCAR (SCA avisa «La póliza no es una póliza válida…» y conserva la tabla; SCA2 «No hay resultados») | 2026-10-13 13:35 | liberado (v26 → v27): validación de póliza al BUSCAR como SCA (`SCA2_pObtenerPolizaFecha` + tipo/ramo → mensaje y sin filtrar la tabla) |
| H6 | `SCA2_BuscadorTabla` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | Fila del buscador: causa / fecha solicitud / fecha resolución salen del record SCA2 y en SCA de CORE (`consultarUltimaGestion`), ya cargado en la tabla para Observaciones | 2026-10-13 14:30 | liberado (v10 → v11): Causa / Fecha solicitud / Fecha resolución de la fila salen de la fila CORE (`consultarUltimaGestion`, misma fuente que SCA); record SCA2 como respaldo |
| H4 | `SCA2_AnulacionFueraNormaPrincipal` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | FINALIZAR autorización: la fecha autorizada no se propaga al record `SCA2 Datos Solicitud` (mecanización muestra la fecha original; CORE sí la actualiza, SCA la lee de CORE) | 2026-10-13 11:20 | liberado (v20 → v21) 11:27: FINALIZAR añade `a!writeRecords` de `SCA2 Datos Solicitud.fecanulacion` = fecha autorizada (dd/mm/yyyy); readback y testInterface OK |
| H3 | `SCA2_GestionArgumentos` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053041` | GA-5/6/12: tras modificar un argumento, BUSCAR devuelve el resultado cacheado (SCA pasa `random: rand()` a la consulta) | 2026-10-13 13:50 | liberado (v1 → v2) 14:00: las 3 llamadas a `SCA2_consultarTipoArg` pasan `random: rand()`; readback y testInterface OK |
| H3 | `SCA2_consultarTipoArg` · `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052550` | Añadir input `random` (paridad `SCA_consultarTipoArg`) para romper la caché | 2026-10-13 13:50 | liberado (v1 → v2) 14:00: input `random` (Number Decimal) añadido, expresión sin cambios |

## Incidencias

| Hora UTC | Sesión | Qué ha pasado | Afecta a |
|---|---|---|---|
| 2026-10-13 10:44 | H4 | CANCELAR en Revisión autorización (SCA2 15787895): CORE `guardarAutorizacion` (codEstado 5 / mcaAutorizada N) devuelve SOAP fault 4007 «error en el acceso a la base de datos» también con la regla `SCA_guardarAutorizacion` → fallo del servicio CORE, no de SCA2; el CMD CompletarAccion queda en `SCA2 Error` (AUT_GUARDAR_FAIL, relanzamiento automático) y la solicitud sigue Pendiente | Quien cancele autorizaciones (H4); bandeja de errores |
| 2026-10-13 13:20 | H5 | `SCA2_MecanizacionPrincipal` muestra «Fecha anulación póliza» = fecha del alta (copia local `datosSolicitud.fecanulacion`), no la vigente en CORE (cabecera `fecAnulacion`) tras una Acción Administrativa que cambia la catalogación a vencimiento (15787884: 13/10/2026 vs 19/05/2027; 15787898: 13/10/2026 vs 24/01/2028). No tocado por H5 | H4 (Mecanización) |
| 2026-10-13 13:20 | H5 | Bandeja `/errores`: 15787868 tiene 2 errores DOC_GD_FAIL (CMD Posponer 12:18, CMD CompletarAccion 12:22) por el documento tipo 9; causa corregida en `SCA2_subirDocumentosGD` v6. Falta relanzar «SCA2 CMD CompletarAccion» desde la bandeja (sólo administradores) | Administrador / sesión padre |
