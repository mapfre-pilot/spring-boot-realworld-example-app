# Operación y despliegue de PGM

## Perfiles de ejecución

| Perfil | Uso | Seguridad | Sistemas de datos |
|---|---|---|---|
| `local` | Desarrollo funcional de la SPA y el BFF | Mock, usuario y perfiles configurables | Adaptadores in-memory con datos sintéticos |
| `simulador` | Validación del BFF contra contratos y fallos de Gateway | Mock con `usuarios.json`, sin Entra ID | Adaptadores HTTP reales del BFF contra WireMock |
| `corporativo` (o cualquier perfil distinto de `local`/`simulador`) | Entornos integrados | Resource Server JWT/Entra ID; exige scope de acceso a PGM | API Canal y plataformas exclusivamente mediante el API Gateway |

Los adaptadores HTTP se activan fuera de `local`. `simulador` reutiliza el catálogo local de usuarios y las lanzaderas, sin duplicar sus datos, pero no reemplaza los adaptadores del Gateway. El perfil corporativo no debe habilitar `local` ni `simulador`.

### Variables de entorno

Valores operativos no sensibles:

| Variable | Uso | Valor por defecto |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | Perfil Spring | `local` fuera de despliegues |
| `SERVER_PORT` | Puerto HTTP | `8080` |
| `PGM_GATEWAY_BASE_URL` | URL base del Gateway interno | URL no enrutable de ejemplo; configurar por entorno |
| `PGM_GATEWAY_TENANT` | Tenant enviado como `X-Tenant` | `mapfre-es` |
| `PGM_GATEWAY_CONNECT_TIMEOUT_MS` | Timeout de conexión | `2000` |
| `PGM_GATEWAY_READ_TIMEOUT_MS` | Timeout de lectura | `5000` |
| `PGM_IDEMPOTENCIA_VENTANA` | Ventana de idempotencia ISO-8601 | `PT24H` |
| `APP_CORS_ALLOWED_ORIGINS` | Orígenes permitidos por CORS | `http://localhost:4200` |
| `OTEL_SAMPLING_PROBABILITY` | Muestreo de trazas | `0.1` |
| `OTEL_TRACING_ENABLED` | Exportación OTLP | `false` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Receptor OTLP | `http://localhost:4318/v1/traces` |

Para el perfil `simulador`, `PGM_GATEWAY_BASE_URL` apunta a `http://localhost:8089` localmente o a `http://gateway-sim:8080` en Compose. El timeout de lectura del test de integración se reduce para comprobar los retardos WireMock; no cambia el valor de despliegue.

Secretos (crear/proveerlos en el gestor corporativo y montarlos en Kubernetes; no incluir valores en manifiestos ni repositorio):

- Secret de Kubernetes `pgm-bff-secrets`, referenciado por nombre desde el Deployment.
- Claves esperadas para Entra ID: `ENTRAID_TENANT_ID`, `ENTRAID_AUDIENCE`; `ENTRAID_ISSUER` y `ENTRAID_JWKS_URI` solo si se apartan de los valores derivados por defecto.
- Credenciales de cliente para llamadas M2M al Gateway, si el contrato corporativo las requiere, usando nombres de clave acordados durante onboarding SRE.

El perfil simulador no requiere credenciales ni accede a Entra ID. `X-Usuario-Local` selecciona un usuario del catálogo sintético; también se conserva compatibilidad con `X-PGM-Usuario`. No usar esta autenticación mock en entornos compartidos.

## Entra ID y registros de aplicación

Aplicar la nomenclatura `APP-ESP-[PF]-[PRODUCTO]-[ENTORNO]`, con identificadores acordados por Arquitectura/Seguridad. Para PGM, la familia de nombres sigue el patrón `APP-ESP-[PF]-PGM-[ENTORNO]` (por ejemplo, sufijos `DEV`, `PRE` y `PRO`).

- **SPA**: registro cliente público, flujo Authorization Code con PKCE; no contiene secreto de cliente. Configurar los URI de redirección y salida de sesión por entorno.
- **BFF**: registro/API que expone el scope delegado de acceso (por defecto `pgm.acceso`) y valida issuer, audience y scope del access token presentado por la SPA.
- **BFF hacia Gateway (M2M)**: cuando el Gateway requiera identidad de aplicación, registrar al BFF como cliente confidencial y usar Client Credentials con el scope de recurso `.default` del API Gateway. El secreto/certificado se gestiona fuera del repositorio. La configuración final de scopes y permisos debe cerrarse con Seguridad y el equipo propietario del Gateway.

La SPA no debe enviar secretos ni usar Client Credentials. No habilitar el perfil de simulación ni el de desarrollo local para validar la seguridad corporativa.

## Cliente Gateway y resiliencia

Todo acceso remoto sale por el API Gateway interno. No se permiten llamadas directas desde el BFF a ESB, SOAP, Denodo o sistemas core.

- `RestClient` conserva el `RestClient.Builder` instrumentado por Spring/Micrometer y configura `connect-timeout-ms` (2 s por defecto) y `read-timeout-ms` (5 s).
- Todas las operaciones remotas tienen circuit breaker: instancias `apicanal` y `plataforma`, ventana deslizante de 20 llamadas, mínimo de 10, apertura con tasa de error ≥50 %, permanencia abierta de 30 s y tres llamadas permitidas en half-open.
- Las lecturas GET tienen además Retry: tres intentos máximos, espera inicial de 200 ms y backoff exponencial ×2. Solo se reintenta `SistemaExternoException` (fallo transitorio o de comunicación); las respuestas 4xx se clasifican como error de cliente y no se reintentan.
- Los POST no llevan Retry. Los cuatro POST de negocio aceptan `Idempotency-Key`: `/tarificacion/salud`, `/tarificacion/salud/borradores`, `/comunicaciones/llamadas` y `/auditoria`. Si se repite usuario+método+ruta+clave con el mismo cuerpo, se reproduce status, cabeceras y respuesta con `Idempotent-Replayed: true`; si cambia el cuerpo responde 409 RFC 9457. Sin clave, el procesamiento es el habitual.
- El Gateway recibe la clave en los POST remotos de tarificación y comunicaciones, además de `X-Tenant` y el `traceparent` W3C propagado.

La implementación de idempotencia y los borradores son locales al proceso. **Gap para PRO:** con varias réplicas hace falta un almacén compartido y coordinación entre instancias para conservar la garantía de replay; la elección del producto/tecnología queda pendiente del onboarding SRE y de una decisión de arquitectura.

## Salud, trazas y logs

- `/monitoring/health`, `/monitoring/health/liveness` y `/monitoring/health/readiness` se exponen mediante Actuator. Health muestra componentes y detalles, incluidos los circuit breakers. No publicar estos detalles fuera de redes de operación confiables.
- El apagado es graceful, con hasta 20 s por fase y probes para retirar la instancia antes de terminar.
- Los logs se emiten en JSON. Incluyen `trace_id`, `span_id` desde MDC `traceId`/`spanId`, `service.name=pgm-bff` y el enmascarado de DNI, IBAN, correo y teléfono. No añadir payloads ni datos identificativos a los logs.
- Tracing usa W3C Trace Context y exportación OTLP configurable. Ajustar el muestreo según las políticas de observabilidad del entorno.

## Despliegue EKS propuesto

Los manifiestos de `pgm-bff/deploy/k8s/` y `pgm-spa/deploy/k8s/` son **propuesta hasta el onboarding SRE (ZeusOneteam-OnboardingAWSArqContJava)**. No constituyen configuración aprobada de clúster, red, identidad, secretos, políticas ni pipeline.

Cada componente tiene `base` y overlays `dev`, `pre` y `pro`. El BFF usa un Deployment no-root, root filesystem de solo lectura, `/tmp` efímero, requests/limits, probes HTTP, Service, HPA y PDB. La ConfigMap contiene solo parámetros no sensibles. La referencia al Secret `pgm-bff-secrets` no contiene credenciales. La SPA sirve por nginx en 8080 y dirige `BFF_URL` al Service `pgm-bff`.

Los overlays fijan réplicas y un placeholder de URL Gateway por entorno; el perfil activo es `corporativo`, nunca `local`. Sustituir imágenes, dominios placeholder, parámetros de escalado y referencias a secretos mediante el onboarding. Validar compatibilidad con las políticas del clúster antes de desplegar.

### Simulador WireMock

Desde la raíz del repositorio:

```bash
docker compose -f pgm/docker-compose.yml --profile simulador up --build gateway-sim bff-simulador
curl -H 'X-Usuario-Local: usuario.local' http://localhost:8081/api/v1/clientes/C-1001/ficha
docker compose -f pgm/docker-compose.yml --profile simulador stop gateway-sim bff-simulador
```

WireMock carga mappings y respuestas sintéticas desde `pgm-bff/sources/src/test/resources/gateway-sim`. La configuración no sustituye pruebas contra los contratos y entornos reales de API Canal/Gateway.
