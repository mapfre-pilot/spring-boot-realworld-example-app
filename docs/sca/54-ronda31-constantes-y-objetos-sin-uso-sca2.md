# 54. Ronda 31 (d) — Buenas prácticas en SCA2: constantes frente a literales y objetos sin uso

Análisis de sólo lectura (TEST, 26-10-2026) sobre un volcado completo de la aplicación SCA2 por LCP (83 interfaces, 252 reglas, 148 constantes, 17 PM, 106 integraciones, 21 record types, 2 Web API, 1 site). **No se ha borrado ni modificado nada.** Scripts y resultado bruto en `~/sca2work/r31/analiza_sca2.py` y `r31/analisis_sca2.json` (no versionados).

## 1. Criterio (buenas prácticas Appian)

- **En constantes**: todo valor que signifique algo para el negocio o la configuración y que pueda cambiar o repetirse: códigos de estado y de perfil, nombres de acciones/tipos de gestión, códigos de error de servicios, hosts/endpoints/URLs, correos, umbrales y tiempos, colores corporativos, textos legales/avisos reutilizados, punteros a PM/grupos/documentos. Una constante por concepto (o lista) y referenciada con `cons!` en todos los sitios; valores por entorno con *environment specific* + Import Customization.
- **Pueden ir «a pelo»**: los valores que son parte del lenguaje SAIL (`"STANDALONE"`, `"ROUNDED"`, `"CENTER"`…), las claves de los mapas de respuesta de un servicio (`"DATOS_PCA"`, `"COD_INT"`… — mejor encapsuladas en una única regla de mapeo), y los literales de interfaz de un solo uso (etiquetas, títulos). Las etiquetas repetidas (`ACEPTAR` ×19, `CANCELAR` ×22) son aceptables en SAIL; si se quisiera centralizarlas, lo correcto es un *Translation Set*, no constantes.
- **Objetos sin uso**: borrar (tras comprobar «Dependientes» en Designer) todo lo que no tenga consumidores: evita falsos positivos en análisis, despliegues más grandes y confusión. Lo temporal (`_test`, `tmp*`) no debe llegar a PRO.

En SCA2 el estado es el que describe el usuario: **muchos valores de negocio están repetidos como literal** (heredado de SCA, cuyo código se copió tal cual) y hay **constantes de catálogo que existen pero no se usan**, además de **~70 objetos sin consumidor**.

## 2. Constantes de SCA2 que no usa nadie (19)

| Constante | Tipo | Valor | Qué hacer |
|---|---|---|---|
| `SCA2_PM_BATCH_CADUCIDAD` | TEXT | `0002eea4-5cfb-8000-1a24-7f0000014e7a` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_TXT_EMAIL_DUE_PARA_ALTITUDE` | EMAIL_ADDRESS | `JOSPENA@mapfre.com` | Configuración de entorno heredada de SCA → revisar: usar (DUE/errores) o borrar; `SCA2_TXT_URL_HOST` apunta a DEV |
| `SCA2_TXT_URL_HOST` | TEXT | `https://mapfrespain-dev.appiancloud.com` | Configuración de entorno heredada de SCA → revisar: usar (DUE/errores) o borrar; `SCA2_TXT_URL_HOST` apunta a DEV |
| `SCA2_TXT_URL_LANZARDECISION_ANTIGUO` | TEXT | `http://wportalinterno.pre.mapfre.net/PCA_FRON` | Configuración de entorno heredada de SCA → revisar: usar (DUE/errores) o borrar; `SCA2_TXT_URL_HOST` apunta a DEV |
| `SCA2_PM_CMD_BARRIDO_CADUCIDAD` | PROCESS_MODEL | `0000f06f-4f69-8000-671e-7f0000014e7a` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_TXT_GENERAR_SOLICITUD` | TEXT | `Generar Solicitud` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |
| `SCA2_TXT_EMAIL_ENVIO_ERRORES` | EMAIL_ADDRESS | `pruebasca@mapfre.com` | Configuración de entorno heredada de SCA → revisar: usar (DUE/errores) o borrar; `SCA2_TXT_URL_HOST` apunta a DEV |
| `SCA2_TIPOS_DE_GESTION` | TEXT | `['ACCADM', 'CA', 'AU']` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |
| `SCA2_MENSAJE_ERROR_DECISORA` | TEXT | `['La póliza no está actualmente vigente. Es n` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |
| `SCA2_REP_PROCESS_MECANIZACIONES` | DOCUMENT | `_a-0000ecf1-045c-8000-9c82-011c48011c48_15634` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_TXT_DUE_MENSAJE` | TEXT | `['Texto pendiente de expertos', 'Texto pendie` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |
| `SCA2_PLANTILLA_CONTRATO_COMPRA_VENTA` | DOCUMENT | `_a-0000f012-d2f8-8000-9cbe-011c48011c48_19745` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_TXT_EMAIL_DUE_PARA_EXPERTOS` | EMAIL_ADDRESS | `JOSPENA@mapfre.com` | Configuración de entorno heredada de SCA → revisar: usar (DUE/errores) o borrar; `SCA2_TXT_URL_HOST` apunta a DEV |
| `SCA2_FLD_CLIENTE_TIPO_VALOR` | FOLDER | `_a-0000eba7-4ece-8000-9c59-011c48011c48_12352` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_ARTIFACTS_FOLDER` | FOLDER | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION` | PROCESS_MODEL | `0000f095-791c-8000-d602-7f0000014e7a` | Puntero a objeto sin consumidor (PM/documento/carpeta) → borrar si el objeto apuntado tampoco se usa |
| `SCA2_TXT_ACCIONES` | TEXT | `['AUTORIZACION', 'AUTORIZACION NIVEL 2', 'AUT` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |
| `SCA2_TEXTOS_GENERAR_SOLICITUD_POPUP_ESTRATEGICAS` | TEXT | `['Se ha producido un error en la creación de ` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |
| `SCA2_TXT_ESTADOS_SOLICITUD_CA` | TEXT | `['Pendiente', 'Finalizada positivamente', 'Fi` | Catálogo de textos copiado de SCA sin usar → o se usa para sustituir literales (ver §3) o se borra |

Nota: `SCA2_GRP_USUARIOS` no aparece porque los PM la referencian en *Modify Process Security*. `SCA2_PM_BATCH_CADUCIDAD` es de tipo TEXT con el UUID de un PM de SCA (mismo defecto que en SCA).

## 3. Literales de negocio repetidos que deberían ser constante

Recuento = nº de objetos distintos (interfaces + reglas) que contienen el literal. Entre paréntesis, la constante que **ya existe** con ese valor y no se usa.

| Prioridad | Dominio | Literales (objetos) | Propuesta |
|---|---|---|---|
| Alta | Perfiles / subperfiles | `CE_RM` (21), `CE_RM_OFICINA` (12), `CE_MF_SI24_EXPERTO` (8), `CE_MF_RECIBOS_CCC` (7), `CE_MF_SI24` (7), `CE_MF_RECIBOS_CCR` (6), `CE_MF_SI24_FRONT` (6), `CE_MF_RECIBOS` (4), `CE_MF_CENTRAL_AT` (4), `CE_MF_BK` (4), `CE_MF_CONTROL` (3) | Constantes `SCA2_TXT_PERFIL_*` / `SCA2_TXT_SUBPERFIL_*` (o una lista `SCA2_TXT_PERFILES` como `SCA_TXT_GRP_TODOS`), y que las reglas de perfil las usen en vez del nombre del grupo (ver doc 51 D3). |
| Alta | Estados de solicitud / tarea | `FINALIZADA` (11), `PENDIENTE` (8), `CADUCADA` (7, en `SCA2_TXT_ESTADOS_MECANIZACION`), `FINALIZADA_POSITIVO` (6), `EN_ACCION` (5), `FINALIZADA_SIN_ANULAR` (5), `CADUCADA_NEGATIVA` (5), `FINALIZADA_NEG_CONTRA` (4), `FINALIZADA_NO_REQ` (4), `PENDIENTE_AUTORIZACION` (4), `PDTE_FINALIZAR` (3) | Constantes `SCA2_TXT_ESTADO_*` (una por estado) o completar `SCA2_TXT_ESTADOS_SOLICITUD_CA` (hoy sin uso) y referenciar por índice con nombre; `SCA2_textoEstadoSolicitud` / `SCA2_colorEstadoSolicitud` / buscador / detalle deben leer de ahí. |
| Alta | Acciones y tipos de gestión | `CONTRA ANULAR` (4), `MECANIZAR` (4), `AUTORIZACION` (4), `CONTRAANULAR` (3), `ACCIONES ADMINISTRATIVAS` (3) → ya en `SCA2_TXT_ACCIONES` (sin uso); `ACCADM` (3) → ya en `SCA2_TIPOS_DE_GESTION` (sin uso); `VENCIMIENTO` (3) | Usar las constantes existentes en `SCA2_D_TiposGestiones`, `SCA2_DetalleSolicitud`, `SCA2_DetalleTareas`, `SCA2_altaGestionCore`, `SCA2_AccionesAdministrativasPrincipal`, `SCA2_posponerGestionSGC`, `SCA2_subirDocumentosGD`. |
| Alta | Códigos de servicios externos | `DOCS_SCA_001` (4) y `QUERY_SCA_AGD_001` (4) (SGD/Documentum), `4022` (4, código de error NSE), `200` (5, prefijo NSE Autos / código HTTP), `SGO` (5, en `SCA2_TXT_CANALES_ENTRADA_DESC`), `BAJA TEMPORAL` (3, en `SCA2_TXT_CAUSA_ANULACION`), `BAJA VEHICULO` (3), `OFICINA_DIRECTA` (3) | Constantes `SCA2_TXT_SGD_*`, `SCA2_VAL_NSE_COD_ERROR_*`, `SCA2_TXT_PREFIJO_NSE_AUTOS`; usar las de causa/canal existentes. |
| Media | Colores | `#000000` (33), `#FFFFFF`/`#ffffff` (19), `#F5F5F5` (8), `#9F9F9F` (7, ya `SCA2_VAL_COLOR_GRIS_MEDIO`), `#008C47` (6), `#6495ED` (6), `#ff8000` (4), `#E46B15` (3), `#BE0F0F` (3), `#0D82BD` (3) | Completar la paleta `SCA2_VAL_COLOR_*` (ya hay rojo y gris medio) y sustituir; los colores de estado deben salir de `SCA2_colorEstadoSolicitud`/`SCA2_D_ColorEstadoGestion` únicamente. |
| Baja | Claves de mapas de servicio | `DATOS_PCA` (10), `DATOS_POLIZA` (9), `DATOS_TO` (6), `COD_INT` (5), `DATOS_STR_COMER`, `NUM_MATRICULA`, `DATOS_VEHIC`, `COD_RAMO`, `COD_CIA`, `COD_ACUERDO`, `CLAVE_PRODUCCION`, `COD_MARCA/MODELO/TIPO_VEHIC`, `FEC_PRIM_MATRIC`, `NUM_DOCUM`, `TELEFONO MOVIL` (3-4 cada una, en `SCA2_AltaSolicitudPage`, `SCA2_construirContextoAlta`, `SCA2_obtenerDatosCabeceraLive`, `SCA2_CalcularListaParCargaSGCOnline`, `SCA2_ModalClaveProduccion`) | No hacen falta constantes: concentrar el acceso a la respuesta de `consultarPolizas`/cabecera en una única regla de mapeo (`SCA2_construirContextoAlta` ya lo hace en parte) y que el resto consuma el mapa resultante. |
| Baja | Etiquetas UI repetidas | `ACEPTAR` (19), `CANCELAR` (22), `" - "` (9) | Aceptable; si se quiere centralizar, Translation Set. |

No se han encontrado URLs, hosts ni correos «a pelo» en SAIL de SCA2 (están en constantes `SCA2_TXT_*`/`SCAC_VAL_HOST_*`); sí hay una constante de host apuntando a DEV (`SCA2_TXT_URL_HOST`) sin uso.

## 4. Objetos de SCA2 sin ningún consumidor (71)

Criterio: ningún otro objeto de la app (interfaces, reglas, integraciones, PM —por nombre `rule!` o por UUID—, record types, Web APIs, site) los referencia. **Limitación**: las *Decisions* `SCA2_D_*` no se pueden leer por LCP, y no se ven consumidores externos a la app (SCA/SCAC no deberían llamar a SCA2); antes de borrar, comprobar «Dependientes» en Designer. Los que son tareas de PM o páginas de site ya están excluidos.

- **Interfaz/integración sin consumidor** (11): `SCA2_AltaSolicitud (interface)`, `SCA2_BuscarSolicitudClientePoliza (interface)`, `SCA2_CalcularListaParCargaSGCOnline (expression rule)`, `SCA2_CargaGcOnLine (integration)`, `SCA2_DatosCabecera (interface)`, `SCA2_DocumentosAccion (interface)`, `SCA2_GenerarSolicitudPopup (interface)`, `SCA2_InterfazErrorDocumentos (interface)`, `SCA2_MensajeCancelarContraAnulacion (interface)`, `SCA2_RedirigirGesvida (interface)`, `SCA2_VisualizarDocumentoContraanular (interface)`
- **Variante «Estrategicas» copiada de SCA no cableada** (4): `SCA2_BuscadorTablaEstrategicas (interface)`, `SCA2_bloquearPolizaEnCentralEstrategicas (expression rule)`, `SCA2_mapearDatosDecidirAccionEstrategicas (expression rule)`, `SCA2_setDatosGestionSGCEstratégicas (expression rule)`
- **Copia de SCA (o pieza de fase 1) sin consumidor en SCA2** (52): `SCA2_GuardarDocumentos (expression rule)`, `SCA2_GuardarImprimir (expression rule)`, `SCA2_ObtenerCredencialesConceptos (integration)`, `SCA2_ObtenerDatosBasicosSolicitud (expression rule)`, `SCA2_ObtenerDatosPerfilesPca (expression rule)`, `SCA2_ObtenerDatosPolizaAutos (expression rule)`, `SCA2_ObtenerDatosPolizaHogar (expression rule)`, `SCA2_ObtenerDatosPolizaVida (expression rule)`, `SCA2_ObtenerDatosProductorBBDD (expression rule)`, `SCA2_ObtenerDatosSolicitud (expression rule)`, `SCA2_ObtenerDocumentosArgumentos (integration)`, `SCA2_ObtenerMapaPoliza (expression rule)`, `SCA2_ObtenerNivelesCoberturaAutos (expression rule)`, `SCA2_RecordToCdtSolicitudAnulacion (expression rule)`, `SCA2_TM_ObtenerTransaccion (expression rule)`, `SCA2_aceptarAutorizacion (expression rule)`, `SCA2_bloquearPolizaEnCentral (expression rule)`, `SCA2_calcularDocumentosASubir (expression rule)`, `SCA2_calculoSumasAseguradas (expression rule)`, `SCA2_catCargarDesdeCore (expression rule)`, `SCA2_comprobarEliminarDocumentos (expression rule)`, `SCA2_comprobarUserTareaActiva (expression rule)`, `SCA2_configurarDatosContextoSolicitud (expression rule)`, `SCA2_esOleadaDecisora (expression rule)`, `SCA2_esPropietarioProvisional (expression rule)`, `SCA2_extraerCodClienteNIF (expression rule)`, `SCA2_gestionSegunOrigen (expression rule)`, `SCA2_guardarObservaciones (expression rule)`, `SCA2_guardarTrazabilidad (expression rule)`, `SCA2_isUsuarioProceso (expression rule)`, `SCA2_liberarTarea (expression rule)`, `SCA2_mapSalidaRespuestaAccAdm (expression rule)`, `SCA2_mapSalidaRespuestaAutorizacion (expression rule)`, `SCA2_mapSalidaRespuestaCA (expression rule)`, `SCA2_mapSalidaRespuestaFinalizatrCA (expression rule)`, `SCA2_mensajeCorreoElectronico (expression rule)`, `SCA2_monitorizarSolicitud (integration)`, `SCA2_monitorizarSolicitudRegla (expression rule)`, `SCA2_obtenerDescuentos (expression rule)`, `SCA2_obtenerFormaDeCobro (expression rule)`, `SCA2_obtenerOficinas (expression rule)`, `SCA2_obtenerOtrasSolicitudesCabecera (expression rule)`, `SCA2_obtenerSituacionRiesgo (expression rule)`, `SCA2_obtenerTareasSolicitudAlta (expression rule)`, `SCA2_pmPorComando (expression rule)`, `SCA2_posponerTarea (expression rule)`, `SCA2_propietarioParaCaducidad (expression rule)`, `SCA2_relanzarError (expression rule)`, `SCA2_renovarCacheCabecera (expression rule)`, `SCA2_setDatosGestionDatosPoliza (expression rule)`, `SCA2_setDatosGestionSGC (expression rule)`, `SCA2_simularAnulacionPolizaRest (expression rule)`
- **Temporal / pruebas** (4): `SCA2_S2_diagnosticoSolicitud (expression rule)`, `SCA2_calcularCaducidadNivel_test (expression rule)`, `SCA2_construirEntradaReglas_test (expression rule)`, `SCA2_tmpDevinQuery (expression rule)`

Candidatos claros a borrar ya: los temporales (`SCA2_construirEntradaReglas_test`, `SCA2_calcularCaducidadNivel_test`, `SCA2_tmpDevinQuery`, `SCA2_S2_diagnosticoSolicitud`) y las variantes «Estrategicas»/copias de SCA que nunca se cablearon (`SCA2_GenerarSolicitudPopup`, `SCA2_RedirigirGesvida`, `SCA2_BuscadorTablaEstrategicas`, `SCA2_DatosCabecera` —se usa `SCA2_DatosCabecera_Estrategicas`—, `SCA2_AltaSolicitud`, `SCA2_mapearDatosDecidirAccionEstrategicas`, `SCA2_setDatosGestionSGCEstratégicas`, `SCA2_bloquearPolizaEnCentral*`, `SCA2_ObtenerDatosPoliza{Autos,Hogar,Vida}`, `SCA2_mapSalidaRespuesta*`…). Los relacionados con la Decisora (`SCA2_esOleadaDecisora`, `SCA2_isUsuarioProceso`, `SCA2_comprobarUserTareaActiva`, `SCA2_obtenerTareasSolicitudAlta`) **conviene conservarlos** si se aprueba la fachada SCA→SCA2 (docs 52/53), porque son justo las piezas que se necesitarán.

Los objetos de la ronda 26 que quedaron sin uso funcional (`SCA2_InduccionVertiPanel`, `SCA2_tareasInduccionVerti`, `SCA2_obtenerTareaInduccion`, constantes `SCA2_PM_CMP_*`) **no** aparecen en la lista porque siguen referenciándose entre sí; su borrado sigue pendiente de tu decisión (doc 42).

## 5. Propuesta de limpieza (por lotes, con regresión)

1. **Lote 0 (sin riesgo)**: borrar temporales y copias no cableadas (§4) tras «Dependientes» en Designer; borrar las constantes sin uso que no vayan a servir para el lote 1; corregir `SCA2_PM_BATCH_CADUCIDAD` (tipo PM) o borrarla.
2. **Lote 1 (perfiles, estados, acciones)**: crear/usar las constantes y sustituir literales por dominio, un dominio por sesión hija, con regresión por LCP (`/test` de las reglas tocadas con solicitudes reales) y UI con solicitud nueva.
3. **Lote 2 (códigos externos y colores)**.
4. Regla para lo nuevo: en las revisiones (y en el analizador estático, regla «literal repetido ≥3 objetos») no admitir literales de negocio nuevos.

## 6. Decisiones que necesito

1. ¿Borro ya el lote 0 (temporales + copias no cableadas) y las constantes sin uso de catálogo que no se vayan a usar?
2. ¿Conservo las piezas «Decisora» para la fachada SCA→SCA2?
3. ¿Arranco el lote 1 (perfiles/estados/acciones) con sesiones hijas?

## 7. Resultado de la ronda 32 (ejecución, 26-10-2026)

Coordinación en `docs/sca/pruebas/coordinacion-ronda32.md`; informes `r32-a-constantes-y-borrado.md`, `r32-b-literales-lote.md`, `r32-c-*.md`, `r32-d-*.md`.

| Hija | Resultado | Pruebas |
|---|---|---|
| R32-A (commit 7086e38) | 58 constantes nuevas (incl. `SCA2_VAL_COLOR_VERDE_OSCURO`=#008C47 porque `SCA2_VAL_COLOR_VERDE` ya existía con #00E663; `SCA2_VAL_NSE_COD_ERROR_4022` INTEGER = póliza PRRA/deficitaria). **66 objetos borrados** (52 reglas/interfaces/integraciones + 14 constantes, backups JSON), sin tocar PMs. 14 del lote no borrados por tener dependientes indirectos (`SCA2_ObtenerDatos*`, `SCA2_ObtenerNivelesCoberturaAutos`, `SCA2_RecordToCdtSolicitudAnulacion`, `SCA2_setDatosGestionSGC`, 3 constantes DUE usadas por `SCA2_notificarNivel`, `SCA2_renovarCacheCabecera` usada por la Web API). Candidatos pendientes: PMs `SCA2 CMD BarridoCaducidad` y `SCA2 CMD RegistrarDesincronizacion` (confirmar temporizador). `SCA2_PM_BATCH_CADUCIDAD` apuntaba a un PM de SCA. | UI solicitud nueva 15788370 (alta → CA → detalle) OK; bandeja sin errores de esa solicitud. |
| R32-B (commit c1ec9f6) | 28 objetos, 228 literales → constantes | 12 reglas `/test` iguales; UI 15788366 alta → CA positiva → buscador/detalle/notificaciones OK; modales y Verti/vencimiento sólo validate. |
| R32-C (commit e00dfca) | 27/28 objetos, 188 literales → 40 constantes | 8 reglas `/test` iguales (50 casos); 18 interfaces render OK; UI 15788368 alta/AA/detalle OK; páginas admin y catalogación/Verti sólo render. |
| R32-D | 28 objetos, 136 literales → constantes | 11 reglas `/test` 275/275 iguales; 14 interfaces render OK; UI 15788369 alta/detalle OK; **servicio de decisión devolvió ERROR** (preexistente desde el 15-21/10, 3 `DECISION_ERROR` en bandeja), por lo que CA y mantenimiento no se vieron. |

Hallazgo corregido respecto a §4: el análisis de «sin referencias» no seguía referencias indirectas (reglas usadas sólo desde otras reglas usadas por PM); los 14 objetos afectados se conservan. Pendientes: decisión sobre los 2 PMs sin consumidores y revisar el `DECISION_ERROR` del motor en TEST (ajeno a la ronda).
