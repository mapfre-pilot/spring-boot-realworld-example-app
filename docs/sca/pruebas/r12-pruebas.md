# Ronda 12 — Pruebas (15/10/2026)

Cambios probados: `33-respuestas-analista-ronda12.md` §2. Usuario de pantalla: JJGONZ2 (Oficina / Red Mapfre). SCA2 `sites/sca2`, SCA `sites/sca-site`.

## 1. Pruebas LCP (regla viva, datos reales de CORE)
| Solicitud | Estado CORE | Gestiones (acción:estado) | Etiqueta SCA2 (v3) | Esperado |
|---|---|---|---|---|
| 15787945 | 5 | 8:FINALIZADA, 3:FINALIZADA, 5:INCOMPLETA | Pendiente de Autorización | Pendiente de Autorización (resp. 11) ✔ |
| 15787950 | 5 | …, 5:INCOMPLETA, 7:AUTORIZACION RECHAZADA | Solicitud Finalizada. Rechazada anulación | sin cambio ✔ |
| 15788000 | 3 | 8:FINALIZADA, 2:FINALIZADA POSITIVA | Finalizado Contra Anulación Positiva | sin cambio ✔ |
| 15788014 | 5 | 8, 2:INCOMPLETA, 4:FINALIZADA, 5:INCOMPLETA | Pendiente de Autorización | antes «Solicitud Pendiente» (ver nota doc 33 §2.1) |
| 15787909 | 2 | 8:FINALIZADA, 7:FINALIZADA CANCELADA | Solicitud Pendiente | sin cambio ✔ |
| 15787911 | 2 | 8:FINALIZADA, 2:INCOMPLETA | Solicitud Pendiente | sin cambio ✔ |
| 15788009 | 2 | 8, 2:FINALIZADA NEGATIVA, 4:FINALIZADA, 5:INCOMPLETA | Solicitud Pendiente | sin cambio ✔ |

Lógica CCC/CCR (`esCCC` / `anulaTecnicosMotor`): CE_RM→false · CE_MF_RECIBOS→true · sub CE_MF_RECIBOS_CCR→true · sub CE_MF_RECIBOS_CCC→true · CE_RM con productor true→true ✔.

## 2. Pruebas en pantalla (testing agent, grabación `sca2-r12-estados-ca-negativa`)
| Caso | SCA2 | SCA | Resultado |
|---|---|---|---|
| Buscador: 15787945 | «Pendiente de Autorización», naranja | «Finalizada no requerida contraanulación», rojo (textos antiguos de SCA TEST) | OK SCA2; diferencia esperada (HU3980-2) |
| Detalle 15787945, tarjeta Mecanización | «Incompleta» naranja, resultado «MECANIZACIÓN INCOMPLETA» | — | OK (resp. 4: sin cambio en el Detalle) |
| Buscador: 15787950 | «Solicitud Finalizada. Rechazada anulación», rojo | — | OK regresión |
| Buscador: 15788000 | «Finalizado Contra Anulación Positiva», verde | — | OK regresión |
| Alta nueva 0000253500305 → **15788025** | Solicitud creada una sola vez (10:10:56); la pantalla volvió al formulario sin mostrar el número | — | Incidencia a investigar (doc 33 §3.4) |
| CA 15788025: INCREMENTO PRIMA → Negativo, oficina MADRID CORREDORES NORTE II, impresión plantilla, FINALIZAR | Modal «Se van a finalizar las acciones de contra anulación. ¿Desea continuar?» → SI → CORRECTO → «Se va a redirigir a la anulación» → Mecanización. Sin pregunta «¿insiste…?» ni errores | — | OK regresión Opciones v50 / Modal v5 |
| Detalle 15788025 | Contra Anulación «Finalizada Negativa», Mecanización «Incompleta»; buscador «Solicitud Pendiente» | — | OK |
| Datos Solicitud 15788025 (LCP) | `mcaanulatecnico="false"`, `mcaanulaexperto="false"`, canal 1, origen SCA2 | — | OK (JJGONZ2 no es CCC: valor del productor) |

No probado: perfil CCC/CCR (no existe usuario en TEST). No se tocaron 15787909/15787759/15787911/15787917. 15788025 queda en MECANIZAR sin anular la póliza.
