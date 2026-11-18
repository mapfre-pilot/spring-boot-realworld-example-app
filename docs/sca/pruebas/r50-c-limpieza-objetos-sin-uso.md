# R50-C — Limpieza de objetos SCA2 sin uso, reglas SCA2 fuera de la aplicación y relanzamiento del error 215

Fecha: 16/11/2026. Entorno: Appian TEST (`https://mapfrespain-test.appiancloud.com`, site `/suite/sites/sca2`), MCP `appian-dev-mcp-c90b`. Horas en UTC (Madrid = UTC+1) salvo que se diga otra cosa. Coordinación: `coordinacion-ronda50.md`. Copias: `backups-r50/R50C_*`.

## 1. Resumen

| Punto | Resultado |
|---|---|
| Objetos sin uso | Recalculado con el MCP sobre los 690 objetos de la aplicación (677 con `getObjectDependents`, sin errores) más los `SCA2*` que están fuera de la aplicación. **Borrados 9 objetos** sin ningún dependiente (§3). Se conservan las Web APIs, los PM con temporizador o con decisión funcional pendiente, las piezas de piloto y Decisora/FDC (§4). |
| Reglas fuera de la aplicación | Las **6 reglas** de §5 de r33 están ahora en la aplicación SCA2 y en la carpeta `SCA2 Rules and Constants`. **Versión y contenido sin cambios** (expresión e inputs idénticos antes y después). Heredan la seguridad de la carpeta (`SCA2 Administrators` / `SCA2 Users`). |
| Error 215 | **Relanzado una vez desde `/errores` (usuario `devin`, grupo `SCA2 Administrators`) a las 15:38:38. Ya no falla en «Write Tarea»** (el recorte `left(…,255)` de R47-C funciona). La fila 215 queda `RELANZADO`; la contra anulación de 15788894 queda **Finalizada Positiva** (`FINALIZADA_POSITIVO`, tarea 829 `COMPLETADA`). No hace falta esperar a R50-B. |
| Regresión | **OK.** 3 solicitudes nuevas (15789173, 15789177, 15789180): alta, POSPONER, buscador, detalle, RETOMAR, contra anulación negativa con carta, positiva y Acción Administrativa. **Ningún error nuevo en `SCA2 Error`** (máximo `id` 226 antes y después) y **todas las instancias SCA2 desde las 15:30 están COMPLETED** (ninguna en error ni `PAUSED_BY_EXCEPTION`). |
| SQL | **No hace falta ningún SQL.** |

## 2. Cómo se ha calculado el «sin uso»

1. Inventario de la aplicación `SCA2 Sistema Comercial de Anulaciones` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`) con `listApplicationObjects`, paginando reglas (214) y constantes (247): 690 objetos.
2. `getObjectDependents` de cada objeto (677 consultas, 0 errores). Sin dependientes de diseño salieron 12 objetos; con el cierre (objetos que solo usan esos 12) salieron 11 más.
3. Búsqueda `listObjects("SCA2")` (825 resultados) para encontrar objetos `SCA2*` **fuera** de la aplicación: las 6 reglas vivas de r33 §5, la regla temporal `SCA2_tmpSolanulDateFmt_1791282137` y las constantes `SCA2_TXT_COD_ESTADO_SOL_CANCELADA` / `SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA` (sin uso desde que se revirtió R45-B fase 1).
4. `listProcessInstances` de los 17 PM: los candidatos no tienen instancias en la retención visible (la retención es limitada; por eso no es prueba suficiente para PM con temporizador o batch).
5. Usos que el grafo de dependencias no ve: Web APIs llamadas por HTTP (`SCA2_guardarContacto`, `SCA2_refrescarCacheCabecera`, desde integraciones), temporizador de `SCA2 CMD RefrescarCacheCabecera` (07:05, doc R33), referencias por UUID (Appian guarda las referencias de las expresiones por UUID y las cuenta como dependientes; además se buscaron el UUID y el nombre de cada borrado en las 102 integraciones y Web APIs exportadas, incluidas URLs y cuerpos HTTP: ninguna coincidencia), documentación funcional (piloto, Decisora/FDC).
6. Justo antes de cada borrado se repitió `getObjectDependents`; solo se borró si el único «dependiente» era la propia aplicación. Después, `get*` devuelve 404.

## 3. Objetos borrados

| Objeto | Tipo | UUID | Versión antes → después | Motivo | Copia |
|---|---|---|---|---|---|
| `SCA2 CMD CambiarNivel` | PM | `0000f06f-8a54-8000-6759-7f0000014e7a` | última publicada (el MCP no da número) → borrado | 0 dependientes, 0 instancias. El cambio de nivel lo hace `SCA2 CMD Decidir` (R27/R29). La constante `SCA2_PM_CMD_CAMBIAR_NIVEL` **ya no existía** (no está en la aplicación ni en `listObjects`) | `R50C_borrado_SCA2_CMD_CambiarNivel.json` |
| `SCA2 CMD RegistrarDesincronizacion` | PM | `0000f095-791c-8000-d602-7f0000014e7a` | → borrado | 0 dependientes, 0 instancias; su constante `SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION` se borró en R32-A | `R50C_borrado_SCA2_CMD_RegistrarDesincronizacion.json` |
| `SCA2_RegistrarDesincronizacionForm` | Interfaz | `_a-0000f093-2064-8000-9d36-011c48011c48_5605245` | v1 → borrado | Solo la usaba el PM anterior | `R50C_borrado_SCA2_RegistrarDesincronizacionForm.json` |
| `SCA2_tmpMedicionArgumentario` | Regla | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5643715` | v4 → borrado | Regla temporal de medición (R46/R47), sin dependientes | `R50C_borrado_SCA2_tmpMedicionArgumentario.json` |
| `SCA2_tmpSolanulDateFmt_1791282137` | Regla (fuera de la app) | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5516094` | v1 → borrado | Regla temporal, sin dependientes | `R50C_borrado_SCA2_tmpSolanulDateFmt_1791282137.json` |
| `SCA2_TXT_URL_AUTEMISDIST` | Constante | `_a-0000f09f-42ed-8000-9d42-011c48011c48_5650543` | v2 → borrado | Sin dependientes; la URL que se usa es `SCA2_TXT_WAUTEMIS` | `R50C_borrado_SCA2_TXT_URL_AUTEMISDIST.json` |
| `SCA2_VAL_ESPERA_DECISION_INCREMENTO_SEGUNDOS` | Constante | `_a-0000f09f-42ed-8000-9d42-011c48011c48_5648803` | v1 → borrado | Sin dependientes; R35-A la dejó reservada y nunca se conectó | `R50C_borrado_SCA2_VAL_ESPERA_DECISION_INCREMENTO_SEGUNDOS.json` |
| `SCA2_TXT_COD_ESTADO_SOL_CANCELADA` | Constante (fuera de la app) | `225d3e42-00bf-4753-98df-dfe6a04cff34` | v1 → borrado | Sin dependientes desde la reversión de R45-B | `R50C_borrado_SCA2_TXT_COD_ESTADO_SOL_CANCELADA.json` |
| `SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA` | Constante (fuera de la app) | `2bde13a5-2a36-4561-ab18-9718d57a4ee6` | v1 → borrado | Ídem | `R50C_borrado_SCA2_TXT_MCA_ESTADO_FINAL_CANCELADA.json` |

Para recuperar cualquiera: crear el objeto con el contenido de la copia (mismo nombre); los PM, importando la copia o recreándolos desde el JSON.

## 4. Objetos sin dependientes que NO se borran

| Objeto | Por qué se conserva |
|---|---|
| Web APIs `SCA2_guardarContacto`, `SCA2_refrescarCacheCabecera` | Se llaman por HTTP desde integraciones (no aparece como dependiente). Instrucción expresa |
| PM `SCA2 CMD RefrescarCacheCabecera` y sus reglas (`SCA2_renovarCacheCabecera`, `SCA2_construirFilaCacheCabecera`, `SCA2_ajustarFilaCacheCabecera`, `SCA2_obtenerIdFilaCacheCabecera`, `SCA2_limitesFilaCacheCabecera`, `SCA2_RECORTAR_FILA_CACHE_CABECERA`, `SCA2_CACHE_REFRESCO_BATCH`) | Temporizador diario 07:05 (y lo usa la Web API de refresco) |
| PM `SCA2 CMD BarridoCaducidad` | Duda funcional (D1) |
| PM `SCA2 Batch Mecanizacion NSE` y `SCA2_BOOL_BATCH_NSE` | Duda funcional (D2) |
| `SCA2_esUsuarioPiloto`, `SCA2_esSolicitudSCA2`, `SCA2_GRP_PILOTO`, `SCA2_BOOL_PILOTO_ACTIVO` | Piezas del piloto SCA2 (doc 60), pendientes de conectar con SCA |
| Piezas Decisora/FDC (r33 §3.3), documentos de GGALV10, `SCA2_FLD_DOCUMENTOS` | Instrucción expresa / tienen dependientes |

## 5. Reglas añadidas a la aplicación

`addObjectsToApplication` (6 añadidas, 0 fallos) y `moveObjectsToFolder` a `SCA2 Rules and Constants` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050135`). Antes de mover se comprobó que la versión viva era la de la copia.

| Regla | UUID | Versión antes → después | Expresión / inputs | Consumidores |
|---|---|---|---|---|
| `SCA2_notificarNivel` | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505875` | 5 → 5 | idénticos | `SCA2 CMD Decidir` |
| `SCA2_finalizarGestionSGC` | `_a-0000f07f-6ec5-8000-9d2c-011c48011c48_5505931` | 2 → 2 | idénticos | `SCA2 CMD CrearAccion`, `Finalizar`, `Mecanizar` |
| `SCA2_construirSolicitudAnulacionAnl` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5493600` | 1 → 1 | idénticos | `SCA2 CMD Mecanizar`, `SCA2_construirSolicitudAnulacionAnlTraducida` |
| `SCA2_construirContextoSolicitudAnl` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5493604` | 2 → 2 | idénticos | `SCA2 CMD Mecanizar` |
| `SCA2_construirSolicitudAnulacionAnlTraducida` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5501155` | 2 → 2 | idénticos | `SCA2 CMD Mecanizar` |
| `SCA2_construirConsultaActualizarMecanizacion` | `_a-0000f07a-9a6a-8000-9d2b-011c48011c48_5493616` | 1 → 1 | idénticos | `SCA2 CMD Mecanizar`, `MecanizarNSE` |

Copias antes/después: `R50C_externa_<regla>_antes.json`, `..._despues.json` y `....security_antes.json`. La aplicación pasa de 214 a 221 reglas listadas (6 añadidas + ajustes de R50-A/B en paralelo).

## 6. Error 215 (solicitud 15788894, prueba propia de R47-C)

| Paso | Resultado |
|---|---|
| Antes | Fila 215 `PENDIENTE`: `SCA2 CMD CompletarAccion`, nodo «Write Tarea», `WRITE_FAIL` varchar(255), observación de 1.100 caracteres. Solicitud «Solicitud Pendiente / Contra anulación Incompleta». Captura `../img/r50-c-215-antes.png` |
| Relanzar | `/errores` con `devin` (JJGONZ2 y SISANS no tienen acceso), filtro 15788894, Relanzar una sola vez. `SCA2 CMD MarcarErrorRelanzado` 11310671 y `SCA2 CMD CompletarAccion` 15536815, ambos COMPLETED. Captura `../img/r50-c-215-relanzado.png` |
| Después | Fila 215 `RELANZADO` (resolución 15:38:38). Transición 3296 `CompletarAccion EN_ACCION→FINALIZADA_POSITIVO`. Solicitud `FINALIZADA_POSITIVO`, interfaz `FIN`, tarea 829 `COMPLETADA`. Detalle «Contra Anulación Finalizada Positiva»; buscador «Finalizado Contra Anulación Positiva». Sin fila nueva de error. Capturas `../img/r50-c-215-detalle-cerrado.png`, `../img/r50-c-215-solicitud-finalizada.png` |

## 7. Regresión con solicitudes nuevas

Usuario JJGONZ2 (SSO NOPRO), pólizas del bloque `polizas/bloque-R50-C.txt`. Vídeo de la prueba entregado en la sesión (no se sube al repositorio por tamaño).

| ID | Solicitud / póliza | Pasos | Esperado | Real | OK/KO |
|---|---|---|---|---|---|
| A1 | 15789173 / 2002400409136 (Autos, NSE-Autos) | Alta 15:46:05 → contra anulación → POSPONER | CORRECTO; solicitud pendiente | Transiciones 3301 Alta, 3302 Decidir, 3303 CrearAccion, 3307 `Posponer EN_ACCION→PENDIENTE`. Captura `../img/r50-c-a-posponer.png` | OK |
| A2 | 15789173 | Buscador por póliza → detalle → RETOMAR | Se ve la solicitud y vuelve a la gestión | «Contra Anulación Incompleta»; RETOMAR abre la gestión con la oficina VILLALBA. Captura `../img/r50-c-a-retomar.png` | OK |
| A3 | 15789173 | Argumento obligatorio NEGATIVO (15:48:39) → carta (`SCA2 CMD GenerarPdf` 793975) → CONTINUAR → FINALIZAR → Sí | Cierre negativo y siguiente tarea | Tarea 911 `COMPLETADA`; transiciones 3309 `CompletarAccion EN_ACCION→DECIDIR` y 3310 `Decidir →MECANIZAR`; tarea 913 `VERTI` `PENDIENTE`. Detalle «Contra Anulación Finalizada Negativa», «Gestión Verti/vencimiento Incompleta» (igual que 15789003 en R48-D). Captura `../img/r50-c-a-negativa.png` | OK |
| B1 | 15789177 / 0732000041110 (Hogar, NSE-Hogar) | Alta 15:53:07 → POSITIVO → ACEPTAR | `FINALIZADA_POSITIVO` | Transiciones 3311–3313 y 3317 `CompletarAccion EN_ACCION→FINALIZADA_POSITIVO`; tarea 914 `COMPLETADA`. Buscador «Finalizado Contra Anulación Positiva». Captura `../img/r50-c-b-positiva.png` | OK |
| C1 | 15789180 / 2002500238410 (Autos, venta del vehículo) | Alta 15:57:30 → Acción Administrativa → VILLALBA → «El cliente no entrega documentación» → FINALIZAR → ACEPTAR | Redirige a la anulación; tarea MECANIZAR | «Se va a redirigir a la anulación» (15:59:05), consulta NSE-Autos con fecha 01/06/2027. Transiciones 3326–3331 (`CompletarAccion →DECIDIR`, `Decidir →MECANIZAR`, `CrearAccion →PDTE_MECANIZAR`); tarea 918 `COMPLETADA`, tarea 919 `MECANIZAR` `PENDIENTE`; solicitud `PDTE_MECANIZAR`. Igual que 15789009 en R48-D. Capturas `../img/r50-c-c-redireccion.png`, `r50-c-c-consulta-nse.png`, `r50-c-c-detalle.png`, `r50-c-c-buscador.png` | OK |
| D1 | — | `SCA2 Error` | Sin filas nuevas | Máximo `id` 226 antes (15:3x) y después (16:0x) | OK |
| D2 | — | `listProcessInstances` de los 15 PM que quedan, desde las 15:30 | Ninguna en error | Alta 7, Decidir 11, CrearAccion 11, CompletarAccion 6, Posponer 2, GenerarPdf 1, MarcarErrorRelanzado 1: **todas COMPLETED** (incluyen pruebas de R50-A/B en paralelo). Sin errores de regla no encontrada | OK |

Observación en C1 (no la causa R50-C): con la mecanización pendiente, la cabecera y el buscador muestran «Solicitud Finalizada sin anular» y el buscador enseña como observación «Consulta NSE: codMotivo…». Es el texto que da `SCA2_textoEstadoSolicitud` para ese estado desde R10 (HU3980) y la observación la escribe la consulta NSE; ninguno de los objetos tocados interviene.

Comparación con SCA: el borrado y el cambio de carpeta no cambian nada de lo que ve o hace el usuario; los flujos probados se comportan igual que en R48-D, que ya se comparó con SCA.

## 8. No probado y dudas

- No se pulsó ANULAR PÓLIZA (A y C) ni se continuó la gestión Verti/vencimiento, para no anular pólizas en NSE. `SCA2 CMD Mecanizar` y `MecanizarNSE` (consumidores de 4 de las 6 reglas movidas) no se han ejecutado; como las reglas no cambian de contenido ni de UUID, no se espera efecto.
- No se revisó el contenido del PDF de la carta.
- La retención de Monitorización es limitada: los PM borrados no tienen instancias visibles, pero tampoco ningún dependiente ni referencia.
- **D1.** `SCA2 CMD BarridoCaducidad`: sin dependientes ni instancias. Propuesta: borrarlo si la caducidad se deja solo en `SCA2 CMD Caducar` (como hoy); si se quiere un barrido nocturno, programarlo. Decide negocio.
- **D2.** `SCA2 Batch Mecanizacion NSE` (+ `SCA2_BOOL_BATCH_NSE`): sin dependientes ni instancias. Propuesta: borrarlo si la mecanización NSE se mantiene síncrona en `SCA2 CMD MecanizarNSE`. Decide negocio.

## 9. Coordinación

Reserva y liberación en `coordinacion-ronda50.md` (commits `3638575` y `42457e8`). Bloque de pólizas 8581-8620 (`7517e24`). No se ha modificado ningún objeto de SCA, SCAC, CORE, GAIA, PRE, CMP, NSE, ANL, SGD ni Documentum, ni se ha ejecutado SQL.
