# Plan de migración SCA → SCA2 (convivencia hasta drenar SCA)

Objetivo: que **toda solicitud nueva nazca en SCA2**, que las **solicitudes y tareas antiguas sigan en SCA** hasta terminar, y retirar SCA sólo cuando no quede nada en vuelo. Sin cambiar los contratos externos mientras sea posible: **SCA actúa de fachada** (misma URL Decisora, sites, grupos).

Documentos de apoyo:
- DDL: `docs/sca/sql/56-ddl-sca2-produccion.sql` y resumen `docs/sca/sql/56-ddl-sca2-resumen.md`.
- Inventario de consumo de SCA (Observado / Inferido / Pendiente): `docs/sca/57-inventario-consumo-sca.md`.
- Antecedentes: `51` (grupos), `52` (Decisora y mínimo impacto), `53` (fachada SCA→SCA2), `pruebas/r33-objetos-sin-uso-verificados.md`.

## 1. Qué consume SCA hoy (resumen del inventario 57)

| Vía de entrada | Objeto | Quién la usa | Qué pasa en la migración |
|---|---|---|---|
| URL Decisora (GET) | Web API `SCA Decisora` (`/suite/webapi/decisora`) | PCA / portal / GPC (externo, no visible desde Appian) | **Se mantiene**. Es el punto de enrutado: decide SCA o SCA2. |
| Sites | `sca-site` (búsqueda, mantenimiento), `decidir-accion` | Gestores (enlaces y favoritos) | Se mantienen; el buscador de SCA redirige a SCA2 cuando la solicitud es SCA2. |
| Site SCA2 | `sca2` (buscador, errores, mantenimiento) | Destino de la fachada | Página `buscador` acepta `numPoliza`, `idSolicitud`, `tipoAccion`, `idTarea`. |
| Batch AWS | `ejecutarRsvPrima`, `volcadoReservaPrima` | Batch externo AWS | Se mantienen en SCA hasta tener equivalente SCA2 (no hay hoy). |
| Limpieza AWS | `eliminarTareas`, `eliminarTareasBBDD` | Proceso externo | Se mantienen para lo antiguo; SCA2 no las necesita para lo nuevo. |
| Callbacks autorización | `modificaEstadoAutorizacion`, `2v1iyg` (STCAT), `gestionarAutorizacionIA` (SCAC) | SGO / STCAT / IA | Compartidas (SCAC/ANL). Deben resolver tanto solicitudes SCA como SCA2. **Verificar** que SCA2 recibe el desbloqueo (mensaje ANL_Desbloquear) igual que `SCA Mecanizacion`. |
| Documentos | `DocumentsToRecord`, `submitUploadedFile`, `KdX27Q` (SCAC) | SGD/Documentum, Vida | Compartidas; lanzan PMs de SCA. Revisar si SCA2 las necesita. |
| Tareas Appian | 183 instancias RUNNING en 14 PMs de SCA (TEST) | Gestores con tareas abiertas | **No se migran**: se dejan terminar en SCA. |
| Diseño SCA2 → SCA | 51 referencias de 46 objetos SCA2 a 44 objetos SCA (30 grupos, 3 record types, 5 decisiones, 5 constantes, 1 regla) | SCA2 | **Bloquean la retirada de SCA**: hay que trasladarlos o conservarlos (ver fase 7). |
| Otros consumidores | ANL (26 refs), SCAC (4), «Objetos Perdidos» (226), 15 sin aplicación | Otras apps | Revisar antes de retirar SCA. |

Mayor carga en vuelo (TEST): Alta Particionado 58, Batch Mecanización NSE (2) 32, Mecanización 26, Finalizar Solicitud 25, Contra Anulación 11, Acciones Administrativas 10. **En PRO hay que repetir el recuento** antes de cada fase.

## 2. Regla de enrutado (la pieza central)

En la Web API `decisora` (y en el buscador de SCA), antes de la lógica actual:

1. ¿Existe la solicitud en **SCA2** (`sca2_solicitud` por póliza/`codSolicitud`, no cerrada)? → **abrir SCA2** (`/suite/sites/sca2/page/buscador?numPoliza=…&idSolicitud=…`).
2. ¿Existe solicitud viva en **SCA** (tablas/records de SCA o tareas activas)? → **seguir en SCA** (flujo actual, sin cambios).
3. Solicitud **nueva**: ¿el gestor/estructura está en la **oleada SCA2** y el interruptor global está activo? → **alta en SCA2**; si no → alta en SCA.

Principios:
- Una solicitud **nunca cambia de sistema** en vida: nace y muere donde se creó.
- Un único interruptor global (constante `SCA2_MIGRACION_ACTIVA`, kill-switch) y una definición de oleada (grupo `SCA2 Oleada` o tabla de DGT/DT/oficina/NUUMA). Reutilizar el mecanismo de oleada que ya tiene Decisora (estructura comercial o grupo `SCA Acceso Decisora`).
- La respuesta de la Web API sigue siendo la misma redirección HTML: **PCA/GPC no cambian nada**.

## 3. Fases

| Fase | Qué se hace | Criterio para pasar a la siguiente | Vuelta atrás |
|---|---|---|---|
| 0. Preparación BD | DBA ejecuta `56-ddl-sca2-produccion.sql` en PRE y PRO; habilita FKs/GRANTs revisados; **carga de catálogos** SCA2 (`sca2_cat_*`: motivos, detalles, causas, tipos de argumento, conceptos, valores) desde TEST validado. | 21 tablas creadas, catálogos con los mismos recuentos que TEST, data source `SCA2 DataBase AWS` apuntando a PRO. | Tablas vacías: sin impacto. |
| 1. Despliegue SCA2 «apagado» | Desplegar SCA2 (incluidas las 6 reglas `[SCA2]` que hoy están fuera de la aplicación) + cambios de fachada en SCA con interruptor **OFF** y oleada vacía. Configurar timer diario de `SCA2 CMD RefrescarCacheCabecera` y decidir `BarridoCaducidad`. | Smoke test: Decisora sigue llevando todo a SCA; site SCA2 accesible sólo a administradores. | Interruptor OFF (estado por defecto). |
| 2. Piloto | Oleada = grupo pequeño de gestores/oficina piloto. Seguimiento diario de `sca2_error`, tareas y mecanización. | 2–4 semanas sin errores bloqueantes; mecanización CORE y ANL correctas; analista conforme. | Sacar el piloto de la oleada: sus nuevas altas vuelven a SCA; lo ya creado en SCA2 se termina en SCA2. |
| 3. Oleadas progresivas | Ampliar por DT / DGT (p. ej. 10 % → 30 % → 60 %). | Mismos indicadores por oleada; capacidad de los servicios CORE/GAIA/ANL. | Retirar la última oleada. |
| 4. 100 % altas en SCA2 | Interruptor global: toda alta nueva en SCA2. SCA sólo gestiona lo existente. | Ninguna alta nueva en SCA durante 1 semana (comprobar en tablas de SCA). | Volver a oleada parcial. |
| 5. Drenaje de SCA | Se dejan terminar o caducar las solicitudes y tareas de SCA. Seguimiento semanal de instancias RUNNING por PM y de solicitudes abiertas en SCA. Las tareas huérfanas se revisan con negocio (cerrar o reasignar). | 0 solicitudes abiertas y 0 instancias activas en los PMs de SCA (salvo los que también sirven a SCA2). | No aplica (SCA sigue operativo). |
| 6. Apagado de SCA | Desactivar batches y temporizadores de SCA, Web APIs sólo de lo antiguo (`eliminarTareas*`, reserva prima si ya tiene sustituto), y quitar la creación de solicitudes en SCA. Decisora queda como **sólo enrutador** a SCA2. | Período de observación sin llamadas a lo apagado. | Reactivar objetos (no se borra nada aún). |
| 7. Retirada | Trasladar a SCA2 los 44 objetos SCA de los que depende SCA2 (grupos, records, decisiones, constantes) o mantenerlos en una app «SCA Fachada» mínima con Decisora, sites, grupos y `SCA_DecidirAccion`. Archivar PMs, interfaces y datos de SCA (consulta histórica). Cuando PCA/GPC apunten directamente a SCA2, se puede retirar la fachada. | Sin dependencias de SCA2/ANL/SCAC hacia SCA; histórico consultable. | Reimportar paquete de SCA. |

## 4. Acceso a lo antiguo durante la convivencia

- Los gestores siguen entrando por las mismas URLs; Decisora y el buscador de SCA llevan a SCA si la solicitud es antigua.
- Las **bandejas de tareas** de SCA siguen funcionando (mismos grupos).
- El buscador SCA2 debe mostrar también las solicitudes de SCA (histórico CORE ya integrado) con enlace a SCA para las antiguas, y viceversa.
- Grupos: reutilizar los grupos SCA durante la convivencia (doc 51); SCA2 ya los referencia mediante constantes.

## 5. Indicadores de seguimiento

- Altas por sistema y día (SCA vs SCA2).
- Solicitudes abiertas en SCA (debe bajar a 0) e instancias RUNNING por PM de SCA.
- Errores en `sca2_error` y desincronizaciones con CORE.
- Mecanizaciones pendientes/incompletas en SCA2.
- Llamadas a cada Web API (logs de Web API/gateway; hoy sólo `decisora` y `2v1iyg` tienen logging activado — **activar logging en las demás antes de la fase 6**).

## 6. Pendientes que hay que cerrar antes de la fase 1

| Pendiente | Por qué importa | Quién |
|---|---|---|
| Confirmar llamadores reales de cada Web API (PCA/GPC, AWS, SGO/STCAT/IA, SGD, PGM) | Desde Appian sólo se ve la configuración, no el tráfico. | Equipos consumidores / logs gateway |
| Temporizadores de inicio de los 59 PMs de SCA | La API no expone los timers de inicio; revisar en Designer. | Appian |
| Equivalente SCA2 de reserva prima y de batch NSE | Sin ellos, SCA no puede apagarse del todo. | Negocio / Appian |
| Callbacks de autorización para solicitudes SCA2 | Deben desbloquear también SCA2. | Appian (prueba en TEST) |
| Caducidad en SCA2 (`BarridoCaducidad` sin timer) | Las solicitudes SCA2 no caducan hoy. | Negocio |
| Datos de PRO: recuento real de solicitudes/tareas SCA en vuelo | Dimensiona el drenaje (fase 5). | Soporte PRO |
| 15 consumidores sin aplicación y 226 refs de «Objetos Perdidos» | Podrían romperse al retirar SCA. | Appian |
| Defaults, secuencias, nulabilidad e índices físicos de TEST | La API no los expone; el DBA debe compararlos con TEST antes de PRO. | DBA |
