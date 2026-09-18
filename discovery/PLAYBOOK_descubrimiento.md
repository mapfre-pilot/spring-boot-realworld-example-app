# Playbook — Descubrimiento de novedades para SMK Pruebas de Humo

Objetivo: cada vez que una aplicación de Appian añade, cambia o elimina un Connected System (HTTP, base de datos, S3, plugin) o un record type sobre un CS de BD, detectarlo y proponer/dar de alta la prueba de humo correspondiente, sin activar nada peligroso automáticamente.

## Por qué fuera de Appian
Las expresiones SAIL no pueden enumerar los Connected Systems ni los record types de la instancia; el Dev MCP sí (`listApplications`, `listConnectedSystems`, `getConnectedSystem`, `listRecordTypes`). Por eso el descubrimiento lo ejecuta Devin (sesión programada), y el resultado se materializa en Appian como diseño (`SMK_catalogoBase` + integración + rama del dispatcher), que luego viaja a TEST/PRO con el paquete y se carga con **Sincronizar catálogo**.

## Pasos de cada ejecución

1. Cargar la skill `appian` y comprobar que el MCP `appian-dev-mcp-desarrollo-05c9` responde (`listApplications`).
2. Ejecutar `discover_smk.py` (contenido inline en `scripted_tools`). Produce:
   - `discovery/snapshot_dev.json` — inventario actual (CS con tipo, baseUrl, apps; record types por data source; códigos del catálogo).
   - `discovery/hallazgos_dev.md/json` — **Nuevos** (CS que no estaban en el snapshot anterior), **Desaparecidos**, **URL cambiada**, **Sin prueba de humo en el catálogo**.
3. Para cada hallazgo **Sin prueba / Nuevo**:
   - **HTTP** (`system.http`, `system.http.openapi`): crear integración `SMK_INT_HTTP_<host>` (GET, `relativePath: "/smk-smoke-probe"`, timeout 10 s, CS del hallazgo) en la app SMK; añadir rama `HTTP_<HOST>[_PUERTO]` en `SMK_ejecutarPrueba` que llame a `rule!SMK_evaluarHttp`; añadir fila en `SMK_catalogoBase` con `categoria: "HTTP"` (o `"APIGW"` si el host es un API gateway), `activo: false`.
   - **DB** (`system.[DataSource].*`): si tiene record types dependientes, elegir uno y su PK (`listRecordTypeFields`) y añadir rama `DB_<CS>` con `a!queryRecordType(... batchSize: 1, fetchTotalCount: true)`; fila `categoria: "DB"`, `activo: false`. Si no tiene record types: solo listarlo en el informe (no crear objetos en esquemas de negocio).
   - **Plugin/S3/SharePoint**: solo informar; requiere decisión humana sobre qué operación de lectura usar.
   - Ejecutar la prueba nueva una vez con `testRule` sobre la integración / `SMK_ejecutarPrueba(codigo)` para validar que funciona antes de proponerla.
4. Para **URL cambiada**: actualizar `sistema`/`nombre` de la fila en `SMK_catalogoBase` (el código no cambia) y anotarlo en el informe.
5. Para **Desaparecidos**: no borrar; marcar `activo: false` en el catálogo base y anotarlo. Además en DEV desactivar la fila en `SMK_TEST` (via `Catálogo` o `updateRecordData`).
6. Lanzar el runner (`testProcessModel` de `SMK Ejecutar Pruebas` sin filtros) y comparar con la ejecución anterior: pruebas que pasan de OK a KO/WARN son regresiones a destacar.
7. Informe al usuario (mensaje o canal acordado): resumen de novedades, pruebas propuestas (quedan **inactivas** hasta que alguien pulse *Activar* en Catálogo), regresiones y acciones manuales pendientes. Adjuntar `hallazgos_dev.md`.

## Reglas
- Solo operaciones read-only contra los sistemas: nunca crear tablas, escribir datos de negocio ni llamar a endpoints de token/escritura.
- Las pruebas nuevas nacen con `activo: false` (propuesta). La activación es humana, desde el site.
- No modificar Connected Systems, integraciones ni record types de otras aplicaciones.
- No copiar ni imprimir credenciales (los `getConnectedSystem` devuelven contraseñas enmascaradas; no persistir otros campos sensibles).
- Si el MCP responde 405 (plugin read-only) o errores de auth, informar y parar.

## Extensión a TEST/PRO
Requiere un Dev MCP por entorno (hoy solo existe el de DEV). Con él, el mismo script (cambiar `S` y `ENV`) permite comparar el inventario de cada entorno con el catálogo y detectar CS que existen en PRO pero no en DEV.
