# 9. Plan de migración Appian → Angular Material + backend

Propuesta de cómo abordaría la migración completa de TVA. El backend es una **propuesta
inicial** pendiente de las indicaciones del equipo (se ajustará cuando se defina el
stack objetivo). Se apoya en el análisis de los documentos 01–08.

## 9.1 Qué se migra y qué no

| Componente Appian | Destino | Comentario |
|---|---|---|
| 96 interfaces SAIL | Angular 19 + Angular Material | Reagrupadas en ~35 componentes (ver 9.3) |
| 172 reglas de expresión | TypeScript (front) o Java (back) según naturaleza | Validaciones/factorías de request → back; formateo/visibilidad → front |
| 28 modelos de proceso | Casos de uso del backend (servicios de aplicación) | Son procesos cortos y síncronos: no requieren motor BPM |
| 20 integraciones + 3 sistemas conectados HTTP | Clientes HTTP del backend (API Life, SBC, MISV, RIC/Personas) | Mismo contrato `/api/life/1.0/…` |
| Data store `TVA_ENT_TRAZA` (sesión JSON) | Tabla `tva_sesion` + `tva_traza` en PostgreSQL (JSONB) | Mismo esquema RDS si se desea |
| 2 Web APIs de inicio | 2 endpoints REST `POST /inicio/ahorro`, `POST /inicio/rentas` | Invocados por los portales GV/PFM |
| Sites, grupos, seguridad | SPA + SSO corporativo (OIDC/SAML) + roles en JWT | Grupos `TVA Usuarios/Administradores portal/Debug` → roles |
| Batch Apertura-Cierre, Borrar traza | `@Scheduled` / cron Kubernetes | — |
| `TVA IPs` (alertas email) | Servicio de notificaciones | — |
| Pantalla de administración (constantes en caliente, cachés) | Módulo `/admin` Angular + tabla `tva_parametro` | Sustituye a `MU_PM_ACTUALIZAR_CONSTANTES` |
| Dependencias MU / VIDA / CMP / TI | **Reimplementar** solo lo que TVA usa (≈150 objetos, mayoría componentes de formulario y constantes) | Componentes `MU_*Field` → Material; `VIDA_ObtenerConfiguracionProductoComercial` → endpoint del backend |
| 49 reglas `TVA_MOCK_*`, `TVA_prueba*`, duplicados `V1/V2/_DUP` | **No se migran** | Los mocks pasan a fixtures de test |

## 9.2 Arquitectura objetivo

```
Portal GV / PFM ──POST /api/tva/inicio/*──▶ ┌────────────────────────────┐
                                             │  tva-backend (Spring Boot) │
Navegador ──▶ tva-frontend (Angular) ──REST─▶│  api · application · domain│──▶ API Life / SBC / MISV / RIC
              Angular Material, Signals      │  infrastructure (clients,  │──▶ PostgreSQL (sesión, traza, parámetros)
                                             │  persistence, security)    │──▶ SMTP (alertas)
                                             └────────────────────────────┘
                     ▲                                     ▲
                     └──────────── SSO OIDC (Entra ID) ────┘
```

Principios:
- **El estado deja de ser un JSON opaco**: `TVA_Sesion` se modela como agregado `Sesion`
  con versión de esquema; el front mantiene una copia reactiva (signals/NgRx Signal Store)
  y el back es la fuente de verdad (resuelve A2/A3/M10 de 07-mejoras).
- **El backend orquesta**, como hoy hacen los modelos de proceso: cada botón de Appian
  (`TVA Guardar y volver`, `TVA R2C Precios-Recalcular`…) pasa a ser un caso de uso
  `POST /sesiones/{id}/acciones/{accion}` que devuelve la sesión actualizada y la
  siguiente pantalla (`idPantallaActual` → `pantallaActual` como enum).
- **El front no habla con API Life**: solo con `tva-backend`. Así las credenciales
  Basic Auth y la lógica por entorno viven en un único sitio.

## 9.3 Frontend — Angular 19 + Angular Material

### Stack
Angular 19 (standalone components, signals), Angular Material 19 + CDK, Reactive Forms,
`@angular/localize` o Transloco para literales, Angular Router con guards por rol,
Vitest/Jest + Testing Library, Playwright para e2e, ESLint + Prettier, Nx opcional si se
prevé más de un front (p. ej. simulador de rentas independiente).

### Estructura de módulos (mapeo desde Appian)

| Ruta / feature | Interfaces Appian de origen | Material principal |
|---|---|---|
| `shell/` (layout, cabecera, avisos, botonera) | `TVA_Principal`, `TVA_Cabecera`, `TVA_MostrarAvisos`, `TVA_Botonera` | `mat-toolbar`, `mat-stepper` (horizontal, para las pantallas del wizard), `MatSnackBar`/`mat-card` para avisos |
| `productos/` | `TVA_Pantalla_SeleccionProductoAhorro`, `TVA_Pantalla_SegurosAhorro`, `TVA_SeccionProductoAhorro*`, `TVA_SeccionOpcionesInversion*` | `mat-card`, `mat-radio-group`, `mat-table` |
| `solicitud/` | `TVA_Pantalla_CapturaDatosSolicitud`, `TVA_SeccionDatosDeLaOperacion*` (unificadas VA/VIA), `TVA_SeccionAsegurado`, `TVA_SeccionAportante`, `TVA_SeccionBeneficiarios*`, `TVA_SeccionCuentaBancaria`, `TVA_SeccionFormaPago` | `mat-form-field`, `mat-select`, `mat-datepicker`, `mat-expansion-panel` |
| `tomador/` | `TVA_Pantalla_CapturaTomador`, `TVA_CapturaTomador_Panel*`, `TVA_DatosParticipanteV1/V2` (**una sola** implementación), `TVA_DomicilioV1/V2`, `TVA_SeccionMediosContacto`, `TVA_SeccionDocumentoIdentificativo` | `mat-form-field`, `mat-autocomplete` (búsqueda RIC/Vida), `mat-chip` |
| `rentas/` (R2C) | `TVA_Pantalla_R2C_*`, `TVA_R2C_Seccion*` | `mat-table`, `mat-slider`, `mat-button-toggle` |
| `resumen/` | `TVA_Pantalla_ResumenContratacion`, `TVA_SeccionResumen*`, `TVA_SeccionDocumentacionPrecontractual`, `TVA_SeccionSeleccionTipoFirma`, `TVA_SeccionFirma*`, `TVA_SeccionCargaPoliza`, `TVA_Pantalla_ResultadoFirma` | `mat-list`, `mat-checkbox`, `mat-progress-bar`, descarga de PDF |
| `dialogos/` | `TVA_PopUp_*` (Intervinientes, Cesión derechos, RGPD, Digitalización DNI, Test conveniencia, Firmar) | `MatDialog` (elimina la necesidad del record `TVA Dummy`) |
| `admin/` | `TVA_Pantalla_Administracion`, `TVA_Admin_*`, `TVA_Utilidades*`, `TVA_LogAplicacion` | `mat-tab-group`, `mat-table`, `mat-slide-toggle` |
| `shared/ui` | Equivalentes de `MU_TextField`, `MU_Dropdown`, `MU_DateField`, `MU_Aviso`, `CMP_formatearNumero`, `CMP_validacionDNI` | Componentes wrapper + `Validators` propios (NIF/NIE/CIF, IBAN, teléfono, email) |

### Estado y navegación
- `SesionStore` (Signal Store): `sesion`, `pantallaActual`, `avisos`, `taller`
  (configuración del producto comercial, hoy `VIDA_ObtenerConfiguracionProductoComercial`).
- Router: `/s/:claveSesion/(productos|solicitud|tomador/:n|rentas|resumen|firma|fin)`;
  un `CanActivate` comprueba que la pantalla pedida coincide con la que autoriza el back
  (evita saltos en el wizard).
- Componentes de formulario controlados por metadatos: hoy la visibilidad/obligatoriedad
  depende del `taller` y de las funcionalidades activables (`TVA_ObtenerFuncionalidades`);
  se modela como `FormConfig` que el back devuelve junto a la sesión.

### Reglas de expresión que pasan al front (TypeScript puro, testeables)
Formateo (`TVA_Formatear*`), visibilidad/habilitación de secciones, cálculo de textos de
aviso, comparación de discrepancias RIC/Vida (`TVA_Discrepancias*`), utilidades de fechas.
Las **validaciones de negocio** (`TVA_*_Validacion`, `TVA_Validacion*`) se implementan en
el back y se replican solo las triviales (formato) en el front.

## 9.4 Backend — propuesta

> Propuesta a la espera de la definición del equipo; se elige lo más cercano a lo que ya
> existe en este repositorio (Spring Boot, Gradle, Flyway) para poder prototipar aquí.

### Stack propuesto
Java 21 + Spring Boot 3.4 (Web, Validation, Security OAuth2 Resource Server, Data JPA o
MyBatis, WebClient/RestClient), PostgreSQL 16 (JSONB para la sesión), Flyway, MapStruct,
springdoc-openapi (contrato consumido por el front con `openapi-generator` para generar
los clientes TypeScript), Testcontainers + WireMock (stubs de API Life a partir de los
mocks `TVA_MOCK_*`), Resilience4j (timeouts/reintentos por integración, hoy 10–120 s).

Alternativas equivalentes si el equipo lo prefiere: NestJS (TypeScript end-to-end, mismo
lenguaje que el front) o .NET 8. La estructura de casos de uso descrita abajo es la misma.

### Estructura (misma convención DDD/CQRS que este repo)

```
io.mapfre.tva
├── api/            controllers REST + DTOs (OpenAPI)
│   ├── InicioController        POST /inicio/ahorro · POST /inicio/rentas   (portales)
│   ├── SesionController        GET /sesiones/{id} · POST /sesiones/{id}/acciones/{accion}
│   ├── ClientesController      GET /clientes?documento=  (RIC + Vida + discrepancias)
│   ├── DocumentosController    GET /sesiones/{id}/documentos/{tipo} (precontractual, póliza)
│   └── AdminController         parámetros, apertura/cierre, cachés, log
├── application/    casos de uso = 1 por modelo de proceso Appian
│   ├── IniciarSesionAhorro     (TVA Inicio Ahorro)
│   ├── SeleccionarModalidad    (TVA modalidadProductosAhorro / propuestaProductosAhorro)
│   ├── GuardarSolicitud        (TVA Guardar y volver)
│   ├── ContinuarTomador        (TVA CapturaTomador1/2-Continuar)
│   ├── RecalcularRentas / ContratarRentas (TVA R2C Precios-*)
│   ├── Firmar / EnviarFirmaManuscrita
│   ├── ValidarReinversion, VerificarProductores, ImporteMaximo, PerfilCliente
│   └── AperturaCierreJob, BorrarTrazasJob  (@Scheduled)
├── core/           dominio: Sesion, Tomador, Participante, Beneficiario, Producto,
│                   OpcionInversion, Propuesta, Documento, Firma; reglas de validación
│                   (`TVA_*_Validacion`) y máquina de estados de pantallas
└── infrastructure/
    ├── apilife/    clientes de los 16 endpoints `TVA_API_Life_*` + SBC máximo
    ├── misv/       perfilado de clientes
    ├── ric/        personas / RIC (hoy MU_ObtenerClienteRIC, TVA_GestionarPersonas)
    ├── persistence/ sesion (JSONB versionado), traza, parametro
    └── security/   OIDC resource server, mapeo grupos → roles, API key para portales
```

### Modelo de datos
- `tva_sesion(id, clave_sesion, usuario, version_esquema, pantalla_actual, estado jsonb, creado, actualizado)`
- `tva_traza(id, clave_sesion, ubicacion, clase, tipo_contenido, contenido jsonb, fecha)` — equivalente a `TVA_ENT_TRAZA` sin mezclar sesión y log.
- `tva_parametro(clave, valor, entorno, actualizado_por)` — sustituye las ~200 constantes editables y `TVA_FECHA_*` de apertura/cierre.

### Seguridad
- Usuarios: SSO corporativo (OIDC) → JWT con roles `TVA_USUARIO`, `TVA_ADMIN_PORTAL`,
  `TVA_DEBUG`. La sesión se vincula al `sub` del token: solo su dueño (o admin) la recupera.
- Portales GV/PFM: `client_credentials` o API key por portal (hoy grupo `TVA WebApi Inicio`).
- Credenciales de API Life/MISV/BD en Vault/Secrets del cluster; nunca en código
  (elimina `TVA_Conectar_ContrasennaUsuarioVida`).

## 9.5 Fases

| Fase | Contenido | Entregable |
|---|---|---|
| 0. Preparación | Contrato OpenAPI del backend a partir de los CDT `VIDA_API_Life_*` y `TVA_Sesion`; catálogo de pantallas y transiciones (`TVA_*_siguientePantalla`); extracción de los ~200 valores de constantes a `tva_parametro`; fixtures WireMock desde `TVA_MOCK_*` | `openapi.yaml`, tabla de transiciones, fixtures |
| 1. Esqueleto | Monorepo `tva-frontend` + `tva-backend`, CI, SSO, shell Angular con stepper y avisos, `SesionStore`, endpoints de inicio y `GET /sesiones/{id}` | Login + pantalla vacía navegable con sesión real |
| 2. Flujo VIA (venta informada) | Selección producto → captura solicitud → tomador → resumen → firma. Es el flujo más lineal | Primer flujo contratable en DEV contra API Life PRE |
| 3. Flujo VA | Propuesta multi-producto, perfil de cliente, test idoneidad/conveniencia, notas individuales | — |
| 4. Rentas R2C | Captura, precios, recálculo, contratación | — |
| 5. Transversales | Diálogos (RGPD, cesión, DNI), documentación precontractual, firma manuscrita, descarga póliza | — |
| 6. Administración y batch | Admin, parámetros, apertura/cierre, borrado trazas, alertas | Paridad funcional |
| 7. Convivencia y corte | Feature flag en portales GV/PFM para enrutar a Appian o Angular por usuario/canal; migración de sesiones abiertas no necesaria (son de corta vida); retirada de la app Appian | Go-live |

Estimación de esfuerzo propio: fases 0–2 ≈ 2–3 sesiones de trabajo; 3–6 ≈ 4–6 sesiones;
la fase 7 depende de coordinación con portales y entornos. El coste real lo marcan los
accesos a API Life/MISV y la definición del backend.

## 9.6 Riesgos específicos

- **Lógica oculta en SAIL**: ~1.500 líneas en `TVA_DatosParticipanteV2` y equivalentes;
  la migración debe partir del catálogo de reglas de 03-inventario, no de la UI visible.
- **Contrato de API Life no documentado en Appian**: se infiere de los CDT; hace falta el
  Swagger/WSDL real (`TVA_WSDL_IGestionarPerfilUsuario` es SOAP).
- **Dependencias MU/VIDA/CMP**: hay que decidir si se reimplementan o si se expone un
  servicio común para todas las aplicaciones Vida que migren.
- **Firma electrónica**: el flujo `TVA PopUp Firmar` / `TVA_Pantalla_ResultadoFirma`
  depende de un proveedor externo con retorno por URL; requiere pruebas en entorno real.

## 9.7 Qué necesitas tener instalado (equipo local)

| Herramienta | Versión | Para |
|---|---|---|
| Node.js (LTS) | 22.x | Angular CLI, build del front |
| npm o pnpm | 10.x / 9.x | dependencias |
| Angular CLI | `npm i -g @angular/cli@19` | `ng new`, `ng generate`, `ng serve` |
| JDK | 21 (Temurin) | backend Spring Boot |
| Gradle | wrapper incluido en el repo | build/test |
| Docker Desktop | actual | PostgreSQL 16, WireMock (stubs API Life), Testcontainers |
| Git | actual | — |
| IDE | VS Code (Angular Language Service, ESLint, Prettier) + IntelliJ IDEA CE o VS Code con Extension Pack for Java | — |
| Opcional | Playwright (`npx playwright install`), Postman/Bruno, DBeaver | e2e, pruebas de API, BD |

Acceso de red necesario para probar contra sistemas reales: API Life PRE, MISV PRE y RDS DEV
(o, mientras no haya acceso, WireMock con los fixtures derivados de los mocks Appian).

## 9.8 Qué puedo hacer yo en mi máquina

Mi entorno ya tiene Node 24, npm 10, JDK 17, Docker y Gradle (por el wrapper del repo).
Puedo instalar Angular CLI 19 y JDK 21 y construir el prototipo completo aquí:

1. Crear `tva-frontend` (Angular 19 + Material) y `tva-backend` (Spring Boot 3.4) en esta
   rama o en repos nuevos, con Docker Compose (PostgreSQL + WireMock).
2. Generar los stubs de API Life a partir de los `TVA_MOCK_*` del volcado, de forma que el
   flujo VIA completo funcione **sin acceso a Mapfre**.
3. Levantar front + back, grabar una demo del flujo y publicar PRs por fase.

Lo que **no** puedo hacer sin que me lo proporcionéis: acceso de red a API Life/MISV/RDS
(hoy no alcanzables desde mi máquina), credenciales de los usuarios técnicos y el
Swagger/WSDL real de API Life. Con eso, sustituiría WireMock por los servicios reales.

Siguiente paso propuesto: confirmar el stack de backend (o mantener Spring Boot como en
este repo) y empezar por la fase 0 + 1.
