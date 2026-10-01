# Ronda 2 (documento del analista) — evidencias LCP y UI

Complemento de `docs/sca/13-revision-analista-ronda2.md`. Entorno TEST, usuario de pruebas JJGONZ2, SCA (`/sites/sca-site`) como referencia y SCA2 (`/sites/sca2`). Todas las pruebas con solicitudes nuevas; no se pulsó `ANULAR PÓLIZA`.

## 1. Objetos desplegados y verificación por LCP

| Objeto | Versión | PUT → GET | Prueba `/test` |
|---|---|---|---|
| `SCA2_Buscador` | 15 → 16 | expresión enviada = recibida; inputs `vista, numPoliza, idSolicitud, tipoAccion, idTarea` | HTTP 200, `ContentLayout`, sin error |
| `SCA2_ContraAnulacionOpciones` | 29 → 30 → 31 → 32 → 33 → 34 → 35 → 36 | expresión enviada = recibida en cada PUT; inputs `idSolicitud, idTarea, onCompletar, onVolver` | HTTP 200, `ContentLayout`, sin error (v31 y v32 con `idSolicitud: 15787747`). v31 y v32 fallaron en UI al POSPONER («Attempted to run a second smart service…», también encadenando en `onSuccess`); v33 delega la persistencia al CMD Posponer. v33 en UI: POSPONER CORRECTO sin error de smart service, pero RETOMAR seguía con 3247 (record sin actualizar: `idCompania` llegaba como lista → nulo) → v34 (`index(..., 1, null)`); además ACEPTAR en el popup no cambiaba el campo porque guardaba en `local!seleccionCia` → v35 guarda en `local!companiaContraria` como SCA. v34 y v35: PUT 200, GET expresión igual, `/test` 200 sin error con `idSolicitud: 15787747`. v35 en UI: ACEPTAR aplica ABANCA, pero el record quedó `idcompania = 1` (mapa escalar + `index(texto, 1)` → "1") → v36 con `a!flatten`, verificado en regla temporal LCP (lista y mapa → 1808; regla borrada, DELETE 204) |
| `SCA2 CMD Posponer` | — | pvs parámetro `idCompania`, `catalogacion`, `fecAnulacion`; nodo 5 «Write Posponer»: el item `SCA2 Datos Solicitud` (antes sólo `fecimpresion`) actualiza también `idcompania`/`catalogacion`/`fecanulacion` cuando llega `idCompania` | La primera verificación fue un falso positivo (el nodo ya contenía un item `SCA2 Datos Solicitud` de `fecimpresion` y la escritura de `idcompania` no había quedado grabada); re-PUT 200 con el item fusionado, GET: expresión igual, 12 nodos, pvs presentes. UI tras el re-PUT: record modificado (`fecimpresion` = observación, `idcompania` escrito) |
| `SCA2_consultaDocumentoIntegracion` | 1 → 2 | `responseBodyParsing: CONVERT_BINARY`, `documentFolderUuid: …_20064050` (`SCA2 Documentos`) | `/integrations/{uuid}/test` con `documentId: 0900ab4481a05272` → `success: true`, HTTP 200, `Content-Type: application/pdf`, `Content-Disposition: attachment; filename="0900ab4481a05272.pdf"`, `body: 556331` (id del documento Appian creado) |
| `SCA2 CMD ObtenerDocumentoGD` | — | nueva pv `documentId` (Integer); nodo 12 `consultaDocumento` → `customOutputs: if(a!defaultValue(ac!Success,false), tointeger(ac!Result.body), null) → documentId` | GET posterior confirma pv y salida |
| Carpeta `SCA2 Documentos` | — | `/objects/{uuid}/security`: `editor += SCA2 Users` (administrator/viewer sin cambios) | GET posterior |

Nota LCP: el PUT de `SCA2 CMD ObtenerDocumentoGD` devolvía `400 The data is invalid for at least one type/value` incluso sin cambios; la causa son los inputs vacíos del nodo «Modify Process Security» que el GET devuelve con `value: []` y el PUT exige como `value: null`. El endpoint `/folders/{uuid}/security` no existe (501); la seguridad se lee/escribe con `/objects/{uuid}/security`.

## 2. Causa raíz del visor «Documento no disponible» (Acción Administrativa)

- SCA: `SCA_PM_OBTENER_DOCUMENTO_GD` → `SCAC_consultaDocumentoIntegracion` (`CONVERT_BINARY`, carpeta `SCA_FLD_DOCUMENTOS_ARGUMENTOS`) → pv `documentId` (Integer) → `a!documentViewerField(document: fv!processInfo.pv.documentId)`.
- SCA2 (antes): integración `RETURN_RAW` (texto), PM sin pv `documentId`, la interfaz leía `fv!processInfo.pv.documentId` → `null` → visor vacío.
- SCA2 (ahora): misma cadena que SCA. El ojo deshabilitado justo tras AÑADIR (antes de POSPONER/FINALIZAR) es la misma condición que en SCA (`search(idDocumento, consultaDocumentosGD) = 0`): el documento no existe en GD hasta que el CMD lo sube.

## 3. Datos de las solicitudes usadas

| Solicitud | Póliza | Flujo | Notas |
|---|---|---|---|
| 15787744 | 2002000026491 | CA NEGATIVO + POSPONER/RETOMAR/CANCELAR (pre-v30) | gestiones CA 43704951 (incompleta) / 43704952 (`FINALIZADA CANCELADA`) |
| 15787745 | — | CA POSITIVO (pre-v16) | — |
| 15787746 | 2002000025762 | Acción Administrativa (documentos DNI + compra) | docs GD `0900ab4481a05274` (tipo 1) / `0900ab4481a05272` (tipo 7); visor fallaba antes de la corrección |
| 15787747 | 2002000022901 | CA NEGATIVO + POSPONER (v30…v36) + RETOMAR | `idgestionsgc 233844114` en CORE; compañía vacía/ALLIANZ/`1` al retomar en v30–v35 → v36 + PM: `idcompania 1808` persistido; queda pendiente (retomada) |
| 15787672 | 2002100648994 | Búsqueda por NIF `74010262B` / nombre `OTDAF` + apellido `POPAZ` (v16) | SCA2 encuentra la solicitud igual que SCA; NIF sintético `99999999R` → 0 resultados sin error |

## 4. Resultado UI (testing agent)

Informe íntegro del testing agent: `07-ronda2-ui3-informe-testing-agent.md`; resumen en §13.3 de `../13-revision-analista-ronda2.md`.

Veredicto: buscador v16 igual que SCA; POSPONER/RETOMAR de Contra Anulación persiste compañía/catalogación/fecha/argumentos en v36 + PM (record `idcompania 1808` confirmado por LCP tras la prueba); CANCELAR y POSITIVO cierran como SCA (`15787744`/`15787745`); Acción Administrativa y visor PDF iguales a SCA (`15787746`). Sin comparar: alta nueva en SCA (no navegó en >90 s en TEST), por lo que la paridad fila a fila de la tarea editable CA queda pendiente de una nueva ronda.
