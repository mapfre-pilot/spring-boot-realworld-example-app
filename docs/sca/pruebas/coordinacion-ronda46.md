# Coordinación ronda 46 — 10.º «Análisis SCA2» (10/11/2026)

Origen: documento de los analistas «Analisis SCA2.docx» (respuestas a `../63-dudas-analista-pendientes.md`). Herramienta: MCP de Appian TEST (`appian-dev-mcp-c90b`, plugin 26.9.15); alternativa Deployment API v2.

## Sesiones
| Sesión | Alcance | Estado |
|---|---|---|
| R46-B | ANL, NSE, NEW y mecanización: «Cancelada» (explicación), wAutemis 916 en pantalla, excepción de exceso de tiempo, nivel NEW (confirmación), espera NSE 5 min/30 s, catalogación MAS MOVIL, notación 4/5 + 2/7, rechazo NSE → mecanización 4, catalogación final NSE. Informe `r46-b-anl-nse-new.md` | EN CURSO |
| R46-A | Detalle (nivel, bloque Inducción Verti/vencimiento), etiquetas de estado, filtro Estado, combinaciones fuera de tabla, ACEPTAR Vida, clave Vida | EN CURSO |
| R46-C | Alta, Si24/Verti, detalle y mensajes: aviso Si24 central/CCC, FINALIZAR sin carta (perfiles SCA), N5 error CMP agente, N6 Verti nivel 2, CONSULTAR SOLICITUD, mensaje fecha anterior a efecto, enlace NSE &n=&o=, lógica Vida (explicación), COMPROBAR AHORA/respaldo/cerca del vencimiento, retorno al formulario (doc 44). Informe `r46-c-alta-si24-detalle.md` | EN CURSO |
| R46-D | Argumentario (RECARGAR), enhorabuena/tréboles, entrega parcial Club/TTQ, observaciones >999, catálogo Aurora tras mantener argumentos, observaciones SVA/reserva de prima, columna `POLIZA_FECHAULTIMOSINIESTRO`. Informe `r46-d-argumentario-treboles.md` | TERMINADA |

## Objetos en edición
| Objeto | Sesión | Estado | Versión |
|---|---|---|---|
| IF `SCA2_DetalleSolicitud` | R46-A | LIBERADO | v73 → v74 |
| ER `SCA2_calcularEstadoSolicitud` | R46-A | LIBERADO | v6 → v7 |
| IF `SCA2_BuscadorTabla` (filtro Estado) | R46-A | LIBERADO sin cambios | v18 (sin cambios) |
| IF `SCA2_ContraAnulacionOpciones` (aviso Si24, FINALIZAR sin carta) | R46-C | RESERVADO | v70 → ? |
| IF `SCA2_AltaSolicitudAnulacionPopUp` (CONSULTAR SOLICITUD) | R46-C | RESERVADO | v11 → ? |
| ER `SCA2_erroresGuardarSolicitud` (mensaje fecha anterior a efecto) | R46-C | RESERVADO | v2 → ? |
| IF `SCA2_DetalleSolicitud` (enlace NSE, Verti nivel 2) | R46-C | RESERVADO | v74 → ? |
| ER `SCA2_puedeGestionarTarea` (Verti nivel 2) | R46-C | RESERVADO | v6 → ? |
| ER `SCA2_simularAnulacion` (wAutemis 916 bloquea el alta) | R46-B | LIBERADO | v17 → v18 |
| PM `SCA2 CMD Finalizar` (espera 30 s y error de exceso de tiempo) | R46-B | RESERVADO | — |
| CONST `SCA2_VAL_ESPERA_NSE_FINALIZAR_MAX_INTENTOS` (10 × 30 s) | R46-B | LIBERADO sin cambios (10 consultas × 30 s = 5 min) | v1 (sin cambios) |
| IF `SCA2_AltaSolicitudPage` (catalogación propuesta por el servicio) | R46-B | LIBERADO | v51 → v52 |
| PM `SCA2 CMD Mecanizar` (rechazo ANL → mecanización 4) | R46-B | RESERVADO | — |
| IF `SCA2_ContraAnulacionOpciones` (catalogación final NSE) | R46-B | EN ESPERA (reservado por R46-C) | v70 → ? |
| IF `SCA2_ContraAnulacionCompaniaCatalogacion` (RECARGAR) | R46-D | LIBERADO | v7 → v8 |
| IF `SCA2_ContraAnulacionSGO` (pantalla tréboles) | R46-D | LIBERADO | v4 → v5 |
| IF `SCA2_ContraAnulacionOpciones` (dataRecuperacion) | R46-D | LIBERADO — **aviso a R46-C:** R46-D guardó v72 sobre v70 sin ver la reserva de R46-C y pisó su v71; v73 = v71 de R46-C (aviso Si24/FINALIZAR sin carta, verificado por diff) + campo `aplicarTreboles` de `local!dataRecuperacion` (2 líneas). Si R46-C guarda desde su copia local, que conserve ese campo | v70 → v72 (error) → v73; v73 → v74 (R46-D: `local!SVADisponibles` sin el `index(…, "sva")` duplicado, el desplegable SVA fallaba; 1 bloque, sobre v73 vivo). R46-C/R46-B: partid de v74 |
| IF `SCA2_ContraAnulacionModalRecuperacionPoliza` (enhorabuena) | R46-D | LIBERADO | v15 → v16 |
| IF `SCA2_BandejaErrores` / `SCA2_DetalleErrores` (relanzar TTQ) | R46-D | LIBERADO | v12 → v13 / v6 → v7 |
| IF `SCA2_AltaGestionArgumento` (recarga Aurora) | R46-D | LIBERADO | v8 → v9 |
| RT `SCA2 Datos Cabecera` (`POLIZA_FECHAULTIMOSINIESTRO`) | R46-D | LIBERADO sin efecto (DDL bloqueado) | v11 → v12 (columna sigue VARCHAR(255)) |
| CONS `SCA2_TXT_OBS_RESERVA_PRIMA_APLICADA` (nueva) | R46-D | LIBERADO | v1 (nueva) |

## Reglas
- Solo objetos SCA2. Nunca PRO. No tocar solicitudes/instancias históricas. No desactivar/activar la aplicación (variable CORE compartida con SCA).
- Protocolo: reservar aquí (commit+push) → leer vivo → backup → cambio mínimo → importar → reexportar y comparar → liberar con vN→vM.
