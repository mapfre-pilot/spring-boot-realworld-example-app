# 12. Análisis de gap Appian TVA ↔ Angular + Django

Comparación pantalla a pantalla entre la aplicación real **Tarificador Vida Ahorro** en Appian DEV
(recorrida en navegador con el usuario autorizado de Devin, sin modificar ningún objeto) y la
implementación de `tva-frontend/` + `tva-backend/` de esta rama.

Fuentes de evidencia:

- Ejecución real en DEV del flujo **Venta Informada Ahorro (VIA)** con el producto 00427 PIAS Elección:
  Utilidades → Selección de producto → Tomador 1 (datos personales, domicilio) → Solicitud
  (productores, operación, inversión, garantías, domiciliaciones, captura ampliada).
- Pantalla de inicio de **Venta Asesorada (VA)** en `TVA_Utilidades` (tabla de inversión, validaciones de
  entrada devueltas por la Web API de inicio).
- Volcado completo de la app (96 interfaces, 172 reglas, 28 procesos, 209 constantes) que actúa de
  especificación cuando la ejecución no fue posible (firma, documentos, R2C).
- JSON de sesión real (`TVA_Debug`) capturado en la pantalla de Tomador 1.

Leyenda de cobertura: **C** completa · **P** parcial · **N** no implementada · **M** implementada con mock.

---

## 12.1. Hallazgos que cambian el diseño actual

| # | Hallazgo en Appian | Estado en la rama | Impacto |
|---|---|---|---|
| H1 | **La navegación no es una secuencia fija**: `TVA_propuestaProductosAhorro_siguientePantalla` decide la pantalla según datos (`insuranceOfferInd` → Modalidad campaña; `perfilClientesOK` → saltar Tomador; VA con una sola `insurancesApplication` sin `statusDesc` → ir directo a Solicitud). En VIA el orden real es **Selección producto → Tomador 1 → Solicitud**, no Solicitud → Tomador. | `maquina_pantallas.SECUENCIAS` usa listas fijas por modalidad (VIA: producto → campaña → solicitud → tomador1). | Alto: hay que portar la regla de siguiente pantalla y los procesos `*-Continuar`. |
| H2 | **Modelo de sesión** (`TVA_Sesion`): `claveSesion, modoFuncionamiento, codigoProducto, companyId, distributionChannel, perfilUsuario, tomadores[], ventaInformada, datosOperacion, garantias, comisiones, beneficiarios, cajas[], avisos[], idPantallaActual, idPantallaAnterior, documentosPrecontractuales, rentas`. | `Sesion.estado` es un JSON libre con claves ad hoc (`documentoCliente`, `clienteVida`, `solicitud`…). | Alto: el front no puede reproducir las pantallas sin la misma estructura. |
| H3 | **Cajas y secciones con estado de validez** (`sesion.cajas[i].secciones[j].datosValidos`). La botonera habilita/deshabilita botones a partir de ese estado y las secciones se pliegan con marca verde al ser válidas. | No existe el concepto; los contenedores validan localmente. | Alto: es la base de todo el comportamiento de habilitado/deshabilitado. |
| H4 | **Parámetros de entrada reales**: `indFunctionMode (VA/VIA/R2C), proposalId, companyId, distributionChannel, username (@mapfre.net → NUUMA), policyHolders[], investment[]`. Validación exacta en `TVA_WebApi_Inicio_ObtenerMensajeError` + `TVA_ValidacionInvestmentOption`. | El inicio pide `documentoCliente, canal (GV/PFM), modalidad`. | Alto: el contrato de entrada del portal que invoca a TVA es otro. |
| H5 | **Catálogo de productos** por `API Life ProductList(companyId, productTypeCode, nuuma, distributionChannel)` ordenado por `commercialProductDesc`; 21 productos en DEV. El servicio puede no devolver ninguno (`El servicio no ha devuelvo ningún producto de ahorro`). | Mock con lista corta. | Medio: mock con el catálogo real + filtro por canal. |
| H6 | **Botonera única** (`TVA_Botonera`) con visibilidad/habilitado por pantalla y modo: Cancelar, Administración (grupo), Atrás/Recalcular (R2C), Guardar y volver (VA), Doc. Precontractual + Contratar (VIA), Contratar (R2C), Continuar (Tomador 1/2), Siguiente (R2C captura), Firmar (oculto). | `botonera.component` genérica Anterior / Guardar y volver / Siguiente. | Alto. |

---

## 12.2. Matriz de pantallas

| Pantalla Appian (`cons!TVA_ID_PANTALLA_*`) | Interfaz Appian | Componente Angular | Acción / proceso | Cobertura | Gap principal |
|---|---|---|---|---|---|
| Inicio (Web API `TVA InicioTarificadorVidaAhorro` / utilidades) | `TVA_Utilidades_Inicio`, `TVA_WebApi_Inicio_ObtenerMensajeError` | `pages/inicio/inicio.page.ts` | `PM TVA_Inicio_Ahorro`: alta usuario, buscar cliente (RIC), propuesta (API Life `getProposal`), modalidad, grabar sesión, `idPantalla` | P | H4, H1. Textos exactos de validación (§12.4.1). |
| SISTEMA_CERRADO | `TVA_SistemaCerrado` | `sistema-cerrado.container` | Parámetro apertura/cierre | C | Texto del motivo de cierre desde parámetro. |
| SIN_PERFIL | `TVA_Principal` (rama) | `sin-perfil.container` | Perfil usuario (APPINVE) | M | — |
| SOLO_AVISOS | `TVA_MostrarAvisos` | `solo-avisos.container` | Taller (`TVA_*ActualizarSesionParaCapturaDatos*`) | P | Avisos con `clase/tipo/texto/mostrarEn`. |
| SELECCION_PRODUCTO_AHORRO (VIA) | `TVA_Pantalla_SeleccionProductoAhorro` | `seleccion-producto-ahorro.container` | Tarjetas de producto con enlace *Contratación*; al elegir → `TVA_VIA_ActualizarSesionParaCapturaDatosAhorro` → Tomador 1 | P | Grid de tarjetas, 21 productos, filtro por canal, mensaje sin productos. |
| SEGUROS_AHORRO (VA) | `TVA_Pantalla_SegurosAhorro` | `seguros-ahorro.container` | Lista de `insurancesApplication` de la propuesta; botón *Captura datos* | P | Datos desde propuesta real (`responseProposal`). |
| MODALIDAD_CAMPANIA | (según `insuranceOfferInd`) | `modalidad-campania.container` | — | P | Sólo se alcanza si el producto está en campaña. |
| CAPTURA_TOMADOR1 / 2 | `TVA_Pantalla_CapturaTomador`, `TVA_CapturaTomador_Caja*`, `TVA_DatosParticipanteV2`, `TVA_DomicilioV2`, `TVA_MediosContacto`, `TVA_CapturaTomador_PanelDerecho` | `captura-tomador1/2.container`, `tomador-base` | `PM TVA_CapturaTomador1-Continuar`: perfil cliente, actualizar tomadores, validar domiciliaciones, importe máximo, ¿dos tomadores?, siguiente pantalla | P | Secciones plegables con validez, requisitos (RGPD, DNI digitalizado, test conveniencia), representante legal, FATCA/CRS, medios de contacto múltiples. |
| CAPTURA_DATOS_SOLICITUD | `TVA_Pantalla_CapturaDatosSolicitud`, `TVA_CajaDatosProductores`, `TVA_CajaDatosDelSeguro`, `TVA_SeccionDatosDeLaOperacion*`, `TVA_SeccionOpcionesDeInversion*`, `TVA_SeccionGarantias`, `TVA_SeccionDomiciliaciones*`, `TVA_SeccionDatosContacto`, `TVA_SeccionAsegurado`, `TVA_SeccionBeneficiarios`, `TVA_SeccionNotas`, `TVA_SeccionCesionDerechos` | `captura-datos-solicitud.container` | VA: *Guardar y volver* (`PM TVA_Guardar_y_volver` → insuranceApplication + getProposal + printingTypes → Resumen). VIA: *Doc. Precontractual* (`PM TVA_DocumentacionPrecontractual`) y *Contratar*. R2C: *Contratar* | P | Cajas/secciones, inversión multi-opción con reparto de importes, garantías del producto, captura ampliada, reglas de habilitado (§12.4.3). |
| RESUMEN_CONTRATACION | `TVA_Pantalla_ResumenContratacion`, `TVA_CajaResumenContratacion*`, `TVA_CajaSeleccionTipoFirma`, `TVA_CajaDatosFirma`, `TVA_CajaDocumentosPrecontractuales` | `resumen-contratacion.container` | Selección tipo firma (papel / electrónica / biométrica según flags), `PM TVA_PopUp_Firmar`, `PM TVA_Firma-EnvioFirmaManuscrita` | P | Tipos de firma, documentos precontractuales, resumen con importes reales. |
| RESULTADO_FIRMA | `TVA_Pantalla_ResultadoFirma`, `TVA_CajaResultadoFirma` | `resultado-firma.container` | `PM TVA_Firmar` → API Life policy documents | M | Descarga de documentos de póliza. |
| R2C_CAPTURA / R2C_PRECIOS | `TVA_Pantalla_R2C_*`, `TVA_R2C_*` | `r2c-captura/precios.container` | `PM TVA_R2C_PM_CAPT_SIGUIENTE`, `PRECIOS_RECALCULAR`, `PRECIOS_CONTRATAR` | P | Validación `TVA_SimuladorRentas_Captura_Validacion` (dos tomadores obligatorios, % participación), botón Recalcular. |
| ADMINISTRACION | `TVA_Pantalla_Administracion`, `TVA_Admin_*` | `pages/admin/admin.page.ts` | Activar/desactivar, apertura/cierre, gestión de cachés | P | Gestión de cachés; acceso por grupo `TVA_GRP_ADMINISTRADORES_PORTAL`. |
| FIN | `TVA_Principal` | `fin.container` | Cancelar → FIN + avisos = null | C | Texto "La aplicación ha terminado su ejecución, puede cerrar el navegador". |
| Debug | `TVA_Debug` | — | Grupo `TVA_GRP_DEBUG` | N | JSON de sesión (estándar/Appian), árbol sesión/taller. |
| Log | `TVA_Utilidades_Log`, `TVA_LogAplicacion` | (admin) | Trazas por sesión | P | Filtros, exportación. |

---

## 12.3. Modelo de datos de sesión observado (VIA, 00427)

```text
claveSesion, modoFuncionamiento=VIA, codigoProducto=00427, companyId=0511, distributionChannel=500
perfilUsuario            { nuuma, oficina=1231, productor=90938, funcionalidades[] }
tomadores[]              { datosPersonales{ documentId, nombre, apellidos, fechaNacimiento, sexo,
                            nacionalidad, paisNacimiento, actividad, sector, profesion,
                            responsabilidadPublica, residenciaEspaña, legalRepresentative },
                           domicilioHabitual{ tipoVia, nombreVia, numero, complemento, cp, localidad,
                            provincia, pais },
                           mediosContacto[]{ tipo, prefijo, numero | email },
                           fatcaCrs, perfilCliente{ perfil=ME, testConveniencia{ estado=FIRMADO } },
                           datosGestionParticipante{ consentimientoProteccionDatos,
                            documentoIdDigitalizado, testConvenienciaVigente,
                            enviadosDocumentosPrecontractuales },
                           domiciliaciones{ ibanRecibos, ibanPrestaciones } }
ventaInformada           { opcionesInversion[]{ codigo, descripcion, primaUnica, primaPeriodica,
                            plazoObjetivo }, cestaLibre, preferencias }
datosOperacion           { fechaEfecto, duracion, primaUnica, aportacionPeriodica, periodicidad,
                           diaCobro, revalorizacion, porcentajeCrecimiento, reinversion{...} }
garantias[]              { codigo, descripcion (Fallecimiento por accidente / por cualquier causa),
                           obligatoria, seleccionada }
comisiones               { maxPrimerAnio, deseadaPrimerAnio }
beneficiarios            { vida{ tipo, eleccion }, fallecimiento{ tipo: herederos legales | hijos |
                           padres | cónyuge | tomador | hermanos | distribución por defecto } }
cajas[]                  { id, titulo, plegada, secciones[]{ id, titulo, datosValidos, plegada } }
avisos[]                 { clase, tipo (INFO|WARNING|ERROR), texto, mostrarEn (CABECERA|SECCION) }
documentosPrecontractuales[], idPantallaActual, idPantallaAnterior
```

---

## 12.4. Reglas a portar (texto exacto)

### 12.4.1. Inicio (`TVA_WebApi_Inicio_ObtenerMensajeError`)

- `Request inválida` (body nulo)
- `El campo companyId no puede ser nulo` / `Valor de companyId no permitido` (`TVA_CODIGOS_EMPRESA_ADMITIDOS`)
- `El campo distributionChannel no puede ser nulo` / `Valor de distributionChannel no permitido`
- `El campo username no puede ser nulo` / `El nombre de usuario debe acabar en @mapfre.net` (NUUMA = parte local en mayúsculas)
- `El campo indFunctionMode no puede ser nulo` / `Valor de indFunctionMode no permitido`
- `El campo proposalId no puede ser nulo si indFunctionMode es VA`
- `No se admiten más de dos tomadores`
- VA: `En Venta Asesorada es obligatorio informar al menos un seguro de ahorro`
- Por opción de inversión (`investment[i]- …`): `commercialProductCode: El valor informado no es válido`,
  `operationTypeCode: El valor informado no es válido` (Suscripción / Aportación extraordinaria),
  `uniqueContributionAmn: El valor no puede ser negativo`, `periodicContributionAmn: El valor no puede ser negativo`,
  `Los dos importes no pueden ser nulos a la vez`, `contributionFrequencyCode: El valor informado no es válido`
  (obligatorio si hay aportación periódica).
- Respuesta de error observada: `{ code: "02", message: "Error en los datos proporcionados", application: "TVA", timestamp, errors[]{ code, message } }`.

### 12.4.2. Siguiente pantalla tras inicio (`TVA_propuestaProductosAhorro_siguientePantalla`)

```text
VA : sin insurancesApplication → SEGUROS_AHORRO
     1 insuranceApplication y perfilClientesOK y statusDesc nulo → CAPTURA_DATOS_SOLICITUD
     resto → SEGUROS_AHORRO
VIA: sin investmentOption → SELECCION_PRODUCTO_AHORRO
     investmentOption.insuranceOfferInd → MODALIDAD_CAMPANIA
     perfilClientesOK → CAPTURA_DATOS_SOLICITUD, si no → CAPTURA_TOMADOR1
R2C: CAPTURA_DATOS_SOLICITUD
otro: SOLO_AVISOS
```
Además: aplicación cerrada → SISTEMA_CERRADO; usuario sin perfil → SIN_PERFIL; taller con error → SOLO_AVISOS.
Tomador 1 → Continuar: si hay dos tomadores → CAPTURA_TOMADOR2, si no → CAPTURA_DATOS_SOLICITUD.

### 12.4.3. Botonera (`TVA_Botonera`)

| Botón | Visible | Habilitado | Acción |
|---|---|---|---|
| Cancelar (link, confirmación "Va a cancelar el proceso de captura. ¿Está seguro?") | Solicitud, Tomador 1/2, R2C captura/precios, Resumen | siempre | pantalla = FIN, avisos = null |
| Administración | miembro de `TVA_GRP_ADMINISTRADORES_PORTAL` y no en Administración | siempre | guarda pantalla anterior, pantalla = ADMINISTRACION |
| Atrás | R2C precios | siempre | pantalla = R2C_CAPTURA |
| Recalcular | R2C precios | simulación seleccionada y `rentas.recalcular` | PM recalcular |
| Guardar y volver | Solicitud + VA | productores y seguro válidos | PM Guardar y volver |
| Doc. Precontractual (confirmación: "Se va a enviar un correo al cliente con la información precontractual.\nSi continúa ya no podrá modificar los datos de la solicitud." Continuar/Volver) | Solicitud + VIA | productores y seguro válidos; test conveniencia válido si flag; no enviados ya | PM Documentación precontractual; error → aviso "Error al enviar la documentación precontractual" |
| Contratar (VIA) | Solicitud + VIA | productores y seguro válidos; test conveniencia; documentos precontractuales presentes; sin avisos de error | PM Guardar y volver (contratación) |
| Contratar (R2C) | Solicitud + R2C | productores, seguro (y doc. precontractual si flag) válidos; test conveniencia | PM Rentas contratar |
| Continuar (Tomador 1/2) | Tomador 1/2 | caja tomador válida; caja representante legal válida si hay representante; test conveniencia si flag | PM Tomador N continuar |
| Siguiente (R2C captura) | R2C captura | `TVA_SimuladorRentas_Captura_Validacion` vacío | PM R2C siguiente |
| Firmar | oculto (`showWhen: false`) | — | (firma se lanza desde la caja de firma) |

### 12.4.4. Validaciones de secciones

- Datos personales (`TVA_CapturaTomador_DatosPersonales_Validacion`): documento, nombre, primer apellido,
  fecha de nacimiento, sexo, nacionalidad, país de nacimiento, `Los campos Actividad, Sector y Profesión son obligatorios`,
  `El móvil es obligatorio`, `El correo electrónico es obligatorio`.
- Domicilio habitual: tipo de vía, nombre de vía, número, código postal, localidad, provincia, país (`El/La … es obligatorio/a`).
- Dirección de correspondencia (`TVA_Address_Validacion`): mismos campos + `El campo tipo de dirección es obligatorio`.
  El servicio devuelve además los códigos de campo (`addressRoadTypeCode: el campo es obligatorio; …`).
- Medios de contacto: tipo, prefijo, valor.
- Datos de la operación (`TVA_DatosDeLaOperacion_Validacion`): `Debe rellenar la prima única o la prima periódica`,
  `Debe seleccionar la periodicidad`, `El importe de la prima debe estar entre …`, `El valor debe estar en el rango 1 a 31` (día de cobro),
  reinversión (operación, póliza, tipo), duración (tipo, años, tabla, edad/fecha de vencimiento), jubilación, minusvalía
  (`La fecha de alta de la minusvalía no puede ser un valor futuro`), revalorización.
- Opciones de inversión: `Debe seleccionar la opción de inversión`, `La suma de los importes de la prima única debe coincidir con el total de la operación`,
  ídem periódica, `El plazo objetivo no puede ser nulo`. Al seleccionar la primera opción se le asigna el importe de la prima.
- Domiciliaciones: `El IBAN de pago de recibos no puede ser nulo`, `El IBAN de pago de prestaciones no puede ser nulo`, `IBAN inválido`.
- Beneficiarios: `Debe incluir en el texto libre el beneficiario`. Participantes: nombre, primer apellido, sexo, fecha de nacimiento, parentesco.
- Notas: `Hay notas seleccionadas que deben llevar texto obligatoriamente`.
- R2C: `Son obligatorios dos tomadores`, `El importe total de la prima es obligatorio`, `La periodicidad de la renta es obligatoria`,
  por tomador `: el número de DNI es obligatorio`, `: la fecha de nacimiento es obligatoria`, `: el porcentaje de participación es obligatorio`.
- Aviso informativo VIA: `El importe máximo anual que el cliente puede contratar para la agrupación fiscal es de 7.500 €` (PM Importe máximo).

---

## 12.5. Integraciones y permisos

| Integración Appian | Uso | Estado en la rama |
|---|---|---|
| API Life `ProductList`, `getProposal`, `insuranceApplication`, `printingTypes`, `documents`, `policy documents`, `messages` | catálogo, propuesta, alta solicitud, tipos de impresión, doc. precontractual, documentos póliza | M (`connectors/apilife.py`), faltan operaciones de documentos y mensajes |
| APPINVE (perfil usuario / productores) | perfil, oficina, productor, comisiones | M |
| RIC (buscar cliente) | tomadores por documento | M (`TVA_FLAG_SIMULAR_BUSQUEDA_CLIENTE_RIC`) |
| MISV | trazas | M |
| Perfil cliente (test conveniencia / idoneidad) | `perfilCliente`, `TVA_EsValidoTestConveniencia` | N |
| Firma (manuscrita / electrónica / biométrica; flags `TVA_FLAG_FIRMA_*`) | resumen | N (simulada) |
| RGPD, Digitalización DNI, Cesión derechos, Intervinientes, Notas (pop-ups) | tomador / solicitud | N |
| Resolver IP local (`CMP_CS_OBTENER_IP`) | firma | N |

Grupos: `TVA_GRP_USUARIOS`, `TVA_GRP_ADMINISTRADORES_PORTAL` (botón Administración), `TVA_GRP_DEBUG` (JSON de sesión, IP local),
y el resto de los 11 grupos descritos en `06-seguridad.md`. En la rama existen roles `TVA_USUARIO` y `TVA_ADMIN_PORTAL`; falta `TVA_DEBUG`.

---

## 12.6. Backlog priorizado

| Prio | Bloque | Contenido | Estado |
|---|---|---|---|
| 1 | Navegación y sesión | Portar H1 (`siguientePantalla`), H2 (estructura `TVA_Sesion`), H3 (cajas/secciones con `datosValidos`), H4 (parámetros y validación de inicio), H6 (botonera por pantalla/modo) | **en curso en esta rama** |
| 2 | Tomador | Secciones datos personales / domicilio / contacto / FATCA / representante legal con validaciones §12.4.4, panel de requisitos (RGPD, DNI, test conveniencia), plegado con validez | hecho (parcial: pop-ups RGPD/DNI/test conveniencia pendientes de integración) |
| 3 | Solicitud | Cajas Productores, Datos del seguro (operación, opciones de inversión con reparto, garantías, domiciliaciones), Captura ampliada (contacto, asegurado, beneficiarios, notas), Doc. Precontractual/Contratar con reglas de habilitado | hecho (parcial: pop-ups RGPD/DNI/test conveniencia pendientes de integración) |
| 4 | Catálogo | 21 productos DEV en mock API Life, filtro por canal/NUUMA, caso sin productos, campaña (`insuranceOfferInd`) | pendiente |
| 5 | Resumen y firma | Tipos de firma según flags, documentos precontractuales, resultado y descarga | pendiente (requiere contratos de firma) |
| 6 | R2C | Validación captura, Recalcular, Contratar | pendiente |
| 7 | Perfil cliente | Test de conveniencia/idoneidad y flag obligatorio | pendiente (requiere servicio) |
| 8 | Admin/Debug/Log | Cachés, grupo debug, JSON de sesión, log filtrable | pendiente |
| 9 | Integraciones reales | Sustituir mocks por API Life / APPINVE / RIC / MISV | requiere red y credenciales |

## 12.7. Lo que no se pudo verificar en DEV

- Inicio de **Venta Asesorada** desde `TVA_Utilidades`: la validación de `commercialProductCode` usa el catálogo del
  usuario conectado (`loggedInUser()`), y el usuario de Devin no tiene productos asociados en API Life, por lo que la
  Web API devuelve `investment[1]- commercialProductCode: El valor informado no es válido`. Hace falta un usuario con
  productos o una propuesta (`proposalId`) real en API Life DEV.
- Envío real de documentación precontractual, contratación, firma y descarga de documentos (implican correo al
  cliente y alta de póliza en API Life; no se ejecutaron para no generar datos en DEV).
- Rentas/R2C end-to-end.
