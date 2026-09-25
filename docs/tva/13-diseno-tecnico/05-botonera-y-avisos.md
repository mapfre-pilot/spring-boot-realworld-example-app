# Design: Botonera y avisos

## Technical Approach

La botonera es DATA, no markup: `botones_para(sesion, roles)` devuelve en cada
respuesta (acción y GET) la lista `[{id, label, visible, disabled, confirm?}]`
calculada por pantalla/modo/rol según la tabla §12.4.3 (replica de
`interfaces/TVA_Botonera.sail`). `condiciones_contratar(sesion)` es la única fuente
de verdad del motivo por el que Contratar está deshabilitado, reutilizada por el
botón y por el operador (que devuelve el aviso ERROR correspondiente). En frontend,
`BotoneraComponent` renderiza los botones en el layout Appian (Cancelar a la
izquierda como enlace, Administración centrado outline, primarios a la derecha) y
abre `MatDialog` con el `confirm` cuando existe. `AvisosComponent` muestra
`texto` por `tipo` (ERROR/WARNING/INFO) solo para `mostrarEn==='CABECERA'`;
los de `SECCION` los muestra `SeccionComponent` filtrando por `seccion`.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Botonera | Calculada en backend y devuelta en `botones` | Lógica en cada pantalla frontend | Única fuente de verdad como `TVA_Botonera` en Appian |
| 2 | Regla de Contratar | `condiciones_contratar` público compartido botón+operador | Duplicar condiciones | Un solo sitio para el motivo → botón disabled y aviso ERROR coherentes |
| 3 | Confirmaciones | `confirm: {header, message, ok, cancel}` en el DTO del botón | Diálogos hardcodeados | Appian define mensaje y botones por acción |
| 4 | Roles | De `request.user.roles` (JWT) a `botones_para` | Guardar rol en sesión | El rol es de la petición, no del estado |
| 5 | Avisos | Cabecera en `SesionPage`; sección dentro de `app-seccion` con filtro `seccion: "<caja>/<seccion>"` | Todos en cabecera | Appian muestra errores dentro de la sección |
| 6 | Flags | `TVA_FLAG_*` leídos de `Parametro` en cada cálculo | Cachear flags | Cambios de administración efectivos sin reinicio |

## Data Flow

```text
Operador → resultado(sesion, roles) → botones_para(sesion, roles)
  → _seguro_y_productores_validos (caja_valida) / tc / flags / avisos ERROR
  → botones[] en la respuesta
  → store.botones → BotoneraComponent → MatDialog (confirm)
  → (accion) → store.ejecutar(id) → ACCION_POR_BOTON → POST acción

avisos: estado.avisos
  → CABECERA → AvisosComponent (sesion.page)
  → SECCION + seccion="<caja>/<seccion>" → SeccionComponent
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/botonera.py` | Create | `botones_para`, `condiciones_contratar`, `_CONFIRM_CANCELAR`, `_CONFIRM_DOC` |
| `tva-backend/sources/apps/tva/operators/_comun.py` | Modify | `resultado` incluye `botones`; `add_aviso` con `tipo`/`mostrar_en` |
| `tva-backend/sources/apps/tva/operators/dispatcher.py` | Modify | `_accion_contratar` usa `condiciones_contratar` |
| `tva-frontend/src/app/ui/botonera.component.ts` | Create | Render data-driven + MatDialog confirm |
| `tva-frontend/src/app/ui/confirm-dialog.component.ts` | Create | Diálogo con header/message/ok/cancel |
| `tva-frontend/src/app/ui/avisos.component.ts` | Modify | `texto`/`tipo`/`mostrarEn` CABECERA |
| `tva-frontend/src/app/ui/seccion.component.ts` | Create | Plegado + check + avisos de sección |

## Interfaces / Contracts

```python
# operators/botonera.py
def botones_para(sesion: Sesion, roles: list[str] | None = None) -> list[dict]: ...
def condiciones_contratar(sesion: Sesion) -> str | None: ...
```

```typescript
interface Boton {
  id: string;            // cancelar|administracion|atras|recalcular|guardar-y-volver|doc-precontractual|contratar|continuar|siguiente|firmar
  label: string;
  visible: boolean;
  disabled: boolean;
  confirm?: { header: string; message: string; ok: string; cancel: string };
}

interface Aviso {
  clase: number;
  tipo: 'INFO' | 'WARNING' | 'ERROR';
  texto: string;
  mostrarEn: 'CABECERA' | 'SECCION';
  seccion?: string;       // "<caja>/<seccion>"
  codigo?: string; mensaje?: string;
}
```
