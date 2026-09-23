# T13 — mapeo estado interno SCA2 → literal SCA (tag buscador)

| Estados SCA2 (estadoSolicitud/procesoActivo) | Literal SCA | Color tag |
|---|---|---|
| EN_ACCION, EN_PROCESO, PENDIENTE, PDTE, PDTE_FINALIZAR, POSPUESTA, MECANIZAR | Solicitud Pendiente | #E46B15 naranja |
| PENDIENTE_AUTORIZACION, PDTE_AUTORIZACION | Solicitud pendiente de autorización | #E46B15 |
| PENDIENTE_AUTORIZACION_ANULACION, AUTORIZACION | Solicitud Pendiente de autorización de anulación | #E46B15 |
| MECANIZADA | Mecanización Enviada | #E46B15 |
| FINALIZADA, FINALIZADA_ANULADA | Finalizada. Anulación realizada | #0D82BD azul |
| FINALIZADA_POSITIVA, FINALIZADA_POSITIVO | Finalizada positivo | #008C47 verde |
| FINALIZADA_SIN_ANULAR | Solicitud finalizada sin anular | #BE0F0F rojo |
| FINALIZADA_NO_REQUERIDA, FINALIZADA_NO_REQUERIDA_CA | Finalizada no requerida contraanulación | #BE0F0F |
| RECHAZADA, ERROR, ERROR_DECISION | Finalizada. Rechazada anulación | #BE0F0F |
| CANCELADA | Cancelada | #9F9F9F gris |
| CADUCADA | Caducada | #9F9F9F |
| CADUCADA_NEGATIVA | Caducada negativa | #734B30 marrón |
| (sin match) | valor crudo | cons!SCA2_VAL_COLOR_GRIS_MEDIO |

Reglas: `SCA2_textoEstadoSolicitud` (texto) + `SCA2_colorEstadoSolicitud` (color,
ya existente con los hex SCA; sin cambios). En SCA el texto lo calcula
`SCA_calcularEstadoSolicitud(estadoSolicitud, datosGestiones)` — el parámetro
`datosGestiones` (consultaGestion por solicitud) no existe con esa forma en SCA2
y SCA2 persiste el estado de negocio directamente, por lo que el mapping es
estático por código.
