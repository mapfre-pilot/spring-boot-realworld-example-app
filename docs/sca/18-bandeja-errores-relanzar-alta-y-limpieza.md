# 18 · Bandeja de errores SCA2 — relanzar Alta y propuesta de limpieza de datos (06/10/2026)

## 1. Error reportado

Al pulsar **Relanzar** sobre un error `SCA2 CMD Alta` en `/errores`:

```
Expression evaluation error [...] in rule 'sca2_bandejaerrores': An error occurred while executing a save:
Attempted to run a second smart service, but only one smart service can be run per expression evaluation
```

**Causa (fallo de la v9, no de datos antiguos):** la rama Alta del botón devolvía dos smart services en el mismo `saveInto`:
`a!startProcess(cons!SCA2_PM_CMD_ALTA, ...)` y `rule!SCA2_relanzarError(...)` (que arranca otro proceso para marcar el error).
Appian ejecutó el primero (el alta se relanzó y volvió a fallar: error 65) y abortó en el segundo, por lo que el error original no quedaba marcado.

## 2. Corrección

Un único punto de entrada para todos los relanzamientos: el PM `SCA2 CMD MarcarErrorRelanzado` (`0000f073-49f2-8000-d0e7-7f0000014e7a`).

| Objeto | Cambio |
|---|---|
| PM `SCA2_CMD_MarcarErrorRelanzado` | Nodo nuevo 16 «Start Alta» (`cons!SCA2_PM_CMD_ALTA`, parámetros `=pv!params`, asíncrono) → End. XOR 4: condición `comandoBase = "SCA2 CMD Alta"` → nodo 16. Nodo 20: `pv!params` pasa a `a!match` — CompletarAccion como antes; Alta = `rule!SCA2_parametrosRelanzarAlta(error: a!queryRecordByIdentifier(SCA2 Error, pv!idError, {id, idSolicitud, payload}))`. Resto de nodos (1,2,3,10–15) idénticos al backup. |
| `SCA2_BandejaErrores` v9 → v10 | La rama Alta desaparece: todos los comandos relanzables (incluida Alta con payload) llaman solo a `a!startProcess(cons!SCA2_PM_CMD_MARCAR_ERROR_RELANZADO, {idError, idSolicitud, comando}, isSynchronous: true)`. |
| `SCA2_DetalleErrores` v3 → v4 | Regenerado con la misma lógica (sección «Errores» del Detalle de solicitud). |

Flujo resultante: marca el error RELANZADO (nodo 3) → calcula comando base y parámetros (nodo 20) → XOR → arranca el CMD correspondiente. Si el CMD vuelve a fallar, registra un error **nuevo** (el original queda RELANZADO).

## 3. Verificación

- `validateExpression` de la interfaz: sin errores. `updateInterface` Bandeja v10 y Detalle v4; readback idéntico byte a byte al payload.
- `testInterface`: Bandeja sin filtros, Detalle con `idSolicitud=15787744` y Detalle sin solicitud → sin errores.
- `testProcessModel` del PM con `idError=65`, `comando="SCA2 CMD Alta"` (proceso 11062523, COMPLETED): `pv!params` reconstruido completo desde el payload (póliza 2002300361370, contexto, catalogación, fechas…); error 65 → RELANZADO por `devin`; el Alta se ejecutó y CORE la rechazó con «Solicitud de anulacion ya existente para el numero de poliza», que quedó como error nuevo 66 PENDIENTE. Es el comportamiento esperado: la póliza ya tiene una solicitud abierta.
- Anexos: `anexos/bandeja-errores/SCA2_BandejaErrores_v10.sail`, `diff_BandejaErrores_v9_v10.diff`, `PM_MarcarErrorRelanzado_cambios_v10.json`.

## 4. Inventario de datos SCA2 en TEST (06/10/2026 17:10 UTC)

Todos los registros son de pruebas (JJGONZ2, GGALV10, devin) creados con versiones anteriores de SCA2.

### 4.1 `SCA2 Error` — 57 filas (ids 1–66)

| Grupo | Ids | Clasificación |
|---|---|---|
| Alta con «error en el acceso a la base de datos» / «datos pasados como parámetro no son los esperados» (23–30/09) | 1, 2, 25, 30 (PENDIENTE) | Fallos de versiones antiguas del Alta, ya corregidos. Relanzar no aporta. |
| Alta rechazada por «Solicitud de anulacion ya existente» | 29, 31, 45, 46, 47, 48, 49, 57, 66 (PENDIENTE) | Rechazo de negocio de CORE (la póliza ya tenía solicitud abierta). Relanzar siempre vuelve a fallar. Desde la ronda 3 el Alta avisa antes de este caso. |
| `SCA2 CMD Decidir` 25/09 | 9, 11, 12, 14, 15 (PENDIENTE), 10, 13, 16 (BLOQUEADO) | Versión antigua de Decidir (solicitudes 15787510/514/516). |
| `ObtenerDocumentoGD` 25/09 | 26 | Fallo antiguo de GD (doc 553961). |
| `Posponer` CORE_OBSERVACIONES | 34, 44 | Versión antigua de Posponer. |
| `CompletarAccion` sobre 15787717 | 38, 41 | Solicitud ya cerrada en CORE. |
| Resto | 3–8, 17–24, 32–33, 35–37, 39–40, 42–43, 58, 60–65 | Ya RELANZADO/DESCARTADO (incluidas las de prueba PRUEBA-ERR-01/02 y 62–64). |

Ningún error pendiente corresponde al código actual.

### 4.2 `SCA2 Solicitud` — 90 filas (+104 `SCA2 Tarea`, 437 `SCA2 Transicion`)

| Grupo | Nº | Solicitudes |
|---|---|---|
| B. Altas que nunca llegaron a CORE (`PDTE-*` en estado ALTA) + 1 fila vacía (id 98) | 13 | PDTE-9962887, PDTE-268927149, PDTE-12087381, PDTE-268955689, PDTE-8940908, PDTE-9997566, PDTE-17329637, PDTE-16287989, PDTE-10001205, PDTE-13152818, PDTE-537413766, PDTE-12108734, (vacía) |
| C. `ERROR_DECISION` antiguas | 2 | 15787510, 15787514 |
| D1. En curso (EN_ACCION, PDTE_MECANIZAR, MECANIZADA) creadas con versiones anteriores | 47 | 15787499 … 15787793 (lista en §4.3) |
| D2. Cerradas (FINALIZADA*, CANCELADA) | 28 | 15787530 … 15787812 (lista en §4.3) |

### 4.3 Listas

- D1: 15787499 15787516 15787527 15787528 15787529 15787538 15787539 15787543 15787545 15787589 15787668 15787672 15787673 15787692 15787697 15787703 15787704 15787709 15787714 15787720 15787721 15787724 15787725 15787726 15787730 15787732 15787736 15787739 15787741 15787743 15787746 15787747 15787752 15787754 15787756 15787757 15787759 15787761 15787764 15787765 15787766 15787770 15787772 15787783 15787791 15787792 15787793
- D2: 15787530 15787546 15787699 15787702 15787706 15787713 15787716 15787717 15787719 15787722 15787723 15787728 15787738 15787744 15787745 15787749 15787751 15787755 15787763 15787771 15787777 15787779 15787780 15787786 15787789 15787790 15787794 15787812

### 4.4 Consideraciones antes de borrar

- Borrar en SCA2 no toca CORE: las solicitudes D1/D2 siguen existiendo en CORE y se ven en el buscador de SCA.
- Las MECANIZADA de D1 (15787759, 761, 764, 765, 766, 770, 772, 783) siguen en Mecanizar sin desbloqueo ANL. 15787759 lleva más de 24 h y no ha registrado `ANL_TIMEOUT`: pendiente de revisar si el corte a 24 h funciona.
- Backups CSV previos a cualquier borrado: `r9/v10/errores_all.json`, `data_sol.json`, `data_tar.json`, `data_tra.json` (workspace, no versionados por contener datos de pólizas).

## 5. Limpieza ejecutada (06/10/2026, alcance elegido por el usuario: «Solo errores y las 15 solicitudes que nunca llegaron a CORE o fallaron al decidir»)

Copia previa (CSV completos) en el workspace: `r9/v10/cleanup_backup/pre_{err,sol,tar,tra,traz}.csv` (no versionada: contiene datos de pólizas). Borrado con `deleteRecordData` por clave primaria:

| Record | Antes | Borradas | Después |
|---|---|---|---|
| `SCA2 Error` | 56 | 56 (ids 1–66, todas) | 0 |
| `SCA2 Solicitud` | 90 | 15 (grupos B y C de §4.2: 12 `PDTE-*`, fila vacía id 98, 15787510, 15787514) | 75 |
| `SCA2 Transicion` | 437 | 2 (de 15787510 y 15787514) | 435 |
| `SCA2 Tarea` | 104 | 0 (esas solicitudes no tenían tareas) | 104 |

No se ha tocado CORE ni las 75 solicitudes con número CORE (D1/D2). `testInterface` posterior: bandeja vacía con el mensaje de lista vacía y Detalle sin errores.

## 6. Pendiente

- `ANL_TIMEOUT` de 15787759: la consulta ANL (`ANL_getAnulacionByFilter_qr`) sigue sin fila para esa solicitud y su instancia (526741, versión del 01/10 con sondeo 288 × 5 min → nodo 312 → Write Error) debería haber escrito `ANL_TIMEOUT` el 02/10. No llegó a `SCA2 Error`. Sin acceso a Monitoring no se puede ver si la instancia está pausada por excepción o sigue esperando; lo tiene que mirar un administrador. La versión viva del PM ya no espera a ANL en pólizas NSE (nodo 324 → 325).
- 15787761 y 15787783 sí tienen fila ANL (2081 / 2087) en estado MECANIZAR, sin desbloqueo.
