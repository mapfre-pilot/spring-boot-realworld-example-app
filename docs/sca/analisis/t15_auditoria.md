# Tanda 15 — Auditoría de resiliencia y paridad de flujo (FASE A)

Volcado MCP `getProcessModel` de los 12 PMs `SCA2 CMD *` (snapshot /tmp/t15_pms.json). Para cada nodo Integration/Write Records/Script/Start Process: ¿isSuccess capturado + XOR a Persistir error? ¿Pausa posible? ¿El PM termina siempre en End?

## Resumen por PM

| PM | Integraciones | isSuccess→XOR→Write Error | Riesgo de pausa | Gap paridad SCA |
|---|---|---|---|---|
| Alta | `generarStudAnul` (Core7, NO idempotente) | **SÍ** (Success→pv!success → "Resultado?" → Write Error → End) | Write Records ×4 (PauseOnError=1), scripts Cargar/Contexto/PreGenerar, Start Decidir | Ninguna lógica: XORs idempotencia, PRRA/NSE, estados OK |
| Decidir | ninguna (reglas en Script `Consultar reglas`) | n/a — ya hay reintento interno (intentos<3 → Start Decidir reintento; ≥3 → Write Error bloqueado) | Write Records ×5, scripts Cargar/Consultar reglas | OK — rama Mecanizar/destino igual a spec |
| CrearAccion | ninguna | n/a | Write Records ×6, scripts | OK |
| CompletarAccion | ninguna (trazabilidad es write record) | n/a | Write Records ×6 | OK — XORs Cancel/Autorizacion/PDTE_FINALIZAR |
| Finalizar | Finalizar Solicitud (PCA), Finalizar Gestion SGC | **SÍ ambas** (successPca/successSgc → Write Error → End) | Write Records ×3 | OK — idGestionSGC? guarda igual que SCA |
| Mecanizar | Guardar Mecanización, Crear Autorización (VERTI) | **SÍ ambas** → Write Error → End | Write Records ×4 | OK — ramas Caducada/VERTI/Autoriz |
| Caducar | Finalizar Solicitud (PCA) | **SÍ** → Write Error → End | Write Records ×3 | OK — ¿Caducada?/¿Ya ejecutado? |
| Posponer | ninguna | n/a | Write Records ×1, script Cargar | OK |
| CambiarNivel | ninguna | n/a | Write Records ×2, script | OK |
| BarridoCaducidad | ninguna | n/a | script Obtener caducadas, Start Caducar por fila | OK — no-op cuando lista vacía |
| GenerarPdf | docxtemplatemerge ×2, PDFfromDOCX ×2, Delete Document | **NO** (sin salida isSuccess capturada) | docxtemplatemerge/PDFfromDOCX/DeleteDocument pausan en error | Igual que SCA DocxPDF (SCA tampoco maneja) |
| ObtenerDocumentoGD | consultaDocumento (GD, lectura) | **SÍ + reintento** (`success?` → contador<3 → reintenta; si no → End) | Modify Process Security | OK — retry ya implementado |

## Conclusiones FASE A
1. **Todas las integraciones ya capturan `Success`/`Error` y enrutan a `SCA2 Error` → End**: ninguna instancia queda pausada por excepción de integración (el smart service devuelve isSuccess=false, no lanza). Cumple el requisito sin cambios.
2. **Riesgo residual de pausa**: nodos `Write Records` (`PauseOnError=1`), `internal.16` Script Tasks (eval error de expresión), smart services de documento (GenerarPdf) y `Modify Process Security`. No tienen salida isSuccess — la única vía es la pestaña "Exceptions" del nodo (excepción + boundary event) o `PauseOnError=0` (silenciar, no recomendado: pierde la fila).
3. **Reintento**: ya existe en ObtenerDocumentoGD (×3) y Decidir (intentos<3). No aplica reintentar escrituras (Core7, SGC, SGO, PCA Finalizar) — no idempotentes. No hay integraciones de lectura sin reintento.
4. **Paridad de flujo**: sin gaps de lógica detectables — XORs de idempotencia (claveIdempotencia), estados escritos y llamadas externas coinciden con el spec atómico (SCA usa subprocesos síncronos en vez de records, ya documentado).

## Decisión FASE B
- Sin cambios de código en rutas de integración (ya conformes al patrón pedido).
- `SCA2_conReintento` **no se crea**: no hay integraciones de lectura sin reintento que lo necesiten (consultaDocumento ya reintenta ×3).
- PauseOnError/Exceptions: intento por MCP; si no expone → Designer (Alta + Decidir) o documentado.

## FASE B — acciones aplicadas (Tanda 15)
- **Write Records (31 nodos, 9 PMs)**: `PauseOnError=false()` en TODOS los nodos write_records_to_source (incl. los "Write Error") → un fallo de escritura ya no pausa la instancia. Persistido vía updateProcessModelNode; validateDesignObject 0 errores en los 12 PMs.
- **Exceptions tab (Designer, comprobado en CMD Alta)**: solo ofrece triggers de evento de excepción (mensaje/timer/regla) — NO existe opción por nodo de "no pausar" salvo PauseOnError. No se añadieron triggers (aplicarían a escalaciones, no al requisito).
- **Salidas ocultas descubiertas**: los nodos Write Records exponen `ErrorOccurred`/`Error` — candidato para XOR→Write Error si se quiere capturar fila en fallo de escritura (no aplicado: doble escritura en cascada de riesgo; documentado como opción).
- **CompletarAccion XOR "Cancel?"**: null-guards `a!defaultValue` (fix previo, verificado COMPLETED).
- **ObtenerDocumentoGD**: fallo residual "rank (Data Outputs)" dentro del parseo binario de la integración consultaDocumento (errorHandling=CUSTOM no lo evita) — documentado como dudoso/pendiente Designer.
- **SCA2_conReintento**: no creada — no hay integraciones de lectura sin reintento propio; ObtenerDocumentoGD y Decidir ya implementan retry contador<3 / intentos<3.
- Limpieza: borradas filas de prueba Transicion ids 34-39 y Error ids 63-70 (deleteRecordData).

## FASE B-bis — cableado ErrorOccurred + ObtenerDocumentoGD (Tanda 15-bis)
- **Write fail XOR**: 25 nodos Write Records de negocio (9 PMs) con outputs `ErrorOccurred→pv!wrErr`, `Error→pv!wrErrMsg` y XOR "¿Write fail?" posterior → Script "Capturar error escritura" (wrNodo=nombre nodo, wrCodigo="WRITE_FAIL") → Write Error existente → End. Write Error sin PauseOnError → termina siempre. PMs sin nodo Write Error (CompletarAccion, Posponer, CambiarNivel) recibieron uno nuevo (id 199). PVs nuevos: wrErr, wrErrMsg, wrCodigo, wrNodo.
- **ObtenerDocumentoGD**: causa raíz real = output `Result` (HttpResponse) guardado en PV `documentId` (Number) → "rank (Data Outputs)". Fix: saveInto de Result eliminado; integración dejada con errorHandling=DEFAULT; XOR success? null-safe (`a!defaultValue(pv!success,false)`, `a!defaultValue(pv!contador,0)<3`); nuevo nodo 200 "Write Error" (GD_ERROR) en la rama default tras 3 reintentos → End.
- **Regla `SCA2_consultaDocumentoGD` creada** (`_a-…_20071048`) — pero `rule!` sobre integración devuelve "[Reaction Tree]" (diferido, no ejecuta): enfoque de regla no viable; la integración se llama desde el smart service como antes. La regla queda publicada pero SIN USO.
- **Null-guards añadidos**: Decidir nodo 5 intentos (`a!defaultValue(rule!SCA2_contarErroresPendientes(...),0)+1`); Decidir XOR `pv!nivelCalc>1` → `todecimal(a!defaultValue(...))`; Posponer/CambiarNivel XOR `pp!name`→literal (validación); CambiarNivel filtro `pv!idSolicitud`→`a!defaultValue(...,"#")`; contador++ GD.
- **Props verificadas en Designer** (alertas "SCA2 Alertas" + eliminar 1 día): Alta, Decidir, ObtenerDocumentoGD — capturas t15_props_*.
- Retest fallo forzado: 12/12 COMPLETED; filas prueba borradas (Error 74-81, Transición 40-45).
