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
| # | Origen | Qué pasaba en SCA2 | Corrección | Objeto / versión | Prueba |
|---|---|---|---|---|---|
| 1 | PADRE (HU3980) | Etiquetas/colores del buscador con textos internos antiguos | Tarjetas y colores según HU3980 (SCA TEST sigue con los textos antiguos; referencia = PDF) | `SCA2_calcularEstadoSolicitud` v2, `SCA2_textoEstadoSolicitud` v14, `SCA2_colorEstadoSolicitud` v7, `SCA2_BuscadorTabla` v12 | LCP + UI buscador |
| 2 | PADRE (Análisis SCA2) | Rechazo de autorización desde NSE no se veía en el Detalle (15787950) | Si `consultarAutorizacion` no da `codEstado`, se lee la gestión 7 de CORE → «Autorizacion Rechazada» en rojo con «Actualizacion desde NSE» | `SCA2_DetalleSolicitud` v54 | UI Detalle 15787950 (SCA y SCA2 iguales) |
| 3 | R10-A → PADRE | Alta de pólizas **Hogar NSE** volvía al formulario sin solicitud ni error (0732000028208) | `datosPolizaHogar` vacío hacía fallar `SCA2_PreGenerarStudAnul` en el PM de alta; ahora se rellena (calificación, fecha nacimiento, oficina comercial) como en Autos | `SCA2_construirContextoAlta` v11 | LCP (Hogar/Autos NSE y wAutemis) + UI: solicitud 15788005 → AA |

## 5. Diferencias externas / no reproducibles (pendiente)
- **SCA TEST**: la decisora del motor no ejecutó en las altas de SCA (15787971/76/84: «Aún procesando» >5 min → 403); el GUARDAR de la Contra Anulación se queda procesando y la flecha «volver» de la cabecera da error de evaluación (`sca_datoscabecera`). Impide comparar en SCA las decisiones del motor y los recorridos completos (R10-A, R10-D).
- **NSE → CORE**: la autorización positiva de 15787945 hecha en NSE nunca llegó a CORE (sigue INCOMPLETA, sin gestión 7); el rechazo de 15787950 sí llegó. Ninguna app puede mostrar lo que CORE no tiene.
- **CORE**: `consultarAutorizacion` devuelve `codEstado` vacío en el rechazo NSE; el estado se deduce de la gestión 7.
- **Documentos tipo 9** («compraventa sin traspaso»): no se registran en CORE en ninguna app (misma regla de documentos en SCA y SCA2; CORE rechaza el tipo); tipos 1, 3 y 7 sí llegan. Sin error en bandeja.
- **Datos de prueba**: las 20 telemáticas del Excel son NSE anonimizadas (5 vigentes sin solicitud); no hay telemáticas wAutemis, de corredor ni Ford/Bankia. Plan de pagos: sólo cabecera informativa en ambas apps.
- **Permisos**: la bandeja de errores de SCA2 no es visible para el perfil Oficina (JJGONZ2).

## 6. Preguntas para el analista
1. **HU3980-1**: solicitud finalizada en CORE (estado 5) con mecanización `INCOMPLETA` porque NSE no respondió (15787945): ¿«Solicitud Pendiente», «Pendiente de Autorización» o «Solicitud Finalizada sin anular»? CORE no informa el estado de mecanización «pendiente de autorizar».
2. **HU3980-2**: ¿se actualizará SCA TEST con las etiquetas HU3980? Hasta entonces no hay comparación literal SCA/SCA2 en el buscador.
3. **NSE-1**: texto de la tarjeta de Autorización tras rechazo NSE: SCA «Rechazada» vs SCA2 «Autorizacion Rechazada» (CORE no devuelve `codEstado`). ¿Cuál se quiere?
4. **DOC-1**: en AA por venta del vehículo, el «Documento compra/venta sin traspaso del seguro» (tipo 9) no queda en CORE en ninguna de las dos aplicaciones (sólo DNI y contrato con traspaso). ¿Debe conservarse en CORE/gestor documental? ¿Debe avisar la pantalla a la oficina?
5. **DOC-2**: con el contrato de compraventa **con traspaso** adjunto, ambas apps avisan «Al no adjuntar la documentación requerida, la póliza se anulará al vencimiento» (sólo el «sin traspaso» cuenta como documentación completa). ¿Es correcto?
6. **PLAN-1** (R10-D): ni SCA ni SCA2 avisan ni bloquean cuando la póliza está en un plan de pagos (sólo cabecera + detalle del plan). El plan de pruebas espera un aviso al finalizar la autorización («sacar la póliza del plan»). ¿Aviso o bloqueo, y en qué pantalla?
7. **TEL-1** (R10-A): la pregunta «¿El cliente insiste en que se anule su póliza por este canal?» la ve en SCA SI24 y Gestión Especial; en SCA2 (decisión ronda 9) sólo CCC/CCR. ¿Se confirma que SI24 no debe verla? ¿Debe preguntarse también en el alta cuando deriva a AA (casos 23/24 del plan)?
8. **TEL-2** (R10-A): mensaje de solicitud abierta: SCA «La póliza ya tiene una solicitud abierta en Appian»; SCA2 texto largo con instrucciones (esperar, no generar nueva, añadir documentos en NSE/SGO). ¿Cuál se mantiene?
9. **TEL-3** (R10-A): póliza telemática gestionada por Oficina → SCA2 la deja en Contra Anulación nivel 1 de la misma oficina, sin salto a SI24. ¿Es lo esperado o debe saltar a SI24/Expertos por ser telemática?
10. **NSE-2** (R10-D): autorización NSE de 15787945 que no llegó a CORE: ¿quién revisa el canal NSE→CORE? Mientras, ¿qué debe mostrar SCA2 (hoy «Mecanización Incompleta» / «Solicitud Finalizada sin anular»)?

## 7. Cambios Appian de la ronda (se completa al cerrar)
Ver tabla de reservas en `pruebas/coordinacion-ronda10.md`.
