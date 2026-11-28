# 83 · Visibilidad del contrato de compraventa sin traspaso en SCA2

**Publicado en Appian TEST el 27/11/2026.** Antes de publicar se comprobó que `sca2_anulaciones.sca2_adjunto_compraventa` existía como tabla, con seis columnas y PK `ID`. [El DDL](sql/sca2-adjunto-compraventa.sql) se entregó a BD; no se ejecutó desde Appian. No se modificaron DEV, SCA, SCAC, CORE ni SGD.

## Causa

Caso del analista: póliza `2002400356323`, solicitud `15789366`, tarea AA `1010`, gestión CORE `43709539`. En la instancia `11350500` de **SCA2 CMD CompletarAccion v61**, el nodo 310 recibió los tres ficheros. **SCA2_subirDocumentosGD v12** devuelve `numDocumentos: 3`, `numSubidos: 2`: el `591785` (tipo 9) queda con `omitido: true` porque no se admite en SGD/CORE para AA. **SCA2_consultarDocumentos v2** devuelve exclusivamente los tipos 2 (`0900ab4481a3beed`) y 7 (`0900ab4481a3beef`); esa es la lista que muestra la tarjeta.

**SCA2_AnulacionFueraNormaPrincipal v26** reutiliza **SCA2_AccionesAdministrativasDocumentacion v12** y, al aceptar, envía `tipoGestion: "AUT"`, `codEstado: "2"` y los adjuntos al mismo CMD. El XOR 6 dirige la aceptación al 310. El tipo 9 tampoco está entre los tipos subibles para AUT (7 y 8). No se encontró un ejemplo real de AUT con tipo 9 en las cuatro autorizaciones revisadas (`15788303`, `15788754`, `15788855`, `15789357`); la omisión en AUT se deduce del flujo y la lista de tipos, no de una instancia con el fichero. La tarjeta de Autorización debe mostrar **documentos**, no argumentos.

## Objetos publicados y paquete

Paquete existente **SCA2 Caducidad TM 27-11-2026** (`230be394-bb39-4d0c-bb48-e7966391839f`): conserva **SCA2 CMD Caducar** y **SCA2 CMD Encolar Caducidad TM**; se añadieron los ocho objetos siguientes. El paquete tiene diez objetos y no contiene scripts de BD. Antes de importarlo en otro entorno, BD debe crear la tabla allí; la fila de recuperación tampoco se exporta con el paquete.

| Objeto | UUID | Versión en TEST |
|---|---|---|
| SCA2 Adjunto Compraventa | `a2953258-c308-418f-b5b3-1b3fd024ad92` | 2 |
| SCA2_consultarAdjuntosCompraventa | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5820675` | 1 |
| SCA2_filaAdjuntoCompraventa | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5820681` | 1 |
| SCA2_prepararAdjuntoCompraventa | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5820685` | 1 |
| SCA2_AccionesAdministrativasPrincipal | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056429` | 28 (antes 27) |
| SCA2 CMD CompletarAccion | `0000f06f-1307-8000-65b1-7f0000014e7a` | 63.0 (antes 62.0) |
| SCA2_DetalleSolicitud | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 82 (antes 80) |
| SCA2_DetalleSolicitud_HistPiloto | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5789444` | 5 (antes 3) |

Copias previas de las interfaces y del modelo (borrador y publicado) en `~/memory/appian_91b2ca/files/sca2-adjunto-compraventa/`.

### Record y reglas

**SCA2 Adjunto Compraventa** usa la tabla existente del origen **SCA2 DataBase AWS** (`createTable: false`). Una fila por solicitud, acción y gestión; el tipo de documento 9 es implícito. Campos: `ID → id` (Integer, PK generada), `ID_SOLICITUD → idSolicitud` (Text), `TIPO_GESTION → tipoGestion` (Text, `ACCADM`/`AUT`), `NUM_GESTION → numGestion` (Text), `ID_DOCUMENTO_APPIAN → idDocumentoAppian` (Integer) y `FECHA_ENTREGA → fechaEntrega` (Date). El record tiene la misma seguridad de objeto que SCA2 Tarea (lectura a SCA2 Users; sin acceso por defecto). No se cambió la seguridad de la carpeta o del fichero.

Las [reglas SAIL](sail/83-adjunto-compraventa/) usan los UUID de TEST. Inputs:

- `SCA2_consultarAdjuntosCompraventa` y `SCA2_filaAdjuntoCompraventa`: `idSolicitud`, `tipoGestion`, `numGestion` (Text).
- `SCA2_prepararAdjuntoCompraventa`: `idSolicitud` (Text), `resultado`, `docsResult` (Any Type), `fechaEntrega` (Date).

### Escritura al completar AA o aceptar AUT

1. **SCA2_AccionesAdministrativasPrincipal v28** añade `codGestion: local!numGestion` al mapa `resultado` del CMD en el botón de finalización. AUT ya envía `codGestion: local!codGestion`; no cambió su interfaz principal.
2. **SCA2 CMD CompletarAccion v63.0** conserva el nodo 310 y la salida de error **311 → 312**. En la ruta de éxito, **380 Preparar adjunto compraventa** asigna `pv!adjuntoCompraventa` (tipo record) con `rule!SCA2_prepararAdjuntoCompraventa(idSolicitud: pv!idSolicitud, resultado: pv!resultado, docsResult: pv!docsResult, fechaEntrega: today())`. La regla recoge exclusivamente el tipo 9 omitido; la consulta de clave funcional aporta el ID si se actualiza y evita reescribir el mismo fichero. Si hay varios resultados tipo 9, toma el último, conforme al único contrato activo por gestión.
3. **381 ¿Guardar compraventa?** salta la escritura sin registro. Sin solicitud o gestión, **383 Capturar falta de clave compraventa** envía `ADJUNTO_SIN_CLAVE` a la vía de error **199**, sin continuar la finalización. En otro caso, **382 Guardar adjunto compraventa** (Write Records) escribe el record y pausa la instancia si falla. Se configuró **SCA2 Alertas** y se conservó el borrado automático tras un día. Si falla la escritura, se puede reintentar el nodo sin volver a ejecutar 310; una colisión de clave exige preparar de nuevo el registro.
4. **384 Continuar tras documentos** conserva la salida AA original hacia **11** y la salida por defecto hacia **300**. Desde 300, AUT conserva **302 Aceptar Autorizacion** y las transiciones anteriores. No se cambian los tipos enviados a SGD/CORE.

### Lectura en ambas variantes de detalle

Se aplicó el mismo cambio en **SCA2_DetalleSolicitud v82** y **SCA2_DetalleSolicitud_HistPiloto v5**:

1. Después de `local!docsCA`, añadir:

   ```sail
   local!filaCompraventa: if(
     and(local!abierta, or(local!esAA, local!esAut)),
     rule!SCA2_filaAdjuntoCompraventa(
       idSolicitud: tostring(ri!idSolicitud),
       tipoGestion: if(local!esAA, "ACCADM", "AUT"),
       numGestion: tostring(local!numGestionCA)
     ),
     {}
   ),
   ```

   Usar el número CORE resuelto para esa tarjeta, no el identificador Appian de la tarea ni el número de gestión de otra acción. No buscar el adjunto si falta ese número.
2. Con adjunto Appian, la rejilla **Documentos presentados por el cliente** combina las filas y las convierte a una lista de diccionarios; el grid no acepta la lista de variantes que devuelve `a!flatten` por sí sola. Sin adjunto deja intacto `local!docsCA`. La marca `origenAppian` aplica la etiqueta **Documento de compraventa sin traspaso del seguro** antes de las reglas de etiquetado de CORE, también en AUT.
3. En el botón del ojo, usar la misma marca para elegir el `saveInto`: para la fila Appian, `{a!save(local!docVis, todocument(tointeger(index(fv!row, "idDocumento", null)))), a!save(local!verDoc, true)}`; para CORE, mantener el `a!startProcess` de **SCA2_PM_OBTENER_DOCUMENTO_GD**. Reutilizar la sección existente **SCA2_VisualizarDocumento** y su cierre. No tocar el listado de argumentos de Contra Anulación.

### Recuperación puntual y verificación en TEST

- **Recuperación:** el record estaba vacío. La API de datos de records de Appian insertó `1,15789366,ACCADM,43709539,591785,2026-11-25`, sin SQL directo ni repetir la gestión.
- **AA:** en el site TEST, la tarjeta de `15789366` mostró gestoría, DNI y el contrato. El botón del ojo abrió el PDF de una página dentro del visor de Appian. La comprobación fue con la cuenta técnica; no valida permisos de un usuario funcional.
- **AUT:** en la tarjeta de la autorización de prueba ya aceptada `15787725` (gestión `43704885`), un registro AUT temporal con el PDF de plantilla mostró DNI, Autorización y la compraventa. Se eliminó el registro temporal y se releyó la tabla: solo quedó la recuperación de AA. No se cambió la solicitud ni se pulsó Finalizar.
- **Reglas y detalle:** la preparación de AUT aceptada devolvió el record esperado; la de AUT no aceptada y la del mismo contrato AA devolvieron una lista vacía. El render independiente de `SCA2_DetalleSolicitud_HistPiloto v5` terminó sin error.
- **No ejecutado:** completar de extremo a extremo una AA o AUT nueva, para no consumir pólizas. La ejecución del nodo 382, su pausa/reintento ante fallo y la recepción de alertas no quedaron probadas en un flujo de negocio.

Capturas de ambas tarjetas y del visor en `~/sca2-doc-investigation/`: `sca2-compraventa-aa-tres-documentos.png`, `sca2-compraventa-aa-visor.png` y `sca2-compraventa-aut-fixture.png`. El DDL ya se había validado localmente en PostgreSQL 14.25: creación, segunda ejecución sin cambios y rechazo tanto sin tabla viva como ante una tabla preexistente de otra procedencia.
