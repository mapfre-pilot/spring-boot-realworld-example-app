# Tarificador Vida Ahorro (TVA) — documentación de análisis

Documentación resultante del análisis **de solo lectura** de la aplicación Appian
**Tarificador Vida Ahorro** (prefijo `TVA`) en el entorno `mapfrespain-dev.appiancloud.com`.

| Dato | Valor |
|---|---|
| Aplicación | Tarificador Vida Ahorro |
| Descripción (Appian) | Aplicación del proyecto Tarificador Vida Ahorro |
| Prefijo | `TVA` |
| UUID | `e922a3b8-7bb8-4c61-b926-e4ee365b75fc` |
| Entorno analizado | Appian DEV (`mapfrespain-dev`) |
| Método | Inventario y lectura de definiciones vía MCP Appian (`list*` / `get*`, sin modificaciones) |
| Fecha | 2026-09-21 |

## Índice

1. [Visión general y funcionalidad](01-vision-general.md)
2. [Arquitectura y flujos](02-arquitectura-y-flujos.md)
3. [Inventario de objetos](03-inventario.md)
4. [Integraciones y sistemas conectados](04-integraciones.md)
5. [Dependencias externas (otras aplicaciones Appian)](05-dependencias.md)
6. [Seguridad, grupos y sites](06-seguridad.md)
7. [Hallazgos y propuestas de mejora](07-mejoras.md)
8. [Limitaciones del análisis](08-limitaciones.md)
9. [Plan de migración a Angular Material + backend](09-plan-migracion-angular.md)

## Resumen ejecutivo

TVA es un **tarificador/contratador de seguros de Vida Ahorro y Rentas** embebido en el
Portal Financiero de Mapfre. No es una aplicación Appian "clásica" basada en records y
tareas: es una **aplicación de flujo guiado (wizard) sin estado en Appian**, cuyo estado
completo (`TVA_Sesion`) se serializa en JSON y se persiste en una tabla de trazas en una
base de datos Aurora PostgreSQL. La pantalla que se muestra la decide el campo
`idPantallaActual` de la sesión, y cada botón lanza un modelo de proceso corto que
invoca servicios REST de **API Life** (SBC) y actualiza la sesión.

Tres modos de funcionamiento conviven en la misma aplicación:

- **VA — Venta Asesorada** de productos de ahorro (con test de idoneidad).
- **VIA — Venta Informada** de productos de ahorro (con test de conveniencia).
- **VIR / R2C — Rentas** (simulador y contratación de rentas).

Puntos clave:

- 172 reglas de expresión, 96 interfaces, 28 modelos de proceso, 20 integraciones,
  4 sistemas conectados, 2 Web APIs, 2 sites, 209 constantes, 11 grupos.
- Fuerte dependencia de tres aplicaciones compartidas: **MU** (Minsait Utilities),
  **VIDA** (Comunes Vida) y **CMP** (Componentes): 151 objetos externos referenciados.
- Toda la lógica de negocio real (tarificación, emisión, documentación, firma) reside en
  **API Life**; TVA es la capa de captura, validación y orquestación.
- Se han detectado varias oportunidades de mejora (ver [07-mejoras.md](07-mejoras.md)),
  entre ellas una regla que devuelve valores tipo credencial hardcodeados por entorno,
  ~50 reglas `MOCK`/`prueba` desplegadas junto al código productivo, y un volumen alto
  de código comentado.
