# 15. Guía de pruebas end-to-end — TVA (Angular + Django)

Recorrido manual para comprobar que la instalación local funciona, con los datos exactos
a introducir y qué verificar en cada pantalla. Aplica a la pila arrancada según
[11-guia-despliegue.md](11-guia-despliegue.md), con los conectores en modo `mock`
(valor por defecto). Al final se indica qué cambia en modo `real`.

Convención: **[Introducir]** = datos a teclear · **[Verificar]** = lo que debe verse.

## 0. Verificación previa (5 min)

| Paso | Comando / URL | [Verificar] |
|---|---|---|
| Backend vivo | `curl http://localhost:8888/api/tva/v1/salud/` | `{"status":"ok", …, "integraciones":{"apilife":"mock","misv":"mock","perfilUsuario":"mock","ric":"mock","appianEmbed":"mock"}}` |
| Configuración | `poetry run python manage.py check` (en `tva-backend/sources`) | `System check identified no issues` |
| Conectores | `poetry run python manage.py smoke_integraciones` | 5 líneas `OK` y código de salida 0 |
| Swagger | http://localhost:8888/docs/swagger/ | Se listan `sesiones`, `acciones`, `catalogos`, `admin`, `popups`… |
| Frontend | http://localhost:4200 (o :8080 con Docker) | Redirige a `/login`. La primera vez `ngx-multienvironment` muestra un selector de entorno: elegir **dev** (apunta a `localhost:8888`) |

## 1. Login

```bash
cd tva-backend/sources
poetry run python manage.py crear_token_local --usuario operador1 --roles TVA_USUARIO,TVA_ADMIN_PORTAL
```

- **[Introducir]** pegar el token en `/login` y pulsar *Entrar*.
- **[Verificar]** se abre la pantalla **«Utilidades — Inicio TVA»** con cabecera roja MAPFRE
  y el campo *Username* precargado con `operador1@mapfre.net` (el NUUMA `OPERADOR1` se
  calcula solo, deshabilitado).
- Prueba negativa: un token con solo `TVA_USUARIO` no debe mostrar el botón
  *Administración* dentro de la sesión y `/admin` debe redirigir al inicio.

## 2. Pantalla de inicio: validaciones del contrato Appian

Esta pantalla sustituye a la Web API `TVA_WebApi_Inicio` de Appian; los textos de error
son los literales de Appian.

| # | [Introducir] | [Verificar] |
|---|---|---|
| 2.1 | Username `operador1@gmail.com` → *INICIAR TVA* | Error `El nombre de usuario debe acabar en @mapfre.net` |
| 2.2 | CompanyId `9999` | `Valor de companyId no permitido` |
| 2.3 | Modo `VA`, ProposalId vacío | `El campo proposalId no puede ser nulo si indFunctionMode es VA` |
| 2.4 | Modo `VA`, ProposalId `P-1`, sin filas de inversión | `En Venta Asesorada es obligatorio informar al menos un seguro de ahorro` |
| 2.5 | Modo `VA`, una fila de inversión con aportación única y periódica vacías | `investment[1]- Los dos importes no pueden ser nulos a la vez` |
| 2.6 | Username `sinproductos@mapfre.net`, modo `VIA` | Se crea la sesión pero la pantalla de selección de producto muestra el aviso de «sin productos» (no hay tarjetas) |

Valores por defecto correctos para el resto de pruebas: CompanyId `0511`,
Distribution channel `500`, Número de tomadores `1`.

## 3. Flujo VIA (Venta Informada) — el recorrido principal

Orden real de pantallas en VIA: **Selección producto → Tomador 1 → Datos solicitud → Resumen
→ Resultado de la firma → Fin** (el tomador va antes que la solicitud; en VA es al revés).

### 3.1 Inicio
- **[Introducir]** Modo `VIA`, Username `operador1@mapfre.net`, casillas *Tomador* ✔,
  *Perfilado* ✔, *Inversión* ✔ → *INICIAR TVA*.
- **[Verificar]** URL `/sesion/<clave>`, miga de pan **Selección producto**; rejilla
  de 21 tarjetas `código - descripción` (p. ej. `00427 - PIAS ELECCION`,
  `00447 - DIVIDENDO VIDA II`, `00534 - MILLÓN VIDA`), cada una con el enlace *Contratación*.
  Botones: *Cancelar* y, con rol admin, *Administración*.

### 3.2 Selección de producto
- **[Introducir]** pulsar *Contratación* en `00427 - PIAS ELECCION` (producto Unit Linked:
  admite periodicidades M/T/S/A y opciones de inversión).
- **[Verificar]** pasa a **Tomador 1** (la pantalla *Modalidad campaña* solo aparece si el
  producto trae modalidad de campaña; ninguno del mock la trae).

### 3.3 Tomador 1
Secciones: **Datos personales**, **Domicilio habitual**, **Medios de contacto** y la caja de
**Requisitos** (RGPD, digitalización DNI, test de conveniencia). Cada sección tiene su propio
*Continuar* y **solo valida sus propios campos** (los errores de Medios de contacto no aparecen
al validar Datos personales); el *Continuar* inferior queda deshabilitado hasta que todas sean
válidas.

| # | [Introducir] | [Verificar] |
|---|---|---|
| 3.3.1 | *Continuar* de Datos personales con la sección vacía | `El documento identificativo no puede ser nulo`, `El nombre es obligatorio`, `La fecha de nacimiento es obligatoria`, `El sexo es obligatorio`, `Los campos Actividad, Sector y Profesión son obligatorios`. **No** aparecen `El móvil es obligatorio` ni `El correo electrónico es obligatorio` |
| 3.3.2 | Documento `12345678Z`, Nombre `PRUEBA`, Apellidos `TVA` `UNO`, Fecha nacimiento `1980-05-10`, Sexo, Nacionalidad `España`, Actividad/Sector/Profesión cualquiera → *Continuar* | Sección válida (icono verde). En mock **no se precarga nada** al teclear el documento |
| 3.3.3 | Domicilio: Tipo de vía `Calle`, Nombre `Mayor`, Número `1`, CP `28001`, Provincia `Madrid`, Localidad `Madrid`, País `España` → *Continuar* | Válida |
| 3.3.4 | Contacto: *Continuar* vacío | `El móvil es obligatorio`, `El correo electrónico es obligatorio` (con móvil sin prefijo: `El campo Prefijo es obligatorio`) |
| 3.3.5 | Prefijo `+34`, Móvil `600000000`, Email `prueba@example.com` → *Continuar* | Válida |
| 3.3.6 | Requisito **RGPD** → *Realizar* | Diálogo «Consentimiento RGPD» con el texto «Appian en modo simulado (stub local)» y botones **Simular completado** / **Cancelar** |
| 3.3.7 | *Cancelar* en el diálogo | El requisito sigue **pendiente** (no hay falso positivo) |
| 3.3.8 | *Realizar* → **Simular completado** | Requisito RGPD en verde |
| 3.3.9 | Repetir 3.3.8 con **Digitalización DNI** y **Test de conveniencia** | Los tres requisitos en verde |
| 3.3.10 | *Continuar* inferior | Miga de pan **Datos solicitud**; aviso INFO «El importe máximo anual … es de 7.500 €» |

Nota: el mock del test de conveniencia no tiene caso «KO» desde la interfaz; ese camino
está cubierto por tests automáticos y por el modo `real`.

### 3.4 Datos de la solicitud
Dos cajas plegables: **Datos de los productores** y **Datos del seguro** (secciones
*Operación*, *Opciones de inversión*, *Garantías*, *Domiciliaciones*). Botones: *Cancelar*,
*Administración*, *Doc. Precontractual* y *Contratar* (los dos últimos deshabilitados hasta
que todo es válido). No hay *Siguiente*: se avanza con *Contratar*.

| # | [Introducir] | [Verificar] |
|---|---|---|
| 3.4.1 | Productores → Productor `P0001`, Oficina `9275` → *Continuar* | Sección válida |
| 3.4.2 | Operación: *Prima única* y *Aportación periódica* vacías → *Continuar* | `Debe rellenar la prima única o la prima periódica`, `La fecha de efecto no puede ser nula`, `El tipo de duración no puede ser nulo` |
| 3.4.3 | Prima única `100` | `El importe de la prima debe estar entre 600 y 1000000` |
| 3.4.4 | Prima única vacía, Aportación periódica `1200`, sin periodicidad | `Debe seleccionar la periodicidad` (solo es obligatoria con aportación periódica) |
| 3.4.5 | Prima única `6000`, Fecha de efecto = hoy, Tipo de duración informado → *Continuar* | Sección válida |
| 3.4.6 | Opciones de inversión: `Fondtesoro` prima única `3000` + `Renta Fija` `3000` (suma = prima de la operación), Plazo objetivo informado → *Continuar* | Válida; sin plazo: `El plazo objetivo no puede ser nulo`; suma distinta de la prima: aviso |
| 3.4.7 | Garantías: *FC* aparece obligatoria; marcar/desmarcar *FA* → *Continuar* | Válida |
| 3.4.8 | Domiciliaciones: IBAN recibos `ES0000000000000000000000` | `IBAN inválido` |
| 3.4.9 | IBAN recibos `ES9121000418450200051332` → *Continuar* | Válida |
| 3.4.10 | Con alguna sección inválida, *Contratar* (si está habilitado) | `Los datos de productores y del seguro no son válidos` (y `Hay avisos de error pendientes` al repetir) |
| 3.4.11 | Todo válido, *Contratar* sin documentación | `Es necesario enviar la documentación precontractual antes de contratar` |
| 3.4.12 | *Doc. Precontractual* → diálogo «Documentación precontractual» («Se va a enviar un correo… ya no podrá modificar») → *Continuar* (*Volver* cancela) | Panel de documentos con `PRECONTRACTUAL · enviado` |
| 3.4.13 | *Cancelar* → diálogo `Va a cancelar el proceso de captura. ¿Está seguro?` → *Cancelar* | Se mantiene la pantalla (*Aceptar* cierra la sesión y vuelve al inicio) |
| 3.4.14 | *Contratar* | Miga de pan **Resumen** |

### 3.5 Resumen, firma y fin
- **[Verificar]** resumen estructurado: producto `00427 - PIAS ELECCION`, prima única
  `6.000 €`, tomador `PRUEBA TVA UNO` con los tres requisitos en verde, panel de documentos
  con la precontractual enviada. Selector de *Tipo de firma*.
- **[Introducir]** elegir un tipo de firma → *Firmar y contratar*.
- **[Verificar]** pantalla **Resultado de la firma** con la respuesta (JSON del mock de
  `policy documents`) → *Finalizar* → pantalla **Fin**: «Sesión finalizada… correctamente»
  y botón *Nueva sesión*, que vuelve al inicio.

## 4. Flujo VA (Venta Asesorada con propuesta y dos tomadores)

Como en Appian, el inicio VA llama a `GetProposal(proposalId)` y guarda la respuesta en
`responseProposal`; en mock la propuesta `PROP-0001` contiene **una** solicitud del producto
`00447 - Dividendo Vida II` con aportación única `12.000 €` (fixture `get_proposal.json`).
La navegación sigue `TVA_propuestaProductosAhorro_siguientePantalla`: con una sola solicitud
sin estado y tomadores **perfilados** se entra directamente en *Datos solicitud*; en el resto de
casos se pasa por *Seguros ahorro*.

### 4.1 Con Seguros ahorro (tomadores sin perfilar)
- **[Introducir]** en Inicio: Modo `VA`, ProposalId `PROP-0001`, Número de tomadores `2`,
  casilla *Perfilado* **desmarcada**, una fila en *Opciones de inversión*: Cód. modalidad
  `00447`, Tipo operación (cualquiera), Aportación única `12000`, Frecuencia `A` → *INICIAR TVA*.
- **[Verificar]** miga de pan **Seguros ahorro** con una tabla de una fila: Producto
  `00447 - Dividendo Vida II`, Aportación única `12.000,00 €`, Aportación periódica `0,00 €`,
  Estado vacío y botón *Captura datos* habilitado (el perfil mock incluye la funcionalidad
  `4045`, que permite capturar sin test de conveniencia vigente; sin ella el botón estaría
  deshabilitado hasta que todos los tomadores tengan test vigente).
- **[Introducir]** *Captura datos*.
- **[Verificar]** secuencia: **Datos solicitud** (prima única precargada `12000` desde la
  propuesta; botones *Cancelar*, *Administración* y *Guardar y volver* — en VA no hay
  *Doc. Precontractual* ni *Contratar*; rellenar productores y seguro como en 3.4 y avanzar con
  *Guardar y volver*, que guarda la propuesta y pasa a la siguiente pantalla)
  → **Tomador 1** → **Tomador 2** (repetir 3.3 con documento `87654321X`, Nombre `PRUEBA DOS`)
  → **Resumen** (dos tomadores listados) → **Resultado de la firma** → **Fin**.
- **[Verificar]** en Tomador 2 los requisitos son independientes de los del Tomador 1.

### 4.2 Directo a Datos solicitud (tomadores perfilados)
- **[Introducir]** igual que 4.1 pero con *Perfilado* **marcada**.
- **[Verificar]** la sesión se abre directamente en **Datos solicitud** con el producto `00447`
  ya seleccionado (no se muestra *Seguros ahorro*).

### 4.3 Negativa
- **[Introducir]** Modo `VA` sin ProposalId.
- **[Verificar]** `El campo proposalId no puede ser nulo si indFunctionMode es VA` (no se crea sesión).

## 5. Flujo R2C (Rentas)

El simulador de rentas de Appian (`TVA_SimuladorRentas_Captura_Validacion`, producto
`FUTURO VITALICIO DOS TOMADORES`) exige **siempre dos tomadores**; por eso en Inicio, al elegir
`R2C`, el *Número de tomadores* se fija en `2` y queda bloqueado.

### 5.1 Captura
- **[Introducir]** en Inicio: Modo `R2C`, Username `operador1@mapfre.net` → *INICIAR TVA*.
- **[Verificar]** miga de pan **Captura R2C**, caja *Datos de la renta* con dos tomadores.
- **[Introducir]** Importe total de la prima `50000`, Periodicidad de la renta `Anual`,
  Tomador 1: Nº de DNI `12345678Z`, Fecha de nacimiento `1960-01-15`, % de participación `60`;
  Tomador 2: Nº de DNI `87654321X`, Fecha de nacimiento `1962-03-20`, % de participación `40`
  → *Continuar* de la sección → *Siguiente*.
- Negativas: prima vacía → `El importe total de la prima es obligatorio`; DNI/fecha/% vacíos
  → `Tomador N: … es obligatorio`. Con errores, *Siguiente* no avanza y muestra los avisos.

### 5.2 Precios de rentas
*Siguiente* ejecuta `individualAnnuitySimulation` una vez por opción de capital decreciente
(50 % y 100 %), como el PM `TVA_R2C_Capt-Siguiente`.

| # | [Introducir] | [Verificar] |
|---|---|---|
| 5.2.1 | — | Dos tarjetas: `1.415,89 € /año` (prima `50.000,00 €`, rentabilidad `2.3%`, capital decreciente hasta el `50%`) y `1.058,17 € /año` (rentabilidad `2.41%`, hasta el `100%`). Botones *Atrás* y *Cancelar* habilitados; *Recalcular* y *Contratar* **deshabilitados** (sin opción seleccionada) |
| 5.2.2 | Seleccionar la opción del 50 % | Aparece la tarjeta **Capital decreciente** con el texto de la opción, `Renta Tomador 1: 849,53 €` / `Renta Tomador 2: 566,36 €` y el campo *Renta año* = `1415.89`. *Contratar* habilitado, *Recalcular* deshabilitado |
| 5.2.3 | Cambiar *Renta año* a `2000` (salir del campo) | *Recalcular* habilitado y *Contratar* deshabilitado (hay que recalcular) |
| 5.2.4 | *Recalcular* | Las dos tarjetas se recalculan para la renta objetivo: opción 50 % con prima `70.626,96 €` y renta `2.000,00 €`; *Contratar* vuelve a habilitarse |
| 5.2.5 | *Contratar* | Miga de pan **Resumen** con la renta: prima, renta objetivo, periodicidad, % de capital decreciente y los dos tomadores |
| 5.2.6 | Elegir tipo de firma → *Firmar y contratar* → *Finalizar* | **Resultado de la firma** → **Fin** |

## 6. Administración

Entrar por el botón *Administración* dentro de una sesión (vuelve con *Volver*) o por
http://localhost:4200/admin (requiere rol `TVA_ADMIN_PORTAL`).

| # | [Introducir] | [Verificar] |
|---|---|---|
| 6.1 | Bloque *Parámetros* | Lista de `TVA_*` (`TVA_APLICACION_CERRADA=0`, `TVA_FECHA_APERTURA`/`CIERRE` vacías, `TVA_FLAG_*`) con descripción |
| 6.2 | Editar `TVA_APLICACION_CERRADA` → `1` y guardar (o *Cerrar aplicación*). En otra pestaña iniciar una sesión VIA | El inicio muestra el cuadro «Se han encontrado ERRORES … **Aplicación cerrada por mantenimiento**» y no crea sesión |
| 6.3 | Volver a `0` (o *Abrir aplicación*) y repetir | El inicio vuelve a funcionar |
| 6.4 | *Ejecutar batch apertura/cierre* con fechas vacías | Resultado «abierta»; `TVA_APLICACION_CERRADA` permanece `0` |
| 6.5 | *Limpiar cachés* | Mensaje de éxito; la siguiente selección de producto vuelve a cargar el catálogo |
| 6.6 | *Trazas* → *Buscar* filtrando por la clave de la sesión anterior | Aparecen las trazas de inicio, acciones, pop-ups y firma; ninguna contiene tokens ni credenciales |

## 7. Pantallas de error que NO se pueden provocar con el mock

- **Sin perfil**: el mock de perfil de usuario siempre devuelve `conPerfil=true` con
  funcionalidades. Solo se ve con `PERFIL_USUARIO_MODE=real` o editando
  `fixtures/apilife/perfil_usuario.json` (`conPerfil:false`, `funcionalidades:[]`).
- **Solo avisos**: reservada a modalidades distintas de VA/VIA/R2C; no alcanzable desde la UI.
- Búsqueda de cliente «no encontrado», perfilado KO o reinversión inválida: RIC/MISV/API Life
  mock devuelven siempre el mismo cliente (`perfilClientesOK=true`, `importeMaximo=240000`,
  reinversión `TOTAL` válida) sea cual sea el documento.

## 8. Qué cambia en modo `real`

- Pop-ups (`APPIAN_EMBED_MODE=real` + API key): el diálogo embebe la tarea real de Appian
  TEST (`cmp-firma-rgpd`, `cmp-captura-dni`, `testIdoneidad`); el requisito solo se marca
  cuando `cmp-respuesta-componente` devuelve `enviado` / `digitalizacion` / test válido.
  Captura DNI exige que el origen esté en la lista blanca del componente (red MAPFRE).
- API Life / MISV / SOA / RIC en `real`: catálogo, cliente, perfilado, máximo SBC y
  perfil de usuario dejan de ser fijos; repetir §2–§5 con un NIF y un productor reales de
  DEV/PRE. Antes, `manage.py smoke_integraciones --nif <nif> --usuario <nuuma>` debe dar OK.
- La firma sigue **simulada** en ambos modos (gap pendiente, ver
  [12-gap-analysis-appian-angular.md](12-gap-analysis-appian-angular.md) §12.6).

## 9. Hoja de resultados

| Bloque | OK / KO | Observaciones |
|---|---|---|
| 0 Verificación previa | | |
| 1 Login y roles | | |
| 2 Validaciones de inicio | | |
| 3 Flujo VIA completo | | |
| 4 Flujo VA dos tomadores | | |
| 5 Flujo R2C | | |
| 6 Administración | | |
