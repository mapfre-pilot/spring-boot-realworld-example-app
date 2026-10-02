# 1. Visión general y funcionalidad

## Propósito

TVA permite a un gestor de Mapfre (oficina/productor), desde el Portal Financiero,
**simular, tarificar y contratar** productos de Vida Ahorro y Rentas para uno o dos
tomadores, incluyendo la captura de datos de intervinientes, beneficiarios, opciones de
inversión, documentación precontractual, firma (digital o manuscrita) y emisión de la póliza.

La aplicación no se arranca desde un site Appian de forma autónoma: se **invoca desde el
portal** mediante dos Web APIs (`tarificadorVidaAhorro` y `simuladorRentas`) que crean la
sesión y devuelven la URL del site con la `claveSesion`. Si se abre sin sesión, la pantalla
principal muestra un aviso genérico de fin de ejecución (`TVA_Principal`, rama `default`).

## Modos de funcionamiento

| Modo | Constante | Descripción | Test previo |
|---|---|---|---|
| **VA** | `TVA_VAL_VENTA_ASESORADA` | Venta asesorada de productos de ahorro. Parte de una propuesta (`saveProposal`/`getProposal`) con uno o varios seguros de ahorro. | Test de idoneidad (`TVA_EsValidoTestIdoneidad`) |
| **VIA** | `TVA_VAL_VENTA_INFORMADA` | Venta informada: el usuario selecciona producto/modalidad (incl. cestas de fondos, Unit Linked, PPA). | Test de conveniencia (`TVA_EsValidoTestConveniencia`) |
| **VIR / R2C** | `TVA_VAL_VENTA_RENTAS` | Simulador y contratación de rentas (pantallas `R2C_Captura` y `R2C_Precios`). | — |

Existe además un modo **campaña** (`TVA_ID_PANTALLA_MODALIDAD_CAMPANIA`, site
`TVA Principal Campania`, oculto) que solo muestra un mensaje informativo cuando la
opción de inversión tiene `insuranceOfferInd`.

## Pantallas (máquina de estados)

`TVA_Principal` renderiza cabecera, avisos, la pantalla seleccionada por
`sesion.idPantallaActual` y la botonera. Pantallas:

| Constante `TVA_ID_PANTALLA_*` | Interfaz | Función |
|---|---|---|
| `SELECCION_PRODUCTO_AHORRO` | `TVA_Pantalla_SeleccionProductoAhorro` | Elección de producto/modalidad (VIA) |
| `SEGUROS_AHORRO` | `TVA_Pantalla_SegurosAhorro` | Lista de seguros de la propuesta (VA) |
| `CAPTURA_DATOS_SOLICITUD` | `TVA_Pantalla_CapturaDatosSolicitud` | Wizard de secciones/cajas: tomadores, asegurado, aportante, beneficiarios, datos de la operación, opciones de inversión, domiciliaciones, productores, notas, requisitos |
| `R2C_CAPTURA` | `TVA_Pantalla_R2C_Captura` | Captura de datos de rentas |
| `R2C_PRECIOS` | `TVA_Pantalla_R2C_Precios` | Precios de rentas (recalcular / contratar) |
| `CAPTURA_TOMADOR1` / `CAPTURA_TOMADOR2` | `TVA_Pantalla_CapturaTomador` | Alta/edición de tomador (datos personales, domicilio, contacto, RGPD, DNI) |
| `RESUMEN_CONTRATACION` | `TVA_Pantalla_ResumenContratacion` | Resumen, documentación precontractual, selección de tipo de firma |
| `RESULTADO_FIRMA` | `TVA_Pantalla_ResultadoFirma` | Resultado de la emisión/firma, descarga de póliza |
| `ADMINISTRACION` | `TVA_Pantalla_Administracion` | Apertura/cierre, activar/desactivar funcionalidades, gestión de cachés |
| `SISTEMA_CERRADO`, `SIN_PERFIL`, `SOLO_AVISOS`, `MODALIDAD_CAMPANIA`, `FIN` | avisos `MU_Aviso` | Estados terminales / informativos |

Pop-ups lanzados como acciones sobre el record dummy `TVA Dummy`: intervinientes, cesión
de derechos, RGPD, digitalización de DNI, test de conveniencia, firma.

## Funcionalidades transversales

- **Perfil de usuario**: se recupera vía `TVA_API_Life_perfilUsuario` / SOAP
  `IGestionarPerfilUsuario` (oficina, clave de productor, nuuma). Sin perfil → pantalla `SIN_PERFIL`.
- **Perfilado de cliente** (`TVA_PerfiladoClientes`, MISV) y búsqueda de cliente RIC/Vida.
- **Funcionalidades activables** (`TVA_FUNCIONALIDAD_*`, `TVA_FiltroFuncionalidades`):
  interruptores administrables desde `TVA_Admin_ActivarDesactivar`.
- **Apertura/cierre programado** de la aplicación (`TVA Batch Apertura-Cierre`,
  `TVA_Admin_AperturaCierre`, `TVA_MENSAJE_MOTIVO_CIERRE`).
- **Trazas**: toda petición/respuesta y la sesión se guardan en la entidad `TVA_ENT_TRAZA`
  (60 constantes `TVA_TRAZA_*`); `TVA Batch Borrar traza` las purga.
- **Avisos** (`TVA_Aviso`, `TVA_AVISOS_*`) mostrados en cabecera o en secciones.
- **Alertas** por email a administradores (`TVA IPs`, grupo `TVA Alertas`).
- **Utilidades / Debug** (`TVA_Utilidades_*`, grupo `TVA Debug`): lanzamiento de pruebas
  VA/VIA/VIR con sesiones mock, log, constantes.
