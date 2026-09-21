# SMK Pruebas de Humo — Guía de despliegue a TEST / PRO

## 1. Qué contiene la aplicación (paquete `SMK Pruebas de Humo`)

| Tipo | Nº | Observaciones |
|---|---|---|
| Record types | 3 | `SMK Test`, `SMK Ejecucion`, `SMK Resultado` (fuente `jdbc/Appian`, tablas `SMK_TEST`, `SMK_EJECUCION`, `SMK_RESULTADO`) |
| Expression rules | 8 | incluye `SMK_catalogoBase` (catálogo como diseño) y `SMK_catalogoPendiente` |
| Integraciones | 72 | 71 HTTP GET ligeros + `SMK_INT_S3_ListBuckets`. Todas reutilizan Connected Systems de **otras** aplicaciones |
| Process models | 2 | `SMK Ejecutar Pruebas` (runner, MNI) y `SMK Ejecutar Prueba` |
| Web APIs | 4 | `smoke_runs` (POST), `smoke_run`, `smoke_run_results`, `smoke_tests` (GET) |
| Interfaces | 6 | Panel, Ejecutar, Histórico, Detalle, Catálogo y Comparar |
| Site | 1 | `/suite/sites/smoke-tests` |
| Constantes | 2 | `SMK_PM_EJECUTAR_PRUEBAS`, `SMK_ARTIFACTS_FOLDER` (ninguna con valor dependiente de entorno) |
| Grupos | 2 | `SMK Administrators` / `SMK Users` |
| Connected Systems propios | **0** | La app no lleva credenciales ni URLs: usa los CS del entorno destino |

Inventario completo: `objetos_app.json`.

## 2. Dependencias externas (precedentes) — deben existir en el destino ANTES de importar

- **71 Connected Systems** de otras apps (HTTP y S3) usados por las integraciones `SMK_INT_*`.
- **39 record types** de otras apps usados por las pruebas `DB_*` en `SMK_ejecutarPrueba` (uno por Connected System de BD).
- Data source **`jdbc/Appian`** (BD de negocio).

Si las mismas aplicaciones de negocio están desplegadas en TEST/PRO (flujo normal DEV → TEST → PRO), estos precedentes existen con los mismos UUIDs y con la URL/credenciales propias del entorno: **no hay nada que reconfigurar**. Si una app de negocio no está en el destino, el import avisará de precedentes faltantes en su integración/rama; en ese caso importar igualmente y desactivar esa prueba en el Catálogo (o quitarla del catálogo base).

Verificación previa recomendada: en Appian Designer del destino, *Compare and Deploy* (o importar en modo inspección) y revisar la lista de "missing precedents".

## 3. Pasos

1. **Exportar** el paquete de la app `SMK Pruebas de Humo` desde DEV (Designer → aplicación → Export). No hace falta Import Customization File: no hay constantes de entorno.
2. **Tablas**: al importar, Appian crea/actualiza `SMK_TEST`, `SMK_EJECUCION` y `SMK_RESULTADO` en `jdbc/Appian` si el usuario del data source tiene permiso DDL (los record types tienen *Source configuration* con creación de tabla). Si no es así, ejecutar antes `01_ddl_smk.sql` en la BD de negocio del destino.
3. **Importar** el paquete (inspeccionar primero). Comprobar que no hay errores en integraciones ni en `SMK_ejecutarPrueba`.
4. **Seguridad**: añadir usuarios/grupos a `SMK Administrators` (operan el site) y `SMK Users` (solo consulta). Las Web APIs heredan la seguridad de la app. Los objetos deben heredar la seguridad de la aplicación, evitando role maps explícitos redundantes.
5. **Visibilidad para el aviso KO**: configurar el grupo `SMK Administrators` con visibilidad **Pública** en cada entorno. El runner usa ese grupo como destinatario del nodo `Notificar KO`; con visibilidad restringida el proceso puede terminar KO aunque la prueba ya haya finalizado.
6. **Catálogo**: abrir el site → página *Catálogo* → pulsar **Sincronizar catálogo**. Inserta en `SMK_TEST` las pruebas del catálogo base (`SMK_catalogoBase`) que falten; no modifica las existentes ni sus flags `activo`. La interfaz permite filtrar Activas, Desactivadas y Pendientes de revisión; al desactivar exige `motivoInactivo` y las altas automáticas usan `origenAlta="DESCUBRIMIENTO"`. Alternativa sin UI: `02_catalogo_smk.sql` (idempotente por `CODIGO`).
7. **Comparativa**: comprobar que el site conserva la página *Comparar* inmediatamente después de *Histórico*. Permite seleccionar ejecuciones y revisar regresiones, nuevas, ausentes, mejoras e iguales.
8. **Baseline del entorno**: *Ejecutar* → Todas → motivo "Baseline <entorno> <fecha>". Revisar KO/WARN:
   - KO "sin respuesta" en un host = ese CS no es alcanzable desde ese entorno (red/whitelist/OAuth). Es un hallazgo real; si es esperado (host de otro entorno) desactivar la prueba en *Catálogo*.
   - Las 10 pruebas que vienen desactivadas de DEV (hosts DESA/PRE, OAuth) pueden **activarse** en TEST/PRO si allí los hosts sí responden.
   - Ajustar `umbralMs` si la latencia del entorno es distinta.
9. **Web APIs desde pipelines/procesos de instalación**: crear una cuenta de servicio en el destino, añadirla al grupo `Administrators`, generar su API key (Admin Console → Web API Authentication) y guardarla en el gestor de secretos del pipeline (nunca en la app). Ejemplo de llamada:
   ```
   POST https://<host>/suite/webapi/smoke_runs
   {"categorias": [], "motivo": "Post-instalación <app> <versión>", "origen": "INSTALACION_APP"}
   → {"ejecucionId": N}
   GET  https://<host>/suite/webapi/smoke_run?id=N
   GET  https://<host>/suite/webapi/smoke_run_results?id=N&resultado=KO,WARN
   ```

## 4. Qué NO viaja con el paquete (y cómo se resuelve)

| Elemento | Dónde vive | Solución |
|---|---|---|
| Filas de `SMK_TEST` (catálogo) | Datos | Botón *Sincronizar catálogo* (o `02_catalogo_smk.sql`) |
| Flags `activo` / umbrales ajustados por entorno | Datos | Se gestionan en cada entorno desde *Catálogo* |
| Historial de ejecuciones | Datos | No se migra; cada entorno tiene su propio histórico |
| Credenciales / URLs de los sistemas | Connected Systems de otras apps | Ya son por entorno |
| Cuenta de servicio + API key | Admin Console | Crear por entorno |
| Miembros de los grupos SMK | Grupos | Alta por entorno; `SMK Administrators` debe mantener visibilidad Pública para el aviso KO |

## 5. Notas

- Los códigos de las pruebas HTTP incluyen el host que tenía el CS en DEV al crearse (`HTTP_<HOST>_<PUERTO>`). Son identificadores estables: la prueba llama a la integración, que usa el CS, que en cada entorno apunta a su host real. Si en PRO el nombre confunde, cambiar `nombre`/`sistema` en el catálogo base (solo etiqueta).
- El runner usa `SMK Administrators` para notificar por email los resultados KO y `SMK Users` para consulta. El grupo administrador debe tener visibilidad Pública en cada entorno.
- La política de Data Management prevista para ambos process models es **eliminar instancias 1 día después de finalizar, sin archivar**. El MCP no permite editar esta propiedad: debe configurarse y confirmarse desde Designer. Si no se ha aplicado aún, el subproceso `SMK Ejecutar Prueba` queda pendiente de esa configuración.
- Los rule test cases de las 10 reglas SMK están creados y validados: **10/10 correctos**.
- El campo `detalle` de `SMK_RESULTADO` es texto largo (`TEXT`); no se usa en filtros.
