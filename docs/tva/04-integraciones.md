# 4. Integraciones y sistemas conectados

## Sistemas conectados (4)

| Nombre | Tipo | Endpoint base | Autenticación | Uso |
|---|---|---|---|---|
| `TVA API Life` | HTTP | host API Life (entorno PRE) | Basic, preemptive (usuario técnico A) | 18 de las 20 integraciones (API Life / SBC / personas) |
| `TVA API Life APPINVE` | HTTP | host API Life (entorno PRE) | Basic (usuario técnico B) | Sin integraciones dependientes en el volcado |
| `TVA MISV` | HTTP | host MISV (entorno PRE) | Basic (usuario técnico C) | `TVA_PerfiladoClientes` (NOVAServices) |
| `TVA BD Aurora PostgreSQL` | Data Source (Aurora PostgreSQL) | Aurora PostgreSQL DEV, esquema propio de TVA | usuario técnico propio | Data store de trazas/sesión |

> Observación: los tres sistemas HTTP del entorno **DEV** de Appian apuntan a hosts de
> **PRE** de Mapfre (hosts PRE). Las contraseñas están enmascaradas en Appian y
> no se documentan.

## Integraciones (20)

Todas las de API Life heredan URL base y autenticación del sistema conectado y envían la
misma familia de cabeceras `X-Request-*` (`companyId`, `issueCompanyId`,
`applicationId`, `distributionChannel`, `internalUser`, `processId`, `operationCode`) más
`Accept-Language: cons!CMP_VAL_TRADUCCION_ES` y `Host`.

| Integración | Método | Ruta | Tipo | Timeout (s) | Propósito |
|---|---|---|---|---|---|
| `TVA_API_Life_ProductList` | GET | `/apisbctaller_int-web/api/life/1.0/settings/products` | QUERY | 20 | Catálogo de productos por tipo/canal/cliente |
| `TVA_API_Life_generalTable` | GET | `/apisbctaller_int-web/api/life/1.0/catalog/general/generalTable/{codigo}` | QUERY | 100 | Tablas generales (catálogos) |
| `TVA_API_Life_printingTypes` | GET | `apisbctaller_int-web/api/life/1.0/settings/printingTypes/{commercialProductCode}` | QUERY | 10 | Tipos de firma válidos por producto |
| `TVA_API_Life_verifyProducers` | POST | `/apisbctaller_int-web/api/life/1.0/settings/verifyProducers` | QUERY | 20 | Verificación de productores/comisiones |
| `TVA_API_Life_clientSearch` | POST | `/apisbctaller_int-web/api/life/1.0/client/search` | QUERY | 20 | Búsqueda de cliente en Personas |
| `TVA_API_Life_perfilUsuario` | GET | `apisbctaller_int-web/api/life/1.0/individual/search/{nuuma}` | QUERY | 10 | Perfil del usuario gestor |
| `TVA_API_Life_individualDocuments` | POST | `/apisbctaller_int-web/api/life/1.0/individual/documents` | MODIFY | 20 | Documentos precontractuales (KID/NI) |
| `TVA_API_Life_individualDocumentsNOdocs` | POST | ídem | MODIFY | 20 | Variante sin tratamiento de documentos |
| `TVA_API_Life_saveProposal` | POST | `/apisbcsolicitudes_int-web/api/life/1.0/individual/saving/proposal` | MODIFY | 20 | Guardar propuesta de ahorro (VA) |
| `TVA_API_Life_getProposal` | GET | `/apisbcsolicitudes_int-web/api/life/1.0/individual/saving/proposal/{proposalId}` | QUERY | 10 | Recuperar propuesta |
| `TVA_API_Life_individualAnnuityInsuranceApplication` | POST | `/apisbcsolicitudes_int-web/api/life/1.0/individual/annuity/insuranceApplication` | MODIFY | 20 | Solicitud de renta |
| `TVA_API_Life_individualAnnuitySimulation` | POST | `/apisbcpolizas_int-web/api/life/1.0/individual/annuity/simulation` | MODIFY | 20 | Simulación de renta |
| `TVA_API_Life_savingInsuranceApplication` | POST | `/apisbcpolizas_int-web/api/life/1.0/individual/saving/insuranceApplication` | MODIFY | 20 | Solicitud/emisión de seguro de ahorro |
| `TVA_API_Life_validateReinvestment` | POST | `/apisbcpolizas_int-web/api/life/1.0/individual/validate/reinvestment` | QUERY | 20 | Validación de reinversión |
| `TVA_API_Life_individualNotes` | POST | `/apisbcpolizas_int-web/api/life/1.0/individual/notes` | QUERY | 20 | Notas individuales |
| `TVA_API_Life_policy_documents` | POST | `/apisbcpolizas_int-web/api/life/1.0/individual/policy/{policyId}/documents` | MODIFY | 120 | Documento firmado de la póliza (envía `X-Forwarded-For` con IP cliente) |
| `TVA_API_SBC_maximo` | GET | `sbccliente_be-web/api/1.0/vida/cliente/{nif}/individual/ahorro/importe/maximo` | QUERY | 10 | Importe máximo de aportación en agrupaciones fiscales (cabeceras `X-Request-codEntidad/codRemitente/codMedio/idAplicacion/codIdioma`) |
| `TVA_GestionarPersonas` | PUT | `personavida_be-web/api/1.0/vida/gestionarPersonas` | MODIFY | 20 | Alta/actualización de personas en Vida |
| `TVA_PerfiladoClientes` | GET | `/NOVAServices/rest/RSPerfiladoClienteV2/obtenerPerfiladoCliente` (MISV) | QUERY | 20 | Perfilado financiero del cliente |
| `TVA_WSDL_IGestionarPerfilUsuario` | POST (SOAP) | `rule!MU_Conectar_URL_SOA7(forzarPreEnDev: true) & "MAVISA_910Usuario_SOAMEDWeb/sca/MAVISA_910Usuario_WSDL"` | QUERY | 10 | Perfil de usuario vía SOA (sin sistema conectado) |

Los cuerpos de las peticiones se construyen con las reglas `TVA_FactoriaRequest*` sobre
los CDT `VIDA_API_Life_*`, y las respuestas se tratan con `VIDA_MensajeErrorServicio`,
`TVA_MensajeErrorServicioRetencion` y `TVA_PerfilCliente_ProcesarRespuesta`.

## Web APIs (2)

| Nombre | Alias | Método | Público | Logging | Descripción |
|---|---|---|---|---|---|
| `TVA InicioTarificadorVidaAhorro` | `tarificadorVidaAhorro` | POST | No | No | Inicio del tarificador Vida Ahorro (arranca `TVA Inicio Ahorro`) |
| `TVA InicioSimuladorRentas` | `simuladorRentas` | POST | No | No | Inicio del simulador de rentas (arranca `TVA Inicio SimuladorRentas`) |

Ambas se invocan con las cuentas de servicio del grupo `TVA WebApi Inicio`
(dos cuentas de servicio, una por portal: GV y PFM). El MCP no devolvió el cuerpo
SAIL de las Web APIs; el comportamiento se infiere de `TVA_responseTVAWebAPI`,
`TVA_ResponseInicio`, `TVA_WebApi_Inicio_ObtenerMensajeError` y
`TVA_R2C_WebApi_Inicio_ObtenerMensajeError`.

## Otros canales

- **Email**: `TVA Firma-EnvioFirmaManuscrita` (envío de documentación para firma
  manuscrita) y `TVA IPs` (aviso a administradores).
- **Base de datos**: `a!queryEntity` / Write to Data Store / Delete from Data Store sobre
  `TVA_ENT_TRAZA`.
