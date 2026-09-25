# Design: Integraciones mock y conectores

## Technical Approach

Cada integración Appian (API Life, APPINVE/perfil usuario, RIC, MISV) es un
conector con dos implementaciones: `Mock*Client` que devuelve fixtures JSON o un
catálogo razonable, y `Real*Client` sobre `apps.core.httpclient.BaseHttpClient`
con credenciales por entorno. La selección se hace por variable
(`APILIFE_MODE=mock|real`, análogo en el resto) a través de las factories
`get_apilife_client`, `get_ric_client`, `get_misv_client`,
`get_perfil_usuario_client`. Los fixtures de `fixtures/apilife/` se derivan de
las reglas `TVA_MOCK_*` del volcado; el catálogo de productos es código (los 21
productos DEV). El punto de sustitución por los conectores reales está
documentado en la guía de despliegue.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Contrato del conector | Interfaz `*Client` + `Mock`/`Real` + factory `get_*_client()` | Llamadas HTTP directas | Permite cambiar a real sin tocar los operadores |
| 2 | Selección mock/real | Env `*_MODE` por conector | Por entorno global | Permite mezclar (p.ej. API Life real + RIC mock) |
| 3 | Fixtures | JSON en `fixtures/apilife/` por endpoint (`ENDPOINT_FIXTURES`) | Datos en código salvo productos | Los volcados Appian son JSON; los productos son el catálogo DEV real |
| 4 | HTTP real | `BaseHttpClient` stub con `get/post/put` + basic auth + timeout | requests a pelo | Misma responsabilidad que `arch-ram-lib-django-httpclient`; swap trivial |
| 5 | Fallos | `ApiLifeError` y log; el operador decide el aviso | Excepción genérica | Permite el aviso Appian específico por fallo de servicio |
| 6 | Comportamiento mock | `SINPRODUCTOS` → `[]`; `individual_documents` OK; etc. | Siempre éxito | Cubre los casos de error que hay que poder probar |

## Data Flow

```text
Operador → get_*_client() (factory por *_MODE)
  → Mock*Client → fixtures/apilife/*.json | _catalogo_dev()
  → Real*Client → BaseHttpClient(base_url+auth por env) → servicio real
  → respuesta → operador → estado/avisos
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/services/connectors/apilife.py` | Create | `ApiLifeClient` con 16 métodos + `MockApiLifeClient` + `RealApiLifeClient` + `ENDPOINT_FIXTURES` + `_PRODUCTOS_DEV` |
| `tva-backend/sources/apps/tva/services/connectors/ric.py` | Create | `RicClient.buscar_cliente` mock/real |
| `tva-backend/sources/apps/tva/services/connectors/misv.py` | Create | `MisvClient.perfilar` mock/real |
| `tva-backend/sources/apps/tva/services/connectors/perfil_usuario.py` | Create | `PerfilUsuarioClient.obtener_perfil` mock/real |
| `tva-backend/sources/apps/core/httpclient.py` | Create | `BaseHttpClient` stub del wrapper corporativo |
| `tva-backend/sources/apps/tva/fixtures/apilife/*.json` | Create | Respuestas por endpoint |

## Interfaces / Contracts

```python
# services/connectors/apilife.py
class ApiLifeClient:
    def call(self, endpoint: str, payload: dict | None = None) -> dict: ...
    def product_list(self, company_id=None, product_type_code=None, nuuma=None, distribution_channel=None) -> dict: ...
    def individual_documents(self, payload: dict) -> dict: ...
    def save_proposal(self, payload: dict) -> dict: ...
    def annuity_simulation(self, payload: dict) -> dict: ...
    def validate_reinvestment(self, payload: dict) -> dict: ...
    def verify_producers(self, payload: dict) -> dict: ...
    # … 16 endpoints mapeados a fixtures

def get_apilife_client() -> ApiLifeClient:  # mock|real por APILIFE_MODE

# ric.py / misv.py / perfil_usuario.py
def get_ric_client() -> RicClient: ...
def get_misv_client() -> MisvClient: ...
def get_perfil_usuario_client() -> PerfilUsuarioClient: ...
```
