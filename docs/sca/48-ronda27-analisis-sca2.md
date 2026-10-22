# Ronda 27 — tercer «Análisis SCA2» del analista (22/10/2026): clasificación y reparto

Documento del analista: «Analisis SCA2.docx» (22/10). Contiene resultados de sus pruebas y nuevas peticiones. Clasificación:

| # | Punto del analista | Resultado / qué hay que hacer | Quién |
|---|---|---|---|
| 1 | Pruebas Motivo, detalle y causa | Sin incidencia reportada. | — |
| 2 | Cabecera comparar datos SCA–SCA2: **pestaña por defecto «Datos póliza»** (hoy «Datos cliente») en todas las interfaces con cabecera | Cambio en `SCA2_DatosCabecera` (y llamadores). | R27-A |
| 3 | Contra Anulación positiva (póliza 2729367576) | OK, sin incidencia. | — |
| 4 | TTQ Autos 2002400344113: 18 tréboles aplicados, visibles en cabecera; segunda solicitud ya no ofrece el argumento TTQ | **OK** (validado por el analista). | — |
| 5 | TTQ Hogar 0732400152193 (solicitud 15788262): validaciones 1, 2 y 4 | **OK** (17 TTQ añadidos; argumento oculto en la solicitud siguiente). | — |
| 6 | CA negativa con salto a SI24 (0002729346658): **«Tarda mucho en decidir»** («Procesando la decisión de la solicitud…») | Medir y localizar la causa (motor / CORE / sondeo); corregir sólo si es propio de SCA2. | R27-B |
| 7 | Mensaje al consultar desde Oficina una solicitud en SI24: «Esta solicitud la está gestionando SI24 (texto provisional, pendiente del analista)» | **Texto aceptado** → dejar «Esta solicitud la está gestionando SI24». | R27-A |
| 8 | Botón **REASIGNAR** en la CA de nivel 2 (SISANS): ¿tiene sentido? SCA no lo tiene; explicar motivo, recomendar y, si se mantiene, colocarlo como el resto de botones | Explicación + recomendación para el analista; recolocar RETOMAR/REASIGNAR (no quitar sin decisión). Relacionado con la duda #10 (RETOMAR por cualquier usuario del grupo) ya cerrada. | R27-A |
| 9 | **Orden de argumentos** en la CA de nivel 2: ejecutados en CA anteriores (alfabético) → separador → argumentos de la nueva CA en el orden del servicio | Cambio en `SCA2_ContraAnulacionOpciones` (grid de argumentos). | R27-B |
| 10 | Datos en tarjeta Impresión | **OK**. | — |
| 11 | Esquema de orquestación SCA: Alta → decidir acción → CA negativa → decidir mecanizar → mecanizar → decidir contacto (Verti/Vencimiento) → CMP Inducir Cliente → decidir acción (nivel 2 / fin). «A ver si ya orquesta bien la parte de enlazar las interfaces desde mecanizar hasta componente de inducción a VERTI» | Reconstruir la orquestación real de SCA2, compararla con SCA y el esquema, corregir divergencias claras (p. ej. «decidir acción» tras el CMP). Continúa la ronda 26 (doc 47). | R27-C |

Reparto de objetos y pólizas: `pruebas/coordinacion-ronda27.md`. Informes: `pruebas/r27-a-cabecera-si24-reasignar.md`, `pruebas/r27-b-argumentos-nivel2-decision.md`, `pruebas/r27-c-orquestacion-mecanizar-cmp.md`.
