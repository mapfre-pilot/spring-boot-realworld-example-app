# Ronda 35 — sexto «Análisis SCA2» (analistas, 29/10/2026): clasificación y reparto

Origen: «Analisis SCA2.docx» (6.º) + `polizasDevin.csv` (970.823 pólizas para pruebas; ver `pruebas/polizas/`).

| # | Punto del analista | Tipo | Qué hay que hacer | Quién |
|---|---|---|---|---|
| 1 | Alta (prueba TTQ con póliza Hogar 0732400126663): tras ACEPTAR, «decidir acción» tarda >30 s, no avanza y **vuelve a la pantalla de Alta**; por detrás la solicitud sí se ha creado y al volver a GUARDAR salta una excepción «ya existe una solicitud en curso» | Error | (a) Si la decisión tarda: mostrar aviso «está tardando un poco más en generar la siguiente gestión, espere» y **ampliar la espera 15 s** (repetible) hasta que exista la siguiente gestión; nunca volver al alta en blanco. (b) Si el usuario vuelve a GUARDAR con una solicitud en vuelo para esa póliza: mensaje «existe una solicitud en curso para la póliza, ¿quiere consultarla?» → navegar al detalle de esa solicitud con RETOMAR (si el rol lo permite) → la CA. Sin excepción. | R35-A |
| 2 | Carga de documentos: permitir imágenes además de PDF (como en la carga de DNI) | Necesidad | Aceptar los mismos formatos de imagen que la carga de DNI en la carga de documentos de la solicitud; comprobar que SGD/visor los acepta. | R35-B |
| 3 | Tréboles: en el detalle, el argumento positivo muestra los 20 ofrecidos pero no los 17 aplicados | Necesidad | Al aplicar tréboles (ACEPTAR de la pantalla TTQ, R34-A), guardar en **observaciones** del argumento «Se han aplicado Y tréboles al cliente» y mostrarlo en la consulta de la solicitud. | R35-B |

| 4 | Los documentos mostrados (PDF de oposición a la renovación, imagen del DNI) salen sobredimensionados | Necesidad | Adaptar el visor al tamaño real del documento (PDF e imágenes) sin sobredimensionar. Añadido el 29/10 por el usuario. | R35-B |

Coordinación y pólizas: `pruebas/coordinacion-ronda35.md`, `pruebas/polizas/` (bloques por sesión y registro de uso). Informes: `pruebas/r35-a-espera-decision-solicitud-en-curso.md`, `pruebas/r35-b-documentos-imagen-observaciones-treboles.md`.

## Resultados de la ronda 35 (29/10; informes `pruebas/r35-a-espera-decision-solicitud-en-curso.md`, `pruebas/r35-b-documentos-imagen-observaciones-treboles.md`)

| # | Punto | Resultado | Objetos SCA2 | Pregunta abierta |
|---|---|---|---|---|
| 1 | Espera de decisión / solicitud en curso | **Corregido**: el alta lanzaba `CMD Alta` síncrono y al agotar 30 s sin tarea volvía a mostrar el formulario aunque la solicitud se seguía creando (Alta → Decidir → motor → CrearAccion, 20-25 s en TEST). Ahora el alta queda en espera (formulario y GUARDAR ocultos), aviso «está tardando un poco más…», ACEPTAR abre la gestión; si se vuelve a GUARDAR con solicitud en vuelo: «Existe una solicitud en curso… ¿quiere consultarla?» → detalle → RETOMAR → CA. Probado 15788537 (Autos), 15788542 (Hogar), regresión 15788545. Caso >30 s del analista no reproducido. | `SCA2_AltaSolicitudPage` v42, `SCA2_AltaSolicitudAnulacionPopUp` v11, `SCA2_consultarSolicitudEnCurso` v2, 9 constantes `SCA2_VAL_ESPERA_DECISION_*`/`SCA2_TXT_*` | Appian no refresca por debajo de 30 s: ¿vale sondeo de 30 s o se exige 15 s (otro mecanismo)? ¿Tope de espera / salida si el proceso se bloquea? |
| 2 | Documentos con imagen | **Aplicado**: PDF, PNG, TIFF, JPG (lista del DNI) en constante; JPG/PNG al SGD y vistos; TXT rechazado. | `SCA2_AccionesAdministrativasDocumentacion` v7, `SCA2_TXT_EXTENSIONES_DOCUMENTO`, `SCA2_TXT_MSG_EXTENSION_DOCUMENTO` | ¿Añadir `.jpeg`? TIFF/DOCX y rechazo al MODIFICAR sin probar. |
| 3 | Observaciones «Se han aplicado Y tréboles» | **Aplicado, sin probar en pantalla**: ninguna póliza del bloque ofrecía TTQ vigente. | `SCA2_ContraAnulacionModalRecuperacionPoliza` v13, `SCA2_TXT_OBS_TREBOLES_APLICADOS` | Separador con observaciones del gestor; ¿sólo TTQ?; pólizas con TTQ vigente. |
| 4 | Visor sobredimensionado | **Aplicado**: visor centrado ≈800 px para PDF e imagen. | `SCA2_VisualizarDocumento` v3, `SCA2_VisualizarDocumentoContraanularEstrategicas` v3 | ¿Anchura adecuada? |
| — | Hallazgo R35-A: CA «No hay argumentos disponibles» tras RETOMAR/RECARGAR | **Corregido**: timeout de `SCA2_consultarListadoArgumentosREST` 60 s (SCA 300 s); el servicio de TEST tardó >60 s. Igualado a 300 s. No era regresión de R34-A. | `SCA2_consultarListadoArgumentosREST` v3 | — |

Otros: 15788547 lista 9 argumentos en el detalle y 7 en la CA (filtro heredado de SCA). Pólizas usadas registradas en `pruebas/polizas/REGISTRO.md`.

## Respuestas del analista (29/10) → ronda 37
- `.jpeg`: añadirlo (también al DNI).
- Observaciones de tréboles: grabar sólo cuando el servicio ha aplicado los tréboles en Club MAPFRE y en el candidato (como SCA). **Punto 3 probado por el analista con póliza TTQ: correcto** («Se han aplicado 15 tréboles al cliente» en el detalle).
- Extender la observación a Retos y SVA indicando lo aplicado en cada caso, sólo cuando el servicio lo registre.
- Anchura del visor ≈800 px: OK.
Pendientes de respuesta: sondeo 30 s vs 15 s y tope de espera (punto 1). Ejecución: `pruebas/coordinacion-ronda37.md`.
