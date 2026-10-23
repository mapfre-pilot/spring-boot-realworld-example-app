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

## Resultados de la ronda 27 (22/10, tres sesiones hijas; informes en `pruebas/r27-*.md`)

| # | Punto | Resultado | Objetos SCA2 (versión) | Pregunta abierta |
|---|---|---|---|---|
| 2 | Pestaña por defecto «Datos póliza» | **Aplicado y verificado** (alta, CA nivel 1/2, Detalle; Verti/AA/Autorización usan la misma cabecera). SCA sigue en «Datos cliente». Solicitud 15788291. | `SCA2_AltaSolicitudPage` v39, `SCA2_DetalleSolicitud` v64, `SCA2_MilestoneMasDatosAltaSolicitud` v5, `…_Estrategicas` v5 | — |
| 7 | Texto SI24 definitivo | **Aplicado**: «Esta solicitud la está gestionando SI24». | `SCA2_DetalleSolicitud` v64 | ¿Texto definitivo también para el mensaje provisional de `SCA2_AnulacionFueraNormaPrincipal` (error al cancelar autorización CORE)? ¿Mostrar el aviso también si Oficina abre la CA nivel 1 con la solicitud ya en nivel 2? |
| 8 | REASIGNAR nivel 2 | RETOMAR/REASIGNAR **recolocados** (misma fila, derecha, estilo botón). REASIGNAR en SCA2 sólo asigna la tarea al propio usuario (= RETOMAR); SCA no muestra ninguno a SI24 en nivel 2. **No quitado**. | `SCA2_DetalleSolicitud` v64 | ¿Quitar REASIGNAR (recomendación) o dejarlo sólo a administradores con selector de usuario? |
| 9 | Orden de argumentos nivel 2 | **Aplicado**: anteriores alfabético → fila separadora no seleccionable → nuevos en orden del servicio; Orden 1..n; selección/paginación conservadas. Verificado 15788293 (SCA 15788294 sigue mezclado). | `SCA2_ContraAnulacionOpciones` v58, `SCA2_ContraAnulacionArgumentarioEstrategicas` v4 | ¿OK texto del separador y numeración? ¿El separador no debe contar en la paginación? |
| 6 | «Tarda mucho en decidir» | **Medido, no corregido**: SCA2 38 s backend (CompletarAccion → Decidir → CrearAccion nivel → Decidir → CrearAccion; dos ciclos del motor + CORE) + sondeo ≤30 s ≈ 55-70 s; SCA ~20 s backend / 25-45 s UI. Sin espera artificial. | — | ¿Se acepta, botón ACTUALIZAR junto al mensaje, o revisar la doble llamada al motor (lógica de decisión)? |
| 11 | Orquestación Mecanizar → contacto → CMP → decidir acción | **Paridad**: componente completo (incl. firma RGPD) encadenado dentro del site en SCA2 y SCA; después el motor decide CA nivel 2 (SCA2 24 s, SCA 5 min). Corregido el orden: guardarMecanizacion → alta ANL → CMP → espera ANL. Solicitudes 15788292 (SCA2) / 15788295 (SCA). | PM `SCA2 CMD Mecanizar` (conexiones 6→8, 300→331, 301→331, 331→324, 333→324) | **D4**: la primera pantalla del CMP tras ANULAR PÓLIZA se abre sola en SCA y en SCA2 exige clic en «COMPLETAR INDUCCIÓN» (`a!startProcess` no sigue la cadena) — el usuario lo consulta con el analista. D2: tipoInduccion fijo «I» vs «V/A» con vencimiento SGC (#13). D5: canal «Te lo Juro» (OneTrust manuscrito) no encadenado en el propio CMP. |

Incidencias colaterales: tras ACEPTAR el alta SCA2 vuelve al formulario sin id (caso #9, propuesta doc 44 pendiente de OK); toast «El argumento no puede volver a ejecutarse» al rehacer un argumento negativo en CA nivel 1; «Actualizar datos» del Detalle muestra caché tras la decisión de nivel 2; página de errores no visible para JJGONZ2 (por diseño: administradores); SCA: error `a!submitLink` en `sca_datoscabecera` al volver del detalle abierto desde el buscador (no corregible desde SCA2). **15 de las 16 pólizas wAutemis «que derivan» ya tienen solicitud: hace falta hoja nueva.**
