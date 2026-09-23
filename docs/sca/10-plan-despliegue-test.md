# 10. Plan de despliegue de SCA2 a TEST

Objetivo: promocionar la aplicación `SCA2 Sistema Comercial de Anulaciones` de
DEV (`mapfrespain-dev`) a TEST (`mapfrespain-test`) y **continuar el
desarrollo en TEST** con el MCP apuntando a ese entorno. SCA/SCAC no se tocan
en ningún entorno.

Estado: **plan, no ejecutado**. Nada se ha creado ni modificado en TEST.

---

## 0. Decisiones previas (necesitan tu confirmación)

| # | Decisión | Recomendación |
|---|----------|---------------|
| D1 | **Entorno "fuente de verdad" tras el despliegue.** Si seguimos desarrollando en TEST, DEV queda desincronizado desde el primer cambio. | TEST pasa a ser el único entorno de desarrollo de SCA2; DEV se congela como baseline (paquete exportado guardado). La promoción a PRO se hará desde TEST. No desarrollar en los dos a la vez. |
| D2 | **Base de datos.** `SCA2 DataBase AWS` en TEST: ¿misma instancia AWS con schema nuevo `sca2_anulaciones` o instancia distinta? | Schema `sca2_anulaciones` vacío en la BBDD AWS de TEST, mismo DDL que DEV (ver §4). |
| D3 | **Datos.** TEST arranca con tablas vacías (no se copian las filas `PDTE-*`/`TEST-*` de DEV). | Vacío. Las pólizas de prueba de TEST las das tú. |
| D4 | **Cuenta MCP de TEST.** El usuario `devin` en TEST hoy devuelve 401 con las dos contraseñas que tengo (la de DEV y la antigua). | Necesito la contraseña de `devin` en TEST (formulario seguro, secreto `APPIAN_TEST_DEVIN_PASSWORD`) o que me digas qué servidor MCP de TEST tienes configurado. |
| D5 | **Método de despliegue.** Compare & Deploy DEV→TEST (si los entornos están conectados en Admin Console) o export manual `.zip` + `.properties`. | Compare & Deploy si está disponible (deja log de despliegue y hace la comparación de objetos); si no, export manual. |
| D6 | **Alcance de usuarios en TEST.** Mantener SCA2 visible solo para ti y `devin`. | Igual que en DEV hasta que empiece la validación con negocio. |

---

## 1. Prerrequisitos en TEST (verificar ANTES de importar)

SCA2 **no es autocontenida**: depende por UUID de objetos de SCA y SCAC. Si
en TEST esos objetos no existen con **el mismo UUID** que en DEV, el import
falla o deja referencias rotas. Como SCA/SCAC de TEST proceden del mismo
origen que DEV, los UUIDs deberían coincidir, pero hay que comprobarlo con la
inspección del paquete (Designer → Import → "Inspect") antes de importar.

### 1.0 Estado real de TEST (auditoría read-only, ver `analisis/test_prereqs.md`)

- **SCA2 ya existe parcialmente en TEST** con el mismo UUID de aplicación:
  99 constantes `SCA2_*` (API Clients ya rellenas), 3 grupos SCA2 y 10/15
  record types. No hay reglas, interfaces, integraciones, PMs ni site
  (`sca2` libre). El import será una **actualización**, no una creación.
- **Bloqueantes (missing precedents)**: 3 connected systems de SCAC no existen
  en TEST → `SCAC API Clients` (`SCA2_APIClients_Benefits/contactMethod/search`,
  `SCA2_SCA_CMP_APIClients_Perfil`), `SCAC Login Token` (`SCA2_APIClients_Login`)
  y `SCAC_SGC3` (`SCA2_cargaGestionSGC3`). Los otros 15 CS coinciden en UUID.
- Todo lo demás coincide en UUID: apps SCA/SCAC, grupos SCA (incl. 42
  `SCA_CE_*`), constantes de catálogo, carpetas/documentos, record types.
- Hosts en TEST: `SCAC_VAL_HOST_*` → PRE (igual que DEV);
  `CMP_VAL_HOST_*` → **PRE** (en DEV apuntan a `*.desa.mapfre.net`).
  `SCA_TXT_URL_HOST` = `mapfrespain-test`; `SCA_TXT_EMAIL_DUE_PARA_*` =
  buzón personal en TEST (existe `…_TEST` = APP-ALTITUDEMAILPRU4).
- `cons!SCA2_GRP_ALERTAS` la usan `SCA2_isUsuarioProceso`,
  `SCA2_obtenerInformacionUsuario` y
  `SCA2_ContraAnulacionArgumentarioEstrategicas`.

### 1.1 Objetos de SCAC referenciados

| Tipo | Objetos | Uso en SCA2 |
|------|---------|-------------|
| Connected systems | `SCAC_SCA_Core7` y el resto de CS SOAP/REST de SCAC (PCA, SGC, SGO, ESB, GD, API Clients, GESVIDA) | Las 107 integraciones `SCA2_*Integracion` se crearon **sobre los CS de SCAC** (decisión de Fase 0: no duplicar credenciales). |
| Constantes de host | `SCAC_VAL_HOST_CORE7` (112 refs), `SCAC_VAL_HOST_WEBSERVICES` (11), `SCAC_VAL_HOST_ESB` (9), `CMP_VAL_HOST_CORE7` (4), `CMP_VAL_HOST_ESB` (4), `CMP_VAL_HOST_SOA7` (3) | Endpoints de las integraciones. En TEST tomarán **el valor que SCAC tenga en TEST** → hay que confirmar a qué entorno backend apuntan (PRE o TEST de Core7/PCA). |
| CDTs de WSDL | Tipos `type!{ns}…` de Core7/PCA/SGC (p. ej. `pObtenerPolizaFecha`, `IGenerarContraAnul`) | Solo dentro del body de las 63 integraciones SOAP (`toxml(cast(type!…))`). |
| Integraciones Retos | `obtenerTokenRetosREST`, `asignarRetosREST` | Se usan tal cual (decisión del usuario). |

### 1.2 Objetos de SCA referenciados

| Tipo | Objetos |
|------|---------|
| Constantes | `SCA_TXT_BONIFICACION_VALUES`, `SCA_INT_CODIGO_COMPANIA`, `SCA_TXT_RAMA_NEGOCIO_ITEMS`, `SCA_INT_RAMA_NEGOCIO_VALUES`, `SCA_DSE_TM_TRANSACTION` |
| Record types de catálogo (solo lectura) | Motivos/Detalles/Causas, canales, perfiles, etc. (inventario en `04-modelo-de-datos.md`) — se leen, no se copian datos. |
| Grupos (vía constantes `SCA2_GRP_*`) | `SCA Acceso Decisora`, `SCA Alertas`, `SCA_PROCESO`, `SCA_CE_*old` y `SCA_CE_*_TEST` (14 pares) |
| Carpetas/documentos | `SCA2_FLD_CLIENTE_TIPO_VALOR`, `SCA2_FLD_DOCUMENTACION_ARGUMENTARIO` (carpetas de SCA `_a-0000eba7…`), `SCA2_PLANTILLA_CONTRATO_COMPRA_VENTA`, `SCA2_REP_PROCESS_MECANIZACIONES` (documentos de SCA) |

> Nota: `SCA2_GRP_ALERTAS` apunta hoy al grupo **`SCA Alertas`** (de SCA), no a
> `SCA2 Alertas`. Las alertas de los 12 PMs sí están configuradas directamente
> a `SCA2 Alertas`. Revisar qué usa esa constante y repuntarla a `SCA2 Alertas`
> **antes** de exportar (§2.2).

### 1.3 Plataforma

- Usuarios `GGALV10@mapfre.net` y `devin` existen en TEST (`devin` con rol de
  administrador de sistema o al menos permisos de diseñador + Import).
- El identificador de site `sca2` está libre en TEST.
- Versión de Appian de TEST igual o superior a DEV (los PMs usan
  `Write Records and Related Records` 23r3 y `a!defaultValue`).
- El usuario JDBC de `SCA2 DataBase AWS` en TEST tiene `CREATE/ALTER` sobre
  el schema (para "Generar script DDL" desde el record type, §4).

---

## 2. Preparación en DEV (antes de exportar)

### 2.1 Cerrar lo que no debe viajar a medias
1. `SCA2_Buscador`: la última versión local corregida no está publicada (PUT
   falla por `Unresolved reference(s): xml, text`). Resolver y publicar.
2. `SCA2_construirContextoAlta`: correcciones de paridad de payload (§18-sept5
   de `analisis/t18_polizas.md`) desplegadas; repetir el GUARDAR de
   `2001900000007` para confirmar que `ALTA_ERROR` desaparece **antes** de
   congelar el paquete.
3. Documentos de prueba 629513/629514 en la KB de SCA2: borrar.
4. Test case perdido de `SCA2_consultarConceptoIntegracion`: restaurar.
5. Health check de la app en Designer sin warnings críticos.

### 2.2 Constantes: marcar / corregir
- Repuntar `SCA2_GRP_ALERTAS` → `SCA2 Alertas`.
- `SCA2_TXT_EMAIL_ENVIO_ERRORES` = `pruebasca@mapfre.com` (buzón de pruebas):
  confirmar valor para TEST.
- Verificar que **ninguna** regla/interfaz tiene URLs o UUIDs literales de DEV
  (grep del dump: `mapfrespain-dev`, `.pre.mapfre.net`); todo debe salir de
  constantes (§3).

### 2.3 Paquete
1. Designer DEV → aplicación SCA2 → **Export** (o Compare & Deploy).
2. Incluir **toda** la aplicación (≈ 520 objetos: 15 record types + relaciones,
   99 constantes, 210 reglas, ~45 interfaces, 107 integraciones, 12 PMs, 3
   grupos, site, 7 carpetas, test cases).
3. Generar **Import Customization File (`.properties`)** al exportar.
4. Guardar `.zip` + `.properties` + informe de dependencias en
   `docs/sca/anexos/deploy-test/` (sin valores de secretos en el
   `.properties` versionado: usar plantilla con `***`).
5. Congelar: anotar en este capítulo el commit/fecha del paquete y la versión de
   cada PM.

---

## 3. Import Customization File — matriz DEV → TEST

Todo lo que cambia por entorno. Los valores de TEST deben copiarse de las
**constantes equivalentes de SCA en TEST** (mismo nombre sin el prefijo
`SCA2_`), no inventarse.

### 3.1 Connected system (obligatorio)
| Objeto | Campos a rellenar en TEST |
|--------|---------------------------|
| `SCA2 DataBase AWS` | JDBC URL / host, schema `sca2_anulaciones`, usuario, contraseña (nunca en el zip; sólo en el `.properties` del import o a mano en Designer TEST). |

Los CS de SCAC no se importan (ya existen en TEST).

### 3.2 Secretos (constantes TEXT) — valores de TEST, nunca documentados
`SCA2_TXT_APICLIENTS_USER`, `SCA2_TXT_APICLIENTS_PASS`,
`SCA2_TXT_APICLIENTS_CLIENT_ID`, `SCA2_TXT_APICLIENTS_CLIENT_SECRET`.

### 3.3 URLs y hosts (hoy apuntan a PRE / DEV)
| Constante | Valor DEV (resumen) | En TEST |
|-----------|---------------------|---------|
| `SCA2_TXT_URL_HOST` | `https://mapfrespain-dev.appiancloud.com` | `https://mapfrespain-test.appiancloud.com` |
| `SCA2_WEBSERVICES_URL` | `webservices.pre.mapfre.net` | = `SCA_WEBSERVICES_URL` de TEST |
| `SCA2_NUMPOLIZA_URL`, `SCA2_FECHAULTIMOSINIESTRO_URL`, `SCA2_FORMAPAGO_URL`, `SCA2_PLANPAGO_URL`, `SCA2_FICHAAMPLIADA_URL` | `https://apps.pre.mapfre.net/…` | = equivalentes SCA en TEST |
| `SCA2_NUMPOLIZAVIDA_URL`, `SCA2_TXT_LINK_GESVIDA`, `SCA2_TXT_LINK_GESVIDA_CABECERA` | `https://webvida.pre.mapfre.net/…` | = equivalentes SCA en TEST |
| `SCA2_TXT_URL_NSE`, `SCA2_TXT_URL_LOCALIZADOROFICINAS`, `SCA2_TXT_URL_LANZARDECISION_ANTIGUO` | `wportalinterno.pre.mapfre.net/…` | = equivalentes SCA en TEST |
| `SCA2_TXT_RUTAS_ARGUMENTOS_VAL`, `SCA2_TXT_URL_GESCOMWEB`, `SCA2_TXT_URL_GESTIONCOMPETENCIAS`, `SCA2_TXT_URL_DOCUMENTACIONSCA`, `SCA2_URL_TECUIDAMOS` | portal interno / externos | = equivalentes SCA en TEST |
| `SCA2_USERS_DOMAIN` | `@mapfrenopro.onmicrosoft.com` | confirmar (¿mismo tenant en TEST?) |

### 3.4 Correo
`SCA2_TXT_EMAIL_DUE_PARA_ALTITUDE`, `SCA2_TXT_EMAIL_DUE_PARA_EXPERTOS`
(`APP-ALTITUDEMAIL93@mapfre.com`), `SCA2_TXT_EMAIL_ENVIO_ERRORES` → valores de
SCA en TEST. (Hoy ningún PM SCA2 envía correo; sólo se muestran.)

### 3.5 Referencias por UUID que deben resolverse en el import (no se editan)
- 12 constantes `SCA2_PM_*` → PMs del propio paquete.
- `SCA2_GRP_ADMINISTRADORES`, `SCA2_GRP_USUARIOS`, `SCA2_GRP_ALERTAS` → grupos del paquete.
- `SCA2_GRP_*` restantes → grupos de SCA en TEST (§1.2).
- `SCA2_FLD_*` → carpetas del paquete (5) y de SCA (2).
- `SCA2_PLANTILLA_*`, `SCA2_REP_*` → documentos de SCA.
- `SCA_*`/`SCAC_*`/`CMP_*` → constantes de SCA/SCAC en TEST.

Si la inspección marca alguna como "missing precedent", **no importar**: es
un objeto de SCA/SCAC que en TEST tiene otro UUID o no existe.

---

## 4. Base de datos TEST (`sca2_anulaciones`)

Orden recomendado (evita importar record types contra tablas inexistentes):

1. DBA/tú: crear schema `sca2_anulaciones` en la BBDD AWS de TEST y el usuario
   técnico con permisos DML + `CREATE/ALTER` (temporal, para DDL).
2. Crear las 15 tablas con el **DDL exportado de DEV** (`SHOW CREATE TABLE` de
   las 15 `sca2_*` en DEV, incluidas `RSVPRIMA DECIMAL` e `IDCOMPANIA INTEGER`
   en `sca2_datos_solicitud`, PKs autoincrementales e índices por
   `idSolicitud`, `numPoliza`, `estadoSolicitud`, `claveIdempotencia`).
   Alternativa: importar primero y usar "Generar script DDL" en cada record
   type desde Designer TEST (mismo resultado, 15 pasos manuales).
3. Verificar tras el import: los 15 record types "Fuente de datos = SCA2
   DataBase AWS", campos mapeados sin avisos, **sync completo OK**.
4. Relaciones: comprobar las que quedaron tras tu limpieza en DEV (espejo
   `solicitud` recreada) — viajan en el paquete.

Tablas: `sca2_solicitud`, `sca2_transicion`, `sca2_tarea`, `sca2_error`,
`sca2_datos_solicitud`, `sca2_datos_cabecera`, `sca2_datos_perfiles_pca`,
`sca2_otras_solicitudes_cabecera`, `sca2_trazabilidad_cliente` y las 6
restantes del inventario `04-modelo-de-datos.md`.

---

## 5. Ejecución del despliegue (día D)

| Paso | Acción | Verificación |
|------|--------|--------------|
| 1 | Backup: exportar el estado actual de TEST de los grupos/constantes que se vayan a tocar (ninguno de SCA se toca; sólo por trazabilidad). | zip guardado |
| 2 | BBDD lista (§4.1-4.2). | 15 tablas, `DESCRIBE` coincide con DEV |
| 3 | Designer TEST → Import → **Inspect** con `.zip` + `.properties`. | 0 errores, 0 "missing precedents"; sólo warnings esperables |
| 4 | Import. | Log: todos los objetos "Created"; ninguno "Skipped/Failed" |
| 5 | Connected system `SCA2 DataBase AWS`: Test connection. | OK |
| 6 | Record types: sync manual de los 15. | Estado "Success", 0 filas |
| 7 | PMs: comprobar publicados (v1 en TEST), alertas → `SCA2 Alertas`, retención "Eliminar 1 día tras completar/cancelar", `PauseOnError` según diseño. | 12/12 |
| 8 | Grupos: `SCA2 Administrators` (tú + devin), `SCA2 Users` (= Administrators), `SCA2 Alertas` (tú + devin). Seguridad de la app y del site = sólo esos grupos. | Nadie más ve `sca2` |
| 9 | Site `sca2`: branding (barra blanca, logo, acento rojo) — **no viaja en el paquete de forma completa** (logo/favicon son documentos); reaplicar desde Designer TEST copiando `sca-site`. | Captura lado a lado |
| 10 | Constantes: recorrer §3 en Designer TEST y comparar con SCA de TEST. | Checklist firmado |
| 11 | Reconfigurar el MCP a TEST (`LCP_URL=https://mapfrespain-test.appiancloud.com`, credencial de `devin` en TEST). | `listApplications` devuelve SCA2 |

Tiempo estimado: 0,5 sesión (sin contar BBDD y credenciales, que dependen de ti).

---

## 6. Validación post-despliegue en TEST

### 6.1 Smoke (misma sesión del despliegue)
1. Login y acceso a `/suite/sites/sca2` → Buscador vacío sin errores.
2. Bandeja de errores y Gestiones mantenimiento cargan.
3. Popup Alta con una póliza de TEST: datos de póliza/cliente cargan
   (Core7/PCA de TEST responden), cascada Motivo→Detalle→Causa desde
   catálogos SCA de TEST.
4. GUARDAR → `SCA2 CMD Alta` COMPLETED en < 10 s, fila en `sca2_solicitud`.
5. Forzar un error externo (póliza inválida) → PM COMPLETED, fila en
   `sca2_error`, relanzable desde la bandeja.

### 6.2 Funcional (comparación SCA vs SCA2 en TEST, con tus pólizas)
Alta → Decidir → CrearAcción → CompletarAcción → Finalizar; Mecanizar; Contra
Anulación; Acciones administrativas; Autorización; Vida/GESVIDA; VERTI; Fuera
de norma; Caducidad/Barrido; Posponer; CambiarNivel; GenerarPdf;
ObtenerDocumentoGD. Para cada uno: misma pantalla, mismos datos, misma
escritura en backend (PCA/SGC/Core7), tiempos.

### 6.3 No funcional
- Idempotencia (doble GUARDAR / doble Completar) → 1 sola transición.
- Rendimiento: Buscador < 0,5 s, Detalle < 1 s, CMD < 10 s (baseline DEV: 0,3 / 0,5 / 3-8 s).
- Volumen: ≥ 200 altas concurrentes en TEST antes de hablar de PRO.
- Seguridad: usuario fuera de `SCA2 Users` recibe 403 en el site.
- SCA/SCAC en TEST: 0 versiones nuevas creadas por `devin`.

---

## 7. Rollback

SCA2 es aditiva: SCA sigue operativo en TEST en todo momento.

1. **Deshabilitar entrada**: quitar `SCA2 Users` del site `sca2` (nadie puede crear solicitudes).
2. Cancelar instancias SCA2 activas desde Monitor (deberían ser 0; duran segundos).
3. Si hay que retirar la app: borrar la aplicación SCA2 y sus objetos en TEST
   (Designer → aplicación → objetos → eliminar) y `DROP SCHEMA sca2_anulaciones`
   (sólo si D3 = vacío y no hay datos que conservar).
4. Los objetos de SCA/SCAC no se han modificado → no requieren rollback.

---

## 8. Convivencia y camino a PRO (fuera del alcance de este despliegue)

- Solicitudes abiertas de SCA no se migran a SCA2 en TEST; se validan flujos
  nuevos punta a punta. La estrategia de migración de solicitudes abiertas
  para PRO se definirá tras la validación funcional (opciones: agotar SCA en
  paralelo o importador PCA→`sca2_solicitud`).
- Antes de PRO: aprobación de seguridad (SCA2 usa los CS de SCAC → mismas
  credenciales), plan de carga, monitorización (`SCA2 Alertas`, bandeja de
  errores), y el paquete de PRO se exportará desde TEST (D1).

---

## 9. Checklist resumida de lo que necesito de ti

- [ ] D1–D6 confirmadas.
- [ ] Contraseña de `devin` en TEST (formulario seguro) o datos del MCP de TEST.
- [ ] Schema `sca2_anulaciones` + usuario JDBC en la BBDD AWS de TEST (o
      permiso para generar el DDL desde Designer TEST).
- [ ] Credenciales API Clients de TEST (rellenarlas tú en Designer TEST, como en DEV).
- [ ] Confirmación de a qué backend apuntan `SCAC_VAL_HOST_*`/`CMP_VAL_HOST_*` en TEST.
- [ ] 3–5 pólizas vigentes de TEST sin solicitud previa (Autos, Hogar, Vida).
