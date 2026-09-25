# Design: Pop-ups Appian Embedded (RGPD, DNI, test de conveniencia)

## Technical Approach

El panel derecho de `TVA_CapturaTomador` lanza tres pop-ups externos (Consentimiento RGPD,
Digitalización del NIF/NIE y Test de conveniencia). La integración sigue el patrón de
*Appian Embedded Interfaces* del codepen de referencia: el backend llama a una Web API
privada de Appian TEST con `Appian-API-Key` y obtiene un `taskId`; el frontend carga una
vez `embeddedBootstrap.nocache.js` y monta `<appian-task taskId="…">` en un diálogo,
escuchando los eventos `submit`/`error`. Si aparece `#appianLoginIframe`, se abre su `src`
en una pestaña nueva y se espera a `#task-body` (las cookies de terceros impiden el login
embebido). Al cerrar, el frontend notifica el resultado (`SUBMIT`/`DISMISS`/`ERROR`) y el
backend actualiza `datosGestionParticipante` / `perfilCliente.testConveniencia` del tomador.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Seguridad | API key solo en backend (`APPIAN_EMBED_API_KEY`), header `Appian-API-Key` | OAuth client_credentials en el navegador (como el CodePen) | La credencial no debe viajar al cliente; el CodePen la expone |
| 2 | HTTP | `requests.Session` directo, **sin reintentos** | `BaseHttpClient` con reintentos | Estos POST inician procesos en Appian; reintentar duplicaría tareas |
| 3 | Entorno | `APPIAN_EMBED_MODE=mock|real` con `get_appian_embed_client()` singleton | Siempre real | Permite desarrollo y pruebas sin red ni allow-list de IP |
| 4 | Login Appian | Detectar `#appianLoginIframe` → `window.open(src,'_blank')` y esperar `#task-body` (5 min) | Login embebido en iframe | Las cookies de terceros bloquean el login dentro del iframe; `data-signin="appiantestmapfrenopro"` marca el proveedor |
| 5 | Resultado | El frontend envía `SUBMIT`/`DISMISS`/`ERROR`; el backend aplica el flag | Callback de Appian al backend | La Web API devuelve el taskId pero no notifica cierre; el cliente ve el `submit` del componente |
| 6 | Limitación | DNI usa `cmp-captura-dni`, que solo responde desde IPs permitidas (IP allow-list MAPFRE); desde fuera devuelve 401 "Origen no válido" y se reporta como 502 | — | Limitación de la infraestructura, no del código |

## Data Flow

```text
Requisitos del tomador (botón) → AppianPopupService.abrir(clave, popup, idxTomador)
  → POST /sesiones/{clave}/popups/{popup}/lanzar/ {idxTomador}
    → construir_body(estado) → AppianEmbedClient.lanzar → POST Appian /webapi/<ruta> → {taskId, taskUrl}
  → MatDialog (AppianTaskDialogComponent, modo mock|real)
    → cargar() → <script embeddedBootstrap.nocache.js data-themeidentifier data-signin>
    → <appian-task taskId> → submit|error ; #appianLoginIframe → nueva pestaña → #task-body
  → afterClosed → POST /sesiones/{clave}/popups/{popup}/completar/ {idxTomador, taskId, resultado}
    → completar_popup → flags datosGestionParticipante / perfilCliente.testConveniencia
    → guardar_y_trazar → resultado(sesion) → store → UI
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/config/settings.py` | Modify | `APPIAN_EMBED_*` (base_url, api_key, mode, timeout, email avisos) |
| `tva-backend/sources/apps/tva/services/connectors/appian_embed.py` | Create | `POPUPS`, `AppianEmbedError`, `Mock/RealAppianEmbedClient`, `get_appian_embed_client` |
| `tva-backend/sources/apps/tva/operators/popups.py` | Create | `construir_body`, `lanzar_popup`, `completar_popup` |
| `tva-backend/sources/apps/tva/views/popups.py` | Create | `PopupLanzarView` (400/502/404) y `PopupCompletarView` |
| `tva-backend/sources/apps/tva/urls.py` | Modify | `popups/<str:popup>/(lanzar|completar)/` |
| `tva-backend/sources/apps/tva/tests/test_popups.py` | Create | 19 tests (connector mockeado, bodies, completar, vistas) |
| `tva-backend/docker/docker-compose.yml` | Modify | `APPIAN_EMBED_*` en environment (comentadas/mock) |
| `tva-frontend/public/assets/environments.json` | Modify | bloque `appianEmbed` por entorno |
| `tva-frontend/libs/core/src/lib/domain/*.model.ts` | Modify | `PopupAppian`, `PopupLanzadoResponse`, `PopupResultado` |
| `tva-frontend/libs/core/src/lib/data/repositories/*-http.repository.ts (+ ports/*-repository.port.ts)` | Modify | `lanzarPopup`, `completarPopup` |
| `tva-frontend/libs/core/src/lib/infra/appian/appian-embed-script.service.ts` | Create | Carga única del script embedded |
| `tva-frontend/src/app/ui/appian/appian-popup.service.ts` | Create | Orquestación lanzar→diálogo→completar (+ snackbar de error) |
| `tva-frontend/src/app/ui/appian-task-dialog.component.ts` | Create | Diálogo `<appian-task>` (mock/login/error/reintentar) |
| `tva-frontend/src/app/pages/sesion/pantallas/tomador-base.ts` | Modify | `requisitos` con `popup`/`habilitado` + `abrirRequisito` |
| `tva-frontend/src/app/pages/sesion/pantallas/captura-tomador1.container.ts` | Modify | Filas icono+botón en lugar de chips "Pendiente de integración" |

## Interfaces / Contracts

```python
# Web APIs privadas Appian TEST (POST JSON, header Appian-API-Key)
#   /webapi/cmp-firma-rgpd / /webapi/cmp-captura-dni / /webapi/testIdoneidad
# Respuesta: {"taskId": "…", "taskUrl": "https://…/suite/sites/…/task/<id>"}
# Errores:   401 {"code":"3","message":"Origen no válido",…} | 500 {"code":"3","message":"Parámetros no válidos","errors":[…]}

def construir_body(sesion: Sesion, popup: str, idx_tomador: int, user) -> dict: ...
def lanzar_popup(sesion: Sesion, popup: str, idx_tomador: int, user) -> dict: ...
def completar_popup(sesion: Sesion, popup: str, idx_tomador: int, task_id: str, resultado: str, roles) -> dict: ...

# POST /popups/<popup>/lanzar/  {idxTomador} → {popup, idxTomador, taskId, taskUrl, modo}
# POST /popups/<popup>/completar/ {idxTomador, taskId, resultado: SUBMIT|DISMISS|ERROR} → resultado(sesion)
```

```typescript
export type PopupAppian = 'rgpd' | 'dni' | 'test-conveniencia';
export interface PopupLanzadoResponse { popup; idxTomador; taskId; taskUrl; modo: 'mock'|'real' }
export type PopupResultado = 'SUBMIT' | 'DISMISS' | 'ERROR';
// Environment config: appianEmbed: { baseUrl, themeIdentifier: 'mapfre', signIn: 'appiantestmapfrenopro' }
```
