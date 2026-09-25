# Design: Administración

## Technical Approach

La pantalla Administración (`/admin`) replica la de Appian para el grupo
`TVA_GRP_ADMINISTRADORES_PORTAL`: tabla editable de `Parametro`, ejecución del
batch apertura/cierre, botones Abrir/Cerrar aplicación (PUT directo sobre
`TVA_APLICACION_CERRADA` con estado visible al cargar), limpieza de cachés y
consulta de trazas por clave de sesión. El acceso viene del botón
`administracion` de la botonera (visible solo con rol `TVA_ADMIN_PORTAL`,
que guarda `idPantallaAnterior`) y de la ruta `/admin` protegida por
`roleGuard('TVA_ADMIN_PORTAL')` en el frontend y `IsTvaAdmin` en el backend.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Parámetros | Tabla `Parametro` con tipos str/int/bool/json + `Parametro.get` con fallback | settings/constantes | Sustituye las constantes cons!TVA_* editables en runtime |
| 2 | Apertura/cierre | Batch lee `TVA_FECHA_APERTURA`/`CIERRE` (vacío = sin restricción) y escribe `TVA_APLICACION_CERRADA` + botones directos | Solo fechas | El admin necesita abrir/cerrar manualmente como en Appian |
| 3 | Semillas | Fixtures `parametros.json` con fechas vacías y comentario "valor Appian original" | Fechas 2024 del dump | Evita que la app arranque cerrada en una instalación nueva |
| 4 | PUT parámetros | Solo actualiza los campos enviados | Reemplazo total | Evita perder tipo/descripción al editar el valor |
| 5 | Acceso | Rol en JWT + `IsTvaAdmin` + `roleGuard` | Sesión o grupo en BD | La autorización es del JWT corporativo, no de la app |
| 6 | Volver | `volver-administracion` restaura `idPantallaAnterior` | Volver a inicio | Permite volver al punto exacto del flujo |

## Data Flow

```text
Botón administracion → sesion.pantalla_actual = ADMINISTRACION (idPantallaAnterior)
GET /admin/parametros/ (IsTvaAdmin) → lista Parametro
PUT /admin/parametros/ {clave, valor} → actualiza campos enviados
POST /admin/apertura-cierre/ → batch fechas → TVA_APLICACION_CERRADA
PUT {clave: 'TVA_APLICACION_CERRADA', valor: '0'|'1'} → Abrir/Cerrar directo
POST /admin/caches/limpiar/ → invalidate caché productos
GET /admin/trazas/?clave=… → trazas de la sesión
Botón volver-administracion → idPantallaAnterior
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/views/admin.py` | Modify | `IsTvaAdmin`, `ParametrosView`, `AperturaCierreView`, `CachesView`, `TrazasView` |
| `tva-backend/sources/apps/tva/fixtures/parametros.json` | Modify | Fechas vacías + `TVA_APLICACION_CERRADA=0` + flags |
| `tva-backend/sources/apps/tva/management/commands/cargar_parametros.py` | Modify | Carga del fixture |
| `tva-frontend/src/app/pages/admin/admin.page.ts` | Modify | Tabla + botones apertura/cierre |
| `tva-frontend/libs/core/src/lib/infra/auth/guards.ts` | Modify | `roleGuard('TVA_ADMIN_PORTAL')` |

## Interfaces / Contracts

```python
# views/admin.py
class IsTvaAdmin(BasePermission):
    def has_permission(self, request, view) -> bool: return ROLE_ADMIN_PORTAL in roles

class ParametrosView(APIView):
    def get(self, request): ...
    def put(self, request): ...
class AperturaCierreView(APIView):
    def post(self, request): ...
class CachesView(APIView):
    def post(self, request): ...
class TrazasView(APIView):
    def get(self, request): ...
```

```typescript
// PUT /admin/parametros/
{ clave: string; valor: string }
```
