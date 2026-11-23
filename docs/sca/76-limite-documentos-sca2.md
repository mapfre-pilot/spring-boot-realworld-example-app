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

La versión vigente del padre (v82) tiene cuatro llamadas a `a!submitUploadedFiles` sin `documents:`. Las cuatro requieren que `listaNombreDocs` no esté vacía; POSPONER requiere además que no esté marcada la no entrega de documentos. Seleccionar un archivo temporal en el campo, por sí solo, no lo añade a esa lista.

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

**Propuesta, no aplicada:** acotar las cuatro llamadas del padre con `documents:` a los IDs de `listaNombreDocs`, que AÑADIR y MODIFICAR registran tras validar y consolidar. No invocar la variante sin documentos si no hay IDs admitidos; se mantienen los grupos y el flujo de negocio. Antes de aplicar el cambio, verificar en TEST aislado que la llamada con IDs explícitos admite los adjuntos ya consolidados y no cambia el recorrido de un PDF válido.
