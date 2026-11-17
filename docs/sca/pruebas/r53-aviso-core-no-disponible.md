# R53 — SCA2: aviso claro cuando CORE no responde (Appian TEST)

Fecha: 17/11/2026. Entorno: Appian TEST (`mapfrespain-test`). Solo objetos SCA2. Sin SQL. Sin cambios en PM ni en integraciones.

## Causa
Con CORE7 (`core7.pre.mapfre.net:26007`) caído, las integraciones devuelven `success:false` y `result.body = null`. Las reglas que hacen `xpathsnippet(body, ...)` revientan con `contextNode is null` y el site muestra «Error al evaluar la expresión de interfaz de usuario». La primera que falla es `SCA2_obtenerRolPerfilSubperfil` (roles), así que el site no cargaba para nadie.

## Diseño
- Constante `SCA2_TXT_CORE_NO_DISPONIBLE` = «El servicio de CORE no está disponible en este momento. Inténtelo más tarde.» (no existía un texto parecido en SCA2).
- `SCA2_valorCoreNoDisponible()` devuelve el centinela `a!map(coreNoDisponible: true, mensaje: cons!SCA2_TXT_CORE_NO_DISPONIBLE)`.
- `SCA2_esCoreNoDisponible(valor)` devuelve `true` solo para ese centinela (probado con null, texto, número, listas, CDT y otros mapas → `false`).
- `SCA2_AvisoCoreNoDisponible(mensaje)` es la tarjeta `WARN` con el aviso.
- Reglas que llaman a CORE: solo se protege el camino `body` nulo:
  `if(a!isNullOrEmpty(local!tmp), rule!SCA2_valorCoreNoDisponible(), <lógica actual sin tocar>)`.
- Interfaces: si detectan el centinela muestran el aviso; si no, la interfaz original sin tocar.

## Objetos cambiados

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| SCA2_TXT_CORE_NO_DISPONIBLE (constante) | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5751622` | nuevo → v1 | Texto del aviso |
| SCA2_valorCoreNoDisponible (regla) | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5751628` | nuevo → v1 | Centinela |
| SCA2_esCoreNoDisponible (regla) | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5751634` | nuevo → v1 | Detector |
| SCA2_AvisoCoreNoDisponible (interfaz) | `_a-0000f0b4-5b71-8000-9d56-011c48011c48_5751640` | nuevo → v1 | Tarjeta de aviso |
| SCA2_obtenerRolPerfilSubperfil | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050948` | v1 → v2 | Guarda body nulo |
| SCA2_consultarSolicitudes | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050936` | v1 → v2 | Guarda body nulo |
| SCA2_consultarCabeceraSolicitud | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20051080` | v1 → v2 | Guarda body nulo |
| SCA2_BuscadorTabla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | v18 → v20 | Aviso si roles = centinela (v19 llamaba al aviso sin `mensaje`; corregido en v20) |
| SCA2_AltaSolicitudAnulacionPopUp | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064994` | v12 → v14 | Aviso + CANCELAR si roles o solicitudes de la póliza = centinela |
| SCA2_DetalleSolicitud | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | v76 → v77 | Aviso si roles o cabecera = centinela |
| SCA2_Buscador | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055660` | v39 (sin cambios) | No hizo falta |

Copias previas: `backups-r53/*.sail`. Diffs (`diff -u -w`): `backups-r53/diffs/`. Objetos nuevos: `backups-r53/nuevos/`. Coordinación: `coordinacion-ronda53.md` (todo liberado).

## Camino de error: antes / después (CORE caído)

| Pantalla | Antes | Después |
|---|---|---|
| Carga del site (JJGONZ2, SISANS) | «Error al evaluar la expresión…» en `sca2_obtenerrolperfilsubperfil` (`xpathsnippet`, línea 17) | Carga el buscador; la tabla «Últimas solicitudes gestionadas» muestra el aviso |
| Buscador por póliza | No se llegaba (site caído) | Sin error: mensaje existente «La póliza no es una póliza válida o no se encuentra disponible…» (`SCA2_pObtenerPolizaFecha` ya devolvía vacío sin body) y aviso en la tabla |
| Alta (popup tras introducir póliza) | `sca2_comprobacionespreviaswm` → error (`wherecontains` / `xpathsnippet` en `sca2_consultaraccesostudpormodo`) | Aviso + botón CANCELAR |
| Detalle / cabecera | `sca2_consultarpolizavidariesgo` (`a!fromJson` nulo) vía `sca2_obtenerdatoscabecera` | Aviso (testInterface, `idSolicitud` 15788677: sin error) |
| `testRule` roles / solicitudes / cabecera | Error `contextNode is null` | Centinela, `error: null` |

El Detalle no se puede abrir desde el site con CORE caído (la tabla de solicitudes muestra el aviso y la URL con `idSolicitud` sin `$sp` no abre el Detalle), por eso se probó con `testInterface`.

## Camino normal (CORE responde)
- En las reglas, la lógica original queda íntegra en la rama `else` (ver diffs: solo se añade el `if` exterior). Con body no vacío el resultado es el mismo expresión a expresión.
- En las interfaces, si no hay centinela se evalúa la interfaz original sin cambios. Coste añadido: el popup de alta y el Detalle hacen una llamada extra de detección (roles + `consultarSolicitudes`/`consultarCabeceraSolicitud`) cuando hay póliza/solicitud. No cambia validaciones, textos, estados ni navegación.
- **Pendiente** comparar con `testRule` antes/después con las mismas entradas cuando CORE vuelva (ver «Reintentos»).

## Procesos (decisión a revisar)
No se ha tocado ningún PM. Dos PM usan reglas protegidas en expresiones de nodo que ya tenían respaldo:
- `SCA2 CMD Alta` (`0000f06f-28fc-8000-6693-7f0000014e7a`): `fecsolicitudanul` usa `consultarSolicitudes` con respaldo `now()`.
- `SCA2 CMD Mecanizar` (`0000f06f-4cfc-8000-66d3-7f0000014e7a`): `fechaAnulacion` usa `consultarCabeceraSolicitud` con respaldo al dato de BBDD.

Antes, con body nulo, esas expresiones lanzaban excepción de nodo; ahora usan su respaldo y el proceso sigue. El resto de pasos que llaman a CORE en esos PM conservan su gestión actual (SCA2 Error / reintento). Si se prefiere que esos dos campos sigan provocando el error, hay que añadir en el PM la comprobación `rule!SCA2_esCoreNoDisponible(...)` (no se ha hecho: los PM están fuera de alcance).

## Pruebas con CORE caído (17/11/2026, desde 10:20 CET)
Usuarios funcionales JJGONZ2 y SISANS (SSO NO PRO). No se ha creado ni modificado ninguna solicitud.

| Prueba | Resultado | Captura |
|---|---|---|
| Site antes (JJGONZ2) | Error técnico | `capturas-r53/antes-site-jjgonz2.png` |
| Site después (JJGONZ2) | Aviso, sin error | `capturas-r53/despues-site-jjgonz2.png` |
| Site después (SISANS) | Aviso, sin error | `capturas-r53/despues-site-sisans.png` |
| Buscador por póliza 0730080003210 | Sin error; mensaje de póliza + aviso | `capturas-r53/despues-buscador-poliza.png` |
| Alta: pantalla inicial | Sin error | `capturas-r53/despues-alta-1.png` |
| Alta con póliza (JJGONZ2) | Aviso + CANCELAR | `capturas-r53/despues-alta-poliza.png` |
| Alta con póliza (SISANS) | Aviso + CANCELAR | `capturas-r53/despues-alta-poliza-sisans.png` |
| testInterface Detalle (15788677), popup alta, Buscador, BuscadorTabla | `error: null` | — |

## Reintentos de CORE
Ver tabla al final (cada 20 min, máx. 3 h).

## Pendientes
- Regresión con CORE disponible (alta, buscador, Detalle/cabecera, POSPONER, RETOMAR, contra anulación positiva y negativa, Acción Administrativa) con solicitudes nuevas, y comparación `testRule` antes/después.
- Revisar SCA2 Error y procesos fallidos tras la regresión.
- Otras reglas SCA2 con el mismo patrón (`SCA2_consultaGestion`, `SCA2_consultarDetalleSolicitud`, `SCA2_consultarPolizaVidaRiesgo`, `SCA2_consultaraccesostudpormodo`, …) no se han tocado: con CORE caído quedan detrás del aviso de roles/cabecera. Inventario en `backups-r53/inventario-xpathsnippet-dependientes.txt` (59 reglas con `xpathsnippet` y sus dependientes).
- Si los roles responden pero CORE7 no, el site carga y el buscador no avisa (solo el popup de alta y el Detalle tienen detección propia).

### Tabla de reintentos (hora UTC; sonda `testRule` de roles y `consultarSolicitudes`)

| Hora UTC | Roles | consultarSolicitudes |
|---|---|---|
| 09:30 | CAÍDO | CAÍDO |
| 09:48 | CAÍDO | CAÍDO |
