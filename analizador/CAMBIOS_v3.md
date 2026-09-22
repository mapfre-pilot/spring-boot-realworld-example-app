# appian_static_analyzer v3.0.0 — especificación de cambios

Contexto: el script se ejecuta en un GitHub Action que SOLO recibe (a) el zip del paquete/aplicación exportado de Appian y (b) el fichero de Health Check. No hay acceso a Appian. Solo stdlib Python 3.8+.
Fixtures reales (exports de DEV): `fixtures/smk.zip` (143 objetos, 5 PMs, 4 record types) y `fixtures/adm.zip` (572 objetos, 74 PMs, 12 record types, 7 CS). Extraídos en `fixtures/smk/` y `fixtures/adm/`. Salidas del script actual en `baseline/*.json`.

## 1. Veredicto = solo gates (G01–G10)

`gate_verdict`: eliminar `unjustified_high`. Reglas:
- Cualquier gate `FAIL` sin justificar → `NO_APTO`.
- Si no hay FAIL y hay algún `REVIEW` o `JUSTIFIED` → `APTO_CON_CONDICIONES`.
- Si todo PASS/NA → `APTO`.
- Nuevo veredicto `ERROR` si `analysis.errors` no vacío (zip ilegible, HC ilegible cuando se pasó, cobertura < `minCoverage`, ver §7).
Los findings heurísticos (PRF-*, DEP-*, NAM-*, DOC-*, MNT-*, …) siguen en `findings`/score pero NO afectan al veredicto. Opción en config `qualityGate: {"enabled": false, "maxHigh": N}` que, solo si `enabled`, añade un gate `G11 "Calidad de código"` (FAIL si HIGH heurísticos sin justificar > maxHigh). Por defecto desactivado.

Exit codes (`--gate`): APTO=0, APTO_CON_CONDICIONES=3, NO_APTO=1, ERROR=2. Sin `--gate` mantener 0 salvo ERROR=2.

## 2. Modelos de proceso — extractores (formato real, ver fixtures)

Estructura real (`processModelHaul/process_model_port/pm`):
```
<pm><meta>
  <uuid><![CDATA[…]]></uuid>
  <name><string-map><pair><locale lang="en"/><value>…</value></pair><pair><locale lang="es"/><value><![CDATA[SMK Ver Ejecucion]]></value></pair></string-map></name>
  <pm-notification-settings>
    <custom-settings>true|false</custom-settings>
    <notify-initiator>…</notify-initiator><notify-owner>…</notify-owner>
    <usersandgroups><people><type>4096</type><stringId><![CDATA[_e-…_8047]]></stringId></people>…</usersandgroups>
    <recipients-exp/>
  </pm-notification-settings>
  <cleanup-action>2</cleanup-action><auto-archive-delay>7</auto-archive-delay><auto-delete-delay>1</auto-delete-delay>
  <timeZoneId><![CDATA[Europe/Madrid]]></timeZoneId><useProcessInitiatorTimeZone>true</useProcessInitiatorTimeZone>
</meta>
<nodes><node uuid="…"> … <ac><local-id>core.0|core.1|internal.17|internal.16|core.7|internal.38|…</local-id><name><![CDATA[User Input Task]]></name> …
   <assignments><assignee><type>5|29</type>…</assignee></assignments> (solo en tareas de usuario)
   <escalations/>  ó  <escalations>…</escalations>
   <pre-triggers><timer-trigger index="0"><rules>…</rules>
      <schedule absoluteDelay="true|false" isAbsoluteOrRelative="true" isRecurring="true|false">
         <absolute-expr><![CDATA[=pv!fecha]]></absolute-expr> | <interval><minutes>1</minutes>|<minutesExpr>…</minutesExpr></interval>
      </schedule>
      <recurrence><recurring-interval type="1|2|3"><daily><weekdays>false</weekdays><day-interval>1</day-interval></daily>|<weekly><week-interval>1</week-interval><days-of-week><el>2</el></days-of-week></weekly>|<monthly>…</monthly>
         <time>01:00:00Z</time> | <timeExpr><![CDATA[="05:30 AM"]]></timeExpr>
      </recurring-interval><timeZoneId/><timeZoneIdExpr><![CDATA[=pm!timezone]]></timeZoneIdExpr></recurrence>
   </timer-trigger></pre-triggers>
   <deadline><enabled>false</enabled><type>0</type><units>0</units><rex/><aex/></deadline>
</node></nodes>
```
Nombre del PM: valor no vacío del `string-map` de `meta/name` (preferir `es`, si vacío `en`, si vacío cualquiera). Los nodos NO son tareas de usuario por `requires-user-interaction` (es `true` incluso en nodos desatendidos): ignorar ese tag.

Usar `xml.etree.ElementTree` con el namespace `http://www.appian.com/ae/types/2009` (el `pm` está en ese ns por defecto; el haul externo sin ns). Si el XML no parsea → registrar en `analysis.parseErrors` y contar en cobertura; los checks de ese objeto quedan como `REVIEW` con finding `PKG-003 "Objeto no analizable"`.

### G03 (PM-007) grupo de alertas
- Leer `pm-notification-settings`. Si `custom-settings` = false, o `usersandgroups` sin `people` y `recipients-exp` vacío → FAIL ("sin destinatarios propios: se usa la configuración por defecto = administradores").
- `people/type` 4096 = grupo, 4 = usuario. Solo usuarios (sin grupo) → FAIL ("las alertas deben ir a un grupo").
- Resolver UUID de grupo con los `group/*.xml` del zip (`groupHaul/group/uuid` + `name`). Config `forbiddenAlertGroups: {"uuids": [...], "names": [...]}`; por defecto uuids `["SYSTEM_GROUP_ADMINISTRATORS"]` y names exactos (case-insensitive) `["Administrators", "Administradores", "Process Administrators"]`. Si el UUID o nombre resuelto está en la lista → FAIL.
- Si el UUID no está en el zip ni en config (no resoluble offline) → REVIEW con el uuid en el mensaje. Si el nombre resuelto contiene `administrator|administrador` pero no es forbidden exacto (p. ej. "SMK Administrators") → PASS con finding INFO `PM-012` "grupo de alertas es un grupo de administradores de aplicación; confirmar que no es el de plataforma" (no bloquea). Si `recipients-exp` no vacío → REVIEW (expresión dinámica).
- Un finding por PM (ahora solo se emite 1 en total: corregir).

### G04 (PM-008) borrado de instancias
Códigos `cleanup-action` observados: 0 = no archivar ni borrar, 1 = archivar (usa `auto-archive-delay`), 2 = borrar (usa `auto-delete-delay`), 3 = configuración por defecto del sistema (observado con 7/0). -1 u otro → REVIEW.
- 2 y `auto-delete-delay` <= `max_instance_cleanup_days` (3) → PASS. 2 con delay > 3 → FAIL. 0/1/3 → FAIL (mensaje distinto por código). Ausente → REVIEW.
- Bug actual: SMK (cleanup 2, delete 1 en los 5 PMs) sale FAIL en baseline; debe salir PASS.

### G07 (PM-009) tareas de usuario
- Tarea de usuario = nodo con `ac/local-id == internal.17` **o** nodo con `<assignments>` que contenga al menos un `<assignee>`. Start node (core.0) con formulario NO es tarea de usuario.
- Excepción de tiempo válida = (a) `deadline/enabled == true` con `type`/`units` numéricos, o (b) `escalations` con hijos que contengan un `timer`/`schedule`/`delay`. Como no tenemos fixture con escalado real, implementar (b) de forma conservadora: si `escalations` tiene hijos, extraer cualquier `<interval>`/`<delay>`/`<minutes|hours|days>` numéricos dentro de escalations; si se extrae → comparar con `max_user_task_escalation_days` (1) → PASS/FAIL; si hay hijos pero no se puede extraer duración → REVIEW con snippet (300 chars). Sin deadline habilitado y `<escalations/>` vacío → FAIL.
- Para `deadline`: `units` interpretado como código; si no se conoce el mapeo unidades→días, REVIEW con los valores. Nunca coger números de otras partes del nodo.

### G10 (PM-010/PM-011) batch
- Batch = `timer-trigger` en `pre-triggers` de un nodo con `local-id == core.0` (Start) y (`schedule/@isRecurring == "true"` **o** `<recurrence>` presente). `isRecurring="false"` sin `recurrence` → no es batch. Timers recurrentes en nodos que no son Start (bucles de polling con `interval/minutes`) → no G10; emitir INFO `PM-013` "timer recurrente intra-proceso" (informativo).
- Hora: `recurring-interval/time` formato `HH:MM:SSZ` (UTC) → convertir a la zona del PM: `recurrence/timeZoneId` si no vacío; si `timeZoneIdExpr == =pm!timezone` usar `meta/timeZoneId`; si es otra expresión → REVIEW ("zona horaria dinámica"). Conversión con `zoneinfo` (py3.9+) y fallback: si no disponible o tz desconocida → REVIEW indicando que no se pudo convertir. Anotar en el mensaje hora UTC y hora local con la tz usada.
- `timeExpr`: si es literal (`="05:30 AM"`, `="17:00"`) parsear; si es expresión → REVIEW con el snippet.
- Regla: hora local dentro de [06:30, 22:00) → FAIL PM-011; fuera → PASS con INFO `PM-010` (batch detectado, hora X, recordar revisar horario de menor carga en "Site Gestión de Procesos > Batch model process management"). Ventana configurable `--batch-window` (por defecto 06:30-22:00).
- Fixtures reales: ADM tiene 8 PMs "ADM Batch *" con recurrence daily `01:00:00Z` (→ 03:00/02:00 Madrid → PASS) y uno weekly `="05:30 AM"` (PASS). Ninguno debe salir REVIEW salvo tz dinámica.

## 3. Record types — G08 (REC-001)

Estructura real: `recordTypeHaul/recordType[@a:uuid,@name]`, `<a:source xsi:type="a:RecordsReplica"/>` = sincronizado; `<sourceType>RDBMS_TABLE|…</sourceType>`; `<refreshSchedule><value>{"hour":3,"minute":"00","amPM":"AM","timeZone":"Europe/Madrid","dayOfWeek":""}</value><activated>false</activated></refreshSchedule>`.
- No sincronizado (sin RecordsReplica) → NA para ese record.
- Sincronizado con `activated == true` y (sin `dayOfWeek` o vacío) → full sync diario → FAIL REC-001 con hora. `activated true` con `dayOfWeek` → INFO (semanal, cumple). `activated false` → PASS.
- Quitar `"sync" in raw`. Añadir INFO `REC-002` si `sourceType` es RDBMS y el record está sincronizado (recordar límites de filas), no bloqueante.

## 4. Health Check — contrato explícito

- Eliminar autodetección por nombre/mtime. `--health-check PATH` opcional; si no se pasa → G02 = REVIEW ("HC no aportado"). Si se pasa y no existe / no se puede leer / 0 filas interpretables → `analysis.errors` + veredicto ERROR (no confundir con NO_APTO). Vacío pero legible (cabeceras sin filas) → G02 REVIEW con `healthCheck.status = "EMPTY"`.
- `healthCheck` en el informe: `{status: MISSING|EMPTY|UNREADABLE|OK, file, date, ageDays, maxAgeDays, stale: bool, rows, objectRisks: [...], applicationRisks: [...], platformRisks: [...], matchStats: {byUuid, byName, unmatched}}`.
- Fecha: buscar en el fichero (hoja/celda con `Fecha|Date|Generated|Report date` o nombre de fichero `YYYY-MM-DD|YYYYMMDD|DD-MM-YYYY`); si no → `date: null`, `ageDays: null`, y `--hc-max-age-days` (por defecto 10) solo aplica si hay fecha; si stale → G02 REVIEW aunque no haya riesgos ("HC caducado").
- Matching: por UUID (confianza `HIGH`), por nombre exacto normalizado (`MEDIUM`), por nombre de app (`applicationRisks`, no se asigna a objetos). Filas cuyo texto no cita ningún objeto ni la app → `platformRisks`. Solo `objectRisks` con nivel HIGH → HC-001 → G02 FAIL. `applicationRisks` HIGH → INFO `HC-002`; `platformRisks` → INFO `HC-003`. Cada risk lleva `matchMethod` y `confidence`.
- Mantener soporte .xlsx (zip + XML) y .csv; aceptar también .json (lista de objetos con campos `object|uuid|risk|description`).

## 5. G05 — dependencias con cobertura limitada

- `inventory.kind`: `application` si el zip incluye `application/*.xml` (export de app completa) o `patch/package` si no.
- Dependencias internas: referencias por UUID (`#"_a-…"`, `#"urn:appian:record-type:v1:UUID"`, `<uuid>` en XML) entre objetos del zip. Objeto sin referencias entrantes internas:
  - kind=application: objetos "raíz" (sites, web APIs, process models con start form/timer, record types, grupos, carpetas, CDTs, data stores, constantes env-specific, aplicación) no cuentan como huérfanos. Resto → FAIL DEPN-001 "sin referencias en la aplicación" (confianza MEDIUM: puede referenciarlo otra app; incluir texto).
  - kind=package: NUNCA FAIL. Objetos sin referencias internas → REVIEW DEPN-002 "no se puede verificar dependencias externas con un paquete parcial".
- `export.log` sección "Precedentes referenciados que no fueron exportados (N)" → lista `externalPrecedents` en inventory (informativo).

## 6. Justificaciones

Fichero JSON `--justifications`. Formato aceptado:
```
{"G03": {"text": "...", "approver": "...", "date": "YYYY-MM-DD"}, "PM-008:ADM Close Version": "texto", "PM-008": "texto genérico"}
```
Valor string o objeto. Prioridad: `CHECK:Objeto` > `Gxx` > `CHECK`. Las justificaciones genéricas por `CHECK` (sin objeto) solo se aplican si config `allowGenericJustifications: true` (por defecto **false**); si no, se ignoran y se registra en `justifications.ignored`. Un gate pasa a `JUSTIFIED` si todos sus findings FAIL están justificados o el gate `Gxx` lo está. Informe: `justifications: {applied: [{key, scope, text, approver, date}], ignored: [...], pending: [gateIds/checks:obj]}`. No se valida firma (documentarlo en el help).

## 7. Cobertura, seguridad de entrada, errores

- `PackageReader`: límites `maxZipBytes` (200 MB), `maxEntryBytes` (50 MB), `maxEntries` (20000), rechazar rutas con `..` o absolutas. Superarlos → `analysis.errors` + ERROR.
- `analysis: {parseErrors: [{file, error}], coverage: {manifestObjects, analyzedObjects, parsedOk, parseFailed, ratio}, errors: [...], warnings: [...]}`.
- Manifiesto: preferir `META-INF/export.log` (sección `Éxito (N):` con líneas `tipo id uuid "nombre"`), fallback `patches.xml`. Corregir `expectedObjects` (SMK: 143 no 87; byType no vacío). Sección `Problemas (N):` → warnings.
- `ratio < minCoverage` (config, 0.9) → ERROR. `--min-coverage` en CLI.
- Versión de Appian del export si aparece en export.log/MANIFEST.MF → `report.appianVersion`.

## 8. Checks nuevos (todos NO bloqueantes, severidad indicada)

- `ENV-002` MEDIUM: constante con `<isEnvironmentSpecific>true</isEnvironmentSpecific>` (fixture ADM: 20) o CS con `EncryptedText` sin fichero `.properties` en el zip que defina su valor. Si hay `.properties`, comprobar que contiene la clave (nombre/uuid) y valor no vacío.
- `SEC-005` HIGH (informativo): Web API / Site / Portal con acceso público/anónimo si el XML lo indica (buscar tags con `public|anonymous|authentication` en `webApi/*.xml`, `site/*.xml`, `portal/*.xml`; en ADM no aparece ninguno → no emitir nada).
- `PRF-004` MEDIUM: `a!writeRecords|a!writeToDataStoreEntity|a!startProcess|a!writeToMultipleDataStoreEntities` dentro del cuerpo (`expression:`) de `a!forEach`. Reutilizar el detector corregido de PRF-002 (ver §9).
- `NAM-004` LOW: objeto cuyo nombre empieza por un prefijo distinto del de la app (prefijo inferido = el más frecuente; ignorar objetos de sistema).
- G09 (SEC-004) mantener: nombre con `pass|pwd|secret|token|apikey|credential` **y** valor Text no vacío que no sea una referencia (`#"…"`), URL, ni un nombre de variable. Constante de tipo distinto a Text → no. Las 2 detecciones actuales en ADM (`ADM_PM_ENVIAR_EMAIL_ACTUALIZACION_SECRETOS_WORKFLOWS`, `ADM_REPO_ACTUALIZAR_SECRETS_WORKFLOWS`) revisar: si el valor es un UUID de PM/carpeta (tipo ProcessModel/Folder) → no es credencial → no emitir.

## 9. Correcciones de heurísticas

- PRF-002 (query en bucle): parsear `a!forEach(` con conteo de paréntesis, separar argumentos `items:` y `expression:`; solo buscar `a!query*` / `rule!`+query dentro de `expression:`. `a!forEach(items: a!queryRecordType(...).data, expression: ...)` → NO finding.
- PM-011: solo con la lógica de §2.
- Alinear textos del catálogo con los umbrales `DEFAULT_THRESHOLDS`.
- Score normalizado por nº de objetos analizados (0-100), documentado en `summary.scoreMethod`.

## 10. Salidas

- Informe JSON completo (mantener claves actuales: report, summary, deploymentGate, inventory, monitoringRecommendations, healthCheck, objects, packageFindings, findings, checksCatalog) + nuevas `analysis`, `justifications`.
- `--verdict-json PATH`: `{verdict, verdictLabel, exitCode, gates:[{id,status,title,findings,justification}], pendingJustifications, healthCheck:{status,date,ageDays,stale}, coverage, package:{name,kind,applicationUuid}, analyzerVersion, generatedAt}`.
- `--markdown PATH`: resumen para `$GITHUB_STEP_SUMMARY` / comentario de PR: veredicto, tabla de gates, HC (fecha/estado), cobertura, findings FAIL por gate con objeto+fichero+línea, pendientes de justificación, top 10 heurísticos.
- Mantener `--csv`.

## 11. Tests (`tests/test_analyzer.py`, unittest, sin dependencias)

Fixtures sintéticas mínimas en `tests/fixtures/` generadas en el propio test (construir zips en tmp con XML mínimos que sigan la estructura real de §2/§3) + los 2 zips reales en `fixtures/` (tests de regresión: no deben lanzar excepciones, y asserts concretos abajo).
Casos:
1. forEach con query en `items` → sin PRF-002; query en `expression` → PRF-002.
2. Finding HIGH heurístico (PRF-001) con gates PASS → verdict APTO.
3. Timer Start `isRecurring=false` sin recurrence → sin PM-010/011. Start recurrente daily `10:00:00Z` tz Europe/Madrid → PM-011 FAIL. Daily `01:00:00Z` → PASS PM-010. timeExpr literal `="05:30 AM"` → PASS. timeExpr expresión → REVIEW. `timeZoneIdExpr` distinto de pm!timezone → REVIEW. Timer recurrente en nodo no-Start → PM-013 solo.
4. PM cleanup 2/1 → PASS; 2/5 → FAIL; 1 → FAIL; 3 → FAIL; ausente → REVIEW.
5. Alertas: custom-settings false → FAIL; grupo resuelto "Administrators" → FAIL; uuid SYSTEM_GROUP_ADMINISTRATORS → FAIL; grupo "SMK Administrators" → PASS + PM-012; uuid no resoluble → REVIEW; solo usuario → FAIL.
6. Tarea internal.17 sin deadline ni escalations → FAIL; deadline enabled con duración <= 1 día → PASS; escalations con hijos no interpretables → REVIEW; Start node con form → no cuenta.
7. Record RecordsReplica activated true sin dayOfWeek → FAIL REC-001; con dayOfWeek → PASS; activated false → PASS; sin RecordsReplica → NA.
8. HC: ausente → G02 REVIEW status MISSING; fichero inexistente → verdict ERROR exit 2; CSV vacío → EMPTY/REVIEW; riesgo HIGH con uuid del objeto → G02 FAIL byUuid; riesgo HIGH solo por nombre → FAIL confidence MEDIUM; riesgo HIGH de plataforma → G02 PASS + HC-003; fecha de hace 30 días → stale → REVIEW.
9. Manifiesto: export.log con 3 objetos y zip con 2 → coverage ratio 0.67 → ERROR con minCoverage 0.9; con `--min-coverage 0.5` → no ERROR + warning.
10. Justificaciones: `PM-008:Obj` justifica solo ese objeto; `PM-008` genérica ignorada por defecto y aplicada con `allowGenericJustifications`; `G03` justifica el gate → JUSTIFIED → APTO_CON_CONDICIONES.
11. G05: kind=package con objeto sin refs → REVIEW DEPN-002 (nunca FAIL); kind=application con expression rule sin refs → FAIL DEPN-001; record type sin refs → no finding.
12. Regresión real: `fixtures/smk.zip` → G04 PASS, G07 NA, G10 NA, G03 PASS (grupo "SMK Administrators" → PM-012), coverage ratio 1.0, expectedObjects 143. `fixtures/adm.zip` → G10 sin REVIEW por horario (todos PASS), G04 FAIL con exactamente los PMs de cleanup ≠ 2 o delay > 3 (ADM_PM_UNARCH_FindArchivedProcess, ADM Recepcion Aprobacion RT, ADM Close Version, ADM Proceso Devops, ADM TEST reactivar user, ADM Modificar Correos Informes Usuarios, ADM Registrar Despliegue), verdict NO_APTO, exit 1 con --gate.
13. Exit codes: APTO 0, APTO_CON_CONDICIONES 3, NO_APTO 1, ERROR 2.
14. Zip con entrada `../evil.xml` → ERROR.

## 12. Verificación obligatoria
- `python3 -m pyflakes src/appian_static_analyzer.py` (instalar con pip --user si falta) y `python3 -m py_compile`.
- `python3 -m unittest discover -s tests -v`.
- Ejecutar sobre `fixtures/smk.zip` y `fixtures/adm.zip` con `--gate --verdict-json --markdown` y guardar salidas en `out/`.
