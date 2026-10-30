# 51. Ronda 31 — Grupos y permisos: cómo lo hace SCA y qué haría falta en SCA2 para la migración

Análisis de sólo lectura sobre Appian TEST (26-10-2026), por LCP (`/objects?appUuid`, `/groups/{uuid}`, `/groups/{uuid}/members`, `/sites/{uuid}`, `/objects/{uuid}/security`) y lectura de las reglas/PMs de SCA y SCA2. **No se ha ejecutado ni modificado nada.** Los nombres de usuario que aparecen son los miembros reales de los grupos en TEST; no se incluyen contraseñas ni datos de acceso.

## 1. Resumen ejecutivo

- SCA usa los grupos Appian para tres cosas: (1) **entrar al site** (`SCA Usuarios` es *viewer* y contiene como subgrupos a los 48 grupos restantes), (2) **deducir el perfil/subperfil funcional del usuario** (`CE_RM_OFICINA`, `CE_MF_SI24_EXPERTO`, …) a partir del grupo `SCA_CE_*` al que pertenece y (3) **tratar como administradores** a `SCA Administradores` y `SCA Alertas`. Los *roles* (SOLICITUD, PCACORE, PROCESO…) no vienen de grupos sino de CORE por NUUMA (`CMP_APIUsuarios_ObtenerRoles`).
- Los grupos de perfil `SCA_CE_*` están descritos como «grupo que contiene los usuarios del subperfil relacionado con el **grupo de Azure**»: su membresía es la sincronizada desde Entra ID, no se mantiene en Appian. Coexisten tres generaciones (`SCA_CE_X`, `SCA_CE_Xold`, `SCA_CE_X_TEST`); en TEST los usuarios reales (30 Oficina, 21 Expertos SI24…) están en la generación **base**, pero las constantes `SCA_GRP_CE_*` apuntan a la generación **old** (4 usuarios de prueba) y `_TEST` (vacías).
- SCA2 **reutiliza los grupos de SCA**: sus 28 constantes `SCA2_GRP_CE_*`, `SCA2_GRP_PROCESO` y `SCA2_GRP_ACCESO_DECISORA_NUUMAS` apuntan a los mismos objetos grupo de la aplicación SCA, y sus reglas de perfil son copia literal de las de SCA. Sólo tiene tres grupos propios: `SCA2 Users` (7 usuarios), `SCA2 Administrators` (4) y `SCA2 Alertas` (vacío).
- Para que los usuarios de SCA pasen a SCA2 **no hay que recrear perfiles**: basta con dar acceso al site (`SCA2 Users`) a los mismos colectivos y alinear administradores/alertas. Lo que sí hay que decidir es (a) si los grupos `SCA_CE_*` se quedan en la aplicación SCA (dependencia cruzada) o se trasladan a SCA2/SCAC, (b) qué generación de grupos es la vigente en cada entorno y (c) corregir dos diferencias de visibilidad (página de mantenimiento y Decisora Vida). El detalle está en §5.

## 2. Cómo funciona SCA con los grupos

### 2.1 Inventario (aplicación SCA, 49 grupos)

| Grupo | Miembros en TEST | Uso |
|---|---|---|
| `SCA Usuarios` | 2 usuarios + **48 subgrupos** (todos los demás grupos de SCA) | Viewer de los sites `SCA_Site` y `SCA Decidir Accion` y de los objetos de la app. Quien esté en cualquier grupo SCA entra al site. |
| `SCA Administradores` | 3 (devin, GGALV10, sca.decisora) | Administrator de los sites; `SCA_isUsuarioProceso` / `SCA_obtenerInformacionUsuario` lo tratan como admin (roles fijos). |
| `SCA Alertas` (fuera de la app SCA) | 6 (AMDAVI2, ARMAJIM, CMORE11, JJGONZ2, MASCARP, sca.decisora) | Administrator de los sites, destinatarios de errores y **también tratado como administrador** en las reglas de perfil. |
| `SCA Acceso Decisora` / `SCA Acceso Decisora Vida` | 0 / 3 | Listas de usuarios autorizados a entrar desde la Decisora (`SCA_esOleadaDecisora`, `SCA_crearUriDecisora`). |
| `SCA_PROCESO` | 0 | Constante `SCA_GRP_PROCESO`; uso residual. |
| `SCA_CE_<subperfil>` × 14 (`CE_RM_OFICINA`, `CE_RM_AGENTE`, `CE_RM_DT`, `CE_MF_SI24_EXPERTO`, `CE_MF_SI24_TECNICO`, `CE_MF_SI24_SA`, `CE_MF_SI24_FRONT`, `CE_MF_SI24_CENTRAL`, `CE_MF_BK_EXPERTO_SI24`, `CE_MF_RECIBOS_CCC`, `CE_MF_RECIBOS_CCR`, `CE_MF_CONTROL`, `CE_MF_CENTRAL_AT`, `CE_CONSULTA`) | Generación **base**: Oficina 30, SI24 Experto 21, SI24 SA 20, SI24 Técnico 19, Recibos CCC 9, Central AT 6, Control 3, BK Experto SI24 3, Recibos CCR 1, resto 0. Generación **old**: Oficina 4 (CMORE11, devin, GGALV10, JJGONZ2), SI24 Experto 1 (SISANS), Agente 1 (VFERNA), resto 0. Generación **_TEST**: todas vacías. | Determinan el **perfil y subperfil** del usuario (§2.2). Descripción del grupo: «usuarios del subperfil relacionado con el grupo de Azure» → membresía sincronizada desde Entra ID. |
| `SCA _RE_TEST`, `SCA _RE_TESTold` | 0 / 3 | Restos de pruebas; sin constante que los use. |

Constantes de tipo GROUP de SCA (todas en la app SCA): `SCA_GRP_ADMINISTRADORES`, `SCA_GRP_ALERTAS`, `SCA_GRP_PROCESO`, `SCA_GRP_ACCESO_DECISORA_NUUMAS`, `SCA_GRP_ACCESO_DECISORA_VIDA_NUUMAS` y, por cada subperfil, `SCA_GRP_CE_X` → grupo `SCA_CE_Xold` y `SCA_GRP_CE_X_TEST` → grupo `SCA_CE_X_TEST`. **Ninguna constante apunta a la generación base** en TEST. `SCA_TXT_GRP_TODOS` (texto) lista los 14 códigos de subperfil.

### 2.2 Para qué se usan en la lógica

1. **Perfil y subperfil del usuario** — `SCA_obtenerInfoUsuarioDTODelNUUMALogueado`: recorre los 28 grupos (old + _TEST) con `a!isUserMemberOfGroup`; el **subperfil** es el nombre del primer grupo al que pertenece quitando `SCA_` y `old` (p. ej. `SCA_CE_RM_OFICINAold` → `CE_RM_OFICINA`); el **perfil** sale de un `a!match` por familias (`CE_RM`, `CE_MF_SI24`, `CE_MF_RECIBOS`, `CE_RM_DT`, `CE_MF_CONTROL`, `CE_MF_CENTRAL_AT`; si no pertenece a ninguno, `""`). Los **roles** se piden a CORE por NUUMA (`SCA_obtenerRolPerfilSubperfil` → `CMP_APIUsuarios_ObtenerRoles`). Este perfil/subperfil es el que viaja al motor de decisión, al alta de la gestión en CORE y a la comprobación de tareas.
2. **Administradores** — `SCA_isUsuarioProceso`, `SCA_obtenerInformacionUsuario`, `SCA_comprobarUserTareaActiva`: miembro de `SCA Administradores` o `SCA Alertas` ⇒ roles fijos `SOLICITUD, PCACORE, PCASOA, CE_RM, CE_RM_OFICINA, PROCESO`, perfil `CE_RM/CE_RM_OFICINA` y NUUMA de ejemplo (`SCA_TXT_EJEMPLO_NUUMA`), y puede retomar cualquier tarea.
3. **Visibilidad del site** — página «Gestiones mantenimiento» visible si `rule!SCA_isUsuarioProceso()` (rol `PROCESO` o `GSSCC-SCA-MF-CONTROL` de CORE, o administrador). La página de solicitudes es visible a todo el que entra.
4. **Tareas Appian** — SCA sí usa User Input Tasks: en `SCA_ContraAnulacion` la tarea se asigna a `pv!cambioAsignacion` si hay paso a nivel 2, a `cons!SCA_GRP_CE_RM_OFICINA` si nivel ≠ 1 y subperfil `CE_MF_SI24_EXPERTO`, y si no a `pp!initiator`; `reassignPrivileges = REASSIGN_TO_ANY`. Casi todos los PMs ejecutan *Modify Process Security* con los grupos de la app.
5. **Decisora** — `SCA_esOleadaDecisora` / `SCA_crearUriDecisora` comprueban pertenencia a `SCA Acceso Decisora` (y Vida).

## 3. Estado actual de SCA2

| Aspecto | SCA2 (TEST) |
|---|---|
| Grupos propios | `SCA2 Users` (cmp.loopback, devin, GGALV10, JJGONZ2, JOSPENA, SISANS, +1; subgrupo `SCA2 Administrators`), `SCA2 Administrators` (cmp.loopback, devin, GGALV10, JOSPENA), `SCA2 Alertas` (vacío). |
| Site `SCA2 Anulaciones` | Viewer `SCA2 Users`; Administrator `SCA2 Administrators`. Páginas: «Solicitudes anulación» (todos), «Errores» y «Gestiones mantenimiento» sólo si `a!isUserMemberOfGroup(loggedInUser(), cons!SCA2_GRP_ADMINISTRADORES)`. |
| Constantes de grupo | `SCA2_GRP_ADMINISTRADORES`, `SCA2_GRP_ALERTAS`, `SCA2_GRP_USUARIOS` → grupos propios. `SCA2_GRP_CE_X` / `_TEST` (28), `SCA2_GRP_PROCESO`, `SCA2_GRP_ACCESO_DECISORA_NUUMAS` → **los mismos grupos de la aplicación SCA** (`SCA_CE_Xold`, `SCA_CE_X_TEST`, `SCA_PROCESO`, `SCA Acceso Decisora`). No existe constante para `SCA Acceso Decisora Vida`. |
| Reglas | `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado`, `SCA2_isUsuarioProceso`, `SCA2_obtenerInformacionUsuario`, `SCA2_comprobarUserTareaActiva`, `SCA2_esOleadaDecisora`, `SCA2_flagVerti` son copia literal de las de SCA (sólo cambia el prefijo de las constantes). `SCA2_puedeGestionarTarea` añade la lógica de tareas SI24/nivel 2 (ronda 9). |
| Tareas | SCA2 **no usa tareas Appian**: la tarea es una fila del record `SCA2 Tarea` (grupo = perfil decidido por el motor, p. ej. `CE_RM` / `CE_MF_BK`; `asignadoA`), y el permiso para retomarla lo calcula `SCA2_puedeGestionarTarea` comparando el **perfil del usuario (derivado de los grupos)** con el grupo de la tarea. Los PMs `SCA2 CMD *` sólo usan `SCA2 Users` / `SCA2 Administrators` para la seguridad del proceso. |

Consecuencia práctica: hoy un usuario que esté en un grupo `SCA_CE_*old` obtiene el **mismo perfil en SCA y en SCA2** sin configurar nada más; lo único que le falta para usar SCA2 es estar en `SCA2 Users` (acceso al site).

## 4. Diferencias y riesgos detectados

| # | Diferencia / riesgo | Efecto |
|---|---|---|
| D1 | **Dependencia cruzada**: SCA2 apunta a grupos que pertenecen a la aplicación SCA. | Si SCA se retira/desinstala o se reorganizan sus grupos, SCA2 pierde perfiles. Los despliegues de SCA2 a otro entorno requieren que los grupos existan allí con el mismo UUID (o repuntar las constantes). |
| D2 | **Generación de grupos**: en TEST las constantes apuntan a `old`/`_TEST` y la membresía real (Azure) está en la generación base. | Los ~100 usuarios sincronizados desde Azure en TEST tendrían perfil `""` tanto en SCA como en SCA2; sólo los de `old` (4) funcionan. Hay que confirmar qué apuntan las constantes en PRO (probablemente la base) antes de fijar la configuración de SCA2. |
| D3 | La regla de subperfil depende del **nombre** del grupo (`substitute("SCA_", "")`, `substitute("old", "")`). | Si se crean grupos propios con otro prefijo (`SCA2_CE_*`) el subperfil saldría mal; habría que adaptar `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado` (o, mejor, derivar el subperfil de la constante y no del nombre). |
| D4 | «Gestiones mantenimiento» en SCA2 sólo para administradores Appian; en SCA para rol `PROCESO` / `GSSCC-SCA-MF-CONTROL` (CORE) o admin. | Usuarios de Control que hoy mantienen argumentos en SCA no podrían en SCA2 sin ser administradores. Paridad: usar `rule!SCA2_isUsuarioProceso()` en la visibilidad. |
| D5 | SCA2 no tiene constante/uso de `SCA Acceso Decisora Vida`. | Si la Decisora de Vida debe redirigir a SCA2, falta esa comprobación. |
| D6 | `SCA2 Users` es una lista de 7 usuarios de prueba; `SCA Usuarios` da acceso por **subgrupos**. | Para la migración no se debe replicar usuario a usuario: hay que anidar los grupos de perfil (o `SCA Usuarios`) dentro de `SCA2 Users`. |
| D7 | `SCA2 Alertas` vacío; `SCA Alertas` tiene 6 miembros y además es administrador funcional en SCA. | Las notificaciones de error de SCA2 no llegan a nadie; y los miembros de `SCA Alertas` dejarían de ser «admin» en SCA2 si no se replican. |
| D8 | `SCA Acceso Decisora` (no Vida) está vacío en TEST. | No se puede probar la entrada por Decisora a SCA2 en TEST sin añadir NUUMAs. |

## 5. Qué habría que hacer para que los usuarios vayan por SCA2

### 5.1 Decisiones previas (analistas / administradores Appian)

1. **Dónde viven los grupos de perfil.** Opciones: (A) dejarlos en la app SCA mientras convivan ambas y, al retirar SCA, **mover** los objetos grupo a la aplicación SCA2 (o a SCAC, que es la app común) — el UUID no cambia, las constantes siguen válidas y se conserva la sincronización con Azure; (B) crear grupos propios `SCA2_*` y repuntar las 28 constantes, lo que obliga a rehacer el mapeo Azure y a adaptar la regla (D3). **Recomendación: A** (mover, no recrear).
2. **Qué generación es la buena por entorno** (D2): confirmar en PRO los valores de `SCA_GRP_CE_*`; si en PRO apuntan a la base y en TEST a `old`, SCA2 debe seguir exactamente la misma convención (idealmente con un *Import Customization File* que fije los grupos por entorno) y conviene retirar las generaciones `old`/`_TEST` que no se usen para evitar que el `a!match` dé perfil por un grupo obsoleto.
3. **Mantenimiento**: si los usuarios de Control (`GSSCC-SCA-MF-CONTROL`/`PROCESO`) deben seguir manteniendo argumentos, aprobar el cambio de visibilidad D4.
4. **Decisora**: si Vida redirige a SCA2, aprobar D5.

### 5.2 Configuración (sin código) — checklist

| Paso | Dónde | Detalle |
|---|---|---|
| C1 | Grupo `SCA2 Users` | Añadir como **subgrupos** los 14 grupos `SCA_CE_*` de la generación vigente (o directamente `SCA Usuarios` mientras convivan). Retirar los usuarios sueltos de prueba cuando se vaya a PRO. |
| C2 | Grupo `SCA2 Administrators` | Añadir los administradores funcionales actuales (`SCA Administradores`) y, si se mantiene el criterio de SCA, `SCA Alertas` como subgrupo (o cambiar `SCA2_isUsuarioProceso`/`SCA2_obtenerInformacionUsuario` para que miren sólo administradores). |
| C3 | Grupo `SCA2 Alertas` | Replicar los miembros de `SCA Alertas` (destinatarios de errores de SCA2). |
| C4 | Grupos `SCA Acceso Decisora` / `Vida` | Mantener/poblar las listas de NUUMAs; crear `SCA2_GRP_ACCESO_DECISORA_VIDA_NUUMAS` si se aprueba D5. |
| C5 | Constantes `SCA2_GRP_CE_*` | Verificar en cada entorno que apuntan a la generación vigente (igual que `SCA_GRP_CE_*`); fijarlo con Import Customization al desplegar. |
| C6 | Site `SCA2 Anulaciones` | Viewer `SCA2 Users` / Administrator `SCA2 Administrators` ya está; revisar visibilidad de «Gestiones mantenimiento» (D4). |
| C7 | Seguridad de objetos | Los `SCA2 CMD *` ya usan `SCA2 Users`/`SCA2 Administrators`; comprobar que record types, PMs e interfaces de SCA2 heredan viewer de `SCA2 Users` (hoy sí para los PMs revisados). |
| C8 | Azure / Entra ID | Si se opta por mover grupos (A) no hay cambio; si se recrean (B), solicitar la sincronización de los nuevos grupos con los mismos grupos de Azure. |
| C9 | Decisora / enlaces externos | Cambiar la URL de redirección de la Decisora (PCA) al site `sca2` cuando se dé el corte; revisar `SCA2_crearUriDecisora` equivalente. |

### 5.3 Cambios de código mínimos asociados (sólo si se aprueban)

- D4: visibilidad de «Gestiones mantenimiento» en el site SCA2 → `rule!SCA2_isUsuarioProceso()`.
- D5: constante `SCA2_GRP_ACCESO_DECISORA_VIDA_NUUMAS` + uso en `SCA2_esOleadaDecisora` / `SCA2_flagVerti` como en SCA.
- D3 (recomendable aunque no se recreen grupos): que `SCA2_obtenerInfoUsuarioDTODelNUUMALogueado` obtenga el subperfil del código asociado a la constante (mapa constante → código `CE_*`) en lugar de parsear el nombre del grupo.
- Limpieza: eliminar constantes y comprobaciones de la generación `_TEST` (vacía) cuando se confirme D2.

### 5.4 Pruebas que habría que hacer tras configurar (no ejecutadas)

1. Usuario sólo en `SCA_CE_RM_OFICINA` (generación vigente): entra al site SCA2, su perfil en la cabecera/alta es `CE_RM / CE_RM_OFICINA`, puede retomar tareas de nivel 1 y no las de SI24.
2. Usuario sólo en `SCA_CE_MF_SI24_EXPERTO`: entra, perfil `CE_MF_SI24 / CE_MF_SI24_EXPERTO`, ve/retoma la CA de nivel 2.
3. Usuario de `SCA_CE_MF_CONTROL` con rol `GSSCC-SCA-MF-CONTROL`: ve «Gestiones mantenimiento» (tras D4).
4. Usuario en ningún grupo SCA: no entra al site SCA2.
5. Miembro de `SCA Alertas`: recibe correo de la bandeja de errores de SCA2 y (según decisión) actúa como administrador.
6. Entrada desde Decisora (Autos y Vida) con NUUMA autorizado y no autorizado.

## 6. Dudas para los analistas / administradores

1. ¿Qué grupos apuntan las constantes `SCA_GRP_CE_*` en PRO: la generación base (sincronizada con Azure) o `old`? ¿Se pueden eliminar `old` y `_TEST`?
2. ¿Los grupos `SCA_CE_*` se trasladan a la aplicación SCA2 (o a SCAC) cuando se retire SCA, o SCA2 debe tener grupos propios con nueva sincronización Azure?
3. ¿Los miembros de `SCA Alertas` deben seguir siendo administradores funcionales en SCA2?
4. ¿El mantenimiento de argumentos en SCA2 debe abrirse a `PROCESO` / `GSSCC-SCA-MF-CONTROL` como en SCA?
5. ¿La Decisora de Vida redirigirá a SCA2? ¿Quién mantiene las listas `SCA Acceso Decisora*`?
6. ¿Hay más consumidores externos que entren por grupo/URL de SCA (PGM, Decisora PCA, correos DUE) que deban repuntar a SCA2?

Ficheros de apoyo (no versionados): `~/sca2work/r31/grupos.json` (detalle y miembros de los 54 grupos), `r31/grupos_resumen.txt`, `r31/sites_security.json`, `groups_inventory.json`.
