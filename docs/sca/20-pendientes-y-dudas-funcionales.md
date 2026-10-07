# SCA2 — pendientes y dudas funcionales (estado al cierre de la ronda 6, incluida la prueba UI)

Objetivo: que el analista pueda darnos la información **de forma funcional** y seguir desarrollando SCA2 sin adivinar reglas de negocio. Lo que no está aquí se considera en paridad con SCA TEST y probado (ver `pruebas/`).

## 1. Pendiente técnico (sabemos qué hacer, falta ejecutarlo o probarlo)

| # | Pendiente | Por qué sigue abierto | Qué necesitamos |
|---|---|---|---|
| T1 | **Cierre tras ANL** (mecanización NSE/wAutemis → `ANULACION REALIZADA` → FINALIZAR) | En TEST ANL nunca ha marcado `DESBLOQUEO_ANULACION`; las filas ANL de 15787761/64/65/72 siguen bloqueadas. En NSE la solicitud termina igual (Decidir tras mecanizar), como SCA | Confirmar con el equipo ANL qué proceso desbloquea en TEST o un desbloqueo manual para probar la rama wAutemis «pendiente de aceptar» (nodos 302–315 de Mecanizar) |
| T2 | **Finalizar con gestión SGC real** (`SCA2_CMD_Finalizar` nodos 13/11/12) | Validado sólo con `soloPayload`; el relanzamiento de 15787843 entró por la rama anterior | Una solicitud CE_RM nueva que llegue a FIN con `idGestionSGC` ≠ 0 (ocurre cuando se pospone o se cambia de nivel) |
| T3 | **Cambio de nivel real con CE_RM** (gestión SGC de nivel 2 + notificación externa `SGC`) | Probado con `soloPayload`; falta ejecución real tras la corrección de ronda 5 | Mismo caso que T2 |
| T4 | **Autorización wAutemis** (mecanización con `observaciones` 00000005/00000006 → gestión 7 → ACEPTAR/RECHAZAR) | Desde la ronda 6 la gestión 7 sólo se crea en ese caso; no hay póliza wAutemis en TEST que devuelva esos códigos | Una póliza wAutemis que Emisión deje «pendiente de aceptar» |
| T5 | **REASIGNAR con un segundo usuario real** | Sólo probado con el mismo usuario (popup, grupo, record) | Un segundo usuario funcional en los grupos SCA2 |
| T6 | **Caducidad real** (`SCA2 CMD Caducar` / `BarridoCaducidad`, 24 h ANL, caducidad de nivel) | No ha pasado el plazo en ninguna solicitud de la versión actual; 15787759 (versión antigua) no registró `ANL_TIMEOUT` y su instancia 526741 debe revisarla un administrador | Un administrador en Monitoring (526741 y 9994107) y una solicitud que se deje caducar |
| T7 | **Validaciones de fecha del Alta** (fecha < efecto, > vencimiento, > 18 meses, anterior a siniestro, impagos) | La regla está copiada de SCA pero el formulario no la invoca; pendiente de confirmación del analista (resumen del Alta enviado) | Confirmación de que se aplican las mismas reglas que SCA |
| T8 | **Alta: PRRA, Vida, servicio de pólizas caído, solicitud ya abierta → abrir Detalle, simulación previa/Expertos** | Diferencias con SCA detectadas en el resumen del Alta; no implementadas por no estar confirmadas | Confirmación punto a punto (ver §2.6) |
| T9 | **Compañía 1 (NEW)**: traducción motivo/detalle/causa | Sin solicitud SCA2 de compañía 1 en TEST | Una póliza de compañía 1 |
| T10 | **Correo DUE (SI24)** | `dueEnviado = S` y notificación `SI24` en CORE; no comprobada la recepción; texto `SCA2_TXT_DUE_MENSAJE` genérico | Texto definitivo y confirmación de recepción en `JOSPENA@mapfre.com` |
| T11 | **Rendimiento / volumen** del buscador y del Detalle (consultas CORE por tarjeta) | No medido con datos reales | Volumen esperado de solicitudes/usuario y tiempos aceptables |
| T12 | **Registro histórico 15787843** | `error`/`nodoRelanzar` con el fault antiguo (la limpieza en el Write FINALIZADA se añadió después). No visible en pantalla | Nada; se deja como está salvo que se pida limpiarlo |

## 2. Dudas funcionales (necesitamos decisión del analista/negocio)

### 2.1 Mecanización y autorización
1. ¿Qué códigos exactos devuelve Emisión para «anulación directa» y cuáles para «pendiente de autorizar»? Hoy SCA y SCA2 usan `observaciones ∈ {00000005, 00000006}` + origen `wAutemis`. ¿Hay más códigos o aplica también a NSE-Autos/NSE-Hogar?
2. Cuando la gestión 5 queda `ANULACION PENDIENTE DE AUTORIZAR`, ¿quién debe ver la tarjeta Autorización y qué botones (ACEPTAR/RECHAZAR/RETOMAR) debe tener si no hay tarea SCA2 propia?
3. Si NSE/ANL nunca responde (gestión 5 `INCOMPLETA` indefinidamente), ¿la solicitud debe caducar, avisar o cerrarse manualmente? ¿Tras cuánto tiempo?
4. Si CORE marca la gestión 5 como `ANULACION REALIZADA` pero ANL no desbloquea (caso wAutemis), ¿prevalece CORE?

### 2.2 Impresión / documentos
5. ¿La impresión (gestión 4 + carta) es única **por solicitud** o **por nivel/gestión de contra anulación**? Hemos implementado «por solicitud» (si existe gestión 4 y documento, no se repite).
6. ¿Dónde se considera «guardado» el documento: Documentum (GD), el record SCA2, CORE (`consultarDocumentos`) o los tres? Hoy comprobamos CORE.
7. Si existe la gestión 4 pero no el documento (o al revés), ¿reintentar sólo la parte que falta o generar las dos de nuevo?
8. ¿Cómo reconciliar escrituras parciales en CORE (p. ej. gestión creada y fallo posterior) cuando se relanza desde `/errores`?

### 2.3 Tareas, RETOMAR, REASIGNAR
9. Estados exactos que permiten RETOMAR y REASIGNAR: hoy `INCOMPLETA`, `PENDIENTE`, `ANULACION PENDIENTE DE AUTORIZAR` con tarea SCA2 no finalizada (paridad con SCA). ¿Correcto?
10. ¿Puede un administrador retomar una tarea asignada a otro usuario sin reasignarla?
11. Si hay dos tareas pendientes a la vez (p. ej. CA nivel 2 y autorización), ¿qué tarjeta se abre y cuál tiene prioridad?
12. ¿Qué debe mostrar el Detalle cuando una gestión CORE está finalizada y la tarea SCA2 sigue pendiente (o al contrario)? Hoy manda CORE para el estado y la tarea SCA2 para los botones.
12b. Tras una anulación directa NSE (sin autorización), `Decidir` abre una Contra Anulación de nivel 2 y el buscador pasa de «Mecanización Enviada» a «Pendiente» (caso 15787844). ¿Es el comportamiento esperado mientras NSE/ANL no responde, o la solicitud debe quedar sólo en «Mecanización Enviada» hasta el cierre?
12c. Al RETOMAR una Contra Anulación pospuesta, la **Oficina** (usuario con varias oficinas NUUMA) vuelve a quedar sin seleccionar, igual que en SCA. ¿Debe conservarse la oficina elegida antes de posponer?

### 2.4 Buscador / Detalle
13. ¿Debe SCA2 mostrar también las solicitudes históricas y las creadas en SCA (hoy sólo las suyas)?
14. ¿Debe abrir el Detalle directamente cuando hay un único resultado, como SCA, o mantener la lista?
15. ¿`JJGONZ2` (perfil funcional) debe acceder a `/errores`? Hoy sólo administradores.

### 2.5 Niveles, SGC, SI24/DUE
16. Texto definitivo del correo DUE (`SCA2_TXT_DUE_MENSAJE`) y buzón por entorno.
17. ¿Cómo se confirma funcionalmente la recepción del DUE (sólo `dueEnviado`, acuse, notificación externa)?
18. Al posponer una Autorización pendiente, SCA **no** crea gestión SGC (y SCA2 tampoco). ¿Se mantiene?
19. ¿Quién debe quedar como `grupoAsignacion` tras un cambio de nivel decidido por el motor (hoy el `codPerfil` de la decisión)?

### 2.6 Alta
20. ¿Se aplican en SCA2 las mismas validaciones de fecha que SCA al GUARDAR (T7)? ¿Alguna se ha quedado obsoleta?
21. ¿Es obligatoria la simulación previa al alta y el paso a Expertos en retención?
22. Pólizas PRRA: ¿códigos fijos de motivo/detalle/causa como SCA?
23. Pólizas de Vida: ¿se dan de alta desde SCA2 o se redirige a su aplicación (hoy redirección)?
24. Servicio de pólizas caído: ¿bloquear GUARDAR con el aviso «Servicio caído» como SCA?
25. ~~Si la póliza ya tiene una solicitud abierta, ¿abrir su Detalle (SCA) en lugar de permitir un alta nueva?~~ Hecho en la ronda 6: el popup bloquea el alta si CORE tiene una solicitud abierta y, si es de SCA2, ofrece VER SOLICITUD. Queda confirmar los `codEstSolic` que cuentan como «abierta» (hoy 1, 2, 7, 8, 9, 10, 16, 17, copiados de SCA).
26. ¿Se deben enviar IP y datos de cliente (PECA/Robinson) al proceso como hace SCA? ¿Sigue vigente `flagActivoPMO`?

### 2.7 Errores, reintentos y relanzamiento
27. ¿Qué integraciones deben reintentar automáticamente, cuántas veces y con qué espera antes de registrar el error (hoy 3 reintentos en GD y en CORE guardar/actualizar; 288 consultas × 5 min a ANL)?
28. ¿Qué debe pasar tras agotar las 288 consultas a ANL (24 h): error relanzable, caducidad o aviso?
29. ¿Quién puede relanzar/descartar errores y debe quedar traza de quién lo hizo?

### 2.8 Datos
30. ¿Se pueden eliminar las solicitudes SCA2 de pruebas que sí existen en CORE (75) o deben conservarse? Sólo se han borrado las 15 autorizadas.

## 3. Hallazgos en SCA (no tocados)
- La flecha «volver» del Detalle de SCA da «Ha ocurrido un error».
- `SCA_D_ColorEstadoGestion("MECANIZACION", "ANULACIÓN REALIZADA")` (con tilde) devuelve `ACCENT`; sin tilde devuelve verde. CORE devuelve sin tilde; SCA2 mapea el valor sin tilde.
- Servicios externos con caídas puntuales durante las pruebas: `IContraAnularPCA`, `IGenerarContraAnul` (`Failed to connect`), `srGestionarAnulacionesPolizasWs` (HTTP 500), CORE `0999 Error no catalogable` transitorio en `finalizarSolicitud`.
