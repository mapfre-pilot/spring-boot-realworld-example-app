# PGM (Portal de Gestión MAPFRE) — Análisis funcional

> Fuente: aplicación Appian `PGM_MAPFRE` en TEST (`mapfrespain-test.appiancloud.com`, site `pgm-mapfre`), explorada en modo solo lectura el 19/10/2026, más la descripción de PGM en `ARCH-APICANAL-001`. Las capturas están en `capturas/`.

## 1. Qué es PGM

PGM es el **frontal de oficinas MAPFRE para la visión 360 del cliente orientada al comercial**. Un asesor (asesor de clientes, asesor comercial, delegado, gestor de delegado, director comercial, usuario central, APS…) localiza a un cliente o potencial, consulta toda su posición (datos, pólizas, recibos, prestaciones/siniestros, presupuestos, oportunidades, familia, descuentos) y desde ahí lanza las operativas de cada ramo o aplicación corporativa (SGC, SGO, NSE, PGO, Club MAPFRE, ACI…). Según `ARCH-APICANAL-001`, PGM **decomisiona la Ficha Ampliada de Cliente (FAC)** y se relaciona con SGC (2.0 → 3.0), PGO (catálogo de oportunidades/vencimientos), RIC (maestro de clientes), BDM y GESCOM.

PGM no es un sistema de registro: **casi toda la información se consulta en línea** en APIs y servicios corporativos; la persistencia propia es mínima (caché temporal de la ficha, borradores de tarificación, registro de operaciones y cuadro de mando).

## 2. Usuarios y perfiles

| Perfil (grupo Appian) | Uso |
|---|---|
| `PGM_AsesorClientes` | Asesor de clientes en oficina: búsqueda, ficha, gestiones básicas |
| `PGM_AsesorComercial` | Asesor comercial: ficha + gestión comercial (SGC/PGO, actividad comercial) |
| `PGM_Delegado`, `PGM_GestorDelegado` | Delegados con oficina MAPFRE y sus empleados |
| `PGM_DirectorComercial`, `PGM_UsuarioCentral`, `PGM_UsuariosTerritorio` | Dirección comercial y servicios centrales / territoriales |
| `PGM_APS` | Perfil APS |
| `PGM Visualizar CdM` | Acceso al cuadro de mando de uso |
| `PGM Acceso APP No Appian SGC` | Aplicaciones externas (SGC) que abren la ficha vía Web API |
| Pilotos: `PGM Piloto Captura WEB`, `PGM_Grupo_PilotoFrontal_NSEi`, `PGM_UsuariosEvolutivoConsentimientos` | Funcionalidad en piloto por grupo (feature flags por pertenencia a grupo) |
| `PGM_Admin`, `PGM2 administradores`, `PGM Audit`, `PGM_Alertas` | Administración, auditoría y alertas de procesos |

El perfil efectivo del usuario se completa con datos externos: **NUUMA** (identificador corporativo del empleado), estructura comercial (oficina, delegado, perfil) obtenida de **iMediador/BDEC** y perfil **SGC 3.0**. La visibilidad de cada bloque y acción depende de la combinación grupo Appian + perfil comercial.

## 3. Mapa de navegación

El site tiene 8 páginas de barra superior (la última, *Cuadro de Mando*, restringida por grupo); la navegación real se hace **dentro de la ficha** mediante pestañas.

| Página | Contenido observado | Captura |
|---|---|---|
| **Inicio** | *Buscador de clientes* multicriterio y *Enlaces de interés* | `01-inicio-buscador.png` |
| **N. Producción** | Tarjetas por ramo (Agropecuario, Empresas, Vida, Ahorro, Patrimoniales, Automóviles, Salud) que lanzan la nueva producción de cada ramo (NSE, tarificador Salud, Vida…) | `02-nueva-produccion.png` |
| **Gest. Cartera** | Tarjetas por ramo para operar la cartera (suplementos, anulaciones, consultas) | `03-gestion-cartera.png` |
| **Recibos** | Acceso directo a *Gestión de Recibos* (No Vida, aplicación externa) | `04-recibos.png` |
| **Prestaciones** | Tarjetas por ramo para prestaciones y siniestros | `05-prestaciones.png` |
| **Gest. Comercial** | Accesos a SGC 2.0, Asesor 360, SGC 3.0 y WhatsApp para Oficinas | `06-gestion-comercial.png` |
| **Utilidades** | SGO v2, Club MAPFRE, Site APM, Site Delegados, Información IDD, Portal de Incentivos | `07-utilidades.png` |
| **Cuadro de Mando** | Uso de la aplicación (interacciones por motivo y canal) | — |

## 4. Procesos funcionales

### 4.1 Localizar al cliente (Inicio)

Criterios de búsqueda: documento, nombre/razón social, primer y segundo apellido, código postal, correo electrónico, teléfono, nº expediente, matrícula, nº póliza, nº presupuesto, nº recibo y nº tarjeta sanitaria. Reglas observadas:

- Al rellenar un criterio "posicionado" (documento, matrícula, póliza, recibo, presupuesto, expediente, tarjeta) se deshabilitan los demás: la búsqueda es por **identificador** o por **datos personales** (nombre + apellidos, opcionalmente CP/email/teléfono), nunca mezclada.
- Nombre y apellido se exigen juntos ("Es necesario cumplimentar también el nombre o el segundo apellido").
- Resultado: tabla *Resultados de búsqueda* (nombre, documento, fecha de nacimiento, domicilio, CP, estado **Vigor/Potencial**), paginada, con aviso cuando se supera el límite (100 registros) y acceso a la ficha por fila. Si no hay resultados se ofrece **alta de cliente**; casos especiales para cliente VIP sin documento. (`08-resultados-busqueda.png`)
- Enlaces alternativos: *Ficha Ampliada de Cliente* (FAC, aplicación legacy que PGM sustituye), *Bandeja SGO*.
- La ficha también se abre **desde fuera de Appian** (SGC, otros frontales) por documento o id de cliente mediante Web APIs (`accesoFicha`, `fichaCliente`, `abrir-ficha-SGC`, `abrir-poliza`).

### 4.2 Ficha de cliente (visión 360) — `09-ficha-cliente.png`, `10-ficha-cliente-completa.png`

Cabecera: nombre, documento, estado (Vigor/Potencial), teléfono (con **click-to-call**), e-mail, edición de datos de contacto, alertas urgentes, refrescar información. Aviso RGPD (uso de datos / recabar consentimiento).

Bloque de situación: antigüedad, edad, dirección habitual, tipología de cliente, **Alta Cliente Total** (empresas representadas, firma); indicadores con acción directa:

| Indicador | Estado | Acción |
|---|---|---|
| DNI | digitalizado / sin digitalizar | *Digitalizar DNI* |
| RGPD | firmado / no firmado | *Firmar RGPD* (consentimientos, OneTrust) |
| ACI (Área de Cliente) | alta / potencial | *Solicitar alta en ACI* |
| En Familia | familia / sin familia | *Ver más* (familiares) |
| Plan de pagos | contratado / potencial | *Simular* |
| ClubMAPFRE | contratado / no | *Alta en ClubMAPFRE* (tréboles) |

Indicadores económicos: **% descuento por vinculación (integralidad)**, **total prima** (tomador/titular), acciones comerciales pendientes, **posición bancaria** (tarjeta financiera Club MAPFRE, contrato Santander), enlace a *Visualización Cliente* (FAC).

**Resumen por ramo** (carrusel): Riesgo, Ahorro/Jubilación, Autos, Hogar, Decesos, Salud, Accidentes… con nº de pólizas, vencimientos y presupuestos y acción *Vencimiento/Presupuesto* (alta de oportunidad en PGO).

**Pestañas**: *Posición del cliente* (Productos — en vigor / estados anteriores —, Prestaciones, Recibos; exportables a Excel), *Gestión comercial* (gestiones SGC 3.0, actividad comercial iMediador, interacciones, historial SGO, reclamaciones, encuestas, intervinientes) y *Presupuestos*.

Tabla de productos: ramo/riesgo/tipo/póliza, figura del cliente (tomador, titular, asegurado…), importe, efecto/vencimiento, estado, acciones por póliza (ficha de póliza, suplementos, duplicados, anulación, impresión).

### 4.3 Ficha de póliza y operativa por ramo

Desde la tabla de productos se abre la **ficha de póliza** (también vía Web API `abrir-poliza`): datos generales, intervinientes, estructura comercial, coberturas (Salud, Hogar, Autos, Vida/Unit Link, Hipoteca Segura, Consumo Protegido, productos financieros), situaciones de riesgo, recibos de la póliza, prestaciones. Operativas detectadas: duplicado de póliza/condiciones, solicitud de anulación (contra-anulación CORE), consulta de documentos, **lanzadera Citrix** a aplicaciones de ramo que no tienen API, apertura de enlaces NSE/Portal Interno.

### 4.4 Recibos

Consulta de recibos por cliente y por póliza (características, cuota, pagador, entidad, comisiones, estructura comercial, gestiones). Operativas: **cobro de recibo individual o múltiple** (incluido Bizum), **agrupar/desagrupar recibos**, **envío al banco**, impresión de duplicados y avisos de cobro, envío al *Centro de Recibos*.

### 4.5 Prestaciones y siniestros

Listado de prestaciones del cliente y detalle de expediente/siniestro (Autos vía METS, Hogar, Salud, Patrimoniales), tabla de prestaciones por póliza.

### 4.6 Gestión comercial y oportunidades

- **Vencimientos / oportunidades (PGO)**: alta de vencimiento (completo o incompleto), detalle, observaciones, documentos adjuntos, listado de compañías competidoras, características técnicas del producto, productos financieros (fondos, planes).
- **Gestiones SGC 3.0**: listado y detalle de tareas comerciales, crear/editar/eliminar observaciones, asignación, compartir, cerrar/reabrir, firma del mediador, estructura dentro/fuera de la propia.
- **Actividad comercial (iMediador)**: alta de actividad, consulta de actividades, catálogos de niveles de gestión, vencimientos de agenda.
- **Inducción de cliente** a Verti (Neurona/NSE), Santander (alta/baja de contrato), SAVIA (leads), con variantes RGPD / sin RGPD / Robinson.
- **DPVE** (descuento por vinculación): simulación de integralidad, productos contratados, generación de documentación.
- **Tarificación rápida Salud** con borradores recuperables (BBDD Borradores) y Nueva Producción por ramo.
- **Consentimientos** (firma RGPD/OneTrust) y **Cliente Total** (empresas representadas y firma).
- Comunicación: click-to-call (ConectaOrange), WhatsApp para Oficinas, crosselling / creatividades.

### 4.7 Utilidades, SGO y cuadro de mando

Bandeja y solicitudes **SGO** (sistema de gestión de operaciones), documentos de solicitud, acceso a Club MAPFRE, APM, Delegados, IDD, incentivos. **Cuadro de mando** interno con el volumen de interacciones por motivo y canal.

## 5. Reglas de negocio destacables (observadas)

- Cliente **Vigor** vs **Potencial**; VIP sin documento; alta de cliente cuando no existe.
- Un cliente "nivel 1" = datos del cliente + pólizas + datos de riesgo (la información que API Canal Clientes replica en su ODL).
- Visibilidad por **grupo Appian + estructura comercial** (oficina/delegado/perfil) + pilotos.
- RGPD: aviso permanente; acciones comerciales condicionadas a consentimiento; variantes de inducción según RGPD/Robinson.
- Caché temporal de la ficha (`PGM_R_cliente_tmp`) **borrada cada 10 minutos**; refresco manual desde la ficha.
- Límite de 100 resultados en búsqueda; búsqueda por identificador excluye criterios personales.
- Registro de operaciones de consulta/modificación de clientes por NUUMA (auditoría en Portal Interno).

## 7. Casuísticas y variantes detectadas (UI + SAIL)

Complemento tras recorrer la ficha de un cliente real en TEST y extraer los textos literales de las 566 interfaces (`inventario/pantallas-textos-sail.md`, `inventario/lanzaderas-paginas.md`, `inventario/lanzaderas-por-ramo.md`).

### 7.1 Tipologías de cliente y marcas de cabecera

| Variante | Qué cambia |
|---|---|
| **Particular** vs **Autónomo** (real o *potencial*) vs **Empresa** | Cabecera distinta: para empresas se muestran segmento, F. constitución, actividad, nº empleados y facturación "extraída del balance"; para particulares edad, estado civil, profesión, dirección. Iconos de tipología (decisiones `PGM_icono_tipologia_*`, `PGM_TipoPerfilCliente`). |
| **Vigor** / **Potencial** | Estado del cliente (icono y color: `PGM_Traduccion_Icono_Estado_Cliente`, `PGM_ColorEstado`). Un potencial puede no tener documento (**VIP sin documento**). |
| Marcas: **VIP**, **Rentas Altas**, **Empleado MAPFRE**, **Cliente Robinson**, **No perfilado**, **Gestor personal** | Se muestran como etiquetas; Robinson (`PGM_ClienteRobinson`) y RGPD condicionan la inducción comercial y los avisos (`PGM_MensajeGDPR`). |
| **Exclusivo corredor** | Aviso cuando el cliente está gestionado por un corredor exclusivo (`exclusiveAgentMessage`). |
| Cliente **menor** / **fallecido** | Variantes de validación en formularios (edad, documentos). |
| **Perfil financiero firmado** | Condiciona el alta de vencimientos de productos financieros (`PGM_Test_Perfil_Finaciero_Firmado`). |

### 7.2 Cabecera: palancas y acciones

DNI (digitalizar) · Consentimientos/RGPD (firmar; canales) · ACI (alta) · Plan de pagos (susceptible / datos PDP / simular) · Plan **En Familia** (`servicioFamilyId`) · ClubMAPFRE (alta; tréboles disponibles/gastados vía *Te Cuidamos*) · Acceso **FAS** (ficha ampliada) · Edición de datos de contacto (nuevo móvil, fijo, email; registra interacción) · **Alertas urgentes** y **Avisos e interacciones** (buscador con filtros y fechas) · Refrescar ficha · Click-to-call (fijo/móvil) y WhatsApp.

Primas y descuentos: *Pulse para calcular la prima total* (cálculo bajo demanda), **Descuento por vinculación** con *Simulador DPVE* / *Ejecutar DPVEs* (selección de productos a los que aplicar descuentos; reglas Pymes ≥ 5 asegurados, colectivos ≥ 50). Mensaje "No es posible realizar el cálculo online" cuando el servicio falla.

### 7.3 Resumen por ramo y acciones de póliza

Carrusel con un ítem por ramo (`PGM_FichaCliente_ItemCarrusel`: nº pólizas TO/TI y otros, nº vencimientos, nº presupuestos) y acción **Vto./Ppto.** que abre el alta de vencimiento/oportunidad en PGO (completo/incompleto, productos financieros con ISIN/emisor/tipo de interés, adjuntos y observaciones). Versiones *Mobile* de cabecera, carrusel y tabla de productos.

Tabla de productos: filtro **En vigor / Anulado**, pestañas *Estados anteriores*, *Prestaciones*, *Recibos*; acciones por póliza (ficha de póliza con pestañas resumen/prestaciones/recibos, duplicados, solicitud de anulación, impresión).

### 7.4 Recibos: operativas

Menú de recibo (datos del pagador: actúa como asegurado, documento, contacto, dirección) · **Agrupar/Desagrupar** (forma de pago, situación, STCAT, grupo, nota de cargo, no seguro, reserva de primas, descuento, tréboles, plan de pago, póliza on/off, Planeta Santander, efectivo/no efectivo, pendiente de vencimiento) · **Impresiones de recibo** / duplicado / aviso de cobro · **Enviar a Centro de Recibos** (observaciones) · **Cobrar recibo individual / múltiple** (forma de cobro, Bizum) · **Envío al banco**.

### 7.5 Gestión comercial: dependencias de perfil

Observado con el usuario de pruebas (sin perfil comercial): *Vencimientos* (Todos/Completo/Incompleto), *Actividad Comercial* → "Esta acción aún no está disponible en PGM para tu usuario… Puedes realizarla desde SGC 2.0", *Gestiones* → "No tienes permiso para ver las gestiones" (requiere perfil SGC 3.0 por NUUMA). Es decir, la pestaña degrada por perfil y enlaza a la aplicación origen. *Presupuestos*: "El cliente no tiene presupuestos".

**Cliente Total**: variantes Físico (empresas vinculadas: CIF, razón social, actividad, segmento, cargo, estado; añadir/editar/eliminar; firma con servicio de firma; fiabilidad), Jurídico (clientes totales vinculados) y Particular/Empresa (envío de enlace).

### 7.6 Lanzaderas por ramo (N. Producción / Gest. Cartera / Prestaciones)

Cada tarjeta de ramo abre una interfaz con accesos a aplicaciones externas; **PGM no implementa la emisión ni la gestión de cartera**, solo las enlaza:

| Ramo | Nueva producción | Gestión de cartera | Prestaciones |
|---|---|---|---|
| Automóviles | NSE Autos (tarificación y emisión, rápida, otros acuerdos), NSEi (piloto por grupo), wAutem, Flotas (Citrix) | NSE suplementos, acuerdos especiales, Flotas | METS (solo Director Comercial / Usuario Central) |
| Patrimoniales | NSE Hogar/Comunidades, Decesos, Viajes (Citrix/URL), Portal Interno | NSE suplementos, bandeja de operaciones | Hogar (Home API), Decesos |
| Salud | **Tarificación rápida PGM** (propia, con borradores) + GESALUD (pasarela) por producto (Supra, Plus, Tú e-liges, Dental, Elección, Reembolso, Indemnización…) | GESALUD (operaciones pendientes, incompletas) | Salud |
| Vida / Ahorro | GESVIDA, WEBVIDA (rentas, solicitud), comparador de riesgo (PGM CV), dependencia, Solución Global, accidentes | GESVIDA | Vida |
| Empresas | Multirriesgo, RC, CiberON, Autoemprendedores, Mercancías (NSE / Citrix) | Suplementos, bandeja de operaciones, cláusulas | Empresas |
| Agropecuario | SAC (Portal Interno), NSE Agropecuaria, bandeja de operaciones | idem | Agropecuario |

Accesos transversales: Portal Interno (SAC, bandeja, Liquicom, Asesor 360, SGC 2.0, Club), SGC 3.0, WhatsApp Oficinas (restringido por grupos), SGO (site Appian), APM, Delegados, IDD, Incentivos, VirtualApps/Citrix (`PGM_PM_NAV_CITRIX`: lista de recursos por usuario).

### 7.8 Diálogos de la ficha comprobados en TEST (primera pantalla, sin enviar)

| Acción | Comportamiento observado |
|---|---|
| Menú **ACCIONES** (cabecera) | *Más datos cliente* (consultar más datos), *Centro de comunicaciones*, *Consulta descarga documentación*. |
| **Acciones** de una póliza | Diálogo "Acciones – Ramo – nº póliza": *Consulta individual SCA* (anulaciones) y *Documentación de emisión*; el resto de acciones depende del ramo/estado. |
| **Vto./Ppto.** | Diálogo "Añadir Vencimiento / Presupuesto" (PGO); para usuarios sin perfil comercial: "Esta acción aún no está disponible en PGM para tu usuario… Contacta con el administrador". |
| **Ver más** (En Familia) | "El cliente no tiene familiares identificados. Para obtener los beneficios de MAPFRE en Familia, cree una familia" → *CREAR FAMILIA*. |
| **Simular** (Plan de pagos) | "El cliente es susceptible de contratar un Plan de Pagos" → *Simular plan de pagos individual* / *familiar*. |
| **Descuento vinculación** | "Resumen Descuento por Vinculación (DpV)": sectores de negocio (Autos, Patrimonio/RC, Salud, Decesos, Vida/Accidentes), tomadores con pólizas en vigor, composición familiar del DpV por sector, DpV mínimo para nueva producción; detalle por contrato / tomador / documento. |
| **Alertas urgentes** | "Centro de Comunicaciones" con pestañas *Alertas* (prioridad, descripción: p. ej. revisar nacionalidad y actualizar desde FAC; solicitar documento y almacenarlo en el gestor documental), *Interacciones*, *Reclamaciones*. |
| **Digitalizar DNI** | *Digitalizar ahora* (frontal y reverso, png/jpg/bmp/tif/pdf ≤ 3 MB) o *Solicitar al cliente*. |
| **Firmar RGPD** | Métodos: firma biométrica, aceptación por email, aceptación por SMS; alternativa "impresión y firma" (oficina sin papel). |
| **Solicitar alta en ACI** | Requisito previo: teléfono móvil o email del cliente ("incorpóralos en Más datos cliente"); el resto de datos se modifican por suplemento. |
| **Alta Cliente Total** | Tabla del cliente (NIF, nombre, clasificación actual / nueva), empresas vinculadas (CIF, razón social, actividad, segmento, clasificación, cargo, estado), *Ver documento*, *Añadir CIF*, *Firmar*. |
| Pestaña **Estados anteriores** | Vacía para el cliente de prueba (sin pólizas anuladas). |

Nota de trazabilidad: al abrir *Digitalizar DNI*, *Firmar RGPD*, *Solicitar alta en ACI* y *Alta Cliente Total*, Appian arranca una instancia de proceso con tarea de usuario (así están diseñados); se cerraron sin enviar nada, por lo que no hubo modificación de datos, pero las instancias quedan iniciadas por el usuario de pruebas.

### 7.9 Limitaciones de la exploración

El usuario de pruebas no tiene perfil comercial (NUUMA/estructura) ni grupos de piloto, por lo que *Gestiones SGC 3.0*, *Actividad comercial*, *Cuadro de mando* y los pilotos (Captura Web, NSEi, consentimientos) se documentan solo desde SAIL. Las operativas que modifican datos no se ejecutaron.

## 8. Fuera de alcance / no verificado en TEST

- Operativas que modifican datos (cobros, agrupaciones, altas de vencimiento, firmas, inducciones) **no se ejecutaron** para no dejar rastro; se documentan a partir de los objetos de diseño.
- Cuadro de mando y pilotos (Captura Web, NSEi) no se visualizaron (grupo restringido).
- Comportamiento en PRO (URLs PRO en constantes comentadas) no comprobado.
