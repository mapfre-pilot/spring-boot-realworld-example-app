# R50-B — Pruebas funcionales parciales en Appian TEST

Fecha: 16/11/2026. UI real de SCA2, usuario funcional SISANS (SI24 Experto), autenticación SSO Mapfre NO PRO. Solo `https://mapfrespain-test.appiancloud.com/suite/sites/sca2`. No se ha accedido a PRO, modificado objetos Appian, ejecutado SQL ni hecho commits. No se han modificado solicitudes antiguas ni llamado a `SCA2_consultarListadoArgumentosREST`.

## Discrepancia inicial aclarada y continuación

Se detuvo inicialmente la ejecución por la cabecera Incompleta tras la positiva de **15789172**. El responsable confirmó que no era R50-B: CompletarAccion 17596822 v51.0 terminó con finalizarContraAnulPca=true, finalizarSolicitud=true, wrErr=false; Solicitud FINALIZADA_POSITIVO / FIN y tarea 910 COMPLETADA. Se autorizó continuar.

En la segunda ejecución, 15789172 ya muestra **Finalizada Positiva**, antes y después de pulsar **Actualizar datos**. En SCA, consultada sin modificarla, la misma solicitud también muestra **Finalizada Positiva**. La discrepancia inicial queda como observación CORE/caché de cabecera, no fallo R50-B.

**Cobertura incompleta:** `/suite/sites/sca2/page/errores` muestra «Se ha producido un error. La página no existe o no tiene permiso para verla» tanto con JJGONZ2 como con SISANS. No hay nodo técnico en este mensaje de acceso. No se pudo verificar el funcionamiento de la bandeja.

## Resultados

Pólizas utilizadas del bloque reservado `bloque-R50-B.txt`: **0732300314838**, **0731800083179**, **2002400004454**. Solicitudes nuevas propias: **15789172**, **15789179**, **15789182**. Se utilizaron SISANS y JJGONZ2, siempre SSO NO PRO.

| Escenario | Nº solicitud | Póliza | Pasos | Resultado | Tareas PENDIENTE por tipo | Errores |
|---|---|---|---|---|---|---|
| a) Alta nueva | 15789172 | 0732300314838 | ALTA → NO VIDA → DECISION DE CLIENTE / PRECIO / ME HA SUBIDO MUCHO LA PRIMA → TELEFONICO → A VENCIMIENTO 01/02/2027 → observaciones 240 caracteres → GUARDAR → ACEPTAR | **Pasó**: abre Contra anulación; después se encuentra en bandeja por póliza | CONTRAANULAR: **1**, id 910 | **0** nuevos |
| b) Posponer, observación larga | 15789172 | 0732300314838 | Observaciones **250/250** → POSPONER → ACEPTAR | **Pasó**: «CORRECTO. Los datos se han guardado correctamente»; texto completo visible en detalle y bandeja | CONTRAANULAR: **1**, mismo id 910; asignadoA vacío | **0** nuevos; ningún WRITE_FAIL |
| c) Retomar | 15789172 | 0732300314838 | Bandeja por póliza → solicitud → desplegar Contra Anulacion → RETOMAR | **Pasó**: abre argumentario, conserva 250 caracteres | CONTRAANULAR: **1**, mismo id 910; asignada SISANS; fechaCaptura 15:47:01 UTC | **0** nuevos |
| d) Contraanulación positiva | 15789172 | 0732300314838 | POSITIVO → ACEPTAR; reapertura posterior → Actualizar datos | **Pasó al reabrir**: Finalizada Positiva antes/después de actualizar, igual que en SCA | **0**; id 910 COMPLETADA | **0** nuevos |
| e) Contraanulación negativa, solicitud distinta | 15789179 | 0731800083179 | Alta nueva → argumentario → NEGATIVO → guardar | **Pasó primer nivel**: CORRECTO y siguiente tarea Nivel 2; no se resuelve Nivel 2 | CONTRAANULAR: 0 (916 COMPLETADA); CONTRA ANULAR NIVEL 2: **1** (917) | **0** nuevos |
| f) Acción Administrativa | 15789182 | 2002400004454 | JJGONZ2: alta nueva → DECISION DE CLIENTE / VENTA DEL VEHICULO / NO VOY A COMPRARME OTRO COCHE → PRESENCIAL → A FECHA → aceptar → VILLALBA → cliente no entrega documentación → FINALIZAR → ACEPTAR | **Pasó**: CORRECTO; AA Finalizada en detalle; MECANIZAR pendiente. No se pulsa ANULAR PÓLIZA | AA: 0 (920 COMPLETADA); MECANIZAR: **1** (921) | **0** nuevos |
| g) Reapertura sin duplicados | 15789172 | 0732300314838 | POSPONER y RETOMAR, mismo caso de b/c | **Pasó para esta reapertura UI**: no hay segunda tarea. **Sin probar** el relanzamiento del nodo creador ni concurrencia | CONTRAANULAR: **1** antes y después; id 910 | **0** nuevos |
| Regresión: bandeja | 15789172 | 0732300314838 | Volver tras posponer → pestaña Póliza → escribir póliza → abrir solicitud | **Pasó**: aparece la solicitud nueva y sus observaciones | Misma tarea | **0** nuevos |
| Regresión: /errores | — | — | Acceso directo con JJGONZ2 y SISANS | **Sin verificar**: página inexistente o sin permiso con ambos perfiles | No aplica | MCP sin errores nuevos |

Observaciones adicionales: 15789179 mostró tarjetas Contra Anulacion Incompleta, pero MCP confirma 916 completada y una sola tarea 917 de Nivel 2 pendiente. Se registra como observación de presentación/caché, no como duplicación R50-B. SISANS no ofreció Venta del vehículo en el catálogo; se abandonó ese formulario sin guardar y se completó AA con JJGONZ2.

## Alcance de las lecturas

MCP TEST `appian-dev-mcp-c90b`, exclusivamente `listRecordData`:

- Tarea `696285d3-cb21-4f27-adce-66354ebf2b89`: lectura inicial de 909 filas; lecturas posteriores desde offset 909 y selección por `idSolicitud=15789172`. La herramienta disponible no admite filtro servidor, solo uuid/limit/offset.
- Error `d7111f93-55f3-4b43-b921-aedadd2af7c3`: lectura inicial de **149 filas**, último id **226**; posteriores desde offset 149, todas vacías. El baseline tampoco contiene 15789172. No se observaron errores nuevos en ningún paso.
- Durante las pruebas aparecieron tareas de ejecuciones paralelas (911–915, 918–919): no son solicitudes propias ni se han manipulado.
- Las comprobaciones se hicieron tras alta, posponer, retomar y positiva. No se probaron errores repetidos con intentos crecientes porque no se produjo ninguno; tampoco se forzaron fallos ni relanzamientos técnicos.
- La UI limita el alta a 240 y la gestión a 250 caracteres. Esto prueba el guardado al máximo de UI, **no** la rama `left(...,255)` con entradas superiores a 255.
- La segunda ejecución compara 15789172 en SCA: Finalizada Positiva. Lectura final de tareas desde offset 909 confirma 910 COMPLETADA, 916 COMPLETADA + 917 PENDIENTE y 920 COMPLETADA + 921 PENDIENTE. Ninguna duplicación pendiente por tipo/solicitud propia. Errores desde offset 149 sin filas tras negativa, alta AA, finalización AA y comprobación final.
- No se inspeccionaron instancias de proceso mediante diseño; no se observaron bloqueos funcionales, pero no se certifica ausencia global de procesos parados. No se afirma cobertura completa ni que todo funcione perfectamente.

## Evidencias locales

No se han subido archivos: quedan para que el responsable los suba.

- `r50b-funcional.mp4`: primera grabación, del alta hasta la discrepancia inicial.
- `r50b-funcional-2.mp4`: continuación anotada con positiva reabierta, negativa, AA, acceso bloqueado a errores y consulta SCA.
- `06-positiva-reabierta-actualizada.png`: positiva finalizada.
- `07-negativa-guardada-nivel2.png`: confirmación negativa y tarea siguiente.
- `08-autos-sin-venta-vehiculo.png`: catálogo SISANS.
- `09-aa-guardada-correctamente.png`, `10-aa-finalizada-mecanizacion-pendiente.png`: AA completada.
- `11-errores-acceso-jjgonz2.png`, `12-errores-acceso-sisans.png`: bloqueo de acceso.
- `13-sca-positiva-solo-consulta.png`: comparación SCA.
- `verificaciones-mcp-2.txt`: extracto de lecturas de continuación.
- `01-alta-240-caracteres.png`: formulario con 240/240.
- `02-posponer-250-caracteres.png`: gestión con 250/250 antes de posponer.
- `02b-posponer-correcto.png`: confirmación del guardado.
- `03-bandeja-solicitud-nueva.png`: solicitud 15789172 en bandeja por póliza.
- `04-observaciones-guardadas-retomar.png`: texto persistido y botón RETOMAR.
- `05-ca-positiva-detalle-incompleta.png`: estado Incompleta después de Actualizar datos.
- `tareas-inicial.csv`, `errores-inicial.csv`: baseline técnico solo lectura.
- `verificaciones-mcp.txt`: extracto de la solicitud propia por paso.

## Pendiente del responsable

Confirmar ruta/perfil autorizado para `https://mapfrespain-test.appiancloud.com/suite/sites/sca2/page/errores`. Quedan sin probar el relanzamiento técnico de creación, concurrencia, actualización de intentos de errores repetidos y entradas superiores a 255. No se forzaron fallos ni se realizaron escrituras MCP. No se proporcionó PR: comentario PR sugerido, ninguno.

Configuración: no se instalaron dependencias ni se iniciaron servicios. Se leyó el blueprint y se reutilizaron Chrome, MCP y credenciales existentes; solo se maximizó Chrome y se creó esta carpeta de evidencias. No se sugieren cambios de blueprint ni SKILL.md.
