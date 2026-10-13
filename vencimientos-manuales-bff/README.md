# vencimientos-manuales-bff

BFF REST para la migración gradual de `ES_VIDA_372VENCIMIENTOSMANUALES`. No mantiene base de datos propia. El perfil `local` utiliza adaptadores en memoria y no realiza llamadas a CICS, CTG, BDGI ni al sistema de impresión.

## Requisitos y arranque local

- Java 17.
- Maven Wrapper incluido; la primera ejecución descarga Maven 3.9.9 en la caché del usuario.

```bash
cd vencimientos-manuales-bff/sources
./mvnw -B clean verify
./mvnw -B spring-boot:run -Dspring-boot.run.profiles=local
```

El servicio escucha en `http://localhost:8080`. La documentación OpenAPI está disponible en `/v3/api-docs` y `/v3/api-docs.yaml`. Los endpoints de Actuator se publican sin autenticación en `/monitoring/health`, `/monitoring/metrics` y `/monitoring/prometheus`.

Sin perfil activo, la aplicación usa la configuración segura de OAuth2 Resource Server para Entra ID; configura `ENTRAID_TENANT_ID`, `ENTRAID_AUDIENCE`, `ENTRAID_SCOPE_CONSULTA` y `ENTRAID_SCOPE_GESTION` sin incluir secretos en el repositorio. `local` desactiva deliberadamente la autenticación y solo debe usarse para desarrollo, activándolo de forma explícita con `SPRING_PROFILES_ACTIVE=local` (o `-Dspring-boot.run.profiles=local` al arrancar con Maven). El CORS local permite `http://localhost:4200`; otros orígenes se configuran en `APP_CORS_ALLOWED_ORIGINS`.

Para emitir trazas OTLP configura `OTEL_EXPORTER_OTLP_ENDPOINT`; el exportador queda desactivado si no se proporciona. Los logs se generan en JSON y no registran cuerpos HTTP ni PII.

## Perfiles y adaptadores

| Perfil | Adaptador host | Impresión | Seguridad |
|---|---|---|---|
| `local` | Datos en memoria | Respuesta simulada con identificador | Desactivada solo para desarrollo |
| Distinto de `local` | Esqueleto CTG; devuelve 503 hasta completar la integración | Esqueleto pendiente; devuelve 503 | JWT Entra ID y scopes configurables |

El adaptador CTG no abre conexiones reales. `ARCH-FIS-COM-001` requiere Gateway para comunicación síncrona inter-plataforma salvo excepción aprobada. La excepción PPV documentada para una aplicación EAR/WAS no contenerizada no acredita automáticamente a este BFF Spring Boot. Antes de implementar tráfico host real se debe decidir Gateway/z/OS Connect o aprobar y auditar la excepción CTG aplicable.

## Mapa de servicio legacy a endpoint

| Legacy | Endpoint |
|---|---|
| B372VT04 + B372VT08 | `GET /api/v1/expedientes` |
| B372VT01 | `GET/POST/PUT /api/v1/expedientes`, `POST /{anio}/{numero}/anulacion` y `/reaseguro`, `PUT /api/v1/expedientes/{anio}/{numero}/coaseguro` |
| B372VT02 | `GET/PUT /api/v1/expedientes/{anio}/{numero}/variables` |
| B372VT12 | `GET /api/v1/expedientes/{anio}/{numero}/coaseguro` |
| B372VT11 | `GET /api/v1/personas?nif=...` |
| B372VT19 | `GET /api/v1/polizas/{ramo}/{anio}/{numero}/cartera` |
| B372VT03 + B372VT05 | `GET /api/v1/carteras` y `/api/v1/carteras/listado` (provisionales) |
| B372VT09 + impresión | `POST /api/v1/finiquitos/emisiones` |
| B372VT10 + impresión | `POST /api/v1/informes` |
| B372VT06 | `POST /api/v1/peticiones-bdgi` |
| B372VT07 | `POST /api/v1/cargas-fichero` |
| B372VT01 (operación `M3`) | `POST /api/v1/expedientes/{anio}/{numero}/reaseguro` |
| Cálculos de `GestionCalculoVen.js` y `GestionExpedienteCalculoVen.js` | `POST /api/v1/calculos/liquidacion` |

El helper `J372J007ReaseguroVenHelperBean` confirma que `/reaseguroVen` termina en `J372J005ServicioGestionExpVenBean`, que invoca B372VT01 con operación `M3`; no existe un servicio host independiente para reaseguro.

Los catálogos VT03/VT05 quedan explícitamente provisionales: sus contratos aparecen en implantación, pero el inventario no encontró el caller Java ni los programas host correspondientes en el snapshot.

## Límites y cuestiones abiertas

- B372VT11 recibe claves de persona/domicilio en el XML legacy, no un NIF de búsqueda. El endpoint por NIF es el contrato solicitado; el mapeo productivo debe acordarse con el propietario de ese servicio.
- El XML de B372VT12 define la consulta del cuadro; la escritura se modela mediante los campos de entrada de coaseguro de B372VT01. Hay que confirmar que la operación `M1` es la prevista por el host para este cambio.
- No se encontró el código de operación VT01 para anulación ni para consulta individual; alta `A1`, modificación `M1` y reaseguro `M3` sí están confirmados. No se debe habilitar tráfico host hasta cerrar esos códigos.
- Los requests y responses del puerto host son records Java tipados; la traducción a campos XML/COBOL está confinada al adaptador `B372VtXmlMapper`. El adaptador CTG sigue pendiente y debe validarse con el contrato de transporte real antes de activar integración.
- VT03/05/08 se mantienen provisionales donde el inventario no confirma contrato o caller. VT12 usa transacción 3612.
- El algoritmo implementa el redondeo solicitado `HALF_UP`; la función legacy usa `Number.toFixed`, cuyo comportamiento puede diferir en empates binarios. `tools/caracterizacion/calculos.js` ejecuta la función legacy original para evidenciar esos casos.
- Los flujos que crean estado reciben `Idempotency-Key`, pero no hay almacenamiento compartido de claves; se debe definir la estrategia antes de habilitar reintentos con CTG.
- No se han incorporado el scaffold ni el onboarding SRE corporativos; se requiere el pipeline Zeus/SRE y la decisión de comunicación Gateway frente a CTG antes de producción.
