# Design: Rentas (R2C)

## Technical Approach

El flujo R2C (simulador de rentas) tiene su propia máquina: `R2C_CAPTURA`
(captura con exactamente 2 tomadores: DNI, fecha de nacimiento y % de
participación, importe total de prima y periodicidad de la renta) →
`R2C_PRECIOS` → `contratar` → `RESUMEN_CONTRATACION`.

`R2C_PRECIOS` replica la interfaz Appian `TVA_R2C_SeccionPrecios` +
`TVA_OpcionImporteRenta`: al entrar (SIGUIENTE en R2C_CAPTURA, tras
`errores_rentas_captura`) `rentas.simular` llama a
`individualAnnuitySimulation` **una vez por cada opción de capital
decreciente** (`deathCapitalOptions`, mock: 50 % y 100 %) y guarda las
respuestas en `estado.rentas.simulaciones` (shape
`{operationResult, projectData:{premiumAmn, incomeAmn, expectedReturnPerc}}`).
La acción `actualizar-rentas` (solo válida en R2C_PRECIOS) recibe
`idxSimulacionSeleccionada` — selecciona la simulación y fija
`rentaObjetivo = simulaciones[idx].incomeAmn` — u `rentaObjetivo` — marca
`recalcular = true` (Appian: al cambiar la renta objetivo hay que recalcular
antes de contratar). `rentas.recalcular` exige selección + `recalcular=true`,
vuelve a simular pasando `incomeAmn = rentaObjetivo` y fija
`importeTotalPrima = simulaciones[idx].premiumAmn`. `rentas.contratar` exige
selección y `recalcular=false` (avisos "Seleccione una simulación" / "Debe
recalcular antes de contratar"), llama a
`individualAnnuityInsuranceApplication` y avanza a RESUMEN, que tolera la
sesión R2C (prima, renta objetivo, periodicidad, % capital decreciente y
tomadores DNI/%). En el frontend el estado se tipa como `RentasEstado`
(`importeTotalPrima`, `periodicidadRenta`, `deathCapitalOptions`,
`simulaciones: SimulacionRenta[]`, `idxSimulacionSeleccionada`,
`rentaObjetivo`, `recalcular`) en `core/domain/sesion.model.ts`, y la botonera
habilita Recalcular solo con selección + `recalcular`, y Contratar solo con
selección + `!recalcular`.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Operador separado | `operators/rentas.py` con `recalcular`/`contratar` | Mezclar con guardar_solicitud | Los endpoints de rentas son distintos (annuitySimulation/application) |
| 2 | Acciones | `recalcular-rentas`/`contratar-rentas` validados por modalidad `R2C` | Permitir en cualquier modo | El dispatcher rechaza estas acciones fuera de R2C |
| 3 | Simulaciones | Una por `deathCapitalOption` en `estado.rentas.simulaciones` | Una sola simulación | Appian muestra una tarjeta por opción de capital decreciente |
| 4 | Selección/recalculo | Acción `actualizar-rentas` con `idxSimulacionSeleccionada` o `rentaObjetivo`; flag `recalcular` | Recalcular en cada cambio | Replica `TVA_OpcionImporteRenta`/`TVA_R2C_SeccionPrecios` (recalcular solo tras editar la renta) |
| 5 | Contratar R2C | Reutiliza el botón `contratar` visible en R2C_PRECIOS (dispatch a `rentas.contratar`) | Botón distinto | En Appian es el mismo PM Contratar con la regla por modalidad |
| 6 | Atrás | Solo R2C_PRECIOS→R2C_CAPTURA | Atrás genérico | Regla Appian: solo ese retroceso + Administración |
| 7 | Captura | `siguiente` en R2C_CAPTURA exige 2 tomadores; inicio R2C fuerza `numTomadores=2` (control deshabilitado) | Un tomador opcional | Validación `TVA_SimuladorRentas_Captura_Validacion` ("Son obligatorios dos tomadores") |

## Data Flow

```text
R2C_CAPTURA: botonera siguiente → siguiente → merge datos → errores_rentas_captura
  → rentas.simular (una llamada por deathCapitalOption) → R2C_PRECIOS
R2C_PRECIOS: actualizar-rentas {idxSimulacionSeleccionada} → selección + rentaObjetivo=incomeAmn
R2C_PRECIOS: actualizar-rentas {rentaObjetivo} → recalcular=true (Recalcular se habilita)
R2C_PRECIOS: recalcular-rentas → simulaciones con incomeAmn → importeTotalPrima=premiumAmn
R2C_PRECIOS: contratar → rentas.contratar → individualAnnuityInsuranceApplication → RESUMEN_CONTRATACION
Atrás → pantalla_anterior → R2C_CAPTURA
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/rentas.py` | Modify | `simular`, `actualizar`, `recalcular`, `contratar` contra API Life annuity endpoints; `deathCapitalOptions` mock 50/100 |
| `tva-backend/sources/apps/tva/operators/validaciones.py` | Modify | `errores_rentas_captura` (`TVA_SimuladorRentas_Captura_Validacion`) |
| `tva-backend/sources/apps/tva/operators/secciones.py` | Modify | Caja `R2C_CAPTURA` en `escribir_seccion`/`errores_seccion` |
| `tva-backend/sources/apps/tva/operators/dispatcher.py` | Modify | Dispatch por modalidad + validación R2C |
| `tva-backend/sources/apps/tva/operators/maquina_pantallas.py` | Modify | R2C_CAPTURA→R2C_PRECIOS, R2C_PRECIOS→R2C_CAPTURA en `pantalla_anterior` |
| `tva-backend/sources/apps/tva/operators/botonera.py` | Modify | `atras`/`recalcular`/`contratar` visibles en R2C_PRECIOS |
| `tva-frontend/src/app/pages/sesion/pantallas/rentas/r2c-captura.container.ts` | Modify | Form captura → `datosPendientes` |
| `tva-frontend/src/app/pages/sesion/pantallas/rentas/r2c-precios.container.ts` | Modify | Dos tarjetas de opción (radio → `actualizar-rentas`), tarjeta Capital decreciente + campo renta → `{rentaObjetivo}`; `RentasEstado`/`SimulacionRenta` en core |
| `tva-frontend/src/app/pages/inicio/inicio.page.ts` | Modify | R2C fuerza `numTomadores=2` y deshabilita el control |

## Interfaces / Contracts

```python
# operators/rentas.py — estado.rentas: RentasEstado
{ "importeTotalPrima": 50000, "periodicidadRenta": "MENSUAL",
  "deathCapitalOptions": [{"deathCapitalPremiumPerc": 50.0}, {"deathCapitalPremiumPerc": 100.0}],
  "simulaciones": [
    {"operationResult": {"operationStatusCode": "01", "operationStatusDesc": "Accepted"},
     "projectData": {"premiumAmn": 50000, "incomeAmn": 1415.89, "expectedReturnPerc": 2.3}}],
  "idxSimulacionSeleccionada": 0, "rentaObjetivo": 1200.0, "recalcular": true }

def simular(sesion, datos) -> dict     # 1 llamada annuity_simulation por deathCapitalOption
def actualizar(sesion, datos) -> dict  # acción 'actualizar-rentas': idx o rentaObjetivo
def recalcular(sesion, datos) -> dict  # exige idx + recalcular; simula con incomeAmn
def contratar(sesion, datos) -> dict   # exige idx + !recalcular → annuity_insurance_application → RESUMEN

# acciones/
POST acciones/actualizar-rentas {datos:{idxSimulacionSeleccionada: 0}}
POST acciones/actualizar-rentas {datos:{rentaObjetivo: 1200}}
POST acciones/recalcular-rentas {datos:{}}

# mock annuity_simulation (determinista): factor 0.0283178 (50 %) / 0.0211634 (100 %),
# expectedReturnPerc 2.3 / 2.41; con incomeAmn → premium=income/factor; si no → income=prima*factor

# validaciones.py
def errores_rentas_captura(rentas: dict, tomadores: list) -> list[str]: ...

# validar-seccion caja R2C_CAPTURA
{ "caja": "R2C_CAPTURA", "seccion": "captura",
  "datos": {"rentas": {...}, "tomadores": [{"documentId": "…", "fechaNacimiento": "…", "participationPerc": 50}] } }
```
