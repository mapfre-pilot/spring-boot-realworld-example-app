# PGM — Arquitectura objetivo y plan de migración (brownfield)

> Specs activadas (WRK-SPEC congelados en `.kdd/WRK-SPEC-NEW-SPA-001.md` y `.kdd/WRK-SPEC-NEW-BFF-001.md`, 19/10/2026): `MFST-NEW-SPA-001@1.3.0` → `ARQT-ANGULAR-001@1.1.0`, `BP-API-001@1.0.0`; `MFST-NEW-BFF-001@1.2.0` → `ARCH-FIS-COM-001@1.0.0`, `ARQT-SBOOT-001@1.0.1`, `BP-API-001@1.0.0`. Contexto adicional: `ARCH-APICANAL-001`, `PROD-APICANAL-*`. Todas con `confidence: medium/low` sin `verified`: las decisiones que se apoyan en ellas se marcan como tal.

## 1. Arquitectura objetivo

```
 Oficina MAPFRE (navegador)
 ┌──────────────────────────────┐
 │  pgm-spa  (Angular, Nx)      │  ARQT-ANGULAR-001 · SSO Entra ID (OIDC) · deep links /clientes/{doc} /polizas/{id}
 └──────────────┬───────────────┘
                │ HTTPS/JSON · JWT usuario
 ┌──────────────▼───────────────┐
 │  pgm-bff  (Spring Boot)      │  ARQT-SBOOT-001 + BP-API-001 · OpenAPI 3 · OAuth2 resource server
 │  journey PGM: composición    │  autorización perfil×estructura comercial · lanzaderas · auditoría · borradores
 │  360, visibilidades, flags   │  sin BBDD de cliente (opcional: Redis/Mongo para borradores y flags)
 └───┬──────────┬───────────┬───┘
     │ s2s JWT  │           │  API Gateway interno (ARCH-FIS-COM-001)
 ┌───▼───────┐ ┌▼─────────┐ ┌▼──────────────────────────────────────┐
 │ API Canal │ │API Canal │ │ APIs de Plataforma / producto          │
 │ Clientes  │ │Pólizas · │ │ PGO (oportunidades) · SGC 3.0 · iMediador│
 │ (ODL 360) │ │Recibos · │ │ SGO · ACI/Club · Consentimientos ·      │
 │           │ │Siniestros│ │ Comunicaciones (click-to-call, WhatsApp)│
 │           │ │· Ventas  │ │ Partners (Verti/Santander/SAVIA) → BFP  │
 └───────────┘ └──────────┘ └─────────────────────────────────────────┘
       │ proxy v0 → API Plataforma cuando exista (deuda controlada)
   RIC · GESYC · METS · cores de ramo · Denodo/Kafka (eventos cliente/póliza/rol)
```

### 1.1 Componentes

| Componente | Spec | Decisiones |
|---|---|---|
| **pgm-spa** | `ARQT-ANGULAR-001` | Angular 17–19 + Nx, esbuild, Jest/Spectator, ESLint/Prettier MAPFRE, registro npm Azure Artifacts, CI `ZeusOneteam-CI-FrontSPA`; creado desde Zeus OneTeam (Application SPA, extensión España). Rutas: `/inicio` (buscador), `/clientes/:id` (ficha con pestañas *posición*, *gestión comercial*, *presupuestos*), `/polizas/:id`, `/recibos`, `/prestaciones`, `/nueva-produccion`, `/gestion-cartera`, `/utilidades`. Estado por feature (signals/NgRx a decidir), componentes de ficha reutilizables (cabecera, indicadores, carrusel por ramo, tablas exportables). |
| **pgm-bff** | `ARQT-SBOOT-001`, `BP-API-001`, `ARCH-FIS-COM-001` | Java 21, Spring Boot 3, arquetipo `arch-ram-archetype-container-java`, starters logging/telemetry/monitoring (España) + auth + httpclient (+ rediscache opcional). Arquitectura hexagonal: `application` (casos de uso por pestaña), `domain` (modelo de ficha PGM), `adapters/in` (REST OpenAPI-first `/api/v1/...`), `adapters/out` (clientes API Canal y plataformas con timeouts, retries idempotentes, circuit breaker). Sin lógica de dominio de Clientes/Pólizas/Recibos: solo composición y adaptación. |
| **API Canal** (`PROD-APICANAL-*`) | `ARCH-APICANAL-001` | Consumo exclusivo para los 5 dominios; peticiones de capacidades del doc 03 §3. |
| **APIs de plataforma** | `ARCH-FIS-COM-001` | Siempre por API Gateway interno del dominio destino, autenticación s2s por tenant; nunca desde la SPA. |
| **BFP** | `ARCH-APICANAL-001` | Inducciones a Verti/Santander/SAVIA y cualquier tercero: salen del BFF hacia un BFP (o se piden a API Canal como integración transversal). |

### 1.2 Seguridad

- Usuario: OIDC/OAuth2 **Microsoft Entra ID** (BP-API-001), grupos de Entra ID sustituyen a los 21 grupos Appian (mapa 1:1 de perfiles + pilotos como *feature flags* en configuración, no en grupos).
- Estructura comercial (oficina, delegado, perfil, NUUMA): claim resuelto por el BFF al inicio de sesión (plataforma comercial), cacheado por sesión.
- s2s: client-credentials por tenant hacia API Canal y API Gateway; secretos en Key Vault; cifrado de parámetros SGC se mantiene hasta que SGC publique API por Gateway.
- PII: sin persistencia propia; logs JSON sin PII (`arch-ram-lib-java-logging-starter` con enmascarado); `enableRequestResponseLogging` desaparece.

### 1.3 Observabilidad

- `/monitoring/health|metrics|prometheus`, OpenTelemetry OTLP, dashboards *Java functional/technical* (BP-API-001).
- Métricas de negocio del cuadro de mando actual (interacciones por motivo/canal) como contadores Prometheus / eventos, no como tabla propia.

### 1.4 Datos

- Caché de ficha PostgreSQL y Appian DB → **se elimina**; la visión 360 nivel 1 se sirve del ODL de API Clientes (`apichannel`).
- Borradores de tarificación Salud y estado de diálogos → almacén ligero del BFF (Redis/Mongo Atlas, starter corporativo) o en la propia plataforma de Ventas si lo ofrece.
- CDTs `urn:mapfre:pgm` → DTO OpenAPI del BFF + modelos de los productos API Canal.

## 2. Estrategia: strangler por dominio

Appian sigue en producción mientras la SPA y el BFF crecen; el **buscador y la ficha** son el primer corte porque concentran el 70 % de las integraciones (Clientes) y están cubiertos por API Canal Clientes. Cada fase entrega valor y retira integraciones de Appian.

| Fase | Alcance | Specs / productos | Entregables | Sale de Appian |
|---|---|---|---|---|
| **0. Preparación** (2–3 sem.) | WRK-SPEC SPA+BFF congelados; alta en Zeus OneTeam; contratos OpenAPI del BFF v1; acuerdo de capacidades con PCC (doc 03 §3); alta Entra ID y grupos | MFST-NEW-SPA/BFF, BP-API-001 | repos `pgm-spa`, `pgm-bff`, `openapi.yaml`, mapa grupos Appian→Entra | — |
| **1. Buscador + ficha nivel 1** | Búsqueda multicriterio (federada), cabecera, indicadores, resumen por ramo, pestaña Productos, deep links `accesoFicha`/`fichaCliente`/`abrir-ficha-SGC` | APICANAL-CLIENTES (ODL, search, individuals/companies, contactMethods, families, healthCards), APICANAL-POLIZAS | SPA rutas `/inicio`, `/clientes/:id`; BFF `GET /clientes/search`, `GET /clientes/{id}/ficha`, `/productos` | ~70 integraciones Clients EDGE/API GW, caché PostgreSQL, Web APIs de entrada |
| **2. Recibos y prestaciones** | Pestañas Recibos y Prestaciones, ficha recibo, duplicados; operativas (agrupar, envío banco, cobro) cuando API Canal Recibos las publique | APICANAL-RECIBOS, APICANAL-SINIESTROS | BFF `/clientes/{id}/recibos`, `/prestaciones`, `/recibos/{id}` | gesycore/GESYC ESB, METS, ATN ESB (procesos SOAP) |
| **3. Gestión comercial** | Pestaña Gestión comercial: SGC 3.0, iMediador, interacciones, oportunidades PGO (alta/detalle/documentos), consentimientos, Cliente Total | plataformas PGO/SGC/iMediador por API GW (gap API Canal), CLIENTES (interacciones/consentimientos) | BFF `/clientes/{id}/gestiones`, `/oportunidades`, `/actividades`, `/consentimientos` | `/apipgo`, `sgc3-bk-*`, iMediador, BFF `/api-pgm` v0 absorbido |
| **4. Ventas y cartera** | Nueva producción por ramo, tarificación rápida Salud + borradores, presupuestos, ficha de póliza completa por ramo, gestión de cartera, lanzaderas (Citrix/NSE/Portal Interno) | APICANAL-VENTAS, APICANAL-POLIZAS, catálogo de lanzaderas en BFF | SPA `/nueva-produccion`, `/gestion-cartera`, `/polizas/:id`; BFF `/lanzaderas`, `/tarificacion/salud` | Health/Life/Home/Motor API directas, WLCatalog, Citrix lambda, borradores Appian |
| **5. Periferia y apagado** | Inducciones a partners (BFP), ACI/Club/tréboles, SGO, click-to-call/WhatsApp, cuadro de mando → métricas; redirección del site Appian a la SPA; baja de objetos | BFP, plataformas por API GW | decommission Appian PGM_MAPFRE | resto (≈ 60 integraciones, 127 PMs, 4 data stores) |

Criterios de corte por fase: paridad funcional verificada con analistas funcionales de la aplicación; cero llamadas directas canal→legacy en el código nuevo (`ARCH-APICANAL-001` AC1); métricas y logs en los dashboards estándar; contrato OpenAPI versionado.

## 3. Reglas de implementación (criterios de aceptación heredados)

- `ARQT-SBOOT-001`: estructura `sources/`, `docker/Dockerfile`, `docker/docker-compose.yml`, `maven/settings.xml`, workflows `pull-request.yml` / `merge-commit.yml`, `mvn clean package` exit 0, starters de observabilidad España, `/docs/swagger`, health/metrics 200, OAuth2 contra Entra ID.
- `ARQT-ANGULAR-001`: workspace Nx, ESLint/Prettier/commitlint/Husky, Jest+Spectator, build esbuild, publicación vía `ZeusOneteam-CI-FrontSPA`.
- `BP-API-001`: OpenAPI-first, `catalog-info.yaml` en Backstage, SonarQube quality gate, logging JSON + OTLP + Prometheus.
- `ARCH-FIS-COM-001`: llamadas inter-plataforma solo por API Gateway interno del destino; nada de acceso directo a BBDD ajenas.
- `ARCH-APICANAL-001`: el BFF no cachea lo que cachea API Canal; lógica de activo en BFF; excepciones solo vía BFP documentadas.

## 4. Riesgos y decisiones abiertas (Open Questions del WRK-SPEC)

1. **Plataforma**: PGM pertenece a la plataforma **Canales y Clientes**, que todavía no tiene specs (`PLAT-FUNC-*`, `PROD-*`) en el grafo; los WRK-SPEC se han creado con `platform: standalone` (misma activación que `PGO`) por decisión del usuario (19/10/2026). Gap a consolidar: `PLAT-FUNC-CYC-001` y `PROD-CYC-PGM-*`.
2. **Dominios sin producto API Canal** (PGO, SGC, iMediador, SGO, ACI/Club, partners): ¿nuevos `PROD-APICANAL-*` o consumo de API de Plataforma por Gateway desde el BFF? Decisión con PCC y Arquitectura.
3. **Búsqueda federada** por matrícula/recibo/presupuesto/expediente: ¿en API Canal Clientes o compuesta en el BFF?
4. Operativas de **recibos** (cobro, agrupación, banco) y de **pólizas** (anulación, duplicados): calendario de API Canal; mientras tanto Appian sigue sirviendo esas acciones (strangler).
5. **Modelo de autorización**: traducción de grupos Appian + estructura comercial a Entra ID (grupos vs. claims vs. servicio de perfiles).
6. **Appian como fuente de SGO**: si SGO permanece en Appian, el BFF lo consume por Web API publicada en API Gateway (no loopback).
7. Las specs activadas son `confidence: medium/low` sin `verified`: validar con Arquitectura antes de fijar el diseño detallado.

## 5. Estimación orientativa

Fase 0: 2–3 semanas · Fase 1: 8–10 semanas · Fase 2: 6–8 · Fase 3: 8–10 · Fase 4: 10–12 · Fase 5: 4–6. Dependencias críticas externas: publicación de capacidades por API Canal (doc 03 §3) y disponibilidad de APIs de plataforma PGO/SGC/iMediador por API Gateway. Sin ellas, las fases 2–4 solo pueden cubrir consulta.
