# 56 · Optimización de `SCA2_consultarListadoArgumentosREST` — análisis y propuesta

> Alcance: análisis y propuesta. **No se ha modificado ningún objeto Appian, servicio ni dato.**
> Entorno analizado: Appian TEST (`mapfrespain-test`). Leyenda: **[Observado]** comprobado en objeto/log/código · **[Inferido]** deducido, a confirmar · **[Pendiente]** no verificable con lo disponible.

## 1. Resumen ejecutivo

- Es **la integración más lenta de SCA2**: media **8,7 s** por llamada, **29 % de llamadas fallidas** y **2 timeouts de 300 s** (5 min con la pantalla bloqueada). En SCA, en el mismo periodo, la equivalente tarda **11,2 s** de media y llegó a **60‑67 s** de media en 2024‑2025. [Observado]
- El tiempo **no se pierde en Appian** (preparación y transformación ≈ 1 ms); es todo **tiempo de backend**. [Observado]
- Por dentro (código Plastic del core legacy) el listado hace **3 consultas + 4‑5 accesos a BD por cada argumento** (patrón N+1), repite la misma validación de perfil una vez por argumento, y en el primer acceso **genera** el argumentario llamando al motor de reglas **BRMS/ILOG** e insertándolo. Además la respuesta trae los **tréboles (DEFCART)**, que viene de otro servicio. [Observado en legacy / Inferido para el REST]
- Propuesta: **fraccionar** en (1) catálogo de argumentos casi estático → **cacheado en Appian**, (2) estado de argumentos de la solicitud → **servicio de lectura rápido** (1 consulta), (3) **generación del argumentario** (BRMS) → **fuera de la pantalla**, en el proceso, (4) **tréboles** → llamada separada y solo cuando hace falta. Con mejoras rápidas en Appian antes (timeout, evitar llamadas duplicadas, fallo rápido).

## 2. Qué es el servicio [Observado]

| Campo | Valor |
|---|---|
| Integración SCA2 | `SCA2_consultarListadoArgumentosREST` (`5db48f50-b77a-47db-9ed9-25264966228a`) |
| Equivalente SCA | `SCAC_consultarListadoArgumentosREST` (`c0d1a3cc-7aff-49fa-b9ec-384e246b53a8`) |
| Sistema conectado | `SCAC SCA Webservice` (Basic Auth, usuario técnico; compartido con SCA) |
| Endpoint | `POST {baseUrl}/es_pca_gestionartareas_bbe-web/esp/api/1.0/consultarListadoArgumentos` |
| Base URL en TEST | `https://webservices.pre.mapfre.net:26004/` (**TEST apunta a PRE**) |
| Cabecera | `Host = cons!SCAC_VAL_HOST_WEBSERVICES` |
| Body | `a!toJson_17r1(ri!body)`, `removeNullsFromJson` activo |
| Timeout | **300 s** · uso `QUERY` · log de request/response desactivado |
| Regla envoltorio | `SCA2_consultarListadoArgumentos` → `a!fromJson(result.body)` si `success`, si no `null` |

**Entrada** (la construye `SCA2_ContraAnulacionOpciones`): compañía, póliza, solicitud, gestión, nivel, línea de negocio, compañía contraria, clave de producción, detalle/motivo/causa de anulación, catalogación, canal de entrada, fecha de anulación, anula técnico/experto, mecanizada, centro emisor, `modoAcceso "G"`, `numApli` e `infoUsuario` (nuuma, compañía, perfil, subperfil).

**Salida**: `listadoArgumentos[]` (código y descripción del tipo, obligatorio, orden, estado, usuario, fecha de ejecución, nivel, `mcaEconomico`, …) y `treboles[]` (DEFCART: `codTrebol`, `descTrebol`, `trebolesDisponibles`, `trebolesRecomendados`).

## 3. Dependencias y uso [Observado]

Dependientes (índice `objects/dependents` de Appian):

```
SCA2_ContraAnulacionPrincipal
  └─ SCA2_ContraAnulacionOpciones  (L195: a!refreshVariable(refreshOnVarChange: ri!idTarea))
       ├─ SCA2_consultarListadoArgumentos ─► SCA2_consultarListadoArgumentosREST
       └─ SCA2_ContraAnulacionCompaniaCatalogacion (L73: botón RECARGAR ARGUMENTO) ─► mismo servicio
```

- En SCA: `SCA_ContraAnulacionOpciones` (L660) lo llama con **`rand()`**, es decir, **sin caché: se relanza en cada reevaluación de la pantalla**; también `SCA_ContraAnulacionOpcionesEstrategicas` y `SCA_CompañiaContrariaCatalogacion`. SCA2 ya mejora esto (solo se relanza al cambiar de tarea). Esto explica en parte las 13.918 llamadas de SCA frente a 540 de SCA2.
- Uso en SCA2: se calcula al abrir la tarea de Contra Anulación, **en serie** con otras llamadas de la misma pantalla (cabecera, propietario, póliza renovada, equipos/centro emisor…). Con la respuesta, Appian ordena argumentos, cruza tréboles DEFCART por `codTrebol = codTipoArgumento`, obtiene la campaña del argumento seleccionado, y después llama a `SCA2_consultarTipoArg` y `SCA2_obtenerSVADisponibles`.
- Mismo backend que SCA: cualquier cambio en el servicio afecta a las dos aplicaciones.

## 4. Tiempos medios (perflogs de TEST, 3 nodos) [Observado]

Fuente: `integration_details.csv` (agregados por minuto, ponderados por número de llamadas) e `integration_trace.csv` (llamada a llamada; solo contiene muestras de SCA).

| Servicio | Periodo | Llamadas | Fallos | Timeouts | Media | Máx. |
|---|---|---:|---:|---:|---:|---:|
| **SCA2** listado | 24‑09 → 26‑10‑2026 | 540 | 156 (29 %) | 2 | **8,7 s** | 300 s |
| **SCA** listado | ≥ 20‑09‑2026 | 436 | 43 (10 %) | 1 | **11,2 s** | 300 s |
| SCA listado | jun‑2024 → oct‑2026 | 13.918 | 1.744 | 52 | 46,6 s | 300 s |

Evolución de la media mensual en SCA: 2024‑2025 entre **52 y 71 s**; 2026 baja a **7‑25 s** (oct‑2026: 7,2 s). La muestra llamada a llamada de SCA (413 llamadas) da **mediana 64 s, p90 68 s, p95 69 s**, con dos grupos claros: respuestas muy rápidas (< 1 s, casi siempre errores 400/404/409) y respuestas de más de 30 s.

Comparación con otras integraciones de la **misma pantalla** de SCA2 (mismo periodo): consultarAnulacionPoliza 6,3 s · simularAnulacion 5,1 s · scaServiciosReglas 4,0 s · determinarContacto 2,3 s · consultarCatalogacion 2,1 s · APIClients_Benefits 1,2 s. **El listado de argumentos es la llamada que más pesa en la apertura de la tarea.**

Limitaciones: los fallos rápidos bajan la media, por lo que la media de las llamadas correctas es mayor que 8,7 s [Inferido]; no hay traza llamada a llamada de SCA2 para calcular percentiles [Pendiente].

## 5. Qué hace el servicio por dentro (repos Plastic)

Repos revisados (ZIP `SCA2 Servicios SCA`, 9 repos): `ES_SSCC_SCA_CODE`, `_DESIGN`, `_DOCUM`, `_GAIACORE_CODE`, `_GAIA_INTEGRATION_CODE`, `_MAPFAMI_PROCANU_SGD_CONFIG`, `_PCA`, `_PCA006`, `_SGO`.

**Limitación importante**: el código del REST `es_pca_gestionartareas_bbe-web` **no está en los repos** [Observado]. Sí está el **core legacy** que implementa la misma operación (`IContraAnularPCA.listarDetalleArgumentosCntrAnu`, core7) y el frontal JSF que la orquestaba. Lo que sigue describe ese core; que el REST lo reutilice tal cual es **[Inferido]** (mismo nombre de operación, mismos campos de salida y mismas tablas).

### 5.1 Listado (core `ContraAnularCON.consultarListadoArgumentos`) [Observado]

1. `consultarGestionActual(solicitud)` → gestión activa y nivel de intervención (tabla `A2139003_MES`).
2. `isContraAnulCedida` → consulta el detalle de la gestión para validar perfil/nivel (Red MAPFRE en nivel II).
3. Consulta principal `obtenerInformacionArgumentoPorCodSolicitud`:
   `A2139006_MES` (argumentos de la solicitud) × `D2139004_MES` (tipos de argumento, `MCA_INH='N'`, misma línea de negocio) × textos de idioma × `A2139003_MES` (gestión de tipo 2, nivel actual o anteriores ya ejecutados), ordenado por nivel, orden y texto.
4. **Por cada argumento** (`consultarDetalleArgumentos` → `TipoArgumentoCON.consultarDetalleTipoArgumento`):
   - vuelve a ejecutar `isContraAnulCedida` (**la misma validación del paso 2, repetida N veces**);
   - lee el tipo de argumento (`D2139004_MES`);
   - lee sus parámetros (`D2139012_MES`);
   - lee el argumento de la solicitud por clave (`A2139006_MES`) para compañía contraria e importe;
   - si no hay compañía contraria, **consulta la cabecera completa de la solicitud**.
   - Los errores se ignoran (el argumento queda sin detalle).
5. Filtra los argumentos **no vigentes** (`FEC_VIGENCIA` > hoy), valida y ordena.
6. Busca las observaciones de contra anulación de la solicitud.

Coste: **≈ 3 + N × (4 a 5) accesos a BD** para N argumentos, más la transformación a la salida. Con 10‑20 argumentos son 40‑100 viajes a BD por apertura de pantalla.

### 5.2 Generación del argumentario (BRMS/ILOG) [Observado en legacy]

El frontal legacy lo explica en código: *«si devuelve la excepción de que no existen argumentos para esta solicitud, se consultan los datos a BRMS y se cargan en el sistema»*. Es decir, la **primera vez** se llama a `IObtenerArgumentario.obtenerArgumentario` (motor de reglas, core8 `PCAApp_CCFSAArgumentar`) con canal, perfil, catalogación, agente, coberturas, motivo/detalle/causa, póliza y vehículo; el resultado se inserta (`generarCntrAnu`) y luego se lista. El body del REST lleva exactamente esos datos (línea de negocio, clave de producción, motivo, causa, catalogación, mecanizada, nivel…), por lo que el REST **probablemente** hace «listar → si no hay, generar con BRMS → listar» en una sola llamada [Inferido]. Encaja con los dos grupos de tiempos observados.

### 5.3 Tréboles (DEFCART) [Observado en legacy / Inferido en REST]

El legacy obtiene los tréboles de otro servicio (`ConsultarTreboles` / `IConsultarTrebolesClubM`). El REST los devuelve en la misma respuesta (`treboles`), por lo que **añade otra llamada externa al mismo tiempo de espera** [Inferido].

### 5.4 Consecuencia sobre el argumento 999 (ronda 34) [Inferido]

Un argumento solo aparece si **existe una fila en `A2139006_MES` para esa solicitud**, el tipo no está inhabilitado, su vigencia ya ha empezado y la línea de negocio coincide. Dar de alta el tipo `999` en `D2139004_MES` **no basta**: tiene que asignarlo el argumentario (BRMS) al generarse; las solicitudes ya generadas no lo recibirán. Explicaría lo observado en R34‑B y no sería un fallo de Appian.

## 6. Dónde se va el tiempo [Inferido]

```
Apertura de la tarea de Contra Anulación (SCA2)
 ├─ llamadas previas en serie (cabecera, propietario, póliza, equipos…)        ~varios s
 └─ consultarListadoArgumentos                                                  ~8,7 s (hasta 300 s)
      ├─ (1ª vez) BRMS obtenerArgumentario + inserción                          lento y variable
      ├─ listado: 3 consultas + N×(4‑5) consultas (N+1, validación repetida)    crece con N
      └─ tréboles DEFCART (servicio externo)                                    se suma en serie
```

## 7. Propuesta

### 7.1 Fase 1 — Mejoras rápidas solo en Appian (sin servicio nuevo)

| Mejora | Qué se gana | Riesgo |
|---|---|---|
| Bajar el timeout de 300 s a 30‑60 s y mostrar mensaje con «Reintentar» | Evita 5 min de pantalla bloqueada | Bajo |
| No relanzar el servicio en `RECARGAR ARGUMENTO` si nada ha cambiado (reutilizar la respuesta de Opciones) | Menos llamadas | Bajo |
| Fallo rápido: no llamar si faltan datos obligatorios (perfil, nivel, solicitud) y clasificar los errores 400/409 | Reduce parte del 29 % de fallos | Bajo |
| Calcular el `body` con datos ya cargados y evitar llamadas previas en serie que solo sirven para el body (p. ej. equipos/centro emisor) cuando se puedan cachear por usuario | Menos espera antes del listado | Bajo |
| Activar log de request/response **solo en TEST** durante la medición | Ver qué parte tarda | Bajo |

### 7.2 Fase 2 — Fraccionar: parte en Appian, parte en un servicio rápido (recomendada)

| Pieza | Dónde | Cómo |
|---|---|---|
| **Catálogo de tipos de argumento** (descripción, instrucciones, obligatorio, económico, URL/aplicación a lanzar, parámetros, vigencia, inhabilitado) — tablas `D2139004_MES`/`D2139012_MES` | **Appian** | Cacheado (record type sincronizado o consulta cacheada) y refrescado al guardar en el **Mantenimiento** de SCA2 + refresco diario. Es casi estático y lo gestiona el propio negocio. |
| **Estado de los argumentos de la solicitud** (`A2139006_MES` + gestión) | **Servicio rápido de solo lectura** | Una consulta con los joins ya resueltos (sin N+1 ni validación repetida). Objetivo < 300 ms. Appian cruza con el catálogo. |
| **Validación perfil/nivel** (`isContraAnulCedida`) | **Appian** | Se hace una vez con los datos de gestión que ya tiene la pantalla. |
| **Generación del argumentario (BRMS) + inserción** | **Proceso Appian, fuera de la pantalla** | Al crear la tarea de contra anulación / cambiar de nivel se llama a «generar argumentario» de forma asíncrona; la pantalla solo lista. Si aún no está generado: aviso «preparando argumentario» y refresco. |
| **Tréboles DEFCART** | **Llamada separada** | Solo cuando la pantalla los necesita (argumento con campaña/económico seleccionado), no en cada apertura. |
| Montaje de URL de aplicación a lanzar y tooltips | **Appian** | Ya está en SAIL. |

Servicio nuevo propuesto (arquitectura de referencia: arquetipo Spring Boot y publicación por Marketplace/API corporativa):

- `GET /solicitudes/{id}/argumentos?nivel=` → estado de argumentos de la solicitud (lectura).
- `POST /solicitudes/{id}/argumentario` → generación idempotente (BRMS + inserción), llamada desde proceso.
- `GET /solicitudes/{id}/treboles` → DEFCART bajo demanda.

**Alternativa sin servicio nuevo** (si el equipo de backend puede tocar `es_pca_gestionartareas_bbe-web`): mismo contrato, pero dentro del servicio actual: sustituir el bucle N+1 por 2 consultas (argumentos con joins + parámetros en bloque), validar perfil una sola vez, cachear el catálogo, separar generación y tréboles con un indicador en el body, y revisar índices de `A2139006_MES` por `NUM_SOLICITUD_PCA, NUM_GESTION_PCA`. Beneficia también a SCA sin tocar Appian.

### 7.3 Ganancia esperada [Inferido — a medir]

- Apertura habitual (argumentario ya generado): de ~8,7 s a **< 1 s** de esta pieza (1 lectura + catálogo en caché).
- Primera apertura: el coste de BRMS pasa al proceso y deja de verse en pantalla.
- Menos fallos y ningún bloqueo de 5 min.

## 8. Riesgos y convivencia con SCA

- **Consistencia**: el catálogo cacheado debe refrescarse al guardar en el Mantenimiento (si no, un cambio de descripción o URL tarda en verse). La generación asíncrona necesita un estado «pendiente» en pantalla.
- **Convivencia SCA/SCA2**: mismas tablas y mismo backend. El servicio de lectura no escribe, por lo que no interfiere; la generación debe seguir siendo la misma (mismo BRMS, misma inserción) para que SCA y SCA2 vean los mismos argumentos.
- **Seguridad**: usuario técnico Basic Auth compartido; el servicio nuevo debería ir con autenticación corporativa (Entra ID/OAuth vía Marketplace) y no exponer datos de cliente que la pantalla no usa.
- **Entorno**: TEST llama a webservices de **PRE**; confirmar antes de medir o cambiar.
- **Paridad**: hay que conservar orden, filtro de vigencia, nivel/ejecutados de niveles anteriores, `mcaEconomico` y cruce de tréboles.

## 9. Plan de transición y medición

1. **Línea base** (1‑2 semanas, sin cambios): perflogs por UUID → llamadas, media, p50/p95, fallos, timeouts; activar log de request/response solo en TEST para separar «primera vez» vs «ya generado».
2. **Fase 1** (Appian): aplicar mejoras rápidas y repetir la medición.
3. **Confirmar el REST**: pedir el código de `es_pca_gestionartareas_bbe-web` (no está en los repos) para validar §5.2‑5.4.
4. **Fase 2**: servicio de lectura + catálogo en Appian + generación en proceso + tréboles separados, activable por constante para volver atrás.
5. **Comparativa antes/después** con solicitudes nuevas en TEST, en paralelo con SCA (mismas pólizas, mismos argumentos y tréboles).

## 10. Pendientes

- Código fuente de `es_pca_gestionartareas_bbe-web` (y `sca_servicios`) — **[Pendiente]**, necesario para confirmar orquestación interna, uso de BRMS y tréboles.
- Acceso de Appian a las tablas `TRON_LD`/PCA (lectura directa del catálogo) — **[Pendiente]**.
- Percentiles de SCA2 llamada a llamada (la traza de TEST no los recoge) — **[Pendiente]**.
