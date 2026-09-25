# Design: Observabilidad y trazas

## Technical Approach

`apps/core/observability.py` es el stub de `arch-ram-lib-django-observability`:
`JsonFormatter` para logs JSON, `ObservabilityMiddleware` que propaga un
`request_id` y `set_clave_sesion`/`get_request_id` por contexto de hilo para
anotar cada log con la sesión. `apps/tva/models.Traza` es la traza funcional
(`TVA_ENT_TRAZA`): cada operador llama a `guardar_y_trazar` (`_comun.py`) que
guarda la sesión (`pantalla_actual`/`estado`/`abierta`) y crea una `Traza` con
`tipo_contenido` (la acción/ubicación), `clase` INFO/ERROR según los avisos,
`mensaje` y `datos`. `django.db.backends` se deja en WARNING salvo `SQL_DEBUG=True`.
Las trazas se consultan desde Admin (`GET /admin/trazas/?clave=…`).

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Traza funcional | `Traza` persistida por acción (`tipo_contenido`, `clase`, `mensaje`, `datos`) | Solo logs | La traza de Appian es una entidad consultable desde admin |
| 2 | Punto de escritura | `guardar_y_trazar` llamado por cada operador tras persistir | Middleware o señales | Mismo punto en el que Appian graba traza en el PM |
| 3 | Contexto por hilo | `set_clave_sesion`/`get_request_id` en `observability` | Logger por sesión | Anota todos los logs de una petición sin pasar la clave |
| 4 | Formato | `JsonFormatter` para logs estructurados | Logs planos | Igual que la librería corporativa de observabilidad |
| 5 | SQL | `django.db.backends` en WARNING salvo `SQL_DEBUG=True` | Siempre DEBUG | Con DEBUG=True el logger volcaba cada sentencia |
| 6 | Interceptor | `errorInterceptor` → MatSnackBar en frontend | Solo consola | Los errores de API deben ser visibles en la UI |

## Data Flow

```text
Request → ObservabilityMiddleware (request_id)
Operador → guardar_y_trazar(sesion, ubicacion, avisos, datos)
  → sesion.save + Traza.objects.create(clave_sesion, tipo_contenido, clase, mensaje, datos)
  → set_clave_sesion (anota logs)
Admin → GET /admin/trazas/?clave=<clave> → Traza.objects.filter(clave_sesion=…)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/core/observability.py` | Create | `JsonFormatter`, `ObservabilityMiddleware`, `set_clave_sesion`, `get_request_id` |
| `tva-backend/sources/apps/tva/models.py` | Modify | Modelo `Traza` (FK sesión, clase, tipo_contenido, mensaje, datos) |
| `tva-backend/sources/apps/tva/operators/_comun.py` | Modify | `guardar_y_trazar` persiste + crea Traza + `set_clave_sesion` |
| `tva-backend/sources/apps/tva/views/admin.py` | Modify | `TrazasView` |
| `tva-backend/sources/config/settings.py` | Modify | Logger `django.db.backends` WARNING salvo `SQL_DEBUG` |
| `tva-frontend/libs/core/src/lib/infra/http/` | Modify | `errorInterceptor` → MatSnackBar |

## Interfaces / Contracts

```python
# apps/core/observability.py
def set_clave_sesion(clave: str) -> None: ...
def get_request_id() -> str: ...
class JsonFormatter(logging.Formatter): ...
class ObservabilityMiddleware:
    def __init__(self, get_response): ...
    def __call__(self, request): ...

# apps/tva/models.py
class Traza(models.Model):
    sesion = models.ForeignKey(Sesion, null=True, on_delete=models.SET_NULL)
    clave_sesion = models.CharField(max_length=64, db_index=True)
    tipo_contenido = models.CharField(max_length=64)   # ubicación/acción
    clase = models.CharField(choices=Clase.choices, default="INFO")  # INFO|ERROR|AVISO
    mensaje = models.TextField()
    datos = models.JSONField(default=dict)

# operators/_comun.py
def guardar_y_trazar(sesion: Sesion, ubicacion: str, avisos: list | None = None, datos: dict | None = None) -> Sesion: ...
def resultado(sesion: Sesion, avisos: list | None = None, roles: list[str] | None = None) -> dict: ...
```
