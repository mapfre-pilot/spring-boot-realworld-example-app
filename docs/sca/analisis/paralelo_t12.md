# Tanda 12 — Prueba en paralelo SCA vs SCA2 (solo medición)

Fecha: 2026-09-23. Solo lectura/medición; no se modificó ningún objeto Appian (los TEST
creados fueron eliminados tras la medición). `testProcessModel` ejecuta el modelo real
de forma síncrona: los tiempos incluyen las llamadas SOAP reales a Core7/PCA/SGC.

## 1. Tiempos SCA2 por PM (testProcessModel, `diagnostics.durationMs`)

| PM | UUID (sufijo) | Nodos | Ejecución | Duración | Resultado / filas escritas |
|---|---|---|---|---|---|
| CMD Alta (póliza 0007051068625, run1) | …28fc-14e7a | 13 | PDTE-268895704 | **7.034 ms** | COMPLETED · fault Core7 4004 «Datos insuficientes para la operacion» · 1 fila `SCA2 Error` (ALTA_ERROR) · 0 Solicitud/Transición/Tarea |
| CMD Alta (misma póliza, run2 — idempotencia) | | | PDTE-268895705 | **7.661 ms** | COMPLETED · idéntico: nueva idSolicitud + 1 Error; **sin filas duplicadas** para el mismo id |
| CMD Alta (0000253500263, run1) | | | PDTE-537333779 | **4.942 ms** | mismo fault 4004 + 1 Error |
| CMD Alta (0000253500263, run2) | | | PDTE-537333781 | **6.385 ms** | mismo fault 4004 + 1 Error |
| CMD Decidir (TEST-NIV-2) | …0eab-14e7a | 15 | — | **6.687 ms** | COMPLETED |
| CMD CrearAccion (TEST-NIV-2) | …0eaa-14e7a | 15 | — | **4.176 ms** | COMPLETED |
| CMD CompletarAccion (TEST-NIV-2) | …1307-14e7a | 14 | — | **5.697 ms** | COMPLETED |
| CMD Finalizar (TEST-NIV-2) | …1309-14e7a | 11 | — | **5.409 ms** | COMPLETED |
| CMD Mecanizar (TEST-NIV-2) | …4cfc-14e7a | 15 | — | **8.026 ms** | COMPLETED (rama de error Core7) |
| CMD Caducar (TEST-NIV-2) | …4f07-14e7a | 10 | — | **3.378 ms** | COMPLETED |
| CMD Posponer (TEST-NIV-2) | …8a47-14e7a | 5 | — | **3.360 ms** | COMPLETED |
| CMD CambiarNivel (TEST-NIV-2) | …8a54-14e7a | 8 | — | **3.861 ms** | COMPLETED |

- Mediana ≈ **5,4 s** por comando; el coste dominante es la red SOAP a
  `core7.pre.mapfre.net`, no el motor.
- Fault real capturado en `pv!generar.error`: `soapenv:Server 4004 Datos
  insuficientes para la operacion` + transporte `HTTP/1.1 500` — el flujo de error
  funciona (Write Error → End, sin Solicitud ni Transición, igual que el diseño).
- Idempotencia verificada a nivel idSolicitud: cada ejecución genera su propia
  clave `PDTE-*` y una única fila Error; no se duplican filas por solicitud.
- Limpieza: las 4 filas `SCA2 Error` de prueba (ids 53-56) borradas con
  `deleteRecordData`.

## 2. Baseline estructural SCA (diseño, dumps locales)

No hay tool de monitoring de instancias en el MCP (catálogo revisado: solo
`listMyTasks`/`completeTask` a nivel de tareas de usuario). Baseline documentado
previamente en el análisis: **1,55 M AMU / 21.659 instancias / 25.028 procesos
activos** — los PMs largos SCA acumulan estado en PVs durante semanas.

| Proceso SCA | Nodos | PVs | SubProc | User Input Tasks | Otros |
|---|---|---|---|---|---|
| Alta Solicitud Anulacion Particionado | 46 | 51 | 12 | 2 | 12 script, 12 XOR, 2 StartProcess, Reassign |
| Decidir Accion | 10 | 10 | 1 | 0 | — |
| Contra Anulación | 49 | 42 | 5 | 4 | 17 script, 12 XOR, 1 Receive (deprecated StartProcess) |
| Autorización | 37 | 22 | 5 | 3 | 12 script, 9 XOR |
| Acciones Administrativas | 37 | 28 | 5 | 3 | 10 script, 9 XOR |
| Mecanizacion (PM largo) | 64 | 34 | 11 | 2 | 16 script, 15 XOR, 2 Receive events, e-mail |
| Finalizar Contra Anulacion | 33 | 34 | 5 | 0 | 2 StartProcess, 2 Delete DSE |
| Finalizar Solicitud | 44 | 19 | 0 | 0 | 17 script, 17 XOR, 3 StartProcess, 1 Receive |
| Finalizar Mecanización | 40 | 27 | 9 | 0 | 13 script, 1 Receive |
| Alta Contra Anulacion | 14 | 8 | 1 | 0 | Reassign |
| Posponer Contra Anulacion | 15 | 19 | 1 | 0 | Write DSE |
| Guardar Trazabilidad | 4 | 7 | 0 | 0 | Write |
| DocxPDF | 9 | 23 | 0 | 0 | 2 PDF+2 Docx |
| Batch Caducidad | 23 | 17 | 3 | 0 | 3 CALLI |

Equivalentes SCA2 (orquestador atómico): Alta 13 n/22 pv · Decidir 15 ·
CrearAccion 15 · CompletarAccion 14 · Finalizar 11 · Mecanizar 15 · Caducar 10 ·
BarridoCaducidad (paginado) · Posponer 5 · CambiarNivel 8 · GenerarPdf ~7 ·
ObtenerDocumentoGD ~4 — **sin User Input Tasks, sin timers/Receive, sin
SUB_PROC**: el estado vive en record types, no en instancias abiertas.
Diferencia estructural clave: SCA ejecuta el flujo entero como 1 proceso de
46 nodos con 51 PVs y 2 UITs; SCA2 lo parte en comandos de ≤15 nodos
sincrónicos lanzados desde la interfaz. AMU esperada: órdenes de magnitud
menor (instancias que viven segundos y se borran al día).

## 3. Contratos de integraciones (diff textual body SCA vs SCA2)

Comparados los 104 objetos tipo integración en la app SCA2 contra sus
originales SCA/SCAC (dumps):

- **`bodyContent` idéntico en todas** salvo renombres esperados:
  `rule!SCA_obtenerUserPassSimularPoliza` → `SCA2_obtenerUserPassSimularPoliza`
  (en `simularAnulacionPolizaIntegracion`) y `SCAC_APIClients_Login` →
  `SCA2_APIClients_Login` (en `SCA2_APIClients_Address`). Mismo XML SOAP,
  mismo DTO (`generarStudAnul`/`mseSolicitudAnulacionDTO`, `IGenerarContraAnul`,
  `insertarObservaciones`, etc.) — consistente con "misma integración, mismo body".
- `consulta` input tipado CDT → Map (por diseño, sin CDTs nuevos).
- Headers: valores literales almacenados como expresión `"texto"` vs literal —
  equivalente funcional (en runtime evalúa al mismo header).
- `ignoreEmptyHeaders`/`ignoreEmptyQueryParameters`/`errorHandling` None↔True/DEFAULT
  — defaults de creación del MCP, equivalentes en práctica.
- Wrapper rules `SCA2_PreGenerarStudAnul`/`SCA2_mapSalidaGenerarStudAnul`/
  `SCA2_actualizacionVariablesPostGenerarStudAnul`: diff vs originales SCA = 0
  (tras normalizar el prefijo SCA2→SCA).
- Único objeto sin original emparejado: `SCA2_SCA_CMP_APIClients_Perfil`
  (revisar de dónde salió; posible duplicado de `SCA_CMP_APIClients_Perfil`).

## 4. Discrepancias UI (pantalla a pantalla)

### 4a. Gaps visuales confirmados en navegador real (sca-site vs sca2, lead)
1. Buscador default tab: SCA abre en "Cliente"; SCA2 abre en "Póliza".
2. Pestaña Póliza: SCA = Número póliza* / Matrícula* / Número bastidor*;
   SCA2 = Número de póliza* / Nº solicitud.
3. ALTA SOLICITUD ANULACIÓN: SCA = botón rojo relleno que abre popup in-page
   pidiendo Número póliza; SCA2 = enlace rojo a página "Alta" del site.
4. Nav del site: SCA = "Solicitudes anulación" + "Gestiones mantenimiento";
   SCA2 añade "Alta" y "Errores".
5. Botones: SCA LIMPIAR gris secondary, BUSCAR SOLICITUD rojo disabled hasta
   campos obligatorios, ambos a la derecha; SCA2 LIMPIAR red outline a la
   izquierda, BUSCAR siempre habilitado.
6. Fechas grid: SCA "2026-09-22 12:53:22"; SCA2 "22/09/2026 22:30 CEST".
7. Columna Estado: SCA etiquetas de negocio con tags de color; SCA2 códigos
   crudos (EN_ACCION, PDTE_FINALIZAR) en gris.
8. Grid: SCA 8 columnas ordenables + "Elementos 1 a 10 de 194"; SCA2 solo 5.
9. Alta: SCA header card (flecha atrás, "póliza - nombre - NIF", toggle
   Más Datos, tabs Datos cliente/Datos póliza/Otras sol./Datos contacto) +
   form card; SCA2 una sola card con texto debug "Tipo de póliza wAutemis".
10. Alta form: en SCA2 falta Compañía aseguradora contraria+lupa, Número fax,
    Canal entrada contacto como texto "1" en vez de dropdown "PRESENCIAL",
    Medio comunicación vacío, campo extra "Teléfono Expertos", Tipo
    catalogación texto libre en vez de dropdown, falta info box, falta
    contador 0/240, Cancelar sin confirm dialog. Label "Motivo anulación*" OK.
11. Detalle: SCA = header card con 6 tabs (incl. "Solicitud Anulación" y
    "Notificaciones") + acordeón de acciones con tags de estado; SCA2 =
    cabecera técnica (idSolicitud/Estado/Proceso activo/Interfaz activa,
    error SOAP crudo) + grids Tareas/Transiciones/Errores + botón Mecanizar.
12. Footer: links en negrita en SCA; sin negrita en SCA2 Buscador.

### 4b. Diff de literales por código (complementario)
- `SCA2_BuscadorTabla` contiene las etiquetas de estado de negocio
  (Caducada/Cancelada/Finalizada positivamente/…) pero el grid muestra el
  código crudo → falta el mapping estilo `SCA_textoEstadoSolicitud`+color.
- `SCA2_AccionesAdministrativasDocumentacion`: 77 vs 77 literales — paridad
  total de textos con `SCA_AccionesAdministrativasDocumentacion`.
- `SCA2_GenerarContactoVerti`: 13 vs 13 — paridad total.
- Mensajes de validación presentes en SCA y ausentes en SCA2:
  - CA Opciones: "Deben ejecutarse los argumentos obligatorios previamente",
    "El argumento no puede volver a ejecutarse", "Es obligatorio adjuntar el
    DNI", "El campo de observaciones ha sobrepasado el límite de 999
    caracteres", "Hay argumentos obligatorios de mayor prioridad…".
  - AccAdm: "Los datos se han guardado correctamente", "Los datos no se han
    podido guardar correctamente", "Es necesario informar la entrega de
    algún documento", "La acción ya ha sido pospuesta".
  - FueraNorma: "Adjuntar Documentacion".
  - AltaPopup/Alta: "El formato de la póliza no es el esperado", "La longitud
    del número de póliza debe ser inferior a 13 caracteres", "El usuario no
    tiene permisos para realizar altas", "El formato del fax es incorrecto",
    "POLIZA EN PRRA", info box catalogación, texto confirm de cancelar
    (ver gap 10).
- `SCA2_AltaSolicitudPage` (form) es un diseño distinto al popup+form SCA —
  gap estructural ya cubierto en 4a-9/10.

## 5. Qué corregiría, priorizado

| # | Corrección propuesta | Impacto |
|---|---|---|
| 1 | BuscadorTabla: columna Estado con etiquetas de negocio + tag color (regla `SCA2_textoEstadoSolicitud` ya existe — cablearla al grid) y formato fecha `yyyy-MM-dd HH:mm:ss` | paridad visual inmediata |
| 2 | Buscador: pestaña por defecto "Cliente", campos Póliza (Número póliza/Matrícula/Número bastidor), BUSCAR disabled-hasta-obligatorio + LIMPIAR secondary; botón ALTA como primary rojo con popup in-page (eliminar página "Alta" del nav o mantenerla oculta) | primera pantalla del usuario |
| 3 | Alta: portar `SCA_AltaSolicitudAnulacionPopUpEstrategicas` + `…Estrategicas` completa (header card de datos, dropdowns PRESENCIAL/catálogo, compañía+lupa, fax, validaciones de formato, contador 0/240, confirm cancel, info box) | gap funcional real (faltan campos) |
| 4 | Detalle: header card con tabs cliente/póliza/solicitud/otras/contacto/notificaciones + acordeón de acciones con tags de estado (componentes SCA existentes listados en §6) | paridad estética+negocio |
| 5 | Mensajes de validación faltantes en CA Opciones/AccAdm/FueraNorma (lista §4b) | comportamiento de error del original |
| 6 | Eliminar/restaurar `SCA2_SCA_CMP_APIClients_Perfil` si duplica el de SCAC | higiene |
| 7 | Footer links en negrita; quitar texto debug "Tipo de póliza wAutemis" y campos "Teléfono Expertos" sobrantes de Alta | pulido |

## 6. Objetos SCA de referencia para paridad UI (read-only, dumps/MCP)

| Pieza de pantalla | Objeto SCA | UUID | Rol en SCA2 actual |
|---|---|---|---|
| (a) Página Buscador | `SCA_BuscadorSolicitudPrincipalEstrategicas` | `_a-0000eebe-52f3-8000-9ca6-011c48011c48_18292718` | `SCA2_Buscador` |
| — grid del buscador | `SCA_BuscadorTablaEstrategicas` | `_a-0000eec6-fe87-8000-9ca7-011c48011c48_18311677` | `SCA2_BuscadorTabla` |
| (b) Popup alta (Número póliza + CANCELAR/ALTA SOLICITUD ANULACIÓN) | `SCA_AltaSolicitudAnulacionPopUpEstrategicas` | `_a-0000eebe-52f3-8000-9ca6-011c48011c48_18290304` | ninguno (SCA2 usa página "Alta") |
| (c) Header Detalle (flecha, "póliza - nombre - NIF:", Más Datos, tabs) | `SCA_DecidirAccion` (+`SCA_DatosCabecera_Estrategicas` para cabecera cliente) | `_a-0000ee64-4a6f-8000-9c9f-011c48011c48_17577825` / `_a-0000ee64-4a6f-8000-9c9f-011c48011c48_17871044` | `SCA2_DetalleSolicitud` / `SCA2_DetalleCabecera` |
| (d) Tab "Datos cliente" | `SCA_DatosCliente` | `_a-0000eb64-971e-8000-9c0e-011c48011c48_1676972` | `SCA2_DatosCliente` (sin consumo en Detalle) |
| (d) Tab "Datos póliza" | `SCA_DatosPoliza` | `_a-0000eb64-971e-8000-9c0e-011c48011c48_1677001` | `SCA2_DatosPoliza` |
| (d) Tab "Solicitud Anulación" | `SCA_SolicitudAnulaci_n` | `_a-0000eb64-971e-8000-9c0e-011c48011c48_1701045` | `SCA2_DetalleDatos` (parcial) |
| (d) Tab "Otras sol. Anulación" | `SCA_TablaOtrasSolAnulaci_n_Estrategicas` | `_a-0000ee64-4a6f-8000-9c9f-011c48011c48_17873480` | sin equivalente visible |
| (d) Tab "Datos contacto" | `SCA_DatosContacto` | `_a-0000eb64-971e-8000-9c0e-011c48011c48_1677139` | `SCA2_DatosContacto` |
| (d) Tab "Notificaciones" | `SCA_TablaNotificaciones` | `_a-0000ef79-7a00-8000-9cb4-011c48011c48_19083735` | sin equivalente |
| (e) Acordeón de acciones (Alta Solicitud [Finalizada]/Acciones Administrativas [Incompleta]/Contra Anulación/…) | `SCA_DetalleAnulacion*Estrategicas` (Autorizacion `_a-…_18314216`, ContraAnulacion `_a-…_18313817`, Mecanizacion `_a-…_18314129`, AltaSolicitud `_a-…_18314262`) | — | `SCA2_DetalleTareas` (grid plano) |
| (f) Card formulario Alta | `SCA_AltaSolicitudAnulacionEstrategicas` (compañía+lupa, dropdowns, 0/240, confirm cancel, info box) | `_a-0000eebe-52f3-8000-9ca6-011c48011c48_18289725` | `SCA2_AltaSolicitudPage` (diseño simplificado) |
| — "Más Datos" milestone | `SCA_MilestoneMasDatosAltaSolicitud_Estrategicas` | `_a-0000ee64-4a6f-8000-9c9f-011c48011c48_17871063` | ninguno |
| — Compañía contraria + catálogo | `SCA_Compa_iaContrariaCatalogacion` | `_a-0000eb64-971e-8000-9c0e-011c48011c48_1680539` | parcial en `SCA2_ContraAnulacionCompaniaCatalogacion` (CA, no Alta) |
| (g) Estado→tag/color | lógica embebida en `SCA_BuscadorTabla*` (colores `#008C47` verde, `#BE0F0F` rojo, `#E46B15` naranja, `#734B30` marrón, `#9F9F9F` gris, `#0D82BD` azul) + `SCA_calcularEstadoSolicitud` `_a-0001ef2c-f97c-8000-9cb0-011c48011c48_18789454` | — | `SCA2_textoEstadoSolicitud`/`SCA2_D_ColorEstadoGestion` existen pero sin cablear al grid |
| (g) Formato fecha | literales `text(…,"yyyy-MM-dd HH:mm:ss")` en BuscadorTabla; `dd/MM/yyyy HH:mm:ss` en TablaOtrasSolAnulación | — | `SCA2_convertirAFecha` |
