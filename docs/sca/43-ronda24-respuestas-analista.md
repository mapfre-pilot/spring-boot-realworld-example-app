# Ronda 24 — Respuestas del analista a las 17 dudas (20/10/2026) y plan de aplicación

> Entrada: respuestas del analista a la tabla §1 de `42-estado-sca2-ronda23.md` (copia en `~/sca2work/r23/respuestas_analista_r24.txt`). Este documento clasifica cada respuesta, fija qué cambia en SCA2 y reparte el trabajo entre sesiones hijas para que no se pisen.

## 1. Clasificación

| # | Duda | Respuesta del analista | Clasificación | Qué se hace |
|---|---|---|---|---|
| 1 | Pantalla previa Verti/Vencimiento | Sin respuesta (sólo repite la pregunta) | **Abierta** | Sin cambio; SCA2 sigue mostrándola tras cada CA negativa |
| 2 | Estado tras ANULAR PÓLIZA (wAutemis no pendiente) | Sin respuesta | **Abierta** | Sin cambio |
| 3 | Espera a ANL | Esperar el ciclo completo (Central, NEW y SGO) y la respuesta de autorización/rechazo; si tras la respuesta hay errores, esperar 24 h y terminar con error | **Cambio** | `SCA2 CMD Mecanizar`: reanudar sólo con la fila ANL **concluida** (no con ESTADO); el plazo de 24 h cuenta desde la respuesta → R23-A |
| 4 | Usuario de la gestión de mecanización | CE_MF_BK es un perfil de SI24 | **Cerrada sin cambio** | Se retira D7 de r23-c |
| 5 | NSE: estado CORE de la mecanización | Pide póliza/solicitud para contexto | **Falta contexto → lo damos** | SCA 15788154 (pól. 2002400468198) «ANULACIÓN REALIZADA» (gestión 43706159) vs SCA2 15788155 (pól. 2002000157937) «PENDIENTE DE AUTORIZAR». R23-B añade la llamada exacta que fija cada estado |
| 6 | NSE: catalogación final CORE 1 vs 2 | El servicio devuelve 1..N catalogaciones; el usuario elige; validaciones posteriores (NSE a futuro / renovadas a futuro) pueden cambiarla internamente | **Falta contexto → lo damos** | Mismo par 15788154/15788155; R23-B documenta en qué paso SCA2 escribe 2 |
| 7 | NSE: paso RGPD | Pide contexto | **Falta contexto → lo damos** | SCA, tras ANULAR PÓLIZA en NSE Autos (15788154): pantalla «Este cliente no ha firmado…» (email/SMS o impresión/firma; exige certificar «RGPD FIRMADA»). Captura `A-SCA-RGPD-despues.png` de R23-B |
| 8 | Pólizas emitidas a futuro | Al detectar la excepción de NSE a futuro, repetir la consulta de póliza con fecha de consulta +1 año; después la catalogación la decide el servicio | **Cambio** | Alta de SCA2: reintento +1 año; caso exacto: SCA2 pól. 2002600059907 / 2002600060945, SCA 15788158 pól. 0732600004759 → R23-B |
| 9 | Retorno al formulario tras el alta | Quieren entender qué supone y una navegación simulada | **Entregable** | Documento con la navegación simulada (pantalla a pantalla) antes de implementar → padre |
| 10 | RETOMAR en AA y nivel 2 | Cualquier usuario del grupo | **Cerrada sin cambio** (SCA2 ya lo hace) | Se retira Q2 de r23-c |
| 11 | Impresión de carta en nivel 2 | Una única carta por solicitud; el detalle de la gestión de impresión debe mostrar fecha y quién imprimió | **Cerrada + cambio pequeño** | Detalle: mostrar fecha/usuario de la impresión en la gestión → R23-C |
| 12 | Nuuma al RETOMAR | Lanzar al RETOMAR la misma llamada CORE que al posponer | **Cambio** | RETOMAR → llamada CORE de posponer con el nuuma que retoma → R23-C |
| 13 | Casilla vencimiento SGC | Fuera de alcance: lo hace Suscripción Inteligente (doc aparte) | **Cerrada sin cambio** | Pendiente de recibir el documento de la integración |
| 14 | Batch NSE | Sí, pero desactivado | **Cambio (nuevo)** | Implementar `SCA2 Batch Mecanizacion NSE` según `29 §3`, constante `SCA2_BOOL_BATCH_NSE = false` → sesión nueva R24-D |
| 15 | Origen FDC / Decisora | Entrada desde Decisora con parámetros en URL como SCA; pasarán llamadas de ejemplo (doc aparte) | **Cambio (espera doc)** | Se implementa cuando lleguen los ejemplos |
| 16 | Documentos afectados Documentum | No re-subir; validar que se subió al SGD y mostrar error en pantalla para reintentar | **Cambio** | Tras subir: comprobar referencia SGD; si falta, error visible y reintento → R24-D |
| 17 | 15788025 desincronizada | Debe quedar en la traza de errores y resolverse manualmente desde ahí | **Cambio de criterio** | Registrar el caso en `SCA2 Error` y resolverlo desde la bandeja; regla general: toda desincronización CORE↔SCA2 va a la bandeja → R24-D |

## 2. Reparto y coordinación (sesiones hijas R23 retomadas)

| Sesión | Objetos que toca | Trabajo |
|---|---|---|
| R23-A (reanudada) | `SCA2 CMD Mecanizar` (espera ANL), página de mantenimiento | #3 + AUTORIZAR/RECHAZAR/CANCELAR con 15788161/66/68; informe `pruebas/r23-a-autemis-anl.md` |
| R23-B (reanudada) | `SCA2_AltaSolicitudPage` (v37) y reglas de consulta de póliza | #8 + contexto exacto de #5/#6/#7 en `pruebas/r23-b-nse.md` |
| R23-C (reanudada) | `SCA2_DetalleSolicitud`, RETOMAR, gestión de impresión | #11 + #12; retira D7/Q2; informe `pruebas/r23-c-nivel2-verti.md` |
| R24-D (nueva) | Batch NSE, `SCA2_subirDocumentosGD`, bandeja `SCA2 Error` | #14, #16, #17 |
| Padre | documentación | #9 navegación simulada; consolidación; `36-funcional-sca2.md` |

Reglas comunes: releer el objeto vivo antes de tocarlo (otras hijas también escriben), un objeto por hija salvo acuerdo, datos nuevos, no tocar solicitudes protegidas (15787909/759/911/917/8025) ni SCA/SCAC/CORE/ANL, `git pull --rebase` antes de cada push a `feature/sca`.

## 3. Sigue pendiente del analista
- #1 y #2 (sin respuesta).
- Documento de la integración con Suscripción Inteligente (#13) y ejemplos de llamadas externas a la Decisora (#15).
- Confirmar #5/#6/#7 con el contexto de la tabla.
