# Registro de pólizas de prueba (CSV del analista, 29/10/2026)

Fuente: `polizasDevin-2026-10-30.txt.gz` (970.823 pólizas: 554.707 Hogar `073…`, 390.327 Autos `200…`, resto otros). Las pólizas **se comparten con otras sesiones**, así que cada sesión usa SOLO su bloque y anota aquí cada póliza que usa, aunque la prueba falle.

| Bloque | Fichero | Sesión | Estado |
|---|---|---|---|
| 1-400 | `bloque-R35-A.txt` | R35-A (espera decisión / solicitud en curso) | asignado 29/10 |
| 401-800 | `bloque-R35-B.txt` | R35-B (documentos imagen / observaciones tréboles) | asignado 29/10 |
| 801-1200 | `bloque-reserva-1.txt` | libre | — |

Reglas: empezar por la primera póliza libre del bloque; no usar pólizas de otro bloque ni las de rondas anteriores (`polizas-ronda9.md`, `polizas-ronda10.md`); una póliza con solicitud abierta queda «ocupada» hasta que se finalice; anotar también las que no sirven (error de alta, sin tarea, etc.).

## Pólizas usadas

| Póliza | Sesión | Fecha | Solicitud(es) | Uso / estado final |
|---|---|---|---|---|
| 0732400126663 | analista | 28/10 | — | Hogar, caso del punto 1 de la ronda 35 (no usar) |
| 2002600052346 | R35-A QA UI | 29/10 11:28 UTC | 15788534 (ajena, no abierta) | Ocupada en UI: Solicitud Pendiente, creación 29/10 12:21:33 UI. Excluida sin abrir/modificar. |
| 2002600074045 | R35-A QA UI | 29/10 11:28–11:34 UTC | 15788537 | Libre en búsqueda UI antes de alta. Creada 12:30:44 UI; aviso adicional y ACEPTAR→CA. Popup detecta en curso, consulta sin acción y RETOMAR→CA propia. Pendiente, no se ejecutan argumentos. |
| 0730080016454 | R35-A QA UI | 29/10 11:35–11:41 UTC | 15788542 | Libre en búsqueda UI; dos formularios antes de crear. Creada 12:37:43 UI; espera adicional sin GUARDAR, ACEPTAR→CA. GUARDAR en pestaña paralela detecta solicitud en curso; consulta y RETOMAR→CA propia (~80 s). Búsqueda final una sola solicitud. Incidencia secundaria: tras RETOMAR la CA no muestra argumentos (antes ocho); no se recarga ni ejecuta ninguno. Pendiente. |
| 2002600042670 | R35-A QA UI | 29/10 11:41–11:45 UTC | 15788545 | Libre en búsqueda UI antes de alta. GUARDAR ~11:43:08 UTC, confirmación ~11:43:50 UTC; creada 12:43:54 UI. Aviso adicional sin formulario/GUARDAR; ACEPTAR→CA propia (nueve argumentos sin ejecutar)→detalle. Pendiente, CA Incompleta al volver. Bandeja errores bloqueada: página inexistente o sin permiso para JJGONZ2; ausencia de errores no verificada. Última póliza utilizada. |
| 2002600009091 | R35-B QA UI | 29/10 | 15788539 | Alta nueva TEST SCA2. Documentación: rechazo TXT no-DNI y DNI con sus mensajes; JPG aceptado y visible, modificación a PNG y PDF DNI visibles; referencias SGD no vacías (PNG 0900ab4481a119d3, DNI PDF 0900ab4481a117dd). Pendiente/ocupada; no se aplicó TTQ. Responsable confirma 0 errores de esta solicitud mediante lectura LCP. |
| 2002400308796 | R35-B QA UI | 29/10 | 15788544 | Alta nueva Autos candidata TTQ; sin TU TE QUEDAS en CA. Tras argumento obligatorio negativo y RECARGAR, carga de ~65 s dejó tabla vacía antes del cambio de timeout a 300 s; incidencia comunicada y corregida por responsable. Pendiente/ocupada. No se aplicaron tréboles; 0 errores de esta solicitud en lectura LCP del responsable. |
| 0731280228213 | R35-B QA UI | 29/10 | 15788546 | Alta nueva Hogar; sin TU TE QUEDAS en CA. Regresión con argumento no-TTQ positivo y cierre; PDF no-DNI persistido en SGD 0900ab4481a119da y visible con el ojo. Estado final confirmado al reabrir: Finalizada Positiva (antes hubo discrepancia transitoria buscador/detalle). 0 errores de esta solicitud en lectura LCP del responsable. |
| 0731280331168 | R35-B QA UI | 29/10 | 15788547 | Alta nueva Hogar tras visores v3 y timeout 300 s. Sin TU TE QUEDAS en CA. POSPONER→detalle→RETOMAR y una RECARGAR conservan 7 argumentos; RETOMAR <10 s y RECARGAR <35 s (no cubre respuesta >60 s). PDF oposición, JPG y DNI PNG centrados y CONTINUAR operativo; referencias SGD 0900ab4481a11884 y 0900ab4481a11886. Pendiente/ocupada. 0 errores de esta solicitud en lectura LCP del responsable. |
| 2002300094099 | R35-B QA UI | 29/10 | — (alta no completada; búsqueda posterior sin resultados) | Candidato Autos adicional. GUARDAR de alta nueva bloqueado por NSE tras ~100 s: «NSE nos indica una excepción que impide avanzar con su solicitud… Mensaje de NSE: No hay detalles disponibles». No se reintentó, no se llegó a CA ni se aplicó TTQ. Captura r35b-autos-adicional-alta-bloqueada-nse.png. |
