# R47-B — Optimizaciones sin cambio funcional (cabecera y vigilancia de procesos)

Sesión hija R47-B de SCA2, 10/11/2026. Entorno: Appian TEST (`mapfrespain-test`, MCP `appian-dev-mcp-c90b`), site `/suite/sites/sca2`. Nunca PRO. Solo objetos SCA2.
Etiquetas: **[Observado]** = visto en Appian/pantalla; **[Inferido]** = deducción; **[Pendiente]** = no hecho.

## 1. Resumen
| Optimización | Resultado |
|---|---|
| 1a. Cabecera en paralelo | **Sin cambios en Appian.** La regla ya lanza en paralelo todo lo que no depende entre sí; lo que queda en serie es una cadena de dependencias real. Comprobado con una regla de prueba temporal (ya borrada). |
| 5. Vigilancia ACTIVE >1 h | **Aplicado** aviso de solo lectura en el cuadro de mando (`SCA2_CuadroMando` v25→v28). Archivado/borrado de PM revisado: **sin cambios** (ya es automático). Instancias 9157659 y 11252029 documentadas, **no canceladas**. |
| Pruebas en pantalla | Solicitudes nuevas **15788861** (Hogar 0730080003210) y **15788862** (Autos 2001900000007): alta y detalle correctos. Vida 0005912430: alta con cabecera correcta (sin guardar). |

## 2. Objetos cambiados
| Objeto | UUID | Versión | Cambio | Backup / copia |
|---|---|---|---|---|
| IF `SCA2_CuadroMando` | `_a-0000f0a4-c27c-8000-9d46-011c48011c48_5663892` | v25 → **v28** | Bloque nuevo «Aviso de operación: procesos en espera más de 1 hora (N)» encima de las pestañas (40 líneas añadidas, 0 borradas). v26 primera versión; v27 texto más preciso y «Días en espera» en vez de «Horas» (salía 0); v28 días como número entero (salía `18::00:00:00.000`). | `backups-r47/R47-B_SCA2_CuadroMando_v25_antes.sail`, `backups-r47/R47-B_SCA2_CuadroMando_v28_despues.sail`, `../sail/62-cuadro-mando/SCA2_CuadroMando.sail` |

Reexportación: tras cada guardado se comparó la expresión guardada con la enviada → idénticas (ignorando espacios) [Observado]. `testInterface` v28 sin errores [Observado].

Objetos leídos y **no** modificados: `SCA2_obtenerDatosCabecera` (v8, envoltorio de caché), `SCA2_obtenerDatosCabeceraLive` (v3; copia `backups-r47/R47-B_SCA2_obtenerDatosCabeceraLive_v3_leida_sin_cambios.sail`), los 17 PM SCA2.

Objeto temporal: regla `SCA2_R47B_TMP_pruebaParalelismo` (`_a-0000f0af-4eea-8000-9d50-011c48011c48_5691852`) creada solo para medir y **borrada** («Deleted successfully») [Observado]. Copia: `backups-r47/R47-B_TMP_pruebaParalelismo_borrada.sail`.

## 3. Cabecera (1a)

### 3.1 Cómo evalúa Appian las llamadas
Regla temporal con 5 modos, 5 ejecuciones por modo y póliza (`backups-r47/R47-B_paralelismo_tiempos.json`). Medianas en ms [Observado]:

| Póliza | Póliza sola | searchAPIClients sola | consultarSolicitudes sola | Suma | Las 3 como locales de un `a!localVariables` | Las 3 en `a!forEach` |
|---|---|---|---|---|---|---|
| 2001900000007 | 150 | 317 | 151 | 618 | **321** (≈ la más lenta → en paralelo) | 600 (≈ suma → en serie) |
| 0005912430 (Vida) | 2059 | 316 | 139 | 2514 | **1832** (≈ la más lenta → en paralelo) | 2767 (en serie) |

Máximos: 2001900000007 → locales 487, forEach 677; Vida → locales 2804, forEach 3068.

Conclusión [Observado + Inferido]: Appian ya ejecuta en paralelo las variables locales independientes de un mismo `a!localVariables`; `a!forEach` no paraleliza.

### 3.2 Estructura actual de la regla
`SCA2_obtenerDatosCabeceraLive` v3 ya tiene todas las llamadas como locales de un único `a!localVariables` (lo hizo una ronda anterior, doc 11 §3). Lo que sigue en serie depende de otro resultado [Observado en el código]:

| Llamada | Depende de |
|---|---|
| póliza (`SCA2_consultarPolizas` / `SCA2_consultarPolizaVidaRiesgo` / `SCA2_pObtenerPolizaFecha`) | tipo de póliza (`SCA2_obtenerTipoPoliza`) |
| datos personales, agente, vehículo, características, clave de consulta, estructura Vida | póliza |
| benefits, perfil, integralidad, contactMethod, address (API Clients) | `searchAPIClients` (id de cliente / documento) |
| siniestros | tipo y vehículo/matrícula |
| reserva de prima | documento del tomador (datos personales) |
| otras solicitudes | código interno del tomador |
| `SCA2_consultarCabecera` | documento, clave de producción, `nuuma` |

`infoUsuario`, `nuuma`, `searchAPIClients` y la rama de póliza ya corren en paralelo entre sí. No hay llamadas repetidas. Cualquier otro cambio exigiría lanzar llamadas sin tener aún sus parámetros o leer de caché, y la caché está fuera de alcance (decisión de negocio). **Por eso no se ha cambiado la regla.**

### 3.3 Mediciones (regla `SCA2_obtenerDatosCabeceraLive`, `testRule`, `idSolicitud = "0"`)
| Póliza | Toma | Tiempos (ms) | Mediana | Máximo |
|---|---|---|---|---|
| 2001900000007 | antes (6) | 1736, 1439, 1661, 1280, 1136, 1287 | 1363 | 1736 |
| 2001900000007 | después (5, misma regla) | 5765, 2914, 4777, 4417, 4573 | 4573 | 5765 |
| 0005912430 Vida | antes (6) | 5453, 5854, 5116, 4513, 4262, 4146 | 4814,5 | 5854 |
| 0005912430 Vida | después (5, misma regla) | 3472, 3730, 4211, 3714, 3776 | 3730 | 4211 |

Como la regla no ha cambiado, «después» es una toma de control: las diferencias vienen de los servicios externos de TEST, no de SCA2 [Inferido]. En la toma «antes» de 2001900000007 varios servicios devolvieron vacío (sin nombre, NIF, vehículo…), por eso tardó menos; en la toma «después» devolvieron datos completos. Durante la prueba en pantalla NSE devolvió además `StaleConnectionException` (ver §5).

### 3.4 Comparación campo a campo
Salidas completas de cada toma comparadas aplanando por campo (no se suben al repositorio porque contienen datos personales de cliente; tiempos en `backups-r47/R47-B_cabecera_tiempos*.json`) [Observado]:
- Las 6 tomas «antes» son iguales entre sí, y las 5 «después» también, en las dos pólizas.
- 2001900000007: 55 campos distintos entre «antes» y «después»; en 49 el valor «antes» era vacío/nulo (servicio sin datos en ese momento). Los otros 6 son datos que dependen de esos servicios: carterizado Sí→No, tréboles 0,00→1, antigüedad 0→7 años, prima `NO DISPONIBLE`→`638.17€`, tipo de productor y vehículo.
- 0005912430: 16 campos distintos; 15 vacíos «antes»; el otro es la clave de producción `250640710 / ` → `250640710 / 5298228`.
- Mensajes de error: la regla no cambia, así que los mensajes cuando falla una llamada son los mismos [Inferido].

## 4. Vigilancia de procesos (5)

### 4.1 Instancias ACTIVE investigadas (no canceladas)
| Instancia | PM (versión) | Desde (UTC) | Solicitud / póliza | Dónde está [Observado] | Por qué [Inferido] |
|---|---|---|---|---|---|
| 9157659 | `SCA2 CMD Mecanizar` (44) | 03/11 10:50:08 | 15788699 / 0732600005004 (NSE-Hogar, MECANIZADA) | Nodo 334 «Inducción Verti (CMP) [SUB encadenado]»: empezó 10:50:10.550 y no ha terminado. La otra rama (Recargar solicitud → Finalizar gestión SGC → Cambio nivel → Start CrearAccion → End) terminó a las 10:50:13.930 | El nodo 334 es un subproceso **síncrono** del componente de inducción CMP (PM `0002ea05-adcc-…`, no SCA2). Espera a que alguien complete la tarea humana de inducción en el site `inducir`; hasta entonces la instancia sigue ACTIVE |
| 11252029 | `SCA2 CMD Mecanizar` (44) | 03/11 10:56:15 | 15788703 / 0731480115289 (NSE-Hogar, MECANIZADA) | Igual: nodo 334 pendiente | Igual |
| 11252095 (encontrada) | `SCA2 CMD CompletarAccion` (49) | 03/11 11:12:24 | 15788703 (la misma que 11252029) | Nodo 12 «Start decidir»: arranca `SCA2 CMD Decidir` de forma síncrona con regla `"mecanizar"`, que a su vez lanza Mecanizar | Misma solicitud que 11252029, pero arrancó 16 min después. No hay ninguna instancia de `SCA2 CMD Decidir` activa (se borran al día), así que no se ha podido ver en qué subproceso concreto espera. Causa sin confirmar [Pendiente] |

Ruta del subproceso en Mecanizar: 332 «Write Tarea INDUCCION» → 334 subproceso → 333 «Write cierre Tarea INDUCCION» → 341 «End Inducción». El nodo 334 pasa el cliente con `rule!SCA_obtenerDatosCabecera` (objeto **SCA**, no SCA2; no se toca).

### 4.2 Aviso para operación
Ubicación: site SCA2 → Gestiones mantenimiento → Cuadro de mando (primera opción), encima de las pestañas. Solo se ve si hay casos.
Criterio: `SCA2 Tarea` tipo `INDUCCION`, estado `PENDIENTE`, creada hace más de 1 hora. Se usa la tarea porque el record no ve el estado de las instancias de proceso y la tarea `INDUCCION` es justo lo que deja Mecanizar en espera; no hace falta configuración de entorno [Inferido].
Resultado hoy en TEST (5 casos) [Observado en `testInterface` v28]:

| Solicitud | Póliza | Pendiente desde | Días | Instancia Mecanizar activa |
|---|---|---|---|---|
| 15788323 | 2002600060638 | 23/10/2026 13:46 | 18 | No (ya no existe) |
| 15788326 | 2002100339302 | 23/10/2026 14:10 | 18 | No |
| 15788540 | 2002100339314 | 29/10/2026 12:52 | 12 | No |
| 15788699 | 0732600005004 | 03/11/2026 11:50 | 7 | 9157659 |
| 15788703 | 0731480115289 | 03/11/2026 11:56 | 7 | 11252029 |

Las tres primeras tienen la tarea de inducción pendiente pero su instancia de Mecanizar ya no está activa (tarea «huérfana»: el proceso terminó o se canceló y la tarea nunca se cerró) [Inferido]. El texto del aviso lo tiene en cuenta («si sigue activo»). Ningún flujo de usuario cambia: el bloque es de solo lectura, sin enlaces ni acciones.

No se ha añadido el aviso a `/errores`: allí se listan filas `SCA2 Error` relanzables y mezclarlo cambiaría el uso de esa pantalla [decisión de R47-B].

### 4.3 Archivado y borrado de instancias terminadas
Los 17 PM SCA2 (CrearAccion, Decidir, CompletarAccion, Finalizar, Alta, Mecanizar, Caducar, BarridoCaducidad, Posponer, CambiarNivel, ObtenerDocumentoGD, GenerarPdf, MarcarErrorRelanzado, RegistrarDesincronizacion, MecanizarNSE, Batch Mecanizacion NSE, RefrescarCacheCabecera) tienen [Observado]: `cleanupAction = AUTO_DELETE`, borrado **1 día** después de terminar (`autoDeleteDelay 1`), alertas configuradas. (`autoArchiveDelay 7` no aplica con AUTO_DELETE.)

Conclusión: la limpieza ya existe y es agresiva; **no se cambia nada**. `/errores`, el relanzamiento y Process HQ no dependen de instancias terminadas: leen `SCA2 Error`, `SCA2 Transicion` y demás records en BD [Inferido de docs 61 y 62]. Lo que se acumula son solo las instancias que nunca terminan (§4.1), y esas no las borra ninguna configuración.

## 5. Pruebas con solicitudes nuevas
Recorrido en pantalla en el site SCA2 TEST con el usuario de pruebas (navegador). Solo solicitudes creadas en esta ronda; no se abrió ni tocó ninguna solicitud ni instancia histórica. Las solicitudes nuevas quedan con el alta terminada y la contra anulación sin hacer (no se ejecutaron argumentos ni acciones).

| ID | Caso | Esperado | Real | OK/KO | Solicitud | Instancia | Pasos realizados | Posible causa/solución |
|---|---|---|---|---|---|---|---|---|
| C1 | Medición cabecera antes/después (`testRule`) | Misma salida si la regla no cambia | Tomas internas idénticas; diferencias antes/después solo por datos de servicios TEST (§3.3–3.4) | OK | — (`idSolicitud "0"`) | — | 6 + 5 ejecuciones por póliza | La regla no se ha modificado |
| C2 | Paralelismo en Appian | Saber si un cambio de estructura gana tiempo | Locales ya paralelas; `a!forEach` en serie (§3.1) | OK | — | — | Regla temporal, 5 modos × 5 × 2 pólizas; borrada | Sin cambio en la cabecera |
| A1 | Alta Autos 2001900000007, primer GUARDAR | Solicitud creada | Error NSE: `com.ibm.websphere.ce.cm.StaleConnectionException: No hay más datos para leer del socket` en `TRON_APP.LN_EM_TARIFA_PPTA.P_VALIDAR_INF_POLIZA`. Captura `../img/r47-b-03-autos-guardar-error-nse.png` | KO (entorno) | — | — | ALTA → póliza → cabecera cargada (`r47-b-01`, `r47-b-02`) → GUARDAR | Conexión caída en NSE TEST (servicio externo), no SCA2. Al reintentar funcionó |
| A2 | Alta Autos 2001900000007, reintento | Solicitud creada y detalle con cabecera | Solicitud **15788862**; detalle con cliente, póliza, producto, clave 0360999, siniestros 0, reserva de prima y otras solicitudes. Capturas `../img/r47-b-23-autos-reintento-creada.png`, `r47-b-24…27` | OK | 15788862 | No visible en pantalla | GUARDAR → confirmaciones → VOLVER AL DETALLE | — |
| H0 | Alta Hogar 0732400122931 y 0731700076776 | — | «Existe una solicitud en curso para la póliza indicada» (son las de R47-A). Capturas `r47-b-04`, `r47-b-05` | N/A | — | — | ALTA → póliza; no se pulsó CONSULTAR SOLICITUD | Se usó otra póliza |
| H1 | Alta Hogar 0730080003210 | Solicitud creada y detalle con cabecera | Solicitud **15788861**; detalle con cliente, póliza, HOGAR FAMILIAR, clave 0505230, siniestros 0, reserva de prima. Capturas `../img/r47-b-10-hogar-alta-creada.png`, `r47-b-11…14` | OK | 15788861 | No visible en pantalla | ALTA → GUARDAR → confirmaciones → VOLVER AL DETALLE | — |
| V1 | Alta Vida 0005912430 | Cabecera cargada | Cabecera con cliente, póliza, agente y otras solicitudes. Capturas `r47-b-06…08` | OK | Sin solicitud (no se guarda: el alta Vida falla en CORE con 4004, R47-A) | — | ALTA → póliza Vida | — |
| T1 | Tiempo de cabecera en pantalla | Similar al de antes | 20–30 s aprox. en Autos y Vida desde ALTA (sin cronómetro) | Observación | 15788862 | — | — | Incluye la carga completa de la página de alta y los servicios TEST lentos; no es comparable con `testRule` |
| W1 | Aviso en cuadro de mando | Título con número y tabla de casos | «Aviso de operación: procesos en espera más de 1 hora (5)», filas 15788323, 15788326, 15788540, 15788699, 15788703; días 18, 18, 12, 7, 7; sin acciones. Captura `../img/r47-b-15-aviso-cinco-filas.png` | OK | — | 9157659, 11252029 (no tocadas) | Gestiones mantenimiento → Cuadro de mando | — |
| W2 | Regresión pestañas del cuadro | Todas pintan sin error | Las seis pestañas sin error (`r47-b-16…21`). En Resumen, con ventana estrecha, cifras y etiquetas de los KPI se parten en varias líneas | OK (observación) | — | — | Pulsar cada pestaña | La fila de 8 KPI no ha cambiado en R47-B (el bloque nuevo va encima de las pestañas); es el ancho de la ventana [Inferido] |
| W3 | Regresión `/errores` | Igual que antes | «Bandeja de errores (105)». Captura `../img/r47-b-22-regresion-bandeja-errores.png` | OK | — | — | Menú ERRORES; no se relanzó ni descartó nada | — |
| W4 | Aviso sin casos | No se muestra el bloque | No probado | PENDIENTE | — | — | — | Haría falta cerrar las tareas históricas; no se tocan |

Grabación del recorrido: adjunta en la sesión de Devin (no se sube al repositorio).

## 6. Lo que no se ha podido hacer / pendiente
- **Cabecera más rápida: no aplicada** porque no hay ganancia segura sin cambiar comportamiento (§3.2). La única mejora grande es la caché (N47-B1).
- **Comparación de tiempos antes/después no concluyente**: los servicios de TEST cambiaron entre tomas (datos vacíos en la toma «antes» de Autos; `StaleConnectionException` de NSE en la prueba en pantalla). Al no cambiar la regla, no afecta a la conclusión.
- **Aviso en `/errores`: no añadido** (se usa el cuadro de mando, doc 62).
- **Aviso cuando no hay casos** (W4) no probado.
- **Aviso para CompletarAccion 11252095**: el criterio por tarea `INDUCCION` no detecta instancias paradas por otra causa; para ver todas las instancias ACTIVE >1 h haría falta consultar el motor de procesos (Process HQ/monitor o un proceso programado), no los records. Queda propuesto (N47-B4).
- **Causa exacta de 11252095** sin confirmar (§4.1).
- **Cambios en archivado/borrado: no** (ya `AUTO_DELETE` a 1 día).
- **IDs de instancias** de las solicitudes nuevas no visibles en pantalla.
- No se ha cancelado ni modificado ninguna instancia ni solicitud histórica.

## 7. Para analistas y negocio
| # | Tema | Propuesta | Decide |
|---|---|---|---|
| N47-B1 | Caché de cabecera | Leer siempre de la caché (doc 43-D) bajaría la cabecera a ~0,1–0,2 s, pero puede mostrar datos de hasta el refresco anterior. Es la única mejora grande de tiempo que queda | Negocio |
| N47-B2 | Tareas de inducción pendientes | ¿Quién completa la tarea de inducción Verti en CMP para 15788699 y 15788703? Al completarla, Mecanizar (9157659, 11252029) y CompletarAccion (11252095) deberían terminar solos. ¿Se cierran las 3 tareas huérfanas (15788323, 15788326, 15788540) o se dejan? | Analistas / operación |
| N47-B3 | Subproceso síncrono | El nodo 334 de Mecanizar espera a una tarea humana: la mecanización queda «abierta» días. Hacerlo asíncrono cambia el flujo (cuándo se cierra la tarea `INDUCCION` y cuándo arranca CompletarAccion); no se ha tocado | Analistas |
| N47-B4 | Alerta activa | Hoy el aviso es visible en el cuadro de mando. Si se quiere correo/notificación diaria haría falta un proceso programado nuevo y un destinatario | Negocio / operación |
| N47-B5 | Retención | Instancias terminadas se borran al día. Si se quiere investigar más tiempo en Process HQ/monitor, subir `autoDeleteDelay` (p. ej. 7 días) a costa de memoria del motor | Operación |
