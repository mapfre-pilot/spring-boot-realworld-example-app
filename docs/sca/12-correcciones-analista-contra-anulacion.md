# 12. Correcciones tras la revisión del analista funcional (Alta, Contra Anulación, documentos)

Entorno: **Appian TEST** (`mapfrespain-test`), aplicación `SCA2`, cambios aplicados por LCP API (`/interfaces`,
`/expression-rules`, `/integrations`, `/process-models`). Referencia funcional: **SCA TEST**. No se ha tocado ningún
objeto de SCA ni SCAC.

Pólizas/solicitudes de prueba: NSE `2002100648994` → solicitud `15787672` (gestión CA incompleta `43704742`);
NSE `2002100649006` → `15787673`; Autemis `164300869`.

## 12.1 Hallazgos del analista y veredicto

| # | Hallazgo | Veredicto | Cambio en SCA2 |
|---|---|---|---|
| 1 | Alta de una 2ª solicitud con otra póliza carga los datos de la 1ª | Defecto SCA2 (locales del Alta no se reinician al cambiar `ri!numPoliza`) | `SCA2_AltaSolicitudPage`: locales del formulario con `a!refreshVariable(refreshOnVarChange: ri!numPoliza)`; `SCA2_Buscador` limpia `ri!numPoliza` al pulsar ALTA |
| 2 | Cancelar limpia pero no vuelve al listado | Defecto SCA2 | Cancelar hace `a!save(ri!vista,"BUSQUEDA")`, `a!save(ri!numPoliza,null)` además de limpiar locales; el popup limpia también `ri!polizaAlta` |
| 3 | Tras el Alta debe ir directo a la acción decidida (Contra Anular), no al listado con RETOMAR | Defecto SCA2 | El Alta espera (polling `local!estadoSolNueva` / `local!tareaNueva`) a que `CMD Decidir`+`CMD CrearAccion` creen la tarea y abre la acción; el botón OK sólo se muestra cuando `local!decisionLista` |
| 4 | Mensaje de Guardar en la parte inferior | Ya conforme | Mensaje inferior para éxito/error, se mantiene |
| 5 | Antigüedad de póliza | **No divergente**: `SCA_obtenerDatosCabecera` y `SCA2_obtenerDatosCabecera` comparten la fórmula (`year(now())-year(fecefecini)`) y devuelven el mismo valor (`5 años` para `2002100648994`, `14 años` para `164300869`) | Sin cambio en SCA2; si el valor es incorrecto es defecto compartido con SCA |
| 6 | Detalle: controlar estado de gestión y solicitud vía CORE | Faltaba en SCA2 el Alta de gestión CORE al crear la acción | Regla `SCA2_altaGestionCore` + nodo `Alta gestion CORE` en `SCA2 CMD CrearAccion` (ahora recibe `accion: pv!accionCalc`); `IContraAnularPCA` responde `respuesta=true` con perfiles persistidos (`CE_RM`/`CE_RM_OFICINA`, cía `41`) |
| 7 | Argumentarios no cargan | Defecto SCA2 de mapeo: el GAIA `consultarListadoArgumentos` devuelve `listadoArgumentos[]` con `mcaEstado`, `usuario`, `fecEjecutado` (no `MSSConsultarListadoArgumentos.listaArgumentos` ni `codTipEstArgumento`) | `SCA2_ContraAnulacionOpciones` lee las claves reales; `compania` dinámica (`1` Autemis / `3` Vida / `41` NSE) y `codCiaUsuario` dinámico; se usa la gestión **INCOMPLETA** (no la FINALIZADA, que da `ORA-02291`) |
| 8 | Estado de cada argumento (aplicado +, aplicado −, sin acción) | Cubierto por `mcaEstado` (`0` sin acción, `1` positivo, `2` negativo) | Columna estado alimentada por `mcaEstado` |
| 9 | Bloque "documento no disponible" como si fuera PDF | Defecto SCA2 | `SCA2_VisualizarDocumentoContraanularEstrategicas`: visor sólo si `a!isNotNullOrEmpty(ri!document)`; `a!deleteDocument` protegido contra `null` |
| 10 | Desplegable compañía contraria / tipo catalogación da error | Defecto SCA2 (`value` Text `"2"` vs `choiceValues` enteros) | `SCA2_ContraAnulacionCompaniaCatalogacion`: `value: tointeger(...)` |
| 11 | Documentos por motivo (`2002100649006`) y carga individual con tipo documental Documentum | Flujo de subida a GD **no existía** en SCA2 (`CMD CompletarAccion` no subía nada) | Ver 12.2 |

## 12.2 Subida de documentos al gestor documental (paridad con `SCA Subir Docs Documentum BBDD`)

SCA sube los adjuntos en el PM `SCA Subir Docs Documentum BBDD` (por documento: `SCA_altaDocumento` → REST
`documents-web/api/sgd/1.0/documents` multipart `file`+`body`, y después `SCA_modificarCrearDocumento{Dni,sCarta,sAdmin}`).
En SCA2 se ha replicado de forma atómica (sin PM adicional, un único nodo de script en `CMD CompletarAccion`):

- Integración `SCA2_altaDocumentoIntegracion` (copia de `SCAC_altaDocumentoIntegracion`, mismo connected system,
  `relativePath` entrecomillado, `Host: webservices.pre.mapfre.net`). El `contentType` de la parte `file` es
  `if(a!isNullOrEmpty(ri!file),"application/octet-stream","auto-detect")` porque LCP valida el body con inputs nulos.
- Regla `SCA2_altaDocumento(file, random, tipoDocumento, accion, codSolicitud)`: mismas plantillas que SCA
  (`DOCS_SCA_JUVN/JUBA/IDPE/SOAN/AUAN_0001`), metadata `codigo_expediente`, `fecha_doc`, `object_name`; devuelve
  `{success, r_object_id, object_name, template}` o `{success:false, error}`.
- Regla `SCA2_subirDocumentosGD(codSolicitud, listaNombreDocs[], tipoGestion, nuuma)`: recorre `"<idDoc>_<tipoDoc>"`,
  omite documentos inexistentes en Appian (`CMP_existeObjeto`), sube a GD y registra en BBDD (`7`→Dni, `6`→Carta,
  resto→Admin). Devuelve `{success, numDocumentos, numSubidos, resultados[], mensaje}`.
  Test: lista vacía → `success=true`; `999999999_7` → omitido, `success=true`.
- PM `SCA2 CMD CompletarAccion`: `Write PDTE_FINALIZAR (7)` → **`Subir documentos GD (310)`** → `¿Docs GD ok? (311)`
  → `Capturar error documentos (312)` → `Write Error (199)` (relanzable) / default → `300`. Nueva pv `docsResult`.
- Interfaces: `SCA2_ContraAnulacionOpciones` (REVISIÓN y FINALIZAR), `SCA2_AccionesAdministrativasPrincipal` (FINALIZAR)
  y `SCA2_AnulacionFueraNormaPrincipal` (FINALIZAR) añaden a `resultado` `listaNombreDocs`, `tipoGestion`
  (`CA`/`ACCADM`/`AUT`) y `nuuma`. CANCELAR no sube documentos.

**Bloqueo compartido**: `SCA_consultarDocumentos` y `SCA2_consultarDocumentos` devuelven `{"MSSConsultarDocumentos": null}`
para `15787672` y `15787673`, por lo que el listado de documentos configurados por motivo no puede validarse punta a
punta ni en SCA ni en SCA2. La subida real a Documentum queda por verificar cuando el servicio devuelva datos.

## 12.3 Verificación

Todos los objetos escritos se han releído (GET) y probado con `/test` (HTTP 200, `error: null`):
`SCA2_AltaSolicitudPage`, `SCA2_ContraAnulacionCompaniaCatalogacion`, `SCA2_VisualizarDocumentoContraanularEstrategicas`,
`SCA2_ContraAnulacionOpciones` (`15787672`/tarea 14), `SCA2_AccionesAdministrativasPrincipal`,
`SCA2_AnulacionFueraNormaPrincipal`, `SCA2_subirDocumentosGD`; PMs `CMD CrearAccion` (27 nodos) y
`CMD CompletarAccion` (31 nodos) releídos con la topología esperada. Pendiente: prueba UI real (2ª alta, Cancelar,
salto directo a Contra Anular, POSITIVO/NEGATIVO/FINALIZAR y subida real de documentos).

## 12.4 Prueba UI comparativa SCA vs SCA2 (TEST, 30/09/2026)

### Correcciones validadas

| Área | Resultado en SCA2 |
|---|---|
| Alta | `SCA2_AltaSolicitudPage`: estilos de texto enriquecido `ERROR`/`SUCCESS` sustituidos por `STRONG` y colores `NEGATIVE`/`POSITIVE`. `SCA2_construirContextoAlta` recibe `descCausa` y `SCA2 CMD Alta` persiste `desccausa`. |
| Solicitud | `SCA2_SolicitudAnulacion`: fecha de impresión desde `fecImpresion` de cabecera CORE; compañía contraria vía `SCA2_catalogFilteredIntegracion` (`3247` → `ALLIANZ DIRECT`). |
| Argumentarios | `SCA2_ContraAnulacionOpciones`: `lineaNegocio` numérico. Con `"wAutemis"`, el servicio de argumentos responde `409`/`ORA-00936`; con `"1"`, responde HTTP 200 y devuelve 8 argumentos para `15787692`. |
| Antigüedad | SCA y SCA2 muestran 14 años para la póliza `164300869`. |

### Tarjeta Contra Anulación

`SCA2_DetalleSolicitud` queda alineada con `SCA_DetalleAnulacionContraAnulacion`: argumentos históricos de
`SCA2_consultaDetalleGestion(...).MSSConsultaDetalleGestion.listadoContraAnul`; estado de argumento
`codTpEstArgumento=2` (Negativo, rojo), `1` (Positivo, verde) y otros (Pendiente, gris), igual que en SCA.
El estado y las fechas de la tarjeta proceden de la gestión CORE (`accionRealizada=2`), no de la tarea SCA2.
También muestra el título «Contra Anulacion», nivel/perfil/grupo/nuuma de `infoUsuario` CORE, paginación de 10,
columna «Detalle suplemento» (ojo solo para `txtApliArgumento=WAUTEMIS`), documentos presentados por el cliente
con visor GD y observaciones de la gestión. RETOMAR/REASIGNAR/Completar siguen ligados a la tarea SCA2.

| Solicitud | Origen | Argumentos | Gestión CORE | Usuario CORE | Comparación |
|---|---|---:|---|---|---|
| `15787692` | Autemis | 12, todos Pendiente | Incompleta; inicio `30/09/2026 10:07:56`; fin `-` | `1` / `RED MAPFRE` / `OFICINA` / `JJGONZ2` | Igual a SCA |
| `15787672` | NSE | 11, todos Pendiente | Incompleta; inicio `30/09/2026 09:00:29`; fin `-` | `1` / `RED MAPFRE` / `OFICINA` / `JJGONZ2` | Igual a SCA |

### Observaciones y pendientes

1. En `15787672`, la tarea CA SCA2 está COMPLETADA y la solicitud está en `PDTE_MECANIZAR`, mientras la gestión
   CORE `43704742` sigue INCOMPLETA desde `30/09 09:00:29`. **Hipótesis pendiente de verificar:** la gestión se
   reabrió por una llamada directa de prueba a `IContraAnularPCA` el 30/09; el nodo 301 «Finalizar CA PCA» de
   `CMD CompletarAccion` solo cierra CORE cuando `resultado.finalizadoCA=true`. Falta comprobarlo con un FINALIZAR real.
2. El ojo «Detalle suplemento» no muestra contenido ni en SCA ni en SCA2: SCA solo guarda `local!showPopup`, que
   no se renderiza; SCA2 replica únicamente el control visual.
3. El orden de los argumentos puede variar entre cargas en ambas aplicaciones.
4. RETOMAR aparece en SCA2 para `15787692` porque hay una tarea pendiente.
5. `consultarDocumentos` devuelve `MSSConsultarDocumentos=null` para `15787672` y `15787673` tanto en SCA como en
   SCA2; la subida real a Documentum no está verificada punta a punta.
6. Sin probar: POSITIVO/NEGATIVO/FINALIZAR reales, REASIGNAR, alta nueva tras los fixes (las pólizas de prueba ya
   tienen solicitud abierta), Mecanización, VERTI/Vida y caducidad.

Grabaciones conservadas como artefactos locales (no versionadas): `sca-comparison`, `sca-delta-retest`,
`sca-detalle-arguments`, `sca-core-card-retest`, `sca-v14-card-comparison`.
