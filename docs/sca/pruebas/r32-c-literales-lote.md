# R32-C — Literales de negocio → constantes en el lote C de SCA2

Ronda 32 (SCA vs SCA2, Appian TEST). Origen: `docs/sca/54-ronda31-constantes-y-objetos-sin-uso-sca2.md`; reparto: `docs/sca/pruebas/coordinacion-ronda32.md`.

## 1. Resumen

- 28 objetos del lote C revisados; **27 modificados** y 1 sin cambios (`SCA2_companiasContrariasCompletas`).
- 188 literales sustituidos por 40 constantes (`cons!`). Cambio funcional cero: cada constante tiene exactamente el valor del literal que sustituye (comprobado leyendo la constante viva antes de escribir).
- No se ha creado ninguna constante: todas las usadas las creó R32-A.
- Método por objeto: leer objeto vivo → backup local → sustitución mínima (solo el literal entre comillas, nunca dentro de comentarios `/* */`) → `PUT` → releer (expresión releída = expresión enviada) → comparar → probar.

## 2. Tabla por objeto

| Objeto | Versión antes→después | Literales sustituidos | Prueba |
|---|---|---|---|
| `SCA2_AccionesAdministrativasCatalogacion` | 1→2 | `"#6495ED"`→`SCA2_VAL_COLOR_AZUL_CLARO` ×1, `"CE_MF_RECIBOS_CCC"`→`SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC` ×1, `"CE_MF_RECIBOS_CCR"`→`SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR` ×1 | validate =; UI (ver §4) |
| `SCA2_AccionesAdministrativasDocumentacion` | 5→6 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×3, `"BAJA TEMPORAL"`→`SCA2_TXT_CAUSA_BAJA_TEMPORAL` ×1, `"BAJA VEHICULO"`→`SCA2_TXT_CAUSA_BAJA_VEHICULO` ×1, `"CE_MF_CENTRAL_AT"`→`SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT` ×1, `"CE_MF_CONTROL"`→`SCA2_TXT_PERFIL_CE_MF_CONTROL` ×1 | validate =; UI (ver §4) |
| `SCA2_AccionesAdministrativasPrincipal` | 23→24 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×5, `"#FFFFFF"`→`SCA2_VAL_COLOR_BLANCO` ×1, `"ACCADM"`→`SCA2_TXT_TIPO_GESTION_ACCADM` ×2, `"ACCIONES ADMINISTRATIVAS"`→`SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS` ×2, `"BAJA TEMPORAL"`→`SCA2_TXT_CAUSA_BAJA_TEMPORAL` ×1, `"BAJA VEHICULO"`→`SCA2_TXT_CAUSA_BAJA_VEHICULO` ×1, `"FINALIZADA"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA` ×1, `"PENDIENTE"`→`SCA2_TXT_ESTADO_TAREA_PENDIENTE` ×1 | validate =; UI (ver §4) |
| `SCA2_AltaGestionArgumento` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×3, `"#F5F5F5"`→`SCA2_VAL_COLOR_GRIS_CLARO` ×1, `"DOCS_SCA_001"`→`SCA2_TXT_SGD_COD_DOCUMENTAL` ×1 | validate =; UI (ver §4) |
| `SCA2_AltaGestionConcepto` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×1, `"CE_RM"`→`SCA2_TXT_PERFIL_CE_RM` ×1, `"CE_RM_OFICINA"`→`SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×1 | validate =; UI (ver §4) |
| `SCA2_AnadirGestionConceptosyClases` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×2, `"CE_RM"`→`SCA2_TXT_PERFIL_CE_RM` ×5, `"CE_RM_OFICINA"`→`SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×5 | validate =; UI (ver §4) |
| `SCA2_BandejaErrores` | 11→12 | `"PENDIENTE"`→`SCA2_TXT_ESTADO_TAREA_PENDIENTE` ×4 | validate =; UI (ver §4) |
| `SCA2_BuscarCompaniasContrarias` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×1, `"#F5F5F5"`→`SCA2_VAL_COLOR_GRIS_CLARO` ×1 | validate =; UI (ver §4) |
| `SCA2_DatosCabecera_Estrategicas` | 2→3 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×3, `"#F5F5F5"`→`SCA2_VAL_COLOR_GRIS_CLARO` ×2 | validate =; UI (ver §4) |
| `SCA2_DetalleTareas` | 38→39 | `"#FFFFFF"`→`SCA2_VAL_COLOR_BLANCO` ×1, `"#ffffff"`→`SCA2_VAL_COLOR_BLANCO` ×1, `"ACCIONES ADMINISTRATIVAS"`→`SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS` ×1, `"AUTORIZACION"`→`SCA2_TXT_ACCION_AUTORIZACION` ×9, `"CADUCADA"`→`SCA2_TXT_ESTADO_SOL_CADUCADA` ×1, `"COMPLETADA"`→`SCA2_TXT_ESTADO_TAREA_COMPLETADA` ×2, `"CONTRA ANULAR"`→`SCA2_TXT_ACCION_CONTRA_ANULAR` ×8, `"CONTRAANULAR"`→`SCA2_TXT_ACCION_CONTRAANULAR` ×1, `"EN_ACCION"`→`SCA2_TXT_ESTADO_SOL_EN_ACCION` ×1, `"FINALIZADA"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA` ×2, `"FINALIZADA_POSITIVO"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO` ×1, `"MECANIZAR"`→`SCA2_TXT_ACCION_MECANIZAR` ×7, `"PENDIENTE"`→`SCA2_TXT_ESTADO_TAREA_PENDIENTE` ×9, `"VERTI"`→`SCA2_TXT_CONTACTO_VERTI` ×9 | validate =; UI (ver §4) |
| `SCA2_GenerarContactoVerti` | 2→3 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×3, `"#6495ED"`→`SCA2_VAL_COLOR_AZUL_CLARO` ×1, `"#FFFFFF"`→`SCA2_VAL_COLOR_BLANCO` ×3 | validate =; UI (ver §4) |
| `SCA2_GestionConceptosYClases` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×1 | validate =; UI (ver §4) |
| `SCA2_MantenimientoPendientesAutorizar` | 2→3 | `"SGO"`→`SCA2_TXT_CANAL_SGO` ×2 | validate =; UI (ver §4) |
| `SCA2_MensajeEliminacionConcepto` | 1→2 | `"#ff8000"`→`SCA2_VAL_COLOR_NARANJA` ×1 | validate =; UI (ver §4) |
| `SCA2_MensajeEliminacionDocumento` | 1→2 | `"#ff8000"`→`SCA2_VAL_COLOR_NARANJA` ×1 | validate =; UI (ver §4) |
| `SCA2_ModalClaveProduccion` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×4 | validate =; UI (ver §4) |
| `SCA2_PieDePagina` | 1→2 | `"#000000"`→`SCA2_VAL_COLOR_NEGRO` ×8 | validate =; UI (ver §4) |
| `SCA2_TablaOtrasSolAnulacion` | 8→9 | `"#ffffff"`→`SCA2_VAL_COLOR_BLANCO` ×1, `"CADUCADA"`→`SCA2_TXT_ESTADO_SOL_CADUCADA` ×4, `"CADUCADA_NEGATIVA"`→`SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA` ×1, `"FINALIZADA"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA` ×2, `"FINALIZADA_NEG_CONTRA"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA` ×3, `"FINALIZADA_NO_REQ"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ` ×2, `"FINALIZADA_POSITIVO"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO` ×2, `"FINALIZADA_SIN_ANULAR"`→`SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR` ×2, `"PENDIENTE"`→`SCA2_TXT_ESTADO_TAREA_PENDIENTE` ×1, `"PENDIENTE_AUTORIZACION"`→`SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION` ×2 | validate =; UI (ver §4) |
| `SCA2_actualizarVariable` | 1→2 | `"CE_MF_CONTROL"`→`SCA2_TXT_PERFIL_CE_MF_CONTROL` ×1 | validate =; sin `/test` (llama a integración de escritura PCA) |
| `SCA2_calcularEstadoSolicitud` | 3→4 | `"CADUCADA"`→`SCA2_TXT_ESTADO_SOL_CADUCADA` ×1 | validate =; `/test` 25 casos antes=después |
| `SCA2_catParametrosCarga` | 3→4 | `"CE_MF_BK"`→`SCA2_TXT_PERFIL_CE_MF_BK` ×2, `"CE_MF_SI24"`→`SCA2_TXT_PERFIL_CE_MF_SI24` ×2, `"CE_MF_SI24_EXPERTO"`→`SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO` ×1, `"CE_RM"`→`SCA2_TXT_PERFIL_CE_RM` ×3, `"CE_RM_OFICINA"`→`SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×2 | validate =; `/test` 1 casos antes=después |
| `SCA2_companiasContrariasCompletas` | 1 (sin cambios) | — (el único `"200"` es código de compañía, no prefijo de póliza NSE) | sin cambios |
| `SCA2_consultarConceptoReutilizable` | 2→3 | `"CE_RM"`→`SCA2_TXT_PERFIL_CE_RM` ×1, `"CE_RM_OFICINA"`→`SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×1 | validate =; `/test` 2 casos antes=después |
| `SCA2_erroresGuardarSolicitud` | 1→2 | `"CE_MF_RECIBOS_CCC"`→`SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC` ×2, `"CE_MF_RECIBOS_CCR"`→`SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR` ×2, `"CE_RM"`→`SCA2_TXT_PERFIL_CE_RM` ×2 | validate =; `/test` 8 casos antes=después |
| `SCA2_mostrarMensajesOAlta` | 1→2 | `"200"`→`SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS` ×2, `"CE_MF_BK"`→`SCA2_TXT_PERFIL_CE_MF_BK` ×1, `"CE_MF_RECIBOS_CCC"`→`SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC` ×1, `"CE_MF_SI24_EXPERTO"`→`SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO` ×1, `"CE_MF_SI24_FRONT"`→`SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT` ×2 | validate =; `/test` 9 casos antes=después |
| `SCA2_obtenerInformacionUsuario` | 1→2 | `"CE_RM"`→`SCA2_TXT_PERFIL_CE_RM` ×2, `"CE_RM_OFICINA"`→`SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×2 | validate =; `/test` 1 casos antes=después |
| `SCA2_parametrosRelanzarCompletarAccion` | 4→5 | `"CA"`→`SCA2_TXT_TIPO_GESTION_CA` ×1, `"PENDIENTE"`→`SCA2_TXT_ESTADO_TAREA_PENDIENTE` ×1 | validate =; `/test` 1 casos antes=después |
| `SCA2_subirDocumentosGD` | 11→12 | `"ACCADM"`→`SCA2_TXT_TIPO_GESTION_ACCADM` ×1, `"CA"`→`SCA2_TXT_TIPO_GESTION_CA` ×1, `"QUERY_SCA_AGD_001"`→`SCA2_TXT_SGD_QUERY_ARGUMENTOS` ×1 | validate =; `/test` 3 casos antes=después |

`validate =`: `POST /expressions/validate` de la expresión antes y después devuelve exactamente los mismos mensajes (solo referencias `ri!`/`env!` no resolubles fuera de contexto, propias del validador sin contexto); ningún error nuevo.

### UUID y número de sustituciones

| Objeto | Tipo | UUID | Nº sustituciones |
|---|---|---|---:|
| `SCA2_AccionesAdministrativasCatalogacion` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053127` | 3 |
| `SCA2_AccionesAdministrativasDocumentacion` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060475` | 7 |
| `SCA2_AccionesAdministrativasPrincipal` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | 14 |
| `SCA2_AltaGestionArgumento` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063439` | 5 |
| `SCA2_AltaGestionConcepto` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051566` | 3 |
| `SCA2_AnadirGestionConceptosyClases` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052843` | 12 |
| `SCA2_BandejaErrores` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055578` | 4 |
| `SCA2_BuscarCompaniasContrarias` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051662` | 2 |
| `SCA2_DatosCabecera_Estrategicas` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053328` | 5 |
| `SCA2_DetalleTareas` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | 53 |
| `SCA2_GenerarContactoVerti` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050894` | 7 |
| `SCA2_GestionConceptosYClases` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053047` | 1 |
| `SCA2_MantenimientoPendientesAutorizar` | interfaz | `_a-0000f090-b70c-8000-9d35-011c48011c48_5582354` | 2 |
| `SCA2_MensajeEliminacionConcepto` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051584` | 1 |
| `SCA2_MensajeEliminacionDocumento` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052819` | 1 |
| `SCA2_ModalClaveProduccion` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053298` | 4 |
| `SCA2_PieDePagina` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050888` | 8 |
| `SCA2_TablaOtrasSolAnulacion` | interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065000` | 20 |
| `SCA2_actualizarVariable` | regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051008` | 1 |
| `SCA2_calcularEstadoSolicitud` | regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052795` | 1 |
| `SCA2_catParametrosCarga` | regla | `_a-0000f093-2064-8000-9d36-011c48011c48_5604030` | 10 |
| `SCA2_consultarConceptoReutilizable` | regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052825` | 2 |
| `SCA2_erroresGuardarSolicitud` | regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053438` | 6 |
| `SCA2_mostrarMensajesOAlta` | regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051674` | 7 |
| `SCA2_obtenerInformacionUsuario` | regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051686` | 4 |
| `SCA2_parametrosRelanzarCompletarAccion` | regla | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5483721` | 2 |
| `SCA2_subirDocumentosGD` | regla | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481351` | 3 |

## 3. Constantes utilizadas (creadas por R32-A)

| Constante | UUID | Valor |
|---|---|---|
| `SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624094` | `ACCIONES ADMINISTRATIVAS` |
| `SCA2_TXT_ACCION_AUTORIZACION` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624088` | `AUTORIZACION` |
| `SCA2_TXT_ACCION_CONTRAANULAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624076` | `CONTRAANULAR` |
| `SCA2_TXT_ACCION_CONTRA_ANULAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624070` | `CONTRA ANULAR` |
| `SCA2_TXT_ACCION_MECANIZAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624082` | `MECANIZAR` |
| `SCA2_TXT_CANAL_SGO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624148` | `SGO` |
| `SCA2_TXT_CAUSA_BAJA_TEMPORAL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624154` | `BAJA TEMPORAL` |
| `SCA2_TXT_CAUSA_BAJA_VEHICULO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624160` | `BAJA VEHICULO` |
| `SCA2_TXT_CONTACTO_VERTI` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624172` | `VERTI` |
| `SCA2_TXT_ESTADO_SOL_CADUCADA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624046` | `CADUCADA` |
| `SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624052` | `CADUCADA_NEGATIVA` |
| `SCA2_TXT_ESTADO_SOL_EN_ACCION` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623992` | `EN_ACCION` |
| `SCA2_TXT_ESTADO_SOL_FINALIZADA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624016` | `FINALIZADA` |
| `SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624034` | `FINALIZADA_NEG_CONTRA` |
| `SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624040` | `FINALIZADA_NO_REQ` |
| `SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624022` | `FINALIZADA_POSITIVO` |
| `SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624028` | `FINALIZADA_SIN_ANULAR` |
| `SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624010` | `PENDIENTE_AUTORIZACION` |
| `SCA2_TXT_ESTADO_TAREA_COMPLETADA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624064` | `COMPLETADA` |
| `SCA2_TXT_ESTADO_TAREA_PENDIENTE` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624058` | `PENDIENTE` |
| `SCA2_TXT_PERFIL_CE_MF_BK` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623902` | `CE_MF_BK` |
| `SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623914` | `CE_MF_CENTRAL_AT` |
| `SCA2_TXT_PERFIL_CE_MF_CONTROL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623908` | `CE_MF_CONTROL` |
| `SCA2_TXT_PERFIL_CE_MF_SI24` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623890` | `CE_MF_SI24` |
| `SCA2_TXT_PERFIL_CE_RM` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623884` | `CE_RM` |
| `SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624142` | `200` |
| `SCA2_TXT_SGD_COD_DOCUMENTAL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624124` | `DOCS_SCA_001` |
| `SCA2_TXT_SGD_QUERY_ARGUMENTOS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624130` | `QUERY_SCA_AGD_001` |
| `SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623974` | `CE_MF_RECIBOS_CCC` |
| `SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623980` | `CE_MF_RECIBOS_CCR` |
| `SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623938` | `CE_MF_SI24_EXPERTO` |
| `SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623944` | `CE_MF_SI24_FRONT` |
| `SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623926` | `CE_RM_OFICINA` |
| `SCA2_TXT_TIPO_GESTION_ACCADM` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624106` | `ACCADM` |
| `SCA2_TXT_TIPO_GESTION_CA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624112` | `CA` |
| `SCA2_VAL_COLOR_AZUL_CLARO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624196` | `#6495ED` |
| `SCA2_VAL_COLOR_BLANCO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624184` | `#FFFFFF` |
| `SCA2_VAL_COLOR_GRIS_CLARO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624190` | `#F5F5F5` |
| `SCA2_VAL_COLOR_NARANJA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624202` | `#ff8000` |
| `SCA2_VAL_COLOR_NEGRO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624178` | `#000000` |

`#ffffff` (minúsculas) se sustituye por `SCA2_VAL_COLOR_BLANCO` (`#FFFFFF`) por indicación expresa de la especificación; los colores hexadecimales no distinguen mayúsculas.

## 4. Pruebas

### 4.1 Reglas (`POST /expression-rules/{uuid}/test`, solo lectura)

Mismas entradas antes y después del cambio; se compara `result` y `error`:

| Regla | Casos | Entradas | Resultado |
|---|---:|---|---|
| `SCA2_calcularEstadoSolicitud` | 25 | estados CORE 1/2/4/5/14 × estado de mecanización CADUCADA, FINALIZADA CADUCADA, ANULACION REALIZADA, MECANIZACION INCOMPLETA, vacío | idéntico |
| `SCA2_erroresGuardarSolicitud` | 8 | perfil CE_RM / CE_MF_SI24, subperfil CE_RM_OFICINA / CE_MF_RECIBOS_CCC / CCR, causa 29 con canal 5 y 1, fechas fuera de rango (llama a simulación NSE y `SCA2_polizaRenovada`) | idéntico |
| `SCA2_mostrarMensajesOAlta` | 9 | subperfiles SI24_FRONT (+isSi24), SI24_EXPERTO, CE_MF_BK, RECIBOS_CCC; ramo 200/100; causa 28; acuerdo 20 (flota); NSE hogar | idéntico (los 4 mensajes distintos se reproducen igual) |
| `SCA2_parametrosRelanzarCompletarAccion` | 1 | sin filtros → primer error `PENDIENTE` real (error 78, solicitud 15787932) | idéntico |
| `SCA2_consultarConceptoReutilizable` | 2 | conceptos 1 y 2 (servicio PCA de consulta) | idéntico |
| `SCA2_catParametrosCarga` | 1 | sin entradas | idéntico |
| `SCA2_obtenerInformacionUsuario` | 1 | sin entradas | idéntico |
| `SCA2_subirDocumentosGD` | 3 | tipoGestion ACCADM / CA / AUT con lista de documentos vacía (no sube nada) | idéntico |
| `SCA2_actualizarVariable` | — | no se ejecuta: invoca la integración de escritura `IGestionarConceptosPCA.actualizarVariable` | solo validate y relectura |

### 4.2 Interfaces (UI)

Ver §6 (prueba UI con solicitud nueva, grabada).

## 5. Decisiones y literales NO sustituidos

| Objeto | Literal | Motivo |
|---|---|---|
| `SCA2_companiasContrariasCompletas` | `"200"` (`codigo: "200"`) | Es el código de una compañía contraria, no prefijo de póliza NSE (regla 3). Objeto sin cambios. |
| `SCA2_mostrarMensajesOAlta` | `"200"` en `local!codRamo = "200"` | **Sí** se sustituye por `SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS`: el ramo son los 3 primeros dígitos del nº de póliza, el mismo prefijo que `SCA2_obtenerTipoPoliza` compara con `"200"` para NSE Autos. |
| `SCA2_AccionesAdministrativasPrincipal` | `"OFICINA_DIRECTA"` | Se usa como clave del mapa de respuesta del servicio de oficinas (`index(..., "OFICINA_DIRECTA")`), regla 2. |
| `SCA2_catParametrosCarga` | `"CE_MF_BK_EXPERTOSI24"` | Valor real distinto de la constante de la especificación `SCA2_TXT_SUBPERFIL_CE_MF_BK_EXPERTO_SI24` (`CE_MF_BK_EXPERTO_SI24`); sustituirlo cambiaría el valor. Se deja como hallazgo. |
| Todos | literales dentro de comentarios | No son código. |
| `SCA2_DetalleTareas`, `SCA2_TablaOtrasSolAnulacion`, `SCA2_AccionesAdministrativasPrincipal` | estados heredados no especificados (`FINALIZADA_ANULADA`, `FINALIZADA_RECHAZADA_ANULACION`, `FINALIZADA_NEGATIVO`, `RECHAZADA`, `CANCELADA`, `CANCELADO`, `ERROR`, `PDTE_REDIRECCION_VIDA`…) | Fuera de la especificación y de la asignación del lote; la mayoría de un solo uso por objeto. Candidatos para una ronda posterior. |
| `SCA2_calcularEstadoSolicitud` | `"FINALIZADA CADUCADA"`, `"ANULACION REALIZADA"`… | Estados de gestión de CORE (texto libre), fuera de la especificación. |

Notas semánticas:

- `PENDIENTE`: se usa `SCA2_TXT_ESTADO_TAREA_PENDIENTE` en todos los usos (tarea, estado del registro `SCA2 Error` en `SCA2_BandejaErrores`, `SCA2_AccionesAdministrativasPrincipal`, `SCA2_parametrosRelanzarCompletarAccion`, y estado de solicitud en `SCA2_TablaOtrasSolAnulacion`/`SCA2_DetalleTareas`): su descripción en Appian es «Estado de tarea/gestión/error: pendiente» y la especificación pide no duplicar constantes con el mismo valor.
- `VERTI` en `SCA2_DetalleTareas` es el tipo de tarea/pantalla del contacto Verti; se usa `SCA2_TXT_CONTACTO_VERTI` (mismo valor).
- `CA` además de lo asignado: en `SCA2_parametrosRelanzarCompletarAccion` y `SCA2_subirDocumentosGD` es tipo de gestión → `SCA2_TXT_TIPO_GESTION_CA`.
- `"CADUCADA"` en `SCA2_calcularEstadoSolicitud` compara el estado de mecanización; mismo valor que `SCA2_TXT_ESTADO_SOL_CADUCADA` (asignado por la coordinación).

## 6. Prueba UI

PENDIENTE_UI

## 7. Pendientes

- Hallazgo `CE_MF_BK_EXPERTOSI24` (ver §5): decidir si se crea constante propia o si el valor de CORE es `CE_MF_BK_EXPERTO_SI24`.
- Ningún objeto fuera del lote C ha sido necesario ni modificado.
