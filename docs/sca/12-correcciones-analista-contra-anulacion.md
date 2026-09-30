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
