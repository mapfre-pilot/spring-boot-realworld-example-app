# R43-A — Informe final de pruebas UI en Appian TEST

Se ejecutó el procedimiento mediante la UI real de SCA2 y SCA en `https://mapfrespain-test.appiancloud.com`, con resultados parciales y fallos. **El alta Vida sigue fallando incluso después de SCA2_PreGenerarStudAnul v3.** No se usó PRO, no se modificaron objetos Appian y no se hizo commit.

## Incidencias y cobertura incompleta

- El último intento autorizado, **0005912462**, falló en `generarStudAnul`, referencia **PDTE-735412**. Se detuvieron definitivamente las altas Vida, sin pulsar ACEPTAR del error.
- Los intentos anteriores 0005912434 y 0005912443 fallaron en el mismo paso; se detallan como historial, no como nueva verificación del despliegue v3.
- Catálogo Vida UI: **4 detalles y 9 causas**, frente a los 5 detalles y 12 causas indicados por el responsable. Faltan `MALA GESTION` y sus causas 12, 10 y 11. También se observó la ausencia de MALA GESTION en el último formulario 0005912462.
- SCA rechazó 0005912432; no fue posible comparar su cabecera ni desplegables campo a campo con SCA. No se infiere paridad por consultas LCP.
- GESVIDA generó una URL en `webvida.pre.mapfre.net`, pero el destino mostró `DNS_PROBE_FINISHED_NXDOMAIN`; su funcionamiento no quedó validado.
- La consulta posterior en buscador de las altas fallidas 0005912434 / 0005912443 quedó **sin ejecutar** al recibir la orden final de parar del todo si volvía a fallar Vida. No se afirma que no existan filas PDTE.
- No hubo solicitud Vida creada y accesible en UI; por tanto, primera gestión, cabecera de solicitud creada y segunda apertura de una nueva solicitud Vida quedaron sin verificar.
- Hogar y Autos llegaron a primera gestión antes del último cambio backend. Sus segundas aperturas se comprobaron después, sin crear más solicitudes. No se volvió a ejecutar el alta de Autos/Hogar tras v3.

## Resultados por aserción

- **passed** — 0005912432 muestra AG y 105333 / 5324209 en SCA2; las cuatro pestañas mantienen sus datos al cerrar y reabrir.
- **passed** — No se pulsó GUARDAR ni ACEPTAR con 0005912432 ni se abrió/modificó su solicitud anterior.
- **untested** — Paridad completa SCA/SCA2 de cabecera y catálogos Vida: SCA impidió acceder.
- **passed** — Vida muestra solamente DECISION DE CLIENTE como motivo, no los tres de Autos.
- **failed** — Catálogo Vida completo esperado: falta MALA GESTION y sus tres causas.
- **failed** — Apertura funcional de GESVIDA: destino no resolvió DNS.
- **passed** — 0005912430 se descartó sin alta por solicitud previa 15783812.
- **failed** — Alta 0005912434 hasta primera gestión: ALTA_ERROR en generarStudAnul, PDTE-9158129.
- **failed** — Alta 0005912443 hasta primera gestión: ALTA_ERROR en generarStudAnul, PDTE-735385.
- **passed** — Regresión Hogar: productor/clave, dos motivos y alta 15788719 hasta Contra anulación.
- **passed** — Regresión Autos: productor/clave, tres motivos y alta 15788720 hasta Contra anulación.
- **passed** — Segunda apertura de 15788719 y 15788720 mantiene producto, productor y clave.
- **passed** — 0005912462: CreciVida, AG, 86629 / 5252013 y tabla de solicitudes previas vacía antes de enviar.
- **passed** — 0005912462 permite PRECIO / ME HA SUBIDO MUCHO LA PRIMA y calcula A VENCIMIENTO, 27/05/2027.
- **failed** — Alta 0005912462 con PreGenerarStudAnul v3: ALTA_ERROR en generarStudAnul, PDTE-735412, después de un solo ACEPTAR.
- **untested** — Consulta posterior de filas PDTE para 0005912434 / 0005912443, por cierre inmediato ordenado.

## Cabecera Vida 0005912432: comparación campo a campo

En la tabla, **N/V** significa «no verificable en SCA, porque rechazó la póliza». No significa vacío ni igual a SCA2. Los valores de SCA2 fueron iguales en la primera y segunda apertura.

| Pestaña | Campo | SCA2 primera apertura | SCA2 segunda apertura | SCA |
|---|---|---|---|---|
| Datos cliente | Nombre | EXA | EXA | N/V |
| Datos cliente | Apellidos | MIVEFET GETTAJREV | Igual | N/V |
| Datos cliente | Documento identificativo | 85655488S | Igual | N/V |
| Datos cliente | Carterizado | No | Igual | N/V |
| Datos cliente | Dto. integralidad nueva producción | - | Igual | N/V |
| Datos cliente | Tréboles | 0,00 | Igual | N/V |
| Datos cliente | Activo Club Mapfre | Sí | Igual | N/V |
| Datos cliente | Perfil Club Mapfre | Platino | Igual | N/V |
| Datos cliente | Tipo cliente por valor | Flecha azul hacia abajo | Igual | N/V |
| Datos póliza | Número póliza | 0005912432 | Igual | N/V |
| Datos póliza | Nombre producto | 00409 - CreciVida | Igual | N/V |
| Datos póliza | Ramo | 101 | Igual | N/V |
| Datos póliza | Línea negocio | Vida | Igual | N/V |
| Datos póliza | Forma de pago | Anual | Igual | N/V |
| Datos póliza | Fecha efecto | 27/05/2026 | Igual | N/V |
| Datos póliza | Fecha vencimiento | 27/05/2027 | Igual | N/V |
| Datos póliza | Antigüedad | 1 años | Igual | N/V |
| Datos póliza | Plan de pago | - | Igual | N/V |
| Datos póliza | Prima actual | 1308.2€ | Igual | N/V |
| Datos póliza | Cesión de Derechos | NO | Igual | N/V |
| Datos póliza | Clave producción | 105333 / 5324209 | Igual | N/V |
| Datos póliza | Tipo productor | AG | Igual | N/V |
| Datos póliza | Revalorizacion | Constante | Igual | N/V |
| Datos póliza | Descuentos | 0% | Igual | N/V |
| Otras sol. Anulación | Número solicitud | 15788717 | Igual | N/V |
| Otras sol. Anulación | Estado | Solicitud Finalizada sin anular | Igual | N/V |
| Otras sol. Anulación | Fecha solicitud | 03/11/2026 13:34:00 | Igual | N/V |
| Otras sol. Anulación | Número póliza | 0005912432 | Igual | N/V |
| Otras sol. Anulación | Línea negocio | Vida | Igual | N/V |
| Otras sol. Anulación | Causa anulación | Compromisos | Igual | N/V |
| Otras sol. Anulación | Fecha resolución | 03/11/2026 13:36:48 | Igual | N/V |
| Otras sol. Anulación | Observaciones | - | Igual | N/V |
| Datos contacto | Vía | Calle | Igual | N/V |
| Datos contacto | Domicilio | ALCALA | Igual | N/V |
| Datos contacto | Número | 220 | Igual | N/V |
| Datos contacto | Piso | - | Igual | N/V |
| Datos contacto | Puerta | A | Igual | N/V |
| Datos contacto | Escalera | - | Igual | N/V |
| Datos contacto | Provincia | Madrid | Igual | N/V |
| Datos contacto | Localidad | MADRID | Igual | N/V |
| Datos contacto | País | ESPAÑA | Igual | N/V |
| Datos contacto | Código postal | 28011 | Igual | N/V |
| Datos contacto | Teléfono móvil | 636894702 | Igual | N/V |
| Datos contacto | Teléfono fijo | - | Igual | N/V |
| Datos contacto | Correo electrónico | aamunoz@minsait.com | Igual | N/V |

Rechazo literal, tanto en búsqueda SCA2 como en SCA:

> La póliza no es una póliza válida o no se encuentra disponible, por lo tanto, no se puede gestionar la anulación por SCA.

La cabecera SCA2 se obtuvo desde el formulario de alta Vida, exclusivamente en lectura. SCA real se probó en `/suite/sites/sca-site/page/b-squeda`; `/suite/sites/sca` no es la referencia correcta porque redirige a SCA2.

## Catálogos Vida observados

Motivo visible único: **DECISION DE CLIENTE**.

| Detalle visible | Causas visibles en UI |
|---|---|
| ASEGURADO NO DESEA SEGURO | COMPROMISOS |
| PRECIO | ME HA SUBIDO MUCHO LA PRIMA; MEJOR PRECIO DE LA COMPETENCIA; NO PUEDO PAGAR ESA CANTIDAD |
| PRODUCTO | EL PRODUCTO NO SATISFACE AL CLIENTE; ME GUSTARIA BAJAR CAPITALES; MEJORES COBERTURAS EN OTRA COMPAÑIA; NO QUIERO TANTAS GARANTIAS |
| VENTA/DESAPARICION DEL RIESGO | PRESTAMO DESAPARECIDO |
| MALA GESTION | **No visible**; causas 12, 10 y 11 no accesibles |

Los IDs de catálogo esperados proceden del responsable, no se muestran en el desplegable: motivo 1; detalles 9, 4, 1, 2, 10; causas 30; 12/10/11; 1/3/2; 6/34/4/33; 35, respectivamente.

## Altas e identificadores

| Póliza | Resultado UI | ID / referencia | Estado / primera gestión |
|---|---|---|---|
| 0005912430 | No usada; solicitud previa | 15783812, previa | Solicitud Finalizada sin anular; no modificada |
| 0005912434 | Fallo al confirmar alta | PDTE-9158129 | No se pudo crear; no hubo primera gestión |
| 0005912443 | Fallo al confirmar alta | PDTE-735385 | No se pudo crear; no hubo primera gestión |
| 0731480121955 | Alta completada | 15788719 | Solicitud Pendiente; Contra anulación abierta |
| 2002300311820 | Alta completada con espera prolongada | 15788720 | Solicitud Pendiente; Contra anulación abierta |
| 0005912462 | Fallo tras el cambio PreGenerarStudAnul v3 | PDTE-735412 | No se pudo crear; no hubo primera gestión |

### Vida

- 0005912434: producto 00529 - Confianza VIDA; productor `-`, clave `25064 /`. El responsable confirmó que son datos TEST iguales a SCA; no se clasificó como diferencia SCA/SCA2. Otras sol. Anulación vacía antes de guardar.
- 0005912443: producto 00409 - CreciVida; productor AG; clave 10045 / 5266862. Otras sol. Anulación vacía. DECISION DE CLIENTE → PRECIO → ME HA SUBIDO MUCHO LA PRIMA; A VENCIMIENTO, 27/05/2027.
- 0005912462: producto 00409 - CreciVida; productor AG; clave 86629 / 5252013. Otras sol. Anulación vacía. Misma selección y fecha que 2443. Un solo ACEPTAR de confirmación; el error ya era visible al comprobar la pantalla a los 8 segundos. No se dispone de medición más fina de latencia.
- Antes de guardar el último intento estaban deshabilitados compañía aseguradora contraria, medio comunicación, número fax y fecha/calendario de anulación; catalogación A VENCIMIENTO y fecha fueron calculadas. En el resultado de error el formulario quedó sustituido por el mensaje y un botón ACEPTAR, que no se pulsó.

Errores literales:

> Los datos no se han podido guardar correctamente. La solicitud no se ha podido crear. Error: ALTA_ERROR - Datos insuficientes para la operacion (paso: generarStudAnul). Póliza: 0005912434. Referencia: PDTE-9158129. Reporte este error a mantenimiento SCA.

> Los datos no se han podido guardar correctamente. La solicitud no se ha podido crear. Error: ALTA_ERROR - Datos insuficientes para la operacion (paso: generarStudAnul). Póliza: 0005912443. Referencia: PDTE-735385. Reporte este error a mantenimiento SCA.

> Los datos no se han podido guardar correctamente. La solicitud no se ha podido crear. Error: ALTA_ERROR - Datos insuficientes para la operacion (paso: generarStudAnul). Póliza: 0005912462. Referencia: PDTE-735412. Reporte este error a mantenimiento SCA.

### Regresión Hogar y Autos

| Campo | Hogar | Autos |
|---|---|---|
| Póliza | 0731480121955 | 2002300311820 |
| Producto | HOGAR BÁSICO | BASICar TERCEROS AMPLIADO |
| Línea | HOGAR | AUTOMOVILES |
| Productor | INTERNET-TELEFO / Expertos / Telemática | RED AGEN / Expertos / No Telemática |
| Clave | 0507804 | 5273190 |
| Fecha efecto / vencimiento | 06/03/2026 / 06/03/2027 | 01/07/2026 / 01/07/2027 |
| Prima actual / renovación | 242.84€ / NO DISPONIBLE | 358.86€ / NO DISPONIBLE |
| Motivos | DECISION DE CLIENTE; DECISION DE LA ENTIDAD | DECISION DE CLIENTE; DECISION DE LA ENTIDAD; DESAPARICION DEL RIESGO |
| Causa solicitud | Más Prima | Más Prima |
| Fecha solicitud visible | 03/11/2026 14:01:44 | 03/11/2026 14:05:48 |
| ID | 15788719 | 15788720 |
| Estado | Solicitud Pendiente | Solicitud Pendiente |
| Primera gestión | Contra anulación | Contra anulación |
| Segunda apertura | Producto, productor y clave conservados | Producto, productor y clave conservados |

No se ejecutaron argumentos ni se finalizaron las gestiones. Autos permaneció cargando aproximadamente 90–100 segundos antes de permitir ver la primera gestión; se esperó sin reenviar. No se dispone de una duración exacta equivalente de Hogar.

## Evidencia visual principal

| Vida 0005912462 — cabecera antes de guardar | Vida 0005912462 — resultado del único envío |
|---|---|
| ![Vida 2462: cabecera](https://mapfre.devinenterprise.com/attachments/a8dfc6f9-01a5-47bc-ad28-60c0733c7234/r43-a-vida-2462-cabecera.png) | ![Vida 2462: error](https://mapfre.devinenterprise.com/attachments/2cd936c7-3ede-4f27-b128-35c32a1a9718/r43-a-vida-2462-alta-error.png) |

| Regresión Hogar — segunda apertura | Regresión Autos — segunda apertura |
|---|---|
| ![Hogar: caché](https://mapfre.devinenterprise.com/attachments/b626e9eb-5f04-4ceb-b027-b5cdd4db7dac/r43-a-hogar-cabecera-segunda.png) | ![Autos: caché](https://mapfre.devinenterprise.com/attachments/a6c912fb-4f78-4193-925e-87b9165b964c/r43-a-autos-cabecera-segunda.png) |

Vídeo del último despliegue probado:

`/home/ubuntu/screencasts/r43-a-vida-v3/r43-a-vida-v3-edited.mp4`

## Lista de capturas

Directorio absoluto de todas las capturas:

`../img/`

```text
r43-a-sca2-buscador-vida-rechazo.png
r43-a-sca-buscador-vida-rechazo.png
r43-a-sca-alta-vida-rechazo.png
r43-a-sca2-vida-cliente-primera.png
r43-a-sca2-vida-cliente-segunda.png
r43-a-sca2-vida-poliza-primera.png
r43-a-sca2-vida-poliza-segunda.png
r43-a-sca2-vida-otras-primera.png
r43-a-sca2-vida-otras-segunda.png
r43-a-sca2-vida-contacto-primera.png
r43-a-sca2-vida-contacto-segunda.png
r43-a-sca2-gesvida-dns.png
r43-a-sca2-vida-motivos.png
r43-a-sca2-vida-detalles.png
r43-a-sca2-causas-asegurado.png
r43-a-sca2-causas-precio.png
r43-a-sca2-causas-producto.png
r43-a-sca2-causas-venta.png
r43-a-vida-nueva-cabecera.png
r43-a-vida-nueva-solicitud-previa.png
r43-a-vida-2434-cabecera.png
r43-a-vida-2434-sin-previas.png
r43-a-vida-2434-popup.png
r43-a-vida-2434-alta-error.png
r43-a-vida-2443-cabecera.png
r43-a-vida-2443-sin-previas.png
r43-a-vida-2443-popup.png
r43-a-vida-2443-alta-error.png
r43-a-hogar-cabecera.png
r43-a-hogar-cabecera-segunda.png
r43-a-hogar-motivos.png
r43-a-hogar-primera-gestion.png
r43-a-hogar-id-15788719.png
r43-a-autos-cabecera.png
r43-a-autos-cabecera-segunda.png
r43-a-autos-motivos.png
r43-a-autos-primera-gestion.png
r43-a-autos-id-15788720.png
r43-a-vida-2462-cabecera.png
r43-a-vida-2462-sin-previas.png
r43-a-vida-2462-popup.png
r43-a-vida-2462-alta-error.png
```

## Cierre

- Pruebas cerradas tras el último error, sin más reintentos.
- Informe guardado fuera del checkout; capturas en el directorio solicitado. Sin commit.
- Sugerencias SKILL.md: ninguna; no se creó fichero.
- Blueprint consultado: configuración organizativa cubre Appian Dev MCP y dependencias. Para pruebas GUI conviene documentar la disponibilidad de `wmctrl` y la maximización con `wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz`. No se inició servidor local.
- Necesario para continuar: resolver el error de alta Vida y la diferencia del catálogo; cualquier nuevo intento requerirá autorización expresa y otra póliza. No se necesitan nuevas credenciales para explicar los resultados actuales.
