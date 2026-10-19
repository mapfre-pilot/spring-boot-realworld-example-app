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

## 6. Fuera de alcance / no verificado en TEST

- Operativas que modifican datos (cobros, agrupaciones, altas de vencimiento, firmas, inducciones) **no se ejecutaron** para no dejar rastro; se documentan a partir de los objetos de diseño.
- Cuadro de mando y pilotos (Captura Web, NSEi) no se visualizaron (grupo restringido).
- Comportamiento en PRO (URLs PRO en constantes comentadas) no comprobado.
