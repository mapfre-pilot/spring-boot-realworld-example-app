# Consolidado de las pruebas comparativas SCA vs SCA2 en TEST (sesiones S1–S5, 30/09/2026)

Resumen ejecutivo de las cinco sesiones paralelas de prueba (una por flujo, con pólizas NSE vigentes y sin
solicitud previa del Excel «Pólizas NSE vigor»). El detalle paso a paso, las causas raíz y las evidencias
están en los informes `s1-…md` a `s5-…md` de esta carpeta. Referencia funcional: **SCA TEST**. No se ha
modificado ningún objeto de SCA, SCAC, CORE, GAIA, PRE ni Documentum.

## 1. Veredicto por flujo

| Sesión | Flujo | Solicitud SCA2 final (póliza) | Solicitud SCA de referencia | Veredicto |
|---|---|---|---|---|
| S1 | Alta → salto directo a Contra Anular → POSITIVO → FINALIZAR | 15787723 (2002000032929); 15787728 confirma la versión final | 15787696 / 15787734 | **Igual que SCA**: gestión `FINALIZADA POSITIVA`, `finalizarSolicitud` 2→3, retorno directo al buscador |
| S2 | Contra Anular NEGATIVO + documentos por motivo + GD/CORE → mecanización | 15787743 (2002000085510) | 15787734 (2002000062827) | **Igual que SCA**: gestiones 8/2/4/5, `codEstSolic=2`, carta en GD/CORE, pantalla NSE‑Autos, traza «Inicia Subproceso Appian» |
| S3 | Acción Administrativa (documentos, POSPONER/SGC, RETOMAR, FINALIZAR, ACEPTAR) | 15787736 (2002000044711) | 15787700 | **Igual que SCA**: gestión 3 finalizada, 5 abierta, NSE‑Autos, observaciones del buscador |
| S4 | Autorización fuera de norma (POSPONER, REASIGNAR, RETOMAR, documentos, FINALIZAR) | 15787739 (2002000062813) | 15787698 | **Igual que SCA**: `mcaAutorizada=S`, gestión 7 finalizada, 5 abierta, tag «Aceptada», buscador «Pendiente» |
| S5 | Detalle, buscador, tareas, bandeja de errores, POSITIVO+documento, resiliencia | 15787728 (2002000065541) | 15787696 | **Igual que SCA** a la primera; relanzamiento real desde `/errores`; reintentos 3+3 como SCA |

Todos los ciclos finales se ejecutaron desde la UI con una sola pulsación por acción, terminaron con el CMD
`COMPLETED` y sin fila en `SCA2 Error`. En ninguna prueba se pulsó «ANULAR PÓLIZA».

## 2. Causas raíz comunes corregidas en SCA2

| # | Síntoma | Causa | Corrección |
|---|---|---|---|
| 1 | «CORRECTO» en pantalla pero la gestión CORE seguía abierta | input `consulta` del nodo Finalizar CA sin prefijo `=` (texto literal) | payload evaluado; validado por API y UI (S1) |
| 2 | Cierres erróneos / rama «finalizar» siempre | operador `in` (inexistente en Appian) en el nodo 200 del `CMD CompletarAccion` | `contains()` (S2) |
| 3 | PM pausado por excepción al subir documentos | ficheros de `a!fileUploadField` en páginas de site son temporales | `a!submitUploadedFiles(onSuccess: a!startProcess…)` en las tres pantallas de acción (S4 → S1/S2/S3) |
| 4 | `DOC_GD_FAIL` a la primera | error transitorio del servicio documental sin cuerpo | reintento acotado 3 GD + 3 BBDD, idéntico a los nodos de SCA (S5) |
| 5 | Relanzamiento desde `/errores` era un no‑op y la idempotencia lo bloqueaba | transición de éxito escrita antes de las llamadas externas | transición al nodo 330 tras CORE; `resultado` desde el payload persistido (S5) |
| 6 | Autorización aceptada pero no actualizada en CORE | faltaba «Actualizar Autorización» (`guardarAutorizacion`, `codEstado=2`, `mcaAutorizada=S`) | nodos 303–305 (S4) |
| 7 | Tras la CA positiva la solicitud quedaba en 2 | faltaba `finalizarSolicitud` (2→3) | nodos 350–353, payload exacto de SCA (S5) |
| 8 | NEGATIVO cerraba la solicitud | SCA deja la solicitud pendiente y abre mecanización | rama NEGATIVO → gestiones 4 (impresión) y 5, redirección NSE‑Autos (S2) |
| 9 | POSPONER sin gestión SGC / perdía adjuntos | no portado de SCA | `SCA2_posponerGestionSGC` reutilizable (AccAdm/CA; AUT omitido como SCA) (S3/S4) |
| 10 | Buscador: textos, colores y Observaciones distintos | fuente record vs CORE | `SCA2_textoEstadoSolicitud` v9, `SCA2_colorEstadoSolicitud` v5, última observación CORE por solicitud con fallback al record (S4/S5) |
| 11 | Detalle sin refrescar al volver de NSE‑Autos | `refreshVariable` no invalida la consulta | «VOLVER AL DETALLE» navega con `a!sitePageLink` (S2) |

## 3. Hallazgos comunes a SCA y SCA2 (no son defectos de SCA2)

- Latencia de CORE tras un cierre: el buscador/detalle pueden mostrar «Pendiente»/`INCOMPLETA` 1–2 min (S1 §10.3, S5 §10.4).
- Caídas puntuales de `IContraAnularPCA` y del servicio documental (integraciones SCA2 y SCAC idénticas).
- Doble «Consulta NEW …» al abrir la pantalla operativa (código común).
- Error de SCA al pulsar la flecha «volver» del Detalle (`sca_datoscabecera`, `a!submitLink`): propio de SCA, no tocado.
- El botón «Detalle suplemento» no muestra nada en ninguna de las dos aplicaciones.

## 4. Pendientes y decisiones abiertas

| Tema | Estado | Quién decide |
|---|---|---|
| Instancia `9994107` de `SCA2 CMD CompletarAccion` en `ACTIVE` (v33, antes del fix de tipos) | LCP 501, Designer 403 con el usuario funcional | administrador Appian: cancelar desde Monitoring |
| Acceso de JJGONZ2 a la bandeja `/errores` | 403 por diseño de seguridad del site | analista/seguridad |
| REASIGNAR con un segundo usuario real del grupo | la regla de asignación es la del código SCA (`pp!initiator`); no verificable con datos propios | requiere solicitud iniciada por otro usuario |
| Visibilidad en el buscador SCA2 de solicitudes históricas/creadas en SCA | SCA2 solo consulta su record; SCA consulta CORE | analista (convivencia/migración) |
| Mecanización completa (ANULAR PÓLIZA), caducidad real, cambio de nivel, VERTI/Vida | no ejercitados (sin acción equivalente o fuera de alcance de pruebas) | siguiente fase |
| Rama de error `AUT_GUARDAR_FAIL` y reintentos GD en fallo real | lógica idéntica a SCA y tests de regla, sin fallo real provocado | — |
| Rendimiento, volumen (>1.000 altas/día) y validación previa a producción | no medido en esta tanda | siguiente fase |

## 5. Objetos SCA2 relevantes al cierre (versiones vivas en TEST)

`SCA2 CMD CompletarAccion` PM v34 (49 nodos) · `SCA2 CMD CrearAccion` (28 nodos) · `SCA2 CMD Posponer` v7 ·
`SCA2_DetalleSolicitud` v37 · `SCA2_DetalleTareas` v12 · `SCA2_ContraAnulacionOpciones` v28 ·
`SCA2_BuscadorTabla` v7 · `SCA2_textoEstadoSolicitud` v9 · `SCA2_colorEstadoSolicitud` v5 ·
`SCA2_subirDocumentosGD` v5 · `SCA2_altaDocumento` v2 · `SCA2_posponerGestionSGC` · `SCA2_liberarTarea` (nuevo, conservado).

Pólizas consumidas en esta tanda: ver tabla del §1 y los informes por sesión; el resto de pólizas del Excel
sigue disponible para futuras pruebas.
