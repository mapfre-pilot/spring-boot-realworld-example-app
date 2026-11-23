# 76 — Límite de 50 MB por documento en SCA2

Aplicado solo en Appian TEST. En los tres campos de adjuntos se añadió una única comprobación a la lista de validaciones existente:

```sail
if(or(fv!files.size > 50 * 1024 * 1024), "El archivo no puede superar los 50 MB.", "")
```

El límite es por archivo: **52.428.800 bytes** (50 MiB). Un archivo de exactamente ese tamaño no activa esta validación. Appian puede recibir el archivo temporal antes de mostrar el error: no es un límite de transferencia del sitio.

| Interfaz SCA2 | Versión anterior → guardada | Campos |
|---|---|---|
| `SCA2_AccionesAdministrativasDocumentacion` | v9 → v10 | AÑADIR y MODIFICAR |
| `SCA2_AltaGestionArgumento` | v9 → v10 | Documento a visualizar (alta y edición) |

La comparación del SAIL guardado con las copias de v9 mostró solo dos inserciones en la primera interfaz y una en la segunda. Se mantienen un archivo por campo, las extensiones admitidas (PDF/PNG/TIFF/JPG/JPEG en documentación y solo PDF en argumentos), y los grupos, botones y destinos existentes. No se creó una constante ni se editaron las interfaces padre, SCA, SCAC o CORE. No se ejecutó DDL ni DML directo. Las copias de antes y después quedaron en `files/sca2-limite-50mb/` de la memoria de trabajo.

## Verificación en TEST

Se usaron PDF sintéticos de 53.477.944 bytes y 608 bytes. No se guardó ningún argumento ni se envió ninguna acción de negocio.

| Recorrido | Resultado |
|---|---|
| Mantenimiento → Argumentos de Contra Anulación (site) | El PDF grande mostró el mensaje. Al pulsar GUARDAR con los datos obligatorios sin rellenar, el formulario siguió abierto y el archivo quedó pendiente; esto no aísla el error de tamaño como causa del bloqueo. El PDF pequeño se pudo seleccionar sin error; se canceló sin guardar. |
| Documentación → AÑADIR (Designer) | El PDF grande mostró el mensaje y quedó pendiente al pulsar AÑADIR. El PDF pequeño se pudo seleccionar sin error; se retiró y se canceló sin añadirlo. |
| Documentación → MODIFICAR (Designer) | Se añadió un PDF sintético inicial sin asociarlo a una solicitud. Al pulsar MODIFICAR con el PDF de 51 MiB, el editor siguió abierto con el error y la referencia del documento original no cambió. El PDF pequeño se pudo seleccionar sin error; se retiró y se canceló sin guardar ningún reemplazo. |

## Contra Anulación: alcance de la comprobación

En Designer de TEST, con una solicitud de prueba, el campo de documentación de `SCA2_ContraAnulacionOpciones` mostró el error para el PDF de 51 MiB y permitió seleccionar el pequeño. No aparecieron los botones REVISIÓN, POSPONER ni FINALIZAR en esa previsualización. Se retiraron los archivos temporales y se canceló el adjunto; no se completó ni pospuso ninguna acción contra CORE.

La v82 del padre tenía cuatro llamadas a `a!submitUploadedFiles` sin `documents:`. Las cuatro requerían que `listaNombreDocs` no estuviera vacía; POSPONER requería además que no estuviera marcada la no entrega de documentos. Seleccionar un archivo temporal en el campo, por sí solo, no lo añade a esa lista.

| Recorrido en el SAIL | Validación del botón | Efecto al confirmar |
|---|---|---|
| REVISIÓN | `submit: true`; `validate` por defecto; sin grupo. | Ejecuta `SCA2 CMD CompletarAccion` con estado 6. Pasa a crear la acción de autorización, con posible alta de gestión en CORE. |
| POSPONER | `submit: true`; `validate` por defecto; sin grupo. | En función del contexto puede persistir la catalogación en CORE antes de consolidar. `SCA2 CMD Posponer` puede abrir gestión SGC, registrar observaciones en CORE y enviar adjuntos a GD. |
| Recuperación de póliza → ACEPTAR (`onFinalizarPositivo`) | `submit: false` en la aceptación principal; el aviso de continuación omite `submit`. Ambos omiten `validate` y el grupo. | Ejecuta `SCA2 CMD CompletarAccion` para el cierre positivo, con envío a GD y cierre en CORE. |
| FINALIZAR → Sí/No, incluidas las ramas de ilocalizables (`onFinalizar`) | FINALIZAR usa `submit: true` y abre el modal; Sí/No tienen `submit` condicional. Ninguno especifica `validate` ni grupo. | Las confirmaciones de cierre ejecutan `SCA2 CMD CompletarAccion`; algunas ramas del modal pueden escribir en CORE antes de invocar el proceso. |

Ninguno de estos botones selecciona el grupo `documento`, así que el mensaje del campo no garantiza que se bloquee el botón antes de ejecutar su acción. No se cambió el padre: asignarle el grupo `documento` también aplicaría las validaciones preexistentes de extensión y obligatoriedad, no solo la de tamaño.

### Prueba aislada de consolidación

En Designer de TEST, `SCA2_TMP_PruebaLimite50MB` v1 reprodujo el patrón: campo en el grupo `documento` con la misma validación, botón con `submit: true` sin grupo y `a!submitUploadedFiles()` sin `documents:`. Los callbacks solo escribían variables locales; no había procesos ni llamadas a CORE o GD.

| PDF sintético | Vista previa tras pulsar el botón | Comprobación independiente |
|---|---|---|
| 51 MiB (53.477.944 bytes) | `onSuccess`, con el mismo ID que tenía el temporal; el mensaje de tamaño seguía visible. | El PDF apareció como documento en la carpeta destino de Appian. |
| Pequeño (608 bytes) | `onSuccess`, con el mismo ID que tenía el temporal y sin error de tamaño. | El PDF apareció como documento en la misma carpeta. |

La prueba confirma que la llamada sin `documents:` puede consolidar un PDF sobredimensionado aun con el error visible. No se ejecutó una acción de Contra Anulación: en el padre, la llamada sigue condicionada a que ya haya adjuntos en `listaNombreDocs`. Se eliminaron la interfaz temporal, los dos PDF de la prueba y el PDF sintético usado anteriormente para habilitar MODIFICAR.

### Verificación de la propuesta con IDs explícitos

En una segunda interfaz temporal de TEST, `SCA2_TMP_PruebaIdsLimite50MB` v1, AÑADIR validaba el grupo `documento` y consolidaba el PDF pequeño antes de guardar su ID. El botón de continuación mantuvo `submit: true` sin grupo: con un ID admitido invocaba `a!submitUploadedFiles(documents: ...)`; sin IDs, solo guardaba el resultado en una variable local.

| Caso con el PDF de 51 MiB pendiente | Resultado al pulsar Continuar |
|---|---|
| Sin IDs admitidos, sin llamar a `a!submitUploadedFiles` | Continuó y el PDF grande apareció en la carpeta de Appian. |
| Con el ID del PDF de 608 bytes ya consolidado | Se ejecutó `onSuccess` y en la carpeta quedó un único PDF pequeño. También apareció otro PDF grande. |

En ambos casos seguía visible el mensaje de tamaño. La consulta de la carpeta devolvió dos PDF nuevos de 53.477.944 bytes y uno de 608 bytes. **Acotar la llamada a los IDs admitidos no basta con el patrón de continuación probado**. El caso sin llamada demuestra que la consolidación del PDF grande no depende de invocar `a!submitUploadedFiles` sin `documents:`; la prueba no aisló el comportamiento de `submit: true` fuera de Designer.

La revisión del SAIL v82 no identificó otro campo de subida en el padre ni en las interfaces SCA2 que usa, aparte de AÑADIR y MODIFICAR de Documentación. Ambos añaden a `listaNombreDocs` el ID como prefijo del nombre después de validar y consolidar el archivo. El padre conserva la v82: no se cambió ninguna de sus cuatro llamadas ni se repitió la prueba de pantalla con la solicitud, ya que la prueba aislada no cumplió el requisito de bloqueo. No hubo llamadas a CORE o GD en la prueba aislada.

Se eliminaron la interfaz temporal y los tres PDF nuevos; la consulta por UUID devolvió HTTP 404 para los cuatro objetos.

### Rechazo al seleccionar el archivo en la interfaz hija

En otra previsualización aislada de TEST, `SCA2_TMP_PruebaRechazo50MB` v1 usó la misma variante de campo que Documentación (`a!fileUploadField_26r7`). En `saveInto`, `document(tointeger(index(save!value, 1, null)), "size")` leyó el tamaño del temporal en bytes. Si superaba el límite, el campo quedaba vacío y un local mantenía visible «El archivo no puede superar los 50 MB.». Se conservó la validación basada en `fv!files.size`.

| Prueba | Resultado |
|---|---|
| PDF de 51 MiB (53.477.944 bytes) | Campo vacío, mensaje visible. La carpeta no tenía el documento al terminar la selección, pero pasó de cero a un documento al pulsar el botón aislado con `submit: true`, sin grupo y con `a!submitUploadedFiles()` sin `documents:`. El campo siguió vacío. |
| Dos PDF de 608 bytes | Cada uno quedó seleccionado sin aviso. Los botones aislados de AÑADIR y MODIFICAR devolvieron éxito y cada fichero apareció en la carpeta. |

Dejar vacío el valor visible no retira el temporal del conjunto que Appian puede consolidar. **No se cambió `SCA2_AccionesAdministrativasDocumentacion` (v10) ni se tocó el padre (v82)**; no se ejecutaron botones de negocio ni llamadas a CORE o GD.

Se eliminaron la interfaz temporal y los cuatro PDF de prueba, incluida una repetición del caso de 51 MiB para comprobar la carpeta antes y después del clic. La consulta por UUID devolvió HTTP 404 para los cinco objetos.

### Bloqueo de botones mientras haya un fichero sobredimensionado pendiente

En Documentación v10, **CANCELAR** en AÑADIR copia el valor pendiente al input `documentosACargarN` correspondiente al tipo, oculta el editor y vacía el valor del campo. En MODIFICAR, CANCELAR oculta el editor sin vaciar su valor. Contra Anulación también permite plegar Documentación, lo que oculta el campo y su mensaje.

En la interfaz aislada `SCA2_TMP_PruebaCancelar50MB` v1 de TEST se reprodujo el CANCELAR de AÑADIR y se comparó con quitar el archivo mediante la «×» del propio campo. En ambos casos se pulsó luego un botón de prueba con `submit: true`, sin grupo y con `a!submitUploadedFiles()` sin `documents:`:

| Acción con un PDF de 51 MiB | Documentos en la carpeta antes y después de Continuar |
|---|---|
| CANCELAR: campo oculto y vacío | 0 → 1 |
| Quitar con la «×» del campo | 0 → 0 |

No se aplicó el bloqueo de los botones. Si se levanta al cancelar el editor, el archivo aún puede consolidarse; si el bloqueo se mantiene, el campo y el mensaje pueden quedar ocultos. Para aplicar la protección, primero hay que decidir cómo debe descartarse el temporal al cancelar. No se cambió Documentación v10 ni el padre v82, ni se ejecutaron acciones de negocio, CORE o GD.

Se eliminaron la interfaz temporal y el único PDF consolidado; la consulta por UUID devolvió HTTP 404 para ambos.

### Bloqueo aplicado en TEST

Se mantiene la validación del campo y su mensaje. Appian recibe el archivo temporal; para abandonar el editor cuando supera el límite, primero hay que retirarlo con la **×** del campo. El padre mantiene el bloqueo mientras esté pendiente, aunque se pliegue la sección Documentación.

| Interfaz | Versión | Diff |
|---|---|---|
| `SCA2_AccionesAdministrativasDocumentacion` | v10 → v11 | Local e input booleano opcional `archivoGrandePendiente`. Los dos campos conservan su guardado y calculan el indicador con `document(tointeger(index(save!value, 1, null)), "size") > 50 * 1024 * 1024` (falso al retirar el archivo); se comunica al padre si pasó el input. Ambos CANCELAR se deshabilitan con el indicador activo. |
| `SCA2_ContraAnulacionOpciones` | v82 → v83 | Local booleano inicializado a falso, pasado a Documentación y a las dos continuaciones. REVISIÓN, POSPONER y FINALIZAR conservan su condición de deshabilitación y añaden el indicador como alternativa. |
| `SCA2_ContraAnulacionModalSiNo` | v7 → v8 | Input opcional. Bloquea Sí/OK y bloquea No solo en las ramas que finalizan. |
| `SCA2_ContraAnulacionRehabilitacion` | v6 → v7 | Input opcional que transmite el indicador a Recuperación de póliza. |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | v16 → v17 | Input opcional y bloqueo de ACEPTAR, tanto en el modal principal como en el aviso de continuación. |

Las relecturas de TEST coincidieron con las expresiones guardadas y los únicos cambios de inputs fueron los cuatro booleanos opcionales de la tabla. No cambiaron grupos, extensiones, mensajes de validación de tamaño ni llamadas de consolidación. Las copias SAIL y JSON de cada versión están en `files/sca2-limite-50mb/` de la memoria de trabajo.

| Prueba | Resultado |
|---|---|
| Site aislado, sin archivo y con PDF de 608 B | CANCELAR del editor y el botón de consolidación habilitados. |
| Site aislado, PDF de 51 MiB | Mensaje visible y ambos botones deshabilitados. Plegar la sección mantuvo el bloqueo; la × volvió a habilitar el botón. La consulta antes y después de la cancelación simulada dio **0 → 0 documentos**. |
| Vista previa de Contra Anulación, solicitud sintética | Después de seleccionar oficina, POSPONER estaba habilitado sin archivo. Con el PDF de 51 MiB en AÑADIR, se mostró el error y se deshabilitaron CANCELAR y POSPONER. La × reactivó ambos. El PDF de 608 B no produjo error ni los bloqueó; AÑADIR lo consolidó después de plegar la sección de catalogación, cuyos campos obligatorios no estaban completos en la prueba. |

FINALIZAR ya estaba deshabilitado sin archivo por falta de argumentos ejecutados. REVISIÓN y las continuaciones no se ejercitaron en la vista previa; tampoco se volvió a probar MODIFICAR en pantalla con la v11. No se pulsó ningún botón de negocio ni se completó ninguna acción contra CORE.

Capturas completas: `aislada-site-bloqueo-51MiB.png`, `contra-anulacion-bloqueo-sin-archivo.png`, `contra-anulacion-bloqueo-anadir-51MiB.png`, `contra-anulacion-bloqueo-anadir-608B.png` y `contra-anulacion-bloqueo-anadido-608B.png`, en `~/.devin-files/sca2-limite-50mb/`.

Se eliminaron el site y la interfaz temporales y el PDF de 608 B consolidado en la vista previa; los tres devolvieron HTTP 404 por UUID. Ningún PDF de la prueba aislada llegó a consolidarse.
