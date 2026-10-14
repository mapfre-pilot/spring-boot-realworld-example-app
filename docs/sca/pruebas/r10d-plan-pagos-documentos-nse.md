# R10-D — Plan de pagos, Acción Administrativa con documentos y autorización/rechazo por NSE

Sesión hija R10-D de la ronda 10 (`27-plan-ronda10.md`, coordinación `coordinacion-ronda10.md`). Entorno Appian TEST; SCA es la referencia funcional y SCA2 la reimplementación. Pólizas: sección R10-D de `polizas-ronda10.md` (plan de pagos), de arriba abajo. Fecha: 2026-10-14.

## 1. Resumen

(pendiente de completar al cerrar las pruebas de UI)

## 2. Análisis previo por LCP (sin UI)

### 2.1 Plan de pagos: qué hacen SCA y SCA2 con él

Búsqueda en todos los objetos `SCA_*` / `SCA2_*` (interfaces y reglas) de referencias a plan de pagos (`PlanPago`, `planPago`, «plan de pago»):

| Objeto | SCA | SCA2 | Uso |
|---|---|---|---|
| `*_consultarPlanPagoPorPoliza` | `_a-0000eb9b-717e-8000-9c54-011c48011c48_12082664` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050942` | Servicio GESYCORE `consultarPlanPagoPorPoliza`; misma expresión (sólo cambia el prefijo) |
| `*_obtenerDatosCabecera` | — | — | Rellena `datosPoliza.planPago` con `idnplanpago` del servicio (p. ej. `P1024692P25`) |
| `*_DatosPoliza` (cabecera «Datos póliza») | — | — | Muestra «Plan de pago: <id>» y un enlace (`cons!*_PLANPAGO_URL`) que abre el modal |
| `*_ModalPlanPago` | `_a-0000ec31-13b0-8000-9c78-011c48011c48_14024890` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053035` | Modal «Plan de pagos» / «Detalle del plan de pagos»: N. de pólizas, Importe, Periodicidad, Fecha Inicio, Plan de pago, Día de cobro, Cobro, Detalle de cobro, botón ACEPTAR. Diferencia entre ambos: sólo prefijos `SCA_`→`SCA2_` (16 líneas) |
| Pantallas de Mecanización / Autorización (`SCA_DetalleAnulacionMecanizacion`, `SCA_DetalleAnulacionAutorizacion`, `SCA_ContraAnulacionDetalleAnulacionPoliza`, `SCA2_MecanizacionPrincipal`, `SCA2_DetalleSolicitud`, `SCA2_PopUpMensajeAutorizacion`…) | sin referencias | sin referencias | **Ninguna de las dos aplicaciones tiene aviso ni bloqueo por plan de pagos** al mecanizar o autorizar |

Conclusión: el caso `manual_test_2-14` («el sistema advierte que no es posible seguir adelante mientras la póliza esté dentro de un plan de pagos») **no está implementado en SCA TEST**; SCA2 se comporta igual que SCA (sólo informativo en la cabecera). Se mantiene como **pendiente de decisión** (ya abierto en `22-dudas-funcionales-para-el-analista.md`).

Pólizas R10-D comprobadas con `SCA2_consultarPlanPagoPorPoliza` (y `SCA_consultarPlanPagoPorPoliza` en la primera, misma respuesta):

| Póliza | Plan de pagos (`idnplanpago`) |
|---|---|
| 2002500188047 | P1024692P25 (codplanpago 5, gestor DT) |
| 0731600003780 | **sin plan** (respuesta vacía) → descartada |
| 2002400061669 | M071059P23 |
| 0730580045025 | P054378P18 |
| 2002400046024 | P866798P24 |
| 2002400319124 | P914104P24 |

### 2.2 Históricos NSE y documentos (sólo consulta, LCP `test`)

| Solicitud | Póliza | Causa CORE | Gestiones CORE (`SCA2_consultaGestion`) | Documentos CORE (`SCA2_consultarDocumentos`) |
|---|---|---|---|---|
| 15787945 (autorizada en NSE por el analista) | 2002100194827 | 14 «NO VOY A COMPRARME OTRO COCHE» (venta del vehículo), codEstSolicitud 5 | 8 FINALIZADA · 3 FINALIZADA · 5 INCOMPLETA («RESPUESTA SUSCRIPCION NSE: Num Solicitud Anulacion 2002642G0000066»). **No hay gestión 7**: la autorización de NSE no ha llegado a CORE | sólo tipo 7 (DNI) |
| 15787950 (rechazada en NSE) | 2002300361333 | 16 «BAJA VEHICULO», codEstSolicitud 5 | 8 · 3 · 5 INCOMPLETA (NSE 2002642G0000067) · **7 «AUTORIZACION RECHAZADA»** de APP-PCAE 12:13:30 «Actualizacion desde NSE». `SCA2_consultarAutorizacion` para la gestión 7: `codEstado` **null**, `mcaAutorizada` N | tipo 3 + tipo 7 |
| 15787966 (venta sin traspaso) | 2002300361241 | 14, codEstSolicitud 5 | 8 · 3 · 5 INCOMPLETA | sólo tipo 7 (DNI) |

Estado calculado con las gestiones reales de CORE:

| Solicitud | `SCA_calcularEstadoSolicitud` | `SCA2_calcularEstadoSolicitud` (v2, HU3980, PADRE) |
|---|---|---|
| 15787945 | Solicitud Pendiente | Solicitud Pendiente |
| 15787950 | **Solicitud Pendiente** | **Solicitud Finalizada. Rechazada anulación** |
| 15787966 | Solicitud Pendiente | Solicitud Pendiente |

La diferencia en 15787950 es deliberada (HU3980, objeto reservado por el PADRE): SCA no interpreta la gestión 7 «AUTORIZACION RECHAZADA» en el listado y sigue mostrando «Solicitud Pendiente»; SCA2 la refleja. En la tarjeta Autorización del Detalle, SCA (`SCA_DetalleAnulacionAutorizacion`) toma el estado de `consultarAutorizacion.codEstado`, que en este rechazo viene vacío; el PADRE corrigió `SCA2_DetalleSolicitud` (v54) para usar `codEstGestion` de la gestión 7 en ese caso.

## 3. Pruebas de UI (SCA frente a SCA2)

(pendiente: resultados del testing agent)

## 4. Objetos Appian modificados por R10-D

Ninguno hasta el momento.

## 5. Hallazgos externos (CORE / NSE / Emisión / Documentum)

- 15787945: autorizada en NSE según el analista, pero CORE no tiene gestión 7 ni cambio de estado → la respuesta de NSE no ha llegado a CORE (no es SCA2).
- 15787950: CORE registra la gestión 7 «AUTORIZACION RECHAZADA» pero `consultarAutorizacion` devuelve `codEstado` vacío → el estado de autorización sólo se puede deducir de la gestión.

## 6. Preguntas para el analista

(pendiente)
