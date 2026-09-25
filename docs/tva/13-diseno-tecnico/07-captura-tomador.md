# Design: Captura del tomador

## Technical Approach

La pantalla Tomador 1/2 replica `interfaces/TVA_CapturaTomador_*`: una caja con
secciones plegables (Datos personales, Domicilio habitual, Medios de contacto,
FATCA/CRS, Representante legal) y un panel derecho de requisitos (RGPD, DNI
digitalizado, test de conveniencia — deshabilitados con tooltip
"Pendiente de integración"). Cada Continuar de sección postea
`validar-seccion {caja, seccion, datos}`: el backend escribe en
`tomadores[i][seccion]`, valida con los textos exactos §12.4.4, marca
`datosValidos` y sustituye los avisos de sección. La acción `continuar-tomador`
revalida toda la caja (y la de representante legal si existe) y navega con
`siguiente_pantalla` (TOMADOR2 si ≥2 tomadores, si no SOLICITUD). En VIA añade el
aviso INFO del importe máximo (7.500 €). `perfil_cliente.py` queda para el
perfilado real (servicio pendiente).

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Validación | Por sección en backend con textos §12.4.4 exactos | Form validators en frontend | La regla de validación es una sola fuente Appian; el front solo refleja errores |
| 2 | Escritura | `validar-seccion` escribe en `tomadores[i][seccion]` antes de validar | Guardar todo en continuar | Persistir cada sección permite retomar la sesión |
| 3 | Continuar | `continuar-tomador` revalida y navega (sin merge de datos) | Reenviar datos en continuar | En Appian la sección ya está persistida al pulsar Continuar de la caja |
| 4 | Tomador 1 y 2 | Mismo container/directive `TomadorBase` con `cajaId`/`indiceTomador` | Dos componentes duplicados | Misma interfaz, solo cambia el índice de la caja |
| 5 | Requisitos | Panel informativo desde `datosGestionParticipante`/`perfilCliente` con botones disabled | Ocultar el panel | Marca lo que falta (pop-ups externos) sin romper el layout |
| 6 | Catálogos | Selects desde `/catalogos/` | Listas en el componente | Mismos valores que el backend y fácil ampliación |

## Data Flow

```text
SeccionComponent "Continuar" → store.validarSeccion(caja, seccion, datos)
  → POST acciones/validar-seccion → secciones.ejecutar
    → escribir_seccion (tomadores[i] / estado raíz)
    → errores_seccion (validadores errores_*)
    → set_seccion_valida + _set_avisos_seccion
  → respuesta → store → seccionValida() / expandida() → plegado

Botonera "Continuar" → ejecutar('continuar-tomador')
  → revalidar_caja(tomador) (+ rep legal) → siguiente_pantalla (+ INFO importe máximo VIA)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/tva/operators/secciones.py` | Create | `escribir_seccion`, `errores_seccion`, `ejecutar`, `revalidar_caja` |
| `tva-backend/sources/apps/tva/operators/continuar_tomador.py` | Modify | Revalida cajas tomador y avanza; INFO importe máximo VIA |
| `tva-backend/sources/apps/tva/operators/validaciones.py` | Modify | `errores_datos_personales`, `errores_medios_contacto`, `errores_domicilio_habitual`, `errores_participante`, `errores_direccion_correspondencia` |
| `tva-frontend/src/app/pages/sesion/pantallas/tomador-base.ts` | Modify | `TomadorBase` con formularios por sección + catálogos + requisitos |
| `tva-frontend/src/app/pages/sesion/pantallas/captura-tomador1.container.ts` | Modify | Template compartido `TOMADOR_TEMPLATE` |
| `tva-frontend/src/app/pages/sesion/pantallas/captura-tomador2.container.ts` | Modify | Mismo template con `cajaId='CAPTURA_DATOS_TOMADOR2'` |
| `tva-frontend/src/app/ui/seccion.component.ts` | Create | Plegado/validez/avisos de sección + botón Continuar |
| `tva-frontend/src/app/ui/caja.component.ts` | Modify | Contenedor mat-expansion-panel |

## Interfaces / Contracts

```python
# operators/secciones.py
def escribir_seccion(estado: dict, caja_id: str, seccion_id: str, datos: dict) -> dict: ...
def errores_seccion(estado: dict, caja_id: str, seccion_id: str) -> list[str]: ...
def ejecutar(sesion: Sesion, datos: dict, roles: list[str] | None = None) -> dict: ...
def revalidar_caja(sesion: Sesion, caja_id: str) -> list[str]: ...

# payload POST validar-seccion
{ "caja": "CAPTURA_DATOS_TOMADOR1", "seccion": "datosPersonales", "datos": { "documentId": "…", "nombre": "…" } }
```

```typescript
// tomador-base.ts
abstract class TomadorBase {
  abstract readonly cajaId: string;
  abstract readonly indiceTomador: number;
  datosPersonales: FormGroup; domicilioHabitual: FormGroup;
  mediosContacto: FormGroup; correo: FormGroup; fatcaCrs: FormGroup;
  legalRepresentative: FormGroup; catalogos: Signal<Record<string, Opcion[]>>;
  continuar(seccionId: string, form: FormGroup): void;
  seccionValida(id: string): boolean;
}
```
