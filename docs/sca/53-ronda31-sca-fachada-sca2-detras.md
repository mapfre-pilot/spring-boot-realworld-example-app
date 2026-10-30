# 53. Ronda 31 (c) — SCA como fachada: lo viejo muere en SCA, lo nuevo va por SCA2 sin que los integradores lo noten

Análisis de sólo lectura (TEST, 26-10-2026). Responde a: «si se pueden tocar objetos de SCA para que el cambio sea mínimo, el site tiene que ser el de SCA y poner lo de SCA2 en sitios clave». Sustituye la fase 1/2 del doc 52 (que proponía redirigir al site SCA2); el doc 51 (grupos) sigue vigente, con la simplificación de que **los grupos no hay que moverlos** mientras SCA sea la fachada.

## 1. Idea

- Hacia fuera **no cambia nada**: misma Web API `decisora` (misma URL, parámetros y respuesta), mismo site `SCA_Site` / `SCA Decidir Accion`, mismos grupos, mismos correos. PCA/portal, favoritos y enlaces siguen funcionando.
- Dentro de SCA se añade **una única regla de decisión** y se usa en los **4 puntos donde SCA elige qué pintar o qué proceso arrancar**. Cuando la regla dice «SCA2», la página de SCA **pinta las interfaces de SCA2** (`SCA2_AltaSolicitudPage`, `SCA2_DetalleSolicitud`) en lugar de las suyas; los comandos `SCA2 CMD *` se arrancan desde ahí igual que hoy desde el site SCA2. Cuando dice «SCA», todo sigue como ahora.
- Las solicitudes nacidas en SCA se terminan en SCA (tareas Appian vivas, caducidad, batches); al no crearse nuevas, SCA «muere» solo. Las nacidas en SCA2 se reconocen siempre por existir en el record `SCA2 Solicitud`.

Esto es posible porque SCA y SCA2 están en el mismo entorno Appian, comparten CORE como fuente de verdad (el buscador de ambas lee `consultarSolicitudes`), comparten grupos/perfiles (doc 51) y connected systems (SCAC), y las interfaces de SCA2 son reglas invocables desde cualquier interfaz (`rule!SCA2_…`) si el usuario tiene permiso de viewer.

## 2. La regla de decisión (nueva, en SCA)

`SCA_vaPorSCA2(numPoliza, idSolicitud, nuuma)` →

1. **Ya es de SCA2**: existe fila en `SCA2 Solicitud` para `idSolicitud` (o para la póliza con estado no final). → `SCA2` siempre, aunque la oleada esté apagada (así lo creado en SCA2 nunca se queda sin pantalla).
2. **Ya es de SCA**: hay tarea Appian viva (`SCA_obtenerTareasSolicitudAlta`) o fila en `SCA solicitudAnulacion` no finalizada para la póliza. → `SCA`.
3. **Nueva**: `SCA2` si `cons!SCA_BOOL_SCA2_ACTIVO` y el gestor está en la **oleada SCA2** (`SCA_esOleadaDecisora` reutilizada con conceptos funcionales nuevos `subprocesoAppian{DGT,DT,OD,OC,Nuumas}SCA2` + grupo `SCA Acceso SCA2`); si no, `SCA`.

Interruptores: la constante (kill-switch global) y los conceptos funcionales / grupo (reparto progresivo por DGT, DT, oficina o NUUMA, igual que hizo SCA en su despliegue). Vaciar la oleada = todo lo nuevo vuelve a SCA; lo ya creado en SCA2 sigue viéndose por el punto 1.

## 3. Puntos clave de SCA donde se inserta SCA2

| # | Punto de SCA (objeto) | Qué hace hoy | Qué se cambia |
|---|---|---|---|
| P1 | Web API `SCA Decisora` → `SCA_DecisoraMain` / `SCA_crearUriDecisora` | Valida y devuelve la URL del site SCA (`decidiraccion?entradaDecisora&creacionSolicitud&revisionSolicitud&numPoliza&numSolicitud…`) | **Sin cambio de contrato**. Opcional: cuando `SCA_vaPorSCA2 = SCA2`, saltarse las validaciones de pantalla de SCA (las hace `SCA2_AltaSolicitudPage`) y devolver la misma URL con `creacionSolicitud=true`. Las derivaciones Vida→GESVIDA y los errores de parámetros se mantienen. |
| P2 | Página `decidiraccion` → interfaz `SCA_DecidirAccion` | Según `entradaDecisora/creacionSolicitud/revisionSolicitud` e `interfazActiva` (record SCA) pinta pop-up Decisora, alta, detalle, CA/AA/mecanización | Al inicio `local!motor: rule!SCA_vaPorSCA2(ri!numPoliza, ri!numSolicitud, nuuma)`. Si `SCA2`: `creacionSolicitud` → `rule!SCA2_AltaSolicitudPage(numPoliza: ri!numPoliza, vista: "ALTA")`; `revisionSolicitud` o solicitud existente → `rule!SCA2_DetalleSolicitud(idSolicitud: …)` (incluye tareas SCA2 con RETOMAR y las acciones CA/AA/mecanizar). Si `SCA`: el `if` actual sin tocar. |
| P3 | Página `b-squeda` → `SCA_BuscadorSolicitudPrincipal(Estrategicas)` + `SCA_BuscadorTabla(Estrategicas)` | Lista de CORE (ya incluye las solicitudes de SCA2); clic en nº solicitud → `a!startProcessLink(SCA_PM_REDIRIGIRDETALLE)` → tarea con el detalle SCA; botón ALTA → `SCA_AltaSolicitudAnulacionPopUp*` | En la fila: si `SCA_esSolicitudSCA2(idSolicitud)` → mostrar `rule!SCA2_DetalleSolicitud(idSolicitud)` (en la misma página, p. ej. con una variable `local!idSolicitudSCA2`) en vez de arrancar `SCA Redirigir Detalle`; si no, igual que hoy. En ALTA: si `SCA_vaPorSCA2(poliza) = SCA2` → `rule!SCA2_AltaSolicitudPage(numPoliza, vista: "ALTA")`; si no, pop-up actual. |
| P4 | Pop-ups de alta de SCA (`SCA_PopUpDecisora(Estrategicas)`, `SCA_AltaSolicitudAnulacionPopUp(Estrategicas)`, `SCA_GenerarSolicitudPopupEstrategicas`) | Arrancan `SCA_PM_ALTA_SOLICITUD_ANULACION_*` / `SCA_PM_ALTA_CONTRA_ANULACION` | Guardia: sólo se llega a ellos cuando `motor = SCA` (P2/P3 ya han bifurcado antes). No hace falta tocarlos; como red de seguridad, `showWhen: motor = "SCA"`. |
| P5 | Página «Gestiones mantenimiento» (`SCA_GestionMantenimientoMenu`) | Mantenimiento de argumentos/conceptos sobre el **mismo backend** que usa SCA2 | Sin cambio funcional. Opcional: pintar `rule!SCA2_GestionMantenimiento…` detrás de la misma página cuando se quiera retirar el código SCA. |
| P6 | Tareas Appian de SCA (`a!processTaskLink`) | Abren la tarea del PM SCA | Sin cambio: sólo existen para solicitudes SCA. Las de SCA2 son records y ya se gestionan dentro de `SCA2_DetalleSolicitud`. |

### Ajustes en SCA2 para poder vivir dentro del site SCA

- `SCA2_DatosCabecera` y `SCA2_DetalleTareas` tienen 2 enlaces `a!urlForSite(... SCA2 Anulaciones.buscador ...)` («volver al detalle», aceptar). Deben resolverse por una regla `SCA2_urlDetalle(idSolicitud)` que devuelva la URL del **site SCA** (`SCA_Site.b-squeda?numSolicitud=…` o `decidiraccion?revisionSolicitud=true&numSolicitud=…`) según una constante `SCA2_SITE_HOST` («SCA» mientras sea fachada). El resto de la navegación de SCA2 es por rule inputs/locales (`vista`, `idSolicitud`), así que funciona embebida.
- Los `a!startProcessLink` de SCA2 (p. ej. `CMD Mecanizar` con el CMP encadenado, R28) vuelven al terminar a la página desde la que se lanzaron: al estar en el site SCA, vuelven al site SCA. Hay que verificarlo en TEST con una solicitud nueva (es el único punto con riesgo de «salto» al site SCA2).
- Página `decidiraccion` de SCA debe aceptar los parámetros que SCA2 necesita (`numPoliza`, `numSolicitud` ya existen; `tipoAccion`/`idTarea` se pueden derivar dentro de `SCA2_DetalleSolicitud`).
- Seguridad: añadir `SCA Usuarios` como miembro de `SCA2 Users` (viewer de interfaces/reglas/records SCA2 y permiso para iniciar los `SCA2 CMD *`), `SCA Administradores`/`SCA Alertas` en `SCA2 Administrators`/`SCA2 Alertas` (doc 51 C1–C3). Con SCA como fachada **no hace falta mover los grupos** `SCA_CE_*` (resuelve D1 del doc 51).
- El site `SCA2 Anulaciones` queda como site técnico (administradores: bandeja de errores, pruebas) hasta que se decida retirarlo.

## 4. Cómo muere lo viejo

1. Oleada SCA2 al 0 %: nada cambia (sólo las solicitudes que ya existan en `SCA2 Solicitud` se ven con pantallas SCA2 desde el site SCA).
2. Oleada por DGT/DT/oficina → las altas nuevas de esos gestores nacen en SCA2 dentro del site SCA; sus solicitudes viejas se terminan en SCA (misma pantalla, misma lista).
3. Oleada al 100 % → SCA ya no crea solicitudes. Quedan vivas las tareas Appian de SCA hasta que el batch de caducidad / los gestores las cierren; se puede fijar fecha límite.
4. Sin tareas vivas en SCA: desactivar batches y Web APIs de SCA (`ejecutarRsvPrima`, `volcadoReservaPrima`, `eliminarTareas*`), archivar los PMs SCA. **Se conservan** en la app SCA: Web API `decisora` (delegando ya al 100 % en SCA2), sites, grupos, constantes de grupo, `SCA_DecidirAccion` y buscador (ahora finos envoltorios de SCA2) y las reglas de perfil. Opcional posterior: renombrar/limpiar, nunca necesario para los integradores.

## 5. Objetos a tocar (estimación)

| App | Objeto | Tipo de cambio |
|---|---|---|
| SCA | `SCA_vaPorSCA2`, `SCA_esSolicitudSCA2` (nuevas reglas), `SCA_BOOL_SCA2_ACTIVO` (constante), grupo `SCA Acceso SCA2`, conceptos funcionales `subprocesoAppian*SCA2` (datos) | Nuevos, sin impacto hasta activarlos |
| SCA | `SCA_DecidirAccion` | 1 `local!` + 1 `if` que envuelve el bloque actual |
| SCA | `SCA_BuscadorSolicitudPrincipalEstrategicas`, `SCA_BuscadorTabla(Estrategicas)` | enlace de fila y botón ALTA condicionados |
| SCA | `SCA_crearUriDecisora` (opcional) | saltar validaciones SCA cuando `motor = SCA2` |
| SCA2 | `SCA2_DatosCabecera`, `SCA2_DetalleTareas` (+ regla `SCA2_urlDetalle`, constante `SCA2_SITE_HOST`) | URLs de retorno parametrizadas |
| SCA2 | grupos `SCA2 Users/Administrators/Alertas` | anidar los de SCA |

Lo que **no** se toca: PMs de SCA, PMs/CMD de SCA2, Web API `decisora` (contrato), SCAC, CORE, integradores externos.

## 6. Riesgos y comprobaciones previas

- **Formularios de tarea**: `SCA Redirigir Detalle` muestra el buscador como *User Input Task*; si el detalle SCA2 se pinta dentro de una tarea de SCA, hay que verificar que `a!startProcess` en `saveInto` y `a!startProcessLink` de SCA2 funcionan ahí (en principio sí; preferible pintar SCA2 en la página del site, no dentro de la tarea).
- **Retorno tras `a!startProcessLink`** de SCA2 (CMP encadenado) al site SCA: verificar.
- **Doble lectura de CORE** en la misma página (SCA + SCA2) → medir tiempos; la regla `SCA_vaPorSCA2` debe evaluarse una vez (`a!refreshVariable` sin `refreshAlways`).
- **Estilos**: dos cabeceras distintas (SCA vs SCA2) en el mismo site durante la convivencia; aceptable o unificar la cabecera de SCA2 con la de SCA.
- **Mediadores / Vida**: la Decisora devuelve `null` para clase de agente 31 y GESVIDA para Vida: se mantiene igual.
- **Solicitud abierta en ambas**: imposible por construcción (puntos 1 y 2 de la regla antes que la oleada; SCA2 ya bloquea el alta si CORE tiene solicitud abierta).

## 7. Dudas para analistas

1. ¿Oleada por DGT/DT/oficina/NUUMA (como la Decisora) o por otro criterio (ramo, tipo de póliza)?
2. ¿Fecha límite para cerrar las tareas vivas de SCA tras el 100 %?
3. ¿Se acepta la convivencia visual (cabeceras distintas) o se unifica antes?
4. ¿La bandeja de errores y el mantenimiento de SCA2 se exponen también dentro del site SCA (sólo administradores)?
