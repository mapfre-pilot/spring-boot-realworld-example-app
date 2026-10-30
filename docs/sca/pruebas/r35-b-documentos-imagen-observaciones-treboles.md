# R35-B — Documentos en imagen, observaciones de tréboles, tamaño del visor y argumentario vacío (SCA2, TEST)

Origen: 6.º «Análisis SCA2» del analista, puntos 2 y 3 de [`../56-ronda35-analisis-sca2.md`](../56-ronda35-analisis-sca2.md), punto 4
(visor sobredimensionado, añadido durante la ronda) y hallazgo de R35-A («No hay argumentos disponibles»).
Reserva de objetos: [`coordinacion-ronda35.md`](coordinacion-ronda35.md). Pólizas: `polizas/bloque-R35-B.txt`.

## 1. Cambios por objeto

| Objeto | Versión | Cambio |
|---|---|---|
| `SCA2_TXT_EXTENSIONES_DOCUMENTO` (nueva) | v1 | `{PDF, PNG, TIFF, JPG}`: la lista que ya admitía la carga del DNI |
| `SCA2_TXT_MSG_EXTENSION_DOCUMENTO` (nueva) | v1 | «Los documentos adjuntos han de ser PDF, PNG, TIFF o JPG» |
| `SCA2_TXT_OBS_TREBOLES_APLICADOS` (nueva) | v1 | «Se han aplicado {0} tréboles al cliente» (`{0}` = tréboles aplicados) |
| `SCA2_AccionesAdministrativasDocumentacion` | v6 → v7 | Las dos validaciones de carga (AÑADIR y MODIFICAR documento) usan la constante de extensiones para todos los tipos. DNI conserva su mensaje; el resto muestra la constante de mensaje |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | v11 → v13 | Nueva `local!obsArgumentoPositivo`: si el argumento es TTQ (`tuTeQuedas`) y se aplicaron tréboles (`numBonAplic` > 0), a las observaciones del argumento que graba `guardarEjecuArg` se añade «Se han aplicado Y tréboles al cliente» (tras « - » si el gestor ya había escrito observaciones; no se sustituyen). Se aplica en las dos llamadas a `guardarEjecuArg` (rama CE/RM anulada y rama general). v12 usaba `tipoArgumentoVariable = 1`, pero `SCA2_ContraAnulacionSGO` lo pone a 0 al terminar el servicio; v13 usa `tuTeQuedas` |
| `SCA2_VisualizarDocumento` | v2 → v3 | Punto 4: visor (`a!documentViewerField`, alto TALL) en una columna centrada de anchura WIDE (≈800 px) |
| `SCA2_VisualizarDocumentoContraanularEstrategicas` | v2 → v3 | Punto 4: mismo cambio (visor de la CA: documento de oposición, DNI y documentación) |
| `SCA2_consultarListadoArgumentosREST` | v2 → v3 | Tiempo de espera 60 s → 300 s, igual que `SCAC_consultarListadoArgumentosREST` v7 (hallazgo R35-A) |

Método: leer objeto vivo → copia JSON local → cambio mínimo → releer y comparar (todas iguales). No se ha tocado
SCA, SCAC, CMP, CORE, GAIA, NSE, ANL, SGD ni Documentum. El alta en SGD (`SCA2_subirDocumentosGD` → `SCA2_altaDocumento`) y la
recuperación para el ojo (`SCA2 CMD ObtenerDocumentoGD`) no necesitaban cambios.

## 2. Causa raíz

- **Punto 2**: la validación de la carga sólo admitía PDF para los tipos distintos del DNI (tipo 7); las extensiones
  del DNI estaban escritas a mano dentro de la interfaz. SCA (`SCA_AccionesAdministrativasDocumentacion` v7) tiene la misma
  restricción: es una mejora nueva, no una diferencia de paridad.
- **Punto 3**: el modal de recuperación sólo enviaba a CORE (`guardarEjecuArg.observaciones`) las observaciones del
  argumento; el número de tréboles aplicado (`numBonAplic`) se enviaba sólo al servicio de tréboles. El detalle muestra en la
  columna Observaciones de «Argumentos ejecutados» lo que CORE guarda (`textObservacionEjec`), por eso salía vacía. SCA
  (`SCA_ContraAnulacionModalRecuperacionPoliza` v7) se comporta igual: mejora nueva.
- **Punto 4**: el visor estaba directamente en la tarjeta, sin limitar el ancho; el PDF y las imágenes se escalaban a todo
  el ancho de la página.
- **Argumentario vacío (R35-A)**: el servicio `consultarListadoArgumentos` de TEST tarda más de 60 s (medido: dos
  llamadas con la solicitud 15788539 agotaron los 60 s). La integración SCA2 cortaba a los 60 s → error → lista vacía →
  «No hay argumentos disponibles para esta contra anulación». No era ninguna edición a medias ni la recarga de R34-A.

## 3. Pruebas

Pruebas por pantalla en TEST con JJGONZ2, solicitudes nuevas y pólizas del bloque R35-B. Vídeo del testing agent:
`r35b-visores-timeout-edited.mp4` (visores v3, POSPONER → RETOMAR → RECARGAR). Todas las pólizas quedan en
[`polizas/REGISTRO.md`](polizas/REGISTRO.md).

| Póliza | Solicitud | Prueba | Resultado |
|---|---|---|---|
| 2002600009091 (Autos) | 15788539 | Punto 2: TXT no-DNI rechazado con «Los documentos adjuntos han de ser PDF, PNG, TIFF o JPG»; TXT como DNI rechazado con «El DNI ha de ser PDF, PNG, TIFF o JPG»; JPG aceptado y visto con el ojo; MODIFICAR a PNG y visto; DNI en PDF aceptado y visto | **OK**. Referencias SGD: PNG `0900ab4481a119d3`, DNI PDF `0900ab4481a117dd` |
| 2002400308796 (Autos, campaña TTQAUTOS histórica) | 15788544 | Punto 3 Autos: la CA no ofrece TU TE QUEDAS (9 argumentos). Tras obligatorio NEGATIVO + RECARGAR (~65 s) quedó «No hay argumentos disponibles» (antes de subir el tiempo de espera) | TTQ **no probado**; reproduce el hallazgo de R35-A |
| 0731280228213 (Hogar, TTQHOGAR histórica) | 15788546 | Punto 3 Hogar: sin TU TE QUEDAS (7 argumentos). Usada como **regresión**: alta → CA → argumento positivo (SERVICIOS MAPFRE) → Enhorabuena → Finalizado Contra Anulación Positiva → detalle; PDF no-DNI subido y visto | **OK**. SGD `0900ab4481a119da`. El detalle tardó en mostrar «Finalizada Positiva» (al reabrir ya coincidía) |
| 0731280331168 (Hogar, TTQHOGAR histórica) | 15788547 | Punto 4 y argumentario: PDF de oposición, JPG y DNI PNG en la CA centrados y acotados, CONTINUAR operativo; POSPONER → detalle (JPG, PNG y PDF centrados) → RETOMAR (7 argumentos, <10 s) → RECARGAR (7 argumentos, <35 s) | **OK**. SGD `0900ab4481a11884`, `0900ab4481a11886`. Sin TTQ |
| 2002300094099 (Autos, TTQAUTOS histórica) | — | Alta: GUARDAR bloqueado por NSE tras ~100 s («NSE nos indica una excepción… No hay detalles disponibles») | No llegó a crearse la solicitud |

Bandeja de errores: JJGONZ2 no tiene acceso a `/errores` (403 por diseño, ![captura](../img/r35b-bandeja-errores-sin-permiso.png)).
Se revisó en lectura (render LCP de `SCA2_DetalleErrores`): 0 errores en 15788539, 15788544, 15788546 y 15788547
(control: la antigua 15787868 sí lista sus errores).

### No probado y motivo
- **Punto 3 de extremo a extremo (Y < N, texto en el detalle, CORE `consultarBonoCliente` con `mcaAplicada = S`)**: ninguna
  de las pólizas del bloque probadas ofreció TU TE QUEDAS en la CA, ni siquiera las que tienen campañas TTQ históricas
  (todas con vigencia ≤ 2025). Hacen falta pólizas con campaña TTQ vigente. El cambio está aplicado y revisado en el
  código, pero no se ha visto funcionar en pantalla.
- **Respuesta del argumentario de más de 60 s con el tiempo de espera nuevo**: en la reprueba el servicio respondió antes
  de 35 s. La causa sí está medida: dos llamadas de 60 s sin respuesta.
- TIFF, DOCX y el rechazo de formato al MODIFICAR (se probó TXT al añadir).

### Capturas
| | |
|---|---|
| ![JPG con el ojo](../img/r35b-doc-jpg-visor.png) | ![PNG modificado](../img/r35b-doc-png-modificado-visor.png) |
| ![TXT rechazado](../img/r35b-doc-formato-rechazado.png) | ![DNI TXT rechazado](../img/r35b-dni-formato-rechazado.png) |
| ![Referencias SGD](../img/r35b-doc-referencias-sgd.png) | ![PDF no-DNI](../img/r35b-doc-pdf-no-dni-visor.png) |
| ![Oposición centrada](../img/r35b-visor-oposicion-ca-centrado.png) | ![DNI PNG en CA](../img/r35b-visor-dni-png-ca-centrado.png) |
| ![JPG en detalle](../img/r35b-visor-jpg-detalle-centrado.png) | ![PDF en detalle](../img/r35b-visor-pdf-detalle-centrado.png) |
| ![Argumentario vacío antes del cambio](../img/r35b-autos-sin-argumentos-tras-recarga.png) | ![7 argumentos tras RECARGAR](../img/r35b-argumentos-hogar-tras-recarga.png) |
| ![Hogar sin TTQ](../img/r35b-hogar-sin-ttq.png) | ![Regresión finalizada](../img/r35b-regresion-hogar-finalizada.png) |
| ![Alta bloqueada por NSE](../img/r35b-autos-adicional-alta-bloqueada-nse.png) | ![Visores imagen SGD](../img/r35b-visor-imagenes-referencias-sgd.png) |

### Observación (no atribuida a R35-B)
En 15788547 el detalle lista 9 argumentos y la CA 7: OPORTUNIDAD DE DESCUENTOS y SUBIDA DE IMPUESTOS IPS no salen en la CA.
`SCA2_ContraAnulacionOpciones` filtra la lista con `idxArgAnterioresAlfa`/`idxArgNuevos` (lógica copiada de SCA).

## 4. Diferencias con SCA
- SCA sólo admite PDF en documentos no DNI y no guarda los tréboles aplicados en observaciones: los puntos 2 y 3 son mejoras
  de SCA2 pedidas por el analista.
- SCA no limita el ancho del visor (punto 4).
- El tiempo de espera de 300 s iguala SCA2 a SCA.

## 5. Dudas para el analista
1. Extensiones: se reutiliza exactamente la lista del DNI (PDF, PNG, TIFF, JPG). `.jpeg` (4 letras) sigue rechazándose,
   igual que en el DNI. ¿Añadirla? (bastaría con la constante).
2. Formato del texto cuando el gestor ya escribió observaciones en el argumento: «<observación> - Se han aplicado Y tréboles
   al cliente». ¿Vale ese separador?
3. El texto se añade sólo en los argumentos TTQ («Tu te quedas», pantalla «Indique el número de…»). En TEST, para Retos y
   SVA no se pide número de tréboles. ¿Debe salir en algún otro caso?
4. Tamaño del visor: anchura fija de unos 800 px centrada, igual para PDF e imagen. ¿Os parece bien o lo preferís más
   estrecho?
5. `SCA2_AltaGestionArgumento` (mantenimiento) también sólo admite PDF; no está en el alcance del punto 2 y no se ha tocado.
6. Hacen falta pólizas con campaña TTQ vigente para cerrar la prueba del punto 3.
7. Alta de 2002300094099 bloqueada por NSE sin detalle: ¿es conocido?
