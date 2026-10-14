# Ronda 11 — respuestas del analista aplicadas a SCA2 (TEST)

Fuente: respuestas del analista a las 23 dudas del consolidado de la ronda 9/10 (recibidas 07/10/2026). Entorno: Appian TEST
(`mapfrespain-test`), SCA2 comparada con SCA/CORE. Backups, payloads y relecturas de cada objeto en `/home/ubuntu/sca2work/r15`
(fuera del repo). Procedimiento por objeto: GET vivo → backup → PUT completo → relectura idéntica → prueba.

## 1. Clasificación de las 23 respuestas

| # | Respuesta del analista (resumen) | Estado en SCA2 | Acción ronda 11 |
|---|---|---|---|
| 1 | El texto «Esta solicitud la está gestionando SI24» se mantiene | Ya implementado (R9-B) | Nada |
| 2 | SI24 sólo consulta en tareas de nivel 1 (CA, AA, Autorización) | Ya implementado (R9-B, `SCA2_puedeGestionarTarea`) | Verificado por código; sin cambios |
| 3 | SI24 no puede retomar una tarea asignada a otro gestor | Ya implementado (R9-B) | Nada |
| 4 | Motivo → detalle → causa es jerárquico: no mostrar elementos sin hijos | **Faltaba** (sólo se filtraban las causas) | **Hecho**: `SCA2_AltaSolicitudPage` v30 (§2.1) |
| 5 | La oficina se conserva por tarea; al retomar otro NUUMA ve sus oficinas | Ya implementado (R9 consolidado: oficina al POSPONER/RETOMAR; oficinas del NUUMA que retoma, H3) | Nada |
| 6 | La lista de acuerdos sólo avisa; el motor decide la derivación | Ya así desde R9-C (aviso informativo, sin bloquear) | Nada |
| 7 | El aviso de acuerdos actual es correcto | — | Nada |
| 8 | Se elimina la pregunta «¿El cliente insiste en anular…?» | **Faltaba** (se mostraba a CCC/CCR) | **Hecho**: `SCA2_ContraAnulacionModalSiNo` v4 (§2.2) |
| 9 | SI24 + póliza de acuerdos → al motor `anulaExperto = true` | **Faltaba** (la marca nunca llegaba al motor) | **Hecho**: `SCA2_ContraAnulacionOpciones` v49 + `SCA2 CMD CompletarAccion` (§2.3) |
| 10 | Situación ANL sin respuesta: necesitan más contexto | — | Contexto en §4.1 |
| 11 | Guardar y reutilizar la referencia de Documentum al relanzar | **Faltaba** (relanzar duplicaba el documento en el SGD) | **Hecho**: `SCA2_subirDocumentosGD` v7 + `SCA2 CMD CompletarAccion` (§2.4) |
| 12 | SCA2 debería tener su propio batch NSE | No existe | Diseño en §3; implementación pendiente de decisión (no se puede crear un proceso nuevo desde la API de TEST) |
| 13 | Proponer el texto del error al cancelar una autorización | Hoy muestra el fault de CORE | Propuesta en §4.2 |
| 14 | No finalizar solicitudes antiguas sin confirmación expresa | — | Siguen sin tocar: 15787909, 15787759, 15787911, 15787917 |
| 15 | Filtros de estado/línea sobre solicitudes históricas: abierto | — | Sin cambios; queda abierto |
| 16 | El teléfono del DUE es el del tomador | Ya implementado (R9-E) | Nada |
| 17 | DUE validado en el buzón de jospena | — | Nada |
| 18 | RCI negativa en nivel 1 deriva a SI24/BK Expertos y genera DUE en nivel 2 | Ya implementado (motor + DUE, R9-E/R10-B) | Nada |
| 19 | «Ilocalizable a la tercera gestión» = cerrar como ilocalizable | Ya implementado (modal FINALIZAR caso 3 «ILOCALIZABLES», R10-B) | Nada |
| 20 | Observaciones «-» en filas sólo CORE: aceptable | — | Nada |
| 21 | Verti depende de PRE (token 1101): pendiente de sistemas | — | Nada |
| 22 | No hay pólizas para M201/M206 ni FDC | — | Nada |
| 23 | Vida/Más Móvil: no concluir fallo con datos no funcionales | — | Nada |

## 2. Cambios aplicados en SCA2

### 2.1 Cascada motivo → detalle → causa (#4) — `SCA2_AltaSolicitudPage` v29 → v30
Hasta ahora el alta pedía a CORE los motivos y detalles tal cual y sólo filtraba las causas que SI24 no puede usar
(`SCA2_consultarCausa` v2: 13, 14, 16, 17, 18, 28, 31, 32). Un gestor SI24 podía elegir un detalle que después no ofrecía ninguna causa.

Ahora, **sólo para perfiles SI24** (los únicos con causas ocultas), el alta calcula qué detalles tienen alguna causa visible y qué
motivos tienen algún detalle con causas, y oculta el resto. Para Red Mapfre y el resto de perfiles las listas siguen siendo las de
CORE, como en SCA.

Evidencia (LCP, mismas reglas que usa la pantalla; `r15/cascada_ln1.json`, `r15/cascada_ln2.json`), formato detalle → nº causas SI24 / nº causas Red Mapfre:

| Línea | Motivo | Detalles (SI24 / RM) | Efecto para SI24 |
|---|---|---|---|
| Autos (1) | 1 | 9 (2/2), 6 (1/1), 4 (3/3), 1 (3/3), 2 (3/3), 3 (3/3), **5 (0/2)** | se oculta el detalle 5 |
| Autos (1) | 2 | **7 (0/3)** | se oculta el motivo 2 |
| Autos (1) | 3 | 8 (0/0) | se oculta el motivo 3 |
| Autos (1) | 4 | **9 (0/3)** | se oculta el motivo 4 |
| Hogar (2) | 1 | 9 (2/2), 6 (1/1), 4, 1, 2, 3 (3/3), **10 (0/2)** | se oculta el detalle 10 |
| Hogar (2) | 3 | 8 (0/0) | se oculta el motivo 3 |
| Hogar (2) | 4 | **9 (0/3)** | se oculta el motivo 4 |

Pregunta derivada (§5): el motivo 3 / detalle 8 no tiene causas en CORE para **ningún** perfil, también en SCA; ¿se oculta para todos?

### 2.2 Pregunta «¿El cliente insiste…?» eliminada (#8) — `SCA2_ContraAnulacionModalSiNo` v3 → v4
Los tres casos del modal que hacían la pregunta (casos 4, 5 y 6, sólo para CCC/CCR) quedan desactivados; FINALIZAR sigue la cadena
normal (corredor, ilocalizable, canal, telemática, acuerdo). Las marcas `anulaExpertos`/`anulaTecnicos` que el modal devuelve ya no
dependen del perfil CCC.

### 2.3 `anulaExperto = true` para SI24 + acuerdo (#9) — `SCA2_ContraAnulacionOpciones` v48 → v49 y `SCA2 CMD CompletarAccion`
Hallazgo: en SCA2 la marca que calculaba la pantalla **nunca llegaba al motor**. El motor (`SCA2 CMD Decidir` →
`SCA2_mapearDatosDecidirAccion[Estrategicas]`) lee `mcaanulaexperto`/`mcaanulatecnico` del record `SCA2 Datos Solicitud`, que el alta
graba siempre a `"false"`, y el comando CompletarAccion ignoraba `resultado.anulaExpertos`. SCA lee la misma marca de su tabla de datos
de solicitud, que su proceso de Contra Anulación sí actualiza.

Cambios:
- Pantalla: `anulaTecnicos`/`anulaExpertos` toman la marca del productor para cualquier perfil (antes sólo CCC/CCR); nueva
  `anulaExpertosMotor = true` si el gestor es SI24 (`SCA2_datosPerfilesPcaSi24`) **y** la póliza es de acuerdos (`isAcuerdoSi24`,
  misma lista de R9-C); si no, la marca del productor. Es la que va en el resultado POSITIVO y en el modal de FINALIZAR.
- `SCA2 CMD CompletarAccion`, nodo «Write Decidir»: además de la transición, actualiza `SCA2 Datos Solicitud.mcaanulaexperto/mcaanulatecnico`
  con lo que trae `resultado` (sólo si viene informado), de forma que el motor lo lea en la decisión siguiente.
- El aviso de acuerdos se mantiene como está (#6, #7).

### 2.4 Referencia de Documentum reutilizada al relanzar (#11) — `SCA2_subirDocumentosGD` v6 → v7 y `SCA2 CMD CompletarAccion`
- Cuando la subida al SGD funciona pero falla el registro en BBDD CORE, el comando captura el error (`DOC_GD_FAIL`) y ahora, antes de
  grabarlo en la bandeja, reescribe `resultado.listaNombreDocs` con un tercer tramo `idDoc_tipo_<referenciaSGD>` para cada documento
  que ya tiene referencia.
- Al relanzar desde la bandeja (`payload.resultado`), la regla detecta la referencia previa, **no vuelve a subir el fichero** al SGD
  (`reutilizado: true`) y sólo repite el registro en CORE. Sin referencia previa el comportamiento es el de antes (3 intentos).
- No se ha añadido ningún campo a los records: la referencia viaja en el payload del error, que es lo que consume el relanzamiento.

## 3. Batch NSE propio de SCA2 (#12) — diseño propuesto
Referencia: `SCA Batch Mecanizacion NSE` (proceso 0002ecf2-fb2e-8000-6f80-7f0000014e7a, activado por `SCA_BOOL_BATCH_NSE`). Qué hace hoy, en CORE/ANL compartidos con SCA2:
1. Consulta a CORE las solicitudes en estado 4 y 5 con mecanización en estado 2 (500 por llamada, 3 reintentos), une ambas listas.
2. Descarta las wAutemis; separa pólizas **vigentes** (`SCA_polizaVigente = "V"`) y **anuladas** (`"A"`).
3. Para cada una lee cabecera y detalle de la solicitud en CORE y: vigente → mecanización a estado 4 + autorización **rechazada**;
   anulada → mecanización a estado 4 + autorización **aceptada**.
4. Localiza la instancia de ANL (`SCA_obtenerAnulacion`), la finaliza (subproceso «Finalizar instancia de mecanizacion»), llama a
   `finalizarSolicitud` en CORE e inserta las observaciones post-anulación (`ANL_mapObservaciones_PostAnulacionNSE`).

Efecto sobre SCA2 mientras convivan: como actúa sobre CORE y ANL, **ya cierra también las solicitudes creadas en SCA2**, pero deja el
record `SCA2 Solicitud` en `MECANIZADA / procesoActivo = ANL` (SCA2 lo corta a las 24 h con `ANL_TIMEOUT`, §4.1).

Propuesta para SCA2 (`SCA2 Batch Mecanizacion NSE`, nocturno, activable por constante `SCA2_BOOL_BATCH_NSE`):
- Origen de datos: solicitudes del record `SCA2 Solicitud` con `estado = MECANIZADA`, `procesoActivo = ANL` y origen NSE (no wAutemis),
  en vez de barrer CORE: así sólo toca las suyas y no compite con el batch de SCA.
- Por solicitud: `SCA2_polizaVigente` (misma consulta) → vigente: mecanización 4 + autorización rechazada; anulada: mecanización 4 +
  autorización aceptada + `finalizarSolicitud` CORE + observaciones post-anulación; en ambos casos cerrar la instancia ANL propia y
  pasar el record a `FINALIZADA` (o a la tarea de nivel 2 si procede) con `SCA2 Transicion` idempotente, como el resto de comandos.
- Errores a la bandeja `SCA2 Error` (comando `SCA2 CMD BatchNSE`) relanzables.
- Decisión necesaria del analista: mientras SCA siga en TEST/PRO con su batch activo, ¿se ejecutan los dos (el de SCA2 encontraría las
  suyas ya cerradas en CORE y sólo sincronizaría el record) o se excluyen del batch de SCA las solicitudes de origen SCA2?
- Limitación: la API de diseño de TEST no permite crear modelos de proceso nuevos (sólo leer/modificar los existentes), así que el
  proceso hay que crearlo en el diseñador; las reglas y la constante sí se pueden crear desde aquí cuando se confirme el diseño.

## 4. Contexto y propuestas pedidas

### 4.1 Situación ANL sin respuesta (#10)
Cuando ANL no contesta a una mecanización, SCA espera indefinidamente (la gestión 5 queda INCOMPLETA en CORE, nadie recibe aviso y el
gestor no puede retomar). SCA2 corta la espera a las 24 h y deja el error `ANL_TIMEOUT` en la bandeja de errores, relanzable. La pregunta
es si ese corte y su plazo son correctos, y si además debe avisarse a alguien (p. ej. correo al gestor o a SI24).

### 4.2 Texto propuesto para el error al cancelar una autorización (#13)
Hoy SCA2 muestra el fault técnico de CORE. Propuesta (pendiente de validación):
> «No se ha podido cancelar la autorización. La solicitud se mantiene pendiente de autorización; inténtelo de nuevo en unos minutos y,
> si el problema persiste, contacte con soporte indicando el número de solicitud.»

## 5. Preguntas nuevas para el analista
1. Cascada (#4): el motivo 3 / detalle 8 no tiene causas en CORE para ningún perfil (tampoco en SCA). ¿Se oculta a todos los perfiles o es un dato a corregir en CORE?
2. Batch NSE (#12): convivencia con el batch de SCA (§3).
3. ANL (#10): plazo del corte (24 h) y aviso (§4.1).
4. Texto de cancelación de autorización (#13): validar §4.2.

## 6. Pruebas
Ver `docs/sca/pruebas/r11-pruebas.md` (se completa con los recorridos UI de esta ronda).

## 7. Objetos Appian modificados (TEST)

| Objeto | Tipo | Versión | Cambio |
|---|---|---|---|
| SCA2_AltaSolicitudPage | Interfaz | v29 → v30 | Cascada motivo/detalle/causa para SI24 |
| SCA2_ContraAnulacionModalSiNo | Interfaz | v3 → v4 | Sin pregunta «¿insiste?»; marcas sin dependencia de CCC |
| SCA2_ContraAnulacionOpciones | Interfaz | v48 → v49 | Marcas del productor para todos; `anulaExpertosMotor` (SI24 + acuerdo) |
| SCA2_subirDocumentosGD | Regla | v6 → v7 | Reutiliza referencia SGD previa (`idDoc_tipo_ref`) |
| SCA2 CMD CompletarAccion | Proceso | nueva versión | Write Decidir graba marcas en Datos Solicitud; captura de error de documentos guarda referencias |
