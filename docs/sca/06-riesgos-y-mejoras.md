# 6. Riesgos detectados y mejoras propuestas

Los hallazgos se basan en el diseño de los objetos (no en ejecución). Prioridad: **A** = seguridad/operación,
**B** = mantenibilidad con impacto alto, **C** = higiene.

## 6.1 Seguridad (A)

| # | Hallazgo | Evidencia | Propuesta |
|---|---|---|---|
| S1 | Credenciales de servicios en constantes de texto legibles desde el designer; al menos una en claro. | `SCAC_VAL_PWD_*`, `SCAC_VAL_USUARIO_*` (100 refs); `SCA_obtenerUserPassSimularPoliza` | Mover usuario/contraseña a los **connected systems** (campos seguros / Basic auth) o a secretos gestionados; que las integraciones tomen la autenticación del CS. Rotar las credenciales expuestas. |
| S2 | WS-Security compuesto manualmente en 204 integraciones. | `wsse:UsernameToken` + `wsse:Nonce` en bodies SOAP | Centralizar en una única regla `SCAC_buildWsseHeader(cs)` o en el CS; reduce la superficie de cambio si rotan las credenciales. |
| S3 | Datos personales en constantes (correo de una desarrolladora externa) y buzones de prueba (`pruebasca@`) en objetos susceptibles de pasar a PRO. | `SCA_TXT_EMAIL_DUE_PARA_ALTITUDE_TEST`, `SCA_TXT_EMAIL_ENVIO_ERRORES` | Sustituir por buzones funcionales y parametrizar vía Import Customization. |
| S4 | `SCA Decisora` es la única Web API con logging; las de borrado (`eliminarTareas`, `eliminarTareasBBDD`) no dejan traza. | Metadatos Web API | Activar logging y comprobar el grupo con permiso de invocación (service account dedicada). |
| S5 | Objeto `SCAC Prueba` (Web API) y constantes/grupos `_TEST`/`old` desplegables. | Inventario | Eliminar o mover a una app de sandbox. |

## 6.2 Arquitectura y dependencias (B)

| # | Hallazgo | Evidencia | Propuesta |
|---|---|---|---|
| A1 | **Dependencia circular SCA ↔ SCAC**: el core referencia objetos funcionales. | `SCAC_descargaDocumentoIntegracion → cons!SCA_WEBSERVICES_URL`; `SCAC_simularAnulacionPolizaIntegracion → rule!SCA_obtenerUserPassSimularPoliza`; constantes `ANL_*`/`SCA_*` dentro de SCAC | Mover esos objetos a SCAC (o parametrizarlos como inputs de la integración) para que SCAC sea desplegable de forma independiente. |
| A2 | **Acoplamiento fuerte con la app ANL** (68 refs, records `ANL Anulacion` leídos/escritos y sincronización por evento `ANL_Desbloquear`). | `SCA Mecanizacion` "Pausar hasta ANL_Desbloquear", `SCA Desbloquear Proceso Principal` | Documentar contrato ANL↔SCA; encapsular el acceso a records ANL en reglas `SCA_ANL_*` para poder cambiarlo; valorar unificar ambas apps si comparten ciclo de vida. |
| A3 | Hosts duplicados en dos librerías (`SCAC_VAL_HOST_*` y `CMP_VAL_HOST_*`) usados indistintamente. | 10 refs a `CMP_VAL_HOST_CORE7` vs 309 refs a `SCAC_*` | Elegir una fuente única de configuración por entorno. |
| A4 | Endpoints y URLs literales en reglas (~170 ficheros con URLs; ~82 con hosts PRE). | `endpoint: "PCA_CORECFSA_HTTPRouter/..."` | Externalizar los paths a constantes `SCAC_TXT_ENDPOINT_*` y limpiar comentarios con URLs de entorno. |
| A5 | Uso residual de Data Store / CDT (`SCA TM Add Transactions to Job Type`, `SCA_DSE_TM_TRANSACTION`) y de `[Deprecated] Start Process` (10 nodos). | Inventario PMs | Migrar a Records / `a!startProcess` y retirar el framework Transaction Manager si ya no se usa. |
| A6 | Record types sin relaciones, sin record actions ni vistas: el modelo relacional vive en el código. | 19 RTs, `relationships` vacío | Declarar relaciones en Appian (uno-a-uno/uno-a-muchos por `idsolicitud`) y aprovechar `a!relatedRecordData`, vistas y filtros; reduce `a!queryRecordType` manuales (31). |
| A7 | 116 integraciones SOAP con mapeo XML manual (`xpathsnippet` + `torecord` a CDTs WSDL). | Reglas `SCA_*` | Evaluar exposición REST/JSON de los servicios Core7 más usados o, al menos, una regla genérica de mapeo por operación. |

## 6.3 Mantenibilidad (B)

| # | Hallazgo | Evidencia | Propuesta |
|---|---|---|---|
| M1 | **Duplicidad Autos/Hogar vs Vida ("Estrategicas")**: 26 interfaces y varios PMs duplicados (incluso con doble versión por tilde: `Gestion SGC Estratégicas` y `Gestion SGC Estrategicas`). | Inventario | Unificar en una sola versión parametrizada por `origenPoliza`/`lineaNegocio`; eliminar la copia huérfana. |
| M2 | Interfaces monolíticas: 4.771 (`SCA_AltaSolicitudAnulacionEstrategicas`), 3.592, 3.307, 2.228, 1.587 líneas. | `wc -l` sobre SAIL | Descomponer en secciones/reglas reutilizables; extraer lógica a expression rules; objetivo < 800 líneas. |
| M3 | Process models grandes con lógica de reintento repetida (`contador++` / `success?` / `intentos = 3?`) y 16 PMs sin descripción. | `SCA Mecanizacion` (64 nodos), 3 copias de `Batch Mecanizacion NSE` | Subproceso genérico "llamar integración con reintentos"; borrar copias `(1)`/`(2)`; rellenar descripciones. |
| M4 | Estados referenciados por índice de lista (`cons!SCA_TXT_ACCIONES[7]`). | Interfaces/reglas | Reglas `SCA_esAccionContraAnular(...)` o constantes individuales por estado; evita romper el flujo al reordenar listas. |
| M5 | 112 ficheros con `TODO`/`FIXME`/`prueba`/`test`; código comentado en interfaces; PM vacío `SCA Crear CDTs desde WSDL`. | grep sobre dump | Saneamiento periódico; retirar objetos sin uso (usar "Dependents" del designer antes de borrar). |
| M6 | Constantes `TEXT` que guardan UUID de PM (`SCA_PM_BATCH_CADUCIDAD`, `SCA_PM_BATCH_RSV_PRIMA`) junto a su equivalente tipado. | Inventario constantes | Eliminar las versiones TEXT y referenciar la tipada. |
| M7 | Nombres inconsistentes (`SCA_A_adirConcepto`, `SCA_Compa_iaContrariaCatalogacion`, `SCA_SolicitudAnulaci_n`, PM con espacios extra) y mezcla de idioma en nodos. | Inventario | Convención de nombres sin caracteres especiales; renombrar en una ventana de mantenimiento. |
| M8 | Internacionalización parcial: solo 5 interfaces usan `translation!`. | grep | Decidir si i18n es requisito; si no, retirar las translation sets. |

## 6.4 Operación (B/C)

| # | Hallazgo | Propuesta |
|---|---|---|
| O1 | Batches disparados por Web API/PM sin monitorización explícita más allá de correo a `SCA Alertas`. | Panel de operación (record `SCA TareasPorPolizaAWS` + `SCA Reserva Prima`) con tareas caducadas, reintentos agotados y reservas no ejecutadas. |
| O2 | Estado duplicado entre variables de proceso y tablas (`nodorelanzar`, `tareacapturada`). | Documentar el protocolo de relanzamiento y añadir un PM de reconciliación. |
| O3 | Sin Import Customization para hosts/buzones. | Crear `SCA.properties` de importación por entorno (DEV/PRE/PRO). |
| O4 | Cinco PMs no legibles vía MCP (`'interfaceUuid' KeyError`), probablemente nodos con formularios antiguos. | Revisar esos PMs en el designer; puede indicar interfaces de tarea embebidas obsoletas. |

## 6.5 Hoja de ruta sugerida

1. **Corto plazo (sin cambios funcionales):** S1–S3 (credenciales y correos), M6, S5, borrado de copias `(1)/(2)` y
   `Estratégicas` duplicada, descripciones de PMs, Import Customization (O3).
2. **Medio plazo:** A1/A3/A4 (dirección de dependencias y configuración única), M4 (estados por nombre), O1 (panel).
3. **Largo plazo:** M1/M2 (unificación Autos-Hogar-Vida y descomposición de interfaces), A6 (relaciones de records),
   A5 (retirar Data Store/TM), A7 (modernización de integraciones SOAP), A2 (contrato con ANL).

## 6.6 Métricas de referencia (para medir la mejora)

| Métrica | Valor actual |
|---|---:|
| Interfaces > 1.500 líneas | 5 |
| Interfaces duplicadas `*Estrategicas` | 26 |
| Refs SCA → SCAC | 455 |
| Refs SCAC → SCA (inversas) | 2 |
| Ficheros con hosts de entorno hardcodeados | ~82 |
| Constantes con credenciales | 4 |
| PMs sin descripción | 16 |
| Nodos `[Deprecated] Start Process` | 10 |
| Record types con relaciones declaradas | 0 / 19 |
