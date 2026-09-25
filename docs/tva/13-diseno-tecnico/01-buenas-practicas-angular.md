# 01 — Guía corporativa de buenas prácticas Angular (aplicada a TVA)

Reglas aplicadas en `refactor(tva-frontend)` sobre `src/app` y `libs/core`.

## Reglas

- **Ficheros separados**: ningún componente lleva `template:`/`styles:` inline;
  cada uno tiene `<nombre>.component.html` / `.scss` (o `.container.*`,
  `.page.*`). Los antiguos `TOMADOR_TEMPLATE`/`TOMADOR_STYLES` compartidos se
  sustituyeron por el componente presentacional `app-tomador-form`, que usan
  `captura-tomador1` y `captura-tomador2`.
- **Tamaños**: clase ≤150 líneas (máx. 300), plantilla ≤100 (máx. 200),
  método ≤20 (máx. 50), ≤3–5 parámetros, una responsabilidad por componente.
  `captura-datos-solicitud` se dividió en 6 presentacionales
  (`datos-productores`, `datos-operacion`, `opciones-inversion`, `garantias`,
  `domiciliaciones`, `captura-ampliada`) con `input()`/`output()`/`model()`;
  el contenedor solo coordina estado y llamadas `validar-seccion`.
- **Reactive Forms**: `FormGroup`/`FormBuilder` tipados con validadores
  centralizados en factories de `libs/core/src/lib/application/forms/`
  (`crearFormulariosTomador`, `crearFormulariosSolicitud`,
  `crearFormularioInicio`, `crearGrupoInversion`). Sin `ngModel` ad-hoc.
- **Sin lógica de negocio en plantillas**: se precalcula con `computed()`/
  `signal()` (`validez`, `valor`, `requierePrestaciones`, `esTomador`).
- **Sin manipulación DOM directa**: el único caso es la carga del script de
  Appian Embedded en `libs/core/src/lib/infra/appian/appian-embed-script.service.ts`
  (capa infra, justificado: es un web component externo; usa `DOCUMENT` y
  `MutationObserver` dentro del diálogo, no en componentes).
- **Estilos**: colores/tipografía/espaciados centralizados como variables CSS
  (`--tva-*`, `--mat-sys-*`) en `src/styles.scss` + clases globales
  (`.pagina`, `.formulario`, `.tabla`, `.chips-ruta`); los `.scss` de
  componente solo contienen reglas específicas.
- **Angular Material**: se extiende Material; los `<input>` nativos de las
  tablas pasaron a `matInput` en `mat-form-field appearance="outline"
  subscriptSizing="dynamic"`.
- Signals, standalone, OnPush, `inject()`, control flow `@if/@for/@switch`,
  `host:{}`, suscripciones con `toSignal`/`takeUntilDestroyed`.

## Justificaciones de tamaño

- `captura-datos-solicitud.container.ts` (266): coordinador de 9 secciones,
  lógica de validar-seccion/selección de opciones; no es un componente visual.
- `tomador-base.ts` (213): directiva base compartida, solo lógica (sin plantilla).
- `tomador-form.component.html` (196): dos cajas, 5 secciones + requisitos;
  dividirlo más obligaría a prop-drilling de 6 FormGroups.
- `sesion.model.ts` (152): modelo de dominio, puras interfaces.
- `inicio.page.ts` (175): orquestación del formulario de utilidades + payload.

## Conteo de líneas tras el refactor (ts | html | scss)

| Fichero | ts | html | scss |
|---|---|---|---|
| ui/appian-task-dialog.component | 126 | 33 | 31 |
| ui/avisos.component | 37 | 6 | 31 |
| ui/botonera.component | 52 | 51 | 41 |
| ui/cabecera.component | 20 | 17 | 41 |
| ui/caja.component | 15 | 6 | 11 |
| ui/campo-select.component | 23 | 11 | 3 |
| ui/campo-texto.component | 19 | 7 | 3 |
| ui/confirm-dialog.component | 18 | 6 | 3 |
| ui/migas-de-pan.component | 50 | 17 | 43 |
| ui/seccion.component | 29 | 19 | 42 |
| app.component | 10 | 1 | - |
| pages/login/login.page | 34 | 32 | 34 |
| pages/inicio/inicio.page | 175 | 133 | 42 |
| pages/admin/admin.page | 84 | 51 | 31 |
| pages/admin/admin-panel.component | 17 | 50 | 12 |
| pages/sesion/sesion.page | 101 | 57 | 9 |
| pantallas/captura-datos-solicitud.container | 266 | 68 | - |
| pantallas/solicitud/datos-productores.component | 22 | 24 | - |
| pantallas/solicitud/datos-operacion.component | 54 | 79 | - |
| pantallas/solicitud/opciones-inversion.component | 49 | 70 | 11 |
| pantallas/solicitud/garantias.component | 28 | 16 | - |
| pantallas/solicitud/domiciliaciones.component | 43 | 17 | - |
| pantallas/solicitud/captura-ampliada.component | 70 | 91 | - |
| pantallas/tomador-form.component | 52 | 196 | 51 |
| pantallas/tomador-base (directive) | 213 | - | - |
| pantallas/captura-tomador1.container | 16 | 11 | - |
| pantallas/captura-tomador2.container | 16 | 11 | - |
| pantallas/fin.container | 23 | 5 | - |
| pantallas/modalidad-campania.container | 31 | 9 | 4 |
| pantallas/r2c-captura.container | 80 | 34 | 10 |
| pantallas/r2c-precios.container | 20 | 6 | 3 |
| pantallas/resumen-contratacion.container | 41 | 20 | 8 |
| pantallas/resultado-firma.container | 24 | 7 | - |
| pantallas/seguros-ahorro.container | 36 | 12 | - |
| pantallas/seleccion-producto-ahorro.container | 51 | 13 | 8 |
| pantallas/sin-perfil.container | 11 | 4 | - |
| pantallas/sistema-cerrado.container | 11 | 4 | - |
| pantallas/solo-avisos.container | 11 | 4 | - |
