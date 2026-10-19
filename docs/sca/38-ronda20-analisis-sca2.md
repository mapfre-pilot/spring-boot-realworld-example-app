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

## 2. Pruebas (19/10 tarde, testing agent, JJGONZ2/SISANS/devin; vídeo `sca2-r20-v35-bc-edited.mp4`)

| Caso | Resultado |
|---|---|
| A. Compañías contrarias como ventana | **PASA** con 2002600073360 (sin guardar): la lupa oculta el formulario y deja sola la tarjeta; seleccionar devuelve el formulario con la compañía; la X conserva el valor. Hallazgo corregido de paso: CANCELAR del alta no limpiaba la compañía elegida y aparecía en el siguiente alta (`SCA2_AltaSolicitudPage` v35). 2002600070459 (la del analista) ya tiene solicitud abierta. |
| B. Nuuma «-» en nivel 2 / RETOMAR / SI24 finalizar negativo → mecanizar | **NO PROBADO**: 15788107 / 0001047017147 (acuerdos) fue tras la CA negativa directamente a Mecanización (nivel 00000004), sin nivel 2; 7101/7111/7113/7136/7137/7146 «póliza no válida o no disponible» en CORE; la CA nivel 2 de 15788105 está asignada a Oficina (no SI24). Hace falta una póliza nueva cuyo motor derive a SI24 nivel 2 (como 0002729291207 del analista, ya con solicitud). Los cambios están verificados por relectura/renderizado, no en pantalla. |
| C. Autemis pendiente: bloqueo NEW + CANCELAR | **NO PROBADO**: ninguna póliza wAutemis libre con A EFECTO anterior a hoy (7148/7150/7156 fechas de 2027, 7011 sólo A VENCIMIENTO, 7007 con solicitud SCA). El nodo nuevo está en el PM (relectura OK) pero no se ha ejecutado; CANCELAR de mantenimiento sigue sin ejecutar. |
| Ronda 19 (misma tarde) | AUTORIZAR 15788103 y RECHAZAR 15788105 **PASAN** de extremo a extremo (ver doc 37 §5). |

## 3. Pendiente / para el analista
1. Datos: pólizas wAutemis de acuerdos que deriven a SI24 nivel 2 (B) y pólizas wAutemis con anulación «a efecto» retroactiva sin solicitud (C). Las pólizas 000104701xxxx restantes tienen efecto en 2027 (Emisión devuelve 00000004, no pendiente de autorizar).
2. Nuuma al retomar: SCA2 lo registra en su tarea y lo muestra; **no se escribe en CORE hasta posponer/finalizar** (no hay servicio CORE conocido para «retomar»). Confirmar si basta o indicar el servicio.
3. Casos NSE del punto 5 (recién emitidas, a futuro, renovadas): sin empezar.
4. El resultado de «Bloquear póliza en Central» se guarda en `pv!bloqueoCentral` y no corta el flujo (como SCA); si NEW falla en PRE la anulación seguirá por ANL igual.
