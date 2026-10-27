# R34-A — Recarga del argumentario y tréboles; enhorabuena al final (SCA2, TEST)

> **BORRADOR (27/10/2026, 11:00)**: causa raíz y corrección propuesta. **Todavía no hay cambios aplicados en Appian**:
> la prueba «antes» está bloqueada porque el servicio NSE de simulación de anulación de TEST responde
> «HTTP/1.1 500 Internal Server Error» y no se pueden crear solicitudes nuevas (ni en SCA2 ni en SCA).

Origen: 5.º «Análisis SCA2» del analista, puntos 1 y 2 de [`../55-ronda34-analisis-sca2.md`](../55-ronda34-analisis-sca2.md).
Reserva de objetos: [`coordinacion-ronda34.md`](coordinacion-ronda34.md).

## 1. Punto 1 — Tras «RECARGAR ARGUMENTO» el POSITIVO de tréboles ya no abre la pantalla TTQ

### Cómo decide SCA2 si abre la pantalla de tréboles
`SCA2_ContraAnulacionOpciones` carga el argumentario con el servicio `consultarListadoArgumentos`. Ese servicio devuelve
la **lista de argumentos** (`listadoArgumentos`) y, en el mismo resultado, las **campañas de tréboles** (`treboles` = DEFCART:
código de campaña, tréboles disponibles y recomendados). Al pulsar POSITIVO, la pantalla «Indique el número de TTQ… a aplicar
(máximo: N)» se abre sólo si el argumento seleccionado tiene una campaña en ese bloque `treboles`
(`local!descart` → `campanaDescart` → `codCampana` / `tuTeQuedas` / `esRegateable` / `maximo`).

### Causa raíz [Observado en el código]
- El botón RECARGAR ARGUMENTO está en `SCA2_ContraAnulacionCompaniaCatalogacion` (v6). Vuelve a llamar al servicio, pero
  **guarda sólo la lista** (`index(…, "listadoArgumentos", {})`) en la variable que le pasa Opciones (`local!listaArgumentos`).
- Las campañas (`local!descart`) se siguen calculando con la **respuesta de la primera carga** (`local!respArgumentario`),
  que la recarga no toca.
- Además, el argumento que estaba marcado antes de recargar (`local!argumentoSeleccionado`) sigue siendo el objeto de la
  lista antigua (la casilla queda marcada tras CANCELAR la pantalla TTQ, como en SCA).
- Resultado: si al recargar cambia el argumentario (caso del analista: el cliente se hace de Club MAPFRE y el servicio
  devuelve otra campaña u otro argumento de tréboles), el argumento nuevo/antiguo no encuentra su campaña en el bloque de
  tréboles antiguo → `esRegateable` falso → POSITIVO salta directamente a «¡Enhorabuena…!» sin pantalla de tréboles.
- SCA (`SCA_CompañiaContrariaCatalogacion` v7, sólo lectura) **guarda la respuesta completa** (lista + tréboles) y
  `SCA_ContraAnulacionOpcionesEstrategicas` le pasa la respuesta completa (`local!argumentario`), de la que derivan tanto la
  lista como las campañas. SCA2 se separó de SCA en ese punto.
- [Inferido, pendiente de prueba en pantalla] Si la recarga no cambia nada del argumentario, SCA2 sí debería seguir abriendo la
  pantalla (los códigos coinciden con la campaña antigua). La prueba «antes» lo iba a confirmar.
- [Pendiente] `SCA2_consultarListadoArgumentos` (lote R34-B) no lleva el parámetro `rand` que sí usa SCA para evitar que
  Appian reutilice una respuesta con la misma petición. Si en la prueba «después» la recarga devuelve datos antiguos con la
  misma petición, se pedirá a R34-B que lo añada (no es un objeto de R34-A).

### Corrección propuesta
| Objeto | Versión viva | Cambio |
|---|---|---|
| `SCA2_ContraAnulacionCompaniaCatalogacion` | v6 | RECARGAR guarda la **respuesta completa** (lista + tréboles), como SCA; nuevos inputs `argumentoSeleccionado` e `indiceArgumentoSeleccionado` que la recarga deja vacíos |
| `SCA2_ContraAnulacionOpciones` | v59 | Pasa a la recarga `local!respArgumentario` (respuesta completa) y la selección actual |
| `SCA2_ContraAnulacionArgumentarioEstrategicas` | v6 | La casilla de la tabla «Argumentos disponibles…» se desmarca cuando la selección queda vacía (tras recargar se vuelve a elegir sobre la lista nueva) |

## 2. Punto 2 — La enhorabuena al final (mejora; SCA tampoco lo hace)

### Hoy
POSITIVO → pantalla del servicio (tréboles/TTQ, retos, SVA → correo) → su ACEPTAR sólo cierra la pantalla →
«¡Enhorabuena en la retención de la póliza!… ¿Desea continuar?» → su ACEPTAR ejecuta, por este orden, el servicio
(tréboles/TTQ, retos o SVA), el argumento económico (R30) y el cierre positivo → si el servicio falla, aviso
«No se han podido asignar tréboles…» y el argumento vuelve a Pendiente.

### Propuesto
POSITIVO → pantalla del servicio → **su ACEPTAR ejecuta el servicio**:
- **Falla**: sólo el aviso de fallo (mismos textos), el argumento vuelve a Pendiente y no sale la enhorabuena.
- **Va bien**: «¡Enhorabuena…! ¿Desea continuar?» → ACEPTAR → argumento económico (R30, mismas condiciones) → cierre positivo.
Argumentos sin pantalla: sin cambios (enhorabuena directa → ACEPTAR → económico → cierre).

| Objeto | Versión viva | Cambio |
|---|---|---|
| `SCA2_ContraAnulacionSGO` (modales de tréboles/retos/SVA) | v1 | El ACEPTAR de tréboles ejecuta executeAsignar (Club MAPFRE) + gestionarTTQ / marcarAsignacionBonificacion; a Retos y a SVA-correo les pasa la acción del servicio. Nuevos inputs: `dataServicio`, `tipoArgumentoVariable`, `return`, `mensajeInfo`, `mcaVentanaInfo` |
| `SCA2_ContraAnulacionModalRetos` | v1 | Nuevo input `onAceptar`: el ACEPTAR ejecuta asignarRetos |
| `SCA2_ContraAnulacionModalSVAEmail` | v1 | Nuevo input `onAceptar`: tras validar el correo ejecuta asignarSVA + marcarAsignacionBonificacion |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | v10 | Se retiran de su ACEPTAR los pasos 5-7 (servicio), que pasan a las pantallas; mantiene observaciones, R30 y cierre |
| `SCA2_ContraAnulacionOpciones` | v59 | Los datos del modal de recuperación pasan a un local (`local!dataRecuperacion`, mismo contenido) que se entrega también a SGO |

El código del servicio **se mueve** (no se copia): los textos de enhorabuena y de los avisos de fallo no cambian y no hay
literales nuevos. Se retiran los avisos de éxito «Se ha realizado la asignación de tréboles al usuario correctamente.»
(y su variante «…muy cerca del Vencimiento…») y «Ha comenzado el proceso de asignación de SVA…», que hoy nunca se ven porque
el mismo clic cierra el positivo.

Diff completo propuesto (7 objetos): se adjunta en el mensaje de entrega (`r34a-propuesto.patch`).

## 3. Pruebas

### 3.1 Prueba «antes» (27/10, 10:14–10:32, JJGONZ2) — bloqueada
| Póliza | Resultado del alta | Solicitud |
|---|---|---|
| 2002100432563 | GUARDAR → «NSE … HTTP/1.1 500 Internal Server Error» | no creada |
| 2002100432561 | igual | no creada |
| 0731380454474 | igual | no creada |
| 0731380454486 | igual | no creada |
| 0731700187136 | igual | no creada |

Comprobado también por LCP: `SCA2_simularAnulacionAltaNse` y `SCA_simularAnulacionAltaNse` fallan en 0,3 s con el 500 de
NSE (09:33, 09:43, 09:52 UTC y reintentos cada 10 min). Ninguna solicitud antigua se ha tocado.

![Alta bloqueada por NSE](../img/r34a_antes_alta_nse_http500.png)

### 3.2 Pendiente
a) Caso del analista (antes/después), b) enhorabuena al final (tréboles OK, tréboles KO, sin pantalla, económico R30),
c) comparación con SCA.

## 4. Dudas para el analista
1. **CANCELAR en la enhorabuena después de entregar tréboles/SVA/retos**: con el nuevo orden, el servicio ya se ha
   ejecutado cuando sale la enhorabuena. Si el gestor pulsa CANCELAR, el cliente se queda con los tréboles y el argumento
   vuelve a Pendiente (si repite POSITIVO, se volverían a entregar). ¿Se quita CANCELAR en ese caso, o se mantiene?
2. **Argumento económico**: se sigue insertando al ACEPTAR la enhorabuena (positivo definitivo, como en R30) y sólo si el
   servicio fue bien. Insertarlo antes de mostrar la enhorabuena dejaría una fila si el gestor cancela. ¿Correcto así?
3. **Observaciones de más de 999 caracteres**: el aviso sale al ACEPTAR la enhorabuena, es decir, después de entregar el
   servicio. ¿Hay que comprobarlo antes de entregar tréboles?
4. **Aviso de tréboles «muy cerca del Vencimiento»**: hoy no se ve (el mismo clic cierra el positivo) y con el cambio
   tampoco. ¿Debe mostrarse antes de la enhorabuena?
5. **Fallo de SVA** («No ha sido posible asignar el SVA al cliente»): hoy el positivo seguía igualmente; con el cambio el
   argumento queda abierto, como el resto de fallos. ¿Correcto?
6. **Entrega parcial** (p. ej. Club MAPFRE asigna los tréboles pero gestionarTTQ falla): el argumento queda abierto con el
   aviso «No se han podido asignar los tréboles al cliente», pero el cliente ya tiene los tréboles. ¿Qué debe hacerse?
