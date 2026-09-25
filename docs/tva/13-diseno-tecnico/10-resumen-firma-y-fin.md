# Design: Resumen, firma y fin

## Technical Approach

`RESUMEN_CONTRATACION` muestra los datos consolidados (cajas de resumen y JSON del
estado en la versión mock) y la selección del tipo de firma (`DIGITAL`/`MANUSCRITA`).
La acción `firmar` (lanzada desde la caja de firma, no desde la botonera — botón
oculto `showWhen: false`) simula el alta en API Life (`savingInsuranceApplication` /
`annuityInsuranceApplication` según modalidad), marca el resultado y avanza a
`RESULTADO_FIRMA`; de ahí `siguiente` → `FIN` (sesión cerrada, `abierta=false`).
`GET /sesiones/<clave>/documentos/<tipo>/` sirve los documentos mock de la sesión.
`cancelar` en cualquier pantalla lleva a FIN limpiando avisos.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Firma | Simulada con llamada al endpoint de alta + estado `resultadoFirma` | Integración con servicio de firma | Los contratos de firma reales no están disponibles |
| 2 | Botón Firmar | `visible: false` en la botonera; acción desde la caja de firma | Botón de botonera | En Appian `firmar` está oculto: la firma se dispara dentro de la caja |
| 3 | Fin | `FIN` + `abierta=false` | Mantener abierta | Equivalente al fin de proceso Appian |
| 4 | Tipo de firma | Campo `tipoFirma` en el payload de `firmar` | Enum cerrado de flags | Los flags `TVA_FLAG_FIRMA_*` aún pendientes; se admite el tipo como dato |
| 5 | Documentos | Endpoint `documentos/<tipo>/` con fixtures/mock | Generación real | Punto de swap para los documentos reales de API Life |
| 6 | Resumen | Cajas de resumen + JSON del estado (modo demo) | Vista definitiva | Muestra la estructura TVA_Sesion tal cual para depurar |

## Data Flow

```text
Resumen → firmar {tipoFirma}
  → firmar.ejecutar → API Life alta → estado.resultadoFirma
  → RESULTADO_FIRMA → siguiente → FIN (abierta=false)

GET /sesiones/<clave>/documentos/<tipo>/
  → DocumentosView.get → documento mock por tipo
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/firmar.py` | Modify | `ejecutar` alta + resultadoFirma + avance |
| `tva-backend/sources/apps/tva/views/documentos.py` | Modify | `DocumentosView` por tipo |
| `tva-frontend/src/app/pages/sesion/pantallas/resumen-contratacion.container.ts` | Modify | Cajas resumen + tipo firma → `datosPendientes` |
| `tva-frontend/src/app/pages/sesion/pantallas/resultado-firma.container.ts` | Modify | Resultado + siguiente |
| `tva-frontend/src/app/pages/sesion/pantallas/fin.container.ts` | Modify | Pantalla fin |

## Interfaces / Contracts

```python
# operators/firmar.py
def ejecutar(sesion: Sesion, datos: dict) -> dict:
    """Firma simulada: {tipoFirma} → resultadoFirma → RESULTADO_FIRMA"""
```

```typescript
// payload firmar
{ tipoFirma: 'DIGITAL' | 'MANUSCRITA' }
// GET documentos
{ tipo: string; documento: Record<string, unknown> }
```
