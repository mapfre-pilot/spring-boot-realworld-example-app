# Ronda 30 — Evolutivo «argumento económico» (inserción en TRON_LD.A2139022_MES)

## 1. Petición de los analistas (30/10)

Cada vez que un argumento marcado como **económico** (check de Económicos del mantenimiento de argumentos,
`TRON_LD.D2139004_MES.txt_mca_eco = 'S'`) se da como **positivo**, insertar un registro en `TRON_LD.A2139022_MES`:

| Campo | Valor |
|---|---|
| COD_DOCUM | primeros 20 caracteres de la descripción del argumento |
| COD_ID_CAMPANA | `ECONOMICO` |
| COD_TIP_BON | `Arg. Econ.` |
| FEC_APLICACION | SYSDATE |
| MCA_APLICADA | `S` |
| NUM_POLIZA | póliza |
| NUM_SOLICITUD_PCA | solicitud |
| NUM_TIP_BON | código del argumento económico |

Condición clave: la inserción sólo cuando el positivo es **definitivo**; si el argumento abre la pantalla de tréboles
y el servicio que los recibe no devuelve OK, **no** se inserta.

## 2. Revisión previa en TEST (sin modificar nada)

| Pregunta | Resultado |
|---|---|
| ¿SCA2 usa el mismo mantenimiento de argumentos que SCA? | **Sí.** `SCA2_AltaGestionArgumento` lee el concepto funcional `flagActivoEconomico` (record `SCA Concepto Funcional`), consulta la marca con `SCA2_obtenerMarcaEconomica` → integración `SCAC_consultaMarcaEconomica` (`GET es_pca_gestionartareas_bbe-web/esp/api/1.0/consultaMcaEcon/{codArg}`) y la graba con `SCA2_modificarMarcaEconomica` → **la misma integración SCAC** `SCAC_modificarMarcaEconomica` (`POST …/modifMarcaEconomica`, body `{idArgumento, mcaEconomica}`) que usa `SCA_AltaGestionArgumento`. Es el backend el que escribe `txt_mca_eco`; Appian no accede a TRON_LD directamente (ni SCA ni SCA2 tienen data store a TRON). |
| ¿Cómo llega la marca a la pantalla de contra anulación? | El servicio `consultarListadoArgumentos` devuelve por argumento `mcaEconomico` (lo usa `SCA_ContraAnulacionOpcionesEstrategicas` línea ~492 y SCA2 ya lo propaga: `SCA2_ContraAnulacionOpciones` → `data.argumentoEconomico: index(local!argumentoSeleccionado,"mcaEconomico")` y `data.descTipoArgumento`). Marcas en TEST comprobadas con `SCA2_obtenerMarcaEconomica` (test LCP): codArg 1 → `S`, 24 → `N`, 252 → `S`. |
| ¿SCA ya inserta en `A2139022_MES`? | **Sí.** `SCA_ContraAnulacionModalRecuperacionPolizaEstrategicas` (`_a-0000ee64-4a6f-8000-9c9f-011c48011c48_18033401`), bloque «Comprobamos si el argumento es economico para insertar la ejecución en BBDD» tras los pasos 5-7 (tréboles / TTQ / SVA) y antes del 8: `SCAC_marcarAsignacionBonificacionIntegracion(host CORE7, endpoint PCA_CORECFSA_HTTPRouter/IGenerarContraAnul, marcarAsignacionBonificacion{numPoliza, codIdCampana "ECONOMICO", codTipBon "Arg. Econ.", numTipBon codTipoArgumento, numSolicitud, mcaAplicada "S", codDocum left(descTipoArgumento,20), fecAplicacion today()})`. Es el mismo servicio CORE (`marcarAsignacionBonificacion`, el «Bonocliente» de tréboles) que alimenta `A2139022_MES`; SCA no escribe en la tabla, llama al servicio. |
| ¿SCA2 lo hace? | **No.** `SCA2_ContraAnulacionModalRecuperacionPoliza` (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20052951`) deriva del modal **no** Estrategicas de SCA, que no tiene el bloque económico. Recibe ya `data.argumentoEconomico`, `data.descTipoArgumento`, `data.codTipoArgumento`, `data.numPoliza`, `data.codSolicitud` y dispone de `SCA2_marcarAsignacionBonificacionIntegracion` (copia de la SCAC, mismo endpoint). |
| ¿Dónde está el positivo definitivo? | En el `saveInto` de ACEPTAR del modal de recuperación: pasos 5-7 ejecutan tréboles (`executeAsignar` + `marcarAsignacionBonificacion`), TTQ (`gestionarTTQ`) o SVA; un fallo pone `ri!return = true` y devuelve el argumento a estado `0`; sólo con `ri!return = false` siguen los pasos 8/9 (`guardarEjecuArg` mcaResultado 1 → `onFinalizarPositivo`). |

### Hallazgo sobre SCA (no se toca SCA)

El bloque económico de SCA **no comprueba `ri!return = false`**: si los tréboles/TTQ fallan, SCA inserta igualmente en
`A2139022_MES`. Contradice la condición del analista. En SCA2 la inserción se condiciona a `ri!return = false`
(tréboles/TTQ/SVA con OK) además de `argumentoEconomico = "S"`.

## 3. Conclusión

No quedan dudas funcionales bloqueantes: todos los datos están en el modal de SCA2 y el servicio es el mismo que usa SCA.
Implementación en una sesión hija (R30) sobre `SCA2_ContraAnulacionModalRecuperacionPoliza`, con prueba en solicitudes
nuevas (argumento económico con y sin tréboles, fallo/cancelación) y comparación con SCA.

Puntos a confirmar con el analista (no bloquean): (1) FEC_APLICACION la fija Appian con `today()` como en SCA (no SYSDATE del
backend); (2) en SCA la inserción se produce aunque fallen los tréboles — ¿se corrige también en SCA?
