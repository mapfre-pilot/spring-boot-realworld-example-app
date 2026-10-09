# Ronda 7 — comparación funcional SCA / SCA2, wAutemis y SISANS

Fecha de ejecución: 09/10/2026 (horas de las pantallas Appian). Entorno TEST. Pruebas mediante UI real; JJGONZ2 en Chrome normal y SISANS en incógnito, cookies aisladas. Sin modificaciones de aplicación por el agente de pruebas y sin commit.

**Veredicto: cobertura parcial; no se puede declarar equivalencia funcional completa.** Se verificaron el alta SISANS corregida, su CA positiva y el nuevo salto RCI con asignación sólo a grupo. La referencia SCA quedó bloqueada repetidamente en Alta; no se pudo completar CA1/CA2 histórica. La candidata AA de SISANS no dio una tarea ejecutable y el buscador SCA2 presenta un estado final engañoso respecto al error confirmado por el lead.

**Seguridad:** no se pulsó ANULAR PÓLIZA, no se repitió GUARDAR en altas ya enviadas, no se ejecutaron argumentos de CA2, no se modificaron permisos ni grupos. Al cierre no se iniciaron más altas.

## 1. Versiones y separación de evidencia

- Inicio de ronda con Detalle v47 y los cambios de procesos de ronda 6.
- La primera ejecución encontró el error de nulos en Alta SISANS. Esa observación se conserva como antecedente; no demuestra el estado corregido.
- Continuación después de publicar AltaSolicitudPage null-safe: alta SISANS 0000253500328 ejecutada y finalizada positivamente.
- Delta CrearAccion: nueva RCI 0005726678405, sin reutilizar la tarea antigua de 15787861. El resultado nuevo **no** se extrapola a tareas ya grabadas.
- Los diagnósticos de records/grupos aportados por el lead se identifican como tales; no se presentan como comprobación backend independiente del agente de pruebas.

## 2. Tabla de trazabilidad y comparación paso a paso

En la columna de evidencia, E1–E12 corresponden a las imágenes alojadas de la sección 7. Las filas históricas recogen lo observado durante esta ronda antes de la continuación; no son reejecuciones.

| Póliza(s) | Usuario | App | Solicitud CORE | Paso | SCA | SCA2 | Igual / diferente / límite | Evidencia |
|---|---|---|---|---|---|---|---|---|
| 0000253500285 / 0000253500287 | JJGONZ2 | SCA / SCA2 | 15787859 / 15787858 | Alta y CA positiva | Alta enviada; «Aún procesando»; sólo Alta disponible, sin CA | Alta y CA POSITIVO completadas; tras reabrir, «Finalizada positivamente», resolución 09/10/2026 13:08:25 | Comparación final bloqueada por SCA; el Incompleta inmediato en SCA2 desapareció al propagar | Lecturas de continuación; ss_2d01c64a.png |
| 0000253500305 | JJGONZ2 | SCA | No confirmado por UI | Reserva normal | Alta enviada; no repetir GUARDAR; sin número confirmado en esta ejecución | No aplica | Incompleto; no inventar CORE | Ledger comunicado por lead, no prueba de finalización |
| 0000253500293 | JJGONZ2 | SCA2 | 15787860 | CA negativa con documento | No se completó contraparte histórica | Llegó a consulta de anulación; se detuvo antes de ANULAR PÓLIZA. Buscador Pendiente naranja | Cobertura negativa SCA2 parcial, comparación SCA pendiente | Buscador E10; antecedente de ronda |
| 0005726674052 / 0005726674004 | JJGONZ2 | SCA / SCA2 | 15787862 / 15787861 | Alta RCI y CA1 | SCA sólo Alta Finalizada, incluso en comprobaciones posteriores | CA1 negativa; CA2 Incompleta, nivel 2, GGE EXPERTOS SI24 | Salto comprobado sólo SCA2 | E12; ss_511f8eec.png |
| 0005726674004 | JJGONZ2 / SISANS | SCA2 | 15787861 | Permisos CA2 antigua | No hay CA2 histórica accesible para comparar | JJGONZ2 vio y abrió RETOMAR; SISANS ve detalle, argumentos/documento, sin RETOMAR/REASIGNAR | Antecedente explicado por asignadoA JJGONZ2; no es prueba del delta nuevo | ss_25d1c322.png, ss_592ed324.png |
| 0000253500329 / 0000253500328 | SISANS | SCA / SCA2 | 15787864 / 15787863 | Canal/Medio iniciales | Canal «--- Seleccione ---»; no valor por defecto; Medio vacío y deshabilitado | Igual después de corrección; formulario ya no falla Null/Integer | Igual en valores iniciales; fix SCA2 pasa | E1/E2; ss_57674aa9.png |
| 0000253500329 / 0000253500328 | SISANS | SCA / SCA2 | 15787864 / 15787863 | Guardar alta | Seleccionado SI24; Medio «--- Seleccione ---»; creó solicitud pero continuación 403 | Seleccionado SI24; Medio «--- Seleccione ---»; alta creada, CA disponible | Diferente: SCA bloqueada; SCA2 ejecutable | E1/E2/E4 |
| 0000253500328 | SISANS | SCA2 | 15787863 | POSPONER → RETOMAR → positivo | No completado en 15787864 por bloqueo | POSPONER confirmado, RETOMAR abre CA, argumento positivo y finalizar. Alta Finalizada verde y CA Finalizada Positiva verde; grupo SI24 EXPERTOS, usuario SISANS | Pasa flujo propio SISANS SCA2; comparación final incompleta | E3; ss_9a4eb1bf.png, ss_8f1d13b6.png, ss_de161b32.png |
| 0000253500338 | SISANS | SCA2 | No mostrado en popup | Reserva descartada | No aplica | «No puede crear una nueva solicitud ya que existe una solicitud de anulación abierta.» No se creó alta | No se conoce número de la solicitud existente | ss_db0ebd58.png |
| 0000253500332 / 0000253500286 | SISANS | SCA / SCA2 | 15787866 / 15787865 | Candidata AA, códigos 1/5/14 | Decisión cliente / Venta vehículo / No voy a comprarme otro coche; SI24; A FECHA 09/10/2026; alta creada, sólo Alta Finalizada | Mismos valores. Guardado y mensajes de generación/redirección; tras espera sólo Alta Finalizada | No apareció AA ejecutable en ninguna | E7/E8; ss_fe0ea891.png, ss_b53b1f8e.png |
| 0000253500286 | SISANS | SCA / SCA2 | 15787865 | Estado en buscadores | Pendiente naranja, resolución «-» | **Finalizada. Rechazada anulación**, rojo; resolución 09/10/2026 13:44:16 | Diferente; además contradice record ERROR confirmado por lead | E9/E10 |
| 0000253500332 | SISANS | SCA | 15787866 | Flecha volver desde Detalle | Error sca_datoscabecera / a!submitLink línea 23; se recupera navegando a URL del buscador | En los retornos SCA2 ejercitados no apareció este error | Fallo observado SCA; no atribuir a SCA2 | E11 |
| 0005726678405 | JJGONZ2 | SCA2 | **15787867** | Alta RCI nueva post-fix | Referencia SCA 15787862 sigue sólo Alta | Decisión cliente / Precio / Me ha subido mucho la prima; PRESENCIAL; Medio vacío; A VENCIMIENTO 25/11/2027. Alta guardada una sola vez | Alta nueva pasa | ss_c9a07c1d.png |
| 0005726678405 | JJGONZ2 | SCA2 | 15787867 | CA1 negativa | No ejecutable aún en SCA 15787862 | Aviso «Esta poliza es de un acuerdo que trata SI24. La retención o anulación de la póliza se trasladara al SI24». Oficina MADRID CORREDORES NORTE II; INCREMENTO PRIMA negativo a las 13:51:34; impresión plantilla → CONTINUAR → FINALIZAR → ACEPTAR | Pasa salto sin anular; no se aportó archivo firmado en este caso | ss_9b9e3b75.png, ss_be992f83.png, ss_9fd0f014.png |
| 0005726678405 | JJGONZ2 | SCA2 | 15787867 | Detalle tras decisión | Sin CA2 histórica comparable | Alta Finalizada verde; CA1 Finalizada Negativa roja; CA2 Incompleta naranja; Impresion Finalizada roja, en ese orden | CA2 nueva sin RETOMAR/REASIGNAR: pasa criterio delta | E5; ss_c3b6c6ec.png |
| 0005726678405 | SISANS | SCA2 | 15787867 | Visibilidad y botones | SCA 15787862 accesible por póliza pero sólo Alta | Buscador Pendiente naranja; Detalle accesible; CA2 nivel 2, GGE / GGE EXPERTOS SI24, Nuuma JJGONZ2. Sin argumentos ejecutados ni documentos presentados. Sin RETOMAR/REASIGNAR | Igual a JJGONZ2 para nueva CA2; pasa regla de permisos esperada | E6/E10/E12 |

## 3. Resultado del delta CrearAccion

**PASA en UI para la nueva solicitud 15787867.**

- CA1 finalizada negativa y CA2 creada a las **09/10/2026 13:52:42**, nivel **2**.
- Ambos usuarios ven **GGE EXPERTOS SI24**, perfil **GGE**, **Nuuma de usuario JJGONZ2**. Ese Nuuma visible no demuestra asignación de la tarea.
- Se desplegó la CA2 y se revisó su pie en ambas sesiones: **ningún RETOMAR ni REASIGNAR**.
- Ambos ven la solicitud en el buscador, **Pendiente naranja**, sin fecha de resolución.
- CA2 muestra «No hay argumentos para esta gestión» y «No hay documentos a mostrar». En este caso se imprimió plantilla; no se subió documento firmado. No se confunde con 15787861, que sí tenía Carta firmada `0900ab4481a08961`.
- El lead confirmó por record que la tarea nueva tiene `asignadoA=null`, `grupo=CE_MF_BK`. Es una confirmación complementaria del lead, no inferencia a partir de la etiqueta Nuuma.
- La tarea anterior 15787861 no cambia. Su diferencia de permisos queda explicada por la asignación antigua a JJGONZ2.
- **No probado:** finalización de CA2 por SISANS. No tiene permiso según la configuración actual y no se intentó eludirlo.

El lead confirmó que SISANS tiene perfil CE_MF_SI24, distinto de CE_MF_BK, y que el grupo histórico equivalente está vacío en TEST. Por tanto, la ausencia de RETOMAR en SISANS **no se registra como fallo de SCA2**. Queda duda funcional sobre la configuración esperada de grupos o la decisión del motor.

## 4. Incidencias, diferencias y latencias

### 4.1 Alta SISANS: error corregido

Antecedente: `sca2_altasolicitudpage`, a!textField línea 531: `Cannot compare incompatible operands of type Null and type Number (Integer)`.

Después del fix, 0000253500328 abre sin fallo, Canal y Medio comienzan vacíos. **SCA tampoco asigna Canal por defecto a SISANS**. Se seleccionó SI24 en ambas. SCA2 completó el alta y CA propia; SCA llegó al modal **«403 Acceso denegado / No tiene permiso para ver esta página»** después del alta. No se repitió el guardado.

### 4.2 SCA bloquea comparaciones

- 15787859: alta 13:12:31 según ledger del lead; sólo Alta y sin CA en las comprobaciones de la ronda.
- 15787862: alta 13:26:25; seguía sólo Alta a las comprobaciones finales de aproximadamente **13:56**. Se consultó como JJGONZ2 y SISANS, sin repetir GUARDAR.
- 15787864: alta SISANS 13:37:42; Pendiente y sólo Alta, con 403 en la continuación.
- 15787866: alta 13:44:01; aproximadamente 13:55 seguía sólo Alta. No fue posible ejecutar AA.

Son incidencias de SCA TEST, no fallos atribuibles a SCA2. Se cumplió la instrucción de verificar desde buscador/detalle en lugar de volver a guardar.

### 4.3 Candidata AA 15787865: etiqueta engañosa

UI observada en SCA2:

- Buscador: **«Finalizada. Rechazada anulación»**, **rojo**, resolución **09/10/2026 13:44:16**.
- Detalle: únicamente **Alta Solicitud — Finalizada**, **verde**; sin Acción Administrativa ejecutable.
- SCA buscador para la misma solicitud: **Pendiente**, naranja, sin resolución.

**Diagnóstico aportado por el lead al cierre:** el record SCA2 está **ERROR**, no finalizado. CORE rechazó el alta de la gestión **ACCIONES ADMINISTRATIVAS NIVEL 2** por error de BBDD al recibir perfil CE_RM y subperfil CE_MF_SI24_EXPERTO tras la decisión. SCA utiliza la misma regla, pero no avanzó para poder comparar.

**Hallazgo funcional/UI:** la etiqueta de SCA2 induce a interpretar un error técnico como un rechazo final de anulación. No se relanzó ni se repitió la AA; pendiente aclaración funcional/diagnóstico por el lead.

### 4.4 SCA: error al volver desde Detalle

Solicitud **15787866**, póliza **0000253500332**, SISANS, aproximadamente **13:55:58**. Pulsar la flecha de vuelta desde Detalle:

> Error de evaluación de expresión [evaluation ID = 5fcb3:e0748] in rule 'sca_datoscabecera' (called by rules 'sca_detallesolicitud' > 'sca_buscarsolicitudclientepoliza' > 'sca_buscadorsolicitudprincipal') at function a!submitLink [line 23]: Ocurrió un error al ejecutar una operación de guardado: Expression evaluation error: The save target must be a local variable that does not refresh on every evaluation or on an interval, a process variable, or a node input (or a rule input passed one of those three), but instead was: 0000253500332

Se recuperó navegando a la URL de SCA y buscando por póliza. Sin cambios de datos.

### 4.5 Diferencias de presentación y refresco

- SCA muestra fechas del buscador con patrón `2026-10-09 13:...`; SCA2 con `09/10/2026 13:...`.
- En 15787863, SCA muestra resolución **13:39:16**, SCA2 **13:39:18**: diferencia de 2 segundos visible, no interpretada como fallo de negocio.
- SCA dispone los cinco filtros de cliente en una fila; SCA2 los reparte en dos filas. SCA2 ocupa más ancho de página y añade pestaña **Notificaciones** en Detalle; SCA visible no la incluye.
- SCA muestra «Últimas solicitudes gestionadas» del usuario (SISANS: 16 elementos, 10 por página); SCA2 muestra las 10 últimas que incluyen solicitudes JJGONZ2. Las listas no representan el mismo conjunto.
- En la primera parte de la ronda, volver al buscador SCA2 no mostró inmediatamente todo el estado nuevo; reabrir/recargar resolvió la CA positiva 15787858. No se demuestra paridad de ese refresco con SCA, pues su alta no avanzó. En la nueva RCI 15787867, ACEPTAR sí llevó a un listado que incluía la nueva fila Pendiente.
- En el listado JJGONZ2 de SCA2, 15787860 exponía texto técnico `Consulta NEW: codMotivo ... codDetalle ... codCausa ...` en Observaciones; SISANS mostraba la observación de alta «Ronda7 SCA2 normal NEGATIVO documento TEST». Diferencia visible entre sesiones, pendiente aclarar fuente/actualización.
- Estados visibles de 15787867: Alta verde, CA1 negativa roja, CA2 incompleta naranja, Impresion Finalizada roja. No se pudo comparar con el mismo recorrido histórico de SCA.

## 5. Cobertura que sigue pendiente

- CA positiva/negativa normal histórica SCA y comparación completa de sus documentos/popups finales.
- RCI SCA 15787862: CA1 negativa y CA2; comparación runtime de quién ve RETOMAR/REASIGNAR en nivel 2.
- CA2 como SISANS: POSPONER/RETOMAR y finales positivo/negativo bloqueados por permisos esperados actuales. No son fallos del delta.
- Permiso inverso SISANS sobre una CA1 abierta asignada a JJGONZ2: sin comprobación concluyente.
- Acción Administrativa completa de SISANS: bloqueada por error CORE SCA2 y proceso SCA sin avanzar. No repetir hasta aclaración.
- Recepción del correo DUE: **no verificada**; el aviso SI24 no prueba entrega de correo.
- No se hizo anulación externa ni se probó el botón ANULAR PÓLIZA, por instrucción expresa.
- No se cambiaron grupos, no se probó reasignación real ni se inspeccionó la bandeja administrativa con estos usuarios no administradores.

## 6. Preguntas funcionales / acciones para el lead

1. ¿Debe SISANS pertenecer a BK_EXPERTO_SI24, o debe el motor devolver SI24_EXPERTO en estos acuerdos? Actualmente la configuración impide gestionar CA2 con los dos usuarios autorizados.
2. Corregir/aclarar la representación de `estadoSolicitud=ERROR` en buscador: 15787865 no debe aparentar rechazo final exitoso.
3. Aclarar perfil/subperfil de AA nivel 2 y el error CORE de 15787865, comparando con 15787866 sólo cuando SCA avance. No volver a crear AA SISANS mientras tanto.
4. Investigar procesos SCA que quedan sólo con Alta y el error de flecha volver. No repetir GUARDAR.
5. Confirmar si diferencias de fuentes de fecha de resolución/Observaciones y alcance de últimas solicitudes son las deseadas.

## 7. Evidencia visual

### E1/E2 — Alta SISANS: mismo Canal seleccionado, Medio vacío

| SCA | SCA2 corregido |
|---|---|
| ![E1 SCA alta SISANS](https://mapfre.devinenterprise.com/attachments/732549d4-d9ce-48c3-98e6-44c556e7f5d6/ss_6d7d7315.png) | ![E2 SCA2 alta SISANS](https://mapfre.devinenterprise.com/attachments/eba076a3-084a-4c53-96b1-d0c60d57c7be/ss_6348b255.png) |

### E3/E4 — Resultado SISANS: flujo SCA bloqueado, SCA2 positivo

| SCA — 403 | SCA2 — CA positiva |
|---|---|
| ![E4 SCA 403](https://mapfre.devinenterprise.com/attachments/fa1d8ba0-47b7-4800-a0ed-45a2f187c8f1/ss_ddc222e7.png) | ![E3 SCA2 positiva](https://mapfre.devinenterprise.com/attachments/bccc99ee-d785-412e-9538-6cbf5df1dfcc/ss_03606ab6.png) |

### E5/E6 — CA2 nueva 15787867: sin acciones en ambas sesiones

| JJGONZ2 | SISANS |
|---|---|
| ![E5 CA2 JJGONZ2](https://mapfre.devinenterprise.com/attachments/75eaae7e-ffcf-44c1-9ed3-355b1ad201f3/ss_67e16293.png) | ![E6 CA2 SISANS](https://mapfre.devinenterprise.com/attachments/db392ade-a3b0-4529-8ce0-bba0dc947345/ss_7eec58e7.png) |

### E7/E8 — Candidata AA: sólo Alta

| SCA 15787866 | SCA2 15787865 |
|---|---|
| ![E8 SCA candidata AA](https://mapfre.devinenterprise.com/attachments/3cd8a0e3-d609-4ebc-a95f-c4fd77f1396b/ss_e1357c91.png) | ![E7 SCA2 candidata AA](https://mapfre.devinenterprise.com/attachments/09f46415-e26c-46dd-bf80-798687cb8961/ss_692a7363.png) |

### E9/E10 — Buscadores SISANS: diferencia de estado 15787865

| SCA — Pendiente naranja | SCA2 — Finalizada. Rechazada anulación roja |
|---|---|
| ![E9 SCA buscador](https://mapfre.devinenterprise.com/attachments/b7e8081e-ab4c-4228-8921-b62816f9903e/ss_df775517.png) | ![E10 SCA2 buscador](https://mapfre.devinenterprise.com/attachments/08e7844d-7709-4770-b553-64e4fdf1a488/ss_f0ef2c72.png) |

### E11/E12 — Bloqueos SCA

| SCA — Error al volver 15787866 | SCA — 15787862 continúa sólo Alta |
|---|---|
| ![E11 error volver](https://mapfre.devinenterprise.com/attachments/d0d8ba22-b8cb-427e-90fd-43abb23ec9c4/ss_1c715101.png) | ![E12 RCI sin CA](https://mapfre.devinenterprise.com/attachments/52d7bc1b-e63b-43fd-a143-5321f87c0fef/ss_31cfac4a.png) |

## 8. Grabación y entrega

- Grabación vigente de continuación: `sca-ronda7-sisans-continuacion-edited.mp4`. Incluye la verificación del alta SISANS corregida y el delta RCI nuevo, con anotaciones. Las tareas antiguas se distinguen por número CORE.
- No se presenta una grabación pre-corrección como evidencia de la versión corregida.
- Capturas adicionales se identifican por nombre en las tablas; las rutas absolutas para entrega se proporcionan al lead aparte.
- Comentario PR sugerido: ninguno; no se indicó PR abierto.
- SKILL.md adicional: ninguno en esta continuación.
- Blueprint consultado: no se instalaron dependencias ni se iniciaron servicios. Sugerencia de configuración/documentación para futuras rondas: incluir dos sesiones Chrome aisladas, SSO NOPRO y comprobación del avatar JG/SS; la configuración MCP existente no documenta este requisito UI.
- Necesario del usuario para ampliar cobertura: decisiones funcionales de grupos y AA anteriores. No se necesitan credenciales nuevas para entregar el informe.

## Ronda 7b — validaciones de fecha al GUARDAR

Prueba UI en Appian TEST con JJGONZ2, póliza **0001047017036**, el 09/10/2026. No se modificaron objetos ni código. Se completó el procedimiento con **fallo del alta válida por 403**; no queda demostrado el recorrido completo hasta Contra Anulación.

### Datos y combinación

- Fecha efecto visible: **02/03/2026**; vencimiento: **02/03/2027**; último siniestro: `-`.
- DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA ofrecía A EFECTO con fecha bloqueada. No se guardó con esa combinación.
- Con autorización del lead se usó en ambas aplicaciones **DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE**, canal **PRESENCIAL**, catalogación **A FECHA**. Fecha propuesta: **09/10/2026**.

### Comparación paso a paso

| Póliza | Usuario | App | Paso | Resultado SCA | Resultado SCA2 | Igual/diferente | Evidencia |
|---|---|---|---|---|---|---|---|
| 0001047017036 | JJGONZ2 | SCA / SCA2 | GUARDAR con 01/01/2024 | Tras VOLVER del popup de simulación, conserva la fecha antigua y muestra el error de 18 meses | Error rojo de 18 meses, permanece en Alta sin navegación ni número CORE | Mismo texto de validación; recorrido SCA distinto por popup | F1/F2 |
| 0001047017036 | JJGONZ2 | SCA2 | GUARDAR con 03/03/2027 | No probado | Error rojo por superar vencimiento 02/03/2027; permanece en Alta | Sin comparación | F3 |
| 0001047017036 | JJGONZ2 | SCA2 | Buscar póliza tras los dos rechazos | No comprobado en buscador SCA | «No hay resultados para dicha búsqueda» | Confirma ausencia visible en UI; no es consulta independiente a CORE | F4 |
| 0001047017036 | JJGONZ2 | SCA2 | Restaurar 09/10/2026 y GUARDAR una vez | No se creó alta válida en SCA | **403 Acceso denegado — No tiene permiso para ver esta página**, alrededor de 14:23 TEST; no abrió CA | **FALLA** el recorrido esperado | F5 |
| 0001047017036 | JJGONZ2 | SCA2 | Buscar póliza tras 403 | No probado | Sigue «No hay resultados para dicha búsqueda» | Sin número CORE confirmado; no se repitió GUARDAR | F6 |

### Textos exactos y observaciones

1. SCA2, fecha antigua: **«Se han detectado los siguientes errores: La fecha de anulación no puede ser más antigua de los 18 meses anteriores a la fecha de hoy.»**
2. SCA2, fecha posterior: **«Se han detectado los siguientes errores: La fecha de anulación no puede ser superior a la fecha de vencimiento de la póliza.»**
3. SCA mostró inicialmente un popup: **«NEW nos indica un error al realizar la simulación de la póliza. Se continúa con el proceso de anulación, si finalmente va a anular, por favor compruebe la situación de la póliza antes de finalizar para evitar posibles errores.»** Se pulsó **VOLVER**, no ACEPTAR. La captura posterior confirma **01/01/2024** y el error de 18 meses. El texto final coincide, pero no se declara equivalencia completa del flujo de GUARDAR.
4. El error anterior SCA2 permanece al editar la fecha hasta volver a GUARDAR; al guardar 03/03/2027 sí cambió al error correcto. Tras el 403 permanecía detrás del modal el error anterior de vencimiento; no se interpreta como una nueva validación de 09/10/2026.
5. No se pulsó **ANULAR PÓLIZA**, no se finalizaron gestiones y no se repitió el intento de alta válida. No hay solicitud nueva confirmada en esta subronda.

### Evidencia visual

| F1 — SCA: fecha antigua tras VOLVER | F2 — SCA2: fecha antigua rechazada |
|---|---|
| ![F1 SCA 18 meses](https://mapfre.devinenterprise.com/attachments/0eec7c1e-4401-4bfb-bd24-412b42370a76/ss_168ee0a4.png) | ![F2 SCA2 18 meses](https://mapfre.devinenterprise.com/attachments/12db03e5-1b0c-432c-8862-aa94c3a6b2d0/ss_32a214a9.png) |

| F3 — SCA2: posterior al vencimiento | F4 — SCA2: sin solicitud tras fechas inválidas |
|---|---|
| ![F3 Vencimiento](https://mapfre.devinenterprise.com/attachments/32126402-992a-4358-911d-d40b8692daa6/ss_0cee056f.png) | ![F4 Búsqueda antes de alta válida](https://mapfre.devinenterprise.com/attachments/464b4a15-0f69-4f24-8776-560f418d0359/ss_722a2f16.png) |

| F5 — SCA2: 403 con fecha válida | F6 — SCA2: búsqueda después del 403 |
|---|---|
| ![F5 403 alta válida](https://mapfre.devinenterprise.com/attachments/80153012-ae5d-4fef-820a-6f21501236fc/ss_751f9174.png) | ![F6 Búsqueda tras 403](https://mapfre.devinenterprise.com/attachments/a6e6f260-994c-4151-9ff8-4ccfb99d7b22/ss_3261f831.png) |

| F7 — SCA: popup previo | Alcance |
|---|---|
| ![F7 Simulación SCA](https://mapfre.devinenterprise.com/attachments/fc5cc9da-f2f5-4219-be24-98d5aece72b3/ss_637ea623.png) | Se canceló mediante VOLVER; no se autorizó una creación SCA. |

### Cobertura pendiente y entrega

- **PASA:** validaciones visibles de 18 meses y vencimiento en SCA2; ausencia de solicitud en buscador tras ambos rechazos; texto final de 18 meses comparable a SCA.
- **FALLA:** alta válida y navegación a CA por 403. Requiere diagnóstico de permisos/proceso y confirmar ledger antes de cualquier nuevo GUARDAR.
- **NO PROBADO:** PRRA 4022 y envío 3/8/19, aviso de impago, validación aislada anterior al efecto y anterior al último siniestro. Esta póliza no permitió comprobar esas ramas; no se infiere su funcionamiento.
- Grabación de esta subronda: `sca-ronda7b-fechas-guardar-edited.mp4`, con anotaciones de ambos rechazos, comparación SCA y fallo 403.
- Comentario PR sugerido: ninguno; no se indicó PR.
- SKILL.md adicional: ninguno.
- Blueprint organizacional consultado. Sin instalaciones ni servicios nuevos; se reutilizó Chrome autenticado. Continúa siendo útil documentar sesiones SSO NOPRO aisladas, no descritas en el blueprint MCP.
- Necesario del usuario: ninguno para entregar; para completar el paso válido se necesita resolver el 403 y autorizar la continuación sin duplicar una posible alta en curso.

### Repetición autorizada del paso 3 — simulación PRRA retirada

El lead comunicó la retirada de la detección PRRA desde `SCA2_AltaSolicitudPage`, manteniendo las validaciones de fecha. Se reabrió el alta desde el buscador para cargar la versión publicada. Se repitió **sólo el paso 3**, con JJGONZ2; no se repitieron fechas inválidas ni comparación SCA.

| Póliza | Usuario | App | Paso | Resultado SCA | Resultado SCA2 | Evidencia |
|---|---|---|---|---|---|---|
| 0001047017036 | JJGONZ2 | SCA2 | Misma combinación DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE | No repetido | Canal PRESENCIAL; A FECHA propone **09/10/2026**, sin editar la fecha | R1 |
| 0001047017036 | JJGONZ2 | SCA2 | GUARDAR una sola vez, ~14:30 TEST del 09/10/2026 | No repetido | **FALLA:** no aparece 403, pero devuelve **ALTA_ERROR** en `generarStudAnul`, referencia **PDTE-14230000**; permanece en alta, GUARDAR deshabilitado, sin navegar a CA | R2 |
| 0001047017036 | JJGONZ2 | SCA2 | Nueva pestaña de buscador, búsqueda por póliza | No repetido | **«No hay resultados para dicha búsqueda»**; sin número CORE confirmado por UI | R3 |

Mensaje exacto:

> Los datos no se han podido guardar correctamente. La solicitud no se ha podido crear. Error: ALTA_ERROR - Los datos pasados como parametro no son los esperados (paso: generarStudAnul). Póliza: 0001047017036. Referencia: PDTE-14230000. Reporte este error a mantenimiento SCA.

El 403 **no se reprodujo en este intento**, pero el flujo válido continúa bloqueado por un error distinto. No se demuestra creación ni navegación a Contra Anulación. No se pulsó de nuevo GUARDAR, ANULAR PÓLIZA ni FINALIZAR. No se investigó ni corrigió el backend desde esta sesión de pruebas.

| R1 — Fecha propuesta antes de GUARDAR | R2 — Error tras el único GUARDAR |
|---|---|
| ![R1 Preparación válida](https://mapfre.devinenterprise.com/attachments/5016f148-a403-4574-a8ae-b94f0894fdf3/ss_311cae6f.png) | ![R2 ALTA_ERROR](https://mapfre.devinenterprise.com/attachments/4520120e-c963-4983-9196-2f32f0babf87/ss_79c144d4.png) |

| R3 — Buscador después del error | Resultado |
|---|---|
| ![R3 Sin resultados](https://mapfre.devinenterprise.com/attachments/fa2b2e7f-6e72-4a08-8a31-7f4966d0e4e2/ss_3403e82b.png) | Sin número CORE visible; comprobar ledger antes de otro intento. |

- Grabación actual de la repetición: `sca-ronda7b-alta-sin-prra-edited.mp4`. La grabación anterior sólo documenta la versión anterior, no este cambio.
- Pendiente: diagnóstico de `ALTA_ERROR / generarStudAnul`, referencia `PDTE-14230000`, y autorización de continuación. No se necesita una nueva credencial para entregar.
- Comentario PR sugerido y SKILL.md adicional: ninguno.
- Blueprint ya consultado; sin instalaciones, configuración persistente ni servicios nuevos en esta repetición.

### Repetición autorizada del paso 3 — fecImpagoPCA=null

Tras la corrección comunicada en `SCA2_construirContextoAlta`, se reabrió el alta SCA2 con JJGONZ2 y la misma póliza. Sólo se ejecutó el paso 3: **un único GUARDAR**, sin repetir validaciones inválidas ni SCA. Se añadió la observación de trazabilidad `Ronda7b TEST alta fecImpagoPCA null`.

**Resultado parcial: solicitud CORE 15787868 creada, pero la navegación fue a Acciones administrativas, no a Contra Anulación.** No reaparecieron 403 ni ALTA_ERROR. La combinación VENTA DEL VEHICULO podía decidir AA (advertido en el ajuste del plan); no se atribuye esta decisión a un defecto sin confirmación funcional. El criterio literal de navegación a CA no quedó cumplido.

| Póliza | Usuario | App | Paso | Resultado SCA | Resultado SCA2 | Igual/diferente | Evidencia |
|---|---|---|---|---|---|---|---|
| 0001047017036 | JJGONZ2 | SCA2 | Preparación | No repetido | DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE; PRESENCIAL, A FECHA, propuesta **09/10/2026** sin editar | Misma combinación que repetición anterior | N1 |
| 0001047017036 | JJGONZ2 | SCA2 | GUARDAR una vez | No repetido | **PASA creación:** número **15787868**, fecha visible en buscador **09/10/2026 14:35:48**. Sin 403 ni ALTA_ERROR; navegación observada aproximadamente dentro de un minuto | Diferente al error anterior | N2, N5 |
| 0001047017036 | JJGONZ2 | SCA2 | Destino automático | No repetido | **No cumple destino CA esperado:** abre **Acciones administrativas**, sin ejecutar acción en ella | Decisión AA pendiente de confirmar; no comparación nueva con SCA | N2 |
| 0001047017036 | JJGONZ2 | SCA2 | Consulta de solicitud y Detalle | No repetido | Solicitud **PENDIENTE**, nivel 1, A FECHA 09/10/2026; Alta **Finalizada**, AA **Incompleta**. Cabecera muestra **Origen IMPAGO** y fecha efecto recibo impago **-** | Origen IMPAGO observado, no se infiere el payload | N3, N4 |
| 0001047017036 | JJGONZ2 | SCA2 | Volver al buscador sin finalizar | No repetido | **15787868 Pendiente**, naranja, póliza correcta y observación de esta prueba | Creación visible confirmada | N5 |

Se dejó la gestión sin finalizar. No se pulsó ANULAR PÓLIZA, FINALIZAR, POSPONER ni un segundo GUARDAR. Se consultó únicamente Solicitud Anulación, VOLVER AL DETALLE y vuelta al buscador para obtener número y estado. No se verificó el payload interno `fecImpagoPCA`; se prueba el resultado visible tras la publicación comunicada.

| N1 — Fecha propuesta antes del único GUARDAR | N2 — Destino automático: Acciones administrativas |
|---|---|
| ![N1 Preparación](https://mapfre.devinenterprise.com/attachments/e428398f-fdeb-4323-b774-737964060b50/ss_12b49d1e.png) | ![N2 AA](https://mapfre.devinenterprise.com/attachments/3c430945-55b9-47ce-8525-d286d39bac2a/ss_48d2ad4a.png) |

| N3 — Solicitud pendiente, origen IMPAGO | N4 — Alta Finalizada y AA Incompleta |
|---|---|
| ![N3 Cabecera](https://mapfre.devinenterprise.com/attachments/4bcfd461-acb7-4db4-a711-9b0cfc5b5983/ss_36192d55.png) | ![N4 Detalle](https://mapfre.devinenterprise.com/attachments/fd1265b0-3a41-4a7c-8ef4-ce7701d556f5/ss_27a97de7.png) |

| N5 — CORE 15787868 visible en buscador | Alcance |
|---|---|
| ![N5 Creación confirmada](https://mapfre.devinenterprise.com/attachments/0792b29e-cca8-4a95-92e2-907f4dee29e8/ss_364380cf.png) | Un único GUARDAR; sin finalizar ni anular. |

- Grabación de esta repetición: `sca-ronda7b-alta-impago-null-edited.mp4`.
- Pendiente funcional: confirmar AA como decisión correcta para la combinación elegida y el origen IMPAGO mostrado. No realizar otra alta en esta póliza.
- Validaciones inválidas, SCA, PRRA y finalización no repetidos, conforme al alcance.
- Comentario PR sugerido: ninguno; no se indicó PR.
- SKILL.md adicional: ninguno. Blueprint previamente consultado; no se instalaron dependencias ni iniciaron servicios en esta repetición.
- Necesario del usuario: ninguno para entregar; sólo confirmación funcional si se quiere cerrar la discrepancia del destino.

## Ronda 7c — SISANS

Prueba por UI real en Appian TEST, con SISANS (SI24 Experto, avatar SS) en sesión Chrome aislada. **Ejecución con cobertura parcial:** CA propia SCA2 completada; comparación equivalente SCA bloqueada por latencia tras GUARDAR. Ningún ANULAR PÓLIZA, ningún segundo GUARDAR de alta, ninguna modificación de objetos Appian.

### Resultado y límites

- **PASA:** SCA2 `0001047017037 → 15787869`: alta única, apertura CA, POSPONER → RETOMAR → finalización positiva. Buscador **Finalizada positivamente**, verde; Detalle **Alta Finalizada / Contra Anulacion Finalizada Positiva**, verde.
- **FALLA / limitación SCA:** `0001047017038 → 15787870`: tras único GUARDAR permaneció **Aún procesando más de 90 segundos** (captura a ~100 s). Reabrir buscador mostró CORE 15787870, **Pendiente**, fecha 09/10/2026 14:52:57; Detalle sólo **Alta Solicitud Finalizada**. No hubo CA disponible para comparar Oficina, argumentos, POSPONER, RETOMAR y FINALIZAR. No se repitió alta.
- **NO PROBADO por ausencia de acciones:** AA SCA2 `15787868`, grupo OFICINA / perfil RED MAPFRE / Nuuma JJGONZ2, no muestra RETOMAR ni REASIGNAR a SISANS. No se adjuntaron DNI ni otro documento ni se probó persistencia documental, FINALIZAR o destino Decidir Acción.
- **PASA control esperado:** CA2 SCA2 `15787867` **Incompleta**, nivel 2, perfil GGE, grupo GGE EXPERTOS SI24, Nuuma JJGONZ2, sin RETOMAR/REASIGNAR. El Nuuma mostrado no demuestra asignación de tarea; el lead confirmó previamente grupo interno CE_MF_BK y asignadoA=null. No se considera fallo de SCA2.
- **Comparación de permisos SCA inconclusa:** `15787862`, `15787866` y `15787859` mostraron únicamente Alta Finalizada, sin RETOMAR/REASIGNAR. La precondición «15787859 en CA» no se cumplió visualmente. No es evidencia de denegación SI24 sobre una tarea CE_RM abierta, porque no hubo tarjeta de gestión pendiente.
- **Duda de datos de la muestra:** aunque la petición agrupaba las tres solicitudes SCA como creadas por JJGONZ2, `15787866` muestra Nuuma **SISANS**, perfil SI24 y grupo SI24 EXPERTOS; coincide con el alta realizada con SISANS en ronda 7. No usarla como prueba de autor distinto.

### Tabla comparativa

| Paso / pólizas / CORE | SCA | SCA2 | Igual / diferente | Evidencia |
|---|---|---|---|---|
| AA ajena, 0001047017036 / 15787868 | No se ejecuta gestión equivalente, al no poder completarla en SCA2 | AA Incompleta, nivel 1, RED MAPFRE / OFICINA / JJGONZ2; sin RETOMAR/REASIGNAR; sin documentos | Sin comparación válida de gestión | C1 |
| Acceso SISANS a 0005726674052 / 15787862 | Alta Finalizada; 09/10/2026 13:26:25 inicio y fin; nivel 1; RED MAPFRE / OFICINA / JJGONZ2. Sin CA ni acciones | Control nivel 2 15787867 descrito abajo | Diferente estado de proceso; permisos no comparables | C2 |
| Acceso SISANS a 0000253500332 / 15787866 | Sólo Alta Finalizada; SI24 / SI24 EXPERTOS / SISANS; sin RETOMAR/REASIGNAR | AA 15787868 sigue Incompleta sin acciones para SISANS | No equivalentes ni mismo creador | C3, C1 |
| Acceso SISANS a 0000253500285 / 15787859 | Sólo Alta Finalizada, inicio/fin 09/10/2026 13:12:31, RED MAPFRE / OFICINA / JJGONZ2. Cabecera PENDIENTE, nivel 1, A VENCIMIENTO 12/01/2027 | No nueva acción equivalente | Precondición CA no cumplida; no se puede pulsar RETOMAR | C4 |
| Alta propia, SCA 0001047017038 / SCA2 0001047017037 | DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA; Canal vacío inicialmente, SI24 seleccionado; Medio vacío/deshabilitado; A VENCIMIENTO 02/03/2027 | Misma combinación, Canal SI24 seleccionado, Medio vacío/deshabilitado, misma fecha/catalogación | Igual preparación | C5, C10 |
| GUARDAR propio una vez | 15787870 creada, pero formulario procesando >90 s y sólo Alta en Detalle | 15787869 creada y CA abierta | Diferente continuación | C5, C6, C7 |
| Oficina / compañía contraria | CA no disponible | Sin selector Oficina disponible; compañía contraria vacía. No se seleccionó compañía ni se comprobó persistencia de un valor no vacío | No comparable; Oficina seleccionada no verificable | C8, C10 |
| Argumentos CA | No disponible | 7 filas principales: INCREMENTO PRIMA (obligatorio SI), SERVICIOS MAPFRE, GESTION COMPETENCIA, SUPLEMENTO EN GENERAL, CLUB MAPFRE PLATA, CAMBIO DE FORMA DE PAGO y REDUCCION DE COBERTURAS. Estado inicial Pendiente | No comparable | C8 |
| POSPONER → Detalle → RETOMAR | No probado, sin CA | Confirmación y banner CORRECTO; conserva observación «Ronda7c SISANS posponer y retomar CA propia», A VENCIMIENTO y 02/03/2027. RETOMAR visible y apertura de CA. Oficina no disponible antes/después | Pasa SCA2 con límite Oficina; SCA sin cobertura | C9 |
| Argumentos y documentos en Detalle tras POSPONER | No probado | Detalle lista 11 argumentos (10 en primera página), incluyendo subargumentos, inicialmente Pendiente; no documentos. La pantalla de CA tenía 7 filas principales. No se interpreta esa diferencia como duplicado sin especificación | Observación interna SCA2; SCA no comparable | C8, C9 |
| FINALIZAR POSITIVO | No probado; no se completó ninguna tarea SCA | Confirmación de finalización positiva; buscador Finalizada positivamente y CA Finalizada Positiva en verde. Fecha resolución visible SCA2 09/10/2026 14:48:21 | Pasa SCA2; SCA bloqueado | C11, C12 |
| Control nivel 2, 0005726678405 / 15787867 | 15787862 sólo Alta, sin referencia CA2 disponible | CA2 Incompleta; inicio 09/10/2026 13:52:42; fin «-»; nivel 2; GGE / GGE EXPERTOS SI24 / JJGONZ2; «No hay argumentos para esta gestión», «No hay documentos a mostrar», observaciones «-»; sin acciones | Pasa restricción esperada SCA2; comparación SCA inconclusa | C13 |

No se probó ejecución individual de todos los argumentos ni aplicaciones externas. En CA propia SCA2 Carta firmada y Dni figuraban sin entregar; no se adjuntaron documentos. La prueba documental solicitada correspondía a AA y quedó bloqueada por permiso. El estado final positivo prueba el cierre visible, no la recepción de correos ni efectos externos.

### Evidencia visual

| C1 — SCA2 AA ajena sin acciones | C13 — SCA2 CA2 sin acciones |
|---|---|
| ![C1 AA SISANS](https://mapfre.devinenterprise.com/attachments/15b7ede9-3d77-4ade-bcaa-e73e1095f5d4/ss_d87f5502.png) | ![C13 CA2 SISANS](https://mapfre.devinenterprise.com/attachments/842c1762-0d3a-4426-b868-69e58d40f726/ss_009ff8bd.png) |

| C2 — SCA 15787862 sólo Alta | C3 — SCA 15787866 sólo Alta / SISANS |
|---|---|
| ![C2 RCI SCA](https://mapfre.devinenterprise.com/attachments/73f90a1c-4ad2-4ca6-aff4-7f8d8e30e654/ss_bfbde5ba.png) | ![C3 Alta SISANS](https://mapfre.devinenterprise.com/attachments/b48f4cab-6d21-4d1c-acb3-b6f2aa7e7dba/ss_d7e5f992.png) |

| C4 — SCA 15787859 sin CA | C5 — SCA alta propia procesando >90 s |
|---|---|
| ![C4 Sin CA](https://mapfre.devinenterprise.com/attachments/55b2d0b9-55bd-483b-8c27-1c0777a1bbc1/ss_7e3666e1.png) | ![C5 Latencia SCA](https://mapfre.devinenterprise.com/attachments/193ee8c1-d815-4f39-8fa7-d4d368708f73/ss_c0384787.png) |

| C6 — SCA 15787870 Pendiente | C7 — SCA 15787870 sólo Alta |
|---|---|
| ![C6 CORE creado](https://mapfre.devinenterprise.com/attachments/9ec613ba-aed8-4c65-82cf-620b4c69c2d5/ss_3671ed5f.png) | ![C7 Sin continuación CA](https://mapfre.devinenterprise.com/attachments/eeaf0365-53e1-4d79-a41d-8f62cafe1095/ss_d67a12f8.png) |

| C8 — SCA2 argumentos / documentos | C9 — SCA2 observación guardada y RETOMAR |
|---|---|
| ![C8 CA propia](https://mapfre.devinenterprise.com/attachments/8a365456-fd0c-4e6e-900e-01386261e811/ss_4328f352.png) | ![C9 Retomar](https://mapfre.devinenterprise.com/attachments/c832bf5b-25bf-4a06-98be-3e65d8746cc7/ss_f3e77105.png) |

| C11 — SCA2 15787869 finalizada positiva | C12 — SCA2 Detalle final positivo |
|---|---|
| ![C11 Buscador](https://mapfre.devinenterprise.com/attachments/715b347c-1b5b-44f3-9c75-feb26d889bad/ss_849893fd.png) | ![C12 Detalle](https://mapfre.devinenterprise.com/attachments/61a2e08c-f2af-4e63-b997-348b34c92a73/ss_9d34ffd2.png) |

### Paths y seguimiento

- Informe: `/home/ubuntu/sca2work/r11/informe-testing-agent.md`.
- Grabación única de esta ronda: `/home/ubuntu/screencasts/sca-ronda7c-sisans/sca-ronda7c-sisans-edited.mp4`.
- Capturas C1/C2/C3/C4/C5/C6/C7/C8/C9/C11/C12/C13: `/home/ubuntu/screenshots/ss_d87f5502.png`, `/home/ubuntu/screenshots/ss_bfbde5ba.png`, `/home/ubuntu/screenshots/ss_d7e5f992.png`, `/home/ubuntu/screenshots/ss_7e3666e1.png`, `/home/ubuntu/screenshots/ss_c0384787.png`, `/home/ubuntu/screenshots/ss_3671ed5f.png`, `/home/ubuntu/screenshots/ss_d67a12f8.png`, `/home/ubuntu/screenshots/ss_4328f352.png`, `/home/ubuntu/screenshots/ss_f3e77105.png`, `/home/ubuntu/screenshots/ss_849893fd.png`, `/home/ubuntu/screenshots/ss_9d34ffd2.png`, `/home/ubuntu/screenshots/ss_009ff8bd.png`.
- C10, pantalla CA SCA2 sin Oficina y compañía vacía: `/home/ubuntu/screenshots/ss_32cc4a2b.png`. Alta inicial SCA2: `/home/ubuntu/screenshots/ss_88e87d19.png`.
- No confundir la pestaña antigua de SCA `0000253500332`, todavía con 403 de la ronda anterior, con el alta 7c `0001047017038`: el fallo observado en esta última fue latencia, no un nuevo 403.
- Comentario PR sugerido: ninguno; no hay PR indicado.
- SKILL.md adicional: ninguno.
- Blueprint organizacional consultado. Sin instalaciones ni servicios nuevos. Sugerencia: documentar aislamiento de sesiones Chrome y SSO NOPRO para pruebas multiusuario, no cubiertos por el launcher MCP.
- Necesario del usuario para entregar: ninguno. Para ampliar cobertura: confirmar permiso esperado de SISANS sobre AA de OFICINA/CE_RM y Oficina disponible para SI24; resolver continuación SCA de 15787870 antes de autorizar más pruebas. **No repetir GUARDAR ni crear otra solicitud de estas pólizas.**

## Ronda 7d — buscador CORE

Prueba UI de sólo lectura con **JJGONZ2**, sesión confirmada como Juan Gonzalez, en Appian TEST. Ejecutadas las tres comprobaciones obligatorias y la opcional por cliente. **Sin altas, GUARDAR, RETOMAR, FINALIZAR ni ANULAR PÓLIZA.** No se modificaron objetos Appian.

**Observación de acceso:** la URL solicitada `/suite/sites/sca` redirigió a SCA2; la comparación histórica se realizó en `/suite/sites/sca-site`, que sí cargó SCA. No se observaron 403 ni errores de expresión en estas búsquedas.

### Resultado paso a paso

| Paso / póliza / solicitud | SCA histórico | SCA2 | Igual-diferente / resultado | Evidencia |
|---|---|---|---|---|
| 1. Póliza 0000253500329 → BUSCAR SOLICITUD | Referencia del paso 3 | Principal vacía: «No hay resultados para dicha búsqueda». Debajo aparece «Otras solicitudes de la póliza / cliente (SCA e históricas en CORE, sin gestión en SCA2)», una fila 15787864 | **PASA** visibilidad y separación | D1 |
| Estado y datos de 15787864 | Pendiente, tag naranja; Automóviles | Pendiente, tag naranja; fecha solicitud 09/10/2026; póliza 0000253500329; Automóviles; causa «Me Ha Subido Mucho La Prima» | **PASA** número, estado y columnas requeridas | D1, D3 |
| Fila CORE sin gestión SCA2 | En SCA el número sí es enlace | 15787864 es texto, sin enlace en DOM; clic no navega | **PASA** diferencia intencionada | D1, grabación |
| 2. Póliza 0001047017036 → BUSCAR SOLICITUD | No requerido | Principal contiene 15787868 Pendiente. BUSCAR abre automáticamente Detalle, con Alta Finalizada y AA Incompleta. Flecha vuelve sin error y reinicia filtros; se reintroduce póliza y se captura principal filtrada. No sección «Otras solicitudes…» | **PASA**, sin duplicado en la secundaria para este caso | D2 |
| 3. Póliza 0000253500329 → BUSCAR en SCA | Abre Detalle automáticamente. «Solicitud Anulación» indica PENDIENTE; «Otras sol. Anulación» contiene una fila 15787864, Pendiente naranja, misma póliza y Automóviles | La misma 15787864 Pendiente en tabla secundaria del buscador | **PASA** identidad y estado. Pantallas distintas por autonavegación de SCA | D3, D4 |
| 4. Opcional Cliente → N.I.F. + documento leído de cabecera SCA → BUSCAR en SCA2 | Documento tomado de la cabecera de la póliza 0000253500329 | Principal vacía; secundaria contiene una fila 15787864, misma póliza, Pendiente naranja, causa y fechas del paso 1 | **PASA** búsqueda por cliente | D5 |

### Diferencias observadas para 15787864

| Campo | SCA, «Otras sol. Anulación» del Detalle | SCA2, tabla secundaria CORE |
|---|---|---|
| Número / estado | 15787864 / Pendiente | 15787864 / Pendiente: iguales |
| Tag | Fondo naranja, texto blanco | Fondo naranja, texto negro: diferencia visual |
| Fecha solicitud | 09/10/2026 **13:37:42** | 09/10/2026: sin hora |
| Fecha resolución | 09/10/2026 **13:37:42** | 09/10/2026: sin hora |
| Causa | ME HA SUBIDO MUCHO LA PRIMA | Me Ha Subido Mucho La Prima: sólo cambia capitalización |
| Número póliza / línea | 0000253500329 / Automóviles | Iguales |
| Navegación | Número enlazado a Detalle | Texto sin enlace, conforme al cambio |
| Observaciones | No hay columna en esa tabla del Detalle SCA | Columna con «-» |

SCA muestra «MÁS PRIMA» en la pestaña **Solicitud Anulación** y la descripción larga en **Otras sol. Anulación**; no son estados distintos. También muestra Alta Finalizada como estado de gestión, mientras la solicitud sigue PENDIENTE. Ambos listados muestran fecha de resolución pese a Pendiente: no es una discrepancia introducida por la nueva tabla; no se validó aquí la semántica de esa fecha CORE.

**Cobertura delimitada:** comprobados un resultado CORE-only y un resultado ya existente SCA2, además de cliente con una solicitud. No se probaron paginación/múltiples páginas, otros estados CORE, filtros Estado/Línea sobre la secundaria ni todos los históricos. Ningún error de pantalla durante los flujos comprobados. La vuelta de SCA2 limpia el filtro, por lo que D2 se capturó tras reintroducirlo sin volver a activar la autonavegación.

### Evidencia visual

| D3 — SCA: misma solicitud, Pendiente | D1 — SCA2: principal vacía y tabla CORE |
|---|---|
| ![D3 SCA 15787864](https://mapfre.devinenterprise.com/attachments/fab1c00d-c626-44ca-be73-373aefce3764/ss_e449ffb6.png) | ![D1 SCA2 15787864 CORE](https://mapfre.devinenterprise.com/attachments/f4155c44-4fb4-4c98-a363-41aa5414ed6b/ss_59810a5e.png) |

| D2 — SCA2: 15787868 sólo principal | D5 — SCA2: búsqueda por cliente |
|---|---|
| ![D2 Sin duplicado](https://mapfre.devinenterprise.com/attachments/e914d2ae-1efb-4887-9a3d-27afa67e2a12/ss_034f9a6b.png) | ![D5 Cliente con solicitud CORE](https://mapfre.devinenterprise.com/attachments/07da3857-7c6b-4d76-a606-d0d936a7ca40/ss_7f07ccf2.png) |

| D4 — SCA: estado de solicitud | Observación |
|---|---|
| ![D4 SCA PENDIENTE](https://mapfre.devinenterprise.com/attachments/3768c766-e18d-484c-ba21-6c26c7ee6d5c/ss_f12cbb89.png) | PENDIENTE corresponde a la solicitud; Finalizada corresponde sólo a Alta. |

### Paths y seguimiento

- Informe: `/home/ubuntu/sca2work/r11/informe-testing-agent.md`.
- Grabación única: `/home/ubuntu/screencasts/sca-ronda7d-buscador-core/sca-ronda7d-buscador-core-edited.mp4`.
- D1: `/home/ubuntu/screenshots/ss_59810a5e.png`.
- D2: `/home/ubuntu/screenshots/ss_034f9a6b.png`.
- D3: `/home/ubuntu/screenshots/ss_e449ffb6.png`.
- D4: `/home/ubuntu/screenshots/ss_f12cbb89.png`.
- D5: `/home/ubuntu/screenshots/ss_7f07ccf2.png`.
- Comentario PR sugerido: ninguno, no hay PR indicado.
- SKILL.md adicional: ninguno.
- Blueprint organizacional consultado: no hubo instalaciones, configuración de herramientas ni servicios nuevos. Sugerencia de documentación UI no cubierta por el launcher MCP: confirmar identidad en menú usuario, usar sesiones Chrome aisladas, maximizar con wmctrl y verificar `/sca-site` si `/sca` redirige a SCA2.
- Necesario del usuario: ninguno para completar esta ronda. Las diferencias de precisión de fechas, capitalización y color de texto quedan documentadas, no bloquean los criterios explícitos de visibilidad.
