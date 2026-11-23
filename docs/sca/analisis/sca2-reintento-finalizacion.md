# SCA2: recuperación de finalizaciones fallidas

## Alcance y estado

En TEST, **Errores** incluye el indicador de solicitudes que siguen en `ERROR` con nodo de relanzamiento `Finalizar PCA`, una fila por solicitud y con los mismos filtros de alta, línea y origen del cuadro. En la comprobación inicial había siete. El indicador no afirma que los cierres externos de esas solicitudes estén confirmados.

El responsable de BD aplicó la migración en TEST. Appian confirmó las tres tablas y `habilitado=false`. La constante `SCA2_REINTENTO_FIN_ACTIVO` está en `false`: no se captura ni se reserva en el flujo habitual, el batch no está programado y no se ejecuta trabajo automático. No activar sin una decisión expresa.

Modelos publicados en TEST: [Finalizar 24.0](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=1173), [MarcarErrorRelanzado 38.0](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=1619) y [Batch Reintentar Finalizaciones 6.0](https://mapfrespain-test.appiancloud.com/suite/process/startdesigner.none?idToOpen=6132). Appian validó los tres sin errores. Un diagnóstico temporal pasó por JDBC con el interruptor SQL apagado y devolvió `[]`; la versión del batch que se dejó en TEST no contiene la vía de diagnóstico.

## Instalación en TEST (solo tras autorización)

1. En el origen **SCA2 DataBase AWS** de TEST, ejecutar [el script SQL](../sql/sca2-reintento-finalizacion.sql) entero en DBeaver (Alt+X, parar ante error), con un usuario que pueda asumir `user_sca2_anulaciones`. La última consulta debe devolver `false` en una primera instalación. No ejecutar en producción.
2. Verificar que el origen JDBC de Appian usa `escapeSyntaxCallMode=callIfNoReturn` (o `call`) y que su rol puede ejecutar las rutinas. El script revoca permisos a `PUBLIC`. Si el rol de ejecución difiere del propietario, el responsable de BD debe conceder solo los permisos necesarios sobre las tres rutinas JDBC, sus funciones y los objetos SCA2 que usan; no otorgar permisos masivos sobre el esquema. El rol de ejecución no necesita modificar la configuración.
3. Validar los parámetros del nodo [Execute Stored Procedure](https://docs.appian.com/suite/help/26.6/Execute_Stored_Procedure_Smart_Service.html#postgresql) contra el origen real. Los modelos usan el sistema conectado `SCA2_CS_BD_AWS`, validación de parámetros activada y autocommit. La salida JDBC se lee como `ac!parameters.salida`.

## Cableado y criterios antes de habilitar

| Modelo | Cambio |
|---|---|
| **SCA2 CMD Finalizar** | Capturar solo tras `Write Error` sin error de escritura, cuando el fallo anterior fue `WRITE_FAIL` en `Write FINALIZADA`. Usar el ID exacto del `SCA2 Error` devuelto por `Records Updated` (salida tipada, no buscar el último error). Pasar la versión y estado leídos en Cargar, el estado final efectivo que iba a escribirse, el ID de la instancia y su inicio en UTC. Confirmar PCA únicamente con `successPca=true`; confirmar SGC únicamente con código explícito `0` de la regla (normaliza la respuesta de servicio `9`) o cuando el propio flujo omitió SGC por no aplicar. Una salida nula no es confirmación. Si no hay evidencia completa o la captura falla, dejar el error original pendiente y registrar el fallo técnico; no repetir servicios. |
| **SCA2 CMD MarcarErrorRelanzado** | Solo para Finalizar con ID conocido, consultar la reserva antes de marcar el error. `NORMAL`: ejecutar el nodo de marcado original; `LANZAR`: la misma marca ya se escribió atómicamente en BD, sincronizar ese `SCA2 Error` y continuar por el mismo nodo de carga/ruteo; `OMITIR`: finalizar sin iniciar otro cierre. Los otros comandos no pasan por la reserva. El relanzamiento en lote existente usa este mismo comando. Dejar la rama original como única ruta en TEST hasta habilitar la reserva como parte de una activación aprobada. Después, no hacer fallback al cierre externo ante una respuesta ambigua de la reserva. |
| **SCA2 — batch de recuperación** | Nuevo modelo SCA2 con cadencia de 30 minutos, sin programación activa en TEST. Ejecutar `sca2_pm_ejecutar_reintento_fin` con usuario e ID de instancia y la constante vigente `SCA2_USAR_CACHE_CABECERA`. Procesa hasta 25 casos por ejecución y hasta tres intentos por caso; no invoca PCA, SGC, NSE ni notificaciones. Los casos históricos no se precargan. |

La escritura directa en PostgreSQL no sincroniza los record types. Guardar los IDs de la salida del batch antes de sincronizar **Solicitud**, **Error**, **Transición** y **Datos Cabecera** (solo si hay filas de caché). Si una sincronización falla, reintentar con esos mismos IDs, no relanzar el cierre. No habilitar si Appian no puede reintentar la sincronización fallida conservando los IDs en la instancia.

**Antes de activar:** probar en un entorno aislado, con datos sintéticos y sin invocar servicios reales, la captura del ID exacto, un estado final no estándar y la sincronización visible en Errores. Los dos órdenes de la carrera manual/batch ya se probaron en PostgreSQL local, no de extremo a extremo en Appian. Inventariar todos los puntos de relanzamiento de Finalizar, habilitar la reserva en Appian antes que el batch y no habilitar con instancias manuales que no hayan pasado por ella.

**Desactivación:** detener el timer y dejar `habilitado=false`; drenar el lote en curso y completar cualquier sincronización pendiente. El ajuste SQL no deshace un cierre ya confirmado y persistido.

## Prueba repetible de PostgreSQL

En una BD local vacía con PostgreSQL 14, crear el rol `user_sca2_anulaciones`, aplicar [la estructura SCA2](../sql/73-promocion-bd-sca2-estructura.sql), aplicar la migración y ejecutar [la prueba transaccional](../pruebas/sca2-reintento-finalizacion-local.sql) con `psql -v ON_ERROR_STOP=1`. La prueba usa datos sintéticos y termina con rollback.
