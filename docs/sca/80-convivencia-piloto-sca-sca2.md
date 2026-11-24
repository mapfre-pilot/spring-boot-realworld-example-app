# Convivencia SCA y SCA2 en TEST

La entrada manual sigue siendo `sca-site/b-squeda`. Con `SCA2_BOOL_PILOTO_ACTIVO` encendido, los miembros de `SCA2 Piloto` ven el buscador de SCA2; el resto sigue en `SCA_BuscadorSolicitudPrincipal`. Los enlaces que llegan de Decisora y las entradas legacy explícitas conservan esa misma interfaz. No se cambiaron Decisora, portales ni los procesos de alta y relanzamiento.

El alta nueva en la fachada exige pertenecer al piloto y tener encendido el interruptor. En el site nativo `sca2/buscador`, pueden dar altas los miembros de `SCA2 Piloto` o de `SCA2 Administrators` (`SCA2_GRP_ADMINISTRADORES`), incluso con el interruptor apagado. El site nativo sigue disponible para tramitar. La ACL de `SCA2 CMD Alta` no se modificó; las pruebas abrieron el popup sin confirmar el alta.

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
| `SCA2_BOOL_PILOTO_ACTIVO` | `_a-0000f09c-d8f4-8000-9d41-011c48011c48_5632095` | 5 → 13 → 15; `false` tras las activaciones temporales |

La fachada se creó duplicando la interfaz en Designer para mantener el tipo `mssConsultarSolicitudesDTO` y la metadata de `solicitud`. El MCP de TEST rechazó ese tipo para la creación de la interfaz. El resto de las publicaciones se hizo por MCP.

Las páginas `errores-sca2` y `gestion-mantenimiento-sca2` de SCA se muestran solo en el piloto activo. Apuntan a `SCA2_BandejaErrores` y `SCA2_GestionMantenimientoMenu` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20060073`) sin modificar sus permisos. Errores muestra «No tienes permiso para ver esta página» cuando se abre sin rol administrador y no presenta acciones de relanzar ni descartar. La página nativa de Errores sigue visible solo para administradores. La página de mantenimiento legacy no cambia.

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
- CFERNA7 vio las dos pestañas. En la prueba inicial, Errores quedó en blanco (`sca-errores-cferna7.png`) y Mantenimiento mostró el cuadro de mando (`sca-mantenimiento-cferna7.png`). Tras el ajuste, con el interruptor encendido, la fila SCA mostró «Pendiente» y Errores mostró el aviso sin cuadrícula (`ajustes-sca-estado-cferna7.png`, `ajustes-sca-errores-cferna7.png`).
- SISANS conservó el buscador legacy y no vio las pestañas SCA2 aunque el interruptor estaba encendido; en el buscador nativo SCA2 no vio el botón de alta (`ajustes-sca-sisans-encendido.png`, `ajustes-sca2-sisans-sin-alta.png`).
- `devin` abrió el popup de alta nativa con el interruptor apagado y vio la cuadrícula nativa de Errores sin el aviso (`ajustes-sca2-alta-devin-apagado.png`, `ajustes-sca2-errores-devin.png`). No se confirmó el alta ni se ejecutaron operaciones administrativas.
- El nodo `Start Alta` de `SCA2 CMD MarcarErrorRelanzado` continúa llamando directamente a `SCA2 CMD Alta`. No se ejecutó un relanzamiento ni se hizo DML directo.
