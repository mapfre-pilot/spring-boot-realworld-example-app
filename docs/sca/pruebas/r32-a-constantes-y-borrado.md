# R32-A — Constantes nuevas y borrado de objetos sin uso en SCA2

Entorno TEST (mapfrespain-test), aplicación SCA2 `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`. Origen: `docs/sca/54-...` y `docs/sca/pruebas/coordinacion-ronda32.md`.

## Fase 1 — Constantes creadas (26-10-2026)

Método: inventario de las 148 constantes de SCA2 y de las 8.015 del entorno (los nombres de constante son globales) para detectar duplicados por nombre o valor; alta por LCP (`POST /constants`, carpeta `SCA2 Rules and Constants` `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050135`, aplicación SCA2); relectura de cada una (nombre, tipo, valor, no múltiple) y comprobación de que figura en la aplicación: **57/57 correctas**, versión 1.

| # | Constante | UUID | Tipo | Valor | Versión |
|---|---|---|---|---|---|
| 1 | `SCA2_TXT_PERFIL_CE_RM` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623884` | TEXT | `CE_RM` | 1 |
| 2 | `SCA2_TXT_PERFIL_CE_MF_SI24` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623890` | TEXT | `CE_MF_SI24` | 1 |
| 3 | `SCA2_TXT_PERFIL_CE_MF_RECIBOS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623896` | TEXT | `CE_MF_RECIBOS` | 1 |
| 4 | `SCA2_TXT_PERFIL_CE_MF_BK` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623902` | TEXT | `CE_MF_BK` | 1 |
| 5 | `SCA2_TXT_PERFIL_CE_MF_CONTROL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623908` | TEXT | `CE_MF_CONTROL` | 1 |
| 6 | `SCA2_TXT_PERFIL_CE_MF_CENTRAL_AT` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623914` | TEXT | `CE_MF_CENTRAL_AT` | 1 |
| 7 | `SCA2_TXT_PERFIL_CE_RM_DT` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623920` | TEXT | `CE_RM_DT` | 1 |
| 8 | `SCA2_TXT_SUBPERFIL_CE_RM_OFICINA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623926` | TEXT | `CE_RM_OFICINA` | 1 |
| 9 | `SCA2_TXT_SUBPERFIL_CE_RM_AGENTE` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623932` | TEXT | `CE_RM_AGENTE` | 1 |
| 10 | `SCA2_TXT_SUBPERFIL_CE_MF_SI24_EXPERTO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623938` | TEXT | `CE_MF_SI24_EXPERTO` | 1 |
| 11 | `SCA2_TXT_SUBPERFIL_CE_MF_SI24_FRONT` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623944` | TEXT | `CE_MF_SI24_FRONT` | 1 |
| 12 | `SCA2_TXT_SUBPERFIL_CE_MF_SI24_TECNICO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623950` | TEXT | `CE_MF_SI24_TECNICO` | 1 |
| 13 | `SCA2_TXT_SUBPERFIL_CE_MF_SI24_SA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623956` | TEXT | `CE_MF_SI24_SA` | 1 |
| 14 | `SCA2_TXT_SUBPERFIL_CE_MF_SI24_CENTRAL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623962` | TEXT | `CE_MF_SI24_CENTRAL` | 1 |
| 15 | `SCA2_TXT_SUBPERFIL_CE_MF_BK_EXPERTO_SI24` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623968` | TEXT | `CE_MF_BK_EXPERTO_SI24` | 1 |
| 16 | `SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCC` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623974` | TEXT | `CE_MF_RECIBOS_CCC` | 1 |
| 17 | `SCA2_TXT_SUBPERFIL_CE_MF_RECIBOS_CCR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623980` | TEXT | `CE_MF_RECIBOS_CCR` | 1 |
| 18 | `SCA2_TXT_SUBPERFIL_CE_CONSULTA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623986` | TEXT | `CE_CONSULTA` | 1 |
| 19 | `SCA2_TXT_ESTADO_SOL_EN_ACCION` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623992` | TEXT | `EN_ACCION` | 1 |
| 20 | `SCA2_TXT_ESTADO_SOL_PDTE_MECANIZAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5623998` | TEXT | `PDTE_MECANIZAR` | 1 |
| 21 | `SCA2_TXT_ESTADO_SOL_PDTE_FINALIZAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624004` | TEXT | `PDTE_FINALIZAR` | 1 |
| 22 | `SCA2_TXT_ESTADO_SOL_PENDIENTE_AUTORIZACION` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624010` | TEXT | `PENDIENTE_AUTORIZACION` | 1 |
| 23 | `SCA2_TXT_ESTADO_SOL_FINALIZADA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624016` | TEXT | `FINALIZADA` | 1 |
| 24 | `SCA2_TXT_ESTADO_SOL_FINALIZADA_POSITIVO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624022` | TEXT | `FINALIZADA_POSITIVO` | 1 |
| 25 | `SCA2_TXT_ESTADO_SOL_FINALIZADA_SIN_ANULAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624028` | TEXT | `FINALIZADA_SIN_ANULAR` | 1 |
| 26 | `SCA2_TXT_ESTADO_SOL_FINALIZADA_NEG_CONTRA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624034` | TEXT | `FINALIZADA_NEG_CONTRA` | 1 |
| 27 | `SCA2_TXT_ESTADO_SOL_FINALIZADA_NO_REQ` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624040` | TEXT | `FINALIZADA_NO_REQ` | 1 |
| 28 | `SCA2_TXT_ESTADO_SOL_CADUCADA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624046` | TEXT | `CADUCADA` | 1 |
| 29 | `SCA2_TXT_ESTADO_SOL_CADUCADA_NEGATIVA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624052` | TEXT | `CADUCADA_NEGATIVA` | 1 |
| 30 | `SCA2_TXT_ESTADO_TAREA_PENDIENTE` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624058` | TEXT | `PENDIENTE` | 1 |
| 31 | `SCA2_TXT_ESTADO_TAREA_COMPLETADA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624064` | TEXT | `COMPLETADA` | 1 |
| 32 | `SCA2_TXT_ACCION_CONTRA_ANULAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624070` | TEXT | `CONTRA ANULAR` | 1 |
| 33 | `SCA2_TXT_ACCION_CONTRAANULAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624076` | TEXT | `CONTRAANULAR` | 1 |
| 34 | `SCA2_TXT_ACCION_MECANIZAR` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624082` | TEXT | `MECANIZAR` | 1 |
| 35 | `SCA2_TXT_ACCION_AUTORIZACION` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624088` | TEXT | `AUTORIZACION` | 1 |
| 36 | `SCA2_TXT_ACCION_ACCIONES_ADMINISTRATIVAS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624094` | TEXT | `ACCIONES ADMINISTRATIVAS` | 1 |
| 37 | `SCA2_TXT_ACCION_VENCIMIENTO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624100` | TEXT | `VENCIMIENTO` | 1 |
| 38 | `SCA2_TXT_TIPO_GESTION_ACCADM` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624106` | TEXT | `ACCADM` | 1 |
| 39 | `SCA2_TXT_TIPO_GESTION_CA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624112` | TEXT | `CA` | 1 |
| 40 | `SCA2_TXT_TIPO_GESTION_AU` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624118` | TEXT | `AU` | 1 |
| 41 | `SCA2_TXT_SGD_COD_DOCUMENTAL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624124` | TEXT | `DOCS_SCA_001` | 1 |
| 42 | `SCA2_TXT_SGD_QUERY_ARGUMENTOS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624130` | TEXT | `QUERY_SCA_AGD_001` | 1 |
| 43 | `SCA2_VAL_NSE_COD_ERROR_4022` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624136` | INTEGER | `4022` | 1 |
| 44 | `SCA2_TXT_PREFIJO_POLIZA_NSE_AUTOS` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624142` | TEXT | `200` | 1 |
| 45 | `SCA2_TXT_CANAL_SGO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624148` | TEXT | `SGO` | 1 |
| 46 | `SCA2_TXT_CAUSA_BAJA_TEMPORAL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624154` | TEXT | `BAJA TEMPORAL` | 1 |
| 47 | `SCA2_TXT_CAUSA_BAJA_VEHICULO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624160` | TEXT | `BAJA VEHICULO` | 1 |
| 48 | `SCA2_TXT_TIPO_OFICINA_DIRECTA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624166` | TEXT | `OFICINA_DIRECTA` | 1 |
| 49 | `SCA2_TXT_CONTACTO_VERTI` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624172` | TEXT | `VERTI` | 1 |
| 50 | `SCA2_VAL_COLOR_NEGRO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624178` | TEXT | `#000000` | 1 |
| 51 | `SCA2_VAL_COLOR_BLANCO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624184` | TEXT | `#FFFFFF` | 1 |
| 52 | `SCA2_VAL_COLOR_GRIS_CLARO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624190` | TEXT | `#F5F5F5` | 1 |
| 53 | `SCA2_VAL_COLOR_AZUL_CLARO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624196` | TEXT | `#6495ED` | 1 |
| 54 | `SCA2_VAL_COLOR_NARANJA` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624202` | TEXT | `#ff8000` | 1 |
| 55 | `SCA2_VAL_COLOR_NARANJA_OSCURO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624208` | TEXT | `#E46B15` | 1 |
| 56 | `SCA2_VAL_COLOR_ROJO_OSCURO` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624214` | TEXT | `#BE0F0F` | 1 |
| 57 | `SCA2_VAL_COLOR_AZUL` | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624220` | TEXT | `#0D82BD` | 1 |

### Reutilizadas / no creadas

| Constante | UUID | Situación |
|---|---|---|
| `SCA2_VAL_COLOR_GRIS_MEDIO` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050833` | Ya existía con `#9F9F9F`: se reutiliza. |
| `SCA2_VAL_COLOR_VERDE` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050845` | Ya existe con `#00E663` (no `#008C47`) y la usan `SCA2_DetalleSolicitud`, `SCA2_DetalleTareas` y `SCA2_D_ColorEstadoGestion`. **No se toca** (decisión de la sesión padre). |
| `SCA2_VAL_COLOR_VERDE_OSCURO` (nueva, nº 58) | `_a-0000f099-f136-8000-9d3c-011c48011c48_5624247` | Creada por decisión de la sesión padre: TEXT `#008C47`, versión 1, no múltiple, descripción «[SCA2] Color verde oscuro (#008C47). Distinto de SCA2_VAL_COLOR_VERDE (#00E663).». Es la que deben usar B/C/D para sustituir `#008C47`. |

### Notas para R32-B/C/D

- `SCA2_VAL_NSE_COD_ERROR_4022` (INTEGER): 4022 es el código que devuelve NSE en `SCA2_simularAnulacionPoliza` para póliza PRRA/deficitaria; `SCA2_obtenerMensajeErrorNSE` responde «La póliza es Deficitaria, irá directamente a anulación» y deja avanzar el alta si la póliza es PRRA y el mensaje contiene «PRRA». En SCA2 los literales son TEXTO (`"4022"`). Probado con una regla temporal (creada y borrada, 404 comprobado): `"4022" = cons!SCA2_VAL_NSE_COD_ERROR_4022` → `true`, pero `a!match(value: "4022", equals: cons!SCA2_VAL_NSE_COD_ERROR_4022)` → **no casa**; con `tostring(cons!…)` sí. En `a!match(equals:)`, `index(...)=` sobre listas o cualquier sitio donde se devuelva el código (p. ej. `code: "4022"`) hay que usar `tostring(cons!SCA2_VAL_NSE_COD_ERROR_4022)`.

## Fase 2 — Borrado de objetos sin uso (26-10-2026)

### Método

1. Para cada uno de los 80 objetos (66 reglas/interfaces/integraciones + 14 constantes) se consultaron sus dependientes con `GET /objects/dependents?object=<uuid>` de LCP (es el mismo índice que la pestaña «Dependientes» de Designer; devuelve objeto y línea, de todo el entorno, no solo de SCA2). Ningún objeto del lote está en la lista «CONSERVAR».
2. Se descartó como dependiente la propia aplicación SCA2 (contenedor). Si quedaba **cualquier** otro dependiente, el objeto **no se borra**.
3. Control adicional: búsqueda textual del nombre/UUID en la definición viva de todos los objetos de la app (incluidos los PM). Solo aparecieron menciones en **comentarios**: `SCA2_catCargarDesdeCore` en los comentarios de cabecera de `SCA2_CatMantenimiento` y `SCA2_catConstruirCarga` (no lo llaman), y `SCA2_monitorizarSolicitud` en `SCA2_monitorizarSolicitudRegla` (también del lote; se borró antes).
4. Justo antes de cada borrado: nueva consulta de dependientes, `GET` del objeto vivo y backup JSON local (`definición + dependientes`, fuera del repo, en el equipo de la sesión `~/r32a/backups/<nombre>.json`), `DELETE` y nueva lectura (debe dar 404).
5. No se ha modificado ningún objeto existente ni se ha borrado ningún modelo de proceso.

### Resultado: 66 borrados, 14 conservados por tener dependientes reales

Aplicación SCA2: 703 objetos tras la fase 1 → 638 tras el borrado (la cifra incluye los cambios de las sesiones paralelas B/C/D).

#### Borrados (versión = la última antes de borrar; después = borrado, `GET` → 404)

| # | Objeto | Tipo | UUID | Versión antes | DELETE | GET después |
|---|---|---|---|---|---|---|
| 1 | `SCA2_monitorizarSolicitudRegla` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063445` | 1 | 204 | 404 |
| 2 | `SCA2_AltaSolicitud` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055666` | 1 | 204 | 404 |
| 3 | `SCA2_BuscadorTablaEstrategicas` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052975` | 1 | 204 | 404 |
| 4 | `SCA2_BuscarSolicitudClientePoliza` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056373` | 1 | 204 | 404 |
| 5 | `SCA2_CalcularListaParCargaSGCOnline` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053017` | 1 | 204 | 404 |
| 6 | `SCA2_CargaGcOnLine` | INTEGRATION | `59a89edd-8628-4fd0-b348-47e7cc8b2ef1` | 1 | 204 | 404 |
| 7 | `SCA2_DatosCabecera` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053077` | 2 | 204 | 404 |
| 8 | `SCA2_DocumentosAccion` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056367` | 1 | 204 | 404 |
| 9 | `SCA2_GenerarSolicitudPopup` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053280` | 2 | 204 | 404 |
| 10 | `SCA2_GuardarDocumentos` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051350` | 1 | 204 | 404 |
| 11 | `SCA2_GuardarImprimir` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051788` | 1 | 204 | 404 |
| 12 | `SCA2_InterfazErrorDocumentos` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051254` | 1 | 204 | 404 |
| 13 | `SCA2_MensajeCancelarContraAnulacion` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052963` | 1 | 204 | 404 |
| 14 | `SCA2_ObtenerCredencialesConceptos` | INTEGRATION | `f60c299e-bcfd-4d5b-94a7-9715a2ff60cb` | 3 | 204 | 404 |
| 15 | `SCA2_ObtenerDocumentosArgumentos` | INTEGRATION | `163a6c42-8008-436c-b14a-4cf5471657c1` | 1 | 204 | 404 |
| 16 | `SCA2_ObtenerMapaPoliza` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063411` | 1 | 204 | 404 |
| 17 | `SCA2_S2_diagnosticoSolicitud` | EXPRESSION_RULE | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5483224` | 5 | 204 | 404 |
| 18 | `SCA2_TM_ObtenerTransaccion` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051440` | 1 | 204 | 404 |
| 19 | `SCA2_VisualizarDocumentoContraanular` | INTERFACE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051302` | 1 | 204 | 404 |
| 20 | `SCA2_aceptarAutorizacion` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052675` | 1 | 204 | 404 |
| 21 | `SCA2_bloquearPolizaEnCentral` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052753` | 1 | 204 | 404 |
| 22 | `SCA2_bloquearPolizaEnCentralEstrategicas` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051776` | 1 | 204 | 404 |
| 23 | `SCA2_calcularCaducidadNivel_test` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5603502` | 1 | 204 | 404 |
| 24 | `SCA2_calcularDocumentosASubir` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052759` | 1 | 204 | 404 |
| 25 | `SCA2_calculoSumasAseguradas` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052717` | 1 | 204 | 404 |
| 26 | `SCA2_catCargarDesdeCore` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5604046` | 1 | 204 | 404 |
| 27 | `SCA2_comprobarEliminarDocumentos` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051368` | 1 | 204 | 404 |
| 28 | `SCA2_configurarDatosContextoSolicitud` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052669` | 1 | 204 | 404 |
| 29 | `SCA2_construirEntradaReglas_test` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5603728` | 3 | 204 | 404 |
| 30 | `SCA2_esPropietarioProvisional` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5604058` | 2 | 204 | 404 |
| 31 | `SCA2_extraerCodClienteNIF` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051596` | 1 | 204 | 404 |
| 32 | `SCA2_gestionSegunOrigen` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051602` | 1 | 204 | 404 |
| 33 | `SCA2_guardarObservaciones` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051344` | 1 | 204 | 404 |
| 34 | `SCA2_guardarTrazabilidad` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063965` | 1 | 204 | 404 |
| 35 | `SCA2_liberarTarea` | EXPRESSION_RULE | `_a-0001f076-8f0a-8000-9d26-011c48011c48_5484899` | 1 | 204 | 404 |
| 36 | `SCA2_mapSalidaRespuestaAccAdm` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053414` | 1 | 204 | 404 |
| 37 | `SCA2_mapSalidaRespuestaAutorizacion` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053408` | 1 | 204 | 404 |
| 38 | `SCA2_mapSalidaRespuestaCA` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053420` | 1 | 204 | 404 |
| 39 | `SCA2_mapSalidaRespuestaFinalizatrCA` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051416` | 1 | 204 | 404 |
| 40 | `SCA2_mapearDatosDecidirAccionEstrategicas` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051782` | 1 | 204 | 404 |
| 41 | `SCA2_mensajeCorreoElectronico` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052735` | 1 | 204 | 404 |
| 42 | `SCA2_monitorizarSolicitud` | INTEGRATION | `3f1a0486-2ca9-41a3-b2f8-f13f870a2c11` | 1 | 204 | 404 |
| 43 | `SCA2_obtenerDescuentos` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052723` | 1 | 204 | 404 |
| 44 | `SCA2_obtenerFormaDeCobro` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051182` | 1 | 204 | 404 |
| 45 | `SCA2_obtenerOficinas` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051152` | 3 | 204 | 404 |
| 46 | `SCA2_obtenerOtrasSolicitudesCabecera` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051770` | 1 | 204 | 404 |
| 47 | `SCA2_obtenerSituacionRiesgo` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052729` | 1 | 204 | 404 |
| 48 | `SCA2_pmPorComando` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055466` | 1 | 204 | 404 |
| 49 | `SCA2_posponerTarea` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056361` | 2 | 204 | 404 |
| 50 | `SCA2_propietarioParaCaducidad` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5603576` | 1 | 204 | 404 |
| 51 | `SCA2_relanzarError` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055472` | 1 | 204 | 404 |
| 52 | `SCA2_setDatosGestionDatosPoliza` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052765` | 1 | 204 | 404 |
| 53 | `SCA2_setDatosGestionSGCEstratégicas` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053432` | 2 | 204 | 404 |
| 54 | `SCA2_simularAnulacionPolizaRest` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053268` | 1 | 204 | 404 |
| 55 | `SCA2_tmpDevinQuery` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5591913` | 157 | 204 | 404 |
| 56 | `SCA2_PM_BATCH_CADUCIDAD` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050575` | 1 | 204 | 404 |
| 57 | `SCA2_TXT_URL_HOST` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050785` | 1 | 204 | 404 |
| 58 | `SCA2_TXT_URL_LANZARDECISION_ANTIGUO` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050791` | 1 | 204 | 404 |
| 59 | `SCA2_PM_CMD_BARRIDO_CADUCIDAD` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20059118` | 1 | 204 | 404 |
| 60 | `SCA2_TXT_EMAIL_ENVIO_ERRORES` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050647` | 1 | 204 | 404 |
| 61 | `SCA2_REP_PROCESS_MECANIZACIONES` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050581` | 1 | 204 | 404 |
| 62 | `SCA2_PLANTILLA_CONTRATO_COMPRA_VENTA` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050569` | 1 | 204 | 404 |
| 63 | `SCA2_FLD_CLIENTE_TIPO_VALOR` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050299` | 1 | 204 | 404 |
| 64 | `SCA2_ARTIFACTS_FOLDER` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050155` | 1 | 204 | 404 |
| 65 | `SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION` | CONSTANT | `_a-0000f093-2064-8000-9d36-011c48011c48_5605082` | 1 | 204 | 404 |
| 66 | `SCA2_TEXTOS_GENERAR_SOLICITUD_POPUP_ESTRATEGICAS` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050587` | 1 | 204 | 404 |

#### No borrados: tienen dependientes reales (pendientes)

El análisis de la ronda 31 los daba sin consumidores, pero el índice de dependientes muestra llamadas reales desde reglas vivas que usan los procesos CMD. Quedan **pendientes** para una ronda que revise primero esos consumidores (fuera del lote R32-A: no se tocan).

| Objeto | Tipo | UUID | Dependientes (objeto > línea) |
|---|---|---|---|
| `SCA2_ObtenerDatosBasicosSolicitud` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051722` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 8); `SCA2_finalizarGestionSGC` (Línea: 25); `SCA2_notificarNivel` (Línea: 65) |
| `SCA2_ObtenerDatosPerfilesPca` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051716` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 9); `SCA2_finalizarGestionSGC` (Línea: 29); `SCA2_notificarNivel` (Línea: 69) |
| `SCA2_ObtenerDatosPolizaAutos` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051746` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 11); `SCA2_finalizarGestionSGC` (Línea: 31); `SCA2_notificarNivel` (Línea: 71) |
| `SCA2_ObtenerDatosPolizaHogar` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051740` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 10); `SCA2_finalizarGestionSGC` (Línea: 30); `SCA2_notificarNivel` (Línea: 70) |
| `SCA2_ObtenerDatosPolizaVida` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051764` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 14); `SCA2_finalizarGestionSGC` (Línea: 35); `SCA2_notificarNivel` (Línea: 75) |
| `SCA2_ObtenerDatosProductorBBDD` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051734` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 13); `SCA2_finalizarGestionSGC` (Línea: 34); `SCA2_notificarNivel` (Línea: 74) |
| `SCA2_ObtenerDatosSolicitud` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051728` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 7); `SCA2_finalizarGestionSGC` (Línea: 27); `SCA2_notificarNivel` (Línea: 67) |
| `SCA2_ObtenerNivelesCoberturaAutos` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051752` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 12); `SCA2_finalizarGestionSGC` (Línea: 33); `SCA2_notificarNivel` (Línea: 73) |
| `SCA2_RecordToCdtSolicitudAnulacion` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051758` | `SCA2_construirSolicitudAnulacionAnl` (Línea: 15); `SCA2_finalizarGestionSGC` (Línea: 26); `SCA2_notificarNivel` (Línea: 66) |
| `SCA2_renovarCacheCabecera` | EXPRESSION_RULE | `_a-0000f093-2064-8000-9d36-011c48011c48_5607622` | `SCA2_refrescarCacheCabecera` (Línea: 5) |
| `SCA2_setDatosGestionSGC` | EXPRESSION_RULE | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20052999` | `SCA2_finalizarGestionSGC` (Línea: 98); `SCA2_notificarNivel` (Línea: 167) |
| `SCA2_TXT_EMAIL_DUE_PARA_ALTITUDE` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050635` | `SCA2_notificarNivel` (Línea: 209); `SCA2_notificarNivel` (Línea: 210) |
| `SCA2_TXT_DUE_MENSAJE` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050623` | `SCA2_notificarNivel` (Línea: 222) |
| `SCA2_TXT_EMAIL_DUE_PARA_EXPERTOS` | CONSTANT | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050641` | `SCA2_notificarNivel` (Línea: 210) |

Quién usa a esos consumidores (comprobado, siguen vivos):

- `SCA2_finalizarGestionSGC` ← PM `SCA2 CMD CrearAccion`, `SCA2 CMD Finalizar`, `SCA2 CMD Mecanizar`.
- `SCA2_notificarNivel` ← PM `SCA2 CMD Decidir`.
- `SCA2_construirSolicitudAnulacionAnl` ← `SCA2_construirSolicitudAnulacionAnlTraducida` y PM `SCA2 CMD Mecanizar`.
- `SCA2_refrescarCacheCabecera` (Web API de la caché de cabecera) → usa `SCA2_renovarCacheCabecera`.

### Constantes que apuntan a modelos de proceso (no se ha borrado ningún PM)

| Constante | Apunta a | ¿Se usa la constante? | ¿Se usa el PM? | Acción |
|---|---|---|---|---|
| `SCA2_PM_CMD_BARRIDO_CADUCIDAD` | PM `SCA2 CMD BarridoCaducidad` | No | Solo lo referenciaba esta constante | Constante borrada. **PM candidato a revisar** (sin consumidores; puede arrancarse por programación/temporizador, no se borra). |
| `SCA2_PM_CMD_REGISTRAR_DESINCRONIZACION` | PM `SCA2 CMD RegistrarDesincronizacion` | No | Solo lo referenciaba esta constante | Constante borrada. **PM candidato** (sin consumidores; no se borra). |
| `SCA2_PM_BATCH_CADUCIDAD` (TEXT) | PM `SCA Batch Caducidad` (de **SCA**, no de SCA2) | No | Sí: `SCA Batch Caducidad Previo` | Constante borrada. El PM es de SCA: no se toca. |
| `SCA2_PM_CMD_MECANIZAR_NSE` | PM `SCA2 CMD MecanizarNSE` | Sí: `SCA2 CMD MarcarErrorRelanzado`, `SCA2 Batch Mecanizacion NSE` | Sí (vía constante) | No estaba en el lote: se conserva. |
| `SCA2_PM_ANL_FINALIZAR_MECANIZACION` | PM `ANL OS FinalizarMecanizacion` (de **ANL**) | Sí: `SCA2 CMD MecanizarNSE` | Sí: `SCA Batch Mecanizacion NSE` y `(2)` | No estaba en el lote: se conserva. |


### Regresión tras el borrado

**Pruebas de reglas (`POST /test`)**: no aplican. En R32-A no se ha modificado ninguna regla ni interfaz existente (solo se han creado constantes y borrado objetos sin dependientes), así que no hay salida «antes/después» que comparar. Las reglas borradas no se pueden ejecutar después del borrado; su definición queda en los backups.

**Prueba UI con solicitud nueva (grabada)** — usuario `JJGONZ2` (CE_RM), site `/suite/sites/sca2`:

| Paso | Resultado |
|---|---|
| Alta nueva Autos NSE, póliza `2002100432565`, observación «Regresión UI R32-A» | OK — solicitud **15788370** (las tres primeras pólizas candidatas tenían solicitudes abiertas y no se tocaron) |
| Tarea de Contra Anulación (creación asíncrona) | OK — se abre; cabecera y argumentos se renderizan |
| CA: argumento obligatorio «INCREMENTO PRIMA PLATINO» → NEGATIVO, carta generada, FINALIZAR | OK — «Los datos se han guardado correctamente»; siguiente gestión «Gestión Verti/vencimiento» (no tramitada, fuera de alcance) |
| Detalle desde el buscador | OK — alta finalizada, CA «Finalizada Negativa», observación del alta, argumentos y documentos («No hay documentos a mostrar») |
| Errores de expresión / regla no encontrada en alta, CA y detalle | Ninguno |

**Bandeja Errores**

- Página `/errores` del site: JJGONZ2 recibe «La página no existe o no tiene permiso para verla» (solo administradores; ya documentado).
- Por API (`SCA2_consultarErroresSolicitud`, `idSolicitud` nulo = todos, devuelve los 50 más recientes): para la solicitud nueva **15788370 no hay ningún error**.
- Aparecen 3 errores nuevos `DECISION_ERROR` (`SCA2 CMD Decidir` > «Consultar reglas», el motor de decisión devuelve `accion: ERROR`) de la solicitud **15788369**, que no es de esta prueba (otra sesión paralela). No se relacionan con el borrado: `SCA2 CMD Decidir` no referencia ningún objeto borrado (comprobado por dependientes y por texto) y en la solicitud de esta prueba Decidir funcionó y creó la CA. Es un error ya conocido: antes del borrado había 8 `DECISION_ERROR` del 20 y 21-10-2026 (15788161, 15788164, 15788200).

### Pendientes

1. 14 objetos del lote no borrados por tener dependientes reales (tabla de arriba). Para borrarlos habría que revisar antes `SCA2_finalizarGestionSGC`, `SCA2_notificarNivel`, `SCA2_construirSolicitudAnulacionAnl` y la Web API `SCA2_refrescarCacheCabecera`, que están fuera del lote R32-A.
2. PMs sin consumidores (candidatos, **no borrados**): `SCA2 CMD BarridoCaducidad` y `SCA2 CMD RegistrarDesincronizacion`. Antes de decidir hay que confirmar que no los arranca un temporizador o un proceso programado.
3. Comentarios desfasados que mencionan `SCA2_catCargarDesdeCore` (borrado) en `SCA2_CatMantenimiento` y `SCA2_catConstruirCarga`. Son solo comentarios y no afectan; no se tocan (fuera del lote).
4. Las 58 constantes nuevas aún no tienen consumidores: las usarán R32-B/C/D.
