# R33 — Investigación de objetos SCA2 sin uso real (lista verificada, nada borrado)

Fecha: 26/10/2026 · Entorno: Appian TEST · Aplicación SCA2 (638 objetos tras R32) · Sin cambios en TEST.

## 1. Método (por qué esta lista es fiable y la de R32 no lo era del todo)

| Paso | Fuente | Qué aporta |
|---|---|---|
| 1 | Dump vivo LCP de los 638 objetos (`r31/sca2dump2`) | Definiciones actuales (post-R32) |
| 2 | Alcance transitivo textual (`rule!`, `cons!`, UUID) desde site, Web APIs y record types | 50 objetos no alcanzables (análisis estático, con falsos positivos) |
| 3 | **Índice Dependientes de Designer** (`GET /objects/dependents`) para los **624 objetos** no estructurales | Consumidores reales, incluidos los que no están en la app SCA2 y los que referencian por UUID |
| 4 | Cierre iterativo: un objeto está «muerto» si no tiene dependientes o **todos** sus dependientes están muertos | Detecta clústeres huérfanos que se llaman sólo entre sí |
| 5 | Designer → Monitorización → Actividad de procesos (usuario devin, Playwright), filtro por modelo, rango «Todos» | Si un PM se ejecuta aunque nadie lo referencie (temporizadores) |
| 6 | Lectura de los literales residuales en el dump (comentarios `/* */`) | Distinguir referencia viva de referencia comentada |

Correcciones respecto a R32-A: los 14 objetos que no se pudieron borrar **sí se usan** (`SCA2_ObtenerDatos*`, `RecordToCdt…`, `setDatosGestionSGC`, constantes DUE, `renovarCacheCabecera`): sus consumidores son reglas `[SCA2]` que **viven fuera de la aplicación SCA2** (sin carpeta ni aplicación; ver §5) y la Web API `SCA2_refrescarCacheCabecera`.

## 2. Resultado global

- 624 objetos consultados en el índice de dependientes, 0 errores.
- **31 objetos sin ningún dependiente funcional** (sólo la aplicación contenedora) + 2 que sólo dependen de ellos (cierre) = **33 candidatos**.
- Record types (21), connected system, site, carpetas y los 4 documentos: todos usados o propiedad del usuario (§4).

## 3. Clasificación

### 3.1 Seguro para borrar (20) — sin dependientes, sin disparador, sin referencia viva

| Tipo | Objeto | Evidencia |
|---|---|---|
| Constante | `SCA2_FLD_DOCUMENTOS` | 0 dependientes; `CMD GenerarPdf` y `consultaDocumentoIntegracion` apuntan a la carpeta por UUID directo |
| Constante | `SCA2_TIPOS_DE_GESTION` | 0 dependientes; sólo citada en descripciones de `SCA2_TXT_TIPO_GESTION_*` |
| Constante | `SCA2_TXT_ACCIONES` | 0 dependientes (R32 pasó las acciones a `SCA2_TXT_ACCION_*` individuales) |
| Constante | `SCA2_TXT_ESTADOS_SOLICITUD_CA` | 0 dependientes (ídem, estados individuales) |
| Constante | `SCA2_TXT_GENERAR_SOLICITUD` | 0 dependientes |
| Constante | `SCA2_TXT_SUBPERFIL_CE_CONSULTA` | 0 dependientes (catálogo R32 no usado) |
| Constante | `SCA2_TXT_SUBPERFIL_CE_MF_BK_EXPERTO_SI24` | ídem |
| Constante | `SCA2_TXT_SUBPERFIL_CE_MF_SI24_CENTRAL` | ídem |
| Constante | `SCA2_TXT_SUBPERFIL_CE_RM_AGENTE` | ídem |
| Constante | `SCA2_TXT_TIPO_GESTION_AU` | ídem (AU no se usa como tipo de gestión en SCA2) |
| Constante | `SCA2_TXT_TIPO_OFICINA_DIRECTA` | ídem |
| Regla | `SCA2_DatosPolizaDinamico` | 0 dependientes, 0 referencias textuales |
| Regla | `SCA2_clientInformationAPIClients` | 0 dependientes; única referencia **comentada** en `SCA2_obtenerDatosCabeceraLive` |
| Regla | `SCA2_obtenerPolizaPrerenovada` | 0 dependientes; única referencia **comentada** en `SCA2_obtenerDatosCabeceraLive` |
| Integración | `SCA2_obtenerPolizaPrerenovadaIntegracion` | sólo la usa la regla anterior (cierre) |
| Integración | `SCA2_simularAnulacionPolizaRESTIntegracion` | 0 dependientes (la simulación va por `SCA2_simularAnulacionPolizaIntegracion`) |
| Interfaz | `SCA2_MilestoneMasDatosAltaSolicitud` | 0 dependientes |
| Interfaz | `SCA2_InduccionVertiPanel` | 0 dependientes; panel R26 retirado en R28 (referencias sólo en comentarios de `DetalleSolicitud`/`DetalleTareas`) |
| Regla | `SCA2_tareasInduccionVerti` | sólo la usaba `SCA2_InduccionVertiPanel` (cierre) |
| Regla (fuera de la app) | `SCA2_consultarErroresSolicitud` (`_a-0000f07f-6ec5-…_5505939`) | 0 dependientes; creada en R24-D «para Detalle/soporte» y nunca cableada |

**No** entra en este lote, aunque venía del mismo panel R26: `SCA2_obtenerTareaInduccion` + `SCA2_REP_TAREAS_CMP_INDUCCION` + report `SCA2 Tareas CMP Induccion` — `SCA2_DetalleTareas` la usa en vivo (`local!tareaCmp`) para encadenar el CMP.

### 3.2 Borrable, pero requiere tu OK funcional (2)

| Objeto | Situación |
|---|---|
| PM `SCA2 CMD CambiarNivel` + `cons!SCA2_PM_CMD_CAMBIAR_NIVEL` | Nadie lo arranca (0 dependientes, 0 instancias en todo el histórico de Monitorización). El cambio de nivel real lo hace `SCA2 CMD Decidir` al crear la CA de nivel 2 (R27/R29). Es un camino alternativo que nunca se ha usado. |

### 3.3 Conservar hasta decidir la fachada SCA→SCA2 (7) — piezas «Decisora» (docs 52/53)

`SCA2_esOleadaDecisora`, `SCA2_ConsultaConceptosFuncionalesDecisoraRecord` (sólo la usa la anterior), `SCA2_isUsuarioProceso`, `SCA2_comprobarUserTareaActiva`, `SCA2_obtenerTareasSolicitudAlta`, `SCA2_MENSAJE_ERROR_DECISORA`, `SCA2_RedirigirGesvida` (Vida fuera de oleada). Sin dependientes hoy; serían el equivalente SCA2 de la Web API Decisora. Si se descarta la Decisora en SCA2, pasan al lote 3.1.

### 3.4 PMs sin consumidor — decisión funcional (3 + 2 objetos arrastrados)

| PM | Dependientes | Temporizador / ejecuciones (Monitorización, rango Todos) | Recomendación |
|---|---|---|---|
| `SCA2 CMD RefrescarCacheCabecera` | ninguno | **Sí: temporizador diario 07:05** — ejecuciones 22, 23, 24, 25 y 26/10 a las 7:05 (v3.0) | **CONSERVAR** (renueva la caché de cabecera; el LCP no exporta el timer, por eso parecía huérfano) |
| `SCA2 CMD BarridoCaducidad` | ninguno | Sin timer, **0 instancias** | Es el único lanzador periódico de `SCA2 CMD Caducar` (el otro es `MarcarErrorRelanzado`, por fila). Sin él **la caducidad de solicitudes no se ejecuta nunca** en SCA2 (`SCA2 CMD Caducar` tampoco tiene ninguna instancia en el histórico; `MarcarErrorRelanzado` sí, 12 relanzamientos manuales 30/09–20/10). Decisión: (a) añadirle un temporizador como `RefrescarCacheCabecera`, o (b) borrarlo si la caducidad la hará CORE/SCA. No borrar sin decidir. |
| `SCA2 CMD RegistrarDesincronizacion` + `SCA2_RegistrarDesincronizacionForm` | ninguno (el form sólo lo usa el PM) | Sin timer; 2 ejecuciones manuales de prueba el 21/10 (R24-D) | Herramienta manual de soporte sólo arrancable desde Designer. **Borrable** si no quieres esa herramienta; si la quieres, habría que exponerla (acción en la bandeja de errores). |
| `SCA2 Batch Mecanizacion NSE` + `cons!SCA2_BOOL_BATCH_NSE` (=0) | ninguno | Sin timer; 1 ejecución de prueba 21/10 | Interruptor apagado desde R24-D. **Conservar** hasta decidir si SCA2 necesita el batch NSE que sí tiene SCA (si no, borrar PM + constante; `CMD MecanizarNSE` seguiría vivo por `SCA2_PM_CMD_MECANIZAR_NSE`). |

### 3.5 Parecían huérfanos y NO lo son (conservar)

- Web APIs `SCA2_guardarContacto` y `SCA2_refrescarCacheCabecera`: sin dependientes (son raíces), pero las invocan por HTTP las integraciones `SCA2_guardarContactoIntegracion` (← `SCA2_determinarContacto`) y `SCA2_refrescarCacheCabeceraIntegracion` (← `SCA2_obtenerDatosCabecera`, con `SCA2_USAR_WEBAPI_CACHE_CABECERA = 1`).
- Los 14 objetos de R32-A (`SCA2_ObtenerDatos*`, `SCA2_ObtenerNivelesCoberturaAutos`, `SCA2_RecordToCdtSolicitudAnulacion`, `SCA2_setDatosGestionSGC`, `SCA2_TXT_DUE_*`, `SCA2_renovarCacheCabecera`): usados por las reglas externas de §5 y por la Web API.
- `SCA2_obtenerTareaInduccion`, `SCA2_REP_TAREAS_CMP_INDUCCION`, report `SCA2 Tareas CMP Induccion`: usados por `SCA2_DetalleTareas`.
- `SCA2 CMD Caducar`, `MarcarErrorRelanzado`, `MecanizarNSE`: referenciados por sus constantes `SCA2_PM_CMD_*`.

## 4. Documentos, carpetas, record types, site, connected system

- Record types (21): todos con dependientes funcionales. `SCA2 DataBase AWS` (connected system) lo usa además el record type externo `PRBRV Expediente`.
- Documentos: `SCA2 Tareas CMP Induccion` usado (§3.5); `SCA2 Servicios SCA`, `SCA2 spa`, `SCA2 tvaBackend` subidos por GGALV10 (sept./oct. 2026), sin referencias desde objetos — **no se tocan** (son del usuario).
- Carpetas: `SCA2 Documentos`, `Autorizacion`, `Contra Anulacion`, `Accion Administrativa` referenciadas por UUID; las estructurales (`Rules and Constants`, `Artifacts`, `Application Documentation`) contienen objetos.

## 5. Hallazgo: 7 reglas `[SCA2]` fuera de la aplicación SCA2

`SCA2_notificarNivel`, `SCA2_finalizarGestionSGC`, `SCA2_construirSolicitudAnulacionAnl`, `SCA2_construirContextoSolicitudAnl`, `SCA2_construirSolicitudAnulacionAnlTraducida`, `SCA2_construirConsultaActualizarMecanizacion` (usadas por `CMD Decidir / Mecanizar / MecanizarNSE / CrearAccion / Finalizar`) y `SCA2_consultarErroresSolicitud` (sin uso) existen en TEST (LCP las lee por UUID, prefijos `_a-0000f07a…`/`_a-0000f07f…`) pero **no pertenecen a la aplicación SCA2 ni a ninguna carpeta** (`folder: null`; tampoco están en SCA ni SCAC). Riesgo: un export/import de la app SCA2 a otro entorno **no las llevaría** y los PMs fallarían. Recomendación (no ejecutada): añadir las 6 vivas a la app SCA2 / carpeta `SCA2 Rules and Constants` y borrar la séptima.

## 6. Límites

- Monitorización sólo muestra las instancias dentro del periodo de retención de TEST; «0 instancias» en `BarridoCaducidad`/`CambiarNivel` significa que no se han ejecutado en ese periodo.
- Las Decisions `SCA2_D_*` no se exportan por LCP, pero el índice de dependientes de Designer sí las contaría como consumidores si referenciaran algún candidato; ninguna lo hace.
- Consumidores fuera de Appian (enlaces desde PCA/portal) sólo aplican a Web APIs y site, que se conservan.

## 7. Procedimiento si se aprueba un lote

Backup JSON de cada objeto → `GET /objects/dependents` justo antes → DELETE sólo de lo aprobado → `GET` 404 → regresión con **solicitud nueva** (alta → CA → detalle → bandeja de errores) → informe. Ficheros de trabajo: `~/sca2work/r31/` (`dependents_all.json`, `alcance_sca2.json`, `reglas_externas_sca2.json`, `shots/act_*.png`, `designer_act*.log`).
