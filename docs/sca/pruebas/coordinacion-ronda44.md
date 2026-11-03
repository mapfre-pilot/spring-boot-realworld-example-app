# Coordinación ronda 44 — estados tras acciones administrativas y mecanización (8.º Análisis SCA2)

Origen: documento «Análisis SCA2» de los analistas (03/11). Una sola sesión hija (R44-A). Capturas del analista: `img/r44-analista-01.png` … `r44-analista-14.png` (en el orden del documento).

## Puntos del analista (literal, con su captura)
1. (01) «Este botón no se anula cuando le doy por primera vez. Qué pasa si le doy más veces.» → el botón debe quedar deshabilitado tras el primer clic y no lanzar dobles envíos.
2. (02) «CASO ACCIONES ADMINISTRATIVAS MARCANDO CHECK ANULACIÓN AL VENCIMIENTO. Cuando generamos una Acción Administrativa con VFERNA me pasa a VERTI. Cuando entiendo que no debería, pero como he pasado la anulación a vencimiento por eso puede que me salte a VERTI / Vencimiento. (Identificar la condición de lanzamiento de inducción a VERTI.) ¿Se lanza el servicio de contacto desde Acc Adm?»
3. (03-05) «Cuando finalizamos la solicitud en este caso. Se anula a vencimiento y NSE responde ok. Pero en la lista de solicitudes queda en este estado. La gestión de mecanización está incompleta. Pero el estado de la solicitud está finalizada negativa no requerida contra anulación. Pero en la anulación NSE ha finalizado con el resultado ok en el resultado de la anulación en la traza.»
4. (06-11) «El cliente no entrega documentación. Póliza Autos NSE: 2002100197362. Aplica tanto a pólizas de NSE Autos, como NSE Hogar como Autemis. Se lanza la anulación desde Acc Adm a vencimiento. Este estado no es correcto porque hemos ido por el flujo de anulación directa a pesar de haber ido por Acciones Administrativas. El resultado de la anulación directa es correcto. En mecanización de esta solicitud, de esta póliza tengo que el estado es incompleto pero la emisión se ha finalizado correctamente. La solicitud está finalizada correctamente. Pero en la lista de solicitudes no se está interpretando bien el estado.»
5. (12-14) «Prueba entregar documentos que llevan a anulación a Vencimiento. Comprobamos que va a vencimiento. Se queda el estado como incompleta cuando se ha anulado a Vencimiento.»
6. Regla: «La condición para el estado de mecanización pendiente de autorizar o anulado, es que en los controles técnicos de mecanizar el sistema indica que necesita autorización o no: si necesita autorización se lanzará el flujo de autorización y quedará pendiente de autorizar; si no necesita autorización se lanza la anulación directa y se queda el estado como mecanización finalizada.»

## R44-A — objetos propios
Acciones administrativas (`SCA2_AccionesAdministrativasPrincipal`, `…Documentacion`), mecanización (`SCA2_MecanizacionPrincipal`, PMs `SCA2 CMD Mecanizar`, `SCA2 CMD MecanizarNSE`, `SCA2 CMD CompletarAccion`, `SCA2 CMD Decidir`, `SCA2 CMD CrearAccion`, `SCA2 CMD Finalizar`), reglas SCA2 de estado de solicitud/gestión (`SCA2_textoEstadoSolicitud` y las del buscador/lista de solicitudes y de las tarjetas del detalle), condición de Verti/Vencimiento y constantes nuevas `SCA2_*`.
Los PMs de la ronda 42 están encadenados y con subprocesos síncronos: conservarlo (mismo `activityChained`/`IsSynchronous`).

## Pólizas
- `2002100197362` (del analista): solo consulta de sus solicitudes/trazas para entender el caso; no crear solicitudes nuevas con ella.
- Altas nuevas: `polizas/bloque-R44-A.txt` (2001-2400), anotando cada una en `polizas/REGISTRO.md` con «R44-A». Hacen falta NSE Autos, NSE Hogar y wAutemis. No usar 0732400126663.

## Reglas
- Solo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD. No tocar solicitudes antiguas.
- Lectura viva → backup JSON → cambio mínimo → relectura y comparación (PMs nodo a nodo). Literales de negocio en constantes. Paridad con SCA (cómo resuelve SCA estos estados y la condición de Verti).

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| IF `SCA2_AltaSolicitudPage` (v49→v50) | R44-A | modificado: ACEPTAR deshabilitado tras el primer clic |
| PM `SCA2 CMD Mecanizar` (nodo 331 «¿Inducir Verti?») | R44-A | modificado: no induce VERTI/Vencimiento si viene de Acc. Adm. |
| PM `SCA2 CMD Finalizar` (nodo nuevo 14) | R44-A | modificado: actualiza mecanización NSE a ANULACIÓN REALIZADA |
| ER `SCA2_actualizarMecanizacionAnulacionNse` | R44-A | nuevo |
| ER `SCA2_vieneDeAccionAdministrativa` | R44-A | nuevo |
| Constantes `SCA2_TXT_COD_EST_MECANIZACION_ANULADA`, `SCA2_TXT_EST_GESTION_INCOMPLETA`, `SCA2_TXT_ACCION_GESTION_MECANIZACION`, `SCA2_TXT_ACCION_GESTION_ACCADM` | R44-A | nuevas |
