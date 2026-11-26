# 83 · Visibilidad del contrato de compraventa sin traspaso en SCA2

**Preparado para TEST, pendiente de BD.** BD debe ejecutar [el DDL](sql/sca2-adjunto-compraventa.sql) completo en Aurora PostgreSQL 14, con parada al primer error. No incluye datos ni modifica tablas existentes. No aplicar los cambios de Appian hasta comprobar que la tabla existe en TEST. No se modifica DEV, SCA, SCAC, CORE ni SGD.

## Causa

Caso del analista: póliza `2002400356323`, solicitud `15789366`, tarea AA `1010`, gestión CORE `43709539`. En la instancia `11350500` de **SCA2 CMD CompletarAccion v61**, el nodo 310 recibió los tres ficheros. **SCA2_subirDocumentosGD v12** devuelve `numDocumentos: 3`, `numSubidos: 2`: el `591785` (tipo 9) queda con `omitido: true` porque no se admite en SGD/CORE para AA. **SCA2_consultarDocumentos v2** devuelve exclusivamente los tipos 2 (`0900ab4481a3beed`) y 7 (`0900ab4481a3beef`); esa es la lista que muestra la tarjeta.

**SCA2_AnulacionFueraNormaPrincipal v26** reutiliza **SCA2_AccionesAdministrativasDocumentacion v12** y, al aceptar, envía `tipoGestion: "AUT"`, `codEstado: "2"` y los adjuntos al mismo CMD. El XOR 6 dirige la aceptación al 310. El tipo 9 tampoco está entre los tipos subibles para AUT (7 y 8). No se encontró un ejemplo real de AUT con tipo 9 en las cuatro autorizaciones revisadas (`15788303`, `15788754`, `15788855`, `15789357`); la omisión en AUT se deduce del flujo y la lista de tipos, no de una instancia con el fichero. La tarjeta de Autorización debe mostrar **documentos**, no argumentos.

## Cambios preparados

### Record y reglas

Crear **SCA2 Adjunto Compraventa** en TEST sobre la tabla existente `sca2_anulaciones.sca2_adjunto_compraventa` del origen **SCA2 DataBase AWS**. Una fila por solicitud, acción y gestión; el tipo de documento es siempre 9 y no se repite en la tabla. Mapear `ID → id` (Integer, PK generada), `ID_SOLICITUD → idSolicitud` (Text), `TIPO_GESTION → tipoGestion` (Text, `ACCADM`/`AUT`), `NUM_GESTION → numGestion` (Text), `ID_DOCUMENTO_APPIAN → idDocumentoAppian` (Integer) y `FECHA_ENTREGA → fechaEntrega` (Date). Alinear la seguridad de consulta con los lectores del detalle SCA2, la escritura con la identidad del CMD y comprobar el acceso efectivo al documento con un usuario funcional; no otorgar permisos generales a la carpeta.

Los [borradores SAIL](sail/83-adjunto-compraventa/) usan marcadores de UUID (reemplazar con los del record creado antes de validar). Inputs:

- `SCA2_consultarAdjuntosCompraventa` y `SCA2_filaAdjuntoCompraventa`: `idSolicitud`, `tipoGestion`, `numGestion` (Text).
- `SCA2_prepararAdjuntoCompraventa`: `idSolicitud` (Text), `resultado`, `docsResult` (Any Type), `fechaEntrega` (Date).

### Escritura al completar AA o aceptar AUT

1. En **SCA2_AccionesAdministrativasPrincipal v27**, añadir `codGestion: local!numGestion` al mapa `resultado` del CMD en el botón de finalización (junto a `listaNombreDocs`). AUT ya envía `codGestion: local!codGestion`. No cambiar la subida ni las llamadas existentes de las interfaces.
2. En **SCA2 CMD CompletarAccion v61**, mantener el nodo 310 y la salida de error **311 → 312**. En las salidas de éxito hacia **11 Write Decidir** (AA) y **300 Llamada cierre?** (incluye AUT aceptada), interponer un tramo común: **Preparar adjunto compraventa** asigna `pv!adjuntoCompraventa` (tipo record) con `rule!SCA2_prepararAdjuntoCompraventa(idSolicitud: tostring(pv!idSolicitud), resultado: pv!resultado, docsResult: pv!docsResult, fechaEntrega: today())`. La regla recoge exclusivamente el tipo 9 omitido; la consulta de clave funcional aporta el ID si se actualiza y evita reescribir el mismo fichero. Si hay varios resultados tipo 9, toma el último, conforme al único contrato activo por gestión.
3. El XOR **¿Hay adjunto por guardar?** salta la escritura si la preparación no devuelve registro. Si devuelve uno sin solicitud/gestión, registrar un error explícito (`ADJUNTO_SIN_CLAVE`) por la vía de **199** (`wrErr`, `wrNodo`, `wrCodigo`, `wrErrMsg`); no escribir ni continuar la finalización. En otro caso, **Write Records · Guardar adjunto compraventa** escribe `pv!adjuntoCompraventa`. Configurar pausa al error y alertas a **SCA2 alertas**: un fallo de escritura no debe alcanzar 11 ni 300. Reintentar ese nodo, sin volver a ejecutar 310; ante una colisión de la clave única, volver a preparar el record antes de reintentar.
4. Tanto la salida sin cambios como la salida correcta del Write Records van a **Continuar tras documentos**, que conserva la condición AA original de 311 hacia 11 y la salida por defecto hacia 300. Desde 300, AUT conserva **302 Aceptar Autorizacion** y las demás transiciones actuales. Mantener encadenamiento, alertas y autoeliminación de instancias cumplido un día. No cambiar los tipos enviados a SGD/CORE.

### Lectura en ambas variantes de detalle

Aplicar el mismo cambio en **SCA2_DetalleSolicitud v80** y **SCA2_DetalleSolicitud_HistPiloto v3**:

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
2. En la rejilla **Documentos presentados por el cliente**, cambiar `data: local!docsCA` por `data: a!flatten({local!docsCA, local!filaCompraventa})`. En la columna de tipo, anteponer `if(a!defaultValue(index(fv!row, "origenAppian", false), false), "Documento de compraventa sin traspaso del seguro", <expresión actual>)` al tratamiento especial de AUT; mantener todas las etiquetas actuales de las filas CORE.
3. En el botón del ojo, usar la misma marca para elegir el `saveInto`: para la fila Appian, `{a!save(local!docVis, todocument(tointeger(index(fv!row, "idDocumento", null)))), a!save(local!verDoc, true)}`; para CORE, mantener el `a!startProcess` de **SCA2_PM_OBTENER_DOCUMENTO_GD**. Reutilizar la sección existente **SCA2_VisualizarDocumento** y su cierre. No tocar el listado de argumentos de Contra Anulación.

### Recuperación puntual y verificación en TEST

- Antes de publicar, respaldar las versiones vivas y volver a comprobar los nodos y puntos de integración si cambiaron. Verificar que `591785` sigue consolidado y es accesible por el perfil funcional (la comprobación de solo lectura con la cuenta técnica dio `accesible: true`). Revisar la retención de su carpeta.
- Tras el DDL y la creación del record, consultar la clave `("15789366", "ACCADM", "43709539")`. Si no existe, escribir mediante **Write Records** de Appian el documento `591785` y `date(2026, 11, 25)`. Si ya existe y coincide, no hacer nada; si difiere, no sobrescribir sin verificar con el analista. No usar SQL directo para el rescate ni repetir la gestión original.
- Abrir la gestión AA `43709539` como usuario funcional: deben verse tres filas (contrato, gestoría y DNI). Abrir el contrato con el ojo y comprobar que el visor permite volver a la lista; los tipos 2 y 7 siguen usando Documentum.
- Completar una AA nueva y aceptar una AUT nueva con un contrato tipo 9 en TEST. Confirmar una fila por clave, etiqueta, visor y aislamiento entre gestiones y acciones. En AUT verificar también tipos 7 y 8. Probar ambas variantes del detalle, una gestión sin tipo 9, una autorización rechazada y un reintento de escritura: no se duplican filas ni se repite una subida a SGD/CORE.

DDL validado localmente en PostgreSQL 14.25: creación, segunda ejecución sin cambios y rechazo tanto sin tabla viva como ante una tabla preexistente de otra procedencia. La configuración de los objetos, su ejecución y la comprobación visual en Appian TEST quedan pendientes.
