# TVA Frontend — Tarificador Vida Ahorro

Migración a Angular 21 (standalone, zoneless, signals) del frontend Appian de TVA.
Generada a partir del arquetipo `arquetipos/frontend-angular/` adaptado a dependencias
públicas (npmjs) — el usuario puede clonar y levantar todo sin acceso a Azure Artifacts.

## Requisitos

- Node ≥ 20 (probado con 24)
- pnpm ≥ 11 (`packageManager: pnpm@11.21.0`; con corepack: `corepack enable && corepack prepare pnpm@11.21.0 --activate`)
- Backend `tva-backend/` corriendo en `http://localhost:8888` (`ENVIRONMENT=local`)

## Arranque

```bash
pnpm install
pnpm exec nx serve tva        # http://localhost:4200
```

El backend local:

```bash
cd ../tva-backend/sources
poetry install && poetry run python manage.py migrate
poetry run python manage.py cargar_parametros
ENVIRONMENT=local poetry run python manage.py runserver 0:8888
```

### Token local

En modo `local` el login es una página que pega un token JWT HS256 generado por el backend:

```bash
poetry run python manage.py crear_token_local --usuario operador1 --roles TVA_USUARIO,TVA_ADMIN_PORTAL
```

Pega el token en `/login`. Se guarda en `localStorage[tva_token]` y el
`authInterceptor` lo envía como `Authorization: Bearer …`.

## Entornos — `public/assets/environments.json`

Multi-entorno en runtime (sin fileReplacements): al arrancar, `initMultiEnvironmentApp()`
descarga `assets/environments.json` y elige la clave por:

1. `window.okcdApplicationEnvironment` (fijado en `assets/env.js`; en el contenedor lo
   genera `docker/entrypoint.sh` desde `TVA_ENV`, defecto `pro`),
2. si `environments.json` tiene varias claves, el selector interactivo del paquete (en
   `env.js` ya fijamos el entorno para evitarlo).

Claves: `dev` (api localhost:8888, `auth.mode: local`), `pre`/`pro` (`auth.mode: oidc` con
`authority`/`clientId`/`scope`/`redirectUrl` = CHANGEME). Cada entorno lleva también
`appianEmbed: { baseUrl, themeIdentifier, signIn }` para los pop-ups Appian Embedded
(en `dev` apunta a Appian TEST; en `pre`/`pro` son CHANGEME).

> **OIDC**: `angular-auth-oidc-client` está instalado y `app.config.ts` ya registra
> `provideAuth` cuando `auth.mode === 'oidc'`. El flujo de login real (redirect, callback,
> silent-renew) queda como TODO marcado en `core/auth/auth.service.ts#loginOidc` —
> requiere el alta de la app registration en EntraID por infraestructura.

## Stubs corporativos

`@mapfre-tech/ngx-multienvironment` 4.0.0 se instala desde el feed corporativo de
Azure Artifacts (`.npmrc` apunta a `pkgs.dev.azure.com`; la autenticación vive en
`~/.npmrc` del usuario, nunca en el repo). La app lo usa vía
`initMultiEnvironmentApp` (main.ts), `provideEnvironment` y los tokens
`ENVIRONMENT`/`ENVIRONMENT_CONFIG` a través de `core/config/environment.service.ts`
(`EnvironmentService` + `TvaEnvironmentConfig`).

La elección de entorno evita el selector interactivo del paquete: `public/assets/env.js`
fija `window.okcdApplicationEnvironment = { env: 'dev' }` en local y el
`docker/entrypoint.sh` del contenedor la regenera con `TVA_ENV` (por defecto `pro`).

## Ejecutores Nx corporativos

`project.json` usa los executores del arquetipo (`@mapfre-tech/nx-angular:application`
y `@mapfre-tech/nx-angular:dev-server`), con nombre `tva`, `outputPath dist/apps/tva`,
los `styles` propios (material-icons + roboto) y configuraciones `dev`/`pre`/`pro`.


## Comandos

```bash
pnpm exec nx lint tva
pnpm exec nx test tva                 # Jest + Spectator, zoneless
pnpm exec nx build tva --configuration=pro
pnpm exec nx build tva --configuration=dev|pre
pnpm exec prettier --check .
```

## Estructura

```
src/app/
├── core/
│   ├── auth/        AuthService (signals token/usuario/roles), authInterceptor, guards
│   ├── api/         TvaApiService (endpoints de openapi.yaml), errorInterceptor→snackbar
│   ├── state/       SesionStore (signal store de la sesión)
│   ├── models/      interfaces TS (Sesion, Pantalla enum, Aviso, Modalidad…)
│   └── validaciones/  NIF/NIE/CIF (port de CMP_validacionDNI) + IBAN
├── shared/ui/       Avisos, Cabecera, MigasDePan, Botonera, CampoTexto/Select, Caja
└── pages/           login, inicio, sesion/:clave (shell + @switch por Pantalla),
                     sesion/pantallas/* (14 containers), admin
```

Rutas: `''`→inicio (authGuard), `login`, `sesion/:clave`, `admin` (roleGuard
`TVA_ADMIN_PORTAL`), `**`→inicio.
