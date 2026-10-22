# Paridad funcional Appian–SPA

Este documento registra la correspondencia funcional de las pantallas de PGM cuya cadena de llamadas está viva en `analysis/refs.json`. El inventario Appian se obtuvo de `obj/INTERFACE/*.json`, retirando antes los comentarios `/* ... */`. Una interfaz se considera viva solo si una cadena de referencias parte de `PGM_R_recordViewFichaCliente`, `PGM_FichaCliente_v2` o de la página del site correspondiente.

## Cabecera de cliente

`PGM_FichaCliente_v2` llama directamente a `PGM_FichaCliente_Header_ParteSuperior_Nuevo_v2` en la rama `not(a!isPageWidth("PHONE"))` y a `PGM_FichaCliente_Header_ParteSuperior_Mobile` en `PHONE`. La parte inferior `PGM_FichaCliente_Header_ParteInferior_v2` se llama para `DESKTOP` y `DESKTOP_WIDE`; `PGM_FichaCliente_Header_Palancas_v2` y las secciones de prima/posición se muestran según `headerDetallado`. La variante antigua `PGM_FichaCliente_Header_ParteSuperior_Nuevo` también es alcanzable desde la ficha por la cadena de detalle de prestaciones (`PGM_FichaCliente_SeccionPrestaciones_v2` → `PGM_VerDetalle_Header`), pero no sustituye al selector principal de cabecera. `PGM2_FichaCliente_Header_ParteSuperior_Nuevo` no tiene cadena de llamadores viva.

| Appian (interfaz viva) | SPA | Estado |
|---|---|---|
| `PGM_FichaCliente_Header_ParteSuperior_Nuevo_v2` (ancho distinto de PHONE) y `PGM_FichaCliente_Header_ParteSuperior_Mobile` (PHONE) | Cabecera adaptable, datos de contacto y acciones de cliente | diferencia: la SPA comparte el mismo contenido adaptable en lugar de dos plantillas SAIL |
| `PGM_FichaCliente_Header_Palancas_v2`: DNI, RGPD, ACI, En Familia, Plan de pagos y ClubMAPFRE; en la SPA se omiten DpV y Cliente Total como palancas generales | Los cinco indicadores con su estado; ClubMAPFRE muestra «No disponible» al faltar origen; Cliente Total solo se presenta para empresa con el indicador activo | diferencia: algunas condiciones de `headerDetallado` y valores de palanca no están disponibles en el contrato SPA |
| `PGM_FichaCliente_Header_PrimasYDescuentos` / parte inferior: «Descuento vinculación», «Total prima (Tomador/Titular)» y «Posición bancaria» | Mismos literales y orden; los campos sin origen presentan «No disponible» | diferencia: el contrato local no provee todos los valores de Appian |
| `PGM_FichaCliente_Header_ParteSuperior_Nuevo_v2`: «Alertas urgentes» con `showWhen` de SGC habilitado y `local!totalAlertas > 0`; «Avisos e interacciones» con `showWhen: local!totalAvisosImportantes > 0` | Acciones condicionadas por permiso SGC y alertas disponibles; la segunda se muestra solo cuando hay alertas disponibles | diferencia: el contrato de alertas no distingue interacciones de avisos ni sus contadores |
| `PGM_FichaCliente_Header_ParteSuperior_Nuevo_v2`: «Métodos de contacto cliente», «Nuevo email», «Nuevo fijo», «Nuevo móvil» | Sección desplegable con los mismos literales; fijo sin origen indicado como «No disponible» | diferencia: la SPA no tiene el flujo de edición de métodos de contacto de Appian |
| `PGM_FichaCliente_Header_ParteSuperior_Nuevo_v2`: acción de refresco | «Refrescar ficha» recarga los datos del cliente | igual |

## Ficha de póliza y recibo

| Appian (interfaz viva) | SPA | Estado |
|---|---|---|
| `PGM_FichaPoliza` → `PGM_FichaPoliza_DetalleAutos`: `PGM_Detalle_Autos_Riesgo`, `PGM_Datos_Tomador_Detalle_Autos`, `PGM_Detalle_Autos_Garantias`, `PGM_Detalle_Autos_Intervinientes`, `PGM_TablaRecibos`, `PGM_TablaPrestaciones` | Pestañas Vehículos, Coberturas, Intervinientes, Recibos y Prestaciones; etiquetas, cajas y columnas SAIL | igual |
| `PGM_FichaPoliza` → `PGM_FichaPoliza_DetalleSalud`: tomador, intervinientes, coberturas y tablas de recibos/prestaciones | Contenido por pestaña según las interfaces hijas vivas | igual |
| `PGM_FichaPoliza` → `PGM_FichaPoliza_DetalleVida`: intervinientes, estructura comercial, coberturas, recibos, prestaciones, documentos y Primas condicional | Contenido por pestaña y condición de Primas según SAIL | igual |
| `PGM_FichaPoliza` → `PGM_FichaPoliza_DetalleGenerica` | Recibos y Prestaciones con columnas de `PGM_TablaRecibos` y `PGM_TablaPrestaciones` | igual |
| `PGM_FichaPoliza` → Hogar: la llamada a `PGM_Hogar_Principal` está comentada | Solo cabecera de póliza, sin detalle ni pestañas de Hogar | igual |
| `PGM_Ficha_Recibo` / `PGM_RecibosMenu`: «Datos Generales», «Desglose económico», «Gestiones»; pagador en `PGM_PopUp_RecibosMenu` | Pestañas del recibo y datos del pagador | igual |

## Gestión comercial → Vencimientos

La cadena viva es `PGM_FichaCliente_v2` → `PGM_iMediador_Gestiones` (rama Vencimientos) → `PGM_ResumenVencimientos` → `PGM_FiltrosVencimientos_V2` y `PGM_TablaVencimientos_V2`. El desplegable de estado de `PGM_iMediador_Gestiones` está condicionado a la rama Gestiones, no a Vencimientos.

| Appian (interfaz viva) | SPA | Estado |
|---|---|---|
| `PGM_TablaVencimientos_V2`: «Venc. / Oport.», «Clase de Vcto.», «Producto / Riesgo», «F. Venci. / Opor.», «Prima / Saldo», «Entidad competencia», «Usuario», «Comentarios», «Anexos» | Las mismas columnas en el mismo orden | igual |
| `PGM_FiltrosVencimientos_V2`: «Todos», «Completo», «Incompleto»; filtros Producto, Tipo Acción, Desde, Hasta y Contratado; botones «Limpiar» y «Ver resultados» | Se conservan esos controles y filtros | igual |
| En la rama viva no hay acción de alta «+ Vencimiento» en `PGM_ResumenVencimientos`, `PGM_FiltrosVencimientos_V2` ni `PGM_TablaVencimientos_V2` | Se retira el botón de alta de la barra SPA | igual |

## Páginas del site

Los destinos se resuelven usando los códigos de lanzadera ya configurados en Configuración (`NSE`, `NSE_HOGAR`, `GESALUD`, `GESVIDA`, `PORTAL_INTERNO`, `CITRIX`, entre otros). La SPA no añade URL propia: si falta código, URL válida o NUUMA requerido, presenta el acceso deshabilitado con el motivo.

| Appian (interfaz viva) | SPA | Estado |
|---|---|---|
| `PGM_GestionDeCartera`: Agropecuario, Automóviles, Empresas, Patrimoniales, Salud, Vida; contenido de las interfaces hijas correspondientes | Barra de seis pestañas, tarjetas/enlaces con su interfaz de origen y lanzadera | diferencia: las tarjetas sin lanzadera configurada se muestran deshabilitadas |
| `PGM_PrestacionesYSiniestros`: Automóviles y Salud | Barra de dos pestañas y accesos de `PGM_PrestacionesYSiniestros_Autos` / `PGM_PrestacionesYSiniestros_Salud` | diferencia: los accesos sin lanzadera válida están deshabilitados |
| `PGM_BarraPrincipal_Imagenes` → Nueva Producción: Agropecuario, Ahorro, Automóviles, Empresas, Patrimoniales, Salud, Vida | Barra con el mismo orden; Salud muestra Particulares; Vida muestra Particulares y Colectivos; tarjetas de sus interfaces hijas | diferencia: los destinos que no existen en Configuración se presentan deshabilitados |

## Interfaces no migradas

Los siguientes elementos no tienen una cadena de llamadores viva desde las raíces de ficha/site, o su único padre está muerto. No se trasladan a la SPA.

| Appian (interfaz) | SPA | Estado |
|---|---|---|
| `PGM_Autos_Info_General_v2` / `Autos_Info_General_v2`, `PGM_Autos_Info_Riesgo` / `Autos_Info_Riesgo`, `PGM_Inf_General_Auto_FigurasTomador` / `Autos_FigurasTomador` | Sin pantalla SPA | no migrado: código muerto |
| `PGM_Hogar_Principal` y sus hijas de riesgo, figuras, coberturas, pagos, recibos, autorizaciones e información general (incluidas `PGM_Hogar_Riesgo_Principal`, `PGM_Hogar_Figuras`, `PGM_Detalle_PolizaHogar_Vivienda`, `PGM_Detalle_PolizaHogar_Tomador` y `PGM_Hogar_Inf_General_Detalle_Observaciones`) | Sin detalle Hogar (la llamada del dispatcher está comentada) | no migrado: código muerto |
| `PGM_ConsumoProtegido_Principal`, `PGM_HipotecaSegura_Principal` | Sin pantalla SPA | no migrado: código muerto |
| `PGM_TablaSGO` | Sin tabla SPA; no se encontró caller vivo | no migrado: código muerto |
| `PGM2_FichaCliente_Header_ParteSuperior_Nuevo` | No se usa en la selección de cabecera viva | no migrado: código muerto |

Las interfaces hijas usadas por una pantalla viva no se clasifican como código muerto aunque tengan otros llamadores no migrados. La existencia de referencias a reglas auxiliares o constantes, por sí sola, no se considera una ruta viva desde una raíz.
