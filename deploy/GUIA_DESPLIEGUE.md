# SMK Pruebas de Humo — Guía de despliegue a TEST / PRO

## 1. Qué contiene la aplicación (paquete `SMK Pruebas de Humo`)

| Tipo | Nº | Observaciones |
|---|---|---|
| Record types | 4 | `SMK Test`, `SMK Ejecucion`, `SMK Resultado`, `SMK Programacion` (fuente Connected System `SMK Database AWS`, Aurora PostgreSQL, esquema `smk_pruebashumo`; tablas `smk_test`, `smk_ejecucion`, `smk_resultado`, `smk_programacion`) |
| Expression rules | 9 | incluye `SMK_catalogoBase`, `SMK_catalogoPendiente` y `SMK_getProgramaciones` |
| Integraciones | 72 | 71 HTTP GET ligeros + `SMK_INT_S3_ListBuckets`. Todas reutilizan Connected Systems de **otras** aplicaciones |
| Process models | 5 | `SMK Ejecutar Pruebas` (runner, MNI), `SMK Ejecutar Prueba`, `SMK Ver Ejecucion`, `SMK Ver Resultado` y `SMK Programar Pruebas` (timer hasta fecha programada) |
| Web APIs | 4 | `smoke_runs` (POST), `smoke_run`, `smoke_run_results`, `smoke_tests` (GET) |
| Interfaces | 7 | Panel, Ejecutar, Histórico, Detalle, Catálogo, Comparar y `SMK_UI_Programar` |
| Site | 1 | `/suite/sites/smoke-tests` |
| Constantes | 4 | `SMK_PM_EJECUTAR_PRUEBAS`, `SMK_PM_PROGRAMAR_PRUEBAS`, `SMK_ARTIFACTS_FOLDER`, `SMK_GRUPO_ADMINISTRADORES` |
| Grupos | 2 | `SMK Administrators` / `SMK Users` |
| Connected Systems propios | **0** | La app no lleva credenciales ni URLs: usa los CS del entorno destino |

Inventario completo: `objetos_app.json`.

## 2. Dependencias externas (precedentes) — deben existir en el destino ANTES de importar

- **71 Connected Systems** de otras apps (HTTP y S3) usados por las integraciones `SMK_INT_*`.
- **39 record types** de otras apps usados por las pruebas `DB_*` en `SMK_ejecutarPrueba` (uno por Connected System de BD).
- Connected System **`SMK Database AWS`** (Aurora PostgreSQL), creado en el entorno destino con el mismo UUID (viaja en el paquete; credenciales/URL específicas por entorno se fijan en el fichero de personalización de la importación o en el propio CS), esquema `smk_pruebashumo` y usuario de BD creados previamente.
- Data source **`jdbc/Appian`** sólo para la prueba `DB_APPIAN_BUSINESS` de la base de datos de negocio, no para los record types SMK.

Si el Connected System `SMK Database AWS` y las mismas aplicaciones de negocio están desplegados en TEST/PRO (flujo normal DEV → TEST → PRO), estos precedentes existen con los mismos UUIDs y con la URL/credenciales propias del entorno: **no hay nada que reconfigurar**, salvo introducir por entorno la contraseña del CS. Si una app de negocio no está en el destino, el import avisará de precedentes faltantes en su integración/rama; en ese caso importar igualmente y desactivar esa prueba en el Catálogo (o quitarla del catálogo base).

Verificación previa recomendada: en Appian Designer del destino, *Compare and Deploy* (o importar en modo inspección) y revisar la lista de "missing precedents".

## 3. Pasos

1. **Exportar** el paquete de la app `SMK Pruebas de Humo` desde DEV (Designer → aplicación → Export).
2. **Tablas**: la ruta recomendada es ejecutar Liquibase contra la URL PostgreSQL del entorno destino y el esquema `smk_pruebashumo`: `liquibase --changelog-file=deploy/liquibase/db.changelog-master.xml --default-schema-name=smk_pruebashumo update`. Crea/actualiza `smk_test`, `smk_ejecucion`, `smk_resultado` y `smk_programacion`, y carga el catálogo inicial sólo si `smk_test` está vacía. `01_ddl_smk.sql` y `02_catalogo_smk.sql` se mantienen como fallback legado de MariaDB/`jdbc/Appian`.
3. **Importar** el paquete (inspeccionar primero). Comprobar que no hay errores en integraciones ni en `SMK_ejecutarPrueba`.
4. **Seguridad**: añadir usuarios/grupos a `SMK Administrators` (operan el site) y `SMK Users` (solo consulta). Ambos grupos pueden crear y cancelar programaciones; no hay restricción adicional por grupo dentro de la aplicación, y el acceso lo proporciona el site. Las Web APIs heredan la seguridad de la app. Los objetos deben heredar la seguridad de la aplicación, evitando role maps explícitos redundantes.
5. **Destinatarios del aviso KO**: en `SMK Rules and Constants`, configurar `SMK_GRUPO_ADMINISTRADORES` con el grupo administrador real del entorno. El runner obtiene los usuarios miembros mediante `touser(getdistinctusers(cons!SMK_GRUPO_ADMINISTRADORES))`; comprobar que los miembros tienen email antes de ejecutar el baseline.
6. **Personalización de URLs sin Connected System**: antes de ejecutar el catálogo, editar `deploy/smk_import_customization.properties` y fijar en cada entorno los 12 valores `SMK_URL_*` (incluido `http://core7.desa.mapfre.net` en DEV si aplica). Existe una única integración compartida sin Connected System, `SMK_INT_HTTP_url`; no hay ningún Connected System adicional que remapear.
7. **Catálogo**: abrir el site → página *Catálogo* → pulsar **Sincronizar catálogo**. Inserta en `smk_test` las pruebas del catálogo base (`SMK_catalogoBase`) que falten; no modifica las existentes ni sus flags `activo`. La interfaz permite filtrar Activas, Desactivadas, Pendientes de revisión y Sin Connected System; al desactivar exige `motivoInactivo` y las altas automáticas usan `origenAlta="DESCUBRIMIENTO"`. Alternativa sin UI: la carga inicial de Liquibase (`changes/05_smk_catalogo_data.xml`) o, como fallback legado, `02_catalogo_smk.sql`.
8. **Comparativa**: comprobar que el site conserva la página *Comparar* inmediatamente después de *Histórico*. Permite seleccionar ejecuciones y revisar regresiones, nuevas, ausentes, mejoras e iguales.
La validación DEV más reciente de las 12 pruebas `INT_SIN_CS` (ejecución **#26**) obtuvo 10 OK y 2 KO; la versión 3 de `SMK_INT_HTTP_url` considera OK cualquier respuesta con `statusCode` (incluidos 403/404) y usa timeout de 15 s.

9. **Baseline del entorno**: *Ejecutar* → Todas → motivo "Baseline <entorno> <fecha>". Revisar KO/WARN:
   - KO "sin respuesta" en un host = ese CS no es alcanzable desde ese entorno (red/whitelist/OAuth). Es un hallazgo real; si es esperado (host de otro entorno) desactivar la prueba en *Catálogo*.
   - Las 10 pruebas que vienen desactivadas de DEV (hosts DESA/PRE, OAuth) pueden **activarse** en TEST/PRO si allí los hosts sí responden.
   - Ajustar `umbralMs` si la latencia del entorno es distinta.
10. **Web APIs desde pipelines/procesos de instalación**: crear una cuenta de servicio en el destino, añadirla al grupo `SMK Users`, generar su API key (Admin Console → Web API Authentication) y guardarla en el gestor de secretos del pipeline (nunca en la app ni en el repo). Ejemplo de llamada (cabecera `Appian-API-Key: <key>`):
   ```
   POST https://<host>/suite/webapi/smoke_runs
   {"categorias": [], "motivo": "Post-instalación <app> <versión>", "origen": "INSTALACION_APP"}
   → 202 {"ejecucionId": N, "processId": P, "estado": "EN_CURSO", "estadoUrl": "/suite/webapi/smoke_run?id=N", ...}
   GET  https://<host>/suite/webapi/smoke_run?id=N            (sondear hasta "terminada": true; ~30 s)
   GET  https://<host>/suite/webapi/smoke_run_results?id=N&resultado=KO,WARN
   ```
   El POST es asíncrono: la ejecución se crea `EN_CURSO` antes de arrancar el runner, por lo que `ejecucionId` es definitivo desde la respuesta. Verificado en DEV (#19–#22) con la cuenta `apigw.devops`.
11. **Data Management** de los cinco process models (`SMK Ejecutar Pruebas`, `SMK Ejecutar Prueba`, `SMK Ver Ejecucion`, `SMK Ver Resultado` y `SMK Programar Pruebas`): comprobar tras importar que sigue en *Eliminar procesos 1 día después de finalizar, sin archivar*. Está aplicado en DEV desde Designer; debe confirmarse también en cada entorno destino.

## 4. Qué NO viaja con el paquete (y cómo se resuelve)

| Elemento | Dónde vive | Solución |
|---|---|---|
| Filas de `smk_test` (catálogo) | Datos | Botón *Sincronizar catálogo* (o `02_catalogo_smk.sql`) |
| Flags `activo` / umbrales ajustados por entorno | Datos | Se gestionan en cada entorno desde *Catálogo* |
| Historial de ejecuciones | Datos | No se migra; cada entorno tiene su propio histórico |
| Credenciales / URLs de los sistemas | Connected Systems de otras apps | Ya son por entorno |
| Cuenta de servicio + API key | Admin Console | Crear por entorno |
| Miembros de los grupos SMK | Grupos | Alta por entorno; configurar `SMK_GRUPO_ADMINISTRADORES` con el grupo administrador de cada entorno |
| Programaciones PENDIENTES | Instancias de proceso y datos del entorno origen | No viajan con el paquete; se crean de nuevo en el entorno destino |
| Contraseña de `SMK Database AWS` | Connected System | No viaja; introducirla en el entorno destino después de importar |

## 5. Notas

- Los códigos de las pruebas HTTP incluyen el host que tenía el CS en DEV al crearse (`HTTP_<HOST>_<PUERTO>`). Son identificadores estables: la prueba llama a la integración, que usa el CS, que en cada entorno apunta a su host real. Si en PRO el nombre confunde, cambiar `nombre`/`sistema` en el catálogo base (solo etiqueta).
- El runner usa los usuarios miembros de `SMK_GRUPO_ADMINISTRADORES` para notificar por email los resultados KO y `SMK Users` para consulta. La constante debe revisarse después de cada importación por entorno.
- La política de Data Management de los cinco process models es **eliminar instancias 1 día después de finalizar, sin archivar**; ya está aplicada en DEV desde Designer y debe confirmarse tras importar en cada entorno.
- El timer de `SMK Programar Pruebas` usa la conversión de la fecha/hora local del usuario a la zona horaria del servidor; la hora mostrada en el site es la hora local del usuario.
- Los rule test cases de las 10 reglas SMK están creados y validados: **10/10 correctos**.
- El campo `detalle` de `smk_resultado` es texto largo (`TEXT`); no se usa en filtros.
