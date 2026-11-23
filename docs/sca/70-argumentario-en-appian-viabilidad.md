# 70 · Llevar a Appian el servicio de argumentario (preparar request → reglas → argumentario): viabilidad

> Alcance: análisis. **No se ha modificado ningún objeto Appian, servicio ni dato** (ni SCA, ni SCAC, ni CORE).
> Fuentes: doc [59](59-optimizacion-consultarListadoArgumentos.md), sesión «Optimizar servicio SCA2_consultarListadoArgumentosREST» (27‑28/10/2026, código Plastic `ES_SSCC_SCA_BINT`, `ES_SSCC_SCA_SERVICIOS_BE_CODE`, `ES_SSCC_SCA_CORE_CODE`, `ES_SSCC_SCA_FRONT_CODE`) y medidas hechas entonces en Appian TEST.
> Leyenda: **[Observado]** visto en código o medido · **[Inferido]** deducido, a confirmar.

## 1. Respuesta corta

- **Sí se puede hacer en Appian**, pero **solo se gana tiempo si se deja de llamar al servicio de reglas en cada apertura**. Mover a Appian los mismos pasos que hace hoy el servicio, en el mismo orden, tardaría lo mismo: casi todo el tiempo es de la llamada a reglas.
- El servicio actual (`es_pca_gestionartareas_bbe-web`, `consultarListadoArgumentos`) **regenera el argumentario entero en cada llamada** (abrir la tarea, recargar, volver de un positivo/negativo). El SCA antiguo (frontal JSF) solo lo generaba la primera vez. **[Observado]**
- Propuesta: Appian decide cuándo hace falta regenerar (primera entrada en la gestión/nivel) y el resto de veces **solo lee** el argumentario de CORE y usa catálogo y tréboles guardados en Appian. Reaperturas: de **~4,4 s** (3,2‑16,6 s) a **~1‑1,5 s** con la lectura SOAP de CORE, o **< 1 s** con un endpoint de solo lectura del BBE. **[Inferido, a medir]**
- Necesita **una decisión funcional del analista**: hoy reglas vuelve a recomendar tras cada positivo/negativo y puede cambiar los pendientes; con la propuesta solo lo haría al cambiar de gestión o de nivel (como el SCA antiguo).

## 2. Qué hace hoy el servicio por dentro [Observado]

`GestionarArgumentosBLImp.consultarListadoArgumentos` (repo `ES_SSCC_SCA_BINT`, rama `/INTEGRATION`), en **cada** llamada:

| # | Paso | Coste |
|---|---|---|
| 1 | Lee el argumentario de CORE con consulta directa a BD (`A2139006` × `D2139004` × `A2139003`), por nivel y orden | Rápido |
| 2 | **Llama siempre al servicio de reglas** `sca_servicios/.../argumento` (prepara la request con los datos del body) | **3,4‑9 s**: dentro hace ~26 llamadas a otros servicios en 2 tandas paralelas + BRMS + log `SCA_AGR_LOGS` |
| 3 | **Borra** todos los argumentos no ejecutados de la solicitud | BD |
| 4 | **Inserta** los recomendados, salvo los ya ejecutados en ese nivel (NUUMA del usuario) | BD |
| 5 | Vuelve a leer el argumentario | Rápido |
| 6 | Cuenta ejecutados y añade tréboles al texto («N TREBOLES DISPONIBLES» / «TREBOLES RECOMENDADOS»); graba tréboles BigData (`insertarTrebolesBD`) | BD |
| 7 | Vida: el argumento 356 toma el texto de una nota de la póliza | Llamada extra |

- La rama `/INTEGRATION/PCA-4113 - Optimización del argumentario` **no** optimiza esto: misma lógica sin los pasos 6 y 7.
- El paso 3 explica casos vistos en TEST (15788331, 15788336): con otro perfil reglas devolvió otra cosa, se borraron los pendientes y no se reinsertaron.
- El frontal antiguo (`ContraAnularBC`, `ES_SSCC_SCA_FRONT_CODE`) hacía: leer CORE (`listarDetalleArgumentosCntrAnu`) → solo si error 4102 «no existen argumentos»: preparar solicitud, llamar a reglas, grabar con `generarCntrAnu`, releer.

## 3. Tiempos medidos en TEST (oct‑2026) [Observado]

| Pieza | Tiempo |
|---|---|
| Listado actual (REST BBE), 24 llamadas, misma solicitud y usuario | media **4,4 s**, rango 3,2‑16,6 s (8,7 s media histórica SCA2, 29 % fallos, timeouts de 300 s) |
| Solo reglas `argumento` (`SCA2_scaServiciosReglas`) | 3,4‑3,7 s (5,8 y 8,9 s en frío) |
| Lectura SOAP de CORE (`listarDetalleArgumentosCntrAnu`, integración ya existente) | 0,9‑1,2 s |
| Catálogo de tipos de argumento en Appian (`sca2_cat_tipo_argumento`) | 18 ms |

Conclusión: **reglas es ~80 % del tiempo** del listado. Preparar la request en Appian + reglas + leer en Appian ≈ el mismo tiempo que hoy.

## 4. Qué se puede hacer en Appian

| Pieza | ¿En Appian? | Cómo |
|---|---|---|
| Preparar la request | **Sí, ya está** | El body se monta en `SCA2_ContraAnulacionOpciones`; la request de reglas ya la arma `SCA2_scaServiciosReglas` |
| Decidir si hay que regenerar | **Sí (nuevo)** | Regla: regenerar solo si CORE responde 4102 o cambia gestión/nivel respecto a lo guardado |
| Llamar a reglas `argumento` | Sí, ya existe la integración | Solo cuando toca regenerar (idealmente en el proceso, fuera de la pantalla) |
| Grabar el argumentario en CORE | Sí, por SOAP de CORE | `generarCntrAnu` / `IGestionarArgumentosPCA` (`guardarEjecuArg`, `modificarArgumento`). **Falta confirmar** una operación para borrar pendientes (paso 3) |
| Leer el argumentario | Sí, con límites | SOAP CORE (0,9‑1,2 s). No da exactamente lo mismo: solo mira la gestión activa y valida perfil/préstamo; en gestiones cerradas da error donde el BBE devuelve listado. Paridad exacta → endpoint de solo lectura en el BBE (reutiliza su paso 1) |
| Catálogo (descripción, instrucciones, URL, campañas) | **Sí** | `sca2_cat_tipo_argumento` (18 ms), refrescado desde el Mantenimiento |
| Tréboles | **Sí** | Guardar los que devuelve reglas en una tabla SCA2 (solicitud, gestión, nivel) y reutilizarlos |
| Tréboles BigData (`insertarTrebolesBD`) y nota Vida 356 | Con cuidado | BigData es inserción directa a BD en el BBE (Appian no tiene conexión a TRON_LD); habría que mantenerla en el BBE o por servicio |

## 5. Opciones

| Opción | Qué cambia | Reapertura | Paridad | Quién |
|---|---|---|---|---|
| **A. Solo mejoras Appian, sin cambio funcional** | Evitar llamadas repetidas, reintento ante `StaleConnectionException`/`TransactionException`, timeout 30‑60 s | Igual (~4,4 s) pero menos fallos y sin bloqueos de 5 min | Total | Appian |
| **B. Orquestación en Appian con SOAP de CORE** | Appian hace: leer CORE → (si toca) reglas + grabar + releer; catálogo y tréboles en Appian | ~1‑1,5 s | Casi: difiere en gestiones cerradas; borrado de pendientes y BigData por confirmar | Appian + analista |
| **C. Híbrida (recomendada)** | Como B, pero la lectura con un endpoint de solo lectura del BBE (paso 1 + recuento + tréboles) y el listado completo actual solo al regenerar | **< 1 s** | Exacta | Appian + equipo BBE (cambio pequeño) + analista |

Todas irían detrás de una constante `SCA2_USAR_*` para volver atrás, sin tocar SCA ni el BBE compartido (salvo el endpoint nuevo de C), y se validarían comparando campo a campo con el listado actual en solicitudes nuevas de TEST.

## 6. Pendiente de decidir / información necesaria

1. **Analista:** ¿vale regenerar el argumentario solo la primera vez por gestión/nivel (no tras cada positivo/negativo ni al recargar)? Sin esto, B y C no ganan tiempo.
2. **Equipo BBE** (`es_pca_gestionartareas_bbe-web`): ¿pueden exponer el endpoint de solo lectura (opción C)?
3. **CORE:** operación SOAP para borrar argumentos pendientes, si se elige B.
4. **Datos de prueba:** pólizas nuevas que deriven a contra anulación N1, para comparar con solicitudes nuevas.

## 7. Piezas que ya existen en Appian TEST para sustituir el servicio [Observado]

| Paso del BBE | Pieza Appian existente | Contrato |
|---|---|---|
| Leer argumentario (paso 1/5) | `SCAC_listarDetalleArgumentosCntrAnuIntegracion` (SOAP `IContraAnularPCA.listarDetalleArgumentosCntrAnu`) | Entrada `codSolicitud`, `infoUsuario`. Salida `numArgEjecutados` + `listaCompletaArgContrAnuDTO[]`: orden, descTipoArgumento, mcaEstado, mcaObligatorio, usuario, fecEjecutado, observaciones, codTipoArgumento, codDocumEstatico, txtLanzarAplicacion, txtInstrucciones, urlAplicacion, txtUrlArg, infoCiaContraria, atributosLanzarAplicacionDTO, codIdCampana, codTipBon, numTipBon, mcaEconomico |
| Llamar a reglas (paso 2) | `SCA2_scaServiciosReglas` (`sca_servicios/.../argumento`) | Ya en uso en SCA2 |
| Grabar recomendación (paso 4) | `SCAC_generarCntrAnuIntegracion` (SOAP `IContraAnularPCA.generarCntrAnu`) | Entrada `codSolicitud`, `codTipoNegocio`, `infoUsuario`, `listadoContraAnulDTO[]` (descTipoArgumento, txtApliArgumento, orden, mcaObligatorio, codTipoArgumento, codTpEjecArgumento, textObservacionEjec, impCIAContraria, numSpto, centroEmisor, codCiaContraria, codIdCampana, codTipBon, numTipBon). Salida `codGestion` |
| Ejecutar / modificar argumento | `SCA2_guardarEjecuArgIntegracion`, `SCA2_modificarArgumentoIntegracion` | Ya en uso |
| Catálogo | `SCA2 Cat Tipo Argumento` / `SCA2_catTiposArgAurora` | Ya en uso |
| Borrar pendientes (paso 3) | **No hay operación SOAP localizada** | A confirmar con el código BBE/CORE |

Con el mismo comportamiento que hoy (reglas en cada llamada) la versión Appian haría reglas + lectura + generación + lectura: **no ganaría tiempo**. La ganancia depende de la decisión del punto 6.1.

## 8. Lógica exacta del BBE (código `ES_SSCC_SCA_BINT`, subido a Appian el 23/11/2026) [Observado]

`GestionarArgumentosBLImp.consultarListadoArgumentos` + `GestionarArgumentosDLImp`:

```text
valida numSolicitud, nivel, infoUsuario
lista1 = SELECT A2139006 × D2139004 × A2139003            -- DL.consultarListadoArgumentos
         WHERE NUM_SOLICITUD_PCA=? AND COD_TIP_GESTION_PCA='2'
           AND (NIVEL=? OR (NIVEL<? AND MCA_EJEC_ARGUMENTO='S'))
           AND D2139004.MCA_INH='N'  ORDER BY nivel, num_orden
reglas = POST sca_servicios/api/1.0/compania/{cia}/poliza/{poliza}/argumento   -- siempre
         (numApli, canal, perfil/subperfil, línea, clave producción, catalogación, motivo, causa,
          nivel, fecAnul, detalle, codigoSCA, descSCA, ciaContraria, estadoUltimaGestion,
          anulaTecnico/Experto, nuuma, subgrupo, mecanizada, motivoContacto, modoAcceso)
DELETE A2139006 WHERE NUM_SOLICITUD_PCA=? AND COD_TIP_LINEA_NEGOCIO=? AND MCA_EJEC_ARGUMENTO<>'S'
descripción de cada recomendado = D2139004.NOM_TIPO_ARG
  + " N TREBOLES DISPONIBLES" | ". TREBOLES RECOMENDADOS: N"   (por codTrebol = codigo)
  + Vida (póliza < 11 dígitos, arg 356): nota 888071-888074 de apisbcpolizas_int-web/life
for cada recomendado no ejecutado ya en ese nivel (según lista1):
  INSERT A2139006 (solicitud, codGestion, cod, línea, tipEjec, estado '0', SYSDATE, orden=prioridad,
                   ciaContraria, numSpto, obligatorio, COD_USR=nuuma, centroEmisor, campaña,
                   bono, TXT_FINAL_DESC_ARG=descripción)
lista2 = SELECT (igual que lista1)
treboles = reglas.treboles;  insertarTrebolesBD(codTrebol, codigoSCA, trebolesBigData)
numArgEjecutados = count(lista2.MCA_EJEC_ARGUMENTO='S')
```

### Qué cubre Appian y qué no

| Paso | En Appian hoy | Hueco |
|---|---|---|
| Preparar request de reglas | Sí (`SCA2_scaServiciosReglas`) | — |
| Descripción + texto de tréboles + nota Vida 356 | Sí (catálogo Appian + regla; integración de póliza Vida a crear) | — |
| Lectura (`lista1`/`lista2`) | `SCAC_listarDetalleArgumentosCntrAnuIntegracion` | El SOAP filtra por gestión activa y valida perfil/préstamo; el SQL del BBE filtra por solicitud + nivel. Paridad a comprobar |
| `DELETE` de pendientes | **No** | Sin operación SOAP ni conexión a `TRON_LD` |
| `INSERT` con `TXT_FINAL_DESC_ARG` | Parcial (`SCAC_generarCntrAnuIntegracion`) | Hay que confirmar en CORE que `generarCntrAnu` borra los pendientes, respeta los ejecutados del nivel y graba `TXT_FINAL_DESC_ARG` |
| Tréboles BigData | **No** | Inserción directa en BD del BBE |

Conclusión: para sustituir el servicio con paridad exacta, Appian necesita **una vía de escritura en `A2139006`** que haga el `DELETE` + `INSERT` del BBE: o `generarCntrAnu` lo hace (confirmar en `ES_SSCC_SCA_CORE_CODE`), o el BBE expone dos operaciones pequeñas (`guardarArgumentario` = delete + insert, y tréboles BigData). Con eso Appian orquesta: lectura → (si toca) reglas → grabar → lectura.

## 9. ¿Puede CORE grabar el argumentario? (código `ES_SSCC_SCA_CORE_CODE`) [Observado]

`IContraAnularPCA.generarCntrAnu` → `ContraAnularCON.guardarArgContraAnul` → `ContraAnularEAO.guardarArgumentos`:

| Necesidad del BBE | CORE `generarCntrAnu` | Hueco |
|---|---|---|
| Borrar los pendientes (`MCA_EJEC_ARGUMENTO<>'S'`) | **No**. Hace upsert por PK (solicitud, gestión, tipo de argumento, línea): `persist` si no existe, `merge` si existe. Ningún EAO de CORE borra filas de `A2139006` | Los pendientes que reglas deje de recomendar se quedarían |
| No tocar los ejecutados del nivel | Hace `merge` también sobre los ejecutados (orden, obligatorio, `COD_USR`, obs, cía contraria…); el estado solo se pone al insertar | Appian tendría que filtrarlos antes, como hace el BBE |
| Grabar `TXT_FINAL_DESC_ARG` (descripción + tréboles) | **No**. El DTO no lo lleva y el EAO no lo escribe | Se perdería el texto de tréboles y de Vida 356 en BD |
| Gestión | Exige una gestión de contra anulación abierta (tipo 2) | Igual que el BBE en la práctica |

La lectura SOAP (`listarDetalleArgumentosCntrAnu` → `ContraAnularCON.consultarListadoArgumentos`) tampoco equivale al SQL del BBE:
- devuelve solo los argumentos ejecutados o con `COD_USR_EJECUCION` = nuuma del usuario (`filtrarArgumentosNuuma`), y el BBE inserta los pendientes con `COD_USR_EJECUCION` vacío, por lo que **los pendientes no saldrían**;
- filtra por fecha de vigencia del tipo, valida perfil (`isContraAnulCedida`), devuelve error si no hay argumentos del nivel y pasa a estado de nivel los negativos;
- la descripción sale del catálogo (`NOM_TIPO_ARG`), no de `TXT_FINAL_DESC_ARG`.

**Conclusión:** con CORE tal cual no se puede sustituir el servicio sin cambiar el comportamiento. La vía es que el BBE exponga la escritura («guardar argumentario»: borrar pendientes + insertar con `TXT_FINAL_DESC_ARG`, y los tréboles BigData) y una lectura igual a su SQL actual; Appian prepara la request, llama a reglas y compone las descripciones. La alternativa sería cambiar CORE (nueva operación de borrado y grabar `TXT_FINAL_DESC_ARG`), fuera del alcance de SCA2.

## 10. Propuesta: argumentos en Appian y una sola grabación al final [Observado + Inferido]

Propuesta de ggalv10: durante la contra anulación los argumentos, estados y cambios viven en Appian, y al finalizar se llama una vez a un servicio que graba el estado final.

**Es viable sin cambiar lo que ve el gestor**, con estas condiciones:

| Punto | Detalle |
|---|---|
| Reglas | Para no cambiar el comportamiento, Appian sigue llamando a reglas tras cada positivo/negativo y recalcula los pendientes en memoria. Se ahorran el `DELETE`/`INSERT`/2 lecturas SQL del BBE y el SOAP `guardarEjecucionArgumento` de cada clic; los ~3,4 s de reglas siguen (la decisión del punto 6.1 sigue aplicando) |
| Servicio de grabación | No existe: `generarCntrAnu` no graba estados y `guardarEjecucionArgumento` graba de uno en uno y exige que la fila exista. Hace falta una operación nueva del BBE: borrar pendientes + insertar/actualizar todas las filas de `A2139006` con estado, `MCA_EJEC_ARGUMENTO`, `MCA_FIN_POSITIVO`, `FEC_EJEC_ARGUMENTO`, `COD_USR_EJECUCION`, observaciones y `TXT_FINAL_DESC_ARG` |
| Cuándo grabar | No solo al finalizar: también al posponer, ilocalizable y cambio de nivel. `ContraAnularCON.finalizarContraAnulacion` copia en esos casos los argumentos de `A2139006` a monitorización (`insertarGestionMon` → `guardarArgumentosMon`, `A2139032`); hay que grabar **antes** de llamar a finalizar |
| Fechas y usuario | Guardar en Appian la fecha y el usuario de cada clic y enviarlos; hoy CORE pone la hora del momento |
| Validaciones | Replicar en Appian las de `guardarEjecucionArgumento`: estado válido, perfil con la contra anulación cedida, un positivo no se cambia |
| Datos en Appian | Tabla SCA2 nueva de argumentos (solicitud, gestión, nivel, tipo, estado, fechas, usuario, observaciones, descripción) |
| Fallo al grabar | El estado quedaría solo en Appian: reintento automático y aviso en el cuadro de mando (mismo patrón que el reintento de finalización) |

**Lo que sí cambia mientras la contra anulación está abierta:** quien lee `A2139006` fuera de SCA2 vería el estado de la última grabación, no el actual: la búsqueda por póliza del BBE (`GestionarAplicacionDLImpl.consultarContraAnulaciones`, que muestra los argumentos ejecutados positivo/negativo), el SCA antiguo y los informes/BigData que lean la tabla.
