# R54 — SCA2: enlace en «Fecha solicitud anulación» de la cabecera (Appian TEST)

Fecha: 18/11/2026. Entorno: Appian TEST (`mapfrespain-test`). Solo objetos SCA2. Sin SQL.

## Duda del analista
«De la póliza 0002729355511 no puedo ver la solicitud ya que en la cabecera no hay enlace en fecha de solicitud anulación» (solicitud 15789203, alta wAutemis de R52b).

## Causa
En SCA, `SCA_SolicitudAnulación` v7 pone un `a!dynamicLink` en la fecha cuando CORE (`consultarCabecera`) devuelve `fecSolicitudAnul`; el enlace abre `SCA_ModalFechaSolicitudAnulacion` (histórico de gestiones de la solicitud, `consultaGestion`).
`SCA2_SolicitudAnulacion` conservaba el estilo de enlace (ACCENT + subrayado) pero no tenía `link` desde la v1: el port no trajo el modal. No depende de la póliza ni del estado de la solicitud.

Datos de 15789203 en CORE (TEST, 18/11): `fecSolicitudAnul` 17/11/2026 23:26:47, estado 9; `consultaGestion` devuelve 2 gestiones (Alta Solicitud FINALIZADA y Contra Anulación INCOMPLETA, ambas JJGONZ2).

## Cambios
| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_ModalFechaSolicitudAnulacion` (`_a-0000f0b4-5b71-8000-9d56-011c48011c48_5758083`) | nuevo v1 | Copia de `SCA_ModalFechaSolicitudAnulacion` v7 con `rule!SCA2_consultaGestion` y `cons!SCA2_VAL_COLOR_ROJO`; en la app SCA2 y carpeta `SCA2 Rules and Constants` |
| `SCA2_SolicitudAnulacion` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20064988`) | v13 → **v14** | `local!showFechaAnulacion`; la fecha lleva `a!dynamicLink` cuando CORE devuelve `fecSolicitudAnul` (misma condición que SCA) y abre el modal en el sitio de la tarjeta, como SCA; ACEPTAR vuelve a la cabecera |

Consumidores de `SCA2_SolicitudAnulacion`: `SCA2_DetalleSolicitud` y `SCA2_MilestoneMasDatosAltaSolicitud_Estrategicas` (sin cambios). Copias: `backups-r54/`.

## Pruebas (MCP TEST)
| # | Prueba | Resultado |
|---|---|---|
| 1 | `testInterface` `SCA2_ModalFechaSolicitudAnulacion` (15789203) | OK: «Gestión de la solicitud de anulación Num. 15789203», 2 filas (Alta Solicitud / Contra Anulación) |
| 2 | `testInterface` `SCA2_SolicitudAnulacion` v14 (15789203) | OK: «17/11/2026» con `link` (dynamicLink), sin errores |

Pendiente: probar el clic en el site con un usuario funcional.
