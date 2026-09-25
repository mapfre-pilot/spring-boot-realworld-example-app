# Design: Navegación y máquina de pantallas

## Technical Approach

La navegación NO es una secuencia fija por modalidad: `siguiente_pantalla(sesion)`
implementa la regla `TVA_propuestaProductosAhorro_siguientePantalla` leyendo el estado
(`investmentOption.insuranceOfferInd`, `perfilClientesOK`, número de tomadores,
`rentas.recalcular`). `pantalla_inicio` decide la pantalla inicial tras `iniciar_sesion`
(cerrado → SISTEMA_CERRADO, sin perfil → SIN_PERFIL, VIA sin productos → SOLO_AVISOS,
VA → SEGUROS_AHORRO o CAPTURA_DATOS_SOLICITUD, VIA → SELECCION_PRODUCTO o flujo de
solicitud, R2C → R2C_CAPTURA). `dispatcher.ejecutar_accion` enruta cada acción al
operador correspondiente, aplica acciones transversales (`cancelar`, `administracion`,
`volver-administracion`, `doc-precontractual`, `contratar`, `siguiente`, `anterior`)
y añade la botonera. En Angular, `SesionPage` hace `@switch` sobre `idPantallaActual`
renderizando el container correspondiente.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Modelo de navegación | Regla data-driven `siguiente_pantalla` sobre el estado | `SECUENCIAS` fijas por modalidad | Appian decide por datos (perfil OK, campaña, nº tomadores) |
| 2 | Punto único de avance | `siguiente_pantalla` compartida por `siguiente`, `seleccionar-modalidad`, `continuar-tomador`, `contratar` | Lógica duplicada por operador | Misma tabla §12.4.2 para todos los caminos de avance |
| 3 | Sincronización | `sincronizar_pantalla` espeja `pantalla_actual` → `estado.idPantallaActual` | Solo guardar en tabla | El estado serializado debe reflejar la pantalla |
| 4 | Atrás | Solo R2C_PRECIOS→R2C_CAPTURA y ADMINISTRACION→idPantallaAnterior | Atrás genérico | La regla Appian solo permite esos dos retrocesos |
| 5 | Enrutado | `SesionPage` con `@switch` sobre `pantallaActual()` | Una ruta por pantalla | La pantalla la decide el backend; el front es un visor |
| 6 | Acciones nuevas | `cancelar` (FIN+avisos[]), `administracion` (guarda idPantallaAnterior, rol TVA_ADMIN_PORTAL), `doc-precontractual` (mock envío+flag tomador), `contratar` (condiciones §12.4.3) | Solo acciones de negocio | El menú superior de Appian es parte del contrato de pantalla |

## Data Flow

```text
POST /sesiones/<clave>/acciones/<accion>/
  → SesionAccionView.post → dispatcher.ejecutar_accion(sesion, accion, datos, roles)
    → acción transversal o dispatch → operador
    → sincronizar_pantalla + guardar_y_trazar
  → { pantallaActual, estado, avisos, botones }
  → SesionStore → pantallaActual() → @switch → container
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/maquina_pantallas.py` | Modify | `siguiente_pantalla`, `pantalla_inicio`, `pantalla_anterior`, `sincronizar_pantalla`, `Accion` (+5 nuevas) |
| `tva-backend/sources/apps/tva/operators/dispatcher.py` | Modify | `_accion_cancelar`, `_accion_administracion`, `_accion_doc_precontractual`, `_accion_contratar`, `VALIDAR_SECCION` |
| `tva-backend/sources/apps/tva/views/sesiones.py` | Modify | `SesionAccionView` pasa `request.user.roles` |
| `tva-frontend/src/app/pages/sesion/sesion.page.ts` | Modify | `@switch` por pantalla + `app-botonera` data-driven |
| `tva-frontend/libs/core/src/lib/application/state/sesion.store.ts` | Modify | `ACCION_POR_BOTON` map botón→acción backend |

## Interfaces / Contracts

```python
# operators/maquina_pantallas.py
class Accion(StrEnum):
    SIGUIENTE = "siguiente"; ANTERIOR = "anterior"
    SELECCIONAR_MODALIDAD = "seleccionar-modalidad"
    GUARDAR_SOLICITUD = "guardar-solicitud"; CONTINUAR_TOMADOR = "continuar-tomador"
    RECALCULAR_RENTAS = "recalcular-rentas"; CONTRATAR_RENTAS = "contratar-rentas"
    FIRMAR = "firmar"; VALIDAR_REINVERSION = "validar-reinversion"
    VERIFICAR_PRODUCTORES = "verificar-productores"; IMPORTE_MAXIMO = "importe-maximo"
    CANCELAR = "cancelar"; ADMINISTRACION = "administracion"
    VOLVER_ADMINISTRACION = "volver-administracion"
    DOC_PRECONTRACTUAL = "doc-precontractual"; CONTRATAR = "contratar"
    VALIDAR_SECCION = "validar-seccion"

def pantalla_inicio(modalidad: str, estado: dict) -> Pantalla: ...
def siguiente_pantalla(sesion: Sesion) -> Pantalla: ...
def pantalla_anterior(sesion: Sesion) -> Pantalla: ...
def sincronizar_pantalla(sesion: Sesion) -> None: ...

# operators/dispatcher.py
def ejecutar_accion(sesion: Sesion, accion: str, datos: dict, roles: list[str] | None = None) -> dict: ...
```
