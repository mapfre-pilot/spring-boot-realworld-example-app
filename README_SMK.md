# SMK Pruebas de Humo — Appian DEV

Aplicación Appian `SMK Pruebas de Humo` (DEV, `mapfrespain-dev`) para lanzar pruebas de humo tras instalaciones de apps, cambios de versión de Appian o intervenciones en el SaaS.

## Arquitectura

| Capa | Objetos |
|---|---|
| Catálogo | Record `SMK Test` (tabla `SMK_TEST`): codigo, nombre, categoria (PLATAFORMA/DB/S3/HTTP/APIGW), sistema, criticidad, activo, motivoInactivo, origenAlta, orden, umbralMs |
| Ejecuciones | Record `SMK Ejecucion` (`SMK_EJECUCION`): estado (EN_CURSO/OK/WARN/KO), origen, motivo, lanzadoPor, totales, duracionMs |
| Programaciones | Record `SMK Programacion` (`SMK_PROGRAMACION`): estado (PENDIENTE/LANZADA/CANCELADA), fechaProgramada, alcance y enlace a la ejecución resultante |
| Resultados | Record `SMK Resultado` (`SMK_RESULTADO`): un registro por prueba y ejecución, con resultado OK/KO/WARN/SKIP, mensaje, detalle técnico, duración |
| Pruebas | 70 integraciones HTTP `SMK_INT_HTTP_<host>` con Connected System y 12 pruebas HTTP adicionales `HTTP_<host>` mediante la integración sin Connected System `SMK_INT_HTTP_url` (GET a `/smk-smoke-probe`, URL por las constantes `SMK_URL_*`), `SMK_INT_S3_ListBuckets` (CS `CMP Conexion AWS S3`), 40 pruebas DB (`jdbc/Appian` + 39 Connected Systems DataSource: consulta read-only de 1 fila a un record type que usa cada CS, validando credenciales, red y esquema), comprobación del motor de procesos |
| Lógica | `SMK_seleccionarPruebas` (filtro por códigos/categorías/sistemas), `SMK_ejecutarPrueba` (dispatcher por código), `SMK_evaluarHttp`, `SMK_evaluarIntegracion`, `SMK_construirResultado`, `SMK_resumenEjecucion` |
| Runner | PM `SMK Ejecutar Pruebas` (selecciona → crea ejecución → MNI paralelo de `SMK Ejecutar Prueba`, uno por prueba → espera (timer 10 s, máx. 24 intentos) → consolida → cierra). Constante `SMK_PM_EJECUTAR_PRUEBAS` |
| Programación | Regla `SMK_getProgramaciones`, PM `SMK Programar Pruebas` (timer hasta `fechaProgramada`, relee la programación y sólo lanza si sigue PENDIENTE; crea `SMK Ejecucion` con origen PROGRAMADO y motivo con `[Programación #N]`, y lanza `SMK Ejecutar Pruebas`; borrado a 1 día). Constante `SMK_PM_PROGRAMAR_PRUEBAS` |
| API | Web APIs `smoke_runs` (POST), `smoke_run` (GET), `smoke_run_results` (GET), `smoke_tests` (GET) |
| UI | Site `Pruebas de Humo` (Panel, Ejecutar, Histórico, Comparar, Programar, Catálogo); interfaz `SMK_UI_Programar` |

## Criterio de resultado

- **HTTP/APIGW/PLATAFORMA (host)**: cualquier respuesta HTTP (incl. 401/403/404/500) = `OK` (host alcanzable y autenticación del CS resuelta); sin respuesta (DNS, red, TLS, timeout, fallo al obtener token OAuth) = `KO`.
- **S3 / integraciones genéricas**: `success` de la integración → `OK`, en otro caso `KO`.
- **DB**: `a!queryRecordType` (batch 1) sobre un record type del Connected System devuelve → `OK`; error de conexión/credenciales → `KO`. 7 CS de BD sin record types dependientes no tienen prueba (LCK DB AWS, CMD Prueba orafi053, CMP DB Plan Familia, CMP DB Respuesta Componente, FAS Schema FAS, TVA BD Aurora PostgreSQL, TI Aurora PostgreSQL).
- Cualquier `OK` cuya duración supere `umbralMs` pasa a `WARN`. La duración medida es la del subproceso (incluye planificación del motor), no sólo la llamada.
- Estado global: `KO` si hay algún KO o faltan resultados; `WARN` si hay algún WARN; si no, `OK`.

## Uso desde pipelines / procesos de intervención

```
POST /suite/webapi/smoke_runs
{"categorias":["PLATAFORMA","DB","S3"], "motivo":"Despliegue APP X v1.2", "origen":"INSTALACION_APP"}
→ 202 {"ejecucionId": 20, "processId": 537316617, "estado": "EN_CURSO",
       "estadoUrl": "/suite/webapi/smoke_run?id=20", "resultadosUrl": "/suite/webapi/smoke_run_results?id=20"}

GET /suite/webapi/smoke_run?id=20            → estado, terminada, totales (404 si no existe)
GET /suite/webapi/smoke_run_results?id=20&resultado=KO,WARN
GET /suite/webapi/smoke_tests?categoria=HTTP
```
Autenticación: cabecera `Appian-API-Key: <key>` de una cuenta de servicio miembro de `SMK Users` (la key vive en el gestor de secretos del pipeline, nunca en la app ni en el repo).

Body de `smoke_runs`: `codigos`, `categorias`, `sistemas` (listas, vacías = sin filtro), `motivo`, `origen`. El POST es **asíncrono**: crea la `SMK Ejecucion` en estado `EN_CURSO` (por eso el `ejecucionId` de la respuesta es definitivo) y arranca el runner pasándole ese id como parámetro; el pipeline debe sondear `smoke_run` hasta `terminada=true` (una ejecución completa tarda ~30 s) y decidir con `estado` (`OK`/`WARN`/`KO`). Verificado por HTTP en DEV con la cuenta de servicio: filtros por códigos (#19), categorías (#20), sistemas (#21) y sin filtros (#22, 102/102 OK); 404 para id inexistente.

Las Web APIs de estado/resultados consultan mediante las reglas `SMK_getEjecucion(ejecucionId)` y `SMK_getResultados(ejecucionId, resultados)` (así se respeta el límite de 4.000 caracteres por expresión de Web API).
Desde un proceso Appian: subproceso `SMK Ejecutar Pruebas` o `a!startProcess(cons!SMK_PM_EJECUTAR_PRUEBAS, ...)`.

## Añadir una prueba

1. Crear la integración/regla de la prueba (read-only, sin efectos de negocio).
2. Añadir el caso en `SMK_ejecutarPrueba` devolviendo `a!map(resultado, mensaje, detalle)` (o `rule!SMK_evaluarHttp(...)` / `rule!SMK_evaluarIntegracion(...)`).
3. Dar de alta la fila en `SMK Test` (codigo único, categoria, sistema, umbralMs, activo=true, `origenAlta="BASE"`).

## Catálogo, comparación y aviso KO

- La página **Catálogo** permite filtrar por `Activas`, `Desactivadas`, `Pendientes de revisión` y `Sin Connected System`. Las pruebas descubiertas se crean con `origenAlta="DESCUBRIMIENTO"` y quedan inactivas hasta revisión humana. Al desactivar una prueba se exige `motivoInactivo`; la activación limpia el motivo y conserva el origen.
- La página **Comparar**, situada después de Histórico, permite seleccionar las ejecuciones anterior y posterior, ver regresiones/mejoras/nuevas/ausentes/sin cambio y filtrar las filas sin cambios. Las etiquetas muestran `#id · fecha · estado · motivo`.
- Cuando una ejecución termina en `KO`, el runner envía el resumen por email a los usuarios obtenidos de la constante de grupo `SMK_GRUPO_ADMINISTRADORES`, incluyendo las pruebas KO/WARN y el enlace al Histórico. La constante se despliega con seguridad heredada en `SMK Rules and Constants` y debe apuntar al grupo administrador de cada entorno.

## Programación de ejecuciones (página Programar)

La página **Programar** permite indicar fecha y hora (mínimo 2 minutos en el futuro), alcance (**Todas**, **Por categoría**, **Por sistema** o **Pruebas concretas**), motivo y origen. La programación queda `PENDIENTE` y aparece inmediatamente en la tabla; puede cancelarse mientras permanece PENDIENTE. La cancelación marca `CANCELADA` y el proceso termina sin lanzar al despertar del timer. Al llegar la hora, pasa a `LANZADA` y muestra el enlace **Ver detalle** a la ejecución resultante. La página muestra KPIs de próxima ejecución y programaciones pendientes. El proceso convierte la fecha/hora local mostrada por el site usando la zona horaria del servidor.

Verificado en DEV: las programaciones **#3**, **#5** y **#6** se lanzaron a la hora exacta y crearon las ejecuciones **#27**, **#28** y **#29**; la programación **#4** se canceló sin lanzar.

## Seguridad, pruebas y limpieza

- Los objetos de la aplicación heredan la seguridad de la app siempre que el objeto lo permite; se evitan role maps explícitos redundantes. `devin` conserva acceso por pertenencia a `SMK Administrators`.
- Las 10 expression rules SMK cubiertas por Estado de prueba de regla tienen casos de prueba: **10/10 con resultado correcto** en la validación realizada.
- Los cinco process models (`SMK Ejecutar Pruebas`, `SMK Ejecutar Prueba`, `SMK Ver Ejecucion`, `SMK Ver Resultado` y `SMK Programar Pruebas`) tienen política de **eliminar las instancias 1 día después de finalizar, sin archivar**; aplicada y publicada en DEV desde Designer (Process Modeler → Propiedades → Data Management). Tras importar en otro entorno hay que comprobarla en Designer.
- `SMK Administrators` y `SMK Users` pueden crear y cancelar programaciones; no hay una restricción adicional por grupo dentro de la aplicación, y el acceso lo proporciona el site.

## Baseline v2 (ejecución #6, 102 pruebas activas, 15 s): 102 OK

10 pruebas de host quedaron **desactivadas** (activo=false, marcadas en su descripción) porque no obtienen respuesta desde DEV (ver `ko_diag.md`): api-gw.core.pfgop.dev (OAuth CS `PPP Proxy API GW`), www.apisb.mapfre.net:25003 (OAuth), backend.pgo.mapfre.net (OAuth), api-product-sgc...pre.mapfredigitalhealth.com (OAuth), core8.pre:26025, wmbig3is.pre:26019, ses000a204616.es:26023, wmbig1is.desa:25018 (timeout 15 s), webservices.desa.mapfre.net, esp-cvm2...pfadmsop.dev:250544 (puerto inválido en el CS). Se reactivan desde el catálogo cuando el CS quede corregido.

## Validación DEV de INT_SIN_CS

La integración compartida `SMK_INT_HTTP_url` usa timeout de 15 s y considera éxito cualquier respuesta con `statusCode` presente, incluidos 403/404. La revalidación exacta de las 12 pruebas (ejecución **#26**) obtuvo **10 OK y 2 KO**: KO por falta de respuesta en `api-product-clients.clientes.private.pre.mapfredigitalhealth.com` y timeout en `core7.desa.mapfre.net`.

## Limitaciones / siguientes pasos

- Las pruebas HTTP miden alcance del host, no la corrección funcional del endpoint.
- API GW OT: el CS OAuth `PPP Proxy API GW` falla antes de enviar la petición (probable obtención de token); requiere revisión del CS/credenciales en DEV. Se puede añadir un endpoint de lectura autorizado cuando exista.
- No hay prueba de escritura (DB/S3) ni pruebas de plug-ins; añadir como wrappers con recursos probe si se desea.
- Rule Test Cases: pendiente la app de tests y el nodo `Start Rule Tests (Applications)` integrado como prueba de categoría `UNITARIAS`.
- Seguridad de las Web APIs: crear cuenta de servicio + API key y dar permiso al grupo de la app.

## Despliegue a TEST / PRO
Ver `deploy/GUIA_DESPLIEGUE.md`. Resumen: la app no contiene Connected Systems; reutiliza los CS/record types de las apps de negocio ya desplegadas en cada entorno. Para las tablas y la carga inicial del catálogo, la ruta recomendada es Liquibase: `liquibase --changelog-file=deploy/liquibase/db.changelog-master.xml update` contra `jdbc/Appian` del entorno destino. Pasos: exportar paquete → ejecutar Liquibase → importar → configurar `SMK_GRUPO_ADMINISTRADORES` por entorno → grupos → site *Catálogo* → **Sincronizar catálogo** → *Ejecutar* → baseline → activar/desactivar por entorno. `deploy/01_ddl_smk.sql` y `deploy/02_catalogo_smk.sql` se mantienen como fallback.

## Evolución del catálogo (detectar conexiones / BD nuevas)
- **Fuente de verdad**: regla `SMK_catalogoBase` (124 pruebas: 112 existentes y 12 `INT_SIN_CS`). `SMK_catalogoPendiente` devuelve las que faltan en `SMK_TEST`; el botón *Sincronizar catálogo* las inserta (nunca actualiza ni borra las existentes). Así una prueba nueva se añade una vez en DEV y llega a TEST/PRO con el paquete.
- **Descubrimiento**: `discovery/discover_smk.py` (vía Dev MCP, solo lectura) inventaría apps → Connected Systems (tipo, baseUrl, auth) → record types por data source, y lo compara con el snapshot anterior y con el catálogo base. Genera `snapshot_dev.json` y `hallazgos_dev.md` con: nuevos, desaparecidos, URL cambiada y sin cobertura. Procedimiento completo para convertir hallazgos en pruebas: `discovery/PLAYBOOK_descubrimiento.md`.
- Las pruebas propuestas nacen inactivas; se activan desde *Catálogo*.
