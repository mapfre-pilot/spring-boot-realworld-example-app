# Design: Captura de la solicitud

## Technical Approach

La pantalla Solicitud replica la estructura Appian: caja Datos de productores
(oficina, productor, % comisión máxima/deseada, toggles planificada/extraordinaria),
caja Datos del seguro con secciones operación (fecha efecto, tipo de duración,
primas única/periódica, periodicidad del producto, día de cobro, revalorización,
reinversión, minusvalía), opciones de inversión (tabla con reparto y suma en
directo; primera selección auto-rellena el importe de la prima), garantías
(obligatorias marcadas y deshabilitadas) y domiciliaciones (IBAN recibos y
prestaciones si `requierePrestaciones`). El toggle "Ampliar captura" revela
datos de contacto, asegurado, beneficiarios y notas. Cada Continuar postea
`validar-seccion` con los textos §12.4.4. `guardar-solicitud` revalida las
cajas base y guarda la propuesta en API Life; `doc-precontractual` y `contratar`
usan las reglas de habilitado de la botonera.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Validación | `validar-seccion` por sección con validadores `errores_*` | Form validators frontend | Una sola fuente de verdad Appian |
| 2 | Campos del producto | `periodicidades`, `primaMinima/Maxima`, `garantias`, `opcionesInversion` leídos del producto en estado | Listas fijas | Dependen del producto seleccionado |
| 3 | Opciones inversión | Reparto en UI con suma vs `datosOperacion.primaUnica`; validación backend de la suma | Validar solo en front | La regla Appian exige coincidencia con la operación |
| 4 | Guardar y volver | `guardar-solicitud` revalida productores+seguro antes de `save_proposal` | Guardar sin validar | Mantiene la validez de las cajas aunque se edite sin validar-seccion |
| 5 | Doc. precontractual | Mock `individual_documents` → `documentosPrecontractuales` + flag en tomador | Integración real | La integración de documentos requiere API Life real |
| 6 | Breadcrumbs | Migas "Tomador 1 › Solicitud ��� Resumen" + producto `"<code> - <desc>"` en cabecera | Sin contexto | Appian muestra la posición dentro del flujo |

## Data Flow

```text
SeccionComponent → store.validarSeccion(caja, seccion, datos)
  → escribir_seccion (datosOperacion / ventaInformada.opcionesInversion /
    garantias / domiciliaciones / datosProductores / datosContacto / asegurado /
    beneficiarios / notas)
  → errores_seccion → set_seccion_valida + avisos

Botonera "Guardar y volver" → guardar-solicitud → revalidar productores+seguro
  → save_proposal → aviso OK/ERROR
Botonera "Doc. Precontractual" → doc-precontractual → documentosPrecontractuales
Botonera "Contratar" → condiciones_contratar OK → RESUMEN_CONTRATACION
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/secciones.py` | Modify | Paths de escritura de las secciones de solicitud |
| `tva-backend/sources/apps/tva/operators/validaciones.py` | Modify | `errores_datos_operacion`, `errores_opciones_inversion`, `errores_domiciliaciones`, `errores_beneficiarios`, `errores_notas`, `errores_productores`, `iban_valido` |
| `tva-backend/sources/apps/tva/operators/guardar_solicitud.py` | Modify | Revalida cajas antes de `save_proposal` |
| `tva-backend/sources/apps/tva/operators/verificar_productores.py` | Modify | Wrapper `verify_producers` |
| `tva-backend/sources/apps/tva/operators/validar_reinversion.py` | Modify | Wrapper `validate_reinvestment` |
| `tva-frontend/src/app/pages/sesion/pantallas/captura-datos-solicitud.container.ts` | Modify | Cajas+secciones completas + ampliar captura |
| `tva-backend/sources/apps/tva/operators/dispatcher.py` | Modify | `_accion_doc_precontractual`, `_accion_contratar` |

## Interfaces / Contracts

```python
# operators/validaciones.py (textos §12.4.4)
def errores_datos_operacion(op: dict, producto: dict | None = None) -> list[str]: ...
def errores_opciones_inversion(opciones: list, op: dict | None = None, producto: dict | None = None) -> list[str]: ...
def errores_domiciliaciones(dom: dict) -> list[str]: ...
def errores_beneficiarios(b: dict) -> list[str]: ...
def errores_notas(notas: list) -> list[str]: ...
def errores_productores(prod: dict) -> list[str]: ...
def iban_valido(iban: str) -> bool: ...

# datosOperacion (path de escritura: estado["datosOperacion"])
{ "fechaEfecto": "2025-01-01", "tipoDuracion": "ANIOS", "duracion": 5,
  "primaUnica": 1000, "aportacionPeriodica": None, "periodicidad": None, "diaCobro": None,
  "revalorizacion": false, "reinversion": {"activa": false}, "gradoMinusvalia": null }
```
