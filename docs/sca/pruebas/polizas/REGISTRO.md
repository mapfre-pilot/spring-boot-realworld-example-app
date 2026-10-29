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
