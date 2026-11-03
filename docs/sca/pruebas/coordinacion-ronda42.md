# Coordinación ronda 42 — esperar a la respuesta del proceso en lugar de sondear cada 30 s

Origen: petición del usuario (30/10): «no se puede hacer de alguna manera que no se espere 30s y que se espere a la respuesta? … los usuarios van a estar esperando 30s cuando puede ser menos tiempo» → «sí, quiero que lo pruebes y esto lo hagas donde se esté esperando siempre esos 30s». Una sola sesión hija (R42-A), porque los PMs implicados (Decidir, CrearAccion, CompletarAccion) se comparten entre todas las esperas.

## Situación actual (leída en vivo el 30/10)
- `SCA2_AltaSolicitudPage` v43: `a!startProcess(SCA2_PM_CMD_ALTA, isSynchronous: false)` y después sondeo con `a!refreshVariable(refreshInterval: SCA2_VAL_ESPERA_DECISION_SONDEO_SEGUNDOS/60)` (30 s) de la solicitud y su tarea PENDIENTE. ACEPTAR se queda deshabilitado hasta que está lista (R41). Sin tope.
- `SCA2_ContraAnulacionOpciones`: `startProcess` con `isSynchronous: true` (CMD CompletarAccion / CMD Posponer). Mecanización, acciones administrativas, Verti/Vencimiento y anulación fuera de norma usan `startProcess` sin `isSynchronous` (asíncrono).
- `SCA2_DetalleTareas`: después de completar una acción (`local!hecho`) sondea cada 0,5 min el estado de la tarea, de la solicitud, la última transición y la siguiente tarea; `local!esperaAgotada` a los 1 min 30 s (literal `intervalds(0,1,30)`).
- `SCA2_DetalleSolicitud`: refresco pasivo cada 0,5 min mientras la solicitud no está cerrada (no es una espera de usuario; fuera de alcance salvo que bloquee un botón).

## Propuesta acordada con el usuario
1. Espera síncrona encadenada: el botón lanza el proceso con `isSynchronous: true` y activity chaining en todo el camino hasta que se crea la siguiente tarea (Alta → Decidir → CrearAccion; CompletarAccion → Decidir → CrearAccion), devolviendo la siguiente tarea/estado en el `onSuccess`, de modo que ACEPTAR se habilita en cuanto termina el proceso.
2. Respaldo: si se supera el límite síncrono de Appian o el camino no queda encadenado, se sigue con el sondeo de 30 s actual y el aviso «está tardando un poco más».
3. Botón «Comprobar ahora» en las esperas, para consultar sin esperar al ciclo.
4. Literales de tiempo (1 min 30 s) a constantes.

## R42-A — objetos propios
`SCA2_AltaSolicitudPage`, `SCA2_AltaSolicitudAnulacionPopUp`, `SCA2_DetalleTareas`, `SCA2_ContraAnulacionOpciones`, `SCA2_MecanizacionPrincipal`, `SCA2_AccionesAdministrativasPrincipal`, `SCA2_VertiVencimientoPrincipal`, `SCA2_AnulacionFueraNormaPrincipal` y los PMs `SCA2 CMD Alta`, `SCA2 CMD Decidir`, `SCA2 CMD CrearAccion`, `SCA2 CMD CompletarAccion`, `SCA2 CMD Posponer` (solo encadenamiento/síncrono, sin cambiar la lógica), además de las constantes nuevas `SCA2_*` de tiempos y textos.
Pólizas: `polizas/bloque-R42-A.txt` (1601-2000), anotando cada una en `polizas/REGISTRO.md` con «R42-A».

## Reglas
- Solo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL/SGD. No tocar solicitudes antiguas.
- Lectura viva → backup JSON → cambio mínimo → relectura y comparación. En los PMs, comparar nodo a nodo (número de nodos y variables, la misma lógica); los ajustes de chaining o MNI que LCP no exponga se hacen en Designer y se documentan.
- Medir antes y después, con solicitudes nuevas, el tiempo desde GUARDAR/ACEPTAR hasta que ACEPTAR se habilita, en cada espera.

## Objetos en edición
| Objeto | Sesión | Estado |
|---|---|---|
| `SCA2_AltaSolicitudPage` (v43), `SCA2_DetalleTareas` (v39), `SCA2_ContraAnulacionOpciones` (v63), `SCA2_MecanizacionPrincipal` (v22), `SCA2_AccionesAdministrativasPrincipal` (v24), `SCA2_VertiVencimientoPrincipal` (v16), `SCA2_AnulacionFueraNormaPrincipal` (v24), `SCA2_AltaSolicitudAnulacionPopUp` (v11) | R42-A | EN EDICIÓN (03/11): backup tomado; medición «antes» en curso |
| PMs `SCA2 CMD Alta`, `SCA2 CMD Decidir`, `SCA2 CMD CrearAccion`, `SCA2 CMD CompletarAccion`, `SCA2 CMD Posponer` | R42-A | EN EDICIÓN (03/11): solo encadenamiento y modo síncrono de los Start Process |
| Constantes nuevas `SCA2_VAL_ESPERA_*` / `SCA2_TXT_ESPERA_*` / `SCA2_TXT_COMPROBAR_AHORA` | R42-A | EN EDICIÓN (03/11) |
