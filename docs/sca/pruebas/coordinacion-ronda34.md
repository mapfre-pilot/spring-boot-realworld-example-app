# Coordinación ronda 34 — recarga/tréboles/enhorabuena y mantenimiento

Origen: `docs/sca/55-ronda34-analisis-sca2.md`. Dos sesiones hijas con propiedad exclusiva de objetos SCA2. Ninguna toca objetos de la otra; si necesita algo del otro lote, lo anota en su informe.

## R34-A — contra anulación (puntos 1 y 2)
Objetos propios: `SCA2_ContraAnulacionArgumentarioEstrategicas`, `SCA2_ContraAnulacionModalRecuperacionPoliza`, `SCA2_ContraAnulacionModalSVA`, `SCA2_ContraAnulacionModalSVAEmail`, `SCA2_ContraAnulacionModalRetos`, `SCA2_ContraAnulacionModalInformativo`, `SCA2_ContraAnulacionModalSiNo`, `SCA2_ContraAnulacionOpciones`, `SCA2_ContraAnulacionPrincipal` y las reglas de argumentario/campañas que sólo usan ellas (`SCA2_consultarListadoArgumentos` **NO**: es de R34-B; si la recarga necesita cambiarla, R34-A lo documenta y lo pide).
Pólizas: Autos no Club MAPFRE (para hacer el cliente Club durante la prueba) — crear solicitudes NUEVAS.

## R34-B — mantenimiento (puntos 3, 4, 5 y 7)
Objetos propios: `SCA2_GestionArgumentos`, `SCA2_TablaGestionArgumentos`, `SCA2_AltaGestionArgumento`, `SCA2_IF_ArgumentoAplicacionUrl`, `SCA2_GetUrlArgumento`, `SCA2_ArgumentoListadoValor`, `SCA2_modificarArgumento`, `SCA2_consultarListadoArgumentos`, `SCA2_GestionConceptosYClases`, `SCA2_AnadirGestionConceptosyClases`, `SCA2_ValoresConceptoGestionConceptosyClases`, `SCA2_AltaGestionConcepto`, `SCA2_EliminarValorConcepto`, `SCA2_consultarConcepto*`, `SCA2_guardarConcepto`, `SCA2_insertar/modificar/eliminarConceptoFuncionalREST`, `SCA2_obtenerConceptosRecord`, `SCA2_catConceptosAurora`, `SCA2_GestionMantenimientoMenu`, `SCA2_CatMantenimiento` y sus integraciones SCAC de mantenimiento (sólo lectura de SCAC).
Datos: usar códigos de prueba nuevos (argumentos ≥ 990 distintos de 999; valores de concepto `PRUEBA_DEVIN_R34_*`), nunca los antiguos; dejar documentado qué se creó.

## Reglas comunes
- Sólo objetos SCA2. Prohibido modificar SCA/SCAC/CORE/CMP/NSE/ANL. Solicitudes y datos NUEVOS para probar.
- Lectura viva → backup → cambio mínimo → relectura/comparación; validación LCP y UI con usuario de pantalla; comparar siempre con SCA.
- Informe en `docs/sca/pruebas/r34-*.md` + commit/push en `feature/sca` con la lista de objetos y versiones tocadas.
