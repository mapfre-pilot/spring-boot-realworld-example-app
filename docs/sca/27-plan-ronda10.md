# Plan ronda 10 — pólizas telemáticas, corredor, campañas y plan de pagos + HU3978/HU3980 + Análisis SCA2 (14/10/2026)

Entradas del analista: `PolizasPruebaPRE.xlsx` (columnas nuevas: telemáticas, corredor, campañas TTQ/PREMFIDE/RETOS/SVA, plan de pagos; PRRA vacía), `AF04-HU3978 Estados de Solicitud y Mecanización`, `AF04-HU3980 Listado de solicitudes por NUUMA` y `Analisis SCA2.docx` (pruebas del 14/10 con NSE y documentos).

## Reparto

| Sesión | Alcance | Planes (filtrar casos por palabra clave) | Pólizas |
|---|---|---|---|
| R10-A | Alta + Contra Anulación con pólizas **telemáticas** (canal telemático: preguntas de contacto, impresión, DUE, salto SI24) | `planes/alta.md` (telem*), `planes/contra-anular-v2.md` (telem*) | `polizas-ronda10.md` §R10-A |
| R10-B | Alta + Contra Anulación con pólizas de **corredor** (productor corredor: catalogación, oficinas, avisos, flujo nivel) | `planes/alta.md` (corredor), `planes/contra-anular-v2.md` (corredor) | §R10-B |
| R10-C | Contra Anulación con pólizas de **campañas TTQ / PREMFIDE / RETOS / SVA** (argumentario de campaña, gestionarTTQ, avisos de campaña) | `planes/contra-anular-v2.md` (TTQ, PREMFIDE, RETOS, SVA, campaña) | §R10-C |
| R10-D | Mecanización/Autorización con **plan de pagos**; Acción Administrativa «venta con/sin traspaso» con documentos y autorización/rechazo por **NSE** (Analisis SCA2 14/10) | `planes/revision-autorizacion.md` (plan de pagos), `planes/acciones-administrativas.md` (venta, documentos), `planes/pruebas-de-mecanizacion.md` | §R10-D |
| PADRE | Etiquetas/colores del listado por NUUMA según HU3980 (estado solicitud + estado mecanización + gestión); reflejo en el Detalle de la actualización NSE (gestión 7 «Actualizacion desde NSE»); documento de venta que no llega al gestor documental; consolidado | — | reserva |

Casos ya cubiertos en rondas 8/9 no se repiten; cada sesión compara SCA (`/suite/sites/sca-site`) y SCA2 (`/suite/sites/sca2`) con la misma póliza/escenario, corrige solo divergencias propias de SCA2 y documenta lo externo (CORE, Emisión, ANL, NSE, Documentum, PRE).
