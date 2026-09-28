# 01 — Guía corporativa de buenas prácticas Angular (aplicada a TVA)

Reglas aplicadas en `refactor(tva-frontend)` sobre `src/app` y `src/app/core`.

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
  centralizados en factories de `src/app/core/application/forms/`
  (`crearFormulariosTomador`, `crearFormulariosSolicitud`,
  `crearFormularioInicio`, `crearGrupoInversion`). Sin `ngModel` ad-hoc.
- **Sin lógica de negocio en plantillas**: se precalcula con `computed()`/
  `signal()` (`validez`, `valor`, `requierePrestaciones`, `esTomador`).
- **Sin manipulación DOM directa**: el único caso es la carga del script de
  Appian Embedded en `src/app/core/infra/appian/appian-embed-script.service.ts`
  (capa infra, justificado: es un web component externo; usa `DOCUMENT` y
  `MutationObserver` dentro del diálogo, no en componentes).
- **Estilos**: colores/tipografía/espaciados centralizados como variables CSS
  (`--tva-*`, `--mat-sys-*`) en `src/styles/_tokens.scss` + clases globales en
  los partials de `src/styles/` (`_layout`, `_forms`, `_tables`, `_utilities`)
  importados por `styles.scss`; los `.scss` de componente solo contienen
  reglas realmente locales (los triviales se eliminaron).
- **Angular Material**: se extiende Material; los `<input>` nativos de las
  tablas pasaron a `matInput` en `mat-form-field appearance="outline"
  subscriptSizing="dynamic"`.
- **`MATERIAL` compartido**: los componentes que importan ≥3 módulos Material
  usan `imports: [...MATERIAL, …]` con `MATERIAL` de
  `src/app/shared/ui/material.ts`; los de 1–2 módulos los importan directos.
- **Visibilidad**: miembros usados solo por la plantilla → `protected`;
  internos → `private`; `public` solo en `@Input`/`@Output`/`model`/`signals`
  de entrada y miembros accedidos desde specs.
- **Constantes**: literales de presentación (opciones de selectos, sets de
  botones, pasos de miga) en `*.const.ts` junto al componente, o en
  `core/domain` cuando son compartidos (`PERIODICIDAD_RENTA_*`).
- **Templates sin warnings**: 0 diagnósticos extendidos NG8102/NG8107 en el
  build — `??`/`?.` eliminados donde el tipo ya es no-nulo; los índices de
  `Record` se sirven con helpers tipados (`catalogo()`, `seccionValida()`).
- Signals, standalone, OnPush, `inject()`, control flow `@if/@for/@switch`,
  `host:{}`, suscripciones con `toSignal`/`takeUntilDestroyed`.

## Justificaciones de tamaño

- `captura-datos-solicitud.container.ts` (234): coordinador de 9 secciones,
  lógica de validar-seccion/selección de opciones; no es un componente visual.
- `tomador-base.ts` (213): directiva base compartida, solo lógica (sin plantilla).
- `tomador-form.component.html` (196): dos cajas, 5 secciones + requisitos;
  dividirlo más obligaría a prop-drilling de 6 FormGroups.
- `sesion.model.ts` (201): modelo de dominio, puras interfaces.
- `inicio.page.ts` (161): orquestación del formulario de utilidades + payload.

## Conteo de líneas tras el refactor (ts | html | scss)

| Fichero | ts | html | scss |
|---|---|---|---|
| shared/ui/feedback/appian-task-dialog.component | 126 | 33 | 31 |
| shared/ui/feedback/avisos.component | 37 | 6 | 31 |
| shared/ui/layout/botonera.component | 50 | 51 | 41 |
| shared/ui/layout/cabecera.component | 18 | 17 | 41 |
| shared/ui/contenedores/caja.component | 15 | 6 | 11 |
| shared/ui/formularios/campo-select.component | 22 | 11 | - |
| shared/ui/formularios/campo-texto.component | 18 | 7 | - |
| shared/ui/feedback/confirm-dialog.component | 17 | 6 | - |
| shared/ui/layout/migas-de-pan.component | 50 | 17 | 43 |
| shared/ui/contenedores/seccion.component | 29 | 19 | 42 |
| shared/ui/formularios/campo-lectura.component | 13 | 4 | 13 |
| app.component | 10 | 1 | - |
| pages/login/login.page | 27 | 32 | 34 |
| pages/inicio/inicio.page | 161 | 135 | 11 |
| pages/admin/admin.page | 84 | 51 | 31 |
| pages/admin/admin-panel.component | 17 | 50 | 12 |
| pages/sesion/sesion.page | 73 | 57 | - |
| pantallas/solicitud/captura-datos-solicitud.container | 234 | 68 | - |
| pantallas/solicitud/datos-productores.component | 22 | 24 | - |
| pantallas/solicitud/datos-operacion.component | 57 | 79 | - |
| pantallas/solicitud/opciones-inversion.component | 46 | 70 | - |
| pantallas/solicitud/garantias.component | 28 | 16 | - |
| pantallas/solicitud/domiciliaciones.component | 43 | 17 | - |
| pantallas/solicitud/captura-ampliada.component | 69 | 91 | - |
| pantallas/tomador/tomador-form.component | 51 | 196 | 51 |
| pantallas/tomador/tomador-base (directive) | 213 | - | - |
| pantallas/tomador/captura-tomador1.container | 16 | 11 | - |
| pantallas/tomador/captura-tomador2.container | 16 | 11 | - |
| pantallas/cierre/fin.container | 23 | 5 | - |
| pantallas/ahorro/modalidad-campania.container | 26 | 9 | - |
| pantallas/rentas/r2c-captura.container | 73 | 34 | - |
| pantallas/rentas/r2c-precios.container | 71 | 53 | 33 |
| pantallas/cierre/resumen-contratacion.container | 161 | 122 | 80 |
| pantallas/cierre/resultado-firma.container | 24 | 7 | - |
| pantallas/ahorro/seguros-ahorro.container | 53 | 47 | - |
| pantallas/ahorro/seleccion-producto-ahorro.container | 50 | 13 | - |
| pantallas/avisos/sin-perfil.container | 11 | 4 | - |
| pantallas/avisos/sistema-cerrado.container | 11 | 4 | - |
| pantallas/avisos/solo-avisos.container | 11 | 4 | - |
