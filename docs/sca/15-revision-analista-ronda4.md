# Revisión del analista — ronda 4 (SCA2 TEST)

Documento de entrada: `Analisis_SCA2.docx` (versión 4). Puntos nuevos respecto a la ronda 3 y su resolución.

| # | Punto del analista | Diagnóstico | Resolución | Prueba |
|---|---|---|---|---|
| 1 | Consulta de solicitudes, póliza 2002200566837: espacio entre la flecha de volver y «póliza - nombre - NIF» | La cabecera de SCA2 es un port literal de `SCA_DatosCabecera` / `SCA_DatosCabecera_Estrategicas` (columna de flecha sin ancho + columna `MEDIUM_PLUS`, `showDividers`). Medido en pantalla en la solicitud 15787766: el hueco es de 34 px CSS en SCA y en SCA2 (diferencia 0 px) | Sin cambios: es el comportamiento de SCA. Si se quiere eliminar, habría que cambiarlo en ambas aplicaciones | UI, misma ventana y resolución (informe 09) |
| 2 | Anulación tras CA negativa (2002300601539): al ACEPTAR el aviso «Se va a redirigir a la anulación» vuelve al buscador | `SCA2_CMD_CompletarAccion` arranca `Decidir` de forma asíncrona, así que la tarea MECANIZAR se crea unos segundos después del cierre. Si se pulsaba ACEPTAR antes, la rama sin tarea volvía al buscador. Esta es la hipótesis principal: el caso 15787770 no se pudo cronometrar | `SCA2_DetalleTareas` v18: con CA negativa y sin tarea MECANIZAR todavía, ACEPTAR queda deshabilitado y se muestra «Preparando la pantalla de anulación…». Se habilita en cuanto aparece la tarea (refresco de 30 s) y abre la mecanización. Ya no vuelve al buscador en ese caso | UI 15787772: deshabilitado 22,3 s; ACEPTAR abre NSE-Autos |
| 3 | Los motivo/detalle/causa del alta deben traducirse a NEW (cía 1) / NSE (cía 41) antes de anular | SCA traduce al pulsar ANULAR (`SCA_obtenerTraduccionMotivosSca` por cía+ramo, relleno a 8 dígitos) y pasa el CDT traducido a `ANL Alta` → `ANL Aceptar`. SCA2 reconstruía el CDT desde sus records con los códigos PCA sin traducir (`1/1/1`) | Nueva regla `SCA2_construirSolicitudAnulacionAnlTraducida` (`_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5501155`). Traduce con `SCA2_obtenerTraduccionMotivosSca`, rellena a 8 dígitos y, si falta algún dato o la traducción, conserva los códigos originales. `SCA2_CMD_Mecanizar` nodo `ANL Alta` (solo el input `solicitudAnulacion`) usa la regla nueva | LCP 15787761/15787764/15787770 → `00000001/00000001/00000002`; UI+backend 15787772: fila ANL única 2086 con esos códigos y `SCA2 Error` vacío |

## Pendiente

- **Cierre posterior a ANL**: en 15787772, CORE ya muestra la mecanización como «Anulación realizada» (suplemento 9). Sin embargo, en la fila ANL 2086 siguen vacíos `ESTADO` y `DESBLOQUEO_ANULACION`, y el registro SCA2 sigue en `MECANIZADA / ANL / PENDIENTE`. SCA espera el mensaje `ANL_Desbloquear` (nodo «Pausar hasta ANL_Desbloquear»), mientras que SCA2 consulta esos campos cada 5 minutos, con un máximo de 288 intentos. Falta confirmar con ANL qué proceso rellena esos campos o envía el mensaje.
- **Pólizas en PRRA**: SCA sustituye los códigos por `00000013/00000008/00000021` antes de ANL. SCA2 no detecta todavía PRRA en el alta (punto 3 del resumen de alta para el analista).
- **Compañía 1 (wAutemis)**: la traducción no se ha probado con una solicitud SCA2 real de esa compañía, porque no hay ninguna en TEST.

## Objetos modificados (SCA2 TEST)

- `SCA2_construirSolicitudAnulacionAnlTraducida`: nueva, v1.
- `SCA2_CMD_Mecanizar` (`0000f06f-4cfc-8000-66d3-7f0000014e7a`): nodo 301, input `solicitudAnulacion`.
- `SCA2_DetalleTareas` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554`): v17 → v18.

Pruebas UI: `pruebas/09-ronda4-informe-testing-agent.md`.
