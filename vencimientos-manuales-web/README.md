# Vencimientos manuales Vida 372

SPA Angular 19 standalone sobre Nx. Consume el BFF mediante `environment.bffUrl`; no implementa cálculos de negocio en el navegador. El botón **Calcular** invoca `POST /api/v1/calculos/liquidacion`.

## Arranque local

Requisitos: Node.js compatible con Angular 19 y pnpm.

```bash
pnpm install
pnpm nx serve vencimientos-manuales-web --configuration=local
```

La SPA escucha en `http://localhost:4200` y consume el BFF en `http://localhost:8080`. La autenticación está desactivada exclusivamente en el entorno local para trabajar con el perfil explícito `local` del BFF. Arranque del BFF desde `../vencimientos-manuales-bff/sources`:

```bash
SPRING_PROFILES_ACTIVE=local ./mvnw spring-boot:run
```

En los entornos no locales se activa OIDC de Entra ID. `tenantId`, `clientId` y `scopes` se configuran en `src/environments/environment.ts`; los valores se mantienen vacíos en el repositorio. `bffUrl` también es configurable por entorno.

## Pantallas y correspondencia con el legacy

| JSP / funcionalidad legacy                              | Ruta SPA                                             | Endpoint BFF                                               |
| ------------------------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------------- |
| `buscarExpedientesVen.jsp` / búsqueda y listado         | `/expedientes`                                       | `GET /api/v1/expedientes`                                  |
| `altaExpedienteVen.jsp`, `modificarExpVen.jsp`, detalle | `/expedientes/nuevo`, `/expedientes/{anio}/{numero}` | `POST`, `GET`, `PUT /api/v1/expedientes...`                |
| Anulación de expediente                                 | gestión del expediente                               | `POST /api/v1/expedientes/{anio}/{numero}/anulacion`       |
| Variables del expediente                                | `/variables`                                         | `GET`, `PUT /api/v1/expedientes/{anio}/{numero}/variables` |
| Emisión de finiquitos                                   | `/finiquitos`                                        | `POST /api/v1/finiquitos/emisiones`                        |
| Impresión de informes                                   | `/informes`                                          | `POST /api/v1/informes`                                    |
| Petición BDGI                                           | `/bdgi`                                              | `POST /api/v1/peticiones-bdgi`                             |
| Reaseguro                                               | `/reaseguro`                                         | `POST /api/v1/expedientes/{anio}/{numero}/reaseguro`       |
| Consulta de cartera de póliza                           | `/cartera-poliza`                                    | `GET /api/v1/polizas/{ramo}/{anio}/{numero}/cartera`       |
| Consulta de carteras (provisional)                      | `/carteras`                                          | `GET /api/v1/carteras/listado?page=0&size=20`              |
| Carga de fichero                                        | `/carga-fichero`                                     | `POST /api/v1/cargas-fichero`                              |
| Cálculo y reparto de liquidación                        | gestión del expediente                               | `POST /api/v1/calculos/liquidacion`                        |

La búsqueda permite criterios por expediente, póliza o NIF y listado paginado. La búsqueda de persona por NIF es un componente reutilizable. El cuadro de coaseguro presenta hasta seis filas; las validaciones definitivas y los cálculos son responsabilidad del BFF.

El esquema actual de `POST /api/v1/cargas-fichero` solo recibe `tipoEmision`; no define el transporte del contenido binario seleccionado en el legacy. La pantalla solicita la operación con ese esquema y muestra este límite hasta que se acuerde el contrato de carga.

## Comprobaciones

```bash
pnpm nx lint vencimientos-manuales-web
pnpm nx test vencimientos-manuales-web
pnpm nx build vencimientos-manuales-web
pnpm exec prettier --check .
pnpm exec nx graph --file=project-graph.html
```

Para ejecutar con nginx, construir la SPA y ejecutar `docker build -t vencimientos-manuales-web .`.
