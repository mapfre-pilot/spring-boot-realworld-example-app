# Ronda 10 — Consolidado (telemáticas, corredor, campañas, plan de pagos, HU3978/HU3980 y Analisis SCA2)

> Estado: EN CURSO. Se completa cuando terminen R10-A/B/C/D. Plan: `27-plan-ronda10.md`; reparto: `pruebas/polizas-ronda10.md`; coordinación: `pruebas/coordinacion-ronda10.md`.

## 1. Materiales de entrada
- Excel `PolizasPruebaPRE.xlsx` (pestañas telemáticas 20 únicas, corredor 187, campañas 33, plan de pagos 134; PRRA vacía; RCI, Más Móvil y Vida ya usadas en rondas anteriores).
- HU3978 (estados de solicitud y de mecanización) y HU3980 (etiquetas y colores del listado por NUUMA).
- `Analisis SCA2.docx`: documentos de venta en AA (15787945, 15787966) y actualización desde NSE no reflejada en el Detalle (15787950).

## 2. Trabajo del PADRE (hecho)
Ver `pruebas/r10-padre-hu3980-nse-documentos.md`.

| Punto | Resultado | Objetos SCA2 (versión) |
|---|---|---|
| HU3980 etiquetas/colores del buscador | Implementado y probado (LCP + UI). SCA TEST no implementa HU3980: ahí la referencia es el PDF. | calcularEstadoSolicitud 1→2, textoEstadoSolicitud 13→14, colorEstadoSolicitud 6→7, BuscadorTabla 11→12 |
| Detalle no reflejaba el rechazo NSE (15787950) | Corregido: tarjeta Autorización «Autorizacion Rechazada» (rojo) + «Actualizacion desde NSE», como SCA («Rechazada»). | DetalleSolicitud 52→54 |
| Documentos de venta en AA sólo DNI (15787945/15787966) | Misma regla que SCA (`calcularDocumentosASubir` idénticas): no es divergencia de SCA2. Pendiente caso nuevo de R10-D y decisión funcional (tipo 1 / tipo 9; CORE rechaza el tipo 9). | sin cambios |

## 3. Resultados de las sesiones (pendiente)
| Sesión | Informe | OK | Corregidas | Pendientes decisión | No probados |
|---|---|---|---|---|---|
| R10-A Telemáticas | `pruebas/r10a-telematicas.md` | OK 5 · corregidas 0 (hallazgo alta Hogar NSE corregido por el PADRE, anexo A del informe del padre: `SCA2_construirContextoAlta` v11, solicitud 15788005) · texto distinto 1 (mensaje de solicitud abierta) · decisión 1 (pregunta «¿insiste?» para SI24) · no comparables por SCA 2 (decisora SCA TEST 403) · sin datos 3 (todas las telemáticas del Excel son NSE; 5 vigentes) |
| R10-B Corredor | `pruebas/r10b-corredor.md` | | | | |
| R10-C Campañas | `pruebas/r10c-campanas.md` | | | | |
| R10-D Plan de pagos / AA documentos / NSE | `pruebas/r10d-plan-pagos-documentos-nse.md` | OK 5 · corregidas 0 · decisión 1 (plan de pagos: ni SCA ni SCA2 avisan/bloquean) · tipo 9 «compraventa sin traspaso» no llega a CORE en ninguna app (diseño heredado de SCA; tipo 1, 3 y 7 sí) · NSE: autorización positiva de 15787945 nunca llegó a CORE (externo) · no probados 3 (recorridos SCA por latencia) · solicitudes nuevas 15787977/78, 15787986/92, 15787996/98 |

## 4. Divergencias corregidas en SCA2 (pendiente de consolidar)

## 5. Diferencias externas / no reproducibles (pendiente)

## 6. Preguntas para el analista
1. **HU3980-1**: solicitud finalizada en CORE (estado 5) con mecanización `INCOMPLETA` porque NSE no respondió (15787945): ¿«Solicitud Pendiente», «Pendiente de Autorización» o «Solicitud Finalizada sin anular»? CORE no informa el estado de mecanización «pendiente de autorizar».
2. **HU3980-2**: ¿se actualizará SCA TEST con las etiquetas HU3980? Hasta entonces no hay comparación literal SCA/SCA2 en el buscador.
3. **NSE-1**: texto de la tarjeta de Autorización tras rechazo NSE: SCA «Rechazada» vs SCA2 «Autorizacion Rechazada» (CORE no devuelve `codEstado`). ¿Cuál se quiere?
4. **DOC-1**: en AA por venta del vehículo, ¿qué documentos deben llegar a CORE/gestor documental (DNI, contrato tipo 1, tipo 9 sin traspaso)? Hoy ninguna de las dos aplicaciones sube más que el DNI y CORE rechaza el tipo 9.

## 7. Cambios Appian de la ronda (se completa al cerrar)
Ver tabla de reservas en `pruebas/coordinacion-ronda10.md`.
