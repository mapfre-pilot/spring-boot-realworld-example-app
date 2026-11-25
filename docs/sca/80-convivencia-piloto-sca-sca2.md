# Convivencia SCA y SCA2 en TEST

La primera fachada se publicó en `sca-site/b-squeda`. Con `SCA2_BOOL_PILOTO_ACTIVO` encendido, los miembros de `SCA2 Piloto` ven allí el buscador de SCA2; el resto sigue en `SCA_BuscadorSolicitudPrincipal`. Las entradas de Decisora que llegan a ese site y las entradas legacy explícitas conservan esa misma interfaz. La extensión a `decidir-accion` se detalla más abajo. No se cambiaron Decisora, portales ni los procesos de alta y relanzamiento.

El alta nueva en la fachada exige pertenecer al piloto y tener encendido el interruptor. En el site nativo `sca2/buscador`, pueden dar altas los miembros de `SCA2 Piloto` o de `SCA2 Administrators` (`SCA2_GRP_ADMINISTRADORES`), incluso con el interruptor apagado. El site nativo sigue disponible para tramitar. La ACL de `SCA2 CMD Alta` no se modificó; las pruebas abrieron el popup sin confirmar el alta. En la primera publicación de TEST solo el piloto podía abrir un alta nativa; la última revisión restituyó ese acceso a los administradores.

## Objetos en TEST

| Objeto | UUID | Versión inicial → publicada |
| --- | --- | --- |
| `SCA_Site` | `c8ed5d26-77ce-4878-9ee7-e85153335ae5` | 2 → 3 |
| `SCA_SolicitudesPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5797574` | Nueva → 2 |
| `SCA2_pilotoHabilitado` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5797522` | Nueva → 1 |
| `SCA2_BuscadorTablaPiloto` | `_a-0000f0bf-3e32-8000-9d57-011c48011c48_5797552` | Nueva → 2 → 3 |
| `SCA2_Buscador` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | 41 → 43 → 44 |
| `SCA2_AltaSolicitudPage` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055716` | 57 → 59 → 60 |
| `SCA2_BandejaErrores` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055578` | 18 → 19 |
| `SCA2_DetalleSolicitud` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 78 → 79 |
| `SCA2_DetalleTareas` | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055554` | 45 → 46 |
| `SCA2_BOOL_PILOTO_ACTIVO` | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5632095` | 5 → 13 → 15 (`false`); 16 (`true`, confirmado en la revisión de ambos sites) |

La fachada se creó duplicando la interfaz en Designer para mantener el tipo `mssConsultarSolicitudesDTO` y la metadata de `solicitud`. El MCP de TEST rechazó ese tipo para la creación de la interfaz. El resto de las publicaciones se hizo por MCP.

Las páginas `errores-sca2` y `gestion-mantenimiento-sca2` de SCA se mostraban inicialmente a todo el piloto activo; desde el [ajuste de visibilidad](#visibilidad-de-errores-y-mantenimiento-sca2--test) requieren además pertenecer a SCA2 Administradores. Apuntan a `SCA2_BandejaErrores` y `SCA2_GestionMantenimientoMenu` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20060073`) sin modificar sus permisos. Errores muestra «No tienes permiso para ver esta página» cuando se abre sin rol administrador y no presenta acciones de relanzar ni descartar. La página nativa de Errores sigue visible solo para administradores. La página de mantenimiento legacy no cambia.

## Tabla y activación

- La tabla mixta solo se activa en la fachada para búsqueda por póliza. Combina CORE y registros vivos/históricos de SCA2, identifica SCA por evidencia en su registro operativo, deduplica por ID antes de ordenar y paginar, y muestra etiqueta y color. Una fila CORE sin origen acreditado no se etiqueta como SCA; las colisiones quedan marcadas sin acción cruzada. Los `PDTE-*` siguen separados.
- La columna Estado traduce el código de las filas SCA con `SCA_D_EstadosSolicitud`, la misma decisión de literales que usa `SCA_BuscadorTabla`. El estado de las demás filas no cambia.
- El ID de una fila SCA abre `SCA Redirigir Detalle Solicitud`; el de SCA2 abre su detalle. Si alguna de las consultas informa más de 250 solicitudes, se muestra un aviso en lugar de una página parcial.
- Para habilitar la experiencia en TEST, configurar `SCA2_BOOL_PILOTO_ACTIVO = true`. Para deshabilitarla, usar `false`: SCA vuelve al recorrido legacy y oculta las dos pestañas. No se elimina el acceso nativo de SCA2. No se desplegó ni activó PRO.
- En las 19 instancias de `SCA2 CMD Alta` visibles en el historial de TEST, `CFERNA7` inició 5 y la cuenta administrativa `devin`, fuera del piloto, inició 14. El historial no identifica el canal de arranque y no incluye procesos ya purgados. La excepción de alta para administradores se aplica solo al site nativo.

## Verificación

- Antes del cambio de destino, el buscador legacy y la fachada devolvieron `ContentLayout` sin error para la entrada normal y el retorno de error de Decisora. Se comprobó que los diez inputs heredados son idénticos, incluido el CDT.
- `testRule`: CFERNA7 `false` con el interruptor apagado y `true` encendido; SISANS `false` en ambos estados.
- En Chrome CDP, CFERNA7 abrió el popup nativo de alta con el interruptor apagado y el popup de alta dentro de SCA con el interruptor encendido (`sca2-alta-cferna7-interruptor-apagado.png`, `sca-alta-fachada-cferna7.png`). No se confirmó ni se creó una solicitud. SISANS conservó el buscador legacy y no vio las pestañas nuevas con el interruptor encendido (`sca-sisans-interruptor-encendido.png`). Las capturas están en `/home/ubuntu/convivencia-capturas/`.
- Con CFERNA7 y el interruptor encendido, se verificaron los dos orígenes en una misma póliza, con las etiquetas `SCA` y `SCA2` y fondos `#EBEFF4` y `#DFEEFF`. La fila SCA abrió la tarea legacy `BuscadorSolicitudPrincipal`; la fila SCA2 abrió su detalle dentro de la fachada (`sca-tabla-mixta-cferna7.png`, `sca-detalle-legacy-cferna7.png`, `sca-detalle-sca2-cferna7.png`). No se modificó ninguna solicitud.
- CFERNA7 vio las dos pestañas. En la prueba inicial, Errores quedó en blanco (`sca-errores-cferna7.png`) y Mantenimiento mostró el cuadro de mando (`sca-mantenimiento-cferna7.png`). Tras el ajuste, con el interruptor encendido, la fila SCA mostró «Pendiente» y Errores mostró el aviso sin cuadrícula, sin ampliar permisos ni probar operaciones administrativas (`ajustes-sca-estado-cferna7.png`, `ajustes-sca-errores-cferna7.png`).
- SISANS conservó el buscador legacy y no vio las pestañas SCA2 aunque el interruptor estaba encendido; en el buscador nativo SCA2 no vio el botón de alta (`ajustes-sca-sisans-encendido.png`, `ajustes-sca2-sisans-sin-alta.png`).
- `devin` abrió el popup de alta nativa con el interruptor apagado y vio la cuadrícula nativa de Errores sin el aviso (`ajustes-sca2-alta-devin-apagado.png`, `ajustes-sca2-errores-devin.png`). No se confirmó el alta ni se ejecutaron operaciones administrativas.
- El nodo `Start Alta` de `SCA2 CMD MarcarErrorRelanzado` continúa llamando directamente a `SCA2 CMD Alta`. No se ejecutó un relanzamiento ni se hizo DML directo.

## Comparación de los dos sites de SCA — TEST, 24 de noviembre de 2026

Appian registró más actividad en **`/decidir-accion`**. Fuente: `audit/sites_usage.csv` del nodo `mapfrespain-test-jboss-1`, entre el 26 de octubre a las 18:59 UTC y el 24 de noviembre a las 21:47 UTC. Son eventos de un nodo, no sesiones, usuarios únicos, inicios de proceso ni un recuento de toda la plataforma. No se consultó PRO.

| Evento | `decidir-accion` | `sca-site` |
| --- | ---: | ---: |
| View Site Interface | 471 | 56 |
| View Process Task Form | 437 | 3 |
| Submit Process Task Form | 435 | 0 |

Antes de adaptar `decidir-accion`, ambos sites mostraban un buscador y un botón de alta, pero solo `sca-site/b-squeda` presentaba el buscador SCA2 y las pestañas SCA2 a CFERNA7. En `decidir-accion/decidiraccion`, CFERNA7 veía el buscador SCA de Estratégicas. SISANS veía el recorrido legacy de cada site sin pestañas SCA2. Capturas de partida en `/home/ubuntu/convivencia-capturas/sites-{sca-site,decidir-accion}-{cferna7,sisans}.png`.

La Web API `GET /suite/webapi/decisora` llama a `SCA_DecisoraMain` y `SCA_responseDecisora`. `SCA_crearUriDecisora` construye la URL de `decidir-accion/decidiraccion` para el flujo habitual de Appian, con `entradaDecisora`, `creacionSolicitud`, `revisionSolicitud`, `numPoliza`, `numSolicitud` y los indicadores de error. Una rama de error no Vida apunta a `sca-site/b-squeda`; se conservan las excepciones de GESVIDA. No se ha verificado qué portales lo consumen actualmente.

## Fachada piloto en `/decidir-accion` — publicada en TEST

El piloto se limita **al buscador del site**. `SCA_DecidirAccion` muestra `SCA2_Buscador` solo en la entrada manual con grupo e interruptor activos. El bloque legacy y sus 12 inputs se mantienen para el resto. Decisora y portales quedan fuera: no se cambian la Web API, sus parámetros ni el popup SCA. El site conserva las páginas originales y añade Errores y Mantenimiento de SCA2 con visibilidad piloto y los permisos internos existentes.

| Objeto | Versión MCP antes → publicada |
| --- | --- |
| `SCA Decidir Accion` | 2 → 3 |
| `SCA_DecidirAccion` | 9 → 11 |
| `SCA2_Buscador` | 44 → 45 |
| `SCA2_DetalleSolicitud` | 79 → 80 |
| `SCA2_DetalleTareas` | 46 → 48 |

El contexto `desdeDecidirAccion` llega a las tareas SCA2. Sus retornos cierran la acción o el detalle mediante el estado de la página, sin salir de `/decidir-accion` ni cambiar la configuración de parámetros URL de Decisora. Las ramas de retorno anteriores para `/sca-site` y SCA2 nativo se conservaron.

**Comprobaciones en TEST** (capturas `/home/ubuntu/convivencia-capturas/decidir-*.png`):

- CFERNA7 abrió el popup de alta de SCA2 sin confirmar. Al buscar una póliza de control, vio la tabla con los dos colores y etiquetas: la fila SCA abrió el detalle legacy y la SCA2 se abrió en la misma página. Errores mostró el aviso de permisos; Mantenimiento mostró el cuadro de mando.
- SISANS conservó los mismos controles y columnas que en la línea base y no vio las dos pestañas nuevas. Ambos usuarios conservaron su recorrido en `/sca-site`.
- Para ambos usuarios se comparó antes y después un enlace cifrado de Decisora, generado por `SCA_crearUriDecisora` con un error de control. El contenido del popup y su botón OK se conservaron; no se probó un alta o una revisión real de Decisora.
- `testInterface` evaluó correctamente el buscador legacy, la entrada Decisora y el enlace «Volver al detalle» en `SCA2_DetalleTareas`: usa guardados locales en `decidir-accion` y conserva la URI del site nativo. No se retomó ni modificó una tarea real para pulsar ese retorno. Antes de esta publicación, la misma evaluación forzada para el retorno de `/sca-site` devolvía que su parámetro de URL `idSolicitud` no era válido; esa configuración preexistente no se cambió.

No se tocaron PM, grupos ni permisos. Las copias previas `*.decidir.before-v*.json` están en `~/memory/appian_91b2ca/files/sca2-convivencia-piloto/`. El interruptor se dejó activo (`1`, v16). En esta publicación no se gastaron pólizas; quedaron pendientes el alta real, la concurrencia y la exclusión del batch NSE.

## Reaplicación tras la subida de SCA — TEST, 25 de noviembre de 2026

La subida devolvió ambos sites a sus páginas legacy: quitó las pestañas piloto de Errores y Mantenimiento y devolvió la página principal de `/sca-site` a `SCA_BuscadorSolicitudPrincipal`. El nuevo `SCA_DecidirAccion` conservó el destino de `/decidir-accion`, pero ya no incluía la rama piloto. La subida añadió el input de texto `idSolicitud` y cambió la selección de solicitud: ese input tiene prioridad sobre `numSolicitud` y, si no llegan esos parámetros, se usa la selección local. La cabecera y el detalle legacy usan esa selección.

| Objeto | Piloto anterior | Tras la subida SCA | Tras reaplicar |
| --- | ---: | ---: | ---: |
| `SCA_Site` | 3 | 4 | 5 |
| `SCA Decidir Accion` | 3 | 4 | 5 |
| `SCA_DecidirAccion` | 11 | 12 | 13 |

Se repusieron las dos pestañas piloto en ambos sites y el enlace de `/sca-site` a `SCA_SolicitudesPiloto`. En `SCA_DecidirAccion` se reaplicó la rama piloto sobre la v12 sin sustituir su bloque legacy ni sus 13 inputs. Si llega `idSolicitud`, se conserva el recorrido SCA. La Web API y el popup de Decisora quedaron fuera del cambio. No se cambiaron PM, grupos ni permisos.

Los otros nueve objetos revisados quedaron idénticos: `SCA_SolicitudesPiloto` v2, `SCA2_pilotoHabilitado` v1, `SCA2_BuscadorTablaPiloto` v3, `SCA2_Buscador` v45, `SCA2_AltaSolicitudPage` v60, `SCA2_DetalleSolicitud` v80, `SCA2_DetalleTareas` v48, `SCA2_BandejaErrores` v19 y `SCA2_BOOL_PILOTO_ACTIVO` v16 (activo, `1`). Las copias previas son `*.reaplicar.before-v*.json` en `~/memory/appian_91b2ca/files/sca2-convivencia-piloto/`.

CFERNA7 vio las pestañas piloto y abrió el alta SCA2 en ambos sites sin confirmar; SISANS vio los buscadores legacy sin pestañas SCA2. Ambos vieron el mensaje de control de Decisora y el botón OK. `testInterface` devolvió `ContentLayout` y `error: None` para el buscador sin parámetros y la entrada de error de Decisora. Capturas: `/home/ubuntu/convivencia-capturas/reaplicado-*.png`. No se gastaron pólizas ni se crearon solicitudes; esta restauración no valida el alta real, la concurrencia ni el batch NSE.

## Visibilidad de Errores y Mantenimiento SCA2 — TEST

En `SCA_Site` y `SCA Decidir Accion` (ambos v5 → v6), las pestañas **Errores SCA2** y **Gestión de mantenimiento SCA2** solo se muestran si el interruptor está activo y el usuario pertenece a **SCA2 Piloto** y **SCA2 Administradores**. Se modificaron solo las dos expresiones de visibilidad de cada site. El interruptor quedó intacto (`1`, v16); tampoco se modificaron los grupos, permisos, interfaces de destino ni el site nativo SCA2.

- **Antes:** CFERNA7 (piloto, no administrador) veía las pestañas y al abrir Errores recibía el aviso de permisos en ambos sites. Mantenimiento mostró el cuadro de mando en `/sca-site`; en `/decidir-accion` no se pudo verificar que cargara. Capturas: `/home/ubuntu/convivencia-capturas/visib-antes-*.png`.
- **Después:** CFERNA7 ya no vio las pestañas en ninguno de los dos sites y pudo abrir el alta SCA2 sin confirmarla. SISANS siguió viendo el buscador legacy sin dichas pestañas en ambos. Capturas: `/home/ubuntu/convivencia-capturas/visib-despues-*.png`.
- **Pendiente:** GGALV10 es miembro de ambos grupos en TEST. Falta validar con su sesión que ve ambas pestañas y que las dos páginas abren correctamente.

Copias previas: `SCA_Site.visib.before-v5.json` y `SCA_Decidir_Accion_Site.visib.before-v5.json` en `~/memory/appian_91b2ca/files/sca2-convivencia-piloto/`.
