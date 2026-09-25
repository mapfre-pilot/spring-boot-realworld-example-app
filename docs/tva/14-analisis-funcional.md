# 14. Análisis funcional — Tarificador Vida Ahorro (TVA)

Documento funcional de la aplicación Appian **Tarificador Vida Ahorro** (uuid
`e922a3b8-7bb8-4c61-b926-e4ee365b75fc`), redactado para lectores de negocio.
Toda afirmación es trazable a un objeto del volcado de diseño (`/home/ubuntu/tva`)
o a los documentos técnicos previos; la columna **Fuente Appian** nombra el
objeto concreto (interfaz `TVA_*`, regla `rule!TVA_*`, proceso `PM TVA_*`,
constante `cons!TVA_*`, grupo, Web API). No se documentan hostnames ni credenciales.

## 1. Objetivo y alcance funcional

TVA es el tarificador que usa el gestor de MAPFRE (oficina/productor) desde el
Portal Financiero para **simular, tarificar y contratar** productos de Vida
Ahorro y Rentas para uno o dos tomadores. Cubre: captura de datos de tomadores,
intervinientes y beneficiarios, opciones de inversión, garantías, domiciliaciones,
documentación precontractual, firma y emisión de la póliza.
*(Fuente: `docs/tva/01-vision-general.md`, interfaces `TVA_Pantalla_*`)*

La aplicación **no arranca de forma autónoma**: el portal la invoca mediante dos
Web APIs (`tarificadorVidaAhorro` para ahorro y `simuladorRentas` para rentas) que
crean la sesión (`TVA_Sesion`) y devuelven la URL con `claveSesion`. Abrir el site
sin sesión muestra el fin de ejecución genérico. *(Fuente: Web APIs `TVA Inicio*`,
`TVA_Principal` rama `default`, sites `tarificadorVidaAhorro`)*

Modos de funcionamiento (`indFunctionMode` de la request de inicio):

| Modo | Negocio | Test previo requerido | Fuente Appian |
|---|---|---|---|
| **VA** — Venta Asesorada | Parte de una propuesta (`proposalId`) con seguros de ahorro ya captados | Test de idoneidad | `cons!TVA_VAL_VENTA_ASESORADA`, `rule!TVA_EsValidoTestIdoneidad`, `rule!TVA_WebApi_Inicio_ObtenerMensajeError` (`proposalId` obligatorio en VA) |
| **VIA** — Venta Informada | El usuario elige producto y opciones de inversión (Unit Linked, PPA, cestas) | Test de conveniencia | `cons!TVA_VAL_VENTA_INFORMADA`, `rule!TVA_EsValidoTestConveniencia` |
| **R2C** — Rentas | Simulador y contratación de rentas vitalicias | — | `cons!TVA_VAL_VENTA_RENTAS`, PM `TVA_Inicio_SimuladorRentas`, pantallas `R2C_*` |

Canales: el usuario llega con `companyId` y `distributionChannel` validados contra
`cons!TVA_CODIGOS_EMPRESA_ADMITIDOS` / `cons!TVA_CODIGOS_DISTRIBUTION_CHANNEL_ADMITIDOS`
(por defecto `cons!TVA_CODIGOS_*_POR_DEFECTO`). Los roles funcionales en la rama se
mapean a `TVA_USUARIO` y `TVA_ADMIN_PORTAL`.

## 2. Actores y roles

| Actor | Grupo(s) Appian | Qué ve / puede | Fuente Appian |
|---|---|---|---|
| Gestor / productor | `TVA_GRP_USUARIOS` | Ejecuta el flujo completo de tarificación | `groups/TVA_Usuarios`, constantes `TVA_GRP_*` |
| Administrador del portal | `TVA_GRP_ADMINISTRADORES_PORTAL` | Además de lo anterior: botón **Administración**, apertura/cierre, activar/desactivar funcionalidades, gestión de cachés, trazas | `groups/TVA_Administradores_portal`, interfaz `TVA_Pantalla_Administracion`, `TVA_Admin_*` |
| Equipo técnico / debug | `TVA_GRP_DEBUG` | Pantalla `TVA_Debug` (JSON de sesión, IP local) | `groups/TVA_Debug`, interfaz `TVA_Debug` |
| Alertas | `TVA_Alertas` | Recepción de avisos por email | `groups/TVA_Alertas`, `docs/tva/01` |
| Web API de inicio | `TVA_WebApi_Inicio` | Invocación autenticada de las Web APIs de arranque | `groups/TVA_WebApi_Inicio`, `web_apis/` |
| Administradores / SSO | `TVA_Administradores`, `TVA_Adm_Portal_SSO_*`, `TVA_SSO_Vida_*`, `TVA_Utilidades` | Seguridad de objetos y accesos SSO | `groups/*.json`, `docs/tva/06-seguridad.md` |

## 3. Mapa de procesos de negocio

```mermaid
flowchart TD
    A[Portal: Web API inicio VA/VIA/R2C] --> B{Validaciones inicio}
    B -- error --> AV[SOLO_AVISOS]
    B -- cerrada --> SC[SISTEMA_CERRADO]
    B -- sin perfil --> SP[SIN_PERFIL]
    B --> C{Modalidad}
    C -- VA --> SA[SEGUROS_AHORRO\nlista de seguros de la propuesta]
    C -- VIA --> SPB[SELECCION_PRODUCTO_AHORRO]
    C -- R2C --> RC[R2C_CAPTURA]
    SA --> CD[CAPTURA_DATOS_SOLICITUD]
    SPB -- producto en campaña --> MC[MODALIDAD_CAMPANIA]
    SPB --> T1[CAPTURA_TOMADOR1]
    T1 -- 2 tomadores --> T2[CAPTURA_TOMADOR2]
    T1 -- 1 tomador --> CD
    T2 --> CD
    RC -- Siguiente --> RP[R2C_PRECIOS]
    RP -- Atrás --> RC
    RP -- Recalcular --> RP
    RP -- Contratar --> RS[RESUMEN_CONTRATACION]
    CD -- Guardar y volver VA / Doc.Precontr.+Contratar VIA --> RS
    RS --> F{tipo de firma}
    F --> RF[RESULTADO_FIRMA]
    RF --> FIN[FIN]
    T1 & T2 -. pop-ups .-> PP[RGPD / DNI / Test conveniencia\nAppian Embedded]
    ADM[ADMINISTRACIÓN\nparámetros · apertura/cierre · cachés · trazas] -.-> cualquier pantalla
```

Decisiones de siguiente pantalla: `rule!TVA_propuestaProductosAhorro_siguientePantalla`
(VA: `SEGUROS_AHORRO` salvo 1 seguro sin `statusDesc` → Solicitud; VIA: producto →
campaña si `insuranceOfferInd` → Solicitud si `perfilClientesOK` si no Tomador 1;
R2C: `R2C_CAPTURA`→`R2C_PRECIOS`). La apertura/cierre se controla por el parámetro
`TVA_APLICACION_CERRADA` + `TVA_MENSAJE_MOTIVO_CIERRE` y el batch `PM TVA_Batch_Apertura-Cierre`.

## 4. Casos de uso funcionales

### 4.1 Inicio

| Campo | Detalle |
|---|---|
| Pantalla | Inicio (Web API `TVA InicioTarificadorVidaAhorro` / utilidades) |
| Objetivo | Crear la sesión TVA desde la request del portal |
| Entrada | `indFunctionMode`, `proposalId` (VA), `companyId`, `distributionChannel`, `username` `@mapfre.net`, `policyHolders[]`, `investment[]` (opciones de inversión VA) |
| Reglas de negocio (avisos literales) | `Request inválida`; `El campo companyId no puede ser nulo` / `Valor de companyId no permitido`; `El campo distributionChannel no puede ser nulo` / `Valor de distributionChannel no permitido`; `El campo username no puede ser nulo` / `El nombre de usuario debe acabar en @mapfre.net` (NUUMA = parte local en mayúsculas); `El campo indFunctionMode no puede ser nulo` / `Valor de indFunctionMode no permitido`; `El campo proposalId no puede ser nulo si indFunctionMode es VA`; `No se admiten más de dos tomadores`; `En Venta Asesorada es obligatorio informar al menos un seguro de ahorro`; por `investment[i]`: `commercialProductCode: El valor informado no es válido`, `operationTypeCode: El valor informado no es válido`, `uniqueContributionAmn: El valor no puede ser negativo`, `periodicContributionAmn: El valor no puede ser negativo`, `Los dos importes no pueden ser nulos a la vez`, `contributionFrequencyCode: El valor informado no es válido` |
| Salidas | `claveSesion` + URL de la pantalla inicial según `siguientePantalla` |
| Fuente Appian | `rule!TVA_WebApi_Inicio_ObtenerMensajeError`, `rule!TVA_ValidacionInvestmentOption`, `rule!TVA_InicializarSesion`, PM `TVA_Inicio_Ahorro` / `TVA_Inicio_SimuladorRentas`, `cons!TVA_CODIGOS_*` |

### 4.2 Selección de producto / Seguros de ahorro

| Campo | Detalle |
|---|---|
| Pantalla | `SELECCION_PRODUCTO_AHORRO` (VIA) / `SEGUROS_AHORRO` (VA) |
| Objetivo | VIA: elegir producto del catálogo. VA: elegir uno de los seguros de la propuesta |
| Entrada | Catálogo API Life (`companyId`, canal, nuuma) / `insurancesApplication` de la propuesta |
| Reglas | 21 productos en DEV ordenados por `commercialProductDesc`; si el servicio no devuelve productos: `El servicio no ha devuelvo ningún producto de ahorro`; producto en campaña (`insuranceOfferInd`) → pantalla `MODALIDAD_CAMPANIA` |
| Salidas | `codigoProducto` → Tomador 1 o Solicitud |
| Fuente Appian | `TVA_Pantalla_SeleccionProductoAhorro`, `TVA_Pantalla_SegurosAhorro`, `rule!TVA_GetListaProductos*`, int. `TVA_API_Life_ProductList` |

### 4.3 Captura de tomador (1/2)

| Campo | Detalle |
|---|---|
| Pantalla | `CAPTURA_TOMADOR1` / `CAPTURA_TOMADOR2` |
| Objetivo | Alta completa del tomador con secciones plegables que quedan marcadas como válidas |
| Entrada | Secciones: datos personales, domicilio habitual, medios de contacto, FATCA/CRS, representante legal (opcional); panel derecho de requisitos |
| Reglas de negocio (avisos literales) | Datos personales: documento/nombre/primer apellido/fecha nacimiento/sexo/nacionalidad/país obligatorios; `Los campos Actividad, Sector y Profesión son obligatorios`; `El móvil es obligatorio`; `El correo electrónico es obligatorio`. Domicilio: `El/La … es obligatorio/a` (tipo vía, nombre, número, CP, localidad, provincia, país). Dirección de correspondencia: `El campo tipo de dirección es obligatorio`. Medios de contacto: tipo/prefijo/valor |
| Requisitos | RGPD (`consentimientoProteccionDatos`), digitalización DNI (`documentoIdDigitalizado`), test de conveniencia (`testConvenienciaVigente` + `perfilCliente.testConveniencia`), habilitados al ser válidos datos personales (y medios de contacto para el test). El resultado se verifica por la respuesta real del componente, no por el simple cierre |
| Salidas | Caja `CAPTURA_DATOS_TOMADOR_N` con `datosValidos` → Continuar (PM `TVA_CapturaTomadorN-Continuar`) → Tomador 2 o Solicitud |
| Fuente Appian | `TVA_Pantalla_CapturaTomador`, `TVA_DatosParticipanteV2`, `TVA_DomicilioV2`, `TVA_MediosContacto`, `TVA_CapturaTomador_PanelDerecho`, `rule!TVA_CapturaTomador_*_Validacion`, PM `TVA_PopUp_RGPD/DigitalizacionDNI/TestConveniencia` |

### 4.4 Datos de la solicitud

| Campo | Detalle |
|---|---|
| Pantalla | `CAPTURA_DATOS_SOLICITUD` |
| Objetivo | Completar productores, datos del seguro y captura ampliada |
| Entrada | Cajas: Datos productores, Datos del seguro (operación, opciones de inversión, garantías, domiciliaciones), Captura ampliada (contacto, asegurado, beneficiarios, notas, cesión de derechos) |
| Reglas de negocio (avisos literales) | Operación: `Debe rellenar la prima única o la prima periódica`, `Debe seleccionar la periodicidad`, `El importe de la prima debe estar entre …`, `El valor debe estar en el rango 1 a 31` (día de cobro), reinversión, duración, jubilación, `La fecha de alta de la minusvalía no puede ser un valor futuro`. Inversión: `Debe seleccionar la opción de inversión`, `La suma de los importes de la prima única debe coincidir con el total de la operación`, `El plazo objetivo no puede ser nulo`; la primera opción seleccionada auto-rellena la prima. Domiciliaciones: `El IBAN de pago de recibos no puede ser nulo`, `El IBAN de pago de prestaciones no puede ser nulo`, `IBAN inválido`. Beneficiarios: `Debe incluir en el texto libre el beneficiario`. Notas: `Hay notas seleccionadas que deben llevar texto obligatoriamente`. Info VIA: `El importe máximo anual que el cliente puede contratar para la agrupación fiscal es de 7.500 €` |
| Salidas | VA: Guardar y volver (PM `TVA_Guardar_y_volver`) → Resumen. VIA: Doc. Precontractual (PM `TVA_DocumentacionPrecontractual`, confirmación *"Se va a enviar un correo al cliente…"*) + Contratar. R2C: Contratar |
| Fuente Appian | `TVA_Pantalla_CapturaDatosSolicitud`, `TVA_Caja*`, `TVA_Seccion*`, `rule!TVA_DatosDeLaOperacion_Validacion`, `rule!TVA_Domiciliaciones_Validacion`, PM `TVA_ImporteMaximo` |

### 4.5 Rentas (R2C)

| Campo | Detalle |
|---|---|
| Pantalla | `R2C_CAPTURA` / `R2C_PRECIOS` |
| Objetivo | Simulación de rentas con dos tomadores |
| Entrada | Datos económicos (importe total prima, periodicidad) + 2 tomadores (DNI, fecha nacimiento, % participación) |
| Reglas (avisos literales) | `Son obligatorios dos tomadores`, `El importe total de la prima es obligatorio`, `La periodicidad de la renta es obligatoria`, por tomador: `: el número de DNI es obligatorio`, `: la fecha de nacimiento es obligatoria`, `: el porcentaje de participación es obligatorio` |
| Salidas | Precios: Atrás / Recalcular / Contratar |
| Fuente Appian | `TVA_Pantalla_R2C_*`, `TVA_R2C_*`, `rule!TVA_SimuladorRentas_Captura_Validacion`, `rule!TVA_DatosDeLaOperacionRentas_Validacion`, PM `TVA_R2C_*` |

### 4.6 Resumen, firma y fin

| Campo | Detalle |
|---|---|
| Pantalla | `RESUMEN_CONTRATACION` / `RESULTADO_FIRMA` / `FIN` |
| Objetivo | Resumen con importes, documentos precontractuales, selección y ejecución de la firma |
| Entrada | Cajas resumen (ahorro/rentas), `CajaSeleccionTipoFirma`, `CajaDatosFirma`, `CajaDocumentosPrecontractuales` |
| Reglas | Tipos de firma según flags `TVA_FLAG_FIRMA_*` (manuscrita, electrónica, biométrica); resultado muestra documentos de póliza; Cancelar en cualquier punto (confirmación `Va a cancelar el proceso de captura. ¿Está seguro?`) → `FIN` y avisos a null |
| Salidas | `La aplicación ha terminado su ejecución, puede cerrar el navegador` |
| Fuente Appian | `TVA_Pantalla_ResumenContratacion`, `TVA_CajaSeleccionTipoFirma`, `TVA_CajaResultadoFirma`, PM `TVA_PopUp_Firmar`, `TVA_Firma-EnvioFirmaManuscrita`, `TVA_Firmar` |

### 4.7 Administración

| Campo | Detalle |
|---|---|
| Pantalla | `ADMINISTRACION` (solo `TVA_GRP_ADMINISTRADORES_PORTAL`) |
| Objetivo | Operación de la aplicación sin despliegues |
| Funciones | Activar/desactivar funcionalidades (`TVA_FUNCIONALIDAD_*`), apertura/cierre (parámetro `TVA_APLICACION_CERRADA` + motivo `TVA_MENSAJE_MOTIVO_CIERRE`), gestión de cachés, consulta de trazas por sesión |
| Fuente Appian | `TVA_Pantalla_Administracion`, `TVA_Admin_ActivarDesactivar`, `TVA_Admin_AperturaCierre`, `TVA_Admin_GestionCaches`, `TVA_Utilidades_Log`, `TVA_LogAplicacion` |

## 5. Reglas de negocio transversales

| Regla | Detalle | Fuente Appian |
|---|---|---|
| Documentos de identidad | NIF/NIE/CIF y arreglo PFM | `rule!MU_*`/`VIDA_*` de validación, `rule!TVA_ArregloNIF_PFM`, `cons!TVA_CODIGOS_TIPO_DOCUMENTO_DE_IDENTIDAD_ADMITIDOS` |
| IBAN | Obligatorio recibos/prestaciones y checksum IBAN | `rule!TVA_Domiciliaciones_Validacion` |
| Avisos | Clases (`GENERAL`, `DISCREPANCIAS`, `FIRMA`, `GET_PROPOSAL`, `INSURANCE_APPLICATION`, `SAVE_PROPOSAL`, `BUSQUEDA_RIC`, `ANNUITY_SIMULATION`, `TALLER`, `VERIFICAR_PRODUCTORES`), tipos INFO/WARNING/ERROR, `mostrarEn` CABECERA/SECCION | `cons!TVA_AVISOS_*`, `rule!TVA_Avisos_*`, interfaz `TVA_MostrarAvisos` |
| NUUMA | Parte local del `username` `@mapfre.net` en mayúsculas; identificador del gestor para API Life | `rule!TVA_WebApi_Inicio_ObtenerMensajeError`, reglas `*nuuma*` |
| Perfilado / idoneidad | `perfilCliente` (perfil, test conveniencia vigente), `perfilClientesOK` derivado de `policyHolders[].testData.convenience` | `rule!TVA_EsValidoTestConveniencia`, `rule!TVA_EsValidoTestIdoneidad`, PM `TVA_Perfil_cliente` |
| Importe máximo | Aviso informativo de agrupación fiscal (7.500 €) | PM `TVA_ImporteMaximo`, `rule!TVA_FactoriaRequestSBCMaximo` |
| Cajas/secciones | `sesion.cajas[].secciones[].datosValidos` gobierna el habilitado de la botonera y el plegado con marca verde | `rule!TVA_Caja_ControlDeCaja`, `TVA_Caja_ControlDeSeccion`, `cons!TVA_CAJA_INDEX_*` |
| Funcionalidades | Interruptores administrables que filtran capacidades por usuario | `rule!TVA_FiltroFuncionalidades`, `cons!TVA_FUNCIONALIDAD_*` |
| Trazas | Peticiones/respuestas y sesión se registran en la entidad de trazas; purga batch | `rule!TVA_GetInfoTraza`, `cons!TVA_TRAZA_*`, PM `TVA_Batch_Borrar_traza` |

## 6. Integraciones (visión funcional)

| Integración | Qué aporta al flujo | Fuente Appian |
|---|---|---|
| API Life | Catálogo de productos, propuesta, alta de solicitud, tipos de impresión, documentos precontractuales y de póliza, tablas generales | `TVA API Life`, integraciones `TVA_API_Life_*` |
| APPINVE | Perfil del usuario (oficina, productor, comisiones) | `TVA API Life APPINVE`, `TVA_API_Life_perfilUsuario` |
| RIC / Cliente Vida | Búsqueda del cliente por documento y comparación de discrepancias | `rule!TVA_ComparaEntrada*`, avisos `BUSQUEDA_RIC`/`DISCREPANCIAS` |
| MISV (perfilado) | Perfilado de cliente / test de idoneidad | `TVA MISV`, integración `TVA_PerfiladoClientes` |
| Firma | Envío y resultado de la firma (manuscrita/electrónica/biométrica) | PM `TVA_Firmar`, `TVA_PopUp_Firmar`, flags `TVA_FLAG_FIRMA_*` |
| CMP RGPD | Consentimiento de protección de datos con canal de firma | Web API `cmp-firma-rgpd`, PM `TVA_PopUp_RGPD` |
| CMP Captura DNI | Digitalización del documento de identidad | Web API `cmp-captura-dni`, PM `TVA_PopUp_DigitalizacionDNI` |
| TI Test conveniencia | Test de conveniencia vigente por cliente | Web API `testIdoneidad`, PM `TVA_PopUp_TestConveniencia` |
| CMP Respuesta componente | Lectura one-shot del resultado real de cada pop-up | Web API `cmp-respuesta-componente` |

## 7. Estados y ciclo de vida de la sesión/propuesta

La sesión `TVA_Sesion` nace en la Web API de inicio (crea usuario/perfil, propuesta o
simulación) y se persiste con `claveSesion`; su `idPantallaActual` marca la pantalla
activa y `estado.avisos` los mensajes pendientes. Cada acción de la botonera dispara un
proceso que valida, actualiza `sesion.estado` (incl. `cajas[].secciones[].datosValidos`)
y fija la siguiente pantalla. Estados terminales: `FIN` (cancelar o fin de flujo),
`SISTEMA_CERRADO` (aplicación cerrada), `SIN_PERFIL` (usuario sin perfil),
`SOLO_AVISOS` (errores de taller sin pantalla destino).
*(Fuente: `rule!TVA_InicializarSesion`, `rule!TVA_propuestaProductosAhorro_siguientePantalla`, PM `TVA_*-Continuar`, interfaces `TVA_Principal`)*

## 8. Matriz de cobertura funcional Appian ↔ Angular/Django

Estados: **Completo** · **Parcial** · **Mock** · **Pendiente** (consistente con
`docs/tva/12-gap-analysis-appian-angular.md`).

| Caso de uso | Estado | Notas |
|---|---|---|
| Inicio (request, validaciones exactas, siguiente pantalla) | Completo | contrato §12.4.1 portado |
| Selección de producto VIA / Seguros ahorro VA | Parcial | catálogo con 21 productos en mock API Life |
| Captura tomador 1/2 (secciones, requisitos, representante) | Completo | pop-ups RGPD/DNI/test con verificación real de resultado (`cmp-respuesta-componente`, one-shot) |
| Datos de la solicitud (operación, inversión, garantías, domiciliaciones) | Completo | validaciones §12.4.4 portadas; cesión/intervinientes pendientes |
| Rentas R2C (captura, precios, recalcular, contratar) | Parcial | validación captura + recalcular; contratación con datos mock |
| Resumen y firma | Parcial | tipos de firma y documentos pendientes (mock) |
| Administración (parámetros, apertura/cierre, cachés, trazas) | Completo | implementado con parámetros y trazas propias |
| Integraciones API Life / RIC / MISV / APPINVE / perfil cliente | Mock | conectores con fixtures/mock según `APPIAN_EMBED_MODE` y flags |
| Pop-ups RGPD / DNI / Test conveniencia | Completo | Appian Embedded + verificación de resultado; DNI solo desde IPs MAPFRE |
| Debug / Log | Mock | trazas en admin; sin pantalla debug Appian |

## 9. Glosario funcional

| Término | Definición |
|---|---|
| **VA / VIA / R2C** | Venta asesorada / venta informada / rentas (modos `indFunctionMode`). |
| **NUUMA** | Identificador del gestor en MAPFRE (parte local de `username@mapfre.net`). |
| **Tomador** | Persona que contrata (máximo dos). |
| **Propuesta / Seguro de ahorro** | Objeto de negocio que la VA recupera por `proposalId` (`insurancesApplication`). |
| **Perfilado / conveniencia / idoneidad** | Evaluación previa del cliente (test) exigida en VIA/VA. |
| **Caja / Sección** | Bloques de la UI con `datosValidos` que habilitan la botonera. |
| **Aviso** | Mensaje funcional con clase, tipo (INFO/WARNING/ERROR) y `mostrarEn`. |
| **MISV / RIC / APPINVE / API Life** | Servicios corporativos: perfilado, cliente, perfil de usuario/productor, catálogo y operaciones de vida. |
| **Apertura/cierre** | Interruptor funcional de la aplicación (`TVA_APLICACION_CERRADA`). |
