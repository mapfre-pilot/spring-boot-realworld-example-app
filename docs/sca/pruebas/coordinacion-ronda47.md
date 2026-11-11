# Coordinación ronda 47 — 11.º «Análisis SCA2» (10/11/2026)

Origen: respuestas del analista a `../63-dudas-analista-pendientes.md` (rectificación duda 25 y pólizas TTQ NO CLUB). Herramienta: MCP de Appian TEST (`appian-dev-mcp-c90b`, plugin 26.9.15); alternativa Deployment API v2.

## Sesiones
| Sesión | Alcance | Estado |
|---|---|---|
| R47-A | Vida «MALA GESTIÓN» en el desplegable de detalle del alta (duda 25, rectificada) y tréboles TTQ con clientes NO CLUB (pólizas 0732400122931 y 0731700076776). Informe `r47-a-vida-mala-gestion-ttq.md` | TERMINADA (`SCA2_AltaSolicitudPage` v52→v53; TTQ sin cambios) |
| R47-B | Optimizaciones sin cambio funcional: paralelismo de la cabecera y vigilancia de procesos ACTIVE >1 h / archivado PM. Informe `r47-b-optimizaciones-sin-cambio-funcional.md` | TERMINADA (`SCA2_CuadroMando` v25→v28; cabecera sin cambios) |
| R47-C | RECARGAR ARGUMENTO no refresca el argumento TTQ CLUB / NO CLUB tras dar de alta al cliente en Club; pruebas pendientes de R46-D/R47-A con las pólizas TTQ del analista. Informe `r47-c-ttq-recargar-argumento.md` | EN CURSO |

## Objetos en edición
| Objeto | Sesión | Estado | Versión |
|---|---|---|---|
| IF `SCA2_AltaSolicitudPage` (detalle MALA GESTIÓN en Vida) | R47-A | LIBERADO | v52→v53 |
| IF `SCA2_CuadroMando` (aviso de procesos/tareas en espera >1 h) | R47-B | LIBERADO | v25→v28 |

## Reglas
- Solo objetos SCA2. Nunca PRO. No tocar solicitudes/instancias históricas. No desactivar/activar la aplicación (variable CORE compartida con SCA).
- Protocolo: `git pull` → reservar aquí (commit+push) → leer vivo → backup → cambio mínimo → importar → reexportar y comparar → liberar con vN→vM.
