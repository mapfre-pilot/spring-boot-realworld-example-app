# Coordinación ronda 46 — 10.º «Análisis SCA2» (10/11/2026)

Origen: documento de los analistas «Analisis SCA2.docx» (respuestas a `../63-dudas-analista-pendientes.md`). Herramienta: MCP de Appian TEST (`appian-dev-mcp-c90b`, plugin 26.9.15); alternativa Deployment API v2.

## Sesiones
| Sesión | Alcance | Estado |
|---|---|---|
| R46-B | ANL, NSE, NEW y mecanización: «Cancelada» (explicación), wAutemis 916 en pantalla, excepción de exceso de tiempo, nivel NEW (confirmación), espera NSE 5 min/30 s, catalogación MAS MOVIL, notación 4/5 + 2/7, rechazo NSE → mecanización 4, catalogación final NSE. Informe `r46-b-anl-nse-new.md` | EN CURSO |
| R46-A | Detalle (nivel, bloque Inducción Verti/vencimiento), etiquetas de estado, filtro Estado, combinaciones fuera de tabla, ACEPTAR Vida, clave Vida | EN CURSO |
| R46-D | Argumentario (RECARGAR), enhorabuena/tréboles, entrega parcial Club/TTQ, observaciones >999, catálogo Aurora tras mantener argumentos, observaciones SVA/reserva de prima, columna `POLIZA_FECHAULTIMOSINIESTRO` | EN CURSO |

## Objetos en edición
| Objeto | Sesión | Estado | Versión |
|---|---|---|---|
| IF `SCA2_DetalleSolicitud` | R46-A | LIBERADO | v73 → v74 |
| ER `SCA2_calcularEstadoSolicitud` | R46-A | LIBERADO | v6 → v7 |
| IF `SCA2_BuscadorTabla` (filtro Estado) | R46-A | LIBERADO sin cambios | v18 (sin cambios) |

## Reglas
- Solo objetos SCA2. Nunca PRO. No tocar solicitudes/instancias históricas. No desactivar/activar la aplicación (variable CORE compartida con SCA).
- Protocolo: reservar aquí (commit+push) → leer vivo → backup → cambio mínimo → importar → reexportar y comparar → liberar con vN→vM.
