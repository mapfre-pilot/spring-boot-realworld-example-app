# Ronda 34 — quinto «Análisis SCA2» (analistas, 27/10/2026): clasificación y reparto

Origen: documento «Analisis SCA2.docx» (5.º) del analista. Confirma que el evolutivo del argumento económico (ronda 30) **funciona** («está insertando en económicos correctamente, además hace bien lo de insertar solo cuando se da tréboles de verdad»).

| # | Punto del analista | Tipo | Qué hay que hacer | Quién |
|---|---|---|---|---|
| 1 | Tras **RECARGAR ARGUMENTO** (cliente que no era de Club, se hace de Club y se refresca el argumentario) al dar POSITIVO al argumento de tréboles **ya no sale la pantalla de tréboles** | Error | La recarga debe reconstruir el argumentario con los flags de campaña (tréboles/TTQ/SVA/retos) actualizados y el POSITIVO debe abrir la pantalla correspondiente igual que sin recargar. Comparar con SCA. | R34-A |
| 2 | El mensaje «¡Enhorabuena en la retención de la póliza!…» sale **antes** de la entrega de tréboles/SVA/retos y después puede salir «No se han podido asignar tréboles…» | Mejora (SCA tampoco lo hace) | Reservar la enhorabuena para el **final**, después de que tréboles/SVA/retos/servicio condicionado hayan terminado OK; si fallan, mostrar sólo el aviso del fallo (y el argumento queda sin cerrar como hoy). | R34-A |
| 3 | Mantenimiento → Argumentos: desplegables **Campaña** y **URL** no se llenan | Error | Cargar las opciones (conceptos CAMPAÑAS ARGUMENTARIOS y URLs de aplicación) como en SCA. | R34-B |
| 4 | Mantenimiento → Argumentos, **modificación**: estado, descripción, campaña, código de compañía, documentos a visualizar, checks (salvo económicos), instrucciones y observaciones **no se graban** | Error | Revisar `modificarArgumento` y el mapeo del formulario → servicio; comparar con SCA. | R34-B |
| 5 | Mantenimiento → Argumentos, **inserción**: el argumento 999 insertado por el analista está en BD (`D2139004_MES`, COD_TIPO 999) pero **no aparece en el listado** (que sí muestra 981/982 de pruebas Devin) | Error | Revisar filtro/paginación/orden del listado (`consultarListadoArgumentos`, tabla) y por qué 999 queda fuera. | R34-B |
| 6 | Variables de aplicación | OK | — | — |
| 7 | Gestión de conceptos: alta del valor **BAJAPRIM** en CAMPAÑAS ARGUMENTARIOS **no aparece ni se graba en BD** | Error | Revisar el alta de valor de concepto (`insertarConceptoFuncionalREST`/`guardarConcepto`, `AnadirGestionConceptosyClases`); comparar con SCA. | R34-B |

El analista anuncia otro «ideal» más complejo para más adelante (sin detallar).

Coordinación: `pruebas/coordinacion-ronda34.md`. Informes: `pruebas/r34-a-recarga-treboles-enhorabuena.md`, `pruebas/r34-b-mantenimiento-argumentos-conceptos.md`.
