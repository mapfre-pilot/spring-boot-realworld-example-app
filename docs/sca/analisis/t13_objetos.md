# Tanda 13 — objetos SCA2 creados/modificados (paridad UI SCA→SCA2)

Todos los objetos son SCA2_* en la app "SCA2 Anulaciones" (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20050128`).
SCA/SCAC/ANL no recibieron ninguna escritura (solo lecturas/dumps).

## Creados

| Objeto | Tipo | UUID | Origen portado |
|---|---|---|---|
| SCA2_AltaSolicitudAnulacionPopUp | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064994` | SCA_AltaSolicitudAnulacionPopUpEstrategicas (validaciones formato/longitud/permisos/PRRA/póliza pendiente/solicitud existente) |
| SCA2_TablaOtrasSolAnulacion | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065000` | SCA_TablaOtrasSolAnulaci_n_Estrategicas (8 columnas, dd/MM/yyyy HH:mm:ss, tags estado) |
| SCA2_SolicitudAnulacion | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064988` | SCA_SolicitudAnulaci_n (14 campos en 4 columnas) |
| SCA2_obtenerTareasSolicitudAlta | Regla | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064974` | Consulta SCA2 Tarea por numPoliza (usada por el popup) |
| SCA2_DBG_t13 (wrapper debug) | Interfaz | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20065202` | ELIMINADA tras capturas (page debug-t13 también retirada) |

## Modificados

| Objeto | Tipo | UUID | Cambio |
|---|---|---|---|
| SCA2_BuscadorTabla | Interfaz | `_a-..._20056379` | Estado = etiqueta negocio + tag color; fechas `yyyy-MM-dd HH:mm:ss`; guards null; sortFields (`.bak_t13`) |
| SCA2_textoEstadoSolicitud | Regla | `_a-..._20063670` | Mapeo completo códigos internos → literales SCA (ver t13_estado_mapping.md) |
| SCA2_colorEstadoSolicitud | Regla | `_a-..._20063676` | Colores #008C47/#BE0F0F/#E46B15/#734B30/#9F9F9F/#0D82BD |
| SCA2_Buscador | Interfaz | `_a-..._20055660` | Tab Cliente por defecto; Póliza = Número póliza/Matrícula/Número bastidor; LIMPIAR secondary + BUSCAR SOLICITUD rojo disabled hasta obligatorios, a la derecha; ALTA SOLICITUD ANULACIÓN rojo → popup in-page (vista=POPUP); vista=ALTA muestra SCA2_AltaSolicitudPage in-page; Detalle sin heading ni botón VOLVER (`.bak_t13`) |
| SCA2_AltaSolicitudPage | Interfaz | `_a-..._20055716` | +input numPoliza; header card (flecha "<" → buscador, "póliza - nombre - NIF", Más Datos, tabs Datos cliente/Datos póliza/Otras sol. Anulación/Datos contacto); form card ← SCA_AltaSolicitudAnulacionEstrategicas (compañía+lupa, Canal dropdown PRESENCIAL, Medio dropdown, fax validación `^[0-9]{1,9}$`, Tipo catalogación dropdown cons!SCA2_TXT_TIP_CATALOGACION_PCA, Fecha anulación, INFO box literal, Observaciones 0/240, CANCELAR confirm literal, GUARDAR tooltip); conserva submit SCA2 (a!writeRecords + a!startProcess SCA2 CMD Alta) y cascada Motivo→Detalle→Causa; quitados debug "Tipo de póliza" y "Teléfono Expertos" (`.bak_t13`) |
| SCA2_DetalleSolicitud | Interfaz | `_a-..._20055572` | +input idSel; header card 6 tabs (Datos cliente/Datos póliza/Solicitud Anulación/Otras sol. Anulación/Datos contacto/Notificaciones←SCA2 Trazabilidad Cliente); acordeón de acciones desde SCA2 Tarea (tag COMPLETADA verde/CANCELADA gris/default naranja + chevron + RETOMAR→SCA2_DetalleTareas); "Trazabilidad técnica" plegada solo SCA2 Administrators (a!isUserMemberOfGroup); sin headings rojos ni "VOLVER AL BUSCADOR"; flecha "<" → safeLink buscador (`.bak_t13`) |
| SCA2_SCA_CMP_APIClients_Perfil | Integración | — | ELIMINADA (duplicaba SCA2_APIClients_Perfil ya cableada) |
| Site "SCA2 Anulaciones" | Site | `bb62c468-0f71-4985-980a-6db65a9dc1f5` | v19→v21: página "Alta" eliminada (la alta vive in-page en Buscador); 3 páginas: buscador/errores/gestiones-mantenimiento. Backup pre-cambio: sca2_objects/site_backup_t13.json |

## Validación

- updateInterface/updateExpressionRule OK en todos; testInterface sin errores en las 4 principales.
- Capturas: t13_buscador.png, t13_buscador_cliente.png, t13_buscador_poliza.png, t13_popup_alta.png, t13_popup_validacion.png, t13_alta_page.png, t13_detalle.png, t13_detalle_sol.png, t13_detalle_notif.png (en /home/ubuntu/screenshots/).

## Gaps pendientes

- Popup Alta: para 0007051068625 la cadena de validaciones muestra "no es una póliza válida" (consultarPolizas/detalle no devuelve datos PCA para esa póliza al usuario AA vía pantalla — sí en el debug wrapper numPoliza fijo). La pantalla Alta completa se verificó vía wrapper SCA2_DBG_t13.
- Mensajes de validación §4b pendientes en CA Opciones (×5), AccAdm (×4), FueraNorma ("Adjuntar Documentacion") — solo se añadieron permisos+PRRA del popup.
- Compañías contrarias: el picker `SCA2_BuscarCompaniasContrarias` se muestra expandido bajo el form (revisar su gating `show`).
- Acordeón de acciones: TEST-NIV-2 no tiene filas en SCA2 Tarea → el acordeón aparece vacío en las capturas (funciona sobre datos; pendiente captura con tarea real).

## Tanda 13-bis (segunda pasada de paridad UI)

| Objeto | Tipo | UUID | Cambio |
|---|---|---|---|
| SCA2_TXT_ORIGEN | Constante | `_a-…_20065476` | NUEVA — ["IMPAGO","SOLICITUD EXPRESA","ENTIDAD","VENTA O DESAPARICIÓN"] (copia de SCA_TXT_ORIGEN) |
| SCA2_TXT_NIVEL_INTERVENCION | Constante | `_a-…_20065482` | NUEVA — ["NIVEL 1","NIVEL 2","NIVEL 3"] |
| SCA2_cargarSolicitud | Regla | `_a-…_20054954` | v10 — añade fecsolicitudanul/fecestado/fecimpresion/fecefecimpagado/contacto a Datos Solicitud y createdAt/modifiedAt/grupoAsignacion a estado |
| SCA2_SolicitudAnulacion | Interfaz | `_a-…_20064988` | v2 — reescrita: orden exacto SCA (14 campos/4 cols), etiqueta gris+valor STRONG, catálogos SCA2_TXT_ORIGEN/CAUSA/CANAL/CATALOGACION/NIVEL, estado upper(), Reserva prima "NO SOLICITADA / -", Núm. Solicitud solo admins |
| SCA2_DetalleSolicitud | Interfaz | `_a-…_20055572` | v7 — cabecera gris #F5F5F5 (arrow-left rojo + título + "Más Datos" chevron), tabs decorativeBar BOTTOM roja (no botones rellenos), expandida por defecto, acordeón blanco ROUNDED con fila fija "Alta Solicitud" (Finalizada verde) + filas Tarea (chevron+tag, separador rojo, RETOMAR, GESVIDA en fila VERTI), MECANIZAR/GESVIDA centrados eliminados, "Trazabilidad técnica" plegada solo admins |
| SCA2_AltaSolicitudPage | Interfaz | `_a-…_20055716` | v14 — masDatos:true (expandida), cabecera gris + tabs decorativeBar, título "Alta Solicitud Anulación" dentro de la card del form, picker compañías solo visible tras la lupa |
| SCA2_Buscador | Interfaz | `_a-…_20055660` | v12 — LIMPIAR color:"SECONDARY" (gris) junto a BUSCAR SOLICITUD, separador bajo "Últimas solicitudes gestionadas" |
| SCA2_ContraAnulacionOpciones | Interfaz | `_a-…_20056435` | v13 — +local!mayorOrdenObligNoEjecutados; POSITIVO/NEGATIVO disabled+tooltip literal SCA (×3 mensajes); FINALIZAR valida observaciones >999 → "El campo de observaciones ha sobrepasado el límite de 999 caracteres" |
| SCA2_AccionesAdministrativasPrincipal | Interfaz | `_a-…_20056429` | — FINALIZAR guarda local!mensaje "Los datos se han guardado correctamente"/"no se han podido"; tooltip "Es necesario informar la entrega de algún documento"; POSPONER disabled+tooltip "La acción ya ha sido pospuesta" si contadorPosponer>0 |
| SCA2_AnulacionFueraNormaPrincipal | Interfaz | `_a-…_20056423` | v9 — tooltip FINALIZAR literal SCA "Es necesario informar la entrega de algún documento" |
| SCA2_DBG_t13b (wrapper) | Interfaz | `_a-…_20067821` | CREADA y ELIMINADA tras captura (página debug-t13b añadida y retirada del site, v23→v24) |
| Site SCA2 Anulaciones | Site | `bb62c468-…` | v24 — vuelve a 3 páginas |

Capturas: `/home/ubuntu/screenshots/t13b_buscador_cliente.png`, `t13b_buscador_poliza.png`, `t13b_detalle.png`, `t13b_detalle_sol.png`, `t13b_detalle_notif.png`, `t13b_acordeon.png`, `t13b_alta.png`. Backups `.bak_t13b` en los 8 ficheros.

## Tanda 13-c (retoques finales)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| SCA2_Buscador | `_a-…_20055660` | v13 | LIMPIAR+BUSCAR SOLICITUD en un único `a!buttonArrayLayout(align:"END")` fuera de la card interior (como SCA, LIMPIAR SECONDARY); tabs sin `color` explícito (estilo de enlace por defecto SCA: STRONG/PLAIN, STANDALONE, dividers) |
| SCA2_BuscadorTabla | `_a-…_20056379` | v22 | `labelPosition:"ABOVE"` e `initialSorts` por createdAt (parámetros literales de `SCA_BuscadorTablaEstrategicas`; SCA no fija borderStyle/shadeAlternateRows/columnWidth → tampoco SCA2; cabeceras ya son los literales SCA y se ajustan en dos líneas automáticamente) |
| SCA2_DetalleSolicitud | `_a-…_20055572` | v10 | Franja superior del acordeón vacía (eliminado `local!acuerdoYDistribuidor` del título; el map se conserva para Datos póliza); toggle siempre "Más Datos" con chevron up/down |
| SCA2_AltaSolicitudPage | `_a-…_20055716` | v15 | Toggle siempre "Más Datos" con chevron |

Capturas: `t13c_buscador_cliente.png`, `t13c_buscador_poliza.png`, `t13c_detalle_sol.png`. Backups `.bak_t13c`.

## Tanda 14 (rsvPrima + idCompania)

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| SCA2 Datos Solicitud | `9a9209c7-…` | v9 (fields: rsvprima v8 `62f04821-67a9-4a3d-ae26-984ea0dcb5a1` DECIMAL→col RSVPRIMA; idcompania v9 `ad845ba3-1e5c-497c-807f-440b295df66d` INTEGER→col IDCOMPANIA) | ALTER TABLE aplicado vía `addRecordTypeField` (updateTable=true) |
| SCA2 CMD Alta | `0000f06f-28fc-8000-6693-7f0000014e7a` | — | +2 PVs parámetro `idCompania` (Number Integer), `rsvPrima` (Number Decimal); nodo 11 "Write Motivos reales" escribe `idcompania: pv!idCompania`, `rsvprima: pv!rsvPrima` |
| SCA2_cargarSolicitud | `_a-…_20054954` | v11 | +`rsvPrima`/`idcompania` en query+map datosSolicitud |
| SCA2_AltaSolicitudPage | `_a-…_20055716` | v16 | processParameters += `idCompania` (tointeger(compania.codigo)), `rsvPrima` (datosCliente.rsvPrima) |
| SCA2_SolicitudAnulacion | `_a-…_20064988` | v3 | "Reserva prima" lee `local!ds.rsvPrima` (=1→"SOLICITADA /", sino "NO SOLICITADA / -"); "Compañía contraria" resuelve `idcompania`→descripcion vía `SCA2_companiasContrariasCompletas` (catálogo, como SCA cons!SCA_TXT_COMPANIAS) |

Desviaciones: en SCA `rsvPrima` vive en `datosCabecera.cliente_rsvPrima` (TEXT, ya existe en SCA2 Datos Cabecera) e `idCompania` NO se persiste en SCA (se resuelve en vivo del `MSSConsultarCabecera`); por el brief se persisten en `SCA2 Datos Solicitud` con los nombres pedidos. `SCA2_AltaSolicitudPage` pasa `rsvPrima` desde `local!datosCliente.rsvPrima` (hoy null → "NO SOLICITADA / -", mismo resultado que SCA para altas nuevas).
Verificación: validateDesignObject 0 errores en PM Alta y record type; testInterface Detalle+Alta OK. Captura `t14_detalle_sol.png` obtenida en navegador real (login nativo restablecido): tab Solicitud Anulación renderiza Reserva prima / Compañía contraria sin error. Propiedades del PM (alertas SCA2 Alertas, borrado 1 día) sin tocar — updateProcessModel/updateProcessModelNode no incluyen esos campos (igual que en tandas 8-11).
Backups: `.bak_t14`.
