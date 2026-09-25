# Arquitectura de referencia del frontend — Clean Architecture (TVA)

> Documento de referencia transversal: describe la estructura Clean
> Architecture que sigue `tva-frontend` según la guía MAPFRE "Arquitectura de
> aplicación" implementada por los generadores `@mapfre-tech/nx-angular(-esp)`.

## Capas y reglas de dependencia

Todo el código reutilizable vive en la librería `libs/core` (importPath
`@tva/core`), organizada en las capas del layout `clean` del generador
corporativo:

| Capa | Directorio | Contenido | Dependencias permitidas |
|------|-----------|-----------|--------------------------|
| **domain** | `libs/core/src/lib/domain/` | Modelos puros (`*.model.ts`), validaciones (`validaciones/documentos.ts`), utilidades (`nuuma.ts`). Sin Angular ni HTTP. | Ninguna |
| **ports** | `libs/core/src/lib/ports/` | Interfaces de repositorio + `InjectionToken` en el mismo fichero (`<nombre>-repository.port.ts`). | domain |
| **application** | `libs/core/src/lib/application/` | Casos de uso (`<nombre>.usecase.ts`, `providedIn: 'root'`, método `execute(...)`) y el store de solo estado `state/sesion.store.ts`. | domain + ports |
| **data** | `libs/core/src/lib/data/repositories/` | Implementaciones HTTP de los puertos (`<nombre>-http.repository.ts`), `inject(HttpClient)` + `EnvironmentService`. | domain + ports + infra |
| **infra** | `libs/core/src/lib/infra/` | Servicios de infraestructura: `config/environment.service.ts`, `auth/` (service, interceptor, guards), `http/api-error.interceptor.ts`, `appian/appian-embed-script.service.ts`. | domain |

La aplicación (`src/app`, tag `type:app`) solo puede importar desde `@tva/core`
(nunca rutas relativas a `libs/`). El constraint `@nx/enforce-module-boundaries`
en `eslint.base.config.mjs` permite a `type:app` depender únicamente de librerías
con tag `clean-lib`. Las reglas intra-capa (domain no importa de nadie,
application solo domain+ports) se mantienen por convención — ESLint de Nx no
puede distinguir subdirectorios dentro de una misma librería.

`provideTvaCore()` (`libs/core/src/lib/core.providers.ts`) registra los 5
puertos (`{ provide: SESION_REPOSITORY, useClass: SesionHttpRepository }`, …)
y `provideHttpClient(withInterceptors([authInterceptor, errorInterceptor]))`.
`app.config.ts` lo incluye junto a `provideEnvironment` del paquete corporativo.

## Árbol resultante

```
libs/core/src/lib/
├── application/          # 17 usecases + state/sesion.store.ts
├── data/repositories/    # sesion/inicio/catalogo/popup-appian/admin -http.repository.ts
├── domain/               # sesion|inicio|admin|producto|popup|webapi-error .model.ts,
│                         #   validaciones/documentos.ts, nuuma.ts
├── infra/                # config/, auth/, http/, appian/
├── ports/                # sesion|inicio|catalogo|popup-appian|admin -repository.port.ts
└── core.providers.ts     # provideTvaCore()

src/app/
├── pages/                # inicio|login|sesion|admin .page.ts (+ .page.html)
│   └── sesion/pantallas/ # *.container.ts + tomador-base.ts
└── ui/                   # componentes presentacionales + appian/appian-popup.service.ts
```

## Generadores usados (comandos exactos)

```bash
# librería con layout clean
pnpm nx g @mapfre-tech/nx-angular-esp:library core --layout clean \
  --directory libs/core --importPath @tva/core
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

1. **Modelo**: añade los tipos a `libs/core/src/lib/domain/` (o un nuevo
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
   `provideTvaCore()` y el export en `libs/core/src/index.ts`.
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

Estilos globales en `src/styles.scss` (tema Angular Material M3); estilos de
componente colocalizados en `src/app/ui` y `src/app/pages`. Sin cambios de
contrato ni de arquitectura: solo presentación.

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
