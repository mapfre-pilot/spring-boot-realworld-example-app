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
