# Ronda 9 — respuestas del analista: clasificación y plan de trabajo

Fuente: `24-respuestas-analista-ronda9.md` (respuestas al doc 22/23), `PolizasPruebaPRE.xlsx` (reparto en `pruebas/polizas-ronda9.md`) y mensaje del usuario (2026-10-07): «para Verti sirve cualquier póliza, las reglas están trampeadas en PRE».

Regla general: SCA TEST es la referencia. Si SCA2 diverge por causa propia se corrige SCA2; si depende de CORE/ANL/Emisión/Documentum o de una decisión funcional pendiente, se documenta.

## 1. Clasificación de cada respuesta

| Ref | Respuesta del analista | Estado en SCA2 | Acción | Paquete |
|---|---|---|---|---|
| A1 | La simulación es obligatoria y da la fecha de anulación válida; sospecha que SCA2 llama a la simulación NSE en vez de a la de wAutemis | `SCA2_simularAnulacion*` son copia exacta de `SCA_simularAnulacion*` (SCA también usa `srGestionarAnulacionesPolizasWs` para ambos tipos; para wAutemis añade `consultarNewAlta`). El fallo real es el **403 de la integración de simulación para el usuario final** (ronda 7) que llevó a quitar la llamada de la interfaz | Restaurar la simulación en el alta como SCA (misma regla y momento), resolver el 403 (seguridad de `SCA2_simularAnulacionPolizaIntegracion`/sistema conectado) y probar con pólizas nuevas | R9-A |
| A2 | — | | | |
| A3 | PRRA puede resolverse por el sistema después de guardar | PRRA no se simula (403) | Ejecutar simulación/PRRA desde el proceso tras el alta si no puede hacerse desde la interfaz | R9-A |
| A4 | El destino CA/AA lo decide siempre el servicio de decisión | Ya así | Confirmar en pruebas | R9-A |
| A5 | Servicio de pólizas caído → bloquear como SCA | Comprobar | Verificar comportamiento con error del servicio (no se puede provocar; revisar código frente a SCA) | R9-A |
| A6 | Aviso de solicitud en la misma anualidad sigue vigente (`flagActivoPMO`) | Implementado en ronda anterior (`SCA2_tieneSolicMismaAnualidad`) | Probar con póliza que tenga solicitud previa en la anualidad | R9-A |
| A7 | Vida pasa por el mismo flujo; motor decide | — | Probar altas Vida en SCA vs SCA2 | R9-A |
| B1 | Oficina debe conservarse al retomar (y en otras tareas) | Sin campo donde guardarla | Buscar sitio (campo existente de `SCA2 Datos Solicitud`/`SCA2 Tarea`/`SCA2 Transición`; si hace falta columna nueva, pedirla) e implementar | R9-B |
| B2/B6/B7-motor | El motor decide grupo/subgrupo y tiene precedencia sobre el perfil | Ya así desde ronda 7 | Confirmar que SCA2 nunca sustituye el grupo del motor | R9-B |
| B3 | Administradores pueden retomar tareas de otros | Comprobar `SCA2_puedeGestionarTarea` | Probar con usuario admin | R9-B |
| B4 | Nunca dos tareas abiertas a la vez en una solicitud | Comprobar | Verificar que SCA2 no crea una segunda tarea mientras hay una pendiente (CA2 + Autorización, AA + Mecanización) | R9-B |
| B5 | Con CORE finalizada no se muestran RETOMAR/REASIGNAR | Implementado en ronda 6 | Confirmar en todos los tipos de tarjeta | R9-B |
| Decisión 2 | AA de nivel 1 pospuesta: SI24 solo consulta | SCA2 muestra RETOMAR a SISANS | **Corregir**: ocultar RETOMAR/REASIGNAR a SI24 en AA nivel 1 pospuesta | R9-B |
| B7-SI24 | Red Mapfre no recupera una tarea de nivel 2 que el motor envió a SI24; en Detalle, mensaje «gestionada por SI24»; no enviar gestión al CUE | Comprobar RETOMAR para CE_RM sobre tarea de grupo SI24 | Implementar ocultación + mensaje informativo (texto provisional, pendiente del analista) | R9-B |
| B7-causas | SI24 no ejecuta causas AA 13, 14, 31, 32, 16, 17, 18, 28 | SCA2 las ofrece | **Implementar**: ocultarlas al perfil SI24 en AA (comprobar en SCA si ya existe algo equivalente) | R9-C |
| B7-insiste | «¿Insiste en anular técnico?» desaparece salvo perfiles CCC; solo se envía valor a reglas para CCC | `SCA2_ContraAnulacionModalSiNo` casos 4/5/6 para GGE/SI24 como SCA | **Implementar** en SCA2 (SCA aún no lo tiene) y documentar la diferencia deliberada con SCA | R9-C |
| B7-acuerdos | Póliza de acuerdos en nivel 1 que debe tratar SI24: Red Mapfre ve mensaje informativo y no anula | No existe | Implementar con texto provisional marcado como pendiente | R9-C |
| C1 | 00000005/00000006 son wAutemis; NSE tiene su propio patrón en SCA (`txtObservaciones: 00000005`, hito «Suscripción») | SCA2 solo contempla el patrón wAutemis | **Implementar** patrón NSE como `SCA_DetalleAnulacionMecanizacion`/`SCA Mecanizacion` | R9-D |
| C2 | La tarjeta Autorización no necesita botones; el estado lo cambia un servicio externo | Revisar botones de la revisión de autorización (CANCELAR provoca 4007) y tarjeta | **Alinear** con SCA: mismos botones que SCA, sin añadidos | R9-D |
| C3 | Caducidad sin respuesta Emisión/ANL: probar más frente a SCA | — | Comparar proceso SCA (`SCA Mecanizacion`, 24 h ANL) con `SCA2 CMD Mecanizar` y documentar | R9-D |
| C4 | Bloqueada por Emisión → nada que hacer | Comprobar que SCA2 no permite actuar en «Mecanización enviada» | Verificar | R9-D |
| C5 | Decisión tras anulación directa NSE la toma el servicio | Ya así | — | — |
| D1 | No consultar Documentum para saber si existe impresión | SCA2 comprueba gestión 4 en CORE + BBDD | OK | — |
| D2 | Documento en Documentum sin gestión CORE: probar antes de decidir | — | Probar escenario (forzar fallo tras Documentum) y documentar | R9-D |
| D3 | Relanzar reutiliza lo existente | Implementado | — | — |
| E1 | Correos DUE llegan; falta teléfono o correo de contacto (obligatorio) | Revisar `SCA2_mensajeCorreoElectronico` vs `SCA_mensajeCorreoElectronico` y datos de contacto del alta | **Implementar** el dato de contacto en el correo DUE como SCA | R9-E |
| E2 | Más contexto para preguntas SI24, impresión, Ilocalizable, 3ª gestión | — | Redactar contexto concreto para el analista | R9-E |
| F1 | Solicitudes históricas/SCA: Detalle de solo lectura | Las filas solo-CORE no abren Detalle | **Implementar** Detalle de solo lectura con datos CORE (`SCA2_DetalleSolicitud` ya tiene rama sin registro SCA2) | R9-E |
| F2 | «¿Qué segunda tabla?» | — | Explicar: pestaña «Otras solicitudes de anulación» del buscador/Detalle | R9-E |
| F3 | Fecha de resolución solo cuando está resuelta | Buscador muestra `fechaResolucion` siempre | **Implementar**: vacía mientras PENDIENTE | R9-E |
| G1/G2 | ANL: contexto de la espera de 24 h; qué hace SCA después | — | Documentar el flujo SCA (proceso `SCA Mecanizacion`) con el contexto que pide | R9-D |
| G3 | Solo administradores relanzan/descartan | Implementado | — | — |
| G4 | Solicitudes de prueba sin terminar por errores: finalizarlas para liberar | Toca CORE | **Requiere confirmación del usuario** antes de finalizar nada en CORE | padre |
| Decisiones 1, 3, 5, 7, 8 | Mantener SCA2 como está / no probar Desactivar | — | Sin cambios | — |
| Decisión 4 | Cancelar autorización: probar antes de decidir | 4007 en CORE para SCA y SCA2 | Reprobar con póliza nueva y documentar | R9-D |
| Decisión 6 | Fecha de anulación tras AA: contexto | Corregido en ronda 8 (fecha vigente de CORE) | Explicar al analista | padre |

## 2. Dudas del usuario

- **M201/M206**: no son tipos de póliza; son códigos de error que devuelve el servicio de simulación New/wAutemis. M201 = «operación pendiente» sobre la póliza (error controlado, no deja continuar). M206 = «Error al consultar el estado de la situación de la póliza» (deja continuar). Para probarlos hace falta una póliza wAutemis con una operación pendiente en Emisión (M201) o que la consulta de situación falle (M206); se detectan solo cuando la simulación está activa (R9-A).
- **FDC**: no significa «tener oficina». `origen` es un parámetro con el que otra aplicación abre SCA por URL (`SCA_gestionSegunOrigen`: valores SGC, STCAT, ALT, AltMENU…, y FDC). Con `origen = "FDC"` (o subperfil `CE_MF_RECIBOS_CCC` / modo FICHAREDU) SCA muestra la sección «Tipo catalogación» en Acciones Administrativas y Contra Anulación. Es decir, FDC identifica solicitudes **abiertas desde otra aplicación** (por el nombre, probablemente la Ficha de Cliente — inferencia, a confirmar). SCA2 siempre graba `origen = "SCA2"`, así que ese caso no se da salvo que SCA2 deba admitir esa entrada externa. Pregunta al analista: ¿qué aplicación abre SCA con origen FDC y debe SCA2 soportar esa entrada?

## 3. Paquetes de trabajo (sesiones hijas)

| Paquete | Alcance | Objetos SCA2 previsibles |
|---|---|---|
| R9-A Alta y simulación | A1, A3, A5, A6, A7; altas con pólizas nuevas (wAutemis, Vida, Más Móvil, RCI, Verti); M201/M206 si aparecen | `SCA2_AltaSolicitudPage`, `SCA2_simularAnulacion*`, seguridad de `SCA2_simularAnulacionPolizaIntegracion`, `SCA2 CMD CrearSolicitud` |
| R9-B Tareas y permisos | B1, B3, B4, B5, Decisión 2, B7-SI24 (RETOMAR/mensaje) | `SCA2_DetalleSolicitud`, `SCA2_DetalleTareas`, `SCA2_puedeGestionarTarea`, `SCA2 CMD Retomar/Posponer` |
| R9-C AA y SI24 | B7-causas, B7-insiste, B7-acuerdos; AA con Más Móvil, baja temporal | `SCA2_AccionesAdministrativasPrincipal`, `SCA2_ContraAnulacionModalSiNo`, `SCA2_ContraAnulacionOpciones` |
| R9-D Mecanización y autorización | C1, C2, C3, C4, D2, G1/G2, Decisión 4 | `SCA2_MecanizacionPrincipal`, `SCA2 CMD Mecanizar`, `SCA2_Autorizacion*`, `SCA2_DetalleSolicitud` (tarjeta Autorización) |
| R9-E Buscador, Detalle y DUE | E1, E2, F1, F2, F3 | `SCA2_Buscador*`, `SCA2_DetalleSolicitud`, `SCA2_mensajeCorreoElectronico`, proceso DUE |

Coordinación: `pruebas/coordinacion-ronda9.md`. Informes: `pruebas/r9a-…md` … `pruebas/r9e-…md`.
