# Lanzaderas y accesos directos por página (extraído de SAIL)

## PGM_NuevaProduccion_TarjetasProductos

- **Icono agropecuario / Agropecuario** → (proceso/enlace interno)
- **Icono empresas / Empresas** → (proceso/enlace interno)
- **Icono vida / Vida** → (proceso/enlace interno)
- **Icono vida / Ahorro** → (proceso/enlace interno)
- **Icono patrimoniales / Patrimoniales** → (proceso/enlace interno)
- **Icono automóviles / Automóviles** → (proceso/enlace interno)
- **Icono salud / Salud** → (proceso/enlace interno)
- **Icono contratación / SAC** → PGM_DOMINIO_PORTALINTERNO="https://wportalinterno.pre.mapfre.net"
- **Icono contratación / Presupuestos** → PGM_ENDPOINT_RUP · showWhen: `2=3,*/`

## PGM_GestionDeCartera_TarjetasProductos

- **Icono agropecuario / Agropecuario** → (proceso/enlace interno)
- **Icono patrimoniales / Patrimoniales** → (proceso/enlace interno)
- **Icono automóviles / Automóviles** → (proceso/enlace interno)
- **Icono salud / Salud** → (proceso/enlace interno)
- **Icono empresas / Empresas** → (proceso/enlace interno)
- **Icono vida / Vida** → (proceso/enlace interno)
- **Icono contratación / SAC** → PGM_DOMINIO_PORTALINTERNO="https://wportalinterno.pre.mapfre.net"

## PGM_PrestacionesYSiniestros_TarjetasProductos

- **Icono agropecuario / Agropecuario** → (proceso/enlace interno)
- **Icono patrimoniales / Patrimoniales** → (proceso/enlace interno)
- **Icono automóviles / Automóviles** → (proceso/enlace interno) · grupos: PGM_GRUPO_DIRECTORCOMERCIAL, PGM_GRUPO_USUARIOCENTRAL
- **Icono salud / Salud** → (proceso/enlace interno)
- **Icono empresas / Empresas** → (proceso/enlace interno)
- **Icono vida / Vida** → (proceso/enlace interno)

## PGM_GestionComercial_TarjetasProductos

- **Icono contratación / Sistema de gestión comercial 2.0** → PGM_DOMINIO_PORTALINTERNO_SGC20="https://wportalinterno.pre.mapfre.net"
- **Icono contratación / Asesor 360** → PGM_DOMINIO_PORTALINTERNO="https://wportalinterno.pre.mapfre.net"
- **Icono contratación / Sistema de gestión comercial 3.0** → PGM_ENDPOINT_SGC30="https://sgc.es.pre.azure.mapfre.com"
- **Icono contratación / WhatsApp para Oficinas** → PGM_ENDPOINT_WHATSAPP="https://conversa-dev.mapfre.es" · grupos: PGM_GRUPO_APS, PGM_GRUPO_ASESORCLIENTES, PGM_GRUPO_ASESORCOMERCIAL, PGM_GRUPO_DIRECTORCOMERCIAL, PGM_GRUPO_GESTORDELEGADO, PGM_GRUPO_USUARIOCENTRAL, PGM_GRUPO_USUARIOTTT
- **Icono contratación / Liquidación de comisiones** → PGM_DOMINIO_PORTALINTERNO="https://wportalinterno.pre.mapfre.net"

## PGM_Utilidades_TarjetasProductos

- **Icono contratación / Sistema de Gestión de Operaciones** → PGM_ENDPOINT_APPIAN="https://mapfrespain-test.appiancloud.com"
- **Icono contratación / Otros accesos** → PGM_DOMINIO_PORTALINTERNO="https://wportalinterno.pre.mapfre.net"; PGM_ENDPOINT_APM_NUEVO="https://internos.pre.mapfre.com/aps/"; PGM_ENDPOINT_DELEGADOS="http://delegadosmapfre.pre.mapfre.net/"; PGM_ENDPOINT_INFORMACION_INTERES_IDD="https://www.mapfre.es/informacion-de-interes/"; PGM_ENDPOINT_Portal_Incentivos="https://incentivosmapfre.es/home"; PGM_ENDPOINT_VIRTUALAPPS="https://virtualapps.mapfre.net" · grupos: PGM_GRUPO_APS, PGM_GRUPO_ASESORCLIENTES, PGM_GRUPO_DIRECTORCOMERCIAL, PGM_GRUPO_GESTORDELEGADO, PGM_GRUPO_USUARIOTTT · showWhen: `not(`

## PGM_Recibos_TarjetasProductos

- **Icono contratación / No vida** → PGM_DOMINIO_PORTALINTERNO="https://wportalinterno.pre.mapfre.net"

