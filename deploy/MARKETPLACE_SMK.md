# SMK · Pruebas de Humo de la plataforma Appian

**Categoría:** Administración / Operación de plataforma · **Site:** `Pruebas de Humo` (`/suite/sites/smoke-tests`) · **Propietario:** Arquitectura Appian

## ¿Qué es?

SMK Pruebas de Humo es la aplicación que comprueba, en menos de un minuto, que la plataforma Appian y todos los sistemas a los que se conecta siguen funcionando. Está pensada para ejecutarse **después de cualquier intervención**: instalación o despliegue de una aplicación, cambio de versión de Appian, intervención del SaaS, cambio de red/certificados o de credenciales en un sistema externo.

No sustituye a las pruebas funcionales de cada aplicación: responde a la pregunta *"¿sigue estando todo accesible y respondiendo?"*.

## ¿Para qué se utiliza?

- **Validar una intervención**: lanzar las pruebas al terminar y confirmar que nada ha dejado de responder.
- **Comparar antes / después**: ejecutar antes de la intervención (baseline) y después, y ver exactamente qué pruebas han pasado de OK a KO.
- **Diagnóstico rápido** ante una incidencia: saber en segundos si el problema es de un sistema concreto (una BD, el API Gateway, S3) o general.
- **Integración en pipelines**: los procesos de despliegue la invocan por Web API y deciden con el resultado.

## ¿Qué comprueba?

| Categoría | Qué se prueba | Cómo |
|---|---|---|
| **PLATAFORMA** | Motor de procesos, base de datos de negocio de Appian (`jdbc/Appian`), usuario en ejecución | Arranque de proceso, consulta read-only |
| **DB** | Cada Connected System de base de datos (40 bases de datos: PostgreSQL/Aurora, Oracle, SQL Server…) | Consulta de 1 fila a un record type real de ese sistema: valida red, credenciales y esquema |
| **HTTP** | Cada host externo cubierto por HTTP (70 hosts mediante Connected System + 12 hosts sin Connected System: APIs de negocio, ESB, Core7, Denodo, Salud Digital, Azure…) | Petición GET ligera a través del Connected System real o, para los 12 casos Sin CS, mediante `SMK_INT_HTTP_url` y la URL por constante: valida DNS, red, TLS y alcance del host |
| **APIGW** | API Gateway de OT y proxies | Obtención de token y llamada a través del gateway |
| **S3** | Almacenamiento AWS S3 corporativo | ListBuckets con el Connected System de S3 |

La cobertura del catálogo es de **124 pruebas** (114 activas): 112 pruebas existentes y 12 pruebas HTTP `INT_SIN_CS` para hosts de integraciones sin Connected System. Estas 12 aparecen en Catálogo con la marca **Sin CS** y usan la integración compartida `SMK_INT_HTTP_url` con URL base por constante `SMK_URL_*`. Cada prueba es *read-only*: no crea, modifica ni borra datos de negocio.

### Validación DEV

La versión 3 de `SMK_INT_HTTP_url` tiene timeout de 15 s y clasifica como alcanzable toda respuesta con `statusCode`, incluidos 403/404. En la ejecución exacta de las 12 pruebas INT_SIN_CS (**#26**) se obtuvieron 10 OK y 2 KO: `api-product-clients.clientes.private.pre.mapfredigitalhealth.com` sin respuesta HTTP y `core7.desa.mapfre.net` con timeout.

### Criterio de resultado

- **OK** – el sistema responde correctamente (para hosts, cualquier respuesta HTTP, incluido 4xx/5xx, demuestra que el host es alcanzable y la autenticación del Connected System funciona; en las pruebas Sin CS, cualquier respuesta HTTP demuestra alcance del host).
- **WARN** – responde, pero por encima del umbral de latencia configurado para esa prueba.
- **KO** – sin respuesta: DNS, red, TLS, timeout, error de credenciales o de obtención de token.
- **SKIP** – prueba sin implementación.

**Estado global de la ejecución:** KO si hay algún KO · WARN si hay algún WARN · OK en caso contrario. Si termina en KO, los miembros de `SMK Administrators` reciben un correo con las incidencias.

## ¿Cómo se usa?

### Desde el site

1. **Panel** – semáforo global de la última ejecución, KPIs (pruebas, OK, WARN, KO, duración), semáforo por categoría y últimas ejecuciones. *Ver detalle* abre en un modal el resumen completo de la ejecución y, desde ahí, el detalle técnico de cada prueba.
2. **Ejecutar** – elige *Todas*, *Por categoría*, *Por sistema* o *Pruebas concretas*, indica el motivo (p. ej. "Post-despliegue APP X v1.2") y el origen y pulsa **Ejecutar pruebas de humo**. Una ejecución completa tarda ~30 s.
3. **Histórico** – todas las ejecuciones, con filtros, de la más reciente a la más antigua.
4. **Comparar** – dos ejecuciones lado a lado: regresiones (OK → KO/WARN), mejoras y pruebas nuevas.
5. **Catálogo** – todas las pruebas con estado (Activa / Desactivada / Pendiente de revisión), motivo de desactivación, umbral de latencia; permite activar/desactivar y sincronizar el catálogo base.

### Desde un pipeline (Web API, cuenta de servicio con API key)

```
POST /suite/webapi/smoke_runs   {"categorias":["DB","S3","PLATAFORMA"],"motivo":"Post-instalación","origen":"INSTALACION_APP"}
  → 202 {"ejecucionId": N, "estadoUrl": ".../smoke_run?id=N", "resultadosUrl": ".../smoke_run_results?id=N"}
GET  /suite/webapi/smoke_run?id=N                       → estado, terminada, totales
GET  /suite/webapi/smoke_run_results?id=N&resultado=KO,WARN
GET  /suite/webapi/smoke_tests                          → catálogo
```
El pipeline sondea `smoke_run` hasta `terminada=true` y decide con `estado`.

## Qué NO hace

- No prueba la lógica funcional de las aplicaciones (para eso están sus rule test cases).
- No escribe en ningún sistema externo.
- No detecta por sí sola sistemas nuevos: una tarea automática semanal (lunes, madrugada) inventaría los Connected Systems y record types de la plataforma y da de alta las pruebas nuevas **desactivadas**, pendientes de revisión en Catálogo.

## Acceso

- **`SMK Users`**: acceso al site, lanzar pruebas y consultar resultados.
- **`SMK Administrators`**: además, activar/desactivar pruebas, ajustar umbrales, sincronizar catálogo y recibir los avisos de KO.
- Pipelines: cuenta de servicio miembro de `SMK Users` con API key.

## Datos y limpieza

Ejecuciones y resultados se guardan en las tablas `SMK_EJECUCION` / `SMK_RESULTADO` (histórico permanente). Las instancias de proceso se eliminan automáticamente 1 día después de finalizar.

## Soporte

Equipo de Arquitectura Appian. Documentación técnica, guía de despliegue a TEST/PRO y expresiones en la rama `feature/pruebas-humo` de `mapfre-pilot/spring-boot-realworld-example-app`.
