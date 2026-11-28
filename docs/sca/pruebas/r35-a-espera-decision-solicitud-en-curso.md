# R35-A — espera de decisión y solicitud en curso

Fecha: 29/10/2026. Entorno: Appian TEST, sitio SCA2. Alcance: punto 1 del sexto Análisis SCA2; coordinación R35-A.

## Dictamen y alcance

La corrección mantiene el alta en espera, oculta el formulario/GUARDAR mientras se crea la siguiente gestión y permite consultar una solicitud propia en curso. **No se da por cumplida la cadencia exacta de 15 segundos**: el sondeo nativo disponible es de 30 segundos. No se ha cambiado ningún objeto de SCA, SCAC, CORE, CMP, NSE, ANL, SGD o Documentum ni del lote R35-B.

## Cambios vivos

| Objeto SCA2 | Versión | Cambio |
|---|---:|---|
| `SCA2_AltaSolicitudPage` | 42 | Inicio asíncrono, fecha de lanzamiento, panel de espera, recuperación por póliza/fecha, comprobación de tarea y ACEPTAR→gestión. GUARDAR y confirmación comprueban solicitud en curso antes de lanzar otro proceso. |
| `SCA2_AltaSolicitudAnulacionPopUp` | 11 | Detecta también solicitudes locales SCA2; mensaje en constante; ACEPTAR abre DETALLE, no vuelve a BUSQUEDA. |
| `SCA2_consultarSolicitudEnCurso` | 2 | Devuelve por póliza el identificador más reciente de solicitud SCA2 no finalizada; excluye estados finales/caducados/cancelados. Versión 2 sólo sustituye el literal CANCELADA por constante, sin cambiar el resultado. |

`SCA2_DetalleSolicitud`, `SCA2_DetalleTareas`, `SCA2_Buscador` y los PM permanecen sin cambios. Se reutiliza RETOMAR existente: captura la tarea si corresponde y abre su tipo de acción. No se modifican permisos ni se fuerza la asignación de roles.

### Tiempos y textos

| Constante | Valor objetivo/final |
|---|---|
| `SCA2_VAL_ESPERA_DECISION_INICIAL_SEGUNDOS` | 30 s, versión final 3; durante la prueba controlada, temporalmente 0 s (v2) |
| `SCA2_VAL_ESPERA_DECISION_INCREMENTO_SEGUNDOS` | 15 s, **reservada: no conectada a un temporizador efectivo de 15 s** |
| `SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS` | 30 s |
| `SCA2_TXT_ESPERA_DECISION_INICIAL` | Su solicitud se está generando. Determinando la siguiente gestión, espere un momento. No vuelva a pulsar GUARDAR. |
| `SCA2_TXT_ESPERA_DECISION_ADICIONAL` | Está tardando un poco más en generar la siguiente gestión, espere un momento. |
| `SCA2_TXT_SOLICITUD_EN_CURSO` | Existe una solicitud en curso para la póliza indicada. ¿Quiere consultar la solicitud? |
| `SCA2_TXT_ESPERA_DECISION_LISTA` | Su solicitud se ha generado correctamente. Acepte para abrir la gestión correspondiente. |
| `SCA2_TXT_ACEPTAR_CONSULTA_SOLICITUD` | ACEPTAR |
| `SCA2_TXT_ESTADO_SOL_CANCELADA` | CANCELADA |

Las otras nueve constantes permanecen en versión 1. La prueba UI se hizo con la regla v1; su v2 sólo externaliza un literal idéntico y se comprueba por LCP sobre las tres solicitudes propias. No se repite la prueba UI con el umbral restaurado a 30 s.

No se fija un tiempo máximo: la pantalla sigue comprobando mientras permanece abierta. Esto no garantiza que un proceso bloqueado se recupere solo. Las consultas actualizan como máximo cada 30 s; no se presenta la constante de incremento como una ampliación real de 15 s. La documentación de [`a!refreshVariable`](https://docs.appian.com/suite/help/26.6/fnc_evaluation_a_refreshvariable.html) admite como mínimo 0,5 minutos. Una cadencia exacta de 15 s requiere acordar otro mecanismo soportado/homologado; no se instala un componente nuevo ni se modifica SCAC para simularlo.

## Causa de la incidencia y rendimiento

### Hechos verificados

1. La UI anterior lanzaba `SCA2_PM_CMD_ALTA` con espera síncrona. El proceso puede continuar aunque el retorno a la interfaz todavía no contenga una tarea lista. Rehabilitar entonces el alta posibilita un segundo intento sobre una solicitud ya creada.
2. El inventario de la aplicación no contiene un PM denominado `SCA2 CMD CrearSolicitud`: contiene la integración `SCA2_crearSolicitud` y el PM real de este flujo, **`SCA2 CMD Alta`** (`0000f06f-28fc-8000-6693-7f0000014e7a`). Su nodo `generarStudAnul` llama a CORE y obtiene el id; después construye/escribe datos y solicitud, y `Start Decidir` espera síncronamente a `SCA2 CMD Decidir`.
3. `SCA2 CMD Decidir` (`0000f06f-0eab-8000-6595-7f0000014e7a`) carga la solicitud, consulta BBDD SCA para mapear el DTO, llama a `SCA2_consultarServiciosReglas`→`SCA2_scaServiciosReglas`, interpreta el resultado y espera síncronamente a `SCA2 CMD CrearAccion`. Por tanto, el tiempo visible no es sólo el tiempo del motor de reglas: incluye consultas, escrituras, arranque de subprocesos y creación de la gestión/tarea.
4. La integración del motor permite `requestTimeout = 300` segundos, superior al umbral de espera inicial de 30 s. Este valor es un límite, **no una prueba de que cada llamada dure 300 s**.

### Mediciones de solicitudes nuevas propias

Horas de eventos LCP en UTC; pantalla en CET (UTC+1). Duraciones de nodo: diferencia entre eventos TYPE_START y TYPE_COMPLETE del mismo id de tarea. No sumar un nodo padre con su proceso hijo: los tiempos se solapan.

| Solicitud / póliza | Proceso Alta | Duración Alta | Proceso Decidir | Duración Decidir | Nodo Consultar reglas |
|---|---:|---:|---:|---:|---:|
| 15788537 / 2002600074045 (Autos) | 11231720 | 24,490 s | 16479266 | 11,630 s | 3,659 s |
| 15788542 / 0730080016454 (Hogar) | 10191069 | 20,880 s | 11231775 | 10,030 s | 2,670 s |

En Autos, `Start Decidir` ocupa 12,650 s del Alta; `Contexto`, 4,770 s; `Write Datos`, 2,550 s. En Decidir, `Start CrearAccion` ocupa 4,590 s. La tarea se escribe en CrearAccion 715126, terminado a las 11:31:05,320 UTC; Alta finaliza a las 11:31:07,210 UTC.

Medición aislada posterior de lectura con el DTO propio: Autos, mapeo 127 ms y motor 2.511 ms; Hogar, mapeo 131 ms y motor 1.465 ms. Respuestas correctas, sin timeout. Son otras invocaciones, no los tiempos internos exactos de las ejecuciones originales. En Hogar `Start Decidir` tarda 10,750 s; `Contexto`, 3,440 s; `Write Datos`, 2,599 s. El nodo Consultar reglas no es el mayor consumidor de tiempo en estas muestras.

La incidencia histórica de Hogar >30 s es compatible con esta cadena síncrona y con latencia variable, pero **no se ha reproducido ni identificado con trazas el cuello de botella externo exacto de la póliza del analista**, que está prohibida para estas pruebas. No se atribuye sin evidencia la lentitud exclusivamente al motor, a CORE o a infraestructura. La corrección protege la UI frente a esa duración; no optimiza ni cambia contratos del backend.

### Comparación con SCA

Lectura únicamente de `SCA Decidir Accion`, `SCA_AltaSolicitudAnulacion`, `SCA_GenerarSolicitudPopup` y `SCA_consultarServiciosReglas`. SCA también contiene mapeo, consulta al motor (`SCAC_scaServiciosReglas`), consulta de gestión y búsqueda de última gestión. No se ejecuta un alta en SCA ni se modifica ningún objeto suyo. No hay una comparación cronometrada equivalente SCA/SCA2 y no se afirma que uno sea más rápido.

## Prueba controlada y resultados UI

Se redujo exclusivamente el umbral de aviso inicial a 0 s, sin ralentizar servicios ni alterar datos ajenos. Esto fuerza la rama de aviso adicional; **no reproduce una llamada real de más de 30 s ni demuestra intervalos de 15 s**. Después se restaura el umbral de 30 s mediante GET→backup→PUT→GET.

| Caso | Resultado observado |
|---|---|
| Autos nueva 2002600074045 → 15788537 | Aviso adicional exacto, formulario/GUARDAR ocultos; aparece ACEPTAR; abre CA. |
| Autos propia: nuevo intento desde popup | Mensaje de solicitud en curso → ACEPTAR → detalle sin acción → desplegar CA → RETOMAR → CA propia. |
| Hogar nueva 0730080016454 → 15788542 | Aviso adicional, formulario/GUARDAR ocultos; ACEPTAR abre CA. |
| GUARDAR en alta Hogar obsoleta de una segunda pestaña, preparada antes de crear | Detecta la solicitud propia en curso; ACEPTAR abre consulta sin crear otra; búsqueda final muestra una sola solicitud. RETOMAR abre CA tras aproximadamente 80 s, con incidencia de argumentos indicada debajo. |
| Regresión Autos 2002600042670 → 15788545 | Alta→aviso adicional→ACEPTAR→CA (nueve argumentos, sin ejecutar)→detalle. CA Incompleta al volver. Bandeja de errores no verificable con JJGONZ2: página inexistente o sin permiso. |

La póliza 2002600052346 ya estaba ocupada por 15788534. Se registra y se excluye; no se abre ni modifica esa solicitud. Todas las pólizas consultadas, incluidas ocupadas/fallidas, están en [`REGISTRO.md`](polizas/REGISTRO.md). No se usa 0732400126663.

### Incidencia adicional de Hogar tras RETOMAR

La primera entrada en CA de 15788542 mostraba ocho argumentos disponibles. Después de consultar la solicitud y RETOMAR, la CA tarda aproximadamente 80 s y muestra «No hay argumentos disponibles para esta contra anulación». No se ejecutaron argumentos ni RECARGA para alterar/ocultar el resultado. La navegación funciona, pero **la equivalencia funcional completa no queda validada**. Se eleva para coordinación con R35-B, propietario de CA/argumentario. `SCA2_DetalleSolicitud` no se ha modificado y no se atribuye causalidad a ese objeto sin investigación adicional.

#### Reproducción y hora

Usuario JJGONZ2; 29/10/2026, franja 12:35–12:41 CET (11:35–11:41 UTC). Alta lanzada por el proceso a las 11:37:42,760 UTC. No se dispone de un registro al segundo de cada clic.

1. Comprobar por búsqueda que 0730080016454 está libre y abrir dos altas de esa póliza antes de crear la solicitud.
2. Completar y GUARDAR/ACEPTAR el alta en la primera pestaña; aparece el aviso adicional con el umbral de prueba a 0 s. No volver al formulario ni pulsar otro GUARDAR.
3. Cuando esté lista, ACEPTAR abre la CA de 15788542: ocho argumentos disponibles, sin ejecutar ninguno ([entrada inicial](../img/r35-a-13-hogar-ca.png)).
4. GUARDAR en la segunda pestaña detecta la solicitud en curso ([aviso](../img/r35-a-14-guardar-guard.png)). ACEPTAR abre su consulta/detalle.
5. Desplegar la CA y pulsar RETOMAR ([detalle](../img/r35-a-15-hogar-retomar.png)). Tras aproximadamente 80 s se abre la CA sin argumentos ([resultado](../img/r35-a-16-hogar-retomada.png)). Esta última captura quedó guardada a las 11:41:32 UTC; es hora de guardado del fichero, no del clic.
6. La búsqueda final muestra una sola solicitud ([comprobación](../img/r35-a-17-hogar-unica.png)). No pulsar RECARGA ni ejecutar argumentos para ocultar el hallazgo.

#### Versiones de CA observadas, sólo lectura

GET de las interfaces y GET de `/objects/{uuid}/versions` por LCP a las 11:49–11:50 UTC. El historial confirma que sus últimas versiones se guardaron antes de la reproducción; no hay una versión posterior entre la prueba y esta lectura. Son objetos relacionados consultados, no una afirmación de que todos se renderizaran en la CA de Hogar.

| Interfaz | Versión viva durante la prueba | Último guardado (UTC) |
|---|---|---|
| `SCA2_ContraAnulacionPrincipal` | 4 | 30/09/2026 11:24:02 |
| `SCA2_ContraAnulacionOpciones` | 61 | 28/10/2026 22:05:08 |
| `SCA2_ContraAnulacionArgumentarioEstrategicas` | 7 | 27/10/2026 14:44:43 |
| `SCA2_ContraAnulacionSGO` | 2 | 27/10/2026 14:44:36 |
| `SCA2_ContraAnulacionModalRecuperacionPoliza` | 13 | 29/10/2026 11:26:56 |
| `SCA2_GestionArgumentos` | 5 | 27/10/2026 09:12:24 |
| `SCA2_TablaGestionArgumentos` | 3 | 26/10/2026 12:09:21 |

La comprobación es de historial de diseño, no una traza de evaluación del navegador. R35-A no ha hecho PUT sobre ninguno de estos objetos. El hallazgo y las versiones se trasladan a R35-B, sin proponer una causa no demostrada.

### Capturas

- [Autos en espera](../img/r35-a-03-autos-espera.png), [lista](../img/r35-a-04-autos-lista.png), [CA](../img/r35-a-05-autos-ca.png).
- [Solicitud en curso](../img/r35-a-06-duplicado-popup.png), [RETOMAR](../img/r35-a-07-retomar.png), [CA retomada](../img/r35-a-08-retomada-ca.png).
- [Hogar en espera](../img/r35-a-11-hogar-espera.png), [CA](../img/r35-a-13-hogar-ca.png), [GUARDAR con solicitud en curso](../img/r35-a-14-guardar-guard.png).
- [Hogar retomada sin argumentos](../img/r35-a-16-hogar-retomada.png), [una sola solicitud](../img/r35-a-17-hogar-unica.png).
- [Regresión: póliza libre](../img/r35-a-18-regresion-libre.png), [CA](../img/r35-a-22-regresion-ca.png), [detalle](../img/r35-a-23-regresion-detalle.png), [bandeja bloqueada](../img/r35-a-25-errores-sin-permiso.png).

## Validación y límites

- Para cada objeto modificado: GET vivo, backup JSON local, cambio mínimo, PUT, GET posterior y comparación de expresión/versión. Appian valida la expresión en cada PUT; se corrigió una variable local no usada antes de aplicar el candidato.
- Regla de solicitud en curso: entrada vacía→null sin error; póliza propia Autos→15788537 sin error (19 ms en v1). Repetida en v2 con entrada vacía y con las tres pólizas propias: los ids siguen siendo 15788537, 15788542 y 15788545.
- MCP TEST falló al inicializar. Se usa LCP REST con credenciales de entorno; no se guardan secretos en el repositorio. Backups y respuestas con datos completos permanecen fuera de Git.
- No aplican compilación Java/TypeScript ni pruebas de esos proyectos: no se modifican sus fuentes. La validación de expresiones corresponde a Appian, complementada por prueba de pantalla.
- La regla nueva busca en el record type SCA2. El popup mantiene su consulta anterior de CORE y el detalle mantiene su fallback CORE-only; **no se prueba una solicitud nueva existente sólo en CORE**.
- No se fuerza un estado final/caducado/cancelado sobre solicitudes antiguas para probar exclusiones. No se prueban todos los roles ni todos los tipos de siguiente gestión.
- Bandeja de errores bloqueada para JJGONZ2: no se afirma que esté libre de errores. Requiere usuario autorizado; no se alteran permisos ni se omite la restricción.
- Comprobación técnica adicional por LCP: `SCA2_contarErroresPendientes` devuelve 0 para cada una de las tres solicitudes propias al filtrar separadamente por `SCA2 CMD Alta` y `SCA2 CMD Decidir`. Sólo cubre registros en estado Pendiente de esos comandos; no sustituye la bandeja UI ni demuestra ausencia de cualquier otro error.

## Dudas que requieren decisión

1. ¿Se acepta el sondeo nativo de 30 s o se exige un componente/mecanismo homologado para 15 s? La constante de 15 s por sí sola no cumple el requisito.
2. ¿Debe existir un límite máximo o una salida explícita para un proceso permanentemente bloqueado? Actualmente la espera continúa sin volver al alta.
3. Para diagnosticar el caso histórico exacto se necesitan trazas de esa instancia y del motor/CORE; no se reutiliza la póliza del analista.

No se considera cerrado al 100 % el punto 1 mientras permanezca abierta la cadencia de 15 s y los límites indicados.
