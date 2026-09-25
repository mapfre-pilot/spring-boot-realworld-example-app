# Design: Modelo de sesión TVA

## Technical Approach

La sesión de tarificación se modela como un único registro `Sesion` con un campo JSON
`estado` que reproduce el CDT `TVA_Sesion` de Appian (§12.3): camelCase, `cajas[]` con
`secciones[]` y `datosValidos`, `tomadores[]`, `ventaInformada`, `avisos[]` con
`seccion` para los de nivel SECCION, `idPantallaActual`/`idPantallaAnterior` espejo de
`sesion.pantalla_actual`. `sesion_modelo.py` construye el estado inicial
(`nueva_sesion_estado`, `tomador_vacio`, `cajas_iniciales`) y ofrece helpers inmutables
(`set_seccion_valida`, `caja_valida`, `buscar_caja`). En Angular, `SesionStore` expone
signals (`sesion`, `botones`, `avisos`, `pantallaActual`, `modalidad`) y métodos
`cargar`, `ejecutar`, `validarSeccion`, `guardarEstado`, con `datosPendientes` como
payload de la próxima acción de botonera.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Persistencia del estado | JSON único `estado` en `Sesion` (estructura TVA_Sesion) | Tablas normalizadas por entidad | Appian usa un CDT único; facilita paridad 1:1 y depuración |
| 2 | Cajas/secciones | Lista ordenada `cajas[].secciones[]` con `datosValidos` | Flags planos por campo | Replica el árbol Appian; la botonera depende de `caja_valida` |
| 3 | `idPantallaActual`/`Anterior` en estado | Espejo del campo `pantalla_actual` (`sincronizar_pantalla`) | Solo en tabla | La sesión serializada coincide con lo que Appian expone |
| 4 | Avisos | `{clase, tipo, texto, mostrarEn, codigo?, mensaje?, seccion?}` | Solo `{codigo,mensaje}` | Shape §12.3; `codigo`/`mensaje` se conservan por compatibilidad |
| 5 | Estado en frontend | `SesionStore` injectable root con signals + `datosPendientes` | NgRx / servicios por pantalla | Zoneless + signals nativos; evita estado duplicado entre container y botonera |
| 6 | Validación por sección | Acción `validar-seccion` escribe+valida+marca | Validar todo en continuar | Appian valida por sección al pulsar Continuar (plegado con validez) |

## Data Flow

```text
Operador (validar-seccion / continuar / acción)
  → escribe datos en estado[...path seccion...]
  → set_seccion_valida / _set_avisos_seccion
  → sesion.save (pantalla_actual + estado + abierta)
  → Traza.objects.create
  → resultado(sesion) → {claveSesion, pantallaActual, avisos, estado, botones}
  → SesionStore.sesion/botones signals
  → containers leen cajas/secciones/datos del estado
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/models.py` | Create | `Sesion` (JSONField estado), `Traza`, `Parametro` |
| `tva-backend/sources/apps/tva/operators/sesion_modelo.py` | Create | `tomador_vacio`, `cajas_iniciales`, `nueva_sesion_estado`, `set_seccion_valida`, `caja_valida`, `buscar_caja`, ids `CAJA_*` |
| `tva-backend/sources/apps/tva/schemas/errors.py` | Modify | `aviso` con shape §12.3 + `webapi_error_response` |
| `tva-frontend/src/app/core/state/sesion.store.ts` | Create | `SesionStore` signals y métodos |
| `tva-frontend/src/app/core/models/models.ts` | Create | `EstadoSesion`, `Tomador`, `Caja`, `SeccionCaja`, `Aviso`, `Boton`… |
| `tva-backend/sources/apps/tva/views/sesiones.py` | Modify | GET devuelve `botones`; acción pasa `request.user.roles` |

## Interfaces / Contracts

```python
# operators/sesion_modelo.py
def seccion(id: str, titulo: str = "") -> dict: ...
def caja(id: str, titulo: str, secciones: list[dict]) -> dict: ...
def tomador_vacio() -> dict: ...
def cajas_iniciales() -> list[dict]: ...
def nueva_sesion_estado(clave_sesion: str, modo_funcionamiento: str, **kw) -> dict: ...
def set_seccion_valida(estado: dict, caja_id: str, seccion_id: str, valida: bool) -> dict: ...
def caja_valida(estado: dict, caja_id: str) -> bool: ...
def buscar_caja(estado: dict, caja_id: str) -> dict | None: ...

CAJA_DATOS_PRODUCTORES = "DATOS_PRODUCTORES"
CAJA_DATOS_DEL_SEGURO = "DATOS_DEL_SEGURO"
CAJA_TOMADOR1 = "CAPTURA_DATOS_TOMADOR1"  # … etc (16 ids)
```

```typescript
interface EstadoSesion {
  claveSesion: string; modoFuncionamiento: Modalidad;
  codigoProducto?: string | null; companyId?: string | null;
  perfilUsuario: { nuuma?: string; oficina?: string; productor?: string; funcionalidades?: number[] };
  tomadores: Tomador[];
  ventaInformada: { opcionesInversion: Record<string, unknown>[]; cestaLibre: unknown[]; preferencias: Record<string, unknown> };
  cajas: Caja[]; avisos: Aviso[];
  idPantallaActual: string | null; idPantallaAnterior: string | null;
  perfilClientesOK?: boolean; [k: string]: unknown;
}
```
