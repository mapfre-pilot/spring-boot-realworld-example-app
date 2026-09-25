# Design: Autenticación y stubs corporativos

## Technical Approach

Los paquetes corporativos (`arch-ram-lib-django-auth`, `arch-ram-lib-django-httpclient`,
`arch-ram-lib-django-cache`, `arch-ram-lib-django-observability`, `@mapfre-tech/ngx-multienvironment`,
`@mapfre-tech/nx-angular|nx-tools`) no son instalables desde el clone (registro privado de Azure
Artifacts). El frontend usa ya el paquete real `ngx-multienvironment`; el backend conserva stubs locales que replican la misma responsabilidad
y un punto de sustitución documentado. La autenticación replica la del portal TVA: JWT Bearer con
roles `TVA_USUARIO` / `TVA_ADMIN_PORTAL` / `TVA_DEBUG`; en `ENVIRONMENT=local` se valida un HS256
firmado con `SECRET_KEY` (generado con `manage.py crear_token_local`), y fuera de local se valida
RS256 contra el JWKS del IdP corporativo (OIDC). En Angular, `AuthService` mantiene el token en
`localStorage` (clave configurable en `environments.json`), el `authInterceptor` añade el Bearer y
`authGuard`/`roleGuard` protegen las rutas; `angular-auth-oidc-client` se inicializa cuando
`auth.mode === 'oidc'`.

## Architecture Decisions

| # | Decision | Choice | Alternatives Rejected | Rationale |
|---|----------|--------|------------------------|-----------|
| 1 | Forma de las libs corporativas | Paquete real `@mapfre-tech/ngx-multienvironment` 4.0.0 (frontend) + stubs locales `arch-ram-lib-*` (backend, feed Python fuera de alcance) | Vendored forks, reescritura total | El feed npm está disponible con `~/.npmrc` + PAT; el frontend usa los tokens del paquete vía `EnvironmentService` propio |
| 2 | Doble backend JWT | `LocalJWTAuthentication` (HS256) + `OIDCJWTAuthentication` (RS256/JWKS) elegidos por `ENVIRONMENT` | Solo OIDC, solo mock header | Desarrollo offline sin IdP; producción con el mismo claim `roles` |
| 3 | Usuario autenticado | `TokenUser` dataclass (`sub`, `roles`, `claims`), sin modelo User de Django | `django.contrib.auth` | La app no gestiona usuarios; el JWT corporativo es la fuente de verdad |
| 4 | Token en frontend | `localStorage` + signals (`token`, `roles`, `autenticado`) | Cookies, sessionStorage | Mismo esquema que el portal; almacenable por clave configurable `tokenStorageKey` |
| 5 | Multi-entorno | `initMultiEnvironmentApp` (paquete real); el contenedor reduce `assets/environments.json` a la clave `TVA_ENV` → el paquete no muestra selector (patrón documentado) | Selector interactivo del paquete, build-time fileReplacements | Un solo build para todos los entornos sin selector en UI |
| 6 | OIDC en frontend | `angular-auth-oidc-client` inicializado solo si `auth.mode==='oidc'`; login documentado como TODO | Implementar flujo completo sin IdP | Sin IdP accesible no se puede probar end-to-end; se deja el punto de conexión |

## Data Flow

```text
HTTP Bearer token
  → LocalJWTAuthentication | OIDCJWTAuthentication (apps/core/auth.py)
  → TokenUser(sub, roles) en request.user
  → views/_auth.py (es_admin / puede_ver_sesion) o IsTvaAdmin
  → respuesta 401/403 o recurso

Frontend: login page → token pegado en localStorage
  → authInterceptor añade Authorization en cada HttpClient call
  → errorInterceptor → MatSnackBar
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tva-backend/sources/apps/core/auth.py` | Create | `TokenUser`, `_decode_hs256`, `_decode_rs256` (PyJWKClient), `LocalJWTAuthentication`, `OIDCJWTAuthentication` |
| `tva-backend/sources/apps/tva/views/_auth.py` | Create | `es_admin`, `puede_ver_sesion`, roles `ROLE_USUARIO`/`ROLE_ADMIN_PORTAL`/`ROLE_DEBUG` |
| `tva-backend/sources/apps/tva/management/commands/crear_token_local.py` | Create | Genera JWT HS256 con `sub` y `roles` para desarrollo |
| `tva-frontend/libs/core/src/lib/infra/auth/auth.service.ts` | Create | `AuthService` signals `token`, `roles`, `autenticado`; `login`/`logout` |
| `tva-frontend/libs/core/src/lib/infra/auth/auth.interceptor.ts` | Create | `authInterceptor` añade `Authorization: Bearer` |
| `tva-frontend/libs/core/src/lib/infra/auth/guards.ts` | Create | `authGuard`, `roleGuard(role)` |

## Interfaces / Contracts

```python
# apps/core/auth.py
@dataclass
class TokenUser:
    sub: str
    roles: list[str] = field(default_factory=list)
    claims: dict = field(default_factory=dict)
    def has_role(self, role: str) -> bool: ...

class LocalJWTAuthentication(authentication.BaseAuthentication): ...
class OIDCJWTAuthentication(authentication.BaseAuthentication): ...

# JWT payload esperado (local)
{ "sub": "ggalv10", "roles": ["TVA_USUARIO", "TVA_ADMIN_PORTAL"], "iat": ..., "exp": ... }
```

```typescript
// @mapfre-tech/ngx-multienvironment/core (paquete real)
export function initMultiEnvironmentApp(opts?): Promise<{ env: string; envConfig: EnvironmentConfig }>;
export function provideEnvironment(env: string, envConfig: EnvironmentConfig): EnvironmentProviders;
export const ENVIRONMENT: InjectionToken<string>;
export const ENVIRONMENT_CONFIG: InjectionToken<EnvironmentConfig>;

// core/config/environment.service.ts
export class EnvironmentService { env: string; config: TvaEnvironmentConfig }

// core/auth
export class AuthService { token: Signal<string | null>; roles: Signal<string[]>; ... }
export const authGuard: CanActivateFn;
export function roleGuard(role: string): CanActivateFn;
export const authInterceptor: HttpInterceptorFn;
```
