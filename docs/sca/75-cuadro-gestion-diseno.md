# Cuadro de Gestión — análisis y diseño (sin cambios en Appian)

Petición: documento «Cuadro de Gestión.docx» (23/11). Revisado en Appian TEST sin modificar nada.

## Dónde están los datos

| Dato pedido | ¿Está en SCA2? | Dónde está |
|---|---|---|
| Positivo / negativo de la solicitud | Sí | `SCA2 Solicitud.argumentoPositivo`, `lineaNegocio` |
| Qué argumento se ejecutó, si es económico, resultado | No | CORE: `guardarEjecuArg` (IGestionarArgumentosPCA); marca económica `txt_mca_eco`; fila `ECONOMICO` en `TRON_LD.A2139022_MES` |
| Tréboles asignados / máximo / recomendados | No | Club MAPFRE (`SocioAsignarTreboles.execute`) y `A2139022_MES`; disponibles y recomendados solo en la respuesta de `consultarListadoArgumentos` (`treboles[]`) |
| TTQ, premfide, SVA, retos | No | Servicios `gestionarTTQ`, `AsignarSVA`, etc. |
| Argumentos económicos por cliente y anualidad | No | CORE / Club MAPFRE |

SCA2 no tiene data store a TRON ni a Club MAPFRE (solo `SCA2 DataBase AWS`; la única tabla de argumentos es el catálogo `sca2_cat_tipo_argumento`).

## Servicios disponibles en SCA2

- Dar tréboles: `SCA2_executeAsignarIntegracion` + `SCA2_marcarAsignacionBonificacionIntegracion` (los usa el modal de recuperación).
- TTQ / SVA: `SCA2_gestionarTTQRESTIntegracion`, `SCA2_AsignarSVARestIntegracion`.
- Consulta por solicitud: `SCA2_consultarListadoArgumentosREST` (argumentos y tréboles de **una** solicitud).
- **No hay** servicio para quitar tréboles (webClub), eliminar un cierre positivo (hoy SAU/TI) ni consultar los argumentos de un cliente por anualidad.

## Consecuencias

- **Cuadro de Mando (indicadores)**: ninguno de los 13 indicadores pedidos se puede calcular hoy con datos de SCA2. Hace falta una fuente nueva (ver decisiones).
- **Cuadro de Gestión — errores**: ya existe (Bandeja de errores con relanzar/descartar, R54).
- **Cuadro de Gestión — consultas**: consultar por póliza si tiene el argumento de tréboles y cuántos es posible con `consultarListadoArgumentos` para una solicitud abierta; «ya se le dio», «vigencia pasada» y «marcada como económica pero no se le dio» necesitan datos de CORE.
- **Acciones** (dar/quitar tréboles, eliminar cierre positivo): dar existe; quitar y eliminar requieren servicios backend nuevos y cambian el comportamiento.

## Decisiones

| # | Decisión | Estado |
|---|---|---|
| 1 | Fuente de los indicadores: (a) tabla SCA2 nueva que guarda cada ejecución de argumento al cerrar en positivo o negativo (datos solo desde el despliegue; script DDL como los de `sql/`, ejecutado en el despliegue; una escritura más en el comando de cierre, sin cambio para el gestor) o (b) servicio CORE de agregados sobre TRON (histórico completo, depende de otro equipo). Recomendación: (a). | **Decidido** (usuario, 23/11): opción (a) |
| 2 | «Regateable» | **Decidido** (usuario, 23/11): ver abajo |
| 3 | Acciones que escriben (quitar tréboles, eliminar cierre positivo, dar tréboles fuera del flujo) | **Decidido** (Bot, 23/11): el Cuadro de Gestión empieza solo con consultas; las acciones se harán cuando haya servicio y permisos definidos |

### Regateable (decisión 2)

Respuesta del usuario: «Regateables son argumentos de campañas de comerciales. Hay un marcador en la tabla de argumentarios que indica si es regateable o no el argumento. Lleva el valor S o N.»

- Se descarta la propuesta anterior (tréboles asignados < máximo): regateable es una **propiedad del tipo de argumento**, no del importe asignado.
- El marcador ya está en SCA2: campo `regateable` (S/N) del record `SCA2 Cat Tipo Argumento` (`sca2_cat_tipo_argumento`, columna `REGATEABLE`, clave `codTpArg`; ver [43-C](43-C-catalogos-aurora.md)). No hace falta llamar a CORE para saberlo.
- En TEST (lectura del 23/11): 347 tipos, 187 con `S` y 160 con `N`. Son `S` los de campaña: Tú te quedas (TTQ, todas las variantes), premio de fidelización (PREMFIDE), servicio de valor añadido, regalo de permanencia, retos, Club MAPFRE y producto alternativo. Por tanto TTQ, premfide, SVA y retos se tratan igual: por su marcador. Hay 3 filas de prueba (`999`, `991`) que conviene limpiar antes de calcular indicadores.
- Diseño: los indicadores «regateables / no regateables» cruzan el `codTpArg` de cada argumento ejecutado con `SCA2 Cat Tipo Argumento.regateable`. Lo que sigue faltando es saber qué argumentos se ejecutaron (`codTpArg` por solicitud): eso depende de la decisión 1.

### Opción A: diseño (decisión 1)

1. **Tabla** `sca2_ejecucion_argumento` con una fila por argumento cerrado en positivo o negativo. Script: [sql/77-ejecucion-argumento.sql](sql/77-ejecucion-argumento.sql), probado en PostgreSQL 14 (se puede relanzar); crea la tabla con `SET LOCAL ROLE user_sca2_anulaciones`, como `sca2-hist-ddl.sql`, para que sea del usuario de Appian. Lo ejecuta el usuario con DBeaver, primero en TEST; Devin no lanza DDL.
2. **Record type** `SCA2 Ejecucion Argumento` sobre esa tabla (sincronizado, para poder agregar en los gráficos).
3. **Grabación:** un nodo *Write Records* nuevo en `SCA2 CMD CompletarAccion`, después del cierre (tras `Write PDTE_FINALIZAR`) y solo cuando `resultado.operacion = "CONTRAANULACION"` con un argumento seleccionado. Su fallo no lleva a `Write Error` ni para el proceso: se anota en `SCA2 Error` y el cierre sigue igual. Los datos que faltan en el `resultado` (código, descripción, campaña, económico, tréboles) se añaden como una clave nueva `ejecucionArgumento` en los `a!map` de `SCA2_ContraAnulacionOpciones` que lanzan CompletarAccion. El proceso ignora las claves que no conoce, así que el gestor no ve ningún cambio. `MCA_REGATEABLE` se copia de `SCA2 Cat Tipo Argumento` al cerrar.
4. **Cuadro de Gestión:** pestaña de solo consulta sobre el record, con los filtros del Cuadro de Mando. Muestra positivos y negativos económicos, regateables y no regateables, tréboles por AUTOS, HOGAR y VIDA, barras por tipo y tartas.
5. **Limitación:** solo hay datos desde el despliegue; el histórico anterior sigue en CORE.

### Implementado en TEST (23/11)

El usuario lanzó el script 77 en TEST. Appian escribe en la tabla: se insertó y se borró una fila de prueba con el usuario de Appian.

| Objeto | Cambio |
|---|---|
| Record `SCA2 Ejecucion Argumento` (`22e52e08-b3bd-4770-9905-28b281f5e57b`) | Nuevo, sobre `sca2_ejecucion_argumento` |
| `SCA2_ContraAnulacionOpciones` v82 | Clave nueva `ejecucionArgumento` en los 5 `a!map` de `resultado` con `operacion: "CONTRAANULACION"` ([línea añadida](sail/75-cuadro-gestion/Opciones-clave-ejecucionArgumento.sail)). Ningún otro objeto la lee. |
| `SCA2 CMD CompletarAccion` | Variables `ejArgErr`/`ejArgErrMsg`. Nodos nuevos ([JSON](sail/75-cuadro-gestion/CompletarAccion-nodos-ejecucion-argumento.json)): `¿CA ok?` (OK) → `¿Argumento cerrado?` (finalizadoCA y estadoFinalizar 3 positivo, 2/4 negativo) → `Grabar ejecucion argumento` → `¿Grabacion argumento fallida?` → `Anotar fallo grabacion argumento` (SCA2 Error `EJEC_ARG_FAIL` en estado `DESCARTADO`, que no se puede relanzar) → `¿CA positiva?`. Cancelar (9) y Revisión (6) no graban. El fallo no toca `wrErr`, así que el cierre sigue igual. |
| `SCA2_CuadroMando` v38 | Pestaña 5 «Cuadro de Gestión», de solo consulta. 9 tarjetas (cerrados, positivos, negativos, económicos +/−, tréboles, regateables, no regateables, sin marca), tréboles por línea y por tipo, positivos y tréboles por día, 3 tartas y una cuadrícula por póliza. Fecha = fecha del cierre; el filtro de origen no aplica. |

- La expresión del nodo de grabación se probó con una regla temporal (ya borrada) para positivo, negativo y vacío; `MCA_REGATEABLE` sale del catálogo.
- Una ejecución real del cierre no se probó para no cerrar contra anulaciones en CORE TEST: la primera fila real llegará con el primer cierre.
- v38: `SCA2_INT_ID_LINEA_NEGOCIO` es texto, así que el filtro de línea usa `tointeger` sobre el campo entero.
