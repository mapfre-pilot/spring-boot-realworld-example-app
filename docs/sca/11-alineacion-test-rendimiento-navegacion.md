# Alineación con SCA TEST, navegación persistente (F5) y rendimiento del Alta

Fecha: septiembre 2026. Trabajo realizado **solo en TEST**, solo sobre objetos SCA2.
La baseline funcional acordada es **SCA en TEST** (no DEV): se compararon los 353
objetos SCA (interfaces + expression rules) del dump DEV contra TEST y luego cada
equivalente SCA2 contra la versión SCA TEST. Resultado de ese cruce:
**337 idénticos / 13 diferentes / 3 ausentes en TEST**.

## 1. Alineación SCA2 ↔ SCA TEST

| Objeto SCA (estado en TEST) | Equivalente SCA2 | Veredicto |
|---|---|---|
| `SCA_simularAnulacion` (DIFFERENT: TEST elimina `tipoPoliza`/`indicadorReservaPrimas`/`tipoAnulacion` y la rama FORD) | `SCA2_simularAnulacion` | **Cambiado hoy**: rama FORD y locales eliminados; queda siempre `SCA2_simularAnulacionAltaNse`, envuelto en guard de input nulo |
| `SCA_consultarSiniestroPoliza` (DIFFERENT: TEST devuelve `local!body` directo) | `SCA2_consultarSiniestroPoliza` | **Cambiado hoy**: devuelve `local!body` (con guard `numPoliza` nulo). Arregla además el nº de siniestros del año en la cabecera del Alta (verificado con `SCA2_obtenerDatosCabecera`, 2001900000007 → error None) |
| `SCA_DetalleAnulacionContraAnulacionEstrategicas` (TEST añade `polizaNSEHogar`) | `SCA2_DetalleDatos` | **Ya alineado**: tiene ramas explícitas Hogar (`SCA2 Datos Poliza Hogar`), Vida y Autos — sin cambio |
| `SCA_BuscadorTabla` (TEST reescribe columna estado) | `SCA2_BuscadorTabla` | **Legacy sin uso**: en SCA solo la usa `SCA_BuscarSolicitudClientePoliza`; SCA2 usa `SCA2_BuscadorTablaEstrategicas` (idéntica DEV/TEST). Sin cambios |
| `SCA_searchAPIClients` / `SCA_contactMethodAPIClients` (TEST llama CMP_*) | `SCA2_searchAPIClients` / `SCA2_contactMethodAPIClients` | **Ya alineados** vía las integraciones `SCA2_APIClients_*`, que ya apuntan a los connected systems CMP (verificado live) |
| `SCA_erroresGuardarSolicitud` (TEST añade `polizaRenovada`, `fechaUltimoSiniestro`) | `SCA2_erroresGuardarSolicitud` | **Ya alineado** (contiene ambas) |
| `SCA_AltaSolicitudAnulacionEstrategicas` (TEST elimina `causaDDFiltrada`/essi24 y el aviso "póliza anulada") | `SCA2_AltaSolicitudPage` | **Ya alineado** (sin esos bloques) |
| `SCA_GenerarSolicitudPopupEstrategicas` (TEST pierde `a!save(ri!idSolicitud,null)` en onSuccess) | `SCA2_GenerarSolicitudPopup` | **Ya alineado** |
| `SCA_AccionesAdministrativasPrincipalEstrategicas` (TEST pierde un `insertarObservaciones`) | `SCA2_AccionesAdministrativasPrincipal` | Sigue la variante DEV (conserva `insertarObservaciones`); resto es reescritura propia — hunk menor anotado |
| `SCA_DecidirAccion`, `SCA_ArgumentosContraAnulacion` | — | **Sin equivalente** en SCA2 (si se porta el hunk de tréboles, usar la variante TEST sin `tointeger`) |
| `SCA_flagAcuerdosNse`, `SCA_ConsultaConceptosFuncionalesAcuerdosNseRecord`, `SCA_cargaGestionSGC` (MISSING en TEST) | `SCA2_cargaGestionSGC` existe (→ `SCA2_cargaGestionSGC3` → `SCAC_SGC3`, por diseño); los otros dos no tienen equivalente | Sin acción: ausentes en TEST |

### Nota técnica del LCP API (despliegues por API en TEST)

El `PUT` del LCP API **valida evaluando la expresión con los rule inputs a null**.
Si la expresión lanza una integración externa y ese servicio responde 401, el 401 se
propaga y el PUT falla (se comprobó con `SCA2_simularAnulacionAltaNse`).

Patrón aplicado: envolver el cuerpo con un guard de inputs nulos de igual semántica,
p.ej. `if(a!isNullOrEmpty(ri!infoSolicitud), null, a!localVariables(...))` en
`SCA2_simularAnulacion`, y `if(a!isNullOrEmpty(ri!numPoliza), null, …)` en
`SCA2_consultarSiniestroPoliza`. **Nunca** hacer PUTs de diagnóstico (p.ej.
`expression: "1"`) sobre objetos reales.

## 2. Navegación persistente (F5) — diseño final

Igual que la página `decidiraccion` de SCA: **rule inputs de la interfaz de la página
del site + parámetros de URL configurados en Designer**.

- La página `buscador` del site SCA2 tiene configurados en Designer los parámetros de
  URL `vista`, `numPoliza`, `idSolicitud`, `tipoAccion`, `idTarea`, con
  **"Cifrar parámetros"** y **"Actualizar URL cuando cambien los valores de entrada de
  regla"** activados.
- Cualquier `a!save(ri!…)` sobre esos inputs se serializa en la URL como `?$sp=…`
  (cifrado) y F5 reconstruye el estado completo.
- Los parámetros de URL de página de site **no se pueden crear/configurar por lcp-api**
  (probado: el PUT los ignora y el validador de `a!urlForSite` exige el alta en la
  página). Es configuración de Designer únicamente.

Objetos: `SCA2_Buscador` (inputs `vista/numPoliza/idSolicitud/tipoAccion/idTarea`,
vista por defecto "BUSQUEDA"); `SCA2_BuscadorTabla` (dynamicLink → `ri!idSolicitud`);
`SCA2_DetalleSolicitud` (inputs `tipoAccion/idTarea`; `accionAbierta` deriva de
`ri!tipoAccion`; RETOMAR los guarda); `SCA2_DetalleTareas` (Completar/VOLVER con saves);
`SCA2_AltaSolicitudAnulacionPopUp` (botón ALTA con saves); `SCA2_AltaSolicitudPage`
(CANCELAR = botón OUTLINE con diálogo de confirmación → BUSQUEDA + póliza null).

### Por qué se descartó el PM `SCA2 CMD Redirigir`

Se construyó como solución intermedia con `a!startProcessLink` (mecanismo que usa SCA
para el link de solicitud). Descartado y **borrado** (PM + constante
`SCA2_PM_REDIRIGIR_DETALLE`) porque: (1) cada clic creaba una instancia de proceso;
(2) con los URL parameters los `a!save(ri!…)` ya persisten el estado; (3) forzaba
enlaces de texto en lugar de botones con confirmación.

### Verificación (capturas)

| Escenario | Resultado | Captura |
|---|---|---|
| Popup Alta abierto → F5 | El popup se mantiene | `img/t21_f5_popup.png` |
| Póliza 2001900000007 → ALTA → F5 | Alta completo con datos de la póliza | `img/t21_f5_alta.png` |
| CANCELAR → confirmación → Sí → F5 | Vuelve al Buscador y se mantiene | `img/t21_f5_confirm.png`, `img/t21_f5_buscador.png` |

**Pendiente**: F5 dentro de Detalle/Acción — el record `SCA2 Solicitud` no tiene filas
en TEST y no se crean solicitudes de prueba. El mecanismo es el mismo ya verificado.

## 3. Rendimiento del Alta

Medición con `testRule` en TEST, 3 ejecuciones por llamada, póliza `2001900000007`,
timeout 60 s (medias de `diagnostics.durationMs`):

| Llamada | Media | Mín | Máx | Tipo |
|---|---:|---:|---:|---|
| `SCA2_obtenerDatosCabecera` | 3948,0 | 1842 | 5001 | compuesta; integra API Clients y servicios externos |
| `SCA2_pObtenerPolizaFecha` | 171,0 | 154 | 204 | integración Core7 externa |
| `SCA2_consultarReservaPrima` | 586,7 | 167 | 1416 | integración externa |
| `SCA2_consultarSiniestroPoliza` | 542,0 | 494 | 567 | integración externa |
| `SCA2_searchAPIClients` | 569,3 | 558 | 583 | integración CMP API Clients externa |
| `SCA2_contactMethodAPIClients` | 463,0 | 443 | 484 | integración CMP API Clients externa |
| `SCA2_consultarSolicitudes` | 139,3 | 138 | 141 | integración externa |
| `SCA2_obtenerInformacionUsuario` | 1,0 | 1 | 1 | datos de sesión / expresión local |
| `SCA2_consultarCatalogacionRest` | 5,3 | 1 | 12 | catálogo (consulta mínima) |
| `SCA2_consultarMotivo` | 138,0 | 137 | 139 | catálogo / servicio externo |
| `SCA2_consultarDetalle` | 142,7 | 137 | 152 | catálogo / servicio externo |
| `SCA2_consultarCausa` | 137,7 | 136 | 139 | catálogo / servicio externo |
| `SCA2_consultarFechaUltimoSiniestro` | 800,0 | 468 | 1362 | integración externa |
| `SCA2_obtenerTipoPoliza` | 159,3 | 154 | 165 | composición de consulta |
| `SCA2_cargarSolicitud` | 2,7 | 2 | 3 | BBDD / record query |

La consulta de tareas del Detalle no es una regla independiente con input simple;
no se midió por separado sin un contexto de interfaz válido.

### Por qué va lento (priorizado)

1. **La cabecera (~3,9 s) es la suma secuencial de llamadas externas**: reserva (~0,6 s)
   + siniestros (~0,5 s) + `searchAPIClients` (~0,6 s) + `contactMethodAPIClients`
   (~0,5 s) + póliza (~0,2 s) + catálogos. El coste es del **backend PRE** (los mismos
   servicios que consume SCA), no de Appian ni de SCA2 en sí.
2. **Reevaluación en cada interacción**: en `SCA2_AltaSolicitudPage` se evalúan sin
   `a!refreshVariable` propio (se recalculan en cada interacción del formulario):
   `SCA2_obtenerInformacionUsuario`, `SCA2_obtenerTipoPoliza`, `SCA2_consultarPolizas`/
   `SCA2_pObtenerPolizaFecha`, `SCA2_obtenerDatosCabecera`, catálogos Motivo/Detalle/
   Causa, `SCA2_consultarFechaUltimoSiniestro`, `SCA2_calculoCanalEntrada`,
   `SCA2_calculoMedioComunicacion`, `SCA2_consultarCatalogacionRest` y los auxiliares
   de presentación (`SCA2_DatosCliente`, `SCA2_DatosPoliza`, `SCA2_DatosContacto`,
   `SCA2_TablaOtrasSolAnulacion`). Ya protegidos con `a!refreshVariable`:
   `motivoAnulacion`, `detalle`, `causa`, `tipoCatalogacion`, `fechaAnulacion`,
   `telefonoExpertos`, `observaciones`, `compania`, `numFax`.
3. Varianza: algunas integraciones tienen máximos altos (reserva 1416 ms, fecha último
   siniestro 1362 ms) — picos del servicio, no del diseño.

### Mejoras propuestas

- **Paralelizar lo independiente**: las variables locales sin dependencias entre sí se
  evalúan en paralelo por `a!localVariables` — revisar la cabecera para que las 5
  llamadas externas no queden encadenadas. *(Aplicada — ver «Mejoras aplicadas».)*
- **Cachear con `refreshOnVarChange: ri!numPoliza`** (o `refreshOnReferencedVarChange:false`)
  las consultas que solo dependen de la póliza, para que no se reevalúen en cada
  interacción del formulario. *(Aplicada parcialmente: los 9 campos del formulario ya
  tienen `a!refreshVariable`; aplicada en usuario/tipoPolizaCalc/poliza/estructuraCabecera/motivosDD/consultaFecUltimoSiniestro/canalDD; cascada intencionadamente sin tocar — ver «Mejoras aplicadas».)*
- **Evitar re-consultas**: `obtenerInformacionUsuario` es local (1 ms) pero se
  reevalúa cada vez; catálogos Motivo/Detalle/Causa podrían cargarse una vez.
  *(No aplicada.)*
- El grueso (~3,9 s de cabecera) es latencia del backend PRE; optimizar el servidor es
  decisión fuera del alcance de SCA2. *(Documentado; sin acción en SCA2.)*

### Mejoras aplicadas (TEST, 24-sep)

**1. Paralelización de `SCA2_obtenerDatosCabecera`** — se elevaron a locales top-level
las llamadas externas que estaban anidadas dentro de otras llamadas o del bloque de
resultado (se evaluaban en serie tras el resto):

- `local!infoUsuario` (`SCA2_obtenerInformacionUsuario`) y `local!nuuma`
  (`CMP_obtenerNuuma`) — antes `nuuma` iba *dentro* del body de
  `SCA2_consultarCabecera` (serial) e `infoUsuario` se invocaba dos veces inline en
  las consultas de siniestros.
- `local!consultaReservaPrima` y `local!addresAPI` — antes dentro del
  `a!localVariables` de construcción del resultado (se evaluaban después de
  `cabecera`/`otrasSolicitudes`); ahora corren en paralelo con ellas.
- La cadena real se mantiene: `searchAPIClients → benefits/profile/integrality/
  contactMethod` y `poliza → datosPersonales/datosVehiculo → siniestros/reserva/
  cabecera`.
- Se añadió el guard `if(a!isNullOrEmpty(ri!numPoliza), null, …)` exigido por el
  LCP API. Salida verificada **byte a byte idéntica** (JSON ordenado) para las dos
  pólizas de prueba.

**2. `a!refreshVariable` en `SCA2_AltaSolicitudPage`** — protegidas con
`refreshOnVarChange: ri!numPoliza`: `tipoPolizaCalc`, `poliza`,
`estructuraCabecera` (la llamada de 3-4 s ya no se reevalúa en cada interacción del
formulario), `motivosDD`, `consultaFecUltimoSiniestro`, `canalDD`; y con
`refreshOnReferencedVarChange: false`: `usuario`. **Sin tocar** la cascada
`detalleDD`/`causaDD`/`medioDD`/`consultaCatalogacion` (dependen de selecciones del
usuario).

#### Medición antes/después (testRule ×3, TEST)

| Póliza | Antes (media) | Después (media) | Antes (min) | Después (min) |
|---|---:|---:|---:|---:|
| 2001900000007 | 5.017 ms | 3.373 ms | 4.302 | 2.965 |
| 2002000048398 | 5.142 ms | 3.178 ms | 3.139 | 3.053 |

En régimen caliente (descartando el primer disparo): ~4,4 s → ~3,1 s (~30 %).
Verificado en Chrome que el Alta muestra la misma cabecera y que la cascada
Motivo→Detalle sigue funcionando (`img/t21_perf_alta.png`).

## 4. Asignación de tareas en SCA2 (resumen)

Fuente de verdad = record `SCA2 Tarea` (sin tareas humanas de Appian):

- `SCA2 CMD CrearAccion` (nodo "Write Asignacion"): `asignadoA` =
  `if(and(nivelIntervencion<>1, codsubperfil="CE_MF_SI24_EXPERTO"), null, pp!initiator)`
  (null = pool del grupo); `propietario` = `pp!initiator` siempre; `grupo` = codperfil.
- Regla nueva `SCA2_puedeGestionarTarea(tarea, nivelIntervencion)`:
  admin (`SCA2_GRP_ADMINISTRADORES`) OR `asignadoA = loggedInUser()` OR
  (asignadoA null AND perfil = tarea.grupo).
- `SCA2_reasignarTarea`: `a!writeRecords` directo (asignadoA = usuario actual,
  fechaCaptura = now()) — sin PM.
- `SCA2_DetalleSolicitud`: RETOMAR y REASIGNAR (OUTLINE) gobernados por la regla;
  REASIGNAR abre `SCA2_PopUpReasignarTarea`.
- `SCA2_DetalleTareas`: Completar con la misma regla + columna "Asignado a"
  (displayName o "Grupo <grupo>").

Verificado por testRule (3 casos OK) y testInterface; la verificación visual queda
pendiente de que existan solicitudes en TEST. Detalle completo en
`t20/asignacion_tareas.md`.

## 5. Recomendación "Invalid parameter" corregida (SCA2_consultarConceptoReutilizable)

**Causa**: `SCA2_consultarConcepto` perdió el input `rand` en TEST (edición de
Álvaro, 23/09 15:06) pero `SCA2_consultarConceptoReutilizable` seguía pasando
`rand: null` como kwarg → "Invalid parameter". SCA TEST conserva el input `rand`
en ambas reglas. **Corrección**: eliminado el kwarg `, rand: null` de la llamada
(restaurando paridad funcional con SCA). testRule: 849 ms → 368 ms, resultado
idéntico (null, sin error). Copia en `t20/tst_sca2_dump/`.

## 6. Paridad UI SCA2 ↔ SCA TEST — correcciones aplicadas

| # | Objeto | Desviación | Corrección |
|---|---|---|---|
| 1 | `SCA2_AltaSolicitudPage` | "Tipo catalogación" editable en Vida | `disabled: local!tipoPoliza = cons!SCA2_TXT_VIDA_RIESGO` |
| 2 | `SCA2_DetalleSolicitud` | REASIGNAR OUTLINE rojo | `color: "SECONDARY"` |
| 3 | `SCA2_AccionesAdministrativasPrincipal` | FINALIZAR disabled solo por `noEntregaDoc`; confirm POSPONER distinto | añadidos locals `dniAdjunto`/`1Adjunto..5Adjunto` (misma lógica SCA) + `disabled: not(or(noEntregaDoc, and(dniAdjunto, or(1..5))))` + texto "Se va a posponer la solicitud de anulación" |
| 4 | `SCA2_ContraAnulacionOpciones` | POSITIVO/NEGATIVO sin `showWhen`; textos confirm distintos | `showWhen: not(local!collapse2)` + textos SCA ("Se va a finalizar la contra anulación") |
| 5 | `SCA2_AnulacionFueraNormaPrincipal` | FINALIZAR disabled distinto | `not(or(noEntregaDoc, documentosOk))` |
| 6 | `SCA2_MecanizacionPrincipal` | CANCELAR con confirmación (SCA no tiene) | confirmación eliminada |
| 7 | `SCA2_Buscador` | "Tipo documento" con literales, sin limpieza cruzada, sin "Tipo Poliza" | constantes `SCA2_TXT_*TIPO_DOCUMENTO_BUSQUEDA` (ya existían con valores SCA) + saveInto que limpia póliza/matrícula/bastidor + dropdown "Tipo Poliza" {NO VIDA, VIDA} que limpia matrícula/bastidor en VIDA |
| 8 | `SCA2_GenerarSolicitudPopup` | OK sin startProcess | SIN CAMBIO — el CMD SCA2 sustituye al PM SCA por diseño; sin llamadores pendientes |
| 9 | `SCA2_VertiVencimientoPrincipal` | — | sin equivalente SCA (nuevo por diseño) |

Desviaciones menores aceptadas (documentadas en `t20/paridad_ui.md`): POSPONER de
ContraAnulacionOpciones usa confirm nativo en vez del diálogo custom de SCA;
botón "Adjuntar Documentacion" de SCA-FueraNorma no se replica (saveInto muerto
en SCA). Auditoría completa en `t20/paridad_ui.md` (14 secciones).

Validación: las 7 interfaces actualizadas devolvieron objeto OK en
`updateInterface` (validación de expresión server-side en el PUT) y re-GET
confirma el SAIL desplegado = copia local en `t20/tst_sca2_dump/`.

## 7. Incidente Alta 15787499 y reanudación

**Incidente.** Alta real de la póliza 2002000024445 (usuario JJGONZ2) ejecutó `SCA2 CMD Alta`: la integración Core7 `generarStudAnul` **respondió correctamente** (creó la solicitud Core7 idSolicitud **15787499**; `pv!err` vacío, `pv!generar.error` nulo, salida custom computó `pv!idSolicitud="15787499"`), pero el XOR nodo 5 "Resultado?" (`or(pv!success<>true, isNullOrEmpty(...idSolicitud...))`) se fue por la rama de Error igualmente. Resultado: nodo 206 escribió `SCA2 Solicitud` (id=3, idSolicitud 15787499, estado ALTA, sin grupoAsignacion) y nodo 6 escribió `SCA2 Error` id=3 con idSolicitud `PDTE-13118844` (pp!id), nodo `generarStudAnul`, mensaje/payload vacíos. No se escribieron Datos Básicos / Datos Solicitud / Transición / Tarea y no se arrancó `SCA2 CMD Decidir`.

**Causa probable.** `pv!success` no se pobló desde la salida `Success` del nodo Call Integration (la evaluación del XOR corría sobre un `success` indefinido), y/o el `Dictionary` devuelto por `SCA2_mapSalidaGenerarStudAnul` se degradaba al guardarlo en `pv!generar` (declarado `Any Type`).

### Correcciones aplicadas (TEST, solo SCA2, backup + re-GET)

| Objeto | Cambio |
|---|---|
| `SCA2_mapSalidaGenerarStudAnul` | Devuelve `a!map` en todos los niveles (`success`, `error` como a!map, `result` a!map). Mismas claves/valores. |
| `SCA2 CMD Alta` (PM) | `pv!generar`: Any Type → **Map**. Nuevo parámetro **`idSolicitudExistente`** (Text, no requerido). Nodo 4: salida custom `a!defaultValue(ac!Success,false)` → `success`. Nodo 5 XOR → `or(a!isNullOrEmpty(pv!idSolicitud), left(pv!idSolicitud,5)="PDTE-")`. Nodo 6: `idSolicitud = pv!idSolicitud`; `payload = a!toJson(a!map(...))` con los 16 PVs parámetro + `errorTecnico`. Nodos 9 y 206: **upsert** por lookup `id` en `idSolicitud = pv!idSolicitud` (patrón del nodo 11); `createdAt`/`createdBy` solo cuando el lookup es null. |
| Nodos nuevos 14/15 | XOR "¿Reanudar?" (`not(isNullOrEmpty(pv!idSolicitudExistente))`) → Script Task "Reanudar" (outputs: `idSolicitud`, `success=true`, `generar` map sintético) → nodo 7 Contexto; default → nodo 4. |
| `SCA2_BandejaErrores` + `SCA2_DetalleErrores` | Texto "Repetir alta desde la pantalla Alta" reemplazado por `-` si `payload` vacío; si no, link **Relanzar** que hace `a!startProcess(cons!SCA2_PM_CMD_ALTA, rule!SCA2_parametrosRelanzarAlta(error: fv!row))` + `rule!SCA2_relanzarError` (estado RELANZADO). `payload` añadido a los campos de la query. |
| `SCA2_parametrosRelanzarAlta` (nueva) | Devuelve el map de los 16 parámetros del PM construido explícitamente desde las claves del `a!fromJson(payload)` (un campo ajeno nunca rompe `startProcess`) + `idSolicitudExistente`: null si `idSolicitud` empieza por `PDTE-`, si no el propio id. 2 test cases (`alta_idSolicitud_real`, `alta_pdte_2`, NO_ERRORS) **pasados**. |

Dump del PM: `t20/pm_alta_test_v2.json` (`validateDesignObject` → `hasErrors:false`).
`sca2_error.payload` = `LONGVARCHAR(65535)` (tipo CLOB) — el JSON de relanzamiento cabe sin truncar.

### Relanzamiento del alta 15787499 — ejecutado OK

TEST volvió tras ~40 min de 401. Se lanzó `SCA2 CMD Alta` vía `testProcessModel`
con `idSolicitudExistente="15787499"` y `datosContexto` de
`SCA2_construirContextoAlta` (motivo "1" DECISION DE CLIENTE, detalle "1" PRECIO,
causa "1" ME HA SUBIDO MUCHO LA PRIMA, catalogación "2" A VENCIMIENTO, canal "1"
PRESENCIAL, `origenPoliza` "NSE-Autos", `usuario` JJGONZ2@mapfrenopro.onmicrosoft.com,
`fecAnulacion` 2027-03-04, `idCompania` 41).

**Resultado: `COMPLETED`.** La rama de reanudación (XOR 14 → Script 15 → nodo 7)
funcionó: `pv!success=true`, `pv!idSolicitud="15787499"`, `pv!generar` es el Map
sintético. Verificación de filas:

- `SCA2 Solicitud`: **sigue habiendo una sola fila** (id=3, idSolicitud 15787499) —
  el upsert la actualizó en lugar de duplicarla (`modifiedBy`=devin).
- `SCA2 Datos Solicitud`: 1 fila nueva (id=1, codmotivo 1 / coddetalle 1 / codcausa 1,
  canalentrada 1, usuario JJGONZ2). `SCA2 Datos Basicos Solicitud`: 1 fila nueva.
- `SCA2 Transicion`: 1 fila `SCA2 CMD Alta` → ALTA, `resultado OK`,
  clave idempotencia `SCA2 CMD Alta|15787499|1`, processId 268931940.
- `SCA2 Tarea`: 0 (esperado; la decisión la inicia `SCA2 CMD Decidir` desde el nodo 12).
- No se creó ninguna fila nueva en `SCA2 Error`.

**Hallazgo del propio relanzamiento**: el upsert escribía `null` en `createdAt`/
`createdBy` cuando la fila ya existía (borraba la auditoría). Corregido en caliente
en los nodos 9 y 206: ahora `a!defaultValue(<lookup del campo existente>, now() /
pp!initiator)`. Re-GET verificado y `validateDesignObject` → `hasErrors:false`.
Los valores originales de la fila id=3 se restauraron manualmente
(`updateRecordData`). `SCA2 Error` id=3 quedó `estado=RELANZADO`,
`resueltoPor=devin`, `fechaResolucion=2026-09-24 15:40`. Evidencia completa en
`t20/relanzar_15787499.log` (antes/después por record type).

## 8. Encadenamiento CMD→CMD: referencias de PM corregidas

Los 10 nodos Start Process de los CMDs de SCA2 apuntaban a un icono
(`SYSTEM_CONTENT_ICON_*`) en lugar del PM destino — el encadenamiento estaba roto
desde la creación (por eso el Alta 15787499 completó sin arrancar Decidir).
El PUT de nodo rechaza `value` con uuid plano; el formato correcto (igual que
ya usaba Barrido n4) es `expression: '=cons!SCA2_PM_CMD_*'` + `value: null`
(hay que quitar `value` de `ProcessParameters`, cuyo `typeRef` no round-tripea).
Nota: `expression: '="<uuid>"'` se aceptaba en el PUT pero en runtime evalúa como
texto y el Start Process falla con `ID del modelo de proceso: -2147483647`.

| PM | Nodo | Destino corregido |
|---|---|---|
| Alta | 12 Start Decidir | `0000f06f-0eab-…` (Decidir) |
| Decidir | 11 Start Decidir (reintento) | `0000f06f-0eab-…` (sí mismo) |
| Decidir | 12 Start CrearAccion | `0000f06f-0eaa-…` |
| Decidir | 15 Start Finalizar | `0000f06f-1309-…` |
| CrearAccion | 14 Start Finalizar | `0000f06f-1309-…` |
| CrearAccion | 15 Start Decidir | `0000f06f-0eab-…` |
| CompletarAccion | 8 finalizar / 10 crearaccion / 12 decidir | Finalizar / CrearAccion / Decidir |
| Mecanizar | 14 Start Finalizar | `0000f06f-1309-…` |
| Barrido | 4 Start Caducar | `0000f06f-4f07-…` |

Re-GET confirma `="uuid"` en los 10; `validateDesignObject` → `hasErrors:false`
en los 8 CMDs. Dumps: `t20/pm_chain_v1/`.

**Causa raíz del null de `SCA2_mapearDatosDecidirAccion`**: la regla
`SCA2_consultaBBDDSCA` se llamaba a sí misma en `local!integracion` (recursión
infinita → null). Corregida para llamar a `rule!SCAC_consultaBBDDSCA(request:{...})`
como SCA; testRule con 15787499 devuelve el CDT poblado. Además, el mapear leía
`datosPerfilesPca.codPerfil/codSubPerfil` pero `SCA2_cargarSolicitud` emite las
claves en minúsculas (`codperfil/codsubperfil/codcompania`, igual que el record
type SCA2 Datos Perfiles Pca) — corregido en SCA2_mapearDatosDecidirAccion
(4 ocurrencias; la variante `...Estrategicas` ya usaba referencias tipadas).

**Resiliencia nodo 5 "Consultar reglas" (Decidir)**: el input `decision` ahora
computa el DTO en `local!dto`; si es null devuelve `a!map(accion:"ERROR",
grupo:"ERROR", subgrupo:"ERROR", error:"DTO decision nulo (mapearDatosDecidirAccion)")`
en vez de llamar a `SCA2_consultarServiciosReglas`. Si no es null, se desenvuelve
con `index(local!dto,1,local!dto)` porque el mapear devuelve `{CDT}` (lista de 1,
como en SCA) y `consultarServiciosReglas` espera un solo CDT
(`Could not cast SCAC_scaServiciosReglas?list to Map` en el primer rerun).

**Prueba de cadena (15787499), run final**: `testProcessModel` de
`SCA2 CMD Decidir` → **COMPLETED** (proc 497255). `pv!decision =
{accion:"ERROR",grupo:"ERROR",subgrupo:"ERROR"}` (PRE responde error — esperado),
`destinoMecanizar=FINALIZAR`, `intentos=2`, `codPerfil=CE_RM`,
`codSubPerfil=CE_RM_OFICINA`. Filas: Solicitud 1 (ALTA, consistente),
Transicion 1 (solo la del Alta — Decidir no escribe Transicion en su flujo),
Error 2 (DECISION_ERROR id=4 del run con PM roto + id=5 del run final,
ambas PENDIENTE/intentos=1), Tarea 0. Los 8 CMDs revalidados
`hasErrors:false`; dumps finales en `t20/pm_chain_v1/`.

### Inyección de decisión y prueba de `SCA2 CMD CrearAccion` (15787499)

PRE devuelve 500 para toda póliza, así que se inyectó la decisión replicando los
writes del nodo 9 "Write Decidida POPUP_SGO" de Decidir (ruta default para una
acción no-ERROR nivel 1): Solicitud `estadoSolicitud=DECIDIDA`,
`procesoActivo=<accion>`, `interfazActiva=POPUP_SGO`, version+1; Transicion OK
`SCA2 CMD Decidir` → DECIDIDA; Datos Perfiles Pca ya tenía CE_RM/CE_RM_OFICINA.
Errores 4–6 marcados `DESCARTADO`/`devin`.

Hallazgo: la acción correcta en SCA es `CONTRAANULAR` (sin espacio, constante
`SCA_TXT_ACCIONES`); el primer run con `CONTRA ANULACION` fue rechazado y, además,
el XOR nodo 5 "Accion?" de CrearAccion **no incluía `CONTRAANULAR`** en la rama
Humana (bug SCA2 vs SCA, cuyo dispatch sí la rutea a tarea humana) — corregido
añadiendo `pv!accionCalc="CONTRAANULAR"` a la condición Humana (PUT 200, re-GET
confirma).

Re-inyección con `CONTRAANULAR` + run `testProcessModel` CrearAccion →
**COMPLETED** (proc 12063074). Filas: Solicitud `EN_ACCION`, interfazActiva
`CONTRA_ANULAR`, estadoTarea `PENDIENTE`, caducidad +1d; Transicion id=3 OK
(`SCA2 CMD CrearAccion|15787499|5`); **SCA2 Tarea id=1** creada (nombre/tipo
CONTRAANULAR, estado PENDIENTE, grupo CE_RM, propietario devin, token
TK-12063074-…, prioridad NORMAL, fechaCaducidad `SCA2_obtenerCaducidadNivel`).
El nodo 7 no escribe `asignadoA` (asignación por grupo, igual que SCA);
Error 7 (ACCION_DESCONOCIDA del primer run) marcado `DESCARTADO`.
Evidencia: `t20/crearaccion_15787499.log`, `pm_chain_v1/CrearAccion.json`
(pre-fix del XOR; el fix se re-GETeó).

**Asignación de tareas**: los nodos que crean/reasignan `SCA2 Tarea` (CrearAccion
n7 y n16, Mecanizar n7 VERTI) ahora escriben `propietario` y `asignadoA` con
`index(pv!sol.estado,"usuario")` (el usuario del alta) en lugar de `pp!initiator`,
con la guarda `if(tointeger(nivel)<>1 and codsubperfil="CE_MF_SI24_EXPERTO",
null, usuario)` para `asignadoA` — en SCA2 cada CMD es un proceso separado y
`pp!initiator` sería el lanzador del CMD, no el del alta. Tarea id=1 actualizada
a mano: asignadoA/propietario = JJGONZ2@mapfrenopro.onmicrosoft.com.

**Fixes UI (15787499)**: `SCA2_DetalleSolicitud` acordeón Contraanular — el `if`
de la columna GESVIDA usaba `and` infijo dentro de los argumentos de `if()`, que
Appian cuenta como parámetros separados ("passed 4"); corregido a
`if(and(local!esVida, index(fv!item,"tipo","")="VERTI"), ...)`.
`SCA2_textoEstadoSolicitud`/`SCA2_colorEstadoSolicitud`: nuevo input `accion`
(procesoActivo); EN_ACCION ahora etiqueta por acción ("Contra anulación en curso",
"Autorización en curso", "Acción administrativa en curso", "Mecanización en
curso"; default "Solicitud Pendiente") en vez de "Solicitud Pendiente" siempre —
paridad con los literales `SCA_TXT_ESTADO_SOLICITUD_PCA` de SCA. Callers
actualizados: `SCA2_BuscadorTabla`, `SCA2_TablaOtrasSolAnulacion`,
`SCA2_SolicitudAnulacion`. El Buscador de SCA no tiene columna "Asignado a"
(queda solo en la grid de tareas del Detalle).

**Fixes UI 2 (15787499)**: el Buscador seguía mostrando "Solicitud Pendiente"
porque la query de `SCA2_Buscador` no seleccionaba `procesoActivo` — añadido a
`fields`; la etiqueta "Contra anulación en curso" ya se deriva bien.
`SCA2_DetalleTareas`: el router de RETOMAR hacía match sobre `tipo` con las
claves de pantalla ("CONTRA ANULAR") pero CrearAccion escribe `tipo =
procesoActivo` ("CONTRAANULAR", "ACCIONES ADMINISTRATIVAS", "MECANIZAR", VERTI) —
añadida normalización `local!pantalla` (a!match de los 15 valores de
`SCA_TXT_ACCIONES` a las 5 claves de pantalla) antes del match de la pantalla.
Columna "Asignado a" ya existe en la grid de `SCA2_DetalleTareas`; el acordeón de
SCA muestra solo Grupo/Nuuma (igual que SCA2) — sin cambios ahí.
**Decidir 15787516 (DTO nulo + constante PM + mensaje error)**: el
`SCA2_mapearDatosDecidirAccion` declaraba `datosSolicitud` con tipo record-type
*SCA2 Solicitud* — Appian casteaba el `sol` completo al record y descartaba
`datosCompletosSolicitud`/`datosPerfilesPca`/`datosPolizaAutos`, así que todos
los `reduce` devolvían null → `consultarServiciosReglas` → `accion:ERROR` →
`ERROR_DECISION` tras 3 reintentos (diseño: XOR `accion=ERROR` y
`intentos<3` → Write Error PENDIENTE + Start Decidir reintento; `intentos>=3` →
Write Error BLOQUEADO; las 3 filas Error 14-16 corresponden a eso).
Además las claves del CDT estaban en camelCase pero `cargarSolicitud` emite
minúsculas (`canalentrada`, `codmotivo`, `claveproduccion`…). Fixes:
input `datosSolicitud` → `Map`, claves → minúsculas; DTO ahora poblado y la
decisión PRE devuelve `CONTRAANULAR` para 2002000010177.
Mensaje de Error vacío: nodos 7/8 escribían `mensaje/payload` desde `pv!err`
(null); ahora `a!toJson(pv!decision)` como fallback (re-GET confirmado).
`SCA2_textoEstadoSolicitud`: `ERROR_DECISION` → "Error en el servicio de
decisión" (paridad con texto SCA).
Bug extra encontrado: nodos Start Process usaban `cons!SCA2_PM_CMD_CREARACCION`
pero la constante real es `SCA2_PM_CMD_CREAR_ACCION` → runtime "-2147483647";
corregido en Decidir n12 y CompletarAccion n10 (re-GET OK). Relanzamiento:
Decidir COMPLETED parcial (decisión OK, falló solo el Start CrearAccion por la
constante) → tras el fix, `SCA2 CMD CrearAccion` para 15787516 COMPLETED:
Solicitud `EN_ACCION`/`CONTRA_ANULAR`/`estadoTarea PENDIENTE`, Transicion OK
DECIDIDA→EN_ACCION y **Tarea id=2 CONTRAANULAR PENDIENTE asignada a
JJGONZ2@mapfrenopro.onmicrosoft.com (grupo CE_RM)**. Filas Error 14-16 quedan
PENDIENTE/BLOQUEADO con mensaje vacío (escritas antes del fix de mensaje).
Logs: `t20/decidir_15787516.log`, `t20/crearaccion_15787516.log`,
`t20/sol_15787516.json`, `t20/dto_15787516.json`, `t20/dec_15787516.json`.

### 8.x Paridad funcional JJGONZ2 (tanda post-15787516)

| Item | Cambio SCA2 | Resultado |
|---|---|---|
| Post-GUARDAR | `SCA2_AltaSolicitudPage`: `isSynchronous:true` + `onSuccess` guarda `local!idSolGenerada` (pv.idSolicitud); se muestra card `style:"INFO"` (azul) con "Su solicitud se ha generado correctamente. Se le va a redirigir a la acción correspondiente" + OK→`/buscador?idSolicitud=…&numPoliza=…` | Mismo mensaje azul que SCA |
| Refresh tareas/sol | `SCA2_DetalleSolicitud`: `a!refreshVariable(refreshInterval: if(estado in ALTA/DECIDIDA o tareas vacío, 0.5, "NEVER"))` en `local!sol` y `local!tareas` | Polling solo hasta EN_ACCION |
| Cabecera Detalle | Detalle usa `SCA2_obtenerDatosCabecera` (misma llamada que Alta) → `estructuraCabecera.datosCliente/datosPoliza/datosContacto` | Campos cliente poblados |
| Acordeón Alta | Campos Perfil/Grupo/Nuuma/Nivel desde `SCA2_consultaGestion(codSolicitud).infoUsuario` + `nivelIntervencion` | "RED MAPFRE"/"OFICINA"/"JJGONZ2"/"1" |
| Popup Tipo póliza | Dropdown {"NO VIDA","VIDA"}{1,2} → `local!eleccionPoliza` (bloque idéntico a SCA, antes de Número póliza) | Añadido |
| Site | Pages Errores + Gestiones mantenimiento `visibilityExpr: a!isUserMemberOfGroup(loggedInUser(), cons!SCA2_GRP_ADMINISTRADORES)` | Solo admins ven las tabs |
| Trazabilidad técnica | Ya estaba `showWhen: local!esAdmin` (misma condición de grupo) | Sin cambios |

`testInterface` SCA2_DetalleSolicitud(15787516): sin errores, 3.5 s; re-GET
confirma las 3 interfaces (`sca2_ui/*_reget.sail`) y el site v8.

`refreshInterval` corregido a `if(cond, 0.5, null)` (NEVER no es valor válido).
testInterface Detalle 15787516 (EN_ACCION): sin errores 3.7 s; PDTE-268927149
(ALTA): sin errores 6.7 s. PM Alta verificado: sin nodos attended →
isSynchronous devuelve pv.idSolicitud al finalizar.
