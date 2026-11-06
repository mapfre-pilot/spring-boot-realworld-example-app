# Ronda 12 — Respuestas del analista (15/10/2026) y cambios aplicados en SCA2

Sesión padre: https://mapfre.devinenterprise.com/sessions/6f3b571d45154ca8bddc009fb360ba0c · Pruebas: `pruebas/r12-pruebas.md` · Preguntas de origen: `28-consolidado-ronda10.md` §6 y `pruebas/r10-padre-hu3980-nse-documentos.md`.

## 1. Clasificación de las 13 respuestas

| # | Tema | Respuesta del analista | Situación en SCA2 | Acción |
|---|---|---|---|---|
| 1 | Plan de pagos (aviso/bloqueo al autorizar) | «De momento como hace SCA» | Igual que SCA: sólo identificador y detalle del plan, sin aviso ni bloqueo | Ninguna (confirmado) |
| 2 | Documento de venta sin traspaso (tipo 9) no llega a CORE | «Como SCA» | Misma regla de documentos que SCA; CORE rechaza el tipo 9 | Ninguna (confirmado); se cierra DOC-1 |
| 3 | Aviso «se anulará al vencimiento» con contrato con traspaso | «Correcto, como SCA» | Igual que SCA | Ninguna |
| 4 | Autorización NSE que no llega a CORE (15787945) | Servicio externo a SCA; mientras tanto mecanización incompleta y el servicio externo cambiará el estado | Detalle muestra «Mecanización Incompleta» | Ninguna en el Detalle; el listado cambia por la respuesta 11 |
| 5 | Etiqueta de rechazo NSE | «El texto nuevo es el deseado» («Solicitud Finalizada. Rechazada anulación») | Ya aplicado (R10, HU3980) | Ninguna |
| 6 | Pregunta «¿insiste…?» en el alta telemática/telefónica | No se pregunta más (excepto CCC/CCR, a los que se manda `true` al motor por defecto) | El alta nunca preguntaba | Ninguna en el alta |
| 7 | Pregunta «¿insiste…?» al finalizar la CA (SI24, CCC/CCR) | Idem #6 | Pregunta eliminada en R11; para CCC/CCR el valor que llegaba al motor era el de la marca del productor, no `true` | **Aplicado** (§2.2) |
| 8 | Mensaje «la póliza ya tiene una solicitud abierta» | «Lo que indica SCA2» | Texto largo de SCA2 | Ninguna |
| 9 | Póliza telemática gestionada por Oficina → CA nivel 1 | «Lo que haga SCA, no cambiar condiciones» | Misma condición que SCA | Ninguna |
| 10 | Pólizas vencidas/anuladas: aviso sólo al guardar | «Correcto; puede irse a contra anular» | Igual que SCA | Ninguna |
| 11 | HU3980-1: CORE finalizada (4/5) + mecanización INCOMPLETA por NSE | «Como Pendiente de Autorización» | Mostraba «Solicitud Pendiente» | **Aplicado** (§2.1) |
| 12 | HU3980-2: ¿se actualiza SCA TEST con las etiquetas nuevas? | «Se debería de hacer sí» | SCA TEST sigue con textos antiguos | Fuera de alcance (no tocamos SCA); queda como dependencia externa para comparar el buscador |
| 13 | DOC-1: documentos de AA por venta que llegan a CORE/SGD | «Lo que haga SCA» | Igual que SCA (sólo DNI y tipo 1) | Ninguna |

## 2. Cambios aplicados en Appian TEST (API LCP; backups, payloads y relecturas en `sca2work/r16/`)

### 2.1 Listado por NUUMA: «Pendiente de Autorización» para CORE finalizada + mecanización INCOMPLETA
- Objeto: `SCA2_calcularEstadoSolicitud` (regla, `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052795`) **v2 → v3**.
- Cambio: antes de la rama «Solicitud Pendiente» se añade  
  `if(and(local!finalCore, local!estadoMecanizacion = "INCOMPLETA"), "Pendiente de Autorización", …)`  
  y se quita `local!estadoMecanizacion = "INCOMPLETA"` de la condición de «Solicitud Pendiente» (que sigue aplicando a gestión pospuesta o última acción 8 sin mecanización).
- Color: `SCA2_colorEstadoSolicitud` ya mapeaba «Pendiente de Autorización» → naranja `#E46B15`; sin cambios.
- Efecto comprobado por LCP (gestiones reales de CORE): 15787945 (CORE 5; gestiones 8 FINALIZADA, 3 FINALIZADA, 5 INCOMPLETA) → «Pendiente de Autorización»; 15787950 → «Solicitud Finalizada. Rechazada anulación»; 15788000 → «Finalizado Contra Anulación Positiva»; 15787909/15787911/15788009 (CORE 2) → «Solicitud Pendiente».
- Nota: la misma regla alcanza a **15788014** (CORE la cerró como «FINALIZADA NO REQUERIDA CONTRAANULACIÓN» con gestión 5 INCOMPLETA, caso CORR-7 de la ronda 10): pasa de «Solicitud Pendiente» a «Pendiente de Autorización». Es consecuencia literal de la respuesta 11; si el analista quiere distinguir ese caso haría falta otra fuente (CORE no informa el estado 2 de mecanización).

### 2.2 CCC/CCR: `anulaTecnicos = true` al motor por defecto, sin pregunta
- `SCA2_ContraAnulacionOpciones` (interfaz, `…_20056435`) **v49 → v50**: nuevas locales  
  `local!esCCC: or(local!codPerfil = "CE_MF_RECIBOS", codSubPerfil = "CE_MF_RECIBOS_CCC", codSubPerfil = "CE_MF_RECIBOS_CCR")`  
  `local!anulaTecnicosMotor: if(local!esCCC, true, local!anulaTecnicos)`  
  y se usa `anulaTecnicosMotor` en los tres sitios donde el resultado/los datos del modal llevaban `anulaTecnicos` (resultado al FINALIZAR, datos del modal Sí/No y resultado del caso «fecha de periodo anterior»). Para el resto de perfiles sigue valiendo la marca `anulatecnicos` del productor (igual que SCA).
- `SCA2_ContraAnulacionModalSiNo` (interfaz, `…_20052807`) **v4 → v5**: en los dos casos que grababan `anulaTecnicos: if(local!esCCC, index(local!datosProductor, "anulaTecnicos"), null)` ahora `if(local!esCCC, true, null)`. Las preguntas «¿insiste…?» (casos 4/5/6) siguen desactivadas desde R11.
- Camino hasta el motor (sin cambios, verificado en `SCA2 CMD CompletarAccion` nodo «Write Decidir»): `pv!resultado.anulaTecnicos` → `SCA2 Datos Solicitud.mcaanulatecnico` → `SCA2_mapearDatosDecidirAccion[Estrategicas]` → motor.
- Comprobación LCP de la lógica: CE_RM → `false` (productor), CE_MF_RECIBOS → `true`, subperfil CCC → `true`, subperfil CCR → `true`, CE_RM con productor `true` → `true`.
- **No probado end-to-end con CCC/CCR**: no hay usuario de ese perfil en TEST. Regresión con JJGONZ2 (CA negativa nueva 15788025) correcta y `mcaanulatecnico = "false"` grabado.

## 3. Pendientes y preguntas que siguen abiertas
1. **HU3980-2**: actualizar SCA TEST con las etiquetas nuevas (dependencia externa; el analista dice que debería hacerse). Mientras, en el buscador SCA muestra «Finalizada no requerida contraanulación» donde SCA2 muestra «Pendiente de Autorización» (15787945).
2. **Usuario CCC/CCR en TEST** para probar en pantalla que el motor recibe `true` y decide como se espera.
3. Caso 15788014 (ver §2.1 nota): ¿debe verse también como «Pendiente de Autorización» aunque CORE la cerrara «no requerida»?
4. Incidencia observada en la prueba (no es de esta ronda): al dar de alta 15788025 (póliza 0000253500305) la pantalla volvió al formulario sin mostrar el número, aunque la solicitud se creó una sola vez (10:10:56) y se gestionó después con normalidad. Mismo síntoma que R10-A pero `SCA2_construirContextoAlta` v11 ya está aplicado; pendiente de reproducir con otra póliza para ver si es latencia del proceso de alta o un error silenciado.
5. Siguen pendientes de rondas anteriores: batch NSE propio (`29` §3), `anulaExperto = true` end-to-end con póliza de acuerdos, relanzamiento Documentum real, bandeja de errores (quién la ve), texto del error al cancelar autorización, y la finalización de 15787909/15787759/15787911/15787917 (sin OK del usuario).

## 4. Tabla de objetos modificados en esta ronda
| Objeto | UUID | Antes | Después |
|---|---|---|---|
| SCA2_calcularEstadoSolicitud | _a-0000f069-4f37-8000-9cc8-011c48011c48_20052795 | v2 | v3 |
| SCA2_ContraAnulacionOpciones | _a-0000f069-4f37-8000-9cc8-011c48011c48_20056435 | v49 | v50 |
| SCA2_ContraAnulacionModalSiNo | _a-0000f069-4f37-8000-9cc8-011c48011c48_20052807 | v4 | v5 |
Reserva: los tres objetos los tocó sólo la sesión padre (no había sesiones hijas activas). Relectura tras cada PUT idéntica al payload enviado.
