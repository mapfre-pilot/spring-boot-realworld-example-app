# Plan de rediseño: SCA con procesos atómicos orquestados desde la interfaz

Propuesta de trabajo, **sin ejecutar todavía**, para:

1. Duplicar la aplicación SCA en una copia aislada (acceso solo para el solicitante y Devin) sin tocar los objetos
   originales.
2. Sustituir los process models de larga vida `SCA Alta Solicitud Anulacion` (original) y
   `SCA Alta Solicitud Anulacion Particionado` por una **interfaz orquestadora + máquina de estados en BBDD +
   process models atómicos** cuyas instancias vivan segundos/minutos, no días.

Todo lo indicado como *hecho confirmado* procede de la lectura de los objetos vía MCP (solo lectura). Lo marcado
como *propuesta* es diseño pendiente de validar con el equipo.

---

## 1. Diagnóstico: por qué las instancias duran días

### 1.1 Los dos PMs de alta

| | `SCA Alta Solicitud Anulacion` (original) | `SCA Alta Solicitud Anulacion Particionado` |
|---|---|---|
| UUID | `0002eb8b-09db-8000-c7f1-7f0000014e7a` | `0038ee6b-8ea7-8000-0ec5-7f0000014e7a` |
| Nodos / variables | 52 nodos (lectura parcial por error MCP) | 46 nodos / 51 variables |
| Arrancado desde | `SCA_PopUpDecisora` (`cons!SCA_PM_ALTA_SOLICITUD_ANULACION_ANTIGUO`) | `SCA_GenerarSolicitudPopupEstrategicas` (`cons!SCA_PM_ALTA_SOLICITUD_ANULACION_PARTICION`) |
| Alta en PCA (`generarStudAnul`, 3 reintentos) | dentro del PM | extraída a `SCA Generar Solicitud` (12 nodos) |
| Persistencia inicial + trazabilidad + reglas | subprocesos `Guardar BBDD`, `Guardar Trazabilidad`, `Reglas` dentro del PM | extraída a `SCA Generar Solicitud` → `SCA Consulta Reglas` |
| Bucle de tramitación (autorización / mecanización / contra anulación / acc. adm. / cambio de nivel) | dentro del PM | **sigue dentro del PM** |
| Subprocesos de acción llamados con `isAsynchronous = 0` (el padre espera) | sí | sí: `AUTORIZACIÓN`, `MECANIZAR`, `CONTRA ANULAR`, `ACC ADM`, `Finalizar Gestion SGC`, `Notificar/DUE`, `Guardar tarea`, `Borrar tarea`, `Borrar registros BBDD`, `REDIRECCION VIDA` |

La partición hecha en su día sacó del PM la parte **corta** (alta en PCA + persistencia + primera consulta de
reglas). La parte **larga** (el bucle `Acción?` → subproceso con tarea humana → volver a `Acción?`) quedó intacta,
por eso las instancias siguen durando lo mismo.

### 1.2 Dónde se "aparca" realmente una instancia (hechos confirmados)

El árbol de procesos completo que cuelga de una instancia del PM particionado es:

```
SCA Alta Solicitud Anulacion Particionado (padre, vivo hasta FIN PROCESO)
 ├─ User Input Task "Generar solicitud"            → pp!initiator   (espera humana)
 ├─ SUB SCA Autorización (37 nodos, sync)
 │    ├─ User Input Task "AUTORIZACIÓN"             → pp!initiator   (espera humana, días)
 │    ├─ User Input Task "PopUpMensajeAutorizacion" (x2)             (espera humana)
 │    ├─ XOR "Caducada or Doc entregada?"  now() >= pv!caducidadNivel
 │    └─ SUB Obtener Documentos / Subir Docs Documentum / Guardar tarea / Borrar tarea (sync)
 ├─ SUB SCA Mecanizacion (64 nodos, sync)
 │    ├─ User Input Task "Detalle Anulacion", "Verti / Vencimiento" → pp!initiator
 │    ├─ 2 x Intermediate Consuming Event (espera de evento externo)
 │    ├─ 6 Call Integration (Core7 mecanización/autorización)
 │    └─ 11 SUB_PROC (ANL Alta, Inducción VERTI, Insertar Observaciones, tareas BBDD…)
 ├─ SUB SCA Contra Anulación (49 nodos, sync)
 │    ├─ User Input Task "CONTRA ANULACIÓN" → grupo (CE_RM oficina) o pp!initiator
 │    └─ 3 popups humanos + Obtener/Subir documentos
 ├─ SUB SCA Acciones Administrativas (37 nodos, sync) — 3 tareas humanas
 ├─ Cambio de nivel → SUB Notificar/DUE (email + Gestion SGC), vuelve a Acción?
 ├─ Start Process SCA Finalizar Solicitud (44 nodos, async)  ← único desacoplado
 └─ SUB Borrar registros BBDD / Borrar tarea (sync)
```

Causas raíz de la duración:

1. **Tareas humanas dentro de subprocesos síncronos.** Cada acción tiene su `User Input Task` (asignada a
   `pp!initiator` o a un grupo) *dentro* del subproceso, y el subproceso se llama con `isAsynchronous = 0`. Mientras
   el gestor no actúe, subproceso y padre están vivos.
2. **Bucle de tramitación en el padre.** Tras cada acción el flujo vuelve al `XOR "Acción?"` (vía `Join`,
   `Decidir Mecanizar`, `Cambio de nivel`). Una solicitud que pasa por nivel 1 → nivel 2 → nivel 3 → mecanización
   mantiene la *misma* instancia padre abierta durante todo el recorrido.
3. **Caducidad por comparación en el flujo**, no por evento: `now() >= pv!caducidadNivel` solo se evalúa cuando
   alguien completa la tarea. La caducidad real la resuelve `SCA Batch Caducidad` desde fuera, pero el PM que
   contenía la tarea sigue existiendo hasta que alguien lo cierre (`SCA Desbloquear Proceso Principal`,
   Web API `eliminarTareas`).
4. **Estado duplicado.** El estado de negocio vive a la vez en 51 variables de proceso (records, CDTs, mapas) y
   en BBDD (`SCA solicitudAnulacion.procesoactivo/interfazactiva/…`, `SCA TareasPorPolizaAWS`). Cualquier
   cambio de versión del PM deja instancias antiguas con lógica antigua.
5. **Eventos de espera (`Intermediate Consuming Event`)** en `SCA Mecanizacion`, `SCA Finalizar Solicitud` y
   `SCA Borrar tarea Finalizada en BBDD`: quedan a la espera de mensajes externos indefinidamente.

### 1.3 Lo que ya existe y apunta al modelo objetivo (hechos confirmados)

Durante el análisis se ha visto que la rama "Estratégicas" (Vida) ya empezó a construir, parcialmente, el patrón
que queremos generalizar:

| Pieza | Objeto | Qué hace |
|---|---|---|
| Estado en BBDD | record `SCA solicitudAnulacion` | campos `procesoactivo`, `interfazactiva`, `nodorelanzar`, `caducidadtarea`, `estadotarea`, `estadosolicitud`, `nivelintervencion`, `grupoasignacion`, `usuario`, `tareacapturada`, `contadorposponer`, `transactionid`, `dueenviado` |
| Tarea activa en BBDD | record `SCA TareasPorPolizaAWS` | `nombreTarea`, `estado`, `proceso`, `idTarea`, `propietario`, `asignadoA`, `numSolicitud` |
| Interfaz orquestadora embrionaria | `SCA_DecidirAccion` | lee `interfazactiva` con `rule!SCA_ObtenerEstado(numPoliza)` y hace `a!match` para pintar la sub-interfaz correspondiente. Solo están cableadas "Generar solicitud" y "Contra anulación" (índices 7/8/9 de `cons!SCA_TXT_ACCIONES`); las ramas Autorización / Acc. Adm. / Mecanización / Verti / Mensaje están **comentadas**. |
| Comprobación de propietario | `rule!SCA_comprobarUserTareaActiva` | compara `nivelintervencion`, `usuario` (NUUMA) y `grupoasignacion` con el usuario logueado |
| PMs atómicos ya existentes | `SCA Alta Contra Anulacion` (14 nodos), `SCA Finalizar Contra Anulacion` (33), `SCA Posponer Contra Anulacion` (15), `SCA Alta Mecanización`, `SCA Consulta Reglas` (11), `SCA Decidir Accion` (10), `SCA Posponer Accion`, `SCA Reasignar Tarea Estrategica` | sin tareas humanas; los lanza la interfaz `SCA_ContraAnulacionOpcionesEstrategicas` con `a!startProcess_26r3` y actualizan `interfazactiva` |
| Caducidad desde fuera | `SCA Batch Caducidad` + `SCA Batch Caducidad Previo` (Transaction Manager, prefijo TM) | lee la solicitud por `idSolicitud`, decide por `procesoactivo`, llama a la integración de finalización de la acción, escribe error/`caducidadtarea`, lanza `SCA Finalizar solicitud` y `Borrar BBDD` |

Conclusión: **no partimos de cero**. La estrategia es completar este patrón para todas las acciones y ambos
orígenes (PCA/Autos-Hogar y Estratégicas/Vida), y retirar los dos PMs de alta.

---

## 2. Arquitectura objetivo (propuesta)

### 2.1 Principios

1. **La fuente de verdad es la BBDD, no la instancia.** Todo lo que hoy es `pv!` de larga vida pasa a columnas
   del record de solicitud o a records hijos. Una instancia de PM debe poder morir en cualquier punto y ser
   sustituida por otra que lea el estado de BBDD.
2. **Ningún `User Input Task` en PMs de negocio.** La interacción humana es la interfaz orquestadora (site
   "decidir-accion" / record action), que se abre siempre por `numPoliza`/`idSolicitud`. Excepción admitida:
   formularios *chained* de confirmación que se completan en la misma sesión (segundos).
3. **Un PM = un comando.** Cada PM atómico recibe `idSolicitud` (+ pocos parámetros), relee lo que necesite de
   BBDD, hace *una* transición de estado (integraciones + escritura + trazabilidad) y termina. Objetivo: < 2 min,
   sin subprocesos síncronos con espera humana, sin `Intermediate Consuming Event`.
4. **Transición de estado explícita e idempotente.** Cada comando comprueba que el estado actual permite la
   transición (`estadosolicitud`/`procesoactivo` esperados) y usa `transactionid`/`idSolicitud` como clave de
   idempotencia frente a reintentos y dobles clics.
5. **Esperas = filas, no instancias.** "Esperar al gestor", "esperar 3 días de caducidad", "esperar respuesta de
   Documentum" se modelan como estado + `caducidadtarea` + batch/TM o callback (Web API), nunca como una
   instancia parada.
6. **Reintentos y errores en BBDD.** `nodorelanzar` + `error` + contador; un PM `Relanzar` (o el batch) reintenta
   desde el último paso persistido, en vez de contadores `numReintentos` en variables de proceso.

### 2.2 Componentes

```
┌────────────────────────────────────────────────────────────────────┐
│ Interfaz orquestadora  SCA2_Orquestador (evoluciona SCA_DecidirAccion)│
│  - lee solicitud + tarea activa (a!refreshVariable / refreshAfter)   │
│  - a!match(estado) → sub-interfaz de la acción                       │
│  - botones = comandos → a!startProcess(PM atómico, {idSolicitud,…})  │
│  - tras el startProcess: refresca; no espera al PM                    │
└──────────────┬─────────────────────────────────────────────────────┘
               │ comandos
   ┌───────────┴──────────────┐          ┌──────────────────────────────┐
   │ PMs atómicos (segundos)   │  escriben │ BBDD (fuente de verdad)       │
   │ CMD_AltaSolicitud         │ ───────▶ │ solicitudAnulacion (estado)   │
   │ CMD_DecidirAccion         │          │ tareaActiva (quién/qué/hasta) │
   │ CMD_IniciarAccion         │ ◀─────── │ historicoTransicion (nuevo)   │
   │ CMD_ResolverAccion        │   leen   │ comandoEjecutado (idempot.)   │
   │ CMD_Posponer / CambiarNivel│          └──────────────────────────────┘
   │ CMD_Finalizar / Relanzar  │                     ▲
   └───────────────────────────┘                     │
   ┌───────────────────────────┐          ┌──────────┴───────────────────┐
   │ Reactivadores externos    │          │ Web APIs entrantes (callbacks)│
   │ Batch Caducidad (TM)      │          │ decisora / eliminarTareas /   │
   │ Batch Mecanización NSE    │          │ nuevos: documentoRecibido…    │
   └───────────────────────────┘          └──────────────────────────────┘
```

### 2.3 Máquina de estados (propuesta inicial, a validar con negocio)

Estados de `estadosolicitud` (nuevo enum, sustituye la combinación `procesoactivo`+`interfazactiva`):

| Estado | Quién lo deja | Siguiente(s) | Espera |
|---|---|---|---|
| `BORRADOR` | interfaz alta | `ALTA_EN_CURSO` | humana (no hay instancia) |
| `ALTA_EN_CURSO` | `CMD_AltaSolicitud` | `PENDIENTE_DECISION` / `ERROR_ALTA` | segundos |
| `PENDIENTE_DECISION` | `CMD_DecidirAccion` (reglas `accion`) | `EN_AUTORIZACION` / `EN_MECANIZACION` / `EN_CONTRA_ANULACION` / `EN_ACC_ADM` / `CAMBIO_NIVEL` / `FINALIZANDO` | segundos |
| `EN_<ACCION>` (N1/N2/N3 en `nivelintervencion`) | `CMD_IniciarAccion` (alta en Core7, guarda tarea) | `RESUELTA_<ACCION>` / `POSPUESTA` / `CADUCADA` / `CAMBIO_NIVEL` | **humana**: fila en `tareaActiva` con `caducidadtarea` |
| `POSPUESTA` | `CMD_Posponer` | `EN_<ACCION>` al vencer `fechadietario` (batch) | temporal (batch) |
| `RESUELTA_<ACCION>` | `CMD_ResolverAccion` (actualiza Core7, documentos) | `PENDIENTE_DECISION_MECANIZAR` → `EN_MECANIZACION` / `FINALIZANDO` | segundos |
| `CAMBIO_NIVEL` | `CMD_CambiarNivel` (notifica DUE/SGC, reasigna grupo) | `PENDIENTE_DECISION` | segundos |
| `CADUCADA` | Batch Caducidad | `FINALIZANDO` | segundos |
| `FINALIZANDO` | `CMD_Finalizar` (hoy `SCA Finalizar Solicitud` + `Eliminar Tablas BBDD`) | `FINALIZADA` / `ERROR_FINALIZACION` | segundos |
| `ERROR_*` | cualquier comando | mismo estado previo vía `CMD_Relanzar` | humana/batch |

Las decisiones que hoy están en `XOR "Acción?"` (17 salidas: `AUTORIZACION`, `AUTORIZACION NIVEL 2`, …,
`IR A NIVEL 2`, `FIN PROCESO`, `CONTRA ANULAR NIVEL 3`) se convierten en una **tabla de transiciones**
(`accion` de reglas × `nivelintervencion` → estado destino, PM a lanzar, grupo asignado), que puede vivir en una
constante/record de configuración en lugar de en condiciones SAIL dentro del PM.

### 2.4 Mapeo nodo a nodo del PM particionado

| Nodo actual (PM particionado) | Destino en el nuevo diseño |
|---|---|
| `Modify Process Security` | plantilla común de todos los PMs atómicos |
| `User Input Task "Generar solicitud"` / `"Generar error solicitud"` | interfaz orquestadora (estado `BORRADOR` / `ERROR_ALTA`) |
| `Consulta servicio reglas` (+ reintento ×3 con `numReintentos`) | `CMD_DecidirAccion` (reutiliza `SCA Consulta Reglas`); reintento por `nodorelanzar` |
| `XOR "Acción?"` (17 ramas) | tabla de transiciones + `CMD_DecidirAccion` escribe estado destino |
| `SUB AUTORIZACIÓN` | se parte en `CMD_IniciarAccion(AUTORIZACION)` (nodo `Alta Autorización` + `Guardar tarea`) y `CMD_ResolverAccion(AUTORIZACION)` (`Actualizar Autorización`, documentos, `Borrar tarea`); la `User Input Task "AUTORIZACIÓN"` desaparece → sub-interfaz `SCA_AnulacionFueraNormaPrincipal` dentro del orquestador |
| `SUB MECANIZAR` (64 nodos) | igual: `CMD_IniciarAccion(MECANIZACION)` (existe ya `SCA Alta Mecanización`) + `CMD_ResolverAccion(MECANIZACION)` (`SCA Finalizar Mecanización`); los `Intermediate Consuming Event` pasan a Web API/batch; sub-flujos Verti y ANL Alta se lanzan async |
| `SUB CONTRA ANULAR` | ya existe el patrón en Estratégicas (`Alta` / `Finalizar` / `Posponer Contra Anulacion`); se generaliza a PCA |
| `SUB ACC ADM` | `CMD_IniciarAccion(ACC_ADM)` + `CMD_ResolverAccion(ACC_ADM)` |
| `Decidir Mecanizar` + `XOR` | `CMD_DecidirAccion(regla: "mecanizar")` al final de `CMD_ResolverAccion` |
| `Cambio de nivel` + `SUB Notificar/DUE` + `Reassign Task` | `CMD_CambiarNivel` (email + `Gestion SGC` + `grupoasignacion`); no hay tarea Appian que reasignar |
| `SUB Finalizar Gestion SGC` | dentro de `CMD_Finalizar` / `CMD_CambiarNivel` según rama |
| `Start Process Finalizar Solicitud` (async) + `SUB Borrar registros BBDD` | `CMD_Finalizar` (ya desacoplado; se mantiene) |
| `SUB REDIRECCION VIDA` (User Input Task) | redirección desde la interfaz (`a!recordActionField` / site page) |
| `SUB Guardar tarea` / `Borrar tarea` (sync, en cada rama) | escritura directa de `tareaActiva` en el mismo `CMD_*` (un `Write Records`), sin subproceso |
| `SUB ERROR` → `SCA Notificacion Errores` | se mantiene como PM async común |

### 2.5 Reactivación sin instancias vivas

| Espera actual | Mecanismo propuesto |
|---|---|
| Gestor tarda días en autorizar | fila `tareaActiva` + orquestador; bandeja = query por `asignadoA`/`grupoasignacion` (ya existe `SCA_obtenerTareasSolicitudAlta`) |
| Caducidad de nivel (`caducidadNivel`) | `caducidadtarea` en BBDD + `SCA Batch Caducidad` (TM) → `CMD_Caducar`. Ya existe; solo debe dejar de necesitar "desbloquear" PMs padres |
| Posponer (`fechadietario`, `contadorposponer`) | batch diario TM → `CMD_Reactivar` |
| Respuesta externa (Documentum, Core7 asíncrono) | Web API entrante → `CMD_ResolverAccion`; si el proveedor no hace callback, polling en batch con `nodorelanzar` |
| Doble clic / concurrencia | `tareacapturada` + `usuario` como lock optimista; `CMD_*` comprueba estado esperado antes de escribir |

### 2.6 Qué NO hace la interfaz orquestadora

- No espera a que termine un PM (`a!startProcess` sin `onSuccess` bloqueante; refresco con `refreshAfter`/intervalo).
- No contiene lógica de integración: solo lee estado y lanza comandos.
- No decide la acción de negocio: la decide el servicio de reglas dentro de `CMD_DecidirAccion`.

---

## 3. Fase 0 — Duplicar la aplicación de forma aislada

### 3.1 Restricciones confirmadas

- Appian no ofrece "clonar aplicación" en el mismo entorno; la duplicación es **objeto a objeto** (Save As /
  recreación). El MCP dispone de `create*` para todos los tipos necesarios (application, group, folder, constant,
  expression rule, interface, process model + nodes, record type, web api, site) y `updateObjectSecurity`, por lo que
  la copia se puede automatizar con un script que lea el volcado ya realizado y reescriba referencias.
- Los nombres de objetos son únicos por entorno → la copia necesita **otro prefijo** (propuesta: `SCA2`), y todas
  las referencias `rule!SCA_*`, `cons!SCA_*`, `recordType!…`, `processModel` deben reescribirse a los UUID nuevos.
- `createRecordType` vía MCP solo soporta tablas nuevas (`createTable = true`); no permite apuntar a las tablas
  existentes de `SCAC AWS DB`. Efecto colateral **deseado**: la copia tendrá sus propias tablas y no pisará datos
  del original. Se necesitará carga inicial de datos de prueba.
- Los CDTs (`SCAC_DS_*`, `generarStudAnul`, `mssConsultarSolicitudesDTO`…) y las **176 integraciones y 25
  connected systems de SCAC** no se duplican: son de solo lectura desde SCA y ya están compartidos por ANL/EDA.
  La copia los referencia tal cual.
- **Aislamiento incompleto por fuera de Appian**: aunque la copia esté aislada en Appian, sus integraciones
  seguirán llamando a los mismos servicios PRE de PCA/Core7/SGC/Documentum que el original. Pruebas con pólizas
  reales de PRE afectarán a esos sistemas igual que hoy. Decisión necesaria (§6).

### 3.2 Pasos

| # | Paso | Herramienta | Verificación |
|---|---|---|---|
| 0.1 | Crear grupo `SCA2 Administradores` con exactamente dos miembros (solicitante + usuario de servicio de Devin). Sin grupos padre. | `createGroup`, `addGroupMembers`, `listGroupMembers` | lista de miembros = 2 |
| 0.2 | Crear aplicación `SCA2 - Sistema Comercial de Anulaciones (copia)` prefijo `SCA2`; seguridad de la app: Administrator = `SCA2 Administradores`, sin Viewers. | `createApplication`, `updateObjectSecurity` | `getObjectSecurity` de la app |
| 0.3 | Crear carpetas (reglas, constantes, PMs, documentos) con seguridad heredada del grupo anterior. | `createFolder` | `getObjectSecurity` de cada carpeta |
| 0.4 | Copiar en orden de dependencias: constantes → record types (+ campos) → expression rules → interfaces → PMs (+ nodos) → Web APIs → site. Reescritura de referencias por tabla UUID original → UUID copia. | script + `create*` | `validateDesignObject` sobre cada objeto; comparación de contadores con `docs/sca/anexos/inventario-generado.md` |
| 0.5 | Constantes de entorno de la copia: mismos hosts PRE que el original salvo decisión contraria; las 5 Web APIs copiadas con alias distinto (`sca2/...`) y sin publicar hasta la fase 2. | `createConstant`, `createWebApi` | `getWebApi` |
| 0.6 | Seguridad final: recorrer todos los objetos copiados con `getObjectSecurity` y forzar `Administrator = SCA2 Administradores` únicamente; `ModifySecurity` inicial de los PMs apuntando al nuevo grupo. | `updateObjectSecurity` | script que falla si aparece cualquier otro grupo |
| 0.7 | Comprobar que **ningún objeto original ha cambiado**: comparar `listObjectVersions` de los objetos SCA antes/después de la copia. | `listObjectVersions` | 0 versiones nuevas en SCA |
| 0.8 | Datos: crear 3-5 solicitudes sintéticas en las tablas nuevas (`insertRecordData`). | `insertRecordData` | `listRecordData` |

Rollback: `deleteApplication` de `SCA2` (y sus grupos/carpetas); el original no se toca en ningún paso.

### 3.3 Qué no se copia

- SCAC completo (se referencia). Si hiciera falta cambiar una integración, se crea `SCA2C_*` solo para esa.
- Los 68 documentos de SCA salvo plantillas usadas por interfaces copiadas.
- PMs claramente obsoletos: `SCA Alta Solicitud Anulacion` (original), `Copy of …`, `Batch Mecanizacion NSE_1/_2`
  duplicados. Se copian **solo para referencia** los dos PMs de alta, sin arrancarlos.

---

## 4. Fases de rediseño (sobre la copia)

| Fase | Contenido | Entregable en la rama |
|---|---|---|
| 1. Modelo de estado | Enum de estados y tabla de transiciones; nuevos campos/records (`historicoTransicion`, `comandoEjecutado`); revisar `nodorelanzar`/`error`. Sin PMs todavía. | `docs/sca/08-modelo-de-estados.md` + DDL de los record types |
| 2. Comandos base | `CMD_AltaSolicitud` (a partir de `SCA Generar Solicitud`), `CMD_DecidirAccion`, `CMD_Finalizar`. Orquestador con ramas `BORRADOR` → `PENDIENTE_DECISION` → `FINALIZADA`. Prueba: solicitud que las reglas resuelven a `FIN PROCESO` completa sin ninguna instancia > 1 min. | PMs + interfaz en SCA2; test de interfaz/reglas vía MCP (`testProcessModel`, `runAllExpressionRuleTestCases`) |
| 3. Contra anulación | Generalizar el patrón Estratégicas (`Alta`/`Finalizar`/`Posponer Contra Anulacion`) a PCA; descomentar rama en orquestador. | idem |
| 4. Autorización | `CMD_IniciarAccion`/`CMD_ResolverAccion(AUTORIZACION)`, documentos (Obtener/Subir Documentum) como PMs async con callback/polling. | idem |
| 5. Acciones administrativas y cambio de nivel | `CMD_CambiarNivel` (DUE, SGC, grupo), `CMD_Posponer`. | idem |
| 6. Mecanización | La más grande (64 nodos, 6 integraciones, Verti, ANL Alta, reserva de prima). Se aborda última y en dos sub-fases: alta/actualización y flujos NSE/Verti. | idem |
| 7. Caducidad y reactivadores | Adaptar `Batch Caducidad` para que actúe solo por BBDD (ya casi lo hace) y eliminar `Desbloquear Proceso Principal` / `eliminarTareas` como mecanismo de limpieza de PMs. | idem |
| 8. Paralelo y comparación | Misma póliza de prueba por los dos caminos (original en SCA, nuevo en SCA2) y comparación de escrituras en Core7/SGC/trazabilidad. | informe de comparación |
| 9. Promoción | Decisión de negocio: sustituir constantes de arranque (`SCA_PM_ALTA_SOLICITUD_ANULACION_PARTICION`) por el orquestador, o mover objetos SCA2 a SCA. Fuera del alcance de esta propuesta. | — |

Estimación: fases 0-2 en una sesión de trabajo; fases 3-5 una sesión cada una; fase 6 dos sesiones; fase 7-8 una.
Las esperas externas (decisiones de §6, datos de prueba en PRE) son el principal riesgo de calendario.

---

## 5. Criterios de aceptación

- Ninguna instancia de PM de SCA2 con duración > 5 min en el monitor de procesos durante las pruebas (salvo batch TM).
- Ningún `User Input Task` ni `Intermediate Consuming Event` en PMs de SCA2 (verificable con `listProcessModelNodes`).
- Toda transición queda registrada en `historicoTransicion` con usuario, comando, estado origen/destino,
  respuesta externa y error.
- Reejecutar el mismo comando dos veces (mismo `transactionid`) no produce doble escritura en Core7/SGC.
- Caducidad y reactivación funcionan con **cero** instancias vivas entre eventos.
- Los objetos originales de SCA no tienen versiones nuevas (`listObjectVersions`) al final de cada fase.

---

## 6. Decisiones que necesito del equipo antes de la fase 0

1. **Prefijo** de la copia (`SCA2` propuesto) y nombre de la aplicación.
2. **Miembros del grupo administrador**: usuario del solicitante y usuario técnico con el que opera el MCP de Devin
   (hay que confirmar qué cuenta usa `appian-dev-mcp-desarrollo-05c9`).
3. **Sistemas externos**: ¿se acepta que SCA2 llame a los mismos servicios PRE que SCA, o hay que crear
   connected systems/constantes `SCA2C_*` apuntando a un entorno de pruebas separado / mocks (por ejemplo Web APIs
   en SCA2 que simulen Core7)?
4. **Datos**: tablas nuevas generadas por Appian (aislamiento total, requiere datos sintéticos) o vistas de solo
   lectura sobre las tablas de SCAC AWS DB para consultas.
5. **Alcance de Vida/Estratégicas**: confirmar que el orquestador único debe cubrir ambos orígenes o si Vida se
   mantiene en su rama actual.
6. **Rama Mecanización NSE / Verti / reserva de prima**: confirmar que entra en el rediseño (fase 6) y no queda
   fuera de alcance.

---

## 7. Limitaciones de este análisis

- `SCA Alta Solicitud Anulacion` (original) solo se pudo leer por lista de nodos (error MCP `'interfaceUuid'
  KeyError`); el mapeo de §2.4 se ha hecho sobre el particionado, que contiene el mismo bucle de tramitación.
- No se han analizado datos reales de duración de instancias (no hay acceso al monitor de procesos vía MCP); las
  causas de §1.2 se deducen de la estructura de los PMs.
- Los subprocesos `Insertar Observaciones`, `ANL Alta` e `Inducción VERTI` pertenecen a otras aplicaciones y no
  están en el volcado; se tratan como cajas negras async.
