/** Servicio de autenticación TVA.
 *
 * - modo `local` (dev): el usuario pega un token HS256 generado en el backend
 *   con `manage.py crear_token_local`. El token se guarda en
 *   `auth.tokenStorageKey` (default `tva_token`).
 * - modo `oidc` (`local-sso`/pre/pro): Authorization Code + PKCE con
 *   `angular-auth-oidc-client` contra EntraID; la librería gestiona el
 *   almacenamiento/refresh del access token (no se guarda en localStorage).
 *   `roles` viene del claim `roles` del access token; si el token no trae
 *   roles se aplican `auth.defaultRoles` de `environments.json`.
 */
import { Injectable, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { combineLatest } from 'rxjs';

import { EnvironmentService } from '../config/environment.service';

interface JwtClaims {
  sub?: string;
  oid?: string;
  roles?: string[] | string;
  preferred_username?: string;
  upn?: string;
  exp?: number;
}

function decodePayload(token: string): JwtClaims {
  try {
    const payload = token.split('.')[1];
    return JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
  } catch {
    return {};
  }
}

function usuarioDe(claims: JwtClaims): string {
  return claims.preferred_username ?? claims.upn ?? claims.sub ?? '';
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly env = inject(EnvironmentService);
  private readonly router = inject(Router);
  private readonly oidc = inject(OidcSecurityService, { optional: true });

  private readonly storageKey: string;
  readonly token = signal<string | null>(null);
  readonly usuario = computed(() => usuarioDe(decodePayload(this.token() ?? '')));
  readonly roles = computed<string[]>(() => {
    const r = decodePayload(this.token() ?? '').roles;
    const claim = Array.isArray(r) ? r : r ? [r] : [];
    return claim.length ? claim : (this.env.config['auth']?.['defaultRoles'] ?? []);
  });
  readonly autenticado = computed(() => {
    const t = this.token();
    if (!t) return false;
    const exp = decodePayload(t).exp;
    return exp === undefined || exp * 1000 > Date.now();
  });

  constructor() {
    this.storageKey = this.env.config['auth']?.['tokenStorageKey'] ?? 'tva_token';
    if (this.authMode === 'local') {
      const guardado = localStorage.getItem(this.storageKey);
      if (guardado) this.token.set(guardado);
    }
  }

  get authMode(): 'local' | 'oidc' {
    return this.env.config['auth']?.['mode'] ?? 'local';
  }

  /** Arranque OIDC (app initializer, solo modo `oidc`): completa el code flow
   *  tras el redirect del IdP y mantiene la señal tras silent renew. */
  inicializarOidc(): void {
    if (this.authMode !== 'oidc' || !this.oidc) return;
    this.oidc.checkAuth().subscribe(({ isAuthenticated, accessToken }) => {
      if (isAuthenticated) this.token.set(accessToken);
    });
    // Tras silent renew, refrescar la señal con el nuevo access token.
    combineLatest([this.oidc.isAuthenticated$, this.oidc.getAccessToken()]).subscribe(
      ([isAuth, accessToken]) => {
        if (isAuth && accessToken) this.token.set(accessToken);
      }
    );
  }

  login(token: string): void {
    this.token.set(token.trim());
    localStorage.setItem(this.storageKey, this.token() ?? '');
  }

  /** Login OIDC: redirige al IdP corporativo (EntraID). */
  loginOidc(): void {
    this.oidc?.authorize();
  }

  logout(): void {
    if (this.authMode === 'oidc' && this.oidc) {
      this.token.set(null);
      this.oidc.logoffAndRevokeTokens().subscribe();
      return;
    }
    this.token.set(null);
    localStorage.removeItem(this.storageKey);
    void this.router.navigate(['/login']);
  }

  hasRole(role: string): boolean {
    return this.roles().includes(role);
  }
}
