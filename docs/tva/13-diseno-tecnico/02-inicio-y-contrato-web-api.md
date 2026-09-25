# Design: Inicio y contrato Web API

## Technical Approach

Replica de la Web API `TVA InicioTarificadorVidaAhorro` y del PM de inicio: validación
del contrato de entrada con los textos exactos de `TVA_WebApi_Inicio_ObtenerMensajeError`
y `TVA_ValidacionInvestmentOption` (§12.4.1), comprobación de apertura
(`TVA_APLICACION_CERRADA`), perfil del usuario vía conector APPINVE, catálogo API Life,
creación de la `Sesion` con el estado `TVA_Sesion` y la pantalla inicial según
`TVA_propuestaProductosAhorro_siguientePantalla`. Dos endpoints (`inicio/ahorro`,
`inicio/rentas`) comparten la lógica; `indFunctionMode` (VA/VIA/R2C) decide la modalidad.
`NUUMA` se deriva del username (`upper(local-part)`). `perfilClientesOK` se deriva SOLO de
`policyHolders[].testData.convenience` (`signatureStatus == "FI"` y fecha no caducada) —
el bug original lo tomaba del mock RIC. Los errores devuelven HTTP 400 con el sobre Appian
`{code:"02", message, application:"TVA", timestamp, errors:[…]}`.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Contrato | Nuevo body primario `{indFunctionMode, proposalId, companyId, distributionChannel, username, policyHolders, investment}`; campos legacy opcionales | Solo nuevo contrato | Tests anteriores y compatibilidad sin romper |
| 2 | Validación | `validar_parametros_inicio_body` devuelve `list[str]` con textos exactos; sobre `webapi_error_response` | Avisos genéricos | Paridad literal con Appian (los textos se verifican en tests) |
| 3 | NUUMA | Derivado de `username` (`@mapfre.net` obligatorio), no del usuario autenticado | Token `sub` | En Appian es el usuario del portal, no el del JWT de servicio |
| 4 | `perfilClientesOK` | Derivado solo de `policyHolders[].testData.convenience` (FI + fecha) | RIC/perfil externo por defecto | Bug encontrado: el mock RIC devolvía True siempre y saltaba Tomador 1 |
| 5 | Catálogo para validar investment | `product_list(companyId, nuuma, channel)` como lista de códigos válidos | Lista fija hardcodeada | Mismo catálogo que verá el usuario; caso SINPRODUCTOS testeable |
| 6 | Pantalla inicial | `pantalla_inicio(modalidad, estado)` con la regla Appian | Secuencia fija por modalidad | La regla decide por datos (cerrado, sin perfil, sin productos) |

## Data Flow

```text
POST /inicio/ahorro (JSON nuevo o legacy)
  → InicioAhorroView.post → iniciar_sesion(usuario, datos)
    → validar_parametros_inicio_body (400 sobre Appian si errores)
    → Parametro TVA_APLICACION_CERRADA
    → perfil_usuario.obtener_perfil / ric.buscar_cliente / apilife.product_list
    → nueva_sesion_estado + pantalla_inicio → Sesion.objects.create
  → 201 { claveSesion, pantallaActual, estado, botones }

Frontend: InicioPage (TVA_Utilidades_Inicio) → api.inicioAhorro/inicioRentas
  → errores[] bajo "Se han encontrado ERRORES" o navegación a /sesion/:clave
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/views/inicio.py` | Modify | `_InicioBase.post`, `InicioAhorroView`, `InicioRentasView`; 400 con `webapi_error_response` |
| `tva-backend/sources/apps/tva/serializers/sesion.py` | Modify | Campos nuevos opcionales del contrato |
| `tva-backend/sources/apps/tva/operators/iniciar_sesion.py` | Modify | `_es_contrato_nuevo`, `_tomadores_desde_policy_holders` (testData→perfilCliente), `perfilClientesOK` derivado |
| `tva-backend/sources/apps/tva/operators/validaciones.py` | Modify | `validar_parametros_inicio_body`, `validar_investment_option`, `nuuma_desde_username`, `test_conveniencia_valido` |
| `tva-backend/sources/apps/tva/schemas/errors.py` | Modify | `webapi_error_response` con sobre `{code:"02", errors:[…]}` |
| `tva-frontend/src/app/pages/inicio/inicio.page.ts` | Modify | Formulario completo Utilidades Inicio + tabla investment + `policyHolders` con `testData.convenience` |
| `tva-frontend/libs/core/src/lib/domain/nuuma.ts` | Create | `nuumaDe(username)` read-only |

## Interfaces / Contracts

```python
# operators/validaciones.py
def nuuma_desde_username(username: str) -> str: ...
def validar_investment_option(opt: dict, prefijo: str, canal: str, codigos_validos: list[str] | None = None) -> list[str]: ...
def validar_parametros_inicio_body(body: dict, codigos_productos: list[str] | None = None) -> list[str]: ...
def test_conveniencia_valido(perfil: dict | None) -> bool: ...

# operators/iniciar_sesion.py
def iniciar_sesion(usuario: str, datos: dict) -> tuple[Sesion | None, list[str]]: ...

# schemas/errors.py
def webapi_error_response(mensajes: list[str]) -> dict:  # {"code":"02","message":...,"application":"TVA","timestamp":...,"errors":[…]}
```

```typescript
// Request (contrato nuevo)
interface InicioRequest {
  indFunctionMode: 'VA' | 'VIA' | 'R2C' | string;
  proposalId?: string;
  companyId: string;
  distributionChannel: string;
  username: string;
  policyHolders?: Record<string, unknown>[];
  investment?: InvestmentOption[];
}

// policyHolder con Perfilado marcado
{ testData: { convenience: { profileCode: 'ME', profileDesc: 'Medios', signatureStatus: 'FI', expirationDate: '2028-01-17' } } }
```
