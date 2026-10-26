# R32-D — literales de negocio → constantes en el lote D (28 objetos SCA2)

Entorno: Appian TEST, aplicación SCA2 `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`. Reparto: `coordinacion-ronda32.md` (lote R32-D). Fecha: 26/10/2026.

## Método
1. Inventario de la app por LCP (`/objects`, paginado de 50) y comprobación de que existen las 57 constantes de R32-A.
2. Por objeto: GET vivo → backup local → sustitución mínima de **literales entrecomillados** (se ignoran comentarios `/* */` y referencias `'recordType!…'`) por `cons!` con el mismo valor → PUT con el `versionId` vivo → relectura y comparación exacta de la expresión.
3. Validación: `/expressions/validate` de la expresión antes y después (con `ri!` sustituidos): **mismos mensajes antes y después en los 28** (solo «unresolved reference» de las entradas y, en dos interfaces, `env!features`, preexistente).
4. Regresión:
   - Reglas: `POST /expression-rules/{uuid}/test` con las mismas entradas antes y después (datos reales de solo lectura: errores reales del registro `SCA2 Error`, salidas reales de `SCA2_cargarSolicitud` de las solicitudes 15787865, 15788151, 15788209 y 15787895, y todos los valores de perfil/estado/código del catálogo). **275/275 salidas iguales** (259 casos en 10 reglas + 16 de `SCA2_posponerGestionSGC`).
   - `SCA2_posponerGestionSGC` se modificó antes de capturar el «antes»: se restauró la expresión del backup (v3), se ejecutaron 16 casos (`soloPayload: true`, sin llamar a servicios), se volvió a aplicar el cambio (v4) y se repitieron: 16/16 iguales.
   - Interfaces: `POST /interfaces/{uuid}/test` (render sin entradas) antes y después, comparando el árbol de componentes sin identificadores volátiles (`_cId`, `saveInto` cifrados): **14/14 iguales**. Única diferencia: en `SCA2_Buscador` el `textColor` del estado pasa de `#ffffff` a `#FFFFFF` (Appian normaliza a minúsculas el literal; la constante devuelve el valor tal cual). Es el mismo color.
   - UI: ver apartado «Prueba UI».

## Resultado por objeto
| Objeto | UUID | Versión | Nº | Literales → constante | Prueba |
|---|---|---|---|---|---|
| `SCA2_textoEstadoSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063670` | v15→v16 | 12 | `EN_ACCION`→`cons!SCA2_TXT_ESTADO_SOL_EN_ACCION`; `PENDIENTE`→`cons!SCA2_TXT_ESTADO_SOL_PENDIENTE`; `PDTE_FINALIZAR`→`cons!SCA2_TXT_ESTADO_SOL_PDTE_FINALIZAR`; `PDTE_MECANIZAR`→`cons!SCA2_TXT_ESTADO_SOL_PDTE_MECANIZAR`; `PENDIENTE_AUTORIZACION`→`cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION`; `FINALIZADA_POSITIVO`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO`; `FINALIZADA`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA`; `FINALIZADA_SIN_ANULAR`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR`; `FINALIZADA_NEG_CONTRA`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA`; `FINALIZADA_NO_REQ`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ`; `CADUCADA`→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA`; `CADUCADA_NEGATIVA`→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA` | `/test` antes/después 28/28 iguales |
| `SCA2_AltaSolicitudAnulacionPopUp` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064994` | v9→v10 | 1 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | v39→v40 | 17 | `CE_RM_OFICINA`→`cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA`; `PENDIENTE`→`cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE` ×2; `EN_ACCION`→`cons!SCA2_TXT_ESTADO_SOL_EN_ACCION`; `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` ×5; `#F5F5F5`→`cons!SCA2_VAL_COLOR_GRIS_CLARO` ×4; `#FFFFFF`→`cons!SCA2_VAL_COLOR_BLANCO` ×2; `#6495ED`→`cons!SCA2_VAL_COLOR_AZUL_CLARO`; `4022`→`tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022)` | `/interfaces/test` render antes/después idéntico |
| `SCA2_AnadirModificarGestionAplicacion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051590` | v1→v2 | 1 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_Buscador` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | v33→v34 | 37 | `PENDIENTE`→`cons!SCA2_TXT_ESTADO_SOL_PENDIENTE` ×4; `EN_ACCION`→`cons!SCA2_TXT_ESTADO_SOL_EN_ACCION`; `PDTE_FINALIZAR`→`cons!SCA2_TXT_ESTADO_SOL_PDTE_FINALIZAR`; `PDTE_MECANIZAR`→`cons!SCA2_TXT_ESTADO_SOL_PDTE_MECANIZAR`; `PENDIENTE_AUTORIZACION`→`cons!SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION` ×5; `FINALIZADA_NEG_CONTRA`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA` ×5; `CADUCADA`→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA` ×6; `CADUCADA_NEGATIVA`→`cons!SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA`; `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` ×4; `FINALIZADA_POSITIVO`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO` ×2; `FINALIZADA_NO_REQ`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ` ×2; `FINALIZADA`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA` ×2; `FINALIZADA_SIN_ANULAR`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR` ×2; `#FFFFFF`→`cons!SCA2_VAL_COLOR_BLANCO` | `/interfaces/test` render antes/después idéntico (salvo mayúsculas de `#ffffff`→`#FFFFFF`, mismo color) |
| `SCA2_D_ColorEstadoGestion` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056355` | v1→v2 | 3 | `FINALIZADA`→`cons!SCA2_TXT_ESTADO_SOL_FINALIZADA`; `PENDIENTE`→`cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE`; `#9F9F9F`→`cons!SCA2_VAL_COLOR_GRIS_MEDIO` | `/test` antes/después 7/7 iguales |
| `SCA2_DetalleErrores` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055566` | v5→v6 | 1 | `PENDIENTE`→`cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE` | `/interfaces/test` render antes/después idéntico |
| `SCA2_EliminarValorConcepto` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052837` | v1→v2 | 7 | `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM` ×3; `CE_RM_OFICINA`→`cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×3; `#ff8000`→`cons!SCA2_VAL_COLOR_NARANJA` | `/interfaces/test` render antes/después idéntico |
| `SCA2_GestionAplicacionRecords` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053292` | v1→v2 | 3 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` ×3 | `/interfaces/test` render antes/después idéntico |
| `SCA2_GestionMantenimientoMenu` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060073` | v4→v5 | 3 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO`; `#9F9F9F`→`cons!SCA2_VAL_COLOR_GRIS_MEDIO` ×2 | `/interfaces/test` render antes/después idéntico |
| `SCA2_MecanizacionPrincipal` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20060481` | v20→v21 | 6 | `VERTI`→`cons!SCA2_TXT_CONTACTO_VERTI`; `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` ×2; `#FFFFFF`→`cons!SCA2_VAL_COLOR_BLANCO` ×3 | `/interfaces/test` render antes/después idéntico |
| `SCA2_MilestoneMasDatosAltaSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053322` | v5→v6 | 4 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO`; `#F5F5F5`→`cons!SCA2_VAL_COLOR_GRIS_CLARO` ×2; `#FFFFFF`→`cons!SCA2_VAL_COLOR_BLANCO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_MilestoneMasDatosAltaSolicitud_Estrategicas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053071` | v5→v6 | 4 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO`; `#F5F5F5`→`cons!SCA2_VAL_COLOR_GRIS_CLARO` ×2; `#FFFFFF`→`cons!SCA2_VAL_COLOR_BLANCO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_ModalDescuentosVida` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051668` | v1→v2 | 1 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_TablaGestionArgumentos` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052538` | v1→v3 | 4 | `#000000`→`cons!SCA2_VAL_COLOR_NEGRO`; `#ffffff`→`cons!SCA2_VAL_COLOR_BLANCO`; `DOCS_SCA_001`→`cons!SCA2_TXT_SGD_COD_DOCUMENTAL`; `#008C47`→`cons!SCA2_VAL_COLOR_VERDE_OSCURO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_ValoresConceptoGestionConceptosyClases` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052987` | v1→v2 | 3 | `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM`; `CE_RM_OFICINA`→`cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA`; `#000000`→`cons!SCA2_VAL_COLOR_NEGRO` | `/interfaces/test` render antes/después idéntico |
| `SCA2_altaDocumento` | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5481374` | v4→v5 | 1 | `DOCS_SCA_001`→`cons!SCA2_TXT_SGD_COD_DOCUMENTAL` | `/test` antes/después 15/15 iguales |
| `SCA2_altaSGO` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051518` | v1→v2 | 1 | `SGO`→`cons!SCA2_TXT_CANAL_SGO` | sin `/test` (llama a SGO real, crearía gestiones); diff + validate idénticos |
| `SCA2_altaSGORehabilitar` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051536` | v1→v2 | 1 | `SGO`→`cons!SCA2_TXT_CANAL_SGO` | sin `/test` (llama a SGO real, crearía gestiones); diff + validate idénticos |
| `SCA2_altaSGOVida` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051554` | v1→v2 | 1 | `SGO`→`cons!SCA2_TXT_CANAL_SGO` | sin `/test` (llama a SGO real, crearía gestiones); diff + validate idénticos |
| `SCA2_calculoCanalEntrada` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052593` | v1→v2 | 7 | `CE_MF_CENTRAL_AT`→`cons!SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT`; `CE_RM_DT`→`cons!SCA2_TXT_PERFIL_CE_RM_DT`; `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM`; `CE_MF_SI24`→`cons!SCA2_TXT_PERFIL_CE_MF_SI24`; `CE_MF_SI24_FRONT`→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT`; `CE_MF_SI24_EXPERTO`→`cons!SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO`; `CE_MF_BK`→`cons!SCA2_TXT_PERFIL_CE_MF_BK` | `/test` antes/después 20/20 iguales |
| `SCA2_checkDniObligatorioAndCermProfileAccAdm` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051128` | v1→v2 | 1 | `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM` | `/test` antes/después 20/20 iguales |
| `SCA2_comprobarUserTareaActiva` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051710` | v1→v2 | 1 | `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM` | `/test` antes/después 20/20 iguales |
| `SCA2_contarErroresPendientes` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20054966` | v1→v2 | 1 | `PENDIENTE`→`cons!SCA2_TXT_ESTADO_TAREA_PENDIENTE` | `/test` antes/después 51/51 iguales |
| `SCA2_isUsuarioProceso` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051680` | v1→v2 | 4 | `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM` ×2; `CE_RM_OFICINA`→`cons!SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` ×2 | `/test` antes/después 1/1 iguales |
| `SCA2_obtenerCaducidadNivel` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051362` | v1→v2 | 2 | `CE_MF_SI24`→`cons!SCA2_TXT_PERFIL_CE_MF_SI24`; `CE_RM`→`cons!SCA2_TXT_PERFIL_CE_RM` | `/test` antes/después 41/41 iguales |
| `SCA2_obtenerMensajeErrorNSE` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051218` | v1→v2 | 1 | `4022`→`tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022)` | `/test` antes/después 56/56 iguales |
| `SCA2_posponerGestionSGC` | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5483474` | v1→v4 | 8 | `ACCADM`→`cons!SCA2_TXT_TIPO_GESTION_ACCADM` ×4; `CA`→`cons!SCA2_TXT_TIPO_GESTION_CA` ×4 | `/test` antes/después 16/16 iguales |

Total: 28 objetos modificados, 136 sustituciones.

## Constantes
- Se usan las constantes creadas por R32-A (versión 1). `#008C47` → `SCA2_VAL_COLOR_VERDE_OSCURO` (creada por R32-A tras el conflicto con `SCA2_VAL_COLOR_VERDE` = `#00E663`, que **no** se usa para este color).
- **Nueva (R32-D):** `SCA2_TXT_ESTADO_SOL_PENDIENTE` = `PENDIENTE` (TEXT, `_a-0000f099-f136-8000-9d3c-011c48011c48_5624233`, carpeta `SCA2 Rules and Constants`): estado interno de **solicitud** «PENDIENTE» (filtros y valor por defecto de `SCA2_Buscador`, etiqueta de `SCA2_textoEstadoSolicitud`). No estaba en la especificación.
- El estado PENDIENTE de **tarea** (`SCA2 Tarea.estado` en `SCA2_AltaSolicitudPage`), de **gestión** (`SCA2_D_ColorEstadoGestion`) y de **error** (`SCA2 Error.estado` en `SCA2_DetalleErrores` y `SCA2_contarErroresPendientes`) usa `SCA2_TXT_ESTADO_TAREA_PENDIENTE` (su descripción: «estado de tarea/gestión/error: pendiente»).
- `"4022"` se compara como texto → `tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022)` (la constante es INTEGER).
- En `SCA2_D_ColorEstadoGestion`, `FINALIZADA` (estado de gestión) → `SCA2_TXT_ESTADO_SOL_FINALIZADA` (mismo valor; no hay constante específica de gestión).

## Literales que NO se han tocado (a propósito)
- `"200"` en `SCA2_AltaSolicitudAnulacionPopUp` y `SCA2_Buscador`: es **código de ramo** (lista `210/200/73/101`), no prefijo de póliza NSE → no se usa `SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS`.
- `"OFICINA_DIRECTA"` en `SCA2_posponerGestionSGC`: es **clave del mapa** de respuesta `MSSObtenerOficinasFisicasNuuma` (`index(ri!detalleOficina, "OFICINA_DIRECTA")`), regla (2).
- `"AUT"` en `SCA2_posponerGestionSGC`: solo aparece en el comentario de cabecera (el código usa ACCADM/CA); no es el tipo de gestión `AU`.
- `"VERTI:"` (prefijo de token) en `SCA2_MecanizacionPrincipal`: se sustituye solo `search("VERTI", …)`.
- Otros colores/estados fuera de la especificación (p. ej. `#F7B500`, `OK`, `AUTORIZADA`, `ERROR`, `ALTA`, `DECIDIDA`, `CANCELADA`…), literales SAIL y etiquetas de interfaz.

## Pendientes
- `SCA2_altaSGO`, `SCA2_altaSGORehabilitar`, `SCA2_altaSGOVida`: sin `/test` porque llaman a SGO real (crearían gestiones); el cambio es solo `sistema: "SGO"` → `cons!SCA2_TXT_CANAL_SGO`, con diff y validación idénticos.
- `SCA2_comprobarUserTareaActiva` y `SCA2_isUsuarioProceso` están en «Se conservan»; modificados igualmente (lote D).

## Prueba UI
PENDIENTE_UI
