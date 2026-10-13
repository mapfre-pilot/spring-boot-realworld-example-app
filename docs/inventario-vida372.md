# Inventario funcional y técnico — ES_VIDA_372VENCIMIENTOSMANUALES

**Alcance:** lectura del código y artefactos versionados del legacy; no se han ejecutado ni compilado la aplicación ni los programas host. Las rutas citadas son relativas a la raíz del repositorio y apuntan al snapshot inventariado.

Para acortar las referencias:

- **WSS** = `legacy/ES_VIDA_372VENCIMIENTOSMANUALES/2 - DES Desarrollo/3 - Programacion/JAVA/WSS372VENCIMIENTOSMANUALES/`
- **IMP** = `legacy/ES_VIDA_372VENCIMIENTOSMANUALES/3 - IMP Implantacion/`
- **JAVA** = `WSS/Java Source/com/mapfre/mavisa/wss372vencimientosmanuales/`

## 1. Funcionalidades, pantallas y navegación Struts

La navegación se declara en `WSS/Web Content/WEB-INF/struts-config.xml`; los formularios en `WSS/Java Source/com/mapfre/mavisa/wss372vencimientosmanuales/forms/`; y las vistas en `WSS/Web Content/jsp/`. La tabla registra las 27 declaraciones de `<action>` (26 paths distintos). `OK`, `continuar` y `enviar` son los nombres de forward declarados.

| Path Struts | Action class | ActionForm (bean) | Forward |
|---|---|---|---|
| `/gestionVariablesVen` | `J372J007GestionVariablesVenAction` | `formGestionVariables` | `OK → /jsp/gestionVariablesVen.jsp` |
| `/inicioGestionVariablesVen` | `J372J007GestionVariablesVenAction` | `formGestionVariables` | `OK → /jsp/gestionVariablesVen.jsp` |
| `/emisionFiniquitosVen` | `J372J003EmisionFiniquitosVenAction` | `formEmisionFiniquitos` | `OK → /jsp/emisionFiniquitosVen.jsp` |
| `/inicioEmisionFiniquitosVen` | `J372J003EmisionFiniquitosVenAction` | `formEmisionFiniquitos` | `OK → /jsp/emisionFiniquitosVen.jsp` |
| `/gestionCarterasVen` | `J372J005GestionCarterasVenAction` | `formGestionCarteras` | `OK → /jsp/gestionCarterasVen.jsp` |
| `/peticionBDGIVen` | `J372J009PeticionBDGIVenAction` | `formPeticionBDGI` | `OK → /jsp/peticionBDGIVen.jsp` |
| `/inicioPeticionBDGIVen` | `J372J009PeticionBDGIVenAction` | `formPeticionBDGI` | `OK → /jsp/peticionBDGIVen.jsp` |
| `/listadoGestionCarterasVen` | `J372J013ForwardSuccessListadoAction` | `formGestionCarteras` | `continuar → /jsp/gestionCarterasListadoVen.jsp` |
| `/reaseguroVen` | `J372J010ReaseguroVenAction` | `formReaseguro` | `OK → /jsp/reaseguroVen.jsp` |
| `/inicioReaseguroVen` | `J372J004ForwardSuccessAction` | `formReaseguro` | `OK → /jsp/reaseguroVen.jsp` |
| `/impresionInformesVen` | `J372J008ImpresionInformesVenAction` | `formImpresionInformes` | `OK → /jsp/impresionInformesVen.jsp` |
| `/inicioImpresionInformesVen` | `J372J008ImpresionInformesVenAction` | `formImpresionInformes` | `OK → /jsp/impresionInformesVen.jsp` |
| `/busquedaExpFormVen` | `J372J001BusquedaExpVenAction` | `formBusquedaExp` | `OK → /jsp/contenedor.busquedaExpedientesVen.jsp` |
| `/listadoBusquedaExpVen` | `J372J013ForwardSuccessListadoAction` | `formBusquedaExp` | `continuar → /jsp/busquedaExpListadoVen.jsp` |
| `/inicioModificarExpVen` | `J372J018InicioModificacionAction` | `formBusquedaExp` | `OK → /jsp/contenedor.gestionExpedientesVen.jsp` |
| `/modificarExpVen` | `J372J019ModificacionAction` | `formBusquedaExp` | `OK → /jsp/gestionExpedientesVen.jsp` |
| `/inicioBusquedaExpVen` | `J372J004ForwardSuccessAction` | `formBusquedaExp` | `OK → /jsp/contenedor.busquedaExpedientesVen.jsp` |
| `/gestionExpedientesVen` | `J372J012GestionExpedientesVenAction` | `formGestionExped` | `OK → /jsp/gestionExpedientesVen.jsp` |
| `/inicioGestionExpedVen` | `J372J004ForwardSuccessAction` | `formGestionExped` | `OK → /jsp/contenedor.altaGestionExpedientesVen.jsp` |
| `/contGestionExpedVen` | `J372J012GestionExpedientesVenAction` | `formGestionExped` | `OK → /jsp/gestionExpedientesVen.jsp` |
| `/consultaCarteraVen` | `J372J014ConsultaCarteraVenAction` | `formGestionExped` | `OK → /jsp/gestionExpedientesVen.jsp` |
| `/cargarCuadroCoasegurosVen` | `J372J020GestionExpCoaseguroVenAction` | `formGestionExped` | `OK → /jsp/gestionExpedientesVen.jsp` |
| `/lanzarImpresionDirecta` | `J372J015ImpresionDirectaAction` | `formImpresionInformes` | `enviar → /jsp/impresionInformesVen.jsp` |
| `/obtenerDatosFiscalidad` | `J372J004ForwardSuccessAction` | `formGestionExped` | `OK → /jsp/frameFiscalidad.jsp` |
| `/cargaFicheroVen` | `J372J011CargaFicheroVenAction` | `formCargaFichero` | `OK → /jsp/cargaFicheroVen.jsp` |
| `/inicioCargarFicheroVen` | `J372J004ForwardSuccessAction` | `formCargaFichero` | `OK → /jsp/cargaFicheroVen.jsp` |
| `/modificarExpVen` (**segunda declaración**) | `J372J019ModificacionAction` | `formBusquedaExp` | `OK → /jsp/gestionExpedientesVen.jsp` |

### Formularios declarados

Los nombres siguientes son los beans del `struts-config.xml`; se indica su clase concreta y el contenido funcional principal observado en campos JSP/ActionForm (`WSS/Web Content/WEB-INF/struts-config.xml`, `JAVA/forms/*.java`).

| Bean | Clase ActionForm | Datos principales |
|---|---|---|
| `formBusquedaExp` | `J372J001BusquedaExpVenActionForm` | selector de búsqueda y datos de expediente, póliza, beneficiarios, situación, valores fiscales/financieros que pueden cargarse al pasar al detalle; es un formulario amplio reutilizado entre búsqueda y modificación. |
| `formEmisionFiniquitos` | `J372J002EmisionFiniquitosVenActionForm` | año, intervalo de expedientes, regional de envío y fecha efectiva de emisión. |
| `formGestionVariables` | `J372J004GestionVariablesVenActionForm` | año y expediente, más código/descripcion de operación/retorno. |
| `formImpresionInformes` | `J372J005ImpresionInformesVenActionForm` | tipo, año/expediente o intervalos, fechas de cálculo/emisión/pago y opción de imprimir. |
| `formPeticionBDGI` | `J372J006PeticionBDGIVenActionForm` | año, mes, fecha inicial/final y confirmación. |
| `formReaseguro` | `J372J007ReaseguroVenActionForm` | operación y retorno del procesamiento. |
| `formGestionCarteras` | `J372J003GestionCarterasVenActionForm` | formulario declarado para filtros de cartera; la pantalla/Action correspondientes no están completas en el snapshot (véase hallazgos). |
| `formGestionExped` | `J372J008GestionExpedientesVenActionForm` | formulario de alta/gestión amplio: identificación de póliza y expediente, fechas y estado, importes de capital/beneficios/complementarios, impuestos, rendimientos, retenciones/liquidaciones, personas y datos fiscales, reaseguro, BDGI y coaseguros. |
| `formCargaFichero` | `J372J010CargaFicheroVenActionForm` | tipo de fichero/operación y resultado. |

### Casos de uso

1. **Búsqueda de expedientes.** El usuario elige buscar por año/expediente, póliza (ramo, año y número, subpóliza/certificado) o NIF/CIF; el resultado tabular muestra expediente, póliza, canal, entidad, situación, beneficiario y ubicación. La fila seleccionada conduce al detalle/modificación. Intervienen `/busquedaExpFormVen`, `/inicioBusquedaExpVen`, `/listadoBusquedaExpVen`, `/inicioModificarExpVen` y `/modificarExpVen`; vistas `contenedor.busquedaExpedientesVen.jsp`, `busquedaExpFormVen.jsp`, `busquedaExpListadoVen.jsp`, `contenedor.gestionExpedientesVen.jsp` y `gestionExpedientesVen.jsp` (`WSS/Web Content/jsp/`).
2. **Alta, consulta, modificación y anulación de expedientes.** El detalle reúne póliza, tomador/beneficiarios, fechas, capital, beneficios, anticipos/intereses, hasta dos conceptos complementarios, impuestos/retención/líquido, datos fiscales y hasta seis posiciones de coaseguro; incluye acciones de alta, modificación, consulta de cartera, anulación y devolución de información fiscal. Las entradas se validan en parte en navegador y se envían al host para persistir/recuperar el expediente. Paths `/inicioGestionExpedVen`, `/gestionExpedientesVen`, `/contGestionExpedVen`, `/consultaCarteraVen`, `/cargarCuadroCoasegurosVen`, `/obtenerDatosFiscalidad` y las dos rutas de modificación anteriores; vistas `contenedor.altaGestionExpedientesVen.jsp`, `contenedor.gestionExpedientesVen.jsp`, `gestionExpedientesVen.jsp`, `frameFiscalidad.jsp` (`struts-config.xml`, `JAVA/actions/J372J012GestionExpedientesVenAction.java`, `J372J019ModificacionAction.java`, `WSS/Web Content/js/GestionExpedienteVen.js`).
3. **Emisión de finiquitos.** Se filtra por año e intervalo de expedientes, regional de envío y fecha efectiva; el backend devuelve registros para emitir y el subsistema de impresión genera el documento. Paths `/inicioEmisionFiniquitosVen` y `/emisionFiniquitosVen`; vista `emisionFiniquitosVen.jsp`; impresión asociada a `JAVA/actions/J372J017ImpresionEmisionDirecta.java` y plantilla QFS (`legacy/ES_VIDA_372VENCIMIENTOSMANUALES/2 - DES Desarrollo/3 - Programacion/Recursos/sgdd/FormsPath/MAVISA/`).
4. **Gestión de variables.** Se consulta/actualiza el conjunto de variables asociado a un expediente identificado por año y número; la pantalla ofrece la operación de guardado. Paths `/inicioGestionVariablesVen` y `/gestionVariablesVen`; vista `gestionVariablesVen.jsp`.
5. **Impresión de informes.** Permite elegir tipo de informe y criterios por ejercicio/expediente, fechas de cálculo/emisión/pago; la respuesta contiene una lista de datos que se mapea a etiquetas de plantilla FormsPath. Paths `/inicioImpresionInformesVen`, `/impresionInformesVen` y `/lanzarImpresionDirecta`; vista `impresionInformesVen.jsp`.
6. **Petición BDGI.** El usuario indica año, mes e intervalo de fechas; el servicio envía la solicitud de información a prestaciones y devuelve el estado/retorno. Paths `/inicioPeticionBDGIVen` y `/peticionBDGIVen`; vista `peticionBDGIVen.jsp`.
7. **Reaseguro.** Pantalla de confirmación/acción para operar la gestión de reaseguro vinculada al expediente; los datos de operación y retorno se manejan en `formReaseguro`. Paths `/inicioReaseguroVen` y `/reaseguroVen`; vista `reaseguroVen.jsp`.
8. **Consulta/gestión de cartera.** El formulario declarado apunta a criterios de modalidad, fechas de efecto, cartera, entidad y tipo de operación; el listado es un forward separado. Paths `/gestionCarterasVen` y `/listadoGestionCarterasVen`; los JSP de destino no aparecen en `WSS/Web Content/jsp/`.
9. **Carga de fichero.** La pantalla deja seleccionar el tipo de fichero/operación, que se remite al servicio host; la carga ejecutable/procesamiento ulterior está en el mainframe y su calendario operativo. Paths `/inicioCargarFicheroVen` y `/cargaFicheroVen`; vista `cargaFicheroVen.jsp`.
10. **Coaseguro y búsqueda de personas/datos fiscales.** En el detalle se mantienen códigos y porcentajes de hasta seis coaseguradoras, se distribuyen importes y se consultan datos de persona/domicilio por una ventana auxiliar; los datos fiscales se muestran en `frameFiscalidad.jsp`. El cuadro usa `/cargarCuadroCoasegurosVen`; la búsqueda de persona se implementa como servicio desde `GestionPersonaVen.js`/Beans, no como mapping Struts independiente.

### Observaciones de navegación

- La ruta `/modificarExpVen` está declarada dos veces con el mismo tipo, nombre de form y forward en `WSS/Web Content/WEB-INF/struts-config.xml`.
- El árbol contiene 15 JSP y un fragmento JSPF. Entre las vistas están también `blancoRep.jsp`, `busquedaExpContVen.jsp` e `app/errores/IncludeMensajes.jspf`; no todas son forwards directos en el fichero Struts.
- `gestionCarterasVen.jsp` y `gestionCarterasListadoVen.jsp` son destinos declarados, pero no aparecen en el árbol JSP inspeccionado. Tampoco se encontró la clase `J372J005GestionCarterasVenAction` bajo `JAVA/actions/`; no se puede concluir del snapshot si esos recursos se suministran externamente.

## 2. Servicios Java, XML y host

### Contrato de llamada

Los servicios se configuran bajo `WSS/Servicios/IN372VENCIMIENTOSMANUALES/` y se empaquetan para implantación en `IMP/Recursos/Servicios/IN372VENCIMIENTOSMANUALES/`. La clase común `JAVA/servicios/J372J003ServicioCobol.java` obtiene el servicio host mediante `J000J000GestorServicios.obtenerServicioHost(interface, servicio)` y crea el conector con `J000J000FactoriaAccesoDatos.crearConector(servicio, usuario)`. Los Beans lo llaman con la interfaz `IN372VENCIMIENTOSMANUALES`; los campos de control comunes del XML incluyen `KSERVICIO-C`, `CCANAL-C`, `KEMPRESA-C`, `KDEPARTA-C`, `KUSUARIO-C`, `KCADISTR-C`, `KFILTRO-C` y `FILLER-C`. No es una API HTTP/REST local: la conexión es por el framework MAPFRE hacia la transacción CICS y su programa COBOL.

| Servicio XML (`B372VT*`) | Programa / transacción CICS | Bean Java caller hallado | Propósito y principales entradas/salidas |
|---|---|---|---|
| `B372VT01GestionExpedientesVen.xml` | `B372VT01` / `3701` | `J372J005ServicioGestionExpVenBean` | Alta/consulta/modificación del expediente; entrada con operación, año/expediente y póliza, importes/fechas de capital y complementarios, parámetros fiscales, beneficiarios, banderas BDGI y ocurrencias de coaseguro; salida de claves, importes recalculados y código/texto de retorno. El XML declara 93 campos de entrada y 9 de salida. |
| `B372VT02GestionVariablesVen.xml` | `B372VT02` / `3702` | `J372J006ServicioGestionVariablesBean` | Lectura/actualización de variables del sistema asociadas a año y expediente; devuelve estado/código de operación. El layout COBOL asociado es `X372VT02`. |
| `B372VT03GestionCarterasVen.xml` | `B372VT03` / `3703` | No encontrado en `JAVA/servicios/*.java` | Configuración de servicio para gestión/consulta de carteras; entrada de criterios de cartera y filtros de póliza/fecha, salida de datos de cartera. No se halló programa `B372VT03` en `IMP/App_ZOS/P02PROGR/`. |
| `B372VT04BusquedaExpVen.xml` | `B372VT04` / `3704` | `J372J001ServicioBusquedaExpVenBean` | Búsqueda por expediente, año, póliza, beneficiario y situación/paginación; salida de filas con datos de expediente, póliza, beneficiario, ubicación y situación. Se extrajeron 12 campos de entrada y 102 de salida. |
| `B372VT05GestionCarterasListadoVen.xml` | `B372VT05` / `3705` | No encontrado en `JAVA/servicios/*.java` | Servicio de listado de cartera; parámetros de filtro y salida repetitiva para filas. No se encontró el programa `B372VT05` en las fuentes `P02PROGR` del snapshot. |
| `B372VT06PeticionBDGIVen.xml` | `B372VT06` / `3706` | `J372J008ServicioPeticionBDGIVenBean` | Solicitud BDGI: año, mes y fechas inicial/final; retorna estado/error de envío. |
| `B372VT07CargaFicheroVen.xml` | `B372VT07` / `3707` | `J372J010ServicioCargaFicheroBean` | Solicita la carga/procesamiento según tipo de fichero/operación; comunica retorno host. El programa COBOL enlaza con infraestructura común de procesamiento de ficheros. |
| `B372VT08BusquedaAdicExpVen.xml` | `B372VT08` / `3708` | `J372J001ServicioBusquedaExpVenBean` | Búsqueda adicional de expediente usada después de la consulta principal; amplía los datos necesarios para mostrar/abrir el detalle. La referencia Java y el XML aparecen en implantación, pero este XML no está en la carpeta `WSS/Servicios/` de desarrollo. |
| `B372VT09EmisionFiniquitosVen.xml` | `B372VT09` / `3709` | `J372J004ServicioEmisionFiniquitosVenBean` | Emisión por ejercicio/rango de expedientes, regional y fecha efectiva; devuelve datos de finiquito que se preparan para imprimir. El COBOL enlaza con `B372N009`. |
| `B372VT10ImpresionInformesVen.xml` | `B372VT10` / `3710` | `J372J009ServicioImpresionInformesVenBean` | Consulta de registros para informes, con filtros por año/expediente y fechas; devuelve filas con datos de póliza, liquidación, persona e impuestos. El COBOL enlaza con `B372N010`. |
| `B372VT11GestionPersonasVen.xml` | `B372VT11` / `3711` | `J372J010ServicioBusquedaPersonasVenBean` | Búsqueda de persona/beneficiario y sus datos fiscales y de domicilio; el wrapper host llama al módulo compartido `B362N011`. |
| `B372VT12GestionExpCoaseguroVen.xml` | `B372VT12` / **`3612`** | `J372J011ServicioExpCoaseguroVenBean` | Gestión del cuadro de coaseguro: expediente, códigos y porcentajes/valores por coaseguradora; salida con importes/estado. Se conserva el número transaccional `3612` declarado en la configuración, no `3712`. |
| `B372VT19ConsultaCarteraVen.xml` | `B372VT19` / `3719` | `J372J007ServicioConsultaCarteraVenBean` | Consulta de cartera/póliza en el servicio legacy; el programa CICS enlaza con `B362VT19`. |

Para cada fila, el nombre de XML indicado se encuentra en `WSS/Servicios/IN372VENCIMIENTOSMANUALES/` cuando pertenece al paquete de desarrollo; los 13 contratos de implantación (incluidos VT08, VT03 y VT05) se encuentran en `IMP/Recursos/Servicios/IN372VENCIMIENTOSMANUALES/`. Los layouts COBOL `X372VT01`, `X372VT02`, `X372VT04`, `X372VT06`–`X372VT12` y `X372VT19` se encuentran en `IMP/App_ZOS/P01COPYS/`; contienen los campos y longitudes de intercambio correspondientes. Para VT01 son explícitos importes con dos decimales, porcentajes, fechas y una ocurrencia de coaseguro; el XML completo es la fuente normativa del detalle del contrato.

### Funcionalidades por entorno

Los ficheros `IN372VENCIMIENTOSMANUALES.xml` de `WSS/Funcionalidades/{desa,tran,real}/` (y las copias en `2 - DES Desarrollo/3 - Programacion/Recursos/Funcionalidades/{desa,tran,real}/` e `IMP/Recursos/Funcionalidades/{desa,tran,real}/`) declaran los mismos códigos funcionales en los tres entornos: `10020 expedientes.gestion`, `10021 expedientes.alta`, `10022 expedientes.consulta`, `10023 expedientes.modificacion`, `10024 expedientes.busqueda`, `10025 expedientes.anulacion`, `10026 expedientes.simular`, `10027 expedientes.enviarfiscalidad`, `10028 variables.gestiona`, `10029 emision.finiquitos`, `10030 bgdi.alta`, `10031 reaseguro.alta`, `10032 informes.consulta` y `10033 cargar.fichero`. No se observaron diferencias desa/tran/real en esos tres ficheros.

### Servicios COBOL compartidos

`JAVA/servicios/J372J003ServicioCobol.java` solo resuelve el XML por interfaz/nombre, obtiene el usuario de arquitectura recibido y crea el conector común; la serialización del copybook, transporte CICS y control de errores recaen en `MAPFRE_VIDA_COMUN` y las librerías host. En los wrappers COBOL se observan enlaces a lógica compartida, entre ellos `B372N001` (gestión), `B372N004` (búsqueda), `B372N009` (emisión), `B372N010` (informes), `B362N011` (persona), `B372V012` (coaseguro) y `B362VT19` (consulta de cartera). Las operaciones SQL/DB2 están en módulos COBOL de negocio/persistencia; los programas Java no contienen consultas SQL locales.

## 3. Host, mainframe, DB2 y batch

### Fuentes y catálogos de implantación

`IMP/App_ZOS/P01COPYS/` contiene **27** miembros:

`@COPYCOB`, `@INCLUDE`, `@PROGRAM`, `X372M001`, `X372M004`, `X372M006`, `X372M011`, `X372M012`, `X372MCOA`, `X372N003`, `X372N005`, `X372N007`, `X372PS19`, `X372VT01`, `X372VT02`, `X372VT04`, `X372VT06`, `X372VT07`, `X372VT08`, `X372VT09`, `X372VT10`, `X372VT11`, `X372VT12`, `X372VT19`, `X372X101`, `X372X102`, `X372X103`.

`IMP/App_ZOS/P02PROGR/` contiene **71** miembros:

`@COPYCOB`, `@INCLUDE`, `@PROGRAM`, `B371K003`, `B372J001`–`B372J015` (falta `B372J016`), `B372J017`–`B372J027`, `B372JCOA`, `B372JI11`, `B372JI12`, `B372JI13`, `B372JI14`, `B372JI18`, `B372K001`, `B372K002`, `B372K016`, `B372KA75`, `B372KVEN`, `B372M001`, `B372M004`, `B372M006`, `B372M008`, `B372M011`, `B372M012`, `B372MCOA`, `B372N001`, `B372N003`, `B372N004`, `B372N005`, `B372N006`, `B372N007`, `B372N009`, `B372N010`, `B372V012`, `B372VT01`, `B372VT02`, `B372VT04`, `B372VT06`–`B372VT12`, `B372VT19`, `VB372K02`, `VC370001`, `VC370526`. La lista refleja nombres efectivamente presentes; los rangos se han usado solo para abreviar secuencias contiguas.

`IMP/App_ZOS/RECATLG/` incluye cinco miembros de catálogo:
`@RECATLG_000.009.00.00`, `@RECATLG_000.010.00.00`, `@RECATLG_000.011.00`, `@RECATLG_000.012.00.00` y `@RECATLG_000.013.00.00`.

Las fuentes de servicio presentes `B372VTxx` son wrappers CICS que intercambian los copybooks `X372VTxx` disponibles; no hay fuente/copy local de VT03 y VT05 en este paquete. Las rutinas `B372J*`, `B372N*`, `B372M*`, `B372K*` y `B372JI*` contienen operaciones de negocio, persistencia, carga y procesamiento batch. La búsqueda de SQL en `P02PROGR` localiza accesos a `TB372VEN0`, `TB372CCV0` y `TB372MIG0` en los módulos `B372J*`, `B372K*`, `B372M*`, `B372JI*` y `B372N*` relacionados; el conjunto usa también componentes compartidos del entorno host. Referencias: `IMP/App_ZOS/P02PROGR/B372VT01`, `B372VT04`, `B372VT07`, `B372VT08`, `B372VT09`, `B372VT10`, `B372VT11`, `B372VT12` y `B372VT19`.

### DB2: objetos con DDL presente

Se inspeccionaron los ZIP de `IMP/BD_DB2/`; contienen JCL de utilidades y sentencias DDL, no solo listados de nombres. Se identifican los espacios `TS372VEN`, `TS372CCV` y `TS372MIG` en la base lógica `BD372VEM`. Los siguientes son los nombres de columna extraídos de los miembros SQL:

- **`TB372VEN0` — 80 columnas en el DDL más reciente revisado** (`BD372VEM.G0183234.zip/BD372000.TXT`): `VEN0_ANIO`, `VEN0_KEXPEDIENTE`, `VEN0_KRAMO`, `VEN0_ANIOPOL`, `VEN0_KPOLIZA`, `VEN0_NSUBPOLIZA`, `VEN0_KCERTIFICADO`, `VEN0_KMODALIDAD`, `VEN0_CCANALCAMP`, `VEN0_CENTIDAD`, `VEN0_FECEFECTO`, `VEN0_KDURACION`, `VEN0_FECEMISION`, `VEN0_CCARTERA`, `VEN0_SREASEGURO`, `VEN0_REGIONAL`, `VEN0_LUGARENVIO`, `VEN0_KOFICINA`, `VEN0_IPENDIENTE`, `VEN0_CTIPOPERS1`, `VEN0_SRESIDENTE1`, `VEN0_NIF1`, `VEN0_KPERSONA1`, `VEN0_IMPCAPITAL`, `VEN0_IMPBENEFICIOS`, `VEN0_FECPAGOCAPITAL`, `VEN0_IMPANTICIPO`, `VEN0_IMPINTEPEND`, `VEN0_FECVENCIMICAP`, `VEN0_TIPIMPUESTCAP`, `VEN0_IMPRTOINTEGRCAP`, `VEN0_IMPREDPRICAP`, `VEN0_IMPREDTRANCAP`, `VEN0_IMPCOMPENSATORIA`, `VEN0_IMPRTONETOCAP`, `VEN0_PORRETCAP`, `VEN0_IMPRETCAP`, `VEN0_IMPLIQCAP`, `VEN0_FECIMPRECAP`, `VEN0_FECPAGRET`, `VEN0_IMPCOMP1`, `VEN0_FECPAGCOMP1`, `VEN0_FECEMICOMP1`, `VEN0_TIPIMPUESTCOMP1`, `VEN0_IMPRTOINTCOMP1`, `VEN0_IMPREDPRICOMP1`, `VEN0_IREDTRANCOMP1`, `VEN0_IRTONETCOMP1`, `VEN0_PORRETCOMP1`, `VEN0_IRETCOMP1`, `VEN0_ILIQCOMP1`, `VEN0_FECIMPRECOMP1`, `VEN0_FECPAGRETCOM1`, `VEN0_IMPCOMP2`, `VEN0_FECPAGCOMP2`, `VEN0_FECEMICOMP2`, `VEN0_TIPIMPUESTCOMP2`, `VEN0_IMPRTOINTCOMP2`, `VEN0_IMPREDPRICOMP2`, `VEN0_IREDTRANCOMP2`, `VEN0_IRTONETCOMP2`, `VEN0_PORRETCOMP2`, `VEN0_IRETCOMP2`, `VEN0_ILIQCOMP2`, `VEN0_FECIMPRECOMP2`, `VEN0_FECPAGRETCOM2`, `VEN0_PAGOTOT`, `VEN0_CUSUARIO`, `VEN0_SBDGICAP`, `VEN0_FECBDGICAP`, `VEN0_SBDGICOMP1`, `VEN0_FECBDGICOMP1`, `VEN0_SBDGICOMP2`, `VEN0_FECBDGICOMP2`, `VEN0_GOBSERVACION`, `VEN0_ANIOFISCAL`, `VEN0_KDOMICILIO1`, `VEN0_FMODIFICACION`, `VEN0_EXIMIDO`, `VEN0_KDOMCOM`.
- **`TB372CCV0` — 12 columnas** (`BD372VEM.G0183234.zip/BD372000.TXT`): `CCV0_ANIO`, `CCV0_KEXPEDIENTE`, `CCV0_NCOA`, `CCV0_CODCOA`, `CCV0_PORCOA`, `CCV0_IMPCOA`, `CCV0_IMPRTOINTEGRCOA`, `CCV0_IMPREDPRICOA`, `CCV0_IMPREDTRANCOA`, `CCV0_IMPRTONETOCOA`, `CCV0_IMPRETCOA`, `CCV0_IMPCOMPENSATCOA`.
- **`TB372MIG0` — 28 columnas** (`ABD.DESA.D260727.BD372VEM.R2432677.zip/BD372001.txt`): `MIG0_ANIO`, `MIG0_KEXPEDIENTE`, `MIG0_VEN_MIGR`, `MIG0_USUARIO_PAGO`, `MIG0_FCAPTURA`, `MIG0_CUSUARIO_CAPT`, `MIG0_FORMAPAGO`, `MIG0_NUM_CHEQUE`, `MIG0_NUM_CUENTA`, `MIG0_REF_REINVERSION`, `MIG0_CUSU_PAGO_COMP1`, `MIG0_FCAPTURA_COMP1`, `MIG0_CUSU_CAPT_COMP1`, `MIG0_FORMAPAGO_COMP1`, `MIG0_NCHEQUE_COMP1`, `MIG0_NCUENTA_COMP1`, `MIG0_CUSU_PAGO_COMP2`, `MIG0_FCAPTURA_COMP2`, `MIG0_CUSU_CAPT_COMP2`, `MIG0_FORMAPAGO_COMP2`, `MIG0_NCHEQUE_COMP2`, `MIG0_NCUENTA_COMP2`, `MIG0_GRADO_DISCAP`, `MIG0_PREST_VIVIENDA`, `MIG0_SITU_FAMILIAR`, `MIG0_NIF_CONYUGUE`, `MIG0_ICOMPENSATORIA`, `MIG0_IMPALIMENHIJOS`.

Hay DDL/versiones anteriores con **87** columnas en `TB372VEN0`, incluyendo `VEN0_CODCOA1..6` y `VEN0_PORCOA1..6` en la propia tabla; en el DDL más nuevo revisado el cuadro se separa en `TB372CCV0`. También varían anchos/precisiones entre entregas. Antes de migrar el modelo se debe fijar qué release y esquema son los realmente desplegados; los ZIP históricos no prueban por sí solos el estado del entorno actual. Otros miembros de los ZIP ejecutan `ALTER`, `COPY`, `REORG` y `RUNSTATS`. Archivos de referencia: `IMP/BD_DB2/BD372VEM.G0037764.zip`, `G0135451.zip`, `G0147240.zip`, `G0183234.zip`, `D160328.BD372VEM.G0147930.zip`, `D170322.BD372VEM.G0176383.zip`, `ABD.DESA.D260727.BD372VEM.R2432677.zip` y `Scripts orden 1 y 2.zip`.

### APP_JCL, operativa y pruebas

- `IMP/APP_JCL/` tiene los ZIP `App_JCL v1_0.zip` y `App_JCLv1_1.zip`, con formularios de explotación y diagramas `.drw`/`.jpg`; el directorio `2 - DES Desarrollo/3 - Programacion/JCL/` solo tiene `readme.txt`, no fuentes JCL sueltas.
- Se leyó con `xlrd` el fichero `App_JCL v1_0.xls` incluido en los ZIP. Su hoja `App_JCL` enumera seis cadenas: `X0323760` (informe por retención de capital), `X0323761` (informe por retención por trabajo), `X0323762` (informe sin retención), `X0323765` (carga de fichero de expedientes), `X0323766` (carga de datos fiscales) y `X0323767` (carga de datos complementarios).
- `IMP/Operativa Batch/Plantillas Batch Mainframe/readme.txt` solo solicita incluir plantillas rellenas; `IMP/Pruebas Implantacion/readme.txt` solicita ficheros relevantes del resultado de pruebas. No se encontraron plantillas rellenadas ni evidencias de pruebas dentro de esas carpetas. Las cadenas detalladas arriba sí aparecen en el inventario del XLS incluido en APP_JCL.
- La ficha general de implantación está en `IMP/Ficha de aplicacion.xls`; se puede leer y contiene siete hojas (`Datos Generales`, `Frontend`, `Backend`, `Midleware`, `Citrix`, `Tablas`, `RESUMEN`) de plantilla, sin información de cambio efectiva completada en los apartados muestreados.

### Hojas de software y releases

Los tres XLS de `IMP/` fueron legibles con `xlrd` instalado en un virtualenv fuera del repositorio:

- `IMP/SW_A372VEN.xls`: 39 hojas de versiones/release (desde `v2_8` hasta `030`, más plantilla de ejemplo); relaciona entregables web, COBOL host, copybooks, plantillas de impresión y, en algunas hojas, DB2. Entre los componentes históricos aparecen `WSS372VENCIMIENTOSMANUALES`, `B372VT*`, `B372N*`, `B372J*`, `B372M*`, `X372VT*` y `EmisionFiniquitoVencimientos.qdf`.
- `IMP/SW_A372VENM.xls`: 52 hojas de releases/histórico; registra elementos `APP_WEB`, `APP_ZOS`, `BD_DB2` y plantillas, incluidas entradas de cambios de 2015–2021, ajustes de DB2, gestión de datos fiscales y de coaseguro, migraciones y mantenimiento. Es un histórico de instalación, no una prueba de que cada componente histórico siga desplegado.
- `IMP/Ficha de aplicacion.xls`: ficha estructural de cambio/despliegue en forma de plantilla. El libro de cadenas JCL descrito antes está dentro de los ZIP, no como XLS independiente en la raíz.

## 4. Reglas de negocio y validación

- `WSS/Web Content/js/GestionCalculoVen.js` calcula duración/fecha de vencimiento, importes pendientes y liquidación; `RtoNeto = RtoIntegro - RedPrimas - RedTransit`; la retención se calcula como `RtoNeto * porcentaje / 100`; y el líquido de capital resta retención, anticipo e intereses pendientes. Estas son reglas visibles en cliente, no sustituyen el cálculo host.
- `WSS/Web Content/js/GestionExpedienteCalculoVen.js` prorratea importes y rendimientos por porcentaje de coaseguro, recalcula campos derivados y ajusta diferencias de redondeo para cerrar totales de filas (hasta seis coaseguradoras). La rama reconoce un código de compañía MAPFRE específico; los límites y redondeos deben conservarse con pruebas de equivalencia.
- `WSS/Web Content/js/GestionExpHabilitarLimpiarVen.js` habilita/deshabilita y limpia campos según operación, opción de valores manuales y configuración del coaseguro. `GestionExpedienteVen.js` contiene navegación de alta/modificación/consulta y cambios asociados a tipos de impuesto; `GestionPersonaVen.js` integra búsqueda/retorno de persona, domicilio y fiscalidad.
- `WSS/Web Content/js/GenericoVen.js` y `utilidades.js` contienen utilidades de formato de fecha, parseo coma/punto, relleno de ceros, longitud/caracteres permitidos, validaciones de documento (NIF/CIF) e importes/rangos; `psurtsub.js` contiene valores fijos de subcentrales/regiones. `impuestosVen.js` está presente, pero no aporta reglas significativas en el archivo inspeccionado.
- `WSS/Web Content/WEB-INF/validator.xml` tiene vacío el bloque de validación declarativa. `validator-rules.xml` contiene reglas estándar de Struts Validator, pero no define las reglas funcionales propias de estos formularios. `web.xml` configura el servlet Struts con `validate=true`; no debe interpretarse como prueba de que `validator.xml` esté aplicando validaciones de negocio. Revisar también las validaciones de cada ActionForm y validar en servidor al migrar.
- `JAVA/config/J372J001ConstantesVen.java` define claves de sesión/contexto (`HTTP_PATH`, `GV`, `informes`, `emision`), códigos de retorno y nombre lógico de plantilla FormsPath `EMISIONFINIQUITOVENCIMIENTOS`. `JAVA/resources/ApplicationResources.properties` centraliza los literales de pantallas y mensajes: búsquedas, gestión del expediente, póliza, impuestos, beneficiario/fiscalidad, coaseguro, BDGI, impresión y carga. El formulario `J372J008GestionExpedientesVenActionForm` inicializa algunos tipos de impuesto a `"34"`; es un default de interfaz/Java que requiere validación de vigencia funcional.

## 5. Dependencias, identidad, seguridad e integraciones

### Runtime y librerías

`legacy/ES_VIDA_372VENCIMIENTOSMANUALES/pda-import.properties` identifica el proyecto `ES_VIDA_372VENCIMIENTOSMANUALES`, aplicación Java `WSS372VENCIMIENTOSMANUALES`, versión `043.010.00.00-SNAPSHOT`, gestor Plastic, clase de carga `PARENT_FIRST` y `app.ext.fileserving=true`. Declara las LIBS `MAPFRE_VIDA_CUSTOMTAGS-v2_0_6`, `MAPFRE_VIDA_struts-v1_2_7` y `MAPFRE_VIDA_COMUN-v2_30`.

`WSS/Web Content/WEB-INF/lib/` trae 12 JAR: `antlr.jar`, `arquitectura-web.jar`, `commons-beanutils.jar`, `commons-collections.jar`, `commons-digester.jar`, `commons-fileupload.jar`, `commons-lang-2.0.jar`, `commons-logging.jar`, `commons-validator.jar`, `jakarta-oro.jar`, `log4j-1.2.9.jar` y `struts.jar`. Es una aplicación web Struts 1 sobre Servlet API 2.3 (`WSS/Web Content/WEB-INF/web.xml`) y configuración WebSphere (`WEB-INF/ibm-web-bnd.xmi`, `ibm-web-ext.xmi`); el descriptor registra también `PrintServlet`.

### Identidad, autorización y exposición de datos

`web.xml` mapea `J000J000FiltroAcceso` a `*.jsp` y al servlet `MapfreActionServlet`, y configura `J000J000FiltroConfigWeb` para `/*`. Las Actions recuperan la identidad con `J000J000Usuario.getUsuarioArquitectura(request)` y los Beans la pasan al conector host; el header XML incluye el campo de usuario. El detalle de autenticación, perfiles/roles y autorización queda encapsulado en `MAPFRE_VIDA_COMUN`/filtros, cuyo código no forma parte del proyecto local; el código inspeccionado no permite afirmar cómo se resuelve cada permiso ni qué matriz de roles se aplica. Los ficheros funcionales sí registran 14 IDs, `10020`–`10033`, iguales en desa/tran/real (`Funcionalidades/.../IN372VENCIMIENTOSMANUALES.xml`).

Los formularios manejan NIF/CIF, datos personales/fiscales y de domicilio, cuentas y números de cheque, liquidaciones, importes y estados BDGI. La migración debe aplicar autorización por operación, protección de datos y trazabilidad server-side; no confiar en controles de JSP/JavaScript.

### Integraciones externas identificadas

- **Host/CICS:** `JAVA/servicios/*.java` usa el gestor MAPFRE de servicios y los XML de interfaz para invocar transacciones CICS COBOL. `WSS/Servicios/IN372VENCIMIENTOSMANUALES/IN372VENCIMIENTOSMANUALES.xml` y su paquete en `IMP/Recursos/Servicios/...` declaran el mapeo de programa y transacción.
- **DB2:** se accede desde módulos host, no desde JDBC local observado; ver `IMP/BD_DB2/` y SQL embebido en `IMP/App_ZOS/P02PROGR/`.
- **BDGI / prestaciones:** funcionalidad `bgdi.alta` (10030), JSP `peticionBDGIVen.jsp`, servicio VT06 y campos/flags BDGI del expediente (`WSS/Funcionalidades/...`, `JAVA/servicios/J372J008ServicioPeticionBDGIVenBean.java`).
- **FormsPath / SGDD / MAVISA:** recursos `.qfs` en `legacy/ES_VIDA_372VENCIMIENTOSMANUALES/2 - DES Desarrollo/3 - Programacion/Recursos/sgdd/FormsPath/MAVISA/` y copias de impresión en `WSS/FormulariosImpresion/`. `J372J015ImpresionDirectaAction` obtiene `printJob` de sesión; `J372J016ImpresionInformesDirecta` y `J372J017ImpresionEmisionDirecta` preparan etiquetas del documento `EMISIONFINIQUITOVENCIMIENTOS`, atendidas por `PrintServlet`/framework de impresión. La impresión no es solo un botón web: depende de plantillas y servicio de impresión corporativo.
- **Búsqueda de personas:** servicio VT11 para NIF/domicilio/datos fiscales; `GestionPersonaVen.js` abre el flujo auxiliar y carga la respuesta.
- **Ficheros y batch:** servicio VT07 y cadenas `X0323765`–`X0323767` para carga de expedientes/datos fiscales/complementarios; cadenas `X0323760`–`X0323762` para informes de retenciones (`IMP/APP_JCL/`).

### Secretos

La búsqueda estática en ficheros de texto por marcadores de contraseña, secreto, token y claves no encontró valores de credencial configurados. Una coincidencia textual de `Token` correspondía a `StringTokenizer` en `JAVA/actions/J372J002BusquedaExpVenDataProvider.java`, no a una credencial. No se reproducen valores sensibles.

## 6. Volumetría

Conteo recursivo de `legacy/ES_VIDA_372VENCIMIENTOSMANUALES/` (**332 ficheros**); líneas físicas, aproximadas, en los tipos indicados (no LOC ejecutables depuradas):

| Tipo | Ficheros | Líneas aproximadas |
|---|---:|---:|
| Java | 66 | 28.992 |
| JSP + JSPF | 16 (15 + 1) | 6.906 |
| JavaScript | 9 | 4.375 |
| XML | 59 | 5.528 |
| Properties | 4 | 466 |
| Texto `.txt` | 10 | 38 |
| Fuentes COBOL/copybooks sin extensión en `App_ZOS` | 98 (27 copybooks + 71 programas) | 82.833 |
| **Subtotal de tipos de texto anteriores** | — | **129.138** |

Distribución total por extensión: `.properties` 4, sin extensión 107, `.txt` 10, `.xml` 59, `.xls` 3, `.ps1` 1, `.sh` 1, `.war` 1, `.mf` 1, `.prefs` 4, `.component` 2, `.qdf` 6, `.qfs` 6, `.java` 66, `.js` 9, `.jsp` 15, `.tld` 7, `.xmi` 2, `.jspf` 1, `.jar` 12, `.zip` 10 y `.00` 5. El total de 107 ficheros sin extensión incluye los 98 miembros fuente de `App_ZOS`; el resto son otros archivos sin sufijo. Las líneas son conteos físicos de archivos del snapshot, incluyendo comentarios, espacios, descriptores y generaciones históricas.

## 7. Hallazgos para la migración

### Separación por responsabilidad

- **Presentación:** JSP/fragmentos, Struts tags, `ActionForm` y JavaScript bajo `WSS/Web Content/`; incluye estructura de navegación, controles, cálculos visuales y generación/selección de informes.
- **Orquestación:** Actions, helper/page beans y `JAVA/servicios/*Bean.java`; traducen formularios a parámetros XML, transportan identidad/contexto, procesan retornos y preparan la impresión. `J372J003ServicioCobol` es adaptador al gestor común MAPFRE, no contiene lógica del negocio host.
- **Dominio y persistencia host:** programas COBOL/CICS, copybooks `X372VT*`, rutinas de persistencia y reglas de negocio en `IMP/App_ZOS/`; DB2 y servicios host deben tratarse como contratos y comportamiento a caracterizar. Las cadenas JCL, DDL y plantillas FormsPath son dependencias del proceso operativo, no lógica reemplazable por una conversión mecánica de Java.

### Riesgos y puntos de caracterización

1. **Inventario de cartera incompleto en el código fuente:** hay Action/Form/forward de gestión de carteras en `struts-config.xml`, pero el Action y ambos JSP de destino no aparecen bajo WSS; los servicios VT03/VT05 tampoco tienen caller Java localizado ni fuentes host `B372VT03`/`B372VT05` en `P02PROGR`. Aclarar si se despliegan desde otro artefacto o si el snapshot está incompleto.
2. **Desalineación del servicio VT08:** el Java de búsqueda lo invoca; XML, interfaz/transacción 3708 y programa COBOL se encuentran en implantación, pero no en el catálogo de servicios de desarrollo enumerado. Sincronizar ambos paquetes antes de congelar el contrato.
3. **Duplicidad de `/modificarExpVen`:** resolver cuál declaración es la efectiva antes de reproducir la navegación.
4. **Deriva del esquema DB2:** `TB372VEN0` aparece con 87 columnas en un DDL histórico y 80 en otro, y el modelo de coaseguro pasa a `TB372CCV0`; hay además una tabla auxiliar `TB372MIG0`. Fijar release, claves, nullability y precisión desde el entorno desplegado antes de diseñar persistencia/migraciones.
5. **Reglas financieras sensibles:** fórmulas de bruto/neto/retención/líquido y distribución de coaseguro se reparten entre JS y host. Definir pruebas de caracterización con decimales, redondeo, datos parciales y hasta seis ocurrencias; no portar coma decimal ni `float` JavaScript como tipo de dominio.
6. **Identidad/perfiles opacos en código externo:** la aplicación delega control de acceso al filtro MAPFRE; faltan las fuentes de la librería común y la matriz de asignación de los IDs funcionales. Revalidar roles por operación y segregación de funciones en el destino.
7. **Integraciones operativas fuera del WAR:** impresión depende de FormsPath/SGDD, CICS y plantillas; carga e informes dependen de cadenas JCL/entornos host. La carpeta de pruebas de implantación solo tiene un README, por lo que no se dispone de evidencia de pruebas ni resultados.
8. **Privacidad:** datos fiscales/personales y de pago atraviesan pantalla, servicio, host, informes impresos y DB2; revisar logging, exportación, masking, retención y auditoría.
9. **Dependencias antiguas:** Struts 1, Commons Validator 1.x, Log4j 1.2.9 y APIs de Servlet/WebSphere requieren sustitución/control de vulnerabilidades y revisión de compatibilidad; la disponibilidad de bibliotecas compartidas MAPFRE forma parte del comportamiento.
10. **Sin credenciales textuales detectadas** en la búsqueda estática descrita en la sección anterior. El conteo no es análisis dinámico ni evaluación de seguridad.

## Fuentes principales citadas

- Struts, JSP y configuración web: `WSS/Web Content/WEB-INF/struts-config.xml`, `validator.xml`, `validator-rules.xml`, `web.xml`, `WSS/Web Content/jsp/`, `WSS/Web Content/js/`.
- Java: `JAVA/actions/`, `JAVA/forms/`, `JAVA/helperbeans/`, `JAVA/pagebeans/`, `JAVA/servicios/`, `JAVA/config/J372J001ConstantesVen.java`, `JAVA/resources/ApplicationResources.properties`.
- Integración y permisos funcionales: `WSS/Servicios/IN372VENCIMIENTOSMANUALES/`, `WSS/Funcionalidades/{desa,tran,real}/IN372VENCIMIENTOSMANUALES/`, `2 - DES Desarrollo/3 - Programacion/Recursos/Funcionalidades/` e `IMP/Recursos/{Servicios,Funcionalidades}/`.
- Mainframe, base de datos y operación: `IMP/App_ZOS/{P01COPYS,P02PROGR,RECATLG}/`, `IMP/BD_DB2/`, `IMP/APP_JCL/`, `IMP/Operativa Batch/`, `IMP/Pruebas Implantacion/`.
- Despliegue y librerías: `legacy/ES_VIDA_372VENCIMIENTOSMANUALES/pda-import.properties`, `WSS/Web Content/WEB-INF/lib/`, `IMP/Ficha de aplicacion.xls`, `IMP/SW_A372VEN.xls`, `IMP/SW_A372VENM.xls`.
