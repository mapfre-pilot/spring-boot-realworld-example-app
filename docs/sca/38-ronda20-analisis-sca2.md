# Ronda 20 — Análisis SCA2 del analista (19/10) y cierre de la ronda 19

Fuente: «Analisis SCA2.docx» (19/10). Cambios en SCA2 TEST; la lógica de SCA sigue siendo la referencia.

| # | Punto del analista | Cambio en SCA2 | Objeto / versión |
|---|---|---|---|
| 1 | Alta: la lupa de compañía contraria abre el listado debajo del formulario; debe ser una ventana | Mientras la búsqueda está abierta el formulario se oculta y la tarjeta «Compañías contrarias» queda sola bajo la cabecera (en esta versión de Appian no hay diálogos modales en SAIL; SCA lo resolvía con un formulario de proceso) | `SCA2_AltaSolicitudPage` v34 |
| 2a | CA nivel 2: «Nuuma de usuario» debe ser «-» hasta que alguien retoma; al retomar, guardar el nuuma | La gestión CORE de nivel > 1 nace sin nuuma (como SCA); al RETOMAR se registra quién retoma (`SCA2 Tarea.asignadoA/fechaCaptura`) y el Detalle lo muestra; al POSPONER/FINALIZAR CORE recibe el nuuma del gestor (ya ocurría). **Pendiente analista**: no hay servicio CORE conocido para informar el nuuma en el propio retomar (en BBDD de PRE seguirá vacío hasta posponer/finalizar). | `SCA2_altaGestionCore` v4, `SCA2_DetalleSolicitud` v55 |
| 2b | Tras FINALIZAR negativo en nivel 2 con SI24 + acuerdo no salta a mecanizar | Causa: al motor sólo iba `anulaExperto=true`; ahora también `anulaTecnico=true` (punto 3) | ver 3 |
| 3 | SI24 + acuerdo: `informacionOperacionSCA.anulaTecnico = true` y `anulaExperto = true` | `anulaTecnicosMotor` también true para SI24 gestor + póliza de acuerdos (antes sólo CCC/CCR) | `SCA2_ContraAnulacionOpciones` v53 |
| 4 | Autemis pendiente: al ANULAR PÓLIZA lanzar «bloquear» de NEW antes de ANL | Nodo nuevo «Bloquear póliza en Central (NEW)» en `CMD Mecanizar` entre «Success Mecanización? (wAutemis 00000005/6)» y «Crear Autorización» (`bloquearPolizaEnCentral` de RecubrirNew con póliza, perfil, nuuma, reservaPrima, motivo/detalle/causa, fecha), como el nodo «Bloquear póliza» de `SCA Finalizar Mecanizacion`; resultado en `pv!bloqueoCentral` | `SCA2 CMD Mecanizar` (nodo 340, PV `bloqueoCentral`) |
| 5 | Casos NSE (pólizas 2002600070490…) | Pruebas pendientes (ver §2) | — |

## 2. Pruebas
(se completa con el informe del testing agent: casos A popup, B nuuma/salto a mecanizar, C Autemis + CANCELAR)
