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
| H2 | EN CURSO | | |
| H3 | EN CURSO | | |
| H4 | EN CURSO | | |
| H5 | EN CURSO | | |
| H6 | EN CURSO | | |

## Objetos en edición

| Sesión | Objeto (nombre · uuid) | Motivo | Reservado (UTC) | Estado |
|---|---|---|---|---|

## Incidencias

| Hora UTC | Sesión | Qué ha pasado | Afecta a |
|---|---|---|---|
