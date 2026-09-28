# Arquitectura de referencia del frontend — Clean Architecture (TVA)

> Documento de referencia transversal: describe la estructura Clean
> Architecture que sigue `tva-frontend` según la guía MAPFRE "Arquitectura de
> aplicación" implementada por los generadores `@mapfre-tech/nx-angular(-esp)`.

## Capas y reglas de dependencia

Todo el código reutilizable vive en `src/app/core` (importPath
`@tva/core` → `src/app/core/index.ts` en `tsconfig.base.json`), organizada en
las capas del layout `clean` del generador corporativo. El workspace es
standalone: no hay `libs/` ni proyectos secundarios.

| Capa | Directorio | Contenido | Dependencias permitidas |
|------|-----------|-----------|--------------------------|
| **domain** | `src/app/core/domain/` | Modelos puros (`*.model.ts`), validaciones (`validaciones/documentos.ts`), utilidades (`nuuma.ts`). Sin Angular ni HTTP. | Ninguna |
| **ports** | `src/app/core/ports/` | Interfaces de repositorio + `InjectionToken` en el mismo fichero (`<nombre>-repository.port.ts`). | domain |
| **application** | `src/app/core/application/` | Casos de uso (`<nombre>.usecase.ts`, `providedIn: 'root'`, método `execute(...)`) y el store de solo estado `state/sesion.store.ts`. | domain + ports |
| **data** | `src/app/core/data/repositories/` | Implementaciones HTTP de los puertos (`<nombre>-http.repository.ts`), `inject(HttpClient)` + `EnvironmentService`. | domain + ports + infra |
| **infra** | `src/app/core/infra/` | Servicios de infraestructura: `config/environment.service.ts`, `auth/` (service, interceptor, guards), `http/api-error.interceptor.ts`, `appian/` (embed-script + `appian-popup.service.ts`). | domain |

La aplicación importa `src/app/core` siempre vía el alias `@tva/core`
(nunca rutas relativas a `../core/`). Como `core` ya vive dentro del proyecto
`tva`, el constraint `@nx/enforce-module-boundaries` en
`eslint.base.config.mjs` tiene `^@tva/core$` en `allow` (auto-import permitido).
Las reglas intra-capa (domain no importa de nadie, application solo
domain+ports) se mantienen por convención — ESLint de Nx no puede distinguir
subdirectorios dentro de un mismo proyecto.

`provideTvaCore()` (`src/app/core/core.providers.ts`) registra los 5
puertos (`{ provide: SESION_REPOSITORY, useClass: SesionHttpRepository }`, …)
y `provideHttpClient(withInterceptors([authInterceptor, errorInterceptor]))`.
`app.config.ts` lo incluye junto a `provideEnvironment` del paquete corporativo.

## Árbol resultante

```
src/app/
├── core/                 # alias @tva/core (sin libs/)
│   ├── application/      # 17 usecases + state/sesion.store.ts + forms/
│   ├── data/repositories/# sesion|inicio|catalogo|popup-appian|admin -http.repository.ts
│   ├── domain/           # sesion|inicio|admin|producto|popup|webapi-error .model.ts,
│   │                     #   validaciones/documentos.ts, nuuma.ts
│   ├── infra/            # config/, auth/, http/, appian/ (embed-script + popup service)
│   ├── ports/            # sesion|inicio|catalogo|popup-appian|admin -repository.port.ts
│   ├── core.providers.ts # provideTvaCore()
│   └── index.ts          # barrel del alias
│
├── pages/                # inicio|login|sesion|admin .page.ts (+ .page.html)
│   └── sesion/pantallas/ # un subdirectorio por familia de pantalla:
│       ├── tomador/      #   captura-tomador1/2, tomador-base, tomador-form
│       ├── solicitud/    #   captura-datos-solicitud + 6 componentes de sección
│       ├── rentas/       #   r2c-captura, r2c-precios
│       ├── ahorro/       #   seguros-ahorro, seleccion-producto-ahorro, modalidad-campania
│       ├── cierre/       #   resumen-contratacion, resultado-firma, fin
│       └── avisos/       #   sin-perfil, sistema-cerrado, solo-avisos
│
├── shared/ui/            # componentes presentacionales por responsabilidad:
│   ├── layout/           #   cabecera, migas-de-pan, botonera
│   ├── formularios/      #   campo-texto, campo-lectura, campo-select
│   ├── feedback/         #   confirm-dialog, avisos, appian-task-dialog
│   ├── contenedores/     #   caja, seccion
│   └── material.ts       #   const MATERIAL = [Mat*Module ≥3 usos]
│
└── src/styles/           # partials globales (@use desde styles.scss):
    ├── _tokens.scss      #   variables --tva-*/--mat-sys-*
    ├── _layout.scss      #   .pagina, tarjetas, tipografía, chips, botones
    ├── _forms.scss       #   .formulario grid, .campo, h4 en grid, radios
    ├── _tables.scss      #   table.tabla, .num/.numero, .suma, .celda
    └── _utilities.scss   #   .errores, .ok, .checks, .grid/.tarjeta, .mensaje
```

## Generadores usados (comandos exactos)

```bash
# librería con layout clean
pnpm nx g @mapfre-tech/nx-angular-esp:library core --layout clean \
  --directory src/app/core --importPath @tva/core
# caso de uso
pnpm nx g @mapfre-tech/nx-angular-esp:usecase <nombre> --project core
# puerto (interface + InjectionToken en el mismo fichero)
pnpm nx g @mapfre-tech/nx-angular-esp:port <nombre> --project core
# repositorio HTTP (genera <nombre>.repository.ts|spec.ts; borrar el test() de ejemplo)
pnpm nx g @mapfre-tech/nx-angular-esp:repository <nombre>-http --project core
# página de la app
pnpm nx g @mapfre-tech/nx-angular:page pages/<nombre> --project tva
```

## Receta para una feature nueva

1. **Modelo**: añade los tipos a `src/app/core/domain/` (o un nuevo
   `<x>.model.ts` + export en `domain/index.ts`).
2. **Puerto**: `nx g :port <nombre> --project core`; define la interfaz con los
   métodos que la app necesita (Observable de rxjs).
3. **Repositorio**: `nx g :repository <nombre>-http --project core`; implementa
   el puerto con `HttpClient` + `EnvironmentService`; borra el `test()` de
   ejemplo; completa el spec con `HttpTestingController`.
4. **Caso de uso**: `nx g :usecase <nombre> --project core`; inyecta el token
   del puerto (`inject(TOKEN)`) y, si toca estado, `SesionStore`; el spec mockea
   el puerto con `{ provide: TOKEN, useValue: { metodo: jest.fn() } }`.
5. **Cableado**: añade `{ provide: TOKEN, useClass: <Nombre>HttpRepository }` a
   `provideTvaCore()` y el export en `src/app/core/index.ts`.
6. **Página**: `nx g @mapfre-tech/nx-angular:page pages/<x> --project tva`;
   inyecta el caso de uso (nunca el repositorio directamente) y lee estado del
   `SesionStore`; extrae templates >30 líneas a `.page.html`.

## Buenas prácticas Angular 21 (lint obligatorio)

- `changeDetection: ChangeDetectionStrategy.OnPush` en todo componente.
- `inject()` en lugar de constructor DI; `input()`/`output()`/`model()` y
  `viewChild()` signal-based (sin decoradores `@Input/@Output/@ViewChild`).
- Control flow `@if/@for/@switch`; sin `standalone: true` (por defecto en v21);
  `host: {}` en lugar de `@HostBinding/@HostListener`.
- Suscripciones gestionadas (`toSignal`/`takeUntilDestroyed`).
- Reglas ESLint activas (`error`): `prefer-on-push-component-change-detection`,
  `prefer-signals`, `prefer-inject`, `prefer-standalone`,
  `template/prefer-control-flow`, `component-class-suffix: ['Component','Container','Page']`.

## Diseño visual (tema MAPFRE)

Estilos globales en `src/styles.scss` (tema Angular Material M3) que
delega en los partials de `src/styles/` (`_tokens`, `_layout`, `_forms`,
`_tables`, `_utilities`); estilos de componente colocalizados en
`src/app/shared/ui` y `src/app/pages` — solo los `.scss` con reglas
realmente locales. Sin cambios de contrato ni de arquitectura: solo
presentación.

- **Tokens**: `--tva-primary: #D81E05` (hover `#B71C1C`), `--tva-ok: #2E7D32`,
  `--tva-surface: #F4F5F7`, `--tva-border: #E0E0E0`, texto `#212121`/muted `#666`.
  `mat.theme()` con `primary: mat.$red-palette`, `tertiary: azure`,
  `typography: Roboto`, `density: -1`; el rojo exacto se fija sobre
  `--mat-sys-primary`.
- **Layout**: `.pagina` = contenedor 1200px centrado, padding 24px + 96px
  inferior (la botonera va fija, 64px, blanca con borde superior); <900px
  columna única. Cabecera roja 56px (marca `MAPFRE` letter-spacing 2px +
  título + chip de modalidad + usuario + logout). Sub-barra blanca de 40px con
  `app-migas-de-pan` (pasos con chevron, completados con check, actual en rojo).
- **Componentes**: cajas = tarjetas blancas radius 8, borde 1px, sombra suave;
  secciones = filas con separadores, check verde cuando son válidas, borde
  izquierdo rojo al expandir; formularios en grid 2 columnas
  (`grid-template-columns: repeat(2, 1fr); gap 12px 16px`); tablas con cabecera
  `#F5F5F5`, zebra e inputs compactos 36px con `€`; avisos como banners
  ERROR/WARNING/INFO; panel de requisitos del tomador como lista icono+label+
  enlace "Realizar"; diálogo Appian con borde superior rojo y spinner centrado.
- **Accesibilidad**: contraste ≥4.5:1, `:focus-visible` con outline rojo,
  `aria-label` en botones de icono.
