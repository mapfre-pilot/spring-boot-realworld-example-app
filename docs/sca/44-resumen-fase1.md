# 44. Fase 1 «lógica legacy en Appian» — resumen de cierre (SCA2 TEST, 21-10-2026)

Cinco piezas construidas en paralelo (sesiones A–E, reparto en [doc 42](42-coordinacion-fase1.md); diseño en [doc 41](41-diseno-logica-appian-fase1.md)). Sin tocar MR01/CORE ni PRO. Detalle por pieza en los docs 43-A…E; datos de prueba en [pruebas/coordinacion-fase1.md](pruebas/coordinacion-fase1.md).

## Estado en TEST
| Pieza | Interruptor | Estado | Efecto visible |
|---|---|---|---|
| A · Caducidad por nivel | — (sin interruptor) | **activa** | `SCA2 Solicitud.caducidadTarea` = caducidad del nivel (hoy+14 propietario / hoy+7 no propietario, tope vencimiento); se fija en el alta y en cada salto de nivel; posponer / crear acción no la mueven; `fecInicioNivel` informado |
| B · Propietario / carterización | `SCA2_USAR_PROPIETARIO_APPIAN` = **true** (v10) | activa + sombra | Contra Anulación y SGC usan el criterio legacy (carterizado O clave O póliza); cada FINALIZAR de Contra Anulación registra en `SCA2 Trazabilidad Cliente` la comparación ESB/Appian |
| C · Catálogos en Aurora | `SCA2_USAR_CATALOGOS_AURORA` = **true** (v8) | activa | Causas/motivos/detalles/tipos de argumento/conceptos desde Aurora (fallback SOAP); página «Catálogos CORE (Aurora)» en Gestiones de mantenimiento |
| D · Caché de cabecera | `SCA2_USAR_CACHE_CABECERA` = **true** (v20) | activa | El alta guarda la cabecera (válida hasta las 07:00 del día siguiente); Detalle con enlace «Actualizar datos»; «otras solicitudes» siempre en vivo |
| E · Entrada al motor de reglas | — | activa (impacto cero) | `SCA2_mapearDatosDecidirAccion` delega en `SCA2_construirEntradaReglas`; paquete idéntico 13/13 |

Cualquier pieza con interruptor se desactiva poniendo su constante a `false` (sin despliegue). El motor tarda unos minutos en ver el cambio de una constante.

## Objetos Appian (prefijo nuevos `_a-0000f093-2064-8000-9d36-011c48011c48_`)
**A** — nuevos: `SCA2_DIAS_CADUCIDAD_PROPIETARIO` (…5603454 v2 = 14), `SCA2_DIAS_CADUCIDAD_NO_PROPIETARIO` (…5603464 v1 = 7), `SCA2_calcularCaducidadNivel` (…5603490 v1, 10 tests), `SCA2_calcularCaducidadNivel_test` (…5603502), `SCA2_textoAFecha` (…5604118 v1, 9 tests), `SCA2_esPropietarioProvisional` (…5604058 v2, OBSOLETA, 0 llamadores). Modificados: `SCA2_cargarSolicitud` v7→v8 (aditivo); PM `SCA2 CMD Alta` (nodos 7, 8, 9), `SCA2 CMD CrearAccion` (nodos 7, 11), `SCA2 CMD CambiarNivel` (nodo 6), `SCA2 CMD Posponer` (nodo 5).
**B** — nuevos: `SCA2_USAR_PROPIETARIO_APPIAN` (…5603472 v10), `SCA2_esPropietarioPoliza` (…5603496 v4, 8 tests), `SCA2_propietarioParaCaducidad` (…5603576 v1, 10 tests), `SCA2_registrarSombraPropietario` (…5603783 v2), `SCA2_evaluarPropietarioContraAnulacion` (…5604455 v1), `SCA2_sombraPropietarioContraAnulacion` (…5604465 v1). Modificados: `SCA2_nuumaEsPropietario` v1→v6, `SCA2_setDatosGestionSGC` v1→v2, `SCA2_setDatosGestionSGCEstratégicas` v1→v2, `SCA2_ContraAnulacionOpciones` v54→v57 (sombra en FINALIZAR; corrección de la clave de producción).
**C** — nuevos: tablas `sca2_cat_motivo/detalle/causa/tipo_argumento/concepto/valor_concepto` (esquema `sca2_anulaciones`, DDL en [sql/43-C-catalogos.sql](sql/43-C-catalogos.sql)), records `SCA2 Cat *` (6), reglas `SCA2_consultar*Core` (5 copias), `SCA2_catParametrosCarga`/`SCA2_catConstruirCarga`/`SCA2_catCargarDesdeCore`, `SCA2_cat*Aurora` (5), interfaz `SCA2_CatMantenimiento` (v8), `SCA2_USAR_CATALOGOS_AURORA` (…5603869 v8). Modificados: `SCA2_consultarMotivo` v2, `SCA2_consultarDetalle` v2, `SCA2_consultarCausa` v3, `SCA2_consultarTipoArg` v6, `SCA2_consultarConcepto` v2, `SCA2_GestionMantenimientoMenu` v4. Carga: 14/22/146/343/17/100 filas.
**D** — nuevos: `SCA2_obtenerDatosCabeceraLive` (…5603393 v1), `SCA2_USAR_CACHE_CABECERA` (…5603399 v14), `SCA2_HORA_CADUCIDAD_CACHE_CABECERA` (…5603405 v1 = 7), `SCA2_calcularValidaHastaCache` (…5603423 v1, 10 tests). Modificados: `SCA2_obtenerDatosCabecera` v2→v5 (envoltorio, `forzarRefresco`), record `SCA2 Datos Cabecera` v1→v11 (+9 campos), `SCA2_DetalleSolicitud` v59→v60.
**E** — nuevos: `SCA2_construirEntradaReglas` (…5603604 v4, 12 tests), `SCA2_construirEntradaReglas_test` (…5603728 v3). Modificados: `SCA2_mapearDatosDecidirAccion` v3→v4.

## Pruebas (resumen; tablas en cada 43-*)
Regresión con interruptores en false idéntica en todas las piezas (A: nodo a nodo; B: 4 entradas + 3 solicitudes; C: 12/12; D: 3 solicitudes campo a campo; E: 13/13). Con interruptores en true: C 145/145 listas iguales a CORE; D caché = vivo campo a campo, caducidad y refresco forzado, UI «Actualizar datos»; A altas nuevas hoy+7, tope por vencimiento, posponer/CA no mueven la caducidad, `CMD Caducar` caduca; B sombra con datos reales; E dos solicitudes nuevas decididas igual que sus equivalentes. Tiempos: Detalle 4,7→3,2 s (navegador); Contra Anulación 11,6→~7 s; Alta −0,75 s mediana.

## Hallazgos preexistentes (sin tocar; decisión del usuario)
1. `CMD BarridoCaducidad` nunca caduca nada (lote de 100 sin orden y un solo arranque de `CMD Caducar` con la lista entera; 115 vencidas en TEST). `CMD Caducar` escribe `CADUCADA` (no `FINALIZADO_CADUCADO`) y su llamada a CORE da 500/0999 en TEST. Propuesta en 43-A §11.
2. `SCA2_setDatosGestionSGC(+Estratégicas)` no tienen llamadores y su condición de propietario está invertida (43-B).
3. El motor de reglas no recibe recibo impagado / carterización / propietario (el legacy sí); `estadoUltimaGestion` lleva el estado de la solicitud; Vida todo nulo (43-E).
4. `SCA2 Datos Cabecera` tiene filas duplicadas por `idSolicitud` (43-D).
5. El indicador propietario solo gobierna el botón REVISIÓN de Contra Anulación; argumentario y modal no lo usan (43-B).

## Pendientes
- Aviso: la sesión R23-A modificó `CMD Mecanizar` nodo 16 en paralelo (21-10); los nodos de G siguen intactos.
- **F** (hecho, [43-F](43-F-pm-refresco-cache.md)): PM `SCA2 CMD RefrescarCacheCabecera` v3.0 (uuid `0000f095-81a8-8000-d613-7f0000014e7a`, timer diario 07:05 Europe/Madrid, tolerante por fila, errores a `SCA2 Error`) + `SCA2_CACHE_REFRESCO_BATCH` = 50 (…5605352 v3). Punto de control: primera ejecución programada 22-10-2026 07:05.
- **G** (hecho, [43-G](43-G-invalidacion-cache.md)): regla `SCA2_invalidarCacheCabecera` (…5605449 v1, 5 tests) añadida al Write Records de `CMD Finalizar` [8], `CMD Caducar` [6], `CMD Mecanizar` [13][306][5], `CMD CompletarAccion` [340][7]; Decidir/CrearAccion sin tocar (encadenados tras el alta). Mecanizar verificado solo por definición.
- Del usuario: caso de gestor propietario / cliente carterizado en TEST; usuarios de negocio por perfil (guiones en 43-B §9, 43-C C-19); decidir corrección del barrido; índices únicos `ux_*` para el DBA.
- Sin camino en TEST: salto a N2 (A), pólizas Vida/Verti (D, E).
