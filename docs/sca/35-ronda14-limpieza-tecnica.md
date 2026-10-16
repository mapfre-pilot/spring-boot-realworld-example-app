# Ronda 14 — Limpieza técnica de SCA2 (recomendaciones de Designer) sin cambio funcional

Fecha: 16/10/2026. Entorno: Appian TEST. Petición: resolver las «Warnings and Recommendations» de la aplicación SCA2, ordenar los modelos de proceso y limpiar código **sin cambiar el funcionamiento**. Documento funcional complementario para analistas: `36-funcional-sca2.md`.

## 1. Método
La API LCP no expone las recomendaciones de Designer, así que se recalcularon sobre un export vivo de los 546 objetos SCA2 (`sca2work/r18/live`, script `r18/analyze.py`): inputs `ri!` sin uso (y qué llamadores los pasan), variables de proceso sin uso y número de nodos por PM. El resultado coincide con la captura del usuario (9 avisos). Cada objeto: backup del GET vivo (`r18/backup_*`), PUT mínimo y relectura (`r18/after_*`).

## 2. Recomendaciones resueltas

| Objeto | Aviso | Qué se hizo | Versión |
|---|---|---|---|
| `SCA2 CMD Mecanizar` | Too many nodes (44) | 5 nodos «Capturar error …» eliminados: cada Write graba ahora `wrNodo/wrCodigo` (y `nodoError`) como salidas condicionales `if(ac!ErrorOccurred, literal, pv!…)`, idénticas a las que fijaba la captura; los XOR «¿Write fail?» van directos a Write Error. Re-ordenado por niveles. **44 → 39 nodos** | v20 → v21 |
| `SCA2 CMD CompletarAccion` | Too many nodes (49) | Mismo plegado de 6 capturas de escritura; los dos nodos «Subir documentos GD» (CA y AccAdm) unificados en uno con el XOR de salida reproduciendo exactamente la prioridad del XOR «Cancel?»; las capturas de autorización (305) e impresión (362) plegadas en Write Error con `local!autFail/imprFail` (mismos nodo/código/mensaje). **49 → 39 nodos** | v… |
| `SCA2_AltaSolicitudPage` | Unused rule input `mensaje` | Input eliminado; `SCA2_Buscador` ya no lo pasa | v30 → v33 |
| `SCA2_construirContextoAlta` | Unused rule input `origen`, `telefonoExpertos` | Inputs eliminados; kwargs quitados en `SCA2_AltaSolicitudPage` y en el nodo «Construir Contexto» de `SCA2 CMD Alta` | v11 → v12 |
| `SCA2_textoEstadoSolicitud` | Unused rule input `accion` | Input eliminado; kwargs quitados en `SCA2_Buscador`, `SCA2_BuscadorTabla`, `SCA2_SolicitudAnulacion`, `SCA2_TablaOtrasSolAnulacion` | v14 → v15 |
| `SCA2_consultarTipoArgIntegracion` | Unused rule input `random` | Input eliminado en la integración; el wrapper `SCA2_consultarTipoArg` ya no lo pasa y pierde también su input `random` (kwargs quitados en `SCA2_ContraAnulacionOpciones`, `SCA2_GestionArgumentos`) | integ v3; regla v3 → v5 |
| `SCA2_ContraAnulacionCompaniaCatalogacion` | Unused rule input `seleccionCia` | Input eliminado; `SCA2_ContraAnulacionOpciones` ya no lo pasa | v4 → v5 |
| `SCA2 CMD Finalizar` | Unused process variable `successSgc` | Variable eliminada; re-ordenado | — |
| `SCA2_altaDocumentoIntegracion` | Unused rule input `random` | Input eliminado; `SCA2_altaDocumento` ya no lo pasa ni lo recibe (`SCA2_subirDocumentosGD` actualizado) | integ v3; regla v2 → v4 |

Re-escaneo tras los cambios: **0 inputs sin uso** en los 412 reglas/interfaces/integraciones (queda sólo `SCA2_tmpDevinQuery`, regla auxiliar de pruebas de Devin que se borra al cerrar la ronda) y 0 PVs sin uso según Designer.

## 3. Orden de los modelos de proceso
Todos los PMs se han re-dibujado con un layout por niveles (BFS desde Start: flujo de izquierda a derecha, un carril por rama, nodos de error en la fila inferior): Alta, Decidir, CrearAccion, CompletarAccion, Mecanizar, Finalizar, Caducar, CambiarNivel, Posponer, MarcarErrorRelanzado. `BarridoCaducidad`, `GenerarPdf` y `ObtenerDocumentoGD` no se han podido re-ordenar: la API rechaza el PUT de sus nodos («data is invalid for at least one type/value», nodos Generate Docx/PDF/ModifySecurity no re-serializables por el plugin); su lógica no cambia.

## 4. Garantía de no cambio funcional
- Las salidas condicionales de los Write sólo actúan cuando `ErrorOccurred` es verdadero; en éxito dejan `pv!wrNodo/wrCodigo` como estaban (antes la captura no se ejecutaba).
- La unificación de «Subir documentos GD» conserva destino: CA/autorización → «Llamada cierre?», AccAdm → «Write Decidir», con la condición `and(AccAdm, not(Cancelado), not(Autorización aceptada))`.
- Los inputs eliminados no se referenciaban en ninguna expresión (comentarios excluidos) y los llamadores sólo pasaban valores que se ignoraban.
- Pruebas: regresión UI con el testing agent (alta → CA negativa → mecanización → inducción Verti; alta → CA positiva; buscador; Detalle) — resultado en §5.

## 5. Pruebas
(se completa al cierre de la ronda)
