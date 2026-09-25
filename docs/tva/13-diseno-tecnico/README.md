# Diseño técnico por feature — TVA (rama `feature/tva`)

Documentos de diseño de cada bloque funcional de la migración Appian →
Django + Angular, siguiendo la plantilla *Design: <Feature>*.

Cada documento describe el enfoque técnico, las decisiones de arquitectura
tomadas (con alternativas descartadas), el flujo de datos extremo a extremo,
los ficheros implicados y los contratos públicos reales del código.

## Índice

| # | Feature | Fichero |
|---|---------|---------|
| 00 | Arquitectura de referencia (Clean Architecture) | [00-arquitectura-referencia-frontend.md](00-arquitectura-referencia-frontend.md) |
| 01 | Autenticación y stubs corporativos | [01-autenticacion-y-stubs.md](01-autenticacion-y-stubs.md) |
| 02 | Inicio y contrato Web API | [02-inicio-y-contrato-web-api.md](02-inicio-y-contrato-web-api.md) |
| 03 | Modelo de sesión TVA | [03-modelo-de-sesion-tva.md](03-modelo-de-sesion-tva.md) |
| 04 | Navegación y máquina de pantallas | [04-navegacion-y-maquina-de-pantallas.md](04-navegacion-y-maquina-de-pantallas.md) |
| 05 | Botonera y avisos | [05-botonera-y-avisos.md](05-botonera-y-avisos.md) |
| 06 | Selección de producto y catálogos | [06-seleccion-producto-y-catalogos.md](06-seleccion-producto-y-catalogos.md) |
| 07 | Captura del tomador | [07-captura-tomador.md](07-captura-tomador.md) |
| 08 | Captura de la solicitud | [08-captura-solicitud.md](08-captura-solicitud.md) |
| 09 | Rentas (R2C) | [09-rentas-r2c.md](09-rentas-r2c.md) |
| 10 | Resumen, firma y fin | [10-resumen-firma-y-fin.md](10-resumen-firma-y-fin.md) |
| 11 | Administración | [11-administracion.md](11-administracion.md) |
| 12 | Integraciones mock y conectores | [12-integraciones-mock-y-conectores.md](12-integraciones-mock-y-conectores.md) |
| 13 | Observabilidad y trazas | [13-observabilidad-y-trazas.md](13-observabilidad-y-trazas.md) |
| 14 | Pop-ups Appian Embedded | [14-popups-appian-embedded.md](14-popups-appian-embedded.md) |

Referencias cruzadas: [12-gap-analysis-appian-angular.md](../12-gap-analysis-appian-angular.md)
(especificación §12.* citada en cada documento) y
[11-guia-despliegue.md](../11-guia-despliegue.md) (operación).
