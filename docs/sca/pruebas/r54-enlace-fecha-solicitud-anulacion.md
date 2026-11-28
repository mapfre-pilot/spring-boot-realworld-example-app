# R54 — SCA2: enlace en «Fecha solicitud anulación» de la cabecera (Appian TEST)

Fecha: 18/11/2026. Solo objetos SCA2, sin SQL. El informe omite identificadores y copias completas de los objetos.

## Causa

En SCA, `SCA_SolicitudAnulación` v7 pone un `a!dynamicLink` en la fecha si CORE devuelve `fecSolicitudAnul`. El enlace abre `SCA_ModalFechaSolicitudAnulacion`, que muestra el histórico de gestiones. En SCA2 se conservaba el estilo de enlace (ACCENT y subrayado), pero faltaban el enlace y el modal desde la primera versión.

## Cambios

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_ModalFechaSolicitudAnulacion` | v1 | Porta el modal de SCA v7 a SCA2: usa `SCA2_consultaGestion` y `SCA2_VAL_COLOR_ROJO`. |
| `SCA2_SolicitudAnulacion` | v13 → v14 | Si CORE devuelve `fecSolicitudAnul`, el enlace pone `local!showFechaAnulacion` a verdadero y muestra el modal en lugar de la tarjeta. ACEPTAR vuelve a la cabecera. |

No se cambiaron los consumidores `SCA2_DetalleSolicitud` ni `SCA2_MilestoneMasDatosAltaSolicitud_Estrategicas`.

## Pruebas en TEST

| Caso | Resultado registrado |
|---|---|
| `testInterface`: modal y solicitud con fecha de CORE | La fecha incluye un enlace y el modal muestra dos gestiones: Alta Solicitud y Contra Anulación. |
| `testInterface`: solicitud pendiente sin fecha de CORE | Sin enlace y sin errores. |
| Site: Detalle → Solicitud Anulación | El enlace abre el histórico y ACEPTAR vuelve a la tarjeta. |
| Site: Buscador → Detalle → Cabecera → Más Datos → Solicitud Anulación | El enlace abre el mismo histórico y ACEPTAR vuelve a la cabecera expandida. |
| Site: Errores → Ver solicitud, dos casos sin fecha de CORE | La fecha local conserva el estilo rojo subrayado, pero el clic no tiene efecto; no hubo errores de expresión. |

Sin probar en el site: `SCA2_DatosCabecera_Estrategicas`, que solo aparece en tareas y usa la misma `SCA2_SolicitudAnulacion`.
