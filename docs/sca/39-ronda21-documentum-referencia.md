# Ronda 21 — Documentos SCA2: «Referencia» = nº de solicitud y error GD_ERROR 404 al ver el documento

**Pregunta del usuario (19/10/2026):** al subir un documento a Documentum, ¿se guarda bien el identificador? Al pulsar el ojo en el Detalle aparece en la bandeja de errores
`SCA2 CMD ObtenerDocumentoGD / consultaDocumento / GD_ERROR … HTTP/1.1 404 Not Found`.

## 1. Diagnóstico (verificado en TEST)

| Evidencia | Resultado |
|---|---|
| `SCA2 Error` con `GD_ERROR` | El campo `idSolicitud` de esas filas es en realidad el `documentumId` enviado a `consultaDocumento`: **15788098, 15788099, 15788106** = el **nº de solicitud**, no un id de Documentum. |
| `rule!SCA2_consultarDocumentos("15788098")` (CORE) | `listaDocumentos = [idDocumento=15788098, tipo 6]` → CORE tiene guardado el nº de solicitud como referencia del documento. |
| Misma consulta para solicitudes creadas desde **SCA** (15787986, 15787759) | `idDocumento = 0900ab4481a0a479`, `0900ab4481a05a86` (r_object_id real de Documentum). |
| `SCA2_searchDocumentosIntegracion` (advancedSearch, QUERY_SCA_AGD_001, 15788098) | HTTP 200, `items: []` → el documento **no existe en Documentum**. |
| Integraciones `consultaDocumento` SCA vs SCA2 | Idénticas (mismo connected system, `documents-web/api/…/{id}/content`). El 404 es porque el id no existe, no por la URL. |

**Causa raíz:** regresión introducida en la ronda 11 (#11, `SCA2_subirDocumentosGD` v7, «reutilizar la referencia SGD al relanzar»).
La regla interpretaba la **3ª parte** de cada item de `listaNombreDocs` (`idDoc_tipo_<3ª>`) como referencia SGD previa y, si existía,
**no subía el fichero** al SGD (`reutilizado: true`) y grababa esa 3ª parte en CORE. Pero las pantallas (herencia literal de SCA:
`SCA_AccionesAdministrativasDocumentacion` → `local!nombreDoc = idDoc & "_" & tipo & "_" & codSolicitud`) rellenan siempre esa 3ª parte
con el **código de solicitud**. Resultado desde v7: ningún documento adjuntado en SCA2 llegaba a Documentum; CORE guardaba el nº de
solicitud como referencia; el ojo pedía `/documents/<nºsolicitud>/content` → 404. SCA no tiene el fallo (no tiene lógica de referencia previa).

Respuesta corta a la pregunta: el identificador **no se estaba guardando bien porque el documento no se estaba subiendo**; el fallo estaba
en Appian (SCA2), no en Documentum ni en CORE.

## 2. Corrección — `SCA2_subirDocumentosGD` v7 → v8 (versionId 9)

```sail
/* antes */ refPrevia: tostring(a!defaultValue(index(local!partes, 3, ""), "")),
/* ahora  */ refPrevia: a!localVariables(
  local!p3: tostring(a!defaultValue(index(local!partes, 3, ""), "")),
  if(or(a!isNullOrEmpty(local!p3), local!p3 = tostring(ri!codSolicitud), len(local!p3) <> 16), "", local!p3)
),
```
La 3ª parte sólo cuenta como referencia previa cuando **no es el codSolicitud y tiene 16 caracteres** (r_object_id de Documentum), que es lo que
escribe `SCA2 CMD CompletarAccion` al llevar un `DOC_GD_FAIL` a la bandeja (`idDoc_tipo_<ref16>`). El relanzamiento sin duplicar (R11 #11)
se mantiene; `CMD CompletarAccion` no cambia. Backups: `sca2work/r21/before_subirDocumentosGD.json`, `after_subirDocumentosGD.json`.

## 3. Prueba (dato nuevo)

Solicitud **15788108** (póliza 2002600073520, JJGONZ2, 19/10/2026 21:31): Contra Anulación negativa + «Carta firmada» (tipo 6, PDF con marca
`R21-GD-20261019-01`) → Detalle: Referencia **`0900ab4481a0c1cf`** (16 caracteres), el ojo abre el PDF correcto, 0 filas nuevas en la bandeja de errores,
persiste tras F5. Vídeo: `sca2-r21-documentum-edited.mp4`.

## 4. Solicitudes afectadas (barrido CORE ≥ 15787980)

| Solicitud | Tipo doc | Referencia en CORE | Estado |
|---|---|---|---|
| 15788028 | 6 Carta firmada | 15788028 | afectada — el fichero nunca llegó al SGD |
| 15788045 | 7 DNI | 15788045 | afectada |
| 15788098 | 6 | 15788098 | afectada (GD_ERROR 15:45) |
| 15788099 | 6 | 15788099 | afectada (GD_ERROR 15:54) |
| 15788106 | 7 | 15788106 | afectada (GD_ERROR 21:05) |
| 15787998 | 7 | 0900ab4481a0a838 | correcta (anterior a v7) |
| 15788108 | 6 | 0900ab4481a0c1cf | correcta (v8) |

Los ficheros originales siguen en Appian (el `idDoc` de la carpeta de la solicitud), así que es posible **re-subirlos** al SGD y corregir la referencia
en CORE (`modificarCrearDocumentos*`) con un relanzamiento controlado; no se ha hecho por ser datos de pruebas antiguas (pendiente de decisión del usuario).
Las 8 filas `GD_ERROR` de la bandeja (ids 88–96) quedan `PENDIENTE`; «Repetir la acción» sobre ellas volverá a fallar mientras no se corrija la referencia.

## 5. Objetos tocados
| Objeto | Tipo | Versión | Cambio |
|---|---|---|---|
| SCA2_subirDocumentosGD | Regla | v7 → v8 | 3ª parte de `listaNombreDocs` sólo es referencia previa si ≠ codSolicitud y len = 16 |
