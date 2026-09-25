# Design: Rentas (R2C)

## Technical Approach

El flujo R2C (simulador de rentas) tiene su propia máquina: `R2C_CAPTURA`
(captura con al menos 2 tomadores: DNI, fecha de nacimiento y % de participación,
importe total de prima y periodicidad de la renta) → `R2C_PRECIOS` (resultado de
`individualAnnuitySimulation`) → `contratar`/`contratar-rentas` →
`RESUMEN_CONTRATACION`. `rentas.recalcular` llama al endpoint
`individualAnnuitySimulation` de API Life y guarda la respuesta en
`estado.rentas.recalcular` (habilita Recalcular); `rentas.contratar` llama a
`individualAnnuityInsuranceApplication` y avanza a RESUMEN. La navegación es la
misma `siguiente_pantalla`/`pantalla_anterior` (R2C_PRECIOS→R2C_CAPTURA el único
"atrás" del flujo).

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Operador separado | `operators/rentas.py` con `recalcular`/`contratar` | Mezclar con guardar_solicitud | Los endpoints de rentas son distintos (annuitySimulation/application) |
| 2 | Acciones | `recalcular-rentas`/`contratar-rentas` validados por modalidad `R2C` | Permitir en cualquier modo | El dispatcher rechaza estas acciones fuera de R2C |
| 3 | Resultado de simulación | Guardado en `estado.rentas` | Campo propio del modelo | El estado JSON es el único contrato de datos |
| 4 | Contratar R2C | Reutiliza el botón `contratar` visible en R2C_PRECIOS (dispatch a `rentas.contratar`) | Botón distinto | En Appian es el mismo PM Contratar con la regla por modalidad |
| 5 | Atrás | Solo R2C_PRECIOS→R2C_CAPTURA | Atrás genérico | Regla Appian: solo ese retroceso + Administración |
| 6 | Captura | `siguiente` en R2C_CAPTURA exige ≥2 tomadores | Un tomador opcional | Validación `TVA_SimuladorRentas_Captura_Validacion` |

## Data Flow

```text
R2C_CAPTURA: botonera siguiente → siguiente → merge datos → siguiente_pantalla → R2C_PRECIOS
R2C_PRECIOS: recalcular → individualAnnuitySimulation → estado.rentas.recalcular
R2C_PRECIOS: contratar → rentas.contratar → individualAnnuityInsuranceApplication → RESUMEN_CONTRATACION
Atrás → pantalla_anterior → R2C_CAPTURA
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/rentas.py` | Modify | `recalcular`, `contratar` contra API Life annuity endpoints |
| `tva-backend/sources/apps/tva/operators/validaciones.py` | Modify | `errores_rentas_captura` (`TVA_SimuladorRentas_Captura_Validacion`) |
| `tva-backend/sources/apps/tva/operators/secciones.py` | Modify | Caja `R2C_CAPTURA` en `escribir_seccion`/`errores_seccion` |
| `tva-backend/sources/apps/tva/operators/dispatcher.py` | Modify | Dispatch por modalidad + validación R2C |
| `tva-backend/sources/apps/tva/operators/maquina_pantallas.py` | Modify | R2C_CAPTURA→R2C_PRECIOS, R2C_PRECIOS→R2C_CAPTURA en `pantalla_anterior` |
| `tva-backend/sources/apps/tva/operators/botonera.py` | Modify | `atras`/`recalcular`/`contratar` visibles en R2C_PRECIOS |
| `tva-frontend/src/app/pages/sesion/pantallas/r2c-captura.container.ts` | Modify | Form captura → `datosPendientes` |
| `tva-frontend/src/app/pages/sesion/pantallas/r2c-precios.container.ts` | Modify | Muestra resultado; botones desde botonera |

## Interfaces / Contracts

```python
# operators/rentas.py
def recalcular(sesion: Sesion, datos: dict) -> dict:
    """individualAnnuitySimulation → estado['rentas']['recalcular'] = response"""
def contratar(sesion: Sesion, datos: dict) -> dict:
    """individualAnnuityInsuranceApplication → pantalla RESUMEN_CONTRATACION"""

# estado.rentas
{ "importeTotalPrima": 6000, "periodicidadRenta": "MENSUAL",
  "recalcular": { /* response de la simulación */ } }

# validaciones.py
def errores_rentas_captura(rentas: dict, tomadores: list) -> list[str]: ...

# validar-seccion caja R2C_CAPTURA
{ "caja": "R2C_CAPTURA", "seccion": "captura",
  "datos": {"rentas": {...}, "tomadores": [{"documentId": "…", "fechaNacimiento": "…", "participationPerc": 50}] } }
```
