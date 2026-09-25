# Design: Selección de producto y catálogos

## Technical Approach

`GET /productos/` sirve el "taller" (catálogo del usuario) con `ProductList` del
conector API Life — mock: los 21 productos DEV con `commercialProductCode`,
`commercialProductDesc`, `unitLinkedInd`, `garantias`, `periodicidades`,
`primaMinima`/`primaMaxima`, `opcionesInversion`, `requiereAsegurado`. El caso
`nuuma == "SINPRODUCTOS"` devuelve `[]` para poder probar el aviso
"El servicio no ha devuelvo ningún producto de ahorro" (se conserva la falta
original). `GET /catalogos/<nombre>/` sirve listas estáticas desde
`fixtures/catalogos/*.json` (sexos, países, provincias completa, tipos de vía,
actividad/sector/profesión, periodicidades, tipos de duración, beneficiarios,
medios de contacto). `seleccionar-modalidad` copia el producto al estado:
`codigoProducto`, `garantias` con las obligatorias preseleccionadas y
`ventaInformada.opcionesInversion`.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Catálogo de productos | Mock con los 21 productos DEV reales + metadatos para validar | Fixture genérico mínimo | Las validaciones §12.4.4 dependen de datos del producto |
| 2 | Caso sin productos | `nuuma=="SINPRODUCTOS"` → `[]` | Excepción o fixture especial | Reproduce el comportamiento Appian con un usuario sin productos |
| 3 | Catálogos de valores | `fixtures/catalogos/*.json` servidos por una vista | Constantes en código o BD | Cercano a las constantes Appian; fácil de ampliar |
| 4 | Cache del taller | `get_cache` con clave `tva:productos:{companyId}:{nuuma}:{canal}` | Sin caché / caché global | API Life se llama por usuario; la caché sigue el patrón del taller |
| 5 | Copia a la sesión | `seleccionar-modalidad` persiste garantías (obligatorias ON) y opciones | Leer del producto en cada validación | La sesión debe ser autocontenida (estado TVA_Sesion) |
| 6 | UI de selección | Grid de tarjetas `"<code> - <desc>"` con enlace "Contratación" | Select simple | Reproduce `TVA_SeleccionProductoAhorro` |

## Data Flow

```text
GET /productos/?companyId&nuuma&distributionChannel
  → _catalogo_taller (cache) → apilife.product_list → {products:[…]}
GET /catalogos/<nombre>/ → fixtures/catalogos/<nombre>.json → {valores:[{codigo,descripcion}]}

POST acciones/seleccionar-modalidad {productCode}
  → seleccionar_modalidad.ejecutar → estado[codigoProducto/garantias/ventaInformada.opcionesInversion]
  → siguiente_pantalla → respuesta con botones
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/services/connectors/apilife.py` | Modify | `_PRODUCTOS_DEV`, `_catalogo_dev` con garantías/periodicidades/primas/opciones UL |
| `tva-backend/sources/apps/tva/views/productos.py` | Modify | `_catalogo_taller` con caché por (companyId, nuuma, canal) |
| `tva-backend/sources/apps/tva/views/catalogos.py` | Create | `CatalogosView` sirviendo JSON estático + 404 |
| `tva-backend/sources/apps/tva/fixtures/catalogos/*.json` | Create | 12 catálogos estáticos |
| `tva-backend/sources/apps/tva/operators/seleccionar_modalidad.py` | Modify | Copia producto → estado |
| `tva-frontend/src/app/pages/sesion/pantallas/seleccion-producto-ahorro.container.ts` | Modify | Grid de tarjetas + texto de catálogo vacío |
| `tva-frontend/libs/core/src/lib/data/repositories/*-http.repository.ts (+ ports/*-repository.port.ts)` | Modify | `productos(params)`, `catalogo(nombre)` |

## Interfaces / Contracts

```python
# apilife.py
def product_list(self, company_id=None, product_type_code=None, nuuma=None, distribution_channel=None) -> dict:
    # {"products": [{code, commercialProductCode, commercialProductDesc, unitLinkedInd,
    #   garantias, periodicidades, primaMinima, primaMaxima, opcionesInversion, requiereAsegurado}]}
```

```typescript
interface Producto {
  code?: string;
  commercialProductCode: string;
  commercialProductDesc: string;
  unitLinkedInd?: boolean;
  garantias?: { codigo: string; descripcion: string; obligatoria: boolean; seleccionada?: boolean }[];
  periodicidades?: string[];
  primaMinima?: number; primaMaxima?: number;
  opcionesInversion?: { investmentPreferenceCode: string; descripcion: string; seleccionada?: boolean }[];
  requiereAsegurado?: boolean;
}

catalogo(nombre: string): Observable<{ valores: { codigo: string; descripcion: string }[] }>
```
