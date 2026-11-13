# Ronda 23 — Pólizas PRE del analista, página de mantenimiento ANL y salto a nivel 2 (20/10/2026)

> Estado: EN CURSO (pruebas E2E con 15788148). Workspace: `~/sca2work/r23/` (NOTAS.md, backups, PMs SCA/ANL exportados, `derivan_check.txt`).

## 1. Entrada
- `SCA2PolizasPRE.ods` (2ª versión): **wAutemis que derivan de nivel** (59 pólizas 0005726…), **wAutemis «a efecto»** (0000253500…, 0001047017…, 0002729392…, 0007051071…) y **pólizas con solicitud pendiente en SCA (M021)**. El analista avisa de que no todas cumplen la casuística.
- «Revisar la pantalla nueva de autorizar/rechazar/cancelar: los procesos de anulaciones no se están ejecutando bien».

## 2. Hallazgos

### R23-1 Tras mecanizar, SCA2 vuelve a preguntar al motor; SCA finaliza
- 15788140 / 15788143 (0000253500327/334, creadas por el analista): Verti previa → Mecanización → Emisión `00000004` (anulación directa) → `CMD Mecanizar` escribe «IR A NIVEL 2» → `CrearAccion` → Decidir → **Contra Anulación nivel 2** pendiente.
- SCA («SCA Finalizar Mecanización» `0002eebd-9493…`, «SCA Mecanizacion» `0002ec01-57f1…`) termina en «SCA Finalizar Solicitud»; no vuelve a preguntar al motor. HU3980 tiene la etiqueta «Póliza Anulada. Solicitud Pendiente Nivel 2», así que **no se cambia sin confirmación** (§4).

### R23-2 Página de mantenimiento: parámetros correctos; el PM ANL de los casos SCA2 se paraba en NEW
- `SCA2_MantenimientoPendientesAutorizar` lanza `ANL Desbloquear` con los mismos parámetros que la Web API.
- Trazas `ANL Integracion`/`ANL Evento Anulacion` de 2137 (15788103), 2139 (15788105), 2141 (15788111), 2101 (15787878): ANL actualiza la fila, alta SGO/STCAT OK y en «Desbloquear Poliza en Central» NEW responde **500 `M555 … error al actualizar en BD la autorizacion/rechazo de una operacion pendiente de PCA`** → el PM acaba sin «Anular Poliza NEW» ni «Cierre SGO y STCAT». SCA2 reanudaba su mecanización sólo por leer el ESTADO de la fila.
- Causa: NEW no tenía la operación pendiente porque el bloqueo de SCA2 (`CMD Mecanizar` nodo 340) fallaba con `4004` hasta la ronda 22. Verificación con caso nuevo: §3.
- Bug de ANL (informativo): el evento se registra como 7 «Error Obtener Detalle Solicitud» porque `success_consulta` nunca se asigna en «ANL OSS DesbloquearPolizaEnCentral»; el error real es el 15.

### R23-3 ANL Alta de 15788140: NEW `M518` reserva de prima
- `registrarOpeAnulPolizaEnCentral` → 500 «Para realizar reserva de primas la fecha de anulación no puede ser al efecto ni al vencimiento». `mcaReservaPrima=S` sale de NEW (`consultarAnulacionPoliza.confirReserva`) y SCA (`SCA_ContraAnulacionDetalleAnulacionPoliza`) hace lo mismo (S, si falla N). No es divergencia; dato/NEW PRE.

### R23-4 Salto a nivel 2: `CORE_ALTA_GESTION` «error en el acceso a la base de datos» (15788148)
- 0005726681713 («deriva») tras CA negativa → NIVEL 2 (motor `NO_MECANIZAR`); el alta en CORE fallaba porque `SCA2_altaGestionCore` v6 (R22) mezclaba perfil de usuario `CE_RM` con subperfil de grupo `CE_MF_BK_EXPERTOSI24`.
- SCA («SCA Contra Anulación» nodo 16, «SCA Alta Contra Anulacion» nodo 3) envía siempre `datosPerfilesPca` (nivel 2: `CE_MF_BK`/`CE_MF_BK_EXPERTOSI24` + nuuma del gestor; remap `CE_MF_SI24_EXPERTO→CE_MF_SI24`). **`SCA2_altaGestionCore` v6→v7** replica eso. Relanzamiento de 15788148 OK (tarea nivel 2 creada).
- **`SCA2_DetalleSolicitud` v57→v58→v59**: en nivel > 1 la tarjeta muestra el nuuma de quien retoma (Tarea de la propia tarjeta) o «-», no el de CORE (que es el gestor del nivel anterior); v59 lo mantiene en las gestiones ya finalizadas.
- Diferencia abierta: SCA crea la gestión de nivel 2 en CORE al abrir/retomar (popup → `SCA_PM_ALTA_CONTRA_ANULACION`); SCA2 al crear la tarea.

## 3. Pruebas (detalle en `pruebas/r23-pruebas.md`)
- «A efecto» 0000253500327/334 → `00000004` (no pendientes). Las 5 primeras «derivan» tienen solicitud en SCA; sin solicitud previa: 0005726681713, 0005726682097, 0005726681936, 0005726681296, 0005726681221 (más en `derivan_check.txt`).
- 15788148: alta → CA negativa → Verti previa → NIVEL 2 → error (R23-4) → v7 → relanzado → CA nivel 2 (SISANS retoma y finaliza negativa) → 2ª Verti previa → motor `NO_MECANIZAR` → nivel 3 → FIN → FINALIZADA 17:35. **Nivel 2 validado**; esta vía no mecaniza.
- Caso pendiente de autorizar: la vía que lo produce es AA por venta del vehículo (motivo 1/detalle 5/causa 14, como 15788111) → Mecanización → `00000005`. Prueba C con 15788149 / 0005726682097.
- Hallazgo adicional: tras la CA negativa de nivel 2 SCA2 vuelve a mostrar la pantalla Verti previa aunque el motor no mecanice (coherente con «decisión de contacto tras CA negativa»); confirmar con el analista si debe mostrarse en cada nivel.

## 4. Preguntas al analista
1. Tras mecanizar con anulación directa (`00000004`), ¿finalizar como SCA o volver a preguntar al motor (hoy: CA nivel 2)?
2. ¿Gestión de nivel 2 en CORE al crear la tarea (SCA2) o al retomar (SCA)?
