# Ronda 13 — Evolutivo «visionado al adjuntar», error de Mecanización (Verti) y retorno al formulario tras el alta (15/10/2026)

Sesión padre: https://mapfre.devinenterprise.com/sessions/6f3b571d45154ca8bddc009fb360ba0c · Pruebas: `pruebas/r13-pruebas.md` · Backups/payloads/relecturas: `sca2work/r17/`.
Entradas del usuario: funcional «ESMSA – Habilitar visionado de documentación al adjuntar» (v2, 15/10/2026), «Plan de pruebas Botón visionado. SCA2 v1.xlsx» (CP01–CP04) y «Análisis SCA2.docx» (error en Mecanización/Verti).

## 1. ¿Por qué tras el alta a veces se vuelve a la pantalla de alta en vez de ir a CA/AA?

**Qué hace SCA2.** `SCA2_AltaSolicitudPage` lanza `SCA2 CMD Alta` de forma síncrona. Ese comando sólo crea la solicitud en CORE y los records; la decisión del motor y la creación de la tarea las hacen después `SCA2 CMD Decidir` → `SCA2 CMD CrearAccion`, que `CMD Alta` arranca **de forma asíncrona** (nodo 12 «Start Decidir», `IsSynchronous = false`, sin activity chaining). Al volver el `onSuccess`, la pantalla busca la tarea PENDIENTE de la solicitud: si existe navega directamente a Contra Anulación / Acciones Administrativas; si todavía no existe se queda en el formulario, con el aviso azul «Su solicitud se ha generado correctamente. Determinando la acción a realizar, espere un momento…» y, cuando la tarea aparece (sondeo cada 0,5 s), un enlace **OK** que lleva a la acción.

**Evidencia (15788025, póliza 0000253500305, prueba de la ronda 12).** Solicitud creada en CORE a las 10:10:56; tarea CONTRAANULAR creada por `CrearAccion` a las **10:11:38** (42 s después); la pantalla se observó de vuelta en el formulario a las 10:11:19, es decir, en la ventana en la que la solicitud ya existía pero la tarea no. No hubo error (`SCA2 Error` vacío para la solicitud) y la solicitud no se duplicó.

**Causa.** Es una carrera de tiempos: la navegación directa sólo funciona si Decidir + CrearAccion terminan antes de que `CMD Alta` devuelva el control; cuando el motor/CORE tardan (en TEST entre 10 y 40 s) no hay tarea y la pantalla se queda en el formulario esperando. El aviso azul y el OK son poco visibles (la captura del tester muestra el formulario con GUARDAR habilitado, lo que indica además que la pantalla llegó a re-evaluarse perdiendo el estado local: en ese caso ni siquiera se ve el aviso).

**Casos distintos ya corregidos antes.** R10-A (pólizas Hogar NSE): `CMD Alta` fallaba antes de crear la solicitud por un dato vacío del contexto (`SCA2_construirContextoAlta` v11) y la pantalla volvía al formulario sin solicitud. No es este caso.

**Propuesta de corrección (pendiente de OK, no aplicada).** Encadenar la decisión al alta: en `SCA2 CMD Alta` arrancar `Decidir` de forma síncrona y en `Decidir` arrancar `CrearAccion` también síncrono (o activity chaining), de modo que `a!startProcess(isSynchronous: true)` de la pantalla devuelva el control con la tarea ya creada y la navegación directa funcione siempre, como en SCA. Complemento en pantalla: mientras no exista tarea, ocultar el formulario y mostrar sólo el aviso «Generando la solicitud nnn… espere» con el botón de ir a la acción, para que no parezca que «ha vuelto al alta».

## 2. Evolutivo «Habilitar visionado de documentación al adjuntar» (aplicado)
Requisito (funcional v2): en Contra Anulación y Acciones Administrativas, al adjuntar un documento se activa el botón de visionado (ojo) junto con editar/eliminar; al pulsarlo se ve el documento adjunto como se ve hoy la plantilla al imprimir (visor con botón CONTINUAR arriba); si la fila también tiene imprimir, imprimir sigue mostrando la plantilla y el ojo el adjunto.

| Objeto | UUID | Antes | Después | Cambio |
|---|---|---|---|---|
| SCA2_AccionesAdministrativasDocumentacion (componente de documentación usado por CA, AA y Autorización) | _a-0000f069-4f37-8000-9cc8-011c48011c48_20060475 | v3 | v4 | Botón ojo: si `idDocumento` de la fila es un documento Appian (adjuntado en la sesión, `typeof = 3`, mismo criterio que usa el botón editar) se abre directamente `todocument(idDocumento)`; si es un id de Documentum se recupera con `SCA2_PM_OBTENER_DOCUMENTO_GD` como antes. `disabled` sólo para filas sin documento o con documento de GD no listado. |
| SCA2_VisualizarDocumento | _a-0000f069-4f37-8000-9cc8-011c48011c48_20051272 | v1 | v2 | Botón CONTINUAR (rojo) en la parte superior del visor en lugar de CANCELAR abajo, igual que el visor de la plantilla (`SCA2_VisualizarDocumentoContraanularEstrategicas`). |

Sin cambios en los botones imprimir (plantilla de carta, tipo 9 compra/venta sin traspaso) ni en la subida al gestor documental.

## 3. Error del Análisis SCA2: Mecanización mostraba la inducción Verti junto a la confirmación (aplicado)
Lo que decía el analista: al anular con SCA2 aparecía a la vez la confirmación «¿Desea anular la póliza…?» y el bloque «Generación de contactos de cliente» (Verti / vencimiento). Debe aparecer primero sólo la confirmación; tras aceptar, ir a la pantalla de inducción si así lo dice el motor; marcar cualquiera de las casillas abre el módulo de inducción a Verti; y «ahora mismo si das a Anular póliza termina la solicitud».

Diagnóstico en SCA2: `SCA2_MecanizacionPrincipal` pintaba el bloque Verti inline y pasaba `verti: local!checkVerti` al proceso; `SCA2 CMD Mecanizar` decidía la tarea VERTI con `and(or(pv!flagVerti, contacto≠null), defaultValue(pv!verti, true))`, donde `flagVerti` (conceptos funcionales del nuuma) y `contacto` (determinarContacto llamado desde el proceso con parámetros vacíos) eran falsos/nulos aunque el motor sí había devuelto VERTI en pantalla → nunca se creaba la tarea VERTI y la mecanización terminaba la solicitud.

| Objeto | UUID | Antes | Después | Cambio |
|---|---|---|---|---|
| SCA2_MecanizacionPrincipal | _a-0000f069-4f37-8000-9cc8-011c48011c48_20060481 | v15 | v16 | Eliminado el bloque inline `SCA2_GenerarContactoVerti`; nueva local `induccionPendiente = or(mostrarVerti, mostrarVencimiento)` (resultado del motor `SCA2_determinarContacto`) que se envía como `verti` a `CMD Mecanizar` en los dos ANULAR PÓLIZA. |
| SCA2 CMD Mecanizar (nodo 6 «Inducción VERTI?») | 0000f06f-4cfc-8000-66d3-7f0000014e7a | — | — | Condición: `and(a!defaultValue(pv!verti, false), interfazActiva <> "VERTI")` → crea la tarea VERTI (pantalla de inducción) sólo cuando la pantalla de confirmación indica que el motor devolvió contactos y la solicitud no está ya en la tarea VERTI. |
| SCA2_VertiVencimientoPrincipal (pantalla «Inducción Verti / Vencimiento») | _a-0000f069-4f37-8000-9cc8-011c48011c48_20063389 | v3 | v8 | CONTINUAR: si la casilla Verti está marcada arranca el PM corporativo `CMP Inducir Cliente Completo` (el mismo que usa SCA en «Inducción Verti»: aplicación SCA, cliente, cia, entidad 00, inducirA 1, póliza, nuuma, producto, usuario) y en su onSuccess/onError `CMD Mecanizar` con `verti: false` y las observaciones (una sola llamada a servicio por evaluación; antes el botón llamaba también a insertarObservaciones). v5: parámetros del motor como en Mecanización y casillas por defecto si el motor no responde. |
| SCA2 CMD Mecanizar | 0000f06f-4cfc-8000-66d3-7f0000014e7a | v15 | v20 | PV nueva `inducirVerti`; nodos nuevos «¿Inducir Verti?» → «Inducción Verti (CMP)» (Start Process de `CMP Inducir Cliente Completo`, el mismo PM que usa SCA, con idCliente de la cabecera CORE) antes de «Guardar Mecanización»; la tarea VERTI ya no escribe la transición OK del comando; «¿Ya ejecutado?» no aplica en la pantalla VERTI; «Write Éxito» usa clave `…|VERTI` en la vuelta desde la inducción y cierra la tarea MECANIZAR pendiente. Appian sólo permite un smart service por evaluación (también encadenado en onSuccess), por eso la inducción vive en el proceso y no en el botón. |
| SCA2_DetalleTareas | _a-0000f069-4f37-8000-9cc8-011c48011c48_20055554 | v24 | v26 | Tras ANULAR PÓLIZA, ACEPTAR espera (sondeo 0,5 s, máx. 90 s) a que CMD Mecanizar cree la tarea VERTI o termine, y abre la pantalla de inducción en la misma cadena (antes volvía al buscador). |
| SCA2_SolicitudAnulacion (pestaña del Detalle) | _a-0000f069-4f37-8000-9cc8-011c48011c48_20064988 | v9 | v10 | Corrección colateral: `wherecontains` con lista vacía de compañías contrarias. |
| SCA2_PM_CMP_INDUCIR_CLIENTE (constante nueva, app SCA2) | _a-0000f084-4517-8000-9d2d-011c48011c48_5569582 | — | v1 | PM 0002ea05-adcc-8000-8c7a-7f0000014e7a «CMP Inducir Cliente Completo». |

Pendiente / a confirmar con el analista:
- **Vencimiento**: en SCA la casilla «Generar un vencimiento a un año vista» genera el vencimiento en SGC al finalizar la solicitud (`vencimientoSGC`). En SCA2 la casilla se muestra pero `CMD Finalizar` no tiene esa salida: hay que implementar la gestión de vencimiento en SGC (o confirmar que no aplica).
- El módulo de inducción se lanza al pulsar CONTINUAR con la casilla marcada (SCA lo hace también en proceso, tras la mecanización); si debe abrirse al marcar la casilla, hace falta una pantalla intermedia.
- Verti en TEST depende de que `determinarContacto` (GAIA) devuelva contactos; en la ronda 9 devolvía error 1101 para JJGONZ2. La captura del analista (póliza 0000023400744) demuestra que ahora sí devuelve VERTI al menos para esa póliza/usuario.

## 4. Pruebas
Ver `pruebas/r13-pruebas.md` (plan CP01–CP04 del analista + mecanización 15788025).
