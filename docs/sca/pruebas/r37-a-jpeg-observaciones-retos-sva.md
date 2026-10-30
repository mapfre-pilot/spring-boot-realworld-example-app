# R37-A — JPEG en documentos y observaciones de Retos/SVA aplicados (SCA2, TEST)

Origen: respuestas del analista a la ronda 35 (`56-ronda35-analisis-sca2.md`). Entorno Appian TEST, site SCA2, usuario funcional JJGONZ2. Fecha: 29/10.

## 1. Cambios por objeto

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_TXT_EXTENSIONES_DOCUMENTO` | v1 → v2 | `{PDF, PNG, TIFF, JPG}` → `{PDF, PNG, TIFF, JPG, JPEG}`. La usan tanto los documentos de la solicitud como el DNI (misma lista; no hay lista propia del DNI). |
| `SCA2_TXT_MSG_EXTENSION_DOCUMENTO` | v1 → v2 | «Los documentos adjuntos han de ser PDF, PNG, TIFF, JPG o JPEG». |
| `SCA2_TXT_MSG_EXTENSION_DNI` | nueva v1 | «El DNI ha de ser PDF, PNG, TIFF, JPG o JPEG» (antes literal a pelo en la interfaz). |
| `SCA2_AccionesAdministrativasDocumentacion` | v7 → v8 | Los dos literales del mensaje del DNI pasan a `cons!SCA2_TXT_MSG_EXTENSION_DNI`. |
| `SCA2_TXT_OBS_RETOS_APLICADOS` | nueva v1 | «Se han asignado {0} tréboles en Retos al cliente» ({0} = tréboles enviados a Retos, `numTipBon`). |
| `SCA2_TXT_OBS_SVA_APLICADO` | nueva v1 | «Se ha asignado al cliente el SVA {0} con el correo {1}» ({0} = descripción del SVA elegido o, si el servicio no la trae, su código; {1} = correo). |
| `SCA2_ContraAnulacionOpciones` | v61 → v62 | Nueva local `obsServicioAplicado`: se vacía al pulsar POSITIVO, se pasa a `SCA2_ContraAnulacionSGO` y viaja en `dataRecuperacion.obsServicioAplicado`. |
| `SCA2_ContraAnulacionSGO` | v2 → v4 | Nuevo input `obsServicioAplicado`. Retos: sólo si `SCA2_asignarRetos` devuelve éxito (`success` del servicio) se guarda el texto de Retos. SVA: sólo en el `onSuccess` de `SCA2_marcarAsignacionBonificacionIntegracion`, que se ejecuta tras `SCA2_asignarSVA` con `codSVA` (Club MAPFRE) → texto de SVA. En fallo no se escribe nada (sigue aviso + argumento a Pendiente, R34-A). v4: si el SVA no trae descripción se usa el código. |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | v13 → v14 | `obsArgumentoPositivo`: si no hay texto de tréboles (TTQ), usa `obsServicioAplicado`; se añade a las observaciones del gestor con « - » (o solo, si el gestor no escribió nada). TTQ sin cambios. |

No se tocan `SCA2_ContraAnulacionModalRetos`, `SCA2_ContraAnulacionModalSVAEmail`, `SCA2_VisualizarDocumento*`, alta ni process models. Nada de SCA/SCAC/CORE/CMP/SGD/Club MAPFRE. Proceso: leer vivo → backup JSON local → cambio mínimo → PUT → releer y comparar (expresión idéntica en todos).

Por qué un dato nuevo y no `tipoArgumentoVariable`: SGO lo pone a 0 al terminar; el texto lo genera SGO justo en la rama de éxito del servicio, así que su presencia equivale a «aplicado por el servicio».

## 2. Paridad con SCA (sólo lectura)

SCA (`SCA_ContraAnulacionModalRecuperacionPoliza`, `…Estrategicas`, `SCA_ContraAnulacionModalRetos`, `SCA_ContraAnulacionModalSVAEmail`, `SCA_ContraAnulacionOpcionesEstrategicas`) graba en el argumento sólo la observación del gestor (`observacionesArgumento`); **no añade nada para Retos ni SVA** (tampoco para tréboles). Por eso se ha usado un texto análogo al de tréboles (duda D1).

## 3. Pruebas

| Punto | Póliza | Solicitud | Resultado |
|---|---|---|---|
| a) JPEG documento general | 0732500060414 | 15788582 | **OK**: aceptado, en SGD (0900ab4481a12fa5), visible con el ojo tras POSPONER y reabrir |
| a) JPEG DNI | 0732500060414 | 15788582 | **OK**: aceptado, en SGD (0900ab4481a12fa7), visible con el ojo tras reabrir |
| a) TXT no permitido (general y DNI) | 0732500060414 | 15788582 | **OK**: rechazado con «…PDF, PNG, TIFF, JPG o JPEG» y «El DNI ha de ser PDF, PNG, TIFF, JPG o JPEG» |
| b) Retos en pantalla | 15 pólizas | 15788582–15788600 | **No probado en pantalla**: ninguna CA ofrece argumento Retos (286/287) |
| c) SVA en pantalla | 15 pólizas | ídem | **No probado en pantalla**: ninguna CA ofrece SERVICIO VALOR AÑADIDO (252/254/365) |
| d) Regresión TTQ | 15 pólizas | ídem | **No probado en pantalla**: ninguna CA ofrece TU TE QUEDAS. El código TTQ de v13 no cambia (sólo se renombra la variable que se concatena) |
| e) Fallo de servicio | — | — | **No probado**: no se llegó a ejecutar Retos/SVA; no se forzaron fallos |

La documentación se probó desde la pestaña Documentación de la CA (misma interfaz `SCA2_AccionesAdministrativasDocumentacion`) y se comprobó en el detalle; no se recorrió aparte la entrada de acciones administrativas.

Validación por LCP: `POST /interfaces/{Recup}/test` sin errores con `data` de Retos (observación del gestor + `obsServicioAplicado`), de TTQ (`tuTeQuedas`, `numBonAplic: 15`) y sin servicio. Appian valida la sintaxis de SGO/Opciones en el PUT. No se llamó a los servicios reales de Retos/SVA (asignarían tréboles/SVA reales en Club MAPFRE sin póliza de prueba adecuada).

Pólizas exploradas (todas libres antes de dar de alta, solicitudes nuevas que quedan Pendientes con la CA sin finalizar): 0732500060414, 0730980242750, 0732500042407, 2002400383852, 2002000000910, 2002200225834, 0731900024805, 0731900024795, 2002400304316, 0732300122312, 0732600000384, 0732500039267, 0732500061199, 2002300260145, 0731180058542 (ver `polizas/REGISTRO.md`). Argumentos que sí aparecen: GESTIÓN COMPETENCIA, SUPLEMENTO GENERAL, PÉRDIDA DE DESCUENTOS, SERVICIOS MAPFRE, CLUB MAPFRE PLATA/ORO/PLATINO, TARJETA BANKINTER, CAMBIO DE FORMA DE PAGO, etc.

Capturas (`docs/sca/img/`): `r37a-03-documento-txt-rechazado.png`, `r37a-07-dni-txt-rechazado.png`, `r37a-04-documento-jpeg-aceptado.png`, `r37a-08-dni-jpeg-aceptado.png`, `r37a-17-jpeg-persistidos-reapertura.png`, `r37a-18-documento-jpeg-visor-reapertura.png`, `r37a-19-dni-jpeg-visor-reapertura.png`, `r37a-02-ca-sin-retos-sva-ttq.png` y, por póliza, `r37a-{póliza}-libre.png` / `r37a-{póliza}-argumentos.png`.

## 4. Dudas para el analista

- **D1** Textos exactos: Retos «Se han asignado {N} tréboles en Retos al cliente» y SVA «Se ha asignado al cliente el SVA {descripción} con el correo {email}». SCA no graba nada; confirmar o dar el texto deseado (se cambia sólo la constante).
- **D2** Retos: se informa el número de tréboles enviado al servicio (`numTipBon` del argumento, igual que SCA), no el introducido en el modal (`numBonAplic`). Confirmar que es lo correcto.
- **D3** SVA: si la asignación en Club MAPFRE va bien pero falla el marcado en CORE (`marcarAsignacionBonificacion`), el argumento se finaliza positivo (comportamiento heredado) sin observación de SVA. ¿Se quiere así?
- **D4** Necesitamos pólizas de TEST cuyas CA ofrezcan Retos, SVA y TU TE QUEDAS para cerrar b), c), d) y e) en pantalla.
