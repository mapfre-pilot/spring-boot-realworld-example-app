# 1. Visión funcional

## 1.1 Propósito

SCA es la herramienta comercial con la que Mapfre gestiona las **solicitudes de anulación de póliza** de los ramos
Autos, Hogar y Vida ("Estratégicas"). Cubre el ciclo completo desde que se detecta la intención de anular hasta que la
póliza queda anulada, se retiene al cliente (contra anulación) o la solicitud caduca:

1. **Alta de la solicitud** de anulación (manual desde el buscador, o de forma automática al llegar una gestión desde
   los sistemas de emisión/gestión: PCA, SGC, SGO, Verti).
2. **Decisión de la acción** a realizar mediante un servicio de reglas externo (`SCA Decidir Accion`): autorizar,
   mecanizar, contra anular, acción administrativa, cambiar de nivel o finalizar.
3. Ejecución de la acción como **tarea humana** asignada por nivel de intervención (N1/N2/N3) y grupo.
4. **Finalización** (positiva, negativa, caducada) con actualización del estado en los sistemas origen, notificación
   por correo y trazabilidad.

## 1.2 Actores y roles

| Grupo Appian | Miembros (DEV) | Uso |
|---|---|---|
| `SCA Administradores` | 1 | Administración de la app y datos maestros (grupo admin por defecto). |
| `SCA Usuarios` | 60 | Tramitadores; acceso a los sites y a las tareas. |
| `SCA Acceso Decisora` | 9 | Usuarios que llegan desde la "Decisora" (redirección desde PCA vía Web API). |
| `SCA Acceso Decisora Vida` | 5 | Variante para Vida (redirige a GESVIDA). |
| `SCA Alertas` | 1 | Destinatarios de alertas/errores batch. |

La visibilidad de la página "Gestiones mantenimiento" depende de `rule!SCA_isUsuarioProceso()` y las tareas se
asignan por `grupoasignacion` + `nivelintervencion` (campos del record `SCA solicitudAnulacion`).

## 1.3 Puntos de entrada

| Entrada | Objeto | Descripción |
|---|---|---|
| Site `SCA_Site` (`/sca-site`) | `SCA_BuscadorSolicitudPrincipal` | Buscador de solicitudes por cliente/póliza, alta manual, consulta de detalle y tabla de "otras solicitudes". |
| Site `SCA Decidir Accion` (`/decidir-accion`) | `SCA_DecidirAccion` | Pantalla de trabajo de la tarea activa: cabecera de póliza, pop-up de la Decisora, alta, autorización, mecanización, contra anulación, acciones administrativas. |
| Web API `SCA Decisora` (GET `/decisora`) | — | Invocada desde PCA/portal: recibe póliza y devuelve la URL de redirección al site correcto (Autos/Hogar → `SCA_DecidirAccion`; Vida → `SCA_RedirigirGesvida`). |
| Web APIs batch (POST) | `ejecutarRsvPrima`, `volcadoReservaPrima`, `eliminarTareas`, `eliminarTareasBBDD` | Disparadores de procesos batch (reserva de prima, limpieza de tareas). |
| Process models `SCA Batch *` | 4 PMs | Caducidad de tareas, mecanización NSE, reserva de prima SGO, envío de correos. |

## 1.4 Ciclo de vida de una solicitud

```
                   ┌──────────────────────────┐
  Buscador / PCA → │  SCA Alta Solicitud       │ → Generar Solicitud (reglas + BBDD + trazabilidad)
                   │  Anulacion (Particionado) │
                   └────────────┬─────────────┘
                                │  SCA Decidir Accion  (servicio de reglas externo)
        ┌───────────┬───────────┼───────────┬────────────────┬──────────────┐
        ▼           ▼           ▼           ▼                ▼              ▼
  AUTORIZACIÓN  MECANIZAR  CONTRA ANULAR  ACC. ADMIN.   IR A NIVEL 2/3   FIN PROCESO
   (N1..N3)      (N1..N3)    (N1..N3)      (N1..N3)     (reasignación)
        │           │           │           │
        └───────────┴─────┬─────┴───────────┘
                          ▼
             SCA Finalizar Solicitud / Finalizar Mecanización
             (actualiza PCA/SGC/SGO, correo DUE, trazabilidad)
                          │
               SCA Batch Caducidad (caduca tareas fuera de plazo)
```

Las acciones posibles están tipificadas en la constante `SCA_TXT_ACCIONES` (15 valores: AUTORIZACION, MECANIZAR,
CONTRAANULAR y ACCIONES ADMINISTRATIVAS en niveles 1/2/3, IR A NIVEL 2/3, FIN PROCESO). El process model principal
mantiene en `interfazactiva` cuál es la pantalla que debe mostrarse y en `nodorelanzar` el punto de reanudación.

### Fases

| Fase | Process model(s) | Interfaces principales | Qué hace |
|---|---|---|---|
| Alta | `SCA Alta Solicitud Anulacion` (52 nodos), `... Particionado` (46), `SCA Generar Solicitud` (12) | `SCA_AltaSolicitudAnulacion[Estrategicas]`, `SCA_AltaSolicitudAnulacionPopUp*`, `SCA_GenerarSolicitudPopup*`, `SCA_SimularAnulacionPopup*` | Recupera datos de póliza/cliente/productor desde Core7/webservices, permite simular la anulación (prima, deducciones), consulta reglas para clasificar la solicitud (motivo/detalle/causa) y persiste la solicitud y su trazabilidad. Detecta pólizas PRRA y NSE. |
| Decisión | `SCA Decidir Accion` (10) | `SCA_PopUpDecisora*` | Busca la última gestión, llama al servicio de reglas y devuelve acción + nivel; con reintentos (`numReintentos`). |
| Autorización | `SCA Autorización` (37) | `SCA_DetalleAnulacionAutorizacion*`, `SCA_PopUpMensajeAutorizacion` | Solicita/acepta autorizaciones vía Core7 (`IGestionarAutorizacionesPCA`); estados `SCA_TXT_ESTADOS_AUTORIZACION`. |
| Mecanización | `SCA Mecanizacion` (64), `SCA Finalizar Mecanización` (40), `SCA Batch Mecanizacion NSE` | `SCA_MecanizacionEstrategicas`, `SCA_DetalleAnulacionMecanizacion*`, `SCA_ModalPlanPago`, `SCA_ModalClaveProduccion` | Ejecuta la anulación en el sistema origen (`IMecanizarPCA`), bloquea póliza, crea autorización si procede, gestiona reserva de prima, inducción Verti, correo DUE. Se sincroniza con la app **ANL** ("Pausar hasta ANL_Desbloquear"). |
| Contra anulación | `SCA Contra Anulación` (49) | `SCA_ContraAnulacionPrincipal*`, `SCA_ContraAnulacionOpciones*`, modales Retos / SVA / Tréboles / Recuperación póliza / Argumentos | Retención del cliente: argumentario, ofertas (Retos, SVA, Tréboles, descuentos Vida), generación de contacto Verti, recuperación de póliza. |
| Acciones administrativas | `SCA Acciones Administrativas` (37) | `SCA_AccionesAdministrativasPrincipal*`, `...Catalogacion`, `...Documentacion` | Catalogación de compañía contraria, gestión documental (carta firmada, Documentum), errores de documentación. |
| Finalización | `SCA Finalizar Solicitud` (44), `SCA Finalizar Gestion SGC` | — | Cierra la gestión en SGC/SGO/PCA, actualiza estados, envía correo, borra la tarea. |
| Reasignación | `SCA Reasignar Tarea`, `SCA Cambio Asignacion` | `SCA_PopUpReasignarTarea`, `SCA_selectorOficinas` | Cambio de nivel/grupo/usuario. |
| Documentos | `SCA Subir Docs Documentum BBDD`, `SCA Subir Documento`, `SCA Eliminar Documento` | `SCA_VisualizacionDocumento`, `SCA_VisualizarDocumento*` | Subida temporal a Appian y persistencia en Documentum + BBDD. |
| Caducidad | `SCA Batch Caducidad` (23) | — | Caduca solicitudes fuera de plazo por nivel (`caducidadtarea`, `fecinicionivel`). |
| Reserva de prima | `SCA Batch Rsva Prima SGO`, `SCA Volcado Datos Reserva Prima`, `SCA Lanzar Reserva Prima` | — | Carga y ejecución de reservas de prima contra SGO; record `SCA Reserva Prima`. |
| Mantenimiento | `SCA Crear/Modificar/Eliminar Concepto [Funcional]`, `SCA Gestion Aplicacion`, `SCA Gestion Argumentos` | `SCA_GestionMantenimientoMenu`, `SCA_GestionConceptosYClases`, `SCA_GestionArgumentos`, `SCA_GestionAplicacionRecords`, `SCA_BuscarCompaniasContrarias` | Datos maestros: conceptos y clases, argumentos de contra anulación, aplicaciones/URLs, compañías contrarias. Los conceptos se gestionan vía record types `WEB_SERVICE`. |

## 1.5 Ramos y duplicidad Autos/Hogar vs Vida

La aplicación distingue dos "líneas": **Autos/Hogar** (flujo PCA original) y **Vida / Estratégicas**. Esta
distinción se implementa duplicando interfaces con el sufijo `Estrategicas` (26 de las 103 interfaces son
variantes `*Estrategicas`) y bifurcando con `VIDA?` / `origenPoliza` en los process models. Los record types de
póliza también están separados por ramo (`SCA datosPolizaAutos`, `SCA datosPolizaHogar`, `SCA Datos Poliza Vida`).

## 1.6 Estados de negocio

Definidos como constantes de tipo lista (ver `04-modelo-de-datos.md`, §4.4):

- Solicitud PCA (`SCA_TXT_ESTADO_SOLICITUD_PCA`, 14): Registrada, En tramitación, Autorización/Mecanización/Contra
  anulación en curso, Finalizada positivamente, Finalizada negativo con contra anulación, Caducada…
- Solicitud CA (`SCA_TXT_ESTADOS_SOLICITUD_CA`, 9), Autorización (5), Mecanización (9), Argumento (3).
