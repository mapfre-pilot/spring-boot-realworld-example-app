# Ronda 9 — Consolidado (respuestas del analista, pólizas nuevas, SISANS) y dudas abiertas

Fecha: 2026-10-13. Entorno: Appian TEST (`mapfrespain-test`). Usuarios: JJGONZ2 (Oficina, CE_RM) y SISANS (SI24 Experto). Referencia funcional: **SCA TEST**; sólo se corrige SCA2 cuando la diferencia es propia de SCA2. Lo que depende de CORE, ANL, Emisión, Documentum, PRE o de una decisión funcional se documenta y se pregunta, no se inventa.

Entradas de la ronda: respuestas del analista (`24-respuestas-analista-ronda9.md`), plan y reparto (`25-plan-ronda9.md`, `pruebas/polizas-ronda9.md`), coordinación entre sesiones (`pruebas/coordinacion-ronda9.md`). Informes de detalle: `pruebas/r9a-*.md` … `pruebas/r9e-*.md`.

## 1. Resultado en una página

| Bloque | Qué se pedía | Resultado en SCA2 | Informe |
|---|---|---|---|
| Alta y simulación (A1–A7) | Simulación obligatoria y PRRA como SCA, popup de simulación, datos al motor (canal, SI24, código de intermediario), aviso de misma anualidad | **Corregido y probado** con pólizas wAutemis y RCI del Excel (JJGONZ2). El 403 de la simulación era de permisos y está resuelto | R9-A |
| Verti | «Cualquier póliza debería activar Verti (reglas trampeadas en PRE)» | **No aparece ni en SCA ni en SCA2 en TEST**: el servicio de inducción de contacto (GAIA → Oficina de Frontales) falla en TEST (ver §3). Se han corregido además dos diferencias propias de SCA2 en la llamada a ese servicio | R9-A + §3 |
| M201 / M206 | Probar los errores de simulación | No se reproducen con las pólizas de TEST (ninguna tiene operación pendiente). Explicado en §4 | R9-A |
| Tareas y permisos (B1–B7) | Oficina al retomar, manda el motor, administradores, tarea única, finalizadas, Red Mapfre no recupera tareas de SI24 | **Corregido y probado**: SI24 gestiona sus tareas y Red Mapfre sólo consulta con aviso; SI24 sólo consulta nivel 1; Completar oculto en finalizadas; **Oficina conservada al POSPONER y preseleccionada al RETOMAR** (terminado en esta consolidación, §2) | R9-B + §2 |
| Acciones Administrativas y SI24 (B7) | Causas ocultas a SI24, pregunta «¿insiste?» sólo CCC/CCR, pólizas de acuerdo | **Corregido y probado** (SISANS no ve las causas 13/14/16/17/18/28/31/32; la pregunta sólo sale a CCC/CCR). El bloqueo por «póliza de acuerdos» se dejó como **aviso** porque la lista de SCA incluía RCI y rompía la Contra Anulación de Oficina (15787911) | R9-C |
| Mecanización, Autorización, ANL (C1–C4, D2, G1/G2, Decisión 4) | Aviso NSE, botones de Autorización, CANCELAR autorización, ANL, Documentum | **Corregido y probado**: avisos NSE 00000005/00000006, botones y CANCELAR graban en CORE y muestran el resultado real. **Documentado**: espera a ANL (SCA indefinida, SCA2 24 h), documento huérfano duplicado en Documentum, batch NSE sin equivalente | R9-D |
| Buscador, Detalle, DUE (E1, E2, F1–F3) | Detalle de sólo lectura para solicitudes de SCA/históricas, fecha de resolución, correo DUE con datos de contacto | **Corregido y probado**: Detalle de consulta con datos CORE, fecha de resolución vacía mientras está pendiente, DUE con tomador/DNI/email/teléfono. Envío real del DUE no completado (bloqueo B7 y latencia de SCA) | R9-E |

Objetos SCA2 modificados en la ronda (todos con backup, PUT completo y relectura; detalle y versiones en cada informe y en `pruebas/coordinacion-ronda9.md`): `SCA2_AltaSolicitudPage` 27→29, `SCA2_puedeGestionarTarea` 4→6, `SCA2_DetalleSolicitud` 51→52, `SCA2_DetalleTareas` 23→24, `SCA2 CMD Posponer`, `SCA2_consultarCausa` 1→2, `SCA2_ContraAnulacionModalSiNo` 1→2, `SCA2_ContraAnulacionOpciones` 41→44, `SCA2_AccionesAdministrativasPrincipal` 21→22, `SCA2_AnulacionFueraNormaPrincipal` 22→23, `SCA2_MecanizacionPrincipal` 14→15, `SCA2 CMD CompletarAccion`, `SCA2_notificarNivel` 3→5, `SCA2_TablaOtrasSolAnulacion` 2→6, `SCA2_Buscador` 27→29, `SCA2_VertiVencimientoPrincipal` 2→3, `SCA2 CMD Mecanizar` (nodo «Cargar»).

## 2. Cerrado en la consolidación: Oficina al RETOMAR (B1)

- Al **POSPONER** (Contra Anulación, Acción Administrativa, Autorización) `SCA2 CMD Posponer` guarda la oficina elegida en `SCA2 Tarea.tokenTarea` con el formato `OFICINA:<OFICINA_DIRECTA>|<DESC_OFICINA>` (hecho por R9-B).
- Al **RETOMAR**, `SCA2_ContraAnulacionOpciones` (v44) y `SCA2_AccionesAdministrativasPrincipal` (v22) leen ese valor de la tarea (`ri!idTarea`) y preseleccionan en el selector la oficina de la lista del gestor cuya `OFICINA_DIRECTA` coincide. Si no hay valor guardado o la oficina ya no está en la lista, se comporta como antes (una sola oficina → preseleccionada; varias → «Seleccione una oficina»).
- Prueba (render de las interfaces por LCP con las tareas pospuestas por R9-B): solicitud 15787908 / tarea 157 → selector con «MADRID CORREDORES NORTE II» seleccionada; solicitud 15787913 / tarea 162 → «VILLALBA». Antes del cambio ambas mostraban «--Seleccione una oficina--» (informe R9-B).
- Autorización fuera de norma (`SCA2_AnulacionFueraNormaPrincipal`) no tiene selector de oficina propio al retomar: no requiere cambio.
- SCA **pierde** la oficina al retomar; aquí SCA2 mejora a SCA por decisión del analista («la oficina debe conservarse, sí»). Pregunta pendiente: ¿la oficina se conserva por tarea (mientras está pospuesta) o por solicitud (se arrastra a tareas posteriores)? Hoy: por tarea.

## 3. Verti: qué se ha comprobado y por qué no sale en TEST

El analista indica que en PRE cualquier póliza debería activar Verti. En TEST, con JJGONZ2 y las pólizas del Excel, **ni SCA ni SCA2 crean la tarea Verti**. Se ha seguido la cadena completa:

1. **Regla `flagVerti`** (`SCA_flagVerti` y `SCA2_flagVerti`): misma lógica (estructura comercial del gestor, conceptos funcionales de suscripción inteligente, grupo «SCA Acceso Decisora»). Con JJGONZ2 y compañías 1 y 41 ambas devuelven **false** (los conceptos funcionales OD/OC/DGT/DT vienen a «0»). Es paridad: la diferencia no está aquí.
2. **Servicio de inducción de contacto** (`determinarContacto` → `SCAC_determinarContactoREST`, componente GAIA). Con los datos completos de una solicitud real (15787912) devuelve **HTTP 500** `1101 — Error al consultar inducción clientes en Cliente REST Servicio de la oficina de frontales: error al obtener el token personalizado`. Es un fallo del servicio externo en TEST que afecta igual a SCA y a SCA2: **sin ese servicio no hay contacto Verti/Vencimiento en ninguna de las dos**.
3. **Dos diferencias propias de SCA2 corregidas** en cómo se llama a ese servicio (no cambian el resultado mientras el servicio falle, pero son necesarias para que Verti funcione cuando se arregle):
   - `SCA2 CMD Mecanizar`, nodo «Cargar»: enviaba a `determinarContacto` canal/línea desde el estado local y **vacíos o cero** en clave de producción, catalogación, motivo, causa, fecha de anulación y detalle (y `anulaTecnico/anulaExperto` a false). El servicio respondía **400 «canalEntrada no puede ser nulo»** y el contacto quedaba vacío. Ahora envía los mismos datos que `SCA Mecanizacion` (nodo determinarContacto).
   - `SCA2_VertiVencimientoPrincipal`: enviaba la fecha de anulación como `dd/MM/yyyy`; el servicio la rechaza con **400 «Can not construct instance of java.util.Date»**. Ahora la envía en `yyyy-MM-dd` como SCA.
4. **Preguntas para el analista / sistemas**: (a) ¿la «trampa» de reglas Verti está en PRE pero no en TEST? En TEST los conceptos funcionales de JJGONZ2 son «0» y el servicio de inducción falla; (b) ¿puede sistemas revisar el token de la Oficina de Frontales en TEST (error 1101)? Hasta entonces Verti no es probable en TEST con ningún usuario.

## 4. M201 / M206 (respuesta a la duda del usuario)

No son tipos de póliza: son **códigos de error del servicio de simulación de anulación** (wAutemis/New).
- **M201**: «la póliza tiene una operación pendiente» — error controlado que **no deja continuar** el alta.
- **M206**: «error al consultar el estado de la situación de la póliza» — **deja continuar**.
Sólo aparecen con la simulación activa (ya restaurada en SCA2). Para forzarlos hace falta una póliza con una **operación pendiente en Emisión** (M201) o un fallo de la consulta de situación (M206); ninguna de las pólizas del Excel está en esa situación en TEST. Petición al analista: una póliza de TEST con operación pendiente.

## 5. Origen FDC (respuesta a la duda del usuario)

`origen` **no es «tener oficina»**: es el parámetro con el que otra aplicación abre SCA por URL (valores vistos: SGC, STCAT, ALT…, FDC). Con `origen = FDC`, SCA muestra la sección «Tipo catalogación» en Acción Administrativa y Contra Anulación y cambia alguna validación (modo G). Por el nombre parece la **Ficha de Cliente** (inferencia, no confirmado). SCA2 siempre graba origen «SCA2» y no tiene entrada externa. Preguntas: ¿qué aplicación abre SCA con origen FDC? ¿debe SCA2 soportar esa entrada y mostrar la catalogación? ¿qué URL/póliza permite reproducirlo en TEST? Los casos de Más Móvil con AA exigen ese origen (por eso no se han podido probar).

## 6. Dudas abiertas para el analista (lenguaje de negocio)

**Tareas, niveles y SI24**
1. Texto definitivo del aviso «Esta solicitud la está gestionando SI24» (hoy provisional).
2. ¿«SI24 sólo consulta» aplica a toda tarea de nivel 1 (CA, AA, Autorización) como se ha aplicado, o sólo a la AA pospuesta?
3. Tarea de SI24 que ya figura asignada a un gestor de Red Mapfre (15787861, 15787867): ¿debe SI24 poder retomarla aunque esté asignada a otro? Hoy ni SCA ni SCA2 lo permiten.
4. `SCA2 CMD CambiarNivel` (cambio de nivel manual) asigna un grupo literal «SCA2 Nivel N», no un grupo del motor. ¿Debe usar el motor como el resto?
5. Oficina al retomar: ¿se conserva por tarea o por solicitud? (§2)

**Acciones Administrativas y acuerdos**
6. Criterio exacto de «póliza que debe tratar SI24»: la única lista disponible (clases de agente/acuerdos de SCA) incluye RCI y bloquea a la Oficina; por eso en SCA2 es un aviso, y el salto lo decide el motor. ¿Qué lista/criterio manda?
7. Texto definitivo del aviso de póliza de acuerdo (hoy provisional).
8. ¿La pregunta «¿insiste el cliente?» aplica a CCC y CCR o sólo a CCC? ¿Debe verla SI24 con origen telemático/telefónico (en SCA sí la ve)?
9. En el alta, `anula técnico / anula experto` se guardan con los valores del productor (false en TEST); ¿es el comportamiento esperado para el motor?

**Mecanización, Autorización, ANL, Documentum**
10. Espera a ANL: SCA espera indefinidamente sin aviso; SCA2 corta a 24 h (`ANL_TIMEOUT`). ¿Plazo, aviso y quién cierra?
11. Documento huérfano en Documentum: al relanzar, SCA2 lo duplica (CORE queda con uno). ¿Se acepta o SCA2 debe guardar la referencia para reutilizarla?
12. Batch nocturno NSE de SCA: ¿necesita SCA2 el suyo o se mantiene el de SCA mientras convivan?
13. Texto definitivo del error al cancelar una autorización (hoy «No se ha podido cancelar la autorización en CORE…»). Nota: SCA muestra «CORRECTO» aunque CORE falle; SCA2 ahora muestra el error real.
14. Solicitudes de prueba sin terminar (15787909, 15787759, 15787911, 15787917…): el analista dice «se finalizan para liberar»; implica finalizarlas en CORE TEST. **No se hace sin confirmación expresa.**

**Buscador, Detalle, DUE**
15. ¿Los filtros de Estado y Línea de negocio deben aplicarse también a la lista de solicitudes de SCA/históricas?
16. El alta de SCA2 no recoge «teléfono de contacto» (`tlfexperto`); el DUE usa el del tomador. ¿Debe el alta pedirlo como SCA?
17. Confirmar recepción real del DUE requiere acceso al buzón de TEST; ¿quién lo comprueba?
18. Con el aviso/bloqueo de acuerdos, ¿cómo debe llegar una RCI a nivel 2/SI24 para que se envíe el DUE: la crea SI24 o la crea la Oficina y salta?
19. SI24: ¿debe recibir las preguntas de contacto al posponer/finalizar?, ¿debe tener la impresión activa (hoy activa en SCA y SCA2, el plan la esperaba inactiva)?, ¿qué significa exactamente el cierre «Ilocalizable a la tercera gestión»?
20. Observaciones «-» en filas sólo-CORE del grid «Otras solicitudes»: el servicio `consultarSolicitudes` de CORE no las devuelve. ¿Se acepta?

**Alta, Verti, errores**
21. Verti en TEST (§3): ¿la trampa de reglas está sólo en PRE? ¿puede sistemas revisar el token de la Oficina de Frontales (error 1101)?
22. Pólizas para M201/M206 (§4) y para origen FDC (§5).
23. Vida y Más Móvil: las pólizas del Excel no permiten alta ni en SCA TEST (Emisión las rechaza). ¿Hay pólizas Vida/Más Móvil válidas en TEST?

## 7. Limitaciones de esta ronda

- SCA TEST con latencia alta y errores 403 intermitentes: varias comparaciones de UI en SCA no fueron concluyentes (se indica en cada informe).
- Servicio de inducción de contacto (GAIA/Oficina de Frontales) caído en TEST (error 1101): Verti/Vencimiento no probable.
- No se ha finalizado ni borrado ninguna solicitud en CORE.
- Las grabaciones y capturas de las sesiones hijas no se suben al repositorio; constan en cada sesión.
