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
| Documentación → MODIFICAR | Se verificó la validación en el SAIL guardado; no se probó el reemplazo en pantalla. |

**Contra Anulación:** `SCA2_ContraAnulacionOpciones` tiene cuatro llamadas a `a!submitUploadedFiles` sin `documents:`, en ramas que requieren una lista de adjuntos no vacía y que encadenan completar o posponer una acción. La lectura del SAIL identifica una posible consolidación de temporales, pero no demuestra que se consolide un archivo grande pendiente. No se accionaron esos botones en TEST para no tramitar una acción real; el resultado queda sin confirmar y el padre no se modificó.
