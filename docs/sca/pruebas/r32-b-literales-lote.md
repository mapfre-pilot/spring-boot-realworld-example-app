# R32-B — Literales de negocio → constantes (lote B, 28 objetos SCA2)

Ronda 32 (origen: `docs/sca/54-ronda31-constantes-y-objetos-sin-uso-sca2.md`; reparto: `docs/sca/pruebas/coordinacion-ronda32.md`). Entorno Appian **TEST**, aplicación SCA2. Cambio funcional cero: cada literal se sustituye por la constante `cons!` con el mismo valor (creadas por R32-A, ver `r32-a-constantes-y-borrado.md`).

## Método

Para cada objeto: lectura viva (LCP) → copia de seguridad local → sustitución mínima (solo cadenas literales; comentarios y referencias de record intactos) → `/expressions/validate` antes y después (sin errores nuevos) → `PUT` con el `versionId` vivo → relectura y comparación con el resultado esperado (idéntico en los 28). Ningún objeto tenía cambios paralelos entre la copia y la escritura (versión de la copia = versión viva).

## Resultado por objeto

| Objeto | UUID | Tipo | Versión antes→después | Nº sustituciones | Literales sustituidos | Prueba |
|---|---|---|---|---|---|---|
| `SCA2_altaGestionCore` | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481118` | expression-rules | 7→8 | 9 | "CE_MF_SI24_EXPERTO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO`; "CE_MF_SI24"×1→`cons!SCA2_TXT_PERFIL_CE_MF_SI24`; "CE_RM"×1→`cons!SCA2_TXT_PERFIL_CE_RM`; "CE_RM_OFICINA"×1→`cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA`; "CONTRAANULAR"×1→`cons!SCA2_TXT_ACCION_CONTRAANULAR`; "CONTRA ANULAR"×1→`cons!SCA2_TXT_ACCION_CONTRA_ANULAR`; "ACCIONES ADMINISTRATIVAS"×1→`cons!SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS`; "AUTORIZACION"×1→`cons!SCA2_TXT_ACCION_AUTORIZACION`; "MECANIZAR"×1→`cons!SCA2_TXT_ACCION_MECANIZAR` | `/test` 40 casos, salida idéntica |
| `SCA2_AnulacionFueraNormaPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | interfaces | 23→24 | 6 | "#000000"×3→`cons!SCA2_VAL_COLOR_NEGRO`; "CE_MF_RECIBOS_CCC"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC`; "CE_MF_RECIBOS_CCR"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR`; "#FFFFFF"×1→`cons!SCA2_VAL_COLOR_BLANCO` | validate sin errores nuevos + UI |
| `SCA2_BuscadorTabla` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | interfaces | 14→15 | 6 | "#ffffff"×1→`cons!SCA2_VAL_COLOR_BLANCO`; "FINALIZADA"×1→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA`; "FINALIZADA_SIN_ANULAR"×1→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR`; "FINALIZADA_POSITIVO"×1→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO`; "CADUCADA"×1→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA`; "CADUCADA_NEGATIVA"×1→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA` | validate sin errores nuevos + UI |
| `SCA2_calculoMedioComunicacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052599` | expression-rules | 1→2 | 10 | "CE_MF_RECIBOS_CCR"×2→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR`; "CE_MF_RECIBOS_CCC"×2→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC`; "CE_RM"×1→`cons!SCA2_TXT_PERFIL_CE_RM`; "CE_RM_DT"×1→`cons!SCA2_TXT_PERFIL_CE_RM_DT`; "CE_MF_CENTRAL_AT"×1→`cons!SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT`; "CE_MF_SI24_FRONT"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT`; "CE_MF_SI24_EXPERTO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO`; "CE_MF_BK"×1→`cons!SCA2_TXT_PERFIL_CE_MF_BK` | `/test` 42 casos, salida idéntica |
| `SCA2_colorEstadoSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063676` | expression-rules | 8→9 | 24 | "#E46B15"×8→`cons!SCA2_VAL_COLOR_NARANJA_OSCURO`; "#9F9F9F"×6→`cons!SCA2_VAL_COLOR_GRIS_MEDIO`; "#BE0F0F"×6→`cons!SCA2_VAL_COLOR_ROJO_OSCURO`; "#008C47"×3→`cons!SCA2_VAL_COLOR_VERDE_OSCURO`; "#0D82BD"×1→`cons!SCA2_VAL_COLOR_AZUL` | `/test` 13 casos, salida idéntica |
| `SCA2_construirContextoAlta` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056014` | expression-rules | 12→13 | 2 | "CE_RM"×1→`cons!SCA2_TXT_PERFIL_CE_RM`; "CE_RM_OFICINA"×1→`cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` | `/test` 3 casos, salida idéntica |
| `SCA2_consultarDocumentos` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051626` | expression-rules | 1→2 | 1 | "QUERY_SCA_AGD_001"×1→`cons!SCA2_TXT_SGD_QUERY_ARGUMENTOS` | `/test` 3 casos, salida idéntica |
| `SCA2_consultarDocumentosREST` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051632` | expression-rules | 1→2 | 2 | "QUERY_SCA_AGD_001"×2→`cons!SCA2_TXT_SGD_QUERY_ARGUMENTOS` | `/test` 3 casos, salida idéntica |
| `SCA2_ContraAnulacionArgumentarioEstrategicas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060043` | interfaces | 5→6 | 10 | "QUERY_SCA_AGD_001"×2→`cons!SCA2_TXT_SGD_QUERY_ARGUMENTOS`; "DOCS_SCA_001"×2→`cons!SCA2_TXT_SGD_COD_DOCUMENTAL`; "#008C47"×2→`cons!SCA2_VAL_COLOR_VERDE_OSCURO`; "#ffffff"×4→`cons!SCA2_VAL_COLOR_BLANCO` | validate sin errores nuevos + UI |
| `SCA2_ContraAnulacionCompaniaCatalogacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060061` | interfaces | 5→6 | 1 | "#6495ED"×1→`cons!SCA2_VAL_COLOR_AZUL_CLARO` | validate sin errores nuevos + UI |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951` | interfaces | 9→10 | 1 | "CE_RM"×1→`cons!SCA2_TXT_PERFIL_CE_RM` | validate sin errores nuevos + UI |
| `SCA2_ContraAnulacionModalSiNo` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052807` | interfaces | 6→7 | 3 | "CE_MF_RECIBOS"×1→`cons!SCA2_TXT_PERFIL_CE_MF_RECIBOS`; "CE_MF_RECIBOS_CCC"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC`; "CE_MF_RECIBOS_CCR"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR` | validate sin errores nuevos + UI |
| `SCA2_ContraAnulacionOpciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056435` | interfaces | 58→59 | 24 | "FINALIZADA"×2→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA`; "CE_RM"×1→`cons!SCA2_TXT_PERFIL_CE_RM`; "CE_MF_RECIBOS"×1→`cons!SCA2_TXT_PERFIL_CE_MF_RECIBOS`; "CE_MF_RECIBOS_CCC"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC`; "CE_MF_RECIBOS_CCR"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR`; "#6495ED"×1→`cons!SCA2_VAL_COLOR_AZUL_CLARO`; "#000000"×7→`cons!SCA2_VAL_COLOR_NEGRO`; "#FFFFFF"×1→`cons!SCA2_VAL_COLOR_BLANCO`; "CA"×9→`cons!SCA2_TXT_TIPO_GESTION_CA` | validate sin errores nuevos + UI |
| `SCA2_ContraAnulacionRehabilitacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060049` | interfaces | 4→5 | 1 | "#6495ED"×1→`cons!SCA2_VAL_COLOR_AZUL_CLARO` | validate sin errores nuevos + UI |
| `SCA2_D_TiposGestiones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056349` | expression-rules | 2→3 | 4 | "AUTORIZACION"×1→`cons!SCA2_TXT_ACCION_AUTORIZACION`; "CONTRA ANULAR"×1→`cons!SCA2_TXT_ACCION_CONTRA_ANULAR`; "CONTRAANULAR"×1→`cons!SCA2_TXT_ACCION_CONTRAANULAR`; "MECANIZAR"×1→`cons!SCA2_TXT_ACCION_MECANIZAR` | `/test` 8 casos, salida idéntica |
| `SCA2_datosPerfilesPcaSi24` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051482` | expression-rules | 1→2 | 5 | "CE_MF_SI24"×1→`cons!SCA2_TXT_PERFIL_CE_MF_SI24`; "CE_MF_SI24_SA"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_SA`; "CE_MF_SI24_TECNICO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_TECNICO`; "CE_MF_SI24_EXPERTO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO`; "CE_MF_SI24_FRONT"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT` | `/test` 14 casos, salida idéntica |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | interfaces | 70→71 | 82 | "FINALIZADA_POSITIVO"×2→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO`; "FINALIZADA_NEG_CONTRA"×2→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA`; "FINALIZADA_NO_REQ"×1→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ`; "CADUCADA"×5→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA`; "PENDIENTE_AUTORIZACION"×2→`cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION`; "FINALIZADA"×11→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA`; "FINALIZADA_SIN_ANULAR"×2→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR`; "PENDIENTE"×2→`cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE`; "CADUCADA_NEGATIVA"×1→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA`; "COMPLETADA"×2→`cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA`; "MECANIZAR"×2→`cons!SCA2_TXT_ACCION_MECANIZAR`; "EN_ACCION"×1→`cons!SCA2_TXT_ESTADO_SOL_EN_ACCION`; "CONTRA ANULAR"×1→`cons!SCA2_TXT_ACCION_CONTRA_ANULAR`; "AUTORIZACION"×6→`cons!SCA2_TXT_ACCION_AUTORIZACION`; "#000000"×13→`cons!SCA2_VAL_COLOR_NEGRO`; "#F5F5F5"×4→`cons!SCA2_VAL_COLOR_GRIS_CLARO`; "#FFFFFF"×1→`cons!SCA2_VAL_COLOR_BLANCO`; "#008C47"×5→`cons!SCA2_VAL_COLOR_VERDE_OSCURO`; "VERTI"×4→`cons!SCA2_TXT_CONTACTO_VERTI`; "VENCIMIENTO"×2→`cons!SCA2_TXT_ACCION_VENCIMIENTO`; "#BE0F0F"×4→`cons!SCA2_VAL_COLOR_ROJO_OSCURO`; "#0D82BD"×1→`cons!SCA2_VAL_COLOR_AZUL`; "#9F9F9F"×1→`cons!SCA2_VAL_COLOR_GRIS_MEDIO`; "#E46B15"×1→`cons!SCA2_VAL_COLOR_NARANJA_OSCURO`; "#ffffff"×4→`cons!SCA2_VAL_COLOR_BLANCO`; "CE_MF_SI24_EXPERTO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO`; "CE_MF_SI24"×1→`cons!SCA2_TXT_PERFIL_CE_MF_SI24` | validate sin errores nuevos + UI |
| `SCA2_FechaDisponibilidadVehiculo` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052747` | interfaces | 1→2 | 2 | "CE_MF_RECIBOS_CCC"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC`; "CE_MF_RECIBOS_CCR"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR` | validate sin errores nuevos + UI |
| `SCA2_GestionArgumentos` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053041` | interfaces | 3→4 | 1 | "#000000"×1→`cons!SCA2_VAL_COLOR_NEGRO` | validate sin errores nuevos + UI |
| `SCA2_InduccionVertiPanel` | `_a-0000f096-c175-8000-9d37-011c48011c48_5610492` | interfaces | 6→7 | 5 | "COMPLETADA"×3→`cons!SCA2_TXT_ESTADO_TAREA_COMPLETADA`; "PENDIENTE"×1→`cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE`; "#008C47"×1→`cons!SCA2_VAL_COLOR_VERDE_OSCURO` | validate sin errores nuevos + UI |
| `SCA2_MensajeDesactivarAplicacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052849` | interfaces | 1→2 | 1 | "#000000"×1→`cons!SCA2_VAL_COLOR_NEGRO` | validate sin errores nuevos + UI |
| `SCA2_ModalPlanPago` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053035` | interfaces | 1→2 | 2 | "#000000"×2→`cons!SCA2_VAL_COLOR_NEGRO` | validate sin errores nuevos + UI |
| `SCA2_mostrarBotonCancelarPosponer` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051278` | expression-rules | 1→2 | 5 | "CE_MF_SI24_EXPERTO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO`; "CE_RM"×2→`cons!SCA2_TXT_PERFIL_CE_RM`; "CE_MF_RECIBOS"×1→`cons!SCA2_TXT_PERFIL_CE_MF_RECIBOS`; "CE_MF_SI24_FRONT"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT` | `/test` 56 casos, salida idéntica |
| `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051578` | expression-rules | 1→2 | 8 | "CE_RM"×1→`cons!SCA2_TXT_PERFIL_CE_RM`; "CE_MF_SI24"×1→`cons!SCA2_TXT_PERFIL_CE_MF_SI24`; "CE_MF_RECIBOS"×1→`cons!SCA2_TXT_PERFIL_CE_MF_RECIBOS`; "CE_RM_DT"×1→`cons!SCA2_TXT_PERFIL_CE_RM_DT`; "CE_MF_CONTROL"×1→`cons!SCA2_TXT_PERFIL_CE_MF_CONTROL`; "CE_MF_CENTRAL_AT"×1→`cons!SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT`; "CE_MF_SI24_FRONT"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT`; "CE_MF_SI24_EXPERTO"×1→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO` | `/test` 1 casos, salida idéntica |
| `SCA2_obtenerTipoPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052969` | expression-rules | 1→2 | 1 | "200"×1→`cons!SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS` | `/test` 6 casos, salida idéntica |
| `SCA2_simularAnulacionPoliza` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051194` | expression-rules | 2→3 | 2 | "4022"×2→`tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022)` | `/test` 3 casos, salida idéntica |
| `SCA2_TablaNotificaciones` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051620` | interfaces | 1→2 | 1 | "#000000"×1→`cons!SCA2_VAL_COLOR_NEGRO` | validate sin errores nuevos + UI |
| `SCA2_VertiVencimientoPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063389` | interfaces | 14→15 | 9 | "ACCIONES ADMINISTRATIVAS"×2→`cons!SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS`; "VERTI"×1→`cons!SCA2_TXT_CONTACTO_VERTI`; "VENCIMIENTO"×2→`cons!SCA2_TXT_ACCION_VENCIMIENTO`; "#000000"×1→`cons!SCA2_VAL_COLOR_NEGRO`; "#9F9F9F"×2→`cons!SCA2_VAL_COLOR_GRIS_MEDIO`; "#FFFFFF"×1→`cons!SCA2_VAL_COLOR_BLANCO` | validate sin errores nuevos + UI |

Total: **28 objetos, 228 sustituciones**.

## Decisiones

- `"#008C47"` → `cons!SCA2_VAL_COLOR_VERDE_OSCURO` (creada por R32-A a petición de la coordinación). **No** se usa `SCA2_VAL_COLOR_VERDE`, que ya existía con otro valor (`#00E663`).
- `"#ffffff"` → `cons!SCA2_VAL_COLOR_BLANCO` (`#FFFFFF`), según la especificación (mismo color).
- `"#9F9F9F"` → `cons!SCA2_VAL_COLOR_GRIS_MEDIO` (ya existente).
- `"4022"` (en `SCA2_simularAnulacionPoliza` se compara y se devuelve como texto) → `tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022)` para conservar el tipo texto (la constante es INTEGER).
- `"200"` en `SCA2_obtenerTipoPoliza` es el prefijo de póliza (`local!inicio` = 3 primeros dígitos) → `cons!SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS`. No hay usos de `200` como código HTTP en el lote.
- `"CA"` en `SCA2_ContraAnulacionOpciones` (9 usos como `tipoGestion`/`tipoAccion`) → `cons!SCA2_TXT_TIPO_GESTION_CA`.
- `"PENDIENTE"`/`"COMPLETADA"` (estado de tarea) → `SCA2_TXT_ESTADO_TAREA_*`, también donde se muestran como texto de estado en `SCA2_InduccionVertiPanel` y `SCA2_DetalleSolicitud`.

## Literales NO sustituidos (y motivo)

| Objeto | Literal | Motivo |
|---|---|---|
| `SCA2_ContraAnulacionOpciones` | `"OFICINA_DIRECTA"` | Es clave de mapa de respuesta de servicio (`index(..., "OFICINA_DIRECTA", ...)`), no valor de negocio (regla 2). |
| `SCA2_DetalleSolicitud` | `"SGO"` | Etiqueta del hito de mecanización en la lista `{"Mecaniza", "SGO", "STCAT", "Anulación"}` (texto de interfaz), no canal de entrada. |
| `SCA2_datosPerfilesPcaSi24` | `"CE_MF_BK_EXPERTOSI24"` | El código real no lleva guion bajo; `SCA2_TXT_SUBPERFIL_CE_MF_BK_EXPERTO_SI24` vale `CE_MF_BK_EXPERTO_SI24` y sustituirlo cambiaría el comportamiento. |
| `SCA2_mostrarBotonCancelarPosponer` | `"CE_GGE"`, `"CE_MF"`, `"FUERA_SGC"` | Fuera de la especificación y de un solo uso en el lote. |
| `SCA2_InduccionVertiPanel` | `"EN CURSO"`, `"#D9822B"` | Fuera de la especificación y de un solo uso. |
| `SCA2_DetalleSolicitud` | `"#ffb005"`, `"CANCELADA"`, `"MECANIZA"`… | Fuera de la especificación; no se crean constantes nuevas en esta ronda para ellos. |

No se ha creado ninguna constante nueva desde R32-B.

## Pruebas

### Reglas (`POST /expression-rules/{uuid}/test`, antes y después)

Salida idéntica (comparando `result`, sin diagnósticos de tiempo) en los 12 objetos de tipo regla:

| Regla | Casos | Entradas |
|---|---|---|
| `SCA2_D_TiposGestiones` | 8 | todas las acciones + otro + nulo |
| `SCA2_colorEstadoSolicitud` | 13 | los 11 estados de solicitud + `CANCELADA` + vacío |
| `SCA2_datosPerfilesPcaSi24` | 14 | combinaciones reales perfil/subperfil (RM, SI24, BK, RECIBOS, CONTROL, CENTRAL_AT…) |
| `SCA2_mostrarBotonCancelarPosponer` | 56 | perfiles × propietario igual/distinto × nivel 1/3 |
| `SCA2_calculoMedioComunicacion` | 42 | perfiles × canal 1/5/7 |
| `SCA2_altaGestionCore` | 40 | acciones × perfiles, **sin `idSolicitud`** (la regla no llama a CORE; evita escribir sobre solicitudes reales) |
| `SCA2_obtenerTipoPoliza` | 6 | pólizas reales 0000253500329, 0005726681296, 0001047017037 + prefijos 200/001 + vacío |
| `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado` | 1 | usuario de servicio |
| `SCA2_consultarDocumentos` / `SCA2_consultarDocumentosREST` | 3 + 3 | solicitudes existentes 15788291, 15788292, 15787911 (solo lectura) |
| `SCA2_construirContextoAlta` | 3 | pólizas reales (solo lectura) |
| `SCA2_simularAnulacionPoliza` | 3 | pólizas reales; simulación NSE (solo lectura; NSE responde 4011 en los 3 casos, rama 4022 no alcanzable con estos datos) |

### Interfaces

`/expressions/validate` antes y después sin errores nuevos en las 16 interfaces. Prueba UI con solicitud nueva: ver apartado siguiente.

### Prueba UI (solicitud nueva)

Grabada con el agente de pruebas (usuario JJGONZ2, perfil CE_RM). **Resultado: correcto, sin errores de expresión ni constantes no encontradas.**

- Alta **nueva**: solicitud **15788366**, póliza 2002500381088, observaciones «Regresión R32-B constantes UI».
- Contra anulación (desde RETOMAR del detalle): `SCA2_ContraAnulacionOpciones` y `SCA2_ContraAnulacionCompaniaCatalogacion` renderizan (selector de oficina, catálogo de compañías); `SCA2_ContraAnulacionArgumentarioEstrategicas` con 9 argumentos en estado Pendiente; POSITIVO/NEGATIVO deshabilitados hasta seleccionar argumento. Se eligió «INCREMENTO PRIMA SINIESTROS» → POSITIVO → confirmación → ACEPTAR.
- `SCA2_BuscadorTabla`: la solicitud aparece como «Finalizado Contra Anulación Positiva» en verde con fecha de resolución (tras la actualización asíncrona habitual).
- `SCA2_DetalleSolicitud`: cabecera de póliza, hitos Alta Finalizada y Contra Anulación Finalizada Positiva en verde, fecha fin y argumento Positivo.
- `SCA2_TablaNotificaciones`: columnas y estado vacío «No hay elementos disponibles».
- No probados en UI (el flujo no los ofreció con esta póliza): Verti/vencimiento (`SCA2_VertiVencimientoPrincipal`, `SCA2_InduccionVertiPanel`) y los modales de recuperación, rehabilitación, Sí/No, plan de pago, gestión de argumentos, disponibilidad de vehículo, anulación fuera de norma y mensaje de desactivación. Para estos queda la validación `/expressions/validate` sin errores nuevos y la comparación de la expresión releída.

## Pendientes

- Ninguno bloqueante del lote B.
- Cobertura UI de las pantallas no alcanzadas (Verti/vencimiento y modales listados arriba) con una nueva solicitud que lleve a esas ramas.
- Para la sesión padre: decidir si `"CE_MF_BK_EXPERTOSI24"` (código real) necesita una constante propia, dado que `SCA2_TXT_SUBPERFIL_CE_MF_BK_EXPERTO_SI24` tiene otro valor.
