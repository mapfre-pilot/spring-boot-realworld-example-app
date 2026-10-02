# Alineación del plan con los planes previos (NTT DATA y Appian Accelerate)

Comparación entre el plan de la rama ([07-plan-rediseno-procesos-atomicos.md](07-plan-rediseno-procesos-atomicos.md))
y la documentación previa facilitada por el solicitante:

| Documento | Autor / fecha | Contenido relevante |
|---|---|---|
| *SCA – Acciones estratégicas v2* | NTT DATA, mayo 2025 | Diseño de la partición del PM principal en procesos cortos + pantallas; plan conjunto con la incorporación de Vida |
| *SCA – Plan de acción julio 2025* | NTT DATA, 11/07/2025 | Incidencias de PRO, plan de estabilización y resiliencia, planificación jul-dic 2025 |
| *Plan de estabilización SCA* | NTT DATA, 22/08/2025 | Estado de incidencias (Service Manager / Jira `ESMSA-*`) y avance de las acciones estratégicas |
| *Application Development Review v3* | Appian Accelerate, jul-sep 2024 | Code review: 10 urgentes, 28 altas, 17 medias, 15 bajas |
| *Evaluación Best practices* | Appian, julio 2025 | Resumen de revisiones, war room nov-dic 2024, records sincronizados, métricas AMU de PRO |

Conclusión general: **el plan de la rama y las "acciones estratégicas" de NTT describen la misma solución**
(estado en BBDD, procesos activos solo hasta persistir, pantallas sin proceso vivo, siguiente proceso lanzado al
completar la tarea). Las diferencias son de detalle y se han incorporado al plan (revisión 2). Lo que el plan de la
rama añade es la copia aislada `SCA2`, la gestión de errores desde el principio, la optimización de los objetos al
replicarlos y el checklist Accelerate como criterio de aceptación.

---

## 1. Qué dicen los planes de NTT (hechos tomados de los documentos)

### 1.1 Diseño de las acciones estratégicas (mayo 2025)

- Contexto: problemas de rendimiento en noviembre 2024; medidas tácticas permitieron volver a desplegar en la red de
  oficinas; queda pendiente la medida estratégica: **sustituir el enfoque de tareas por records en BBDD** para no
  mantener procesos activos durante el ciclo de vida de la solicitud y gestionar todo desde interfaces.
- Bloques del nuevo flujo: `Pantalla Alta → Proceso Alta → Proceso Decisión → Proceso Crear Acciones → Pantalla
  Acciones → Proceso Completar Acciones → Proceso Finalizar`, más `Proceso Salto de nivel`. Los procesos (naranja)
  solo viven hasta actualizar BBDD y lanzar el siguiente; durante las pantallas (verde) no hay procesos activos.
- Subprocesos de tarea con el mismo patrón: `Crear tarea → Pantalla → Posponer / Completar tarea`.
- Consideraciones técnicas:
  - Pantallas y procesos recuperan de BBDD lo que necesitan.
  - Persistir la finalización de una tarea manual **desde la pantalla** (el usuario ve el error y relanza).
  - Persistir la creación de una tarea como **último punto del proceso previo**; si falla, no redirigir.
  - Las pantallas esperan a que los procesos necesarios terminen y hayan guardado en BBDD antes de redirigir.
  - Ante error, el proceso finaliza y guarda en BBDD el punto de fallo para retomarlo (procesos arrancables desde un
    punto concreto; pantalla de detalle con relanzar o bandeja de errores).
  - La pantalla Decisora se sustituye por **acceso controlado al site** que consulta BBDD (¿existe solicitud?) y
    redirige a Alta o a Detalle; el Detalle consulta BBDD para decidir la pantalla.
- Fases de construcción: Fase I: Alta, Detalle, Decisión, Contra anulación, Mecanización Vida. Fase II: Acciones
  administrativas, Verti, Mecanización, Autorización, Finalizar. Orden tentativo.
- Volumetría: 10.000 solicitudes/día; Vida añade ~7.000/día. Fecha comprometida de Vida en PRO: 19/10/2025.
  Arquitectura MAPFRE exige las acciones estratégicas **antes** de incorporar Vida.

### 1.2 Plan de acción (julio 2025) y plan de estabilización (agosto 2025)

- Líneas: resolución de incidencias, estrategia con NSE, plan de resiliencia, acciones estratégicas ("reducir la
  duración máxima de semanas a pocos minutos"), resolución de la revisión Accelerate.
- Acciones estratégicas divididas para reducir impacto: (1) crear BBDD de estado, (2) nuevo site de acceso único
  reutilizando interfaces actuales, (3) dividir el proceso en subprocesos entre transiciones de pantalla — *con
  impacto en mantenibilidad: cualquier cambio hay que aplicarlo en las dos partes*, (4) gestión de errores por BBDD
  **después** de la división, (5) optimizaciones posteriores.
- Planificación: duplicado del proceso SCA en PRE para corregir incidencias productivas y crear los nuevos
  subprocesos, portando a estos las correcciones hechas en la versión de PRO; implantación de SCA con acciones
  estratégicas prevista para noviembre 2025.
- Puntos que hoy provocan bloqueos y relanzamientos manuales: salto de nivel SGC, posponer con SGC, consulta de
  reglas, servicio de cabecera (productor), servicios de documentación, NSE/NEW, STCAT/SGO.
- Estado a 22/08/2025: BBDD creada; site de acceso retrasado (28/08); subproceso Alta en curso (28/08). Dos reuniones
  semanales con Appian y OT. Entorno PRE bloqueado por enmascaramiento.
- Incidencias con relación directa con la duración de los procesos: solicitudes que **caducan automáticamente** e
  impiden completar la anulación (relanzadas a mano a diario), solicitud bloqueada que requiere desbloqueo por SCA,
  "la tarea no existe", problema de records sincronizados al relanzar, anulaciones enviadas que quedan incompletas
  y caducan (`ESMSA-507`).

---

## 2. Qué dice Appian Accelerate (hechos tomados de los documentos)

### 2.1 Code Review 2024 — hallazgos sobre procesos

- **Urgente**: eliminar process messaging; añadir exception flows a las user input tasks (junto con hacer los
  procesos de corta vida); cargas de interfaz con pocas integraciones; no fallos silenciosos de integración; load
  testing; métodos HTTP correctos; autenticación soportada en integraciones.
- **Alta**: muchos PMs activos más de un día (hasta dos semanas) → migrar a enfoque record/data-centric; procesos
  atómicos (uno hace una cosa u orquesta varios que hacen una cosa); swim lanes en todos los PMs; integraciones
  encapsuladas en subprocesos con manejo de error estándar; evitar script tasks consecutivos; activity chaining solo
  donde hace falta (< 50 nodos / 5 s), sacar subprocesos asíncronos de la cadena; minimizar datos en integraciones
  y Web APIs; response logging desactivado; documentar dependencias entre aplicaciones; test cases con aserciones
  en reglas; revisar porcentaje de completitud de PMs (en TEST ~900 procesos sin terminar por user input tasks sin
  escalado, p. ej. `SCA Iniciar Proceso PCA` y `SCA Alta Solicitud Anulacion`).
- **Media/baja**: ≤ 30 nodos por PM; display names dinámicos; SAIL corto en entradas/salidas de nodos (ej.
  `posponer Acción Administrativa` en `SCA Acciones Administrativas`); `loggedInUser()` en PM devuelve
  *Administrator*; variables ocultas; pasar claves y no CDTs; un solo Write to Data Store múltiple; descripciones en
  objetos; aplicación *Deprecated* para objetos sin uso; matriz de grupos/funcionalidad; grupo admin de organización;
  deshabilitar Tempo.
- Nota del Code Review: 2.000 casos/día y 8.000 usuarios en 2024; el enfoque de reemplazo "tal cual" de webMethods
  es parte de la causa.

### 2.2 Best practices (julio 2025)

- War room nov-dic 2024: reducir procesos por instancia; aligerar el proceso padre hasta la tarea de usuario;
  paralelizar llamadas; archivado; eliminar duplicidades en la Decisora; reducir nodos en cadena y llevarlos a reglas;
  rediseño de `SCA Solicitud Anulación` a *case management* (estado en BBDD en vez de temporizador de espera);
  optimizar `SCA Subir Documentos Documentum` / `Eliminar documentos`.
- Reintentos por eventos ante fallos de servicios; persistir información del proceso en BBDD **con cuidado** (Appian
  desaconseja CDTs anidados); modularización por ramo con subprocesos comunes; procesos lo más atómicos posible.
- Records sincronizados para datos referenciales/inmutables (criterios: poco cambiantes, con id único, < 4 M filas,
  campos < 4.000 caracteres). Caso: `ListarCiasPoliza` ~125.000 ejecuciones/día. PoC comprometida con
  `SCA_GestionAplicacion`.
- Interfaces: no lanzar todas las integraciones en carga; paginación/filtrado (`SCA_BuscadorTabla`); integraciones
  ANL con el 100 % del tiempo fuera de Appian (latencia externa).
- Métricas PRO 4/7/2025 (baseline recogido en §1.4 del plan): 25.028 procesos activos; `SCA Alta Solicitud
  Anulacion` 1,55 M AMU / 21.659 instancias; etc. Reglas con test cases: 66 %. 80 objetos sin referencia.
- Directriz: **no introducir funcionalidad nueva en SCA hasta estabilizar** y dividir el proceso.

---

## 3. Comparación con el plan de la rama

### 3.1 Coincidencias

| Tema | NTT / Accelerate | Plan de la rama |
|---|---|---|
| Fuente de verdad | BBDD; pantallas y procesos leen de BBDD | §2.1.1 |
| Procesos activos | solo hasta persistir y lanzar el siguiente | §2.1.3, §2.1.8 |
| Tareas humanas | pantallas sin proceso; siguiente proceso al completar | §2.1.2, §2.5 |
| Bloques | Alta / Decisión / Crear acción / Pantalla / Completar acción / Finalizar / Salto de nivel | `CMD_AltaSolicitud`, `CMD_DecidirAccion`, `CMD_IniciarAccion`, orquestador, `CMD_ResolverAccion`, `CMD_Finalizar`, `CMD_CambiarNivel` |
| Subprocesos de tarea | Crear / Posponer / Completar | `CMD_IniciarAccion`, `CMD_Posponer`, `CMD_ResolverAccion` |
| Reintentos | por eventos / desde punto de fallo | `nodorelanzar` + `CMD_Relanzar` (§2.1.6) |
| Duplicado para trabajar | "duplicado del proceso SCA en PRE" | Fase 0: copia `SCA2` aislada |
| Atomicidad, ≤ 30 nodos, sin process messaging | Accelerate | §2.7 checklist |

### 3.2 Diferencias y cómo se han resuelto en la revisión 2 del plan

| # | Diferencia | Resolución |
|---|---|---|
| 1 | NTT sustituye la Decisora por un **site de acceso único + pantalla Buscador/Detalle**; el plan hablaba de "interfaz orquestadora" evolucionando `SCA_DecidirAccion`. | Adoptada la estructura de NTT (§2.2): site → inicio (¿existe solicitud?) → Alta / Detalle → pantallas de acción. El Detalle *es* el orquestador. SCA2 parte de los objetos `*Estrategicas` ya construidos. |
| 2 | NTT fija **dónde se persiste**: completar tarea desde la pantalla; crear tarea como último nodo del proceso previo. El plan lo dejaba dentro de los `CMD_*`. | Incorporado como principio §2.1.7. |
| 3 | NTT: la pantalla **espera** a que el proceso escriba en BBDD antes de redirigir; el plan proponía todo asíncrono. | Principio §2.1.8: síncrono (chaining < 5 s / < 50 nodos) hasta el write, asíncrono después. |
| 4 | NTT **pospone la gestión de errores** para no duplicar mantenimiento durante la división. | En SCA2 no hay doble implementación del mismo flujo, así que la bandeja de errores y el relanzado se construyen en la fase 2 (§4). Cubre las incidencias top del plan de estabilización (caducadas, "la tarea no existe", solicitudes bloqueadas, relanzamientos manuales). |
| 5 | Orden de construcción: NTT prioriza Alta, Detalle, Decisión, Contra anulación y Mecanización Vida; el plan situaba Autorización antes que Acc. Adm. y Finalizar en la fase 2. | Orden ajustado a bloques I/II de NTT (§4), manteniendo `CMD_Finalizar` mínimo en fase 2 para poder cerrar solicitudes de prueba. |
| 6 | NTT modulariza **por ramo** con subprocesos comunes. | Principio §2.1.10: `CMD_*` comunes parametrizados por `ramo`; lógica específica en reglas seleccionadas con `a!match`. |

### 3.3 Añadidos que no estaban en ninguno de los dos

| # | Añadido | Dónde |
|---|---|---|
| 7 | Baseline medible de PRO (AMU, instancias, volumetría) como criterio de éxito | §1.4 y §5 del plan |
| 8 | Checklist Accelerate por objeto como condición de "terminado" en SCA2 | §2.7 |
| 9 | Records sincronizados para datos inmutables de póliza y lazy loading en el Detalle | §2.6, decisión §6.7 |
| 10 | Registro de correctivos `ESMSA-*` de SCA a portar a SCA2 durante el proyecto | §4 (`anexos/correctivos-a-portar.md`) |
| 11 | Aislamiento de seguridad de la copia (grupo de dos miembros, verificación de que SCA no recibe versiones nuevas) | Fase 0 |
| 12 | Pregunta abierta: estado real en DEV de lo construido por NTT tras agosto 2025 | decisión §6.8 |

---

## 4. Riesgos heredados de los documentos que el plan debe vigilar

- **PRE bloqueado por enmascaramiento** (agosto 2025): puede impedir pruebas con pólizas reales en la fase 8.
- **Latencia externa**: integraciones ANL/Core7 con el 100 % del tiempo fuera de Appian; los `CMD_*` no la
  eliminan, solo evitan que una instancia espere por ella. Se mitiga encapsulando cada integración con timeout y
  error reintentable (§2.7) y con reintentos por batch.
- **Directriz de no añadir funcionalidad a SCA**: el trabajo en SCA2 la respeta (no se toca SCA), pero la promoción
  final (fase 9) tendrá que coordinarse con lo que NTT haya desplegado entre tanto.
- **Vida**: si el orquestador único cubre PCA y Estratégicas, la mecanización Vida (bloque I) es el primer camino
  completo a probar; confirmar con negocio que el flujo Vida en DEV es representativo.

---

## 5. Fuentes

Documentos facilitados por el solicitante (no versionados en el repositorio):

- `MAPFRE España - Plan de Estabilización_SCA 20250822.pptx`
- `MAPFRE Spain - SCA - Evaluación Best practices - July 2025 v1.pdf`
- `SCA - Acciones estrategicas v2 (3).pptx`
- `SCA - Application Development Review v3 - MAPFRE SA (Spain).pdf`
- `SCA - Plan de Acción julio 2025-07-11.pptx`
