# S4 — Decisión → Autorización (anulación fuera de norma): SCA vs SCA2 en TEST

Prueba de paridad funcional ejecutada el 30/09/2026 en `https://mapfrespain-test.appiancloud.com`
(usuario funcional `JJGONZ2`, perfil `RED MAPFRE` / `OFICINA`, canal `CE_RM`). SCA TEST es la
referencia funcional; solo se corrigen objetos de SCA2.

## 1. Pólizas y solicitudes creadas

| App | Póliza | idSolicitud | Combinación de alta | Gestiones CORE creadas |
|---|---|---|---|---|
| SCA (`sca-site`) | `2001900033136` | **15787698** | Motivo 4 `DECISIÓN DE LA ENTIDAD` → Detalle 9 `DECISIÓN DE LA ENTIDAD` → Causa 28 `ANULACIÓN FUERA DE NORMA`, catalogación 4 `A FECHA`, fecha anulación 30/09/2026 | Alta `43704809` (acción 8), Autorización `43704813` (acción 7) |
| SCA2 (`sca2`) | `2002000066389` | **15787703** | Idéntica | Alta `43704818` (acción 8), Autorización `43704820` (acción 7) |
| SCA2 (`sca2`), repetición tras corregir | `2002000024237` (reserva) | **15787714** | Idéntica | Alta `43704858` (acción 8), Autorización `43704859` (acción 7) |
| SCA2 (`sca2`), ronda 2 (POSPONER SGC + FINALIZAR v15…v18) | `2002000045500` | **15787721** | Idéntica | Alta `43704873` (8), Autorización `43704876` (7), Mecanización `43704882` (5) |
| SCA2 (`sca2`), ronda final (FINALIZAR v19 punta a punta) | `2002000040119` (reserva 2) | **15787725** | Idéntica | Alta `43704884` (8), Autorización `43704885` (7), Mecanización `43704888` (5) |
| SCA2 (`sca2`), ronda 4 (CMD genéricos, §3.10) | `2002000025123` | **15787732** | Idéntica | Alta `43704912` (8), Autorización `43704913` (7), Mecanización `43704914` (5) |
| SCA2 (`sca2`), ronda 5 (etiquetas, Observaciones, popup, §3.11) | `2002000062813` | **15787739** | Idéntica | Alta `43704933` (8), Autorización `43704935` (7), Mecanización `43704937` (5) |

La primera reserva se usó para repetir FINALIZAR en SCA2 tras la primera corrección del PM (§3.4); las dos
pólizas de la segunda asignación para la ronda 2 (§3.5-§3.7). No se ha tocado ninguna otra solicitud.

Ambas pólizas son NSE-Autos (`idLineaNegocio = 1`, compañía 41). El motor de reglas decidió en
ambas apps `Autorización` (nivel de intervención 1, grupo `CE_RM`), y la navegación tras el alta
llevó directamente a la pantalla «Revisión autorización de fecha de anulación».

## 2. Tabla paso a paso SCA vs SCA2

| # | Paso | SCA 15787698 | SCA2 15787703 | Veredicto |
|---|---|---|---|---|
| 1 | Alta (motivo 4 / detalle 9 / causa 28 / a fecha) | Alta OK, decisión Autorización, navegación directa a la pantalla de autorización | Igual | igual |
| 2 | Estado CORE inicial | `codEstSolic=2`, gestión 8 FINALIZADA, gestión 7 (`codEstGestion=FINALIZADA`, `fecFinGestion=null`, nivel 1); autorización `codEstado=1`, `mcaAutorizada=N`, `tipoAutorizacion=SI24` | Igual (gestiones 43704818/43704820) | igual |
| 3 | Estado SCA2 inicial | n/a | Solicitud `EN_ACCION` / `interfazActiva=AUTORIZACION` / `estadoTarea=PENDIENTE` / `grupoAsignacion=CE_RM` / nivel 1; Tarea id 20 `AUTORIZACION` PENDIENTE | igual (equivalente) |
| 4 | Pantalla de autorización: cabecera, pestañas, oficinas, fecha, botones | Pestañas Datos cliente/póliza/Solicitud Anulación/Otras sol./Datos contacto; selector oficina (MADRID CORREDORES NORTE II, VILLALBA); fecha 30/09/2026; CANCELAR / POSPONER / FINALIZAR | Igual; SCA2 añade «Notificaciones» y «VOLVER AL DETALLE» (diseño propio, ya documentado) | igual |
| 5 | Sección Documentación | Desplegada al abrir, línea separadora solo si está plegada | Antes: plegada y línea invertida → **corregido** (`SCA2_AnulacionFueraNormaPrincipal` v11) | divergencia_corregida |
| 6 | Tooltip / deshabilitado de FINALIZAR sin documentos | «Es necesario entregar los documentos que se precisan para poder continuar» | Antes: texto distinto y condición sobre `noEntregaDoc` → **corregido** (v11: `documentosEntregados = noEntregaDoc or documentosOk`) | divergencia_corregida |
| 7 | Pestaña «Solicitud Anulación» del detalle | Fechas `dd/MM/yyyy` de cabecera CORE, origen, estado y fecha estado de CORE | Antes: fecha con hora y CEST, estado/fecha de la fila SCA2 → **corregido** (`SCA2_SolicitudAnulacion` v5) | divergencia_corregida |
| 8 | Tarjeta de la gestión Autorización en el Detalle | Título «Gestiones realizadas»; tarjeta con estado CORE (Pendiente), fecha inicio, nivel, perfil, grupo, nuuma, centro emisor, nº situación Autemis, resultado, documentos y observaciones | Antes: encabezado vacío y tarjeta sin datos CORE → **corregido** (`SCA2_DetalleSolicitud` v18: la tarjeta Autorización lee `SCA2_consultaGestion` acción 7, `SCA2_consultarAutorizacion` y `SCA2_consultaDetalleGestion`) | divergencia_corregida |
| 9 | Cambio de nivel | No existe acción visible de «cambiar nivel/escalar» en la pantalla de autorización; el nivel lo fija el motor al alta | Igual: `SCA2 CMD CambiarNivel` existe como PM pero ninguna pantalla lo expone; `nivelIntervencion` permanece 1 en CORE y en `SCA2 Solicitud` | igual (no aplicable en este flujo) |
| 10 | REASIGNAR / RETOMAR antes de POSPONER | REASIGNAR → «La tarea se ha reasignado correctamente» → RETOMAR abre la tarea | RETOMAR visible (tarea asignada al creador) y abre la autorización | igual |
| 11 | POSPONER sin oficina | Bloqueado: «Seleccione oficina — Se requiere un valor» | Antes: guardaba `CORRECTO` sin oficina → **corregido** (`SCA2_selectorOficinas` v4 + `SCA2_AnulacionFueraNormaPrincipal` v13, ver §3) | divergencia_corregida (verificado en fase 3: mensaje rojo «Se requiere un valor» y sin `CORRECTO`) |
| 12 | POSPONER con oficina y observaciones | `CORRECTO`; CORE gestión 7 `observaciones = "Prueba S4 posponer"`; tras F5 sigue Pendiente y la tarjeta muestra la observación | Antes: `CORRECTO` pero CORE `observaciones = null` y tarjeta `-` → **corregido** (v12: el botón inserta observaciones en CORE con `tipoGestion "7"` como SCA); tras la corrección CORE muestra `"Prueba S4 posponer 2"` | divergencia_corregida |
| 13 | Botones tras POSPONER (vuelta al pool) | REASIGNAR visible | Tras el primer POSPONER no aparecía ningún botón (regla `SCA2_puedeGestionarTarea` excluía nivel 1); con la v3 de la regla (publicada por otra sesión durante la prueba) aparece REASIGNAR y RETOMAR funciona | divergencia_corregida (otra sesión) |
| 14 | RETOMAR tras POSPONER | «La tarea solicitada no está disponible…» (el proceso SCA sustituye la tarea al posponer y el detalle apunta a la antigua) | RETOMAR abre la autorización de `2002000066389` | divergencia_comun_sca (fallo del lado SCA; no se corrige) |
| 15 | FINALIZAR (autorizar) con oficina, fecha 30/09/2026, 2 PDF (tipos 7 y 8) y observación | `CORRECTO`; tras F5 la tarjeta Autorización muestra **Aceptada**, fecha fin, los 2 documentos y la observación `Prueba S4 finalizar` añadida a la anterior | 15787703/15787714: `CORRECTO` en pantalla, pero tras F5 la autorización seguía **Pendiente**, sin fecha fin ni documentos (PM sin rama de aceptación + adjuntos temporales, §3.4). Tras las correcciones (§3.5 y §3.6), **15787725** (v19): `CORRECTO` y tras F5 la tarjeta muestra **Aceptada**, fecha fin `30/09/2026 14:29:12`, los 2 documentos y la observación `Prueba S4 finalizar v19`, igual que SCA | divergencia_corregida |
| 16 | Estado final CORE / Detalle / buscador / F5 | CORE: autorización `codEstado=2`, `mcaAutorizada=S`, `fecAnulAutorizada=30/09/2026`; gestión 7 `FINALIZADA` con `fecFinGestion=12:43:12`; nueva gestión 5 (Mecanización) `43704856` `INCOMPLETA`; `codEstSolic=2`. Buscador SCA: Pendiente (la solicitud sigue viva hasta mecanizar) | 15787703/15787714: CORE `codEstado=1`, sin gestión 5, buscador «PDTE_MECANIZAR» (divergencias iniciales). **15787725**: CORE `codEstado=2` / `mcaAutorizada=S` / `fecAnulAutorizada=30/09/2026`; gestión 7 `FINALIZADA` `14:29:12`; gestión 5 `43704888` `INCOMPLETA`; `codEstSolic=2`; `SCA2 Solicitud` = `PDTE_MECANIZAR` / `procesoActivo MECANIZAR` / tarea PENDIENTE; buscador SCA2 «Pendiente» naranja (§3.7) = SCA; sin filas en `SCA2 Error` | divergencia_corregida |
| 17 | FINALIZAR habilitado con un solo documento entregado | Habilitado (`documentosOk = or(documentoOk1..9)`) | Igual (mismo `SCA2_AccionesAdministrativasDocumentacion`, solo cambian constantes) | igual |
| 18 | Documentos registrados en CORE tras FINALIZAR (`consultarDocumentos`) | 2 documentos (tipos 7 y 8, Documentum `0900ab44…`) | `null` en 15787703 y 15787714 (adjuntos perdidos). 15787721 y 15787725: 2 documentos (tipos 7 y 8, `0900ab4481a04e09/…4e07` y `…4e19/…47e3`), `docsResult.numSubidos=2` en el PM | divergencia_corregida |
| 19 | POSPONER y gestión SGC | El XOR 19 «Posponer?» de `SCA Autorización` no llega a `SCA_posponerAutorizacion` cuando `codEstado="1"` (instancias 16282489/521404: `cargaGestionPCA0=[]`, `idGestionSGC` sigue `"0"`) → **no** se da de alta gestión SGC al posponer una autorización pendiente | `SCA2 CMD Posponer` recibe `tipoAccion="AUT"` y el nodo «Alta gestión SGC» omite el alta para AUT (`omitido=true`, §3.8); la observación sí se inserta en CORE (`Prueba S4 posponer v15,Prueba S4 posponer v16` en la gestión 7 de 15787721) | igual |
| 20 | Texto/color del estado en el buscador tras aceptar | «Pendiente» (tag naranja) | Antes «PDTE_MECANIZAR» → **corregido** (`SCA2_textoEstadoSolicitud` v8, `SCA2_colorEstadoSolicitud` v3): «Pendiente» naranja para 15787721 y 15787725 | divergencia_corregida |
| 21 | Subida de adjuntos por el usuario funcional | Permitida | Antes (v17): «No tiene privilegios suficientes para cargar un archivo en la carpeta designada» → **corregido** (seguridad de la carpeta `SCA2 Autorizacion`: `SCA2 Users` Editor, §3.5) | divergencia_corregida |
| 22 | Columna Observaciones del buscador | `txtObs` de la última gestión CORE (`Prueba S4 posponer v20` tras POSPONER, `Prueba S4 finalizar v20` tras FINALIZAR en 15787732) | `SCA2_BuscadorTabla` v6 (S1) lee `SCA2 Datos Solicitud.fecimpresion`; antes solo la escribía `CMD Alta` (S4 sin observación en el alta → `-`). **Corregido en los CMD** (ronda 4, §3.10): `SCA2 CMD Posponer` nodo 5 y `SCA2 CMD CompletarAccion` nodo 5 persisten la última observación de forma genérica (CA/ACCADM/AUT). UI 15787732: tras POSPONER ambos buscadores `Prueba S4 posponer v20`; tras FINALIZAR ambos `Prueba S4 finalizar v20`. 15787725/15787721 (anteriores) siguen en `-` | divergencia_corregida |
| 23 | Color del tag «Aceptada» en la tarjeta Autorización del Detalle | Verde `#008C47` (`SCA_D_ColorEstadoGestion`) | Antes naranja (`local!estadoCard = "ACEPTADA"` no estaba en el `a!match` → `default: "#E46B15"`) → **corregido** (`SCA2_DetalleSolicitud` v24): tag «Aceptada» verde `#008C47` en 15787725 tras F5, verificado en píxeles y comparado con SCA 15787698/15787725 (`s4-203`, `s4-205`, `s4-206`) | divergencia_corregida |
| 23 | Etiqueta de estado del buscador («Últimas solicitudes gestionadas») tras POSPONER y tras FINALIZAR | «Pendiente» naranja: `SCA_BuscadorTabla` muestra `rule!SCA_D_EstadosSolicitud(estSolicitud)` sobre el `codEstSolic` CORE (2) | Mostraba «Solicitud Pendiente» (mapeo S3/S5 tomado de `SCA_calcularEstadoSolicitud`, que es el texto de la pestaña **Póliza**/`*Estrategicas`, no el de esta tabla) → `SCA2_textoEstadoSolicitud` v9: «Pendiente» naranja; verificado en 15787739 tras POSPONER y tras FINALIZAR (capturas s4-404/405/411/412) | ≠SCA2 ✔ |
| 24 | Resto de etiquetas del buscador | Textos de `SCA_D_EstadosSolicitud` («Finalizada positivamente» verde `#008C47`, «Finalizado negativo con contraanulación» / «Finalizada no requerida contraanulación» `#BE0F0F`, «Caducada», «Cancelada», «Pendiente de Autorizar»…) | v9 mapea **todos** los estados internos a esos textos (tabla en §3.11); `SCA2_colorEstadoSolicitud` v4 solo añade los hex de los textos nuevos. 15787728 «Finalizada positivamente» verde en ambas apps | ≠SCA2 ✔ |
| 25 | Popup «La tarea se ha reasignado correctamente» (REASIGNAR) | Tarjeta INFO centrada (`a!columnsLayout` NARROW / auto / NARROW) a ~2/3 del ancho de la tarjeta de la gestión | En v17-v24 la llamada a `SCA2_PopUpReasignarTarea` estaba dentro de la 9ª columna del layout de botones (popup estrecho con el texto en vertical). En la v28 viva (ediciones de S2/S3 posteriores a la ronda 4) la llamada está al nivel de la tarjeta y el popup se ve igual que en SCA (captura s4-407). Sin cambios de S4 | = (corregido en v28) |
| 26 | Columna Observaciones del buscador: regla exacta de SCA | `fv!row.txtObs` de `SCA_consultarUltimaGestionREST(nuuma)` (una llamada por carga): **última observación registrada en CORE para la solicitud (máx `codObs`)**, sea de la gestión que sea — incluida la traza técnica «Consulta NEW: …» que CORE escribe como observación de la gestión de mecanización (acción 5) al crearla en FINALIZAR de AccAdm/CA negativa | `fecimpresion` del record (observación del usuario en el CMD): coincidía con SCA solo cuando la última observación es la del usuario (Autorización sí; AccAdm 15787736/15787730 y CA negativa 15787726 no) → `SCA2_BuscadorTabla` v7 usa la misma llamada CORE con join por `numSolicitud` y `fecimpresion` como respaldo; 15787736 muestra la misma traza en ambas apps (capturas s4-411/412/413) | ≠SCA2 ✔ |
| 27 | Ciclo completo 15787739 (alta → POSPONER → REASIGNAR → RETOMAR → 2 documentos → FINALIZAR) | referencia | CORE autorización `codEstado=2` / `mcaAutorizada=S` / `codGestion=43704935`; gestión 7 FINALIZADA 15:54:54 (obs. «Prueba S4 posponer v21,Prueba S4 finalizar v21»), gestión 5 INCOMPLETA; documentos `893801a0f298b67b` (tipo 7) y `0900ab4481a0484f` (tipo 8); record `PDTE_MECANIZAR` / `MECANIZAR` / `PENDIENTE` v6 con `fecimpresion="Prueba S4 finalizar v21"`; Detalle F5 «Aceptada» verde + 2 docs + observaciones + Mecanizacion/Incompleta; `SCA2_BandejaErrores` sin filas de 15787739; PM Posponer v7.0 (`522219`) y CompletarAccion v32.0 (`14190911`) COMPLETED | = |

## 3. Divergencias y correcciones en SCA2

Procedimiento por objeto: GET vivo → backup local JSON → edición mínima → PUT completo (con `inputs`) →
re-GET → `POST .../test` → repetición UI. SAIL antes/después guardado en local (`~/sca2work/live`,
`~/sca2work/backup`), no en el repositorio.

| Objeto | UUID | Versión | Cambio |
|---|---|---|---|
| `SCA2_AnulacionFueraNormaPrincipal` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056423` | 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18 → 19 → 20 | v20 (ronda 4, §3.10): se revierte el `a!writeRecords` de la v19 (expresión idéntica a la v18: la interfaz solo arranca el PM; la persistencia pasa a los CMD). v19 (ronda 3, §3.9): `a!writeRecords` en POSPONER/FINALIZAR (descartado por diseño). v16: FINALIZAR con `submit: false` (la doc. oficial indica que `submit: true` + `a!submitUploadedFiles` no funciona). v17: `documents:` explícito con los ficheros de los 8 huecos. v18 (**final**): se elimina `a!submitUploadedFiles` de FINALIZAR porque `SCA2_AccionesAdministrativasDocumentacion` v3 ya consolida cada fichero en AÑADIR/MODIFICAR; FINALIZAR inserta observaciones y arranca `SCA2 CMD CompletarAccion` directamente (§3.5). v14: FINALIZAR inserta las observaciones en CORE (`tipoGestion "7"`) antes de lanzar el PM, como SCA. v15: FINALIZAR envuelve la acción en `a!submitUploadedFiles(onSuccess: …)` cuando hay adjuntos (§3.4). v11: documentación desplegada por defecto (`collapse1: true`, `horizontalLine(showWhen: not(collapse1))`) y tooltip/`disabled` de FINALIZAR con `documentosEntregados`. v12: POSPONER inserta observaciones en CORE (`SCA2_insertarObservaciones(..., tipoGestion: "7")`) antes de lanzar `SCA2 CMD Posponer`. v13: validación manual de oficina en POSPONER y FINALIZAR (`local!faltaOficina` → mensaje «Se requiere un valor»). |
| `SCA2_SolicitudAnulacion` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20064988` | 4 → 5 | Fechas (`fecSolicitudAnul`, `fecEstado`), origen y estado de la solicitud tomados de la cabecera CORE (`left(tostring(...),10)`, `SCA_D_EstadosSolicitud`) con fallback a la fila SCA2. |
| `SCA2_DetalleSolicitud` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20055572` | 17 → 18; 23 → 24 (ronda 3) | v24: `a!match` de `backgroundColor` del tag de la tarjeta añade `equals: "ACEPTADA", then: "#008C47"` (verde como `SCA_D_ColorEstadoGestion`); resto de la interfaz (ediciones de S2/S3/S5 hasta v23) intacto, GET vivo inmediatamente antes del PUT y re-GET. v18: Encabezado «Gestiones realizadas»; la tarjeta de la acción Autorización se asocia a la gestión CORE `accionRealizada = "7"` y muestra estado (`SCA2_consultarAutorizacion.codEstado` → `SCA2_TXT_ESTADOS_AUTORIZACION`), fechas, nivel, perfil/grupo/nuuma, centro emisor, nº situación, resultado, documentos y observaciones (`SCA2_consultaDetalleGestion`). |
| `SCA2 CMD CompletarAccion` (PM) | `0000f06f-1307-8000-65b1-7f0000014e7a` | 12.0 → 15.0 → (26.0 → 27.0 en la 2ª edición; 30.0 ya en la instancia v19 por ediciones de S2/S3/S5) | **3ª edición (ronda 4, §3.10)**: nodo 5 «Write Tarea» añade a la misma transacción `SCA2 Datos Solicitud`(`id`, `fecimpresion` = `tostring(index(pv!resultado,"observaciones",null))`) cuando hay observaciones (las tres interfaces CA/ACCADM/AUT informan `resultado.observaciones`). GET vivo tras el cierre de S5: nodo 340 con `estadoTarea: "COMPLETADA"` verificado antes y después; 46 nodos y 17 pv conservados, resto de nodos idéntico. Instancia 15787732 con versión 32.0. **2ª edición (§3.6)**: nodo 302 «Aceptar Autorizacion» → nuevo 303 «Actualizar Autorizacion» (`rule!SCA2_guardarAutorizacion`, `codEstado 2`/`mcaAutorizada S`, como el nodo «Actualizar Autorización» de `SCA Autorización`) → 304 «¿Autorizacion ok?» (`autRes.success`) → 330 Write Transicion OK; rama KO → 305 «Capturar error autorizacion» (`AUT_GUARDAR_FAIL`) → 199 Write Error. Nueva `pv!autRes`. 37 → 40 nodos, 13 → 14 variables; re-GET: rama GD de S5 (310-312), fix `consulta` de S1 (301) y nodos 350-353 conservados. **1ª edición**: XOR 6 «Cancel?»: nueva condición `operacion="Autorizacion" and codEstado="2"` → nodo 310 «Subir documentos GD» (antes iba por el `defaultPath` a «Write Decidir» sin aceptar la autorización en CORE ni subir documentos). XOR 200 «¿Write fail?»: misma condición → nodo 11 «Write Decidir» tras «Aceptar Autorizacion». Backups en `~/sca2work/backup/pm/`. |
| `SCA2_textoEstadoSolicitud` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063670` | 7 → 8 | `PDTE_MECANIZAR` → «Pendiente» (texto exacto del tag de `SCA_BuscadorTabla`/`SCA_D_EstadosSolicitud`); el resto del mapeo de S3/S5 («Solicitud Pendiente», etc.) intacto. |
| `SCA2_colorEstadoSolicitud` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063676` | 2 → 3 | «Pendiente» → `#E46B15` (naranja, como SCA). |
| `SCA2 CMD Posponer` (PM) | `0000f06f-8a47-8000-6751-7f0000014e7a` | v4 (S3) → v5 → v7 (instancia 15787732) | **Ronda 4 (§3.10)**: nodo 5 «Write Posponer» añade a la misma transacción `SCA2 Datos Solicitud`(`id`, `fecimpresion` = `tostring(pv!motivo)`) cuando hay motivo, genérico para CA/ACCADM/AUT; 12 nodos y 23 pv conservados, resto de nodos idéntico (comparado tras el re-GET). Ronda 2: nodo 6 «Alta gestión SGC»: el `or()` de omisión incluye `local!esAutorizacion` (`pv!tipoAccion = "AUT"`) con comentario `[S4]` explicando la paridad con el XOR 19 de SCA (§3.8). Payload AUT de `SCA2_posponerGestionSGC` (S3) verificado igual al de `SCA_posponerAutorizacion` (`codPca "N"`, `codEstado "1"`, `numSgo`, `tipoAutorizacion`, `ID_AGENTE_CLAVE`/`NIF_CIF_PRODUCTOR`): sin cambios en la regla. |
| Carpeta `SCA2 Autorizacion` (seguridad) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20050263` | — | `PUT /objects/{uuid}/security`: se añade `SCA2 Users` como **Editor** (antes solo Viewer; `SCA2 Administrators` Administrator se conserva). Backup `~/sca2work/backup/folder_SCA2_Autorizacion.security.*.json`. S3 hizo lo mismo en las carpetas de AccAdm/CA. |
| `SCA2_selectorOficinas` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20053256` | 1 → 2 → 3 → 4 | v2: input `validationGroup` (descartado: fuera de un formulario Appian no evalúa `required` y ocultaba el asterisco). v3: **versión rota durante ~3 min** (`if` con 4 parámetros; detectada por el test LCP y corregida de inmediato). v4: input `mensajeError` (Text) mostrado en rojo bajo el desplegable y limpiado al seleccionar oficina; se elimina `validationGroup`. |
| `SCA2_textoEstadoSolicitud` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063670` | 8 → **9** (ronda 5) | Mapeo completo estado interno → texto `SCA_D_EstadosSolicitud` (§3.11); antes solo `PDTE_MECANIZAR` → «Pendiente» y el resto «Solicitud Pendiente» |
| `SCA2_colorEstadoSolicitud` (regla) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20063676` | 3 → **4** (ronda 5) | Solo **añade** «Finalizada positivamente» `#008C47`, «Finalizado negativo con contraanulación` y «Finalizada no requerida contraanulación» `#BE0F0F` (hex de `SCA_BuscadorTabla`); las entradas existentes no se tocan |
| `SCA2_BuscadorTabla` (interfaz) | `_a-0000f069-4f37-8000-9cc8-011c48011c48_20056379` | 6 → **7** (ronda 5) | Envuelta en `a!localVariables` con `local!ultimas: SCA2_consultarUltimaGestionREST(nuuma)` (una llamada por carga, como SCA); columna Observaciones = `txtObs` por `numSolicitud`, respaldo `fecimpresion` |

### 3.1 Fragmentos relevantes

`SCA2_AnulacionFueraNormaPrincipal` v12/v13 — botón POSPONER:

```
saveInto: if(local!faltaOficina, a!save(local!mensajeOficina, "Se requiere un valor"), {
  /* Paridad SCA: las observaciones de POSPONER se insertan en CORE (tipoGestion "7") desde el botón */
  a!save(local!insertarObservacionesResponse,
    index(rule!SCA2_insertarObservaciones(nuuma: local!nuuma, codSolicitud: ri!idSolicitud,
          txtObservaciones: local!observaciones, tipoGestion: "7"), "success", false)),
  a!startProcess(processModel: cons!SCA2_PM_CMD_POSPONER, ...)
}),
```

con `local!faltaOficina: and(local!masDeUnaOficina, a!isNullOrEmpty(local!detalleOficina))` y
`rule!SCA2_selectorOficinas(..., mensajeError: local!mensajeOficina)`. El mismo `if` envuelve el
`saveInto` de FINALIZAR.

`SCA2_selectorOficinas` v4:

```
saveInto: {ri!detalleOficina, a!save(ri!mensajeError, null)}
...
a!richTextDisplayField(labelPosition: "COLLAPSED",
  value: a!richTextItem(text: ri!mensajeError, color: "NEGATIVE", size: "SMALL"),
  showWhen: and(length(ri!oficinas) > 1, a!isNotNullOrEmpty(ri!mensajeError)))
```

### 3.2 Por qué SCA valida la oficina y SCA2 no lo hacía

En SCA la pantalla es el formulario de una tarea de proceso: al pulsar un botón `submit` Appian
evalúa los `required` de todo el formulario. En SCA2 la misma interfaz se muestra dentro del Detalle
(página de site, sin formulario de tarea), donde `required: true` del desplegable no se evalúa y el
botón (con `validationGroup: "FechaDeAnulacion"`) no lo bloquea. Añadir el mismo `validationGroup`
al desplegable (v2) no sirvió: el diálogo de confirmación aparecía igual, se guardaba sin oficina y
además desaparecía el asterisco de obligatorio. Por eso la v4/v13 valida a mano y reproduce el
mensaje estándar «Se requiere un valor».

### 3.3 Causa raíz de las observaciones perdidas en POSPONER

`SCA2 CMD Posponer` (nodo *Write Posponer*) llama a `SCA2_insertarObservaciones` con
`tipoGestion: ""`; el servicio CORE devuelve `success=false` (comprobado con `POST .../test`
reproduciendo la llamada), por lo que nunca se persiste. SCA inserta las observaciones desde el propio
botón con `tipoGestion: "7"`. La corrección replica el botón SCA; el PM no se ha modificado (la llamada
embebida sigue fallando de forma inocua; se recomienda eliminarla en una revisión del PM).

### 3.4 Causa raíz de FINALIZAR: `CORRECTO` en pantalla pero autorización Pendiente

1. **Primera causa (PM).** En `SCA2 CMD CompletarAccion` el XOR «Cancel?» solo distinguía *Cancelado*
   (`finalizadoCA`/`mcaEstadoFinal` 9-3/`codEstado` 5) y *Autorizacion* (`estadoFinalizar = "6"`, que es el
   caso en que una Contra Anulación deriva a autorización). Una autorización **aceptada** (`operacion =
   "Autorizacion"`, `codEstado = "2"`) caía en el `defaultPath` → «Write Decidir» → `SCA2 CMD Decidir`, por eso
   15787703 pasó a `PDTE_MECANIZAR` en SCA2 sin que CORE registrase la aceptación (`SCA2_aceptarAutorizacion`
   nunca se llamaba) ni se subiesen los documentos. SCA, en cambio, ejecuta `SCAC_aceptarAutorizacion` y
   «SCA Subir Docs Documentum BBDD» en el formulario de la tarea. Corrección: nuevas condiciones en los XOR 6 y
   200 para encadenar `Subir documentos GD → Aceptar Autorizacion → Write Decidir` (tabla §3).
2. **Segunda causa (adjuntos temporales), detectada al repetir con 15787714.** Con el endpoint LCP
   `GET /process-models/{uuid}/processes` + `GET /processes/{id}` (y `/variables`) se localizó la instancia
   `17325135` (`idSolicitud 15787714`, `idTarea 25`) en estado `ACTIVE` pausada por excepción:

   ```
   Subir documentos GD: An error occurred while evaluating expression: docsResult:
   rule!SCA2_subirDocumentosGD(codSolicitud: pv!idSolicitud, listaNombreDocs: index(pv!resultado,"listaNombreDocs",{}), ...)
   (Expression evaluation error in rule 'sca2_subirdocumentosgd' at function a!forEach [line 23]: ... in rule
   'sca2_altadocumento' at function 'document' [line 27]: Document Does Not Exist or has been Deleted)
   ```

   `pv!resultado.listaNombreDocs = {"555703_8_15787714", "555704_7_15787714"}`. En SCA la pantalla es el
   formulario de una tarea y Appian consolida los ficheros de `a!fileUploadField` al enviar el formulario. En
   SCA2 la misma pantalla se muestra en una página del site (sin formulario): los ficheros quedan
   **temporales** y, al pasar sus ids como texto dentro de un `a!map` a `a!startProcess`, Appian no los
   persiste; cuando el PM los busca ya no existen. La misma excepción aparece en instancias de otras sesiones
   por la rama Contra Anulación (`11036933` → 15787716, `268956156` → 15787699), luego afecta a todas las
   pantallas SCA2 que adjuntan documentos.

   Corrección en `SCA2_AnulacionFueraNormaPrincipal` v15 (solo FINALIZAR):

   ```
   saveInto: if(local!faltaOficina, a!save(local!mensajeOficina, "Se requiere un valor"),
     if(a!isNullOrEmpty(local!listaNombreDocs),
       { /* insertarObservaciones + a!startProcess(SCA2_PM_CMD_COMPLETAR_ACCION, ...) + a!save(ri!onCompletar, true) */ },
       a!submitUploadedFiles(
         onSuccess: { /* mismo bloque */ },
         onError: a!save(local!mensaje, "No se han podido guardar los documentos adjuntos. Inténtelo de nuevo.")))),
   ```

   `POST /interfaces/{uuid}/test` con `idSolicitud 15787714 / idTarea 25` → 200, `error: null`. **La repetición
   UI de FINALIZAR con v15 + PM corregido queda pendiente**: 15787714 ya tiene la tarea `COMPLETADA` y su
   proceso pausado no puede reanudarse ni relanzarse por API (`POST /process-models/{uuid}/processes` → 501;
   no hay fila en `SCA2 Error` porque la excepción pausa el nodo en vez de ir al XOR «¿Docs GD ok?»), y no
   quedan pólizas asignadas.
3. Comportamiento de `SCA2_subirDocumentosGD` con ids inexistentes probado por LCP (`{"999999999_7"}`):
   devuelve `success=true, omitido=true, "Documento inexistente en Appian"`; con los ids reales del proceso,
   `CMP_existeObjeto` pasó pero `document()` en `SCA2_altaDocumento` falló, lo que confirma que el documento
   dejó de existir entre la subida y la ejecución del PM.

### 3.5 Adjuntos: solución final (v16 → v18) y permisos de la carpeta

- **v15/v16** (`a!submitUploadedFiles(onSuccess: …)` en FINALIZAR): la documentación oficial
  (`fnc_system_a_submituploadedfiles`) indica que `submit: true` y `a!submitUploadedFiles` en el mismo botón no
  funcionan; se pasó a `submit: false` (v16). Aun así el `onSuccess` no se disparaba: `SCA2_AccionesAdministrativasDocumentacion`
  vacía `local!documentosACargarN` al pulsar AÑADIR, así que en FINALIZAR no quedaba ningún fichero que consolidar
  (`documents:` vacío en v17).
- **Causa real**: la interfaz hija `SCA2_AccionesAdministrativasDocumentacion`
  (`_a-0000f069-4f37-8000-9cc8-011c48011c48_20060475`, **v3**, publicada por S3 durante la prueba) ya consolida cada
  fichero con `a!submitUploadedFiles(documents: tointeger(local!documento), onSuccess: …, onError: …)` en AÑADIR y
  MODIFICAR. Por eso la **v18** de `SCA2_AnulacionFueraNormaPrincipal` elimina el `a!submitUploadedFiles` de FINALIZAR y
  arranca el PM directamente con `local!listaNombreDocs` (ids ya persistentes):

  ```
  saveInto: if(local!faltaOficina, a!save(local!mensajeOficina, "Se requiere un valor"),
    { a!save(local!insertarObservacionesResponse, index(rule!SCA2_insertarObservaciones(..., tipoGestion: "7"), "success", false)),
      a!startProcess(processModel: cons!SCA2_PM_CMD_COMPLETAR_ACCION,
        processParameters: { idSolicitud: ri!idSolicitud, idTarea: ri!idTarea,
          resultado: a!map(listaNombreDocs: local!listaNombreDocs, tipoGestion: "AUT", nuuma: local!nuuma,
            mcaEstadoFinal: "S", codEstado: "2",
            mSEAceptarAutorizacion: { codSolicitud: ri!idSolicitud, fecAnulAutorizada: tostring(todate(local!fechaAnulacion)), infoUsuario: {...} },
            fechaAutorizada: tostring(todate(local!fechaAnulacion)), tipoAutorizacion: local!tipoAutorizacion,
            codGestion: local!codGestion, observaciones: local!observaciones, operacion: "Autorizacion",
            resultadoOperacion: "OK", poliza: local!numPoliza, ...) },
        onSuccess: {}),
      a!save(ri!onCompletar, true) }),
  submit: false,
  ```

- **Permisos**: al consolidar el fichero en AÑADIR (v17) apareció «No tiene privilegios suficientes para cargar un
  archivo en la carpeta designada»: la carpeta `SCA2 Autorizacion` solo tenía a `SCA2 Users` como Viewer y `JJGONZ2`
  pertenece a ese grupo. Se añadió `SCA2 Users` como Editor vía `GET/PUT /objects/{uuid}/security` (tabla §3). Con
  v18 + permisos, la instancia `537393666` (15787721) terminó `COMPLETED` con `docsResult.numSubidos=2`, `wrErr=false`.

### 3.6 FINALIZAR aceptaba pero no persistía la aceptación en CORE (2ª causa del PM)

Tras v18, 15787721 quedó con documentos, observación, gestión 7 `FINALIZADA` y record `PDTE_MECANIZAR`, pero
`SCA2_consultarAutorizacion` seguía `codEstado=1 / mcaAutorizada=N` y la tarjeta «Pendiente». Comparando con
`SCA Autorización`: SCA encadena `SCAC_aceptarAutorizacion` **y** el nodo «Actualizar Autorización»
(`SCA_guardarAutorizacion` con `mcaAutorizada = mcaEstadoFinal`, `codEstado`, `codGestion`, `tipoAutorizacion`,
`fecAnulAutorizada`, `infoUsuario`). `SCA2 CMD CompletarAccion` solo llamaba a la integración
`SCA2_aceptarAutorizacionIntegracion` (devuelve `true` pero no cambia el estado). Se añadieron los nodos 303-305
(tabla §3); expresión del nodo 303:

```
rule!SCA2_guardarAutorizacion(mseGuardarAutorizacionDTO: a!localVariables(
  local!r: pv!resultado, local!iu: a!defaultValue(index(local!r, "mSEAceptarAutorizacion", null).infoUsuario, a!map()),
  a!map(codSolicitud: pv!idSolicitud, codPca: null, descPca: null,
    mcaAutorizada: a!defaultValue(index(local!r, "mcaEstadoFinal", null), "S"),
    nivelIntervencion: tostring(a!defaultValue(index(index(pv!sol, "estado", null), "nivelIntervencion", null), 1)),
    numSgo: null, fecAnulAutorizada: index(local!r, "fechaAutorizada", null),
    infoUsuario: a!map(codCiaUsuario: index(local!iu, "codCiaUsuario", null), nuuma: index(local!iu, "nuuma", null),
                       codPerfil: index(local!iu, "codPerfil", null), codSubPerfil: index(local!iu, "codSubPerfil", null)),
    codEstado: a!defaultValue(index(local!r, "codEstado", null), "2"),
    codGestion: index(local!r, "codGestion", null), tipoAutorizacion: index(local!r, "tipoAutorizacion", null))))
```

- **Reparación de 15787721** (comprobación técnica, no UI): se ejecutó `SCA2_guardarAutorizacion` por LCP con el DTO
  anterior construido desde `pv!resultado` de la instancia `537393666` → `respuesta=true`; después
  `SCA2_consultarAutorizacion` devuelve `codEstado=2`, `mcaAutorizada=S`, `fecAnulAutorizada=30/09/2026`, y la gestión 7
  pasó a tener `fecFinGestion=30/09/2026 14:20:35`. La UI (SCA2 y SCA) muestra ahora «Aceptada/ACEPTADA» para 15787721.
- **Verificación punta a punta con 15787725** (alta nueva, sin intervención manual): instancia `17325403` de
  `SCA2 CMD CompletarAccion` (versión 30.0) `COMPLETED` en 14 s con `autRes.success=true`, `docsResult.numSubidos=2`
  (`idReferencia` GD `893601a0f24a3dfe`/`b8ca71a0f24a45c2`, `bbdd.success=true`), `wrErr=false`; estados en §4.4.

### 3.7 Buscador: «Pendiente» en lugar de `PDTE_MECANIZAR`

`SCA_BuscadorTabla` muestra el estado CORE (`SCA_D_EstadosSolicitud`: «Pendiente» mientras `codEstSolic=2`).
`SCA2_textoEstadoSolicitud` v7 (S3/S5) mapeaba los estados internos pero devolvía el literal `PDTE_MECANIZAR`; la
v8 devuelve «Pendiente» exactamente para ese estado y `SCA2_colorEstadoSolicitud` v3 le asigna `#E46B15`. Resto de
estados sin cambios (siguen mostrando «Solicitud Pendiente» donde SCA muestra «Pendiente»: se anota, no se toca).

### 3.8 POSPONER y SGC en Autorización

Decisión funcional recibida: «POSPONER debe registrar en SGC como SCA». Verificado en SCA que para **Autorización**
no ocurre: en `SCA Autorización` el XOR 19 «Posponer?» evalúa primero
`and(codEstado="1", or(a!isNotNullOrEmpty(idGestionSGC), idGestionSGC<>"0", perfil="CE_MF_SI24"))`, que con el
`idGestionSGC="0"` que devuelve CORE es verdadero y va al popup (nodo 21) sin pasar por el nodo 20 «posponer y
caducidad» (`SCA_posponerAutorizacion`). Lo confirman las instancias SCA de 15787698 (`16282489`, `521404`):
`cargaGestionPCA0=[]` e `idGestionSGC="0"` tras POSPONER. Por tanto en `SCA2 CMD Posponer` (v4 de S3, nodo 6) se
omite el alta SGC para `tipoAccion="AUT"` (comentario `[S4]` en la expresión, un solo término del `or()` para
activarlo si el analista decide lo contrario). La observación del POSPONER sí se inserta en CORE (nodo 7,
`tipoGestion "7"`): instancia v16 de 15787721 → `sgcRes.omitido=true`, `obsRes.success=true`, gestión 7
`observaciones="Prueba S4 posponer v15,Prueba S4 posponer v16"`.

### 3.9 Buscador: columna Observaciones (ronda 3)

Tras `git pull`, §9 del informe S1 documenta que `SCA2_BuscadorTabla` pasó a v6: «Fecha solicitud» =
`SCA2 Datos Solicitud.fecsolicitudanul` y «Observaciones» = `SCA2 Datos Solicitud.fecimpresion` (columna reutilizada, sin
columna propia), leídas por la relación `datosSolicitud` del record, y `SCA2 CMD Alta` (nodo 8 *Write Datos*) las
persiste en el alta. Verificado en la versión viva (v6, sin `-` fijo) y en UI: las filas 15787722/15787719 (S1) muestran
`Prueba S1 Devin ciclo3` / `Prueba S1 Devin ciclo2`. Sin embargo 15787725 y 15787721 seguían en `-`: el alta S4 no lleva
observación y la observación real (`Prueba S4 finalizar v19`) se insertó en CORE (`SCA2_insertarObservaciones`,
tipoGestion 7) pero no en el record; en SCA la columna es `txtObs` de `consultarUltimaGestion` (última observación de la
última gestión), por lo que sí la muestra. `SCA2_cargarSolicitud(15787725)` → `datosSolicitud.fecimpresion = null`.

Corrección (solo Autorización, sin tocar el buscador ni `CMD Alta`): `SCA2_AnulacionFueraNormaPrincipal` v18 → v19.
POSPONER y FINALIZAR persisten la observación en el record antes de arrancar el PM (`a!writeRecords` con `id` +
`fecimpresion`; según la documentación oficial del Write Records solo se escriben los campos informados):

```
local!idDatosSolicitud: index(index(local!sol, "datos", {}), "id", null),
...
if(or(a!isNullOrEmpty(local!observaciones), a!isNullOrEmpty(local!idDatosSolicitud)), {},
  a!writeRecords(
    records: 'recordType!{9a9209c7-…}SCA2 Datos Solicitud'(
      'recordType!{9a9209c7-…}SCA2 Datos Solicitud.fields.{2d7b6a31-…}id': local!idDatosSolicitud,
      'recordType!{9a9209c7-…}SCA2 Datos Solicitud.fields.{ef1b0aa7-…}fecimpresion': local!observaciones),
    onSuccess: {}, onError: {})),
a!startProcess(processModel: cons!SCA2_PM_CMD_POSPONER | cons!SCA2_PM_CMD_COMPLETAR_ACCION, ...)
```

Re-GET: v19, 3 inputs, 2 `a!writeRecords`; `POST .../test` con 15787725/15787721 → 200, `diagnostics.error=null`.
**No verificado en UI**: no queda póliza NSE cía 41 sin solicitud para un alta nueva y no se repite FINALIZAR sobre
solicitudes ya consumidas; 15787725/15787721 seguirán mostrando `-` en SCA2 (anteriores al fix). Pendiente de una
próxima ronda con póliza nueva.

### 3.10 Ronda 4: persistencia de la observación movida de la interfaz a los CMD

Decisión de diseño del lead: en SCA2 las escrituras de estado van en los CMD (atomicidad/idempotencia/trazabilidad), no en
las interfaces. Por ello:

- `SCA2_AnulacionFueraNormaPrincipal` v19 → **v20**: se elimina el `a!writeRecords` (expresión idéntica a la v18); POSPONER
  y FINALIZAR solo arrancan `SCA2 CMD Posponer` / `SCA2 CMD CompletarAccion`.
- `SCA2 CMD Posponer`, nodo 5 «Write Posponer» (Write Records, ya escribe `SCA2 Solicitud` + `Datos Basicos` + `Tarea` +
  `Transicion` en una transacción): se añade el registro

```
if(or(a!isNullOrEmpty(pv!motivo), a!isNullOrEmpty(index(index(pv!sol,"datos",null),"id",null))), {},
  'SCA2 Datos Solicitud'(id: index(index(pv!sol,"datos",null),"id",null), fecimpresion: tostring(pv!motivo)))
```

- `SCA2 CMD CompletarAccion`, nodo 5 «Write Tarea» (primera escritura tras «¿Ya ejecutado?», común a las tres acciones):
  mismo registro con `tostring(index(pv!resultado,"observaciones",null))`. Las tres interfaces (`SCA2_ContraAnulacionOpciones`
  «CA», `SCA2_AccionesAdministrativasPrincipal` «ACCADM», `SCA2_AnulacionFueraNormaPrincipal` «AUT») ya informan
  `resultado.observaciones`, así que la corrección es genérica sin tocar las interfaces de S1/S2/S3.
- Coordinación: GET vivo del `CMD CompletarAccion` tras el aviso de cierre de S5; nodo 340 «Write FINALIZADA_POSITIVO» con
  `estadoTarea: "COMPLETADA"` presente antes y después del PUT; 46 nodos / 17 pv, y todos los nodos distintos del 5
  idénticos byte a byte tras el re-GET. Backups en `~/sca2work/backup/pm/CMD_*.<ts>.before|after.json`.

Verificación (solicitud nueva **15787732**, póliza `2002000025123`, grabación `s4-v20`):

| Momento | Buscador SCA2 (Estado / Observaciones) | Buscador SCA | Igual |
|---|---|---|---|
| Tras POSPONER | «Solicitud Pendiente» / `Prueba S4 posponer v20` | «Pendiente» / `Prueba S4 posponer v20` | Observación sí; texto de estado no (mapeo S3/S5, ver §5) |
| Tras FINALIZAR | «Pendiente» / `Prueba S4 finalizar v20` | «Pendiente» / `Prueba S4 finalizar v20` | sí |

LCP: `SCA2_cargarSolicitud(15787732)` → `datos.fecimpresion = "Prueba S4 finalizar v20"`, `estadoSolicitud = PDTE_MECANIZAR`
(v6); `SCA2_consultarUltimaGestionREST` → `txtObs = "Prueba S4 finalizar v20"` (mismo valor que muestra SCA). Instancias:
`SCA2 CMD Posponer` 12088608 (v7.0) COMPLETED `wrErr=false`, `obsRes.success=true`, `sgcRes.omitido=true`;
`SCA2 CMD CompletarAccion` 9993801 (v32.0) COMPLETED `wrErr=false`, `autRes.success=true`, `docsResult.numSubidos=2`.
CORE: autorización `codEstado=2`/`mcaAutorizada=S`, gestión 7 FINALIZADA `15:15:19` con observaciones
`Prueba S4 posponer v20,Prueba S4 finalizar v20`, gestión 5 INCOMPLETA, 2 documentos (`0900ab4481a04e69`, `0900ab4481a04e67`),
`codEstSolic=2`. Detalle SCA2 tras F5: «Aceptada» verde, fecha fin, 2 docs, observaciones, Mecanizacion/Incompleta = SCA.

Solicitudes de otras sesiones (solo lectura, LCP): **15787728** (CA, S5): `fecimpresion = "Prueba S5 ciclo positivo Devin"` =
`txtObs` CORE (la observación del alta coincide con la última gestión) → columna ya informada. **15787720** (AccAdm, S3):
`fecimpresion = null` frente a `txtObs` CORE `Consulta NEW: codMotivo: 0001 …` (observación técnica del alta): la columna
solo se informará con un ciclo nuevo (POSPONER/FINALIZAR) que pase por los CMD corregidos; no se ha ejecutado ninguna
acción sobre ella.

### 3.11 Ronda 5: etiquetas del buscador, regla de Observaciones y popup de REASIGNAR

**Etiquetas de estado.** SCA tiene dos tablas con textos distintos: «Últimas solicitudes gestionadas» (`SCA_BuscadorTabla`,
también `SCA_TablaOtrasSolAnulación`) muestra `rule!SCA_D_EstadosSolicitud(codEstSolic)`; la pestaña Póliza
(`SCA_BuscadorTablaEstrategicas`) muestra `SCA_calcularEstadoSolicitud` («Solicitud Pendiente», «Finalizada positivo»…).
`SCA2_BuscadorTabla` y `SCA2_TablaOtrasSolAnulacion` son el port de la primera, pero `SCA2_textoEstadoSolicitud` (S3/S5) usaba los
textos de la segunda. `SCA_D_EstadosSolicitud` no está en ninguna aplicación LCP (73 revisadas); sus textos se obtuvieron por
`SCA2_calcularEstadoSolicitud` (rama por defecto) y por las evidencias de S1-S5: 1/2/7-10/13 → «Pendiente», 3 → «Finalizada
positivamente», 4/15 → «Finalizado negativo con contraanulación», 5 → «Finalizada no requerida contraanulación», 6/12 → «Caducada»,
14 → «Cancelada», 16/17 → «Pendiente de Autorizar», 18 → «Finalizado autorizado (sí anulada)», 19 → «Finalizada no autorizado (no
anulada)», 20 → «Caducada (poliza anulada)». Estados internos que escriben los PM de SCA2 (revisados los 13 PM): `ALTA` (CMD Alta),
`DECIDIDA`/`EN_DECISION`/`ERROR_DECISION` (Decidir), `EN_ACCION`/`PDTE_MECANIZAR`/`FIN`/`ERROR` (CrearAccion), `PDTE_FINALIZAR`/
`FINALIZADA_POSITIVO` (CompletarAccion), `FINALIZADA` (Finalizar), `MECANIZADA`/`CADUCADA` (Mecanizar/Caducar). `FIN` salía en crudo.

| Estado interno SCA2 | `codEstSolic` CORE equivalente (observado) | Texto v9 (= `SCA_D_EstadosSolicitud`) | Color |
|---|---|---|---|
| `ALTA`, `DECIDIDA`, `EN_DECISION`, `EN_ACCION`, `PENDIENTE`, `EN_PROCESO`, `PDTE`, `PDTE_FINALIZAR`, `PDTE_MECANIZAR`, `MECANIZADA` | 1/2 (S1-S5) | «Pendiente» | `#E46B15` |
| `PENDIENTE_AUTORIZACION`, `PENDIENTE_AUTORIZACION_ANULACION` | 16/17 (no observado; ningún PM los escribe) | «Pendiente de Autorizar» | gris (como SCA) |
| `FINALIZADA_POSITIVO` | 3 (15787728, 15787723) | «Finalizada positivamente» | `#008C47` (nuevo en v4) |
| `FINALIZADA`, `FIN`, `FINALIZADA_SIN_ANULAR` | 5 (15787702) | «Finalizada no requerida contraanulación» | `#BE0F0F` (nuevo en v4) |
| `RECHAZADA` | 4/15 (no observado) | «Finalizado negativo con contraanulación» | `#BE0F0F` (nuevo en v4) |
| `CANCELADA` / `CADUCADA` / `CADUCADA_NEGATIVA` | 14 / 6-12 | «Cancelada» / «Caducada» / «Caducada negativa» | sin cambios (`#9F9F9F`; SCA usa `#0D82BD`/`#734B30` en esta tabla — no tocado por indicación) |
| `ERROR`, `ERROR_DECISION` | sin equivalente SCA | sin cambios («Finalizada. Rechazada anulación», «Error en el servicio de decisión») | sin cambios |

Verificación UI (15787739): «Pendiente» naranja en SCA2 y SCA tras POSPONER y tras FINALIZAR; 15787728 «Finalizada positivamente» verde en
ambas. Divergencia conocida no tocada: 15787723 (S1) es «Finalizada positivamente» en SCA2 y «Pendiente» en SCA porque su record dice
`FINALIZADA_POSITIVO` y CORE `codEstSolic=2` (§35 del informe S1).

**Observaciones (regla exacta de SCA).** `SCA_BuscadorTabla` hace una única llamada `SCA_consultarUltimaGestionREST(nuuma)` (CORE
`consultarUltimaGestion/PCARAGE`) que devuelve una fila por solicitud con `numGestion`, `codObs`, `txtObs`, `estSolicitud`, `fechaResolucion`,
y la columna es `fv!row.txtObs`. Contrastando 10 solicitudes de S1-S5 con `consultaGestion`/`consultaDetalleGestion`: `txtObs` es la última
observación registrada en CORE (máx `codObs`) de cualquier gestión de la solicitud. Casos: 15787732 → gestión 7, «Prueba S4 finalizar v20»
(la de `guardarAutorizacion` es la última); 15787736 (AccAdm S3) → gestión 5 `43704927`, cuya observación es la traza «Consulta NEW: codMotivo:
0001 …» que CORE escribe al crear la mecanización en FINALIZAR (posterior a la observación del usuario de la gestión 3); 15787726 (CA negativa)
idem; 15787728/15787702 (CA positiva/cerrada, sin gestión 5) → observación del alta. Como la traza la genera CORE, no puede reproducirse desde
el record: `SCA2_BuscadorTabla` v7 replica la fuente de SCA (una llamada por carga, no por fila) y deja `fecimpresion` como respaldo.

```sail
/* SCA2_BuscadorTabla v7 (cabecera) */
a!localVariables(
  local!usuario: rule!SCA2_obtenerInformacionUsuario(),
  local!ultimas: a!defaultValue(rule!SCA2_consultarUltimaGestionREST(nuuma: reduce(index(_,_,null), local!usuario, {"infoUsuarioDTO", "nuuma"})), {}),
  local!ultimasIds: a!forEach(items: local!ultimas, expression: tostring(index(fv!item, "numSolicitud", null))),
  a!gridField_25r3( ...
    a!gridColumn(label: "Observaciones",
      value: a!localVariables(
        local!pos: wherecontains(tostring(<idSolicitud del record>), local!ultimasIds),
        local!txtObs: if(length(local!pos) > 0, index(index(local!ultimas, index(local!pos, 1, 0), null), "txtObs", null), null),
        if(a!isNotNullOrEmpty(local!txtObs), tostring(local!txtObs), <fecimpresion del record o "-">)))
```

Verificación UI: 15787739 «Prueba S4 posponer v21» / «Prueba S4 finalizar v21» en ambas; 15787736 muestra la misma traza «Consulta NEW …» en
SCA2 y SCA; ninguna de las 10 filas comparadas muestra `-` en SCA2 con texto en SCA.

**Popup de REASIGNAR.** `SCA_PopUpReasignarTarea` y `SCA2_PopUpReasignarTarea` son idénticos (NARROW / auto / NARROW). La diferencia estaba en
`SCA2_DetalleSolicitud`: hasta v24 la llamada estaba dentro de la 9ª columna del `a!columnsLayout` de botones; en la v28 viva (S2/S3) está al
nivel de la tarjeta de la gestión y el popup ocupa ~2/3 del ancho como en SCA (captura s4-407). No se ha tocado la interfaz. Diferencia menor
que queda: en SCA la tarjeta de botones se oculta mientras se muestra el popup (`showWhen: local!showPopupReasignar = false`); en SCA2 el botón
REASIGNAR sigue visible.

Procedimiento: GET vivo → backup (`~/sca2work/backup/ER_SCA2_textoEstadoSolicitud.v8.*.before.json`, `ER_SCA2_colorEstadoSolicitud.v3.*`,
`IF_SCA2_BuscadorTabla.v6.*`) → PUT → re-GET (v9/v4/v7, inputs conservados) → `POST /test` de las 13 ramas de estado y de la interfaz. Nota
de coordinación: `SCA2_DetalleSolicitud` estaba en v28 (última documentada: v27 de S2).

## 4. Estados CORE observados

### 4.1 Tras el alta (ambas apps)

`SCA2_consultarSolicitudes`: `codEstSolic = "2"`, `causaAnul = "ANULACIÓN FUERA DE NORMA"`,
`fecAnul = 30/09/2026`, `fecResolucion = null`.
`SCA2_consultaGestion`: acción 8 `FINALIZADA` (con `fecFinGestion`), acción 7 `codEstGestion = FINALIZADA`
con `fecFinGestion = null` (así lo devuelve CORE; no se reinterpreta), `nivelIntervencion = "1"`.
`SCA2_consultarAutorizacion`: `codEstado = "1"`, `mcaAutorizada = "N"`, `numSgo = "N"`, `tipoAutorizacion = "SI24"`.

### 4.2 Tras POSPONER

| Dato | SCA 15787698 (gestión 43704813) | SCA2 15787703 (gestión 43704820) |
|---|---|---|
| `codEstGestion` / `fecFinGestion` | FINALIZADA / null | FINALIZADA / null |
| `nivelIntervencion` | 1 | 1 |
| `observaciones` | `Prueba S4 posponer` | `null` tras el 1er POSPONER (divergencia) → `Prueba S4 posponer 2` tras la corrección v12 |
| `codEstSolic` | 2 | 2 |
| `SCA2 Solicitud` | n/a | `EN_ACCION` / `estadoTarea PENDIENTE` / `caducidadTarea 2026-10-07` / `contadorPosponer` incrementado / version 5 |
| `SCA2 Tarea` 20 | n/a | `PENDIENTE`, `asignadoA` vuelto a null (pool del grupo) |

### 4.3 Tras FINALIZAR

| Dato | SCA 15787698 | SCA2 15787703 (antes de corregir PM) | SCA2 15787714 (PM corregido, sin v15) |
|---|---|---|---|
| `SCA2_consultarAutorizacion.codEstado` / `mcaAutorizada` / `fecAnulAutorizada` | `2` / `S` / `30/09/2026` | `1` / `N` / null | `1` / `N` / null |
| Gestión 7 (`codEstGestion` / `fecFinGestion` / `observaciones`) | FINALIZADA / `30/09/2026 12:43:12` / `Prueba S4 posponer,Prueba S4 finalizar` | FINALIZADA / null / `Prueba S4 posponer 2` | FINALIZADA / null / `Prueba S4 finalizar v2` |
| Gestión 5 Mecanización | `43704856` INCOMPLETA, nivel 1 | no existe | no existe |
| `codEstSolic` / `fecAnul` | 2 / 30/09/2026 | 2 / 30/09/2026 | 2 / 30/09/2026 |
| `consultarDocumentos` | 2 documentos (tipos 7 y 8) | null | null |
| `SCA2 Solicitud` | n/a | `PDTE_MECANIZAR` / `procesoActivo MECANIZAR` / tarea PENDIENTE / version 7 | `EN_ACCION` / `AUTORIZACION` / version 3 |
| `SCA2 Tarea` | n/a | 20 `COMPLETADA` (+ tarea de mecanización) | 25 `COMPLETADA` |
| `SCA2 Transicion` (`SCA2_DetalleTransiciones`) | n/a | Alta, CrearAccion, Decidir, CompletarAccion→Decidir | solo Alta, CrearAccion, Decidir (ninguna de CompletarAccion) |
| `SCA2 Error` (`contarErroresPendientes`) | n/a | 0 | 0 |
| Instancia `SCA2 CMD CompletarAccion` | n/a | `15250872` COMPLETED (versión 12.0) | `17325135` ACTIVE, pausada en «Subir documentos GD» (versión 15.0) |


### 4.4 Ronda 2: 15787721 (v15…v18 + reparación) y 15787725 (v19 punta a punta)

| Dato | SCA 15787698 (referencia) | SCA2 15787721 | SCA2 15787725 |
|---|---|---|---|
| `SCA2_consultarAutorizacion.codEstado` / `mcaAutorizada` / `fecAnulAutorizada` | `2` / `S` / `30/09/2026` | `1` / `N` / null tras FINALIZAR v18 → `2` / `S` / `30/09/2026` tras `SCA2_guardarAutorizacion` por LCP (§3.6) | `2` / `S` / `30/09/2026 00:00:00` (solo UI) |
| Gestión 7 (`codEstGestion` / `fecFinGestion` / `observaciones`) | FINALIZADA / `12:43:12` / `Prueba S4 posponer,Prueba S4 finalizar` | FINALIZADA / `14:20:35` / `Prueba S4 posponer v15,Prueba S4 posponer v16,Prueba S4 finalizar v18` | FINALIZADA / `14:29:12` / `Prueba S4 finalizar v19` |
| Gestión 5 Mecanización | `43704856` INCOMPLETA | `43704882` INCOMPLETA | `43704888` INCOMPLETA |
| `codEstSolic` | 2 | 2 | 2 |
| `consultarDocumentos` | 2 (tipos 7 y 8) | 2: `0900ab4481a04e09` (7), `0900ab4481a04e07` (8) | 2: `0900ab4481a04e19` (7), `0900ab4481a047e3` (8) |
| `SCA2 Solicitud` | n/a | `PDTE_MECANIZAR` / `interfazActiva AUTORIZACION` / `procesoActivo MECANIZAR` / tarea PENDIENTE / version 7 / `idGestionSGC 233844122` | `PDTE_MECANIZAR` / `AUTORIZACION` / `MECANIZAR` / PENDIENTE / nivel 1 / `CE_RM` / version 5 |
| Instancia `SCA2 CMD CompletarAccion` | n/a | `537393666` COMPLETED (v26.0, 12 s): `docsResult.numSubidos=2`, `wrErr=false`; sin nodo 303 todavía | `17325403` COMPLETED (v30.0, 14 s): `autRes.success=true`, `docsResult.numSubidos=2`, `wrErr=false` |
| Bandeja `SCA2 Error` (`SCA2_Errores` por LCP) | n/a | sin filas para 15787721 | sin filas para 15787725 |
| Detalle SCA2 tras F5 | Aceptada, fecha fin, 2 docs, observación, Mecanización/Incompleta | Aceptada, `14:20:35`, 2 docs, observaciones, Mecanizar/Incompleta | Aceptada, `14:29:12`, 2 docs, `Prueba S4 finalizar v19`, Mecanizar/Incompleta |
| Detalle SCA (misma solicitud) | — | ACEPTADA, mismos docs/observación, Mecanizacion/Incompleta | ACEPTADA, mismos docs/observación, Mecanizacion/Incompleta |
| Buscador SCA2 / SCA | Pendiente / Pendiente | Pendiente (naranja) / Pendiente | Pendiente (naranja) / Pendiente |

### 4.5 Ronda 5: 15787739 (2002000062813)

- Alta 15:48:31 → `codEstSolic=2`; gestión 8 `43704933` FINALIZADA; gestión 7 `43704935` (autorización) abierta, nivel 1.
- Tras POSPONER (CMD Posponer v7.0, instancia `522219`, COMPLETED): observación «Prueba S4 posponer v21» en la gestión 7 y en `fecimpresion`; buscadores SCA2/SCA «Pendiente» + observación.
- Tras FINALIZAR (CMD CompletarAccion v32.0, instancia `14190911`, COMPLETED 15:54:44→15:54:55): autorización `codEstado=2`, `mcaAutorizada=S`, `fecAnulAutorizada=30/09/2026`, `codGestion=43704935`; gestión 7 FINALIZADA 15:54:54 con «Prueba S4 posponer v21,Prueba S4 finalizar v21»; gestión 5 `43704937` INCOMPLETA; `consultarDocumentos` → `893801a0f298b67b` (7) y `0900ab4481a0484f` (8); `consultarUltimaGestion` → `numGestion=43704935`, `codObs=41323178`, `txtObs="Prueba S4 finalizar v21"`; record `PDTE_MECANIZAR` / `AUTORIZACION` / `MECANIZAR` / `PENDIENTE` / nivel 1 / `CE_RM` / v6; `SCA2_BandejaErrores` y `SCA2_DetalleErrores(15787739)` sin filas.


## 5. Limitaciones y pendientes

- LCP: `GET /process-models/{uuid}/processes`, `GET /processes/{id}` y `GET /processes/{id}/variables`
  **sí funcionan** (lista de instancias, estado, error de pausa y `pv!`); en cambio `POST .../processes`,
  `/processes/{id}/errors|nodes|tokens|history` y `/runtime/processes` devuelven 501. Las acciones de negocio se
  han ejecutado por UI y la lectura de CORE/records por `POST /expression-rules/{uuid}/test`.
- **Resuelto en la ronda 2**: FINALIZAR punta a punta verificado con 15787725 (§3.5-§3.6, §4.4). La rama de error
  305 → `SCA2 Error` (`AUT_GUARDAR_FAIL`) no se ha podido provocar (no hubo fallo de `guardarAutorizacion`).
- 15787721 quedó Aceptada gracias a la ejecución técnica de `SCA2_guardarAutorizacion` por LCP (§3.6), no por
  la UI; 15787703 y 15787714 se dejan como evidencia (`PDTE_MECANIZAR` con autorización Pendiente en CORE;
  instancia `17325135` pausada: `POST .../processes` → 501, cancelar/reanudar requiere Designer).
- `a!submitUploadedFiles` en Contra Anulación / AccAdm: lo trasladan S1/S2/S3 (indicación del lead); la
  robustez de «Subir documentos GD» la asumió S5 (`SCA2_subirDocumentosGD` v3). No se han tocado.
- Buscador SCA2, columna Observaciones: **corregido en la ronda 4 en los CMD** (`SCA2 CMD Posponer` y
  `SCA2 CMD CompletarAccion`, nodo 5; §3.10) y verificado en UI con 15787732 (POSPONER y FINALIZAR). Las solicitudes
  anteriores al fix sin observación de alta (15787725, 15787721, 15787720 de S3) siguen en `-` hasta un ciclo nuevo.
- Tras POSPONER, el buscador SCA2 muestra «Solicitud Pendiente» (mapeo de S3/S5 en `SCA2_textoEstadoSolicitud`) donde SCA
  muestra «Pendiente»; solo `PDTE_MECANIZAR` se alineó en S4 (v8). Divergencia de texto pendiente en objeto compartido.
- Popup de confirmación de REASIGNAR en SCA2 muy estrecho (presentación; la reasignación funciona).
- Color del tag «Aceptada» en la tarjeta Autorización del Detalle SCA2: **corregido en la ronda 3**
  (`SCA2_DetalleSolicitud` v24, verde `#008C47` verificado en UI sobre 15787725 vs SCA 15787698). «Rechazada» sigue
  con el color por defecto (no probado en este escenario).
- Rama de error 305 → `SCA2 Error` (`AUT_GUARDAR_FAIL`) del `CMD CompletarAccion`: no provocada (aceptado por el lead).
- POSPONER/SGC en Autorización: decisión confirmada por el lead — SCA no da de alta SGC para autorización pendiente
  y SCA2 lo omite para `AUT` (§3.8); no se cambia.
- Estados distintos de `PDTE_MECANIZAR` siguen mostrando «Solicitud Pendiente» en el buscador SCA2 (S3/S5)
  donde SCA muestra «Pendiente»; no se ha modificado.
- No hay endpoint LCP de datos de record types (`/record-types/{uuid}/records` → 501): `SCA2 Tarea`
  y `SCA2 Transicion` se han observado a través de `SCA2_cargarSolicitud`, `SCA2_obtenerTareasSolicitudAlta`
  y de la UI; la bandeja `/errores` del site SCA2 devolvió 403 al usuario funcional, por lo que no se
  puede afirmar que no existan filas en `SCA2 Error` para estas solicitudes.
- `SCA2 CMD CambiarNivel` no está expuesto en ninguna pantalla de SCA ni de SCA2 en este flujo; el
  cambio de nivel no se ha podido probar de extremo a extremo (no existe la acción equivalente en SCA).
- SCA: tras POSPONER, RETOMAR desde el Detalle abre una tarea ya sustituida («La tarea solicitada no está
  disponible»); es comportamiento del SCA original, no se corrige.
- `SCA2 CMD Posponer` sigue llamando a `SCA2_insertarObservaciones` con `tipoGestion ""` (inocuo, falla
  siempre); conviene limpiarlo en el PM. SCA además registra el POSPONER en SGC
  (`SCA_posponerAutorizacion` → `SCA_guardarGestionSGC` con la oficina); SCA2 no llama a SGC al posponer
  (`SCA2_guardarGestionSGC` existe pero no se usa en `SCA2 CMD Posponer`). No se ha corregido: requiere
  decisión funcional (ver preguntas).
- Diferencias de presentación no corregidas (diseño propio SCA2 ya documentado): «Notificaciones» y
  «VOLVER AL DETALLE», ancho/distribución de cabecera, «Fecha estado» en otra columna, `-` en lugar de
  vacío para «Fecha fin de gestión».
- La versión 3 de `SCA2_selectorOficinas` estuvo rota unos minutos en TEST (afecta también a las pantallas
  de Acciones Administrativas y Contra Anulación de SCA2 que la reutilizan); se corrigió con la v4 y los
  cuatro casos de test (2 oficinas con/sin mensaje, 1 oficina, 0 oficinas) devuelven 200 sin error.
- Ronda 5: `SCA2_colorEstadoSolicitud` conserva `#9F9F9F` para «Cancelada»/«Caducada» (SCA usa `#0D82BD`/`#734B30` en `SCA_BuscadorTabla`); no se ha cambiado por indicación de no tocar la regla de color salvo lo imprescindible.
- Ronda 5: mapeos no observados en pruebas (`PENDIENTE_AUTORIZACION*`, `RECHAZADA`, `FINALIZADA_SIN_ANULAR`, `CADUCADA_NEGATIVA`) se han asignado por equivalencia de `codEstSolic` documentada, no por ciclo real.
- Ronda 5: la página `/errores` del site SCA2 sigue sin ser accesible para el usuario funcional («La página no existe o no tiene permiso»); la ausencia de errores se comprobó por LCP (`SCA2_BandejaErrores`, `SCA2_DetalleErrores`).
- Ronda 5: botón REASIGNAR visible mientras se muestra el popup de confirmación en SCA2 (SCA lo oculta); `SCA2_DetalleSolicitud` (v28, S3 activa) no tocada.
- Formato de «Fecha solicitud»: SCA `2026-09-30 15:48:31` (CORE) vs SCA2 `30/09/2026 15:48:31` (S1); no tratado en S4.

## 6. Evidencias (no incluidas en el repo)

Grabaciones (`~/screencasts/<nombre>/<nombre>-edited.mp4`, anotadas):

| Grabación | Contenido | Capturas |
|---|---|---|
| `s4-fase1` | Alta SCA 15787698 y SCA2 15787703, pantalla de autorización inicial (pestañas, documentos, tooltip), detalles cruzados, F5, bandeja `/errores` (403) | `s4-00` … `s4-20` |
| `s4-fase2a` | Detalle corregido (v5/v18), sin cambio de nivel, REASIGNAR/RETOMAR SCA, POSPONER SCA con validación de oficina, POSPONER SCA2 sin oficina (`CORRECTO`, divergencia), estados tras F5 | `s4-21` … `s4-47` |
| `s4-fase2b` | REASIGNAR/RETOMAR SCA2, POSPONER sin oficina con v2 del selector (sigue sin validar) | `s4-50` … `s4-57` |
| `s4-fase2b-continuacion` | POSPONER SCA2 con oficina + observación 2 (v12), RETOMAR SCA no disponible, error de expresión al volver en SCA, búsquedas cruzadas | `s4-58` … `s4-70` |
| `s4-fase3` | Validación oficina v13 en SCA2, FINALIZAR SCA (Aceptada, docs, fecha fin) y FINALIZAR SCA2 15787703 (`CORRECTO` pero Pendiente tras F5), buscador PDTE_MECANIZAR vs Pendiente | `s4-71` … `s4-91` |
| `s4-fase4` | Alta SCA2 15787714 con la reserva, FINALIZAR con PM corregido: `CORRECTO`, pero Pendiente tras >2 min; referencia SCA aceptada | `s4-92` … `s4-106` |
| `s4-v15` | Alta SCA2 15787721 (2002000045500), POSPONER v15 (observación en CORE, SGC omitido), RETOMAR | `s4-107` … |
| `s4-v16` | POSPONER v16 (`tipoAccion AUT`, obs OK), FINALIZAR v16: `CORRECTO` pero Pendiente (adjuntos no consolidados) | … |
| `s4-v17` | AÑADIR documento con v17: error de privilegios de carpeta | … `s4-140` |
| `s4-v18` | 2 documentos OK tras permisos, FINALIZAR v18 `CORRECTO`, Detalle (docs+obs, autorización aún Pendiente), buscador «Pendiente» SCA2 y SCA | `s4-141` … `s4-150` |
| `s4-v19` | 15787721 Aceptada tras la reparación (SCA2 F5 y SCA), alta 15787725 (2002000040119), 2 documentos, FINALIZAR v19 `CORRECTO`, Detalle F5 Aceptada + docs + obs + Mecanizar/Incompleta, buscadores, contraste SCA | `s4-151` … `s4-166` |
| `s4-v20` | Ronda 4, ciclo completo 15787732 (2002000025123): alta, Autorización, POSPONER «Prueba S4 posponer v20» → buscadores SCA2/SCA con la observación, REASIGNAR/RETOMAR, 2 documentos, FINALIZAR «Prueba S4 finalizar v20» `CORRECTO`, Detalle F5 Aceptada verde + docs + obs, buscadores con la última observación, contraste SCA | `s4-301` … `s4-311` |
| `s4-v24` | Ronda 3 (solo lectura): Detalle SCA2 15787725 tras F5 con tag «Aceptada» verde `#008C47` + 2 docs + obs + Mecanizar/Incompleta; Detalle SCA 15787725 y 15787698 (mismo verde); buscadores SCA2/SCA filas 15787725 y 15787698 («Pendiente» naranja; Observaciones `-` en SCA2 vs `txtObs` en SCA; 15787722/15787719 de S1 con observación en SCA2) | `s4-201` … `s4-207` |
| `s4-v21` | Ronda 5, ciclo completo 15787739 (2002000062813): alta, Autorización, POSPONER «Prueba S4 posponer v21» → buscadores SCA2/SCA («Pendiente» + observación, filas «Finalizada positivamente»), REASIGNAR (popup a lo ancho), RETOMAR, 2 documentos, FINALIZAR «Prueba S4 finalizar v21», Detalle F5 Aceptada, buscadores v7 con la traza CORE de 15787736 en ambas apps, `/errores` inaccesible | `s4-401` … `s4-414` (`~/sca2work/s4-v21-capturas.zip`; grabación `~/screencasts/s4-v21/s4-v21-edited.mp4`) |

Capturas: `~/sca2work/capturas/s4-NN-<app>-<pantalla>.png` (también en `~/sca2work/s4-faseN-capturas.zip` y
`~/sca2work/s4-vNN-capturas.zip`).
Estados de procesos: `~/sca2work/proceso_<id>.json` y `procesos_completaraccion.json`. SAIL antes/después:
`~/sca2work/live/`, `~/sca2work/backup/`.

## 7. Preguntas para el analista

- POSPONER/SGC: SCA **no** da de alta SGC al posponer una autorización pendiente (§3.8) y así se ha dejado SCA2
  (omisión para `AUT`). Si el analista quiere que SCA2 sí lo haga (a diferencia de SCA), basta quitar
  `local!esAutorizacion` del `or()` del nodo 6 de `SCA2 CMD Posponer`; el payload AUT ya está preparado.
- Buscador SCA2, columna Observaciones: resuelto de forma genérica en los CMD (§3.10). Queda por decidir si las
  solicitudes anteriores al fix (p. ej. 15787720 de S3) deben rellenarse desde CORE o se dejan hasta su próximo ciclo.
- Ronda 5: Observaciones del buscador se leen ahora de CORE con una llamada por carga (misma fuente y regla que SCA, §3.11). Si se prefiere no depender de CORE en el buscador, la alternativa es mantener `fecimpresion` y aceptar la divergencia de la traza técnica en AccAdm/CA negativa.
- Ronda 5: ¿alinear también los hex de «Cancelada»/«Caducada» de `SCA2_colorEstadoSolicitud` con `SCA_BuscadorTabla` (`#0D82BD`/`#734B30`)? Y ¿ocultar el botón REASIGNAR mientras se muestra el popup, como SCA?
