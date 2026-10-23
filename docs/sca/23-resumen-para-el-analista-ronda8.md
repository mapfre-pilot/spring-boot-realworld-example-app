# SCA2 — Resumen para el analista (pruebas de los planes, 13/10/2026)

## Qué se ha hecho

Se han ejecutado en Appian TEST los 10 planes de prueba de SCA (Alta, Contra Anular, Argumentos, Conceptos y clases, Gestión de solicitudes, Detalle, Mecanización, Autorización, Acciones Administrativas y Gestión de la aplicación) comparando en cada caso lo que hace SCA con lo que hace SCA2, con los usuarios JJGONZ2 (oficina) y SISANS (SI24) y las pólizas wAutemis normales y RCI que nos pasasteis. Sólo el plan de Alta tenía la columna de aplicación informada (39 casos SCA); en los otros nueve estaba vacía y se han probado todos sus casos.

## Resultado en cifras

| | Casos |
|---|---|
| Casos probados en los que SCA2 se comporta igual que SCA | 79 |
| Diferencias encontradas y ya corregidas en SCA2 | 13 |
| Diferencias que necesitan una decisión funcional | 11 |
| Casos que no se han podido probar en TEST | 100 |
| **Total** | **203** |

## Qué se ha corregido en SCA2

- **Contra Anulación:** el contador de veces pospuesta era siempre 1; «Recargar argumento» dejaba el argumentario vacío; SISANS veía las oficinas de quien dio el alta en vez de las suyas; la búsqueda de argumentos no reflejaba los cambios recién guardados; la tarjeta Contra Anulación del Detalle no mostraba las observaciones.
- **Acciones Administrativas:** finalizar sin documentación (o con una causa que exige contrato) ahora cataloga a vencimiento y avisa, como SCA; Cancelar ya deja la observación registrada; algunos tipos de documento hacían fallar el cierre de la acción.
- **Mecanización:** cuando una Autorización o una Acción Administrativa cambia la fecha de anulación, SCA2 mecanizaba con la fecha original del alta; ahora usa la fecha vigente, como SCA.
- **Buscador y Detalle:** la lista de últimas solicitudes sólo mostraba 10 filas; una póliza inexistente no daba el aviso de SCA; la causa y las fechas de cada fila no salían de la misma fuente que SCA; el menú de Gestión de conceptos no funcionaba.
- **Bandeja de errores:** el error pendiente de la solicitud 15787868 se ha relanzado y la solicitud ha pasado a Mecanizar.

## Qué necesitamos que decidáis (resumen; detalle en el documento de dudas)

1. **Alta:** SCA deja pulsar GUARDAR y avisa de los campos obligatorios; SCA2 no deja pulsar hasta completarlos. ¿Cuál se quiere?
2. **Acción Administrativa pospuesta de nivel 1:** en SCA SISANS sólo puede consultarla; en SCA2 puede retomarla. ¿Quién debe poder retomar?
3. **Autorización pendiente tras mecanizar:** SCA muestra el mensaje de petición de autorización y estado «Pendiente»; SCA2 muestra «anulación lanzada» y «Mecanización enviada». ¿Igualamos?
4. **Cancelar una autorización:** CORE devuelve error en TEST tanto desde SCA como desde SCA2; SCA2 muestra «Correcto» y registra el fallo después. ¿Cómo debe verlo el usuario?
5. **Buscador:** la lista inicial de SCA trae todas las solicitudes del gestor en CORE; SCA2 sólo las creadas en SCA2. ¿Debe traer todas? La pestaña «Otras solicitudes de anulación», ¿debe alimentarse de CORE como SCA?
6. **SI24:** las preguntas de contacto, el cierre «Ilocalizable» a la tercera gestión y la impresión (activa en SCA aunque el plan la espera inactiva). ¿Qué comportamiento es el correcto?
7. **Presentación:** maquetación de la pestaña Cliente e icono del hito Anulación, ¿hay que igualarlos a SCA?
8. **Desactivar/Activar la aplicación:** no se ha probado porque el interruptor de CORE es común y apagaría también SCA. ¿Se prueba igualmente?

## Por qué no se han probado 100 casos

Casi todos necesitan datos que no existen en TEST: pólizas NSE, Vida, Más Móvil, Ibericar, telemáticas, CCC/CCR, corredor, Verti, campañas (TTQ, PREMFIDE, RETOS, SVA), origen FDC, plan de pagos, simulación PRRA y los errores M201/M206. Además SCA TEST ha sido inestable (esperas de más de 25 minutos, «Acceso denegado» y tareas que no se generaban), por lo que varios casos que exigían usar SCA no se pudieron comparar. Si nos facilitáis pólizas de esos tipos, se completan.

Documentos de apoyo (rama `feature/sca`): `docs/sca/pruebas/15-ronda8-consolidado.md` (detalle de todos los casos), `docs/sca/22-dudas-funcionales-para-el-analista.md` (preguntas completas).
