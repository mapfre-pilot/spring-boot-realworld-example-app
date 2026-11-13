# 52. Ronda 31 (b) — Web API «Decisora» de SCA y propuesta de migración a SCA2 con mínimo impacto

Análisis de sólo lectura en Appian TEST (26-10-2026) por LCP y lectura de reglas/interfaces de SCA y SCA2. **No se ha ejecutado ni modificado nada.** Complementa el doc 51 (grupos y permisos).

## 1. La Web API «decidir acción» de SCA (`SCA Decisora`)

### 1.1 Qué es y quién la llama

| Dato | Valor |
|---|---|
| Objeto | Web API `SCA Decisora` (uuid `211b28b3-8ab2-4dde-82c0-3248805edac1`), app SCA |
| URL | `GET https://<appian>/suite/webapi/decisora?numPoliza=…&origen=…&nuuma=…&codSolicitud=…&modo=G|C` (parámetros deducidos de los inputs de `SCA_DecisoraMain`; la expresión de la Web API no se puede leer por LCP, sólo en Designer) |
| Privada / logging | `isPublic = false` (requiere sesión o credenciales Appian), `loggingEnabled = true` (la única con log) |
| Seguridad | Administrator `SCA Administradores`; Viewer `SCA Usuarios` |
| Identidad del llamador | Previsiblemente el usuario de servicio **`sca.decisora`** (miembro de `SCA Administradores` y `SCA Alertas`); los sistemas que la invocan desde fuera son, según la documentación previa (docs 01/02), **PCA / portal interno (Decisora de anulaciones, GPC)** que redirigen al gestor a Appian al tramitar una anulación. En Appian no queda rastro de qué aplicación origina la llamada: habría que confirmarlo con el equipo de PCA. |
| Respuesta | `SCA_responseDecisora`: HTTP 200 con `Access-Control-Allow-Origin: *` y cuerpo HTML `<meta http-equiv="Refresh" content="0; URL=<uri>">` → el navegador del gestor **salta a la URL calculada**. No devuelve JSON: es un redirector. |

### 1.2 Qué hace (`SCA_DecisoraMain`)

1. **Validación de parámetros**: póliza obligatoria y ≤ 13 caracteres, `origen` obligatorio, y `NUUMA@mapfrenopro.onmicrosoft.com` (`cons!SCA_USERS_DOMAIN`) debe existir como usuario Appian. Si falla → URL del site con `entradaDecisora=true, error=true, mensajeError, codMensaje=-1`.
2. **Tipo de póliza** (`SCA_obtenerTipoPolizaDecisora`): por prefijo (`200` NSE Autos, `073/873` NSE Hogar); si no, `pBuscarPoliza` (cia 1/14/10 → wAutemis; Vida…).
3. **Solicitud/tarea existente**: `SCA_obtenerTareasSolicitudAlta` (tarea Appian viva por póliza) y `SCA_ObtenerSolicitudAnulacion` (record `SCA solicitudAnulacion`).
4. **Consulta de póliza** en CORE/SOA/Vida (`pObtenerPolizaFecha`, `consultarPolizas`, `consultarPolizaVidaRiesgo`).
5. **Validaciones de pantalla** (`SCA_validacionesPantallaDecisora`): modo `G` (gestión) o `C` (consulta, exige que CORE tenga solicitudes); ramo 210/200/73; estados de operación; inhibiciones (`mcaInh`); si ya hay tarea Appian → `redireccion = ANTIGUO`; si todo OK → `NUEVO` (pasa además `SCA_validacionesPreviasPopupAlta_Decisora`); si no → `ERROR` + `codMensaje` (1, 23, 25, -1…).
6. **Oleada** (`SCA_esOleadaDecisora`): la póliza/gestor «está en oleada» si su estructura comercial (DGT, DT, oficina directa, oficina comercial, obtenidas por `obtenerEstComNuuma`) está en los conceptos funcionales `subprocesoAppian{DGT,DT,OD,OC}Decisora` del record `SCA Concepto Funcional`, o si el NUUMA pertenece al grupo `SCA Acceso Decisora`. **Es el mecanismo de despliegue progresivo que ya tiene SCA.**
7. **URL de destino** (`SCA_crearUriDecisora`):
   - Póliza anulada / no vigente → site con error `codMensaje 1`; Vida fuera de oleada → enlace externo **GESVIDA** (`cons!SCA_TXT_LINK_GESVIDA`); clase de agente 31 (mediadores) → `null` (pendiente, «hablar con JE»).
   - Resto → `a!urlForSite(site "SCA Decidir Accion", página decidiraccion, {entradaDecisora, error, mensajeError, codMensaje, creacionSolicitud, revisionSolicitud, numPoliza, numSolicitud})`. `creacionSolicitud = true` si modo G y redirección `NUEVO/3`; `revisionSolicitud = true` si modo C o redirección `ANTIGUO/CONSULTA`.
8. La página `SCA_DecidirAccion` recibe esos parámetros como rule inputs y abre el **pop-up de la Decisora** (alta) o la revisión de la solicitud existente.

### 1.3 Otras Web APIs de SCA/SCAC llamadas desde fuera

| Web API | Alias | Quién la llama (según docs/descripción) | Impacto en la migración |
|---|---|---|---|
| `SCA Lanzar Reserva Prima`, `SCA Volcado Datos Reserva Prima` | `ejecutarRsvPrima`, `volcadoReservaPrima` | Batch externo (AWS) de reserva de prima | SCA2 ya trata la reserva de prima en el alta (R25); hay que decidir si el batch sigue en SCA o se apaga. |
| `SCA Eliminar Tareas AWS`, `SCA Eliminar Tareas BBDD` | `eliminarTareas`, `eliminarTareasBBDD` | Limpieza externa de tareas/tablas por solicitud | Sólo aplican a objetos de SCA; no tienen sentido en SCA2 (records + CORE). |
| `SCAC_GestionarAutorizacionSgo` / `STCAT` / `IA` | `modificaEstadoAutorizacion`, `2v1iyg`, `gestionarAutorizacionIA` | Callbacks de SGO / STCAT / asistente IA al resolver autorizaciones | Son de SCAC (compartidas); hay que comprobar que su lógica resuelve también autorizaciones de solicitudes SCA2 (`SCA2 CMD *`) y no sólo los PMs de SCA. **Pendiente de revisar.** |
| `SCAC LanzarDocumentsToRecord`, `SCAC Submit Uploaded File`, `SCAC_PF_*` | — | Documentos (Documentum/SGD, Plan en Familia) | Compartidas; SCA2 ya usa la ruta SGD (R29-B). |
| `SCAC Obtener Credenciales Conceptos` | `obtenerCredencialesConceptos` | Record types WEB_SERVICE | Compartida, sin cambio. |
| `SCA2_refrescarCacheCabecera`, `SCA2_guardarContacto` | `sca2-cache-cabecera`, `sca2-contacto` | Internas de SCA2 | — |

### 1.4 Qué tiene SCA2 hoy

- Site `SCA2 Anulaciones`, página `buscador`, cuya interfaz `SCA2_Buscador` **ya acepta parámetros de URL** `vista`, `numPoliza`, `idSolicitud`, `tipoAccion`, `idTarea` (alta directa con póliza, detalle de una solicitud). El buscador consulta CORE (`SCA2_consultarSolicitudes`), por lo que **ve también las solicitudes creadas desde SCA**.
- Tiene copiadas `SCA2_esOleadaDecisora`, `SCA2_ConsultaConceptosFuncionalesDecisoraRecord`, `SCA2_flagVerti` y la constante `SCA2_MENSAJE_ERROR_DECISORA`, pero **no** tiene Web API `decisora`, ni `crearUriDecisora`, ni `validacionesPantallaDecisora`, ni página `decidiraccion`.
- Las validaciones previas del alta (póliza válida, solicitud abierta, inhibiciones, acuerdos SI24…) están en `SCA2_AltaSolicitudPage` / `SCA2_AltaSolicitudAnulacionPopUp` (rondas 6–9), no en una Decisora.

## 2. Propuesta de migración a SCA2 con mínimo impacto

Principio: **no tocar a los llamadores externos ni a SCA en la primera fase**; aprovechar que CORE es la fuente de verdad común, que SCA2 reutiliza los grupos y los connected systems de SCA, y que SCA ya tiene un mecanismo de «oleada» para repartir usuarios.

### 2.1 Fase 0 — Preparación (sin impacto en usuarios)

1. Grupos y permisos según doc 51 (§5.2): anidar `SCA_CE_*` en `SCA2 Users`, replicar administradores/alertas, confirmar la generación de grupos vigente en PRO.
2. Crear en SCA2 la **Web API `SCA2 Decisora`** con el **mismo contrato** (`GET ?numPoliza&origen&nuuma&codSolicitud&modo`, misma respuesta HTML de redirección) reutilizando `SCA_DecisoraMain` en versión SCA2: validaciones → `SCA2_esOleadaDecisora` → URL `a!urlForSite(SCA2 Anulaciones.buscador, {vista: ALTA|DETALLE, numPoliza, idSolicitud})`. Así el día del corte **sólo cambia la URL** que invocan PCA/portal (`/webapi/decisora` → `/webapi/sca2-decisora`) o, mejor aún, se mantiene el alias cambiando sólo la implementación (ver 2.3).
3. Revisar las Web APIs de callback de SCAC (`GestionarAutorizacion*`) para que resuelvan autorizaciones de solicitudes SCA2. Revisar los batches externos (reserva de prima, eliminar tareas) y las caducidades (`SCA2 CMD BarridoCaducidad` ya existe).
4. Cerrar las dudas funcionales abiertas de las rondas 27–30 y la validación formal de analistas.

### 2.2 Fase 1 — Convivencia por oleadas (impacto acotado)

- **Un único punto de entrada**: la Decisora de SCA sigue recibiendo todas las llamadas. Se añade en `SCA_crearUriDecisora` (o en una regla previa) una condición «**oleada SCA2**» (nuevo concepto funcional `subprocesoAppian*SCA2` en `SCA Concepto Funcional` + grupo `SCA2 Acceso Decisora` para NUUMAs piloto) que, si se cumple **y la póliza no tiene tarea viva en SCA**, redirige al site SCA2 (`buscador?vista=ALTA&numPoliza=…` o `?idSolicitud=…`); en caso contrario, al site SCA como hoy. Es un cambio pequeño y reversible en SCA (una regla y datos de configuración), que se puede desactivar vaciando el concepto funcional.
- Regla de **no duplicidad**: una póliza con solicitud abierta en SCA (tarea Appian viva) se termina en SCA; las nuevas de usuarios en oleada nacen en SCA2. SCA2 ya bloquea el alta si CORE tiene solicitud abierta (ronda 6), y su buscador muestra las de SCA (sólo lectura/estado) al venir de CORE.
- Usuarios: los de la oleada entran a SCA2 con el mismo perfil (grupos compartidos); el resto no nota nada. Se amplía la oleada por DGT/DT/oficina igual que hizo SCA en su despliegue.
- Soporte: bandeja `Errores` de SCA2 y `SCA2 Alertas` poblados; comparación SCA/SCA2 sobre CORE para detectar divergencias.

### 2.3 Fase 2 — Corte (impacto mínimo para los llamadores)

- Opción recomendada: **mantener el alias `decisora`** y hacer que su expresión delegue en la lógica SCA2 (o poner la oleada SCA2 al 100 %). PCA/portal **no cambian nada**. Alternativa: publicar `sca2-decisora` y pedir a PCA el cambio de URL (requiere despliegue en el llamador).
- Dejar SCA sólo para **agotar las solicitudes abiertas** (tareas Appian vivas, batch de caducidad); no se migran datos: CORE ya tiene el histórico y SCA2 lo consulta.
- Retirar el acceso de alta en SCA (ocultar el pop-up de alta o devolver siempre redirección a SCA2) para evitar altas nuevas en el legado.

### 2.4 Fase 3 — Retirada de SCA

- Cuando no queden tareas vivas: apagar batches/Web APIs de SCA, **mover** los grupos `SCA_CE_*`, `SCA Acceso Decisora*` y `SCA Alertas` a la app SCA2/SCAC (mismo UUID, se conserva la sincronización con Azure; doc 51 D1), repuntar las constantes `SCA2_GRP_*` si se renombra algo, y archivar SCA.
- Vuelta atrás en cualquier fase: vaciar la oleada SCA2 / restaurar la expresión de la Decisora; SCA no se ha modificado salvo la regla de oleada.

### 2.5 Qué hay que cambiar en cada sitio (resumen)

| Dónde | Fase | Cambio |
|---|---|---|
| SCA (`SCA_crearUriDecisora` o Web API `SCA Decisora`) | 1 | Condición «oleada SCA2» → URL al site SCA2. Único cambio en SCA. |
| Record `SCA Concepto Funcional` / grupo nuevo | 1 | Conceptos `subprocesoAppian{DGT,DT,OD,OC,Nuumas}SCA2` y grupo `SCA2 Acceso Decisora`. |
| SCA2 | 0 | Web API `SCA2 Decisora` (contrato idéntico), reglas `SCA2_DecisoraMain/validacionesPantallaDecisora/crearUriDecisora` adaptadas a `buscador?vista=…`; mensajes de error en la propia página del buscador (`SCA2_MENSAJE_ERROR_DECISORA`). |
| SCA2 grupos/site | 0 | Doc 51 §5.2 (C1–C9). |
| SCAC callbacks | 0 | Verificar resolución de autorizaciones de SCA2. |
| PCA / portal | 2 (sólo si no se mantiene el alias) | Nueva URL de la Decisora. |
| GESVIDA / mediadores | 0 | Replicar en SCA2 la derivación Vida → GESVIDA y decidir la lógica de mediadores (hoy `null`). |

## 3. Dudas para analistas / PCA

1. ¿Qué aplicaciones llaman exactamente a `/suite/webapi/decisora` (PCA Decisora, GPC, portal interno, otras) y con qué usuario? ¿Pueden mantenerse con el mismo alias?
2. ¿Hay más consumidores de SCA desde fuera (enlaces directos al site `SCA_Site`/`decidir-accion` en correos DUE, favoritos, PGM)?
3. ¿Se acepta la estrategia de oleadas por DGT/DT/oficina (igual que el despliegue original de SCA) para repartir SCA → SCA2?
4. ¿Qué hacer con las solicitudes abiertas en SCA en el corte: agotarlas en SCA (propuesta) o importarlas a `SCA2 Solicitud`?
5. ¿Los batches externos de reserva de prima y eliminación de tareas deben seguir existiendo para SCA2?
6. Vida → GESVIDA y mediadores (clase 31): ¿se mantiene igual en SCA2?

Ficheros de apoyo (no versionados): `~/sca2work/r31/webapis.json`, `r31/notas.md`.
