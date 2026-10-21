# 41. Diseño detallado — lógica de servicios legacy llevada a Appian (fase 1, sin tocar la BD MR01/CORE ni la funcionalidad)

**Fecha:** 20-10-2026 · **Estado:** propuesta pendiente de OK; **ningún objeto Appian modificado**. Contexto y origen de cada lógica en [40-analisis-servicios-legacy-sca.md](40-analisis-servicios-legacy-sca.md).

Reglas del encargo: (1) no se toca la base de datos CORE (MR01/Oracle MES) ni los servicios Core7: siguen siendo el maestro y SCA2 sigue escribiendo en ellos como hoy; (2) no cambia la funcionalidad visible: las pantallas y los `CMD` hacen lo mismo, sólo cambian *de dónde* sale el dato o *cómo* se calcula; (3) todo lo nuevo se crea como objetos nuevos (`SCA2_*`) y se conecta en un único punto, de forma que se pueda volver atrás cambiando una constante.

## 1. Caducidad de tarea (`determinarCaducidad` → regla Appian)

**Situación actual en SCA2 (verificada en los objetos):** el record `SCA2 Solicitud` tiene `caducidadTarea`, `fechaDietario` y `contadorPosponer`. `SCA2_configurarDatosContextoSolicitud` los inicializa a `null` en el alta; `CMD CrearAccion` y `CMD Posponer` escriben `caducidadTarea`; `SCA2_posponerTarea` pone `fechaDietario = now()`; `CMD Decidir` **no** calcula caducidad; `CMD Caducar` caduca cuando `caducidadTarea`/`fechaDietario` vencen. Para SGC, `SCA2_setDatosGestionSGC(+Estratégicas)` recibe `datosSGCCaducidad {propietario, fechaVencimiento, mismoNivel, fechaCaducidadAnterior}` y hoy delega el cálculo en la mediación.

**Lógica legacy (Java `cDeterminarCaducidad`, mediación SMED2):** `caducidad = hoy + N` donde `N = caducidad.dias.propietario` si el usuario es propietario, si no `caducidad.dias.no.propietario`; si la tarea sigue en el **mismo nivel** y existe caducidad anterior, se conserva la anterior; formato CORE `dd/MM/yyyy`.

**Objetos nuevos**
| Objeto | Tipo | Detalle |
|---|---|---|
| `SCA2_DIAS_CADUCIDAD_PROPIETARIO` | Constante (Number, por entorno) | Valor a confirmar con OT (propiedad legacy `caducidad.dias.propietario`). |
| `SCA2_DIAS_CADUCIDAD_NO_PROPIETARIO` | Constante (Number, por entorno) | Ídem `caducidad.dias.no.propietario`. |
| `SCA2_calcularCaducidadTarea(propietario: Boolean, mismoNivel: Boolean, fechaCaducidadAnterior: Date, fechaBase: Date)` | Regla → Date | `if(and(mismoNivel, not(isnull(fechaCaducidadAnterior))), fechaCaducidadAnterior, a!defaultValue(fechaBase, today()) + if(propietario, cons!…_PROPIETARIO, cons!…_NO_PROPIETARIO))`. Sin llamadas externas. |
| `SCA2_calcularCaducidadTarea_test` | Casos `a!test` (4) | propietario/mismo nivel; propietario/cambio nivel; no propietario/mismo nivel sin anterior; no propietario/cambio nivel. |

**Dónde se conecta (sin cambiar comportamiento):** `SCA2_setDatosGestionSGC` y `…Estratégicas`: rellenar `datosSGCCaducidad.fechaCaducidad` con la regla cuando venga vacía (hoy el mapa viaja sin calcular). `CMD CrearAccion`, `CMD CambiarNivel` y `CMD Posponer`: usar la regla para `caducidadTarea` en lugar del valor que ponen hoy, con `mismoNivel = (nivel origen = nivel destino)` y `fechaCaducidadAnterior = pv!sol.estado.caducidadTarea`. Mientras no se confirmen los días con OT, las constantes toman el valor que hoy produce el flujo (comparado con SCA) para que el resultado sea idéntico.

**Pruebas:** `a!test` de la regla; una solicitud nueva por combinación en TEST comparando `caducidadTarea` y la fecha de caducidad enviada a SGC con la que produce SCA para la misma póliza/usuario.

## 2. Propietario de la póliza y carterización (`comprobarPropietario` ESB → regla Appian)

**De dónde sale hoy la carterización en SCA2 (verificado):**
- `SCA2_obtenerDatosCabecera` llama al REST `SCA2_consultarCabecera` (`es_pca_gestionartareas_bbe-web/esp/api/1.0/cargaCabecera` con `invocarCarterizacion: "true"`, `invocarEstruage: "true"`) y lee `respuestaCarterizacion.pcodretorno` (**0 = carterizado, 1 = no**) y `pnuuma` (nuuma del carterizador); lo guarda en `SCA2 Datos Cabecera.clienteCarterizado` («Sí/No») y `clienteNuumapropietario`.
- En el legacy la carterización se obtenía de `IGestionarCarterizacion.comprobarCliente` (Core7 `Sgc_CCFSAIGestionarCarterizacion_HTTPRouter`); en Appian existe esa integración como `SCAC_comprobarClienteCarterizadoIntegracion` (sin uso). Es el mismo dato con el mismo `pcodretorno`.
- La **propiedad de clave/póliza** sale de Estruage: `SCA2_consultaPropiedadClave(codCia, nuuma, claveProd)` → `MCA_PROPIEDAD_POLIZA`, `MCA_PROPIEDAD_CLAVE`. `SCA2_nuumaEsPropietario` ya la usa, pero con **AND** de los dos flags (el legacy usa **OR** y además carterización = 0).
- La mediación `IObtenerInformacionSCA.comprobarPropietario` (la que llama `SCA2_comprobarPropietario` desde `setDatosGestionSGC`) hace internamente: Estruage `consultaPropiedadClave` + carterización `comprobarCliente` + TRON `consultarPolizas`, y devuelve `propietario`.

**Objetos nuevos**
| Objeto | Detalle |
|---|---|
| `SCA2_esPropietarioPoliza(codCia, nuuma, claveProd, codRetornoCarterizacion, mcaPropiedadClave, mcaPropiedadPoliza)` → Boolean | Regla **pura** con la fórmula legacy: `or(tostring(codRetornoCarterizacion) = "0", mcaPropiedadClave = "S", mcaPropiedadPoliza = "S")`. Si se le pasan los flags ya calculados (desde `Datos Cabecera`) no llama a nada; si vienen vacíos, los obtiene con `SCA2_consultaPropiedadClave` y con la carterización de `SCA2 Datos Cabecera` (o, si no hay cabecera, `SCAC_comprobarClienteCarterizadoIntegracion`). |
| `SCA2_propietarioParaCaducidad(servicioDecision, resultadoSD, codPerfil, esPropietario)` → Boolean | Casos N1/N2: `esPropietario`; N3: `resultadoSD = "ENVIAR A NIVEL 2" and codPerfil = "CE_RM"`; N4: `resultadoSD = "ENVIAR_A_NIVEL_3"`. Es la lógica de `cPropietarioYNivel`. |
| `SCA2_USAR_PROPIETARIO_APPIAN` | Constante Boolean (interruptor): `true` → regla; `false` → `SCA2_comprobarPropietario` (ESB) como hoy. Permite comparar y volver atrás. |

**Dónde se conecta:** en `SCA2_setDatosGestionSGC` / `…Estratégicas` el `local!setPropietario` pasa a `if(cons!SCA2_USAR_PROPIETARIO_APPIAN, rule!SCA2_esPropietarioPoliza(...), <llamada actual>)`. `SCA2_nuumaEsPropietario` (usado en `SCA2_ContraAnulacionOpciones`) **no se toca** en esta fase: se documenta la diferencia AND/OR y se decide con el analista si debe alinearse con el legacy.

**Pruebas:** durante una semana la regla y el ESB se evalúan los dos y se registra en `SCA2 Transicion.detalle` si coinciden (modo sombra); casos: propietario de clave, carterizador no propietario, SI24, CE_RM en N3, usuario ajeno. Ahorro: una llamada ESB por gestión SGC y un servicio legacy menos.

## 3. Catálogos CORE cacheados en Aurora (lectura) — CORE sigue siendo maestro

**Qué se cachea y quién lo lee hoy (SOAP a Core7 en cada apertura):** `consultarCausa`, `consultarMotivo`, `consultarDetalle` (`SCA2_AltaSolicitudPage`), `consultarTipoArg` (`ContraAnulacionOpciones`, `GestionArgumentos`, `AltaGestionArgumento`), `consultarConcepto` (mantenimiento de conceptos y `AltaGestionArgumento`), `obtenerOficinasFisicasNuuma` (BDEC; Acciones Administrativas, Anulación fuera de norma, Contra Anulación).

**Diseño**
| Objeto | Detalle |
|---|---|
| Tablas Aurora `sca2_cat_causa`, `sca2_cat_motivo`, `sca2_cat_detalle`, `sca2_cat_tipo_argumento`, `sca2_cat_concepto`, `sca2_cat_valor_concepto`, `sca2_cat_oficina_nuuma` | Mismas columnas que devuelve cada operación + `fechaRefresco`, `origen`. Clave natural del CORE (`codCausa`, `codMotivo`, …) + `cia/ramo` donde aplique. En la **BD de SCA2 (Aurora)**, nunca en MR01. |
| Record types `SCA2 Cat Causa`, … | Fuente DB (`SCA2 DataBase AWS`), sincronizados. |
| PM `SCA2 CAT Refrescar Catalogos` | Programado (diario, 06:00) y lanzable desde las pantallas de mantenimiento tras guardar: llama a las integraciones actuales (`SCA2_consultarCausa`, …) y hace *upsert* en las tablas; si la integración falla se conserva el contenido anterior y se anota en `SCA2 Error`. |
| Reglas `SCA2_catCausas(cia, ramo)`, `SCA2_catMotivos(causa)`, `SCA2_catDetalles(motivo)`, `SCA2_catTiposArgumento(...)`, `SCA2_catConceptos(...)`, `SCA2_catOficinasNuuma(nuuma)` | `a!queryRecordType` sobre el record; si el record está vacío o `fechaRefresco` > 48 h, hacen *fallback* a la integración actual (así nunca se pierde funcionalidad). |
| `SCA2_USAR_CATALOGOS_AURORA` | Constante Boolean para activar/desactivar por entorno. |

**Dónde se conecta:** las interfaces listadas cambian `rule!SCA2_consultarCausa(...)` por `rule!SCA2_catCausas(...)`, etc.; la firma de salida se mantiene (misma estructura que el CDT actual) para no tocar el resto de la pantalla. Los mantenimientos (`GestionConceptosYClases`, `AltaGestionArgumento`) siguen escribiendo en CORE con `guardarConcepto/guardarTipoArg` y, al terminar, lanzan el refresco.

**Pruebas:** comparar lista a lista (orden y textos) la salida del record frente a la SOAP para 3 compañías/ramos; medir tiempo de apertura del Alta antes/después.

## 4. Cabecera con caché temporal de una jornada (`cargarCabecera` / `consultarCabeceraRest`)

**Situación actual:** `SCA2_obtenerDatosCabecera` se llama desde 9 interfaces y desde `CMD Alta`; cada llamada vuelve a invocar el REST `cargaCabecera` + TRON/NSE/Vida + API Clients + Estruage + productor + reserva de prima + siniestros. El record `SCA2 Datos Cabecera` (44 campos) ya existe y se rellena en el alta.

**Diseño (caché temporal, no cambia lo que se muestra)**
| Objeto | Detalle |
|---|---|
| Campos nuevos en `SCA2 Datos Cabecera`: `fechaCache` (Date and Time), `validaHasta` (Date and Time), `origenCache` (Text) | `validaHasta = fin de la jornada` (constante `SCA2_HORAS_CACHE_CABECERA`, por defecto 8 h, o fin del día natural: a decidir). |
| `SCA2_obtenerDatosCabeceraCache(idSolicitud, numPoliza, nuuma, forzarRefresco)` | Si existe fila con `validaHasta > now()` y `forzarRefresco = false` → devuelve el record; si no → llama a `SCA2_obtenerDatosCabecera` (la actual, sin cambios), hace *upsert* en el record y devuelve el resultado. Misma estructura de salida que la regla actual. |
| Botón «Actualizar datos» (ya existe el patrón de refresco en Detalle) | Pone `forzarRefresco = true`. Los `CMD` que cambian estado (Mecanizar, Finalizar) invalidan la caché (`validaHasta = now()`). |
| `SCA2_USAR_CACHE_CABECERA` | Constante Boolean para activar/desactivar. |

**Dónde se conecta:** las 9 interfaces y `CMD Alta` sustituyen la llamada por `SCA2_obtenerDatosCabeceraCache(...)`. Los datos que deben ser siempre en vivo (estado de póliza para mecanizar, simulación NEW) **no** salen de la caché: siguen en sus reglas (`SCA2_obtenerEstadoPoliza`, `SCA2_consultarAnulacionPoliza`).

**Pruebas:** comparación campo a campo cabecera viva vs. cacheada en 5 pólizas (Autos, Hogar, Vida, wAutemis, Verti); medición del tiempo de apertura de Detalle y Alta (referencia doc 11); caducidad de la caché al cambiar de día.

## 5. Preparación de datos para decidir (`cPrepararDatosSD` → regla pura)

**Situación actual:** `SCA2_mapearDatosDecidirAccion` construye el CDT `SCAC_scaServiciosReglas` (numeroAplicacion, canalEntrada, perfil/subperfil de ejecución, lineaNegocio, claveProduccion, catalogación, motivo/causa/detalle, nivelDecidirAccion, `fechaAnulacion` en `yyyy-mm-dd`, codigoSCA, compañía contraria, numeroFax, estadoUltimaGestion, anulaTecnico/Experto, nuuma, subgrupo, mecanizada…) y `SCA2_consultarServiciosReglas` añade lógica propia (si `regla = "mecanizar"` y mecanizada, consulta estado de póliza). Parte de la preparación está en el nodo «Consultar reglas» de `CMD Decidir`.

**Diseño:** regla pura `SCA2_construirEntradaReglas(sol, datosPoliza, carterizacion, estruage, nivel, regla)` → `SCAC_scaServiciosReglas`, sin llamadas externas, que concentra: formatos de fecha (CORE `dd/MM/yyyy` → `yyyy-MM-dd`), normalización `S/N`/booleanos, recibo impagado (`fechaEfectoReciboImp` desde `ESTADO_RECIBOS.FEC_EFEC_RECIBO`), carterización (`pcodretorno = 0`) y propietario (regla del punto 2). `SCA2_mapearDatosDecidirAccion` pasa a delegar en ella (misma salida); `CMD Decidir` no cambia. Casos `a!test` por tipo de póliza y por regla (`alta`, `mecanizar`, `cambioNivel`).

## 6. Plan (sin cambios funcionales; todo reversible por constante)

| Semana | Trabajo | Validación | Objetos tocados |
|---|---|---|---|
| 1 | Punto 1 (caducidad) + punto 5 (entrada reglas): reglas puras, constantes, `a!test` | Comparación con SCA en 4+6 casos nuevos | Nuevos: 2 reglas, 2 tests, 2 constantes. Modificados: `setDatosGestionSGC(+Estr.)`, `mapearDatosDecidirAccion` (delegación), `CMD CrearAccion/Posponer/CambiarNivel` (una expresión) |
| 2 | Punto 2 (propietario) en **modo sombra** (se calcula y se registra, el valor efectivo sigue siendo el del ESB) | Coincidencia regla vs. ESB en todas las gestiones SGC de la semana | Nuevos: 2 reglas, 1 constante. Modificados: `setDatosGestionSGC(+Estr.)` |
| 3 | Punto 3 (catálogos): tablas Aurora, records, PM de refresco, reglas `SCA2_cat*` con *fallback* | Lista a lista vs. SOAP; tiempos del Alta | Nuevos: 7 tablas/records, 1 PM, 7 reglas, 1 constante. Modificados: 6 interfaces (una línea cada una) |
| 4 | Punto 4 (caché de cabecera 1 jornada) | Campo a campo en 5 pólizas; tiempos de Detalle/Alta | Nuevos: 3 campos, 1 regla, 1 constante. Modificados: 9 interfaces + `CMD Alta` (una línea) |
| 5 | Activar propietario Appian (`SCA2_USAR_PROPIETARIO_APPIAN = true`), retirar la llamada ESB de SGC; cierre y documentación (ronda de pruebas comparadas, doc 42) | Ronda completa Alta → CA/AA → SGC → Mecanizar con solicitudes nuevas | — |

**Qué no se hace en esta fase:** nada sobre MR01/CORE ni sus servicios; no se cambian estados, mensajes ni pantallas; no se tocan `SCA2_nuumaEsPropietario` (pendiente de decisión AND/OR), el servicio de reglas ni la alta automática. Los interruptores por constante permiten volver al comportamiento actual en cualquier momento.

**Dependencias/decisiones que necesito:** valores de días de caducidad (OT); TTL de la caché de cabecera (8 h vs. fin del día); criterio AND/OR de propietario para Contra Anulación.
