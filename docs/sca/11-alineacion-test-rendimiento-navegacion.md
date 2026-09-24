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
