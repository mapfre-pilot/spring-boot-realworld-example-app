# SMK Pruebas de Humo — Appian DEV

Aplicación Appian `SMK Pruebas de Humo` (DEV, `mapfrespain-dev`) para lanzar pruebas de humo tras instalaciones de apps, cambios de versión de Appian o intervenciones en el SaaS.

## Arquitectura

| Capa | Objetos |
|---|---|
| Catálogo | Record `SMK Test` (tabla `SMK_TEST`): codigo, nombre, categoria (PLATAFORMA/DB/S3/HTTP/APIGW), sistema, criticidad, activo, orden, umbralMs |
| Ejecuciones | Record `SMK Ejecucion` (`SMK_EJECUCION`): estado (EN_CURSO/OK/WARN/KO), origen, motivo, lanzadoPor, totales, duracionMs |
| Resultados | Record `SMK Resultado` (`SMK_RESULTADO`): un registro por prueba y ejecución, con resultado OK/KO/WARN/SKIP, mensaje, detalle técnico, duración |
| Pruebas | 70 integraciones HTTP `SMK_INT_HTTP_<host>` (GET ligero a `/smk-smoke-probe` reutilizando el Connected System real: valida DNS, red, TLS y autenticación), `SMK_INT_S3_ListBuckets` (CS `CMP Conexion AWS S3`), 40 pruebas DB (`jdbc/Appian` + 39 Connected Systems DataSource: consulta read-only de 1 fila a un record type que usa cada CS, validando credenciales, red y esquema), comprobación del motor de procesos |
| Lógica | `SMK_seleccionarPruebas` (filtro por códigos/categorías/sistemas), `SMK_ejecutarPrueba` (dispatcher por código), `SMK_evaluarHttp`, `SMK_evaluarIntegracion`, `SMK_construirResultado`, `SMK_resumenEjecucion` |
| Runner | PM `SMK Ejecutar Pruebas` (selecciona → crea ejecución → MNI paralelo de `SMK Ejecutar Prueba`, uno por prueba → espera (timer 10 s, máx. 24 intentos) → consolida → cierra). Constante `SMK_PM_EJECUTAR_PRUEBAS` |
| API | Web APIs `smoke_runs` (POST), `smoke_run` (GET), `smoke_run_results` (GET), `smoke_tests` (GET) |
| UI | Site `Pruebas de Humo` (Panel, Ejecutar, Histórico, Catálogo) |

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
→ 202 {"ejecucionId": 12, "totalPruebas": 9, "estadoUrl": "/suite/webapi/smoke_run?id=12", ...}

GET /suite/webapi/smoke_run?id=12            → estado, terminada, totales
GET /suite/webapi/smoke_run_results?id=12&resultado=KO,WARN
GET /suite/webapi/smoke_tests?categoria=HTTP
```
Body de `smoke_runs`: `codigos`, `categorias`, `sistemas` (listas, vacías = sin filtro), `motivo`, `origen`.
Desde un proceso Appian: subproceso `SMK Ejecutar Pruebas` o `a!startProcess(cons!SMK_PM_EJECUTAR_PRUEBAS, ...)`.

## Añadir una prueba

1. Crear la integración/regla de la prueba (read-only, sin efectos de negocio).
2. Añadir el caso en `SMK_ejecutarPrueba` devolviendo `a!map(resultado, mensaje, detalle)` (o `rule!SMK_evaluarHttp(...)` / `rule!SMK_evaluarIntegracion(...)`).
3. Dar de alta la fila en `SMK Test` (codigo único, categoria, sistema, umbralMs, activo=true).

## Baseline v2 (ejecución #6, 102 pruebas activas, 15 s): 102 OK

10 pruebas de host quedaron **desactivadas** (activo=false, marcadas en su descripción) porque no obtienen respuesta desde DEV (ver `ko_diag.md`): api-gw.core.pfgop.dev (OAuth CS `PPP Proxy API GW`), www.apisb.mapfre.net:25003 (OAuth), backend.pgo.mapfre.net (OAuth), api-product-sgc...pre.mapfredigitalhealth.com (OAuth), core8.pre:26025, wmbig3is.pre:26019, ses000a204616.es:26023, wmbig1is.desa:25018 (timeout 15 s), webservices.desa.mapfre.net, esp-cvm2...pfadmsop.dev:250544 (puerto inválido en el CS). Se reactivan desde el catálogo cuando el CS quede corregido.

## Limitaciones / siguientes pasos

- Las pruebas HTTP miden alcance del host, no la corrección funcional del endpoint.
- API GW OT: el CS OAuth `PPP Proxy API GW` falla antes de enviar la petición (probable obtención de token); requiere revisión del CS/credenciales en DEV. Se puede añadir un endpoint de lectura autorizado cuando exista.
- No hay prueba de escritura (DB/S3) ni pruebas de plug-ins; añadir como wrappers con recursos probe si se desea.
- Rule Test Cases: pendiente la app de tests y el nodo `Start Rule Tests (Applications)` integrado como prueba de categoría `UNITARIAS`.
- Seguridad de las Web APIs: crear cuenta de servicio + API key y dar permiso al grupo de la app.

## Despliegue a TEST / PRO
Ver `deploy/GUIA_DESPLIEGUE.md`. Resumen: la app no contiene Connected Systems ni constantes de entorno; reutiliza los CS/record types de las apps de negocio ya desplegadas en cada entorno. Pasos: exportar paquete → (opcional) `deploy/01_ddl_smk.sql` → importar → grupos → site *Catálogo* → **Sincronizar catálogo** (carga las pruebas de `SMK_catalogoBase` que falten; alternativa `deploy/02_catalogo_smk.sql`) → *Ejecutar* → baseline → activar/desactivar por entorno.

## Evolución del catálogo (detectar conexiones / BD nuevas)
- **Fuente de verdad**: regla `SMK_catalogoBase` (112 pruebas). `SMK_catalogoPendiente` devuelve las que faltan en `SMK_TEST`; el botón *Sincronizar catálogo* las inserta (nunca actualiza ni borra las existentes). Así una prueba nueva se añade una vez en DEV y llega a TEST/PRO con el paquete.
- **Descubrimiento**: `discovery/discover_smk.py` (vía Dev MCP, solo lectura) inventaría apps → Connected Systems (tipo, baseUrl, auth) → record types por data source, y lo compara con el snapshot anterior y con el catálogo base. Genera `snapshot_dev.json` y `hallazgos_dev.md` con: nuevos, desaparecidos, URL cambiada y sin cobertura. Procedimiento completo para convertir hallazgos en pruebas: `discovery/PLAYBOOK_descubrimiento.md`.
- Las pruebas propuestas nacen inactivas; se activan desde *Catálogo*.
