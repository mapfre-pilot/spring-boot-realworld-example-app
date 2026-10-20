# PGM — Matriz global Appian (TEST) ↔ nueva aplicación (pgm-spa + pgm-bff)

Consolidación de las seis rondas de pruebas funcionales sobre `PGM_MAPFRE` en Appian **TEST** (usuario `devin`, solo lectura salvo las incidencias de §4) y del estado de paridad en la nueva aplicación de la rama `feature/pgm` tras los bloques de código posteriores a las pruebas. Las matrices detalladas pantalla a pantalla están en cada área:

| Área | Alcance | Informe | Filas matriz | Casos (OK / KO / bloqueados) | Capturas |
|---|---|---|---|---|---|
| A | Inicio, buscador, cabecera de la ficha y ACCIONES | [`A-inicio-cabecera/informe.md`](A-inicio-cabecera/informe.md) | 34 | 39 (30 / 2 / 7) | 37 |
| B | Pólizas, recibos y prestaciones | [`B-polizas-recibos-prestaciones/informe.md`](B-polizas-recibos-prestaciones/informe.md) | 21 | 39 (22 / 0 / 17) | 29 |
| C | Vto./Ppto., tarificación Salud, Nueva producción, Gestión de cartera, lanzaderas | [`C-vto-ppto-lanzaderas/informe.md`](C-vto-ppto-lanzaderas/informe.md) | 18 | 20 (14 / 0 / 6) | 24 |
| D | Gestión comercial, Cuadro de Mando, Utilidades, SGO, Click2Call | [`D-gestion-comercial-cdm-utilidades/informe.md`](D-gestion-comercial-cdm-utilidades/informe.md) | 29 | 32 (21 / 0 / 11) | 10 |
| E | Dependencias técnicas (30 connected systems, 208/211 integraciones, 9 Web APIs, 127 PM) | [`E-dependencias-servicios/informe.md`](E-dependencias-servicios/informe.md) | — | 14 (9 / 3 / 2) | — |
| F | Re-test con perfil comercial (NUUMA `JZAHONE` vía `PGM_Alertas`) | [`F-perfil-comercial/informe.md`](F-perfil-comercial/informe.md) | 23 | 34 (24 / 2 / 8) | 47 |
| **Total** | | | **125** | **178 (120 / 7 / 51)** | **147** |

Los «KO» son defectos observados en Appian (p. ej. la búsqueda por teléfono «123» no valida formato y abre una ficha por coincidencia parcial; integraciones 501 en LCP), no de la nueva aplicación. Los «bloqueados» son por datos inexistentes en TEST, permisos/grupos o red (DNS a `*.pre.mapfre.net` desde la VM), y se listan en [`requisitos-pruebas-servicios.md`](requisitos-pruebas-servicios.md).

## 1. Estado de paridad por bloque funcional

Leyenda: **cubierto** = misma funcionalidad y textos literales, probado con el BFF local; **parcial** = pantalla/operación presente con parte de los campos o sin el contrato real; **falta** = no implementado; **n/a** = no se replica por decisión (lanzaderas a aplicaciones externas que siguen existiendo).

| Bloque (Appian) | Área | Estado nueva app | SPA (ruta / componente) | BFF (operación OpenAPI) | Observaciones |
|---|---|---|---|---|---|
| Inicio: buscador con 13 criterios, matriz de compatibilidad Documento/Nombre, validaciones literales (`PGM_EsValidaBusquedaCliente`), límite 100 → «demasiados resultados» | A | **cubierto** | `/inicio` `InicioPageComponent` | `buscarClientes` (422 `demasiados-resultados`) | Grid con nombre, documento, fecha nacimiento, domicilio, CP, estado, Robinson |
| Inicio: CTA «Alta cliente», Ficha Ampliada, Bandeja SGO, 6 enlaces de interés | A | **cubierto** | `/inicio` | — (enlaces) | Bandeja SGO como enlace al site SGO (es una app Appian distinta, F-03) |
| Inicio: caja de aviso «perfil iMediador» y selección de estructura | F | **falta** | — | `obtenerContexto` devuelve una sola estructura | Requiere lista de perfiles iMediador del usuario (`/api/1.0/perfil`); pendiente contrato |
| Cabecera de ficha: nombre, documento, tipología, VIP/Robinson/exclusivo corredor, teléfono/email, alertas, palancas con textos literales | A | **cubierto** | `/clientes/:id` `IndicadoresClienteComponent` | `obtenerFichaCliente` | Palancas: DNI, RGPD, ACI («Potencial»), En Familia, Plan de pagos, Cliente Total, DpV |
| Cabecera: aviso RGPD, descuento de vinculación, prima total | A | **parcial** | `/clientes/:id` | `obtenerFichaCliente` | Prima total calculada desde productos; faltan textos de `PGM_FichaCliente_Header_PrimasYDescuentos` por tipología |
| Menú ACCIONES: Más datos cliente (3 pestañas + modificar contacto), Centro de comunicaciones (30D/12M/3A), Consulta y descarga de documentación | A, F | **cubierto** | `AccionesClienteComponent` | `masDatosCliente`, `actualizarContactoCliente`, `centroComunicaciones`, `consultaDescargaDocumentacion` | Contratos reales de Clients EDGE/Client API pendientes (cuerpos sintéticos en simulador) |
| ACCIONES con NUUMA: Inducir, Contacto Personal (SGC 2.0), SVA | F | **cubierto** | `AccionesClienteComponent` (solo con NUUMA) | `inducirCliente` (reglas Robinson / sin contacto) | URLs SGC 2.0/SVA por entorno (`PGM_URL_*`) |
| Palancas → acciones: Digitalizar DNI, Firmar RGPD (métodos según móvil/email), Solicitar alta en ACI, Plan de pagos › Simular, Alta Cliente Total (+ empresas vinculadas), Ver familia | A | **cubierto** (familia: parcial) | `AccionesClienteComponent` | `solicitarDigitalizacionDni`, `metodosFirmaRgpd`, `firmarRgpd`, `solicitarAltaAci`, `planPagos`, `simularPlanPagos`, `clienteTotal`, `anadirEmpresaVinculada` | En Appian estas acciones arrancan procesos con tarea; en la nueva app son operaciones del BFF con `Idempotency-Key`. Familia: lectura sí; crear/dar de baja familia **falta** (ver incidencia FAM1377681) |
| Resumen: carrusel por ramo con conteos y «+ Vto./Ppto.» | B, C | **parcial** | `CarruselRamosComponent` | `listarProductosCliente` | Falta la agregación por *agrupación* de ramo según tipo de cliente (códigos de agrupación de Appian) |
| Posición › Productos: tabla con estado, filtro En vigor/Anulados/Todos, filtro por ramo, exportar | B | **cubierto** | `/clientes/:id` pestaña Posición | `listarProductosCliente` | Faltan figura/interviniente y nº de suplementos (no vienen en el contrato propuesto) |
| Posición › Estados anteriores | B | **cubierto** | subpestaña «Estados anteriores» | `estadosAnterioresCliente` | Datos anulados/suspendidos: no hay en TEST, simulados en local |
| Tabla productos › «Acciones» → diálogo con cards por cia+ramo e `IR` (9 Autos, 3 Vida, SGO, Documentación de emisión) | B | **cubierto** | `/polizas/:numero` diálogo Acciones | `accionesPoliza` (WLCatalog vía Gateway), `documentosPoliza` | URLs de PRE observadas; parametrización por entorno con `PGM_URL_APPS`; `inicioExterno` cifrado de SGO pendiente |
| Ficha de póliza: Resumen Póliza + bloques por ramo (Vida/Ahorro garantías y beneficiarios; Autos vehículo/conductores; Hogar vivienda); restricción Autos/Hogar por `PGM_USUARIOSGRUPOTRABAJO` / `PGM_GR_DETALLEHOGAR` | B | **cubierto** (contratos por ramo pendientes) | `/polizas/:numero` | `fichaPoliza` (403 literal), `detallePolizaRamo` | Motor API / Health API / Life API detrás del Gateway: cuerpos sintéticos |
| Recibos: lista cliente/póliza, filtros, exportar | B | **cubierto** | `/recibos`, `/clientes/:id`, `/polizas/:numero` | `listarRecibosCliente`, `listarRecibosPoliza` | Faltan producto/riesgo en la lista (sí en el detalle) |
| Recibo › menú ⋮: Consulta Recibos (ConsuWeb), Visualizar duplicado (NUUMA), Detalle (flag `PGM_visualizacionRecibos`) | B | **cubierto** | `/recibos/:numero` | `accionesRecibo`, `duplicadoRecibo`, `detalleCompletoRecibo` | GESYC `consultarRecibo`/`imprimirRecibo` SOAP→REST en Gateway |
| Recibos › operativas modificadoras (cobro, agrupar, plan de pagos, cambio forma de pago, envío al banco/centro de recibos) | B | **n/a (decisión)** | — | — | En Appian TEST no están en la UI (se hacen en ConsuWeb); si se quieren en la nueva app hay que exponer los servicios GESYC y definir contratos |
| Prestaciones: lista y detalle de expediente (flag `PGM_CONS_VER_DETALLE_PRESTACIONES`) | B | **cubierto** | `/prestaciones`, `/prestaciones/:numero` | `listarPrestacionesCliente`, `detallePrestacion` | METS vía Gateway; sin clientes con prestaciones en TEST |
| Vto./Ppto.: diálogo «Añadir Vencimiento / Presupuesto», bloqueo literal sin perfil, selector Perfil Comercial, tipo de vencimiento | C, F | **parcial** | `/clientes/:id` Gestión comercial › alta | `crearOportunidad` (PGO `/apipgo/opportunity/incomplete`) | Formulario genérico; **faltan los 17 subformularios por ramo** (`PGM_AltaVencimientos_<ramo>`) y la pestaña Presupuesto (`RM Usuarios`) |
| Tarificación Salud (cotización, borradores) | C | **cubierto** (local) | `/clientes/:id` tarificación | `cotizarSalud`, borradores | Health API 1.0 (`/1.0/health/quote`…) según PROD-APICANAL-VENTAS-001 |
| Gestión comercial › Vencimientos (filtros, contadores Todos/Completo/Incompleto, detalle, observaciones, documentos) | D, F | **cubierto** | `GestionComercialClienteComponent` | `oportunidades`, `resumenOportunidades`, `detalleOportunidad`, observaciones | Sin cliente con PGO en TEST: detalle documentado desde SAIL |
| Gestión comercial › Actividad comercial (filtros, aviso RGPD, «Nueva actividad alcanzada» con catálogo NGA) | D, F | **cubierto** | idem | `actividadComercial`, `crearActividad`, `catalogo` | Catálogo de 14 tipos observado en F; el BFF lo sirve por `catalogos-comerciales/{tipo}` |
| Gestión comercial › Gestiones SGC 3.0 (tabla, detalle, cerrar/reabrir, observaciones, WhatsApp) | D, F | **cubierto** (diálogos Agendar/Asignar **falta**) | idem | `gestiones`, `detalleGestion`, `cerrarGestion`, `reabrirGestion` | Permiso VIEW de SGC 3.0 por NUUMA; la API devuelve más gestiones que la UI (filtro por estado) |
| Degradación por perfil: «Esta acción aún no está disponible en PGM para tu usuario (X)», «No tienes permiso para ver las gestiones», «Puedes realizarla desde SGC 2.0» | D | **cubierto** | idem | 403 RFC 9457 con el texto literal | Modelo de autorización perfil × NUUMA × perfil SGC 3.0 × flags |
| Nueva producción / Gestión de cartera / Prestaciones / Recibos por ramo (lanzaderas NSE, GESALUD, GESVIDA/WEBVIDA, Portal Interno, Citrix) | C | **cubierto** (enlaces) | `/nueva-produccion`, `/gestion-cartera`, … | `listarLanzaderas` | Sin parámetros de expediente/póliza en algunas lanzaderas; red a `*.pre.mapfre.net` |
| Gest. Comercial (tarjetas), Utilidades (tarjetas), SGO (solicitudes/documentos) | D, F | **cubierto** | `/gestion-comercial`, `/utilidades` | `listarLanzaderas`, `solicitudesSgo`, `documentosSgo` | SGO SOAP→REST en Gateway |
| Cuadro de Mando | D | **parcial** | `/cuadro-mando` | `listarKpis` | Sin datos en TEST; KPIs sintéticos |
| Click2Call | D | **cubierto** (flag) | cabecera (teléfono) | `clickToCall` | Broadsoft `callmenow` por NUUMA |
| «Nueva producción desde la ficha» | C | **retirado** | — | — | No existe en Appian (el menú ⋮ solo tiene Más datos, Centro de comunicaciones y CDD); se eliminó como requisito |

## 2. Gaps pendientes de implementar (orden propuesto)

1. Subformularios de alta de vencimiento por ramo (17) y pestaña Presupuesto del diálogo «Añadir Vencimiento / Presupuesto» (F-11…F-15). Dependen del contrato PGO `incomplete`/`complete` por ramo.
2. Selector de perfil iMediador en Inicio y en el alta de vencimiento (F-01, F-13): contrato iMediador `/api/1.0/perfil` + estructura.
3. Diálogos Agendar / Asignar de gestión SGC 3.0 (F-10) y permiso VIEW.
4. Agrupación de ramos del carrusel por tipo de cliente (B-01) y figura/interviniente en productos (B-02).
5. Crear / dar de baja familia y gestión de miembros (A, «En Familia › Ver más»).
6. Operativas de recibos (B-14) **solo si se decide** que la nueva app las cubra.

## 3. Correcciones al análisis funcional derivadas de las pruebas

- No existe «Nueva producción desde la ficha» (C).
- La búsqueda por teléfono no valida formato en Appian (A, KO funcional): la nueva app sí valida (`Formato de número de teléfono inválido`) — decisión consciente de mejora, no de paridad.
- El bloqueo de Gestiones/Actividad/Vto. depende del **perfil SGC 3.0 por NUUMA y de la estructura comercial** (iMediador), no de los grupos Appian (D, F). El BFF lo modela así.
- En TEST el NUUMA se asigna fijo (`JZAHONE`) a `PGM_Alertas` / `PGM_CONS_USUARIOS_NEGOCIO`; en PRO viene del perfil real (E).
- Appian TEST consume los legacy de **PRE**; las URL de PRO no constan salvo Citrix (E).
- `PGM_Mostrar_ExclusivoCorredor=false`, `PGM_mostrarDPVE=false`, `PGM_visualizacionRecibos=false`, `PGM_CONS_VER_DETALLE_PRESTACIONES=false` en TEST → en la nueva app son feature flags (`pgm.features.*`).

## 4. Incidencias de las pruebas (efectos colaterales en TEST)

| Área | Qué ocurrió | Estado | Decisión pendiente |
|---|---|---|---|
| A | «CREAR FAMILIA» (En Familia › Ver más) creó la familia **FAM1377681** para 15930307R (inactiva, único miembro, sin firmar) | Sin tocar | Dar de baja desde «Dar baja familiar» o dejar |
| F | «DAR DE ALTA CONTACTO» creó el contacto comercial **35298931** (NUUMA JZAHONE) en 71913797L | Sin tocar | Borrar desde SGC 2.0 o dejar |
| Previa | Digitalizar DNI / Firmar RGPD / Alta ACI / Alta Cliente Total arrancaron 4 instancias de proceso con tarea (15930307R), cerradas sin enviar | Aceptado por el owner | — |
| E | Evaluación LCP escribió 3 filas en la caché técnica `PGM_R_cliente_record_postgres` (38859674, 38903733, 9198551) | La purga el proceso de caché | — |
| — | `devin` añadido a `PGM_AsesorComercial`, `PGM Visualizar CdM`, `PGM_Alertas` (autorizado); el LCP no permite retirarlo | Pendiente de retirar por Designer | Retirar o dejar |
