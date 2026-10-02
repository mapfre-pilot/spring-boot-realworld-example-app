# 2. Arquitectura y flujos

## Arquitectura lógica

```
Portal Financiero (GV / PFM)
        │  POST /webapi/tarificadorVidaAhorro | /webapi/simuladorRentas
        ▼
 Web API TVA ──► PM "TVA Inicio Ahorro" / "TVA Inicio SimuladorRentas"
                   ├─ perfil de usuario (API Life / SOAP MAVISA_910Usuario)
                   ├─ búsqueda cliente RIC (MU) / cliente Vida
                   ├─ propuesta / modalidad productos ahorro
                   └─ Write to Data Store: TVA_Traza(json = TVA_Sesion)
        │  redirección al site "TVA Principal" ?claveSesion=…
        ▼
 Interfaz TVA_Principal  ──lee──► rule!TVA_ObtenerTraza(claveSesion) ──► a!fromJson → TVA_Sesion
        │  a!match(sesion.idPantallaActual) → pantalla
        │  botón → a!startProcess(PM corto)
        ▼
 PM "acción"  ──► Integración API Life (SBC) ──► actualiza sesion ──► graba traza
                                 │
                       Connected Systems:
                       TVA API Life · TVA API Life APPINVE · TVA MISV
                       TVA BD Aurora PostgreSQL (schema tva_tarificadorvidaahorro)
```

### Patrón de estado

- **Sin records de negocio**: el único record type es `TVA Dummy` ("Tipo de registro
  Dummy para levantar PopUp"), utilizado solo para poder lanzar acciones en diálogo.
- El estado vive en el CDT `TVA_Sesion` (tomadores, propuesta, datos de operación,
  opciones de inversión, beneficiarios, comisiones, firma, avisos, `idPantallaActual`,
  `idPantallaAnterior`, `modoFuncionamiento`, `perfilUsuario`, …), que se serializa con
  `a!toJson` en la columna `json` de la tabla de trazas y se recupera por
  `claveSesion` + `tipoContenido`.
- En entornos no PRO, `TVA_Principal` permite abrir la app sin `claveSesion` con una
  sesión vacía (hay una línea comentada para inyectar `TVA_MOCK_Sesion_Expresion`).

### Modelado de UI: cajas y secciones

Las pantallas de captura se componen de **cajas** (`TVA_Caja_*`, CDT `TVA_Caja_Publico`,
17 constantes `TVA_CAJA_*`) y **secciones** (`TVA_Seccion*`, CDT `TVA_Caja_Seccion_Publico`,
16 constantes `TVA_SECCION_*`). Las factorías `TVA_Factoria_Caja_Privado` /
`TVA_Factoria_Caja_Seccion_Privado` y las reglas `TVA_Init*ParaCapturaDatos` /
`TVA_ValidarSeccionesParaCapturaDatos*` construyen y validan dinámicamente qué
secciones aparecen según el taller de producto (`VIDA_ObtenerConfiguracionProductoComercial`).

### Familias de reglas de expresión

| Familia | Nº aprox. | Rol |
|---|---|---|
| `TVA_FactoriaRequest*` | 12 | Construcción de los request a API Life (simulación rentas, solicitud rentas, propuesta, documentos VIA/VIR, notas, policy documents, SBC máximo, insurance application VA/VIA, validate reinvestment, verify producers) |
| `TVA_*_Validacion` / `TVA_Validacion*` | 25 | Validaciones de secciones y de CDTs API Life (Address, ContactMethod, IdentificationMethod, NaturalPerson, PersonName, LabourInformation, TaxObligationCountry, InvestmentOption, PolicyHolder VA/VIA, Beneficiarios, Domiciliaciones, Notas, CesionDerechos, RequisitosContratacion, TestData) |
| `TVA_Init*` | 15 | Inicialización de la sesión y de sus bloques |
| `TVA_Obtener*` | 14 | Acceso a datos (traza, perfil usuario, funcionalidades, cliente Vida, URL entorno, nuuma…) |
| `TVA_Garantias_*`, `TVA_EsModalidad*`, `TVA_EsValidoTest*` | 8 | Reglas de negocio booleanas |
| `TVA_MOCK_*`, `TVA_R2C_MOCK_*` | 49 | Datos de prueba (sesiones VA/VIA/rentas, tomadores, perfiles, requests) |
| `TVA_prueba*` | 6 | Reglas de prueba sin descripción |

## Modelos de proceso (28)

Todos son procesos cortos (4–25 nodos) con nodo final `Modify Process Security` y un
patrón común: *script task* (preparar request con `TVA_FactoriaRequest*`) → *nodo de
integración* → *gateway ok?* → *script task* (actualizar sesión / avisos con
`VIDA_MensajeErrorServicio`) → subproceso `T …` de traza.

| Grupo | Modelos |
|---|---|
| Inicio | `TVA Inicio Ahorro` (25 nodos: alta usuario, crear sesión, buscar cliente RIC/Vida, propuesta/modalidad, grabar sesión, ¿aplicación cerrada?), `TVA Inicio SimuladorRentas` |
| Productos ahorro | `TVA modalidadProductosAhorro`, `TVA propuestaProductosAhorro`, `TVA Perfil cliente`, `TVA VerificarProductores`, `TVA ImporteMaximo` (agrupaciones fiscales), `TVA ValidarReinversion` |
| Tomadores | `TVA CapturaTomador1-Continuar`, `TVA CapturaTomador2-Continuar` |
| Rentas | `TVA CapturaDatosRentas-Contratar`, `TVA R2C Capt-Siguiente`, `TVA R2C Precios-Recalcular`, `TVA R2C Precios-Contratar` |
| Contratación | `TVA Guardar y volver` ("Guardar y Volver en VA / Contratar en VIA": insuranceApplication → getProposal → printingTypes), `TVA DocumentacionPrecontractual` (20 nodos, 4 integraciones), `TVA IndividualNotes` |
| Firma | `TVA Firmar`, `TVA PopUp Firmar`, `TVA Firma-EnvioFirmaManuscrita` (email) |
| Pop-ups | `TVA PopUp Intervinientes`, `TVA PopUp Cesion derechos`, `TVA PopUp RGPD`, `TVA PopUp DigitalizacionDNI`, `TVA PopUp TestConveniencia` |
| Batch / soporte | `TVA Batch Apertura-Cierre`, `TVA Batch Borrar traza`, `TVA IPs` (aviso a administradores) |

## Flujo principal — Venta Informada (VIA)

1. Portal → Web API `tarificadorVidaAhorro` → `TVA Inicio Ahorro`: perfil de usuario,
   ¿aplicación cerrada?, alta/búsqueda de tomadores, `modalidadProductosAhorro`.
2. `TVA_propuestaProductosAhorro_siguientePantalla` decide: sin opción de inversión →
   `SELECCION_PRODUCTO_AHORRO`; `insuranceOfferInd` → `MODALIDAD_CAMPANIA`; test de
   conveniencia OK → `CAPTURA_DATOS_SOLICITUD`; si no → `CAPTURA_TOMADOR1`.
3. Captura de datos por secciones; validaciones `TVA_*_Validacion`; pop-ups (RGPD, DNI,
   cesión de derechos, intervinientes); `ImporteMaximo` si el producto está en agrupación
   fiscal; `ValidarReinversion` si aplica.
4. Contratar → `TVA Guardar y volver` → `savingInsuranceApplication`, `getProposal`,
   `printingTypes` → `RESUMEN_CONTRATACION`.
5. `TVA DocumentacionPrecontractual` (individualDocuments / NOdocs) y selección del tipo
   de firma (`TVA_MensajeAuxiliarSeleccionTipoFirma`).
6. `TVA Firmar` / `TVA PopUp Firmar` / firma manuscrita por email → `RESULTADO_FIRMA`
   con `policy_documents` para descarga.

## Flujo Venta Asesorada (VA)

Igual que VIA pero partiendo de una propuesta existente (`saveProposal`/`getProposal`):
pantalla `SEGUROS_AHORRO` con los `insurancesApplication` de la propuesta; si solo hay
uno y los tomadores superan el test de idoneidad se salta a `CAPTURA_DATOS_SOLICITUD`.
"Guardar y volver" devuelve al portal en lugar de emitir.

## Flujo Rentas (VIR / R2C)

Web API `simuladorRentas` → `TVA Inicio SimuladorRentas` → `R2C_CAPTURA`
(`TVA R2C Capt-Siguiente` → `individualAnnuitySimulation`) → `R2C_PRECIOS`
(`Recalcular` = nueva simulación; `Contratar` → `CapturaDatosRentas-Contratar` →
`individualAnnuityInsuranceApplication`) → resumen/firma como en ahorro.

## Persistencia

- Data source: `TVA BD Aurora PostgreSQL`
  (esquema propio de TVA en Aurora PostgreSQL DEV).
- Entidad principal: `cons!TVA_ENT_TRAZA` (CDT `TVA_Traza`: `id`, `claveSesion`,
  `ubicacion`, `tipoContenido`, `json`, …). Se usa tanto para trazas de servicio como para
  la sesión (`TVA_TRAZA_CODIGOS_TIPO_CONTENIDO_SESION`).
- Documentos (8) en el Knowledge Center `TVA` (plantillas, imágenes).
