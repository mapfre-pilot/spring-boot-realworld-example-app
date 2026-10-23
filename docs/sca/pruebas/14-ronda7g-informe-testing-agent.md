# Ronda 7g — Detalle CORE de sólo consulta

## Alcance y resultado

Verificación E2E por navegador en Appian TEST, como **JJGONZ2**, el 13/10/2026. Se ejecutó navegación de consulta en SCA2 y comparación con SCA histórico. Cambios comunicados: Buscador v23, DetalleSolicitud v49 y corrección SolicitudAnulacion v9 durante la prueba.

Se completó el procedimiento: las tres solicitudes CORE abren desde la tabla secundaria, muestran el aviso de sólo consulta, sus gestiones y datos de Solicitud Anulación; no muestran RETOMAR, REASIGNAR ni Trazabilidad técnica. La comparación de 15787531 confirma paridad de los datos principales. La solicitud nativa 15787867 carga sin aviso CORE y sin error.

**Observaciones que no deben ocultarse:**

- La primera apertura de Solicitud Anulación de 15787531 falló con `Cannot compare incompatible operands of type Null and type Number (Integer)` en `sca2_solicitudanulacion`, `a!richTextItem`, línea 295. Tras la corrección viva v9 se reabrió: la pestaña carga y muestra **Reserva prima NO SOLICITADA / -**, sin error. Las imágenes y el vídeo de este informe corresponden a la verificación posterior.
- **15787867 no presenta RETOMAR a JJGONZ2** al expandir y recorrer CA2. El mínimo explícito de esta regresión —carga sin error y sin aviso azul— sí se cumple. No se afirma que RETOMAR funcione para este usuario.
- `/suite/sites/sca` redirige a SCA2; se comparó con SCA real mediante `/suite/sites/sca-site`.
- El buscador secundario expone códigos como `FINALIZADA_NEG_CONTRA` y `FINALIZADA_NO_REQ`; SCA muestra estados descriptivos. Hay otras diferencias de presentación detalladas abajo.

**Restricciones respetadas:** ninguna alta, GUARDAR, FINALIZAR, ANULAR, POSPONER, RETOMAR ni REASIGNAR. No se modificó la gestión de ninguna solicitud.

## Resultado por paso

| Paso | SCA | SCA2 | Resultado / igual-diferente |
|---|---|---|---|
| 1. Póliza 0000148600179 → 15787531 | Comparación en paso 3 | Principal vacía, cinco filas secundarias y enlace 15787531; Detalle con aviso azul y cabecera ZOJE TASALER DEJMOFAN | **PASA** |
| 1. Gestiones 15787531 | Alta Finalizada, CA Finalizada Negativa, Impresion Finalizada | Mismas tres gestiones y estados | **PASA — igual** |
| 1. Sólo consulta | Sin acciones de gestión visibles en esta solicitud finalizada | Sin RETOMAR/REASIGNAR/Trazabilidad técnica; regreso por flecha al buscador | **PASA** |
| 1. Solicitud Anulación / v9 | Datos poblados, Reserva prima NO SOLICITADA / - | Datos poblados después de la corrección v9; sin excepción de null | **PASA tras corrección** |
| 2. 0000253500322 → 15787040 | No solicitado comparar este caso en SCA | Alta Finalizada, CA Incompleta nivel 1, Acciones Administrativas Finalizada; aviso, pestaña poblada y sin acciones/traza | **PASA** |
| 2. 0000253500322 → 15787832 | No solicitado comparar este caso en SCA | Alta Finalizada; CA nivel 1 Incompleta; Impresion Finalizada; CA nivel 2 Incompleta; aviso, pestaña poblada y sin acciones/traza | **PASA** |
| 3. Paridad 15787531 | Detalle histórico, misma cabecera, gestiones, estados y datos de Solicitud Anulación | Datos coincidentes, presentación más compacta y aviso CORE | **PASA en datos principales; diferencias visuales** |
| 4. Regresión 15787867 | No aplica | Buscador principal Pendiente; Detalle nativo sin aviso CORE ni error; CA2 Incompleta | **PASA criterio mínimo indicado** |
| 4. RETOMAR / admin | No aplica | RETOMAR no visible a JJGONZ2; no se probó con administrador | **Observación / admin NO PROBADO** |

## Datos visibles de Solicitud Anulación

| Campo | 15787531 — SCA y SCA2 | 15787040 — SCA2 | 15787832 — SCA2 |
|---|---|---|---|
| Fecha solicitud | 25/09/2026 | 20/07/2026 | 07/10/2026 |
| Origen | SOLICITUD EXPRESA | IMPAGO | SOLICITUD EXPRESA |
| Causa | COMPROMISOS | COMPROMISOS | COMPROMISOS |
| Canal entrada | PRESENCIAL | SI24 | PRESENCIAL |
| Estado | FINALIZADO NEGATIVO CON CONTRAANULACIÓN | FINALIZADA NO REQUERIDA CONTRAANULACIÓN | FINALIZADA NO REQUERIDA CONTRAANULACIÓN |
| Fecha estado | 25/09/2026 | 21/07/2026 | 07/10/2026 |
| Fecha anulación | 09/04/2027 | 18/03/2026 | 07/07/2030 |
| Nivel | NIVEL 1 | NIVEL 1 | NIVEL 2 |
| Catalogación | A VENCIMIENTO | A VENCIMIENTO | A VENCIMIENTO |
| Fecha impresión | 25/09/2026 | - | 07/10/2026 |
| Fecha efecto recibo impago | - | - | - |
| Reserva prima | NO SOLICITADA / - | NO SOLICITADA / - | NO SOLICITADA / - |
| Compañía contraria | - | - | - |

Las CA Incompletas de 15787040 y 15787832 nivel 1 muestran también fecha fin de gestión. Se documenta lo mostrado, sin concluir que su estado global o fecha histórica sea correcto: no se gestionaron estas solicitudes ni se auditó el origen de esos datos.

## Comparación visual de 15787531

| Aspecto | SCA | SCA2 |
|---|---|---|
| Buscador: estado | Finalizado negativo con contraanulación | FINALIZADA_NEG_CONTRA, tag gris |
| Buscador: causa / resolución | Ambos `-` | COMPROMISOS / 25/09/2026 11:45:42 |
| Buscador: fecha solicitud | 25/09/2026 11:44:51 | 25/09/2026 11:44:51 — igual |
| Alta: inicio y fin | 25/09/2026 11:44:51 | Igual |
| CA: inicio / fin | 25/09/2026 11:45:00 / 11:45:41 | Igual |
| Alta y CA: nivel / grupo / usuario | 1 / OFICINA / JJGONZ2 | Igual |
| Argumentos de CA | 10; COMPROMISOS Negativo y restantes Pendiente | Mismos elementos y estados visibles, distinto orden; p. ej. TARJETA BANKINTER aparece más abajo |
| Documento de CA | Carta firmada, 0900ab4481a00d3f, 25/09/2026 | Igual; sólo se comprobó la fila, no se abrió el fichero |
| Fecha solicitud en pestaña | Enlace | Texto subrayado, sin enlace DOM |
| Distribución | Cabecera y gestiones con más espacio; pie de enlaces | Distribución compacta, aviso azul superior, pestaña adicional Notificaciones |

### Buscador — diferencias de representación

| SCA — referencia histórica | SCA2 — tabla CORE enlazada |
|---|---|
| ![SCA: buscador 15787531](https://mapfre.devinenterprise.com/attachments/490ef58c-153c-48d3-b201-0b51a7c4e0d8/ss_996bf283.png) | ![SCA2: tabla secundaria 15787531](https://mapfre.devinenterprise.com/attachments/c90117d6-6772-43b3-90c0-1f8fe98b4d66/ss_80194838.png) |

### Solicitud Anulación — mismos datos y gestiones; v9 verificada

| SCA — solicitud y estados | SCA2 — aviso CORE y Reserva prima sin error |
|---|---|
| ![SCA: Solicitud Anulación 15787531](https://mapfre.devinenterprise.com/attachments/b2e171e1-9c8f-4737-bcf1-48645f276752/ss_7fd146aa.png) | ![SCA2: Solicitud Anulación 15787531 tras v9](https://mapfre.devinenterprise.com/attachments/ed626487-ed98-4dbc-95b4-3a7dab40b6d0/ss_b1536722.png) |

### Documentos de CA — misma fila, sin gestionar

| SCA — Carta firmada | SCA2 — Carta firmada |
|---|---|
| ![SCA: documento histórico](https://mapfre.devinenterprise.com/attachments/5b23c44a-1462-4b56-8f59-cf0974a4d5fd/ss_415a39e0.png) | ![SCA2: documento CORE](https://mapfre.devinenterprise.com/attachments/cfa895fb-8f71-4046-a0f3-c394bcc20239/ss_64d3c283.png) |

### Solicitudes con CA Incompleta — sólo consulta

| 15787040 — datos y gestiones | 15787832 — dos CA Incompletas |
|---|---|
| ![SCA2: 15787040](https://mapfre.devinenterprise.com/attachments/45cb458b-39a1-49e7-99f6-30e8599e6ad8/ss_0a9419c5.png) | ![SCA2: 15787832](https://mapfre.devinenterprise.com/attachments/77109c15-0231-4ceb-ac4b-c1c8851ab7e9/ss_395cc8fd.png) |

| 15787832 — CA nivel 1 | 15787832 — CA nivel 2 |
|---|---|
| ![SCA2: CA1 Incompleta](https://mapfre.devinenterprise.com/attachments/4508be87-976e-44f3-b437-31ddf75565d5/ss_4f92cdc8.png) | ![SCA2: CA2 Incompleta sin acciones](https://mapfre.devinenterprise.com/attachments/bd1a0a24-ce5e-4dcd-bbe1-9b797a0889a8/ss_a6ad576e.png) |

### Regresión — solicitud nativa 15787867

| Buscador — 15787867 en principal | Detalle — sin aviso CORE |
|---|---|
| ![SCA2: buscador nativo](https://mapfre.devinenterprise.com/attachments/63007916-a6ce-455b-a97a-d647eabada7e/ss_31725205.png) | ![SCA2: Detalle nativo](https://mapfre.devinenterprise.com/attachments/1f283221-8403-4a14-b3f2-a482cd79aac5/ss_30fff3a3.png) |

| CA2 — Incompleta nivel 2 | Final de CA2 — sin RETOMAR para JJGONZ2 |
|---|---|
| ![SCA2: CA2 nativa expandida](https://mapfre.devinenterprise.com/attachments/bf2089e7-1106-4dd0-ba1e-3ccc47140158/ss_793c5cc3.png) | ![SCA2: final de tarjeta CA2](https://mapfre.devinenterprise.com/attachments/eb581527-2d6c-4711-96f1-24fd62d27f1c/ss_a457e713.png) |

En esta regresión continúa la observación de rondas anteriores: CA2 **Incompleta**, pero fecha fin **13/10/2026 08:50:39**, grupo **OFICINA**, usuario **PCARAGE**. No se intervino en esa tarea. La tabla secundaria contiene además 15787873, distinta de 15787867, sin duplicar ésta en CORE.

## Límites y seguimiento

- Sólo un usuario, JJGONZ2. Ausencia de trazabilidad comprobada visualmente, pero no se ha ejercitado el caso CORE con administrador ni se ha hecho una prueba de seguridad de backend.
- No se abrieron los documentos ni los detalles de suplemento. No se comprobaron Notificaciones, contacto, otras pestañas, paginación, búsquedas por cliente ni otras solicitudes fuera del alcance.
- No se cuantificó latencia. Hubo esperas de carga del buscador que finalizaron; no hubo nuevos errores en la ejecución posterior a v9.
- Al regresar por flecha se reintrodujo el filtro de póliza; la navegación de regreso funcionó.
- Sin cambios de código, instalaciones ni servicios nuevos por parte del testing agent.
- Pendiente funcional: confirmar si se desea normalizar los estados del buscador CORE y si RETOMAR debe estar disponible a JJGONZ2 en 15787867. Esto no bloquea la comprobación mínima de regresión expresamente permitida.

## Artefactos y preparación

- Informe: `/home/ubuntu/sca2work/r13/informe_ui_ronda7g.md`
- Grabación actual: `/home/ubuntu/screencasts/sca-ronda7g-core-consulta-v9/sca-ronda7g-core-consulta-v9-edited.mp4`
- Capturas: `/home/ubuntu/screenshots/ss_996bf283.png`, `ss_80194838.png`, `ss_7fd146aa.png`, `ss_b1536722.png`, `ss_0a9419c5.png`, `ss_395cc8fd.png`, `ss_4f92cdc8.png`, `ss_a6ad576e.png`, `ss_31725205.png`, `ss_30fff3a3.png`, `ss_793c5cc3.png`, `ss_a457e713.png`, `ss_415a39e0.png`, `ss_64d3c283.png` (todos bajo `/home/ubuntu/screenshots/`).
- Comentario PR sugerido: ninguno; no se indicó PR.
- SKILL.md adicional: ninguno.
- Blueprint organizativo consultado: cubre launcher MCP, no el acceso de navegador. Sugerencia: documentar SSO NOPRO, verificación de identidad, reutilización de sesión UI y maximización de Chrome con `wmctrl`; sin instalaciones o servicios adicionales que incorporar.
- Necesario del usuario: ninguna credencial ni acción adicional para entregar esta ronda. Las observaciones anteriores quedan para decisión funcional.
