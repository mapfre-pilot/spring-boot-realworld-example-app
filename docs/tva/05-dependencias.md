# 5. Dependencias externas (otras aplicaciones Appian)

TVA referencia **151 objetos** (`rule!`/`cons!`) que no pertenecen a la aplicación, repartidos en cuatro aplicaciones compartidas. Cualquier cambio en ellas puede afectar a TVA; deben desplegarse antes que TVA (orden de dependencias).

| Aplicación (prefijo) | Rol | Reglas | Constantes |
|---|---|---|---|
| `MU_*` | Minsait Utilities — componentes UI (`MU_TextField`, `MU_Dropdown`, `MU_Aviso`…), conectividad (`MU_Conectar_Host_*`), trazas, avisos, cliente RIC, actualización de constantes | 30 | 15 |
| `VIDA_*` | Comunes Vida — CDT API Life, catálogos/códigos (`VIDA_CODIGOS_*`, `VIDA_Codigos_*`), configuración de producto comercial, mensajes de error de servicio | 28 | 33 |
| `CMP_*` | Componentes — validaciones (DNI/NIE/CIF/IBAN/email/teléfono), formato de números, colores, entorno actual, integraciones DNI/RGPD | 15 | 29 |
| `TI_*` | Test de Idoneidad — `TI_integracionAppianTestIdoneidad` | 1 | 0 |

## Dependencias críticas (por impacto)

- `rule!VIDA_ObtenerConfiguracionProductoComercial` (31 archivos): el *taller* de producto que gobierna qué secciones y validaciones aplican. Es la dependencia funcional más sensible.
- `rule!MU_Conectar_Host_WebServices` / `MU_Conectar_Host_Misv` / `MU_Conectar_URL_SOA7`: resolución de hosts por entorno para las 20 integraciones.
- `cons!CMP_VAL_ENTORNO_ACTUAL` + `CMP_VAL_ENTORNO_DEV/PRE/PRO`: bifurcaciones de comportamiento por entorno en 13 archivos (incluida `TVA_Principal`).
- `cons!MU_PM_ACTUALIZAR_CONSTANTES` + `rule!MU_ActualizarConstantes_Parametros`: las pantallas de administración modifican constantes en caliente vía un proceso de MU.
- Componentes UI `MU_*Field` (TextField 104 usos, Dropdown 45, IntegerField 16, RadioButton 15, DateField 13…): toda la capa de formulario depende del look&feel de MU.
- Integraciones externas embebidas: `CMP_integracionAppianCapturaDNI`, `CMP_integracionAppianFirmaRGPD`, `TI_integracionAppianTestIdoneidad`, `MU_ObtenerClienteRIC`, `CMP_servicioValidarTelefono`, `CMP_servicioValidarEmail`.

## Sistemas externos (fuera de Appian)

| Sistema | Vía | Uso |
|---|---|---|
| API Life — SBC Taller (`apisbctaller_int-web`) | REST / `TVA API Life` | productos, catálogos, tipos de firma, productores, búsqueda cliente, perfil usuario, documentos |
| API Life — SBC Solicitudes (`apisbcsolicitudes_int-web`) | REST | propuestas de ahorro, solicitud de rentas |
| API Life — SBC Pólizas (`apisbcpolizas_int-web`) | REST | simulación rentas, emisión ahorro, reinversión, notas, documentos póliza |
| SBC Cliente (`sbccliente_be-web`) | REST | importe máximo agrupaciones fiscales |
| Persona Vida (`personavida_be-web`) | REST PUT | gestionar personas |
| MISV / NOVAServices | REST / `TVA MISV` | perfilado de cliente |
| SOA7 MAVISA_910Usuario | SOAP | perfil de usuario |
| Aurora PostgreSQL (`aws-rds-dev.mapfre.es`) | JDBC | trazas y sesión |
| Portal Financiero (GV / PFM) | Web API entrante | arranque de la aplicación |
| Correo | Smart service email | firma manuscrita, alertas |

## Lista completa de referencias externas

Ordenadas por número de usos (usos totales / archivos SAIL o de proceso en que aparecen).

| Objeto | Usos | Archivos |
|---|---|---|
| `rule!MU_TextField` | 104 | 19 |
| `cons!MU_AVISO_TIPOAVISO_ERROR` | 75 | 42 |
| `cons!MU_TRAZA_CODIGOS_CLASE_INFO` | 73 | 43 |
| `cons!VIDA_CODIGOS_TIPO_MEDIO_CONTACTO_MOVIL` | 58 | 24 |
| `cons!VIDA_CODIGOS_TIPO_MEDIO_CONTACTO_EMAIL` | 58 | 27 |
| `rule!CMP_formatearNumero` | 54 | 18 |
| `cons!VIDA_CODIGOS_TIPO_CONTEXTO_OTRO` | 52 | 13 |
| `cons!MU_TRAZA_CODIGOS_CLASE_ERROR` | 51 | 31 |
| `rule!MU_Dropdown` | 45 | 11 |
| `cons!MU_TYPE_NUMBER_LIST_OF_MAP` | 44 | 34 |
| `cons!VIDA_CODIGOS_TIPO_PERSONA_FISICA` | 38 | 17 |
| `rule!VIDA_ObtenerConfiguracionProductoComercial` | 32 | 31 |
| `rule!CMP_indexAnidado` | 30 | 13 |
| `cons!VIDA_CODIGOS_ESTADO_OPERACION_ACEPTADA` | 30 | 20 |
| `rule!MU_Aviso` | 24 | 16 |
| `cons!VIDA_CODIGOS_FIRMA_MANUSCRITA` | 23 | 18 |
| `cons!CMP_VAL_SIGLAS_APLICACION_TVA` | 23 | 6 |
| `cons!CMP_VAL_COLOR_DESACTIVADO` | 22 | 12 |
| `cons!VIDA_CODIGOS_TIPO_PARTICIPANTE_TOMADOR` | 20 | 17 |
| `rule!VIDA_MensajeErrorServicio` | 18 | 8 |
| `rule!MU_Conectar_Host_WebServices` | 18 | 18 |
| `rule!CMP_validacionDNI` | 18 | 8 |
| `cons!VIDA_CODIGOS_FIRMA_ELECTRONICA` | 17 | 17 |
| `rule!MU_IntegerField` | 16 | 7 |
| `cons!CMP_VAL_TRADUCCION_ES` | 16 | 16 |
| `rule!MU_RadioButtonField` | 15 | 6 |
| `cons!VIDA_CODIGOS_TIPO_EVENTO_VIDA` | 15 | 10 |
| `cons!MU_PM_ACTUALIZAR_CONSTANTES` | 15 | 4 |
| `rule!VIDA_ObtenerDatosCombo` | 14 | 9 |
| `cons!VIDA_CODIGOS_TIPO_DIRECCION_FISCAL` | 14 | 9 |
| `cons!CMP_VAL_ENTORNO_PRO` | 14 | 9 |
| `cons!CMP_VAL_COLOR_ESTADO_EXITO` | 14 | 12 |
| `rule!MU_DateField` | 13 | 7 |
| `cons!VIDA_CODIGOS_FIRMA_MANUSCRITA_DESC` | 13 | 13 |
| `cons!VIDA_CODIGOS_FIRMA_ELECTRONICA_DESC` | 13 | 13 |
| `cons!CMP_VAL_ENTORNO_ACTUAL` | 13 | 13 |
| `rule!MU_Igual` | 12 | 3 |
| `cons!VIDA_CODIGOS_ESTADO_OPERACION_DESC_ACEPTADA` | 12 | 12 |
| `cons!MU_AVISO_TIPOAVISO_ADVERTENCIA` | 12 | 8 |
| `cons!CMP_VAL_COLOR_ROJO` | 12 | 7 |
| `rule!VIDA_CNO_Ocupaciones` | 11 | 5 |
| `rule!MU_ComprobarDigitalizacionDocumentoIdentificativo` | 11 | 6 |
| `rule!MU_ClienteNecesitaCPD` | 11 | 6 |
| `cons!VIDA_CODIGOS_TIPO_EVENTO_FALLECIMIENTO` | 11 | 8 |
| `rule!CMP_generarCodigoAleatorio` | 10 | 5 |
| `cons!VIDA_CODIGOS_TIPO_PARTICIPANTE_BENEFICIARIO` | 10 | 7 |
| `cons!MU_TYPE_NUMBER_MAP` | 10 | 4 |
| `cons!CMP_VAL_ENTORNO_DEV` | 10 | 4 |
| `cons!CMP_VAL_COLOR_CLARO` | 10 | 9 |
| `cons!CMP_VAL_COLOR_AZUL_NEGRO` | 10 | 4 |
| `rule!VIDA_Codigos_Sexo` | 9 | 5 |
| `rule!CMP_validacionNIE` | 9 | 5 |
| `cons!MU_AVISO_TIPOAVISO_INFO` | 9 | 7 |
| `cons!MU_AVISO_TIPOAVISO_EXITO` | 9 | 4 |
| `rule!MU_Arbol` | 8 | 5 |
| `rule!CMP_validacionCIF` | 8 | 3 |
| `rule!CMP_errorResponseWebAPI` | 8 | 2 |
| `cons!CMP_VAL_ENTORNO_PRE` | 8 | 2 |
| `rule!MU_NumeroFormateado2Decimal` | 7 | 5 |
| `rule!MU_AjustarCerosIniciales` | 7 | 5 |
| `cons!VIDA_CODIGOS_TIPO_MEDIO_CONTACTO_FIJO` | 7 | 4 |
| `cons!CMP_VAL_COLOR_ESTADO_AVISO` | 7 | 5 |
| `rule!VIDA_PersonName2String` | 6 | 5 |
| `rule!VIDA_ObtenerTelefonoParticipant` | 6 | 2 |
| `rule!VIDA_ObtenerEmailParticipant` | 6 | 2 |
| `rule!VIDA_CNO_Sectores` | 6 | 3 |
| `rule!MU_FormatearNumeroEnTexto` | 6 | 3 |
| `rule!MU_FloatingPointField` | 6 | 6 |
| `cons!VIDA_CODIGOS_FIRMA_BIOMETRICA` | 6 | 3 |
| `cons!CMP_VAL_COLOR_NARANJA` | 6 | 6 |
| `cons!CMP_VAL_COLOR_AZUL_MEDIO_OSCURO` | 6 | 3 |
| `rule!VIDA_ObtenerCodigosPRP` | 5 | 5 |
| `rule!VIDA_Codigos_TipoOperacionInversion` | 5 | 3 |
| `rule!MU_UsernameToNuuma` | 5 | 5 |
| `rule!MU_TextFieldEditable` | 5 | 1 |
| `rule!MU_ObtenerClienteRIC` | 5 | 5 |
| `rule!MU_CheckboxField` | 5 | 4 |
| `rule!MU_ActualizarConstantes_Parametros` | 5 | 1 |
| `cons!CMP_VAL_COLOR_BLANCO` | 5 | 4 |
| `cons!CMP_VAL_COLOR_AZUL` | 5 | 5 |
| `rule!MU_ValidarCodPostalEspannol` | 4 | 2 |
| `rule!MU_GetInfoAviso` | 4 | 1 |
| `rule!CMP_validarIBAN` | 4 | 3 |
| `rule!CMP_servicioValidarTelefono` | 4 | 2 |
| `rule!CMP_integracionAppianCapturaDNI` | 4 | 2 |
| `cons!VIDA_CODIGOS_ESTADO_OPERACION_RECHAZADA` | 4 | 2 |
| `cons!CMP_CS_OBTENER_IP` | 4 | 4 |
| `rule!VIDA_Codigos_TipoProducto` | 3 | 3 |
| `rule!VIDA_Codigos_TipoDireccion` | 3 | 2 |
| `rule!VIDA_CNO_Actividades` | 3 | 3 |
| `rule!MU_Conectar_Host_Apps` | 3 | 2 |
| `rule!CMP_integracionAppianFirmaRGPD` | 3 | 2 |
| `cons!VIDA_CODIGOS_TIPO_PRODUCTO_AHORRO` | 3 | 3 |
| `cons!VIDA_CODIGOS_TIPO_PERSONA_JURIDICA` | 3 | 3 |
| `cons!VIDA_CODIGOS_TIPO_DIRECCION_CORRESPONDENCIA` | 3 | 2 |
| `cons!VIDA_CODIGOS_TIPO_ACTIVIDAD_PRP_NO_ES_O_NO_HA_SIDO` | 3 | 3 |
| `cons!MU_LITERALES_SELECCIONE_UNA_OPCION` | 3 | 1 |
| `cons!MU_LITERALES_NO_HAY_DATOS_PARA_MOSTRAR` | 3 | 1 |
| `cons!CMP_VAL_TIPO_TLF_MOVIL` | 3 | 2 |
| `rule!VIDA_SBC_MensajeError` | 2 | 2 |
| `rule!VIDA_ObtenerTelefonoClientComplete` | 2 | 1 |
| `rule!VIDA_ObtenerIconoTipologiaCliente` | 2 | 2 |
| `rule!VIDA_ObtenerEmailClientComplete` | 2 | 1 |
| `rule!VIDA_ObtenerCodigosOcupacion` | 2 | 2 |
| `rule!VIDA_LiteralModoDeFirma` | 2 | 2 |
| `rule!VIDA_Codigos_TipoMedioContacto` | 2 | 2 |
| `rule!VIDA_Codigos_EstadoCivil` | 2 | 2 |
| `rule!TI_integracionAppianTestIdoneidad` | 2 | 2 |
| `rule!MU_DropdownEditable` | 2 | 2 |
| `rule!CMP_servicioValidarEmail` | 2 | 2 |
| `rule!CMP_catalogoPrefijos` | 2 | 2 |
| `cons!VIDA_URL_CALCULO_JUBILACION_CORREDORES` | 2 | 1 |
| `cons!VIDA_URL_CALCULO_JUBILACION` | 2 | 1 |
| `cons!VIDA_FUNCIONALIDAD_EXCEPCIONES_PARA_CORREDORES` | 2 | 1 |
| `cons!VIDA_CODIGOS_TIPO_PRODUCTO_RENTAS` | 2 | 2 |
| `cons!VIDA_CODIGOS_TIPO_METODO_IDENTIFICACION_NIF` | 2 | 1 |
| `cons!VIDA_CODIGOS_TIPO_COBERTURA_PRINCIPAL` | 2 | 2 |
| `cons!VIDA_CODIGOS_ESTADO_OPERACION_RETENIDA` | 2 | 2 |
| `cons!MU_LITERALES_FORMATO_FECHA_HORA` | 2 | 1 |
| `cons!MU_AVISO_TIPOINFO_COLOR_ICONO` | 2 | 1 |
| `cons!MU_AVISO_TIPOINFO_COLOR_FONDO` | 2 | 1 |
| `cons!CMP_VAL_COLOR_GRIS_MEDIO` | 2 | 2 |
| `cons!CMP_VAL_COLOR_CLIENTE_PLATA` | 2 | 2 |
| `cons!CMP_VAL_COLOR_BLACK_VARIATIONS` | 2 | 2 |
| `cons!CMP_VAL_COLOR_AZUL_GRIS` | 2 | 1 |
| `cons!CMP_VAL_ACCION_CANCELAR` | 2 | 2 |
| `rule!VIDA_ValidacionDocumentoIdentificativo` | 1 | 1 |
| `rule!VIDA_Codigos_TipoPersona` | 1 | 1 |
| `rule!VIDA_Codigos_TipoDocumentoIdentidad` | 1 | 1 |
| `rule!VIDA_Codigos_FrecuenciaContribucion` | 1 | 1 |
| `rule!VIDA_Codigos_EstadoFirma` | 1 | 1 |
| `rule!VIDA_Codigos_CodigoPerfilConveniencia` | 1 | 1 |
| `rule!MU_ParagraphEditable` | 1 | 1 |
| `rule!MU_Paragraph` | 1 | 1 |
| `rule!MU_MenuSuperiorPestannasAccionables` | 1 | 1 |
| `rule!MU_Conectar_URL_SOA7` | 1 | 1 |
| `rule!MU_Conectar_Host_SOA7` | 1 | 1 |
| `rule!MU_Conectar_Host_Misv` | 1 | 1 |
| `rule!CMP_fechaHoraISO8601` | 1 | 1 |
| `rule!CMP_crearNonce` | 1 | 1 |
| `cons!VIDA_PM_LIMPIAR_CACHES_SERVICIOS_VIDA` | 1 | 1 |
| `cons!VIDA_CODIGOS_TIPO_PARTICIPANTE_ASEGURADO` | 1 | 1 |
| `cons!VIDA_CODIGOS_PAIS_ESPANNA` | 1 | 1 |
| `cons!VIDA_ACRONIMO_APLICACION` | 1 | 1 |
| `cons!MU_PM_EXPORTAR_EXCEL` | 1 | 1 |
| `cons!CMP_VAL_TIPO_TLF_FIJO` | 1 | 1 |
| `cons!CMP_VAL_COLOR_TURQUESA` | 1 | 1 |
| `cons!CMP_VAL_COLOR_EXTRA_CLARO` | 1 | 1 |
| `cons!CMP_VAL_COLOR_ESTADO_ERROR` | 1 | 1 |
| `cons!CMP_DOC_ICON_ECOLOGY_LEAF` | 1 | 1 |
| `cons!CMP_DOC_ICONOVENTANAEMERGENTE` | 1 | 1 |

## Dependientes de TVA

Se consultaron los dependientes (`getObjectDependents`) de 27 objetos: los 4 sistemas conectados, las 20 integraciones, las 2 Web APIs y el record type. Resultado:

- Todos los dependientes resueltos pertenecen a la propia aplicación TVA (reglas, procesos, integraciones). No se ha detectado que otra aplicación Appian consuma objetos TVA; el único consumidor externo son los portales GV/PFM que invocan las Web APIs.
- `TVA API Life APPINVE` **no tiene ningún dependiente** más allá de la aplicación: es un sistema conectado sin uso.
- `TVA MISV` tiene dos integraciones dependientes: `TVA_PerfiladoClientes` y un objeto (`79f2b309-…-ac8e655122b4`) que no forma parte del inventario de la aplicación TVA — posiblemente una integración de otra aplicación que reutiliza este sistema conectado. Pendiente de verificar.

No se consultaron los dependientes de las reglas de expresión ni de las interfaces (172 + 96 llamadas adicionales); ver [08-limitaciones.md](08-limitaciones.md).
